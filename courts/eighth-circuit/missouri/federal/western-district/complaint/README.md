# W.D. Mo. (mowd): complaint

Doc type: **complaint** in the United States District Court for the Western District of Missouri (`mowd`).
Folder: `courts/eighth-circuit/missouri/federal/western-district/complaint/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (an excerpt of the 60-page filing, see Known gaps) |
| typeface | face required by the rules: none (see Governing rules). Substitute: none; EB Garamond kept (`docs/FONTS.md`, "No face named"). Metric note: n/a. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`; re-rendered 2026-10-14, `pdffonts`: EB Garamond Regular and Bold embedded) |
| overlay | fail: `usage/OVERLAY-johnson-complaint.pdf` not regenerated. `usage/` holds only `SOURCE.md` in this snapshot (no `SAMPLE-*.pdf`), so `tools/overlay.sh` exits 1. The `.txt` page map is from an earlier run. |
| pages reviewed | 10 of 10 (re-rendered 2026-10-14 and every page viewed at 60 dpi; the template did not change) |

File names: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf` and the overlay `OVERLAY-<id>.{pdf,txt}`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default (the brief's `<id>.pdf` / `<id>-overlay.pdf` would not be found by the overlay tool).

## Governing rules

The W.D. Mo. local rules do not set a typeface, font size, margin or line spacing for filed papers. Searched and read (the typeface check was repeated on 2026-10-14 by extracting the text of the 76-page local rules PDF listed below and searching it for font, typeface, point size and paper-format terms: no match for filed papers):

| Source | What it says | Used for |
|---|---|---|
| W.D. Mo. Local Civil Rules, effective Dec. 1, 2022 (`https://www.mow.uscourts.gov/sites/mow/files/DC-Local_Rules-120122.pdf`, fetched 2026-10-14) | L.R. 3.1: civil cover sheet must be filed with a pleading asserting a claim. L.R. 3.2(a), (b): the court's divisions (Western, St. Joseph, Central, Southern, Southwestern) and divisional venue. L.R. 5.1: mandatory electronic filing by represented parties. L.R. 7.1(a)–(b): every non-governmental corporate party files a certificate of interest with its first pleading. No form-of-papers rule. | Cover (`division`), the separate-filings note below. |
| W.D. Mo. CM/ECF Civil and Criminal Administrative Procedures Manual and User's Guide (`https://www.mow.uscourts.gov/sites/mow/files/AdministrativeGuideandUserManual.pdf`, fetched 2026-10-14; revision date printed in the manual 8/27/2026) | Electronically converted PDFs must be text searchable; scanned image PDFs are not searchable. | The render is text searchable (vector text, fonts embedded). |
| Fed. R. Civ. P. 10(a) (caption: court, title, file number, Rule 7(a) designation) | Caption carries the court name, the title, the case number. | `court-title`, `caption`, `case_number`, `title`. |
| Fed. R. Civ. P. 10(b) (numbered paragraphs; each claim founded on a separate transaction in a separate count) | Paragraphs numbered; claims in counts. | Each body paragraph numbered by the template (`allegations()`); count headings are the author's text. |
| Fed. R. Civ. P. 8(a) (short and plain statement of grounds for jurisdiction, claim, demand for relief) | Content of the complaint. | Not checked by the template (author content). |
| Fed. R. Civ. P. 5.2 (privacy: SSN, birth year, minor's name, financial account, home address) | Redaction. | Not checked (author responsibility). |
| Fed. R. Civ. P. 38(b) (jury demand) | Demand under Rule 38(b). | `jury_demand: true` prints "JURY TRIAL DEMANDED" under the title; the demand paragraph is in the body. |

Not generated, on purpose (separate filings): the civil cover sheet (L.R. 3.1; JS-44 form), the certificate of interest (L.R. 7.1; required from a corporate party with its first pleading; the sample's plaintiffs are individuals), the summons, and the Rule 7.1 disclosure statement.

## Layout (chosen, not mandated)

- Letter paper, 1 inch margins on all sides; no pleading paper (the local rules do not require numbered lines).
- Court title centred and bold on the first page (two lines: "UNITED STATES DISTRICT COURT" / "FOR THE WESTERN DISTRICT OF MISSOURI"); the division line is printed only when the sample gives one.
- Caption: parties in a left column, "v." between the sides; right column: "Case No.", the title, and "JURY TRIAL DEMANDED".
- Body: EB Garamond 13 pt, double spaced (`body-leading` = 1.35 em, one blank line of leading between lines), first-line indent 0.5 inch, numbered paragraphs 1., 2., ...
- Headings: level 1 centred bold caps; level 2 centred bold; level 3 bold, left. A heading is never the last line of a page (kept with the paragraph after it).
- Lists: lettered A., B., ... (the template's choice; the exemplar's lists use a., b., in places).
- Signature block: "Dated" at left; "Respectfully submitted," and the `/s/` signer at right; one block per firm.
- Page numbers centred at the foot, arabic from page 1.

Why EB Garamond: the local rules name no face, so the court-named-face rows of `docs/FONTS.md` do not apply and the template keeps EB Garamond. The exemplar is set in Times New Roman, but the rules do not require Times, and any proportional serif is allowed. A metric-compatible Times substitute is vendored (`fonts/liberation-serif/`, "Liberation Serif"); it is not used here.

Why 13 pt and not 12 pt: at 13 pt the EB Garamond x-height is about that of Times New Roman at 12 pt, which is the exemplar's face and size (measured from text-box heights on the exemplar's body: about 13.3 pt line boxes). Not a rule; a visual match to the exemplar. The Mannon exemplar in the motion-brief folder measures about 14 pt Times.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks:
  - a `#` heading (level 1 centred caps; level 2 centred bold; level 3 bold left);
  - a `>` block quotation (indented, single spaced; used for the class definition);
  - a list (`1.` items, lettered by the template);
  - the chunk `WHEREFORE...` is an unnumbered lead-in (the prayer's first line);
  - any other chunk is one numbered paragraph.
- Frontmatter: `case_number`; `caption.parties` (list of `{names, designation}`; "v." is inserted between the sides); `title`; `jury_demand` (true/false); optional `division`; `signature` (`date`, `signer`, `blocks`: a list of firms, each a list of lines).
- Not supported: footnotes (the template has no footnote rule), tables, raw typst. The sample writes no paragraph numbers; the template numbers the paragraphs from 1.

## Known gaps and open choices

1. **Local rules text is from December 2022.** The 2026 local rules PDF (`DC-Local_Rules-072026.pdf`) returned HTTP 404 to WebFetch from this box, and courtrules.net returned 403. A later amendment that adds a form-of-papers rule would not be seen here. **Needs a check by David or the clerk's current local rules before this is treated as complete.**
2. **No mandated typeface, size or spacing in the local rules.** The choices above are conventions from the exemplar (Times New Roman, double spaced). If a judge's standing order requires Times New Roman, the face would change to "Liberation Serif" (`docs/FONTS.md`), and the page count and line breaks would need a re-render and check.
3. **Excerpt, not the whole filing.** The sample transcribes: the introduction (paragraphs 1 to 3), jurisdiction and venue (4 to 7), the parties (8 and 9, the Mosaic paragraph only), the start of the factual allegations (10 and 11), the statute of limitations (12 to 15), class allegations (16 to 24, the class definition, the exclusions and the Rule 23 elements through predominance), Count 1 (25 to 28) and the prayer and jury demand (29). Omitted: most factual allegations, the other defendants' paragraphs, the superiority paragraph (145), Counts 2 and up. The 60-page filing is 60 pages; the render is 10 pages, within the 8 to 14 target for an excerpt of this kind.
4. **Footnotes dropped.** The exemplar has footnote 1 (defining "Defendants") on paragraph 1, and footnotes 2 to 4 (sources) on paragraphs 23 and 24. The template does not support footnotes; the sample omits the footnote text and the footnote numbers, so the overlay shows those words as missing.
5. **Paragraph numbers differ.** The exemplar's paragraph numbers are not reproduced; the template numbers from 1. The jury demand is paragraph 29 here, 174 in the exemplar.
6. **Lettering.** The exemplar's exclusion and prayer lists use a., b. and A., B. in places; the template letters all lists A., B., ... (capitals). The exemplar's relief list is lettered A to F, matching.
7. **Division line.** The exemplar has no division line in its caption, although its case is in the Western Division (case number prefix 4:). The template prints a division line when `division` is set; the sample leaves it out, to match the exemplar. The Mannon exemplar (motion-brief) shows "SOUTHERN DIVISION" in its caption.
8. **Second exemplar not collected.** EVAL-LOOP's tier-2 rule asks for two or three filers. Another W.D. Mo. complaint was identified (Cincinnati Specialty Underwriters Insurance Co. v. Union Station Kansas City Inc., No. 4:26-cv-00504, Doc. 1, filed 2026-06-11, CourtListener docket 73473742); not downloaded. Tier 2 is therefore not judged against two filers.
9. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. The render and overlay were run; the page review below is the Gate 2 equivalent.
10. **Class-action legend.** The title already reads "CLASS ACTION COMPLAINT"; no separate legend is generated (the W.D. Mo. rules do not call for one).

## Review of the rendered pages (current PDF, 60 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, title, jury legend; Introduction paragraphs 1 and 2 | Pass after fixes: the court title lines no longer overlap; the heading is body size (it had been drawn at the default heading size); the class-action legend that duplicated the title is removed. |
| 2 | Introduction 3; Jurisdiction and Venue 4 to 7 | Pass after fixes: paragraphs no longer overlap one another (the paragraph block had been losing its trailing leading); the heading has space above and below. |
| 3 | Introduction end; The Parties (Plaintiffs, Defendants, Mosaic); Factual Allegations A (10, 11) | Pass. |
| 4 | Factual allegations end; Statute of Limitations 12 to 15 | Pass. |
| 5 | Class Allegations 16 to 19 (definition as a block quotation, exclusions A to D, numerosity) | Pass. |
| 6 | Commonality list A to I; Typicality and Adequacy 21 | Pass. |
| 7 | Typicality 22 to 24; Claims for Relief, Count 1 heading, 25 to 28 | Pass. |
| 8 | Request for Relief (WHEREFORE unnumbered; items A to D) | Pass after fix: the first item (A.) had overlapped the WHEREFORE lead-in; fixed by giving the lead-in its trailing space. |
| 9 | Items E and F; Jury Trial Demanded, 29 | Pass. |
| 10 | Signature block (date left, firms right, `/s/`) | Pass. |

## Engines

- **typst** (`typst/`, primary): `usage/OUTPUT-complaint.typst.pdf`, 10 pages.
- **docx** (`docx/`): `reference.docx` (styles and page setup, built by `sh docx/build-reference.sh reference.docx`) and `mowd-complaint.lua` (cover, caption, numbered paragraphs, lists, signature block). Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-complaint.md` writes `usage/OUTPUT-complaint.docx` and `usage/OUTPUT-complaint.docx.pdf` (LibreOffice 26.8.1; 11 pages). LibreOffice must see `fonts/` (EB Garamond) through fontconfig, or the PDF substitutes a face.
- **latex**: not built for this doc type (`latex/` is empty).

What matches the typst form (every page of the docx PDF viewed at 60 dpi, next to the typst page):
- US Letter, 1 in margins; EB Garamond 13 pt, the only font embedded (`pdffonts`); double spacing (26 pt line pitch); 0.5 in first-line indent.
- Court title, caption (parties left, case number, title and jury legend right), numbered paragraphs 1., 2., ..., headings (level 1 centered caps; level 2 centered bold; level 3 bold, left), block quotation single spaced, lettered lists A., B., ..., the unnumbered WHEREFORE lead-in, signature block in one unbreakable row.
- Page number centered at the foot, arabic from 1 (on the cover too, as in the typst template).

What differs:
- Pagination: the sample is 11 pages in docx and 10 in typst. Word's exact line spacing sets the first line about 12 pt lower on each page (first line at 80 pt against 67 pt in the typst render), so about one line less fits on a page. Word may paginate differently again.
- Signature block: in both renders it is alone on the last page (the jury demand ends the page before it). The docx keeps the signature with the paragraph before it, as the typst block is kept together.
- Caption and signature lines: the same text and wrapping; the typst single-spaced stacks have no gap between items, and the docx matches that.
- Footnotes: none (the template has none).

docx BLOCKED items: none for the mandated form. Not checked: Word itself (not installed here). The `.docx` is a valid zip of well-formed XML parts and opens and converts in LibreOffice without a repair prompt.

## Overlay

`usage/OVERLAY-johnson-complaint.pdf` (red = our render, blue = exemplar, black = both) and `OVERLAY-johnson-complaint.txt` (page map). Pages are paired by word overlap: ours p.1 to p.10 pair with filed p.1, 3, 4, 50, 51, 52, 55, 58, 58, 59. The pairing is coarse because the sample is an excerpt; the exemplar's pleading page layout is not reproduced (no pleading paper), so the lines will not coincide. The overlay is a diagnostic, not a score.
