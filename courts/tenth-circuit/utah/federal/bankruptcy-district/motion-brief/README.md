# Motion with supporting memorandum: U.S. Bankruptcy Court, D. Utah (utb)

Doc type folder for a motion filed with its supporting memorandum in one document, the form LBR 9013-1 requires. Engines: typst (`typst/`, the reference) and docx (`docx/`). The exemplar and its filer are in `usage/SOURCE.md`.

## Files

| Path | What it is |
|---|---|
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...` |
| `typst/utb-motion-brief.typ` | The template: parameters, counsel block, Form 416D-style caption, body (headings, paragraphs, lists), signature, certificate markers |
| `docx/reference.xml` | The Word styles, page and footer (built by `fb render`; base `xengine`) |
| `docx/utb-motion-brief.lua` | The docx filter: the same chunks, caption, signature and markers as the typst template |
| `eval.yaml` | `params.cross_engine: gate` |
| `usage/INPUT-motion-brief.md` | Our transcription of the Plaza 106 motion to dismiss and memorandum (Doc 32): caption, headings, body, signature, certificate of compliance, certificate of service |
| `usage/OUTPUT-motion-brief.typst.pdf` | Our render, `sh tools/render.sh`, 13 pages |
| `usage/OUTPUT-motion-brief.docx` / `.docx.pdf` | The docx render and its LibreOffice PDF, 13 pages |
| `usage/OVERLAY-plaza106-motion-to-dismiss.pdf` / `.txt` | Red (ours) / blue (filed) / black (both) overlay against `FILED-EXAMPLE-motion-brief.pdf`, and the page map |
| `usage/FILED-EXAMPLE-motion-brief.pdf` | Filed exemplar, Doc 32, 16 pp. |

Commands (run from the repo root, toolchain on PATH):

```
sh tools/render.sh courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief plaza106-motion-to-dismiss courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf
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
6. **Certificate of service formatting.** The service list is rendered as indented double-spaced lines, close to the filing but not a match to its spacing.
7. **Heading styles approximate.** Level-1 headings are centered and bold; level-2 and level-3 headings are bold and left-aligned. The filing's heading treatment was matched by eye, not measured.
8. **Second exemplar not present.** This folder has one exemplar (the Plaza 106 motion). The memorandum-form tier-2 comparison would need a second filer's motion with memorandum, which was not found in RECAP in this run.

## Engines

The typst template is the reference; the docx engine is in `docx/` (`reference.xml`, the Word styles; `utb-motion-brief.lua`, the filter). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md`. `fb render` builds the reference document from `docx/reference.xml`; no shell script and no binary `reference.docx` (fb-595.68).

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"), and the docx breaks every line and page where the typst render does: `eval.yaml` sets `params.cross_engine: gate`, and XENG-001..003 pass (301/301 lines, 13 = 13 pages).

- **Face and size**: Times New Roman 12 pt on both (no rule names a face, UTB-FORM-004; the docx used to name EB Garamond and failed DEF-FONT-002). The docx names the face only as `{font}`, the typst template's face.
- **Pitches** (Word's exact line spacing; twips = 20 x pt): body paragraphs and list items double-spaced at 24 pt (480; DUCivR 10-1(4)), no extra space between paragraphs, the first line indented 0.5 in; counsel block, court title, caption, title, headings and signature single-spaced at 13.8 pt (276). Headings 12 pt bold (level 1 centered, levels 2 and 3 at the margin), 18 pt above and 6 pt below, kept with the text after them. The parts of the first page 24 pt apart. A list's label in a 0.5 in box, the text hanging after it.
- **Caption** (Form 416D, with the third-party group): the party column 3.3 in wide, ruled on its right and at its foot (0.75 pt; its text 10 pt from the right rule and 8 pt above the foot), a blank single line between its elements; the case numbers and the judge 0.15 in right of the 0.25 in gutter. The docx writes it as a one-row table.
- **Signature**: "DATED ..." at the margin, the firm beside it at 3.4 in, a blank single line, "/s/" and the signer's lines under the firm. At each `<!-- SIGNATURE -->` marker, kept on one page with the paragraph before it (typst: one unbreakable block; docx: keep-with-next and keep-lines). `<!-- PAGEBREAK -->` starts the certificates on a new page (docx: page break before, no space above the heading that opens the page, as typst drops it there).
- **Page**: letter, top margin 1.5 in (DUCivR 10-1(1)), 1 in on the other sides; the page number centered at the foot of every page in a single-pitch line whose box ends 0.5 in above the page edge.
- **Reading**: the docx filter reads the sample chunk by chunk (the text between blank lines), as typst does, and the frontmatter as written (`$FORMBOOK_META`). Break rules both engines share: no break inside ")(" or between a sign and its number ("(¶¶ 39–40,": typst boxes `[§¶]+ \S+`, the docx binds it with a no-break space and word joiners), a break after a slash before a letter ("CM/ECF").
- **One docx difference, in the margin**: the docx right margin is one twip wider (1441 twips). LibreOffice places a line in whole twips and fitted "dollars" on p. 11, which overruns typst's 468 pt measure by 0.04 pt; with the measure 0.05 pt shorter every line breaks as in typst. The margin stays inside the 1 in minimum. Another text could still have a line that typst fits or overruns by a few hundredths of a point (docs/EVAL-LOOP.md, "What the first adoption found").
- **Limits**: footnotes are not supported: both engines read the body chunk by chunk, so a footnote's definition would be a chunk of its own (the sample has none; gap 2). The numbers in the docx are typed text, not Word list numbering. No table of contents or authorities.
