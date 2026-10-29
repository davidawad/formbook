# nmid: motion brief

Doc type: **motion** (a motion to dismiss with its memorandum of points and authorities, one filed document) in the United States District Court for the Northern Mariana Islands (`nmid`).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 19-page memorandum: caption, lead-in, Background, Facts, Legal Standard, Argument IV.1, conclusion, signature; see Known gaps) |
| typeface | LR 5.2.a requires "12-point type or larger and in a serif font" and names no face. Font: Times New Roman (vendored, the house face; typst and docx alike). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 10 pages each (typst 0.15.0, pdfLaTeX, LibreOffice), no warnings (2026-10-29, on the shared document model, fb-595.96) |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 10 of 10 on each engine rendered to PNG at 60 dpi (30 images, `.overlay/`); read by their text layout and line geometry (2026-10-29: the image viewer of the agent pod could not open them; see Visual review) |

File names follow the file roles in `CLAUDE.md` (`INPUT-` the markdown, `OUTPUT-` our render, `OVERLAY-` the comparison) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Build

```sh
D=courts/ninth-circuit/northern-mariana-islands/federal/district/motion-brief
for e in typst latex docx; do sh tools/render.sh --engine $e $D usage/INPUT-motion-brief.md; done
for e in typst latex docx; do sh tools/check.sh $D --engine $e; done
just overlay $D   # -> .overlay/<doc path>/OVERLAY-motion-brief.pdf and .txt (not committed)
```

## Governing rules

Primary source: **D.N.M.I. Local Rules, 2017 "Final Redline"**, https://www.nmid.uscourts.gov/sites/nmid/files/LR2017-FinalRedline.pdf, read 2026-10-14 through the WebFetch tool (the court site refuses the box's HTTP client). The PDF is a redline; the rule text below is the inserted wording. **Which version is currently adopted could not be confirmed** (see Known gaps; same as `../complaint/README.md`).

