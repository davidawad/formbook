# District of New Hampshire (civil): rules

Alias `nhd`. Scope: civil filings by counsel through CM/ECF in the United States District Court for the District of New Hampshire; doc types `complaint` and `motion-brief` (a motion with its memorandum of law). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the court's local-rule amendments take effect December 1) and whenever the court posts amended local rules or supplemental ECF rules at https://www.nhd.uscourts.gov/local-rules-0.

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | Local Rules of the U.S. District Court for the District of New Hampshire, effective December 1, 2025 (includes the Supplemental Rules); the court's local-rules page lists it as current | https://www.nhd.uscourts.gov/pdf/2025%20Local%20Rules%20-%20District%20of%20New%20Hampshire.pdf (linked from https://www.nhd.uscourts.gov/local-rules-0) |
| ECF | Supplemental Rules for Electronic Case Filing (Appendix A of LR; "Incorporated as Supplement to Local Rules December 1, 2011, As Amended Through December 1, 2025"), cited "ECF Rule n" | same PDF as LR |
| FRCP | Federal Rules of Civil Procedure, Rules 5, 5.2, 7, 7.1, 8, 10, 11, 38 (current text) | https://www.law.cornell.edu/rules/frcp/rule_5 (and `rule_5.2`, `rule_7`, `rule_7.1`, `rule_8`, `rule_10`, `rule_11`, `rule_38`) |
| EX-C1 | Complaint exemplar: Nicholas v. Federal Express Corp., No. 1:26-cv-00879, Doc. 1 (Douglas, Leonard & Garvey; Lichten & Liss-Riordan) | `complaint/usage/SOURCE.md` |
| EX-C2 | Complaint exemplar: Grant v. Allstate Insurance Co., No. 1:26-cv-00677, Doc. 1 (Kimmel & Silverman) | `complaint/usage/SOURCE.md` |
| EX-M1 | Motion exemplar: Jonas v. Ayotte, No. 1:26-cv-00600, Doc. 14 (N.H. Attorney General) | `motion-brief/usage/SOURCE.md` |
| EX-M2 | Motion exemplar: EEOC v. Coca-Cola Beverages Northeast, No. 1:26-cv-00115, Doc. 6-1 (The Bennett Law Firm) | `motion-brief/usage/SOURCE.md` |

