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
- The exemplars are public filings, collected into `usage/` as `FILED-EXAMPLE-<doctype>[-<n>].pdf` (2 or 3, different filers), with the source URL of each file recorded in `usage/SOURCE.md` (filename, filer, case, date filed, URL, date retrieved). A court with fewer than 2 exemplars cannot finish tier 2; say so in the PR instead of judging against one filer.

## Folder layout: `usage/`

A doc folder (a court folder with `court.json`, or a doc-type folder under one) keeps everything a template is judged with in one folder, `usage/`. The file role is in the name:

| File | What |
|---|---|
| `SOURCE.md` | where each FILED-EXAMPLE came from: file, filer, case, docket, date filed, URL, date retrieved |
| `MASKS.json` | optional regions `fb diff` ignores (clerk stamps), keyed by FILED-EXAMPLE file name |
| `FILED-EXAMPLE-<id>.pdf` | a real filing (public court record) |
| `INPUT-<id>.md` | markdown we feed in (transcribed from `FILED-EXAMPLE-<id>.pdf` when that exists) |
| `OUTPUT-<id>.typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` | our render of the INPUT with the same `<id>` |
| `.check-<engine>.txt`, `.match-<engine>.txt` | pass stamps written by `fb check` / `fb match-stamp` |

Example, `courts/fifth-circuit/texas/federal/eastern-district/complaint/usage/`: `FILED-EXAMPLE-complaint.pdf`, `FILED-EXAMPLE-complaint-2.pdf`, `INPUT-complaint.md`, `OUTPUT-complaint.typst.pdf`, `OUTPUT-complaint.docx`, `SOURCE.md`.

`<id>` is `<doctype>[-<n>]`: `<doctype>` is the doc-type folder's own name (`complaint`, `motion-brief`); in a court-root folder (the one with `court.json`) it is any known doc type, since court roots hold exemplars of several (`FILED-EXAMPLE-amicus-brief-2.pdf`). `<n>` is an integer >= 2; no suffix means 1. No court alias and no case or party name goes in a file name. Files pair by identical id: `INPUT-x.md` renders to `OUTPUT-x.<engine>.pdf` and was transcribed from `FILED-EXAMPLE-x.pdf` when that exists; a fictional INPUT takes an `<n>` with no FILED-EXAMPLE. A folder with nothing to hold has no `usage/` (court roots without exemplars have none). `fb usage` prints every one of these names (scripts never parse them), and `fb lint paths` (`just lint`) fails on any other file in `usage/` (in a doc-type folder the `<doctype>` must be the folder's name; in a court root it must be a key of `data/doctypes.json` or the name of a doc-type folder in the repo), on any OUTPUT whose INPUT is missing, and on any `samples/`, `exemplars/`, `OVERLAY-*` or `SAMPLE-*` under `courts/`. Overlays are generated into the gitignored `<repo>/.overlay/<doc path>/OVERLAY-<id>.pdf` and `.txt`, never committed.

## Engines (typst, latex, docx)

A court is delivered in three engines from the same markdown contract. Each has a folder in the doc folder and its own rendered output in `usage/`:

