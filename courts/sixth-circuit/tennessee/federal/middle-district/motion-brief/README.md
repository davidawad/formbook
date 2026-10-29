# tnmd: motion-brief

Doc type: **motion-brief**, the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), in the United States District Court for the Middle District of Tennessee (`tnmd`).
Folder: `courts/sixth-circuit/tennessee/federal/middle-district/motion-brief/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, Buchalter LLP for the Gefteas defendants; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: excerpt of the 27-page memorandum (pages 1 to 5, the start of Section IV and IV.B, and pages 26 to 27). Pages 6 to 10 and 13 to 25 are not transcribed; see Known gaps 3. |
| render | ok (2026-10-29, fb-595.17.18): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 10 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with M.D. Tenn.'s local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay courts/sixth-circuit/tennessee/federal/middle-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed; the sample skips filed pages, so pages pair loosely) |
| typeface | face required: none. LR 7.03(a) requires "at least 12-point font" and names no face. Times New Roman 12 pt (vendored), the exemplar's face, in every engine. |
| pages reviewed | 10 of 10 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |

## Governing rules

Primary sources, fetched 2026-10-14.

- M.D. Tenn. Local Rules of Court (2025 amendments, effective 2025-05-15), https://www.tnmd.uscourts.gov/sites/tnmd/files/2025.05.15%20TNMD%20Local%20Rules%20of%20Court%20-%202025%20amendments%20_0.pdf. LR 7.01 and LR 7.03 quoted and checked against the text.
- Fed. R. Civ. P. 7(b)(1) and 12(b), https://www.law.cornell.edu/rules/frcp/rule_7 and `rule_12` (text checked: 12(b)(1), (2), (3), (6)).

| ID | Rule | Requirement | Where it is in the layout |
|---|---|---|---|
| TNMD-FORM-001 | LR 7.03(a) | 8½ × 11 paper, one-inch margins. | The base. |
| TNMD-FORM-002 | LR 7.03(a) | At least 12-point font. Footnotes at least 12-point. | The base's 12 pt, footnotes too. |
| TNMD-FORM-003 | LR 7.03(a) | All material except headings, footnotes and quotations double spaced; footnotes single-spaced. | `pitch.body: 27.6` (Word's double line at 12 pt, the exemplar's pitch); headings, caption, footnotes and signature single-spaced (13.8 pt). |
| TNMD-FORM-004 | LR 7.03(a) | All pages numbered at the bottom. | The base's centered page number. |
| TNMD-FORM-005 | LR 7.03(a) | The District Judge and Magistrate Judge names placed below the case number on filings after the initial filing. | `judges` (caption, right column). |
| TNMD-MEMO-001 | Fed. R. Civ. P. 10(a); LR 7.03(a) | Caption: court, title of the action, file number, judges. | `front`, with a ")" column the model measures per row. |
| TNMD-MEMO-002 | LR 7.01(a)(2) | A motion requiring a determination of law must be accompanied by a memorandum citing authorities. | Author content; unnumbered paragraphs, each indented 0.5 in. |
| TNMD-MEMO-003 | LR 7.01(a)(2) | The memorandum may be separately filed or incorporated; an incorporated one is titled "MOTION AND MEMORANDUM OF LAW". | `brief_title` in the frontmatter; not checked. |
| TNMD-MEMO-004 | LR 7.03(c) | "JURY DEMAND" immediately opposite the style of the case on the first page, when the complaint demanded a jury. | `jury_demand: true`. |
| TNMD-MEMO-005 | LR 7.03(a); Fed. R. Civ. P. 11(a) | Names typed or printed beneath signature lines; page limits exclusive of caption, signature and certificate of service. | `closing` (`signature`). |
| TNMD-MEMO-006 | LR 5.01 | A certificate of service identifying the person served, what was served, the method and the date, for any filing not served through CM/ECF. | The body's CERTIFICATE OF SERVICE section (`tail`), then `certificate` (`after_tail`). |
| TNMD-MEMO-007 | LR 7.01(a)(2) | No memorandum or combined motion and memorandum shall exceed 25 pages without leave of Court. | `eval.yaml` `params.page_limit: 25` (DEF-LEN-001, every engine; counts every page, the stricter reading). |
| TNMD-MEMO-008 | LR 7.01(a)(1) | Conferral with counsel is not required for motions under Rule 12. | Author content. |
| TNMD-MEMO-009 | LR 7.03(b) | Citation form: U.S. reports for Supreme Court decisions; Westlaw or Lexis for unreported decisions. | Author content. |
| TNMD-MEMO-010 | Fed. R. Civ. P. 12(b)(1), (2), (3), (6) | Defenses by motion, with the alternative and conditional grounds stated. | Author content. |

Not produced: the motion itself (a separate document), any proposed order, exhibits, declarations.

## Layout

The generic FRCP brief with M.D. Tenn.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/tnmd-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Court name and division centered, a double line below; the caption in two rows: the plaintiff's names, a blank line, the designation half an inch in, in italics; then a blank line, "v.", a blank line and the defendants the same; a column of ")" beside every line. At the right, from the "v." line down: "Case No." and the number, a blank line, "JURY DEMAND" (LR 7.03(c)), a blank line, each judge a blank line apart (LR 7.03(a)).
- The title bold and centered between two rules across the page, a blank line from each (the exemplar's).
- Body double-spaced (27.6 pt), first-line indent 0.5 in on every paragraph.
- Headings single-spaced, bold, a blank line above and 6.9 pt below, kept with what follows: level 1 centered (ARGUMENT, CONCLUSION); level 2 at the margin, its later lines hung half an inch; level 3 half an inch in, bold italic (as filed). The author types the numbers.
- Footnotes 12 pt, single-spaced, 7 pt apart.
- Signature block at 3.25 in, kept on one page with the conclusion's last paragraph: "Respectfully submitted,", a blank line, the signer, 6.9 pt, the counsel lines.
- Certificate of service on its own page (as filed): the body's CERTIFICATE OF SERVICE section double-spaced, then the service entries half an inch in, a blank line apart, each kept whole, and the signer's lines at 3.25 in.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `brief_title`; `division`; `case_number`; `case_label` (default "Case No."); `caption.parties` (two sides, each `{names, designation}`); `jury_demand`; `judges` (lines); `signature` (`signer`, `lines`); `certificate` (`service`: a list of entries, each a list of lines; `signer`; `lines`).
- Body: `#` level 1, `##` level 2, `###` level 3 headings; paragraphs; footnotes as `[^n]` with `[^n]:` definitions. A level-1 heading starting "CERTIFICATE OF SERVICE" opens the certificate: it and its text are set on a new page after the signature, followed by the frontmatter's service entries.
- Not supported: numbered paragraphs (briefs do not number them), raw typst, a caption of more than two sides.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The RECAP search (`type=r&court=tnmd`, "motion to dismiss" "memorandum") also found other memoranda in support of Rule 12 motions (*Doe v. HCA Healthcare, Inc.*, No. 3:26-cv-00993; *Lucy v. Skrmetti*, No. 3:26-cv-00998; *Martin v. Western Express, Inc.*, No. 3:26-cv-01178), not saved. Tier 2 is **not** judged against two filers yet (OPEN).
2. **Font.** Times New Roman 12 pt (vendored), the exemplar's face; the rule names no face. Footnotes are 12 pt (LR 7.03(a)); the exemplar's are smaller.
3. **Sample is an excerpt.** The sample transcribes the caption and title, filed pages 1 to 5 (the background and Section I), filed page 11 (Section IV and IV.A), the first part of page 12 (IV.B), and filed pages 26 to 27 (conclusion, signature, certificate of service). The overlay therefore pairs pages loosely.
4. **No table of contents or table of authorities.** The exemplar has neither.
5. **Justification.** The body is ragged right (the cross-engine model); the rules are silent; the exemplar is justified (ACCEPTED).
6. **Point headings not underlined.** The exemplar underlines its level-2 headings (tier 2). Not here: in an underlined run Word's PDF (LibreOffice) splits "12(b)(6)" into two words at the joiner the shared docx code puts between ")(", so XENG-003 fails on the heading "IV. ... Rule of Civil Procedure 12(b)(6).". The missing shared feature: an underline in `lib/docx` that keeps ")(" one word (ACCEPTED until it lands; restore `underline: true` on level 2 then).
7. **Page limit.** LR 7.01(a)(2) limits a memorandum to 25 pages exclusive of caption, signature and certificate; `eval.yaml` counts every page, the stricter reading.
8. **Exemplar conventions not followed** (tier 3): a signature line under "/s/", "Page X of Y" in the footer, smaller footnotes.

