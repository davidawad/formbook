//! Identical repeated package entries, dropped. A `docx/render.sh` that adds a relationship or a content-type
//! Override itself cannot know whether pandoc already carried the reference document's over (pandoc versions
//! differ), and a doubled entry makes Word ask to repair the file (DEF-DOCX-OPEN). `fb render` therefore keeps the
//! first of any `<Relationship/>` or `<Override/>` whose attributes repeat one before it exactly. Entries that share
//! an id but differ (a real conflict) are left alone for DEF-DOCX-OPEN to refuse.
use crate::{fail, Res};
use std::collections::BTreeSet;
use std::path::Path;

/// `text` without the later copies of `<tag .../>` elements whose attributes equal an earlier one's.
pub fn dedupe(text: &str, tag: &str) -> String {
    let open = format!("<{tag} ");
    let mut seen = BTreeSet::new();
    let (mut out, mut rest) = (String::with_capacity(text.len()), text);
    while let Some(i) = rest.find(&open) {
        let Some(len) = rest[i..].find("/>").map(|j| j + 2) else {
            break;
        };
        let elem = &rest[i..i + len];
        out.push_str(&rest[..i]);
        if seen.insert(attrs(elem)) {
            out.push_str(elem);
        }
        rest = &rest[i + len..];
    }
    out.push_str(rest);
    out
}

/// The attributes of one self-closing element, sorted (`name="value"` pairs, whitespace-insensitive).
fn attrs(elem: &str) -> Vec<(String, String)> {
    let mut v = Vec::new();
    let mut rest = elem;
    while let Some(eq) = rest.find("=\"") {
        let name = rest[..eq]
            .rsplit(|c: char| c.is_whitespace())
            .next()
            .unwrap_or("");
        let after = &rest[eq + 2..];
        let Some(close) = after.find('"') else {
            break;
        };
        v.push((name.to_string(), after[..close].to_string()));
        rest = &after[close + 1..];
    }
    v.sort();
    v
}

/// Drop identical repeated relationships and Overrides from `docx` in place (`work`: scratch space). The file is
/// rewritten only when there was something to drop.
pub fn package(docx: &Path, work: &Path) -> Res<()> {
    let x = work.join("dedupe");
    let _ = std::fs::remove_dir_all(&x);
    let o = crate::proc::capture(
        std::process::Command::new("unzip")
            .arg("-q")
            .arg(docx)
            .arg("-d")
            .arg(&x),
    )?;
    if !o.status.success() {
        return Ok(()); // not a zip: DEF-DOCX-OPEN reports it
    }
    let mut changed = false;
    let mut parts = vec![(x.join("[Content_Types].xml"), "Override")];
    for e in walk(&x) {
        if e.extension().is_some_and(|x| x == "rels") {
            parts.push((e, "Relationship"));
        }
    }
    for (p, tag) in parts {
        let Ok(text) = std::fs::read_to_string(&p) else {
            continue;
        };
        let new = dedupe(&text, tag);
        if new != text {
            std::fs::write(&p, new)
                .map_err(|e| fail(2, format!("fb render: {}: {e}", p.display())))?;
            changed = true;
        }
    }
    if changed {
        crate::docxzip::pack(&x, docx)?;
    }
    Ok(())
}

fn walk(dir: &Path) -> Vec<std::path::PathBuf> {
    let mut out = Vec::new();
    let mut stack = vec![dir.to_path_buf()];
    while let Some(d) = stack.pop() {
        for e in std::fs::read_dir(&d).into_iter().flatten().flatten() {
            let p = e.path();
            match p.is_dir() {
                true => stack.push(p),
                false => out.push(p),
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn keeps_the_first_of_identical_entries_only() {
        let r = r#"<Relationships><Relationship Type="f" Id="rId100" Target="footer1.xml" /><Relationship Id="rId1" Type="s" Target="styles.xml"/><Relationship Id="rId100"  Target="footer1.xml" Type="f"/></Relationships>"#;
        assert_eq!(
            dedupe(r, "Relationship"),
            r#"<Relationships><Relationship Type="f" Id="rId100" Target="footer1.xml" /><Relationship Id="rId1" Type="s" Target="styles.xml"/></Relationships>"#
        );
    }

    #[test]
    fn a_conflict_is_left_for_the_check() {
        let r =
            r#"<Relationship Id="rId9" Target="a.xml"/><Relationship Id="rId9" Target="b.xml"/>"#;
        assert_eq!(dedupe(r, "Relationship"), r);
        let t = r#"<Types><Override PartName="/word/footer1.xml" ContentType="c" /><Override PartName="/word/footer1.xml" ContentType="c" /></Types>"#;
        assert_eq!(
            dedupe(t, "Override"),
            r#"<Types><Override PartName="/word/footer1.xml" ContentType="c" /></Types>"#
        );
    }
}
