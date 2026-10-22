//! Multi-pass docx builds (the `reference.docx` + `docx/*.lua` engine of `fb render --engine docx`).
//!
//! A filter that needs page numbers (tables of contents and authorities) cannot know them: it writes needles to
//! `$FORMBOOK_NEEDLES` (format: docxpages.rs) and reads the pages of the previous pass from `$FORMBOOK_PAGES`
//! (`id <TAB> page <TAB> label`; empty on the first pass, when it prints placeholders). A filter that writes neither
//! needles nor `$FORMBOOK_FINAL` gets one plain pandoc pass, as before; one that writes only `$FORMBOOK_FINAL` gets
//! one pass with the footers and last section below. Sections should name those footers: pandoc may renumber the
//! reference document's relationship ids (`rIdFooter1` becomes `rId9`), so a raw sectPr naming one can dangle and
//! the .docx will not open. For a needle-writing filter each pass is:
//!   * pandoc with the reference document and the filters;
//!   * the footers its sections name: `rIdFtrNone` (empty), `rIdFtrPage` (PAGE field) and `rIdFtrAdd`
//!     ("Add-" and the PAGE field), all centered; the document's last sectPr is replaced by the XML the filter
//!     wrote to `$FORMBOOK_FINAL` (pandoc would copy the reference document's); a filter may add footers of its
//!     own (text from the sample, such as a paper's title) in `$FORMBOOK_FOOTERS`, one per line:
//!     `ID <TAB> paragraphs` (the footer's `w:p` elements; the PAGE field is the filter's to write);
//!   * a reproducible archive (docxzip.rs);
//!   * the LibreOffice PDF, and the page of every needle in it.
//!
//! Every pass also gets `$FORMBOOK_META`: the sample's YAML frontmatter as JSON (`pandoc.json.decode`), the values as
//! written, where pandoc's own metadata reads each string as markdown.
//!
//! Every pass also gets `$FORMBOOK_STATE`: a file that is empty before the first pass and is kept across the passes
//! of one render, for a layout decision a pass makes from the pages and every later pass must keep (the Fourth
//! Circuit's sticky headings: a heading a pass left at the foot of a page opens the next page from then on, though
//! it no longer ends a page once moved). The filter reads it, adds what the pages of `$FORMBOOK_PAGES` call for and
//! writes it back; what it adds must depend only on those pages and what is already there, so equal pages give the
//! same document.
//!
//! The passes go on until the pages stop changing (a page list longer than its placeholder can move text).
//! Word may paginate slightly differently from LibreOffice (docs/DOCX.md).
use crate::proc::capture;
use crate::{fail, Res};
use std::path::Path;
use std::process::Command;

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

/// One pandoc pass: `args` are the reader (`--from=..`), reference document and filter arguments.
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
            .env("FORMBOOK_FOOTERS", work.join("footers.tsv"))
            .env("FORMBOOK_META", work.join("meta.json"))
            .env("FORMBOOK_STATE", work.join("state.tsv"))
            .env("FORMBOOK_PAGES", pages)
            .args(["--to", "docx"])
            .args(args)
            .arg(sample)
            .arg("-o")
            .arg(out),
        "pandoc",
    )
}

/// The document's last sectPr (just before `</w:body>`) replaced by `last`.
pub(crate) fn replace_final_sect(doc: &str, last: &str) -> Option<String> {
    let body_end = doc.rfind("</w:body>")?;
    let start = doc[..body_end].rfind("<w:sectPr")?;
    let end = doc[start..body_end].rfind("</w:sectPr>")? + start + "</w:sectPr>".len();
    Some(format!("{}{}{}", &doc[..start], last, &doc[end..]))
}

/// The footers a filter wrote to `$FORMBOOK_FOOTERS`: one per line, `ID <TAB> paragraphs` (the `w:p` elements of
/// the footer), as `(id, file, paragraphs)`; the file names follow the line order.
fn filter_footers(text: &str) -> Vec<(String, String, String)> {
    text.lines()
        .filter_map(|l| l.split_once('\t'))
        .enumerate()
        .map(|(n, (id, paras))| {
            (
                id.to_string(),
                format!("ftr-own{}.xml", n + 1),
                paras.to_string(),
            )
        })
        .collect()
}

/// Footers, the last section and a reproducible archive, in place.
fn finish(docx: &Path, work: &Path) -> Res<()> {
    let x = work.join("parts");
    crate::docxzip::unpack(docx, &x)?;
    let centered = |runs: &str| {
        format!(
            r#"<w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:jc w:val="center"/></w:pPr>{runs}</w:p>"#
        )
    };
    let mut footers = vec![
        ("rIdFtrNone".into(), "ftr-none.xml".into(), centered("")),
        (
            "rIdFtrPage".into(),
            "ftr-page.xml".into(),
            centered(PAGE_FIELD),
        ),
        (
            "rIdFtrAdd".into(),
            "ftr-add.xml".into(),
            centered(&format!("<w:r><w:t>Add-</w:t></w:r>{PAGE_FIELD}")),
        ),
    ];
    let own = work.join("footers.tsv");
    if own.is_file() {
        footers.extend(filter_footers(&read(&own)?));
    }
    let mut rels = String::new();
    let mut types = String::new();
    for (id, file, paras) in &footers {
        write(
            &x.join("word").join(file),
            &format!(
                r#"<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:ftr {FOOTER_NS}>{paras}</w:ftr>"#
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
    crate::docxzip::pack(&x, docx)
}

/// The sample's YAML frontmatter as JSON, for `$FORMBOOK_META`: the values as written (pandoc's metadata reads
/// every string as markdown); `{}` for a sample without one.
fn write_meta(sample: &Path, work: &Path) -> Res<()> {
    let text = read(sample)?;
    let json = match crate::lint::metadata::frontmatter(&text) {
        Err(_) => "{}".to_string(),
        Ok(yaml) => {
            let v: serde_yaml::Value = serde_yaml::from_str(yaml).map_err(|e| {
                fail(
                    1,
                    format!("fb render: {}: frontmatter: {e}", sample.display()),
                )
            })?;
            serde_json::to_string(&v).map_err(|e| {
                fail(
                    1,
                    format!("fb render: {}: frontmatter: {e}", sample.display()),
                )
            })?
        }
    };
    write(&work.join("meta.json"), &json)
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
/// settle. `args` are the `--from`, `--reference-doc` and `--lua-filter` arguments; `work` is scratch space.
pub fn render(court: &Path, args: &[String], sample: &str, out: &Path, work: &Path) -> Res<()> {
    write_meta(&court.join(sample), work)?;
    write(&work.join("state.tsv"), "")?;
    let pass = |n: usize| work.join(format!("pass{n}.docx"));
    pandoc(court, args, sample, "", work, &pass(1))?;
    if !work.join("needles.tsv").is_file() {
        if work.join("final.xml").is_file() {
            finish(&pass(1), work)?;
        }
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
    fn reads_the_filter_footers() {
        let got = filter_footers("rIdA\t<w:p/>\nbad line\nrIdB\t<w:p><w:r/></w:p>\n");
        assert_eq!(
            got,
            [
                (
                    "rIdA".to_string(),
                    "ftr-own1.xml".to_string(),
                    "<w:p/>".to_string()
                ),
                (
                    "rIdB".to_string(),
                    "ftr-own2.xml".to_string(),
                    "<w:p><w:r/></w:p>".to_string()
                )
            ]
        );
    }
}
