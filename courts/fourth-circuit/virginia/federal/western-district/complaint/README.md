# vawd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Virginia (`vawd`).
Folder: `courts/fourth-circuit/virginia/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-extreme-driver-3-25-cv-00099-complaint.pdf` (9 pages, counsel, box caption) and `exemplars/FILED-EXAMPLE-moler-7-25-cv-00937-complaint.pdf` (33 pages, counsel, ")" caption). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-extreme-driver-complaint.md`: a full transcription of the 9-page complaint (all 40 numbered paragraphs, both counts, prayer, signature). |
| render | ok: `samples/OUTPUT-extreme-driver-complaint.pdf`, 8 pages, letter, typst 0.15.0, EB Garamond only (embedded), no warnings. |
| overlay | ok: `samples/OVERLAY-extreme-driver-complaint.pdf` and `.txt`. |
| pages reviewed | 8 of 8 (each page rendered at 60 dpi and viewed after the last layout change; page 1 re-checked after the final edit). |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` and read `INPUT-<id>.md` by default, so the sample and its outputs use those names (not `<id>.pdf`).

## Governing rules

The local rules set no type size, margin, line spacing, or page limit for a pleading. The layout values in the template are therefore the convention both exemplars show (tier 2), not a mandate. Every requirement below that is cited to a rule is tier 1.

