# skills/

Agent skills shipped with formbook. Each folder holds a `SKILL.md` (YAML frontmatter `name`, `description`, then instructions) plus optional `reference/` and `scripts/`.

| Skill | Purpose |
|---|---|
| `formbook/` | Draft a court filing as markdown and render a court-compliant PDF from the repo's Typst templates; or write a new template for a court or doc type that is missing. |

All scripts are POSIX sh and are run from the formbook repo root.

## Claude Code

Copy or symlink the folder into a skills directory:

```sh
# for you, in every project
mkdir -p ~/.claude/skills && ln -s "$PWD/skills/formbook" ~/.claude/skills/formbook
# for one project
mkdir -p .claude/skills && ln -s "$PWD/skills/formbook" .claude/skills/formbook
```

Claude Code loads it when the task matches the skill's `description` (formatting a court filing, adding a court template), or invoke it by name (`/formbook`). Work from a checkout of this repo so `tools/` and `courts/` are available.

## Codex, Cursor, and other agents

Point the agent at `skills/formbook/SKILL.md`: for example "Read skills/formbook/SKILL.md and follow it", or reference it from the agent's own instruction file (`AGENTS.md`, `.cursor/rules/`, and so on). Only a shell with `sh` is required. The SKILL.md links to `reference/` files; load those when it tells you to.

## Plain LLM with shell access

Paste or attach `skills/formbook/SKILL.md`, and give the model a shell in a checkout of the repo. It needs `sh`, `git`, and the toolchain from `sh tools/bootstrap.sh` (no root). No network is needed at render time.

## Try it

```sh
sh tools/bootstrap.sh && export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
just find ca1
just new-filing ca1 opening-brief ./out
just render-filing courts/first-circuit/court-of-appeals/opening-brief ./out/filing.md ./out/filing.pdf
```
