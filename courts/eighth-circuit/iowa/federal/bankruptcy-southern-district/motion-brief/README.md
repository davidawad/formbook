# iasb: motion with brief in support

Doc type: **motion with brief in support** (one document) in the United States Bankruptcy Court, Southern District of Iowa (`iasb`), under Fed. R. Bankr. P. 9013 and 9014 (a contested matter in the main case; the same form serves an adversary proceeding if `adv_number` is given).
Folder: `courts/eighth-circuit/iowa/federal/bankruptcy-southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, 2014; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption, lead-in, all four headings and the sub-headings in the order filed, all 34 numbered paragraphs, two footnotes, conclusion, signature, both verifications, certificate of service |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <dir> usage/INPUT-motion-brief.md`) |
| overlay | ok: `usage/OVERLAY-foods-motion.pdf` and `usage/OVERLAY-foods-motion.txt` (`sh tools/overlay.sh <dir> foods-motion`) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |
| BLOCKED | none. The local-rules premise of the brief does not hold (see Governing rules), which is recorded, not blocked. |

File names: the brief lists `usage/<id>.pdf` and `usage/<id>-overlay.pdf`. The shared tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, and the tools are not to be edited, so the render and overlay follow the tools' names.

## Governing rules

**The court has no local rules to cite.** The court's website says: "Effective August 4, 2003, this court's local rules were abolished. Attorneys and pro se parties shall consult the Federal Rules of Bankruptcy Procedure." (https://www.iasb.uscourts.gov/bankruptcy-rules, fetched 2026-10-14.) A search for "LBR 9013" for this court found nothing (courtrules.net: "not yet imported"). So there is no local rule on motion form, brief length, page limits, typeface, or a separate memorandum requirement. The brief's "per this court's local bankruptcy rules" is recorded as a finding; the template follows the national rules and the court's forms.

| Rule | Requirement | Kind | Where in the template | Source (verified) |
|---|---|---|---|---|
| Fed. R. Bankr. P. 9013 | A request for an order is made by written motion (unless made in a hearing or an exempt application). The motion states its grounds with particularity and sets forth the relief requested. It is served on the parties the rules specify. | M | Heading "III. Relief Requested" (author content; the template does not assert headings); lead-in paragraph; the motion's grounds are the numbered paragraphs. | https://www.law.cornell.edu/rules/frbp/rule_9013 (eff. 2024-12-01; restyled, stylistic only per the committee note), verified 2026-10-14 |
| Fed. R. Bankr. P. 9014(a) | Relief in a contested matter by motion; reasonable notice and an opportunity to be heard. | M | Not asserted by the template (notice is a matter of the case, not form). | https://www.law.cornell.edu/rules/frbp/rule_9014 (eff. 2024-12-01), verified 2026-10-14 |
| Fed. R. Bankr. P. 9014(b)(1) | The motion is served within the time prescribed by Rule 9006(d) and **in the manner for serving a summons and complaint under Rule 7004**. | M | `certificate-block()` prints the certificate. The template does not assert the method: the exemplar's certificate describes CM/ECF service only (see Known gaps 3). | same |
| Fed. R. Bankr. P. 9004(a) | Documents must be legible; commonly used abbreviations are acceptable. | M | Text is EB Garamond, 12 pt, black (`type-size`); no typeface is required (see Typeface below). | https://www.law.cornell.edu/rules/frbp/rule_9004 (eff. 2024-12-01), verified 2026-10-14 |
| Fed. R. Bankr. P. 9004(b) | Caption: the court's name, the case title, the case number (and adversary number if any), and a brief designation of the document. | M | `caption()`: court name; "In re" debtor block; Case No.; Chapter; title. | same |
| Fed. R. Bankr. P. 9011(a) | Signed by at least one attorney of record in the attorney's individual name; the document states the signer's address and telephone number. | M | `signature-block()` and the verifications: "/s/" signature, counsel lines. | https://www.law.cornell.edu/rules/frbp/rule_9011 (eff. 2024-12-01), verified 2026-10-14 |
| Fed. R. Bankr. P. 9037 | Redaction of taxpayer identification numbers to the last four digits (the exemplar prints a full EIN on its caption). | A | The sample does not transcribe the EIN. The template has no EIN field. | not re-verified this pass |

Convention (C), not rule: the caption's Form 416A-style debtor address and EIN line (the exemplar has them); the "No Hearing Set" line; the verifications (FRBP 9013 requires none; the exemplar has two, one by counsel and one by the officer); the certificate of service; the "Dated" line.

## Typeface

| Item | Value |
|---|---|
| Face required | none. No local rule (abolished 2003-08-04, General Order 2003-1) and no FRBP text names a typeface; FRBP 9004(a) asks only for legibility. |
| Vendored substitute | not applicable: no face is named, so the template keeps **EB Garamond** (`fonts/eb-garamond/`, SIL OFL 1.1), per `docs/FONTS.md` ("No face named"). |
| Metric fit | n/a (not a substitute). Page count (10) and line breaks are EB Garamond's; the exemplar is set in a Times-type face. |

