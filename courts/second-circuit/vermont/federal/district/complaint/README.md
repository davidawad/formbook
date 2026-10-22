# vtd: complaint

Doc type: **complaint** in the United States District Court for the District of Vermont (`vtd`).
Folder: `courts/second-circuit/vermont/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole 11-page filing (84 numbered paragraphs, caption, headings, prayer, signature), transcribed from the text layer |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 11 pages, vendored Times New Roman only, no warnings, on the shared cross-engine layout model (fb-595.68.26) |
| overlay | ok: `usage/OVERLAY-bonges-complaint.pdf` and `usage/OVERLAY-bonges-complaint.txt` (page map) |
| pages reviewed | 11 of 11 on typst and docx (every page of both renders viewed side by side at 40 dpi after the last template change, 2026-10-22; the review below was made on the earlier 12-page render) |

File names follow `tools/render.sh` and `tools/overlay.sh`, which read `usage/INPUT-<id>.md` and write `usage/OUTPUT-<id>.pdf` and `usage/OVERLAY-<id>.pdf|.txt`. The brief's `usage/<id>.md` and `<id>-overlay.*` names would need changes to the shared tools, which this work does not touch.

## Governing rules

Primary source: **D. Vt. Local Rules of Procedure, April 20, 2026** (`LocalRules-20260420.pdf`), posted by the court at https://www.vtd.uscourts.gov/court-info/local-rules-and-orders. Fetched 2026-10-14; the text was read from the PDF's text layer. The third-party compilation at courtrules.net returned 403 and was not used.

Federal rules: Fed. R. Civ. P. 5(d)(1)(B), 8(a), 10(a), 10(b) and 38(b), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/ (`rule_5`, `rule_8`, `rule_10`, `rule_38`).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Vt. L.R. 10(a)(1) | 8 1/2 x 11 inch paper. | `paper: "us-letter"` |
| L.R. 10(a)(2) | Plainly legible. | Vendored font, no fallback (render only via `tools/render.sh`). |
| Typeface (L.R. 10(a) names none) | Face required by the rule: **none** (L.R. 10(a)(2) asks for "plainly legible" type and (a)(4) for 12 point or more; no face is named). The template sets Times New Roman (vendored), the house standard and the exemplars' face, on typst and docx alike (fb-595.68.26). | `font-family = ("Times New Roman", "Liberation Serif")`; the docx names it through `{font}` |
| L.R. 10(a)(3) | At least 1 inch margins. | `page-margin = 1in` on all four sides. |
| L.R. 10(a)(4) | No less than 12 point font. | `type-size = 12pt`, the rule's floor. |
| L.R. 10(a)(5) | Consecutively numbered. | Footer page number, arabic, centered (`counter(page)`). |
| L.R. 10(a)(6) | Double-spaced, except quoted material. | `pitch-double = 24pt`: every body line a 24 pt box (2 x 12 pt), the cross-engine layout model (`lib/typst/xengine.typ`). Quotations are not set single-spaced (none in the sample set off as block quotes). |
| L.R. 10(a)(7) | Footnotes used sparingly. | No footnotes in this filing. |
| L.R. 10(a)(8) | Paper-clipped or attached for scanning. | Physical; not templated. |
| L.R. 3(a) | A complaint is filed with: the original, the fee or an IFP motion and affidavit, a civil cover sheet (JS 44), and, when applicable, the notice-and-waiver forms. | Not produced by this template (separate filings, listed below). |
| Fed. R. Civ. P. 8(a) | A short and plain statement of the grounds for jurisdiction, of the claim, and a demand for relief. | Author content; the template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court name, the title of the action (names all parties), the file number, and the title of the paper. | `court-title()`, `caption()`: parties from the frontmatter, `Civil Action No.`, `COMPLAINT`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | `numbered()`: each body paragraph is numbered 1, 2, ...; headings and lists are not; `~ ` marks an unnumbered paragraph (the WHEREFORE clause). The sample's 84 numbered paragraphs render as 1 to 84, matching the filed numbering. |
| Fed. R. Civ. P. 38(b) | A jury demand may be included in a pleading. | `jury_demand: true` prints `JURY TRIAL DEMANDED` under the title. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | No certificate in the complaint template. |

Not produced by this template (separate filings that go with a first filing): the civil cover sheet (JS 44, L.R. 3(a)(3)); the summons (L.R. 4); the notice of lawsuit and waiver forms when applicable (L.R. 3(a)(4)-(5)); the Rule 7.1 disclosure statement when a party is a nongovernmental corporation.

## Layout

- Letter paper, 1 inch margins, no pleading-paper line numbers (the D. Vt. rules do not require them; N.D. Cal.'s pleading paper is a different rule).
- No separate cover page: the court title (two bold lines, centered), then the caption (parties in a column closed by a rule on the right and the bottom; the case number, the title and the jury legend on the right), then the body on the same page.
- Headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the margin; single-spaced (13.8 pt lines), a single line above and below. A heading is kept with the text after it (sticky).
- Numbered paragraphs: 0.5 inch first-line indent, the number in a half-inch box, then text, double-spaced (24 pt lines). The last block of the body is kept with the signature block.
- Prayer: a markdown list, lettered A., B., ... by item number, the label half an inch in, the text hanging 0.4 inch after it.
- Signature block, a double line below the body: the date line indented half an inch ("Respectfully submitted this ... day of ..."), a double line below it `By: /s/` and each counsel's lines (single-spaced, a blank line between), indented 2.9 inches, kept on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `case_label` (optional, default `Civil Action No.`); `caption.parties` (a list of `{names: [...], designation: ...}`; `v.` is inserted between parties); `brief_title`; `jury_demand` (optional); `signature` with `date_line`, `by` (optional, rendered `By: /s/ <by>`), `blocks` (a list of counsel blocks, each a list of lines) and `counsel_for` (optional).
- Body: blank-line-separated chunks. `#` is level 1, `##` level 2, `###` level 3. A chunk starting with `~ ` is an unnumbered paragraph. A list (`1.` items) is lettered A., B., ... A paragraph is numbered by the template.
- Do not put numbers in the text: the template numbers the paragraphs.
- Not supported: tables; footnotes; raw typst.

