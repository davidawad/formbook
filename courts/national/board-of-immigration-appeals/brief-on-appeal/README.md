# BIA brief on appeal (`brief-on-appeal`)

A respondent's brief on appeal to the Board. The template was built from the rules. One filed brief on appeal now serves as the exemplar, and the sample is a transcription of it.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: `exemplars/FILED-EXAMPLE-AB-redacted-brief-on-appeal.pdf` (*Matter of A-B-*, respondent's brief filed 2019-12-16; public copy, docket redacted). Source and rejected candidates in [`exemplars/SOURCE.md`](exemplars/SOURCE.md). |
| Render | ok: `samples/OUTPUT-AB-2019-12-16.pdf`, 12 pages. `sh tools/render.sh` exited 0 with no typst warnings. |
| Overlay | ok: `samples/OVERLAY-AB-2019-12-16.pdf` and `.txt`. `sh tools/overlay.sh` wrote both. Pairs: our pp. 1–11 with filed pp. 1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 51. Our p. 12 (certificate) has no filed counterpart. |
| Pages reviewed | 12 of 12. First pass at 50 dpi, one page at a time. After the numbering change, re-checked as 60 dpi montages of all 12 pages. |

## What the overlay found, and what changed

1. **Body numbering.** The filed brief numbers the Introduction as page 1, with the cover and table of contents unnumbered. The template numbered the Introduction 3. Fixed in `typst/bia-brief-on-appeal.typ`: `numbering: n => str(n - 2)`, and the footer shows only from the Introduction. The table of contents now lists body page numbers.
2. **Certificate of service.** The filed copy has no certificate page (its last page is blank). The template still draws one from the sample's `service` fields, so our page 12 has no counterpart. This is kept: a rule-based certificate is required, and the filed copy may have lost its certificate in the public redaction. The sample's service fields are placeholders.
3. **Cover counsel block.** The filed cover lists all counsel at the top. The template puts the filer block at the top (one name and address, the Manual's rule) and the counsel block at the bottom. Kept: it follows the Manual, and the filed layout is one exemplar's convention.
4. **Caption.** The filed caption uses a `)` column. The template uses plain "In the Matter of" text. Kept: a convention, not a rule.
5. **Section breaks.** Our body breaks at different points from the filed one. This comes from the font (below), not from the template.

## Governing rules

Verified 2026-10-14. Sources:

- **8 C.F.R. § 1003.3(c)(1)**: brief timing, reply briefs, and proof of service on the opposing party. Text from Cornell LII, `https://www.law.cornell.edu/cfr/text/8/1003.3`. The eCFR URL redirected to an unrelated host and was not followed.
- **BIA Practice Manual** (EOIR), Jan. 2025 edition, text copy at `https://resources.humanrightsfirst.org/wp-content/uploads/2025/01/BIA-practice-manual-jan.-2025.pdf`. Chapter 4 is marked "last updated August 12, 2024" and chapter 3 "June 1, 2023". The live DOJ page `https://www.justice.gov/eoir/reference-materials/bia` returned HTTP 403 from this box, so the copy was not checked against the live site. Appendix E (cover-page examples) and Appendix F (certificate of service) were not extracted and are not checked.

| Rule | Where | Template parameter / check |
|---|---|---|
| Body limit 50 pages; headings, footnotes and quotations count; cover, TOC, table of citations, signature block, certificate of service and addendum do not count | Manual ch. 4.6(b) | `page-limit = 50`; the template does not count words. The sample body is pages 1–10 of the body numbering. |
| Paginated | Manual ch. 4.6(b) | footer, page number centred; cover and TOC unnumbered; body numbering starts at the Introduction (matches the filed exemplar) |
| A-number on the cover and at bottom right of each later page | Manual ch. 4.6(c)(2) | footer right, `A#<a_number>`. The filed public copy shows no A-number on its body pages (redacted), so this is not checked against the exemplar. |
| Cover page with caption: filer name and address, title, respondent name as on charging document, A-number, type of proceeding; special circumstances (e.g. DETAINED) prominent, top right | Manual ch. 3.3(c)(6), App. E; ch. 4.6(c)(3) | cover block, `custody` box top right |
| Fonts: "Times New Roman 12 point" preferred; proportionally spaced and monospaced both acceptable; double-spaced text preferred; single-spaced footnotes preferred | Manual ch. 3.3(c)(7) | `body-size = 12pt`; `body-leading = 1.74em` (double-spaced); see Known gaps for the font |
| Paper: standard 8½ × 11 | Manual ch. 3.3(c)(4) | `paper: "us-letter"` |
| Contents: facts and procedural history, issues, standard of review, summary of argument, argument, conclusion | Manual ch. 4.6(c)(4) | sample uses these headings, in the filed order |
| Party names: "respondent" for the noncitizen in removal proceedings | Manual ch. 4.6(c)(5) | sample uses "Respondent" |
| Signature by the preparer; EOIR ID shown when a registered attorney or accredited representative prepares it | Manual ch. 4.6(c)(1); ch. 3.3(b) | signature block after the conclusion. The filed brief has no EOIR ID line; the sample has none. |
| Proof of service: name/title of party served, precise address, date, means of service, document served, name of the person serving; signed by the person serving; ECAS wording when served through ECAS | Manual ch. 3.2(d); 8 C.F.R. § 1003.3(c)(1) | certificate of service on its own page; ECAS sentence used when `service.means` is `ecas` |

## Known gaps

1. **One exemplar.** The task asked for one. A second filer's brief would help tier-2 judgment. Not searched beyond the queries in `exemplars/SOURCE.md`.
2. **Transcription is partial.** The sample transcribes the Introduction through the Request for Oral Argument (filed pp. 1–9) and the Conclusion and signature (filed pp. 48–49). The Argument (filed pp. 10–47) is marked as omitted. The overlay pairs the transcribed pages only.
3. **Font.** The Manual prefers Times New Roman 12 point. Only EB Garamond is vendored (`fonts/eb-garamond`), and `fonts/` is shared, so a Times-metric face was not added. EB Garamond at 12 pt reads smaller than Times 12 pt, so line breaks and page breaks differ from the filed copy. Adding a Times-metric font is a shared-folder change for David.
4. **Margins.** The Manual sets no margin figure. 1-inch margins are a convention, not a rule.
5. **Table of citations.** Not generated. Only the table of contents is built (from the headings). A brief with citations needs a table of authorities; the Manual excludes it from the page count.
6. **Two-hole punch.** Manual ch. 3.3(c)(8) asks for paper briefs pre-punched at the top, centred, 2¾ in apart. The template does not add punch holes. This matters only for paper filing.
7. **Page limit.** The template does not count words. The 50-page limit has to be checked by the filer, against the rendered body pages.
8. **Appendix E.** Cover-page examples were not read. The cover follows ch. 3.3(c)(6) and the one filed exemplar.
9. **Automatic checks.** There is no `checks.yaml` or gate for this folder. Checks were done by reading the render and the overlay.
10. **Certificate of service** is not in the exemplar (see What the overlay found, item 2).

## Files

- `typst/main.typ`: entry point. Reads `--input sample=...`, splits the frontmatter, calls the template.
- `typst/bia-brief-on-appeal.typ`: the template, `bia-brief(meta, md)`. Parameters at the top, each with its rule.
- `exemplars/FILED-EXAMPLE-AB-redacted-brief-on-appeal.pdf`: the filed brief (public copy). `exemplars/SOURCE.md` has its URL, filer, date and checksum.
- `samples/INPUT-AB-2019-12-16.md`: transcription of the exemplar (frontmatter plus body).
- `samples/OUTPUT-AB-2019-12-16.pdf`: render. Command: `sh tools/render.sh courts/national/board-of-immigration-appeals/brief-on-appeal samples/INPUT-AB-2019-12-16.md`.
- `samples/OVERLAY-AB-2019-12-16.pdf` and `.txt`: overlay and page map. Command: `sh tools/overlay.sh courts/national/board-of-immigration-appeals/brief-on-appeal AB-2019-12-16`.

[Board of Immigration Appeals](../README.md)
