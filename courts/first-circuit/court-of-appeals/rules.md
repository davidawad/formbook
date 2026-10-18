# First Circuit Court of Appeals briefs: rules

Alias `ca1`. Scope: the principal brief of an appellant (`opening-brief`), the principal brief of an appellee (`answering-brief`) and the appellant's reply brief (`reply-brief`), filed by counsel through CM/ECF in the United States Court of Appeals for the First Circuit. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the usual FRAP amendment date) and whenever the court posts an amended Rulebook at https://www.ca1.uscourts.gov/sites/ca1/files/rulebook.pdf.

## Sources

Page numbers are the printed page numbers of the Rulebook.

| Tag | Source | URL |
|---|---|---|
| RB | First Circuit Rulebook: FRAP, First Circuit Local Rules, IOPs, "Effective with amendments through June 1, 2026" (197 PDF pages; read 2026-10-17). Contains the FRAP text, the Notice to Litigants (p. 7), the Local Rules and Appendix Form 6 (p. 113). | https://www.ca1.uscourts.gov/sites/ca1/files/rulebook.pdf |
| FRAP | Federal Rules of Appellate Procedure, Rules 25, 26.1, 28, 32 (cross-check of the RB text; same wording) | https://www.law.cornell.edu/rules/frap/rule_32 and https://www.law.cornell.edu/rules/frap/rule_28 |
| EX | The filed exemplars in each doc type's `usage/` (see `usage/SOURCE.md` there). Visual reference only. | local |

