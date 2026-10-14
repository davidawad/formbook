# Agent operating protocol

You are one of many agents working this repo in parallel. Read this file, then `docs/EVAL-LOOP.md`, before touching anything.

## Open contribution

If you are an outside agent (or an agent told to "contribute" with no assigned court), do not use the court-claim flow below. Read [CONTRIBUTING.md](CONTRIBUTING.md) and run `sh tools/contribute.sh pick`: it hands you one open unit (a court x document type from `data/worklist.json`), then `claim <id>`, `brief <id>`, `verify <id>`, `submit <id>`. Units are claimed as the branch `contrib/<id>`; a court claimed whole (`court/<alias>`) is skipped.

## Pick work

"Run the eval loop on a court" means exactly this, and nothing else needs to be asked:

1. Claim a court: `sh tools/claim.sh --next` (highest-priority unclaimed court; order in `data/priority.json`), or `sh tools/claim.sh --random`, or `sh tools/claim.sh <alias>` for a specific one. It atomically creates the remote branch `court/<alias>` from `origin/master`, so two agents can never take the same court, and prints the alias and the court folder. Add `--dry-run` to see what it would claim without claiming. If it exits non-zero, nothing was claimed.
2. Check the claimed branch out in your own worktree: `git fetch origin court/<alias> && git worktree add .worktrees/<alias> court/<alias>`. Work only there, with absolute paths.
3. Run the full eval loop (`docs/EVAL-LOOP.md`) for all three engines: typst, latex, docx. Tier 1 (mandated form) must be perfect; tier 2 (professional convention) judged against 2 or 3 exemplars from different filers; tier 3 (one filer's style) is not chased.
4. Push the branch and open a PR against `master` titled `court(<alias>): typst/latex/docx templates`. Body: see "Finish".

Scope: one court folder per claim. Do not edit another court's folder or shared files (`lib/`, `tools/`, `docs/`, `data/`) unless the work is about them. Tool and infrastructure work (and any shared change you need) is tracked as beads in `.beads/`: `br ready`, `br show <id>`, `br update <id> --claim`; file a new one with `br create --parent fb-595 ...` and mention it in your PR. Court work is claimed by branch, not by bead.

## Do the work

- Court templates follow `docs/EVAL-LOOP.md` exactly. Reference implementation: `courts/ninth-circuit/court-of-appeals/`. Copy its structure (`rules.md`, `checks.yaml`, `typst/`, `latex/`, `docx/`, `exemplars/` with `SOURCE.md`, `samples/`, `reviews/`, `LOG.md`, `README.extra.md`), not its numbers.
- Quality tiers decide where to spend effort: tier 1 (the court's mandated form: font, margins, spacing, length, cover contents, required sections, certificates, e-filing PDF rules) must be perfect; tier 2 (conventions a clerk expects) must look professional, judged against 2 or 3 filed exemplars from different filers; tier 3 (matching one filer exactly) is not chased. The overlay is a diagnostic, not a score. Stop when tiers 1 and 2 pass.
- File roles are in the name, so anyone browsing can tell input, output and comparison apart: `exemplars/FILED-EXAMPLE-*.pdf` (the real filing), `samples/INPUT-<id>.md` (markdown we feed in), `samples/OUTPUT-<id>.pdf` (our render), `samples/OVERLAY-<id>.pdf` and `.txt` (red/blue comparison). The tools read and write these names by default.
- Three engines per court: `typst/` (primary), `latex/`, `docx/`; outputs `samples/OUTPUT-<id>.pdf`, `OUTPUT-<id>.latex.pdf`, `OUTPUT-<id>.docx`, `OUTPUT-<id>.docx.pdf`. `tools/render.sh` and `tools/check.sh` take `--engine typst|latex|docx`. DOCX limits: `docs/DOCX.md`.
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
3. The same two commands for the other engines: `sh tools/check.sh <court-dir> --engine latex` and `--engine docx` (each writes its pass stamp only when fully green).
4. `sh tools/tracker.sh`, then commit the regenerated files.
5. Commit on the claimed branch `court/<alias>`, push it, and open a PR against `master` titled `court(<alias>): typst/latex/docx templates`. The body contains:
   - the tier-1 `check.sh` RESULT line for each engine (typst, latex, docx);
   - the `check-selftest.sh` result;
   - the path of the overlay PDF (`samples/OVERLAY-<id>.pdf`);
   - the exemplars used, with the filer of each (from `exemplars/SOURCE.md`);
   - the remaining tier-2 findings, by page (`OPEN` or `ACCEPTED` rows of the Gate 2 review);
   - the docx `BLOCKED` items: each failing check ID and why (a docx may be delivered BLOCKED or partial; silently missing is not acceptable, and the same holds for latex).
   Never merge your own PR. Do not delete the claim branch.
6. For tool or infrastructure beads (not court work): branch `fb-595.N-<slug>`, PR with the bead id, leave the bead `in_progress` and record the PR with `br comments add <id> "<PR URL>"`. David closes beads.

If you are blocked on a decision only David can make (scope, license, which exemplar, conflicting rules), stop, record the question (a bead comment for tool work, the PR description for court work), and end with a single line `BLOCKED: <question>`. Do not guess, and do not report success you have not verified with the commands above.

## Setup

Run `sh tools/bootstrap.sh` once per box. It needs no root: micromamba and conda-forge install typst (pinned 0.15.0), poppler, imagemagick, gawk, jq, go-yq, pandoc and tectonic into `~/.local/share/formbook/env`. It prints every tool's version and exits non-zero if one is missing or wrong. Then put the toolchain on PATH: `export PATH="$HOME/.local/share/formbook/env/bin:$PATH"`. Rerunning is safe.

Dependencies: typst, poppler (`pdfinfo pdffonts pdftotext pdftohtml pdfimages pdftoppm`), gawk, jq, yq (mikefarah), bend, `br` (beads_rust); latex engine: pandoc, tectonic or xelatex; docx engine: pandoc, LibreOffice (`soffice`). The bootstrap does not install bend, `br`, or LibreOffice: conda-forge has no LibreOffice package, so the docx engine needs `soffice` installed another way. Fonts and the cmarker typst package are vendored; nothing is fetched at build time.
