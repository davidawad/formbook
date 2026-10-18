# bap1 — Answering brief (Brief for Appellee)

- Court: United States Bankruptcy Appellate Panel for the First Circuit (`bap1`), folder `courts/first-circuit/bankruptcy-appellate-panel/answering-brief/`
- Doc type: `answering`
- Status (2026-10-16):
  - **Exemplar found.** Brief of Appellee William K. Harrington, United States Trustee, BAP No. MW 23-003, filed June 26, 2023 by the U.S. Trustee Program (Frederick Gaston Hall signing; Ramona D. Elliott first on the cover) (`usage/SAMPLE-bap1-answering-brief-blumsackmw2303.pdf`, born-digital). Found on CourtListener under court id `ca1` (docket 23-3); details in `usage/SOURCE.md`. The earlier status was "BLOCKED: no exemplar".
  - Transcribed (abridged) to `usage/INPUT-bap1-answering-brief-blumsack.md`, rendered (19 pages) and overlaid; every page reviewed (Gate 2 below, no OPEN rows).
  - Template fixed from the overlay: body double spacing (tier 1), the interested-parties statement (omitted for governmental parties, as here) and the Official-Form layout of the L.R. 8014-1 statements (tier 1), cover debtor line, party and one-page cover (tier 1), heading and TOA conventions (tier 2). See "Template changes from the overlay".
  - **Tier 2 cannot be finished**: only one filer per doc type exists publicly; tier 2 was judged against two filers in the same case (this brief and the appellant's opening brief).
  - Typst only: `docx/` and `latex/` were not touched in this pass (the docx engine still has the pre-fix behavior).

Summary line for the PM: `exemplar=yes render=ok overlay=ok pages_reviewed=19`

## Rules (verified 2026-10-14)

| ID | Requirement | Source | Verified |
|---|---|---|---|
| BAP-FORM-001 | Contents and order of the answering brief: FRBP 8014(b) | FRBP 8014 via [LII](https://www.law.cornell.edu/rules/frbp/rule_8014) | 2026-10-14 |
| BAP-FORM-002 | One-inch margins on all sides; letter paper | FRBP 8015(a)(4) via [LII](https://www.law.cornell.edu/rules/frbp/rule_8015); BAP guide §VI | 2026-10-14 |
| BAP-FORM-003 | Proportionally spaced serif font, 14-point or larger; sans-serif only in headings and captions | FRBP 8015(a)(5) via LII | 2026-10-14 |
| BAP-FORM-004 | Double-spaced text; quotations and footnotes may be single-spaced | FRBP 8015(a)(4) via LII | 2026-10-14 |
| BAP-LEN-001 | Type-volume limit: 13,000 words (FRBP 8015(a)(7)(A)) | FRBP 8015(a)(7) via LII | 2026-10-14 |
| BAP-CERT-001 | Certificate of compliance with word count, excluding exempted parts | FRBP 8015(g), (h) via LII (Form 417C) | 2026-10-14 |
| BAP-LR-001 | Statement regarding related cases, attached to the last page (Official Form 1) | 1st Cir. BAP L.R. 8014-1(a)(2) and the [BAP local rules PDF](https://www.bap1.uscourts.gov/sites/bap1/files/BAP%20Local%20Rules.pdf) | 2026-10-14 |
| BAP-LR-002 | Statement regarding interested parties (Official Form 2) | 1st Cir. BAP L.R. 8014-1(a)(3) | 2026-10-14 |
| BAP-LR-003 | Statement regarding oral argument: one-half page, after the tables, before the first page | 1st Cir. BAP L.R. 8019-1(a) | 2026-10-14 |
| BAP-LR-004 | Record cites to the appendix (App. at __) | 1st Cir. BAP L.R. 8014-1(a)(1) | 2026-10-14 |
| BAP-COVER-001 | Cover: case number centered at the top; court name; title of the case (FRBP 8003(d)(2), with the debtor); nature of the proceeding and court below; brief title identifying the party; counsel name, address, telephone and email | FRBP 8015(a)(2) via [LII](https://www.law.cornell.edu/rules/frbp/rule_8015) | 2026-10-16 |
| BAP-LR-005 | The related-cases and interested-parties statements are "substantially in the form of" Official Forms 1 and 2 (caption, statement with checkboxes, signature of attorney with address and telephone); interested parties not required of governmental parties | 1st Cir. BAP L.R. 8014-1(a)(2), (3) and Official Forms 1-2, [BAP local rules PDF](https://www.bap1.uscourts.gov/sites/bap1/files/BAP%20Local%20Rules.pdf) pp. 11, 17-18 | 2026-10-16 |

## Conflict to resolve (David)

The [BAP guide](https://www.bap1.uscourts.gov/sites/bap1/files/BAP_Guide.pdf) §VI says text may be 11-point, double-spaced, with a 30-page limit (15 for reply), and that a 13,000-word principal brief is acceptable. FRBP 8015(a)(5) as fetched says 14-point and 13,000 words (half for reply). The template follows the federal rule, which the local rules cannot override (L.R. 8015-1(a) only lets the panel accept nonconforming documents). Which governs the bap1 filing is an open question for David; the guide's 11-point figure should not be used until it is resolved. Evidence from the two filed exemplars (2026-10-16): the appellant's brief is set in Courier New, a monospaced face, at about 12 pt (allowed by FRBP 8015(a)(5)(B) at no more than 10 1/2 characters per inch); the U.S. Trustee's brief is set in Garamond 14 pt. Neither uses an 11-point proportional face. The quick reference also lists 30 and 15 pages, which the template does not enforce (the word limit does).

## Template

- `typst/bap1-answering.typ` (the template, `doc-kind = "answering"`) and `typst/main.typ` (entry). Same structure as the other two doc types; only the constant and the cover title differ.
- Cover (BAP-COVER-001): BAP number at the top, the panel name, bankruptcy case number, optional debtor line (`debtor`), caption, proceeding, brief title with the optional party name (`party`), counsel block (two columns when there are several counsel groups). No page number on the cover.
- Front matter: optional corporate disclosure (FRBP 8012, only when `disclosure:` is given), table of contents (outline), table of authorities (built from `toa:` links; "passim" at 7+ pages), oral-argument statement.
- Body: markdown rendered by cmarker. Body text double spaced (ascender-to-descender line box, about 31.4 pt pitch at 14 pt). Headings at body size, single spaced: level 1 centered bold capitals; level 2 `I.` left, bold, numbered, hanging indent; level 3 `A.`, level 4 `1.`. The template refuses to build if a required section heading is missing (BAP-FORM-001; each section accepts several titles, case-insensitive) or the word count exceeds the limit (BAP-LEN-001).
- Back matter: signature block, certificate of compliance, then the statements regarding related cases and interested parties (BAP-LR-001, -002, -005), each repeating the Official Form caption with checkboxes and the attorney's signature block; the interested-parties statement is omitted when `governmental_party: true`. The word count is computed from the rendered text (headings included, footnotes not).
- Fonts: only the vendored EB Garamond (`fonts/eb-garamond/`); `render.sh` uses `--ignore-system-fonts`, and any typst warning fails the build.

## Sample and overlay (before 2026-10-16)

- `usage/INPUT-bap1-answering-brief-generic.md`: fictional, rule-structured, not a transcription of any filing. Frontmatter is the schema.
- `usage/OUTPUT-bap1-answering-brief-generic.typst.pdf`: rendered with `sh tools/render.sh courts/first-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-bap1-answering-brief-generic.md`. Renders clean (no typst warnings).
- Overlay: `sh tools/overlay.sh courts/first-circuit/bankruptcy-appellate-panel/answering-brief generic-answering-brief` **fails**: "no exemplar pdf in usage/". There is nothing to overlay against, so no OVERLAY files exist.

## Run 2026-10-15 (bap1 exemplar search)

- Exemplar: none (see `usage/SOURCE.md`). CourtListener returns 0 bap1 RECAP documents and 0 bap1 dockets; the bap1 filter is throttled (429) on some queries. The status stays BLOCKED.
- Render: `sh tools/render.sh` on `usage/INPUT-bap1-answering-brief-generic.md` exits 0 (8 pages). Overlay: `sh tools/overlay.sh` exits 1, "no exemplar pdf".
- Pages reviewed this run: 0. The sample was rendered to check the build, not reviewed page by page; the Gate 2 notes below are from the earlier run.

## Gate 2 review of the generic sample (earlier run, before 2026-10-15)

Pages were rasterized at 60 dpi and each was checked on a contact sheet. Defects found and fixed in the same pass: cover lines running together (fixed with per-line blocks); paragraphs without first-line indent; signature and certificate blocks running together. Remaining open items:

- Signature block and "Respectfully submitted" land alone on the last page (answering brief, page 6) when the conclusion ends near the foot of page 5. The template keeps the signature block unbreakable but does not keep it with the conclusion. Accepted for now.
- The cover, TOC and TOA were checked against the rules only, not against any filed bap1 exemplar.

## Exemplar search (resolved 2026-10-16)

Found: `usage/SAMPLE-bap1-answering-brief-blumsackmw2303.pdf`, the Brief of Appellee William K. Harrington, United States Trustee, BAP No. MW 23-003, filed June 26, 2023 by the U.S. Trustee Program (Frederick Gaston Hall, Trial Attorney, signing; Ramona D. Elliott, Deputy Director/General Counsel, first on the cover). The earlier searches (kept above and in `usage/SOURCE.md`) filtered on CourtListener court id `bap1`, which holds opinions only; the BAP's dockets are filed under `ca1` (MW 23-03 is ca1 docket "23-3"). Alternate, different filer: the appellant's opening brief in the same appeal (saved in `../opening-brief/usage/`). No second appellee's brief from another filer was found. **Tier 2 is therefore judged against two filers in one case (this answering brief and the appellant's opening brief), not against 2 or 3 answering briefs; EVAL-LOOP: "A court with fewer than 2 exemplars cannot finish tier 2; say so."**

## Template changes from the overlay (2026-10-16)

Found on the real content (the Blumsack transcriptions of `../opening-brief/` and `../answering-brief/`) and fixed in the shared template; the three doc types carry the same file (`typst/bap1-opening.typ`, `bap1-answering.typ`, `bap1-reply.typ`, only `doc-kind` differs), so each change is in all three. Every typst `OUTPUT-*.pdf` of the three doc types was re-rendered and viewed after the last change.

1. **Body was not double spaced (tier 1, BAP-FORM-004, FRBP 8015(a)(4)).** `body-leading = 0.94em` was copied from the CA9 template without CA9's ascender/descender line box, so the body baseline pitch was 22.26 pt at 14 pt type (1.6 x the size). The text now sets `top-edge: "ascender", bottom-edge: "descender"` as CA9 does: measured pitch 31.43 pt (`pdftotext -bbox`, generic opening p. 5 and both Blumsack renders p. 9). For comparison the U.S. Trustee's brief (Garamond 14 pt, Word double spacing) measures 31.5 pt. Headings, block quotations, footnotes, TOC and TOA stay single spaced, as FRBP 8015(a)(4) allows.
2. **No statement regarding interested parties (tier 1, BAP-LR-002, 1st Cir. BAP L.R. 8014-1(a)(3), Official Form 2).** Added. It is omitted when `governmental_party: true` (the rule exempts governmental parties; the U.S. Trustee's brief has none). New frontmatter `interested_parties: {status: none | listed, parties: [...]}`, default `none` like `related_cases`.
3. **The related-cases statement was not in the form of Official Form 1 (tier 1, BAP-LR-001: "substantially in the form of").** Both statements now repeat the form's caption (court, BAP No., bankruptcy case number, title of the case), then the checkboxes, then the signature of the attorney with address and telephone, as on Official Forms 1 and 2 (local rules PDF pp. 17-18) and on both exemplars. They now follow the certificate of compliance, so they are "attached to the last page of [the] brief" (L.R. 8014-1(a)(2), (3)). They are set in plain single spacing so each stays on one page.
4. **Cover (tier 1, FRBP 8015(a)(2)(C), (E)).** Optional `debtor` (names, designation) prints the "In re" debtor line of the title of the case; optional `party` adds the party to the brief title ("BRIEF FOR APPELLANT, SCOTT H. BLUMSACK"). The bankruptcy case number moved above the title of the case (Official Forms 1-2 and both exemplars). With several counsel the cover ran onto a second page (U.S. Trustee transcription): several counsel groups are now set in two columns.
5. **Required-heading check too strict.** It rejected the opening filer's "Summary of Argument". Each FRBP 8014(a) requirement now lists the titles it accepts (e.g. "Jurisdictional Statement", "Statement of Appellate Jurisdiction"), compared case-insensitively.
6. **Headings (tier 2, both filers).** Level-2 headings printed no number in the body (the TOC had it) and were centered; both filers set them left, bold, with the number and a hanging indent, and the template now does. Level-1 and level-2 headings were 1.4 em and 1.2 em; both filers set headings at the body size, and the template now does.
7. **Table of authorities (tier 2, both filers).** No dot leaders; wrapped lines started flush left and a page number could wrap alone onto the next line. Entries now have dot leaders, a hanging indent, and the pages in their own column level with the entry's last line.

Not changed (rule governs, tier-2 difference ACCEPTED): the cover keeps the BAP number at the top (FRBP 8015(a)(2)(A): "the number of the case centered at the top"); both filers put the court name first. Front matter keeps arabic page numbers from the cover (the appellant numbers it that way; the U.S. Trustee uses roman numerals, one filer's style).

DOCX and LaTeX: this was a typst-only pass. `docx/` was not touched, so the docx engine still has the old behavior for items 1-7 (its body line pitch is the old 22.25 pt, which is the same tier-1 spacing defect; no interested-parties statement; old cover and statement layout). The docx text in "Engines" below predates this pass. Follow-up for the docx engine.

## Sample

- `usage/INPUT-bap1-answering-brief-blumsack.md`: a transcription of the exemplar, abridged (the header comment lists what is excerpted and omitted: cover, oral-argument statement, Statement of Appellate Jurisdiction through Statement of the Facts § A, the Summary of the Argument, the opening paragraphs of Arguments I-III, the end of III, the Conclusion, signature, related-cases statement; footnotes 1, 3, 4 and 7 kept). Text from the PDF's own text layer. Cover counsel: the left column (Executive Office for U.S. Trustees) only. `governmental_party: true`, so no interested-parties statement, as filed. Rendered to `usage/OUTPUT-bap1-answering-brief-blumsack.typst.pdf` (19 pages) with `sh tools/render.sh courts/first-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-bap1-answering-brief-blumsack.md`: exit 0, no typst warnings. The compliance certificate states the transcription's own count (2594 words); the filer's certificate states 6,836 for the whole brief.
- `usage/INPUT-bap1-answering-brief-generic.md` (fictional) is kept as it was and re-rendered with the changed template (9 pages, every page viewed).

## Overlay

`sh tools/overlay.sh courts/first-circuit/bankruptcy-appellate-panel/answering-brief blumsack-answering-brief courts/first-circuit/bankruptcy-appellate-panel/answering-brief/usage/SAMPLE-bap1-answering-brief-blumsackmw2303.pdf` exits 0 and writes `usage/OVERLAY-blumsack-answering-brief.pdf` (19 pages) and `.txt`.

Page map (ours → filed, word overlap): 1→1 (68%), 2→2 (75%), 3→3 (28%), 4→6 (38%), 5→7 (74%), 6→8 (88%), 7→9 (92%), 8→10 (89%), 9→11 (82%), 10→12 (53%), 11→13 (51%), 12→14 (47%), 13→20 (60%), 14→21 (69%), 15→27 (40%), 16→33 (37%), 17→34 (38%), 18→35 (24%), 19→36 (74%). Body pages line up closely (same type size, 14 pt, and nearly the same line pitch: ours 31.43 pt, filed about 31.5 pt). Low overlap on the TOA and certificate pages is expected (page numbers and layout differ).

## Gate 2 review (2026-10-16, every page rendered at 60 dpi and viewed with its paired exemplar page and overlay page)

Sample `blumsack-answering-brief`, `usage/OUTPUT-bap1-answering-brief-blumsack.typst.pdf` (19 pages). Tier 2 compared against two filers (this filer and the appellant's opening brief); see "Exemplar search".

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1; opening exemplar p.1 | Cover on one page: BAP No. at the top (rule), court name, Bankruptcy Case No., "In re" debtor line, caption, "On Appeal from", bold title naming the party, counsel in two columns. Ran onto a second page before (fixed with two-column counsel). Filer puts the court name first and draws rules between blocks; title wording "Brief for Appellee, ..." vs filed "Brief of Appellee ...". | FIXED (one page, debtor line, party); ACCEPTED (BAP No. first per rule; rules and "of"/"for" one filer's style) |
| 2 | exemplar p.2 | TOC: level-1, level-2 (I., II.) and level-3 (A.-C.) entries, hanging indent, leaders, page numbers matching the body. Filer also lists TOA, oral-argument statement and certificates. | ACCEPTED (TOC scope) |
| 3 | exemplar p.3 | TOA Cases and Statutes with leaders and hanging indent. Filer puts each case name on its own line with the cite under it, and has a "Page(s)" label. | ACCEPTED (one filer's style; the appellant uses one-line entries) |
| 4 | exemplar p.5-6 | TOA continued: Regulations, Rules. Filer groups statutes under title headings (11 U.S.C., 18 U.S.C.); ours lists each section. | ACCEPTED (one filer's style) |
| 5 | exemplar p.7 | Statement regarding oral argument, own page, under half a page (L.R. 8019-1(a)); matches the filer's placement. | PASS |
| 6 | exemplar p.8 | Statement of Appellate Jurisdiction (accepted title), Statement of the Issues I.; footnote 1 at the foot, single spaced. Double spacing 31.43 pt against the filer's 31.5 pt. | FIXED (spacing) |
| 7 | exemplar p.9 | Issues II-III (bold labels as transcribed, indented as body paragraphs; filer hangs them), Standard of Review. | ACCEPTED (issue-label hanging indent, one filer's style) |
| 8 | exemplar p.10 | Statement of the Case; level-2 "I. Statutory Framework" and level-3 "A. Chapter 13 cases" bold left at body size (filer: same hierarchy, plain level-3 text). | FIXED (heading size, level-2 number) |
| 9 | exemplar p.11 | Chapter 13 text continued; B. heading; bullet list (single bullet item double spaced). | PASS |
| 10 | exemplar p.12 | Bullet continued, C. heading, the role of the U.S. Trustee. Filer's bullets are single spaced and indented both sides (quotations). | ACCEPTED (list spacing; bullets carry quotations, the template sets list items as text) |
| 11 | exemplar p.13 | II. Statement of the Facts, A. heading (two lines, hanging), facts. | PASS |
| 12 | exemplar p.14 | Facts continued; Summary of the Argument heading. | PASS |
| 13 | exemplar p.20 | Summary paragraphs II. and III. | PASS |
| 14 | exemplar p.21 | Argument; four-line level-2 heading I., single spaced, hanging; footnotes 2 and 3 (filed 3 and 4). | PASS (footnote numbers follow the abridgement) |
| 15 | exemplar p.27 | End of I; II and III headings; first paragraphs. | PASS |
| 16 | exemplar p.30, 33 | End of III, Conclusion; footnote 4 (filed 7). | PASS |
| 17 | exemplar p.34 | Signature block alone on the page, as in the filing (its p.34 is the signature page). Lines italic in ours (template style). | ACCEPTED |
| 18 | exemplar p.35 | Certificate of compliance, own page; matches the filer's placement. | PASS |
| 19 | exemplar p.36 | Statement regarding related cases in the form of Official Form 1: caption repeated, title and rule cite, checkboxes (the filer prints only the selected statement), signature block. No interested-parties statement (governmental party), as filed. | FIXED (form caption and signature); ACCEPTED (both checkboxes shown, as on the Official Form) |

No OPEN rows. Generic sample (`OUTPUT-bap1-answering-brief-generic.typst.pdf`, 9 pages) re-rendered after the changes and every page viewed: cover, TOC, TOA, oral-argument statement, body, signature under the Conclusion, certificate, related-cases and interested-parties statements each on one page. No defect found.

Summary of the tier-2 comparison against the alternate exemplar (appellant's opening brief, viewed: cover p.1, TOC p.2, TOA p.3, body p.6, p.14, p.15, p.30, signature and certificate p.35, statements pp.36-37): see `../opening-brief/README.md`; both filers agree on centered cover and caption, centered bold capital level-1 headings at body size, left bold numbered level-2 points, dot leaders in the tables, and the form caption on the L.R. 8014-1 statements, and the template follows each.

## Engines

DOCX (`docx/`): `reference.docx` (built by `docx/build-reference.sh`, every font named explicitly, no theme fonts) and `docx/bap1.lua` (cover, disclosure, contents, authorities, oral-argument statement, the body's heading numbers, the related-cases page and the certificate, with the word limit and required sections checked as in the typst template). `tools/render.sh --engine docx` writes `usage/OUTPUT-bap1-answering-brief-generic.docx` and its LibreOffice PDF. The body font in the PDF is EB Garamond only; DejaVu Sans appears for the ballot-box glyphs in the related-cases statement.

Matches the typst output (checked on the LibreOffice PDF against `usage/OUTPUT-generic-*.pdf`, every page): EB Garamond 14 pt; body lines at the typst line pitch (22.25 pt exact); US Letter with 1 in margins; 0.5 in first-line indent, not on the first paragraph after a heading or a front title; centered caps level-1 headings at 19.5 pt and centered bold level-2 headings at 17 pt (the typst 1.4 em and 1.2 em heading sizes); bold left level 3 and 4 headings; cover on its own unnumbered section, its lines within a few points of the typst positions; page numbers from page 2 (typst counts the cover as page 1, so the contents page is page 2); footnote text 14 pt.

Differs from the typst output:
- Pagination: 8 pages in the docx against 8 in typst. Page counts match; the signature block lands alone on page 6 in both, as the typst section above already records.
- Heading numbers: the docx prints the level-2 numbers (I., II., ...) in the body as well as in the contents. The typst body omits them (its heading show rule drops the counter), so the body and contents disagree there. Kept as the template intends; David to decide.
- Certificate word count: docx 281 against typst 277. The docx counts the body text with pandoc; the typst count is taken from the cmarker output. The cause is not isolated (on one page the two token lists match apart from the numbers).
- Not exercised by the samples and not checked: block quotations (exact 15 pt, single-spaced), footnotes (exact 22.25 pt, 14 pt).

BLOCKED (DOCX):
- FRBP 8014(a)(2), contents page numbers (BAP-FORM-001 contents): the contents is a Word TOC field with cached entries and no page numbers. Word fills them in when fields are updated; the PDF shows no numbers. Measuring them needs a two-pass build (as the eighth circuit does) and is not done here.
- FRBP 8014(a)(3), table of authorities page numbers: the authorities are listed without pages, and "passim" is not produced. Same cause (TA fields are not honored by LibreOffice; see docs/DOCX.md).
- `tools/check.sh --engine docx` could not run on this folder: no `checks.yaml` at the court or doc-type level, and `court.json` is looked up in the doc-type folder. No gate result is claimed.
