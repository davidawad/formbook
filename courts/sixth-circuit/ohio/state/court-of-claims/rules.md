# Ohio Court of Claims: motions and memoranda

Alias `ohioctcl`. Scope: motions with their supporting memorandum (the combined motion-and-memorandum form the court receives), filed in the Court of Claims of Ohio. Verified against the Local Rules of the Court of Claims of Ohio (consolidated 2025 text, as amended by the journal entry of November 6, 2025) and the Administrative Rules Regarding Electronic Filing in the Court of Claims (January 16, 2024) on 2026-10-21.

Face: the court's e-filing rules name Times New Roman or Arial (Admin. Rules § VII (D)). This template declares Times New Roman. No Liberation Serif fallback is declared; the pinned Times New Roman files are required for a render (docs/FONTS.md).

Limits: no order in the record reduces or relaxes the 15-page limit of L.C.C.R. 4 (E). The template enforces 15 pages for the whole rendered document, certificate of service included (conservative reading: the rule excludes only attachments).

Civil Rules: L.C.C.R. 1 (A) applies the Civil Rules not clearly inapplicable to R.C. Chapter 2743 proceedings. Local rules not retrieved: https://www.supremecourt.ohio.gov/docs/LegalResources/Rules/civil/CivilProcedure.pdf (the Ohio Rules of Civil Procedure text) gave no response on two attempts (curl exit 28 and HTTP 000, 2026-10-21); no Civil Rules figure is relied on for a rule row below.

## Sources

| Tag | Source | URL |
|---|---|---|
| LCCR | Local Rules of the Court of Claims of Ohio (consolidated text; Rules 1, 4, 25 read; amended November 6, 2025) | https://ohiocourtofclaims.gov/wp-content/uploads/2025/11/local-rules-2025.pdf |
| LCCR-AMEND | Journal entry amending the Local Rules (adds Rule 23, Receiverships; effective November 6, 2025) | https://ohiocourtofclaims.gov/wp-content/uploads/2025/11/order-amending-rules-november-2025.pdf |
| EFILE | Administrative Rules Regarding Electronic Filing in the Court of Claims (January 16, 2024; §§ III, VII) | https://ohiocourtofclaims.gov/wp-content/uploads/2024/01/Admin-Rules-for-E-Filing-1-16-24.pdf |
| RULES-PAGE | Court of Claims rules and statutes page (index of the rules above) | https://ohiocourtofclaims.gov/resources/rules-statutes/ |

The court's site returns HTTP 403 to a default user agent and HTTP 200 to a browser user agent; every URL above was fetched with a browser user agent on 2026-10-21 and returned HTTP 200.

## Form of every paper

| ID | Requirement | Source | Kind |
|---|---|---|---|
| OHIOCTCL-FORM-001 | Papers are 8½ × 11 inch. The top one and one-half inches of every page is left blank (filing and binding space). | L.C.C.R. 4 (A) (1) | M |
| OHIOCTCL-FORM-002 | An electronically filed document is double-spaced, in Times New Roman or Arial, at least 12 point. | EFILE § VII (D) | M |
| OHIOCTCL-FORM-003 | Electronic documents are PDF, searchable and tagged. Each document has no external links. | EFILE § VII (intro) | M |
| OHIOCTCL-FORM-004 | Side and bottom margins: no figure is stated. One inch is used (conventional). | none; convention | C |
| OHIOCTCL-FORM-005 | Page numbers appear at the bottom of each page (conventional; the rules state no numbering rule). | none; convention | C |
| OHIOCTCL-PRIV-001 | Personal identifiers are partially redacted from every document that becomes a public record, unless the hearing officer orders otherwise. | EFILE § III (A) | M |

## Caption, counsel, and identification

| ID | Requirement | Source | Kind |
|---|---|---|---|
| OHIOCTCL-CONT-001 | Caption: the court name (IN THE COURT OF CLAIMS OF OHIO), the case number, the name of the first party plaintiff and the first party defendant. | L.C.C.R. 4 (A) (1) | M |
| OHIOCTCL-CONT-002 | Each paper is identified by its title. | L.C.C.R. 4 (A) (1) | M |
| OHIOCTCL-CERT-001 | The paper bears the name, Supreme Court Registration Number, mailing address, e-mail and telephone number of trial counsel (a self-represented party gives the same contact data without a registration number). | L.C.C.R. 4 (A) (1) | M |
| OHIOCTCL-ELEC-001 | The e-filed document shows the case number, the party's name, the filing party, the type of filing, and enough other information to identify it. | EFILE § VII (E) | M |
| OHIOCTCL-CERT-002 | Signature: a conformed "/s/ Name" signature, followed by the name, the Ohio Supreme Court ID number, the party represented, the firm, address, telephone and e-mail. | EFILE § VII (F) (a) | M |

## Motions and supporting memoranda

| ID | Requirement | Source | Kind |
|---|---|---|---|
| OHIOCTCL-MOT-001 | A motion is determined without oral argument unless the court orders otherwise. The movant files with the motion a brief written statement of reasons and the authorities relied upon. | L.C.C.R. 4 (C) | M |
| OHIOCTCL-MOT-002 | A motion to dismiss under Civ.R. 12 (B) (6) states its grounds and authorities; the brief is part of the same filing in this court's combined form. | L.C.C.R. 4 (C), 1 (A) | C |
| OHIOCTCL-LEN-001 | Supporting, opposing, or memorandum briefs do not exceed fifteen pages, exclusive of attachments. Long-brief leave is sought by motion. | L.C.C.R. 4 (E) | M |
| OHIOCTCL-CERT-003 | A certificate of service on the parties, in the form the filer uses (the exemplar's form: date, method, the recipients' addresses, conformed signature). No local rule states the form. | convention; no L.C.C.R. text | C |

## Template-only requirement

| ID | Requirement | Kind |
|---|---|---|
| OHIOCTCL-TPL-001 | A reusable template contains no case-specific text, measured coordinates, or forced line breaks. | T |
