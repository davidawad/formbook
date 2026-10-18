# lamb (Bankruptcy Court, M.D. La.): motion with incorporated memorandum

Doc type: **motion** with an incorporated memorandum (FRBP 9013; LR 9013-1 motions, LR 9013-2 memoranda) in the United States Bankruptcy Court for the Middle District of Louisiana (`lamb`).
Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | **yes**: `usage/SAMPLE-lamb-motion-brief-kologik2410311.pdf`, pp. 1-19 of Doc. 8 in *In re Kologik, LLC, et al.*, No. 24-10311 (Bankr. M.D. La.), filed 04/23/2024. Source, fetch date, checksums and the reason for choosing it are in `usage/SOURCE.md`. The PDF was missing from the tree until re-fetched on 2026-10-14. |
| typeface | Rule names **no face**: LR 5005-2(b) requires "12-point font and be double-spaced" (2022 local rules); LR 9013-5(b) requires "12 point font" for proposed orders. Neither names a typeface (read from the court's PDF 2026-10-14). Keeps **EB Garamond** (vendored, OFL). |
| sample md | `usage/INPUT-lamb-motion-brief-motionbriefsample.md`: a transcription of exemplar pp. 1-19 (caption, Material Terms table, nine footnotes, block quotation, prayer, signature). Placeholders only in the hearing fields (see gap 2). |
| render | ok (re-run 2026-10-14): `sh tools/render.sh` exit 0, no typst output; `usage/OUTPUT-lamb-motion-brief-motionbriefsample.typst.pdf`, 18 pages, letter, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular, -Bold, -Italic, all embedded). |
| overlay | ok (re-run 2026-10-14): `sh tools/overlay.sh` exit 0 once the exemplar was restored; `usage/OVERLAY-motion-brief-sample.pdf` (18 pages) and `.txt` (page map). |
| pages reviewed | 18 of 18 (re-run 2026-10-14): every page of the re-rendered output viewed as PNG at 100 dpi. Page 18 is the signature block alone (gap 4, OPEN). |
| tier 1 (mandated form) | Pass on the rule points the template checks: letter size, 12 pt, double-spaced body, legible vendored font, caption, notice, contact block (LR 9013-1(a)), footer page numbers. The 15-page memorandum limit (LR 9013-2) is not checked by the template; this exemplar is 18 pages including the motion. See gap 1. |
| tier 2 (clerk conventions) | One open item: the signature block falls alone on page 18 (gap 4). Everything else in the overlay review matches the filing's conventions. |

File names. The brief asks for `usage/<id>.md`, `usage/<id>.pdf` and `<id>-overlay.pdf`. The repo tools read and write `usage/OUTPUT-<id>.pdf` and `usage/OVERLAY-<id>.pdf/.txt`, and `tools/` is not to be edited, so the tool names are used.

## Governing rules

