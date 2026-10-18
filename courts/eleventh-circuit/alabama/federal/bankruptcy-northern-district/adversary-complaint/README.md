# U.S. Bankruptcy Court, N.D. Alabama (alnb): adversary complaint

- Court: `alnb`, United States Bankruptcy Court for the Northern District of Alabama (`courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district/`)
- Doc type: `adversary-complaint` (commencing an adversary proceeding, Fed. R. Bankr. P. 7001 and 7003)
- Engine: typst (primary). `latex/` and `docx/` are not built for this doc type.
- Exemplars: `usage/` holds two public filings from different filers (see `usage/SOURCE.md`). The overlay uses the first one (`SAMPLE-alnb-adversary-complaint-bcicapitalvmontalbano2100015.pdf`), which is the tier-2 primary.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...` and calls `alnb-adversary-complaint`. |
| `typst/alnb-adversary-complaint.typ` | Template. Caption, title, numbered allegations, headings, WHEREFORE prayers, signature block. Parameter block at the top. |
| `usage/INPUT-alnb-adversary-complaint-bcicapitalmontalbano.md` | Transcription of the BCI complaint (frontmatter + body). Frontmatter fields: `court`, `caption` (list of `left`/`right` line blocks), `title`, `lead_in`, `consent`, `signature` (`date`, `signers`, `firm`, `address`, `contact`, `role`). |
| `usage/OUTPUT-alnb-adversary-complaint-bcicapitalmontalbano.typst.pdf` | `sh tools/render.sh <dir> usage/INPUT-alnb-adversary-complaint-bcicapitalmontalbano.md`, where `<dir>` is this folder. 6 pages. |
| `usage/OVERLAY-bci-capital-montalbano.pdf`, `.txt` | `sh tools/overlay.sh <dir> bci-capital-montalbano`. Red = our render, blue = filed exemplar, black = both. `.txt` is the page map. |
| `usage/` | Two filed complaints (BCI 7 pp.; Garner 3 pp.) and `SOURCE.md`. |

## Governing rules

Retrieved 2026-10-14.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Fed. R. Bankr. P. 7010 (<https://www.law.cornell.edu/rules/frbp/rule_7010>) | Fed. R. Civ. P. 10 applies in an adversary proceeding, except that the caption must substantially conform to the appropriate version of Form 416. | `caption` block, numbered allegations (Civ. R. 10(b)) |
| Fed. R. Bankr. P. 9004(a)-(b) (<https://www.law.cornell.edu/rules/frbp/rule_9004>; as amended Apr. 2, 2024, eff. Dec. 1, 2024) | 9004(a): clearly legible. 9004(b): a document must have a caption with (1) court name, (2) case title, (3) case number and, if appropriate, adversary-proceeding number, (4) a brief designation of the document's character. | `court` lines, `caption` (case and adversary numbers), `title` |
| Fed. R. Bankr. P. 7008(a) (<https://www.law.cornell.edu/rules/frbp/rule_7008>) | In an adversary proceeding, a complaint must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | `consent`, rendered as allegation 1 |
| N.D. Ala. Bankr. L.R. 1001-1(d) (<https://www.alnb.uscourts.gov/content/rule-1001-1-purpose-and-scope-rules>) | The local rules have an effective date of March 1, 2023. | Revision used for the local-rule check |
| N.D. Ala. local rules index (<https://www.alnb.uscourts.gov/court-info/local-rules-and-orders/local-rules>) | Lists the local rules by number (1001-1 through 3015-2 on page 1 of the list). No local rule on the form of papers, type size, margins or caption was on that page. | No local format rule adopted |

No N.D. Ala. local rule sets a typeface, type size, margin, line spacing, or page limit for a complaint. The template's type size (12 pt), margins (1 in), and double-spacing are style choices, following the exemplars (see the comment block at the top of `alnb-adversary-complaint.typ`).

Gap: the 2023 local-rules PDF that `usage/SOURCE.md` cites as read in full was not reachable through the court's website in this run (the index page links HTML rule pages, not a PDF). The rules above are the ones checked. Local rule pages 2 and 3 of the index were not opened.

## Overlay

`usage/OVERLAY-bci-capital-montalbano.pdf` pairs our six pages with the BCI complaint's seven pages (page pairs in `usage/OVERLAY-bci-capital-montalbano.txt`: ours p.1-3 with filed p.1-3, ours p.4 with filed p.5, ours p.5 with filed p.6, ours p.6 with filed p.7). Word overlap per page runs from 59% to 89%. Expected differences, by page:

- Page 1: caption, title and court lines agree. The consent allegation (1) is red only: it is rule-required and absent from the filed BCI text.
- Pages 2-5: numbered allegations, the `Facts` and `Count One`/`Count Two` headings, the WHEREFORE prayers and footnotes agree in text. Paragraph numbers are shifted by +1 from the filed text because of the consent allegation. The realleges references were adjusted to match (`paragraphs 1 through 26` and `1 through 30` in the sample; the filed text says `1 through 25` and `1 through 29`).
- Page 6: signature block. The filed signature sits at the bottom of page 7 after the second prayer.

Known differences that are not template faults:

- The ECF header ("Case 21-00015-TOM Doc 1 Filed ...") is the court's stamp and is not reproduced.
- The sample reproduces the filed text as transcribed, including the filed typos ("These representations and were made", "Plaintiff or about May 12, 2020"). They are the filer's, not ours.

## Template changes (this pass)

The template was present on master, but its render was broken, so it was changed. Three fixes, all in `typst/alnb-adversary-complaint.typ`:

- Each numbered allegation, the lead-in, the consent allegation and the WHEREFORE paragraphs are now blocks, not `par()` wrappers around cmarker output. The wrappers made the first line of one paragraph land on top of the last line of the one before it.
- Text edges are `"bounds"`. EB Garamond's default line box is shorter than its glyphs, so stacked caption rows and the court title overprinted each other.
- Body leading is 1.0 em (was 0.9 em, which measured about 19 pt pitch), now about 24 pt pitch, matching the comment's double-space target. Caption rows, the court title and the signature block use `single-leading` (0.4 em).

## Gaps

- **Consent statement is not in the filed exemplar.** The BCI complaint has no Rule 7008(a) statement, and neither does the Garner complaint. The template renders it because the rule requires it. The sample's text ("Plaintiff does not consent...") is a sample choice, not the filer's.
- **No certificate of service.** Neither exemplar has one. Service of a complaint runs under Rule 7004 (summons), not a certificate, so the template has no certificate block.
- **Second filer not overlaid.** The overlay tool pairs against the first `usage/*.pdf` only. The Garner complaint (3 pp., filed by debtor-plaintiff's counsel, with an `OF COUNSEL` block and a caption that carries the Chapter 13 debtors' masked SSNs) is the tier-2 comparison for the caption and signature. It is compared by reading, not by overlay.
- **Caption fill-ins.** The `Adv. Pro. No. 21-_____` line is a blank as in the filed text. The sample does not fill it.
- **No e-filing rules.** The court's CM/ECF filing requirements are not encoded (only the physical layout is).

[Court index](../README.md) | [Formbook index](../../../../../../README.md)

## Engines

- **typst** (primary): `typst/`, `usage/OUTPUT-alnb-adversary-complaint-bcicapitalmontalbano.typst.pdf` (6 pages).
- **docx**: `docx/` (`make-reference.sh` builds `reference.docx`; `alnb.lua` adds the court title, caption table, numbered allegations, consent statement and signature block). Output `usage/OUTPUT-alnb-adversary-complaint-bcicapitalmontalbano.docx` and `.docx.pdf` (LibreOffice conversion, 7 pages, every page rendered and looked at).
- **latex**: not built for this doc type.

What matches the typst form (12 pt EB Garamond, 1-inch margins, letter, 24 pt exact body leading, half-inch first-line indent, numbered allegations with the consent statement as paragraph 1, centered headings, centered page-number footer, single-spaced caption/court title/signature block, the ")" column of the caption, footnotes).

What differs:
- Pagination: 7 pages in the docx PDF against 6 in typst. Caption rows and the signature block take more space in Word-native tables and paragraphs; the page count is measured on the LibreOffice PDF (`docs/DOCX.md`).
- Footnote text is 10 pt single-spaced; the typst footnote size is not set in the template, so it is not compared exactly.
- The caption ")" column is a table column, so a wrapped party line repeats the ")" on each of its rows, as in typst; the table border is off by the reference's Table style.

docx BLOCKED (not run; no fake PASS):
- Gate 0-3 (`sh tools/check.sh <court> --engine docx`): BLOCKED. This court has no `checks.yaml` (Gate 1) and no `reviews/` file (Gate 2), so `check.sh` exits 2 before measuring anything. These belong to the court's eval-loop work, not to this engine.
- Word: the `.docx` is not opened in Word; only the LibreOffice PDF was checked.
- Tooling: `tools/render-docx.sh` runs LibreOffice on a fresh profile per call, and LibreOffice exits 81 on the first conversion of a fresh profile. Rendering here used a retrying wrapper (outside the repo). Not a template fault.
