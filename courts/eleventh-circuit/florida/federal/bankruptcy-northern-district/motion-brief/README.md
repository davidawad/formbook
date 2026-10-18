# Motion with incorporated memorandum of law, U.S. Bankruptcy Court, N.D. Florida (flnb)

Template for a motion in an adversary proceeding with its memorandum of law in the same document. Engine: typst (`typst/`). Court folder for the tools: this directory.

## Rules applied (primary sources)

Verified 2026-10-14 against the Local Rules of the U.S. Bankruptcy Court, N.D. Fla. (effective Feb. 26, 2024; `https://www.flnb.uscourts.gov/sites/flnb/files/local_rules_02-26-2024.pdf`) and the Local Rules of the U.S. District Court, N.D. Fla. (PDF `https://www.flnd.uscourts.gov/sites/flnd/files/local_rules/local_rules_0.pdf`, stated effective Nov. 24, 2015).

| Requirement | Source | Template |
|---|---|---|
| District Local Rules apply in all bankruptcy cases, adversary proceedings included | Bankr. N.D. Fla. LBR 1001-1(B)-(C) | Pulls the district format and length rules in |
| Caption; title states the party's designation, the paper's contents, and "MEMORANDUM" if the paper contains one | LBR 9004-1(A) | Title from frontmatter; the memorandum is named in the title |
| One claim per motion; conferral statement; "Agreed"/"Consent" in the title if consented | LBR 9013-1(A)(1)-(2) | One claim (dismissal as to GCS); conferral certificate under its own heading |
| Memorandum of law or citation of authority served and filed with every motion in an adversary proceeding | LBR 9013-1(B); LBR 7007-1 | "MEMORANDUM OF LAW" section in the same document |
| Length limits of the District Local Rules | LBR 9013-1(D) | District LR 7.1(F) below |
| 14-point font or larger; double spaced; one-inch margins; pages numbered; case style, then heading | District LR 5.1(B)-(C) | 14 pt; double-spaced; 1 in margins; centred page number |
| Typeface: none named (LR 5.1 sets the size only) | `docs/FONTS.md`: no face named → EB Garamond | Typeface row: face required = none; font = **EB Garamond** (no substitution, so no metric claim) |
| Attorney signature block: signature, typed name, bar number, street and email addresses, telephone; identify the party | District LR 5.1(D) | Signature block from frontmatter, after the WHEREFORE paragraph |
| Certificate of service with date and method | District LR 5.1(F) | Certificate in the body, after the word-count certificate |
| Conferral certificate under a separate heading | District LR 7.1(C) | Certificate under its own heading before WHEREFORE |
| Memorandum limit 8,000 words; certificate stating the word count (case style, signature block, certificate of service excluded; motion words count only if the motion exceeds 500) | District LR 7.1(F) | The template counts the memorandum words from the body and writes the count into the certificate (`{{MEMO_WORDS}}`); it stops rendering if the count exceeds 8,000 |

Footnotes are placed as typst footnotes in the paragraph that cites them (cmarker 0.1.10 does not render markdown footnotes, so the template does it).

No case-specific text, coordinates or forced line breaks are in the template: the caption, title, signature lines and all text come from the sample.

## What the overlay shows

Sample: `usage/INPUT-motion-brief.md` (transcription of the filed motion, 4 pages, Doc 40 of Adv. Pro. No. 16-04003-KKS). Render: `usage/OUTPUT-motion-brief.typst.pdf` (5 pages). Overlay: `usage/OVERLAY-rooks.pdf` (red = our render, blue = filed exemplar, black = both) with page map `usage/OVERLAY-rooks.txt`.

- Layout matches the filing's order: caption, title, numbered paragraphs, memorandum, conferral certificate, WHEREFORE, signature, certificate of service, footnote 1 at the foot of its page.
- Pagination: the render is 5 pages against 4 in the filing (the 14-point face and the added word-count certificate). Overlay word overlap per page: p1 76%, p2 46%, p3 48%, p4 54%, p5 85% (pairing by shared words; the drift reflects the extra page, not a rule failure).
- Fonts: the filing is Times New Roman; the rule names no face, so EB Garamond is used (see gaps). `pdffonts` on the render: EB Garamond Regular, Bold and Italic, embedded.

