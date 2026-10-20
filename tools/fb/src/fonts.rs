//! Font policy migrations backed by the checked-in exemplar-font audit.
use crate::{fail, repo_root, Res};
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

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

fn attr(line: &str, key: &str) -> Option<String> {
    let needle = format!("{key}=\"");
    let start = line.find(&needle)? + needle.len();
    let end = line[start..].find('"')? + start;
    Some(line[start..end].to_string())
}

fn unsuperset(name: &str) -> String {
    if name.len() > 7
        && name.as_bytes()[..6].iter().all(u8::is_ascii_uppercase)
        && name.as_bytes()[6] == b'+'
    {
        name[7..].to_string()
    } else {
        name.to_string()
    }
}

fn body_family(name: &str) -> String {
    let n = name.to_ascii_lowercase().replace([' ', '-', '_'], "");
    if n.contains("timesnewroman") || n.contains("liberationserif") {
        "timesnewroman".into()
    } else if n.contains("times") || n.contains("nimbusroman") {
        "times".into()
    } else if n.contains("liberationsans") {
        "liberationsans".into()
    } else if n.contains("garamond") {
        "garamond".into()
    } else if n.contains("calisto") {
        "calisto".into()
    } else if n.contains("aptos") {
        "aptos".into()
    } else if n.contains("century") {
        "centuryschoolbook".into()
    } else {
        n
    }
}

fn audit_record(pdf: &Path, root: &Path) -> Res<Value> {
    let fonts_out = Command::new("pdffonts")
        .arg(pdf)
        .output()
        .map_err(|e| fail(2, format!("pdffonts: {e}")))?;
    if !fonts_out.status.success() {
        return Err(fail(2, format!("pdffonts failed for {}", pdf.display())));
    }
    let font_text = String::from_utf8_lossy(&fonts_out.stdout);
    let fonts: Vec<String> = font_text
        .lines()
        .skip(2)
        .filter_map(|line| line.split_whitespace().next())
        .map(unsuperset)
        .collect();
    let html = Command::new("pdftohtml")
        .args(["-xml", "-i", "-q", "-stdout"])
        .arg(pdf)
        .output()
        .map_err(|e| fail(2, format!("pdftohtml: {e}")))?;
    let xml = String::from_utf8_lossy(&html.stdout);
    let mut ids = std::collections::HashMap::new();
    let mut usage = std::collections::BTreeMap::<String, usize>::new();
    let mut total = 0usize;
    for line in xml.lines() {
        if line.contains("<fontspec ") {
            if let (Some(id), Some(family)) = (attr(line, "id"), attr(line, "family")) {
                ids.insert(id, unsuperset(&family));
            }
        } else if line.contains("<text ") {
            if let Some(id) = attr(line, "font") {
                if let Some(family) = ids.get(&id) {
                    let text = line.split_once('>').map(|(_, body)| body).unwrap_or("");
                    let visible = text.chars().filter(|c| c.is_alphanumeric()).count();
                    if visible > 0 {
                        *usage.entry(body_family(family)).or_default() += visible;
                        total += visible;
                    }
                }
            }
        }
    }
    let (body, share) = usage
        .iter()
        .max_by_key(|(_, n)| *n)
        .map(|(body, n)| (body.clone(), *n as f64 / total.max(1) as f64))
        .unwrap_or_else(|| (String::new(), 0.0));
    let (class, face, why) = match body.as_str() {
        "timesnewroman" => (
            "metric-exact",
            "Times New Roman",
            "Times New Roman body face; metric exact.",
        ),
        "times" => (
            "approximate",
            "Times",
            "Times-family body face; no exact Times New Roman name.",
        ),
        "liberationsans" => (
            "approximate",
            "Liberation Sans",
            "Body face is extractable but is not Times New Roman.",
        ),
        "garamond" | "calisto" | "aptos" | "centuryexpandedbt" | "equitya" | "charter" | "" => (
            "impossible",
            "",
            if total == 0 {
                "No extractable text layer."
            } else {
                "No redistributable metric-exact body face is identified."
            },
        ),
        _ => (
            "impossible",
            "",
            "No redistributable metric-exact body face is identified.",
        ),
    };
    let _ = root;
    Ok(serde_json::json!({
        "body": body,
        "body_share": (share * 1000.0).round() / 1000.0,
        "class": class,
        "face": face,
        "why": why,
        "fonts": fonts,
    }))
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
/// embedded `TimesNewRomanPSMT`). A Times New Roman body does. Adobe Times (`body == "times"`)
/// does only when the audit maps it to Times itself; when the audit maps it to `TeX Gyre Termes`
/// the template declares Termes (what `fb lint fonts` demands) and no TNR is expected.
fn wants_tnr(record: &Value) -> bool {
    let text = |k: &str| record.get(k).and_then(Value::as_str).unwrap_or("");
    let body = text("body").to_ascii_lowercase();
    body.contains("timesnewroman")
        || (body == "times" && matches!(text("face"), "Times New Roman" | "Times" | "Times-Roman"))
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
    if args == ["audit-additions".to_string()] {
        return audit_additions();
    }
    if args != ["migrate".to_string()] {
        return Err(fail(2, "usage: fb fonts migrate|audit-additions"));
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

fn audit_additions() -> Res<std::process::ExitCode> {
    let root = repo_root()?;
    let p = root.join("data/exemplar-fonts.json");
    let raw = fs::read_to_string(&p).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let audit: Value =
        serde_json::from_str(&raw).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    let entries = audit
        .get("exemplars")
        .and_then(Value::as_object)
        .ok_or_else(|| fail(2, "font audit has no exemplars map"))?;
    let mut pdfs = Vec::new();
    collect_pdfs(&root.join("courts"), &mut pdfs).map_err(|e| fail(2, format!("courts: {e}")))?;
    let mut additions = Vec::new();
    for pdf in pdfs {
        let key = pdf
            .strip_prefix(&root)
            .unwrap_or(&pdf)
            .to_string_lossy()
            .replace('\\', "/");
        if entries.contains_key(&key) {
            continue;
        }
        additions.push((key, audit_record(&pdf, &root)?));
    }
    if !additions.is_empty() {
        let marker = "\n  }\n}";
        let at = raw
            .rfind(marker)
            .ok_or_else(|| fail(2, "font audit exemplar map closing brace not found"))?;
        let mut inserted = String::new();
        for (key, record) in &additions {
            let key_json =
                serde_json::to_string(key).map_err(|e| fail(2, format!("serialize path: {e}")))?;
            let record_json = serde_json::to_string(record)
                .map_err(|e| fail(2, format!("serialize record: {e}")))?;
            inserted.push_str(&format!(",\n    {key_json}: {record_json}"));
        }
        let mut text = raw;
        text.insert_str(at, &inserted);
        fs::write(&p, text).map_err(|e| fail(2, format!("{}: {e}", p.display())))?;
    }
    println!(
        "audited {} new FILED-EXAMPLE PDFs with pdffonts and pdftohtml",
        additions.len()
    );
    Ok(std::process::ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

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
    }
}
