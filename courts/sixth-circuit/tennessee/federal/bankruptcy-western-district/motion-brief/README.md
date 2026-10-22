# tnwb: motion-brief

Doc type: **motion with memorandum of law** in the United States Bankruptcy Court for the Western District of Tennessee (`tnwb`), filed under FRBP 9013 and TNWB LBR 9013-1. The template formats the memorandum of law that supports a motion; the motion itself is a separate short filing.
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (memorandum only, 1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the full 7-page memorandum transcribed: caption, background, standard of review, argument, conclusion, footnotes, signature, certificate of service) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx.pdf`, 7 pages each, US Letter, Times New Roman (vendored), no typst warnings |
| overlay | `just overlay <dir>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (gitignored, not committed) |
| pages reviewed | 7 of 7, typst and docx (every page rasterized at 60 dpi and viewed; fb-595.68.31) |
| tier 2 | not met: one filer only (see Known gaps 1) |
| typeface | face required by the rules: none (Known gaps 4) -> the exemplar's Times New Roman (vendored, `("Times New Roman", "Liberation Serif")`) |

Commands (from the repo root, toolchain on PATH):

```sh
sh tools/check.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief                 # typst: render and gates
sh tools/check.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief --engine docx   # docx: render, gates, XENG
just overlay courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief
```

## Governing rules

