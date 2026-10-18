# mied: motion-brief

Doc type: **motion to dismiss with the memorandum (brief) in support**, FRCP 12(b)(6), in the United States District Court for the Eastern District of Michigan (`mied`). The motion and the brief are one document, as in the exemplar.
Folder: `courts/sixth-circuit/michigan/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-mied-motion-brief-soboleski226cv11195.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-mied-motion-brief-soboleski.md` (partial transcription, see Known gaps) |
| typeface | required: none (LR 5.1(a)(3) sets 14 pt for proportional type and names no face); vendored substitute: none needed; font kept: **EB Garamond** (`docs/FONTS.md`, "No face named"). Visual-only: the exemplar is Times New Roman, not a rule. |
| render | ok: `usage/OUTPUT-mied-motion-brief-soboleski.typst.pdf`, 15 pages, typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-15) |
| embedded fonts | `pdffonts`: EBGaramond-Regular, -Bold, -Italic only (all embedded) |
| overlay | ok: `usage/OVERLAY-soboleski-motion-brief.pdf` and `OVERLAY-soboleski-motion-brief.txt` (re-run 2026-10-15) |
| pages reviewed | 15 of 15 (every page rendered at 60 dpi and viewed on 2026-10-15) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Mich. LR 5.1(a)(2) | Papers double-spaced (quotations excepted), margins at least 1 inch on all sides, pages numbered. | `margin = 1in`; `double-leading` (2.3em pitch); page numbers in three sections. |
| E.D. Mich. LR 5.1(a)(3) | Type no smaller than 14 point for proportional fonts, footnotes included. | `type-size = 14pt`. |
| E.D. Mich. LR 7.1(a)(1) | The motion states the conferral: the date and the result of the conference with the other side. | Author content: the `L.R. 7.1 STATEMENT OF CONFERRAL` heading in the motion. |
| E.D. Mich. LR 7.1(d)(2) | The brief opens with a concise statement of the issues, then a list of the controlling or most appropriate authority; a table of contents and index of authorities are optional. | `STATEMENT OF ISSUES PRESENTED` and `CONTROLLING OR MOST APPROPRIATE AUTHORITIES` in the front matter; the contents are generated (`[[toc]]`). |
| E.D. Mich. LR 7.1(d)(3)(A) | A brief supporting a motion may not exceed 25 pages, including footnotes and signatures. | Not checked by the template (no page counter). The sample is a partial brief. |
| Fed. R. Civ. P. 12(b)(6) | The motion's ground: failure to state a claim. | Author content. |

Rule text: the E.D. Mich. local rules PDF (`https://www.mied.uscourts.gov/PDFs/LocalRules.pdf`) returned an HTML error page from this box, and courtrules.net (`https://www.courtrules.net/courts/federal/eastern-district-michigan/local-rules/lr-7-1`) is behind a bot challenge. The LR 5.1 and LR 7.1(d) text above comes from search excerpts (courtrules.net, a practitioner guide, and the 2024 amendment notice `https://www.mied.uscourts.gov/PDFFIles/notice_LocalRules_amendments_1-2024.pdf`, which fixes LR 7.1 as subsections (a) through (i) effective 2024-01-01 but does not quote (d)). **Verify each subsection against the official rules before relying on it**, especially LR 7.1(d)(2) and the 25-page limit in (d)(3).

## Layout

- Motion (pages numbered 1, 2, ...): caption, motion title, the motion paragraph, the conferral statement, the date and the signature block at the right half of the page.
- Brief cover (no page number): the caption again and the brief's title.
- Front matter (roman numerals from ii; the cover is i): statement of issues, controlling authorities (bulleted, single-spaced), table of contents (generated from the body headings, so page numbers track the render).
- Body (numbered from 1): INTRODUCTION, ARGUMENT with I., II., III. (bold, flush left) and A., B., C. (bold, indented), CONCLUSION, then the signature block.
- Certificate of service (numbered, not in the contents).
- Headings: `#` = centered bold caps; `##` = bold flush left; `###` = bold indented 0.5 in. Block quotations are single-spaced and indented on both sides.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division`, `caption.parties` (list of `{names, designation}`), `case_number`, `judges` (list), `motion_title`, `brief_title`, `date`, `signature` (`firm` lines, `signer`, `lines`).
- Markers (lines of their own): `[[brief]]` starts the brief's cover (the motion is before it); `[[toc]]` places the contents; `[[body]]` starts the numbered text. `# CERTIFICATE OF SERVICE` closes the body and is kept out of the contents.
- Headings in the front matter are not in the contents (they are not outlined).

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The CourtListener search (`court=mied`, `type=r`, motions to dismiss) also found Nano Magic, Inc. v. The Hilsinger Company Parent, LLC, 2:26-cv-12212, ECF 7 (26 pp., Liberation Sans; a Rule 12(b)(2) motion with its brief, Honigman LLP). It was checked for text but not saved. Tier 2 is therefore **not** judged against two filers yet.
2. **Partial sample.** The brief is 22 pages in the exemplar; the sample transcribes the motion, the front matter (issues, authorities, no table of authorities), the introduction, Argument I, II.A to II.C (II.B and II.C are shortened, the case-string paragraphs of II.B other than Stockdale and James are omitted), III and the conclusion, plus the certificate of service. The table of authorities (pages 'passim' and page numbers) is not transcribed; the template does not generate one. The render is 15 pages, one over the 8-14 target, because the front matter is a full page each.
3. **Font.** As for the complaint: LR 5.1(a)(3) names no face, so EB Garamond at 14 pt is kept (`docs/FONTS.md`, "No face named"). The exemplar's Times New Roman is a filer's choice, not a rule; the x-height difference is visual only (a question for David).
4. **Double spacing.** Same reading as the complaint: 2.3em pitch, ~32 pt at 14 pt, matching Times New Roman's double line box.
5. **Page numbers.** The motion is numbered 1 and 2; the brief cover is unnumbered; the front matter is roman from ii; the body restarts at 1. The exemplar follows the same pattern, but its motion pages and cover are not transcribed page-for-page, so the page numbers in the TOC follow our render, not the exemplar's.
6. **Contents.** Generated from the body headings with `outline()`; page numbers are typst's. The exemplar's contents are not matched line-for-line (its heading wording is the same).
7. **Caption.** Party block closed by a right and bottom rule (same choice as the complaint); the judge lines are at right.
8. **Sample file names.** The brief asked for `usage/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/overlay.sh` reads `usage/OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`, and CLAUDE.md requires the INPUT-/OUTPUT-/OVERLAY- names, so this folder follows the repo convention. Flagged for the PM.
9. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` are court-level gates and this doc-type folder is not that shape; the brief forbids editing `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.
10. **Overlay.** The overlay map pairs each render page with the exemplar page sharing the most words; the pairing is by text, not index, so the page numbers on the overlay map are not the filed page numbers. Diagnostic, not a score.

