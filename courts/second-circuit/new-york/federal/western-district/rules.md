# District Court, W.D. New York: rules

Alias `nywd`. Scope: civil papers filed by counsel through CM/ECF in the United States District Court for the Western District of New York; doc types `complaint` (initial pleading) and `motion-brief` (memorandum of law in support of a motion, e.g. under Fed. R. Civ. P. 12(b)(6)). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each January (the court adopts amended Local Civil Rules effective in January; the current edition is effective January 15, 2026) and whenever the court posts amended local rules or a revised Administrative Procedures Guide on https://www.nywd.uscourts.gov/rules-individual-local-federal or https://www.nywd.uscourts.gov/cmecf-information-0. Also check the assigned judge's individual practices ("Judge Preferences" on the court site), which are not recorded here.

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | W.D.N.Y. Local Rules of Civil Procedure, "Effective January 15, 2026" (cover page; adoption order: "shall apply to all actions commenced on or after January 15, 2026"). File name "2025 Local Rules of Civil Procedure FINAL - v3-1.pdf", 75 pages, sha256 `b32b2c3c52838dbb09e94bf7bac93b17ea9faf7d88fed1dce79d4d4a44be073f`. | https://www.nywd.uscourts.gov/sites/nywd/files/2025%20Local%20Rules%20of%20Civil%20Procedure%20FINAL%20-%20v3-1.pdf |
| RULES-PAGE | Court's rules page (links the LR file above as the Local Rules of Civil Procedure "Effective January 15, 2026") | https://www.nywd.uscourts.gov/rules-individual-local-federal |
| APG | W.D.N.Y. Administrative Procedures Guide for Electronic Filing, "Revised: October 5, 2022" (24 pages, sha256 `0db64af00caf8d660d61f0e7a4d08d89c6045bf39c500084327403a6fa5bbccc`); incorporated by LR 5.1(a). Linked from https://www.nywd.uscourts.gov/cmecf-information-0. | https://www.nywd.uscourts.gov/sites/nywd/files/administrative%20guide%2020221005.pdf |
| FRCP | Federal Rules of Civil Procedure 5.2, 7, 8, 10, 11, 38 (Legal Information Institute) | https://www.law.cornell.edu/rules/frcp/rule_5.2, `rule_7`, `rule_8`, `rule_10`, `rule_11`, `rule_38` |
| EX-C1 | Complaint exemplar: Kerrick v. Town of Gorham, No. 6:26-cv-06006, Doc. 1-2 (plaintiff, Gregory L. Silverman). Visual reference only. | `complaint/exemplars/SOURCE.md` |
| EX-M1 | Motion-brief exemplar: Kerrick v. Town of Gorham, No. 6:26-cv-06006, Doc. 6-9 (defendants, Adams Leclair LLP). Visual reference only. | `motion-brief/exemplars/SOURCE.md` |
| EX-C2 | Complaint exemplar 2: NIFLA v. James, No. 1:24-cv-00514, Doc. 1 (plaintiffs, Alliance Defending Freedom / Michael G. McCartin Law PLLC). Added 2026-10-17. Visual reference only. | `complaint/exemplars/SOURCE.md` |
| EX-M2 | Motion-brief exemplar 2: United States v. City of Rochester, No. 6:25-cv-06226, State of New York amicus-leave motion, memorandum and proposed amicus brief (NY Attorney General). Added 2026-10-17. Visual reference only. | `motion-brief/exemplars/SOURCE.md` |

All rule PDFs and HTML pages above were fetched on 2026-10-17 (cached outside the repo in `/work/artifacts/rules-cache/nywd/`).

