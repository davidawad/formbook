# ctd: complaint

Doc type: **complaint** (Complaint and Demand for Jury Trial) in the United States District Court for the District of Connecticut (`ctd`). Folder: `courts/second-circuit/connecticut/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `exemplars/FILED-EXAMPLE-forzano-3-26-cv-00665-complaint.pdf` (see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-forzano-complaint.md`, the whole filing: caption, lead-in, all 66 paragraphs, five causes of action, prayer, jury demand, signature block |
| render | ok: `samples/OUTPUT-forzano-complaint.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond Regular and Bold, embedded), no typst warnings |
| typeface | no face named by the rules; EB Garamond kept (vendored, embedded). See Known gaps 2 |
| overlay | ok: `samples/OVERLAY-forzano-complaint.pdf` and `OVERLAY-forzano-complaint.txt` (pairs by text; exemplar PDF `exemplars/FILED-EXAMPLE-forzano-3-26-cv-00665-complaint.pdf` fetched from the SOURCE.md URL on 2026-10-15) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi to PNG and viewed on 2026-10-15) |

Commands (run with `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/second-circuit/connecticut/federal/district/complaint samples/INPUT-forzano-complaint.md
sh tools/overlay.sh courts/second-circuit/connecticut/federal/district/complaint forzano-complaint
```

File names follow the repo tools rather than the brief's `<id>.pdf` and `<id>-overlay.pdf`: `render.sh` writes `OUTPUT-<id>.pdf` and `overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt` by default, and the tools are not to be edited here. The sample is `INPUT-<id>.md`, as in the other courts.

## Governing rules

Primary sources, fetched 2026-10-14:
- D. Conn. Local Rules of Civil Procedure (as amended; the rules PDF "Current-Revised-Local-Rules-9.4.26"), https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-9.4.26.pdf (linked from https://www.ctd.uscourts.gov/court-info/local-rules-and-orders). Rule 10 and Rule 7(a)(5) quoted below.
- Electronic Filing Policies and Procedures, rev. Oct. 3, 2025, https://www.ctd.uscourts.gov/sites/default/files/Electronic-Filing-Policies-and-Procedures-10.3.25.pdf (sections I.F, II and XI).
- Fed. R. Civ. P. 8, 10, retrieved from https://www.law.cornell.edu/rules/frcp/rule_8 and rule_10.

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| CTD-FORM-001 | D. Conn. L. Civ. R. 10 | "Pleadings shall be double-spaced, on 8-1/2" by 11" pages." | `line-pitch = 27.6pt`, `body-leading = 1.65em`. 27.6 pt is 2 x 13.8 pt, the single line of 12 pt Times in Word; the exemplar measures 27.6 pt pitch. Checked on the render with `pdftotext -bbox`: every body line 27.6 pt apart. |
| CTD-FORM-002 | L. Civ. R. 7(a)(5) (memoranda); L. Civ. R. 10 (pleadings, silent on size) | Text at least 12 point "unless otherwise ordered". | `type-size = 12pt`. The 12 pt size is taken from L. Civ. R. 7(a)(5), which sets it for memoranda; for pleadings it is a convention that matches the exemplar. |
| CTD-FORM-003 | EFPP I.F.2 (fonts) | PDF records must embed every font; base-14 fonts (Times New Roman among them) need no embedding, others must be embedded and legally embeddable. | EB Garamond is vendored (OFL) and embedded as subsets (`pdffonts`). Not Times New Roman: see Known gaps. |
| CTD-FORM-004 | L. Civ. R. 10 | "margins of at least 1"" (left and right); the template uses 1 inch on all sides. | `margin = 1in`. |
| CTD-FORM-005 | L. Civ. R. 10 | "page numbers in the bottom margin of each page after page 1." | `footer`: centred number, suppressed on page 1 (`counter(page).get().first() > 1`). |
| CTD-FIRST-001 | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. | `court` (two lines, from the sample), `caption.parties` (every party named, with designation), `brief_title`, `case_number`. |
| CTD-FIRST-002 | L. Civ. R. 10 | "The complete docket number, including the initials of the Judge to whom the case has been assigned, shall be typed on each pleading. The date of each pleading shall be included in the case caption." | `case_number` must include the judge's initials (the template prints it as given); `date` printed in the caption right column (`Date:`). |
| CTD-PARA-001 | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph 1, 2, ... from the Markdown, with a hanging number at 0.5 in. Headings and lists are not numbered. `[unnumbered]` marks the wherefore clause and the jury demand. |
| CTD-SIG-001 | L. Civ. R. 10; EFPP XI.B | Signature block: "/s/" name of the password registrant, typewritten name, office address, telephone, fax (if available), e-mail, federal bar number. | `signature` (`signer`, `bar`, `lines`); `signature-block()` prints "/s/ name", "name, Fed. Bar No. bar", then the lines. |
| CTD-SIG-002 | L. Civ. R. 10 | "The date of each pleading shall be included in the case caption." | `date`, printed as "Dated:" in the signature block and in the caption. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the summons, a Rule 7.1 disclosure statement, and any certification of interested parties the judge requires. Not checked: a jury demand under Fed. R. Civ. P. 38 (the demand is written as in the exemplar; the rule text was not fetched in this pass).

## Layout

- US Letter, 1 inch on every side. No pleading paper: D. Conn. has no numbered-line rule (L. Civ. R. 10 requires double spacing and nothing more). The exemplar has none.
- Caption on page 1 with the court title, a left party column (rule on the right and bottom), and the right column with case number, date and title. Page 1 starts the body under the caption (no separate cover page), as in the exemplar.
- Numbered paragraphs: first line indented 0.5 in, number, then text. Continuation lines return to the margin, as in the exemplar.
- Each paragraph ends with a gap of one leading, so n lines take exactly n pitches (27.6 pt); headings are rounded to whole pitches (`on-grid`). This is why paragraphs stay on the grid; typst's `leading` alone leaves the gap after the last line out of the block height.
- Headings: level 1 is a centred bold caps heading, level 2 a centred bold sub-heading (the cause-of-action title), level 3 bold italic. A heading is sticky: it never ends a page.
- Bullets stay bullets; ordered lists are lettered (a), (b), ... (the prayer, and any quoted statute).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (with judge initials), `court` (list of lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `lead_in` (unnumbered lead-in paragraph, optional), `jury_demand` (true puts "DEMAND FOR JURY TRIAL" in the caption), `date`, `signature` (`signer`, `bar` (optional), `lines`).
- Body: blank-line-separated chunks. `#` = level 1 heading, `##` = level 2, `###` = level 3. A chunk starting `1. `, `- ` or `* ` is a list. Any other chunk is a numbered paragraph. A chunk beginning with `[unnumbered]` is an unnumbered paragraph.
- Do not put paragraph numbers in the text: a chunk that starts `12. ` is read as a list and lettered. The sample's paragraph numbers were stripped for this reason.

