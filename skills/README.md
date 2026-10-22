# skills/

The `formbook/` folder is an agent skill: one `SKILL.md` (plus `reference/` notes it links to) that teaches an agent to draft a court filing as markdown and render a court-compliant PDF from this repo's Typst templates, or to write a new template for a court or document type that is missing.

## Install

From a checkout of this repo, one command copies the skill into your agent's skills folder (it replaces an older copy):

```sh
sh skills/install.sh ~/.claude/skills
```

Then restart your agent and ask it to format a court filing, or type `/formbook`. Keep the checkout: the skill renders with its `tools/` and `courts/`.

Other agents (Codex, Cursor, a plain LLM with a shell): point them at `skills/formbook/SKILL.md`, for example "Read skills/formbook/SKILL.md and follow it". They need `sh`, `git`, and the toolchain from `sh tools/bootstrap.sh` (no root).

## Try it

```sh
sh tools/bootstrap.sh && export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
just find ca1
just new-filing ca1 opening-brief ./out
just render-filing courts/first-circuit/court-of-appeals/opening-brief ./out/filing.md ./out/filing.pdf
```
