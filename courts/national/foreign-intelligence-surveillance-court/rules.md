# Foreign Intelligence Surveillance Court: rules

Alias `fisc`. Scope: motions (FISC Rule 6(d)) filed by the government or a private party, as built by `motion-brief/`. Applications and certifications by the government (Rules 6(a), 6(b), 9) and petitions under Titles IV and VI are outside this doc type. Verified against primary sources on 2026-10-17.

Re-check cadence: the Rules have been unchanged since they took effect November 1, 2010 (the court's Rules of Procedure page, read 2026-10-17, still names them as current). Re-check annually each October, and whenever the court posts new rules (they are promulgated under 50 U.S.C. § 1803(g) and transmitted to Congress).

## Sources

| Tag | Source | URL |
|---|---|---|
| FR | United States Foreign Intelligence Surveillance Court, Rules of Procedure, effective November 1, 2010. Page numbers are the Rules' printed pages. | https://www.fisc.uscourts.gov/sites/default/files/FISC%20Rules%20of%20Procedure.pdf |
| RP | FISC "Rules of Procedure" page (states the 2010 Rules are current and supersede the 2006 rules and procedures) | https://www.fisc.uscourts.gov/rules-procedure |
| EX-* | Filed exemplars in `motion-brief/usage/` (see `SOURCE.md`): the United States (DOJ National Security Division) in Misc. 19-02, and Yahoo! Inc. (ZwillGen PLLC) in 105B(g) 07-01 | local |

Kinds: **M** = mandated by a FISC Rule. **C** = convention (rules leave it open). **T** = project/tooling rule. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **The Rules set almost no typography.** FR 7(c): "on 8½-by-11-inch opaque white paper" and "typed (double-spaced) or reproduced in a manner that produces a clear black image". No font, size or margin rule. Everything else about the look is convention.
2. **Filing is by delivery to the Clerk**, not CM/ECF; electronic filing only when the Court authorizes it, by "reliable, and appropriately secure, electronic means" (FR 7(a), (d), (k)). A signed original and one copy are filed (FR 7(b)).
3. **Private-party submissions carry security-clearance statements and full counsel contact data** in the initial submission (FR 7(h), (i)).
4. **No page limit for motions.** The 20-page limits in FR 25 and 35 apply to petitions and responses under Titles IV and VI, not to motions.

## Requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Form (FR 7)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISC-FORM-001 | Unless otherwise ordered, every submission is on 8 1/2 by 11 inch opaque white paper. | FR 7(c)(1), p. 2 | M |
| FISC-FORM-002 | Typed double-spaced, or reproduced in a manner that produces a clear black image. | FR 7(c)(2), p. 2 | M |
| FISC-FORM-003 | Font and page: the Rules name no typeface, size or margin. Both exemplars (scans with an OCR layer; pages 1-2 rendered and viewed 2026-10-17) use a Times-style serif face, double-spaced body, side margins of roughly one inch, centered bold headings, and the page number centered at the foot. Seen across two filers: convention. The point size cannot be measured reliably from the scans; the template's 12 pt is a choice, not a rule. | EX-accuracy-concerns, EX-yahoo-directives | C |
| FISC-FORM-006 | Classification banner ("UNCLASSIFIED//FOR OFFICIAL USE ONLY") at the top and foot of every page, and portion markings such as "(U)" before headings and paragraphs, on the government's motion. One filer (the government); the private party's unclassified motion has none. | EX-accuracy-concerns; FR 3 | C (one filer) |
| FISC-FORM-004 | Each submission contains citations to pertinent provisions of the Act (FISA). | FR 7(f), p. 2 | M |
| FISC-FORM-005 | Every font used is embedded and is the template's declared face; text extracts on every page. | project | T |

### Contents of a motion (FR 6(d), 7(h), 7(i))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISC-CONT-001 | A party seeking relief other than by application, certification or petition does so by motion. | FR 6(d), p. 2 | M |
| FISC-CONT-002 | Caption: "United States Foreign Intelligence Surveillance Court / Washington, D.C.", the matter title ("In re ..."), and the docket number (e.g. "Misc. 19-02", "No. 105B(g) 07-01"), then the motion title. Seen in both filers. | EX-accuracy-concerns, EX-yahoo-directives | C |
| FISC-CONT-003 | In an adversarial proceeding, a party other than the government includes in its initial submission its full name, address and telephone number, or, if represented, the party's full name and counsel's address, telephone number, facsimile number and bar membership information. | FR 7(h)(1), p. 2 | M (initial submission) |
| FISC-CONT-004 | In an adversarial proceeding, the government's initial submission includes the full names of the attorneys representing the United States and their mailing addresses, telephone numbers and facsimile numbers. | FR 7(h)(2), pp. 2-3 | M (initial submission) |
| FISC-CONT-005 | A party other than the government states in its initial submission whether it (or its responsible officers or employees) and its counsel hold security clearances, describes the circumstances in which they were granted, and identifies the granting agencies and the classification levels and compartments. | FR 7(i), p. 3 | M (initial submission) |
| FISC-CONT-006 | If the government files ex parte a submission containing classified information in an adversarial proceeding, it files and serves an unclassified or redacted version that at a minimum clearly articulates its legal arguments. | FR 7(j), p. 3 | M (conditional) |
| FISC-CONT-007 | Classification markings and handling follow 50 U.S.C. §§ 1803(c), 1822(e), 1861(f)(4), 1881a(k)(1) and Executive Order 13526. The template produces unclassified public versions only. | FR 3, p. 1 | A |
| FISC-CONT-008 | A government motion that relies on facts carries a verification by an agency official under 28 U.S.C. § 1746 (EX-accuracy-concerns). One filer: style, not a rule. | EX-accuracy-concerns | C (one filer) |

### Signature and service (FR 7(b), 7(e), 8)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISC-CERT-001 | A party other than the government serves a copy on the government at or before filing (instructions from DOJ's Security and Emergency Planning Staff). The government, in an adversarial proceeding, serves counsel for the other party by hand or overnight delivery at or before filing. | FR 8(a), (b), p. 3 | M |
| FISC-CERT-002 | A party includes a certificate of service specifying the time and manner of service. | FR 8(c), p. 3 | M |
| FISC-CERT-003 | Signed original and one copy filed with the Clerk; the Clerk may accept a facsimile or scanned signature, which then is the original record. Signature block: "Respectfully submitted," the signer's name and title or firm, address and telephone. Seen in both filers. | FR 7(b), (e), p. 2; EX-* (block layout) | M (signature); C (layout) |
| FISC-CERT-004 | An attorney appearing must be licensed and a member in good standing of a United States district or circuit court bar (government attorneys excepted) and hold the appropriate security clearance. | FR 63, p. 15 | A |

### Filing (FR 7(a), (d), (k))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| FISC-ELEC-001 | A submission is filed by delivering it to the Clerk or as the Clerk directs (instructions from the Clerk at (202) 357-6250); electronic filing only by reliable, appropriately secure electronic means when the Court authorizes it. | FR 7(a), (d), (k), pp. 2-3 | M |
| FISC-ELEC-002 | Publication: an opinion or order is published only at the Court's direction; a movant may move under Rule 62 for publication or release (as in EX-yahoo-directives). | FR 62, p. 15 | A |
