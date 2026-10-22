//! `fb selftest <court-dir>`: does the checker actually catch defects? A mutation test for `fb check`.
//!
//! Each mutant breaks ONE thing, rebuilds the PDF, and runs the checker against the ORIGINAL markdown. The named
//! requirement IDs must FAIL. A mutant the checker lets through means a check is blind, which is the failure mode
//! that sank the earlier attempt (aggregate scores declaring PASS on visibly wrong pages). Run this after changing
//! any check.
//!
//! Content mutants change the markdown that is rendered (but not the markdown the checks compare against). Layout
//! mutants change the template in a scratch copy of the court folder. Latex mutants change latex/template.tex and are
//! checked with `--engine latex`; latex build mutants must make the render itself refuse (the stock pdflatex check:
//! the .tex alone compiles in an empty directory with TEXINPUTS unset). Docx mutants render with the docx engine and
//! then break the .docx package itself (selftest/docx.rs); DEF-DOCX-OPEN must FAIL. The mutations are `sed` programs, applied
//! with the system sed, with the mutation definitions kept here as data.
use crate::proc::capture;
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const SAMPLE: &str = "generic";
const TEMPLATE: &str = "ca9-brief.typ";
const LATEX_TEMPLATE: &str = "template.tex";

mod docx;
pub(crate) mod mutants;
use mutants::{Kind, Mutant, MUTANTS};

/// Which of the wanted requirement ids did not FAIL in the checker output.
fn missed<'a>(out: &str, want: &'a str) -> Vec<&'a str> {
    want.split_whitespace()
        .filter(|id| {
            let prefix = format!("  FAIL  {id} ");
            !out.lines().any(|l| l.starts_with(&prefix))
        })
        .collect()
}

/// The verdict line for a mutant that built.
fn verdict(m: &Mutant, out: &str) -> (String, bool) {
    let miss = missed(out, m.want);
    if miss.is_empty() {
        (format!("caught   {}  (failed: {})", m.name, m.want), true)
    } else {
        (
            format!(
                "MISSED   {}  (should have failed: {})",
                m.name,
                miss.join(" ")
            ),
            false,
        )
    }
}

/// The folder the mutant copies go in. A mutant copy (scratch/<mutant>) sits as deep below the repo root as the
/// court itself, so a template's relative imports of shared files (`../../../../lib/typst/...`) resolve the same
/// way: out/selftest-<alias>/<mutant> for a court three levels down, padded for a deeper one.
fn scratch_dir(root: &Path, court: &Path, alias: &str) -> PathBuf {
    let canon = std::fs::canonicalize(root).unwrap_or_else(|_| root.to_path_buf());
    let depth = court
        .strip_prefix(&canon)
        .or_else(|_| court.strip_prefix(root))
        .map_or(0, |r| r.components().count());
    let mut d = root.join("out").join(format!("selftest-{alias}"));
    for _ in 3..depth {
        d.push("d");
    }
    d
}

