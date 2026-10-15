# ksd: complaint

Doc type: **complaint** in the United States District Court for the District of Kansas (`ksd`).
Folder: `courts/tenth-circuit/kansas/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-jenkins-2-26-cv-02623-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-jenkins-complaint.md`: the whole filing, 14 pages, transcribed (no paragraph numbers; the template numbers them) |
| render | ok: `samples/OUTPUT-jenkins-complaint.pdf`, 14 pages, typst 0.15.0, vendored Liberation Serif only (`pdffonts`: LiberationSerif, -Bold, -Italic), no warnings (`tools/render.sh`) |
| overlay | fail: `tools/overlay.sh` exits 1, "no exemplar pdf": `exemplars/` holds no `FILED-EXAMPLE-*.pdf` in this snapshot. `samples/OVERLAY-jenkins-complaint.txt` is left from the EB Garamond render and is stale; no `.pdf` overlay exists |
| pages reviewed | 14 of 14: every page rendered at 70 dpi and viewed after the Liberation Serif change (fonts pass) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and the Rule 7(a) designation; the title of a complaint names all the parties. Source: https://www.law.cornell.edu/rules/frcp/rule_10 (text checked 2026-10-14). | `court-title()`, `caption()`, `cover()`. The file number is `case_number`; when it is empty the caption prints a blank line, as the filed copy does. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. Same source. | `allegations()`: each body paragraph is numbered from 1; headings and lists are not. |
| D. Kan. R. 5.1(a) | Papers are letter-size, double-spaced, in no less than 12-point (10-point for footnotes), "Times New Roman or similar," uncompressed font. Source: https://www.ksd.uscourts.gov/sites/ksd/files/MASTER%20COPY%20updated%204%2027%2026.pdf (the Rules of Practice, "As amended 4/1/26"; text checked 2026-10-14). | `page` (US Letter), `double-leading` (27.6 pt pitch, measured on page 2 of the render with `pdftotext -bbox`), `type-size` 12 pt, `footnote-size` 12 pt, `font-family` "Liberation Serif" (the docs/FONTS.md substitute for Times New Roman; metric-compatible). |
| D. Kan. R. 5.1(b)(1) | Signature block gives the signer's name, address, telephone, facsimile and email. | `signature-block()` prints every line the sample gives. The facsimile line is not asserted (see Known gaps). |
| D. Kan. R. 5.1(b)(2) | Attorneys include their state supreme court registration number (or the equivalent outside Kansas). | Author content in the signature lines (the filed copy shows "KS Bar No."). |
| D. Kan. R. 3.1 | A civil cover sheet must accompany a complaint. | Not produced here: a separate filing (see Known gaps). |

Not produced by this template: the civil cover sheet (D. Kan. R. 3.1), the summons, the Rule 7.1 disclosure statement (Fed. R. Civ. P. 7.1 applies to diversity cases and nongovernmental corporate parties; not checked), and the D. Kan. trial-location designation that the docket shows on the complaint's ECF event (not a rule of the local rules; it is an ECF entry).

## Layout

- Letter paper, 1-inch margins on all sides, no line numbers and no pleading rules (D. Kan. does not require pleading paper; the reference courts do).
- Cover: court name on two centered lines; caption with a column of ")" marks as tall as the party column (measured, so it always matches); the case number and "JURY DEMANDED" on the right; the title in centered bold capitals.
- Body double-spaced at a 27.6 pt pitch (2 × the 13.8 pt single pitch); no extra space between paragraphs.
- Numbered paragraphs: first-line indent of 0.5 inch, the number, then an em space. Wrapped lines return to the margin.
- Headings: level 1 centered bold capitals (unnumbered); level 2 bold, Roman numerals I., II., ... with a hanging number; level 3 centered bold (a count subtitle).
- Lists: lettered (a), (b), ... (the markdown `1.` items become letters).
- A level 1 heading starting with PRAYER or JURY stops the paragraph numbering: the prayer, the WHEREFORE paragraph and the jury demand are not allegations and are not numbered.
- Typeface: Liberation Serif, 12 pt. D. Kan. R. 5.1(a) names "Times New Roman or similar"; `docs/FONTS.md` maps Times New Roman to Liberation Serif (metric-compatible). EB Garamond is not used here.
- Footnotes: 12 pt, single-spaced, with a short rule above them.
- Signature block: "DATED:" on the left; "Respectfully submitted," and the party line; "/s/" signer; the lines given in the frontmatter, single-spaced, kept on one page.
- Page number centered at the foot of every page, including the first.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

**Frontmatter**

