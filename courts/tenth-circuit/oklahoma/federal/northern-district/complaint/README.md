# N.D. Okla. (oknd): complaint

Doc type: **complaint** (with jury demand) in the United States District Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-oknd-complaint-lord426cv00407.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-oknd-complaint-lord.md`: paragraphs 1-46 (caption to damages), Counts I and II, jury demand, prayer, signature |
| typeface | face required: none (LGnR2-4(a) sets a 12-pt floor and names no face). Substitute: none needed; **EB Garamond kept** (`docs/FONTS.md`: "no face named"). Fit: not metric-compatible with the Times/Cambria exemplar; visual only. |
| render | ok: `usage/OUTPUT-oknd-complaint-lord.typst.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings; `pdffonts`: EBGaramond Regular, Bold, BoldItalic embedded |
| overlay | ok: `usage/OVERLAY-lord-complaint.pdf` and `usage/OVERLAY-lord-complaint.txt` |
| pages reviewed | 12 of 12 (every page rendered at 70 dpi and viewed, fonts pass; page count unchanged at 12) |

## Governing rules

Primary sources, all fetched 2026-10-14.

| ID | Rule | Requirement | Source | Where in the template |
|---|---|---|---|---|
| OKND-FORM-001 | LGnR2-4(a), Local Rules (2026-07-31 version) | "All papers ... must be double-spaced, if typewritten." The 2023 general order carries the same text. | https://www.oknd.uscourts.gov/sites/default/files/2026-07-31%20Local%20Rules.pdf | `line-pitch` = 24 pt, `body-leading`. Measured: 24.0 pt body pitch on every body page (`pdftotext -bbox-layout`). |
| OKND-FORM-002 | LGnR2-4(a) | "The print style, including footnotes, must not be smaller than 12-point font." | same | `type-size` = 13 pt, `footer-size` = 12 pt. 13 pt is a style choice (see gaps). |
| OKND-FORM-003 | LGnR2-4(a) | 8½ × 11 inch paper, one side; margins "a minimum of one inch on the top, bottom, and sides"; "The use of 'Exactly 24 pt' spacing is not permitted"; "All papers must be clearly legible." | same | `margins` (1 in all sides), `paper: us-letter`, single-side output. Line spacing is a multiple of the font's natural height (no exact spacing). |
| OKND-CAP-001 | Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." "The title of the complaint must name all the parties." | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `court-title()` (the court's name, two centered lines), `caption-table()` (all parties; file number on the right), `title` in the cover. |
| OKND-CAP-002 | LCvR38-1, Jury Demand | "If a party demands a jury trial by endorsing it on a pleading ... a notation shall be placed on the front page of the pleading, immediately following the title of the pleading, stating 'Jury Trial Demanded.'" | 2026 Local Rules, p. 50 (same text as the 2023 general order) | `jury_demand: true` puts "Jury Trial Demanded" directly under the title, on page 1. |
| OKND-CONT-001 | Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | https://www.law.cornell.edu/rules/frcp/rule_10 | `allegations()` numbers each body paragraph from 1; headings and lists are not numbered. |
| OKND-CONT-002 | Fed. R. Civ. P. 8(a)(1)-(3) | A pleading with a claim must contain a short and plain statement of the grounds for jurisdiction, of the claim, and "a demand for the relief sought." | https://www.law.cornell.edu/rules/frcp/rule_8 (verified 2026-10-14) | Author content (the sample has jurisdiction and venue headings and a prayer). The template does not check the wording. |
| OKND-CONT-003 | LCvR3-1(a) | The initiating document and the Civil Cover Sheet (JS-44) are "separate documents." | 2026 Local Rules, p. 26 | Not produced: a separate filing. |
| OKND-CONT-004 | LCvR5.2-1; Fed. R. Civ. P. 5.2 | Personal data identifiers are redacted by counsel and the parties. | 2026 Local Rules, p. 29 | Author responsibility. The sample contains no identifiers beyond counsel's public bar information. |

Not produced by this template: the civil cover sheet, the summons, the Rule 7.1 / LCvR7.1-1 disclosure statement (only needed when a party requires it), and any exhibits.

## Layout

