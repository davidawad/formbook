# Federal Circuit briefs (opening, answering, reply): rules

Alias `cafc`. Scope: the appellant's principal brief (`opening-brief/`), the appellee's principal brief (`answering-brief/`) and the appellant's reply brief (`reply-brief/`) in the United States Court of Appeals for the Federal Circuit, filed by counsel as PDF through the court's CM/ECF system. Cross-appeal briefs (FRAP 28.1, Fed. Cir. R. 28.1), informal briefs (Fed. Cir. R. 28(g), 32(c)) and amicus briefs are out of scope. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the usual effective date of Federal Circuit rule amendments) and whenever the court posts a new compilation of the Rules of Practice or a notice of proposed amendments. A proposal published July 2026 (Fed. Cir. R. 32(j), no "passim" in the table of authorities) is pending; re-check it first (see Finding 6).

## Sources

Page numbers are the printed page numbers of the compilation (FCR) or of the Electronic Filing Procedures (EFP).

| Tag | Source | URL |
|---|---|---|
| FCR | "United States Court of Appeals for the Federal Circuit, Rules of Practice: Federal Rules of Appellate Procedure, Federal Circuit Rules, Practice Notes, Federal Circuit Attorney Discipline Rules", dated **October 6, 2026** (239 pp.; "Incorporating final amendments to Federal Circuit Rules 15, 25, 25.1, 30, 32, 39, 46, and 47.6"). Contains the FRAP text with the court's footnotes. Fetched with curl 2026-10-17. | https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/FederalCircuitRules/FederalCircuitRulesofPractice.pdf |
| FRAP | Federal Rules of Appellate Procedure 28 and 32 (read in FCR pp. 103-105 and 140-144; FRAP 32 cross-checked at Cornell LII) | https://www.law.cornell.edu/rules/frap/rule_32 |
| EFP | Clerk's Office, "CM/ECF User's Guide / Electronic Filing Procedures", Version 3.3, May 2025 (103 pp.), adopted under Fed. Cir. R. 25(a)(4). Fetched 2026-10-17. | https://www.cafc.uscourts.gov/wp-content/uploads/ElectronicFilingProcedures.pdf |
| F9 | Form 9, Certificate of Interest (March 2023) | https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/Forms/form9.pdf |
| F19 | Form 19, Certificate of Compliance with Type-Volume Limitations (July 2020) | https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/Forms/form19.pdf |
| F30 | Form 30, Certificate of Service (July 2020) | https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/Forms/form30.pdf |
| PROP | "Rules of Practice, Proposed Amendments, July 2026, Public Clean Copy" (proposed Fed. Cir. R. 32(j); not in force) | https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/FederalCircuitRules/FCRProposedAmendments-PublicCleanCopy-July%202026.pdf |
| FORMS-PAGE | Court forms page (links F9, F19, F30) | https://www.cafc.uscourts.gov/home/rules-procedures-forms/court-forms/ |
| EX-DELFASCO | Opening brief, *Delfasco LLC v. Secretary of the Army*, No. 24-1363 (Cordatis LLP) | `opening-brief/usage/` |
| EX-VIDSTREAM | Opening brief, *VidStream LLC v. Twitter, Inc.*, No. 24-2265 (Caldwell Cassady & Curry PC) | `opening-brief/usage/` |
| EX-ABLYNX | Brief for Appellee Director of the USPTO, *In re Ablynx N.V.*, No. 26-1333 (USPTO Office of the Solicitor) | `answering-brief/usage/` |
| EX-LIGADO | Response brief of appellee, *Ligado Networks LLC v. United States*, No. 25-1792 (Paul, Weiss; Munger, Tolles & Olson; Selendy Gay; Covington & Burling) | `answering-brief/usage/` |
| EX-GEM | Reply brief, *GEM Products, LLC v. Rupp Marine, Inc.*, No. 2026-1817 (Taft Stettinius & Hollister LLP) | `reply-brief/usage/` |
| EX-TOPBRAND | Reply brief, *Top Brand LLC v. Cozy Comfort Co.*, No. 2024-2191 (Jones Day) | `reply-brief/usage/` |

