# District Court, D. South Carolina (`scd`): motion-brief

Doc type **motion-brief**: the memorandum in support of a Rule 12(b) motion to dismiss, folder `courts/fourth-circuit/south-carolina/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-cobb-v-charleston-county-school-district-2-25-cv-08752-motion-brief.pdf` (1 filer: defendant's counsel; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-cobb-motion-brief.md` (the full 7-page memorandum transcribed: caption, cover title, Introduction, Legal Standard, Argument with block quotation, Conclusion, footnote 1, signature block) |
| render | ok: `samples/OUTPUT-cobb-motion-brief.pdf`, 6 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-cobb-motion-brief.pdf` and `samples/OVERLAY-cobb-motion-brief.txt` |
| pages reviewed | 6 of 6 (every page rendered at 60 dpi and viewed after the last template change) |
| tier-1 font (L.R. 1.05(B)) | **BLOCKED**: Times New Roman, Arial or Courier New is required; only EB Garamond is vendored (see Known gaps) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.S.C. Local Civ. Rule 1.05(A) | Minimum one-inch margins on all sides. | `margin` in `typst/scd-motion-brief.typ` |
| D.S.C. Local Civ. Rule 1.05(B) | Times New Roman, Arial or Courier New. | `font-family` (currently EB Garamond; BLOCKED) |
| D.S.C. Local Civ. Rule 1.05(C) | Minimum 12-point type for caption, text and footnotes. | `type-size` (footnote is set in the same size) |
| D.S.C. Local Civ. Rule 1.05(D) | Only page numbers and document identification may be in margins or smaller than 12 pt. | page number only, centered at the foot |
| D.S.C. Local Civ. Rule 1.05(E) | Double space text, except indented quotations and footnotes. | `double-leading` (about 27 pt pitch at 12 pt); block quotation single-spaced and indented |
| D.S.C. Local Civ. Rule 7.05(A) | A memorandum contains a concise summary of the case, a statement of facts with record references, the argument with citations, and any special content the rule for the motion requires. | Sample content (the exemplar's order: Introduction, Legal Standard, Argument, Conclusion); the template does not enforce it |
| D.S.C. Local Civ. Rule 7.05(B)(1) | An initial brief may not exceed 35 double-spaced pages, unless the court grants an exception. | Not enforced by the template. This sample is 6 pages. |
| FRCP 7(b), 10(a), 11(a) | A motion and its grounds are stated in writing; caption; attorney signature. | `caption`, `signature` (signers and firm lines from frontmatter) |
| FRCP 12(b)(6) | The motion (and so the memorandum) asserts failure to state a claim. | Sample content only |

Sources: D.S.C. Local Civil Rules (February 22, 2023), https://www.scd.uscourts.gov/Rules/Civil%20Rules%20-%20Current.pdf, fetched 2026-10-14; Local Civ. Rules 1.05, 7.05 read from that PDF with pdftotext. The same text appears in the May 15, 2017 edition at https://www.scd.uscourts.gov/Rules/2017/Civil%20Rules%20-%20May%2015,%202017.pdf. The FRCP text is cited from the rule as known and was not re-fetched in this session; verify the pin cites before relying on them.

## Template and sample contract

- `typst/main.typ` reads the sample named by `--input sample=` and calls `scd-motion-brief(meta, body)`.
- `typst/scd-motion-brief.typ` holds all rule parameters at the top, the caption, the signature block and the heading styles. Nothing case-specific and no coordinates measured off the exemplar.
- Frontmatter: `court`, `case_number`, `parties` (each `{text, indent}`), `doc_title`, `signature` (`location`, `dated`, `signers`, `firm`). Body: markdown. `##` is a section heading (centered, bold capitals: INTRODUCTION, LEGAL STANDARD, ARGUMENT, CONCLUSION); `###` is a subsection (left, bold, as in the exemplar); footnotes use `[^1]` with the definition at the end of the sample.

Render and overlay (from the repo root; the doc-type folder is the court dir):

```sh
export PATH="$HOME/tb/bin:$PATH"
D=courts/fourth-circuit/south-carolina/federal/district/motion-brief
sh tools/render.sh $D samples/INPUT-cobb-motion-brief.md     # -> samples/OUTPUT-cobb-motion-brief.pdf
sh tools/overlay.sh $D cobb-motion-brief                      # -> samples/OVERLAY-cobb-motion-brief.{pdf,txt}
```

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` form in the brief, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.{pdf,txt}`.

## What the overlay shows

Red is our render, blue is the filed exemplar, black is where they agree. The page map in `OVERLAY-cobb-motion-brief.txt` pairs our pages 1 to 6 with filed pages 1, 2, 3, 4, 6, 6. Word overlap is 43% to 95% per page. Pages 1 and 2 match most closely (95% and 83%). Pages 5 and 6 match least (49% and 43%): the filed page 5 is not one-to-one with our page 5, and our page 6 pairs with the filed page 6 only in part, because the filed memorandum runs to 7 pages and our render runs to 6. The overlay is a diagnostic for layout and structure, not a score.

## Visual review (Gate 2)

Pages 1 through 6 were rendered at 60 dpi and viewed. Findings during review, all fixed unless noted:

| Page | Finding | Fix |
|---|---|---|
| 1 to 6 | Paragraphs after the caption, after headings and after the block quotation lost their first-line indent. | `first-line-indent: (amount: para-indent, all: true)` |
| 1 to 6 | Section headings rendered left-aligned in a larger size. | Full-width heading blocks, heading text at the body size. |
| 1 to 6 | Line pitch was about 19 pt, which is not double spacing. | `double-leading` raised to 1.6em (about 27 pt). |
| 2 and others | Subsection headings (I., II.) sat tight against the preceding paragraph. | Level-3 space above raised to 1em. |
| 6 | Signature block: the firm name, the attorney list and the place and date are all on the last page. | none needed; the firm and "ATTORNEYS FOR DEFENDANT" line set in the same column as the signers |

Open findings: none for layout. The exemplar's own typographical quirks are reproduced as filed, not corrected: the Introduction reads `False Claims Act “FCA”)` with no opening parenthesis, and the *Ahumada* citation has no closing parenthesis. Both are transcribed as written.

## Known gaps

1. **BLOCKED: font (L.R. 1.05(B)).** The rule requires Times New Roman, Arial or Courier New. `fonts/` vendors only EB Garamond, the render uses `--ignore-system-fonts` (so a system Times New Roman would fail to compile, not silently substitute), and `fonts/` is a shared path this box must not edit. The template therefore renders in EB Garamond and tier-1 font compliance is **not met**. A decision for David: vendor a metric-compatible Times New Roman substitute (for example Liberation Serif) into `fonts/`, then change `font-family` in `typst/scd-motion-brief.typ`. This is the only blocker on this doc type, and the same blocker as `complaint`.
2. **One exemplar, one filer.** Tier 2 is judged against one filed memorandum (defendant's counsel, Saxton & Stump, Charleston Division), not the 2 or 3 the eval loop asks for.
3. **Page limit not enforced.** L.R. 7.05(B)(1) caps an initial brief at 35 double-spaced pages; the template does not count pages. The sample is far under the cap.
4. **Not checked by the court tools.** This folder has no `checks.yaml`, so `tools/check.sh` has not been run here. The render has no typst warnings (`tools/render.sh` fails on warnings).
5. **Exemplar motion not transcribed.** The filing is the memorandum (ECF 24-1); the motion (ECF 24) is a separate document and is not in this folder.

## Exemplar search (for the record)

CourtListener search API, `court=scd`, `type=rd`, query `"MOTION to Dismiss" "12(b)(6)"`, then `"Memorandum in Support" "Motion to Dismiss"`, filed after 2024-06-01, `is_available=true`. Candidates downloaded: Cobb v. Charleston County School District, memorandum (ECF 24-1, 7 pp., selected: standalone Rule 12(b)(6) memorandum, text-based PDF); Williams/Freedom Mortgage and Musgrave v. Mace turned up only as orders and were not used; SLWP, LLC v. MGoBlue (ECF 11-1, 37 pp., not used: longer than the 8 to 14 page target).
