//! `fb check`: the eval loop's mechanical gates for one court or doc-type folder (was tools/check.sh).
//! The checks themselves stay in tools/check/lib.sh; see bridge.rs.
mod bridge;
mod opts;
mod prepare;
mod rows;
mod sh;
pub(crate) mod stamp;

use crate::{fail, Res};
use sh::{cfg, io_fail, out, Env};
use std::fs::OpenOptions;
use std::io::Write;
use std::process::ExitCode;

/// Everything the gates need about the run (check.sh's globals).
pub struct Ctx {
    pub root: String,
    pub doc: String,
    pub court: String,
    pub engine: String,
    pub render: bool,
    pub out: String,
    pub template: String,
    pub calib: String,
    pub ftop: i64,
    pub ph: i64,
    pub second: String,
    pub env: Env,
}

/// One sample being checked.
struct Sample {
    sid: String,
    md: String,
    pdf: String,
    w: String,
    npages: String,
}

/// The run's counters, mirrored into $OUT/.tally .fails .fails_sample .shas as check.sh kept them.
#[derive(Default)]
struct Tally {
    pass: usize,
    fail: usize,
    fails: u64,
    fails_sample: u64,
    shas: Vec<String>,
}

fn append(path: &str, s: &str) -> Res<()> {
    OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)
        .and_then(|mut f| f.write_all(s.as_bytes()))
        .map_err(|e| io_fail(path, e))
}

fn write(path: &str, s: &str) -> Res<()> {
    std::fs::write(path, s).map_err(|e| io_fail(path, e))
}

/// `$(( a - b ))` on two cfg values.
fn int(s: &str) -> Res<i64> {
    s.trim().parse().map_err(|_| {
        fail(
            2,
            format!("tools/check.sh: arithmetic expression: expecting EOF: \"{s}\""),
        )
    })
}

/// `jq -r KEY court.json`: strings raw, missing as null.
fn court_field(court: &str, key: &str) -> Res<String> {
    let p = format!("{court}/court.json");
    let text = std::fs::read_to_string(&p).map_err(|e| io_fail(&p, e))?;
    let v: serde_json::Value =
        serde_json::from_str(&text).map_err(|e| fail(2, format!("jq: error: {p}: {e}")))?;
    Ok(match v.get(key) {
        Some(serde_json::Value::String(s)) => s.clone(),
        Some(x) => x.to_string(),
        None => "null".into(),
    })
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let (dir, rest) = args.split_first().ok_or_else(|| fail(2, opts::USAGE))?;
    let doc = opts::logical_dir(dir)?;
    let court = opts::resolve_court(&doc)?;
    let o = opts::parse_opts(rest)?;
    let root = crate::repo_root()?.to_string_lossy().into_owned();
    let (_, font_findings) = crate::lint::fonts::check(std::path::Path::new(&root))?;
    if !font_findings.is_empty() {
        font_findings
            .iter()
            .for_each(|finding| eprintln!("{finding}"));
        return Err(fail(
            1,
            "fb check: font audit mismatch; run `fb lint fonts`",
        ));
    }
    let (_, path_findings) = crate::lint::paths::check(std::path::Path::new(&root));
    if !path_findings.is_empty() {
        path_findings
            .iter()
            .for_each(|finding| eprintln!("{finding}"));
        return Err(fail(
            1,
            "fb check: usage/ layout violations; run `fb lint paths`",
        ));
    }
    let mut env: Env = vec![("LC_ALL".into(), "en_US.UTF-8".into())];
    let alias = court_field(&court, "alias")?;
    let out_dir = format!("{root}/out/check/{alias}/{}", opts::doc_key(&doc, &root));
    std::fs::create_dir_all(&out_dir).map_err(|e| io_fail(&out_dir, e))?;
    let tq = match o.engine.as_str() {
        "typst" => ".template".to_string(),
        e => format!(".templates.{e} // \"\""),
    };
    let template = Some(cfg(&env, &court, &tq)?)
        .filter(|t| !t.is_empty())
        .unwrap_or_else(|| o.engine.clone());
    env.push(("TEMPLATE".into(), template.clone()));
    env.push(("ENGINE".into(), o.engine.clone()));
    let mut c = Ctx {
        root,
        doc,
        court,
        engine: o.engine.clone(),
        render: o.render,
        out: out_dir,
        template,
        calib: String::new(),
        ftop: 0,
        ph: 0,
        second: String::new(),
        env,
    };
    c.calib = prepare::calibrate(&c)?;
    c.ph = int(&cfg(&c.env, &c.court, ".params.page_height_pt")?)?;
    c.ftop = c.ph - int(&cfg(&c.env, &c.court, ".params.margin_pt")?)?;
    c.second = cfg(&c.env, &c.court, ".generalization.second_sample")?;
    run(&c, &alias, &o.only)
}

