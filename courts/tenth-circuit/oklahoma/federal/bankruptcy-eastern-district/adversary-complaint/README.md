# Adversary complaint (okeb)

Complaint commencing an adversary proceeding in the U.S. Bankruptcy Court for the Eastern District of Oklahoma. Typst template in `typst/` (entry point `typst/main.typ`, layout in `typst/okeb-adversary-complaint.typ`). LaTeX and Word engines are not built for this doc type.

| Item | State |
|---|---|
| Template | `typst/main.typ`, `typst/okeb-adversary-complaint.typ` (rule-driven, no case text) |
| Exemplars | 2 filed PDFs in `usage/`, both from one filer (the Chapter 7 trustee's counsel). See `usage/SOURCE.md` |
| Sample | `usage/INPUT-adversary-complaint.md`, transcribed from `FILED-EXAMPLE-adversary-complaint.pdf` (word set checked against the filed text) |
| Render | `usage/OUTPUT-adversary-complaint.typst.pdf`, 6 pages, `sh tools/render.sh` (no typst warnings) |
| Overlay | `usage/OVERLAY-apache-complaint.pdf` and `.txt`, `sh tools/overlay.sh` (see "Overlay") |
| Gate stamp | none: `checks.yaml` and `tools/check.sh` do not exist for this doc type yet |

## Rules

Sources were read on 2026-10-14. Local rules: the Eastern District of Oklahoma's *Local Rules of the United States Bankruptcy Court for the Eastern District of Oklahoma*, effective December 1, 2009, revised through 10/22/2019 (the last revision date printed in the PDF), <https://www.okeb.uscourts.gov/sites/okeb/files/LOCAL%20RULES%20Printable%20Version.pdf>. The PDF carries a 2026-03-03 creation date and no other date. Federal rules: FRBP 7010, <https://www.law.cornell.edu/rules/frbp/rule_7010> (amended eff. Dec. 1, 2024), and FRCP 10(b), <https://www.law.cornell.edu/rules/frcp/rule_10>.

Kind: **M** = mandated by a rule; **C** = convention; **A** = author responsibility.

| ID | Requirement | Kind | Source | Where in the template |
|---|---|---|---|---|
| ADV-FORM-001 | Paper 8.5 × 11 in | M | LBR 9004-1(A) | `page(paper: "us-letter")` |
| ADV-FORM-002 | Type no less than 12 pt, footnotes included | M | LBR 9004-1(A) | `type-size`; `show footnote.entry` |
| ADV-FORM-003 | Margins no less than 1 in | M | LBR 9004-1(A) | `page-margin = 1in` |
| ADV-FORM-004 | One side of the page only | M | LBR 9004-1(A) | PDF output is single-sided |
| ADV-FORM-005 | Pleadings double spaced | M | LBR 9004-1(A) | `double-leading` (1.65 em, about 27.6 pt baseline pitch) |
| ADV-FORM-006 | Signature block: attorney's full name, bar number, address, email, telephone, fax, party represented, beneath the signature line | M | LBR 9004-1(C) | `signature-block()` (fax line in the sample frontmatter) |
| ADV-CAP-001 | Caption: name of the Court, title of the case, bankruptcy case number and the judge's three initials, chapter directly under the case number, adversary number | M | LBR 9004-2 | `caption()`, right column; judge initials from frontmatter `judge` (`___` placeholder in the sample) |
| ADV-CAP-002 | Caption substantially conforms to Official Form 416D | M | FRBP 7010 | `caption()`, two-column party/number layout |
| ADV-CAP-003 | Title clearly describes the document | M | LBR 9004-2 | "COMPLAINT" centered, bold, caps |
| ADV-PLD-001 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances | M | FRCP 10(b), applied by FRBP 7010 | `numbered-items()`, numbered consecutively across the whole complaint |
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
| `debtor` | yes | debtor name in the caption, with its comma |
| `parties` | yes | list of `{names, role}`; one block per party, `v.` between blocks |
| `case_number` | yes | bankruptcy case number |
| `judge` | no | judge's three initials after the case number, shown as `-XXX` |
| `chapter` | yes | chapter number, shown directly under the case number |
| `adversary_number` | yes | adversary number |
| `signature` | yes | `electronic` (the `s/` name) and `lines` (the block under it, one line each) |
| `date` | no | "Dated:" line above "Respectfully submitted" |

Body (cmarker): paragraphs are unnumbered and first-line indented. An ordered list is numbered by the template, consecutively, across the whole complaint (the numbers typed in the markdown are ignored). A bulleted list is a property list: indented and single spaced. `#` headings render as bold caps centered. A footnote is rendered at 12 pt.

## Overlay

`usage/OVERLAY-apache-complaint.pdf` compares our render with `FILED-EXAMPLE-adversary-complaint.pdf` (the default exemplar: `tools/overlay.sh` takes the first PDF in `usage/`). Red is our render, blue is the filed page, black is both. Pages pair by shared words: our pages 1 to 6 map to filed pages 1 to 6 (word overlap 52% to 81%; `usage/OVERLAY-apache-complaint.txt`). The overlay is a diagnostic, not a score.

What it shows:

- Caption: the filed caption uses a column of `)` marks and a bold party list. Ours uses a vertical rule and a regular-weight party list. Both are one filer's choice (the same trustee's firm filed both exemplars), so this is not judged a convention.
- Body: ours is ragged right; the filed text is justified. One filer's choice (tier 3), not chased.
- Footer: the filed pages carry the CM/ECF header and footer ("Case 26-08003 Doc 1 Filed 02/27/26 ..."), which the court's system adds on filing. The template does not reproduce it.
- Signature: the filed page 7 has the signature alone on the last page, with "s/Kelley G. Loud" on a rule. Ours sets it on page 6 with the prayer, and "s/ Kelley G. Loud" has no rule.
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
- **Engines.** Only typst is built. `latex/` and `docx/` are not built for this doc type.
- **Gate machinery.** No `checks.yaml`, `tools/check.sh` stamp, or `reviews/` entry exists for this doc type. The render, overlay, and page review in this README are the only verification.

## Engines

Docx engine (`docx/`): `docx/reference.docx` (built by `sh docx/build-reference.sh reference.docx`) and `docx/okeb-adversary-complaint.lua` (caption as a table with a vertical rule, consecutive numbered allegations, property lists, signature block). It matches the typst form in paper (letter, 1 in margins), type (EB Garamond 12 pt, footnotes included), double spacing (exact 27.6 pt), 0.5 in first-line indent, headings (bold, centered capitals at every level) and the centered page number in the footer.

Differences from typst: Word's line breaking and the caption table's border rendering are not checked; the typst vertical gaps are approximated with paragraph spacing; the typst form's ragged-right body is kept.

BLOCKED (docx engine, `usage/OUTPUT-adversary-complaint.docx` is written and valid XML, but the rest cannot run here):
- `docx.pdf` (Gates 0 and 1 on the LibreOffice PDF): soffice not installed on this box, and LibreOffice cannot be installed here (no conda-forge package, no root). `tools/render-docx.sh` fails at its soffice step.
- Visual review of the docx pages: BLOCKED for the same reason; pages reviewed: 0.
- Word open check (no repair prompt): not done, no Word here.
