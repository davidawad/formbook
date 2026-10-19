//! `fb contribute brief <id>`: print the exact task for a unit.
use super::{die, field, load_worklist, min_pages, read_json, unit_json, usage, Ctx, Net};
use crate::Res;
use std::path::Path;
use std::process::ExitCode;

/// Everything the brief interpolates.
pub struct Brief<'a> {
    pub id: &'a str,
    pub kind: &'a str,
    pub alias: &'a str,
    pub court_path: &'a str,
    pub doctype: &'a str,
    pub title: &'a str,
    pub level: &'a str,
    pub court_name: &'a str,
    pub what: &'a str,
    pub min: &'a str,
    pub siblings: &'a str,
    pub has_rules: bool,
    pub has_readme: bool,
}

fn kind_section(b: &Brief, folder: &str) -> String {
    let (kind, dt, al, min) = (b.kind, b.doctype, b.alias, b.min);
    match kind {
        "new-template" | "new-doctype" => format!(
            r##"
DO (kind {kind})
  1. Research the governing rules for a {dt} in {al} from primary sources (court rules, local rules, clerk's
     form requirements). Note rule number, URL and date verified. These decide the layout (tier 1).
  2. Find 1 to 3 real, public filings of this type in this court (CourtListener RECAP, the court's own
     site, state e-filing archives). Save the PDFs as {folder}/usage/FILED-EXAMPLE-{dt}.pdf, then
     FILED-EXAMPLE-{dt}-2.pdf, FILED-EXAMPLE-{dt}-3.pdf (no court alias, no case name). Public court records only: no sealed, redacted-by-mistake
     or private documents.
  3. Write {folder}/usage/SOURCE.md: for every PDF the file name, filer, case, docket number, date
     filed, the exact URL you downloaded it from, date retrieved. See the first-circuit example.
  4. Write the typst template: {folder}/typst/main.typ (entry point; reads the sample via
     --input sample=...) plus {folder}/typst/<court>-{dt}.typ. Rule-driven and content-agnostic: no
     case-specific text, no coordinates measured off the exemplar. Fonts only from fonts/.
  5. Write {folder}/usage/INPUT-{dt}.md (markdown with YAML frontmatter) transcribed from
     FILED-EXAMPLE-{dt}.pdf (same suffix = pair), and, if you can, a second structurally different
     fictional INPUT-{dt}-<n>.md whose <n> has no FILED-EXAMPLE.
  6. Render: just render {folder}      (any typst warning fails) -> usage/OUTPUT-{dt}.typst.pdf
     then: just overlay {folder}       -> .overlay/{folder}/OVERLAY-{dt}.pdf/.txt (gitignored)
  7. Look at EVERY page of the overlay against the exemplar. Fix tier-1 and tier-2 defects; do not chase tier 3.
  8. Write {folder}/README.md: rules table (rule, requirement, where the template uses it), file table,
     frontmatter contract, known gaps. Mark BLOCKED items honestly.
"##
        ),
        "add-exemplar" => format!(
            r##"
DO (kind add-exemplar): the template exists but has no filed exemplar to be judged against.
  1. Find 1 to 3 real, public filings of this doc type in this court by different filers.
  2. Save as {folder}/usage/FILED-EXAMPLE-{dt}.pdf (then -2, -3: FILED-EXAMPLE-{dt}-2.pdf) and record
     each in {folder}/usage/SOURCE.md (file, filer, case, docket no., date filed, exact URL, date retrieved).
  3. Transcribe FILED-EXAMPLE-{dt}-<n>.pdf into {folder}/usage/INPUT-{dt}-<n>.md (same suffix); render it:
     just render {folder} ; just overlay {folder}
  4. Review every overlay page; fix tier-1 and tier-2 defects in {folder}/typst/ only.
  5. Update {folder}/README.md (remove the BLOCKED: no exemplar line, add the exemplar and findings).
"##
        ),
        "deepen" => format!(
            r##"
DO (kind deepen): the sample is shorter than a realistic {dt} (about {min}+ pages), so layout under real load
is untested (page breaks, long tables, many footnotes, long headings, certificates).
  1. Read {folder}/README.md "Known gaps" and the existing samples.
  2. Extend or add a usage/INPUT-*.md so the rendered output reaches at least {min} pages and exercises
     every section the court requires (tables, footnotes, block quotes, certificates, signature block).
  3. Re-render and re-overlay; fix tier-1 and tier-2 defects in typst/ (content-agnostic fixes only).
  4. Update README.md known gaps.
"##
        ),
        _ => String::new(),
    }
}