## Known gaps and open choices

1. **One exemplar, one filer.** The EVAL-LOOP tier-2 standard asks for two or three filers. The search (CourtListener RECAP API, `type=r`, `court=vtd`, `available_only=on`, query "complaint", sorted by filing date) also found *United States v. State of Vermont*, No. 2:26-cv-00272 (filed 2026-08-10 by the United States; 18 pages; Times New Roman; text layer present). It was downloaded to a scratch directory and not saved, because the brief asks for one exemplar per doc type. Tier 2 is judged against one filer here.
2. **Type size and font (resolved).** The rule's minimum is 12 point, and it names no face. The template sets Times New Roman 12 pt, the house standard (David, 2026-10-17) and the exemplar's face.
3. **Sample length.** The sample is the whole filing, 12 rendered pages against the exemplar's 11 (the exemplar is set with a larger line count per page). Target 8 to 14 pages: met.
4. **Signature page.** The last block of the body (here prayer item E.) is kept with the signature block, so the signature page is never without text.
5. **Italics.** The text layer has no italic markup, so case names are transcribed in roman. The template supports `*...*` italics, so a future sample can carry them.
6. **Caption.** The party column is closed by a rule (right and bottom) instead of the `)` column seen in some D. Vt. filings. This is a layout choice; the rule does not specify a caption form beyond Fed. R. Civ. P. 10(a).
7. **Overlay pairing.** The overlay pairs by shared words. Our page 12 (the signature) pairs with the exemplar's page 11, which carries the same signature; the word overlap there is lower because the page has little text. The overlay is a diagnostic, not a score.
8. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.

## Review of the rendered pages (made on the earlier 12-page EB Garamond render; the 11 pages of the current typst and docx renders were viewed side by side on 2026-10-22, no defect found)

- Page 1: court title, caption with the party column and the right column (case number, COMPLAINT, JURY TRIAL DEMANDED), INTRODUCTION heading, paragraphs 1 to 4. Pass.
- Page 2: paragraphs 5 to 11, PARTIES heading, Plaintiff and Defendants subheadings. Pass.
- Page 3: paragraphs 12 to 19, JURISDICTION AND VENUE heading. The bottom third is empty because the FACTUAL ALLEGATIONS heading and the first lettered subheading are kept with paragraph 20, which does not fit. Pass (layout choice; no split heading).
- Page 4: FACTUAL ALLEGATIONS, subheadings A and B, paragraphs 20 to 29. Pass.
- Page 5: paragraphs 30 to 42; the paragraph 42 break (the May 19 sentence continues the paragraph) is correct. Pass.
- Page 6: paragraphs 43 to 49, quotations inline. Pass.
- Page 7: paragraphs 50 to 58; subheadings D and E; the long subheading E wraps to two lines. Pass.
- Page 8: paragraphs 59 to 65; FIRST CAUSE OF ACTION heading with the two-line sub-heading and "(All Defendants)". Pass.
- Page 9: paragraphs 66 to 74. Pass.
- Page 10: paragraphs 75 to 82; SECOND CAUSE OF ACTION heading (three lines). Pass.
- Page 11: paragraphs 83 and 84, PRAYER FOR RELIEF, the WHEREFORE clause (unnumbered), prayer items A. to E. Pass.
- Page 12: signature block: the date line, `By: /s/ James M. Diaz`, both counsel blocks, "Counsel for Plaintiff Henry Bonges". Pass (see Known gaps 4).

Pages reviewed: 12 of 12.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 13.8 pt single lines, 1 in margins, the centered page-number footer) and `vtd-complaint.lua` (on `lib/docx/xengine.lua`: the court title, the caption table with its right and bottom rule, the headings, the numbered and unnumbered paragraphs, the prayer letters and the signature block, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.26). Samples: `usage/OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word). Paragraph numbers are typed text, not a Word list.

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (11 pages, 280/280 lines).
- No latex engine for this folder.
