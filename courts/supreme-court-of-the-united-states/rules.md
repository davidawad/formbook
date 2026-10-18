# Supreme Court of the United States: rules

Alias `scotus`. Scope: booklet-format documents filed by counsel under Rule 33.1 (petition for a writ of certiorari, brief on the merits, brief for an amicus curiae), as built by the doc-type folders `cert-petition/`, `merits-brief/` and `amicus-brief/`. Verified against primary sources on 2026-10-17.

Re-check cadence: each time the Court amends its Rules (it posts a revisions notice on the "Rules and Guidance" page; the last amendments were adopted 2026-02-17, effective 2026-03-16) and at least once a year, every October before the Term opens; re-check the electronic filing guidelines with the same cadence.

## Sources

| Tag | Source | URL |
|---|---|---|
| R | Rules of the Supreme Court of the United States, adopted February 17, 2026, effective March 16, 2026 (read: Rules 14, 24, 29, 33, 34, 37). Page numbers are the Rules' printed pages. | https://www.supremecourt.gov/filingandrules/2026RulesoftheCourt_WEB.pdf |
| CHART | "U.S. Supreme Court: Booklet-Format Specification Chart", effective March 16, 2026 (same word limits and colors as Rule 33.1(g)) | https://www.supremecourt.gov/casehand/BookletFormatSpecificChart2026.pdf |
| EFG | "Guidelines for the Submission of Documents to the Supreme Court's Electronic Filing System" (March 2026 edition, PDF created 2026-03-09), issued by the Clerk under Rule 29.7 | https://www.supremecourt.gov/filingandrules/ElectronicFilingGuidelines_March2026.pdf |
| EX-* | The filed exemplars in each doc type's `usage/` (see `SOURCE.md` there). Visual reference only. | local |

Kinds: **M** = mandated by a Rule of the Court (or the Clerk's guidelines that Rule 29.7 makes binding). **C** = convention (from the exemplars or common practice; the Rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **The Rules fix the booklet, not the e-file page.** Rule 33.1(a) requires a 6 1/8 x 9 1/4 inch booklet; every filed exemplar's electronic copy (8 of 8, five filers) is a US Letter PDF with the booklet text block placed on the page. Rule 29.7 and EFG say nothing about the PDF page size. The templates render the booklet page itself (the Rule); a letter-size e-file wrapper is a convention, not a requirement.
2. **Font is the Century family, by Rule.** Rule 33.1(b): "typeset in a Century family (e. g., Century Expanded, New Century Schoolbook, or Century Schoolbook) 12-point type with 2-point or more leading between lines"; footnotes "10-point type with 2-point or more leading".
3. **No "passim".** Rule 34.2 says the table of authorities "should not use the 'passim' notation". Two filers in the exemplars use it anyway (Munger Tolles in 21-1397, the Solicitor General in 21-1397); the templates follow the Rule.
4. **The amicus disclosure goes in the first footnote** on the first page of text (Rule 37.6, 2026 text), not wherever the author likes. Governments listed in Rule 37.6 are exempt.
5. **The word-count certificate and proof of service are separate documents** (Rules 33.1(h), 29.5), not pages of the brief.
6. **Cover color is a paper-copy property.** Rule 33.1(e) and the chart set it; the e-filed PDF in every exemplar has a white cover. Not rendered.

## Requirements (court-wide, every booklet-format document)

IDs are stable. `checks.yaml` references them. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (Rule 33.1(a) to (c))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-FORM-001 | Booklet format: 6 1/8 by 9 1/4 inch pages (441 x 666 pt), "using a standard typesetting process" producing "typographic (as opposed to typewriter) characters"; "a clear, black image on white paper". | R 33.1(a), pp. 43-44 | M |
| SCOTUS-FORM-002 | Typeface: "a Century family (e. g., Century Expanded, New Century Schoolbook, or Century Schoolbook)", applied to the text "including any appendix". | R 33.1(b), p. 44 | M |
| SCOTUS-FORM-003 | Text "12-point type with 2-point or more leading between lines" (baseline pitch at least 14 pt). | R 33.1(b) | M |
| SCOTUS-FORM-004 | Footnotes "10-point type with 2-point or more leading between lines" (pitch at least 12 pt). | R 33.1(b) | M |
| SCOTUS-FORM-005 | "Quotations in excess of 50 words shall be indented." | R 33.1(b) | M |
| SCOTUS-FORM-006 | Text on both sides of the page (paper copies; the PDF is one page per side). | R 33.1(b) | M (paper) |
| SCOTUS-FORM-007 | Margins at least three-fourths of an inch on all sides; the text field, including footnotes, may not exceed 4 1/8 by 7 1/8 inches. | R 33.1(c), p. 44 | M |
| SCOTUS-FORM-008 | Every font used is embedded, and every embedded font is the template's declared Century-family face (no silent fallback). | project; supports R 33.1(b) | T |
| SCOTUS-FORM-009 | Pagination: page numbers at the top of the page (first text line of the page in all eight exemplars); front matter after the cover in roman numerals, body in Arabic numerals from 1; appendix pages suffixed "a" or prefixed "App-". Lowercase roman in five filers (Fisher/Wiley Rein, Munger Tolles, Clement & Murphy, Schaerr Jaffe, Gibson Dunn); capital roman in the West Virginia AG brief, and capital roman in parentheses at the foot of a section's first page ("(III)") in the SG brief (each one filer's style). The Rules say nothing about page numbers. | EX-* (pdftotext of pages 3, 4, 12, 13 of each exemplar, 2026-10-17) | C |
| SCOTUS-FORM-010 | Table of contents and table of authorities use dot leaders to right-aligned page numbers. Seen in all eight exemplars (Fisher uses spaced dots). | EX-* | C |

