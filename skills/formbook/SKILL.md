---
name: formbook
description: Draft and format a US court filing (brief, complaint, motion memorandum) as markdown and render a court-compliant PDF with the formbook repo's Typst templates, or write a new template for a court or document type that does not exist yet. Use when asked to format a filing for a specific court, check a filing against a court's rules, or add a court template to formbook.
---

# formbook: use or write court-filing templates

formbook is an open collection of court-filing templates (Typst, markdown-first), organized by court. You write the content as markdown with a YAML frontmatter block; the template generates everything the court's rules dictate (cover or caption, tables of contents and authorities, spacing, fonts, certificates, signature block). It is not legal advice and it does not check your arguments or citations.

Use it when: the user wants a brief, complaint or memorandum formatted for a named court; or wants a court's filing rules enforced mechanically; or wants a new court or document type added.

Do not use it for: contracts, letters, memos (not court filings); a court/doc type with no template when the user only wants a one-off (say so, offer to write the template).

## Setup (once per machine, no root)

```sh
git clone <formbook-repo-url> formbook && cd formbook      # or use the checkout you are in
sh tools/bootstrap.sh                                        # installs typst 0.15.0, poppler, jq, yq, pandoc, tectonic
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
sh tools/bootstrap.sh --check                                # lists any missing tool
```

Typst plus poppler is enough to render and look at pages. `tools/check.sh` also needs gawk, jq, yq. LibreOffice (`soffice`) is only for the docx engine and is not installed by the bootstrap. Fonts and the cmarker package are vendored: nothing is downloaded at render time. Run every command from the repo root.

## USE a template

1. **Find the court.** Aliases are CourtListener court ids (`ca1`, `cand`, `nysupct`, `scotus`). `data/index.json` maps alias to folder; `data/index.json` may lag the tree, so the script also falls back to each folder's `court.json`.
   ```sh
   sh skills/formbook/scripts/find.sh cand              # court folder + doc types that have a template
   sh skills/formbook/scripts/find.sh "northern district" complaint
   ```
   A doc type exists only if `<court>/<doctype>/typst/main.typ` exists. Empty `typst/` folders are scaffolds. The ninth circuit (`ca9`) is the reference court with its template at the court root (doc type shown as `.`). See `reference/doc-types.md` for what exists.
   If the court or doc type has no template, go to WRITE. Do not substitute another court's template: caption, length limits and certificates differ per court.
2. **Start from the sample.**
   ```sh
   sh skills/formbook/scripts/new-filing.sh cand complaint ./my-filing
   ```
   This copies the doc type's `usage/INPUT-*.md` to `./my-filing/filing.md` and prints the render command. Read the doc type's `README.md` (rules table, "Markdown contract", known gaps) and `reference/input-contract.md` before editing.
