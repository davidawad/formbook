# tnmd: motion-brief

Doc type: **motion-brief**, the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), in the United States District Court for the Middle District of Tennessee (`tnmd`).
Folder: `courts/sixth-circuit/tennessee/federal/middle-district/motion-brief/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-veris-3-26-cv-00918-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-veris-motion-brief.md`: excerpt of the 27-page memorandum (pages 1 to 5, the start of Section IV and IV.B, and pages 26 to 27). Pages 6 to 10 and 13 to 25 are not transcribed; see Known gaps 3. |
| render | ok: `samples/OUTPUT-veris-motion-brief.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-veris-motion-brief.pdf` and `samples/OVERLAY-veris-motion-brief.txt` (sample page 6 pairs with exemplar page 5 and page 7 with exemplar page 12, because the transcription skips pages) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |
| tier 1 | not gated: `tools/check.sh` expects a court folder with `court.json` and `rules.md`, which this doc-type folder is not, and the brief forbids touching `tools/`. The rule rows below are the tier-1 record. |

## Governing rules

Primary sources, fetched 2026-10-14.

- M.D. Tenn. Local Rules of Court (2025 amendments, effective 2025-05-15), https://www.tnmd.uscourts.gov/sites/tnmd/files/2025.05.15%20TNMD%20Local%20Rules%20of%20Court%20-%202025%20amendments%20_0.pdf. LR 7.01 and LR 7.03 quoted and checked against the text.
- Fed. R. Civ. P. 7(b)(1) and 12(b), https://www.law.cornell.edu/rules/frcp/rule_7 and `rule_12` (text checked: 12(b)(1), (2), (3), (6)).

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| TNMD-FORM-001 | LR 7.03(a) | 8½ × 11 paper, one-inch margins. | `page` settings. |
| TNMD-FORM-002 | LR 7.03(a) | At least 12-point font. Footnotes at least 12-point. | `type-size = 13pt` (Known gaps 2); footnotes use `type-size`. |
| TNMD-FORM-003 | LR 7.03(a) | All material except headings, footnotes and quotations double spaced; footnotes single-spaced. | `body-leading` (27.6 pt pitch); headings, caption, footnotes and signature at `single-pitch` (15 pt). |
| TNMD-FORM-004 | LR 7.03(a) | All pages numbered at the bottom. | `footer` (centered page number). |
| TNMD-FORM-005 | LR 7.03(a) | The District Judge and Magistrate Judge names placed below the case number on filings after the initial filing. | `judges` (caption right column). |
| TNMD-MEMO-001 | Fed. R. Civ. P. 10(a); LR 7.03(a) | Caption: court, title of the action, file number, judges. | `caption-block`, with a ")" column measured per row. |
| TNMD-MEMO-002 | LR 7.01(a)(2) | A motion requiring a determination of law must be accompanied by a memorandum citing authorities. | Author content. The memorandum is a body of unnumbered paragraphs (briefs are not numbered); each paragraph is indented 0.5 in. |
| TNMD-MEMO-003 | LR 7.01(a)(2) | The memorandum may be separately filed or incorporated. A memorandum incorporated into the motion must be titled "MOTION AND MEMORANDUM OF LAW". | Title in frontmatter. The template does not check the title. |
| TNMD-MEMO-004 | LR 7.03(c) | "JURY DEMAND" appears immediately opposite the style of the case on the first page of the pleading and all subsequent filings, when a jury demand is made in the complaint. | `jury_demand: true` (the complaint's demand carries into this filing). |
| TNMD-MEMO-005 | LR 7.03(a); Fed. R. Civ. P. 11(a) | Names typed or printed beneath signature lines; page limits exclusive of caption, signature and certificate of service. | `signature` frontmatter and the `@signature` marker. |
| TNMD-MEMO-006 | LR 5.01 | A certificate of service identifying by name the person served, what was served, the method and the date, for any filing not served through CM/ECF. | `certificate` frontmatter, `@service` marker. |
| TNMD-MEMO-007 | LR 7.01(a)(2) | No memorandum or combined motion and memorandum shall exceed 25 pages without leave of Court. | Not enforced by the template (page count is a filing check). The rendered sample is 9 pages of the 27-page filing. |
| TNMD-MEMO-008 | LR 7.01(a)(1) | Conferral with counsel is not required for motions under Rule 12. | Author content; no template element. |
| TNMD-MEMO-009 | LR 7.03(b) | Citation form: U.S. reports for Supreme Court decisions; Westlaw or Lexis for unreported decisions; authorities not in a reporter attached as exhibits. | Author content. The template does not check citations. |
| TNMD-MEMO-010 | Fed. R. Civ. P. 12(b)(1), (2), (3), (6) | Defenses by motion, with the alternative and conditional grounds stated. | Author content (the sample's conditional structure is the filer's). |

Not produced by this template: the motion itself (a separate document), any proposed order, exhibits, and the declarations some motions need.

## Layout

- Court name and division centered on three single-spaced lines; caption with the ")" column; "Case No." and "JURY DEMAND" with the judge lines in the right column.
- Title centered and bold below the caption.
- Body paragraphs: double spaced, first-line indent 0.5 in on every paragraph (including the first after a heading), ragged right.
- Headings: level 1 centered bold (ARGUMENT, CONCLUSION); level 2 bold, flush left (the argument points, I, IV); level 3 bold, indented 0.5 in (A, B). Each heading has a blank double-spaced line above and below.
- Footnotes at the foot of the page, single-spaced, 13 pt.
- Signature block on the right half of the page, opening "Respectfully submitted," then the signer and the counsel lines.
- Certificate of service: centered heading, paragraph, service entries single-spaced one after another, then the signer's line (no "Respectfully submitted," opening).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `title` (the title, centered bold), `division` (required), `case_number`, `caption.parties` (list of `{names, designation}`; "v." between parties), `jury_demand`, `judges` (judge lines), `signature` (`signer`, `lines`), `certificate` (`service`: a list of entries, each a list of lines; `signer`; `lines`).
- Body: paragraphs and headings in markdown; footnotes as `[^n]` with `[^n]:` definitions in the same run of text.
- Markers: a line `@signature` places the signature block; a line `@service` places the certificate's service entries and signer line (the certificate's own heading and paragraph are ordinary markdown above it).
- Heading levels: `#` = level 1 (centered), `##` = level 2 (flush-left argument point), `###` = level 3 (indented sub-point).
- Not supported: numbered paragraphs (briefs do not number them), tables, raw typst.