### Length (Rule 33.1(d), (g))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-LEN-001 | Every booklet-format document complies with the word limit in the Rule 33.1(g) chart for its type (per-doc-type limits below). | R 33.1(d), (g), pp. 44-46; CHART | M |
| SCOTUS-LEN-002 | Excluded from the count: the questions presented, the list of parties and the corporate disclosure statement, the table of contents, the table of cited authorities, the listing of counsel at the end of the document, any appendix, and verbatim quotations required by Rule 14.1(f) or 24.1(f) if set out in the text. Footnotes are counted. | R 33.1(d), pp. 44-45 | M |

### Cover (Rule 34.1, Rule 33.1(e))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-COVER-001 | The cover bears, in this order from the top: (a) the docket number, or a space for one; (b) the name of this Court; (c) the caption of the case as appropriate in this Court; (d) the nature of the proceeding and the court below (e.g. "On Petition for Writ of Certiorari to the United States Court of Appeals for the Fifth Circuit"; for a merits brief "On Writ of Certiorari to ..."); (e) the title of the document; (f) the counsel of record, with a notation directly under the name identifying the attorney as counsel of record, and counsel's office address, e-mail address and telephone number. | R 34.1(a)-(f), pp. 47-48 | M |
| SCOTUS-COVER-002 | Only one counsel of record per document (except a joint appendix). | R 34.1(f) | M |
| SCOTUS-COVER-003 | Cover type "may not be set in type smaller than standard 11-point", except the identification of counsel. | R 34.1(g), p. 48 | M |
| SCOTUS-COVER-004 | Cover color per the Rule 33.1(g) chart (per doc type below); a document filed by the United States or a federal party represented by the Solicitor General has a gray cover; any document not in the chart has a tan cover. 65-pound paper. Paper copies only; the PDF cover is white in every exemplar. | R 33.1(e), p. 45; CHART | M (paper only) |
| SCOTUS-COVER-005 | Cover layout (page 1 rendered and viewed for the Chamber/Gibson Dunn, West Virginia AG and Solicitor General exemplars, 2026-10-17): docket number centered at the top; the Court's name as a single line set in a blackletter face; caption centered with party designations right of center; short centered rules between the caption, the proceeding line and the title; title in bold capitals; counsel names in small capitals, at the foot, counsel of record marked "Counsel of Record" in italics under the name; the cover alone on page 1. Seen across three filers: convention. The blackletter face is not required (the Rule requires only the Century family for "the text"). | EX-chamber-of-commerce, EX-west-virginia, EX-united-states | C |

### Contents (Rule 34.2 to 34.5)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-CONT-001 | A document over 1,500 words (Rule 33.1) contains a table of contents and a table of cited authorities (cases alphabetically arranged, constitutional provisions, statutes, treatises, other materials) with references to the pages where each is cited. | R 34.2, p. 48 | M |
| SCOTUS-CONT-002 | The table of authorities lists every page on which an authority is cited and does not use "passim"; a range is allowed only when the authority is cited on every page in it. | R 34.2, p. 48 | M |
| SCOTUS-CONT-003 | The body bears at its close the name of counsel of record and any other counsel named on the cover. | R 34.3, pp. 48-49 | M |
| SCOTUS-CONT-004 | Every appendix begins with a table of contents describing each document in it. | R 34.4, p. 49 | M |
| SCOTUS-CONT-005 | Federal statutes cited to the United States Code where codified; otherwise to the Statutes at Large. | R 34.5, p. 49 | A |
| SCOTUS-CONT-006 | Privacy redaction follows FRAP 25(a)(5), FRBP 9037, FRCP 5.2 or FRCrP 49.1 as applied below. | R 34.6, p. 49 | A |
| SCOTUS-CONT-007 | Sealed material is marked "Under Seal" on the cover and every page; the public copy is marked "Public Copy—Sealed Materials Redacted" on the cover; neither is submitted through the electronic filing system. | R 34.7(f), p. 50 | M (conditional) |
| SCOTUS-CONT-008 | Corporate disclosure statement for a nongovernmental corporate filer (parents; any publicly held company owning 10% or more; stock ticker symbols, if any; or a notation that there are none). Not required in an amicus brief or joint appendix. | R 29.6, p. 41; EFG 16(b) | M (conditional) |

