# W.D. Tex. (txwd): motion brief

Doc type: **motion with brief in support** (a Rule 12(b) motion to dismiss and the brief in one document) in the United States District Court for the Western District of Texas (`txwd`).
Folder: `courts/fifth-circuit/texas/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (Dallas County Election Administrator's Rule 12 motion and brief, 22 pages). See `usage/SOURCE.md`. The second-filer check is not met: see gap 1. |
| sample md | `usage/INPUT-motion-brief.md` (an excerpt: cover, table of contents, introduction, grounds, argument A, B.1 to B.3, part of C, prayer, signature block, certificate of service). |
| typeface | face required: none (CV-10(a) names no face). Substitute: none needed; **Times New Roman** 12 pt (`docs/FONTS.md` rule 6, the house standard; EB Garamond 13 pt before fb-595.68). Embedded: Times New Roman Regular and Bold only (`pdffonts` on the committed render). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 14 pages each (cover, contents ii, body 1 to 12), vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.7) |
| overlay | ok: `usage/OVERLAY-lulac-rule-12-motion-to-dismiss.pdf` and `.txt` (see "Overlay"), regenerated 2026-10-14 against `usage/FILED-EXAMPLE-motion-brief.pdf`. That PDF was missing from the checkout and was fetched from the URL in `usage/SOURCE.md`. |
| pages reviewed | 14 of 14 on typst, latex and docx, read as laid-out text after the move onto the FRCP base, 2026-10-29 (see "Gate 2 review on the FRCP base"; the older reviews below were made on earlier renders) |
| gates | `sh tools/check.sh <dir>` exits 0 on typst, latex and docx (fb-595.17.7); the docx and latex renders pass XENG-001..003 against the typst render |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| W.D. Tex. Local Rule CV-10(a) | Typed or printed in 12-point or larger font (including footnotes), double-spaced, on 8½ × 11 paper, one-inch margins on all sides; endorsed with the style of the case and the descriptive name of the document. Headings, footnotes and quotations more than two lines long may be single-spaced. | `page` (us-letter, 1 in margins), `type-size = 12pt`, `pitch-double` (24 pt, 2 x the size), `title`, `caption`. |
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
- Body from page 3: double spacing (24 pt pitch, 2 x 12 pt), paragraph spacing equal to the leading, first-line indent 0.5 in, body paragraphs not numbered.
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

- The tool writes `usage/OVERLAY-<id>.pdf` and `.txt`, not the `<id>-overlay.*` names in the brief (the tool was not changed; file roles follow CLAUDE.md).
- Page map (word-overlap pairing, on the earlier EB Garamond render, before fb-595.68): ours p.1-2 ↔ filed p.1-2; ours p.3-4 ↔ filed p.7 and p.9; ours p.5-12 ↔ filed p.10-18; ours p.14 ↔ filed p.22 (the certificate). Ours p.13 is paired with filed p.1 by word overlap; that is an artifact (the prayer and signature page shares words with the cover block) and not a layout match.
- The overlay is a diagnostic, not a score: the filing has footnotes, Roman-numeral front matter and a TOA the sample does not reproduce.

## Review of the rendered pages (Gate 2 record; every page viewed at 60 dpi on the final build; the earlier EB Garamond render, before fb-595.68)

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

1. **One filer.** EVAL-LOOP tier 2 asks for two or three filers. The search found other txwd motions (see `usage/SOURCE.md`), but none was downloaded and checked for structure in this pass. The tier-2 comparison is against one filing only.
2. **No table of authorities.** The exemplar has a TOA (pages iii to iv). The template does not generate one: it would need page numbers per authority, which the markdown does not carry (the ca9 template's `toa:` links are not used here). The TOA is not required by W.D. Tex. CV-7 or CV-10.
3. **Sample is an excerpt.** The Baker-factors passage ends with an ellipsis ("U.S. Const. art. I, § 4 …"): the exemplar's text continues past what was transcribed. Argument C's remainder, D and E, and the footnotes are not transcribed. The sample is 14 pages with the cover and contents; the filing is 22.
4. **Footnotes.** The exemplar has footnotes (for example, the note on Administrator Adams's title and the note on Secretary Nelson's resignation). They are omitted from the sample. The template has no footnote rule; CV-10(a) requires 12 pt or larger for footnotes, which the 12 pt type size meets, but the footnote layout is untested.
5. **Front matter numbering.** The exemplar numbers the cover and contents with Roman numerals (the TOC is page iii onward in the filing); the render numbers every page in Arabic. No rule requires either.
6. **Justification.** Body text is left-aligned (ragged right). The exemplar's justification could not be read from the text layer; not asserted.
7. **Font.** Times New Roman, 12 pt, as the exemplar. CV-10(a) names no face (it requires only "12-point or larger"); Times New Roman is the house standard (`docs/FONTS.md` rule 6). Before fb-595.68 the template was EB Garamond 13 pt, not metric-compatible with the exemplar's Times.
8. **Headings.** Level 2 and 3 headings are single-spaced and kept with the text after them, which CV-10(a) allows for headings.
9. **Page limit not counted.** CV-7(c)(2) sets 20 pages for this motion, excluding caption, signature and certificate. The template does not count; the sample's body is 11 pages.
10. **Dated line.** The exemplar has no "Dated" line; its certificate carries the filing date ("on 12 June 2026"). The template prints a "Dated" line only if the frontmatter has a `date`, which this sample omits.
11. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder. The brief forbids changes to `tools/`, so the gates were not run here. The render and overlay were run; the review above is the Gate 2 record for this doc type.

## Gate 2 review on the FRCP base (2026-10-29, every page of the typst, latex and docx renders read)

Pages read as laid-out text (`pdftotext -layout`) on all three engines; XENG-001..003 show the latex and docx pages break every line where typst does.

- Page 1 (the cover, counted, unprinted): court's name with the division, the caption with the column of section marks, "CIVIL ACTION NO." and the number at the right, the title at the body pitch. PASS (DEF-COVER-002 passes on every engine).
- Page ii: the table of contents, three levels, a step in per level. PASS. The pages now run as the exemplar's: the cover counted, the contents ii, the motion from 1 (the old template numbered from the cover).
- Pages 1 to 9: body, the grounds as a numbered list with bullets under it, the block quotations, argument and sub-headings at the margin. PASS.
- Page 10: ACCEPTED (tier 2): eight lines only; the prayer, the body's last paragraph, is kept with the signature block on page 11.
- Page 11: prayer and the signature block in the right 3.2 inches (CV-10(b)). Page 12: the certificate of service, the signer's lines at the right. PASS.
- Frontmatter now: `division`, `caption.parties`, `case_number`, `brief_title` (was `title`); the caption is built from the parties, not typed as rows; `toc_title` and the court's name are the layout's.

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.7): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays only what this court sets itself, each with its rule; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`, and the per-folder docx filter (`docx/txwd-motion-brief.lua`) is removed. The 20-page limit of CV-7(c)(2) is `eval.yaml` params.page_limit (DEF-LEN-001, every engine). The sections above that name the old template's parameters (`pitch-double`, `caption-left` and the like) predate the move; the layout is now `typst/layout.yaml`.

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass (every page and line breaks where typst breaks it) |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |
