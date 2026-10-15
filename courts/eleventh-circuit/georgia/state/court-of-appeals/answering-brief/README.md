# Court of Appeals of Georgia (`gactapp`): appellee's brief (`answering-brief`)

**BLOCKED: no exemplar.** No filed Georgia Court of Appeals appellee's brief was found (searches as in `../opening-brief/README.md`, plus the CourtListener and web searches recorded in `exemplars/SOURCE.md`). The template and a fictional sample were built from the rules as found; the rule text was not read from a primary source (see Governing rules).

## Status of each output

| Item | Result |
|---|---|
| `exemplars/` | empty: no real filing found (`exemplars/SOURCE.md`) |
| `samples/INPUT-fictional-answering-brief.md` | fictional sample, rule-driven, not a transcription |
| render (`tools/render.sh`) | ok: `samples/OUTPUT-fictional-answering-brief.pdf`, 5 pages, exit 0, zero typst warnings, Liberation Serif embedded |
| overlay (`tools/overlay.sh`) | fail: no exemplar PDF to overlay (exit 1) |
| pages reviewed | 5 of 5 (final render, every page viewed at 60 dpi) |

## Governing rules

Rule text status: **not verified against the rule itself**; see `../opening-brief/README.md` for the failed primary-source fetches and the secondhand Rule 2(3) summary. The typeface, size and spacing are the same as the opening brief.

| Requirement | Value in template | Source and status |
|---|---|---|
| Typeface | serif, proportional, 14-point or larger | Ga. Ct. App. R. 2(3) (secondhand). |
| Substitute | **Liberation Serif** (`docs/FONTS.md`, Times New Roman row) | Same choice as the opening brief. |
| Spacing | as opening brief: double-spaced body, single-spaced headings, block quotations and cover | Older rule set (2010, secondhand) required double-spacing including quotations. Open item. |
| Margins, paper | 1 inch; US Letter | Convention. |
| Required sections | Table of contents (generated); Counter-Statement of the Case; Counter-Statement of Facts; Argument and Citation of Authority; Conclusion | Ga. Ct. App. R. 23 (appellee's brief): **text not retrieved.** The heading set is a guess from the opening brief's structure and must be checked against the rule. |
| Rule number | Ga. Ct. App. R. 23 | Index by search summary; not verified. |
| Word limit, word-count certificate | not enforced, not generated | Ga. Ct. App. R. 24 (secondhand, as opening brief). |

Date verified: **not verified**. Date of this README: 2026-10-15.

## Known gaps

1. Rule text unverified; the required appellee's-brief sections are unverified (the heading set is a guess).
2. No exemplar. The sample is invented; 5 pages (cover, contents, 3 body) is below the 8-14 page target, which cannot be checked without a real filing.
3. Not generated: table of citations, word-count certificate, certificate of service.
4. The signature can fall alone onto a new page (see opening brief, gap 4). The fictional sample was trimmed to fit; a real brief may not fit.
5. Block quotations are single-spaced (conflict with the 2010 summary).

## Template and markdown contract

Same as `../opening-brief/`: `typst/main.typ` calls `gactapp-brief` from `typst/gactapp-answering-brief.typ`; the frontmatter fields and body conventions are the same (see `../opening-brief/README.md`). The cover title is `brief_title` (the sample uses "Brief of Appellee").

## Engines

docx (`docx/`: `reference.docx` from `make-reference.sh`, `gactapp-brief.lua`, `render.sh`; LibreOffice PDF is the checked copy).

- Matches the typst form: Liberation Serif 14 pt throughout; 1-inch margins, Letter; body double-spaced (Word "double"); half-inch first-line indent, none after headings; headings centred caps (level 1), bold (level 2), bold italic (level 3); block quotations indented both sides and single-spaced; cover with no page number; contents on a lower-roman page; body numbered from 1 at the bottom centre; signature block at 3.2 in.
- Contents is a TOC field with cached entries; page numbers come from a first LibreOffice pass (`docx/render.sh`), so Word may show a different page after updating fields.
- Differs: the typst body leading measures about 24.6 pt (pitch of the render), below true double spacing (about 32 pt for this face). The docx uses true double spacing, so it runs longer (opening brief: typst 7 pages, docx 9). This is a typst finding for the typst template, not changed here.
- Footnotes: the typst brief template sets no footnote rule; the docx uses 14 pt single-spaced footnotes (the form's stated 14 pt). No sample has footnotes.
- BLOCKED: none for this doc type. `sh tools/check.sh --engine docx` was not run (no gate run in this bead; the .docx.pdf is rendered and every page was viewed at 60 dpi).
- Opened and rendered with LibreOffice only; not opened in Word.
