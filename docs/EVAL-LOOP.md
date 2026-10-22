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
| `DEF-COVER-001` | 1 | the cover is exactly one page and the first page after it prints the expected number (`fb cover-pages` runs the same test on any PDF): the cover is the pages before the first printed page number (bottom margin, a titled footer such as `COMPLAINT - 2` or `Page 2 of 10`, else a page number alone on the last or first line; pleading line numbers ignored), and it must be `params.cover_pages` long (1; set it in `eval.yaml` for a longer cover the rules declare). That first numbered page prints 1, i or C-1 (numbering starts after the cover) or its physical page number (the cover counted); a document numbered from page 1 prints 1 there. So a cover that overflows, shifting every page number, fails. A longer cover is accepted only when the cover content a rule requires (every party or attorney, the full caption) cannot fit one page: set `params.cover_pages` in the doc folder's `eval.yaml` with a comment citing that content rule (michigan petition-for-rehearing, MCR 1.109(D)(1)(b); ohio petition-for-writ, RoP 3.07; pa supreme-court petition-for-writ, Pa.R.A.P. 2172(a); fb-595.73.2). Where the rule allows, counsel beyond lead counsel move to the signature block instead (TRAP 9.4(g): texjpml, fb-595.73.1). Engine-neutral |
| `XENG-001`..`003` | 4 | latex and docx only: the same pages, page ends and line breaks as the typst render (see "Cross-engine gate"); REPORTED, not counted, unless `params.cross_engine: gate` |

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

The PDF text and the markdown are reduced to one normal form (lower case, straight quotes, ligatures expanded, **all** whitespace removed, and every dot leader, four dots or more, reduced to four) so line breaks and leader lengths can never matter, but a missing or altered character always does. Page numbers are dropped by position; footnotes are checked on their own (marker number plus full text) and cut out of the stream, because they sit in the middle of a paragraph that continues on the next page. Every other block, in document order, must then occur whole and contiguous after the previous one. Headings are placed just before the block that follows them, so a table of contents earlier in the PDF can never stand in for the real heading.

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

## Cross-engine gate (fb-595.54)

Every engine's output must look the same for the record: the latex and docx renders of an INPUT break every line and every page where the typst render (the reference) breaks them. A line or page break that moves between engines is a failure to fix, never a tolerance.

### Adoption checklist (one folder)

For each INPUT in the folder, render typst, latex, and docx from the same markdown, then review every page of each new render. Complete these steps before setting `params.cross_engine: gate`:

1. Compare latex and docx with typst using `fb diff --engines`; fix every different page count, page boundary, line ending, and word sequence. Do not accept a percentage or a tolerance for a changed break.
2. Run the folder's full checker on all three engines. Every tier-1 check must pass, including `DEF-COVER-001` and `DEF-TOC-001` (the latter passes when the document has no contents or authorities table).
3. Re-do the Gate 2 review against the new renders and record the reviewed pages and findings in `reviews/`. Keep unresolved differences only when an engine cannot reproduce the reference for a documented renderer limitation; identify the exact folder, INPUT, page or line, and reason, and leave that engine at `report` rather than claiming the cross-engine gate passes.
4. Once both latex and docx pass XENG-001..003 on every INPUT and all tier-1 checks pass, set `params.cross_engine: gate`. Run the folder selftest where present and include the results with the review record.

**The gate.** Gate 4 CROSS-ENGINE of `fb check` runs on the latex and docx engines (typst is the reference: SKIP there with that reason) and compares `usage/OUTPUT-<id>.<engine>.pdf` with `usage/OUTPUT-<id>.typst.pdf` (`fb diff --engines <typst.pdf> <other.pdf>` prints the same comparison by hand):

| Id | Checks |
|---|---|
| `XENG-001` | the same page count |
| `XENG-002` | every page starts and ends on the same word |
| `XENG-003` | every typst line ends after the same word in the other engine, and carries the same words (100 %; no break-word tolerance) |

Dot leaders are fill, not words (Word sets them as one run of dots touching the text, typst and LaTeX as dots apart), a no-break space counts as a space, and a word's trailing periods are not compared (a leader set right after "2020)." takes its period into the dots in one engine's PDF text and not in another's); Gate 0 checks the text itself. `params.cross_engine` decides what a difference does: `gate` (ca9, `courts/ninth-circuit/court-of-appeals/checks.yaml`) fails the check and puts the typst PDF's hash into the latex and docx stamps (the verdict holds only for that reference); `report` (the default in `data/checks-default.yaml`) prints the verdict as `REPORTED`, not counted, so no folder skips the comparison silently. A folder moves to `gate` (in its `eval.yaml`) when it passes; that is phase 2 (fan-out per circuit group). `params.cross_engine_<engine>` (`latex` or `docx`) overrides the folder's mode for that engine alone, for an engine that cannot follow the reference for a reason outside the template, written beside the key (e.g. `eighth-circuit/court-of-appeals/reply-brief`: `cross_engine_docx: report`, LibreOffice decides a line in whole twips; fb-595.54.9). `fb cross-engine` reads the same keys.

### Adoption checklist (one document folder)

- [ ] Render every `usage/INPUT-<id>.md` with typst and each available comparison engine (latex and docx). Review the generated PDFs for every page; use `fb diff --engines` to find changed lines and pages, then fix the template until page count, page starts and ends, and every line's ending word match typst (XENG-001..003).
- [ ] Run the full checks for every available engine. All tier-1 checks must have zero failures. Where the default checks apply, `DEF-COVER-001` and `DEF-TOC-001` must each have zero failures; do not mark a check passed when its required content is absent from the sample.
- [ ] Set `params.cross_engine: gate` only after latex and docx each pass XENG-001..003 for every input and all tier-1 checks pass. Keep a per-engine `report` override only for a measured limitation that cannot be fixed in the template; document the failing sample, page/line, engine behavior and check ID beside the override and in the folder README. A `REPORTED` engine is an explicit exception, not a passing gate.
- [ ] Re-render and redo the Gate 2 review on every page of every changed engine output. Update the folder README with the engines gated, any recorded exceptions, and final check results.

For the fifth-circuit district adoption (fb-595.68.14), record each of its 12 folders that cannot match by folder and engine, with its XENG check ID and specific unmatched page/line. Do not describe a `REPORTED` engine as gated. The accompanying DOCX port checklist in [DOCX.md](DOCX.md) requires deleting each folder's shell builders and reducing court-specific shell baseline entries to zero.

**Fourth Circuit part 02 adoption (fb-595.68.20, verified 2026-10-22).** The 11 assigned Virginia and West Virginia district and bankruptcy folders have typst and DOCX templates and no LaTeX templates. DOCX uses declarative `reference.xml` and Lua filters, with `{font}` resolving to the typst face; the assigned folders have no DOCX shell builders, private script-only artifacts, or entries in `.shell-safety-baseline.json`. Each folder sets `params.cross_engine: gate`. Typst and DOCX checks were rerun on every folder: tier 1 passed with zero failures, including `DEF-COVER-001` and `DEF-TOC-001`, and DOCX passed XENG-001..003 for every input. There are no reported engine exceptions.

Folders: `virginia/federal/eastern-district/motion-brief`, `virginia/federal/western-district/{complaint,motion-brief}`, `west-virginia/federal/bankruptcy-northern-district/{adversary-complaint,motion-brief}`, `west-virginia/federal/bankruptcy-southern-district/{adversary-complaint,motion-brief}`, `west-virginia/federal/northern-district/{complaint,motion-brief}`, and `west-virginia/federal/southern-district/{complaint,motion-brief}`.

**Fifth Circuit part 01 adoption (fb-595.68.14, verified 2026-10-22).** All 12 assigned Mississippi and Texas bankruptcy and district folders have typst and DOCX templates and no LaTeX templates. Each DOCX uses `reference.xml`; every folder sets `params.cross_engine: gate`, has no per-court DOCX shell script or `reference.docx`, and has no entry in `.shell-safety-baseline.json`. The folders are `mississippi/federal/bankruptcy-northern-district/{adversary-complaint,motion-brief}`, `mississippi/federal/bankruptcy-southern-district/{adversary-complaint,motion-brief}`, `mississippi/federal/northern-district/{complaint,motion-brief}`, `mississippi/federal/southern-district/{complaint,motion-brief}`, `texas/federal/bankruptcy-eastern-district/{adversary-complaint,motion-brief}`, and `texas/federal/bankruptcy-northern-district/{adversary-complaint,motion-brief}`. The recorded adoption verification found zero failed tier-1 checks across the engines present, including `DEF-COVER-001` and `DEF-TOC-001`, and DOCX XENG-001..003 passed on every input. No folder or engine remains at `report` for a cross-engine mismatch.

**Ninth Circuit part 02 adoption (fb-595.68.23, verified 2026-10-22).** These 14 folders have typst and DOCX templates and no LaTeX templates. Each DOCX uses `reference.xml` and Lua filters, with its body face inherited through `{font}` from typst. No folder retains a DOCX shell builder or binary `reference.docx`; the court-specific entries in `.shell-safety-baseline.json` are zero. All 14 folders set `params.cross_engine: gate`. On 2026-10-22, the typst and DOCX checks were rerun for every folder: all tier-1 checks passed with zero failures, including `DEF-COVER-001` and `DEF-TOC-001`; DOCX also passed XENG-001..003 on every input. No folder or engine remains at `report` for a cross-engine mismatch.

**Tenth Circuit part 01 adoption (fb-595.68.33, verified 2026-10-22).** The 12 assigned Oklahoma, Utah, and Wyoming federal district and bankruptcy folders have typst and DOCX templates and no LaTeX templates. Each DOCX uses declarative `reference.xml` and Lua filters, inherits its face through `{font}` from typst, and has no per-court shell builders or private script-only artifacts. The assigned-folder entries in `.shell-safety-baseline.json` are zero, and every folder sets `params.cross_engine: gate`. The recorded verification found zero failed tier-1 checks in both engines, including `DEF-COVER-001` and `DEF-TOC-001`; DOCX XENG-001..003 passed on every input. No folder or engine remains at `report` for a cross-engine mismatch.

Folders: `oklahoma/federal/eastern-district/{complaint,motion-brief}`, `oklahoma/federal/northern-district/{complaint,motion-brief}`, `oklahoma/federal/western-district/{complaint,motion-brief}`, `utah/federal/bankruptcy-district/{adversary-complaint,motion-brief}`, `utah/federal/district/{complaint,motion-brief}`, and `wyoming/federal/district/{complaint,motion-brief}`.

**Eleventh Circuit Georgia district adoption (fb-595.68.12, verified 2026-10-22).** These ten folders have typst and DOCX templates and no LaTeX templates. The DOCX templates use declarative `reference.xml` and Lua filters, resolve `{font}` from the typst face, and leave no DOCX shell scripts or private script-only artifacts. There are no Georgia entries in `.shell-safety-baseline.json`. Every folder sets `params.cross_engine: gate`. The typst and DOCX checks were rerun for each folder: tier 1 passed with zero failures, including `DEF-COVER-001` and `DEF-TOC-001`, and DOCX passed XENG-001..003 on every input. On `newbox/fb-595-68-12-a7`, a fresh rerun passed all 20 typst and DOCX folder checks; `cargo test -p fb` passed (320 tests, 0 failed), and `fb lint fonts` found no mismatch in the assigned folders. No folder or engine remains at `report`.

| Georgia folder | Engines | DOCX XENG-001..003 |
|---|---|---|
| `eleventh-circuit/georgia/federal/bankruptcy-middle-district/adversary-complaint` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/bankruptcy-middle-district/motion-brief` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/bankruptcy-northern-district/adversary-complaint` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/bankruptcy-northern-district/motion-brief` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/bankruptcy-southern-district/adversary-complaint` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/bankruptcy-southern-district/motion-brief` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/northern-district/complaint` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/northern-district/motion-brief` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/southern-district/complaint` | typst, docx | PASS |
| `eleventh-circuit/georgia/federal/southern-district/motion-brief` | typst, docx | PASS |

| State | Folders |
|---|---|
| Idaho | `idaho/federal/bankruptcy-district/motion-brief`; `idaho/federal/district/complaint`; `idaho/federal/district/motion-brief` |
| Montana | `montana/federal/bankruptcy-district/adversary-complaint`; `montana/federal/bankruptcy-district/motion-brief`; `montana/federal/district/complaint`; `montana/federal/district/motion-brief` |
| Nevada | `nevada/federal/bankruptcy-district/adversary-complaint`; `nevada/federal/bankruptcy-district/motion-brief`; `nevada/federal/district/complaint`; `nevada/federal/district/motion-brief` |
| Northern Mariana Islands | `northern-mariana-islands/federal/bankruptcy-district/adversary-complaint`; `northern-mariana-islands/federal/bankruptcy-district/motion-brief`; `northern-mariana-islands/federal/district/complaint` |

**Eighth Circuit district adoption (fb-595.68.7, verified 2026-10-22).** The 13 folders in this fan-out have typst and docx templates; none has a LaTeX template. Every folder's typst and docx `check.sh` run has zero failed checks, including `DEF-COVER-001` and `DEF-TOC-001` (the samples have no contents or authorities table). The docx face matches the typst face in all 13 folders, and `docx/` contains only declarative XML and Lua inputs: no builder/render shell scripts or binary reference documents remain. Twelve folders pass XENG-001..003 on every input:

| Folder | Engine | XENG-001..003 |
|---|---|---|
| `eighth-circuit/arkansas/federal/bankruptcy-eastern-district/adversary-complaint` | docx | PASS |
| `eighth-circuit/arkansas/federal/bankruptcy-eastern-district/motion-brief` | docx | PASS |
| `eighth-circuit/arkansas/federal/bankruptcy-western-district/adversary-complaint` | docx | PASS |
| `eighth-circuit/arkansas/federal/bankruptcy-western-district/motion-brief` | docx | PASS |
| `eighth-circuit/arkansas/federal/eastern-district/complaint` | docx | PASS |
| `eighth-circuit/arkansas/federal/eastern-district/motion-brief` | docx | PASS |
| `eighth-circuit/arkansas/federal/western-district/complaint` | docx | PASS |
| `eighth-circuit/arkansas/federal/western-district/motion-brief` | docx | PASS |
| `eighth-circuit/iowa/federal/bankruptcy-northern-district/adversary-complaint` | docx | PASS |
| `eighth-circuit/iowa/federal/bankruptcy-northern-district/motion-brief` | docx | PASS |
| `eighth-circuit/iowa/federal/bankruptcy-southern-district/adversary-complaint` | docx | PASS |
| `eighth-circuit/iowa/federal/northern-district/complaint` | docx | PASS |
| `eighth-circuit/iowa/federal/bankruptcy-southern-district/motion-brief` | docx | REPORTED: XENG-003, p. 8 line 25 |

The reported motion-brief difference is footnote 2: typst keeps the final two note lines together (four lines on p. 7, two on p. 8), while LibreOffice ignores widow control in a note (five lines on p. 7, one on p. 8). Letting typst split the note freely leaves the note on p. 7 below its moved anchor paragraph, which is worse; no available setting makes the renderers agree. Its `eval.yaml` therefore keeps `params.cross_engine: report`, and its README records the exact exception. Do not count this folder as gated.

**Fifth Circuit Louisiana district adoption (fb-595.68.13, verified 2026-10-22).** These 12 folders have typst and DOCX templates and no LaTeX templates. Every DOCX uses declarative `reference.xml` and Lua filters, with its body face inherited through `{font}` from typst; no DOCX builder or render shell scripts or binary `reference.docx` remain, and the assigned-folder entries in `.shell-safety-baseline.json` are zero. The typst and DOCX checks were rerun for every folder: all tier-1 checks passed with zero failures, including `DEF-COVER-001` and `DEF-TOC-001`; 11 folders pass XENG-001..003 on every input and set `params.cross_engine: gate`.

| Folder | Engine | XENG-001..003 |
|---|---|---|
| `fifth-circuit/louisiana/federal/bankruptcy-eastern-district/adversary-complaint` | docx | PASS |
| `fifth-circuit/louisiana/federal/bankruptcy-eastern-district/motion-brief` | docx | PASS |
| `fifth-circuit/louisiana/federal/bankruptcy-middle-district/adversary-complaint` | docx | PASS |
| `fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief` | docx | PASS |
| `fifth-circuit/louisiana/federal/bankruptcy-western-district/adversary-complaint` | docx | PASS |
| `fifth-circuit/louisiana/federal/bankruptcy-western-district/motion-brief` | docx | REPORTED: XENG-003, p. 4 lines 26–27 |
| `fifth-circuit/louisiana/federal/eastern-district/complaint` | docx | PASS |
| `fifth-circuit/louisiana/federal/eastern-district/motion-brief` | docx | PASS |
| `fifth-circuit/louisiana/federal/middle-district/complaint` | docx | PASS |
| `fifth-circuit/louisiana/federal/middle-district/motion-brief` | docx | PASS |
| `fifth-circuit/louisiana/federal/western-district/complaint` | docx | PASS |
| `fifth-circuit/louisiana/federal/western-district/motion-brief` | docx | PASS |

The western-district motion-brief exception is footnote 7: typst places the note at the foot of p. 4 while LibreOffice keeps it with its mark on p. 5. XENG-001 and XENG-002 pass; XENG-003 matches 179/181 lines, with the two differences at p. 4 lines 26–27. The `eval.yaml` records why the engines cannot agree and leaves this folder at `report`; do not count it as gated. The remaining exception is tracked separately by fb-595.54.11.

**Tolerance, from measurement.** On break words: none. On positions, measured on ca9 once every break agreed (both samples, 880 lines per engine pair, `fb diff --engines` diagnostics): the width of a line both engines break alike differs by at most 0.10 pt (latex) and 0.37 pt (docx); outside the cover every line's left edge and baseline is within 0.5 pt of typst's (cover: the gaps between its parts differ, up to 34 pt; its lines break alike). The documented tolerance is therefore **glyph-advance drift below 0.5 pt per line, and no other**: a template whose identical lines drift more, or whose breaks differ at all, has a layout difference to fix. The 0.5 pt is reported (`width`, `left edge`, `baseline` diagnostics of `fb diff --engines`), not gated: the gate is the breaks.