Dates verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| FRBP 9013(a) | A request for an order must be made by written motion (unless an exception applies). | https://www.law.cornell.edu/rules/frbp/rule_9013 | Not generated: the motion is a separate filing. The memorandum's title names the motion it supports (`title`). |
| FRBP 9013(b) | A motion must state its grounds with particularity and set forth the relief requested; service on the entities the rules require. | same | Author content (the memorandum's argument). Service is shown by the certificate of service (`service` frontmatter). |
| FRBP 9004(a), (b) (restyled eff. Dec. 1, 2024) | Papers must be clearly legible; caption with the court's name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-heading`, `caption`, `title`. |
| FRBP 7010 (adversary proceedings) | Caption must substantially conform to Official Form 416; Rule 10 of the Civil Rules applies. | https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption` (same layout as the adversary complaint). Form 416 was not fetched (Known gaps 3). |
| TNWB LBR 9013-1 (eff. April 3, 2017) | Motions, applications, objections and proposed consent orders in which relief is sought after notice and hearing; in Chapter 7, 11 and 12 cases the movant files with the Clerk and the Courtroom Deputy sets the deadline. | https://www.tnwb.uscourts.gov/PDFs/BK/LocalRules.4.3.17.pdf | Not checked by the template (Known gaps 2). |
| TNWB LBR 7016-1(a) | Memoranda of facts and law "should not exceed twenty-five (25) pages without prior approval of the court." | same | Not checked by the template. The sample is 6 pages; the author must count any longer memorandum. |
| TNWB LBR 7016-1(b) | An opinion cited that is not on Westlaw or Lexis must be attached or supplied to the court seven days before the hearing. | same | Not generated; author content. |
| TNWB LBR 1001-3(h) | Every filed document bears the signature of an attorney of record and the attorney's address, zip, telephone, email, fax if any, and state bar disciplinary number. | same | `signature` frontmatter (`firm`, `signer`, `name_line`, `lines`, `role`). See Known gaps 5. |

## Layout

The shared cross-engine layout model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch with the baseline at 0.8 of it, the boxes touching, explicit spaces between blocks; first fit, ragged right, no kerning, ligatures or hyphenation. The docx sets the same pitches and spaces in twips (`docx/reference.xml`, `docx/tnwb-motion-brief.lua`). No TNWB rule sets any of these numbers (TNWB-FORM-011): they are conventions.

- Letter paper, 1 in margins. Times New Roman 12 pt; body double spaced (24 pt pitch), first-line indent 0.5 in; single lines 13.8 pt (Word's single line at 12 pt). Paragraphs are not numbered by the template; a paragraph that opens with a typed number (`1\.` in the markdown) sets it in a half-inch box at the indent, the text from 1 in (as filed).
- Court heading centered, plain capitals; caption as in the court's adversary complaint (the § column, one single line per row, party names in capitals, a 0.5 pt rule under the debtor block and under the parties).
- Title centered bold capitals, 12 pt above and below.
- `#` headings: centered bold capitals; `##`: centered bold; `###`: bold at the margin, a typed label (`A.`) in a half-inch box with the text hanging after it (as filed). Single lines, 12 pt above and below, kept with the text after them.
- Block quotations (`>`): single lines, 0.5 in in on both sides, 12 pt above and below.
- Tables (pipe tables, none in the sample): centered, 60 % of the text width, equal columns, 0.5 pt rules, the header row bold; rows not split, the header not repeated.
- Footnotes: 10 pt in 11.5 pt lines, 6 pt apart, a 30 % rule 7.8 pt above (with the 6 pt, Word's 13.8 pt separator line).
- Signature block 3 in from the margin (as filed), 12 pt below the last paragraph, single lines: the closing, the firm (bold) a line below it, `/s/` signer, name line with the state bar number, address and contact lines, role (italic). The last body paragraph is kept on one page with the signature block.
- Certificate of service (if `service` is given), on a page of its own (as filed): centered bold underlined heading, the exemplar's wording at body pitch, the served parties two to a row (0.3 in apart, a single line between rows), `/s/` signer at 3 in.
- Page number centered in the footer, in a 13.8 pt line.

## Markdown contract (for samples)

YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `division` | no | third caption line |
| `debtor` (list of lines) | yes | `IN RE:` block |
| `case_number` | yes | `CASE NO.:` |
| `chapter` (list of lines) | yes | chapter lines |
| `adversary_number` | yes | `ADVERSARY PROCEEDING NO.:` |
| `plaintiffs`, `defendants` (lists) | yes | adversary block |
| `title` | yes | memorandum title, centered in capitals |
| `signature` | yes | `closing`, `firm`, `signer`, optional `name_line`, `lines`, `role` |
| `service` | no | `date` and `parties` (a list; each party is a list of lines) for the certificate of service |

Body: blank-line separated blocks. `#` / `##` / `###` headings; `|` tables; `>` quotations; any other block is an unnumbered paragraph with a first-line indent; one that opens with a typed number sets it in the number box. `- ` lists are set with the bullet in a half-inch box. A literal `*` must be escaped (`at \*8`), and a paragraph that begins with a number and period must be escaped (`1\. On July 19, 2017`), or cmarker reads it as a list.

## Known gaps and open choices

1. **One exemplar, and it is the memorandum, not the motion.** The tier-2 test (2 or 3 filers) is not met. The search (CourtListener RECAP, `court=tnwb`, memoranda in support) found Johnson 18-00294 and Minnesota Life 18-00157 (memoranda whose PDFs are not in RECAP) and Brown 23-00021 (doc 15, the motion to dismiss, which did not download). None was saved. The motion that Kenney's memorandum supports is not in the exemplar; the template covers the memorandum only.
2. **LBR 9013-1 and 7016-1 are not checked by the template.** The page limit (25 pages, LBR 7016-1(a)) and the motion-practice steps (LBR 9013-1(b)–(c): filing with the Clerk, the Courtroom Deputy's deadlines, the proposed order and certificate on Local Form 008F) are the filer's job. The template does not generate the motion, the proposed order or Local Form 008F.
3. **Form 416 was not fetched.** See the adversary complaint README, Known gaps 3.
4. **No court typeface, margin or spacing rule found.** See the adversary complaint README, Known gaps 2. The conventions here (Times New Roman 12 pt, double spaced, 1 in margins) follow the exemplar. Until fb-595.68.31 the docx was EB Garamond (TNR-EMBEDDED and DEF-FONT-002 failed).
5. **State bar number.** LBR 1001-3(h) requires the state bar disciplinary number. The exemplar's signature block shows "Jay A. Ebelhar (22770)", which is the number on the signature line; the template prints `name_line` as given. The template does not check for it.
6. **Italics.** The exemplar's text layer does not show italics. The sample italicizes case names and signals (*Id.*, *see*, *In re ...*) as a convention; the exemplar's visual italics were not checked.
7. **Certificate of service.** The wording and the layout follow the exemplar. The rule that requires a proof of service on each filed motion was not identified and was not verified; the certificate is an exemplar convention.
8. **Transcription.** The sample is the exemplar's text transcribed from its text layer, with the exemplar's own errors kept (for example "fails to state a clam" in the Standard of Review). The footnote numbering is the exemplar's.
9. **Justification.** Body text is ragged right (the cross-engine model: first fit, no hyphenation). Not asserted.
10. **Overlay.** The overlay (`just overlay`) pairs pages by word overlap; the sample breaks pages where the template does, not where the exemplar does. The overlay is a diagnostic, not a score.
11. **Caption.** The exemplar (Baker Donelson) sets a ruled caption without a § column, with the designations at the right margin; the template keeps the § caption of the court's adversary complaint exemplar (another filer), so both doc types share one caption. Tier 2, ACCEPTED; a decision for David if the memorandum should follow its own filer.

## Review of the rendered pages (final render, 7 pages, typst and docx; fb-595.68.31)

Rendered at 60 dpi with `pdftoppm -r 60` and viewed page by page, typst beside docx. The docx breaks every line and page as the typst render (XENG-001..003, 177/177 lines); the findings hold for both.

| Page | Content | Result |
|---|---|---|
| 1 | Court heading, caption, title, opening paragraph, PROCEDURAL/FACTUAL BACKGROUND, paragraphs 1–2; footnote 1 | Pass. Typed numbers in the number box, as filed. |
| 2 | Paragraphs 3–8; STANDARD OF REVIEW; footnote 2 in full | Pass. |
| 3 | Standard of review (cont.); ARGUMENT; sub-heading A (label in its box, text hanging) | Pass. |
| 4 | Sub-heading A (cont.): block quotation and the Moore citation | Pass. The citation after the quotation takes the first-line indent (the exemplar sets it at the margin): ACCEPTED, tier 3. |
| 5 | Sub-heading B; its paragraphs | Pass. The page ends early: CONCLUSION (kept with its paragraph) and the last paragraph (kept with the signature block) move to page 6 together, as in the exemplar. ACCEPTED. |
| 6 | CONCLUSION; signature block | Pass. The firm name wraps to three lines in the 3.5 in column, alike in both engines. |
| 7 | CERTIFICATE OF SERVICE: wording, served parties two to a row, `/s/` signer | Pass. |

Open tier-2 findings: none. ACCEPTED: Known gaps 11 (caption), the pages 4 and 5 notes above.

## Engines

- **typst** (primary, `typst/tnwb-motion-brief.typ`): the reference for the form, on `lib/typst/xengine.typ` (`xengine.with(pitch: 24pt)`, single lines in `edges(13.8pt)` boxes, footnotes in `edges(11.5pt)`).
- **docx** (`docx/reference.xml`, `docx/tnwb-motion-brief.lua`; built by `fb render`, no shell): `reference.xml` is the cross-engine recipe (`base="xengine"`, `{font}` = the typst face; Body Text 480-twip lines with a 720-twip indent, 276-twip single lines, headings 240 twips from the text, footnotes 10 pt in 230-twip lines 120 twips apart, the page number in a 276-twip footer line 735 twips from the page foot) plus "Numbered Paragraph" (tab at 1 in) with its "Note" and "Keep" variants, "Body Text Note" (no widow control, for a paragraph that anchors a footnote) and "Body Keep". The filter (`require("docx.xengine")`) writes the court heading, caption table, title, headings, tables, quotations, the signature block and the certificate of service (page break before it, parties in a three-column table) with the typst spacing in twips; body paragraphs go to pandoc in those styles (footnotes stay Word footnotes). Break rules as typst: no break inside ")(", a break after a slash before a letter ("CM/ECF"), `§§`/`¶¶` bound to the number. Until fb-595.68.31 the docx was EB Garamond from `docx/build-reference.sh`.
- Checks (fb-595.68.31): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (7 pages each, 177/177 lines). `eval.yaml` sets `params.cross_engine: gate`.
- **latex**: no latex template for this doc type.
