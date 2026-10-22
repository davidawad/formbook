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

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.54.36): `typst/layout.yaml` holds the
whole layout, every number with its rule; `typst/ga-opening-brief.typ` names the face (TeX Gyre Schola) and hands the
layout to `lib/typst/xdoc.typ`; `latex/` and `docx/` are generated from the layout by `fb engines gen` (the Schola
glyph widths in LaTeX by `lib/latex/xeschola.lua`). The answering, opening, reply, amicus and merits briefs share the
layout (one copy per folder). The table of authorities is keyed: the frontmatter's `authorities: {key: {kind, name,
cite, sort}}`, a case's name in italics as written (`*...*`), an authority with one citation text under `cite`.

Checks (`sh tools/check.sh <this folder> --engine typst|latex|docx`), 15 pages each: typst 8 passed, 0 failed; latex
10 passed, 0 failed, XENG-001 and -002 PASS, XENG-003 REPORTED (308 of 310 typst lines: typst ends a line after the
slash in "redline/blue", pdfLaTeX has no break there); docx 10 passed, 0 failed, XENG-001 PASS, XENG-002 and -003
REPORTED (308 of 310: LibreOffice's footnote placement on body page 6, as before the move). `eval.yaml` keeps
`params.cross_engine: report`; both requests are in docs/open-items/fb-595.54.36.md.

Reviewed: every page of the three renders at 36 to 40 dpi, and typst against the earlier template's render page by
page (the same pages and breaks but for the first paragraph after a heading, now indented as every paragraph).

BLOCKED: none.
