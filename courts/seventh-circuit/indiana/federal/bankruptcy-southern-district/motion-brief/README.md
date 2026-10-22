# S.D. Ind. bankruptcy (insb): motion-brief

Doc type: **motion-brief** (a motion with its supporting argument in one document, and a certificate of service). Court: United States Bankruptcy Court, Southern District of Indiana. Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 8 of 8 (typst and docx). Nothing here sets `court.json` status.

## Governing rules

Verified 2026-10-14. Each row is from the text named in its source column.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| INSB-MOT-001 | Fed.R.Bankr.P. 9013(a), (b) (eff. Dec. 1, 2024), text at https://www.law.cornell.edu/rules/frbp/rule_9013 | A request for an order must be made by written motion unless an exception applies. "A motion must state its grounds with particularity and set forth the relief or order requested." | Body: the first paragraphs state the relief and the grounds (author-written). `title` (caption) names the relief. |
| INSB-MOT-002 | S.D.Ind. Bankr. L.R. B-9013-1(a) (Local Rules as amended through Dec. 1, 2025), https://www.insb.uscourts.gov/sites/insb/files/Local-Rules.pdf (linked from https://www.insb.uscourts.gov/content/local-rules) | Every motion is filed separately (alternative relief may be combined). "All requests shall be named in the caption, state the order or relief sought, and contain a short and plain statement of the basis for the motion." | `title` in the caption (the request), the first paragraph (relief), the second (basis). Not checked by the template. |
| INSB-MOT-003 | B-9013-2(a), (b) (same text) | A certificate of service accompanies every pleading or document filed under Rule 9013 or 9014. The certificate conforms substantially to the court's Certificate of Service form in the Administrative Policies and Procedures Manual. | `certificate` in the frontmatter (rendered on its own page). The court's form was not fetched; the wording is the exemplar's. |
| INSB-MOT-004 | B-7007-1(a), (b) (same text) | Only for a motion to dismiss, for judgment on the pleadings, or for a more definite statement under Rule 12 (as applied by Rule 7012): a supporting brief is required (35 pages); the motion and brief may be combined into one document. Response 35 pages, reply 21 pages. | Not applicable to this exemplar (a Rule 9024 motion). The template supports a combined document; the page limits are not counted. |
| INSB-FORM-001 | Fed.R.Bankr.P. 9004(a) (eff. Dec. 1, 2024), https://www.law.cornell.edu/rules/frbp/rule_9004 | "A petition, pleading, schedule, or other document must be clearly legible." | Whole template: 12 pt, vendored font. |
| INSB-FORM-002 | S.D.Ind. B-5005-3 (same PDF) | "Papers submitted for filing shall be no larger than 8-1/2 by 11 in size." | `page-w`, `page-h` (US Letter). |

Not used, and why:
- B-9013-3 (first-day motions in Chapter 11 and 12) and B-9013-1(b) (stay relief may not be joined) and (c) (block scheduling). The exemplar is not a first-day or stay-relief motion, and the template does not check for those cases.
- The Local Rules (as amended through Dec. 1, 2025) contain no table-of-contents, table-of-authorities, memorandum-format, font, margin or line-spacing requirement. The PDF was searched for "table of", "memorand", "font", "double spac" and "point type": only the rules document's own contents page matched "table of". Every layout value is therefore a **layout choice**, marked at its definition.

## Layout choices (not rules)

