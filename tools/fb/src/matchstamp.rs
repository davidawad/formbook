//! `fb match-stamp <doc-dir> [--engine typst|latex|docx] [--sample ID] [--exemplar PDF]`: diff every
//! sample's render (usage/OUTPUT-<stem>-<id>.<engine>.pdf) against its filed SAMPLE
//! (`crate::diff::diff_paths`) and write usage/.match-<engine>.txt (PASS plus the sha256 of every
//! render and SAMPLE) only when every paired sample passes. Any failure or error removes a stale
//! stamp. Exit 0 only when stamped.
//!
//! Pairing: `--exemplar`, else the SAMPLE-<stem>-<id>.pdf that `crate::layout::pair` picks for the
//! INPUT id (equal id, else longest shared leading run, ties by shared trailing run). A sample with no
//! unique SAMPLE is skipped, or is an error when named with `--sample`.
use crate::check::stamp::{sha256, stamp_text};
use crate::diff::Report;
use crate::layout::{self, Doc, INPUT, SAMPLE};
use crate::{fail, Res};
use std::path::PathBuf;
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

/// usage/OUTPUT-<stem>-<id>.typst.pdf, .latex.pdf or .docx.pdf.
fn render_name(stem: &str, id: &str, engine: &str) -> String {
    Doc::rel(&layout::output_name(stem, id, engine))
}

/// One sample paired with an exemplar; paths relative to the doc dir.
#[derive(Debug, Clone, PartialEq)]
struct Pair {
    id: String,
    exemplar: String,
    render: String,
}

/// Pair the samples; skipped samples come back as messages (an error with --sample).
fn plan(o: &Opts, stem: &str, ids: &[String], samples: &[String]) -> Res<(Vec<Pair>, Vec<String>)> {
    let ids: Vec<String> = match &o.sample {
        Some(s) if !ids.contains(s) => {
            return Err(fail(
                1,
                format!(
                    "fb match-stamp: no {}",
                    Doc::rel(&layout::input_name(stem, s))
                ),
            ))
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
            None => layout::pair(&id, samples).map(|s| Doc::rel(&layout::sample_name(stem, &s))),
        };
        match (ex, &o.sample) {
            (Some(exemplar), _) => pairs.push(Pair {
                render: render_name(stem, &id, &o.engine),
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
    let doc = Doc::open(&o.dir)?;
    let stamp = doc.usage().join(format!(".match-{}.txt", o.engine));
    let planned = plan(&o, &doc.stem, &doc.ids(INPUT), &doc.ids(SAMPLE));
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
            exemplar: format!("usage/SAMPLE-ca9-{id}.pdf"),
            render: render_name("ca9", id, "typst"),
        }
    }

    #[test]
    fn stamp_only_when_all_pass() {
        let sha = |s: &str| format!("h{}", s.len());
        let ok = decide(&[(p("a"), Ok(rep(true))), (p("b"), Ok(rep(true)))], sha).unwrap();
        assert_eq!(
            ok,
            "PASS\nh28  usage/OUTPUT-ca9-a.typst.pdf\nh28  usage/OUTPUT-ca9-b.typst.pdf\nh22  usage/SAMPLE-ca9-a.pdf\nh22  usage/SAMPLE-ca9-b.pdf\n"
        );
        let bad = decide(&[(p("a"), Ok(rep(true))), (p("b"), Ok(rep(false)))], sha).unwrap_err();
        assert_eq!(
            bad[0],
            "FAIL b at G2 (usage/OUTPUT-ca9-b.typst.pdf vs usage/SAMPLE-ca9-b.pdf)"
        );
        assert_eq!(bad[1], "  p3: body baseline +1.2pt");
        let err = decide(&[(p("a"), Err(fail(2, "boom")))], sha).unwrap_err();
        assert_eq!(err, vec!["ERROR a: boom"]);
        assert!(decide(&[], sha).is_err());
    }

    #[test]
    fn planning() {
        let args = |v: &[&str]| v.iter().map(|s| s.to_string()).collect::<Vec<_>>();
        let ex = vec!["sweetvmcmahon1".to_string()];
        let ids = vec!["genericbrief".to_string(), "sweetbrief".to_string()];
        let o = parse_opts(&args(&["d", "--engine", "latex"])).unwrap();
        let (pairs, skipped) = plan(&o, "ca9", &ids, &ex).unwrap();
        assert_eq!(pairs.len(), 1);
        assert_eq!(pairs[0].render, "usage/OUTPUT-ca9-sweetbrief.latex.pdf");
        assert_eq!(pairs[0].exemplar, "usage/SAMPLE-ca9-sweetvmcmahon1.pdf");
        assert_eq!(skipped, vec!["SKIP genericbrief: no unique exemplar"]);
        let o = parse_opts(&args(&["d", "--sample", "genericbrief"])).unwrap();
        assert!(plan(&o, "ca9", &ids, &ex).is_err());
        let o = parse_opts(&args(&["d", "--sample", "nope"])).unwrap();
        assert_eq!(
            plan(&o, "ca9", &ids, &ex).unwrap_err().msg,
            "fb match-stamp: no usage/INPUT-ca9-nope.md"
        );
        let o = parse_opts(&args(&[
            "d",
            "--sample",
            "genericbrief",
            "--exemplar",
            "d/usage/SAMPLE-ca9-x.pdf",
        ]))
        .unwrap();
        let (pairs, _) = plan(&o, "ca9", &ids, &ex).unwrap();
        assert_eq!(pairs[0].exemplar, "usage/SAMPLE-ca9-x.pdf");
        assert_eq!(
            render_name("ca9", "x", "docx"),
            "usage/OUTPUT-ca9-x.docx.pdf"
        );
        assert_eq!(
            render_name("ca9", "x", "typst"),
            "usage/OUTPUT-ca9-x.typst.pdf"
        );
        assert!(parse_opts(&args(&["d", "--engine", "pdf"])).is_err());
    }
}
