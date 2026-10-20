# District Court, District of Puerto Rico: rules

Alias `prd`. Scope: civil papers filed by counsel through CM/ECF in the United States District Court for the District of Puerto Rico; doc types `complaint` (a complaint commencing a civil action) and `motion-brief` (a motion incorporating or accompanied by its memorandum of law, L.Cv.R. 7(a)). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (national rule amendments) and whenever the court posts amended Local Rules or a notice of proposed amendments (the current compilation is "Effective with amendments through October 16, 2024"; a notice of adoption of amendments to Local Rule 39 was posted in early 2026 and does not touch form).

**Access note.** On 2026-10-17 www.prd.uscourts.gov answered every request from this box with "Request Rejected" (browser user agent) or 404 (curl user agent). The local rules were therefore read from the Internet Archive's stored copy of the court's own file; both URLs are given. The capture is dated 2026-03-07 and the PDF's modification date is 2025-10-21; an amendment posted after the capture would not be reflected.

## Sources

| Tag | Source | URL |
|---|---|---|
| LCVR | Local Rules of the United States District Court for the District of Puerto Rico (Civil, Admiralty, Criminal), "Effective with amendments through October 16, 2024", 145 pp. Rules read: 1, 3, 5, 5.2, 7, 7.1, 10, 11, 56. | court file https://www.prd.uscourts.gov/sites/default/files/local_rules/Local%20Rules%2010-16-2024-amended-rule-83A.pdf ; read from https://web.archive.org/web/20260307052350id_/https://www.prd.uscourts.gov/sites/default/files/local_rules/Local%20Rules%2010-16-2024-amended-rule-83A.pdf |
| FRCP | Federal Rules of Civil Procedure 5(d)(1)(B), 7(b), 7.1, 8(a), 10(a)-(b), 11(a), 38(b) | https://www.law.cornell.edu/rules/frcp/rule_5 (and `rule_7`, `rule_7.1`, `rule_8`, `rule_10`, `rule_11`, `rule_38`) |
| EX-C1 | Complaint: Conde Vidal v. García Padilla, No. 3:14-cv-01253, Doc. 7 (amended complaint; Lambda Legal, Debevoise & Plimpton) | `complaint/usage/SOURCE.md` entry 1 |
| EX-C2 | Complaint: United States v. Commonwealth of Puerto Rico, No. 3:12-cv-02039, Doc. 1 (U.S. Department of Justice, Civil Rights Division) | `complaint/usage/SOURCE.md` entry 2 |
| EX-M1 | Motion to dismiss with memorandum: Franklin California Tax-Free Trust v. Commonwealth of Puerto Rico, No. 3:14-cv-01518, Docs. 10, 10-1 (Puerto Rico Department of Justice, Kirkland & Ellis) | `motion-brief/usage/SOURCE.md` entry 1 |
| EX-M2 | Memorandum in support of motion for summary judgment: Conde Vidal v. García Padilla, No. 3:14-cv-01253, Doc. 44 (Lambda Legal, Debevoise & Plimpton) | `motion-brief/usage/SOURCE.md` entry 2 |

Kinds: **M** = mandated by a court rule (FRCP or L.Cv.R.). **C** = convention (seen across exemplars of different filers; the rules leave it open). **T** = project/tooling rule. **A** = author responsibility, not machine-checkable.

Findings:

1. **Size floor, no face, no margin.** L.Cv.R. 7(e): "a font size no smaller than ten (10) characters per inch or, if a proportionately spaced font is used, no less than twelve (12) points". No typeface and no margin is named. L.Cv.R. 10(e) applies L.Cv.R. 7(e) to pleadings.
2. **Page limits** (L.Cv.R. 7(e)): 25 pages for motions to dismiss, for judgment on the pleadings, for summary judgment, for injunctive relief and appeals from a magistrate judge; 15 for non-dispositive motions and memoranda or oppositions; 10 for replies. Replies need prior leave (L.Cv.R. 7(c)). The rule does not say whether a table of contents or authorities counts; EX-M2's body runs exactly 25 Arabic-numbered pages after roman-numbered front matter.
3. **Signature block is longer than FRCP 11(a).** L.Cv.R. 11 adds the USDC-PR bar identification number, pro hac vice or pro se status, and facsimile number.
4. **No certificate of service is required** for a paper served through CM/ECF (FRCP 5(d)(1)(B); L.Cv.R. 5(b) makes the NEF service). Both motion exemplars still carry one (EX-M1, EX-M2): a convention, not a rule.
5. **Spanish-language documents** must be filed with a certified English translation (L.Cv.R. 5(c)); the template is English-only.

