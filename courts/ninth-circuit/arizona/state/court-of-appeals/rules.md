# Arizona Court of Appeals: briefs, petitions, motions, and amicus briefs

Alias `arizctapp`. Scope: briefs (opening, answering and reply), motions, amicus curiae briefs, petitions for review, and petitions for special action (writ) filed in the Arizona Court of Appeals, Division One and Division Two.

Verified against the court's own sources on 2026-10-22: none. The official Arizona court rules pages returned HTTP 403 to every request (see Status). Nothing in this file is a verified rule.

## Status: BLOCKED (court rules not retrieved)

No Arizona rule has been retrieved, so this file records **no `M` (mandated) requirement**. The templates in the doc folders run the repo default tier-1 set only (`data/checks-default.yaml`: US letter pages, 12 point body text, 1 inch margins, no page limit). Those are defaults, not Arizona requirements. Cover contents, section order, certificates, word limits and the e-filing PDF rules are not yet recorded.

- Arizona Rules of Civil Appellate Procedure (ARCAP, including Rule 14 on the form of briefs and its certificate of compliance, and Rule 4 on the format of documents): `https://www.azcourts.gov/rules/Arizona-Rules-of-Civil-Appellate-Procedure`. Not retrieved: HTTP 403 to curl with a browser user agent, retried after a pause, 2026-10-22.
- Arizona Rules of the Supreme Court (including the rules on petitions for review and special action that the Court of Appeals applies): `https://www.azcourts.gov/rules/Arizona-Rules-of-the-Supreme-Court`. Not retrieved: HTTP 403 to curl, 2026-10-22.
- Arizona Rules of Criminal Procedure (Rule 31, form of documents, for criminal appeals): not retrieved; the same host blocks the rules pages.

Retry the azcourts.gov URLs and add the rows (ID, requirement, source, kind) before the templates are judged against any mandated form. Until then `fb check` runs the default tier-1 set only.

## Sources

| Tag | Source | URL | Status |
|---|---|---|---|
| ARCAP | Arizona Rules of Civil Appellate Procedure | https://www.azcourts.gov/rules/Arizona-Rules-of-Civil-Appellate-Procedure | Not retrieved: HTTP 403 on 2026-10-22 |
| Supreme Court rules | Arizona Rules of the Supreme Court | https://www.azcourts.gov/rules/Arizona-Rules-of-the-Supreme-Court | Not retrieved: HTTP 403 on 2026-10-22 |

Kinds, when rows are added: **M** mandated by a rule, **C** convention seen across filers, **T** project rule, **A** author responsibility.

## Requirements

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARIZCTAPP-FORM-001 | No form requirement for briefs, petitions or motions is asserted: the Arizona rules listed above were not retrieved, so no check enforces a mandated margin, font, spacing, length or cover content for this court. Rows are added here, each with its rule text, URL and verification date, once retrieved. | Project rule (docs/EVAL-LOOP.md, "Adding a court", step 1) | T |
