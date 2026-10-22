# nyed: motion-brief (memorandum of law in support of a Rule 12(b) motion to dismiss)

Doc type: **memorandum of law in support of a motion** in the United States District Court for the Eastern District of New York (`nyed`), for a motion to dismiss under Fed. R. Civ. P. 12(b).
Folder: `courts/second-circuit/new-york/federal/eastern-district/motion-brief/` (self-contained; no court-root `typst/` or `usage/` touched).

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/FILED-EXAMPLE-motion-brief.pdf` (Ropes & Gray for Qatar National Bank, 47 pp.) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (counsel for a Florida state official, 34 pp.). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: selected passages of the Force memorandum (preliminary statement, Argument I.A to I.C, II, conclusion, certificate of service), with the template's frontmatter. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages (cover, TOC, TOA, body 1 to 7), vendored Times New Roman only, no warnings (`tools/render.sh`), on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.26). |
| overlay | ok: `usage/OVERLAY-force-memorandum.pdf` (red = ours, blue = filed) and `usage/OVERLAY-force-memorandum.txt` (page map). The overlay reads the first exemplar in name order (Force). Regenerated 2026-10-15 from `usage/FILED-EXAMPLE-motion-brief.pdf` (47 pages, restored from the URL in `usage/SOURCE.md`). |
| pages reviewed | 10 of 10 on typst and docx (every page rendered at 40 dpi and viewed side by side after the last template change, 2026-10-22). |
| word count | 1792 words by the template's count (see Known gaps 1). |
| tier-2 exemplars | 2 filers (EVAL-LOOP minimum). |

Naming: the brief's `<id>.pdf` / `<id>-overlay.pdf` are written as `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, because `tools/render.sh` and `tools/overlay.sh` read and write those names (file role in the name, per CLAUDE.md).

## Governing rules

Verified 2026-10-14 against the joint EDNY/SDNY Local Civil Rules, "As Amended", effective January 2, 2026, downloaded from https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf (text read from the PDF, pp. 20 to 22 of the rules).

| Source | Requirement | Where it is in the template |
|---|---|---|
| Local Civil Rule 7.1(a)(1) | A motion includes a notice of motion specifying the rules under which it is brought. | Not part of this doc type (the notice is a separate filing). The memorandum's Preliminary Statement names the rules (Fed. R. Civ. P. 12(b)(2), (5), (6)). |
| Local Civil Rule 7.1(a)(2) | A memorandum of law setting forth the cases and other authorities relied on, divided "under appropriate headings, into as many parts as there are issues to be determined". | Headings `#` to `####` (Argument I, A, B, 1, C; II). Each heading is in the TOC. |
| Local Civil Rule 7.1(b)(1) | "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type". | `type-size = 12pt` (body, headings, caption, TOC, TOA, signature); `footnote-size = 10pt`. |
| Local Civil Rule 7.1(b)(2) | At least one-inch margins on all sides. | `margins = 1in` on all sides, every page including the cover. |
| Local Civil Rule 7.1(b)(3) | All text double-spaced, except headings, footnotes, or block quotations (which may be single-spaced). | `line-pitch = 24pt`: body baseline pitch measured at 24.0 pt. Headings, footnotes, caption, TOC and TOA are single-spaced under the exceptions. |
| Local Civil Rule 7.1(c), first paragraph | Briefs supporting a motion, prepared with a computer, may not exceed 8,750 words; the caption, tables of contents and authorities, signature blocks and required certificates are excluded; footnotes are included. | `count-words()` counts the body markdown, footnotes included, and nothing else. The build fails if the count exceeds `word_limit` (default 8750). |
| Local Civil Rule 7.1(c), certificate | A brief prepared with a computer must include a certificate by the attorney that it complies with the word limit, stating the number of words. The preparer may rely on the word-processing program's count. | `word-certificate()`: "Certificate of Compliance", stating the template's count. The attorney must replace it with the count from the word-processing program before filing (see Known gaps 1). |
| Local Civil Rule 7.1(c), last sentence | If the court sets a page limit, each page is 350 words. | `word_limit` frontmatter field: set it to the court's word equivalent when the court grants more than 8,750 words. |
| Fed. R. Civ. P. 10(a) (caption) | Applies to pleadings. | Not a rule for a memorandum; the caption follows the exemplars' practice (convention, `C`). |
| Fed. R. Civ. P. 12(b)(2), (5), (6) | The defenses the Force memorandum raises. | Content, cited by the author. |
| Local Civil Rule 11.1 | Form of papers. | Marked "[Withdrawn]" in the 2026 joint rules. |
| Local Civil Rule 7.1(b), lead-in (same, text read 2026-10-15) | "The typeface, margins, and spacing of all documents presented for filing must meet the following requirements". The rule names no typeface; its only typeface requirement is the 12-point minimum in (b)(1). | Face: **none named**, so the template sets **Times New Roman**, the house standard. See Typeface below. |

