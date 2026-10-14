# U.S. Bankruptcy Court, S.D. Georgia (gasb): adversary complaint

Doc type: **adversary complaint** (a complaint that starts an adversary proceeding under Part VII of the Federal Rules of Bankruptcy Procedure). Court: United States Bankruptcy Court for the Southern District of Georgia (the exemplar is from the Savannah Division). Folder: `courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/adversary-complaint/`.

Status: exemplar=yes (1 filed exemplar, 1 filer), render=ok, overlay=ok, pages reviewed 8 of 8 (the sample renders to 8 pages, the same length as the exemplar). Nothing here sets `court.json` status.

## Governing rules

Dates: each rule below was fetched on 2026-10-14. The federal rules are quoted from Cornell LII (current text, as amended Apr. 2, 2024, eff. Dec. 1, 2024). The local rules are the **court's own local rules, which are older than the federal rules**: see the caveat under "Local rules currency".

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| GASB-FORM-001 | FRBP 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004) | "A petition, pleading, schedule, or other document must be clearly legible. Commonly used English abbreviations are acceptable." | the whole template: the body is typeset, not handwritten or scanned |
| GASB-FORM-002 | S.D. Ga. LBR, Uniformity of Practice (https://www.gasb.uscourts.gov/sites/gasb/files/local_rules/GASB-localRules.pdf, "current as of May 2017") incorporating S.D. Ga. LR 10.1 (https://www.gasd.uscourts.gov/sites/gasd/files/Local_Rules_of_Civil_Procedure_Printable_rev_June_2016.pdf, Rev. June 2016) | "All pleadings, notices, orders, and other papers … shall … be double-spaced." | `line-pitch` = 24 pt (double spacing), `body-leading` |
| GASB-FORM-003 | LR 10.1 (as incorporated) | "be numbered on each page. … Page numbering shall begin on the first page of a submission, including any title page, cover sheet …" | `set page(numbering: "1", footer: …)`: the caption page is page 1 |
| GASB-CAP-001 | FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | A document's caption must set out (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, the adversary-proceeding number, and (4) a brief designation of the document's character. | `court-title`, `caption-table`, `title` |
| GASB-CAP-002 | FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) and FRCP 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Caption with the court's name, a title, a file number and a designation; "The title of the complaint must name all the parties." | `caption-left`: every party is named in the caption (the template requires `caption` to have sides with `names`) |
| GASB-CAP-003 | FRBP 7010 | "a pleading's caption must substantially conform to the appropriate version of Form 416." | **Open: not verified.** The template follows the layout of the exemplar and FRBP 9004(b). One search result identifies Official Form 416D as the adversary caption for a complaint other than a debtor's; the text of 416A/416D was not retrieved, so conformity is not checked. See Known gaps. |
| GASB-CONT-001 | FRBP 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The jurisdiction allegation must name the case the adversary relates to, the district and division where it is pending, and the pleader must state whether it does or does not consent to final orders by the bankruptcy judge. | author-written (the template does not check the text). The sample's ¶¶ 7-8 and 12 carry the statements. |
| GASB-CONT-002 | FRCP 10(b) (https://www.law.cornell.edu/rules/frcp/rule_10) | "A party must state its claims or defenses in numbered paragraphs"; separate claims go in separate counts. | the author writes the numbers in the markdown (`1.`, `2.`, …); cmarker keeps them across headings, so the paragraph numbers run through the claims. The template does not check that they are consecutive. |
| GASB-SIG-001 | S.D. Ga. LR 11.1 (as incorporated, substituting FRBP 9011) | Counsel's name, complete address (street and post office box), telephone number and State Bar Number, on every pleading. | `signature-block`: the template requires `signature.firm`, `signer`, `role` and `address`. |

Not generated, on purpose (see Known gaps): the summons (FRBP 7004), the adversary cover sheet (Official Form 104, which the exemplar's docket shows as an attachment), exhibit slip sheets, the proposed order, certificates of service (see the next line).

LR 5.1 (S.D. Ga., as incorporated: "Each paper served other than by a United States Marshal shall include a certificate of the person or firm making service … and the date, method, and address of service.") is the basis for the certificate of service on the motion. A complaint is served with a summons under FRBP 7004; the exemplar has no certificate, so none is generated here.

## Local rules currency

- The bankruptcy local rules were fetched from the court's PDF (https://www.gasb.uscourts.gov/sites/gasb/files/local_rules/GASB-localRules.pdf), which says "current as of May 2017". Courtrules.net copies of the same rules returned HTTP 403, and the court's current rules page was not reachable. **Whether the court has amended these rules since May 2017 is not verified.**
- The Uniformity of Practice clause incorporates district rules "to the maximum extent possible" and names LR 10.1 and LR 11.1 without a condition. The district rules in the GASD PDF are Rev. June 2016. A district rule may have changed since.
- The "double-spaced" (LR 10.1) and "numbered on each page" requirements are the only form requirements found for the bankruptcy court's papers. No font, type-size or margin rule was found in the bankruptcy local rules (2017), the district local rules (2016), or FRBP 9004. The font and margins here are style choices, marked as such in the template.

## Exemplar

- `exemplars/FILED-EXAMPLE-master-lending-26-04010-adversary-complaint.pdf`: Complaint (ECF 1), *Caron v. Synergy Homes of Georgia, LLC, et al.*, Adv. Pro. No. 26-04010-EJC, in *In re Master Lending Group, LLC*, No. 23-40569-EJC (Chapter 7), Savannah Division. 8 pages. Filed May 14, 2026 by the Chapter 7 trustee's counsel (Hunter Maclean Exley & Dunn, P.C.). Text layer present.
- Provenance and searches: `exemplars/SOURCE.md`.
- **Only one exemplar.** The eval-loop tier-2 rule asks for two or three from different filers. A second filer (Butler v. Ally Financial, 24-01001-SDB, 26 pages) was downloaded and checked, but it is 9.6 MB, over the snapshot size limit, so it was not kept; its RECAP URL is in `exemplars/SOURCE.md`. Tier 2 is judged against this one exemplar, so the tier-2 judgment is weaker than the bar asks for.

## Sample

- `samples/INPUT-master-lending-complaint.md` transcribes the whole exemplar: the caption, all 48 numbered paragraphs, the five headings, the WHEREFORE clause, footnote 1, and the signature block. The exemplar's Exhibit 1 (the notice of default, ECF 1-1) is not transcribed.
- The frontmatter carries the caption, counsel and signature fields (schema below). Headings are typed in the author's case (the template does not change case).

Frontmatter schema for this doc type:

| Field | Required | Feeds |
|---|---|---|
| `court` | yes | court title lines, centered, upper case (GASB-CAP-001) |
| `case_number`, `chapter` | yes | right caption column: `CASE NO.`, `CHAPTER` |
| `in_re` | yes | debtor block, first lines of the left caption column (`In re:` and the debtor's name) |
| `debtor_role` | no (`Debtor.`) | designation under the debtor block |
| `judge` | no | right caption column |
| `adversary_number` | no | `ADV. PRO. NO.`; a blank prints an underscored blank for the clerk |
| `caption` | yes | list of sides, each `names` and `designation`; `v.` between sides |
| `title` | yes | designation of the document, centered, upper case |
| `submitted_on` | yes | "Respectfully submitted this …" |
| `signature` | yes | `firm`, `signer`, `signer_lines`, `other_counsel_lines`, `role`, `address` |

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-master-lending-complaint.md          # -> samples/OUTPUT-master-lending-complaint.pdf
sh tools/overlay.sh $D master-lending-complaint $D/exemplars/FILED-EXAMPLE-master-lending-26-04010-adversary-complaint.pdf
```

- `samples/OUTPUT-master-lending-complaint.pdf`: 8 pages. Typst compiled with no warnings (`render.sh` fails on any). Only the vendored EB Garamond is embedded (`pdffonts`).
- `samples/OVERLAY-master-lending-complaint.pdf` and `.txt`: red = our render, blue = the filed exemplar, black = both. The page map pairs pages 1-8 with filed pages 1-8, with word overlap 58-90%. The overlay is a diagnostic: the exemplar is set in Times with no printed page number on the caption page, and the render is not, so text lines will not coincide.
- File names follow the tools (`OUTPUT-`, `OVERLAY-`, `INPUT-`), not the brief's `<id>.pdf` / `<id>-overlay.pdf` names.

## Visual review (Gate 2 record: all 8 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, parties, CASE NO., CHAPTER, ADV. PRO. NO. blank), title, COMPLAINT, first paragraph, start of Preliminary Statement | OK after two fixes: the heading was drawn at 1.2× body size (fixed to body size, bold); the author's title case is kept (was forced to upper case). The caption border is a right-and-bottom rule on the left cell. |
| 2 | Heading "PARTIES, JURISDICTION, AND VENUE"; paragraphs 1-11, numbers hang | OK. Hanging number layout (the exemplar sets the number on the first line; both read as numbered paragraphs). |
| 3 | Paragraphs 11 (end) to 18; "FACTUAL BACKGROUND" | OK. Italic *See In re Melton* and *Stern v. Marshall* render; `at *2` shows the asterisk. |
| 4 | Paragraphs 18-24 | OK. |
| 5 | Paragraphs 25-29; footnote 1 at foot of page | OK. Footnote at type size. |
| 6 | Paragraphs 31-39; "SECOND CLAIM FOR RELIEF" heading (two lines, centered) | OK. |
| 7 | Paragraphs 40-48; "THIRD CLAIM FOR RELIEF" | OK. |
| 8 | WHEREFORE; "Respectfully submitted" at left with the firm block at right; the second counsel block and the address | OK after one fix: the signature block did not fit under WHEREFORE and sat alone on a ninth page; the "Respectfully submitted" line moved into the empty left column, and the block now fits on page 8 with the prayer. |

Pages reviewed: 8 of 8.

## Known gaps and open choices

1. **Official Form 416 (GASB-CAP-003).** FRBP 7010 requires the caption to substantially conform to Form 416. The text of the appropriate form (416A, 416D or other) was not retrieved, so conformity is not checked. The caption follows the exemplar's layout and FRBP 9004(b). **Needs a check against the official form before this template is treated as complete.**
2. **Typeface (fonts pass, 2026-10-14).** Face required: **none**. The bankruptcy local rules (2017 PDF, GASB-localRules.pdf) and the district LR 10.1 (2016 PDF, Local_Rules_of_Civil_Procedure_Printable_rev_June_2016.pdf) were each extracted with `pdftotext` and searched for font, typeface, type size and named faces: no match. FRBP 9004 names none either. Vendored substitute: **EB Garamond** (`fonts/eb-garamond/`, OFL), the "no face named" row of `docs/FONTS.md`. Fit: n/a (no court face). The exemplar is set in Times, which the rules do not require; 13 pt was chosen by eye to approximate Times at 12 pt (not measured). Changing the font would need a court rule that names a face.
3. **Margins.** 1 inch all round: a style choice (no margin rule found).
4. **Second exemplar.** One exemplar only (see Exemplar).
5. **Paragraph numbers are typed by the author.** The template does not check that they run 1..n without a gap. A checker that does is a candidate for the next iteration.
6. **Jurisdiction and consent statement (GASB-CONT-001)** are written by the author, not checked.
7. **Not generated:** summons (FRBP 7004); adversary cover sheet (Official Form 104, in the exemplar's docket as an attachment); exhibit slip sheets; the proposed order (LBR 9072-1(a) requires a proposed order with a motion, not with a complaint); the certificate of service (see Governing rules).
8. **Court-specific local rules currency.** See "Local rules currency" above.
9. **Privacy redactions** (FRBP 9037 / FRCP 5.2) are the filer's job; the template does not check them.
10. **Cover page.** The exemplar's caption page has no printed page number (its page 2 does). LR 10.1, as incorporated, requires every page, including the caption page, to be numbered; the template follows the rule and the exemplar differs.
