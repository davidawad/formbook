# wawd: motion-brief (motion to dismiss with memorandum)

Doc type: **motion-brief**, specifically a Rule 12(b) motion to dismiss with its memorandum, in the United States District Court for the Western District of Washington (`wawd`).
Folder: `courts/ninth-circuit/washington/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`). Tier 2 is not judged against two or three filers; see gaps. |
| sample md | `usage/INPUT-motion-brief.md`: caption, noting data, table of contents, the introduction through Argument II, the conclusion, the word-count certificate, signature, and certificate of service. Argument III and IV, and the table of authorities, are not transcribed (see gaps). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 13 pages, typst 0.15.0, Times New Roman (pinned) only, no typst warnings. |
| overlay | ok: `usage/OVERLAY-hoffman-motion-to-dismiss.pdf` and `usage/OVERLAY-hoffman-motion-to-dismiss.txt`. |
| pages reviewed | 13 of 13, typst and docx: every page rendered at 60 dpi side by side and viewed in its final state (2026-10-22). |
| typeface | Face required: **none**. LCR 10(e)(1) requires "a proportionally spaced font" and names no face, and the filed motion embeds Times New Roman, so the template sets Times New Roman (`docs/FONTS.md`: a Times exemplar), in every engine. Checked against the rule text, 2026-10-15. Metric fit: n/a. |

## Governing rules

Primary source: W.D. Wash. Local Civil Rules (2026 edition, "WAWD Local Civil Rules (2026) - Clean"), downloaded 2026-10-14 from https://www.wawd.uscourts.gov/sites/wawd/files/WAWD%20Local%20Civil%20Rules%20%282026%29%20-%20Clean.pdf. The court's proposed 2026 amendments (dated 2026-09-22) amend LCR 100 only. LCR rule text was checked against the PDF text layer. Fed. R. Civ. P. 10(a) was fetched from https://www.law.cornell.edu/rules/frcp/rule_10 and checked; Fed. R. Civ. P. 5, 7(b) and 12(b) are cited by number only and were not re-checked against their text in this pass.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCR 10(d) | 8 1/2 x 11 inch page. | `page-w`, `page-h`. |
| LCR 10(e)(1) | No less than three inches above the court title on the first page; one-inch margins; 12 pt or larger; double spaced or exactly 24 pt; proportionally spaced font. | `first-page-blank = 6`; `top-margin`, `right-margin`; `type-size = 12pt`; `pitch-body = 24pt`; `font-family = ("Times New Roman", "Liberation Serif")`. Footnotes are not used in the sample (see gaps). |
| LCR 10(e)(2) | "United States District Court, Western District of Washington" on the first page, and a title below the docket number. | `court-title()`, `caption()`. |
| LCR 10(e)(3) | Bottom notation: left, the abbreviated title and case number with the page number; right, the firm, mailing address and telephone (the filing may omit the firm block). | `footer-block()`: title and case number at left; `footer_firm` at right (omitted when the sample gives none). |
| LCR 10(e)(4) | Dated and signed under Fed. R. Civ. P. 11 and LCR 11. | `signature-block()`. |
| LCR 10(e)(5) | Line numbers in the left margin, at least half an inch to their left. | `line-numbers()`, 27 numbers on the 24 pt grid. |
| LCR 7(b)(4) | "ORAL ARGUMENT REQUESTED" in the caption of a motion or responsive memorandum that asks for argument. | `caption_notes` (the sample requests argument). |
| LCR 7(d)(4) | Motions to dismiss are noted for consideration no earlier than 28 days after filing. | `caption_notes` carries the noting date given in the filing (NOVEMBER 6, 2026). The template does not check the date. |
| LCR 7(e)(4) | Motions to dismiss and the responses to them: 8,400 words or 24 pages; replies 4,200 words or 12 pages. | Not asserted by the template (length is the author's). The sample is shorter than the limit. |
| LCR 7(e)(6) | When word limits apply, the signature block certifies the word count of the memorandum. Captions, tables and certificates do not count. | `word-certificate()`: the form language, with the count from `word_count`. |
| Fed. R. Civ. P. 7(b) (not re-checked this pass) | A request for a court order must be made by motion, stated with particularity. | Author content. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, and Rule 7(a) designation. | `court-title()`, `caption()`. |
| Fed. R. Civ. P. 12(b)(6) | Motion to dismiss for failure to state a claim. | Author content (the sample's title and body). |
| Fed. R. Civ. P. 5 | Certificate of service on counsel of record. | `certificate_of_service` (printed on its own page after the signature, as in the filing). |

Not produced by this template: the proposed order (LCR 10(e)(7) "Presented by" language, if a proposed order is filed with the motion), declarations, and the word-count tool output.

## Layout

- Numbered lines 1 to 27 down the left margin on a 24 pt grid, with a double rule at the text's left edge and a single rule at its right.
- Page 1 (cover): judge's name at line 1, right (`judge`), lines 1 to 6 blank (three inches), court title on lines 7 to 9, caption from line 11 with the noting data and the title of the paper in its right column.
- The table of contents starts on a new page (`page_breaks`). Its rows are single-spaced (12 pt), half a numbered line apart; "I." labels at the margin and "A." labels at 0.5 in, each in a 0.5 in box with the title hanging after it, the page number at the right on the entry's last line.
- The introduction starts on a new page (`page_breaks`).
- Headings: level 1 centered bold caps; level 2 bold, left, with a hanging indent (argument headings); level 3 bold italic, left.
- Body paragraphs: double spaced, 0.5 in first-line indent, on the grid. A heading stays with the paragraph after it.
- The word-count certificate follows the conclusion; the signature block follows it; the certificate of service is on its own page last.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1), a `##` heading (level 2, argument headings), a `###` heading (level 3), a markdown table row set (`| entry | page |`, for the table of contents; the header row `| | Page |` prints "Page" at the right), a list, or a paragraph (unnumbered).
- Frontmatter fields: `case_number`, `judge`, `location`, `caption.parties`, `brief_title`, `caption_notes` (noting date, oral argument, dates of the action), `footer_title`, `footer_firm` (optional), `page_breaks` (headings that start a new page), `word_count`, `signature` (`date`, `firm` (optional), `signers`, `additional`, `role`), `certificate_of_service` (`date`, `signer`).
- Footnotes and tables of authorities are not supported in the sample (see gaps).

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/washington/federal/western-district/motion-brief hoffman-motion-to-dismiss` pairs each rendered page with the exemplar page sharing the most words.

Pairing and word overlap: our p1 to filed p1 (96%), p2 to p2 (98%), p3 to p10 (91%), p4 to p11 (46%), p5 to p13 (45%), p6 to p13 (45%), p7 to p14 (45%), p8 to p15 (53%), p9 to p16 (63%), p10 to p17 (48%), p11 to p30 (57%), p12 to p31 (97%). The body pages pair with the filed pages they transcribe (pages 10 to 17 and 30 to 31 of the filing), but the sample skips the filing's pages 18 to 29 and the table of authorities, so the body pages overlap only in part. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Tier 2 is not judged against two or three filers.** One motion to dismiss with a memorandum was found in the search (CourtListener RECAP, `type=r`, `court=wawd`, filed 2026-08-01 to 2026-10-13); its filer is the only exemplar. A second filer's motion would be needed for the tier-2 rule. Not searched further in this pass (the brief asks for one exemplar per doc type).
2. **Excerpt.** The sample transcribes the filing's cover, table of contents, introduction, relevant allegations, legal standards, Argument I and the start of II, the conclusion, the word-count certificate, the signature and the certificate of service. Argument II (its end), III and IV, and the table of authorities are not transcribed. Rendered length (12 pages) is within the 8 to 14 page target for a motion of this kind.
3. **Page numbering.** The filing numbers its front matter (table of contents and authorities) in roman numerals and starts the arabic count at the introduction. The template numbers every page in arabic from the cover. Matching the filing would need a page-numbering rule keyed to the section starts; not done.
4. **Footnotes** are not supported in the sample. The filing has footnotes (1, 2 and 4 in the argument), set at 10 pt by LCR 10(e)(1); the template has no footnote rule.
5. **Table of contents**: the filing uses dot leaders, which the template does not draw: the page numbers are typed in the INPUT, and a leader joins an entry's closing period to its dots, which DEF-CONT-001 reads as altered text (and the entry "... Rule 12(b)(6) ... | 12" is then not found at all). A tier-2 deviation, kept for the tier-1 content gate.
6. **Font.** LCR 10(e)(1) names no face; the filed motion embeds Times New Roman, which the template sets (typst and docx alike).
7. **Footer type size.** 10 pt (title) and 9 pt (firm block); see the complaint README, gap 2.
8. **No firm block in the footer** for this sample: the filing carries none. The template prints one when `footer_firm` is given.
9. **Output file names.** As in the complaint README, gap 9: `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt` are the tools' names, not the brief's `<id>.pdf` and `<id>-overlay.pdf`.
10. **Caption.** Party column closed by a rule (right and bottom), as in the complaint; accepted.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`;
docs/EVAL-LOOP.md, "Cross-engine gate"), and `eval.yaml` gates it (`params.cross_engine: gate`): the docx breaks every
line and page where typst does (XENG-001..003 pass, 406/406 lines).