fn copy_into(from: &[PathBuf], to: &Path) -> Res<()> {
    let o = capture(Command::new("cp").arg("-R").args(from).arg(to))?;
    o.status.success().then_some(()).ok_or_else(|| {
        fail(
            2,
            format!(
                "fb selftest: cp into {} failed: {}",
                to.display(),
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        )
    })
}

/// `sed EXPR FILE` stdout.
fn sed(expr: &str, file: &Path) -> Res<Vec<u8>> {
    let o = capture(Command::new("sed").arg(expr).arg(file))?;
    o.status.success().then_some(o.stdout).ok_or_else(|| {
        fail(
            2,
            format!(
                "fb selftest: sed failed on {}: {}",
                file.display(),
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        )
    })
}

fn sample_field(checks: &serde_yaml::Value, key: &str) -> Res<String> {
    checks["samples"]
        .as_sequence()
        .into_iter()
        .flatten()
        .find(|s| s["id"].as_str() == Some(SAMPLE))
        .and_then(|s| s[key].as_str())
        .map(str::to_string)
        .ok_or_else(|| {
            fail(
                2,
                format!("fb selftest: checks.yaml has no sample {SAMPLE} with .{key}"),
            )
        })
}

struct Run<'a> {
    exe: PathBuf,
    root: &'a Path,
    court: &'a Path,
    scratch: &'a Path,
    md: String,
    pdf: String,
}

impl Run<'_> {
    fn fresh_copy(&self, name: &str) -> Res<PathBuf> {
        let d = self.scratch.join(name);
        std::fs::create_dir_all(&d)
            .map_err(|e| fail(2, format!("fb selftest: {}: {e}", d.display())))?;
        let from: Vec<PathBuf> = [
            "typst",
            "latex",
            "docx",
            "usage",
            "checks.yaml",
            "court.json",
        ]
        .iter()
        .map(|f| self.court.join(f))
        .collect();
        copy_into(&from, &d)?;
        std::fs::create_dir_all(d.join("reviews"))
            .map_err(|e| fail(2, format!("fb selftest: {e}")))?;
        Ok(d)
    }

    /// Render `sample` of the scratch court `d` with `engine` into `d/<pdf>` (the engine's OUTPUT for latex);
    /// Err carries the render's whole stderr. `texinputs`: the TEXINPUTS value to run with, if any.
    fn render(
        &self,
        d: &Path,
        sample: &str,
        engine: &str,
        texinputs: Option<String>,
    ) -> Res<Result<(), String>> {
        let mut cmd = Command::new(&self.exe);
        cmd.current_dir(self.root)
            .env("FB_ROOT", self.root)
            .args(["render", "--engine", engine, "--deny-warnings"])
            .arg(d)
            .arg(sample)
            .arg(d.join(self.out(engine)));
        if let Some(t) = texinputs {
            cmd.env("TEXINPUTS", t);
        }
        let o = capture(&mut cmd)?;
        Ok(match o.status.success() {
            true => Ok(()),
            false => Err(String::from_utf8_lossy(&o.stderr).into_owned()),
        })
    }

    /// Where the checker looks for `engine`'s render of the sample (usage/OUTPUT-<id>.<engine>.pdf).
    fn out(&self, engine: &str) -> String {
        match engine {
            "typst" => self.pdf.clone(),
            e => self.pdf.replace(".typst.pdf", &format!(".{e}.pdf")),
        }
    }

    /// Run one mutant; the line to print and whether it counts as handled.
    fn mutant(&self, m: &Mutant) -> Res<(String, bool)> {
        let d = self.fresh_copy(m.name)?;
        let (engine, texinputs) = match m.kind {
            Kind::Content | Kind::Layout => ("typst", false),
            Kind::Latex => ("latex", false),
            Kind::LatexBuild { texinputs } => ("latex", texinputs),
            Kind::Docx { .. } => ("docx", false),
        };
        let sample = match m.kind {
            Kind::Docx { .. } => self.md.clone(),
            Kind::Content => {
                std::fs::write(
                    d.join("mutated.md"),
                    sed(m.expr, &self.court.join(&self.md))?,
                )
                .map_err(|e| fail(2, format!("fb selftest: {e}")))?;
                "mutated.md".to_string()
            }
            _ => {
                let rel = match engine {
                    "typst" => Path::new("typst").join(TEMPLATE),
                    _ => Path::new("latex").join(LATEX_TEMPLATE),
                };
                let orig = self.court.join(&rel);
                let changed = sed(m.expr, &orig)?;
                if changed == std::fs::read(&orig).unwrap_or_default() {
                    return Ok((
                        format!("MUTANT {}: the sed expression changed nothing", m.name),
                        false,
                    ));
                }
                std::fs::write(d.join(&rel), changed)
                    .map_err(|e| fail(2, format!("fb selftest: {e}")))?;
                self.md.clone()
            }
        };
        let path = texinputs.then(|| format!("{}:", d.join("latex").display()));
        let built = self.render(&d, &sample, engine, path)?;
        if let Kind::LatexBuild { .. } = m.kind {
            return Ok(build_verdict(m, built));
        }
        if let Err(log) = built {
            let head: Vec<&str> = log.lines().take(3).collect();
            return Ok((
                format!("MUTANT {}: render failed: {}", m.name, head.join("\n")),
                false,
            ));
        }
        if let Kind::Docx { part } = m.kind {
            let pdf = d.join(self.out(engine));
            let docx = pdf.with_extension("");
            if let Err(e) = docx::mutate(&docx, part, m.expr) {
                return Ok((format!("MUTANT {}: {}", m.name, e.msg), false));
            }
        }
        // a mutant is meant to fail the checker, so its exit status is ignored
        let o = capture(
            Command::new(&self.exe)
                .current_dir(self.root)
                .env("FB_ROOT", self.root)
                .arg("check")
                .arg(&d)
                .args(["--engine", engine, "--no-render", "--only", SAMPLE]),
        )?;
        let out = format!(
            "{}{}",
            String::from_utf8_lossy(&o.stdout),
            String::from_utf8_lossy(&o.stderr)
        );
        Ok(verdict(m, &out))
    }
}

