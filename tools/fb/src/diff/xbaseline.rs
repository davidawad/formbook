//! `fb cross-engine [--write] [--no-convert] [dir-substring]`: the cross-engine baseline (fb-595.54).
//! For every doc folder under courts/ and every INPUT id with a typst render and at least one other
//! engine's render, compare OUTPUT-<id>.typst.pdf (reference) with .latex.pdf and .docx.pdf (xengine.rs)
//! and print one row per pair: folder | engine | pages equal | % lines same break | first differing
//! page/line. A .docx whose LibreOffice PDF is not committed is converted into out/cross-engine/ first
//! (`--no-convert`: listed as not measured instead). `--write` stores the rows in
//! data/cross-engine-baseline.json. Each row also says whether its folder gates the check
//! (`params.cross_engine: gate`) or only reports it. Nothing is silently skipped: a pair that cannot be
//! measured is a row that says why.
use super::xengine::{self, Cross};
use crate::layout::{self, Doc};
use crate::measure;
use crate::{fail, repo_root, Res};
use serde::Serialize;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

const USAGE: &str = "usage: fb cross-engine [--write] [--no-convert] [dir-substring]";
pub const BASELINE: &str = "data/cross-engine-baseline.json";

#[derive(Serialize, Clone, Debug)]
pub struct Row {
    pub folder: String,
    pub id: String,
    pub engine: String,
    /// "gate" or "report" (the folder's `params.cross_engine`).
    pub mode: String,
    /// Page counts typst / this engine; None when the pair could not be measured.
    pub pages: Option<(usize, usize)>,
    pub pages_equal: bool,
    pub page_ends_differ: usize,
    pub lines: usize,
    pub lines_same: usize,
    pub pct_same: f64,
    pub first_differing: String,
    /// Largest width difference of a line both engines break alike (glyph-advance drift).
    pub width_drift_pt: f64,
    /// Where the other engine's PDF came from: "committed", "converted" (from the committed .docx), or why
    /// it was not measured.
    pub source: String,
}

impl Row {
    pub fn pass(&self) -> bool {
        self.pages.is_some()
            && self.pages_equal
            && self.page_ends_differ == 0
            && self.lines_same == self.lines
    }
}

/// Doc folders under `dir` that hold a usage/ folder, sorted.
fn doc_dirs(dir: &Path, out: &mut Vec<PathBuf>) {
    let mut v: Vec<PathBuf> = std::fs::read_dir(dir)
        .map(|rd| {
            rd.filter_map(Result::ok)
                .map(|e| e.path())
                .filter(|p| p.is_dir())
                .collect()
        })
        .unwrap_or_default();
    v.sort();
    for p in v {
        if p.file_name().is_some_and(|n| n == layout::USAGE_DIR) {
            out.push(dir.to_path_buf());
        } else {
            doc_dirs(&p, out);
        }
    }
}

fn yaml_mode(p: &Path, key: &str) -> Option<String> {
    let v: serde_yaml::Value = serde_yaml::from_str(&std::fs::read_to_string(p).ok()?).ok()?;
    v["params"][key].as_str().map(str::to_string)
}

/// The folder's cross-engine mode as `fb check` reads it: its own checks.yaml, else data/checks-default.yaml
/// with the court's and then the folder's eval.yaml merged over it; `params.cross_engine_<engine>` over
/// `params.cross_engine`.
pub fn mode(root: &Path, doc: &Path, engine: &str) -> String {
    let own = doc.join("checks.yaml");
    let files: Vec<PathBuf> = match own.is_file() {
        true => vec![own],
        false => {
            let mut v = vec![root.join("data/checks-default.yaml")];
            v.extend(layout::court_dir(doc).map(|c| c.join("eval.yaml")));
            v.push(doc.join("eval.yaml"));
            v
        }
    };
    let last = |key: &str| files.iter().filter_map(|f| yaml_mode(f, key)).last();
    last(&format!("cross_engine_{engine}"))
        .or_else(|| last("cross_engine"))
        .unwrap_or_else(|| "report".into())
}

struct Job {
    folder: String,
    id: String,
    engine: &'static str,
    mode: String,
    typst: PathBuf,
    other: PathBuf,
    /// The .docx to convert when `other` is missing.
    docx: Option<PathBuf>,
}

fn row(j: &Job, c: Option<&Cross>, source: &str) -> Row {
    let d = Cross::default();
    let c0 = c.unwrap_or(&d);
    Row {
        folder: j.folder.clone(),
        id: j.id.clone(),
        engine: j.engine.into(),
        mode: j.mode.clone(),
        pages: c.map(|c| c.pages),
        pages_equal: c.is_some_and(Cross::pages_equal),
        page_ends_differ: c0.ends_bad,
        lines: c0.lines,
        lines_same: c0.same,
        pct_same: (c0.pct() * 10.0).round() / 10.0,
        first_differing: c.map_or("-".into(), Cross::first_text),
        width_drift_pt: (c0.width_drift() * 100.0).round() / 100.0,
        source: source.into(),
    }
}

fn run(j: &Job, root: &Path, convert: bool) -> Row {
    let mut other = j.other.clone();
    let mut source = "committed";
    if !other.is_file() {
        let Some(docx) = j.docx.as_ref().filter(|_| convert) else {
            return row(j, None, "not measured: OUTPUT .docx.pdf is not committed");
        };
        other = root
            .join("out/cross-engine")
            .join(&j.folder)
            .join(layout::output_name(&j.id, "docx"));
        let _ = std::fs::create_dir_all(other.parent().unwrap_or(root));
        // LibreOffice now and then exits without a PDF when several run at once: one retry
        let convert = || {
            crate::proc::TempDir::new("xengine")
                .and_then(|w| crate::engines::convert(docx, &other, w.path()))
        };
        let made = convert().or_else(|_| convert());
        if let Err(e) = made {
            return row(
                j,
                None,
                &format!("not measured: LibreOffice conversion failed: {}", e.msg),
            );
        }
        source = "converted";
    }
    match (measure::load(&j.typst), measure::load(&other)) {
        (Ok(a), Ok(b)) => row(j, Some(&xengine::compare(&a, &b)), source),
        (Err(e), _) | (_, Err(e)) => row(j, None, &format!("not measured: {}", e.msg)),
    }
}

fn jobs(root: &Path, filter: &str) -> Res<Vec<Job>> {
    let mut dirs = Vec::new();
    doc_dirs(&root.join("courts"), &mut dirs);
    let mut v = Vec::new();
    for dir in dirs {
        let folder = dir
            .strip_prefix(root)
            .unwrap_or(&dir)
            .to_string_lossy()
            .into_owned();
        if !folder.contains(filter) || layout::court_dir(&dir).is_none() {
            continue;
        }
        let doc = Doc::open(&dir)?;
        for id in doc.ids(layout::INPUT) {
            let typst = doc.output(&id, "typst");
            for engine in ["latex", "docx"] {
                let other = doc.output(&id, engine);
                let docx = (engine == "docx")
                    .then(|| doc.usage().join(layout::output_docx_name(&id)))
                    .filter(|d| d.is_file());
                if !other.is_file() && docx.is_none() {
                    continue;
                }
                v.push(Job {
                    folder: folder.clone(),
                    id: id.clone(),
                    engine,
                    mode: mode(root, &dir, engine),
                    typst: typst.clone(),
                    other,
                    docx,
                });
            }
        }
    }
    Ok(v)
}

/// The rows, measured on `threads` workers, in job order.
fn measure_all(jobs: &[Job], root: &Path, convert: bool) -> Vec<Row> {
    let threads = std::thread::available_parallelism()
        .map_or(4, |n| n.get())
        .min(8);
    let next = std::sync::atomic::AtomicUsize::new(0);
    let out = std::sync::Mutex::new(vec![None; jobs.len()]);
    std::thread::scope(|s| {
        for _ in 0..threads {
            s.spawn(|| loop {
                let k = next.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                let Some(j) = jobs.get(k) else { break };
                let r = match j.typst.is_file() {
                    true => run(j, root, convert),
                    false => row(
                        j,
                        None,
                        "not measured: OUTPUT .typst.pdf (the reference) is missing",
                    ),
                };
                eprintln!("{} {} {}", r.folder, r.id, r.engine);
                out.lock().unwrap()[k] = Some(r);
            });
        }
    });
    out.into_inner().unwrap().into_iter().flatten().collect()
}

/// The markdown table of docs/EVAL-LOOP.md.
pub fn table(rows: &[Row]) -> String {
    let mut s = String::from("| folder | id | engine | mode | pages equal | % lines same break | first differing page/line |\n|---|---|---|---|---|---|---|\n");
    for r in rows {
        let (pages, pct) = match r.pages {
            None => (r.source.clone(), "-".to_string()),
            Some((a, b)) if a == b => (format!("yes ({a})"), format!("{:.1}", r.pct_same)),
            Some((a, b)) => (format!("no ({a} vs {b})"), format!("{:.1}", r.pct_same)),
        };
        s.push_str(&format!(
            "| {} | {} | {} | {} | {pages} | {pct} | {} |\n",
            r.folder, r.id, r.engine, r.mode, r.first_differing
        ));
    }
    s
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let (mut write, mut convert, mut filter) = (false, true, String::new());
    for a in args {
        match a.as_str() {
            "--write" => write = true,
            "--no-convert" => convert = false,
            s if !s.starts_with('-') && filter.is_empty() => filter = s.into(),
            _ => return Err(fail(2, USAGE)),
        }
    }
    let root = repo_root()?;
    let jobs = jobs(&root, &filter)?;
    let rows = measure_all(&jobs, &root, convert);
    print!("{}", table(&rows));
    let pass = rows.iter().filter(|r| r.pass()).count();
    println!(
        "\nRESULT: {pass}/{} engine pairs break every line like typst",
        rows.len()
    );
    if write {
        let doc = serde_json::json!({
            "about": "fb-595.54 cross-engine baseline: typst render (reference) vs latex and docx renders of the same INPUT; regenerate with `fb cross-engine --write` (docs/EVAL-LOOP.md, Cross-engine gate)",
            "pairs": rows.len(),
            "pairs_pass": pass,
            "rows": rows,
        });
        let text = serde_json::to_string_pretty(&doc).map_err(|e| fail(2, format!("fb: {e}")))?;
        let p = root.join(BASELINE);
        std::fs::write(&p, text + "\n")
            .map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
        println!("wrote {BASELINE}");
    }
    Ok(ExitCode::SUCCESS)
}
