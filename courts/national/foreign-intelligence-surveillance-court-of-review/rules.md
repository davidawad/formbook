# Foreign Intelligence Surveillance Court of Review: rules

Alias `fiscr`. Scope: amicus curiae briefs (FISCR Rule 15), as built by `amicus-brief/`, by a court-appointed amicus (50 U.S.C. § 1803(i)) or a volunteer amicus granted leave. Verified against primary sources on 2026-10-17.

Re-check cadence: the Rules carry the version footer "May-18" and take effect six months after transmittal to Congress (Rule 21). Re-check annually each October and whenever the FISC/FISCR Rules of Procedure page posts new rules; re-check FRAP 29 and 32 each December 1 (FRAP amendments take effect then), because Rules 14(d) and 15(d)(2) incorporate them.

## Sources

| Tag | Source | URL |
|---|---|---|
| FR | United States Foreign Intelligence Surveillance Court of Review, Rules of Procedure (version "May-18", 24 printed pages). Page numbers are printed pages. | https://www.fisc.uscourts.gov/sites/default/files/Rules%20of%20Procedure.pdf |
| RP | FISC/FISCR "Rules of Procedure" page ("Court of Review" link) | https://www.fisc.uscourts.gov/rules-procedure |
| FRAP-32 | Fed. R. App. P. 32 (form of briefs), as published by LII on 2026-10-17 (includes the 2024 amendment notes) | https://www.law.cornell.edu/rules/frap/rule_32 |
| FRAP-29 | Fed. R. App. P. 29 (amicus briefs), as published by LII on 2026-10-17 | https://www.law.cornell.edu/rules/frap/rule_29 |
| EX-donohue | `amicus-brief/usage/SAMPLE-fiscr-amicus-brief-certificationofquestionsfiscr1801.pdf` (court-appointed amicus Prof. Laura K. Donohue) | local |
| EX-rcfp | `amicus-brief/usage/SAMPLE-fiscr-amicus-brief-reporterscommitteefiscr1801.pdf` (volunteer amicus, The Reporters Committee for Freedom of the Press) | local |

Kinds: **M** = mandated by a FISCR Rule or a FRAP provision it incorporates. **C** = convention. **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **FRAP 32(a) governs the form**, by incorporation (FR 14(d), 15(d)(2)): 14-point proportionally spaced serif face, double spacing, 1-inch margins. FR 9(c) adds that the page number goes in the lower margin.
2. **Length depends on who the amicus is.** A court-appointed amicus gets the full principal-brief limit of FRAP 32(a)(7) (13,000 words); any other amicus gets FRAP 29(a)(5)'s half (6,500 words) (FR 15(d)(2)).
3. **Corporate disclosure includes foreign ownership, control or influence** (Intelligence Community Standard 700-01), and goes before the table of contents (FR 12).
4. **Filing is by delivery to the Clerk**, with a signed original and three copies (FR 9(b)(4)); four copies of each brief (FR 16(b)).

## Requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Form (FR 9(c), FRAP 32(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISCR-FORM-001 | 8 1/2 x 11 inch opaque white paper. | FR 9(c)(1), p. 9; FRAP 32(a)(4) | M |
| FISCR-FORM-002 | Typed double-spaced; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced (FRAP). | FR 9(c)(2), p. 9; FRAP 32(a)(4) | M |
| FISCR-FORM-003 | Margins at least one inch on all four sides. | FR 9(c)(3), p. 9; FRAP 32(a)(4) | M |
| FISCR-FORM-004 | Page numbered in the lower margin of the page. | FR 9(c)(4), p. 9 | M |
| FISCR-FORM-005 | "A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions. A proportionally spaced face must be 14-point or larger" (or a monospaced face of no more than 10 1/2 characters per inch). | FR 14(d), p. 15; FR 15(d)(2), p. 18; FRAP 32(a)(5) | M |
| FISCR-FORM-006 | Plain roman style; italics or boldface for emphasis; case names italicized or underlined. | FRAP 32(a)(6) | M |
| FISCR-FORM-007 | Cover contents: case number centered at the top; name of the court; title of the case; nature of the proceeding and the court below; title of the brief identifying the party for whom filed; counsel's name, office address and telephone. An amicus cover also identifies the party supported and whether the brief supports affirmance or reversal. Cover color (green for amicus) applies to paper copies. | FRAP 32(a)(2); FRAP 29(a)(4) | M |
| FISCR-FORM-008 | Cover layout differs between the two filers: the court-appointed amicus centers "Docket No. FISCR 18-01" at the top, sets the court name in blackletter, and uses short centered rules (EX-donohue); the Reporters Committee uses a district-court-style caption box with the docket number to the right (EX-rcfp). No common convention beyond the FRAP 32(a)(2) items; each is one filer's style. | EX-donohue, EX-rcfp (page 1 rendered and viewed 2026-10-17) | C (one filer each) |
| FISCR-FORM-009 | Every font used is embedded and is the template's declared face; text extracts on every page. | project | T |

