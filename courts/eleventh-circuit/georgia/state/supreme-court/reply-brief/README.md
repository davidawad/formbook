# Georgia Supreme Court: reply brief

Doc type: the appellant's reply brief (Ga. Sup. Ct. R. 19(3), 20(2)). Court `ga`, folder `courts/eleventh-circuit/georgia/state/supreme-court/reply-brief/`.

| Check | Result |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-reply-brief.pdf` (see `usage/SOURCE.md`) |
| render | ok: `tools/render.sh` (typst, `--ignore-system-fonts`, no warnings); 14 pages; only TeX Gyre Schola embedded (`pdffonts`) |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-reply-brief.pdf` and `.txt` (gitignored; `tools/overlay.sh`) |
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
- `usage/OUTPUT-reply-brief.typst.pdf` (overlays: `just overlay`, into the gitignored `.overlay/`).

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
- **Gates.** `tools/check.sh` runs on the typst and docx engines (see Engines); `tools/check-selftest.sh` does not run here (the court has no `checks.yaml`).
- **Exemplar filer.** The reply's filer is the appellants' counsel, the same as the opening-brief exemplar.

## Related

- [opening-brief](../opening-brief/README.md), [answering-brief](../answering-brief/README.md).

## Engines

Typst is the reference engine; the docx engine sets the same layout, line for line (docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.36). The answering, opening and reply briefs share the code: `typst/ga-<doc type>.typ` (one copy per folder, the same but for its first line) and `docx/ga-brief.lua` and `docx/reference.xml` (identical copies). Render with `sh tools/render.sh [--engine docx] <this folder> usage/INPUT-reply-brief.md`: `usage/OUTPUT-reply-brief.typst.pdf`, `.docx` and `.docx.pdf` (LibreOffice).

- **Layout model.** Both engines are on the shared cross-engine model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): first-fit line breaking, ragged right (Rule 16(3): left-aligned), no kerning, ligatures or hyphenation, and every line a box of its pitch with the baseline at 0.8 of it: 31.2 pt (double, Rule 16(4)) for the text, the closing and the certificate's statements; 15.6 pt (1.2 x 13 pt, the rule's floor) for the cover, headings, quotations, the tables' rows and the signature and service columns; 13.2 pt for the 11 pt footnotes. The spaces between blocks are explicit, the larger of two adjacent ones applying, as in Word: half a single line (7.8 pt) around headings and quotations and between authorities, a single line between contents rows and around the signature and service columns.
- **Headings** are 13 pt bold (level 3 bold italic, a case name in it upright), single-spaced, kept with the next paragraph: the body size, as both exemplars set them (were typst's default 18.2 and 15.6 pt, which Word cannot set in half points).
- **Tables.** Contents (levels 1 and 2; level 2 half an inch in) and authorities (by kind, sorted, wrapped lines hanging 0.4 in, "passim" from seven pages): the text wraps before a page column (36 pt; 72 pt or the page list's own width), and a dot leader runs from three spaces after the text to the page number. A citation's page is the page on which it starts. The cover counts as page i, so the contents start at ii (as the opening-brief exemplar).
- **docx.** `docx/reference.xml` holds the styles (base="xengine", the face as `{font}`, which is the typst face TeX Gyre Schola; `w14:ligatures none`, so LibreOffice sets no fi or fl ligatures); `docx/ga-brief.lua` writes the cover, the tables, the closing and the certificate from the frontmatter as written (`$FORMBOOK_META`, the strings typst sets) and leaves headings, paragraphs, lists, quotations and footnotes to pandoc in those styles. The table pages come from fb render's needles (the page of every heading and citation in the LibreOffice PDF, rendered again until they settle); the sections and the page-number footer from `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL` (cover unnumbered, front matter ii, iii, ..., body from 1, the number in a 15.6 pt line 27.6 pt above the page edge, where typst sets it). This replaced `build-reference.sh`, `reference.docx` and a two-pass `render.sh`.
- **LibreOffice measures** (docs/EVAL-LOOP.md, "What the federal-appellate adoption found"): the right margin is 1441 twips (1440 to 1442 break every line of the three samples as typst does, 1443 moves one); the three no-break spaces before a leader are two at 13 pt and one at 9 pt, 9.73 pt for typst's 0.75 em (Schola's space is 0.278 em); LibreOffice reserves the face's line height, 15.13 pt, for the footnote separator (measured: a one-line note under a one-line anchor fits with 303 twips to spare, not 302), which typst reserves as an 8.53 pt clearance plus the 6.6 pt gap before the note.
- **DEF-FORM-002.** LibreOffice embeds Schola with word boxes reaching 15.8 pt above the baseline (typst 9.6 pt), so a single line opening a page measures 3.31 pt into the top margin on docx while its glyphs are inside; `eval.yaml` sets the vertical tolerance to 3.5 pt.

Checks (`sh tools/check.sh <this folder> --engine typst|docx`): typst 8 passed, 0 failed; docx 12 passed, 0 failed, XENG-001..003 PASS (293 of 293 typst lines alike, every page start and end, 14 pages), so `eval.yaml` gates it (`params.cross_engine: gate`). The sample cited `toa:s51-13-1` without an `authorities:` entry (the exemplar's table lists O.C.G.A. § 51-13-1); the entry is added, so the statute is in the table of authorities. `tools/check-selftest.sh` does not run here: the court has no `checks.yaml` (fb selftest reads its sample list from it).

Reviewed: every page of both renders as page images at 40 dpi, typst and docx side by side, and the opening brief's cover, contents and authorities and the reply brief's body page 9 again at 70 to 80 dpi. Word itself was not run: the contents and authorities numbers are those of the LibreOffice PDF, and Word may paginate differently (docs/DOCX.md).

BLOCKED: none.