Fed. R. Civ. P. 12(b) text: https://www.law.cornell.edu/rules/frcp/rule_12 (read 2026-10-14; the page's most recent amendment is dated Apr. 2, 2024, effective Dec. 1, 2024). Fed. R. Civ. P. 10(a) is in `../complaint/README.md`.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 5.2.a | 8.5 x 11 inch white paper; double-spaced numbering down the left margin; double-spaced text except block quotations, footnotes and headings; 12-point type or larger in a serif font; one-sided; pages numbered. | layout.yaml `pleading.lines: 25`, `pitch.body: 24`, the base's 12 pt; `page_number` (pages numbered as one); Times New Roman (typst/nmid-motion-brief.typ) |
| LR 5.2.a | Margins: not less than 1.5 in top, 1 in bottom, 0.5 in right, 1 in left. | layout.yaml `margin: {top: 108, bottom: 84, left: 72, right: 36}` |
| LR 5.2.a | Upper right-hand corner of page one: three inches left blank. | The counsel box is 4.2 in wide at the upper left (`width: 302.4`); nothing is set in the top-right corner (checked on page 1). |
| LR 5.2.c | Counsel identification upper left of page one, with bar identification number and the party represented. | `counsel` frontmatter (printed as given). |
| LR 5.2.d.1 | "IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN MARIANA ISLANDS", two lines, single-spaced, centered, at least 1.5 in from the top. | `constants` court and district, single-spaced (12 pt lines) a numbered line below the counsel box (at least seven numbered lines high), so on line 8 or later. |
| LR 5.2.d.2 | Title of the proceeding, left of center; the names of the parties. | the cover's caption columns, from `caption` (sides with `names` and `designation`); `versus` (default "v.") between sides. |
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

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`) with D.N.M.I.'s rules overlaid in `typst/layout.yaml`, set by the shared document model (`lib/typst/xdoc.typ`; `latex/` and `docx/` generated by `fb engines gen`, fb-595.96).

- Pleading paper (layout.yaml `pleading`): the numbers 1 to 25 down the left margin, right-aligned 0.3 in left of the text, one per 24 pt numbered line from the 1.5 in top margin (25 lines is what the page holds between the 1.5 in top and the 1 in bottom margins); a double rule just left of the text and a single one just right of it. `eval.yaml` params.pleading_lines: 25 drops the numbers from the text the checks read.
- Page 1 (`cover`): counsel single-spaced in a 4.2 in box at least seven numbered lines high, the court title single-spaced (LR 5.2.d.1) a numbered line below, the caption (parties left of centre with "vs.", ruled at the right and foot; "CIVIL CASE NO.", the title in bold and the hearing lines at the right), then the lead-in paragraph.
- Page 2: table of contents ("Page" over the column); page 3: table of authorities (keyed, from the `toa:` links; passim at 7 pages or more). The body starts on page 4, as in the exemplar; the pages are numbered as one.
- Headings at the body pitch, numbered by the layout: level 1 "I.", level 2 "1.", level 3 "a.", level 4 "(1)", each half an inch further in, the label in a half-inch box.
- Lists half an inch in, numbered as the sample writes them ("1."); the exemplar's Background list uses roman numerals (i) to (v), the old template lettered them (a) to (e).
- Footer: the page number centred; under it the paper's title (`footer_title`, in capitals as filed) at the left and "CASE NO." with the case number at the right of one line, 10 pt, the last line 0.4 in above the foot.
- The signature block stays with the last paragraph (the base's keep_with_closing).

## Markdown contract (for samples)

- YAML frontmatter, then the body: `#` a numbered section (I.), `##` a sub-heading (1.), `###` (a.), `####` ((1)); paragraphs; `1.` lists; footnotes. Do not type the heading numbers.
- Frontmatter: `case_number`; `caption` (list of sides: `names`, `designation`); `versus` (optional, default `v.`); `brief_title` (as filed); `footer_title` (in capitals); `counsel` (lines, printed as given); `hearing` (`date`, `time`, `judge`); `lead_in`; `date`; `signature` (`preamble`, `signer`, `lines`); `authorities` (keyed: `{kind, name, cite}`, kinds case, constitution, statute, rule, regulation, other).
- Authorities: `[link text](toa:KEY)`. Every key used must be in `authorities`, or the build stops.
- Escape square brackets in the filed text: `\[Plaintiff’s\]`, `\[c\]apacity`.

## Known gaps and open choices

