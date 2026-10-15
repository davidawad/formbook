# txsb: adversary-complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the Southern District of Texas (`txsb`).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-southern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-camp-mystic-26-03604-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-camp-mystic.md`: the full body of the complaint (paragraphs 1 to 52, all three counts, the conclusion) and the caption, signature block and debtor footnote. Exemplar footnotes 2 to 4 and Appendix A are not transcribed. |
| render | ok: `samples/OUTPUT-camp-mystic.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 |
| overlay | **not regenerated (fail)**: `tools/overlay.sh` exits 1 because `exemplars/` holds only `SOURCE.md` in this snapshot (the filed PDF is not in the tree or in git). `samples/OVERLAY-camp-mystic.txt` is the page map from the earlier run; no `OVERLAY-camp-mystic.pdf` is present. |
| pages reviewed | 13 of 13 (fonts pass, 2026-10-14: every page rendered at 60 dpi and viewed on the final layout) |

## Governing rules

Verified 2026-10-14. Where a rule is cited from its text, the source is given; where it is cited only as referred to by another rule, that is said.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| BLR 1001-1(b) ([Bankruptcy Local Rules, effective March 3, 2026](https://www.txs.uscourts.gov/sites/txs/files/Local_Rules_March_3_2026.pdf)) | The District Court's Local Rules govern practice in the bankruptcy court, in addition to the Bankruptcy Local Rules. | Why LR10 below applies. |
| LR10.1 ([S.D. Tex. Local Rules, Sept. 2025 reprint](https://www.txs.uscourts.gov/sites/txs/files/LR%20September%202025%20Reprint.pdf)) | Papers must have a caption with the filer's name and party designation and a statement of the paper's character. | `caption` (court, division, parties, designations), `title`. |
| LR10.2 (same) | Papers: no covers; 8½ × 11 inch paper; stapled at the top only; punched at the top with two holes; double spaced; paginated. | `page-w`, `page-h`, `body-leading` (double spacing), `numbering: "1"` in the page setup. Staples and punch holes are the filer's, not the PDF's. |
| FRBP 9004(a), (b) ([Cornell, as amended Apr. 2, 2024, eff. Dec. 1, 2024](https://www.law.cornell.edu/rules/frbp/rule_9004)) | Papers must be clearly legible; caption must set out the court's name, the case title, the case number and adversary number, and a brief designation of the document. | `cover`: court name, `chapter`, `case_number`, `adversary_number`, `title`. |
| FRBP 7010 ([Cornell, as amended 2024](https://www.law.cornell.edu/rules/frbp/rule_7010)) | Fed. R. Civ. P. 10 applies in an adversary proceeding, except the caption must substantially conform to the appropriate Official Form. | Caption layout; the Official Form itself is not reproduced (see Known gaps). |
| FRCP 10(a), (b), as applied by FRBP 7010 | Caption, title, numbered paragraphs, each limited as far as practicable to one set of circumstances. | `allegations()`: each body paragraph is numbered 1, 2, ...; headings and lists are not. Text of FRCP 10 was not separately fetched in this run. |
| FRBP 7001 | Kinds of adversary proceedings (the complaint commences one). | Author content: the sample's first paragraphs cite Bankruptcy Rules 7001(g), 7001(i), 7065. The template does not check the cited rules. |
| FRBP 7008(a) and BLR 7008-1 ([BLR text](https://www.txs.uscourts.gov/sites/txs/files/Local_Rules_March_3_2026.pdf)) | A complaint that says the proceeding is core must say whether the pleader consents to final orders by the bankruptcy judge. | Author content (sample ¶¶ 12–13). The template does not check the wording. FRBP 7008(a) was not fetched; BLR 7008-1 was read from the local rules text. |

Not produced by this template (separate filings that may be required with the first filing): the Adversary Proceeding Cover Sheet (Official Form 1040 in the exemplar's cover sheet, as it appears on the CMG Funding filing); the summons; the Certification of Interested Parties if required by the judge. None of these is in the exemplar PDF we filed.

## Layout

- Page: US Letter, 1 inch margins on all sides (a convention; the rules set no margins), page numbers centered in the footer (LR10.2 "paginated").
- Type: EB Garamond 12 pt, the only font vendored in `fonts/`. No point size or typeface is set by the S.D. Tex. rules (see Known gaps).
- Typeface row (fonts pass, 2026-10-14): face required = none (the text of the Bankruptcy Local Rules, March 3, 2026, and the LR Sept. 2025 reprint was extracted with `pdftotext` and searched for font, typeface, type size and margin: none) → vendored substitute = EB Garamond (kept; the rules allow any face) → fit = n/a.
- Spacing: double spaced (1.35 em leading on a 12 pt face, 24 pt baseline pitch, as in the CAND template). Caption, counsel and signature blocks are single spaced.
- Caption: court name block (centered, bold), division, then a two-column caption: the left column has `In re:`, debtor names and footnote, the debtor designation, plaintiffs, `v.`, defendants, and the designation; it is closed by a rule at its right and bottom. The right column has chapter, case number, joint administration and adversary number.
- Title: centered, bold, all caps.
- Body: paragraphs numbered from 1 with a 0.5 inch first-line indent; level 1 headings centered bold; level 2 centered bold (count headings); level 3 bold, left (A., B., ...). A heading and the paragraph after it are kept together, and the last paragraph is kept with the signature block, so a signature never stands alone.
- Signature: `Dated:` at left; `Respectfully submitted,` and each signing block at right, blocks separated by `-and-`.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `division`, `caption` (`debtor_names`, optional `debtor_footnote`, `debtor_designation`, `plaintiff_names`, `plaintiff_designation`, `defendant_names`, `defendant_designation`), `chapter`, `case_number`, optional `joint_admin`, `adversary_number`, `title`, optional `lead_in` (an unnumbered paragraph before ¶1), `dated`, `signature.blocks` (a list of lists of lines; the first line of the first block is the `/s/` line).
- Body: blank-line-separated chunks. `#` = level 1, `##` = level 2, `###` = level 3 heading. A chunk starting `1. ` is a list (items lettered (a), (b), ... by the template). A chunk starting `> ` is an unnumbered paragraph (for a clause the filing does not number). Any other chunk is a numbered paragraph.
- Do NOT number the paragraphs in the sample: the template numbers them, and a chunk that starts with `N. ` is read as a list.
- Not supported: body footnotes (only the caption footnote), tables, raw typst.

