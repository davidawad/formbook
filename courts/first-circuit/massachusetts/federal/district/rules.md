# District of Massachusetts (civil): rules

Alias `mad`. Scope: civil filings by counsel through CM/ECF in the United States District Court for the District of Massachusetts; doc types `complaint` and `motion-brief` (memorandum of law in support of a motion). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 and whenever the court posts amended local rules (the rules page states the combined PDF's "amendments through" date) or revised CM/ECF Administrative Procedures, at https://www.mad.uscourts.gov/general/rules-home.htm.

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | Local Rules of the U.S. District Court for the District of Massachusetts, "Effective September 8, 2026", "Including Amendments Through September 8, 2026" (combined PDF, 174 pp.; the court's rules page links it as current). Supersedes the 11-1-19 combined copy cited in the doc-type READMEs; the passages quoted here from LR 3.1, 5.1, 5.4, 7.1 and 56.1 appear with the same wording in both copies (compared 2026-10-17). | https://www.mad.uscourts.gov/general/pdf/local-rules/Combined%20Local%20Rules.pdf (linked from https://www.mad.uscourts.gov/general/rules-home.htm) |
| ECF | CM/ECF Case Management/Electronic Case Files Administrative Procedures, "As Amended Through July, 2011" (the version linked from the court's CM/ECF page; LR 5.4(b) requires compliance) | https://www.mad.uscourts.gov/caseinfo/pdf/ECFadminProc.pdf (linked from https://www.mad.uscourts.gov/caseinfo/cmecf-general.htm) |
| FRCP | Federal Rules of Civil Procedure, Rules 5, 5.2, 7, 7.1, 8, 10, 11, 38 | https://www.law.cornell.edu/rules/frcp/rule_5 (and `rule_5.2`, `rule_7`, `rule_7.1`, `rule_8`, `rule_10`, `rule_11`, `rule_38`) |
| EX-C1 | Complaint: Door Systems, Inc. v. Door Systems, Inc., 1:26-cv-14133, Doc. 1 (Hamilton, Brook, Smith & Reynolds) | `complaint/exemplars/SOURCE.md` |
| EX-C2 | Complaint: Clere v. Delta Air Lines, Inc., 1:26-cv-14437, Doc. 1 (Brody, Hardoon, Perkins & Kesten) | `complaint/exemplars/SOURCE.md` |
| EX-M1 | Memorandum: Diaz v. Trustees of Smith College, 3:26-cv-12246, Doc. 11 (Seyfarth Shaw) | `motion-brief/exemplars/SOURCE.md` |
| EX-M2 | Memorandum: Ferrini v. Allied World Assurance Co., 1:26-cv-10838, Doc. 49, for Starr Surplus Lines (Hinshaw & Culbertson) | `motion-brief/exemplars/SOURCE.md` |

Kinds: **M** = mandated by a court rule (FRCP, Local Rules, or the ECF Administrative Procedures the Local Rules incorporate). **C** = convention (seen across exemplars of different filers; the rules leave it open). **T** = project/tooling rule. **A** = author responsibility, not machine-checkable.

Findings:

1. **No typeface, type size, or margin rule.** LR 5.1(a)(2) sets only paper size ("8 1/2" x 11" printable format") and double spacing. The Local Rules and the ECF Administrative Procedures were searched for "font", "point", "margin", "typeface": none sets one. Size and margins are therefore conventions (C) here, unlike most districts.
2. **Memorandum length is 20 pages, double-spaced** (LR 7.1(b)(4)); replies only with leave (LR 7.1(b)(3)).
3. **Meet-and-confer certificate** on every motion (LR 7.1(a)(2)); it belongs to the motion, and a memorandum filed separately need not carry it.
4. **BBO number below the signature** (LR 5.1(a)(1)), unlike the generic "bar number" rule.
5. **ECF file size**: each PDF at most 20 MB per ECF P.2, but the same paragraph says files over seven megabytes are rejected by CM/ECF; the 2011 text is internally inconsistent, so the stricter figure is recorded.
6. **ID families `MAD-CAP-*` and `MAD-SIG-*`** were already referenced by the templates (`typst/mad-*.typ`) before this file existed; they are kept as stable IDs (R8) rather than renamed into `CONT`/`CERT`.

## Court-wide requirements

### Page form (LR 5.1(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MAD-FORM-001 | All documents, except discovery requests and responses, "shall be double-spaced except for the identification of counsel, title of the case, footnotes, quotations and exhibits". Non-conforming documents other than complaints and notices of appeal "shall be returned by the clerk". | LR 5.1(a)(2) (LR) | M |
| MAD-FORM-002 | Typeface: the rules name none. Times New Roman is used by all four exemplars (EX-C1, EX-C2, EX-M1, EX-M2; four filers): a convention. The template's vendored serif may substitute. | LR 5.1 (silent); EX-C1, EX-C2, EX-M1, EX-M2 | C |
| MAD-FORM-003 | "All documents filed in the court shall be adapted for flat filing, be filed in 8 1/2" x 11" printable format" (612 x 792 pt). | LR 5.1(a)(2) (LR) | M |
| MAD-FORM-004 | Type size 12 pt body: no rule; all four exemplars use 12 pt Times New Roman. Margins about one inch: no rule; seen in all four exemplars. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| MAD-FORM-005 | Page numbers centered at the foot of each page (all four exemplars; EX-C1 prints "Page n"). No rule requires numbering. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| MAD-FORM-006 | Every font used is embedded and is the template's declared family. | project | T |
| MAD-FORM-007 | The top margin carries no text: CM/ECF stamps "Case ... Document ... Filed ... Page n of N" there (all four exemplars). | EX-C1, EX-C2, EX-M1, EX-M2 | C |

### Caption and signature (FRCP 10, 11; LR 5.1(a)(1), (c))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MAD-CAP-001 | Caption with the court's name: "UNITED STATES DISTRICT COURT" / "[FOR THE] DISTRICT OF MASSACHUSETTS". (The court name is M; the two-line centered caps form is C, seen in all four exemplars, with or without "IN THE"/"FOR THE".) | FRCP 10(a), 7(b)(2) (FRCP); LR 5.1(a)(1) (LR); EX-C1, EX-C2, EX-M1, EX-M2 | M (content); C (form) |
| MAD-CAP-002 | Caption title: the complaint names all the parties; later papers may name the first party on each side and refer generally to others; the title states the Rule 7(a) designation or the paper's title. | FRCP 10(a) (FRCP) | M |
| MAD-CAP-003 | Caption carries the file (civil action / docket) number. Party block at left, number at right: EX-C1, EX-M1, EX-M2 (three filers); EX-C2 puts the number above the party block (that filer's style). | FRCP 10(a) (FRCP); EX-C1, EX-C2, EX-M1, EX-M2 | M (number); C (placement) |
| MAD-CAP-004 | A request for special process or relief out of the ordinary course is noted on the first page to the right of or immediately beneath the caption, unless noted on the category sheet. | LR 5.1(c) (LR) | M (conditional) |
| MAD-SIG-001 | "The board of bar overseers registration number of each attorney signing such documents, except the United States Attorney and his or her staff, shall be inscribed below the signature." | LR 5.1(a)(1) (LR) | M |
| MAD-SIG-002 | Signed by at least one attorney of record; states the signer's address, e-mail address and telephone number. | FRCP 11(a) (FRCP); LR 5.1(a)(1) (LR) | M |
| MAD-ELEC-003 | Electronic signature: the signature block sets out the attorney's name, bar number, address, telephone number and email address; the ECF user's name is "preceded by a "/s/" and typed in the space where the signature would otherwise appear"; multiple signatories each get a "/s/" block. | ECF M.1, M.2 (ECF) | M |
| MAD-SIG-003 | Signature block in the right half: "Respectfully submitted," party name, "By [its/her] attorneys," then the /s/ line and counsel block, with the date at the left or below. Seen in EX-C2, EX-M1, EX-M2 (three filers). | EX-C2, EX-M1, EX-M2 | C |
| MAD-AUTH-001 | Partially redact SSNs (last four), birth dates (year), minors' names (initials) and financial-account numbers (last four). | FRCP 5.2(a) (FRCP); ECF N (ECF) | A |

### Service (FRCP 5; LR 5.2, 5.4)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MAD-CERT-001 | Certificate of service: "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system"; transmission of the NEF constitutes service on a registered ECF user. When served by other means, a certificate is filed with the paper. A one-paragraph ECF certificate is nonetheless appended in EX-C2, EX-M1 and EX-M2 (three filers): convention. | FRCP 5(d)(1)(B) (FRCP); LR 5.4(c) (LR); EX-C2, EX-M1, EX-M2 | M (conditional); C (ECF certificate) |
| MAD-CERT-003 | Papers served after the complaint are served in the manner of FRCP 5, and electronically unless exempt. | LR 5.2(a), 5.4(c) (LR) | M |

### Electronic filing (LR 5.4; ECF Administrative Procedures)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MAD-ELEC-001 | Filed in PDF. Electronically converted (text-searchable) PDFs are "preferred" over scanned ones; the template produces converted PDF. Check: text extracts on every page; fonts embedded. | ECF "Electronic Filing and PDF", D (ECF) | M (PDF); C (text layer preferred) |
| MAD-ELEC-002 | Each PDF file at most 20 MB; "PDF files larger than seven megabytes will be rejected by the CM/ECF system" (the check uses 7 MB). | ECF P.2 (ECF) | M |
| MAD-ELEC-004 | No tracking tags, embedded system commands, password protection, access restrictions or other security features, special tags or dynamic features. | ECF G.8 (ECF) | M |
| MAD-ELEC-005 | Hyperlinks only within the document, to CM/ECF documents, or to an internet source of a citation; they may not replace the full citation. | ECF G.7 (ECF) | M (conditional) |
| MAD-ELEC-006 | All pleadings and other papers filed, signed and verified electronically unless exempt; filings follow the ECF Administrative Procedures; documents transmitted after 6:00 p.m. are filed the next day. | LR 5.4(a), (b), (d) (LR) | M |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MAD-CONT-010 | Short and plain statement of jurisdiction, of the claim, and a demand for relief. | FRCP 8(a) (FRCP) | M (A for content) |
| MAD-CONT-011 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts where that promotes clarity. | FRCP 10(b) (FRCP) | M |
| MAD-CONT-012 | Jury demand may be included in the pleading. Title "COMPLAINT AND DEMAND FOR JURY TRIAL" in EX-C1 and EX-C2 (two filers): convention. | FRCP 38(b) (FRCP); EX-C1, EX-C2 | M (conditional); C (title form) |
| MAD-CONT-013 | The party filing the initial pleading also files a civil cover sheet (JS 44) and the local category sheet (separate documents, filed electronically by registered users). | LR 3.1, 5.4(e) (LR) | M (separate document) |
| MAD-CONT-014 | Corporate disclosure statement (FRCP 7.1) is a separate filing, not part of the complaint. | FRCP 7.1 (FRCP) | M (separate document) |
| MAD-CONT-015 | Section headings centered in bold caps (e.g. INTRODUCTION, PARTIES, JURISDICTION AND VENUE, COUNT I); numbered paragraphs; prayer unnumbered. Seen in EX-C1 and EX-C2 (two filers). | EX-C1, EX-C2 | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MAD-CONT-020 | "A party filing a motion shall at the same time file a memorandum of reasons, including citation of supporting authorities, why the motion should be granted." In CM/ECF a supporting memorandum is filed "as a separate document, using the proper event". | LR 7.1(b)(1) (LR); ECF G.4 (ECF) | M |
| MAD-LEN-001 | "Memoranda supporting or opposing allowance of motions shall not, without leave of court, exceed 20 pages, double-spaced." | LR 7.1(b)(4) (LR) | M |
| MAD-LEN-002 | Reply briefs and other additional papers "may be submitted only with leave of court"; summary-judgment reply within 14 days. | LR 7.1(b)(3), 56.1 (LR) | M |
| MAD-CERT-002 | "No motion shall be filed unless counsel certify that they have conferred and have attempted in good faith to resolve or narrow the issue." (The certificate is on the motion; neither memorandum exemplar carries one.) | LR 7.1(a)(2) (LR) | M (on the motion) |
| MAD-CONT-021 | A request for oral argument goes "in a separate paragraph of the motion or opposition", "set off with a centered caption, 'REQUEST FOR ORAL ARGUMENT.'" | LR 7.1(d) (LR) | M (conditional) |
| MAD-CONT-022 | A summary-judgment motion includes a concise statement of material facts with page references to the record. | LR 56.1 (LR) | M (conditional) |
| MAD-CONT-023 | Ex parte consideration is requested in writing on the face of the motion. | LR 7.1(c) (LR) | M (conditional) |
| MAD-CONT-024 | Title "MEMORANDUM OF LAW IN SUPPORT OF ... MOTION TO DISMISS" in bold caps centered under the caption; centered bold-caps section headings (e.g. BACKGROUND, ARGUMENT, CONCLUSION). Seen in EX-M1 and EX-M2 (two filers). No table of contents in either (both 12 pages). | EX-M1, EX-M2 | C |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| MAD-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| MAD-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| MAD-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect. | T |

Not verified: judges' individual standing orders and session practices (not fetched). The doc-type READMEs' rule citations (LR 3.1, 5.1(a)(1)-(2), 5.1(c), 7.1(a)(2), 7.1(b)(1), 7.1(b)(4), 7.1(d); FRCP 5(d)(1)(B), 10(a)-(b)) were all confirmed against the September 8, 2026 text.
