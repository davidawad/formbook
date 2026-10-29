# lawd: motion-brief

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b) motion, in the United States District Court for the Western District of Louisiana (`lawd`). The exemplar is a Rule 12(b)(6) memorandum; the template serves any Rule 12 memorandum of this district (the sample header says so).
Folder: `courts/fifth-circuit/louisiana/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, see `usage/SOURCE.md`) |
| typeface | face required: none (LR 7.1, 7.8 and 10.1 name no face or size, checked 2026-10-14). Font: Times New Roman (`docs/FONTS.md` rule 6, the house standard where the rules name no face; was EB Garamond before fb-595.68). Fit: n/a. The filed exemplar is set in Times New Roman, which is a filer choice, not a rule. |
| sample md | `usage/INPUT-motion-brief.md`: caption, opening, the TOC and TOA, filed pages 1 to 11 (Background, Law and Argument, Legal Standard, Part II.A and II.B), the conclusion, signature and certificate. Parts II.B (rest), II.C to II.F and Part III are a bracketed note. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 10 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.6) |
| overlay | ok: `usage/OVERLAY-lewis-motion-brief.pdf` and `OVERLAY-lewis-motion-brief.txt` (`sh tools/overlay.sh <this dir> lewis-motion-brief`) |
| pages reviewed | 10 of 10 on typst, latex and docx (every page of the three renders viewed at 40 dpi after the move onto the FRCP base, 2026-10-29; see "Engines"; older reviews below were made on earlier renders) |
| tools/check.sh | not run: same reason as `../complaint/README.md` |

File names: the tools write `OUTPUT-` and `OVERLAY-` names, not the `<id>.pdf` and `<id>-overlay.pdf` names in the brief. The sample is `INPUT-<id>.md`, which the tools expect.

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1 (W.D. La. Local Civil Rules, Ver3 030526, https://www.lawd.uscourts.gov/sites/lawd/files/UPLOADS/CivilCrimLRs.Barbara.updated.Ver3.030526.ppm.pdf, linked from https://www.lawd.uscourts.gov/local-rules) | A memorandum in support of a motion may not exceed 25 pages, exclusive of the tables; a judge may grant leave. A memorandum over 10 pages must have a table of contents and a table of authorities. | Table of contents (generated from the headings, depth 3) and table of authorities (from the sample's `authorities` list) are produced when `authorities` is in the frontmatter. The 25-page limit is not checked by the template. |
| LR 7.8 | The same limits and tables, for briefs. | Same as LR 7.1. |
| LR 7.3 | A proposed order is not required for a motion filed under Rule 12. | No proposed order is produced. |
| LR 10.1 | 8 1/2 x 11 paper, paginated, double spaced except footnotes and quotations. The caption includes the division, the district judge and the magistrate judge. | `page` (letter, roman numbers for the caption and tables, arabic from the body), `body-leading` (double spacing), `caption()` (JUDGE and MAGISTRATE JUDGE lines), `division` (checked against the five W.D. La. divisions). |
| LR 11.1 | Signature: the signer's name, address, telephone and Attorney Identification Number under the signature. | `signature()` prints the lines the sample gives (the sample carries the bar numbers in parentheses, as the exemplar does). The template does not check them. |
| FRCP 10(a) | Caption with the court's name, title, file number and Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10. | `caption()`, the court title, `title`. |
| FRCP 12(b)(6) | The motion is made by a Rule 12(b)(6) motion, and the memorandum is its support. | Not a template rule; the sample's title follows the filing. |

Not produced: the motion itself, the proposed order (not required, LR 7.3), any certificate of conference (LR 7.4.1 applies to non-dispositive motions, not to a Rule 12 motion).

## Layout

- Front matter (roman numbers): caption, title, optional subtitle (the filer line), and the opening paragraph(s) before the first heading.
- Tables: TABLE OF CONTENTS (generated) and TABLE OF AUTHORITIES (sample list, cases, statutes and other authorities, with dot leaders), each on its own page.
- Body (arabic numbers from 1): level 1 headings centered bold caps, level 2 bold at the margin, level 3 bold italic; paragraphs with a 0.5 inch first-line indent and double spacing; lists numbered (1), (2), ... 
- Signature block (single spaced, the date at left when given), then the CERTIFICATE OF SERVICE when the frontmatter has `certificate`.
- Every block is rounded up to whole 24 pt lines (`on-grid`), so no paragraph overlaps the line before it. Headings are kept with the paragraph after them (`sticky`), and the certificate heading is kept with its text.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `division`, `caption` (`parties`, `separator` such as `VERSUS`), `judge`, `magistrate`, `legend` (optional), `title`, `subtitle` (optional), `authorities` (list of `{category, items: [{cite, pages}]}`), `signature` (`date`, `lines`), `certificate` (`text`, `signature.lines`).
- The body is blank-line separated chunks: `# ` (level 1), `## ` (level 2), `### ` (level 3), a list (`1. ` items), or a paragraph. Case names in `*italics*`. A literal asterisk (as in "at *3") is written `\*`.
- `authorities[].items[].pages` is typed by hand (see Known gaps).
- Not supported: footnotes (none are transcribed), block quotations (single spaced in filings, so they would not match), tables other than the generated ones, and images.

## Known gaps and open choices

