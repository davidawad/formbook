# Court of Appeals of Georgia (`gactapp`): reply brief (`reply-brief`)

**BLOCKED: no exemplar.** No filed Georgia Court of Appeals reply brief was found (searches as in `../opening-brief/README.md` and `exemplars/SOURCE.md`). The template and a fictional sample were built from the rules as found; the rule text was not read from a primary source (see Governing rules).

## Status of each output

| Item | Result |
|---|---|
| `exemplars/` | empty: no real filing found (`exemplars/SOURCE.md`) |
| `samples/INPUT-fictional-reply-brief.md` | fictional sample, rule-driven, not a transcription |
| render (`tools/render.sh`) | ok: `samples/OUTPUT-fictional-reply-brief.pdf`, 4 pages, exit 0, zero typst warnings, Liberation Serif embedded |
| overlay (`tools/overlay.sh`) | fail: no exemplar PDF to overlay (exit 1) |
| pages reviewed | 4 of 4 (final render, every page viewed at 60 dpi) |

## Governing rules

Rule text status: **not verified against the rule itself**; see `../opening-brief/README.md` for the failed primary-source fetches.

| Requirement | Value in template | Source and status |
|---|---|---|
| Typeface | serif, proportional, 14-point or larger | Ga. Ct. App. R. 2(3) (secondhand). |
| Substitute | **Liberation Serif** (`docs/FONTS.md`, Times New Roman row) | Same choice as the other two doc types. |
| Spacing | as opening brief | Older rule set (2010, secondhand) required double-spacing including quotations. Open item. |
| Margins, paper | 1 inch; US Letter | Convention. |
| Length | not enforced | Reply limit, secondhand: 4,200 words or 15 pages for reply briefs (2017 notice). The same summaries give 8,400 words for civil briefs as amended Oct 9, 2025; the reply figure is **not verified** for the current rule. |
| Required sections | Table of contents (generated); Argument and Citation of Authority; Conclusion | Ga. Ct. App. R. 25 (reply brief, secondhand: 2017 revision lists required and optional elements): **text not retrieved.** The heading set is a guess and must be checked against the rule. |
| Rule number | Ga. Ct. App. R. 25 (reply) | Index by search summary; not verified. |

Date verified: **not verified**. Date of this README: 2026-10-15.

## Known gaps

1. Rule text unverified; the reply brief's required sections and word limit are unverified.
2. No exemplar. The sample is invented and short by design (a reply is short); the 8-14 page target does not apply to it without an exemplar.
3. Not generated: word-count certificate, certificate of service, table of citations.
4. The signature may fall alone onto a new page (see opening brief, gap 4).
5. Block quotations are single-spaced (conflict with the 2010 summary).

## Template and markdown contract

Same as `../opening-brief/`: `typst/main.typ` calls `gactapp-brief` from `typst/gactapp-reply-brief.typ`; frontmatter and body conventions are as in `../opening-brief/README.md`. The sample's cover title is "Reply Brief of Appellant".

## Engines

docx (`docx/`: `reference.docx` from `make-reference.sh`, `gactapp-brief.lua`, `render.sh`; LibreOffice PDF is the checked copy).

- Matches the typst form: Liberation Serif 14 pt throughout; 1-inch margins, Letter; body double-spaced (Word "double"); half-inch first-line indent, none after headings; headings centred caps (level 1), bold (level 2), bold italic (level 3); block quotations indented both sides and single-spaced; cover with no page number; contents on a lower-roman page; body numbered from 1 at the bottom centre; signature block at 3.2 in.
- Contents is a TOC field with cached entries; page numbers come from a first LibreOffice pass (`docx/render.sh`), so Word may show a different page after updating fields.
- Differs: the typst body leading measures about 24.6 pt (pitch of the render), below true double spacing (about 32 pt for this face). The docx uses true double spacing, so it runs longer (opening brief: typst 7 pages, docx 9). This is a typst finding for the typst template, not changed here.
- Footnotes: the typst brief template sets no footnote rule; the docx uses 14 pt single-spaced footnotes (the form's stated 14 pt). No sample has footnotes.
- BLOCKED: none for this doc type. `sh tools/check.sh --engine docx` was not run (no gate run in this bead; the .docx.pdf is rendered and every page was viewed at 60 dpi).
- Opened and rendered with LibreOffice only; not opened in Word.