**What the measurement found** (before the fix; ca9 typst vs latex 59.8 % / 57.2 % of lines alike, docx 78.7 % / 64.9 %, two of four page counts different; repo-wide 0 of 548 engine pairs passing, latex mean 52 %, docx mean 27 %):

1. *Font size units.* newtx is Times metrics in TeX points: `\fontsize{14}` is 13.95 bp, every word 0.37 % narrower than typst's 14 pt. In bp (`14bp`) TeX Gyre Termes X and Times New Roman advances agree to 0.02/1000 em (regular, italic, bold).
2. *Kerning and ligatures.* typst kerned Times New Roman and set its ligatures, Word sets neither, newtx kerns about 2,300 pairs and forms fi/ffi: up to 1.75 pt per word. Fix: no kerning or ligatures anywhere (typst `kerning: false, ligatures: false`; pdfTeX `\pdfnoligatures\font`, which also drops the kern program; Word's default).
3. *The line breaker.* LibreOffice and Word break ragged text first-fit; typst too for ragged text (`linebreaks: "simple"` makes it explicit); TeX's Knuth-Plass optimum breaks earlier or later and shrinks interword spaces. Identical breaks are infeasible with stock TeX parameters (`\tolerance`, `\emergencystretch`, `\looseness` and `\linepenalty` change the optimum, not the algorithm), but TeX's optimum *is* first fit when every line is equally good: a fil right skip (badness 0 on every line), interword spaces that neither stretch nor shrink (`\fontdimen3`, `\fontdimen4`, `\fontdimen7` 0), every break penalty and hyphen demerit 0; of the breakings with the fewest lines TeX then keeps the one whose lines end latest, which is first fit.
4. *Break opportunities.* typst and LibreOffice break where Unicode line breaking (UAX #14) allows, TeX at spaces and after hyphens. Aligned: no break at a hyphen before a digit ("ER-178-82": typst and Word never, LaTeX `\mbox{-}`, Word `w:noBreakHyphen`), breaks before and after an em dash and after an en dash (LaTeX `\allowbreak`), and pandoc's smart reader's no-break space after an abbreviation ("v. Jones", "ed. 2020") back to a space (typst's markdown reader inserts none).
5. *Vertical model.* Each engine spaced lines its own way (typst leading between ascender boxes, LaTeX `\baselineskip`, Word exact spacing at 31.45 pt). The common model is Word's exact line spacing: every line a box of its pitch with the baseline at 0.8 of it, boxes touching, the space between blocks the larger of below/above (LibreOffice collapses them the same way), dropped at the top of a page after a soft break (Word keeps it after a hard break, so a block that opens a section carries none), no widows or orphans. typst: `top-edge: 0.8 * pitch, bottom-edge: -0.2 * pitch`, leading 0 (an explicit block spacing wins over a paragraph's default one; two explicit ones collapse to the larger); LaTeX: `\pdfeachlineheight`/`\pdfeachlinedepth`, `\baselineskip` 0, `\lineskip` 0, `\lineskiplimit` `\maxdimen`, `\topskip` 0, `\maxdepth` 0, `\addvspace` for every space, `\clubpenalty`/`\widowpenalty` 10000 (and the same inside footnotes, where `\@parboxrestore` resets them).
6. *Design differences.* Contents and authorities set three ways (typst: leader to the margin with the page inline; LaTeX: a 36/56 bp page column; Word: a right indent with a tab beyond it). The common design is Word's: the text wraps before a page column (36 pt contents; 56 pt authorities, or the page list's own width when longer), the leader starts at least three spaces after the text and runs to the number; the same pitches and spacings, list numbers in a half-inch box, a ruled box around a literal X for the form check boxes, footnote marks at 58 %.

**Reference breaker each engine follows** (shown on ca9: both samples, typst↔latex and typst↔docx, 100 % of lines and every page alike; `fb check --engine latex|docx` gates it, and the selftest mutant `latex-kerning` turns kerning back on and must fail `XENG-003`): first fit on Unicode break opportunities, no hyphenation, no kerning or ligatures, rigid spaces, Word's exact-line-spacing boxes. The model is shared code since fb-595.54.1 (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; the checklist at the end of this section); ca9 (`courts/ninth-circuit/court-of-appeals`: `typst/ca9-brief.typ`, `latex/template.tex`, `latex/ca9.lua`, `docx/ca9.lua`, `docx/make-reference.sh`) is the worked example.

**Baseline** (`fb cross-engine --write` writes `data/cross-engine-baseline.json`; committed renders, a `.docx` without its committed PDF converted with LibreOffice into `out/cross-engine/`). Current measurement: 933 engine pairs in 677 folders; 698 pairs pass. The 19 measured engine pairs for fb-595.54.5 show 18/19 at 100% with equal page counts; the remaining pair is the second sample of `tenth-circuit/court-of-appeals/reply-brief` (docx 99.2%, because LibreOffice moves the whole footnote; that folder stays `report`). Every other adopted pair passes XENG-001..003 and gates. Earlier measurements: on master 97737ac6 (2026-10-21), LibreOffice conversion with vendored fonts in view (fb-595.52) moved docx from a mean 27.7% to 34.2% of lines alike and from 139 to 222 of 502 page counts equal; latex was 58.1%, with 16 of 41 page counts equal. For fb-595.54.1, besides the ca7 opening brief (latex 40.0% to 100%, docx 42.3% to 100%), five rows moved with renders committed on master since that measurement. For fb-595.54.6, the federal-circuit rows went from 0/17 measured pairs passing (latex mean 67.9%, docx 43.0%, 3/17 page counts equal) to 18/18; besides them, 25 rows moved with renders committed on master since, including `eleventh-circuit/court-of-appeals/reply-brief`, `first-circuit/bankruptcy-appellate-panel/reply-brief`, `first-circuit/puerto-rico/federal/district/motion-brief`, `eleventh-circuit/georgia/state/court-of-appeals/motion-brief` docx, and all three `fourth-circuit/court-of-appeals` briefs. The detailed table is generated from the current measurement; `data/cross-engine-baseline.json` is the source of truth.


<details><summary>Full baseline table (933 rows)</summary>