### Length (FR 15(d)(2), FRAP 29(a)(5), FRAP 32(a)(7), 32(f))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISCR-LEN-001 | Court-appointed amicus: the principal-brief limit of FRAP 32(a)(7): 30 pages, or 13,000 words (monospaced: 1,300 lines) with a certificate. | FR 15(d)(2), p. 18; FRAP 32(a)(7) | M |
| FISCR-LEN-002 | Any other amicus: no more than one-half the maximum length for a party's principal brief (6,500 words, or 15 pages without a word count). | FR 15(d)(2); FRAP 29(a)(5) | M |
| FISCR-LEN-003 | Excluded from the count (FRAP 32(f)): cover, disclosure statement, table of contents, table of citations, statement regarding oral argument, addendum of statutes and rules, certificates of counsel, signature block, proof of service, any item the court exempts. | FRAP 32(f) | M |

### Contents (FR 12, 14(a), 15(d)(1), FRAP 29(a)(4))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISCR-CONT-001 | An amicus brief conforms to FR 14(a)(2)-(8) and (10), without the jurisdictional statement, statement of the issues or standard of review: table of contents with page references; table of authorities (cases alphabetically, statutes, other authorities) with page references; statement of the case (with record references to the appendix); summary of the argument (not a repetition of headings); argument; certificate of compliance. | FR 15(d)(1), p. 18; FR 14(a), p. 15 | M |
| FISCR-CONT-002 | FRAP 29(a)(4) items: a concise statement of the identity of the amicus, its interest, and the source of its authority to file; for a non-governmental amicus, the authorship and funding statement (whether a party's counsel authored it; whether a party or its counsel, or any other person, contributed money to fund it). | FR 15(d)(2) (FRAP 29(a)(5) and 32(a) incorporated; 29(a)(4) applies through FRAP 29 itself); FRAP 29(a)(4)(D), (E) | M |
| FISCR-CONT-003 | A nongovernmental corporate party (and, through FRAP 29(a)(4)(A), a corporate amicus) files a statement identifying any parent corporation and any publicly held corporation owning 10% or more of its stock (or that there is none), and whether any parent or 10% owner is under foreign ownership, control or influence as defined in Intelligence Community Standard 700-01; in a principal brief it appears before the table of contents. EX-rcfp carries a "Corporate Disclosure" statement on page 2 (unincorporated association, no parent, no stock). | FR 12(a), (b), p. 13; FRAP 29(a)(4)(A) | M |
| FISCR-CONT-004 | Use the FISC designation or a descriptive term ("the government", "the service provider") rather than "appellant"/"appellee". | FR 14(e), p. 16 | A |
| FISCR-CONT-005 | Record references are to the appendix pages ("App. 1"); briefs may refer only to parts of the record reproduced in the appendix. | FR 14(f)(4), p. 16 | A |
| FISCR-CONT-006 | Section order in both exemplars: cover; (corporate disclosure, EX-rcfp); table of contents; table of authorities; identity and interest of amicus; summary of the argument; argument; conclusion; certificate(s). Seen across two filers: convention. | EX-donohue, EX-rcfp | C |
| FISCR-CONT-007 | A volunteer amicus participates only by motion for leave (FR 15(a)(3)); EX-rcfp's brief keeps the "[Proposed]" label after filing. | FR 15(a)(3), p. 17; EX-rcfp | M (motion); C (label) |

### Contact, clearance, signature, service (FR 9(d)-(f), 10, 16)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISCR-CERT-001 | Initial filing by a party other than the government includes counsel's full name, address, telephone, facsimile, email and bar membership, and the party's full name; the government's initial filing gives its attorney's name, mailing address, telephone, facsimile and email. | FR 9(d), p. 9 | M (initial filing) |
| FISCR-CERT-002 | A party other than the government states in its initial submission whether it and its counsel hold a security clearance, the granting agency (with point of contact) and the clearance level. | FR 9(e), pp. 9-10 | M (initial filing) |
| FISCR-CERT-003 | Every submission is signed by the filing party or one of its attorneys. | FR 9(f), p. 10 | M |
| FISCR-CERT-004 | Certificate of compliance (FRAP 32(g)) when length is computed by words or lines. | FR 14(a)(10), p. 15; FRAP 29(a)(4)(G) | M |
| FISCR-CERT-005 | Certificate of service specifying the time and manner of service; a non-government filer serves the government through DOJ's Litigation Security Group. | FR 10(a), (c), p. 11 | M |
| FISCR-CERT-006 | Appointed amicus serves and files its brief within 28 days after the appellant's brief is made available; four copies of each brief filed, two served on each separately represented party. | FR 16(a), (b), p. 19 | A |
| FISCR-ELEC-001 | Filing by delivery to the Clerk, or by reliable and appropriately secure electronic means approved in advance by the Clerk; signed original and three copies unless otherwise provided; facsimile or scanned signatures may be accepted. | FR 9(b), p. 9 | M |
| FISCR-ELEC-002 | Attorneys appearing must be licensed, members of a federal district or circuit bar (government attorneys excepted), and hold the appropriate security clearance. | FR 19, p. 22 | A |
