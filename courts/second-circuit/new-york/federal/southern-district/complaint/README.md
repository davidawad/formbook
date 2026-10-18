# S.D.N.Y. (nysd): complaint

Doc type: **complaint** (with a jury demand) in the United States District Court for the Southern District of New York (`nysd`).
Folder: `courts/second-circuit/new-york/federal/southern-district/complaint/`. Sibling doc type: `../motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nysd-complaint-sacchi26cv08973.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nysd-complaint-sacchi.md` (a partial transcription of the 20-page filing: the caption, most of the allegations, the causes of action it covers, the prayer and the signature; see Sample) |
| typeface | face required: **none** (the joint rules name no face; see NYSD-FORM-002). Vendored substitute: **none needed**, EB Garamond kept per `docs/FONTS.md` ("No face named"). Fit: n/a. `pdffonts`: EBGaramond-Regular and -Bold, embedded. |
| render | ok: `usage/OUTPUT-nysd-complaint-sacchi.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-15) |
| overlay | ok: `usage/OVERLAY-sacchi-complaint.pdf` and `OVERLAY-sacchi-complaint.txt` (re-generated 2026-10-15 against `usage/SAMPLE-nysd-complaint-sacchi26cv08973.pdf`, the RECAP copy named in `usage/SOURCE.md`) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and looked at, again on 2026-10-15 after the re-render) |

Naming note: the brief asked for `usage/<id>.md` and `<id>-overlay.pdf`. The tools (`tools/render.sh`, `tools/overlay.sh`) and the repo convention use `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, so the files follow that. The id is `sacchi-complaint`.

Not set here: `court.json` status, the court-root `typst/` and `usage/` folders (untouched), `STATUS.md`, the tracker.

## Governing rules

Primary sources, both read on 2026-10-14:

- **S.D.N.Y. and E.D.N.Y. Joint Local Civil Rules, as amended effective January 2, 2026**, https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf (PDF, 144 pages; the rule text is quoted from it).
- **Fed. R. Civ. P. 8(a), 10(a)-(c)**, Cornell LII (https://www.law.cornell.edu/rules/frcp/rule_8, https://www.law.cornell.edu/rules/frcp/rule_10). Quoted in part; the text of Rule 10(a)-(c) was checked against the Cornell page.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NYSD-FORM-001 | Local Civ. R. 7.1(b)(1) | "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type." | `type-size = 12pt` (footnotes also 12 pt, single-spaced) |
| NYSD-FORM-002 | Local Civ. R. 7.1(b) | The joint rules name **no typeface**. Typeface is the vendored EB Garamond. See gaps. | `font-family` |
| NYSD-FORM-003 | Local Civ. R. 7.1(b)(3) | "all text must be double-spaced, except for headings, text in footnotes, or block quotations, which may be single-spaced." | `body-leading = 1.35em` (24 pt pitch at 12 pt), headings, block quotes, footnotes and signature block single-spaced |
| NYSD-FORM-004 | Local Civ. R. 7.1(b)(2) | "all documents must have at least one-inch margins on all sides." | `margin = 1in` |
| NYSD-CAP-001 | Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | `cover()`, `caption-table()`: court name (two lines), parties, `No.` file number, `title` (COMPLAINT) |
| NYSD-CAP-002 | Fed. R. Civ. P. 10(a) | "The title of the complaint must name all the parties." | `caption` (every side, `names` and `designation`) |
| NYSD-PAR-001 | Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs." | `allegations()` numbers each paragraph 1, 2, ...; headings, lists, block quotes, the WHEREFORE paragraph and the jury demand are not numbered |
| NYSD-PAR-002 | Fed. R. Civ. P. 10(b) | "each limited as far as practicable to a single set of circumstances." | Author content; not checked by the template |
| NYSD-CONT-001 | Fed. R. Civ. P. 8(a) | A claim needs (1) a statement of jurisdiction, (2) a short and plain statement of the claim, (3) a demand for the relief sought. | Author content; the template does not check it (see gaps) |
| NYSD-CONT-002 | Fed. R. Civ. P. 10(c) | Exhibits attached to a pleading are part of it. | Not produced; the sample mentions Exhibit A only in passing |

Not produced by this template (separate filings, not verified here): civil cover sheet, the Rule 7.1 disclosure statement, the summons, a Notice of Related Case (Local Civ. R. 1.6 covers related cases), and the assigned judge's individual practices, which can add rules of their own.

## Layout

- Letter paper, one-inch margins, page number centered at the top of the page (the rule does not name a footer; the exemplar has a centered page number).
- No pleading-paper line numbers and no rules at the margins: the SDNY joint rules have no numbered-line requirement, and the exemplar is not on pleading paper.
- Caption: court name centered (bold caps), the parties on the left with a rule at the right and bottom, and on the right `ELECTRONICALLY FILED`, the file number, `Hon. ___`, the legends (`CLASS ACTION`), the title (`COMPLAINT`) and `JURY TRIAL DEMANDED`. The layout is a convention; the rules set no caption layout.
- The lead-in ("Plaintiff ... hereby alleges as follows:") follows the caption on page 1; the body begins on page 1 (the exemplar does too).
- Headings: level 1 centered caps; level 2 centered bold; level 3 bold italic at the left. Each heading is sticky (it never ends a page).
- Numbered paragraphs: a 0.5 in first-line indent, the number, then the text, with the text running to the left margin.
- Prayer items and class questions are lettered (a), (b), ... by the template. The exemplar numbers its prayer items 1 to 11; the letters are the convention used in the CAND complaint template and are kept for consistency across the repo.
- Block quotations are indented 0.75 in and single-spaced (NYSD-FORM-003).
- Footnote definitions (`[^label]: text`) are attached to the paragraph that refers to them; cmarker cannot resolve a reference to a definition in another chunk.
- Signature block: "Dated:" at left, "Respectfully submitted," and the signer at right. The exemplar signs twice (after the prayer, and after the jury demand); the template prints one signature block after the jury demand.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `court` (list of lines), `case_number`, `electronic` (true prints `ELECTRONICALLY FILED`), `judge` (optional, `Hon. ___`), `caption` (list of `{names, designation}`; "v." is inserted between sides), `legends` (optional, above the title), `title`, `legends-after` (optional, below the title, e.g. `JURY TRIAL DEMANDED`), `lead_in` (optional), `date`, `signature` (`signer`, `lines`).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2) and `###` (level 3) headings; markdown lists (lettered); `>` block quotations; `[^label]` footnotes; a paragraph beginning `WHEREFORE` is not numbered; so is any paragraph under a heading containing `JURY TRIAL`.
- The sample must not type paragraph numbers: the template numbers the allegations.

