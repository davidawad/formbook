//! Font policy migrations backed by the checked-in exemplar-font audit.
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};

fn collect_files(dir: &Path, out: &mut Vec<PathBuf>) -> std::io::Result<()> {
    if !dir.is_dir() {
        return Ok(());
    }
    for ent in fs::read_dir(dir)? {
        let ent = ent?;
        let p = ent.path();
        if p.is_dir() {
            collect_files(&p, out)?;
        } else if matches!(p.extension().and_then(|s| s.to_str()), Some("typ" | "tex")) {
            out.push(p);
        }
    }
    Ok(())
}

fn collect_pdfs(dir: &Path, out: &mut Vec<PathBuf>) -> std::io::Result<()> {
    if !dir.is_dir() {
        return Ok(());
    }
    for ent in fs::read_dir(dir)? {
        let p = ent?.path();
        if p.is_dir() {
            collect_pdfs(&p, out)?;
        } else if p.extension().and_then(|s| s.to_str()) == Some("pdf")
            && p.file_name()
                .and_then(|s| s.to_str())
                .is_some_and(|s| s.starts_with("FILED-EXAMPLE-"))
            && p.parent()
                .and_then(|d| d.file_name())
                .is_some_and(|d| d == crate::layout::USAGE_DIR)
        {
            out.push(p);
        }
    }
    Ok(())
}

fn replace_in_file(path: &Path, content: &str, changed: &mut usize) -> Res<()> {
    let old = fs::read_to_string(path).map_err(|e| fail(2, format!("{}: {e}", path.display())))?;
    if old == content {
        return Ok(());
    }
    fs::write(path, content).map_err(|e| fail(2, format!("{}: {e}", path.display())))?;
    *changed += 1;
    Ok(())
}

fn times_doc_dirs(root: &Path) -> Res<Vec<PathBuf>> {
    let p = root.join("data/exemplar-fonts.json");
    let raw = fs::read_to_string(&p).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let json: Value =
        serde_json::from_str(&raw).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let examples = json
        .get("exemplars")
        .and_then(Value::as_object)
        .ok_or_else(|| fail(2, "font audit has no exemplars map"))?;
    let mut dirs = std::collections::BTreeSet::new();
    for (rel, item) in examples {
        if wants_tnr(item) {
            if let Some(doc) = audit_doc(rel) {
                dirs.insert(root.join(doc));
            }
        }
    }
    Ok(dirs.into_iter().collect())
}

/// True when the audited exemplar calls for Times New Roman in the template (and so for an
/// embedded `TimesNewRomanPSMT`): the face the template declares ([`template_face`]: a recorded ruling, else the
/// audited face) is Times New Roman. Adobe Times maps to `TeX Gyre Termes` and needs no TNR; a ruling that names
/// another face (a court rule over a Times New Roman exemplar) needs none either.
fn wants_tnr(record: &Value) -> bool {
    matches!(
        template_face(record),
        "Times New Roman" | "Times" | "Times-Roman"
    )
}

/// Metric-compatible Times faces the latex engine may embed instead of Times New Roman (fb-595.45): newtxtext
/// and newtxmath (TeXGyreTermesX, NewTX; txsys, its symbols: a minus or an arrow, lib/latex/xdoc.lua) and TeX Gyre
/// Termes, all in stock TeX Live, so the .tex compiles with
/// stock pdflatex. Scoped to latex; typst and docx stay Times New Roman.
pub const LATEX_TIMES: [&str; 4] = ["TeXGyreTermesX", "TeXGyreTermes", "NewTX", "txsys"];

/// The `pdffonts` names (subset tag removed) of `fonts_txt`, its two header lines skipped.
fn pdffonts_names(fonts_txt: &str) -> impl Iterator<Item = &str> {
    fonts_txt.lines().skip(2).map(|line| {
        let name = line.split_whitespace().next().unwrap_or("");
        name.rsplit_once('+').map_or(name, |(_, n)| n)
    })
}

/// The first embedded font that satisfies the Times New Roman requirement of a Times exemplar on `engine`:
/// TimesNewRomanPSMT, or on latex also a metric-compatible Times (LATEX_TIMES).
pub fn times_embedded<'a>(fonts_txt: &'a str, engine: &str) -> Option<&'a str> {
    pdffonts_names(fonts_txt).find(|n| {
        *n == "TimesNewRomanPSMT"
            || (engine == "latex" && LATEX_TIMES.iter().any(|t| n.starts_with(t)))
    })
}