Kinds: **M** = mandated by a court rule (FRAP or First Circuit Local Rule). **C** = convention (seen in exemplars from different filers; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **No local override of FRAP 32 form or length.** The Notice to Litigants ¶ 2 (RB p. 7) directs parties to "carefully comply with the margin, print size, and word limit requirements of Fed. R. App. P. 32". There is no local word limit and no named typeface: FRAP 32(a)(5)(A) governs ("A proportionally spaced face must include serifs ... must be 14-point or larger").
2. **Addendum required in the appellant's brief** (Local Rule 28.0(a), RB p. 58): the judgment or order appealed from, with its supporting explanation, bound at the rear and beginning with its own table of contents.
3. **Disclosure statement placement** (Notice to Litigants ¶ 6; FRAP 26.1(d)(2)): in front of the table of contents of the principal brief, for a nongovernmental corporate party, even if there is nothing to disclose.
4. **Paper copies are still required for briefs** (Local Rule 25.0(b)(3), Local Rule 31.0(b): the electronic brief counts as one copy and nine paper copies follow after the clerk accepts the e-filing). The FRAP 32(a)(2) cover colors therefore apply to those paper copies; the electronic PDF has no color requirement.
5. **Certificate of service only where FRAP 25(d) requires one** (Local Rule 25.0(e); Notice to Litigants ¶ 7): the Notice of Docket Activity is service on ECF filers.
6. **Optional oral-argument statement** (Local Rule 34.0(a), RB p. 74-75): at most one-half page, placed immediately after the TOC and TOA, captioned "REASONS WHY ORAL ARGUMENT SHOULD [NEED NOT] BE HEARD", excluded from the length count.

## Court-wide requirements (all three doc types)

### Page form (FRAP 32(a)(1), (4) to (6))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-FORM-001 | Every page is 8 1/2 by 11 inch. | FRAP 32(a)(4), RB p. 68 | M |
| CA1-FORM-002 | Margins at least one inch on all four sides. Page numbers may be placed in the margins, but no text may appear there. | FRAP 32(a)(4), RB p. 68 | M |
| CA1-FORM-003 | Text double-spaced; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced. | FRAP 32(a)(4), RB p. 68 | M |
| CA1-FORM-004 | Typeface: "A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions. A proportionally spaced face must be 14-point or larger." (Or a monospaced face of no more than 10 1/2 characters per inch.) No First Circuit rule names a face. The rule states no footnote exemption, so the checks apply 14 pt to footnotes too. | FRAP 32(a)(5), RB p. 68; Notice to Litigants ¶ 2, RB p. 7 | M |
| CA1-FORM-005 | Plain, roman style; italics or boldface may be used for emphasis; case names italicized or underlined. | FRAP 32(a)(6), RB p. 68 | M |
| CA1-FORM-006 | Clear black image on light paper, one side only; text with a clarity equal to a laser printer. | FRAP 32(a)(1), RB p. 67 | M |
| CA1-FORM-007 | Every font used is embedded and is the template's declared family. | project | T |
| CA1-FORM-008 | Typeface choice: Times New Roman 14 pt is used by Acadia (Drummond Woodsum), Mundell (Johnson & Webbert), Griffin (Morgan, Brown & Joy), O'Donovan (Homan/Weinberg) and Warner (Whitney Law Group); Figueroa (Jellison & Nathanson) uses Century Schoolbook. Any FRAP-conforming serif face is acceptable; the face is a convention, not a rule. | EX (6 exemplars, 6 filers) | C |
| CA1-FORM-009 | Page numbering: cover unnumbered; front matter (disclosure, TOC, TOA) in lowercase roman numerals; body starts at Arabic 1; numbers centered at the foot. Seen in all six exemplars (Figueroa, Acadia, Griffin, Mundell, Warner, O'Donovan). | EX | C |
| CA1-FORM-010 | Table of contents with dot leaders and right-aligned page numbers. Seen in all six exemplars. | EX | C |

### Cover (FRAP 32(a)(2))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-COVER-001 | The number of the case centered at the top of the front cover. | FRAP 32(a)(2)(A), RB p. 67 | M |
| CA1-COVER-002 | The name of the court (United States Court of Appeals for the First Circuit). | FRAP 32(a)(2)(B), RB p. 67 | M |
| CA1-COVER-003 | The title of the case (see FRAP 12(a)). | FRAP 32(a)(2)(C), RB p. 67 | M |
| CA1-COVER-004 | The nature of the proceeding (e.g., Appeal, Petition for Review) and the name of the court, agency, or board below. | FRAP 32(a)(2)(D), RB p. 68 | M |
| CA1-COVER-005 | The title of the brief, identifying the party or parties for whom the brief is filed. | FRAP 32(a)(2)(E), RB p. 68 | M |
| CA1-COVER-006 | The name, office address, and telephone number of counsel representing the party for whom the brief is filed. | FRAP 32(a)(2)(F), RB p. 68 | M |
| CA1-COVER-007 | Cover color on the required paper copies: appellant blue, appellee red, reply gray (not for unrepresented parties). Not applicable to the electronic PDF. | FRAP 32(a)(2), RB p. 67; Local Rule 25.0(b)(3), RB p. 46; Local Rule 31.0(b) | M (paper only) |
| CA1-COVER-008 | Cover occupies one page; counsel block at the foot. Acadia's PDF repeats the cover on page 2 (that filer's artifact, not a convention). | EX | C |

### Length and certificate of compliance (FRAP 32(a)(7), (f), (g))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-LEN-001 | Excluded from any length count: cover page, disclosure statement, table of contents, table of citations, statement regarding oral argument, addendum containing statutes, rules, or regulations, certificate of counsel, signature block, proof of service, and any item excluded by local rule. Headings, footnotes and quotations count. | FRAP 32(f), RB p. 69-70 | M |
| CA1-LEN-002 | The Local Rule 34.0(a) oral-argument statement is not counted. | Local Rule 34.0(a), RB p. 74-75 | M |
| CA1-CERT-001 | A brief relying on the FRAP 32(a)(7)(B) type-volume limit must include a certificate by the attorney stating the number of words; the preparer may rely on the word processor's count. Form 6 (RB p. 113) is an acceptable form: it states compliance with the type-volume limit, the word count excluding FRAP 32(f) items, and the typeface (word-processing program, font size and name). Signed "(s)", "Attorney for", "Dated". | FRAP 32(g)(1)-(2), RB p. 70; Form 6, RB p. 113 | M |
| CA1-CERT-002 | The word count stated in the certificate equals an independent count of counted words and is within the limit. | FRAP 32(g)(1) | M |
| CA1-LEN-003 | Motions for leave to file an oversized brief: at least ten days before the due date (seven for a reply), specifying the length sought; granted only for compelling reasons. | Local Rule 32.4, RB p. 71 | A |

### Contents common to the briefs

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-CONT-001 | Required sections under appropriate headings and in the order indicated by FRAP 28. | Notice to Litigants ¶ 3, RB p. 7; FRAP 28(a), RB p. 56 | M |
| CA1-CONT-002 | Disclosure statement (FRAP 26.1) for a nongovernmental corporate party, placed before the table of contents in the principal brief; required even if there is nothing to disclose. | FRAP 26.1(a), (d)(2), RB p. 52-53; Notice to Litigants ¶ 6, RB p. 7 | M (conditional) |
| CA1-CONT-003 | Table of contents, with page references. | FRAP 28(a)(2), (c), RB p. 56-57 | M |
| CA1-CONT-004 | Table of authorities: cases (alphabetically arranged), statutes, and other authorities, with references to the pages of the brief where they are cited. | FRAP 28(a)(3), (c), RB p. 56-57 | M |
| CA1-CONT-005 | Optional oral-argument statement, at most one-half page, immediately after the TOC and TOA and before the first page of the brief, captioned "REASONS WHY ORAL ARGUMENT SHOULD BE HEARD" or "REASONS WHY ORAL ARGUMENT NEED NOT BE HEARD". Not used in any of the six exemplars. | Local Rule 34.0(a), RB p. 74-75 | M (conditional) |
| CA1-CONT-006 | Relevant parts of statutes, rules, regulations set out in the brief or in an addendum at the end. | FRAP 28(f), RB p. 58 | M (conditional) |
| CA1-CONT-007 | State-court citations give both the official state reporter and the National Reporter System citation; unpublished First Circuit dispositions are marked as unpublished. | Local Rule 32.2, RB p. 71; Local Rule 32.1.0(a), RB p. 71 | A |
| CA1-CONT-008 | Factual assertions supported by accurate references to the appendix or the record. | Notice to Litigants ¶ 4, RB p. 7; FRAP 28(e) | A |
| CA1-CONT-009 | Minimize "appellant"/"appellee"; use the parties' names or lower-court designations. | FRAP 28(d), RB p. 57 | A |

### Signature, service, electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-ELEC-001 | Documents are formatted for electronic filing by converting the original word-processing document to PDF; PDF images created by scanning paper documents do not comply (exhibits may be scanned if no word-processing file exists). Check: text extracts on every page. | Local Rule 25.0(a)(3), RB p. 46 | M |
| CA1-ELEC-002 | Briefs (including the Local Rule 28.0 addendum) must be filed electronically; the clerk reviews the tendered brief, then the filer files paper copies (nine, the electronic brief counting as one) within seven days of the notification. | Local Rule 25.0(b)(3), RB p. 46-47; Local Rule 31.0(b) | M (filing procedure; A) |
| CA1-ELEC-003 | Every brief signed by the party or one of its attorneys; the ECF login and password serve as the filer's signature (typed "/s/" signature block). | FRAP 32(d), RB p. 69; Local Rule 25.0(j), RB p. 49 | M |
| CA1-ELEC-004 | Hyperlinks allowed, but complete citations must be included in the text; no links to sealed material. | Local Rule 25.0(n), RB p. 50 | M (conditional) |
| CA1-ELEC-005 | Redact personal data identifiers per FRAP 25(a)(5); responsibility rests solely with counsel. | Local Rule 25.0(m), RB p. 50 | A |
| CA1-CERT-003 | Certificate of service only if required by FRAP 25(d) (e.g., a party not registered with ECF); if used, attached to the last page and stating the date and manner of service and the names and addresses of the persons served. The Notice of Docket Activity is service on ECF filers. All six exemplars include one anyway. | Local Rule 25.0(e), RB p. 48; Notice to Litigants ¶ 7, RB p. 7; EX | M (conditional); C (included) |
| CA1-ELEC-006 | Sealed material goes in a separate sealed filing (paper only), never in the public brief or addendum. | Local Rule 25.0(b)(1), (h); Local Rule 28.0(c); Local Rule 28.1 | A |

## Doc type: opening-brief

Exemplars: Figueroa (Jellison & Nathanson, criminal), Acadia Hospital Corp. (Drummond Woodsum, civil).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-LEN-010 | Principal brief: no more than 13,000 words (or 30 pages without a certificate, or 1,300 monospaced lines). | FRAP 32(a)(7)(A), (B)(i), RB p. 68 | M |
| CA1-CONT-010 | Contents in order: disclosure statement (if FRAP 26.1 applies); TOC; TOA; jurisdictional statement (district court/agency jurisdiction, court of appeals jurisdiction, filing dates showing timeliness, final-judgment assertion or other basis); statement of the issues; statement of the case (facts, procedural history, rulings presented for review, record references); summary of the argument (not merely the headings); argument with, for each issue, a concise statement of the standard of review; short conclusion stating the precise relief sought; certificate of compliance. | FRAP 28(a)(1)-(10), RB p. 56-57 | M |
| CA1-CONT-011 | Addendum (required): the judgments, decisions, rulings, or orders appealed from, with any supporting explanation, and any lower-level decision reviewed below (e.g., a magistrate judge's recommended decision); a text-only docket order is supplied as a copy of the docket entry. Optional extra record items up to 25 pages total (statutes under FRAP 28(f) do not count toward the 25). | Local Rule 28.0(a), RB p. 58-59 | M |
| CA1-CONT-012 | Addendum form: bound at the rear of the brief, beginning with a table of contents identifying the page at which each part begins. Both exemplars place it after the certificates. | Local Rule 28.0(b), RB p. 59; EX | M; C (after certificates) |
| CA1-CONT-013 | Standard of review: Acadia sets it as its own top-level heading before the Argument; Figueroa states it within each argument point. Both are permitted by FRAP 28(a)(8)(B); the placement is a filer choice. | FRAP 28(a)(8)(B); EX | M (presence); C (placement open) |
| CA1-COVER-010 | Cover color (paper copies): blue. | FRAP 32(a)(2), RB p. 67 | M (paper only) |

## Doc type: answering-brief

Exemplars: Griffin / Massachusetts Department of Revenue (Morgan, Brown & Joy), Mundell (Johnson & Webbert; Borealis Law).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-LEN-020 | Appellee's principal brief: no more than 13,000 words (FRAP 32(a)(7)(B)(i) limit for a principal brief). | FRAP 32(a)(7)(B)(i), RB p. 68 | M |
| CA1-CONT-020 | Conforms to FRAP 28(a)(1)-(8) and (10): disclosure statement if required, TOC, TOA, summary of argument, argument, certificate of compliance. The jurisdictional statement, statement of the issues, statement of the case and standard of review need not appear unless the appellee is dissatisfied with the appellant's statement. Both exemplars include a statement of the issues and of the case. | FRAP 28(b), RB p. 57; EX | M; C (statements included) |
| CA1-CONT-021 | Optional addendum to incorporate materials omitted from the appellant's addendum, subject to the same length and content limits (Mundell includes one). | Local Rule 28.0(b)(1), RB p. 59 | M (conditional) |
| CA1-COVER-020 | Cover color (paper copies): red. | FRAP 32(a)(2), RB p. 67 | M (paper only) |

## Doc type: reply-brief

Exemplars: Warner (Whitney Law Group), O'Donovan (Kimberly Homan; Martin G. Weinberg).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA1-LEN-030 | Reply brief: no more than half the type volume of a principal brief, i.e. 6,500 words (or 15 pages without a certificate). | FRAP 32(a)(7)(A), (B)(ii), RB p. 68 | M |
| CA1-CONT-030 | A reply brief must contain a table of contents with page references and a table of authorities with the pages where cited. No other section is required. | FRAP 28(c), RB p. 57 | M |
| CA1-CONT-031 | A reply brief may be rejected if it repeats the main brief or contains matter that should have been in the main brief. | Local Rule 31.0(a)(1) | A |
| CA1-CONT-032 | Body opens with an Introduction, then roman-numeral reply points, then Conclusion: seen in both Warner and O'Donovan. | EX | C |
| CA1-COVER-030 | Cover color (paper copies): gray. | FRAP 32(a)(2), RB p. 67 | M (paper only) |

## Not verified

- The ca1 "Checklist for Briefs" (rev. 3/22) cited in the doc-type READMEs (footnotes the same size as the body) could not be located on the court site on 2026-10-17 (the site's rules pages returned 404 to this box). The footnote-size rule above rests on FRAP 32(a)(5)(A) alone (CA1-FORM-004).
- RB page numbers for Local Rules 25.0(m)-(n) (p. 50) and 32.1.0/32.2/32.4 (p. 71) are taken from the page-number lines adjacent to the text in `pdftotext` output.