## Sample

- `usage/INPUT-nysd-complaint-sacchi.md` transcribes the exemplar's caption, the lead-in, the opening headline, filed paragraphs 1 to 7, 10 to 13, 16 to 20 (jurisdiction, venue, parties), 23 to 28 and 30 and 35 (facts and class allegations, with the class question list), the first and second causes of action (36 to 50), the WHEREFORE paragraph, the prayer for relief, the jury demand and the signature block.
- Not transcribed: filed paragraphs 8, 9, 14, 15, 21, 22, 29, 31 to 34, and the third to fifth causes of action (51 to 58). These are left out to keep the render at 11 pages; the frontmatter header comment says the same.
- The filed paragraph numbers are not reproduced (the template numbers from 1). The filing itself repeats "27" after "35"; the template numbers paragraphs in order.
- Footnotes transcribed: the executive order cite (filed note 2, on paragraph 1; the render numbers it 1) and the New Jersey arbitration note (filed note 4, on paragraph 11; the render numbers it 2). Filed notes 1, 3 and 5 are not transcribed (note 1 repeats the executive order cite under the headline; notes 3 and 5 sit on omitted paragraphs).
- Text was read from the exemplar's native text layer (`pdftotext`); there is no OCR in this sample.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/second-circuit/new-york/federal/southern-district/complaint usage/INPUT-nysd-complaint-sacchi.md
sh tools/overlay.sh courts/second-circuit/new-york/federal/southern-district/complaint sacchi-complaint
```

- `usage/OUTPUT-nysd-complaint-sacchi.typst.pdf`: 11 pages. typst compiled with no warnings; `render.sh` fails on any warning. Vendored fonts only (`pdffonts`: EBGaramond-Regular and -Bold, embedded).
- `usage/OVERLAY-sacchi-complaint.pdf` and `.txt`: red = our render, blue = exemplar, black = both agree. Pages are paired by word overlap, which is coarse. The overlay is a diagnostic, not a score. Pages 1 and 2 pair with the filed pages 1 and 2 (81% and 71% overlap). Pages 3 to 7 pair with filed pages 3 to 11 at 33% to 55%, because the sample omits paragraphs and the filed document is 20 pages long. Page 11 (the signature) pairs with filed page 19 at 29%, which is the lowest, because the filed signature page sits on a different page from the sample's.

## Visual review (Gate 2 record, all 11 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, court title, lead-in, start of body | OK after the body-loop fix: paragraphs now start on their own lines (an earlier render ran them together), and the headline stays with paragraph 1. The caption's left column breaks cleanly. |
| 2 | Headline (single-spaced, sticky), paragraphs 1 to 5, footnote 1 | OK. Footnote number now set apart from its text (an earlier render ran the number into the text). |
| 3 | Paragraphs 5 to 8, block quotation begins | OK. |
| 4 | Block quotation (single-spaced, indented), paragraphs 9 to 10, headline, paragraph 11, footnote 2 | OK. |
| 5 | Paragraph 11 continues, JURISDICTION AND VENUE, paragraphs 12 to 13, OTHER PARTIES, paragraph 14 | OK. |
| 6 | Paragraphs 15 to 20, FACTUAL ALLEGATIONS, CLASS ALLEGATIONS heading, paragraph 21 | OK. |
| 7 | Paragraphs 21 to 23, block quotation (class definition), lettered class questions (a) to (d) | OK. |
| 8 | Paragraphs 24 to 33, FIRST CAUSE OF ACTION and SECOND CAUSE OF ACTION headings with subtitles | OK. Headings are not at the foot of the page. |
| 9 | Paragraphs 34 to 39, WHEREFORE (unnumbered), PRAYER FOR RELIEF, prayer items (a) to (e) | OK. |
| 10 | Prayer items (e) continues to (k), DEMAND FOR JURY TRIAL (unnumbered) | OK. |
| 11 | Signature block | OK. The block sits alone on page 11 after the jury demand on page 10: no heading or paragraph is stranded. |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one per doc type. The tier-2 bar (two or three filers) is not met. The CourtListener search found few SDNY complaints with a RECAP copy (most had `is_available: false`); only Sacchi had a usable one. Filers' conventions are therefore judged from one document.
2. **Typeface.** The joint rules name no typeface, and the exemplar does not set one either: its embedded fonts are Liberation Sans, Courier New and Cambria (`pdffonts`). Kept as EB Garamond on 2026-10-15 because the court's rules name no face (`docs/FONTS.md`, "No face named"). EB Garamond has a smaller x-height than Times at 12 pt, so the text looks smaller than a Times filing. 12 pt meets the rule. Whether the bench expects a Times-metric face is a question for David. If so, the substitute is Liberation Serif (metric-compatible); the change would be one line (`font-family`) plus a re-render.
3. **Sample is partial.** Eleven pages of the 20-page filing (see Sample). The overlay's pairs for the omitted sections are weak by design.
4. **Footnote size.** Footnotes are 12 pt, which the rule allows (10 pt is also allowed). Single-spaced, as the rule permits.
5. **Caption.** The rules set no caption layout. The exemplar uses a colon column; the template uses a rule on the right and bottom of the party block (the convention used in the CAND complaint template too). ACCEPTED as a convention.
6. **Lettered prayer items.** The exemplar numbers them; the template letters them. Convention, not a rule.
7. **No check on NYSD-CONT-001 or NYSD-PAR-002.** Whether the complaint has jurisdiction, a claim and a demand (Rule 8(a)), and whether each paragraph is limited to one set of circumstances (Rule 10(b)), is author content. The template does not check either.
8. **Judge's individual practices.** Not in the template. Judges in this district set their own word limits, typeface and filing rules; check the assigned judge's individual practices before filing.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The Gate 2 table above is the review record for this doc type.

## Engines

DOCX (`docx/`: `build-reference.sh` makes `reference.docx`; `complaint.lua` builds the caption, the numbering and the signature). Output: `usage/OUTPUT-nysd-complaint-sacchi.docx` and `.docx.pdf` (LibreOffice PDF, 9 pages). Opened and converted by LibreOffice without error (no Word here).

- Matches the typst output: letter paper, 1 in margins; EB Garamond 12 pt (`pdffonts`: EBGaramond-Regular and -Bold, embedded); body double spaced at an exact 24 pt pitch; 0.5 in first-line indent; numbered paragraphs 1, 2, ...; the WHEREFORE paragraph and the jury demand unnumbered; lettered prayer and class questions (a), (b), ...; block quotation indented and single spaced; footnotes single spaced; centered page number at the top; caption with the rule at the right and bottom of the party block; signature block after the jury demand.
- Differs: docx headings are 12 pt bold (the typst headings render larger). Both meet NYSD-FORM-001; not chased. The docx runs 9 pages against 11 for typst; the cause (heading size, spacing around headings) was not investigated. The caption is a Word table, so border weight may differ slightly in Word.
- Pages reviewed: 9 of 9, each rendered at 60 dpi and compared with the typst page. Pages 1 to 6 were looked at before the last fix (lettered lists and the WHEREFORE check), which touches only text on pages 7 to 9.
- BLOCKED: `tools/check.sh <doc-dir> --engine docx` cannot run on this doc-type folder: there is no `checks.yaml` and no `court.json` (the script prints `open .../checks.yaml: no such file or directory` for every check and then fails on an arithmetic line). The gates (0 to 3) for docx are therefore not run. Check IDs affected: all (no checks file). Reason: this folder has no court-level check set, as the brief notes in "Known gaps", item 9.