- **Typeface.** Face required by the rules: none. The S.D.Ind. Local Rules (as amended through Dec. 1, 2025; checked 2026-10-15, `Local-Rules.pdf`) name no typeface; B-5005-1(b)(1) requires documents to be "plainly and legibly typewritten, printed, or reproduced". Substitute: none. Times New Roman 12 pt (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike; the exemplar is Times New Roman too.
- Double spacing at a 27.6 pt baseline pitch, matching the exemplar (measured with `pdftotext -bbox-layout`: 27.6 pt on every body line). Set as exact 27.6 pt line boxes (`pitch-body`; single lines 13.8 pt, `pitch-single`) on the shared cross-engine layout model (`lib/typst/xengine.typ`), with no extra space between paragraphs; headings and block quotations have 13.8 pt above and below.
- 1 inch margins on all sides.
- Headings: section headings in bold, typed by the author with their numbers (I., II., III.), as in the filing; the conclusion centered in capitals; the certificate of service on its own page.
- Block quotations single-spaced, indented 1 inch on the left and 0.5 inch on the right.
- A citation line that continues after a block quotation (e.g. "431 B.R. at 821-822 (citations omitted).") is flush left, as in the filing.
- The signature block sits left-aligned 3 in from the margin, below the date line; the last paragraph is kept with it.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Motion to Set Aside Order Granting Fifth Third's Request for Rule 2004 Examination of Your Community Bank (ECF Doc 588), 7 pages, filed July 1, 2011 by a non-party bank. Text-based (embedded TimesNewRoman).
- Provenance, searches and the era note are in `usage/SOURCE.md`.
- One exemplar, one filer, and a 2011 filing. The eval loop's tier-2 rule asks for two or three filed exemplars from different filers; this is a gap (see Known gaps).

## Sample

- `usage/INPUT-motion-brief.md`: the whole motion transcribed as filed: caption, title, the motion paragraphs, Sections I, II and III with citations and both block quotations, the conclusion, the date line and signature block, and the certificate of service.
- The markdown contract: YAML frontmatter (`case_number`, `chapter`, `division`, `debtor`, `title`, `date_line`, `signature`, `certificate`); `#` headings for level 1 (centered, e.g. CONCLUSION), `##` for level 2 (bold, e.g. the Section headings); a `>` block quotation; every other blank-line chunk is a paragraph with a first-line indent (a chunk starting "Id." or with a digit is flush left).
- Not transcribed: italics for case names and signals (the sample is plain text), because the exemplar's italic markup is not in its text layer. Footnotes: none in the filing.
- The template holds no case text.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief eastern-livestock-motion-set-aside
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 8 pages (7 pages of motion and signature, 1 certificate page). Typst compiled with no warnings (`render.sh` fails on any). Vendored font only: Times New Roman regular and bold, embedded.
- `usage/OVERLAY-eastern-livestock-motion-set-aside.pdf` and `.txt`: red = our render, blue = exemplar, black = both. Page map: ours p.1-6 ↔ filed p.1-6 (word overlap 52-86%); ours p.7 ↔ filed p.6 (34%: the conclusion and signature page, which is short in the filing, while ours carries the signature in a different place); ours p.8 ↔ filed p.7 (91%: the certificate). The overlay is a diagnostic, not a score; the layers do not coincide line for line because of the typeface and spacing.
- File names: `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (CLAUDE.md naming and the tools' defaults), not the `<id>.pdf` and `<id>-overlay.pdf` in the task brief.

## Visual review (Gate 2 record, all 8 pages, typst and docx, rendered at 50 dpi and looked at; fb-595.68.28)

The docx breaks every line and page as typst does (XENG-001..003), so one row covers both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor, Case No., Chapter 11), title (two bold lines), the opening paragraphs | OK. The title names the relief (B-9013-1(a)). |
| 2 | Section I heading and its paragraphs, Section II heading and its first lines | OK. Headings kept with their text. |
| 3 | Section II: paragraphs with string citations; the J & R Trucking block quotation begins | OK. The quotation single-spaced, 1 in in at the left and 0.5 in at the right. |
| 4 | Quotation end; "431 B.R. at 821-822" flush left; the second block quotation; "Id. at 822." flush left; the next paragraph | OK. |
| 5 | Paragraphs to the end of Section II; Section III heading (two lines) and its first paragraph | OK. |
| 6 | Section III continued, the Buick quotation, "Id. at 305.", the last paragraph of Section III | OK. White space at the foot: the conclusion is kept with the signature. |
| 7 | CONCLUSION, the closing sentence, the date line, the signature block 3 in from the margin | OK. |
| 8 | CERTIFICATE OF SERVICE on its own page (as filed), the text, the "/s/" line and "Counsel for Your Community Bank" | OK. |

Reviewed pages: 8 of 8 on both engines.

## Known gaps and open choices

1. **Tier-2 exemplars.** One exemplar, one filer, from 2011. The eval loop asks for two or three filed exemplars from different filers. Not done; a current S.D. Ind. bankruptcy motion with a hosted, text-based PDF would be needed. Searches tried are in `usage/SOURCE.md`.
2. **Case-name italics.** The sample is plain text: case names and signals are not italic. The filing's convention is italic (not checked against the image; the text layer has no italic markup). A tier-2 gap until the sample is marked up.
3. **Certificate of service form.** B-9013-2(b) requires conformity with the court's form, which was not fetched. The wording is the exemplar's.
4. **Font.** No face named by the rules (checked 2026-10-15); Times New Roman 12 pt, the house standard, in both engines.
5. **Length limits.** B-7007-1's 35-page limit applies only to Rule 12 motions; not checked by the template. This exemplar is 7 pages.
6. **Rule 9024 and the relief.** The exemplar moves under B.R. 9024 for relief from an order; the template does not check the rule text of Rule 9024 (not fetched).
7. **Corporate ownership statement (B-7007-2)** does not apply to a non-party bank in a contested matter; not generated.
8. **Proposed order.** None generated; the exemplar has none.

## Engines

**DOCX** (`docx/`). `docx/reference.xml` holds the Word styles: `base="xengine"` in the typst face (`{font}`, Times New Roman), 12 pt, 552-twip body and 276-twip single line boxes, headings with 276 twips above and below, and the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it. `docx/insb.lua` reads the sample's body chunk by chunk, as the typst template does, and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua`: the cover, the caption table, the argument (paragraphs, headings, block quotations, flush-left citation lines), the date line and signature, and the certificate of service on its own page, all from the sample's frontmatter and body. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002).

- Cross-engine (fb-595.68.28): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (8 = 8 pages, every line breaks after the same word); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.
- TOC and TOA: none in this doc type.
