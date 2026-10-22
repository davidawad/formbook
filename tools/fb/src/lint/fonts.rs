//! Check that each audited document template declares its audited exemplar face.
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

fn family(face: &str) -> Option<&'static str> {
    match face.trim() {
        "Times New Roman" | "Times" | "Times-Roman" => Some("times"),
        "TeX Gyre Schola" => Some("schola"),
        "TeX Gyre Bonum" => Some("bonum"),
        "TeX Gyre Pagella" => Some("pagella"),
        "TeX Gyre Termes" => Some("termes"),
        "TeX Gyre Cursor" => Some("cursor"),
        "Liberation Serif" => Some("liberation-serif"),
        "Liberation Sans" => Some("liberation-sans"),
        "Liberation Mono" => Some("liberation-mono"),
        "Gelasio" => Some("gelasio"),
        "Caladea" => Some("caladea"),
        "Carlito" => Some("carlito"),
        "TeX Gyre Heros" => Some("heros"),
        "EB Garamond" => Some("eb-garamond"),
        _ => None,
    }
}

fn family_markers(f: &str) -> &'static [&'static str] {
    match f {
        "times" => &["Times New Roman", "Liberation Serif"],
        "schola" => &[
            "TeX Gyre Schola",
            "tex-gyre-schola",
            "\\usepackage{tgschola}",
        ],
        "bonum" => &["TeX Gyre Bonum", "tex-gyre-bonum"],
        "pagella" => &["TeX Gyre Pagella", "tex-gyre-pagella"],
        "termes" => &["TeX Gyre Termes", "tex-gyre-termes"],
        "cursor" => &["TeX Gyre Cursor", "tex-gyre-cursor"],
        "liberation-serif" => &["Liberation Serif", "liberation-serif"],
        "liberation-sans" => &["Liberation Sans", "liberation-sans"],
        "liberation-mono" => &["Liberation Mono", "liberation-mono"],
        "gelasio" => &["Gelasio", "gelasio"],
        "caladea" => &["Caladea", "caladea"],
        "carlito" => &["Carlito", "carlito"],
        "heros" => &["TeX Gyre Heros", "tex-gyre-heros"],
        "eb-garamond" => &["EB Garamond", "eb-garamond"],
        _ => &[],
    }
}

fn declaration(path: &Path, text: &str, family: &str) -> bool {
    let ext = path.extension().and_then(|s| s.to_str()).unwrap_or("");
    if ext == "typ" {
        // A template may bind font-family to font-name, so include both declaration lines.
        let lines = text.lines().filter(|line| {
            line.trim_start().starts_with("#let font-family")
                || line.trim_start().starts_with("#let font-name")
                || line.trim_start().starts_with("#let body-font")
                || line.trim_start().starts_with("#let typeface")
                || line.trim_start().starts_with("#let face ")
                || line.trim_start().starts_with("#let serif ")
                || line.contains("set text(font:")
        });
        let declaration = lines
            .map(|line| line.split_once("//").map_or(line, |(code, _)| code))
            .collect::<Vec<_>>()
            .join("\n");
        if family == "times" {
            return declaration.contains("Times New Roman")
                && declaration.contains("Liberation Serif");
        }
        return family_markers(family)
            .iter()
            .any(|marker| declaration.contains(marker));
    }
    if family == "times" {
        // stock pdflatex (fb-595.45): newtxtext, a metric-compatible Times in every TeX Live
        return text.contains("\\usepackage{newtxtext")
            || (text.contains("Times New Roman")
                && text.contains("Liberation Serif")
                && text.contains("IfFontExistsTF"));
    }
    family_markers(family)
        .iter()
        .any(|marker| text.contains(marker))
}

fn collect_typst(dir: &Path, out: &mut Vec<PathBuf>) -> std::io::Result<()> {
    if !dir.is_dir() {
        return Ok(());
    }
    for ent in fs::read_dir(dir)? {
        let p = ent?.path();
        if p.is_dir() {
            collect_typst(&p, out)?;
        } else if p.extension().and_then(|s| s.to_str()) == Some("typ")
            && p.file_name().and_then(|s| s.to_str()) != Some("main.typ")
        {
            out.push(p);
        }
    }
    Ok(())
}

pub(crate) fn template_files(doc_dir: &Path) -> std::io::Result<Vec<PathBuf>> {
    let typst = doc_dir.join("typst");
    let main = typst.join("main.typ");
    let mut files = Vec::new();
    if main.is_file() {
        let text = fs::read_to_string(&main)?;
        for line in text.lines() {
            if !line.trim_start().starts_with("#import") {
                continue;
            }
            for (_, rest) in line.match_indices('"') {
                if let Some((name, _)) = rest.split_once('"') {
                    if name.ends_with(".typ") && !name.starts_with('@') {
                        let path = typst.join(name);
                        if path.is_file() {
                            files.push(path);
                        }
                    }
                }
            }
        }
    }
    if files.is_empty() {
        collect_typst(&typst, &mut files)?;
    }
    files.sort();
    files.dedup();
    Ok(files)
}

