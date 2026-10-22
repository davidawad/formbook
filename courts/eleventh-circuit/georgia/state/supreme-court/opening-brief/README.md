# Georgia Supreme Court: opening brief

Doc type: the appellant's principal brief in a direct appeal (Ga. Sup. Ct. R. 19(1), 20(1)). Court `ga`, folder `courts/eleventh-circuit/georgia/state/supreme-court/opening-brief/`.

| Check | Result |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-opening-brief.pdf` (see `usage/SOURCE.md`) |
| render | ok: `tools/render.sh` (typst, `--ignore-system-fonts`, no warnings); 15 pages; only TeX Gyre Schola embedded (`pdffonts`) |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-opening-brief.pdf` and `.txt` (gitignored; `tools/overlay.sh`) |
| pages reviewed | 15 of 15, each rendered to PNG at 60 dpi and looked at |

## Governing rules

Primary source: *Rules of the Supreme Court of Georgia (Effective July 2, 2026)*, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read by `pdftotext` on 2026-10-15; the rule text below is from that PDF.

| Requirement | Rule | Where the template applies it |
|---|---|---|
| Proportionally spaced serif body face; no monospace | 16(1) | `face` = TeX Gyre Schola |
| Body text and headings no smaller than 13-pt Century Schoolbook; footnotes no smaller than 11-pt | 16(2) | `body-size` 13pt, `note-size` 11pt |
| Left-aligned, or justified with hyphenation | 16(3) | left-aligned (`justify: false`) |
| Line spacing from 1.2x to double; quotations, headings, captions, footnotes may be single | 16(4) | line pitches, not leadings (see Engines): double for text (`pitch-body` 31.2 pt); 1.2x, the floor, for the cover, headings, quotations and the TOC and TOA rows (`pitch-single` 15.6 pt); footnotes 1.2 x 11 pt (`pitch-note` 13.2 pt) |
| Margins no smaller than one inch | 16(5), 17(2) | `margin` = 1in |
| Letter size, searchable PDF | 17(1) | `paper: "us-letter"`; typst PDF has a text layer |
| No hyperlinks to other documents or websites | 17(3) | every link except `toa:` keys prints its text only |
| Pages counted toward the limit numbered with Arabic numerals | 21 | body restarts at 1; front matter is roman (exemplar practice; the rule only requires Arabic for counted pages) |
| Principal brief: 10,000 words (30 pages if typed) | 20(1) | not computed in the template; see gaps |
| Cover, TOC, TOA, certificate of service, signature block and word-count statement excluded from the limit | 20(6) | not counted |
| "This submission does not exceed the word-count limit imposed by Rule 20." immediately above the signature block | 20(7) | `closing-sentence`, printed directly above "Respectfully submitted" |
| Contents: TOC and TOA for significant length; introduction; jurisdictional statement (basis, and why this Court); enumeration of errors; statement of the case; summary of argument; argument with standard of review; conclusion | 19(1) | headings in the sample follow this order; TOC from headings; TOA from `toa:` links |
| Citations: Georgia cases with official reporter cite; record cites as Vol.-Page | 22(2) | sample citations follow the exemplar |
| Certificate of service: manner of service identified; names and addresses; for e-mail service, the prior-agreement certification in substance | 14 | `certificate-of-service`: "I certify that there is a prior agreement with counsel to allow documents in a PDF format sent via e-mail to suffice for service under Supreme Court Rule 14." followed by the recipients |

Not applicable here: 16(6) (documents not filed electronically), Rule 10 (filing deadlines). Rule 17(4)–(6) (sealing, redaction of personal identifying information) is not applied by the template: the sample has no sealed or redacted material, but a real filing must comply.

## Typeface

Rule 16(1) names the Century family as examples; Rule 16(2) sizes body text by 13-pt Century Schoolbook. The rule-named face is therefore Century Schoolbook. Substitute: **TeX Gyre Schola**, the vendored Century Schoolbook substitute, per `docs/FONTS.md` (Century family row). Nothing is set in system fonts; the render uses `--ignore-system-fonts`.

## Line spacing (measured, not assumed)

