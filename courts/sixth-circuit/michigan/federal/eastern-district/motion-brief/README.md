# mied: motion-brief

Doc type: **motion to dismiss with the memorandum (brief) in support**, FRCP 12(b)(6), in the United States District Court for the Eastern District of Michigan (`mied`). The motion and the brief are one document, as in the exemplar.
Folder: `courts/sixth-circuit/michigan/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (partial transcription, see Known gaps) |
| typeface | required: none (LR 5.1(a)(3) sets 14 pt for proportional type and names no face); used: **Times New Roman** 14 pt (vendored, `docs/FONTS.md`), as the filed exemplar, in both engines |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 17 pages each, on the generic FRCP brief (fb-595.92); vendored fonts only, no warnings |
| embedded fonts | `pdffonts`: TimesNewRomanPSMT, -BoldMT, -ItalicMT only (all embedded), both engines |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 17 of 17 on each engine (2026-10-29, the FRCP-base render: `reviews/2026-10-29.md`) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Mich. LR 5.1(a)(2) | Papers double-spaced (quotations excepted), margins at least 1 inch on all sides, pages numbered. | `margin = 1in`; `pitch-body` 32.2 pt (twice the 16.1 pt single line); page numbers in three sections. |
| E.D. Mich. LR 5.1(a)(3) | Type no smaller than 14 point for proportional fonts, footnotes included. | `type-size = 14pt`; docx `size="28"`. |
| E.D. Mich. LR 7.1(a)(1) | The motion states the conferral: the date and the result of the conference with the other side. | Author content: the `L.R. 7.1 STATEMENT OF CONFERRAL` heading in the motion. |
| E.D. Mich. LR 7.1(d)(2) | The brief opens with a concise statement of the issues, then a list of the controlling or most appropriate authority; a table of contents and index of authorities are optional. | `STATEMENT OF ISSUES PRESENTED` and `CONTROLLING OR MOST APPROPRIATE AUTHORITIES` in the front matter; the contents are generated (`<!-- toc -->`). |
| E.D. Mich. LR 7.1(d)(3)(A) | A brief supporting a motion may not exceed 25 pages, including footnotes and signatures. | Not checked by the template (no page counter). The sample is a partial brief. |
| Fed. R. Civ. P. 12(b)(6) | The motion's ground: failure to state a claim. | Author content. |

Rule text: the E.D. Mich. local rules PDF (`https://www.mied.uscourts.gov/PDFs/LocalRules.pdf`) returned an HTML error page from this box, and courtrules.net (`https://www.courtrules.net/courts/federal/eastern-district-michigan/local-rules/lr-7-1`) is behind a bot challenge. The LR 5.1 and LR 7.1(d) text above comes from search excerpts (courtrules.net, a practitioner guide, and the 2024 amendment notice `https://www.mied.uscourts.gov/PDFFIles/notice_LocalRules_amendments_1-2024.pdf`, which fixes LR 7.1 as subsections (a) through (i) effective 2024-01-01 but does not quote (d)). **Verify each subsection against the official rules before relying on it**, especially LR 7.1(d)(2) and the 25-page limit in (d)(3).

## Layout

Both engines run on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line is a box of its pitch (body 32.2 pt, single 16.1 pt, the 12 pt page number 13.8 pt), first-fit ragged-right breaking, no kerning, ligatures or hyphenation; the docx breaks every line and page where the typst render does (`eval.yaml`: `params.cross_engine: gate`).

