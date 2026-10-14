# lawd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Louisiana (`lawd`).
Folder: `courts/fifth-circuit/louisiana/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-louisiana-dental-implant-lab-6-26-cv-00025-complaint.pdf` (1 filer, see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-ldil-complaint.md`: the whole filed text (9 pages), the comparison chart not transcribed |
| render | ok: `samples/OUTPUT-ldil-complaint.pdf`, 5 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> samples/INPUT-ldil-complaint.md`) |
| overlay | ok: `samples/OVERLAY-ldil-complaint.pdf` and `OVERLAY-ldil-complaint.txt` (`sh tools/overlay.sh <this dir> ldil-complaint`) |
| pages reviewed | 5 of 5 (every page rendered at 60 dpi and viewed after the last template change) |
| tools/check.sh | not run: that script expects a court folder with `court.json` and `rules.md`, and this doc-type folder has neither (the brief forbids editing `tools/`). Render and overlay are the gates here. |

File names: the tools write `OUTPUT-` and `OVERLAY-` names (the convention in `tools/render.sh` and `tools/overlay.sh`), not the `<id>.pdf` and `<id>-overlay.pdf` names in the brief. The sample is `INPUT-<id>.md`, which the tools expect.

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRCP 10(a) | The caption has the court's name, a title, a file number, and a Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10. | `caption()`, the court title, `title` (frontmatter). |
| FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every body paragraph is numbered by the template (`lawd-complaint()`); headings and lists are not numbered. The sample does not type numbers. |
| LR 10.1 (W.D. La. Local Civil Rules, Ver3 030526, https://www.lawd.uscourts.gov/sites/lawd/files/UPLOADS/CivilCrimLRs.Barbara.updated.Ver3.030526.ppm.pdf, linked from https://www.lawd.uscourts.gov/local-rules) | Papers on 8 1/2 x 11 paper, paginated, double spaced except footnotes and quotations. The caption includes the division, the district judge and the magistrate judge assigned. | `page` (letter, numbered footer), `body-leading` (double spacing), `caption()` (JUDGE and MAGISTRATE JUDGE lines, blank until assigned), `division` (checked against the five W.D. La. divisions). |
| LR 10.1, last paragraph | An executed civil cover sheet (JS-44) accompanies the initial pleading. | Not produced (a separate filing). |
| LR 11.1 | The signing attorney's name, address, telephone and Attorney Identification Number under the signature. | `signature()` prints the lines the sample gives; the template does not check the AIN. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Rule 7.1 disclosure statement; the summons.

## Layout

- Court title: three lines, centered caps, from the division given in the frontmatter.
- Caption: parties on the left, one asterisk per line of the party column in the middle (the count is measured from the rendered height, so the asterisks follow the text), CIVIL ACTION NO. and the judge lines on the right.
- Title: centered bold caps. Headings: centered bold caps (level 1), bold sub-heading (level 2), bold italic (level 3), each with one blank line above.
- Body: paragraphs numbered 1, 2, ... with a 0.5 inch first-line number and double spacing. Sub-lists lettered (a), (b), ... Prayer items lettered A, B, ... (a `:::upper` directive before the list). A paragraph not numbered (the lead-in, the WHEREFORE clause, a bracketed note) is marked `:::unnumbered`.
- Every block is rounded up to whole 24 pt lines (`on-grid`), so no paragraph overlaps the line before it. Typst leaves the leading out of a paragraph's measured height, which is why the rounding is needed (measured, see the review below).
- Signature block: date at the left, "Respectfully submitted," and the lines at the right half.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `division` (one of Alexandria, Lafayette, Lake Charles, Monroe, Shreveport), `caption.parties` (list of `{names, designation}`), `caption.separator` (for example `v.`), optional `judge`, `magistrate`, `legend`, `title`, `signature` (`date`, `lines`).
- Body chunks are separated by blank lines. `# ` is a level 1 heading, `## ` level 2, `### ` level 3. A chunk that is a single line starting with `N. ` is a numbered paragraph in the filing; the sample writes the text without the number. A chunk of lines starting with `1. ` or `- ` is a list; a `:::upper` or `:::unnumbered` chunk applies to the next chunk.
- Not supported: tables, footnotes, block quotations (single spaced in filings), images (a bracketed italic note stands in for them).

## Known gaps and open choices

1. **Font.** The rule set names no font and no size, and EB Garamond is the only font vendored in `fonts/`. The exemplar is Times New Roman 12 pt. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar. Whether a larger size is wanted is a question for David (a vendored Times-metric font would remove the difference).
2. **Caption style.** The template uses the asterisk column (the style of the W.D. La. Alexandria filing in `../../motion-brief/`). The exemplar uses no asterisks (its party column is closed by `v.`). Both are seen in W.D. La. filings; recorded as ACCEPTED.
3. **Judge lines.** The exemplar's caption has no judge names. LR 10.1 asks for the judges assigned, and a new complaint has none, so the template prints blank JUDGE lines. This follows the rule, not the exemplar.
4. **Page count.** The exemplar is 9 pages; the render is 5. The 9 pages include a comparison chart (two pages, not transcribed) and the filing's own page breaks. The sample carries the full filed text.
5. **One exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. A second candidate was checked but not stored (the brief asks for one exemplar per doc type): Trove Brands, LLC v. Rumi, LLC, 6:25-cv-01580 (W.D. La., Doc. 1, filed 2025-10-21, 16 pages, Times/Tahoma; https://storage.courtlistener.com/recap/gov.uscourts.lawd.214213/gov.uscourts.lawd.214213.1.0.pdf). Tier 2 is therefore not judged against two filers yet.
6. **Signature lines.** The template does not check the Attorney Identification Number that LR 11.1 requires. The exemplar's signature block gives no AIN, so the sample does not supply one either (it is a filer deviation, not a template choice).
7. **Justification.** Body text is left aligned, not justified. The exemplar's alignment is not recoverable from its text layer; this is a tier-2 choice, not asserted.

## Review of the rendered pages

Every page was rendered at 60 dpi and viewed after the last template change.

- Page 1: court title, caption (party column, asterisks, CIVIL ACTION NO., blank JUDGE and MAGISTRATE JUDGE lines), title, lead-in, the first three paragraphs. Pass.
- Page 2: heading JURISDICTION AND VENUE, paragraphs 4 to 6, lettered sub-items (a) to (g) inside the margin, (h) on page 3. Pass (an earlier build pushed the sub-items past the right margin; fixed).
- Page 3: paragraphs 6 to 12, THE PATENT-IN-SUIT and DEFENDANT'S INFRINGEMENT headings with a blank line above, the italic note in place of the chart. Pass.
- Page 4: paragraphs 13 to 20, DAMAGES, PRAYER FOR RELIEF heading and the WHEREFORE clause (unnumbered), item A and the start of B. Pass.
- Page 5: prayer items B (cont.) to H, JURY DEMAND (paragraph 21), date, signature block. No heading stranded at the foot of a page. Pass.
