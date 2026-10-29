# District Court, D. South Carolina (`scd`): motion-brief

Doc type **motion-brief**: the memorandum in support of a Rule 12(b) motion to dismiss, folder `courts/fourth-circuit/south-carolina/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer: defendant's counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the full 7-page memorandum transcribed: caption, cover title, Introduction, Legal Standard, Argument with block quotation, Conclusion, footnote 1, signature block) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 7 pages each, vendored faces only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.9) |
| overlay | ok: `usage/OVERLAY-cobb-motion-brief.pdf` and `usage/OVERLAY-cobb-motion-brief.txt` |
| pages reviewed | 7 of 7 on typst, latex and docx after the move onto the FRCP base (2026-10-29: every page's text layout and the checks' geometry; see "Gate 2 review on the FRCP base") |
| tier-1 font (L.R. 1.05(B)) | Met: **Times New Roman** (one of the three faces the rule names), set in the face itself (the pinned files of `docs/FONTS.md` rule 1; Liberation Serif only as fallback) on typst and docx (see Known gaps) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.S.C. Local Civ. Rule 1.05(A) | Minimum one-inch margins on all sides. | the base's one-inch margins |
| D.S.C. Local Civ. Rule 1.05(B) | Times New Roman, Arial or Courier New. | `font-family` = `("Times New Roman", "Liberation Serif")` |
| D.S.C. Local Civ. Rule 1.05(C) | Minimum 12-point type for caption, text and footnotes. | the base's 12 pt, footnotes too (`footnote.size` 12) |
| D.S.C. Local Civ. Rule 1.05(D) | Only page numbers and document identification may be in margins or smaller than 12 pt. | page number only, centered at the foot |
| D.S.C. Local Civ. Rule 1.05(E) | Double space text, except indented quotations and footnotes. | `pitch.body` 27.6 (Word's double of 12 pt Times); `quote` single-spaced (13.8 pt lines) and indented half an inch |
| D.S.C. Local Civ. Rule 7.05(A) | A memorandum contains a concise summary of the case, a statement of facts with record references, the argument with citations, and any special content the rule for the motion requires. | Sample content (the exemplar's order: Introduction, Legal Standard, Argument, Conclusion); the template does not enforce it |
| D.S.C. Local Civ. Rule 7.05(B)(1) | An initial brief may not exceed 35 double-spaced pages, unless the court grants an exception. | `eval.yaml` `params.page_limit` 35 (DEF-LEN-001, every engine). This sample is 7 pages. |
| FRCP 7(b), 10(a), 11(a) | A motion and its grounds are stated in writing; caption; attorney signature. | `typst/layout.yaml` `front` (caption) and `closing` (signers and firm lines from frontmatter) |
| FRCP 12(b)(6) | The motion (and so the memorandum) asserts failure to state a claim. | Sample content only |

Sources: D.S.C. Local Civil Rules (February 22, 2023), https://www.scd.uscourts.gov/Rules/Civil%20Rules%20-%20Current.pdf, fetched 2026-10-14; Local Civ. Rules 1.05, 7.05 read from that PDF with pdftotext. The same text appears in the May 15, 2017 edition at https://www.scd.uscourts.gov/Rules/2017/Civil%20Rules%20-%20May%2015,%202017.pdf. The FRCP text is cited from the rule as known and was not re-fetched in this session; verify the pin cites before relying on them.

## Template and sample contract

- `typst/main.typ` reads the sample named by `--input sample=` and calls `scd-motion-brief(meta, body)`.
- `typst/layout.yaml` holds every rule number and block (over the FRCP base); `typst/scd-motion-brief.typ` names the face and asserts the required fields. Nothing case-specific and no coordinates measured off the exemplar.
- Frontmatter: `division`, `case_number`, `caption.parties` (each `{names, relator (optional), designation}`), `brief_title`, `signature` (`location`, `dated`, `firm_name`, `by`, `signers`, `firm`). Body: markdown. `##` is a section heading (centered, bold capitals: INTRODUCTION, LEGAL STANDARD, ARGUMENT, CONCLUSION); `###` is a subsection (left, bold, as in the exemplar); footnotes use `[^1]` with the definition at the end of the sample.

Render and overlay (from the repo root; the doc-type folder is the court dir):

```sh
export PATH="$HOME/tb/bin:$PATH"
D=courts/fourth-circuit/south-carolina/federal/district/motion-brief
sh tools/render.sh $D usage/INPUT-motion-brief.md     # -> usage/OUTPUT-motion-brief.typst.pdf
sh tools/overlay.sh $D cobb-motion-brief                      # -> usage/OVERLAY-cobb-motion-brief.{pdf,txt}
```

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` form in the brief, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.{pdf,txt}`.

## What the overlay shows

