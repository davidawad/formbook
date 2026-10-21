//! DEF-DOCX-OPEN: a delivered .docx opens. Run by `fb check --engine docx` on every sample, by `fb lint docx` on
//! every committed usage/OUTPUT-*.docx, and (the package checks alone) by `fb render --engine docx` before it
//! writes one.
//!
//! The package checks, in order: the zip is valid (`unzip -t`); every XML part is well-formed; `[Content_Types].xml`
//! gives every part a content type and names no missing part; every internal relationship target is in the package;
//! and every relationship id a part uses (`r:id`, `r:embed`, any attribute in the relationships namespace) is
//! declared in that part's .rels. A dangling id is what Word answers with a repair prompt and LibreOffice with
//! "source file could not be loaded" (fb-595.64: a sectPr naming `rIdFooter1` after pandoc renumbered it `rId9`).
//! Then LibreOffice must convert it headless: `soffice` exits 0 even when it cannot load a file, so the test is the
//! PDF it writes.
use crate::proc::{capture, which};
use crate::{fail, Res};
use quick_xml::events::Event;
use quick_xml::Reader;
use std::collections::{BTreeMap, BTreeSet};
use std::path::{Path, PathBuf};
use std::process::Command;

pub const ID: &str = "DEF-DOCX-OPEN";
pub const NAME: &str =
    "the .docx opens: a valid zip, well-formed XML, every relationship resolves, LibreOffice converts it headless";

const REL_NS: &str = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
/// LibreOffice conversions per soffice start (one start costs seconds; lint converts hundreds of files).
const BATCH: usize = 40;

/// One start tag: its qualified name and attributes (unescaped values).
struct Elem {
    name: String,
    attrs: Vec<(String, String)>,
}

fn local(name: &str) -> &str {
    name.rsplit(':').next().unwrap_or(name)
}

impl Elem {
    fn attr(&self, key: &str) -> Option<&str> {
        self.attrs
            .iter()
            .find(|(k, _)| k == key)
            .map(|(_, v)| v.as_str())
    }
}

/// Every start tag of a well-formed XML document, or why it is not well-formed.
fn parse(bytes: &[u8]) -> Result<Vec<Elem>, String> {
    let mut r = Reader::from_reader(bytes);
    let mut buf = Vec::new();
    let (mut depth, mut roots, mut out) = (0usize, 0usize, Vec::new());
    loop {
        let pos = r.buffer_position();
        let ev = r
            .read_event_into(&mut buf)
            .map_err(|e| format!("at byte {pos}: {e}"))?;
        match ev {
            Event::Start(ref e) | Event::Empty(ref e) => {
                if depth == 0 {
                    roots += 1;
                }
                let name = String::from_utf8_lossy(e.name().as_ref()).into_owned();
                let mut attrs = Vec::new();
                for a in e.attributes() {
                    let a = a.map_err(|e| format!("at byte {pos}: <{name}>: {e}"))?;
                    let v = a
                        .unescape_value()
                        .map_err(|e| format!("at byte {pos}: <{name}>: {e}"))?;
                    attrs.push((
                        String::from_utf8_lossy(a.key.as_ref()).into_owned(),
                        v.into_owned(),
                    ));
                }
                if matches!(ev, Event::Start(_)) {
                    depth += 1;
                }
                out.push(Elem { name, attrs });
            }
            Event::End(_) => depth = depth.saturating_sub(1),
            Event::Text(t) => {
                t.unescape().map_err(|e| format!("at byte {pos}: {e}"))?;
            }
            Event::Eof => break,
            _ => {}
        }
        buf.clear();
    }
    match (depth, roots) {
        (0, 1) => Ok(out),
        (0, n) => Err(format!("{n} root elements")),
        (d, _) => Err(format!("{d} elements not closed at the end")),
    }
}

/// The part a .rels file describes ("" for the package's own _rels/.rels).
fn rels_source(rels: &str) -> Option<String> {
    let (dir, file) = rels.rsplit_once("_rels/")?;
    Some(format!("{dir}{}", file.strip_suffix(".rels")?))
}