## Review of the rendered pages (current PDF, 15 pages)

- Page 1 (motion): caption, motion title, the motion paragraph. Pass.
- Page 2 (motion): L.R. 7.1 STATEMENT OF CONFERRAL, the date, the signature block at the right. Pass.
- Page 3 (brief cover, unnumbered): caption and brief title. Pass.
- Page 4 (ii): STATEMENT OF ISSUES PRESENTED, the numbered issue, the two answers, CONTROLLING OR MOST APPROPRIATE AUTHORITIES begins. Pass.
- Pages 5 and 6 (iii, iv): bulleted authorities (single-spaced, hanging) and the TABLE OF CONTENTS with dot leaders and page numbers. The contents shows INTRODUCTION 1, ARGUMENT 2, sections I to III, the subsections A to C, and CONCLUSION 8. Pass.
- Pages 7 and 8 (body 1 and 2): INTRODUCTION on page 1; ARGUMENT and I. on page 2. Pass.
- Pages 9 to 12 (body 3 to 6): II. (bold, hanging) on body page 3; A., B., C. headings indented and bold; block quotations single-spaced and indented; the Keating block quote on body page 6. Pass.
- Pages 13 to 15 (body 7 to 9): the rest of II.C; III. and CONCLUSION on body page 8 with the signature block; CERTIFICATE OF SERVICE on body page 9, not in the contents. Pass.

Defects found and fixed during this review:
- Paragraph spacing: typst applies `spacing` between paragraphs, not `leading`; the body's `spacing` is the double pitch (same fix as the complaint).
- `context` and separate content pieces misplaced lines; the body is rendered as one markdown string per section.

[Formbook index](../../../../../README.md)

## Engines

Built 2026-10-15 with `docx/build-reference.sh`, `docx/mied-motion-brief.lua`, and `docx/render.sh` (the court's own build: it maps the section footers to the ids pandoc writes), run by tools/render.sh --engine docx (pandoc 3.6.4).

**docx: BLOCKED (not passed).** `usage/OUTPUT-mied-motion-brief-soboleski.docx` is written and valid (no duplicate zip entries, every XML part well formed). The `.docx.pdf` step did not run: LibreOffice (`soffice`) is not installed on this box, so `tools/render-docx.sh` exits 1 at the conversion. The docx.pdf checks and the page-by-page visual review are BLOCKED, and no `usage/.check-docx.txt` stamp is written. Pages reviewed: 0.

Blocked items, by check area (docs/DOCX.md):
- docx.pdf / page review: soffice not installed on this box.
- Table of contents (the body headings): the contents is a TOC field over the heading styles. Its cached result lists the entries without page numbers; the page numbers appear only when the field is updated. `settings.xml` sets `updateFields`, so Word asks to update on open (accept it); LibreOffice needs an update on load. Page numbers in the contents are not verified in this box.
- Table of authorities: none on this doc type; the front matter lists the authorities as a bulleted list, as in the sample (the template has no TOA either).
- Pagination: Word and LibreOffice may break lines differently, so a page-number reference in the contents may be off by a page in Word.

What the docx matches, as set in `docx/reference.docx` and the filter (checked in the XML, not on a page):
- Sections as in the typst template: motion (arabic from 1), brief cover (unnumbered, the empty footer `footer2.xml`), front matter (lowercase roman), body and certificate (arabic from 1). Four `w:sectPr` blocks; the footers are named by relationship id after `docx/render.sh` maps the placeholders.
- US Letter, 1 in margins on all sides; EB Garamond 14 pt (vendored family); body exact 644 twips (32.2 pt = 2.3 em, the typst double pitch) with a 0.5 in first-line indent; block quotations single spaced and indented 0.5 in on both sides; footers 12 pt.
- Headings: level 1 centered bold caps; level 2 bold flush left; level 3 bold indented 0.5 in. Motion and front-matter headings use styles with no outline level, so they are not in the contents; the certificate starts on a new page.
- Caption on both covers: court title, party block with right and bottom rules, case number and judges at right, the title bold centered.

Differences from typst (not verified on a page):
- Single spacing is Word's font-metric single line (`w:line 240 auto`), not typst's 1.15 em pitch; the typst PDF is 15 pages (motion 2, brief cover 1, front matter 3, body 9). The docx page count is unmeasured.
- The caption rules are cell borders in a table; judge the LibreOffice PDF when it can be made (docs/DOCX.md, "Cover pages and caption boxes").
- The issues list and the authorities use hanging-indent paragraphs, not the typst list engine; their spacing is judged on the PDF only.

Not reviewed: the .docx has not been opened in Word or LibreOffice (no repair prompt check possible here).
