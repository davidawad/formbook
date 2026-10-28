# skills/

Two agent skills, one `SKILL.md` each:

- `formbook/` (plus `reference/` notes it links to) teaches an agent to draft a court filing as markdown and render a court-compliant PDF from this repo's Typst templates, or to write a new template for a court or document type that is missing.
- `formbook-review/` walks a reviewing attorney's agent through reviewing one or more templates: render the samples, check each page against the court's current rules, record the attorney's verdict in each template's `attorney-reviews/`, and open a pull request with it. Attorneys become reviewers by opening a [reviewer issue](https://github.com/davidawad/formbook/issues/new?template=reviewer.yml); reviewers get merge rights on the repo.

## Install

From a checkout of this repo, one command copies both skills into your agent's skills folder (it replaces older copies):

```sh
sh skills/install.sh ~/.claude/skills
```

Then restart your agent and ask it to format a court filing (`/formbook`) or to review a court (`/formbook-review`). Keep the checkout: the skill renders with its `tools/` and `courts/`.

Other agents (Codex, Cursor, a plain LLM with a shell): point them at `skills/formbook/SKILL.md` or `skills/formbook-review/SKILL.md`, for example "Read skills/formbook/SKILL.md and follow it". They need `sh`, `git`, and the toolchain from `sh tools/bootstrap.sh` (no root).

## Try it

```sh
sh tools/bootstrap.sh && export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
just find ca1
just new-filing ca1 opening-brief ./out
just render-filing courts/first-circuit/court-of-appeals/opening-brief ./out/filing.md ./out/filing.pdf
```
