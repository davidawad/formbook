# U.S. District Court, District of New Jersey (complaint, motion brief): rules

Alias `njd`. Scope: a civil complaint (`complaint/`) and a brief (memorandum of law) in support of a motion, typically a Rule 12(b) motion to dismiss (`motion-brief/`), filed by counsel through CM/ECF. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (FRCP amendment date) and whenever the court posts a revised "Local Civil and Criminal Rules" PDF (current: "With Revisions as of July 22, 2026"); the ECF Policies and Procedures are printed inside that PDF.

Access note: on 2026-10-17 `www.njd.uscourts.gov` rejected direct requests from this box; the rules PDF was retrieved through the WebFetch tool from the court's own URL and read with `pdftotext`.

## Sources

| Tag | Source | URL |
|---|---|---|
| LCivR | Local Civil and Criminal Rules of the U.S. District Court for the District of New Jersey, "With Revisions as of July 22, 2026" (122 pp.; includes the Electronic Case Filing Policies and Procedures after L.Civ.R. 5.2) | https://www.njd.uscourts.gov/sites/njd/files/CompleteLocalRules.pdf |
| ECF-PP | Electronic Case Filing Policies and Procedures, D.N.J. (printed in LCivR after Civ. Rule 5.2) | same PDF |
| FRCP | Federal Rules of Civil Procedure 5, 7, 7.1, 8, 10, 11, 38 (LII text) | https://www.law.cornell.edu/rules/frcp/rule_5 (and rule_7, rule_7.1, rule_8, rule_10, rule_11, rule_38) |
| EX-DGL | Complaint, *DGL Group Ltd. v. GoLabs, Inc.*, No. 2:26-cv-13086 (Kasowitz LLP) | `complaint/exemplars/` |
| EX-GOMEZ | Complaint, *Gomez v. Town of West New York*, No. 2:25-cv-02242 (Law Offices of Richard Malagiere) | `complaint/exemplars/` |
| EX-KARRE | Memorandum of law in support of motion to dismiss, *Karre v. E*Trade Securities LLC*, No. 2:26-cv-06421 (McGuireWoods, for Bank of America) | `motion-brief/exemplars/` |
| EX-ZEINES | Memorandum of law in support of motion to dismiss, *Zeines v. Blejer*, No. 2:25-cv-13335 (Freedman Normand Friedland) | `motion-brief/exemplars/` |

Kinds: **M** = mandated by a rule (FRCP, D.N.J. L.Civ.R., or the ECF Policies and Procedures). **C** = convention (from the exemplars). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **Brief typeface rule with a length penalty**: "12-point non-proportional font (such as Courier New 12) or an equivalent 14-point proportional font (such as Times New Roman 14). If a 12-point proportional font is used instead, the page limits shall be reduced by 25 percent" (L.Civ.R. 7.2(d)). A 12 pt Times brief therefore has a 30-page limit, not 40. The rule binds briefs; pleadings have no type-size rule.
2. **Every brief has a TOC and a TOA**, whatever its length (L.Civ.R. 7.2(b)), and the brief is "a separate document" whose **cover page notes the motion day** (L.Civ.R. 7.1(d)(1)).
3. **Every paper shows the docket number and the assigned Judge's name**, and the first page carries counsel's name, office, address and telephone (L.Civ.R. 10.1(b)); the initial pleading's first paragraph gives each named party's street and post office address (L.Civ.R. 10.1(a)).
4. **Initial pleading certification under L.Civ.R. 11.2** (other actions, arbitrations or administrative proceedings), and a jury demand endorsed on a pleading puts "and Demand for Jury Trial" in its title (L.Civ.R. 38.1).

## Requirements: all papers

### Page form (L.Civ.R. 10.1(b), 7.2(c)-(d); ECF-PP 1(h))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NJD-FORM-001 | "All papers shall be in black lettering on reasonably heavy paper size 8.5 x 11 inches"; plainly printed or typewritten, without interlineations or erasures that materially deface them. | L.Civ.R. 10.1(b) | M |
| NJD-FORM-002 | Every paper "shall bear the docket number and the name of the Judge assigned to the action or proceeding; and shall have endorsed upon the first page the name, office, post office address, and telephone number of the attorney of record for the filing party." | L.Civ.R. 10.1(b) | M |
| NJD-FORM-003 | PDF "should be text searchable" (ECF-PP 1(h)); each PDF within the court's posted file-size limit. | ECF-PP 1(h), 2 | M |
| NJD-FORM-004 | Times New Roman in EX-GOMEZ, EX-KARRE and EX-ZEINES (EX-DGL embeds unnamed fonts); 1 inch margins; double-spaced body. Size varies: about 14 pt (line pitch about 32 pt) in EX-GOMEZ and EX-KARRE, 12 pt (pitch about 27-28 pt) in EX-DGL and EX-ZEINES. | exemplars | C |
| NJD-FORM-005 | The top margin carries no text: CM/ECF stamps "Case ... Document ... Filed ... Page x of y PageID: n" on every page. | exemplars | C |
| NJD-FORM-006 | Every font embedded and of the template's declared family. | project | T |

