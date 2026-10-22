# miwd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Michigan (`miwd`).
Folder: `courts/sixth-circuit/michigan/federal/western-district/complaint/`. Self-contained: it does not touch the court root (`court.json`, `typst/`, `usage/`, `usage/`).

| Item | Status |
|---|---|
| exemplar | yes: 2 filers, `usage/FILED-EXAMPLE-complaint.pdf` (primary, Goodman Hurwitz & James) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, Flood Law). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md`: a portion of the 42-page filing (7 rendered pages) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` (typst 0.15.0, no warnings) and `usage/OUTPUT-complaint.docx` with its LibreOffice PDF `usage/OUTPUT-complaint.docx.pdf`, 8 pages each, vendored Times New Roman only; the docx breaks every line and page where typst does (Gate 4, `params.cross_engine: gate` in `eval.yaml`) |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-complaint.pdf` and `.txt` (gitignored; against the primary exemplar) |
| typeface | LCivR 10.1 names no face (it sets the size only; checked against the rule text 2026-10-15). Times New Roman (vendored, docs/FONTS.md), as the primary exemplar, in both engines (the docx was EB Garamond before 2026-10-22). Embedded: Times New Roman only (`pdffonts`). |
| pages reviewed | 8 of 8 in each engine (typst and docx, every page rendered at 60 dpi and viewed 2026-10-22; see the review below) |

Build, from the repo root (`PATH` must include the toolchain, see the brief's setup):

```sh
sh tools/render.sh courts/sixth-circuit/michigan/federal/western-district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/sixth-circuit/michigan/federal/western-district/complaint complaint usage/FILED-EXAMPLE-complaint.pdf
```

`tools/render.sh` writes `usage/OUTPUT-<id>.typst.pdf` (`--engine docx`: `usage/OUTPUT-<id>.docx` and `.docx.pdf`); `sh tools/check.sh <this folder> --engine typst|docx` runs the gates.

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| LCivR 10.1 (W.D. Mich.) | All documents double spaced, 8 1/2 x 11, one side; type no smaller than 12 point; margins at least one inch. No typeface is named (checked 2026-10-15 against the rule text, extracted with `pdftotext`). (Electronic filings must be PDF: LCivR 5.7(d)(i), same source.) | Local Civil Rules, as posted: https://www.miwd.uscourts.gov/sites/miwd/files/Local%20Civil%20Rules.pdf (text dated "Updated February 1, 2018"; the court's rules page shows last modified January 1, 2019). | `type-size = 12pt`, `pitch-body = 24pt`, `margin = 1in` (typst/miwd-complaint.typ; docx/reference.xml). |
| LCivR 10.3 | Date of signing and the address and telephone number of the signing attorney. | same | `signature` frontmatter (`signer`, `lines`), `date`. |
| LCivR 5.1 | A civil cover sheet obtained from the Clerk is filed with each new case. | same | Not produced (a separate form). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `court-title`, `caption`. The Rule 7(a) designation is in the title. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | same | `allegations()`: every paragraph is numbered 1, 2, ... until the `numbering_stops_at` heading. |
| Fed. R. Civ. P. 11(a) | Every paper signed by at least one attorney, stating the signer's address, e-mail address and telephone number. | https://www.law.cornell.edu/rules/frcp/rule_11 (verified 2026-10-14, lead-in text) | `signature-block`. |
| Fed. R. Civ. P. 5.2(a) | Social-security, taxpayer, birth-date, minor and financial-account information is redacted. | https://www.law.cornell.edu/rules/frcp/rule_5.2 | Author responsibility (not checked by the template). |

Not produced by this template (separate filings or author responsibility): the civil cover sheet (LCivR 5.1), the summons, the Rule 7.1 disclosure statement, the redaction of Rule 5.2 information (author), and any W.D. Mich. certificate of service.

## Layout (as built)

Both engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch (24 pt double, 13.8 pt single), the spaces between blocks explicit, first-fit ragged-right breaking without kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does.

- Cover, page 1 (no number): court title centered in bold (three single lines, the division from the frontmatter); 24 pt below it the caption (the parties single-spaced in a 3.25 in column closed by a rule on its right and under it, "v." between them; 0.35 in to the right the case number and the judge, blanks when the sample has none, and 24 pt below them the title in bold); 48 pt below it the counsel block, single spaced, at the left.
- Page 2 opens with the title centered in bold, then (one blank double line below) the lead-in paragraph.
- Body: double spaced (24 pt pitch), first-line indent 0.5 in. Numbered paragraphs: the number in a 0.5 in box from the indent, the text from 1 in (the docx tab), wrapped lines flush left. Headings at the type size on the body pitch, centered and bold, level 1 in capitals, each kept with the next block.
- Lists (the request for relief) are lettered A., B., ...: the letter 0.5 in in, the text hanging at 0.9 in; a list goes on across blank lines.
- Signature: 24 pt below the last paragraph, single spaced: "Dated:" and the date at the left of the first line; "Respectfully submitted," the firm, "By: /s/" the signer and the remaining lines from 2.8 in. The last paragraph (or list item) is kept on one page with it, so it never stands alone on a page.
- Page numbers centered at the foot of every page after the cover, in a single-pitch line whose box ends 0.5 in above the edge (convention; the rules set no footer).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number` (blank prints a blank line), `judge` (blank prints a blank line), `division`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `counsel` (list of `{names, lines}` groups), `lead_in` (optional, unnumbered), `date`, `signature` (`firm` list, `signer` string, `lines` list), `numbering_stops_at` (heading text after which paragraphs are not numbered; the request for relief).
- Body: blank-line-separated chunks. `#` heading (level 1 centered bold capitals), `##` (level 2 centered bold), `###` (level 3 centered bold); a list (`1.` or `-` items, lettered by the template, across blank lines); or a paragraph (numbered by the template). Do not type paragraph numbers.
- Not supported: tables, footnotes (none used), raw typst.

