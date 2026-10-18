# Court of Appeals of Georgia (`gactapp`): appellant's brief (`opening-brief`)

Exemplar: **yes** (`usage/FILED-EXAMPLE-opening-brief.pdf`, Appellant's Brief in *Campbell v. Taylor*, No. A26A1103, filed January 26, 2026 by Jody D. Peterman, LLC; source in `usage/SOURCE.md`). The sample is a transcription of it.

## Status of each output

| Item | Result |
|---|---|
| `usage/` | 1 filed brief, text PDF, 18 pages, court e-filing stamp "Case A26A1103 Filed 01/26/2026" on every page |
| `usage/INPUT-opening-brief.md` | transcription of the whole filed brief (cover, table of authorities, all sections, signature, certificate of service). The id still says "fictional": it was kept so the existing docx outputs keep their names (see Engines) |
| render (`tools/render.sh`) | ok: `usage/OUTPUT-opening-brief.typst.pdf`, 17 pages, exit 0, zero typst warnings, Liberation Serif (regular, bold, italic, bold italic) embedded |
| overlay (`tools/overlay.sh`) | ok: `usage/OVERLAY-fictional-opening-brief.pdf` and `.txt` |
| pages reviewed | 17 of 17 (every page rendered at 60 dpi and looked at), plus the 18 exemplar pages |

## Governing rules (primary source, read 2026-10-16)

Court of Appeals of Georgia Rules, effective March 26, 2026: `https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf`. gaappeals.gov refuses this box (HTTP 403), so the PDF was read from the Internet Archive copy `https://web.archive.org/web/2026id_/https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf` (53 pages, text PDF). This table replaces the earlier secondhand one; the same rules govern the appellee's brief and the reply brief.

| Requirement | Rule | Template |
|---|---|---|
| Letter paper (8 1/2 x 11), searchable PDF | 2 (c) (1), 2 (a) (2) (i) | `paper: "us-letter"`; typst writes text PDFs |
| No less than double spacing, except block quotations, headings, captions and footnotes | 2 (c) (2) | `body-leading = 1.65em`: baseline pitch 32.3 pt measured on the render, the exemplar measures 32.2 pt (Word "double" at 14 pt). **Changed**: the old 1.1em gave 24.6 pt, below double spacing |
| Serif, proportionally spaced, 14 pt or larger; Times New Roman and Century Schoolbook named as examples; no monospace; italics or bold only for emphasis | 2 (c) (3) | Liberation Serif 14 pt (Times New Roman substitute, `docs/FONTS.md`); footnotes 14 pt |
| Margins not less than 1 inch at top, sides, bottom | 24 (c) | 1 in all sides |
| Pages numbered sequentially with an Arabic numeral at the bottom of each page | 24 (e) | **Changed**: every page Arabic, cover = 1 (was: unnumbered cover, roman contents). The exemplar numbers its cover 1 |
| 8,400 words civil, 14,000 criminal; certification "This submission does not exceed the word count limit imposed by Rule 24." just above the signature block | 24 (f) (1), (3) | **Added**: the sentence is printed above the signature block (fixed rule text). Word count itself is not computed |
| Signed; mailing address, phone, e-mail, State Bar number; "/s/" typed name underlined, typed name again below the underline | 2 (a), 2 (a) (2) (ii) | **Changed**: each signer prints underlined "/s/ *Name*", then the name, then its lines |
| Certificate of service on opposing counsel, method identified; e-mail service needs the prior-agreement certification | 2 (a), 6 (b) (2), 6 (d) | **Added**: `service` frontmatter renders a "Certificate of Service" page with recipients and a signature |
| Contents: (1) for long briefs a table of contents and of cited authorities with page references; (2) introduction; (3) jurisdictional statement; (4) enumeration of errors; (5) statement of the case; (6) summary of argument; (7) argument with standard of review. Items 3, 4, 5, 7 mandatory | 25 (a) | Body headings come from the markdown; contents generated; **added** an optional generated table of authorities (`authorities` frontmatter) |
| Citations by case name, volume, page, year of the Official Report | 24 (d) | content, not template |
| Address of a criminal defendant on the face of the brief | 24 (h) | not applicable to the sample (civil); a criminal brief adds it to `counsel` or the caption |

## Exemplar, overlay page map

`usage/OVERLAY-fictional-opening-brief.txt`: ours 1-10 pair with filed 1-10 (cover 90%, contents 74%, authorities 90%, body 44-67%), ours 11-15 with filed 12-15 (our page breaks run about one page ahead: 17 pages against 18), ours 16 with filed 16 (signature, 71%), ours 17 with filed 17 (certificate of service, 66%). Body lines sit on the same pitch (black where they agree in the overlay); the drift is word wrap (Liberation Serif vs. the filer's Times New Roman, and their justified text).

## Gate 2 review (all 17 pages, 60 dpi)

| Page | Content | Finding |
|---|---|---|
| 1 | Cover: court, case no., caption, title, counsel | OK. Centred caption (the filer uses a ")" two-column caption: tier 3, not chased) |
| 2 | Table of contents with leaders and pages | OK |
| 3 | Table of authorities, Cases and Constitution | OK; pages generated from the body |
| 4 | Introduction, Jurisdictional Statement, Enumeration of Errors, Statement of the Case | OK. Headings 14 pt bold caps centred |
| 5-6 | Statement of the case, deposition Q/A as a single-spaced block quote | OK |
| 7-14 | Argument, sub-headings A, B, 1 | OK; double spaced, 0.5 in indents |
| 15 | Conclusion | OK; the rest of the page is empty because the certification and signature are kept together (ACCEPTED) |
| 16 | Word-count certification, date, firm, three signers, address | OK |
| 17 | Certificate of service | OK |

## What changed (template `typst/gactapp-opening-brief.typ`)

Double spacing (Rule 2 (c) (2)); Arabic numbering on every page (24 (e)); fixed Rule 24 certification above the signature (24 (f) (1)); conformed underlined signatures, several signers (2 (a) (2) (ii)); certificate of service (6); generated table of authorities (25 (a) (1)); headings forced to 14 pt and full width (they rendered at typst's default heading size and left-aligned before); first-line indent on every paragraph, as filed; footnotes 14 pt single spaced; `proceeding` now optional.

## Markdown contract

Frontmatter: `case_number`; `caption` (two sides: `names`, `designation`); `proceeding` and `trial_court_case` (optional, centred under the caption); `brief_title`; `counsel` (groups: `names` bold, `lines`); `phone` (optional); `signature` (`firm` optional, `signers` list of `name` + `lines`, or the older single `signer`; `lines` printed after the signers); `date` (a full sentence printed after the certification, e.g. "Respectfully submitted this ..."); `toc` (default true); `authorities` (groups: `heading`, `entries` of `cite` and `find`: a string present in every citation of that authority, e.g. "324 Ga. App.", whose occurrences give the page numbers); `service` (`paragraphs`, `recipients` list of line lists, `closing`, `first_signer_only` default true). Body: `#` section heading (centred caps bold), `##` and `###` sub-headings; `>` block quotations; `[^n]` footnotes. Escape `[X]:` at a line start (`\[X\]:`), or markdown reads it as a link definition.

## Known gaps

1. Word count is not computed or checked against 8,400 / 14,000 words.
2. Case names are italic, not underlined as in this exemplar (Rule 2 (c) (3) allows either).
3. A `find` string that appears in another authority's citation would over-count pages; choose volume + reporter strings.
4. docx outputs are stale (below).

## Engines

docx (`docx/`: `reference.docx`, `gactapp-brief.lua`, `render.sh`). **Not regenerated in this pass**: this box has no LibreOffice (`soffice`), so `OUTPUT-opening-brief.docx` and `.docx.pdf` are still renders of the earlier synthetic sample, and the docx form still has the old numbering (unnumbered cover, roman contents), no Rule 24 certification and no certificate of service. These are open docx items (`BLOCKED` until rerun with `soffice`): Rule 24 (e) numbering, Rule 24 (f) (1) certification, Rule 6 certificate, the new frontmatter keys (`signature.signers`, `authorities`, `service`). latex: none in this court.
