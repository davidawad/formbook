# ilnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Illinois (`ilnd`).
Folder: `courts/seventh-circuit/illinois/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-ilnd-complaint-uniontankcar126cv10014.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-ilnd-complaint-uniontankcar.md`: caption, numbered paragraphs 1 to 40 with Count I, prayer, jury demand, signature. Counts II to IX and the rest of the case list in paragraph 19 are not transcribed (see Known gaps). |
| render | ok: `usage/OUTPUT-ilnd-complaint-uniontankcar.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-union-tank-car-complaint.pdf` and `OVERLAY-union-tank-car-complaint.txt` (page map) |
| typeface | face required: none (N.D. Ill. LR 5.2(e) names no typeface; checked against the consolidated rules text, 2026-10-15). Vendored substitute: not needed; stays **EB Garamond** (the court-named-face rule in `docs/FONTS.md` does not apply). Metric compatibility: n/a. |
| pages reviewed | 11 of 11 (re-rendered 2026-10-15 and every page rendered at 60 dpi and viewed) |

Build (from the repo root, with the toolchain on `PATH`):

```sh
D=courts/seventh-circuit/illinois/federal/northern-district/complaint
sh tools/render.sh $D usage/INPUT-ilnd-complaint-uniontankcar.md     # -> usage/OUTPUT-ilnd-complaint-uniontankcar.typst.pdf
sh tools/overlay.sh $D union-tank-car-complaint               # -> usage/OVERLAY-union-tank-car-complaint.{pdf,txt}
```

File names follow the tools, not the brief: `tools/render.sh` writes `OUTPUT-<id>.pdf` for a sample named `<id>.md`, and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>.pdf` and `<id>-overlay.pdf` names would not be found by the tools.

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Ill. LR 5.2(e) (https://www.ilnd.uscourts.gov/_assets/_documents/_rules/lrrules.pdf, "Amended ... May 18, 2023" text; the consolidated rules PDF is amended through May 4, 2026) | 8½ × 11 inch opaque white paper; line spacing "at least 2.0 lines"; 12-point type in the body; footnotes no less than 11 points; margins at least 1 inch on all four sides. | `page-w`, `page-h`, `margin-*` (1 in each), `type-size = 12pt`, `body-leading = 1.65em` (27.6 pt pitch, the exemplar's double pitch). |
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

- Page 1: court title (three centered lines, single-spaced), a caption in a box (the party column is closed by a rule on its right and bottom, as in the exemplar), the case number at right, the title and the jury legend.
- Body: double-spaced (27.6 pt pitch), justified, first-line indent 0.5 in on numbered paragraphs; numbered paragraphs use a hanging number at the indent.
- Headings: level 1 is a centered bold capital section; level 2 a centered bold sub-heading (the count title); level 3 bold, flush left. A heading takes one pitch above and below and stays with the next paragraph.
- Prayer items are lettered (a), (b), ... by the template.
- Signature block after the last paragraph: "Dated", "Respectfully submitted", "/s/" signer, firm, party. The last paragraph, its heading if any, and the signature block are kept together (a signature alone at a page top is not filed).
- Footer: page number, centered, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: a `#` heading (level 1 section), `##` (sub-heading), `###` (flush-left bold), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter: `case_number` (string; blank prints "Case No.:" alone), `judge` (optional), `division` (optional), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties; each name is one line), `brief_title` (list of lines), `jury_demand` (bool), `lead_in` (unnumbered introductory paragraph, optional), `date`, `signature` (`firm` lines, `signer`, `lines` for the signer's telephone, facsimile, e-mail, `party` lines).
- A level-1 heading whose text is `PRAYER FOR RELIEF` or `DEMAND FOR JURY TRIAL` turns numbering off for the paragraphs that follow it, until the next level-1 heading.
- Not supported: tables, footnotes (none used), raw typst.

## Known gaps and open choices