- Plain page, no line numbers, no pleading rules (N.D. Okla. does not require pleading paper; LGnR2-4 does not mention numbered lines). Footer: centered page number only.
- Cover on page 1, body begins under the title on the same page (no forced page break): the court name (two centered lines), the caption (parties in the left column with a rule down the right and across the bottom; "Case No." on the right), the title (bold, centered), and the jury notation if `jury_demand` is true.
- No counsel block at the top. The local rules do not require one, and both exemplars put counsel at the end (signature block).
- Headings: `#` centered bold caps; `##` centered bold; `###` bold italic at the margin. Headings are sticky (a heading is never the last line on a page).
- Paragraphs: first-line indent 0.5 in, the number followed by a tab, numbered from 1; continuation lines flush left.
- Lists (subparagraphs and the prayer) are lettered (a), (b), ...; a list may break across pages.
- A paragraph beginning `WHEREFORE` is the prayer's lead-in and is not numbered (see gaps).
- Signature block: "Dated:" on the left, "Respectfully submitted," then "/s/" and the signer's name and details on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (string, verbatim; the court assigns it), `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between sides), `title` (the title of the pleading), `jury_demand` (true/false; required for the LCvR38-1 notation), `lead_in` (optional, unnumbered introductory paragraph), `date` (string), `signature` (`signer`, and `lines` for OBA number, firm, address, telephone, email).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings; a list (`1.` items, rendered as (a), (b), ...); or a paragraph (numbered by the template). Do not type paragraph numbers.
- Not supported: tables, footnotes (none used), raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/northern-district/complaint usage/INPUT-oknd-complaint-lord.md
sh tools/overlay.sh courts/tenth-circuit/oklahoma/federal/northern-district/complaint lord-complaint
```

File names follow the tools: `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The brief's `<id>.pdf` / `<id>-overlay.pdf` names do not match the tools, and the tools are not edited here.

The overlay is a diagnostic, not a score. Red is our render, blue is the exemplar, black is both. Pages pair by word overlap (`OVERLAY-lord-complaint.txt`): ours p.1 ↔ filed p.1 (88.6%), p.2 ↔ p.2 (80.1%), p.3 ↔ p.4 (52.5%), p.4 ↔ p.5 (76.3%), p.5 ↔ p.6 (76.4%), p.6 ↔ p.7 (58.0%), p.7 ↔ p.9 (70.6%), p.8 ↔ p.10 (73.3%), p.9 ↔ p.12 (52.9%), p.10 ↔ p.13 (65.7%), p.11 ↔ p.14 (70.5%), p.12 ↔ p.24 (49.5%, the signature page). The exemplar is 24 pages in Cambria/Calibri, not double-spaced, with a different caption layout, and the sample omits Counts III-XIII. The two layers agree on words and not on line position; the lower percentages are on pages where the sample skips exemplar text.

## Visual review (Gate 2 record, all 12 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, caption, title, "Jury Trial Demanded", lead-in, paragraph 1 | OK. Caption rule on the right and bottom; "Case No." vertically centered on the right. Jury notation directly under the title. |
| 2 | Paragraphs 2-5 | OK. Double-spaced, numbers at 0.5 in indent. |
| 3 | Paragraphs 6-10, "Parties" heading | OK. Heading kept with its paragraph. |
| 4 | Paragraphs 10-15, "Jurisdiction and Venue" heading | OK. Heading not stranded at foot. |
| 5 | Paragraphs 16-22, "Securities at Issue" | OK. |
| 6 | "Factual Allegations", A. and B. headings, paragraphs 23-29 | OK. Bold-italic sub-headings left at the margin. |
| 7 | B. (end), C. heading, paragraphs 30-34 | OK. |
| 8 | Paragraphs 35-41, D. heading | OK. |
| 9 | Paragraphs 42-43, E. heading, list (a)-(e) | OK. The list breaks to page 10 without splitting an item. |
| 10 | List (f)-(i), paragraphs 44-48, "Claims for Relief", Count I heading | OK. |
| 11 | Paragraphs 49-57, Count II heading, "Demand for Jury Trial", prayer lead-in (unnumbered), list (a) begins | OK. The WHEREFORE paragraph is unnumbered. |
| 12 | Prayer (b)-(l), date, signature block | OK. Signature block fits on the page; nothing spills. |

Reviewed pages: 12 of 12.

