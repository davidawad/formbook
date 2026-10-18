# tnmd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Tennessee (`tnmd`).
Folder: `courts/sixth-circuit/tennessee/federal/middle-district/complaint/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-tnmd-complaint-doge326cv01418.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-tnmd-complaint-doge.md` (the whole 12-page filing, transcribed from its text layer; exhibits not included) |
| render | ok: `usage/OUTPUT-tnmd-complaint-doge.typst.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-doge-complaint.pdf` and `usage/OVERLAY-doge-complaint.txt` (exemplar pages 1 to 12, sample page 13 paired with exemplar page 12) |
| typeface | face required: none. LR 7.03(a) requires "at least 12-point font" and names no face, so the court-named-face substitute does not apply. Stays EB Garamond (vendored, visual only), per `docs/FONTS.md` ("No face named"). |
| pages reviewed | 13 of 13 (re-rendered 2026-10-15 with vendored fonts only, zero warnings; every page rendered at 60 dpi and viewed) |
| tier 1 | not gated: `tools/check.sh` expects a court folder with `court.json` and `rules.md`, which this doc-type folder is not, and the brief forbids touching `tools/`. The rule rows below are the tier-1 record. |

## Governing rules

Primary sources, fetched 2026-10-14. The local rules are the M.D. Tenn. Local Rules of Court (2025 amendments, effective 2025-05-15) from https://www.tnmd.uscourts.gov/sites/tnmd/files/2025.05.15%20TNMD%20Local%20Rules%20of%20Court%20-%202025%20amendments%20_0.pdf. The federal rules are from https://www.law.cornell.edu/rules/frcp/rule_8, `rule_10` (Rule 10(a) and (b) verified by text).

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| TNMD-FORM-001 | LR 7.03(a) | 8½ × 11 paper, one-inch margins. | `page` settings, `page-margin`. |
| TNMD-FORM-002 | LR 7.03(a) | At least 12-point font. | `type-size = 13pt` (see Known gaps 2). |
| TNMD-FORM-003 | LR 7.03(a) | All material except headings, footnotes and quotations double spaced. | `body-leading` (27.6 pt pitch at 13 pt); single spacing (`single-pitch`, 15 pt) for headings, caption, signature. |
| TNMD-FORM-004 | LR 7.03(a) | All pages numbered at the bottom. | `footer` (centered page number on every page). |
| TNMD-FORM-005 | LR 7.03(a) | Judge names below the case number on all filings after the initial filing. | `judges` (caption right column); not used for the complaint, which is the initial filing. |
| TNMD-COMP-001 | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and the Rule 7(a) designation. | `caption-block` (court and division lines, party column with a ")" column, "Case No." column, title). |
| TNMD-COMP-002 | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-blocks`: each non-heading paragraph is numbered 1, 2, … by the template; the sample carries no numbers. |
| TNMD-COMP-003 | Fed. R. Civ. P. 8(a) | Short and plain statement: grounds for jurisdiction, claim showing entitlement to relief, demand for relief. | Author content (the sample has jurisdiction, venue, counts and a prayer). The template does not check the content. |
| TNMD-COMP-004 | Fed. R. Civ. P. 8(a)(3) | Demand for the relief sought. | `1. ` list chunks, lettered A, B, … by the template (prayer). |
| TNMD-COMP-005 | LR 7.03(c) | If a jury demand is made in the complaint, "JURY DEMAND" appears immediately opposite the style of the case on the first page. | `jury_demand: true` puts "JURY DEMAND" in the caption's right column opposite the party column. |
| TNMD-COMP-006 | Fed. R. Civ. P. 11(a); LR 7.03(a) | The pleading is signed; names typed or printed beneath signature lines. | `signature` frontmatter (`signer` line, then the signer's name, BPR number and firm lines). |
| TNMD-COMP-007 | LR 3.01(a), LR 3.03 | Complaints are filed electronically by counsel; the filing attorney must file a civil cover sheet (JS-44) with each complaint. | Not produced by this template (a separate filing; see Known gaps 8). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44, LR 3.03); the Business Entity Disclosure Statement (LR 7.02(a)) and the Rule 7.1(a)(2) disclosure (LR 7.02(b)) where they apply; the summons.

## Layout

- Court name and division centered on three single-spaced lines at the top.
- Caption: party column (3.3 in), a ")" column (one ")" per line of the party column, measured per row so it always matches), and a right column with "Case No." and "JURY DEMAND", vertically centered.
- Title centered and bold below the caption; the body follows.
- Numbered paragraphs at a 0.5 in number indent with the text starting at 1 in on the first line; wrapped lines return to the left margin.
- Count headings (level 2) are centered bold and stacked single-spaced; a blank double-spaced line sits above and below each count block.
- Prayer items lettered A, B, … (hanging indent).
- Signature block on the right half of the page, single-spaced, in a block that does not break across pages.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `title` (required), `division` (required), `case_number` (blank leaves "Case No. ________"), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `jury_demand` (true adds "JURY DEMAND"), `judges` (optional list of judge lines), `lead_in` (optional unnumbered opening paragraph), `signature` (`date` optional, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = centered bold heading (level 1); `##` = centered bold heading (level 2, stacked count lines); `1. ` items = a lettered list, one contiguous block; `~ ` = an unnumbered paragraph (the WHEREFORE clause); any other chunk = a numbered paragraph.
- Not supported: footnotes, tables, raw typst, and any body paragraph that must be unnumbered without the `~ ` marker.

## Known gaps and open choices