Kinds: **M** = mandated by a rule (FRAP, a Federal Circuit Rule, or the EFP adopted under Fed. Cir. R. 25(a)(4)). **C** = convention (the rules leave it open; the exemplars that show it are named). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **Word limits are enlarged**: principal brief 14,000 words, reply 7,000 (Fed. Cir. R. 32(b)(1), FCR p. 146), not FRAP's 13,000 / 6,500. The reply figure is now verified against the official text (earlier README notes relied on a mirror).
2. **Certificate of interest goes in the brief.** Fed. Cir. R. 28(a)(1) puts it first after the cover, and Fed. Cir. R. 47.4(b) requires it "in each principal brief", but exempts "the United States, or its officers or agencies" (FCR pp. 199-200). It replaces the FRAP 26.1 disclosure statement (FCR p. 103 footnote).
3. **Statement of related cases** (Fed. Cir. R. 47.5(a)) is a required section of each principal brief, after the table of authorities.
4. **Page numbers centered at the bottom** are mandatory for any submission over two pages (Fed. Cir. R. 32(e)); FRAP is silent.
5. **Text-searchable, flattened PDF, no links**: EFP § 11(b) says the PDF "should not contain encryptions, embedded comments, scripts, links, form fields, or executables" and users "must lock or 'flatten'" it; § 11(e) "PDF documents must be text-searchable in their entirety" (EFP pp. 41-42). File cap 60 MB per PDF (EFP § 7, p. 40). EFP p. 34 also says: "Do not create hyperlinks from your brief citations to your appendices".
6. **"Passim" is allowed today**: the July 2026 proposal (PROP) would add Fed. Cir. R. 32(j): "The table of authorities must identify each page on which the authority is cited. Passim or similar terms may not be used." It is not in the October 6, 2026 compilation, whose Rule 32 ends at (i). Templates that never print "passim" satisfy both.
7. **Cover color is a paper-copy rule only**: FCR p. 140 footnote to FRAP 32(a)(2): "electronically filed versions of documents should not follow the cover color requirements ... only the paper copies should follow". Paper copies are provided only after a court notice (Fed. Cir. R. 25(c)(3)(A)).
8. **Proof of service only for non-electronic service** (Fed. Cir. R. 25(e)(1); Form 30 note).

## Court-wide requirements (all three doc types)

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (FRAP 32(a); Fed. Cir. R. 32)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-FORM-001 | Every page is 8 1/2 by 11 inch (612 x 792 pt). | FRAP 32(a)(4), FCR p. 141 | M |
| CAFC-FORM-002 | Margins at least one inch on all four sides; page numbers may sit in the margins, "but no text may appear there" (the court also permits the Fed. Cir. R. 25.1(e)(1)(B) nonconfidential legend in the margin). | FRAP 32(a)(4) and court footnote, FCR p. 141 | M |
| CAFC-FORM-003 | Text double-spaced; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced. Exemplary patent claims reproduced under Fed. Cir. R. 32(a)(3) may be single-spaced. | FRAP 32(a)(4), FCR p. 141; Fed. Cir. R. 32(a)(3), FCR p. 146 | M |
| CAFC-FORM-004 | Typeface, as the rule says: "A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions. A proportionally spaced face must be 14-point or larger." (A monospaced face may not exceed 10 1/2 characters per inch.) The court applies this to footnotes: "The typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) apply to all text in the brief, including footnotes." | FRAP 32(a)(5), FCR p. 142; Practice Notes to Rule 32 (Footnotes), FCR p. 149 | M |
| CAFC-FORM-005 | "A brief must be set in a plain, roman style, although italics or boldface may be used for emphasis. Case names must be italicized or underlined." | FRAP 32(a)(6), FCR p. 142 | M |
| CAFC-FORM-006 | Clear black image on light paper; one side of the page only (the brief stays single-sided even if a bound appendix/addendum is double-sided). | FRAP 32(a)(1)(A) and court footnote, FCR p. 140 | M |
| CAFC-FORM-007 | Page numbers: every submission over two pages carries page numbers, "centered at the bottom of the page"; the cover need not be numbered. | Fed. Cir. R. 32(e), FCR p. 147 | M |
| CAFC-FORM-008 | Numbering scheme: cover unnumbered; front matter (certificate of interest through statement of related cases or the start of the body) in lowercase roman; body in arabic from 1. Seen in EX-DELFASCO, EX-VIDSTREAM, EX-ABLYNX, EX-LIGADO, EX-GEM, EX-TOPBRAND (all six filers). | exemplars | C |
| CAFC-FORM-009 | No highlighting or extraneous markings beyond the confidentiality notations the rules require. | Fed. Cir. R. 32(i), FCR p. 148 | M |
| CAFC-FORM-010 | Body face: Times New Roman 14 pt is what the exemplars use (fonts embedded: TimesNewRomanPSMT family in EX-VIDSTREAM, EX-LIGADO, EX-GEM, EX-TOPBRAND, EX-ABLYNX; Times-Roman in the OCR layer of EX-DELFASCO; certificates in EX-LIGADO, EX-VIDSTREAM and EX-TOPBRAND state "Times New Roman 14-point"). The rule requires only a 14-point serif face (CAFC-FORM-004), so the specific face is a convention, not a rule. | exemplars | C |
| CAFC-FORM-011 | Every font used is embedded, and every embedded font is the template's declared family (no silent fallback to a system font). | project; supports CAFC-ELEC-002 | T |