fn run(c: &Ctx, alias: &str, only: &str) -> Res<ExitCode> {
    let f = |n: &str| format!("{}/{n}", c.out);
    write(&f(".tally"), "")?;
    write(&f(".shas"), "")?;
    write(&f(".fails"), "0\n")?;
    write(&f(".fails_sample"), "")?;
    let name = court_field(&c.court, "name")?;
    let h = format!("{:.2}", sh::awk_num(&c.calib) * 14.0);
    out(&format!(
        "formbook check: {alias} ({name})  font calibration: 14 pt = {h} pt word height\n"
    ));
    let mut t = Tally::default();
    let ids = cfg(&c.env, &c.court, ".samples[].id")?;
    for sid in ids
        .split_whitespace()
        .filter(|s| only.is_empty() || *s == only)
    {
        sample(c, sid, &mut t)?;
    }
    out(&format!(
        "\nRESULT: {} checks passed, {} failed\n",
        t.pass, t.fail
    ));
    let stamp = format!("{}/usage/.check-{}.txt", c.doc, c.engine);
    match (t.fail, only.is_empty()) {
        (0, true) => {
            if let Err(e) = std::fs::write(&stamp, stamp::stamp_text(&t.shas)) {
                eprintln!("tools/check.sh: cannot create {stamp}: {e}");
            }
            out(&format!(
                "stamp: usage/.check-{}.txt written for engine {}\n",
                c.engine, c.engine
            ));
        }
        (0, false) => {}
        _ => {
            let _ = std::fs::remove_file(&stamp);
        }
    }
    match t.fail {
        0 => {
            out("All gates green: this court folder is eligible for 'up for review' (tools/tracker.sh). 'done' is set by David, by hand, in court.json.\n");
            Ok(ExitCode::SUCCESS)
        }
        _ => Ok(ExitCode::from(1)),
    }
}

/// The sample's markdown (checks.yaml `md`, usage/INPUT-<id>.md) and the engine's render of it
/// (usage/OUTPUT-<id>.<engine>.pdf, from the layout; checks.yaml `pdf` is not consulted).
fn sample_paths(c: &Ctx, sid: &str) -> Res<(String, String)> {
    let mdrel = cfg(
        &c.env,
        &c.court,
        &format!(".samples[] | select(.id == \"{sid}\") | .md"),
    )?;
    Ok((
        format!("{}/{mdrel}", c.doc),
        format!("{}/{}", c.doc, render_rel(&mdrel, &c.engine)?),
    ))
}

/// usage/OUTPUT-<id>.<engine>.pdf for the input usage/INPUT-<id>.md.
fn render_rel(mdrel: &str, engine: &str) -> Res<String> {
    let file = mdrel.strip_prefix("usage/").unwrap_or_default();
    crate::layout::id_of(crate::layout::INPUT, file)
        .map(|id| crate::layout::Doc::rel(&crate::layout::output_name(id, engine)))
        .ok_or_else(|| {
            fail(
                2,
                format!(
                    "fb check: checks.yaml md {mdrel} is not usage/{}",
                    crate::layout::input_name("<doctype>[-<n>]")
                ),
            )
        })
}

fn sample(c: &Ctx, sid: &str, t: &mut Tally) -> Res<()> {
    let f = |n: &str| format!("{}/{n}", c.out);
    let (md, pdf) = sample_paths(c, sid)?;
    out(&format!("\n=== sample {sid}\n"));
    let w = format!("{}/{sid}", c.out);
    let Some(p) = prepare::prepare(c, sid, &md, &pdf, &w)? else {
        out(&format!("  could not prepare {sid}\n"));
        t.fail += 1;
        return append(&f(".tally"), "F\n");
    };
    let s = Sample {
        sid: sid.to_string(),
        md,
        pdf: pdf.clone(),
        w,
        npages: p.npages,
    };
    let base = pdf.rsplit('/').next().unwrap_or(&pdf);
    out(&format!("    {base}: {} pages\n", s.npages));
    let rel = |p: &str| {
        p.strip_prefix(&format!("{}/", c.doc))
            .unwrap_or(p)
            .to_string()
    };
    let mut lines = vec![format!("{}  {}", stamp::sha256(&pdf), rel(&pdf))];
    if c.engine == "docx" {
        let docx = pdf.strip_suffix(".pdf").unwrap_or(&pdf);
        let l = format!("{}  {docx}", stamp::sha256(docx));
        lines.push(l.replacen(&format!("  {}/", c.doc), "  ", 1));
    }
    let shas: String = lines.iter().map(|l| format!("{l}\n")).collect();
    append(&f(".shas"), &shas)?;
    t.shas.extend(lines);
    let gates = [("0", "CONTENT"), ("1", "RULES"), ("2", "VISUAL REVIEW")];
    for (g, title) in gates {
        out(&format!(" GATE {g} {title}\n"));
        if g == "1" && times_exemplar(c)? {
            let fonts = std::fs::read_to_string(format!("{}/fonts.txt", s.w))
                .map_err(|e| io_fail(&format!("{}/fonts.txt", s.w), e))?;
            let found = fonts.lines().skip(2).any(|line| {
                let name = line.split_whitespace().next().unwrap_or("");
                name.rsplit_once('+').map_or(name, |(_, n)| n) == "TimesNewRomanPSMT"
            });
            if found {
                out("  PASS TNR-EMBEDDED: TimesNewRomanPSMT is embedded\n");
                t.pass += 1;
                append(&f(".tally"), "P\n")?;
            } else {
                out("  FAIL TNR-EMBEDDED: TimesNewRomanPSMT is not embedded\n");
                t.fail += 1;
                t.fails_sample += 1;
                append(&f(".tally"), "F\n")?;
                append(&f(".fails_sample"), "F\n")?;
            }
        }
        run_checks(c, &s, g, t)?;
    }
    t.fails += t.fails_sample;
    t.fails_sample = 0;
    write(&f(".fails"), &format!("{}\n", t.fails))?;
    write(&f(".fails_sample"), "")?;
    if sid == c.second {
        out(" GATE 3 GENERALIZATION\n");
        run_checks(c, &s, "3", t)?;
    }
    Ok(())
}

