# idd: complaint

Doc type: **complaint** (FRCP 8 and 10 pleading) in the United States District Court for the District of Idaho (`idd`).
Folder: `courts/ninth-circuit/idaho/federal/district/complaint/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (primary) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md` (excerpts of the 19-page filing; the parties, the facts, Counts I to III, the prayer, the jury demand and the signature; see Known gaps) |
| typeface | face required: none (LR 5.2(a) sets only a 12-point minimum, footnotes and footer included; checked on the Court's site 2026-10-15). Times New Roman 12 pt, the house standard (`docs/FONTS.md`), as the three Times-style exemplars; typst names `("Times New Roman", "Liberation Serif")`, the docx the same face through `{font}`. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx` / `.docx.pdf`, 12 pages each, letter, Times New Roman Regular and Bold embedded only, no warnings |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-<id>.pdf` from `usage/FILED-EXAMPLE-<id>.pdf` (not re-run for the cross-engine port) |
| pages reviewed | 12 of 12 on both engines (typst and docx.pdf, every page at 60 dpi, side by side, 2026-10-22, after the cross-engine port) |

## Commands

```
sh tools/render.sh courts/ninth-circuit/idaho/federal/district/complaint usage/INPUT-complaint.md
sh tools/render.sh --engine docx courts/ninth-circuit/idaho/federal/district/complaint usage/INPUT-complaint.md
sh tools/check.sh courts/ninth-circuit/idaho/federal/district/complaint [--engine docx]
just overlay courts/ninth-circuit/idaho/federal/district/complaint
```

## Governing rules

Primary source: the District of Idaho's Local Civil Rules, the print packet from https://idd.uscourts.gov/district/forms_fees_rules/Civil_Rules.cfm?lni=214 (the packet's cover reads "Revised and adopted August 17, 2026"; General Order No. 479, adopted August 17, 2026, amended Rules 9.1, 9.2, 16.4 and 37.1, none of them the form rules below). Fetched 2026-10-14. Rule text quoted from that packet.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Dist. Idaho Loc. Civ. R. 5.2(a) | 8½ × 11 inch paper; "plainly typewritten"; "double-spaced, except for quoted material and footnotes"; "Each page must be numbered consecutively"; top, bottom and side margins "at least one inch"; "the font or typeface for all text, including footnotes, must be at least 12 point." | `page-w`/`page-h`, `margin = 1in`, `type-size = 12pt` (footer included), `pitch-double` (27.6 pt, Word double spacing of 12 pt Times New Roman, as the exemplars), footer `N - TITLE`. |
| Dist. Idaho Loc. Civ. R. 5.2(b) | Upper-left counsel block: attorney name, e-mail, State Bar number, office address, telephone, fax, and the party represented. | `counsel` frontmatter. The template does not check that each item is present. |
| Dist. Idaho Loc. Civ. R. 5.2(b) | "commencing four inches below the top of the first page, (except where additional space is required for identification)" the caption, with the court title. | `cover()`: the caption starts at `caption-top = 4in`; counsel that needs more room pushes it down (`calc.max`). |
| Dist. Idaho Loc. Civ. R. 5.2(b)(1)–(3) | The court title; the title of the action; the CM/ECF file number (division, year, civil, number, judge initials). | `caption.court`, `caption.parties`, `case_number` (for example `1:26-cv-00521-DKG`). |
| Dist. Idaho Loc. Civ. R. 5.2(b)(5) | A title describing the pleading. | `brief_title`. |
| Dist. Idaho Loc. Civ. R. 38.1 | "a notation must be placed on the front page of the pleading, immediately following the title of the pleading, stating 'Demand For Jury Trial' or an equivalent statement." | `jury_demand: true` puts "DEMAND FOR JURY TRIAL" directly under the title in the caption. |
| Fed. R. Civ. P. 8, 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each paragraph; headings and lists are not numbered. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet, the Rule 7.1 disclosure statement, the summons, and any required certification of interested parties. The Local Civil Rules do not require pleading paper (numbered lines); the template uses none, and the exemplars use none.

## Layout

All of it on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does.

