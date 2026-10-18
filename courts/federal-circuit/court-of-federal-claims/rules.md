# United States Court of Federal Claims (complaint, motion brief): rules

Alias `uscfc`. Scope: papers filed by counsel in an ECF case in the United States Court of Federal Claims: the complaint (`complaint/`) and a dispositive motion with its supporting brief or memorandum (`motion-brief/`: a motion for judgment on the administrative record under RCFC 52.1(c), and by extension the other RCFC 7.2(b) motions under RCFC 12(b), 12(c) and 56). Vaccine Act petitions (Appendix B) and pro se filings are out of scope. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each August 1 (the court's rule amendments take effect in late July: July 31, 2023; July 29, 2024; July 28, 2025; July 27, 2026, per the amendment dates printed under each rule) and whenever the court posts a "Notice of Proposed Rules Amendments" (posted each May or June, e.g. "26.05.18 Notice of Proposed Rules Amendments").

## Sources

| Tag | Source | URL |
|---|---|---|
| RCFC | Rules of the United States Court of Federal Claims, "As amended through July 27, 2026" (PDF; ModDate 2026-10-08; sha256 `943733526f5391cad22562adf31411148fecfb03f01ae7bcf8bd6ec051a0c971`). Page numbers below are the printed page numbers. Read in full for the rules cited. Copy read: the live court URL fetched with the WebFetch tool on 2026-10-17 (plain `curl` from this box gets HTTP 404 from every uscfc.uscourts.gov page); cached outside the repo at `/work/artifacts/rules-cache/uscfc/rules-10.08.26.pdf`. | https://www.uscfc.uscourts.gov/sites/cfc/files/Rules%2010.08.26.pdf |
| APP-C | RCFC Appendix C, "Procedure in Procurement Protest Cases Pursuant to 28 U.S.C. § 1491(b)" (in the RCFC PDF above) | same |
| APP-E | RCFC Appendix E, "Electronic Filing Procedures", pp. 160-164 (in the RCFC PDF above) | same |
| EX-DB | Complaint, *Design Build, LLC v. United States*, No. 26-1361 C (Watt, Tieder, Hoffar & Fitzgerald) | `complaint/usage/` |
| EX-MTA | Complaint, *Metropolitan Transportation Authority v. United States*, No. 26-422 C (Kaplan Martin LLP) | `complaint/usage/` |
| EX-OFN | Complaint for Relief, *Opportunity Finance Network v. United States*, No. 26-1324 C (Jenner & Block LLP) | `complaint/usage/` |
| EX-ORACLE | Motion and Memorandum for Judgment on the Administrative Record, *Oracle America, Inc. v. United States*, No. 18-1880C, bid protest (Arnold & Porter Kaye Scholer LLP). Memorandum pages are scanned images. | `motion-brief/usage/` |
| EX-US | Defendant's Motion to Dismiss and in the Alternative Motion to Strike, *Sublime Systems, Inc. v. United States*, No. 26-458 (U.S. Department of Justice, Commercial Litigation Branch) | `motion-brief/usage/` |

Kinds: **M** = mandated by a rule of this court (RCFC or one of its appendices). **C** = convention (the rules leave it open; taken from the exemplars, with the filers that show it). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

The rules are the court's own: the RCFC incorporate the Federal Rules of Civil Procedure only "to the extent appropriate" (preface, p. i), so every requirement below cites the RCFC text, not the FRCP.

Findings that differ from what many templates assume:

1. **No typeface is named.** RCFC 5.5(c)(2) sets only a minimum size: "The type size for text and footnotes must be no smaller than 12 point." A search of the whole PDF finds no font name. Times New Roman is a convention (every exemplar), not a rule.
2. **Page limits, not word limits.** RCFC 5.4(b): initial brief 40 pages (50 for a cross-movant), reply 20 (30 with a response included), excluding only the table of contents, the table of citations and any appendix. No certificate of compliance exists in this court.
3. **Every page is numbered, centered at the bottom.** RCFC 5.5(c)(6): "All pages, including appendices, must be numbered in large distinct type that appears in the center of the bottom margin of the page." EX-US leaves its cover unnumbered and numbers its front matter in roman; the rule text gives no exception for a cover.
4. **Judge's name under the docket number** in every filing other than the complaint (RCFC 5.5(g)); "Bid Protest" directly under the court name in every filing in a bid protest (RCFC 5.5(h)).
5. **No certificate of service for ECF-served papers.** RCFC 5(d)(1)(B) and APP-E ¶14(b)(i): the Notice of Electronic Filing is service and proof of service. The complaint is served on the United States by the clerk (RCFC 4(a)).
6. **E-mail and telephone directly below the signature line** of every filing (RCFC 5.5(f)), and the signing date on the signature page (RCFC 5.5(e)).

Not verified (not written as requirements): the current ECF file-size limit (APP-E ¶11(b)(iii)(B) says it "is posted on the court's website", which this box could not read); the citation formats for ECF documents (RCFC 5.4(c)(2)(B), same); the full text of RCFC 7.1 (the PDF's text layer for that rule is broken; only its heading and first words extract). The doc-type READMEs use their own `CFC-*` and `RCFC-*` row labels; the IDs below are the stable ones.

## Requirements: court-wide (both doc types)

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (RCFC 5.5)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-FORM-001 | Every page is 8 1/2 by 11 inch (612 x 792 pt): papers "must be printed on 8 1/2 by 11-inch paper". | RCFC 5.5(c)(1)(A), p. 10 | M |
| USCFC-FORM-002 | Type size: "The type size for text and footnotes must be no smaller than 12 point." Applies to body text and footnotes. The rule names no typeface. | RCFC 5.5(c)(2), p. 10 | M |
| USCFC-FORM-003 | Margins: "Margins must not be less than 1 inch on each side." Page numbers sit in the bottom margin (USCFC-FORM-005); no other text may. | RCFC 5.5(c)(3), p. 10 | M |
| USCFC-FORM-004 | Spacing: "Text must be double spaced, except that quoted and indented material and footnotes may be single spaced." Headings, captions, tables and signature blocks are not named as exceptions; single-spacing them is a convention (USCFC-FORM-009). | RCFC 5.5(c)(4), p. 10 | M |
| USCFC-FORM-005 | Numbering: "All pages, including appendices, must be numbered in large distinct type that appears in the center of the bottom margin of the page." The first page and any cover are included. | RCFC 5.5(c)(6), p. 10 | M |
| USCFC-FORM-006 | Clear black images on white paper; letter-quality type. For a generated PDF: black text on a white page. | RCFC 5.5(b), 5.5(c)(1)(B), p. 10 | M |
| USCFC-FORM-007 | Every font used is embedded and is the template's declared family (no silent fallback). | project; supports APP-E ¶11(a) | T |
| USCFC-FORM-008 | Typeface: Times New Roman (or a metric equivalent) at 12 pt. Seen in all five exemplars (EX-DB, EX-MTA, EX-OFN, EX-US by `pdffonts`; EX-ORACLE visually), so a convention across filers; any face of at least 12 pt satisfies USCFC-FORM-002. | EX-DB, EX-MTA, EX-OFN, EX-ORACLE, EX-US | C |
| USCFC-FORM-009 | Headings, caption, tables of contents/authorities and signature blocks single-spaced; numbered paragraphs and body text double-spaced; footnotes single-spaced. Seen in all five exemplars. | EX-DB, EX-MTA, EX-OFN, EX-ORACLE, EX-US | C |
| USCFC-FORM-010 | Paper binding ("secure, does not obscure text, and is easily removable") applies to paper filings only; not applicable to the ECF PDF. | RCFC 5.5(c)(5), p. 10 | M (paper only) |

### Caption (RCFC 5.5(g)-(h), 7(b)(2), 10(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-COVER-001 | Caption with "the court's name, a title, a file number, and a RCFC 7(a) designation". The rules governing captions in pleadings apply to motions and other papers. | RCFC 10(a), p. 19; RCFC 7(b)(2), p. 15 | M |
| USCFC-COVER-002 | Bid protest cases: the words "Bid Protest" "must be included in the caption of all filings directly below the name of the court." | RCFC 5.5(h), p. 10 | M (bid protests) |
| USCFC-COVER-003 | "In all filings other than the complaint, the name of the judge assigned to the case must be included directly below the docket number." | RCFC 5.5(g), p. 10 | M (all but the complaint) |
| USCFC-COVER-004 | Caption layout: court name centered in bold capitals at the top ("IN THE UNITED STATES COURT OF FEDERAL CLAIMS" in EX-DB, EX-ORACLE, EX-US; "UNITED STATES COURT OF FEDERAL CLAIMS" in EX-MTA, EX-OFN); parties in capitals in a left column separated from the right column by a vertical rule (EX-DB, EX-MTA, EX-OFN, EX-US) or a column of ")" (EX-ORACLE); docket number (and judge) in the right column; document title in bold capitals centered below the caption. Convention across filers; the exact rule drawing is each filer's style. | all five exemplars | C |
| USCFC-COVER-005 | The top of page 1 is left free for the ECF banner ("the filing date ... will appear at the top of the first page in an automatically generated banner stating the case number, the document number, and the date filed"). Covered by the 1-inch margin. | APP-E ¶19, pp. 163-164 | C |

### Signature and certificates (RCFC 5(d), 5.3, 5.5(e)-(f), 11(a), APP-E ¶20-22)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-CERT-001 | Every paper is signed by or for the attorney of record and states the signer's "address, e-mail address, and telephone number". | RCFC 11(a), p. 20 | M |
| USCFC-CERT-002 | ECF signature: a signature block "with the name of the Filing User under whose login and password the document is submitted along with an 's/[name of Filing User]' typed in the space where the signature would otherwise appear" (or a scanned written signature). | APP-E ¶21(a)-(b), p. 163 | M |
| USCFC-CERT-003 | "Each paper must bear the date it is signed on the signature page." | RCFC 5.5(e), p. 10 | M |
| USCFC-CERT-004 | "The electronic mail address and telephone number (including area code) of the attorney of record must appear directly below the signature line of every filing." | RCFC 5.5(f), p. 10 | M |
| USCFC-CERT-005 | Certificate of service: "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." When served by other means and filed, a certificate (day and manner of service, person served, method) is "attached to the end of any original filing" and filed with it. Template: off by default, on when the frontmatter asks for it. | RCFC 5(d)(1)(B), p. 4; RCFC 5.3(a)-(b) (as amended July 27, 2026), p. 8; APP-E ¶14(b)(i), p. 162 | M (conditional) |
| USCFC-CERT-006 | Multiple signers: either a scanned page with all written signatures, or an "s/[name of party]" for each with the filer's representation that the others consent. | APP-E ¶22, p. 163 | A |
| USCFC-CERT-007 | Signature block placed at the right half of the page after the conclusion or prayer, with "Respectfully submitted," and the "Dated:" line at the left or above. Seen in EX-DB, EX-MTA, EX-OFN, EX-US. | exemplars | C |

### Electronic filing (APP-E)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-ELEC-001 | Documents filed via ECF must be "converted into PDF" and "text searchable"; no tracking tags, embedded commands, passwords, access restrictions, security features or dynamic features. | APP-E ¶11(a)(i), p. 162 | M |
| USCFC-ELEC-002 | Documents "must not be scanned prior to filing unless the original documents are unavailable in electronic form." Check: text extracts on every page. | APP-E ¶11(a)(ii)(A), p. 162 | M |
| USCFC-ELEC-003 | Each PDF file must not exceed the court's posted size limit (value not verified, see "Not verified"); a filing may be split into several PDFs. | APP-E ¶11(b), p. 162 | M (limit value unverified) |
| USCFC-ELEC-004 | Exhibits and attachments are filed with the main document under one entry number, excerpted to what is germane and clearly identified. | APP-E ¶10(c), p. 161 | A |
| USCFC-ELEC-005 | A document (with exhibits) over 50 printed pages requires a paper courtesy copy to chambers, in RCFC 5.5(c) form. | APP-E ¶12, p. 162 | A |
| USCFC-ELEC-006 | Redact personal identifiers: last four digits of SSN/TIN and financial-account numbers, year of birth, minors' initials. | RCFC 5.2(a), p. 7; APP-E ¶28 | A |
| USCFC-ELEC-007 | Filing under seal requires leave; in bid protests a sealed complaint is marked to show the protected information and accompanied by a proposed redacted version. | APP-E ¶13, p. 162; APP-C ¶4-6 | A |

## Doc type: complaint

Scope: the complaint that initiates an action (RCFC 3), filed by counsel via ECF (APP-E ¶10(a)). Exemplars: EX-DB, EX-MTA, EX-OFN (three filers, three firms).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-CONT-001 | The title of the complaint "must name all the parties (see RCFC 20(a)), with the United States designated as the party defendant". | RCFC 10(a), p. 19 | M |
| USCFC-CONT-002 | Claims stated "in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | RCFC 10(b), p. 19 | M |
| USCFC-CONT-003 | Contents: (1) a short and plain statement of the grounds for the court's jurisdiction; (2) a short and plain statement of the claim showing entitlement to relief; (3) a demand for the relief sought. Template checks that a jurisdiction section and a relief section exist; their content is the author's. | RCFC 8(a)(1)-(3), p. 16 | M (presence); A (content) |
| USCFC-CONT-004 | Special matters the complaint must plead when they apply: tax refund particulars and sealed/redacted filing (RCFC 9(m)), assignment of the claim (9(n)), action by another tribunal or body (9(o)), and prior litigation with its effect on jurisdiction (9(p)). | RCFC 9(m)-(p), p. 18 | A |
| USCFC-CONT-005 | No judge line is required on the complaint (RCFC 5.5(g) exempts it). EX-DB prints a blank "Judge: ____" line; EX-MTA and EX-OFN print none. The blank judge line is one filer's style. | RCFC 5.5(g); EX-DB vs EX-MTA, EX-OFN | M (exemption); C (omit) |
| USCFC-CONT-006 | Docket number left blank for the clerk ("No. ____" / "Case No. ____"); the clerk stamps the number on filing. Seen in EX-DB, EX-MTA, EX-OFN. | exemplars | C |
| USCFC-CONT-007 | Title "COMPLAINT" (EX-DB, EX-MTA) or "COMPLAINT FOR RELIEF" (EX-OFN), bold capitals, centered; section headings in bold capitals centered (EX-DB, EX-MTA underline them; EX-OFN does not: underlining is a filer style). Paragraph numbers at the first-line indent, continuing through the whole complaint across sections (all three). | exemplars | C |
| USCFC-CONT-008 | Prayer for relief ("WHEREFORE" or a "PRAYER FOR RELIEF"/"REQUEST FOR RELIEF" heading) with lettered or numbered items, before the signature. Seen in EX-DB, EX-MTA, EX-OFN. | exemplars; supports RCFC 8(a)(3) | C |
| USCFC-CERT-010 | No certificate of service: the clerk serves the complaint on the Attorney General and the docket entry is proof of service. EX-DB nevertheless attaches one (that filer's style); EX-MTA and EX-OFN do not. | RCFC 4(a)-(c), p. 3; EX-DB vs EX-MTA, EX-OFN | M (not required); C (omit) |
| USCFC-CERT-011 | Civil cover sheet (Appendix of Forms, Form 2) filed with the complaint, as a separate document; not part of the complaint PDF. | RCFC 5.5(d)(1)(A)(ii), (d)(1)(B), p. 10 | A |
| USCFC-CERT-012 | Disclosure statement of a nongovernmental corporate party: a separate filing under RCFC 7.1; not part of the complaint. (Rule text only partly readable in the PDF; see "Not verified".) | RCFC 7.1(a), p. 15 | A |
| USCFC-CONT-009 | Bid protest complaint: an application for a TRO or preliminary injunction is filed together with the complaint with supporting papers and a statement of service on DOJ's Commercial Litigation Branch; the apparently successful offeror is named if known. | APP-C ¶10-11 | A |
| USCFC-LEN-001 | No page or word limit applies to a complaint (RCFC 5.4(b) limits briefs and memoranda only). | RCFC 5.4(b), pp. 8-9 | M (no limit) |

## Doc type: motion-brief

Scope: a dispositive motion (RCFC 52.1(c) judgment on the administrative record; also RCFC 12(b), 12(c), 56) filed with its supporting brief or memorandum, either as one document (EX-US) or as a short motion plus a memorandum (EX-ORACLE). Exemplars: EX-ORACLE (plaintiff, Arnold & Porter, bid protest JAR motion) and EX-US (defendant United States, DOJ, motion to dismiss).

### Length (RCFC 5.4(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-LEN-010 | Initial brief or memorandum: at most 40 pages (50 for a cross-movant), "not including: (A) the table of contents; (B) the list of citations to constitutional provisions, treaties, statutes, regulations, and cases; and (C) any appendix". Longer only by leave of court on motion. The cover page, if any, is not among the exclusions. | RCFC 5.4(b)(1), p. 9 | M |
| USCFC-LEN-011 | Reply brief or memorandum: at most 20 pages (30 when a response to a cross-motion is included). | RCFC 5.4(b)(2), p. 9 | M |
| USCFC-LEN-012 | No incorporation by reference of a prior brief; to rely on one, reproduce it in an appendix, state the number of relevant pages in a footnote on the first page, and count those pages against the limit. | RCFC 5.4(b)(3), p. 9 | A |

### Contents and order (RCFC 5.4(a), 7(b), 52.1(c))

Required order for an initial brief or memorandum over 10 pages (RCFC 5.4(a)(2)(A)-(G)), "arranged under proper headings":

1. Table of contents, including the contents of any appendix (USCFC-CONT-020)
2. Table of cited constitutional provisions, treaties, statutes, regulations and cases, cases alphabetical (USCFC-CONT-021)
3. Questions presented (USCFC-CONT-022)
4. Statement of the case, with record references (USCFC-CONT-023)
5. Argument (USCFC-CONT-024)
6. Conclusion indicating the relief sought (USCFC-CONT-025)
7. Appendix, if any (USCFC-CONT-026)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-CONT-020 | Table of contents "including the specific contents of any appendix ... listing a description of every item or exhibit being reproduced in the appendix and the page number at which the item or exhibit appears". Required unless the brief is 10 pages or fewer. EX-ORACLE has one; EX-US has none (a deviation by that filer, not a convention). | RCFC 5.4(a)(2)(A), p. 9 | M |
| USCFC-CONT-021 | Table of cited constitutional provisions, treaties, statutes, regulations and cases, "giving the volume and page number of the edition where each may be found" (Cl. Ct. / Fed. Cl. reporters for this court's published decisions), cases in alphabetical order. Every page reference is a page where the authority is cited. | RCFC 5.4(a)(2)(B), p. 9 | M |
| USCFC-CONT-022 | A concise statement of each question presented (may be omitted in an opposing brief unless the party is dissatisfied with the other side's presentation). | RCFC 5.4(a)(2)(C), (a)(3), p. 9 | M (initial brief) |
| USCFC-CONT-023 | A concise statement of the case, referring to findings, stipulations or the record, and setting out verbatim the pertinent provisions and administrative decisions (unless already reproduced with the complaint). For an RCFC 52.1(c) motion, the motion or memorandum includes a statement of facts that cites the administrative record; a response includes a counter-statement. | RCFC 5.4(a)(2)(D), p. 9; RCFC 52.1(c)(1)-(2), p. 72 | M |
| USCFC-CONT-024 | A clear statement of the argument with the points of fact and law and the authorities relied on. | RCFC 5.4(a)(2)(E), p. 9 | M |
| USCFC-CONT-025 | A concise conclusion indicating the relief sought; the motion states its grounds with particularity and the relief sought. | RCFC 5.4(a)(2)(F), p. 9; RCFC 7(b)(1)(B)-(C), p. 15 | M |
| USCFC-CONT-026 | Any appendix is numbered consecutively within itself; a separately bound appendix carries its own table of contents. Appendix pages are still numbered at the bottom center (USCFC-FORM-005). EX-US numbers its appendix "Appx1", "Appx2", ... | RCFC 5.4(a)(2)(G), p. 9; RCFC 5.5(c)(6); EX-US for the label | M; C (label) |
| USCFC-CONT-027 | Brief "compact, concise, logically arranged, and free of burdensome, irrelevant, immaterial, and scandalous matter". | RCFC 5.4(a)(1), p. 8 | A |
| USCFC-CONT-028 | Citations follow the most recent Bluebook; ECF documents are cited in one of the court's posted formats. | RCFC 5.4(c)(1)-(2), p. 9 | A |
| USCFC-CONT-029 | Cross-motion and response to the original motion are one document; response to a cross-motion and reply on the original motion are one document. | RCFC 5.4(a)(5), p. 8 | A |
| USCFC-CONT-030 | Timing (not form): response to an RCFC 12(b), 12(c), 52.1 or 56 motion within 28 days after service, reply within 14 days. Duty to confer (RCFC 7.3) applies only to motions not described in RCFC 7.2(b), so not to these. | RCFC 7.2(b), 7.3(a), pp. 15-16 | A |

### Cover and conventions

| ID | Requirement | Source | Kind |
|---|---|---|---|
| USCFC-COVER-010 | Caption with docket number and the judge's name directly below it (USCFC-COVER-003); "Bid Protest" under the court name in a bid protest (USCFC-COVER-002). Both exemplars comply (EX-ORACLE: "BID PROTEST", "Case No. 18-1880C / Senior Judge Eric G. Bruggink"; EX-US: "No. 26-458 / Judge Kaplan"). | RCFC 5.5(g)-(h) | M |
| USCFC-COVER-011 | Separate cover page for the brief: caption, title in bold capitals, counsel blocks (attorney of record, of counsel) below. Seen in both EX-ORACLE (memorandum cover, p. 4) and EX-US (p. 1): a convention across filers. Under USCFC-FORM-005 the cover still carries a page number; EX-US leaves it unnumbered, which the template does not copy. | EX-ORACLE, EX-US; RCFC 5.5(c)(6) | C |
| USCFC-COVER-012 | Caption repeated on the first page of the body after the tables (EX-US p. 6). Seen in one filer only: that filer's style. | EX-US | C (tier 3) |
| USCFC-FORM-020 | Front-matter tables paginated in lowercase roman, body from arabic 1 (EX-US: TOA i-iv, body 1-39). Allowed by USCFC-FORM-005 so long as every page carries a number. | EX-US; EX-ORACLE TOC | C |
| USCFC-FORM-021 | Top-level headings centered bold capitals ("QUESTIONS PRESENTED", "ARGUMENT", "CONCLUSION"); argument points numbered I./II., then A./B., then 1./2. Seen in EX-US and in EX-ORACLE's table of contents. | EX-ORACLE, EX-US | C |
| USCFC-FORM-022 | Table of contents and table of authorities with dot leaders and right-aligned page numbers; "Page(s)" column head on the TOA (EX-US); cases first, then statutes, regulations, other authorities. | EX-ORACLE, EX-US | C |
| USCFC-CERT-020 | No certificate of compliance (no word limit exists). No certificate of service when served through ECF (USCFC-CERT-005); neither exemplar has one. | RCFC 5.4(b); RCFC 5(d)(1)(B); EX-ORACLE, EX-US | M (none required) |
| USCFC-CERT-021 | Proposed order: not required by RCFC 7 (the 2008 committee note to RCFC 7 records that the earlier "may be accompanied by a proposed order" language was dropped). EX-ORACLE attaches one; EX-US does not. One filer's style. | RCFC 7 Rules Committee Note (2008); EX-ORACLE | C (tier 3) |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| USCFC-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| USCFC-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| USCFC-TOOL-003 | Every TOC and TOA page reference equals the page where the heading or citation really appears. | T (supports USCFC-CONT-020, -021) |
| USCFC-TOOL-004 | The counted brief pages (body after the tables, before any appendix) are at most the USCFC-LEN-010/011 limit; the build reports the count. | T (supports USCFC-LEN-010) |
| USCFC-REVIEW-001 | A recorded visual review covers every page of the current PDF and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |
