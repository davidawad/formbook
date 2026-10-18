# Georgia Supreme Court: answering brief

Doc type: the appellee's brief in a direct appeal (Ga. Sup. Ct. R. 19(2), 20(1)). Court `ga`, folder `courts/eleventh-circuit/georgia/state/supreme-court/answering-brief/`.

| Check | Result |
|---|---|
| exemplar | yes: `usage/SAMPLE-ga-answering-brief-clarkvleighs26a0349.pdf` (see `usage/SOURCE.md`) |
| render | ok: `tools/render.sh` (typst, `--ignore-system-fonts`, no warnings); 12 pages; only TeX Gyre Schola embedded (`pdffonts`) |
| overlay | ok: `usage/OVERLAY-clark.pdf` and `OVERLAY-clark.txt` (`tools/overlay.sh`) |
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
- `usage/INPUT-ga-answering-brief-clark.md`: transcription of the appellee's brief. The statement of the case (to the amended judgment) and the opening of argument I are transcribed; the rest is marked `[Omitted from this transcription: ...]`. The block quotation of O.C.G.A. § 51-13-1 is omitted.
- `usage/OUTPUT-ga-answering-brief-clark.typst.pdf`, `usage/OVERLAY-clark.pdf`, `usage/OVERLAY-clark.txt`.

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

## Engines

Typst is the primary engine (above). The DOCX engine is `docx/`: `build-reference.sh` writes `reference.docx` (TeX Gyre Schola 13 pt, exact line pitches that match the typst render, 1-in margins, letter paper, 11-pt footnotes, the page number in the footer); `ga-brief.lua` builds the cover, table of contents, table of authorities, closing and certificate, and the three sections (cover without folio, roman front matter, arabic body); `render.sh` makes two renders, so the TOC and TOA page numbers come from the docx's own layout. Render with `sh tools/render.sh --engine docx <this folder> usage/INPUT-ga-answering-brief-clark.md`: `usage/OUTPUT-ga-answering-brief-clark.docx` and `usage/OUTPUT-clark.docx.pdf` (LibreOffice 26.8.1, `soffice --headless --convert-to pdf`). It needs pandoc (3.12.1), LibreOffice (`soffice`), poppler (`pdfinfo`, `pdftotext`), perl, zip, unzip and xmllint; the other doc types use the same folder layout.

| | docx | typst |
|---|---|---|
| Pages | 12 | 12 |
| Font | TeX Gyre Schola only (`pdffonts`) | TeX Gyre Schola only |
| Line pitch | double 31.2 pt, single 15.6 pt, footnotes 13.2 pt | same |
| Margins, paper | 1 in, letter | same |
| Cover, caption, counsel | same layout | same |
| Heading sizes | 18 pt (level 1), 15.5 pt (level 2), 13 pt (level 3) | same |
| TOC, TOA | dot leaders; every number equals the typst output | same |
| Closing, certificate | same; the closing is kept on one page | same |

Checked: every page of `OUTPUT-ga-answering-brief-clark.docx.pdf` was rendered (60 dpi) and set beside the typst page; the first body line, the heading spacing and the TOC and TOA numbers were measured with `pdftotext -bbox` and `pdftotext -layout`.

What differs:

- **Run-in headings.** A level-3 heading after body text sits about 7 pt lower in the docx (LibreOffice adds the paragraph gap and the heading's space above; typst takes the larger). Through the middle of the brief the docx sets one or two lines fewer per page than typst, so its page breaks fall a line or two apart.
- **Front-matter numbers.** Typst counts the cover as page 1, so its TOC is page `ii`; the docx starts the roman numbers at `i` on the TOC. The court's rule decides which is right; the docx follows the usual convention.
- **Word.** Not run here. The docx opens in LibreOffice without a repair prompt (it was converted). The TOC and TOA numbers are plain text, not fields: Word may paginate differently, and the numbers would then be off by a page. Check them in Word before filing.
- Fonts: the `.docx` names TeX Gyre Schola, so the court face must be installed where the file is opened (`docs/DOCX.md`).

BLOCKED: none. No check IDs apply to this folder's docx (the gates here are typst's); the differences above are not blocks.
