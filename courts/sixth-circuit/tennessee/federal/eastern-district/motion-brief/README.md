# tned: motion-brief

Doc type: **motion brief** (memorandum of law supporting a Rule 12(b)(6) motion to dismiss) in the United States District Court for the Eastern District of Tennessee (`tned`).
Folder: `courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (Miller & Martin PLLC, the memorandum the sample transcribes) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (Blanchard Horton PLLC for the Hoffman defendants, a second filer); see `usage/SOURCE.md` |
| sample md | `usage/INPUT-motion-brief.md` (the whole memorandum, footnotes and certificate of service included) |
| render | ok (2026-10-29, fb-595.17.18): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 9 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with E.D. Tenn.'s local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 9 of 9 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |
| typeface | face required: none (LR 5.1) -> Times New Roman (vendored; `docs/FONTS.md` default), the exemplars' face, in every engine |

## Governing rules

| Rule | Requirement | Where | Source, verified |
|---|---|---|---|
| E.D. Tenn. LR 5.1 (TNED-FORM-001, TNED-SIG-001) | 8½ × 11 white paper; double-spaced, except quotations (indented and single-spaced) and headings and footnotes (single-spaced); font size no smaller than 12, footnotes included; margins at least 1 inch on all four sides; pages numbered consecutively at the bottom, nothing else in the bottom margin; the filing attorney's name, address, telephone number and BPR number. | The base (letter, one-inch margins, 12 pt, 24 pt double pitch, the page number centered); `quote`, `heading`, `footnote` and `closing` (each attorney's BPR number) in `typst/layout.yaml`. | Local Rules revised April 8, 2026, https://www.tned.uscourts.gov/local-rules (PDF `Local Rules_Active_2026.04.08 to Present.pdf`, p. 11); verified 2026-10-14. |
| E.D. Tenn. LR 7.1(b) | Briefs state the factual and legal grounds, comply with LR 5.1, and do not exceed 25 pages unless the Court orders otherwise. | `eval.yaml` `params.page_limit: 25` (DEF-LEN-001, every engine; counts every page, the stricter reading). | Same PDF, p. 14; verified 2026-10-14. |
| E.D. Tenn. LR 7.1(a) | The opening brief and any supporting material are filed with the motion. | The memorandum is the supporting brief; the motion is a separate filing (gap 2). | Same PDF, p. 14. |
| Fed. R. Civ. P. 7(b)(1), 10(a) | A motion in writing, stating its grounds and the relief sought; a caption with the court's name, the title of the action, the file number and the paper's designation. | `front` in `typst/layout.yaml`. | https://www.law.cornell.edu/rules/frcp/rule_7, `rule_10`; verified 2026-10-14. |
| Fed. R. Civ. P. 11(a) | Signed by an attorney of record, with address, e-mail and telephone. | `closing`. | https://www.law.cornell.edu/rules/frcp/rule_11. |
| Fed. R. Civ. P. 5(d)(1)(B), 5(b)(2)(E) | No certificate of service is needed for a paper served through the court's electronic-filing system. | The certificate is optional: it renders when the frontmatter carries `certificate` (the exemplar has one, one party served by mail). | https://www.law.cornell.edu/rules/frcp/rule_5; verified 2026-10-14. |

## Layout

The generic FRCP brief with E.D. Tenn.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/tned-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Court name and division (the sample's, in capitals) centered in bold; then the caption as the first exemplar sets it: each party's names in capitals, a blank line, its designation half an inch in; "v." at the margin, a blank line from each; `No.` and the file number at the right, centered on the parties' height.
- The title in bold capitals, centered between two rules across the page (the first exemplar's).
- Body double-spaced (24 pt), first-line indent 0.5 in on every paragraph; paragraphs are not numbered.
- Headings single-spaced, bold, 12 pt above and below, kept with what follows; the author types each number: level 1 centered capitals; level 2 at the margin, its later lines hung half an inch; level 3 half an inch in; level 4 an inch in, italic.
- Block quotations single-spaced, half an inch in on both sides, 12 pt from the text. Footnotes 12 pt, single-spaced, 7 pt apart.
- Signature block at 3.25 in, kept whole with the last paragraph: "Respectfully submitted,", the firm, "By: /s/", each attorney's name with the BPR number (LR 5.1) and contact lines, whom they represent in italics, a blank line between the groups.
- Certificate of service (optional) on its own page: "CERTIFICATE OF SERVICE" centered bold underlined (both exemplars), the double-spaced text, the persons served an inch in, the "By: /s/" lines at 3.25 in.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`; `case_label` (default "No."); `division` (optional); `caption.parties` (list of `{names, designation}`; "v." between parties); `brief_title`; `signature` (`firm` (a list of lines, optional), `by`, `attorneys` (list of `{name, bpr, lines}`), `role` (optional)); `certificate` (optional: `text`, `recipients` (list of lists of lines), `by`).
- Body: `#` level 1, `##` level 2, `###` level 3 headings (their numbers typed); paragraphs; `>` block quotations; footnotes as `[^n]` with `[^n]: text`.
- Star-page citations (`at *2`) must be escaped as `at \*2`, or markdown reads the asterisk as emphasis.
- Not supported: a table of contents or authorities (not required under LR 7.1(b) for a brief this length).

