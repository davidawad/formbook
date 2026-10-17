# United States Bankruptcy Court, D. Connecticut: rules

Alias `ctb`. Scope: documents filed by counsel through CM/ECF in the United States Bankruptcy Court for the District of Connecticut; doc types in this folder: `adversary-complaint` (a complaint commencing an adversary proceeding) and `motion-brief` (a memorandum of law supporting or opposing a motion, in an adversary proceeding or a contested matter). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (national rule amendments) and whenever the Bankruptcy Court posts amended Local Bankruptcy Rules or Appendix A, or the District Court posts a new compilation of its Local Civil Rules (it did so on 2026-10-13; the README files cite the superseded 9.4.26 compilation).

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | Local Rules of Bankruptcy Procedure, D. Conn., effective March 16, 2026 (Local Bankr. R. 1001-1(a)(3); supersedes the rules effective August 2, 2021). 202 pp. PDF, sha256 `f8877ab74b73ae64cff1eb1183116a8d979849d9369cc7d92ef32ea1c46b7b4f`, fetched 2026-10-17 from the court's "Local Rules of Bankruptcy Procedure" page (https://www.ctb.uscourts.gov/local-rules-bankruptcy-procedure). | https://www.ctb.uscourts.gov/sites/ctb/files/Local%20Rules_2026_03_16with%20appdncs.pdf |
| LBR-5005 | Local Bankr. R. 5005-1, court web page ("EFFECTIVE MARCH 16, 2026"), same text as LBR | https://www.ctb.uscourts.gov/local-bankrr5005-1 |
| APPX-A | Appendix A to the Local Bankruptcy Rules, "Administrative Procedures for Electronic Case Filing", revised March 16, 2026. 15 pp., sha256 `89e038f612cf3f46b4984123966de803cb77adda0644c179bf55aef3fa2b0186` | https://www.ctb.uscourts.gov/sites/ctb/files/Appendix%20A_2026_03_16.pdf |
| DLR | D. Conn. Local Rules of Civil Procedure, compilation posted by the District Court as "Current-Revised-Local-Rules-10.13.26" (Rule 7 amended January 12, 2024; Rule 10 amended November 7, 2016). 174 pp., sha256 `7276a8de62373432011f35807dca01ce7ef5a7879d87a7e7a6f3d8f90d7d6264`. Applied in this court by Local Bankr. R. 5005-1 (Rule 10) and 7007-1 (Rules 7 and 56). | https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-10.13.26.pdf |
| D-ECF | D. Conn. (District Court) Electronic Filing Policies and Procedures, revised October 3, 2025. 17 pp., sha256 `25549742a84c7e89ce5d216ddbcaf4a0ac493e5683132afedae895b65a4f76a6`. Context only, see Finding 3. | https://www.ctd.uscourts.gov/sites/default/files/Electronic-Filing-Policies-and-Procedures-10.3.25.pdf |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7008, 7010, 9004, 9011, 9013 (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7008, .../rule_7010, .../rule_9004, .../rule_9011, .../rule_9013 |
| FRCP | Fed. R. Civ. P. 10 (applied by FRBP 7010) | https://www.law.cornell.edu/rules/frcp/rule_10 |
| EX-AC | `adversary-complaint/exemplars/`: Despins (Neubert, Pepe & Monteith), Novak (Law Offices of Jeffrey Hellman), Lotto (Willcutts & Habib). See that folder's `SOURCE.md`. | local |
| EX-MB | `motion-brief/exemplars/`: Pillsbury (Green & Sklarz; Pillsbury Winthrop Shaw Pittman), Hamilton defendants (Lazare Potter Giacovas & Moyle). See that folder's `SOURCE.md`. | local |

