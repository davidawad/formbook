# Intermediate Court of Appeals of West Virginia: briefs

Alias `wvactapp`. Scope: briefs filed in the Intermediate Court of Appeals (ICA) of West Virginia, as built by the doc-type folders `opening-brief/`, `answering-brief/`, `reply-brief/`, `petition-for-review/` and `amicus-brief/`. Verified against the Rules of Appellate Procedure as posted on courtswv.gov on 2026-10-21 (the page shows no edition date; Rule 1(e) makes the rules apply to ICA appeals from orders entered after June 30, 2022).

Re-check cadence: each time the Supreme Court of Appeals amends the Rules (the page lists the current text only) and at least once a year.

Not covered: motions (Rules 29-33, 40, 41; 15 pages), petitions for rehearing, workers' compensation docketing statements and briefs under Rule 12 (20 pages, different limits), family court and other Rule 13-15 briefs, bail petitions (Rule 34), and original-jurisdiction writs (Rule 16, filed in the Supreme Court of Appeals). The ICA has no original jurisdiction. No doc-type folder exists for them.

## Sources

| Tag | Source | URL |
|---|---|---|
| RAP | West Virginia Rules of Appellate Procedure (court rules page on courtswv.gov; text fetched 2026-10-21, HTTP 200). Cited as Rule N, subsection. | https://www.courtswv.gov/legal-community/court-rules/rules-appellate-procedure |
| EX-* | The filed exemplars in each doc type's `usage/` (see `SOURCE.md` there). Visual and convention reference only. | local |

Kinds: **M** = mandated by a rule. **C** = convention seen across filers in the exemplars where the rules leave the choice open. **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **Length is counted without the front matter.** Rule 38(c): page limits exclude "the cover page, table of contents, table of authorities, or certificate of service". The table of contents and table of authorities are required only when the brief exceeds five pages (Rule 10(c)(1)-(2)).
2. **The cover reads "In the Intermediate Court of Appeals of West Virginia".** Rule 38(b)(1). Two exemplars omit "In the"; the rule governs.
3. **Font is 12-point proportional, double-spaced**, not the 14-point or 13-point defaults some courts use. Footnotes and indented quotations may be single-spaced; footnotes at least 11-point proportional (Rule 38(a)).
4. **Amicus disclosure goes in the first footnote on the first page of text** (Rule 30(e)(5)).
5. **Respondent's brief answers each assignment of error** and need not restate them (Rule 10(d)); the reply brief need not have a summary of argument if it has topical headings (Rule 10(g)).
6. **The Rules set no PDF, font-embedding, bookmark or file-size rule** for e-filed briefs. Rule 38A(m) requires a document "legible and acceptable within the E-filing System" and compliance with Rule 38's format standards. Nothing else in the rules page constrains the PDF.

## Common to all briefs

### Form (Rule 38(a), Rule 38B(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-FORM-001 | Text is double-spaced. Footnotes and indented quotations may be single-spaced. | RAP 38(a) | M |
| WVACTAPP-FORM-002 | Text is at least 12-point proportionally spaced type (11-point if non-proportional). Footnote text is at least 11-point proportional (10-point non-proportional). | RAP 38(a) | M |
| WVACTAPP-FORM-003 | Margins are at least one inch on all sides. | RAP 38(a) | M |
| WVACTAPP-FORM-004 | Reproduction is "a clear black image on white background". Paper filings are 8 1/2 x 11 inches, securely bound at top left (Rule 38B(b), paper only). | RAP 38(a), 38B(b) | M |
| WVACTAPP-FORM-005 | Page numbers: front matter (cover is unnumbered; table of contents and table of authorities in lower-case roman) and body in Arabic numerals from 1. | RAP 10(c); EX-opening-brief (Bowe), EX-amicus-brief | C |

### Cover (Rule 38(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-COVER-001 | The cover contains, in order: (1) "In the Intermediate Court of Appeals of West Virginia"; (2) the docket number, if assigned (e.g. "No. 23-ICA-370"); (3) the official caption as set in the scheduling order, if one has issued; (4) a brief descriptive title; (5) the name, address, telephone number, West Virginia State Bar identification number and e-mail address of the counsel filing. | RAP 38(b) | M |
| WVACTAPP-COVER-002 | When the respondent's brief contains cross-assignments of error, the cover page must clearly so reflect. | RAP 10(f) | M |
| WVACTAPP-COVER-003 | The caption lists the parties with their trial-court designations (e.g. "Petitioner Below, Petitioner"). The e-file header that the court stamps ("ICA EFiled") is not the filer's to set. | EX-opening-brief, EX-answering-brief, EX-petition-for-review | C |