| Field | Required | Feeds |
|---|---|---|
| `case_number` | no (blank as filed) | "Case No." in the caption |
| `caption.parties` | yes | list of `{names: [...], designation: "..."}`; "v." is inserted between parties |
| `title` | yes | the centered title (printed in capitals) |
| `jury_demand` | no | "JURY DEMANDED" in the caption |
| `lead_in` | no | an unnumbered paragraph after the title (the filed copy's opening sentence) |
| `date` | no | "DATED:" line |
| `signature.intro` | yes | lines above the signer ("Respectfully submitted," and the party line) |
| `signature.signer` | yes | the "/s/" line, e.g. `/s/ George A. Barton` |
| `signature.lines` | yes | lines after the signer; `""` is a blank line between groups of counsel |

**Body**: `# HEADING` (level 1), `## Heading` (level 2, numbered I., II., ...), `### Heading` (level 3); a paragraph is one numbered allegation; a list (`1.`) is lettered; `[^key]` footnotes with their definitions anywhere in the body. Not supported: tables, raw typst. Case names are italic when written `*...*`.

## Known gaps and open choices

1. **One exemplar.** The search found two more complaints in the same court (Douglas, 21 pages; Worthington, 56 pages), not saved. Tier 2 would be judged against 2 or 3 filers; with one exemplar the tier-2 judgment is single-filer.
2. **Font (resolved by the fonts pass).** D. Kan. R. 5.1(a) names "Times New Roman or similar", so the template uses Liberation Serif, the `docs/FONTS.md` substitute (metric-compatible), in place of EB Garamond. The render is still 14 pages, the same count as the filed copy. The filed copy is not in this snapshot, so the visual match to it was not re-checked.
3. **Margins.** The D. Kan. rules set no margin. One inch was chosen; the exemplar's margins were not measured (measuring them would be a coordinate-based template, which the rules forbid).
4. **Prayer lettering.** The filed copy letters the prayer A., B., C.; the template letters every list a., b., c. (one lettering style for all lists). Tier-2 difference, not a rule.
5. **Facsimile number.** D. Kan. R. 5.1(b)(1)(D) lists the facsimile number as a required part of the signature block. The filed copy has none, and the sample has none, so the template does not assert it. A sample for a filer who has a fax line puts it in `signature.lines`.
6. **Civil cover sheet.** D. Kan. R. 3.1 requires the civil docket cover sheet with the complaint. It is a clerk's form, not produced here.
7. **Paragraph numbers.** The template numbers the allegations from 1; the render ends at paragraph 73, the filed copy's last numbered paragraph. The sample does not carry the filed numbers, so a line-by-line match is not checked.
8. **Overlay pairing.** The sample and the filed copy share pages one to one (14 each), so the overlay pairs pages by index. The overlay is a diagnostic, not a score.
9. **Output and overlay file names.** `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `samples/OVERLAY-<id>.pdf`/`.txt`; the sample is `samples/INPUT-<id>.md` (the file-role naming in `docs/EVAL-LOOP.md`). The brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools produce, and the tools are shared, so they were not changed.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none of those, and the brief forbids editing `tools/`. The render and the overlay were run; the page review above is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (`samples/OUTPUT-jenkins-complaint.pdf`, 14 pages, Liberation Serif)

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption with ")" column, "Case No." blank, JURY DEMANDED, COMPLAINT title, lead-in, I. PROCEDURAL BACKGROUND, paragraphs 1 and 2, footnote 1 | Pass |
| 2 | Paragraph 3; paragraphs 4 to 11 under PARTIES | Pass |
| 3 | FACTS heading; paragraphs 12 to 15; heading I. (two lines) and paragraph 16 begins | Pass |
| 4 | Paragraph 16 ends; paragraphs 17 to 21; footnote 2 with italic case names | Pass |
| 5 | Paragraphs 22 and 23; heading II.; paragraphs 24 and 25 with the first lettered list (a. to f.) | Pass |
| 6 | Lettered list (a. to t.) of paragraph 26 | Pass |
| 7 | Paragraph 27 with its list (a. to h.); paragraphs 28 to 30 | Pass |
| 8 | Paragraphs 31 to 34; heading III.; paragraph 35 | Pass |
| 9 | Paragraphs 36 to 39; heading IV. (two lines); paragraphs 40 to 43 | Pass |
| 10 | Paragraphs 44 to 48; heading V. (two lines); paragraphs 49 and 50 | Pass |
| 11 | Paragraphs 51 to 57 | Pass |
| 12 | Paragraphs 58 to 60; heading VI.; paragraphs 61 to 65 | Pass |
| 13 | Paragraphs 66 to 72; COUNT I with its subtitle; paragraph 73 | Pass |
| 14 | PRAYER FOR RELIEF (lettered a. to d., unnumbered WHEREFORE); JURY TRIAL DEMAND; signature block (DATED, "Respectfully submitted," party line, "/s/", counsel lines), on its own page as in the filed copy | Pass |

Gate 2 rows are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Log of changes made during review

- Paragraph lines overprinted (each paragraph's last line sat on the next paragraph's first line, because typst adds no leading between blocks). Fixed: each paragraph and list is a block with a gap of one leading below it; the render went from 11 to 14 pages, the filed copy's count.
- Footnote references printed as literal `[^1]`. Fixed: definitions are attached to each chunk that cites them.
- Headings rendered larger than the 12 pt body (typst's default heading sizes). Fixed: headings are set at the body size.
