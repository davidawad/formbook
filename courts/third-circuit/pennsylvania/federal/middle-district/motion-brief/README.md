# pamd: motion brief (memorandum in support of a motion)

Doc type: **motion-brief** (the memorandum of law filed in support of a motion, here a Rule 12(b)(6) motion to dismiss) in the United States District Court for the Middle District of Pennsylvania (`pamd`).
Folder: `courts/third-circuit/pennsylvania/federal/middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (Cumberland County's memorandum in support of a 12(b)(6) motion). A second filer was **not found**: see gap 1. See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: caption, Preliminary Statement and facts (I–III), Statement of Questions (IV), Standard of Review (V), Argument A and A.1 only (VI), Conclusion (VII), the LR 7.1 certificate of non-concurrence, the certificate of service (first two counsel), signature. |
| render | ok (2026-10-22): `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, and `usage/OUTPUT-motion-brief.docx` with its LibreOffice PDF, 10 pages; `fb render`, vendored Times New Roman only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 10 of 10, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |

Naming: `usage/` holds `INPUT-motion-brief.md`, `OUTPUT-motion-brief.typst.pdf`, `OUTPUT-motion-brief.docx` and `.docx.pdf`, the `FILED-EXAMPLE-` files and `SOURCE.md` (`fb usage` prints the names).

## Governing rules

Sources and dates. Read on 2026-10-14. The brief-related rules are in the court's own "Local & Federal Rules Excerpts" PDF, https://www.pamd.uscourts.gov/sites/pamd/files/Local%20%26%20Federal%20Rules%20Excerpts.pdf (14 pp., Word-generated, file date 2020-03-04). That file date is old: confirm the current text on https://www.pamd.uscourts.gov/ before a real filing.

- **LR 7.1** (motions to be written): "A motion must be written, and shall contain a certification by counsel for the movant that he or she has sought concurrence in the motion from each party, and that it has been either given or denied." Every motion must be accompanied by a proposed form of order (a separate filing).
- **LR 7.5** (brief in support): the movant files the supporting brief within 14 days after the motion; otherwise the motion is deemed withdrawn.
- **LR 7.8(a)** (contents): the moving brief contains a procedural history, a statement of facts, a statement of questions involved, and argument. "The brief of each party, if more than fifteen (15) pages in length, shall contain a table of contents, with page references, and table of citations ... with references to the pages at which they are cited." One motion per brief.
- **LR 7.8(b)(1)–(3)** (length): no brief over 15 pages, unless it is 5,000 words or fewer (with a certificate stating the actual word count, LR 7.8(b)(2)); longer briefs need prior authorization.
- **LR 5.1** (form; same as the complaint): 8½ × 11 paper; typeface no smaller than a 14 point word-processing font; double-spaced text (quotations over two lines may be single-spaced; headings and footnotes may be single-spaced); margins at least one inch on all four sides; page numbers in the margins. Read from search summaries of a mirror (courtrules.net blocks direct fetches) on 2026-10-14. Paraphrased here, not quoted.
- **LR 5.2(d)** (personal identifiers): same as the complaint; the author's responsibility.
- **Fed. R. Civ. P. 12(b)(6)**: cited in the content; not re-fetched in this pass.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| PAMD-BRF-001 | LR 5.1 | 8½ × 11 paper; 14 point or larger; standard face | `typst/pamd-motion-brief.typ`: `type-size = 14pt`, `font-family` |
| PAMD-BRF-002 | LR 5.1 | Double-spaced text; 32 pt baseline pitch (verified in the render) | `pitch`, `body-leading` |
| PAMD-BRF-003 | LR 5.1 | Margins ≥ 1 in, all sides; page numbers in the margin | `margin-all = 1in`; page number in the bottom margin |
| PAMD-BRF-004 | LR 7.8(a) | Statement of questions, procedural history, facts, argument, conclusion | authored body sections (`usage/`), in the order of the exemplar |
| PAMD-BRF-005 | LR 7.1 | Certification of concurrence sought (non-concurrence), in the filing | authored body text (the certificate is a body section, not generated) |
| PAMD-BRF-006 | LR 7.8(a) | Table of contents and table of authorities when the brief is more than 15 pages | **not generated**: see gap 2 |
| PAMD-BRF-007 | LR 7.8(b)(1)–(2) | 15 pages, or 5,000 words with a word-count certificate | **not checked**: see gap 2 |
| PAMD-BRF-008 | FRCP 12(b)(6) | The motion's ground is stated in the title | title (`title` frontmatter) |

