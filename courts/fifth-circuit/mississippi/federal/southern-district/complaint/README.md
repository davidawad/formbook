# S.D. Miss. (mssd): complaint

Doc type: **complaint** in the United States District Court for the Southern District of Mississippi (`mssd`).
Folder: `courts/fifth-circuit/mississippi/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (plaintiff's counsel; see `usage/SOURCE.md`). A second filer is saved too: `usage/FILED-EXAMPLE-complaint-2.pdf` (19 pp., not transcribed). |
| sample md | `usage/INPUT-complaint.md`: the whole filing transcribed (10 pages, paragraphs 1 to 56, the prayer, the jury demand and the signature block). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 10 pages, typst 0.15.0 via `tools/render.sh`, vendored EB Garamond only, no typst warnings. |
| overlay | ok: `usage/OVERLAY-mariano-complaint.pdf` and `usage/OVERLAY-mariano-complaint.txt` (`tools/overlay.sh`). |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed; see the review below). |

The file names follow the tools' conventions (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default and the brief bars editing `tools/`.

## Governing rules

Sources, fetched 2026-10-14:

- S.D. Miss. and N.D. Miss. Local Uniform Civil Rules (the "2024 Local Civil Rules MSSD MSND" PDF, 164 pp.), linked from https://www.mssd.uscourts.gov/court-info/local-rules-and-orders/local-rules: `https://www.mssd.uscourts.gov/sites/mssd/files/2024%20Local%20Civil%20Rules%20MSSD%20MSND%20%28.pdf%29.pdf`. The same page links an "InternalRule1Amended_6-26-26.pdf" that was not checked for civil-rule changes.
- Fed. R. Civ. P. 5, 8, 10: https://www.law.cornell.edu/rules/frcp/rule_5, `rule_8`, `rule_10` (text checked against the Cornell copies on 2026-10-14).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court` (three lines, bold caps), `caption` (party names, "v.", designations), `case_number` ("CIVIL ACTION NO."), `brief_title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered 1, 2, ... by the template; headings and lists are not numbered. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the claim. | Content of the sample only; the template does not check it. |
| L.U.Civ.R. 11(a) | Every signed filing shows counsel's name, address, telephone, fax number, e-mail and bar membership number. | `signature-block()`: asserts each key in `signature` (`signer`, `bar_no`, `firm`, `address`, `telephone`, `fax`, `email`); a missing key fails the render (tested, see below). |
| L.U.Civ.R. 38(a) | A jury demand must be made in the pleading; a designation on the civil cover sheet is not enough. | Caption title "... AND DEMAND FOR JURY TRIAL"; the numbered paragraph "VI. DEMAND FOR JURY TRIAL" (paragraph 55 in the exemplar). |
| L.U.Civ.R. 5(a)(1), (a)(2) | A civil cover sheet (JS-44) and the filing fee with each original complaint. | Not produced: separate filings. |
| L.U.Civ.R. 7(c) | A non-governmental corporate party files a corporate disclosure statement with its initial pleading. | Not produced: a separate pleading. |
| Fed. R. Civ. P. 7.1 | Disclosure statement. | Not produced: a separate filing. |
| Fed. R. Civ. P. 5.2 (L.U.Civ.R. 5.2) | Redaction of personal identifiers (SSN, birth date, account numbers; a minor by initials). | Not checked by the template. The sample's filing names no minor and uses no identifier. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required for a paper served by filing it through the e-filing system. | No certificate. A complaint is served with the summons under Rule 4, so the template has none. |

## Layout

