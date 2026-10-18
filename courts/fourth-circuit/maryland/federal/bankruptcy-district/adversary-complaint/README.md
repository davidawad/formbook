# mdb: adversary-complaint

Doc type: **adversary complaint** (the pleading that starts an adversary proceeding, Fed. R. Bankr. P. 7001) in the United States Bankruptcy Court for the District of Maryland (`mdb`).
Folder: `courts/fourth-circuit/maryland/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-mdb-adversary-complaint-kapitus2600188.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-mdb-adversary-complaint-kapituscomplaint.md` (an abridged transcription, see "Transcription") |
| render | ok: `usage/OUTPUT-mdb-adversary-complaint-kapituscomplaint.typst.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-kapitus-complaint.pdf` and `usage/OVERLAY-kapitus-complaint.txt` (13 sample pages paired with 19 exemplar pages) |
| pages reviewed | 13 of 13 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the repo's role convention (`INPUT-` for markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf/.txt` by name.

## Governing rules

| Source | Requirement | Where it is in the template |
|---|---|---|
| Local Bankruptcy Rule 9004-1 (Ver. 25.01, Dec. 1, 2025, printed p. 66), https://www.mdb.uscourts.gov/files/localrules.pdf, fetched 2026-10-14 | Papers filed by an attorney: legible; at least a one-inch margin on each side; 12-point or larger type for text, 10-point or larger for footnotes. | `page-margin = 1in`, `type-size = 12pt`; footer also 12 pt (no footnotes in the template). |
| Local Bankruptcy Rule 9004-1, text checked 2026-10-14 in the PDF of the same URL (p. 66) | Typeface: none named. The rule requires "12 point or larger font for text", and names no face. | `font-family = "EB Garamond"` kept (see Known gaps, item 2). |
| Fed. R. Bankr. P. 9004(a), (b), https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14 | (a) clearly legible. (b) caption: court's name; the case's title; case number and, if appropriate, adversary-proceeding number; a brief designation of the document's character. | `caption` (court lines, party block, case number, adversary number) and the title line. |
| Local Rule 9013-1(a) (p. 76) | Caption with the court's name, the case name, the case number, the chapter, and a descriptive title; in an adversary, the names of the plaintiff and the defendant. | `caption.in_re`, `caption.parties`, `chapter`, `title`. |
| Fed. R. Civ. P. 10(a), (b) (made applicable to adversary pleadings by Fed. R. Bankr. P. 7010), https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14 | (a) caption with the court's name, a title, a file number and a Rule 7(a) designation. (b) claims in numbered paragraphs. | Allegations numbered by the template (`allegations()`); the caption as above. |
| Fed. R. Bankr. P. 7010 | Form of pleadings in an adversary proceeding. | **Not verified verbatim.** The Cornell page for Rule 7010 did not yield its text in this pass; the Rule 10 reference above is taken from the rule's title and the common reading, and must be checked before the template is relied on. |
| Local Rule 9013-3(b) (p. 77) and Appendix H § IV.B (p. 204) | Pleadings initiating an adversary proceeding under Rule 7001 are excepted from the proposed-order requirement. | No proposed order is produced for this doc type. The 3-inch top margin in Appendix H § IV.B.1.a applies to proposed orders only, so it does not apply here. |
| Local Rule 7003-1 (p. 55) | A cover sheet is required for an adversary filed by a party who is not represented by an attorney. | Not produced: the template is for counsel-filed complaints. |
| Local Rule 7004-1 (p. 55) and Fed. R. Bankr. P. 7004 | Summons and proof of service. | Not produced: the summons and the proof of service are separate filings. |

Not produced by this template (separate filings, not part of the complaint): the summons; the adversary cover sheet for a pro se plaintiff (LR 7003-1); the proof of service (LR 7004-1); any disclosure statement required with the first filing.

## Layout

- Letter size; 1-inch margins; EB Garamond 12 pt; double spacing on a 24 pt pitch (`pitch`), every block rounded up to the pitch so headings and paragraphs stay on the same grid.
- Court name lines and the division (from the frontmatter), centered and bold, then the caption: a party column closed by a ")" column, and a right column with the case number, chapter and adversary number.
- Title in bold caps between two rules, the lead-in paragraph, then the body.
- Numbered allegations (`1.`, `2.`, ...) with a first-line indent; section headings centered and bold, with underlined caps for the first level.
- Block quotations (quoted contract or certification) are single-spaced and indented, and are not numbered.
- The prayer lead-in ("WHEREFORE ...") is unnumbered; prayer items are lettered `A.`, `B.`, ...
- Date, then "Respectfully submitted," and the firm and signer block at the right half of the page. The signature block does not split.
- Page number centered at the foot of each page. The CM/ECF header line ("Case 26-00188 Doc 1 Filed ... Page n of 19") is added by the court's system, not by the filer, so the template does not produce it.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court` (list of lines), `division` (optional), `caption.in_re` (optional: `names`, `designation`), `caption.parties` (list of `names`, `designation`; "v." is inserted between parties), `case_number`, `chapter` (optional), `adv_number` (empty leaves a blank), `title`, `lead_in` (unnumbered paragraph, optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = section heading (centered, bold, underlined caps), `##` = sub-heading (centered, bold), `###` = run-in sub-heading (bold italic). A plain chunk is one numbered allegation. A `>` chunk is an unnumbered block quotation. A list is lettered (`A.`).
- Not supported: tables, footnotes, raw typst. The sample must not number its own paragraphs; the template numbers them.