/// The extra pdf_prefix alternatives (`a|b`) the engine accepts for a declared `prefix`: on latex, a template
/// that declares Times New Roman, or Liberation Serif (its metric twin, absent from stock TeX Live), may embed a
/// metric-compatible Times; one that declares Arial or Liberation Sans, TeX Gyre Heros (Helvetica's advances, which
/// are Arial's; tools/fb/src/enginegen/gen.rs latex_face); nothing otherwise.
pub fn latex_alt_prefix(engine: &str, prefix: &str) -> String {
    let times = |p: &str| p == "TimesNewRoman" || p == "LiberationSerif";
    let arial = |p: &str| p == "Arial" || p == "LiberationSans";
    let mut alt: Vec<&str> = vec![];
    if engine == "latex" && prefix.split('|').any(times) {
        alt.extend(LATEX_TIMES);
    }
    if engine == "latex" && prefix.split('|').any(arial) {
        alt.push("TeXGyreHeros");
    }
    alt.join("|")
}

/// The face the template of an audited exemplar declares: the record's `template_face` when one is set (a
/// ruling that overrides the audit, its reason in `note`; the measured `face` stays as audited), else `face`.
pub fn template_face(record: &Value) -> &str {
    let text = |k: &str| {
        record
            .get(k)
            .and_then(Value::as_str)
            .filter(|s| !s.is_empty())
    };
    text("template_face").or_else(|| text("face")).unwrap_or("")
}

/// The doc folder of a font-audit key `<doc>/usage/FILED-EXAMPLE-<id>.pdf`.
pub fn audit_doc(key: &str) -> Option<&str> {
    let (doc, file) = key.rsplit_once(&format!("/{}/", crate::layout::USAGE_DIR))?;
    file.starts_with("FILED-EXAMPLE-").then_some(doc)
}

pub fn has_times_exemplar(root: &Path, doc: &Path) -> Res<bool> {
    let p = root.join("data/exemplar-fonts.json");
    let raw = fs::read_to_string(&p).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let audit: Value =
        serde_json::from_str(&raw).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let examples = audit
        .get("exemplars")
        .and_then(Value::as_object)
        .ok_or_else(|| fail(2, "font audit has no exemplars map"))?;
    let rel = doc.strip_prefix(root).unwrap_or(doc).to_string_lossy();
    Ok(examples
        .iter()
        .any(|(path, record)| audit_doc(path) == Some(&*rel) && wants_tnr(record)))
}

