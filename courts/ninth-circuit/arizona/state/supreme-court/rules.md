# Arizona Supreme Court: briefs, petitions, motions, and amicus briefs

Alias `ariz`. Scope: briefs on the merits, answering and reply briefs, amicus curiae briefs, motions, petitions for review, petitions for discretionary review, petitions for rehearing (motion for reconsideration), and petitions for special action (writ) filed in the Arizona Supreme Court.

Verified against the court's own sources on 2026-10-22: none. The official Arizona court rules pages returned HTTP 403 to every request (see Status). Nothing in this file is a verified rule.

## Status: BLOCKED (court rules not retrieved)

No Arizona rule has been retrieved, so this file records **no `M` (mandated) requirement**. The templates in the doc folders run the repo default tier-1 set only (`data/checks-default.yaml`: US letter pages, 12 point body text, 1 inch margins, no page limit). Those are defaults, not Arizona requirements. Cover contents, section order, certificates, word or page limits and the e-filing PDF rules are unverified. A PR built on this file must say so.

- Arizona Rules of the Supreme Court (including Rule 31 and its form rules for petitions for review and briefs): `https://www.azcourts.gov/rules/Arizona-Rules-of-the-Supreme-Court` (HTTP 403 to curl with a browser User-Agent and to WebFetch, 2026-10-22).
- Arizona Rules of Civil Appellate Procedure (ARCAP, including Rule 14 on the form of briefs and Rule 4 on the format of documents): `https://www.azcourts.gov/rules/Arizona-Rules-of-Civil-Appellate-Procedure` (HTTP 403 to curl and WebFetch, 2026-10-22).
- Supreme Court rules index: `https://www.azcourts.gov/rules/Supreme-Court-Rules` (HTTP 403 to curl, 2026-10-22); home page `https://www.azcourts.gov/` (HTTP 403 to curl, 2026-10-22).
- Administrative orders on e-filing and document format: not located on the court site (the site refused every request).
- `https://www.azleg.gov/` (HTTP 200) publishes statutes only and does not host the court rules, so it is not cited.

Retry the azcourts.gov URLs above (one at a time, with a browser User-Agent and a pause between requests) from a host that can reach the site, then write the rows.

## Sources

| Tag | Source | URL | Status |
|---|---|---|---|
| Supreme Court rules | Arizona Rules of the Supreme Court | https://www.azcourts.gov/rules/Arizona-Rules-of-the-Supreme-Court | Not retrieved: HTTP 403 on 2026-10-22 |
| ARCAP | Arizona Rules of Civil Appellate Procedure | https://www.azcourts.gov/rules/Arizona-Rules-of-Civil-Appellate-Procedure | Not retrieved: HTTP 403 on 2026-10-22 |
| Rules index | Arizona Supreme Court, rules index | https://www.azcourts.gov/rules/Supreme-Court-Rules | Not retrieved: HTTP 403 on 2026-10-22 |

Kinds, when rows are added: **M** mandated by a rule, **C** convention seen across filers, **T** project rule, **A** author responsibility.

## Requirements

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARIZ-FORM-001 | No form requirement for briefs or petitions is asserted: the Arizona rules listed above were not retrieved, so no check enforces a mandated margin, font, spacing, length or cover content for this court. Rows are added here, each with its rule text, URL and verification date, once retrieved. | Project rule (docs/EVAL-LOOP.md, "Adding a court", step 1) | T |

## Exemplars

Court-root exemplars in `usage/` (one per doc type, public filed PDFs; see `SOURCE.md` in each doc folder): amicus-brief, answering-brief, brief-on-the-merits, motion-brief, petition-for-discretionary-review, petition-for-rehearing, petition-for-review, petition-for-writ, reply-brief.

## Open items

- **Tier 1 not written.** Retrieve the Arizona Rules of the Supreme Court and ARCAP from the court's site and record the rows (font, size, margins, spacing, length, cover, certificates, e-filing).
- **Tier 2 not judged.** Each exemplar comes from a single filer, so no tier-2 convention is claimed.
