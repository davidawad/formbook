# pamd: complaint

Doc type: **complaint** (civil complaint, Fed. R. Civ. P. 7(a)(1)) in the United States District Court for the Middle District of Pennsylvania (`pamd`).
Folder: `courts/third-circuit/pennsylvania/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-dillow-4-26-cv-03021-complaint.pdf` (primary; transcribed) and `exemplars/FILED-EXAMPLE-anderson-4-26-cv-03004-complaint.pdf` (second caption style; compared, not transcribed). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-dillow.md`: caption, paragraphs 1–65 (through Count I), prayer, jury demand, signature. Counts II–VII are omitted. |
| render | ok: `samples/OUTPUT-dillow.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-dillow.pdf` and `OVERLAY-dillow.txt` (red = ours, blue = Dillow exemplar) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed; see "Review" below) |

Naming: the tools (`tools/render.sh`, `tools/overlay.sh`) read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`, so the sample id is `dillow` and the files carry those prefixes.

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
| PAMD-CMP-002 | LR 5.1 | Double-spaced text; 32 pt baseline pitch (the Times 14 pt filed exemplars) | `pitch`, `body-leading` (verified: the render's line pitch is 32 pt) |
| PAMD-CMP-003 | LR 5.1 | Margins ≥ 1 in, all four sides; page numbers in the margin | `margin-all = 1in`; the page number sits in the bottom margin |
| PAMD-CMP-004 | FRCP 10(a) | Court title (two lines, centred); caption with the party names, the civil action number, the title of the paper | `cover()`, `caption()` |
| PAMD-CMP-005 | FRCP 10(b) | Numbered paragraphs; the sample's `^` marks the unnumbered ones (lead-in, WHEREFORE, jury demand) | `allegations()`, `plain-paragraph()` |
| PAMD-CMP-006 | LR 8.1 | No specific sum where damages are unliquidated | authored content, not checked by the template |
| PAMD-CMP-007 | FRCP 38(b) | "JURY TRIAL DEMANDED" in the caption (`right` column) and a jury demand at the end | caption row, sample `JURY DEMAND` section |
| PAMD-CMP-008 | FRCP 11(a) | Signature, with the attorney's address, telephone and email, under the paper | `signature-block()` (fields from frontmatter `signature.lines`) |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Rule 7.1 disclosure statement; the summons; any corporate or citizenship disclosure the case requires; the filing fee. The Dillow and Anderson exemplars both carry a civil cover sheet as an attachment.

## Layout

- Letter paper, 1 in margins, 14 pt EB Garamond, 32 pt double-spaced body text (about 20 lines per page).
- Caption: court title centred on two lines; the party column with a ":" column; the right column for the civil action number and the jury legend. Each caption row is a fixed 16 pt block, so the colons line up.
- Numbered paragraphs: number at 0.5 in, text at 1.0 in; continuation lines at the margin.
- Headings: level 1 centred bold caps; level 2 centred bold; level 3 bold italic. Sticky, so a heading never ends a page.
- Lettered prayer items: (a), (b) ... (`set enum(numbering: "(a)")`).
- Signature block: date at left; "Respectfully submitted," and the signer at right, single-spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `title` (cover title, caps are applied by the template); `caption` (a list of rows: `left` text, optional `indent` in inches, optional `right` text; one row per caption line, and the colons are generated); `lead_in` (unnumbered, optional); `date`; `signature.lines` (signer first, then address and email, then the role line).
- Body: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3). A `1.` list is lettered (a), (b) ... A chunk starting with `^` is a paragraph that is not numbered. Any other chunk is a numbered paragraph.
- Do not put numbers in the text of an allegation: the template numbers them.
- Not supported: tables, footnotes, raw typst, forced line breaks.

## Overlay

`tools/overlay.sh` pairs each rendered page with the exemplar page that shares the most words (word overlap, not position). Pass the Dillow exemplar explicitly (`sh tools/overlay.sh <dir> dillow <exemplar.pdf>`); the default takes the first PDF in `exemplars/`, which is Anderson. Pages 1–10 pair with the same page number. Pages 11–12 (prayer, jury demand, signature) pair with filed pages 16–17 because the sample skips Counts II–VII. The map is in `OVERLAY-dillow.txt`. The overlay is a diagnostic, not a score: word overlap runs 62–85% on the body pages.

