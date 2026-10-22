# pawb: motion brief

Doc type: **motion brief** (the memorandum in support of a motion, FRBP 9013, in an adversary proceeding) in the United States Bankruptcy Court for the Western District of Pennsylvania (`pawb`).
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a portion of the 19-page brief (caption, all of I and II, the first six paragraphs of III, all of IV.A.1 and IV.A.2, the first three paragraphs of IV.A.3, all of IV.B and IV.D, the first two paragraphs of IV.C, the conclusion and the signature block). See "Sample" below. |
| typeface | face required: **none** (LBR 5005-13(b)(4) names Courier only as the size benchmark, "12 Courier or an equivalent font size"; no face is mandated). Used: **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard, in typst, the docx and its LibreOffice PDF (`fb lint fonts` does not report the folder). See Known gaps 1 |
| render | ok (2026-10-22): `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx` with its LibreOffice PDF, 10 pages each; `fb render`, vendored fonts only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 10 of 10, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |
| check gates | typst 10 passed, 0 failed; docx 14 passed, 0 failed, XENG-001..003 PASS (`params.cross_engine: gate`); DEF-LEN-001 asserts the 20-page limit (`params.page_limit: 20`, `eval.yaml`) |

## Governing rules

Primary sources, read 2026-10-14. Local rules: the W.D. Pa. Local Bankruptcy Rules compilation published on the court's "Local Rules Currently in Effect" page, https://www.pawb.uscourts.gov/sites/default/files/lrules2026/Localrules2026.pdf (rules take effect July 1, 2026, LBR 1001-3). Federal rules: Federal Rules of Bankruptcy Procedure as restyled effective 2024-12-01, https://www.law.cornell.edu/rules/frbp/ (rule 9013 read; 7008, 7010 and 9004 read in the adversary-complaint review). Official Form 416D (12/15), https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf.

Kind: **M** mandated by a rule (tier 1), **C** convention seen in the exemplar (tier 2), **A** author responsibility or a separate filing.

