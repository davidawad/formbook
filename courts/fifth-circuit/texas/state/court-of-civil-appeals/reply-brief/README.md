# Appellant’s Reply Brief template

## Governing rules (verified 2026-10-14)

- Texas Rules of Appellate Procedure 9.4(c)–(e), (g), (i), and (j): margins, spacing, typeface, cover, length/word count, and electronic filing requirements. Official current rules, updated February 6, 2026: https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf
- Texas Rules of Appellate Procedure 38.1 (appellant brief contents); Rule 38.2 (appellee brief); Rule 38.3 (reply brief). Same official rules URL above.
- Fifth Court of Appeals Local Rule 5: cross-appeal brief length limits and briefing schedule; https://www.txcourts.gov/5thcoa/practice-before-the-court/local-rules/ (approved May 2, 2017; checked 2026-10-14).

The template uses 14-point EB Garamond, US Letter pages, one-inch margins, and double-spaced body text in accordance with Rule 9.4. Cover metadata fields provide the case number, parties, lower court and cause number, brief title, and counsel. The body is author-supplied markdown; this simple template does not automatically construct the table of contents, authorities, signature block, word-count certificate, or certificate of service. Include all Rule 38 contents and Rule 9.4 certificates before filing.

## Exemplar and overlay

BLOCKED: no exemplar. Public case dockets and filer-hosted PDFs were found in searches, but their document URLs returned HTTP 403 from this environment. See `exemplars/SOURCE.md` for the docket and candidate filed PDFs with fetch failures. The intended overlay places the sample render in red over the filed PDF in blue, with matching content in black; it cannot be produced without the filed PDF.

## Known gaps

- This template's cover and markdown flow are a basic render scaffold; it is not yet validated against a filed example.
- Page limits vary by type and appeal; check Rule 9.4(i) and local rules, including cross-appeals.
- This build does not provide an automatic TOC/TOA, page numbering, word-count certificate, or generated certificate language.

## Render review (2026-10-14)

Rendered with `sh tools/render.sh` and reviewed both pages at 60 dpi. Page 1 contains only the cover. Page 2 contains the fictional sample body with no clipping or unexpected overflow. No exemplar comparison was possible. Per-page notes and the PDF hash are in `reviews/2026-10-14.md`.