## Known gaps and open choices

1. **One exemplar only.** Tier 2 of the eval loop asks for two or three filers. The CourtListener search (`type=r`, `court=oknd`, complaints filed 2024 onward, RECAP documents marked available) returned one downloadable complaint. The other new complaint (Nichols v. Reed, 4:26-cv-00616, pro se) is not available. Tier 2 is **not** judged against two filers.
2. **The exemplar does not carry the LCvR38-1 notation.** Lord's complaint is captioned "Complaint and Demand for Jury Trial" and has no "Jury Trial Demanded" line under the title. The template follows LCvR38-1 (tier 1), so the overlay shows the notation as a difference from the filed document. This is a finding about the exemplar, not a template defect.
3. **Font and size.** EB Garamond (vendored) at 13 pt, not Times New Roman at 12 pt. The rule's floor is 12 pt and is met. EB Garamond sets smaller than Times at the same size, so 13 pt was chosen to look like the Times 12 pt exemplar. This is a style choice; the rule does not ask for a particular face.
4. **Caption, signature block and sub-headings are single-spaced.** LGnR2-4 says "all papers ... must be double-spaced" and does not exempt the caption, the signature block, or headings. The caption and signature block are single-spaced as in the exemplar. Headings are one line each with a half-pitch (12 pt) gap above and below, which the rule does not exempt. Flagged for David's call.
5. **Lettered lists, not numerals.** The exemplar's prayer uses "1., 2., ...". The template letters all lists (a), (b), ... (as the cand complaint does). The rules do not specify; this is a convention choice, recorded as ACCEPTED.
6. **Prayer lead-in.** A paragraph beginning `WHEREFORE` is unnumbered. This is a structural convention in the template (a prayer lead-in is not an allegation); the rule does not say so. Flagged.
7. **Transcription.** The sample transcribes paragraphs 1-46 (so that Count I's "paragraphs 1 through 46" is accurate), Counts I and II, the jury demand and the prayer. Counts III-XIII are not transcribed, and the jury demand (exemplar ¶ 118) is numbered 57 by the template. Extraction artifacts in the source text ("15)", "4.-", "Doe's") were removed; "Wherefore" and signature-block spacing were normalized. Two quoted passages were reflowed without changing words (the Blume signature block, the term sheet's "Funding Up to $50,000,000" line).
8. **Paragraph numbering.** The template numbers from 1 and does not reproduce the filed numbers (see 7).
9. **Certificate of service.** None for a complaint: service is by summons (Rule 4). Not produced.
10. **Civil cover sheet, summons, disclosure statement.** Not produced (see Governing rules).
11. **Tools gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court directory level. This doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the Gate 2 table above is the review for this doc type.

## Engines

DOCX engine (`docx/`: `reference.docx`, `oknd-complaint.lua`, `build-reference.sh`). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/northern-district/complaint usage/INPUT-oknd-complaint-lord.md`.

- **Matches the typst form:** EB Garamond 13 pt body, 12 pt page number centered in the footer, 1 in margins on letter paper, double spacing (Word "double", line 480), first-line indent 0.5 in, numbered allegations (typed numbers, FRCP 10(b)), centered bold caps level-1 headings, centered bold level-2, bold italic level-3, the cover (court name, caption with rule, title, "Jury Trial Demanded"), lettered "(a)" lists, and the signature block.
- **Differs from typst:** line pitch is "double" rather than exactly 24 pt (the local rule bans "exactly 24 pt"), so the page holds a different number of lines in Word. The caption and signature block are Word tables (border and row heights differ slightly). Allegation numbers are typed text, not a list field. Footnotes are not used by this form.
- **Output:** `usage/OUTPUT-oknd-complaint-lord.docx` is written. `render-docx.sh` then exits 1 (see below).
- **BLOCKED:** `docx.pdf` (LibreOffice PDF, check gates 0-3): `soffice` is not installed on this box and cannot be installed without root or conda-forge. Visual review of the docx pages: needs the same PDF; 0 docx pages reviewed. `unzip` is not installed, so the zip-integrity step of `tools/render-docx.sh` fails after the `.docx` is written. The XML parts were checked instead with `ziptool` and `xmllint` (15 of 15 well-formed). Opening in Word and LibreOffice without a repair prompt: not done.