## Known gaps and open choices

1. **Only one exemplar.** The brief asks for one per doc type; EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The RECAP search (`type=r&court=tnmd`, "motion to dismiss" "memorandum") also found other memoranda in support of Rule 12 motions (*Doe v. HCA Healthcare, Inc.*, No. 3:26-cv-00993; *Lucy v. Skrmetti*, No. 3:26-cv-00998; *Martin v. Western Express, Inc.*, No. 3:26-cv-01178). They were not saved. Tier 2 is therefore **not** judged against two filers yet. Recorded as an open tier-2 item.
2. **Font size.** The rule requires at least 12 point and names no font. The template uses EB Garamond (vendored) at 13 pt, for the same reason as the complaint (see `../complaint/README.md`, Known gaps 2). Footnotes are 13 pt as well.
3. **Sample is an excerpt.** The sample transcribes the caption and title, filed pages 1 to 5 (the background and Section I), filed page 11 (Section IV and IV.A) and the first part of page 12 (IV.B), and filed pages 26 to 27 (conclusion, signature, certificate of service). Filed pages 6 to 10 (the rest of Section I, Sections II and III) and 13 to 25 (the rest of Section IV, Counts II to VII) are not transcribed. The overlay therefore pairs sample page 6 with the exemplar's page 5 (the closest text) and sample page 7 with page 12. The overlay is a diagnostic, not a score.
4. **No table of contents or table of authorities.** The exemplar has neither (it is a 27-page memorandum with a caption, body, conclusion and certificate). A longer memorandum with a table of contents is not covered by this template; adding one is a template change.
5. **Justification.** The body is ragged right. The rules are silent on justification and the exemplar's justification could not be read from the text layer. Tier-2 convention choice; not asserted.
6. **Paragraph indent.** Every body paragraph carries a 0.5 in first-line indent, including the first paragraph after a heading. The exemplar's indent on the first paragraph after a heading could not be confirmed from the text layer; this is a convention choice.
7. **Certificate signature.** The certificate's signer line is printed without "Respectfully submitted," (the exemplar's certificate ends with the signer's name, as rendered here).
8. **Page limit.** LR 7.01(a)(2) limits a memorandum to 25 pages (exclusive of caption, signature and certificate). The template does not enforce this; the filing's own page count must be checked before filing.

## Review of the rendered pages (current PDF, 60 dpi, every page viewed)

- Page 1: court name and division; caption with the ")" column, "Case No. 3:26-cv-00918", "JURY DEMAND", the two judge lines; the title centered in bold; the opening paragraph with footnote 1 at the foot of the page. Pass.
- Page 2: opening paragraph continued (ending with footnote 2 at the foot); "BRIEF FACTUAL & PROCEDURAL HISTORY" centered; two paragraphs, footnote 2 at single spacing. Pass.
- Page 3: the paragraph continued; "ARGUMENT" centered; "I. The Court Should Dismiss…" (level 2, wraps to two lines); paragraph; "A. Standard of Law." (level 3) with its paragraph. Pass.
- Page 4: "B. Veris Pleads…" (level 3) and its paragraphs; the "Here, the Complaint…" paragraph with footnote 3 reference. Pass.
- Page 5: the paragraph continued; "Per the Complaint…"; "Veris argues…"; footnote 3 at the foot of the page, single-spaced. Pass.
- Page 6: the "The Court should reach the same result here…" paragraph; "IV. In the Alternative…" (level 2, two lines); the conditional paragraph; "A. Standard of Law." Pass.
- Page 7: the standard-of-law paragraphs (Iqbal, Carper, Hill). Pass.
- Page 8: "B. Veris Fails to Plausibly State a Defamation Claim…" (level 3) and its paragraph; "CONCLUSION" centered; conclusion paragraph; "Respectfully submitted," signature block on the right half, with the counsel lines. Pass.
- Page 9: "CERTIFICATE OF SERVICE" centered; certificate paragraph; the three service entries single-spaced; the certificate signer line (no opening line). Pass.

Gate 2 rows are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).
