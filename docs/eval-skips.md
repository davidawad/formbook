# Folders that still fail the default eval (fb-xye0)

Each row: folder, failing check, root cause, what a fix needs. Checks and the checker are untouched.

## TNR-EMBEDDED vs the font audit (8 folders)

The exemplar audit (`data/exemplar-fonts.json`) classes each of these exemplars as body face `times` (Adobe Times, 57-97% of the text) and maps it to `TeX Gyre Termes`. `fb lint fonts` (run by every `fb check`) therefore requires the template to declare Termes. But `has_times_exemplar` (`tools/fb/src/fonts.rs`) treats `body == "times"` like `timesnewroman` and the checker then demands an embedded `TimesNewRomanPSMT`. The two cannot both pass: switching the template to Times New Roman makes `fb check` abort with "font audit mismatch", keeping Termes fails TNR-EMBEDDED. The filed examples themselves are Adobe Times (Type 1 `Times-Roman`), not TNR, so the court does not require TNR.

Fix needs: `has_times_exemplar` (and `times_doc_dirs`) should match only `timesnewroman`, or the audit entries should be reclassified. Not changed here (tool code).

| Folder | Failing check |
|---|---|
| courts/second-circuit/new-york/state/supreme-court/motion-brief | TNR-EMBEDDED |
| courts/federal-circuit/trademark-trial-and-appeal-board/notice-of-opposition | TNR-EMBEDDED |
| courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/adversary-complaint | TNR-EMBEDDED |
| courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/adversary-complaint | TNR-EMBEDDED |
| courts/eighth-circuit/iowa/federal/northern-district/complaint | TNR-EMBEDDED |
| courts/eighth-circuit/south-dakota/federal/bankruptcy-district/motion-brief | TNR-EMBEDDED |
| courts/ninth-circuit/guam/federal/bankruptcy-district/adversary-complaint | TNR-EMBEDDED (also DEF-CONT-001, DEF-FORM-002 before any font change) |
| courts/eleventh-circuit/georgia/federal/middle-district/motion-brief | TNR-EMBEDDED (also DEF-FORM-002) |

## INPUT template directives the content gate cannot read (4 folders)

`tools/check/md-blocks.awk` treats INPUT directives as literal paragraph text (`[unnumbered]`, `[signature]`, `[sig]`, `[[TOC]]`, `[[TOA]]`, `[[MEMO]]`), while the template consumes them and does not print them, so DEF-CONT-001 reports those blocks as missing. The INPUT must keep the directives. Fix needs: `md-blocks.awk` to strip or honour the directives before comparing. Every other block in these folders now matches (line-number and margin fixes are committed).

| Folder | Failing check | Directive blocks |
|---|---|---|
| courts/ninth-circuit/california/federal/eastern-district/complaint | DEF-CONT-001 | `[unnumbered]` x2 |
| courts/ninth-circuit/california/federal/eastern-district/motion-brief | DEF-CONT-001 | `[[TOC]]`, `[[TOA]]`, `[[MEMO]]` |
| courts/ninth-circuit/nevada/federal/bankruptcy-district/adversary-complaint | DEF-CONT-001 | `[unnumbered]` |
| courts/ninth-circuit/nevada/federal/bankruptcy-district/motion-brief | DEF-CONT-001 | `[signature]`, `[sig]` |

More caed/nvb directives: see the table above. Idaho and Missouri use the same class of marker.

## Other directive/marker folders (3)

| Folder | Failing check | Root cause | Fix needs |
|---|---|---|---|
| courts/ninth-circuit/idaho/federal/bankruptcy-district/motion-brief | DEF-CONT-001 | 12 INPUT paragraphs start with a literal `: ` marker the template consumes | `md-blocks.awk` strips the `: ` marker |
| courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/adversary-complaint | DEF-CONT-001 (WHEREFORE blocks) | leading `%` on paragraphs is a template directive, absent from the PDF | `md-blocks.awk` ignores the `%` directive |
| courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief | DEF-CONT-001 | same `%` directive | same |

## SCOTUS booklet pages (3)

courts/supreme-court-of-the-united-states/{amicus-brief,cert-petition,merits-brief}: DEF-CONT-001. `tools/check/pdf-runs.awk` computes `scale = pageWidth/612`, assuming letter pages, so on the 441 x 666 booklet every run's y is inflated about 1.27x and `footer_top` (666 - 54) drops the bottom third of each page, footnotes included. No template or eval.yaml change fixes it. Fix needs: `pdf-runs.awk` scales by the real page width (or `footer_top` is scaled).

## Footnote that splits across two pages (5)

DEF-CONT-001: a footnote begins at the foot of one page and continues on the next, so the checker cannot match its text (tried `show footnote.entry: set block(breakable: false)` and unbreakable paragraph wrappers; neither helped). Fix needs: a template layout that never splits a footnote entry, or checker support for split footnotes.

- courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/motion-brief
- courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief
- courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/motion-brief (INPUT-motion-brief-2.md, footnote 3)
- courts/eleventh-circuit/georgia/federal/northern-district/motion-brief
- courts/tenth-circuit/new-mexico/federal/bankruptcy-district/motion-brief (footnote defined in frontmatter, not as `[^n]`; checker does not know its text)

## Table read order (1)

courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief: DEF-CONT-001, block 6 (Material Terms table). PDF text is read in line order, so a short third-column cell ("¶ 7") precedes the wrapped lines of the second column; the INPUT order is cell by cell. Fix needs: checker reads table cells in order, or a table layout that does not interleave columns.