3. **Fill in the markdown.** Replace every frontmatter value and all body text; the sample is a real filing excerpt, so leave none of its parties, facts or cites behind. Rules of thumb: frontmatter holds metadata only (case number, parties, counsel, title, date, signature, authorities); the body holds headings and prose; do not type paragraph numbers (complaints), the TOC, TOA, certificates or signature block (the template generates them); heading numbers are automatic in appellate briefs but typed by you in the NY motion-brief (check the doc type's README); no tables, images, raw HTML or raw Typst.
4. **Render.**
   ```sh
   sh skills/formbook/scripts/render-filing.sh <doctype-dir> ./my-filing/filing.md ./my-filing/filing.pdf
   ```
   This wrapper stages the file inside the doc-type folder (typst `--root` requires it), calls `tools/render.sh` (vendored fonts, `--ignore-system-fonts`, any warning fails), and cleans up. Equivalent by hand: copy the md to `<doctype-dir>/<name>.md` (not into `usage/`, whose names are linted) and run `sh tools/render.sh <doctype-dir> <name>.md <out.pdf>`, then delete the copy.
5. **Verify.** Render every page and look at each one: `pdftoppm -r 80 -png filing.pdf pg`, then view all of them (not just page 1). Check: cover/caption fields, TOC page numbers, TOA entries, headings, footnotes on the right page, signature block, certificates, word/page count against the limit in the README. `pdffonts filing.pdf` should list only vendored fonts. Where the court folder has a `checks.yaml` (only `ca9` today), run `sh tools/check.sh courts/ninth-circuit/court-of-appeals` for its mechanical gates (it checks the court's own samples, not your filing).
6. **Hand over** the PDF and the markdown, and name what the template does not do (the README's "Known gaps": e.g. paper cover color, disclosure statements, case-name italics are yours to add with `*...*`).

Failure of a build is information: read the message. The templates `panic` on a missing frontmatter field, an unknown `toa:` key, a word count over the limit, a cover that cannot fit one page. Fix the markdown; do not edit the template to get past it for a filing.

## WRITE a new template (court or doc type not yet present)

Do this only on a branch or worktree; work in one court folder. Start from the nearest finished template for the same doc type, and copy its structure, not its numbers. Full process: `docs/EVAL-LOOP.md`; operating protocol: `AGENTS.md`. Read both first.

1. **Place it.** Folder is `courts/<circuit>/<state>/<federal|state>/<court>/<doctype>/` (look at `find.sh` output for siblings). Claim via `sh tools/claim.sh <alias>` if you are working the repo's queue.
2. **Get the rules from primary sources**: the court's local rules, FRAP/FRCP/CPLR or equivalent, the clerk's filing guide. Record URL, rule number and date read. The rules decide the layout; the filed exemplar settles only what the rules leave open.
3. **Find 2 or 3 public filed exemplars from different filers** (CourtListener/RECAP, the court's website, a docket). Save into `usage/SAMPLE-<stem>-<id>.pdf` (`<stem>` = `<alias>-<doctype>`, or the alias alone in a court-root folder; `<id>` = lowercase `[a-z0-9]+`, no hyphens, e.g. the case name and docket) and record filename, filer, case, date filed, URL, date retrieved in `usage/SOURCE.md`. Only public, filed documents.
4. **Transcribe an INPUT sample**: `usage/INPUT-<stem>-<id>.md` with the frontmatter and body of the exemplar (an excerpt is fine; say so in a `#` comment at the top of the frontmatter). Then write a second, structurally different sample (fictional) to prove the template is not tuned to one filing.
5. **Write the Typst** in `typst/main.typ` (entry: read the sample, split frontmatter, call the template) and `typst/<alias>-<doctype>.typ` (the template, cmarker for the body). Every number traces to a rule or a named style choice in a parameter block with the rule cited in a comment. Layout from the rules, not from coordinates read off the exemplar.
6. **Render** with `just render <doctype-dir>` (or `tools/render.sh`; output `usage/OUTPUT-<stem>-<id>.typst.pdf`) and fix until no warnings. `just lint` checks every `usage/` name.
7. **Overlay** the sample on the exemplar: `just overlay <doctype-dir>` (or `sh tools/overlay.sh <doctype-dir> <id>`) writes `.overlay/<doctype-dir>/OVERLAY-<stem>-<id>.pdf/.txt` (red ours, blue filed, black both); `.overlay/` is gitignored, never commit it. A diagnostic, not a score.
8. **Review every page** of the output next to the exemplar. Fix tier 1 (mandated form: font, size, margins, spacing, length, required sections, certificates) fully; tier 2 (conventions seen across several filers) to professional quality; do not chase tier 3 (one filer's style).
9. **Write `README.md`** in the doc-type folder: governing rules table (rule, requirement, where the template uses it, with citations), markdown contract (fields and body), page-by-page review, known gaps. Model: `courts/first-circuit/court-of-appeals/opening-brief/README.md`.
10. **Finish** per `AGENTS.md`: `sh tools/check.sh <court-dir>` where the court has `checks.yaml`, `sh tools/tracker.sh` if the protocol asks, commit, open a PR; never merge your own.

## Hard rules (from AGENTS.md)

- No case-specific text, coordinates measured off a filed PDF, or forced line breaks in a template.
- Compile only through `tools/render.sh`: vendored fonts, system fonts ignored, warnings fail. Never a bare `typst compile`.
- No new Python. Use shell, typst, Bend (small glue) or Rust (validators).
- No aggregate scores or "mostly passes"; no review of page 1 only; no Gate 2 row for a page you did not view.
- Never set `"status": "done"` in any `court.json`; only the repo owner does.
- Do not edit another court's folder or shared files (`lib/`, `tools/`, `docs/`, `data/`) unless the work is about them.
- If a decision is only the owner's (scope, license, which exemplar, conflicting rules), stop and end with `BLOCKED: <question>`.

## Troubleshooting

- **`typst emitted warnings; treating as failure`**: the warning text is printed above it. Common: unknown font (a font name that is not vendored; use only what `fonts/` has), deprecated function, unused import. Fix the cause, never filter the warning.
- **Font not found / wrong font in PDF**: `pdffonts out.pdf`. Only `fonts/` is visible. Add a font by vendoring it with its license, not by installing it system-wide.
- **cmarker problems**: package is vendored at `vendor/typst-packages` (cmarker 0.1.10); do not let typst fetch it (`--package-cache-path` is set by render.sh). A paragraph starting `1.`, `-`, `+`, `#`, `>` is parsed as a list, heading or quote: escape it (`90\. The record`). `raw-typst` is off, so Typst code in markdown is inert.
- **`could not read file` / `file not found` for the sample**: the sample path must be inside the doc-type folder (typst `--root`); use `render-filing.sh`.
- **`missing required metadata field`**: add the key named in the message to the frontmatter; keys differ per doc type (`reference/input-contract.md`).
- **`toa:` key not in `authorities:`**: every `[cite](toa:key)` needs a registry entry; a link inside a heading is refused.
- **Cover or heading must fit**: shorten the counsel/party list or heading; templates refuse to shrink type.
- **Tool missing**: `sh tools/bootstrap.sh --check`; `soffice` problems affect only `--engine docx`.
- **Alias not found**: try a name fragment (`find.sh "southern district"`), or look in `data/index.json` and `courts/**/court.json`.

## Files in this skill

- `reference/input-contract.md`: frontmatter keys, body conventions, annotated example, per-doc-type differences.
- `reference/doc-types.md`: doc types that exist, counts, how to regenerate.
- `scripts/find.sh`, `scripts/new-filing.sh`, `scripts/render-filing.sh`: discover, start, render (POSIX sh, run from repo root).
