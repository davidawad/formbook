# W.D. Tex. (txwd): motion brief

Doc type: **motion with brief in support** (a Rule 12(b) motion to dismiss and the brief in one document) in the United States District Court for the Western District of Texas (`txwd`).
Folder: `courts/fifth-circuit/texas/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `exemplars/FILED-EXAMPLE-lulac-1-26-cv-00729-motion-brief.pdf` (Dallas County Election Administrator's Rule 12 motion and brief, 22 pages). See `exemplars/SOURCE.md`. The second-filer check is not met: see gap 1. |
| sample md | `samples/INPUT-lulac-rule-12-motion-to-dismiss.md` (an excerpt: cover, table of contents, introduction, grounds, argument A, B.1 to B.3, part of C, prayer, signature block, certificate of service). |
| typeface | face required: none (CV-10(a) names no face). Substitute: none needed; **EB Garamond** kept (`docs/FONTS.md`, "No face named"). Embedded: EB Garamond Regular and Bold only (`pdffonts`, 2026-10-14). |
| render | ok: `samples/OUTPUT-lulac-rule-12-motion-to-dismiss.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-14). |
| overlay | ok: `samples/OVERLAY-lulac-rule-12-motion-to-dismiss.pdf` and `.txt` (see "Overlay"), regenerated 2026-10-14 against `exemplars/FILED-EXAMPLE-lulac-1-26-cv-00729-motion-brief.pdf`. That PDF was missing from the checkout and was fetched from the URL in `exemplars/SOURCE.md`. |
| pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed on the final build; all 14 viewed again on the 2026-10-14 re-render). |
| gates | `tools/check.sh` not run: it expects a court folder with `court.json` and `rules.md`, which this doc-type folder does not have, and the brief forbids editing `tools/`. |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| W.D. Tex. Local Rule CV-10(a) | Typed or printed in 12-point or larger font (including footnotes), double-spaced, on 8½ × 11 paper, one-inch margins on all sides; endorsed with the style of the case and the descriptive name of the document. Headings, footnotes and quotations more than two lines long may be single-spaced. | `page` (us-letter, 1 in margins), `type-size = 13pt`, `body-leading` (2.0 em pitch), `title`, `caption`. |
| W.D. Tex. Local Rule CV-10(b) | Represented party: attorney's mailing address, e-mail, signature, state bar card number, telephone and fax numbers, including area code. | `signature-block` (`firm`, `signer`, `lines`). |
| W.D. Tex. Local Rule CV-7(a) | A motion must meet CV-10. | As CV-10 above. |
| W.D. Tex. Local Rule CV-7(c)(1) | Legal authority in support of a motion is cited in the motion, not a separate brief; the motion states its grounds and cites the rule or statute justifying the relief. | Author content: the sample has the brief inside the motion (one document). |
| W.D. Tex. Local Rule CV-7(c)(2) | Other motions are limited to 20 pages, exclusive of the caption, signature block, any certificate and accompanying documents. | Not counted by the template. The sample's body runs from page 3 to page 13 (11 pages including the prayer), inside the limit. |
| W.D. Tex. Local Rule CV-7(g) | Conference is required only for nondispositive motions. A Rule 12(b) motion is dispositive, so no certificate of conference is generated. | Not generated. |
| Fed. R. Civ. P. 7(b)(1) | A motion must state with particularity the grounds for seeking the order. | The grounds list (`# II. GROUNDS FOR RELIEF`) in the sample; the template does not check the content. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served through the court's electronic filing system; the exemplar still includes one. | `certificate` (optional, from the frontmatter). |

Not produced by this template: a proposed order (required for discovery and case-management motions, CV-7(f), not for this motion); the certificate of conference (CV-7(g)); the TOA (see gap 2).

## Layout

