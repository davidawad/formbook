# moed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Missouri (`moed`).
Folder: `courts/eighth-circuit/missouri/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-moed-complaint-carreaga426cv00743.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-moed-complaint-carreaga.md` (a transcription of the filing, 10 rendered pages; see "Sample" below) |
| render | ok: `usage/OUTPUT-moed-complaint-carreaga.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-carreaga-complaint.pdf` and `usage/OVERLAY-carreaga-complaint.txt` (page map) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |
| BLOCKED | none |

File names: `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf/.txt`, so the render and overlay follow the tools, not the brief's `<id>.pdf` / `<id>-overlay.pdf` spelling.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Mo. L.R. 2.01(A)(1) | "All filings, unless otherwise permitted by leave of Court, shall be in 12-point or larger font, double spaced, typed or legibly written on 8 1/2 by 11-inch pages." Also: the signer's name, address, telephone, email and state bar registration number immediately beneath each signature. | `type-size = 12pt`, `pitch = 24pt`, `page-w/page-h`; `signature-block()` prints each firm block from `signature` frontmatter. |
| E.D. Mo. L.R. 2.01(A)(2) | A blank area no smaller than 2 by 2 inches in the upper left and upper right corners of the first page. | `court-title()` is a fixed band from the top margin to the 2 inch line, so the caption starts below the corners. The court name is centered, clear of both corners. |
| Typeface (no face named) | Face required: none. L.R. 2.01 sets size, spacing and paper, not a typeface (see the verification note). Vendored substitute: EB Garamond, the default in `docs/FONTS.md` for a court that names no face. Fit: n/a. | `font-family = "EB Garamond"` in `moed-complaint.typ`. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. | `court-title()`, `caption()` (party names from frontmatter; "Case No." from `case_number`, or a blank line when no number is assigned), `title-block()`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered()`: the template numbers each body paragraph; the sample does not carry numbers. |
| Fed. R. Civ. P. 38(b) | A jury demand may be included in the pleading. | `legends` frontmatter puts "JURY TRIAL DEMANDED" in the caption; the sample's JURY DEMAND heading and paragraph are body text. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Content, not checked by the template. |

Verification status of the rules (2026-10-14):

- **L.R. 2.01(A)(1)-(2)**: text read from search excerpts of the court's own rule PDF and of a courtrules.net copy. The court's PDF (`moed.uscourts.gov/sites/moed/files/documents/local-rules/`) and courtrules.net both refused the fetch from this box, so the rule was not read in full. Date of the current text not confirmed. Re-check against the current PDF before a filing.
- **Fed. R. Civ. P. 10(a)-(b)**: text confirmed by search excerpts of the rule (Cornell LII copy and the N.D. Ill. copy); not fetched in full.
- **Fed. R. Civ. P. 8(a), 38(b)**: cited from the rule's known text; not re-read in this pass.
- **Typeface (2026-10-14)**: search excerpts of L.R. 2.01(A)(1) (courtrules.net copy and the court's rule PDF) give size, spacing and paper, and name no face. courtrules.net returned HTTP 403 to the fetch, and the court's November 2019 press release PDF could not be read as text here (its "standard font" sentence is unread). "No face named" therefore rests on those excerpts; re-check the full rule before a filing. If the rule does name a face, switch `font-family` to the substitute in `docs/FONTS.md`.
- Not produced by this template, and possibly required with a first filing: the civil cover sheet (JS-44); the Rule 7.1 disclosure statement (for a diversity case, the citizenship disclosure of Rule 7.1(a)(2)); the summons. The filing's own privacy redactions (Fed. R. Civ. P. 5.2) are the filer's job; the sample contains no SSN, birth date or account numbers.

## Layout

- Page: 8 1/2 by 11 inch, 1 inch margins (the margin is not stated in L.R. 2.01; 1 inch is the convention used here), page number centered at the foot of each page.
- Text: EB Garamond 12 pt (the substitute for a court that names no face, per `docs/FONTS.md`), body at a 24 pt baseline pitch (double spacing; `body-leading = 1.35em` on a 0.65em line box).
- Caption: court name block in the top band, then a two-column caption (parties with a right and bottom rule; "Case No." and legends on the right). No pleading line numbers and no pleading rules: the rule does not require them, and the exemplar has none.
- Numbered allegations: "1." at a 0.5 inch first-line indent, text wrapped to the margin.
- Headings: level 1 centered bold caps (NATURE OF THE ACTION, PRAYER FOR RELIEF); level 2 centered bold (Proposed Class, Count title subheadings); level 3 bold left.
- Lists (the prayer, the common-questions list): lettered (a), (b)... with a 1 inch text indent.
- Notes (`> ...` in the sample): single-spaced, unnumbered; used for omission markers.
- Signature: "DATED:" line, "Respectfully submitted," and each firm block at 3.25 inch indent, single spaced, then the represented party.

## Sample

The sample transcribes the filing's cover and caption, the nature of the action (¶¶ 1–14), parties (¶¶ 15–20), jurisdiction and venue (¶¶ 21–23), facts (¶¶ 24–29, 32–33, 40–43, 49–50), class allegations (¶¶ 51–55, with the first four items of the common-questions list), Count I (¶¶ 61–68, 77–79, 86–87), the full prayer for relief except sub-items (5)–(16) of item 3, the jury demand and the signature blocks. Each omitted run is marked in the sample with a note. The filing's omitted paragraphs are 30–31, 34–39, 44–48, 56–60, items 5–8 of the common-questions list, 69–76, 80–85, and prayer sub-items (5)–(16).

Paragraph cross-references in the sample (for example "paragraphs 1–60" in the count's incorporation paragraph) keep the filing's own numbering. The template renumbers the paragraphs, so in the rendered sample the cross-reference does not match the paragraph it sits in. That is a sample-level inconsistency: it does not affect the template.

## Known gaps and open choices

1. **One filer only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers from different firms. The search also found a second E.D. Mo. complaint, Jones-Williams v. Missouri Department of Revenue, 4:26-cv-00772-SEP (Doc. 1, 9 pages, text layer present), which was downloaded and not kept because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers. OPEN.
2. **Font.** L.R. 2.01 names no typeface, so the template keeps EB Garamond (`docs/FONTS.md`: a court that names no face keeps EB Garamond). The exemplar is Times New Roman, and EB Garamond at 12 pt has a smaller x-height than Times, so the text looks smaller than the exemplar. The 12-point minimum is met. The difference is visual only, and switching to a Times substitute (Liberation Serif) would be a choice the rule does not require. ACCEPTED (tier 2); David may choose otherwise.
3. **Judge requirements.** Individual judges add requirements (for example, a 13-point requirement for memoranda in one judge's published requirements; the judge-specific requirements are not in the template and are not verified for the assigned judge). Check the assigned judge's requirements before filing. OPEN.
4. **Caption closing.** The exemplar uses a column of ")" marks; the template uses a right and bottom rule on the party column. Both are seen in E.D. Mo. filings. ACCEPTED (tier 2).
5. **Case names and italics.** The exemplar's text layer has no italics, so italic markup is not verified against it. The complaint sample has no case citations.
6. **Overlay pairing.** Pages pair by word overlap, and the sample skips paragraphs, so the pairs for pages 5, 8 and 10 share only 35–38% of their words (OVERLAY-carreaga-complaint.txt). The overlay is a diagnostic, not a score.
7. **Justification.** The template sets ragged-right text; the exemplar's justification could not be read from its text layer. ACCEPTED (tier 2/3).

## Gate 2: rendered pages (current PDF, 60 dpi, viewed)

- Page 1: court name in the top band, caption from below the 2 inch line, "Case No." and legends at right, title, lead-in paragraph, paragraphs 1 to 3. The top-left and top-right 2 by 2 inch corners are blank. Pass.
- Page 2: numbered paragraphs 4 to 11, wrapped to margin, 24 pt pitch. Pass.
- Page 3: paragraphs 12 to 16, PARTIES heading centered bold. Pass.
- Page 4: paragraphs 17 to 27, JURISDICTION AND VENUE and FACTS headings, no heading at the foot of a page. Pass.
- Page 5: paragraphs 28 to 35, with omission notes after 29, 31 and 33 (single spaced, italic). Pass.
- Page 6: paragraphs 36 to 42, CLASS ALLEGATIONS with Proposed Class and Numerosity subheadings, common-questions list begins at (a). Pass.
- Page 7: list (b) to (d), omission note, COUNT I heading and subheading, paragraphs 43 to 50. Pass.
- Page 8: paragraphs 51 to 54 with omission notes, and paragraph 54's damages list (a)-(j) in running text. Pass.
- Page 9: paragraph 55, PRAYER FOR RELIEF, paragraph 56 (WHEREFORE) and prayer items (a) to (c) with wrapped lines. Pass.
- Page 10: prayer (c) to (g) with the sub-item omission note, JURY DEMAND heading and paragraph 57, DATED line, signature blocks with bar numbers and contacts, party line in italic. Pass.

Defects found and fixed during review: the first render stacked each block on the one before it (a block's height excluded the trailing leading, so each paragraph overlapped the last line of the one before). Fixed by a `below` gap of one body leading on every body block and a row gutter in the list grid; the page-by-page check above is after that fix.

## Engines

Typst is the primary engine and the reference for the court form. The docx engine follows the same values in Word styles.

- `docx/`: `reference.docx` (pandoc's default with this folder's styles, page setup and footer), `court-form.lua` (the caption table, title, numbered allegations, lettered lists, notes and signature block, read from the sample's frontmatter), and `make-reference.sh` with `reference-src/` (rebuilds `reference.docx`: `sh docx/make-reference.sh complaint`).
- Matches typst: EB Garamond 12 pt; 8 1/2 by 11 inch pages with 1 inch margins; body double spaced at an exact 24 pt pitch with a 0.5 inch first-line indent; the court name in the 2 inch corner band, so the caption starts 2 inches down; caption with a right and bottom rule on the party column, and the case number and legends at right; allegations numbered by the template (number at 0.5 inch, text after it, wrapped lines to the margin); lettered lists "(a)" at 0.5 inch with text at 1 inch; single-spaced notes; signature block at 3.25 inch with the bar number and contacts under each signature; page number centered in the footer (a `PAGE` field).
- Differs: line breaks and page breaks are Word's or LibreOffice's, not typst's, so page-by-page comparison is not possible until the `.docx.pdf` exists. The number-to-text gap is a tab stop at 1 inch, not a fixed 0.25 inch space. The caption rule is a table border, which Word and LibreOffice draw slightly differently. Footnotes (none in this sample) are 12 pt and single spaced. The typeface, size and spacing are set in the styles, so a machine without EB Garamond substitutes a font silently (`docs/DOCX.md`).
- docx BLOCKED (not run; no `.docx.pdf` exists):
  - Gates 0 to 3 on `usage/OUTPUT-carreaga-complaint.docx.pdf`: BLOCKED. `tools/render-docx.sh` writes the `.docx` and then stops at `soffice`, which is not installed. conda-forge has no LibreOffice package and this box has no root, so there is no LibreOffice here.
  - Gate 2 (visual review) for the docx: BLOCKED. `pages_reviewed=0`. No page of the `.docx` has been rendered or viewed.
  - Opens in Word and LibreOffice without a repair prompt: not checked. The `.docx` is a valid zip with well-formed XML parts and reads back through pandoc, which is necessary but not sufficient.
