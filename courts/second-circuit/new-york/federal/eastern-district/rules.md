# U.S. District Court for the Eastern District of New York: rules

Alias `nyed`. Scope: civil papers filed by counsel through CM/ECF in the Eastern District of New York; doc types `complaint` (initial complaint) and `motion-brief` (memorandum of law in support of a motion, here a Fed. R. Civ. P. 12(b) motion to dismiss). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (federal rule amendments take effect then) and whenever the court posts amended Joint Local Rules. The courts' July 1, 2026 Joint Notice proposes amendments (comment period closed September 29, 2026), including a change to how LCR 6.3 and 7.1 compute word limits when the judge sets a page limit; re-read LCR 7.1(c) when the amended rules are adopted.

## Sources

| Tag | Source (rule / version / effective date) | URL |
|---|---|---|
| LCR | Local Rules of the United States District Courts for the Southern and Eastern Districts of New York (Joint Local Rules), "As Amended", effective January 2, 2026 (PDF created 2025-12-15; sha256 439b9e2c67fd4ca1d1be65a7f28ca53707820bcbabb4b459323ade1a773607af). Page numbers below are the printed page numbers of the rules. | https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf |
| NOTICE | Joint Notice to the Bar, July 1, 2026: proposed amendments to the Joint Local Rules (not in effect; confirms the January 2, 2026 rules are current). Linked from the EDNY home page. | https://www.nyed.uscourts.gov/sites/default/files/uploads/joint%20notice%20to%20bar%202026%20amendments%2020260701.pdf |
| ECF-GUIDE | EDNY "NextGen CM/ECF User's Guide", March 2024 (PDF modified 2024-03-26), linked from the court's CM/ECF page https://www.nyed.uscourts.gov/cmecf-nextgen-information | https://www.nyed.uscourts.gov/sites/default/files/uploads/ecf-usermanual.pdf |
| CASE-OPEN | EDNY "CM/ECF Electronic New Civil Case Opening Manual" (cover date 05/09/2018; PDF modified 2026-05-15), linked from the same page | https://www.nyed.uscourts.gov/sites/default/files/uploads/caseopeningmanual.pdf |
| PRINT-PDF | EDNY "Printing to PDF" instructions (PDF dated 2021-06-24), linked from the same page | https://www.nyed.uscourts.gov/sites/default/files/uploads/print%20to%20pdf.pdf |
| FRCP | Federal Rules of Civil Procedure, Rules 5, 5.2, 7, 7.1, 8, 10, 11, 12, 38 (current text) | https://www.law.cornell.edu/rules/frcp/rule_5 , .../rule_5.2 , .../rule_7 , .../rule_7.1 , .../rule_8 , .../rule_10 , .../rule_11 , .../rule_12 , .../rule_38 |
| EX-C1 | Complaint exemplar 1: Blade v. GameStop Inc., No. 1:26-cv-06563, ECF 1 (Robert Wisniewski P.C. for plaintiff) | `complaint/usage/SOURCE.md` |
| EX-C2 | Complaint exemplar 2: Forsythe v. Carerite Centers LLC, No. 2:26-cv-06559, ECF 1 (Romero Law Group PLLC for plaintiff) | `complaint/usage/SOURCE.md` |
| EX-C3 | Complaint exemplar 3: Mejia v. Hamide NYC Inc, No. 1:26-cv-06581, ECF 1 (Joseph & Kirschenbaum LLP for plaintiff) | `complaint/usage/SOURCE.md` |
| EX-M1 | Memorandum exemplar 1: Force v. Qatar Charity, No. 1:20-cv-02578 (BMC), ECF 56-1 (Ropes & Gray LLP for defendant Qatar National Bank) | `motion-brief/usage/SOURCE.md` |
| EX-M2 | Memorandum exemplar 2: Saldarriaga v. Coffin, No. 1:20-cv-03529 (RPK)(JRC), ECF 19 (Office of the Attorney General of Florida, William E. Chorba, for defendant Ann Coffin) | `motion-brief/usage/SOURCE.md` |

