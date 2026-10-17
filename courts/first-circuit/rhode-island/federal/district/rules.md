# D.R.I. (District of Rhode Island) civil filings: rules

Alias `rid`. Scope: counseled civil filings in the United States District Court for the District of Rhode Island, filed through CM/ECF: the complaint (`complaint/`) and the memorandum of law in support of a motion, here a Rule 12(b)(6) motion to dismiss (`motion-brief/`). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the court's amendments take effect on December 1 or on a stated date, see the "Effective" notes under each rule) and whenever the court posts amended local rules on https://www.rid.uscourts.gov/local-rules-and-procedures.

## Sources

| Tag | Source (rule, version, effective date) | URL |
|---|---|---|
| LR | Local Rules of the United States District Court for the District of Rhode Island, "Effective January 1, 2006, As Amended through April 1, 2024" (the PDF the court links as "Local Rules for the District of Rhode Island"; file name "Approved Dec 2024 Rules"). Includes the ECF rules LR Gen 301 to 314. Page numbers below are the printed page numbers. | https://www.rid.uscourts.gov/sites/rid/files/documents/Approved%20Dec%202024%20Rules.pdf |
| LR-PAGE | Court's "Local Rules and Procedures" page (links the PDF above as the current rules; checked 2026-10-17) | https://www.rid.uscourts.gov/local-rules-and-procedures |
| FRCP-5.2 | Fed. R. Civ. P. 5.2 (privacy protection) | https://www.law.cornell.edu/rules/frcp/rule_5.2 |
| FRCP-7 | Fed. R. Civ. P. 7 (pleadings; form of motions) | https://www.law.cornell.edu/rules/frcp/rule_7 |
| FRCP-7.1 | Fed. R. Civ. P. 7.1 (disclosure statement) | https://www.law.cornell.edu/rules/frcp/rule_7.1 |
| FRCP-8 | Fed. R. Civ. P. 8 (general rules of pleading) | https://www.law.cornell.edu/rules/frcp/rule_8 |
| FRCP-10 | Fed. R. Civ. P. 10 (form of pleadings) | https://www.law.cornell.edu/rules/frcp/rule_10 |
| FRCP-11 | Fed. R. Civ. P. 11 (signing) | https://www.law.cornell.edu/rules/frcp/rule_11 |
| FRCP-12 | Fed. R. Civ. P. 12 (defenses; motion to dismiss) | https://www.law.cornell.edu/rules/frcp/rule_12 |
| FRCP-38 | Fed. R. Civ. P. 38 (jury demand) | https://www.law.cornell.edu/rules/frcp/rule_38 |
| EX-C1 | Complaint, Nightingale v. City of Providence, 1:26-cv-00213 (Robinson & Clapham) | `complaint/exemplars/SOURCE.md` |
| EX-C2 | Complaint, Melo v. Lifespan Physician Group of Mass., 1:26-cv-00539 (Law Offices of Peter N. Wasylyk; Schubert Jonckheer & Kolbe) | `complaint/exemplars/SOURCE.md` |
| EX-C3 | Complaint, Gifford v. Beacon Mutual Ins. Co., 1:26-cv-00340 (Leone Law LLC; Ahdoot & Wolfson) | `complaint/exemplars/SOURCE.md` |
| EX-M1 | Memorandum, Tablada v. Rocket Mortgage, 1:26-cv-00118, ECF 7 (Brock and Scott, PLLC) | `motion-brief/exemplars/SOURCE.md` |
| EX-M2 | Memorandum, United States v. Amore, 1:25-cv-00639, ECF 26-1 (R.I. Office of the Attorney General) | `motion-brief/exemplars/SOURCE.md` |

