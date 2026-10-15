# miwb: adversary complaint

Doc type: **adversary complaint** (Fed. R. Bankr. P. 7001 proceeding, commenced by complaint) in the United States Bankruptcy Court for the Western District of Michigan (`miwb`).
Folder: `courts/sixth-circuit/michigan/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-spiech-farms-17-05398-adversary-complaint.pdf` (primary; Rayman & Knight for the Chapter 11 debtor, 2017) and `exemplars/FILED-EXAMPLE-fuller-25-02060-adversary-complaint.pdf` (Chapter 7 debtor, 2026, through counsel). Provenance in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-spiech-complaint.md`: the whole 8-page complaint transcribed, exhibits left out |
| render | ok: `samples/OUTPUT-spiech-complaint.pdf`, 9 pages, letter, 67 KB, typst 0.15.0 with vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> samples/INPUT-spiech-complaint.md`) |
| overlay | ok: `samples/OVERLAY-spiech-complaint.pdf` (red = ours, blue = filed Spiech, black = both) and `samples/OVERLAY-spiech-complaint.txt` (page map). Run as `sh tools/overlay.sh <this dir> spiech-complaint <this dir>/exemplars/FILED-EXAMPLE-spiech-farms-17-05398-adversary-complaint.pdf`; see "Overlay" for why the exemplar is passed explicitly |
| pages reviewed | 9 of 9 (every page of the final `OUTPUT-spiech-complaint.pdf` rendered at 60 dpi and viewed) |

