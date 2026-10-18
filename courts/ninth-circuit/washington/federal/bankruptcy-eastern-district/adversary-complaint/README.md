# waeb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court, Eastern District of Washington (`waeb`).
Folder: `courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-waeb-adversary-complaint-icap2580041.pdf` (Bush Kornfeld LLP for co-trustees, 2025-09-26) and `usage/SAMPLE-waeb-adversary-complaint-cleelum2580033.pdf` (Stoel Rives LLP for the City of Cle Elum, Chapter 9, 2025-08-13). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-waeb-adversary-complaint-icap.md`: caption, paragraphs 1 to 35 (Counts I and II), prayer, signature, Exhibit 1 and Exhibit 2 (full tables). Counts III and IV are not transcribed (see Known gaps). |
| render | ok: `usage/OUTPUT-waeb-adversary-complaint-icap.typst.pdf`, 17 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> usage/INPUT-waeb-adversary-complaint-icap.md usage/OUTPUT-waeb-adversary-complaint-icap.typst.pdf`). |
| overlay | ok: `usage/OVERLAY-icap-adversary-complaint.pdf` and `usage/OVERLAY-icap-adversary-complaint.txt` (`tools/overlay.sh` with the iCap exemplar as third argument, 2026-10-15; see Overlay). The exemplar PDF is not in the checkout; it was fetched from its CourtListener URL in `usage/SOURCE.md` into a scratch directory for the run. |
| pages reviewed | 17 of 17 (2026-10-15: every page rasterized at 70 dpi and viewed as a contact sheet, unchanged font; earlier 60 dpi review 2026-10-14). |
| typeface | LBR 9004-1(a)(3) names no face; EB Garamond kept (2026-10-15 check of the rule text). See Typeface. |

## Governing rules

Primary sources, fetched 2026-10-14 (the rule text in each source is quoted from the fetched page).

| Rule | Requirement | Template |
|---|---|---|
| LBR 9004-1(a)(1) (Complete Set of Local Rules, https://www.waeb.uscourts.gov/sites/waeb/files/Complete_Set_Local%20Rules_20260717.pdf, rule dated AUGUST 1, 2020) | Documents prepared letter size, 8 " x 11". | `paper: "us-letter"` (WAEB-AC-FORM-003). |
| LBR 9004-1(a)(3) (same source) | Double-spaced; "a proportionately spaced typeface of 14 points or more"; roman type; footnotes double-spaced; quotations may be single-spaced; average of no more than 280 words per page. | `type-size = 14pt`, `body-leading = 0.94em` (about 2.2 x type size), EB Garamond (WAEB-AC-FORM-001, -002). Words per page measured on the render: 210 to 260 on pages 3 to 12. |
| LBR 9004-1(a)(4) (same source) | Title of the Court on or below the fifth line of the first page; names typed under each signature line. | `court-heading()` after the counsel block (WAEB-AC-CAP-003); `signature-block()` (WAEB-AC-SIG-001). |
| LBR 9004-1(a)(5)(A)-(D) (same source) | Right of centre opposite the caption: case number and related case number above the adversary number; nature of the document; party status; "Demand for Jury Trial" when demanded. | `caption()`: `related_case`, `adversary_no`, `title`, `jury_demand` (WAEB-AC-CAP-004). |
| LBR 9004-1(a)(6) (same source) | Attorney name, mailing address and telephone on the left side above line five. | `counsel-block()` (WAEB-AC-CAP-002). |
| LBR 9004-1(a)(7) (same source) | Bottom left: abbreviated name of the document, followed by the page number. | Footer `COMPLAINT  n` (WAEB-AC-FOOT-001). |
| LBR 7003-1(a) (same source, rule dated DECEMBER 1, 2015) | Paper adversary proceedings are accompanied by Official Form 1040 (cover sheet). | Not produced by this template (separate filing). |
| FRBP 7001 (https://www.law.cornell.edu/rules/frbp/rule_7001, as amended Apr. 2, 2024, eff. Dec. 1, 2024) | Defines the proceedings that must be brought as adversary proceedings (here: recovery of transfers and avoidance). | Doc type scope; the template does not check the claim type. |
| FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, eff. Dec. 1, 2024) | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the caption substantially conforms to Form 416. | Caption and numbering follow FRCP 10 (below). |
| FRCP 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, as amended Apr. 30, 2007, eff. Dec. 1, 2007) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | `court-title` constant, `caption()`, `related_case`. |
| FRCP 10(b) (same source) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | Numbered paragraphs by the template (WAEB-AC-BODY-001). Unnumbered paragraphs need the `~ ` marker (see contract). |
| FRBP 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004, eff. Dec. 1, 2024) | "A petition, pleading, schedule, or other document must be clearly legible." | Text in EB Garamond, 14 pt, roman; no fallback font (`fallback: false`). |

