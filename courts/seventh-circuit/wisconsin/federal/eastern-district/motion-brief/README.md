# wied: motion-brief

Doc type: **motion-brief**, the memorandum (brief) in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Wisconsin (`wied`).
Folder: `courts/seventh-circuit/wisconsin/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (14 pp.; the overlay and cover-structure reference). Second filer: `FILED-EXAMPLE-motion-brief-2.pdf` (9 pp.). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the whole brief, transcribed from the text layer) |
| render | ok (2026-10-29, fb-595.17.16): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 13 pages each, Times New Roman regular, bold, italic, bold italic only (embedded), no warnings |
| pages reviewed | 13 of 13 (text layout and word boxes; the latex and docx renders break every line and page as typst does) |

## Governing rules

Primary source: Local Rules of the United States District Court for the Eastern District of Wisconsin, "Local Rules 2010-0201, Amended 2026-0729" (71 pp.), fetched 2026-10-14 from https://www.wied.uscourts.gov/sites/wied/files/documents/Local%20Rules%202010-0201-Amended%202026-0729.pdf (linked from https://www.wied.uscourts.gov/local-rules-and-guidance).

Federal Rules of Civil Procedure, from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp), fetched 2026-10-14: Rule 12(b).

| Rule | Requirement | Where it is in the layout |
|---|---|---|
| General L.R. 5(a)(5) | 8½ × 11 inch paper; double-spaced text; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced; margins of at least one inch on all four sides; page numbers may go in the margins. | The base (`lib/layouts/frcp-motion-brief.yaml`): letter paper, 1 in margins, 24 pt body pitch, 13.8 pt single lines, page number centered at the foot. Overlay (`typst/layout.yaml`): block quotations single-spaced, 0.5 in each side, 12 pt above and below; argument and sub-headings single-spaced. |
| General L.R. 5(a)(6) | A proportionally spaced face must include serifs (sans-serif allowed in headings and captions) and be 12-point or larger. No face is named. | `font-family = ("Times New Roman", "Liberation Serif")` in `typst/wied-motion-brief.typ`; the base's 12 pt everywhere. No face named by the rule, so Times New Roman, the house standard (`docs/FONTS.md`), in all three engines. |
| General L.R. 5(a)(7) | Plain roman type; italics or boldface for emphasis; case names italicized or underlined. | Body is roman; `*...*` in markdown renders italic. The sample italicizes case names; see gap 1. |
| General L.R. 5(c) | Signature block: `s/ [attorney name]`, attorney name, bar number, attorney for (party), firm, address, telephone, e-mail. | `closing` in `typst/layout.yaml`, one `s/` line per signer. |
| Civil L.R. 7(a) | A motion must state the rule it is made under and be accompanied by a supporting memorandum (or a certificate that none will be filed). | The brief is the memorandum; the motion itself is a separate document, not produced here. |
| Civil L.R. 7(f) | The principal memorandum in support of a motion must not exceed 30 pages; a reply must not exceed 15 pages; the caption, cover, tables and signature block are excluded from the count. | `eval.yaml` `page_limit: 30` (DEF-LEN-001, every engine; the whole render counted, the stricter reading). The sample is 13 pages. |
| Civil L.R. 7(j) | Unreported decisions may be cited; an unavailable one must be served on the parties (and on pro se parties). | Content only. |
| Civil L.R. 7(k) | Notice of Supplemental Authority is a separate filing without argument. | Not produced here. |
| Fed. R. Civ. P. 12(b)(6) | Motion to dismiss for failure to state a claim. | The brief's standard of review and argument are the sample's content, not the template's. |

Not produced by this template (separate filings, not part of the brief): the motion itself (Civil L.R. 7(a)), any declaration or exhibits, the proposed order (Civil L.R. 7(a)), and any certificate of service. A certificate of service is not required for papers served through ECF (Civil L.R. 5); a paper served on a pro se party needs one. The ECF header is added by the court's electronic system at filing and is not added here.

## Layout

Since fb-595.17.16 the folder is on the generic federal district brief: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay (each choice cited there), `typst/wied-motion-brief.typ` names the face, and `lib/typst/xdoc.typ` sets the layout; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Court title, centered bold caps (`{xd.court}` / `{xd.district}`, layout constants), a rule across the page; the caption with the party names on the left (designation 0.5 in in a single line below, "v." at the margin a single line from each, no box: both exemplars) and "Case No." beside them, centered on their height; a rule, the document title centered in bold caps, a rule (the same-id exemplar's three rules; the second filer has none).
- Body paragraphs are not numbered. A first-line indent of 0.5 in; double-spaced (24 pt pitch).
- Section headings (`#`, e.g. INTRODUCTION, ARGUMENT, CONCLUSION): centered bold caps on the body pitch, 12 pt above.
- Argument headings (`##`): bold, single-spaced, numbered `I.`, `II.` by the template in a 1 in label box, wrapped lines hung under the text; 12 pt above, 6 pt below.
- Sub-headings (`###`): bold italic, single-spaced, 0.5 in in, numbered `a.`, `b.` by the template (restarting under each argument heading), 6 pt above and below.
- Block quotations (`>`): single-spaced, indented 0.5 in on each side, 12 pt above and below.
- Signature block, kept with the last paragraph: "Dated this ... day of ..." (sample field `date`) at the paragraph indent, then 3 in from the margin the firm, role, `s/` line, name and bar number for each signer, address, telephone and each signer's e-mail.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names: [...], designation}`; "v." is inserted between parties), `document_title`, `jury_demand` (not used by briefs; keep false), `date` (the words after "Dated this", e.g. `7th day of October, 2026`), `signature` (`firm`, `role`, `signers: [{name, bar, email}]`, `address: [lines]`, `telephone`).
- Body: `#` = section heading; `##` = argument heading (its text only: the template numbers it); `###` = sub-heading (its text only); `>` = block quotation; any other paragraph is a paragraph.
- Case names and signals (*Id.*, *See*) are italic in the markdown (`*...*`).

