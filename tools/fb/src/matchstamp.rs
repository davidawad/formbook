//! `fb match-stamp <doc-dir> [--engine typst|latex|docx] [--sample ID] [--exemplar PDF]`: diff every
//! sample's render against its filed exemplar (`crate::diff::diff_paths`) and write
//! samples/.match-<engine>.txt (PASS plus the sha256 of every render and exemplar) only when every
//! paired sample passes. Any failure or error removes a stale stamp. Exit 0 only when stamped.
//!
//! Pairing: `--exemplar`, else the FILED-EXAMPLE-*.pdf whose hyphen-separated name tokens contain the
//! sample id's first token (ties broken by the number of shared tokens). A sample with no unique
//! exemplar is skipped, or is an error when named with `--sample`.
use crate::check::stamp::{sha256, stamp_text};
use crate::diff::Report;
use crate::fetch::exemplar_pdfs;
use crate::{fail, Res};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

const USAGE: &str =
    "usage: fb match-stamp <doc-dir> [--engine typst|latex|docx] [--sample ID] [--exemplar PDF]";

#[derive(Debug, PartialEq)]
struct Opts {
    dir: PathBuf,
    engine: String,
    sample: Option<String>,
    exemplar: Option<PathBuf>,
}

fn parse_opts(args: &[String]) -> Res<Opts> {
    let mut o = Opts {
        dir: PathBuf::new(),
        engine: "typst".into(),
        sample: None,
        exemplar: None,
    };
    let mut dir = None;
    let mut it = args.iter();
    while let Some(a) = it.next() {
        let mut value = || {
            it.next()
                .cloned()
                .ok_or_else(|| fail(2, format!("{a} needs a value\n{USAGE}")))
        };
        match a.as_str() {
            "--engine" => o.engine = value()?,
            "--sample" => o.sample = Some(value()?),
            "--exemplar" => o.exemplar = Some(PathBuf::from(value()?)),
            s if s.starts_with("--") => {
                return Err(fail(2, format!("unknown option {s}\n{USAGE}")))
            }
            s if dir.is_none() => dir = Some(PathBuf::from(s)),
            _ => return Err(fail(2, USAGE)),
        }
    }
    o.dir = dir.ok_or_else(|| fail(2, USAGE))?;
    match o.engine.as_str() {
        "typst" | "latex" | "docx" => Ok(o),
        e => Err(fail(2, format!("unknown engine {e} (typst, latex, docx)"))),
    }
}

/// samples/OUTPUT-<id>.pdf, .latex.pdf or .docx.pdf.
fn render_name(id: &str, engine: &str) -> String {
    match engine {
        "typst" => format!("samples/OUTPUT-{id}.pdf"),
        e => format!("samples/OUTPUT-{id}.{e}.pdf"),
    }
}

/// The exemplar whose name tokens contain the sample id's first token; ties go to the most shared
/// tokens; None unless the best is unique.
fn pair(id: &str, exemplars: &[String]) -> Option<String> {
    let toks: Vec<&str> = id.split('-').collect();
    let first = toks.first().copied().unwrap_or("");
    let scored: Vec<(usize, &String)> = exemplars
        .iter()
        .filter_map(|n| {
            let stem = n
                .trim_start_matches("FILED-EXAMPLE-")
                .trim_end_matches(".pdf");
            let parts: Vec<&str> = stem.split('-').collect();
            parts
                .contains(&first)
                .then(|| (toks.iter().filter(|t| parts.contains(t)).count(), n))
        })
        .collect();
    let best = scored.iter().map(|s| s.0).max()?;
    let top: Vec<&String> = scored.iter().filter(|s| s.0 == best).map(|s| s.1).collect();
    match top.as_slice() {
        [one] => Some((*one).clone()),
        _ => None,
    }
}