## Transcription (what the sample contains)

The sample is an abridged transcription of Doc 1 (19 pages) and renders to 13 pages:

- Caption, title, lead-in, and the signature block, transcribed from the exemplar.
- Jurisdiction and Venue (exemplar ¶¶ 1-6) and Parties (¶¶ 7-10), with the Debtor's street address removed. The exemplar gives it as the debtor's residence; the sample keeps "a resident of the State of Maryland" only.
- Facts I-IV (¶¶ 11-47), abridged. The Use of Proceeds Certification is a block quotation, trimmed. Some multi-part representations in ¶¶ 23-27 are condensed into prose.
- Count I (§ 523(a)(2)(A)), Count II (§ 523(a)(2)(B)), Count IV (§ 523(a)(6)), and the prayer. **Count III (§ 523(a)(4), exemplar ¶¶ 68-80) is omitted.**
- Footnotes 1-7 of the exemplar are omitted. Footnote 1 is a reservation of rights; footnotes 2-7 are citations to the Agreements' sections, which the sample keeps where it keeps the text they support.
- Exhibit references are kept as written.

Paragraph numbers are not transcribed: the template numbers the allegations. The sample's numbers match the exemplar's for ¶¶ 1-10 only; after that the sample merges and drops paragraphs, so its numbers differ from the filed ones.

## Known gaps and open choices

1. **Only one exemplar; tier 2 is not met.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `court=mdb`, `type=r`, adversary complaints) also found Roman Catholic Archbishop of Baltimore (Adv. 26-00041, Official Committee of Unsecured Creditors, 16 pp., counsel Richard L. Costella) and Hughes Construction Management, Inc. v. Marrero Astacio (Adv. 26-00115, 18 pp.). Neither was saved, because the brief asks for one exemplar per doc type. A second filer should be collected before this doc type is judged against tier 2.
2. **Typeface: no court-named face; EB Garamond kept.** Local Rule 9004-1 requires 12-point or larger font and names no typeface, and Fed. R. Bankr. P. 9004 names none either. Per `docs/FONTS.md` ("No face named" row), the template keeps EB Garamond. The exemplar is in Times New Roman, which is the filer's choice, not a rule. The difference is visual only: EB Garamond has a smaller x-height at 12 pt, so the text looks smaller than the exemplar. Substitute: none (`EB Garamond` is the vendored face).
3. **Caption style.** The exemplar uses a ")" column, and the template follows it. The motion-brief exemplar in the same court uses an asterisk column; both are seen in this court. Recorded as ACCEPTED.
4. **Double spacing is a convention, not a rule.** Local Rule 9004-1 sets no line spacing; the exemplar is double-spaced, and the template follows it.
5. **Certificate of service.** None is required for the complaint itself; service is by summons (see the table above). None is produced.
6. **Adversary number is blank.** The clerk assigns it; the template leaves the line blank when `adv_number` is empty.

## Overlay

`usage/OVERLAY-kapitus-complaint.pdf` is the red/blue comparison: red is our render, blue is the filed exemplar. Pages are paired by shared words (`tools/overlay.sh`); the word overlap per page is 57%-94%, and the page map is in `OVERLAY-kapitus-complaint.txt`. The overlay was built against the filed exemplar fetched from the SOURCE.md URL (the PDF is not in this snapshot). Because the sample is abridged and the template is in EB Garamond, the overlay shows the difference in font and in the omitted Count III. It is a diagnostic, not a score.

## Review of the rendered pages (Gate 2 rows)

Every page was rendered at 60 dpi and viewed. Defects found on the first renders and fixed:

- Every paragraph and heading overprinted the last line of the block before it. Typst does not count a paragraph's trailing leading in its height. Fixed by rounding each block up to the line pitch (`on-grid`), the same approach as the ca9 complaint template.
- Section headings rendered at the default heading size. Fixed: 12 pt, bold.
- The blank "Adv. Pro. No." had no line. Fixed: an underlined blank.
- The prayer's "WHEREFORE" paragraph was numbered as allegation 78. Fixed: unnumbered.

