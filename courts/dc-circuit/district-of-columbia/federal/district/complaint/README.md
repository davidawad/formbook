# dcd: complaint

Doc type: **complaint** in the United States District Court for the District of Columbia (`dcd`).
Folder: `courts/dc-circuit/district-of-columbia/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: caption, lead-in, allegations 1 to 38 (exemplar pages 1 to 10) and the last two allegations 87 and 88 (exemplar page 27), prayer for relief and signature block |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 13 pages, typst 0.15.0, vendored Times New Roman only, no warnings |
| overlay | ok: `usage/OVERLAY-terre-du-soleil-complaint.pdf` and `OVERLAY-terre-du-soleil-complaint.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

File names: the render and overlay names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`), not the `<id>.pdf` and `<id>-overlay.pdf` names in the task brief. The tools are shared and were not edited.

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.1(c)(1) (D.D.C.) | The first filing shows in the caption the name and full residence address of each party (official address for an official-capacity defendant). Every attorney-signed document carries the attorney's name, address, telephone number and D.C. Bar identification number. | Party names and addresses in `caption.parties[].names` (the sample transcribes the filed addresses). Attorney block in `signature` (name with bar number, firm, address, telephone, email, role). |
| LCvR 5.1(d) | Typed double-spaced on 8 1/2 by 11 inch paper; a heading under the caption naming the document; the case number followed by the judge's initials once assigned; **all pleadings in 12-pt type, double-spaced; footnotes 12-pt**. | `type-size = 12pt`, `pitch-double = 27.6pt` (Word's double spacing in this face), `page-w`/`page-h`, `Civil Action No.` in the caption (blank until a judge is assigned; the template prints the initials from `case_number` when set). |
| LCvR 5.1(e) | No attachment to a complaint that is not essential to the action. | Author content. The template does not check attachments. |
| (none) | The D.D.C. local rules do not require numbered pleading lines or line-numbered paper. | No line numbers, rules or footer title in this template (contrast the CAND complaint). |
| Typeface (LCvR 5.1(d), no face named) | Rule names only "12-pt. font" and double spacing; no typeface is required. | `font-family = ("Times New Roman", "Liberation Serif")` in `typst/dcd-complaint.typ`: no court-named face, so the house standard (fb-9fyu), the face of both filed exemplars; the docx takes the same face (`{font}` in `docx/reference.xml`). Checked against the April 2017 text of LCvR 5.1(d). |
| Fed. R. Civ. P. 10(a) | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation. The complaint's title names all the parties. | `court-title()` (court name is the template's constant), `caption()`, `brief_title`. The sample's title names the parties in the caption block. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each blank-line-separated paragraph is numbered 1, 2, ... by the template; headings and `>` lines are unnumbered. |
| Fed. R. Civ. P. 8(a) | A short and plain statement of the grounds for jurisdiction, the claim, and the relief sought. | Author content. The template does not check it. |

Sources: the D.D.C. Local Civil Rules at https://www.dcd.uscourts.gov/sites/dcd/files/LocalRulesApril2017.pdf (the April 2017 edition, the most recent edition the court site served to this box; **the current edition was not confirmed**, see Known gaps 1); FRCP 10 at https://www.law.cornell.edu/rules/frcp/rule_10 (quoted text confirmed 2026-10-14).

Not produced by this template (separate filings that may be required with a first filing): the civil cover sheet (JS-44), the LCvR 7.1 corporate disclosure statement, the summons, and any LCvR 5.4 privacy redaction.

## Layout

- US Letter, 1-inch margins on all sides (a convention; LCvR 5.1(d) names no margin size).
- Court title centered and bold on lines 1 to 2; the caption is a two-column table: parties (left, closed by a rule on the right and bottom) and the case number and title (right). Party addresses are part of the party block.
- The cover and the first body paragraph share page 1, as in the filed exemplar (no page break after the caption).
- Body double-spaced at a 27.6 pt pitch (Word's double spacing for 12-pt Times New Roman, as in both filed exemplars); the court title, caption and signature block single-spaced at 13.8 pt. Every line is a box of its pitch (the cross-engine layout model, `lib/typst/xengine.typ`); spaces between blocks are explicit.
- Headings: 12 pt at the body pitch; level 1 centered bold caps; level 2 centered bold; level 3 bold, left. A heading stays with the text after it.
- Paragraphs: numbered by the template, the number at the margin in a 0.5-inch box (as in the exemplars); unnumbered paragraphs indented 0.5 inch.
- Prayer items: markdown list items (`1.` ...) are lettered `A.`, `B.`, ... as in the filed exemplar. A `>` line is an unnumbered paragraph (the "WHEREFORE" lead-in).
- Signature block: "Dated" on the left; "Respectfully submitted," and the signature line on the right, then the signer (name and D.C. Bar number), firm, address, telephone, email, and the role line.
- Page numbers, centered, arabic, on every page including page 1.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading, a list (`1.` items, lettered by the template), a `>` unnumbered paragraph, or a paragraph (numbered by the template).
- Frontmatter: `case_number` (blank until assigned; the template prints a blank line), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title` (not used by this template), `jury_demand` (optional), `lead_in` (unnumbered first paragraph), `date`, `signature` (`signer`, `firm` lines, `role`).
- The sample must not number its paragraphs in the text: the template numbers them. The sample's paragraph numbers are dropped on transcription.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **Rules edition.** The local rules fetched are the April 2017 edition (`LocalRulesApril2017.pdf`), the most recent the court site served to this box. A newer edition may exist; the LCvR 5.1(c) and (d) text should be checked against the current edition before this template is treated as final. Recorded for David.
2. **One exemplar.** The brief asks for 2 or 3 filers for tier 2. The search (CourtListener RECAP, `court=dcd`, complaints filed 2026-10-01 to 2026-10-13) found *McWilliams Ballard, Inc. v. 1128 Tenth Street NW, LLC*, 1:26-cv-03533 (5 pages) and others; only *Terre du Soleil* was downloaded and transcribed. Tier 2 is therefore judged against one filer.
3. **Font.** LCvR 5.1(d) names no typeface. Times New Roman (the house standard, and the face of both exemplars) on every engine since fb-595.68.6.
4. **Table of contents and table of authorities.** Complaints have neither in the exemplar; none is generated. (The motion-brief template has a TOC.)
5. **Sample coverage.** The sample is pages 1 to 10 and 27 to 29 of the 29-page exemplar: allegations 1 to 38, then allegations 87 and 88, the prayer, and the signature block. Pages 11 to 26 are not transcribed, so allegations 39 to 86 are missing. The exemplar's summons notice on page 29 is not transcribed. The template renumbers the sample's allegations 1 to 40, so the sample's 39 and 40 are the filed 87 and 88.
6. **Stray glyph in the exemplar.** The filed text has a stray "O." at the start of paragraph 35 (on exemplar page 8). It is transcribed as printed.
7. **Caption.** The sample's party block is closed by a rule on its right and bottom, not the column of ")" marks used by some filers. This is a tier-2 convention choice (accepted; both forms appear in D.D.C. filings).
8. **Footnotes.** Not supported by the template; LCvR 5.1(d) requires 12-pt footnotes, which the template would need to add if a sample used them.
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification is not asserted; this is a tier-2/3 choice.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. The brief forbids touching `tools/`, so the gates were not run. Render and overlay were run; the page review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (fb-595.68.6, 13 pages per engine)

