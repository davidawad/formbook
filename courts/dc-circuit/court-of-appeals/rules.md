# D.C. Circuit Court of Appeals briefs: rules

Alias `cadc`. Scope: the principal brief of an appellant or petitioner (`opening-brief`), the principal brief of an appellee or respondent (`answering-brief`) and the reply brief (`reply-brief`), filed by counsel through CM/ECF in the United States Court of Appeals for the District of Columbia Circuit. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (FRAP amendment date) and whenever the court posts amended Circuit Rules or a revised Handbook (https://www.cadc.uscourts.gov/circuit-rules-procedures; the Handbook was last revised September 17, 2026).

## Sources

The rules PDF has no printed page numbers; rows cite rule numbers. Handbook rows cite the Handbook's printed page.

| Tag | Source | URL |
|---|---|---|
| CR | "Circuit Rules of the United States Court of Appeals for the District of Columbia Circuit (Together with the corresponding Federal Rules of Appellate Procedure)", Circuit Rules "As Amended Through December 4, 2025", Federal Rules "As Amended Through December 1, 2025" (194 pp.; read 2026-10-17). Contains the text of FRAP 25, 26.1, 28, 28.1, 32 and Circuit Rules 25, 26.1, 28, 31, 32, 32.1. Circuit Rule 28(a)(7) appears as amended by the en banc order of July 11, 2025 (effective August 11, 2025). | https://www.cadc.uscourts.gov/sites/cadc/files/rules-RulesFRAP20251204.pdf |
| HB | "Handbook of Practice and Internal Procedures", "As Amended Through September 17, 2026", Part IX.A (briefs), pp. 39-43. Guidance only (Preface), but it states the court's typeface preference. | https://www.cadc.uscourts.gov/sites/cadc/files/rules-Handbook20260917.pdf |
| ORD-28A7 | En banc order of July 11, 2025 amending Circuit Rule 28(a)(7) (Standing), effective August 11, 2025 | https://www.cadc.uscourts.gov/sites/cadc/files/orderCircRule28a7.pdf |
| FRAP | Federal Rules of Appellate Procedure 28, 32 (cross-check of the CR text) | https://www.law.cornell.edu/rules/frap/rule_32 and https://www.law.cornell.edu/rules/frap/rule_28 |
| EX | The filed exemplars in each doc type's `usage/` (see `SOURCE.md` there). Visual reference only. | local |

Kinds: **M** = mandated by a court rule (FRAP or D.C. Circuit Rule). **C** = convention (seen in exemplars from different filers, or stated by the Handbook as a preference; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **Certificate as to Parties, Rulings, and Related Cases** immediately inside the cover, before the TOC, with paragraphs A (parties and amici, with the Circuit Rule 26.1 disclosure), B (rulings under review), C (related cases), in that order (Circuit Rule 28(a)(1)). It replaces a free-standing disclosure statement in the brief and is excluded from the word count (Circuit Rule 32(e)(1)).
2. **No "passim"** in the table of authorities or in any citation (Circuit Rule 28(a)(2), 28(b)).
3. **Glossary** of every non-common abbreviation, on a page immediately after the TOA (Circuit Rule 28(a)(3)); excluded from the count.
4. **Oral-argument legend** in capital letters at the top of the cover when the case is scheduled, argued, or submitted without argument, with the argument date (Circuit Rule 28(a)(8)).
5. **Summary of argument in every brief, including the reply**, immediately before the argument (or before the Standing section) (Circuit Rule 28(a)(6)).
6. **Typeface preference**: the Handbook encourages Century and Times New Roman and discourages Garamond (HB p. 40). The rule itself (FRAP 32(a)(5)(A)) only requires a serif face, 14-point or larger.
7. **Paper copies of briefs are required** in addition to the electronic filing (Circuit Rule 32(d)(3); original and 8 copies, Circuit Rule 31(b)), so FRAP 32(a)(2) cover colors apply to the paper copies. Initial briefs under the deferred-appendix method are electronic only.

## Court-wide requirements (all three doc types)

### Page form (FRAP 32(a)(1), (4) to (6); Circuit Rule 32(e))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-FORM-001 | Every page is 8 1/2 by 11 inch. | FRAP 32(a)(4) (CR); Circuit Rule 32(e) | M |
| CADC-FORM-002 | Margins at least one inch on all four sides; page numbers may be in the margins, but no text may appear there. | FRAP 32(a)(4) (CR) | M |
| CADC-FORM-003 | Text double-spaced; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced. | FRAP 32(a)(4) (CR); HB p. 40 | M |
| CADC-FORM-004 | Typeface: "A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions. A proportionally spaced face must be 14-point or larger." (Or monospaced, no more than 10 1/2 characters per inch.) No footnote exemption is stated; the checks apply 14 pt to footnotes. | FRAP 32(a)(5) (CR); HB p. 40 | M |
| CADC-FORM-005 | Plain, roman style; italics or boldface may be used for emphasis; case names italicized or underlined. | FRAP 32(a)(6) (CR); HB p. 40 | M |
| CADC-FORM-006 | Face choice: "Certain typefaces can be easier to read, such as Century and Times New Roman. The Court encourages the use of these typefaces. Briefs that use Garamond as the typeface can be more difficult to read and the use of this typeface is discouraged." Exemplars: Century Schoolbook (Centro/Public Citizen; Wilson/U.S. Attorney; New York/NY Attorney General), Times New Roman (Rosen-Kellogg/Swick & Shapiro; Kidane/EFF-Robins Kaplan), Georgia (Hegseth/DOJ Civil Division). The template should use a Century-like or Times-like face, not Garamond. | HB p. 40; EX | C (court-stated preference) |
| CADC-FORM-007 | Every font used is embedded and is the template's declared family. | project | T |
| CADC-FORM-008 | Page numbering: cover unnumbered; front matter (certificate, TOC, TOA, glossary) in lowercase roman numerals; body from Arabic 1, centered at the foot. Seen in Centro, Hegseth, Wilson, Rosen-Kellogg and Kidane (New York not checked page by page). | EX | C |
| CADC-FORM-009 | Briefs double-spaced and printed on one side only; clear black image on light paper. | FRAP 32(a)(1) (CR); HB p. 40 | M |

### Cover (FRAP 32(a)(2); Circuit Rule 28(a)(8))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-COVER-001 | The number of the case centered at the top. | FRAP 32(a)(2)(A) (CR) | M |
| CADC-COVER-002 | The name of the court. | FRAP 32(a)(2)(B) (CR) | M |
| CADC-COVER-003 | The title of the case (FRAP 12(a)); in a consolidated appeal, the docket number and caption of the lead case. | FRAP 32(a)(2)(C) (CR); HB p. 40 | M |
| CADC-COVER-004 | The nature of the proceeding and the name of the court, agency, or board below (e.g., "Appeal from the United States District Court for the District of Columbia"). | FRAP 32(a)(2)(D) (CR); HB p. 40 | M |
| CADC-COVER-005 | The title of the brief, identifying the party or parties for whom it is filed. | FRAP 32(a)(2)(E) (CR) | M |
| CADC-COVER-006 | The name, office address, and telephone number of counsel; the Handbook adds e-mail addresses for electronic filers. One attorney on the cover must be a member of the bar of the Court. | FRAP 32(a)(2)(F) (CR); HB p. 40 | M (name, address, telephone); C (e-mail, HB guidance) |
| CADC-COVER-007 | If the case has been scheduled for oral argument, has been argued, or is being submitted without oral argument, the brief so states in capital letters at the top of the front cover, with the argument date where applicable. Centro and Wilson print "ORAL ARGUMENT NOT YET SCHEDULED"; Hegseth prints "[ORAL ARGUMENT SCHEDULED FOR MAY 7, 2026]". | Circuit Rule 28(a)(8) (CR); HB p. 40; EX | M |
| CADC-COVER-008 | Cases designated "Complex" show that designation on the cover; cases considered under Circuit Rule 34(j) show "Case being considered for treatment pursuant to Rule 34(j)". | HB p. 40 | C (HB guidance; conditional) |
| CADC-COVER-009 | Cover color on the required paper copies: appellant blue, appellee red, reply gray (not for unrepresented IFP parties). Not applicable to the electronic PDF. | FRAP 32(a)(2) (CR); Circuit Rule 32(d)(3); HB p. 40 | M (paper only) |

### Front matter and contents (Circuit Rule 28(a); FRAP 28)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-CONT-001 | Certificate titled "Certificate as to Parties, Rulings, and Related Cases", immediately inside the cover and before the table of contents, with separate headed paragraphs in this order: (A) Parties and Amici (appellant lists all parties, intervenors and amici below and here; others may incorporate by the stated formula) including the Circuit Rule 26.1 disclosure for any entity party (government in a criminal case: FRAP 26.1(b)); (B) Rulings Under Review (date, judge, appendix page, official citation or a statement that none exists; may incorporate by the stated formula); (C) Related Cases (prior proceedings and pending related cases, or a statement that there are none). | Circuit Rule 28(a)(1)(A)-(C) (CR); Circuit Rule 26.1 (CR); HB pp. 41-42 | M |
| CADC-CONT-002 | Table of contents with page references. | FRAP 28(a)(2), (c) (CR); HB p. 42 | M |
| CADC-CONT-003 | Table of authorities: cases (alphabetical), statutes, other authorities, with each page of the brief on which each is cited; "passim or similar terms may not be used". Optional asterisks in the left margin for principal authorities, with the note "Authorities upon which we chiefly rely are marked with asterisks." at the bottom of the TOA's first page. | FRAP 28(a)(3), (c) (CR); Circuit Rule 28(a)(2) (CR); HB p. 42 | M (pages, no passim); M (conditional) asterisk note |
| CADC-CONT-004 | Glossary defining each abbreviation (including acronyms) not in common usage, on a page immediately following the TOA. Required whenever the brief uses such abbreviations. | Circuit Rule 28(a)(3) (CR); HB p. 42 | M (conditional) |
| CADC-CONT-005 | Pertinent statutes and regulations set forth in the body after the statement of issues, or in an addendum introduced by a table of contents (with a statement in the body referencing it); an addendum over 40 pages is bound separately; an addendum bound with the brief is separated by a distinctly colored page (paper). Or the statement "[Except for the following,] all applicable statutes, etc., are contained in the Brief for ___." | Circuit Rule 28(a)(5) (CR); HB p. 42 | M |
| CADC-CONT-006 | Summary of argument immediately preceding the argument (except where a Standing section intervenes), in each brief including a reply brief; not merely the argument headings. | Circuit Rule 28(a)(6) (CR); FRAP 28(a)(7) | M |
| CADC-CONT-007 | Citations to the record, authorities or other material refer to specific pages; no "passim". | Circuit Rule 28(b) (CR); HB p. 43 | M (A for content) |
| CADC-CONT-008 | Unpublished dispositions not in a publicly accessible database: a copy filed and served with the brief. Citation forms: Federal Reporter for D.C. Circuit decisions, National Reporter System for D.C. and state decisions. | Circuit Rule 32.1(b) (CR); HB p. 43 | A |
| CADC-CONT-009 | Avoid acronyms other than widely known ones. | HB p. 42 | A |

### Length and certificate of compliance

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-LEN-001 | Excluded from the count: FRAP 32(f) items (cover, disclosure statement, TOC, table of citations, statement regarding oral argument, addendum of statutes/rules/regulations, certificate of counsel, signature block, proof of service) plus the Circuit Rule 28(a)(1) certificate, the glossary, and any addendum of standing evidence. Headings, footnotes and quotations count. | FRAP 32(f) (CR); Circuit Rule 32(e)(1) (CR); HB pp. 40-41 | M |
| CADC-CERT-001 | Certificate of compliance (FRAP 32(g)(1)) signed by counsel stating the number of words; "generalized statements that the brief does not exceed the maximum length limitations, without indicating the specific number of words or lines, are not allowed." Word-processor counts may be used if they count footnotes and citations. | FRAP 32(g) (CR); HB p. 41 | M |
| CADC-CERT-002 | The stated word count equals an independent count of counted words and is within the limit. | FRAP 32(g)(1) | M |
| CADC-LEN-002 | A motion to exceed length must be filed at least 7 days before the brief is due; granted only for extraordinarily compelling reasons. | Circuit Rule 28(e) (CR) | A |

### Signature, service, electronic filing (Circuit Rules 25, 32)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-ELEC-001 | Electronically filed documents are PDF "generated from an original word-processing file and ... text searchable"; appendix items and attachments may be scanned only if no word-processing version exists. Check: text extracts on every page. | Circuit Rule 32(b)(1) (CR) | M |
| CADC-ELEC-002 | Signature: the filer's name preceded by "/s/" typed where the signature would appear, followed by the firm name, if any, and the attorney's street address, telephone number, and e-mail address. | Circuit Rule 32(a)(1) (CR); FRAP 32(d) | M |
| CADC-ELEC-003 | Hyperlinks only to the same document, other filings in the case, the record, or cited authorities; never replacing standard citations. | Circuit Rule 32(c) (CR) | M (conditional) |
| CADC-ELEC-004 | Paper copies of briefs must be filed in addition to the electronic original (original and 8 copies; within two business days by First-Class Mail unless ordered otherwise); initial briefs under the deferred-appendix method are electronic only unless the court requests paper. | Circuit Rule 32(d)(3)-(4) (CR); Circuit Rule 31(b) (CR); HB pp. 39-40 | M (procedure; A) |
| CADC-ELEC-005 | Redact Social Security and financial account numbers (last four digits), minors' names (initials), dates of birth (year), home addresses in criminal cases (city and state). | Circuit Rule 25(e) (CR) | A |
| CADC-ELEC-006 | Sealed material may not be filed through CM/ECF. | Circuit Rule 25(c)(4) (CR) | A |
| CADC-CERT-003 | Service: the Notice of Docket Activity is service on parties who consented to electronic service; any other party is served by an alternative FRAP 25 method, with proof of service under FRAP 25(d). All exemplars include a certificate of service. | Circuit Rule 25(f) (CR); FRAP 25(d); EX | M (conditional); C (always included) |
| CADC-ELEC-007 | Nonconforming briefs: the clerk directs a corrected brief or errata. | Circuit Rule 32(g) (CR); HB p. 40 | A |

## Doc type: opening-brief

Exemplars: Centro de Trabajadores Unidos (Public Citizen Litigation Group; Raise the Floor Alliance), No. 25-5181; Hegseth et al. (U.S. Department of Justice, Civil Division), No. 26-5070.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-LEN-010 | Principal brief: no more than 13,000 words (or 1,300 monospaced lines; 30 pages without a certificate). | FRAP 32(a)(7)(A), (B)(i) (CR); Circuit Rule 28(c); HB pp. 40-41 | M |
| CADC-CONT-010 | Order (HB IX.A.8): Rule 28(a)(1) certificate; TOC; TOA; glossary; jurisdictional statement (district court/agency and court of appeals jurisdiction, timeliness dates, finality); statutes and regulations (or addendum statement); statement of the issues; statement of the case; summary of argument; Standing (direct review of agency action); argument, with the standard of review for each issue; conclusion stating the precise relief sought; certificate of compliance. | FRAP 28(a) (CR); Circuit Rule 28(a)(1)-(7) (CR); HB pp. 41-43 | M |
| CADC-CONT-011 | Standing section: in cases of direct review of administrative action, titled "Standing", following the summary of argument and immediately preceding the argument, with arguments and evidence establishing standing by a "substantial probability"; evidence not in the record goes in an addendum. | Circuit Rule 28(a)(7) (CR); ORD-28A7 | M (conditional) |
| CADC-COVER-010 | Cover color (paper copies): blue. | FRAP 32(a)(2) (CR) | M (paper only) |

## Doc type: answering-brief

Exemplars: Wilson / United States (U.S. Attorney's Office for D.C.), No. 25-3041; State of New York et al. (New York Attorney General), No. 19-5125 (2019; "Final Brief for Appellees").

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-LEN-020 | Appellee's principal brief: no more than 13,000 words. | FRAP 32(a)(7)(B)(i) (CR); HB pp. 40-41 | M |
| CADC-CONT-020 | Conforms to FRAP 28(a)(1)-(8) and (10); the jurisdictional statement, statement of the issues, statement of the case and standard of review need not appear unless the appellee is dissatisfied with the appellant's. A counter-statement of jurisdiction is permitted. | FRAP 28(b) (CR); Circuit Rule 28(a)(4) (CR); HB p. 42 | M |
| CADC-CONT-021 | Rule 28(a)(1) certificate: the appellee may omit parties listed by the appellant, using the formula "[Except for the following,] all parties, intervenors, and amici appearing [before the district court and] in this court are listed in the Brief for ___", and may incorporate the rulings paragraph by the parallel formula. | Circuit Rule 28(a)(1)(A)-(B) (CR) | M |
| CADC-COVER-020 | Cover color (paper copies): red. | FRAP 32(a)(2) (CR) | M (paper only) |

## Doc type: reply-brief

Exemplars: Rosen-Kellogg (Swick & Shapiro), No. 24-5158; John Doe a.k.a. Kidane (Electronic Frontier Foundation; Robins Kaplan), No. 16-7081 (2016; certificate in the pre-2016 form, layout reference only).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CADC-LEN-030 | Reply brief: no more than half the type volume of a principal brief, i.e. 6,500 words (15 pages without a certificate). | FRAP 32(a)(7)(A), (B)(ii) (CR); HB p. 41 | M |
| CADC-CONT-030 | A reply brief must contain a table of contents with page references and a table of authorities with page references (no passim). | FRAP 28(c) (CR); Circuit Rule 28(a)(2) (CR) | M |
| CADC-CONT-031 | The Circuit Rule 28(a) additions apply to briefs "for an appellant/petitioner and an appellee/respondent"; a summary of argument is expressly required "in each brief, including a reply brief". Whether the Rule 28(a)(1) certificate and glossary are required in a reply is not stated separately; Neither reply exemplar (Rosen-Kellogg, Kidane) has the Rule 28(a)(1) certificate; Kidane has a glossary (it uses abbreviations), Rosen-Kellogg does not. The glossary therefore follows Circuit Rule 28(a)(3) whenever abbreviations are used. | Circuit Rule 28(a), 28(a)(6) (CR); EX | M (summary); C (certificate omitted); M (conditional) glossary |
| CADC-COVER-030 | Cover color (paper copies): gray. | FRAP 32(a)(2) (CR) | M (paper only) |

## Not verified

- The CM/ECF page (https://www.cadc.uscourts.gov/cmecf) links no PDF size limit or ECF user manual; no file-size requirement is recorded.
- The D.C. Circuit "Brief Compliance Checklist" cited in an older README was not located on the court site on 2026-10-17.