1. **Table of authorities page references.** Since fb-595.17.6 the template finds them: each authority in the frontmatter names the text that cites it (`find`, or `finds`), and every engine marks the pages where it appears.
2. **Font.** The same finding as `../complaint/README.md`: the W.D. La. local rules name no typeface. EB Garamond stayed until fb-595.68; the template is now Times New Roman 12 pt, the house standard where the rules name no face (`docs/FONTS.md` rule 6), which is also the exemplar's face.
3. **Footnotes.** The exemplar uses footnotes (references to the complaint, "Doc. 1, p. 23" and the like). The sample omits them (the markers are left out of the text), and the template does not render footnotes. Not tested whether cmarker renders `[^n]` footnotes; left as a gap.
4. **Block quotations.** The exemplar's block quotations (the Armstrong and Webster passage at 60 F.4th 276) are single spaced; the template has no quotation directive, so a quotation would be double spaced. The sample replaces that quotation with a bracketed note.
5. **Page limit.** LR 7.1 and 7.8 cap a memorandum at 25 pages, exclusive of tables. The template does not count pages. The exemplar is 15 pages of body text plus tables and certificate.
6. **Table of authorities wrap.** A long entry (Alvarado) wraps and its page reference drops to the next line, with dot leaders on that line. Cosmetic; not corrected.
7. **Caption style and filer line.** The caption uses asterisks and the subtitle carries the filer line, as the exemplar does; the exemplar's title block differs in spacing. Recorded as ACCEPTED.
8. **Second filer.** The brief asks for one exemplar. Other W.D. La. Rule 12 memoranda were checked for text and format but not stored: Burroughs v. KTBS, LLC, 5:25-cv-01933, Doc. 15-1 (32 pages; Times New Roman; TOC and TOA; Shreveport; https://storage.courtlistener.com/recap/gov.uscourts.lawd.215021/gov.uscourts.lawd.215021.15.1.pdf) and Street v. Christ, 2:25-cv-01882, Doc. 29-1 (33 pages; Lake Charles; https://storage.courtlistener.com/recap/gov.uscourts.lawd.214913/gov.uscourts.lawd.214913.29.1.pdf). Tier 2 is not judged against two filers yet.

## Review of the rendered pages

Every page was rendered at 60 dpi and viewed after the last template change (the EB Garamond render, before fb-595.68; the page contents below are from that render).

- Page 1 (caption, roman i): court title, caption with VERSUS, JUDGE DRELL, MAGISTRATE JUDGE PEREZ-MONTES, JURY TRIAL REQUESTED, the title and filer line, MAY IT PLEASE THE COURT and the opening paragraph. Pass.
- Page 2 (TOC, roman ii): entries to level 3, page numbers 1 to 6 matching the body pages (checked against the body headings). Pass.
- Page 3 (TOA, roman iii): cases, statute and other authorities with dot leaders and page references from the body search (see gap 1). Pass, with the wrap noted in gap 6.
- Page 4 (body 1): BACKGROUND, I. Factual background., the numbered list (1), (2) and the facts paragraph. Pass.
- Page 5 (body 2): II. Plaintiffs' claims with its two paragraphs, LAW AND ARGUMENT and its introduction. I. Legal Standard moves with its paragraph to page 6 (the orphan is fixed by `sticky`). Pass.
- Page 6 (body 3): I. Legal Standard and its paragraphs; II. heading with its first paragraph. Pass.
- Page 7 (body 4): Monell paragraphs; heading A with its first paragraph. Pass.
- Page 8 (body 5): the rest of A, heading B and its paragraphs (Edwards, Pembaur, Piotrowski). Pass.
- Page 9 (body 6): the rest of B, the bracketed note on the Armstrong quotation, CONCLUSION. Pass.
- Page 10 (body 7): date and signature block, CERTIFICATE OF SERVICE heading with its text and signature (the heading had stranded at the foot of page 4 in an earlier build; fixed). Pass.

## Gate 2 review on the FRCP base (2026-10-29, every page of the typst, latex and docx renders viewed)

- Page 1: court name and division, caption with the asterisk column, title and filer line, "MAY IT PLEASE THE COURT" opening. Unnumbered, as the exemplar. Pass.
- Page ii: table of contents, three levels, page column. Page iii: table of authorities (cases, statutes with *passim*, other authorities), pages found from `find` (the same pages the sample used to type). Pass.
- Pages 1 to 7: body, headings, numbered list, conclusion, signature beside the date, certificate of service. Pass.
- OPEN (tier 2): the tables are single-spaced (the old template set them at the body pitch); list items are numbered "1." at the margin, the exemplar "(1)".
- Frontmatter now: `brief_title`, `opening` (markdown), `authorities: [{heading, entries: [{cite, find}]}]` (the base's names; the Markdown contract above predates them).

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.6): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays what this court sets itself, each with its rule: the district's name and the division (the template asserts one of the five, LR 10.1); the caption with a column of asterisks as high as the parties, the civil action number and the judges (LR 10.1) and an optional bold legend; the title and the filer line; the sample's `opening` (the text before the first section) on the caption's page; the table of contents and the table of authorities (LR 7.1, 7.8), their pages now found by the template from each authority's `find`; the caption page counted, unprinted, the tables from ii, the text from 1; the signature block beside the date; the certificate of service. `typst/lawd-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`. `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them); the old per-folder template code and docx filter are removed. The page limit is `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine).

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass (every page and line breaks where typst breaks it) |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |

