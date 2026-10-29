# D. Mont. (mtd): motion brief

Doc type: **motion-brief** (brief in support of a motion to dismiss, the memorandum filed separately from the motion). Court: United States District Court for the District of Montana. Folder: `courts/ninth-circuit/montana/federal/district/motion-brief/`.

Status: exemplar=yes, render=ok (typst, latex, docx; 11 pages each), pages reviewed 11 of 11 on every engine (2026-10-29, the FRCP-base render: `reviews/2026-10-29.md`). Nothing here sets `status` in any `court.json`.

## Governing rules

Sources: the District of Montana's Local Rules of Procedure, both versions, fetched from the court's website on 2026-10-14:

- Effective **December 1, 2026**: https://www.mtd.uscourts.gov/sites/mtd/files/LocalRules_12012026.pdf
- Effective **December 1, 2025** (the version in force on the review date): https://www.mtd.uscourts.gov/sites/mtd/files/LocalRules_12012025.pdf

The rules below read the same in both versions (checked: L.R. 1.5(a); L.R. 7.1(d)(2)(A), (C) and (E) at the same word limits and the same certificate wording). The one 2025/2026 wording change in L.R. 7.1 is "pro se" becoming "self-represented" in (c) and (d), which does not touch this doc type. Local rules index: https://www.mtd.uscourts.gov/local-rules.

