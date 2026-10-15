# S.D. Ind. bankruptcy (insb): motion-brief

Doc type: **motion-brief** (a motion with its supporting argument in one document, and a certificate of service). Court: United States Bankruptcy Court, Southern District of Indiana. Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 8 of 8. Nothing here sets `court.json` status.

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

- **Typeface.** Face required by the rules: none. The S.D.Ind. Local Rules (as amended through Dec. 1, 2025; checked 2026-10-15, `Local-Rules.pdf`) name no typeface; B-5005-1(b)(1) requires documents to be "plainly and legibly typewritten, printed, or reproduced". Substitute: none. EB Garamond 12 pt is kept (vendored, OFL), as `docs/FONTS.md` says for a court that names no face. The exemplar is Times New Roman, which the rules do not require.
- Double spacing at a 27.6 pt baseline pitch, matching the exemplar (measured with `pdftotext -bbox-layout`: 27.6 pt on every body line). `body-leading = 1.65em` on the 0.65 em line box (same method as the CAND template).
- 1 inch margins on all sides.
- Headings: section headings in bold, typed by the author with their numbers (I., II., III.), as in the filing; the conclusion centered in capitals; the certificate of service on its own page.
- Block quotations single-spaced, indented 1 inch on the left and 0.5 inch on the right.
- A citation line that continues after a block quotation (e.g. "431 B.R. at 821-822 (citations omitted).") is flush left, as in the filing.
- The signature block sits left-aligned from about the middle of the page, below the date line.

## Exemplar

- `exemplars/FILED-EXAMPLE-eastern-livestock-10-93904-motion-brief.pdf`: Motion to Set Aside Order Granting Fifth Third's Request for Rule 2004 Examination of Your Community Bank (ECF Doc 588), 7 pages, filed July 1, 2011 by a non-party bank. Text-based (embedded TimesNewRoman).
- Provenance, searches and the era note are in `exemplars/SOURCE.md`.
- One exemplar, one filer, and a 2011 filing. The eval loop's tier-2 rule asks for two or three filed exemplars from different filers; this is a gap (see Known gaps).

## Sample

