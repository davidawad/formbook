# nhb: motion-brief

Doc type: **motion with supporting memorandum** (the memorandum of law) in the United States Bankruptcy Court for the District of New Hampshire (`nhb`), filed in a bankruptcy case as a contested matter (not an adversary proceeding).
Folder: `courts/first-circuit/new-hampshire/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nhb-motion-brief-oldcold1511400.pdf` (one filer, see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nhb-motion-brief-oldcold.md`: the full memorandum (introduction, factual background, argument with sub-sections A and B and their sub-headings i to iv, conclusion), eight footnotes, the signature block and the certificate of service text; the service list is not transcribed (gap 5) |
| typeface | face required: none (no NH local rule names a typeface; see gap 1). Font used: EB Garamond (vendored, the court-names-no-face default in `docs/FONTS.md`). Not a substitution: nothing to match. |
| render | ok: `usage/OUTPUT-nhb-motion-brief-oldcold.typst.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EB Garamond Regular, Bold and BoldItalic embedded), no warnings (`tools/render.sh`, re-run 2026-10-14) |
| overlay | ok: `usage/OVERLAY-old-cold-motion-brief.pdf` and `usage/OVERLAY-old-cold-motion-brief.txt` (re-run 2026-10-14). The filed PDF is not in this checkout (`usage/` holds only `SOURCE.md`); the overlay was run against the copy fetched from the URL in `usage/SOURCE.md` (15 pages, matching the record) |
| pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed on the 2026-10-14 re-render; no template change, so the review matches the earlier one) |

File names follow the tools' contract (`render.sh` writes `OUTPUT-<id>.pdf`, `overlay.sh` reads it and writes `OVERLAY-<id>.pdf`/`.txt`), not the bare `<id>.md` / `<id>.pdf` names in the task brief.

## Governing rules

Primary sources, fetched 2026-10-14. Federal rules from the Legal Information Institute text of the restyled Bankruptcy Rules (amended Apr. 2, 2024, eff. Dec. 1, 2024): https://www.law.cornell.edu/rules/frbp/. District rules from the court's combined local rules (file dated 2025-04-01): https://www.nhb.uscourts.gov/sites/nhb/files/PDFs/2025-04-01-local-rules-final.pdf.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013(a), (b) | A request for an order is made by written motion; a motion states its grounds with particularity and the relief requested. | Content (author text). The template does not check the grounds. |
| Fed. R. Bankr. P. 9004(a) | Legibility. | Layout: 12 pt body, single-spaced footnotes, no forced breaks. |
| Fed. R. Bankr. P. 9004(b) | Caption shows the court name, case title, case number, and a brief designation of the document. | `court`, `bankruptcy`, `title` frontmatter. |
| D.N.H. LBR 7101(a) | Motion procedure: all requests for an order other than adversary proceedings. | Scope of the doc type (contested matter). |
| D.N.H. LBR 7101(c) | With the motion: notice of hearing, certificate of service and proposed order. | Not produced (separate documents; gap 2, gap 3). |
| D.N.H. LBR 7102(a)(1) | Motions are filed separately from other pleadings; the caption shows the character of the paper; the caption or first sentence identifies the party and its relationship to the estate. | `title` (the designation) and the first sentence of the body (the introduction names the movant, Mission Product Holdings, Inc.; its relationship to the estate is not stated, see gap 9). |
| D.N.H. LBR 7102(a)(2) | Chapter of the case after the case number. | `bankruptcy.chapter`, printed beside "Case No.". |
| D.N.H. LBR 7102(a)(3) | Judge's initials after a hyphen immediately following the case number. | `case_number` (`15-11400-CJP`). The filed copy writes "Bk. No. 15-11400 (CJP)"; the template follows the rule's hyphen form (gap 8). |
| D.N.H. LBR 7102(a)(4), LBR 9004-1(c) | BNH identification number after counsel's signature. | `signature.lines` (`BNH 07506`). |
| D.N.H. LBR 7102(b)(2) | Memorandum in support of a nondispositive motion: no more than 15 pages; of a dispositive motion: no more than 25 pages, except by prior leave. | Not enforced by the template. The sample renders at 14 pages (gap 4). |
| D.N.H. LBR 7102(b)(3) | Proposed order, entitled "Order", with a line for the judge's signature and the date. | Not produced (separate document; gap 2). |
| D.N.H. LBR 7103 (certificate of service; cross-referenced from LBR 9004-1) | Certificate identifies the document served, the manner, the date, the persons served by mail, and the CM/ECF statement. | `certificate` frontmatter: the certificate's two paragraphs and signature block; the service list is omitted (gap 5). |
| D.N.H. LBR 9004-2(a) | Caption includes a brief designation and identifies the party and its relationship to the estate. | `title` plus the introduction sentence. |

