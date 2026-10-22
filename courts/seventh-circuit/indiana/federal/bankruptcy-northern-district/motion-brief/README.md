# innb: motion brief (supporting brief / memorandum)

Doc type: **brief in support of a motion** in a contested matter or adversary proceeding in the United States Bankruptcy Court for the Northern District of Indiana (`innb`). Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief/`.

Scope: the template produces the supporting brief (the memorandum). Under N.D. Ind. L.B.R. B-7007-1(a) the motion is a separate document, so the motion itself, and the proposed order that B-9013-1(c) says "should accompany" it, are not templated (see gaps).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer: a creditor; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole brief as filed (13 pages), transcribed |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 12 pages each, typst 0.15.0, vendored Times New Roman only, no warnings, exit 0 |
| checks | typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (338/338 lines break alike), `params.cross_engine: gate` in `eval.yaml` (fb-595.68.27) |
| overlay | ok: `usage/OVERLAY-river-terrace-motion-brief.pdf` and `.txt` (exit 0) |
| pages reviewed | 12 of 12, typst and docx (every page rendered at 60 dpi and viewed after the last template change) |

This is a doc-type folder, not a court folder: `court.json`, `STATUS.md` and the court-root `typst/` and `usage/` are untouched, and nothing here sets a status.

## Governing rules

Rule text was read on 2026-10-14. Local rules were read from the PDF text layers (WebFetch returned the saved PDFs; `pdftotext` read them). Federal rule text was read from the Cornell LII pages.

| ID | Rule | Requirement (quoted or closely paraphrased) | Where it is in the template |
|---|---|---|---|
| INNB-FORM-001 | N.D. Ind. L.B.R. B-5005-2(a)(1) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-5005-2_0.pdf) | "They shall be plainly typewritten or printed and double spaced, except for quoted material." | `pitch-body = 24pt`; body double spaced; block quotations single spaced (`pitch-single = 13.8pt`). |
| INNB-FORM-002 | B-5005-2(a)(2) | "The title must be set out on the first page." | `title-block` under the caption, on page 1. |
| INNB-FORM-003 | B-5005-2(a)(3) | "Each page shall be consecutively numbered." | Footer page number, 1 to end, centred. |
| INNB-FORM-004 | B-5005-2(a)(4), (b)(2) | "All papers must be clearly legible." Paper: "white paper of good quality, 8½" x 11" in size, printed on one side of the paper only." | `paper: "us-letter"`; 1-inch margins (style choice). |
| INNB-FORM-005 | (none) | No typeface or point size is named in B-5005-2 or FRBP 9004(a). B-5005-2(a)(1) says only "plainly typewritten or printed" (text checked 2026-10-15); FRBP 9004(a) says only "clearly legible". Typeface row: face required = none; Times New Roman (the exemplar's face) set by its vendored substitute (`docs/FONTS.md`). | `font-family = ("Times New Roman", "Liberation Serif")`, `type-size = 12pt` (style choices; see gaps); the docx names the same face (`{font}` in `docx/reference.xml`). |
| INNB-CAP-001 | Fed. R. Bankr. P. 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004; amended Apr. 2, 2024, eff. Dec. 1, 2024) | "A document presented for filing must contain a caption that sets forth: the court's name; the case's title; the case number and, if appropriate, adversary-proceeding number; and a brief designation of the document's character." | `court-title`, `debtor-table` (case no., chapter), `title-block` (designation). No adversary number: this is a contested matter; the River Terrace case had none. |
| INNB-CAP-003 | B-9013-1(a) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-9013-1_0.pdf) | "All such requests shall be named in the caption, shall state with particularity the order or relief sought and the grounds for the motion." | `title` frontmatter: the title names the request ("Motion to Determine Bid ... as a Conforming Bid ..."). Read as the caption here (see gaps). |
| INNB-BRF-001 | B-7007-1(a) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-7007-1_0.pdf) | "Any motion filed within a contested matter or an adversary proceeding ... shall be accompanied by a separate supporting brief." | The template is the brief. The motion is a separate filing, not templated. |
| INNB-BRF-002 | B-7007-1(b) | "Except by permission of the court, no brief shall exceed twenty-five (25) pages in length (exclusive of any pages containing a table of contents, table of authorities, and appendices), and no reply brief shall exceed fifteen (15) pages." "Briefs exceeding twenty-five (25) pages ... shall contain (a) a table of contents with page references; (b) a statement of issues; and (c) a table of cases ... with reference to the pages of the brief where they are cited." | Not checked: the template has no page counter. A brief over 25 pages needs a table of contents, a statement of issues and a table of authorities, which the template does **not** generate (see gaps). The sample is 12 pages. |
| INNB-BRF-003 | B-9013-1(c) | "The application, motion, or other request should be accompanied by a proposed form of order." | **Not templated.** The proposed order is a separate filing. |
| INNB-SIG-001 | Convention (no rule cites the form) | "Dated:" line, "Respectfully submitted,", "/s/" signature, signer, firm, address, telephone, email, "Attorneys for ...". | `signature-block`. The exemplar prints a firm document number at the foot (`2303419`); it is transcribed as the last signature line. |

Not used, and why: B-7008-1 (responsive pleadings) applies to answers, not briefs. Fed. R. Bankr. P. 9013 and 9014 (motion practice and contested matters) were not fetched, so nothing is asserted from them.

## Layout

- US Letter, 1-inch margins, one side, Times New Roman 12 pt. The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line an exact box of its pitch, 24 pt for the double-spaced body, 13.8 pt (Word's single line at 12 pt) for the court title, caption, title, headings, block quotations, footnotes and signature; spaces between blocks in pt (half a body line, 12 pt, around headings and quotations and between a quotation's paragraphs); first-fit, ragged right, no hyphenation, kerning or ligatures. The 11 pt page number sits in a 13.8 pt line, footer-descent 30 %.
- Page 1: court title (three centred bold lines), debtor block (`In re:`, the debtor's name half an inch in and the designation 1.6 in in, closed by a rule on the right and below; case number and chapter at right, from the line of the name), then the title in centred bold caps (one line per entry in `title`).
- Headings are written by the author as they appear in the filing: `# I. INTRODUCTION` centred bold caps; `## 1. The Court Should Find ...` left bold; single-spaced, half a body line above and below, kept with the text. The template does not number headings (unlike ca9).
- Paragraphs are not numbered; the first line is indented 0.5 inch, and so is the paragraph after a heading or a block quotation.
- Block quotations: a chunk starting with `>` is single spaced, indented 0.5 inch on both sides.
- Footnotes: `[^key]` in the body and `[^key]: text` anywhere; 12 pt in 13.8 pt lines, 7 pt apart, each kept whole on one page (typst had set a split note's first line on the page before its anchor line; Word keeps Footnote Text's lines together).
- Signature: the last paragraph is kept on one page with the signature block, a body line below it: "Dated:" at the margin, the preamble, the signer a body line lower and the address lines in a 3.2 in right-hand column.