| folder | id | engine | mode | pages equal | % lines same break | first differing page/line |
|---|---|---|---|---|---|---|
| courts/dc-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (14) | 100.0 | - |
| courts/dc-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (14) | 100.0 | - |
| courts/dc-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (15) | 100.0 | - |
| courts/dc-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (15) | 100.0 | - |
| courts/dc-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (16) | 100.0 | - |
| courts/dc-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (16) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (13) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/federal/district/complaint | complaint | docx | gate | yes (13) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/federal/district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/amicus-brief | amicus-brief | latex | report | yes (29) | 96.6 | p5 line 24 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (29) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/answering-brief | answering-brief | latex | report | yes (51) | 97.8 | p6 line 3 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/answering-brief | answering-brief | docx | report | yes (51) | 97.8 | p6 line 3 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/brief-on-the-merits | brief-on-the-merits | latex | gate | yes (26) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/brief-on-the-merits | brief-on-the-merits | docx | gate | yes (26) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/motion-brief | motion-brief | latex | report | yes (10) | 95.1 | p3 line 5 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (10) | 98.7 | p3 line 5 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/petition-for-rehearing | petition-for-rehearing | latex | report | yes (27) | 99.6 | p22 line 17 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/petition-for-rehearing | petition-for-rehearing | docx | report | yes (27) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/petition-for-review | petition-for-review | latex | gate | yes (3) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/petition-for-review | petition-for-review | docx | gate | yes (3) | 100.0 | - |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/reply-brief | reply-brief | latex | report | yes (27) | 96.1 | p3 line 10 |
| courts/dc-circuit/district-of-columbia/state/court-of-appeals/reply-brief | reply-brief | docx | report | yes (27) | 96.1 | p3 line 10 |
| courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/western-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/arkansas/federal/western-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/amicus-brief | amicus-brief | latex | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/amicus-brief | amicus-brief | docx | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/motion-brief | motion-brief | latex | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/petition-for-writ | petition-for-writ | latex | gate | yes (4) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | gate | yes (4) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/arkansas/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief | docx | report | no (20 vs 22) | 68.8 | p1 line 2 |
| courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief | opening-brief | docx | gate | yes (20) | 100.0 | - |
| courts/eighth-circuit/bankruptcy-appellate-panel/reply-brief | reply-brief | docx | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (14) | 100.0 | - |
| courts/eighth-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (14) | 100.0 | - |
| courts/eighth-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (15) | 100.0 | - |
| courts/eighth-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (15) | 100.0 | - |
| courts/eighth-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (18) | 100.0 | - |
| courts/eighth-circuit/court-of-appeals/reply-brief | reply-brief | docx | report | yes (18) | 99.3 | p9 line 14 |
| courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (5) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (3) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/motion-brief | motion-brief-2 | docx | gate | yes (6) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | report | yes (12) | 99.7 | p8 line 25 |
| courts/eighth-circuit/iowa/federal/northern-district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/southern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/iowa/federal/southern-district/motion-brief | motion-brief | docx | report | yes (8) | 83.4 | p1 line 6 |
| courts/eighth-circuit/iowa/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (27) | 98.4 | p5 line 20 |
| courts/eighth-circuit/iowa/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (27) | 99.1 | p4 line 12 |
| courts/eighth-circuit/iowa/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | yes (46) | 99.5 | p29 line 21 |
| courts/eighth-circuit/iowa/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (46) | 99.5 | p29 line 21 |
| courts/eighth-circuit/iowa/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/iowa/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/iowa/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | report | yes (23) | 100.0 | - |
| courts/eighth-circuit/iowa/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | yes (23) | 98.7 | p12 line 3 |
| courts/eighth-circuit/iowa/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (18) | 99.7 | p17 line 18 |
| courts/eighth-circuit/iowa/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | no (18 vs 19) | 98.4 | p2 line 17 |
| courts/eighth-circuit/iowa/state/supreme-court/reply-brief | reply-brief | latex | gate | yes (19) | 100.0 | - |
| courts/eighth-circuit/iowa/state/supreme-court/reply-brief | reply-brief | docx | gate | yes (19) | 100.0 | - |
| courts/eighth-circuit/minnesota/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (13) | 100.0 | - |
| courts/eighth-circuit/minnesota/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/eighth-circuit/minnesota/federal/district/complaint | complaint | docx | gate | yes (14) | 100.0 | - |
| courts/eighth-circuit/minnesota/federal/district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/eighth-circuit/minnesota/state/court-of-appeals/motion-brief | motion-brief | latex | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/minnesota/state/court-of-appeals/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/minnesota/state/court-of-appeals/petition-for-review | petition-for-review | latex | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/minnesota/state/court-of-appeals/petition-for-review | petition-for-review | docx | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/minnesota/state/court-of-appeals/petition-for-writ | petition-for-writ | latex | report | yes (13) | 99.3 | p3 line 24 |
| courts/eighth-circuit/minnesota/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | report | yes (13) | 99.3 | p3 line 24 |
| courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief | motion-brief-2 | docx | gate | yes (6) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (4) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/eastern-district/complaint | complaint | docx | gate | yes (13) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/western-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/missouri/federal/western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eighth-circuit/missouri/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (19) | 100.0 | - |
| courts/eighth-circuit/missouri/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (19) | 100.0 | - |
| courts/eighth-circuit/missouri/state/court-of-appeals-southern-district/answering-brief | answering-brief | latex | report | yes (20) | 99.6 | p18 line 9 |
| courts/eighth-circuit/missouri/state/court-of-appeals-southern-district/answering-brief | answering-brief | docx | report | yes (20) | 99.6 | p3 line 19 |
| courts/eighth-circuit/missouri/state/court-of-appeals-southern-district/opening-brief | opening-brief | latex | report | yes (31) | 99.6 | p26 line 32 |
| courts/eighth-circuit/missouri/state/court-of-appeals-southern-district/opening-brief | opening-brief | docx | report | yes (31) | 99.8 | p20 line 28 |
| courts/eighth-circuit/missouri/state/court-of-appeals-southern-district/reply-brief | reply-brief | latex | gate | yes (15) | 100.0 | - |
| courts/eighth-circuit/missouri/state/court-of-appeals-southern-district/reply-brief | reply-brief | docx | gate | yes (15) | 100.0 | - |
| courts/eighth-circuit/missouri/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | yes (38) | 93.7 | p2 line 8 |
| courts/eighth-circuit/missouri/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (38) | 99.1 | p10 line 3 |
| courts/eighth-circuit/missouri/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (3) | 100.0 | - |
| courts/eighth-circuit/missouri/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (3) | 100.0 | - |
| courts/eighth-circuit/missouri/state/supreme-court/petition-for-writ | petition-for-writ | latex | report | yes (19) | 97.3 | p6 line 1 |
| courts/eighth-circuit/missouri/state/supreme-court/petition-for-writ | petition-for-writ | docx | report | yes (19) | 98.6 | p6 line 1 |
| courts/eighth-circuit/missouri/state/supreme-court/reply-brief | reply-brief | latex | report | yes (28) | 97.7 | p4 line 5 |
| courts/eighth-circuit/missouri/state/supreme-court/reply-brief | reply-brief | docx | report | yes (28) | 99.9 | p4 line 5 |
| courts/eighth-circuit/nebraska/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/nebraska/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/eighth-circuit/nebraska/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/nebraska/federal/district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/eighth-circuit/north-dakota/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/eighth-circuit/north-dakota/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/north-dakota/federal/district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/north-dakota/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (8) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (11) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (7) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (7) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/supreme-court/answering-brief | answering-brief | latex | report | yes (20) | 98.1 | p3 line 30 |
| courts/eighth-circuit/north-dakota/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | yes (33) | 98.1 | p16 line 13 |
| courts/eighth-circuit/north-dakota/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (33) | 98.1 | p16 line 13 |
| courts/eighth-circuit/north-dakota/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (4) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (4) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (10) | 99.1 | p7 line 12 |
| courts/eighth-circuit/north-dakota/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | yes (10) | 99.1 | p7 line 12 |
| courts/eighth-circuit/north-dakota/state/supreme-court/petition-for-writ | petition-for-writ | latex | gate | yes (35) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/supreme-court/petition-for-writ | petition-for-writ | docx | gate | yes (35) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/supreme-court/reply-brief | reply-brief | latex | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/north-dakota/state/supreme-court/reply-brief | reply-brief | docx | gate | yes (12) | 100.0 | - |
| courts/eighth-circuit/south-dakota/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (3) | 100.0 | - |
| courts/eighth-circuit/south-dakota/federal/bankruptcy-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (3) | 100.0 | - |
| courts/eighth-circuit/south-dakota/federal/bankruptcy-district/motion-brief | motion-brief | docx | report | yes (10) | 99.7 | p1 line 20 |
| courts/eighth-circuit/south-dakota/federal/district/complaint | complaint | docx | gate | yes (3) | 100.0 | - |
| courts/eighth-circuit/south-dakota/federal/district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-middle-district/motion-brief | motion-brief-2 | docx | gate | yes (5) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (5) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/middle-district/complaint | complaint | docx | gate | yes (14) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/middle-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/northern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/southern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/eleventh-circuit/alabama/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/eleventh-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (15) | 100.0 | - |
| courts/eleventh-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (15) | 100.0 | - |
| courts/eleventh-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (16) | 100.0 | - |
| courts/eleventh-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (16) | 100.0 | - |
| courts/eleventh-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (15) | 100.0 | - |
| courts/eleventh-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (15) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (12) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (18) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (5) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/middle-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/middle-district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/northern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/southern-district/complaint | complaint | docx | gate | yes (7) | 100.0 | - |
| courts/eleventh-circuit/florida/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (15) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/middle-district/complaint | complaint | docx | report | yes (10) | 49.3 | p1 line 4 |
| courts/eleventh-circuit/georgia/federal/middle-district/motion-brief | motion-brief | docx | report | yes (9) | 32.7 | p1 line 4 |
| courts/eleventh-circuit/georgia/federal/northern-district/complaint | complaint | docx | gate | yes (13) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/southern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/amicus-brief | amicus-brief | latex | report | yes (31) | 99.2 | p21 line 5 |
| courts/eleventh-circuit/georgia/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (31) | 99.2 | p21 line 5 |
| courts/eleventh-circuit/georgia/state/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/motion-brief | motion-brief | docx | gate | yes (18) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (17) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/petition-for-rehearing | petition-for-rehearing | docx | gate | yes (12) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/supreme-court/answering-brief | answering-brief | docx | gate | yes (13) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (9) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/supreme-court/opening-brief | opening-brief | docx | report | yes (15) | 99.4 | p10 line 1 |
| courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (12) | 100.0 | - |
| courts/eleventh-circuit/georgia/state/supreme-court/reply-brief | reply-brief | docx | gate | yes (14) | 100.0 | - |
| courts/federal-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (15) | 100.0 | - |
| courts/federal-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (15) | 100.0 | - |
| courts/federal-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (22) | 100.0 | - |
| courts/federal-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (22) | 100.0 | - |
| courts/federal-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (13) | 100.0 | - |
| courts/federal-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (13) | 100.0 | - |
| courts/federal-circuit/court-of-federal-claims/complaint | complaint | docx | gate | yes (14) | 100.0 | - |
| courts/federal-circuit/court-of-federal-claims/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/federal-circuit/court-of-international-trade/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/federal-circuit/court-of-international-trade/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/federal-circuit/court-of-veteran-appeals/answering-brief | answering-brief | docx | gate | yes (12) | 100.0 | - |
| courts/federal-circuit/court-of-veteran-appeals/opening-brief | opening-brief | docx | gate | yes (14) | 100.0 | - |
| courts/federal-circuit/court-of-veteran-appeals/opening-brief | opening-brief-2 | docx | gate | yes (12) | 100.0 | - |
| courts/federal-circuit/patent-trial-and-appeal-board/patent-owner-response | patent-owner-response | docx | gate | yes (13) | 100.0 | - |
| courts/federal-circuit/patent-trial-and-appeal-board/petition | petition | docx | gate | yes (15) | 100.0 | - |
| courts/federal-circuit/trademark-trial-and-appeal-board/answer | answer-3 | docx | gate | yes (4) | 100.0 | - |
| courts/federal-circuit/trademark-trial-and-appeal-board/notice-of-opposition | notice-of-opposition | docx | gate | yes (9) | 100.0 | - |
| courts/federal-circuit/trademark-trial-and-appeal-board/trial-brief | trial-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (15) | 100.0 | - |
| courts/fifth-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (15) | 100.0 | - |
| courts/fifth-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (15) | 100.0 | - |
| courts/fifth-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (15) | 100.0 | - |
| courts/fifth-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (5) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (18) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | report | yes (7) | 98.9 | p4 line 26 |
| courts/fifth-circuit/louisiana/federal/eastern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/middle-district/complaint | complaint | docx | gate | yes (5) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/middle-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/western-district/complaint | complaint | docx | gate | yes (6) | 100.0 | - |
| courts/fifth-circuit/louisiana/federal/western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/motion-brief | motion-brief-2 | docx | gate | yes (3) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (19) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/northern-district/complaint | complaint | docx | gate | yes (13) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/southern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/mississippi/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/fifth-circuit/mississippi/state/supreme-court/motion-brief | motion-brief | latex | report | yes (8) | 100.0 | - |
| courts/fifth-circuit/mississippi/state/supreme-court/motion-brief | motion-brief | docx | report | yes (8) | 98.9 | p5 line 28 |
| courts/fifth-circuit/texas/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (16) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (13) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (13) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/texas/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/texas/federal/eastern-district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/fifth-circuit/texas/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/fifth-circuit/texas/federal/eastern-district/motion-brief | motion-brief-2 | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/texas/federal/northern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/texas/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/fifth-circuit/texas/federal/southern-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fifth-circuit/texas/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/texas/federal/western-district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/fifth-circuit/texas/federal/western-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/fifth-circuit/texas/state/court-of-civil-appeals/answering-brief | answering-brief | docx | gate | yes (18) | 100.0 | - |
| courts/fifth-circuit/texas/state/court-of-civil-appeals/opening-brief | opening-brief | docx | gate | yes (17) | 100.0 | - |
| courts/fifth-circuit/texas/state/court-of-civil-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fifth-circuit/texas/state/court-of-criminal-appeals/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/fifth-circuit/texas/state/court-of-criminal-appeals/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | no (12 vs 13) | 87.6 | p2 line 1 |
| courts/fifth-circuit/texas/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | gate | yes (18) | 100.0 | - |
| courts/fifth-circuit/texas/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (17) | 100.0 | - |
| courts/first-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief | docx | gate | yes (20) | 100.0 | - |
| courts/first-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief-2 | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/bankruptcy-appellate-panel/opening-brief | opening-brief | docx | gate | yes (23) | 100.0 | - |
| courts/first-circuit/bankruptcy-appellate-panel/opening-brief | opening-brief-2 | docx | gate | yes (13) | 100.0 | - |
| courts/first-circuit/bankruptcy-appellate-panel/reply-brief | reply-brief | docx | gate | yes (12) | 100.0 | - |
| courts/first-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (11) | 100.0 | - |
| courts/first-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (11) | 100.0 | - |
| courts/first-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (14) | 100.0 | - |
| courts/first-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (14) | 100.0 | - |
| courts/first-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (10) | 100.0 | - |
| courts/first-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/first-circuit/maine/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/first-circuit/maine/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/first-circuit/maine/federal/district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/maine/federal/district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/first-circuit/maine/state/supreme-judicial-court/amicus-brief | amicus-brief | latex | report | yes (42) | 94.7 | p3 line 15 |
| courts/first-circuit/maine/state/supreme-judicial-court/amicus-brief | amicus-brief | docx | report | no (42 vs 43) | 90.1 | p2 line 7 |
| courts/first-circuit/maine/state/supreme-judicial-court/answering-brief | answering-brief | latex | report | yes (48) | 96.6 | p3 line 3 |
| courts/first-circuit/maine/state/supreme-judicial-court/answering-brief | answering-brief | docx | report | yes (48) | 97.6 | p2 line 22 |
| courts/first-circuit/maine/state/supreme-judicial-court/brief-on-the-merits | brief-on-the-merits | latex | report | yes (87) | 98.0 | p4 line 7 |
| courts/first-circuit/maine/state/supreme-judicial-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (87) | 95.9 | p2 line 20 |
| courts/first-circuit/maine/state/supreme-judicial-court/motion-brief | motion-brief | latex | report | yes (22) | 95.1 | p2 line 14 |
| courts/first-circuit/maine/state/supreme-judicial-court/motion-brief | motion-brief | docx | report | yes (22) | 96.8 | p12 line 1 |
| courts/first-circuit/maine/state/supreme-judicial-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (19) | 98.3 | p12 line 20 |
| courts/first-circuit/maine/state/supreme-judicial-court/petition-for-rehearing | petition-for-rehearing | docx | report | yes (19) | 98.5 | p12 line 20 |
| courts/first-circuit/maine/state/supreme-judicial-court/petition-for-review | petition-for-review | latex | report | yes (12) | 99.1 | p3 line 18 |
| courts/first-circuit/maine/state/supreme-judicial-court/petition-for-review | petition-for-review | docx | report | yes (12) | 100.0 | - |
| courts/first-circuit/maine/state/supreme-judicial-court/petition-for-writ | petition-for-writ | latex | gate | yes (12) | 100.0 | - |
| courts/first-circuit/maine/state/supreme-judicial-court/petition-for-writ | petition-for-writ | docx | gate | yes (12) | 100.0 | - |
| courts/first-circuit/maine/state/supreme-judicial-court/reply-brief | reply-brief | latex | report | yes (41) | 99.6 | p34 line 1 |
| courts/first-circuit/maine/state/supreme-judicial-court/reply-brief | reply-brief | docx | report | yes (41) | 99.6 | p34 line 1 |
| courts/first-circuit/massachusetts/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (5) | 100.0 | - |
| courts/first-circuit/massachusetts/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/first-circuit/massachusetts/federal/district/complaint | complaint | docx | gate | yes (15) | 100.0 | - |
| courts/first-circuit/massachusetts/federal/district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/first-circuit/new-hampshire/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/new-hampshire/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/first-circuit/new-hampshire/federal/district/complaint | complaint | docx | gate | yes (14) | 100.0 | - |
| courts/first-circuit/new-hampshire/federal/district/motion-brief | motion-brief | docx | gate | yes (18) | 100.0 | - |
| courts/first-circuit/new-hampshire/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (6) | 100.0 | - |
| courts/first-circuit/new-hampshire/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (6) | 100.0 | - |
| courts/first-circuit/new-hampshire/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (11) | 90.1 | p6 line 24 |
| courts/first-circuit/new-hampshire/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | no (11 vs 10) | 96.4 | p6 line 24 |
| courts/first-circuit/new-hampshire/state/supreme-court/petition-for-review | petition-for-review | latex | report | yes (24) | 99.7 | p18 line 9 |
| courts/first-circuit/new-hampshire/state/supreme-court/petition-for-review | petition-for-review | docx | report | yes (24) | 100.0 | - |
| courts/first-circuit/new-hampshire/state/supreme-court/petition-for-writ | petition-for-writ | latex | report | yes (20) | 96.2 | p5 line 1 |
| courts/first-circuit/new-hampshire/state/supreme-court/petition-for-writ | petition-for-writ | docx | report | yes (20) | 100.0 | - |
| courts/first-circuit/puerto-rico/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/first-circuit/puerto-rico/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/puerto-rico/federal/bankruptcy-district/motion-brief | motion-brief-2 | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/puerto-rico/federal/district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/puerto-rico/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/first-circuit/puerto-rico/state/court-of-appeals/amicus-brief | amicus-brief | latex | gate | yes (13) | 100.0 | - |
| courts/first-circuit/puerto-rico/state/court-of-appeals/amicus-brief | amicus-brief | docx | gate | yes (13) | 100.0 | - |
| courts/first-circuit/rhode-island/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/first-circuit/rhode-island/federal/bankruptcy-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (8) | 100.0 | - |
| courts/first-circuit/rhode-island/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/first-circuit/rhode-island/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/first-circuit/rhode-island/federal/district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/fourth-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (14) | 100.0 | - |
| courts/fourth-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (14) | 100.0 | - |
| courts/fourth-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (13) | 100.0 | - |
| courts/fourth-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/fourth-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/maryland/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (14) | 100.0 | - |
| courts/fourth-circuit/maryland/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/fourth-circuit/maryland/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/fourth-circuit/maryland/federal/district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/fourth-circuit/maryland/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (35) | 98.1 | p5 line 4 |
| courts/fourth-circuit/maryland/state/court-of-appeals/answering-brief | answering-brief | docx | report | yes (50) | 86.1 | p13 line 11 |
| courts/fourth-circuit/maryland/state/court-of-appeals/motion-brief | motion-brief | latex | report | yes (20) | 96.4 | p9 line 3 |
| courts/fourth-circuit/maryland/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (20) | 96.4 | p9 line 3 |
| courts/fourth-circuit/maryland/state/court-of-appeals/petition-for-discretionary-review | petition-for-discretionary-review | latex | report | yes (22) | 97.4 | p19 line 11 |
| courts/fourth-circuit/maryland/state/court-of-appeals/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | yes (22) | 97.4 | p19 line 11 |
| courts/fourth-circuit/maryland/state/court-of-appeals/petition-for-rehearing | petition-for-rehearing | latex | gate | yes (6) | 100.0 | - |
| courts/fourth-circuit/maryland/state/court-of-appeals/petition-for-rehearing | petition-for-rehearing | docx | gate | yes (6) | 100.0 | - |
| courts/fourth-circuit/maryland/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | report | no (63 vs 64) | 86.2 | p2 line 27 |
| courts/fourth-circuit/maryland/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (17) | 100.0 | - |
| courts/fourth-circuit/maryland/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (17) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/middle-district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/middle-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/western-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/north-carolina/federal/western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/amicus-brief | amicus-brief | latex | report | yes (19) | 98.0 | p9 line 20 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (19) | 98.6 | p14 line 17 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/answering-brief | answering-brief | latex | report | yes (63) | 96.7 | p2 line 30 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/answering-brief | answering-brief | docx | report | yes (63) | 93.0 | p2 line 3 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/motion-brief | motion-brief | latex | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/opening-brief | opening-brief | latex | report | yes (26) | 99.5 | p15 line 1 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/opening-brief | opening-brief | docx | report | yes (26) | 91.5 | p2 line 3 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/petition-for-review | petition-for-review | latex | report | yes (26) | 99.2 | p5 line 4 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/petition-for-review | petition-for-review | docx | report | yes (26) | 99.7 | p5 line 4 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/petition-for-writ | petition-for-writ | latex | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/reply-brief | reply-brief | latex | report | yes (11) | 99.2 | p4 line 22 |
| courts/fourth-circuit/north-carolina/state/court-of-appeals/reply-brief | reply-brief | docx | report | yes (11) | 99.2 | p4 line 22 |
| courts/fourth-circuit/north-carolina/state/superior-court/amicus-brief | amicus-brief | docx | report | yes (38) | 94.2 | p2 line 3 |
| courts/fourth-circuit/north-carolina/state/superior-court/answering-brief | answering-brief | latex | report | yes (17) | 93.3 | p5 line 18 |
| courts/fourth-circuit/north-carolina/state/superior-court/answering-brief | answering-brief | docx | report | yes (17) | 94.9 | p5 line 18 |
| courts/fourth-circuit/north-carolina/state/superior-court/motion-brief | motion-brief | latex | report | yes (48) | 97.5 | p2 line 8 |
| courts/fourth-circuit/north-carolina/state/superior-court/motion-brief | motion-brief | docx | report | yes (48) | 97.7 | p2 line 8 |
| courts/fourth-circuit/north-carolina/state/superior-court/opening-brief | opening-brief | docx | report | no (33 vs 34) | 91.6 | p2 line 19 |
| courts/fourth-circuit/north-carolina/state/superior-court/petition-for-review | petition-for-review | latex | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/superior-court/petition-for-review | petition-for-review | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/superior-court/petition-for-writ | petition-for-writ | latex | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/superior-court/petition-for-writ | petition-for-writ | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/north-carolina/state/superior-court/reply-brief | reply-brief | latex | report | yes (43) | 96.8 | p1 line 23 |
| courts/fourth-circuit/north-carolina/state/superior-court/reply-brief | reply-brief | docx | report | yes (43) | 94.4 | p1 line 23 |
| courts/fourth-circuit/south-carolina/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/south-carolina/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/south-carolina/federal/district/complaint | complaint | docx | report | no (8 vs 9) | 93.8 | p1 line 27 |
| courts/fourth-circuit/south-carolina/federal/district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/fourth-circuit/south-carolina/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (17) | 99.5 | p13 line 23 |
| courts/fourth-circuit/south-carolina/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (17) | 98.5 | p4 line 22 |
| courts/fourth-circuit/south-carolina/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (2) | 100.0 | - |
| courts/fourth-circuit/south-carolina/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (2) | 100.0 | - |
| courts/fourth-circuit/south-carolina/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | gate | yes (27) | 100.0 | - |
| courts/fourth-circuit/south-carolina/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | gate | yes (27) | 100.0 | - |
| courts/fourth-circuit/south-carolina/state/supreme-court/petition-for-writ | petition-for-writ | latex | gate | yes (22) | 100.0 | - |
| courts/fourth-circuit/south-carolina/state/supreme-court/petition-for-writ | petition-for-writ | docx | gate | yes (22) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/eastern-district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/western-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/western-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/virginia/federal/western-district/motion-brief | motion-brief-2 | docx | gate | yes (12) | 100.0 | - |
| courts/fourth-circuit/virginia/state/supreme-court/answering-brief | answering-brief | latex | report | yes (52) | 99.5 | p18 line 2 |
| courts/fourth-circuit/virginia/state/supreme-court/answering-brief | answering-brief | docx | report | yes (52) | 97.3 | p3 line 4 |
| courts/fourth-circuit/virginia/state/supreme-court/motion-brief | motion-brief | latex | report | yes (24) | 98.9 | p2 line 15 |
| courts/fourth-circuit/virginia/state/supreme-court/motion-brief | motion-brief | docx | report | yes (24) | 99.6 | p4 line 4 |
| courts/fourth-circuit/virginia/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | report | yes (35) | 98.2 | p3 line 6 |
| courts/fourth-circuit/virginia/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | yes (35) | 97.9 | p4 line 20 |
| courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (5) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (4) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district/motion-brief | motion-brief-2 | docx | gate | yes (12) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (13) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/northern-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/southern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/fourth-circuit/west-virginia/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/fourth-circuit/west-virginia/state/supreme-court/amicus-brief | amicus-brief | latex | report | no (30 vs 31) | 81.9 | p2 line 15 |
| courts/fourth-circuit/west-virginia/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (30) | 92.3 | p3 line 3 |
| courts/fourth-circuit/west-virginia/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (6) | 100.0 | - |
| courts/fourth-circuit/west-virginia/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (6) | 100.0 | - |
| courts/fourth-circuit/west-virginia/state/supreme-court/reply-brief | reply-brief | latex | report | yes (28) | 100.0 | - |
| courts/fourth-circuit/west-virginia/state/supreme-court/reply-brief | reply-brief | docx | report | no (28 vs 27) | 85.2 | p2 line 6 |
| courts/military/air-force-court-of-criminal-appeals/answering-brief | answering-brief | docx | gate | yes (10) | 100.0 | - |
| courts/military/air-force-court-of-criminal-appeals/answering-brief | answering-brief-2 | docx | gate | yes (3) | 100.0 | - |
| courts/military/air-force-court-of-criminal-appeals/opening-brief | opening-brief | docx | gate | yes (12) | 100.0 | - |
| courts/military/air-force-court-of-criminal-appeals/opening-brief | opening-brief-2 | docx | gate | yes (7) | 100.0 | - |
| courts/military/army-court-of-criminal-appeals/answering-brief | answering-brief | docx | gate | yes (12) | 100.0 | - |
| courts/military/army-court-of-criminal-appeals/answering-brief | answering-brief-2 | docx | gate | yes (5) | 100.0 | - |
| courts/military/army-court-of-criminal-appeals/opening-brief | opening-brief | docx | gate | yes (11) | 100.0 | - |
| courts/military/army-court-of-criminal-appeals/opening-brief | opening-brief-2 | docx | gate | yes (6) | 100.0 | - |
| courts/military/coast-guard-court-of-criminal-appeals/answering-brief | answering-brief | docx | gate | yes (8) | 100.0 | - |
| courts/military/coast-guard-court-of-criminal-appeals/answering-brief | answering-brief-2 | docx | gate | yes (2) | 100.0 | - |
| courts/military/coast-guard-court-of-criminal-appeals/opening-brief | opening-brief | docx | gate | yes (9) | 100.0 | - |
| courts/military/coast-guard-court-of-criminal-appeals/opening-brief | opening-brief-2 | docx | gate | yes (3) | 100.0 | - |
| courts/military/court-of-appeals-for-the-armed-forces/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/military/court-of-appeals-for-the-armed-forces/petition-supplement | petition-supplement | docx | gate | yes (11) | 100.0 | - |
| courts/military/court-of-military-commission-review/answering-brief | answering-brief | docx | gate | yes (11) | 100.0 | - |
| courts/military/court-of-military-commission-review/opening-brief | opening-brief | docx | gate | yes (16) | 100.0 | - |
| courts/military/navy-marine-corps-court-of-criminal-appeals/answering-brief | answering-brief | docx | gate | yes (9) | 100.0 | - |
| courts/military/navy-marine-corps-court-of-criminal-appeals/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/national/board-of-immigration-appeals/brief-on-appeal | brief-on-appeal | docx | report | yes (13) | 69.4 | p1 line 1 |
| courts/national/foreign-intelligence-surveillance-court/motion-brief | motion-brief | docx | report | yes (4) | 97.8 | p1 line 4 |
| courts/national/foreign-intelligence-surveillance-court/motion-brief | motion-brief-2 | docx | report | yes (5) | 91.6 | p1 line 2 |
| courts/national/foreign-intelligence-surveillance-court-of-review/amicus-brief | amicus-brief | docx | report | no (12 vs 13) | 81.7 | p1 line 16 |
| courts/national/judicial-panel-on-multidistrict-litigation/motion-brief | motion-brief | docx | report | no (11 vs 12) | 79.0 | p1 line 7 |
| courts/national/tax-court/petition | petition | docx | report | yes (9) | 83.8 | p2 line 28 |
| courts/national/tax-court/petition | petition-2 | docx | report | yes (4) | 100.0 | - |
| courts/national/tax-court/pretrial-memorandum | pretrial-memorandum | docx | report | yes (8) | 81.8 | p1 line 27 |
| courts/national/tax-court/pretrial-memorandum | pretrial-memorandum-2 | docx | report | yes (3) | 87.0 | p1 line 28 |
| courts/ninth-circuit/alaska/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/ninth-circuit/alaska/federal/district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/alaska/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/alaska/state/court-of-appeals/amicus-brief | amicus-brief | latex | report | yes (19) | 100.0 | - |
| courts/ninth-circuit/alaska/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (19) | 100.0 | - |
| courts/ninth-circuit/alaska/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (35) | 96.4 | p14 line 19 |
| courts/ninth-circuit/alaska/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (35) | 97.5 | p2 line 17 |
| courts/ninth-circuit/alaska/state/supreme-court/answering-brief | answering-brief | latex | report | yes (57) | 86.2 | p2 line 25 |
| courts/ninth-circuit/alaska/state/supreme-court/answering-brief | answering-brief | docx | report | yes (57) | 78.6 | p2 line 25 |
| courts/ninth-circuit/alaska/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | yes (47) | 88.9 | p2 line 23 |
| courts/ninth-circuit/alaska/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (47) | 96.7 | p2 line 14 |
| courts/ninth-circuit/alaska/state/supreme-court/motion-brief | motion-brief | latex | report | yes (38) | 85.4 | p6 line 1 |
| courts/ninth-circuit/alaska/state/supreme-court/reply-brief | reply-brief | latex | report | yes (21) | 89.4 | p9 line 9 |
| courts/ninth-circuit/arizona/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/ninth-circuit/arizona/federal/bankruptcy-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (5) | 100.0 | - |
| courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/arizona/federal/district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/arizona/federal/district/motion-brief | motion-brief | docx | gate | yes (20) | 100.0 | - |
| courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief-2 | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief-3 | docx | gate | yes (19) | 100.0 | - |
| courts/ninth-circuit/bankruptcy-appellate-panel/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief | reply-brief | docx | gate | yes (15) | 100.0 | - |
| courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief | reply-brief-2 | docx | gate | yes (6) | 100.0 | - |
| courts/ninth-circuit/california/federal/bankruptcy-central-district/adversary-complaint | adversary-complaint | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/california/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/california/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/california/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/california/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (5) | 100.0 | - |
| courts/ninth-circuit/california/federal/central-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/california/federal/central-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/california/federal/eastern-district/complaint | complaint | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/california/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/california/federal/northern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/california/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/california/federal/southern-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/california/federal/southern-district/motion-brief | motion-brief | docx | report | yes (9) | 9.6 | p1 line 2 |
| courts/ninth-circuit/california/state/court-of-appeal-fifth-district/motion-brief | motion-brief | latex | report | yes (3) | 86.4 | p1 line 9 |
| courts/ninth-circuit/california/state/court-of-appeal-fifth-district/motion-brief | motion-brief | docx | gate | yes (3) | 100.0 | - |
| courts/ninth-circuit/california/state/court-of-appeal-sixth-district/motion-brief | motion-brief | latex | report | yes (4) | 87.3 | p1 line 5 |
| courts/ninth-circuit/california/state/court-of-appeal-sixth-district/motion-brief | motion-brief | docx | report | yes (4) | 100.0 | - |
| courts/ninth-circuit/california/state/courts-of-appeal/answering-brief | answering-brief | docx | report | no (15 vs 17) | 78.0 | p2 line 5 |
| courts/ninth-circuit/california/state/courts-of-appeal/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/california/state/courts-of-appeal/reply-brief | reply-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/california/state/superior-court/complaint | complaint | docx | gate | yes (5) | 100.0 | - |
| courts/ninth-circuit/california/state/superior-court/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/california/state/superior-court/san-diego-county/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/california/state/superior-court/san-diego-county/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/ninth-circuit/california/state/superior-court/san-diego-county/motion-brief | motion-brief-2 | docx | gate | yes (2) | 100.0 | - |
| courts/ninth-circuit/california/state/supreme-court/opening-brief-on-the-merits | opening-brief-on-the-merits | docx | report | yes (15) | 91.3 | p1 line 3 |
| courts/ninth-circuit/california/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (15) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (15) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals | opening-brief | latex | gate | yes (24) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals | opening-brief | docx | gate | yes (24) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals | opening-brief-2 | latex | gate | yes (19) | 100.0 | - |
| courts/ninth-circuit/court-of-appeals | opening-brief-2 | docx | gate | yes (19) | 100.0 | - |
| courts/ninth-circuit/guam/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/ninth-circuit/guam/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/guam/federal/district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/guam/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/guam/state/supreme-court/answering-brief | answering-brief | latex | report | yes (36) | 99.7 | p30 line 5 |
| courts/ninth-circuit/guam/state/supreme-court/answering-brief | answering-brief | docx | report | yes (36) | 100.0 | - |
| courts/ninth-circuit/guam/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (24) | 100.0 | - |
| courts/ninth-circuit/guam/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | yes (24) | 94.0 | p6 line 1 |
| courts/ninth-circuit/hawaii/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/hawaii/federal/bankruptcy-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/hawaii/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/hawaii/federal/district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/hawaii/federal/district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/hawaii/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/hawaii/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/hawaii/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/ninth-circuit/hawaii/state/supreme-court/reply-brief | reply-brief | latex | report | yes (23) | 99.3 | p2 line 34 |
| courts/ninth-circuit/hawaii/state/supreme-court/reply-brief | reply-brief | docx | report | yes (23) | 99.2 | p10 line 1 |
| courts/ninth-circuit/idaho/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/idaho/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (6) | 100.0 | - |
| courts/ninth-circuit/idaho/federal/bankruptcy-district/motion-brief | motion-brief-2 | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/idaho/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/idaho/federal/district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | gate | yes (17) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | gate | yes (17) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/motion-brief | motion-brief | latex | report | yes (18) | 98.7 | p8 line 27 |
| courts/ninth-circuit/idaho/state/supreme-court/motion-brief | motion-brief | docx | report | no (18 vs 19) | 94.9 | p8 line 26 |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (9) | 97.2 | p6 line 1 |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | yes (9) | 99.5 | p6 line 1 |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-review | petition-for-review | latex | gate | yes (20) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (20) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-writ | petition-for-writ | latex | report | yes (20) | 98.8 | p15 line 17 |
| courts/ninth-circuit/idaho/state/supreme-court/petition-for-writ | petition-for-writ | docx | gate | yes (20) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/reply-brief | reply-brief | latex | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/idaho/state/supreme-court/reply-brief | reply-brief | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/montana/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/ninth-circuit/montana/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/ninth-circuit/montana/federal/district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/montana/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (34) | 99.6 | p15 line 15 |
| courts/ninth-circuit/montana/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (34) | 99.7 | p15 line 15 |
| courts/ninth-circuit/montana/state/supreme-court/answering-brief | answering-brief | latex | report | yes (86) | 89.5 | p2 line 16 |
| courts/ninth-circuit/montana/state/supreme-court/answering-brief | answering-brief | docx | report | yes (86) | 99.2 | p11 line 1 |
| courts/ninth-circuit/montana/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | yes (48) | 99.0 | p21 line 18 |
| courts/ninth-circuit/montana/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (48) | 99.6 | p21 line 18 |
| courts/ninth-circuit/montana/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (19) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (19) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | report | yes (24) | 96.3 | p3 line 18 |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | yes (24) | 94.6 | p1 line 3 |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-review | petition-for-review | latex | gate | yes (18) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (18) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-writ | petition-for-writ | latex | gate | yes (4) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/petition-for-writ | petition-for-writ | docx | gate | yes (4) | 100.0 | - |
| courts/ninth-circuit/montana/state/supreme-court/reply-brief | reply-brief | latex | report | yes (29) | 98.7 | p5 line 7 |
| courts/ninth-circuit/montana/state/supreme-court/reply-brief | reply-brief | docx | report | yes (29) | 98.5 | p16 line 18 |
| courts/ninth-circuit/nevada/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/nevada/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/ninth-circuit/nevada/federal/district/complaint | complaint | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/nevada/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/nevada/state/supreme-court/motion-brief | motion-brief | latex | report | yes (16) | 98.9 | p8 line 16 |
| courts/ninth-circuit/nevada/state/supreme-court/motion-brief | motion-brief | docx | report | yes (16) | 100.0 | - |
| courts/ninth-circuit/nevada/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | report | no (21 vs 20) | 89.7 | p2 line 10 |
| courts/ninth-circuit/nevada/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | no (21 vs 20) | 90.1 | p2 line 10 |
| courts/ninth-circuit/nevada/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | yes (20) | 99.5 | p4 line 1 |
| courts/ninth-circuit/nevada/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | yes (20) | 99.5 | p4 line 1 |
| courts/ninth-circuit/nevada/state/supreme-court/petition-for-review | petition-for-review | latex | gate | yes (21) | 100.0 | - |
| courts/ninth-circuit/nevada/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (21) | 100.0 | - |
| courts/ninth-circuit/nevada/state/supreme-court/reply-brief | reply-brief | latex | report | yes (23) | 97.1 | p2 line 3 |
| courts/ninth-circuit/nevada/state/supreme-court/reply-brief | reply-brief | docx | report | yes (23) | 88.5 | p2 line 3 |
| courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (3) | 100.0 | - |
| courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/northern-mariana-islands/federal/district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/northern-mariana-islands/state/supreme-court/answering-brief | answering-brief | latex | report | yes (30) | 98.6 | p21 line 28 |
| courts/ninth-circuit/northern-mariana-islands/state/supreme-court/answering-brief | answering-brief | docx | gate | yes (30) | 100.0 | - |
| courts/ninth-circuit/oregon/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/oregon/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (5) | 100.0 | - |
| courts/ninth-circuit/oregon/federal/district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/oregon/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (17) | 100.0 | - |
| courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/washington/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/ninth-circuit/washington/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/ninth-circuit/washington/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/ninth-circuit/washington/federal/western-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/ninth-circuit/washington/federal/western-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/ninth-circuit/washington/state/court-of-appeals/motion-brief | motion-brief | latex | report | yes (52) | 99.3 | p33 line 15 |
| courts/ninth-circuit/washington/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (52) | 98.1 | p24 line 6 |
| courts/ninth-circuit/washington/state/court-of-appeals/petition-for-discretionary-review | petition-for-discretionary-review | latex | report | yes (38) | 98.2 | p17 line 13 |
| courts/ninth-circuit/washington/state/court-of-appeals/petition-for-discretionary-review | petition-for-discretionary-review | docx | report | yes (38) | 98.4 | p17 line 13 |
| courts/ninth-circuit/washington/state/court-of-appeals/reply-brief | reply-brief | latex | report | yes (18) | 98.2 | p18 line 5 |
| courts/ninth-circuit/washington/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (18) | 100.0 | - |
| courts/ninth-circuit/washington/state/supreme-court/motion-brief | motion-brief | latex | report | yes (14) | 100.0 | - |
| courts/ninth-circuit/washington/state/supreme-court/motion-brief | motion-brief | docx | report | yes (14) | 99.2 | p8 line 10 |
| courts/ninth-circuit/washington/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | gate | yes (6) | 100.0 | - |
| courts/ninth-circuit/washington/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | gate | yes (6) | 100.0 | - |
| courts/second-circuit/connecticut/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/second-circuit/connecticut/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/second-circuit/connecticut/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/second-circuit/connecticut/federal/district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/second-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (13) | 100.0 | - |
| courts/second-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (13) | 100.0 | - |
| courts/second-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (20) | 100.0 | - |
| courts/second-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (20) | 100.0 | - |
| courts/second-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (14) | 100.0 | - |
| courts/second-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (14) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (11) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/second-circuit/new-york/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/second-circuit/new-york/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/second-circuit/new-york/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/second-circuit/new-york/federal/northern-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/second-circuit/new-york/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/second-circuit/new-york/federal/southern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/second-circuit/new-york/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/second-circuit/new-york/federal/western-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/second-circuit/new-york/federal/western-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/second-circuit/new-york/state/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (14) | 100.0 | - |
| courts/second-circuit/new-york/state/court-of-appeals/motion-brief | motion-brief | latex | gate | yes (7) | 100.0 | - |
| courts/second-circuit/new-york/state/court-of-appeals/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/second-circuit/new-york/state/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (14) | 100.0 | - |
| courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/answering-brief | answering-brief | docx | gate | yes (17) | 100.0 | - |
| courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/opening-brief | opening-brief | docx | gate | yes (11) | 100.0 | - |
| courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/reply-brief | reply-brief | docx | gate | yes (13) | 100.0 | - |
| courts/second-circuit/new-york/state/supreme-court/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/second-circuit/new-york/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/second-circuit/vermont/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (15) | 100.0 | - |
| courts/second-circuit/vermont/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/second-circuit/vermont/federal/district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/second-circuit/vermont/federal/district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/second-circuit/vermont/state/supreme-court/answering-brief | answering-brief | latex | report | yes (30) | 99.6 | p15 line 8 |
| courts/second-circuit/vermont/state/supreme-court/answering-brief | answering-brief | docx | report | yes (30) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (16) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (16) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (15) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (15) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (13) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (13) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/reply-brief | reply-brief-2 | latex | gate | yes (15) | 100.0 | - |
| courts/seventh-circuit/court-of-appeals/reply-brief | reply-brief-2 | docx | gate | yes (15) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/bankruptcy-central-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (14) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (8) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/central-district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/central-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/northern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/southern-district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/seventh-circuit/illinois/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/seventh-circuit/illinois/state/appellate-court/amicus-brief | amicus-brief | latex | report | yes (37) | 95.8 | p2 line 4 |
| courts/seventh-circuit/illinois/state/appellate-court/amicus-brief | amicus-brief | docx | report | yes (37) | 95.6 | p2 line 4 |
| courts/seventh-circuit/illinois/state/appellate-court/answering-brief | answering-brief | latex | report | yes (18) | 93.8 | p3 line 18 |
| courts/seventh-circuit/illinois/state/appellate-court/answering-brief | answering-brief | docx | report | yes (18) | 97.8 | p12 line 13 |
| courts/seventh-circuit/illinois/state/appellate-court/motion-brief | motion-brief | latex | gate | yes (7) | 100.0 | - |
| courts/seventh-circuit/illinois/state/appellate-court/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/seventh-circuit/illinois/state/appellate-court/opening-brief | opening-brief | latex | report | no (79 vs 78) | 93.6 | p2 line 7 |
| courts/seventh-circuit/illinois/state/appellate-court/opening-brief | opening-brief | docx | report | no (79 vs 78) | 96.3 | p4 line 17 |
| courts/seventh-circuit/illinois/state/appellate-court/petition-for-review | petition-for-review | latex | gate | yes (3) | 100.0 | - |
| courts/seventh-circuit/illinois/state/appellate-court/petition-for-review | petition-for-review | docx | gate | yes (3) | 100.0 | - |
| courts/seventh-circuit/illinois/state/appellate-court/reply-brief | reply-brief | latex | report | yes (22) | 99.5 | p7 line 1 |
| courts/seventh-circuit/illinois/state/appellate-court/reply-brief | reply-brief | docx | report | yes (22) | 99.5 | p7 line 1 |
| courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/northern-district/complaint | complaint | docx | gate | yes (16) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/southern-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/seventh-circuit/indiana/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (3) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (20) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/eastern-district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/western-district/complaint | complaint | docx | gate | yes (9) | 100.0 | - |
| courts/seventh-circuit/wisconsin/federal/western-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief | docx | gate | yes (13) | 100.0 | - |
| courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief | opening-brief | docx | gate | yes (13) | 100.0 | - |
| courts/sixth-circuit/bankruptcy-appellate-panel/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/sixth-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (16) | 100.0 | - |
| courts/sixth-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (16) | 100.0 | - |
| courts/sixth-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (19) | 100.0 | - |
| courts/sixth-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (19) | 100.0 | - |
| courts/sixth-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (12) | 100.0 | - |
| courts/sixth-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (12) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (14) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (3) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief | motion-brief-2 | docx | gate | yes (2) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief | motion-brief | docx | report | no (11 vs 12) | 97.0 | p4 line 25 |
| courts/sixth-circuit/kentucky/federal/western-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/sixth-circuit/kentucky/federal/western-district/motion-brief | motion-brief | docx | gate | yes (17) | 100.0 | - |
| courts/sixth-circuit/kentucky/state/court-of-appeals/motion-brief | motion-brief | latex | report | yes (7) | 96.2 | p2 line 18 |
| courts/sixth-circuit/kentucky/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (7) | 96.7 | p2 line 18 |
| courts/sixth-circuit/kentucky/state/court-of-appeals/petition-for-writ | petition-for-writ | latex | report | yes (28) | 95.0 | p10 line 25 |
| courts/sixth-circuit/kentucky/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | report | yes (28) | 100.0 | - |
| courts/sixth-circuit/kentucky/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (5) | 100.0 | - |
| courts/sixth-circuit/kentucky/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (5) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/eastern-district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (16) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/western-district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/sixth-circuit/michigan/federal/western-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/michigan/state/court-of-appeals/motion-brief | motion-brief | latex | report | yes (21) | 98.5 | p13 line 5 |
| courts/sixth-circuit/michigan/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (21) | 93.7 | p3 line 18 |
| courts/sixth-circuit/michigan/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/michigan/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | gate | yes (6) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief | motion-brief-2 | docx | gate | yes (5) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/bankruptcy-southern-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/bankruptcy-southern-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/northern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (15) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/southern-district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/sixth-circuit/ohio/federal/southern-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/ohio/state/court-of-appeals/amicus-brief | amicus-brief | latex | report | yes (21) | 93.3 | p6 line 18 |
| courts/sixth-circuit/ohio/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (21) | 95.1 | p3 line 11 |
| courts/sixth-circuit/ohio/state/court-of-appeals/answering-brief | answering-brief | latex | report | yes (38) | 96.6 | p6 line 13 |
| courts/sixth-circuit/ohio/state/court-of-appeals/answering-brief | answering-brief | docx | report | yes (38) | 97.4 | p2 line 2 |
| courts/sixth-circuit/ohio/state/court-of-appeals/motion-brief | motion-brief | latex | report | yes (28) | 98.5 | p1 line 18 |
| courts/sixth-circuit/ohio/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (28) | 99.1 | p20 line 22 |
| courts/sixth-circuit/ohio/state/court-of-appeals/opening-brief | opening-brief | latex | report | yes (46) | 93.1 | p3 line 13 |
| courts/sixth-circuit/ohio/state/court-of-appeals/opening-brief | opening-brief | docx | report | yes (46) | 98.6 | p3 line 12 |
| courts/sixth-circuit/ohio/state/court-of-appeals/petition-for-writ | petition-for-writ | latex | report | yes (33) | 99.5 | p6 line 22 |
| courts/sixth-circuit/ohio/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | report | yes (33) | 99.5 | p6 line 22 |
| courts/sixth-circuit/ohio/state/court-of-appeals/reply-brief | reply-brief | latex | report | yes (11) | 98.0 | p6 line 24 |
| courts/sixth-circuit/ohio/state/court-of-appeals/reply-brief | reply-brief | docx | report | no (11 vs 10) | 85.0 | p1 line 1 |
| courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (4) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (12) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/middle-district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/middle-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/western-district/complaint | complaint | docx | gate | yes (14) | 100.0 | - |
| courts/sixth-circuit/tennessee/federal/western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/supreme-court-of-the-united-states/amicus-brief | amicus-brief | latex | gate | yes (14) | 100.0 | - |
| courts/supreme-court-of-the-united-states/amicus-brief | amicus-brief | docx | gate | yes (14) | 100.0 | - |
| courts/supreme-court-of-the-united-states/cert-petition | cert-petition | docx | gate | yes (14) | 100.0 | - |
| courts/supreme-court-of-the-united-states/merits-brief | merits-brief | latex | gate | yes (17) | 100.0 | - |
| courts/supreme-court-of-the-united-states/merits-brief | merits-brief | docx | gate | yes (17) | 100.0 | - |
| courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief | answering-brief | docx | gate | yes (7) | 100.0 | - |
| courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief | opening-brief | docx | gate | yes (11) | 100.0 | - |
| courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief | reply-brief | docx | gate | yes (7) | 100.0 | - |
| courts/tenth-circuit/colorado/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/tenth-circuit/colorado/federal/bankruptcy-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (9) | 100.0 | - |
| courts/tenth-circuit/colorado/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/tenth-circuit/colorado/federal/district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/colorado/federal/district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (14) | 100.0 | - |
| courts/tenth-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (14) | 100.0 | - |
| courts/tenth-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (14) | 100.0 | - |
| courts/tenth-circuit/court-of-appeals/reply-brief | reply-brief | docx | report | yes (14) | 100.0 | - |
| courts/tenth-circuit/court-of-appeals/reply-brief | reply-brief-2 | docx | report | yes (14) | 99.2 | p9 line 1 |
| courts/tenth-circuit/kansas/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (9) | 100.0 | - |
| courts/tenth-circuit/kansas/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (14) | 100.0 | - |
| courts/tenth-circuit/kansas/federal/district/complaint | complaint | docx | report | no (14 vs 16) | 37.8 | p1 line 3 |
| courts/tenth-circuit/kansas/federal/district/motion-brief | motion-brief | docx | report | yes (12) | 88.8 | p1 line 3 |
| courts/tenth-circuit/kansas/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (17) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (27) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (27) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/motion-brief | motion-brief | latex | gate | yes (11) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (34) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (34) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/kansas/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/new-mexico/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/new-mexico/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/tenth-circuit/new-mexico/federal/bankruptcy-district/motion-brief | motion-brief-2 | docx | gate | yes (3) | 100.0 | - |
| courts/tenth-circuit/new-mexico/federal/district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/new-mexico/federal/district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/amicus-brief | amicus-brief | latex | report | yes (35) | 93.9 | p2 line 16 |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (35) | 99.7 | p9 line 19 |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/motion-brief | motion-brief | docx | report | yes (19) | 99.0 | p9 line 18 |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/petition-for-writ | petition-for-writ | latex | report | yes (13) | 94.8 | p3 line 19 |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/petition-for-writ | petition-for-writ | docx | gate | yes (13) | 100.0 | - |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/reply-brief | reply-brief | latex | report | yes (24) | 96.9 | p3 line 3 |
| courts/tenth-circuit/new-mexico/state/court-of-appeals/reply-brief | reply-brief | docx | report | yes (24) | 96.9 | p3 line 3 |
| courts/tenth-circuit/new-mexico/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (5) | 100.0 | - |
| courts/tenth-circuit/new-mexico/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (5) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (7) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (4) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/motion-brief | motion-brief-2 | docx | gate | yes (12) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint | adversary-complaint | docx | report | yes (7) | 13.8 | p1 line 1 |
| courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief | motion-brief | docx | report | no (10 vs 9) | 18.0 | p1 line 1 |
| courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | report | no (10 vs 11) | 38.7 | p1 line 6 |
| courts/tenth-circuit/oklahoma/federal/district/complaint | complaint | docx | report | no (11 vs 13) | 26.7 | p1 line 13 |
| courts/tenth-circuit/oklahoma/federal/district/motion-brief | motion-brief | docx | report | no (9 vs 10) | 24.3 | p1 line 4 |
| courts/tenth-circuit/oklahoma/federal/eastern-district/complaint | complaint | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/northern-district/complaint | complaint | docx | gate | yes (15) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/western-district/complaint | complaint | docx | gate | yes (17) | 100.0 | - |
| courts/tenth-circuit/oklahoma/federal/western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/oklahoma/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (24) | 87.4 | p2 line 4 |
| courts/tenth-circuit/oklahoma/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (24) | 99.2 | p9 line 1 |
| courts/tenth-circuit/oklahoma/state/supreme-court/answering-brief | answering-brief | latex | report | no (32 vs 33) | 93.9 | p2 line 25 |
| courts/tenth-circuit/oklahoma/state/supreme-court/answering-brief | answering-brief | docx | report | yes (32) | 96.8 | p3 line 8 |
| courts/tenth-circuit/oklahoma/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | no (20 vs 21) | 82.1 | p2 line 8 |
| courts/tenth-circuit/oklahoma/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | yes (20) | 85.9 | p3 line 20 |
| courts/tenth-circuit/oklahoma/state/supreme-court/motion-brief | motion-brief | latex | report | yes (8) | 98.4 | p3 line 13 |
| courts/tenth-circuit/oklahoma/state/supreme-court/motion-brief | motion-brief | docx | report | yes (8) | 98.4 | p3 line 13 |
| courts/tenth-circuit/oklahoma/state/supreme-court/petition-for-writ | petition-for-writ | latex | report | yes (50) | 95.8 | p1 line 5 |
| courts/tenth-circuit/oklahoma/state/supreme-court/petition-for-writ | petition-for-writ | docx | report | yes (50) | 96.2 | p12 line 15 |
| courts/tenth-circuit/oklahoma/state/supreme-court/reply-brief | reply-brief | latex | report | yes (24) | 96.7 | p4 line 12 |
| courts/tenth-circuit/oklahoma/state/supreme-court/reply-brief | reply-brief | docx | report | yes (24) | 97.2 | p3 line 3 |
| courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (13) | 100.0 | - |
| courts/tenth-circuit/utah/federal/district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/tenth-circuit/utah/federal/district/motion-brief | motion-brief | docx | gate | yes (11) | 100.0 | - |
| courts/tenth-circuit/utah/state/court-of-appeals/amicus-brief | amicus-brief | latex | gate | yes (32) | 100.0 | - |
| courts/tenth-circuit/utah/state/court-of-appeals/amicus-brief | amicus-brief | docx | report | yes (32) | 93.3 | p2 line 4 |
| courts/tenth-circuit/utah/state/court-of-appeals/answering-brief | answering-brief | latex | report | yes (65) | 96.3 | p4 line 4 |
| courts/tenth-circuit/utah/state/court-of-appeals/answering-brief | answering-brief | docx | report | yes (65) | 96.7 | p4 line 4 |
| courts/tenth-circuit/utah/state/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (58) | 100.0 | - |
| courts/tenth-circuit/utah/state/court-of-appeals/opening-brief | opening-brief | docx | report | yes (58) | 99.7 | p11 line 15 |
| courts/tenth-circuit/utah/state/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (15) | 100.0 | - |
| courts/tenth-circuit/utah/state/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (15) | 100.0 | - |
| courts/tenth-circuit/utah/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (17) | 95.7 | p7 line 17 |
| courts/tenth-circuit/utah/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (17) | 91.1 | p2 line 13 |
| courts/tenth-circuit/utah/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | report | no (34 vs 33) | 85.1 | p2 line 21 |
| courts/tenth-circuit/utah/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | report | no (34 vs 33) | 85.1 | p2 line 21 |
| courts/tenth-circuit/utah/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (9) | 100.0 | - |
| courts/tenth-circuit/utah/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/tenth-circuit/utah/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | gate | yes (8) | 100.0 | - |
| courts/tenth-circuit/utah/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | gate | yes (8) | 100.0 | - |
| courts/tenth-circuit/utah/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | report | no (20 vs 21) | 77.8 | p2 line 27 |
| courts/tenth-circuit/utah/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | report | yes (20) | 84.3 | p2 line 27 |
| courts/tenth-circuit/utah/state/supreme-court/petition-for-writ | petition-for-writ | latex | report | yes (30) | 97.6 | p21 line 10 |
| courts/tenth-circuit/utah/state/supreme-court/petition-for-writ | petition-for-writ | docx | report | yes (30) | 97.6 | p21 line 10 |
| courts/tenth-circuit/utah/state/supreme-court/reply-brief | reply-brief | latex | report | yes (16) | 92.3 | p3 line 5 |
| courts/tenth-circuit/utah/state/supreme-court/reply-brief | reply-brief | docx | report | yes (16) | 93.5 | p3 line 5 |
| courts/tenth-circuit/wyoming/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | report | no (5 vs 6) | 24.2 | p1 line 11 |
| courts/tenth-circuit/wyoming/federal/bankruptcy-district/motion-brief | motion-brief | docx | report | no (14 vs 13) | 14.2 | p1 line 13 |
| courts/tenth-circuit/wyoming/federal/district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/tenth-circuit/wyoming/federal/district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/tenth-circuit/wyoming/federal/district/motion-brief | motion-brief-2 | docx | gate | yes (9) | 100.0 | - |
| courts/third-circuit/court-of-appeals/answering-brief | answering-brief | latex | gate | yes (23) | 100.0 | - |
| courts/third-circuit/court-of-appeals/answering-brief | answering-brief | docx | gate | yes (23) | 100.0 | - |
| courts/third-circuit/court-of-appeals/opening-brief | opening-brief | latex | gate | yes (19) | 100.0 | - |
| courts/third-circuit/court-of-appeals/opening-brief | opening-brief | docx | gate | yes (19) | 100.0 | - |
| courts/third-circuit/court-of-appeals/reply-brief | reply-brief | latex | gate | yes (10) | 100.0 | - |
| courts/third-circuit/court-of-appeals/reply-brief | reply-brief | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/delaware/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/delaware/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/third-circuit/delaware/federal/district/complaint | complaint | docx | gate | yes (8) | 100.0 | - |
| courts/third-circuit/delaware/federal/district/motion-brief | motion-brief | docx | gate | yes (12) | 100.0 | - |
| courts/third-circuit/new-jersey/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/new-jersey/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/new-jersey/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/third-circuit/new-jersey/federal/district/motion-brief | motion-brief | docx | report | no (11 vs 12) | 77.4 | p2 line 8 |
| courts/third-circuit/new-jersey/state/supreme-court/amicus-brief | amicus-brief | latex | report | yes (15) | 96.9 | p11 line 21 |
| courts/third-circuit/new-jersey/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (15) | 96.9 | p11 line 21 |
| courts/third-circuit/new-jersey/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (8) | 100.0 | - |
| courts/third-circuit/new-jersey/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/third-circuit/new-jersey/state/supreme-court/petition-for-writ | petition-for-writ | latex | report | yes (20) | 96.8 | p6 line 20 |
| courts/third-circuit/new-jersey/state/supreme-court/petition-for-writ | petition-for-writ | docx | gate | yes (20) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint | docx | gate | yes (13) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/adversary-complaint | adversary-complaint-2 | docx | gate | yes (9) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint | adversary-complaint | docx | gate | yes (3) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/motion-brief | motion-brief | docx | gate | yes (7) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint | adversary-complaint | docx | gate | yes (11) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/eastern-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/middle-district/complaint | complaint | docx | gate | yes (13) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/middle-district/motion-brief | motion-brief | docx | gate | yes (10) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/western-district/complaint | complaint | docx | gate | yes (11) | 100.0 | - |
| courts/third-circuit/pennsylvania/federal/western-district/motion-brief | motion-brief | docx | gate | yes (8) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/commonwealth-court/amicus-brief | amicus-brief | docx | report | yes (19) | 98.7 | p4 line 11 |
| courts/third-circuit/pennsylvania/state/commonwealth-court/motion-brief | motion-brief | latex | report | yes (11) | 98.0 | p3 line 17 |
| courts/third-circuit/pennsylvania/state/commonwealth-court/motion-brief | motion-brief | docx | report | yes (11) | 98.4 | p3 line 17 |
| courts/third-circuit/pennsylvania/state/commonwealth-court/petition-for-review | petition-for-review | latex | report | yes (26) | 98.1 | p8 line 19 |
| courts/third-circuit/pennsylvania/state/commonwealth-court/petition-for-review | petition-for-review | docx | report | yes (26) | 97.9 | p10 line 16 |
| courts/third-circuit/pennsylvania/state/commonwealth-court/petition-for-writ | petition-for-writ | latex | report | yes (29) | 94.1 | p5 line 18 |
| courts/third-circuit/pennsylvania/state/commonwealth-court/petition-for-writ | petition-for-writ | docx | report | yes (29) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/amicus-brief | amicus-brief | latex | gate | yes (27) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/amicus-brief | amicus-brief | docx | report | yes (27) | 94.8 | p17 line 1 |
| courts/third-circuit/pennsylvania/state/supreme-court/answering-brief | answering-brief | latex | gate | yes (45) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/answering-brief | answering-brief | docx | gate | yes (45) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/brief-on-the-merits | brief-on-the-merits | latex | gate | yes (77) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/brief-on-the-merits | brief-on-the-merits | docx | gate | yes (77) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/motion-brief | motion-brief | latex | gate | yes (35) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/motion-brief | motion-brief | docx | gate | yes (35) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | latex | gate | yes (27) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-discretionary-review | petition-for-discretionary-review | docx | gate | yes (27) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-rehearing | petition-for-rehearing | latex | gate | yes (5) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-rehearing | petition-for-rehearing | docx | gate | yes (5) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-review | petition-for-review | latex | report | yes (44) | 99.5 | p23 line 6 |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-review | petition-for-review | docx | gate | yes (44) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-writ | petition-for-writ | latex | gate | yes (70) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/petition-for-writ | petition-for-writ | docx | report | yes (70) | 98.3 | p31 line 20 |
| courts/third-circuit/pennsylvania/state/supreme-court/reply-brief | reply-brief | latex | gate | yes (21) | 100.0 | - |
| courts/third-circuit/pennsylvania/state/supreme-court/reply-brief | reply-brief | docx | gate | yes (21) | 100.0 | - |
| courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint | adversary-complaint | docx | gate | yes (11) | 100.0 | - |
| courts/third-circuit/virgin-islands/federal/bankruptcy-district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |
| courts/third-circuit/virgin-islands/federal/district/complaint | complaint | docx | gate | yes (12) | 100.0 | - |
| courts/third-circuit/virgin-islands/federal/district/motion-brief | motion-brief | docx | gate | yes (9) | 100.0 | - |