/// The whole brief text.
pub fn text(b: &Brief) -> String {
    let folder = format!("{}/{}", b.court_path, b.doctype);
    let mut s = format!(
        r##"TASK {id}  [{kind}]
{title} for {name} ({al}, level: {level})
Folder (your whole change lives here and nowhere else): {folder}/
Doc type means: {what}

READ FIRST
  AGENTS.md and docs/EVAL-LOOP.md (quality tiers, banned practices). Reference doc-type folder to copy the
  structure of: courts/first-circuit/court-of-appeals/opening-brief/  (README.md, typst/, usage/).
"##,
        id = b.id,
        kind = b.kind,
        title = b.title,
        name = b.court_name,
        al = b.alias,
        level = b.level,
        what = b.what,
    );
    if !b.siblings.is_empty() {
        s.push_str(&format!(
            "  Sibling doc types in this court you can reuse patterns from: {}\n",
            b.siblings
        ));
    }
    if b.has_rules {
        s.push_str(&format!(
            "  The court's rules, already researched: {}/rules.md\n",
            b.court_path
        ));
    }
    if b.has_readme {
        s.push_str(&format!("  Court notes: {}/README.md\n", b.court_path));
    }
    s.push_str(&kind_section(b, &folder));
    s.push_str(&format!(
        r##"
QUALITY BAR (summary; the full text is docs/EVAL-LOOP.md)
  tier 1 mandated form (font, size, margins, spacing, length limits, required sections, certificates): perfect.
  tier 2 professional convention (cover, TOC/TOA, headings, caption, signature block): looks professional,
         judged against exemplars from different filers. tier 3 one filer's style: do not chase.
  Banned: case-specific text in typst/, forced line breaks tuned to one document, coordinates measured off a
  filed PDF, system fonts, aggregate scores, claiming a page was reviewed that you did not look at, new Python.
  Never set "status": "done" in any court.json. Do not touch files outside {folder}/.

VERIFY (must pass before you submit)
  just contribute verify {id}
  Needs typst and poppler on PATH: sh tools/bootstrap.sh, then export PATH="$HOME/.local/share/formbook/env/bin:$PATH"

SUBMIT
  just contribute submit {id}        (commits, pushes contrib/{id}, opens the PR; falls back to a compare URL)
  If you cannot finish, release the claim: delete the remote branch contrib/{id} (git push origin --delete contrib/{id})
  or close your draft PR, and say what blocked you in the PR or branch description.
"##,
        id = b.id,
    ));
    s
}

/// Space-terminated list of the court's doc-type folders that hold both typst/ and usage/.
fn siblings(court_path: &str) -> String {
    let mut dirs: Vec<_> = std::fs::read_dir(court_path)
        .into_iter()
        .flatten()
        .flatten()
        .filter(|e| e.path().join("typst").is_dir() && e.path().join("usage").is_dir())
        .map(|e| format!("{court_path}/{} ", e.file_name().to_string_lossy()))
        .collect();
    dirs.sort();
    dirs.concat()
}

pub fn run(ctx: &Ctx, args: &[String]) -> Res<ExitCode> {
    let id = args.first().ok_or_else(usage)?;
    let wl = load_worklist(ctx, Net::Offline)?;
    let u = unit_json(&wl, id).ok_or_else(|| die(format!("no such unit: {id}")))?;
    let (alias, cp, dt) = (
        field(&u, "alias"),
        field(&u, "court_path"),
        field(&u, "doctype"),
    );
    let index = read_json("data/index.json");
    let docs = read_json("data/doctypes.json");
    let min = min_pages(&dt);
    let siblings = siblings(&cp);
    let b = Brief {
        id,
        kind: &field(&u, "kind"),
        alias: &alias,
        court_path: &cp,
        doctype: &dt,
        title: &field(&u, "title"),
        level: &field(&u, "level"),
        court_name: index["courts"][alias.as_str()]["name"]
            .as_str()
            .unwrap_or(""),
        what: docs["doctypes"][dt.as_str()]["what"].as_str().unwrap_or(""),
        min: &if min.fract() == 0.0 {
            format!("{}", min as i64)
        } else {
            min.to_string()
        },
        siblings: &siblings,
        has_rules: Path::new(&cp).join("rules.md").is_file(),
        has_readme: Path::new(&cp).join("README.md").is_file(),
    };
    print!("{}", text(&b));
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample(kind: &'static str) -> Brief<'static> {
        Brief {
            id: "ca1.amicus-brief",
            kind,
            alias: "ca1",
            court_path: "courts/c1",
            doctype: "amicus-brief",
            title: "Amicus brief",
            level: "appeals",
            court_name: "First Circuit",
            what: "a friend-of-the-court brief",
            min: "8",
            siblings: "courts/c1/opening-brief ",
            has_rules: true,
            has_readme: false,
        }
    }

    #[test]
    fn header_and_optional_lines() {
        let t = text(&sample("new-template"));
        assert!(t.starts_with("TASK ca1.amicus-brief  [new-template]\nAmicus brief for First Circuit (ca1, level: appeals)\n"));
        assert!(t.contains("reuse patterns from: courts/c1/opening-brief \n"));
        assert!(t.contains("already researched: courts/c1/rules.md\n"));
        assert!(!t.contains("Court notes:"));
        assert!(t.contains("1. Research the governing rules for a amicus-brief in ca1"));
        assert!(t.contains("just contribute verify ca1.amicus-brief"));
        assert!(t.contains("export PATH=\"$HOME/.local/share/formbook/env/bin:$PATH\""));
    }

    #[test]
    fn one_section_per_kind() {
        assert!(text(&sample("add-exemplar")).contains("DO (kind add-exemplar)"));
        let d = text(&sample("deepen"));
        assert!(d.contains("reaches at least 8 pages"));
        assert!(d.contains("(about 8+ pages)"));
        assert!(!text(&sample("other")).contains("\nDO (kind"));
    }
}
