# S.D.N.Y. (District Court, Southern District of New York): rules

Alias `nysd`. Scope: civil papers filed by counsel through CM/ECF in the United States District Court for the Southern District of New York; doc types in this folder: `complaint/` (complaint with a jury demand) and `motion-brief/` (memorandum of law in support of a Rule 12(b) motion). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (Federal Rules amendments take effect then) and whenever the court posts amended Joint Local Rules, ECF Rules or Division of Business Rules on https://www.nysd.uscourts.gov/rules. The assigned judge's Individual Practices can add or change rules (word limits, typeface, courtesy copies) and must be checked for each case; they are not recorded here.

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | Local Rules of the United States District Courts for the Southern and Eastern Districts of New York (Joint Local Rules), effective January 2, 2026 (title page; PDF of 2025-12-15, sha256 `439b9e2c67fd4ca1d1be65a7f28ca53707820bcbabb4b459323ade1a773607af`). Linked as current from https://www.nysd.uscourts.gov/rules. | https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf |
| ECF | SDNY Electronic Case Filing Rules, effective February 2, 2026 (41 pages, sha256 `355d3125f5eb8078d6202b7bd96fbd85ccdb0410f25696cb6619964190d5e0bd`). Linked from https://www.nysd.uscourts.gov/rules/ecf-related-instructions. | https://www.nysd.uscourts.gov/sites/default/files/pdf/ecf_rules/ECF%20Rules%20February%202%202026%20FINAL%20v2.pdf |
| DOB | Rules for the Division of Business Among District Judges, S.D.N.Y., effective February 12, 2026 (sha256 `c4c66d57cec8dc9d132f30621911f29154b37e192b7d6b4682329cb24952a184`) | https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-2-12%20SDNY%20Rules%20for%20the%20Division%20of%20Business.pdf |
| FRCP | Federal Rules of Civil Procedure 5.2, 7, 7.1, 8, 10, 11, 12, 38 (Cornell LII, read 2026-10-17) | https://www.law.cornell.edu/rules/frcp/rule_5.2 , .../rule_7 , .../rule_7.1 , .../rule_8 , .../rule_10 , .../rule_11 , .../rule_12 , .../rule_38 |
| EX-C1 | Complaint exemplar 1: Sacchi v. WeBull Financial LLC, 1:26-cv-08973, Doc. 1 (filer: plaintiff, Simoni Consumers Class Action Law Offices) | `complaint/usage/SOURCE.md` entry 1 |
| EX-C2 | Complaint exemplar 2: SEC v. Asudani, 1:26-cv-08626, Doc. 1 (filer: SEC, New York Regional Office staff counsel) | `complaint/usage/SOURCE.md` entry 2 |
| EX-M1 | Motion brief exemplar 1: Minerva Bunkering Pte Ltd. v. Rahman, 1:26-cv-06789-VEC, Doc. 14 (filer: defendants, Holland & Knight LLP) | `motion-brief/usage/SOURCE.md` entry 1 |
| EX-M2 | Motion brief exemplar 2: Better Home & Finance Holding Co. v. Garg, 1:26-cv-07025-CM, Doc. 41 (filer: defendant, Quinn Emanuel Urquhart & Sullivan, LLP) | `motion-brief/usage/SOURCE.md` entry 2 |