Kinds: **M** = mandated by a court rule (FRCP, Joint Local Rule, or the court's published ECF instructions). **C** = convention (the rules leave it open; taken from the exemplars, with the filers that show it). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **No typeface is named.** LCR 7.1(b) governs "[t]he typeface, margins, and spacing of all documents presented for filing", but its only type rule is size: "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type". The face is open (C). All five exemplars use Times New Roman; that is the filers' common choice, not a rule.
2. **LCR 7.1(b) reaches complaints.** Its heading is "Formatting Requirements for All Papers" and its text says "all documents presented for filing", so the size, margin and spacing rules apply to the complaint as well as to the memorandum. LCR 11.1 (form of pleadings) is "[Withdrawn]".
3. **Double spacing exceptions are only three.** LCR 7.1(b)(3): "all text must be double-spaced, except for headings, text in footnotes, or block quotations, which may be single-spaced." Captions, counsel blocks, signature blocks, tables of contents and tables of authorities are not in the list. Every exemplar single-spaces its caption, signature block and tables (EX-C1 to C3, EX-M1, EX-M2). Whether the rule reaches those blocks is an open reading question (recorded under NYED-FORM-004; not decided here).
4. **Word limit, not page limit, for memoranda.** LCR 7.1(c): 8,750 words (opening and opposition), 3,500 words (reply), with a mandatory word-count certificate. Both memorandum exemplars predate this rule and carry no certificate.
5. **No certificate of service when served through ECF.** FRCP 5(d)(1)(B): "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." EX-M1 includes one anyway; EX-M2 does not.
6. **EDNY PDF size cap is 40 MB** (ECF-GUIDE), not the 100 MB some courts allow.

## Court-wide requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Form (all papers)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYED-FORM-001 | Type size: "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type". Applies to "all documents presented for filing". | LCR 7.1(b)(1), p. 20 | M |
| NYED-FORM-002 | Margins: "all documents must have at least one-inch margins on all sides". | LCR 7.1(b)(2), p. 21 | M |
| NYED-FORM-003 | Spacing: "all text must be double-spaced, except for headings, text in footnotes, or block quotations, which may be single-spaced." Operational definition for checks: body-paragraph baseline pitch at least twice the type size (24 pt at 12 pt). | LCR 7.1(b)(3), p. 21 | M |
| NYED-FORM-004 | Caption, counsel block, signature block, TOC and TOA single-spaced. The rule does not list them as exceptions (Finding 3); all five exemplars single-space them. Open reading question for the maintainer; until decided, treat as convention. | EX-C1, EX-C2, EX-C3, EX-M1, EX-M2 | C |
| NYED-FORM-005 | Typeface: none named by rule (Finding 1). Any proportional serif face at 12 pt or larger meets the rule. All five exemplars are set in Times New Roman (a convention shared across filers, not a requirement). | LCR 7.1(b) (silent on face); EX-C1 to C3, EX-M1, EX-M2 | C |
| NYED-FORM-006 | Page size 8 1/2 x 11 inch. Not stated in the Joint Local Rules or the ECF guide; every exemplar is US Letter (612 x 792 pt). | EX-C1 to C3, EX-M1, EX-M2 | C |
| NYED-FORM-007 | Pages numbered at the foot, centered, arabic (front matter of a memorandum in lowercase roman). No rule requires page numbers; all exemplars show them. | EX-C1 to C3, EX-M1, EX-M2 | C |
| NYED-FORM-008 | Top margin left clear of text: the court's ECF stamp ("Case ... Document ... Filed ... Page ... PageID") is applied in the top margin of every page. Covered by NYED-FORM-002. | EX-C1 to C3, EX-M1, EX-M2 | C |
| NYED-FORM-009 | Every font used is embedded and is the template's declared family (no system-font fallback). | project | T |

### Caption and signature (all papers)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYED-CAP-001 | Caption with the court's name, a title, a file (docket) number, and a Rule 7(a) designation. For a complaint, the title names all the parties. Motions and other papers follow the same caption rules ("The rules governing captions and other matters of form in pleadings apply to motions and other papers"). | FRCP 10(a); FRCP 7(b)(2) | M |
| NYED-CAP-002 | The new case number is added to the caption of every document filed at case opening (the case number is assigned during the electronic opening). | CASE-OPEN §III.G, p. 22 | M |
| NYED-CAP-003 | Caption layout: court name in capitals ("UNITED STATES DISTRICT COURT / EASTERN DISTRICT OF NEW YORK") above a party block closed by rules (dashed "---X" rule in EX-C1, EX-C2, EX-C3; solid rule and "/" in EX-M2; no rule in EX-M1), designations ("Plaintiff," / "Defendant(s).") under each side, docket number at right. "-against-" (EX-C1, EX-C2) or "v." (EX-C3, EX-M1, EX-M2) between the sides: both are convention. | EX-C1 to C3, EX-M1, EX-M2 | C |
| NYED-CAP-004 | Signature: every paper signed by at least one attorney of record in the attorney's name; it states the signer's address, e-mail address and telephone number. | FRCP 11(a) | M |
| NYED-CAP-005 | Electronic signature: a filing made through the attorney's ECF account and authorized by that person, together with the person's name on a signature block, is the signature ("/s/ Name" in the block). | FRCP 5(d)(3)(C); ECF-GUIDE p. 4 and p. 8 | M |
| NYED-CAP-006 | Signature-block layout: "Dated:" with city and date at left; firm name, "By: /s/ Name", typed name, address, telephone, e-mail and "Attorneys for ..." at right. Seen in EX-C1, EX-C2, EX-C3; EX-M2 uses "Respectfully submitted," and the office name at right. | EX-C1 to C3, EX-M1, EX-M2 | C |

### Electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYED-ELEC-001 | Counsel must serve and file papers following the court's published ECF instructions, unless exempted. | LCR 5.2, p. 17; LCR 6.1(c), p. 18 | M |
| NYED-ELEC-002 | Only PDF documents may be filed electronically. A document created in a word processor must be converted ("printed") to PDF, not printed, signed and scanned. Check: text extracts on every page; fonts embedded. | ECF-GUIDE p. 4, p. 5 and p. 8; PRINT-PDF | M |
| NYED-ELEC-003 | A scanned PDF (only where scanning is unavoidable, e.g. exhibits) must be text-searchable (OCR). | ECF-GUIDE p. 8 | M |
| NYED-ELEC-004 | File size: "The current limit for a PDF to be uploaded is 40 megabytes." Larger documents are divided into parts. | ECF-GUIDE p. 6 | M |
| NYED-ELEC-005 | A PDF whose internal formatting CM/ECF cannot process "will not be accepted"; the court's fix is to re-print it to PDF. The template's PDF must upload as generated (plain PDF, no forms, no JavaScript, no attachments). | PRINT-PDF p. 1 | M |
| NYED-ELEC-006 | Redaction: only the last four digits of social-security, taxpayer-identification and financial-account numbers; only the year of birth; only a minor's initials. | FRCP 5.2(a) | A |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYED-CONT-001 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction or occurrence in a separate count where that promotes clarity. | FRCP 10(b) | M |
| NYED-CONT-002 | A short and plain statement of the grounds for jurisdiction; a short and plain statement of the claim; a demand for the relief sought. | FRCP 8(a) | A |
| NYED-CONT-003 | Caption title names all the parties (not "et al."). | FRCP 10(a) | M |
| NYED-CONT-004 | Jury demand (optional): a written demand, which may be included in the pleading, served no later than 14 days after the last pleading directed to the issue. | FRCP 38(b) | A |
| NYED-CONT-005 | Signed by counsel with address, e-mail and telephone (NYED-CAP-004, -005). | FRCP 11(a); FRCP 5(d)(3)(C) | M |
| NYED-CONT-006 | Filed separately with the complaint, not part of this document: the EDNY civil cover sheet (JS 44-45), filed as Attachment 1 to the complaint at electronic case opening; proposed summons as Attachment 2; the FRCP 7.1 disclosure statement where required (and its supplement within 14 days of a change, LCR 7.1.1). | CASE-OPEN §I.B, p. 1, and §III.G, pp. 22 to 24; FRCP 7.1(a)-(b); LCR 7.1.1, p. 22 | M (separate filings; not generated by the template) |
| NYED-CONT-007 | Section order seen across filers: caption; unnumbered introductory paragraph ("Plaintiff ..., by ... attorneys, ... alleges as follows"); centered bold capital headings (NATURE OF THE ACTION / JURISDICTION AND VENUE / PARTIES / FACTS / claims); prayer introduced by an unnumbered "WHEREFORE" paragraph with lettered or numbered items; date and signature block. | EX-C1, EX-C2, EX-C3 | C |
| NYED-CONT-008 | Numbered paragraph style: number indented 0.5 inch, text after a tab, continuation lines at the left margin, double-spaced. | EX-C1, EX-C2, EX-C3 | C |
| NYED-COVER-001 | Jury demand shown in the caption at right ("JURY TRIAL DEMANDED", "Jury Trial Demanded", "DEMAND FOR JURY TRIAL"). EX-C3 also repeats it as a separate "DEMAND FOR JURY TRIAL" section after the signature (that filer's style). | EX-C1, EX-C2, EX-C3 | C |
| NYED-COVER-002 | Document title "COMPLAINT": centered below the caption (EX-C1) or at right inside the caption block (EX-C2, EX-C3). Both are convention. | EX-C1, EX-C2, EX-C3 | C |
| NYED-COVER-003 | Counsel block (firm, address, telephone, "Attorneys for Plaintiff") at the top left of page 1, above the court name: EX-C1 and EX-C3; EX-C2 has none. Optional. | EX-C1, EX-C3 | C |
| NYED-LEN-001 | No length limit for a complaint in the Joint Local Rules. | LCR (none found) | M (no limit) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYED-CONT-101 | A motion includes (1) a notice of motion specifying the rules or statutes under which it is brought and the relief sought; (2) a memorandum of law; (3) supporting affidavits and exhibits. The notice and affidavits are separate papers, not part of this document. | LCR 7.1(a)(1)-(3), p. 20 | M (memorandum); separate filings otherwise |
| NYED-CONT-102 | The memorandum of law sets forth "the cases and other authorities relied on in support of the motion" and is "divided, under appropriate headings, into as many parts as there are issues to be determined". | LCR 7.1(a)(2), p. 20 | M |
| NYED-CONT-103 | Oppositions and replies follow LCR 7.1(a)(2) and (3); an opposing party seeking relief beyond denial also files a notice of motion. | LCR 7.1(a)(4), p. 20 | M |
| NYED-CONT-104 | Defenses that may be raised by motion: FRCP 12(b)(1)-(7). Content the author cites. | FRCP 12(b) | A |
| NYED-CONT-105 | Caption per NYED-CAP-001 (FRCP 7(b)(2) applies the pleading caption rules to motions and other papers). | FRCP 7(b)(2); FRCP 10(a) | M |
| NYED-CONT-106 | Cover page carrying the caption and the memorandum's title identifying the filing party and the motion; table of contents with dot leaders; table of authorities; front matter numbered in roman, body from arabic 1; top-level headings (PRELIMINARY STATEMENT / ARGUMENT / CONCLUSION) centered; Argument points numbered I., II., then A., B., then 1., 2. Shown by both filers. No rule requires a TOC or TOA (LCR 7.1(c) only excludes them from the count). | EX-M1, EX-M2 | C |
| NYED-CONT-107 | Counsel block at the foot of the cover page: EX-M1 only (that filer's style). Optional "Oral Argument Requested" legend in the caption: EX-M1 only. | EX-M1 | C (one filer) |
| NYED-CONT-108 | Pro se opponent: counsel must give the pro se litigant copies of unpublished or database-only authorities cited (LCR 7.2); a represented party moving to dismiss a pro se party's claims on matters outside the pleadings must serve and file the LCR 12.1 notice with the full text of FRCP 56. | LCR 7.2, p. 22; LCR 12.1, pp. 22 to 23 | A |
| NYED-LEN-101 | If filed by an attorney or prepared with a computer, briefs in support of and in response to a motion (except motions for reconsideration) "may not exceed 8,750 words"; reply briefs "may not exceed 3,500 words". | LCR 7.1(c), p. 21 | M |
| NYED-LEN-102 | Excluded from the count: "the caption, any index, table of contents, table of authorities, signature blocks, or any required certificates". Included: "material contained in footnotes or endnotes". | LCR 7.1(c), p. 21 | M |
| NYED-LEN-103 | Pro se, handwritten or typewritten: 25 pages (support, opposition), 10 pages (reply). Not the template's case. | LCR 7.1(c), p. 21 | M (not applicable to the template) |
| NYED-LEN-104 | If the court permits a longer brief and expresses the limit in pages, "each additional page must not contain more than 350 additional words". (A proposed amendment, NOTICE item 3, would clarify this computation; not in effect.) | LCR 7.1(c), p. 21; NOTICE | M |
| NYED-LEN-105 | Motion for reconsideration: notice served within 14 days; the memorandum "may not exceed 3,500 words", reply 1,750 words, same exclusions, and the LCR 7.1(c) certificate is required. | LCR 6.3, p. 19 | M |
| NYED-LEN-106 | These limits apply "[u]nless ... otherwise directed by the court"; a judge's individual practices or order may change them (not retrieved; see Not verified). | LCR 7.1, lead-in, p. 20 | A |
| NYED-CERT-101 | A brief filed by an attorney or prepared with a computer "must include a certificate by the attorney ... that the document complies with the word-count limitations". "The certificate must state the number of words in the document." The preparer "may rely on the word count of the word-processing program used to prepare the document." | LCR 7.1(c), p. 21 | M |
| NYED-CERT-102 | The word count stated in the certificate equals the actual count of counted words (NYED-LEN-102) and is at most the limit (NYED-LEN-101). | LCR 7.1(c), p. 21 | M |
| NYED-CERT-103 | Certificate of service: not required when the paper is served by filing it through ECF; required for service by other means. Optional in the template. EX-M1 includes one on its own page; EX-M2 does not. | FRCP 5(d)(1)(B); ECF-GUIDE p. 6 (NEF constitutes service on Filing and Receiving Users) | M (conditional) |
| NYED-CERT-104 | Service timing on motions (not form): opposition 14 days after service of the moving papers, reply 7 days after (non-discovery motions). | LCR 6.1(b), p. 18 | A |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| NYED-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| NYED-TOOL-002 | No case-specific text and no coordinates measured off a filed PDF in any template. | T |
| NYED-TOOL-003 | TOC and TOA page numbers equal the pages where the headings and citations really are (motion-brief). | T |

## Not verified

- **Individual practices of EDNY judges.** Many EDNY judges' individual rules add pre-motion conference requirements, page or word limits, courtesy-copy rules and sometimes font or spacing rules. None were retrieved; the template applies only the Joint Local Rules. Not asserted as M.
- **EDNY Administrative Order 2004-08** (mandatory electronic filing), cited by the court's 2017 notice https://www.nyed.uscourts.gov/sites/default/files/uploads/mandatoryecffiling.pdf, was not fetched. That 2017 notice also says initiating documents "will continue to be filed in hard copy", which conflicts with CASE-OPEN (PDF modified 2026-05-15), under which attorneys open civil cases and file the complaint electronically. This file follows CASE-OPEN, the newer document; the conflict is not otherwise resolved.
- **Page size.** No EDNY rule or ECF instruction read here states 8 1/2 x 11; recorded as C (NYED-FORM-006).
- **PDF bookmarks, PDF/A, or a font-embedding rule.** None stated in ECF-GUIDE or PRINT-PDF. Embedding is checked as a project rule (NYED-FORM-009) supporting NYED-ELEC-002.
- The EDNY "Local Rules" page path cited in NOTICE (https://www.nyed.uscourts.gov/local-rules-documents-and-administrative-orders) returned HTTP 404 on 2026-10-17; the Joint Local Rules PDF was read from the S.D.N.Y. copy (same joint rules; the PDF metadata names both districts' Boards of Judges).
