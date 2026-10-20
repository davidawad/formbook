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
