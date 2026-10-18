# U.S. Bankruptcy Court, N.D. Alabama (alnb): motion with memorandum

- Court: `alnb`, United States Bankruptcy Court for the Northern District of Alabama (`courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district/`)
- Doc type: `motion-brief` (a motion in an adversary proceeding, with the argument set out in the motion; Fed. R. Bankr. P. 9013, 9014, 7012(b))
- Engine: typst (primary). `latex/` and `docx/` are not built for this doc type.
- Exemplars: `usage/` holds two public filings from different filers (see `usage/SOURCE.md`). The overlay uses the first one (`FILED-EXAMPLE-motion-brief.pdf`, the United States' motion to dismiss, 11 pp.), which is the tier-2 primary. The second is Wright (defendant NCS's Rule 12(b)(6) motion, 8 pp.).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...` and calls `alnb-motion-brief`. |
| `typst/alnb-motion-brief.typ` | Template. Court title, caption, title, Roman-numeral and lettered section headings, unnumbered body paragraphs, footnotes, signature block, certificate of service. Parameter block at the top. |
| `usage/INPUT-motion-brief.md` | Transcription of the Dombrowski motion, all 11 pages of text (frontmatter + body). Frontmatter fields: `court`, `caption` (list of `left`/`right` line blocks), `title`, `signature` (`date`, `lead`, `signer`, `lines`, `of_counsel`), `certificate` (`text`, `served` as a list of party line-lists, `signer`, `signer_lines`). |
| `usage/OUTPUT-motion-brief.typst.pdf` | `sh tools/render.sh <dir> usage/INPUT-motion-brief.md`, where `<dir>` is this folder. 9 pages. |
| `usage/OVERLAY-dombrowski-motion-brief.pdf`, `.txt` | `sh tools/overlay.sh <dir> dombrowski-motion-brief`. Red = our render, blue = filed exemplar, black = both. `.txt` is the page map. |
| `usage/` | Two filed motions (Dombrowski 11 pp.; Wright 8 pp.) and `SOURCE.md`. |

## Governing rules

Retrieved 2026-10-14. Text checked on Cornell LII; the "as amended" dates are the ones printed on those pages.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Fed. R. Bankr. P. 9013(a)-(b) (<https://www.law.cornell.edu/rules/frbp/rule_9013>; as amended Apr. 2, 2024, eff. Dec. 1, 2024) | "A request for an order must be made by written motion unless" the request is made in a hearing or the rule otherwise allows. "A motion must state its grounds with particularity and set forth the relief or order requested." | The motion's opening paragraph and WHEREFORE prayer; the title |
| Fed. R. Bankr. P. 9014(a) (<https://www.law.cornell.edu/rules/frbp/rule_9014>; as amended Apr. 2, 2024, eff. Dec. 1, 2024) | In a contested matter, relief "must be requested by motion." | Same as 9013 |
| Fed. R. Bankr. P. 7012(b) (<https://www.law.cornell.edu/rules/frbp/rule_7012>; as amended Apr. 2, 2024, eff. Dec. 1, 2024) | "Fed. R. Civ. P. 12(b)–(i) applies in an adversary proceeding." So a Rule 12(b)(1) or 12(b)(6) motion is made under the Civil Rule as applied here. | The Rule 12 basis in the opening paragraph and the argument headings |
| Fed. R. Bankr. P. 9004(a)-(b) (<https://www.law.cornell.edu/rules/frbp/rule_9004>; as amended Apr. 2, 2024, eff. Dec. 1, 2024) | A document must be clearly legible and must have a caption with (1) court name, (2) case title, (3) case number and, if appropriate, adversary-proceeding number, (4) a brief designation of the document's character. | `court` lines, `caption` (case and adversary numbers), `title` |
| N.D. Ala. Bankr. L.R. 1001-1(d) (<https://www.alnb.uscourts.gov/content/rule-1001-1-purpose-and-scope-rules>) | The local rules have an effective date of March 1, 2023. | Revision used for the local-rule check |
| N.D. Ala. local rules index (<https://www.alnb.uscourts.gov/court-info/local-rules-and-orders/local-rules>) | Lists the local rules by number; no rule on the form of papers, type size, margins or spacing was on the first page of the list. | No local format rule adopted |

Neither motion exemplar's caption, body or certificate is a rule text; the exemplars settle only what the rules leave open (heading style, caption layout, the signature block, the service list). The template's type size (12 pt), margins (1 in), double spacing and page-number footer are style choices, not rule requirements.

Gap: the 2023 local-rules PDF that `usage/SOURCE.md` cites as read in full was not reachable through the court's website in this run (the index page links HTML rule pages, not a PDF). No N.D. Ala. local rule that the template relies on was found on those pages. Local rule pages 2 and 3 of the index were not opened.

## Overlay

`usage/OVERLAY-dombrowski-motion-brief.pdf` pairs our nine pages with the Dombrowski motion (page pairs in `usage/OVERLAY-dombrowski-motion-brief.txt`). Word overlap per page runs from 37% to 91%. The pages that disagree most are our pages 7 and 8, which carry the end of the argument, the signature block, and the certificate; the filed certificate is on page 11 and the filed signature on page 10.

Expected differences, by page:

- Page 1: caption, title and the opening paragraph agree in text. The caption's `)` column runs down every row; the filed caption uses the same column.
- Pages 2-6: headings (Roman numerals, letters) and body text agree in text. Footnote 1 is on page 7 of ours and on page 8 of the filed motion.
- Pages 7-8: argument end, WHEREFORE, signature block. The filed signature block is on its own page 10; ours sits on page 8 after the argument.
- Page 9: certificate of service. The filed certificate is on page 11.

Known differences that are not template faults:

- The ECF header ("Case 19-80069-CRJ Doc 6 Filed ...") is the court's stamp and is not reproduced. The Wright exemplar's running footer (the title and "Page n") is not reproduced in this template; see gaps.
- The filed text carries typos ("Dombrowksi", "121 F.35 at 589", "These representations and were made"). The sample reproduces them as filed.
- The filed Dombrowski caption places "Adv. Proc. No.: 17-80079-CRJ" beside the "Plaintiff," row; the sample does the same.

## Gaps

- **Italics not transcribed.** Case names and signals are italic in the filed motion. `pdftotext` cannot see italics, so the sample does not italicize them. The overlay cannot show this difference.
- **Certificate of conference.** The Wright motion has one (counsel's conferral and opposition statement, dated and signed). The template does not render one: nothing in the Dombrowski exemplar requires it, and no N.D. Ala. local rule requiring it was located in this run.
- **Running footer.** The Wright exemplar carries the document title and "Page n" in its footer. The template uses a page-number-only footer, as the adversary complaint does.
- **Second filer not overlaid.** The overlay tool pairs against the first `usage/*.pdf` only. The Wright motion is the tier-2 comparison for the caption (its `§` column and its ADVERSARY NO. line differ from Dombrowski's `)` column) and the signature block (`By:` line, OF COUNSEL block). It is compared by reading, not by overlay.
- **Case-number style.** Dombrowski uses `Case No.` on the first caption line; Wright uses `CASE NO:`. The sample follows Dombrowski.
- **No e-filing rules.** The court's CM/ECF filing requirements are not encoded (only the physical layout is).

[Court index](../README.md) | [Formbook index](../../../../../../README.md)

## Engines

- **typst** (primary): `typst/`, `usage/OUTPUT-motion-brief.typst.pdf` (9 pages).
- **docx**: `docx/` (`make-reference.sh` builds `reference.docx`; `alnb.lua` adds the court title, caption table, title, signature block and certificate of service with the served parties). Output `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice conversion, 10 pages, every page rendered and looked at).
- **latex**: not built for this doc type.

What matches the typst form (12 pt EB Garamond, 1-inch margins, letter, 24 pt exact body leading, half-inch first-line indent, unnumbered paragraphs, centered Roman-numeral headings and flush-left lettered headings with a 0.5-inch indent, footnotes, single-spaced caption and signature block, the certificate of service heading, centered page-number footer).

What differs:
- Pagination: 10 pages in the docx PDF against 9 in typst; the certificate's served-party list breaks across a page in the docx PDF. Measured on the LibreOffice PDF (`docs/DOCX.md`).
- Footnote text is 10 pt single-spaced; the typst footnote size is not set in the template, so it is not compared exactly.
- Italics from the body markdown are carried by pandoc; the caption and signature are plain text.

docx BLOCKED (not run; no fake PASS):
- Gate 0-3 (`sh tools/check.sh <court> --engine docx`): BLOCKED. This court has no `checks.yaml` (Gate 1) and no `reviews/` file (Gate 2), so `check.sh` exits 2 before measuring anything.
- Word: the `.docx` is not opened in Word; only the LibreOffice PDF was checked.
- Tooling: `tools/render-docx.sh` runs LibreOffice on a fresh profile per call, and LibreOffice exits 81 on the first conversion of a fresh profile. Rendering here used a retrying wrapper (outside the repo). Not a template fault.
