# U.S. Court of International Trade (complaint, motion-brief): rules

Alias `cit`. Scope: papers filed by counsel through the court's CM/ECF system in a civil action before the United States Court of International Trade: the complaint (`complaint/`, USCIT Rules 3, 7(a)(1), 8, 10) and the Rule 56.2 motion for judgment on the agency record with its supporting brief in one document (`motion-brief/`, USCIT Rules 7(b), 56.2, 81(j); Standard Chambers Procedures 2). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 and whenever the court posts an amended "Rules of the Court" compilation (the current one is "As amended August 21, 2026, eff. August 21, 2026"; the court amends its rules mid-year, so also re-check when a new compilation date appears on the Rules page).

## Sources

| Tag | Source | URL |
|---|---|---|
| USCIT | Rules of the U.S. Court of International Trade, "Effective November 1, 1980 (As amended August 21, 2026, eff. August 21, 2026)", complete rules and forms compilation, 487 pp. Page numbers below are the compilation's printed page numbers. curl from this box got "Request Rejected" (HTTP 404) from cit.uscourts.gov; the copy read is the official URL fetched through the WebFetch tool on 2026-10-17 (sha256 `6ff22a48484b96c655f5738eae66ea0cfe92941a60e69dc845a41617c56a412a`, cached at `/work/artifacts/rules-cache/cit/COMPLETE-RULES-AND-FORMS.pdf`). | https://www.cit.uscourts.gov/sites/cit/files/COMPLETE%20RULES%20AND%20FORMS.pdf |
| SCP | Standard Chambers Procedures (Rev. 1/23/23), printed in USCIT pp. 423-426 | same file as USCIT |
| FORMS | Appendix of Forms, General Instructions (USCIT pp. 321-322) and "Complaint Allegations" (USCIT pp. 350-351) | same file as USCIT |
| AO-02-01 | Administrative Order 02-01, "In re Electronic Filing Procedures and Submission of Confidential Information" (the court's Electronic Filing Procedures, "EFPs"), printed in USCIT pp. 434-454 | same file as USCIT |
| EX-TREK | Complaint, *Trek Bicycle Corp. v. United States*, Ct. No. 25-00917, ECF 2 (Sidley Austin LLP) | `complaint/usage/` |
| EX-SAHAMITR | Complaint, *Sahamitr Pressure Container PLC v. United States*, Ct. No. 22-00107, ECF 2 (White & Case LLP) | `complaint/usage/` |
| EX-DEERPARK | Complaint, *Deer Park Glycine, LLC v. United States*, Ct. No. 24-00016, ECF 2 (Thompson Hine LLP) | `complaint/usage/` |
| EX-BGH | Rule 56.2 motion and memorandum, *BGH Edelstahl Siegen GmbH v. United States*, Ct. No. 26-01186, ECF 26 (DeKieffer & Horgan, PLLC) | `motion-brief/usage/` |
| EX-GREATRIVER | Rule 56.2 motion and memorandum of consolidated plaintiff Greatriver Wood Co., *Shelter Forest Int'l Acquisition, Inc. v. United States*, Ct. No. 23-00144, ECF 51 (Husch Blackwell LLP) | `motion-brief/usage/` |

Kinds: **M** = mandated by a USCIT rule, the Standard Chambers Procedures or AO 02-01. **C** = convention (the rules leave it open; taken from the exemplars, with the filers that show it). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **12-point minimum, footnotes included.** Rule 81(f): "type size of 12 points or larger, including type used in footnotes." The rules name no typeface and say nothing about serif or proportional spacing. All five exemplars (all five filers) use Times New Roman (`pdffonts`); that is a convention, not a rule.
2. **No margin rule as such.** Rule 81(f) caps the typed area: "typed matter not exceeding 6½ by 9½ inches" on an 8½ by 11 page. One-inch side margins follow from the width; the height cap permits 0.75 in total top and bottom. The 1 in margins seen in every exemplar are convention.
3. **Pages numbered consecutively from 1, on the bottom** (Rule 81(d), 81(f)). Both motion exemplars (EX-BGH, EX-GREATRIVER) number the table of contents and table of authorities in lower-case roman and restart the body at 1; two of the three complaint exemplars (EX-TREK, EX-SAHAMITR) print no page number at all (only the CM/ECF header "Page n of N"). Both practices depart from the literal rule; the template follows the rule (CIT-FORM-006), and this file records the roman-front-matter practice as a convention seen across two filers (CIT-FORM-011) that the template may adopt only if David decides the literal reading yields.
4. **Word limits come from the Standard Chambers Procedures, not the Rules.** SCP 2(B)(1)(a): movant's and respondent's briefs 14,000 words, replies 7,000. A word-count certificate is required (SCP 2(B)(2)).
5. **Motion and brief in a single document.** Rule 7(b)(1)(B) forbids a separate supporting brief unless the Court requires one; Rule 56.2(c)(1) and SCP 2(A) say the Rule 56.2 motion and its brief "must be submitted in a single document".
6. **No certificate of service when served through CM/ECF** (Rule 5(d)(1)(B)). Complaints in 28 U.S.C. § 1581(c) actions instead carry the plaintiff's notice to interested parties (Rule 3(f)); EX-SAHAMITR attaches both.
7. **Disclosure statement is a separate filing** (Rule 3(i), Form 13), not part of either document; it is excluded from the word count (SCP 2(B)(1)(c)).

## Requirements: all doc types

### Page form (Rule 81)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CIT-FORM-001 | Every page is 8½ by 11 inches (612 x 792 pt). Rule text: "Pleadings and other papers must be 81/2 by 11 inches in size". | Rule 81(f), USCIT p. 276; Rule 81(i), p. 278 (briefs) | M |
| CIT-FORM-002 | Typed matter does not exceed 6½ by 9½ inches (468 x 684 pt) on any page. The rule does not exempt page numbers, so the check measures the extent of all text we set, page numbers included (the CM/ECF header stamped by the court is not ours and is excluded). | Rule 81(f), USCIT p. 276 | M |
| CIT-FORM-003 | Type size: "12 points or larger, including type used in footnotes." The rule is silent on typeface; applies to all text (headings, caption, footnotes). | Rule 81(f), USCIT p. 276 | M |
| CIT-FORM-004 | "Typed matter must be double spaced except footnotes, which may be single spaced, quoted material, which may be indented and single spaced, and titles, schedules, tables, graphs, columns of figures, and other interspersed material which are more readable in a form other than double spaced." Operational definition: baseline-to-baseline distance in body paragraphs is at least twice the type size (24 pt at 12 pt). | Rule 81(f), USCIT pp. 276-277; Rule 81(i), p. 278 | M |
| CIT-FORM-005 | Papers are "plainly and legibly typewritten or otherwise produced"; covered by CIT-ELEC-001. | Rule 81(b), USCIT p. 276 | M |
| CIT-FORM-006 | "The pages of each paper must be numbered consecutively, commencing with the number 1." | Rule 81(d), USCIT p. 276 | M |
| CIT-FORM-007 | "Pages must be numbered on the bottom." | Rule 81(f), USCIT p. 276; Rule 81(i), p. 278 | M |
| CIT-FORM-008 | Every font used is embedded and is the template's declared family (no silent fallback). | project; supports Rule 81(b) | T |
| CIT-FORM-009 | Typeface: Times New Roman (or a close proportional serif) for all text. Seen in all five exemplars (EX-TREK, EX-SAHAMITR, EX-DEERPARK, EX-BGH, EX-GREATRIVER); not required by any rule (CIT-FORM-003 is silent on face). | exemplars | C |
| CIT-FORM-010 | One-inch margins on all four sides (text begins at x = 72 pt in all five exemplars; double-spaced body at about a 28 pt baseline pitch in all three complaints). | exemplars | C |
| CIT-FORM-011 | Page number centred at the foot. Seen in EX-DEERPARK, EX-BGH, EX-GREATRIVER (centred). Roman-numeral front matter (TOC, TOA) with the body restarting at 1 is seen in EX-BGH and EX-GREATRIVER; this conflicts with the literal text of CIT-FORM-006 and is not adopted (see Findings, 3). | exemplars; Rule 81(d) | C (centred); not adopted (roman front matter) |
| CIT-FORM-012 | Top margin carries no text of ours: CM/ECF stamps "Case 1:yy-cv-nnnnn-XXX Document n Filed mm/dd/yy Page n of N" there on every page (all five exemplars). Covered by CIT-FORM-002/010. | exemplars | C |

### Caption and status of case (Rules 7(b)(2), 10(a), 81(c), 81(g); Forms General Instructions)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CIT-COVER-001 | Every pleading has "a caption with the court's name, a title, a court number, and a Rule 7(a) designation." Motions and other papers follow the same rules of form (Rule 7(b)(2)) and "must bear a caption in conformity with Rule 7" (Rule 81(c)). | Rule 10(a), USCIT p. 53; Rule 7(b)(2), p. 44; Rule 81(c), p. 276 | M |
| CIT-COVER-002 | The court's name reads "United States Court of International Trade" (Form 1 and the General Instructions' caption "similar to that of the summons"). | Rule 10(a); FORMS General Instruction 3, USCIT p. 321; Form 1, p. 352 | M (name); C (all caps, centred: all five exemplars; "IN THE" prefix in EX-GREATRIVER only, filer style) |
| CIT-COVER-003 | Papers filed after commencement identify, "to the right of the caption", the court number, the court calendar if any (Reserve, Suspension, or Suspension Disposition), and, if assigned, the judge. | Rule 81(g), USCIT p. 277; FORMS General Instruction 6, p. 321 | M |
| CIT-COVER-004 | Caption party block: parties on the left with their designation ("Plaintiff," / "Defendant."), "v." between sides, court number to the right. Separator style differs by filer: ")" column (EX-BGH, EX-GREATRIVER), ":" column (seen in two other CIT complaints read for this file but not kept as exemplars: Southern Marsh Collection, Ct. No. 20-01998, ECF 2, and Eteros Technologies USA, Ct. No. 25-00036, ECF 2), horizontal rules (EX-TREK), no separator (EX-SAHAMITR, EX-DEERPARK). The ")" column or no separator are both conventional; pick one. | exemplars | C |
| CIT-COVER-005 | Each paper is signed by at least one attorney of record in the attorney's name; each paper states the signer's address, e-mail address and telephone number. If the attorney of record is a firm, the firm name and the responsible individual attorney appear. | Rule 11(a), USCIT p. 54; Rule 81(c); FORMS General Instruction 7, p. 321 | M |
| CIT-COVER-006 | Signature block right of centre after "Respectfully submitted," with "/s/ Name", then counsel's names, firm, address, telephone, e-mail and "Counsel for [party]", then the date. Seen in all five exemplars (EX-TREK, EX-SAHAMITR, EX-DEERPARK, EX-BGH, EX-GREATRIVER). | exemplars | C |