- Counsel block single-spaced (13.8 pt lines) in the upper left, from the top margin.
- Court title (bold, centered) and caption at four inches from the top, or, when the counsel block is longer, 12 pt below it (the exemplar's counsel block is long, so the caption sits lower; the rule's exception applies). The docx holds the counsel block in a table row at least 3 in high, with 12 pt after its last line.
- Caption: party column 3.25 in, closed by a right and bottom rule; the right column carries the CM/ECF file number, the title and the jury notation, a blank single line apart.
- Body double-spaced at a 27.6 pt pitch, no space between paragraphs. Each numbered paragraph: a 0.5 in first-line indent, the number in a 0.5 in box, the text. Headings on the same pitch, kept with the text after them.
- Prayer items are lettered (a), (b), ... by the template: the label at 0.5 in in a 0.5 in box, the text hanging after it.
- Signature block: "DATED this ... ." beside "Respectfully submitted,", the firm, "/s/" and the signer, with the lines from the frontmatter; kept on one page with the last paragraph.
- Footer: "N - TITLE" (the page number and `footer_title` in capitals), 12 pt, flush left, on every page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered bold caps; `##` centered bold; `###` bold, left), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `counsel` (lines; an empty string is a line-high gap), `caption.court` (lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `jury_demand`, `lead_in` (optional, an unnumbered paragraph after the caption), `date`, `signature` (`firm`, `signer`, `lines`).
- Not supported: tables, footnotes (none used in the complaint), raw typst.
- The sample must not put the numbering in the text: the template numbers the paragraphs.

## What the overlay shows

The page map below is from the earlier 9-page render (24 pt pitch), before the cross-engine port; `just overlay` regenerates it in `.overlay/` (not committed). The sample is an excerpt, and the page pairing is by words, so the overlap reflects the skipped middle of the filing, not a layout defect. The overlay is a diagnostic, not a score.

## Page review (Gate 2 equivalent)

Every page of `OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx.pdf` was rendered at 60 dpi and viewed side by side after the last template change (2026-10-22). The two engines break every line and page alike (XENG-001..003 PASS, 278/278 lines).

| Page | Result (typst and docx) |
|---|---|
| 1 | Counsel block upper left; court title and caption below it (the counsel block is longer than three inches, so the caption is pushed down, as the rule's exception allows); title and "DEMAND FOR JURY TRIAL" beside the party column; the lead-in. Footer "1 - CLASS AND COLLECTIVE ACTION COMPLAINT". Pass. |
| 2 | Nature of the Action heading, paragraphs 1 to 8. Pass. |
| 3 | Jurisdiction and Venue (9 to 12), Parties heading, 13 to 16. Pass. |
| 4 | Paragraphs 17 to 25; Factual Allegations heading before 23. Pass. |
| 5 | Paragraphs 26 to 33; two lines free at the foot (paragraph 34 moves whole: no orphan). Pass. |
| 6 | Paragraphs 34 to 42. Pass. |
| 7 | Paragraphs 43 to 48; FLSA Collective Action Allegations heading before 47. Pass. |
| 8 | Paragraphs 49 to 55; Rule 23 Class Action Allegations heading before 55. Pass. |
| 9 | Paragraphs 56 to 62; Causes of Action, Count I and its title. Pass. |
| 10 | Paragraphs 63 to 70; Count II and Count III with their titles. Pass. |
| 11 | Paragraphs 71 to 75; Prayer for Relief heading; items (a) to (e). Pass. |
| 12 | Items (f) and (g); "DEMAND FOR JURY TRIAL" with paragraph 76; the date and the signature block ("/s/ DeAnne Casperson", "Attorneys for Plaintiff"). Pass. |

## Tier-2 findings (against the two filed exemplars, by page)

Compared with `FILED-EXAMPLE-complaint.pdf` (Tarazona Castro) and `FILED-EXAMPLE-complaint-2.pdf` (Wilcox):

| Page | Finding | Status |
|---|---|---|
| all | Times New Roman 12 pt, double-spaced at 27.6 pt, as both exemplars (27.6 pt measured on their body pages). | ACCEPTED. |
| 1 | The caption's party column is closed by a rule, not the ")" column used in the Tarazona filing. The Wilcox complaint also uses the closed box. | ACCEPTED. |
| all | Footer carries "N - TITLE" on every page at 12 pt. Tarazona's footer is in the same form. | ACCEPTED. |
| all | No pleading-paper line numbers (the Wilcox and Tarazona filings have none). | ACCEPTED. |

## Known gaps and open choices

1. **Counsel block content (not checked).** LR 5.2(b) lists seven items (name, e-mail, State Bar number, office address, telephone, fax, party represented). The template renders what the frontmatter lists and does not check that each item is there.
2. **Sample is an excerpt.** The sample carries the sections of the 19-page exemplar in condensed form: the Nature of the Action, Jurisdiction and Venue, Parties, the facts, the FLSA and Rule 23 allegations, Counts I to III, the prayer, the jury demand and the signature. Counts IV to VI and the rest of the class allegations are not transcribed. The sample's paragraphs are numbered 1 to 76 by the template; the filed paragraph numbers differ. The rendered sample is 12 pages.
3. **Second exemplar not transcribed.** The Wilcox complaint is saved and checked for layout on page 1 only; its content is not in the sample.
4. **Footers** are 12 pt, the same size as the text, to satisfy "all text" in LR 5.2(a).
5. **Caption position.** The caption starts at four inches when the counsel block is short enough. The Tarazona counsel block is long, so the caption sits lower (the rule's exception). The template does not warn when the counsel block pushes the caption down.
6. **Court title, e-mail and fax** are rendered as the frontmatter gives them; the template does not reformat them.

## Engines

typst (`typst/idd-complaint.typ`, the reference) and docx (`docx/reference.xml`, `docx/idd-complaint.lua`); no latex. Both pass `tools/check.sh` with 0 failed; the docx passes XENG-001..003 and `eval.yaml` sets `params.cross_engine: gate`.

The docx (fb-595.68.23): `docx/reference.xml` is the cross-engine style recipe (`base="xengine"`) in the typst face (`{font}`), 12 pt, 27.6 pt body and heading lines, 13.8 pt single lines; `docx/idd-complaint.lua` writes every paragraph with its own exact spacing, the caption as a table (its left cell ruled right and below; the party text 0.75 pt less from the rule than in typst, since LibreOffice takes the rule's width from the cell), the counsel block as a table row at least 3 in high, and the footer "N - TITLE" with the last section through `fb render` (`$FORMBOOK_FOOTERS`, `$FORMBOOK_FINAL`). No shell and no binary reference document. Paragraph numbers are text, so they do not renumber if a paragraph is inserted by hand. Word may paginate slightly differently from LibreOffice (docs/DOCX.md).
