# U.S. District Court, District of Delaware (complaint, motion brief): rules

Alias `ded`. Scope: a civil complaint (`complaint/`) and an opening brief in support of a motion, typically a Rule 12(b) motion to dismiss (`motion-brief/`), filed by counsel through CM/ECF. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each September 1 (the court's local rules were last amended effective September 1, 2026) and December 1 (FRCP amendment date), and for each case the assigned judge's standing orders and form scheduling orders, which frequently change font and length requirements.

Access note: on 2026-10-17 `www.ded.uscourts.gov` rejected direct requests from this box; the rules PDF and the 2019 standing order were retrieved through the WebFetch tool from the court's own URLs and read with `pdftotext`.

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | Local Rules of Civil Practice and Procedure of the U.S. District Court for the District of Delaware, "(Amended Effective September 1, 2026)" (47 pp.) | https://www.ded.uscourts.gov/sites/ded/files/2026%20District%20of%20Delaware%20Revised%20Local%20Rules%20Effective%20September%201.pdf |
| SO-2019 | Standing Order Regarding Briefing in All Cases, December 9, 2019 (word-count alternative to page limits) | https://www.ded.uscourts.gov/sites/ded/files/Standing%20%20Order_0.pdf |
| FRCP | Federal Rules of Civil Procedure 5, 7, 7.1, 8, 10, 11, 38 (LII text) | https://www.law.cornell.edu/rules/frcp/rule_5 (and rule_7, rule_7.1, rule_8, rule_10, rule_11, rule_38) |
| EX-BSC | Complaint for patent infringement, *Boston Scientific Corp. v. Atraverse Medical, Inc.*, No. 1:26-cv-01294 (Fish & Richardson) | `complaint/exemplars/` |
| EX-MAYNE | Complaint, *Mayne Pharma LLC v. TherapeuticsMD, Inc.*, No. 1:25-cv-00670 (Morris Nichols; Arnold & Porter) | `complaint/exemplars/` |
| EX-ABRAMSON | Opening brief in support of motion to dismiss, *Abramson v. Safe Life Policy, LLC*, No. 1:26-cv-00772 (Heyman Enerio Gattuso & Hirzel; Fellows Labriola) | `motion-brief/exemplars/` |
| EX-PANINI | Opening brief in support of motion to dismiss, *Murdock v. Panini America, Inc.*, No. 1:26-cv-00849 (Troutman Pepper Locke) | `motion-brief/exemplars/` |

Kinds: **M** = mandated by a rule (FRCP, D. Del. LR, or a court-wide standing order). **C** = convention (from the exemplars). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **Double spacing must be real double spacing**: it "must be according to typical word processing software and cannot be "exactly 24 point" or similar" (LR 5.1.1(a)). A template's line pitch must be the face's natural double spacing, not a fixed 24 pt.
2. **Briefs have a front cover** with the court, caption, civil action number, a description of the paper, the date of filing, the party, and Delaware counsel's name, Delaware bar number, address and telephone (LR 7.1.3(a)(1)).
3. **Fixed section list and order** for opening and answering briefs: TOC; table of citations; nature and stage of the proceedings; summary of argument in separately numbered paragraphs; concise statement of facts; argument; short conclusion stating the precise relief (LR 7.1.3(b)(1)).
4. **Length**: opening/answering 20 pages, reply 10, exclusive of the tables (LR 7.1.3(a)(4)); or, under the court-wide 2019 standing order, 250 words per page (5,000 / 2,500 words) with a word-count certification attached (SO-2019). Individual judges' orders may change both.
5. **No certificate of service when everyone is on CM/ECF**: the NEF "shall serve as the certificate of service; i.e., no separate certificate of service shall be filed" (LR 5.2(a)). EX-PANINI carries one because a party was served by mail.
6. **Docket citations as "D.I. n"** (LR 7.1.3(a)(6)) and Bluebook citation form (LR 7.1.3(a)(5)).

## Requirements: all papers

### Page form (LR 5.1.1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DED-FORM-001 | Papers "shall be on 8½ by 11 inch white paper and shall be plainly typewritten or printed". | LR 5.1.1(a) | M |
| DED-FORM-002 | "double-spaced, except for quoted material and footnotes. Double-spacing must be according to typical word processing software and cannot be "exactly 24 point" or similar." | LR 5.1.1(a) | M |
| DED-FORM-003 | "All printed matter must appear in at least 12 point type and all margins shall not be less than 1 inch." No face is named. | LR 5.1.1(a) | M |
| DED-FORM-004 | "Each page shall be numbered consecutively." | LR 5.1.1(a) | M |
| DED-FORM-005 | Papers "shall set forth the date of filing and a brief descriptive title indicating the purpose of the paper." | LR 5.1.1(a) | M |
| DED-FORM-006 | Times New Roman, 12 pt, double-spaced (line pitch about 27-28 pt), 1 inch margins in all four exemplars. | exemplars | C |
| DED-FORM-007 | The top margin carries no text: CM/ECF stamps "Case ... Document ... Filed ... Page x of y PageID #: n" on every page. | exemplars | C |
| DED-FORM-008 | Every font embedded and of the template's declared family. | project | T |

### Signature, filing, service (LR 5.1.1, 5.2; FRCP 11)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DED-ELEC-001 | "the name, Delaware state bar identification number, address, telephone number, and email address of Delaware counsel shall be typed or printed under the signature line." FRCP 11(a): signer's address, e-mail and telephone. | LR 5.1.1(a); FRCP 11(a) | M |
| DED-ELEC-002 | Signature blocks in all four exemplars give Delaware counsel's bar number as "(Del. Bar No. n)" or "(#n)"; EX-MAYNE and EX-ABRAMSON add an "OF COUNSEL:" column for out-of-state counsel. | exemplars | C |
| DED-CERT-001 | If all parties participate in CM/ECF, the NEF "shall serve as the certificate of service; i.e., no separate certificate of service shall be filed" (sealed filings excepted). Otherwise the paper carries a certificate of service by a member of the Bar of this Court. | LR 5.2(a)-(b) | M |
| DED-ELEC-003 | A nonconforming paper may be held without action until corrected. | LR 5.1.2 | M |
| DED-ELEC-004 | Disclosure statement (FRCP 7.1) with the first appearance. Separate filing. | FRCP 7.1 | M (separate filing) |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DED-CONT-001 | Short and plain statement of jurisdiction, of the claim, and a demand for relief; numbered paragraphs; separate counts where that promotes clarity. | FRCP 8(a); FRCP 10(b) | M |
| DED-CONT-002 | If a jury trial is demanded by endorsement on the pleading, "a notation shall be placed in the caption of the pleading stating "Demand For Jury Trial" or the equivalent." | LR 38.1; FRCP 38(b) | M (conditional) |
| DED-CONT-003 | The initiating party files a civil cover sheet, indicating any related action. Separate document. | LR 3.1(a)-(b) | M (separate document) |
| DED-CONT-004 | Structure seen in both filers: caption with ")" column and blank "C.A. No."; centered "COMPLAINT"; "NATURE OF THE ACTION", parties, "JURISDICTION AND VENUE", facts; counts; "PRAYER FOR RELIEF" with WHEREFORE; EX-BSC adds "JURY TRIAL DEMAND"; signature with Delaware bar numbers (EX-MAYNE adds an "OF COUNSEL:" column). | EX-BSC, EX-MAYNE | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DED-LEN-001 | "No opening or answering brief shall exceed 20 pages, and no reply brief shall exceed 10 pages, in each instance exclusive of any table of contents or table of citations." | LR 7.1.3(a)(4) | M |
| DED-LEN-002 | Alternative word limit for double-spaced submissions with page limits: 250 words per page, not exceeding the page limit's total (20 pages = 5,000 words); "a certification as to the total number of words must be attached as part of the submission." | SO-2019 | M (when the word option is used) |
| DED-COVER-001 | Front cover: "the name of the Court, the caption of the case, the civil action number, a description of the paper's nature, the date of filing, the name and designation of the party for whom the paper is filed, and the name, Delaware bar identification number, address, and telephone number of counsel by whom it is filed." | LR 7.1.3(a)(1) | M |
| DED-CONT-010 | Opening and answering briefs contain, "under distinctive titles, in the listed order": (A) table of contents with page numbers of each section and heading; (B) table of citations (or a statement that there are none); (C) statement of the nature and stage of the proceedings; (D) summary of argument in separately numbered paragraphs; (E) concise statement of facts with record references; (F) argument under appropriate headings; (G) short conclusion stating the precise relief sought. | LR 7.1.3(b)(1) | M |
| DED-CONT-011 | Citations per the Bluebook, with National Reporter System cites (official cite for Supreme Court); earlier papers cited as "D.I." plus docket number; unreported opinions not on Westlaw/Lexis attached. | LR 7.1.3(a)(5)-(7) | A |
| DED-CONT-012 | A moving party states the relief and grounds in the motion or accompanies it with a supporting brief; response within 14 days, reply within 7. A nondispositive motion carries an averment of a reasonable effort to agree, including oral communication between Delaware counsel. | LR 7.1.2(a)-(b); LR 7.1.1 | M |
| DED-CONT-013 | Structure seen in both filers: cover page (EX-PANINI numbered "i") with caption, title and Delaware counsel; TOC; TOA; body sections. EX-PANINI follows LR 7.1.3(b)(1) by name (Nature and Stage of the Proceedings, Summary of the Argument, Statement of Facts, Argument, Conclusion) with an added Introduction; EX-ABRAMSON has only Argument and Conclusion after the tables. | EX-PANINI, EX-ABRAMSON | C |

## Not verified

- Judge-specific standing orders and form scheduling orders (some require 14-point type or set separate word limits for case-dispositive briefs) were not read.
- The court's CM/ECF Procedures referred to in LR 5.1.1(a) and 5.2 were not read.
