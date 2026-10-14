# ctb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the District of Connecticut (`ctb`).
Folder: `courts/second-circuit/connecticut/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-despins-1stdibs-25-05088-adversary-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-1stdibs-complaint.md` (the complaint's text, paragraphs 1 to 34 and the prayer; Schedule A and footnotes omitted) |
| render | ok: `samples/OUTPUT-1stdibs-complaint.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 |
| overlay | ok: `samples/OVERLAY-1stdibs-complaint.pdf` and `OVERLAY-1stdibs-complaint.txt` |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the repo's convention (`INPUT-` for the markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), because `tools/render.sh` and `tools/overlay.sh` read and write those names. The brief's `<id>.md` / `<id>-overlay.pdf` form is not what the tools produce.

## Governing rules

Each row was read from the cited text on 2026-10-14. The bankruptcy local rules are the 2025 revision on the court's site; the district local rules are the version posted on the district's site (Rule 7 amended January 12, 2024; Rule 10 amended November 7, 2016).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to Official Form 416 (the adversary form, 416A). | `caption()` in `ctb-adversary-complaint.typ`: court, division, debtor and case, the adversary parties, the adversary number. |
| FRBP 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | (a) clearly legible. (b) caption: court name, case title, case number and adversary number, brief designation of the document. | Caption (court, division, debtors, chapter, case number, adversary number and judge, title). |
| FRBP 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The jurisdiction allegation names the case, its number and Code chapter, and the district and division; the pleader states whether it does or does not consent to final orders or judgment by the bankruptcy court. | Jurisdiction section of the sample. The consent sentence is in the sample, bracketed (see gap 3). |
| FRCP 10(b) via FRBP 7010 | Claims in numbered paragraphs. | The template numbers every paragraph after the first heading; the lead-in and the prayer are not numbered. |
| Local Bankr. R. 5005-1 (2025 PDF, https://www.ctb.uscourts.gov/sites/ctb/files/Local%20Rules_2021%20Revisions%20with%20Appendices_appdixE-revisions_2025_09_12.pdf) | D. Conn. L. Civ. R. 10 applies to pleadings filed with the Bankruptcy Court. | Items below. |
| D. Conn. L. Civ. R. 10 (https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-9.4.26.pdf) | Double-spaced; 8½ x 11; left and right margins of at least 1 inch; page numbers in the bottom margin after page 1; name, office address, telephone, fax and email under the signature, with the federal bar number beneath the signature; the complete docket number with the judge's initials on each pleading; the date in the caption. | `main.typ` page setup (1 inch margins, double spacing at 24 pt pitch, header with the adversary number and judge initials from page 2, page number from page 2); `signature()`; the caption's "Dated" line. Fax number is not in the sample (none in the exemplar). |
| Local Bankr. R. 7001-1, 7002-1 | Complaint filed in the division where the case is pending; the Form B1040 cover sheet accompanies it unless filed through CM/ECF. | Not produced: the B1040 cover sheet is a separate form (see gap 5). The division is in the caption. |
| Local Bankr. R. 7007-1 (applies D. Conn. L. Civ. R. 7 and 56 to adversary motions) | Relevant to motions, not to the complaint. | Not applicable to this doc type. |

Typeface and size: no rule in the bankruptcy local rules sets a typeface. D. Conn. L. Civ. R. 7(a)(5) (applied to adversary practice by Local Bankr. R. 7007-1) requires text of at least 12 point; the template uses 12 point throughout. See gap 2.

## Layout

- Caption: the court (three lines, bold, centred); a two-column box with the debtor block (`In re:`, the debtors, `Debtors.`) and the case number on the right; a second box with the adversary parties (each name, `v.` between them, the designation), the adversary number with the judge's initials, and the date.
- Title: bold, centred, below the caption.
- Body: double-spaced 12 point, first-line indent 0.5 inch. `#` headings are centred bold capitals; `##` headings are bold and left (the lettered sub-sections); `###` would be centred bold. Paragraphs before the first heading are unnumbered (the lead-in). The "PRAYER FOR RELIEF" heading switches numbering off until the next heading.
- Signature: "Dated" and the place on the left; the party, the `By: /s/` line with the e-signer, the signers with bar numbers and emails, the firm, the address, telephone and role on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `court`, `district`, `division`, `chapter`, `main_case`, `jointly_administered`, `debtors`, `judge`, `adv_number`, `caption.parties` (list of `{names, designation}`), `date`, `signature` (`dated_place`, `party`, `esigner`, `signers` (list of `[name, email]`), `firm` (lines), `role`).
- Body: blank-line-separated chunks. `#` / `##` / `###` headings; a list (`1.` items) for the prayer; any other chunk is one numbered paragraph (or the unnumbered lead-in before the first heading).
- Not supported: footnotes, tables, raw typst. The sample does not put the paragraph numbers in the text.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one filed document per doc type, so tier 2 is not judged against two or three filers. Candidates are listed in `exemplars/SOURCE.md`. Vereen v. Scruggs (25-03007, a different filer) is the second filer to check.
2. **Typeface.** The Electronic Filing Order of the district court (revised 1/17/2018, https://ctd.uscourts.gov/sites/default/files/Electronic%20Filing%20Order%2C%20revised%201.17.2018.pdf) says "All documents must be typewritten using Arial bold 12 point font, double spaced." That is an order of the district court; the bankruptcy court's local rules do not adopt it, and Local Bankr. R. 5005-1 adopts only D. Conn. L. Civ. R. 10, which sets no typeface. The template uses EB Garamond 12 point, the only vendored font (Arial is not vendored and may not be used). The exemplar uses a serif face. **Question for David:** does the bankruptcy court apply the district order's Arial bold to adversary pleadings? If so, the template needs an Arial-metric font vendored in `fonts/`.
3. **Statement on final orders (FRBP 7008(a)).** The exemplar has no statement on consent to final orders. The sample's jurisdiction paragraph says "The Trustee [does not consent]" as a bracketed placeholder, not a fact of the filing. The rule requires one of the two choices, so the choice is counsel's. Remove the brackets once the choice is made.
4. **Paragraph numbers.** The template numbers paragraphs from 1 (the exemplar's count is one lower up to the consent paragraph, then the same). The realleging paragraph says "paragraphs 1-34" to match this sample's count; recount if the sample changes.
5. **Cover sheet and schedules.** Not produced: the Form B1040 cover sheet (a separate form; the exemplar's pages 1-2) and Schedule A (the transfer schedule, not in the exemplar's text layer). Schedule A is referenced in paragraph 32 of the sample.
6. **Omitted text.** The sample transcribes paragraphs 1 to 34 and the prayer; footnotes 1 to 3 (debtor identification, the list of other adversary proceedings) are omitted. The sample is 7 pages; the exemplar's complaint runs 11 pages with a different face and spacing. The gap in length is the font metrics, not omitted paragraphs. Tier 2 page count is not a check.
7. **Overlay pairing.** The exemplar's first two pages are the cover sheet, so our page 1 pairs with the exemplar's page 4 (the complaint's second page). The overlay is a diagnostic, not a score.
8. **Caption.** The debtor footnote marker ("1") after "HO WAN KWOK, et al." is not reproduced; the template has no footnote in the caption.
9. **Check scripts.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and `tools/` is out of scope for this box. The gates were not run. Render and overlay were run, and the page review below is the Gate 2 equivalent.

## Review of the rendered pages (`samples/OUTPUT-1stdibs-complaint.pdf`, 7 pages)

Every page rendered at 60 dpi and viewed after the final template change (heading spacing and the e-signer line).

- Page 1: caption (court, division, debtors box, adversary box with the adversary number, judge and date), the title, the lead-in, paragraphs 1 and 2. No header or page number on page 1. Pass.
- Page 2: header "Adv. Pro. No. 25-05088 (JAM)"; page number 2; paragraphs 3 to 12; JURISDICTION AND VENUE, THE PARTIES, FACTS and sub-heading A. The consent sentence (paragraph 7) is bracketed as gap 3 describes. Pass.
- Page 3: paragraphs 13 to 17; sub-heading B on its own line with space above and below. Pass.
- Page 4: paragraphs 18 to 24; sub-headings C and D; no heading at the foot of the page. Pass.
- Page 5: sub-heading E at the top; paragraphs 25 to 29. Pass.
- Page 6: paragraph 29 finishes; paragraphs 30 to 39; sub-heading F; the FIRST CLAIM heading and its two-line subtitle, centred bold. Pass.
- Page 7: paragraphs 40 and 41; PRAYER FOR RELIEF heading; the unnumbered WHEREFORE paragraph; prayer items 1 to 3; the date and place; the signature block (`By: /s/ Patrick R. Linsey`, the signers with bar numbers and emails, the firm, the role). Pass.

Overlay: our pages pair with the exemplar's pages 4 to 12 by shared words (word overlap 52% to 88%). The exemplar's first two pages are the cover sheet, so the pairing starts at its page 4. The overlay is a diagnostic, not a score.