Not produced by this template (separate filings, may be required with the first filing): the adversary cover sheet (Official Form 1040, LBR 7003-1(a)), the summons, and the disclosure statement.

## Typeface

- Court rule: LBR 9004-1(a)(3) requires "a proportionately spaced typeface of 14 points or more" and roman type. It names no face (checked 2026-10-15 against the text of the Complete Set of Local Rules, dated 2026-07-17 on the court's site).
- Substitution: none. The rule names no face, so the template keeps EB Garamond (`docs/FONTS.md`, "No face named"). No other typeface is used in the template.
- Times New Roman in the filed exemplar is the filer's choice, not a rule requirement, and is not copied.

## Layout

- Page 1: counsel block in side-by-side columns (one column per firm); court title below it; caption in two columns: debtor, parties and "v." on the left with a rule on the right and bottom, case numbers, adversary number, title and jury demand on the right. The caption is an unbreakable block, so it never splits across pages.
- Body: numbered paragraphs (1, 2, ...) with a 0.5 inch first-line indent; level-1 `#` headings centered bold caps; level-2 `##` headings bold, lettered A., B., ... (restart under each level-1 heading); bold-only lines centered (cause-of-action subtitles); lettered list items (a), (b), ...
- Signature block after the prayer: date and firm on one line, `/s/` signer, names under the line (WAEB-AC-SIG-001).
- Exhibits: each `# EXHIBIT ...` starts a new page; markdown tables render as bordered tables with the header row repeated on each page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `in_re` (list of lines, last line "Debtors."), `related_case`, `adversary_no`, `parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `jury_demand` (bool), `footer_title` (default `COMPLAINT`), `counsel` (one list of lines, or a list of groups for side-by-side columns), `division` (optional, centered line under the court title), `signature` (`date`, `firm`, `signer`, `lines`).
- Body chunks, separated by blank lines:
  - `# Heading` centered bold caps (no number); `# EXHIBIT n` starts a new page.
  - `## Heading` lettered A., B., ...; the letters are generated, do not type them.
  - `**Line**` a bold-only line: centered, unnumbered (cause-of-action subtitles).
  - `- item` lines: lettered (a), (b), ...; the template letters them.
  - `| table |`: a markdown table (exhibits).
  - `~ text`: an unnumbered paragraph with a first-line indent (WHEREFORE lead-in, closing lines).
  - anything else: a numbered paragraph. Do not type the number.
- Footnotes: `text[^1]` in a paragraph and `[^1]: text` on the line directly after that paragraph, with no blank line between (the template renders chunks one at a time, so the definition must sit in the reference's chunk).
- Escapes: a `$` sign, `§` and `¶` are plain text; `*Italic*` and `**bold**` are markdown.

## Decisions and why

- **Counsel block in columns.** The exemplar sets its counsel block in one column at 12 pt. At 14 pt (LBR 9004-1(a)(3)) a single column of this counsel list is about 320 pt tall, and with the court title and caption it pushed the caption onto page 2. The template therefore sets counsel groups side by side when the frontmatter gives groups. This is a layout choice, not a rule; it is recorded as ACCEPTED for tier 2.
- **Caption unbreakable.** If the caption ever does not fit on page 1, it moves to page 2 whole; the render shows that, and it is treated as a defect.
- **Signature after the prayer, exhibits after the signature.** The filed order is prayer, signature, exhibits.
- **Unnumbered closing paragraphs are sticky.** A `~` paragraph is kept with the signature block so a signature never stands alone on a page.

## Overlay

`usage/OVERLAY-icap-adversary-complaint.pdf` is the red/blue comparison of our render (red) with the filed exemplar (blue), page by page; `-overlay.txt` is the page map. Pairing by text gives: ours 1 to 11 with filed 1 to 11 (word overlap 47 to 89 per cent), ours 12 to 17 with filed 13 to 18 (the exemplar has counts III and IV and the Exhibit 1 table on different pages). The overlay is diagnostic, not a score: the red and blue differ in font size (EB Garamond 14 pt against Times 12 pt in the exemplar), so the text does not line up by eye.

## Known gaps

1. **Font size look.** The rule names no face, so EB Garamond at 14 pt is compliant. The exemplar's Times at 12 pt looks larger; that is the filer's choice, not a requirement, so no Times substitute is used (see Typeface).
2. **Exemplar coverage.** The sample transcribes paragraphs 1 to 35 (Counts I and II), not Counts III and IV (paragraphs 36 to 45 of the filing). The sample's own excerpt note says so. The exemplar is 18 pages and the render is 17; the target of 8 to 14 pages is not met because the sample keeps the full caption, both exhibits and the signature at 14 pt.
3. **Second filer.** Two filers are saved (iCap and Cle Elum). Only iCap is transcribed and overlaid. Tier 2 (conventions) has not been judged against the Cle Elum caption (a two-column caption with the Chapter 9 case number and a different counsel layout) yet.
4. **Adversary number.** The iCap filed caption leaves "Adv. Pro. No." blank; the sample takes the number (25-80041-WLH) from the footer of the filed pages. This is sample content, not template content.
5. **Paragraph numbering.** The sample's numbers come from the template, not from the filing; they agree with the filed numbers for paragraphs 1 to 35 (checked on the overlay).
6. **Captions are typed in the sample.** The template does not enforce capitalization of the caption or heading text.
7. **Court title is a constant.** `court-title` in the template is the court's own name ("UNITED STATES BANKRUPTCY COURT / EASTERN DISTRICT OF WASHINGTON"). It is the same for every filing in this court and is not case-specific.

## Review of the rendered pages (2026-10-14, 60 dpi, every page viewed)

- Page 1: counsel in two columns (Wax; Murphy, Baratz, Meland Budwick), court title, caption complete on the page, footer `COMPLAINT 1`. Pass.
- Page 2: unnumbered intro paragraph, PRELIMINARY STATEMENT, paragraph 1, footnote 1 at the foot of the page. Pass.
- Pages 3 to 4: paragraphs 2 to 9, PARTIES and JURISDICTION centered; numbering continuous. Pass.
- Pages 5 to 10: FACTUAL ALLEGATIONS (centered), A to E lettered and left-aligned, paragraphs 10 to 26; the (a) to (l) list on pages 7 to 9. Pass.
- Pages 11 to 12: COUNT I and COUNT II centered with bold subtitles; paragraphs 27 to 35; the excerpt note; WHEREFORE and the four prayer items (a) to (d). Pass.
- Page 13: the closing paragraph, DATED line with firm, `/s/` signer and names under the line, kept together. Pass.
- Pages 14 to 16: EXHIBIT 1, a 46-row table with the header row repeated on pages 15 and 16, total row at the foot. Pass.
- Page 17: EXHIBIT 2, 16 rows and the total. Pass.

## Engines

docx (`docx/`): `reference.docx` (built by `docx/build-reference.sh`), `complaint.lua` (the markdown contract to cover, caption, numbered paragraphs, lettered lists, signature block and exhibits), `render.sh` (pandoc, then the footer title). Render: `sh tools/render.sh --engine docx <this dir> usage/INPUT-waeb-adversary-complaint-icap.md` writes `usage/OUTPUT-waeb-adversary-complaint-icap.docx` and `usage/OUTPUT-waeb-adversary-complaint-icap.docx.pdf` (LibreOffice 26.8; `pdffonts` shows EB Garamond only). Pages: docx 17, typst 17.

What matches the typst output (`typst/`): letter, 1 in margins; EB Garamond 14 pt throughout; body lines on the typst line pitch (31.4 pt, exact spacing); counsel, caption, signature and table lines single-spaced (about 20 pt); footnotes single-spaced as in the typst complaint template; footer `COMPLAINT n`; counsel side by side and the caption with its rules on page 1; court title with the typst blank lines; numbered paragraphs, (a) lists and A. headings; each exhibit on its own page with the header row repeated; signature block after the prayer, kept with the closing paragraph and the date.

What differs (checked page by page, `reviews/docx.md`):
- Exact line spacing puts the extra leading above each line, so text starts about 11 pt lower on every page than in typst. The pitch is the same, but a full page holds about one body line fewer, so page breaks differ from the typst render on pages 2 to 13. Total length is the same (17 pages).
- Exhibit tables run the full 6.5 in text width; the typst tables are sized to their content. Column shares are set in `complaint.lua`.
- "/s/ JASON EDWARD WAX (WSBA #41944)" wraps in LibreOffice inside the 3.5 in signature column; typst keeps it on one line.
- Word was not run here (no Word on this machine). Word may paginate slightly differently (docs/DOCX.md).

BLOCKED: check.sh gates 0-3: `tools/check.sh <this dir> --engine docx` cannot run on a doc-type folder. It reads `court.json` and `checks.yaml` from the court dir; this folder has neither, and the court folder has `court.json` but no `checks.yaml`. No `usage/.check-docx.txt` is written. The pages were checked by hand (see `reviews/docx.md`), not by the gates.
