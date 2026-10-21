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

## Lessons from ca9 (fb-595.43)

- **Dot leaders**: a Word dot-leader tab comes out of the LibreOffice PDF as contiguous dots ("....."), not the spaced " . . ." typst and latex draw; `tools/check/leader-entries.awk` reads both.
- **Page-number column**: give contents/authorities rows a right indent (the number column) and put the right tab beyond it, inside the margin; LibreOffice honours a tab past the right indent for Word documents, so a long title wraps before the numbers instead of pushing them to the next line.
- **Footer first**: LibreOffice draws the footer before the body, so the page number is the first run of a page in `pdftohtml` order; the checker's "page N starts with" (`first_run`) takes the topmost run above the footer.
- **Reproducible output**: `fb render` re-runs on every check, so the docx must be byte-reproducible for a Gate 2 review to stay current. `fb render` writes the archive of a multi-pass build with fixed part dates and a fixed order (tools/fb/src/docxpass.rs); `fb render` rewrites LibreOffice's wall-clock `/CreationDate`, `/ID` and `/DocChecksum` (tools/fb/src/pdfrepro.rs).
- **Small capitals**: LibreOffice synthesizes them at about 80 % size; under a 14 pt minimum use bold or full capitals instead.
- **Check boxes**: a bordered run (`w:bdr`) holding "X" or non-breaking spaces needs no symbol font, so no fallback face appears in the PDF.
- **Page numbers without shell**: a filter that writes needles to `$FORMBOOK_NEEDLES` gets `fb render`'s multi-pass build (tools/fb/src/docxpass.rs and docxpages.rs; contract in their module docs): pages looked up in the LibreOffice PDF, fed back through `$FORMBOOK_PAGES` until they settle, footers `rIdFtrNone`/`rIdFtrPage`/`rIdFtrAdd` added, the last sectPr taken from `$FORMBOOK_FINAL`. ca9 uses it; no `docx/render.sh` is needed.
- **Reference document from text**: a court may keep its Word styles as `docx/reference.xml` instead of a binary `docx/reference.docx` and a shell builder. `fb render` starts from pandoc's default reference and applies it (tools/fb/src/docxref.rs: `w:docDefaults`, `w:style` merged by id or `styles="replace"`, `<footer id="rId..">` parts, the last `w:sectPr`, `theme-font`, `strip-theme-fonts`), in a staged copy of `docx/` so a court's `docx/render.sh` finds `reference.docx` beside itself. `fb docx-reference <docx-dir> <out.docx>` writes the same file for opening the styles in Word. A folder keeps one of the two, never both.