/// Migrate Typst/Latex declarations for audited Times exemplars.
pub fn main(args: &[String]) -> Res<std::process::ExitCode> {
    match args {
        [a] if a == "audit" => return audit(true),
        [a] if a == "audit-additions" => return audit(false),
        [a] if a == "migrate" => {}
        _ => return Err(fail(2, "usage: fb fonts migrate|audit|audit-additions")),
    }
    let root = repo_root()?;
    let docs = times_doc_dirs(&root)?;
    let mut changed = 0;
    for doc in docs {
        for sub in ["typst", "latex"] {
            let mut files = Vec::new();
            collect_files(&doc.join(sub), &mut files)
                .map_err(|e| fail(2, format!("{}: {e}", doc.display())))?;
            for file in files {
                let old = fs::read_to_string(&file)
                    .map_err(|e| fail(2, format!("{}: {e}", file.display())))?;
                let mut new = old.clone();
                if file.extension().and_then(|s| s.to_str()) == Some("typ") {
                    let trailing_newline = new.ends_with('\n');
                    let mut lines = Vec::new();
                    for line in new.lines() {
                        if let Some((head, tail)) = line.split_once("font-family = \"") {
                            if let Some((_, after)) = tail.split_once('"') {
                                lines.push(format!("{head}font-family = (\"Times New Roman\", \"Liberation Serif\"){after}"));
                                continue;
                            }
                        }
                        lines.push(line.to_string());
                    }
                    new = lines.join("\n");
                    if trailing_newline {
                        new.push('\n');
                    }
                    new = new.replace(
                        "font: \"Liberation Serif\"",
                        "font: (\"Times New Roman\", \"Liberation Serif\")",
                    );
                } else if file.file_name().and_then(|s| s.to_str()) == Some("template.tex") {
                    if new.contains("\\IfFontExistsTF{Times New Roman}") {
                        new = new.replace(
                            "\\IfFontExistsTF{Times New Roman}{\\setmainfont{Times New Roman}}{\\setmainfont{Times New Roman}}",
                            "\\IfFontExistsTF{Times New Roman}{\\setmainfont{Times New Roman}}{\\setmainfont{Liberation Serif}}",
                        );
                        replace_in_file(&file, &new, &mut changed)?;
                        continue;
                    }
                    let mut rest = new.as_str();
                    let mut converted = String::new();
                    while let Some(start) = rest.find("\\setmainfont") {
                        converted.push_str(&rest[..start]);
                        rest = &rest[start..];
                        let cmd_len = "\\setmainfont".len();
                        let after_cmd = &rest[cmd_len..];
                        let consumed = if after_cmd.starts_with('[') {
                            after_cmd.find(']').and_then(|end_opts| {
                                let family = &after_cmd[end_opts + 1..];
                                family.strip_prefix('{').and_then(|f| {
                                    f.find('}')
                                        .map(|end_font| cmd_len + end_opts + 2 + end_font + 1)
                                })
                            })
                        } else {
                            after_cmd
                                .strip_prefix('{')
                                .and_then(|f| f.find('}').map(|end_font| cmd_len + end_font + 2))
                        };
                        if let Some(n) = consumed {
                            converted.push_str("\\setmainfont{Times New Roman}");
                            rest = &rest[n..];
                        } else {
                            converted.push_str("\\setmainfont");
                            rest = &rest[cmd_len..];
                        }
                    }
                    converted.push_str(rest);
                    new = converted;
                    new = new.replace(
                        "\\setmainfont{Times New Roman}",
                        "\\IfFontExistsTF{Times New Roman}{\\setmainfont{Times New Roman}}{\\setmainfont{Liberation Serif}}",
                    );
                }
                replace_in_file(&file, &new, &mut changed)?;
            }
        }
    }
    println!(
        "Times template declarations migrated in {changed} files across {} audit directories",
        times_doc_dirs(&root)?.len()
    );
    Ok(std::process::ExitCode::SUCCESS)
}

