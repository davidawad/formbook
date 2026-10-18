# nyed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of New York (`nyed`).
Folder: `courts/second-circuit/new-york/federal/eastern-district/complaint/` (self-contained; no court-root `typst/` or `usage/` touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nyed-complaint-blade126cv06563.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nyed-complaint-blade.md`: a transcription of selected passages of that filing (caption, opening, parties and jurisdiction, Claims I to VI, prayer, jury demand line, signature). |
| render | ok: `usage/OUTPUT-nyed-complaint-blade.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`). Re-rendered 2026-10-15; `pdffonts` shows only EB Garamond (Regular, Italic, Bold), all embedded. |
| overlay | ok: `usage/OVERLAY-blade-complaint.pdf` (red = ours, blue = filed) and `usage/OVERLAY-blade-complaint.txt` (page map). Regenerated 2026-10-15 from `usage/SAMPLE-nyed-complaint-blade126cv06563.pdf`, restored from the URL in `usage/SOURCE.md` (18 pages, as recorded). |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change; re-checked 2026-10-15). |
| tier-2 exemplars | 1 filer. EVAL-LOOP asks for 2 or 3 filers; not met (see Known gaps). |

Naming: the brief's `<id>.pdf` / `<id>-overlay.pdf` are written as `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, because `tools/render.sh` and `tools/overlay.sh` read and write those names (file role in the name, per CLAUDE.md).

## Governing rules

Each requirement is from a primary source. Verified 2026-10-14.

| Source | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. The complaint's title names all parties. | `caption-table()`: court name (`court`), parties (`caption`), `Docket No.` (`case_number`), `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph chunk; headings, the prayer lead-in and the prayer items are not numbered. |
| Fed. R. Civ. P. 8(a) (https://www.law.cornell.edu/rules/frcp/rule_8) | Short and plain statement of jurisdiction, claim and relief. | Content only (author responsibility, `A`). Not checked by the template. |
| Fed. R. Civ. P. 5.2(a) (https://www.law.cornell.edu/rules/frcp/rule_5.2) | Redact SSN and taxpayer ID to last four digits, birth date to year, minors' names to initials, financial accounts to last four digits. | Author responsibility (`A`). The template does not scan for these. The transcribed passages contain none of them. |
| Local Civil Rule 7.1(b)(1) (joint EDNY/SDNY Local Civil Rules, effective Jan. 2, 2026: https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf) | "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type". Applies to "all documents presented for filing" (7.1(b)). | `type-size = 12pt` everywhere, including the page number. No footnotes in the complaint template. |
| Local Civil Rule 7.1(b)(2) (same) | At least one-inch margins on all sides. | `margins = 1in` on all sides. |
| Local Civil Rule 7.1(b)(3) (same) | All text double-spaced, except headings, footnotes, or block quotations. | `line-pitch = 24pt`: baseline pitch measured at 24.0 pt in the PDF (`pdftotext -bbox`). Body paragraphs and prayer items use it. |
| Local Civil Rule 11.1 | Form of pleadings. | Marked "[Withdrawn]" in the 2026 joint rules. No EDNY local form rule applies to the complaint's layout. |
| Local Civil Rule 7.1(b), lead-in (same, text read 2026-10-15) | "The typeface, margins, and spacing of all documents presented for filing must meet the following requirements". The rule names no typeface; its only typeface requirement is the 12-point minimum in (b)(1). | Face: **none named**, so the template keeps **EB Garamond** (`docs/FONTS.md`, "No face named"). See Typeface row below. |

Typeface (fonts pass, 2026-10-15): face required = none (LCR 7.1(b) names no face; the 12-point minimum is the only type-size rule). Substitute = EB Garamond (the default, not a stand-in). Fit = n/a. The judge's individual practices, not retrieved, could name a face; if one does, change `font-family` in `typst/nyed-complaint.typ` to that face's substitute from `docs/FONTS.md`.

Not produced by this template (separate filings): the civil cover sheet, the Fed. R. Civ. P. 7.1 disclosure statement and its Local Civil Rule 7.1.1 supplemental statement, the summons. Any of these may be required with the first filing.

Not retrieved, so not asserted: the EDNY ECF Rules and Instructions (the PDF-format rules: text-searchable, embedded fonts, bookmarks, size cap); the individual practices of the assigned judge (they often add font, spacing or length rules); Fed. R. Civ. P. 38(b) (the jury demand). The EDNY ECF manual is linked from the court's site; it was not reachable from the box.

## Layout

- Counsel block (optional `counsel` frontmatter) single-spaced at top left; the court title follows. No pleading paper: the EDNY rules do not require numbered lines.
- Court name centered, bold capitals; caption as a two-column table with rules above and below the party column, "-against-" between the sides; `Docket No.` and `JURY TRIAL DEMANDED` at right.
- Title ("COMPLAINT") centered bold capitals.
- Unnumbered lead-in (`lead_in` frontmatter; the "Plaintiff ... states as follows" paragraph).
- Headings: `#` centered bold capitals; `##` centered bold; `###` left bold. Single-spaced, with a half-line gap.
- Numbered paragraphs: number at 0.5 inch, text at 1 inch, continuation lines at the margin, double-spaced.
- Prayer: a `WHEREFORE` paragraph (unnumbered by rule), then items lettered A., B., ... in a label column at 0.5 inch.
- Signature block: "Dated:" at left; "Respectfully submitted," and the signer block at right; "By: /s/ <signer>".

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: a `#`/`##`/`###` heading, a `- ` list (prayer items, lettered), or a paragraph (numbered).
- Frontmatter fields: `case_number`, `court` (lines), `caption` (list of `{names, designation}`; "-against-" is inserted between sides), `title`, `jury_demand` (bool), `counsel` (optional lines), `lead_in` (optional, unnumbered), `date`, `signature` (`signer`, `lines`).
- Do not number paragraphs in the text: the template numbers them. A paragraph starting `WHEREFORE` is unnumbered.
- Not supported: tables, footnotes (not used), raw typst.

## Known gaps and open choices

1. **One filer only.** EVAL-LOOP tier 2 asks for 2 or 3 filers. The CourtListener RECAP search (court `nyed`, complaints filed 2026-10-02 to 2026-10-13, type `r`) found several complaints, but only Blade's was available with a text layer and was downloaded. Tier 2 is therefore not judged against two filers.
2. **Caption and counsel block single-spaced.** LCR 7.1(b)(3) requires double spacing except for headings, footnotes and block quotations. The caption, counsel block and signature block are not in that list. The template single-spaces them, following the exemplar's practice. Whether the rule reaches captions is a reading question for David, and it is a tier-1 question because it changes the form. **Open: David to decide.**
3. **Font (kept EB Garamond; tier 2, open).** LCR 7.1(b) names no typeface, so `docs/FONTS.md` keeps EB Garamond for this doc type. The filed exemplar is set in Times New Roman, and a filer's choice of face is not a rule. EB Garamond at 12 pt has a smaller x-height than Times New Roman, so text looks smaller than the exemplar; the 12-point minimum is met. A Times-metric substitute (`Liberation Serif`) would match the exemplar's look, but it is a tier-2 choice for David, not a court requirement. **Open: David to decide.**
4. **Headings must fit the flow.** Headings use `sticky` so a heading does not end a page; a very long heading wraps and is not measured.
5. **Paragraph numbers differ.** The sample is a selection and the template numbers from 1. The filed numbers are not transcribed; the overlay pairs pages by words, not paragraph numbers.
6. **Paragraph spacing.** Paragraphs are separated only by the double-space line, with no extra gap. This matches the exemplar's look; it is a tier-2 choice.
7. **No automated check.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The Gate 2 review below is the only review of this PDF. No `checks.yaml` exists.

## Review of the rendered pages (current PDF, `OUTPUT-nyed-complaint-blade.typst.pdf`)

Compared with the exemplar page that the overlay pairs with each page (`OVERLAY-blade-complaint.txt`); pages 1 to 3 pair with the same page number, pages 4 to 9 do not, because the sample skips passages of the filing.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Counsel block, court title, caption box with rules, `Docket No. 1:26-cv-06563`, `JURY TRIAL DEMANDED`, title centered, unnumbered lead-in, heading NATURE OF THE ACTION. Page number at foot. | PASS |
| 2 | exemplar p.2 | Tail of paragraph 3, then paragraphs 4 to 11, numbers at 0.5 in, double-spaced. Heading PARTIES, JURISDICTION, AND VENUE centered. No orphan heading. | PASS |
| 3 | exemplar p.3 | Paragraphs 12 to 21, headings PREREQUISITES and TRIAL BY JURY, FIRST CLAIM FOR RELIEF with a two-line bold subheading centered. | PASS |
| 4 | exemplar p.11 (overlay pair) | Paragraphs 22 to 28, SECOND CLAIM FOR RELIEF heading kept with its first paragraph. | PASS |
| 5 | exemplar p.14 (overlay pair) | Paragraphs 29 to 36, THIRD CLAIM FOR RELIEF heading and subheading centered. | PASS |
| 6 | exemplar p.14 (overlay pair) | Paragraphs 37 to 44, FOURTH CLAIM FOR RELIEF heading; the statutory quotation is set as an ordinary numbered paragraph. | PASS |
| 7 | exemplar p.15 (overlay pair) | Paragraphs 45 to 53, FIFTH CLAIM FOR RELIEF heading kept with its first paragraph. | PASS |
| 8 | exemplar p.16 (overlay pair) | Paragraphs 54 to 60, SIXTH CLAIM FOR RELIEF, PRAYER FOR RELIEF heading and WHEREFORE lead-in unnumbered, item A. at 0.5 in. | PASS |
| 9 | exemplar p.17 (overlay pair) | Prayer items B. to G. in the label column; "Dated" line; signature block at right, "By: /s/" line; page number. Nothing spills. | PASS |

Overlay (word-overlap pairing, not a score): page 3 pairs with the lowest overlap (33.7%). The sample is a selection of passages, so its paragraphs and the exemplar's page 3 share fewer words; this is expected and is tier 3, not a defect. The overlay is a diagnostic, not a score.

## Engines

DOCX (`docx/`): `build-reference.sh` builds `reference.docx` (EB Garamond 12 pt, exact 24 pt body spacing, 0.5 in first-line indent, 1 in margins, centered PAGE footer); `nyed-complaint.lua` builds the counsel block, caption table, title, numbered paragraphs (number at 0.5 in, tab to 1 in), prayer letters, and signature block. Samples: `usage/OUTPUT-nyed-complaint-blade.docx` and `.docx.pdf` (LibreOffice conversion, no errors; opened in LibreOffice, not Word).

- Matches the typst output: font and size, 24 pt double spacing, margins, caption layout and rules, heading styles, numbering positions, prayer indents, signature block, page-number footer. Pages reviewed: 10 of 10 (`docx-01` to `docx-10` at 60 dpi, compared with the typst pages).
- Differs: 10 pages in docx, 9 in typst. Line breaks and per-page line counts differ between LibreOffice and typst (docx pages carry 25 to 28 text lines, typst 28 to 30); the mandated line pitch is the same in both. Paragraph numbers are typed text, not a Word list, so a paragraph inserted in Word must be renumbered by hand.
- BLOCKED: `tools/check.sh <doc-dir> --engine docx` cannot run on this folder (exit 2): it needs `court.json` and `checks.yaml` at the court root, and neither exists for a doc-type folder. No gate has passed for the docx engine; the `.docx.pdf` was reviewed by eye only.