## Layout (decisions that the rules leave open)

- Letter paper, one-inch margins, page numbers centered at the foot. No NH or federal rule gives a margin or format for memoranda, so these follow common practice and the exemplar.
- Body: EB Garamond 12 pt (vendored, the only font in `fonts/`), double-spaced at 27.6 pt line pitch (Word's double spacing for 12 pt Times). Footnotes are 10 pt, single-spaced, with a short rule above them; no rule sets footnote size, so this is a layout choice.
- Caption: court name centered bold caps, then the bankruptcy caption (debtor, chapter, case number with judge's initials), then the title centered bold caps. No adversary block: this is a contested matter.
- Paragraphs are not numbered (memoranda are not numbered pleadings), first line indented 0.5 in.
- `#` headings are centered bold caps (FACTUAL BACKGROUND, ARGUMENT, CONCLUSION); `##` headings are bold, left, with a hanging indent (lettered sub-sections A, B); `###` headings are bold italic, left (roman-numeral sub-sections i to iv).
- Block quotations (`> `) are single-spaced, indented 0.5 in on both sides, with 12 pt after.
- Footnotes: the sample marks them as markdown `[^n]` references with `[^n]: ...` definitions. cmarker does not render markdown footnotes, so the template splits each paragraph at the markers and inserts typst footnotes with the definition text.
- Signature block: "Dated:" on the left, the firm and signer on the right half, counsel lines and BNH number below. The last body paragraph is unbreakable and sticky, so it stays with the signature block.
- Certificate of service: after the signature, on the same document. Its own date and signature block.
- No forced line breaks, no case-specific text, no coordinates in the template. Every case word comes from the sample frontmatter.

## What the overlay shows

`usage/OVERLAY-old-cold-motion-brief.pdf`: red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by word overlap; the page map is in `OVERLAY-old-cold-motion-brief.txt`:

```
ours p.1  filed p.1  word-overlap 80.4%   ours p.8  filed p.8  word-overlap 78.2%
ours p.2  filed p.2  word-overlap 75.4%   ours p.9  filed p.9  word-overlap 61.2%
ours p.3  filed p.3  word-overlap 69.9%   ours p.10 filed p.10 word-overlap 46.4%
ours p.4  filed p.4  word-overlap 81.3%   ours p.11 filed p.11 word-overlap 47.3%
ours p.5  filed p.5  word-overlap 90.1%   ours p.12 filed p.13 word-overlap 58.3%
ours p.6  filed p.6  word-overlap 84.2%   ours p.13 filed p.14 word-overlap 50.0%
ours p.7  filed p.7  word-overlap 76.1%   ours p.14 filed p.14 word-overlap 46.3%
```

The overlay is a diagnostic, not a score. The lower overlaps on pages 10 to 14 are the expected ones: the exemplar is set in Times New Roman with different line breaks, and page 14 of the sample is the certificate, whose service list (on the exemplar's page 15) is not transcribed. The overlay was produced on the final render.

## Known gaps and open choices

1. **Typeface.** Checked 2026-10-14 against the text of the court's combined local rules (file dated 2025-04-01): no rule names a typeface, a font size or a line spacing for filed papers. The only font wording is LBR 1007-2(b)(2), "Use legible font", which covers creditor matrices. The court names no face, so the template keeps EB Garamond 12 pt, the `docs/FONTS.md` default. The exemplar is Times New Roman, but that is the filer's choice, not a rule. A Times-metric substitute (Liberation Serif) would be a style choice, not a rule requirement.
2. **Proposed order and notice of hearing.** LBR 7101(c) and LBR 7102(b)(3) require a proposed order (entitled "Order", LBF 9072-1 form) and a notice of hearing with the motion. Neither is produced by this template; both are separate documents.
3. **Motion and memorandum are separate filings.** LBR 7102(a)(1) requires motions to be filed separately from other pleadings. This template produces the memorandum; a standalone motion would reuse the same template with a shorter body. The exemplar is a standalone memorandum.
4. **Page limit not enforced.** LBR 7102(b)(2) caps memoranda at 15 pages (nondispositive) or 25 pages (dispositive). The template does not count pages. The sample renders at 14 pages, within the 15-page limit for a nondispositive motion. The exemplar is 15 pages.
5. **Service list omitted.** The certificate of service's second paragraph is followed in the filing by a table of about 20 names and addresses (served by mail). The sample ends the certificate's text at the colon; the table is not transcribed. Markdown tables are not supported by the sample contract, so this is a structural gap.
6. **Italics.** The exemplar's text layer has no italic markup; case names in the sample are roman.
7. **Footnote typography.** Footnotes are 10 pt, single-spaced, with a 1.5 in rule above. No rule sets the size; the exemplar footnote size was not measured.
8. **Judge's initials.** The sample writes `15-11400-CJP` following LBR 7102(a)(3), not the filed copy's "Bk. No. 15-11400 (CJP)". This is a rule-driven choice; the filing (2021) predates the 2025 local-rules text used here.
9. **Relationship to the estate.** LBR 7102(a)(1) asks that the caption or the first sentence identify the party and its relationship to the estate. The introduction names the movant but does not state its relationship to the estate, as in the filed copy; the template does not check this. A filing that needs it would add it to the first sentence.

## Review of the rendered pages (final render)

- Page 1: court title, bankruptcy caption (debtor, chapter, case number with judge's initials), title, introduction paragraph (identifies the movant), FACTUAL BACKGROUND, footnote 1. Pass.
- Page 2: paragraphs on the DIP facility and the Carve Out Reserve Account (with the "Carve Out Reserve Account" marker and footnote 2). Pass.
- Page 3: paragraphs; ARGUMENT; sub-section A heading (bold, hanging). Pass.
- Page 4: paragraphs on the Final DIP order and the sale; no headings. Pass.
- Page 5: end of sub-section A; sub-section B heading; sub-heading i in bold italic; footnote 3. Pass.
- Page 6: the citation paragraph (joined across the page break from page 5) and paragraph on the disgorgement remedy; footnote 4. Pass.
- Page 7: paragraphs; sub-heading ii (two-line bold italic heading). Pass.
- Page 8: paragraphs on section 330(a)(5); block quotation (merged from its line-by-line transcription); footnotes 5 and 6. Pass.
- Page 9: block quotation continues; paragraphs on sections 329(b) and 330(a)(5). Pass.
- Page 10: paragraphs; sub-heading iii (two-line heading). Pass.
- Page 11: paragraphs; sub-heading iv. Pass.
- Page 12: paragraphs; block quotation on the SPM decision with footnote 7 (MCO Wash) and the footnote 8 reference. Pass.
- Page 13: final paragraph ("Accordingly"), CONCLUSION, date, signature block with BNH number, CERTIFICATE OF SERVICE heading and its first paragraph; footnote 8. Pass.
- Page 14: certificate second paragraph, date, certificate signature block. Pass.

No findings were recorded in `reviews/` (this doc type has no `reviews/` folder). The Gate 2 record for this doc type is this section.

[Formbook index](../../../../../../README.md) | [Bankruptcy court README](../README.md)

## Engines

docx (`docx/`: `build-reference.sh`, `reference.docx`, `nhb.lua`; output `usage/OUTPUT-nhb-motion-brief-oldcold.docx` and `.docx.pdf`, LibreOffice PDF, 15 pages, EB Garamond only):

- Matches the typst form: EB Garamond 12 pt; body at an exact 27.6 pt line pitch; 0.5 in first-line indent with no space between paragraphs (as the typst renders); single-spaced block quotes at 13.8 pt; footnotes 10 pt at an 11.5 pt pitch; `###` headings bold italic, `##` headings bold with a hanging indent; the caption, title, conclusion and certificate of service; the signature blocks kept with the text before them; the memorandum unnumbered (as the typst); PAGE number centered in the footer.
- Differs: LibreOffice line breaks drift by a few lines per page against the typst PDF (footnote and block-quote lines are the largest source), so the CONCLUSION block (kept with its signature) moves to page 14 and the certificate of service moves whole to page 15 (the typst has 14 pages with the certificate split between pages 13 and 14). The certificate is kept as one unit rather than split.
- BLOCKED: page count (typst 14, docx 15): the LibreOffice pagination above; no Word limit is involved, and the template has no forced break. Not fixed.
- Opened with LibreOffice only (the PDF conversion is the no-repair proof); Word was not checked.
