# Agent operating protocol

You are one of many agents working this repo in parallel. Read this file, then `docs/EVAL-LOOP.md`, before touching anything.

## Pick work

- Work comes from the bead queue in `.beads/`. `br ready` lists unblocked beads; `br show <id>` gives the full brief. Take exactly one bead.
- Claim it before starting: `br update <id> --claim`. If it is already in progress, pick another.
- One bead = one court folder, or one tool. Do not edit another court's folder or shared files (`lib/`, `tools/`, `docs/`, `data/`) unless your bead is about them. If you need a shared change, file a new bead (`br create --parent fb-595 ...`) and mention it in your PR.
- Fan-out beads (e.g. "remaining federal circuits") are parents: create one child bead per court with `br create --parent <id>`, then work one child.

## Do the work

- Court templates follow `docs/EVAL-LOOP.md` exactly. Reference implementation: `courts/ninth-circuit/court-of-appeals/`. Copy its structure (`rules.md`, `checks.yaml`, `typst/`, `samples/`, `reviews/`, `LOG.md`, `README.extra.md`), not its numbers.
- The court's own rules (primary sources, cited with URL, rule number and date verified) decide the layout. The filed exemplar only settles what the rules leave open.
- Banned, no exceptions:
  - case-specific text, coordinates measured off a filed PDF, or forced line breaks in a template;
  - aggregate scores or "mostly passes";
  - reviewing only page 1, or writing a Gate 2 row for a page you did not render and look at;
  - system fonts (compile only via `tools/render.sh`: vendored fonts, `--ignore-system-fonts`, warnings fail);
  - new Python. Use shell, typst, Bend (small glue) or Rust (validators, CLIs).
- Never set `"status": "done"` in any `court.json`. Only David does that.

## Finish

1. `sh tools/check.sh <court-dir>` exits 0: every gate green on every sample.
2. `sh tools/check-selftest.sh <court-dir>` prints `SELFTEST OK`. Add mutants for any check you added.
3. `sh tools/tracker.sh`, then commit the regenerated files.
4. Commit on a branch named after the bead (`fb-595.N-<slug>`), push, and open a PR against `master` containing: bead id, the `check.sh` RESULT line, the selftest result, remaining known defects by page, and decisions you made. Never merge your own PR.
5. Leave the bead `in_progress` and record the PR: `br comments add <id> "<PR URL>"`. David closes beads.

If you are blocked on a decision only David can make (scope, license, which exemplar, conflicting rules), stop, add a bead comment with the question, and end with a single line `BLOCKED: <question>`. Do not guess, and do not report success you have not verified with the commands above.

## Setup

Dependencies: typst, poppler (`pdfinfo pdffonts pdftotext pdftohtml pdfimages pdftoppm`), gawk, jq, yq (mikefarah), bend, `br` (beads_rust). Fonts and the cmarker typst package are vendored; nothing is fetched at build time.
