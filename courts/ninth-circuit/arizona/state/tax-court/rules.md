# Arizona Tax Court: motions and memoranda

Alias `ariztaxct`. Scope: motions with supporting memoranda filed in the Arizona Tax Court, the tax department of the Maricopa County Superior Court exercising original jurisdiction (A.R.S. 12-161). Appeals from its judgments go to the Court of Appeals, so no appellate brief format applies here.

Verified against A.R.S. 12-161 (azleg.gov) and the Maricopa County Superior Court Tax Department page on 2026-10-22; the court's own filing rules are not verified (see Status).

## Status: BLOCKED (court rules not retrieved)

The court's own filing-form rules were not retrieved, so this file records **no `M` (mandated) requirement**. The motion-brief template is not judged against any mandated form until the rules are fetched and the rows below are written.

- Arizona Rules of Civil Procedure, rule 5.2 (form of documents), and the Arizona Rules of Tax Court procedure (rule 2 is cited by the court's exemplar): `https://www.azcourts.gov/` and its rules pages. Not retrieved: every URL on azcourts.gov returned HTTP 403 to curl on 2026-10-22 (tried the Supreme Court home page and the civil-rules, court-rules and rule-order PDF paths, twice each, with the same browser user agent as the other courts). WebFetch is blocked for the same host.
- Maricopa County Superior Court local rules (exemplar cites Local Practice Rule 3.2): no rules page was found on `https://superiorcourt.maricopa.gov/` (`/rules/` and `/court-resources/court-rules/` returned HTTP 404 on 2026-10-22). Not retrieved.

Retry the azcourts.gov URLs and add the rows (ID, requirement, source, kind) before the template is judged. Until then `fb check` runs the default tier-1 set (`data/checks-default.yaml`) only; no page limit or margin is asserted.

## Sources

| Tag | Source | URL | Status |
|---|---|---|---|
| A.R.S. 12-161 | Arizona Revised Statutes 12-161, definition of tax court (the tax department of the Maricopa County superior court; the Arizona tax court) | https://www.azleg.gov/ars/12/00161.htm | Fetched HTTP 200 on 2026-10-22 |
| Tax Court page | Maricopa County Superior Court, Tax Department page (states the Tax Court follows the rules of evidence and civil procedure) | https://superiorcourt.maricopa.gov/departments/superior-court/tax/ | Fetched HTTP 200 on 2026-10-22 |
| ARCP 5.2 | Arizona Rules of Civil Procedure, rule 5.2 (form of documents) | https://www.azcourts.gov/ | Not retrieved: HTTP 403 on 2026-10-22 |
| Ariz. R. Tax Ct. 2 | Arizona Rules of Tax Court procedure, rule 2 (cited by the exemplar) | https://www.azcourts.gov/ | Not retrieved: HTTP 403 on 2026-10-22 |
| Maricopa LPR 3.2 | Maricopa County Superior Court Local Practice Rules, rule 3.2 (cited by the exemplar) | https://superiorcourt.maricopa.gov/ | Not retrieved: rules index HTTP 404 on 2026-10-22 |

Kinds, when rows are added: **M** mandated by a rule, **C** convention seen across filers, **T** project rule, **A** author responsibility.

## Requirements

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARIZTAXCT-FORM-001 | No form requirement for motions is asserted: the court's filing-form rules (see Status) are not yet recorded, so no check enforces a mandated margin, font, spacing or length. Rows are added here, each with its rule text, URL and verification date, once retrieved. | Project rule (docs/EVAL-LOOP.md, "Adding a court", step 1) | T |

## Exemplar (one filer, tier 3 until a second exemplar exists)

`usage/FILED-EXAMPLE-motion-brief.pdf` (Vangilder v. Arizona Department of Revenue, No. TX2017-000663, motion for preliminary injunction, filed 2018-02-26, 16 pages). Its cover is the superior-court caption: "IN THE SUPERIOR COURT OF ARIZONA / IN THE ARIZONA TAX COURT", counsel block at top left, a two-column caption with the case number and title at right, and the judge's name in parentheses. It shows no table of contents or authorities for a motion of this length. One filer cannot settle a convention, so none of this is recorded as `C`.

## Open items

- **Tier 1 not written.** Write the ARIZTAXCT rows from ARCP 5.2 and Tax Court rule 2 once azcourts.gov is reachable.
- **Tier 2 not judged.** Only one court-root exemplar exists; a second filer's motion is needed before any cover or caption choice can be called a convention.
- **Exemplar search.** Tax Court filings are on the Clerk's registered eAccess, so no second public motion has been found (see `usage/SOURCE.md`).
