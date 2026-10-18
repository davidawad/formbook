# Motion with supporting memorandum: U.S. Bankruptcy Court, D. Utah (utb)

Doc type folder for a motion filed with its supporting memorandum in one document, the form LBR 9013-1 requires. Engine: typst (`typst/`). The exemplar and its filer are in `usage/SOURCE.md`.

## Files

| Path | What it is |
|---|---|
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...` |
| `typst/utb-motion-brief.typ` | The template: parameters, counsel block, Form 416D-style caption, body (headings, paragraphs, lists), signature, certificate markers |
| `usage/INPUT-utb-motion-brief-plaza106motiontodismiss.md` | Our transcription of the Plaza 106 motion to dismiss and memorandum (Doc 32): caption, headings, body, signature, certificate of compliance, certificate of service |
| `usage/OUTPUT-utb-motion-brief-plaza106motiontodismiss.typst.pdf` | Our render, `sh tools/render.sh`, 13 pages |
| `usage/OVERLAY-plaza106-motion-to-dismiss.pdf` / `.txt` | Red (ours) / blue (filed) / black (both) overlay against `SAMPLE-utb-motion-brief-plaza1062602063.pdf`, and the page map |
| `usage/SAMPLE-utb-motion-brief-plaza1062602063.pdf` | Filed exemplar, Doc 32, 16 pp. |

Commands (run from the repo root, toolchain on PATH):

```
sh tools/render.sh courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief usage/INPUT-utb-motion-brief-plaza106motiontodismiss.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief plaza106-motion-to-dismiss courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief/usage/SAMPLE-utb-motion-brief-plaza1062602063.pdf
```

Pass the exemplar explicitly: `overlay.sh` with no third argument uses the first PDF in `usage/`, and this folder has only one.

## Rules

"Text checked" records what was read in this run (2026-10-14). "Cited, not re-read" is carried from the template's comments or from the exemplar's notes and still needs a primary-text check.

| Rule | Requirement used | Source | Text checked |
|---|---|---|---|
| LBR 9013-1 | Motion and any supporting memorandum are one document (single-document rule) | Third-party excerpt of the rule: https://www.courtrules.net/courts/federal/bankruptcy-district-utah/local-rules/rule-9013-1 (returned by search; the page itself returned 403 when fetched) | Excerpt only. Two copies of the rule in the search results differ in wording, so the version is uncertain. |
| LBR 9013-1(h) | 15-page limit for a motion with memorandum | Exemplar `usage/SOURCE.md` note | **Not verified.** No retrieved text gives this limit. |
| DUCivR 7-1(a)(4) (incorporated by LBR 1001-1(a)) | Word limit for a Rule 12(b) motion, and the certificate of compliance | Exemplar's certificate; District of Utah 2018 summary of changes, https://www.utd.uscourts.gov/sites/utd/files/July%202018%20FINAL%20SUMMARY%20OF%20CHANGES%20TO%20LOCAL%20RULES.pdf; Part 8 motion practice, https://www.utd.uscourts.gov/sites/utd/files/Part_8-Motion_Practice.pdf; General Order 23-012, https://www.utd.uscourts.gov/sites/utd/files/general-orders/General_Order_23-012_Adopting_Rule_Amendments_RJS_FINAL_231128.pdf | **Conflict.** Search excerpts of the 2018 summary and the Part 8 guide (the PDFs were not fetched) give 6,500 words or 25 pages for Rule 12(b) motions. The exemplar's note says 7,750 words. This template does not count words or pages, and the number is not confirmed. General Order 23-012 amended DUCivR 7-1 in 2023; its current text was not retrieved. |
| DUCivR 10-1 (format; applies through LBR 1001-1(a)) | Margins, 12 pt minimum, double spacing | Template comments (`typst/utb-motion-brief.typ`); same parameters as the adversary template | cited, not re-read |
| LBR 5005-3(a)(2)–(7) | Margins, font size, page number at foot | Template comments | cited, not re-read |
| Fed. R. Bankr. P. 7012, 7009 (as cited in the motion) | Rule 12(b)(6) and Rule 9(b) apply in the adversary | Motion itself | Taken from the filing; not checked against the rule text. |

Nothing in this folder is verified against the court's current local-rules text. The template does not enforce a page or word limit; the certificate of compliance is transcribed from the filing, and the count (3285 words) was not recomputed.

## Overlay: what it shows

The overlay compares our render (13 pp.) with the Plaza 106 motion (Doc 32, 16 pp.). Pages are paired by shared words.

- Page map (`OVERLAY-plaza106-motion-to-dismiss.txt`, word overlap in brackets): ours p.1 → filed p.1 (76.9%, caption and title); p.2 → p.4 (65.0%); p.3 → p.5 (59.6%); p.4 → p.6 (54.7%); p.5 → p.8 (47.0%); p.6 → p.9 (55.7%); p.7 → p.10 (70.0%); p.8 → p.11 (78.9%); p.9 → p.12 (86.0%); p.10 → p.13 (91.4%); p.11 → p.14 (78.3%); p.12 → p.15 (84.0%); p.13 → p.16 (84.3%, certificate of service).
- Each of our pages pairs with the next filed page, in order. The overlap is lower where our line breaks and the filing's differ. The wording itself matches.
- Filed pp.2–3 (table of contents and table of authorities) have no counterpart in our render. This is the only blue-only block and is listed as a gap below.

## Gaps

1. **No table of contents or table of authorities.** The filing's pp.2–3 are not transcribed or rendered. Our sample starts at the introduction.
2. **Footnote 1 omitted.** The filing's footnote on p.4 (on the Count Two response) is not in the sample. The sentence it supports is not in the transcription.
3. **Word-count certificate not checked.** The sample copies the filing's certificate (3285 words). The template does not compute the count, and the figure was not verified against the body text.
4. **Word and page limits not enforced.** See the table: the 15-page and word limits in the rules are not verified, and the exemplar's note conflicts with the 2018 summary on the Rule 12(b) word limit. The template does not check either.
5. **Counsel firm name differs across filings.** The motion's counsel block reads "VALERGA LLP"; the complaint sample (`../adversary-complaint/`) reads "VALERGA LAWYERS". Both are as filed in each document.
6. **Certificate of service formatting.** The service list is rendered as indented single lines, close to the filing but not a match to its spacing.
7. **Heading styles approximate.** Level-1 headings are centered and bold; level-2 and level-3 headings are bold and left-aligned. The filing's heading treatment was matched by eye, not measured.
8. **Second exemplar not present.** This folder has one exemplar (the Plaza 106 motion). The memorandum-form tier-2 comparison would need a second filer's motion with memorandum, which was not found in RECAP in this run.

## Engines

The typst template is the primary form. The DOCX engine is in `docx/` (`reference.docx`, `utb-motion-brief.lua`, `build-reference.sh`). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief usage/INPUT-utb-motion-brief-plaza106motiontodismiss.md`.