/// `target` of a relationship of `source`, as a part name (no leading slash, `..` resolved).
fn resolve(source: &str, target: &str) -> String {
    let mut parts: Vec<&str> = match target.strip_prefix('/') {
        Some(_) => vec![],
        None => source
            .rsplit_once('/')
            .map_or(vec![], |(d, _)| d.split('/').collect()),
    };
    for seg in target.trim_start_matches('/').split('/') {
        match seg {
            "" | "." => {}
            ".." => {
                parts.pop();
            }
            s => parts.push(s),
        }
    }
    parts.join("/")
}

/// The problems of the package `parts` (part name -> bytes); empty when it is sound.
pub fn package_problems(parts: &BTreeMap<String, Vec<u8>>) -> Vec<String> {
    let mut found = Vec::new();
    let mut xml = BTreeMap::new();
    for (name, bytes) in parts {
        let is_xml = name.ends_with(".xml") || name.ends_with(".rels");
        if !is_xml {
            continue;
        }
        match parse(bytes) {
            Ok(e) => {
                xml.insert(name.as_str(), e);
            }
            Err(e) => found.push(format!("{name} is not well-formed XML: {e}")),
        }
    }
    match xml.get("[Content_Types].xml") {
        None if !parts.contains_key("[Content_Types].xml") => {
            found.push("no [Content_Types].xml".into())
        }
        None => {}
        Some(types) => {
            let mut defaults = BTreeSet::new();
            let mut overrides = BTreeSet::new();
            for e in types {
                match (local(&e.name), e.attr("Extension"), e.attr("PartName")) {
                    ("Default", Some(x), _) => {
                        defaults.insert(x.to_ascii_lowercase());
                    }
                    ("Override", _, Some(p)) => {
                        let p = p.trim_start_matches('/').to_string();
                        if !parts.contains_key(&p) {
                            found.push(format!(
                                "[Content_Types].xml names /{p}, which is not in the package"
                            ));
                        }
                        if !overrides.insert(p.clone()) {
                            found.push(format!("[Content_Types].xml overrides /{p} twice"));
                        }
                    }
                    _ => {}
                }
            }
            for name in parts.keys().filter(|n| *n != "[Content_Types].xml") {
                let ext = name.rsplit_once('.').map(|(_, x)| x.to_ascii_lowercase());
                if !overrides.contains(name) && !ext.is_some_and(|x| defaults.contains(&x)) {
                    found.push(format!("{name} has no content type"));
                }
            }
        }
    }
    if !parts.contains_key("_rels/.rels") {
        found.push("no _rels/.rels".into());
    }
    for (rels, elems) in xml.iter().filter(|(n, _)| n.ends_with(".rels")) {
        let Some(source) = rels_source(rels) else {
            continue;
        };
        let mut ids = BTreeSet::new();
        for e in elems.iter().filter(|e| local(&e.name) == "Relationship") {
            let id = e.attr("Id").unwrap_or_default();
            if !ids.insert(id.to_string()) {
                found.push(format!("{rels}: relationship id {id} is declared twice"));
            }
            let external = e.attr("TargetMode") == Some("External");
            let target = e.attr("Target").unwrap_or_default();
            if !external && !parts.contains_key(&resolve(&source, target)) {
                found.push(format!(
                    "{rels}: {id} targets {target}, which is not in the package"
                ));
            }
        }
        if let Some(src) = xml.get(source.as_str()) {
            found.extend(dangling(&source, src, &ids, rels));
        }
    }
    // a part that uses relationship ids but has no .rels at all
    for (name, elems) in &xml {
        let rels = match name.rsplit_once('/') {
            Some((d, f)) => format!("{d}/_rels/{f}.rels"),
            None => format!("_rels/{name}.rels"),
        };
        if !name.ends_with(".rels") && !parts.contains_key(&rels) {
            found.extend(dangling(name, elems, &BTreeSet::new(), &rels));
        }
    }
    found
}

