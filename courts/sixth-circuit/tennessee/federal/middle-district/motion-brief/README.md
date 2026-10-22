# tnmd: motion-brief

Doc type: **motion-brief**, the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), in the United States District Court for the Middle District of Tennessee (`tnmd`).
Folder: `courts/sixth-circuit/tennessee/federal/middle-district/motion-brief/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: excerpt of the 27-page memorandum (pages 1 to 5, the start of Section IV and IV.B, and pages 26 to 27). Pages 6 to 10 and 13 to 25 are not transcribed; see Known gaps 3. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx(.pdf)`, 9 pages each, vendored Times New Roman only, no warnings |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed; the sample skips filed pages, so pages pair loosely) |
| typeface | face required: none. LR 7.03(a) requires "at least 12-point font" and names no face. Times New Roman 12 pt (vendored), the exemplar's face. |
| pages reviewed | 9 of 9, typst and docx (2026-10-22, 60 dpi, every page viewed) |
| tier 1 | `sh tools/check.sh <dir>`: typst 10 passed, 0 failed (with the 25-page limit, `eval.yaml`); `--engine docx` 14 passed, 0 failed (XENG-001..003 gated). |

## Governing rules

Primary sources, fetched 2026-10-14.

- M.D. Tenn. Local Rules of Court (2025 amendments, effective 2025-05-15), https://www.tnmd.uscourts.gov/sites/tnmd/files/2025.05.15%20TNMD%20Local%20Rules%20of%20Court%20-%202025%20amendments%20_0.pdf. LR 7.01 and LR 7.03 quoted and checked against the text.
- Fed. R. Civ. P. 7(b)(1) and 12(b), https://www.law.cornell.edu/rules/frcp/rule_7 and `rule_12` (text checked: 12(b)(1), (2), (3), (6)).

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| TNMD-FORM-001 | LR 7.03(a) | 8½ × 11 paper, one-inch margins. | `page` settings. |
| TNMD-FORM-002 | LR 7.03(a) | At least 12-point font. Footnotes at least 12-point. | `type-size = 12pt`; footnotes use `type-size`. |
| TNMD-FORM-003 | LR 7.03(a) | All material except headings, footnotes and quotations double spaced; footnotes single-spaced. | `pitch-body` (27.6 pt pitch, Word's double line at 12 pt, the exemplar's pitch); headings, caption, footnotes and signature at `pitch-single` (13.8 pt). |
| TNMD-FORM-004 | LR 7.03(a) | All pages numbered at the bottom. | `footer` (centered page number). |
| TNMD-FORM-005 | LR 7.03(a) | The District Judge and Magistrate Judge names placed below the case number on filings after the initial filing. | `judges` (caption right column). |
| TNMD-MEMO-001 | Fed. R. Civ. P. 10(a); LR 7.03(a) | Caption: court, title of the action, file number, judges. | `caption-block`, with a ")" column measured per row. |
| TNMD-MEMO-002 | LR 7.01(a)(2) | A motion requiring a determination of law must be accompanied by a memorandum citing authorities. | Author content. The memorandum is a body of unnumbered paragraphs (briefs are not numbered); each paragraph is indented 0.5 in. |
| TNMD-MEMO-003 | LR 7.01(a)(2) | The memorandum may be separately filed or incorporated. A memorandum incorporated into the motion must be titled "MOTION AND MEMORANDUM OF LAW". | Title in frontmatter. The template does not check the title. |
| TNMD-MEMO-004 | LR 7.03(c) | "JURY DEMAND" appears immediately opposite the style of the case on the first page of the pleading and all subsequent filings, when a jury demand is made in the complaint. | `jury_demand: true` (the complaint's demand carries into this filing). |
| TNMD-MEMO-005 | LR 7.03(a); Fed. R. Civ. P. 11(a) | Names typed or printed beneath signature lines; page limits exclusive of caption, signature and certificate of service. | `signature` frontmatter and the `<!-- signature -->` marker. |
| TNMD-MEMO-006 | LR 5.01 | A certificate of service identifying by name the person served, what was served, the method and the date, for any filing not served through CM/ECF. | `certificate` frontmatter, `<!-- service -->` marker. |
| TNMD-MEMO-007 | LR 7.01(a)(2) | No memorandum or combined motion and memorandum shall exceed 25 pages without leave of Court. | `params.page_limit: 25` in `eval.yaml` (DEF-LEN-001 checks every render). The rendered sample is 9 pages of the 27-page filing. |
| TNMD-MEMO-008 | LR 7.01(a)(1) | Conferral with counsel is not required for motions under Rule 12. | Author content; no template element. |
| TNMD-MEMO-009 | LR 7.03(b) | Citation form: U.S. reports for Supreme Court decisions; Westlaw or Lexis for unreported decisions; authorities not in a reporter attached as exhibits. | Author content. The template does not check citations. |
| TNMD-MEMO-010 | Fed. R. Civ. P. 12(b)(1), (2), (3), (6) | Defenses by motion, with the alternative and conditional grounds stated. | Author content (the sample's conditional structure is the filer's). |

Not produced by this template: the motion itself (a separate document), any proposed order, exhibits, and the declarations some motions need.

## Layout

Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt, ragged right, first-fit line breaks, no kerning, ligatures or hyphenation; every line a box of its pitch (27.6 pt body, double spacing; 13.8 pt single lines: Word's single line at 12 pt).

- Court name and division centered on three single lines, a 27.6 pt gap, then the caption: one row per party line (names, a blank line, the designation italic 0.5 in in, a blank line, "v.", a blank line, ...) in a 3.3 in column, a 0.3 in column of ")" marks (one per line of text), and on the right, line by line from the "v." row down, "Case No.", a blank line, "JURY DEMAND", a blank line and the judge lines (was a column vertically centered on the caption, which Word cannot do alike).
- Title centered and bold, 27.6 pt below the caption and a blank single line above the body.
- Body paragraphs: double spaced, first-line indent 0.5 in on every paragraph, ragged right.
- Headings single-spaced, kept with what follows, a blank single line above and 6.9 pt below: level 1 centered bold (ARGUMENT, CONCLUSION); level 2 the typed label ("I.") in a half-inch box at the margin, the text bold and underlined, hanging (as filed); level 3 the same half an inch in, bold italic (as filed).
- Footnotes 12 pt in 13.8 pt lines, 7 pt apart, 7 pt between the text and the rule.
- Signature block at 3.25 in, kept on one page with the conclusion's last paragraph: "Respectfully submitted,", a blank line, the signer, 6.9 pt, the counsel lines.
- Certificate of service on its own page (as filed): centered heading, paragraph, service entries 0.5 in in, single-spaced, a blank line apart, each kept whole, then the signer's lines at 3.25 in (no "Respectfully submitted,").
- Page number centered at the foot in a 13.8 pt line (footer-descent 30 %).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `title` (the title, centered bold), `division` (required), `case_number`, `caption.parties` (list of `{names, designation}`; "v." between parties), `jury_demand`, `judges` (judge lines), `signature` (`signer`, `lines`), `certificate` (`service`: a list of entries, each a list of lines; `signer`; `lines`).
- Body: paragraphs and headings in markdown; footnotes as `[^n]` with `[^n]:` definitions in the same run of text.
- Markers: a line `<!-- signature -->` places the signature block; a line `<!-- service -->` places the certificate's service entries and signer lines (the certificate's own heading and paragraph are ordinary markdown between them; the heading after the signature opens a new page).
- Heading levels: `#` = level 1 (centered), `##` = level 2 (flush-left argument point), `###` = level 3 (indented sub-point).
- Not supported: numbered paragraphs (briefs do not number them), tables, raw typst.

## Known gaps and open choices

1. **Only one exemplar.** The brief asks for one per doc type; EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The RECAP search (`type=r&court=tnmd`, "motion to dismiss" "memorandum") also found other memoranda in support of Rule 12 motions (*Doe v. HCA Healthcare, Inc.*, No. 3:26-cv-00993; *Lucy v. Skrmetti*, No. 3:26-cv-00998; *Martin v. Western Express, Inc.*, No. 3:26-cv-01178). They were not saved. Tier 2 is therefore **not** judged against two filers yet. Recorded as an open tier-2 item.
2. **Font.** Times New Roman 12 pt (vendored), the exemplar's face; the rule names no face. Footnotes are 12 pt (LR 7.03(a)); the exemplar's are smaller. The docx was EB Garamond 13 pt until fb-595.68.31; it now names the typst face.
3. **Sample is an excerpt.** The sample transcribes the caption and title, filed pages 1 to 5 (the background and Section I), filed page 11 (Section IV and IV.A) and the first part of page 12 (IV.B), and filed pages 26 to 27 (conclusion, signature, certificate of service). Filed pages 6 to 10 (the rest of Section I, Sections II and III) and 13 to 25 (the rest of Section IV, Counts II to VII) are not transcribed. The overlay therefore pairs sample page 6 with the exemplar's page 5 (the closest text) and sample page 7 with page 12. The overlay is a diagnostic, not a score.
4. **No table of contents or table of authorities.** The exemplar has neither (it is a 27-page memorandum with a caption, body, conclusion and certificate). A longer memorandum with a table of contents is not covered by this template; adding one is a template change.
5. **Justification.** The body is ragged right (the cross-engine model: Word and typst break ragged text alike). The rules are silent on justification; the exemplar is justified.
6. **Paragraph indent.** Every body paragraph carries a 0.5 in first-line indent, including the first paragraph after a heading. The exemplar's indent on the first paragraph after a heading could not be confirmed from the text layer; this is a convention choice.
7. **Certificate signature.** The certificate's signer line is printed without "Respectfully submitted," (the exemplar's certificate ends with the signer's name, as rendered here).
8. **Page limit.** LR 7.01(a)(2) limits a memorandum to 25 pages (exclusive of caption, signature and certificate); `eval.yaml` sets `page_limit: 25`, which counts every page, so it is the stricter reading.
9. **Exemplar conventions not followed** (tier 3): the exemplar justifies the body, sets rules above and below the title, a signature line under "/s/", "Page X of Y" in the footer and smaller footnotes.

## Review of the rendered pages (2026-10-22, typst and docx, 60 dpi, every page viewed)

The typst and docx renders break every line and page alike (XENG-001..003), so one review covers both; each page was viewed in both PDFs.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court and division lines; caption with the ")" column, "Case No. 3:26-cv-00918" on the "v." row, "JURY DEMAND" and the two judge lines below it; title centered bold; opening paragraph; footnote 1. | PASS |
| 2 | exemplar p.2 | Opening paragraph ends with footnote 2; BRIEF FACTUAL & PROCEDURAL HISTORY centered; two paragraphs. | PASS |
| 3 | exemplar p.3 | ARGUMENT; "I." heading (label boxed, text underlined, as filed); "A." and "B." headings bold italic half an inch in. | PASS |
| 4 | exemplar p.4 | Paragraphs; footnote 3 at the foot. | PASS |
| 5 | exemplar p.5 | "Per the Complaint…", "Veris argues…". | PASS |
| 6 | exemplar p.5, p.11 | "The Court should reach…"; "IV." heading on two lines, hanging; IV.A. | PASS |
| 7 | exemplar p.11, p.12 | Standard-of-law paragraphs; IV.B heading. | PASS |
| 8 | exemplar p.26 | CONCLUSION; signature block at 3.25 in with the last paragraph. | PASS |
| 9 | exemplar p.27 | CERTIFICATE OF SERVICE on its own page; paragraph; three service entries; signer lines. | PASS |

Reviewed pages: 9 of 9 (typst and docx).

## Engines

- typst (`typst/tnmd-motion-brief.typ`, the reference).
- docx (ported to the cross-engine layout model 2026-10-22, fb-595.68.31): `docx/reference.xml` (the Word styles: `base="xengine"` in the typst face `{font}`, Times New Roman 12 pt; Body Text in exact 27.6 pt line boxes with a 0.5 in first-line indent, Body Keep for the last paragraph before the signature, Footnote Text 12 pt in 13.8 pt lines 7 pt apart, the page number in a 13.8 pt footer line; `fb render` builds `reference.docx` from it) and `docx/tnmd-motion-brief.lua` (court name, caption table, title, headings, signature block and certificate of service as WordprocessingML with the typst pitches and spaces in twips; body paragraphs and footnotes written by pandoc in the styles above). No shell script and no committed `reference.docx` (were `build-reference.sh`, which set EB Garamond 13 pt, `reference.docx` and `tnmd.lua`, which looked for `@signature` and `@service` markers the sample does not use, so the signature and service entries were missing). XENG-001..003 PASS (231/231 lines, 9 pages), gated (`eval.yaml`: `params.cross_engine: gate`).
- latex: none for this doc type.
