//! Multi-pass docx builds (the `reference.docx` + `docx/*.lua` engine of `fb render --engine docx`).
//!
//! A filter that needs page numbers (tables of contents and authorities) cannot know them: it writes needles to
//! `$FORMBOOK_NEEDLES` (format: docxpages.rs) and reads the pages of the previous pass from `$FORMBOOK_PAGES`
//! (`id <TAB> page <TAB> label`; empty on the first pass, when it prints placeholders). A filter that writes no
//! needles gets one plain pandoc pass, as before. For a needle-writing filter each pass is:
//!   * pandoc with the reference document and the filters;
//!   * the footers its sections name: `rIdFtrNone` (empty), `rIdFtrPage` (PAGE field) and `rIdFtrAdd`
//!     ("Add-" and the PAGE field), all centered; the document's last sectPr is replaced by the XML the filter
//!     wrote to `$FORMBOOK_FINAL` (pandoc would copy the reference document's);
//!   * a reproducible archive: parts dated SOURCE_DATE_EPOCH, in byte order, no directory entries;
//!   * the LibreOffice PDF, and the page of every needle in it.
//!
//! The passes go on until the pages stop changing (a page list longer than its placeholder can move text).
//! Word may paginate slightly differently from LibreOffice (docs/DOCX.md).
use crate::proc::capture;
use crate::{fail, Res};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

const MAX_PASSES: usize = 5;

const FOOTER_NS: &str = r#"xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships""#;
const PAGE_FIELD: &str = r#"<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>"#;

fn io(path: &Path, e: std::io::Error) -> crate::Fail {
    fail(2, format!("fb render: {}: {e}", path.display()))
}

fn read(path: &Path) -> Res<String> {
    std::fs::read_to_string(path).map_err(|e| io(path, e))
}

fn write(path: &Path, text: &str) -> Res<()> {
    std::fs::write(path, text).map_err(|e| io(path, e))
}

fn run(cmd: &mut Command, what: &str) -> Res<()> {
    let o = capture(cmd)?;
    if o.status.success() {
        return Ok(());
    }
    eprint!("{}", String::from_utf8_lossy(&o.stderr));
    Err(fail(1, format!("fb render: {what} failed")))
}

/// One pandoc pass: `args` are the reference document and filter arguments.
fn pandoc(
    court: &Path,
    args: &[String],
    sample: &str,
    pages: &str,
    work: &Path,
    out: &Path,
) -> Res<()> {
    run(
        Command::new("pandoc")
            .current_dir(court)
            .env("FORMBOOK_NEEDLES", work.join("needles.tsv"))
            .env("FORMBOOK_FINAL", work.join("final.xml"))
            .env("FORMBOOK_PAGES", pages)
            .args(["--from", "markdown+smart", "--to", "docx"])
            .args(args)
            .arg(sample)
            .arg("-o")
            .arg(out),
        "pandoc",
    )
}

/// The document's last sectPr (just before `</w:body>`) replaced by `last`.
fn replace_final_sect(doc: &str, last: &str) -> Option<String> {
    let body_end = doc.rfind("</w:body>")?;
    let start = doc[..body_end].rfind("<w:sectPr")?;
    let end = doc[start..body_end].rfind("</w:sectPr>")? + start + "</w:sectPr>".len();
    Some(format!("{}{}{}", &doc[..start], last, &doc[end..]))
}

/// Every file under `dir`, relative, in byte order.
fn files(dir: &Path) -> Vec<PathBuf> {
    let mut stack = vec![dir.to_path_buf()];
    let mut out = vec![];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                stack.push(p);
            } else if let Ok(rel) = p.strip_prefix(dir) {
                out.push(rel.to_path_buf());
            }
        }
    }
    out.sort();
    out
}

