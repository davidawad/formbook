# pawb: motion brief

Doc type: **motion brief** (the memorandum in support of a motion, FRBP 9013, in an adversary proceeding) in the United States Bankruptcy Court for the Western District of Pennsylvania (`pawb`).
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a portion of the 19-page brief (caption, all of I and II, the first six paragraphs of III, all of IV.A.1 and IV.A.2, the first three paragraphs of IV.A.3, all of IV.B and IV.D, the first two paragraphs of IV.C, the conclusion and the signature block). See "Sample" below. |
| typeface | face required: **none** (LBR 5005-13(b)(4) names Courier only as the size benchmark, "12 Courier or an equivalent font size"; no face is mandated). Substitute: none needed. Used: **EB Garamond** (vendored), 13 pt. Metric-compatible: n/a. See Known gaps 1. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-bernstein-brief-in-support.pdf` and `.txt` (page map) |
| pages reviewed | 10 of 10 (every page of the final PDF rendered at 60 dpi and viewed) |
| check gates | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this folder is a doc-type folder (see Known gaps) |

## Governing rules

Primary sources, read 2026-10-14. Local rules: the W.D. Pa. Local Bankruptcy Rules compilation published on the court's "Local Rules Currently in Effect" page, https://www.pawb.uscourts.gov/sites/default/files/lrules2026/Localrules2026.pdf (rules take effect July 1, 2026, LBR 1001-3). Federal rules: Federal Rules of Bankruptcy Procedure as restyled effective 2024-12-01, https://www.law.cornell.edu/rules/frbp/ (rule 9013 read; 7008, 7010 and 9004 read in the adversary-complaint review). Official Form 416D (12/15), https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf.

Kind: **M** mandated by a rule (tier 1), **C** convention seen in the exemplar (tier 2), **A** author responsibility or a separate filing.

| ID | Kind | Requirement | Source (rule text) | Where it lives |
|---|---|---|---|---|
| PAWB-MOT-001 | M | 8½ × 11 inch paper. | W.PA LBR 5005-13(b)(1) | `paper: "us-letter"` in `typst/pawb-motion-brief.typ` |
| PAWB-MOT-002 | M | Sequential page numbers on every page. | W.PA LBR 5005-13(b)(2) | `page-footer()`: centered, page 1 included |
| PAWB-MOT-003 | M | Font no smaller than "12 Courier or an equivalent font size", footnotes included. | W.PA LBR 5005-13(b)(4) | `type-size = 13pt` (EB Garamond) for body, block quotations and footnote entries. See Known gaps 1. |
| PAWB-MOT-004 | M | Created directly to PDF, flattened, fully text-searchable. | W.PA LBR 5005-13(b)(5), (d) | Typst output; every word of the sample markdown is in the PDF text (0 missing after the final render) |
| PAWB-MOT-005 | M | Caption substantially conforms to Official Form 416D: court name; debtor and case number; chapter; plaintiff and defendant; Adv. Proc. No.; title. | FRBP 7010 (FRCP 10 applies; caption per Form 416); FRBP 9004(b); W.PA LBR 7010-1(a); Form 416D | `caption(meta)`: boxed debtor and party column; "Case No." with the judge's initials, chapter and "Adv. Proc. No." on the right |
| PAWB-MOT-006 | M | Motion filed in an adversary proceeding carries a short, concise descriptive title in addition to the complete adversary caption. | W.PA LBR 7010-1(b); LBR 7008-1(b) | Frontmatter `title` ("BRIEF IN SUPPORT OF MOTION TO DISMISS") printed under the caption |
| PAWB-MOT-007 | M | A motion states its grounds with particularity and the relief requested. | FRBP 9013(a)-(b) (a request for an order is made by written motion; the motion states its grounds with particularity) | Author content (the brief); not enforced |
| PAWB-MOT-008 | M | Proposed order of court attached to the motion as a separate attachment, specifying the relief sought. | W.PA LBR 7008-1(c); LBR 9013-1(a); LBR 9013-4(a)-(b) | **Separate filing** (the proposed order is not produced by this template). The exemplar's motion is ECF Adv. Doc. 25, with a proposed order. |
| PAWB-MOT-009 | M | Briefs by the moving party limited to twenty pages (unless the court directs otherwise). | W.PA LBR 7008-1(e) | **Not asserted.** The template does not count pages. The sample is 10 pages; the exemplar's full brief is 19. See Known gaps 2. |
| PAWB-MOT-010 | M | Electronic signature: "/s/" before the filing user's name, then name, address, telephone, e-mail and state Bar registration number. | W.PA LBR 5005-6(d) | `signature-block()`: "/s/" on the filing user's name only (`sign: true`), then Bar ID and e-mail; firm lines above |
| PAWB-MOT-011 | C | Paragraphs are not numbered in a brief (the LBR 5005-13(b)(3) exception). | W.PA LBR 5005-13(b)(3) ("except as to briefs"); the exemplar | Body is one markdown pass, unnumbered (the rule permits this; it does not require it) |
| PAWB-MOT-012 | C | Double spacing with first-line indent of ½ inch; body text justified, not hyphenated; block quotations single-spaced and indented ½ inch on each side. | The exemplar (no W.PA rule sets spacing) | `body-leading = 1.35em`, `para-indent = 0.5in`, `quote` show rule |
| PAWB-MOT-013 | C | Section headings: level 2 centered bold caps ("I. OVERVIEW", "CONCLUSION"); level 3 bold at the margin ("A. ..."); level 4 bold italic ("1. ..."). Headings typed with their numbers. | The exemplar | `heading.where(level: 2/3/4)` |
| PAWB-MOT-014 | C | 1-inch margins. | The exemplar (no W.PA rule sets margins) | `margin = 1in` |
| PAWB-MOT-015 | A | Notice of hearing, certificate of service, responses (14 days after service, LBR 7008-1(d); 9014-1), replies (not permitted without order, LBR 7008-1(d)), and any Judge-specific scheduling procedure (LBR 9013-5(a)). | W.PA LBR 7008-1(d), 9013-5(a); 9014-1 | Separate filings; not produced by this template |

## Layout

- Letter paper, 1-inch margins, page numbers centered at the foot of every page.
- Caption as in the adversary complaint: court title, boxed Form 416D caption, the title of the paper in bold centered caps below it.
- Body: double-spaced; first-line indent on every paragraph (the first paragraph after a heading included, via `first-line-indent: (amount, all: true)`).
- Headings: level 2 centered bold caps; level 3 bold, left; level 4 bold italic, left. Each heading is sticky: it stays with the text after it.
- Footnotes at the foot of the page, 13 pt, single-spaced (footnote text is subject to the same type-size rule).
- Block quotations: single-spaced, indented ½ inch on each side.
- Signature block single-spaced after the conclusion: "Respectfully submitted," firm name and address, then each attorney's "/s/" (filing user only), Bar ID, and e-mail.
- No table of contents or table of authorities: no W.PA rule found that requires them for a brief of this length, and the exemplar has neither.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `debtor` (`name`, `designation`), `bankruptcy_case` (with judge's initials), `chapter`, `caption.parties` (list of `{names, designation}`), `adversary_number`, `title`, `signature` (optional `firm` lines; `blocks` of `{signer, sign, pa_id, lines}`).
- Body: ordinary markdown. Headings: `##` level 2 (centered), `###` level 3, `####` level 4. Footnotes: `[^label]` with definitions. Block quotations: `>`. Italics: `*...*`. The whole body is rendered in one pass so footnote references and definitions stay linked.
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
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief bernstein-brief-in-support
```

- `render.sh` fails on any typst warning. The render uses only the vendored EB Garamond (`pdffonts` lists Regular, Italic, Bold and BoldItalic, all embedded).
- The overlay pairs ours p.1 to p.4 with filed p.1 to p.4; ours p.5 to p.7 with filed p.7 to p.9; ours p.8 to p.10 with filed p.14, p.17 and p.18. Word overlap runs 44% to 79%. The later pairs are coarse because the sample omits parts of the exemplar's text. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record: all 10 pages of the current PDF, rendered at 60 dpi and viewed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title; boxed caption (debtor; plaintiff and defendants, the second defendant's name broken across lines without a stray word); "Case No. 19-22715-CMB", "Chapter 11", "Adv. Proc. No. 21-02063"; title; opening paragraph; I. OVERVIEW (centered); first paragraph indented. | PASS |
| 2 | exemplar p.2 | I. OVERVIEW paragraphs; II. PROCEDURAL BACKGROUND (centered); three paragraphs; III heading at the foot of the page with its paragraph. | PASS |
| 3 | exemplar p.3 | III. STATEMENT OF THE FACTS; paragraphs with ECF and complaint citations; footnote 1 at the foot of the page, single-spaced. | PASS |
| 4 | exemplar p.4 | Paragraphs on the deal structure; footnotes 2 and 3 at the foot of the page (13 pt). White space above the footnotes: the two notes were kept whole. | PASS |
| 5 | exemplar p.5 | IV. ARGUMENT; A. heading (bold, margin); IV.A.1 and IV.A.2 headings (bold italic); block quotation (single-spaced, indented). | PASS |
| 6 | exemplar p.6 | Block quotation continues; IV.A.2 closing paragraphs; IV.A.3 heading (bold italic, two lines). | PASS |
| 7 | exemplar p.7 | Block quotation of § 108(a); Section 108 paragraphs; footnote 4 at the foot of the page. | PASS |
| 8 | exemplar p.14 | IV.B heading (bold, margin, two lines, kept with its paragraph); IV.C heading. | PASS |
| 9 | exemplar p.17 | IV.C continuation (the Preamble quotation); IV.D heading; footnote 5 at the foot of the page. | PASS |
| 10 | exemplar p.18 | CONCLUSION (centered); the jury demand; "Respectfully submitted," firm block; "/s/Holly M. Whalen, Esquire" (only the filing user carries "/s/"), then the two other attorneys with Bar IDs and e-mail. | PASS |

Gate 2 rows are recorded here, not in `reviews/`, because this folder has no `reviews/` directory.

## Known gaps and open choices

1. **Type size and face (PAWB-MOT-003).** The same reading as the adversary complaint: "12 Courier or an equivalent font size" makes Courier a size benchmark, not a required face, so EB Garamond stays (no `docs/FONTS.md` substitute is used). EB Garamond at 13 pt, chosen because "12 Courier or an equivalent font size" is ambiguous and EB Garamond at 12 pt looks smaller than the exemplar's Times at 12 pt. A reading of "12 pt as typed" would allow 12 pt. Open choice for David.
2. **Page limit (PAWB-MOT-009).** LBR 7008-1(e) limits a moving party's brief to twenty pages. The template does not count pages, and the sample is 10 pages, so the limit is untested. The full brief has not been rendered at this type size, so its page count is unknown; the author must check it. Open: whether the limit counts the caption and signature pages.
3. **Motion and proposed order are separate filings.** The exemplar is the brief; the motion (ECF Adv. Doc. 25) and the proposed order (LBR 7008-1(c), 9013-4) are not produced here. A motion template is not in this folder.
4. **No table of contents or authorities.** No W.PA rule found requires one for a brief of this length. Revisit if the brief runs long enough that a clerk expects one.
5. **Caption wording.** The exemplar uses "Bankr. Case No." and "Adv. Pro. No."; the template uses Form 416D's "Case No." and "Adv. Proc. No." (LBR 7010-1(a)). The rule text and the form are followed; the exemplar's wording is recorded here as the one difference.
6. **Tier 2 is judged against one filer only.** A second filer's brief in support of a motion to dismiss, not collected (the brief asks for one exemplar per doc type): Snyder v. Biros, Adv. 23-02020, ECF Doc. 8 (20 pages, Biros's counsel), https://storage.courtlistener.com/recap/gov.uscourts.pawb.380052/gov.uscourts.pawb.380052.8.0.pdf. EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met.
7. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md`. The gates were not run; the render and overlay were run and the review above is the Gate 2 equivalent. Gate 0 was checked by hand: every word of the sample markdown occurs in the PDF text.
8. **Local rules and Judge practice.** LBR 9013-5(a) directs parties to each Judge's scheduling procedures on the court's website; those are not part of this template and were not read.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx`, `docx/pawb.lua`, `docx/build-reference.sh`; output `usage/OUTPUT-motion-brief.docx`): pandoc 3.6.4 on the reference: EB Garamond 13 pt, exact 26 pt double and 14.95 pt single lines (the pitch measured on the typst render), 1 in margins on US Letter, 0.5 in first-line indent on every body paragraph, headings as in the typst template (level 2 centered bold, level 3 bold, level 4 bold italic), footnotes 13 pt single (pandoc footnotes), block quotes single-spaced and indented 0.5 in on each side, page number centered in the footer. The Lua filter builds the court title, the Form 416D caption (a borderless table with the two boxed cells), the title and the signature block from the frontmatter (the "/s/" on the filing user only).
- Differences from typst: the quoted "(a)" list in the block quote is a Word list (pandoc numbering), not typst's list; the caption rules are cell borders, which Word and LibreOffice draw slightly differently; EB Garamond is not embedded, so the machine that opens the file needs it installed; line breaks and page count are whatever Word or LibreOffice produce from these styles, not measured. No table of contents or authorities, as in the typst template.
- Checked here: `ziptool` reads all 17 parts and `xmllint --noout` passes on every XML part; the docx was not rendered and has no visual review.
- docx BLOCKED: no checks file is readable (this folder has no `checks.yaml` and no `rules.md`; the `PAWB-MOT-*` IDs in the rules table are rule IDs, not gate checks). Every gate check measured on `usage/<id>.docx.pdf` is BLOCKED: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.