### Electronic filing (Rule 5(d)(3), Rule 81(b), AO 02-01)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CIT-ELEC-001 | Papers filed electronically "must be filed in Portable Document Format (PDF) and must be text-searchable to the maximum extent possible." Check: text extracts on every page; fonts embedded. | Rule 81(b), USCIT p. 276 | M |
| CIT-ELEC-002 | A represented person must file electronically. | Rule 5(d)(3)(A), USCIT p. 31 | M |
| CIT-ELEC-003 | Electronic signature: the document filed with the Signatory's CM/ECF login "shall indicate an 'electronic signature', e.g., 's/Jane Doe'", on the page where a physical signature would appear. | AO 02-01 ¶ 5(b), USCIT pp. 442-443; Rule 5(d)(3)(C), p. 31 | M |
| CIT-ELEC-004 | Confidential or business proprietary information is enclosed in brackets; a non-confidential version accompanies the confidential one; the cover of each set is labeled "Confidential" / "Nonconfidential" (or "Business Proprietary" where Rule 73.2(c) applies), and each page with confidential material (or from which it was deleted) bears a legend. | Rule 5(g), USCIT p. 33; Rule 81(h), pp. 277-278 | M (when the paper contains such information) |
| CIT-ELEC-005 | No certificate of service is required when a paper is served by filing it through CM/ECF; a paper served by other means carries a certificate of service. | Rule 5(d)(1)(B), USCIT pp. 29-30 | M (conditional) |
| CIT-ELEC-006 | Public-version legend at upper right of the caption ("PUBLIC VERSION", with the pages from which business proprietary information was removed) when a confidential version exists. Seen in EX-BGH and EX-GREATRIVER (two filers). | exemplars; implements CIT-ELEC-004 | C |
| CIT-ELEC-007 | Privacy redaction of personal identifiers. | Rule 5.2, USCIT p. 37 | A |

