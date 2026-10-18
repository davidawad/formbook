# District of Vermont (civil): rules

Alias `vtd`. Scope: civil papers filed by counsel in the United States District Court for the District of Vermont through CM/ECF (NextGen): a complaint (`complaint/`) and a memorandum of law supporting or opposing a motion (`motion-brief/`). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (federal rule amendments) and whenever the court posts amended Local Rules or Administrative Procedures for ECF at https://www.vtd.uscourts.gov/court-info/local-rules-and-orders.

## Sources

Every requirement below cites one of these. Page numbers are the printed page numbers of the PDF.

| Tag | Source | URL |
|---|---|---|
| LR | D. Vt. Local Rules of Procedure, cover dated April 20, 2026 (`LocalRules-20260420.pdf`, 60 pp., sha256 `8048666fab25b6a7f9e35bd7fd8f486cca1041c9d5d047fd81c89338630300fa`); listed on the court's rules page as "Effective 4/20/2026". Fetched 2026-10-17. | https://www.vtd.uscourts.gov/sites/vtd/files/LocalRules-20260420.pdf |
| AP | D. Vt. Administrative Procedures for Electronic Case Filing (ECF), February 2025 (15 pp., sha256 `22f032e1f54ef7444e59168de5067fcb2f4c2552418584f801e73f6c067414a2`). L.R. 5(b) makes compliance mandatory for electronic filings. Fetched 2026-10-17. | https://www.vtd.uscourts.gov/sites/vtd/files/Administrative%20Procedures%20February%202025.pdf |
| RULES-PAGE | Court's "Local Rules and Orders" page (links both PDFs above). Fetched 2026-10-17 (the site rejects a bare `Mozilla/5.0` user agent; a full browser user agent works). | https://www.vtd.uscourts.gov/court-info/local-rules-and-orders |
| FRCP | Federal Rules of Civil Procedure 5, 7, 7.1, 8, 10, 11, 38 (LII text, fetched 2026-10-17) | https://www.law.cornell.edu/rules/frcp/rule_5 (and `rule_7`, `rule_7.1`, `rule_8`, `rule_10`, `rule_11`, `rule_38`) |
| EX-C1 | Complaint exemplar 1: *Bonges v. Town of Milton*, 2:26-cv-00283, ECF 1 (Plaintiff Bonges; Darby Kolter & Roberts LLP and Kingsbury Law) | `complaint/usage/SOURCE.md` |
| EX-C2 | Complaint exemplar 2: *United States v. State of Vermont*, 2:26-cv-00272, ECF 1 (United States; DOJ Civil Division) | `complaint/usage/SOURCE.md` |
| EX-M1 | Motion-brief exemplar 1: *BlackBerry Corp. v. Coulter*, 5:22-cv-00098, ECF 16 (Defendant Coulter; Langrock Sperry & Wool, LLP) | `motion-brief/usage/SOURCE.md` |
| EX-M2 | Motion-brief exemplar 2: *Bingham Brook, LLC v. Verdantas, LLC*, 2:26-cv-00223, ECF 15-1 (Defendant Verdantas; Gardner Preston, PLLC) | `motion-brief/usage/SOURCE.md` |
| EX-M3 | Motion-brief exemplar 3: *Poitras v. Clark*, 2:26-cv-00234, ECF 17 (Defendant Attorney General Clark; Vermont Office of the Attorney General) | `motion-brief/usage/SOURCE.md` |

