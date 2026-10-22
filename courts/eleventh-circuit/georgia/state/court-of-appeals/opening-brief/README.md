# Court of Appeals of Georgia (`gactapp`): appellant's brief (`opening-brief`)

Exemplar: **yes** (`usage/FILED-EXAMPLE-opening-brief.pdf`, Appellant's Brief in *Campbell v. Taylor*, No. A26A1103, filed January 26, 2026 by Jody D. Peterman, LLC; source in `usage/SOURCE.md`). The sample is a transcription of it.

## Status of each output

| Item | Result |
|---|---|
| `usage/` | 1 filed brief, text PDF, 18 pages, court e-filing stamp "Case A26A1103 Filed 01/26/2026" on every page |
| `usage/INPUT-opening-brief.md` | transcription of the whole filed brief (cover, table of authorities, all sections, signature, certificate of service). The id still says "fictional": it was kept so the existing docx outputs keep their names (see Engines) |
| render (`tools/render.sh`) | ok: `usage/OUTPUT-opening-brief.typst.pdf`, 17 pages, exit 0, zero typst warnings, Times New Roman (regular, bold, italic) embedded |
| overlay (`tools/overlay.sh`) | ok: `.overlay/courts/eleventh-circuit/georgia/state/court-of-appeals/opening-brief/OVERLAY-opening-brief.pdf` and `.txt` |
| pages reviewed | all 17 output pages and all 18 exemplar pages rendered at 60 dpi and inspected |

## Governing rules (primary source, read 2026-10-16)

Court of Appeals of Georgia Rules, effective March 26, 2026: `https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf`. gaappeals.gov refuses this box (HTTP 403), so the PDF was read from the Internet Archive copy `https://web.archive.org/web/2026id_/https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf` (53 pages, text PDF). This table replaces the earlier secondhand one; the same rules govern the appellee's brief and the reply brief.

| Requirement | Rule | Template |
|---|---|---|
| Letter paper (8 1/2 x 11), searchable PDF | 2 (c) (1), 2 (a) (2) (i) | `paper: "us-letter"`; typst writes text PDFs |
| No less than double spacing, except block quotations, headings, captions and footnotes | 2 (c) (2) | `pitch-double = 32.2pt`: exact 32.2 pt line boxes, Word "double" at 14 pt, as the exemplar measures |
| Serif, proportionally spaced, 14 pt or larger; Times New Roman and Century Schoolbook named as examples; no monospace; italics or bold only for emphasis | 2 (c) (3) | Times New Roman 14 pt (Liberation Serif declared as fallback, `docs/FONTS.md`); footnotes 14 pt |
| Margins not less than 1 inch at top, sides, bottom | 24 (c) | 1 in all sides |
| Pages numbered sequentially with an Arabic numeral at the bottom of each page | 24 (e) | **Changed**: every page Arabic, cover = 1 (was: unnumbered cover, roman contents). The exemplar numbers its cover 1 |
| 8,400 words civil, 14,000 criminal; certification "This submission does not exceed the word count limit imposed by Rule 24." just above the signature block | 24 (f) (1), (3) | **Added**: the sentence is printed above the signature block (fixed rule text). Word count itself is not computed |
| Signed; mailing address, phone, e-mail, State Bar number; "/s/" typed name underlined, typed name again below the underline | 2 (a), 2 (a) (2) (ii) | **Changed**: each signer prints underlined "/s/ *Name*", then the name, then its lines |
| Certificate of service on opposing counsel, method identified; e-mail service needs the prior-agreement certification | 2 (a), 6 (b) (2), 6 (d) | **Added**: `service` frontmatter renders a "Certificate of Service" page with recipients and a signature |
| Contents: (1) for long briefs a table of contents and of cited authorities with page references; (2) introduction; (3) jurisdictional statement; (4) enumeration of errors; (5) statement of the case; (6) summary of argument; (7) argument with standard of review. Items 3, 4, 5, 7 mandatory | 25 (a) | Body headings come from the markdown; contents generated; **added** an optional generated table of authorities (`authorities` frontmatter) |
| Citations by case name, volume, page, year of the Official Report | 24 (d) | content, not template |
| Address of a criminal defendant on the face of the brief | 24 (h) | not applicable to the sample (civil); a criminal brief adds it to `counsel` or the caption |

## Exemplar, overlay page map

(Measured before the fb-595.68.36 port, which moved the layout onto exact line boxes; regenerate with `just overlay` for current pages.)

The regenerated same-id overlay pairs ours pages 1-10 with filed pages 1-10, ours pages 11-15 with filed pages 12-15, ours page 16 with filed page 16, and ours page 17 with filed page 17. Body line pitch matches; remaining drift is word wrap (Liberation Serif vs. the filer's Times New Roman and justified text).

## Gate 2 review (all 17 pages of the typst and docx renders, 50 dpi; re-done for fb-595.68.36)

| Page | Content | Finding |
|---|---|---|
| 1 | Cover: court, case no., caption, title, counsel | OK. Centred caption (the filer uses a ")" two-column caption: tier 3, not chased) |
| 2 | Table of contents with leaders and pages | OK |
| 3 | Table of authorities, Cases and Constitution | OK; pages generated from the body |
| 4 | Introduction, Jurisdictional Statement, Enumeration of Errors, Statement of the Case | OK. Headings 14 pt bold caps centred |
| 5-6 | Statement of the case, deposition Q/A as a single-spaced block quote | OK |
| 7-14 | Argument, sub-headings A, B, 1 | OK; double spaced, 0.5 in indents |
| 15 | Argument end, Conclusion | OK |
| 16 | Conclusion end, word-count certification, date, firm, three signers, address | OK; certification, date and signature kept together |
| 17 | Certificate of service | OK |

## What changed (template `typst/gactapp-opening-brief.typ`)

Double spacing (Rule 2 (c) (2)); Arabic numbering on every page (24 (e)); fixed Rule 24 certification above the signature (24 (f) (1)); conformed underlined signatures, several signers (2 (a) (2) (ii)); certificate of service (6); generated table of authorities (25 (a) (1)); headings forced to 14 pt and full width (they rendered at typst's default heading size and left-aligned before); first-line indent on every paragraph, as filed; footnotes 14 pt single spaced; `proceeding` now optional.

## Markdown contract

Frontmatter: `case_number`; `caption` (two sides: `names`, `designation`); `proceeding` and `trial_court_case` (optional, centred under the caption); `brief_title`; `counsel` (groups: `names` bold, `lines`); `phone` (optional); `signature` (`firm` optional, `signers` list of `name` + `lines`, or the older single `signer`; `lines` printed after the signers); `date` (a full sentence printed after the certification, e.g. "Respectfully submitted this ..."); `toc` (default true); `authorities` (groups: `heading`, `entries` of `cite` and `find`: a string present in every citation of that authority, e.g. "324 Ga. App.", whose occurrences give the page numbers); `service` (`paragraphs`, `recipients` list of line lists, `closing`, `first_signer_only` default true). Body: `#` section heading (centred caps bold), `##` and `###` sub-headings; `>` block quotations; `[^n]` footnotes. Escape `[X]:` at a line start (`\[X\]:`), or markdown reads it as a link definition.

## Known gaps

1. Word count is not computed or checked against 8,400 / 14,000 words.
2. Case names are italic, not underlined as in this exemplar (Rule 2 (c) (3) allows either).
3. A `find` string that appears in another authority's citation would over-count pages; choose volume + reporter strings.
4. The docx is checked in LibreOffice (the PDF the gates read); Word may paginate slightly differently (docs/DOCX.md).

## Engines

typst, latex and docx on the shared document model (fb-595.54.12; docs/EVAL-LOOP.md, "Generated engines"): `typst/layout.yaml` holds the layout below as data, `typst/gactapp-opening-brief.typ` hands it to `lib/typst/xdoc.typ`, and `fb engines gen` writes `latex/` and `docx/` from it (the court's answering, reply and amicus briefs share the layout). LaTeX and Word break every line and page where typst does (`params.cross_engine: gate` in `eval.yaml`; fb-595.54.59). The paragraphs below record the earlier hand-written docx filter (fb-595.68.36), which the generated engines replace.

Layout model, the same numbers in both engines (twips = 20 x pt): Times New Roman 14 pt, footnotes too (Rule 2 (c) (3)); body text in exact 32.2 pt line boxes (644 twips; Rule 2 (c) (2) double spacing, Word's "double" at 14 pt); single lines 16.1 pt (322 twips) for the cover, tables, headings, quotations, footnotes, signature and recipients; quotations half an inch in on both sides with a blank single line around them and between their paragraphs; level-1 headings centered bold capitals 24 pt below the text and 16 pt above the next, levels 2 and 3 bold (3 italic) 16 pt / 12 pt, wrapped lines hanging half an inch; footnotes 8 pt apart, each kept whole, the room above them one single line (typst clearance 8.1 pt plus the 8 pt entry gap: what LibreOffice keeps for its separator); contents and authorities rows 8 pt apart, the text wrapping before a 36 pt (contents) or 56 pt (authorities) page column with the leader at least three spaces after it; the page number centered in a single line whose foot is 0.5 in above the page edge; every page numbered from the cover (Rule 24 (e)).

The docx was built by `docx/make-reference.sh` and `docx/render.sh` (a two-pass shell page lookup for the contents) on Liberation Serif, with an unnumbered cover, roman contents, no table of authorities, no Rule 24 (f) (1) certification and no certificate of service (DEF-COVER-001 and TNR-EMBEDDED failed). Now `fb render` builds `reference.docx` from `docx/reference.xml` (base="xengine", the face as `{font}`) and runs the filter's page lookup through needles (`FORMBOOK_NEEDLES`: the cover, the authorities' title, every heading with the words after it, every occurrence of an authority's `find` string in the body and its footnotes, as the typst show rule marks it). Break rules the filter adds to `docx.xengine`'s: no break before a closing or infix sign (the space before ". . ."), none inside ")(" (word joiner) or after a doubled sign ("¶¶ 2"), a break after a slash between letters.