## Review of the rendered pages (Gate 2 record, 10 of 10 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx, 232/232 lines), so one row per page covers all three. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`); this pod has no image viewer. DEF-COVER-002 (page 1 against the exemplar) passes on typst and latex; on docx it is REPORTED (baseline): the measurer reads LibreOffice's ")" and "JURY DEMAND" cells as one segment at the margin, a reading of the table, not a difference on the page (the docx line boxes put "JURY DEMAND" at 331 pt, as typst does).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court and division lines; caption with the ")" column, "Case No. 3:26-cv-00918" on the "v." line, "JURY DEMAND" and the two judge lines a blank line apart below it; the four-line title between two rules; opening paragraph; footnote 1 | OK. |
| 2 | Opening paragraph (end) with footnote 2; BRIEF FACTUAL & PROCEDURAL HISTORY | OK. |
| 3 | ARGUMENT; "I." heading; "A." and "B." headings bold italic half an inch in | OK. |
| 4 | Paragraphs; the page ends short: the next line cites footnote 3, which moves on to page 5 with its note (every engine alike) | OK. |
| 5 | Paragraphs, footnote 3 | OK. |
| 6 | "IV." heading on two lines, hung; IV.A. | OK. |
| 7 | Standard-of-law paragraphs | OK. |
| 8 | IV.B heading and its paragraph; the page ends short: CONCLUSION, its paragraph and the signature are kept together on page 9 | ACCEPTED (tier 2: the signature never stands alone). |
| 9 | CONCLUSION; the signature block at 3.25 in with the last paragraph | OK. |
| 10 | CERTIFICATE OF SERVICE on its own page; paragraph; three service entries; signer lines | OK. |

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/tennessee/federal/middle-district/motion-brief --engine typst   # 12 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/tennessee/federal/middle-district/motion-brief --engine latex   # 15 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/tennessee/federal/middle-district/motion-brief --engine docx    # 15 passed, 0 failed
```

`tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has none, so it does not run here.

## Engines

typst (primary): `typst/main.typ` -> `typst/tnmd-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.18). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx. BLOCKED: none.