Kinds: **M** = mandated by a court rule (Local Rule or Federal Rule). **C** = convention (the rules leave it open; taken from exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings:

1. **Font size is the only type rule; no typeface, no margins.** LR Cv 5(a)(3) (LR p. 67): "all documents shall be double-spaced and typed in at least 12-point font. Footnotes shall be in at least 10-point font and may be single-spaced." No local rule names a typeface or sets margins. Typeface and margins are therefore C.
2. **Page numbers at the bottom center** of every page of a document longer than one page (LR Cv 5(a)(3)). Two exemplars do not follow it (Nightingale has no page numbers; Tablada numbers at the bottom right above a running footer); the rule governs.
3. **Memorandum is an attachment, not a separate entry.** LR Cv 7(a)(2)(B) (LR p. 71): a memorandum of law "must be served as an attachment to the motion and not as a separate docket entry." Amore (ECF 26-1) follows it; Tablada (ECF 7) does not.
4. **No page or word limit** for a memorandum appears in LR Cv 5 or LR Cv 7 (the full LR text was searched for "page", "exceed", "word" on 2026-10-17). Judges' individual practices were not checked.
5. **Oral-argument statement** is required in every motion and response (LR Cv 7(c)).

## Court-wide requirements

### Page form (LR Cv 5(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| RID-FORM-001 | Every page is 8 1/2 by 11 inch ("All documents filed in a civil case shall be on 8½" x 11" paper"). | LR Cv 5(a), LR p. 67 | M |
| RID-FORM-002 | Body text double-spaced ("all documents shall be double-spaced"), "Unless otherwise provided or ordered by the Court". Operational check: baseline pitch in body paragraphs at least twice the type size. | LR Cv 5(a)(3), LR p. 67 | M |
| RID-FORM-003 | Type size: "typed in at least 12-point font". The rule names no typeface. | LR Cv 5(a)(3), LR p. 67 | M |
| RID-FORM-004 | Footnotes "in at least 10-point font and may be single-spaced". | LR Cv 5(a)(3), LR p. 67 | M |
| RID-FORM-005 | "Where a document is more than one page in length, the pages shall be numbered at the bottom center of each page." | LR Cv 5(a)(3), LR p. 67 | M |
| RID-FORM-006 | Typeface: Times New Roman (proportional serif) in all five exemplars (EX-C1, EX-C2, EX-C3, EX-M1 by its glyphs, EX-M2). A convention across filers, not a rule. The template's vendored serif face satisfies RID-FORM-003. | EX-C1..C3, EX-M1..M2 | C |
| RID-FORM-007 | Body size: 12 pt in EX-C2, EX-C3, EX-M1; 14 pt in EX-C1 and EX-M2. Both meet the 12-point minimum; 12 pt is the more common choice. | EX | C |
| RID-FORM-008 | Margins 1 inch left and right (text from x = 72 pt to about 540 pt on every exemplar measured, page 3), with the ECF header stamped in the top margin. No margin rule exists. | EX-C1..C3, EX-M1..M2 | C |
| RID-FORM-009 | Double spacing is Word's "double" for 12-point Times: 27.6 pt baseline pitch, measured in all five exemplars (page 5 or 12). | EX | C |
| RID-FORM-010 | Every font embedded, and only the template's declared family. | project | T |

### Caption, title, signature (LR Cv 5(a)(1), (2), (5); LR Gen 308)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| RID-CAP-001 | "Any pleading or other document asserting a claim or counterclaim of any type shall include the full caption showing the names of all parties." | LR Cv 5(a)(1), LR p. 67; FRCP-10 (a) | M |
| RID-CAP-002 | "Documents filed after a case is docketed shall also include the name, case number and initial(s) of the judge to whom the case has been assigned" (e.g. "1:26-cv-00118-MSM-AEM"). | LR Cv 5(a)(1), LR p. 67 | M |
| RID-CAP-003 | Every caption carries the court's name, a title, a file number and a Rule 7(a) designation; the same caption rules apply to motions and other papers. | FRCP-10 (a); FRCP-7 (b)(2) | M |
| RID-CAP-004 | "All documents shall bear a title that concisely states the precise nature of the document and identifies the party filing it." | LR Cv 5(a)(2), LR p. 67 | M |
| RID-CAP-005 | A request for a TRO, other emergency relief or a three-judge court is "noted in all capital letters on the first page to the right of, or immediately beneath, the case caption". | LR Cv 9, LR p. 72 | M (conditional) |
| RID-CAP-006 | Court name centered in capitals above the caption ("UNITED STATES DISTRICT COURT / [FOR THE] DISTRICT OF RHODE ISLAND"), parties left, case number right. All five exemplars. Whether the party block is closed by a ")" column (EX-M1, EX-M2) or left open (EX-C1, EX-C2, EX-C3) differs by filer: style, not convention. | EX | C |
| RID-SIG-001 | Signed by counsel for the party; "The name, address and telephone number of the individual signing the document shall be typed or printed below the signature. Documents filed by attorneys also shall bear the attorney's bar number, and the name, address, fax number and e-mail address of the attorney's law firm." | LR Cv 5(a)(5), LR p. 67 | M |
| RID-SIG-002 | ECF login is the signature; "All electronically filed documents must include a signature block with the attorney's name, bar registration number, address, telephone number, and e-mail address." Multiple signatories each get a signature block. | LR Gen 308(a), (c), LR p. 61 | M |
| RID-SIG-003 | Signer's address, e-mail address and telephone number stated (FRCP 11(a)). | FRCP-11 (a) | M |
| RID-SIG-004 | Signature typed as "/s/ Name" with the bar number in "(#nnnn)" or "#nnnn" form after the name, and a "Dated:" line. Seen in EX-C2, EX-C3, EX-M2 (and "/s/" in EX-C1, EX-M1). | EX | C |

### Electronic filing (LR Gen 301 to 314)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| RID-ELEC-001 | Documents by admitted attorneys "shall be electronically filed in PDF format using ECF". | LR Gen 301(b), LR p. 55 | M |
| RID-ELEC-002 | Format: "converting the original word processing document into PDF, resulting in what is referred to as a 'native PDF' or 'text PDF.' PDF images created by scanning paper documents should be avoided unless the filer does not possess a word processing file version". Check: text extracts on every page. | LR Gen 303(d), LR p. 57; LR Gen 101(f)(11) | M |
| RID-ELEC-003 | Complaints are filed electronically together with the civil cover sheet and a summons for each defendant. | LR Gen 303(a)(1), LR p. 57 | M (separate filings) |
| RID-ELEC-004 | Filer is responsible for redaction of personal identifiers under FRCP 5.2. | LR Gen 102(a), LR p. 5; FRCP-5.2 (a) | A |
| RID-ELEC-005 | Documents filed under seal are labeled "FILED UNDER SEAL" on the cover page. | LR Gen 102(b)(1), LR p. 5 | M (conditional) |
| RID-ELEC-006 | Top margin left free of text: the court stamps "Case ... Document ... Filed ... Page ... PageID" there (all five exemplars). | EX | C |

Not verified: no file-size cap and no bookmark requirement appear in LR Gen 301 to 314; none is recorded.

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| RID-CONT-001 | A short and plain statement of the grounds for jurisdiction; a short and plain statement of the claim; a demand for the relief sought. | FRCP-8 (a)(1)-(3) | M (content A) |
| RID-CONT-002 | The title of the complaint names all the parties (no "et al." in the complaint's caption). | FRCP-10 (a); LR Cv 5(a)(1) | M |
| RID-CONT-003 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim on a separate transaction in a separate count when that promotes clarity. | FRCP-10 (b) | M |
| RID-CONT-004 | A jury demand in a pleading "shall set forth the demand to the right of the caption, below the case number." | LR Cv 5(a)(4), LR p. 67; FRCP-38 (b) | M (conditional) |
| RID-CONT-005 | The complaint is filed with a completed civil cover sheet identifying related cases. Separate form; not generated. | LR Cv 5(b), LR p. 67 | M (separate) |
| RID-CONT-006 | A nongovernmental corporate party files a Rule 7.1 disclosure statement with its first filing (separate document). | FRCP-7.1 (a), (b) | M (separate) |
| RID-CONT-007 | Case number left blank on the complaint ("C.A. No.", "No.", "Case No." with no number) because it is not yet docketed. EX-C1, EX-C2, EX-C3. | EX | C |
| RID-CONT-008 | "JURY TRIAL DEMANDED" in capitals in the right column of the caption, below the case-number line (EX-C1, EX-C2, EX-C3), and a closing "DEMAND FOR JURY TRIAL" heading before the signature (EX-C2, EX-C3). | EX; LR Cv 5(a)(4) | C |
| RID-CONT-009 | Section headings centered (Introduction / Parties / Jurisdiction and Venue / Facts / Counts / Prayer for Relief); counts headed "COUNT I" etc. with the cause of action beneath. All three complaint exemplars. | EX-C1..C3 | C |
| RID-CONT-010 | Paragraph number at the first-line indent followed by a tab, text wrapping to the left margin (EX-C1, EX-C2, EX-C3). | EX | C |
| RID-CONT-011 | Prayer for relief opens "WHEREFORE" and lists lettered items (EX-C2, EX-C3; EX-C1 uses a WHEREFORE paragraph per count). | EX | C |
| RID-CERT-001 | No certificate of service on the complaint: service is by summons (LR Cv 5.1(a)); LR Cv 5.1(b) applies only to documents "filed after the complaint". None of the complaint exemplars has one. | LR Cv 5.1, LR p. 69; EX | M (absence) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| RID-CONT-101 | A request for a court order is made by written motion stating with particularity the grounds and the relief sought; the motion also states "the legal argument necessary to support it". | FRCP-7 (b)(1); LR Cv 7(a)(1), (a)(2)(A), LR p. 71 | M (content A) |
| RID-CONT-102 | "A separate memorandum of law need not be filed. However, if a party chooses to file a memorandum of law, it must be served as an attachment to the motion and not as a separate docket entry." The template produces the memorandum as an attachable document. | LR Cv 7(a)(2)(B), LR p. 71 | M (filing act) |
| RID-CONT-103 | "All motions and responses shall contain a statement by counsel as to whether oral argument and/or an evidentiary hearing is requested; and, if so, the estimated time that will be required." | LR Cv 7(c), LR p. 71 | M |
| RID-CONT-104 | A response is due within 14 days after service of the motion; a reply within 7 days after service of the response and limited to the response; sur-replies only with leave. | LR Cv 7(a)(3)-(5), LR p. 71 | A |
| RID-CONT-105 | In an appeal from an administrative tribunal, motions and responses include all pertinent citations to the administrative record. | LR Cv 7(b), LR p. 71 | A (conditional) |
| RID-LEN-101 | No page or word limit in the local rules (see Findings, 4). The template has no length check. | LR Cv 5, LR Cv 7 (silent) | M (none) |
| RID-CONT-106 | The caption carries the docketed case number with the judges' initials (RID-CAP-002). | LR Cv 5(a)(1) | M |
| RID-CONT-107 | Structure: introduction, background/facts, standard (of review), argument with lettered or numbered point headings, conclusion. Seen in EX-M1 and EX-M2. | EX-M1, EX-M2 | C |
| RID-CONT-108 | Table of contents and table of authorities for a long memorandum: present in EX-M2 (50 pages), absent in EX-M1 (14 pages). Not required by rule; one filer only, so it is that filer's style for long briefs (tier 3). | EX-M2 | C (one filer) |
| RID-CONT-109 | Top-level headings centered bold capitals with roman numerals (EX-M1 "I. INTRODUCTION"; EX-M2 roman-numbered argument points). | EX-M1, EX-M2 | C |
| RID-CERT-101 | Certificate of service: required only when a document filed after the complaint is served other than through ECF; it states the date and manner of service, the persons served and the addresses, and is affixed to the document. | LR Cv 5.1(b), LR p. 69 | M (conditional) |
| RID-CERT-102 | Both memorandum exemplars end with a certificate of service stating ECF service, signed "/s/". A convention even when ECF service makes it optional. | EX-M1, EX-M2 | C |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| RID-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| RID-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| RID-REVIEW-001 | A recorded visual review covers every page of every sample (docs/EVAL-LOOP.md, Gate 2). | T |
