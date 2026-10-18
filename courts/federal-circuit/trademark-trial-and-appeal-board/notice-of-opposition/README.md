# TTAB: notice of opposition (typst)

Doc type `notice-of-opposition` under the Trademark Trial and Appeal Board (`court` ttab). Self-contained: the exemplars, the sample, the template and this README live in this folder. The court root's `typst/` and `usage/` are not touched.

## Status

| Item | State |
|---|---|
| Exemplar | yes: two filers (Brink Biologics 2022, text-based; Vitamin World 2006, mostly scanned). See `usage/SOURCE.md` |
| Sample | `usage/INPUT-notice-of-opposition.md`: the Brink notice, transcribed in full (caption, applications block, Counts I-III, prayer, signature). The ESTTA cover and the two exhibits are not transcribed; slip sheets for the exhibits are generated |
| Render (typst) | ok: `sh tools/render.sh courts/federal-circuit/trademark-trial-and-appeal-board/notice-of-opposition usage/INPUT-notice-of-opposition.md` writes `usage/OUTPUT-notice-of-opposition.typst.pdf`, 8 pages, no typst warnings, fonts EB Garamond only (embedded) |
| Overlay | ok: `sh tools/overlay.sh <dir> brink-notice-of-opposition <dir>/usage/FILED-EXAMPLE-notice-of-opposition.pdf` writes `usage/OVERLAY-brink-notice-of-opposition.pdf` and `.txt` |
| Pages reviewed | 8 of 8 (every page of the current `OUTPUT-` PDF rendered at 60 dpi and looked at; see "Page review") |
| Check gates (`tools/check.sh`) | not run (box task: no tracker, no gates in this unit) |

File names: `tools/render.sh` and `tools/overlay.sh` write and read `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the repo's naming: the role is in the name). The brief named `<id>.pdf` and `<id>-overlay.pdf`; the tools' names are used instead so that the tools run unchanged.

## Governing rules

Verified 2026-10-14. Primary text: 37 C.F.R. Part 2 from the Cornell LII mirror (https://www.law.cornell.edu/cfr/text/37/...), and TBMP June 2025 (chapter 300, section 309; the TBMP PDF was read from the USPTO download).

| ID | Kind | Rule | Source | What the template does |
|---|---|---|---|---|
| TTAB-NOP-FORM-001 | court-mandated (tier 1) | Text in an electronic submission must be at least 11-point and double-spaced. | 37 C.F.R. § 2.126(a)(1) (https://www.law.cornell.edu/cfr/text/37/2.126); TBMP § 801.03 (June 2025) repeats it | 12-point EB Garamond throughout the body; 11 pt is the floor |
| TTAB-NOP-FORM-002 | court-mandated (tier 1) | Double-spaced text. | same | Baseline pitch 24 pt at 12 pt (measured: see "Measurements") |
| TTAB-NOP-FORM-003 | convention (tier 2) | 8.5 x 11 in. paper, 1 in. margins, page numbers at the foot. | 37 C.F.R. § 2.126(b)(2) fixes the paper size for paper filings only; the margins and the numbering are not stated in any rule | US Letter, 1 in. on all sides, centered Arabic page number |
| TTAB-NOP-CONTENT-001 | court-mandated (tier 1) | The heading "IN THE UNITED STATES PATENT AND TRADEMARK OFFICE / BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD" at the top of a complaint. | TBMP § 309.02(a) (format for complaint) | The two heading lines, bold, centered |
| TTAB-NOP-CONTENT-002 | court-mandated (tier 1) | Identification of the application or registration ("Serial No."), the name of the proceeding ("X v. Y" and "Opposition No."), the title of the paper, the opposer's name, entity and address, the substance (entitlement and grounds), and the signature with the capacity of the signer. | TBMP § 309.02(a), (b); 37 C.F.R. § 2.101(b) (signed by the opposer or its attorney; electronic signature under § 2.193(c)) | "In re Application of" block from `applications`, the caption from `caption`, the title from `title`, the signature from `signature` as "By: /Name/" with the capacity line |
| TTAB-NOP-CONTENT-003 | court-mandated (tier 1) | The grounds are pleaded in numbered paragraphs (the body of the complaint). | TBMP § 309.03 (substance of complaint); the paragraph numbers are typed in the sample, not generated | body paragraphs are typed "N." and escaped in the markdown; the template does not renumber |
| TTAB-NOP-FILE-001 | court-mandated (tier 1) | The opposition is filed through ESTTA, with the fee, within the opposition period. | 37 C.F.R. § 2.101(b)(1), (c), (d), (e); 37 C.F.R. § 2.126(a) | Not rendered. The ESTTA cover sheet is not part of the PDF; the template reproduces the pleading only |
| TTAB-NOP-SERVICE-001 | court-mandated (tier 1) | The notice of opposition is not served by the opposer. The Board serves it with the notice of institution. No certificate of service is required for the notice itself. | 37 C.F.R. § 2.119(a) ("Except for the notice of opposition or the petition to cancel"); TBMP § 309.02(c)(1); 37 C.F.R. § 2.105(a) | No certificate is generated. (The 2007-2010 Board orders quoted in search results describe an earlier requirement; the current § 2.119(a) exempts the notice, as amended at 81 FR 69975, Oct. 7, 2016) |
| TTAB-NOP-EXHIBIT-001 | convention (tier 2) | Exhibits are attached electronically, "clear and legible". | 37 C.F.R. § 2.126(a)(2) | One slip sheet per exhibit, "EXHIBIT N" and its description, on its own page. The exhibits' content is not in the PDF |

Not generated, on purpose: the ESTTA cover sheet (the filing receipt); the fee; the exhibits' contents; the 66(a) (Madrid) variant of the notice, which must be filed electronically and carries the WIPO-facing information (TBMP § 309.02(a)).

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

| Field | Required | Feeds |
|---|---|---|
| `caption` | yes | list of `{names, designation}`; two sides; the "v." line is inserted between them |
| `applications` | no | list of `{applicant, serial, mark, application_date, publication_date}`: the "In re Application of" block |
| `opposition_no` | no | the number in the caption; a blank line is printed when absent (the number is assigned by the Board) |
| `title` | yes | the title of the paper, centered, bold, capitals |
| `exhibits` | no | list of `"Exhibit N: description"`; one slip sheet each, after the signature |
| `signature` | yes | `signer` (printed as `/Name/`), `lines` (the capacity, firm, address, telephone, email) |
| `date` | no | "Date: ..." above the signature block |

Body: `# COUNT I` and `## LIKELIHOOD OF CONFUSION` are centered bold capitals. Paragraphs are typed with their numbers, escaped (`1\. Opposer ...`), so markdown does not make a list of them. Case names are italic (`*In re Cook*`). Everything else is plain text.

