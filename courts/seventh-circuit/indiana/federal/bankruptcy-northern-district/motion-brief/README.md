# innb: motion brief (supporting brief / memorandum)

Doc type: **brief in support of a motion** in a contested matter or adversary proceeding in the United States Bankruptcy Court for the Northern District of Indiana (`innb`). Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief/`.

Scope: the template produces the supporting brief (the memorandum). Under N.D. Ind. L.B.R. B-7007-1(a) the motion is a separate document, so the motion itself, and the proposed order that B-9013-1(c) says "should accompany" it, are not templated (see gaps).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-river-terrace-14-11829-motion-brief.pdf` (one filer: a creditor; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-river-terrace-motion-brief.md`: the whole brief as filed (13 pages), transcribed |
| render | ok: `samples/OUTPUT-river-terrace-motion-brief.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 |
| overlay | ok: `samples/OVERLAY-river-terrace-motion-brief.pdf` and `.txt` (exit 0) |
| pages reviewed | 13 of 13 (every page rendered at 60 dpi and viewed; pages 1 to 3 re-viewed after the last template change) |

This is a doc-type folder, not a court folder: `court.json`, `STATUS.md` and the court-root `typst/` and `samples/` are untouched, and nothing here sets a status.

## Governing rules

Rule text was read on 2026-10-14. Local rules were read from the PDF text layers (WebFetch returned the saved PDFs; `pdftotext` read them). Federal rule text was read from the Cornell LII pages.

| ID | Rule | Requirement (quoted or closely paraphrased) | Where it is in the template |
|---|---|---|---|
| INNB-FORM-001 | N.D. Ind. L.B.R. B-5005-2(a)(1) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-5005-2_0.pdf) | "They shall be plainly typewritten or printed and double spaced, except for quoted material." | `line-pitch = 24pt`; body double spaced; block quotations single spaced. |
| INNB-FORM-002 | B-5005-2(a)(2) | "The title must be set out on the first page." | `title-block` under the caption, on page 1. |
| INNB-FORM-003 | B-5005-2(a)(3) | "Each page shall be consecutively numbered." | Footer page number, 1 to end, centred. |
| INNB-FORM-004 | B-5005-2(a)(4), (b)(2) | "All papers must be clearly legible." Paper: "white paper of good quality, 8½" x 11" in size, printed on one side of the paper only." | `paper: "us-letter"`; 1-inch margins (style choice). |
| INNB-FORM-005 | (none) | No typeface or point size is named in B-5005-2 or FRBP 9004(a). | `font-family = "EB Garamond"`, `type-size = 13pt` (style choices; see gaps). |
| INNB-CAP-001 | Fed. R. Bankr. P. 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004; amended Apr. 2, 2024, eff. Dec. 1, 2024) | "A document presented for filing must contain a caption that sets forth: the court's name; the case's title; the case number and, if appropriate, adversary-proceeding number; and a brief designation of the document's character." | `court-title`, `debtor-table` (case no., chapter), `title-block` (designation). No adversary number: this is a contested matter; the River Terrace case had none. |
| INNB-CAP-003 | B-9013-1(a) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-9013-1_0.pdf) | "All such requests shall be named in the caption, shall state with particularity the order or relief sought and the grounds for the motion." | `title` frontmatter: the title names the request ("Motion to Determine Bid ... as a Conforming Bid ..."). Read as the caption here (see gaps). |
| INNB-BRF-001 | B-7007-1(a) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-7007-1_0.pdf) | "Any motion filed within a contested matter or an adversary proceeding ... shall be accompanied by a separate supporting brief." | The template is the brief. The motion is a separate filing, not templated. |
| INNB-BRF-002 | B-7007-1(b) | "Except by permission of the court, no brief shall exceed twenty-five (25) pages in length (exclusive of any pages containing a table of contents, table of authorities, and appendices), and no reply brief shall exceed fifteen (15) pages." "Briefs exceeding twenty-five (25) pages ... shall contain (a) a table of contents with page references; (b) a statement of issues; and (c) a table of cases ... with reference to the pages of the brief where they are cited." | Not checked: the template has no page counter. A brief over 25 pages needs a table of contents, a statement of issues and a table of authorities, which the template does **not** generate (see gaps). The sample is 13 pages. |
| INNB-BRF-003 | B-9013-1(c) | "The application, motion, or other request should be accompanied by a proposed form of order." | **Not templated.** The proposed order is a separate filing. |
| INNB-SIG-001 | Convention (no rule cites the form) | "Dated:" line, "Respectfully submitted,", "/s/" signature, signer, firm, address, telephone, email, "Attorneys for ...". | `signature-block`. The exemplar prints a firm document number at the foot (`2303419`); it is transcribed as the last signature line. |

Not used, and why: B-7008-1 (responsive pleadings) applies to answers, not briefs. Fed. R. Bankr. P. 9013 and 9014 (motion practice and contested matters) were not fetched, so nothing is asserted from them.

## Layout

- US Letter, 1-inch margins, one side. Double spaced (24 pt) body. Block quotations and the caption single spaced.
- Page 1: court title (three centred lines), debtor block (`In re:`, debtor name, case number and chapter at right), then the title in centred bold caps (one line per entry in `title`).
- Headings are written by the author as they appear in the filing: `# I. INTRODUCTION` centred bold caps; `## 1. The Court Should Find ...` left bold. The template does not number headings (unlike ca9).
- Paragraphs are not numbered; the first line is indented 0.5 inch, and so is the paragraph after a heading or a block quotation.
- Block quotations: a chunk starting with `>` is single spaced, indented 0.5 inch on both sides.
- Footnotes: `[^key]` in the body, and `[^key]: text` as a separate chunk; the definition is attached to the chunk that cites it.