## Gaps

- **Font face (accepted, tier 2).** The local rule requires 14-point, not a face, so `docs/FONTS.md` keeps EB Garamond. The filed exemplar is Times New Roman; the vendored Times substitute is Liberation Serif (metric-compatible). Switching is a choice of the clerk-convention reading, not a rule requirement, so it is not made here.
- **Added certificate of word count.** LBR/LR 7.1(F) requires it; the 2016 filing has none. The template adds it (with the computed count).
- **Title.** The filing's title has no "memorandum" words; the template adds "AND INCORPORATED MEMORANDUM OF LAW" as LBR 9004-1(A) requires for a paper containing a memorandum.
- **Conferral heading** is transcribed as filed ("PER LOC. R. 7007-1"). Current practice cites LBR 9013-1(A)(2); the filed citation is kept because it is the exemplar's text.
- **Filing typo kept.** The filed caption reads "Case No.. 16-40025-KKS" (two periods); the transcription uses one.
- **Page length.** This exemplar is 4 pages, below the 8-14 page target in the brief, because it is the only flnb motion-with-memorandum with a stored PDF that was located. The template has no page-length check; LR 7.1(F) is the word limit.
- **Second filer not located.** No second flnb motion-brief PDF with an incorporated memorandum was found with a stored PDF.
- **Pages reviewed.** All five rendered pages were viewed as PNG (montages at 70 dpi: pages 1-3, then 4-5).

[Court index](../README.md)

## Engines

Word (`docx/`) is built next to the typst template: `docx/reference.docx` (made by `docx/make-reference.sh`), `docx/flnb-motion-brief.lua` (caption, title, signature block after the WHEREFORE paragraph, the word count in the certificate), `docx/render.sh` (pandoc with the reference and the filter; native footnotes). Build: `sh tools/render.sh --engine docx motion-brief usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and `OUTPUT-flnb-motion-brief-rooks.docx.pdf` (LibreOffice 26.8). Checked on the LibreOffice PDF; Word was not available.

- **Matches typst:** EB Garamond 14 pt; 32.2 pt line pitch for body text; single 15.4 pt lines in the caption and signature block; 1-inch margins; centred page number; caption, title, numbered paragraphs, footnote 1 at the foot of its page, signature block after WHEREFORE, certificates in the same order; signature block at 45% of the text width.
- **Differs from typst (docx follows the template's intent; typst/ is not changed here):**
  - Headings: the template centres and bolds levels 2 and 3; the typst render sets them flush left. The docx centres them.
  - First-line indent: typst does not indent the first paragraph after a heading; the docx indents every body paragraph.
  - Footnote text: the docx uses 14 pt (the typst render's footnote text measures about 12 pt). Whether LR 5.1 reaches footnotes is not checked here; the docx follows the 14-point reading.
  - Word count: the certificate says 134 words in the docx and 135 in the typst render. The docx count is what the word processor counts for the source text: pandoc reads the sample's `complaint "in` quote as one word (`complaint”in`), which typst reads as two.
  - Pagination: the docx runs 5 pages, as the typst render does; the page breaks differ (see the overlay for typst).
  - Signature block: typst keeps the spaces in `By:    /s/` where the sample has them; pandoc collapses them.
  - Smart quote: pandoc sets the closing quote in `complaint”in` (the sample's own quote pairing); typst sets it differently. Not patched in the filter (it would be case-specific text).
- **docx BLOCKED items:** none. No TOC or TOA is in this template. Word itself was not run; the `.docx` is a valid zip of well-formed XML and LibreOffice converts it without a repair prompt.
- **Pages reviewed (docx.pdf, 5 pages):** every page rendered at 60 dpi and viewed beside the typst page (pages 1 to 5).