- `samples/INPUT-eastern-livestock-motion-set-aside.md`: the whole motion transcribed as filed: caption, title, the motion paragraphs, Sections I, II and III with citations and both block quotations, the conclusion, the date line and signature block, and the certificate of service.
- The markdown contract: YAML frontmatter (`case_number`, `chapter`, `division`, `debtor`, `title`, `date_line`, `signature`, `certificate`); `#` headings for level 1 (centered, e.g. CONCLUSION), `##` for level 2 (bold, e.g. the Section headings); a `>` block quotation; every other blank-line chunk is a paragraph with a first-line indent (a chunk starting "Id." or with a digit is flush left).
- Not transcribed: italics for case names and signals (the sample is plain text), because the exemplar's italic markup is not in its text layer. Footnotes: none in the filing.
- The template holds no case text.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief samples/INPUT-eastern-livestock-motion-set-aside.md
sh tools/overlay.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/motion-brief eastern-livestock-motion-set-aside
```

- `samples/OUTPUT-eastern-livestock-motion-set-aside.pdf`: 8 pages (7 pages of motion and signature, 1 certificate page). Typst compiled with no warnings (`render.sh` fails on any). Vendored font only: EBGaramond-Regular and -Bold, embedded (Identity-H).
- `samples/OVERLAY-eastern-livestock-motion-set-aside.pdf` and `.txt`: red = our render, blue = exemplar, black = both. Page map: ours p.1-6 ↔ filed p.1-6 (word overlap 52-86%); ours p.7 ↔ filed p.6 (34%: the conclusion and signature page, which is short in the filing, while ours carries the signature in a different place); ours p.8 ↔ filed p.7 (91%: the certificate). The overlay is a diagnostic, not a score; the layers do not coincide line for line because of the typeface and spacing.
- File names: `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (CLAUDE.md naming and the tools' defaults), not the `<id>.pdf` and `<id>-overlay.pdf` in the task brief.

## Visual review (Gate 2 record, all 8 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor, Case No., Chapter 11), title, opening paragraphs of the motion | OK. The title names the relief (B-9013-1(a)) and wraps across two bold lines. |
| 2 | Section I heading and its first two paragraphs | OK. The heading kept with its text. White space at the foot: Section II's heading moves to page 3 with its first paragraph. |
| 3 | Section II: paragraphs with string citations; the block quotation from J & R Trucking begins | OK. The quotation is indented on both sides and single-spaced. |
| 4 | Block quotation end; citation "431 B.R. at 821-822" flush left; paragraph on the Perkins quotation; second block quotation; "Id. at 822." flush left | OK. |
| 5 | Paragraphs after the second block quotation, through the end of Section II | OK. White space at the foot: Section III's heading is kept with its first paragraph. |
| 6 | Section III: heading (two lines), its first paragraph, block quotation from Buick, "Id. at 305.", the final paragraph of Section III | OK. |
| 7 | CONCLUSION, the closing sentence, the date line, the signature block (left-aligned from the middle of the page) | OK after the fix: the name appears once, with "/s/" above. Earlier passes showed the name twice and a right-aligned block; both fixed. |
| 8 | CERTIFICATE OF SERVICE on its own page, the certificate text, the "/s/" line and "Counsel for Your Community Bank" | OK. |

Reviewed pages: 8 of 8. Pages 2-5 were reviewed on the render before the signature fix and were not re-viewed afterwards; the fix changed only the signature and certificate code, which comes after the body, so those pages cannot have moved. Pages 1 and 6 were re-viewed on the final render.

## Known gaps and open choices

1. **Tier-2 exemplars.** One exemplar, one filer, from 2011. The eval loop asks for two or three filed exemplars from different filers. Not done; a current S.D. Ind. bankruptcy motion with a hosted, text-based PDF would be needed. Searches tried are in `exemplars/SOURCE.md`.
2. **Case-name italics.** The sample is plain text: case names and signals are not italic. The filing's convention is italic (not checked against the image; the text layer has no italic markup). A tier-2 gap until the sample is marked up.
3. **Certificate of service form.** B-9013-2(b) requires conformity with the court's form, which was not fetched. The wording is the exemplar's.
4. **Font.** No face named by the rules (checked 2026-10-15); EB Garamond at 12 pt is kept. Not a Times New Roman template, because the rules do not require one.
5. **Length limits.** B-7007-1's 35-page limit applies only to Rule 12 motions; not checked by the template. This exemplar is 7 pages.
6. **Rule 9024 and the relief.** The exemplar moves under B.R. 9024 for relief from an order; the template does not check the rule text of Rule 9024 (not fetched).
7. **Corporate ownership statement (B-7007-2)** does not apply to a non-party bank in a contested matter; not generated.
8. **Proposed order.** None generated; the exemplar has none.

## Engines

**DOCX** (`docx/`). `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference: EB Garamond 12 pt, exact 27.6 pt (double) line spacing, 0.5 in first-line indent, letter page with 1 in margins, a centered page number in the footer, and single-spaced caption and signature styles. `docx/insb.lua` lays out the cover, the caption table, the date line, the signature block and the certificate of service (on its own page), all from the sample's frontmatter and body. Block quotations are single spaced, indented 1 in left and 0.5 in right; citation lines that start with "Id." or a digit are flush left.

- Matches the typst form, by construction: font and size, double spacing, first-line indent, margins, the page-number footer, the caption, signature and certificate text.
- Differs or is unverified: the body grid is kept by exact line spacing, not by typst's block rounding, so page breaks may fall differently; the caption rule (0.75 pt, right and bottom) is written as XML and not checked against the typst layout; the signature block is paragraphs indented 3 in, not a table.
- BLOCKED: docx.pdf checks (Gates 0 and 1 on `samples/OUTPUT-eastern-livestock-motion-set-aside.docx.pdf`): not produced, because `soffice` is not installed on this box. No page was rendered or reviewed (pages reviewed 0).
- `sh tools/render.sh --engine docx` writes `samples/OUTPUT-eastern-livestock-motion-set-aside.docx`, then fails at the soffice step (expected here). The `.docx` was checked with `unzip -tq` and `xmllint --noout` on every XML part.
- TOC and TOA: none in this doc type.