Typeface: face required = none (LCR 7.1(b) names no face; the 12-point minimum is the only type-size rule, 10 point in footnotes). The template sets Times New Roman (vendored), the house standard and the exemplars' face, on typst and docx alike (fb-595.68.26; was EB Garamond). The judge's individual practices, not retrieved, could name a face; if one does, change `font-family` in `typst/nyed-motion-brief.typ` (the docx follows it through `{font}`).

Conventions the rules do not dictate (tier 2, `C`): cover page with caption and title, TOC and TOA with dot leaders and roman page numbers for front matter, body numbered from 1, passim for an authority cited on seven or more pages, signature block at the end of the text, certificate of service on its own page. Both exemplars show the cover, the caption and a TOC with dot leaders; the Force exemplar also has a TOA. Neither exemplar has a word-count certificate.

Not retrieved, so not asserted: Fed. R. Civ. P. 5(b) (the certificate of service); the EDNY ECF Rules and Instructions (PDF requirements); the individual practices of the assigned judge (page or word limits, pre-motion letter rules, font or spacing overrides, which EDNY judges' individual rules sometimes add).

## Layout

- Cover (no page number): court name centered, caption as a two-column table with rules above and below the party column, "-against-" between the sides, `Case No.` and an optional `legend` ("Oral Argument Requested") at right; the title centered bold capitals; counsel block at the foot of the page.
- Front matter (roman numerals): Table of Contents (from the headings, levels 1 to 4, with dot leaders); Table of Authorities (from the `toa:` links in the body, grouped Cases, Statutes, Federal Rules, Other, with page numbers and "passim").
- Body (arabic from 1): Level 1 headings centered bold capitals ("PRELIMINARY STATEMENT", "ARGUMENT", "CONCLUSION"); level 2 to 4 headings bold with a hanging label column (I., A., 1., a.). Body paragraphs double-spaced with a 0.5-inch first-line indent. Footnotes single-spaced at 10 pt with a rule above.
- After the conclusion: the signature block ("Dated:" at left, "Respectfully submitted," and the signer at right), then the certificate of compliance.
- Certificate of service (optional `service` field): its own page, with the signature block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: a heading (`#` centered; `##`, `###`, `####` hanging). A heading with a label is written `## I.  TITLE` (two spaces after the label, which the template uses to split the label from the text). A paragraph.
- Footnotes: a reference `[^id]` in a paragraph and a definition `[^id]: text` as its own chunk anywhere in the body. The template places each definition at its reference (cmarker does not put block-level definitions in place itself).
- Citations: link the citation text to `toa:KEY`, where KEY is a key under `authorities:` in the frontmatter (`kind: case | statute | rule | other`, `name` for cases (italic in the TOA), `cite`). A linked citation that has no key fails the build; a cited authority with no link does not appear in the TOA.
- Frontmatter fields: `case_number`, `court` (lines), `caption` (list of `{names, designation}`; "-against-" between sides), `legend` (optional), `brief_title`, `counsel` (optional lines, cover foot), `date`, `signature` (`signer`, `lines`), `service` (optional), `word_limit` (optional), `authorities`.
- Do not put the TOC, TOA, signature block or certificates in the body: the template generates them.
- Not supported: tables, raw typst.

## Known gaps and open choices

1. **Word count is the template's, not Word's.** The count is whitespace tokens containing a letter or digit, from the body markdown with link targets, footnote marks and markdown symbols removed. It counts headings and footnotes, as the rule does, but Word's count can differ (hyphenated words, numbers, "§" and "¶" tokens). LCR 7.1(c) lets the preparer rely on the word-processing program, so the certificate states the template's count and says that it must be confirmed. **Open: David to decide whether the certificate should show the template count or be left for the attorney to fill in.**
2. **Font (resolved).** LCR 7.1(b) names no typeface; the template sets Times New Roman, the house standard (David, 2026-10-17) and the exemplars' face, at 12 pt (footnotes 10 pt).
3. **Two exemplars predate the 2025 word-limit rule.** Both are page-limited filings. Their TOC and TOA styles are compared; their length is not (the template applies the 8,750-word limit).
4. **Overlay is against the Force exemplar only.** `tools/overlay.sh` reads the first exemplar in name order. The Saldarriaga memorandum is compared by hand (see the review below); the page map is in the `.txt`.
5. **Caption.** The party block is closed by a rule above and below, as in the Force exemplar; the Saldarriaga exemplar closes the block with a rule and "/". Both put the case number at right. Both are seen across the two filers, so the template follows the shared structure and the rule style is a tier-2 choice (`ACCEPTED`).
6. **Signature block at a page break.** The last paragraph is kept whole with the signature block, which is never split, so in the sample the CONCLUSION heading, its paragraph and the signature block open body page 6 together. Recorded as `ACCEPTED`.
7. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.
8. **Pages of the Force argument omitted.** The sample transcribes selected passages (about 1,800 words of a 40-page body). The overlay pairs pages by words, so pages with omitted text pair with lower overlap.

## Review of the rendered pages (made on the earlier EB Garamond render; the 10 pages of the current typst and docx renders were viewed side by side on 2026-10-22, no defect found: the conclusion now opens page 9 (6) with the signature block)

Compared with the Force exemplar (the overlay pair) and, for the caption and TOC, the Saldarriaga exemplar. Page numbers are the PDF page numbers, with the printed page number in brackets.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 (cover) | Force p.1; Saldarriaga p.1 | Court title, caption with rules, `Case No. 20-cv-2578 (BMC)`, `ORAL ARGUMENT REQUESTED`, title, counsel block at foot. Saldarriaga has no counsel block on its cover (a choice, tier 2). | ACCEPTED (counsel block on cover is one filer's practice) |
| 2 (i) | Force p.2 (TOC); Saldarriaga p.2 (TOC) | TOC with dot leaders, page column, levels I, A, B, 1, 2, C, II, CONCLUSION; wrapped headings hang under the text. Page i. | PASS |
| 3 (ii) | Force p.5 (overlay pair; TOA runs over Force pp. 3 to 5) | TOA grouped Cases, Statutes, Federal Rules; cases italic; page numbers from the link positions; "Page(s)". No `passim` on this page (no authority reached seven pages). | PASS |
| 4 (1) | Force p.7 (overlay pair; preliminary statement) | PRELIMINARY STATEMENT centered; double-spaced; first-line indent; footer page 1. | PASS |
| 5 (2) | Force p.12 (overlay pair; Argument I) | ARGUMENT centered; I. label hang; A. heading; citations italic; link citations. | PASS |
| 6 (3) | Force p.14 (overlay pair; Argument I.B.1) | B. and 1. headings; footnote 2 at the foot of its page; citations inline and linked. | PASS |
| 7 (4) | Force p.15 (overlay pair; Argument I.B.2 and I.C) | 2. heading (level 4) with hang; C. heading; text continues onto page 5. | PASS |
| 8 (5) | Force p.10 (overlay pair, 43%; the sample's Argument II is a shortened passage of Force Argument II, pp. 16 to 31, which the overlay does not pair) | II. heading; footnote 1 at foot of page; CONCLUSION centered. | PASS |
| 9 (6) | Force p.46 (overlay pair; signature page of the conclusion) | Signature block alone at the top of the page, after the conclusion (Known gaps 6); Certificate of Compliance with the template count. | ACCEPTED |
| 10 (7) | Force p.47 (overlay pair; certificate of service) | CERTIFICATE OF SERVICE on its own page with the signature block. | PASS |

Overlay: pages pair with the Force pages listed in `OVERLAY-force-memorandum.txt` (word overlap 20 to 73%). The overlay is a diagnostic, not a score; the differences are the omitted passages and the font.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 13.8 pt single lines, 10 pt footnotes in 11.5 pt lines; "Body Text Keep" for the last paragraph) and `nyed-motion-brief.lua` (on `lib/docx/xengine.lua`: the cover with the counsel block in a frame at the bottom margin, the TOC and TOA as listing rows with a page column and dot leaders, the headings with their label boxes, the signature table, the certificate of compliance with the word count of the markdown as typst counts it (1792), the certificate of service on its own page). `fb render` builds the reference document and makes the passes: the filter writes needles for the two table titles, every heading and every `toa:` citation, and gets their pages back until they settle; three sections (cover unnumbered, tables lower roman from i, body arabic from 1) with the filter's page-number footer. No shell script and no committed `reference.docx` (fb-595.68.26; were `build-reference.sh`, `render.sh` and its pdftotext page search). Samples: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word). TOC and TOA page numbers are typed text, not Word fields: if the brief is edited in Word they are not updated.

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (10 pages, 231/231 lines).
- No latex engine for this folder.