## Markdown contract (for samples)

A sample is one `.md` file.

- YAML frontmatter. Required: `case_number` (e.g. `"14-02689"`), `chapter`, `debtors` (list of names as in the caption), `debtor_role` (e.g. `"Debtor and Debtor in Possession."`), `brief_title`, `lead_in` (the unnumbered opening paragraph), `date`, `signature` (`signer`, `lines`: the counsel block after the "/s/" line). Optional: `label` (e.g. `"FIRST DAY MOTION"`, bold in the caption's right column), `hearing` (e.g. `"No Hearing Set"`), `adv_number` (adversary case), `declarations` (list of `{title, body, date, signer}`; `body` is markdown, so its own numbered lines render as an ordered list), `service` (`{title, text, signer}`).
- The body is blank-line-separated chunks. `#` is a centered section in capitals; `##` a bold sub-heading (its letter is part of the text, as filed); `###` bold italic. A paragraph is numbered by the template: **do not type the number in the sample** (a typed "1." makes markdown render a list and the number prints twice; this was found in the first render and fixed). A paragraph starting `WHEREFORE` is unnumbered and kept with the signature block that follows it. A `>` quotation is single-spaced and indented.
- Footnotes: `[^n]` in the text, and a definition chunk `[^n]: text`. The template appends the definitions to each chunk that refers to them, because the renderer resolves a reference only against definitions in the same string.
- Case names are italic in `*...*`. Markdown is rendered by `cmarker` (vendored).

## Layout and convention choices (tier 2)

- Letter paper, one-inch margins, page number centered at the foot of each page.
- EB Garamond 12 pt; body double-spaced (`body-leading` = 1.35em); footnotes 10 pt; numbered paragraphs with a half-inch first-line indent; sub-headings bold with a hanging indent.
- Caption: court name centered in bold capitals; the debtor block in the left column with a rule on the right and bottom; Case No., Chapter, and a bold label (e.g. FIRST DAY MOTION) in the right column above the bold title; "No Hearing Set" under the title.
- Signature block: "Dated" on the left; "/s/" signer and counsel lines on the right.
- Verifications and the certificate of service follow the signature, each with a centered bold title.

## What the overlay shows

`usage/OVERLAY-foods-motion.pdf`: red is our render, blue is the filed exemplar pages (paired by shared words), black where both agree. Pairing (from `OVERLAY-foods-motion.txt`): our p.1 to exemplar p.1; p.2 to p.2; p.3 to p.4; p.4 to p.5; p.5 to p.6; p.6 to p.7; p.7 to p.9; p.8 to p.10; p.9 to p.11; p.10 to p.13. Word overlap is 50 to 88 per cent per page. The overlay is a diagnostic: the differences are the typeface, the line pitch, the caption (the exemplar's EIN and address lines and its "FIRST DAY MOTION" box are not reproduced), and the exemplar's own page breaks. The exemplar's typing error in ¶ 11 ("Program and. Dahl's") is transcribed as filed.

## Gate 2 review (every page of the current PDF)

Current PDF: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, after the last template change (the conclusion made sticky to the signature block; pages 1 to 6 are unchanged by that change). Compared with exemplar pages in the right-hand column.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Caption: court name; "In re" block; Case No. 14-02689, Chapter 11, FIRST DAY MOTION; bold title; No Hearing Set; lead-in; heading I; ¶ 1. | PASS |
| 2 | exemplar p.2 | ¶ 2 with footnote 1 at the foot; heading II; ¶¶ 3 to 10; sub-heading A. | PASS (the first render printed each number twice, a typed number in the sample; fixed by removing typed numbers, re-viewed) |
| 3 | exemplar p.3 | ¶¶ 11 to 15; sub-headings B, C, D. | PASS |
| 4 | exemplar p.4 | ¶¶ 16 to 18; heading III; ¶ 19 begins. | PASS |
| 5 | exemplar p.5 | ¶¶ 19 end to 24. | PASS |
| 6 | exemplar p.6 | Heading IV; sub-heading A (wraps to two lines); ¶¶ 25 to 27 begin. | PASS |
| 7 | exemplar p.7 to p.9 | ¶¶ 27 end to 30; footnote 2 at the foot. Footnote 2's reference is placed at the end of ¶ 27 (the text layer does not fix the marker's position with certainty). | PASS (position of the marker: ACCEPTED as approximate, see Known gaps 6) |
| 8 | exemplar p.10 | ¶¶ 31 to 34; the page ends after ¶ 34 because the conclusion moved with its signature block to the next page. | PASS |
| 9 | exemplar p.11 | VI. CONCLUSION (WHEREFORE, unnumbered); date and signature block; verification by counsel (¶¶ 1 to 3, penalty-of-perjury sentence). | PASS |
| 10 | exemplar p.12 and p.13 | Verification by officer (¶¶ 1 to 2); certificate of service with "/s/ Barbara Warner". | PASS |

## Known gaps and open choices

1. **Filers.** One filer. Sivyer Steel Corporation (18-00507, doc 6, a motion for utility-service orders, same counsel, 6 pages, no separate brief) was checked; it is a motion, not a motion with a brief, and it is by the same counsel, so it does not meet the tier-2 rule of different filers. Tier 2 is judged against one filer.
2. **Age of the exemplar.** Filed 2014-11-09. The rule cites in the exemplar are to the 2014 Code and Rules; the template follows the current text (the 2024 restyling is stylistic). The exemplar is evidence of practice in this court, not of current rules.
3. **Service method (FRBP 9014(b)(1)).** The rule requires service "in the manner for serving a summons and complaint provided by Rule 7004". The exemplar's certificate says only that it "was served electronically on parties who receive electronic notice through CM/ECF". Whether 7004 service (for example, by mail on parties who are not CM/ECF registrants) is needed for this motion is an author responsibility; the template prints the certificate text the author supplies and does not decide the method. Open for the author; not a template defect.
4. **Local rules.** Abolished 2003-08-04 (see Governing rules). The brief's premise is recorded here as a finding; no rule text was invented to fill the gap.
5. **Transcription.** The exemplar's ¶ 11 reads "...Drug Benefit Program and." and ¶ 14 "Debtor withholds ... their employees"; both are transcribed as filed. The heading sequence skips V (I, II, III, IV, VI); transcribed as filed (the template does not number headings). The text layer's "Dahl's" apostrophes are rendered as curly quotes by the template.
6. **Footnote 2's marker** is placed at the end of ¶ 27, the paragraph whose text it supports; the filing's marker position is approximate in the text layer.
7. **Omitted from the filing:** the debtor's employer identification number (FRBP 9037; the full number appears in the exemplar); the firm's document identifier printed at the foot of the last page; "Hon." judge line (blank in the exemplar; the template has no judge field).
8. **Not produced here:** a proposed order (none is attached in the exemplar; a proposed order is a separate document), any notice of opportunity to object or hearing notice (the exemplar says "No Hearing Set"; whether this court's practice requires a negative notice is not verified here), and the supporting declaration of Craig Moore (incorporated by reference in ¶ 4; not part of this document).
9. **Italics** of case names are added by the transcriber; the exemplar's text layer has no italic markup.
10. **Verifications** are convention (see above); a motion that relies on facts outside the record needs a declaration, which the template renders wherever the sample supplies it.

## Engines

The typst template is the primary engine. This section covers the **docx** engine (`docx/`, built 2026-10-15): `docx/reference.docx` (regenerated by `docx/make-reference.sh`) and the filter `docx/iasb-motion-brief.lua`. Build with pandoc 3.12.1 (the bootstrap toolchain): `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx`, then LibreOffice converts it to `usage/OUTPUT-foods-motion.docx.pdf` (not run here: see BLOCKED).

What matches the typst render (same settings, written as styles and section properties):

- Letter paper, one-inch margins, page number centered in the footer (a `PAGE` field).
- EB Garamond 12 pt, named in the styles. The font must be installed on the machine that opens the file, or Word substitutes silently.
- Body double-spaced at exact 24 pt (the pitch measured on the typst render), numbered paragraphs with a half-inch first line and a tab after the number; footnotes are native footnotes in 10 pt.
- Caption: court name centered in bold capitals; a borderless two-column table: the debtor on the left with a rule on its right and bottom; Case No., Chapter, the label (FIRST DAY MOTION), the title in bold and the hearing line on the right.
- Numbered paragraphs 1 to 34; the WHEREFORE paragraph unnumbered; section headings centered in capitals (level 1), and sub-headings bold with a hanging indent (level 2); the signature block (date left; `/s/` signature and counsel lines right).
- Verifications: each title centered in capitals, numbered body, its own date and `/s/` signature; the certificate of service last, its signature set to the right.

What differs, or is not checked:

- Line, footnote and page breaks follow Word and LibreOffice, not typst. Footnote placement in particular is left to the application.
- Numbers, including those of the verifications, are typed text, as in the typst template. Level-1 headings are typed in mixed case and shown in capitals by the style.
- The certificate's signature is set at a fixed indent instead of the typst block's right alignment; the typst block is not measured.
- Single-spaced blocks use Word's single line spacing, not typst's 0.5 em leading.

docx BLOCKED (this run):

- `docx.pdf` checks (Gates 0 to 3 on `usage/OUTPUT-foods-motion.docx.pdf`): **BLOCKED**. LibreOffice (`soffice`) is not installable here: it has no conda-forge package, and there is no root for a system install. No PDF was produced, so no page was rendered or reviewed.
- `.docx` opens in LibreOffice and Word without a repair prompt: **NOT VERIFIED**. Checked only: a valid zip, well-formed XML parts, and a pandoc read-back (text, numbering, footnotes, verifications, certificate).
- `sh tools/check.sh <this folder> --engine docx`: **cannot run** for this court. The court has no `rules.md` or `checks.yaml` (Gate 1 has nothing to check), and the checker reads `court.json` from the court root.
- Gate 2 for docx: pages reviewed **0** (of 0 rendered).