## Markdown contract (for samples)

- YAML frontmatter: `court` (lines), `debtors` (list of `names`, `designation`), `case_number`, `chapter`, `title` (lines), `date`, `signature` (`preamble`, `signer`, `lines`).
- Body: markdown. `#` heading, `##` sub-heading, `>` block quotation, `[^key]: ...` footnote definition, or a paragraph; typed labels such as "a." stay text (the docx reader has fancy lists off). No tables, no raw typst.
- Dollar signs are escaped (`\$`). Case names are written with markdown italics where the author chooses (the sample uses none; see gaps).

## Render and overlay

```sh
just render courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief
just overlay courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief
```

- Render: exit 0, no warnings. `pdffonts` shows Times New Roman (regular, bold) only, embedded.
- The exemplar is set in Times with a different caption layout (parenthesis caption, underlined headings, bold defined terms), so lines will not coincide in an overlay. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 12 pages of both engines, rendered at 60 dpi and viewed, fb-595.68.27)

The typst and docx renders break every line and page alike (XENG-001..003), so one row covers both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, debtor block, title, opening paragraph, I. INTRODUCTION | Pass. The debtor name fits its column on one line (was OPEN: it wrapped). |
| 2 | Introduction | Pass. |
| 3 | Introduction end, II. BACKGROUND FACTS | Pass. |
| 4 | Plan quotation (block, single spaced), the Bid Procedures items a to d | Pass. The items are unnumbered paragraphs, as in the filing. |
| 5 | Prior-to-bid facts, Exhibits A to C | Pass. |
| 6 | Exhibit D, December 30 and 31 facts | Pass. |
| 7 | 12/31 e-mail, III. QUESTION PRESENTED | Pass. Three lines free at the foot: the paragraph's last two lines move on with the line that anchors footnote 1, which does not fit here. |
| 8 | Question presented end, IV. ARGUMENT, sub-heading 1, footnotes 1 and 2 | Pass. Both notes at the foot of the page where they are cited. |
| 9 | Argument: authorities, block quotation (Atlanta Packaging) | Pass. |
| 10 | Financial News discussion, the balancing paragraph | Pass. |
| 11 | Argument end | Pass. The foot is left free: the conclusion moves on with the signature. |
| 12 | V. CONCLUSION and the signature block | Pass (was OPEN: the signature stood alone on page 13; the last paragraph is now kept with it). |