- The template sets line pitches (every line a box of its pitch; lib/typst/xengine.typ), not leadings.
- The template takes single spacing as a 1.2 em pitch, and double as 2.4 em (31.2 pt at 13 pt).
- The filed exemplar's body lines measure 31.2 pt apart (`pdftotext -bbox`, exemplar page 8), so double spacing here matches the filing.
- Assumption to check: that "single" in Rule 16(4) is the 1.2 em pitch. If the Clerk reads single as the face's own line box, double would exceed the rule; check against a Clerk-accepted filing before relying on it.

## Cover, counsel and caption

The rules do not prescribe cover contents for briefs. The layout follows the exemplar: court name, caption with case number and lower-court number, title, and counsel blocks. The cover is exemplar practice, not rule text.

## Files

- `typst/main.typ`: entry point. `typst/ga-opening-brief.typ`: template, `ga-brief(meta, body)`.
- `usage/INPUT-opening-brief.md`: markdown transcription of the exemplar (frontmatter for cover, counsel, signature, service and authorities; body from the exemplar's text). Parts not transcribed are marked `[Omitted from this transcription: ...]`.
- `usage/OUTPUT-opening-brief.typst.pdf`, `.docx`, `.docx.pdf`: renders. `just overlay` writes the red (ours), blue (filed), black (both) comparison and the page map into the gitignored `.overlay/`.
- File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.md` / `<id>-overlay.pdf` names in the bead. The tools hardcode the names.

## What the overlay shows

Red is our render only, blue is the filed exemplar only, black is both. Pages are paired by text, so a page's pairing can be off when the sample omits text. The word-overlap percentages in `OVERLAY-clark.txt` are diagnostic only, not a score.

## Review findings and fixes

Each rendered page was checked. Defects found and fixed during the review:

- Footnote numbers and footnote text fell back to typst's default serif (Libertinus), so a second font was embedded. Fixed by setting the font once at document level, in `ga-brief`. `pdffonts` now lists only TeX Gyre Schola.
- Cover lines and paragraphs overlapped, because paragraph spacing was 0 and the line box is 0.72 em. Fixed by setting `spacing` to match each leading.
- The word-count sentence and "Respectfully submitted" ran together. Code-block content does not create paragraph breaks; the closing is now a markup block.
- The certificate of service did not carry the Rule 14 prior-agreement certification. Fixed to the rule's wording.
- Level-3 headings sat tight against the paragraph below. Given more space above.

## Known gaps

- **Word count not checked.** The template prints the Rule 20(7) sentence but does not count words. The sample is not a 10,000-word brief.
- **Sample is partial.** Transcribed: the introduction, jurisdiction, enumeration of errors, statement of the case, summary of argument, the opening of argument II.A, and the conclusion. Not transcribed: the rest of the argument (the exemplar's body runs to page 41). The TOA lists only the authorities cited in the transcribed text.
- **TOA depends on links.** An authority is recorded only if its body cite is a `[text](toa:key)` link. An unlinked cite will not appear in the TOA.
- **Gates.** `tools/check.sh` runs on the typst and docx engines (see Engines); `tools/check-selftest.sh` does not run here (the court has no `checks.yaml`).
- **Certificate wording.** Rule 14 is quoted from the PDF text; the certificate's wording follows the rule's own sentence, which differs from the exemplar's wording.
- **Single-spacing reading** (see above).
- **Exemplar** is one filing in one case (S26A0349) by the appellants' counsel. It is the only Supreme Court opening brief found in the search; see `usage/SOURCE.md`.

## Related

- Sister doc types: [answering-brief](../answering-brief/README.md), [reply-brief](../reply-brief/README.md).
- Fonts: `docs/FONTS.md`.

## Engines

Typst is the reference engine; the docx engine sets the same layout, line for line (docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.36). The answering, opening and reply briefs share the code: `typst/ga-<doc type>.typ` (one copy per folder, the same but for its first line) and `docx/ga-brief.lua` and `docx/reference.xml` (identical copies). Render with `sh tools/render.sh [--engine docx] <this folder> usage/INPUT-opening-brief.md`: `usage/OUTPUT-opening-brief.typst.pdf`, `.docx` and `.docx.pdf` (LibreOffice).

- **Layout model.** Both engines are on the shared cross-engine model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): first-fit line breaking, ragged right (Rule 16(3): left-aligned), no kerning, ligatures or hyphenation, and every line a box of its pitch with the baseline at 0.8 of it: 31.2 pt (double, Rule 16(4)) for the text, the closing and the certificate's statements; 15.6 pt (1.2 x 13 pt, the rule's floor) for the cover, headings, quotations, the tables' rows and the signature and service columns; 13.2 pt for the 11 pt footnotes. The spaces between blocks are explicit, the larger of two adjacent ones applying, as in Word: half a single line (7.8 pt) around headings and quotations and between authorities, a single line between contents rows and around the signature and service columns.
- **Headings** are 13 pt bold (level 3 bold italic, a case name in it upright), single-spaced, kept with the next paragraph: the body size, as both exemplars set them (were typst's default 18.2 and 15.6 pt, which Word cannot set in half points).
- **Tables.** Contents (levels 1 and 2; level 2 half an inch in) and authorities (by kind, sorted, wrapped lines hanging 0.4 in, "passim" from seven pages): the text wraps before a page column (36 pt; 72 pt or the page list's own width), and a dot leader runs from three spaces after the text to the page number. A citation's page is the page on which it starts. The cover counts as page i, so the contents start at ii (as the opening-brief exemplar).
- **docx.** `docx/reference.xml` holds the styles (base="xengine", the face as `{font}`, which is the typst face TeX Gyre Schola; `w14:ligatures none`, so LibreOffice sets no fi or fl ligatures); `docx/ga-brief.lua` writes the cover, the tables, the closing and the certificate from the frontmatter as written (`$FORMBOOK_META`, the strings typst sets) and leaves headings, paragraphs, lists, quotations and footnotes to pandoc in those styles. The table pages come from fb render's needles (the page of every heading and citation in the LibreOffice PDF, rendered again until they settle); the sections and the page-number footer from `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL` (cover unnumbered, front matter ii, iii, ..., body from 1, the number in a 15.6 pt line 27.6 pt above the page edge, where typst sets it). This replaced `build-reference.sh`, `reference.docx` and a two-pass `render.sh`.
- **LibreOffice measures** (docs/EVAL-LOOP.md, "What the federal-appellate adoption found"): the right margin is 1441 twips (1440 to 1442 break every line of the three samples as typst does, 1443 moves one); the three no-break spaces before a leader are two at 13 pt and one at 9 pt, 9.73 pt for typst's 0.75 em (Schola's space is 0.278 em); LibreOffice reserves the face's line height, 15.13 pt, for the footnote separator (measured: a one-line note under a one-line anchor fits with 303 twips to spare, not 302), which typst reserves as an 8.53 pt clearance plus the 6.6 pt gap before the note.
- **DEF-FORM-002.** LibreOffice embeds Schola with word boxes reaching 15.8 pt above the baseline (typst 9.6 pt), so a single line opening a page measures 3.31 pt into the top margin on docx while its glyphs are inside; `eval.yaml` sets the vertical tolerance to 3.5 pt.

Checks (`sh tools/check.sh <this folder> --engine typst|docx`): typst 8 passed, 0 failed; docx 10 passed, 0 failed, XENG-001 PASS (15 pages), XENG-002 and XENG-003 REPORTED (307 of 309 typst lines alike): `eval.yaml` keeps `params.cross_engine: report`. The one difference is LibreOffice's footnote placement: on body page 6 the paragraph's last line ("$33,465,716.") anchors footnote 3, and the line and its three-line note do not fit together below footnote 2. typst moves the line, with its note, to page 7 (a one-line widow there); LibreOffice keeps the line on page 6 and sets the whole note on page 7, so body pages 7 and 8 start a line apart. Widow control on or off, and the note kept whole or allowed to split, both leave the line on page 6 in LibreOffice (docs/EVAL-LOOP.md, "What the federal-appellate adoption found", "Footnotes and widows": no fix found). `tools/check-selftest.sh` does not run here: the court has no `checks.yaml` (fb selftest reads its sample list from it).

Reviewed: every page of both renders as page images at 40 dpi, typst and docx side by side, and the opening brief's cover, contents and authorities and the reply brief's body page 9 again at 70 to 80 dpi. Word itself was not run: the contents and authorities numbers are those of the LibreOffice PDF, and Word may paginate differently (docs/DOCX.md).

BLOCKED: none.
