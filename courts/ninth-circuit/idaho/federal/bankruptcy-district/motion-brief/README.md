# Motion or brief in a contested matter — United States Bankruptcy Court, D. Idaho (`idb`)

Complete doc-type folder: template, sample, exemplar, render, overlay. Court-level README: [../README.md](../README.md).

The exemplar is a numbered objection with argument (a brief on a motion), not a motion with a separate memorandum. Its filer is the objecting creditors; see the provenance below.

## Layout

- `typst/main.typ` entrypoint; `typst/idb-motion-brief.typ` template (parameters at the top; each cited to the rule it follows).
- `samples/INPUT-ziegler-motion-brief.md` transcribed sample (frontmatter: caption, counsel, lead-in, the dated line and signature; body: numbered paragraphs, `- ` lettered items, `> ` block quote, `~ ` unnumbered continuation, `WHEREFORE` clause, `# CERTIFICATE OF SERVICE`).
- `samples/OUTPUT-ziegler-motion-brief.pdf` our render (7 pages), from `sh tools/render.sh <this-dir> samples/INPUT-ziegler-motion-brief.md`.
- `samples/OVERLAY-ziegler-motion-brief.pdf` and `.txt`, from `sh tools/overlay.sh <this-dir> ziegler-motion-brief`.
- `exemplars/FILED-EXAMPLE-ziegler-20-40042-motion-brief.pdf` the filed objection (9 pages); provenance in `exemplars/SOURCE.md`.

## Rules followed (primary sources, fetched 2026-10-14)

- D. Idaho LBR 5005-1(c), Documents for Filing [v. 3]: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_5005-1_3699.htm?Content_ID=3699
  - Counsel block in the upper left, starting 1 inch from the top, with name, ISB number, email, office address, telephone, facsimile, and the party represented.
  - Type 12 to 14 point (EB Garamond 13 pt). The rule names no typeface (checked against the rule text, 2026-10-15), so the template keeps EB Garamond; no substitute from `docs/FONTS.md` applies.
  - Caption: court name, "In re:", debtor, "Debtor", case number with judge suffix, chapter, and the designation of the paper.
- D. Idaho LBR 9014-1, Witness Testimony at Hearings on Contested Matters: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_9014-1_578.htm?Content_ID=578
  - A party who will present witnesses must say so in its pleading or by separate notice filed and served at least 7 days before the hearing. Not a formatting rule; the template does not implement it.
- D. Idaho LBR 9004-1 (form of orders) is the only Idaho format rule found for submissions; it applies to orders, not to motions or briefs, so the template does not use it.
- Fed. R. Bankr. P. 9013 and 9014 (motions and contested matters) and 9004(a)-(b) (legibility, paper, type size) are cited in the template header; the rule texts were not fetched in this pass.

**Gap, not closed:** no Idaho local rule on the format or length of a motion or brief was found on the local rules index (LBR 9013 and 9013-x do not appear on it). The index page: https://www.id.uscourts.gov/bankruptcy/forms_fees_rules/Rules.cfm (shows revision January 5, 2026). The template therefore takes its form from LBR 5005-1(c) and the filed exemplar, and sets no page or word limit. Verify with the court before relying on the layout as a required form.

## What the overlay shows (`samples/OVERLAY-ziegler-motion-brief.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by word overlap (`.txt` page map):

| our page | filed page | word overlap |
|---|---|---|
| 1 | 1 | 68.1% |
| 2 | 3 | 53.6% |
| 3 | 4 | 63.5% |
| 4 | 6 | 58.1% |
| 5 | 7 | 72.0% |
| 6 | 8 | 54.2% |
| 7 | 9 | 19.1% |

Page 1 aligns on the counsel block, caption, and title. The filed brief's last page (9) holds the DATED line, the firm signature block and the certificate of service's end. Ours puts the DATED line and the firm block alone on page 7, because the body and certificate fill page 6. The filed page count is 9 and ours is 7; the filed text is embedded Times New Roman (per `pdffonts`) and ours is EB Garamond at 13 pt, so the line breaks differ. The sample transcribes the full text of the nine filed pages.

## Gaps

- The filed brief uses bullets in paragraph 4; the template letters them `(a)` to `(f)`.
- The filed footnote 1 is a footnote; the template renders it as an unnumbered paragraph beginning with `¹` at the place where the filed footnote is referenced, not at the foot of the page.
- The filed brief's case names are not italic in the text layer; the sample does not italicize them.
- The filed brief has no separate memorandum, table of contents, or exhibit index; the template has none.
- Page 7 holds only the DATED line and the firm block (see above). The template has no rule that keeps the closing paragraphs with the signature; the filed brief's page 9 does.
- Second filer: not collected. Tier 2 would be judged against 2 or 3 filers. Other candidates checked and not used are listed in `exemplars/SOURCE.md`.

## Engines

### docx (`docx/`)

- Set in `docx/reference.docx` (built by `docx/make-reference.sh`) and read by `docx/idb.lua`. Set in styles.xml/sectPr, not rendered: EB Garamond 13 pt in every style; body and numbered paragraphs double spaced (line 480 auto) with 0.6 em (156 twips) after; US Letter, 1 in margins; headings centered bold (levels 1 and 2) or bold at the left (level 3), single spaced; a centered PAGE field at 11 pt in the footer; block quotes single spaced, indented 0.75 in left and 0.5 in right.
- Written by the filter, not rendered here: counsel block single spaced at the top margin; court heading (two lines); caption as a two-column table with a 0.75 pt vertical rule; title in caps; lead-in and numbered paragraphs with a first-line indent, numbers typed with a tab (not Word list numbering); lettered items `(a)`; the dated line and signature block at 3.0 in; numbering stops after the PRAYER and CERTIFICATE OF SERVICE headings.
- Differs from typst: line breaks and page count come from Word or LibreOffice, not from typst's leading (0.85 em); the typed numbers do not renumber when a paragraph is inserted; the caption rule is a table border, not a line.
- Not yet checked: no page of the docx has been rendered or looked at (pages_reviewed = 0).
- BLOCKED (docx.pdf gates 0 to 3): LibreOffice (`soffice`) is not installed on the build box, so no `.docx.pdf` exists and the gates cannot run. The `.docx` itself is written and validated (zip and well-formed XML parts only).
- BLOCKED (no TOC or TOA in this doc type): nothing to populate.
