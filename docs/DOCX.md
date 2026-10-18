# DOCX: what works, what does not

The docx engine (see `docs/EVAL-LOOP.md`, "Engines") is built with pandoc, a per-court `docx/reference.docx`, and Lua filters in `docx/*.lua`. Gates 0 and 1 run on the **LibreOffice PDF** of the `.docx` (`<id>.docx.pdf`, made by `soffice --headless --convert-to pdf`), because there is no scriptable Word here. Word may paginate slightly differently (line breaking, font metrics, table row heights). The `.docx` must also open in Word and in LibreOffice without a repair prompt.

A court PR may deliver docx as BLOCKED or partial if it lists the exact failing check IDs and why. Silently missing is not acceptable. Use this file for the limits that recur across courts; add to it when you meet a new one (one line: the thing, the engine behavior, the workaround or the BLOCKED reason).

## Use the Word-native feature when one exists

| Court wants | Word-native feature | Notes |
|---|---|---|
| Numbered lines in the margin (pleading paper) | Section line numbering, `w:lnNumType` (`w:countBy`, `w:restart="newPage"`, `w:distance`) in `w:sectPr` | Numbers only the lines in the body flow; a table, a text box or a footnote is not numbered. Exactly 28 numbered lines per page needs exact line spacing (`w:spacing w:line=".." w:lineRule="exact"`), not "double". |
| Vertical rules beside the text (pleading paper) | Page borders (`w:pgBorders`), left and right | Border offset is measured from text or from page edge (`w:offsetFrom`); LibreOffice and Word differ on a double rule's spacing. |
| Table of contents | TOC field (`TOC \o "1-5" \h`) over heading styles | Fields are empty until updated. Word asks to update on open if `w:updateFields` is set in `settings.xml`; LibreOffice needs an update on load. For the checked PDF the renderer must have the TOC populated, so generate it (a filter that writes the entries and page numbers from a first pass, or a LibreOffice macro update step in `docx/render.sh`). |
| Table of authorities | TA fields on each citation and a `TOA` field per category | Same update caveat. LibreOffice does not honor TA/TOA fields the way Word does (it has its own bibliography/index model): expect BLOCKED on the TOA check IDs unless the filter writes the table text itself, with page numbers from a first pass. |
| Headings stay with the next paragraph | `w:keepNext` on the heading styles | Works in both. Also set `w:keepLines` for headings. |
| Widows and orphans | `w:widowControl` | Works in both. |
| Page numbering in the footer | `PAGE` field, section `w:pgNumType` for roman then arabic | Works in both. A "Page X of Y" form needs `NUMPAGES`; check it in the PDF. |
| Footnotes | Native footnotes (pandoc emits them) | Footnote text size comes from the `Footnote Text` style in the reference.docx. |
| Block quotations, indentation | Paragraph styles with `w:ind`, not tabs or spaces | |
| Fonts | Name the font in the styles; the court font must be installed on the machine that opens the file | Word will substitute silently if the font is missing. Embedding (`w:embedTrueTypeFonts`) works in Word but LibreOffice ignores it. The checked PDF must show the declared font; the font name check is the proof. For the PDF conversion the vendored fonts must be visible to LibreOffice (install them for the user running the check, or point `docx/render.sh` at a font directory). |

## Known limits

- **Pagination differs by renderer.** Word and LibreOffice disagree on line breaks and therefore on page numbers in a TOC or TOA. A TOC/TOA page-number check passes against the LibreOffice PDF and may be off by a page in Word. State this in the PR; do not "fix" it by forcing page breaks.
- **Exact page counts and word counts** are measured on the LibreOffice PDF.
- **Fields (TOC, TOA, cross-references)** are computed by the application. pandoc writes the field but not its result. A docx whose fields were never updated looks empty in a viewer that does not update on open. Prefer writing the result text into the field (cached field result) so every viewer shows it.
- **PDF bookmarks and tagged PDF** are not emitted by the LibreOffice conversion by default; a check for them is an engine-specific check (`engines: [typst, latex]` with a reason) unless `docx/render.sh` enables them (`--convert-to 'pdf:writer_pdf_Export:{"ExportBookmarks":{"type":"boolean","value":"true"}}'`).
- **Cover pages and caption boxes** (case caption tables with a vertical rule) are tables in Word. Table borders render slightly differently between Word and LibreOffice; judge the LibreOffice PDF and say so.
- **Line numbering with tables or footnotes**: Word skips them; some courts' pleading rules require numbers to continue. Mark such a requirement BLOCKED with its check ID if no workaround (a frame or text box per page) is acceptable.
- **Kerning, ligatures and hyphenation** are application defaults; the typst and latex engines control them. Do not assert them for docx.
- **Image-only content** (a scanned exhibit) cannot pass the content gate; exhibits are out of scope for the templates.

## Checking a docx

1. `sh tools/render.sh --engine docx <doc-dir> usage/INPUT-<id>.md` writes `usage/OUTPUT-<id>.docx` and `usage/OUTPUT-<id>.docx.pdf`.
2. `sh tools/check.sh <doc-dir> --engine docx` runs Gates 0 to 3 on the `.docx.pdf` and writes `usage/.check-docx.txt` only when everything passes.
3. Open the `.docx` in LibreOffice (and Word if you have it) and confirm there is no repair prompt. Record that, and every page you looked at, in the review file under `## sample <id> docx`.
4. Anything that cannot pass goes in the PR as `BLOCKED: <check ID>: <why>` lines.