| ID | Kind | Requirement | Source (rule text) | Where it lives |
|---|---|---|---|---|
| PAWB-MOT-001 | M | 8½ × 11 inch paper. | W.PA LBR 5005-13(b)(1) | `paper: "us-letter"` in `typst/pawb-motion-brief.typ` |
| PAWB-MOT-002 | M | Sequential page numbers on every page. | W.PA LBR 5005-13(b)(2) | `page-footer()`: centered, page 1 included |
| PAWB-MOT-003 | M | Font no smaller than "12 Courier or an equivalent font size", footnotes included. | W.PA LBR 5005-13(b)(4) | `type-size = 12pt` (Times New Roman) for the body, block quotations and footnote entries. See Known gaps 1. |
| PAWB-MOT-004 | M | Created directly to PDF, flattened, fully text-searchable. | W.PA LBR 5005-13(b)(5), (d) | Typst output; every word of the sample markdown is in the PDF text (0 missing after the final render) |
| PAWB-MOT-005 | M | Caption substantially conforms to Official Form 416D: court name; debtor and case number; chapter; plaintiff and defendant; Adv. Proc. No.; title. | FRBP 7010 (FRCP 10 applies; caption per Form 416); FRBP 9004(b); W.PA LBR 7010-1(a); Form 416D | `caption(meta)`: boxed debtor and party column; "Case No." with the judge's initials, chapter and "Adv. Proc. No." on the right |
| PAWB-MOT-006 | M | Motion filed in an adversary proceeding carries a short, concise descriptive title in addition to the complete adversary caption. | W.PA LBR 7010-1(b); LBR 7008-1(b) | Frontmatter `title` ("BRIEF IN SUPPORT OF MOTION TO DISMISS") printed under the caption |
| PAWB-MOT-007 | M | A motion states its grounds with particularity and the relief requested. | FRBP 9013(a)-(b) (a request for an order is made by written motion; the motion states its grounds with particularity) | Author content (the brief); not enforced |
| PAWB-MOT-008 | M | Proposed order of court attached to the motion as a separate attachment, specifying the relief sought. | W.PA LBR 7008-1(c); LBR 9013-1(a); LBR 9013-4(a)-(b) | **Separate filing** (the proposed order is not produced by this template). The exemplar's motion is ECF Adv. Doc. 25, with a proposed order. |
| PAWB-MOT-009 | M | Briefs by the moving party limited to twenty pages (unless the court directs otherwise). | W.PA LBR 7008-1(e) | `params.page_limit: 20` in `eval.yaml` (DEF-LEN-001, the whole file counted: a safe upper bound). The sample is 10 pages; the exemplar's full brief is 19. |
| PAWB-MOT-010 | M | Electronic signature: "/s/" before the filing user's name, then name, address, telephone, e-mail and state Bar registration number. | W.PA LBR 5005-6(d) | `signature-block()`: "/s/" on the filing user's name only (`sign: true`), then Bar ID and e-mail; firm lines above |
| PAWB-MOT-011 | C | Paragraphs are not numbered in a brief (the LBR 5005-13(b)(3) exception). | W.PA LBR 5005-13(b)(3) ("except as to briefs"); the exemplar | Body is one markdown pass, unnumbered (the rule permits this; it does not require it) |
| PAWB-MOT-012 | C | Double spacing with first-line indent of ½ inch; block quotations single-spaced and indented ½ inch on each side. | The exemplar (no W.PA rule sets spacing) | `pitch-body = 24pt`, `para-indent = 0.5in`, `quote-indent = 0.5in`; ragged right (the cross-engine model; the exemplar is justified) |
| PAWB-MOT-013 | C | Section headings: level 2 centered bold caps ("I. OVERVIEW", "CONCLUSION"); level 3 bold at the margin ("A. ..."); level 4 bold italic ("1. ..."). Headings typed with their numbers. | The exemplar | `heading-block()` |
| PAWB-MOT-014 | C | 1-inch margins. | The exemplar (no W.PA rule sets margins) | `margin = 1in` |
| PAWB-MOT-015 | A | Notice of hearing, certificate of service, responses (14 days after service, LBR 7008-1(d); 9014-1), replies (not permitted without order, LBR 7008-1(d)), and any Judge-specific scheduling procedure (LBR 9013-5(a)). | W.PA LBR 7008-1(d), 9013-5(a); 9014-1 | Separate filings; not produced by this template |

## Layout

