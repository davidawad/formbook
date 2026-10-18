# N.D.N.Y. (District Court, Northern District of New York): rules

Alias `nynd`. Scope: civil papers filed by counsel through CM/ECF in the United States District Court for the Northern District of New York; doc types `complaint/` and `motion-brief/` (memorandum of law in support of or in opposition to a motion). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each January 1 (the court's local-rule amendments take effect on January 1 each year, per the Forward to the Local Rules) and whenever the court posts amended local rules or a revised General Order #22.

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | N.D.N.Y. Local Rules of Practice, "Effective JANUARY 1, 2026" (cover). L.R. 5.1, 7.1 and 10.1 are headed "Amended January 1, 2026"; L.R. 5.2 "amended January 1, 2025". Fetched 2026-10-17, sha256 `707fdaa7e094b33f33ee9a44753473626949234f550a0e726ac9a9c2eb9dea96`. Printed page numbers below are those of this edition. | https://www.nynd.uscourts.gov/sites/nynd/files/local_rules/Local%20Rules%202026_Final.pdf |
| LR-2025 | Prior edition (2025), fetched 2026-10-17 for comparison only (the doc-type READMEs cite it), sha256 `8771a5f87f4a2a221808b40a42c9decf8318a41432c4a6f86dd31c779fd65e2c`. Superseded by LR. | https://www.nynd.uscourts.gov/sites/nynd/files/local_rules/Local%20Rules%202025_Final.pdf |
| GO22 | General Order #22, "The Northern District of New York Administrative Procedures for Electronic Case Filing" (18 pages; the PDF carries no edition date in its text; PDF modification date 2026-03-16). Linked from the court's General Order 22 page https://www.nynd.uscourts.gov/content/general-order-22. Fetched 2026-10-17, sha256 `831cd3e8b4e1c0fb91d3255a95e3c1fc8a8a4caae92a8ccb4a1ad94c69a60453`. Page references below are PDF page numbers. | https://www.nynd.uscourts.gov/sites/nynd/files/general-orders/GO22_3.pdf |
| FRCP-7 | Fed. R. Civ. P. 7 (pleadings; motions; 7(b)(2) form of motions) | https://www.law.cornell.edu/rules/frcp/rule_7 |
| FRCP-8 | Fed. R. Civ. P. 8(a) (claim for relief) | https://www.law.cornell.edu/rules/frcp/rule_8 |
| FRCP-10 | Fed. R. Civ. P. 10(a)-(c) (caption; numbered paragraphs) | https://www.law.cornell.edu/rules/frcp/rule_10 |
| FRCP-11 | Fed. R. Civ. P. 11(a) (signature; address, e-mail, telephone) | https://www.law.cornell.edu/rules/frcp/rule_11 |
| FRCP-38 | Fed. R. Civ. P. 38(b) (jury demand) | https://www.law.cornell.edu/rules/frcp/rule_38 |
| FRCP-5.2 | Fed. R. Civ. P. 5.2(a) (redacted filings) | https://www.law.cornell.edu/rules/frcp/rule_5.2 |
| EX-C1 | Complaint exemplar: Golub v. Coll, No. 1:26-cv-1490, Doc. 1 (plaintiff, Capezza Hill, LLP). See `complaint/usage/SOURCE.md`. | local |
| EX-M1 | Motion-brief exemplar: Mistry v. Cornell University, No. 3:26-cv-1419, Doc. 8-1 (defendants, Bond, Schoeneck & King, PLLC). See `motion-brief/usage/SOURCE.md`. | local |
| EX-C2 | Complaint exemplar: Taal v. Trump, No. 3:25-cv-335, Doc. 1 (plaintiffs, Eric Lee; American-Arab Anti-Discrimination Committee; Davis Ndanusa Ikhlas & Saleem LLP; Project TAHA). See `complaint/usage/SOURCE.md`. | local |
| EX-M2 | Motion-brief exemplar: United States v. State of New York, No. 1:25-cv-205, Doc. 10-1 (defendants, New York State Attorney General). See `motion-brief/usage/SOURCE.md`. | local |
| EX-M3 | Motion-brief exemplar: United States v. State of New York, No. 1:25-cv-205, Doc. 24-1 (plaintiff United States, DOJ Civil Division, Federal Programs Branch; combined L.R. 7.1(c) opposition/cross-motion brief). See `motion-brief/usage/SOURCE.md`. | local |

Kinds: **M** = mandated by a court rule (N.D.N.Y. Local Rule or Federal Rule of Civil Procedure). **C** = convention (the rules leave it open; taken from the filed exemplars). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

### Verification notes

- **General Order #22** was at first refused by the court site's firewall ("Request Rejected") on 2026-10-17 and was then fetched later the same day (tag GO22); its rules are recorded below. Its edition date is not printed in the document; the version read is identified by sha256.
- No typeface rule: a full-text search of LR (2026) for "typeface", "font" and "Times" finds nothing. The only type rule is L.R. 10.1(a)(1) "a minimum of 12-point type". No word-count rule exists; length limits are in pages.

### Findings that differ from what many templates assume

1. **No typeface is named.** L.R. 10.1(a)(1) sets only size: "all text, whether in the body of the document or in footnotes, must be a minimum of 12-point type." Any face choice is `C` (all five exemplars use Times New Roman).
2. **Page limits, not word limits.** L.R. 7.1(b)(1): 25 pages, double-spaced, for a memorandum of law; 10 pages for a reply (L.R. 7.1(a)(1), (a)(2)); a combined cross-motion/opposition brief and a combined reply/opposition brief 25 pages, exclusive of exhibits (L.R. 7.1(c)).
3. **A table of contents is mandatory** in every memorandum of law (L.R. 7.1(b)(1)); a table of authorities is not required by any rule.
4. **Bar roll number** of the attorney is required on each document (L.R. 10.1(c)(2)), in addition to FRCP 11(a)'s address, e-mail and telephone. None of the five exemplars prints one (two give state bar numbers).
5. **The caption must carry the assigned judge's initials** (L.R. 10.1(c)(1)), e.g. "(ECC/DJS)".
6. **Jury demand notation on the front page** of the initial pleading (L.R. 38.1(a)); the civil cover sheet checkbox is not enough.
7. **Certificate of service only for non-ECF filers** (L.R. 5.1(a) and 7.1(b), amended January 1, 2026): CM/ECF filing is service on ECF filers and opted-in pro se e-Recipients; a certificate is still required for documents filed under seal or for in camera review served by other means.

## Court-wide requirements

### Page form (L.R. 10.1(a), (b); L.R. 5.1(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYND-FORM-001 | All pleadings and other papers are "in the form prescribed by L.R. 10.1". L.R. 10.1(a) applies to documents presented "whether in paper form or in electronic form". | L.R. 5.1(a), LR p. 6; L.R. 10.1(a), LR p. 19 | M |
| NYND-FORM-002 | Type size: "all text, whether in the body of the document or in footnotes, must be a minimum of 12-point type." Applies to headings, captions and signature blocks too (all text). | L.R. 10.1(a)(1), LR p. 19 | M |
| NYND-FORM-003 | Typeface: no rule. The template's face is a free choice; Times New Roman is used by all five exemplars (four filers: EX-C1 Capezza Hill, EX-C2 Taal counsel, EX-M1 Bond, Schoeneck & King, EX-M2 N.Y. Attorney General, EX-M3 DOJ), so a Times-like serif is the convention. | LR (silent); EX-C1, EX-C2, EX-M1, EX-M2, EX-M3 | C |
| NYND-FORM-004 | Margins: "all documents must have one-inch margins on all four sides of the page." | L.R. 10.1(a)(2), LR p. 19 | M |
| NYND-FORM-005 | Spacing: "all text in the body of the document must be double-spaced." Operational definition for checks: body baseline pitch at least 2 x 12 pt = 24 pt. | L.R. 10.1(a)(3), LR p. 19 | M |
| NYND-FORM-006 | "the text in block quotations and footnotes may be single-spaced." (Headings, caption, signature block, tables of contents: the rule is silent; both exemplars single-space them, a convention.) | L.R. 10.1(a)(4), LR p. 19; EX-C1, EX-M1 for headings/caption | M (quotes, footnotes); C (rest) |
| NYND-FORM-007 | "extensive footnotes must not be used to circumvent page limitations." | L.R. 10.1(a)(5), LR p. 19 | A |
| NYND-FORM-008 | "compacted or other compressed printing features must not be used." Check: no condensed font, no character spacing below normal, no horizontal scaling. | L.R. 10.1(a)(6), LR p. 19 | M |
| NYND-FORM-009 | "pages must be consecutively numbered." | L.R. 10.1(a)(7), LR p. 19 | M |
| NYND-FORM-010 | Paper size 8 1/2 x 11 inch (612 x 792 pt). The rule is stated for paper filings ("8 1/2 x 11-inch white paper"); the e-filed PDF uses the same page size (both exemplars are letter size). | L.R. 10.1(b)(1), LR p. 20; EX-C1, EX-M1 | M (paper); C (PDF) |
| NYND-FORM-011 | Black (or blue) ink; single-sided (paper filings). For the PDF: black text on white. | L.R. 10.1(b)(3), (b)(5), LR p. 20 | M (paper); C (PDF) |
| NYND-FORM-012 | Every font used is embedded and is the template's declared family (no silent fallback to a system font). | project rule | T |
| NYND-FORM-013 | Page numbers: arabic, centered at the foot of the page (all five exemplars). Memoranda: front matter (table of contents, table of authorities) in lowercase roman, body from arabic 1 (EX-M1, EX-M2, EX-M3); the cover is unnumbered in EX-M1 and EX-M2 and numbered "i" in EX-M3 (one filer's style). | EX-C1, EX-C2, EX-M1, EX-M2, EX-M3 | C |

### Caption and filer identification (L.R. 10.1(c); FRCP 10(a), 11(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYND-CAP-001 | Each document contains a caption including: (a) the title of the Court; (b) the title of the action; (c) the civil action number; (d) "the initials of the assigned judge(s)"; (e) "the name or nature of the paper in sufficient detail for identification". | L.R. 10.1(c)(1), LR p. 20 | M |
| NYND-CAP-002 | Papers pertain to one civil action number only (unless consolidated); affidavits and declarations are captioned separately and not physically attached to the Notice of Motion or Memorandum of Law. | L.R. 10.1(c)(1), LR p. 20 | A |
| NYND-CAP-003 | Caption layout: "UNITED STATES DISTRICT COURT / NORTHERN DISTRICT OF NEW YORK" above a party block at the left with the designations ("Plaintiff," / "Defendants.") indented, and the case number with the judges' initials in the right column: seen in all four filers (convention). The court-title position varies (top left in EX-C1 and EX-M1, M2; centered in EX-C2 and EX-M3), and the separator ("-against-" in EX-C1, "v." in EX-C2, EX-M1, EX-M2, EX-M3) is each filer's choice; "v." is the more common. | EX-C1, EX-C2, EX-M1, EX-M2, EX-M3 | C |
| NYND-SIG-001 | Each document identifies the filer: an original or electronic signature of the attorney; the attorney's typewritten name; and "the bar roll number, office address, telephone number, and e-mail address of the attorney". | L.R. 10.1(c)(2), LR p. 20 | M |
| NYND-SIG-002 | Every pleading, written motion and other paper is signed by at least one attorney of record in the attorney's name; it states the signer's address, e-mail address and telephone number. | FRCP 11(a) | M |
| NYND-SIG-003 | Signature on an e-filed paper: filing under the attorney's login and password is the attorney's signature (FRCP 11 included); a document needing an attorney's signature "shall be signed in the following manner "s/ (attorney name)."" GO22 §6.1 gives the model block: "s/ Judith Attorney", the typed name with "Bar Number", "Attorney for (Plaintiff/Defendant)", firm, street, city, "Telephone:", "Fax:", "E-mail:". The filing attorney may not file a document signed by another attorney unless the filing attorney also signs it. Exemplars: EX-C2, EX-M1, EX-M2, EX-M3 use "s/" or "/s/" before the typed name; none prints an N.D.N.Y. bar roll number (EX-C2 and EX-M3 give state bar numbers); the rule governs. | GO22 §6.1, PDF p. 10; L.R. 10.1(c)(2) | M (s/ form, bar number, contact lines); C (block layout) |

### Service, privacy, electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYND-CERT-001 | Certificate of service: required only for service on non-ECF filers, and for documents filed under seal or for in camera inspection that are served by other means. Filing on CM/ECF is service on ECF filers and opted-in pro se e-Recipients; "No additional service by mail or certificate of service is required for these recipients." Template: opt-in certificate. | L.R. 5.1(a), LR p. 6 (amended January 1, 2026); L.R. 7.1(b), LR p. 15 | M (conditional) |
| NYND-AUTH-001 | Redact personal identifiers: SSN/TIN last four digits; minors' initials or pseudonym; birth year only; financial account last four digits; home address city and state only (pro se litigants give their full mailing address); sexual-assault victims as "Victim 1", etc. | L.R. 5.2(a), LR pp. 9-10; FRCP 5.2(a) | A |
| NYND-ELEC-001 | "All documents filed by attorneys ... shall be filed electronically as "PDF text format"", defined as "a text-searchable PDF file generated from an original word-processing file"; converted, "not by scanning", where technically feasible. Check: text extracts on every page; fonts embedded (also NYND-FORM-012). | GO22 §2, PDF p. 3; GO22 §1.6, PDF p. 2 | M |
| NYND-ELEC-002 | The top margin carries no text: CM/ECF stamps "Case ... Document ... Filed ... Page x of y" there (visible on every page of all five exemplars). Covered by NYND-FORM-004. | EX-C1, EX-C2, EX-M1, EX-M2, EX-M3 | C |
| NYND-ELEC-003 | Documents in a language other than English carry a certified English translation (28 U.S.C. § 1746). | L.R. 10.1(d), LR p. 21 | A |
| NYND-ELEC-004 | "Each filed document may not exceed 50 mb." Larger documents are reduced or split into parts labeled "Part 1, Part 2, etc." | GO22 §4.5, PDF p. 8 | M |
| NYND-ELEC-005 | Exhibits and attachments are filed in PDF, each with a descriptive title ("Exhibit 12 Mulligan County Fire Investigation Report", not "Exhibit 1"); only germane excerpts, clearly identified. Not produced by the template. | GO22 §4.4, PDF p. 7 | A |

## Doc type: complaint

Scope: the initial complaint in a civil action, filed by counsel. No page limit applies (L.R. 7.1 limits memoranda of law only; no rule limits pleadings).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYND-CONT-001 | Caption with the court's name, a title, a file number and a Rule 7(a) designation ("Complaint"). The title of the complaint names all the parties. (Plus NYND-CAP-001: judges' initials, once assigned.) | FRCP 10(a); L.R. 10.1(c)(1) | M |
| NYND-CONT-002 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction or occurrence in a separate count if that promotes clarity. | FRCP 10(b) | M (numbered paragraphs); A (content) |
| NYND-CONT-003 | Contents: a short and plain statement of the grounds for jurisdiction; a short and plain statement of the claim; a demand for the relief sought. | FRCP 8(a)(1)-(3) | A (M for the filer) |
| NYND-CONT-004 | Jury demand: if demanded, "a notation on the front page of the initial pleading ... stating 'Demand for Jury Trial' or an equivalent statement". The civil cover sheet's "yes" box is not sufficient. Check: when the sample sets a jury demand, the string appears on page 1. | L.R. 38.1(a), LR p. 34; FRCP 38(b) | M (conditional) |
| NYND-CONT-005 | Class action: the words "Class Action" next to the caption of a complaint asserting a class action. Check: when the sample sets class action, the string appears in the caption on page 1. | L.R. 23.1(a), LR p. 28 | M (conditional) |
| NYND-CONT-006 | A civil cover sheet is submitted with every complaint (separate form, not produced by the template). | L.R. 3.2, LR p. 3 | A |
| NYND-CONT-007 | RICO claims: a separate "RICO Statement" within 30 days (General Order #14). Separate filing; not produced. | L.R. 9.2, LR p. 19 | A |
| NYND-CONT-008 | Exemplar conventions seen in both complaint filers (EX-C1, EX-C2): the title of the paper in capitals in the caption's right column, with the jury demand there too (EX-C2 "DEMAND FOR JURY TRIAL"; EX-C1 "COMPLAINT AND DEMAND FOR JURY TRIAL"); centered capital section headings (PRELIMINARY STATEMENT in EX-C1 or INTRODUCTION in EX-C2, PARTIES, JURISDICTION AND VENUE or "JURISDICTION & VENUE", facts, causes of action, the prayer: WHEREFORE paragraph in EX-C1, REQUEST FOR RELIEF heading in EX-C2); paragraph number at a 0.5 inch indent with the text one tab later; prayer items lettered; dated signature block after the prayer. One filer's style only: the unnumbered lead-in sentence and the bold title (EX-C1), the side-by-side multi-counsel signature columns (EX-C2). | EX-C1, EX-C2 | C |

## Doc type: motion-brief

Scope: a memorandum of law in support of or in opposition to a motion (L.R. 7.1(b)(1)), including replies and combined cross-motion briefs.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYND-LEN-001 | "No party shall file or serve a memorandum of law that exceeds twenty-five (25) pages in length, double-spaced, unless that party obtains leave of the judge hearing the motion prior to filing." Applies to moving and opposing memoranda. | L.R. 7.1(b)(1), LR p. 15 | M |
| NYND-LEN-002 | Reply on a dispositive motion: "a memorandum of law that may not exceed TEN (10) pages in length". Reply on a non-dispositive motion: only with leave, and "reply briefs may not exceed 10 pages in length." No surreply. | L.R. 7.1(a)(1), (a)(2), LR pp. 13-14 | M |
| NYND-LEN-003 | Cross-motions: the cross-motion brief is joined with the opposition brief and "may not exceed twenty-five (25) pages in length, exclusive of exhibits"; the original movant's combined reply/opposition brief likewise 25 pages. | L.R. 7.1(c), LR pp. 16-17 | M |
| NYND-LEN-004 | Which pages count: the rule does not say whether the cover, tables or signature block count toward the 25 pages. All three filers number the front matter in roman and the body from arabic 1, and end the argument by page 25 (EX-M1 signs on page 25; EX-M2 and EX-M3 put the signature block alone on page 26). The template counts the body from the first body heading through the signature block (the conservative reading) and excludes the cover and tables. This reading is a convention, not a rule. | L.R. 7.1(b)(1) (silent); EX-M1, EX-M2, EX-M3 | C |
| NYND-CONT-101 | "All memoranda of law shall contain a table of contents and numbered pages." Check: a table of contents exists, and each entry's page number equals the page where the heading appears. | L.R. 7.1(b)(1), LR p. 15 | M |
| NYND-CONT-102 | The moving party "must specify in its moving papers the rule or statute upon which it bases its motion." | L.R. 7.1(b)(1), LR p. 15 | M (moving papers) ; A (content) |
| NYND-CONT-103 | Table of authorities: not required by any N.D.N.Y. rule, but all three memorandum filers include one after the table of contents (EX-M1, EX-M2, EX-M3), so it is a convention a clerk expects. | LR (silent); EX-M1, EX-M2, EX-M3 | C |
| NYND-CONT-104 | Papers that accompany the memorandum (not produced by this template): a Notice of Motion (caption and docket number, supporting papers, relief and grounds; the main ECF document, with supporting papers as attachments; states any oral-argument request and its reasons); a supporting affidavit when necessary (none for Rule 12(b)(6), 12(c), 12(f) motions); a Statement of Material Facts for summary judgment (L.R. 56.1); proof of service on non-ECF filers. | L.R. 7.1(b), (b)(2), (b)(3), (b)(5), LR pp. 15-16; L.R. 12.1 | A |
| NYND-CONT-105 | Unpublished or electronic-database-only authorities: a hard copy is served on a pro se litigant with the memorandum; copies given to opposing counsel on request. | L.R. 7.1(b)(1), LR p. 15 | A |
| NYND-CONT-106 | Memorandum conventions seen across the three filers (EX-M1, EX-M2, EX-M3): a separate cover page with the caption and the title of the paper in capitals; TABLE OF CONTENTS with dot leaders, then TABLE OF AUTHORITIES (cases, statutes, other authorities, with "Page(s)"); an opening section (PRELIMINARY STATEMENT in EX-M1, EX-M2; INTRODUCTION in EX-M3), a facts or background section, a legal-standard section (STANDARD OF REVIEW in EX-M2, LEGAL STANDARDS in EX-M3; inside ARGUMENT in EX-M1), ARGUMENT with roman-numbered points (I., II.; "POINT I" in EX-M1 only) and A./1. sub-headings, CONCLUSION, then the dated signature block. One filer's style or split: the firm block on the cover (EX-M1, EX-M2; not EX-M3). | EX-M1, EX-M2, EX-M3 | C |
| NYND-CONT-107 | Amicus brief (if this template is used for one): at most 12 pages, double-spaced, with a table of contents and numbered pages, meeting L.R. 10.1(a), plus the authorship/funding statement (unless the amicus is the United States, its officer or agency, or a state). Filed only by leave, as an exhibit to the motion for leave. | L.R. 7.2(b), (d), LR p. 18 | M (for amicus briefs) |

## Template-only requirements (the template's own contract)

| ID | Requirement | Kind |
|---|---|---|
| NYND-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| NYND-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| NYND-TOOL-003 | Each markdown italic span renders in an italic face. | T |
| NYND-TOOL-004 | Each footnote appears on the page that carries its reference. | T |
| NYND-TOOL-005 | Every table-of-contents page number equals the page on which the heading appears (supports NYND-CONT-101). | T |
| NYND-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |
| NYND-GEN-001 | A second, structurally different sample passes gates 0 to 2. | T |
