# tnwb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Western District of Tennessee (`tnwb`), Eastern and Western Divisions.
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (21-page complaint transcribed: caption, intro, paragraphs 1–70 with transfer tables and footnotes, the prayer and the signature; paragraphs 71–116 omitted and marked in the sample) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 11 pages, US Letter, typst 0.15.0, vendored EB Garamond only, no typst warnings |
| overlay | ok: `usage/OVERLAY-brewers-adversary-complaint.pdf` and `usage/OVERLAY-brewers-adversary-complaint.txt` |
| pages reviewed | 11 of 11 (every page of the final render rasterized at 60 dpi and viewed) |
| tier 2 | not met: one filer only (see Known gaps 1) |
| typeface | face required by the rules: none (Known gaps 2) -> vendored substitute: none needed, EB Garamond kept per `docs/FONTS.md` ("No face named") -> not applicable |

Commands (from the repo root, with `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint brewers-adversary-complaint
```

Output names are the tools' defaults (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`): `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and cannot be pointed at a file named `<id>.pdf`.

## Governing rules

Dates verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| TNWB LBR 1001-3(h) (Local Rules eff. April 3, 2017) | Every pleading must bear the signature of an attorney of record and the attorney's address, zip, telephone, email, fax if any, and state bar disciplinary number. | https://www.tnwb.uscourts.gov/PDFs/BK/LocalRules.4.3.17.pdf | `signature` frontmatter (`firm`, `signer`, `name_line`, `lines`). See Known gaps 5 for the bar number. |
| FRBP 9004(a), (b) (restyled eff. Dec. 1, 2024) | Papers must be clearly legible. A document must have a caption with the court's name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-heading`, `caption` (`case_number`, `adversary_number`, `title`). |
| FRBP 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the caption "must substantially conform to the appropriate version of Form 416." | https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption`: court, division line, debtor and case number, all parties, adversary number, title. Form 416 itself was not fetched (Known gaps 3). |
| FRCP 10(a) (via FRBP 7010) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the title of the complaint must name all the parties. | https://www.law.cornell.edu/rules/frcp/rule_10 (text checked 2026-10-14) | `caption` lists every plaintiff and defendant; the title `COMPLAINT` is in the caption block. |
| FRCP 10(b) (via FRBP 7010) | Claims are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; claims from separate transactions go in separate counts. | same | `pleading-body`: allegations are numbered 1, 2, ...; claim headings are author content (`#` lines) and are not numbered. |
| FRBP 7001 (types of adversary proceeding), 7003 and 7004 | The complaint commences the proceeding; summons and cover sheet are separate filings. | https://www.law.cornell.edu/rules/frbp/rule_7001 | Not generated: the cover sheet (Official Form 104) and the summons (Local Form 010, `https://www.tnwb.uscourts.gov/Forms/LocalForms/DOC/LF010.doc`) are separate filings. |

Not produced by this template (separate filings): the adversary cover sheet, the summons, the exhibits (including Exhibit A, the loan agreement), and any statement the court's current forms require.

## Layout

- Letter paper, 1 in margins. Body EB Garamond 12 pt, double spaced (24 pt baseline pitch), first-line indent of 0.5 in.
- Court heading centered: `UNITED STATES BANKRUPTCY COURT`, `WESTERN DISTRICT OF TENNESSEE`, and the division if given.
- Caption: a two-column table with a section-mark (§) column (the exemplar's style). Debtor block on top (`IN RE:`, debtor name, `DEBTOR.`) with the case number and chapter on the right; adversary block below (plaintiffs, `Plaintiff,`, `vs.`, defendants, `Defendants.`) with `ADVERSARY PROCEEDING NO.` on the right.
- Title centered in capitals between rules.
- Allegations numbered by the template. The first paragraph (the introduction) is unnumbered, and so is the prayer lead-in (any paragraph starting `WHEREFORE`) and an editorial note written in italics within square brackets (`*[...]*`).
- `#` headings: centered bold capitals (claims, sections). `##`: centered bold, mixed case (the parenthetical under a claim heading). `###`: left bold (lettered sub-headings).
- Prayer items (`- ` list) are lettered A., B., ... with a hanging indent.
- Transfer tables (markdown pipe tables) are centered, single spaced, ruled; a table that breaks across pages repeats its header row.
- Footnotes: `text[^key]` plus `[^key]: ...` definitions; 10 pt.
- Signature block at 3 in from the left margin, single spaced: closing line, firm, `/s/` signer, name line, address and contact lines, role. The last allegation or prayer item is kept in one unbreakable block with the signature, so the signature never stands alone.
- Page number centered at the foot of each page.

## Markdown contract (for samples)

YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `division` | no | third caption line (`EASTERN DIVISION`) |
| `debtor` (list of lines) | yes | `IN RE:` block |
| `case_number` | yes | `CASE NO.:` |
| `chapter` (list of lines) | yes | chapter lines on the right of the debtor block |
| `adversary_number` | yes | `ADVERSARY PROCEEDING NO.:` |
| `plaintiffs`, `defendants` (lists) | yes | adversary block |
| `title` | yes | document title, centered in capitals |
| `signature` | yes | `closing` (e.g. "Respectfully submitted this 19th day of September, 2025."), `firm`, `signer`, optional `name_line` (defaults to `signer`), `lines`, `role` |

Body: blank-line separated blocks. `#` / `##` / `###` headings; `- ` list items (lettered); `|` tables; `>` quotations (single spaced, indented); any other block is a paragraph, numbered unless it is the first block or starts with `WHEREFORE` or `*[`. Case names and signals are italic in the markdown (`*Tabas v. Lehman*`). Escape a literal `*` (`at \*8`).

Not supported: raw typst, images, nested lists.

## Known gaps and open choices

1. **One exemplar, not two or three.** The tier-2 test (2 or 3 filers) is not met. The search (CourtListener RECAP, `court=tnwb`, adversary complaints 2019–2025) found Springfield 19-00070 and Reed 20-00136 (pro se, 2–3 pages, not representative) and Butcher Shop of Cordova 21-00106 (44 pages, mostly scanned exhibits, little text). None was saved.
2. **No court typeface, margin or spacing rule found.** The W.D. Tenn. bankruptcy local rules (2017 text, `LocalRules.4.3.17.pdf`, re-read 2026-10-15 as extracted text: no font, size, spacing or margin requirement) contain none, and FRBP 9004 (restyled 2024) has none either. The template uses the exemplar's conventions: 12 pt, double spaced, 1 in margins. These are conventions, not court requirements. The court's current local rules may have changed since 2017 and were not verified. A search snippet reports that the Middle District's 2025 amendments moved LBR 9013-1 instructions to the court's website; nothing was found for TNWB either way.
3. **Form 416 was not fetched.** FRBP 7010 requires the caption to substantially conform to Official Form 416. The caption follows the exemplar and the rule's stated contents; the form text itself is unverified.
4. **Font.** The exemplar is set in Times New Roman, but the rules name no face (Known gaps 2), so `docs/FONTS.md` ("No face named") keeps EB Garamond. The exemplar settles only what the rules leave open, and a Times face is a tier-2 look, not a rule. Liberation Serif (metric-compatible with Times New Roman, vendored) would be the substitute if David decides the clerk-facing look should follow the exemplar. EB Garamond at 12 pt has a smaller x-height than Times at 12 pt, so the text reads smaller than the exemplar; that is a decision for David.
5. **State bar number.** LBR 1001-3(h) requires the state bar disciplinary number. The exemplar's counsel block has none (its counsel is a New York firm), so the sample has none either. The template prints `name_line` if given and does not check for it.
6. **Italics.** The exemplar's text layer does not show italics. The sample italicizes case names and signals as a convention, not from the filing.
7. **Transcription.** The sample is the exemplar's text transcribed from its text layer, with the exemplar's own errors kept: the stray quotation mark in the introduction (`“hereinafter referred to as “Bassuk”)`), "should be avoided under as it did not" (paragraph 51), and "a constructively fraudulent conveyances" (paragraph 66). Paragraphs 71–116 are omitted and marked; the prayer is transcribed as filed and still refers to the omitted Fourth and Fifth Claims.
8. **Justification.** Body text is ragged right. The exemplar's justification could not be read from the text layer; not asserted.
9. **Overlay pairing.** The overlay pairs pages by word overlap, not by index (`OVERLAY-<id>.txt`). The lowest matches are our pages 5 (35.0%, paired with filed page 6) and 11 (27.0%, paired with filed page 21): page 5 is the 40-row table, which the exemplar sets differently, and page 11 is the signature page of a sample that omits paragraphs 71–116. Pages 1–3 match 57–81%. The overlay is a diagnostic, not a score.
10. **Checker not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none of those, and the brief forbids changes to `tools/`. Render and overlay were run; the page review below is the visual check.
11. **Cover sheet, summons and exhibits** are separate filings and are not generated (see Governing rules).

## Review of the rendered pages (final render, 11 pages)

Rendered at 60 dpi with `pdftoppm -r 60` and viewed page by page.

| Page | Content | Result |
|---|---|---|
| 1 | Court heading, caption (debtor and adversary blocks, § column), title, introduction, paragraphs 1–5 | Pass. Caption rows do not overlap; wrapped party names sit in their rows. |
| 2 | Paragraphs 6–15; GENERAL ALLEGATIONS and THE AGREEMENT headings | Pass. Heading kept with the following paragraph. |
| 3 | Paragraphs 16–25; first transfer table (25) | Pass. Table fits the page. |
| 4 | Continued table 25, paragraphs 26–30; tables 27 and 28 | Pass. Table 25 breaks onto this page with its header row repeated. |
| 5 | Paragraph 31 and its 40-row table | Pass. Table fits the page. |
| 6 | Paragraphs 32–41; INSOLVENCY; footnotes 1 and 2 | Pass. |
| 7 | Paragraphs 42–51; FIRST CLAIM FOR RELIEF heading and subtitle; footnotes 3 and 4 | Pass. |
| 8 | Paragraphs 52–58; SECOND CLAIM FOR RELIEF heading | Pass. |
| 9 | Paragraphs 59–67; THIRD CLAIM FOR RELIEF heading | Pass. Italic case names in paragraph 59. |
| 10 | Paragraphs 68–70; the omission note (unnumbered); WHEREFORE; prayer A–F | Pass. |
| 11 | Prayer item G; "Respectfully submitted this 19th day of September, 2025."; signature block | Pass. Item G is kept with the signature block. Finding (tier 2, ACCEPTED): the prayer breaks between pages 10 and 11, leaving page 11 short; the keep rule is preferred to a full page 10. |

Open tier-2 findings: none that block the layout. The items above (Known gaps 2–6) are the ones a clerk or a tier-2 comparison would raise.

## Engines

docx (`docx/build-reference.sh` -> `docx/reference.docx`, filter `docx/tnwb.lua`; render `sh tools/render.sh --engine docx`; judged on `usage/OUTPUT-adversary-complaint.docx.pdf`, the LibreOffice conversion):

- Matches the typst output: 11 pages in both; EB Garamond only (`pdffonts`, no fallback face); US Letter, 1 in margins; double spacing (exact 23.9 pt, so 27 lines per page as in typst at 24 pt); single-spaced court heading, caption (with the section-mark column), signature block and parties; numbered allegations at 0.5 in with text at 1 in; lettered prayer with a hanging indent; centered caps, centered bold and left bold headings; transfer tables centered, auto width, ruled, header row repeated across pages; footnotes at 10 pt; page number centered in the footer. Pages reviewed: 11 of 11 (every page of the final docx.pdf rasterized at 60 dpi and viewed, compared with the typst pages).
- Differs (tier 2, not chased): (1) pagination: LibreOffice places exact-spaced text about 4 pt lower and table rows are 14.3 pt against typst's 13.8 pt, so a few page breaks fall a line or two away from typst (for example the transfer table of paragraph 31 starts on page 5 and ends on page 6 in the docx, and entirely on page 5 in typst); (2) the firm name in the signature block wraps to three lines in LibreOffice (typst: two); (3) footnote leading is exact 11.5 pt; (4) cell text of the transfer tables is plain text (markdown emphasis inside a table cell is not carried over); (5) no PDF bookmarks.
- BLOCKED: none in the template. `sh tools/check.sh <court-dir> --engine docx` cannot run on this folder: it needs `checks.yaml` and `rules.md` (and the court's `court.json`), which this unit does not create; the run exits 2 before any gate. No check ID is BLOCKED by the docx template itself.