Primary sources, verified 2026-10-14. The court's rules were read from its own 2022 PDF (https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf, amended January 1, 2022). FRBP 9013 was read through a summarizing fetch of https://www.law.cornell.edu/rules/frbp/rule_9013, not the official text, so its quoted words should be checked against the official rule.

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| LAMB-FORM-001 | LR 5005-2(a) | 8½ × 11 inches. | `page` in `typst/lamb-motion-brief.typ`. |
| LAMB-FORM-002 | LR 5005-2(b) | 12-point font, double-spaced, for all documents except pro se parties. | `type-size = 12pt` everywhere, headings and footer included. |
| LAMB-FORM-003 | LR 5005-2(b) | Double-spaced. | `body-leading = 0.7em`, baseline pitch 24.06 pt on body pages (`pdftotext -bbox-layout`). Block quotations, headings, footnotes and the Material Terms table are single-spaced. |
| LAMB-FORM-004 | FRBP 9004(a) | Clearly legible. | Vendored EB Garamond; `fallback: false`. |
| LAMB-CAP-001 | FRBP 7010 (adversary proceeding caption, Form 416) and FRBP 9004 as applied to motions in a main case | Caption with court, parties and numbers. | `caption(meta)`. An adversary caption is used when `plaintiff` is given; a main-case caption otherwise. |
| LAMB-MOT-001 | FRBP 9013(b) | "A motion must state its grounds with particularity and set forth the relief or order requested." (from the summarizing fetch above) | Author writes the grounds in the body; the `relief` field is printed in the notice. The template requires `relief` and `title`. |
| LAMB-MOT-002 | LR 9013-1(a) | Every motion and proposed order includes the filer's current, direct e-mail address, a current operable telephone number, and physical address. | `contact` frontmatter (`email`, `phone`, `address`), printed in the signature block. The template panics if any is missing. |
| LAMB-MOT-003 | LR 9013-1(b)(2)(i)-(iii) | The notice states the motion's title, concisely describes its content and relief, and gives the date, time and place of the hearing. It states that an objection or response is due no later than eight days before the hearing, and must be served on the mover or its counsel; it may not say the hearing will be held only if an opposition is filed. | `notice(meta)`. The objection sentence follows the rule; the hearing details come from the `hearing` frontmatter. The template does not use the prohibited "only if" wording. |
| LAMB-MOT-004 | LR 9013-1(e), LR 9013-5(a)-(c) | The mover submits a proposed order by e-mail to orders@lamb.uscourts.gov, in Microsoft Word with 12-point font; the caption of an order shows no numbers other than the case and adversary numbers; the introductory phrase identifies the mover and the motion. | **Not generated**: the proposed order is a separate Word document. |
| LAMB-MOT-005 | LR 9013-2 | If the motion needs a memorandum, the mover files it with the motion; it is double-spaced, paginated, and does not exceed fifteen pages, excluding attachments, without leave of court. | Body is double-spaced; footer page numbers on every page. The 15-page limit is **not checked by the template**: the page count is the author's to check (see gap 1). |
| LAMB-MOT-006 | LR 9013-4(a)-(b) | A certificate of service is filed separately, in CM/ECF, identifying the documents served, the persons served by name and address, and the date and method; a collective designation such as "all interested parties" does not comply. Service goes to the trustee, the debtor, debtor's counsel and the U.S. Trustee. | **Not generated**: separate filing. The template does not print one. |

Not checked by the template: the grounds stated in the body, the authorities cited, the defendants' or the mover's standing, the hearing-date rules of LR 9013-3 (motion-day scheduling), and the requirement that a motion be in writing (FRBP 9013(a)).

## Layout and template

- Caption: as in the complaint template (court name centred; two-column caption; right column case, chapter and adversary numbers).
- Title: centred, bold capitals, from `title`.
- Notice of motion and opportunity for hearing (LR 9013-1(b)(2)): a centred heading, then three paragraphs: the filing and relief; the hearing date, time and place; the objection deadline. The template prints this on page 1 before the body.
- Body: the whole markdown body rendered by cmarker. `#` headings are centred bold capitals; `##` bold; `###` bold italic. Paragraphs are double-spaced with a first-line indent. Block quotations are single-spaced and indented 0.5 in on each side. Footnotes are 12 pt (the template sets the footnote entry size). Tables are single-spaced (`show table` rule; the cell text stays 12 pt).
- Signature: `Dated:` on the left; on the right, `Respectfully submitted,`, the signer as `/s/`, the counsel lines in italic, then the address (one string, or a list of lines), telephone and e-mail from `contact`.
- Not generated: proposed order (LR 9013-5, separate Word file); certificate of service (LR 9013-4, separate filing); a table of contents or table of authorities (LR 9013-2 does not require one; add if the court or a judge asks).

Changes made in this pass (all in `typst/lamb-motion-brief.typ`): tables single-spaced; the address may be a list of lines. Nothing rule-driven changed.

## Frontmatter (schema)

