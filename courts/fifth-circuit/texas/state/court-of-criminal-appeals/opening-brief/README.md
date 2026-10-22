# Opening brief (initial brief on the merits)

## Governing rules

Rules checked October 14, 2026. The official [Texas Rules of Appellate Procedure](https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf) returned HTTP 403 to the fetcher, so the Rule 9.4 typeface and spacing wording below was confirmed from secondary summaries of the rule. Check it against the official text before relying on this template.

- **TRAP 9.4(b)–(e), (g), (i), (j) (mandated):** 8.5 by 11 inch page; one-inch margins; double-spaced text, with stated exceptions (footnotes, block quotations, short lists, and issues or points of error may be single-spaced); conventional computer type no smaller than 14 point and footnotes no smaller than 12 point; cover contents; applicable length limit and word-count certificate; text-searchable unlocked PDF for e-filing. Rule 70.3 makes Rule 9 applicable to a brief on the merits.
- **TRAP 9.5 (mandated):** serve each party and include proof of service.
- **TRAP 38.1 (mandated through TRAP 70.3):** brief contents and their order, including identity of parties and counsel, contents, authorities, oral-argument statement, case and procedural history, issues, facts, argument, conclusion, and signature. Rule 70.3 dispenses with the appendix required by Rule 38.1(k).
- **TRAP 70.1 (mandated):** after discretionary review is granted, the petitioner (or the losing party where no petition was filed) files the initial brief within 30 days.
- **TRAP 70.3 (mandated):** merits briefs comply with Rules 9 and 38, except that the appendix is not required.

## Markdown contract and template

The markdown file begins with YAML frontmatter: `case_number`, `style_petitioner`, `style_respondent`, `filing_party`, `brief_title`, `appeal_from`, `lead_counsel`, `counsel_lines`, and optional `filed_date`. The body supplies the document-specific sections and text, including contents, authorities, signature, certificate of compliance, and proof of service.

The template builds the cover and renders markdown with vendored cmarker, on the shared cross-engine layout model (`lib/typst/xengine.typ`): Times New Roman (docs/FONTS.md rule 6), no kerning, ligatures or hyphenation, first-fit ragged-right lines, every line a box of its pitch. Body text is 14-point, double-spaced in 32.2 pt lines (Word's double line at 14 pt), every paragraph indented half an inch. Single lines are 16.1 pt: the cover (title 16 pt bold in 18.4 pt), headings (level 1 centered bold capitals a body line below the text and a single line above the next; level 2 bold; level 3 italic; kept with what follows), identity blocks (bold labels), signature and certificate blocks (hard line breaks; a blank single line around each, kept whole, and in the body a run of them kept together), and contents or index entries. A contents or index entry is typed `title ........ page`: the template sets its own dot leader and keeps the page reference in a column of its own (its width in Times New Roman plus 3.5 pt, the same table in both engines), the title wrapping before it with a half-inch hang. Footnotes are written `[^1]` with a `[^1]: text` definition, rendered at 12 point in 13.8 pt lines, 7 pt apart. The page number is centered in a 16.1 pt footer line.

The front matter (identity, contents, index; each opens a page) is numbered in lower-case roman. The body starts at page 1 with the heading `# Statement Regarding Oral Argument`, which the template requires. The template does not create a table of contents or authorities.

Build from the repository root:

```sh
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/opening-brief usage/INPUT-opening-brief.md
```

## Exemplar

`usage/FILED-EXAMPLE-opening-brief.pdf` is the State's brief on the merits in *State v. Becerra*, PD-0280-22 (54 pages), retrieved October 14, 2026 (see `usage/SOURCE.md`). Its body is double-spaced, consistent with the rule.

This is one filer. Tier 2 calls for two or three filings from different filers, and none was found in this pass.

## Sample and overlay

`usage/INPUT-opening-brief.md` is a transcription of an excerpt of the exemplar: the cover, identity of parties and counsel, table of contents, index of authorities, the statements of oral argument, the case, and procedural history, the statement of facts through Maria Nava's testimony, the prayer, and both certificates. The argument, summary, and response are omitted. The render is 13 pages in both engines (cover unnumbered, front matter i–iv, body 1–8).

`just overlay <this folder>` writes the red/blue overlay to the gitignored `.overlay/` tree (not committed).

## Page review

Every page of `usage/OUTPUT-opening-brief.typst.pdf` and `usage/OUTPUT-opening-brief.docx.pdf` (13 pages each) was rendered at 60 dpi and viewed side by side on October 22, 2026, after the final render (the cross-engine port, fb-595.68.36). Footer numbers are shown; the cover has none.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| cover | exemplar PDF p.1 | Case number, court, parties, the court below, title, filing party, counsel block and date on one page, centered; the same in both engines. | PASS |
| i | exemplar PDF p.2 (identity) | Party and counsel blocks single-spaced, flush, a blank line apart. | PASS |
| ii | exemplar PDF p.3–4 (contents) | Contents on a page of its own (was run on after the identity blocks), rows a blank line apart, leader to the page column. | FIXED |
| iii | exemplar PDF p.5–6 (index) | Index on a page of its own; wrapped entries hang half an inch, page lists in their own column. | FIXED |
| iv | exemplar PDF p.6–7 (index end) | Last cases, constitutions, statutes and rules. | PASS |
| 1 | exemplar PDF p.8 (body p.1) | Oral argument and the case; every paragraph indented (the first after a heading was flush); footnote 1 at 12 pt. | FIXED |
| 2 | exemplar PDF p.9 (body p.2) | Procedural history, facts heading and subheading. | PASS |
| 3–7 | exemplar PDF p.10–14 (body p.3–7) | Facts; footnote 2 on p.6; prayer heading, paragraph and signature blocks on p.7 kept together. | PASS |
| 8 | exemplar body p.45–46 | Certificate of service and certificate of compliance with their signatures. | PASS |

## Known gaps

- One filed exemplar, not two or three from different filers.
- Tables of contents and authorities are author-supplied markdown. Their page numbers are copied from the exemplar and do not match this excerpt.
- The certificate of compliance's word count (11,214) is the exemplar's figure. It is not a count of this excerpt and does not verify any word limit. The template does not calculate word limits or certificate counts.
- The transcription copies a citation year from the filed brief: *Williams v. Florida*, 399 U.S. 78 (1997), as printed. That is the filed brief's error, not verified here.
- The template does not verify service details, create bookmarks, or check every Rule 38.1 requirement. Confirm case-specific requirements and the applicable length limit before use.
- The sample is an excerpt, not the complete brief. No automated rule-check suite (`checks.yaml`) exists for this folder, so there is no selftest; no latex template exists.

## Engines

typst (`typst/texcrimapp-opening-brief.typ`, the reference) and docx. The docx template is declarative (`fb render`, docs/DOCX.md): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`, with the line pitches above in twips: 644 body, 322 single, 276 footnotes; Head 1/2/3, Single Block and Body Text Note styles) and the filter `docx/texcrimapp-opening-brief.lua` on `docx.xengine` (the cover, the contents and index rows with the page column as right indent and a dot-leader tab, the three sections and their footers, the blocks in those styles). The former `docx/render.sh`, `build-reference.sh`, `reference.docx` and `brief.lua` (EB Garamond, which failed DEF-FONT-002) are gone. The docx breaks every line and page where typst does: `fb check --engine docx` passes XENG-001..003 (248/248 lines, 13 pages), and `eval.yaml` sets `params.cross_engine: gate`. Word was not available; the file was checked with LibreOffice only, which may paginate slightly differently from Word.

[Formbook index](../../../../../../README.md)
