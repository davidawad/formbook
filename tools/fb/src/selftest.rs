//! `fb selftest <court-dir>`: does the checker actually catch defects? A mutation test for `fb check`.
//!
//! Each mutant breaks ONE thing, rebuilds the PDF, and runs the checker against the ORIGINAL markdown. The named
//! requirement IDs must FAIL. A mutant the checker lets through means a check is blind, which is the failure mode
//! that sank the earlier attempt (aggregate scores declaring PASS on visibly wrong pages). Run this after changing
//! any check.
//!
//! Content mutants change the markdown that is rendered (but not the markdown the checks compare against). Layout
//! mutants change the template in a scratch copy of the court folder. The mutations are `sed` programs, applied
//! with the system sed, with the mutation definitions kept here as data.
use crate::proc::capture;
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const SAMPLE: &str = "generic";
const TEMPLATE: &str = "ca9-brief.typ";

#[derive(Debug, Clone, Copy, PartialEq)]
enum Kind {
    Content,
    Layout,
}

struct Mutant {
    name: &'static str,
    want: &'static str,
    kind: Kind,
    expr: &'static str,
}

/// content mutants: PDF built from changed markdown, compared with the original; layout mutants: template
/// changed, markdown unchanged.
const MUTANTS: &[Mutant] = &[
    Mutant {
        name: r"drop-paragraph",
        want: r"CA9-TOOL-001",
        kind: Kind::Content,
        expr: r"/^90\\\. The administrative record/d",
    },
    Mutant {
        name: r"drop-dash-paragraph",
        want: r"CA9-TOOL-001",
        kind: Kind::Content,
        expr: r"/^\\- The District has never explained/d",
    },
    Mutant {
        name: r"alter-word",
        want: r"CA9-TOOL-001",
        kind: Kind::Content,
        expr: r"s/The word “shall” forecloses/The word “may” forecloses/",
    },
    Mutant {
        name: r"lose-italics",
        want: r"CA9-TOOL-003",
        kind: Kind::Content,
        expr: r"s/\*Brightwater\* held that/Brightwater held that/",
    },
    Mutant {
        name: r"alter-footnote",
        want: r"CA9-TOOL-004",
        kind: Kind::Content,
        expr: r"s/The order was not preceded by notice/The order was preceded by notice/",
    },
    Mutant {
        name: r"lose-footnote-text",
        want: r"CA9-TOOL-004",
        kind: Kind::Content,
        expr: r"s/ The point is reserved for any remand\.//",
    },
    Mutant {
        name: r"single-spaced",
        want: r"CA9-FORM-003",
        kind: Kind::Layout,
        expr: r"s/^#let body-leading = 0.94em/#let body-leading = 0.2em/",
    },
    Mutant {
        name: r"small-type",
        want: r"CA9-FORM-004",
        kind: Kind::Layout,
        expr: r"s/^#let type-size = 14pt/#let type-size = 12pt/",
    },
    Mutant {
        name: r"narrow-margins",
        want: r"CA9-FORM-002",
        kind: Kind::Layout,
        expr: r"s/^#let page-margin = 1in/#let page-margin = 0.8in/",
    },
    Mutant {
        name: r"left-aligned-headings",
        want: r"CA9-FORM-009",
        kind: Kind::Layout,
        expr: r"s/shared-section-heading(it.body, type-size, single-leading, above: 1.5em, below: 1.1em)/block(width: 100%, above: 1.5em, below: 1.1em, align(left, strong(upper(it.body))))/",
    },
    Mutant {
        name: r"wrong-font",
        want: r"CA9-FORM-007",
        kind: Kind::Layout,
        // ca9 declares Liberation Serif as its vendored serif face; mutate that declaration explicitly.
        expr: r#"s|^#let font-family = .*"Liberation Serif".*$|#let font-family = "DejaVu Sans Mono"|"#,
    },
    Mutant {
        name: r"footnotes-small",
        want: r"CA9-FORM-004",
        kind: Kind::Layout,
        expr: r"s/shared-footnote-body(note.body, num, type-size,/shared-footnote-body(note.body, num, 11pt,/",
    },
    Mutant {
        name: r"no-footnote-size",
        want: r"CA9-FORM-004",
        kind: Kind::Layout,
        // typst's own footnote entry (0.85 em) instead of the template's 14 pt one
        expr: r"s/^    shared-footnote-body(note.body, num, type-size, single-leading, 0.5em)$/    it/",
    },
    Mutant {
        name: r"wrong-word-count",
        want: r"CA9-CERT-002",
        kind: Kind::Layout,
        expr: r"s/^  certificate-of-compliance(meta, words)$/  certificate-of-compliance(meta, words + 7)/",
    },
    Mutant {
        name: r"argument-numbering",
        want: r"CA9-CONT-012",
        kind: Kind::Layout,
        expr: r#"s/if h.level == 2 { numbering("I.", n) }/if h.level == 2 { numbering("A.", n) }/"#,
    },
    Mutant {
        name: r"case-text-in-template",
        want: r"CA9-TOOL-002",
        kind: Kind::Layout,
        expr: r"s|^// U.S. Court of Appeals for the Ninth Circuit: principal (opening) brief\.|& Theresa Sweet, et al.,|",
    },
    Mutant {
        name: r"toa-tag-before-citation",
        want: r"CA9-TOOL-006",
        kind: Kind::Layout,
        expr: r"s/tag-after-first-word(it.body, \[#metadata(it.dest.slice(4))<toa-hit>\]).first()/{ [#metadata(it.dest.slice(4))<toa-hit>]; it.body }/",
    },
    Mutant {
        name: r"toa-wrong-page",
        want: r"CA9-TOOL-006",
        kind: Kind::Layout,
        expr: r#"s/let page-text = shared-authority-page-labels(hits, key, passim-threshold)/let page-text = hits.filter(h => h.value == key).map(h => str(counter(page).at(h.location()).first() + 1)).dedup().join(", ")/"#,
    },
];

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
        let from: Vec<PathBuf> = ["typst", "usage", "checks.yaml", "court.json"]
            .iter()
            .map(|f| self.court.join(f))
            .collect();
        copy_into(&from, &d)?;
        std::fs::create_dir_all(d.join("reviews"))
            .map_err(|e| fail(2, format!("fb selftest: {e}")))?;
        Ok(d)
    }

    /// Render `sample` of the scratch court `d` into `d/<pdf>`; Err carries the first 3 lines of the log.
    fn render(&self, d: &Path, sample: &str) -> Res<Result<(), String>> {
        let o = capture(
            Command::new(&self.exe)
                .current_dir(self.root)
                .env("FB_ROOT", self.root)
                .args(["render", "--deny-warnings"])
                .arg(d)
                .arg(sample)
                .arg(d.join(&self.pdf)),
        )?;
        let head: Vec<String> = String::from_utf8_lossy(&o.stderr)
            .lines()
            .take(3)
            .map(str::to_string)
            .collect();
        Ok(if o.status.success() {
            Ok(())
        } else {
            Err(head.join("\n"))
        })
    }

    /// Run one mutant; the line to print and whether it counts as handled.
    fn mutant(&self, m: &Mutant) -> Res<(String, bool)> {
        let d = self.fresh_copy(m.name)?;
        let built = match m.kind {
            Kind::Content => {
                std::fs::write(
                    d.join("mutated.md"),
                    sed(m.expr, &self.court.join(&self.md))?,
                )
                .map_err(|e| fail(2, format!("fb selftest: {e}")))?;
                self.render(&d, "mutated.md")?
            }
            Kind::Layout => {
                let orig = self.court.join("typst").join(TEMPLATE);
                let changed = sed(m.expr, &orig)?;
                if changed == std::fs::read(&orig).unwrap_or_default() {
                    return Ok((
                        format!("MUTANT {}: the sed expression changed nothing", m.name),
                        false,
                    ));
                }
                std::fs::write(d.join("typst").join(TEMPLATE), changed)
                    .map_err(|e| fail(2, format!("fb selftest: {e}")))?;
                self.render(&d, &self.md)?
            }
        };
        if let Err(log) = built {
            return Ok((format!("MUTANT {}: render failed: {log}", m.name), false));
        }
        // a mutant is meant to fail the checker, so its exit status is ignored
        let o = capture(
            Command::new(&self.exe)
                .current_dir(self.root)
                .env("FB_ROOT", self.root)
                .arg("check")
                .arg(&d)
                .args(["--no-render", "--only", SAMPLE]),
        )?;
        let out = format!(
            "{}{}",
            String::from_utf8_lossy(&o.stdout),
            String::from_utf8_lossy(&o.stderr)
        );
        Ok(verdict(m, &out))
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
        assert_eq!(MUTANTS.len(), 18);
        assert_eq!(
            MUTANTS.iter().filter(|m| m.kind == Kind::Content).count(),
            6
        );
        assert!(MUTANTS
            .iter()
            .any(|m| m.name == "toa-tag-before-citation" && m.want == "CA9-TOOL-006"));
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
