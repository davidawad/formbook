# bap1 — Reply brief (Brief for Appellant)

- Court: United States Bankruptcy Appellate Panel for the First Circuit (`bap1`), folder `courts/first-circuit/bankruptcy-appellate-panel/reply-brief/`
- Doc type: `reply`
- Status: **BLOCKED: no exemplar** (re-searched 2026-10-16). No public bap1 reply brief exists on CourtListener (searched under court id `ca1`, where the BAP's dockets are filed; see "Re-search 2026-10-16" below and `usage/SOURCE.md`). The template is shared with the opening and answering briefs and received their 2026-10-16 fixes (see `../opening-brief/README.md`, "Template changes from the overlay"); the generic sample was re-rendered and every page viewed. Typst only: `docx/` and `latex/` were not touched.

Summary line for the PM: `exemplar=no render=ok overlay=blocked pages_reviewed=7`

## Rules (verified 2026-10-14)

| ID | Requirement | Source | Verified |
|---|---|---|---|
| BAP-FORM-001 | Contents and order of the reply brief: FRBP 8014(c) | FRBP 8014 via [LII](https://www.law.cornell.edu/rules/frbp/rule_8014) | 2026-10-14 |
| BAP-FORM-002 | One-inch margins on all sides; letter paper | FRBP 8015(a)(4) via [LII](https://www.law.cornell.edu/rules/frbp/rule_8015); BAP guide §VI | 2026-10-14 |
| BAP-FORM-003 | Proportionally spaced serif font, 14-point or larger; sans-serif only in headings and captions | FRBP 8015(a)(5) via LII | 2026-10-14 |
| BAP-FORM-004 | Double-spaced text; quotations and footnotes may be single-spaced | FRBP 8015(a)(4) via LII | 2026-10-14 |
| BAP-LEN-001 | Type-volume limit: 6,500 words (FRBP 8015(a)(7)(B)) | FRBP 8015(a)(7) via LII | 2026-10-14 |
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

- `typst/bap1-reply.typ` (the template, `doc-kind = "reply"`) and `typst/main.typ` (entry). Same structure as the other two doc types; only the constant and the cover title differ.
- Cover (BAP-COVER-001): BAP number at the top, the panel name, bankruptcy case number, optional debtor line (`debtor`), caption, proceeding, brief title with the optional party name (`party`), counsel block (two columns when there are several counsel groups). No page number on the cover.
- Front matter: optional corporate disclosure (FRBP 8012, only when `disclosure:` is given), table of contents (outline), table of authorities (built from `toa:` links; "passim" at 7+ pages), oral-argument statement.
- Body: markdown rendered by cmarker. Body text double spaced (ascender-to-descender line box, about 31.4 pt pitch at 14 pt). Headings at body size, single spaced: level 1 centered bold capitals; level 2 `I.` left, bold, numbered, hanging indent; level 3 `A.`, level 4 `1.`. The template refuses to build if a required section heading is missing (BAP-FORM-001; each section accepts several titles, case-insensitive) or the word count exceeds the limit (BAP-LEN-001).
- Back matter: signature block, certificate of compliance, then the statements regarding related cases and interested parties (BAP-LR-001, -002, -005), each repeating the Official Form caption with checkboxes and the attorney's signature block; the interested-parties statement is omitted when `governmental_party: true`. The word count is computed from the rendered text (headings included, footnotes not).
- Fonts: only the vendored EB Garamond (`fonts/eb-garamond/`); `render.sh` uses `--ignore-system-fonts`, and any typst warning fails the build.

## Sample and overlay (before 2026-10-16)

- `usage/INPUT-reply-brief.md`: fictional, rule-structured, not a transcription of any filing. Frontmatter is the schema.
- `usage/OUTPUT-reply-brief.typst.pdf`: rendered with `sh tools/render.sh courts/first-circuit/bankruptcy-appellate-panel/reply-brief usage/INPUT-reply-brief.md`. Renders clean (no typst warnings).
- Overlay: `sh tools/overlay.sh courts/first-circuit/bankruptcy-appellate-panel/reply-brief generic-reply-brief` **fails**: "no exemplar pdf in usage/". There is nothing to overlay against, so no OVERLAY files exist.

## Run 2026-10-15 (bap1 exemplar search)

- Exemplar: none (see `usage/SOURCE.md`). CourtListener returns 0 bap1 RECAP documents and 0 bap1 dockets; the bap1 filter is throttled (429) on some queries. The status stays BLOCKED.
- Render: `sh tools/render.sh` on `usage/INPUT-reply-brief.md` exits 0 (6 pages). Overlay: `sh tools/overlay.sh` exits 1, "no exemplar pdf".
- Pages reviewed this run: 0. The sample was rendered to check the build, not reviewed page by page; the Gate 2 notes below are from the earlier run.

## Gate 2 review of the generic sample (earlier run, before 2026-10-15)

Pages were rasterized at 60 dpi and each was checked on a contact sheet. Defects found and fixed in the same pass: cover lines running together (fixed with per-line blocks); paragraphs without first-line indent; signature and certificate blocks running together. Remaining open items:

- Signature block and "Respectfully submitted" land alone on the last page (answering brief, page 6) when the conclusion ends near the foot of page 5. The template keeps the signature block unbreakable but does not keep it with the conclusion. Accepted for now.
- The cover, TOC and TOA were checked against the rules only, not against any filed bap1 exemplar.

## Re-search 2026-10-16 (still BLOCKED)

CourtListener files the First Circuit BAP's dockets under the circuit's court id `ca1`, not `bap1`; the opening and answering exemplars were found that way. Reply-brief searches on 2026-10-16 (by the batch lead, recorded here; details in `usage/SOURCE.md`): RECAP full text `"BANKRUPTCY APPELLATE PANEL FOR THE FIRST CIRCUIT" "REPLY BRIEF"` (24 hits, none a bap1 reply brief: mab, mad, prd, prb, med and ca1 circuit filings); `caseName:Blumsack court=ca1` (no reply brief docketed or uploaded in BAP No. MW 23-03); `caseName:Akouete court=ca1` and `caseName:Muszynski court=ca1` (bap1 dockets 24-11, 24-14, 24-16, 26-3; the Muszynski docket, BAP No. PR 24-011, shows "Appellant Charles Muszynski reply brief filed" on 03/07/2025, but the document is not on RECAP); `description:(brief) AND "Bankruptcy Appellate Panel" court=ca1` (none). **BLOCKED: no public bap1 reply brief**, so no transcription and no overlay for this doc type, and tier 2 cannot be judged for it.

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

## Gate 2 review of the generic sample (2026-10-16, after the template changes)

`usage/OUTPUT-reply-brief.typst.pdf` (7 pages), rendered at 60 dpi and every page viewed. No exemplar to compare with; checked against the rules and against the two filed bap1 briefs of the other doc types.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | rules (BAP-COVER-001) | Cover: BAP No. at top, court, bankruptcy case number, caption, proceeding, "REPLY BRIEF FOR APPELLANT", counsel. | PASS |
| 2 | rules (FRBP 8014(a)(2)) | TOC with leaders, I.-II. entries numbered, pages match the body. | PASS |
| 3 | rules (FRBP 8014(a)(3)) | TOA with leaders; pages match the body (p.4). | PASS |
| 4 | rules (BAP-FORM-004) | Argument, I., II., Conclusion; body double spaced; headings at body size; signature block under the Conclusion. | PASS |
| 5 | rules (FRBP 8015(h)) | Certificate of compliance under FRBP 8015(a)(7)(B), word count 134. | PASS |
| 6 | Official Form 1 | Statement regarding related cases with caption, checkboxes and signature, one page. | PASS |
| 7 | Official Form 2 | Statement regarding interested parties with caption, checkboxes and signature, one page. | PASS |

## Engines

DOCX (`docx/`): `reference.docx` (built by `docx/build-reference.sh`, every font named explicitly, no theme fonts) and `docx/bap1.lua` (cover, disclosure, contents, authorities, oral-argument statement, the body's heading numbers, the related-cases page and the certificate, with the word limit and required sections checked as in the typst template). `tools/render.sh --engine docx` writes `usage/OUTPUT-reply-brief.docx` and its LibreOffice PDF. The body font in the PDF is EB Garamond only; DejaVu Sans appears for the ballot-box glyphs in the related-cases statement.

Matches the typst output (checked on the LibreOffice PDF against `usage/OUTPUT-generic-*.pdf`, every page): EB Garamond 14 pt; body lines at the typst line pitch (22.25 pt exact); US Letter with 1 in margins; 0.5 in first-line indent, not on the first paragraph after a heading or a front title; centered caps level-1 headings at 19.5 pt and centered bold level-2 headings at 17 pt (the typst 1.4 em and 1.2 em heading sizes); bold left level 3 and 4 headings; cover on its own unnumbered section, its lines within a few points of the typst positions; page numbers from page 2 (typst counts the cover as page 1, so the contents page is page 2); footnote text 14 pt.

Differs from the typst output:
- Pagination: 6 pages in the docx against 6 in typst. Page counts match.
- Heading numbers: the docx prints the level-2 numbers (I., II., ...) in the body as well as in the contents. The typst body omits them (its heading show rule drops the counter), so the body and contents disagree there. Kept as the template intends; David to decide.
- Certificate word count: docx 136 against typst 134. The docx counts the body text with pandoc; the typst count is taken from the cmarker output. The cause is not isolated (on one page the two token lists match apart from the numbers).
- Not exercised by the samples and not checked: block quotations (exact 15 pt, single-spaced), footnotes (exact 22.25 pt, 14 pt).

BLOCKED (DOCX):
- FRBP 8014(a)(2), contents page numbers (BAP-FORM-001 contents): the contents is a Word TOC field with cached entries and no page numbers. Word fills them in when fields are updated; the PDF shows no numbers. Measuring them needs a two-pass build (as the eighth circuit does) and is not done here.
- FRBP 8014(a)(3), table of authorities page numbers: the authorities are listed without pages, and "passim" is not produced. Same cause (TA fields are not honored by LibreOffice; see docs/DOCX.md).
- `tools/check.sh --engine docx` could not run on this folder: no `checks.yaml` at the court or doc-type level, and `court.json` is looked up in the doc-type folder. No gate result is claimed.

## Filed exemplar and review 2026-10-21

Found and downloaded the public Reply Brief of Appellant Christine Marie Ansin, BAP No. NH 23-025, filed March 7, 2024 by counsel Darlene M. Daniele. The docket URL, public file URL, filer, case and date fetched are recorded in `usage/SOURCE.md`. Replaced the fictional sample with an abridged transcription of the filed structure in `usage/INPUT-reply-brief.md`. The exemplar is nine pages. `sh tools/render.sh` produced an 11-page output; `sh tools/overlay.sh` produced the overlay PDF and text under `.overlay/courts/first-circuit/bankruptcy-appellate-panel/reply-brief/`.

The first render left one Rules entry by itself on page 4 of the TOA. Both filed BAP1 briefs show compact TOA entry spacing and keep the table together, so reduced the entry gap from 0.8em to 0.25em in the three copied BAP1 templates. The new reply render keeps all authorities on page 3; answering and opening remain 19 and 22 pages. Regenerated all three outputs and overlays. Rasterized and viewed every page of the 9-page filing and 11-page output at 60 dpi.

| Output page | Compared with | Finding | Status |
|---:|---|---|---|
| 1 | Filed p. 1 | BAP No., panel name, debtor and party caption, proceeding, reply title, counsel and date; single-page cover. The source uses “Reply Brief of Appellant”; the template identifies the party as “Reply Brief for Appellant, Christine Marie Ansin.” | ACCEPTED (title wording convention) |
| 2 | Filed p. 2 | Contents entries, hierarchy and page numbers are readable and track the output. | PASS |
| 3 | Filed p. 3 | Complete table of authorities with cases, statutes and rules on one page after spacing fix. | FIXED |
| 4 | Filed p. 4 | Argument begins after front matter; section I and subsection A, list and citations render cleanly. | PASS |
| 5 | Filed p. 5 | Subsection B and section II with subsection A; body is double spaced and headings are distinct. | PASS |
| 6 | Filed p. 6 | Subsection A continues, followed by subsection B and subsection C; no clipped or overlapping text. | PASS |
| 7 | Filed p. 7 | Subsection C continues and subsection D begins; footnotes and body remain legible. | PASS |
| 8 | Filed p. 8 | Subsection D concludes, followed by conclusion and signature block. | PASS |
| 9 | Filed p. 9 | Certificate of compliance is readable and stands on its own page. | PASS |
| 10 | Rules / Official Form 1 | Related-cases statement, caption, checkboxes and counsel block render on one page under L.R. 8014-1. The filed reply ends with its certificates and has no matching page. | PASS |
| 11 | Rules / Official Form 2 | Interested-parties statement, caption, checkboxes and counsel block render on one page under L.R. 8014-1. The filed reply ends with its certificates and has no matching page. | PASS |

No OPEN findings. Current output SHA-256: `fdb45c858cef3e98ab39f0b8ef763261749bd87eea7b568db920aa59dfaa09d9`.
