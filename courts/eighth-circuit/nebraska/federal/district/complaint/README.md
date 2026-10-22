# ned: complaint

Doc type: **complaint** in the United States District Court for the District of Nebraska (`ned`).
Folder: `courts/eighth-circuit/nebraska/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, 1 filer: `usage/FILED-EXAMPLE-complaint.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole 12-page filing, paragraph numbers left to the template) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 12 pages, typst 0.15.0, pinned Times New Roman only (`pdffonts`), no warnings |
| overlay | ok: `usage/OVERLAY-goldenstein-complaint.pdf` and `OVERLAY-goldenstein-complaint.txt` (page map) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed; on the earlier 11-page EB Garamond render, before fb-595.68) |
| typeface | face required: none (NECivR names no typeface). Substitute: none; Times New Roman, the house standard (`docs/FONTS.md` rule 6), in typst and docx. Fit: n/a. The exemplar is Times New Roman too (see Known gaps, 1). |
| tier 2 | not yet judged against 2 or 3 filers: one exemplar only (see Known gaps, 2) |

## Governing rules

Each rule was read from the primary source on 2026-10-14. The District's rules are in the Civil Rules "Effective December 1, 2021".

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. | `court-title`, `caption` (`case_number`, `caption.parties`, `brief_title`). |
| Fed. R. Civ. P. 10(b) (same URL) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph; headings and the prayer are not numbered. |
| NECivR 10.1(a)(3) (https://www.ned.uscourts.gov/sites/default/files/documents/10.1.pdf) | The caption shows the paper's contents and the party filing it; a jury demand must be noted in the caption. | `caption`: "Jury Trial Demanded" when `jury_demand: true`; the title and case number. |
| NECivR 11.1(a)(1)(A) (https://www.ned.uscourts.gov/sites/default/files/documents/11.1.pdf) | Electronic signature "s/ (attorney name)", then Bar Number, Attorney for, firm, address, telephone, fax, e-mail. | `signature-block` (in that order; `signature` frontmatter). |
| NECivR 10.1(b)(1) (same 10.1 URL) | Paper filings: 8½ × 11 white paper, a 2-inch top margin on the first page for the clerk's stamp. | Page size only. The 2-inch margin is not applied: it governs nonelectronic filings (10.1(b)), and the ECF stamp is applied by the court. |
| NECivR 7.1(d)(1)(A) and (d)(3) | 13,000-word limit for a supporting brief; certificate of compliance. | Not a complaint rule. See the motion-brief README. |

The District's civil rules have no font, type-size, line-spacing, or margin requirement, apart from NECivR 10.1(b)(1). The layout below is therefore a convention drawn from the filed exemplar, not a rule.

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Fed. R. Civ. P. 7.1 disclosure statement; the summons; any Rule 5.2 redaction (the author must redact before filing).

## Layout

- US Letter, 1-inch margins on all sides. Times New Roman 12 pt (the pinned install, `docs/FONTS.md` rule 1; see Known gaps, 1).
- Double spacing: 27.6 pt baseline pitch (`pitch-double`, Word's double in this face). Single spacing (13.8 pt, `pitch-single`) for the counsel block, the caption, the signature block and claim sub-lines.
- Counsel block at the top left, single-spaced (the exemplar's convention, not a rule).
- Court title on two centered lines: "IN THE UNITED STATES DISTRICT COURT" / "FOR THE DISTRICT OF NEBRASKA".
- Caption: a two-column box. The party column has a right and bottom rule; "v." between the parties; each party's designation indented. The right column has the case number, the bold title, "Jury Trial Demanded" (when set), and the trial location (when set).
- Body: numbered paragraphs with a 0.5-inch first-line indent; centered bold caps section headings; claim sub-lines (level 3) single-spaced under the claim heading.
- Prayer items are lettered A., B., ... (a markdown list in the sample, lettered by the template).
- Signature block after the prayer and the jury demand, with "Dated:" on the left.
- Footer from page 2 on: the page number centered; below it the title in capitals at left and "Case No." at right. Page 1 has no footer, as in the exemplar.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`), `brief_title`, `footer_title`, `counsel` (lines; `*...*` for italic), `jury_demand` (bool), `trial_location` (optional), `division` (optional), `date`, `signature` (`signer`, `bar_number`, `attorney_for`, `firm` lines).
- `#` = centered bold caps section heading; `##` = centered bold sub-heading; `###` = claim sub-line (centered, single-spaced). Put each heading in its own blank-line-separated chunk, or it is read as one.
- A blank-line-separated paragraph is a numbered paragraph. A paragraph starting with `^ ` is unnumbered (used for the WHEREFORE lead-in and the jury-demand sentence, which the exemplar does not number).
- A list (`1.` items) is the prayer, lettered A., B., ... by the template.
- The sample does not carry the numbers: the template numbers the paragraphs.

## What the overlay shows

`OVERLAY-goldenstein-complaint.pdf` (measured on the earlier EB Garamond render, before fb-595.68): red is our render, blue is the filed exemplar, black is where both agree. Pages are paired by shared words, not by index (`overlay.sh`). Page 1 pairs at 99%, pages 2 and 3 at 81–91%. Pages 4 to 11 pair at 31–88%: the exemplar's line breaks and page breaks fall differently in Times New Roman than in EB Garamond, so the blue and red text drift against each other by a line or more. The overlay is a diagnostic, not a score; the map (`.txt`) says which filed page each sample page was paired with.

## Known gaps and open choices

1. **Font.** The District's rules name no font: NECivR 7.1 and 10.1 in the 2022 text (`NECivR.2022.pdf`, read 2026-10-14) contain no typeface, type-size or spacing rule beyond 10.1(b)(1)'s paper size and top margin. `docs/FONTS.md` rule 6 makes Times New Roman the house standard where the rules name no face, so the template (typst and docx) is set in it, as the exemplar is. The template's EB Garamond, used until fb-595.68, looked smaller than the exemplar at the same 12 pt (a smaller x-height).
2. **One exemplar.** Tier 2 asks for 2 or 3 filers. Harrison v. Bang, No. 8:26-cv-00501 (10 pp., another attorney, a different caption convention) is the likely second filer; it is listed in `usage/SOURCE.md` but not saved, per the one-exemplar rule.
3. **Signature label.** NECivR 11.1(a)(1)(A) gives "s/ Judith Attorney" with no "By:" label. The exemplar writes "By: /s/". The template follows the rule.
4. **Counsel block.** Its placement is the exemplar's; the District does not require one.
5. **No pleading paper.** The exemplar has none, and the District has no line-number rule. The template uses no line numbers.
6. **Case names are roman** in the sample (the exemplar's text layer has no italic markup for them), so the overlay shows no difference there; the template supports `*...*` for italic.
7. **Trial location.** "Trial Location: Omaha" appears in the exemplar's caption. No D. Neb. rule requires it; the template shows it only when `trial_location` is set.
8. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder has neither. The brief forbids editing `tools/`, so the gates were not run; render, overlay and the page review above are this doc type's record.
9. **Heading fit.** Level-3 claim sub-lines and level-1 headings may wrap; the template does not assert a single line.

## Review of the rendered pages (the earlier EB Garamond render, before fb-595.68)

- Page 1: counsel block, court title, caption box with "Jury Trial Demanded" and "Trial Location: Omaha", "INTRODUCTION", paragraphs 1 and 2. No footer. Pass.
- Page 2: paragraphs 3 to 9; "JURISDICTION AND VENUE" and "PARTIES" headings with a double-spaced line above and no text overlap; footer with page 2, title and case number. Pass.
- Page 3: paragraphs 10 to 18; "THE PAGE IS A GOVERNMENT FORUM". Pass.
- Page 4: paragraphs 19 to 28; "FACTUAL ALLEGATIONS". Pass.
- Page 5: paragraphs 29 to 36. Pass.
- Page 6: paragraphs 37 to 45. Pass.
- Page 7: paragraphs 46 to 53. Pass.
- Page 8: paragraphs 54 to 62; "MUNICIPAL LIABILITY". Pass.
- Page 9: paragraphs 63 to 72; "FIRST CLAIM FOR RELIEF" and "SECOND CLAIM FOR RELIEF" with their single-spaced sub-lines ("Violation of the First and Fourteenth Amendments", the theory, "42 U.S.C. § 1983", "(Against Defendant City of Ashland)"); no heading at the foot of the page. Pass.
- Page 10: paragraph 73; "PRAYER FOR RELIEF", WHEREFORE lead-in unnumbered, items A. to J. with their wrapped lines, the whole prayer on one page. Pass.
- Page 11: "DEMAND FOR JURY TRIAL" with its unnumbered sentence; "Dated" and "Respectfully submitted", the NECivR 11.1 signature block. Pass.

Defects found in review and fixed before this render: headings were drawn over the first line of the paragraph after them; paragraphs ran together with no line between them; a counter displayed inside a block measured one line short and overlapped the next paragraph. Each is fixed in `typst/ned-complaint.typ`.

File names follow `tools/render.sh` and `tools/overlay.sh` (and CLAUDE.md's role prefixes): `INPUT-complaint.md` (input), `OUTPUT-complaint.typst.pdf` (our render), `OVERLAY-goldenstein-complaint.pdf` and `.txt` (the comparison). The brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools write.

## Engines

| Engine | Folder | Output in `usage/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-complaint.typst.pdf` (12 pages) | the reference |
| docx | `docx/` (`reference.xml`, from which `fb render --engine docx` builds the reference document: the cross-engine recipe, `base="xengine"`, in the typst template's face; and `ned-complaint.lua`) | `OUTPUT-complaint.docx` and `OUTPUT-complaint.docx.pdf` (12 pages, LibreOffice headless) | rendered; every page of the `.docx.pdf` viewed against the typst render (on the earlier EB Garamond render) |

**Matches typst** (checked on the LibreOffice PDF of the earlier EB Garamond render, before fb-595.68; the face is now Times New Roman 12 pt in both, embedded per `pdffonts`): double spacing at 24 pt; 1-inch margins on US Letter; the counsel block; the two court-title lines; the caption as a table with a right and a bottom rule on the party column, "v." between the parties, indented designations, the case number, the bold title, "Jury Trial Demanded" and the trial location; centered bold capitals for level-1 headings; numbered allegations with a half-inch first-line indent; the prayer lettered A., B., ...; the signature block in NECivR 11.1 order with "Dated" at left; the footer from page 2 on (page number centered, the title in capitals, "Case No." at right) and no footer on page 1. The text matches typst word for word (the extracted text of both PDFs, compared without whitespace and footers, differs by one character at a page boundary). Some line breaks fall one word differently from typst.

**Differs from typst:**
- Pagination (on the earlier EB Garamond render, before fb-595.68; the committed renders are 12 pages each). The docx ran 12 pages against typst's 11. LibreOffice sets each baseline about 4 pt lower inside 24 pt exact lines, so a page holds one body line fewer. Page breaks are not forced (DOCX.md, "Known limits").
- The footer title and case number are document properties (`subject`, `description`) shown by the `SUBJECT` and `COMMENTS` fields. A copy of the `.docx` that drops its properties drops its footer text.
- Word was not available. The `.docx` was converted and checked in LibreOffice only.

**docx BLOCKED:** `tools/check.sh --engine docx` (Gates 0 to 3) was not run. This folder has no `rules.md` or `checks.yaml`, and the brief forbids adding them or changing `tools/`. So no docx check ID is green or red: `BLOCKED: check.sh (all gates): no rules.md / checks.yaml in this folder; gates not run`.
