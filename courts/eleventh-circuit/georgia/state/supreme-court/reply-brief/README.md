# Georgia Supreme Court: reply brief

Doc type: the appellant's reply brief (Ga. Sup. Ct. R. 19(3), 20(2)). Court `ga`, folder `courts/eleventh-circuit/georgia/state/supreme-court/reply-brief/`.

| Check | Result |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-reply-brief.pdf` (see `usage/SOURCE.md`) |
| render | ok: `tools/render.sh` (typst, `--ignore-system-fonts`, no warnings); 14 pages; only TeX Gyre Schola embedded (`pdffonts`) |
| overlay | ok: `usage/OVERLAY-clark.pdf` and `OVERLAY-clark.txt` (`tools/overlay.sh`) |
| pages reviewed | 14 of 14, each rendered to PNG at 60 dpi and looked at (certificate page re-checked after the Rule 14 fix) |

## Governing rules

Primary source: *Rules of the Supreme Court of Georgia (Effective July 2, 2026)*, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read by `pdftotext` on 2026-10-15.

The typography, filing, citation and service rules are the same as the opening brief's (Rules 14, 16, 17, 21, 22); see [opening-brief/README.md](../opening-brief/README.md) for the table with the template constants. Differences for this doc type:

| Requirement | Rule | Where the template applies it |
|---|---|---|
| Reply brief need only include item (g), the argument with standard of review; including items (a) and (b) is encouraged for briefs of significant length | 19(3) | headings are Argument-led; a TOC and TOA are generated because the reply is of significant length. Not enforced by the template |
| Reply brief may not expand the enumeration of errors | 19(3) | no enumeration section in the template |
| Reply brief limit: 7,000 words (20 pages if typed) | 20(2) | not counted; see gaps |
| "This submission does not exceed the word-count limit imposed by Rule 20." above the signature block | 20(7) | `closing-sentence` |

Not applicable here: Rule 10(2) timing (the reply is due 50 days after docketing or 10 days after the appellee's brief, whichever is later).

## Typeface, spacing, margins, page numbers

As the opening brief: TeX Gyre Schola as the substitute for the Century Schoolbook the rule names (Rule 16(2) size reference); double spacing at a 2.4 em pitch, matching the filed exemplar; the single-spacing assumption is in the opening-brief README; 1-inch margins; left-aligned; 11-pt footnotes; roman front matter; Arabic body pages.

## Files

- `typst/main.typ`: entry point. `typst/ga-reply-brief.typ`: template, `ga-brief(meta, body)` (same code as the opening-brief template).
- `usage/INPUT-reply-brief.md`: transcription of the reply. The opening paragraph and section I are transcribed in full; section II.A and II.B are transcribed; section II.C.3 starts. The rest is marked `[Omitted from this transcription: ...]`. The reply has no introduction in the exemplar, so the body starts with the opening paragraph and section I.
- `usage/OUTPUT-reply-brief.typst.pdf`, `usage/OVERLAY-clark.pdf`, `usage/OVERLAY-clark.txt`.

## What the overlay shows

Red is our render only, blue is the filed exemplar only, black is both. Pages are paired by text. The word-overlap figures are diagnostic only.

## Review findings and fixes

- Same font-fallback defect as the opening brief, fixed the same way.
- Same paragraph-overlap and run-in closing defects, fixed the same way.
- The *Turner* cite in the waiver section was not linked, so the TOA listed *Turner* with no pages. Linked; the TOA now shows page 5.
- The certificate of service showed an e-mail paragraph while the sample said `email: false`. The template tested for the key, not its value. Fixed in the template (it now reads the value). The sample is set to `email: true`, which assumes a prior e-mail service agreement with appellees' counsel: the reply exemplar's own certificate cites only e-filing, so confirm that agreement before relying on this certificate.
- The certificate lacked the Rule 14 prior-agreement certification. Fixed, as for the other two doc types.
- The exemplar's own word-count sentence reads "does not exceed the word count limitation set out in this Court's Rule 20(2)". The template prints the Rule 20(7) sentence instead. The rule governs; the exemplar's wording is not reproduced.

## Known gaps

- **Word count not checked.** The reply limit is 7,000 words (Rule 20(2)). The template does not count.
- **Sample is partial.** Transcribed: the opening paragraph, section I in full, section II.A and II.B, the start of II.C.3, and the conclusion. Not transcribed: II.C.1–2, II.C.3 after its first paragraph, sections III to V, and Exhibit A. The reply has no introduction in the exemplar, so the TOC begins at section I.
- **TOA depends on links.** Only `[text](toa:key)` links are recorded.
- **Exemplar's Exhibit A** (a Court order on the filing extension) is not transcribed.
- **No `tools/check.sh` gate run.** Same as the opening brief.
- **Exemplar filer.** The reply's filer is the appellants' counsel, the same as the opening-brief exemplar.

## Related

- [opening-brief](../opening-brief/README.md), [answering-brief](../answering-brief/README.md).

## Engines

Typst is the primary engine (above). The DOCX engine is `docx/`, the same design as `answering-brief/docx/`: `build-reference.sh` writes `reference.docx`; `ga-brief.lua` builds the cover, TOC, TOA, closing, certificate and the sections; `render.sh` makes two renders so the TOC and TOA numbers come from the docx's own layout. Render with `sh tools/render.sh --engine docx <this folder> usage/INPUT-reply-brief.md`: `usage/OUTPUT-reply-brief.docx` and `usage/OUTPUT-clark.docx.pdf` (LibreOffice 26.8.1).

| | docx | typst |
|---|---|---|
| Pages | 14 | 14 |
| Font | TeX Gyre Schola only | TeX Gyre Schola only |
| Line pitch, margins, paper | 31.2 pt double, 15.6 pt single, 1 in, letter | same |
| Cover, caption, counsel | same layout | same |
| TOC, TOA | numbers agree with the typst output on every entry | same |
| Closing, certificate | same | same |

Checked: every page of `OUTPUT-ga-reply-brief-clark.docx.pdf` was rendered (60 dpi) and set beside the typst page; the TOC and TOA numbers agree with the typst output.

What differs:

- The sample cites `toa:s51-13-1` in the body but has no `authorities:` entry for it. The docx warns on stderr for each such citation and leaves it out of the TOA; typst leaves it out silently. Add the authority to the sample (not done here: `usage/` is an input).
- Front-matter numbers and Word: see answering-brief.
- Run-in heading spacing: see answering-brief.

BLOCKED: none (see answering-brief; the TOA item above is a sample issue, not a block).