### Signature, filing, service

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NJD-ELEC-001 | Papers are signed by the attorney of record who is a member of the bar of this Court; pro hac vice counsel are also responsible under FRCP 11(b). | L.Civ.R. 11.1 | M |
| NJD-ELEC-002 | An electronically filed document "must include a signature line with "s/,"" (e.g. "s/ Jennifer Doe"); the login and password are the FRCP 11 signature. FRCP 11(a): signer's address, e-mail address and telephone number. | ECF-PP 12(a); FRCP 11(a) | M |
| NJD-CERT-001 | "A certificate of service must be included with all documents filed electronically. The certificate of service must indicate how service was accomplished, i.e., electronically and/or by other means." | ECF-PP 14(b) | M |
| NJD-ELEC-003 | Disclosure statement (FRCP 7.1) and, within 30 days of the initial pleading, a separate statement of any third-party litigation funding (L.Civ.R. 7.1.1). Separate filings. | FRCP 7.1; L.Civ.R. 7.1.1 | M (separate filings) |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NJD-CONT-001 | Short and plain statement of jurisdiction, of the claim, and a demand for relief; numbered paragraphs; separate counts where that promotes clarity. | FRCP 8(a); FRCP 10(b) | M |
| NJD-CONT-002 | The first paragraph states "the street and post office address of each named party to the case or, if the party is not a natural person, the address of its principal place of business"; without counsel's and the client's addresses the paper may be stricken. | L.Civ.R. 10.1(a) | M |
| NJD-CONT-003 | The ad damnum clause demands unliquidated damages "generally without specifying the amount" (the jurisdictional amount may still be alleged). | L.Civ.R. 8.1 | M (author) |
| NJD-CONT-004 | The initial pleading "shall be accompanied by a certification or other document complying with 28 U.S.C. § 1746 as to whether the matter in controversy is the subject of any other action pending in any court, or of any pending arbitration or administrative proceeding", identifying each and its parties. | L.Civ.R. 11.2 | M |
| NJD-CONT-005 | "If a demand for jury trial under Fed. R. Civ. P. 38(b) is endorsed upon a pleading, the title of the pleading shall include the words "and Demand for Jury Trial" or the equivalent." | L.Civ.R. 38.1; FRCP 38(b) | M (conditional) |
| NJD-CONT-006 | Structure seen in both filers: caption with the court as "UNITED STATES DISTRICT COURT / DISTRICT OF NEW JERSEY"; numbered paragraphs under centered headings (EX-DGL: Introduction, Jurisdiction and Venue, Facts, counts, Prayer for Relief; EX-GOMEZ: Parties, Jurisdiction, and Venue; Facts Common to All Counts; counts); WHEREFORE clauses; "JURY DEMAND"; EX-DGL ends with a "Certification Pursuant to Local Rule 11.2". | EX-DGL, EX-GOMEZ | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NJD-LEN-001 | A brief "shall not exceed 40 ordinary typed or printed pages (15 pages for any reply brief ... and any brief in support of or in opposition to a motion for reconsideration)", excluding the table of contents and authorities; longer only with the Judge's prior permission. With a 12-point proportional font the limits are 30 and 11.25 pages. | L.Civ.R. 7.2(b), (d) | M |
| NJD-FORM-010 | "All briefs shall be in black lettering on paper size 8.5 x 11 inches. All margins shall be not less than one inch on sides, top, and bottom." | L.Civ.R. 7.2(c) | M |
| NJD-FORM-011 | "Each page of a brief shall contain double-spaced text and/or single-spaced footnotes or inserts. Typeface shall be in 12-point non-proportional font (such as Courier New 12) or an equivalent 14-point proportional font (such as Times New Roman 14)." "Footnotes shall be printed in the same size of type utilized in the text." | L.Civ.R. 7.2(d) | M |
| NJD-CONT-010 | "Any brief shall include a table of contents and a table of authorities." | L.Civ.R. 7.2(b) | M |
| NJD-COVER-001 | "The brief shall be a separate document for submission to the Court, and shall note the motion day on the cover page." (Opposition and reply briefs also specify the motion day on the cover page.) | L.Civ.R. 7.1(d)(1)-(3) | M |
| NJD-COVER-002 | Cover page layout in both filers: caption with docket number including judge initials, "Motion Date:" / "Motion Return Date:" in the right column, centered brief title, counsel block (EX-KARRE below the title; EX-ZEINES above the caption at top left). | EX-KARRE, EX-ZEINES | C |
| NJD-CONT-011 | The moving papers, the brief and proof or acknowledgment of service are filed at least 24 days before the noticed motion day; a proposed order is annexed to every filed motion; a party may file a statement that no brief is necessary instead of a brief. | L.Civ.R. 7.1(d)(1), (d)(4), (e) | M |
| NJD-CONT-012 | Affidavits and certifications contain facts only; argument goes in the brief. | L.Civ.R. 7.2(a) | A |
| NJD-CONT-013 | Body seen in both filers: TOC and TOA on roman-numbered pages; capitalized headings (EX-KARRE: Introduction, Statement of Facts, Legal Standard, Argument I-IV, Conclusion; EX-ZEINES: Preliminary Statement, Argument, Conclusion). EX-KARRE is set at about 14 pt Times; EX-ZEINES at 12 pt (and so falls under the reduced 30-page limit). | EX-KARRE, EX-ZEINES | C |

## Not verified

- The court's posted ECF file-size limit (ECF-PP) was not read.
- Judges' individual practices (some require pre-motion letters for Rule 12 motions) were not read.