1. **Only one exemplar.** The brief asks for one per doc type, and EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `type=r&court=tnmd`, complaints filed 2026-09-29 to 2026-10-09) also found *Bledsoe v. Tennessee Sheriffs’ Association, Inc.*, No. 3:26-cv-01445 (41 pages, counsel-drafted, Times New Roman). It was checked and not saved. Tier 2 is therefore **not** judged against two filers yet. Recorded as an open tier-2 item.
2. **Font size.** The rule requires at least 12 point and names no font. The template uses EB Garamond (vendored, the only serif in `fonts/`) at 13 pt, because EB Garamond's x-height is smaller than Times New Roman at 12 pt and 12 pt would look smaller than the exemplar. Whether the court wants the same apparent size as Times is a question for David (a vendored Times-metric font would remove the choice).
3. **Jury legend wording.** The exemplar's caption says "JURY TRIAL DEMANDED". LR 7.03(c) requires the phrase "JURY DEMAND", so the template prints that. The exemplar's wording is recorded, not copied.
4. **Prayer lettering.** The exemplar's prayer skips "G" (A to F, then H and I). The template letters items in order, so the sample's eight items print as A to H. The text is the same; the skip is a filer's artifact, not a rule.
5. **Justification.** The body is ragged right. The rules are silent on justification; the exemplar's justification could not be read from the text layer. This is a tier-2 convention choice and is not asserted.
6. **Paragraph numbering in the sample.** The template numbers the paragraphs (1 to 61). The exemplar's paragraph numbers match the template's count, so the overlay pairs paragraphs by text, not by number.
7. **Page count.** The rendered sample is 13 pages against the exemplar's 12. The difference is line breaks and the prayer's hanging indent; it is not a rule issue (LR 7.03 sets no page limit for complaints).
8. **Not produced.** The civil cover sheet (JS-44, LR 3.03), the business-entity or Rule 7.1 disclosure (LR 7.02), and the summons are separate filings. Any of them may be needed with the first filing.
9. **Heading placement.** Headings are kept with the text after them (typst default). A section heading at the foot of a page moves to the next page with its first paragraph.
10. **No check gates.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, which this doc-type folder does not have, and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 record.

## Review of the rendered pages (current PDF, 60 dpi, every page viewed)

- Page 1: court name and division on three lines; caption with the ")" column; "Case No. ____" and "JURY DEMAND" opposite the party column; "COMPLAINT" title; lead-in; paragraphs 1 to 3 at double spacing. Pass.
- Page 2: paragraphs 4 to 8. Pass.
- Page 3: paragraphs 9 to 12. The "FACTUAL ALLEGATIONS" heading moved to page 4 with its first paragraph (heading kept with its text). Pass.
- Page 4: "FACTUAL ALLEGATIONS" heading centered; paragraphs 13 to 21. Pass.
- Page 5: paragraphs 22 to 28. Pass.
- Page 6: paragraphs 29 to 33. Pass.
- Page 7: paragraphs 34 to 38. Pass.
- Page 8: paragraphs 39 to 44. Pass.
- Page 9: paragraphs 45 to 51, then the "COUNT I" block (COUNT I, DIRECT COPYRIGHT INFRINGEMENT, 17 U.S.C. §§ 106, 501, (Against All Defendants)) centered with a blank line above and below. Pass.
- Page 10: paragraphs 52 to 57, with the "COUNT II" block (three-line title and the alternative line) between paragraphs 55 and 56, centered, with a blank line above. Pass.
- Page 11: paragraphs 58 to 61; "PRAYER FOR RELIEF" centered; WHEREFORE paragraph; prayer items A and the start of B. Pass.
- Page 12: prayer items B (continued) to H. Pass.
- Page 13: "DEMAND FOR JURY TRIAL" heading and the signature block (right half, single-spaced, "/s/" line and the counsel lines). The block did not fit on page 12 and moved with its heading. Pass.

Gate 2 rows are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

docx: `docx/build-reference.sh` (builds `docx/reference.docx` from pandoc's default reference) and `docx/tnmd.lua` (caption, signature, numbering). Output: `usage/OUTPUT-tnmd-complaint-doge.docx` and `usage/OUTPUT-tnmd-complaint-doge.docx.pdf` (LibreOffice 26.8.1 conversion). Typst output for comparison: `usage/OUTPUT-tnmd-complaint-doge.typst.pdf`. Both are 13 pages. Every page of both was rasterized at 60 dpi and viewed.

- Matches typst: letter paper, one-inch margins, EB Garamond 13 pt (the PDF embeds only EB Garamond Regular and Bold), double spacing as an exact 27.6 pt line pitch, single spacing at 15 pt for the court heading, caption, headings and signature, centered page number at the foot (TNMD-FORM-001 to 004). Caption: court lines, party column with a ")" column, "Case No." and "JURY DEMAND" on the right. Title, numbered paragraphs 1 to 61, stacked count headings, lettered prayer items A to H, and the signature block at 3.25 in, kept together with the heading before it. Heading sizes follow the typst default (1.4 em and 1.2 em).
- Differs (tier 2, or a renderer effect): the ")" column gets one ")" per estimated caption line (typst measures the wrap); recount if the names change. The paragraph text after the number starts at 1.2 in (typst: 0.5 in gap after the number); the number itself is at 0.5 in in both. Exact line spacing in Word and LibreOffice puts each line's text about 12 pt lower in its line box than typst; the line pitch is identical.
- BLOCKED: none for the docx. `tools/check.sh` cannot run on this folder (it has no `court.json` or `checks.yaml`); the docx gate was not run. Word was not available; the file was checked with `unzip -t`, `xmllint` and the LibreOffice conversion only.