## Known gaps and open choices

1. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers, each a different filer, before tier 2 is judged. The brief asks for one exemplar per doc type. Other D. Conn. complaints checked for a second reference are listed in `exemplars/SOURCE.md` and were not saved. Tier 2 is therefore judged against the rules and this one filing, and that is not the full bar.
2. **Font.** No rule text read for this doc type names a face. EFPP I.F.2 (fetched 2026-10-15) lists Times New Roman among the base-14 fonts only as fonts that need not be embedded; it sets no typeface. Local Rule 10 names none in the text checked (the 9.4.26 rules PDF cited above returned 404 on 2026-10-15; a 2016 copy of Rule 10 on courtrules.net names none; re-verify against the live rules). The exemplar is set in Times New Roman, which is a convention, not a rule. Per `docs/FONTS.md`, a court that names no face keeps EB Garamond, so the template keeps it (embedded, legally embeddable). Liberation Serif, the Times-metric substitute, is vendored and would match the exemplar's line breaks, but it is not used because no rule calls for it. Judge-specific orders are a separate matter: see the note in `motion-brief/README.md` Known gaps 4 (Judge Bryant's 2018 Electronic Filing Order names Arial 12 pt for documents in that judge's cases; that is one judge's order, not a court rule, and the template does not switch per judge).
3. **Pleading size.** L. Civ. R. 10 is silent on type size for pleadings. 12 pt is used, matching the exemplar and L. Civ. R. 7(a)(5).
4. **Judge initials.** The template prints `case_number` as given; the template does not check that it has the judge's initials. The sample's number carries them.
5. **Date in the caption.** The exemplar's caption has no date; L. Civ. R. 10 requires one. The template follows the rule, so the render has a date line that the exemplar lacks. The sample's date is the ECF filing date from the page header.
6. **Overlay pairing.** `overlay.sh` pairs pages by word overlap. The render has 11 pages and the exemplar 11, but the lines differ (EB Garamond, different line breaks). The overlay is a diagnostic, not a score.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root; this doc-type folder has neither, and the brief forbids touching `tools/`. The gates were not run. Render, overlay and the page review are the Gate 2 equivalent for this doc type.
8. **Bullets versus numbers.** The exemplar's paragraph 19 is a bulleted list; the render keeps bullets. Its prayer and the quoted statute in paragraph 34 are lettered, as in the cand template. The exemplar letters its prayer as (a) to (h); the sample reproduces the split between "d." and "e." as filed.
9. **Typographical errors kept.** "Plaintiffs drives" (paragraph 9), "Plaintiffs incorporates" (paragraph 39), "reliablity" (paragraph 23) and similar are in the sample as filed. They are the exemplar's text, not the template's.
10. **Signature block.** "Fed. Bar No." is the template's label for the bar number (the exemplar prints "ct28597" alone); the exemplar has no fax number, and the template prints a fax line only if the sample supplies one.

