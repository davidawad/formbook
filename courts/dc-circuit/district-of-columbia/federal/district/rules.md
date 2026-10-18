# D.D.C. (District of Columbia) civil filings: rules

Alias `dcd`. Scope: counseled civil filings in the United States District Court for the District of Columbia, filed through CM/ECF: the complaint (`complaint/`) and the memorandum of points and authorities in support of a Rule 12 motion to dismiss (`motion-brief/`). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 and whenever the court posts an updated "Local Rules of the U.S. District Court for the District of Columbia" PDF or a rule-change order on https://www.dcd.uscourts.gov/court-info/local-rules-and-orders/local-rules (the current PDF is "Updated: September 2026").

## Sources

| Tag | Source (rule, version, effective date) | URL |
|---|---|---|
| LCvR | Rules of the United States District Court for the District of Columbia, "Effective as of September 2015, Updated: September 2026" (212 pages; PDF created 2026-09-15). Page numbers below are the printed page numbers. Supersedes the April 2017 edition cited in the doc-type READMEs; the LCvR 5.1(d) and 7 text quoted there is unchanged in this edition. | https://www.dcd.uscourts.gov/sites/dcd/files/local_rules/Local%20Rules%20SEP_2026.pdf |
| LR-PAGE | Court's Local Rules page (links the September 2026 PDF as current and lists the rule-change orders; checked 2026-10-17) | https://www.dcd.uscourts.gov/court-info/local-rules-and-orders/local-rules |
| ECF-CL | "ECF Checklist for Attorneys", ECF User's Manual, 2019 (clerk's guidance, not a rule) | https://www.dcd.uscourts.gov/sites/dcd/files/2019ChecklistforAttorneys_0.pdf |
| FRCP-5.2 | Fed. R. Civ. P. 5.2 | https://www.law.cornell.edu/rules/frcp/rule_5.2 |
| FRCP-7 | Fed. R. Civ. P. 7 | https://www.law.cornell.edu/rules/frcp/rule_7 |
| FRCP-7.1 | Fed. R. Civ. P. 7.1 | https://www.law.cornell.edu/rules/frcp/rule_7.1 |
| FRCP-8 | Fed. R. Civ. P. 8 | https://www.law.cornell.edu/rules/frcp/rule_8 |
| FRCP-10 | Fed. R. Civ. P. 10 | https://www.law.cornell.edu/rules/frcp/rule_10 |
| FRCP-11 | Fed. R. Civ. P. 11 | https://www.law.cornell.edu/rules/frcp/rule_11 |
| FRCP-12 | Fed. R. Civ. P. 12 | https://www.law.cornell.edu/rules/frcp/rule_12 |
| FRCP-38 | Fed. R. Civ. P. 38 | https://www.law.cornell.edu/rules/frcp/rule_38 |
| EX-C1 | Complaint, Terre du Soleil v. SBA, 1:26-cv-03510 (Clark Hill PLC) | `complaint/usage/SOURCE.md` |
| EX-C2 | Complaint, SMP v. FEC, 1:26-cv-00336 (Elias Law Group LLP); filer's copy, no ECF stamp | `complaint/usage/SOURCE.md` |
| EX-M1 | Memorandum, Estrada v. American University, 1:26-cv-00603, ECF 9-1 (Saul Ewing LLP) | `motion-brief/usage/SOURCE.md` |
| EX-M2 | Memorandum, Esrati v. FEC, 1:26-cv-01498, ECF 12-1 (FEC Office of General Counsel) | `motion-brief/usage/SOURCE.md` |

