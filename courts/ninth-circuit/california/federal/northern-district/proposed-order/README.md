# N.D. Cal. (cand): proposed order

Doc type: **proposed-order**. Court: United States District Court for the Northern District of California. Folder: `courts/ninth-circuit/california/federal/northern-district/proposed-order/`.

Status: filled 2026-10-26 by the template-gap procedure (`brief-build scaffold-template`, donor `../notice`, the docx filter from `../motion-brief/docx`). Exemplars: 3 filed N.D. Cal. proposed orders from different filers (`usage/SOURCE.md`). Engines: typst and docx (cross-engine gate on); no latex. Gates on macOS, 2026-10-26: typst `RESULT: 16 checks passed, 0 failed`, docx `RESULT: 22 checks passed, 0 failed`. Pages reviewed: all 3 of the transcribed sample against exemplar 1, and page 1 of the synthetic sample in both engines. Not a court-level `court.json` status.

## Governing rules

Same paper as the notice, the motion brief and the complaint (rule text in `../motion-brief/README.md`; IDs in `../rules.md`).

| Rule | Requirement | Where it lives |
|---|---|---|
| Civil L.R. 3-4(c)(1)-(3) | Letter, numbered lines, double spaced, at most 28 lines; 12 pt standard font; footer with the paper's title and case number. | `margins`, `line-numbers`, `pleading-rules`, `pitch-double`, `running-footer` |
| Civil L.R. 3-4(a) | Counsel block upper left on a paper presented for filing; court, caption, case number, title. | `counsel-block` (optional: 2 of 3 exemplars omit it), `cover` |
| Civil L.R. 5-1(f) | Proposed orders filed as PDF attached to the motion, and emailed in a word-processing format to the judge's proposed-order address. | the docx engine (`docx/cand.lua`) |
| Civil L.R. 7-2(c) | Each motion must be accompanied by a proposed order; 7-3(a): an opposition may include one. | n/a (when to file) |
| Judges' standing orders | Some judges set the email address and ask for no "extraneous analysis or commentary". | check the assigned judge's order |

No rule sets the judge's signature block; the convention (all 3 exemplars) is a rule at the right over the judge's name and title, with "Dated:" at the left or the date in the last sentence.

## Frontmatter

The notice's (`case_number`, `court`, `caption`, `brief_title`, `footer_title`; `counsel` and `counsel_role` optional), plus `judge: {name, title, dated}` (each optional; `dated: false` drops the "Dated:" line when the body dates the order). Without `judge`, a source that ends with a rule of underscores and `[Hon. Name, Title]` (optionally a `[DECISION: ...]` drafting marker) sets the same block. Numbered paragraphs (`1.`, `2.`) are set as body paragraphs that start with their number, as the filed orders do. A paragraph that starts with "(1)" must escape the parenthesis (`\(1)`): pandoc reads it as a list, cmarker does not.

## Known gaps

1. Exemplar 1 justifies its body text; ours is ragged right (the shared layout model). Tier 3.
2. Exemplar 2 sets a sealing table; tables are not supported in this filter (error, not silent).
3. docx stamps were written on macOS LibreOffice (system Times New Roman), not the pinned box fonts (docs/FONTS.md rule 1).