- Pitches: body 24 pt (LCR 10(e)(1)); single-spaced lines (caption, contents, signature) exactly 12 pt, half a
  numbered line, and every single-spaced block starts 9.6 pt below the top of a numbered line, so each single line's
  baseline is a number's or halfway between two (and the line numbers are read with the same text lines in both
  engines).
- Caption and signature rows are rounded up to whole numbered lines; typst measures the row, `docx/motion-brief.lua`
  computes the same height from the lines with Times New Roman's advances (first fit, no kerning).
- Headings on the body pitch at the type size, kept with the text after them; the TOC and the introduction open a
  page (`page_breaks`); the word certificate is kept with the signature block, the co-counsel list with the signers;
  the certificate of service on its own page last.
- Bottom notation (LCR 10(e)(3)) fixed at its foot, 0.2 in above the page edge plus Word's 1 pt closing paragraph; no
  firm block (the sample gives none).
- Table of contents page numbers are typed from the sample. They do not match the footer count, which starts at the
  cover (page 1): the sample lists INTRODUCTION at page 1 and the rendered introduction is on page 3 (see the gaps,
  item 3).

**docx** (`docx/`; `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, the LibreOffice conversion): `docx/reference.xml`
(the recipe styles in the typst face via `{font}`, the header `rIdWawdLines` with the 27 numbers in a text box and the
three pleading rules as anchored lines) and `docx/motion-brief.lua` (cover, caption, contents, body, word certificate,
signature block, certificate of service, the bottom notation from the frontmatter in `$FORMBOOK_FOOTERS`, the section
in `$FORMBOOK_FINAL`). pandoc reads the sample as CommonMark (`pandoc-from="commonmark_x+smart"`), as cmarker does, so
a Westlaw star page such as "*2" stays literal. No shell. Only the LibreOffice PDF was checked; Word was not available.

Pages reviewed: typst and docx, 13 of 13 each, rendered at 60 dpi side by side and viewed in their final state.
