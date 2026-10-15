# bap1 — Reply brief (Brief for Appellant)

- Court: United States Bankruptcy Appellate Panel for the First Circuit (`bap1`), folder `courts/first-circuit/bankruptcy-appellate-panel/reply-brief/`
- Doc type: `reply`
- Status: **BLOCKED: no exemplar.** Template built from the rules; no filed bap1 exemplar found (see `exemplars/SOURCE.md` for every search tried).

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

## Conflict to resolve (David)

The [BAP guide](https://www.bap1.uscourts.gov/sites/bap1/files/BAP_Guide.pdf) §VI says text may be 11-point, double-spaced, with a 30-page limit (15 for reply), and that a 13,000-word principal brief is acceptable. FRBP 8015(a)(5) as fetched says 14-point and 13,000 words (half for reply). The template follows the federal rule, which the local rules cannot override (L.R. 8015-1(a) only lets the panel accept nonconforming documents). Which governs the bap1 filing is an open question for David; the guide's 11-point figure should not be used until it is resolved. The quick reference also lists 30 and 15 pages, which the template does not enforce (the word limit does).

## Template

- `typst/bap1-reply.typ` (the template, `doc-kind = "reply"`) and `typst/main.typ` (entry). Same structure as the other two doc types; only the constant and the cover title differ.
- Cover: BAP docket number, the panel name, caption, proceeding, bankruptcy case number, brief title, counsel block. No page number on the cover.
- Front matter: optional corporate disclosure (FRBP 8012, only when `disclosure:` is given), table of contents (outline), table of authorities (built from `toa:` links; "passim" at 7+ pages), oral-argument statement.
- Body: markdown rendered by cmarker. Level-1 headings are sections, centered bold capitals. Level 2 is `I.`, level 3 `A.`, level 4 `1.`. The template refuses to build if a required section heading is missing (BAP-FORM-001) or the word count exceeds the limit (BAP-LEN-001).
- Back matter: signature block, statement regarding related cases (checkboxes), certificate of compliance. The word count is computed from the rendered text (headings included, footnotes not).
- Fonts: only the vendored EB Garamond (`fonts/eb-garamond/`); `render.sh` uses `--ignore-system-fonts`, and any typst warning fails the build.

## Sample and overlay

- `samples/INPUT-generic-reply-brief.md`: fictional, rule-structured, not a transcription of any filing. Frontmatter is the schema.
- `samples/OUTPUT-generic-reply-brief.pdf`: rendered with `sh tools/render.sh courts/first-circuit/bankruptcy-appellate-panel/reply-brief samples/INPUT-generic-reply-brief.md`. Renders clean (no typst warnings).
- Overlay: `sh tools/overlay.sh courts/first-circuit/bankruptcy-appellate-panel/reply-brief generic-reply-brief` **fails**: "no exemplar pdf in exemplars/". There is nothing to overlay against, so no OVERLAY files exist.

## Run 2026-10-15 (bap1 exemplar search)

- Exemplar: none (see `exemplars/SOURCE.md`). CourtListener returns 0 bap1 RECAP documents and 0 bap1 dockets; the bap1 filter is throttled (429) on some queries. The status stays BLOCKED.
- Render: `sh tools/render.sh` on `samples/INPUT-generic-reply-brief.md` exits 0 (6 pages). Overlay: `sh tools/overlay.sh` exits 1, "no exemplar pdf".
- Pages reviewed this run: 0. The sample was rendered to check the build, not reviewed page by page; the Gate 2 notes below are from the earlier run.

## Gate 2 review (every page viewed)

Pages were rasterized at 60 dpi and each was checked on a contact sheet. Defects found and fixed in the same pass: cover lines running together (fixed with per-line blocks); paragraphs without first-line indent; signature and certificate blocks running together. Remaining open items:

- Signature block and "Respectfully submitted" land alone on the last page (answering brief, page 6) when the conclusion ends near the foot of page 5. The template keeps the signature block unbreakable but does not keep it with the conclusion. Accepted for now.
- The cover, TOC and TOA were checked against the rules only, not against any filed bap1 exemplar.

## Engines

DOCX (`docx/`): `reference.docx` (built by `docx/build-reference.sh`, every font named explicitly, no theme fonts) and `docx/bap1.lua` (cover, disclosure, contents, authorities, oral-argument statement, the body's heading numbers, the related-cases page and the certificate, with the word limit and required sections checked as in the typst template). `tools/render.sh --engine docx` writes `samples/OUTPUT-generic-reply-brief.docx` and its LibreOffice PDF. The body font in the PDF is EB Garamond only; DejaVu Sans appears for the ballot-box glyphs in the related-cases statement.

Matches the typst output (checked on the LibreOffice PDF against `samples/OUTPUT-generic-*.pdf`, every page): EB Garamond 14 pt; body lines at the typst line pitch (22.25 pt exact); US Letter with 1 in margins; 0.5 in first-line indent, not on the first paragraph after a heading or a front title; centered caps level-1 headings at 19.5 pt and centered bold level-2 headings at 17 pt (the typst 1.4 em and 1.2 em heading sizes); bold left level 3 and 4 headings; cover on its own unnumbered section, its lines within a few points of the typst positions; page numbers from page 2 (typst counts the cover as page 1, so the contents page is page 2); footnote text 14 pt.

Differs from the typst output:
- Pagination: 6 pages in the docx against 6 in typst. Page counts match.
- Heading numbers: the docx prints the level-2 numbers (I., II., ...) in the body as well as in the contents. The typst body omits them (its heading show rule drops the counter), so the body and contents disagree there. Kept as the template intends; David to decide.
- Certificate word count: docx 136 against typst 134. The docx counts the body text with pandoc; the typst count is taken from the cmarker output. The cause is not isolated (on one page the two token lists match apart from the numbers).
- Not exercised by the samples and not checked: block quotations (exact 15 pt, single-spaced), footnotes (exact 22.25 pt, 14 pt).

BLOCKED (DOCX):
- FRBP 8014(a)(2), contents page numbers (BAP-FORM-001 contents): the contents is a Word TOC field with cached entries and no page numbers. Word fills them in when fields are updated; the PDF shows no numbers. Measuring them needs a two-pass build (as the eighth circuit does) and is not done here.
- FRBP 8014(a)(3), table of authorities page numbers: the authorities are listed without pages, and "passim" is not produced. Same cause (TA fields are not honored by LibreOffice; see docs/DOCX.md).
- `tools/check.sh --engine docx` could not run on this folder: no `checks.yaml` at the court or doc-type level, and `court.json` is looked up in the doc-type folder. No gate result is claimed.
