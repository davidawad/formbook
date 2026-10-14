# flmd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Florida (`flmd`).
Folder: `courts/eleventh-circuit/florida/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-bracho-cardella-8-26-cv-03113-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-bracho-complaint.md` (the whole 10-page complaint, transcribed from the text layer) |
| typeface | **BLOCKED: no permitted typeface is vendored.** The template renders in EB Garamond, the only vendored font, as a stand-in. See "Typeface" below. |
| render | ok: `samples/OUTPUT-bracho-complaint.pdf`, 9 pages, typst 0.15.0, no warnings, vendored font only |
| overlay | ok: `samples/OVERLAY-bracho-complaint.pdf` and `OVERLAY-bracho-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| M.D. Fla. Local Rule 1.08(a) | 8½ × 11 paper; 1-inch margins; page numbers bottom center (none needed on page one); main text at least 13-point and 2.0 double-spaced; indented quotations at least 12-point single-spaced; footnotes at least 11-point single-spaced; typeface Book Antiqua, Calisto MT, Century Schoolbook, Georgia or Palatino. | `page-margin`, footer in `flmd-complaint()`, `type-size`, `body-leading`. Typeface: see "Typeface" (BLOCKED). |
| M.D. Fla. Local Rule 1.08(b) | Times New Roman permitted if main text is 14-point, indented quotations 13-point, footnotes 12-point. | `type-size = 14pt`, the Times New Roman size for the main text. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. | `court-title`, `caption`, `cover`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each text paragraph is numbered; headings and lists are not. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of jurisdiction, the claim, and the relief sought. | Author content; the template does not check it. |
| Fed. R. Civ. P. 11(a) | Complaint signed by counsel of record, with address, phone, email and bar number. | `signature-block()`, from the `signature` frontmatter. |

Sources: Local Rule 1.08 text from the court's amended local rules effective 2025-11-01, https://www.flmd.uscourts.gov/sites/flmd/files/flmd-amended-local-rules-effective-november-01-2025.pdf (rule page https://www.flmd.uscourts.gov/local-rules/rule-108-form-pleading-motion-or-other-paper), fetched and read 2026-10-14. Rule 10 from https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14.

Not produced by this template: the civil cover sheet (JS-44); the Local Rule 3.02 case management report (not required for the complaint); the summons; the Rule 7.1 disclosure statement. Any of these may be needed with the first filing.

## Layout

- Court title centered, single-spaced; caption (parties left with a closing rule, `CASE NO.` right); title centered bold.
- Body double-spaced (2.0 em baseline pitch), 14-point EB Garamond, 1-inch margins.
- Headings: level 1 centered bold caps (the sample writes them in caps); level 2 centered bold under it; level 3 bold italic.
- Numbered paragraphs 1, 2, ... with a 0.5 inch first-line indent. A chunk starting `~ ` is unnumbered (used for the jury demand).
- Lists are lettered (a), (b), ...
- Signature block: "RESPECTFULLY SUBMITTED this ... day of ...", then the firm, `s/` signer and the counsel lines, single-spaced, right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `division`, `caption.versus` (optional, default "v."), `caption.parties` (list of `{names, designation}`), `brief_title`, `footer_title` (not used by this template; kept for symmetry with the pleading-paper template), `lead_in` (unnumbered lead-in paragraph, optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. A `#` heading; a list (`1.` items, lettered by the template); a `~ ` unnumbered paragraph; any other text is a numbered paragraph.
- Not supported: tables, footnotes, raw typst. The sample must not put paragraph numbers in the text.

## Typeface: BLOCKED

Rule 1.08(a) names Book Antiqua, Calisto MT, Century Schoolbook, Georgia and Palatino; 1.08(b) allows Times New Roman at 14-point. The repo vendors only EB Garamond (`fonts/eb-garamond/`), and the brief bars system fonts and edits to `fonts/`. The template therefore uses EB Garamond at 14 pt as a **stand-in**, which is **not** a rule-compliant typeface. The render is a layout check, not a filing-ready document. To finish the doc type, one of these is needed from David: vendor a permitted face (for example Times New Roman metrics or Book Antiqua under its license) into `fonts/`, then set `font-family` in `typst/flmd-complaint.typ`.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one; EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. Other M.D. Fla. complaints found in the same search (not saved): Geneva Farms, LLC v. Harllee Fruit & Vegetable Inc., 8:26-cv-03115; Louis v. Bellair East HCC, 8:26-cv-03110; Battle v. Truist Financial Corp., 8:26-cv-03076. Tier 2 is not judged against two filers yet.
2. **Typeface and size.** See "Typeface: BLOCKED." The stand-in has a smaller x-height than Times at 14 pt, so it looks smaller than the exemplar.
3. **Double spacing.** The template uses a 2.0 em baseline pitch on the EB Garamond line box. Word's "double" on Times New Roman is about 2.3 em. This is an approximation; a permitted face with its own metrics would need its leading re-measured.
4. **Footer.** Page numbers are bottom center from page 2 onward (Rule 1.08(a) requires none on page one).
5. **Lettered list alignment.** The markers (k) and (l) sit slightly left of (a)–(j) in the render. Cosmetic; not fixed.
6. **Overlay file names.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`, not `<id>-overlay.pdf` as the brief lists. The tool was not edited (`tools/` is out of scope), so the tool's names are used. The render is `OUTPUT-<id>.pdf`, which `tools/render.sh` also writes by default.
7. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder does not have. The brief forbids editing `tools/`, so the gates were not run; the review below stands in for Gate 2.
8. **Excerpt.** The sample is the whole complaint. The e-filing header ("Case 8:26-cv-03113 Document 1 Filed ... Page n of 10") is not transcribed; it is added by the clerk, not by the filer.
9. **Typographic details not asserted.** Justification (the exemplar is ragged-right in the text layer), the exemplar's use of italics (not visible in the text layer), and FRCP 5.2 redaction (none needed in this sample).

## Review of the rendered pages (current PDF, 60 dpi)

- Page 1: court title single-spaced; caption; title; lead-in with indent; paragraph 1 starts "JURISDICTION AND VENUE". Pass.
- Page 2: paragraphs 2 to 9; PARTIES heading centered. Pass.
- Page 3: paragraphs 10 to 12, FACTS heading, paragraph 13. Pass.
- Page 4: paragraphs 14 to 25, COUNT I and its sub-heading kept with paragraph 22. Pass.
- Page 5: paragraphs 26 to 31, COUNT II heading. Pass.
- Page 6: paragraphs 32 to 38, COUNT III heading. Pass.
- Page 7: paragraphs 39 to 44, STATE LAW CLAIMS, COUNT IV heading. Pass.
- Page 8: paragraphs 44 to 47, DAMAGES heading, list (a) to (i). Pass.
- Page 9: list (j) to (l), DEMAND FOR JURY TRIAL (unnumbered), date line, signature block. Pass.

Re-check after the last template change: the caption column was narrowed and the paragraph indent moved to explicit spacing; the full 9 pages were re-rendered and checked as a montage. No overflow, no orphaned headings.
