# U.S. Bankruptcy Court, Middle District of Pennsylvania (adversary complaint, motion brief): rules

Alias `pamb`. Scope: a complaint commencing an adversary proceeding (`adversary-complaint/`) and a brief in support of a motion in a contested matter or adversary proceeding (`motion-brief/`), filed by counsel through CM/ECF. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (FRBP amendment date) and whenever the court posts a new "Local Rules Effective ..." edition on its Local Rules page (the court amends its rules several times a year: Oct 1 2024, Dec 1 2024, May 1 2025, Oct 1 2025).

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | Local Bankruptcy Rules, M.D. Pa., "Effective: January 1, 2005 (Modified: Oct 1, 2025)", 73 pp. (the current edition, first in the court's list "Local Rules Effective Oct 1, 2025") | https://www.pamb.uscourts.gov/sites/default/files/local-rules/usbc_pamb_local_rules.pdf |
| LBR-PAGE | Court page "Local Rules" (lists the editions) | https://www.pamb.uscourts.gov/court-info/local-rules-and-orders |
| PAMD-LR | U.S. District Court M.D. Pa. Local Rules, as amended December 1, 2014: LR 7.1-7.8 apply in adversary proceedings (L.B.R. 7002-1) | https://www.pamd.uscourts.gov/sites/pamd/files/LR120114.pdf (read from https://web.archive.org/web/20191127182733/https://www.pamd.uscourts.gov/sites/pamd/files/LR120114.pdf; the district site rejects this box) |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7007.1, 7008, 7010, 9004, 9011, 9013 (LII text, restyled eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7008 (and rule_7003, rule_7007.1, rule_7010, rule_9004, rule_9011, rule_9013) |
| FRCP | Federal Rules of Civil Procedure 8, 10 (applied by FRBP 7008, 7010) | https://www.law.cornell.edu/rules/frcp/rule_8 , https://www.law.cornell.edu/rules/frcp/rule_10 |
| F416D | Official Form 416D, Caption for Use in Adversary Proceeding (12/15) | https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| EX-SHEILS | Adversary complaint, *Sheils v. National Debt Relief, LLC*, Adv. No. 5:20-ap-00078 (Sheils Law Associates, for the chapter 7 trustee) | `adversary-complaint/exemplars/` |
| EX-MULLEN | Brief in support of debtor's motion, *In re Mullen*, No. 5:22-bk-00237 (Tullio DeLuca, for the debtor) | `motion-brief/exemplars/` |

Kinds: **M** = mandated by a rule (FRBP, FRCP as applied, L.B.R., or the district LR made applicable). **C** = convention (from the exemplars). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **No typeface, size, spacing or margin rule.** The L.B.R. text (Oct 1, 2025) has no rule on font, point size, line spacing or margins (searched for "font", "point", "margin", "double", "typeface"). The district court's LR 5.1 (14 point) is *not* among the district rules the L.B.R. adopts: L.B.R. 7002-1 adopts only "LR 7.1 through 7.8 and 15.1", and only in adversary proceedings. Every format choice below is therefore C.
2. **Brief length** is set twice to the same numbers: L.B.R. 9013-2 for every matter (15 pages, or 5,000 words with a word-count certificate) and district LR 7.8 in adversary proceedings.
3. **Certificate of service contents are prescribed** (L.B.R. 9013-3) for any document not served through ECF.
4. **Consent statement.** Since Dec. 1, 2016 an adversary complaint must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court (FRBP 7008). EX-SHEILS (2020) has none; the template must still carry it.

## Requirements: all papers

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAMB-FORM-001 | A document "must be clearly legible". No other form rule (paper size, face, size, spacing, margins) is set by the FRBP or L.B.R. for these papers. | FRBP 9004(a); LBR (no rule found) | M (legibility only) |
| PAMB-FORM-002 | Letter paper (8 1/2 x 11 in) with about 1 inch margins: both exemplars. | EX-SHEILS, EX-MULLEN | C |
| PAMB-FORM-003 | Times-family serif (both exemplars embed Times), smaller than the district court's 14 pt (pdftotext word boxes about 11 pt high, against 15-19 pt in the 14 pt M.D. Pa. district filings; consistent with 12 pt), double-spaced body (line pitch about 28-30 pt). Two filers, one per doc type: common practice, not a rule. | EX-SHEILS, EX-MULLEN | C |
| PAMB-FORM-004 | The bottom margin carries no text other than the page number: bankruptcy CM/ECF stamps "Case ... Doc ... Filed ... Entered ... Desc Main Document Page x of y" at the foot of every page (both exemplars). | exemplars | C |
| PAMB-FORM-005 | Every font embedded and of the template's declared family. | project | T |

### Caption, signature, filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAMB-CAP-001 | Caption: the court's name; the case's title; the case number and, if appropriate, adversary-proceeding number; and a brief designation of the document's character. | FRBP 9004(b) | M |
| PAMB-CAP-002 | In a contested matter, the caption is "substantially in compliance with L.B.F. 9004-1"; in an adversary proceeding, "substantially in compliance with the Caption for Use in Adversary Proceeding (Official Form 416D)". | L.B.R. 9004-1; FRBP 7010 | M |
| PAMB-CAP-003 | Official Form 416D layout: "United States Bankruptcy Court / ____ District Of ____"; "In re ____, Debtor" with Case No. and Chapter at right; then "____, Plaintiff" v. "____, Defendant" with "Adv. Proc. No." at right; then the document title (e.g. "COMPLAINT"). | F416D | M (substantial compliance) |
| PAMB-CAP-004 | Court name set as "IN THE UNITED STATES BANKRUPTCY COURT FOR THE MIDDLE DISTRICT OF PENNSYLVANIA", parties at left with a ":" column, case number and chapter at right (both exemplars). | EX-SHEILS, EX-MULLEN | C |
| PAMB-ELEC-001 | Represented entities file through CM/ECF per the CM/ECF Administrative Procedures; an electronic signature is an original signature; documents requiring original signatures are kept for 2 years. | L.B.R. 5005-1(a)(1), (a)(3) | M |
| PAMB-ELEC-002 | Signed by at least one attorney of record in the attorney's individual name; the document states the signer's address and telephone number; the attorney also provides an e-mail address. | FRBP 9011(a); L.B.R. 9010-2 | M |
| PAMB-ELEC-003 | Redaction of personal identifiers per FRBP 9037; the clerk does not review for compliance. | FRBP 9037; L.B.R. 9037-1(a) | A |
| PAMB-CERT-001 | Each document not served through ECF includes a certificate of service stating: (a) the title of the paper served; (b) the names and addresses of all persons served; (c) the entities they represent; (d) when and how service was made. | L.B.R. 9013-3 | M (when served other than by ECF) |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAMB-CONT-001 | FRCP 8 applies: a short and plain statement of the grounds for jurisdiction, of the claim, and a demand for the relief sought. The jurisdiction allegation "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending." | FRBP 7008; FRCP 8(a) | M |
| PAMB-CONT-002 | The complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | FRBP 7008 | M |
| PAMB-CONT-003 | FRCP 10 applies (caption with title naming all parties; numbered paragraphs; separate counts), except the caption follows Official Form 416D. | FRBP 7010; FRCP 10(a)-(b) | M |
| PAMB-CONT-004 | A *paper* complaint is accompanied by the Adversary Proceeding Cover Sheet (Official Form 1040). Separate document; not part of the template; the CM/ECF event collects the same data. | L.B.R. 7003-1 | M (paper filings) |
| PAMB-CONT-005 | District LR 7.1-7.8 and 15.1 apply in the adversary proceeding (motions, briefs, amended pleadings). | L.B.R. 7002-1 | M |
| PAMB-CONT-006 | A nongovernmental corporate party other than the debtor files a corporate ownership statement with its first appearance, pleading or motion. Separate filing. | FRBP 7007.1 | M (separate filing) |
| PAMB-CONT-007 | Body seen in EX-SHEILS: centered title ("TRUSTEE'S COMPLAINT FOR TURNOVER OF FUNDS"), "NOW COMES Plaintiff ..." opening, numbered paragraphs without section headings, a WHEREFORE clause, signature block. One filer: that filer's style. | EX-SHEILS | C (one filer) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAMB-LEN-001 | "no brief filed in any matter in this Court (including adversary or contested matters) shall exceed fifteen (15) pages in length", except as below. | L.B.R. 9013-2(a) | M |
| PAMB-LEN-002 | "A brief may exceed fifteen (15) pages provided it does not exceed 5,000 words"; longer briefs need prior authorization sought at least two working days before the brief is due. | L.B.R. 9013-2(b)-(c); PAMD-LR 7.8(b) (adversary proceedings) | M |
| PAMB-CERT-010 | A brief filed under the 5,000-word option includes a certificate (subject to FRBP 9011) that it complies with the word-count limit; "The certificate must state the actual number of words in the brief." | L.B.R. 9013-2(b) | M (conditional) |
| PAMB-CONT-010 | Complete citations, official and unofficial reports where practicable; a copy of any cited unpublished opinion attached; a brief addresses only one motion (cross motions for summary judgment excepted). | L.B.R. 9013-2(d) | M (author) |
| PAMB-CONT-011 | A brief "if more than fifteen (15) pages in length, shall contain a table of contents, with page references, and table of citations of the cases, statutes and other authorities referred to therein, with references to the pages at which they are cited." | L.B.R. 9013-2(d) | M (conditional) |
| PAMB-CONT-012 | In an adversary proceeding, the moving party's brief contains a procedural history, a statement of facts, a statement of questions involved, and argument (district LR 7.8(a), applied by L.B.R. 7002-1). In a contested matter the L.B.R. sets no section list. | L.B.R. 7002-1; PAMD-LR 7.8(a) | M (adversary proceedings) |
| PAMB-CONT-013 | The motion's title identifies the filing party and the relief sought; each motion is accompanied by a proposed form of order (in an adversary proceeding, filed as an attachment to the motion); motions in adversary proceedings carry the full Form 416D caption and a descriptive title. These bind the motion, not the brief. | L.B.R. 9013-1(a)-(b); L.B.R. 7007-1(a), (e) | M (motion) |
| PAMB-CONT-014 | Body seen in EX-MULLEN: centered brief title naming the motion, "AND NOW COMES ..." opening, roman-numbered sections (I. Statement of Facts, II. Question Presented, III. Argument, IV. Conclusion), "/s/" signature, then a certificate of service. One filer: that filer's style. | EX-MULLEN | C (one filer) |

## Not verified

- L.B.F. 9004-1 (the contested-matter caption form) was not found on the court's forms pages in this pass; PAMB-CAP-002 cites the rule, not the form's layout.
- The court's CM/ECF Administrative Procedures (L.B.R. 5005-1) were not read; any PDF-specific requirement they set is not recorded.
- Each doc type has one filed exemplar. A second filer was searched for on 2026-10-17 (Internet Archive CDX index of CourtListener RECAP `gov.uscourts.pamb.*`: 5 archived files, none an adversary complaint or brief; web search; the Stretto claims-agent docket for *SpiriTrust Lutheran*, which requires a reCAPTCHA) without result; the CourtListener search API was throttled for the day. Recorded in `docs/box-blocked.md`.