## Measurements

- Line pitch: typst's default line box is far too small for this font (the first render overlapped lines). With `top-edge: "ascender"` and `bottom-edge: "descender"`, the natural line is 15.66 pt at 12 pt (1.305 em). Adding `leading: 0.695em` (8.34 pt) gives a 24.0 pt pitch, which is double spacing. Measured by rendering a test document and reading the `yMin` values with `pdftotext -bbox`: pitches 23.46 pt at 0.65 em, 25.50 pt at 0.82 em, and 24.0 pt at 0.695 em.
- Paragraph spacing: 0 (the first-line indent marks paragraphs, as in the exemplar).
- Single spacing (caption, headings, signature, slip sheets): leading 0 em, a 15.66 pt pitch.

## Overlay

`OVERLAY-brink-notice-of-opposition.pdf`: red is our render, blue is the filed exemplar, and black is where both agree. Pages are paired by word overlap (`OVERLAY-brink-notice-of-opposition.txt`):

- ours p.1 -> filed p.3 (93%), p.2 -> p.4 (92%), p.3 -> p.5 (93%), p.4 -> p.6 (84%), p.5 -> p.7 (77%), p.6 -> p.8 (56%). The pairing is by text, not by index: the filed PDF starts with the ESTTA cover page, so filed page numbers run ahead of ours.
- ours p.7 and p.8 (exhibit slip sheets) pair with filed p.9 at 14-17%. There is no counterpart in the filed notice: the filed exhibit 1 is a TESS printout and exhibit 2 is redacted literature, and the slip sheets carry only the label. This is expected, not a defect.