## Known gaps and open choices

1. **Case-name italics are not from the exemplar.** General L.R. 5(a)(7) requires case names in italics or underline. The Nocams text layer carries no italic information, so the exemplar's roman case names could not be copied as-is. The sample italicizes case names as the rule requires. The template is rule-driven; the italics come from the sample's markdown, not the template.
2. **Font.** Same as the complaint: the rule names no face, so Times New Roman 12 pt, the house standard (`docs/FONTS.md`) and the exemplars' face, in both engines.
3. **No table of contents or table of authorities.** E.D. Wis. Civil L.R. 7 does not require one for a brief under 30 pages (the Nocams and Schmidt briefs have none). The layout sets none.
4. **Second filer.** The cover-structure check and the overlay compare against the same-id exemplar (Nocams). Schmidt was checked by reading its layout (caption, roman-numeral headings, conclusion, signature).
5. **Gate scripts.** Since fb-595.17.16: `sh tools/check.sh <this folder>` exits 0 on typst (12 passed), latex (15) and docx (16), 0 failed (DEF-LEN-001 13 of 30 pages); XENG-001..003 PASS on latex and docx (344/344 lines, 13 = 13 pages); DEF-COVER-002 PASS on all three (3 rules vs 3, 0 differences), so the folder left `data/cover-structure-baseline.txt`.

## Review of the rendered pages (`usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx.pdf`, 13 pages each)

Re-rendered on the FRCP base (fb-595.17.16) and reviewed page by page as text layout and word boxes (`pdftotext -layout`, the cover-structure measurer); the latex and docx renders break every line and page as typst does (XENG-001..003).

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, rule, caption (parties; case number centered beside them), rule, document title, rule, opening paragraph, INTRODUCTION. | Pass. ARGUMENT moves whole to page 2 (kept with its text). |
| 2 | ARGUMENT, I. STANDARD OF REVIEW, sub-heading a., paragraphs. | Pass. The label box holds the numeral; sub-heading 0.5 in in. |
| 3 | Sub-heading b.; II. heading in two lines, hung under its text. | Pass. |
| 4 | Section II; III. heading in two lines. | Pass. |
| 5 | Section III paragraphs (Tuggle, Edwards, Katz citations). | Pass. ". . ." kept with the word before it. |
| 6 | Section III (Knotts, Tuggle, Carpenter). | Pass. |
| 7 | Section III end, IV. PLAINTIFFS LACK STANDING, sub-heading a. | Pass. |
| 8 | Sub-heading a. paragraphs. | Pass. |
| 9 | Sub-heading b. (associational standing). | Pass. |
| 10 | Associational standing, paragraphs. | Pass. |
| 11 | Sub-heading c. (taxpayer standing). | Pass. |
| 12 | Block quotation (single-spaced, indented 0.5 in both sides), the citation paragraph after it. | Pass. |
| 13 | CONCLUSION, its paragraph, "Dated this 7th day of October, 2026." and the signature block with two signers. | Pass. The last paragraph kept with the signature block. |

## Engines

**typst** is the primary engine (`typst/main.typ`, `typst/wied-motion-brief.typ`, `typst/layout.yaml`). **latex** (`latex/template.tex`, `latex/xdoc.lua`) and **docx** (`docx/reference.xml`, `docx/xdoc.lua`) are generated by `fb engines gen` from the merged layout (`fb engines gen --check` fails on a stale one) and set by the shared code (`lib/pandoc/xdoc.lua`, `lib/latex/xdoc.lua`, `lib/docx/xdoc.lua`). The old docx filter `docx/wied.lua` is removed. The `.docx` converts in LibreOffice without error; not opened in Word.