### Length (FRAP 32(a)(7), 32(f); Fed. Cir. R. 32(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-LEN-001 | Headings, footnotes and quotations count toward the limit. Not counted (FRAP 32(f)): cover page, disclosure statement, table of contents, table of citations, statement regarding oral argument, addendum of statutes/rules/regulations, certificates of counsel, signature block, proof of service. Also not counted (Fed. Cir. R. 32(b)(2)): (A) certificate of interest; (B) statement of related cases; (C) any addendum; (D) Fed. Cir. R. 25.1(e) items; (E) the cover page, the inside of the front cover including the exemplary patent claims, or text required on the first page in lieu of a cover. | FRAP 32(f), FCR p. 144; Fed. Cir. R. 32(b)(2), FCR p. 146 | M |
| CAFC-LEN-002 | Certificate of compliance: a brief exceeding the FRAP 32(a)(7)(A) page limit (30 pages principal, 15 reply) "must include a certificate of compliance with the type-volume limitation that adheres to the requirements in" FRAP 32(g); it must state the number of words (or lines of monospaced type); the preparer may rely on the word processor's count. Form 19 satisfies it. | Fed. Cir. R. 32(b)(3), FCR pp. 146-147; FRAP 32(g)(1)-(2), FCR pp. 144-145; Practice Notes to Rule 32 (Certificate of Compliance), FCR p. 149; F19 | M |
| CAFC-LEN-003 | The word count stated in the certificate equals the actual count of counted words. The court warns that "some software programs do not automatically include footnotes". | FRAP 32(g)(1); Practice Notes to Rule 32, FCR p. 149 | M |
| CAFC-LEN-004 | Certificate wording: a FRAP 32(g)-style paragraph stating the word count and the typeface/size (EX-DELFASCO, EX-VIDSTREAM, EX-LIGADO, EX-TOPBRAND) is the common form; Form 19 itself is used by EX-GEM. Either satisfies the rule; the paragraph form is the convention across filers. | exemplars; F19 | C |