## Review (Gate 2 equivalent, current PDFs)

Each page of `OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx.pdf` was rendered at 60 dpi and viewed side by side (2026-10-22); the two engines set the same lines on the same pages (XENG-001..003 PASS, 198/198 lines). The comparison is with the primary exemplar (Google, filed 06/27/25), and with the second filer (Cohen, filed 09/16/26) for layout conventions.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | Google p.1 (caption, counsel) | Court title, caption with its rule, case number and judge blanks, title in the right column, counsel below the caption. The filed page carries a CM/ECF header the clerk's system adds; the template does not produce it. Cohen p.1 places the title below the caption; both conventions appear. | ACCEPTED (the clerk's header is not author content; title placement is a tier-2 choice seen in both filers) |
| 2 | Google p.2 | Title centered, lead-in, "JURISDICTION AND VENUE", paragraphs 1 to 7, "PARTIES" on the pitch. | PASS |
| 3 | Google p.3 | Paragraphs 8 to 14, "GENERAL ALLEGATIONS" centered; double spaced, no overlap. | PASS |
| 4 | Google p.4 | Paragraphs 15 to 23, numbering continuous. | PASS |
| 5 | Google p.9 (general allegations) | Paragraphs 24 to 32. | PASS |
| 6 | Google p.15 (count I) | Paragraphs 33 to 35, "CLAIMS FOR RELIEF", "COUNT I", its two-line subtitle and "(Against All Defendants)" centered, paragraphs 36 to 40. | PASS |
| 7 | Google p.40 (prayer) | Paragraphs 41 and 42, "REQUEST FOR RELIEF" unnumbered, items A to E hanging; the page ends five lines short because the jury demand is kept with its paragraph and the signature. | PASS |
| 8 | Google p.41 (jury demand, signature) | "JURY DEMAND", its paragraph, date and signature block together. | PASS |

Tier-2 items that are open choices and are recorded as accepted:

