# North Dakota Court of Appeals: briefs

Alias `ndctapp`. Scope: the principal and reply briefs filed in a case the North Dakota Supreme Court has assigned to the temporary Court of Appeals: opening (appellant's) brief, answering (appellee's) brief and reply brief. North Dakota has no standing intermediate appellate court; the temporary Court of Appeals hears only assigned cases, and every filing in an assigned case goes to the Clerk of the Supreme Court under the Supreme Court number (NDADMIN Rule 27, sec. 9(a)). The filed exemplars are therefore captioned "In the Supreme Court" and the Rules of Appellate Procedure govern their form. Verified against the North Dakota Rules of Appellate Procedure as published on the court's site (Rule 28 effective 9/1/2026; Rule 32 effective 4/1/2024) and N.D.Sup.Ct.Admin.R. 27 (effective 8/11/2021) on 2026-10-21. The Supreme Court sheet is `nd`.

The site www.ndcourts.gov returned HTTP 403 to direct `curl` and to WebFetch on 2026-10-21; every rule text below was read through the r.jina.ai reader (HTTP 200) of the same ndcourts.gov URL. The 2005 exemplars were filed under earlier editions of Rules 28 and 32; the current text decides the layout and the exemplars settle only what the rules leave open.

## Sources

| Tag | Source | URL |
|---|---|---|
| NDRAP28 | N.D.R.App.P. Rule 28, Briefs (effective 9/1/2026) | https://www.ndcourts.gov/legal-resources/rules/ndrappp/28 |
| NDRAP32 | N.D.R.App.P. Rule 32, Form of Briefs and Other Documents (effective 4/1/2024) | https://www.ndcourts.gov/legal-resources/rules/ndrappp/32 |
| NDADMIN27 | N.D.Sup.Ct.Admin.R. 27, Court of Appeals (effective 8/11/2021) | https://www.ndcourts.gov/legal-resources/rules/ndsupctadminr/27 |

## Form (all doc types)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NDCTAPP-FORM-001 | Brief on 8½ by 11 inch paper; only one side of a paper is used; clear black image on white paper. | NDRAP32(a)(1)(A), (a)(4) | M |
| NDCTAPP-FORM-002 | Margins at least one and one-half inch at the left and at least one inch on all other sides. | NDRAP32(a)(4) | M |
| NDCTAPP-FORM-003 | Pages numbered at the bottom, centered or at the right; numbering begins on the cover page with the arabic number 1 and continues consecutively to the end. | NDRAP32(a)(4) | M |
| NDCTAPP-FORM-004 | Typeface 12 point or larger, no more than 16 characters per inch. | NDRAP32(a)(5) | M |
| NDCTAPP-FORM-005 | Text double-spaced; headings and quotations may be single-spaced and indented; footnotes double-spaced and in the same typeface as the text. | NDRAP32(a)(5) | M |
| NDCTAPP-FORM-006 | Plain roman style; italics or boldface only for emphasis; case names italicized or underlined. | NDRAP32(a)(6) | M |
| NDCTAPP-FORM-007 | Paragraphs are numbered with arabic numerals; references to a document that has paragraph numbers are to the paragraph number. | NDRAP32(a)(7) | M |
| NDCTAPP-FORM-008 | Principal brief at most 38 pages; reply brief at most 12 pages; footnotes count; any addendum is excluded. | NDRAP32(a)(8)(A) | M |
| NDCTAPP-FORM-009 | Cover color (blue appellant, red appellee, gray reply) is affixed by the Supreme Court when the brief is filed electronically. | NDRAP32(a)(2) | M |
| NDCTAPP-FORM-010 | Binding is done by the Supreme Court when the brief is filed electronically. | NDRAP32(a)(3) | M |
| NDCTAPP-FORM-011 | A brief that does not comply with Rule 32 is not filed. | NDRAP32(c) | M |
| NDCTAPP-FORM-012 | All appellate documents in an assigned case are filed with the Clerk of the Supreme Court; none is filed with the Court of Appeals. | NDADMIN27 sec. 9(a) | M |
| NDCTAPP-FORM-013 | Typeface family, centered bold capital section headings and caption style follow the filed exemplars where the rules are silent. | exemplars (usage/SOURCE.md) | C |

## Appellate briefs (opening, answering, reply)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NDCTAPP-COVER-001 | Front cover shows the number of the case, the name of the court, the title of the case, the nature of the proceeding and the court, agency or board below, the title of the brief identifying the party for whom it is filed, and counsel's name, bar identification number, office address and telephone number. | NDRAP32(a)(2)(A)-(F) | M |
| NDCTAPP-COVER-002 | A party who wants oral argument places the words "ORAL ARGUMENT REQUESTED" conspicuously on the cover of the appellant's, appellee's or cross-appellee's reply brief. | NDRAP28(h) | M |
| NDCTAPP-CONT-001 | Appellant's brief, in this order under appropriate headings: table of contents with paragraph references; table of authorities (cases alphabetically, statutes, other authorities) with paragraph references; statement of the issues; statement of the case; statement of the facts with record references; argument; short conclusion stating the precise relief sought. | NDRAP28(b)(1)-(7) | M |
| NDCTAPP-CONT-002 | The argument gives, for each issue, the standard of review and the record citation showing the issue was preserved (or the grounds for reviewing an unpreserved issue). | NDRAP28(b)(7)(B) | M |
| NDCTAPP-CONT-003 | Appellee's brief follows the appellant's contents, but the issues, case, facts and standard-of-review statements need not appear unless the appellee is dissatisfied with the appellant's statement. | NDRAP28(c) | M |
| NDCTAPP-CONT-004 | Reply brief contains a table of contents with paragraph references and a table of authorities with references to paragraphs of the reply brief. | NDRAP28(d) | M |
| NDCTAPP-CONT-005 | Record references follow Rule 30. | NDRAP28(f)(1) | M |
| NDCTAPP-CERT-001 | Certificate by the attorney or self-represented party that the brief complies with the page limitation, stating the number of pages, relying on the page count of the filed electronic document. | NDRAP32(d) | M |
| NDCTAPP-CONT-006 | Table of contents and table of authorities list page numbers instead of paragraph numbers in this template: the template does not number paragraphs itself, so paragraph numbers are typed in the INPUT as the filer typed them and the references are pages. OPEN against NDCTAPP-CONT-001, -004. | template | T |

## Template-only requirement

| ID | Requirement | Kind |
|---|---|---|
| NDCTAPP-TPL-001 | A reusable template contains no case-specific text, measured coordinates or forced line breaks. | T |

Not built (no court-root exemplar): motion, petition for writ and amicus brief for this court. Motions and writ petitions in an assigned case are filed with the Clerk of the Supreme Court (NDADMIN27 sec. 9(a)); see the `nd` sheet. Local rules not retrieved: none beyond the 403 noted above (https://www.ndcourts.gov/legal-resources/rules/ndrappp/32, 403 direct; 200 via r.jina.ai).
