# pamd: motion brief (memorandum in support of a motion)

Doc type: **motion-brief** (the memorandum of law filed in support of a motion, here a Rule 12(b)(6) motion to dismiss) in the United States District Court for the Middle District of Pennsylvania (`pamd`).
Folder: `courts/third-circuit/pennsylvania/federal/middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `exemplars/FILED-EXAMPLE-orndorff-1-26-cv-02944-motion-brief.pdf` (Cumberland County's memorandum in support of a 12(b)(6) motion). A second filer was **not found**: see gap 1. See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-orndorff.md`: caption, Preliminary Statement and facts (I–III), Statement of Questions (IV), Standard of Review (V), Argument A and A.1 only (VI), Conclusion (VII), the LR 7.1 certificate of non-concurrence, the certificate of service (first two counsel), signature. |
| render | ok: `samples/OUTPUT-orndorff.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-orndorff.pdf` and `OVERLAY-orndorff.txt` (red = ours, blue = Orndorff exemplar) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed; see "Review" below) |

Naming: the tools (`tools/render.sh`, `tools/overlay.sh`) read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`, so the sample id is `orndorff`.

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
| PAMD-BRF-004 | LR 7.8(a) | Statement of questions, procedural history, facts, argument, conclusion | authored body sections (`samples/`), in the order of the exemplar |
| PAMD-BRF-005 | LR 7.1 | Certification of concurrence sought (non-concurrence), in the filing | authored body text (the certificate is a body section, not generated) |
| PAMD-BRF-006 | LR 7.8(a) | Table of contents and table of authorities when the brief is more than 15 pages | **not generated**: see gap 2 |
| PAMD-BRF-007 | LR 7.8(b)(1)–(2) | 15 pages, or 5,000 words with a word-count certificate | **not checked**: see gap 2 |
| PAMD-BRF-008 | FRCP 12(b)(6) | The motion's ground is stated in the title | title (`title` frontmatter) |

Not produced by this template (separate filings): the motion itself; the proposed order (LR 7.1); declarations and exhibits (LR 7.3); the Rule 7.1 disclosure statement. The reply brief (LR 7.7) and the opposition (LR 7.6) are other doc types.

## Layout

- Letter paper, 1 in margins, 14 pt EB Garamond, 32 pt double-spaced body text (about 20 lines per page).
- Caption and title as the complaint's: court title on two stacked lines; party column with a ":" column; right column with the civil action number and the judge; the title centred and bold caps below.
- Body paragraphs: first-line indent 0.5 in, not numbered.
- Headings: level 1 flush-left bold caps ("I.", "II." ...); level 2 flush-left bold ("A.", "B." ...); level 3 bold italic ("1.", "2." ...). Sticky.
- Statement of questions: lettered paragraphs with a hard line break before the "Suggested Answer" line (the exemplar's convention).
- Signature block: date at left; "Respectfully submitted," the firm, "By:" and a line, then the signer and the address at right, single-spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `title` (cover title, caps applied by the template); `caption` (rows: `left`, optional `indent` in inches, optional `right`; one row per caption line; colons are generated); `date` (optional, shown as "Dated:"); `signature.firm` (single-spaced lines above "By:"), `signature.lines` (signer, address, email, role).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings (levels 1–3). A `1.` list is lettered (a), (b) ... A chunk starting with `~` is a single-spaced block with no first-line indent (service lists, addresses). Any other chunk is an unnumbered paragraph with a first-line indent.
- Hard line breaks inside a chunk: a trailing backslash at the end of the line.
- Not supported: tables, footnotes, raw typst, forced line breaks in the template (the court title is stacked, not broken).

## Overlay

`tools/overlay.sh` pairs each rendered page with the exemplar page that shares the most words. Pass the Orndorff exemplar explicitly (`sh tools/overlay.sh <dir> orndorff <exemplar.pdf>`), as the tool's default would pick the same file. Pages 1–7 pair with the same page number. Sample page 8 (the non-concurrence certificate) pairs with filed page 17, and pages 9–10 (service and signature) pair with filed pages 16–17, because the sample's argument and facts are partial. The map is in `OVERLAY-orndorff.txt`. The overlay is a diagnostic, not a score: word overlap runs 54–88% on the body pages.

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for two or three filers. CourtListener's search API (two queries, 2026-10-14) returned no motion-to-dismiss brief of 15 pages or fewer from this court; the brief found, in support of a bifurcation motion (Bland v. Humana Inc., 1:26-cv-00659, 15 pp., 2026-05-20), is not a Rule 12(b) memorandum and was not saved. Tier 2 is therefore judged against one filer. A second exemplar should be found before this doc type is called tier-2 complete.
2. **No TOC, no TOA, no word-count certificate.** LR 7.8(a) requires a table of contents and a table of authorities when the brief is more than 15 pages; LR 7.8(b)(2) requires a word-count certificate for a brief over 15 pages (up to 5,000 words). The template produces neither, and does not check the page count. The sample is 10 pages, so it does not need them. **A brief over 15 pages cannot be built from this template as it stands.** Adding them (typst `outline()` for the TOC, and a manual or query-driven TOA) is a template change for David to schedule. The exemplar also has no TOC or TOA. Its body length was not counted against LR 7.8(b)(1) here, so whether it complies is not resolved.
3. **Certificates are authored text.** The LR 7.1 certificate of non-concurrence and the certificate of service are body text in the sample, not generated. Their headings are flush-left (the exemplar centres them); a style difference, not a rule.
4. **Partial sample.** The sample transcribes the Statement of the Case in full, the Statement of Questions, the Standard of Review, Argument A and A.1, the Conclusion, both certificates and the signature. Argument A.2–A.3 and B–D are not transcribed. The service certificate lists the first two counsel; the rest are omitted and marked in the sample. The sample's Statement of Questions is the exemplar's "Suggested Answer" convention, which is the filer's, not a rule.
5. **Font.** As for the complaint: EB Garamond at 14 pt, not Times. The 14 pt minimum is met; the apparent size is smaller than the Times exemplar.
6. **Page limit not checked.** LR 7.8(b)(1) is not counted by the template (gap 2).
7. **LR 7.5 deadline.** The 14-day window is not enforced; it is a calendar item for the filer.

## Review

Every page of `OUTPUT-orndorff.pdf` was rendered at 60 dpi and viewed. The caption and page 1 were re-checked after the two caption edits (shortened rows) and the cover edit (stacked court title). Pages 2–8 were re-viewed after the caption and service-list edits.

- Page 1: court title stacked; caption with colons and the judge at the right (the "COMMONWEALTH OF / PENNSYLVANIA –" rows fit after shortening); the title centred and bold caps across three lines; "I. PRELIMINARY STATEMENT" and the first paragraph. Pass.
- Page 2: paragraphs of the preliminary statement; "II. PROCEDURAL HISTORY" and "III. RELEVANT FACTS" flush-left bold; paragraph indents. Pass.
- Page 3: facts paragraphs with record citations (¶ and ¶¶). Pass.
- Page 4: the end of the facts; "IV. STATEMENT OF QUESTIONS INVOLVED" with lettered questions and their "Suggested Answer" lines. Pass.
- Page 5: "V. STANDARD OF REVIEW"; italic case names; the Iqbal quotation. Pass.
- Page 6: the rest of the standard of review; "VI. ARGUMENT" and "A." (level 2, two lines, kept with its paragraph). Pass.
- Page 7: the Monell paragraphs; "1." (level 3) heading kept with its paragraph. Pass.
- Page 8: the rest of Argument A.1; "VII. CONCLUSION" with its paragraph; the certificate of non-concurrence starts mid-page with its heading and first paragraph kept together, and continues on page 9. Pass.
- Page 9: the rest of the certificate; "CERTIFICATE OF SERVICE" with the first two counsel as single-spaced blocks. Pass.
- Page 10: the omitted-counsel note; "Dated:", "Respectfully submitted," the firm, "By:" line, signer and address. Pass.

## Changes made during review

- Caption rows overlapped: "COMMONWEALTH OF PENNSYLVANIA –" was wider than the party column. Fixed: split into "COMMONWEALTH OF" and "PENNSYLVANIA –".
- The service list was double-spaced with a first-line indent on each name. Fixed: a `~` block convention (single-spaced, no indent).
- The court title used a forced line break (`\`). Fixed: two stacked lines (CLAUDE.md bans forced line breaks in templates).
- Headings rendered at typst's default heading size in the first draft of the complaint; the brief's headings were set at the 14 pt type size from the start.

## Engines

- **typst** (primary, `typst/`): the reference for the form. Pages reviewed in this README above.
- **latex**: not built in this pass.
- **docx** (`docx/reference.docx`, `docx/build-reference.sh`, `docx/pamd.lua`; sample `samples/OUTPUT-orndorff.docx`). Built with `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/pamd.lua samples/INPUT-orndorff.md`. Matches the typst template: EB Garamond 14 pt (declared in the styles; the font must be installed on the machine that opens the file), exact 32 pt line pitch, 0.5 in first-line indent on body paragraphs, 1 in margins on letter paper, page number centred in a 12 pt footer, flush-left bold caps level-1 headings, flush-left bold level-2 and bold italic level-3 headings, the court title, the caption as a borderless table with 16 pt rows and a colon column, the title, the Statement of Questions with its "A.", "B." labels as text, `~` blocks (service lists) single-spaced without indent, and the signature block (date at left; firm, "By:" with an underline tab, and the signer at right). Differences: single-spaced blocks use exact 16 pt lines (typst uses its own leading), the "By:" rule is an underlined tab, and the page breaks are not measured. The table of contents, table of authorities and word-count certificate are not produced, as in the typst template (gap 2 above). The `.docx` was checked only for a valid zip and well-formed XML parts, and read back with pandoc. It was not opened in Word or LibreOffice.
- **docx BLOCKED.** No checks file is readable for this court (no `checks.yaml` in the court folder), so there are no gate check IDs to list. The rule IDs measured on the `.docx.pdf` (PAMD-BRF-001 to PAMD-BRF-008, see the table above) are all BLOCKED: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked. The docx is not verified against Gates 0 to 3.