Made on the earlier 6-page Liberation Serif render, before fb-595.68. Red is our render, blue is the filed exemplar, black is where they agree. The page map in `OVERLAY-cobb-motion-brief.txt` pairs our pages 1 to 6 one-to-one with filed pages 1 to 6. Word overlap is 62% to 95% per page. Pages 1 and 2 match most closely (95% and 87%). Pages 4 to 6 match least (67%, 62% and 64%): the filed memorandum runs to 7 pages and our render runs to 6, so the page breaks do not line up after page 3. The filed exemplar is set in Times New Roman (`pdffonts`), the face Liberation Serif substitutes for. The overlay is a diagnostic for layout and structure, not a score.

## Visual review (Gate 2)

Pages 1 through 6 of the earlier render (EB Garamond, then Liberation Serif; before fb-595.68) were rendered at 60 dpi and viewed. Findings during review, all fixed unless noted:

| Page | Finding | Fix |
|---|---|---|
| 1 to 6 | Paragraphs after the caption, after headings and after the block quotation lost their first-line indent. | `first-line-indent: (amount: para-indent, all: true)` |
| 1 to 6 | Section headings rendered left-aligned in a larger size. | Full-width heading blocks, heading text at the body size. |
| 1 to 6 | Line pitch was about 19 pt, which is not double spacing. | `double-leading` raised to 1.6em (about 27 pt). |
| 2 and others | Subsection headings (I., II.) sat tight against the preceding paragraph. | Level-3 space above raised to 1em. |
| 6 | Signature block: the firm name, the attorney list and the place and date are all on the last page. | none needed; the firm and "ATTORNEYS FOR DEFENDANT" line set in the same column as the signers |

Font change (EB Garamond to Liberation Serif, 2026-10-14): all 6 pages re-rendered and viewed at 60 dpi; page count unchanged; no new layout findings.

Open findings: none for layout. The exemplar's own typographical quirks are reproduced as filed, not corrected: the Introduction reads `False Claims Act “FCA”)` with no opening parenthesis, and the *Ahumada* citation has no closing parenthesis. Both are transcribed as written.

## Known gaps

1. **Font (L.R. 1.05(B)): resolved.** The rule names Times New Roman, Arial or Courier New. This template sets Times New Roman itself (the pinned files of `docs/FONTS.md` rule 1), with `Liberation Serif` (SIL OFL 1.1, vendored in `fonts/liberation-serif/`) only as fallback; it used Liberation Serif as the substitute before. Arial and Courier New were not chosen. The page count was unchanged by the EB Garamond to Liberation Serif switch (6 pages); the render is 7 pages since fb-595.68.19 (27.6 pt double pitch). The render uses `--ignore-system-fonts`, so no system font can stand in for it.
2. **One exemplar, one filer.** Tier 2 is judged against one filed memorandum (defendant's counsel, Saxton & Stump, Charleston Division), not the 2 or 3 the eval loop asks for.
3. **Page limit.** L.R. 7.05(B)(1) caps an initial brief at 35 double-spaced pages: `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine). The sample is far under the cap.
4. **Checked by the court tools.** `tools/check.sh` gates typst, latex and docx on `eval.yaml` (see Engines). The render has no typst warnings (`tools/render.sh` fails on warnings).
5. **Exemplar motion not transcribed.** The filing is the memorandum (ECF 24-1); the motion (ECF 24) is a separate document and is not in this folder.

## Exemplar search (for the record)

CourtListener search API, `court=scd`, `type=rd`, query `"MOTION to Dismiss" "12(b)(6)"`, then `"Memorandum in Support" "Motion to Dismiss"`, filed after 2024-06-01, `is_available=true`. Candidates downloaded: Cobb v. Charleston County School District, memorandum (ECF 24-1, 7 pp., selected: standalone Rule 12(b)(6) memorandum, text-based PDF); Williams/Freedom Mortgage and Musgrave v. Mace turned up only as orders and were not used; SLWP, LLC v. MGoBlue (ECF 11-1, 37 pp., not used: longer than the 8 to 14 page target).

## Gate 2 review on the FRCP base (2026-10-29, typst, latex and docx)

Every page of the three renders was reviewed as text layout (`pdftotext -layout`, page by page) with the checks' geometry (DEF-COVER-002 against the exemplar's page 1, XENG-001..003: 166 of 166 lines identical in latex and docx); the pod that did the move could not open images, so a visual look at the pages is left to the PM.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court and division, caption (the relator half an inch in, designations an inch in), the case number and the title at the right, the rule under the parties, the opening, INTRODUCTION (footnote 1, 12 pt) | OK; DEF-COVER-002 passes |
| 2-3 | LEGAL STANDARD, I. and II. (the block quotation single-spaced and indented) | OK |
| 4-6 | ARGUMENT, I. and its discussion | OK |
| 7 | CONCLUSION, place and date at the left, the signers and the firm at the right | OK |

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.9): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays what D.S.C. sets itself, each with its rule: the 27.6 pt double pitch and the single-spaced indented quotations and footnotes (L.R. 1.05(E)), 12 pt footnotes (1.05(C)), the court's name with the division, the caption and the signature block. `typst/scd-motion-brief.typ` names the face (L.R. 1.05(B)) and asserts the required fields. `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them); the per-folder typst code and the docx filter are removed. The page limit is `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine).

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |
