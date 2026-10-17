# Third Circuit briefs (opening, answering, reply): rules

Alias `ca3`. Scope: the principal brief of an appellant or petitioner (`opening-brief/`), the principal brief of an appellee or respondent (`answering-brief/`) and the appellant's reply brief (`reply-brief/`), filed by counsel through the court's CM/ECF system. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (FRAP amendment date) and whenever the court posts amended Local Appellate Rules or a new briefing notice on its "Brief and Appendix Information" page.

Access note: on 2026-10-17 `www.ca3.uscourts.gov` answered every request from this box with "Request Rejected" (a firewall page). The court's own files were therefore read from Internet Archive captures of the court's URLs; the capture URL is given for each. The archived LAR PDF has the same content digest (CDX `3J37QMXT6KANAD2RUVE7UDON25IEORJC`) in every capture from 2015 to 2025-03-06, and the court's "Brief and Appendix Information" page (capture of 2026-01-24) still links that file as "Local Rules (PDF)" and the 2023 amendment as "Recent Amendments to the Local Rules (PDF)".

## Sources

| Tag | Source | URL |
|---|---|---|
| LAR | Third Circuit Local Appellate Rules, 2011 edition ("3RD CIRCUIT LOCAL APPELLATE RULES August 1, 2011"), the current full text as linked by the court | https://www.ca3.uscourts.gov/sites/ca3/files/local_rules/2011_LAR_Final.pdf (read from https://web.archive.org/web/20250306044754/https://www.ca3.uscourts.gov/sites/ca3/files/local_rules/2011_LAR_Final.pdf) |
| LAR-2023 | "L.A.R. 26.0 and L.A.R. Misc. 113.3(c) Effective July 1, 2023" (the only amendment posted since 2011; deadline rule) | https://web.archive.org/web/20260822190041/https://www.ca3.uscourts.gov/sites/ca3/files/LAR%2026%20and%20Misc.%20LAR%20113%28c%29%20Effective%20July%201%202023.pdf |
| BAI | Court page "Brief and Appendix Information" (links LAR, LAR-2023, CHART, the copies order and the court's Word brief template) | https://web.archive.org/web/20260124154831/https://www.ca3.uscourts.gov/brief-and-appendix-information |
| CHART | "Requirements for Briefs" chart (court form, PDF created 2020-03-15) | https://web.archive.org/web/20251012171033/https://www.ca3.uscourts.gov/sites/ca3/files/chart%20of%20requirements%20for%20briefs.pdf |
| COPIES | Order "Reduced Number of Copies of Briefs Required" (April 29, 2013): 7 paper copies instead of 10 | https://web.archive.org/web/20260904131130/https://www.ca3.uscourts.gov/sites/ca3/files/briefs_fewer_order.pdf |
| QC | Notice "Quality Control Program for the Filing of Briefs on the Merits" (blast email of 2026-01-04; program live January 5, 2026) | https://web.archive.org/web/20260105070013/https://www.ca3.uscourts.gov/sites/ca3/files/BlastEmail_2026_01_04.pdf |
| FRAP | Federal Rules of Appellate Procedure 25, 26.1, 28, 32 (LII text) | https://www.law.cornell.edu/rules/frap/rule_32 , https://www.law.cornell.edu/rules/frap/rule_28 , https://www.law.cornell.edu/rules/frap/rule_26.1 , https://www.law.cornell.edu/rules/frap/rule_25 |
| EX-TRESSLAR | Opening brief, *Tresslar v. Greene*, No. 26-1367 (The Gold Law Firm) | `opening-brief/exemplars/` |
| EX-HARRIS-OB | Opening brief, *United States v. Harris*, No. 21-3031 (Federal Public Defender, W.D. Pa.) | `opening-brief/exemplars/` |
| EX-BINDER | Answering brief, *Binder v. Coldwell Banker*, No. 24-1997 (K&L Gates) | `answering-brief/exemplars/` |
| EX-HARRIS-AB | Answering brief for the United States, *United States v. Harris*, No. 21-3031 (USAO W.D. Pa. and DOJ Criminal Division) | `answering-brief/exemplars/` |
| EX-AFP | Reply brief, *Americans for Prosperity Foundation v. Albence*, No. 26-2469 (Baker & Hostetler) | `reply-brief/exemplars/` |
| EX-LACOSTA | Reply brief for the United States, *United States v. LaCosta-Franco*, No. 26-2028 (USAO E.D. Pa.) | `reply-brief/exemplars/` |

Kinds: **M** = mandated by a court rule (FRAP or Third Circuit L.A.R.). **C** = convention (taken from the exemplars or common practice; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **Three extra certificates.** Besides the FRAP 32(g) word count, the court requires (a) a certification that the electronic brief's text is identical to the paper copies and (b) that a virus detection program was run, naming its version, "in the same document" as the type-volume certificate (L.A.R. 31.1(c)); and (c) in each party's initial brief, a bar-membership certificate (L.A.R. 28.3(d)). Government attorneys are exempt from (c) by the court's "longstanding practice" (L.A.R. 28.3 committee comment); EX-HARRIS-AB omits it.
2. **Related-cases statement goes after the statement of issues** (L.A.R. 28.1(a)(2)), not at the end of the brief.
3. **Standard of review under its own heading** before the discussion of each issue (L.A.R. 28.1(b)); FRAP 28(a)(8)(B) allows it inside the discussion, the local rule does not.
4. **Paper copies are still required.** Seven paper copies within 5 days of the electronic filing (COPIES; CHART); cover colors therefore apply to the paper copies. The electronic brief is the official record copy (L.A.R. 31.1(b)(4)).
5. **Margins.** L.A.R. 32.1(b) allows 3/4 inch top and bottom, but FRAP 32(a)(4) requires one inch on all four sides and CHART says "1" margins". One inch on all sides satisfies both; the template uses it.
6. **Automated brief check since January 5, 2026.** The court's CM/ECF runs a quality-control program on Opening, Response and Reply briefs, flagging "Critical" and "Minor" deficiencies, and recommends its Word template (QC). The program's criteria are not published; section headings with extra text may be flagged.

## Requirements: all three brief types

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (FRAP 32(a)(1)-(6), L.A.R. 32.1, 32.2)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-FORM-001 | Every page 8 1/2 by 11 inches (612 x 792 pt). | FRAP 32(a)(4); CHART "8 1/2 x 11 opaque paper" | M |
| CA3-FORM-002 | Margins at least one inch on all four sides; page numbers may be placed in the margins, but no text may appear there. (L.A.R. 32.1(b): sides at least 1 inch, top and bottom at least 3/4 inch; FRAP is stricter and controls what the court must accept, FRAP 32(e).) | FRAP 32(a)(4); L.A.R. 32.1(b); CHART | M |
| CA3-FORM-003 | "The text must be double-spaced, but quotations more than two lines long may be indented and single-spaced. Headings and footnotes may be single-spaced." | FRAP 32(a)(4); CHART | M |
| CA3-FORM-004 | Typeface: "A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions. A proportionally spaced face must be 14-point or larger." (Monospaced alternative: not more than 10 1/2 characters per inch.) L.A.R. 32.1(c): "Briefs must comply with the provisions of FRAP 32(a)(5) and (6)." CHART: "Proportional (14 pt. with serifs)". No face is named. | FRAP 32(a)(5); L.A.R. 32.1(c); CHART | M |
| CA3-FORM-005 | "Footnotes must be printed in the same size type utilized in the text." | L.A.R. 32.2(a) | M |
| CA3-FORM-006 | Plain, roman style; italics or boldface for emphasis; case names italicized or underlined. | FRAP 32(a)(6) | M |
| CA3-FORM-007 | Face actually used (open choice, any 14 pt serif): Times New Roman (EX-TRESSLAR, EX-HARRIS-OB, EX-AFP), Century Schoolbook (EX-BINDER), Garamond (EX-HARRIS-AB), Georgia (EX-LACOSTA). No single convention; the template's face is a free choice within CA3-FORM-004. | exemplars | C |
| CA3-FORM-008 | Front matter after the cover numbered in lowercase roman numerals; body in Arabic numerals from 1; cover unnumbered. Seen in all six exemplars (EX-LACOSTA writes "-i-"). | exemplars | C |
| CA3-FORM-009 | Every font is embedded and is the template's declared family (no fallback to a system font). | project | T |

### Electronic filing and signature (L.A.R. 31.1, 32.1(d), 28.4, Misc. 113)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-ELEC-001 | The brief is filed electronically in PDF; "the entire brief must be contained in one electronic file." | L.A.R. 31.1(b)(1)-(2); L.A.R. 32.1(d) | M |
| CA3-ELEC-002 | "Documents created by the filer and filed electronically must be in PDF text format" (not scanned). Check: text extracts on every page. | L.A.R. Misc. 113.3(b); QC; CHART | M |
| CA3-ELEC-003 | Signature: "either an electronically generated signature or 's/ typed name'"; counsel's state bar number, if any, address and phone number are included with the signature. | L.A.R. 28.4; CHART ("s/ first name last name") | M |
| CA3-ELEC-004 | Redaction of personal identifiers (Social Security numbers to last four digits, minors' initials, etc.). | L.A.R. 32.1(e), Misc. 113.12; FRAP 25(a)(5) | A |
| CA3-ELEC-005 | The top margin carries no text: CM/ECF stamps "Case: ... Document: ... Page: ... Date Filed: ..." there (visible on EX-TRESSLAR, EX-HARRIS-OB, EX-BINDER, EX-HARRIS-AB, EX-AFP). Covered by CA3-FORM-002. | exemplars | C |
| CA3-ELEC-006 | Paper copies: 7 (original and 6) within 5 days of electronic filing; only 1 for redacted briefs. Not a template matter, but it is why the cover colors (CA3-COVER-007) and the identical-text certificate (CA3-CERT-002) exist. | COPIES; CHART; L.A.R. 31.1(a) | M (paper) |

### Cover (FRAP 32(a)(2); CHART "Content of Front Cover")

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-COVER-001 | The number of the case centered at the top. | FRAP 32(a)(2)(A); CHART 2.b | M |
| CA3-COVER-002 | The name of the court (United States Court of Appeals for the Third Circuit). | FRAP 32(a)(2)(B); CHART 2.a | M |
| CA3-COVER-003 | The title of the case (FRAP 12(a)); CHART: "Official Court Caption". | FRAP 32(a)(2)(C); CHART 2.c | M |
| CA3-COVER-004 | The nature of the proceeding and the name of the court, agency or board below. | FRAP 32(a)(2)(D); CHART 2.d | M |
| CA3-COVER-005 | The title of the brief, identifying the party or parties for whom it is filed. | FRAP 32(a)(2)(E); CHART 2.e | M |
| CA3-COVER-006 | The name, office address and telephone number of counsel for the filing party. | FRAP 32(a)(2)(F); CHART 2.f | M |
| CA3-COVER-007 | Cover color on the paper copies (unrepresented parties exempt): appellant blue, appellee red, reply gray (also: intervenor/amicus green, supplemental tan, cross-appeal third step yellow). Under a transparent cover, the underlying sheet must still conform. Not applicable to the electronic PDF. | FRAP 32(a)(2); L.A.R. 32.2(b); CHART 1 | M (paper only) |
| CA3-COVER-008 | District-court docket number and judge below shown on the cover. Seen in EX-HARRIS-OB ("at No. 2:19-cr-00313"), EX-HARRIS-AB ("No. 2:19-cr-00313 (Horan, J.)") and EX-LACOSTA; not required. | exemplars | C |
| CA3-COVER-009 | The cover occupies exactly one page. | all exemplars | C |

### Disclosure (FRAP 26.1; L.A.R. 26.1.1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-CONT-001 | A nongovernmental corporate party's FRAP 26.1 disclosure statement is "included before the table of contents in the principal brief." The court also requires its own disclosure form, filed promptly after the notice of appeal (L.A.R. 26.1.1(a)-(b)). Individuals and the government file none (EX-TRESSLAR, EX-HARRIS-OB, EX-HARRIS-AB have none; EX-BINDER has one at p. i). | FRAP 26.1(a), (d)(2); L.A.R. 26.1.1 | M (corporate parties) |

### Contents rules common to all briefs

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-CONT-002 | Table of contents with page references. | FRAP 28(a)(2), 28(b), 28(c); CHART "Tables" | M |
| CA3-CONT-003 | Table of authorities: cases alphabetically arranged, statutes and other authorities, with the pages where each is cited (CHART: "Table of Citations"). | FRAP 28(a)(3), 28(b), 28(c); CHART | M |
| CA3-CONT-004 | Citations to reported federal opinions are to U.S., F., F. Supp. or F.R.D., identifying the circuit or district and year; unreported decisions by court, docket number and date. Hyperlinks optional. | L.A.R. 28.3(a) | A |
| CA3-CONT-005 | Every assertion of fact is supported by a specific record reference; appendix cites are followed by a parenthetical description of the document unless clear from context. | L.A.R. 28.3(c); FRAP 28(e) | A |
| CA3-CONT-006 | Cite opposing authority that binds this court. | L.A.R. 28.3(b) | A |
| CA3-CONT-007 | No ad hominem attacks on opposing counsel or parties. | L.A.R. 28.1(d) | A |
| CA3-CONT-008 | Use parties' names or lower-court designations rather than "appellant"/"appellee". | FRAP 28(d) | A |

### Certificates (FRAP 32(g), 25(d); L.A.R. 28.3(d), 31.1(c)-(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-CERT-001 | Certificate of compliance with the type-volume limit, stating "the number of words" (counsel may rely on the word processor's count). Required whenever the brief relies on the word limit rather than the page limit; CHART: "A certification of word or line count must be included when a brief exceeds the required 30, 35 or 15 page limit." | FRAP 32(g)(1); FRAP 28(a)(10); CHART | M |
| CA3-CERT-002 | In the same document as the type-volume certificate, counsel certifies (a) that "the text of the electronic brief is identical to the text in the paper copies" and (b) that "a virus detection program has been run on the file and that no virus was detected", specifying "the version of the virus detection program used." | L.A.R. 31.1(c); CHART "Electronic Briefs" 4-5 | M |
| CA3-CERT-003 | "Each party must include a certification in the initial brief filed by that party ... that at least one of the attorneys whose names appear on the brief is a member of the bar of this court, or has filed an application for admission." Government attorneys are not required to be members (committee comment). | L.A.R. 28.3(d) | M (initial brief; non-government counsel) |
| CA3-CERT-004 | Certificate of service: FRAP 25(d) requires proof of service only for service made other than through the court's electronic-filing system; but L.A.R. 31.1(d) says "The certificate of service must note what method of service was used for each party served", and its committee comment says the CM/ECF notice "is not a substitute for a certificate of service." The template always emits one, naming the method. Every exemplar has one. | L.A.R. 31.1(d) and comment; FRAP 25(d); CHART "Combined Certifications" 3 | M |
| CA3-CERT-005 | Certificate layout is open: separate headed certificates each on its own page (EX-TRESSLAR, EX-BINDER), one "Certificates" section with sub-headings (EX-HARRIS-OB), or one numbered "Certification"/"Certificate of Compliance" (EX-LACOSTA, EX-HARRIS-AB). CHART calls them "Combined Certifications". Any of these is acceptable; the paragraph text is double-spaced in every exemplar. | exemplars; CHART | C |

## Doc type: opening-brief

Principal brief of the appellant or petitioner.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-LEN-001 | A principal brief may not exceed 30 pages, unless it contains no more than 13,000 words (or 1,300 lines of monospaced type). CHART: "Principal & Intervenor briefs – 30 pages / 13,000 words / 1,300 lines". | FRAP 32(a)(7)(A), (B)(i); CHART | M |
| CA3-LEN-002 | Excluded from the length: cover page, disclosure statement, table of contents, table of citations, statement regarding oral argument, addendum of statutes/rules/regulations, certificates of counsel, signature block, proof of service. Headings, footnotes and quotations count. Volume one of the appendix bound with the brief does not count (L.A.R. 32.2(c)). | FRAP 32(f); L.A.R. 32.2(c); CHART | M |
| CA3-CONT-010 | Required contents in this order: disclosure statement (if FRAP 26.1 applies); table of contents; table of authorities; jurisdictional statement (basis of district-court/agency jurisdiction; basis of appellate jurisdiction; filing dates showing timeliness; finality or other basis); statement of the issues; statement of related cases and proceedings; statement of the case (facts, procedural history, rulings presented for review, with record references); summary of the argument (not merely the headings); standard or scope of review; argument; short conclusion stating the precise relief sought; certificates. | FRAP 28(a)(1)-(10); L.A.R. 28.1(a)(2), (b) | M |
| CA3-CONT-011 | In the statement of issues, for each issue, "a designation by reference to specific pages of the appendix or place in the proceedings at which each issue on appeal was raised, objected to, and ruled upon." | L.A.R. 28.1(a)(1) | M (author supplies the cites) |
| CA3-CONT-012 | After the statement of issues, a statement of related cases and proceedings: whether the case has been before this court previously, and whether the party is aware of any related case or proceeding, completed, pending or about to be presented, before any court or agency; previous or pending appeals arising from the same case are identified. | L.A.R. 28.1(a)(2) | M |
| CA3-CONT-013 | The standard or scope of review for each issue under a separate heading placed before the discussion of the issue. | L.A.R. 28.1(b) | M |
| CA3-CONT-014 | Volume one of the appendix (notice of appeal; order or judgment appealed and related orders; relevant opinions; any certificate of appealability) may be bound with the paper brief, and may be attached to the electronic brief; it does not count toward length. Both appellant exemplars bind Volume I after the brief (EX-TRESSLAR "Joint Appendix Volume I"; EX-HARRIS-OB "Appendix Volume I, Appx1-9"). | L.A.R. 32.2(c); L.A.R. 28.1(c); CHART "Attachments to Briefs" | M (content of Vol. I); C (binding it in) |
| CA3-CONT-015 | Relevant statutes, rules or regulations set out in the brief or in an addendum at the end when the issues require their study. | FRAP 28(f) | A |
| CA3-CERT-010 | Certificates required in the opening brief: CA3-CERT-001 (word count), CA3-CERT-002 (identical text, virus check with version), CA3-CERT-003 (bar membership, as the appellant's initial brief), CA3-CERT-004 (service). | as cited | M |
| CA3-COVER-010 | Paper cover blue. | FRAP 32(a)(2); CHART | M (paper only) |

## Doc type: answering-brief

Principal brief of the appellee or respondent.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-LEN-020 | Principal brief limit, as CA3-LEN-001: 30 pages, or 13,000 words. Exclusions as CA3-LEN-002. (A cross-appellant's second-step brief: 35 pages or 15,300 words, FRAP 28.1(e); CHART.) | FRAP 32(a)(7); FRAP 32(f); CHART | M |
| CA3-CONT-020 | Contents: those of FRAP 28(a)(1)-(8) and (10) (disclosure, TOC, TOA, jurisdictional statement, issues, statement of the case, summary, argument with standard of review, certificate), except that the jurisdictional statement, statement of the issues, statement of the case and statement of the standard of review "need not appear unless the appellee is dissatisfied with the appellant's statement." No conclusion is listed in FRAP 28(b), but both exemplars have one. | FRAP 28(b); CHART "*Optional in Appellee/Respondent brief" | M; C (conclusion) |
| CA3-CONT-021 | The appellee's brief "must conform to ... 3d Cir. L.A.R. 28.1 (a)(2), (b) and (c)": a statement of related cases after the issues, and a separate standard-of-review heading before the discussion. A cross-appellant also complies with 28.1(a)(1) (issue preservation cites). An appellee filing one brief in consolidated appeals adds a cross-reference index to the appellants' contentions. | L.A.R. 28.2 | M |
| CA3-CONT-022 | Seen in both exemplars: the appellee states jurisdiction, issues and the case anyway (EX-BINDER, EX-HARRIS-AB); EX-HARRIS-AB also states related cases. | exemplars | C |
| CA3-CERT-020 | Certificates: CA3-CERT-001, CA3-CERT-002, CA3-CERT-004; CA3-CERT-003 (bar membership) when this is the appellee's first brief and counsel is not government counsel (EX-BINDER has it; EX-HARRIS-AB, government, does not). | L.A.R. 28.3(d), 31.1(c)-(d); FRAP 32(g) | M |
| CA3-COVER-020 | Paper cover red. | FRAP 32(a)(2); CHART | M (paper only) |

## Doc type: reply-brief

The appellant's reply to the appellee's brief.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA3-LEN-030 | A reply brief may not exceed 15 pages, unless it contains no more than half the principal type volume: 6,500 words (or 650 monospaced lines). CHART: "Reply & Amicus briefs – 15 pages / 6,500 words / 650 lines". Exclusions as CA3-LEN-002. | FRAP 32(a)(7)(A), (B)(ii); FRAP 32(f); CHART | M |
| CA3-CONT-030 | "A reply brief must contain a table of contents, with page references, and a table of authorities—cases (alphabetically arranged), statutes, and other authorities—with references to the pages of the reply brief where they are cited." No other section is mandated. | FRAP 28(c) | M |
| CA3-CONT-031 | Body is an Argument section followed by a Conclusion (EX-AFP, EX-LACOSTA); neither repeats jurisdiction, issues or the case statement. | exemplars | C |
| CA3-CERT-030 | Certificates: CA3-CERT-001 (word count under FRAP 32(a)(7)(B)(ii)), CA3-CERT-002 (identical text and virus check, "in the same document"), CA3-CERT-004 (service). The bar-membership certificate (L.A.R. 28.3(d)) is required only "in the initial brief filed by that party", so not in a reply. | FRAP 32(g)(1); L.A.R. 31.1(c)-(d), 28.3(d) | M |
| CA3-COVER-030 | Paper cover gray. | FRAP 32(a)(2); CHART | M (paper only) |

## Not verified

- The criteria applied by the court's 2026 quality-control program (QC) and the content of the court's Word brief template (BAI links it at `https://ca03portal.powerappsportals.us/Brief-Template/`, not fetched). A template that passes FRAP and the L.A.R. may still be flagged "Minor".
- Whether a statement regarding oral argument belongs in the brief: neither the CHART nor L.A.R. 28 requires one (L.A.R. 34.1 on argument was not read in this pass), and none of the six exemplars has one. The template omits it.
- The live court site was unreachable from this box; every L.A.R. citation is to the archived copy of the court's own file (see Access note).
