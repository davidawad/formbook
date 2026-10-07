# The eval loop

Every court template in formbook is built, judged and promoted by the same loop. `courts/ninth-circuit/court-of-appeals/` is the reference implementation: copy its structure, not its numbers.

## Quality tiers (what to be perfect at, what to stop chasing)

An agent running this loop on a court has a finite budget. Spend it in this order and stop at the line.

| Tier | What | Standard | Judged by |
|---|---|---|---|
| **1. Mandated form** | Everything the court's rules dictate: font and size, margins, spacing, length limits, cover contents, required sections and their order, certificates, e-filing PDF rules (searchable text, embedded fonts, size cap, bookmarks where required). | **Perfect. Zero tolerance.** One violation can get a filing rejected. | Gates 0 and 1 (mechanical, per requirement ID, `M` in `rules.md`). |
| **2. Professional convention** | What a clerk or judge expects to see: cover layout, TOC and TOA style, heading hierarchy, caption and signature-block conventions. | **Must look professional.** A clerk should not notice anything odd. | Gate 2, against **2 or 3 filed exemplars from different filers**. |
| **3. One filer's style** | Matching a single filer's exemplar exactly: their leading, their ornament, their line breaks. | **Do not chase it.** | Nothing. The overlay (`tools/overlay.sh`) is a diagnostic that shows where we differ, not a score. Stop when tiers 1 and 2 pass. |

Rules that follow from the tiers:

