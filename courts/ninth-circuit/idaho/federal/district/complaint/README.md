# idd: complaint

Doc type: **complaint** (FRCP 8 and 10 pleading) in the United States District Court for the District of Idaho (`idd`).
Folder: `courts/ninth-circuit/idaho/federal/district/complaint/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-tarazona-castro-1-26-cv-00521-complaint.pdf` (primary) and `exemplars/FILED-EXAMPLE-wilcox-1-26-cv-00443-complaint.pdf` (second filer). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-tarazona-castro-complaint.md` (excerpts of the 19-page filing; the parties, the facts, Counts I to III, the prayer, the jury demand and the signature; see Known gaps) |
| render | ok: `samples/OUTPUT-tarazona-castro-complaint.pdf`, 9 pages, letter, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-tarazona-castro-complaint.pdf` and `samples/OVERLAY-tarazona-castro-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |

## Commands

```
sh tools/render.sh courts/ninth-circuit/idaho/federal/district/complaint samples/INPUT-tarazona-castro-complaint.md
sh tools/overlay.sh courts/ninth-circuit/idaho/federal/district/complaint tarazona-castro-complaint \
  courts/ninth-circuit/idaho/federal/district/complaint/exemplars/FILED-EXAMPLE-tarazona-castro-1-26-cv-00521-complaint.pdf
```

File names follow the tools, not the brief's shorthand: `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf` and `.txt`. The sample is `INPUT-<id>.md` and the id is `tarazona-castro-complaint`. `tools/` is not edited.

## Governing rules

Primary source: the District of Idaho's Local Civil Rules, the print packet from https://idd.uscourts.gov/district/forms_fees_rules/Civil_Rules.cfm?lni=214 (the packet's cover reads "Revised and adopted August 17, 2026"; General Order No. 479, adopted August 17, 2026, amended Rules 9.1, 9.2, 16.4 and 37.1, none of them the form rules below). Fetched 2026-10-14. Rule text quoted from that packet.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Dist. Idaho Loc. Civ. R. 5.2(a) | 8½ × 11 inch paper; "plainly typewritten"; "double-spaced, except for quoted material and footnotes"; "Each page must be numbered consecutively"; top, bottom and side margins "at least one inch"; "the font or typeface for all text, including footnotes, must be at least 12 point." | `page-w`/`page-h`, `margin = 1in`, `type-size = 12pt` (footer included), `body-leading` (24 pt pitch), footer `N - TITLE`. |
| Dist. Idaho Loc. Civ. R. 5.2(b) | Upper-left counsel block: attorney name, e-mail, State Bar number, office address, telephone, fax, and the party represented. | `counsel` frontmatter. The template does not check that each item is present. |
| Dist. Idaho Loc. Civ. R. 5.2(b) | "commencing four inches below the top of the first page, (except where additional space is required for identification)" the caption, with the court title. | `cover()`: the caption starts at `caption-top = 4in`; counsel that needs more room pushes it down (`calc.max`). |
| Dist. Idaho Loc. Civ. R. 5.2(b)(1)–(3) | The court title; the title of the action; the CM/ECF file number (division, year, civil, number, judge initials). | `caption.court`, `caption.parties`, `case_number` (for example `1:26-cv-00521-DKG`). |
| Dist. Idaho Loc. Civ. R. 5.2(b)(5) | A title describing the pleading. | `brief_title`. |
| Dist. Idaho Loc. Civ. R. 38.1 | "a notation must be placed on the front page of the pleading, immediately following the title of the pleading, stating 'Demand For Jury Trial' or an equivalent statement." | `jury_demand: true` puts "DEMAND FOR JURY TRIAL" directly under the title in the caption. |
| Fed. R. Civ. P. 8, 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each paragraph; headings and lists are not numbered. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet, the Rule 7.1 disclosure statement, the summons, and any required certification of interested parties. The Local Civil Rules do not require pleading paper (numbered lines); the template uses none, and the exemplars use none.

## Layout

- Counsel block single-spaced in the upper left, from the top margin.
- Court title and caption on the page at four inches from the top, or, when the counsel block is longer, directly after it (the exemplar's counsel block is long, so the caption sits at about 4.4 inches; the rule's exception applies).
- Caption: party column closed by a right and bottom rule; the right column carries the CM/ECF file number, the title and the jury notation.
- Body double-spaced at a 24 pt baseline pitch. Each numbered paragraph has a 0.5 inch first-line indent. Headings fill whole 24 pt slots (`on-grid`), so the paragraph after a heading starts on the line grid without overlap.
- Prayer items are lettered (a), (b), ... by the template.
- Signature block: "DATED this ... day of ...", the firm, "/s/" and the signer, with the lines from the frontmatter.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered bold caps; `##` centered bold; `###` bold, left), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `counsel` (lines; an empty string is a line-high gap), `caption.court` (lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `jury_demand`, `lead_in` (optional, an unnumbered paragraph after the caption), `date`, `signature` (`firm`, `signer`, `lines`).
- Not supported: tables, footnotes (none used in the complaint), raw typst.
- The sample must not put the numbering in the text: the template numbers the paragraphs.

## What the overlay shows

