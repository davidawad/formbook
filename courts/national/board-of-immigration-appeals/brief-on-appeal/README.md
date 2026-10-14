# BIA brief on appeal (`brief-on-appeal`)

**BLOCKED: no exemplar.** No public filed brief on appeal was found. The searches and rejected candidates are in [`exemplars/SOURCE.md`](exemplars/SOURCE.md). The template below was built from the rules, and the sample is synthetic.

## Status

| Item | Result |
|---|---|
| Exemplar | no (`exemplars/` has `SOURCE.md` only) |
| Render | ok: `samples/OUTPUT-synthetic-rules.pdf`, 8 pages, `typst compile` with no warnings, vendored EB Garamond only |
| Overlay | fail: not run. `tools/overlay.sh` needs a filed exemplar PDF and reads `samples/OUTPUT-<id>.pdf`, not `<id>.pdf`. |
| Pages reviewed | 8 of 8, rendered at `pdftoppm -r 60` and looked at each |

## Governing rules

Verified 2026-10-14. Sources:

- **8 C.F.R. § 1003.3(c)(1)**: brief timing, reply briefs, and proof of service on the opposing party. Text from Cornell LII, `https://www.law.cornell.edu/cfr/text/8/1003.3`. The eCFR URL redirected to an unrelated host and was not followed.
- **BIA Practice Manual** (EOIR), Jan. 2025 edition, text copy at `https://resources.humanrightsfirst.org/wp-content/uploads/2025/01/BIA-practice-manual-jan.-2025.pdf`. Chapter 4 is marked "last updated August 12, 2024" and chapter 3 "June 1, 2023". The live DOJ page `https://www.justice.gov/eoir/reference-materials/bia` returned HTTP 403 from this box, so the copy was not checked against the live site. Appendix E (cover-page examples) and Appendix F (certificate of service) were not extracted and are not checked.

| Rule | Where | Template parameter / check |
|---|---|---|
| Body limit 50 pages; headings, footnotes and quotations count; cover, TOC, table of citations, signature block, certificate of service and addendum do not count | Manual ch. 4.6(b) | `page-limit = 50`; the template does not count words. Sample body is pages 3–7 of the render (5 pages). |
| Paginated | Manual ch. 4.6(b) | footer, page number centred, cover unnumbered |
| A-number on the cover and at bottom right of each later page | Manual ch. 4.6(c)(2) | footer right, `A#<a_number>` |
| Cover page with caption: filer name and address, title, respondent name as on charging document, A-number, type of proceeding; special circumstances (e.g. DETAINED) prominent, top right | Manual ch. 3.3(c)(6), App. E; ch. 4.6(c)(3) | cover block, `custody` box top right |
| Fonts: "Times New Roman 12 point" preferred; proportionally spaced and monospaced both acceptable; double-spaced text preferred; single-spaced footnotes preferred | Manual ch. 3.3(c)(7) | `body-size = 12pt`; `body-leading = 1.74em` (measured body line pitch 28.7pt, about double); see Known gaps for the font |
| Paper: standard 8½ × 11 | Manual ch. 3.3(c)(4) | `paper: "us-letter"` |
| Contents: facts and procedural history, issues, standard of review, summary of argument, argument, conclusion | Manual ch. 4.6(c)(4) | sample uses these headings, in this order |
| Party names: "respondent" for the noncitizen in removal proceedings | Manual ch. 4.6(c)(5) | sample uses "Respondent" |
| Signature by the preparer; EOIR ID shown when a registered attorney or accredited representative prepares it | Manual ch. 4.6(c)(1); ch. 3.3(b) | signature block after the conclusion |
| Proof of service: name/title of party served, precise address, date, means of service, document served, name of the person serving; signed by the person serving; ECAS wording when served through ECAS | Manual ch. 3.2(d); 8 C.F.R. § 1003.3(c)(1) | certificate of service on its own page; ECAS sentence used when `service.means` is `ecas` |

## What the overlay shows

Nothing. The overlay needs a filed exemplar, and none was found. When one is found, run `sh tools/overlay.sh <this-dir> <id>` after renaming the render to `samples/OUTPUT-<id>.pdf`.

## Known gaps

1. **No exemplar.** The sample is synthetic. Layout choices other than those listed in the rules table are conventions, not measured from a filing. Blocked until a filed brief on appeal is found.
2. **Font.** The Manual prefers Times New Roman 12 point. Only EB Garamond is vendored (`fonts/eb-garamond`), and `fonts/` is shared, so a Times-metric face was not added. EB Garamond at 12 pt reads smaller than Times 12 pt. Adding a Times-metric font is a shared-folder change for David.
3. **Margins.** The Manual sets no margin figure. 1-inch margins are a convention, not a rule.
4. **Table of citations.** Not generated. Only the table of contents is built (from the headings). A brief with citations needs a table of authorities; the Manual excludes it from the page count.
5. **Two-hole punch.** Manual ch. 3.3(c)(8) asks for paper briefs pre-punched at the top, centred, 2¾ in apart. The template does not add punch holes. This matters only for paper filing.
6. **Page limit.** The template does not count words. The 50-page limit has to be checked by the filer, against the rendered body pages.
7. **Appendix E.** Cover-page examples were not read. The cover follows ch. 3.3(c)(6) only.
8. **Automatic checks.** There is no `checks.yaml` or `tools/check.sh` run for this folder. The rules above are checked by reading the render, not by a gate.
9. **Citations in the sample.** The sample uses placeholders (`[CITATION PLACEHOLDER]`, `[VOL.]`, `[PAGE]`). The one regulation it cites, 8 C.F.R. § 1003.1(d)(3), is marked "confirm current text" because only the body of § 1003.3(c) was read.

## Searches tried

1. CourtListener search (`https://www.courtlistener.com/?q=...&type=r`): HTTP 403 from this box.
2. Web searches (standard and extended): BIA practice manual formatting and page limit; "RESPONDENT'S BRIEF ON APPEAL" with BIA and exhibits; "DHS BRIEF ON APPEAL" with EOIR, A-number and certificate of service; "brief on appeal" with "before the Board of Immigration Appeals" and pdf. None returned a filed BIA brief on appeal in a public record.
3. Candidates rejected (not court records; not confirmed as filed): Cliniclegal "Sample BIA Appeal Brief" (bond appeal, names redacted) and ILRC `c_brief_on_appeal.pdf` (sample, names blanked). Details in [`exemplars/SOURCE.md`](exemplars/SOURCE.md).

## Files

- `typst/main.typ`: entry point. Reads `--input sample=...`, splits the frontmatter, calls the template.
- `typst/bia-brief-on-appeal.typ`: the template, `bia-brief(meta, md)`. Parameters at the top, each with its rule.
- `samples/INPUT-synthetic-rules.md`: the synthetic sample (frontmatter plus body, placeholders only).
- `samples/OUTPUT-synthetic-rules.pdf`: render. Command: `sh tools/render.sh courts/national/board-of-immigration-appeals/brief-on-appeal samples/INPUT-synthetic-rules.md courts/national/board-of-immigration-appeals/brief-on-appeal/samples/OUTPUT-synthetic-rules.pdf`.

[Board of Immigration Appeals](../README.md)