## Known gaps and open choices

1. **Motion not templated; B-7007-1(a) reading.** The rule says a motion "shall be accompanied by a separate supporting brief." The doc type's brief in the task was "motion with memorandum". This template follows the rule: a brief, filed separately. A combined motion-with-memorandum is not what B-7007-1 describes, so the motion (and the proposed order under B-9013-1(c)) belongs to another doc type or to a later pass. **Needs David's call** if a combined form is wanted.
2. **Caption and B-9013-1(a).** The rule says the requests are "named in the caption". The River Terrace brief names the request in the title block directly under the caption box, not inside the box. The template follows the filing. Whether a title block counts as "the caption" for this rule is a reading question; flagged, not decided.
3. **TOC and TOA not generated (B-7007-1(b)).** Only briefs over 25 pages need them, and the sample is 12 pages. The template has no page counter, so it cannot tell when the threshold is crossed. A brief over 25 pages filed from this template would be wrong until a TOC, statement of issues and table of authorities are added.
4. **Typeface and size (INNB-FORM-005).** No rule names a typeface or size for innb; Times New Roman 12 pt, the exemplar's face, on all engines.
5. **Case names not italic.** The exemplar's text layer has italic runs (`TimesNewRoman,Italic` is embedded), so case names are italic in the filing. The sample transcribes them roman, because the italic runs were not measured one by one. The template italicises `*...*` markup if a sample adds it. Tier 2 finding.
6. **Certificate of service not generated.** The exemplar has none. Service rules were not checked; nothing is asserted about the certificate.
7. **Signature block.** Kept on one page with the last paragraph (resolved; see page 12).
8. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers. The other innb motion candidates were read and not saved: Homman v. Schwartz (adv. 22-03010, Doc 4, 2-page motion for remand), Rudecki v. Price (adv. 11-03033, Doc 4, 5-page brief for a TRO, 2011), Homann v. One Advantage (adv. 22-03017, Doc 13, 4-page brief for default judgment). None is a combined motion with memorandum.
9. **Dated line.** The exemplar's "Dated:" line sits left of "Respectfully submitted,"; the template does the same (convention).
10. **Footnote 2 position.** The marker is placed after "§§ 105" (the superscript reads as "1052" in the text layer). Placement was taken from the glyph coordinates, not from the rule.

## Engines

DOCX engine (`docx/`, no shell, fb-595.68): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`, Times New Roman: Body Text in exact 24 pt lines (480 twips), the single 13.8 pt line (276), headings and Block Text quotations 12 pt (240) from the text and half an inch in on both sides, footnotes in 13.8 pt lines 7 pt apart and kept whole, the 11 pt page number in a 13.8 pt footer line 735 twips above the page foot; styles added: Body Text Note (no widow control) for a paragraph that anchors a footnote, Body Text Keep for the last paragraph (kept with the signature); pandoc's fancy lists off, so the typed labels "a." stay text) and the filter `docx/innb-motion-brief.lua` (on `require("docx.xengine")`). `fb render` builds the reference and runs pandoc; there is no `build-reference.sh` and no committed `reference.docx`. Output `usage/OUTPUT-motion-brief.docx` and its LibreOffice render `.docx.pdf`.

- The filter writes the court title, the debtor table (Word borders right and below the debtor cell), the title, the headings and the signature row (cantSplit) with the typst pitches and spaces in twips; pandoc writes the paragraphs, quotations and footnotes in the reference's styles, the inlines walked with `xe.inlines`; ')(' gets a word joiner and a slash before a letter a zero-width space, a doubled section sign a no-break space, as typst breaks them.
- Checks: `RESULT: 13 checks passed, 0 failed`; XENG-001..003 PASS, 338/338 typst lines break after the same word, every page starts and ends on the same word (12 pages); largest width drift of an identical line 0.40 pt. Before the port the docx was EB Garamond 13 pt (DEF-FORM-002, DEF-FONT-002 and TNR-EMBEDDED failed; 75/342 lines alike).
- Not applicable: no table of contents or table of authorities in this form (B-7007-1(b) is not checked, see the gaps above), so no field update is needed.
