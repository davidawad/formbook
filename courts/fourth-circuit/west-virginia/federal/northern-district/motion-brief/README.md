# wvnd: motion-brief (memorandum supporting a Rule 12(b)(6) motion to dismiss)

Doc type: **motion-brief**, the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), in the United States District Court for the Northern District of West Virginia (`wvnd`).
Folder: `courts/fourth-circuit/west-virginia/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-wv-rivers-amsted-1-26-cv-00046-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-amsted-motion-brief.md` (a portion of the 26-page memorandum; see below) |
| render | ok: `samples/OUTPUT-amsted-motion-brief.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-amsted-motion-brief.pdf` and `samples/OVERLAY-amsted-motion-brief.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |
| page limit | the template asserts the memorandum (everything before the certificate of service) is at most 25 pages (LR Civ P 7.02(a)); the sample is 7 pages before the certificate |

File names follow the repo's file-role convention, which `tools/render.sh` and `tools/overlay.sh` require: `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>.md` and `<id>-overlay.pdf` names would have needed changes to the tools, which are out of scope for this box.

## Governing rules

Primary sources: the Local Rules of the Northern District of West Virginia (the 2018 compilation, the PDF the court's own site links as its current local rules, `https://www.wvnd.uscourts.gov/sites/wvnd/files/NDWV%20Local%20Rules%202018%20MASTER.pdf%20with%20appendix.pdf`, fetched and text-extracted 2026-10-14; LR Civ P 7.02 and 12.02 read from it in full) and the Federal Rules of Civil Procedure (Cornell LII text, fetched 2026-10-14). The court's site lists one later civil amendment (LR Gen P 2.01 and LR Civ P 7.10 and 7.20, effective December 1, 2022); it does not touch the rules cited here. Searches for a 2024–2026 revision of LR Civ P 7.02 found none.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR Civ P 7.02(a) (2018 compilation, p. 42) | A supporting memorandum of not more than 25 pages, double-spaced; the judge may allow more for good cause. | `page-limit = 25`; the build asserts that the pages before the certificate of service are at most 25 and fails with the page count otherwise. |
| LR Civ P 7.02(a) | 8½ × 11 paper; one-inch margins on all four sides; page numbers, but no text, in the margins. | `page-w`, `page-h`, `margin = 1in`; the footer is a page number only. The court's ECF header, which the filing system adds, is not produced. |
| LR Civ P 7.02(a) | Times New Roman, Courier New or Arial; 12 point proportionally spaced (11 point non-proportional). | **Not met: see known gaps.** The template uses EB Garamond at 12 point. |
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

1. **Typeface (LR Civ P 7.02(a)). Not met.** The rule requires Times New Roman, Courier New or Arial at 12 point proportional. This repo vendors only EB Garamond, and the brief rules out system fonts and touching `fonts/`. The template uses EB Garamond (the cand templates do the same). **BLOCKED for tier 1, a question for David:** vendor a Times-metric face (for example Liberation Serif, SIL OFL, which is metrically compatible with Times New Roman) into `fonts/`, or accept EB Garamond for N.D. W. Va. memoranda. A memorandum set in EB Garamond does not meet LR Civ P 7.02(a) as written.
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
- Page 4: facts ends; "LEGAL STANDARD" centered; "LEGAL ARGUMENT – 33 U.S.C. § 1365 …" centered bold underlined; "I. Plaintiffs Are Exercising the Executive Power" with a hanging indent. Pass.
- Page 5: Argument I paragraphs with italic case names and short forms; "II. Plaintiffs' Exercise of Executive Power Violates the Private Nondelegation Doctrine" bold with a hanging indent at the foot of the page, with two body lines after it (the heading is kept with text). Pass.
- Page 6: Argument II ends; bracketed note for the omitted pages; "CONCLUSION" centered; the conclusion paragraph. The page has white space at the foot (see gap 2). Pass.
- Page 7: "DATED: August 5, 2026", "Respectfully submitted,", "s/ Peter Raupp", counsel lines with the e-mail and telephone. The page carries only the signature (see gap 2). Pass, with the note.
- Page 8: CERTIFICATE OF SERVICE on its own page with the caption repeated; the statement; the served list; "s/ Peter Raupp" and the role line. Pass.

Overlay (`samples/OVERLAY-amsted-motion-brief.txt`): pages 1–4 pair with the same filed pages (94.1%, 83.2%, 65.2%, 47.0% word overlap); page 5 pairs with filed page 6, page 6 and page 7 with filed page 24 (the sample skips filed pages 8 to 22), page 8 with filed page 26 (the certificate). The pairing is a diagnostic, not a score.