/// True when a metric-exact Times exemplar is recorded for this document type.
fn times_exemplar(c: &Ctx) -> Res<bool> {
    crate::fonts::has_times_exemplar(std::path::Path::new(&c.root), std::path::Path::new(&c.doc))
}

/// The verdict of one check row: (pass, measured, detail).
fn verdict(c: &Ctx, s: &Sample, r: &rows::Row, fails: u64) -> Res<(bool, String, String)> {
    match r.method.as_str() {
        "generalization_all" => Ok(match fails {
            0 => (true, "no failing check on any sample".into(), String::new()),
            n => (
                false,
                format!("{n} checks failed on the samples"),
                String::new(),
            ),
        }),
        m => {
            let (calib, ftop, ph) = (c.calib.as_str(), c.ftop.to_string(), c.ph.to_string());
            let vars = [
                ("ROOT", c.root.as_str()),
                ("COURT", c.court.as_str()),
                ("DOC", c.doc.as_str()),
                ("OUT", c.out.as_str()),
                ("SID", s.sid.as_str()),
                ("MD", s.md.as_str()),
                ("PDF", s.pdf.as_str()),
                ("W", s.w.as_str()),
                ("NPAGES", s.npages.as_str()),
                ("CALIB", calib),
                ("FTOP", ftop.as_str()),
                ("PH", ph.as_str()),
            ];
            let v = bridge::run(&c.env, &vars, m, &rows::split_args(&r.args))?;
            Ok((v.pass, v.meas, v.detail))
        }
    }
}

fn run_checks(c: &Ctx, s: &Sample, gates: &str, t: &mut Tally) -> Res<()> {
    let tally = format!("{}/.tally", c.out);
    let fs = format!("{}/.fails_sample", c.out);
    for r in rows::load(&c.env, &c.court)?
        .iter()
        .filter(|r| rows::in_gates(gates, &r.gate))
    {
        if !rows::runs_on(&r.engines, &c.engine) {
            out(&rows::skip_text(r, &c.engine));
            continue;
        }
        if r.gate == "3" && s.sid != c.second {
            continue;
        }
        let (pass, meas, detail) = verdict(c, s, r, t.fails)?;
        if pass {
            out(&rows::pass_text(r, &meas));
            t.pass += 1;
            append(&tally, "P\n")?;
            continue;
        }
        let target = format!("{}/{}", c.doc, c.template);
        let line = stamp::anchor_line(&target, &r.anchor);
        out(&rows::fail_text(r, &meas, &c.template, line, &detail));
        t.fail += 1;
        append(&tally, "F\n")?;
        if r.gate != "3" {
            t.fails_sample += 1;
            append(&fs, "F\n")?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::render_rel;

    #[test]
    fn render_paths() {
        let r = |e: &str| render_rel("usage/INPUT-opening-brief-2.md", e).unwrap();
        assert_eq!(r("typst"), "usage/OUTPUT-opening-brief-2.typst.pdf");
        assert_eq!(r("latex"), "usage/OUTPUT-opening-brief-2.latex.pdf");
        assert_eq!(r("docx"), "usage/OUTPUT-opening-brief-2.docx.pdf");
        assert!(render_rel("samples/INPUT-opening-brief.md", "typst").is_err());
    }
}