`samples/OVERLAY-tarazona-castro-complaint.pdf`: red is our render, blue is the filed exemplar, black is agreement. The page map (`.txt`) pairs each of our pages with the exemplar page sharing the most words:

```
ours p.1  filed p.1  word-overlap 80.9%
ours p.2  filed p.2  word-overlap 68.0%
ours p.3  filed p.4  word-overlap 58.3%
ours p.4  filed p.6  word-overlap 66.0%
ours p.5  filed p.8  word-overlap 64.4%
ours p.6  filed p.9  word-overlap 63.5%
ours p.7  filed p.13  word-overlap 48.7%
ours p.8  filed p.14  word-overlap 41.5%
ours p.9  filed p.19  word-overlap 48.2%
```

The sample is an excerpt, and the page pairing is by words, so the lower overlap on pages 7 to 9 reflects the skipped middle of the filing, not a layout defect. The overlay is a diagnostic, not a score.

## Page review (Gate 2 equivalent)

Every page of `OUTPUT-tarazona-castro-complaint.pdf` was rendered at 60 dpi and viewed after the last template change.

| Page | Result |
|---|---|
| 1 | Counsel block upper left; court title and caption below it (the counsel block is longer than three inches, so the caption sits at about 4.4 inches, as the rule's exception allows); "DEMAND FOR JURY TRIAL" under the title; lead-in and paragraph 1 start on the page. Footer "1 - CLASS AND COLLECTIVE ACTION COMPLAINT". Pass. |
| 2 | Paragraphs 2 to 11, Jurisdiction and Venue heading (after paragraph 8). Pass. |
| 3 | Paragraphs 12 to 25; Parties heading; Factual Allegations heading before paragraph 23. Pass. |
| 4 | Paragraphs 26 to 37. Pass. |
| 5 | Paragraphs 38 to 47; FLSA Collective Action Allegations heading before paragraph 47. Pass. |
| 6 | Paragraphs 48 to 56 (56 continues onto page 7); Rule 23 Class Action Allegations heading before paragraph 55. Pass. |
| 7 | Paragraphs 57 to 66; Causes of Action heading and Count I. Pass (defect found and fixed: the Count headings overlapped the first paragraph under them; fixed by putting headings on whole 24 pt slots). |
| 8 | Count II (paragraphs 67 to 69), Count III (70 to 74), Prayer for Relief heading and items (a) to (d). Pass. |
| 9 | Prayer items (e) to (g); "DEMAND FOR JURY TRIAL" with paragraph 76; the date; the signature block ("/s/ DeAnne Casperson", "Attorneys for Plaintiff"). Pass. |

## Tier-2 findings (against the two filed exemplars, by page)

Compared with `FILED-EXAMPLE-tarazona-castro-…` and `FILED-EXAMPLE-wilcox-…`:

| Page | Finding | Status |
|---|---|---|
| 1 | The exemplars set the counsel block in a Times-style face, which reads larger than EB Garamond at 12 pt, so our text looks smaller. The 12-point minimum in LR 5.2(a) is met. The only vendored font is EB Garamond (`fonts/`); a Times-metric font would remove the difference. | OPEN (font choice for David; see Known gaps). |
| 1 | The caption's party column is closed by a rule, not the ")" column used in the Tarazona filing. The Wilcox complaint also uses the closed box. | ACCEPTED. |
| all | Footer carries "N - TITLE" on every page at 12 pt. Tarazona's footer is in the same form. | ACCEPTED. |
| all | No pleading-paper line numbers (the Wilcox and Tarazona filings have none). | ACCEPTED. |

## Known gaps and open choices

1. **Font (OPEN).** Only EB Garamond is vendored under `fonts/`. Times New Roman is not vendored and system fonts are banned. EB Garamond at 12 pt meets the rule's point size, but it looks smaller than the Times-style exemplars. Whether to vendor a Times-metric font is a decision for David.
2. **Counsel block content (not checked).** LR 5.2(b) lists seven items (name, e-mail, State Bar number, office address, telephone, fax, party represented). The template renders what the frontmatter lists and does not check that each item is there.
3. **Sample is an excerpt.** The sample carries the sections of the 19-page exemplar in condensed form: the Nature of the Action, Jurisdiction and Venue, Parties, the facts, the FLSA and Rule 23 allegations, Counts I to III, the prayer, the jury demand and the signature. Counts IV to VI and the rest of the class allegations are not transcribed. The sample's paragraphs are numbered 1 to 76 by the template; the filed paragraph numbers differ. The rendered sample is 9 pages.
4. **Second exemplar not transcribed.** The Wilcox complaint is saved and checked for layout on page 1 only; its content is not in the sample.
5. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder does not have that shape. The brief forbids touching `tools/`, so the gates were not run; the render, the overlay and the review above are the checks.
6. **Footers** are 12 pt, the same size as the text, to satisfy "all text" in LR 5.2(a).
7. **Caption position.** The caption starts at four inches when the counsel block is short enough. The Tarazona counsel block is long, so the caption sits lower (the rule's exception). The template does not warn when the counsel block pushes the caption down.
8. **Court title, e-mail and fax** are rendered as the frontmatter gives them; the template does not reformat them.