## Markdown contract (for samples)

- YAML frontmatter: `court` (lines), `debtors` (list of `names`, `designation`), `case_number`, `chapter`, `title` (lines), `date`, `signature` (`preamble`, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading, `##` sub-heading, `>` block quotation, `[^key]: ...` footnote definition, or a paragraph. No tables, no raw typst.
- Dollar signs are escaped (`\$`). Case names are written with markdown italics where the author chooses (the sample uses none; see gaps).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env at ~/tb)
sh tools/render.sh courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief samples/INPUT-river-terrace-motion-brief.md
sh tools/overlay.sh courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/motion-brief river-terrace-motion-brief
```

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf`, and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`.

- Render: exit 0, no warnings. `pdffonts` shows EBGaramond-Regular and -Bold only, embedded.
- Overlay page map (word overlap): ours p.1 to p.5 with filed p.1 to p.5; ours p.6 with filed p.7; ours p.7 and p.8 with filed p.8; ours p.9 with p.9; ours p.10 with p.10; ours p.11 with filed p.12; ours p.12 and p.13 with filed p.13. The exemplar is set in Times with a different caption layout, so lines will not coincide. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 13 pages, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, debtor block, title, opening paragraph, heading I (begins) | Pass. The debtor name wraps to two lines (RIVER TERRACE ESTATES, / INC.) because the debtor column is narrow. Cosmetic; OPEN. |
| 2 | Introduction | Pass. |
| 3 | Introduction end, II. BACKGROUND FACTS | Pass. |
| 4 | Plan quotation (block, single spaced), the Bid Procedures list a to c | Pass. The list items are unnumbered paragraphs, as in the filing. |
| 5 | Bid Procedures item d, prior-to-bid facts, Exhibits A and B | Pass. |
| 6 | Exhibits C and D, December 30 facts | Pass. |
| 7 | December 31 facts, 12/31 e-mail, III. QUESTION PRESENTED (begins at foot) | Pass. The heading is kept with its paragraph. |
| 8 | Question presented, footnote 1 at foot, IV. ARGUMENT, sub-heading 1, footnote 2 | Pass. Footnote 1 and footnote 2 are at the foot of the page where they are cited. |
| 9 | Argument: Goldblatt and Doty authorities, debtor-in-possession duties, block quotation begins at foot | Pass. |
| 10 | Block quotation continues (Atlanta Packaging), then the Financial News discussion | Pass. |
| 11 | Argument on late bids, the balancing paragraphs | Pass. |
| 12 | Argument end, V. CONCLUSION | Pass. |
| 13 | Signature block alone | OPEN: the signature block does not fit at the foot of page 12 and moves to page 13 with no text above it. The block is unbreakable and the template has no keep-with-previous rule. The same defect as the adversary complaint. |

## Known gaps and open choices

1. **Motion not templated; B-7007-1(a) reading.** The rule says a motion "shall be accompanied by a separate supporting brief." The doc type's brief in the task was "motion with memorandum". This template follows the rule: a brief, filed separately. A combined motion-with-memorandum is not what B-7007-1 describes, so the motion (and the proposed order under B-9013-1(c)) belongs to another doc type or to a later pass. **Needs David's call** if a combined form is wanted.
2. **Caption and B-9013-1(a).** The rule says the requests are "named in the caption". The River Terrace brief names the request in the title block directly under the caption box, not inside the box. The template follows the filing. Whether a title block counts as "the caption" for this rule is a reading question; flagged, not decided.
3. **TOC and TOA not generated (B-7007-1(b)).** Only briefs over 25 pages need them, and the sample is 13 pages. The template has no page counter, so it cannot tell when the threshold is crossed. A brief over 25 pages filed from this template would be wrong until a TOC, statement of issues and table of authorities are added.
4. **Typeface and size (INNB-FORM-005).** As for the complaint: EB Garamond 13 pt, not Times. The exemplar is Times New Roman; no rule names a typeface or size for innb.
5. **Case names not italic.** The exemplar's text layer has italic runs (`TimesNewRoman,Italic` is embedded), so case names are italic in the filing. The sample transcribes them roman, because the italic runs were not measured one by one. The template italicises `*...*` markup if a sample adds it. Tier 2 finding.
6. **Certificate of service not generated.** The exemplar has none. Service rules were not checked; nothing is asserted about the certificate.
7. **Signature block.** The block moves to page 13 on its own (see the review table). The block is unbreakable, and nothing keeps the last paragraph with it. OPEN.
8. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers. The other innb motion candidates were read and not saved: Homman v. Schwartz (adv. 22-03010, Doc 4, 2-page motion for remand), Rudecki v. Price (adv. 11-03033, Doc 4, 5-page brief for a TRO, 2011), Homann v. One Advantage (adv. 22-03017, Doc 13, 4-page brief for default judgment). None is a combined motion with memorandum.
9. **Dated line.** The exemplar's "Dated:" line sits left of "Respectfully submitted,"; the template does the same (convention).
10. **Footnote 2 position.** The marker is placed after "§§ 105" (the superscript reads as "1052" in the text layer). Placement was taken from the glyph coordinates, not from the rule.
