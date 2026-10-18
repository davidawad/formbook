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

The template builds the cover and renders markdown with vendored cmarker. Body text is 14-point, double-spaced (32.2 pt baseline pitch in EB Garamond). Headings, identity blocks (bold labels), signature and address blocks (hard line breaks), and contents or index entries (dot leaders) are single-spaced; short single-spaced blocks do not break across pages. Footnotes are written `[^1]` with a `[^1]: text` definition, rendered at 12 point.

The front matter (identity, contents, index) is numbered in lower-case roman. The body starts at page 1 with the heading `# Statement Regarding Oral Argument`, which the template requires. The template does not create a table of contents or authorities.

Build from the repository root:

```sh
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/opening-brief becerra-merits
```

## Exemplar

`usage/FILED-EXAMPLE-opening-brief.pdf` is the State's brief on the merits in *State v. Becerra*, PD-0280-22 (54 pages), retrieved October 14, 2026 (see `usage/SOURCE.md`). Its body is double-spaced, consistent with the rule.

This is one filer. Tier 2 calls for two or three filings from different filers, and none was found in this pass.

## Sample and overlay

`usage/INPUT-opening-brief.md` is a transcription of an excerpt of the exemplar: the cover, identity of parties and counsel, table of contents, index of authorities, the statements of oral argument, the case, and procedural history, the statement of facts through Maria Nava's testimony, the prayer, and both certificates. The argument, summary, and response are omitted. The render is 11 pages (cover unnumbered, front matter i–iii, body 1–7).

The red/blue overlay is `usage/OVERLAY-becerra-merits.pdf`; its page map is `usage/OVERLAY-becerra-merits.txt`.

## Page review

Every page of `usage/OUTPUT-opening-brief.typst.pdf` (11 pages) was rendered at 100 dpi and viewed on October 14, 2026, after the final render. Footer numbers are shown; the cover has none.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| cover | exemplar p.1 | Case number, caption, title, counsel block, and date fit on one page. | PASS |
| i | exemplar p.1–2 (identity) | Party and counsel blocks single-spaced and flush; a bold-label paragraph was indented. | FIXED |
| ii | exemplar p.2–3 (contents, index) | Contents and first index entries single-spaced with dot leaders. | PASS |
| iii | exemplar p.4–5 (index end) | Index continuation, constitutions, statutes, and rules. | PASS |
| 1 | exemplar p.1 (body) | Oral argument, case, and procedural history. Footnote 1 printed as literal `[^1]` text and its definition was dropped; now a real 12-point footnote. | FIXED |
| 2 | exemplar p.2 | Procedural history and facts. | PASS |
| 3 | exemplar p.3–4 | Facts. | PASS |
| 4 | exemplar p.4–5 | Facts. | PASS |
| 5 | exemplar p.5–6 | Facts; footnote 2 now a real footnote. | FIXED |
| 6 | exemplar p.6–7 | Facts; the prayer heading and "Respectfully submitted" were split from their signature block. | FIXED |
| 7 | exemplar p.45–46 | Prayer signature block (kept together), certificate of service, certificate of compliance. | FIXED |

## Known gaps

- One filed exemplar, not two or three from different filers.
- Tables of contents and authorities are author-supplied markdown. Their page numbers are copied from the exemplar and do not match this excerpt.
- The certificate of compliance's word count (11,214) is the exemplar's figure. It is not a count of this excerpt and does not verify any word limit. The template does not calculate word limits or certificate counts.
- The transcription copies a citation year from the filed brief: *Williams v. Florida*, 399 U.S. 78 (1997), as printed. That is the filed brief's error, not verified here.
- The template does not verify service details, create bookmarks, or check every Rule 38.1 requirement. Confirm case-specific requirements and the applicable length limit before use.
- The sample is an excerpt, not the complete brief. No engine other than typst was run, and no automated rule-check suite (`checks.yaml`) exists for this folder.

## Engines

docx (`docx/render.sh`, `docx/reference.docx` built by `docx/build-reference.sh`, filter `docx/brief.lua`): `usage/OUTPUT-opening-brief.docx` and `OUTPUT-opening-brief.docx.pdf` were built. The LibreOffice conversion succeeded and the zip and XML checks passed. The template matches the typst form in its settings: EB Garamond 14 pt; exact 32.2 pt double spacing; 0.5 in first-line indent; 1 in margins on letter; 12 pt footnotes; single-spaced headings, cover, identity, contents and index; cover unnumbered; front matter in lower-case roman, body from page 1, as separate Word sections. Dot leaders and contents and index page numbers are literal text, as in typst.

Page review (all 12 docx pages against the 11 typst pages, side by side): the front matter, body and certificates are in the same order. Differences: the body runs to 8 pages against typst's 7, because the signature block and the certificate of compliance spill onto body page 8; the body headings and the certificate headings are set smaller than typst's; the front matter's identity and contents layout differs from typst's. The font names in the docx PDF were not checked. Word was not available; the file was checked with LibreOffice only.

BLOCKED: docx page count: body 8 pages vs typst 7 (the certificate of compliance spills onto body page 8).
BLOCKED: docx headings: body and certificate headings are smaller than typst's (tier 2, not fixed).

[Formbook index](../../../../../../README.md)
