# kywd: motion-brief (Rule 12(b) motion to dismiss with memorandum)

Doc type: **motion-brief** in the United States District Court for the Western District of Kentucky (`kywd`): the memorandum of law supporting a Rule 12(b)(6) motion to dismiss. Under the joint local rules the motion and its supporting memorandum may be one filing (LR 7.1(a), merged by JGO 2017-01A); the template draws the memorandum with its caption and title.
Folder: `courts/sixth-circuit/kentucky/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief-2.pdf` (the memorandum the sample transcribes, 19 pages; Vaughn Petitt Legal Group for the Bullitt County defendants). Companion: `usage/FILED-EXAMPLE-motion-brief-3.pdf` (the 2-page motion, same filer). Second filer for comparison: `usage/FILED-EXAMPLE-motion-brief.pdf` (30-page memorandum, Squire Patton Boggs and Reminger for Cleanlife Energy). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief-2.md` (id `motion-brief-2`, paired with the exemplar it transcribes; it was `INPUT-motion-brief.md`, which paired it with the Glantz filing): the whole memorandum (caption, introduction, statement of facts, all of Law & Argument I to VIII, conclusion, signature). The motion page and the certificate of service are not transcribed. |
| render | ok (2026-10-29, fb-595.17.17): `usage/OUTPUT-motion-brief-2.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 17 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with W.D. Ky.'s local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay courts/sixth-circuit/kentucky/federal/western-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief-2.pdf` against the transcribed exemplar (not committed) |
| pages reviewed | 17 of 17 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |

## Governing rules

| Rule | Requirement | Where | Source, verified |
|---|---|---|---|
| LR 5.2(a) (Joint Local Rules) | 8 1/2 x 11 inch page; margins of at least one inch on all sides; text double spaced (except block quotes, headings and footnotes); at least 12-point proportionately spaced font. | The base: letter, one-inch margins, 12 pt, 24 pt double pitch; block quotations single spaced (`quote` in `typst/layout.yaml`). | Text read from Joint General Order No. 2026-01 (https://www.kywd.uscourts.gov/sites/kywd/files/Joint%20General%20Order%2026-01-1.pdf). Same text in JGO 2018-02 (as LR 5.1(b)). Fetched 2026-10-14. |
| LR 7.1(a) | A motion must state with particularity the grounds, the relief sought and the legal argument necessary to support it (routine motions excepted). | Content, not layout. | JGO 2017-01A (https://www.kyed.uscourts.gov/sites/kyed/files/JGO17-01A.pdf). Fetched 2026-10-14. |
| LR 7.1(d) | Motions and responses may not exceed 25 pages without leave; replies may not exceed 15 pages without leave. | `eval.yaml` `params.page_limit: 25` (DEF-LEN-001, every engine). | JGO 2018-02 (https://www.kywd.uscourts.gov/sites/kywd/files/general-ordes/Joint_General_Order_2018-02.pdf). Fetched 2026-10-14. |
| LR 7.1(e) | A party filing a motion must also file a separate proposed order. | Not part of this file (a separate document). | JGO 2017-01A. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, title, file number and Rule 7(a) designation. | `front` in `typst/layout.yaml`. | https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14. |
| Fed. R. Civ. P. 11(a) | The paper is signed by an attorney of record, with address, e-mail and telephone. | `closing` in `typst/layout.yaml`. | https://www.law.cornell.edu/rules/frcp/rule_11. |

## Layout

The generic FRCP brief with W.D. Ky.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/kywd-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Caption as the transcribed filer sets it: the court's name, the division and `CIVIL ACTION NO.` (from `case_label`) with the number, centered; each party's names at the left with its designation at the right margin on their last line; "vs." between the parties. The title, bold and centered, between two rules across the page. (The Glantz filer closes the parties with a column of ")" instead: tier 3.)
- Body double spaced, first-line indent 0.5 in; paragraphs are not numbered.
- Headings on the body pitch with half a double line above: level 1 centered bold capitals; levels 2 and 3 bold at the margin, the author typing their numbers (I., A.). Kept with what follows.
- Block quotations single spaced, half an inch in on both sides; lists with the label in a half-inch box after the paragraph indent.
- Signature block: "Respectfully submitted," then "/s/ NAME" and `signature.lines` (a "" line is a blank line), 3.25 in from the left margin, kept whole with the last paragraph.
- Footer: page number centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`; `case_label` (default "Civil Action No."); `division`; `caption.parties` (list of `{names, designation}`; "vs." between parties); `brief_title`; `signature` (`by`, `lines`; "" is a blank line).
- Body: `#` level 1, `##` level 2, `###` level 3 headings; paragraphs; lists; block quotations; footnotes (`[^key]`).
- Italic case names are supported (`*Name*`). The Zoeller sample uses roman type because the exemplar's text layer has no italic markup.

## Known gaps and open choices

1. **Typeface.** LR 5.2(a) names no typeface (re-read 2026-10-15). Times New Roman (vendored), the house default (`docs/FONTS.md`), in every engine; the exemplars use it too.
2. **Motion and memorandum.** The exemplar is two documents (2-page motion; 19-page memorandum). The template draws the memorandum; a separate motion page and the proposed order (LR 7.1(e)) are not templated.
3. **Page limit.** DEF-LEN-001 counts every page against LR 7.1(d)'s 25; the Glantz memorandum (30 pages) is over 25 on its face, an observation about the exemplar, not a finding.
4. **Filer's typographical errors** ("Gregrory", "emogional", "Wyndam", "E.D.K.Y.") are kept as filed in the sample.
5. **Certificate of service.** Not in the exemplar memorandum (the companion motion carries one); not templated here (Fed. R. Civ. P. 5(d)(1)(B): none is needed for a paper served through CM/ECF).

## Review of the rendered pages (Gate 2 record, 17 of 17 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx), so one row per page covers all three. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`, `fb measure`); this pod has no image viewer.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division and civil action number centered; parties with designations at the right, "vs."; the title between two rules; opening paragraph; INTRODUCTION | OK. |
| 2-3 | Introduction (end), STATEMENT OF FACTS; LAW & ARGUMENT, I. STANDARD OF REVIEW | OK. |
| 4-5 | II. PLAINTIFF LACKS STANDING and its argument | OK. |
| 6-7 | III. (two lines), A., B. | OK. |
| 8-9 | C., D. (two lines), E. | OK. |
| 10-12 | IV. (two lines), V. MONELL and its argument | OK. |
| 13-16 | VI., VII. (two lines), VIII. immunity | OK. |
| 17 | Immunity (end), CONCLUSION, "Respectfully submitted," "/s/" line and the attorney block at 3.25 in with the blank line before the counsel line, not split | OK. |

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/kentucky/federal/western-district/motion-brief --engine typst   # 12 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/kentucky/federal/western-district/motion-brief --engine latex   # 15 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/kentucky/federal/western-district/motion-brief --engine docx    # 16 passed, 0 failed
```

## Engines

typst (primary): `typst/main.typ` -> `typst/kywd-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.17). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx.
