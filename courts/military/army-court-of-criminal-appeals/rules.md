# U.S. Army Court of Criminal Appeals (opening brief, answering brief): rules

Alias `acca`. Scope: the brief on behalf of an appellant with assignments of error (`opening-brief/`) and the brief on behalf of the appellee United States answering them (`answering-brief/`), filed electronically by appellate counsel. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 and whenever the court posts new Rules of Appellate Procedure on its JAGCNet page (the edition read here is "Effective: 15 January 2019"; a newer edition could not be checked, see Access note).

Access note: on 2026-10-17 `www.jagcnet.army.mil` returned an HTTP 403 page for the rules PDF. The rules were read from the Internet Archive capture of the court's own URL, taken 2025-07-29; it is the only capture of that URL and the only rules file under `jagcnet.army.mil/Home/assets/pdf/court/` in the CDX index. Whether the court adopted a later edition after July 2025 is not verified.

## Sources

| Tag | Source | URL |
|---|---|---|
| ACCA-R | United States Army Court of Criminal Appeals Rules of Appellate Procedure, "Effective: 15 January 2019", "Published Together with the Joint Rules of Appellate Procedure" (JRAP in boldface) (68 pp., scanned with OCR text layer) | https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf (read from https://web.archive.org/web/20250729125903/https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf) |
| APP-A | ACCA-R Appendix A, "Format for Brief on Behalf of Appellant" | same PDF |
| EX-AKBAR-OB | Brief on behalf of appellant, *United States v. Akbar*, ARMY 20050514 (Defense Appellate Division), 2010 | `opening-brief/usage/` |
| EX-AKBAR-AB | Brief on behalf of appellee, *United States v. Akbar*, ARMY 20050514 (Government Appellate Division), 2010 | `answering-brief/usage/` |

Kinds: **M** = mandated by a rule (ACCA Rules or JRAP). **C** = convention (from the exemplars). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **Times New Roman 14 point is named**: an electronic filing "will use a font of Times New Roman 14-point" (Rule 13.2), double-spaced, 1 inch margins; not "any proportional face".
2. **One PDF per filing, appendices combined**: "Any appendix or attachment to the pleading will be combined with the pleading into a single .pdf file" (Rule 13.2), one filing per e-mail (Rule 13.2(e)), with fixed e-mail subject and file-name patterns (Rule 13.2(a)-(c)).
3. **Page limit 50 pages**, excluding tables and appendices; table of contents and table of authorities above 30 pages (Rule 17.3).
4. **Certificate of service on the next page after the signature block**, in the Rule 13.6 form (Rule 17.5).
5. **Assignments of error stated neutrally**, "capitalized and in bold type", consecutive roman numerals (Rule 17.1(d); Appendix A).

## Requirements: both doc types

### Page form and filing (Rules 13, 17)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ACCA-FORM-001 | Form, content and space limits are set by each Service Court's rules. | Rule 17 (JRAP text) | M |
| ACCA-FORM-002 | "Any filing submitted electronically shall be converted into a single .pdf formatted file (without scanning, if practical, to reduce overall file size), typed, and double-spaced." | Rule 13.2 | M |
| ACCA-FORM-003 | "The filing will use a font of Times New Roman 14-point so as to produce a clear black image on a single-side of white 8.5-inch by 11-inch paper. The margins shall be set to 1-inch on all four sides." | Rule 13.2; Rule 17.1(b) (paper filings: same) | M |
| ACCA-FORM-004 | Any appendix or attachment is combined with the pleading into the single PDF. | Rule 13.2 | M |
| ACCA-FORM-005 | E-mail subject "LAST NAME-ACMIS Number-Filing Title-(YYMMDD)"; prescribed e-mail narrative certifying transmission; PDF file name "Last Name-ACMIS #-Filing Title-(YYMMDD)"; one filing per e-mail. | Rule 13.2(a)-(c), (e) | M (filing metadata) |
| ACCA-FORM-006 | Citations per the Army Court of Criminal Appeals Citation Guide, the JAG School Military Citation Guide and The Bluebook. | Rule 17.1(c) | A |
| ACCA-FORM-007 | Personal and sensitive information removed: names of complainants, victims, law-enforcement agents and (for closed-session testimony) witnesses by rank and initials; SSN, account and telephone numbers to the last four digits; home address to city and state; personal e-mail masked; birth dates to the year. | Rule 17.2(c) | A |
| ACCA-FORM-008 | Face seen: Times (OCR scans) in both Akbar exemplars; their line pitch is not measurable from the OCR layer. One filer per side. | exemplars | C |
| ACCA-FORM-009 | Every font embedded and of the template's declared family. | project | T |
| ACCA-LEN-001 | "Briefs must not exceed 50 pages in length excluding tables and appendices"; longer only on a motion showing good cause. | Rule 17.3(b) | M |
| ACCA-CONT-001 | "Any brief in excess of 30 pages must include a table of contents ..., along with a table of cases (alphabetically arranged), statutes and other authorities cited, and references to the pages of the brief where cited." | Rule 17.3(a)-(b) | M (conditional) |

### Signature and service (Rules 13.5, 13.6, 14, 17.5)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ACCA-ELEC-001 | "All formal papers shall be signed, either by hand or electronically, and shall include, at a minimum, the signer's name, military grade (if applicable), email address, and the capacity in which the paper is signed." | Rule 14 (JRAP text) | M |
| ACCA-ELEC-002 | Counsel of record may sign with any commonly accepted mark representing a scanned or electronic signature; non-federal civilian counsel also give firm, mailing address, telephone and e-mail below the signature line. | Rule 14.1 | M |
| ACCA-ELEC-003 | Appendix A signature block: signature; name, rank and branch of military counsel (or civilian counsel's name); title; organization; phone and e-mail if civilian counsel. | APP-A | M |
| ACCA-CERT-001 | Certificate of Service "on the next page after the signature block", in the form: "I certify that a copy of the foregoing was (mailed) (delivered) (sent via electronic submission) to ____ at ____ on the ___ day of ____, 20__." with the certifier's signature, typed name, organization or firm, address, telephone and e-mail; service on civilian counsel shows contemporaneous service on associated military counsel. | Rule 13.6; Rule 17.5; Rule 13.5 | M |

### Caption (Appendix A)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ACCA-COVER-001 | "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS"; left column "UNITED STATES, Appellee / v. / [Rank of Appellant] [NAME OF APPELLANT] United States Army, Appellant"; right column "BRIEF ON BEHALF OF APPELLANT", "Docket No. ARMY 20XXXXXX", "Tried at [location], on [dates], before a [general/special] court-martial appointed by [convening authority], [military judge] presiding."; "Panel X"; then "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS". | APP-A | M |

## Doc type: opening-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ACCA-CONT-010 | Pleadings raising assignments of error follow Rule 13 and Appendix A: "Assignment(s) of Error" (each capitalized and in bold, consecutive roman numerals); "Statement of the Case" (chronology, charges, pleas, findings, sentence, convening authority action); "Statement of Facts" (page references and exhibit designations); "Argument" (each assignment of error in bold, separate argument, standard of review, followed by a prayer for the specified relief); optional "Appendix"; signature; Certificate of Service. | Rule 17.1(a); Rule 18.1; APP-A | M |
| ACCA-CONT-011 | Assignments of error are stated in a neutral manner, argument saved for the body. | Rule 17.1(d) | A |
| ACCA-CONT-012 | Grostefon issues by footnote or in an appendix to the appellant's brief, citing United States v. Grostefon, submitted with the brief, in the same typeface and size as the brief. | Rule 18.2(a)-(d) | M (conditional) |
| ACCA-CONT-013 | A brief for the accused is filed within 60 days after counsel is notified of referral; a supplemental brief only by motion for leave. Merits ("pro forma") pleadings follow Appendix B (other doc type). | Rule 18(d) (JRAP text); Rule 17.1(e); Rule 17.4 | A |

## Doc type: answering-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ACCA-CONT-020 | The answer uses the Appendix A structure; it may adopt the appellant's statement of facts, state additional facts, or restate disputed facts; after restating an assignment of error it may restyle it to reflect the issue in controversy. | APP-A (Statement of Facts note); Rule 17.1(d) | M |
| ACCA-CONT-021 | Appellate government counsel files the answer within 30 days after the appellant's brief; a reply may follow within 7 days. | Rule 18(d) (JRAP text) | A |
| ACCA-CONT-022 | Caption in the Appendix A form with "BRIEF ON BEHALF OF APPELLEE" (EX-AKBAR-AB). One filer: that filer's style. | EX-AKBAR-AB | C (one filer) |

## Not verified

- Whether a rules edition later than 15 January 2019 is in force (see Access note).
- The Army Court of Criminal Appeals Citation Guide (Rule 17.1(c)) was not read.
- Each doc type has one filed exemplar (both from *Akbar*, 2010, scanned with OCR). A second filer was searched for on 2026-10-17 (web searches for public ACCA appellant briefs in *Manning* (ARMY 20130739), *Bergdahl* and *Hasan*: only CAAF-level briefs and an ACCA amicus brief were found; the prior pass's Internet Archive CDX search of `jagcnet.army.mil` found only *Akbar* and image-only *Gray* briefs). Recorded in `docs/box-blocked.md`.