### Certificates (Rule 33.1(h), Rule 29.5)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-CERT-001 | A Rule 33.1 document is accompanied by a certificate, signed by the attorney, unrepresented party or preparer, stating that it complies with the word limit and stating the number of words; the count must include footnotes. The certificate is separate from the document. A preparer who is not a member of the Bar, counsel of record or the party adds a notarized affidavit or 28 U.S.C. § 1746 declaration. | R 33.1(h), pp. 46-47 | M |
| SCOTUS-CERT-002 | The number stated in the certificate equals the counted words and is at most the limit. | R 33.1(h); R 33.1(d) | M |
| SCOTUS-CERT-003 | Proof of service, when required, accompanies the document and is separate from it; it states that all parties required to be served have been served and lists the names, addresses and telephone numbers of counsel with the party each represents. | R 29.5, p. 40 | M (separate document) |

### Electronic filing (Rule 29.7, EFG)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-ELEC-001 | Counsel also submit the document to the electronic filing system under the Clerk's guidelines. | R 29.7, p. 41 | M |
| SCOTUS-ELEC-002 | The PDF "should be in the PDF/A format" and, where possible, created from a word-processing document and text searchable (also the certificate of word count and the proof of service). Check: text extracts on every page; fonts embedded. | EFG 4 | M (as "should") |
| SCOTUS-ELEC-003 | No single uploaded file exceeds 100 MB; larger documents are split. | EFG 5 | M |
| SCOTUS-ELEC-004 | Stock ticker symbols for entities in the Parties to the Proceeding and Corporate Disclosure sections, if they exist. | EFG 16(b); R 14.1(b)(i), 24.1(b) | M (conditional) |
| SCOTUS-ELEC-005 | The electronic version need not carry a physical signature. Hyperlinks to the same document or external sources are allowed. | EFG 4 | M (permissive) |
| SCOTUS-ELEC-006 | E-filed PDF page: US Letter carrying the booklet text block (all eight exemplars, five filers). Not required by any Rule; see Finding 1. | EX-* | C |

## Doc type: `cert-petition` (Rule 14)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-LEN-010 | Petition for a writ of certiorari: 9,000 words. Cover white. | R 33.1(g)(i), p. 45; CHART | M |
| SCOTUS-CONT-010 | Contents in this order: (a) questions presented, on the first page after the cover, with no other information on that page ("capital case" precedes them where applicable); (b)(i) list of all parties to the proceeding below, with stock ticker symbols, if any; (ii) corporate disclosure statement (Rule 29.6); (iii) list of directly related proceedings (court, docket number, caption, date of judgment); (c) table of contents (including the appendix items) and table of cited authorities, if over 1,500 words; (d) citations of the reports of the opinions and orders below; (e) statement of the basis for jurisdiction (date of judgment; rehearing and extension orders; Rule 12.5 reliance for a cross-petition; the statute conferring jurisdiction; Rule 29.4(b)/(c) notifications if applicable); (f) constitutional provisions, treaties, statutes, ordinances and regulations involved, verbatim (or cited, with text in the appendix); (g) concise statement of the case (with, for a state-court judgment, where the federal questions were raised; for a court of appeals judgment, the basis of first-instance federal jurisdiction); (h) argument amplifying the reasons for allowing the writ; (i) appendix in the order (i) to (vi) of Rule 14.1(i). | R 14.1(a)-(i), pp. 11-14 | M |
| SCOTUS-CONT-011 | All contentions are in the body of the petition; no separate supporting brief. | R 14.2, p. 14 | M |
| SCOTUS-CONT-012 | Usual heading names: "Questions Presented", "Parties to the Proceeding", "Corporate Disclosure Statement", "Statement of Related Proceedings", "Opinions Below", "Jurisdiction", "Constitutional and Statutory Provisions Involved", "Statement of the Case", "Reasons for Granting the Petition", "Conclusion". Seen in both filers (Wiley Rein/Consovoy for Fisher; Clement & Murphy for Loper Bright). | EX-fisher, EX-loper-bright | C |
| SCOTUS-CONT-013 | A non-compliant petition is returned by the Clerk; a corrected one within 60 days is deemed timely. | R 14.5, p. 14 | A |