### Cover (FRAP 32(a)(2); Fed. Cir. R. 32(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-COVER-001 | The number of the case centered at the top. | FRAP 32(a)(2)(A), FCR p. 140 | M |
| CAFC-COVER-002 | The name of the court ("United States Court of Appeals for the Federal Circuit"). | FRAP 32(a)(2)(B), FCR p. 140 | M |
| CAFC-COVER-003 | The title of the case: "that cover must contain the official caption provided by the clerk of court" (satisfies FRAP 32(a)(2)(C)). | Fed. Cir. R. 32(a)(1), FCR p. 145; FRAP 32(a)(2)(C) footnote, FCR pp. 140-141 | M |
| CAFC-COVER-004 | The nature of the proceeding (e.g., Appeal, Petition for Review) and the name of the court, agency or board below. The court "encourages inclusion on the cover of the name of the judge ... from whose judgment appeal is taken" (all six exemplars name the tribunal's case number and, where there is one, the judge). | FRAP 32(a)(2)(D), FCR p. 141; Practice Notes to Rule 32 (Preferred Cover Content), FCR p. 149 | M (nature, tribunal); C (judge) |
| CAFC-COVER-005 | The title of the brief, identifying the party or parties for whom it is filed. | FRAP 32(a)(2)(E), FCR p. 141 | M |
| CAFC-COVER-006 | The name, office address and telephone number of counsel for the filing party. | FRAP 32(a)(2)(F), FCR p. 141 | M |
| CAFC-COVER-007 | "Nonconfidential" or "public" may not appear on the cover or first page unless there is a corresponding confidential version; if there is one, the confidential version is labeled "confidential" and the nonconfidential version "nonconfidential", centered at the top or in the title. | Fed. Cir. R. 32(a)(2), FCR p. 145; Fed. Cir. R. 25.1(e)(1)(A)-(B), FCR p. 84 | M |
| CAFC-COVER-008 | A corrected document "must indicate 'corrected' in the title or on the cover". | Fed. Cir. R. 25(i)(2), FCR p. 77 | M (when corrected) |
| CAFC-COVER-009 | Cover color (blue appellant, red appellee, gray reply) applies to paper copies only; the electronic PDF has a white cover (all six exemplars are white). | FRAP 32(a)(2) and court footnote, FCR p. 140 | M (paper only) |
| CAFC-COVER-010 | The cover is one page; counsel that do not fit go on the inside cover ("[Additional counsel on inside cover]", EX-TOPBRAND). Layout: case number, court name, caption with party designations, "Appeal from ..." line, brief title, counsel block, separated by short rules (EX-LIGADO, EX-DELFASCO, EX-GEM, EX-TOPBRAND). The court name in blackletter (Old English) appears in EX-LIGADO, EX-GEM and EX-TOPBRAND but not in the other three: optional style, not followed by default. | exemplars | C |

### Certificates and signature

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-CERT-001 | Certificate of interest: contents in this order, negative responses required for each item: (1) every entity represented by the filing counsel; (2) real parties in interest; (3) parent corporations and publicly held corporations owning 10% or more of the stock (satisfies FRAP 26.1(a)); (4) law firms, partners and associates that appeared below or are expected to appear and have not entered an appearance; (5) whether there are related or prior cases meeting Fed. Cir. R. 47.5; (6) FRAP 26.1(b)-(c) information. Form 9 satisfies it. The United States, its officers or agencies, and unrepresented individuals are exempt. | Fed. Cir. R. 47.4(a)-(b), FCR pp. 199-200; Practice Notes to Rule 47.4; F9 | M |
| CAFC-CERT-002 | Certificate of interest form: Form 9 pages reproduced in the brief (EX-VIDSTREAM, EX-LIGADO, EX-TOPBRAND) vs. a typed certificate with the Form 9 items (EX-DELFASCO). The Form 9 reproduction is the more common; either satisfies 47.4(a). | exemplars | C |
| CAFC-CERT-003 | Proof of service: "A filing does not require proof of service if it is served on all parties through the court's electronic filing system." Nonelectronic filers must be served by another FRAP 25(c) method and "the filing must include proof of service noting the method of service". Confidential versions are served outside CM/ECF and need a proof of service (Fed. Cir. R. 25(e)(3); EFP p. 38). | Fed. Cir. R. 25(e)(1)-(3), FCR p. 75; F30 | M (conditional) |
| CAFC-CERT-004 | A CM/ECF certificate of service is nevertheless included by most filers (EX-DELFASCO, EX-LIGADO, EX-GEM, EX-TOPBRAND); EX-ABLYNX and EX-VIDSTREAM omit it. Optional; on by default. | exemplars | C |
| CAFC-CERT-005 | Signature: every brief is signed by the party or one of its attorneys; an electronic signature is "the printed name of the individual preceded by the mark '/s/' entered on the signature line" (or an ESIGN-compliant commercial signature), placed where the signature would otherwise appear; the signer's name must match the CM/ECF filing account unless Fed. Cir. R. 32(g) multiple signatures apply. Only an attorney who has entered an appearance may sign. | FRAP 32(d), FCR p. 144; Fed. Cir. R. 25(g)(1), FCR p. 76; Fed. Cir. R. 32(g)(1), FCR p. 147 | M |
| CAFC-CERT-006 | Confidential version: a Certificate of Confidential Material (Form 31) accompanies a confidential brief. | EFP § 5(b), p. 38; Fed. Cir. R. 25.1(e)(2) | M (when confidential) |

### Electronic filing (Fed. Cir. R. 25; EFP)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-ELEC-001 | Represented parties "must submit all documents in Portable Document Format (PDF) using the court's electronic filing system". | Fed. Cir. R. 25(a)(1)(A), FCR p. 69; EFP § 11, p. 41 | M |
| CAFC-ELEC-002 | "PDF documents must be text-searchable in their entirety"; when possible the PDF is created directly from the word-processing program, not scanned. Check: text extracts on every page; fonts embedded. | EFP § 11(a), (e), pp. 41-42 | M |
| CAFC-ELEC-003 | The PDF "should not contain encryptions, embedded comments, scripts, links, form fields, or executables"; users "must lock or 'flatten'" it. Check: no encryption, no annotations (link or other), no AcroForm, no JavaScript. Bookmarks (outline entries) are not annotations and are not prohibited. | EFP § 11(b), p. 42 | M |
| CAFC-ELEC-004 | No individual PDF over 60 MB. | EFP § 7, p. 40 | M |
| CAFC-ELEC-005 | The top margin carries no text: CM/ECF stamps "Case: ... Document: ... Page: ... Filed: ..." there (visible on every page of all six exemplars). Covered by CAFC-FORM-002. | exemplars | C |
| CAFC-ELEC-006 | Record references are to appendix pages in the form "Appx123" / "Appx123-132" (no space or period, no dropped leading digits); no hyperlinks from citations to the appendix. | Fed. Cir. R. 28(f), FCR p. 109; EFP § 2(a), pp. 33-34 | M (format); A (content) |
| CAFC-ELEC-007 | PDF bookmarks for the major headings. Convenience; not in the rules. | project | C |

### Author responsibilities (all doc types)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-AUTH-001 | Cite Federal Circuit and predecessor opinions to the Federal Reporter; parallel citations discouraged. | Fed. Cir. R. 28(e), FCR pp. 108-109 | A |
| CAFC-AUTH-002 | Minimize "appellant"/"appellee"; use the parties' names or the designations below. | FRAP 28(d), FCR p. 105 | A |
| CAFC-AUTH-003 | Redact personal identifiers; remove metadata. | Fed. Cir. R. 25.1(a)(3); EFP § 12, p. 45 | A |
| CAFC-AUTH-004 | Duplicative content shared with a brief in a related case must be flagged at the start of the brief or section. Combined brief required for parties represented by the same counsel or firm. | Fed. Cir. R. 28(i)(2), 28(j), FCR p. 110 | A |
| CAFC-AUTH-005 | Paper copies (six, within five business days) only after the court issues a notice requesting them. | Fed. Cir. R. 25(c)(3)(A), FCR p. 73 | A |

### Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| CAFC-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| CAFC-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| CAFC-TOOL-003 | Every TOC entry's page number equals the page on which that heading appears; every TOA page reference is a page that contains the citation, and every cited authority is listed. The template never prints "passim" (Finding 6). | T (supports CAFC-OB-CONT-002/003, CAFC-RB-CONT-001) |
| CAFC-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |

## Doc type: opening-brief

Appellant's (or petitioner's) principal brief. Exemplars: EX-DELFASCO, EX-VIDSTREAM.