/// `fb fonts audit` (every FILED-EXAMPLE) or `audit-additions` (only those not in the audit yet): write
/// `data/exemplar-fonts.json`. A ruling recorded on an entry (`template_face`, `note`) is kept.
fn audit(all: bool) -> Res<std::process::ExitCode> {
    let root = repo_root()?;
    let p = root.join("data/exemplar-fonts.json");
    let raw = fs::read_to_string(&p).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let mut audit: Value =
        serde_json::from_str(&raw).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let old = audit
        .get("exemplars")
        .and_then(Value::as_object)
        .cloned()
        .ok_or_else(|| fail(2, "font audit has no exemplars map"))?;
    let mut pdfs = Vec::new();
    collect_pdfs(&root.join("courts"), &mut pdfs).map_err(|e| fail(2, format!("courts: {e}")))?;
    let key = |pdf: &PathBuf| {
        pdf.strip_prefix(&root)
            .unwrap_or(pdf)
            .to_string_lossy()
            .replace('\\', "/")
    };
    let todo: Vec<PathBuf> = pdfs
        .iter()
        .filter(|pdf| all || !old.contains_key(&key(pdf)))
        .cloned()
        .collect();
    let threads = std::thread::available_parallelism().map_or(4, |n| n.get());
    let chunks: Vec<Vec<PathBuf>> = todo
        .chunks(todo.len().div_ceil(threads).max(1))
        .map(<[PathBuf]>::to_vec)
        .collect();
    let mut fresh = std::collections::HashMap::new();
    let results: Vec<Res<Vec<(PathBuf, Value)>>> = std::thread::scope(|s| {
        let hs: Vec<_> = chunks
            .iter()
            .map(|c| {
                s.spawn(move || {
                    c.iter()
                        .map(|pdf| Ok((pdf.clone(), crate::fontaudit::audit_record(pdf)?)))
                        .collect()
                })
            })
            .collect();
        hs.into_iter()
            .map(|h| h.join().expect("audit thread"))
            .collect()
    });
    for r in results {
        for (pdf, rec) in r? {
            fresh.insert(key(&pdf), rec);
        }
    }
    let mut keys: Vec<String> = pdfs.iter().map(key).collect();
    keys.sort();
    let mut map = serde_json::Map::new();
    for k in keys {
        let rec = match (fresh.remove(&k), old.get(&k)) {
            (Some(mut rec), Some(prev)) => {
                for ruling in ["template_face", "note"] {
                    if let Some(v) = prev.get(ruling) {
                        rec[ruling] = v.clone();
                    }
                }
                rec
            }
            (Some(rec), None) => rec,
            (None, Some(prev)) => prev.clone(),
            (None, None) => continue,
        };
        map.insert(k, rec);
    }
    audit["generated_by"] = "fb fonts audit (tools/fb/src/fontaudit.rs)".into();
    audit["exemplars"] = Value::Object(map);
    let mut text = serde_json::to_string_pretty(&audit)
        .map_err(|e| fail(2, format!("serialize audit: {e}")))?;
    text.push('\n');
    fs::write(&p, text).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    println!(
        "audited {} FILED-EXAMPLE PDFs with pdffonts, pdftohtml and pdfimages",
        todo.len()
    );
    Ok(std::process::ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    const HEAD: &str = "name type\n---- ----\n";

    #[test]
    fn metric_times_counts_only_on_latex() {
        let f = format!("{HEAD}ABCDEF+TeXGyreTermesX-Regular Type 1 Custom yes yes yes 49 0\n");
        assert_eq!(times_embedded(&f, "latex"), Some("TeXGyreTermesX-Regular"));
        assert_eq!(times_embedded(&f, "typst"), None);
        assert_eq!(times_embedded(&f, "docx"), None);
        let t = format!("{HEAD}XYZ+TimesNewRomanPSMT TrueType WinAnsi yes yes yes 9 0\n");
        assert_eq!(times_embedded(&t, "typst"), Some("TimesNewRomanPSMT"));
        let cm = format!("{HEAD}XYZ+LMRoman12-Regular Type 1 Custom yes yes yes 9 0\n");
        assert_eq!(times_embedded(&cm, "latex"), None);
    }

    #[test]
    fn latex_alternatives_only_for_a_declared_times() {
        assert_eq!(
            latex_alt_prefix("latex", "TimesNewRoman"),
            "TeXGyreTermesX|TeXGyreTermes|NewTX|txsys"
        );
        assert_eq!(
            latex_alt_prefix("latex", "TimesNewRoman|LiberationSerif"),
            "TeXGyreTermesX|TeXGyreTermes|NewTX|txsys"
        );
        assert_eq!(
            latex_alt_prefix("latex", "LiberationSerif"),
            "TeXGyreTermesX|TeXGyreTermes|NewTX|txsys"
        );
        assert_eq!(latex_alt_prefix("typst", "TimesNewRoman"), "");
        assert_eq!(latex_alt_prefix("latex", "EBGaramond"), "");
        assert_eq!(latex_alt_prefix("latex", "LiberationSans"), "TeXGyreHeros");
        assert_eq!(latex_alt_prefix("docx", "LiberationSans"), "");
    }

    #[test]
    fn audit_keys() {
        assert_eq!(
            audit_doc("courts/x/opening-brief/usage/FILED-EXAMPLE-opening-brief-2.pdf"),
            Some("courts/x/opening-brief")
        );
        assert_eq!(audit_doc("courts/x/usage/SAMPLE-ca9-a1.pdf"), None);
        assert_eq!(audit_doc("courts/x/usage/OUTPUT-complaint.typst.pdf"), None);
    }

    #[test]
    fn adobe_times_mapped_to_termes_does_not_want_tnr() {
        let j = |s: &str| serde_json::from_str::<Value>(s).unwrap();
        assert!(wants_tnr(&j(
            r#"{"body":"timesnewroman","face":"Times New Roman"}"#
        )));
        assert!(wants_tnr(&j(r#"{"body":"times","face":"Times"}"#)));
        assert!(!wants_tnr(&j(
            r#"{"body":"times","face":"TeX Gyre Termes"}"#
        )));
        assert!(!wants_tnr(&j(r#"{"body":"garamond","face":""}"#)));
        let ruled = j(r#"{"body":"georgia","face":"Gelasio","template_face":"Times New Roman"}"#);
        assert!(wants_tnr(&ruled));
        assert_eq!(template_face(&ruled), "Times New Roman");
        assert_eq!(
            template_face(&j(r#"{"body":"georgia","face":"Gelasio"}"#)),
            "Gelasio"
        );
        // a rule that names another face overrides a Times New Roman exemplar
        assert!(!wants_tnr(&j(
            r#"{"body":"timesnewroman","face":"Times New Roman","template_face":"Liberation Sans"}"#
        )));
    }
}