## Doc type: `merits-brief` (Rule 24)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-LEN-020 | Brief on the merits for a petitioner or appellant: 13,000 words, cover light blue. Respondent or appellee (or respondent supporting petitioner): 13,000 words, light red. Reply brief on the merits: 6,000 words, yellow. United States / SG: gray cover. | R 33.1(g)(v)-(vii), p. 46; R 33.1(e); CHART | M |
| SCOTUS-CONT-020 | Petitioner's brief, in this order: (a) questions presented, on the first page after the cover, nothing else on that page; (b) list of all parties below with stock ticker symbols, if any, and any amended Rule 29.6 disclosure statement; (c) table of contents and table of cited authorities if over 1,500 words; (d) citations of the reports of the opinions and orders below; (e) statement of jurisdiction; (f) constitutional provisions, statutes, etc. involved, verbatim (or in an appendix); (g) statement of the case with references to the joint appendix or record; (h) summary of the argument, a condensation of the argument (not a repetition of the headings); (i) argument; (j) conclusion specifying with particularity the relief sought. | R 24.1(a)-(j), pp. 29-30 | M |
| SCOTUS-CONT-021 | Respondent's brief: same, except items (a), (d), (e), (f) and (g) need not be included unless the respondent is dissatisfied with the petitioner's presentation. Reply brief: as a respondent's brief; need not contain a summary of the argument if divided by topical headings. | R 24.2, 24.4, pp. 30-31 | M |
| SCOTUS-CONT-022 | References to the joint appendix or record give the page number (exhibits: page where it appears, offered and ruled on). | R 24.5, p. 31 | A |
| SCOTUS-CONT-023 | A respondent's brief still carries a Questions Presented page (the SG in 21-1397). One filer; not required by Rule 24.2. | EX-united-states | C (one filer) |

## Doc type: `amicus-brief` (Rule 37)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| SCOTUS-LEN-030 | Merits-stage amicus brief: 9,000 words for an amicus identified in Rule 37.6 (the United States by the Solicitor General; a federal agency by its authorized representative; a State, Commonwealth, Territory or Possession by its Attorney General; an Indian Tribe, city, county, town or similar entity by its authorized law officer); 8,000 words for any other amicus. Cover light green in support of petitioner/appellant or neither party; dark green in support of respondent/appellee. Petition-stage amicus: 6,000 words, cream. | R 33.1(g)(x)-(xiv), p. 46; R 37.6, p. 54; CHART | M |
| SCOTUS-CONT-030 | An amicus brief need contain only the interest of the amicus curiae, the summary of the argument, the argument and the conclusion (plus the Rule 33/34 parts: cover, tables). | R 37.5, p. 54 | M |
| SCOTUS-CONT-031 | Authorship and funding disclosure: whether counsel for a party authored the brief in whole or in part; whether such counsel or a party made a monetary contribution to fund its preparation or submission; every other person (other than the amicus, its members, its counsel) who made such a contribution. Made "in the first footnote on the first page of text". Not required of the Rule 37.6 governmental filers. | R 37.6, p. 54 | M |
| SCOTUS-COVER-030 | The cover identifies the party supported or indicates whether the brief suggests affirmance or reversal. | R 37.2, 37.3, pp. 52-53 | M |
| SCOTUS-CONT-032 | Petition-stage amicus brief: states that counsel of record for all parties received timely (10-day) notice of intent to file. Not required at the merits stage. | R 37.2, pp. 52-53 | M (petition stage) |
| SCOTUS-CONT-033 | Filed by an attorney admitted to the Bar of this Court. | R 37.1, p. 52 | A |
| SCOTUS-CERT-030 | Accompanied by proof of service (Rule 29). | R 37.5, p. 54 | M (separate document) |
| SCOTUS-CONT-034 | Amicus briefs commonly reproduce a "Question Presented" page before the TOC (Chamber/Gibson Dunn and West Virginia AG). Not required by Rule 37.5. | EX-chamber, EX-west-virginia | C |

## Not verified here

- The README claims about Rule 37 numbering in the 2019 text are superseded: the 2026 text (R) puts the merits-stage amicus at Rule 37.3, the governmental class and the disclosure at Rule 37.6.
- Rules 21, 22 and 39 (8 1/2 x 11 documents, Rule 33.2) are outside these doc types and were not recorded.