| Page | Content | Result |
|---|---|---|
| 1 | Court lines, division, caption, title, lead-in, Jurisdiction and Venue ¶¶ 1-5 | Pass. Caption on one grid; no spill. |
| 2 | ¶¶ 6-13, Parties, Facts I | Pass. |
| 3 | ¶¶ 14-17, Facts II (heading), A. Applications | Pass. Heading on its own line, not overprinted. |
| 4 | B heading, ¶¶ 18-22, C heading; the Use of Proceeds block quotation begins | Pass. Quotation single-spaced and indented. |
| 5 | Use of Proceeds quotation completes, ¶¶ 23-26 | Pass. |
| 6 | ¶¶ 27-32, Facts III heading | Pass. |
| 7 | ¶¶ 33-40, Facts IV heading | Pass. |
| 8 | ¶¶ 41-50, Count I heading | Pass. Count heading kept with its first paragraph. |
| 9 | ¶¶ 51-57 | Pass. |
| 10 | ¶¶ 58-64, Count II heading | Pass. |
| 11 | ¶¶ 65-74, Count IV heading | Pass. |
| 12 | ¶¶ 75-77, Prayer heading, unnumbered WHEREFORE, items A-C | Pass. |
| 13 | Prayer items D-E, date, signature block | Pass. The signature follows the prayer, not alone on a page. |

Open layout item: none on the complaint's pages.

## Engines

The same markdown renders through three engines. Typst (`typst/`) is the reference. Only the docx engine is built in this pass; the latex engine is not built for this doc type.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-mdb-adversary-complaint-kapituscomplaint.typst.pdf` (13 pp) | reference |
| docx | `OUTPUT-mdb-adversary-complaint-kapituscomplaint.docx` and `OUTPUT-mdb-adversary-complaint-kapituscomplaint.docx.pdf` (13 pp, LibreOffice) | rendered; BLOCKED lines below |

```sh
sh docx/make-reference.sh     # rebuilds docx/reference.docx from pandoc's default reference document
sh tools/render.sh --engine docx courts/fourth-circuit/maryland/federal/bankruptcy-district/adversary-complaint usage/INPUT-mdb-adversary-complaint-kapituscomplaint.md
```

**docx** (`docx/reference.docx`, `docx/make-reference.sh`, `docx/mdb-adversary-complaint.lua`).

- *Matches typst:* EB Garamond 12 pt (the PDF embeds Regular, Bold and BoldItalic only); body double-spaced on a 24 pt exact pitch with a 0.5 in first-line indent; letter page with 1-inch margins; the cover (court lines, division, the caption with its ")" column and the rule under the debtor line, the case number, chapter and adversary line on the right, the title in capitals between two rules, the lead-in paragraph); numbered allegations 1., 2., ...; level-1 headings centered, bold, underlined, in capitals; level-2 headings centered and bold; level-3 headings bold italic at the margin; the block quotation single-spaced and indented, with its I. and II. labels typed as text; the prayer lettered A. to E.; the signature block at 3 in, kept together; a centered page number on every page, the cover included.
- *Differs (tier 2):* body lines break at other words, so some pages carry a line more or less than typst and a few page breaks move (page 4 onward, most visibly at pp. 4, 12 and 13). Prayer item C is split between pp. 12 and 13 in the docx; typst keeps it whole on p. 12. The caption rule sits closer to the next party line than in typst.
- *Not verified:* the `.docx` has not been opened in Microsoft Word (no Word on this box). LibreOffice converts it without error, and it is a valid zip with well-formed XML parts (`unzip -t`, `xmllint` on every `.xml` and `.rels` part). Word may paginate slightly differently (docs/DOCX.md).
- *Gate status:* this court folder has no `checks.yaml`, so `tools/check.sh --engine docx` was not run and no pass stamp was written. The review is by eye.
- *Pages reviewed:* 13 of 13. Every page of `usage/OUTPUT-mdb-adversary-complaint-kapituscomplaint.docx.pdf` was rendered at 60 dpi and viewed beside the same page of the typst render, on the final build.
- *Build notes:* this box has no `unzip` or `zip`, so the reference build and the zip check used stand-ins outside the repo, built on the toolchain's `ziptool`. The first `soffice` run with a fresh profile exits 81; a wrapper retried it once.

BLOCKED: docx-word-open: not opened in Microsoft Word (not installed on this box); LibreOffice opens and converts the file without error.
BLOCKED: gates-0-3: no `checks.yaml` in this court folder, so the docx gates (`tools/check.sh --engine docx`) were not run; the Gate 2 review above is by eye.