## Review of the rendered pages (11 of 11, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (parties with indented designations; right column case number, date, title), lead-in, INTRODUCTION, paragraphs 1 to 7 | OK. Caption rule right and bottom. No overlap after the grid fix. |
| 2 | JURISDICTION AND VENUE, PARTIES, FACTUAL ALLEGATIONS, paragraphs 8 to 16 | OK. Numbers at 0.5 in, text on the 27.6 pt grid. |
| 3 | Paragraphs 17 to 19 and the first three repair bullets | OK. Bullets keep their indent. |
| 4 | Remaining repair bullets, paragraphs 20 to 22 | OK. |
| 5 | Paragraph 23; FIRST CAUSE OF ACTION (level 1 and level 2 sub-heading), paragraphs 24 to 32 | OK. The two-line sub-heading is on the grid. |
| 6 | Paragraphs 33 to 38; the quoted statute as list item (a) | OK. The list is a block of single-line-leading items closed on the grid. |
| 7 | SECOND CAUSE OF ACTION, paragraphs 39 to 46 | OK. |
| 8 | THIRD CAUSE OF ACTION, paragraphs 47 to 54 | OK. Heading at the top of the page is kept with its paragraph. |
| 9 | Paragraph 54 end; FOURTH and FIFTH CAUSES OF ACTION; paragraphs 55 to 61 | OK. |
| 10 | Paragraphs 62 to 66; PRAYER FOR RELIEF with the wherefore clause (unnumbered) and items (a) to (f) | OK. Item (d) ends "by the" and (e) begins "Court", as filed. |
| 11 | Items (g) and (h); DEMAND FOR JURY TRIAL; "Dated" and signature block (/s/, name with bar number, firm, address, phone, e-mail) | OK. Page number shown. |

## Engines

**docx** (`docx/`): `sh docx/build-reference.sh docx/reference.docx` builds the reference (EB Garamond 12 pt, exact 27.6 pt double-spaced lines, 1 in margins, centred page number from page 2); `docx/complaint.lua` writes the cover (court, caption table with its rules), the numbered paragraphs (typed numbers), the lettered and bulleted lists and the signature block. Output: `samples/OUTPUT-forzano-complaint.docx` and `.docx.pdf` (LibreOffice 26.8, `pdffonts`: EBGaramond Regular and Bold, embedded), 11 pages, the same count as the typst render.

- Matches the typst output: US Letter; 1 in margins; EB Garamond 12 pt; every body line on the 27.6 pt pitch (measured on the PDF: 27.6 pt between body lines, as in typst); no widow control, as in typst, so the page breaks fall where typst's do; caption with the party column ruled right and bottom and the case number, date, title and jury demand at right; unnumbered lead-in, prayer and jury demand; lettered prayer items (a) to (h); bullets in paragraph 19; signature block at the right with "Dated" at left; no page number on page 1.
- Differs from typst: in Word and LibreOffice an exact-spaced line puts its text lower in the line box than typst does, so the first line of each page (and the court title) sits about 14 pt lower; the paragraph pitch is unchanged. The paragraph number is followed by a tab stop at 1 in, where typst's text position follows the width of the number; the sample's numbers are one or two digits, so the text starts at the same place. Table borders are drawn by Word and by LibreOffice slightly differently; judged on the LibreOffice PDF.
- Not verified in Word (only LibreOffice here). The `.docx` is a valid zip of well-formed XML; every style it uses is defined in `reference.docx`; `[unnumbered]` markers are removed from the text.

Gate 2 review of the docx PDF (11 of 11 pages rendered at 60 dpi and viewed on 2026-10-15; typst pages viewed alongside):

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (parties, Case No., Date, title), lead-in, paragraphs 1 to 5 | OK. Caption rules right and bottom. Text sits lower in the lines than typst (see above). |
| 2 | Paragraphs 6 to 15; PARTIES, FACTUAL ALLEGATIONS headings | OK |
| 3 | Paragraphs 16 to 19 and the first repair bullets | OK |
| 4 | Repair bullets continue | OK |
| 5 | Paragraphs 20 to 32; FIRST CAUSE OF ACTION heading and sub-heading | OK |
| 6 | Paragraphs 31 to 37; the quoted statute as item (a) | OK |
| 7 | Paragraphs 38 to 44; SECOND CAUSE OF ACTION heading | OK |
| 8 | Paragraphs 45 to 52; THIRD CAUSE OF ACTION heading | OK |
| 9 | Paragraphs 53 to 59; FOURTH CAUSE OF ACTION heading | OK |
| 10 | Paragraphs 60 to 66; FIFTH CAUSE OF ACTION; PRAYER FOR RELIEF with (a) and (b) | OK |
| 11 | Prayer items (c) to (h); DEMAND FOR JURY TRIAL; "Dated" and the signature block | OK. Page number shown. |

BLOCKED: check.sh (Gates 0 to 3, docx): `tools/check.sh` reads `<court-dir>/court.json` and `checks.yaml`, and a doc-type folder has neither (the court folder has `court.json` but no `checks.yaml` or `rules.md` yet), so the gates did not run and `samples/.check-docx.txt` was not written. Gate 0 was checked by hand: every word of the sample is in the PDF except the `[unnumbered]` markers, which are not text.
