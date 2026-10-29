# flsd: motion-brief

Doc type: **motion to dismiss with incorporated memorandum** (Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the Southern District of Florida (`flsd`).
Folder: `courts/eleventh-circuit/florida/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the exemplar's full text: 10 pages of motion and memorandum, the signature block and the certificate of service) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 13 pages (typst), with `.latex.pdf` and `.docx`/`.docx.pdf` generated from the same layout; Times New Roman only (`docs/FONTS.md`, rule 1), no warnings |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 13 of 13 on every engine (2026-10-29, see "Review of the rendered pages") |

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`.

## Governing rules

Primary source: S.D. Fla. Local Rules, revised effective 1 December 2025, from https://www.flsd.uscourts.gov/sites/flsd/files/25-09-22%202025%20Local%20Rules%20effective%20120125%20-%20FINAL.pdf (fetched and read 2026-10-14).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 5.1(a)(3) | Standard 8½ × 11 inch white, opaque paper. | the base (`lib/layouts/frcp-motion-brief.yaml`): letter paper. |
| L.R. 5.1(a)(4) | 1 inch margins on top, bottom and each side. | the base: `margin` 72 pt on every side. |
| L.R. 5.1(a)(4) | Not less than 1½ spaces between lines (quotations of 50 words or more and footnotes may be single-spaced). | `pitch.body: 27.6` (double, following the exemplar). Footnotes and quotations single-spaced. |
| L.R. 5.1(a)(4) | Fonts no smaller than 12 point, footnotes and quotations included. | the base: `size: 12`, `footnote.size: 12`. |
| L.R. 5.1(a)(4) (typeface) | No typeface is named. The rule text (read 2026-10-14) sets only the 12-point minimum, so no court-named face applies: face required = none. | `font-family = ("Times New Roman", "Liberation Serif")`: Times New Roman, the house standard (`docs/FONTS.md`, rule 6), as in the exemplar. |
| L.R. 5.1(a)(4) | Paginated consecutively at the bottom center of each page. | the base: `page_number: {align: center}`. |
| L.R. 5.1(a)(5)(A)–(D) | Court name, docket line with the judges' last names, the style on the left, the title, all as in the complaint README. | `front` in `typst/layout.yaml`. The docket line (`case_number`) carries the judges' names: `26-cv-25201-BLOOM/Elfenbein`. |
| L.R. 5.1(a)(6) | Signature block: name, street address, telephone, e-mail and bar number of each counsel. | `closing` in `typst/layout.yaml`. |
| L.R. 5.2 | Certificate of service when service is not through CM/ECF, identifying the persons served, their relationship, address, telephone, e-mail, the date and the method. | `after_tail` in `typst/layout.yaml`, from `service` in the frontmatter. Used here because the exemplar has one; the CM/ECF wording is the exemplar's. |
| L.R. 7.1(a)(1) | A motion shall incorporate a memorandum of law citing supporting authorities. | The sample is one document: motion, Preliminary Statement, Standard of Review, Argument, Conclusion. |
| L.R. 7.1(a)(3) | A conferral certificate is required before most motions, but not before a motion to dismiss for failure to state a claim. | No conferral certificate is generated, and none is in the exemplar. Consistent with the exemption. A motion that is not a 12(b)(6) motion would need one. |
| L.R. 7.1(c)(2) | A motion and its incorporated memorandum may not exceed 20 pages without leave. The title page, tables, signature pages and certificates of service do not count if no substantive text is on the same page. | `eval.yaml` `page_limit: 20` (every page counted, the conservative reading); the render is 13 pages, the certificate of service and the signature page among them. |
| Fed. R. Civ. P. 7(b), 12(b)(6) | The motion states the grounds and the relief sought; failure to state a claim. | The motion paragraph and the WHEREFORE paragraph. FRCP text not separately fetched this session. |

## Layout

Set by `typst/layout.yaml` (the generic FRCP brief, `lib/layouts/frcp-motion-brief.yaml`, with this court's overlay; each value cites its rule):

- Court name and division bold and centered; the docket line centered a double line below (`case_label`, default "CIVIL CASE NO.", and the number with the judges' names); the style in a 3.25 in column at the left, each party's names, its designation half an inch in a line below, "v." between them, ruled below and closed by "/" at its right (the exemplar's typed line); the title bold capitals, centered.
- Body double-spaced at 27.6 pt (twice the 13.8 pt single line of 12 pt type), first lines indented half an inch, unnumbered (a motion is not a pleading). Quotations single-spaced, half an inch in on each side. Footnotes 12 pt, single-spaced.
- Headings single-spaced, bold, a single line above and below: level 1 centered capitals, level 2 at the margin, level 3 half an inch in; the numbers typed in the sample. A heading never ends a page.
- "Dated:" at the margin; from 3 in, "Respectfully submitted,", "By: s/" and the signer, then the signer's lines; kept whole and with the last paragraph.
- The certificate of service (when `service` is given) after the signature: its title as a level-1 heading, the CM/ECF statement double-spaced, the "s/" signature and name at 3 in, SERVICE LIST and those served at the margin; kept on one page.
- Pages numbered at the bottom center from page 1.

## Markdown contract (for samples)

- Frontmatter: `case_number` (the docket number with the judges' names), `case_label` (optional), `division` (optional), `caption.parties` (`names`, a list of lines; `designation`), `title`, `date` (printed "Dated: ..."), `signature` (`signer`, `lines`), `service` (optional: `date`, `signer`, `list`).
- Body: markdown set by the shared document model: `#` to `###` headings, paragraphs, lists, block quotations, footnotes (`[^1]`), `*italics*`.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. The tier-2 rule (2 or 3 filers from different filers) is not met for this doc type.
2. **Font.** L.R. 5.1(a)(4) names no typeface (checked 2026-10-14), so the template is set in Times New Roman 12 pt, the house standard (`docs/FONTS.md`, rule 6, 2026-10-17; it was EB Garamond before), the exemplar's face.
3. **Case names not italic.** The exemplar text layer has no italics, so the sample has roman case names. Bluebook italics would be a tier-2 presentation choice, not a rule requirement.
4. **Page 3 gap.** The ARGUMENT heading, point I and sub-point a. are kept with the first paragraph of text, so page 3 ends early. This is the "heading never ends a page" rule, not an error; the exemplar breaks differently.
5. **Overlay pairing.** The render (13 pages) breaks its pages where the 11-page exemplar does not, so overlay pages pair by text; the overlay is a diagnostic, not a score.
6. **Proposed order.** L.R. 7.1(a)(2) requires a proposed order for the motions listed in 7.1(a)(1) and for emergency relief. A motion to dismiss is not one of them; no proposed order is generated.
7. **Judges' names in the caption.** Present here (`26-cv-25201-BLOOM/Elfenbein`), following the exemplar and L.R. 5.1(a)(5)(B).

## Review of the rendered pages (13 of 13, 2026-10-29, the FRCP-base render)

Every page of the typst, LaTeX and Word renders was read as its text layout and word boxes (`pdftotext -layout`, `-bbox`); the three break every line and page alike (XENG-001..003).

- Page 1: court name, division, docket line, the style ruled below with "/" at its right, the title in three centered bold lines, the opening paragraph, PRELIMINARY STATEMENT. Pass.
- Pages 2 to 3: the preliminary statement with footnote 1; STANDARD OF REVIEW. Pass.
- Page 4: ARGUMENT, point I and sub-point a. kept with their first paragraph. Pass.
- Pages 5 to 7: sub-points a. and b. of point I. Pass.
- Page 8: point II and sub-point a. Pass.
- Pages 9 to 10: the FCRA argument; footnote 2 at the foot of page 10. Pass.
- Page 11: the last of the argument and CONCLUSION. Pass.
- Page 12: the WHEREFORE paragraph kept with the date line and the signature block. Pass.
- Page 13: CERTIFICATE OF SERVICE, the signer at 3 in, SERVICE LIST. Pass.

## Engines

On the generic federal district brief since fb-595.17.5: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter (`docx/flsd.lua`) are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst (reference) | `usage/OUTPUT-motion-brief.typst.pdf`, 13 pages | 12 checks passed, 0 failed | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` | 15 checks passed, 0 failed | PASS (288/288 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | 16 checks passed, 0 failed | PASS (288/288 lines) |

The L.R. 7.1(c)(2) 20-page limit is checked on every render (`eval.yaml` `page_limit`). LaTeX only: `latex_bias: 0.1` (newtx runs 0.06 pt wider than typst over the first line of note 2, which typst fills to 0.01 pt of the margin). No item is BLOCKED.