### Citation form (Rule 81, Practice Comment)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CIT-CONT-001 | Citations to CIT decisions use the official CIT Reports (then F. Supp. if published); CM/ECF documents are cited with the document number (e.g. "ECF No. 22"). Practice Comment guidance, not a rule. | Rule 81 Practice Comment, USCIT pp. 280-282 | A |

## Doc type: complaint

Scope: the complaint commencing (with the summons) or following the summons in a civil action. The complaint is a pleading (Rule 7(a)(1)); length is not limited by any rule.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CIT-CONT-010 | The complaint caption names all the parties. | Rule 10(a), USCIT p. 53; FORMS General Instruction 4, p. 321 | M |
| CIT-CONT-011 | Claims are stated "in numbered paragraphs, each limited as far as practicable to a single set of circumstances"; each claim founded on a separate transaction or occurrence is a separate count where that promotes clarity. | Rule 10(b), USCIT p. 53 | M |
| CIT-CONT-012 | A pleading stating a claim contains: (1) a short and plain statement of the grounds for the court's jurisdiction; (2) a short and plain statement of the claim; (3) a demand for the relief sought. | Rule 8(a), USCIT p. 47 | M |
| CIT-CONT-013 | In a 28 U.S.C. § 1581(a) or (b) action the complaint "should set forth" the Complaint Allegations items: jurisdiction, standing, timely protest, payment of liquidated duties, description of the merchandise, the contested customs decision, demand for judgment; plus the value or classification items when those are contested. ("should": guidance by form, not a mandatory list.) | FORMS "Complaint Allegations" (a)-(d), USCIT pp. 350-351 | A |
| CIT-CONT-014 | In a § 1581(a) action, a new ground not raised in the protest is alleged with the Rule 8(b) statements (same merchandise, same administrative decision). | Rule 8(b), USCIT p. 47 | A |
| CIT-CONT-015 | Unnumbered centred all-caps section headings dividing the allegations, with paragraph numbers running continuously across sections. Seen in EX-TREK, EX-SAHAMITR, EX-DEERPARK (three filers). Typical headings for a § 1581(c) complaint: the determination contested ("ADMINISTRATIVE DECISION TO BE REVIEWED" / "CONTESTED DETERMINATION"), JURISDICTION, STANDING, TIMELINESS, facts, STATEMENT OF CLAIMS / COUNT(s), PRAYER FOR RELIEF (AND JUDGMENT): EX-SAHAMITR and EX-DEERPARK. EX-TREK (a § 1581(i) tariff case) uses CAUSE OF ACTION, PARTIES, JURISDICTION AND STANDING, STATEMENT OF FACTS, COUNT I-V, PRAYER FOR RELIEF. | exemplars | C |
| CIT-CONT-016 | Title "COMPLAINT" centred below the caption, followed by an unnumbered introductory sentence ("Plaintiff ..., by and through its attorneys, alleges and states as follows:"). Seen in all three complaint exemplars. | exemplars | C |
| CIT-CONT-017 | Prayer for relief as a lettered list ("(A)", "(B)" or "(a)", "(b)") ending with "such other and further relief as the Court deems just and proper". Seen in EX-TREK, EX-DEERPARK; EX-SAHAMITR uses a prayer paragraph. | exemplars | C |
| CIT-CERT-010 | In a § 1581(c) action under section 516A, the plaintiff promptly serves the complaint by certified or registered mail on every interested party to the administrative proceeding (Rule 3(f)). The complaint itself need not carry the notice; EX-SAHAMITR attaches a "Notice to Interested Parties" and a "Certificate of Service" listing the parties served (one filer's practice). | Rule 3(f), USCIT p. 7; EX-SAHAMITR | M (service act, author); C (attached notice, one filer) |
| CIT-CERT-011 | Filed with the summons as required by Rule 3(a): concurrently in most actions; within 30 days after the summons in a § 1581(c) action contesting a determination under section 516A(a)(2) or (3). Filing fees, the Information Statement (Form 5) and the disclosure statement (Form 13) are separate filings. | Rule 3(a), (b), (d), (i), USCIT pp. 6-9 | A |
| CIT-LEN-010 | No length limit for a complaint in the Rules or the Standard Chambers Procedures (SCP 2(B) applies to "briefs"). | USCIT; SCP 2, p. 423 | M (no limit) |

## Doc type: motion-brief

Scope: the motion for judgment on the agency record under Rule 56.2 (28 U.S.C. § 1581(c) actions) with the supporting brief in a single document. The responding and reply briefs share the form rules but are not this folder's sample.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CIT-CONT-020 | "The motion for judgment on the agency record and the brief in support thereof must be submitted in a single document." A separate brief must not be filed unless the Court requires one. | Rule 56.2(c)(1), USCIT p. 209; SCP 2(A), p. 423; Rule 7(b)(1)(B), p. 43 | M |
| CIT-CONT-021 | The motion states with particularity the grounds and the legal argument, and states the relief sought. | Rule 7(b)(1)(B), (D), USCIT pp. 43-44 | M |
| CIT-CONT-022 | The motion is "accompanied by a proposed order". Both exemplars put the proposed order in the same PDF (EX-BGH first, EX-GREATRIVER after the brief). | Rule 7(b)(1)(E), USCIT p. 44; exemplars for placement | M (order); C (placement) |
| CIT-CONT-023 | A designation below the caption states the nature of the motion (e.g. "PLAINTIFF'S RULE 56.2 MOTION FOR JUDGMENT ON THE AGENCY RECORD"). | FORMS General Instruction 5, USCIT p. 321 | M |
| CIT-CONT-024 | The brief includes a statement in numbered paragraphs setting out (A) the administrative determination reviewed, with Federal Register reference; (B) the issues of law with the reasons for contesting the determination; (C) the request for court order and relief sought. | Rule 56.2(c)(1), USCIT p. 209 | M |
| CIT-CONT-025 | The brief includes the authorities relied on and the conclusions of law; record references cite the portions of the record (page numbers, exhibit identification); "The brief also must include a table of contents and a table of authorities." | Rule 56.2(c)(2), USCIT p. 210 | M |
| CIT-CONT-026 | A movant's brief contains, under proper headings and in this order: (1) table of contents; (2) table of statutes, regulations and cases cited, cases in alphabetical order; (3) for a specific importation, a description of the merchandise and entry facts; (4) in classification or valuation cases, the verbatim tariff or statutory provisions; (5) the questions presented (for a Rule 56.2 brief, presented per Rule 56.2(c)(1)(B) and not restated); (6) a concise statement of facts with record citations; (7) a summary of argument; (8) the argument; (9) a short conclusion stating the relief sought. Items (3)-(4) apply only in those case types. | Rule 81(j), USCIT pp. 278-279 | M |
| CIT-CONT-027 | Heading and outline: memorandum sections in Roman numerals (I. Rule 56.2 Statement with A. Administrative Determination, B. Issues; II. Statement of Facts; III. Summary of Argument; IV. Argument with A. Standard of Review; V. Conclusion), sub-points A./1. Seen in EX-BGH and EX-GREATRIVER (two filers; EX-GREATRIVER adds an Introduction first and places Summary before Facts). | exemplars | C |
| CIT-CONT-028 | Table of contents with dot leaders and right-aligned page numbers; table of authorities grouped Cases / Statutes / Regulations / Administrative determinations with page references. Seen in EX-BGH and EX-GREATRIVER. | exemplars | C |
| CIT-COVER-020 | The memorandum repeats the full caption on its own first page after the motion (second caption with the memorandum title). Seen in EX-BGH and EX-GREATRIVER. | exemplars | C |
| CIT-LEN-020 | Movant's and respondent's briefs "must not exceed 14,000 words"; reply briefs "must not exceed 7,000 words". Over-length briefs need leave. | SCP 2(B)(1)(a), (c), USCIT p. 423 | M |
| CIT-LEN-021 | "Headings, footnotes, and quotations count toward the word limitations. The corporate disclosure statement, table of contents, table of authorities, any addendum containing statutes, rules or regulations, any certificates of counsel, and counsel's signature block do not count." | SCP 2(B)(1)(c), USCIT p. 423 | M |
| CIT-CERT-020 | "Any brief must include a certificate by the attorney, or an unrepresented party, that the brief complies with the word limitation." It "must state the number of words in the brief and be signed by the person preparing the certificate"; the word-processor count may be relied on. | SCP 2(B)(2), USCIT p. 424 | M |
| CIT-CERT-021 | The certificate's stated count equals an independent count of the counted words and is at most 14,000. | SCP 2(B)(1)(a), (2) | M |
| CIT-CERT-022 | Certificate of compliance on its own final page, titled "CERTIFICATE OF COMPLIANCE", citing the Chambers Procedures and naming the word processor. Seen in EX-BGH and EX-GREATRIVER. | exemplars | C |
| CIT-CONT-029 | Record citations are supported by a joint appendix filed separately by plaintiffs within 14 days after the reply briefs; each attached document has a separator page. Not part of this document. | Rule 56.2(c)(3), USCIT p. 210; SCP 2(A), 2(C), pp. 423-424 | A |
| CIT-CONT-030 | No cross-motions for judgment on the agency record. | Rule 56.2(b), USCIT p. 209 | A |

## Not verified

- **CM/ECF User's Manual** (part of the EFPs by AO 02-01): not read; any PDF size cap or bookmark rule it contains is not recorded here.
- **Individual judges' chambers procedures** may modify the Standard Chambers Procedures; not read.
- **README claims** of a "CIT-PAPER/TYPE/SPACE/NUM/CAP/SIG/STAT/PDF/MOT/WORD" ID set in `complaint/README.md` and `motion-brief/README.md` are superseded by the IDs in this file; the rule quotations they rely on were re-read and match the August 21, 2026 compilation.

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| CIT-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| CIT-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| CIT-TOOL-003 | Every TOC and TOA page reference equals the page on which the heading or citation appears (motion-brief). | T (supports CIT-CONT-025) |
| CIT-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect. | T |