Kinds: **M** = mandated by a court rule (FRCP or the Local Rules). **C** = convention (taken from exemplars of different filers; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings:

1. **No typeface is named.** LR 5.1(a) sets a size floor only ("if a proportionately spaced font is used, no less than twelve (12) point"). Every exemplar uses Times New Roman; that is a convention (C), not a rule.
2. **Page numbers are mandated at the bottom center** (LR 5.1(a): "consecutively numbered in the bottom center of each page").
3. **Length is in pages, not words**, and applies to the memorandum (LR 7.1(a)(3), (e)). There is no word-count certificate.
4. **Certificate of service is not required for ECF service** (FRCP 5(d)(1)(B)); when one is used, LR 5.1(d) prescribes its contents. Both motion exemplars carry an ECF certificate anyway (convention).

## Court-wide requirements

### Page form (LR 5.1(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHD-FORM-001 | 8 1/2 x 11 inch paper (612 x 792 pt). | LR 5.1(a) (LR) | M |
| NHD-FORM-002 | Type: "a font size no smaller than ten (10) characters per inch or, if a proportionately spaced font is used, no less than twelve (12) point". The rule names no typeface and does not exempt footnotes; the checks apply 12 pt to all text. | LR 5.1(a) (LR) | M |
| NHD-FORM-003 | "no less than one (1) inch margins". | LR 5.1(a) (LR) | M |
| NHD-FORM-004 | Pages "consecutively numbered in the bottom center of each page". | LR 5.1(a) (LR) | M |
| NHD-FORM-005 | "double spaced except for quoted material". | LR 5.1(a) (LR) | M |
| NHD-FORM-006 | "Footnotes shall be used sparingly." | LR 5.1(a) (LR) | A |
| NHD-FORM-007 | Typeface Times New Roman 12 pt. Seen in all four exemplars (EX-C1, EX-C2, EX-M1, EX-M2: four filers). Not required by rule; the project's vendored face may substitute. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NHD-FORM-008 | Every font used is embedded and is the template's declared family. | project | T |
| NHD-FORM-009 | Documents not in English are rejected unless translations are furnished. | LR 5.1(h) (LR) | A |

### Caption, identification, signature (LR 5.1(b)-(c), FRCP 10, 11)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHD-CONT-001 | Every filing contains the caption of the case, a description of its contents (the title), and identifies the party on whose behalf it is filed. | LR 5.1(c) (LR) | M |
| NHD-CONT-002 | Filings after the initial one show the docket number "including the suffix which indicates the initials of the presiding judge". | LR 5.1(c) (LR) | M |
| NHD-CONT-003 | A request for special process or relief out of the ordinary course is noted on the first page, immediately to the right of or beneath the caption; a request for expedited treatment is "expressly noted in the motion caption". | LR 5.1(c), LR 7.1(f) (LR) | M (conditional) |
| NHD-CONT-004 | Caption: the court's name, a title, a file number, and a Rule 7(a) designation; the rules of caption and form for pleadings apply to motions. | FRCP 10(a), 7(b)(2) (FRCP) | M |
| NHD-CERT-001 | Attorney's name, address, primary telephone number, email address and New Hampshire bar number (or equivalent) appear on all filings; "The bar number shall immediately follow the attorney's typed name in the signature section". | LR 5.1(b) (LR); ECF Rule 2.7(a) (ECF) | M |
| NHD-CERT-002 | Signed by at least one attorney of record, stating the signer's address, e-mail address and telephone number. | FRCP 11(a) (FRCP) | M |
| NHD-ELEC-003 | Electronic signature: "/s/ [Insert Signatory's Name]" typed where the signature would appear (or a digital signature); each additional signatory gets its own "/s/" block. | ECF Rule 2.7(a), (b)(1) (ECF) | M |
| NHD-FORM-010 | Signature block in the right half of the last page, "Respectfully submitted," then party / "By ... attorneys," then the /s/ line and counsel block. Seen in EX-C1, EX-C2, EX-M2 (three filers); EX-M1 similar. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NHD-FORM-011 | Court name centered in caps in two lines ("UNITED STATES DISTRICT COURT" / "[FOR THE] DISTRICT OF NEW HAMPSHIRE"), the "IN THE" and "FOR THE" forms both occur (EX-C1/EX-M1/EX-M2 vs EX-C2). Party block at left, case number at right; the ")" column is used by EX-M1 only (one filer's style). Title in bold caps, centered, below the caption. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| NHD-AUTH-001 | Redact social-security and taxpayer numbers, birth dates, minors' names and financial-account numbers to the permitted partial form. | FRCP 5.2(a) (FRCP) | A |

### Certificate of service (FRCP 5(d)(1)(B), LR 5.1(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHD-CERT-003 | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system; when a paper is served by other means a certificate is filed with it. | FRCP 5(d)(1)(B) (FRCP) | M |
| NHD-CERT-004 | When a certificate is used it "shall state the name and address of the attorney or party served, the manner of service, the date of service, and shall be personally signed"; if conventionally served, it also states the date of electronic filing. | LR 5.1(d) (LR) | M (conditional) |
| NHD-CERT-005 | A one-paragraph ECF certificate of service is appended to motions even though FRCP 5(d)(1)(B) makes it unnecessary. Seen in EX-M1 and EX-M2 (two filers). | EX-M1, EX-M2 | C |

### Electronic filing (ECF Rule 2.3)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHD-ELEC-001 | Main documents are filed "in an electronically converted PDF text searchable format" (not scanned). Check: text extracts on every page; fonts embedded. | ECF Rule 2.3(a) (ECF) | M |
| NHD-ELEC-002 | No individual PDF exceeding 100 megabytes. | ECF Rule 2.3(b) (ECF) | M |
| NHD-ELEC-004 | No tracking tags, embedded system commands, password protection, access restrictions or other security features, special tags or dynamic features. | ECF Rule 2.3(j) (ECF) | M |
| NHD-ELEC-005 | Electronic filings meet the paper formatting and page-limit rules. | ECF Rule 2.3(d) (ECF) | M |
| NHD-ELEC-006 | Hyperlinks allowed only within the document, to CM/ECF documents, or to an internet source of a citation; they may not replace a full citation. | ECF Rule 2.3(i) (ECF) | M (conditional) |
| NHD-ELEC-007 | The top margin carries no text: CM/ECF stamps "Case ... Document ... Filed ... Page n of N" there (visible in all four exemplars). Covered by NHD-FORM-003. | EX-C1, EX-C2, EX-M1, EX-M2 | C |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHD-CONT-010 | A short and plain statement of the grounds for jurisdiction; a short and plain statement of the claim; a demand for the relief sought. | FRCP 8(a)(1)-(3) (FRCP) | M (A for content) |
| NHD-CONT-011 | The title of the complaint names all the parties. | FRCP 10(a) (FRCP) | M |
| NHD-CONT-012 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts for claims on separate transactions where that promotes clarity. | FRCP 10(b) (FRCP) | M |
| NHD-CONT-013 | Jury demand endorsed on the complaint: a notation on the front page "immediately following the title of the filing, stating 'Demand for Jury Trial' or an equivalent statement". (EX-C1 and EX-C2 both place "JURY TRIAL DEMANDED"/"Jury Trial Demanded" in the caption at the right; Grant also ends with a "DEMAND FOR JURY TRIAL" section.) | LR 38.1 (LR); FRCP 38(b) (FRCP) | M (conditional); C (placement in caption) |
| NHD-CONT-014 | Initial filing accompanied by a completed civil cover sheet (separate form; pro se exempt). | LR 3.1(b) (LR) | M (separate document) |
| NHD-CONT-015 | Summons or notice of lawsuit and waiver request delivered with the complaint (separate forms). | LR 4.1 (LR); ECF Rule 2.4(a) (ECF) | M (separate document) |
| NHD-CONT-016 | Nongovernmental corporate and diversity disclosure statements are filed as separate documents (Civil Forms 4 and 4.1), not inside the complaint. | LR 7.1.1(a)-(c) (LR); FRCP 7.1 (FRCP) | M (separate document) |
| NHD-CONT-017 | Section headings centered in bold caps (e.g. "JURISDICTION AND VENUE", "PARTIES"), numbered allegations with first-line indent, prayer ("WHEREFORE") unnumbered. Seen in EX-C1 and EX-C2 (two filers). | EX-C1, EX-C2 | C |
| NHD-CERT-010 | No certificate of service on the complaint (served with the summons under FRCP 4; ECF Rule 2.4(b): case-opening complaints "may not be served electronically"). Neither complaint exemplar has one. | ECF Rule 2.4(b) (ECF); EX-C1, EX-C2 | M |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHD-CONT-020 | A motion is in writing, states with particularity the grounds, and states the relief sought. | FRCP 7(b)(1) (FRCP) | M (A for content) |
| NHD-CONT-021 | The title contains the word "motion"; separate motions for separate and distinct relief; an objection and an affirmative motion are not combined. | LR 7.1(a)(1) (LR) | M |
| NHD-CONT-022 | Every motion is accompanied by a memorandum with citations to supporting authorities (or a statement why none is needed). In ECF the memorandum is filed as the first attachment to the motion (EX-M2 is such an attachment, Doc. 6-1); EX-M1 combines motion and memorandum in one document. | LR 7.1(a)(2) (LR); ECF Rule 2.3(e) (ECF) | M |
| NHD-LEN-001 | Memorandum length, without prior leave: nondispositive motion at most 15 pages; dispositive motion at most 25 pages. "Dispositive" means injunctive relief, FRCP 12(b) or (c), summary judgment, class-action dismissal or maintenance, involuntary dismissal. | LR 7.1(a)(3), 7.1(g) (LR) | M |
| NHD-LEN-002 | Reply memorandum on a dispositive motion: within 7 days, at most 10 pages; nondispositive reply only with leave, at most 5 pages; surreply at most 5 pages. | LR 7.1(e)(1)-(3) (LR) | M |
| NHD-CONT-023 | Nondispositive motions certify a good-faith attempt to obtain concurrence; if obtained, the motion says so and its title contains "assented-to". | LR 7.1(c) (LR) | M (conditional) |
| NHD-CONT-024 | A summary-judgment memorandum incorporates a short and concise statement of material facts with record citations. | LR 56.1(a)-(b) (LR) | M (conditional) |
| NHD-CONT-025 | Request for oral argument is made by a written statement of reasons. | LR 7.1(d) (LR) | A |
| NHD-CONT-026 | Body sections with centered bold-caps headings (e.g. INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION). Seen in EX-M1 and EX-M2 (two filers). No table of contents in either (memoranda at or under 25 pages). | EX-M1, EX-M2 | C |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| NHD-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| NHD-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| NHD-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect. | T |

Not verified (not written as M): none of the README claims was left unverified; the README's citations (LR 3.1(b), 4.1, 5.1(a)-(d), 7.1(a), (c), (e), (g); FRCP 5(d)(1)(B), 8(a), 10(a)-(b)) were all confirmed against the texts above.
