# data/

- `courts-db.json` vendored, unmodified, from CourtListener's courts-db (Free Law Project).
  - Source URL: https://raw.githubusercontent.com/freelawproject/courts-db/main/courts_db/data/courts.json
  - Fetched: 2026-10-06
  - Fields used: `id`, `name`, `system`, `type`, `level`, `location`, `dates` (a court is active if any `dates` entry has `end == null`).
- `scope.json` which courts are in the formbook (explicit allow/deny id lists and rules).
- `circuits.json` circuit-to-state/territory map (28 U.S.C. 41; Northern Mariana Islands via 48 U.S.C. 1821).
- `index.json` GENERATED court tree index: alias to folder path. Do not edit. `tools/gen_tree.sh` normalizes this index and refreshes court folders while preserving manual fields in each `court.json`.
- `priority.json` the order `just claim --next` claims courts in (a priority list, then every other court in index order), and the `reference` courts it never auto-claims.
- `cover-structure-baseline.txt` the doc folders and engines whose page 1 differed in structure from the same-id FILED-EXAMPLE when DEF-COVER-002 came in (fb-595.78): they print the check as REPORTED until fixed. Lines are only ever deleted.
