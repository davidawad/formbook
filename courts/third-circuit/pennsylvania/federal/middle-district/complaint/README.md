# pamd: complaint

Doc type: **complaint** (civil complaint, Fed. R. Civ. P. 7(a)(1)) in the United States District Court for the Middle District of Pennsylvania (`pamd`).
Folder: `courts/third-circuit/pennsylvania/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/FILED-EXAMPLE-complaint.pdf` (primary; transcribed) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second caption style; compared, not transcribed). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md`: caption, paragraphs 1–65 (through Count I), prayer, jury demand, signature. Counts II–VII are omitted. |
| render | ok (2026-10-22): `usage/OUTPUT-complaint.typst.pdf`, 13 pages, and `usage/OUTPUT-complaint.docx` with its LibreOffice PDF, 13 pages; `fb render`, vendored Times New Roman only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 13 of 13, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |

Naming: `usage/` holds `INPUT-complaint.md`, `OUTPUT-complaint.typst.pdf`, `OUTPUT-complaint.docx` and `.docx.pdf`, the two `FILED-EXAMPLE-` files and `SOURCE.md` (`fb usage` prints the names).

## Governing rules

Sources and dates. The rule texts below were read on 2026-10-14.

- **M.D. Pa. LR 5.1** (form of papers). Read from search excerpts that quote the rule (courtrules.net, which blocks direct fetches; and a search summary). Not read on the court's own site in this pass. Summary as read (paraphrase, not quoted): papers on 8½ × 11 in paper; typeface no smaller than a 14 point word-processing font (or pica if typewritten); text double-spaced, except quotations of more than two lines, with headings and footnotes single-spaced; margins at least one inch on all four sides; page numbers in the margins. Confirm against https://www.pamd.uscourts.gov/ before a real filing.
- **M.D. Pa. LR 8.1** (damages): the demand for judgment "may set forth generally that the party ... is entitled to monetary relief but shall not claim any specific sum where unliquidated damages are involved." Source: the court's "Local & Federal Rules Excerpts" PDF, https://www.pamd.uscourts.gov/sites/pamd/files/Local%20%26%20Federal%20Rules%20Excerpts.pdf (14 pp., Word-generated, file date 2020-03-04; read 2026-10-14).
- **M.D. Pa. LR 5.2(d)** (personal data identifiers, same excerpt): SSNs to the last four digits; minor children by initials; birth dates to the year; financial account numbers to the last four digits. Not checked by the template; it is the filer's responsibility.
- **Fed. R. Civ. P. 8(a)**: short and plain statement of jurisdiction, claim and relief. Cited, not re-fetched in this pass.
- **Fed. R. Civ. P. 10(a)–(b)**: caption (court, title, file number, Rule 7(a) designation); numbered paragraphs, each limited as far as practicable to one set of circumstances. Cited, not re-fetched in this pass.
- **Fed. R. Civ. P. 38(b)**: jury demand (caption legend and body). Cited, not re-fetched in this pass.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| PAMD-CMP-001 | LR 5.1 | 8½ × 11 paper; standard face; 14 point or larger | `typst/pamd-complaint.typ`: `type-size = 14pt`, `font-family` |
| PAMD-CMP-002 | LR 5.1 | Double-spaced text; 32 pt baseline pitch (the Times 14 pt filed exemplars) | `pitch-body = 32pt` (the cross-engine line box: every body line 32 pt) |
| PAMD-CMP-003 | LR 5.1 | Margins ≥ 1 in, all four sides; page numbers in the margin | `margin-all = 1in`; the page number sits in the bottom margin |
| PAMD-CMP-004 | FRCP 10(a) | Court title (two lines, centred); caption with the party names, the civil action number, the title of the paper | `cover()`, `caption()` |
| PAMD-CMP-005 | FRCP 10(b) | Numbered paragraphs; the sample's `^` marks the unnumbered ones (WHEREFORE, jury demand) | `body-chunks()` |
| PAMD-CMP-006 | LR 8.1 | No specific sum where damages are unliquidated | authored content, not checked by the template |
| PAMD-CMP-007 | FRCP 38(b) | "JURY TRIAL DEMANDED" in the caption (`right` column) and a jury demand at the end | caption row, sample `JURY DEMAND` section |
| PAMD-CMP-008 | FRCP 11(a) | Signature, with the attorney's address, telephone and email, under the paper | `signature-block()` (fields from frontmatter `signature.lines`) |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Rule 7.1 disclosure statement; the summons; any corporate or citizenship disclosure the case requires; the filing fee. The Dillow and Anderson exemplars both carry a civil cover sheet as an attachment.

## Layout

- Letter paper, 1 in margins, Times New Roman 14 pt (LR 5.1(c)), the cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 32 pt for the body (double spacing, the pitch of the 14 pt filed exemplars), 16 pt for single lines (court title, caption, title, signature); the spaces between blocks explicit. Page number 12 pt, centred in a 13.8 pt line ending 0.5 in above the page edge (in the margin, LR 5.1(c)).
- Caption: court title centred on two single lines; a blank single line; one single line per caption row of the sample (the party text with its indent, a ":" on every row, the right column for the civil action number and the jury legend), so the colons line up in both engines; the title bold centred 32 pt below, the text a blank single line below it.
- Numbered paragraphs: the number at 0.5 in in a 0.5 in box, the text at 1.0 in (a tab in the docx); continuation lines at the margin.
- Headings at the type size on the body pitch with no space of their own: level 1 centred bold caps; level 2 centred bold; level 3 bold italic. Kept with the next block, so a heading never ends a page.
- Lettered prayer items: (a), (b) ..., the letter half an inch in, the text hanging at 0.9 in.
- Signature block, 32 pt below the last paragraph and kept with it (it never stands alone on a page): "Date:" at the left of the first line, "Respectfully submitted," at 2.8 in (a tab in the docx), a 3.2 in signature line in a single line's box 16 pt lower, the signer's lines single-spaced 6 pt below it.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `title` (cover title, caps are applied by the template); `caption` (a list of rows: `left` text, optional `indent` in inches, optional `right` text; one row per caption line, and the colons are generated); `lead_in` (unnumbered, optional); `date`; `signature.lines` (signer first, then address and email, then the role line).
- Body: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3). A `1.` list is lettered (a), (b) ... A chunk starting with `^` is a paragraph that is not numbered. Any other chunk is a numbered paragraph.
- Do not put numbers in the text of an allegation: the template numbers them.
- Not supported: tables, footnotes, raw typst, forced line breaks.

## Overlay

`just overlay <dir>` (`tools/overlay.sh`) pairs each rendered page with the exemplar page that shares the most words (word overlap, not position) and writes `.overlay/<doc path>/OVERLAY-complaint.pdf` and `.txt` (not committed). A diagnostic, not a score.

## Known gaps and open choices

1. **Font.** LR 5.1 names no face. Times New Roman 14 pt (vendored), the face of the filed exemplars and the house standard, in every engine.
2. **Caption style.** Dillow uses a ":" column; Anderson uses a ")" column. Both are seen in M.D. Pa. filings. The template uses ":" (ACCEPTED, see the review).
3. **Tier-2 exemplars.** Two complaint exemplars from two filers exist. The overlay is against Dillow only; the Anderson comparison is page 1 by eye. A full overlay against Anderson would need a second `OVERLAY-` pair, not run here.
4. **Sample is partial.** The sample transcribes paragraphs 1–65 (through Count I), the prayer, the jury demand and the signature. Counts II–VII (paragraphs 66–97) are not transcribed. The sample's paragraph numbers 1–65 match the filed numbers.
5. **Rule text not on the court site.** LR 5.1 was read from a search summary of a mirror, not from the court's own PDF. The court's excerpt PDF (2020 file date) does not include LR 5.1. Confirm LR 5.1 and check whether any later amendment changed it.
6. **No check of LR 5.2 or LR 8.1 wording.** The template does not check content (identifiers, unliquidated damages). These are the author's responsibility.
7. **Page-number placement.** Page numbers are centred in the bottom margin at 12 pt, which LR 5.1 allows.
8. **Cover sheet and other filings.** Not generated (see above).

## Review

Gate 2 equivalent, recorded here (this doc type has no `reviews/` folder). Every page of `OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx.pdf` was rendered at 50 dpi and viewed side by side (2026-10-22); the two engines set every page alike.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (colons on every row, "CIVIL ACTION NO." and "JURY TRIAL DEMANDED" at the right), title, lead-in, PRELIMINARY STATEMENT, paragraphs 1–2 | Pass. |
| 2 | Paragraphs 2–6, JURISDICTION AND VENUE | Pass. Ends two lines short: "III. PARTIES" moves to page 3 with its paragraph. |
| 3 | III. PARTIES, paragraphs 7–13 | Pass. |
| 4 | ADMINISTRATIVE EXHAUSTION, FACTUAL ALLEGATIONS, "Plaintiff's Employment", paragraphs 14–20 | Pass. |
| 5 | Paragraphs 21–28, "Plaintiff Reports Sexual Harassment" | Pass. |
| 6 | Paragraphs 29–34, "The November 11, 2024 Medical Episode" | Pass. |
| 7 | Paragraphs 35–41, "Plaintiff Is Medically Cleared to Return to Work" | Pass. Ends short: the next heading stays with its paragraph. |
| 8 | "Defendant's Excessive Medical Demands", paragraphs 42–46 | Pass. |
| 9 | Paragraphs 47–54, "Defendant Terminates Plaintiff's Employment" | Pass. |
| 10 | Paragraphs 55–59 | Pass. Ends short: COUNT I and its title stay with paragraph 60. |
| 11 | COUNT I, its title, paragraphs 60–65 | Pass. |
| 12 | PRAYER FOR RELIEF, the unnumbered WHEREFORE paragraph, items (a)–(i) | Pass; the items' text hangs at 0.9 in. |
| 13 | JURY DEMAND, its paragraph, the signature block | Pass; the signature is kept with the last paragraph (the old render left it alone on page 13). |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 258/258 lines, 13/13 pages).

Tier 2 is compared against two filed exemplars (Dillow page by page through the overlay; Anderson page 1 only, by eye). The render matches the filed exemplars in: type size (14 pt), line pitch (32 pt), margins, caption structure, the numbered-paragraph indent, the centred bold headings, the prayer's lettered items, and the single-spaced signature block. It differs in: the face (EB Garamond, gap 1) and the caption-column style (gap 2).

## Changes made during review

- Headings rendered at typst's default heading size (about 1.4 × the body text). Fixed: headings use the 14 pt type size.
- The WHEREFORE paragraph and the jury demand were numbered. Fixed: the sample marks them with `^` (not numbered).
- A `plain-paragraph` definition was used before its definition. Fixed: defined before `allegations()`.
- The court title used a forced line break (`\`). Fixed: two stacked lines (CLAUDE.md bans forced line breaks in templates).

- The cross-engine port (fb-595.68.35): em leadings and fixed-height caption rows gave way to line boxes of the pitch; the signature block, which stood alone on the last page, is kept with the last paragraph; the docx named EB Garamond and set its own spacing (a 32 pt blank paragraph between blocks), now Times New Roman on the typst spaces.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/pamd-complaint.typ`): the reference.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 14 pt; Body Text in exact 32 pt line boxes with a 0.5 in first-line indent, single lines 16 pt; the heading levels at the type size on the body pitch; "Numbered Paragraph" with a tab 1 in from the margin; "Lettered" hanging at 0.9 in; letter page, 1 in margins, the footer 0.5 in above the edge) and `docx/pamd-complaint.lua` on `lib/docx/xengine.lua`, which writes the court title, the caption table (one single line per row in each column), the title, the lead-in, the numbered paragraphs and lettered items (numbers typed, as typst types them), the signature kept with the last paragraph, the 12 pt page-number footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (258/258 lines, 13/13 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