| Rule | Kind | Requirement | Where in the template | Source (date verified) |
|---|---|---|---|---|
| Fed. R. Civ. P. 10(a) | M | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. The complaint's title names all the parties. | `court-title`, `caption-box` / `caption-parens`, the `case_label` and `case_number` lines, and the party names with designations. | https://www.law.cornell.edu/rules/frcp/rule_10 (2026-10-14) |
| Fed. R. Civ. P. 10(b) | M | Claims go in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered 1, 2, ...; headings, lists and the WHEREFORE clause are not. | same |
| Fed. R. Civ. P. 11(a) | M | Every pleading must be signed by an attorney of record, who states the signer's address, e-mail address and telephone number. | `signature-block`: the e-signature line, the name, the State bar number, the firm, the address, the telephone and the e-mail. | https://www.law.cornell.edu/rules/frcp/rule_11 (2026-10-14) |
| W.D. Va. Local Rule 11(a) | M | All pleadings and motions include the attorney's office address, telephone number, e-mail address, and bar identification number. | `signature-block` (the same lines as Rule 11(a); the bar number is printed as "Virginia State Bar No."). | https://www.vawd.uscourts.gov/sites/Public/assets/File/court/local_rules.pdf, Rule 11(a) (Rule 11 last revised 2023-10-01; the rules PDF's latest revision entry is 2025-10-01, rule 4 and 12) (2026-10-14) |
| W.D. Va. ECF procedures, para. 5(a) | M (clerk's procedure) | A PDF created from a word processor is flattened and text searchable; scanned PDFs are not the preferred form. | The render is a typst text PDF with embedded fonts (pdffonts: EBGaramond, `Identity-H`, embedded and subset); pdftotext returns the text. | https://www.vawd.uscourts.gov/sites/Public/assets/File/court/ecfprocedures.pdf (revised 2025-10-25) (2026-10-14) |
| Fed. R. Civ. P. 5.2(a) | A | Redact SSNs, taxpayer numbers, birth dates, minors' names, and account numbers. | Not a template rule. The sample has none of these (the sample is a public filing, and the author checks it). | https://www.law.cornell.edu/rules/frcp/rule_5.2 (2026-10-14) |
| Fed. R. Civ. P. 10(c) | C | A written instrument attached as an exhibit is part of the pleading. | Not produced. Exhibits are separate PDFs filed with the complaint. | https://www.law.cornell.edu/rules/frcp/rule_10 (2026-10-14) |

Not produced by this template (separate filings, not part of the complaint):
- Civil cover sheet (Form JS 44). The exemplars attach it as a separate document.
- Fed. R. Civ. P. 7.1 disclosure statement. Rule 7.1(a)(1) requires it from a nongovernmental corporate party, and the Extreme Driver exemplar is one. It is a separate filing.
- Summons (AO 440).

No local rule or standing order on pleading format was found. The local rules PDF (revised 2025-10-01) contains no typeface, margin, spacing, or page-limit rule; the ECF procedures contain none either. The court's standing-order index lists appointment and assignment orders only; I did not read every judge's chambers practices.

## Layout (tier 2: the convention both exemplars show)

- Letter, 1-inch margins. Page number centered at the foot of each page.
- Body: EB Garamond 13 pt (see Known gaps). Double spacing: a 27.6 pt baseline pitch, which is the pitch measured on both exemplars (Word double spacing for 12 pt Times).
- Court title in three centered lines, plain capitals: UNITED STATES DISTRICT COURT / WESTERN DISTRICT OF VIRGINIA / the division.
- Caption: `caption.style: box` (the party block closed by a rule at its right and bottom, the file number opposite; Extreme Driver) or `caption.style: parens` (a column of ")" marks, with the file number below; Moler). Both are supported. The ")" marks follow a name that wraps onto two lines.
- Numbered paragraphs: first-line indent 0.5 in, the number, then the text. Lines are ragged right; there is no extra space between paragraphs.
- Section headings (`#`): centered, bold, capitals. Count headings (`##`): centered, bold. Sub-headings (`###`): bold, left.
- Prayer items (a list): lettered a., b., ... with a hanging indent.
- Signature: "DATED:" at the left margin; the signature block from 3.25 in, starting with "Respectfully submitted," the firm, "By: /s/" and the name, then the bar number and the contact lines.

## Markdown contract (for samples)

The sample is one `.md` file: YAML frontmatter, then the body.

Frontmatter:
- `case_number` (required): the file number, e.g. `"3:25cv99"`.
- `case_label` (optional, default `Civil Action No.`): the label before the number.
- `division` (required): the division, printed in capitals in the court title.
- `caption` (required): `style` (`box`, the default, or `parens`) and `parties`, a list of `{names: [...], designation: "..."}`. "v." is printed between the parties. A name is one line of text (it may wrap).
- `title` (optional): a title printed in capitals under the caption (for example the "CLASS ACTION COMPLAINT" of the Moler exemplar). Extreme Driver has none.
- `lead_in` (optional): the unnumbered introductory paragraph before the first heading.
- `date` (required): the date printed after "DATED:".
- `signature` (required): `signer` (the name, printed twice: after "By: /s/" and again under it, as the exemplar does), `firm` (lines above "By:", e.g. the party name), and `lines` (the bar number, the counsel role, the firm, the address, the telephone, the fax, the e-mail).

Body:
- `# Heading`: a centered caps section. `## Heading`: a centered bold sub-heading (use for "COUNT I" and its title). `### Heading`: a bold left sub-heading.
- Each blank-line-separated paragraph is numbered 1, 2, 3, ... by the template. Do not type the numbers.
- A paragraph right after a heading whose text contains "PRAYER" (the WHEREFORE clause) is unnumbered.
- A markdown list (`1.`, `2.`, ...) is lettered a., b., ... by the template.
- Not supported: tables, footnotes, raw typst.

## Overlay (`samples/OVERLAY-extreme-driver-complaint.pdf`)

Red is our render; blue is the filed exemplar (Extreme Driver); black is where both agree. Pages are paired by shared words, so a page's pair can differ slightly where the sample's line breaks fall differently. The map (`.txt`):

| Ours | Filed (paired by text) | Word overlap |
|---|---|---|
| p.1 | p.1 | 86.6% |
| p.2 | p.2 | 69.8% |
| p.3 | p.3 | 63.1% |
| p.4 | p.4 | 55.4% |
| p.5 | p.5 | 86.4% |
| p.6 | p.7 | 74.4% |
| p.7 | p.8 | 62.2% |
| p.8 | p.9 | 53.5% |

The overlay is a diagnostic, not a score. It shows the difference in position, not in quality. Ours is 8 pages to the filed 9: the filed signature block sits alone on page 9 (its prayer ends on page 8), and ours sits with the prayer on page 8. The overlay tool writes its pages at 240 by 311 pt (its image density setting); the page images inside are complete and legible at higher zoom. The tool is shared (`tools/overlay.sh`) and was not changed.

## Gate 2: page review (each page viewed)

- p.1: court title, boxed caption with the file number on the right, lead-in, and the start of jurisdiction. Numbers 1 to 3. Pass.
- p.2: "THE PARTIES" and "FACTS" centered; numbers 4 to 11; the sub-heading "Plaintiff and Plaintiff's Patented Technology" bold at the left. Pass.
- p.3: numbers 12 to 16 on the page; no heading at the foot. Pass.
- p.4: numbers 17 to 21; the sub-heading "Defendant Iron Force's Infringement of the '591 Patent" is mid-page, kept with paragraph 18. Pass.
- p.5: numbers 22 to 28; the sub-heading "Defendant Montana Post's Infringement of the '591 Patent" is mid-page, kept with paragraph 24. Pass.
- p.6: number 29; "COUNT I" and its title centered; numbers 30 to 36; "COUNT II" and its title on the page. Pass.
- p.7: numbers 37 to 40; "DEMAND FOR JURY TRIAL" and "PRAYER FOR RELIEF" centered; WHEREFORE unnumbered; items a. to d. Pass.
- p.8: items e. and f.; the date, the signature block (By: /s/ Clinton H. Brannon, the bar number, counsel, the firm, the address, telephone, fax, e-mail). Pass.

## Known gaps and choices

1. **Typeface.** Only EB Garamond is vendored in `fonts/`, and the rules set no typeface for pleadings. The exemplars are Times New Roman (pdffonts on the Extreme Driver exemplar shows Times-family faces). EB Garamond at 13 pt is used so its x-height is close to Times at 12 pt; the 13 pt value is a judgment, not a rule. A Times-metric font would remove the difference; that is a question for David and a change to the shared `fonts/`.
2. **Second filer, not transcribed.** Moler is the second exemplar (tier 2). Only its caption style is used here (the ")" caption, now tested with a temporary sample that was not committed, and one page of it rendered cleanly). The Moler complaint is not transcribed and not overlaid.
3. **No exhibits, cover sheet, Rule 7.1 statement, or summons** are produced (see above).
4. **Footer.** The page number only. The exemplars print the ECF header line (court's stamp), which is not reproduced; it is added by the clerk when the PDF is filed.
5. **Paragraph numbers.** The template numbers the paragraphs 1 to 40, which matches the filed numbering (checked against the exemplar text).
6. **Signature block.** It is one unbreakable block, so when it does not fit it moves to the next page as a whole. It has no keep-with-previous rule, so the last prayer item can stay behind on the page before it.
7. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` read a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. `tools/tracker.sh` was not run (the PM regenerates it). The render and the overlay were run; the review above is the Gate 2 record.

[Vawd court README](../README.md) | [Federal courts README](../../README.md)