/// The verdict for a mutant whose render must fail with `want` in its message.
fn build_verdict(m: &Mutant, built: Result<(), String>) -> (String, bool) {
    match built {
        Err(log) if log.contains(m.want) => (
            format!("caught   {}  (render refused: {})", m.name, m.want),
            true,
        ),
        Err(log) => (
            format!(
                "MISSED   {}  (render failed without \"{}\": {})",
                m.name,
                m.want,
                log.lines().last().unwrap_or("")
            ),
            false,
        ),
        Ok(()) => (
            format!(
                "MISSED   {}  (render should have failed: {})",
                m.name, m.want
            ),
            false,
        ),
    }
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let [dir] = args else {
        return Err(fail(2, "usage: fb selftest <court-dir>"));
    };
    let root = repo_root()?;
    let court =
        std::fs::canonicalize(dir).map_err(|e| fail(2, format!("fb selftest: {dir}: {e}")))?;
    let cj: Value = std::fs::read(court.join("court.json"))
        .ok()
        .and_then(|b| serde_json::from_slice(&b).ok())
        .ok_or_else(|| {
            fail(
                2,
                format!("fb selftest: {}/court.json unreadable", court.display()),
            )
        })?;
    let alias = cj["alias"].as_str().unwrap_or("null").to_string();
    let scratch = scratch_dir(&root, &court, &alias);
    std::fs::create_dir_all(&scratch)
        .map_err(|e| fail(2, format!("fb selftest: {}: {e}", scratch.display())))?;
    let checks: serde_yaml::Value = std::fs::read_to_string(court.join("checks.yaml"))
        .ok()
        .and_then(|t| serde_yaml::from_str(&t).ok())
        .ok_or_else(|| {
            fail(
                2,
                format!("fb selftest: {}/checks.yaml unreadable", court.display()),
            )
        })?;
    let run = Run {
        exe: std::env::current_exe().map_err(|e| fail(2, format!("fb selftest: {e}")))?,
        root: &root,
        court: &court,
        scratch: &scratch,
        md: sample_field(&checks, "md")?,
        pdf: sample_field(&checks, "pdf")?,
    };
    let mut fails = 0;
    for m in MUTANTS {
        let (line, ok) = run.mutant(m)?;
        println!("{line}");
        fails += usize::from(!ok);
    }
    println!();
    if fails == 0 {
        println!("SELFTEST OK: every mutant was caught");
        Ok(ExitCode::SUCCESS)
    } else {
        println!("SELFTEST FAILED: {fails} mutants were not caught (or did not build)");
        Ok(ExitCode::from(1))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mutant_copies_sit_as_deep_as_the_court() {
        let root = Path::new("/nonexistent-root");
        let d = scratch_dir(
            root,
            &root.join("courts/ninth-circuit/court-of-appeals"),
            "ca9",
        );
        assert_eq!(d, root.join("out/selftest-ca9"));
        let d = scratch_dir(root, &root.join("courts/a/b/opening-brief"), "x");
        assert_eq!(
            d.join("m").components().count(),
            root.join("courts/a/b/opening-brief").components().count()
        );
    }

    fn m(want: &'static str) -> Mutant {
        Mutant {
            name: "n",
            want,
            kind: Kind::Layout,
            expr: "s/a/b/",
        }
    }

    #[test]
    fn table_matches_the_shell_script() {
        assert_eq!(MUTANTS.len(), 28);
        assert_eq!(
            MUTANTS.iter().filter(|m| m.kind == Kind::Content).count(),
            6
        );
        assert!(MUTANTS
            .iter()
            .any(|m| m.name == "toa-tag-before-citation" && m.want == "CA9-TOOL-006"));
        assert_eq!(
            MUTANTS.iter().filter(|m| m.want == "CA9-TOOL-007").count(),
            2
        );
        assert!(MUTANTS
            .iter()
            .any(|m| m.name == "cover-two-pages" && m.want == "DEF-COVER-001"));
    }

    #[test]
    fn a_build_mutant_is_caught_only_by_the_named_refusal() {
        let mut b = m("stock pdflatex check");
        b.kind = Kind::LatexBuild { texinputs: false };
        assert!(build_verdict(&b, Err("x\nfb render: stock pdflatex check: y".into())).1);
        assert!(!build_verdict(&b, Err("fb render: pdflatex failed".into())).1);
        assert!(!build_verdict(&b, Ok(())).1);
    }

    #[test]
    fn caught_when_every_wanted_id_fails() {
        let out = "  PASS  CA9-X-001 ok\n  FAIL  CA9-TOOL-001 missing\n";
        assert_eq!(
            verdict(&m("CA9-TOOL-001"), out),
            ("caught   n  (failed: CA9-TOOL-001)".into(), true)
        );
    }

    #[test]
    fn missed_lists_ids_that_did_not_fail() {
        let out = "  FAIL  CA9-A-001 x\n  PASS  CA9-B-002 y\n";
        let (line, ok) = verdict(&m("CA9-A-001 CA9-B-002 CA9-C-003"), out);
        assert!(!ok);
        assert_eq!(
            line,
            "MISSED   n  (should have failed: CA9-B-002 CA9-C-003)"
        );
    }

    #[test]
    fn a_fail_prefix_of_another_id_does_not_count() {
        assert_eq!(missed("  FAIL  CA9-A-0011 x\n", "CA9-A-001"), ["CA9-A-001"]);
    }

    #[test]
    fn sample_fields_come_from_checks_yaml() {
        let y: serde_yaml::Value = serde_yaml::from_str("samples:\n  - id: other\n    md: x.md\n  - id: generic\n    md: g.md\n    pdf: g.pdf\n").unwrap();
        assert_eq!(sample_field(&y, "md").unwrap(), "g.md");
        assert_eq!(sample_field(&y, "pdf").unwrap(), "g.pdf");
        assert!(sample_field(&y, "nope").is_err());
    }
}
