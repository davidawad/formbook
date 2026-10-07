# The eval loop

Every court template in formbook is built, judged and promoted by the same loop. `courts/ninth-circuit/court-of-appeals/` is the reference implementation: copy its structure, not its numbers.

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

All gates green on every sample makes the court folder eligible for "up for review". The tracker (`tools/tracker.sh`) already derives that from the folder's contents (`rules.md`, a sample `.md`, a `.typ` template, a rendered `.pdf`), so run the checker before trusting it. **"Done" is never set by an agent.** Only David sets `"status": "done"` in the court's `court.json`.

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

1. `rules.md`: research the current rules from primary sources; number every requirement with a stable ID; mark each M/C/T/A. Note where the court's local rules override the national ones (ca9 does: no disclosure statement in the brief, 14,000 words).
2. `checks.yaml`: one entry per mechanically checkable ID. Reuse the methods in `tools/check/lib.sh`; add a method (one shell function, one `method:` name) only for something new.
3. Template in `typst/` (or `latex/`), entry point `main.typ`, consuming markdown with a YAML frontmatter contract documented in the court's README.
4. Two samples in `samples/`: one transcribed from the exemplar for visual comparison, one structurally different and fictional. Render both.
5. Run `tools/check.sh <court-dir>` until Gates 0 and 1 are green, then do Gate 2 for real, then Gate 3, logging each iteration.
6. Run `tools/check-selftest.sh <court-dir>`, adding mutants for any new check.
7. Run `tools/tracker.sh` and commit the regenerated files.

## Tools

| Tool | Role |
|---|---|
| `tools/render.sh <court-dir> <sample.md>` | Compile one sample with vendored fonts only; any typst warning fails. |
| `tools/check.sh <court-dir> [--no-render] [--only ID]` | Gates 0 to 3 as far as they can be mechanical. Exit 0 only if every check passes. |
| `tools/check-selftest.sh <court-dir>` | Mutation test of the checker. |
| `tools/check/*.awk`, `tools/check/lib.sh` | The checks. Dependencies: gawk, yq (mikefarah), jq, typst, poppler (`pdfinfo pdffonts pdftotext pdftohtml pdfimages`), `shasum`. |

## Replacing the shell checker with a Rust validator

`tools/check.sh` is deliberately simple and readable so its behavior can be reimplemented exactly. The contract the Rust validator must honor:

- **Input**: `<court-dir>/checks.yaml` (samples, parameters, form wording, the check list), the sample markdown with its YAML frontmatter, the rendered PDF, `court.json`, and `reviews/*.md`. Nothing else.
- **Output**: for each check, in the order listed, `PASS`/`FAIL` with the requirement ID, the measured value, the expected value, the failing instances, and `template-file:line` found by searching `fix.anchor` in `template`. Exit status 0 iff no check fails.
- **Semantics that are part of the contract**: the normal form of Gate 0 (lower case, straight quotes, ligatures expanded, all whitespace removed); the footnote numbering rule (numbers follow the order of references in the body); headings placed before the block that follows them; word count by whitespace-delimited tokens, with list markers and footnote references not counted and everything after the `# Addendum` heading excluded; the `-v`-free parameters in `checks.yaml: params`; tolerances only where `checks.yaml` states them.
- **Parity test**: the Rust validator and `tools/check.sh` must produce the same PASS/FAIL set on both samples and on every mutant in `tools/check-selftest.sh`. Delete the shell checker only when that holds.
- **What changes for the better**: exact PDF object parsing (real font names and sizes per glyph, real italic flags, link annotations) instead of poppler's word boxes, which lets several calibrations here (the height of a 14 pt word, the footer position) become direct measurements. It must not change what is checked.
