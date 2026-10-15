# vtd: complaint

Doc type: **complaint** in the United States District Court for the District of Vermont (`vtd`).
Folder: `courts/second-circuit/vermont/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-bonges-2-26-cv-283-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-bonges-complaint.md`: the whole 11-page filing (84 numbered paragraphs, caption, headings, prayer, signature), transcribed from the text layer |
| render | ok: `samples/OUTPUT-bonges-complaint.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-bonges-complaint.pdf` and `samples/OVERLAY-bonges-complaint.txt` (page map) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed; see the review below) |

File names follow `tools/render.sh` and `tools/overlay.sh`, which read `samples/INPUT-<id>.md` and write `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf|.txt`. The brief's `samples/<id>.md` and `<id>-overlay.*` names would need changes to the shared tools, which this work does not touch.

## Governing rules

Primary source: **D. Vt. Local Rules of Procedure, April 20, 2026** (`LocalRules-20260420.pdf`), posted by the court at https://www.vtd.uscourts.gov/court-info/local-rules-and-orders. Fetched 2026-10-14; the text was read from the PDF's text layer. The third-party compilation at courtrules.net returned 403 and was not used.

Federal rules: Fed. R. Civ. P. 5(d)(1)(B), 8(a), 10(a), 10(b) and 38(b), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/ (`rule_5`, `rule_8`, `rule_10`, `rule_38`).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Vt. L.R. 10(a)(1) | 8 1/2 x 11 inch paper. | `paper: "us-letter"` |
| L.R. 10(a)(2) | Plainly legible. | Vendored font, no fallback (render only via `tools/render.sh`). |
| Typeface (L.R. 10(a) names none) | Face required by the rule: **none** (L.R. 10(a)(2) asks for "plainly legible" type and (a)(4) for 12 point or more; no face is named). Vendored substitute: **none needed**; EB Garamond is kept under `docs/FONTS.md` ("No face named"). Metric fit: n/a. | `font-family = "EB Garamond"` |
| L.R. 10(a)(3) | At least 1 inch margins. | `page-margin = 1in` on all four sides. |
| L.R. 10(a)(4) | No less than 12 point font. | `type-size = 13pt` (see Known gaps 2). Footnotes at the same size. |
| L.R. 10(a)(5) | Consecutively numbered. | Footer page number, arabic, centered (`counter(page)`). |
| L.R. 10(a)(6) | Double-spaced, except quoted material. | `body-leading = 1.35em` on EB Garamond (line box 0.65em): measured baseline pitch 26.00 pt at 13 pt, which is 2.0em. Quotations are not set single-spaced (none in the sample set off as block quotes). |
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
- Headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the margin. A heading is kept with the text after it (sticky).
- Numbered paragraphs: 0.5 inch first-line indent, the number, then text, double-spaced.
- Prayer: a markdown list, lettered A., B., ...
- Signature block: the date line at the margin ("Respectfully submitted this ... day of ..."), then `By: /s/` and each counsel's lines, indented 2.9 inches, kept on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `case_label` (optional, default `Civil Action No.`); `caption.parties` (a list of `{names: [...], designation: ...}`; `v.` is inserted between parties); `brief_title`; `jury_demand` (optional); `signature` with `date_line`, `by` (optional, rendered `By: /s/ <by>`), `blocks` (a list of counsel blocks, each a list of lines) and `counsel_for` (optional).
- Body: blank-line-separated chunks. `#` is level 1, `##` level 2, `###` level 3. A chunk starting with `~ ` is an unnumbered paragraph. A list (`1.` items) is lettered A., B., ... A paragraph is numbered by the template.
- Do not put numbers in the text: the template numbers the paragraphs.
- Not supported: tables; footnotes (the template's footnote style is set, but the chunk renderer does not fold footnote definitions the way the motion-brief template does, so a footnote here would not resolve); raw typst.

## Known gaps and open choices

1. **One exemplar, one filer.** The EVAL-LOOP tier-2 standard asks for two or three filers. The search (CourtListener RECAP API, `type=r`, `court=vtd`, `available_only=on`, query "complaint", sorted by filing date) also found *United States v. State of Vermont*, No. 2:26-cv-00272 (filed 2026-08-10 by the United States; 18 pages; Times New Roman; text layer present). It was downloaded to a scratch directory and not saved, because the brief asks for one exemplar per doc type. Tier 2 is judged against one filer here.
2. **Type size and font.** The rule's minimum is 12 point, and it names no face. The template uses 13 pt EB Garamond, which `docs/FONTS.md` keeps for a court that names no face; the apparent size matches the filed exemplar's Times New Roman at 12 pt (EB Garamond has a smaller x-height). The filed exemplar is set in Times New Roman, and the vendored `Liberation Serif` is metric-compatible with it, so a switch is possible. Whether to switch to match the filers' convention is a question for David, not a rule defect.
3. **Sample length.** The sample is the whole filing, 12 rendered pages against the exemplar's 11 (the exemplar is set with a larger line count per page). Target 8 to 14 pages: met.
4. **Signature on its own page.** On page 12 the date line and the signature block sit alone, because the block is kept together and does not fit on page 11 under the last prayer item. A filer would often do the same; the template does not keep the last prayer item with the signature. Accepted for now.
5. **Italics.** The text layer has no italic markup, so case names are transcribed in roman. The template supports `*...*` italics, so a future sample can carry them.
6. **Caption.** The party column is closed by a rule (right and bottom) instead of the `)` column seen in some D. Vt. filings. This is a layout choice; the rule does not specify a caption form beyond Fed. R. Civ. P. 10(a).
7. **Overlay pairing.** The overlay pairs by shared words. Our page 12 (the signature) pairs with the exemplar's page 11, which carries the same signature; the word overlap there is lower because the page has little text. The overlay is a diagnostic, not a score.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`, which this doc-type folder does not have, and `tools/` is not part of this work. Render and overlay were run; the review below is the per-page check for this doc type.

## Review of the rendered pages (`samples/OUTPUT-bonges-complaint.pdf`, 12 pages, viewed at 60 dpi)

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