## Known gaps and open choices

1. **Font.** LR 5.1 names no face. EB Garamond is the only serif vendored in `fonts/`, and no Times-metric face is vendored. EB Garamond at 14 pt has a smaller x-height than Times at 14 pt, so the text looks smaller than the filed exemplars. The 14 pt minimum is met. A Times-metric font would need an addition to `fonts/`, which this doc type may not make.
2. **Caption style.** Dillow uses a ":" column; Anderson uses a ")" column. Both are seen in M.D. Pa. filings. The template uses ":" (ACCEPTED, see the review).
3. **Tier-2 exemplars.** Two complaint exemplars from two filers exist. The overlay is against Dillow only; the Anderson comparison is page 1 by eye. A full overlay against Anderson would need a second `OVERLAY-` pair, not run here.
4. **Sample is partial.** The sample transcribes paragraphs 1–65 (through Count I), the prayer, the jury demand and the signature. Counts II–VII (paragraphs 66–97) are not transcribed. The sample's paragraph numbers 1–65 match the filed numbers.
5. **Rule text not on the court site.** LR 5.1 was read from a search summary of a mirror, not from the court's own PDF. The court's excerpt PDF (2020 file date) does not include LR 5.1. Confirm LR 5.1 and check whether any later amendment changed it.
6. **No check of LR 5.2 or LR 8.1 wording.** The template does not check content (identifiers, unliquidated damages). These are the author's responsibility.
7. **Page-number placement.** Page numbers are centred in the bottom margin at 12 pt, which LR 5.1 allows.
8. **Cover sheet and other filings.** Not generated (see above).

## Review

Gate 2 equivalent, recorded here (this doc type has no `reviews/` folder). Every page of `OUTPUT-dillow.pdf` was rendered at 60 dpi and viewed.

- Page 1: court title, caption with colons, "CIVIL ACTION NO." and "JURY TRIAL DEMANDED" at the right, title centred, lead-in, paragraph 1 starts on the page. No spill. Pass. Re-viewed after the cover edit (the court title stacked as two lines): unchanged. Pass.
- Pages 2–3: paragraphs 2–13, centred level-1 headings ("JURISDICTION AND VENUE", "III. PARTIES"). The heading at the foot of page 2 moved to page 3 with its paragraph. Pass.
- Pages 4–5: "ADMINISTRATIVE EXHAUSTION", "FACTUAL ALLEGATIONS", the level-2 sub-headings (centred bold), paragraphs 14–28. Pass.
- Pages 6–7: paragraphs 29–43 (43 continues onto page 8), level-2 "The November 11, 2024 Medical Episode" and "Plaintiff Is Medically Cleared to Return to Work" kept with their paragraphs. Pass.
- Pages 8–9: paragraphs 43–56, the sub-heading "Defendant Terminates Plaintiff's Employment". Pass.
- Page 10: paragraphs 57–63, "COUNT I" and its title (two sticky headings), no heading at a page foot. Pass.
- Page 11: paragraphs 64–65, "PRAYER FOR RELIEF", the unnumbered WHEREFORE paragraph, items (a)–(h). Pass. (The WHEREFORE paragraph was numbered "66." in the first render; the `^` marker fixed it.)
- Page 12: item (i), "JURY DEMAND" (unnumbered after the `^` fix), the date, "Respectfully submitted," and the signature block. Pass.

Tier 2 is compared against two filed exemplars (Dillow page by page through the overlay; Anderson page 1 only, by eye). The render matches the filed exemplars in: type size (14 pt), line pitch (32 pt), margins, caption structure, the numbered-paragraph indent, the centred bold headings, the prayer's lettered items, and the single-spaced signature block. It differs in: the face (EB Garamond, gap 1) and the caption-column style (gap 2).

## Changes made during review

- Headings rendered at typst's default heading size (about 1.4 × the body text). Fixed: headings use the 14 pt type size.
- The WHEREFORE paragraph and the jury demand were numbered. Fixed: the sample marks them with `^` (not numbered).
- A `plain-paragraph` definition was used before its definition. Fixed: defined before `allegations()`.
- The court title used a forced line break (`\`). Fixed: two stacked lines (CLAUDE.md bans forced line breaks in templates).
