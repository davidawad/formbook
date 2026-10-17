# District of Maine (district court): rules

Alias `med`. Scope: civil papers filed by counsel through CM/ECF in the United States District Court for the District of Maine; doc types `complaint` (an initial civil complaint) and `motion-brief` (a motion with its incorporated memorandum of law, D. Me. Local R. 7(a)). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (when amendments to the Federal Rules take effect) and whenever the court posts amended Local Rules (the current PDF's title page reads "These rules are current as of April 1, 2025").

## Sources

| Tag | Source | URL |
|---|---|---|
| LR | Local Rules of the United States District Court for the District of Maine, title page "These rules are current as of April 1, 2025" (163-page PDF, PDF creation date 2026-06-24), including Appendix B "Administrative Procedures Governing the Filing and Service by Electronic Means". The court site returned "Request Rejected" (HTTP 404) to every direct download on 2026-10-17, so the text was read from the Internet Archive capture of the official URL dated 2026-07-29 (sha256 131911bf...2232). Page numbers below are the printed page numbers. | https://www.med.uscourts.gov/sites/med/files/LocalRules.pdf (read via https://web.archive.org/web/20260729204053id_/https://www.med.uscourts.gov/sites/med/files/LocalRules.pdf) |
| FRCP | Federal Rules of Civil Procedure 5(d)(1)(B), 7(b)(1), 7.1, 8(a), 10(a)-(b), 11(a) (LII text) | https://www.law.cornell.edu/rules/frcp/rule_5, .../rule_7, .../rule_7.1, .../rule_8, .../rule_10, .../rule_11 |
| EX-C1 | Complaint exemplar: Taco Barr, LLC (Brann & Isaacson), No. 2:26-cv-00470, ECF 1 | `complaint/exemplars/SOURCE.md` §1 |
| EX-C2 | Complaint exemplar: Austin Jacob Gagne (Island Justice; Consumer Attorneys), No. 2:26-cv-00301, ECF 1 | `complaint/exemplars/SOURCE.md` §2 |
| EX-M1 | Motion exemplar: Botana and Portland Public Schools (Drummond Woodsum), No. 2:26-cv-00342, ECF 3 | `motion-brief/exemplars/SOURCE.md` §1 |
| EX-M2 | Motion exemplar: Town of Freeport (Bernstein Shur), No. 2:26-cv-00117, ECF 7 | `motion-brief/exemplars/SOURCE.md` §2 |

Kinds: **M** = mandated by a court rule (FRCP or D. Me. Local Rule). **C** = convention (the rules leave it open; taken from the exemplars, with the filers that show it). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings:

1. **The local rule sets the form, including font size.** LR 10(b)(1): "documents must be typewritten in 12-point font or larger, except that footnotes may be in 10-point font or larger". No typeface is named. FRCP sets no form rules of its own.
2. **Every motion incorporates its memorandum** (LR 7(a)); there is no separate memorandum filing. Page limits are in pages, not words (LR 7(d)(1)).
3. **No certificate of service is needed for CM/ECF service** (FRCP 5(d)(1)(B)); the local ECF procedures (App. B (e)(3)) still require paper service on unregistered parties, and then a certificate is needed under FRCP 5(d)(1)(B)(i).

## Court-wide requirements (all doc types)

### Page form (LR 10)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-FORM-001 | Each page measures 8 1/2 x 11 inches (612 x 792 pt). | LR 10(b)(3), p. 19 | M |
| MED-FORM-002 | Margins of 1 inch on the top, bottom and each side of the page. | LR 10(b)(5), p. 19 | M |
| MED-FORM-003 | Font size: "typewritten in 12-point font or larger, except that footnotes may be in 10-point font or larger". The rule names no typeface. | LR 10(b)(1), p. 19 | M |
| MED-FORM-004 | "text must be double-spaced, except that block quotations, headings, and footnotes may be single-spaced". | LR 10(b)(2), p. 19 | M |
| MED-FORM-005 | "each page must be numbered at the bottom". | LR 10(b)(4), p. 19 | M |
| MED-FORM-006 | Supporting documents are attached to the main document with the ECF attachment function (not merged into the main PDF). | LR 10(b)(6), p. 19 | M |
| MED-FORM-007 | Typeface: Times New Roman (serif). Seen in EX-C2, EX-M1, EX-M2 (three filers; EX-C1's fonts are unnamed CID fonts). The rules leave the face open. | EX-C2, EX-M1, EX-M2 | C |
| MED-FORM-008 | Page number centered at the foot, Arabic numerals, starting at 1 on the caption page. Seen in EX-C1, EX-C2, EX-M1, EX-M2. | EX (all four) | C |
| MED-FORM-009 | Every font used is embedded and is the template's declared family. | project | T |

### Caption and title (LR 10(a), FRCP 10(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-COVER-001 | Every pleading, motion and other paper (except exhibits) has a caption containing the case number on the first page. | LR 10(a), p. 19 | M |
| MED-COVER-002 | The title of the filing and the party filing the document are placed immediately under the caption. | LR 10(a), p. 19 | M |
| MED-COVER-003 | Caption carries the court's name, a title, a file number and a Rule 7(a) designation; a complaint's title names all the parties. | FRCP 10(a) | M |
| MED-COVER-004 | If the filing seeks immediate relief, its title states "Request for Immediate Relief". | LR 3(d), p. 3 | M (conditional) |
| MED-COVER-005 | If a party believes a three-judge district court is required (28 U.S.C. § 2284), the caption includes "Three-Judge District Court Requested". | LR 9, p. 18 | M (conditional) |
| MED-COVER-006 | Court name centered on two lines ("UNITED STATES DISTRICT COURT" / "[FOR THE] DISTRICT OF MAINE"); party block on the left closed by a column of ")" marks, case number to the right. The ")" column is in EX-C1, EX-M1, EX-M2 (three filers); EX-C2 uses an open two-column caption without ")". | EX (all four) | C |

### Signature and electronic filing (LR App. B, FRCP 11(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-ELEC-001 | Only electronically converted PDFs (created from the word-processing file, text searchable) may be filed through ECF; scanned PDFs may not, unless a rule or order allows. PDF software that adds proprietary or advertising content is prohibited. | LR App. B, "Electronic Filing and PDF", p. 118 | M |
| MED-ELEC-002 | A filed document may not be password-protected or encrypted. | LR App. B (g)(11), p. 123 | M |
| MED-ELEC-003 | Every electronically filed document includes a signature block with the attorney's name, address, telephone number and e-mail address; the ECF user's name is preceded by "/s/" in the space where the signature would appear. | LR App. B (h)(1), p. 123; FRCP 11(a) | M |
| MED-ELEC-004 | Documents signed under oath (verified complaints, declarations) are filed with "/s/" and the typed name; the filing attorney keeps the original for at least 2 years after the appeal period. | LR 10(c), pp. 19-20 | M (conditional) |
| MED-ELEC-005 | Registered users are served by the Notice of Electronic Filing; unregistered attorneys and pro se parties must be served on paper under FRCP 5. | LR App. B (e)(1), (e)(3), p. 120 | M |

### Certificates and disclosures

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-CERT-001 | No certificate of service when the paper is served by filing with ECF; when served by other means, a certificate of service is filed with it or within a reasonable time. | FRCP 5(d)(1)(B) | M (conditional) |
| MED-CERT-002 | A non-governmental corporate party (defined broadly: LLCs, partnerships, trusts, etc.) files a disclosure statement with its first appearance; in diversity cases every party does. A separate filing, not part of the template. | LR 7.1(a)-(b), p. 16; LR 3(e), p. 3; FRCP 7.1 | M (separate filing) |

## Doc type: complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-CONT-001 | Case-opening documents are e-mailed in PDF to MaineECFIntake@med.uscourts.gov (with summons and civil cover sheet) unless exempt; the clerk dockets them. | LR 3(a), p. 3; LR App. B (c)(1), p. 119 | M (filing step) |
| MED-CONT-002 | Every complaint is accompanied by a completed civil cover sheet (separate form). | LR 3(c), p. 3 | M (separate filing) |
| MED-CONT-003 | Claims are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts where that promotes clarity. | FRCP 10(b) | M |
| MED-CONT-004 | The complaint contains a short and plain statement of the grounds for jurisdiction, a short and plain statement of the claim, and a demand for the relief sought. | FRCP 8(a) | A |
| MED-CONT-005 | A complaint challenging the constitutionality of an Act of Congress or a state statute requires a separate "Notice of Constitutional Question" pleading. | LR 3(f), p. 3; LR 5.1, p. 7 | M (separate filing) |
| MED-CONT-006 | Social Security review complaints under 42 U.S.C. § 405(g) use the form in Appendix C. Out of scope for this template. | LR 3(i), p. 4 | M (out of scope) |
| MED-CONT-007 | The caption leaves the case number to the clerk ("Civil Action No.:" with a blank, EX-C1; "Civil Case No.: 2:26-cv-____", EX-C2). | EX-C1, EX-C2 | C |
| MED-CONT-008 | Title "COMPLAINT" centered under the caption; level-1 section headings (INTRODUCTION, JURISDICTION/PARTIES, counts) centered in capitals; paragraph numbers indented with a tab before the text. Seen in EX-C1 and EX-C2. | EX-C1, EX-C2 | C |
| MED-CONT-009 | Jury demand: EX-C1 puts it on a separate "Demand for Jury Trial" page; EX-C2 states "JURY TRIAL DEMANDED" in the caption. Each is one filer's style. | EX-C1, EX-C2 | C (filer style; either acceptable) |
| MED-CONT-010 | Paragraph numbering runs continuously through the whole complaint (EX-C1, EX-C2). | EX-C1, EX-C2 | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-CONT-101 | "Every motion must incorporate a memorandum of law." Affidavits and supporting documents are filed with the motion. | LR 7(a), p. 14 | M |
| MED-CONT-102 | A motion is in writing, states with particularity the grounds, and states the relief sought. | FRCP 7(b)(1) | M |
| MED-LEN-101 | Memorandum supporting or opposing a nondispositive motion: at most 10 pages. Dispositive motions (to dismiss, for judgment on the pleadings, summary judgment, injunctive relief, any other dispositive motion): at most 20 pages. Reply: at most 7 pages. The rule does not say which parts (caption, signature, certificate) count; the checks count every page of the main document. | LR 7(d)(1), p. 14 | M |
| MED-LEN-102 | A motion to exceed the page limits must be filed at least 3 business days before the memorandum's deadline. | LR 7(d)(2), p. 14 | A |
| MED-CONT-103 | Oral argument may be requested in the caption of the motion, objection or reply (or by the court's form within 5 days of the reply). | LR 7(e), pp. 14-15 | M (conditional) |
| MED-CONT-104 | An objection is due within 21 days and also incorporates a memorandum of law; a reply (within 14 days) is confined to new matter in the objection. | LR 7(b)(1), 7(c), p. 14 | A |
| MED-CONT-105 | Summary-judgment motions additionally need the separate statement of material facts under LR 56(b). Out of scope for this template. | LR 56(a)-(b), p. 53 | M (out of scope) |
| MED-CONT-106 | Motion title in capitals immediately under the caption naming the movant (EX-M1: "DEFENDANTS' MOTION TO DISMISS THE COMPLAINT WITH INCORPORATED MEMORANDUM OF LAW"); opening paragraph citing the rule invoked (both EX-M1 and EX-M2 open "Pursuant to Fed. R. Civ. P. 12(b)(6)"). | EX-M1, EX-M2 | C |
| MED-CONT-107 | Section headings centered in bold capitals (INTRODUCTION / PRELIMINARY STATEMENT, background, argument, CONCLUSION). Seen in EX-M1 and EX-M2. | EX-M1, EX-M2 | C |
| MED-CERT-101 | Certificate of service at the end, only when paper service is needed (EX-M2 has one; EX-M1 has none). | FRCP 5(d)(1)(B); EX-M1, EX-M2 | M (conditional) |

## Author responsibilities

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MED-AUTH-001 | Signer's address, e-mail address and telephone number in the signature block; the signature certifies the FRCP 11(b) representations. | FRCP 11(a)-(b) | A |
| MED-AUTH-002 | Pleadings are docketed under the court's approved list of ECF events. | LR App. B (d)(3), p. 120 | A |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| MED-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| MED-TOOL-002 | No case-specific text and no measured coordinates in the template. | T |
| MED-REVIEW-001 | A recorded visual review of the current PDF covers every page (Gate 2). | T |

Not verified: the court's forms page (civil cover sheet, oral-argument form) was not fetched; the site rejected direct requests on 2026-10-17.
