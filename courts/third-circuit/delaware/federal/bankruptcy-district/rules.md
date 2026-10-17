# U.S. Bankruptcy Court, District of Delaware (adversary complaint, motion brief): rules

Alias `deb`. Scope: a complaint commencing an adversary proceeding (`adversary-complaint/`) and an opening brief supporting a motion in an adversary proceeding, typically a motion to dismiss (`motion-brief/`), filed by counsel through CM/ECF. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each February 1 (the court's Local Rules editions take effect on February 1; current edition effective February 1, 2025) and December 1 (FRBP amendment date), and the assigned Judge's chambers procedures, which the Local Rules leave in force (Del. Bankr. L.R. 1001-1(f)).

Access note: on 2026-10-17 `www.deb.uscourts.gov` rejected direct requests from this box; the rules PDF and the court's local-rules page were retrieved through the WebFetch tool from the court's own URLs.

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | Local Rules of the United States Bankruptcy Court for the District of Delaware ("Del. Bankr. L.R."), "effective on February 1, 2025" (L.R. 1001-1(e)); 150 pp. | https://www.deb.uscourts.gov/sites/deb/files/Local_Rules_2025%20%28Clean%29.pdf |
| LR-PAGE | Court page "Local Rules and Orders" (lists "2025 Local Rules (Clean)" as current, effective February 1, 2025) | https://www.deb.uscourts.gov/local-rules-and-orders |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7007.1, 7008, 7010, 9004, 9011 (LII text, restyled eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7008 (and rule_7003, rule_7007.1, rule_7010, rule_9004, rule_9011) |
| FRCP | Federal Rules of Civil Procedure 8, 10 (applied by FRBP 7008, 7010) | https://www.law.cornell.edu/rules/frcp/rule_8 , https://www.law.cornell.edu/rules/frcp/rule_10 |
| F416D | Official Form 416D, Caption for Use in Adversary Proceeding (12/15) | https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| EX-ZOHAR | Adversary complaint, *Tilton v. MBIA Inc.*, Adv. No. 19-50390 (Cole Schotz; Gibson Dunn) | `adversary-complaint/exemplars/` |
| EX-GIULIANO | Adversary complaint, *Giuliano v. Fisk*, Adv. No. 26-50942 (Fox Rothschild) | `adversary-complaint/exemplars/` |
| EX-BUMBLEBEE | Memorandum of law in support of motion to dismiss, *Jason v. Bumble Bee Foods, LLC*, Adv. No. 19-51146 (Young Conaway; Paul, Weiss) | `motion-brief/exemplars/` |
| EX-SUN | Opening brief in support of motion to dismiss, *PCT Litigation Trust v. Sun*, Adv. No. 25-51975 (Morris James; Loeb & Loeb) | `motion-brief/exemplars/` |

Kinds: **M** = mandated by a rule (FRBP, FRCP as applied, Del. Bankr. L.R.). **C** = convention (from the exemplars). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **The font is named**: briefs in adversary motions "must be double-spaced, in Courier New or Times New Roman font and in at least 12-point typeface", side margins at least 1 inch (L.R. 7007-2(a)(ii)). Any other face (e.g. Garamond) violates the rule.
2. **No notice of motion in adversary proceedings**; the opening brief is filed with the motion, answering brief in 14 days, reply in 7 (L.R. 7007-1(a)).
3. **Brief cover page and fixed section order** like the district court's, but with longer limits: 30 pages opening/answering, 15 reply, exclusive of tables (L.R. 7007-2(a)(i), (a)(iv), (b)(i)).
4. **Caption shows the judge's initials and the docket number**, and related filings repeat the title and docket number of the document they relate to (L.R. 9004-1(a)).
5. **Waiver if the consent statement is omitted** from an adversary complaint (L.R. 7008-1).

## Requirements: all papers

### Page form and signature

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DEB-FORM-001 | A document must be clearly legible. Outside adversary briefs (L.R. 7007-2) the LBR sets no face, size or margin rule. | FRBP 9004(a) | M |
| DEB-FORM-002 | Documents filed electronically are converted to PDF "electronically, as opposed to scanning a document, where practicable." | L.R. 5005-4(d) | M |
| DEB-FORM-003 | Times New Roman, 12 pt, double-spaced (line pitch about 27-28 pt), 1 inch margins in all four exemplars. | exemplars | C |
| DEB-FORM-004 | The top margin carries no text: the court's CM/ECF stamps "Case ... Doc ... Filed ... Page x of y" at the top of each page (all four exemplars). | exemplars | C |
| DEB-FORM-005 | Every font embedded and of the template's declared family. | project | T |
| DEB-ELEC-001 | Following the signature: "the address, telephone number and email address of the attorney"; an electronically filed document shows "/s/" before the typed name (e.g. "/s/ Jane Doe"). | L.R. 9011-1(a)-(b); FRBP 9011(a) | M |
| DEB-ELEC-002 | Signature blocks in all four exemplars give Delaware counsel's bar number ("(No. 4588)", "(DE Bar No. 5214)"), with co-counsel listed after "-and-" in three of them (EX-BUMBLEBEE stacks the firms without it). | exemplars | C |
| DEB-ELEC-003 | Redaction of personal identifiers (FRBP 9037). | FRBP 9037 | A |

### Caption (L.R. 9004-1; FRBP 7010)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DEB-CAP-001 | The caption contains "the name of the debtor, the case number, the initials of the Judge to whom the case has been assigned, the docket number assigned to the case and, if applicable, the adversary proceeding number." | L.R. 9004-1(a) | M |
| DEB-CAP-002 | A document relating to a previously filed document contains in its title the related document's title and docket number, if available. | L.R. 9004-1(a) | M |
| DEB-CAP-003 | Pleadings in adversary proceedings: caption substantially conforming to Official Form 416D (court; In re debtor; plaintiff v. defendant; case and adversary numbers; title). | FRBP 7010; F416D | M |
| DEB-CAP-004 | Caption in all exemplars: "IN THE UNITED STATES BANKRUPTCY COURT FOR THE DISTRICT OF DELAWARE"; "In re:" block with Chapter and "Case No. nn-nnnnn (XXX)"; "(Jointly Administered)" where applicable; parties block with "Adv. Proc. No." or "Adv. No." and judge initials. | exemplars | C |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DEB-CONT-001 | FRCP 8 applies; the jurisdiction allegation names the case, number and chapter, and the district and division. | FRBP 7008; FRCP 8(a) | M |
| DEB-CONT-002 | Statement whether the pleader does or does not consent to entry of final orders or judgment; "If no such statement is included, unless otherwise ordered by the Court, the pleader will have waived the right to contest the authority of the Court to enter final orders or judgments." | FRBP 7008; L.R. 7008-1 | M |
| DEB-CONT-003 | Numbered paragraphs; separate counts where that promotes clarity. | FRBP 7010; FRCP 10(b) | M |
| DEB-CONT-004 | A complaint not filed electronically is accompanied by an adversary cover sheet conforming to Local Form 109. | L.R. 7003-1 | M (paper only) |
| DEB-CONT-005 | The filer prepares the Summons and Notice of Pretrial Conference (Local Form 108), serves it with the complaint and the notice of dispute resolution alternatives (Local Form 110B), and files the summons and certificate of service within 7 days after service. Separate documents. | L.R. 7004-1 | M (separate documents) |
| DEB-CONT-006 | Corporate ownership statement by a nongovernmental corporate party other than the debtor. Separate filing. | FRBP 7007.1 | M (separate filing) |
| DEB-CONT-007 | Structure seen in both filers: centered "COMPLAINT"; roman-numbered sections (EX-GIULIANO: I. Introduction, II. Jurisdiction, Venue, and Statement [of consent], III. Parties, IV. Facts, V. The Claims, VI. Relief Requested, VII. Jury Demand; EX-ZOHAR: I. Preliminary Statement, II. Parties, III. Jurisdiction and Venue, IV. Factual Allegations, V. Claim for Relief, VI. Prayer for Relief); numbered paragraphs; WHEREFORE prayer. | EX-GIULIANO, EX-ZOHAR | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DEB-LEN-001 | "Without leave of Court, no opening or answering brief may exceed 30 pages and no reply may exceed 15 pages, exclusive of any tables of contents and citations." | L.R. 7007-2(a)(iv) | M |
| DEB-FORM-010 | "All filings must be double-spaced, in Courier New or Times New Roman font and in at least 12-point typeface. Side margins of briefs may not be less than 1 inch." | L.R. 7007-2(a)(ii) | M |
| DEB-COVER-001 | "The front cover of each brief and appendix must contain the caption of the case, a title, the date of filing, the name and designation of the party for whom it is filed, and the name, address, telephone number and email address of counsel by whom it is filed, including the bar identification number for Delaware attorneys." | L.R. 7007-2(a)(i) | M |
| DEB-CONT-010 | Opening and answering briefs contain, "under distinctive titles, in the listed order": (A) table of contents with page numbers for all headings; (B) table of citations, alphabetically arranged (or a statement that there are none); (C) statement of the nature and stage of the proceeding; (D) summary of argument in separate numbered paragraphs; (E) concise statement of facts with references to appendices or record; (F) argument under appropriate headings; (G) short conclusion stating the precise relief sought. A reply brief has a TOC and table of citations. | L.R. 7007-2(b)(i)-(ii) | M |
| DEB-CONT-011 | No notice of motion; the opening brief and any affidavit or appendix are filed and served the same day as the motion; answering brief within 14 days of the opening brief; reply within 7 days. | L.R. 7007-1(a) | M |
| DEB-CONT-012 | Bluebook citation form, National Reporter System cites, official U.S. cite; earlier filings cited as "D.I. n"; unreported opinions not on Westlaw/Lexis attached. Appendix pages numbered separately with "A", "B" or "C" prefixes. | L.R. 7007-2(a)(iii), (v)-(vii) | A (citations); M (appendix numbering) |
| DEB-CONT-013 | After briefing, the movant files a "Notice of Completion of Briefing" (or a Certificate of No Objection) within 7 days. Separate document. | L.R. 7007-4 | M (separate document) |
| DEB-CONT-014 | Structure seen in both filers: cover page with caption, brief title and counsel blocks (EX-SUN shows emails, as L.R. 7007-2(a)(i) requires; EX-BUMBLEBEE does not); TOC; TOA. EX-BUMBLEBEE then follows L.R. 7007-2(b)(i) ("Nature and Stage of the Proceeding and Summary of Arguments", "Statement of Facts", "Argument", "Conclusion"); EX-SUN uses "Preliminary Statement", "Jurisdiction and Venue", "Argument", "Conclusion" and omits a separate summary of argument. | EX-BUMBLEBEE, EX-SUN | C |

## Not verified

- Local Forms 108, 109 and 110B were not fetched.
- Individual Judges' chambers procedures (L.R. 1001-1(f)) were not read.
