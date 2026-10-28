//! `docx-rid` (fb-595.70): a docx filter must not name a relationship id that pandoc may renumber.
//!
//! pandoc copies the reference document's footers and headers into the .docx, and some versions renumber their
//! relationship ids (`rIdFooter1` becomes `rId9`). A raw sectPr in a filter (or the last section it writes to
//! `$FORMBOOK_FINAL`) that names one of those ids then dangles, and the .docx does not open (fb-595.64, the cavc and
//! ca4 briefs). A filter names the footers `fb render` adds after pandoc instead (`rIdFtrNone`, `rIdFtrPage`,
//! `rIdFtrAdd`, or its own in `$FORMBOOK_FOOTERS` and `$FORMBOOK_HEADERS`; docxpass.rs).
//!
//! Findings, for a `docx/` folder:
//!   * a `*.lua` filter (any depth) names an id the folder's reference declares: a `<footer id>` or `<header id>` of
//!     `docx/reference.xml`, the cross-engine recipe's `rIdFooter1` (`base="xengine"`), or a footer or header
//!     relationship of a committed `docx/reference.docx`;
//!   * a filter names a numbered id (`rId9`): pandoc's own numbering, never stable;
//!   * `docx/reference.xml` declares a footer or header under a numbered id, which can collide with pandoc's.
use super::Finding;
use crate::proc::capture;
use crate::Res;
use std::collections::BTreeSet;
use std::path::{Path, PathBuf};
use std::process::Command;

const KIND: &str = "docx-rid";
const FIX: &str = "name a footer fb render adds (rIdFtrNone, rIdFtrPage, rIdFtrAdd, or the filter's own in $FORMBOOK_FOOTERS/$FORMBOOK_HEADERS; docxpass.rs)";

/// Every `rId..` token of `text`, with its 1-based line.
fn tokens(text: &str) -> Vec<(usize, String)> {
    let word = |c: char| c.is_ascii_alphanumeric() || c == '_';
    let mut out = vec![];
    for (n, line) in text.lines().enumerate() {
        let mut from = 0;
        while let Some(i) = line[from..].find("rId").map(|i| i + from) {
            let before = line[..i].chars().next_back();
            let len = line[i..].find(|c: char| !word(c)).unwrap_or(line.len() - i);
            if !before.is_some_and(word) && len > 3 {
                out.push((n + 1, line[i..i + len].to_string()));
            }
            from = i + len.max(3);
        }
    }
    out
}

/// `rId` and digits only: pandoc's numbering.
fn numbered(id: &str) -> bool {
    id.strip_prefix("rId")
        .is_some_and(|d| !d.is_empty() && d.bytes().all(|b| b.is_ascii_digit()))
}

/// The footer and header ids of a reference.xml: its `<footer id>` and `<header id>` elements, with their lines, and
/// the recipe's `rIdFooter1` for an xengine base.
fn xml_ids(text: &str) -> Vec<(usize, String)> {
    let mut out = vec![];
    for kind in ["footer", "header"] {
        for el in crate::docxref::elements(text, kind) {
            let tag = &el[..el.find('>').unwrap_or(el.len())];
            if let Some(id) = crate::docxref::attr(tag, "id") {
                let at = text.find(el).unwrap_or(0);
                out.push((text[..at].matches('\n').count() + 1, id));
            }
        }
    }
    let root = text
        .find("<reference")
        .map(|i| &text[i..i + text[i..].find('>').unwrap_or(0)]);
    if root.is_some_and(|r| crate::docxref::attr(r, "base").as_deref() == Some("xengine")) {
        out.push((0, "rIdFooter1".into()));
    }
    out
}

/// The footer and header relationship ids of a binary reference.docx.
fn docx_ids(docx: &Path) -> Res<Vec<String>> {
    let o = capture(
        Command::new("unzip")
            .arg("-p")
            .arg(docx)
            .arg("word/_rels/document.xml.rels"),
    )?;
    let rels = String::from_utf8_lossy(&o.stdout);
    Ok(crate::docxref::elements(&rels, "Relationship")
        .into_iter()
        .filter(|r| {
            crate::docxref::attr(r, "Type")
                .is_some_and(|t| t.ends_with("/footer") || t.ends_with("/header"))
        })
        .filter_map(|r| crate::docxref::attr(r, "Id"))
        .collect())
}

/// Every `*.lua` under `dir`, sorted.
fn filters(dir: &Path) -> Vec<PathBuf> {
    let mut out = vec![];
    let mut stack = vec![dir.to_path_buf()];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                stack.push(p);
            } else if p.extension().is_some_and(|x| x == "lua") {
                out.push(p);
            }
        }
    }
    out.sort();
    out
}

fn read(p: &Path) -> Res<String> {
    std::fs::read_to_string(p).map_err(|e| crate::fail(2, format!("fb lint: {}: {e}", p.display())))
}