| Engine | Folder | Output in `usage/` (per `INPUT-<id>.md`) | Checked on |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-<id>.typst.pdf` | that PDF |
| latex | `latex/` | `OUTPUT-<id>.latex.pdf` | that PDF |
| docx | `docx/` | `OUTPUT-<id>.docx` and `OUTPUT-<id>.docx.pdf` (`soffice --headless --convert-to pdf`) | the LibreOffice PDF |

Commands: `sh tools/render.sh --engine latex|docx <doc-dir> usage/INPUT-<id>.md` (or `tools/render-latex.sh`, `tools/render-docx.sh`) and `sh tools/check.sh <doc-dir> --engine typst|latex|docx` (default typst). `just render <doc-dir>` renders every INPUT of a folder with typst; `just check <doc-dir>` runs the checker. The same gates run on each engine's PDF. Run all three before opening the PR.

- **typst** is the primary template and the reference for what the court wants. Do it first.
- **latex**: the same markdown contract, converted with `pandoc --to latex` through a per-court template (`latex/template.tex`, plus optional `latex/*.lua` filters) or a hand-written class, compiled with stock pdflatex (default: the pinned TeX Live 2025 from `tools/bootstrap.sh`, run until the aux file settles) or, with `LATEX_ENGINE=tectonic|xelatex`, XeTeX (a template that still loads fontspec stays on tectonic until it migrates). The LaTeX target is interop: a stranger must compile the generated `.tex` with stock pdflatex on stock TeX Live, so after a pdflatex build `fb render` compiles the `.tex` alone in an empty directory with `TEXINPUTS` unset and refuses the render if that fails or the `.tex` names a repo path. Fonts therefore come from TeX Live packages, not `fonts/`: for Times, `\usepackage{newtxtext,newtxmath}`; for TeX Gyre Schola (Century Schoolbook), `\usepackage{tgschola}`. A court may instead supply `latex/render.sh <court-dir> <sample.md> <out.pdf>` that owns the whole build. Gate 1 asserts the embedded font names; on the latex engine only, a template whose declared face is Times New Roman (or Liberation Serif, its metric twin) may embed a metric-compatible Times (TeXGyreTermesX, TeX Gyre Termes, NewTX; typst and docx stay Times New Roman).
- **docx** is the hard case: markdown to docx with pandoc and a per-court `docx/reference.docx` (styles, page setup, headers and footers), plus Lua filters (`docx/*.lua`) for the cover and the certificates. Use Word-native features wherever they exist: section line numbering (`w:lnNumType`) for pleading paper, page borders for pleading rules, a TOC field for the table of contents, TA/TOA fields for the table of authorities, keep-with-next on headings, widow/orphan control. A court may supply `docx/render.sh <court-dir> <sample.md> <out.docx>` to own the build. Known limits (things courts want that Word cannot express, or LibreOffice renders differently) are in [DOCX.md](DOCX.md). The `.docx` itself must also open in Word and in LibreOffice without a repair prompt; the renderer checks it is a valid zip of well-formed XML, and the reviewer opens it in LibreOffice.
- **Per-engine checks.** `checks.yaml` checks run on every engine by default. A check that cannot apply to an engine (for example embedded-font names in a docx PDF, or PDF bookmarks that LibreOffice does not emit) carries `engines: [typst, latex]` and `engines_reason: "..."`; `check.sh` prints it as SKIP with the reason. Do not use this to hide a failing tier 1 requirement: a skipped check is only legitimate when the property does not exist in that engine, and the reason must say why.
- **Gate 2 per engine.** Each engine's PDF gets its own review. Sections in `reviews/*.md` are `## sample <id>` for typst and `## sample <id> <engine>` for latex and docx, each with that PDF's sha256 and a row per page.
- **Stamp.** On a full green run (no `--only`), `check.sh` writes `usage/.check-<engine>.txt`: the line `PASS`, then `sha256  path` for every PDF checked (and the `.docx`). Any failing run removes it. The tracker counts an engine as passing only if the stamp exists and every hash still matches the file on disk, so regenerating a PDF without re-running the check turns the engine back to "built".
- **BLOCKED / partial docx.** If a docx cannot reach green, the PR delivers it as BLOCKED and lists the exact failing check IDs and why (a Word limit, a LibreOffice rendering difference, a missing feature). That is acceptable. A docx that is silently missing or silently failing is not. The same applies to latex.

## Default checks and `just eval`

A court that has a `checks.yaml` (today only `courts/ninth-circuit/court-of-appeals/`) is judged by it. Every other doc folder is judged by the court-agnostic tier-1 set in [`data/checks-default.yaml`](../data/checks-default.yaml): `fb check <doc folder>` falls back to it when `<doc folder>/checks.yaml` does not exist, with one sample per `usage/INPUT-<id>.md`. It writes the same stamp (`usage/.check-typst.txt`) on a full green run, so the tracker needs nothing court-specific.

| Id | Gate | What it checks |
|---|---|---|
| `DEF-RENDER-001` | (driver) | the INPUT renders with `fb render --deny-warnings` (no typst warning, a PDF exists) |
| `DEF-CONT-001` | 0 | every INPUT block (section heading, paragraph, quote, list item) appears in the PDF, in order, unaltered; hyphens are ignored on both sides because templates may hyphenate |
| `DEF-FORM-001` | 1 | every page is US letter, 612 x 792 pt |
| `DEF-FORM-002` | 1 | no text in the 1 in margins (page numbers in the bottom margin excepted) |
| `DEF-FORM-003` | 1 | body text (the most common word height) is at least 12 pt |
| `DEF-FONT-001` | 1 | every font in the PDF is embedded |
| `DEF-FONT-002` | 1 | every embedded font starts with a family the template declares (`#let font-family|face|typeface|body-font|font-name = ...` in `typst/*.typ`; the repo default `Times New Roman`/`Liberation Serif` when it declares none), so a silent fallback fails |
| `DEF-LEN-001` | 1 | page count <= `params.page_limit`; SKIP while no limit is set |
| `DEF-TOC-001` | 1 | the layout of a TABLE OF CONTENTS / TABLE OF AUTHORITIES, when there is one (`fb toc-layout` runs the same test on any PDF): no page reference alone on a line (wrapped off its entry), no dot leaders without a page reference after them, and at least 2 pt clear between the rule under the `Page`/`Page(s)` column heading and the ink below it (read from a 288 dpi raster). Engine-neutral; passes when there is no table |

Rules that need court data and have none in machine-readable form are skipped, never guessed: `rules.md` is prose, so the page limit, a size other than 12 pt and a margin other than 1 in are SKIP/defaults until someone supplies them. To state a number for a court (or one doc folder), add an `eval.yaml` beside `rules.md` (or in the doc folder); its keys are merged over the default file (`font.size_pt`, `params.margin_pt` as an all-sides fallback, `params.margin_top_pt`, `params.margin_bottom_pt`, `params.margin_left_pt`, `params.margin_right_pt`, `params.page_limit`, `params.page_width_pt`/`page_height_pt`). Each side-specific value overrides `margin_pt` only for that side; omitted sides use `margin_pt`. The merged file is written to `out/check/<alias>/<doc>/checks-effective.yaml`. Nothing else court-specific (cover contents, section order, certificates, TOC/TOA contents and page numbers, pleading-paper line numbers, word counts) is checked by default; that is what a court-level `checks.yaml` is for.

A court is **up for review** when it has `rules.md` and every doc folder under it that holds at least one `INPUT` has a valid typst stamp (and at least one does). A doc folder is **up for review** when its own stamp is valid, **in progress** when something is present, **todo** otherwise. `done` stays manual (`court.json`).

`just eval DIR` runs `fb check` on every doc folder with an INPUT under DIR (folders with their own `checks.yaml` are left to `just check`) and then regenerates the tracker (README index, STATUS.md, folder READMEs); `just eval-all` does `courts/`. Re-run it after any template or INPUT change: a folder that now passes gets a stamp and is marked up for review, one that regressed loses its stamp. `fb eval` always exits 0; the failing check ids are printed per folder and counted at the end.

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

1. Render every page: `pdftoppm -r 100 -png sample.pdf out/p`. For the sample transcribed from the exemplar, also run `just overlay <doc-dir>` (or `tools/overlay.sh <doc-dir> <id>`): it reads `usage/OUTPUT-<id>.typst.pdf` and the same-id `usage/FILED-EXAMPLE-<id>.pdf` and writes `.overlay/<doc path>/OVERLAY-<id>.pdf` and `.txt` (red = ours, blue = filed, black = both agree; pages paired by text). `.overlay/` is gitignored: overlays are regenerated on demand, never committed.
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

0. Claim the court (`just claim --next`, `--random` or an alias; see AGENTS.md) so no other agent works it.
1. `rules.md`: research the current rules from primary sources; number every requirement with a stable ID; mark each M/C/T/A, and group them by tier (tier 1 = the `M` ones). For tier-2 choices, record whether each is a convention (seen across filers) or one filer's style. Note where the court's local rules override the national ones (ca9 does: no disclosure statement in the brief, 14,000 words).
1a. Exemplars: collect 2 or 3 public filings from **different filers** into `usage/FILED-EXAMPLE-<doctype>[-<n>].pdf` and record each file's source URL (and filer, case, date) in `usage/SOURCE.md`.
2. `checks.yaml`: one entry per mechanically checkable ID. Reuse the methods in `tools/check/lib.sh`; add a method (one shell function, one `method:` name) only for something new.
3. Typst template in `typst/` (entry point `main.typ`), consuming markdown with a YAML frontmatter contract documented in the court's README. Then the latex template in `latex/` and the docx template in `docx/` (see Engines above).
4. Two inputs in `usage/` (`INPUT-<doctype>[-<n>].md`): one transcribed from the exemplar for visual comparison (same suffix as its FILED-EXAMPLE), one structurally different and fictional (an `<n>` with no FILED-EXAMPLE). Render both (`just render <doc-dir>`).
5. Run `tools/check.sh <court-dir>` until Gates 0 and 1 are green, then do Gate 2 for real, then Gate 3, logging each iteration. Repeat with `--engine latex` and `--engine docx`. Stop at tier 2: do not chase tier 3.
6. Run `tools/check-selftest.sh <court-dir>`, adding mutants for any new check.
7. Run `just lint` (font audit and `usage/` path validity), then `tools/tracker.sh`, and commit the regenerated files.

## Word compatibility (fb-w0vj)

Most filed exemplars are Microsoft Word output. Word's paragraph composer is solved once, in `lib/typst/word-compat.typ`, not per court. A template applies it after its own `set text`/`set par` rules:

```typst
#import "/lib/typst/word-compat.typ": word-compat
show: word-compat.with(meta.at("word", default: (:)))
```

It always sets what Word does for ordinary prose: kerning off, hyphenation off, greedy line breaking (`linebreaks: "simple"`), no tracking adjustment, no hanging punctuation. Two settings belong to the filed document, not the court, and come from the INPUT's frontmatter:

```yaml
word:
  justify: true    # the Word document's body is justified (false: ragged right)
  shrink: 0.76     # Word 2013+ compresses inter-word spaces to 0.76 of normal before moving a word down;
                   # 1.0 (or absent) for documents in an older compatibility mode, which never compress
```

How to tell from the exemplar: `justify` when most lines of eight or more words end at the right margin; `shrink: 0.76` when some of those lines have inter-word gaps below the normal space (0.25 em), `1.0` when none do (`fb measure` gives the word boxes).

### Calibration (21 Times New Roman exemplars, `data/calibration-set.json`)

`tools/calibrate.sh [--engine typst|latex] [--no-render] [dir-substring]` renders every entry and prints, per entry and in total, G0 and G2 (`fb diff --content`) and three line-break measures from `fb diff --breaks`, which pairs the two word streams globally (unique 4-word anchors, longest increasing run, LCS in the gaps) so it runs even when G0 to G2 fail on template residuals:

- **identical lines**: exemplar lines all of whose words are paired, in one run, that ours breaks before the first word, after the last and nowhere between (page and line breaks count alike). End to end: template geometry, composition and cascades.
- **same-start lines**: the subset ours starts at the same word and the same left edge (0.5 pt). On these only composition decides where the line ends, so this is the word-compat measure. Misses are split into "ours fits more" and "ours fits less".
- **positions**: on same-start identical lines with a one-to-one word mapping, the largest left- or right-edge difference of any word.

Results, typst 0.15.1, pinned Times New Roman 2.82 (run 2026-10-21; raw output in the PR artifacts):

| Step | Identical lines | Same-start lines (more / less) | G0 pass |
|---|---|---|---|
| Baseline (templates as merged, no word-compat) | 1552/3235 (48.0%) | 936/1145 (81.7%) (57 / 152) | 13/21 |
| word-compat defaults (kerning, hyphenation, greedy) | 1568/3258 (48.1%) | 983/1193 (82.4%) (48 / 162) | 13/21 |
| + `word: justify` (typst's greedy breaker ignores `justification-limits` shrink: no break changed) | 1568/3258 | 983/1193 | 13/21 |
| + narrow natural space in justified text, shrink 0.76 | 1924/3275 (58.7%) | 1285/1450 (88.6%) (91 / 74) | 12/21 |
| + idb-motion-brief at the filers' 12 pt (the 13 pt was an EB Garamond leftover) and 27.6/13.8 pt pitch | 2028/3282 (61.8%) | 1390/1549 (89.7%) (99 / 60) | 13/21 |
| + no hanging punctuation (final) | 2028/3282 (61.8%) | 1391/1550 (89.7%) (99 / 60) | 13/21 |

Final positions: 1387 same-start identical lines; largest word-edge difference within 0.05 pt on 57, within 0.25 pt on 573, within 1 pt on 868.

Shrink sweep (same-start identical / compared): 0.72 1247/1422, 0.74 1277/1444, **0.76 1299/1464**, 0.78 1256/1422, 0.80 1242/1410, 0.84 1169/1347, 0.88 1120/1309 (sweep run before the idb fix, with the narrow space set document-wide). A per-document sweep moved individual entries by 0 to 14 lines (35 on the scaled bap9 exemplar, where a smaller shrink only compensates the scale), so one value is kept for every Word 2013+ document.

### What the exemplars say about Word

- Inter-word compression has a floor: the narrowest gap on a justified line is 0.757 to 0.770 of the normal space in 8 of the 12 compressing documents (0.742, 0.80 and 0.833 in three more; 0.686 in the scaled bap9 exemplar). Three justified exemplars (idb, ilsd, wyb) never compress (an older compatibility mode). Six are ragged right.
- Word's keep-or-push decision is **not** a single threshold on space compression. Fitted per document on the true advance widths, the best threshold explains 88% to 100% of the decisions (arkansas 192/210, txed 169/182, delaware 161/182, ilsd 154/156); globally 2455/2746 at 0.90. Counterexample in one document (ared p2): a line was kept that needs its spaces at 0.794, while another line pushed down a word that needed only 0.907.
- Hinted widths do not explain it: the same test on the `hdmx` advances of the pinned Times New Roman at every recorded ppem (11 to 100; 16 ppem is 12 pt at 96 dpi) is never more consistent than the true advances (16 ppem: 1789/2746).
- Word's PDF export puts the left margin at 72.00 or 72.02 pt (7 exemplars each) and ends justified lines 0.09 to 0.23 pt past the right margin.

### Per-gate residuals (typst, final)

| Gate | Result on the 21 | Residual |
|---|---|---|
| G0 page count/size | 13/21 pass | the 8 failures are template pagination (signature or a heading pushed over a page, a 3-page motion bound in front of the ca7 brief, a scaled bap9 exemplar), recorded per entry in `data/calibration-set.json` (`g0.why`, from fb-w0vj.1). Changed here: idb now passes (12 pt); txed now fails (exemplar 8 pages, ours 7: with compressed spaces its text, under a template that indents paragraph numbers 0.5 in where the filer used 0.25 in, fits on 7) |
| G1 text frame | 0/21 pass | every entry: left 72.00 vs 72.02 or right 540.00 vs 540.09 to 540.23 (Word export, above the 0.01 pt tolerance); plus unmasked CM/ECF header stamps (no `MASKS.json` yet) and template margins/indents (vawd, orb, ca10, cavc) |
| G2 content | 0/21 pass | template-generated text only (captions, page numbers, doc-ID footers, /s/ lines); body divergences 0 (fb-w0vj.1) |
| G3 breaks | 2028/3282 identical lines; composition 1391/1550 | see "Go/no-go" |
| G4 | not reached | |

Tolerances: `tools/fb/tolerance.json` stays at 0.01 pt (two builds of the same sample agree exactly). Against a Word exemplar the floor is measured, not tolerated: 0.02 pt on left edges, 0.23 pt on justified right edges. A G1/G3 tolerance below 0.25 pt cannot pass on Word exemplars even when composition is identical.

### Go/no-go for "identical"

**No-go with typst 0.15.** The ceiling measured here: about 90% of lines that start alike end alike (composition only); 61.8% of comparable lines identical end to end; on lines that do break identically, word edges within 0.25 pt on 41%. Three causes, in order of weight:

1. Word's line-fit decision is not a reproducible threshold (88% to 100% per document at best). A miss changes every later line of the paragraph, so the chance that a whole multi-page brief breaks identically is near zero even at 90% per line.
2. Typst cannot test a line with compressed spaces and still set the last line of a paragraph with natural spaces: its greedy breaker only looks at natural width, so word-compat narrows the space itself, and every last line (and single-line paragraph) of a justified Word 2013+ document is set with spaces at 0.76 of normal (0.72 pt short per gap at 12 pt).
3. Template geometry chosen from other filers (indents, type size, margins, counsel blocks) and exemplars that are scaled or carry CM/ECF stamps: per template, not per engine; fixed here only where the template contradicted both of its own exemplars (idb).

**LaTeX**: not calibrated. Only 1 of the 21 calibration folders has a `latex/` engine, and the LaTeX engine has no Word-composition layer (the LuaLaTeX one was retired, fb-595.44).

## Tools

| Tool | Role |
|---|---|
| `just claim <alias>\|--next\|--random [--dry-run]` | Claim a court by atomically creating remote branch `court/<alias>`. Order in `data/priority.json`. |
| `tools/render.sh [--engine typst\|latex\|docx] <doc-dir> usage/INPUT-<id>.md` | Compile one sample with vendored fonts only; any typst warning fails. Dispatches to `tools/render-latex.sh` / `tools/render-docx.sh`. |
| `tools/check.sh <court-dir> [--engine E] [--no-render] [--only ID]` | Gates 0 to 3 as far as they can be mechanical, on that engine's PDF. Exit 0 only if every check passes; writes/removes `usage/.check-<engine>.txt`. |
| `tools/overlay.sh <doc-dir> <id> [FILED-EXAMPLE.pdf]` | Red/blue overlay of `OUTPUT-<id>.typst.pdf` on `FILED-EXAMPLE-<id>.pdf`, into the gitignored `.overlay/`. A diagnostic (tier 3), not a score. |
| `tools/calibrate.sh [--engine E] [--no-render] [dir]` | The word-compat calibration run over `data/calibration-set.json`: G0, G2, identical and same-start line breaks, word positions (`fb diff --content`, `fb diff --breaks`). |
| `justfile` | `just render\|overlay\|check\|diff <doc-dir>`, `just render-all\|overlay-all\|check-all`, `just lint` (`fb lint fonts`, `fb lint paths`, `fb lint rules`). Straight pipelines into `fb` and the scripts above. |
| `fb usage doctype\|dir\|inputs\|examples\|pairs\|input\|example\|pair\|output\|overlay <doc-dir> ...` | Prints the `usage/` and `.overlay/` names of a doc folder, so no script parses file names. |
| `tools/check-selftest.sh <court-dir>` | Mutation test of the checker. |
| `tools/check/*.awk`, `tools/check/lib.sh` | The checks. Dependencies: gawk, yq (mikefarah), jq, typst, poppler (`pdfinfo pdffonts pdftotext pdftohtml pdfimages`), `shasum`; latex: pandoc, pdflatex (TeX Live 2025), or tectonic or xelatex; docx: pandoc, LibreOffice (`soffice`), unzip, xmllint. |

## Replacing the shell checker with a Rust validator

The driver (`tools/check.sh`, a thin wrapper around `fb check` in `tools/fb`) is Rust: argument parsing, calibration, per-sample preparation, check ordering, SKIP/PASS/FAIL output and stamps. Verdicts for `g0_content`, `g0_italics`, `g0_footnotes`, `page_size` and `page_limit` are evaluated natively in Rust. Other `chk_<method>` verdicts still use the compatibility bridge into `tools/check/lib.sh`; remove that bridge only after every method is native and parity passes. The contract the Rust validator must honor:

- **Input**: `<court-dir>/checks.yaml` (samples, parameters, form wording, the check list), the sample markdown with its YAML frontmatter, the rendered PDF, `court.json`, and `reviews/*.md`. Nothing else.
- **Output**: for each check, in the order listed, `PASS`/`FAIL` with the requirement ID, the measured value, the expected value, the failing instances, and `template-file:line` found by searching `fix.anchor` in `template`. Exit status 0 iff no check fails.
- **Semantics that are part of the contract**: the normal form of Gate 0 (lower case, straight quotes, ligatures expanded, all whitespace removed); the footnote numbering rule (numbers follow the order of references in the body); headings placed before the block that follows them; word count by whitespace-delimited tokens, with list markers and footnote references not counted and everything after the `# Addendum` heading excluded; the `-v`-free parameters in `checks.yaml: params`; tolerances only where `checks.yaml` states them.
- **Parity test**: the Rust validator and the shell checks run by `tools/check.sh` (`tools/check/lib.sh`) must produce the same PASS/FAIL set on both samples and on every mutant in `tools/check-selftest.sh`. Delete the shell checker only when that holds.
- **What changes for the better**: exact PDF object parsing (real font names and sizes per glyph, real italic flags, link annotations) instead of poppler's word rectangles, which lets several calibrations here (the height of a 14 pt word, the footer position) become direct measurements. It must not change what is checked.
- **Engines and stamps**: the validator takes the same `--engine` flag, checks `OUTPUT-<id>.latex.pdf` / `.docx.pdf` for the other engines, honors `engines:` in `checks.yaml`, and writes and removes `usage/.check-<engine>.txt` exactly as `tools/check.sh` does (the tracker reads it).