## Known gaps and open choices

1. **Exemplars.** Two filers (`usage/SOURCE.md`); tier 2 is judged against both (below).
2. **Motion not produced.** A Rule 12(b) motion is a separate filing (Fed. R. Civ. P. 7(b)(1)); this template produces the memorandum only.
3. **Typeface.** LR 5.1 names no typeface, only the 12-point minimum. Times New Roman (vendored), the default per `docs/FONTS.md` and the exemplars' face.
4. **Caption.** Follows the first exemplar (no rules beside the parties; the title between two rules). The second filer sets the file number and the judge at the top right and a rule under the caption only: tier 2, conventions differ between the filers (ACCEPTED). The earlier template's ruled party column was neither filer's.

## Review of the rendered pages (Gate 2 record, 9 of 9 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx, 239/239 lines), so one row per page covers all three. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`); this pod has no image viewer. DEF-COVER-002 (page 1 against the first exemplar: order, alignment, rules) passes on all three engines.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division; caption (parties in capitals, "v.", the file number at the right); the title between two rules on two lines; opening paragraph; I. INTRODUCTION | OK. |
| 2 | II. FACTUAL BACKGROUND, the class definition as a single-spaced quotation, footnotes 1 and 2 | OK. |
| 3 | III. STANDARD OF REVIEW, IV. ARGUMENT, heading A. (two lines, the second hung) | OK. |
| 4 | Argument; footnote 3 with its web address broken after a "/" | OK. |
| 5-6 | Argument, the string citation | OK. |
| 7 | Heading B. (two lines), argument, footnote 4 whole at the foot | OK. |
| 8 | Argument, V. CONCLUSION, its paragraph and the signature block (firm, "By: /s/", two attorneys with BPR numbers, the role in italics), not split | OK. |
| 9 | Certificate of service on its own page: title, text, the person served, the "By: /s/" lines | OK. |

Tier 2 against the exemplars: the first exemplar justifies its text; the second underlines its headings; ours does neither (ACCEPTED, conventions differ between the filers, the body ragged on the cross-engine model). A paragraph that continues after a quotation ("*Id.* ¶ 22. While ...") is indented in ours, flush in the first exemplar: markdown cannot mark a continuation (ACCEPTED).

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief --engine typst   # 12 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief --engine latex   # 15 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief --engine docx    # 16 passed, 0 failed
```

`tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has none, so it does not run here.

## Engines

typst (primary): `typst/main.typ` -> `typst/tned-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.18). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx. BLOCKED: none.
