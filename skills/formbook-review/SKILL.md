---
name: formbook-review
description: Help a formbook reviewer (a licensed attorney) review one or more of formbook's court-filing templates and submit the review as a pull request. Use when a reviewing attorney wants to check that a template's rendered filings meet the court's rules and are good enough to file, and record that review.
---

# formbook-review: an attorney's review of a template, as a pull request

formbook's templates are machine-checked ("up for review") but none is human-verified until a licensed attorney has looked at the output and said it is usable. This skill walks you (the agent) and the attorney you work for through one or more templates (a template is one document type for one court, such as the First Circuit's opening brief): render its samples, check each page against the court's current rules, record the attorney's verdict, and open a pull request with that record. Reviews are merged as they come in.

**Reviewers only.** Attorneys become reviewers by opening a GitHub issue with the reviewer form (https://github.com/davidawad/formbook/issues/new?template=reviewer.yml; title `reviewer - <name>`, with where they are admitted and which courts they file in). Reviewers are added as collaborators with merge rights. If the attorney you work for is not one yet, give them that link, and offer to draft their answers to the form and stop until they are added; nobody claims courts or templates in advance.

**Who signs.** The attorney does. You render, measure, compare and draft; the attorney looks at every page and decides every verdict. Never write a verdict the attorney did not give you, and never write that a page was looked at when it was not. The review is of form (layout, required parts, limits), not of legal substance, and it is not legal advice to anyone.

**What a review does not do.** It does not set `status` in any `court.json` and does not change templates. A maintainer reads the PR and merges it; court status is the maintainer's call. A defect found in review goes in the record; a fix, if the attorney wants to make one, is a separate PR (see `skills/formbook/SKILL.md`, WRITE).

## 1. Setup

```sh
gh repo fork davidawad/formbook --clone && cd formbook     # or: git clone https://github.com/davidawad/formbook && cd formbook
sh tools/bootstrap.sh && export PATH="$HOME/.local/share/formbook/env/bin:$PATH"   # Linux; on macOS: brew install typst poppler jq just
git switch -c review/<alias>-<github-handle>
```

Run every command from the repo root. Rendering needs `cargo` on the PATH (it builds `tools/fb`).

## 2. Pick the templates

Ask the attorney which court and which document types. Pick ones they know: a court they are admitted before or regularly file in; say which in the record.

```sh
just find <alias or name>          # court folder and the doc types that have a template
```

Read the court's `README.md`, its `rules.md` (requirement IDs, each with the rule and source URL) and the chosen doc types' `README.md` ("Known gaps"). Look at any existing `attorney-reviews/` in those folders.

## 3. Render what you will review

For each chosen doc-type folder (it has `typst/main.typ`):

```sh
just render <doc-dir>                                     # every usage/INPUT-*.md to usage/OUTPUT-*.typst.pdf
just check <doc-dir>                                      # the mechanical gates; note any failure
just overlay <doc-dir>                                    # our render over the filed exemplar, in the gitignored .overlay/
pdftoppm -r 100 -png <doc-dir>/usage/OUTPUT-<id>.typst.pdf /tmp/review/<doctype>-p
sha256sum <doc-dir>/usage/OUTPUT-<id>.typst.pdf          # macOS: shasum -a 256
```

Typst is the reference engine; review it. Review the LaTeX or DOCX output too only if the attorney will use it (`sh tools/render.sh --engine docx <doc-dir> usage/INPUT-<id>.md`), and read `docs/DOCX.md` first: Word cannot reproduce some layouts, pleading paper above all.

## 4. Check against the court's rules, today

1. Fetch the court's current rules from the source URLs in `rules.md` (and any newer local rules, standing orders, or clerk's checklists you find). Note every rule that changed since the date read in `rules.md`.
2. For every requirement ID in `rules.md`, measure the rendered PDF: paper size, margins, font and size, line spacing, lines per page, page or word limits, cover or caption contents, required sections and their order, certificates, signature block, page numbering. Write down what you measured, not what the template claims.
3. Show the attorney every page image, one doc type at a time, next to the filed exemplar page (`usage/FILED-EXAMPLE-*.pdf`) and the overlay. Ask, for each page: would the clerk accept this? Would you file it? Record their answer and anything they point out.
4. Ask what the court expects that no written rule says (local custom, a judge's standing order, cover colors on paper copies, what clerks actually reject). Those go in the record too.

## 5. Write the record

One file per template reviewed: `<doc-dir>/attorney-reviews/YYYY-MM-DD-<github-handle>.md` (for `ca9`, whose template sits at the court root, `<doc-dir>` is the court folder). It does not go in `reviews/`: that folder holds the per-page Gate 2 reviews the checker reads.

```markdown
# Attorney review: <court name> (`<alias>`), <doctype>

- Reviewer: <full name>, GitHub @<handle>
- Admitted: <jurisdictions and years>; practice before this court: <yes, since YYYY / no, but ...>
- Date: YYYY-MM-DD
- Commit reviewed: <git rev-parse HEAD>
- Rules checked: <URL, rule, date read> (one line each; note any rule newer than rules.md)
- Review assisted by: <agent and model>

| Sample | Engine | PDF sha256 | Pages looked at | Verdict |
|---|---|---|---|---|
| OUTPUT-opening-brief | typst | <sha256> | 14 of 14 | USABLE |
| OUTPUT-opening-brief-2 | typst | <sha256> | 9 of 9 | USABLE WITH CHANGES |

Verdicts: USABLE (I would file this as rendered, with my content); USABLE WITH CHANGES (usable once the findings below marked MUST are fixed); NOT USABLE (a clerk would reject it, or it is wrong in a way the findings explain).

## Findings

| Sample | Page | Finding | Rule | Severity |
|---|---|---|---|---|
| OUTPUT-opening-brief-2 | 1 | Cover omits the lower-court judge's name | Cir. R. 32(a) | MUST |
| OUTPUT-opening-brief | 3 | TOA groups statutes before cases; local custom is cases first | none (custom) | SHOULD |

Severity: MUST (a rule requires it, or clerks reject without it); SHOULD (custom or practice); NOTE (cosmetic).

## Not checked

What the review did not cover (engines, samples, judge-specific orders).

## Statement

I looked at every page listed above. This review covers the form of the rendered documents, not their content, and is not legal advice.
```

Fill it from the attorney's answers. Leave out anything they did not confirm. A bar number is optional; do not ask for one unless the attorney offers it.

## 6. Open the pull request

The PR adds only the new `attorney-reviews/` files (one per template). Nothing else: not `court.json`, not templates, not generated files.

```sh
git add <doc-dir>/attorney-reviews/<file>.md
git commit -m "review(<alias>.<doctype>): <verdict> by @<handle>"
git push -u origin HEAD
gh pr create --repo davidawad/formbook --title "review(<alias>.<doctype>): <verdict>" --body "<the record's table and its MUST findings; link the record file>"
```

Show the attorney the PR body before you create it; they submit it. If a MUST finding should become its own issue, offer to open one titled `review - <full court name> <doctype>: <finding>`.

## What happens next

A maintainer reads the record, may ask questions on the PR, and merges it. USABLE WITH CHANGES and NOT USABLE findings become fixes; after a fix the template can be reviewed again. Review more templates whenever you like, each as its own record.