## Court-wide requirements

### Page form (L.Cv.R. 7(e), 10(e))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PRD-FORM-001 | "typed, printed or prepared by a clearly-legible duplication process, on 8-1/2 x 11 inch white paper or format" (612 x 792 pt). | LCVR 7(e); LCVR 10(e) | M |
| PRD-FORM-002 | "a font size no smaller than ten (10) characters per inch or, if a proportionately spaced font is used, no less than twelve (12) points." No typeface named. | LCVR 7(e) | M |
| PRD-FORM-003 | "All text shall be double-spaced except for quoted material"; double-spaced "except for the caption, title, footnotes, quotations, descriptions of real property and identifications of counsel." | LCVR 7(e) | M |
| PRD-FORM-004 | "all pages shall be consecutively numbered, preferably at the bottom center of each page." Bottom-center numbers in EX-C1, EX-C2, EX-M1, EX-M2 (three filers). | LCVR 7(e); EX-C1, EX-C2, EX-M1, EX-M2 | M (consecutive); C (bottom center) |
| PRD-FORM-005 | "Footnotes should be used sparingly." | LCVR 7(e) | A |
| PRD-FORM-006 | Margins: no rule. Measured text extents (pdftotext -bbox, all pages, ECF header excluded): left and right about 1 inch in EX-C1 (0.94/1.00 in), EX-C2 (1.00/1.00), EX-M1 (0.93/0.96), EX-M2 (1.00/1.00); top about 1 inch; the bottom margin carries the page number. One inch on all sides is the convention. | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| PRD-FORM-007 | Body type Times New Roman 12 pt in all four exemplars (three filers). The rules name no face, so the face is a convention the template may meet with a vendored serif; 12 pt is the floor (PRD-FORM-002). | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| PRD-FORM-008 | Every font used is embedded and is the template's declared family. (EX-C2 and EX-M2 do not embed Times New Roman; the rules do not require embedding.) | project | T |