- Letter paper, 1-inch margins, Times New Roman 12 pt; page numbers centered at the foot of every page, in a single-pitch line ending 0.5 in above the edge.
- The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 24 pt for the body (double spacing, as the exemplar), 13.8 pt for single lines (court title, caption, title, block quotations, footnotes, signature, footer); the spaces between blocks explicit; ragged right, no hyphenation.
- Caption (Official Form 416D, LBR 7010-1(a)): court title in two bold centered lines; 18 pt below, the boxed column (3.4 in): "In re:", the debtor and its designation (half an inch in), a blank single line between them, ruled above and right; then the parties, ruled right and below, a blank single line between names, designation and parties; the case number and chapter, and the adversary proceeding number, at the top of each box on the right, 0.25 in from the rule. The title of the paper in bold centered 18 pt below; the text 12 pt below it.
- Body: double-spaced; first-line indent on every paragraph (the first paragraph after a heading included).
- Headings at the type size on the body pitch with no space of their own: level 2 centered bold caps; level 3 bold, left; level 4 bold italic, left. Each is kept whole and with the text after it.
- Footnotes at the foot of the page, 12 pt, single-spaced, 7 pt apart, kept whole, a short rule 6 pt below the text (footnote text is subject to the same type-size rule).
- Block quotations: single-spaced, indented ½ inch on each side, 12 pt above and below.
- Signature block single-spaced at the margin, 24 pt below the last paragraph and kept on one page with it: "Respectfully submitted,", the firm name and address, then each attorney's "/s/" (filing user only), Bar ID, and e-mail, a blank single line between the groups.
- No table of contents or table of authorities: no W.PA rule found that requires them for a brief of this length, and the exemplar has neither.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `debtor` (`name`, `designation`), `bankruptcy_case` (with judge's initials), `chapter`, `caption.parties` (list of `{names, designation}`), `adversary_number`, `title`, `signature` (optional `firm` lines; `blocks` of `{signer, sign, pa_id, lines}`).
- Body: blank-line-separated chunks. Headings: `##` level 2 (centered), `###` level 3, `####` level 4. Footnotes: `[^label]` with definitions (the definitions are taken out of the body). Block quotations: `>`. Italics: `*...*`. The body must end with a paragraph (it is kept with the signature).
- Not supported: tables, raw typst, paragraph numbering (not needed for briefs).
- The template contains no case-specific text.

## Exemplar and sample

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Bernstein, as Plan Administrator for the Creditors Trust, v. Meyer, Unkovic & Scott LLP and Robert E. Dauer, Jr., Adv. Proc. No. 21-02063 (main case 19-22715-CMB, Chapter 11). "Brief in Support of Motion to Dismiss", 19 pages, filed 2021-08-06 by the defendants' counsel (DiBella Weinheimer). Provenance in `usage/SOURCE.md`.
- The exemplar is the brief only. Its motion is ECF Adv. Doc. 25 (not in this folder). The brief's caption shows "Bankr. Case No." and "Adv. Pro. No."; the template follows Form 416D ("Case No.", "Adv. Proc. No.") as LBR 7010-1(a) requires.
- `usage/INPUT-motion-brief.md` transcribes the brief in order, verbatim (including the filing's own typos and its citation forms), with footnotes 1 to 5. Omitted from the transcription, to keep the render within the 8 to 14 page target:
  - III (Statement of the Facts): the paragraphs from "Consistent with its plan, in February 2018, Campbells then purchased the real estate ..." to the end of the section (the closing, the Perkins default history, the "Aside from financing issues" and "Finally" paragraphs).
  - IV.A.3: the paragraphs from "Within the Third Circuit, the application of Section 108(a) ..." to the end of the section (the Fifth Circuit and assignee authority, the equitable-estoppel paragraph, the closing paragraph).
  - IV.C: from "As noted in *Maritrans*..." to the end of the section (the RPC 1.3, 2.1 and 8.4 discussion).
  - The footnote 3 pages are included; nothing else is omitted from I, II, IV.A.1, IV.A.2, IV.B, IV.D or the conclusion.

## Render and overlay

```sh
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh --engine docx courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
just overlay courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief
```

The overlay (red = our render, blue = exemplar) is a diagnostic: the sample omits parts of the exemplar's text, and the exemplar is justified with its own line breaks, so lines do not coincide.

## Visual review (Gate 2 record: all 10 pages, typst and docx side by side at 50 dpi, 2026-10-22)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title; boxed caption (debtor ruled above and right, the parties ruled right and below, blank lines between names and designations, designations half an inch in, as the exemplar); "Case No. 19-22715-CMB", "Chapter 11", "Adv. Proc. No. 21-02063" at the top of each box; title; opening paragraph; I. OVERVIEW and two paragraphs. Both engines alike. | PASS |
| 2 | exemplar p.2 | I. OVERVIEW end; II. PROCEDURAL BACKGROUND (centered); three paragraphs; III. STATEMENT OF THE FACTS with its first paragraph. | PASS |
| 3 | exemplar p.3 | Statement of the facts; footnote 1 at the foot of the page, single-spaced, under a short rule. | PASS |
| 4 | exemplar p.4 | Deal structure paragraphs; IV. ARGUMENT; A. heading (bold, margin) and its paragraph; footnotes 2 and 3 kept whole, so the page ends four lines short with a gap above the notes (both engines). | PASS |
| 5 | exemplar p.5 | IV.A.1 and IV.A.2 headings (bold italic); the Wachovia block quotation (single-spaced, ½ inch in on each side). | PASS |
| 6 | exemplar p.6 | IV.A.2 closing paragraph; IV.A.3 heading (bold italic, two lines); the § 108(a) block quotation. | PASS |
| 7 | exemplar p.7 | Section 108 paragraphs; IV.B heading (bold, two lines, kept with its paragraph); footnote 4. | PASS |
| 8 | exemplar p.14 | Deepening insolvency; IV.C heading (two lines); the Preamble quotation; footnote 5. | PASS |
| 9 | exemplar p.17 | IV.D heading (three lines); the reservation-of-rights paragraphs; CONCLUSION and its paragraph. Ends short: the jury demand is kept with the signature. | PASS |
| 10 | exemplar p.18 | The jury demand; "Respectfully submitted," firm block; "/s/Holly M. Whalen, Esquire" (only the filing user carries "/s/"), then the two other attorneys with Bar IDs and e-mail. | PASS |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 271/271 lines, 10/10 pages).

Gate 2 rows are recorded here, not in `reviews/`, because this folder has no `reviews/` directory.

## Known gaps and open choices

1. **Type size and face (PAWB-MOT-003).** "12 Courier or an equivalent font size" makes Courier a size benchmark, not a required face. The template sets Times New Roman 12 pt, the exemplar's face and size and the house standard (was EB Garamond 13 pt). A reading of "12 Courier" as Courier's larger text width would ask for more than 12 pt; open for David.
2. **Page limit (PAWB-MOT-009).** DEF-LEN-001 counts the whole file against the 20 pages of LBR 7008-1(e). Open: whether the limit counts the caption and signature pages (the gate counts them, a safe upper bound).
3. **Motion and proposed order are separate filings.** The exemplar is the brief; the motion (ECF Adv. Doc. 25) and the proposed order (LBR 7008-1(c), 9013-4) are not produced here. A motion template is not in this folder.
4. **No table of contents or authorities.** No W.PA rule found requires one for a brief of this length. Revisit if the brief runs long enough that a clerk expects one.
5. **Caption wording.** The exemplar uses "Bankr. Case No." and "Adv. Pro. No."; the template uses Form 416D's "Case No." and "Adv. Proc. No." (LBR 7010-1(a)). The rule text and the form are followed; the exemplar's wording is recorded here as the one difference. The exemplar is justified; the template is ragged right (the cross-engine model: each engine justifies differently).
6. **Tier 2 is judged against one filer only.** A second filer's brief in support of a motion to dismiss, not collected (the brief asks for one exemplar per doc type): Snyder v. Biros, Adv. 23-02020, ECF Doc. 8 (20 pages, Biros's counsel), https://storage.courtlistener.com/recap/gov.uscourts.pawb.380052/gov.uscourts.pawb.380052.8.0.pdf. EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met.
7. **Selftest.** `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have; `tools/check.sh` runs on it (typst and docx, 0 failed).
8. **Local rules and Judge practice.** LBR 9013-5(a) directs parties to each Judge's scheduling procedures on the court's website; those are not part of this template and were not read.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/pawb-motion-brief.typ`): the reference.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 12 pt; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent; single lines and Footnote Text 13.8 pt, 7 pt after a note; Block Text 12 pt above and below, 0.5 in in on each side; "Body Text Keep" for the last paragraph; pandoc reads CommonMark with footnotes, as cmarker) and `docx/pawb-motion-brief.lua` on `lib/docx/xengine.lua`, which writes the court title, the Form 416D caption table (cell borders: top and right, then right and bottom), the title, the headings, the signature block kept with the last paragraph, the footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 10 passed, 0 failed; docx 14 passed, 0 failed, XENG-001..003 PASS (271/271 lines, 10/10 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
