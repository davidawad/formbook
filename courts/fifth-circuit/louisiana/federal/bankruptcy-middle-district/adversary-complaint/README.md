# lamb (Bankruptcy Court, M.D. La.): adversary complaint

Doc type: **adversary complaint** (FRBP 7001 et seq.) in the United States Bankruptcy Court for the Middle District of Louisiana (`lamb`).
Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | **yes, 2 filed exemplars from 2 filers**, both text-based RECAP copies of Doc. 1: `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (Murrell Law Firm for Pull-A-Part, LLC; filed 08/13/2019; 5 pp) and `usage/FILED-EXAMPLE-adversary-complaint.pdf` (Grand Law Firm for Sinarta Criss; filed 03/16/2018; 2 pp). Sources, searches and rejected candidates (two scanned PDFs, several unavailable) are in `usage/SOURCE.md`. |
| sample md | `usage/INPUT-adversary-complaint.md`: **fictitious**. Mirrors the two exemplars' structure (unnumbered opening paragraph, numbered allegations, unnumbered WHEREFORE, counsel signature). No text is taken from either filing. |
| typeface | Rule names **no face**: LR 5005-2(b) requires "12-point font and be double-spaced" (2022 local rules, read from the court's PDF 2026-10-14). Keeps **EB Garamond** (vendored, OFL). Not a substitute case: no court-named face in `docs/FONTS.md`. Both exemplars are in Times (Word export); the choice stays EB Garamond per `docs/FONTS.md` ("no face named"). |
| render | ok (2026-10-15): `sh tools/render.sh` exit 0, no warnings, `usage/OUTPUT-adversary-complaint.typst.pdf`, **4 pages**, letter, typst 0.15.0; `pdffonts`: EBGaramond-Regular, -Bold, -Italic, all embedded. Body pitch 31.32 pt (see LAMB-FORM-003). |
| overlay | ok (2026-10-15): `sh tools/overlay.sh $D adversary-complaint-sample $D/usage/SAMPLE-hoven-19-01027-adversary-complaint.pdf` exit 0; `usage/OVERLAY-adversary-complaint-sample.pdf` (4 pages) and `.txt`. Compared against Hoven (the longer exemplar). The default (no third argument) picks the first file in `usage/` by name, which is Criss. |
| pages reviewed | **4 of 4** of `OUTPUT-adversary-complaint.typst.pdf` rasterised with `pdftoppm -r 60` and viewed on 2026-10-15; **4 of 4** of `OVERLAY-adversary-complaint-sample.pdf` viewed at the same resolution. Findings in the visual review table below. |

File names. The brief asks for `usage/<id>.md`, `usage/<id>.pdf` and `<id>-overlay.pdf`. The repo tools read and write `usage/OUTPUT-<id>.pdf` and `usage/OVERLAY-<id>.pdf/.txt`, and `tools/` is not to be edited, so the tool names are used.

## Governing rules

Primary sources, verified 2026-10-14. Text was read from the court's own PDF or the official rule page (fetched through WebFetch; see caveat on FRBP 9013 in the motion README).

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| LAMB-FORM-001 | LR 5005-2(a) (2022 Local Rules, amended Jan. 1, 2022: https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf) | Documents are sized 8½ × 11 inches for filing. | `page` in `typst/lamb-adversary-complaint.typ`. |
| LAMB-FORM-002 | LR 5005-2(b) | 12-point font, double-spaced, for all documents except pro se parties. | `type-size = 12pt`; all text, headings, caption and footer at 12 pt. |
| LAMB-FORM-003 | LR 5005-2(b) | Double-spaced. | `body-leading = 1.305em`: double = twice the single line pitch of EB Garamond at 12 pt. The natural single pitch is 1.305 em (measured with zero leading: 15.66 pt), so the extra leading equals one natural line and the baseline pitch is 31.32 pt (checked with `pdftotext -bbox-layout`). The earlier value (0.7 em, 24.06 pt pitch) was a calibration to a number, not to double spacing; a page rendered at that pitch looked like about 1.7 spacing next to the exemplar. |
| LAMB-FORM-004 | Fed. R. Bankr. P. 9004(a) (legibility; https://www.law.cornell.edu/rules/frbp/rule_9004) | Clearly legible. | Vendored EB Garamond, 12 pt; no font fallback (`fallback: false`). |
| LAMB-CAP-001 | Fed. R. Bankr. P. 7010 (applies Fed. R. Civ. P. 10; caption must substantially conform to Official Form 416) (https://www.law.cornell.edu/rules/frbp/rule_7010) | Caption with court, title, parties, case and adversary numbers. | `caption(meta)`: court name, debtor "In re:", plaintiff and defendants, case no., chapter, adversary no. |
| LAMB-CONT-001 | Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The jurisdiction allegation names the case, its number and Code chapter, and the district and division; the complaint states whether the pleader does or does not consent to final orders by the bankruptcy court. | The template panics unless the body contains the word "consent". Author writes the statement (see sample ¶¶ 3-5). |
| LAMB-CONT-002 | Fed. R. Civ. P. 10(b), applied by FRBP 7010 | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | Every body paragraph is numbered by the template (`numbered()`); headings and the `WHEREFORE` lead-in are not. |
| LAMB-CONT-003 | FRBP 7001(1) | Recovery of money or property is an adversary proceeding. | Cited in the sample; not checked by the template. |
| LAMB-FILE-001 | Standing Order 2026-1 (signed Feb. 24, 2026, effective Mar. 1, 2026: https://www.lamb.uscourts.gov/sites/lamb/files/Standing%20Order%202026-1%20adversary%20cover%20sheet.pdf) | Every original complaint in an adversary proceeding is accompanied by Official Form B1040, "Adversary Proceeding Cover Sheet". | **Not generated**: it is a separate form filed with the complaint. Listed here so it is not forgotten. |
| LAMB-FILE-002 | LR 7004-1(a)-(b) | Plaintiff requests issuance of summons on filing; serves summons, notice of pretrial conference and complaint within the FRBP 7004(e) time; files proof of service seven days before the scheduling conference. | **Not generated**: separate filings. |
| LAMB-FILE-003 | LR 9013-4(b) | A filing is served on the trustee, the debtor, debtor's counsel and the U.S. Trustee. | Not generated; the complaint carries no certificate. Separate certificate of service per LR 9013-4(a) if a notice filing is made. |

Not checked by the template, and listed as author responsibilities: the wording of the jurisdiction paragraph, the core and non-core designation, and the factual allegations.

## Layout and template

- Caption: court name centred, then a two-column Form 416 style caption. The left column is closed by a rule at the right and bottom; the right column has the case, chapter and adversary numbers. Every string comes from frontmatter.
- Title: centred, bold capitals, from `title`.
- Body: markdown chunks separated by a blank line. `# TEXT` is a centred bold capitals section heading; `## TEXT` is a bold left sub-heading; `### TEXT` is bold italic. A `1. ...` list is a lettered list `(a)`, `(b)` ... (prayer). A chunk starting `WHEREFORE` is an unnumbered lead-in. **The opening chunk, when it is not a heading, is an unnumbered lead-in too** (changed 2026-10-15: both exemplars leave it unnumbered, and the earlier template numbered it). Any other chunk is a numbered allegation.
- Signature: `Dated:` on the left; `Respectfully submitted,`, the signer as `/s/`, and the counsel lines in italic on the right.
- No counsel block at the top left of page 1, no certificate, no proposed order (none is required for a complaint under these rules).