### Certificates and signature (Rule 37, 38A(j), 40)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-CERT-001 | A certificate of service as required by Rule 37 is attached to the end of the brief. It needs no page number and is not counted toward the page limit. | RAP 10(c)(9), 38(c), 37 | M |
| WVACTAPP-CERT-002 | An e-filed document bears a typographic signature (e.g. "/s/ Adam Attorney") and the attorney's address, telephone number, e-mail address and West Virginia State Bar identification number (or a pro hac vice notation). | RAP 38A(j) | M |
| WVACTAPP-CERT-003 | The certificate of service is served in accordance with Rule 37 (on all parties, or their counsel, through the E-Filing System or by certificate). | RAP 38A(q), 37 | M |

### E-filing and privacy (Rule 38A, 40)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-ELEC-001 | The document is titled and described accurately in the E-Filing System (e.g. "Petitioner's Brief"). The title is entered in the system, not only on the cover. | RAP 38A(n) | M |
| WVACTAPP-ELEC-002 | The document is legible and acceptable in the E-Filing System, and complies with Rule 38's format standards. | RAP 38A(m) | M |
| WVACTAPP-PRIV-001 | Initials or a descriptive term replace full names of juveniles (even if now adults), of victims in sexual-crime cases where the victim must be referred to, and in abuse and neglect, mental hygiene and expungement cases. | RAP 40(e)(1) | M |
| WVACTAPP-PRIV-002 | Birth dates and addresses appear only when absolutely necessary to the disposition. Social Security numbers may not be used under any circumstances. Sensitive financial or medical information only when necessary. | RAP 40(e)(2)-(4) | M |
| WVACTAPP-PRIV-003 | No employer taxpayer, driver's license, state ID, passport, account, credit or debit card number, PIN or password appears in a publicly available e-filed document. Redact where necessary. | RAP 38A(u) | M |
| WVACTAPP-PRIV-004 | If the lower tribunal determined the record or part of it confidential, the notice of appeal or the petitioner's brief (whichever is filed first) says so and cites the authority. | RAP 40(c) | M |

### Citations (Rule 38(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-CITE-001 | A citation to an opinion of the Intermediate or Supreme Court uses the full parallel citation (e.g. "222 W.Va. 365, 664 S.E.2d 706 (2008)"), and may note "(per curiam)". Citations may be in the body or in footnotes. | RAP 38(d) | M |

## Opening brief (petitioner's brief)

Doc type `opening-brief`. Rule 10(c) and Rule 38(c). The petitioner's brief perfects the appeal (Rule 5(g)).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-OPEN-001 | Sections appear in this order, immediately after the cover: table of contents (required if the brief exceeds five pages), table of authorities (required if the brief exceeds five pages), assignments of error, statement of the case, summary of argument, statement regarding oral argument and decision, argument, conclusion, certificate of service. | RAP 10(c)(1)-(9) | M |
| WVACTAPP-OPEN-002 | The assignments of error open the brief, expressed in the terms of the case, without unnecessary detail. A plain-error assignment says so. | RAP 10(c)(3) | M |
| WVACTAPP-OPEN-003 | The statement of the case has appropriate, specific references to the appendix or designated record, and gives the procedural history and the facts relevant to the assignments of error. | RAP 10(c)(4) | M |
| WVACTAPP-OPEN-004 | The summary of argument condenses the argument. It is not a mere repetition of the argument headings. | RAP 10(c)(5) | M |
| WVACTAPP-OPEN-005 | The statement regarding oral argument and decision addresses Rule 18(a); if argument is requested, it says whether Rule 19 or Rule 20 applies and why, and whether a Rule 19 case suits a memorandum decision. | RAP 10(c)(6) | M |
| WVACTAPP-OPEN-006 | The argument states the standard of review, headings correspond to the assignments of error, and it cites the record with pinpoint references to when and how each issue was presented below. | RAP 10(c)(7) | M |
| WVACTAPP-OPEN-007 | The conclusion specifies the relief sought. | RAP 10(c)(8) | M |
| WVACTAPP-LEN-001 | Petitioner's brief: 40 pages maximum, excluding cover page, table of contents, table of authorities and certificate of service. | RAP 38(c) | M |
| WVACTAPP-OPEN-008 | Front matter (table of contents, table of authorities) is in roman numerals; the body begins at page 1 (with the assignments of error). | RAP 10(c)(1)-(2); EX-opening-brief | C |
| WVACTAPP-OPEN-009 | The table of contents and table of authorities use dot leaders to right-aligned page numbers. | EX-opening-brief (Bowe), EX-petition-for-review (CAMC) | C |
| WVACTAPP-OPEN-010 | The cover ends with a "Submitted by" or counsel block that gives counsel's name, bar number, address, telephone and e-mail. | RAP 38(b)(5); EX-opening-brief | C |

## Answering brief (respondent's brief)