/// The ids of samples/INPUT-<id>.md, sorted.
fn sample_ids(dir: &Path) -> Vec<String> {
    let mut v: Vec<String> = std::fs::read_dir(dir.join("samples"))
        .map(|rd| {
            rd.filter_map(|d| d.ok())
                .filter_map(|d| {
                    let n = d.file_name().to_string_lossy().into_owned();
                    n.strip_prefix("INPUT-")?
                        .strip_suffix(".md")
                        .map(str::to_string)
                })
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    v
}

/// One sample paired with an exemplar; paths relative to the doc dir.
#[derive(Debug, Clone, PartialEq)]
struct Pair {
    id: String,
    exemplar: String,
    render: String,
}

/// Pair the samples; skipped samples come back as messages (an error with --sample).
fn plan(o: &Opts, ids: &[String], exemplars: &[String]) -> Res<(Vec<Pair>, Vec<String>)> {
    let ids: Vec<String> = match &o.sample {
        Some(s) if !ids.contains(s) => {
            return Err(fail(1, format!("fb match-stamp: no samples/INPUT-{s}.md")))
        }
        Some(s) => vec![s.clone()],
        None => ids.to_vec(),
    };
    let mut pairs = Vec::new();
    let mut skipped = Vec::new();
    for id in ids {
        let ex = match &o.exemplar {
            Some(p) => Some(
                p.strip_prefix(&o.dir)
                    .unwrap_or(p)
                    .to_string_lossy()
                    .into_owned(),
            ),
            None => pair(&id, exemplars).map(|n| format!("exemplars/{n}")),
        };
        match (ex, &o.sample) {
            (Some(exemplar), _) => pairs.push(Pair {
                render: render_name(&id, &o.engine),
                id,
                exemplar,
            }),
            (None, Some(_)) => {
                return Err(fail(
                    1,
                    format!("fb match-stamp: no unique exemplar for sample {id} (use --exemplar)"),
                ))
            }
            (None, None) => skipped.push(format!("SKIP {id}: no unique exemplar")),
        }
    }
    Ok((pairs, skipped))
}

/// The stamp text when every pair passed, else the failure lines. Pure: no files touched.
fn decide(
    results: &[(Pair, Res<Report>)],
    sha: impl Fn(&str) -> String,
) -> Result<String, Vec<String>> {
    if results.is_empty() {
        return Err(vec!["no sample could be paired with an exemplar".into()]);
    }
    let mut bad = Vec::new();
    for (p, r) in results {
        match r {
            Ok(rep) if rep.pass => {}
            Ok(rep) => {
                bad.push(format!(
                    "FAIL {} at {} ({} vs {})",
                    p.id, rep.gate, p.render, p.exemplar
                ));
                bad.extend(rep.findings.iter().map(|f| format!("  {f}")));
            }
            Err(e) => bad.push(format!("ERROR {}: {}", p.id, e.msg)),
        }
    }
    if !bad.is_empty() {
        return Err(bad);
    }
    let mut paths: Vec<&str> = results
        .iter()
        .flat_map(|(p, _)| [p.render.as_str(), p.exemplar.as_str()])
        .collect();
    paths.sort();
    paths.dedup();
    let shas: Vec<String> = paths.iter().map(|p| format!("{}  {p}", sha(p))).collect();
    Ok(stamp_text(&shas))
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let o = parse_opts(args)?;
    let stamp = o.dir.join(format!("samples/.match-{}.txt", o.engine));
    let exemplars = exemplar_pdfs(&o.dir.join("exemplars"));
    let planned = plan(&o, &sample_ids(&o.dir), &exemplars);
    let (pairs, skipped) = planned.inspect_err(|_| {
        let _ = std::fs::remove_file(&stamp);
    })?;
    skipped.iter().for_each(|s| println!("{s}"));
    let at = |rel: &str| o.dir.join(rel);
    let results: Vec<(Pair, Res<Report>)> = pairs
        .into_iter()
        .map(|p| {
            let r = match (at(&p.exemplar).is_file(), at(&p.render).is_file()) {
                (false, _) => Err(fail(1, format!("missing {}", p.exemplar))),
                (_, false) => Err(fail(1, format!("missing {}", p.render))),
                _ => crate::diff::diff_paths(&at(&p.exemplar), &at(&p.render)),
            };
            (p, r)
        })
        .collect();
    for (p, r) in &results {
        if let Some(rep) = r.as_ref().ok().filter(|rep| rep.pass) {
            println!("PASS {} ({}) vs {}", p.id, rep.gate, p.exemplar);
        }
    }
    match decide(&results, |rel| sha256(&at(rel).to_string_lossy())) {
        Ok(text) => {
            std::fs::write(&stamp, text)
                .map_err(|e| fail(2, format!("{}: {e}", stamp.display())))?;
            println!(
                "RESULT: MATCH PASS ({} samples), stamp {}",
                results.len(),
                stamp.display()
            );
            Ok(ExitCode::SUCCESS)
        }
        Err(lines) => {
            let _ = std::fs::remove_file(&stamp);
            lines.iter().for_each(|l| println!("{l}"));
            println!("RESULT: MATCH FAIL ({} engine)", o.engine);
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn rep(pass: bool) -> Report {
        Report {
            pass,
            gate: if pass { "G4" } else { "G2" },
            findings: if pass {
                vec![]
            } else {
                vec!["p3: body baseline +1.2pt".into()]
            },
        }
    }

    fn p(id: &str) -> Pair {
        Pair {
            id: id.into(),
            exemplar: format!("exemplars/FILED-EXAMPLE-{id}.pdf"),
            render: render_name(id, "typst"),
        }
    }

    #[test]
    fn stamp_only_when_all_pass() {
        let sha = |s: &str| format!("h{}", s.len());
        let ok = decide(&[(p("a"), Ok(rep(true))), (p("b"), Ok(rep(true)))], sha).unwrap();
        assert_eq!(
            ok,
            "PASS\nh29  exemplars/FILED-EXAMPLE-a.pdf\nh29  exemplars/FILED-EXAMPLE-b.pdf\nh20  samples/OUTPUT-a.pdf\nh20  samples/OUTPUT-b.pdf\n"
        );
        let bad = decide(&[(p("a"), Ok(rep(true))), (p("b"), Ok(rep(false)))], sha).unwrap_err();
        assert_eq!(
            bad[0],
            "FAIL b at G2 (samples/OUTPUT-b.pdf vs exemplars/FILED-EXAMPLE-b.pdf)"
        );
        assert_eq!(bad[1], "  p3: body baseline +1.2pt");
        let err = decide(&[(p("a"), Err(fail(2, "boom")))], sha).unwrap_err();
        assert_eq!(err, vec!["ERROR a: boom"]);
        assert!(decide(&[], sha).is_err());
    }

    #[test]
    fn pairing() {
        let ex: Vec<String> = [
            "FILED-EXAMPLE-sweet-v-mcmahon-26-1136-opening-brief.pdf",
            "FILED-EXAMPLE-aca-connects-21-15430-opening-brief.pdf",
            "FILED-EXAMPLE-rooks-16-04003-motion.pdf",
            "FILED-EXAMPLE-rooks-16-04003-reply.pdf",
        ]
        .map(String::from)
        .to_vec();
        assert_eq!(
            pair("sweet-opening-brief", &ex).as_deref(),
            Some(ex[0].as_str())
        );
        assert_eq!(pair("generic-opening-brief", &ex), None);
        assert_eq!(pair("rooks", &ex), None);
        assert_eq!(pair("rooks-reply", &ex).as_deref(), Some(ex[3].as_str()));
        // a substring is not a token: "sweet" does not pair with "sweetwater"
        assert_eq!(pair("sweetwater-brief", &ex), None);
    }

    #[test]
    fn planning() {
        let args = |v: &[&str]| v.iter().map(|s| s.to_string()).collect::<Vec<_>>();
        let ex = vec!["FILED-EXAMPLE-sweet-v-mcmahon-1.pdf".to_string()];
        let ids = vec!["generic-brief".to_string(), "sweet-brief".to_string()];
        let o = parse_opts(&args(&["d", "--engine", "latex"])).unwrap();
        let (pairs, skipped) = plan(&o, &ids, &ex).unwrap();
        assert_eq!(pairs.len(), 1);
        assert_eq!(pairs[0].render, "samples/OUTPUT-sweet-brief.latex.pdf");
        assert_eq!(
            pairs[0].exemplar,
            "exemplars/FILED-EXAMPLE-sweet-v-mcmahon-1.pdf"
        );
        assert_eq!(skipped, vec!["SKIP generic-brief: no unique exemplar"]);
        let o = parse_opts(&args(&["d", "--sample", "generic-brief"])).unwrap();
        assert!(plan(&o, &ids, &ex).is_err());
        let o = parse_opts(&args(&[
            "d",
            "--sample",
            "generic-brief",
            "--exemplar",
            "d/exemplars/X.pdf",
        ]))
        .unwrap();
        let (pairs, _) = plan(&o, &ids, &ex).unwrap();
        assert_eq!(pairs[0].exemplar, "exemplars/X.pdf");
        assert_eq!(render_name("x", "docx"), "samples/OUTPUT-x.docx.pdf");
        assert!(parse_opts(&args(&["d", "--engine", "pdf"])).is_err());
    }
}