1. **One exemplar, so tier 2 is not judged against two filers.** The brief asks for one exemplar per doc type. The CourtListener RECAP search (`type=r`, `court=ilnd`, recent complaints with downloadable PDFs) also found complaints that were not saved: *Davis v. Klover Holdings Inc.* (docket 74735181, 42 pp), *Harris v. Trapananda Seafarms LLC* (docket 74708265, 80 pp), *Zaragoza v. Taylor Fresh Foods, Inc.* (docket 74686559, 31 pp), *Walker v. Veradigm Inc.* (docket 74763514, 32 pp, class action). Tier 2 for this doc type is therefore judged against this one filing only.
2. **Sample is a portion.** Paragraphs 1 to 40 and the prayer and jury demand are transcribed from the 33-page filing (captions, Nature of the Action, Parties, Jurisdiction and Venue, UTLX and BWE, the Demand Letter, the Asserted Patents, Count I). Counts II to IX are omitted, and the case list in paragraph 19 is cut to three citations, marked in the text. Paragraph numbers in the sample follow the template (they match the filing for paragraphs 1 to 40).
3. **Font.** No font is mandated by LR 5.2(e) (verified: the rule sets paper, line spacing, type size and margins only). The template keeps EB Garamond, per `docs/FONTS.md` (no court-named face, so no substitute). The exemplar is Times New Roman, and EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar's. This is a visual difference, not a rule difference; switching to Liberation Serif would be a style choice for David, not a conformance fix.
4. **Attorney identification.** The exemplar shows no attorney code or ARDC number, and the template prints none. Whether N.D. Ill. requires one on filings was not verified in this pass.
5. **Prayer lettering.** The exemplar letters the prayer A, B, C; the template uses (a), (b), (c) (the pleading convention in this repo's other templates). Recorded as ACCEPTED (tier 2, one filer).
6. **Caption style.** The exemplar's party column is closed by a rule (box style). Another N.D. Ill. filing reviewed, the memorandum in `../motion-brief/`, uses a column of ")" marks. Both are seen in N.D. Ill. practice; the template follows the box. Recorded as ACCEPTED.
7. **Not produced.** The designation sheet (LR 3.1), the Notification of Affiliates (LR 3.2), the Rule 7.1 disclosure statement, the summons and the exhibits are separate filings and are not part of this template.
8. **Judge's procedures.** The template does not model any assigned judge's standing order (LR 5.3(a)).
9. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (current PDF)

- Page 1: court title, caption (box), case number, title, jury legend; the first paragraph and the start of the numbered allegations. Pass.
- Page 2: paragraphs 4 to 9; "PARTIES" and "JURISDICTION AND VENUE" centered bold; paragraph spacing even. Pass.
- Page 3: paragraphs 10 to 14; "UTLX AND ITS BUSINESS" heading with a full pitch above and below. Pass.
- Page 4: paragraphs 15 to 18; "BWE AND ITS BUSINESS". Pass.
- Page 5: paragraphs 19 to 24; the case list of paragraph 19 is cut and marked; italics for case names. Pass.
- Page 6: paragraphs 25 to 27; the page ends after paragraph 27, the next heading moves with its paragraph. Pass.
- Page 7: heading "THE ASSERTED PATENTS AND BWE'S INFRINGEMENT ALLEGATIONS" (two centered lines, single-spaced, no hyphenation); paragraphs 28 to 32. Pass.
- Page 8: paragraphs 33 to 36; "COUNT I" and its two-line sub-heading clear of the paragraphs above and below. Pass.
- Page 9: paragraphs 37 to 40. Pass.
- Page 10: "PRAYER FOR RELIEF" (unnumbered), WHEREFORE paragraph, items (a) to (h) with hanging indents. Pass.
- Page 11: "DEMAND FOR JURY TRIAL" (unnumbered), its paragraph and the signature block, kept together. Pass.

## Engines

**docx** (`docx/build-reference.sh` builds `docx/reference.docx`; `docx/ilnd.lua` is the filter; `usage/OUTPUT-ilnd-complaint-uniontankcar.docx` is the output of `tools/render.sh --engine docx`).

- Matches the typst form: EB Garamond 12 pt body; exact 27.6 pt (double) body lines; first-line indent 0.5 in, justified; headings single-spaced with one double line above and below and kept with the next paragraph; front matter and signature lines single (13.8 pt); footnotes 11 pt single; US Letter with 1 in margins; the page number centered in the footer on every page (numbering from 1, as the typst template).
- Numbered paragraphs 1, 2, ... and prayer items (a), (b), ... are typed text, not Word list numbering.
- Differs or unverified: the caption box (a table with a rule on its right and bottom) and the signature block (a borderless table) are not checked against the typst layout; the numbers and letters use the default tab stops, not the template's 0.25 in gap; the last body paragraph is kept with the signature block by keep-with-next only.
- BLOCKED: `OUTPUT-ilnd-complaint-uniontankcar.docx.pdf` is not produced because `soffice` is not installed on this box, so `tools/check.sh --engine docx` (Gates 0 to 3 on the .docx.pdf) cannot run. No page has been rendered or reviewed for the docx engine (pages reviewed: 0). The check that the .docx opens in Word and LibreOffice without a repair prompt is not done. What was verified: the .docx is a valid zip and every XML part is well formed; the text reads back in the right order (pandoc readback).