Doc type `answering-brief`. Rule 10(d), (e), (f) and Rule 38(c). The respondent may instead file a summary response (Rule 10(e)), a different document with a 15-page limit.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-ANS-001 | The respondent's brief conforms to the petitioner's brief (Rule 10(c)), except that no statement of the case is needed beyond correcting an inaccuracy or omission, and the assignments of error need not be restated. | RAP 10(d) | M |
| WVACTAPP-ANS-002 | The argument specifically responds to each assignment of error to the fullest extent possible. | RAP 10(d) | M |
| WVACTAPP-ANS-003 | Cross-assignments of error, if any, are in a separate portion of the brief, with authority and argument as in Rule 10(c), and the cover states them. | RAP 10(f) | M |
| WVACTAPP-LEN-002 | Respondent's brief: 40 pages maximum, excluding cover, table of contents, table of authorities and certificate of service. A summary response: 15 pages. | RAP 38(c) | M |
| WVACTAPP-ANS-004 | The respondent's brief is filed in the time the scheduling order sets (typically 45 days after the petitioner's brief); Rule 10(b). | RAP 10(b) | A |

## Reply brief

Doc type `reply-brief`. Rule 10(g) and Rule 38(c).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-REP-001 | The reply brief complies with the parts of Rule 10 that apply to the respondent. It need not contain a summary of argument, if it is divided by topical headings. | RAP 10(g) | M |
| WVACTAPP-LEN-003 | Reply brief: 20 pages maximum, excluding cover, table of contents, table of authorities and certificate of service. The limit is 40 pages if the respondent asserted cross-assignments, and 30 pages if more than one response brief was filed. | RAP 38(c), 10(g) | M |
| WVACTAPP-REP-002 | The reply brief is filed twenty days after the respondent's brief, or within thirty days after a cross-assignment brief (Rule 10(g) and the scheduling order). | RAP 10(b), 10(g) | A |
| WVACTAPP-REP-003 | Portrait letter pages. A landscape reply brief is not a form the rules describe; the template is portrait. | RAP 38(a), 38B(b); EX-reply-brief landscape | C |

## Petition for review (petitioner's brief in an appeal from an agency or the Health Care Authority)

Doc type `petition-for-review`. Doc type name in the court's exemplars: a petitioner's brief in an appeal under Rule 5 (for example from the West Virginia Health Care Authority). The Rules prescribe the same brief as an opening brief; there is no separate "petition for review" form in the ICA.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-PET-001 | The brief is in the format of a petitioner's brief under Rule 10 (the appeal is perfected by timely filing it with the appendix). | RAP 5(g), 10(c) | M |
| WVACTAPP-PET-002 | The appeal is perfected with the appendix record prepared under Rule 7, filed with the brief. The appendix is not counted toward the page limit. | RAP 5(g), 7(c), 38(c) | M |
| WVACTAPP-LEN-004 | Petitioner's brief: 40 pages maximum (same as the opening brief). | RAP 38(c) | M |

## Amicus curiae brief

Doc type `amicus-brief`. Rule 30 and Rule 38(c). An amicus brief need not strictly comply with Rule 10, but must contain the parts of Rule 30(e) in order.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| WVACTAPP-AMI-001 | Leave to file or consent: an amicus (other than the State, an officer or agency, or a county or municipality) files only by leave of court, or where the brief states that all parties consented. | RAP 30(a) | M |
| WVACTAPP-AMI-002 | Sections appear in this order: (1) a cover with the caption and the party supported and whether the amicus supports affirmance or reversal; (2) table of contents with page references; (3) table of authorities with page references; (4) a concise statement of the amicus's identity, interest, and source of authority to file; (5) the disclosure of authorship and monetary contribution (see WVACTAPP-AMI-003); (6) the argument, with points of fact and law and authorities under suitable headings. | RAP 30(e)(1)-(6) | M |
| WVACTAPP-AMI-003 | The disclosure of whether counsel for a party authored the brief in whole or in part, and whether a party or counsel made a monetary contribution, is in the first footnote on the first page of text. It identifies each person other than the amicus, its members or its counsel who made such a contribution. Not required for a brief filed as of right by a government amicus under Rule 30(a). | RAP 30(e)(5) | M |
| WVACTAPP-AMI-004 | Notice to counsel of record for all parties at least five days before the due date. | RAP 30(b) | M |
| WVACTAPP-LEN-005 | Amicus brief: 25 pages maximum, excluding cover, table of contents, table of authorities and certificate of service. | RAP 38(c) | M |
| WVACTAPP-AMI-005 | The amicus brief's appendix (if any) follows Rule 7 and has no page limit. | RAP 30(e), 38(c) | M |
| WVACTAPP-AMI-006 | The cover shows the party the amicus supports and its position. | RAP 30(e)(1) | M |

## Template-only requirement

| ID | Requirement | Kind |
|---|---|---|
| WVACTAPP-TPL-001 | A reusable template contains no case-specific text, measured coordinates, or forced line breaks. | T |