- Tier 1 requirements are the ones marked `M` in `rules.md`. Source note: FRAP 32(e) says courts of appeals must accept documents that comply with the form requirements and length limits of FRAP 32 (https://www.law.cornell.edu/rules/frap/rule_32); a local rule may add to or replace those, and `rules.md` records which. Anything a rule does not dictate is tier 2 or 3, never tier 1.
- Tier 2 is judged against exemplars from **different filers** so that house style is not mistaken for convention. A choice seen across filers is a convention (`C`) and the template follows it; a choice seen in one filer is that filer's style (tier 3) and the template need not. `rules.md` records, per tier-2 choice, which of the two it is and which exemplars show it.
- Tier 3 differences are logged as `ACCEPTED` in the Gate 2 review, with one line of reason, and then left alone. A defect found by the overlay that is tier 1 or tier 2 is a defect; one that is tier 3 is not.
- The exemplars are public filings, collected into `exemplars/` (2 or 3, different filers), with the source URL of each file recorded in `exemplars/SOURCE.md` (filename, filer, case, date filed, URL, date retrieved). A court with fewer than 2 exemplars cannot finish tier 2; say so in the PR instead of judging against one filer.

## Engines (typst, latex, docx)

A court is delivered in three engines from the same markdown contract. Each has a folder in the court directory and its own rendered output in `samples/`:

| Engine | Folder | Output in `samples/` (per sample id) | Checked on |
|---|---|---|---|
| typst (primary) | `typst/` | `<id>.pdf` | that PDF |
| latex | `latex/` | `<id>.latex.pdf` | that PDF |
| docx | `docx/` | `<id>.docx` and `<id>.docx.pdf` (`soffice --headless --convert-to pdf`) | the LibreOffice PDF |

Commands: `sh tools/render.sh --engine latex|docx <court-dir> <sample.md>` (or `tools/render-latex.sh`, `tools/render-docx.sh`) and `sh tools/check.sh <court-dir> --engine typst|latex|docx` (default typst). The same gates run on each engine's PDF. Run all three before opening the PR.

- **typst** is the primary template and the reference for what the court wants. Do it first.
- **latex**: the same markdown contract, converted with `pandoc --to latex` through a per-court template (`latex/template.tex`, plus optional `latex/*.lua` filters) or a hand-written class, compiled with tectonic (default) or xelatex (`LATEX_ENGINE=xelatex`). A court may instead supply `latex/render.sh <court-dir> <sample.md> <out.pdf>` that owns the whole build. Fonts must come from `fonts/` (the renderer passes the pandoc variable `fontdir`); Gate 1 asserts the embedded font names.
- **docx** is the hard case: markdown to docx with pandoc and a per-court `docx/reference.docx` (styles, page setup, headers and footers), plus Lua filters (`docx/*.lua`) for the cover and the certificates. Use Word-native features wherever they exist: section line numbering (`w:lnNumType`) for pleading paper, page borders for pleading rules, a TOC field for the table of contents, TA/TOA fields for the table of authorities, keep-with-next on headings, widow/orphan control. A court may supply `docx/render.sh <court-dir> <sample.md> <out.docx>` to own the build. Known limits (things courts want that Word cannot express, or LibreOffice renders differently) are in [DOCX.md](DOCX.md). The `.docx` itself must also open in Word and in LibreOffice without a repair prompt; the renderer checks it is a valid zip of well-formed XML, and the reviewer opens it in LibreOffice.
- **Per-engine checks.** `checks.yaml` checks run on every engine by default. A check that cannot apply to an engine (for example embedded-font names in a docx PDF, or PDF bookmarks that LibreOffice does not emit) carries `engines: [typst, latex]` and `engines_reason: "..."`; `check.sh` prints it as SKIP with the reason. Do not use this to hide a failing tier 1 requirement: a skipped check is only legitimate when the property does not exist in that engine, and the reason must say why.
- **Gate 2 per engine.** Each engine's PDF gets its own review. Sections in `reviews/*.md` are `## sample <id>` for typst and `## sample <id> <engine>` for latex and docx, each with that PDF's sha256 and a row per page.
- **Stamp.** On a full green run (no `--only`), `check.sh` writes `samples/.check-<engine>.txt`: the line `PASS`, then `sha256  path` for every PDF checked (and the `.docx`). Any failing run removes it. The tracker counts an engine as passing only if the stamp exists and every hash still matches the file on disk, so regenerating a PDF without re-running the check turns the engine back to "built".
- **BLOCKED / partial docx.** If a docx cannot reach green, the PR delivers it as BLOCKED and lists the exact failing check IDs and why (a Word limit, a LibreOffice rendering difference, a missing feature). That is acceptable. A docx that is silently missing or silently failing is not. The same applies to latex.

## Why the loop is built this way

The loop exists because the first attempt at this repo failed in a specific way, and every rule below answers one of the failures.

| What went wrong | Rule that prevents it |
|---|---|
| The template was tuned to reproduce one filed PDF: its text, its line breaks, coordinates measured off it. It worked for nothing else. | Templates are **rule-driven and content-agnostic** (R1) and must pass a **second, structurally different sample** (Gate 3). |
| Checks were aggregates (thumbnail pixel scores, averaged word positions, substring tests). Agents declared PASS on visibly wrong pages: a district-court caption on a Ninth Circuit cover, missing italics, headings not centered. | **No aggregate scores** (R2). Each check is pass/fail on its worst instance and names the instance. |
| Nobody looked at the rendered pages, and only page 1 ever got looked at. | **Gate 2** is a recorded review of every page of the current PDF (R5). |
| The font was not installed, and typst silently fell back to Times. | Fonts are **vendored and the only fonts typst can see** (R3); the checker asserts the embedded font names. |
| Paragraphs starting "90. ", "-", "+" vanished in the markdown conversion; the loss went unnoticed. | **Gate 0** proves every word of the markdown is in the PDF, in order, before anything else runs. |
| Shrink-wrapped blocks broke centered headings; spacing properties that did nothing broke the TOC. | Every layout claim has a mechanical check (centering, TOC pages, spacing), and the checker is itself **mutation-tested** (R6). |

## The gates

```
 Gate 0 CONTENT          the PDF contains every word of the sample markdown, in order      (mechanical, runs first)
 Gate 1 RULES            one check per requirement ID in rules.md                          (mechanical)
 Gate 2 VISUAL REVIEW    a reviewer looks at every page and records findings per page      (human or agent, recorded)
 Gate 3 GENERALIZATION   a second, structurally different sample passes gates 0 to 2       (mechanical + recorded)
 Exit                    all green  ->  "up for review" (tracker);  "done" is set by David, by hand, only
```

### Gate 0: content (`CA9-TOOL-001`, `-003`, `-004` in the ca9 instance)

The PDF text and the markdown are reduced to one normal form (lower case, straight quotes, ligatures expanded, **all** whitespace removed) so line breaks can never matter, but a missing or altered character always does. Page numbers are dropped by position; footnotes are checked on their own (marker number plus full text) and cut out of the stream, because they sit in the middle of a paragraph that continues on the next page. Every other block, in document order, must then occur whole and contiguous after the previous one. Headings are placed just before the block that follows them, so a table of contents earlier in the PDF can never stand in for the real heading.

A failure names the block, how many characters matched, and what the markdown has where the PDF has something else. Also checked here: every markdown italic span is in an italic face, and every footnote is on the page that carries its reference.

### Gate 1: rules (one check per requirement ID)

`rules.md` is the court's requirement list with stable IDs (`CA9-FORM-003`) and, for every requirement, the primary source (URL and rule number) and its kind: **M** mandated by a court rule, **C** convention, **T** project rule, **A** author responsibility. `checks.yaml` lists the checks, each tagged with the ID it enforces, the gate, a `method`, the expected value, and where in the template to fix a failure. A check prints: ID, measured value, expected value, the failing instances, and `template-file:line`. Typical checks: page size, margins from text extents over **all** pages, body font and size from embedded font names and word heights, line spacing from baseline deltas in body paragraphs only, footnote size, word count against the limit (and the certificate's number against an independent count), required sections present and in order, page numbering, cover fields, table-of-contents and table-of-authorities page numbers against where headings and citations really are, centered headings.