1. **Which rules version applies.** The text is the 2017 Final Redline (see the complaint's gap 1). The current adopted version was not confirmed. **Needs David's check of the court's posted local rules.**
2. **Hearing date and time (LR 5.2.e).** The exemplar leaves them blank ("Hearing Date: ____"), so the sample does too. A filed motion needs them; the template prints what is given and does not invent them.
3. **Bar identification number (LR 5.2.c).** Not printed in the exemplar's counsel block; the sample prints the counsel block as filed.
4. **Font.** Times New Roman at 12 pt (the minimum in LR 5.2.a), in every engine (the docx named EB Garamond until fb-595.68.24). The 2017 Final Redline text: "All text must be in 12-point type or larger and in a serif font"; no face is named, so the house face applies, which is also the exemplar's.
5. **Sub-headings in III.** The exemplar leaves "Party Standard", "Pleading Standard", "Subject Matter Jurisdiction Standard" and "Failure to State a Claim Standard" unnumbered; the template numbers them 1. to 4. (a convention choice, flagged).
6. **Background list.** Roman numerals in the exemplar; 1. to 5. here, as the sample writes them (the model sets a list's own numbers; the old template lettered them (a) to (e)). Tier 3.
7. **Partial sample.** The sample transcribes Background, Facts, Legal Standard, Argument IV.1 with footnotes 1 and 2, and the conclusion and signature. It does not transcribe Argument IV.2 to IV.6 (the sovereign immunity, ripeness, res judicata, and agency arguments), footnote 3, or the notice of motion. The table of authorities therefore lists only what the sample cites. The 19-page exemplar's remaining pages are not in this sample, so the overlay compares the first pages only; the overlay is a diagnostic, not a score.
8. **Errors kept verbatim from the filing.** The sample reproduces the filing as filed, so these are the filing's and not the template's: "Ramirez v. County of San Bernadino" (the case is *San Bernardino*); "*Levin Metals Corp.*, 817 F.2d 1448 ... (9th Cir. 1897)" (the year looks wrong for an 817 F.2d volume, which dates to the 1980s; not checked against the reporter); "Defendants respectfully moves"; "Capital Hill" (Capitol Hill?); "Order No: 2021-002"; "Plaintiff raise force majeure"; "this mooted the all prior Motions". Not corrected in the transcription. An unbalanced parenthesis in Background item 2 is also as filed.
9. **Footnote placement.** The exemplar's footnote 1 hangs from the Argument heading; here it hangs from the end of the first Argument paragraph (a footnote in a heading is not supported by the template).
10. **Hearing lines.** The judge's line reads "Hon. Judge David Carter" as filed.
11. **Page limit.** LR 7.1.d.1's 25 pages are the memorandum's; the sample renders to 10. The exemplar's memorandum is 19 pages.
12. **Tier 2 exemplars.** One filer only. EVAL-LOOP's tier-2 rule asks for two or three; not met.
13. **Check gates.** `tools/check.sh <this folder>` runs on typst, latex and docx (0 failed on each; XENG-001..003 gated, `params.cross_engine: gate`; `pleading_lines: 25`).
14. **Overlay pairing.** The overlay pairs sample pages to the exemplar's pages by word overlap (see `OVERLAY-ipi-motion-to-dismiss-memo.txt`); the exemplar's line numbers and Word layout differ from the render, so text lines do not coincide. Diagnostic only.
15. **Search record.** CourtListener search API (`court=nmid`, `type=r`), motions to dismiss with a memorandum: this memorandum (chosen); Laramie Fealty (1:08-cv-00028, Doc 4, 24 pp., 2008, not fetched); Fanter (1:20-cv-00003, reply only in results). The court site and courtrules.net were not usable from the box.

## Visual review (Gate 2 record, 2026-10-29)

After the move onto the shared model (fb-595.96): every page of the three renders (10 typst, 10 latex, 10 docx: 30 pages) rasterized at 60 dpi with pdftoppm into `.overlay/`. The agent's image viewer could not open the PNGs in its pod, so each page was read by its text layout (`pdftotext -layout`) and its line geometry (`fb measure`); a look at the images themselves is left to the reviewer (PR). The three engines break every line and page alike (XENG-001..003 PASS).

| Page | What it is | Finding (all three engines) | Status |
|---|---|---|---|
| 1 | Counsel (lines 1 to 6), court title (lines 8 and 9, single-spaced), caption with file number, title and hearing lines, the lead-in | OK. The caption's first row reads centred in the exemplar (accepted in eval.yaml for DEF-COVER-002). | OK |
| 2 | Table of contents, "Page", the two-line entry IV.1 | OK. | OK |
| 3 | Table of authorities: Cases, Rules, Other Authorities | OK. | OK |
| 4-6 | I. Background, 1. to 5., the list 1. to 5. | OK. "(§§ 175-10.1-1805(b)(15)" kept with its number in every engine. | OK |
| 7-9 | II. Facts, III. Legal Standard, IV. Argument, footnotes 1 and 2 | OK. | OK |
| 10 | V. Conclusion, date, signature block | OK. | OK |
| all | Footer: number; title at the left, case number at the right | OK. | OK |

Reviewed pages: 10 of 10 on each engine (30).

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.96): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/nmid-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua` (`docx/nmid-motion-brief.lua` is gone; the LaTeX engine is new). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`).

`sh tools/check.sh <dir>`: typst 10 passed, 0 failed; `--engine latex`: 14 passed, 0 failed; `--engine docx`: 15 passed, 0 failed; XENG-001..003 PASS on both. Not verified in Word (LibreOffice only).

[Parent: northern-mariana-islands/federal/district](../README.md)