- Letter paper, 1 inch margins on all four sides, page number centered in the bottom margin. The local rules set no pleading-paper (numbered-line) format for complaints, and the exemplar has none, so the template has none.
- Court title: three lines, bold caps, centered (from the sample's `court` list).
- Caption: the parties in a left column, with "v." on its own line between the parties; "CIVIL ACTION NO." and the case number on the right.
- Title of the paper: bold, underlined, centered caps.
- Body: double spaced. The line pitch is 27.6 pt, the same as the exemplar's measured pitch (`pdftotext -bbox`: 27.5 to 27.8 pt gaps). Each numbered paragraph has a first-line indent of 0.5 inch.
- Section headings ("I. NATURE OF THE ACTION"): bold caps, centered. Count headings ("COUNT I – ..."): bold, centered. A heading stays with the paragraph after it.
- Lettered lists ("a.", "b.", ...) under a numbered paragraph, and in the prayer for relief.
- Signature block: "Respectfully submitted," then the right half of the page: "/s/ <signer>", the counsel's name and bar number in caps, firm, address, telephone, "Facsimile:", e-mail and (if given) the role.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`; `court` (list of lines); `caption.parties` (list of `{names, designation}`; "v." is inserted between parties); `brief_title`; `lead_in` (the unnumbered opening paragraph, optional); `signature` (`signer`, `bar_no`, `firm`, `address` (list), `telephone`, `fax`, `email`, optional `role`); `jury_demand` is not a field: the jury demand is a numbered paragraph in the body, as the local rule requires it to be in the pleading.
- Body: blank-line-separated chunks. `#` heading = section (centered bold caps), `##` heading = count (centered bold); a list (`1.` items, lettered by the template); or a paragraph (numbered by the template).
- The sample must not type the paragraph numbers: the template numbers them.

## Known gaps and open choices

1. **Typeface.** The exemplar is Times New Roman, but no rule names a face for a complaint. Fed. R. Civ. P. 10 sets none; L.U.Civ.R. 7(b)(5)(B) governs memoranda only and names no face ("either a proportionally spaced or a monospaced face"; serifs for proportional type), read in the 2024 Local Civil Rules PDF on 2026-10-14. So the template keeps EB Garamond (`fonts/eb-garamond/`), the default `docs/FONTS.md` gives a court that names no face. It is used at 13 pt, the size the CAND motion template uses to approximate Times 12 pt; the size was chosen by eye against the exemplar, not measured. EB Garamond is not metric-compatible with Times New Roman, so line breaks differ from the filed version. If a Times-metric face is wanted, the substitute is Liberation Serif (`docs/FONTS.md`), a template change, not a rule change.
2. **Fax number.** L.U.Civ.R. 11(a) requires a fax number. The exemplar's counsel block has none. The sample says `fax: "None"`, which renders as "Facsimile: None". The template checks that the key is present, not that the value is a real number; counsel must supply one or the sample must say what they use.
3. **Counsel role line.** Optional (`role`). The exemplar prints "ATTORNEY FOR PLAINTIFF"; the sample uses it.
4. **Date line.** The exemplar has no date, so the template prints no "Dated:" line. The template takes no date field.
5. **Paragraph numbers.** The sample transcribes every numbered paragraph of the exemplar in order (1 to 56), so the template's numbers match the filed numbers. A partial sample would not match.
6. **Length.** The local rules set no page limit for a complaint; the template does not check one.
7. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which a doc-type folder does not have, and the brief bars editing `tools/`. The checks in this README were done by hand: render (no warnings), overlay, the page review below, and two mutant tests (below).
8. **Second exemplar.** `FILED-EXAMPLE-complaint-2.pdf` is saved for a tier-2 comparison but is not transcribed or compared in the overlay (the overlay uses the first exemplar in `usage/`, Mariano).
9. **Italics.** The complaint has no case names. The template renders `*...*` as italic if a sample needs it.
10. **Mutant test** (run by hand, failed as it should): the sample with its `fax:` line removed fails with "signature.fax is required (L.U.Civ.R. 11(a))". The 35-page check is in the memorandum template only (see the motion-brief README).

## Review of the rendered pages (60 dpi, every page viewed)

- Page 1: court title, caption (parties left, "CIVIL ACTION NO. 1:25cv363 HSO-MTP" right), title, lead-in, heading I, paragraphs 1 to 3. No overlap. Pass.
- Page 2: heading II, paragraphs 4 to 10, heading III, paragraph 11. Pass.
- Page 3: paragraphs 12 to 15 (party addresses and registered agents). Pass.
- Page 4: paragraphs 15 (end) to 22; heading IV. Pass.
- Page 5: paragraphs 22 to 28 (the page ends mid-paragraph 28). Pass.
- Page 6: paragraphs 29 to 31 with the lettered list a. to e.; heading V, Count I. Pass.
- Page 7: list item f, paragraphs 32 to 39; Count II and Count III headings, each kept with its first paragraph. Pass.
- Page 8: paragraphs 40 to 48; Count IV heading; Count V heading (two lines, centered). Pass.
- Page 9: paragraphs 49 to 56; Count VI heading; heading VI with paragraph 55 (jury demand); heading VII; paragraph 56 with the lettered list a. (and b. to f. on page 10). Pass.
- Page 10: prayer items b. to f.; signature block on the right half: "Respectfully submitted," "/s/ Marshall Goff", counsel block, "Facsimile: None", e-mail, "ATTORNEY FOR PLAINTIFF". Pass (the page was viewed after the last template change).

Overlay: the overlay pairs each page of our render with the exemplar page sharing the most words. The word overlap runs from 49% (page 6) to 95% (page 1), with the caption and opening pages matching best. The overlay is a diagnostic, not a score: differences are expected at the caption (font and wrapping) and in the paragraph layout (a 13 pt face wraps lines differently from Times 12 pt).

## Engines

- **docx** (`docx/reference.docx`, built by `docx/build-reference.sh`; filter `docx/mssd-complaint.lua`). Samples: `usage/OUTPUT-complaint.docx` and `.docx.pdf` (10 pages, the same as typst). Checked by hand: the LibreOffice PDF was viewed page by page (10 of 10) against the typst render (10 of 10). Opened with LibreOffice only: the conversion succeeds and the parts are well-formed XML; Word was not available and was not checked.
- Matches typst: EB Garamond 13 pt (embedded in the PDF, no other face), US Letter, 1 in margins, exact 27.6 pt double spacing (the typst pitch is 27.56 pt), 0.5 in first-line indent, single-spaced court title, caption, headings and signature block (exact 11.7 pt, the typst pitch), the caption table with "CIVIL ACTION NO." on the right, centered bold caps section headings, centered bold count headings, the page number centered in the footer, lettered lists a., b., ... with a hanging indent, the signature block at 3 in.
- Differs, and why: (1) Paragraph numbers 1 to 56 and list letters are typed text followed by a tab to a style tab stop. pandoc drops the numbering part of a reference.docx, so Word auto-numbering is not available; inserting a paragraph does not renumber the ones after it. (2) Pagination: LibreOffice puts exact-spacing leading above the text, so a page holds 23 double-spaced lines where typst holds 24. The page count matches here (10), but page breaks fall elsewhere; Word may differ again.
- BLOCKED: none.
- `tools/check.sh` was not run on this folder: it needs the court's `court.json` and `checks.yaml`, which this doc-type folder does not have.