/// The findings of one `docx/` folder (or a folder of shared filters, with no reference); file names relative to
/// `base`.
pub fn check(docx: &Path, base: &Path) -> Res<Vec<Finding>> {
    let name = |p: &Path| {
        p.strip_prefix(base)
            .unwrap_or(p)
            .to_string_lossy()
            .into_owned()
    };
    let mut found = vec![];
    let mut declared = BTreeSet::new();
    let xml = docx.join("reference.xml");
    if xml.is_file() {
        for (line, id) in xml_ids(&read(&xml)?) {
            if numbered(&id) && line > 0 {
                found.push(Finding {
                    kind: KIND,
                    file: name(&xml),
                    line,
                    detail: format!("declares a footer or header under the numbered id {id}, which can collide with pandoc's own; give it a name, or move it to a filter's $FORMBOOK_FOOTERS"),
                });
            }
            declared.insert(id);
        }
    }
    let bin = docx.join("reference.docx");
    if bin.is_file() {
        declared.extend(docx_ids(&bin)?);
    }
    for f in filters(docx) {
        for (line, id) in tokens(&read(&f)?) {
            let why = if declared.contains(&id) {
                "the reference document's"
            } else if numbered(&id) {
                "a numbered"
            } else {
                continue;
            };
            found.push(Finding {
                kind: KIND,
                file: name(&f),
                line,
                detail: format!("names {why} relationship id {id}, which pandoc may renumber (fb-595.64); {FIX}"),
            });
        }
    }
    Ok(found)
}

/// Every folder named `docx` under `dir`, sorted.
pub fn docx_dirs(dir: &Path) -> Vec<PathBuf> {
    let mut out = vec![];
    let mut stack = vec![dir.to_path_buf()];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            let hidden = e.file_name().to_string_lossy().starts_with('.');
            if !p.is_dir() || hidden {
                continue;
            }
            if e.file_name() == "docx" {
                out.push(p.clone());
            }
            stack.push(p);
        }
    }
    out.sort();
    out
}

/// The findings of every court's docx folder and of the shared filters in lib/docx.
pub fn check_repo(root: &Path) -> Res<Vec<Finding>> {
    let mut found = vec![];
    for d in docx_dirs(&root.join("courts")) {
        found.extend(check(&d, root)?);
    }
    found.extend(check(&root.join("lib/docx"), root)?);
    Ok(found)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tmp(name: &str) -> PathBuf {
        let d = std::env::temp_dir().join(format!("fb-docxrid-{name}-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&d);
        std::fs::create_dir_all(d.join("lib")).unwrap();
        d
    }

    #[test]
    fn tokens_are_whole_ids() {
        let t = tokens("a r:id=\"rIdFooter1\" x\n-- xrIdNo rId9, rId\nrIdFtrPage");
        let ids: Vec<_> = t.iter().map(|(l, i)| format!("{l}:{i}")).collect();
        assert_eq!(ids, ["1:rIdFooter1", "2:rId9", "3:rIdFtrPage"]);
        assert!(numbered("rId100") && !numbered("rId") && !numbered("rIdFooter1"));
    }

    #[test]
    fn rejects_reference_and_numbered_ids() {
        let d = tmp("bad");
        std::fs::write(
            d.join("reference.xml"),
            "<reference base=\"xengine\" size=\"24\">\n<footer id=\"rIdCourtPage\"><w:p/></footer>\n<footer id=\"rId101\"><w:p/></footer>\n</reference>",
        )
        .unwrap();
        std::fs::write(
            d.join("a.lua"),
            "local A = 'rIdCourtPage'\nlocal B = \"rIdFooter1\"\nlocal C = 'rId101'\nlocal D = 'rId7'\nlocal E = 'rIdFtrPage'\nlocal F = 'rIdOwn'\n",
        )
        .unwrap();
        std::fs::write(d.join("lib/m.lua"), "x = 'rIdCourtPage'\n").unwrap();
        let got: Vec<_> = check(&d, &d)
            .unwrap()
            .iter()
            .map(|f| format!("{}:{}", f.file, f.line))
            .collect();
        assert_eq!(
            got,
            [
                "reference.xml:3",
                "a.lua:1",
                "a.lua:2",
                "a.lua:3",
                "a.lua:4",
                "lib/m.lua:1"
            ]
        );
        let _ = std::fs::remove_dir_all(&d);
    }

    #[test]
    fn accepts_the_footers_fb_render_adds() {
        let d = tmp("good");
        std::fs::write(
            d.join("reference.xml"),
            "<reference base=\"pandoc\">\n<footer id=\"rIdCourtPage\"><w:p/></footer>\n<w:sectPr><w:footerReference w:type=\"default\" r:id=\"rIdCourtPage\"/></w:sectPr>\n</reference>",
        )
        .unwrap();
        std::fs::write(
            d.join("a.lua"),
            "write('FORMBOOK_FOOTERS', 'rIdOwnPage\\t' .. p)\nlocal s = '<w:footerReference r:id=\"rIdFtrPage\"/>' .. 'rIdFtrNone' .. 'rIdOwnPage'\n",
        )
        .unwrap();
        assert!(check(&d, &d).unwrap().is_empty());
        let _ = std::fs::remove_dir_all(&d);
    }

    #[test]
    fn the_repository_has_none() {
        let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
        let found = check_repo(&root).unwrap();
        assert!(
            found.is_empty(),
            "{}",
            found
                .iter()
                .map(|f| f.to_string())
                .collect::<Vec<_>>()
                .join("\n")
        );
    }
}