## Known gaps and open choices

1. **No typeface, point size or margin in the rules.** The S.D. Tex. bankruptcy local rules (read by their rule headings; there is no BLR 9004 formatting rule, and BLR 9013-1 covers notices and service) and the district LR10 set no typeface, no point size and no margins; LR10.2 sets paper size, double spacing, pagination and binding. EB Garamond 12 pt and 1 inch margins are choices. The exemplar is Times New Roman (embedded), so EB Garamond looks smaller at the same point size. A Times-metric font is not vendored (the brief forbids adding one here).
2. **Judges' individual procedures** (BLR 1001-1(c)(4), (d)) were not checked. A judge may impose format rules; this template does not reflect any judge's procedures.
3. **Only one exemplar.** The brief asks for one filed document per doc type. The Camp Mystic complaint is the only one saved. Tier 2 is therefore not judged against two or three filers. Other adversary complaints found on CourtListener (for example Blouse v. Nine Energy Service, Adv. 26-03630, 35 pages, scanned) were not saved.
4. **Numbering across the sample.** The sample transcribes the whole complaint, so its paragraph numbers match the filing (1 to 52). The overlay page map pairs our pages with the exemplar by word overlap, not by number.
5. **The ECF header is not reproduced.** The filed PDF carries the clerk's header ("Case 26-03604 Document 1 Filed in TXSB on ..."). That header is applied by the electronic filing system, not the filer; it appears in blue on the overlay and is absent from the render.
6. **Caption layout is a convention.** The exemplar's caption uses a party column and a right column with case number and adversary number, with no `§` column; the template uses a bordered left column. The rules do not specify the caption layout beyond LR10.1 and FRBP 9004(b).
7. **Attorney-in-charge designation** (LR11.1 designates the attorney in charge by signing the pleading) is not printed as a separate line. The exemplar does not print one.
8. **Overlay.** Red = our render, blue = the matched exemplar page, black = both. The overlay was generated and checked as a page map; in thumbnails the caption and title sit at different heights from the exemplar, and the blue ECF header appears (gap 5). The overlay is a diagnostic, not a score.

## Review of the rendered pages (13 pages, final layout)

- Page 1: court name and division centered; caption with debtor, plaintiffs, defendants, chapter, case number and adversary number; title; lead-in; ¶ 1; footnote 1 (debtor). No spill.
- Pages 2 to 5: ¶¶ 2 to 23 (Introduction, Jurisdiction and Venue, Parties, Background, A. General Background), centered bold or left bold headings. Pass.
- Pages 6 to 7: ¶¶ 24 to 32; B. The Prepetition Actions; Claims for Relief, Count I heading and its sub-heading kept with ¶ 31. Pass.
- Page 8: ¶¶ 33 to 36 (Count I); the page ends early because Count II's heading and ¶ 37 move to the next page with it. Pass.
- Pages 9 to 10: Count II (¶¶ 37 to 40), Count III heading, ¶¶ 41 to 47. Pass.
- Page 11: ¶¶ 48 to 51 (the balance of harms and public interest). Pass.
- Page 12: the end of ¶ 51 only; the page ends early because the conclusion and ¶ 52 stay with the signature block. Pass.
- Page 13: Conclusion and Request for Relief heading; ¶ 52; the signature block (Dated; Respectfully submitted; two signing blocks). Pass.
- Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

docx (`docx/`): `build-reference.sh` writes `reference.docx` (styles, footer page number); `complaint.lua` builds the caption, numbered paragraphs, lettered lists and signature block from the sample; `render.sh` runs pandoc, then writes the caption rules and keeps table rows whole. Output: `samples/OUTPUT-camp-mystic.docx` and `.docx.pdf` (LibreOffice, 13 pages; typst is 13 pages).

- Matches the typst form: EB Garamond 12 pt; body double spaced as an exact 24 pt line; 1 in margins, letter; 0.5 in first-line indent; numbered paragraphs; headings (centered bold for levels 1 and 2, bold left for level 3); the two-column caption with the right and bottom rules and the case numbers at right; centered page number; footnote text 10 pt (typst measures about 10.2 pt); single-spaced lines at the typst pitch (13.8 pt); signature block kept whole.
- Differs, and why: the paragraph numbers are typed with a tab, not Word auto-numbering (the numbers are the sample's own); the caption rules are cell borders added by `docx/render.sh`, because pandoc cannot write cell borders and LibreOffice does not draw paragraph borders in a table cell; LibreOffice places exact-line text about 3 pt lower than typst, so a page can hold one line less and a break can fall differently (page counts match on this sample).
- Opened and converted with LibreOffice only; Word was not checked.
- BLOCKED: none.
