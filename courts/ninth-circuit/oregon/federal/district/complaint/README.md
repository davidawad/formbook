# ord: complaint

Doc type: **complaint** in the United States District Court for the District of Oregon (`ord`).
Folder: `courts/ninth-circuit/oregon/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-kliewer-fender-3-26-cv-02238-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-kliewer-complaint.md`: partial transcription, 8 rendered pages (see Known gaps) |
| render | ok: `samples/OUTPUT-kliewer-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| typeface | face required: none (LR 10-1 text read 2026-10-15 names no typeface; only the 12-pt minimum). Vendored substitute: none needed; **EB Garamond kept** (the rule allows any proportional face). Fit: n/a. Font list unchanged in this pass. |
| overlay | **fail** this pass: `exemplars/FILED-EXAMPLE-*.pdf` is not in this snapshot, so `tools/overlay.sh` could not run. The `samples/OVERLAY-kliewer-complaint.txt` on disk is from an earlier run; no `.pdf` is on disk. |
| pages reviewed | 8 of 8 this pass (every page rasterized at 60 dpi and viewed after the re-render) |
| check.sh / check-selftest.sh | not run: they expect a court root with `court.json` and `rules.md`, and this is a doc-type folder; the brief forbids touching `tools/` |

## Governing rules

Source for the local rules: the District of Oregon's Local Rules page, https://www.ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules/civil-procedure/1989-lr-10-form-of-pleadings-and-other-documents (the LR 10 text, with its amendment notes), fetched and read 2026-10-14. The page's quoted wording is used below. Its amendment notes run to September 3, 2024.

Caveat, read before relying on this: the court's current Local Rules index, fetched 2026-10-14 from https://www.ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules, lists the civil rules as "LR 10 - Form of Pleadings and Other Documents" without subsections, and says changes "will have an expected effective date of December 1, 2026" (the only redline on that page is LR 16). The subsection numbers used here (10-1, 10-2) come from the page above and have **not** been checked against a codified 2026 text. Confirm the numbering and wording before the template is called final.

| Rule | Requirement (as quoted or paraphrased from the source) | Where it lives in the template |
|---|---|---|
| LR 10-1(a) | Typewritten, neatly printed or legibly reproduced, blue or black ink. | Output is black type on white paper. |
| LR 10-1(b) | "Documents must be double-spaced, except for counsel identification, the case title, footnotes, quotations, and exhibits." | `pitch = 24pt`: 27 lines per page; `body-leading`; `on-grid` keeps every block a whole number of pitches. |
| LR 10-1(c) | "Typewritten materials, including footnotes and endnotes, must use no smaller than a 12-point font." | `type-size = 13pt` (body); `footer-size = 12pt`. See Known gaps 4 and 5. |
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
- Counsel block single-spaced in the upper left, starting at the top margin. Its height is rounded up with at least one inch below before the court title.
- Court title, caption and title block centered or set in two columns (party names left, case number and title from the page center).
- Body: each paragraph numbered (Fed. R. Civ. P. 10(b)) with a 0.5 in first-line indent; `##` headings bold and centered; `#` headings bold capitals and centered; markdown `-` lists lettered (a), (b), … with a hanging indent; markdown tables are reproduced unnumbered.
- A heading stays with the paragraph after it. The last body chunk (the prayer list) stays on one page with the signature block.
- Signature block: "DATED:" date on the left, firm, "By: /s/" signer, bar number and address on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Quote any frontmatter value that contains a colon or `#` (a bare `OSB #220318` or `Telephone: 971-800-6000` is misread by YAML; the render shows it).
- Frontmatter fields: `court` (list of lines), `division`, `counsel` (lines), `caption.parties` (list of `{names, designation}`; "vs." is inserted between parties), `case_number` (empty for a complaint), `brief_title`, `jury_demand`, `footer_title`, `lead_in` (unnumbered lead-in paragraph, optional), `date`, `signature` (`firm` list, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (centered bold capitals), `##` heading (centered bold), `###` heading (bold italic); `-` list (lettered); `|` table; any other chunk is a numbered paragraph.
- Do not put paragraph numbers in the text; the template numbers the paragraphs.

## Render and overlay

Run from the repo root (`export PATH="$HOME/tb/bin:$PATH"` first; typst 0.15.0, poppler, ImageMagick):

```sh
sh tools/render.sh courts/ninth-circuit/oregon/federal/district/complaint samples/INPUT-kliewer-complaint.md
sh tools/overlay.sh courts/ninth-circuit/oregon/federal/district/complaint kliewer-complaint
```

File names follow the tools' defaults, not the brief's `<id>.pdf` and `<id>-overlay.pdf`: `render.sh` writes `OUTPUT-<id>.pdf` and `overlay.sh` reads that and writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The `<id>` is `kliewer-complaint`.

The overlay is a diagnostic, not a score: red = our render only, blue = the filed exemplar only, black = both. The page map pairs each sample page with the exemplar page that shares most words (`OVERLAY-kliewer-complaint.txt`): ours p.1-3 ↔ filed p.1-3, ours p.4 ↔ filed p.5, p.5 ↔ p.6, p.6 ↔ p.7, p.7 ↔ p.11, p.8 ↔ p.18. The pairing is coarse because the sample skips paragraphs and the exemplar has pleading line numbers and a left-margin rule the template does not draw.

## Review of the rendered pages (Gate 2 record, all 8 pages, rendered at 60 dpi and viewed)

| Page | Content | Finding |
|---|---|---|
| 1 | Counsel block upper left; court title; caption with the case number at the page center; title single-spaced in capitals; jury demand line; start of the lead-in and Section I | OK. The title was double-spaced in the first render; fixed (single-spaced, LR 10-2(g)). |
| 2 | Paragraphs 3–10; Section II heading | OK. Paragraph numbers, indents and 24 pt pitch as measured (pdftotext bbox). |
| 3 | Paragraph 11; Section III heading and "Lead Plaintiff" sub-heading; paragraphs 12–17; "The Calls" sub-heading; paragraphs 18–21 | OK. |
| 4 | Transcription note, the call table (first and last rows), paragraphs 22–28 | OK. The table is unnumbered with rules. |
| 5 | Paragraphs 29–31; Section IV heading; paragraph 32 with lettered classes (a)–(c) begun | OK. The list item (c) breaks across the page with its hanging indent kept. |
| 6 | Class item (c) finishes; paragraphs 33–41; Section V heading and "Allegations Applicable to All Counts" | OK. |
| 7 | Paragraphs 42–52; "Count 1" sub-heading | OK. The heading stays with its paragraph. |
| 8 | Paragraphs 53–55; Section VI "JURY DEMAND"; Section VII "PRAYER FOR RELIEF"; paragraph 56 with lettered prayer (a)–(h); signature block below the prayer | OK. The signature block is on the same page as the prayer (fixed: it had been alone on a page). |

## Known gaps and open choices

1. **One exemplar, one filer.** The brief asks for one exemplar per doc type; the tier-2 rule in CLAUDE.md asks for two or three filers. Candidates are listed in `exemplars/SOURCE.md` (Brown v. Lincoln County, 25 pages, counsel-filed). Not done.
2. **The sample is partial.** The filing is 18 pages. The sample omits the rest of the class allegations (the Rule 23(b) and exclusion paragraphs), Counts 2 to 8, and the injunctive-relief count; the call table is cut to two rows with a bracketed note (the filed table runs to about 60 entries). The sample is 8 rendered pages, below the 8–14 target because the sample is partial. Paragraph numbers follow the sample's own sequence and differ from the filed numbers in places: the block quotation in paragraph 3 is a separate paragraph in the sample, and the exemplar's text layer scrambles some paragraph breaks.
3. **Pleading line numbers (LR 10-1(d)).** The exemplar carries line numbers 1–26 down the left margin. The template draws none, following the rule as quoted from the LR 10 page. This is an open question for David: if the court still expects pleading paper, a 28-line variant would need a different grid (the LR 10-1(b) double-spacing and the 1-inch margins would still apply).
4. **Font size.** LR 10-1(c) sets 12 pt as the floor, and the template uses 13 pt for the body. The only serif face vendored is EB Garamond, which sets smaller than Times New Roman at the same point size, so 13 pt keeps the apparent size close to the exemplar. The footer is 12 pt. Both are choices, not rule text; flagged for David.
5. **Footer.** Read as "typewritten material" under LR 10-1(c), so 12 pt (the exemplar's footer is about 10 pt).
6. **Counsel block.** The exemplar puts the counsel block in the footer and leaves the top of page 1 empty. The template follows LR 10-2(a) (upper left, page 1). The sample transcribes the counsel from the exemplar's footer into the upper-left block.
7. **Caption.** The party column has no ")" marks or rule; the exemplar has none either. Convention, not a rule.
8. **Dates and rule text.** LR 10-1 and 10-2 are taken from the court's LR 10 page (amendment notes to 2024); the December 1, 2026 changes are not checked (see the caveat above).
9. **Not run.** `tools/check.sh` and `tools/check-selftest.sh` (their gates expect a court root with `court.json` and `rules.md`); tools/ is off limits for this box. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
10. **Italics.** The exemplar's text layer has no italic markup; case names are roman in the sample. The template italicizes `*...*` if a sample uses it.

[District index](../README.md) | [Formbook index](../../../../../../README.md)