- **Font (ACCEPTED).** LCivR 10.1 names no typeface. The template sets Times New Roman, as the Google exemplar (Cohen uses Garamond).
- **Signature.** The Google exemplar signs after the prayer and again after the jury demand. The template prints one signature block, after the jury demand. No rule requires the repeat.

## Overlay

`just overlay courts/sixth-circuit/michigan/federal/western-district/complaint` writes the red/blue overlay of the typst render on the primary exemplar to the gitignored `.overlay/` (a diagnostic, not a score). The differences are the sample's paragraph numbers (they start at 1 and do not match the filed numbers), the omitted paragraphs and the boxed title of the filed caption.

## Known gaps

1. **Sample is a portion.** The filing is 42 pages; the sample carries filed paragraphs 1 to 26, 29 to 38, 41 to 46 and 69 to 75, the request for relief and the jury demand. Paragraph numbers in the sample run from 1.
2. **One filer per type is the brief's minimum; two are collected.** Both are in `usage/`. Gate 2 was done against the primary; the second filer was compared for layout only.
3. **Font** (above): Times New Roman in both engines.
4. **Not produced:** cover sheet (JS-44), summons, Rule 7.1 disclosure, Rule 5.2 redaction (author), certificate of service.
5. **Checker.** `tools/check.sh` runs on this folder (typst and docx: every gate green, 2026-10-22). `tools/check-selftest.sh` needs a court folder with `court.json` and does not run here.
6. **Proposed local-rule change.** Administrative Order 26-RL-054 (June 26, 2026; comment period closed July 27, 2026; https://www.miwd.uscourts.gov/sites/miwd/files/Admin%20Order%2026-RL-054.pdf) proposes the same LCivR 10.1 text, with an e-mail address added to LCivR 10.3. I did not find a final adopted version. Check before landing.
7. **Caption placement.** The Google exemplar places the title at the right of the caption and repeats it on page 2; the template does the same.

## Searches (exemplar)

CourtListener search for W.D. Mich. complaints (`court=miwd`, RECAP `type=r`, filed 2024 to 2026). Candidates were downloaded and checked for a text layer. Gulley (2009, scanned) and Phifer (2008, no RECAP PDF) were set aside for age. Chosen: Google (42 pp., Times, counsel-drafted) and Cohen (45 pp., Garamond, counsel-drafted).

## Engines

DOCX (`docx/`): `sh tools/render.sh --engine docx <this folder> usage/INPUT-complaint.md` writes `usage/OUTPUT-complaint.docx` and its LibreOffice PDF. `fb render` builds the styles from `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`, Times New Roman 12 pt, 24 pt and 13.8 pt exact line boxes; the headings, "Numbered Paragraph" and "List Letter") and runs `docx/miwd-complaint.lua` on `lib/docx/xengine.lua`, which writes the cover, caption, counsel block, body, signature, the page-number footer (`$FORMBOOK_FOOTERS`, none on the cover) and the last section (`$FORMBOOK_FINAL`). pandoc reads the sample as CommonMark, as cmarker does; a frontmatter line that starts like a list label ("(313) 567-6170") is set from its text as written (`$FORMBOOK_META`), since pandoc keeps only the item's text. There are no shell scripts and no committed `reference.docx` (were `docx/build-reference.sh`, `render.sh`, EB Garamond, until 2026-10-22).

- Gate 4: XENG-001..003 PASS (8/8 pages, 198/198 lines), `params.cross_engine: gate` in `eval.yaml`.
- Differs from typst by design: paragraph numbers and list letters are typed text and a tab, not Word automatic numbering (a number inserted by hand does not renumber the rest); the caption rule is a cell border (its 0.75 pt taken off the cell's bottom margin, as LibreOffice sets it below the row).
- Word limits in `docs/DOCX.md` that do not apply: no TOC, TOA or pleading line numbers in this doc type (LCivR 10.1 sets none).
