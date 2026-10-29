# Rules research: per-court `rules.md`, freshness, and the fan-out prompt (fb-595.21)

Every court folder's `rules.md` is the court's requirement list (docs/EVAL-LOOP.md, Gate 1 and R9). This file
says what a `rules.md` must record about its own sources and age, how to find the ones due for a re-check, and
gives the prompt an agent is handed when research is fanned out over many courts.

## What a `rules.md` records

| Item | Form | Checked by |
|---|---|---|
| Primary sources | a table under a `## Sources` heading: tag, source (rule set, edition or effective date), URL (http or https) of the court's or the Judicial Conference's own copy | `fb lint rules` (at least one URL) |
| Rule numbers | every requirement row cites the rule and subdivision it comes from (`FRAP 32(a)(5)`, `L.R. 7.1(c)`, the handbook page); a row of Kind `M` must have a non-empty source cell | `fb lint rules` |
| Last-checked date | one line `Verified against <which sources> on YYYY-MM-DD`; when sources were checked on different days, one line per group (the latest date counts) | `fb lint rules` (format), `fb lint rules --fresh` (age) |
| Re-check cadence | one line `Re-check cadence: <when>` saying when the sources must be looked at again (the national rules change each December 1; local rules when the court publishes an amendment), optionally ending `(next routine review by YYYY-MM-DD)` | `fb lint rules --fresh` (reported, not yet required) |

The cadence line is reported, not linted, because 217 of the 377 files on 2026-10-29 had none; a file gains one
the next time its sources are re-verified.

## Which files are due

`just rules-fresh` (`fb lint rules --fresh [--today YYYY-MM-DD] [--max-age DAYS]`, offline) prints one line per
`courts/**/rules.md`:

    RULES <path> verified <date> due <date> FRESH|DUE|UNDATED[ no-cadence]

The due date is the file's own `next routine review by` date when it states one, else the latest `Verified
against` date plus `--max-age` days (365). `DUE` means today is on or after it; `UNDATED` means no `Verified
against` date was found. It exits 1 when any file is `DUE` or `UNDATED`, so the list it prints is the fan-out
work list. It is not part of `just lint`: a file going stale with time must not turn the landing gate red.

## Re-checking a file

1. Fetch every Sources URL; follow the court's rules landing page to the current edition (a new effective date, a
   general order, a standing order on electronic filing).
2. For every requirement row, confirm the cited rule still says it. A changed rule changes the row's text and
   source, never its ID (EVAL-LOOP R8); a rule that is gone marks the row `(withdrawn)`.
3. Update the Sources table (edition, URL), the `Verified against ... on <today>` line and the cadence line.
4. If an `M` requirement changed, the court's `checks.yaml`, `eval.yaml` and templates follow in the same
   change, and `tools/check.sh` runs green on every engine before it lands.

## Fan-out prompt

Hand one agent one court folder (from the `DUE` lines of `just rules-fresh`, or a court with no `rules.md` yet).
Fill in the two placeholders; everything else is fixed.

```text
Research or re-check the rules for the court folder <COURT-DIR> (alias <ALIAS>). Read CLAUDE.md,
docs/EVAL-LOOP.md (Gate 1, R8, R9, "Adding a court" step 1) and docs/RULES-RESEARCH.md first, then the
folder's court.json and its current rules.md if it has one. Use courts/ninth-circuit/court-of-appeals/rules.md
as the model of the format.

Do:
1. Find the primary sources: the court's own local rules, general and standing orders on filing form and
   electronic filing, required forms (certificates of compliance and service), and the national rules they
   build on (FRAP, FRCP, FRBP, or the state's rules of appellate or civil procedure). Use only the court's or
   rule-maker's own copy; a secondary summary is a lead, not a source. Record each in the Sources table with
   its edition or effective date and URL.
2. Write or update one requirement row per rule: a stable ID (<ALIAS-PREFIX>-<SCOPE>-NNN; never renumber an
   existing ID, mark a dropped one `(withdrawn)`), the requirement, the rule number and subdivision (and page
   of the handbook when there is one), and the Kind: M mandated by a rule, C convention, T project rule, A
   author responsibility. Only a rule's text makes a row M. Note where a local rule overrides a national one.
3. Set `Verified against <sources> on <today>` and a `Re-check cadence:` line naming when each source must be
   looked at again, ending `(next routine review by <date>)`.
4. `just lint` must pass its `fb lint rules` step, and `fb lint rules --fresh` must
   show the folder FRESH with no `no-cadence`.

Do not: edit another court's folder or shared files; guess a rule you could not read (record the URL you
could not reach and why under a `## Re-check notes` heading, and leave the row out or Kind A); copy text from
a filed exemplar into a template; set court.json status to done. If an M requirement changed, say so: the
templates and checks must follow before the court's stamps are trusted again.

Commit on your branch with a message `research(<ALIAS>): ... (<bead id>)`, and end with the file's new
`RULES ... FRESH` line from `fb lint rules --fresh`.
```