Kinds: **M** = mandated by a court rule (FRBP, an applied FRCP rule, a Local Bankruptcy Rule, or a District Local Civil Rule that a Local Bankruptcy Rule adopts). **C** = convention (the rules leave it open; taken from exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

## Findings

1. **No rule sets a typeface.** Local Bankr. R. 5005-1 says only: "D. Conn. L. Civ. R. 10 applies to pleadings and documents filed with the Bankruptcy Court." D. Conn. L. Civ. R. 10 sets paper size, double spacing, side margins and page numbers but no face and no size. Appendix A sets no face or size. The only size rule is D. Conn. L. Civ. R. 7(a)(5) for memoranda: "text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font", which reaches this court through Local Bankr. R. 7007-1 (adversary motion practice). The face is therefore a convention: every exemplar (five filers) sets its body in Times New Roman, 12 point by appearance.
2. **Brief length: 25 pages, not 40.** Local Bankr. R. 7007-2(a): "A brief shall not exceed twenty-five (25) pages (excluding the table of contents and table of authorities). A reply brief shall not exceed ten (10) pages." D. Conn. L. Civ. R. 7(a)(5) allows forty pages, and Local Bankr. R. 7007-1 applies Rule 7 to adversary motion practice; the bankruptcy rule is specific to briefs in this court and is the binding limit here. In a contested matter, Local Bankr. R. 9014-1(e) and (g)(1) limit a response or objection to 10 pages and a reply to 5 pages.
3. **Which electronic filing procedures.** D. Conn. L. Civ. R. 10 requires conformity with "this Court's Electronic Filing Policies and Procedures". In the Bankruptcy Court those are Appendix A (searchable PDF, 20 MB per transmission, the signature block). The District Court's own policy (D-ECF) adds a font-embedding rule ("electronic records that have been converted to PDF ... must include embedded fonts") and a 75 MB limit; this file treats D-ECF as context, not as a rule of this court, and uses the stricter Appendix A size limit. Embedding all fonts is kept as a project rule (CTB-FORM-008).
4. **Top and bottom margins are not set by rule.** D. Conn. L. Civ. R. 10 requires "left and right margins of at least 1”" and page numbers "in the bottom margin"; it is silent on top and bottom margins. The template uses 1 inch on all sides (convention, all exemplars).
5. **Consent statement.** FRBP 7008 requires every adversary complaint to state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. Of the three complaint exemplars only Lotto has it; Despins and Novak omit it. The template must emit it regardless (tier 1).

## Court-wide requirements

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTB-FORM-001 | Pages are 8 1/2 by 11 inch (612 x 792 pt). Rule text: "Pleadings shall be double-spaced, on 8-1/2” by 11” pages". | D. Conn. L. Civ. R. 10 (DLR p. 17), applied by Local Bankr. R. 5005-1 (LBR p. 36; LBR-5005) | M |
| CTB-FORM-002 | Left and right margins at least 1 inch ("with left and right margins of at least 1”"). | D. Conn. L. Civ. R. 10; Local Bankr. R. 5005-1 | M |
| CTB-FORM-003 | Top and bottom margins at least 1 inch. The rule is silent (Finding 4); all exemplars use about 1 inch, and CM/ECF stamps its "Case ... Doc ... Filed ... Entered ... Page x of y" header in the top margin of every page. | EX-AC (Despins, Novak, Lotto); EX-MB (Pillsbury, Hamilton) | C |
| CTB-FORM-004 | Pleadings are double-spaced ("Pleadings shall be double-spaced"). Operational definition for checks: body baseline pitch at least twice the type size (24 pt at 12 pt). Captions, headings, block quotations and signature blocks are single-spaced by convention (all exemplars). | D. Conn. L. Civ. R. 10; Local Bankr. R. 5005-1 | M (body); C (exceptions) |
| CTB-FORM-005 | Page numbers "in the bottom margin of each page after page 1". Every page after page 1 carries a number in the bottom margin. Position (centered) and style vary by filer: plain "2" (Despins), "Page 2 of 3" (Novak), "- 2 -" (Lotto); centered in all three, so centered is C and the style is tier 3. | D. Conn. L. Civ. R. 10; EX-AC | M (number in bottom margin after p. 1); C (centered) |
| CTB-FORM-006 | Typeface: no rule names one (Finding 1). Every exemplar uses Times New Roman for body text (pdffonts: TimesNewRomanPSMT in all five). The template's face is a convention choice; a metric-compatible vendored serif is acceptable. | EX-AC (3 filers); EX-MB (2 filers) | C |
| CTB-FORM-007 | Type size: memoranda "text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font" (see CTB-MB rows). For pleadings no size is set; all exemplars use 12 point body text, so the template uses 12 point throughout. | D. Conn. L. Civ. R. 7(a)(5) via Local Bankr. R. 7007-1 (memoranda); EX-AC (pleadings) | M (memoranda); C (pleadings) |
| CTB-FORM-008 | Every font used is embedded and is the template's declared family (no silent fallback). | project; supports Finding 3 (D-ECF I.F.2 embedding rule, context only) | T |
| CTB-FORM-009 | Document is clearly legible. | FRBP 9004(a) | M |

### Caption

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTB-CAP-001 | Caption sets forth (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, the adversary-proceeding number, and (4) a brief designation of the document's character. | FRBP 9004(b) | M |
| CTB-CAP-002 | "The complete docket number, including the initials of the Judge to whom the case has been assigned, shall be typed on each pleading" (e.g. "Case No. 22-50073 (JAM)"). | D. Conn. L. Civ. R. 10; Local Bankr. R. 5005-1 | M |
| CTB-CAP-003 | "The date of each pleading shall be included in the case caption." | D. Conn. L. Civ. R. 10; Local Bankr. R. 5005-1 | M |
| CTB-CAP-004 | In an adversary proceeding the caption must substantially conform to the appropriate version of Official Form 416 (the adversary caption: debtor block with case number and chapter, then plaintiff v. defendant with the adversary number). The form itself was not fetched in this pass (see Not verified); the layout detail is C. | FRBP 7010 | M (existence); C (layout) |
| CTB-CAP-005 | Court heading in three centered capital lines: UNITED STATES BANKRUPTCY COURT / DISTRICT OF CONNECTICUT / <division> DIVISION. All three complaint exemplars and Pillsbury name the division (Bridgeport, Hartford, New Haven); Hamilton writes "IN THE UNITED STATES BANKRUPTCY COURT / FOR THE DISTRICT OF CONNECTICUT" without a division. | EX-AC (3 filers); EX-MB (2 filers) | C |
| CTB-CAP-006 | Two-column caption: parties on the left (debtor block "In re: ... Debtor(s).", then plaintiff "v." defendant), chapter, case number with judge initials and adversary number on the right, the date at the foot of the right column. All five exemplars. A column of colons (":") between the columns appears in Despins, Novak and Lotto (complaints); Pillsbury and Hamilton use white space and rules only, so the colon column is C for complaints and tier 3 for briefs. | EX-AC; EX-MB | C |

### Signature and electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTB-ELEC-001 | Primary documents (motions, complaints, memoranda of law, objections, responses, briefs) are "Electronically Generated text, so that the text of the document may be searched and copied". Check: text extracts on every page. | APPX-A §7(a)-(b) | M |
| CTB-ELEC-002 | Each CM/ECF transmission at most 20 megabytes total. | APPX-A §7(e) | M |
| CTB-ELEC-003 | Signature block sets forth (a) the filer's name, (b) a complete mailing address, (c) telephone number, (d) e-mail address, (e) the Connecticut federal court bar registration number and firm affiliation, if applicable, and (f) a signature line with "/s/ Name" typed where the signature would appear. | APPX-A §11(c)(i) | M |
| CTB-ELEC-004 | Directly beneath the signature: the name of the signer, office address, telephone number, fax number and e-mail address, if available; the federal bar number "should appear beneath his/her signature". (The fax number appears in Lotto only; Novak and Despins omit it, and Appendix A does not list it: the template prints it when supplied.) | D. Conn. L. Civ. R. 10; Local Bankr. R. 5005-1 | M (fax: when available) |
| CTB-ELEC-005 | Every document is signed by at least one attorney of record in the attorney's individual name and states the signer's address and telephone number. | FRBP 9011(a) | M |
| CTB-ELEC-006 | Multiple signers: a document with signatures of more than one counsel contains the signature information of CTB-ELEC-003 for each. | APPX-A §11(c)(iii) | M |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTB-AC-CONT-001 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts for claims founded on separate transactions where that promotes clarity. | FRCP 10(b), applied by FRBP 7010 | M |
| CTB-AC-CONT-002 | Caption title of the complaint names all the parties. | FRCP 10(a), applied by FRBP 7010 | M |
| CTB-AC-CONT-003 | The jurisdiction allegation refers to the name, number and Code chapter of the case the adversary proceeding relates to, and the district and division where it is pending. | FRBP 7008 | M (A for the content) |
| CTB-AC-CONT-004 | The complaint states whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court (Finding 5). | FRBP 7008 | M |
| CTB-AC-CONT-005 | The complaint is filed in the division in which the related debtor case is pending (the caption names that division). | Local Bankr. R. 7001-1 (LBR p. 53) | M (A for the filing) |
| CTB-AC-CONT-006 | Adversary Proceeding Cover Sheet (Director's Form B1040) is required only if the complaint is not filed through CM/ECF. Not produced by the template (CM/ECF filers enter the cover data in the system; Despins and Novak still attach it). | Local Bankr. R. 7002-1 (LBR p. 53) | M (paper filers only) |
| CTB-AC-CONT-007 | Adversary number left blank on the filed complaint (the clerk assigns it on filing): "Adv. Proceeding No. 25- [ ]" (Despins), "ADV. PRO NO.:" (Novak), "Adv. Pro. No. 24-" (Lotto). The template prints the number when supplied and a blank otherwise. | EX-AC (3 filers) | C |
| CTB-AC-CONT-008 | Order of parts: caption, centered bold title, body with headed sections (jurisdiction and venue, parties, facts, counts), a prayer for relief introduced by "WHEREFORE", date line, signature block. Section headings are centered (Despins, Lotto; Novak has none in a 3-page complaint). | EX-AC | C |
| CTB-AC-CONT-009 | First-line indent on numbered paragraphs, number at the indent (all three filers). | EX-AC | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTB-MB-LEN-001 | A brief shall not exceed 25 pages, excluding the table of contents and table of authorities; a reply brief shall not exceed 10 pages (Finding 2). | Local Bankr. R. 7007-2(a) (LBR p. 55) | M |
| CTB-MB-LEN-002 | Contested matter: a response or objection is no more than 10 pages; a reply no more than 5 pages. | Local Bankr. R. 9014-1(e), (g)(1) (LBR pp. 63-64) | M (contested matters) |
| CTB-MB-FORM-001 | Memoranda double-spaced "except headings, footnotes, and block quotes". | D. Conn. L. Civ. R. 7(a)(5), via Local Bankr. R. 7007-1 | M |
| CTB-MB-FORM-002 | "text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font". | D. Conn. L. Civ. R. 7(a)(5), via Local Bankr. R. 7007-1 | M |
| CTB-MB-CONT-001 | A motion involving disputed issues of law is accompanied by a memorandum of law. | D. Conn. L. Civ. R. 7(a)(1), via Local Bankr. R. 7007-1 | M |
| CTB-MB-CONT-002 | Oral-argument legend: the motion states "in the lower margin of the motion whether oral argument is requested"; an opposition memorandum states it "in the lower margin of the first page of such memorandum". Neither memorandum exemplar carries it (both are supporting memoranda; the legend belongs on the motion). The template prints it on page 1 when `oral_argument` is set, and must set it for an opposition memorandum. | D. Conn. L. Civ. R. 7(a)(1)-(2), via Local Bankr. R. 7007-1 | M (motion and opposition) |
| CTB-MB-CONT-003 | Reply memorandum: strictly confined to matters raised by the memorandum replied to, with references to its pages. | D. Conn. L. Civ. R. 7(d) | A |
| CTB-MB-CONT-004 | Motions conform to FRBP 9013 (written motion stating grounds with particularity and the relief sought) and comply with D. Conn. L. Civ. R. 7(b) for extensions. | Local Bankr. R. 9013-1 (LBR p. 62); FRBP 9013(b) | M (A for the content) |
| CTB-MB-CONT-005 | Contested matter filings: each motion, application, response, objection or reply is filed with a certificate of service; each motion or application with a proposed order. Not produced by the memorandum template. | Local Bankr. R. 9014-1(b)(1)-(2) | M (contested matters; separate documents) |
| CTB-MB-CONT-006 | Cover page carrying the caption and the title of the memorandum, unnumbered; Hamilton adds the counsel block on the cover. | EX-MB (Pillsbury, Hamilton) | C (cover); tier 3 (counsel on cover) |
| CTB-MB-CONT-007 | Table of contents and table of authorities after the cover, paged in lowercase roman numerals (i, ii, ...); body paged in arabic from 1. Both exemplars. Not required by rule (the rules only exclude them from the page count). TOA grouped Cases / Statutes / Rules (both; Pillsbury labels them "Statutes and Codes", "Rules and Regulations"). Hamilton's cover has no date although CTB-CAP-003 requires one; the template keeps the date. | EX-MB (2 filers); Local Bankr. R. 7007-2(a) (exclusion) | C |
| CTB-MB-CONT-008 | Headings: top-level sections centered bold (Preliminary Statement, Argument, Conclusion). Pillsbury numbers paragraphs; Hamilton does not and numbers sections with I./II., A./B., 1./2. Paragraph numbering is therefore one filer's style (tier 3). | EX-MB | C (centered headings); tier 3 (numbered paragraphs) |
| CTB-MB-CERT-001 | Certificate of service at the end of the memorandum: Hamilton includes one; Pillsbury does not (separate filing). In adversary proceedings service follows FRBP 7005 / the court's NEF; the template emits it when requested. | EX-MB | C (optional) |

## Author responsibilities

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CTB-AUTH-001 | Signature on a CM/ECF filing constitutes the filer's signature; documents requiring original signatures are retained by the filer. | APPX-A §§10-11 | A |
| CTB-AUTH-002 | Representations to the court under FRBP 9011(b) (proper purpose, warranted contentions, evidentiary support). | FRBP 9011(b) | A |
| CTB-AUTH-003 | Motions to dismiss a self-represented party's complaint are accompanied by a separate "Notice to Self-Represented Litigant Concerning Motion to Dismiss". | Local Bankr. R. 7012-1 (LBR p. 55); D. Conn. L. Civ. R. 12 | A |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| CTB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| CTB-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| CTB-TOOL-003 | Every TOC entry's page number equals the page on which the heading appears; every TOA page reference is a page that cites the authority (motion-brief). | T |
| CTB-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |

## Not verified

- **Official Form 416 (adversary caption).** FRBP 7010 was read; the form itself (uscourts.gov) returned HTTP 404 at the URL tried on 2026-10-17 and was not read. CTB-CAP-004 is M only for the existence of a conforming caption; its layout is C from the exemplars.
- **District Electronic Filing Order "Arial bold 12 point".** The README files cite a District Court Electronic Filing Order (revised 1/17/2018) that requires "Arial bold 12 point font". It was not re-fetched in this pass; it is a district-court case order, not a Local Bankruptcy Rule, and nothing in LBR, LBR-5005 or APPX-A adopts it. Not recorded as a requirement.
- **Per-rule HTML pages** of ctb.uscourts.gov other than 5005-1 were blocked by the site's firewall on 2026-10-17 ("Request Rejected"); all rules were read in the LBR PDF instead.