**What the docx matches** (the same mandated form as the typst template): EB Garamond 12 pt; exact 24 pt line pitch; 0.5 in first-line indent on body paragraphs; letter paper with a 1.5 in top margin and 1 in other margins; centred bold level-1 headings and bold left-aligned level-2 and level-3 headings; 12 pt single-spaced footnotes; a bottom-centre page number (PAGE field in the footer). The cover is built from the same metadata: counsel block, court title, Form 416D caption with the third-party group (a borderless table with a right and a bottom rule on the party column), title. Body paragraphs are not numbered. The signature block follows the paragraph before `[[SIGNATURE]]`, and that paragraph is kept with it (keep-with-next). `[[PAGEBREAK]]` starts the certificates on a new page.

**What differs**: Word and LibreOffice break lines differently, so the docx page count is not the typst page count (the typst render is 13 pages). The page break is a paragraph that holds a break, so in Word the page after it begins with a 1 pt empty line. The signature and caption are tables with rules drawn by the application. The EB Garamond font must be installed where the file is opened. The template has no table of contents or table of authorities (the sample has none). The word-count certificate text is the sample's, as in the typst template.

**BLOCKED for the docx engine** (not done on this box):
- `docx.pdf` (`usage/OUTPUT-plaza106-motion-to-dismiss.docx.pdf`, the LibreOffice PDF on which Gates 0 and 1 are measured): BLOCKED, `soffice` not installed on the box (no conda-forge package, no root).
- Zip integrity step of `tools/render-docx.sh` (`unzip -tq`): BLOCKED, `unzip` not installed on the box. `tools/render.sh --engine docx` wrote `usage/OUTPUT-utb-motion-brief-plaza106motiontodismiss.docx` and then exited 1 with `render-docx.sh: unzip: not found` and `not a valid zip`. As a substitute, every XML and rels part was checked with `ziptool` and `xmllint --noout`: all well-formed.
- Visual review of the docx pages (LibreOffice or Word, no repair prompt): BLOCKED, no LibreOffice and no Word. Pages reviewed: 0. The typst render (13 pages) was reviewed page by page; the docx was not.
- `sh tools/check.sh <dir> --engine docx` not run to a pass: it needs the `.docx.pdf` (see above), so no `.check-docx.txt` stamp is written.