### Caption and signature

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PRD-CONT-001 | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation; the rules on captions and form apply to motions and other papers. | FRCP 10(a); FRCP 7(b)(2) | M |
| PRD-CONT-002 | Court name centered in capitals ("[IN THE] UNITED STATES DISTRICT COURT / [FOR THE] DISTRICT OF PUERTO RICO"); parties block at the left, civil number (with judge initials once assigned, e.g. "3:14-cv-01253-PG" or "No. 14-1518 (FAB)") at the right; document title centered in bold capitals below the caption: EX-C1, EX-C2, EX-M1, EX-M2. EX-C2 puts "COMPLAINT" in the right-hand column instead of below (one filer's style). | EX-C1, EX-C2, EX-M1, EX-M2 | C |
| PRD-CONT-003 | Every paper is signed by at least one attorney of record, stating the signer's address, e-mail address and telephone number. | FRCP 11(a) | M |
| PRD-CONT-004 | Signature block states "the signer's name, USDC-PR Bar Identification Number, pro hac vice or pro se status, mailing and e-mail addresses, and telephone and facsimile numbers." | LCVR 11 | M |
| PRD-ELEC-001 | Pleadings and other papers are filed by CM/ECF (unrepresented parties excepted); the NEF constitutes service. Electronic signature typed as "s/ Name" (EX-C1, EX-C2, EX-M1) or "/s/ Name" (EX-M2); no local rule prescribes the form. | LCVR 5(a)-(b); EX-C1, EX-C2, EX-M1, EX-M2 | M (CM/ECF); C (typed "s/" signature) |
| PRD-ELEC-002 | PDF has a text layer on every page and embedded fonts. | project | T |
| PRD-ELEC-003 | Non-English documents are accompanied by a certified English translation. | LCVR 5(c) | A |
| PRD-ELEC-004 | Personal data identifiers redacted or partially redacted (SSN last four, minors' initials, year of birth, last four of account numbers, home city and state only). | LCVR 5.2(a); FRCP 5.2 | A |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PRD-CONT-010 | The title of the complaint names all the parties. | FRCP 10(a) | M |
| PRD-CONT-011 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction in a separate count where that promotes clarity. | FRCP 10(b) | M |
| PRD-CONT-012 | A short and plain statement of the grounds for jurisdiction, of the claim, and a demand for the relief sought. | FRCP 8(a)(1)-(3) | M |
| PRD-CONT-013 | Jury demand, if made, may be included in the pleading (FRCP 38(b)(1)); the template prints it only when supplied. | FRCP 38(b) | M (when demanded) |
| PRD-CONT-014 | Section headings centered in bold capitals (e.g. INTRODUCTION, PARTIES, JURISDICTION AND VENUE, claims, PRAYER FOR RELIEF), numbered paragraphs running continuously through the headings, lettered prayer items: EX-C1 (A to G under PRAYER FOR RELIEF) and EX-C2 ("WHEREFORE", a-d). | EX-C1, EX-C2 | C |
| PRD-CONT-015 | Civil Cover Sheet (JS-44) and Category Sheet accompany the complaint (separate papers; not templated). | LCVR 3(a) | M (separate filing) |
| PRD-CONT-016 | Disclosure statement of a nongovernmental corporate party, and the diversity citizenship statement, filed with the first appearance (separate paper). | FRCP 7.1(a)-(b); LCVR 7.1 | M (separate filing) |
| PRD-LEN-010 | No page limit for a complaint. | LCVR 7(e) (limits are for motions and memoranda) | M (none) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PRD-CONT-020 | A request for a court order is made by written motion that states with particularity the grounds and the relief sought. | FRCP 7(b)(1) | M |
| PRD-CONT-021 | Matters are "presented by written motion filed with the clerk, incorporating a memorandum of law as appropriate, including citations and supporting authorities"; affidavits and other documents setting forth the facts are filed with the motion. (EX-M1 files the memorandum as an attachment to the motion; EX-M2 as a separate docket entry; both are permitted.) | LCVR 7(a) | M |
| PRD-LEN-020 | Except by prior leave: motions to dismiss, for judgment on the pleadings, for summary judgment, for injunctive relief, or appeals from a magistrate judge's decision "shall not exceed twenty-five (25) pages"; non-dispositive motions and memoranda or oppositions "shall not exceed fifteen (15) pages"; reply memoranda "shall not exceed ten (10) pages". | LCVR 7(e) | M |
| PRD-LEN-021 | Reply only with prior leave, within 7 days of the opposition, max 10 pages, confined to new matters; surreply only if the reply raises new arguments, max 10 pages. | LCVR 7(c)-(d) | M |
| PRD-CONT-022 | Opposition within 14 days of service of the motion, or objection is waived; it includes citations, authorities, affidavits and documents. | LCVR 7(b) | A |
| PRD-CONT-023 | Adoption by reference expressly identifies the title and docket entry of the adopted paper. | LCVR 7(f) | A |
| PRD-CONT-024 | Summary-judgment motions are supported by a separate, short and concise statement of material facts in numbered paragraphs with record citations (separate paper). | LCVR 56(b), (e) | M (separate filing) |
| PRD-CONT-025 | A long memorandum has a table of contents and a table of authorities, numbered in roman numerals, before an Arabic-numbered body: EX-M1 and EX-M2 (two filers). No rule requires them. | EX-M1, EX-M2 | C |
| PRD-CONT-026 | Body order Introduction, (Background / Legal Standard), Argument with Roman-numeral point headings and lettered sub-points, Conclusion: EX-M1, EX-M2. | EX-M1, EX-M2 | C |
| PRD-CERT-020 | Certificate of service at the end: EX-M1, EX-M2 (two filers). Not required for CM/ECF service (Finding 4). | FRCP 5(d)(1)(B); LCVR 5(b); EX-M1, EX-M2 | C |

## Not verified

- No court-issued CM/ECF administrative procedures document was found in the Internet Archive's index of prd.uscourts.gov files; e-filing format rules beyond L.Cv.R. 5 are therefore not recorded.
- The court's live site could not be read (access note above).