Rendered with `pdftoppm -r 40`; every page of the typst render and of the docx render viewed side by side after the
last template change.

- Page 1: court title (two single lines), caption (party block with addresses closed by a rule on the right and bottom; case number and title at the right), lead-in, heading "I. NATURE OF THE ACTION", paragraphs 1 and 2. Pass on both engines.
- Pages 2 to 10: numbered paragraphs 3 to 36 at the double pitch, headings II to IV centered bold; no overlap, no heading at a page foot. Pass on both.
- Page 11: paragraphs 37 to 40, "PRAYER FOR RELIEF", the unnumbered "WHEREFORE" paragraph. Pass on both.
- Page 12: prayer items A to E, the letter at 0.5 inch and the text hanging at 1 inch. Pass on both.
- Page 13: items F to I, "Dated", "Respectfully submitted,", the signature line and the counsel block. Pass on both.

## Engines

The typst template (`typst/`) is the reference. The docx engine is `docx/`: `reference.xml` (the cross-engine style
recipe, `base="xengine"`, in the typst face) and `complaint.lua`; `fb render` builds the reference document and runs
pandoc (no shell script, fb-595.68). Both engines sit on the cross-engine layout model (`lib/typst/xengine.typ`,
`lib/docx/xengine.lua`): every line in a box of its pitch (27.6 pt body, 13.8 pt single), first-fit ragged-right line
breaking, no kerning, ligatures or hyphenation. The docx filter adds typst's break rules that LibreOffice lacks (a word
joiner in ")(", a zero-width space after a slash before a letter).

- **Gate 4:** `params.cross_engine: gate` (`eval.yaml`): XENG-001..003 pass, the docx breaks every line and page as the typst render (13 pages).
- **docx BLOCKED items:** none.
- **Not verified:** the `.docx` has not been opened in Microsoft Word (none here); it converts without error in LibreOffice (DEF-DOCX-OPEN).
- **No latex template** in this folder.