Kinds: **M** = mandated by a court rule (Local Civil Rule, the Administrative Procedures Guide it incorporates, or the FRCP). **C** = convention (taken from exemplars or common practice; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable (content the lawyer must supply).

Findings that differ from what many templates assume:

1. **No typeface rule.** LR 10(a) sets only a size: "all text and footnotes shall be in a font size of at least 12-point type". No face, serif or proportional-spacing requirement exists in LR, APG or FRCP. Any font choice is C.
2. **Footnotes are 12 pt too.** The 12-point minimum expressly covers footnotes (LR 10(a)(1)); many templates shrink footnotes to 10 or 11 pt.
3. **Page limit, not word limit.** Memoranda are limited to 25 pages (replies 10); tables of contents and authorities are not counted (LR 7(a)(2)(C)). There is no word count and no certificate of compliance.
4. **PDF page labels.** APG 4(A) requires the filer to "alter a PDF's pagination so that it matches the way the filer initially paginated the submitted document" (e.g. roman front matter, arabic argument). A brief with roman front matter must carry matching PDF page labels.
5. **Text-searchable PDF required.** APG 2(A)(v) and 4(A): a non-searchable PDF is "non-conforming" and may be struck.

## Requirements: court-wide

IDs are stable. `checks.yaml` references them. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (LR 10)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWD-FORM-001 | Font size: "all text and footnotes shall be in a font size of at least 12-point type". Applies to body, headings, footnotes, captions. | LR 10(a)(1) | M |
| NYWD-FORM-002 | Spacing: "all text in the body of the document must be double-spaced, except that text in block quotations and footnotes may be single-spaced". Operational definition for checks: baseline-to-baseline distance in body paragraphs at least 24 pt at 12 pt type. | LR 10(a)(2) | M |
| NYWD-FORM-003 | "extensive footnotes and block quotes may not be used to circumvent page limitations". | LR 10(a)(3) | A |
| NYWD-FORM-004 | "documents must have at least one-inch margins on all four sides". Checked from text extents on every page (the ECF header stamp is added by the court, not the filer). | LR 10(a)(4) | M |
| NYWD-FORM-005 | "pages must be consecutively numbered". | LR 10(a)(5) | M |
| NYWD-FORM-006 | Typeface: rule is silent (LR 10(a) gives size only). Both exemplars use a proportional serif face (EX-C1 Times New Roman; EX-M1 Calisto MT); a proportional serif body face is therefore a convention seen across two filers. | none (LR 10(a) silent); EX-C1, EX-M1 | C |
| NYWD-FORM-007 | Page size 8 1/2 x 11 inch (612 x 792 pt). Stated by the rule only for paper filings ("durable white 8½" x 11" paper", LR 10(b)(1)); for e-filed PDFs it is the universal convention and both exemplars use it. | LR 10(b)(1) (paper only); EX-C1, EX-M1 | C |
| NYWD-FORM-008 | Every font used is embedded and is the template's declared family (no silent fallback to a system font). | project | T |

### Caption, signature, privacy (FRCP; APG)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWD-CONT-001 | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation; the rules governing captions apply to motions and other papers. | FRCP 10(a), 7(b)(2) | M |
| NYWD-CONT-002 | Signature: "signed by at least one attorney of record in the attorney's name"; "The paper must state the signer's address, e-mail address, and telephone number." | FRCP 11(a) | M |
| NYWD-CONT-003 | E-filed signature block format for a registered user: `s/Attorney's typed name`, `Attorney for [pltf/deft]`, Firm Name, Address, Telephone Number, Email Address. | APG 2(G)(iii) | M |
| NYWD-CONT-004 | Privacy redaction: only the last four digits of a social-security, taxpayer-identification or financial-account number, the year of birth, and a minor's initials. | FRCP 5.2(a); APG 2(P) | A |
| NYWD-CONT-005 | Court title in the caption as two centered lines "UNITED STATES DISTRICT COURT" / "WESTERN DISTRICT OF NEW YORK" (seen in EX-C1 and EX-M1, two filers). The rule requires only "the court's name". | FRCP 10(a); EX-C1, EX-M1 | C |
| NYWD-CONT-006 | Caption: party names at left, case number at right (both filers). The box/bracket style differs between filers (filer style). | EX-C1, EX-M1 | C |


### Certificates (APG 2(F))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWD-CERT-001 | No certificate of service when all filers in the action are registered users: "The Notice of Electronic Filing effectuates service for all registered users and no certificate of service is required". A certificate stating the manner of service is required when the document is manually filed, when a non-ECF pro se party must be served, or when an attorney is exempt from electronic service. Sample form: APG 4(B). Template: certificate opt-in. | APG 2(F)(iv), 4(B) | M |

### Electronic filing (LR 5.1(a); APG)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWD-ELEC-001 | All civil cases are ECF cases; papers are filed per the FRCP and the Administrative Procedures Guide. | LR 5.1(a) | M |
| NYWD-ELEC-002 | The document is a PDF converted from the word processor, and "must be text searchable. Do not print, scan and .PDF your document when it has been created in a word processing program." A non-searchable PDF is "non-conforming" and may be struck. | APG 2(A)(v), 4(A) | M |
| NYWD-ELEC-003 | Every document filed in CM/ECF "must be less than fifty Megabytes (50 MB) in size". | APG 2(D)(ii) | M |
| NYWD-ELEC-004 | PDF pagination (page labels) must match the document's printed pagination, e.g. roman numerals for a table of contents / table of authorities and arabic for the argument. | APG 4(A) | M |
| NYWD-ELEC-005 | Hyperlinks, if used, are in addition to the conventional citation, not instead of it. | APG 2(A)(vi) | A |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWD-CONT-101 | The title of the complaint must name all the parties. | FRCP 10(a) | M |
| NYWD-CONT-102 | Claims are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction or occurrence in a separate count where that promotes clarity. | FRCP 10(b) | M |
| NYWD-CONT-103 | Contents: (1) a short and plain statement of the grounds for the court's jurisdiction; (2) a short and plain statement of the claim; (3) a demand for the relief sought. | FRCP 8(a) | A |
| NYWD-CONT-104 | Jury demand, if made, may be included in the pleading (served no later than 14 days after the last pleading directed to the issue). | FRCP 38(b) | A |
| NYWD-CONT-105 | A completed civil cover sheet "shall be submitted with every complaint"; when opening a case online, the civil cover sheet, summons and marshal forms are attached to the initiating document as individual attachments. Separate filing; the template does not produce it. | LR 3; APG 2(C)(iii) | M (separate document) |
| NYWD-CONT-106 | RICO claims: a "RICO Case Statement" is filed under separate cover with the papers first asserting the claim. Separate filing. | LR 9 | A |
| NYWD-CONT-107 | Headings for parties / jurisdiction (and venue) / factual background / causes of action / prayer for relief, centered capitals; a jury-demand legend in the caption ("JURY TRIAL DEMANDED" EX-C1, "JURY DEMANDED" EX-C2). Seen across two filers (EX-C1, EX-C2): a convention. An INTRODUCTION heading appears in EX-C2 only (that filer's style). | EX-C1, EX-C2 | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWD-LEN-201 | A memorandum in support of or in opposition to a motion "shall not exceed twenty-five (25) pages in length"; reply memoranda "shall not exceed ten (10) pages". "Tables of contents and tables of authorities are not included in the page limitations." Leave to exceed: by letter at least 7 days before the due date. | LR 7(a)(2)(C) | M |
| NYWD-CONT-201 | On any motion under Fed. R. Civ. P. 12, 56 or 65(a), the moving party files and serves a memorandum of law (the opposing party an answering memorandum). | LR 7(a)(2)(A) | M |
| NYWD-CONT-202 | A notice of motion is required for all motions, stating the relief sought, the grounds, the supporting papers, the return date if known, and whether reply papers will be filed. Separate document; not produced by this template. | LR 7(a)(1) | M (separate document) |
| NYWD-CONT-203 | The motion states with particularity the grounds and the relief sought. | FRCP 7(b)(1) | A |
| NYWD-CONT-204 | Sur-reply papers are not permitted without the judge's permission. | LR 7(a)(6) | A |
| NYWD-CONT-205 | Pro se opponent: counsel serves printed copies of cited unreported decisions on the pro se litigant. | LR 7(a)(8) | A |
| NYWD-CONT-206 | Front matter: table of contents and table of authorities. No rule requires a TOC or TOA (LR 7(a)(2)(C) only excludes them from the page count). Seen in EX-M1 (cover page with caption, title and counsel block, TOC, TOA) and in the proposed brief of EX-M2 (TOC, TOA, no separate cover): TOC and TOA are a convention across two filers; the separate cover page is EX-M1's style. EX-M2 is an amicus filing, so this comparison is weaker than two dispositive memoranda. | EX-M1, EX-M2 | C |
| NYWD-FORM-201 | When the front matter is numbered in roman and the body in arabic, the PDF page labels match (see NYWD-ELEC-004). | APG 4(A) | M |

## Not verified

- Judges' individual practices ("Judge Preferences" on the court site) may add requirements (courtesy copies, page limits, formatting). Not read in this pass.
- FRCP 7.1 / LR 7.1 disclosure statements are separate filings and are not recorded as content of either doc type.