fn audit(root: &Path) -> Res<Vec<(PathBuf, String)>> {
    let p = root.join("data/exemplar-fonts.json");
    let raw = fs::read_to_string(&p).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let json: Value =
        serde_json::from_str(&raw).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let entries = json
        .get("exemplars")
        .and_then(Value::as_object)
        .ok_or_else(|| fail(2, "font audit has no exemplars map"))?;
    let mut docs = BTreeMap::<String, Vec<String>>::new();
    for (path, record) in entries {
        let Some(doc) = crate::fonts::audit_doc(path) else {
            continue;
        };
        let face = crate::fonts::template_face(record);
        if !face.is_empty() {
            docs.entry(doc.to_string())
                .or_default()
                .push(face.to_string());
        }
    }
    let mut results = Vec::new();
    for (doc, faces) in docs {
        let canonical: Vec<_> = faces.iter().filter_map(|face| family(face)).collect();
        let Some(expected) = canonical.first() else {
            continue;
        };
        // Mixed audit faces have no single template target; leave them for an explicit audit decision.
        if canonical.iter().any(|f| f != expected) {
            continue;
        }
        let doc_dir = root.join(&doc);
        let mut files =
            template_files(&doc_dir).map_err(|e| fail(2, format!("{}: {e}", doc_dir.display())))?;
        let tex = doc_dir.join("latex/template.tex");
        if tex.is_file() {
            files.push(tex);
        }
        for file in files {
            results.push((file, (*expected).to_string()));
        }
    }
    Ok(results)
}

pub fn check(root: &Path) -> Res<(usize, Vec<String>)> {
    let entries = audit(root)?;
    let mut findings = Vec::new();
    for (file, expected) in &entries {
        let text =
            fs::read_to_string(file).map_err(|e| fail(2, format!("{}: {e}", file.display())))?;
        if !declaration(file, &text, expected) {
            let rel = file.strip_prefix(root).unwrap_or(file);
            findings.push(format!(
                "LINT font {}: declared body face does not match audited exemplar ({expected})",
                rel.display()
            ));
        }
    }
    Ok((entries.len(), findings))
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let docx_strict = match args {
        [] => false,
        [a] if a == "--docx-strict" => true,
        _ => return Err(fail(2, "usage: fb lint fonts [--docx-strict]")),
    };
    let root = repo_root()?;
    let (checked, findings) = check(&root)?;
    for finding in &findings {
        println!("{finding}");
    }
    let docx_ok = docx_report(&root, docx_strict);
    if findings.is_empty() && docx_ok {
        println!("RESULT: LINT FONTS PASS ({checked} templates)");
        Ok(ExitCode::SUCCESS)
    } else {
        println!("RESULT: LINT FONTS FAIL ({} findings)", findings.len());
        Ok(ExitCode::from(1))
    }
}

/// The docx rule (lint/docxfonts.rs): every folder whose docx names another face than its typst template; true
/// unless `strict` and there is one.
fn docx_report(root: &Path, strict: bool) -> bool {
    let (seen, found) = super::docxfonts::check(root);
    let word = if strict { "LINT" } else { "REPORT" };
    for f in &found {
        println!(
            "{word} docx-font {}: docx names {}; typst sets {}",
            f.docx.display(),
            f.faces.join(", "),
            f.typst.as_deref().unwrap_or("no face")
        );
    }
    let mode = if strict {
        ""
    } else {
        " (report only; --docx-strict, as just lint runs it, fails on them)"
    };
    println!(
        "RESULT: DOCX FONTS {} of {seen} docx folders name a face other than their typst template's{mode}",
        found.len()
    );
    !strict || found.is_empty()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn audited_face_mapping_is_explicit() {
        assert_eq!(family("Times New Roman"), Some("times"));
        assert_eq!(family("TeX Gyre Schola"), Some("schola"));
        assert_eq!(family("Gelasio"), Some("gelasio"));
        assert_eq!(family("TeX Gyre Termes"), Some("termes"));
        assert_eq!(family("EB Garamond"), Some("eb-garamond"));
        assert_eq!(family("unmapped"), None);
    }

    #[test]
    fn typst_lint_accepts_fallback_pair_and_rejects_other_faces() {
        let p = Path::new("template.typ");
        assert!(declaration(
            p,
            "#let font-family = (\"Times New Roman\", \"Liberation Serif\")\nset text(font: font-family)",
            "times"
        ));
        assert!(!declaration(
            p,
            "#let font-family = \"EB Garamond\"\nset text(font: font-family)",
            "times"
        ));
        assert!(declaration(
            p,
            "#let font-family = \"TeX Gyre Schola\"\nset text(font: font-family)",
            "schola"
        ));
    }

    #[test]
    fn latex_lint_uses_vendored_family_path() {
        let p = Path::new("template.tex");
        assert!(declaration(
            p,
            "\\setmainfont[Path=$fontdir$tex-gyre-schola/]{texgyreschola-regular}",
            "schola"
        ));
        assert!(!declaration(p, "\\setmainfont{Liberation Serif}", "schola"));
    }

    #[test]
    fn latex_times_is_newtx_or_the_fontspec_pair() {
        let p = Path::new("template.tex");
        assert!(declaration(p, "\\usepackage{newtxtext,newtxmath}", "times"));
        assert!(declaration(
            p,
            "\\IfFontExistsTF{Times New Roman}{\\setmainfont{Times New Roman}}{\\setmainfont{Liberation Serif}}",
            "times"
        ));
        assert!(!declaration(p, "\\usepackage{lmodern}", "times"));
    }
}
