# wvnd: motion-brief (memorandum supporting a Rule 12(b)(6) motion to dismiss)

Doc type: **motion-brief**, the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), in the United States District Court for the Northern District of West Virginia (`wvnd`).
Folder: `courts/fourth-circuit/west-virginia/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-wv-rivers-amsted-1-26-cv-00046-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-amsted-motion-brief.md` (a portion of the 26-page memorandum; see below) |
| typeface | Liberation Serif (vendored; the Times New Roman substitute, metric-compatible), 12 point. LR Civ P 7.02(a) names Times New Roman, Courier New or Arial. Was EB Garamond. |
| render | ok: `samples/OUTPUT-amsted-motion-brief.pdf`, 8 pages (8 before the font change), typst 0.15.0, vendored Liberation Serif only, `pdffonts`: LiberationSerif, -Bold, -Italic embedded, no warnings |
| overlay | ok: `samples/OVERLAY-amsted-motion-brief.pdf` and `samples/OVERLAY-amsted-motion-brief.txt`, run against the RECAP copy in `exemplars/SOURCE.md` (the exemplar PDF is not in this checkout, so the tool's default `exemplars/*.pdf` lookup fails; pass the file as the third argument) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the font change) |
| page limit | the template asserts the memorandum (everything before the certificate of service) is at most 25 pages (LR Civ P 7.02(a)); the sample is 7 pages before the certificate |

File names follow the repo's file-role convention, which `tools/render.sh` and `tools/overlay.sh` require: `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>.md` and `<id>-overlay.pdf` names would have needed changes to the tools, which are out of scope for this box.

## Governing rules

Primary sources: the Local Rules of the Northern District of West Virginia (the 2018 compilation, the PDF the court's own site links as its current local rules, `https://www.wvnd.uscourts.gov/sites/wvnd/files/NDWV%20Local%20Rules%202018%20MASTER.pdf%20with%20appendix.pdf`, fetched and text-extracted 2026-10-14; LR Civ P 7.02 and 12.02 read from it in full) and the Federal Rules of Civil Procedure (Cornell LII text, fetched 2026-10-14). The court's site lists one later civil amendment (LR Gen P 2.01 and LR Civ P 7.10 and 7.20, effective December 1, 2022); it does not touch the rules cited here. Searches for a 2024–2026 revision of LR Civ P 7.02 found none.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR Civ P 7.02(a) (2018 compilation, p. 42) | A supporting memorandum of not more than 25 pages, double-spaced; the judge may allow more for good cause. | `page-limit = 25`; the build asserts that the pages before the certificate of service are at most 25 and fails with the page count otherwise. |
| LR Civ P 7.02(a) | 8½ × 11 paper; one-inch margins on all four sides; page numbers, but no text, in the margins. | `page-w`, `page-h`, `margin = 1in`; the footer is a page number only. The court's ECF header, which the filing system adds, is not produced. |
| LR Civ P 7.02(a) | Times New Roman, Courier New or Arial; 12 point proportionally spaced (11 point non-proportional). | Met with the vendored substitute for Times New Roman: `font-family = "Liberation Serif"` (`docs/FONTS.md`), 12 point. Not Times New Roman itself, which is not vendored. |
| LR Civ P 7.02(a) | Footnotes and indented quotations may be single-spaced; footnote text no smaller than 11 point proportional. | `note-size = 11pt`, footnotes and quotations single-spaced. |
| LR Civ P 12.02 (2018 compilation, p. 50) | A motion to dismiss is designated prominently and filed as a separate pleading. | The memorandum is its own paper with its own title. The motion itself (ECF No. 7 in the exemplar's docket) is a separate document and is not produced here. |
| LR Gen P 5.06(e) (2018 compilation, pp. 13–14) | A certificate of service "is required for all filings," and "must specify who was served and the manner in which service … was accomplished on each party." | `certificate()`: on its own page with the caption repeated; `served` lists who was served; the manner (CM/ECF) is printed. |
| LR Gen P 5.03(c) (2018 compilation, p. 9) | Attorney signature in the form "s/ (attorney name)"; "s/" alone is insufficient. | `signature-block()` and `certificate()` print "s/ " followed by the signer's name. The exemplar prints "/s/". |
| Fed. R. Civ. P. 11(a) (`https://www.law.cornell.edu/rules/frcp/rule_11`, verified 2026-10-14) | The paper states the signer's address, e-mail and telephone. | `signature-block()` asserts an e-mail address and a telephone number in the signature lines; the build fails without them. |
| Fed. R. Civ. P. 12(b) and 12(b)(6) (`https://www.law.cornell.edu/rules/frcp/rule_12`, verified 2026-10-14) | Failure to state a claim upon which relief can be granted may be raised by motion. | Content of the memorandum (the template does not check the argument). |
| LR Gen P 2.01 and LR Civ P 7.10 | Non-governmental corporate parties file a disclosure statement (the court's form, filed in CM/ECF). | Not part of the memorandum; not produced. |

## Layout

- Court title centered (court, district, division from `division`), then the caption: party lines in a single-spaced column with a ")" mark on each line, and "No. <case number>" on the row given by `caption.case_row`. Each caption line is one fixed-height row, so the ")" column lines up with the party lines.
- No cover page. The memorandum's title is centered and bold directly under the caption, and the body follows.
- Body double spaced (24 pt pitch at 12 pt), first-line indent 0.5 inch, one-inch margins on all four sides, page number centered in the bottom margin.
- Headings, numbered by the template: level 1 is centered, bold and underlined (for example "STATEMENT OF FACTS…", "LEGAL STANDARD", "CONCLUSION"); level 2 is "I.", "II." … bold with a hanging indent; level 3 is "A.", "B." …; level 4 is "1.", "2." … italic. Each level restarts under the one above.
- Footnotes at 11 point, single-spaced; footnote text may carry italic case names.
- Signature block after the conclusion: "DATED:" at the left; "Respectfully submitted," the "s/" line and the counsel lines at the middle of the page, single spaced.
- Certificate of service on its own page: the caption repeated, "CERTIFICATE OF SERVICE" centered bold, the statement that the foregoing was filed through CM/ECF, the list of those served, and the "s/" line with the role.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by blank lines.
- `# Heading` is level 1, `## Heading` level 2, `### Heading` level 3, `#### Heading` level 4. Do not type numbers or letters at the start of a heading; the template numbers the headings.
- A paragraph is any other chunk. Paragraphs are not numbered.
- Footnotes: `text[^key]` in the body and `[^key]: One paragraph of footnote text.` in its own chunk, anywhere in the file. The definition is attached to the chunk that cites it, so a key must be cited once; a second citation of the same key is not supported.
- Inline markdown: `*italic*` (case names, *Id.*, *see*), `[text](url)`, smart punctuation. Not supported: tables, block lists, raw typst.
- Frontmatter: `case_number` (required), `division` (optional), `caption` (required: `case_row` and `lines`; a line is a string or `{text, indent}` with the indent in inches), `brief_title` (required), `date` (required, printed as "DATED:"), `signature` (required: `signer`, `lines`; the lines must include an e-mail address and a telephone number), `certificate_of_service` (required: `date`, `served` (a list), `signer`, `role`).

## What the sample is (and is not)

`samples/INPUT-amsted-motion-brief.md` transcribes the memorandum's opening paragraphs, the statement of facts with its footnotes 1 to 3, the legal standard, the start of Argument I and Argument II (the text of the filing, cut at the paragraph where Argument II's footnote 6 would appear, which is not transcribed), a bracketed note for the filing's pages 8 to 22, the conclusion, the signature block and the certificate of service. Footnotes 4 and 6 of the filing are not transcribed. Case names are italicized by convention, because the exemplar's text layer carries no italics. The certificate's served list is the template's form, not the exemplar's words (see known gaps).

## Known gaps and open choices

1. **Typeface (LR Civ P 7.02(a)). Met with a substitute.** The rule names Times New Roman, Courier New or Arial at 12 point proportional. The template uses Liberation Serif, the vendored metric-compatible Times New Roman substitute, so the line breaks and page count match a Times New Roman setting. The rule names Times New Roman itself, which is not vendored and is not used. The substitute is a metric-compatible Times-style face, not Times New Roman itself; the filed exemplar is set in Times New Roman. The Liberation Serif line pitch was measured at 24.00 pt (`pdftotext -bbox-layout`) with `body-leading = 1.345em`, which keeps double spacing and the page count (8 pages, unchanged) against the EB Garamond setting.
2. **Signature block on its own page.** In the render, the "DATED" line and the signature block fall to page 7, after the conclusion on page 6, because the block does not fit on page 6. The template does not keep the last paragraph with the signature (typst has no keep-with-next for paragraphs). Tier 2: ACCEPTED for now, a candidate for a later pass.
3. **Certificate of service wording.** The exemplar's certificate says the filing was served electronically "to all counsel of record." LR Gen P 5.06(e) asks that the certificate "specify who was served and the manner" of service on each party. The template prints the list given in `served`. The sample lists "Counsel of record for Plaintiffs …" because the plaintiffs' counsel's names do not appear in the exemplar's memorandum text. Whether the court wants names is a question for David; the template accepts any list.
4. **Page limit counts.** The assertion counts every page before the certificate, including the caption page and the signature pages. The exemplar has 25 pages before its certificate (text through page 23, the signature block on pages 24 and 25), so under this count it sits exactly at the 25 pages the rule allows without leave.
5. **Motion not produced.** LR Civ P 12.02 requires the motion to be a separate pleading. This doc type is the memorandum only. The motion (two to three pages, with the relief stated precisely, per LR Civ P 7.02(a)) is a separate template to write if wanted.
6. **One exemplar.** The brief asks for one filing per doc type. Other N.D. W. Va. motion papers with text layers were found and not saved: Weirton Medical Center, Inc. v. Vigilant Insurance Company, 5:26-cv-00079 (motion for partial dismissal, three pages, Wheeling Division; counsel Perry). Tier-2 conventions are therefore judged against one filer.
7. **Footnote size.** The template sets footnotes at 11 point, the minimum LR Civ P 7.02(a) allows for proportional type. The exemplar's footnote size was not measured.
8. **Heading numbering.** The exemplar's own headings (I., II., A.) are typed; the template numbers them. The sample's level-2 headings match the exemplar's numbering (I., II.).

## Review of the rendered pages (current PDF, all 8 pages viewed)

- Page 1: court title, caption (parties with ")" marks; "No. 1:26-cv-00046-TSK" beside "Plaintiffs,"), title, the first paragraph. No overlap. Pass.
- Page 2: introduction ends; "STATEMENT OF FACTS & PROCEDURAL HISTORY" centered bold underlined; first facts paragraph. Pass.
- Page 3: facts paragraphs; footnotes 1 to 3 at 11 point, single spaced, separated by a rule; superscript note marks. Pass.
- Page 4: facts end; footnote 3 at the foot; "LEGAL STANDARD" centered bold underlined at the foot, with the first Legal Standard paragraph. Pass.
- Page 5: "LEGAL ARGUMENT – 33 U.S.C. § 1365 …" centered bold underlined; "I. Plaintiffs Are Exercising the Executive Power" with a hanging indent; Argument I paragraphs with italic case names and short forms. Pass.
- Page 6: the start of "II. Plaintiffs' Exercise of Executive Power Violates the Private Nondelegation Doctrine" (bold, hanging indent) and its paragraphs; bracketed note for the omitted pages; "CONCLUSION" centered; the conclusion paragraph. Pass.
- Page 7: the end of the conclusion; "DATED: August 5, 2026", "Respectfully submitted,", "s/ Peter Raupp", counsel lines with the e-mail and telephone. The page carries only the closing and signature (see gap 2). Pass, with the note.
- Page 8: CERTIFICATE OF SERVICE on its own page with the caption repeated; the statement; the served list; "s/ Peter Raupp" and the role line. Pass.

Overlay (`samples/OVERLAY-amsted-motion-brief.txt`): pages 1–5 pair with the same filed pages (95.6%, 85.8%, 79.3%, 68.9%, 50.2% word overlap); page 6 and page 7 pair with filed page 24 (the sample skips filed pages 8 to 22), page 8 with filed page 26 (the certificate). The pairing is a diagnostic, not a score.

## Engines

DOCX (`docx/`: `build-reference.sh` builds `reference.docx`; `wvnd-motion-brief.lua` writes the caption, the heading numbers, the signature block and the certificate). Output: `samples/OUTPUT-amsted-motion-brief.docx` and `.docx.pdf` (LibreOffice PDF). Pages reviewed: 8 of 8, every page rendered at 60 dpi and viewed.

- Matches the typst form: Liberation Serif 12 pt (`pdffonts`: LiberationSerif only), letter, 1 in margins, body double spaced at an exact 24 pt pitch, 0.5 in first-line indent, the caption with a ")" column (each line an exact 13.8 pt row; the case number beside its row), the brief title bold and centered, level 1 headings centered bold underlined, level 2 headings "I." with a hanging label, signature block at 3.25 in ("DATED:", "Respectfully submitted,", the "s/" line), footnotes native and 11 pt single spaced, page number centered at the foot, the certificate of service on its own page with the caption repeated.
- Differs: the gap after a heading number is a tab stop (typst: a grid cell). Levels 3 and 4 do not occur in the sample; they are set as hanging labels at 0.5 in and 1 in (typst: grid cells, not checked). Pagination differs slightly (docx memorandum 7 pages, typst 7 pages; the certificate is page 8 in both).
- BLOCKED: `sh tools/check.sh <court-dir> --engine docx` cannot run. It exits 2 with `Error: open .../motion-brief/checks.yaml: no such file or directory` (no `checks.yaml` for this court in this snapshot; not authored here).
- The 25-page limit of LR Civ P 7.02(a) is checked by the typst template only; the docx memorandum runs 7 pages on the LibreOffice PDF.