- Motion (pages numbered 1, 2, ...): court title, caption, motion title, the motion text and the conferral statement, then the signature block (kept on one page).
- Brief cover (no page number; it counts as i): the caption again and the brief's title.
- Front matter (roman numerals from ii), each level-1 section opening a page: statement of issues (the issue numbered at the indent, double spaced), controlling authorities (bulleted, single spaced, hanging), table of contents (the body headings, single spaced rows indented 0.5 in per level, a dot leader to the page in a 0.5 in column; typst computes the pages, the docx takes them from fb render's passes over the LibreOffice PDF).
- Body (numbered from 1): INTRODUCTION, ARGUMENT with I., II., III. (bold at the margin) and A., B., C. (bold, 0.5 in in), CONCLUSION, then the signature block, kept on one page with the conclusion's last paragraph.
- Certificate of service on a page of its own (numbered, not in the contents): the certification double spaced, its signature lines single spaced from 3.2 in.
- Headings at the type size on the body pitch with no space of their own, kept with the next line: `#` centred bold capitals; `##` bold at the margin, later lines hanging 0.5 in; `###` bold, 0.5 in in, later lines hanging another 0.5 in. Block quotations single spaced, indented 0.5 in on both sides, a single line above and below; the paragraph after a quotation goes on unindented.
- Caption: as the complaint's (the party column ruled at its right and foot, designations set in 1 in, a blank line around "v."). Signature block: "Dated:" at the left of its first line, from 3.2 in "Respectfully submitted,", the firm, "By: /s/" and the signer, the contact lines.
- Page number: 12 pt, centred, its line box ending 0.5 in above the page edge.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division`, `caption.parties` (list of `{names, designation}`), `case_number`, `judge` or `judges` (list), `motion_title`, `brief_title`, `date` (optional), `signature` (`firm` lines, `signer`, `lines`), `service` (`text`, `lines`: the certificate of service and its signature lines).
- Markers (HTML comments on lines of their own): `<!-- brief -->` ends the motion (`lead`) and starts the brief; `<!-- toc -->` ends the statement of issues and the authorities (`body_before_tables.marker`), the contents following them; `<!-- body -->` is a comment the render drops.
- Blocks: `#` to `###` headings, `>` quotations, `1.` lists (numbered issues), `-` lists (authorities), paragraphs, footnotes. Headings in the motion are not in the contents; the statement of issues and the authorities are (as filed). Not supported: raw typst.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The CourtListener search (`court=mied`, `type=r`, motions to dismiss) also found Nano Magic, Inc. v. The Hilsinger Company Parent, LLC, 2:26-cv-12212, ECF 7 (26 pp., Liberation Sans; a Rule 12(b)(2) motion with its brief, Honigman LLP). It was checked for text but not saved. Tier 2 is therefore **not** judged against two filers yet.
2. **Partial sample.** The brief is 22 pages in the exemplar; the sample transcribes the motion, the front matter (issues, authorities, no table of authorities), the introduction, Argument I, II.A to II.C (II.B and II.C are shortened, the case-string paragraphs of II.B other than Stockdale and James are omitted), III and the conclusion, plus the certificate of service. The table of authorities (pages 'passim' and page numbers) is not transcribed; the template does not generate one. The render is 16 pages (motion 2, cover 1, front matter 3, body 9, certificate 1).
3. **Font.** LR 5.1(a)(3) names no face; Times New Roman (the exemplar's face, the repo default) in both engines. The docx was EB Garamond before the cross-engine port (2026-10-22).
4. **Double spacing.** Same reading as the complaint: Times New Roman's single line box, 16.1 pt single and 32.2 pt double at 14 pt. Headings are on the double pitch too (the exemplar single-spaces a heading's lines); the authorities and the contents rows are single spaced, as in the exemplar.
5. **Page numbers.** The motion is numbered 1 and 2; the brief cover is unnumbered; the front matter is roman from ii; the body restarts at 1. The exemplar follows the same pattern, but its motion pages and cover are not transcribed page-for-page, so the page numbers in the TOC follow our render, not the exemplar's.
6. **Contents.** Generated from the body headings in both engines (typst from the heading locations; docx from fb render's needles, settled over its passes); the front-matter sections are not listed (the exemplar lists the statement of issues and the authorities with their roman pages; tier 3, OPEN). The typst leader stops at the page column, Word's runs to the number (a tab leader); the text and the breaks are the same.
7. **Caption.** Party block closed by a right and bottom rule (same choice as the complaint); the judge lines are at right.
8. **Sample file names.** `usage/` follows the INPUT-/OUTPUT-/FILED-EXAMPLE- convention of CLAUDE.md.
9. **Selftest.** `tools/check-selftest.sh` needs a `court.json` in the folder it is given ("court.json unreadable" on this doc folder), so it does not apply here; `tools/check.sh` runs on the doc folder (typst and docx below).
10. **Overlay.** The overlay map pairs each render page with the exemplar page sharing the most words; the pairing is by text, not index, so the page numbers on the overlay map are not the filed page numbers. Diagnostic, not a score.

## Review of the rendered pages (before the FRCP base, 2026-10-22; the current record is `reviews/2026-10-29.md`)

The docx render breaks every line and page as the typst render (XENG-001..003 PASS, 290/290 lines), so each row holds for both.

- Page 1 (motion, 1): court title, caption with the ruled party column and the case number and judges at the right, the motion title in two bold lines, the motion paragraph, L.R. 7.1 STATEMENT OF CONFERRAL and the first lines of its paragraph. Pass.
- Page 2 (motion, 2): the rest of the conferral paragraph, the date at the left and the signature block from 3.2 in. Pass.
- Page 3 (brief cover, no number): caption and the brief title. Pass.
- Page 4 (ii): STATEMENT OF ISSUES PRESENTED, issue 1 with its number at the indent, the two answers. Pass.
- Page 5 (iii): CONTROLLING OR MOST APPROPRIATE AUTHORITIES, Cases and Statutes and Regulations, bulleted, single spaced, hanging. Pass.
- Page 6 (iv): TABLE OF CONTENTS: INTRODUCTION 1, ARGUMENT 2, I. 2, II. 3, A. 4, B. 5, C. 6, III. 8, CONCLUSION 9, each matching the body page it names. Pass.
- Pages 7 to 9 (1 to 3): INTRODUCTION; ARGUMENT and I. on page 2; II. (two lines, hanging) on page 3. Pass.
- Pages 10 to 14 (4 to 8): A. with the two block quotations (single spaced, indented both sides, the following text unindented); B. (three lines) on page 5; C. on page 6; the Webster and Keating quotations on page 7; III. on page 8, which ends short so that CONCLUSION stays with the signature block. Pass.
- Page 15 (9): CONCLUSION, its paragraph and the signature block. Pass.
- Page 16 (10): CERTIFICATE OF SERVICE, the certification and its signature lines. Pass.

[Formbook index](../../../../../README.md)

## Engines

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and the shared
document model (docs/EVAL-LOOP.md, "Generated engines"): `typst/layout.yaml` names the base and overlays E.D. Mich.'s
local rules (the caption and the signature written once, YAML anchors); `typst/mied-motion-brief.typ` only names the
face; `fb engines gen` writes `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) from the
merged layout; `eval.yaml` gates the cross-engine checks (XENG-001..003). `latex_bias: 0`: LaTeX's text block at
typst's width (an authorities line LaTeX set fuller at the face's 0.05 bp). Word is not available here; the docx is
checked with LibreOffice.

## FRCP base (fb-595.92): moved

The motion before the brief's cover, numbered on its own, is the base's `lead` (fb-595.92): the body up to
`<!-- brief -->` under the motion's caption and title, closed by counsel's signature, pages 1-2. The brief: its cover
counted as i and unnumbered (`page_number.cover: counted`); the statement of issues and the controlling authorities
(LR 7.1(d)(2)), the body up to `<!-- toc -->`, each on a page of its own (`body_before_tables.each_page`, fb-595.92),
ii-iv; the table of contents, now listing them too (as filed), v; the text from 1; the certificate of service from the
sample's `service` (moved from the body into the frontmatter, its signature lines from 3.2 in). The caption's party
column is unruled, as filed. Open (tier 2): the model sets every list at the body pitch in a hanging indent, so the
issue's number hangs at the margin (the exemplar runs the text under it) and the authorities are double-spaced over two
pages (the exemplar single-spaces them on one); both are within LR 5.1(a)(2) (double spacing). The page number is at
the type size, 14 pt (the earlier template's 12 pt; the model has no page-number size).