The overlay is a diagnostic. Differences in leading, the exact position of the caption ")" column and the blank-line length are tier 3 (one filer's style) and are not chased.

## Page review

Every page of `OUTPUT-notice-of-opposition.typst.pdf` (8 pages) was rendered at 60 dpi and looked at, after the final template change.

| Page | Content | Finding |
|---|---|---|
| 1 | Heading, "In re Application" blocks, caption, title, preamble, para 1 starts | OK. Caption ")" column lines up with the names; opposition number blank printed |
| 2 | Paras 1-4 | OK. Double spacing consistent; first-line indent on every paragraph |
| 3 | Paras 5-12 | OK |
| 4 | Paras 13-22, COUNT I heading | OK after fix: paragraph 14, which follows a heading, was flush left until `first-line-indent: (amount, all: true)` was set |
| 5 | Paras 23-28, COUNT II heading | OK |
| 6 | Paras 29-30, COUNT III heading, WHEREFORE, the "Please charge" sentence, date, signature block | OK |
| 7 | Exhibit 1 slip sheet | OK; centered, label and description |
| 8 | Exhibit 2 slip sheet | OK |

Defects found and fixed in the process: (1) overlapping lines, from the default line box (fixed by the measured edges and leading); (2) first paragraph after a heading not indented (fixed by `all: true`).

## Known gaps

- The ESTTA cover sheet, the fee and the exhibit contents are not generated (see the rule table).
- Paragraph numbers are typed, not generated. A notice that is edited must have its numbers changed by hand.
- Tier 2 has two exemplars from two filers, but the Vitamin World exemplar is 2006 and scanned, so only the Brink exemplar can be overlaid. The conventions judged against the Brink exemplar are the caption layout and the signature block. The Vitamin World exemplar was not overlaid: its body is scanned.
- The 66(a) (Madrid) variant and the consolidated-opposition variant (several applications, one opposer) are not separate templates; the `applications` block covers several applications.
- The sample is one filer's notice (Brink). It is not a second, structurally different sample; the template is content-agnostic by construction (no case text in it), but it has not been tested on a second notice.

## Engines

The docx engine (`docx/`, see `docs/DOCX.md`) is built from `docx/make-reference.sh` (the `reference.docx`: EB Garamond 12 pt, double-spaced body at 24 pt exact, half-inch first-line indent, single-spaced footnotes and block quotations, headings at the typst template's default sizes) and `docx/ttab-notice.lua` (the USPTO heading, the applications block, the caption table, the title, the signature block kept together, one slip sheet per exhibit). Render: `sh tools/render.sh --engine docx <this-dir> usage/INPUT-notice-of-opposition.md` writes `usage/OUTPUT-notice-of-opposition.docx` and `.docx.pdf`.

| Item | docx vs typst |
|---|---|
| Font, size, double spacing, margins, US Letter, centered page number from 1 | Matches (TTAB-NOP-FORM-001 to 003) |
| Heading, applications, caption with the ")" column, title, signature block at 3 in., exhibit slip sheets | Matches in content and position; the caption table is a Word table, so its borders are off by design |
| Pagination | The typst sample runs 8 pages; the docx runs 9. The signature block is kept on one page, which moves it to page 7; the typst block fits on page 6. Word will paginate slightly differently again (line height of the single-spaced lines) |
| Exhibit slip sheets | A one-cell table of exact height, vertically centered; the same page as the typst slip sheet |

BLOCKED (docx): `check.sh --engine docx` cannot run on this folder: the checks read `checks.yaml` and `court.json` in the court root, and this doc-type folder has neither (the court root has `court.json` but no `checks.yaml`). So no gate ID is green or red for this engine; the render and the page-by-page review are the only checks made. Pages reviewed: every page of `OUTPUT-notice-of-opposition.docx.pdf` (9 pages) was rendered at 60 dpi and compared with the typst pages.

## Searches

- Web search: "notice of opposition" TTAB pdf ttabvue (returned Board institution and extension orders, not the notice itself); a TTABVUE OPP-1 for 91174465 and 91274910 was fetched directly and found.
- Direct TTABVUE fetches: `ttabvue-91174465-OPP-1.pdf` (Vitamin World, found); `ttabvue-91169294-OPP-1.pdf` (a 3-page document, not a notice); `ttabvue-91274910-OPP-1.pdf` (Brink, found). The Brink docket OPP-2 is the institution answer, OPP-4 is a one-page order.
