# ilnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Illinois (`ilnd`).
Folder: `courts/seventh-circuit/illinois/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: caption, numbered paragraphs 1 to 40 with Count I, prayer, jury demand, signature. Counts II to IX and the rest of the case list in paragraph 19 are not transcribed (see Known gaps). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx` / `.docx.pdf`, 11 pages each, typst 0.15.0, vendored Times New Roman only, no warnings |
| checks | `fb check --engine typst`: 9 passed, 0 failed; `--engine docx`: 13 passed, 0 failed, XENG-001..003 PASS (259/259 lines, every page alike); `params.cross_engine: gate` (`eval.yaml`) |
| typeface | face required: none (N.D. Ill. LR 5.2(e) names no typeface; checked against the consolidated rules text, 2026-10-15). **Times New Roman** (vendored; the exemplar's face), the same face in typst and docx. |
| pages reviewed | 11 of 11, typst and docx (re-rendered 2026-10-22, every page rendered at 60 dpi and viewed side by side) |

Build (from the repo root, with the toolchain on `PATH`):

```sh
D=courts/seventh-circuit/illinois/federal/northern-district/complaint
just check $D                       # typst: usage/OUTPUT-complaint.typst.pdf and the gates
sh tools/check.sh $D --engine docx  # docx: usage/OUTPUT-complaint.docx, .docx.pdf, and Gate 4 against the typst render
just overlay $D                     # .overlay/<doc path>/OVERLAY-complaint.pdf (not committed)
```

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Ill. LR 5.2(e) (https://www.ilnd.uscourts.gov/_assets/_documents/_rules/lrrules.pdf, "Amended ... May 18, 2023" text; the consolidated rules PDF is amended through May 4, 2026) | 8½ × 11 inch opaque white paper; line spacing "at least 2.0 lines"; 12-point type in the body; footnotes no less than 11 points; margins at least 1 inch on all four sides. | `paper: "us-letter"`, `margin` (1 in each side), `type-size = 12pt`, `pitch-body = 27.6pt` (Word's double line at 12 pt, the exemplar's pitch); docx: `docx/reference.xml` (size 24, body 552 twips). |
| N.D. Ill. LR 5.2(e) (electronic copies) | "Documents filed electronically must conform to these requirements." | Same parameters; the PDF is the filed form. |
| N.D. Ill. LR 5.2(g) | A non-compliant document may be stricken. | Not a template check; the layout above is the compliance. |
| N.D. Ill. LR 3.1(a) | Plaintiff's counsel files a designation sheet (civil cover sheet) with the original papers. | Not produced by this template (separate filing). |
| N.D. Ill. LR 3.2 | A nongovernmental party other than an individual files a Notification of Affiliates with its first filing. | Not produced by this template (separate filing). |
| Fed. R. Civ. P. 7.1(a)(1) (https://www.law.cornell.edu/rules/frcp/rule_7.1, fetched 2026-10-14) | A nongovernmental corporate party files a disclosure statement with its first appearance. | Not produced by this template (separate filing). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation; the complaint's title names all the parties. | `court-title`, `caption`: court, division, parties, case number (blank until assigned), title, "JURY TRIAL DEMANDED". |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each allegation is numbered 1, 2, ... by the template (`body-chunks`). Prayer and jury demand are not claims and are not numbered (`unnumbered-after`). |
| Fed. R. Civ. P. 8(a) (https://www.law.cornell.edu/rules/frcp/rule_8) | Short and plain statement of jurisdiction, claim and demand for relief. | Content of the sample only (the template checks no wording). |
| Fed. R. Civ. P. 11(a) (https://www.law.cornell.edu/rules/frcp/rule_11) | Signed by an attorney of record; the signer's address, e-mail address and telephone number. | `signature-block`: firm, signer, telephone, e-mail (from the sample's frontmatter). |
| Fed. R. Civ. P. 38(b) (https://www.law.cornell.edu/rules/frcp/rule_38) | Jury demand. | `jury_demand: true` puts the caption legend; the demand is a body section. |
| N.D. Ill. LR 5.3(a) | Consult the assigned judge's procedures on filing and presenting motions. | Not a template check. Judge-specific formats are not modelled. |

## Layout

Both engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right lines, no kerning, ligatures or hyphenation, the space between blocks the larger of the two.

- Page 1: court title (three centered bold lines, 13.8 pt single lines), one blank single line, a caption in a box (the party column, 3.3 in, is closed by a rule on its right and bottom 10 pt from its text, as in the exemplar), the case number, the title and the jury legend at right, a blank single line between them.
- Body: double-spaced at a 27.6 pt pitch (LR 5.2(e), at least 2.0 lines: Word's double line at 12 pt, the exemplar's pitch), ragged right; every paragraph indented 0.5 in, the paragraph number in a half-inch box after the indent.
- Headings: single 13.8 pt lines, bold; level 1 centered, underlined, in capitals; level 2 centered and underlined (the count title); level 3 at the margin. A group of headings has 6.9 pt above and below (a one-line heading takes one body line, as in the exemplar), none inside, and stays with what follows.
- Prayer items are lettered (a), (b), ... by the template, the letter in the number's place.
- Signature block, one blank single line after the last paragraph: "Dated" at the margin and "Respectfully submitted," at 3 in on the same line; then "/s/" signer and the signer's lines, the firm, the party, a blank single line between the groups, all single lines. The last paragraph, the headings right before it, and the signature block are kept together (a signature alone at a page top is not filed).
- Footer: page number, centered, 12 pt, in a 13.8 pt line (typst footer-descent 30 %; Word footer distance 735 twips).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: a `#` heading (level 1 section), `##` (sub-heading), `###` (flush-left bold), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter: `case_number` (string; blank prints "Case No.:" alone), `judge` (optional), `division` (optional), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties; each name is one line), `brief_title` (list of lines), `jury_demand` (bool), `lead_in` (unnumbered introductory paragraph, optional), `date`, `signature` (`firm` lines, `signer`, `lines` for the signer's telephone, facsimile, e-mail, `party` lines).
- A level-1 heading whose text is `PRAYER FOR RELIEF` or `DEMAND FOR JURY TRIAL` turns numbering off for the paragraphs that follow it, until the next level-1 heading.
- Not supported: tables, footnotes (none used), raw typst.

## Known gaps and open choices

1. **One exemplar, so tier 2 is not judged against two filers.** The brief asks for one exemplar per doc type. The CourtListener RECAP search (`type=r`, `court=ilnd`, recent complaints with downloadable PDFs) also found complaints that were not saved: *Davis v. Klover Holdings Inc.* (docket 74735181, 42 pp), *Harris v. Trapananda Seafarms LLC* (docket 74708265, 80 pp), *Zaragoza v. Taylor Fresh Foods, Inc.* (docket 74686559, 31 pp), *Walker v. Veradigm Inc.* (docket 74763514, 32 pp, class action). Tier 2 for this doc type is therefore judged against this one filing only.
2. **Sample is a portion.** Paragraphs 1 to 40 and the prayer and jury demand are transcribed from the 33-page filing (captions, Nature of the Action, Parties, Jurisdiction and Venue, UTLX and BWE, the Demand Letter, the Asserted Patents, Count I). Counts II to IX are omitted, and the case list in paragraph 19 is cut to three citations, marked in the text. Paragraph numbers in the sample follow the template (they match the filing for paragraphs 1 to 40).
3. **Font.** No font is mandated by LR 5.2(e) (verified: the rule sets paper, line spacing, type size and margins only). Both engines set the vendored Times New Roman, the exemplar's face (the docx named EB Garamond before fb-595.68.27).
4. **Attorney identification.** The exemplar shows no attorney code or ARDC number, and the template prints none. Whether N.D. Ill. requires one on filings was not verified in this pass.
5. **Prayer lettering.** The exemplar letters the prayer A, B, C; the template uses (a), (b), (c) (the pleading convention in this repo's other templates). Recorded as ACCEPTED (tier 2, one filer).
6. **Caption style.** The exemplar's party column is closed by a rule (box style). Another N.D. Ill. filing reviewed, the memorandum in `../motion-brief/`, uses a column of ")" marks. Both are seen in N.D. Ill. practice; the template follows the box. Recorded as ACCEPTED.
7. **Not produced.** The designation sheet (LR 3.1), the Notification of Affiliates (LR 3.2), the Rule 7.1 disclosure statement, the summons and the exhibits are separate filings and are not part of this template.
8. **Judge's procedures.** The template does not model any assigned judge's standing order (LR 5.3(a)).
9. **No selftest.** `tools/check-selftest.sh` expects a court folder with `court.json`; this doc-type folder has none. `fb check` runs the default gates (typst 9, docx 13 passed, 0 failed); the review below is the Gate 2 review.
10. **Ragged right.** The exemplar is justified; both engines set ragged-right lines (the cross-engine model: Word and typst justify differently). Recorded as ACCEPTED (tier 2).

## Review of the rendered pages (current PDFs, typst and docx side by side, 2026-10-22)

Every line and page break is the same in both engines (XENG-001..003, 259/259 lines); the pages below hold for both.

- Page 1: court title, caption (box), case number, title, jury legend; the lead-in, "NATURE OF THE ACTION" (centered, bold, underlined) and paragraphs 1 to 3. Pass.
- Page 2: paragraphs 3 (end) to 9; "PARTIES" and "JURISDICTION AND VENUE"; paragraph spacing even. Pass.
- Page 3: paragraphs 9 (end) to 14; "UTLX AND ITS BUSINESS". Pass.
- Page 4: paragraphs 14 (end) to 18; "BWE AND ITS BUSINESS"; the page ends short by one line (paragraph 19 would leave a single line behind). Pass.
- Page 5: paragraphs 19 to 23; the case list of paragraph 19 is cut and marked; italics for case names. Pass.
- Page 6: paragraphs 24 to 26. Pass.
- Page 7: paragraph 27, "THE ASSERTED PATENTS AND BWE'S INFRINGEMENT ALLEGATIONS" on one line, paragraphs 28 to 30. Pass.
- Page 8: paragraphs 30 (end) to 34; the page ends short: "COUNT I" and its sub-heading move with paragraph 35. Pass.
- Page 9: "COUNT I" and "DECLARATORY JUDGMENT OF NON-INFRINGEMENT OF THE '273 PATENT" as one group, paragraphs 35 to 39. Pass.
- Page 10: paragraph 40, "PRAYER FOR RELIEF" (unnumbered), the WHEREFORE paragraph, items (a) to (e). Pass.
- Page 11: items (f) to (h), "DEMAND FOR JURY TRIAL" (unnumbered), its paragraph and the signature block, kept together. Pass.

## Engines

**docx** (`docx/reference.xml`, `docx/ilnd-complaint.lua`; `fb render` builds the reference and runs the filter, no shell): `<reference base="xengine" size="24" body="552" single="276" indent="720" footer="735">` in `{font}` (the typst face, Times New Roman) with its own page-number footer in a 13.8 pt line. The filter writes every paragraph with `xe.spacing` in the typst pitches and spaces (twips = 20 x pt): court title, the caption table (the party cell with a right and bottom border and a 10 pt margin, less the 0.75 pt rule Word adds to the cell), lead-in, numbered paragraphs (`n.` and a tab to 1 in), headings (KEEP), lettered prayer items, the last paragraph and its headings KEEP, and the signature lines kept together (the first line "Dated" and a tab to 3 in). typst's break rules: no break inside ")(" (word joiner), a break after a slash before a letter (zero-width space), "§§" bound to its number. `fb check --engine docx`: 13 passed, 0 failed; XENG-001..003 PASS (259/259 lines; widths within 0.45 pt, baselines within 0.19 pt).

**latex**: not built for this doc type.
