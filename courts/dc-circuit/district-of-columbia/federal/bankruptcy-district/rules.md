# Bankruptcy Court, District of Columbia: rules

Alias `dcb`. Scope: filings by counsel through NextGen CM/ECF in the United States Bankruptcy Court for the District of Columbia; doc types `adversary-complaint` (complaint commencing an adversary proceeding, FRBP 7001, 7003) and `motion-brief` (a written motion with its argument, or with the memorandum of facts and law combined in the same filing, LBR 9013-1(b)(2)). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (national rule amendments) and whenever the court posts amended Local Bankruptcy Rules, an amended Appendix D (ECF Procedures) or a new general order on its local-rules page (https://www.dcb.uscourts.gov/local-rules). The current rules are "IN EFFECT AS OF April 1, 2025".

**Access note.** On 2026-10-17 the court's site (www.dcb.uscourts.gov) answered every request from this box with an F5 "Request Rejected" page (curl) or HTTP 403 (WebFetch). The court's rules PDF was therefore read from the Internet Archive's stored copy of the court's own file (both URLs are given). The Archive's index of `dcb.uscourts.gov/sites/dcb/files/` lists no later LBR file than this one (newest files indexed: General Order 25-02 of October 1, 2025, on the lapse in appropriations, and hearing notices of 2026); an amendment posted after the last capture would not be reflected. The doc-type READMEs cite the same rules as attached to General Order 2025-01 (signed March 3, 2025; revisions effective April 1, 2025), read from the live site on 2026-10-14.

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | Local Rules of the United States Bankruptcy Court for the District of Columbia, "IN EFFECT AS OF April 1, 2025" (146 pp.; Appendices A to F included) | court file https://www.dcb.uscourts.gov/sites/dcb/files/2025-04-01%20LBR%20Final%20for%20Website.pdf; read from https://web.archive.org/web/20250523075000id_/https://www.dcb.uscourts.gov/sites/dcb/files/2025-04-01%20LBR%20Final%20for%20Website.pdf |
| ECFP | LBR Appendix D, "Administrative Procedures for Filing, Signing, and Verifying Documents by Electronic Means", "Effective Date: August 2, 2022" (pp. D-1 to D-7 of LBR; incorporated by LBR 5005-4(a), which says the ECF Procedures govern on the technicalities of e-filing) | same file as LBR |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7007.1, 7008, 7010, 9004, 9011, 9013 (restyled, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7008 (and `rule_7003`, `rule_7007.1`, `rule_7010`, `rule_9004`, `rule_9011`, `rule_9013`) |
| FRCP | Federal Rules of Civil Procedure 8(a), 10(a)-(b) (applied by FRBP 7008, 7010) | https://www.law.cornell.edu/rules/frcp/rule_8, https://www.law.cornell.edu/rules/frcp/rule_10 |
| EX-A1 | Adversary complaint: Webster (ch. 7 trustee) v. Square Funding LLC, Adv. 25-10054, Doc. 1 (The VerStandig Law Firm) | `adversary-complaint/exemplars/SOURCE.md` |
| EX-A2 | Adversary complaint: MP PPH LLC v. District of Columbia, docketed in Case 23-00246, Doc. 88 (Stinson LLP) | `adversary-complaint/exemplars/SOURCE.md` |
| EX-M1 | Motion to dismiss with memorandum: Swain Landing LaPlata JC, LLC v. Swain, Adv. 25-10013, Doc. 5, for the defendants (McNamee Hosea) | `motion-brief/exemplars/SOURCE.md` |
| EX-M2 | Motion: In re Compass Coffee, LLC, Case 26-00005, Doc. 14, Debtor's Motion to Reject Certain Unexpired Non-Residential Leases (Hunton Andrews Kurth) | `motion-brief/exemplars/SOURCE.md` |

Kinds: **M** = mandated by a court rule (FRBP, LBR, or the ECF Procedures the LBR incorporate). **C** = convention (seen across exemplars of different filers; the rules leave it open). **T** = project/tooling rule. **A** = author responsibility, not machine-checkable.

Findings:

1. **No typeface, type size, margin or spacing rule for counsel's papers.** The LBR and Appendix D were searched for "font", "typeface", "point", "margin", "double", "spac": the only format rule is LBR 5005-1(b), which binds pro se paper filings ("letter size paper (8 ½ by 11 inches) with no less than 1-inch margins on all sides, be plainly and legibly typewritten"). For counsel, FRBP 9004(a) ("clearly legible") is the only rule. Letter size, one-inch margins, 12 pt and double spacing are conventions here.
2. **Attorney identifiers on the first page** (LBR 5005-1(c)): name, bar number, office address, email, telephone and whom the attorney represents, in the header or footer of the first page; D.C. Bar number for each listed D.C. Bar member. All four exemplars put this block in the upper left above the court name.
3. **Final-orders consent statement** is required in an adversary complaint (FRBP 7008; LBR 7012-1), and a party that omits it "is deemed to have consented". Neither complaint exemplar has one (both are non-conforming on this point).
4. **Notice of motion (Official Form B 420A)** must be included with or accompany a motion, including one in an adversary proceeding (LBR 9013-1(c)), unless a LBR 9013-2 motion to shorten is filed or an exception applies. Neither motion exemplar includes one in the PDF (EX-M2 is a first-day motion; any notice would be a separate docket entry).
5. **No page limit** for motions or memoranda in this court (searched "page", "exceed", "limit"; the only page limits are in Appendix A, DCt.LBR rules for District Court proceedings, e.g. 45/25 pages for memoranda on objections under FRBP 9033(b)).
6. **Signatures** are "/s/ User's Name" (ECFP 7(a)); transmission is the FRBP 9011 signature (LBR 9011-1(b)).
7. **File size 50 MB** per document; larger documents are split into attachments (ECFP 3(d)).

## Court-wide requirements

### Page form (FRBP 9004; LBR 5005-1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCB-FORM-001 | A document "must be clearly legible". | FRBP 9004(a) (FRBP) | M |
| DCB-FORM-002 | Typeface: the rules name none (Finding 1). Times New Roman is the body face of all four exemplars (EX-A1, EX-A2, EX-M1, EX-M2; four filers): a convention. The template's vendored serif may substitute. | FRBP 9004(a), LBR (silent); EX-A1, EX-A2, EX-M1, EX-M2 | C |
| DCB-FORM-003 | Paper 8 1/2 x 11 inch (612 x 792 pt). The rule text binds pro se paper filings only ("letter size paper (8 ½ by 11 inches)"); every exemplar is letter size. Scanned documents "shall not exceed 8½ by 11 inches". | LBR 5005-1(b) (LBR); ECFP 3(d) (ECFP); EX-A1, EX-A2, EX-M1, EX-M2 | C (counsel); M (pro se, scans) |
| DCB-FORM-004 | Margins at least one inch: the rule text ("no less than 1-inch margins on all sides") binds pro se filings; all four exemplars keep about one inch. Type size 12 pt body and double-spaced body text: no rule; seen in all four exemplars. | LBR 5005-1(b) (LBR); EX-A1, EX-A2, EX-M1, EX-M2 | C |
| DCB-FORM-005 | Page numbers centered at the foot of each page, page 1 included (all four exemplars). No rule requires numbering. | EX-A1, EX-A2, EX-M1, EX-M2 | C |
| DCB-FORM-006 | Every font used is embedded and is the template's declared family. | project | T |
| DCB-FORM-007 | The top margin carries no text: CM/ECF stamps "Case ... Doc ... Filed ... Entered ... Desc Main / Document Page n of N" there (all four exemplars). | EX-A1, EX-A2, EX-M1, EX-M2 | C |

### Caption, counsel identification and signature (FRBP 9004(b), 7010, 9011; LBR 5005-1(c), 9011-1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCB-CAP-001 | Caption sets out: "(1) the court's name; (2) the case's title; (3) the case number and, if appropriate, adversary-proceeding number; and (4) a brief designation of the document's character." | FRBP 9004(b) (FRBP) | M |
| DCB-CAP-002 | Court name centered in bold capitals on two lines, "[IN THE] UNITED STATES BANKRUPTCY COURT" / "[FOR THE] DISTRICT OF COLUMBIA" (all four exemplars; "IN THE" in EX-A1 and EX-M1 only). The bankruptcy-case block ("In re: ... Debtor.", case number and chapter at right) sits above the adversary block (plaintiff v. defendant, adversary number at right) in EX-A1, EX-A2, EX-M1; the separator column is ")" in EX-A1 and EX-A2, "*" in EX-M1 (that filer's style); EX-M2 uses a borderless two-column layout. | EX-A1, EX-A2, EX-M1, EX-M2 | C |
| DCB-CAP-003 | Attorney identifiers on the first page of every pleading by a represented party, "in either the footer or header of the first page": name, bar number, office address, email address, telephone number, "and whom the attorney represents". Placement in the upper left, single-spaced, above the court name: all four exemplars. | LBR 5005-1(c) (LBR); EX-A1, EX-A2, EX-M1, EX-M2 | M (content); C (placement) |
| DCB-CAP-004 | For an entity represented by counsel, any paper signed by the attorney includes the attorney's name, office address, email address and telephone number; "the attorney's D.C. Bar identification number must be listed if the attorney is a member of the D.C. Bar regardless of whether the attorney signs the paper". | LBR 5005-1(c) (LBR) | M |
| DCB-SIG-001 | Signed by at least one attorney of record in the attorney's individual name; the document states the signer's address and telephone number. | FRBP 9011(a) (FRBP) | M |
| DCB-ELEC-003 | Electronic signature: "All pleadings and other papers and documents filed electronically shall indicate the signature by placing "/s/ User's Name" where the original signature occurs." Transmission constitutes the FRBP 9011(a) signature. | ECFP 7(a)-(c) (ECFP); LBR 9011-1(b) (LBR) | M |
| DCB-SIG-002 | Signature block at the right half: "Respectfully submitted," (EX-A1, EX-A2, EX-M2) then the /s/ line and the counsel block with bar numbers; date line at the left ("Dated: ..."). Seen in all four exemplars with minor variations. | EX-A1, EX-A2, EX-M1, EX-M2 | C |
| DCB-AUTH-001 | Privacy redaction under FRBP 9037 (last four digits of SSNs and account numbers, birth year, minors' initials) is the filer's responsibility. | FRBP 9037 (cited by LBR 9013-1(c)(1)(E)); LBR 9037-1 (LBR) | A |

### Service (LBR 9013-1(f); ECFP 8)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCB-CERT-001 | For each paper required to be served on a party, a certificate of service is filed, detailing the date, manner of service, and names and addresses of each recipient not served through NextGen CM/ECF. It "may be included at the end of a pleading or may be filed separately"; if not filed with the pleading, within seven days of service. EX-M1 appends one; EX-M2 has none in the PDF. | LBR 9013-1(f) (LBR); EX-M1 | M (conditional); C (appended) |
| DCB-CERT-002 | Electronic transmission of the NEF constitutes service on registered users who consented; a summons (FRBP 7004) must also be served in paper form. | ECFP 8(c), 8(e), 8(f) (ECFP) | M |

### Electronic filing (LBR 5005-4; Appendix D)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCB-ELEC-001 | Attorneys file electronically in compliance with the ECF Procedures; the ECF Procedures govern the technicalities of e-filing. | LBR 5005-4(a) (LBR) | M |
| DCB-ELEC-002 | File size 50 MB or smaller per document; larger documents are segmented into attachments. Accepted: PDF/A, scanned documents, OCR text, external hyperlinks. The template produces a text-searchable PDF (check: text extracts on every page, fonts embedded). | ECFP 3(d) (ECFP) | M (size); C (text layer) |
| DCB-ELEC-004 | Filing is complete before midnight Eastern time on the deadline day; the filing time is the NEF time. | ECFP 3(b)-(c) (ECFP) | A |
| DCB-ELEC-005 | Exhibits are filed electronically, limited to excerpts directly germane, "clearly and prominently identified as such". | ECFP 5 (ECFP) | A |
| DCB-ELEC-006 | A proposed order (separate upload) has a 3 to 4 inch blank top margin on its first page, "End of Order" after the last line, no judge's date or signature line, and is PDF. Not part of these doc types; recorded so no template prints an order inside the motion. | ECFP 4(b) (ECFP); LBR 9072-1 (LBR) | M (separate document) |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCB-CONT-010 | FRCP 8 applies; the jurisdiction allegation must include "a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending". | FRBP 7008 (FRBP); FRCP 8(a) (FRCP) | M (A for content) |
| DCB-CONT-011 | The complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court". LBR 7012-1: all parties include in their initial substantive filing a statement on consent to final orders and/or judgments; omission means the party "is deemed to have consented". Neither EX-A1 nor EX-A2 has the statement (both non-conforming). | FRBP 7008 (FRBP); LBR 7012-1 (LBR) | M |
| DCB-CONT-012 | FRCP 10 applies, "except that a pleading's caption must substantially conform to the appropriate version of Form 416": caption names all parties; claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts where that promotes clarity. | FRBP 7010 (FRBP); FRCP 10(a)-(b) (FRCP) | M |
| DCB-CONT-013 | Caption carries the bankruptcy case number and chapter and an adversary-number line, left blank on the complaint ("Adv. Case No. ____" in EX-A1, "Adv. Proc. No." in EX-A2). | FRBP 9004(b)(3) (FRBP); EX-A1, EX-A2 | M (case number); C (blank adversary line) |
| DCB-CONT-014 | Adversary proceeding cover sheet: filed with the complaint only by "a party who is not represented by an authorized filing user"; not produced for counsel. | LBR 7003-1 (LBR) | M (conditional, separate document) |
| DCB-CONT-015 | Corporate ownership statement (FRBP 7007.1) is a single separate CM/ECF filing with the initial pleading, with an address for each entity listed. | FRBP 7007.1 (FRBP); LBR 7007.1-1 (LBR) | M (separate document) |
| DCB-CONT-016 | The Clerk issues the summons (separate document; reissue if not served within seven days). | FRBP 7004; LBR 7004-2 (LBR) | M (separate document) |
| DCB-CONT-017 | Section headings centered and bold (e.g. Introduction/Nature of the Action, Parties, Jurisdiction and Venue, Count I with the statute line under it); allegations numbered consecutively through the counts; a WHEREFORE prayer after each count (EX-A1) or a single "PRAYER FOR RELIEF" (EX-A2). Centered bold headings and continuous numbering are seen in both filers; the prayer placement differs (each filer's style). | EX-A1, EX-A2 | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DCB-CONT-020 | A request for an order is made by written motion that states its grounds with particularity and sets forth the relief requested; motions are filed with the applicable NextGen CM/ECF docketing events. | FRBP 9013(a)-(b) (FRBP); LBR 9013-1(a), (b)(1) (LBR) | M |
| DCB-CONT-021 | "A memorandum of facts and law may be filed with or combined with a motion." EX-M1 combines motion and memorandum in one document; EX-M2 is a motion with its argument under "Basis for Relief". | LBR 9013-1(b)(2), (e)(2) (LBR); EX-M1, EX-M2 | M (option) |
| DCB-CONT-022 | Required notice: unless a LBR 9013-2 motion to shorten is filed or an exception in LBR 9013-1(c)(1) applies, a motion, "including a motion filed in an adversary proceeding, shall include or be accompanied by a conspicuous notice of the motion, objection deadline, and hearing, if applicable", conforming substantially to Official Form B 420A. Neither exemplar includes the notice in its PDF. | LBR 9013-1(c) (LBR) | M |
| DCB-CONT-023 | Response deadline stated in the notice: 14 days when no hearing is set (reply within 7 days); 7 days before a hearing set on at least 21 days' notice; 3 business days before a hearing set on less than 21 days' notice. | LBR 9013-1(d) (LBR) | A |
| DCB-LEN-001 | No page limit for motions or memoranda in this court (Finding 5). | LBR (silent) | M (none) |
| DCB-CERT-003 | Certificate of service per DCB-CERT-001 for a served motion; filed in advance of the hearing when expedited relief is sought. | LBR 9013-1(f) (LBR) | M (conditional) |
| DCB-CONT-024 | Initial pleading of a party in an adversary proceeding (for example a motion to dismiss as the defendant's first filing) carries the LBR 7012-1 consent statement. EX-M1 (the defendants' first filing) lacks it. | LBR 7012-1 (LBR) | M (conditional) |
| DCB-CONT-025 | Title in bold capitals centered under the caption; numbered paragraphs; Roman-numbered or centered section headings (e.g. "Jurisdiction, Venue, and Predicates for Relief", "Relief Requested", "Basis for Relief", "Notice" in EX-M2; memorandum sections in EX-M1). No table of contents in either (6 and 7 pages). | EX-M1, EX-M2 | C |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| DCB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| DCB-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| DCB-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect. | T |

Not verified: Official Form 416 (caption) and Official Form B 420A (notice of motion) wording was not re-read in this pass; judges' chambers procedures were not fetched. The doc-type READMEs' citations (FRBP 7008(a), 7010, 9004(a)-(b), 9013; LBR 5005-1(b)-(c), 7003-1, 7004-2, 7007.1-1, 7012-1, 9013-1(b)(2), 9013-1(c)) were all confirmed against the April 1, 2025 text and the LII pages.