Required order (Fed. Cir. R. 28(a), FCR pp. 106-107; it restates and replaces FRAP 28(a)(1) and (10), FCR p. 104 footnote):

1. Cover (CAFC-COVER-*), with any inside-cover material (exemplary claims, CAFC-OB-CONT-012)
2. Certificate of interest (CAFC-CERT-001)
3. Table of contents
4. Table of authorities
5. Statement of related cases
6. Jurisdictional statement
7. Statement of the issues
8. Statement of the case
9. Summary of the argument
10. Argument, with the standard of review under its own heading
11. Conclusion and statement of relief sought; signature
12. Addenda (Fed. Cir. R. 28(c))
13. Certificate of compliance (if required, CAFC-LEN-002)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-OB-LEN-001 | A principal brief may exceed 30 pages only if it "contains no more than 14,000 words, or 1,300 lines of text if using a monospaced typeface". | Fed. Cir. R. 32(b)(1), FCR p. 146; FRAP 32(a)(7)(A)-(B) and court footnote, FCR p. 142 | M |
| CAFC-OB-CONT-001 | Sections appear in the order listed above. | Fed. Cir. R. 28(a), FCR pp. 106-107 | M |
| CAFC-OB-CONT-002 | Table of contents, with page references. | Fed. Cir. R. 28(a)(2); FRAP 28(a)(2), FCR p. 103 | M |
| CAFC-OB-CONT-003 | Table of authorities: cases (alphabetically arranged), statutes, and other authorities, with references to the pages where cited. | Fed. Cir. R. 28(a)(3); FRAP 28(a)(3), FCR p. 103 | M |
| CAFC-OB-CONT-004 | Statement of related cases: (1) any earlier appeal in or from the same proceeding (title and number, date of decision, panel, Federal Reporter citation); (2) title and number of any case known to counsel to be pending that will directly affect or be affected by the decision. | Fed. Cir. R. 28(a)(4); Fed. Cir. R. 47.5(a), FCR p. 201 | M |
| CAFC-OB-CONT-005 | Jurisdictional statement, including information that the judgment or order is final or, if not, appealable on another basis; with FRAP 28(a)(4)(A)-(D) content (tribunal's jurisdiction, this court's jurisdiction, timeliness dates, finality). | Fed. Cir. R. 28(a)(5), FCR p. 106; FRAP 28(a)(4), FCR p. 103 | M (section); A (content) |
| CAFC-OB-CONT-006 | Statement of the issues. | Fed. Cir. R. 28(a)(6) | M |
| CAFC-OB-CONT-007 | Statement of the case, "including the citation of any published decision of the trial tribunal". | Fed. Cir. R. 28(a)(7), FCR p. 106; FRAP 28(a)(6) | M (section); A (content) |
| CAFC-OB-CONT-008 | Summary of the argument (must not merely repeat the argument headings). EX-VIDSTREAM omits it (filer's deviation; the rule governs). | Fed. Cir. R. 28(a)(8); FRAP 28(a)(7), FCR p. 103 | M |
| CAFC-OB-CONT-009 | Argument, including the statement of the standard of review, "which must appear with its own heading either within the argument section or immediately preceding the argument section". EX-DELFASCO puts it as Argument point I; EX-VIDSTREAM as a top-level section before Argument. | Fed. Cir. R. 28(a)(9), FCR p. 106; FRAP 28(a)(8)(B) | M |
| CAFC-OB-CONT-010 | Conclusion and statement of relief sought. | Fed. Cir. R. 28(a)(10); FRAP 28(a)(9) | M |
| CAFC-OB-CONT-011 | Addendum bound with the brief (unless an appendix is permissibly bound with it under Fed. Cir. R. 30(d)): (A) all judgments, orders, agency actions or decisions appealed from and their supporting opinions, memoranda, findings and conclusions, including rehearing orders; (B) if the appeal involves a patent or application, all patents or applications at issue, in their entirety (not prior-art patents). Addendum pages that are also in the appendix carry the appendix page numbers (Appx); other addendum pages are paginated "to avoid confusion". FRAP 28(f) statutes may also be set out there. | Fed. Cir. R. 28(a)(11), 28(c)(1)-(2), FCR pp. 107-108; Practice Notes to Rule 28, FCR p. 111; FRAP 28(f), FCR p. 105 | M |
| CAFC-OB-CONT-012 | Appeals involving patents: when patent or application language is at issue, the principal brief includes one or more exemplary claims "on the inside of the front cover (or immediately following the front cover if the language requires more space)"; may be single-spaced; not counted (CAFC-LEN-001). | Fed. Cir. R. 32(a)(3), FCR p. 146 | M (patent appeals) |
| CAFC-OB-CONT-013 | Top-level headings in capitals, centered: both exemplars set the section titles (CERTIFICATE OF INTEREST, TABLE OF CONTENTS, STATEMENT OF RELATED CASES, JURISDICTIONAL STATEMENT, ...) in capitals. An "INTRODUCTION" before the jurisdictional statement appears in EX-VIDSTREAM only (filer's style). EX-VIDSTREAM numbers top-level sections with roman numerals (I. INTRODUCTION ... VI. CONCLUSION), EX-DELFASCO does not (filer styles; unnumbered top-level sections with I./A./1. inside the Argument is common to both). | exemplars | C |
| CAFC-OB-CONT-014 | TOC and TOA with dot leaders and right-aligned page numbers (both exemplars). | exemplars | C |
| CAFC-OB-CERT-001 | Certificate of interest included (both exemplars; required for a private appellant, CAFC-CERT-001). | Fed. Cir. R. 47.4(b), FCR p. 200 | M |

## Doc type: answering-brief

Appellee's (or respondent's) principal brief. Exemplars: EX-ABLYNX (United States agency appellee), EX-LIGADO (private appellee).

Order: the Fed. Cir. R. 28(a) list above (cover, certificate of interest, TOC, TOA, statement of related cases, jurisdictional statement, issues, case, summary, argument with standard of review, conclusion, certificate of compliance), less the statements that Fed. Cir. R. 28(b) excludes. FRAP 28(b) requires conformity with FRAP 28(a)(1)-(8) and (10); the court's footnote: "An appellee's brief must include the contents required under Fed. Cir. R. 28(a)" (FCR p. 104).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-AB-LEN-001 | 14,000 words (or 1,300 monospaced lines) for a principal brief over 30 pages. | Fed. Cir. R. 32(b)(1), FCR p. 146 | M |
| CAFC-AB-CONT-001 | "An appellee's statements of jurisdiction, the issues, the case and facts, and the standard of review must be limited to specific areas of disagreement with those of the appellant. Absent disagreement, an appellee must not include those statements." (Stricter than FRAP 28(b), which merely makes them optional.) The template makes each of these four sections opt-in. | Fed. Cir. R. 28(b), FCR p. 107; FRAP 28(b), FCR p. 104 | M (prohibition absent disagreement); A (whether there is disagreement) |
| CAFC-AB-CONT-002 | Table of contents and table of authorities, as CAFC-OB-CONT-002/003. | Fed. Cir. R. 28(a)(2)-(3) | M |
| CAFC-AB-CONT-003 | Statement of related cases (Fed. Cir. R. 47.5(a): "Each principal brief"). Present in both exemplars. | Fed. Cir. R. 28(a)(4); Fed. Cir. R. 47.5(a), FCR p. 201 | M |
| CAFC-AB-CONT-004 | Summary of the argument, argument, conclusion and relief sought. | Fed. Cir. R. 28(a)(8)-(10); FRAP 28(b) | M |
| CAFC-AB-CONT-005 | Exemplary patent claims on or after the inside cover when patent language is at issue (applies to "each party's principal brief"). EX-ABLYNX carries a representative-claim page after the cover. | Fed. Cir. R. 32(a)(3), FCR p. 146 | M (patent appeals) |
| CAFC-AB-CONT-006 | No addendum is required of the appellee (Fed. Cir. R. 28(c)(1) applies to "the principal brief of an appellant or petitioner"). | Fed. Cir. R. 28(c)(1), FCR p. 107 | M (not required) |
| CAFC-AB-CONT-007 | Section headings: EX-LIGADO uses unnumbered capitalized top-level sections (STATEMENT OF RELATED CASES, JURISDICTIONAL STATEMENT, STATEMENT OF THE ISSUES, INTRODUCTION, STATEMENT OF THE CASE, SUMMARY OF THE ARGUMENT, ARGUMENT, CONCLUSION) with I./A./1. inside the Argument; EX-ABLYNX numbers top-level sections I.-V. in title case. Unnumbered capitalized top-level sections are seen in EX-LIGADO and EX-DELFASCO (two filers, two doc types) and are the template default; roman-numbered top-level sections (EX-ABLYNX, EX-VIDSTREAM) are filer style. | exemplars | C |
| CAFC-AB-CERT-001 | Certificate of interest: required for a private appellee (EX-LIGADO includes Form 9); omitted for the United States or its officers or agencies (EX-ABLYNX). | Fed. Cir. R. 47.4(b), FCR pp. 199-200 | M |
| CAFC-AB-CERT-002 | Certificate of compliance (CAFC-LEN-002) present in both exemplars; certificate of service in EX-LIGADO only (CAFC-CERT-004). | Fed. Cir. R. 32(b)(3); exemplars | M (compliance); C (service) |

## Doc type: reply-brief

Appellant's reply to the appellee's brief. Exemplars: EX-GEM, EX-TOPBRAND.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CAFC-RB-LEN-001 | A reply brief may exceed 15 pages only if it "contains no more than 7,000 words, or 650 lines of text if using a monospaced typeface" (overrides FRAP 32(a)(7)(B)(ii)'s 6,500; the FRAP footnote at FCR p. 142 says the reply limit "is similarly enlarged"). | Fed. Cir. R. 32(b)(1), FCR p. 146 | M |
| CAFC-RB-CONT-001 | "A reply brief must contain a table of contents, with page references, and a table of authorities — cases (alphabetically arranged), statutes, and other authorities — with references to the pages of the reply brief where they are cited." | FRAP 28(c), FCR pp. 104-105 | M |
| CAFC-RB-CONT-002 | Cover with the FRAP 32(a)(2) contents and the official caption (CAFC-COVER-001 to 006). | FRAP 32(a)(2); Fed. Cir. R. 32(a)(1) | M |
| CAFC-RB-CONT-003 | No other sections are prescribed. Fed. Cir. R. 28(a) (jurisdiction, issues, case, summary, related cases) governs principal briefs only. The court "prefers that reply briefs respond to the response brief rather than repeating what is in the principal brief" and "favors reply briefs that do not use the full word length when not necessary". | Fed. Cir. R. 28(a), FCR p. 106; Practice Notes to Rule 28 (Reply Brief), FCR p. 111 | M (no prescribed sections); A (content) |
| CAFC-RB-CONT-004 | Body: ARGUMENT then CONCLUSION (both exemplars); an INTRODUCTION before the Argument appears in EX-TOPBRAND only (filer style); EX-GEM numbers them "I. ARGUMENT", "II. CONCLUSION" (filer style). | exemplars | C |
| CAFC-RB-CONT-005 | Exemplary claims (Fed. Cir. R. 32(a)(3)) are not required in a reply (the rule says "each party's principal brief"). | Fed. Cir. R. 32(a)(3), FCR p. 146 | M (not required) |
| CAFC-RB-CERT-001 | Certificate of interest: Fed. Cir. R. 47.4(b) requires it in each principal brief, motion and petition, not in a reply. EX-TOPBRAND includes Form 9 anyway; EX-GEM does not. Optional; off by default. | Fed. Cir. R. 47.4(b), FCR p. 200; exemplars | M (not required); C (optional) |
| CAFC-RB-CERT-002 | Certificate of compliance when the reply exceeds 15 pages (CAFC-LEN-002); both exemplars carry one (EX-GEM: Form 19; EX-TOPBRAND: paragraph). | Fed. Cir. R. 32(b)(3), FCR pp. 146-147 | M |
| CAFC-RB-CERT-003 | Table of abbreviations after the TOA (EX-TOPBRAND only): filer style, optional. | EX-TOPBRAND | C |

## Not verified

- Fed. Cir. R. 25.1 was read only for cover labels (25.1(e)(1)); its other confidentiality-marking details (bracketing, legends, the 15-word limit on marked material) are not recorded here and must be read before a confidential-version template is built.
- The PROP document's notice date, comment deadline and proposed effective date were not read (only the proposed rule text); the README's "July 17, 2026 / Dec. 1, 2026 if adopted" is not confirmed here.
- The court's "Common Filing Errors" guide cited in `reply-brief/README.md` was not re-read in this pass.