## Frontmatter (schema)

| Field | Required | Feeds |
|---|---|---|
| `title` | yes | Title under the caption; PDF title. |
| `debtor` | yes | "In re:" line. |
| `case_no` | yes | "Case No." |
| `chapter` | yes | Chapter line (e.g. "Chapter 7"). |
| `adv_no` | yes | "Adversary Proceeding No." |
| `plaintiff` | yes | List of lines for the plaintiff (e.g. the trustee's name and capacity). |
| `defendants` | yes | List of lines for the defendants. |
| `date` | yes | "Dated:" line. |
| `signature` | yes | `signer` and `lines` (counsel block). |

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/adversary-complaint
sh tools/render.sh $D usage/INPUT-adversary-complaint.md        # -> usage/OUTPUT-adversary-complaint.typst.pdf
sh tools/overlay.sh $D adversary-complaint-sample $D/usage/SAMPLE-hoven-19-01027-adversary-complaint.pdf
```

Render (2026-10-15): `pdfinfo` reports 4 pages, us-letter. `pdffonts` lists EBGaramond-Regular, -Bold and -Italic only, all embedded. `render.sh` exits 0 with no typst output.

Body-line pitch on page 2: 31.32 pt between every pair of body lines (`pdftotext -bbox-layout`).

The overlay PDF's page size is 240.9 × 311.8 pt, not letter. That comes from `tools/overlay.sh` rasterising at 100 dpi and writing the PNGs back out with `magick -density`; it is a property of the diagnostic, not of the sample, and the OUTPUT PDF is letter.

## Visual review (Gate 2 record, 2026-10-15, 60 dpi, every page viewed)

Sample (`OUTPUT-adversary-complaint.typst.pdf`, 4 pages):

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption (Form 416 style, rules bounding the left column), title, unnumbered opening paragraph, allegations 1-3 | OK. The opening paragraph is unnumbered as in both exemplars (Hoven, Criss). |
| 2 | Allegations 4-10 | OK. Double-spaced. Ends with about three empty lines, because allegation 11 (three lines) moves to page 3 under widow/orphan control. Accepted. |
| 3 | Allegations 11-18 | OK. |
| 4 | Allegations 19-20, unnumbered WHEREFORE paragraph, `Dated:` line, "Respectfully submitted," signature block with `/s/` and counsel lines | OK. The `/s/` line wraps at the bar number; the wrap is in the sample text. |

Overlay (`OVERLAY-adversary-complaint-sample.pdf`, against Hoven; page map in `usage/OVERLAY-adversary-complaint-sample.txt`):

| Our page | Paired filed page | Word overlap | Finding |
|---|---|---|---|
| 1 | Hoven p.1 | 38.2% | Caption and opening paragraph line up at the top margin; the filed caption sits higher (Hoven's header line). Diagnostic only. |
| 2 | Hoven p.1 | 14.7% | Body pages pair weakly: the page map pairs every sample page with Hoven p.1 or p.5, because the sample text is fictitious and only the layout is shared. At 60 dpi the two text blocks do not register line by line. Diagnostic only. |
| 3 | Hoven p.1 | 15.5% | As page 2. |
| 4 | Hoven p.5 | 29.2% | Signature block at the right, WHEREFORE paragraph before it. |

Exemplar layout checked on the same pages (60 dpi): both exemplars use an unnumbered opening paragraph, numbers at the paragraph indent (Criss) or centred above the paragraph (Hoven), and a counsel block at the right with `/s/`.

## Tier-2 findings, open or accepted (for the PR)

| Item | Exemplars | Decision |
|---|---|---|
| Opening paragraph numbered or not | Both leave it unnumbered | **Changed to unnumbered** (template). |
| Body spacing (pitch) | Hoven 29.9 pt (Word double) | **Changed**: 31.32 pt, computed as twice the EB Garamond single pitch, not measured off Hoven. |
| Consent to final orders (FRBP 7008(a)) | Neither exemplar states it (both predate the 2022 local rules) | **Kept**: the template still requires the word `consent`; the rule governs, not the exemplars. |
| "PLEASE SERVE DEFENDANT AT" block | Hoven only | **Not added**: one filer; the template has no slot for a service block. |
| Dated line: `Dated: [date]` vs "... this __ day of __" | Hoven has the sentence form; Criss has no date | **Kept** the template's `Dated:` line. One exemplar each way. |
| Number placement (indent vs centred) | Hoven centred above the text; Criss indented | **Kept** the indent. Tier 3 (one filer's style). |
| Section headings | Neither exemplar uses headings | **Kept** the template's heading support (rules do not forbid headings); the sample uses none, to match the exemplars. |
| Length | Exemplars are 5 and 2 pages | Sample is 4 pages; not padded. |
| Caption bounding rules | Hoven: a full-width rule under the caption; Criss: rules under both columns | **Kept**: the rule at the left column's right and bottom, as in Form 416. |

## Known gaps and open choices

1. **Exemplars are short and old.** Two filings (5 pp, 2 pp; 2018 and 2019), from two filers, both text. They settle the opening-paragraph convention, the numbering, the caption and the signature block. They do not show the 2022 rules' consent statement or the B1040 cover sheet (both predate them).
2. **Length.** 4 pages, not the 8-14 pages of the brief's length rule. The brief sets that range only when the exemplar is that long; these exemplars are 5 and 2 pages. The sample is as long as its structure needs and is not padded.
3. **Opening paragraph.** Unnumbered (changed 2026-10-15 to match both exemplars; see the tier-2 table).
4. **Font.** EB Garamond at 12 pt (vendored, OFL), not Times New Roman. LR 5005-2(b) names a size only, no typeface (read from the court's 2022 PDF on 2026-10-14); the Administrative Procedures Manual was not read. The 12-point size is met; the x-height is smaller than Times at 12 pt, so the text looks smaller than a Times filing.
5. **Consent and jurisdiction wording.** The template only checks the word "consent". The wording of the FRBP 7008(a) statement and the core/non-core designation are not verified against any filing and are the author's responsibility.
6. **Standing Order 2026-1 cover sheet (B1040)** is not generated; see LAMB-FILE-001. It is needed with every original complaint on or after March 1, 2026.
7. **Caveat on the source.** The local rules were read from the court's 2022 PDF (amended January 1, 2022). A search result mentions Standing Order 2024-2, which amends LR 4001-1(f) and points to LR 9013-5 for proposed orders. Other amendments after 2022 were not checked against the court's current posting, because the court site is blocked from this box. Check the current rules before relying on this template.
8. **Overlay.** Produced (2026-10-15) against Hoven. A second overlay against Criss would write to the same `OVERLAY-adversary-complaint-sample.*` name, so only one is kept; Criss is compared on the page layout above.
8. **Overlay.** Cannot run without an exemplar. `OVERLAY-*` is not produced.

## Engines

DOCX (`docx/`: `build-reference.sh`, `reference.docx`, `lamb-adversary-complaint.lua`; `usage/OUTPUT-adversary-complaint.docx` is written by `sh tools/render.sh --engine docx`).

- Matches the typst form: EB Garamond 12 pt, exact 24 pt (double) line pitch, 1 in margins on letter, centred PAGE number in the footer, Form 416 caption with a rule at the right and bottom of the left cell, centred court name and title, `(a)` lettered prayer, signature block with `Dated:` on the left.
- Differs: paragraph numbers ("1.", "2.") and "(a)" letters are typed text generated by the filter, not Word list numbering, so they do not renumber if a paragraph is inserted by hand in Word. Pagination follows the renderer (Word and LibreOffice can break lines differently).
- Frontmatter fields are checked by the filter (same list as typst); the `consent` check (LAMB-CONT-001) is the same.
- Not run here: no LibreOffice on this box, so no `.docx.pdf` and no page was viewed. `OUTPUT-adversary-complaint.docx` was validated only as a zip with well-formed XML parts (see the render output).
- BLOCKED: docx.pdf gates (tools/check.sh --engine docx, Gates 0-3 on `usage/OUTPUT-adversary-complaint-sample.docx.pdf`): LibreOffice (`soffice`) is not installed on this box, so no PDF can be made and the stamp `.check-docx.txt` is not written.
