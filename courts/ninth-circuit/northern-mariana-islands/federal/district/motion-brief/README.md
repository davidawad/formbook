# nmid: motion brief

Doc type: **motion** (a motion to dismiss with its memorandum of points and authorities, one filed document) in the United States District Court for the Northern Mariana Islands (`nmid`).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-imperial-pacific-24-cv-00001-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-ipi-motion-to-dismiss-memo.md` (a portion of the 19-page memorandum: caption, lead-in, Background, Facts, Legal Standard, Argument IV.1, conclusion, signature; see Known gaps) |
| typeface | LR 5.2.a requires "12-point type or larger and in a serif font" and names no face. Font: EB Garamond (vendored; no substitute needed). |
| render | ok: `samples/OUTPUT-ipi-motion-to-dismiss-memo.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular, -Bold, -Italic), no warnings. Re-rendered 2026-10-15. |
| overlay | fail (not re-run): `tools/overlay.sh` needs `exemplars/FILED-EXAMPLE-*.pdf`, which is not in this snapshot. `samples/OVERLAY-ipi-motion-to-dismiss-memo.txt` is from an earlier run; no `OVERLAY-*.pdf` exists here. |
| pages reviewed | 9 of 9 (re-rendered and every page viewed as PNG at 60 dpi on 2026-10-15) |

