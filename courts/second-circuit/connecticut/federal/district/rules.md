# District of Connecticut (civil): rules

Alias `ctd`. Scope: civil pleadings and memoranda of law filed by counsel through CM/ECF in the United States District Court for the District of Connecticut. Doc types in this folder: `complaint` (complaint with jury demand) and `motion-brief` (memorandum of law in support of a motion to dismiss). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (national rule amendments) and whenever the court posts an amended Local Rules PDF or a revised Electronic Filing Policies and Procedures on https://www.ctd.uscourts.gov/court-info/local-rules-and-orders (the Local Rules PDF linked there was renamed from "9.4.26" to "10.13.26" between 2026-10-14 and 2026-10-17).

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | D. Conn. Local Rules of Civil Procedure, Local Rules for Magistrate Judges, Local Rules of Criminal Procedure ("Amended December 1, 2009"; each rule carries its own amendment date). PDF linked from the court's Local Rules page as current; PDF created 2026-10-13; 174 pages; sha256 7276a8de62373432011f35807dca01ce7ef5a7879d87a7e7a6f3d8f90d7d6264. Rules read: 1, 3 (am. Jan. 12, 2026), 4, 5 (am. Jan. 18, 2017), 7 (am. Jan. 12, 2024), 8, 10 (am. Nov. 7, 2016), 12 (am. Nov. 7, 2016), 40 (am. Apr. 10, 2017). | https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-10.13.26.pdf (linked from https://www.ctd.uscourts.gov/court-info/local-rules-and-orders) |
| EFPP | Electronic Filing Policies and Procedures, Revised October 3, 2025 (17 pages; sha256 25549742a84c7e89ce5d216ddbcaf4a0ac493e5683132afedae895b65a4f76a6). Sections I.F (format, font, form), II, III.C (privacy), XI (signatures). | https://www.ctd.uscourts.gov/sites/default/files/Electronic-Filing-Policies-and-Procedures-10.3.25.pdf |
| FRCP | Federal Rules of Civil Procedure 5.2, 7, 8, 10, 11, 38 (LII text). | https://www.law.cornell.edu/rules/frcp/rule_10 (and rule_5.2, rule_7, rule_8, rule_11, rule_38) |
| EX-C | Complaint exemplars, `complaint/usage/` (Forzano, Kimmel & Silverman; Whitfield, Perrong Law; Patel, Consumer Attorneys). Visual reference only. | see `complaint/usage/SOURCE.md` |
| EX-M | Memorandum exemplars, `motion-brief/usage/` (MedGuard Alert, Howard Kohn / Sultzer & Lipari; Bondi, U.S. Attorney's Office D. Conn.; Liberty Bank, Carlton Fields). Visual reference only. | see `motion-brief/usage/SOURCE.md` |

Kinds: **M** = mandated by a court rule (Local Rule, EFPP, or FRCP). **C** = convention (the rules leave it open; taken from exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **No typeface is named.** EFPP I.F.2 is a font-*embedding* rule: "electronic records that have been converted to PDF from other word processing software must include embedded fonts ... All fonts embedded in PDF records must be publicly identified as legally embeddable". It lists the "base 14 fonts" (Courier, Arial MT, Times New Roman PS MT, Symbol, ZapfDingbats) only as the fonts that need not be embedded. Neither L. Civ. R. 7 nor 10 names a face. Times New Roman in every exemplar is a convention (C), not a rule.
2. **Type size is set only for memoranda.** L. Civ. R. 7(a)(5): "text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font." L. Civ. R. 10 (pleadings) states no size.
3. **Length is in pages, not words.** Memoranda: "no more than forty (40) 8 1/2" by 11" printed pages, exclusive of pages containing a table of contents, table of statutes, rules or the like" (L. Civ. R. 7(a)(5)); reply memoranda "may not exceed 10 pages" (L. Civ. R. 7(d)). No word count or certificate of compliance is required.
4. **The caption carries the date and the judge's initials** (L. Civ. R. 10). Two of six exemplar filers (Bondi, Liberty Bank) date the caption; the others do not. The rule governs.
5. **Top and bottom margins are not set by rule.** L. Civ. R. 10 sets only "left and right margins of at least 1"". 1 inch top and bottom is a convention.
6. **Certificate of service is optional under CM/ECF.** L. Civ. R. 5(c): "Where service is made on all parties through the court's CM/ECF system, the transmission notice on the Notice of Electronic Filing shall be deemed a sufficient certificate of service."

## Court-wide requirements

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTD-FORM-001 | Pages are 8 1/2 by 11 inch (612 x 792 pt). Rule text: pleadings "on 8-1/2" by 11" pages"; memoranda counted in "8 1/2" by 11" printed pages". | L. Civ. R. 10 (LR); L. Civ. R. 7(a)(5) (LR) | M |
| CTD-FORM-002 | Left and right margins at least 1 inch: "left and right margins of at least 1"". | L. Civ. R. 10 (LR) | M |
| CTD-FORM-003 | Top and bottom margins: not set by any rule read; the template uses 1 inch (a convention, not measured off the exemplars). The CM/ECF header stamp ("Case ... Document ... Filed ... Page ... of ...") sits in the top margin. | EX-C, EX-M | C |
| CTD-FORM-004 | Pleadings "shall be double-spaced". | L. Civ. R. 10 (LR) | M |
| CTD-FORM-005 | Page numbers "in the bottom margin of each page after page 1". Page 1 may be unnumbered. Centred at the foot in every exemplar; page 1 unnumbered in Whitfield (complaint), Patel, Bondi and Liberty Bank, numbered in Forzano: either is permitted. | L. Civ. R. 10 (LR); placement EX-C, EX-M | M (presence after p. 1); C (centred) |
| CTD-FORM-006 | Typeface: no rule names one (see Findings 1). Every exemplar from all six filers is set in Times New Roman (pdffonts). The template's choice of face is therefore C; a Times-metric face matches the exemplars, any legally embeddable proportional face satisfies the rules. | EFPP I.F.2; L. Civ. R. 7, 10 (silent); EX-C, EX-M | C |
| CTD-FORM-007 | Every font used in the PDF is embedded (subsets permitted) and legally embeddable: "PDF records that reference fonts other than the 'base 14 fonts' must have those fonts referenced in the record (i.e., as a minimum, subsets of all referenced fonts) embedded within the PDF file." | EFPP I.F.2 | M |
| CTD-FORM-008 | Every embedded font is the template's declared family (no fallback to a system font). | project rule | T |
| CTD-FORM-009 | Documents "must meet the requirements of Fed. R. Civ. P. 10 ... Local Rule of Civil Procedure 5 ... Local Rule of Civil Procedure 10 ... and Local Rule of Civil Procedure 40", and are "subject to any page limitations set forth by Court order or by Local Rule of Civil Procedure 7". | EFPP I.F.1 | M |

### Caption (every pleading and paper)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTD-CAP-001 | Caption with "the court's name, a title, a file number, and a Rule 7(a) designation." The complaint's title "must name all the parties"; other pleadings may name the first party on each side and refer generally to the others. Motions and other papers follow the same caption rules. | FRCP 10(a); FRCP 7(b)(2) | M |
| CTD-CAP-002 | "The complete docket number, including the initials of the Judge to whom the case has been assigned, shall be typed on each pleading." (An initiating complaint is filed before assignment; the number and initials are then not yet known.) | L. Civ. R. 10 (LR) | M |
| CTD-CAP-003 | "The date of each pleading shall be included in the case caption." | L. Civ. R. 10 (LR) | M |
| CTD-CAP-004 | Court name set as two centred capital lines ("UNITED STATES DISTRICT COURT" / "DISTRICT OF CONNECTICUT", with or without "IN THE ... FOR THE") above the caption: all six filers. Caption form varies by filer: a party block with a ruled or ")" right edge and the number at right (Forzano, Whitfield complaint and memorandum, Patel), or the Connecticut colon column with the date at the lower right (Bondi, Liberty Bank). Both are conventions; neither is mandated. | EX-C, EX-M | C |

### Signature and filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTD-ELEC-001 | Filed in PDF, "OCR text searchable" (text extracts on every page); generated from the word processor, not scanned. | EFPP II; L. Civ. R. 3(a)(1), 5(a) | M |
| CTD-ELEC-002 | A single filed document "must not exceed 75 mb (75,000 kb) in size" or must be split into parts of 75 MB or less. | EFPP I.F.3 | M |
| CTD-ELEC-003 | Electronic signature: the filed document "shall indicate a signature, e.g., "/s/Jane Doe."" The name of the password registrant "should be preceded by a "/s/" or "s/" or "/s" and typed in the space where the signature would otherwise appear". | EFPP XI.A, XI.B | M |
| CTD-ELEC-004 | Signature block contains "the attorney's typewritten name, the office address, telephone number, fax number, e-mail address and federal bar number". L. Civ. R. 10: these appear "directly beneath the signature" ("fax number and e-mail address, if available"); "The federal bar number assigned to counsel should appear beneath his/her signature." FRCP 11(a): signed by an attorney of record, stating "the signer's address, e-mail address, and telephone number." | EFPP XI.B; L. Civ. R. 10 (LR); FRCP 11(a) | M |
| CTD-ELEC-005 | Bar number printed as "ct" + digits after the signer's name or on its own line (Forzano, Bondi, Liberty Bank) or as "D. Ct. # CT..." (Whitfield complaint); the block sits at the right half of the page in all six filers. | EX-C, EX-M | C |
| CTD-ELEC-006 | Redact personal data identifiers: minors to initials, financial account numbers and Social Security numbers to the last four digits, dates of birth to the year (home address to city and state in criminal cases only). | EFPP III.C; FRCP 5.2(a) | A |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTD-CONT-001 | A claim for relief contains "(1) a short and plain statement of the grounds for the court's jurisdiction ...; (2) a short and plain statement of the claim showing that the pleader is entitled to relief; and (3) a demand for the relief sought". The template provides the sections; the content is the author's. | FRCP 8(a) | A (M for the filer) |
| CTD-CONT-002 | Claims stated "in numbered paragraphs, each limited as far as practicable to a single set of circumstances"; each claim founded on a separate transaction or occurrence in a separate count where that promotes clarity. | FRCP 10(b) | M (numbered paragraphs); A (grouping) |
| CTD-CONT-003 | Jury demand: may be "included in a pleading". "A Civil Cover Sheet indicating that a jury trial is desired shall not suffice as a demand for jury trial." All three complaint filers put "DEMAND FOR JURY TRIAL" in the title and as a final section; Whitfield and Patel also print "JURY TRIAL DEMANDED" or "DEMAND FOR JURY TRIAL" in the caption's right column. | FRCP 38(b); L. Civ. R. 3(a)(2) (LR); placement EX-C | M (if a jury is wanted); C (placement) |
| CTD-CONT-004 | Sections seen in all three filers, as centred capital headings: caption and title; unnumbered lead-in; PARTIES and JURISDICTION AND VENUE (in either order: Forzano puts jurisdiction first, Whitfield and Patel parties first); factual allegations or background; counts ("COUNT I" in Whitfield and Patel, "FIRST CAUSE OF ACTION" in Forzano); PRAYER FOR RELIEF; DEMAND FOR JURY TRIAL; date and signature block. Order within the opening sections and count labels are filer style. | EX-C | C |
| CTD-CONT-005 | Paragraph numbers in the left margin indent of a first-line-indented paragraph, continuation lines back to the margin (Forzano, Whitfield, Patel). | EX-C | C |
| CTD-CONT-006 | Separate filings, not part of the complaint: civil cover sheet and summons (L. Civ. R. 3(a)(2), for paper-filed complaints), Notice of Related Case where relatedness is suggested (L. Civ. R. 40(b)(2)), FRCP 7.1 disclosure statement. Not templated. | L. Civ. R. 3(a)(2), 40(b)(2) (LR) | A |
| CTD-LEN-001 | No page or word limit for a complaint in the rules read. | LR (silent) | M (none) |
| CTD-FORM-010 | Type size for pleadings: no rule (L. Civ. R. 10 is silent). 12 pt is used by all three complaint filers and matches L. Civ. R. 7(a)(5) for memoranda. | EX-C | C |

## Doc type: motion-brief

Scope: the memorandum of law accompanying a motion (here a Rule 12(b) motion to dismiss). The motion paper itself is a separate filing.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTD-CONT-101 | "Any motion involving disputed issues of law shall be accompanied by a memorandum of law". | L. Civ. R. 7(a)(1) (LR) | M |
| CTD-CONT-102 | Oral-argument legend: the motion "shall indicate in the lower margin of the motion whether oral argument is requested"; opposition memoranda "shall indicate in the lower margin of the first page of such memorandum whether oral argument is requested." Applies to the memorandum only when it is an opposition (or when motion and memorandum are one document). None of the three supporting memoranda prints one. | L. Civ. R. 7(a)(1), 7(a)(2) (LR) | M (opposition memoranda; motions) |
| CTD-FORM-101 | "memoranda shall be double-spaced (except headings, footnotes, and block quotes)". | L. Civ. R. 7(a)(5) (LR) | M |
| CTD-FORM-102 | "Unless otherwise ordered by the Court, text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font." | L. Civ. R. 7(a)(5) (LR) | M |
| CTD-LEN-101 | A memorandum is "no more than forty (40) 8 1/2" by 11" printed pages, exclusive of pages containing a table of contents, table of statutes, rules or the like", except by order of the Court. A motion to exceed must be filed at least seven days before the deadline. | L. Civ. R. 7(a)(5) (LR) | M |
| CTD-LEN-102 | "A reply memorandum may not exceed 10 pages", and must be confined to matters raised by, and refer to the pages of, the memorandum replied to. (Reply template only.) | L. Civ. R. 7(d) (LR) | M (replies) |
| CTD-CONT-103 | Table of contents and table of authorities: not required by any rule read (L. Civ. R. 7(a)(5) only excludes them from the page count). Present in MedGuard Alert's 19-page memorandum; absent from Bondi (14 pages) and Liberty Bank (6 pages). One filer's choice: optional, used for longer memoranda. | EX-M | C (optional) |
| CTD-CONT-104 | Body sections: an unnumbered opening paragraph, then Roman-numeral or capitalised sections (procedural history or background, legal standard, argument, conclusion): Bondi and Liberty Bank use "I." headings; MedGuard Alert uses unnumbered capital headings with lettered argument points. Heading numbering style is filer style. | EX-M | C |
| CTD-CERT-101 | Proof of service by certificate of counsel listing each person served, unless all parties are served through CM/ECF, in which case "the transmission notice on the Notice of Electronic Filing shall be deemed a sufficient certificate of service." MedGuard Alert and Liberty Bank include a "CERTIFICATION" of electronic filing anyway; Bondi does not. Optional. | L. Civ. R. 5(c) (LR) | M (only when a party is not served through CM/ECF); C (optional otherwise) |
| CTD-CONT-105 | Motion to dismiss a self-represented party's complaint: the movant files, as a separate document, the "Notice to Self-Represented Litigant Concerning Motion to Dismiss" in the form set out in the rule, with FRCP 12 and L. Civ. R. 7 attached. Not part of the memorandum; not templated. | L. Civ. R. 12(a) (LR) | A |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| CTD-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| CTD-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| CTD-TOOL-003 | Each markdown italic span renders in an italic face. | T |
| CTD-TOOL-004 | Each footnote appears on the page that carries its reference. | T |
| CTD-REVIEW-001 | A recorded visual review of the current PDF covers every page with no open defect (docs/EVAL-LOOP.md, Gate 2). | T |

## Not verified

- Judge-specific standing orders (for example the Electronic Filing Order of Judge Vanessa L. Bryant, revised 1/17/2018, cited in `motion-brief/README.md` as requiring "Arial bold 12 point font, double spaced") were not re-fetched in this pass. They apply only to cases before that judge and are not recorded as requirements.
- The README claim that the Local Rules PDF "Current-Revised-Local-Rules-9.4.26.pdf" is current is superseded: the court's page now links "Current-Revised-Local-Rules-10.13.26.pdf", which is the version read here. Rules 5, 7 and 10 text quoted above is from the 10.13.26 PDF.
- Chambers practices on courtesy copies and page limits set by individual judges were not read.