Not produced by this template (separate filings): the motion itself; the proposed order (LR 7.1); declarations and exhibits (LR 7.3); the Rule 7.1 disclosure statement. The reply brief (LR 7.7) and the opposition (LR 7.6) are other doc types.

## Layout

- Letter paper, 1 in margins, Times New Roman 14 pt (LR 5.1(c)), the cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 32 pt for the body (double spacing, the pitch of the 14 pt filed exemplar), 16 pt for single lines; the spaces between blocks explicit. Page number 12 pt, centred in a 13.8 pt line ending 0.5 in above the page edge (in the margin, LR 5.1(c)).
- Caption and title as the complaint's: court title on two single lines; one single line per caption row (party column, a ":" on every row, the right column with the civil action number and the judge); the title bold capitals, centred single lines, 32 pt below.
- Body paragraphs: first-line indent 0.5 in, not numbered.
- Headings at the type size on the body pitch with no space of their own, kept with the next block: level 1 flush-left bold caps ("I.", "II." ...); level 2 flush-left bold ("A.", "B." ...); level 3 bold italic. A heading's own number ("1.  The ...") is text, not a list.
- Single-spaced blocks (the Statement of Questions, each question with its "Suggested Answer" line after a hard break; the service list addresses): no first-line indent, a blank single line (16 pt) around each, kept whole.
- Signature block, 32 pt below the last block: "Dated:" at the left of the first line; "Respectfully submitted," at 2.8 in (a tab in the docx), the firm 6 pt below, "By:" and a signature line to 3.2 in 32 pt below, the signer and the address 6 pt below, single-spaced; kept on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `title` (cover title, caps applied by the template); `caption` (rows: `left`, optional `indent` in inches, optional `right`; one row per caption line; colons are generated); `date` (optional, shown as "Dated:"); `signature.firm` (single-spaced lines above "By:"), `signature.lines` (signer, address, email, role).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings (levels 1–3). A chunk whose lines end in a hard break (trailing `\`) is a single-spaced block with no first-line indent (a lettered question "A.  ...\" is such a block). Any other chunk is a paragraph. Lists are not supported (the docx filter stops on one).
- Hard line breaks inside a chunk: a trailing backslash at the end of the line.
- Not supported: tables, footnotes, raw typst, forced line breaks in the template (the court title is stacked, not broken).

## Overlay

`just overlay <dir>` (`tools/overlay.sh`) pairs each rendered page with the exemplar page that shares the most words and writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt` (not committed). A diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for two or three filers. CourtListener's search API (two queries, 2026-10-14) returned no motion-to-dismiss brief of 15 pages or fewer from this court; the brief found, in support of a bifurcation motion (Bland v. Humana Inc., 1:26-cv-00659, 15 pp., 2026-05-20), is not a Rule 12(b) memorandum and was not saved. Tier 2 is therefore judged against one filer. A second exemplar should be found before this doc type is called tier-2 complete.
2. **No TOC, no TOA, no word-count certificate.** LR 7.8(a) requires a table of contents and a table of authorities when the brief is more than 15 pages; LR 7.8(b)(2) requires a word-count certificate for a brief over 15 pages (up to 5,000 words). The template produces neither, and does not check the page count. The sample is 10 pages, so it does not need them. **A brief over 15 pages cannot be built from this template as it stands.** Adding them (typst `outline()` for the TOC, and a manual or query-driven TOA) is a template change for David to schedule. The exemplar also has no TOC or TOA. Its body length was not counted against LR 7.8(b)(1) here, so whether it complies is not resolved.
3. **Certificates are authored text.** The LR 7.1 certificate of non-concurrence and the certificate of service are body text in the sample, not generated. Their headings are flush-left (the exemplar centres them); a style difference, not a rule.
4. **Partial sample.** The sample transcribes the Statement of the Case in full, the Statement of Questions, the Standard of Review, Argument A and A.1, the Conclusion, both certificates and the signature. Argument A.2–A.3 and B–D are not transcribed. The service certificate lists the first two counsel; the rest are omitted and marked in the sample. The sample's Statement of Questions is the exemplar's "Suggested Answer" convention, which is the filer's, not a rule.
5. **Font.** LR 5.1 names no face. Times New Roman 14 pt (vendored), the face of the filed exemplar and the house standard, in every engine.
6. **Page limit not checked.** LR 7.8(b)(1) is not counted by the template (gap 2).
7. **LR 7.5 deadline.** The 14-day window is not enforced; it is a calendar item for the filer.

## Review

Every page of `OUTPUT-motion-brief.typst.pdf` and `OUTPUT-motion-brief.docx.pdf` was rendered at 50 dpi and viewed side by side (2026-10-22); the two engines set every page alike.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (colons on every row, "CIVIL ACTION", the number and the judge at the right), title in three bold lines, "I. PRELIMINARY STATEMENT", its first paragraph | Pass. Ends three lines short: the next paragraph's first lines do not fit with its orphan rule. |
| 2 | Preliminary statement; "II. PROCEDURAL HISTORY", "III. RELEVANT FACTS" | Pass. |
| 3 | Facts with record citations (¶ and ¶¶) | Pass. |
| 4 | The end of the facts; "IV. STATEMENT OF QUESTIONS INVOLVED", questions A–E single-spaced with their "Suggested Answer" lines | Pass. |
| 5 | "V. STANDARD OF REVIEW"; italic case names; the Iqbal quotation | Pass. |
| 6 | The rest of the standard; "VI. ARGUMENT"; heading A (two lines, kept with its paragraph) | Pass. |
| 7 | The Monell paragraphs; heading "1. The policy and custom allegations ..." kept with its paragraph | Pass. |
| 8 | The rest of A.1; "VII. CONCLUSION" | Pass. Ends short: the certificate heading stays with its paragraph. |
| 9 | Certificate of non-concurrence (LR 7.1) | Pass. |
| 10 | Certificate of service with two single-spaced addresses; the omitted-counsel note; the signature block with "By:" and its line | Pass. |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 220/220 lines, 10/10 pages).

