# D.R.I. Bankruptcy Court (rib): motion brief (motion with memorandum)

Doc type: **motion with memorandum**, one filed document: the motion (FRBP 9013), then the memorandum of points and authorities (LBR 9013-1(a)), then the certificate of service. Court: United States Bankruptcy Court, District of Rhode Island. Folder: `courts/first-circuit/rhode-island/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/SAMPLE-rib-motion-brief-hidalgoastrue12ap01039.pdf` (complete: motion, memorandum, certificate; U.S. Attorney for the Commissioner of Social Security; 9 pages) and `usage/SAMPLE-rib-motion-brief-donovanchristiana17ap01028.pdf` (memorandum only, creditor's counsel; 13 pages; the motion itself was not retrievable). Provenance in `usage/SOURCE.md`. |
| sample md | `usage/INPUT-rib-motion-brief-hidalgoastrue.md`: full transcription of the Hidalgo filing (motion, memorandum with its two footnotes, conclusion, signature, "Of Counsel", certificate). Case-name italics are added; the text layer does not carry the typeface. Quotation marks are restored where the text layer garbled them. Spelling "Judgement" is kept as filed. |
| render | ok: `usage/OUTPUT-rib-motion-brief-hidalgoastrue.typst.pdf`, 9 pages. typst 0.15.0, vendored EB Garamond only (`pdffonts`), no warnings. |
| overlay | ok: `usage/OVERLAY-hidalgo-astrue.pdf` and `.txt`. The Donovan memorandum is not overlaid (it is a memorandum alone, not a complete motion-brief). |
| pages reviewed | 9 of 9, each rendered at 60 dpi and viewed after the last template change |

File names: the brief asked for `usage/<id>.md`, `<id>.pdf` and `<id>-overlay.*`. The repo's file-role convention and the tools fix the names instead: `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`. `tools/overlay.sh` reads `OUTPUT-<id>.pdf`, so the tool's names were kept.

## Governing rules

Primary sources. Local rules: the District of Rhode Island Bankruptcy Court's Local Bankruptcy Rules, December 1, 2024 compilation, https://www.rib.uscourts.gov/sites/default/files/general-ordes/December_1_2024_LBRs.PDF (fetched and text-extracted 2026-10-14). The rule text of LBR 9013-1 was also read on the court's rule page, https://www.rib.uscourts.gov/newhome/rulesinfo/html5/Content/Local%20Rules/9000/9013-1.htm (marked "[Amended 9/9/13]", same text). National rules: FRBP 9013, paraphrased from https://www.law.cornell.edu/rules/frbp/rule_9013 and the 2021 GPO text (not quoted verbatim; the 2024 restyling could not be read in full).

| Rule | Requirement | Where in the template |
|---|---|---|
| FRBP 9013 | A request for a court order is made by written motion, stating the grounds with particularity and the relief sought. Paraphrased; verify wording. | Structure: a motion section, then the memorandum. |
| LBR 9013-1(a) [Amended 9/9/13] | Points and authorities with or within the paper; specific reference to the Code, the FRBP, R.I. General Laws or other controlling authority. Excepted motions in 9013-1(d). | The memorandum is part of the same document. Authorities are the author's; the template does not check them. |
| LBR 9013-1(b) [Amended 9/9/13] | Initial motions, responses, briefs and memoranda limited to 20 pages (reply 10), absent leave. Full caption with bankruptcy case number, adversary number and chapter. Double spaced, 8 1/2 x 11, body at least 11 point, footnotes at least 10 point, no body text in footnotes. | `type-size = 12pt`, `footnote-size = 10pt`, `body-leading = 1.35em` (24 pt pitch, measured). The memorandum runs pages 3 to 8 (about six pages), well under 20. |
| LBR 1005-1(a) [Amended 12/1/22] | Case name, number and chapter on every paper and on the signature page. | Caption grid, and the "In re ..." line on each signature block. |
| LBR 1005-1(b) | As LBR 9013-1(b): 8 1/2 x 11, 11 point, double spaced, footnotes 10 point, quotations single spaced. | As above; block quotations are single spaced. |
| LBR 1005-1(c) | Signer's name, original signature, address, telephone, e-mail, firm, state bar identification number, client. | `signature` frontmatter; `bar_id` is required and printed as "RI Bar No.". |
| LBR 1005-1(d)(1) [Amended 12/1/22] | Response-time language on every motion, in single or double space, at least 11 point: "Within fourteen (14) days after service ..." (verbatim). Not required for the excepted motions in 1005-1(d)(2) and the motions in 9013-1(d). | `response-default` in the template, printed automatically with the motion. Set `response: none` in the frontmatter for an excepted motion, or `response_text` for a different period. |
| LBR 7007-1 | Papers in adversary proceedings comply with LBR 1005-1. | As LBR 1005-1 above. |
| LBR 9013-2 | Motion practice (action without hearing, emergency motions). | Not generated. |
| Certificate of service | Filed motions carry a certificate of service. Rule cite not verified this session. | `certificate` frontmatter (date, recipients). Its text follows the Hidalgo filing's CM/ECF certificate. |

Searches and what they settled: CourtListener RECAP search (`court=rib`, `type=r`, adversary dockets, queries "motion to dismiss" "memorandum" and "memorandum of law in support"). Two text-based filings from different filers, with a memorandum, were kept (table in `usage/SOURCE.md`). The Hidalgo filing is the only complete motion-with-memorandum in one document that was found; Donovan is a memorandum alone. The Donovan motion (entry 7.0) did not download (the storage path returned an error page).

## Layout

- Court title and caption (the same grid as the complaint), then the motion title (centered bold capitals).
- The motion: its paragraphs (unnumbered, first line indented, double spaced).
- The response-time language (LBR 1005-1(d)(1)), single spaced, then the signature block. The language and the signature are kept as one unbreakable block, so a signature never stands alone on a page.
- A line of `---` in the sample starts the memorandum on a new page. The caption is repeated (as the Hidalgo filing does) with the memorandum title.
- Headings: `#` centered bold capitals; `##` centered bold; `###` bold italic left. Sticky, so a heading stays with the next chunk and never ends a page.
- Paragraphs unnumbered (neither the motion nor the memorandum is numbered by the rules). Lists are numbered 1., 2., ...; quotations single spaced; footnotes 10 point, single spaced, placed at the foot of the page that refers to them.
- The memorandum's signature block (with "Of Counsel" lines, kept together with it).
- Certificate of service on a new page: the date and the recipients from frontmatter; `/s/` signer.
- Page numbers at foot, centered, 11 point. Margins 1 inch.

## Markdown contract (for samples)

- YAML frontmatter: `in_re`, `debtor_designation`, `chapter`, `case_number`, `adversary_number`, `caption.parties`, `title` (the motion), `memorandum_title`, `signature` (`client`, `by`, `signer`, `bar_id`, `firm`, `lines`), `of_counsel` (optional list), `certificate` (optional: `date`, `recipients`), `response` (default: the 14-day language; `none` to omit), `response_text` (optional override), `date` (optional).
- Body: motion paragraphs; a line of `---`; memorandum chunks. Headings `#`, `##`, `###`; lists `1.`; quotations `>`; footnotes `text[^key]` with `[^key]: text` anywhere in the memorandum part (the template renders each definition with the paragraph that refers to it).
- Escape a literal asterisk that is not emphasis (as in Westlaw pin cites, `at \*4-5`).

## Overlay: what it shows

`usage/OVERLAY-hidalgo-astrue.pdf`: red = our render, blue = the Hidalgo exemplar, black = both. The page map (`OVERLAY-hidalgo-astrue.txt`) pairs each of our pages with the exemplar page sharing the most words:

| Ours | Filed | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 70.2% | Motion. |
| 2 | 1 | 26.5% | The response language and signature. The exemplar has no response language and fits its signature on page 1, so the page is unmatched by design. |
| 3 | 2 | 76.1% | Memorandum start, caption repeated. |
| 4 | 3 | 66.4% | |
| 5 | 4 | 55.8% | |
| 6 | 5 | 49.7% | |
| 7 | 7 | 67.2% | |
| 8 | 8 | 74.6% | Conclusion, signature, "Of Counsel". |
| 9 | 9 | 76.5% | Certificate of service. |

The overlay is a diagnostic, not a score. The exemplar is in Times with pitch and page breaks of its own, so text lines will not coincide.

## Known gaps and open choices

1. **Response-time language is not in the exemplar.** The Hidalgo filing (2012) carries no LBR 1005-1(d)(1) paragraph; the template adds the verbatim 14-day language because the current rule requires it on every motion. The overlay shows it on page 2. A motion that is excepted (LBR 1005-1(d)(2), 9013-1(d)) must set `response: none` or a different `response_text`.
2. **Bar numbers.** Neither exemplar shows a bar number. `bar_id: "(not shown in exemplar)"` is printed on both signature blocks. A real filing must replace it.
3. **Memorandum of the Donovan exemplar.** Used for comparison of the memorandum's caption and structure only. The motion itself was not retrievable.
4. **Certificate of service.** The text is the Hidalgo filing's CM/ECF certificate. The rule requiring it was not verified this session. The template prints the certificate only when the sample has `certificate:`.
5. **No table of contents or authorities.** LBR 9013-1 does not require them under the 20-page limit; neither exemplar has one. A memorandum over the limit would need leave under 9013-1(b) (the template does not generate contents).
6. **Motion versus memorandum in one document.** The template prints the motion and the memorandum as parts of one filing, as the Hidalgo filing does. Some filers file them separately (the Donovan filing is a separate memorandum); the template does not split them.
7. **Spelling kept as filed.** "Judgement" appears in the title of both the motion and the memorandum, as in the exemplar. A filing should use the correct spelling.
8. **Rule texts not verified verbatim:** FRBP 9013 (paraphrase), the certificate-of-service rule, and LBR 9013-2 (not used).
9. **Font.** EB Garamond at 12 point (vendored), not Times; the exemplars are Times.

## Review of the rendered pages (Gate 2 record)

Every page of the sample was rendered at 60 dpi and viewed after the last template change.

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, motion title, the motion's paragraph. The bottom third is empty: the response language and signature moved to page 2 as one block. | Pass. |
| 2 | Response language (single spaced, verbatim LBR 1005-1(d)(1)), the case line, "Respectfully submitted", signature, bar placeholder. | Pass. The signature is not alone on the page. |
| 3 | Memorandum: caption repeated, memorandum title, "Factual Background". | Pass. |
| 4 | "Argument", the first paragraphs, the point heading "The Within Action Is Moot ...", two lines of heading, paragraph follows. | Pass. |
| 5 | Mootness paragraphs, "Plaintiffs Are Not Entitled to Attorneys' Fees and Costs" heading, the fees paragraphs. | Pass. |
| 6 | Notice paragraph, Westlaw pin cite escaped (`at *4-5`), footnote 1 at the foot in 10 point. | Pass. |
| 7 | Footnote 2 (EAJA) at the foot, "Plaintiffs Are Not Entitled to Punitive Damages". | Pass. |
| 8 | Conclusion, memorandum signature block, "Of Counsel" lines kept with it. | Pass. |
| 9 | Certificate of service: date, recipients, `/s/` signer. | Pass. |

## Engines

**docx** (`docx/`): `reference.docx` (built by `docx/build-reference.sh`, which names every font so no theme font falls back to Aptos or Calibri) and `docx/rib-motion-brief.lua` (caption, unnumbered paragraphs, "1." lists, response language, signature blocks, memorandum part, certificate of service, all from the frontmatter and the `---` separator). Render: `sh tools/render.sh --engine docx motion-brief usage/INPUT-<id>.md`.

Matches the typst output (every page of `usage/OUTPUT-rib-motion-brief-hidalgoastrue.docx.pdf` was viewed, side by side with `usage/OUTPUT-rib-motion-brief-hidalgoastrue.typst.pdf`):

- EB Garamond 12 pt, footnotes 10 pt (single spaced, at the foot of the page), page number 11 pt centered; letter paper, 1 in margins. `pdffonts` shows only EB Garamond, embedded.
- Double spacing is exact 24 pt lines; single spacing (caption, response language, quotations, signature, certificate) is exact 13.8 pt, the pitch measured on the typst output.
- The motion is unnumbered; "1." lists hang with the text at 1.05 in; block quotations are single spaced and indented.
- Caption and title repeated at the start of the memorandum, which starts on a new page; the certificate of service starts on a new page.
- Response-time language (LBR 1005-1(d)(1)), single spaced, kept with the signature block.
- Signature blocks: the case line, "Respectfully submitted", signer, firm, RI Bar No., address; the memorandum's block also carries the "Of Counsel" lines. The certificate's signer lines are right-aligned, as in typst.
- Page count: 9 pages (typst 9).

Differs from the typst output (not fixed):

- The first line of each page sits about 10 pt lower in the docx (exact-height lines place text lower than typst); the line pitch is the same.
- A single-line heading is about 7 pt further above the next paragraph than in typst.
- Some lines break at different words (LibreOffice and typst line-breaking differ slightly), so the response language and some memorandum paragraphs run to one line more or fewer. The page count is the same.
- Paragraph text is not justified in either engine.

BLOCKED: none. Checked with LibreOffice 26.2 only: the `.docx` converts with no error, but Word was not available, so opening in Word without a repair prompt is not verified. Footnotes are native Word footnotes (pandoc). The `---` separator is read as the memorandum break; a document with no separator has no memorandum part.

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md)
