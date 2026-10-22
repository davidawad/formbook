# Adversary complaint (okeb)

Complaint commencing an adversary proceeding in the U.S. Bankruptcy Court for the Eastern District of Oklahoma. Typst template in `typst/` (entry point `typst/main.typ`, layout in `typst/okeb-adversary-complaint.typ`) and a Word template in `docx/` (`reference.xml`, `okeb-adversary-complaint.lua`), both on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; fb-595.68.32). No LaTeX engine for this doc type.

| Item | State |
|---|---|
| Template | `typst/main.typ`, `typst/okeb-adversary-complaint.typ` (rule-driven, no case text) |
| Exemplars | 2 filed PDFs in `usage/`, both from one filer (the Chapter 7 trustee's counsel). See `usage/SOURCE.md` |
| Sample | `usage/INPUT-adversary-complaint.md`, transcribed from `FILED-EXAMPLE-adversary-complaint.pdf` (word set checked against the filed text) |
| Render | `usage/OUTPUT-adversary-complaint.typst.pdf` and `.docx` / `.docx.pdf`, 7 pages each, vendored Times New Roman only, no warnings; the docx breaks every line and page where typst does (XENG-001..003 PASS, 157/157 lines) |
| Overlay | `usage/OVERLAY-apache-complaint.pdf` and `.txt`, `sh tools/overlay.sh` (see "Overlay") |
| Gate stamp | `sh tools/check.sh <this folder>`: typst 9 checks passed, 0 failed; `--engine docx` 13 passed, 0 failed (`usage/.check-typst.txt`, `usage/.check-docx.txt`); `eval.yaml` sets `params.cross_engine: gate` |

## Rules

Sources were read on 2026-10-14. Local rules: the Eastern District of Oklahoma's *Local Rules of the United States Bankruptcy Court for the Eastern District of Oklahoma*, effective December 1, 2009, revised through 10/22/2019 (the last revision date printed in the PDF), <https://www.okeb.uscourts.gov/sites/okeb/files/LOCAL%20RULES%20Printable%20Version.pdf>. The PDF carries a 2026-03-03 creation date and no other date. Federal rules: FRBP 7010, <https://www.law.cornell.edu/rules/frbp/rule_7010> (amended eff. Dec. 1, 2024), and FRCP 10(b), <https://www.law.cornell.edu/rules/frcp/rule_10>.

Kind: **M** = mandated by a rule; **C** = convention; **A** = author responsibility.

| ID | Requirement | Kind | Source | Where in the template |
|---|---|---|---|---|
| ADV-FORM-001 | Paper 8.5 × 11 in | M | LBR 9004-1(A) | `page(paper: "us-letter")` |
| ADV-FORM-002 | Type no less than 12 pt, footnotes included | M | LBR 9004-1(A) | `type-size`; `show footnote.entry` |
| ADV-FORM-003 | Margins no less than 1 in | M | LBR 9004-1(A) | `page-margin = 1in` |
| ADV-FORM-004 | One side of the page only | M | LBR 9004-1(A) | PDF output is single-sided |
| ADV-FORM-005 | Pleadings double spaced | M | LBR 9004-1(A) | `pitch-double = 27.6pt`: every body line a 27.6 pt box (Word's double, 2 x 1.15 x 12 pt); caption, property lists, footnotes and signature in 13.8 pt single lines |
| ADV-FORM-006 | Signature block: attorney's full name, bar number, address, email, telephone, fax, party represented, beneath the signature line | M | LBR 9004-1(C) | `signature-block()` (fax line in the sample frontmatter) |
| ADV-CAP-001 | Caption: name of the Court, title of the case, bankruptcy case number and the judge's three initials, chapter directly under the case number, adversary number | M | LBR 9004-2 | `caption()`, right column; judge initials from frontmatter `judge` (`___` placeholder in the sample) |
| ADV-CAP-002 | Caption substantially conforms to Official Form 416D | M | FRBP 7010 | `caption()`, two-column party/number layout |
| ADV-CAP-003 | Title clearly describes the document | M | LBR 9004-2 | "COMPLAINT" centered, bold, caps |
| ADV-PLD-001 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances | M | FRCP 10(b), applied by FRBP 7010 | `complaint-body()`, numbered consecutively across the whole complaint |
| ADV-PLD-002 | Commenced by a complaint in compliance with Official Form 416D, with the filing fee | M | LBR 7001-1(A) | the template is the complaint; the fee is not on the document |
| ADV-PLD-003 | Each pleading contains only one request for relief (exception: combined motions under §§ 362, 554, 361) | M? | LBR 9004-1(G) | not enforced by the template; see "Open questions" |
| ADV-PLD-004 | Attachments enlarged or reduced to the 9004-1(A) size unless unreadable | M | LBR 9004-1(B) | not rendered by the template (exhibits are separate files) |
| ADV-CERT-001 | Certificate of mailing or service, where required | M | LBR 9004-1(E) citing LBR 5005-1(E), 2002-1(E), 7004-1 | not in the template; see "Open questions" |
| ADV-INSTR-001 | Comply with the Court's Instructions Governing Adversary Proceedings (Local Form 7001-1(B)) | M | LBR 7001-1(B) | not reviewed; see "Open questions" |

`M?` marks an open reading of the rule (see below). Nothing in this table is a tier-2 convention: the court's form requirements are all in the rows above.

## Markdown contract

The sample is `usage/INPUT-<id>.md`. It starts with a YAML frontmatter block, then the body. `typst/okeb-adversary-complaint.typ` panics if a required field is missing.

Frontmatter:

| Field | Required | Use |
|---|---|---|
| `title` | yes | document title, shown centered under the caption (also the PDF title) |
| `debtor` | yes | debtor name in the caption, with its comma (a string or a list of lines) |
| `debtor_role` | no | the designation under the debtor (default `Debtor.`) |
| `parties` | yes | list of `{names, role}`; one block per party, `v.` between blocks |
| `case_number` | yes | bankruptcy case number |
| `judge` | no | judge's three initials after the case number, shown as `-XXX` |
| `chapter` | yes | chapter number, shown directly under the case number |
| `adversary_number` | yes | adversary number |
| `signature` | yes | `electronic` (the `s/` name) and `lines` (the block under it, one line each) |
| `date` | no | "Dated:" line above "Respectfully submitted" |

Body (cmarker in typst, pandoc in docx), in blank-line-separated chunks: paragraphs are unnumbered and first-line indented half an inch, double spaced (27.6 pt lines). A chunk `N. ...` is an allegation, numbered by the template consecutively across the whole complaint (the numbers typed in the markdown are ignored). A chunk of `- ` lines is a property list: one single-spaced line each, one inch in, a single line above and below. `#` and `##` headings render as bold capitals centered at the body pitch, kept with the text after them. A footnote (`[^x]`, its definition anywhere) is rendered at 12 pt in single lines under a 30 % rule. Caption and signature values are text, not markdown. The last block of the body is kept on the page of the signature block, which is never split.

## Overlay

`usage/OVERLAY-apache-complaint.pdf` compares our render with `FILED-EXAMPLE-adversary-complaint.pdf` (the default exemplar: `tools/overlay.sh` takes the first PDF in `usage/`). Red is our render, blue is the filed page, black is both. Pages pair by shared words (word overlap 52% to 81% on the earlier 6-page render; `.overlay/`, not committed; the current render has 7 pages). The overlay is a diagnostic, not a score.

What it shows:

- Caption: the filed caption uses a column of `)` marks and a bold party list. Ours uses a vertical rule and a regular-weight party list. Both are one filer's choice (the same trustee's firm filed both exemplars), so this is not judged a convention.
- Body: ours is ragged right; the filed text is justified. One filer's choice (tier 3), not chased.
- Footer: the filed pages carry the CM/ECF header and footer ("Case 26-08003 Doc 1 Filed 02/27/26 ..."), which the court's system adds on filing. The template does not reproduce it.
- Signature: the filed page 7 has the signature alone on the last page, with "s/Kelley G. Loud" on a rule. Ours sets it on page 7 with the prayer heading and paragraph (the last body block is kept with it), and "s/ Kelley G. Loud" has no rule.
- Paragraph numbers: the filed complaint numbers the Background paragraphs again from 1 (paragraphs 1 to 3 in Parties, then 1 to 18 in Background). The template numbers all paragraphs consecutively (1 to 36), as FRCP 10(b) style allows. The difference is intentional; it is a visible departure from the exemplar.

Known tool defect (not fixed here, `tools/` is shared): `tools/overlay.sh` writes `OVERLAY-<id>.pdf` with pages of 240.9 × 311.8 pt instead of 612 × 792 pt (the final `magick -density 100` step). The content is intact at high zoom (rasterized at 400 dpi it reads correctly), but the overlay PDF is scaled to about 39% of letter size. The defect belongs in `tools/overlay.sh`; this court folder does not change it.

## Exemplar search

Both exemplars are on CourtListener RECAP (`court=okeb`), recorded with their SHA-256 in `usage/SOURCE.md`. `usage/SOURCE.md` also records searches for complaints by other filers (Farmers Insurance, Tinker FCU, Vision Bank, AVB Bank, Blackbeard Marine/Ramon) that found no archived complaint (document 1 not in RECAP). That search was not repeated in this checkout.

## Open questions and gaps

- **One filer only.** Both exemplars are the same trustee's firm. The tier-2 rule asks for exemplars from different filers, so tier 2 cannot be judged yet. The caption layout and body alignment are therefore not settled as convention.
- **One sample.** The template is tuned to one transcription. A second, structurally different sample (for example a complaint with a certificate of service and a second defendant) is not written yet.
- **Certificate of service (ADV-CERT-001).** Neither exemplar has one. LBR 7004-1(A) requires a service certificate that names the individual served when a complaint is served on a corporation (Apache is an LLC). That certificate is outside this template for now; add it when a filer's complaint includes one.
- **One request for relief (ADV-PLD-003).** LBR 9004-1(G) says each pleading contains one request for relief, with an exception for combined motions. The exemplar has three counts, each ending with a WHEREFORE clause, and the template follows that filed practice. Read 9004-1(G) as applying to motions, or ask the clerk. Not enforced by the template.
- **Judge initials after the adversary number.** LBR 9004-2 also mentions the judge's initials after the adversary number, "if any." The template shows judge initials only after the case number, as the frontmatter `judge` field. Confirm with the clerk before adding them to the adversary line.
- **Local Form 7001-1(B).** LBR 7001-1(B) incorporates the Court's Instructions Governing Adversary Proceedings. These were not read for this template.
- **Official Form 416D.** The caption is checked against FRBP 7010 and LBR 9004-2. The form text itself was not fetched.
- **Engines.** typst and docx are built and gated against each other (XENG-001..003). No latex engine.
- **Gate machinery.** `tools/check.sh` runs the default checks (no `checks.yaml`); no `reviews/` entry exists for this doc type.

## Engines

Both engines follow the shared cross-engine layout model (fb-595.68.32): Times New Roman 12 pt (LBR 9004-1(A) names no face; the docx names the typst face through `{font}`), every line an exact box of its pitch (27.6 pt double-spaced body, LBR 9004-1(A); 13.8 pt single lines for the court, caption, property lists, footnotes and signature), explicit spaces between blocks, first-fit ragged-right breaking without kerning, ligatures or hyphenation.

- typst: `typst/okeb-adversary-complaint.typ` (`show: xengine.with(pitch: 27.6pt)`). The caption is a one-row table, the party column ruled at its right; every caption and signature line a block of its own (no forced line breaks); the title and headings bold centered capitals at the body pitch, sticky; the signature block a double line below the body, never split, the last body block kept with it.
- docx: `docx/reference.xml` (`base="xengine"`, 24 half points, body 552, single 276 twips, footer 720; Body Text Note without widow control, Body Text Keep, a Footnote Text that splits) and `docx/okeb-adversary-complaint.lua` (`require("docx.xengine")`): every paragraph with the typst pitch and spaces in twips; the caption an OOXML table; the signature block a table row that cannot split, after an empty double line kept with it; the caption and signature strings from `$FORMBOOK_META` as written. `docx/build-reference.sh` and the binary `reference.docx` are gone (`fb render` builds the reference). The docx had been set in EB Garamond, failing DEF-FONT-002 and TNR-EMBEDDED.

Results (2026-10-22): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (157/157 lines, 7 pages; `params.cross_engine: gate` in `eval.yaml`). All 7 pages of both renders viewed side by side: caption, title, headings, footnote, signature and page numbers alike.
