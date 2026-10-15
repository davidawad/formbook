# Georgia Supreme Court: answering brief

Doc type: the appellee's brief in a direct appeal (Ga. Sup. Ct. R. 19(2), 20(1)). Court `ga`, folder `courts/eleventh-circuit/georgia/state/supreme-court/answering-brief/`.

| Check | Result |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-clark-v-leigh-S26A0349-answering-brief.pdf` (see `exemplars/SOURCE.md`) |
| render | ok: `tools/render.sh` (typst, `--ignore-system-fonts`, no warnings); 12 pages; only TeX Gyre Schola embedded (`pdffonts`) |
| overlay | ok: `samples/OVERLAY-clark.pdf` and `OVERLAY-clark.txt` (`tools/overlay.sh`) |
| pages reviewed | 12 of 12, each rendered to PNG at 60 dpi and looked at |

## Governing rules

Primary source: *Rules of the Supreme Court of Georgia (Effective July 2, 2026)*, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read by `pdftotext` on 2026-10-15.

The typography, word-limit, citation and service rules are the same as the opening brief's (Rules 14, 16, 17, 20, 21, 22); see [opening-brief/README.md](../opening-brief/README.md) for the table with the template constants. Differences for this doc type:

| Requirement | Rule | Where the template applies it |
|---|---|---|
| Appellee's brief follows Rule 19(1) except item (d); items (c) and (e) may be omitted if the appellee is satisfied with the appellant's presentation; a disagreement with the statement of the case must be identified with record cites | 19(2) | the sample's headings are Introduction, Statement of the Case, Argument, Conclusion (no enumeration of errors). Not enforced by the template |
| Principal brief (appellee's initial brief) limit: 10,000 words (30 pages if typed) | 20(1) | not counted; see gaps |
| "This submission does not exceed the word-count limit imposed by Rule 20." above the signature block | 20(7) | `closing-sentence` |

Not applicable here: Rule 10 timing (response due 40 days after docketing or 20 days after the appellant's brief, whichever is later), Rule 23 (amicus).

## Typeface, spacing, margins, page numbers

As the opening brief: Century Schoolbook is the rule-named face (Rule 16(2) size reference); the substitute is TeX Gyre Schola (`docs/FONTS.md`). Double-spaced text at a 2.4 em pitch (31.2 pt at 13 pt), matching the filed exemplar's measured line pitch; the single-spacing assumption is the same as in the opening-brief README. 1-inch margins, left-aligned, 11-pt footnotes, roman front matter, Arabic body pages.

## Files

- `typst/main.typ`: entry point. `typst/ga-answering-brief.typ`: template, `ga-brief(meta, body)` (same code as the opening-brief template).
- `samples/INPUT-clark.md`: transcription of the appellee's brief. The statement of the case (to the amended judgment) and the opening of argument I are transcribed; the rest is marked `[Omitted from this transcription: ...]`. The block quotation of O.C.G.A. § 51-13-1 is omitted.
- `samples/OUTPUT-clark.pdf`, `samples/OVERLAY-clark.pdf`, `samples/OVERLAY-clark.txt`.

## What the overlay shows

Red is our render only, blue is the filed exemplar only, black is both. Pages are paired by text. The sample has a shorter body than the exemplar's 57 pages, so the pairing is partial by design. The word-overlap figures are diagnostic only.

## Review findings and fixes

- Same font-fallback defect as the opening brief (footnote text and numbers in Libertinus), fixed the same way.
- Same paragraph-overlap and run-in closing defects, fixed the same way.
- The certificate of service lacked the Rule 14 prior-agreement certification. Fixed; the sample's counsel are served by e-mail under the agreement in the exemplar's own certificate.
- Level-3 run-in headings ("The verdict.", "Defendants' motion to remit.") gave more space above.

## Known gaps

- **Word count not checked.** See the opening-brief README.
- **Sample is partial.** The statement of the case is transcribed to the amended judgment, the opening of argument I is transcribed, and the rest of the body is omitted. The sample is 12 pages in total.
- **TOA depends on links.** Only `[text](toa:key)` links are recorded. The TOA lists the authorities the sample cites through links.
- **Record cites in the exemplar** (`V26 – 148-49`) are transcribed as given; the Rule 22 format is a Vol.-Page form, and the template does not check it.
- **No `tools/check.sh` gate run.** Same as the opening brief.
- **Exemplar** is the appellee's counsel's response brief in the same appeal (S26A0349). Different filer from the opening-brief exemplar.

## Related

- [opening-brief](../opening-brief/README.md), [reply-brief](../reply-brief/README.md).