Kinds: **M** = mandated by a court rule (Joint Local Rules, SDNY ECF Rules, Division of Business Rules, or the FRCP). **C** = convention (from the exemplars or common practice; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **No typeface is named.** Local Civ. R. 7.1(b) sets size, margins and spacing only. A face is a convention (C). Both motion-brief exemplars and the SEC complaint use Times New Roman (`pdffonts`); EX-M1's certificate attributes Times New Roman 12 pt to Judge Caproni's Individual Practice Rule 4(B)(ii), which is a judge's rule, not a court rule.
2. **Local Civil Rule 11.1 is withdrawn** ("[Withdrawn]", LR p. 22). The form rules now live in Local Civ. R. 7.1(b), which applies to "all documents presented for filing", pleadings included. (ECF Rule 8.2 still cross-refers to "Local Civil Rule 11.1".)
3. **Word limit, not page limit**, for attorney-filed memoranda: 8,750 words (support/opposition), 3,500 (reply); motions for reconsideration 3,500 / 1,750 (Local Civ. R. 6.3). A word-count certificate is mandatory.
4. **PDF/A and text-searchable** filings; 15.0 MB per PDF file (ECF Rules 23.2 to 23.4, raised to 15 MB in the February 2, 2026 revision).
5. **Letter-motions** are Local Civ. R. 7.1(e) in this edition (Local Civ. R. 6.1 still says "7.1(d)"; 7.1(d) is now bankruptcy appeals).

## Court-wide requirements

IDs are stable. `checks.yaml` references them. Never renumber; retire an ID by marking it `(withdrawn)`. NYSD-FORM-001 to -004 keep the meaning they have in the doc-type READMEs.

### Page form (Local Civ. R. 7.1(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYSD-FORM-001 | Type size: "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type." | Local Civ. R. 7.1(b)(1), LR p. 20 to 21 | M |
| NYSD-FORM-002 | Typeface: the rule is silent ("The typeface, margins, and spacing of all documents presented for filing must meet the following requirements" lists size, margins and spacing only). Any face choice is C. Exemplars: Times New Roman in EX-M1 (stated in its certificate), EX-M2 and EX-C2; EX-C1 sets no common face (Cambria / Courier New per `pdffonts`). A judge's Individual Practices may name a face. | Local Civ. R. 7.1(b), LR p. 20; EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NYSD-FORM-003 | Spacing: "all text must be double-spaced, except for headings, text in footnotes, or block quotations, which may be single-spaced." | Local Civ. R. 7.1(b)(3), LR p. 21 | M |
| NYSD-FORM-004 | Margins: "all documents must have at least one-inch margins on all sides." | Local Civ. R. 7.1(b)(2), LR p. 21 | M |
| NYSD-FORM-005 | Paper size: not stated in LR or ECF Rules. Letter (612 x 792 pt) in all four exemplars. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NYSD-FORM-006 | Every font used is embedded, and every embedded font is the template's declared family (no silent fallback to a system font). | project; supports ECF Rule 23.3 | T |
| NYSD-FORM-007 | Page numbers: not regulated. EX-C2, EX-M1 and EX-M2 number pages at the foot, centered (EX-M1 and EX-M2 with roman front matter and arabic body); EX-C1 puts the number at the foot, right (its own style). | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NYSD-FORM-008 | The top margin carries no text: the court's CM/ECF stamp ("Case ... Document ... Filed ... Page x of y") is applied there on every page of all four exemplars. Covered by NYSD-FORM-004. | EX-C1, EX-C2, EX-M1, EX-M2 | C |

### Caption and signature (FRCP 7(b)(2), 10(a), 11(a); ECF Rule 8)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYSD-COVER-001 | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." Motions and other papers: "The rules governing captions and other matters of form in pleadings apply to motions and other papers." | FRCP 10(a); FRCP 7(b)(2) | M |
| NYSD-COVER-002 | Court name as "UNITED STATES DISTRICT COURT / SOUTHERN DISTRICT OF NEW YORK" (two centered lines); parties at left closed by a rule or colon column, file number and paper title at right. Seen in EX-C1 (colon column, "FOR THE SOUTHERN DISTRICT"), EX-C2, EX-M1, EX-M2. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NYSD-COVER-003 | Counsel block (name, address, telephone, e-mail) at the upper left of page 1, above the court name: EX-C2 and EX-M1 do it; EX-C1 and EX-M2 do not. Optional. | EX-C2, EX-M1 (EX-C1, EX-M2 omit) | C |
| NYSD-CERT-001 | Signature: "Every pleading, written motion, and other paper must be signed by at least one attorney of record in the attorney's name ... The paper must state the signer's address, e-mail address, and telephone number." | FRCP 11(a) | M |
| NYSD-ELEC-003 | E-signature: "Electronically filed documents must include a signature block and must set forth the name, address, telephone number and e-mail address ... In the absence of a scanned signature image, the name of the Filing User ... must be preceded by an "S/" typed in the space where the signature would otherwise appear." ECF Rule 13.15: "The attorney's name and contact information, including e-mail address, must appear in the signature block below the signature line." | ECF Rules 8.1, 8.2, 13.15 | M |

### Electronic filing (Local Civ. R. 5.2, 6.1(c); ECF Rules)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYSD-ELEC-001 | PDF/A and text searchable: "All documents electronically filed on the ECF system must be in PDF-A format"; "Documents filed by parties on the ECF system must be in text searchable format." Check: text extracts on every page; fonts embedded. (PDF/A conformance itself is not verified by the current tools; see Not verified.) | ECF Rules 23.2, 23.3; Local Civ. R. 5.2 (ECF instructions on the court website govern) | M |
| NYSD-ELEC-002 | "No single PDF file may be larger than 15.0 megabytes (15.0 mb)." | ECF Rule 23.4 | M |
| NYSD-ELEC-004 | Filing and service via ECF unless exempt. | Local Civ. R. 6.1(c); ECF Rule 14.1 | M |
| NYSD-ELEC-005 | Exhibits are filed as separate, titled attachments, not scanned into the main PDF. (The templates produce no exhibits.) | ECF Rules 5.1, 13.3 | M |
| NYSD-ELEC-006 | Privacy redaction: SSN/TIN last four digits, year of birth, minor's initials, last four digits of financial-account numbers. | FRCP 5.2(a); ECF Rule 21.3 | A |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYSD-CONT-101 | Content of a claim: "(1) a short and plain statement of the grounds for the court's jurisdiction ...; (2) a short and plain statement of the claim showing that the pleader is entitled to relief; and (3) a demand for the relief sought". | FRCP 8(a) | A (M for the filer) |
| NYSD-COVER-101 | Caption with the court's name, a title, a file number and the designation "Complaint"; "The title of the complaint must name all the parties". | FRCP 10(a) | M |
| NYSD-CONT-102 | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." Numbering is M; the single-circumstance limit is author content. | FRCP 10(b) | M (numbering); A (content) |
| NYSD-CONT-103 | An exhibit to a pleading "is a part of the pleading for all purposes"; under ECF Rule 13.3 it is still filed as a separate attachment. | FRCP 10(c); ECF Rule 13.3 | M |
| NYSD-CONT-104 | Jury demand may be included in the pleading (FRCP 38(b)(1): "a written demand—which may be included in a pleading"). Both exemplars put "JURY TRIAL DEMANDED" in the caption and a "JURY DEMAND"/"DEMAND FOR JURY TRIAL" section after the prayer. | FRCP 38(b); EX-C1, EX-C2 | M (if demanded); C (placement) |
| NYSD-CONT-105 | Section headings centered caps (EX-C1, EX-C2); prayer items numbered (EX-C1 arabic, EX-C2 centered roman numerals); one signature block after the jury demand (EX-C2; EX-C1 signs twice, its own style). | EX-C1, EX-C2 | C |
| NYSD-FORM-101 | Form rules NYSD-FORM-001 to -004 apply to the complaint ("all documents presented for filing"). No pleading-paper line numbers are required; neither exemplar uses them. | Local Civ. R. 7.1(b); EX-C1, EX-C2 | M (form); C (no line numbers) |
| NYSD-CERT-101 | Separate filings, not produced by the template: Civil Cover Sheet, filed "in the same manner ... as the complaint" (DOB Rule 4(a), p. 3), with any contention of relatedness and a Related Case Statement (DOB Rule 13(b)(1)); Rule 7.1 disclosure statement for a nongovernmental corporate party (FRCP 7.1(a); supplemental within 14 days, Local Civ. R. 7.1.1); request for issuance of summons with proposed summonses in PDF (ECF Rule 14.4); courthouse certification (ECF Rule 14.5, DOB Rule 18). Attorneys must bring related cases to the court's attention (Local Civ. R. 1.6). | DOB Rules 4(a), 13(b)(1), 18; FRCP 7.1; Local Civ. R. 1.6, 7.1.1; ECF Rules 14.4, 14.5 | A (separate filings) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYSD-CONT-201 | A memorandum of law "setting forth the cases and other authorities relied on in support of the motion, and divided, under appropriate headings, into as many parts as there are issues to be determined". | Local Civ. R. 7.1(a)(2), LR p. 20 | M |
| NYSD-CONT-202 | The motion also needs a notice of motion (specifying the rules or statutes and the relief sought) and supporting affidavits/exhibits; separate papers, not produced by the template. | Local Civ. R. 7.1(a)(1), (3) | A (separate filings) |
| NYSD-LEN-201 | Attorney-filed or computer-prepared briefs "in support of and in response to a motion (except for motions for reconsideration) may not exceed 8,750 words, and reply briefs may not exceed 3,500 words." | Local Civ. R. 7.1(c), LR p. 21 | M |
| NYSD-LEN-202 | Excluded: "the caption, any index, table of contents, table of authorities, signature blocks, or any required certificates"; included: "material contained in footnotes or endnotes." | Local Civ. R. 7.1(c) | M |
| NYSD-LEN-203 | Motions for reconsideration: 3,500 words (support/response), 1,750 (reply), same exclusions; served within 14 days. | Local Civ. R. 6.3, LR p. 19 | M (if that motion) |
| NYSD-LEN-204 | Where the court allows extra length in pages, "each additional page must not contain more than 350 additional words". | Local Civ. R. 7.1(c) | M |
| NYSD-CERT-201 | Certificate of word-count compliance by the attorney: "The certificate must state the number of words in the document." The preparer "may rely on the word count of the word-processing program". | Local Civ. R. 7.1(c) | M |
| NYSD-CERT-202 | The word count in the certificate equals the counted words and is at most the limit in NYSD-LEN-201. | Local Civ. R. 7.1(c) | M |
| NYSD-CONT-203 | Table of contents and table of authorities: not required by LR (only excluded from the count). Both exemplars have both, on roman-numbered pages after a caption cover; EX-M2 adds a table of defined terms (its own style). | Local Civ. R. 7.1(c) (exclusion); EX-M1, EX-M2 | C |
| NYSD-CONT-204 | Section order seen in both exemplars: Preliminary Statement, Background, (Legal Standard: EX-M1 only), Argument (I., II., then A., B., then 1., 2.), Conclusion, signature block. Top-level headings centered caps in both. | EX-M1, EX-M2 | C |
| NYSD-CONT-205 | Placement of the word-count certificate: EX-M1 puts it on its own page after the signature. EX-M2 has none in the filed PDF. One filer only, so placement is that filer's style. | EX-M1 | C |
| NYSD-CONT-206 | Rule 12(b) defenses (e.g. (1) lack of subject-matter jurisdiction, (6) failure to state a claim) "must be made before pleading if a responsive pleading is allowed." | FRCP 12(b) | A |
| NYSD-CONT-207 | Pro se opponent: serve unpublished authorities (Local Civ. R. 7.2) and, for a Rule 12 motion relying on matters outside the pleadings, the Local Civ. R. 12.1 notice with FRCP 56 attached. | Local Civ. R. 7.2, 12.1 | A (conditional) |

## Not verified

- **Judges' Individual Practices.** Each SDNY judge posts Individual Practices (EX-M1's certificate cites Judge Caproni's Rule 4(B)(i)-(ii)). They were not read here and are not court-wide rules. A filer must apply the assigned judge's practices on top of this file.
- **PDF/A conformance.** ECF Rule 23.2 requires PDF-A; none of the four exemplars was checked for a PDF/A identification (the ECF-stamped copies are modified by iText). The templates' PDF/A status is not recorded here.
- **Division of Business Rules** were read only for Rules 4(a) (civil cover sheet), 13(b)(1) (related cases) and the title of Rule 18; the rest of that document was not reviewed.

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| NYSD-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| NYSD-TOOL-002 | No case-specific text and no measured coordinates in a template. | T |
| NYSD-TOOL-003 | Motion brief: every TOC page number and TOA page reference is a page that really carries the heading or citation. | T (supports NYSD-CONT-203) |
| NYSD-REVIEW-001 | A recorded visual review of the current PDF covers every page (docs/EVAL-LOOP.md, Gate 2). | T |

ID crosswalk to the doc-type READMEs (written before this file): NYSD-CAP-001/002 = NYSD-COVER-101; NYSD-PAR-001/002 = NYSD-CONT-102; complaint NYSD-CONT-001 = NYSD-CONT-101; complaint NYSD-CONT-002 = NYSD-CONT-103; motion-brief NYSD-CONT-001 = NYSD-CONT-201; motion-brief NYSD-CONT-002 = NYSD-CONT-202; NYSD-LEN-001 = NYSD-LEN-201/202; NYSD-LEN-002 = NYSD-CERT-201; NYSD-TOC-001 = NYSD-CONT-203; NYSD-RULE-001 = NYSD-CONT-206.