File names follow the file roles in `CLAUDE.md` (`INPUT-` the markdown, `OUTPUT-` our render, `OVERLAY-` the comparison) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief samples/INPUT-ipi-motion-to-dismiss-memo.md
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
- Page 1: counsel (single-spaced, lines 1 to 9 here), the court title, the caption with the file number, the title and the hearing lines, then the lead-in paragraph. The body of the memorandum does not start on page 1 (the exemplar's page 1 also carries only the lead-in).
- Page 2: table of contents. Page 3: table of authorities (generated from the `toa:` links; passim at 7 pages or more). The body starts on page 4, as in the exemplar.
- Every block of text is a whole number of 24 pt rows. Each body chunk (paragraph, list or heading) is rounded up to whole numbered lines (`on-grid`), so the body stays on the grid. Headings are sticky: a heading is never left at the foot of a page with its text on the next.
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
4. **Font.** EB Garamond at 12 pt (the minimum in LR 5.2.a). Checked 2026-10-15 against the 2017 Final Redline text: "All text must be in 12-point type or larger and in a serif font"; no face is named, so `docs/FONTS.md` keeps EB Garamond. It has a smaller x-height than the exemplar's Times New Roman, so the text reads smaller; that is the filer's choice (tier 3), not a rule, so it is not chased.
5. **Sub-headings in III.** The exemplar leaves "Party Standard", "Pleading Standard", "Subject Matter Jurisdiction Standard" and "Failure to State a Claim Standard" unnumbered; the template numbers them 1. to 4. (a convention choice, flagged).
6. **Background list.** Roman numerals in the exemplar; (a) to (e) here.
7. **Partial sample.** The sample transcribes Background, Facts, Legal Standard, Argument IV.1 with footnotes 1 and 2, and the conclusion and signature. It does not transcribe Argument IV.2 to IV.6 (the sovereign immunity, ripeness, res judicata, and agency arguments), footnote 3, or the notice of motion. The table of authorities therefore lists only what the sample cites. The 19-page exemplar's remaining pages are not in this sample, so the overlay compares the first pages only; the overlay is a diagnostic, not a score.
8. **Errors kept verbatim from the filing.** The sample reproduces the filing as filed, so these are the filing's and not the template's: "Ramirez v. County of San Bernadino" (the case is *San Bernardino*); "*Levin Metals Corp.*, 817 F.2d 1448 ... (9th Cir. 1897)" (the year looks wrong for an 817 F.2d volume, which dates to the 1980s; not checked against the reporter); "Defendants respectfully moves"; "Capital Hill" (Capitol Hill?); "Order No: 2021-002"; "Plaintiff raise force majeure"; "this mooted the all prior Motions". Not corrected in the transcription. An unbalanced parenthesis in Background item 2 is also as filed.
9. **Footnote placement.** The exemplar's footnote 1 hangs from the Argument heading; here it hangs from the end of the first Argument paragraph (a footnote in a heading is not supported by the template).
10. **Hearing lines.** The judge's line reads "Hon. Judge David Carter" as filed.
11. **Page limit.** The template does not count pages; LR 7.1.d.1's 25-page limit is for the author. The exemplar's memorandum is 19 pages.
12. **Tier 2 exemplars.** One filer only. EVAL-LOOP's tier-2 rule asks for two or three; not met.
13. **Check gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`; this doc-type folder is not that shape and `tools/` is off limits in this unit. Render and overlay ran; the review below is the Gate 2 record.
14. **Overlay pairing.** The overlay pairs sample pages to the exemplar's pages by word overlap (see `OVERLAY-ipi-motion-to-dismiss-memo.txt`); the exemplar's line numbers and Word layout differ from the render, so text lines do not coincide. Diagnostic only.
15. **Search record.** CourtListener search API (`court=nmid`, `type=r`), motions to dismiss with a memorandum: this memorandum (chosen); Laramie Fealty (1:08-cv-00028, Doc 4, 24 pp., 2008, not fetched); Fanter (1:20-cv-00003, reply only in results). The court site and courtrules.net were not usable from the box.

## Visual review (Gate 2 record: all 9 pages, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1 to 9), court title, caption with file number, title and hearing lines, the lead-in | OK after fixes. Caption and counsel do not overlap; the lead-in is on page 1 in full. Blank lines 20 to 25 below the lead-in (the table of contents starts on page 2). |
| 2 | Table of contents (page 2), with the wrapped entry "Plaintiff, Best Sunshine ..." | OK after a fix: the wrapped entry is sized to two lines; it no longer runs into the next entry. |
| 3 | Table of authorities: Cases, Rules, Other Authorities | OK. Entries on the grid, page references right-aligned, "passim" not needed (no authority reaches 7 pages). |
| 4 | Background, sub-headings 1 and 2, list (a) to (e) | OK after fixes: paragraphs no longer overlap the list; the first line is indented. |
| 5 | Background 3 and 4 | OK. Footnote-free page; "Id." italics. |
| 6 | Background 4 end, 5 (Recent Developments), II. Facts begins | OK. Heading "II. Facts" kept with its paragraph. |
| 7 | Facts end; III. Legal Standard (1 to 2) | OK. Brackets in quotations shown as filed. |
| 8 | III (3 and 4), IV. Argument, IV.1 heading (two lines) and paragraphs; footnote 1 at foot | OK after fix: the two-line heading takes two numbered lines. Footnote 1 sits at the foot of the page. |
| 9 | IV.1 end, V. Conclusion, date, signature block, footnote 2 at foot | OK. The signature block is with the conclusion; "Respectfully submitted" and the firm are right-aligned. |

Reviewed pages: 9 of 9.

## Engines

**docx** (`docx/`): `reference.docx` (`docx/build-reference.sh`), `docx/nmid-motion-brief.lua` (cover, table of contents, table of authorities, headings with their labels, lettered items, signature block), and `docx/render.sh`, which runs two passes: pass 1 writes the search index and is converted to PDF to find the page of each heading and each authority; pass 2 writes the docx with those page numbers (it fails if pass 2 paginates differently). Output: `samples/OUTPUT-ipi-motion-to-dismiss-memo.docx` and `.docx.pdf` (10 pages; typst is 9).

- Matches typst: US Letter; the same margins and 25-line grid; EB Garamond 12 pt, exact 24 pt double spacing; the cover (counsel, court title, caption with the hearing lines, lead-in); a page break before the table of contents and the table of authorities; heading labels I., 1., a., (1) with hanging indents; footnotes in 12 pt single spacing; signature block; footer.
- Differs: the table of contents and table of authorities are written as text with dot leaders and page numbers from the first pass, not as TOC/TOA fields (LibreOffice does not honour TA/TOA fields; Word will not update these, so a field update in Word leaves them as they are); page numbers are LibreOffice's pagination, and Word may place a line differently; the conclusion heading, its paragraph and the signature block are kept together, so page 9 ends with a gap and the conclusion starts page 10 (typst fits them on page 9); the pleading rules and the line-number box are as in the complaint; passim is used for an authority on 7 or more pages.
- Fonts: as in the complaint, LibreOffice needs the vendored EB Garamond visible.
- Visual review: 10 of 10 pages of `OUTPUT-ipi-motion-to-dismiss-memo.docx.pdf` rendered at 60 dpi and viewed (2026-10-15). Open defects: none. Page 3 (table of authorities) was viewed after the page-number fix; the other pages' text is identical to the reviewed render.
- `tools/check.sh` cannot run on this folder (same reason as the complaint). No `.check-docx.txt` stamp is written.

BLOCKED: check.sh (all gates, docx): `tools/check.sh <doc-type dir> --engine docx` exits 2 on a doc-type folder (no `court.json` / `checks.yaml` / `rules.md` there); the docx was checked by the visual review above, not by the gates.