</details>

### Adopting the reference breaker (fb-595.54.1): the checklist for the fan-out

The layout model is shared code, not a recipe to copy: `lib/typst/xengine.typ`, `lib/latex/xengine.sty` with `lib/latex/xengine.lua`, `lib/docx/xengine.lua` with `lib/docx/xengine-reference.sh`, and `lib/pandoc/xengine.lua` (the inline rules both pandoc engines share), and for a LaTeX template set in TeX Gyre Schola `lib/latex/xeschola.sty` with `lib/latex/xeschola.lua` (the vendored font's advances; fb-595.54.5). ca9 runs on them unchanged: all six PDFs byte-identical to the renders before the move (`pdftoppm -r 100`, 0 pixels changed on every page; typst 98, latex 104, docx 104, SELFTEST OK 25/25). Re-verified on 2026-10-22 against current master: 100 typst, 106 latex, and 108 docx checks passed with 0 failures; the selftest printed `SELFTEST OK`, and `cargo test --manifest-path tools/fb/Cargo.toml` passed 320 tests. The totals include newer default checks added since the original extraction. `fb render` makes them reachable: every pandoc run has `<repo>/lib/?.lua` first on `LUA_PATH` (a court filter, or a `docx/render.sh` that calls pandoc, loads `require("docx.xengine")`), and in the generated `doc.tex` a line `\usepackage{NAME}` (a `%` comment may follow) for which `lib/latex/NAME.sty` exists is replaced by that file between `\makeatletter` and `\makeatother` (`tools/fb/src/sharedlib.rs`), so the `.tex` still compiles alone with stock pdflatex. A folder adopts the model engine by engine, in this order, and keeps its own numbers (sizes, pitches, spaces, indents, columns):

**0. One face.** The three engines set the same metrics: Times New Roman ↔ newtx (`newtxtext,newtxmath`), Century Schoolbook ↔ `tgschola`, EB Garamond ↔ `ebgaramond`, Gelasio ↔ `gelasio`; the docx names the vendored family the typst template names (`fb lint fonts`, `DEF-FONT-002`). Sizes in whole half points (Word has no others).

**1. typst (the reference).**
- [ ] `#import "/lib/typst/xengine.typ": xengine, edges, listing-row`.
- [ ] Pitches, not leadings: one `#let pitch-… = <pt>` per kind of line (body, single, headings), `set text(..edges(pitch))` where a kind of block starts, `leading: 0pt` in every `par`; spaces between blocks as explicit `block(above:, below:)` in pt (two explicit ones collapse to the larger, as in Word and `\addvspace`).
- [ ] After the template's own `set text(font:, size:, …)` and `set par(first-line-indent: …)`: `show: xengine.with(pitch: <body pitch>, list-indent: <label box>)`; drop the template's own `kerning`, `ligatures`, `hyphenate`, `linebreaks`, `justify`, super, list and `§`/parenthesis rules (xengine sets them; `list-indent: none` keeps typst's lists).
- [ ] Contents and authorities: `listing-row(target, body, page, col, hang, above)`: the text wraps before a page column `col` (pt), the leader runs from three spaces after the text to the page.
- [ ] No small capitals and no synthesized styles (Word and LaTeX synthesize differently); check boxes a ruled box around a literal X.

**2. latex.**
- [ ] `\usepackage{xengine}` after every other package and before `\makeatletter`; set `\parindent` after it (its `\raggedright` zeroes it).
- [ ] Every size through `\xe@lines{<size>}{<pitch>}` (numbers in bp, the typst values): `\normalsize`, `\footnotesize`, the single and heading styles; no `\fontsize` in TeX points, no `\baselineskip`.
- [ ] Every space between blocks as `\par\addvspace{<bp>}` (headings: `\par\addvspace{above}`, the heading, `\nobreak\addvspace{below}`); no `\vspace`, `\needspace`, `center` or list environments around text (their skips add up instead of collapsing); centered lines as `\begingroup\centering … \par\endgroup`; labels and write nodes inside the paragraph, never between a heading and its text.
- [ ] Footnotes: `\xe@footnotemarks{<body size>}`, `\@makefntext` sets `\xe@mark{\@thefnmark}`, `\skip\footins` and the rule as typst's `footnote.entry`.
- [ ] Lists: `\xe@lists{<label box>}` (enumitem). Contents and authorities: `\setlength{\xe@col}{<bp>}` then `\xe@row{<above>}{<hang>}{<text>}{<page>}`.
- [ ] The filter: `local xe = require("latex.xengine")` and `Inlines = xe.inlines` over the body and over every metadata value the template sets.

**3. docx.**
- [ ] `docx/make-reference.sh` calls `sh <repo>/lib/docx/xengine-reference.sh "$out" font=<family> size=<half points> body=<twips> single=<twips> [indent= list= heading= heading_before= heading_after= quote= note_after= footer=]` (twips = 20 × pt: the typst pitches); commit the `reference.docx` it builds.
- [ ] The filter: `local xe = require("docx.xengine")`; every paragraph it writes carries `xe.spacing(before, after, line)` (exact line spacing, the typst pitch and spaces in twips) and its text as `xe.inl`/`xe.runs`; the inlines pandoc writes itself are walked with `Inlines = xe.inlines`; lists through `xe.list_items` (style List Item); table rows with the page column as right indent, `xe.leader_tab(<text width>)` and `xe.LEAD` before the tab; headings and the last paragraph before the signature `xe.KEEP`.
- [ ] The footer's page number in a single-pitch line, at the typst footer's distance.

**4. Verify and gate.**
- [ ] On every INPUT, latex and docx (where present) match typst on page count, page starts and ends, and every line break: `XENG-001..003` all PASS. Use `fb diff --engines OUTPUT-<id>.typst.pdf OUTPUT-<id>.<engine>.pdf` to identify each differing line, its break word and width drift; fix template differences. If an engine cannot match for a documented limitation outside the template, record the folder, engine, failing check IDs and reason, and leave that engine `report` with the reason beside its `cross_engine_<engine>` setting.
- [ ] After the port, `sh tools/check.sh <dir> --engine typst|latex|docx` has zero failed checks on every engine present, including `DEF-COVER-001` and `DEF-TOC-001` when applicable. Then set `params.cross_engine: gate` in the folder's `eval.yaml` (or `checks.yaml`) only when each present secondary engine passes XENG-001..003 on every INPUT. Re-do the Gate 2 review on the new renders; a folder with a selftest must include a kerning mutant like ca9's `latex-kerning` (`\RemoveFromHook{selectfont}[xengine]` must fail `XENG-003`).
- [ ] A port of a template that already passes changes no pixel: `pdftoppm -r 100` before and after, every page.

**Fan-out acceptance (including fb-595.68.18).** For every folder in the assigned list, check every INPUT on each present engine. LaTeX and docx must match typst's line breaks, page ends and page count (`XENG-001..003`, zero failed); then set `params.cross_engine: gate`. Require zero failed tier-1 checks on all present engines, including `DEF-COVER-001` and `DEF-TOC-001` (the latter passes when no table is present). Record any folder or engine that cannot match, with the failing XENG IDs and observed differences; it cannot be counted as adopted. For docx, also finish the [DOCX porting checklist](DOCX.md#porting-checklist-one-folder-fb-59568-step-2): the template face must equal typst's face, all per-court shell builders/renderers and their private helpers are removed, and the `.shell-safety-baseline.json` entries for the assigned folders are zero.

**Florida district adoption (fb-595.68.11; verified 2026-10-22).** All 11 assigned folders have typst and DOCX engines, no LaTeX template, `params.cross_engine: gate`, and current committed typst/DOCX check stamps. The DOCX path is declarative (`reference.xml` and Lua filters), resolves its face through `{font}`, and has no per-court `*.sh` builder or renderer. None of the assigned folders appears in `.shell-safety-baseline.json`. On `newbox/fb-595-68-11-a7`, fresh `check.sh` runs passed for both engines in all 11 folders (22 runs): zero failed checks, including `DEF-COVER-001` and `DEF-TOC-001`, with DOCX XENG-001..003 passing in all 11 folders. `cargo test --manifest-path tools/fb/Cargo.toml` passed (320 tests, 0 failed).

Folders: `courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/motion-brief`, `bankruptcy-northern-district/{adversary-complaint,motion-brief}`, `bankruptcy-southern-district/{adversary-complaint,motion-brief}`, `middle-district/{complaint,motion-brief}`, `northern-district/{complaint,motion-brief}`, and `southern-district/{complaint,motion-brief}`.
**Sixth Circuit Tennessee part 02 adoption (fb-595.68.31, verified 2026-10-22).** These 11 folders have typst and DOCX templates and no LaTeX templates. Every DOCX uses declarative `reference.xml` and Lua filters, inherits the Times New Roman face through `{font}` from typst, has no per-court shell builder or script-only artifact, and has no `.shell-safety-baseline.json` entry. All 11 folders set `params.cross_engine: gate`. Rerunning typst and DOCX `check.sh` for all 11 folders passed all 22 engine runs with zero failed checks; `DEF-COVER-001` and `DEF-TOC-001` had zero failures, and DOCX XENG-001..003 passed on every input. `fb lint fonts` reports no assigned folder. No folder or engine remains at `report` for a cross-engine mismatch.

Folders: `courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief`, `bankruptcy-middle-district/{adversary-complaint,motion-brief}`, `bankruptcy-western-district/{adversary-complaint,motion-brief}`, `eastern-district/{complaint,motion-brief}`, `middle-district/{complaint,motion-brief}`, and `western-district/{complaint,motion-brief}`.

**Fourth Circuit part 01 adoption (fb-595.68.19, verified 2026-10-22).** The 12 assigned North Carolina, South Carolina, and Virginia federal district folders listed below have typst and DOCX templates and no LaTeX templates. Each DOCX uses declarative `reference.xml` and Lua filters, inherits its face through `{font}` from typst, has no per-court builder/render shell script or script-only artifact, and has no `.shell-safety-baseline.json` entry. Every folder has `params.cross_engine: gate`. Rerunning typst and DOCX `check.sh` for all 12 folders passed all 24 engine runs with zero failed checks; `DEF-COVER-001` and `DEF-TOC-001` had zero failures, and DOCX XENG-001..003 passed for every input. No folder or engine remains at `report` for a cross-engine mismatch.

**Third Circuit part 02 adoption (fb-595.68.34, verified 2026-10-22).** The 12 assigned Delaware, New Jersey, and Pennsylvania federal district and bankruptcy folders listed below have typst and DOCX templates and no LaTeX templates. Each DOCX uses declarative `reference.xml` and Lua filters, inherits the typst face through `{font}`, has no per-court shell builder or renderer, and has no `.shell-safety-baseline.json` entry. All 12 folders set `params.cross_engine: gate`. The master verification reran `check.sh` for typst and DOCX in all 12 folders: all 24 engine runs passed with zero failed checks, including zero failures for `DEF-COVER-001` and `DEF-TOC-001`; DOCX XENG-001..003 passed on every input. No folder or engine remains at `report` for a cross-engine mismatch.

Folders: `courts/third-circuit/delaware/federal/bankruptcy-district/{adversary-complaint,motion-brief}`, `courts/third-circuit/delaware/federal/district/{complaint,motion-brief}`, `courts/third-circuit/new-jersey/federal/bankruptcy-district/{adversary-complaint,motion-brief}`, `courts/third-circuit/new-jersey/federal/district/complaint`, `courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/{adversary-complaint,motion-brief}`, `courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/{adversary-complaint,motion-brief}`, and `courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint`.

Folders: `courts/fourth-circuit/north-carolina/federal/middle-district/{complaint,motion-brief}`, `courts/fourth-circuit/north-carolina/federal/western-district/{complaint,motion-brief}`, `courts/fourth-circuit/south-carolina/federal/bankruptcy-district/{adversary-complaint,motion-brief}`, `courts/fourth-circuit/south-carolina/federal/district/motion-brief`, `courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district/{adversary-complaint,motion-brief}`, `courts/fourth-circuit/virginia/federal/bankruptcy-western-district/{adversary-complaint,motion-brief}`, and `courts/fourth-circuit/virginia/federal/eastern-district/complaint`.

**Tenth Circuit part 00 adoption (fb-595.68.32, verified 2026-10-22).** The 12 assigned Colorado, Kansas, New Mexico, and Oklahoma federal bankruptcy and district folders have typst and DOCX templates and no LaTeX templates. Each DOCX uses declarative `reference.xml` and Lua filters, inherits its face through `{font}` from typst, has no per-court builder/render shell script or script-only artifact, and has no `.shell-safety-baseline.json` entry. Every folder has `params.cross_engine: gate`. Rerunning typst and DOCX `check.sh` for all 12 folders passed all 24 engine runs with zero failed checks; `DEF-COVER-001` and `DEF-TOC-001` had zero failures, and DOCX XENG-001..003 passed for every input. No folder or engine remains at `report` for a cross-engine mismatch. These folders use the default check set and have no folder-specific `checks.yaml`, so the mutation selftest cannot run on them (it requires a folder-specific check definition).

**What the first adoption found** (`courts/seventh-circuit/court-of-appeals/opening-brief`, fb-595.54.1; before: latex 14 vs 16 pages and 40.0 % of lines alike, docx 42.3 % and a tier-1 font failure (EB Garamond for a Times template); after: XENG-001..003 PASS on both engines, `params.cross_engine: gate` in its `eval.yaml`). The pitfalls, each a line or page the gate caught:
- A line that holds boxes (two columns of counsel as minipages) must keep its natural height: `\xe@natural` before it (pdfTeX's unset `\pdfeachlineheight` is −2³⁰ sp, which `-\maxdimen` is not; the package keeps it from load time), and `\xe@lines` again inside each box.
- Word keeps the space above a paragraph that opens a section or follows a page break; typst drops it at the top of a page: a heading that opens a page carries `before="0"`. The empty paragraph that ends a Word section gets a 1 pt exact line, or it pushes a full page's last line on.
- A `\par` inside a `\noindent` group starts an indented paragraph: a form's second paragraph needs its own `\noindent`. `\emph{…}\fi,` puts an italic correction before the comma (`\emph{…},` does not): the PDF text then has "Meyerhoff ,".
- Every engine certifies the same number: count words block by block (stringify of the whole document runs words together), before the headings become raw output. A certificate that names the program ("using Typst …", "using LaTeX …") differs between engines; the wording names the typeface only.
- Word's table page numbers come from a page map of the LibreOffice PDF; search it as ca9's needles do (docxpages.rs): a heading by its label and title at the start of a line, each citation as its link text and the words after it, in document order, with its first words as the fallback when it runs over a page end. A search for the link text alone takes unlinked mentions and a body sentence that begins like a heading (three wrong page numbers in the ca7 docx before the port).
- A footnote widow (fb-595.54.9): typst keeps a paragraph's last two lines together by their heights alone, so when the last line carries a footnote that does not fit with it, the line moved on alone, while LaTeX and Word carry the line before it too. `lib/typst/xengine.typ` does what they do when a template asks for it, `xengine.with(.., footnote-widows: false)` (a paragraph flagged by its footnote places an empty float that ends the page half a line above its second-to-last line). It is opt-in: the federal-circuit fan-out solved the same widow the other way (below), and on the cafc and nmcca opening briefs the rule's layout did not settle (typst "element position did not stabilize", a failed render). With it opt-in, every typst render of the 66 other folders on the model is byte-identical to its committed OUTPUT (82 INPUTs, re-rendered 2026-10-22).
- A line typst fills to within a few hundredths of a point (fb-595.54.9): newtx sets a full line up to about 0.04 bp wider than Times New Roman, so a template may widen the LaTeX text by 0.05 bp; LibreOffice decides a line in whole twips, which no setting aligns with typst both ways (a 1-twip indent that fixed one such line broke another), so such a docx is reported with `params.cross_engine_docx: report`, not gated.

**What the federal-circuit fan-out found** (fb-595.54.6, 14 folders gated; each worked around in the folder, candidates for the shared libraries):
- A paragraph whose footnote does not fit: typst moves that paragraph's last line alone to the next page (its widow rule does not see the note). The latex and docx engines turn widow and orphan control off for a paragraph that carries a footnote mark (docx a "Body Text Note" style, latex `\widowpenalty=0 \clubpenalty=0` around it), never typst. The footnote entry sets `leading: 0pt` itself (it does not inherit the body's), and Word's Footnote Text must not keep its lines together where typst splits a note.
- LibreOffice breaks where typst does not: inside a ")(" token ("§ 7261(a)(3)": a word joiner between the parentheses) and at the space before ". . ."; typst breaks after a slash before a letter ("CM/ECF": docx a zero-width space, latex `\allowbreak`) and between a doubled sign and its number unless bound (`§§ 2643`: bind `[§¶]+`, not one sign). None of these characters shows in the PDF text.
- A table row whose last word ends just before the page column: LibreOffice wants about 4 pt free after `xe.LEAD` before the leader tab, or it wraps the word that typst's `listing-row` keeps.
- newtx's advances are Times New Roman's rounded to 1/1000 em; on running text they are wider by +0.05/1000 em per character, about +0.05 pt over a 14 pt line, which moves the break of a line typst fits with less than that to spare (the CAFC opening brief: two lines; its latex text block is 0.05 bp wider, the measured bias, documented in its template).
- A template that only declares Liberation Serif fails DEF-FONT-002 on docx (LibreOffice embeds the real Times New Roman the docx names): declare `("Times New Roman", "Liberation Serif")`. A face set for EB Garamond leaves leadings that overlap or under-space lines in Times: set pitches, not em leadings.
**What the federal-appellate adoption found** (fb-595.54.5: tenth-circuit, eleventh-circuit and Supreme Court folders; the Supreme Court templates set TeX Gyre Schola). Each a line or page the gate caught:
- *One face, two versions.* pdfLaTeX (`tgschola`) sets TeX Live's Type 1 Schola 2.005; typst and Word the vendored Schola 2.609. Sixteen advances differ (a parenthesis 333/1000 em in 2.005, 483 in 2.609; slash, brackets, braces, `*`, `+`, `<`, `=`, `>`, `|`, `\`, ellipsis, bullet). `\usepackage{xeschola}` (`lib/latex/xeschola.sty`) and `require("latex.xeschola")` (`.lua`, run top down after `latex.xengine`) set those glyphs at the 2.609 advance: a narrower one scaled, a wider one's extra width kept to the end of its segment (before a space, a footnote, an `\allowbreak`, the end of the block), since a gap inside a word reads as a word break in the PDF text; a slash is scaled (a line may end after it). Compare a face's TeX and vendored metrics before trusting "the same font".
- *LibreOffice ligatures.* LibreOffice forms a font's fi/fl ligatures (Schola has them; Word and typst set none) and does not read `w14:ligatures`. A reference.docx whose docDefaults carry `<w14:ligatures w14:val="none"/>` is converted by `fb render` from a copy whose font names carry LibreOffice's `:-liga` (`tools/fb/src/doclig.rs`); the delivered .docx keeps its font names.
- *LibreOffice's Schola is a hair narrower.* 0.088 % on the mean of 203 identical lines (its glyph positions are rounded, unevenly), and each line starts 0.1 pt in: a line typst overflows by under ~0.15 pt fits in LibreOffice. The SCOTUS docx take the difference in the right margin, measured per folder as the one at which every sample line breaks as in typst (1 in + 0.05 to 0.15 pt; one twip either side moves a line); a line of other text that close to the measure may still break differently. Times New Roman showed no such drift.
- *Leader gaps.* `xe.LEAD`'s three no-break spaces are typst's 0.75 em only where a space is 0.25 em (Times); Schola's are 0.278 em (10 pt at 12 pt). LibreOffice ignores character spacing on them: two at the type size and one at 8.5 pt give 9.04 pt.
- *Footnotes and widows.* typst keeps two lines of a paragraph together by their height alone; when a line's footnote does not fit, that line moves on and the one before stays behind alone. LaTeX: `\widowpenalty=0 \clubpenalty=0` around a paragraph with a footnote mark; Word: a paragraph style without widow control for it ("Body Text Note"). LibreOffice sometimes keeps the anchor line and moves the whole footnote instead (ca10 reply-brief-2, p9: no fix found; that folder stays REPORTED).
- *Justification.* typst justifies by shrinking spaces too, so a justified line holds more than Word's; `justification-limits: (spacing: (min: 100%, ...))` stops that, but a justified 4 1/8 in measure without hyphenation (which no two engines share) opens wide gaps: the SCOTUS merits brief and cert petition went ragged right, as the amicus brief already was.
- *Paragraph indents and structure.* typst indents a paragraph only after a paragraph (not after a heading, a quotation or a list): Word needs "First Paragraph" explicitly there (pandoc does not set it after raw headings), LaTeX a `\noindent`. A quotation that holds a list is a `\list` environment in LaTeX, or the list loses the quotation's margins. pandoc reads "b. The ..." and a value "(202) 787-1060" as list items; typst does not: the filters turn them back into text.

### Generated engines: the shared document model (fb-595.54.12)

The state doc folders (689 with a typst template: 656 typst-only, 3 with a docx folder, 30 with a `docx/*.sh` that fb-595.68 step 2 owns; no state doc folder has a LaTeX template, the "142 typst+latex" of the bead are empty court-root `latex/` folders) get their latex and docx engines generated, not written by hand.

**Families** (`fb engines families`, tools/fb/src/enginegen/families.rs; measured before the pilot). Each template is read as tokens with the comments dropped, every string `S`, every number `N`, the template's own name `F`; templates with the same tokens are one exact family, and exact families are joined at a Jaccard similarity of their 5-token shingles (single linkage):

| measure | families | of one folder | largest |
|---|---|---|---|
| exact (same code modulo strings, numbers, name) | 462 | 362 | 9 |
| Jaccard >= 0.95 | 307 | 185 | 24 |
| Jaccard >= 0.9 | 230 | 121 | 24 |
| Jaccard >= 0.8 | 165 | 77 | 60 |
| Jaccard >= 0.7 | 116 | 51 | 126 |
| Jaccard >= 0.5 | 50 | 22 | 330 |

At 0.9 the sizes are 24, 18, 14, 13, 12, 12, 11, 10, 10, nine of 9, eight of 8, eight of 7, twelve of 6, twelve of 5, ten of 4, twenty-one of 3, twenty-five of 2 and 121 of 1. The families follow court lines (one court's doc types share a template; the largest is California's courts of appeal, the next Colorado and Utah), so a typst-to-LaTeX translator per family would mean some 230 translators. The generator therefore does not translate typst code: a folder's layout becomes data that one shared model sets in all three engines.

**The model.** `typst/layout.yaml` holds every number and every block of the folder's layout, each with its rule in a comment; the typst template names the face and hands the layout to `lib/typst/xdoc.typ`:

```typst
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter
#let font-family = ("Times New Roman", "Liberation Serif")   // the rule that names the face
#let mn-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
```

`fb engines gen <folder>` (tools/fb/src/enginegen/gen.rs) writes, from the layout and the template's face (typstface.rs): `latex/template.tex` (the face's package, the page, `xengine.sty` and `xdoc.sty`, the body and footnote line boxes, footnote rule and marks, list labels, the ellipsis), `latex/xdoc.lua` and `docx/xdoc.lua` (`return require("latex.xdoc")(<layout>)`, the layout as a Lua table), and `docx/reference.xml` (the cross-engine recipe at the layout's size and pitches, `{font}`, Body Text Note, the quotation, list and tail styles, the page-number footer, the section). Every generated file says so; `fb engines gen --check` fails on a stale one. `lib/pandoc/xdoc.lua` builds the same tree of blocks for both pandoc engines (`lib/latex/xdoc.lua`, `lib/docx/xdoc.lua`), rule for rule as `lib/typst/xdoc.typ` lays them out, all on the cross-engine model (xengine): the latex and docx renders break every line where typst does by construction, and what one engine does differently is fixed once, in the shared code, for every folder.

**`layout.yaml`** (lengths in points, each a whole number of twips; sizes in half points):

| key | what |
|---|---|
| `size`, `pitch: {body, single}`, `margin: {top, bottom, left, right}`, `indent`, `list_indent` | type size, the two line pitches, the page, the first-line and list indents |
| `paper` | `letter` (the default, 612 x 792 pt) or `legal` (612 x 1008 pt): typst `us-legal`, LaTeX geometry `legalpaper`, Word a 20160-twip page |
| `checks: {footnotes, sections}` | what a court's rules ask of the body, stopping the render in every engine (a word limit: `words.limit`): `footnotes: false` no footnote (22 NYCRR Part 1000); `sections: [..]` those level-1 headings, by the start of their text in any case, present and in that order (22 NYCRR 1250.8(b), TRAP 55.2) |
| `paragraph_gap` | the space between two body paragraphs, a paragraph and a list, or two lists (typst paragraph spacing and a list a block of that space; next to a heading or quotation that block's own space applies, as in typst): LaTeX `\addvspace` between them, Word the Gap variants of Body Text, Body Text Note, Body Text Keep and the first list item after a paragraph or list |
| `justify: true` | the body justified (its paragraphs, quotations, lists, notes and tail; not the layout's blocks, headings or tables): every line but a paragraph's last at the full measure, its spaces stretched and never shrunk, so the lines break where they do ragged (typst `justification-limits` spacing min 100 %, LaTeX interword glue `plus 1fil` in the body only with `\parfillskip` `1fill`, Word `jc` both; LibreOffice in its old compatibility mode never shrinks a space). Proved on a copy of a gated folder: 162 of 162 lines identical in all three engines |
| `links: false` | links as their text (a court that bars hyperlinks: Ga. Sup. Ct. R. 17(3)): the body's and notes' links lose their target in every engine (typst a show rule on a URL target, LaTeX and Word `xd.unlink`); a keyed authority's `toa:` link and the contents' own links stay |
| `cover_fill: "#rrggbb"` | a coloured cover (Ky. RAP 31(C)(2), Ill. S. Ct. R. 341(d)): the pages before the tables in that colour (typst a page background, LaTeX `\pagecolor` and xcolor, Word a page-sized rectangle behind the text anchored in the cover's first paragraph: its first page only) |
| `page_number: {align, from, front, text, cover}` | the page number in a single line box (`cover: counted` the cover counted in the tables' numbering, unprinted, the tables from ii; `cover: numbered` printed too; `text: "Page {page} of {pages}"`: {pages} the last page's number; typst `counter(page).final()`, LaTeX `\pageref*` of a label at the end, Word `NUMPAGES`, `SECTIONPAGES` for a body numbered apart) (typst's footer at 30 % of the bottom margin; Word's footer, LaTeX's `footskip` where typst sets it); `from: 2` leaves page 1 unnumbered; `front: lower-roman` numbers the tables apart (cover none, tables i, ii .., body from 1: Word sections) |
| `footnote: {size, pitch, gap, clearance}`, `quote: {left, right, above, below, gap, pitch}`, `list: {markers}` | notes (a 30 % rule, the mark and a space), quotations (paragraphs and lists, `gap` between them; a list in a quotation at its indents and pitch: LaTeX enumitem margins, Word `XdQuoteList1..3`), bullets per nesting level |
| `heading: [style, ..]` | levels 1, 2, ..: a style (below) with `above`/`below`; kept with what follows; a level the template numbers: `number` (a typst numbering pattern of one counting symbol: `I.`, `A.`, `1.`, `a.`, `(1)`), `number_prefix` (literal text before it, `POINT `), `label_box` (the label in a box that wide, the title's later lines hung under it; Word a tab to the hanging indent; without a `label_box` a `hang` over 0 is the box; a boxed label needs a left-aligned heading), `label_line` (the label on a line of its own); otherwise the label, a space, the title; a heading steps its level's count, drops the deeper ones and counts a skipped level 1 (typst's heading counter, counted by the model in every engine); a numbered heading's contents row carries the label, in its `label_box`, else label, space, text |
| `cover`, `front`, `closing: [block, ..]` | the cover page (before the tables, or before the body when there are none: with `page_number.front` the cover is unnumbered on every page it runs to and the body numbered from 1 in every engine), the top of page 1 of the body, after the body |
| `before_tables: [block, ..]`, `body_before_tables: {count | until | marker}` | pages between the cover and the tables, numbered with them (`page_number.front`: i, ii, ..): the layout's blocks (a disclosure statement, a flyleaf; a page's own, a fill allowed), then the body's first sections: `count: N` level-1 sections (and any text before the first), `until: <text>` the sections before the first level-1 heading that starts with it, or `marker: <text>` the text before a line that is that text alone (dropped; literal, `"{{contents}}"`); a count or heading may read a field (`"{before_toc}"`, `"{body_start}"`), a missing one sets nothing there. Each part ends its page; the contents list their headings with their roman pages; Word's tables section starts at their first line |
| `between_tables: [block, ..]`, `body_before_tables: {.., place: between}` | between the contents and the authorities, numbered with them: the layout's blocks (a compliance statement, NMRA 12-318), then the body sections set before the tables when `place: between` (the issues, Conn. PB 67-4; the points on appeal, Ark. R. 4-2(a)); the contents list their headings in that order |
| `contents: {title, depth, col, hang, step, above, when, break}` | (`when: <field>`: only when that frontmatter field is set; `break: false`: on the cover's page, after it, its title with its heading's space above; not with `page_number.front`) a row per heading: the text wraps before a page column `col`, `hang` under its first line, `step` per level; a leader from three spaces after it |
| `authorities: {title, col, hang, above, group}` | from the frontmatter's `authorities: [{heading, entries: [{cite, find or finds: [..]}]}]`: every `find` in the body and its notes marks a page; the page list is the column when wider; keyed authorities, the frontmatter's `authorities: {key: {kind, name, cite, sort}}` with `kinds: [{kind, title, italic}]` (the groups in order), `passim` (a list of that many pages or more is *passim*) and `page_heading` (on the first group's line, at the right): each `[text](toa:key)` link in the body and its notes marks a page after its first word (a link to a key the frontmatter lacks stops the render); the cited entries of each group sorted by `sort`, else name and citation (lower case, letters, digits and spaces), then key; a group's `italic` sets the name in italics before the citation, else name, comma, citation |
| `tail: {at, break, pitch, indent, gap, above}` | the body from the level-1 heading that starts with `at` (certificates) set after the closing |
| `after_tail: [block, ..]` | blocks set after the tail (the closing split around a body part: a certificate after an appendix); a text block with `heading: <level>` (in any page's own blocks) is a heading of that level: its style, kept with what follows, bookmarked and listed in the contents in document order, never numbered (a certificate's title) |
| `keep_with_closing: true` | the body's last paragraph, unless it calls a footnote, kept whole and on the page of the closing's first block (typst a sticky unbreakable block, LaTeX no break in it or after it, Word Body Text Keep: keep lines, keep with next, and the spacer before a closing table kept too) |
| `words: {from, through, exclude, limit}` | `{xd.words}` in any text block: the words of the sample's body as the court's template counted them (whitespace-delimited, the markdown's markers, link targets and footnote marks not counted, headings, quotations and called footnotes counted; lib/typst/xdoc.typ `count-words`, lib/pandoc/xdoc.lua `count_words`, the same steps, the same count on all 1191 INPUTs of the repo), digits grouped ("11,942"): the body up to the tail, its level-1 sections from the one whose heading starts with `from` through `through`, less `exclude`; over `limit` the render stops in every engine |

Blocks: `{text: "Case No. {case_number}", ..style}` (one paragraph; `{markdown: "{field}", ..style, gap}` a frontmatter text of several paragraphs, split at its blank lines (a certificate, an order), `gap` between them; `"{field}"` alone with a list gives one per item; `<br>` or a newline in a value starts a line (a YAML block scalar's last newline dropped); an empty paragraph is a line of its pitch in every engine; no line breaks at a space before a closing mark, `. , : ; ! ? ) ] }` (a spaced ellipsis ". . ." stays with the word before it: typst by Unicode LB13, LaTeX `\nobreakspace`, Word a no-break space); a URL (http://, https://, www.) breaks only after a slash not followed by another (after `https://`, not inside it), a dot before an ASCII letter or digit, a hyphen before a letter, or a "?" or "!" before a letter or digit, in every engine (typst boxes its pieces, LaTeX `\allowbreak`, Word a zero-width space); `optional`: no paragraph when a field is missing or ""; `{field|text}` prints the text when the field is missing, e.g. a blank `{service.date|____________}`; `{body_words}`, computed: the words of the body before the tail, split at white space, a word holding an ASCII letter or digit (`words` below counts as a court template does)), `{rule: <stroke>}`, `{columns: [{width, valign, blocks}, ..], gutter}` (a column `{width, repeat: ")", <style>}` sets its text once a line, as many lines as the tallest other column of the row is high at its pitch: a column of ")" or "§" beside a caption; typst measures the other cells, LaTeX their boxes, Word the bookmarks LibreOffice exports at their first and last lines) or `{columns: {each: <list>, per_row, row_gap, blocks}}`, `{each: <list>, blocks, between}` (an item's fields, `{.}` and `{#}`, its number from 1; a path may index a list from 0: `{signature.lines.0}`; a frontmatter string that starts like a list item or heading, "1. ", "- ", "# ", "> ", is literal text), `{group: [..]}` (never split), `{when: <field>, blocks}` and `{unless: <field>, blocks}` (the blocks when the field is set, or not: false, "" and an empty list are not set; `default:` the value of a field the frontmatter lacks; `is: <value>`: set when the field is that value, compared as text), `{break: true}`, `{box: [..], width, height, stroke, inset, valign}` (a ruled box: its blocks `inset` from its edges, `stroke` on its sides, each one number or `{top, right, bottom, left}`; the container's width unless `width`; a fixed `height` when given; the blocks at `valign` top, center or bottom: typst a stroked block, LaTeX a ruled `\vbox`, Word a one-cell table with borders, cell margins and an exact row height; a "court use only" area, a caption column ruled at its side), `{fill: <weight>}` (in a page's own blocks: the cover, or `front` and `closing` before a `{break: true}`; the space the page leaves, shared among its fills by weight, the blocks next to a fill without their space toward it: typst `v(1fr)`, LaTeX fill glue, Word a spacer whose height a pass measures). A style: `align`, `bold`, `italic`, `upper`, `underline`, `size`, `pitch` (`body`, `single` or points), `left`, `right`, `hang`, `indent`, `above`, `below`, `keep`. Space between two blocks is the larger of the one's `below` and the other's `above`; the first block of a container (a column, a group, the cover) sets its `above` as explicit space (typst drops a block's space there; LaTeX and Word keep it).

**Pages.** typst queries its marks; LaTeX writes them to the `.aux` (`lib/latex/xdoc.sty`: `\xd@hmark`, `\xd@amark`; fb render runs pdflatex until `doc.aux` settles); Word cannot know a page, so `lib/docx/xdoc.lua` writes a needle per heading and per authority mark in document order (docxpages.rs), declares where each numbering starts (`#section`), and writes its own footers and last section (`$FORMBOOK_FOOTERS`, `$FORMBOOK_FINAL`); fb render runs the passes until the pages settle (docxpass.rs). A fill is measured the same way: position needles (kinds `T` and `Y`) ask for the place of a line (`pdftotext -bbox-layout`), and the next pass sets each fill to its share of what the page leaves; the pages settle a pass later. A repeat column is measured by bookmarks: lib/docx/xdoc.lua bookmarks the first and last paragraphs of the row's other columns and writes destination needles (kind `D`); the measuring passes export them as named destinations (LibreOffice's `ExportBookmarksToPDFDestination`; the final PDF is converted as before), and docxpages.rs reads the top of each one's line from the PDF. fb render now gives the LaTeX filters `$FORMBOOK_META` too (the frontmatter as written).

**Pilot** (five typst-only folders from five families; typst moved onto the model, latex and docx generated, every page of the three renders looked at; `check.sh` with `params.cross_engine: gate`):

| folder | family (0.9) | engine | XENG-001..003 | tier 1 (check.sh) |
|---|---|---|---|---|
| `eighth-circuit/minnesota/state/court-of-appeals/motion-brief` (caption between rules, 10 pages) | 113 | typst | reference | 8 passed, 0 failed |
| | | latex | PASS (211/211 lines) | 11 passed, 0 failed |
| | | docx | PASS (211/211) | 12 passed, 0 failed |
| `first-circuit/maine/state/supreme-judicial-court/petition-for-writ` (signers side by side, nested lists, certificate tail, 12 pages) | 147 | typst | reference | 8 passed, 0 failed |
| | | latex | PASS (260/260) | 11 passed, 0 failed |
| | | docx | PASS (260/260) | 12 passed, 0 failed |
| `third-circuit/new-jersey/state/supreme-court/motion-brief` (letter brief, numbered from page 2, 8 pages) | 222 | typst | reference | 8 passed, 0 failed |
| | | latex | PASS (168/168) | 11 passed, 0 failed |
| | | docx | PASS (168/168) | 12 passed, 0 failed |
| `eighth-circuit/arkansas/state/court-of-appeals/amicus-brief` (cover, contents, authorities, notes double spaced, 12 pages) | 5 | typst | reference | 8 passed, 0 failed |
| | | latex | PASS (207/207) | 11 passed, 0 failed |
| | | docx | PASS (207/207) | 12 passed, 0 failed |
| `sixth-circuit/michigan/state/court-of-appeals/reply-brief` (unnumbered cover, tables i-ii, body from 1, service page, 9 pages) | 21 | typst | reference | 8 passed, 0 failed |
| | | latex | PASS (220/220) | 11 passed, 0 failed |
| | | docx | PASS (220/220) | 12 passed, 0 failed |

Tier 2, open: the Minnesota motion's signature block takes page 10 alone (the model keeps the closing whole but not with the last paragraph); the contents and authorities leaders of typst and LaTeX stop at the page column, Word's run to the number (as ca9). The typst renders changed with the move (exact pitches instead of em leadings): every tier-1 check was re-run on them.

**What the pilot found** (each a line or page the gate caught, fixed in the shared code):
- typst's `overhang` (on by default) hangs a final period into the margin: it moved a centered "v." 1.4 pt and lets a line hold more; the model sets `overhang: false`.
- LibreOffice moves the last word of a contents or authorities row to a new line unless about 0.325 em is left after the three-space lead (0.3232 to 0.3267 em, measured at 12 and 14 pt); typst's `table-row` and LaTeX's `\xd@row` keep the same room.
- A typst show rule that marks an authority's `find` inside a word ("MCL 15.243(1)(f)") split the word, and xengine's ")(" box then started a word of its own, a break LaTeX and Word do not have: the mark matches the whole word. A mark before a line's first word is set at the end of the line before (a page early): it goes after the word, in every engine.
- A contents row must not carry the heading's authority marks (LaTeX listed the contents page as a page of the authority).
- Typst drops a block's space above at the start of a container (a grid cell, a block): the model sets it there as explicit space, LaTeX as an empty rule and `\vskip` (which also keeps the cover's two inches at the top of the page), Word as the paragraph's space before.
- newtx sets a full line about 0.05 bp wider than Times New Roman: the generated LaTeX text block is 0.05 bp wider for that face (a line typst filled to 0.05 pt broke early).
- pandoc's `\ldots` is spaced dots, wider than the glyph: LaTeX sets three periods kerned to the face's ellipsis advance inside an `/ActualText` span, which `pdftotext` reads as "…".
- `\emph` and `\textbf` add an italic correction (0.7 pt on a line with two): the model writes font switches. `\underline` draws below the line box: a rule at the face's underline position.
- LibreOffice collapses a paragraph's space after with the next one's space before (the larger), as typst and `\addvspace` do; a table has none, so the space around it is an empty paragraph of exact height or the next paragraph's before; a cell ends in a paragraph (a nested table without one let LibreOffice split the row). After a page break Word keeps the space before; the model writes none there.
- A ZWSP after a slash at the start of a word ("/s/") split the word in the PDF text: the slash rule applies inside a word only ("CM/ECF").

**Faces.** `fb engines gen` sets a typst face in LaTeX with the package of the same metrics (gen.rs `latex_face`): newtx for Times New Roman and Liberation Serif, ebgaramond, gelasio, tgbonum for TeX Gyre Bonum and Bookman Old Style (TeX Live's Type 1 Bonum has the vendored font's advances in all four shapes, within 0.0005 em; the ellipsis \\xd@ellipsis at 1 em, its periods 0.32; Word a page list at Bonum's advances), ebgaramond with lining tabular figures for EB Garamond (then the vendored font's advances but a regular T, which the generated `latex_specials` sets in a box of 0.670 em, and the ellipsis, \\xd@glyph at 0.686, 0.746, 0.671, 0.764 em by shape; Word a page list at Garamond's advances), tgheros for Arial and Liberation Sans (TeX Gyre Heros, the advances of Liberation Sans in all four shapes, spaces included; on latex fb check accepts its embedded TeXGyreHeros for a declared Arial or Liberation Sans, as TeX Gyre Termes for Times), and tgschola for TeX Gyre Schola (Century Schoolbook), whose TeX Live Type 1 advances differ from the vendored 2.609 font's in sixteen glyphs: the generated template loads `lib/latex/xeschola.sty` (and graphicx), the generated `latex/xdoc.lua` carries `latex_glyphs: schola`, and lib/latex/xdoc.lua runs `lib/latex/xeschola.lua` over every text it writes (cover, headings, body, notes, quotations, lists, tables, closing; not the PDF bookmarks), the ellipsis `\xeglyph` at 860/1000 em; the generated `docx/xdoc.lua` carries the face's `face_advances` (digit, comma, space, hyphen) for the width of a page list. Characters newtx lacks in pdfLaTeX (an okina U+02BB, U+00B4, a minus U+2212, an arrow U+2192, a box bar U+2502; Times New Roman faces) are set as a Type 1 glyph of newtx (T1 or newtxmath's symbols, `txsys`, which fb check accepts as part of the face) centred in a box of Liberation Serif's advance in the current shape, the PDF text the character (lib/latex/xdoc.lua `TIMES_SPECIALS`, lib/latex/xdoc.sty `\xd@glyph`); the cross-engine diff joins a word LibreOffice's PDF text splits at such a character (it takes it from a fallback face).

**Pennsylvania Supreme Court fan-out** (fb-595.54.13: the nine doc folders of `third-circuit/pennsylvania/state/supreme-court`; the court root holds only filed examples, no template or INPUT, so it has nothing to port). Typst moved onto the model, latex and docx generated, every page of the three renders looked at; `check.sh` with `params.cross_engine: gate` (tier 1: 8 typst, 11 latex, 12 docx checks, DEF-COVER-001, DEF-TOC-001, DEF-FONT-002 among them, 0 failed in every row; a REPORTED check is not counted):

| folder | pages | latex XENG-001..003 | docx XENG-001..003 |
|---|---|---|---|
| `amicus-brief` (cover, contents, argument points numbered I., A., 1. by the template, 27 notes) | 27 | PASS (582/582) | REPORTED (552/582; pages equal): LibreOffice sets a note that does not fit under its anchor's line on the next page and keeps the line, typst and LaTeX move the line with it (page 16) |
| `answering-brief` (caption beside the proceeding, word count computed) | 45 | PASS (916/916) | PASS (916/916) |
| `brief-on-the-merits` (blank certificate dates the filer completes) | 77 | PASS (1554/1554) | PASS (1554/1554) |
| `motion-brief` (numbered points) | 35 | PASS (691/691) | PASS (691/691) |
| `petition-for-discretionary-review` | 27 | PASS (519/519) | PASS (519/519) |
| `petition-for-rehearing` (caption on page 1 as the filed application, no cover) | 5 | PASS (95/95) | PASS (95/95) |
| `petition-for-review` | 44 | REPORTED (860/864; pages and page ends equal): a line typst fills to 540.01 pt on a 540 pt measure, newtx 0.03 bp wider inside its 0.05 bp allowance (page 23) | PASS (864/864) |
| `petition-for-writ` (two-page cover, 61 notes, verification pages) | 70 | PASS (1450/1450) | REPORTED (1426/1450; pages equal): the note placement of the amicus brief (page 50) and a URL LibreOffice breaks inside "2024" (page 31) |
| `reply-brief` | 21 | PASS (412/412) | PASS (412/412) |

The three REPORTED pairs carry `params.cross_engine_<engine>: report` with the reason in the folder's `eval.yaml`; the folder gates its other engine. Tier 2 changes with the move: the amicus brief is double spaced at Word's double (32.2 pt; the old template's 1.15 em leading set about 25 pt), the briefs on the merits, for review and for allowance of appeal now carry the Rule 127 Public Access certificate (PA-CERT-001), the application for reargument follows its filed copy (the caption on page 1), and INPUT transcription defects were repaired where the readers disagreed on them (a doubled "v.", list items split at pdftotext line breaks, headings without a blank line before them, a quotation one line per paragraph, two ambiguous straight quotes).

**What the Pennsylvania fan-out found** (each fixed once, in the shared code; the five pilots re-run, all PASS):
- LibreOffice keeps 16.1 pt between the last line box of the text and the first footnote's (the note gap and 9.1 pt; measured with a one-line note under a page of text whose top margin moved 0.05 pt at a time, 12 and 14 pt notes, body pitches 24 and 32.2): the model's footnote `clearance` default is 9.1 (was 7.5, which left a line on a page LibreOffice moved on).
- typst splits a footnote over two pages, LaTeX never does (`\interfootnotelinepenalty`): typst sets a note unbreakable, Word's Footnote Text keeps its lines together. LibreOffice still sets a note that does not fit whole on the next page while the anchor line stays (no docx setting changes it): reported.
- A paragraph that anchors a footnote has no widow or orphan control in LaTeX and Word; typst kept its orphan control (a `show par` rule sees the note already realized): xdoc.typ sets `costs: (widow: 0%, orphan: 0%)` on cmarker's paragraph runs that hold a note.
- Long URLs broke three ways (typst after some slashes and dots, pdfTeX after hyphens only, LibreOffice after a slash before a letter). As merged with fb-595.54.82, the same rule (after each slash not followed by another, each dot before an ASCII letter or digit, each hyphen before a letter, each "?" or "!" before a letter or digit, where LibreOffice breaks by itself), and nowhere else in typst or LaTeX (typst boxes its pieces, LaTeX `\allowbreak`, Word a zero-width space; lib/pandoc/xdoc.lua `url_pieces`). The diff drops zero-width characters (U+200B, U+2060, U+FEFF) from words.
- pandoc reads "a.", "(1)", "(xxi)" as ordered lists, CommonMark (cmarker) only "1." and "1)": such a list is paragraphs with their markers as written, a tight one a single paragraph (`commonmark_lists`). pandoc needs a blank line before a heading, CommonMark does not (INPUTs fixed).
- typst breaks after a word-initial hyphen ("social -media"), LibreOffice follows Unicode 15.1 LB20a and does not: Word gets a zero-width space there. typst and LibreOffice break after an ellipsis a word follows ("…presents"), pdfTeX did not.
- A doubled section or pilcrow sign broke between its two signs in typst (xengine boxes one sign with its number): typst boxes "§§ n", LaTeX binds it as Word did.
- The docx page lookup found a heading's needle ("argument" + the next paragraph) again inside the needle before it ("summary of argument" + the same words): the search moves past a found needle's own text.
- A frontmatter value that starts like a block ("* Pro hac vice ...") is text in every engine (typst escaped its marker; pandoc printed its words); a LaTeX cover numbered apart is unnumbered on every page it runs to.

**Not yet in the model** (a folder that needs one of these is ported when it is added, in the shared code): Gelasio's advances in LaTeX and Word (`\textellipsis` until measured; gen.rs `face_advances`), pleading paper, list items that hold more than a paragraph and their nested lists, tables in the body, a page list too wide for its column set on a line of its own, contents and authorities under one title (points and authorities), a cover whose type size is chosen to fit, a cover with a top margin of its own, the table of contents on the cover or caption page, and the line-fit tolerance of Word and LaTeX at a line typst fills to within a few hundredths of a point (docs/open-items: the requests of each lane, with their folders).

**Recorded family gap (fb-595.54.33).** The Illinois Supreme Court's eight input-bearing folders under `courts/seventh-circuit/illinois/state/supreme-court/` share a cover with counsel after a page-filling `v(1fr)` and a three-column caption with a `)` separator. Both are in the unsupported list above. Do not generate engines from an approximate layout or set `params.cross_engine: gate` until the shared model can represent these blocks in Typst, LaTeX and DOCX; this family remains unported. The court root itself holds only exemplars and has no INPUT/template to port.

**Recorded family gap (fb-595.54.43).** The eight input-bearing folders under `courts/eighth-circuit/minnesota/state/supreme-court/` remain unported pending a decision on the rule-mandated cover top position and shared support for their cover-specific margin, flowing counsel columns, blank-line list items, post-signature blocks, and Markdown tables. The motion brief also exposes shared DOCX optional-block spacing, no-table cover, and `s/Name` signature-text differences. See `docs/open-items/fb-595.54.43.md` for the folder matrix and exact decision request. Do not generate approximate engines or set `params.cross_engine: gate`; the court root has no template or INPUT.

**Fan-out checklist (one folder).** Not for a folder with `docx/*.sh` (fb-595.68 step 2 owns it).
1. Read the folder's typst template and `rules.md`; render every INPUT on the current tree first and keep the PDFs.
2. Write `typst/layout.yaml`: every number of the old template, each with its rule; pitches as Word sets them (single = 1.15 x size for Times New Roman, double = 2 x single, 1.5 lines = 1.5 x single), every length a whole number of twips; the cover, front, closing and tail as blocks reading the sample's frontmatter as it is (no new fields; a court constant is literal text). Replace the template with the three lines above (keep its function name for `main.typ`; the face as `#let font-family`).
3. `fb render` typst; compare with step 1 page by page; fix the layout until it looks as professional as before and every tier-1 check passes (`check.sh --engine typst`).
4. `fb engines gen <folder>`; `fb render --engine latex` and `--engine docx` for every INPUT; `fb diff --engines` against typst. A difference is fixed in the layout when it is the folder's, in `lib/*/xdoc*` when it is the model's (re-run every pilot then); a block the model lacks is added to all three engines and to this section.
5. `params.cross_engine: gate` in the folder's `eval.yaml` once latex and docx pass XENG-001..003 on every INPUT; `check.sh` on all three engines, 0 failed; look at every page of the three renders; `fb engines gen --check`.

**Recommended fan-out.** By court, largest family first (one court's doc types share a layout: write one `layout.yaml` and copy it with the doc type's own blocks), in the order of the 0.9 families above: the California courts of appeal (24), Colorado and Utah (18; the ruled case-number box is `{box}`), Georgia, Kansas, Oklahoma and Texas (14), Idaho, Montana and the Northern Mariana Islands (13), then the 9- to 12-folder courts; one bead per circuit group as for phase 2, each starting with the gaps above that its folders need (Schola for the courts that set Century Schoolbook, `v(1fr)` covers, the ruled box). The 121 one-folder families cost the same per folder as the large ones once the vocabulary covers them.

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
| `fb engines families [--threshold T] [--json FILE]`, `fb engines gen <doc-dir>... [--check]` | The state templates clustered into families; the latex and docx engines of a folder on the shared document model, written (or checked) from its `typst/layout.yaml` and face ("Generated engines" above). |
| `tools/check-selftest.sh <court-dir>` | Mutation test of the checker. |
| `tools/check/*.awk`, `tools/check/lib.sh` | The checks. Dependencies: gawk, yq (mikefarah), jq, typst, poppler (`pdfinfo pdffonts pdftotext pdftohtml pdfimages`), `shasum`; latex: pandoc, pdflatex (TeX Live 2025), or tectonic or xelatex; docx: pandoc, LibreOffice (`soffice`), unzip, xmllint. |

## Replacing the shell checker with a Rust validator

The driver (`tools/check.sh`, a thin wrapper around `fb check` in `tools/fb`) is Rust: argument parsing, calibration, per-sample preparation, check ordering, SKIP/PASS/FAIL output and stamps. Verdicts for `g0_content`, `g0_italics`, `g0_footnotes`, `page_size` and `page_limit` are evaluated natively in Rust. Other `chk_<method>` verdicts still use the compatibility bridge into `tools/check/lib.sh`; remove that bridge only after every method is native and parity passes. The contract the Rust validator must honor:

- **Input**: `<court-dir>/checks.yaml` (samples, parameters, form wording, the check list), the sample markdown with its YAML frontmatter, the rendered PDF, `court.json`, and `reviews/*.md`. Nothing else.
- **Output**: for each check, in the order listed, `PASS`/`FAIL` with the requirement ID, the measured value, the expected value, the failing instances, and `template-file:line` found by searching `fix.anchor` in `template`. Exit status 0 iff no check fails.
- **Semantics that are part of the contract**: the normal form of Gate 0 (lower case, straight quotes, ligatures expanded, all whitespace removed, dot leaders of four or more dots reduced to four); the footnote numbering rule (numbers follow the order of references in the body); headings placed before the block that follows them; word count by whitespace-delimited tokens, with list markers and footnote references not counted and everything after the `# Addendum` heading excluded; the `-v`-free parameters in `checks.yaml: params`; tolerances only where `checks.yaml` states them.
- **Parity test**: the Rust validator and the shell checks run by `tools/check.sh` (`tools/check/lib.sh`) must produce the same PASS/FAIL set on both samples and on every mutant in `tools/check-selftest.sh`. Delete the shell checker only when that holds.
- **What changes for the better**: exact PDF object parsing (real font names and sizes per glyph, real italic flags, link annotations) instead of poppler's word rectangles, which lets several calibrations here (the height of a 14 pt word, the footer position) become direct measurements. It must not change what is checked.
- **Engines and stamps**: the validator takes the same `--engine` flag, checks `OUTPUT-<id>.latex.pdf` / `.docx.pdf` for the other engines, honors `engines:` in `checks.yaml`, and writes and removes `usage/.check-<engine>.txt` exactly as `tools/check.sh` does (the tracker reads it).
