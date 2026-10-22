# vaed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Virginia (`vaed`).
Folder: `courts/fourth-circuit/virginia/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (transcription of selected parts of the 23-page filing; see Known gaps) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (the earlier EB Garamond render, before fb-595.68; the template now sets Times New Roman) |
| typeface | Rule names no face: L.R. 7(F)(3) says "12 point Roman style or 10 pitch Courier style". Any proportional serif is allowed; the template sets Times New Roman (`docs/FONTS.md` rule 6, the house standard; the pinned install, Liberation Serif from `fonts/` as fallback). The 2026-10-14 font check (`pdffonts`: EB Garamond only) was on the earlier render; the committed typst and docx PDFs embed TimesNewRomanPSMT. |
| overlay | fail: `tools/overlay.sh` needs the filed exemplar PDF, and `usage/` holds only `SOURCE.md` (the PDF is not in this snapshot). Old `OVERLAY-tamaris-complaint.txt` is from an earlier run and is not current. |
| pages reviewed | 8 of 8 (the earlier EB Garamond render, re-rendered 2026-10-14; every page rasterized at 70 dpi and viewed) |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Va. Local Civil Rule 7(B) | "All pleadings and motions shall include the attorney's office address and telephone number." | The `signature.lines` in the sample: firm, street address, city and state, telephone. |
| E.D. Va. Local Civil Rule 7(C)(1) | Redaction of personal identifiers is governed by Fed. R. Civ. P. 5.2. | Author content. The template does not check it. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, and Rule 7(a) designation. | `court`, `caption` (party box), `case_number`, `brief_title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every body paragraph is numbered by the template (`vaed-complaint.typ`, the `n` counter). Headings and the prayer list are not numbered. |
| Fed. R. Civ. P. 8(a)(2) | "A short and plain statement of the claim showing that the pleader is entitled to relief." | Author content. The template does not check it. |
| E.D. Va. Local Civil Rule 7(F)(3) | All briefs, including footnotes, in 12 point Roman, one-inch margins, double-spaced. | Applied here by convention, see below. |

Sources:
- E.D. Va. Local Civil Rules, last amended December 1, 2024: https://www.vaed.uscourts.gov/sites/vaed/files/Local%20Rules%20EDVA%20December%201%202024.pdf (the court's Local Rules page says "last amended on December 1, 2024"; the same Rule 7(B) and 7(F)(3) text is in the January 18, 2023 PDF).
- Fed. R. Civ. P. 10: https://www.law.cornell.edu/rules/frcp/rule_10
- Fed. R. Civ. P. 8: https://www.law.cornell.edu/rules/frcp/rule_8

Notes on what the rules do not say:
- Local Civil Rule 7(F)(3) applies to "briefs". It does not name complaints. The template uses the same typography (12 point Roman, one-inch margins, double-spacing) because the exemplar does and because no Eastern District complaint typography rule was found. This is an inference and is recorded as such.
- No pleading-paper or numbered-line rule was found in the Local Civil Rules, so the template has no line numbers. Local Civil Rule 5 is about sealing, not format.
- No page limit for a complaint was found in the Local Civil Rules; the 30-page cap in Local Civil Rule 7(F)(3) is for briefs (see `motion-brief/`).

Not produced by this template (separate filings that may be required with a first complaint): the civil cover sheet (JS-44), the summons, and the disclosure statement under Fed. R. Civ. P. 7.1 (and any corresponding E.D. Va. Local Civil Rule 7.1 form, which the Local Rules reference as "Local Civil Rule 7.1(A)"). Also not produced: the ECF header stamp, which the court's system adds to every page of the filed PDF.

## Layout

- Court title (3 lines), bold, single-spaced, centered.
- Caption: party box on the left (all four sides ruled), case number on the right, vertically centered.
- Title of the paper, bold, centered.
- Body: double-spaced (24 pt baseline pitch at 12 pt, measured in the render), numbered paragraphs with the number at a 0.5 inch indent, wrapped lines to the left margin.
- Headings: level 1 centered bold caps (`# ...`); level 2 bold, left, with any "I." or "A." label hanging (`## I. ...`).
- Prayer items: markdown list, lettered A., B., ... (hanging).
- Signature block: "Dated:" line, party block (optional), "By:" line, counsel lines; single-spaced; kept together so it does not split.
- Page number centered in the footer, 12 point.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (level 1 centered caps), `##` or `###` heading (bold, label hangs), a list (`1.` items, lettered by the template), a paragraph (numbered by the template), or a paragraph starting with `>` (unnumbered, indented; used for WHEREFORE).
- Frontmatter: `court` (list of lines), `caption.parties` (list of `{lines, designation}`; "v." is inserted between entries), `caption.case_number`, `brief_title`, `lead_in` (unnumbered lead-in paragraph, optional), `signature` (`date`, `closing`, `party`, `by`, `lines`).
- Values with a colon must be quoted (YAML).
- Not supported: tables, footnotes, raw typst. The sample must not put numbers in the text; the template numbers the allegations.

## Known gaps and open choices