Anything the rules leave open is **not** asserted mechanically; it goes to Gate 2.

### Gate 2: visual review

1. Render every page: `pdftoppm -r 100 -png sample.pdf out/p`. For the sample transcribed from the exemplar, also run `tools/overlay.sh <court-dir> <sample-id>`: it writes `samples/<sample-id>-overlay.pdf` (red = ours, blue = filed, black = both agree; pages paired by text) and commit it, so anyone can see the difference at a glance.
2. View every page (not a sample, not page 1) next to the corresponding exemplar page. The exemplar settles only what the rules leave open: cover layout, heading styles, TOC/TOA style.
3. Record a row per page in `reviews/YYYY-MM-DD.md`:

```
## sample <id>
sha256: <sha256 of the PDF reviewed>
| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | cover: ... | PASS |
| 2 | exemplar p.2 | TOC wraps ... | FIXED |
| 3 | exemplar p.3 | TOA cite line indented more than the exemplar | ACCEPTED |
```

Statuses: `PASS` nothing to report; `FIXED` a defect was found, fixed, and the page re-viewed; `ACCEPTED` an open-choice difference from the exemplar, stated in the Finding; `OPEN` a defect. **A listed defect is a FAIL.** The check fails when the newest review's recorded sha256 is not the current PDF's (the review is stale), when any page has no row, or when any row is `OPEN`. A reviewer agent that has not rendered and looked at the page does not get to write the row.

### Gate 3: generalization

Render a second sample that is *structurally* different from the first and run gates 0 to 2 on it. `checks.yaml` lists the features it must exercise and the checker verifies them (for ca9: footnotes, block quotations, several parties on a side, four levels of Argument headings, an addendum, a certificate of service, a related-cases list, an issues list, every group of the table of authorities, and paragraphs that begin with markdown markers: `90\. `, `\- `, `\+ `, `2\) `). Passing only the sample you tuned on proves nothing.

### Exit

All gates green on every sample, for an engine, writes that engine's stamp. A court with `rules.md` and a passing typst stamp is "up for review" in the tracker (`tools/tracker.sh`); latex and docx passes show in their own columns and in the court's percentage. The tracker trusts stamps, so run the checker; never write one by hand. **"Done" is never set by an agent.** Only David sets `"status": "done"` in the court's `court.json`.

## Rules of the loop

- **R1. Rule-driven, content-agnostic templates.** No case-specific text. No coordinates measured off a filed PDF. No forced line breaks. Numbers in a template trace to a rule (margins, 14 pt) or are named style parameters at the top of the file. The exemplar is a visual reference for open choices only.
- **R2. No aggregates.** Every check is pass/fail on its worst instance and prints that instance. No scores, no "mostly".
- **R3. Fonts cannot fall back.** Fonts are vendored in `fonts/` with their licenses; compile with `--font-path fonts --ignore-system-fonts`; treat any typst warning as a failure (`tools/render.sh` does); assert embedded font names (`pdffonts`) in Gate 1.
- **R4. Content before layout.** Gate 0 runs first. A page that looks right but dropped a paragraph is a failed page.
- **R5. Look at every page.** Gate 2 requires a row per page for the current PDF. Page 1 is the page least likely to be broken.
- **R6. The checker is tested.** `tools/check-selftest.sh <court-dir>` makes one deliberate break at a time (drop a paragraph, strip italics, alter a footnote, single-space the body, shrink the type, narrow the margins, left-align headings, swap the font, miscount the words, mislabel an Argument heading, shift a TOA page) and requires the named check to fail. Run it after changing any check. A check that cannot fail is not a check.
- **R7. Log the loop.** Each iteration (what failed, what changed) is one short entry in the court's `LOG.md`.
- **R8. Stable IDs.** `CA9-...` IDs are never renumbered. Withdraw one by marking it `(withdrawn)` in `rules.md`.
- **R9. Primary sources.** Every requirement cites the rule text and URL it came from, with the date it was verified, and says whether it is mandated or conventional.

## Adding a court

