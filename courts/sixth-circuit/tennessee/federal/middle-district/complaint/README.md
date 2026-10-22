# tnmd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Tennessee (`tnmd`).
Folder: `courts/sixth-circuit/tennessee/federal/middle-district/complaint/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole 12-page filing, transcribed from its text layer; exhibits not included) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx(.pdf)`, 12 pages each, vendored Times New Roman only, no warnings |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-complaint.pdf` (not committed) |
| typeface | face required: none. LR 7.03(a) requires "at least 12-point font" and names no face. Times New Roman 12 pt (vendored), the exemplar's face. |
| pages reviewed | 12 of 12, typst and docx (2026-10-22, 60 dpi, every page viewed) |
| tier 1 | `sh tools/check.sh <dir>`: typst 9 passed, 0 failed; `--engine docx` 13 passed, 0 failed (XENG-001..003 gated, `eval.yaml`). |

## Governing rules

Primary sources, fetched 2026-10-14. The local rules are the M.D. Tenn. Local Rules of Court (2025 amendments, effective 2025-05-15) from https://www.tnmd.uscourts.gov/sites/tnmd/files/2025.05.15%20TNMD%20Local%20Rules%20of%20Court%20-%202025%20amendments%20_0.pdf. The federal rules are from https://www.law.cornell.edu/rules/frcp/rule_8, `rule_10` (Rule 10(a) and (b) verified by text).

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| TNMD-FORM-001 | LR 7.03(a) | 8½ × 11 paper, one-inch margins. | `page` settings, `page-margin`. |
| TNMD-FORM-002 | LR 7.03(a) | At least 12-point font. | `type-size = 12pt`. |
| TNMD-FORM-003 | LR 7.03(a) | All material except headings, footnotes and quotations double spaced. | `pitch-body` (27.6 pt pitch, Word's double line at 12 pt, the exemplar's pitch); single lines (`pitch-single`, 13.8 pt) for headings, caption, signature. |
| TNMD-FORM-004 | LR 7.03(a) | All pages numbered at the bottom. | page `footer` (centered page number on every page). |
| TNMD-FORM-005 | LR 7.03(a) | Judge names below the case number on all filings after the initial filing. | `judges` (caption right column); not used for the complaint, which is the initial filing. |
| TNMD-COMP-001 | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and the Rule 7(a) designation. | `caption-block` (court and division lines, party column with a ")" column, "Case No." on the "v." row, title). |
| TNMD-COMP-002 | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | the body loop: each non-heading paragraph is numbered 1, 2, … by the template; the sample carries no numbers. |
| TNMD-COMP-003 | Fed. R. Civ. P. 8(a) | Short and plain statement: grounds for jurisdiction, claim showing entitlement to relief, demand for relief. | Author content (the sample has jurisdiction, venue, counts and a prayer). The template does not check the content. |
| TNMD-COMP-004 | Fed. R. Civ. P. 8(a)(3) | Demand for the relief sought. | `1. ` list chunks, lettered A, B, … by the template (prayer). |
| TNMD-COMP-005 | LR 7.03(c) | If a jury demand is made in the complaint, "JURY DEMAND" appears immediately opposite the style of the case on the first page. | `jury_demand: true` puts "JURY DEMAND" in the caption's right column opposite the party column. |
| TNMD-COMP-006 | Fed. R. Civ. P. 11(a); LR 7.03(a) | The pleading is signed; names typed or printed beneath signature lines. | `signature` frontmatter (`signer` line, then the signer's name, BPR number and firm lines). |
| TNMD-COMP-007 | LR 3.01(a), LR 3.03 | Complaints are filed electronically by counsel; the filing attorney must file a civil cover sheet (JS-44) with each complaint. | Not produced by this template (a separate filing; see Known gaps 8). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44, LR 3.03); the Business Entity Disclosure Statement (LR 7.02(a)) and the Rule 7.1(a)(2) disclosure (LR 7.02(b)) where they apply; the summons.

## Layout

Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt, ragged right, first-fit line breaks, no kerning, ligatures or hyphenation; every line a box of its pitch (27.6 pt body, double spacing; 13.8 pt single lines: Word's single line at 12 pt).

- Court name and division centered and bold on three single lines, a 27.6 pt gap, then the caption: one row per party line (names, a blank line, the designation 1 in in, a blank line, "v.", a blank line, ...) in a 3.3 in column, a 0.3 in column of ")" marks (one per line of text), and on the right, from the "v." row down, "Case No.", a blank line and "JURY DEMAND" (LR 7.03(c)), a blank line and the judges when given (was vertically centered on the caption, which Word cannot do alike).
- Title centered and bold, 27.6 pt below the caption; the lead-in (unnumbered, first-line indent 0.5 in) follows.
- Numbered paragraphs: the number 0.5 in in, in a half-inch box (Word: a tab at 1 in), wrapped lines at the margin, double spaced.
- Headings single-spaced, bold, centered, kept with what follows: a blank single line above, 6.9 pt below; a stack of count headings has no space inside.
- Prayer items lettered A, B, …: the letter in a half-inch box 0.5 in in, the text hanging at 1 in, double spaced.
- Signature block at 3.25 in, single-spaced: "Respectfully submitted," (or the date), a blank line, the signer, 6.9 pt, the counsel lines; kept on one page with the last block before it.
- Page number centered at the foot in a 13.8 pt line (footer-descent 30 %).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `title` (required), `division` (required), `case_number` (blank leaves "Case No. ________"), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `jury_demand` (true adds "JURY DEMAND"), `judges` (optional list of judge lines), `lead_in` (optional unnumbered opening paragraph), `signature` (`date` optional, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = centered bold heading (level 1); `##` = centered bold heading (level 2, stacked count lines); `1. ` items = a lettered list, one contiguous block; `~ ` = an unnumbered paragraph (the WHEREFORE clause); any other chunk = a numbered paragraph.
- Not supported: footnotes, tables, raw typst, and any body paragraph that must be unnumbered without the `~ ` marker.