1. **Tier 2 is judged against one filer only.** The brief and EVAL-LOOP ask for 2 or 3 filers. Found and not saved: *Warren v. Bloomberg Industry Group, Inc.*, No. 1:26-cv-03349 (E.D. Va., Alexandria), Document 1, 14 pages, filed 2026-10-06 by counsel Adam Nadelhaft (see `usage/SOURCE.md`). It was not transcribed. The overlay pairs against the first file in `usage/`, so a second file there would change the default pairing. Recorded as an open gap for David.
2. **The sample is a selection, not the whole filing.** It carries the filing's text for the caption and lead-in; the nature of the suit; the parties; jurisdiction and venue (filed ¶¶ 7 to 15); plaintiff's rights (filed ¶¶ 16 to 24, approximately: the text layer of those paragraphs is fragmented, so the numbers were matched by reading, with the enforcement-case citations replaced by "(Citations omitted.)" and the image paragraph 18 omitted); the website facts (filed ¶¶ 36 to 41); Count One (filed ¶¶ 53 to 57), Count Two (filed ¶¶ 62 to 64), Count Three (filed ¶¶ 71 to 75); the prayer (items A to H, with the sub-items of item E condensed); and the signature. Omitted: filed ¶¶ 42 to 52, 58 to 61, 65 to 70 and 76 onward, the rest of the prayer's sub-items, and the exhibit references. The sample numbers its allegations from 1 in order, so its paragraph numbers do not match the filed numbers.
3. **Font.** Tier 1 asks for a 12 point Roman face. The rule names no face ("Roman style"); the template sets Times New Roman (`docs/FONTS.md` rule 6, David's 2026-10-17 house standard), which also matches the Times-style exemplar. (Until fb-595.68 it kept EB Garamond, whose smaller x-height made the text look smaller than the exemplar; the question whether to switch, then recorded as ACCEPTED, is settled by that rule.)
4. **Signature.** The exemplar's signature line carries a handwritten-style mark ("AZ") before the name. The sample writes "By: Attison L. Barnes, III" and does not transcribe the mark.
5. **Caption.** The party box is closed on all four sides. The exemplar's box is also closed. Recorded as ACCEPTED.
6. **Signature block and the last paragraph.** The complaint template keeps the signature block together but does not keep the last paragraph with it (the motion template does). The sample's signature sits on the page with the prayer, so this did not show; it is a known gap.
7. **Overlay pairing.** The sample is shorter than the filing, so the word-overlap figures in `OVERLAY-tamaris-complaint.txt` are low on pages 4 to 8 (the pairing is by shared words, not by content). The overlay is a diagnostic, not a score.
8. **Output file names.** `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`, and `OVERLAY-<id>.txt`. The task brief asked for `<id>.pdf` and `<id>-overlay.pdf`; the tool defaults were followed.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and `tools/` is out of scope. Render and overlay were run; the page review below is the Gate 2 equivalent.

## Review of the rendered pages (final, 2026-10-14; the earlier EB Garamond render, before fb-595.68)

- Page 1: court title, caption box with designations, "COMPLAINT", lead-in, first numbered paragraph under NATURE OF THE SUIT. Pass.
- Page 2: numbered paragraphs 2 to 9, PARTIES and JURISDICTION headings centered bold. "§" no longer breaks from its number. Pass.
- Page 3: paragraphs 10 to 16, no heading at the foot. Pass.
- Page 4: paragraphs 17 to 24, PLAINTIFF'S RIGHTS centered bold. Pass.
- Page 5: paragraphs 25 to 30, two-line centered heading DEFENDANTS' WEBSITE DISPLAYS... wraps cleanly. Pass.
- Page 6: paragraphs 31 to 38, COUNT ONE and COUNT TWO centered bold. Pass.
- Page 7: paragraphs 39 to 43, COUNT THREE, PRAYER FOR RELIEF, WHEREFORE paragraph (unnumbered), items A to D. Pass.
- Page 8: items E to H, "Dated:" line, "By:" line, counsel block single-spaced. Pass.

## Engines

DOCX (`docx/`): `reference.xml` (`base="xengine"`: fb render builds the reference document from the shared cross-engine recipe in the typst face), filter `docx/vaed-complaint.lua`. Output `usage/OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice conversion). Pages reviewed (on the earlier build by `docx/build-reference.sh`, before fb-595.68): 8 of 8 in the docx PDF and 8 of 8 in the typst PDF, at 60 dpi.

- Matches the typst form: Times New Roman 12 pt only (`pdffonts`: TimesNewRomanPSMT); letter, 1 in margins; body at an exact 24 pt pitch; 0.5 in first-line indent; caption party box with four rules and the case number at right; numbered allegations; lettered prayer items with a hanging indent; signature block single-spaced at 3.25 in and kept together; centered PAGE number at 12 pt. Page breaks fall in the same places on all 8 pages.
- Differs (recorded on the earlier build, before the fb-595.68 cross-engine port; `eval.yaml` now gates the docx on typst's line and page breaks): the court heading is single-spaced (13.8 pt) in the docx. The typst court heading renders at about 23 pt pitch, although its comment says single, so the typst caption sits lower on page 1. The number-to-text gap is a tab stop at 1 in (typst: 0.25 in after the number). LibreOffice breaks a line after the hyphen in "1-8" where typst does not.
- Not verified: Word. The file was converted by LibreOffice 26.8 and was not opened in Word, so the no-repair-prompt check is not done.
- BLOCKED: `tools/check.sh --engine docx` (all gates) cannot run on this folder: it exits 2 because the court folder has no `checks.yaml` and no rules file (`court.json` is at the court level). No gate result and no stamp.