| Field | Required | Feeds |
|---|---|---|
| `title` | yes | Title under the caption; PDF title; notice. |
| `relief` | yes | Notice: "The motion seeks ..." (ends with a full stop). |
| `hearing` | yes | `date`, `time`, `place`: the notice's hearing sentence. |
| `debtor` | yes | "In re:" line. |
| `case_no`, `chapter` | yes | Case number and chapter. |
| `adv_no` | no | "Adversary Proceeding No." (shown when given). |
| `plaintiff`, `defendants` | when `plaintiff` is given | Adversary caption parties. |
| `date` | yes | "Dated:" line. |
| `signature` | yes | `signer` and `lines` (counsel block). |
| `contact` | yes | `email`, `phone`, `address` (a string, or a list of lines), printed in the signature block (LR 9013-1(a)). |

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief
sh tools/render.sh $D usage/INPUT-lamb-motion-brief-motionbriefsample.md        # -> usage/OUTPUT-lamb-motion-brief-motionbriefsample.typst.pdf
sh tools/overlay.sh $D motion-brief-sample                        # -> usage/OVERLAY-motion-brief-sample.pdf/.txt
```

Render: 18 pages, us-letter. `pdffonts`: EBGaramond-Regular, -Bold and -Italic only, all embedded. `render.sh` exits 0 with no typst output.

Overlay: pairs each sample page with the exemplar page sharing the most words. The sample and the filing differ in pagination, so the pairing is off by one in places (sample p.2 pairs with filed p.1; sample p.13 with filed p.14). The word overlap ranges from 37% (p.1) to 97% (p.17). The overlay PDF's pages are 241 × 312 pt, not letter (the tool's `magick -density 100` setting); the page images inside are 850 × 1100 px at 254 ppi, so the detail is there. This is a `tools/overlay.sh` artefact and `tools/` is not edited here.

Pitch: 24.06 pt on the body lines of page 2 (unchanged from the earlier calibration).

## Visual review (final layout, 18 pages, 100 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, notice of motion (three paragraphs), opening paragraph | OK. The title's apostrophe is curly now (frontmatter text is not smart-quoted; it had printed "Debtors'"). The notice's hearing sentence shows placeholders (gap 2). |
| 2 | Opening paragraph, JURISDICTION & VENUE, CONCISE STATEMENT, start of the Material Terms table | OK. Footnotes 1-2 on the page. The table starts on this page after the footnote fix (gap 3). |
| 3 | Material Terms table, Duration to Adequate Protection | OK. Column widths and single spacing as filed; the header row repeats on continuation pages (gap 7). |
| 4 | Table: Adequate Protection (continued), Carve Out | OK. |
| 5 | Table: Carve Out (continued) | OK. |
| 6 | Table end, BACKGROUND ¶¶ 3-7 start, footnotes 3-4 | OK. |
| 7 | ¶ 7 (continued), ¶¶ 8-9, footnotes 5-7 | OK. The UCC-1 footnote now sits at ¶ 7 (gap 3). |
| 8 | ¶¶ 9-13, footnote 8 | OK. |
| 9 | ¶¶ 14-16, RELIEF REQUESTED | OK. |
| 10 | ¶¶ 16-21, BASIS FOR RELIEF, ¶ 17 quotation, ¶ 18 block quotation | OK. The block quotation is single-spaced and indented. |
| 11 | ¶¶ 21-26, sub-heading B | OK. |
| 12 | ¶¶ 27-30 | OK. |
| 13 | ¶¶ 31-33, sub-heading C | OK. |
| 14 | ¶¶ 33-35, footnote 9 | OK. |
| 15 | ¶¶ 36-38, sub-heading D, FINAL HEARING REQUESTED | OK. |
| 16 | ¶¶ 39-41, EMERGENCY CONSIDERATION, BANKRUPTCY RULE 6004, RESERVATION OF RIGHTS | OK. |
| 17 | ¶ 41 (continued), NOTICE ¶ 42, CONCLUSION (WHEREFORE) | OK. |
| 18 | Signature block only: `Dated:`, `Respectfully submitted,`, counsel, address, telephone, e-mail | **OPEN**: the signature block falls alone on this page; the WHEREFORE paragraph ends page 17 (gap 4). |

## Known gaps and open choices

1. **Exemplar length.** The exemplar is 19 pages of motion (pp. 1-19 of Doc. 8; the proposed orders on pp. 20-42 are not in the exemplar). The sample is the full motion and renders at 18 pages, which is the exemplar's length, not the 8-14 page target. The filing's argued part (BASIS FOR RELIEF, pp. 10-17) runs about eight pages, within the LR 9013-2 limit of fifteen pages (excluding attachments) if it counts as a memorandum; the whole motion is 18 pages. The template does not check the limit. Check the page count for any real filing.
2. **Notice of hearing.** The filed motion is an emergency motion. It has no LR 9013-1(b)(2) notice of hearing; the filing cites LR 9013-3(d) for emergency consideration. The template prints the notice on page 1 anyway, with bracketed placeholders for the hearing date, time and place (`hearing` in the sample). The notice is rule-driven and is kept; this is an accepted difference for emergency motions, not a defect.
3. **Footnote 3 is in ¶ 7, not in the table.** The filed footnote 3 is attached to the Kelly row of the Material Terms table. A typst footnote inside a table cell printed the footnote text on page 2 while its marker sat in the table on page 3. The marker now sits in ¶ 7, next to the Gordon Oaks sentence it explains; the footnote text is unchanged. Typst footnotes in table cells remain a limitation of this template.
4. **OPEN (tier 2): signature block alone on page 18.** The Conclusion paragraph ends page 17 and the signature block (`sticky`) follows alone. The template cannot keep the last body paragraph with the signature because cmarker renders the body as one flow. Options: a keep-with-next wrapper on the conclusion paragraph (needs a template change that cmarker does not expose), or accept. Not fixed.
5. **Signature block differs from the filing.** The filing has two counsel blocks (Louis M. Phillips, Baton Rouge; Erin K. Arnold and Amelia L. Hurt, New Orleans). The template prints one counsel block; the sample prints the Baton Rouge block only. The filing's caption line "(Joint Administration Requested)" is not a template field and is not printed.
6. **Footnote numbers.** The filing's text says "as mentioned above in foot note 4" for the UCC-1 caveat, but the caveat is footnote 3 in the filing and footnote 5 in this render (footnotes renumber automatically). The sentence is kept verbatim, as filed.
7. **Table header repeats.** cmarker repeats the table's header row at the top of each continuation page. The filing does not repeat it. Accepted as a reader aid.
8. **Table cell structure.** The adequate-protection and carve-out rows put the filing's a./b./c. and A./B./(A)/(B) sub-items in run-in text within one cell; the filing set them on separate lines. The text is complete; the layout is flattened.
9. **Filing typos kept verbatim.** "Claims,," (¶ 28), "Case No. 2333015" (¶ 35), "Las Torres ... (Bankr. S.D. Tex. 2009)" with an unclosed parenthesis (¶ 26), "Post- Tron". Not corrected: the transcription is the filed text.
10. **Overlay page size.** The overlay PDF's pages are 241 × 312 pt (see Render and overlay). A `tools/overlay.sh` artefact; left alone because `tools/` is shared.
11. **Court's current rules.** Read from the 2022 PDF. The filing is from 2024 and cites LR 9013-3(d)(3); Standing Order 2024-2 amends LR 4001-1(f) and refers to LR 9013-5. Other amendments after 2022 were not checked because the court's site is blocked from this box.
12. **FRBP 9013 wording.** Quoted from a summarizing fetch (see Governing rules). Check the official text before this template is treated as final.
13. **Font.** EB Garamond at 12 pt, not Times New Roman. LR 5005-2(b) and LR 9013-5(b) name a size only, no typeface (read from the court's 2022 PDF on 2026-10-14). The Administrative Procedures Manual, which the filing cites for the notice list, was not read, so a face named there is unchecked.
14. **Overlay pairing.** The overlay pairs pages by word overlap (see Render and overlay); pairs are shown in `usage/OVERLAY-motion-brief-sample.txt`.

## Engines

DOCX (`docx/`: `build-reference.sh`, `reference.docx`, `lamb-motion-brief.lua`; `usage/OUTPUT-lamb-motion-brief-motionbriefsample.docx` is written by `sh tools/render.sh --engine docx`).

- Matches the typst form: EB Garamond 12 pt, exact 24 pt (double) body lines, single-spaced footnotes, block quotations, caption, table cells and signature block; 1 in margins on letter; centred PAGE number in the footer; Form 416 style caption; notice of motion and opportunity for hearing (LR 9013-1(b)(2)) with the same wording; headings centred bold capitals (level 1), bold (level 2), bold italic (level 3).
- Differs: the "NOTICE" and caption are built by the filter from frontmatter; table cells are single-spaced by a table pass, not by the table style. Footnotes are Word-native footnotes (footnote text 12 pt, single). Pagination follows the renderer (Word and LibreOffice can break lines differently).
- No TOC or TOA in this form, so no field-update caveat applies.
- Not run here: no LibreOffice on this box, so no `.docx.pdf` and no page was viewed. `OUTPUT-lamb-motion-brief-motionbriefsample.docx` was validated only as a zip with well-formed XML parts.
- BLOCKED: docx.pdf gates (tools/check.sh --engine docx, Gates 0-3 on `usage/OUTPUT-motion-brief-sample.docx.pdf`): LibreOffice (`soffice`) is not installed on this box, so no PDF can be made and the stamp `.check-docx.txt` is not written.