Kinds: **M** = mandated by a court rule (Local Rule, ECF Administrative Procedures made binding by L.R. 5(b), or FRCP). **C** = convention (the rules leave it open; taken from the exemplars, and the row says which filers show it). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **No typeface is named.** L.R. 10(a) says only "be plainly legible" and "be no less than 12 point font". Any face is a convention (C). All five exemplars, from five different filers, are set in Times New Roman (embedded `TimesNewRomanPSMT` per `pdffonts`), so Times New Roman (or the metric-compatible vendored Liberation Serif) is a cross-filer convention, not a rule.
2. **Length is in pages, not words.** L.R. 7(a)(4)-(5): 25 pages for a dispositive-motion memorandum, 15 for a non-dispositive one, 10 for a reply, all "excluding exhibits and attachments". There is no word count and no certificate of compliance.
3. **No certificate of service is required for papers served through ECF.** AP (G)(2): transmission of the NEF "shall constitute service"; AP (G)(3) requires a certificate only for "Any document that requires service outside of the ECF system"; FRCP 5(d)(1)(B) agrees. Only one of the three motion-brief filers (EX-M2) attaches one.
4. **Text-searchable PDF is preferred, not required.** AP (F)(3): "It is preferred documents be filed in an electronically converted PDF"; scanned PDFs are allowed when only paper exists. The project still requires a text layer (T).
5. **Electronic filing is voluntary** under L.R. 5(a), and AP (E)(2) bars non-prisoner pro se parties from e-filing case-initiating documents. The templates target counsel's ECF filings.
6. **Internal date inconsistency in the Local Rules.** The cover says April 20, 2026; L.R. 1(b) still says "effective as revised on January 3, 2014" and L.R. 86(a) says "effective as revised on April 15, 2013". The court's rules page labels the PDF "Effective 4/20/2026"; that date is used here.

## Requirements (court-wide)

IDs are stable. `checks.yaml` references them. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (L.R. 10(a))

L.R. 10(a) text, verbatim: "Filings and attachments must: (1) be of 8 ½ x 11 inch size; (2) be plainly legible, whether keyed, typed, handwritten, or duplicated; (3) have at least 1 inch margins; (4) be no less than 12 point font; (5) be consecutively numbered; (6) be double-spaced, except for quoted material; (7) use footnotes sparingly; and (8) be paper-clipped or otherwise attached to facilitate scanning."

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-FORM-001 | Every page is 8 1/2 x 11 inch (612 x 792 pt). | L.R. 10(a)(1) (LR p. 7) | M |
| VTD-FORM-002 | Margins "at least 1 inch" on all four sides. The rule names no exception for page numbers, so the checks keep all of the filer's text, including the page number, inside the 1 inch margins (the court's ECF header stamp, added after filing, is not the filer's text; see VTD-ELEC-008). | L.R. 10(a)(3) | M |
| VTD-FORM-003 | Type "no less than 12 point font". The rule states no footnote exemption, so the checks apply 12 pt to all text including footnotes, headings and captions (conservative reading). | L.R. 10(a)(4) | M |
| VTD-FORM-004 | Typeface: the rule names none; it requires only that the paper "be plainly legible". | L.R. 10(a)(2) | M (legible); no face mandated |
| VTD-FORM-005 | Pages "consecutively numbered". The rule does not fix the position or style of the number. | L.R. 10(a)(5) | M |
| VTD-FORM-006 | "Double-spaced, except for quoted material." Operational definition used by the checks: baseline-to-baseline distance in body paragraphs at least twice the type size. The rule names no exemption for headings, captions, signature blocks or footnotes; single-spacing those is common practice in all exemplars (see VTD-FORM-012) but not authorized by the text. | L.R. 10(a)(6) | M (body); see VTD-FORM-012 |
| VTD-FORM-007 | Footnotes used sparingly. Not machine-checkable as a limit. | L.R. 10(a)(7) | A |
| VTD-FORM-008 | Paper-clipped or attached for scanning. Paper filings only; not applicable to the ECF PDF. | L.R. 10(a)(8) | M (paper only) |
| VTD-FORM-009 | Every font used is embedded, and every embedded font is the template's declared family (no fallback to a system font). | project; supports L.R. 10(a)(2) | T |
| VTD-FORM-010 | Typeface Times New Roman (or the metric-compatible vendored Liberation Serif). Seen in all five exemplars: EX-C1, EX-C2, EX-M1, EX-M2, EX-M3 (five different filers): a cross-filer convention. | EX-C1, EX-C2, EX-M1, EX-M2, EX-M3 | C |
| VTD-FORM-011 | Page number centered at the foot, arabic. Seen in EX-C1, EX-C2, EX-M1, EX-M2, EX-M3. | exemplars | C |
| VTD-FORM-012 | Caption, headings, block quotations, footnotes and the signature block single-spaced; body double-spaced. Seen in all five exemplars. | exemplars | C |

