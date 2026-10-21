# Court of Criminal Appeals of Tennessee: briefs and motions

Alias `tenncrimapp`. Scope: appellant's and appellee's briefs, amicus briefs, and motions with supporting memoranda filed in the Court of Criminal Appeals. Verified against Tenn. R. App. P. 20, 27, 30, Tenn. Sup. Ct. R. 46 and Rules of the Court of Criminal Appeals, Rule 10, as shown on the Tennessee Administrative Office of the Courts site (Internet Archive captures listed below) on 2026-10-21.

Live-host note: the live tncourts.gov rule pages (https://www.tncourts.gov/rules/rules-appellate-procedure, https://www.tncourts.gov/courts/supreme-court/rules/supreme-court-rules/rule-46-electronic-filing) answered HTTP 200 only with a JavaScript proof-of-work challenge page, so the rule text was read from the Internet Archive captures below. The live host was not retried after that.

Governing rule for e-filed documents: Tenn. Sup. Ct. R. 46 section 3.01(a) says that for e-filed documents its formatting provisions control over any conflicting procedural rule, and that the paper-copy rules on number of copies, cover color and paper type do not apply. Filing is voluntary (Rule 46, section 1), so this file records both. The template implements the e-filed format (Rule 46, section 3.02) and the exemplars (the 2026 opening brief is e-filed Century Schoolbook at 14 point). Paper copies would need double spacing and cover colors under Tenn. R. App. P. 30(a) and (c); see the ACCEPTED row TENNCRIMAPP-FORM-010.

Font decision: the court's rule names a face family, "any font within the Century Family" (Rule 46, section 3.02(3)(a)). The template declares TeX Gyre Schola, the GUST clone of Century Schoolbook, as in the other Century-family courts in this repo (docs/FONTS.md). Times New Roman and Liberation Serif are not used. The size is 14 point, which is stricter than the 12 point default floor, so `eval.yaml` states `font.size_pt: 14`.

Limits: no limit was loosened. Word limits are checked against the word-count certificate, not pages, so no `page_limit` is set. The motion has no word limit in the sources read; no limit is set for it, and that is recorded as ACCEPTED.

## Sources

| Tag | Source | URL |
|---|---|---|
| TRAP-30 | Tenn. R. App. P. 30, Form of Briefs and Other Papers (text as amended through July 1, 2022), Tennessee AOC; Internet Archive capture 2026-01-13 | https://web.archive.org/web/20260113194158/https://www.tncourts.gov/courts/rules-appellate-procedure/rules/rules-appellate-procedure-rules/rule-30-form-briefs-and |
| TRAP-27 | Tenn. R. App. P. 27, Content of Briefs (amended by order filed December 14, 2021, effective July 1, 2022), Tennessee AOC; Internet Archive capture 2026-01-13 | https://web.archive.org/web/20260113194158/https://www.tncourts.gov/courts/rules-appellate-procedure/rules/rules-appellate-procedure-rules/rule-27-content-briefs |
| TRAP-20 | Tenn. R. App. P. 20, Filing and Service (subdivision (e), proof of service), Tennessee AOC; Internet Archive capture 2026-01-13 | https://web.archive.org/web/20260113194158/https://www.tncourts.gov/courts/rules-appellate-procedure/rules/rules-appellate-procedure-rules/rule-20-filing-and-service |
| SCT-46 | Tenn. Sup. Ct. R. 46, Electronic Filing (as amended by order filed July 7, 2022), Tennessee Supreme Court; Internet Archive capture 2026-04-20 | https://web.archive.org/web/20260420005139/https://www.tncourts.gov/courts/supreme-court/rules/supreme-court-rules/rule-46-electronic-filing |
| CCA-10 | Rules of the Court of Criminal Appeals, Rule 10, Inadequate Briefs; Internet Archive capture 2025-08-10 | https://web.archive.org/web/20250810232041/https://tncourts.gov/courts/court-criminal-appeals/rules/court-criminal-appeals-rules/rule-10-inadequate-briefs |

## Form (all e-filed documents: briefs and motions)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-FORM-001 | Pages are 8½ × 11 inch (US letter). | TRAP-30 (a); SCT-46 3.02 | M |
| TENNCRIMAPP-FORM-002 | Margins are 1 inch on all sides. | SCT-46 3.02(2)(b) | M |
| TENNCRIMAPP-FORM-003 | Body text is 1.5-spaced (SCT-46 3.02(2)(a)). Block quotations, headings, captions, footnotes and the table of contents and authorities are single-spaced, as the paper rule's quoted-matter exception and the exemplars show. | SCT-46 3.02(2)(a); TRAP-30 (a) (quoted matter) | M (body); C (single-spaced parts) |
| TENNCRIMAPP-FORM-004 | Typeface is any font within the Century family. The template declares TeX Gyre Schola (Century Schoolbook clone). | SCT-46 3.02(3)(a) | M |
| TENNCRIMAPP-FORM-005 | Font size is 14 point; footnotes are in the same font and size as the text. | SCT-46 3.02(3)(b)-(c) | M |
| TENNCRIMAPP-FORM-006 | Text is fully justified. | SCT-46 3.02(4) | M |
| TENNCRIMAPP-FORM-007 | Pagination begins with page 1, which is the cover; every page carries an Arabic page number at the bottom. | SCT-46 3.02(5); TRAP-30 (a) (numbered on the bottom) | M |
| TENNCRIMAPP-FORM-008 | The e-filed PDF is made by direct conversion from the word-processing file (not a scan of paper) and is text-searchable. Attachments that are photocopies may be scanned. | SCT-46 3.02(2)(b) | M |
| TENNCRIMAPP-FORM-009 | Internal hyperlinks and bookmarks are encouraged; an external link does not replace the full citation in the text. | SCT-46 3.02(6)-(7) | A |
| TENNCRIMAPP-FORM-010 | Paper copies (not e-filed): double spacing, computer-generated text not smaller than Times New Roman 12 point, numbered at the bottom, fastened on the left, and covers colored by party (appellant blue, appellee red, reply gray, amicus green) if available. The e-filing rule displaces the paper spacing and cover color for e-filed documents (SCT-46 3.01(a)). This template produces the e-filed form only. | TRAP-30 (a), (c); SCT-46 3.01(a) | A (ACCEPTED: out of scope for the e-filed template) |

## Cover page (briefs and motions)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-COVER-001 | The cover shows the case number and the name of the court, "IN THE COURT OF CRIMINAL APPEALS OF TENNESSEE" with the session seat (for example "AT KNOXVILLE") as the exemplars show. | TRAP-30 (b)(1) | M (name of court); C (session seat) |
| TENNCRIMAPP-COVER-002 | The title of the case as it appeared in the trial court, with each party's status in this court (Petitioner/Appellant, Defendant/Appellant, Plaintiff/Appellee, Appellee, Amici). | TRAP-30 (b)(2) | M |
| TENNCRIMAPP-COVER-003 | The nature of the proceeding and the name of the court, agency or board below (for example "Appeal from a Jury Verdict of the Criminal Court for Knox County"). | TRAP-30 (b)(3) | M |
| TENNCRIMAPP-COVER-004 | The title of the document (for example "Brief of Amici Curiae"). | TRAP-30 (b)(4) | M |
| TENNCRIMAPP-COVER-005 | The name and address of counsel, or of the party when unrepresented. | TRAP-30 (b)(5) | M |
| TENNCRIMAPP-COVER-006 | Cover colors (appellant blue, appellee red, reply gray, amicus green) when available. | TRAP-30 (c) | A (ACCEPTED: paper-copy rule, see TENNCRIMAPP-FORM-010) |

## Captions on other papers (motions)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-CAP-001 | A paper other than a brief carries a caption: the court and the case number, the title of the case as in the trial court, and a brief descriptive title of its purpose. The motion template puts this on the cover. | TRAP-30 (d) | M |

## Opening (appellant's) brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-SEC-001 | Order of contents: table of contents; table of authorities; statement of the issues presented for review; statement of the case; statement of facts; argument (with the standard of review for each issue, under a heading or in the discussion); short conclusion stating the precise relief sought. The jurisdictional statement (27(a)(3)) applies only to direct appeals to the Supreme Court and is not used here. | TRAP-27 (a)(1)-(8) | M |
| TENNCRIMAPP-SEC-002 | The table of contents gives the page of each heading in the brief. | TRAP-27 (a)(1) | M |
| TENNCRIMAPP-SEC-003 | The table of authorities lists cases alphabetically, then statutes and other authorities, with the pages on which each is cited. | TRAP-27 (a)(2) | M |
| TENNCRIMAPP-SEC-004 | Citation form: cases by title, to the page where the case begins, with the year of decision; Tennessee statutes to Tennessee Code Annotated; a supplement is identified as such. | TRAP-27 (h) | M |
| TENNCRIMAPP-SEC-005 | References to the record are to the record page numbers. | TRAP-27 (g) | M |
| TENNCRIMAPP-SEC-006 | Constitutional provisions, statutes and rules needed for the decision are reproduced in pertinent part in the brief or in an addendum. | TRAP-27 (e) | M (when the issue requires it) |
| TENNCRIMAPP-SEC-007 | Argument headings use a consistent outline (I., A., 1., a.) with the heading text following the label; section headings are centered in capitals. | TRAP-27 (a)(7); exemplars | C |
| TENNCRIMAPP-LEN-001 | Principal brief: 15,000 words. The cover, table of contents, table of authorities, certificate of compliance, signature block and certificate of service are excluded from the count. Applies to the appellant's and the appellee's principal brief. | TRAP-30 (e)(1); SCT-46 3.02(1)(a) | M |

## Appellee's (answering) brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-SEC-008 | The appellee's brief conforms to the appellant's requirements, except that items 27(a)(3)-(6) and the standard-of-review item need not be included unless the appellant's presentation is unsatisfactory. The template keeps the full structure, as the 2015 exemplar does. | TRAP-27 (b) | C |
| TENNCRIMAPP-LEN-002 | Appellee's principal brief: 15,000 words, as above. | TRAP-30 (e)(1); SCT-46 3.02(1)(a) | M |

## Amicus curiae brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-LEN-003 | Amicus brief: 7,500 words, with the same exclusions. | TRAP-30 (e)(3); SCT-46 3.02(1)(c) | M |
| TENNCRIMAPP-SEC-009 | Amicus brief follows the cover, table, and certificate rules of this file; the sections of TRAP 27(a) are not mandated for amici and the amicus exemplar's table of contents (statement of interest, issue presented, summary, background, argument, conclusion) is followed. | TRAP-30 (b), (e); exemplars | C |

## Motion with supporting memorandum

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-LEN-004 | No word limit for motions is set in the sources read (TRAP 30(e) limits briefs and other specifically referenced papers only; the local motion rule was not retrieved). The template sets no limit and states none. | TRAP-30 (e); SCT-46 3.02(1) | A (ACCEPTED: no rule figure) |
| TENNCRIMAPP-SEC-010 | A motion states the relief sought and the grounds, with its supporting argument. The exemplar motion (leave to file amicus brief) has no table of contents or table of authorities; the template omits them for motions. | exemplars | C |

## Certificates, signature and service (all briefs and motions)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-CERT-001 | An e-filed brief includes a certificate of compliance that states the number of words in the brief; the count may come from the word-processing program. | SCT-46 3.02(2)(c); TRAP-30 (e) | M |
| TENNCRIMAPP-CERT-002 | A proof of service states the date and manner of service and the names of the persons served, certified by the person who made service. | TRAP-20 (e) | M |
| TENNCRIMAPP-CERT-003 | The e-filer's electronic signature appears at the end of the document, followed by the user's name, business address, telephone number, e-mail address and Board of Professional Responsibility number. | SCT-46 3.04 | M |
| TENNCRIMAPP-CERT-004 | Papers presented for filing are served on every party (proof of service in the form above). | TRAP-20 (e) | M |

## Filings that the court does not receive (not in this template)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TENNCRIMAPP-OUT-001 | Reply briefs (TRAP 27(c); 5,000 words under TRAP 30(e)(2)) have no exemplar in usage/; no reply-brief folder is built. | TRAP-27 (c); TRAP-30 (e)(2) | A |
| TENNCRIMAPP-OUT-002 | Petitions for discretionary review, for writ and for rehearing have no public exemplar for this court (usage/SOURCE.md); no folder is built. Review of this court's decisions is sought by Rule 11 application in the Supreme Court. | usage/SOURCE.md | A |

## Template-only requirement

| ID | Requirement | Kind |
|---|---|---|
| TENNCRIMAPP-TPL-001 | A reusable template contains no case-specific text, measured coordinates, or forced line breaks. | T |
| TENNCRIMAPP-TPL-002 | Stated numbers (14-point size, 1-inch margins, 1.5 spacing, word limits) trace to the rules above; word limits are applied to the count of the text in the markdown, not to a figure typed by hand. | T |