File names follow the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), not the `<id>.pdf` form in the brief: `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Sources were fetched 2026-10-14. The local rules are the court's own PDF ("Local Bankruptcy Rules", effective October 11, 2026), read in full: https://www.miwb.uscourts.gov/sites/miwb/files/local_rules/Final%20-%20Clean_1.pdf (linked from https://www.miwb.uscourts.gov/court-info/local-rules-and-orders/local-rules). The federal rules are the Cornell LII text of the restyled Bankruptcy Rules (amended to take effect 2024-12-01).

| ID | Rule (source) | Requirement | Where it is in the template |
|---|---|---|---|
| MIWB-FORM-001 | LBR 9004(f) (court LBR, above) | Except exhibits, official forms and software-generated preprinted forms, documents must be "double-spaced and typewritten in at least 12-point type." | `pitch = 27.6pt` (the filed exemplar's measured baseline pitch), `type-size = 13pt`, `body-leading`. No face is named; EB Garamond kept (gap 7). |
| MIWB-FORM-002 | Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | A pleading's caption "must substantially conform to the appropriate version of Form 416" (Fed. R. Civ. P. 10 applies otherwise). | `caption()`: court name, "In re" debtor, case number, chapter, adversary party block, adversary number |
| MIWB-FORM-003 | LBR 9004(a) | The debtor's current chapter in the caption, immediately below the case number. | `caption()`: "Chapter" line directly under "Case No." |
| MIWB-FORM-004 | LBR 9004(b); Fed. R. Bankr. P. 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | Caption contains the court's name, the title of the case, the case number and "a brief designation of the document's character"; the LBR adds: the description is centered and immediately before the body. | `document title`: centered, bold, capitals, before the first paragraph |
| MIWB-FORM-005 | LBR 9004(c) | Every motion, pleading or request for relief states the petition date and any conversion, dismissal or reinstatement; in a complaint, this statement comes "immediately after the jurisdictional paragraph required by Fed. R. Civ. P. 8(a)". | `generated-statements()`: printed in place, right after the first paragraph under JURISDICTION (from `dates:`) |
| MIWB-FORM-006 | LBR 9004(d) | Telephone number, office address, email address and state bar identification number "directly below the attorney's signature". | `signature-block()`: "BUSINESS ADDRESS", "Telephone", "Email", bar number on the signature line; a missing field stops the build |
| MIWB-FORM-007 | Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008); LBR 7008 | The jurisdiction allegation names the case the proceeding relates to, its name, number and chapter, and "the district and division where it is pending"; the complaint states core or non-core and whether the pleader consents to a final order or judgment. The LBR (7008) still requires the core/non-core statement; the restyled Rule 7008 requires only the consent statement. | `generated-statements()`: the relation sentence and the core and consent sentence, from `case:`, `core:`, `consent:` |
| MIWB-FORM-008 | Fed. R. Civ. P. 10(b) as applied by Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frcp/rule_10) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | `numbered()`: every body paragraph is numbered 1, 2, ...; headings, quotations and WHEREFORE clauses are not |
| MIWB-FORM-009 | Fed. R. Bankr. P. 7001 (https://www.law.cornell.edu/rules/frbp/rule_7001) | Defines what is an adversary proceeding (for example recovery of money or property, and avoidance and lien determinations). | Doc type only: this folder is the complaint that starts such a proceeding. The template does not check the cause of action. |
| MIWB-FORM-010 | Fed. R. Bankr. P. 9037(a) (https://www.law.cornell.edu/rules/frbp/rule_9037) and ECF Administrative Procedures VIII (https://www.miwb.uscourts.gov/sites/miwb/files/local_rules/ECF%20Admin%20Procedures%20Amended%20Eff%2012-13-21.pdf) | Redact SSN to last four digits, minors to initials, birth dates to year, financial accounts to last four digits. | Not template-checked: the content is the filer's. The sample contains none of these identifiers. |
| MIWB-FORM-011 | ECF Administrative Procedures IV.B (2 MB per document, about 35 pages) and V.B (standard letter size, 8.5 x 11 in) | Electronically filed PDFs at most 2 MB; letter size. | `paper: us-letter`. The sample is 67 KB. |
| MIWB-FORM-012 | ECF Administrative Procedures II.A.2 | Supporting documents (for example proposed orders, certificates of service) are filed as attachments to the complaint. | Not produced here: the summons (Fed. R. Bankr. P. 7004) and the adversary cover sheet are separate filings. See "Known gaps". |

## Layout

- Court name, centered, bold, two lines (LBR 9004(b)); "In re:" block on the left and "Case No.", "Chapter" on the right (LBR 9004(a)); party block with rules ("____/") and "v."; "Adv. Proc. No." on the right, as in both exemplars.
- Text: EB Garamond, 13 pt, double-spaced at a 27.6 pt baseline pitch. The court's rules name no face for this document, so no substitute applies (gap 7). The pitch is measured from both filed exemplars (Spiech and Fuller use 27.6 pt, Word's double spacing at 12 pt Times). The leading is set so EB Garamond's 0.646 em line box gives 27.6 pt (`body-leading = 1.477em`); the measurement is `pdftotext -bbox-layout`.
- Margins: 1 in on all sides, letter paper. Footer: centered "Page X of Y", 11 pt.
- Numbered paragraphs: the number at 0.5 in, the text at 1.0 in, continuation lines flush with the margin (the exemplars' tab stops).
- Headings: level 1 and 2 centered bold capitals; level 3 bold at the margin. Counts use level 1 ("COUNT I") and level 2 (the count's title).
- Sub-lists are lettered a., b., ...; the prayer after a WHEREFORE is lettered A., B., ... (as in the Spiech exemplar).
- Block quotations are indented 0.5 in and not numbered.
- Footnotes are supported (`[^key]`); the template inlines each definition into the chunk that cites it.

## Overlay

`samples/OVERLAY-spiech-complaint.pdf` pairs each rendered page with the Spiech exemplar page that shares the most words (`OVERLAY-spiech-complaint.txt`):

| ours | filed | word overlap |
|---|---|---|
| 1 | 1 | 54.2% |
| 2 | 2 | 72.0% |
| 3 | 3 | 84.6% |
| 4 | 4 | 72.5% |
| 5 | 5 | 72.5% |
| 6 | 6 | 85.4% |
| 7 | 6 | 59.3% |
| 8 | 7 | 57.1% |
| 9 | 8 | 73.1% |

Read it as a diagnostic, not a score. The differences are expected: the template prints the petition-date and core statements from the fields (in the rule's position) where the filer's paragraphs 1, 2 and 5 were written out; the caption's "In re:" is the form's wording where the filer wrote "IN THE MATTER OF:"; the filer's ECF header and footer ("Case:17-05398-jtg Doc #:3 Filed..." at the top) are court-applied and not reproduced. The overlay default chooses `ls exemplars/*.pdf | head -1`, which is the Fuller file alphabetically; the Spiech file is passed explicitly because it is the primary exemplar.

## Second exemplar (tier 2)

The Fuller complaint (Chapter 7 debtor, filed 2026 through Acclaim Legal Services, PLLC) is the second filer for caption, parties, jurisdiction and signature. Its spacing matches the rule (most body lines measure 27.5 to 27.6 pt), so it agrees with the template on that point. It departs from the rules in two places, which the template does not copy: the petition date is in paragraph 6, not right after the jurisdictional paragraph (LBR 9004(c)), and the adversary number is left blank ("Adv. Pro. No.").

## Known gaps and open choices (for David)

1. **Division (Fed. R. Bankr. P. 7008(a)).** The rule requires the jurisdiction allegation to name "the district and division where it is pending". The LBR text read in full names no divisions for this court (it refers to the Clerk's office at 1 Division Avenue North, Grand Rapids). The template prints a division only when the sample gives one (`division:`); the sample gives none, as the exemplar does. Question: is "Western District of Michigan" enough, or does the court want a division named?
2. **Adversary number on the Spiech exemplar.** The filed document prints "Adv. Proc. No. 17-80"; CourtListener's docket reads 17-80191. The sample keeps the printed text. The template prints whatever `adversary_number:` says.
3. **E-mail address.** The LBR requires an email address (LBR 9004(d)); the Spiech exemplar does not print one. The sample says so in brackets, and the template needs the field to build.
4. **Caption wording.** Form 416A itself could not be fetched (uscourts.gov returned 404 to the sandbox). The caption follows Rule 7010 and LBR 9004, with the exemplars' layout. Compare with the official Form 416A before filing.
5. **Not produced:** the summons (Fed. R. Bankr. P. 7004), the adversary cover sheet, the civil-style exhibits (the Spiech exhibits A to C are separate attachments), and any proposed order (the ECF procedures require it as an attachment). Each is a separate document.
6. **Conference (LBR 7007, 9014).** Not a template field: a movant must make a reasonable effort to confer, which is a fact about the case.
7. **Typeface (no face named; EB Garamond kept).** The only formatting rule is LBR 9004(f): "typewritten in at least 12-point type". The font list in LBR Exhibit 1 ("Courier, Helvetica, Arial or Times New Roman") applies only to the creditor matrix .txt file, not to a complaint. So no substitute from `docs/FONTS.md` applies, and EB Garamond stays (`docs/FONTS.md`, "No face named"). Checked 2026-10-15 against the LBR PDF. At 13 pt its visual size is close to Times New Roman at 12 pt (the exemplars' face); that is a visual comparison, not a metric match. Render: 9 pages, unchanged.
8. **Paragraph count.** The sample renders at 9 pages against 8 for the exemplar. The difference is the generated statements and the typeface; both are within the 8 to 14 page target.

## Searches (for the record)

CourtListener v4 search, `court=miwb`, `type=r`: "adversary" (1,301 hits), "complaint", "Complaint by" (adversary descriptions). Adversary complaints with a downloadable PDF: Spiech (17-05398), Fuller (25-02060), Martech (25-80010, 3 pp., not used), RIH (05-81246, pre-2005 format, not used). Court site: local rules at https://www.miwb.uscourts.gov/court-info/local-rules-and-orders/local-rules. The LBR PDF is "Final - Clean_1.pdf" (modified 2026-09-15, effective 2026-10-11).

## Rebuild

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (see the brief's toolchain steps)
cd /work/repo
sh tools/render.sh courts/sixth-circuit/michigan/federal/bankruptcy-western-district/adversary-complaint samples/INPUT-spiech-complaint.md
sh tools/overlay.sh courts/sixth-circuit/michigan/federal/bankruptcy-western-district/adversary-complaint spiech-complaint courts/sixth-circuit/michigan/federal/bankruptcy-western-district/adversary-complaint/exemplars/FILED-EXAMPLE-spiech-farms-17-05398-adversary-complaint.pdf
```

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md)
