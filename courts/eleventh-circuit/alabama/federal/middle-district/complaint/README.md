# almd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Alabama (`almd`).
Folder: `courts/eleventh-circuit/alabama/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: two filed complaints from different filers, `usage/FILED-EXAMPLE-complaint.pdf` and `usage/FILED-EXAMPLE-complaint-2.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole Allstate complaint (caption, paragraphs 1 to 44, jury demand, signature block, service note), transcribed from the text layer |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 14 pages, `tools/render.sh` exit 0, no typst warnings, embedded fonts EB Garamond only |
| overlay | ok: `usage/OVERLAY-allstate-complaint.pdf` and `usage/OVERLAY-allstate-complaint.txt` (against the Allstate exemplar) |
| pages reviewed | 14 of 14: every page rendered at 60 dpi and viewed after the last template change |

File names follow the repo's tools and `CLAUDE.md` file roles (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.md` names in the brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Verified 2026-10-14. Sources:

- **M.D. Ala. Local Rules**: https://www.almd.uscourts.gov/sites/default/files/forms/ALMD%20Local%20Rules.pdf, linked from https://www.almd.uscourts.gov/forms/local-rules, which gives "Effective Date: December 1, 2010". The PDF we could read is a 2011 print ("All Rules for Review--Redacted"). The court site showed no newer rules PDF. **Verify against the current rules before relying on them.**
- **Federal Rules of Civil Procedure**: Cornell LII (https://www.law.cornell.edu/rules/frcp/rule_10, `rule_11`, `rule_5`), text checked 2026-10-14.

| ID | Source | Requirement | Kind | Where in the template |
|---|---|---|---|---|
| FRCP-10a | FRCP 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the title of a complaint names all parties. | M | `court`, `caption`, `title` in the frontmatter; `caption()` and `court-title()` |
| FRCP-10b | FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction in a separate count. | M (author) | Body text. Not checked mechanically. |
| FRCP-11a | FRCP 11(a) | Signed by at least one attorney of record, with the signer's address, e-mail and telephone. | M | `signature` in the frontmatter; `signature-block()` |
| LR-5.6 | M.D. Ala. LR 5.6 | 8-1/2 x 11 inch white paper, flat, not stapled; "double-spaced, except for quoted material"; each page numbered consecutively. | M | `page(paper: "us-letter")`, page numbers from `numbering: "1"`, body leading that gives a 32.2 pt baseline pitch at 14 pt (the double spacing of the exemplars) |
| LR-3.1a | M.D. Ala. LR 3.1(a) | A completed civil cover sheet (JS-44) with the initial complaint for a represented party. | M (author) | Not produced: a separate filing. |
| LR-7.1a | M.D. Ala. LR 7.1(a) | A Conflict Disclosure Statement with the initial pleading (form in Appendix A). | M (author) | Not produced: a separate filing. |
| LR-5.2a | M.D. Ala. LR 5.2(a) | Redact SSNs to the last four digits, minors' names to initials, dates of birth to the year, financial account numbers to the last four digits, and an individual's address to city and state where relevant. | M (author) | Not templated. See the note below. |
| FRCP-5d | FRCP 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." A complaint is served with a summons, so no certificate applies. | C | None in the template. |

The local rules set no typeface, type size, margin, or page limit (the full text was searched for "font", "point", "margin", "inch", "page"). Type size and margins are therefore tier 2 (convention), not tier 1.

Note on the exemplar: the Allstate filing prints a non-party's full street address (paragraph 1). The sample transcribes it as filed, because it is a transcription of a public record. It is not a model for a real filing, and LR 5.2(a) requires city and state only.

## Tier 1 (mandated form)

Built into the template: letter paper, one-inch margins, consecutive page numbers, double spacing (32.2 pt baseline pitch at 14 pt, measured from the rendered PDF), the FRCP 10(a) caption, the FRCP 11(a) signature block, and a jury demand section. Not built in, and each is a separate document: the JS-44 cover sheet (LR 3.1), the conflict disclosure statement (LR 7.1), and the redaction of identifiers (LR 5.2).

Mechanical checks: none in this folder. The brief did not ask for a `checks.yaml`. The only check run is an ad hoc word comparison: every word token of the sample body occurs in the PDF at least as often (`pdftotext` of the render against the markdown with the frontmatter removed). No body token is missing.

## Tier 2 (professional convention), judged against the two filed complaints

| Convention | Allstate (filer 1) | First Horizon (filer 2) | This template | Verdict |
|---|---|---|---|---|
| Caption: names left, ")" column, "Civil Action No." and "JURY DEMAND" right | yes | yes (")" column, case number right) | yes | matched |
| Court title centered and bold, three lines | centered, bold | not checked page by page | centered, bold | matched to Allstate |
| Body type size | 14 pt (32.2 pt pitch) | 12 pt (27.6 pt pitch) | 14 pt EB Garamond | ACCEPTED: the two filers differ; 14 pt is the Garamond size that reads like 12 pt Times |
| Body double-spaced, first-line indent | yes, yes | double-spaced (measured); indent not checked | yes, 0.5 in indent | matched to Allstate |
| Section headings centered, bold | bold and underlined | not checked page by page | centered, bold, no underline | ACCEPTED: underlining seen in one filer only |
| "/s/" signature with ASB number, firm, address, phone, e-mail | yes | not checked (last page not read) | yes | matched to Allstate |
| "Defendants to be served" block after the signature | yes | not checked | yes | matched to Allstate |

Overlay (`usage/OVERLAY-allstate-complaint.pdf`): pages are paired by text, and the page-to-page word overlap runs from 46% to 94%. The differences are paragraph flow, the type size and the leading, which put 14 pages in our render against 13 in the filed copy. That is tier 3. Page 1 (the caption and title) and the last page (the signature block) line up with the exemplar in order and position.

Accepted differences in the Gate-2 sense (one line each, no further action):

- ACCEPTED page 9: the exemplar's own paragraph numbering puts a lettered item at the head of paragraph 33 ("33. j."). The sample keeps it as filed.
- ACCEPTED page 14: the service address block starts a new page with the signature block, so the signature is never separated from it.

## Engines

- **typst** (primary): `typst/`, unchanged. Renders `usage/OUTPUT-complaint.typst.pdf` (14 pages).
- **docx**: `docx/reference.docx` (built by `sh docx/make-reference.sh`), `docx/almd.lua`. Writes `usage/OUTPUT-complaint.docx` from `usage/INPUT-complaint.md`. Needs pandoc, unzip, zip, xmllint and perl on PATH, and EB Garamond installed where the file is opened.
  - Matches the typst values, set in the reference and the filter: EB Garamond 14 pt; US Letter with 1-inch margins; body lines double-spaced at 32.2 pt exact, 0.5 in first-line indent, 23.1 pt between paragraphs; section heads centered and bold, single-spaced at 16.1 pt; the FRCP 10(a) caption as a borderless three-column table (3.4 in, 0.15 in, 2.95 in); the signature block with "/s/", the service note; a centered page number in the footer. Lettered items ("a.") are kept as typed text, as the typst template prints them.
  - Differs or unknown: none checked on a rendered page yet (see BLOCKED). Word and LibreOffice may break lines and pages differently from typst; the docx has no line numbers, pleading rules or cover page, because the complaint template has none.
  - Checked so far: the package unzips, every XML part is well formed, and the text reads back in order (`pandoc -f docx -t plain`).
  - BLOCKED: `BLOCKED: docx.pdf checks (Gates 0 to 3 on usage/OUTPUT-allstate-complaint.docx.pdf): LibreOffice (soffice) cannot be installed on this box. conda-forge has no LibreOffice package, and apt needs root. So no .docx.pdf was made, no page was rendered to PNG, and tools/check.sh --engine docx cannot run. Pages reviewed: 0 of 14.` The .docx must still be opened in LibreOffice and Word, with the result recorded under `## sample allstate-complaint docx` in a review file (none exists in this folder yet).

## Known gaps

- Only one complaint is transcribed (Allstate). The First Horizon complaint is an exemplar only.
- A verified complaint (First Horizon is verified) needs a verification block. The template has none.
- FRCP 8(a) content (jurisdiction, claim, demand) is the author's responsibility and is not checked.
- Exhibits, the JS-44 cover sheet and the LR 7.1 statement are not produced.
- Judge-specific standing orders on type size, page limits and format were not researched. The local rules text has no brief page limit.
- The local rules copy is effective 2010 (per the court's own page). It must be checked against the current rules.
- No machine check (`checks.yaml`, Gate 0 to 3) exists for this folder.
