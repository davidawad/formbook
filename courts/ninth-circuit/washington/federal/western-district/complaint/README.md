# wawd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Washington (`wawd`).
Folder: `courts/ninth-circuit/washington/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-ironleaf-2-26-cv-03537-complaint.pdf` (primary) and `exemplars/FILED-EXAMPLE-materia-2-26-cv-03656-complaint.pdf` (second filer, structure only). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-ironleaf-complaint.md`: the whole filed complaint (11 pages as filed; 10 rendered), transcribed from the text layer. |
| render | ok: `samples/OUTPUT-ironleaf-complaint.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no typst warnings. |
| overlay | ok: `samples/OVERLAY-ironleaf-complaint.pdf` and `samples/OVERLAY-ironleaf-complaint.txt`. |
| pages reviewed | 10 of 10: every page rendered at 60 dpi and viewed in its final state (footer crop also checked at 150 dpi). |

## Governing rules

Primary source: W.D. Wash. Local Civil Rules (2026 edition, "WAWD Local Civil Rules (2026) - Clean", posted by the court; downloaded 2026-10-14 from https://www.wawd.uscourts.gov/sites/wawd/files/WAWD%20Local%20Civil%20Rules%20%282026%29%20-%20Clean.pdf, which is the rules index page's current copy). The court's proposed 2026 amendments (https://www.wawd.uscourts.gov/sites/wawd/files/2026%20LCR%20Proposed%20Amendments%209-22-2026.pdf, dated 2026-09-22) amend LCR 100 only; they do not change LCR 10. Rule text was checked against the PDF text layer, not paraphrase.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCR 10(d) | 8 1/2 x 11 inch page. | `page-w`, `page-h`. |
| LCR 10(e)(1) | No less than three inches above the court title on the first page; one-inch margins; 12 pt or larger; double spaced or exactly 24 pt; proportionally spaced font. | `first-page-blank = 6` (lines 1 to 6 blank, court title on line 7 at 3 in); `top-margin`, `right-margin`; `type-size = 12pt`; `pitch = 24pt`; `font-family = "EB Garamond"`. Footnotes are not used in the sample (see gaps). |
| LCR 10(e)(2) | Words "United States District Court, Western District of Washington" on the first page, and below the docket number a title of the paper and the party presenting it. | `court-title()` (three lines: UNITED STATES DISTRICT COURT / WESTERN DISTRICT OF WASHINGTON / location from frontmatter, default "AT SEATTLE" as in the filings); `caption()` with `Case No.` and `brief_title`. |
| LCR 10(e)(3) | Bottom notation: left, the abbreviated title and case number with the page number; right, the firm, mailing address and telephone of the preparing attorney. | `footer-block()`: title and `(Case No. ...) - page` at left; `footer_firm` lines at right. |
| LCR 10(e)(4) | Dated and signed as under Fed. R. Civ. P. 11 and LCR 11. | `signature-block()`: `signature.date`, "Respectfully submitted," and `signature.signers` with "By:" on the first line. The signature itself is the signer's `s/` line from the sample. |
| LCR 10(e)(5) | Line numbers in the left margin, at least half an inch to their left. | `line-numbers()` (27 numbers on the 24 pt grid) and `left-margin - 0.5in` for the numbers. |
| LCR 10(e)(6) | Citations to the record cite docket and page numbers. | Author content; the template does not check it. |
| Fed. R. Civ. P. 10(a) | Caption with the court name, the title, the file number, and the Rule 7(a) designation. | `court-title()`, `caption()`; the parties block lists all parties named in the complaint's title (from `caption.parties`). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered 1, 2, ...; headings, lists and the jury demand are not numbered (the prayer and the jury demand are marked by heading text in `allegations()`). |
| Fed. R. Civ. P. 38 | Jury demand: "Jury Trial Demanded" in the caption and the demand paragraph at the end. | `caption_notes` ("JURY TRIAL DEMANDED"); the sample ends with a "DEMAND FOR JURY TRIAL" section. |

Not produced by this template (separate filings): the civil cover sheet (JS-44), the corporate disclosure statement (Fed. R. Civ. P. 7.1), the summons, and any judge-specific chambers copies (LCR 10(e)(9) and the assigned judge's procedures).

## Layout

- Numbered lines 1 to 27 down the left margin on a 24 pt grid, with a double rule at the text's left edge and a single rule at its right.
- Page 1: lines 1 to 6 blank (three inches), court title on lines 7 to 9, caption from line 11, then the body follows on the same page (as in the filings).
- Every block of text is rounded to whole 24 pt rows (`on-grid`), so headings, paragraphs and the signature block land on the numbered lines.
- A heading stays with the paragraph after it.
- Bottom notation in the bottom margin, on all pages.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered bold caps), a `##` heading (level 2, centered roman, used for cause-of-action sub-captions), a `###` heading (bold, left), a list (`1.` items, printed as 1., 2., ... for prayers), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `caption_notes` (optional extra caption lines, bold), `location` (the third line of the court title, e.g. "AT SEATTLE"), `footer_title`, `footer_firm` (lines at the bottom right), `signature` (`date`, `firm`, `signers`, `additional`, `role`), `judge` (optional; printed on line 1 at right, as in the filings).
- Not supported: tables, footnotes, raw typst. Paragraph numbers are not transcribed: the template numbers the allegations itself.

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/washington/federal/western-district/complaint ironleaf-complaint` pairs each rendered page with the exemplar page sharing the most words (`exemplars/*.pdf`, first in name order, i.e. the Ironleaf filing). The overlay is a diagnostic, not a score.

Word overlap per page (rendered page vs filed page): p1 77%, p2 86%, p3 77%, p4 69%, p5 63%, p6 58%, p7 82%, p8 67%, p9 51%, p10 43% (p10 pairs with filed p9, the best word match: the prayer, jury demand and signature sit on pages 9 and 10 of both). Pages 9 and 10 overlap least because the sample reflows the prayer and signature; the content matches.

## Known gaps and open choices

1. **Font.** LCR 10(e)(1) requires a proportional font but names none. The only font vendored in `fonts/` is EB Garamond. Its x-height is smaller than Times New Roman's, so the text looks smaller than the filed exemplar at the same 12 pt. Adding a Times-metric font would remove the difference; that is a change to `fonts/`, which this brief does not allow. Open question for David.
2. **Footer type size.** The bottom notation is 10 pt (title) and 9 pt (firm block). LCR 10(e)(1)'s 12-point rule is written for "text", and LCR 10(e)(3) puts the notation in the margin. Logged as an interpretation; the filings use a similar size.
3. **Character spacing.** No cpi rule for proportional text is in LCR 10(e); none is asserted.
4. **Long URLs break mid-word** at the line end (e.g. "www.ironleafcap / ital.com", page 3). The sample transcribes the filing's text; typst breaks long unbroken words. Not fixed; harmless to the form.
5. **Line numbers** are 27 on the 24 pt pitch, as in the exemplar; the text of a full page fills all 27 lines.
6. **Caption.** The party column is closed by a rule (right and bottom) rather than a column of ")" marks. Both appear in W.D. Wash. filings; recorded as an accepted tier-2 convention.
7. **Second filer, tier 2.** Two filers are saved (Ironleaf and Materia). The Materia filing has the same caption structure (case number at right of the caption) and the same bottom notation (firm block at right). It was checked by its text layer only; its body is not transcribed.
8. **Case names** are not italic in the sample: the text layer of the exemplar has no italic markup, so the transcription is roman. The template italicizes `*...*` markdown.
9. **Output file names.** `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `.txt` (the repo's naming rule; the overlay tool reads `OUTPUT-<id>.pdf` by name). The brief's `<id>.pdf` and `<id>-overlay.pdf` names do not match the tools, so the tools' names are used.
10. **Judge line.** The Ironleaf complaint has no judge assigned; the template prints the judge's name on line 1 only when the frontmatter gives one.
