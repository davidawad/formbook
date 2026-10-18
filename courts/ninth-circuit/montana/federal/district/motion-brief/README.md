# D. Mont. (mtd): motion brief

Doc type: **motion-brief** (brief in support of a motion to dismiss, the memorandum filed separately from the motion). Court: United States District Court for the District of Montana. Folder: `courts/ninth-circuit/montana/federal/district/motion-brief/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 11 of 11 (every page rendered at 60 dpi and looked at). Nothing here sets `status` in any `court.json`.

## Governing rules

Sources: the District of Montana's Local Rules of Procedure, both versions, fetched from the court's website on 2026-10-14:

- Effective **December 1, 2026**: https://www.mtd.uscourts.gov/sites/mtd/files/LocalRules_12012026.pdf
- Effective **December 1, 2025** (the version in force on the review date): https://www.mtd.uscourts.gov/sites/mtd/files/LocalRules_12012025.pdf

The rules below read the same in both versions (checked: L.R. 1.5(a); L.R. 7.1(d)(2)(A), (C) and (E) at the same word limits and the same certificate wording). The one 2025/2026 wording change in L.R. 7.1 is "pro se" becoming "self-represented" in (c) and (d), which does not touch this doc type. Local rules index: https://www.mtd.uscourts.gov/local-rules.

Federal Rules: Fed. R. Civ. P. 5(b)(2)(E) (electronic service on a registered user, read from https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14). The Rule 12(b)(1) and 12(b)(6) grounds named in the exemplar are not reproduced by the template.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MT-FORM-001 | D. Mont. L.R. 1.5(a)(1) | 8½ × 11 inch, printed on one side, one-inch margins, no shading. | `margins` in `typst/mtd-motion-brief.typ` |
| MT-FORM-002 | L.R. 1.5(a)(2) | Typewritten in **14-point** font; double-spaced except quoted material and footnotes. Footnotes at 14 pt. | `type-size`, `line-pitch`, footnote entry |
| MT-FORM-003 | L.R. 1.5(a)(2) | Double-spacing: 32 pt baseline pitch at 14 pt (measured, see Sample). | `line-pitch`, `body-leading`, `gap` |
| MT-FORM-004 | L.R. 1.5(a)(3) | Consecutively numbered at the bottom of each page. Cover is page i; the front matter is roman, the memorandum arabic from 1. | `footer-num`, page numbering |
| MT-FONT-001 | L.R. 1.5(a)(2) (2025 text read 2026-10-15: "typewritten in 14-point font size") | **No typeface is named.** Face required: none. Font: EB Garamond (vendored, OFL), kept; no court-named substitute applies. Metric-compatibility: n/a. | `font-family` in `typst/mtd-motion-brief.typ` |
| MT-CAP-001 | L.R. 1.5(a)(4) and Appendix C, Form A | Counsel block upper left; court title; caption with "Plaintiffs," "v.", "Defendant."; case number and title on the right. | `counsel-block`, `court-title`, `caption-table` |
| MT-DIV-001 | L.R. 1.2 | Division printed under the court title (here MISSOULA DIVISION). | `court-title` |
| MT-SIG-001 | L.R. 1.5(b) | Printed name under the signature line. | `signature-block` |
| MT-FILE-001 | L.R. 7.1(d)(1)(A) | A brief in support of a motion is filed separately from the motion. The motion itself is a separate document, not generated. | outside this template |
| MT-LEN-001 | L.R. 7.1(d)(2)(A) | Briefs in support of a motion are limited to **6500 words**. The template fails the build above the limit. | `word-limit`, assertion in `mtd-motion-brief` |
| MT-LEN-002 | L.R. 7.1(d)(2)(C) | A brief of 4000 words or more must include a Table of Contents, Table of Authorities and Exhibit Index. The template always prints a TOC and a TOA; there is no exhibit index (none in the exemplar). | `toc-section`, `toa-section` |
| MT-CERT-001 | L.R. 7.1(d)(2)(E) | A certificate of compliance stating the number of words, excluding caption, certificate of compliance, TOC and TOA, exhibit index and certificate of service. The template prints the count and the typeface. | `certificate-compliance` |
| MT-SERV-001 | Fed. R. Civ. P. 5(b)(2)(E) | Certificate of service for electronic filing on registered counsel (the exemplar's wording). On by default (`certificate_service`). | `certificate-service` |

Not used: L.R. 7.1(c)(1) (contact with other parties) applies to non-dispositive motions; a motion to dismiss is dispositive. L.R. 7.1(c)(3) (proposed orders) applies only to extensions and unopposed motions.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Brief in Support of Defendant's Motion to Dismiss Plaintiffs' Complaint and Demand for Jury Trial, *Free Speech Coalition, Inc. v. Knudsen*, No. 9:24-cv-00067-DWM (D. Mont., Missoula Division). 43 pages, filed by the Montana Attorney General's office June 24, 2024 (ECF 18). Text layer present (`pdffonts` shows embedded Century Schoolbook and Times New Roman; `pdftotext` reads it). It includes a TOC, a TOA, a certificate of compliance and a certificate of service.
- Provenance, searches and caveats are in `usage/SOURCE.md`. The motion this brief supports is ECF 17 in the same docket (3 pages, same archive).
- Filer: the defendant. The complaint exemplar in `../complaint/` is filed by the plaintiffs in the same case, so the two folders together show both sides of one docket; the tier-2 rule asks for two or three exemplars from different filers, and this is one case, two filers.

## Sample

- `usage/INPUT-motion-brief.md` is a transcription of the exemplar: the cover (counsel, court title, caption, title), the introduction in full, the background (¶¶ 1–3, with footnotes 1–4), the legal standard in full, the start of Argument I and I.A (the first three paragraphs of I.A), the conclusion, the signature block, the certificate of compliance and the certificate of service (both generated by the template from frontmatter and the body). The TOC and TOA are generated from the headings and the `toa:` links.
- It is an excerpt. Argument I.A (the rest), I.B, II to VI and the Conclusion's sentence beyond the one line are not transcribed. The sample's word count is therefore 1,330 (computed), not the 6,496 of the filed brief.
- The sample renders to 11 pages (cover, TOC, TOA, 8 pages of memorandum; the signature block is alone on page 7, as in the exemplar, where the signature also falls on its own page after the conclusion). The target is 8–14 pages when the exemplar is that long; the exemplar is 43 pages.

### Markdown contract for this doc type

- Frontmatter: `case_number`, `division` (required), `counsel` (list of groups; each group a list of lines; two groups are set in two columns), `counsel_role`, `caption` (two sides, `names` and `designation`), `brief_title`, `date`, `signature` (`preamble` lines above the "/s/" block, `signer`, `lines`), `authorities` (the TOA registry), optional `word_count` (overrides the computed count, for a filed brief whose word processor count the attorney has), optional `certificate_service` (default true).
- Body: `#` is a centered section heading (INTRODUCTION, BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION). `##` is Argument level 2 (the template numbers it I., II., ...), `###` level 3 (A., B., ...), `####` level 4 (1., 2., ...). Headings are not numbered by the author.
- Authorities: a link whose target is `toa:KEY`, with the full citation or short form as the text: `[*Reno v. ACLU*, 521 U.S. 844 (1997)](toa:reno)`. Each key must be in `authorities:` (a missing key stops the build). `kind` is `case`, `constitution`, `statute`, `rule`, `regulation` or `other`. An authority on 7 or more pages prints "passim".
- Footnotes: `text[^1]` and `[^1]: text` anywhere in the file, as in the complaint.
- Escape markdown-special brackets in statute text: `entit\[ies\]`, `publish\[\]`.
- Case names and *Id.*/*see* in italic: `*Id.*`.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/ninth-circuit/montana/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/montana/federal/district/motion-brief fsc-knudsen-motion-brief
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 11 pages. Typst compiled with no warnings. Only the vendored font: `pdffonts` shows EBGaramond-Regular, -Italic and -Bold, all embedded.
- Line pitch: 32 pt between body lines (the complaint's measured value, the same settings). The exemplar's brief measured 28.1 pt for a 14 pt Century Schoolbook line; the template uses 32 pt because EB Garamond's line box is taller relative to its size (0.65 em box, `body-leading = 1.64em`).
- `usage/OVERLAY-fsc-knudsen-motion-brief.pdf` and `.txt` (red = our render, blue = exemplar, black = both). Page map by word overlap: ours p.1 ↔ filed p.1 (95%), ours p.2 ↔ filed p.2 (43%), p.3 ↔ filed p.3 (34%), p.4 ↔ filed p.8 (83%), p.5 ↔ filed p.9 (55%), p.6 ↔ filed p.10 (47%), p.7 ↔ filed p.13 (62%), p.8 ↔ filed p.14 (75%), p.9 ↔ filed p.15 (62%), p.10 ↔ filed p.42 (74%), p.11 ↔ filed p.43 (72%). The pairing is coarse: the sample's body is a prefix of the filed memorandum with the same wording, so the body pages pair with the filed pages that carry the same sentences, not the same page numbers. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record)

Each page was rendered at 60 dpi and looked at after the last change.

| Page | What it is | Finding |
|---|---|---|
| 1 (i) | Cover: counsel in two columns, court title, caption, case number, title | OK. The cover fits on page 1 after three changes (two counsel groups, a wider party column, tighter spacing between counsel, title and caption); the first render spilled "Defendant." onto page 2. |
| 2 (ii) | TABLE OF CONTENTS, page numbers per heading, dot leaders | OK. Level 2 and 3 headings indented; the wrapped "minors." line hangs under the title. |
| 3 (iii) | TABLE OF AUTHORITIES: Cases, Statutes; page lists | OK. Entries alphabetical; "Page(s)" heading. Authorities cited on 2 or more pages list all pages. |
| 4 (1) | INTRODUCTION | OK after the first-line indent fix (paragraphs were flush left in the first render). |
| 5 (2) | BACKGROUND, footnotes 1–3 at the foot | OK. Footnotes 1–3 at the foot of the page, at 14 pt. |
| 6 (3) | Background continued, footnote 4 at foot | OK. |
| 7 (4) | LEGAL STANDARD, ARGUMENT | OK after the heading-gap fix (the ARGUMENT heading overprinted the previous paragraph's last line in the first render). |
| 8 (5) | Argument I, I.A (level 2 and 3 headings) | OK. "I." and "A." labels hang correctly. |
| 9 (6) | Argument I.A continued, CONCLUSION | OK after the heading-gap fix (CONCLUSION overprinted the previous line in the first render). |
| 10 (7) | Signature block (DATED, firm, /s/, printed name) on its own page | OK. Alone on the page, as in the exemplar (conclusion on page 6, signature page 7). |
| 11 (8) | CERTIFICATE OF COMPLIANCE (word count, typeface), CERTIFICATE OF SERVICE | OK after the certificate signature indent fix (the second line of the signer name was flush left in the first render). |

Defects found and fixed during review (all template defects):
1. The cover spilled onto page 2 (counsel in one 13-line column). Fixed by the two-group frontmatter, a wider party column and tighter cover spacing.
2. Body paragraphs had no first-line indent (global `first-line-indent: 0pt`). Fixed: the body paragraphs take `para-indent`; headings and blocks set their own.
3. Headings after a paragraph had no gap above, so they overprinted the previous line. Fixed: `above: gap` on every heading.
4. The certificate of compliance signer name's second line was not indented. Fixed: the signature sits in a two-column grid.
5. A stray `if` line with no effect, removed.

Reviewed pages: 11 of 11.

## Known gaps and open choices

1. **Font.** EB Garamond (vendored, OFL) at 14 pt, not Century Schoolbook (exemplar). L.R. 1.5(a)(2) names no face (checked in the 2025 text on 2026-10-15), so the court-named-face substitution (`docs/FONTS.md`) does not apply and the default face stays. The certificate of compliance names EB Garamond; if the filer's typeface differs, the certificate must say so. If David prefers the exemplar's look, the vendored Century substitute is TeX Gyre Schola (`font-family` change only; line counts would need a re-check). Style choice: noted for David.
2. **Word count.** The template's count is an approximation of a word processor's count: whitespace-separated tokens of the markdown body that contain a letter or digit, footnote labels and `(toa:KEY)` targets excluded. It gives 1,330 for this partial sample. For a filed brief, the attorney's software count goes in `word_count` in the frontmatter. The L.R. 7.1(d)(2)(A) 6500-word limit is enforced on whichever count is used.
3. **Partial sample.** Argument I.A (rest), I.B, II–VI and the rest of the Conclusion are not transcribed (see Sample). The TOA therefore lists only the authorities in the transcribed text; the filed TOA lists every authority in the 43-page memorandum (several dozen entries).
4. **Exemplar citation as filed.** *Sable Commc'ns of Cal., Inc. v. FCC* is cited in the exemplar as "492 U.S. 115, 126 (1986)". The reporter year appears to be 1989. The sample transcribes the citation as filed, so the TOA shows 1986; the filer's citation, not the template's, is the error. Not corrected in the sample.
5. **Tier-2 exemplars.** One case, two filers (this brief by the defendant, the complaint by the plaintiffs in `../complaint/`). The eval loop asks for two or three from different filers; the other Montana exemplars found were short notices and briefs (3–6 pages), not memoranda of this type, and were not used.
6. **Exhibit index.** L.R. 7.1(d)(2)(C) requires an Exhibit Index when a brief has 4000 words or more and exhibits are attached. The template prints no exhibit index; the exemplar has none.
7. **Page numbering.** The cover is numbered i (the rule numbers every page; the exemplar's cover carries no visible number). The TOC is ii and the TOA iii, and the memorandum starts at 1 on its first page.
8. **Motion not generated.** The motion (ECF 17 in the exemplar's docket) is a separate document (L.R. 7.1(d)(1)(A)).
9. **Division.** `division` is free text from the frontmatter; the template does not check the five divisions of L.R. 1.2.
10. **Overlay file names.** The task brief named the overlay `<id>-overlay.pdf`; `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and reads `OUTPUT-<id>.pdf`. The tools win; the names follow them.

## Engines

**docx** (`docx/`): `reference.docx` (built by `sh docx/build-reference.sh docx/reference.docx` from `reference-styles.xml`), `mtd-motion-brief.lua` (cover, caption, headings I./A./1., TOC and TOA, signature, certificates), `render.sh` and `pages.awk` (two-pass page numbers), `fonts.conf`.

Render: `export FONTCONFIG_FILE=$PWD/docx/fonts.conf`, then `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`. Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (11 pages). The TOC and TOA page numbers come from the LibreOffice PDF of a first pass (`docx/render.sh` repeats the build until the numbers settle; a heading or authority not found stops the build with a `MISSING` line).

- Matches the typst output: EB Garamond 14 pt; exact 32 pt double spacing; 1 in margins on Letter; roman numbering for the cover, TOC and TOA (i, ii, iii) and arabic from 1 for the memorandum; cover and caption as typst; TOC with dot leaders and page numbers (certificates included); TOA grouped by kind with italic case names, the same page numbers as typst for 13 of 14 authorities (Benavidez: 4, 5 here, 4 in typst, because the argument citation falls on p.5); headings I., A., 1. hanging; signature block; certificate of compliance with the word count (1,330, the same count as typst) and the certificate of service.
- Differs: pagination is LibreOffice's. The memorandum is 8 pages, as typst, but the ARGUMENT heading moves to p.5 (typst p.4), so the TOC shows ARGUMENT on 5. Exact line spacing puts text about 5 pt lower than typst. The TOC and TOA are written text, not Word fields: they do not renumber in Word after an edit; rerun `docx/render.sh`. Word may paginate differently.
- BLOCKED: GATE-RUN (`tools/check.sh <this folder> --engine docx`): exits 2 before any gate runs, because this folder has no `court.json` and no `checks.yaml` (the court folder has neither either). No docx gate result is recorded. The rule checks (MT-FORM-001 to MT-SERV-001, including MT-LEN-001, MT-LEN-002 and MT-CERT-001) are therefore not run by the tool; the visual review is in `reviews/2026-10-15-docx.md`.