/// Footers, the last section and a reproducible archive, in place.
fn finish(docx: &Path, work: &Path) -> Res<()> {
    let x = work.join("parts");
    let _ = std::fs::remove_dir_all(&x);
    run(
        Command::new("unzip").arg("-q").arg(docx).arg("-d").arg(&x),
        "unzip",
    )?;
    let footers = [
        ("rIdFtrNone", "ftr-none.xml", String::new()),
        ("rIdFtrPage", "ftr-page.xml", PAGE_FIELD.to_string()),
        (
            "rIdFtrAdd",
            "ftr-add.xml",
            format!("<w:r><w:t>Add-</w:t></w:r>{PAGE_FIELD}"),
        ),
    ];
    let mut rels = String::new();
    let mut types = String::new();
    for (id, file, runs) in &footers {
        write(
            &x.join("word").join(file),
            &format!(
                r#"<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:ftr {FOOTER_NS}><w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:jc w:val="center"/></w:pPr>{runs}</w:p></w:ftr>"#
            ),
        )?;
        rels.push_str(&format!(r#"<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="{id}" Target="{file}"/>"#));
        types.push_str(&format!(r#"<Override PartName="/word/{file}" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>"#));
    }
    let rp = x.join("word/_rels/document.xml.rels");
    write(
        &rp,
        &read(&rp)?.replacen("</Relationships>", &format!("{rels}</Relationships>"), 1),
    )?;
    let tp = x.join("[Content_Types].xml");
    write(
        &tp,
        &read(&tp)?.replacen("</Types>", &format!("{types}</Types>"), 1),
    )?;
    let dp = x.join("word/document.xml");
    let last = read(&work.join("final.xml"))?;
    let doc = replace_final_sect(&read(&dp)?, last.trim())
        .ok_or_else(|| fail(1, "fb render: the document has no final sectPr"))?;
    write(&dp, &doc)?;

    let epoch = std::env::var("SOURCE_DATE_EPOCH")
        .ok()
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap_or(0);
    let when = std::time::UNIX_EPOCH + std::time::Duration::from_secs(epoch);
    let list = files(&x);
    for f in &list {
        let p = x.join(f);
        std::fs::File::options()
            .write(true)
            .open(&p)
            .and_then(|h| h.set_modified(when))
            .map_err(|e| io(&p, e))?;
    }
    let _ = std::fs::remove_file(docx);
    let mut zip = Command::new("zip")
        .current_dir(&x)
        .env("TZ", "UTC")
        .args(["-X", "-D", "-q"])
        .arg(docx)
        .arg("-@")
        .stdin(Stdio::piped())
        .spawn()
        .map_err(|e| fail(2, format!("fb render: cannot run zip: {e}")))?;
    let names: String = list.iter().map(|f| format!("{}\n", f.display())).collect();
    zip.stdin
        .take()
        .map(|mut s| s.write_all(names.as_bytes()))
        .transpose()
        .map_err(|e| fail(2, format!("fb render: zip: {e}")))?;
    let st = zip
        .wait()
        .map_err(|e| fail(2, format!("fb render: zip: {e}")))?;
    st.success()
        .then_some(())
        .ok_or_else(|| fail(1, "fb render: zip failed"))
}

/// The pages file of the LibreOffice PDF of `docx`.
fn pages_of(docx: &Path, n: usize, work: &Path) -> Res<String> {
    let pdf = work.join(format!("pages{n}.pdf"));
    crate::engines::convert(docx, &pdf, work)?;
    let o = capture(Command::new("pdftotext").arg(&pdf).arg("-"))?;
    if !o.status.success() {
        return Err(fail(1, "fb render: pdftotext failed"));
    }
    let pages = crate::docxpages::page_texts(&String::from_utf8_lossy(&o.stdout));
    crate::docxpages::lookup(&read(&work.join("needles.tsv"))?, &pages).map_err(|e| fail(1, e))
}

/// Build `sample` into `out` (a .docx): one pass for a filter without needles, otherwise passes until the pages
/// settle. `args` are the `--reference-doc` and `--lua-filter` arguments; `work` is scratch space.
pub fn render(court: &Path, args: &[String], sample: &str, out: &Path, work: &Path) -> Res<()> {
    let pass = |n: usize| work.join(format!("pass{n}.docx"));
    pandoc(court, args, sample, "", work, &pass(1))?;
    if !work.join("needles.tsv").is_file() {
        return crate::proc::move_file(&pass(1), out).map_err(|e| io(out, e));
    }
    finish(&pass(1), work)?;
    let mut prev = pages_of(&pass(1), 1, work)?;
    for n in 2..=MAX_PASSES {
        let pf = work.join(format!("pages{}.tsv", n - 1));
        write(&pf, &prev)?;
        pandoc(court, args, sample, &pf.to_string_lossy(), work, &pass(n))?;
        finish(&pass(n), work)?;
        let cur = pages_of(&pass(n), n, work)?;
        if cur == prev {
            return std::fs::copy(pass(n), out)
                .map(|_| ())
                .map_err(|e| io(out, e));
        }
        prev = cur;
    }
    Err(fail(
        1,
        format!("fb render: the pages did not settle in {MAX_PASSES} passes"),
    ))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn replaces_only_the_last_sectpr() {
        let doc = r#"<w:body><w:p><w:pPr><w:sectPr><a/></w:sectPr></w:pPr></w:p><w:sectPr w:x="1"><b/></w:sectPr></w:body>"#;
        let got = replace_final_sect(doc, "<w:sectPr><c/></w:sectPr>").unwrap();
        assert_eq!(
            got,
            r#"<w:body><w:p><w:pPr><w:sectPr><a/></w:sectPr></w:pPr></w:p><w:sectPr><c/></w:sectPr></w:body>"#
        );
        assert!(replace_final_sect("<w:body></w:body>", "x").is_none());
    }

    #[test]
    fn lists_files_in_byte_order() {
        let t = crate::proc::TempDir::new("docxpass-test").unwrap();
        std::fs::create_dir_all(t.path().join("word/_rels")).unwrap();
        for f in [
            "word/document.xml",
            "[Content_Types].xml",
            "word/_rels/document.xml.rels",
        ] {
            std::fs::write(t.path().join(f), "").unwrap();
        }
        let got: Vec<String> = files(t.path())
            .iter()
            .map(|p| p.display().to_string())
            .collect();
        assert_eq!(
            got,
            [
                "[Content_Types].xml",
                "word/_rels/document.xml.rels",
                "word/document.xml"
            ]
        );
    }
}