/// The relationship ids `part` uses that `ids` (its .rels) does not declare.
fn dangling(part: &str, elems: &[Elem], ids: &BTreeSet<String>, rels: &str) -> Vec<String> {
    let prefixes: BTreeSet<&str> = elems
        .iter()
        .flat_map(|e| e.attrs.iter())
        .filter(|(k, v)| v == REL_NS && k.starts_with("xmlns:"))
        .map(|(k, _)| &k["xmlns:".len()..])
        .collect();
    let mut out = Vec::new();
    let mut seen = BTreeSet::new();
    for e in elems {
        for (k, v) in &e.attrs {
            let rel_attr = k
                .split_once(':')
                .is_some_and(|(p, _)| p != "xmlns" && prefixes.contains(p));
            if rel_attr && !ids.contains(v) && seen.insert(v.clone()) {
                out.push(format!(
                    "{part}: <{} {k}=\"{v}\"> names a relationship {rels} does not declare",
                    e.name
                ));
            }
        }
    }
    out
}

/// The parts of `docx` (unzip into `work`), or why it is not a zip.
fn read_parts(docx: &Path, work: &Path) -> Res<Result<BTreeMap<String, Vec<u8>>, String>> {
    let t = capture(Command::new("unzip").arg("-tq").arg(docx))?;
    if !t.status.success() {
        let why = String::from_utf8_lossy(&t.stdout);
        let line = why.lines().find(|l| !l.trim().is_empty()).unwrap_or("");
        return Ok(Err(format!("not a valid zip archive: {}", line.trim())));
    }
    let x = work.join("parts");
    let _ = std::fs::remove_dir_all(&x);
    let o = capture(Command::new("unzip").arg("-q").arg(docx).arg("-d").arg(&x))?;
    if !o.status.success() {
        return Ok(Err("unzip cannot extract it".into()));
    }
    let mut parts = BTreeMap::new();
    let mut stack = vec![x.clone()];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                stack.push(p);
            } else if let Ok(rel) = p.strip_prefix(&x) {
                let bytes =
                    std::fs::read(&p).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
                parts.insert(rel.to_string_lossy().replace('\\', "/"), bytes);
            }
        }
    }
    Ok(Ok(parts))
}

/// The package problems of `docx` (`work`: scratch space).
pub fn package(docx: &Path, work: &Path) -> Res<Vec<String>> {
    Ok(match read_parts(docx, work)? {
        Err(e) => vec![e],
        Ok(parts) => package_problems(&parts),
    })
}

/// Which of `docxs` LibreOffice converts to a PDF headless (`work`: scratch space).
pub fn converts(docxs: &[PathBuf], work: &Path) -> Res<Vec<bool>> {
    let soffice = std::env::var_os("SOFFICE")
        .map(PathBuf::from)
        .or_else(|| which("soffice"))
        .ok_or_else(|| {
            fail(
                2,
                format!("{ID}: soffice (LibreOffice) not found; set SOFFICE"),
            )
        })?;
    let mut ok = Vec::with_capacity(docxs.len());
    for (n, chunk) in docxs.chunks(BATCH).enumerate() {
        let dir = work.join(format!("convert{n}"));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).map_err(|e| fail(2, format!("{}: {e}", dir.display())))?;
        // copies with distinct names: many folders deliver an OUTPUT-opening-brief.docx
        let mut names = Vec::new();
        for (i, d) in chunk.iter().enumerate() {
            let to = dir.join(format!("{i}.docx"));
            std::fs::copy(d, &to).map_err(|e| fail(2, format!("{}: {e}", d.display())))?;
            names.push(to);
        }
        capture(
            Command::new(&soffice)
                .arg(format!(
                    "-env:UserInstallation=file://{}/profile",
                    work.display()
                ))
                .args(["--headless", "--convert-to", "pdf", "--outdir"])
                .arg(&dir)
                .args(&names),
        )?;
        ok.extend(
            (0..chunk.len()).map(|i| {
                std::fs::metadata(dir.join(format!("{i}.pdf"))).is_ok_and(|m| m.len() > 0)
            }),
        );
        let _ = std::fs::remove_dir_all(&dir);
    }
    Ok(ok)
}

/// Every problem of `docx`, package and conversion (`work`: scratch space).
pub fn check(docx: &Path, work: &Path) -> Res<Vec<String>> {
    let mut found = package(docx, work)?;
    if !converts(&[docx.to_path_buf()], work)?[0] {
        found.push(
            "LibreOffice cannot load it (soffice --headless --convert-to pdf wrote no PDF)".into(),
        );
    }
    Ok(found)
}

#[cfg(test)]
#[path = "docxopen_tests.rs"]
mod tests;