### Caption and title (FRCP 7(b)(2), 10(a); AP (F)(5))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-CAP-001 | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. "The title of the complaint must name all the parties; the title of other pleadings, after naming the first party on each side, may refer generally to other parties." | FRCP 10(a) | M |
| VTD-CAP-002 | "The rules governing captions and other matters of form in pleadings apply to motions and other papers." | FRCP 7(b)(2) | M |
| VTD-CAP-003 | Documents filed in ECF are titled in accordance with the court's list of ECF civil events; "Documents submitted in letter format will not be accepted by the court." | AP (F)(5) | M |
| VTD-CAP-004 | Court name as two centered lines in capitals at the top of page 1, then the caption on the same page; no separate cover page. Wording varies by filer ("UNITED STATES DISTRICT COURT / DISTRICT OF VERMONT" in EX-C1; "IN THE UNITED STATES DISTRICT COURT / FOR THE DISTRICT OF VERMONT" in EX-C2, EX-M2; "UNITED STATES DISTRICT COURT / FOR THE DISTRICT OF VERMONT" in EX-M1, EX-M3). Two-line centered court name and no cover: convention across all five filers; the exact wording is filer style. | exemplars | C |
| VTD-CAP-005 | Parties in a block at the left, each with its designation (Plaintiff, Defendants); case number at the right. Seen in all five. A `)` column between the blocks appears only in EX-M2 (one filer's style). The case-number label differs in every filer ("Civil Action No.", "No.", "Docket No.", none, "Case No."): no convention. | exemplars | C |

### Signature (FRCP 11(a); AP (J); L.R. 11(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-SIG-001 | Every pleading, written motion and other paper is signed by at least one attorney of record (or the party if unrepresented) and states the signer's address, e-mail address and telephone number. | FRCP 11(a) | M |
| VTD-SIG-002 | Every electronically filed document (excluding attachments) includes a signature block with the attorney's name, address, telephone number and e-mail address; the ECF user's name must match the name in the signature block. The ECF login is the signature. AP (J)(1) gives the format: name, firm, street, city/state/ZIP, "Telephone:", "Fax:", "Email:". | AP (J)(1) | M (contents); C (line order per the AP sample) |
| VTD-SIG-003 | A document requiring more than one signature lists every signatory with a signature block. | AP (J)(2) | M (conditional) |
| VTD-SIG-004 | A pro se party writes "pro se" after the party's signature on all filings. | L.R. 11(a)(4) | M (pro se only) |
| VTD-SIG-005 | Electronic signature written `/s/ Name`. Seen in EX-C1, EX-C2, EX-M2, EX-M3 (four filers); EX-M1 shows a blank signature line instead. Convention. | exemplars | C |
| VTD-SIG-006 | A date line ("Dated:", "DATED at Burlington, Vermont this ... day of ...", "Respectfully submitted this ... day of ...") above an indented signature block in the right half of the page. Seen in all five exemplars; the wording is filer style. | exemplars | C |

### Service and certificates (FRCP 5; AP (G))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-CERT-001 | No certificate of service is required for a paper served through ECF: the NEF "shall constitute service" (AP (G)(2)); "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system" (FRCP 5(d)(1)(B)). | AP (G)(2); FRCP 5(d)(1)(B) | M |
| VTD-CERT-002 | "Any document that requires service outside of the ECF system shall include a Certificate of Service identifying the manner in which service on each party was accomplished." The template emits one only when asked. | AP (G)(3); FRCP 5(d)(1)(B)(i) | M (conditional) |

### Electronic filing (L.R. 5; AP)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-ELEC-001 | Electronic filings comply with the court's Administrative Procedures for ECF. | L.R. 5(b) | M |
| VTD-ELEC-002 | Documents filed electronically are PDF. | AP (F)(3), (A)(1) | M |
| VTD-ELEC-003 | Each PDF file is at most 250 MB; larger documents are split. | AP (F)(4), (B)(3) | M |
| VTD-ELEC-004 | Electronically converted (text-searchable) PDF is "preferred"; a scanned PDF is allowed when only paper exists. The project requires a text layer on every page. | AP (F)(3); project | C (court); T (project) |
| VTD-ELEC-005 | Cover letters are not included with electronic filings. | AP (L)(5) | M |
| VTD-ELEC-006 | More than 5 attachments: a separate index describing each exhibit is the first attachment. Previously filed papers are referred to, not attached. | AP (L)(1), (L)(4) | M (conditional; outside the template) |
| VTD-ELEC-007 | Redact personal data identifiers (minors' initials, last four of SSN and account numbers, year of birth; home city/state in criminal cases). | AP (K); FRCP 5.2 | A |
| VTD-ELEC-008 | The top margin carries no text of the filer's; the court's ECF stamp ("2:26-cv-... Document N Filed mm/dd/yy Page x of y") is added there. Seen on every page of all five exemplars. Covered by VTD-FORM-002. | exemplars | C |

### Disclosure statements (filed separately)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-DISC-001 | A nongovernmental corporate party files an FRCP 7.1 statement (parent corporation and any publicly held corporation owning 10% or more of its stock, or that there is none); in a diversity case every party files a citizenship statement; filed with the first appearance, pleading, motion or other request. L.R. 7.1(a) adds: any subsidiary (except wholly-owned) and any affiliate that has issued shares to the public. A separate filing; not produced by these templates. | FRCP 7.1(a)-(b); L.R. 7.1(a) | M (separate filing) |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-CONT-001 | A pleading stating a claim contains (1) a short and plain statement of the grounds for the court's jurisdiction, (2) a short and plain statement of the claim showing that the pleader is entitled to relief, and (3) a demand for the relief sought. | FRCP 8(a) | M (A for the wording) |
| VTD-CONT-002 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction or occurrence in a separate count where that promotes clarity. | FRCP 10(b) | M |
| VTD-CONT-003 | The title of the complaint names all the parties (see VTD-CAP-001). | FRCP 10(a) | M |
| VTD-CONT-004 | A jury demand may be included in the pleading. Optional (author choice); shown in EX-C1 ("JURY TRIAL DEMANDED" under the title), absent in EX-C2. | FRCP 38(b) | M (if demanded); A |
| VTD-CONT-005 | A plaintiff instituting a civil action submits: the original complaint; the filing fee or an IFP motion and affidavit; a Civil Cover Sheet (JS 44); when applicable, AO 398 notice and request for waiver and AO 399 waiver for each defendant. All but the complaint are separate filings, not produced by this template. | L.R. 3(a)(1)-(5) | M (separate filings) |
| VTD-CONT-006 | No certificate of service in a complaint filed through ECF (service is by summons under FRCP 4; L.R. 4(a)). | FRCP 5(d)(1)(B); L.R. 4 | M |
| VTD-CONT-007 | Centered capital section headings (INTRODUCTION; JURISDICTION AND VENUE; PARTIES; facts; counts or causes of action; PRAYER FOR RELIEF). Seen in EX-C1 and EX-C2 (two filers): convention. Count labels differ ("FIRST CAUSE OF ACTION" in EX-C1, "COUNT I" under "CLAIMS FOR RELIEF" in EX-C2): filer style. | EX-C1, EX-C2 | C |
| VTD-CONT-008 | Numbered paragraphs with the number at a first-line indent (about 0.5 inch) followed by a tab, double-spaced. Seen in EX-C1 and EX-C2. | EX-C1, EX-C2 | C |
| VTD-CONT-009 | The prayer for relief is a "WHEREFORE" lead-in followed by an enumerated list of the relief sought, under a PRAYER FOR RELIEF heading. Seen in EX-C1 and EX-C2: convention. The list labels differ (A., B., ... in EX-C1; 1., 2., ... in EX-C2): filer style. | EX-C1, EX-C2 | C |
| VTD-CONT-010 | Pro se non-prisoner parties may not e-file a case-initiating document (paper filing). | AP (E)(2), (Q) | M (pro se only) |

## Doc type: motion-brief

A memorandum of law supporting or opposing a motion. L.R. 7(a)(2) lets the motion "be accompanied by, or contain" the memorandum: EX-M1 and EX-M2 file it as a separate document or attachment; EX-M3 puts it in the motion under a "MEMORANDUM OF LAW" heading.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTD-LEN-001 | A memorandum supporting or opposing a dispositive motion (e.g. a motion to dismiss or for summary judgment) must not exceed 25 pages, excluding exhibits and attachments, unless the judge grants prior leave. | L.R. 7(a)(4)(A); L.R. 7(a)(3)(A) (examples of dispositive motions) | M |
| VTD-LEN-002 | A memorandum supporting or opposing a non-dispositive motion must not exceed 15 pages, excluding exhibits and attachments, unless the judge grants prior leave. | L.R. 7(a)(4)(B) | M |
| VTD-LEN-003 | A reply memorandum must not exceed 10 pages, excluding exhibits and attachments, and is filed no more than 14 days after the opposing memorandum. | L.R. 7(a)(5)(A)-(B) | M |
| VTD-LEN-004 | The rule counts pages and names no exclusions other than exhibits and attachments; the checks count every page of the memorandum, including the caption page and the signature. | L.R. 7(a)(4) | M (conservative reading) |
| VTD-CONT-020 | "The court will not consider any motion unless it contains the word 'motion' in the title." For a separate memorandum, the title names the motion it supports (all three exemplars do: EX-M1, EX-M2, EX-M3). | L.R. 7(a)(1); exemplars | M (motion); C (memorandum) |
| VTD-CONT-021 | Unless presented at trial, every written motion is accompanied by, or contains, a memorandum of law concisely stating the legal contentions and supporting authorities, served on all opposing parties. | L.R. 7(a)(2) | M |
| VTD-CONT-022 | A motion states with particularity the grounds and the relief sought, in writing. | FRCP 7(b)(1) | M (A for content) |
| VTD-CONT-023 | Opposition deadlines: 30 days after service for a dispositive motion, 14 days for others, unless the judge extends. Not templated. | L.R. 7(a)(3)(A)-(B) | A |
| VTD-CONT-024 | A non-dispositive motion certifies a good-faith attempt to obtain the opposing party's agreement; if obtained, the statement of agreement is in the body and the word "Stipulated" is in the document caption (not for motions involving incarcerated pro se litigants). | L.R. 7(a)(7) | M (non-dispositive only) |
| VTD-CONT-025 | A request for oral argument is made in writing; motions are otherwise decided without it. | L.R. 7(a)(6) | A (optional) |
| VTD-CONT-026 | A motion to continue a trial contains counsel's certification that the represented party has been notified. | L.R. 7(b) | M (that motion only) |
| VTD-CONT-027 | A motion for summary judgment is accompanied by a separate, concise statement of undisputed material facts in numbered paragraphs, each followed by a citation to admissible evidence; an opposition responds paragraph by paragraph. Separate document, not this template. | L.R. 56(a), (b), (d) | M (summary judgment only) |
| VTD-CONT-028 | No table of contents or table of authorities is required by rule; none of the three exemplars (EX-M1 25 pp., EX-M2 9 pp., EX-M3 12 pp.) has one. | L.R. 7 (silent); exemplars | C |
| VTD-CONT-029 | Centered capital top-level headings (e.g. INTRODUCTION/BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION): EX-M1 and EX-M3 (two filers): convention. EX-M2 uses roman-numbered mixed-case headings at the margin (I. Factual Background, II. Legal Standard): filer style. Roman-numbered argument subheadings at the margin: EX-M2, EX-M3. | EX-M1, EX-M2, EX-M3 | C |
| VTD-CONT-030 | Title of the memorandum in capitals, centered under the caption, naming the filing party and the motion. Seen in EX-M1, EX-M2, EX-M3. | exemplars | C |
| VTD-CONT-031 | Certificate of service at the end: only EX-M2 (one filer). Not required for ECF service (VTD-CERT-001); the template makes it opt-in. | EX-M2; AP (G)(2)-(3) | C (one filer) |

## Template-only requirements (the template's own contract)

| ID | Requirement | Kind |
|---|---|---|
| VTD-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| VTD-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| VTD-TOOL-003 | Each footnote appears on the page that carries its reference. | T |
| VTD-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |

## Not verified

- The court's ECF User Manual and its "comprehensive list of civil or criminal events" (AP (F)(5), (L)(1)) were not fetched; titles are checked only against L.R. 7(a)(1).
- Individual judges' practice preferences or standing orders (if any) were not located on the rules page and are not recorded.
- Font size in the exemplars was not measured in this pass; VTD-FORM-010 records the face only.