0. Claim the court (`sh tools/claim.sh --next`, `--random` or an alias; see AGENTS.md) so no other agent works it.
1. `rules.md`: research the current rules from primary sources; number every requirement with a stable ID; mark each M/C/T/A, and group them by tier (tier 1 = the `M` ones). For tier-2 choices, record whether each is a convention (seen across filers) or one filer's style. Note where the court's local rules override the national ones (ca9 does: no disclosure statement in the brief, 14,000 words).
1a. Exemplars: collect 2 or 3 public filings from **different filers** into `exemplars/` and record each file's source URL (and filer, case, date) in `exemplars/SOURCE.md`.
2. `checks.yaml`: one entry per mechanically checkable ID. Reuse the methods in `tools/check/lib.sh`; add a method (one shell function, one `method:` name) only for something new.
3. Typst template in `typst/` (entry point `main.typ`), consuming markdown with a YAML frontmatter contract documented in the court's README. Then the latex template in `latex/` and the docx template in `docx/` (see Engines above).
4. Two samples in `samples/`: one transcribed from the exemplar for visual comparison, one structurally different and fictional. Render both.
5. Run `tools/check.sh <court-dir>` until Gates 0 and 1 are green, then do Gate 2 for real, then Gate 3, logging each iteration. Repeat with `--engine latex` and `--engine docx`. Stop at tier 2: do not chase tier 3.
6. Run `tools/check-selftest.sh <court-dir>`, adding mutants for any new check.
7. Run `tools/tracker.sh` and commit the regenerated files.

## Tools

| Tool | Role |
|---|---|
| `tools/claim.sh <alias>\|--next\|--random [--dry-run]` | Claim a court by atomically creating remote branch `court/<alias>`. Order in `data/priority.json`. |
| `tools/render.sh [--engine typst\|latex\|docx] <court-dir> <sample.md>` | Compile one sample with vendored fonts only; any typst warning fails. Dispatches to `tools/render-latex.sh` / `tools/render-docx.sh`. |
| `tools/check.sh <court-dir> [--engine E] [--no-render] [--only ID]` | Gates 0 to 3 as far as they can be mechanical, on that engine's PDF. Exit 0 only if every check passes; writes/removes `samples/.check-<engine>.txt`. |
| `tools/overlay.sh <court-dir> <sample-id>` | Red/blue overlay of a sample on its exemplar. A diagnostic (tier 3), not a score. |
| `tools/check-selftest.sh <court-dir>` | Mutation test of the checker. |
| `tools/check/*.awk`, `tools/check/lib.sh` | The checks. Dependencies: gawk, yq (mikefarah), jq, typst, poppler (`pdfinfo pdffonts pdftotext pdftohtml pdfimages`), `shasum`; latex: pandoc, tectonic or xelatex; docx: pandoc, LibreOffice (`soffice`), unzip, xmllint. |

## Replacing the shell checker with a Rust validator

`tools/check.sh` is deliberately simple and readable so its behavior can be reimplemented exactly. The contract the Rust validator must honor:

- **Input**: `<court-dir>/checks.yaml` (samples, parameters, form wording, the check list), the sample markdown with its YAML frontmatter, the rendered PDF, `court.json`, and `reviews/*.md`. Nothing else.
- **Output**: for each check, in the order listed, `PASS`/`FAIL` with the requirement ID, the measured value, the expected value, the failing instances, and `template-file:line` found by searching `fix.anchor` in `template`. Exit status 0 iff no check fails.
- **Semantics that are part of the contract**: the normal form of Gate 0 (lower case, straight quotes, ligatures expanded, all whitespace removed); the footnote numbering rule (numbers follow the order of references in the body); headings placed before the block that follows them; word count by whitespace-delimited tokens, with list markers and footnote references not counted and everything after the `# Addendum` heading excluded; the `-v`-free parameters in `checks.yaml: params`; tolerances only where `checks.yaml` states them.
- **Parity test**: the Rust validator and `tools/check.sh` must produce the same PASS/FAIL set on both samples and on every mutant in `tools/check-selftest.sh`. Delete the shell checker only when that holds.
- **What changes for the better**: exact PDF object parsing (real font names and sizes per glyph, real italic flags, link annotations) instead of poppler's word boxes, which lets several calibrations here (the height of a 14 pt word, the footer position) become direct measurements. It must not change what is checked.
- **Engines and stamps**: the validator takes the same `--engine` flag, checks `<id>.latex.pdf` / `<id>.docx.pdf` for the other engines, honors `engines:` in `checks.yaml`, and writes and removes `samples/.check-<engine>.txt` exactly as `tools/check.sh` does (the tracker reads it).