- Cover page: court title (centred bold, three lines), caption with the § column on every row, the case number on its own row, and the document title (centred bold).
- Table of contents on page 2: generated from the headings by typst's `outline` (levels 1 to 3, dot leaders). The author types the numbers ("I.", "A.", "1.") in the headings, as the exemplar does; the template does not number headings.
- Body from page 3: double spacing (2.0 em pitch, 26 pt at 13 pt), paragraph spacing equal to the leading, first-line indent 0.5 in, body paragraphs not numbered.
- Headings: level 1 centred bold capitals; level 2 and level 3 left bold, single-spaced, kept with the text after them.
- Block quotations (`> `): single-spaced, indented 0.5 in on both sides.
- Lists: numbered grounds with bullet sub-items; bullets for the "La Union" and "Plaintiffs aver" lists.
- Signature block: "Respectfully submitted," then the firm lines, then "/s/" with the signer, then the counsel lines (single-spaced, at the right, as in the exemplar).
- Certificate of service: centred bold heading, the paragraph, signature at the right; kept together on one page.
- Footer: centred page number (arabic throughout; the exemplar's cover and contents are roman-numbered, see gap 5).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (lines, centred bold); `caption` (rows; a row is `[left]` or `[left, right]`; the template adds § on every row; a `right` cell carries the case number); `title`; `toc_title`; `signature` (`firm` lines before the `/s/` line, `signer`, `lines` after it; `""` is a blank line); `certificate` (`heading`, `text`, `signer`, `lines`).
- Body chunks are separated by blank lines: `#` level-1 heading, `##` level-2, `###` level-3 (all typst headings, so they reach the TOC); `> ` a block quotation; `- ` or `1.` a list; anything else a body paragraph.
- Not supported: tables, footnotes (none in the sample), raw typst, the TOA.

## Overlay

`sh tools/overlay.sh <court-dir> lulac-rule-12-motion-to-dismiss <exemplar.pdf>`. The exemplar is passed explicitly, as for the complaint folder, although this folder has one exemplar.

- The tool writes `samples/OVERLAY-<id>.pdf` and `.txt`, not the `<id>-overlay.*` names in the brief (the tool was not changed; file roles follow CLAUDE.md).
- Page map (word-overlap pairing): ours p.1-2 ↔ filed p.1-2; ours p.3-4 ↔ filed p.7 and p.9; ours p.5-12 ↔ filed p.10-18; ours p.14 ↔ filed p.22 (the certificate). Ours p.13 is paired with filed p.1 by word overlap; that is an artifact (the prayer and signature page shares words with the cover block) and not a layout match.
- The overlay is a diagnostic, not a score: the filing has footnotes, Roman-numeral front matter and a TOA the sample does not reproduce.

## Review of the rendered pages (Gate 2 record; every page viewed at 60 dpi on the final build)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption with § column, case number, title | OK after the fix for the wrapped party line ("LEAGUE OF LATIN AMERICAN CITIZENS, et al.," split into two rows, as in the exemplar). |
| 2 | Table of contents (levels 1 to 3, dot leaders, page numbers) | OK. Entries wrap under their heading with a hanging indent. |
| 3 | Introduction and the start of the grounds | OK. Double spacing; heading centred. |
| 4 | Grounds for relief: items 1 to 3 with bullet sub-items | OK. Numbered items indented, bullets at the second level. |
| 5 | Ground 4 (wrapped), III. ARGUMENT heading, A. heading (level 2, bold), start of argument A, heading A.1 | OK after the heading-size fix. Level-2 and level-3 headings at body size, bold. |
| 6 | Argument A.1 continued: block quotation (single-spaced, indented), citation, B. and B.1 headings | OK. The quotation is single-spaced and indented as the exemplar's. |
| 7 | B.1 continued: standing authorities | OK. |
| 8 | B.1: "La Union" bullets, the Fifth Circuit paragraphs | OK. |
| 9 | B.1: the Dallas County bullets and the conclusion of B.1 | OK. |
| 10 | B.2 and B.3 headings, B.3 start | OK. |
| 11 | B.3 continued, C. heading, political question start | OK. |
| 12 | C: the six-factor block quotation, the Baker passage, last paragraph (ends with "…", see gap 3) | OK. |
| 13 | IV. PRAYER, "Respectfully submitted," firm block, /s/ signer, counsel lines | OK after the reorder: the firm block precedes the /s/ line, as in the exemplar. |
| 14 | Certificate of service with /s/ signer | OK. The certificate is kept whole on its own page; the exemplar keeps it on the signature page. |

Reviewed pages: 14 of 14.

## Known gaps and open choices

1. **One filer.** EVAL-LOOP tier 2 asks for two or three filers. The search found other txwd motions (see `exemplars/SOURCE.md`), but none was downloaded and checked for structure in this pass. The tier-2 comparison is against one filing only.
2. **No table of authorities.** The exemplar has a TOA (pages iii to iv). The template does not generate one: it would need page numbers per authority, which the markdown does not carry (the ca9 template's `toa:` links are not used here). The TOA is not required by W.D. Tex. CV-7 or CV-10.
3. **Sample is an excerpt.** The Baker-factors passage ends with an ellipsis ("U.S. Const. art. I, § 4 …"): the exemplar's text continues past what was transcribed. Argument C's remainder, D and E, and the footnotes are not transcribed. The sample is 14 pages with the cover and contents; the filing is 22.
4. **Footnotes.** The exemplar has footnotes (for example, the note on Administrator Adams's title and the note on Secretary Nelson's resignation). They are omitted from the sample. The template has no footnote rule; CV-10(a) requires 12 pt or larger for footnotes, which 13 pt satisfies, but the footnote layout is untested.
5. **Front matter numbering.** The exemplar numbers the cover and contents with Roman numerals (the TOC is page iii onward in the filing); the render numbers every page in Arabic. No rule requires either.
6. **Justification.** Body text is left-aligned (ragged right). The exemplar's justification could not be read from the text layer; not asserted.
7. **Font.** EB Garamond (vendored, OFL), 13 pt. The exemplar is Times New Roman 12 pt, but CV-10(a) names no face (it requires only "12-point or larger"), so no court-named substitute applies and EB Garamond is kept (`docs/FONTS.md`, "No face named"). Visual-only comparison with the exemplar's Times; not metric-compatible with it, so line breaks differ.
8. **Headings.** Level 2 and 3 headings are single-spaced and kept with the text after them, which CV-10(a) allows for headings.
9. **Page limit not counted.** CV-7(c)(2) sets 20 pages for this motion, excluding caption, signature and certificate. The template does not count; the sample's body is 11 pages.
10. **Dated line.** The exemplar has no "Dated" line; its certificate carries the filing date ("on 12 June 2026"). The template prints a "Dated" line only if the frontmatter has a `date`, which this sample omits.
11. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder. The brief forbids changes to `tools/`, so the gates were not run here. The render and overlay were run; the review above is the Gate 2 record for this doc type.

## Engines

docx (`docx/`): `render.sh` runs pandoc in two passes with `reference.docx` (built by `build-reference.sh`) and `txwd-motion-brief.lua`, then patches the list definitions pandoc writes. Pass 1 renders the document with LibreOffice and finds each heading's page; pass 2 writes the table of contents with those page numbers. Output: `samples/OUTPUT-lulac-rule-12-motion-to-dismiss.docx` and `.docx.pdf` (LibreOffice). Opened and checked in LibreOffice only; Word was not checked.

- Matches the typst form: EB Garamond 13 pt (embedded: EB Garamond Regular and Bold only), letter with 1 in margins, double spacing (exact 26 pt) and single (exact 15.6 pt) for the caption, headings, block quotations, signature and certificate, the cover title double-spaced, the caption as a borderless table, level 1 headings centred bold and levels 2 and 3 left bold, 0.5 in first-line indent, block quotation indented 0.5 in each side, signature table kept on one page, certificate of service after the signature, centred PAGE number, table of contents on its own page with dot leaders.
- Differs: LibreOffice draws the glyphs at the bottom of each exact 26 pt line, so a page holds 24 lines (typst 25 to 26); both are 14 pages, with different breaks: in docx the signature block follows the prayer on page 13 and the certificate is on page 14; in typst the prayer is on page 13 and the signature block and certificate are on page 14. Margins are unchanged.
- Table of contents: page numbers are the LibreOffice pagination from pass 1. Word may paginate a line differently, so a page number may be off by one in Word until the field is updated (`TOC \o "1-3"`, Update Field). The TOC has no hyperlinks.
- Footnote text is 13 pt, single spaced. The sample has no footnotes, so this is not exercised.
- No table of authorities in the typst form, so none here.
- `tools/check.sh` cannot run on a doc-type folder (no `checks.yaml`, `rules.md` or `court.json` here); no gate stamp.
- BLOCKED: none.