Federal Rules: Fed. R. Civ. P. 5(b)(2)(E) (electronic service on a registered user, read from https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14). The Rule 12(b)(1) and 12(b)(6) grounds named in the exemplar are not reproduced by the template.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MT-FORM-001 | D. Mont. L.R. 1.5(a)(1) | 8½ × 11 inch, printed on one side, one-inch margins, no shading. | the base (`lib/layouts/frcp-motion-brief.yaml`): letter paper, `margin` 72 pt |
| MT-FORM-002 | L.R. 1.5(a)(2) | Typewritten in **14-point** font; double-spaced except quoted material and footnotes. Footnotes at 14 pt. | `size: 14`, `footnote.size: 14` in `typst/layout.yaml` |
| MT-FORM-003 | L.R. 1.5(a)(2) | Double-spacing: 32 pt line boxes at 14 pt (twice the 16 pt single line), on the shared cross-engine model (`lib/typst/xengine.typ`). | `pitch: {body: 32, single: 16}` |
| MT-FORM-004 | L.R. 1.5(a)(3) | Consecutively numbered at the bottom of each page. The cover carries no number (as filed); the tables are roman from i, the memorandum arabic from 1. | `page_number: {align: center, front: lower-roman}` |
| MT-FONT-001 | L.R. 1.5(a)(2) (2025 text read 2026-10-15: "typewritten in 14-point font size") | **No typeface is named.** Face required: none. Font: Times New Roman, the house face (docs/FONTS.md; `template_face` in data/exemplar-fonts.json, the exemplar being Century Schoolbook), Liberation Serif as its vendored metric twin; the docx names the same face through `{font}`; the certificate of compliance names it. | `font-family` in `typst/mtd-motion-brief.typ`; the certificate in `after_tail` |
| MT-CAP-001 | L.R. 1.5(a)(4) and Appendix C, Form A | Counsel block upper left; court title; caption with "Plaintiffs," "v.", "Defendant."; case number and title on the right. | `cover` in `typst/layout.yaml` |
| MT-DIV-001 | L.R. 1.2 | Division printed under the court title (here MISSOULA DIVISION). | `cover` (`{division}`) |
| MT-SIG-001 | L.R. 1.5(b) | Printed name under the signature line. | `closing` |
| MT-FILE-001 | L.R. 7.1(d)(1)(A) | A brief in support of a motion is filed separately from the motion. The motion itself is a separate document, not generated. | outside this template |
| MT-LEN-001 | L.R. 7.1(d)(2)(A) | Briefs in support of a motion are limited to **6500 words**. The render stops above the limit, in every engine. | `words: {limit: 6500, given: word_count}` |
| MT-LEN-002 | L.R. 7.1(d)(2)(C) | A brief of 4000 words or more must include a Table of Contents, Table of Authorities and Exhibit Index. The template always prints a TOC and a TOA; there is no exhibit index (none in the exemplar). | `contents`, `authorities` |
| MT-CERT-001 | L.R. 7.1(d)(2)(E) | A certificate of compliance stating the number of words, excluding caption, certificate of compliance, TOC and TOA, exhibit index and certificate of service. The template prints the count and the typeface. | `after_tail` (`{xd.words}`) |
| MT-SERV-001 | Fed. R. Civ. P. 5(b)(2)(E) | Certificate of service for electronic filing on registered counsel (the exemplar's wording). On by default (`certificate_service`). | `after_tail` (`when: certificate_service`) |

Not used: L.R. 7.1(c)(1) (contact with other parties) applies to non-dispositive motions; a motion to dismiss is dispositive. L.R. 7.1(c)(3) (proposed orders) applies only to extensions and unopposed motions.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Brief in Support of Defendant's Motion to Dismiss Plaintiffs' Complaint and Demand for Jury Trial, *Free Speech Coalition, Inc. v. Knudsen*, No. 9:24-cv-00067-DWM (D. Mont., Missoula Division). 43 pages, filed by the Montana Attorney General's office June 24, 2024 (ECF 18). Text layer present (`pdffonts` shows embedded Century Schoolbook and Times New Roman; `pdftotext` reads it). It includes a TOC, a TOA, a certificate of compliance and a certificate of service.
- Provenance, searches and caveats are in `usage/SOURCE.md`. The motion this brief supports is ECF 17 in the same docket (3 pages, same archive).
- Filer: the defendant. The complaint exemplar in `../complaint/` is filed by the plaintiffs in the same case, so the two folders together show both sides of one docket; the tier-2 rule asks for two or three exemplars from different filers, and this is one case, two filers.

## Sample

- `usage/INPUT-motion-brief.md` is a transcription of the exemplar: the cover (counsel, court title, caption, title), the introduction in full, the background (¶¶ 1–3, with footnotes 1–4), the legal standard in full, the start of Argument I and I.A (the first three paragraphs of I.A), the conclusion, the signature block, the certificate of compliance and the certificate of service (both generated by the template from frontmatter and the body). The TOC and TOA are generated from the headings and the `toa:` links.
- It is an excerpt. Argument I.A (the rest), I.B, II to VI and the Conclusion's sentence beyond the one line are not transcribed. The sample's word count is therefore 1,331 (computed by the shared model), not the 6,496 of the filed brief.
- The sample renders to 11 pages (cover, TOC, TOA, 8 pages of memorandum; the conclusion and its paragraph are kept with the signature block on page 7; the exemplar sets the signature on its own page after the conclusion). The target is 8–14 pages when the exemplar is that long; the exemplar is 43 pages.

### Markdown contract for this doc type

- Frontmatter: `case_number`, `division` (required), `counsel` (list of groups; each group a list of lines; set in two columns, the first half of the groups at the left, or the first `counsel_split` of them), `counsel_role`, `caption` (two sides, `names` and `designation`), `brief_title`, `date`, `signature` (`preamble` lines above the "/s/" block, `signer`, `lines`), `authorities` (the TOA registry; a case name in `*italics*`, as the table prints it), optional `word_count` (overrides the computed count, for a filed brief whose word processor count the attorney has), optional `certificate_service` (default true).
- Body: `#` is a centered section heading (INTRODUCTION, BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION). `##` is Argument level 2 (the template numbers it I., II., ...), `###` level 3 (A., B., ...), `####` level 4 (1., 2., ...). Headings are not numbered by the author.
- Authorities: a link whose target is `toa:KEY`, with the full citation or short form as the text: `[*Reno v. ACLU*, 521 U.S. 844 (1997)](toa:reno)`. Each key must be in `authorities:` (a missing key stops the build). `kind` is `case`, `constitution`, `statute`, `rule`, `regulation` or `other`. An authority on 7 or more pages prints "passim".
- Footnotes: `text[^1]` and `[^1]: text` anywhere in the file, as in the complaint.
- Escape markdown-special brackets in statute text: `entit\[ies\]`, `publish\[\]`.
- Case names and *Id.*/*see* in italic: `*Id.*`.

## Render and overlay

```sh
sh tools/render.sh [--engine latex|docx] courts/ninth-circuit/montana/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/ninth-circuit/montana/federal/district/motion-brief [--engine latex|docx]
just overlay courts/ninth-circuit/montana/federal/district/motion-brief
```

- `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` / `.docx.pdf`: 11 pages each, no warnings; only the vendored face (Times New Roman regular, italic, bold; LaTeX its metric twin newtx), all embedded.
- Line pitch: 32 pt line boxes for the body, 16 pt for the cover, headings, tables, signature and footnotes. The exemplar's brief measured 28.1 pt for a 14 pt Century Schoolbook line.
- `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt` (not committed; red = our render, blue = exemplar, black = both). The sample's body is a prefix of the filed memorandum with the same wording, so the body pages pair with the filed pages that carry the same sentences, not the same page numbers. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record)

`reviews/2026-10-29.md` (the FRCP-base render, every page of all three engines, read as text layout and word boxes; the three engines break every line and page alike). The earlier reviews (`reviews/2026-10-15-docx.md`, `reviews/2026-10-22.md`) record the template before the port.

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel in two columns and the role in italics below, the court's name and MISSOULA DIVISION, the caption ruled at the right and foot, case number and title | Pass. Counsel in one column, as filed, runs the cover onto page 2 (gap 11). |
| 2 (i) | TABLE OF CONTENTS: each heading with its page, "I." and "A." labels in half-inch boxes, half an inch further in per level; the certificates listed | Pass. No "Page" label over the page column (gap 12). |
| 3 (ii) | TABLE OF AUTHORITIES: "Page(s)" on the Cases line, Cases and Statutes, italic case names, a comma, the citation; "2, 5" and "4, 5" in a 72 pt column | Pass. |
| 4 (1) | INTRODUCTION | Pass. |
| 5 (2) | BACKGROUND, footnotes 1–3 at the foot, 14 pt | Pass. |
| 6 (3) | Background continued, footnote 4 | Pass. |
| 7 (4) | LEGAL STANDARD | Pass. |
| 8 (5) | ARGUMENT, I. and A. headings (labels in half-inch boxes, A.'s second line hung) | Pass. |
| 9 (6) | Argument I.A continued | Pass. |
| 10 (7) | The last paragraph, CONCLUSION and its paragraph kept with the signature block (DATED at the left; the office, /s/, the printed name and lines at the right) | Pass. |
| 11 (8) | CERTIFICATE OF COMPLIANCE (Times New Roman, 14 points, 1,331 words), CERTIFICATE OF SERVICE, each signed | Pass. |

## Known gaps and open choices

1. **Font.** Times New Roman 14 pt on every engine (David's 2026-10-17 ruling that Times New Roman is the standard; L.R. 1.5(a)(2) names no face, checked in the 2025 text on 2026-10-15). The exemplar is set in Century Schoolbook (tier 3). The certificate of compliance names the face; if the filer's typeface differs, the certificate must say so.
2. **Word count.** The shared model's count (`{xd.words}`: the body's whitespace-delimited words, the markdown's markers, link targets and footnote marks not counted, headings, quotations and footnotes counted) gives 1,331 for this partial sample (the earlier template's count gave 1,330). For a filed brief, the attorney's software count goes in `word_count` in the frontmatter (`words.given`). The L.R. 7.1(d)(2)(A) 6500-word limit stops the render on whichever count is used.
3. **Partial sample.** Argument I.A (rest), I.B, II–VI and the rest of the Conclusion are not transcribed (see Sample). The TOA therefore lists only the authorities in the transcribed text; the filed TOA lists every authority in the 43-page memorandum (several dozen entries).
4. **Exemplar citation as filed.** *Sable Commc'ns of Cal., Inc. v. FCC* is cited in the exemplar as "492 U.S. 115, 126 (1986)". The reporter year appears to be 1989. The sample transcribes the citation as filed, so the TOA shows 1986; the filer's citation, not the template's, is the error. Not corrected in the sample.
5. **Tier-2 exemplars.** One case, two filers (this brief by the defendant, the complaint by the plaintiffs in `../complaint/`). The eval loop asks for two or three from different filers; the other Montana exemplars found were short notices and briefs (3–6 pages), not memoranda of this type, and were not used.
6. **Exhibit index.** L.R. 7.1(d)(2)(C) requires an Exhibit Index when a brief has 4000 words or more and exhibits are attached. The template prints no exhibit index; the exemplar has none.
7. **Page numbering.** As filed: the cover carries no number, the TOC is i and the TOA ii, and the memorandum starts at 1 on its first page. L.R. 1.5(a)(3) asks consecutive numbers at the bottom; DEF-COVER-001 passes (page 2 prints i).
8. **Motion not generated.** The motion (ECF 17 in the exemplar's docket) is a separate document (L.R. 7.1(d)(1)(A)).
9. **Division.** `division` is free text from the frontmatter; the template does not check the five divisions of L.R. 1.2.
10. **Contents indents.** Each contents level steps half an inch (the model's `step`), so "I." stands half an inch in; the earlier template set "I." at the margin and "A." half an inch in. ACCEPTED (tier 3).
11. **Counsel in two columns.** The exemplar sets counsel in one column with small capitals; one column here runs the cover onto a second page, so the template keeps two (ACCEPTED, as before the port). DEF-COVER-002 reports this and the caption's wrapping (`eval.yaml` `params.cover_structure: report`; typst and docx are listed in `data/cover-structure-baseline.txt`).
12. **No "Page" label over the contents.** The model's contents have no column heading (the authorities have `page_heading`); the exemplar prints "Page". ACCEPTED (tier 3).

## Engines

On the generic federal district brief since fb-595.17.12: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template (`typst/mtd-motion-brief.typ`) only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter (`docx/mtd-motion-brief.lua`) are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar. The Word contents and authorities take their pages from fb render's needles (docxpass.rs) and are written text, not fields: they do not renumber in Word after an edit.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst | `usage/OUTPUT-motion-brief.typst.pdf` (11 pages) | `RESULT: 10 checks passed, 0 failed` | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` (11 pages) | `RESULT: 13 checks passed, 0 failed` | PASS (215/215 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (11 pages) | `RESULT: 14 checks passed, 0 failed` | PASS (215/215 lines) |

DEF-COVER-002 is REPORTED on every engine (gap 11); DEF-TOC-001 and DEF-COVER-001 pass on every engine.
