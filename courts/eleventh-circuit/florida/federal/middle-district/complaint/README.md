# flmd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Florida (`flmd`).
Folder: `courts/eleventh-circuit/florida/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole 10-page complaint, transcribed from the text layer) |
| typeface | Face required: **Times New Roman** (LR 1.08(b); the filed exemplar is set in Times New Roman). Vendored substitute: **Liberation Serif** (metric-compatible, `docs/FONTS.md`). Metric-compatible. See "Typeface" below. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages (same count as with EB Garamond), typst 0.15.0, no warnings, `pdffonts`: Liberation Serif embedded |
| overlay | ok: `usage/OVERLAY-bracho-complaint.pdf` and `OVERLAY-bracho-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the font change) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| M.D. Fla. Local Rule 1.08(a) | 8½ × 11 paper; 1-inch margins; page numbers bottom center (none needed on page one); main text at least 13-point and 2.0 double-spaced; indented quotations at least 12-point single-spaced; footnotes at least 11-point single-spaced; typeface Book Antiqua, Calisto MT, Century Schoolbook, Georgia or Palatino. | `page-margin`, footer in `flmd-complaint()`, `type-size`, `body-leading`. Typeface: see "Typeface" (Times New Roman under 1.08(b)). |
| M.D. Fla. Local Rule 1.08(b) | Times New Roman permitted if main text is 14-point, indented quotations 13-point, footnotes 12-point. | `font-family = "Liberation Serif"` (the Times New Roman substitute), `type-size = 14pt`. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. | `court-title`, `caption`, `cover`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each text paragraph is numbered; headings and lists are not. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of jurisdiction, the claim, and the relief sought. | Author content; the template does not check it. |
| Fed. R. Civ. P. 11(a) | Complaint signed by counsel of record, with address, phone, email and bar number. | `signature-block()`, from the `signature` frontmatter. |

Sources: Local Rule 1.08 text from the court's amended local rules effective 2025-11-01, https://www.flmd.uscourts.gov/sites/flmd/files/flmd-amended-local-rules-effective-november-01-2025.pdf (rule page https://www.flmd.uscourts.gov/local-rules/rule-108-form-pleading-motion-or-other-paper), fetched and read 2026-10-14. Rule 10 from https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14.

Not produced by this template: the civil cover sheet (JS-44); the Local Rule 3.02 case management report (not required for the complaint); the summons; the Rule 7.1 disclosure statement. Any of these may be needed with the first filing.

## Layout

