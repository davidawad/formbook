# High Court of American Samoa: briefs, petitions, motions, and amicus briefs

Alias `amsamoa`. Scope: briefs on the merits, answering and reply briefs, amicus curiae briefs, motions, petitions for review, petitions for writ, and petitions for rehearing filed in the High Court of American Samoa, Appellate Division.

Verified against the court's own sources on 2026-10-22: none. The Appellate Court Rules (ACR) are published by the High Court; the official pages were not retrieved (see Status). Nothing in this file is a verified rule.

## Status: BLOCKED (court rules not retrieved)

No American Samoa rule has been retrieved, so this file records **no `M` (mandated) requirement**. The folder has no court-root FILED-EXAMPLE (see `usage/SOURCE.md`: the filings exist but no public text-layer copy was found), so no doc folder has been built. The templates run the repo default tier-1 set only (`data/checks-default.yaml`: US letter pages, 12 point body text, 1 inch margins, no page limit). Those are defaults, not American Samoa requirements.

- Appellate Court Rules (ACR 28 on briefs, ACR 31 on form, ACR 27 on motions, ACR 40 on rehearing), published by the American Samoa Bar Association: `https://asbar.org/appellate-court-rules/`. Not retrieved: HTTP 401 to curl with a browser user agent, 2026-10-22. The 2025 Wayback copy used by the exemplar's SOURCE.md was not used as a source here because it is not a current primary copy.
- High Court of American Samoa official website (court rules and clerk's office): not located. `https://www.americansamoa.gov/judiciary` returned HTTP 404 and `https://www.americansamoa.gov/` returned HTTP 200 (its links were not followed), 2026-10-22. `https://www.amsamoa.gov/` and `https://www.courts.as.gov/` did not resolve (HTTP 000), 2026-10-22.
- Third-party mirror copies (`https://paclii.org/as/legis/consol_act/j61`, `https://www.courtrules.net/american_samoa/practice-guide`) returned HTTP 403, 2026-10-22.

Retry the asbar.org ACR pages and the High Court's official site, and add the rows (ID, requirement, source, kind) before any template is judged against a mandated form. Until then `fb check` runs the default tier-1 set only.

## Sources

| Tag | Source | URL | Status |
|---|---|---|---|
| ACR | Appellate Court Rules, High Court of American Samoa (published by the American Samoa Bar Association) | https://asbar.org/appellate-court-rules/ | Not retrieved: HTTP 401 on 2026-10-22 |

Kinds, when rows are added: **M** mandated by a rule, **C** convention seen across filers, **T** project rule, **A** author responsibility.

## Requirements

| ID | Requirement | Source | Kind |
|---|---|---|---|
| AMSAMOA-FORM-001 | No form requirement for briefs, petitions or motions is asserted: the American Samoa rules listed above were not retrieved, so no check enforces a mandated margin, font, spacing, length or cover content for this court. Rows are added here, each with its rule text, URL and verification date, once retrieved. | Project rule (docs/EVAL-LOOP.md, "Adding a court", step 1) | T |
