# District of North Dakota civil filings: rules

Alias `ndd`. Scope: civil complaint and motion-brief documents in the District of North Dakota. The local rules govern form when they specify it; the Federal Rules of Civil Procedure govern otherwise. Verified against the official primary sources below on 2026-10-17. Re-check the official local rules and national rules before each template refresh and at least annually, and whenever the court announces an amendment.

## Primary sources

| Tag | Source | URL | Version checked |
|---|---|---|---|
| DND-LR | District of North Dakota Local Rules | https://www.ndd.uscourts.gov/lci/local_rules.pdf | Effective October 6, 2025; official current PDF checked 2026-10-17 |
| FRCP | Federal Rules of Civil Procedure | https://www.uscourts.gov/forms-rules/current-rules-practice-procedure/federal-rules-civil-procedure | Current official publication checked 2026-10-17; Rules 5, 7, 8, 10, 11, 12, 38 |
| PRIVACY | Federal Rules of Civil Procedure, Rule 5.2 | https://www.uscourts.gov/forms-rules/current-rules-practice-procedure/federal-rules-civil-procedure | Official current publication checked 2026-10-17 |
| EXEMPLARS | Public docket filings saved in each doc-type folder's `usage/` | Their URLs, filer, date filed/retrieved, and SHA-256 are recorded in the respective `usage/SOURCE.md` | Visual convention only |

Kinds: **M** = mandatory; **C** = convention; **T** = repository contract; **A** = filer responsibility.

## Shared civil filing requirements

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NDD-FORM-001 | Standard paper size is 8 1/2 by 11 inches; page numbers appear at the bottom of each page. | D.N.D. Civ. R. 5.1(B)(1), DND-LR p. 23, verified 2026-10-17 | M |
| NDD-FORM-002 | Filings are one-sided, with margins at least one inch, type no smaller than 12 points, and double-spaced text. Case titles and quoted material may be single-spaced. | D.N.D. Civ. R. 5.1(B)(2), DND-LR p. 23, verified 2026-10-17 | M |
| NDD-FORM-003 | Caption designates the appropriate division. | D.N.D. Civ. R. 3.1(A), DND-LR p. 21, verified 2026-10-17 | M |
| NDD-FORM-004 | Papers filed after the initial pleading (other than exhibits) use pleading form and include venue, case title, and file number. | D.N.D. Civ. R. 5.1(B)(3), DND-LR p. 23, verified 2026-10-17 | M |
| NDD-COVER-001 | Court name, title, assigned case number, and the document's nature appear in the caption as required by FRCP 10(a); the complaint title names all parties. | FRCP 10(a), official FRCP publication, verified 2026-10-17 | M |
| NDD-CERT-001 | At least one attorney of record signs a pleading, motion, or other paper; a self-represented party signs. | FRCP 11(a), official FRCP publication, verified 2026-10-17 | M |
| NDD-ELEC-001 | ECF filing and service follow the court's Administrative Policy Governing Electronic Filing and Service; where policy conflicts with a local rule, the policy controls. | DND-LR Preface, pp. 1-2; D.N.D. Civ. R. 5.1(A), p. 23, verified 2026-10-17 | M |
| NDD-AUTH-001 | Filers redact personal identifiers required by FRCP 5.2(a). | FRCP 5.2(a), official FRCP publication, verified 2026-10-17 | A |

## Complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NDD-CONT-001 | A complaint states a short and plain statement of jurisdiction, a short and plain claim showing entitlement to relief, and a demand for relief. | FRCP 8(a)(1)-(3), official FRCP publication, verified 2026-10-17 | M |
| NDD-CONT-002 | Claims and defenses are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate transactions or occurrences are placed in separate counts where clarity requires. | FRCP 10(b), official FRCP publication, verified 2026-10-17 | M |
| NDD-CONT-003 | Complaint alleges the appropriate division in the caption as required for assignment. | D.N.D. Civ. R. 3.1(A), DND-LR p. 21, verified 2026-10-17 | M |
| NDD-CERT-002 | Any jury demand is served no later than 14 days after the last pleading directed to the issue; it may be included in the complaint. | FRCP 38(b), official FRCP publication, verified 2026-10-17 | M (if demanded) |
| NDD-CONT-004 | Caption punctuation, heading style, paragraph spacing, and signature layout follow the complaint exemplars where rules leave a choice. | `complaint/usage/SOURCE.md`, retrieved 2026-10-14 and 2026-10-17 | C |

## Motion brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NDD-CONT-005 | A written motion states its grounds with particularity and states the relief sought. | FRCP 7(b)(1), official FRCP publication, verified 2026-10-17 | M |
| NDD-CONT-006 | A dispositive motion (including a Rule 12 motion) is filed with a supporting memorandum not exceeding 40 pages; a table of contents and authorities, if included, are excluded from the page limit. | D.N.D. Civ. R. 7.1(A)(1)(a), DND-LR pp. 25-26, verified 2026-10-17 | M |
| NDD-CONT-007 | A Rule 12(b) motion states the defense and grounds asserted. | FRCP 12(b), official FRCP publication, verified 2026-10-17 | M |
| NDD-CONT-008 | The court's rule makes a table of contents and table of authorities optional. | D.N.D. Civ. R. 7.1(A)(1)(a), DND-LR p. 26, verified 2026-10-17 | M (optional) |
| NDD-CERT-003 | A corporate disclosure statement or certificate of non-applicability is filed within 14 days of the first filing. | D.N.D. Civ. R. 7.1.1, DND-LR p. 30, verified 2026-10-17 | M |
| NDD-CONT-009 | The memorandum's heading hierarchy, citation presentation, signature, and service certificate follow the motion-brief exemplars when rules leave them open. | `motion-brief/usage/SOURCE.md`, retrieved 2026-10-14 | C |
| NDD-CONT-010 | A proposed order is not required unless the court orders one. | D.N.D. Civ. R. 7.1(B)(3), DND-LR p. 28, verified 2026-10-17 | M |

## Template contract

| ID | Requirement | Kind |
|---|---|---|
| NDD-TOOL-001 | Every sample word appears in the rendered PDF in order; the template contains no case-specific text. | T |
| NDD-TOOL-002 | Mechanical checks cover every applicable mandatory requirement above; each rendered page is visually reviewed. | T |
