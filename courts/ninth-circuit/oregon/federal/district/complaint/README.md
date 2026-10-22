# ord: complaint

Doc type: **complaint** in the United States District Court for the District of Oregon (`ord`).
Folder: `courts/ninth-circuit/oregon/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: partial transcription, 8 rendered pages (see Known gaps) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages, typst 0.15.0, vendored Times New Roman only, no warnings; docx 9 pages, the same lines and pages (XENG-001..003 gated) |
| typeface | face required: none (LR 10-1 text read 2026-10-15 names no typeface; only the 12-pt minimum). Times New Roman (vendored; the house standard, and the face of both filed exemplars), 12 pt, in both engines (fb-595.68.24; was EB Garamond 13 pt in the docx). |
| overlay | **fail** this pass: `usage/SAMPLE-*.pdf` is not in this snapshot, so `tools/overlay.sh` could not run. The `usage/OVERLAY-kliewer-complaint.txt` on disk is from an earlier run; no `.pdf` is on disk. |
| pages reviewed | 8 of 8 this pass (every page rasterized at 60 dpi and viewed after the re-render) |
| check.sh / check-selftest.sh | not run: they expect a court root with `court.json` and `rules.md`, and this is a doc-type folder; the brief forbids touching `tools/` |

## Governing rules

Source for the local rules: the District of Oregon's Local Rules page, https://www.ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules/civil-procedure/1989-lr-10-form-of-pleadings-and-other-documents (the LR 10 text, with its amendment notes), fetched and read 2026-10-14. The page's quoted wording is used below. Its amendment notes run to September 3, 2024.

Caveat, read before relying on this: the court's current Local Rules index, fetched 2026-10-14 from https://www.ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules, lists the civil rules as "LR 10 - Form of Pleadings and Other Documents" without subsections, and says changes "will have an expected effective date of December 1, 2026" (the only redline on that page is LR 16). The subsection numbers used here (10-1, 10-2) come from the page above and have **not** been checked against a codified 2026 text. Confirm the numbering and wording before the template is called final.

| Rule | Requirement (as quoted or paraphrased from the source) | Where it lives in the template |
|---|---|---|
| LR 10-1(a) | Typewritten, neatly printed or legibly reproduced, blue or black ink. | Output is black type on white paper. |
| LR 10-1(b) | "Documents must be double-spaced, except for counsel identification, the case title, footnotes, quotations, and exhibits." | `pitch-body = 24pt` (27 lines per page); the exempt blocks at `pitch-single = 13.8pt`. |
| LR 10-1(c) | "Typewritten materials, including footnotes and endnotes, must use no smaller than a 12-point font." | `type-size = 12pt`, the footer too. See Known gap 5. |
| LR 10-1(d) | "Pleadings and other documents must have one inch margins on the top, bottom, left, and right sides." Pages must not be numbered down the left margin (deposition-transcript exhibits excepted). | `margin = 1in` on all sides; no line numbers. See Known gap 3. |
| LR 10-1(e)(1) | Every page has a footer with "a brief description of the pleading or document and consecutive numbering at the bottom of the page." | `footer-block`: "COMPLAINT - n" (from `footer_title`). |
| LR 10-1(f)(1) | Paper copies: 8½ × 11, one-sided, unfolded. | `paper: "us-letter"`. |
| LR 10-2(a) | "Counsel or self-represented party information (name, bar number, email, firm, address, phone, and party represented) goes in the upper left corner of the first page, starting one inch from the top." | `counsel-block`, from frontmatter `counsel`, starting at the top margin. |
| LR 10-2(b) | Court title "double-spaced, capitalized, and centered at least one inch below the counsel information." | `counsel-block` reserves at least 1 in below the counsel lines; `court-title` lines at pitch, centered, upper case. |
| LR 10-2(d) | "Party names are single-spaced along the left margin below the court title." | `caption`, left column, single-spaced. |
| LR 10-2(f) | Case number "starting at the center of the page, left-justified on the same line as the first named plaintiff," including the division code under LR 3-2. | `caption`: right column starts at the page center (`caption-split`); the first line is "Case No. …", or a blank line for a complaint the clerk has not yet numbered. Division name from frontmatter `division`. |
| LR 10-2(g) | Document title "at least two lines below the case number, single-spaced and capitalized." | `caption`: `v(pitch)` after the case number, title in upper case, single-spaced. |
| LR 3-2 | Division assignment (cited in LR 10-2(f) only). | Division line from frontmatter `division` (PORTLAND DIVISION in the sample). |
| Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." Source: https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14. | Court name (`court`), title (`brief_title`), case number (`case_number`). The Rule 7(a) designation is the title "COMPLAINT" in the `brief_title` text. |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs." Same source, fetched 2026-10-14. | `allegations()` numbers each paragraph 1, 2, …; headings and lists are not numbered. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the claim. Cited by the sample's text only; not separately fetched in this session. | Not checked by the template. |
| LR 3-2 / LR 7 / LR 7-1 | Not applicable to a complaint (no motion). | None. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement, the summons, and any class-action filings the court requires separately. Each may be required with the first filing.

## Layout

- Top margin 1 inch; body text in lines 24 pt apart; 27 lines fill the 9-inch text height exactly.
- Counsel block single-spaced (13.8 pt lines) in the upper left, starting at the top margin; the court title exactly one inch below it (LR 10-2(b): at least one inch), its lines 24 pt apart.
- Court title, caption and title block centered or set in two columns (party names left, case number and title from the page center).
- Body: each paragraph numbered (Fed. R. Civ. P. 10(b)) with a 0.5 in first-line indent; `##` headings bold and centered; `#` headings bold capitals and centered; markdown `-` lists lettered (a), (b), … with a hanging indent; markdown tables are reproduced unnumbered, single-spaced with rules; a `>` quotation is single-spaced, indented 0.5 in on both sides and unnumbered.
- Headings are set at 12 pt on the 24 pt pitch and stay with the block after them. The last paragraph (or the last item of a closing list) stays on one page with the signature block.
- Signature block: "DATED:" date on the left, firm, "By: /s/" signer, bar number and address on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Quote any frontmatter value that contains a colon or `#` (a bare `OSB #220318` or `Telephone: 971-800-6000` is misread by YAML; the render shows it).
- Frontmatter fields: `court` (list of lines), `division`, `counsel` (lines), `caption.parties` (list of `{names, designation}`; "vs." is inserted between parties), `case_number` (empty for a complaint), `brief_title`, `jury_demand`, `footer_title`, `lead_in` (unnumbered lead-in paragraph, optional), `date`, `signature` (`firm` list, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (centered bold capitals), `##` heading (centered bold), `###` heading (bold italic); `>` quotation (single-spaced, indented, unnumbered); `-` list (lettered); `|` table; any other chunk is a numbered paragraph.
- Do not put paragraph numbers in the text; the template numbers the paragraphs.

## Render and overlay

Run from the repo root (`export PATH="$HOME/tb/bin:$PATH"` first; typst 0.15.0, poppler, ImageMagick):

```sh
sh tools/render.sh courts/ninth-circuit/oregon/federal/district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/ninth-circuit/oregon/federal/district/complaint kliewer-complaint
```

File names follow the tools' defaults, not the brief's `<id>.pdf` and `<id>-overlay.pdf`: `render.sh` writes `OUTPUT-<id>.pdf` and `overlay.sh` reads that and writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The `<id>` is `kliewer-complaint`.

The overlay is a diagnostic, not a score: red = our render only, blue = the filed exemplar only, black = both. The page map pairs each sample page with the exemplar page that shares most words (`OVERLAY-kliewer-complaint.txt`): ours p.1-3 ↔ filed p.1-3, ours p.4 ↔ filed p.5, p.5 ↔ p.6, p.6 ↔ p.7, p.7 ↔ p.11, p.8 ↔ p.18. The pairing is coarse because the sample skips paragraphs and the exemplar has pleading line numbers and a left-margin rule the template does not draw.

## Review of the rendered pages

The Gate 2 record for both engines (every page of the current typst and docx renders, viewed side by side) is
`reviews/docx.md`.

## Known gaps and open choices

1. **One exemplar, one filer.** The brief asks for one exemplar per doc type; the tier-2 rule in CLAUDE.md asks for two or three filers. Candidates are listed in `usage/SOURCE.md` (Brown v. Lincoln County, 25 pages, counsel-filed). Not done.
2. **The sample is partial.** The filing is 18 pages. The sample omits the rest of the class allegations (the Rule 23(b) and exclusion paragraphs), Counts 2 to 8, and the injunctive-relief count; the call table is cut to its first and last rows with a bracketed note (the filed table runs to about 60 entries), the elided rows marked by one "…" in the first column (three "…" cells in a row read as a dot leader to Gate 0, which then failed DEF-CONT-001). The sample is 9 rendered pages. The Hollings quotation is a `>` block quotation, unnumbered, as filed; paragraph numbers follow the sample's own sequence and differ from the filed numbers in places where the exemplar's text layer scrambles paragraph breaks.
3. **Pleading line numbers (LR 10-1(d)).** The exemplar carries line numbers 1–26 down the left margin. The template draws none, following the rule as quoted from the LR 10 page. This is an open question for David: if the court still expects pleading paper, a 28-line variant would need a different grid (the LR 10-1(b) double-spacing and the 1-inch margins would still apply).
4. **Font size.** 12 pt Times New Roman throughout (LR 10-1(c) floor; the size of both exemplars). The 13 pt body of earlier passes was chosen for EB Garamond and is gone.
5. **Footer.** Read as "typewritten material" under LR 10-1(c), so 12 pt (the exemplar's footer is about 10 pt).
6. **Counsel block.** The exemplar puts the counsel block in the footer and leaves the top of page 1 empty. The template follows LR 10-2(a) (upper left, page 1). The sample transcribes the counsel from the exemplar's footer into the upper-left block.
7. **Caption.** The party column has no ")" marks or rule; the exemplar has none either. Convention, not a rule.
8. **Dates and rule text.** LR 10-1 and 10-2 are taken from the court's LR 10 page (amendment notes to 2024); the December 1, 2026 changes are not checked (see the caveat above).
9. **Checks.** `tools/check.sh <dir> --engine typst|docx` run green (fb-595.68.24). `tools/check-selftest.sh` takes a court root (`court.json`), not this doc-type folder, so it was not run here.
10. **Italics.** The exemplar's text layer has no italic markup; case names are roman in the sample. The template italicizes `*...*` if a sample uses it.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`;
docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.24): Times New Roman 12 pt, every line an exact box of its pitch
(24 pt double, 13.8 pt single), the spaces between blocks given explicitly, the same break rules. `eval.yaml` sets
`params.cross_engine: gate`, so the docx must break every line and page where typst does (XENG-001..003).

**typst** (`typst/`, primary): `ord-complaint.typ`, rendered by `tools/render.sh`.

**docx** (`docx/`): declarative inputs only. `docx/reference.xml` holds the Word styles (`base="xengine"` in the
typst face `{font}`, the headings, "Numbered Paragraph" and "Lettered"); `docx/complaint.lua` writes the cover, the
caption table, the numbered paragraphs, lettered items, quotations, the pipe table and the signature block, and hands
`fb render` the footer ("TITLE - n", from `footer_title`; `$FORMBOOK_FOOTERS`) and the last section
(`$FORMBOOK_FINAL`). `fb render --engine docx` builds the reference document, runs pandoc and LibreOffice and packs
the archive: no shell script, no committed `reference.docx`. Output: `usage/OUTPUT-complaint.docx` and `.docx.pdf`.
Not verified in Word (only LibreOffice here).

[District index](../README.md) | [Formbook index](../../../../../../README.md)