## Known gaps and open choices

1. **Only one exemplar.** The brief asks for one per doc type, and EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `type=r&court=tnmd`, complaints filed 2026-09-29 to 2026-10-09) also found *Bledsoe v. Tennessee Sheriffs’ Association, Inc.*, No. 3:26-cv-01445 (41 pages, counsel-drafted, Times New Roman). It was checked and not saved. Tier 2 is therefore **not** judged against two filers yet. Recorded as an open tier-2 item.
2. **Font.** Times New Roman 12 pt (vendored), the exemplar's face; the rule names no face. The docx was EB Garamond 13 pt until fb-595.68.31; it now names the typst face.
3. **Jury legend wording.** The exemplar's caption says "JURY TRIAL DEMANDED". LR 7.03(c) requires the phrase "JURY DEMAND", so the template prints that. The exemplar's wording is recorded, not copied.
4. **Prayer lettering.** The exemplar's prayer skips "G" (A to F, then H and I). The template letters items in order, so the sample's eight items print as A to H. The text is the same; the skip is a filer's artifact, not a rule.
5. **Justification.** The body is ragged right (the cross-engine model: Word and typst break ragged text alike). The rules are silent on justification; the exemplar is justified. This is a tier-2 convention choice and is not asserted.
6. **Paragraph numbering in the sample.** The template numbers the paragraphs (1 to 61). The exemplar's paragraph numbers match the template's count, so the overlay pairs paragraphs by text, not by number.
7. **Page count.** 12 pages, as filed.
8. **Not produced.** The civil cover sheet (JS-44, LR 3.03), the business-entity or Rule 7.1 disclosure (LR 7.02), and the summons are separate filings. Any of them may be needed with the first filing.
9. **Heading placement.** Headings are kept with the text after them. "FACTUAL ALLEGATIONS" ends page 3 with its first paragraph (one line).
10. **No selftest.** `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have.
11. **Exemplar conventions not followed** (tier 3): the exemplar justifies the body (here ragged right, the cross-engine model), underlines the title and some headings, sets a rule under the caption and a signature line under "/s/".

## Review of the rendered pages (2026-10-22, typst and docx, 60 dpi, every page viewed)

The typst and docx renders break every line and page alike (XENG-001..003), so one review covers both; each page was viewed in both PDFs.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court and division lines, caption with the ")" column, "Case No." on the "v." row and "JURY DEMAND" two lines below, COMPLAINT, lead-in, paragraphs 1 to 3 (number at 0.5 in, text at 1 in, as filed). | PASS |
| 2 | exemplar p.2 | Paragraphs 3 to 8 on the 27.6 pt pitch. | PASS |
| 3 | exemplar p.3 | Paragraphs 8 to 12; FACTUAL ALLEGATIONS with paragraph 13 at the foot. | PASS |
| 4 | exemplar p.4 | Paragraphs 14 to 22. | PASS |
| 5 | exemplar p.5 | Paragraphs 23 to 29. | PASS |
| 6 | exemplar p.6 | Paragraphs 29 to 33. | PASS |
| 7 | exemplar p.7 | Paragraphs 33 to 40. | PASS |
| 8 | exemplar p.8 | Paragraphs 40 to 46. | PASS |
| 9 | exemplar p.9 | COUNT I stack (four centered bold lines); paragraphs 47 to 53. | PASS |
| 10 | exemplar p.10 | Paragraphs 53 to 55; COUNT II stack; paragraphs 56 to 59. | PASS |
| 11 | exemplar p.11 | Paragraphs 59 to 61; PRAYER FOR RELIEF; WHEREFORE; items A to C hanging under their letters; the foot left free (item D does not fit whole and typst leaves no orphan line). | PASS |
| 12 | exemplar p.12 | Items D to H; DEMAND FOR JURY TRIAL; signature block at 3.25 in. | PASS |

Reviewed pages: 12 of 12 (typst and docx).

## Engines

- typst (`typst/tnmd-complaint.typ`, the reference): `RESULT: 9 checks passed, 0 failed`.
- docx (ported to the cross-engine layout model 2026-10-22, fb-595.68.31): `docx/reference.xml` (the Word styles: `base="xengine"` in the typst face `{font}`, Times New Roman 12 pt; Body Text in exact 27.6 pt line boxes with a 0.5 in first-line indent, Body Numbered with a tab at 1 in, Body Keep / Body Numbered Keep for the last paragraph, the page number in a 13.8 pt footer line; `fb render` builds `reference.docx` from it) and `docx/tnmd-complaint.lua` (court name, caption table, title, headings, prayer items and signature block as WordprocessingML with the typst pitches and spaces in twips; body paragraphs written by pandoc in the styles above). No shell script and no committed `reference.docx` (were `build-reference.sh`, which set EB Garamond 13 pt, `reference.docx` and `tnmd.lua`). `RESULT: 13 checks passed, 0 failed`; XENG-001..003 PASS (290/290 lines, 12 pages), gated (`eval.yaml`: `params.cross_engine: gate`).
- latex: none for this doc type.