## Changes made during review

- Caption rows overlapped: "COMMONWEALTH OF PENNSYLVANIA –" was wider than the party column. Fixed: split into "COMMONWEALTH OF" and "PENNSYLVANIA –".
- The service list was double-spaced with a first-line indent on each name. Fixed: a single-spaced block (its lines end in a hard break), no indent.
- The court title used a forced line break (`\`). Fixed: two stacked lines (CLAUDE.md bans forced line breaks in templates).
- Headings rendered at typst's default heading size in the first draft of the complaint; the brief's headings were set at the 14 pt type size from the start.
- The cross-engine port (fb-595.68.35): em leadings and fixed-height caption rows gave way to line boxes of the pitch; the docx named EB Garamond and set its own spacing (blank paragraphs of 32, 23 and 8 pt), now Times New Roman on the typst spaces; the level-3 heading "1. ..." was read by cmarker as a list inside a paragraph (a typst warning) and is now text; the title takes the sample's curly apostrophes, as the docx did.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/pamd-motion-brief.typ`): the reference.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 14 pt; Body Text in exact 32 pt line boxes with a 0.5 in first-line indent, single lines 16 pt; the heading levels flush left at the type size on the body pitch; letter page, 1 in margins, the footer 0.5 in above the edge) and `docx/pamd-motion-brief.lua` on `lib/docx/xengine.lua`, which writes the court title, the caption table (one single line per row in each column), the title, the body, the single-spaced blocks with the author's line breaks (pandoc's "A." list read back as text), the signature (the "By:" line an underlined tab), the 12 pt page-number footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (220/220 lines, 10/10 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