- Court title centered, single-spaced; caption (parties left with a closing rule, `CASE NO.` right); title centered bold.
- Body double-spaced (2.0 em baseline pitch), 14-point Liberation Serif, 1-inch margins.
- Headings: level 1 centered bold caps (the sample writes them in caps); level 2 centered bold under it; level 3 bold italic.
- Numbered paragraphs 1, 2, ... with a 0.5 inch first-line indent. A chunk starting `~ ` is unnumbered (used for the jury demand).
- Lists are lettered (a), (b), ...
- Signature block: "RESPECTFULLY SUBMITTED this ... day of ...", then the firm, `s/` signer and the counsel lines, single-spaced, right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `division`, `caption.versus` (optional, default "v."), `caption.parties` (list of `{names, designation}`), `brief_title`, `footer_title` (not used by this template; kept for symmetry with the pleading-paper template), `lead_in` (unnumbered lead-in paragraph, optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. A `#` heading; a list (`1.` items, lettered by the template); a `~ ` unnumbered paragraph; any other text is a numbered paragraph.
- Not supported: tables, footnotes, raw typst. The sample must not put paragraph numbers in the text.

## Typeface

Rule 1.08(a) names Book Antiqua, Calisto MT, Century Schoolbook, Georgia and Palatino; 1.08(b) permits Times New Roman at 14-point main text. The filed exemplar is set in Times New Roman (embedded `TimesNewRomanPSMT`), so the template follows that face.

- Face required: Times New Roman (LR 1.08(b)).
- Vendored substitute: **Liberation Serif** (`fonts/liberation-serif/`, SIL OFL 1.1), per the `docs/FONTS.md` table. Metric-compatible with Times New Roman.
- Typst family name: `Liberation Serif`, set in `typst/flmd-complaint.typ` as `font-family`.
- Size: 14-point main text, 13-point indented quotations, 12-point footnotes (1.08(b)); the template sets the main text at 14 pt.
- Page count did not change (9 pages before and after), so the substitute does not move the line breaks.

Liberation Serif is a metric-compatible stand-in, not Times New Roman itself. Visually it is very close; a clerk should see no difference in the render.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one; EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. Other M.D. Fla. complaints found in the same search (not saved): Geneva Farms, LLC v. Harllee Fruit & Vegetable Inc., 8:26-cv-03115; Louis v. Bellair East HCC, 8:26-cv-03110; Battle v. Truist Financial Corp., 8:26-cv-03076. Tier 2 is not judged against two filers yet.
2. **Typeface and size.** See "Typeface." The substitute is metric-compatible, so line breaks match the template's previous render; the exemplar's own line breaks are not reproduced by a template.
3. **Double spacing.** The template uses a 2.0 em baseline pitch (measured 28.1 pt at 14 pt with Liberation Serif, `pdftotext -bbox`). Word's "double" on Times New Roman is about 2.3 em. This is an approximation kept from the EB Garamond version; it was not re-derived from the substitute's line height.
4. **Footer.** Page numbers are bottom center from page 2 onward (Rule 1.08(a) requires none on page one).
5. **Lettered list alignment.** The markers (k) and (l) sit slightly left of (a)–(j) in the render. Cosmetic; not fixed.
6. **Overlay file names.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`, not `<id>-overlay.pdf` as the brief lists. The tool was not edited (`tools/` is out of scope), so the tool's names are used. The render is `OUTPUT-<id>.pdf`, which `tools/render.sh` also writes by default.
7. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder does not have. The brief forbids editing `tools/`, so the gates were not run; the review below stands in for Gate 2.
8. **Excerpt.** The sample is the whole complaint. The e-filing header ("Case 8:26-cv-03113 Document 1 Filed ... Page n of 10") is not transcribed; it is added by the clerk, not by the filer.
9. **Typographic details not asserted.** Justification (the exemplar is ragged-right in the text layer), the exemplar's use of italics (not visible in the text layer), and FRCP 5.2 redaction (none needed in this sample).

## Review of the rendered pages (current PDF, 60 dpi, after the Liberation Serif change)

Every page was rendered with `pdftoppm -r 60`, montaged two per image, and viewed. Result below.

- Page 1: court title single-spaced; caption; title; lead-in with indent; JURISDICTION AND VENUE; paragraphs 1 and 2. Pass.
- Page 2: paragraphs 3 to 9; PARTIES heading centered. Pass.
- Page 3: paragraphs 10 to 12. Pass.
- Page 4: FACTS heading, paragraphs 13 to 21; COUNT I and its sub-heading with paragraphs 22 to 24. Pass.
- Page 5: paragraphs 25 to 31; COUNT II heading. Pass.
- Page 6: paragraphs 32 to 37; COUNT III heading with paragraphs 34 to 37. Pass.
- Page 7: paragraphs 38 to 43; STATE LAW CLAIMS, COUNT IV heading. Pass.
- Page 8: paragraphs 44 to 47, DAMAGES heading, list (a) to (e). Pass.
- Page 9: list (f) to (l), DEMAND FOR JURY TRIAL (unnumbered), date line, signature block. Pass.

No overflow, no orphaned headings. Caption, headings and signature block are as before the font change.

## Engines

| Engine | Status |
|---|---|
| typst | primary; unchanged by this section |
| docx | built: `docx/reference.docx` (made by `docx/make-reference.sh complaint`), `docx/flmd-complaint.lua`, `docx/render.sh`. Output `usage/OUTPUT-complaint.docx` (valid zip, well-formed XML, text check below). `OUTPUT-flmd-complaint-bracho.docx.pdf`: **BLOCKED** (no LibreOffice on this box, see below). |
| latex | not built |

What matches the typst template (by rule): Letter, 1-inch margins; main text Times New Roman 14-point (LR 1.08(b)); double-spaced; the court-title and caption block (FRCP 10(a)); numbered paragraphs (FRCP 10(b)) with a 0.5-inch first-line indent; lettered lists (a), (b), ...; the indented, unnumbered jury demand; the signature block at 3 inches; page numbers bottom center from page two (`titlePg`, no footer on page one).

What differs from typst:

- **Line spacing.** The docx uses Word's native "double" (auto 2.0), not the 28.1-pt pitch of the typst template. Word's double on 14-point Times New Roman is, by the typst README's estimate (gap 3 above), about 2.3 em, so the docx may run longer than the typst render (9 pages). Not measured here; the docx follows the rule's word.
- **Typeface.** The docx names Times New Roman, which Word has; LibreOffice substitutes Liberation Serif (metric-compatible). Typst uses Liberation Serif directly.
- **Caption rule.** A 28-underscore closing rule in a table column (the typst template uses 30, which at 14 pt does not fit the 2.9-inch column).
- **Numbers are text.** The paragraph numbers are typed (`N.` and a tab), as in the typst template, not Word automatic numbering. A paragraph inserted in Word does not renumber the rest.
- **Quotations and footnotes.** Block quotations are 13-point, single-spaced (LR 1.08(b)); footnotes are 12-point single-spaced. The typst template sets no size for quotations, so it renders them at 14 point. The sample has no quotations or footnotes.
- **Pagination** is not measured (see the BLOCKED item): the typst page count of 9 is not a claim for the docx.

Checks run on the `.docx` (not a PDF gate): every word of the markdown body is in the docx text, in order (1578 of 1578 words; `pandoc -t plain`, with the smart-punctuation no-break spaces and ellipses normalized). The cover, caption and signature are added by the filter and are not in the markdown body.

BLOCKED (docx tier 1 gates, `docs/DOCX.md`):

- `OUTPUT-flmd-complaint-bracho.docx.pdf` could not be made: `tools/render-docx.sh` calls `soffice`, which is not installed. LibreOffice 25.2 was unpacked from the Debian packages into a private prefix without root; it stops during UNO bootstrap (`RuntimeException`), so no PDF exists. Gates 0 and 1 and the Gate 2 page review were not run on a docx PDF; pages reviewed: 0.
- Word has not been used to open the file (no Word here). The package is a valid zip with well-formed XML parts.
- `tools/render-docx.sh` runs LibreOffice with the system font configuration, not the vendored fonts that `docs/FONTS.md` rule 2 requires. That is in `tools/` (out of this change's scope) and should be fixed there before the docx PDF gates can count.

To rebuild: `sh docx/make-reference.sh docx/reference.docx complaint`, then `sh tools/render.sh --engine docx <court-dir>/complaint usage/INPUT-complaint.md`.
