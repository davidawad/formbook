# dcd: complaint

Doc type: **complaint** in the United States District Court for the District of Columbia (`dcd`).
Folder: `courts/dc-circuit/district-of-columbia/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-terre-du-soleil-1-26-cv-03510-complaint.pdf` (one filer, see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-terre-du-soleil-complaint.md`: caption, lead-in, allegations 1 to 38 (exemplar pages 1 to 10) and the last two allegations 87 and 88 (exemplar page 27), prayer for relief and signature block |
| render | ok: `samples/OUTPUT-terre-du-soleil-complaint.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-terre-du-soleil-complaint.pdf` and `OVERLAY-terre-du-soleil-complaint.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

File names: the render and overlay names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`), not the `<id>.pdf` and `<id>-overlay.pdf` names in the task brief. The tools are shared and were not edited.

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.1(c)(1) (D.D.C.) | The first filing shows in the caption the name and full residence address of each party (official address for an official-capacity defendant). Every attorney-signed document carries the attorney's name, address, telephone number and D.C. Bar identification number. | Party names and addresses in `caption.parties[].names` (the sample transcribes the filed addresses). Attorney block in `signature` (name with bar number, firm, address, telephone, email, role). |
| LCvR 5.1(d) | Typed double-spaced on 8 1/2 by 11 inch paper; a heading under the caption naming the document; the case number followed by the judge's initials once assigned; **all pleadings in 12-pt type, double-spaced; footnotes 12-pt**. | `type-size = 12pt`, `body-leading = 1.35em` (24 pt pitch), `page-w`/`page-h`, `Civil Action No.` in the caption (blank until a judge is assigned; the template prints the initials from `case_number` when set). |
| LCvR 5.1(e) | No attachment to a complaint that is not essential to the action. | Author content. The template does not check attachments. |
| (none) | The D.D.C. local rules do not require numbered pleading lines or line-numbered paper. | No line numbers, rules or footer title in this template (contrast the CAND complaint). |
| Typeface (LCvR 5.1(d), no face named) | Rule names only "12-pt. font" and double spacing; no typeface is required. | `font-family = "EB Garamond"` in `typst/dcd-complaint.typ`: no court-named face, so the default face under `docs/FONTS.md` (no substitution). Checked against the April 2017 text of LCvR 5.1(d). |
| Fed. R. Civ. P. 10(a) | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation. The complaint's title names all the parties. | `court-title()` (court name is the template's constant), `caption()`, `brief_title`. The sample's title names the parties in the caption block. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each blank-line-separated paragraph is numbered 1, 2, ... by the template; headings and `>` lines are unnumbered. |
| Fed. R. Civ. P. 8(a) | A short and plain statement of the grounds for jurisdiction, the claim, and the relief sought. | Author content. The template does not check it. |

Sources: the D.D.C. Local Civil Rules at https://www.dcd.uscourts.gov/sites/dcd/files/LocalRulesApril2017.pdf (the April 2017 edition, the most recent edition the court site served to this box; **the current edition was not confirmed**, see Known gaps 1); FRCP 10 at https://www.law.cornell.edu/rules/frcp/rule_10 (quoted text confirmed 2026-10-14).

Not produced by this template (separate filings that may be required with a first filing): the civil cover sheet (JS-44), the LCvR 7.1 corporate disclosure statement, the summons, and any LCvR 5.4 privacy redaction.

## Layout

- US Letter, 1-inch margins on all sides (a convention; LCvR 5.1(d) names no margin size).
- Court title centered and bold on lines 1 to 2; the caption is a two-column table: parties (left, closed by a rule on the right and bottom) and the case number and title (right). Party addresses are part of the party block.
- The cover and the first body paragraph share page 1, as in the filed exemplar (no page break after the caption).
- Body double-spaced at a 24 pt pitch. Blocks (paragraphs, headings, the lead-in) are full-width and breakable; the gap between blocks is the leading again, so every block keeps the pitch (see the `set block(spacing: ...)` note in the template).
- Headings: level 1 centered bold caps; level 2 centered bold; level 3 bold, left. A heading stays with the text after it.
- Paragraphs: numbered by the template, first-line indent 0.5 inch.
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
3. **Font.** LCvR 5.1(d) names no typeface, so the template keeps EB Garamond. The exemplar is Times New Roman; `docs/FONTS.md` maps Times to Liberation Serif (metric-compatible). Choosing Liberation Serif to match the exemplar's convention is a decision for David; it is not made here. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar. The 12-pt minimum is met by the font size; visual size is a tier-2 difference.
4. **Table of contents and table of authorities.** Complaints have neither in the exemplar; none is generated. (The motion-brief template has a TOC.)
5. **Sample coverage.** The sample is pages 1 to 10 and 27 to 29 of the 29-page exemplar: allegations 1 to 38, then allegations 87 and 88, the prayer, and the signature block. Pages 11 to 26 are not transcribed, so allegations 39 to 86 are missing. The exemplar's summons notice on page 29 is not transcribed. The template renumbers the sample's allegations 1 to 40, so the sample's 39 and 40 are the filed 87 and 88.
6. **Stray glyph in the exemplar.** The filed text has a stray "O." at the start of paragraph 35 (on exemplar page 8). It is transcribed as printed.
7. **Caption.** The sample's party block is closed by a rule on its right and bottom, not the column of ")" marks used by some filers. This is a tier-2 convention choice (accepted; both forms appear in D.D.C. filings).
8. **Footnotes.** Not supported by the template; LCvR 5.1(d) requires 12-pt footnotes, which the template would need to add if a sample used them.
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification is not asserted; this is a tier-2/3 choice.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. The brief forbids touching `tools/`, so the gates were not run. Render and overlay were run; the page review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (current PDF, 11 pages)

Rendered with `pdftoppm -r 60` and viewed page by page.

- Page 1: court title, caption (party block with addresses, case number, title), lead-in, heading "I. NATURE OF THE ACTION", paragraphs 1 and 2. No overlap. Pass.
- Page 2: paragraphs 3 to 6 (the paragraph flow across the page). Pass.
- Page 3: paragraphs 7 to 11, heading "II. JURISDICTION AND VENUE" centered bold. Pass.
- Page 4: paragraphs 12 to 17, heading "III. PARTIES" centered bold. Pass.
- Page 5: paragraphs 18 to 25, heading "IV. FACTUAL ALLEGATIONS". Pass.
- Page 6: paragraphs 26 to 30. Pass.
- Page 7: paragraphs 31 to 33. Pass.
- Page 8: paragraphs 34 to 36; the bottom of the page is blank, and paragraph 37 starts on page 9. Pass (layout).
- Page 9: paragraphs 37 to 40, heading "PRAYER FOR RELIEF" centered bold, "WHEREFORE" unnumbered, items A to B. Pass.
- Page 10: items C to F, with the items spaced at one pitch. Pass.
- Page 11: items G to I, "Dated", "Respectfully submitted,", the signature line, and the counsel block (name with D.C. Bar number, firm, address, telephone, email, role). No spill onto a page without text. Pass.

Defects found during review and fixed in the template (before the final render): paragraph lines overlapping the previous paragraph (the typst leading is between lines only, so a block ends one leading short; fixed by a block gap equal to the body leading); headings overlapping the lead-in (same cause).
