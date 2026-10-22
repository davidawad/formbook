# nmid: motion brief

Doc type: **motion** (a motion to dismiss with its memorandum of points and authorities, one filed document) in the United States District Court for the Northern Mariana Islands (`nmid`).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 19-page memorandum: caption, lead-in, Background, Facts, Legal Standard, Argument IV.1, conclusion, signature; see Known gaps) |
| typeface | LR 5.2.a requires "12-point type or larger and in a serif font" and names no face. Font: Times New Roman (vendored, the house face; typst and docx alike). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, typst 0.15, vendored Times New Roman only, no warnings; `usage/OUTPUT-motion-brief.docx.pdf`, 10 pages, the same lines and pages (XENG gated). Re-rendered 2026-10-22. |
| overlay | fail (not re-run): `tools/overlay.sh` needs `usage/SAMPLE-*.pdf`, which is not in this snapshot. `usage/OVERLAY-ipi-motion-to-dismiss-memo.txt` is from an earlier run; no `OVERLAY-*.pdf` exists here. |
| pages reviewed | 9 of 9 (re-rendered and every page viewed as PNG at 60 dpi on 2026-10-15) |

File names follow the file roles in `CLAUDE.md` (`INPUT-` the markdown, `OUTPUT-` our render, `OVERLAY-` the comparison) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief ipi-motion-to-dismiss-memo
```

## Governing rules

Primary source: **D.N.M.I. Local Rules, 2017 "Final Redline"**, https://www.nmid.uscourts.gov/sites/nmid/files/LR2017-FinalRedline.pdf, read 2026-10-14 through the WebFetch tool (the court site refuses the box's HTTP client). The PDF is a redline; the rule text below is the inserted wording. **Which version is currently adopted could not be confirmed** (see Known gaps; same as `../complaint/README.md`).

Fed. R. Civ. P. 12(b) text: https://www.law.cornell.edu/rules/frcp/rule_12 (read 2026-10-14; the page's most recent amendment is dated Apr. 2, 2024, effective Dec. 1, 2024). Fed. R. Civ. P. 10(a) is in `../complaint/README.md`.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 5.2.a | 8.5 x 11 inch white paper; double-spaced numbering down the left margin; double-spaced text except block quotations, footnotes and headings; 12-point type or larger in a serif font; one-sided; pages numbered. | `page-w`, `page-h`, `lines-per-page`, `pitch`, `type-size`, `font-family`, `line-numbers()`, `pleading-rules()`, `footer-block` |
| LR 5.2.a | Margins: not less than 1.5 in top, 1 in bottom, 0.5 in right, 1 in left. | `top-margin = 1.5in`, `bottom-margin` (derived), `left-margin = 1in`, `right-margin = 0.5in` |
| LR 5.2.a | Upper right-hand corner of page one: three inches left blank. | The counsel block is 4.2 in wide at the upper left; nothing is set in the top-right corner (checked on page 1). |
| LR 5.2.c | Counsel identification upper left of page one, with bar identification number and the party represented. | `counsel` frontmatter (printed as given). |
| LR 5.2.d.1 | "IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN MARIANA ISLANDS", two lines, single-spaced, centered, at least 1.5 in from the top. | `court-title-lines`; starts on line 8 or later. |
| LR 5.2.d.2 | Title of the proceeding, left of center; the names of the parties. | `caption-block`, from `caption` (sides with `names` and `designation`); `versus` (default "v.") between sides. |
| LR 5.2.d.3 | File number, designation of the proceeding, title of the paper, right of the title of the proceeding. | Right column: "CIVIL CASE NO. ..." and `brief_title`. |
| LR 5.2.d.4 | The paper specifically identified. | `brief_title` |
| LR 5.2.e | Hearing date and time on the first page of every motion. | `hearing` (date, time, judge) in the caption's right column. The filed memorandum leaves the date and time blank; see Known gaps. |
| LR 5.2.b | Authorities not on Westlaw or Lexis must be attached as an exhibit. | Not checked by the template; the sample's footnote 1 cites the rule (`toa:lr52b`). |
| LR 7.1.d.1 | Briefs and memoranda supporting a motion: not more than 25 pages. Briefs over 10 pages: a table of contents and a table of authorities. Reply memoranda: 10 pages. | The template always produces both tables (`toc-section`, `toa-section`) and does not count pages. The sample is 9 pages. |
| LR 7.1.d.2 | Briefs conform to LR 5.2; insufficient margins or spacing can lead to the court striking text. | As LR 5.2.a above. |
| LR 7.1.b.1 | Motions are noticed for hearing not less than 35 days after filing (the redline's wording, 35 accepted). | Not produced (the notice of motion is a separate filing, ECF 61 in the exemplar). |
| Fed. R. Civ. P. 12(b) | Defenses by motion: (1) subject-matter jurisdiction, (6) failure to state a claim, and others; the motion "must be made before pleading". | The template produces the memorandum only; the defence list is the author's text. |

Not produced by this template: the notice of motion (a separate section of ECF 61), the proposed order (LR 7.1.b.4: e-mailed in Word format, not filed), declarations (LR 7.1.b.2), and the exhibit (LR 5.2.b). No certificate of service is generated; none is called for by the rules read.

## Layout

- Numbered lines 1 to 25 down the left margin, a double rule at the text's left edge and a single rule at its right (pleading form). 25 lines is what 8.5 in holds at 24 pt pitch between a 1.5 in top margin and a 1 in bottom margin.
- Page 1: counsel (single-spaced, lines 1 to 7 here), the court title, the caption with the file number, the title and the hearing lines, then the lead-in paragraph. The body of the memorandum does not start on page 1 (the exemplar's page 1 also carries only the lead-in).
- Page 2: table of contents. Page 3: table of authorities (generated from the `toa:` links; passim at 7 pages or more). The body starts on page 4, as in the exemplar.
- The cross-engine layout model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of its pitch with the baseline at 0.8 of it, as Word's exact line spacing. Body text, headings and the rows of both tables are on the 24 pt pitch of the numbered lines. Single-spaced lines (counsel, caption, signature, footnotes) are exactly 12 pt, half a numbered line, and every space between them is a multiple of it; each single-spaced block starts 9.6 pt lower (`lift`) so its baselines fall on the numbered lines' or halfway between two (a 12 pt line box puts its baseline 9.6 pt down, a 24 pt one 19.2 pt). No line sits a few points off a line number, so the numbers and the text read alike in every engine's PDF. Headings are sticky: a heading is never left at the foot of a page with its text on the next.
- Headings: level 2 "I." (roman), level 3 "1.", level 4 "a.", level 5 "(1)", all hanging their labels. Level 1 is a centered caps section (used for TOC and TOA only).
- Lists are lettered (a), (b), ... as in the complaint; the exemplar's Background list uses roman numerals (i) to (v).
- Footer: the paper's title (upper case), the case number, the page number centered above. The exemplar carries an ECF header at the top of each page and no footer title; the rules do not specify a footer.
- The signature block stays with the last paragraph (the conclusion): the last chunk and the signature are one unbreakable block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are blank-line separated: `##` a numbered section (level 2), `###` a sub-heading (level 3), `####` (level 4), a list (`1.` items, lettered by the template), or a paragraph. A `#` heading is a centered section (not used by the sample).
- Frontmatter: `case_number`; `caption` (list of sides: `names`, `designation`); `versus` (optional, default `v.`); `brief_title`; `footer_title`; `counsel` (lines, printed as given); `hearing` (`date`, `time`, `judge`); `lead_in` (optional, unnumbered, on page 1); `date`; `signature` (`preamble` lines, `signer`, `lines`); `authorities` (the registry: `key: {kind, name?, cite}`, kind one of `case`, `constitution`, `statute`, `rule`, `regulation`, `other`).
- Authorities: `[link text](toa:KEY)`. Every key used must be in `authorities`, or the build stops. Short forms and *Id.* can link to the same key.
- Footnotes: `text[^1]` in the body and `[^1]: text` as its own chunk, anywhere in the file (the template renders each chunk with all definitions, so a reference resolves wherever its definition sits). The footnote chunk is not body text.
- Escape square brackets in the filed text: `\[Plaintiff’s\]`, `\[c\]apacity`. Otherwise markdown reads them as link syntax.
- Not supported: tables, raw typst (`raw-typst` is off), numbered paragraphs typed by hand (the template numbers the headings; the paragraphs are unnumbered, as in the exemplar's memorandum body).

## Known gaps and open choices

1. **Which rules version applies.** The text is the 2017 Final Redline (see the complaint's gap 1). The current adopted version was not confirmed. **Needs David's check of the court's posted local rules.**
2. **Hearing date and time (LR 5.2.e).** The exemplar leaves them blank ("Hearing Date: ____"), so the sample does too. A filed motion needs them; the template prints what is given and does not invent them.
3. **Bar identification number (LR 5.2.c).** Not printed in the exemplar's counsel block; the sample prints the counsel block as filed.
4. **Font.** Times New Roman at 12 pt (the minimum in LR 5.2.a), in typst and docx alike (the docx named EB Garamond until fb-595.68.24). The 2017 Final Redline text: "All text must be in 12-point type or larger and in a serif font"; no face is named, so the house face applies, which is also the exemplar's.
5. **Sub-headings in III.** The exemplar leaves "Party Standard", "Pleading Standard", "Subject Matter Jurisdiction Standard" and "Failure to State a Claim Standard" unnumbered; the template numbers them 1. to 4. (a convention choice, flagged).
6. **Background list.** Roman numerals in the exemplar; (a) to (e) here.
7. **Partial sample.** The sample transcribes Background, Facts, Legal Standard, Argument IV.1 with footnotes 1 and 2, and the conclusion and signature. It does not transcribe Argument IV.2 to IV.6 (the sovereign immunity, ripeness, res judicata, and agency arguments), footnote 3, or the notice of motion. The table of authorities therefore lists only what the sample cites. The 19-page exemplar's remaining pages are not in this sample, so the overlay compares the first pages only; the overlay is a diagnostic, not a score.
8. **Errors kept verbatim from the filing.** The sample reproduces the filing as filed, so these are the filing's and not the template's: "Ramirez v. County of San Bernadino" (the case is *San Bernardino*); "*Levin Metals Corp.*, 817 F.2d 1448 ... (9th Cir. 1897)" (the year looks wrong for an 817 F.2d volume, which dates to the 1980s; not checked against the reporter); "Defendants respectfully moves"; "Capital Hill" (Capitol Hill?); "Order No: 2021-002"; "Plaintiff raise force majeure"; "this mooted the all prior Motions". Not corrected in the transcription. An unbalanced parenthesis in Background item 2 is also as filed.
9. **Footnote placement.** The exemplar's footnote 1 hangs from the Argument heading; here it hangs from the end of the first Argument paragraph (a footnote in a heading is not supported by the template).
10. **Hearing lines.** The judge's line reads "Hon. Judge David Carter" as filed.
11. **Page limit.** The template does not count pages; LR 7.1.d.1's 25-page limit is for the author. The exemplar's memorandum is 19 pages.
12. **Tier 2 exemplars.** One filer only. EVAL-LOOP's tier-2 rule asks for two or three; not met.
13. **Check gates.** `tools/check.sh <this folder>` and `--engine docx` run the gates (0 failed on both; XENG-001..003 gated, `params.cross_engine: gate` in `eval.yaml`). `tools/check-selftest.sh` takes a court root and does not run on this doc-type folder.
14. **Overlay pairing.** The overlay pairs sample pages to the exemplar's pages by word overlap (see `OVERLAY-ipi-motion-to-dismiss-memo.txt`); the exemplar's line numbers and Word layout differ from the render, so text lines do not coincide. Diagnostic only.
15. **Search record.** CourtListener search API (`court=nmid`, `type=r`), motions to dismiss with a memorandum: this memorandum (chosen); Laramie Fealty (1:08-cv-00028, Doc 4, 24 pp., 2008, not fetched); Fanter (1:20-cv-00003, reply only in results). The court site and courtrules.net were not usable from the box.

## Visual review (Gate 2 record: all 10 pages of each engine, rendered at 50 and 80 dpi and viewed, 2026-10-22)

The typst and the docx renders set every line and page alike (XENG-001..003 pass), so one table serves both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1 to 7), court title (lines 8 and 9), caption with file number, title and hearing lines, the lead-in | OK. Counsel and caption lines on the numbered lines or halfway between; the lead-in on lines 17 to 19; nothing in the top-right three inches. |
| 2 | Table of contents, with the wrapped entry "Plaintiff, Best Sunshine ..." on two numbered lines | OK. Dot leaders run to the page column; page numbers right-aligned. |
| 3 | Table of authorities: Cases, Rules, Other Authorities | OK. No authority reaches 7 pages, so no "passim". |
| 4 | I. Background, 1. and 2., the list (a) to (e) | OK. "(§§ 175-10.1-610(b)" kept whole (it was split between the two signs). |
| 5 | Background 2 end, 3. and 4. | OK. |
| 6 | Background 4 end, 5. Recent Developments | OK. |
| 7 | II. Facts, III. Legal Standard, 1. and 2. | OK. |
| 8 | III. 2 end, 3. and 4., IV. Argument, the two-line heading IV.1 | OK. The two-line heading takes two numbered lines, kept with its paragraph. |
| 9 | IV.1 continued, footnotes 1 and 2 at the foot | OK. The paragraph's last line "Corporations)." opens the page with footnote 1, as typst sets a line whose note does not fit (docx: that paragraph without widow control). |
| 10 | V. Conclusion, date, signature block | OK. The conclusion and the signature block on one page. |

Reviewed pages: 10 of 10 (typst) and 10 of 10 (docx).

## Engines

**docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt, Body Text in exact 24 pt lines, single lines 12 pt, footnotes 12 pt in 12 pt lines) and `docx/nmid-motion-brief.lua`, which writes the cover, the table of contents and the table of authorities, the headings with their labels, the lettered items, the signature block, the section (letter; margins 1.5 in top, 84 pt bottom, 1 in left, 0.5 in right) and its footer: the page number, the paper's title and the case number from the frontmatter, the numbered lines 1 to 25 in a text box and the three pleading rules as lines, both anchored to the page. No shell: `fb render` builds the reference document and runs the passes (the tables' page numbers come from needles found in the LibreOffice PDF: a citation by its text and the words after it, a heading by the first words of the block it is kept with, since pdftotext may read a heading's tabbed title out of order). Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, 10 pages, as typst.

- Matches typst line for line and page for page (XENG-001..003, gated).
- Differs: the tables are text with dot leaders, not TOC/TOA fields (LibreOffice does not honour TA/TOA fields); their page numbers are LibreOffice's pagination, and Word may place a line differently. The footnote separator is 2 in long (typst 30 % of the text width).
