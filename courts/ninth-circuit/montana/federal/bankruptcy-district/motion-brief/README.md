# U.S. Bankruptcy Court, D. Montana (`mtb`): motion (with memorandum practice)

Doc type: **motion-brief** (a motion under Fed. R. Bankr. P. 9013, filed in a contested matter; the legal basis is stated in the body, see gaps). Court: United States Bankruptcy Court for the District of Montana. Folder: `courts/ninth-circuit/montana/federal/bankruptcy-district/motion-brief/`.

Status: exemplar=yes (1 filed exemplar, 1 filer), render=ok, overlay=ok, pages reviewed 8 of 8. Nothing here sets `status` in `court.json`.

## Governing rules

Sources, all read on 2026-10-14:

- **Mont. LBR** (Local Bankruptcy Rules, December 1, 2025 version), PDF from the court's site: `https://www.mtb.uscourts.gov/sites/mtb/files/LocalBankruptcyRules_12012025.pdf` (linked from `https://www.mtb.uscourts.gov/rules-statutes`). Cited by rule and printed page.
- **Fed. R. Bankr. P.** 9004(a)-(b): Legal Information Institute, `https://www.law.cornell.edu/rules/frbp/rule_9004`. Quoted in part; the rest of the text is taken from the LBR's own references.
- **Fed. R. Bankr. P.** 2002(a)(2) (21 days' notice of a sale outside the ordinary course): not fetched; cited from memory and marked as such in gap 6.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MTB-FORM-001 | Mont. LBR 5005-2(a)(1), (6) | Electronically filed PDF; one-sided. The template uses letter paper. | `set page(paper: "us-letter")` |
| MTB-FORM-002 | Mont. LBR 5005-2(a)(2) | Legible, "at least 12-point font size." | `type-size` = 13 pt |
| MTB-FORM-003 | Mont. LBR 5005-2(a)(5) | "double-spaced, except for quoted material and footnotes." Body pitch 24 pt. Block quotations and footnotes are single-spaced; tables are single-spaced. | `body-leading`; the body block sets it; `show quote` and `show table` |
| MTB-FORM-004 | Mont. LBR 5005-2(a)(3) | "no less than one-inch margins, exclusive of page numbers." | `margins` |
| MTB-FORM-005 | Mont. LBR 5005-2(a)(4) | Consecutive page numbers at the bottom of each page. | page footer, `counter(page)` |
| MTB-FIRST-001 | Mont. LBR 5005-2(b)(1)-(6) | Upper left of the first page: name, office mailing address, telephone, email, state bar I.D., and the party represented. | `counsel`, `counsel_role` |
| MTB-FIRST-002 | FRBP 9004(b)(1)-(4) | Caption: (1) court's name; (2) case title; (3) case number and, if appropriate, adversary-proceeding number; (4) brief designation of the document's character. | `court`, `caption`, `case_number`, `title` |
| MTB-FIRST-003 | Mont. LBR 9004-1 | Case number format `0:12-bk-34567-ABC`. **The exemplar does not follow it** (its caption reads `19-60025-BPH`); see gap 3. | the sample's `case_number` |
| MTB-MOT-001 | Mont. LBR 9013-1(c) | "The body of a motion or an accompanying brief shall state with particularity the relevant law by section and the relevant procedure by rule upon which the moving party relies, specify all relief requested, and include a brief statement explaining why the relief should be granted." | author-written (sample ¶¶ 1-3, 9-16); not checked by the template |
| MTB-MOT-002 | Mont. LBR 9013-1(d) | Each motion a separate document. | not checked (one motion per sample) |
| MTB-MEM-001 | Mont. LBR 9013-2(a)-(b) | Motions "shall be supported by a memorandum of law filed with, or as a part of the motion," except the listed motions (9013-2(b)). Memoranda not to exceed 15 pages without leave. | not generated; see gap 2 |
| MTB-NOTICE-001 | Mont. LBR 9013-1(f)-(g) | After each motion, in bold and conspicuous print: "NOTICE OF OPPORTUNITY TO RESPOND AND REQUEST A HEARING" with the 14-day response text, the notice-of-hearing lines (Date, Time, Location) and the failure-to-respond sentence. A longer or shorter period set by another rule is written into the notice (9013-1(g)). | `notice-block(days)`; `response_days` in the sample frontmatter (default 14) |
| MTB-SIG-001 | Mont. LBR 5005-2(c) | Signature: a cursive signature on the signature line or a conformed "/s/" with the typed name. | `signature` block: `/s/ <signer>` |
| MTB-CERT-001 | Mont. LBR 9013-1(e)(1)-(2) | Minimum service: electronic service on opposing attorneys, the U.S. Trustee and the trustee; mail to any entity not receiving electronic service, with a certificate of service filed for those entities. | `certificate` block (data from the sample frontmatter) |

## Exemplar

- `exemplars/FILED-EXAMPLE-mohler-19-60025-motion-brief.pdf`: Chapter 7 Trustee's Motion to Approve a Short Sale of Real Property Free and Clear of Liens and Interests Pursuant to 11 U.S.C. § 363 and Carve Out Agreement Between Secured Lender and the Estate, with Notice of Opportunity to Respond, and certificate of service. 6 pages, filed July 31, 2019, by Darcy M. Crum, Chapter 7 Trustee. Text layer present.
- Provenance and searches: `exemplars/SOURCE.md`.
- Two other archived hits were rejected: a pro se debtor's motion to disqualify (17-61231, Doc 44; format not comparable) and court memoranda of decision (not filer documents).

## Sample

- `samples/INPUT-mohler-trustee-sale-motion.md`: transcription of the exemplar: counsel block, court title, caption, title, the opening paragraph, ¶¶ 1-16 with the block quotation (¶ 5) and the settlement table (¶ 11), the WHEREFORE paragraph, the signature block, the certificate of service and its addressee list. The notice of opportunity to respond is not in the sample: the template prints it from the rule.
- The exhibits the motion refers to (A: Buy-Sell Agreement; B: estimated settlement statement; C: secured creditor's consent letter) are not in the exemplar and not transcribed.
- The certificate's addressee list is the two-column service list flattened into one column in reading order (`pdftotext` crop of each column). One right-column line, "Kirkland, WA 98083-0788", has no determinable owner in the text layer and is not transcribed.
- `response_days: 21` is set in the frontmatter, not the 14-day default, because the motion is a § 363 sale. See gap 6.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/ninth-circuit/montana/federal/bankruptcy-district/motion-brief samples/INPUT-mohler-trustee-sale-motion.md
sh tools/overlay.sh courts/ninth-circuit/montana/federal/bankruptcy-district/motion-brief mohler-trustee-sale-motion
```

- `samples/OUTPUT-mohler-trustee-sale-motion.pdf`: 8 pages. `render.sh` fails on any typst warning; none. Fonts (`pdffonts`): EB Garamond Regular, Italic, Bold, all embedded (vendored).
- `samples/OVERLAY-mohler-trustee-sale-motion.pdf` and `.txt`: red = our render, blue = exemplar, black = both. Page map (word-overlap pairing, coarse): ours p.1 ↔ filed p.1 (79.0%), p.2 ↔ p.2 (65.4%), p.3 ↔ p.3 (73.1%), p.4 ↔ p.4 (75.5%), p.5 ↔ p.5 (62.5%); ours p.6-8 pair with filed p.6 at low overlap (29.7%, 37.2%, 24.1%), because our notice and the certificate run longer than the exemplar's last page. The layers will not coincide on text lines: the font differs (EB Garamond vs Times). The overlay is a diagnostic, not a score.

## Visual review (all 8 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block upper left, court title, caption (one row), title, opening paragraph | OK. Caption rule right and bottom of the party column. |
| 2 | JURISDICTION (¶¶ 1-3), BACKGROUND (¶¶ 4-6) with the block quotation of the legal description | OK. Quotation single-spaced, indented both sides. |
| 3 | ¶¶ 7-11, RELIEF REQUESTED heading, start of ¶ 11 | OK. |
| 4 | Settlement table (¶ 11) and ¶¶ 12-16 start | OK after fix: the table had no space above it and touched ¶ 11's text; now spaced half a line either side. |
| 5 | ¶ 16 end, WHEREFORE, the date and the signature block | OK. |
| 6 | NOTICE OF OPPORTUNITY TO RESPOND (boxed, bold), CERTIFICATE OF SERVICE begins with the first addressees | OK after fix: the certificate was set unbreakable and ran into the footer; it now flows across pages. The notice is 21 days per `response_days`. |
| 7 | Addressee list (continued) | OK. Address blocks are kept together. |
| 8 | Addressee list (end), conformed signature and date of the certificate | OK. |

Reviewed pages: 8 of 8. Pages 2-3 were looked at in the first render; the later edits (table spacing, certificate breaking, notice text) do not reach them, and the text on both pages is unchanged.

## Known gaps and open choices

1. **Tier 2 exemplars.** One exemplar, one filer. The eval-loop rule asks for two or three filed exemplars from different filers. Not found: most archived `mtb` memoranda are court opinions.
2. **No memorandum of law.** LBR 9013-2(a) says a motion "shall be supported by a memorandum of law filed with, or as a part of the motion." The exemplar has none; its legal basis is stated in the body (¶¶ 1-3, 12-13), which the rule allows "as a part of the motion." The template does not generate a separate memorandum, and does not count the 15-page limit. **Needs David's call** whether this doc type should require a separate memorandum section.
3. **Case number format.** LBR 9004-1 requires `0:12-bk-34567-ABC` (division digit, year, bk, number, judge). The exemplar's caption reads `19-60025-BPH`. The sample keeps the exemplar's value; the template prints whatever the sample says. A compliant caption would read `<division>:19-bk-60025-BPH`; the division digit is not recorded in the exemplar, so it is not invented here.
4. **Font.** EB Garamond at 13 pt, not Times. The LBR sets only the 12-point floor for motions; the Times New Roman requirement in LBR 9013-1(k)(6)(A) covers proposed orders only, so no face is required here and EB Garamond stays (see the court README, "Typeface"). The exemplar is set in Times, so `Liberation Serif` would match its line breaks better; that is a visual choice, not a rule.
5. **Caption and counsel block** are single-spaced; the LBR's double-spacing rule exempts only quoted material and footnotes. The exemplar single-spaces them too; the template follows it. A convention, not a rule reading.
6. **Response period.** The notice's 14-day text is LBR 9013-1(f) for ordinary motions. For a § 363 sale, FRBP 2002(a)(2) (cited from memory, not fetched: 21 days' notice of a sale outside the ordinary course) and LBR 9013-1(g) require the notice to carry the longer period. The sample sets `response_days: 21`. The template does not look the period up; the author sets it. **Verify the Rule 2002(a)(2) period before this template is called complete.**
7. **Exemplar predates the current LBR.** The exemplar was filed in 2019 under the earlier rules; its notice wording (21-day shortened-time text) is not the current 9013-1(f) text, and the template uses the current text.
8. **Exhibits and attachments** (A-C) are not generated or transcribed.
9. **Service list** is flattened (see Sample). Mailing-matrix attachment requirements (LBR 9013-1(e)(2)) are not checked.
10. **Page-count and paragraph numbering** are typed in the sample (`1\.`) and not checked by the template.