Kinds: **M** = mandated by a court rule (Local Rule or Federal Rule). **C** = convention (the rules leave it open; taken from exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings:

1. **12-point type everywhere, footnotes included.** LCvR 5.1(d) (LCvR p. 22): "All pleadings shall appear in 12-pt. font and shall be double-spaced. Footnotes, which shall not be excessive, shall also appear in 12-pt. font." Unlike most districts there is no smaller footnote size. No typeface is named.
2. **No margin rule.** LCvR 5.1(d) prescribes "a standard 8 ½ by 11-inch word processing format" and nothing on margins. Margins are C.
3. **Party addresses in the first filing's caption.** LCvR 5.1(c)(1) (LCvR pp. 21-22): "The first filing by or on behalf of a party shall have in the caption the name and full residence address of the party" (or a sealed notice of the address).
4. **D.C. Bar numbers** for every listed attorney who is a D.C. Bar member, signing or not (LCvR 5.1(c)(1)).
5. **45/25-page limits** for memoranda (LCvR 7(e)), enforced by the Clerk: "Documents that fail to comply with this provision shall not be filed by the Clerk."
6. **Proposed order** accompanies each motion and opposition (LCvR 7(c)); a separate PDF attached to the main document (ECF-CL).
7. **Page numbering is not in the rules.** No LCvR provision requires page numbers or sets their position; every exemplar numbers at the bottom center (C).

## Court-wide requirements

### Page form (LCvR 5.1(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCD-FORM-001 | "Every document shall be typed (double spaced) using a standard 8 ½ by 11-inch word processing format (submitted electronically to the Court in PDF format)". Page size 612 x 792 pt. | LCvR 5.1(d), p. 22 | M |
| DCD-FORM-002 | "All pleadings shall appear in 12-pt. font and shall be double-spaced." Operational check: body type 12 pt; baseline pitch in body paragraphs at least 24 pt. | LCvR 5.1(d), p. 22 | M |
| DCD-FORM-003 | "Footnotes, which shall not be excessive, shall also appear in 12-pt. font." | LCvR 5.1(d), p. 22 | M |
| DCD-FORM-004 | The rule names no typeface. Times New Roman is used by all four exemplars (EX-C1, EX-C2, EX-M1 by glyphs, EX-M2): a convention. | LCvR 5.1(d) (silent); EX | C |
| DCD-FORM-005 | Margins 1 inch left and right (text x = 72 to about 540 pt on every exemplar measured). No margin rule. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| DCD-FORM-006 | Double spacing is Word's "double" for 12-pt Times: 27.6 pt baseline pitch, measured on EX-C1, EX-C2, EX-M1 and EX-M2. | EX | C |
| DCD-FORM-007 | Page number centered at the bottom of each page (all four exemplars); front matter of a memorandum in lowercase roman (EX-M1, EX-M2). No rule requires page numbers. | EX | C |
| DCD-FORM-008 | Every font embedded, and only the template's declared family. | project | T |

### Caption, title, signature (LCvR 5.1(c), (d); FRCP 10, 11)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCD-CAP-001 | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the same rules apply to motions and other papers. | FRCP-10 (a); FRCP-7 (b)(2) | M |
| DCD-CAP-002 | "a heading under the caption describing the nature of the document". | LCvR 5.1(d), p. 22 | M |
| DCD-CAP-003 | "The case number on every document shall be followed by the initials of the judge to whom the case has been assigned. If the case has been referred to a magistrate judge, the magistrate judge's initials shall also be shown." | LCvR 5.1(d), p. 22 | M |
| DCD-CAP-004 | Any exhibit or attachment shows the case number. | LCvR 5.1(d), p. 22 | M |
| DCD-CAP-005 | Court name in capitals, centered ("UNITED STATES DISTRICT COURT / FOR THE DISTRICT OF COLUMBIA", with or without "IN THE"); parties left, "Civil Action No." right. All four exemplars. A ")" column between the two (EX-M2) or none (EX-C1, EX-C2, EX-M1) is filer style. | EX | C |
| DCD-SIG-001 | "All documents signed by an attorney shall contain the name, address, telephone number, and D.C. Bar identification number of the attorney if the attorney is a member of the D.C. Bar. All attorneys listed on any document who are members of the D.C. Bar must include their D.C. Bar identification numbers regardless of whether they sign the document." | LCvR 5.1(c)(1), p. 22 | M |
| DCD-SIG-002 | Signature by an attorney of record, stating the signer's address, e-mail address and telephone number. | FRCP-11 (a) | M |
| DCD-SIG-003 | CM/ECF login and password serve as the signature; the signature line reads "/s/ [Attorney's Typed Name]". | LCvR 5.4(b)(4), p. 26; ECF-CL | M (login) ; C (/s/ form, ECF-CL guidance) |
| DCD-SIG-004 | Bar number written "(D.C. Bar No. nnnnnnn)" after the name (EX-C1, EX-C2, EX-M1, EX-M2); a date line at the left beside "Respectfully submitted," ("Dated:" in EX-C1 and EX-C2; a bare date in EX-M1 and EX-M2). | EX | C |

### Electronic filing and privacy (LCvR 5.4)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCD-ELEC-001 | "all documents to be filed with the Court must be filed by electronic text-searchable means in a manner authorized by the Clerk." Check: text extracts on every page. | LCvR 5.4(a), p. 25 | M |
| DCD-ELEC-002 | A word-processed document "must be converted to PDF format instead of printed and scanned to PDF. Scanning is limited to exhibits only." | ECF-CL p. 1 | C (clerk guidance; supports DCD-ELEC-001) |
| DCD-ELEC-003 | PDF file not more than 35 MB; larger documents split. | ECF-CL p. 1 | C (clerk guidance) |
| DCD-ELEC-004 | Personal identifiers excluded or redacted: last four digits of SSNs and financial-account numbers, initials of minors, year of birth only. | LCvR 5.4(f), p. 27; FRCP-5.2 (a) | A |
| DCD-ELEC-005 | Electronic filing satisfies the certificate-of-service requirement for parties receiving CM/ECF notice; a separate certificate is required only for a party who does not receive electronic notice. | LCvR 5.4(d)(2), p. 26; LCvR 5.3, p. 25 | M (conditional) |
| DCD-ELEC-006 | Top margin left free: the court stamps "Case ... Document ... Filed ... Page ..." there (EX-C1, EX-M1, EX-M2). | EX | C |
| DCD-ELEC-007 | A document not conforming to LCvR 5.1 and FRCP 10(a) draws a deficiency notice; uncorrected by the next business day, it goes to the judge with a recommendation that it be stricken. | LCvR 5.1(g), p. 23; LCvR 5.4(g)(1), p. 27 | M (consequence) |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCD-CONT-001 | Short and plain statement of jurisdiction, of the claim, and a demand for relief. | FRCP-8 (a)(1)-(3) | M (content A) |
| DCD-CONT-002 | The title of the complaint names all the parties. | FRCP-10 (a) | M |
| DCD-CONT-003 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts where that promotes clarity. | FRCP-10 (b) | M |
| DCD-CONT-004 | The caption of the first filing gives "the name and full residence address of the party" for the plaintiff (or omits it and files the address under seal); for a pro se IFP plaintiff, also each defendant's address. | LCvR 5.1(c)(1), pp. 21-22 | M |
| DCD-CONT-005 | No document appended that is not essential to determination of the action. | LCvR 5.1(e), p. 23 | A |
| DCD-CONT-006 | Separate filings with the complaint (not generated): civil cover sheet; related-case form naming any related case (LCvR 40.5(b)(2)); LCvR 26.1 corporate-affiliation certificate and FRCP 7.1 disclosure statement for a corporate party. | LCvR 40.5(b)(2), p. 55; LCvR 26.1, p. 46; FRCP-7.1 | M (separate) |
| DCD-CONT-007 | A jury demand may be included in the pleading. | FRCP-38 (b) | M (conditional) |
| DCD-CONT-008 | Parties listed with street addresses in the caption, the case-number line left blank ("Civil Action No."), the title repeated under the caption. EX-C1 and EX-C2. | EX-C1, EX-C2; LCvR 5.1(c)(1) | C |
| DCD-CONT-009 | Section headings centered; relief headed "PRAYER FOR RELIEF" (EX-C1) or "REQUESTED RELIEF" (EX-C2), opening "WHEREFORE" (EX-C2) with numbered or lettered items. Roman-numbered section headings in EX-C1 only (filer style). | EX | C |
| DCD-CONT-010 | Numbered paragraph with the number at the first-line indent and a tab (EX-C1, EX-C2). | EX | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCD-CONT-101 | A motion states with particularity the grounds and the relief sought. | FRCP-7 (b)(1) | M (content A) |
| DCD-CONT-102 | "Each motion shall include or be accompanied by a statement of the specific points of law and authority that support the motion, including where appropriate a concise statement of facts." This memorandum is that statement. | LCvR 7(a), p. 29 | M |
| DCD-CONT-103 | "If a table of cases is provided, counsel shall place asterisks in the margin to the left of those cases or authorities on which counsel chiefly relies." Neither exemplar's table of authorities carries asterisks; the rule governs. | LCvR 7(a), p. 29 | M (conditional) |
| DCD-CONT-104 | "Each motion and opposition shall be accompanied by a proposed order." Separate PDF, filed as an attachment (ECF-CL). Not generated. | LCvR 7(c), p. 29; ECF-CL p. 1 | M (separate) |
| DCD-LEN-101 | A memorandum in support of or in opposition to a motion "shall not exceed 45 pages and a reply memorandum shall not exceed 25 pages, without prior approval of the Court." | LCvR 7(e), p. 29 | M |
| DCD-CONT-105 | Opposition due within 14 days of service, reply within 7 days after service of the opposition. | LCvR 7(b), (d), p. 29 | A |
| DCD-CONT-106 | A party may request an oral hearing in the motion or opposition (optional). | LCvR 7(f), p. 29 | A |
| DCD-CONT-107 | Duty to confer and the statement of it apply to nondispositive motions only; a Rule 12(b) motion to dismiss is dispositive, so no LCvR 7(m) statement is required. | LCvR 7(m), p. 31 | M (not applicable) |
| DCD-CONT-108 | Table of contents and table of authorities before the body. Both exemplars (EX-M1, 26 pages; EX-M2, 29 pages): a convention, not a rule. | EX-M1, EX-M2 | C |
| DCD-CONT-109 | Structure: introduction, background, argument (with the legal standard per ground), conclusion, then signature. EX-M1 and EX-M2. | EX | C |
| DCD-CONT-110 | Counsel block on the cover page below the title (EX-M2) is that filer's style; EX-M1 puts it only at the end. | EX-M2 | C (one filer) |
| DCD-CERT-101 | Certificate of service required only for a party not receiving CM/ECF notice (DCD-ELEC-005). Neither memorandum exemplar has one. | LCvR 5.4(d)(2); LCvR 5.3 | M (conditional) |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| DCD-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| DCD-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| DCD-REVIEW-001 | A recorded visual review covers every page of every sample (docs/EVAL-LOOP.md, Gate 2). | T |
