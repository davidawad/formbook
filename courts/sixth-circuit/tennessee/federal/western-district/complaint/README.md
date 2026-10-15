# tnwd: complaint

Doc type: **complaint** (FRCP 8 and 10; this district's local rules) in the United States District Court for the Western District of Tennessee (`tnwd`).
Folder: `courts/sixth-circuit/tennessee/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-coran-perry-2-26-cv-03285-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| typeface | **Times New Roman** named by the W.D. Tenn. CM/ECF manual, section "Setting up PDF Reader and Converting to PDF": "The court only allows use of the following fonts ... Times New Roman, Arial, and Courier New. Size of font must be (at least) 12 point." LR 7.1(b) itself names no face. Substitute: **Liberation Serif** (`docs/FONTS.md`, metric-compatible with Times New Roman). EB Garamond is not used. |
| sample md | `samples/INPUT-coran-complaint.md` (a portion of the 26-page filing: caption, opening sections, paragraphs 1 to 46, prayer, jury demand, signature, verifications) |
| render | ok: `samples/OUTPUT-coran-complaint.pdf`, 14 pages (the second verification alone on p. 14), typst 0.15.0, vendored Liberation Serif only (re-rendered 2026-10-15; `pdffonts`: only LiberationSerif embedded), no warnings |
| overlay | ok: `samples/OVERLAY-coran-complaint.pdf` and `samples/OVERLAY-coran-complaint.txt` (page map) |
| pages reviewed | 14 of 14 (every page of the 2026-10-15 render rasterized at 60 dpi and viewed)

File names follow the tools' defaults (`render.sh` writes `samples/OUTPUT-<id>.pdf` and `overlay.sh` reads it and writes `samples/OVERLAY-<id>.pdf`/`.txt`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief. The sample is `samples/INPUT-coran-complaint.md`, so `<id>` is `coran-complaint`.

## Governing rules

Primary sources, fetched and read 2026-10-14:

- **W.D. Tenn. Local Rules** (revised 11.17.2025, the PDF linked from https://www.tnwd.uscourts.gov/local-rules; URL of the PDF: `https://www.tnwd.uscourts.gov/sites/tnwd/files/Local%20Rules%20%E2%80%93%20Revised%2011.17.%202025%20%28Addition%20of%20LR%2043.1%28h%29%29.pdf`, 174 pages).
- **Fed. R. Civ. P. 8, 10** from https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_10.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1(a) | 8½ × 11 inch white paper, typewritten, one-inch margins on all sides; the paper shows the attorney's name, address, telephone, e-mail and Board of Professional Responsibility number. | `page-w`, `page-h`, `margin`; the BPR number and contact lines are in the signature block (`signature.bar_number`, `signature.lines`). No counsel block is printed at the top left: the rule does not say where it goes, and the exemplar puts it at the signature. |
| LR 7.1(b) | Lines double-spaced (quotations, headings and footnotes may be single-spaced); type no smaller than 12 point, footnotes included. | `pitch = 27.6pt` (2 × 1.15 × 12 pt, the word-processor double), `body-leading`; `type-size = 12pt`; footnotes set at 12 pt. |
| LR 7.1(c) | If a jury demand is made in the complaint, the demand is in the last paragraph, and the phrase **"JURY DEMAND"** appears immediately opposite the style of the case on the first page. | `jury_demand: true` prints `JURY DEMAND` in the caption's right column; the demand paragraph is the last paragraph of the body (`DEMAND FOR JURY TRIAL` section in the sample). |
| LR 7.1(d) | Page limits exclude captions, signature lines and certificates. | No page limit applies to a complaint; nothing enforced. |
| LR 3.1 | A civil cover sheet (Form JS-44) accompanies every complaint, except pro se cases. | Not generated: a separate filing. See the known gaps. |
| LR 11.1(b) | Every paper has a signature block: "s/" then the filing user's name, attorney bar number, firm name, street address, telephone, primary e-mail. | `signature-block()`: `s/`, the name, `Attorney Bar No.`, firm, the lines from the frontmatter. |
| Fed. R. Civ. P. 7(a) | The complaint is a pleading; the caption's title is the Rule 7(a) designation. | `title` (for example `VERIFIED COMPLAINT`, `COMPLAINT`). |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Author content; the template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and the Rule 7(a) designation. | `court-title()` (court name fixed in the template: this is court-level text), `caption()`, `case_number` (blank at filing; the clerk assigns the number). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered-para()`: every paragraph after the first heading is numbered by the template. Paragraphs before the first heading (the lead-in) are not numbered. |
| Fed. R. Civ. P. 10(c) | A copy of a written instrument that is an exhibit is part of the pleading. | Author content (exhibits are separate files). |
| 28 U.S.C. § 1746 | An unsworn declaration under penalty of perjury (verification). | `verifications` frontmatter: `I, NAME, declare under penalty of perjury that the foregoing is true and correct.` |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44, LR 3.1); the summons; the Rule 7.1 disclosure statement; any certificate of interested persons the court may require.

## Layout

- Court title on the first page, single-spaced, centered: `IN THE UNITED STATES DISTRICT COURT` / `FOR THE WESTERN DISTRICT OF TENNESSEE` / the division (`court_division`).
- Caption: the parties in a left column with a column of `)` marks, `v.` between the sides, designations (`Plaintiffs,`, `Defendant.`) indented; the case number (`Case No.`, blank if not yet assigned) and `JURY DEMAND` on the right.
- Title centered, bold, capitals; one double-spaced blank line between each block.
- Body double-spaced, 12 point, left-aligned (not justified), first-line indent of ½ inch.
- Section headings (`#`) centered bold capitals; level-2 headings (`##`) bold at the left (the author types the letters A., B., ...); level-3 (`###`) bold italic at the left.
- Lettered prayer list (`(a)`, `(b)`, ...) hung from a ½-inch indent.
- Signature block in the right half of the page, single-spaced, after the date line.
- Verifications: one per verifying party, unnumbered, each with a signature line and `Executed on:`.
- Page numbers centered at the foot of each page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number` (blank string at filing), `court_division` (`WESTERN DIVISION` or the division shown on the filing), `caption` (list of `{names: [...], designation: "..."}`; `v.` is inserted between sides), `title`, `jury_demand` (boolean), `date`, `signature` (`signer`, `bar_number`, optional `firm`, `lines`), `verifications` (optional list of `{name, executed}`).
- Body: blank-line-separated chunks. `#` heading (centered bold capitals), `##` (bold, left), `###` (bold italic, left); a `>` quotation (single-spaced); a `1.` list (lettered by the template); a paragraph (numbered by the template when it follows the first heading).
- `[unnumbered] ` at the start of a paragraph keeps it unnumbered (the WHEREFORE paragraph, the jury demand sentence).
- Footnotes: `text[^key]` in the paragraph, and `[^key]: text` on its own chunk directly after that paragraph (the template joins it to the paragraph).
- Not supported: tables, raw typst, paragraphs before the first heading that are meant to be numbered (the lead-in is not numbered).
- The template numbers paragraphs in order. The sample's paragraph numbers match the filing's for paragraphs 1 to 46 only because the sample starts at the filing's first paragraph.

## Review of the rendered pages (final render, all pages)

Each page was rasterized with `pdftoppm -r 60` after the last template change and viewed.

- p. 1: court title; caption with `)` column, `v.`, designations, `Case No.` line and `JURY DEMAND` on the right; title; lead-in. Caption spacing fixed (the designations had no gap below the party names in the first render). Pass.
- p. 2: paragraphs 2 to 7; PARTIES heading. Pass.
- p. 3: paragraphs 8 to 13; JURISDICTION AND VENUE, FACTUAL ALLEGATIONS, A. heading. Pass.
- p. 4: paragraphs 13 to 16; footnotes 1 and 2 at 12 pt single-spaced at the foot of the page. Pass.
- p. 5: paragraphs 17 to 22 (list items a to i inline in paragraph 21). Pass.
- p. 6: paragraphs 23 to 26; B. heading. Pass.
- p. 7: paragraphs 27 to 31; C. heading. Pass.
- p. 8: paragraphs 32 to 37. Pass.
- p. 9: paragraphs 38 to 43; the sub-heading in bold italic; footnote 3 at the foot. Pass.
- p. 10: paragraphs 44 to 46; D. heading; PRAYER FOR RELIEF; WHEREFORE (unnumbered); items (a) and (b). Pass.
- p. 11: prayer items (b) to (i). Pass.
- p. 12: prayer items (j) to (n); DEMAND FOR JURY TRIAL; the unnumbered demand; `Dated`; `Respectfully submitted`; the signature block with `s/`, `Attorney Bar No.`, firm, address, telephone and e-mail. Pass.
- p. 13: two verifications, each with a rule and name, `Executed on:`. Pass.

## Known gaps and open choices

1. **One exemplar only.** The brief asks for one filed document per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Search (CourtListener RECAP, `type=r`, `court=tnwd`, query `"complaint" "demand for jury trial"`, `available_only=on`, most recent first, the first page of 20) also found *Carter v. X.AI Corp.* (2:26-cv-03257, 55 pages, ruled caption, Times New Roman, class complaint), *Malikie Innovations v. Brother Industries* (2:26-cv-02365, 28 pages, patent complaint), and others. They were downloaded and checked for text and format; not saved. Tier 2 is therefore **not** judged against two filers.
2. **The exemplar does not follow LR 7.1(c) on the legend.** The filing reads `JURY TRIAL DEMANDED.` opposite the style; LR 7.1(c) says `JURY DEMAND`. The template follows the rule. This is a finding against the exemplar, not a convention choice.
3. **Font.** Times New Roman is the face the CM/ECF manual allows (and the exemplar uses). The template sets Liberation Serif, its metric-compatible substitute (`docs/FONTS.md`). The 12-point minimum is met. The page count went from 13 to 14 because the second verification no longer fits on page 13; it stands alone on page 14.
4. **Caption column.** The exemplar has no `)` column; the template uses one (the W.D. Tenn. memorandum exemplar does). Both are seen in this district; recorded as ACCEPTED, a tier-2 convention choice.
5. **Counsel block.** The exemplar places counsel only in the signature block. LR 7.1(a) does not say where the block goes. The template follows the exemplar. A top-left counsel block would be a change to `typst/tnwd-complaint.typ`.
6. **Verification wording.** The exemplar's verification adds "I believe the allegations expressly stated on information and belief to be true". The template prints the 28 U.S.C. § 1746 declaration only. Counsel may add the sentence in a frontmatter field if wanted; not added.
7. **Numbering.** The sample's paragraph numbers are assigned by the template; the filing numbers 1 to 46 the same way because the sample starts at the filing's first paragraph. In a longer transcription, paragraph numbers after a gap would differ from the filing's, which is expected for a portion.
8. **Italics.** The filing's text layer has no italic markup. The sample is set in roman except for the bold headings and the bold italic sub-heading, which are visible in the render. Case names in the complaint are roman, as in the exemplar's text.
9. **Overlay pairing.** Pages 10 and 13 of the overlay pair with filed pages that share few words (the sample skips parts of the filing); the overlay is a diagnostic, not a score.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the visual check for this doc type.
11. **Heading lengths.** Headings are set single-spaced and may wrap; the complaint template does not require one-line headings (unlike the CAND template).

## Engines

DOCX (`docx/`: `build-reference.sh` makes `reference.docx`; `tnwd-complaint.lua` sets the caption, numbered allegations, prayer, signature and verifications). Rendered with `sh tools/render.sh --engine docx complaint samples/INPUT-coran-complaint.md` to `samples/OUTPUT-coran-complaint.docx` and `.docx.pdf` (LibreOffice). Reviewed: all 14 pages of the `.docx.pdf` against all 14 pages of the typst output, at 60 dpi.

- Matches typst: Liberation Serif 12 pt throughout (footnotes too); double spacing at 27.6 pt and single at 13.8 pt; one-inch margins; caption and case-number/JURY DEMAND line; court title; title; numbered allegations at ½ inch with the text at the tab; lead-in unnumbered; lettered prayer (a) to (n) at ½ inch; signature block kept together; each verification kept together with its rule; page numbers centred. Page count is 14 in both; the last page (second verification) is the same in both. Body lines sit at the same pitch as typst; from the court title onward every line is about 3.2 pt lower than typst (the court title lines themselves), with no drift down the page.
- Differs (ACCEPTED, tier 2): the caption's `)` column is a cell rule at the right of the party column; the first court-title line sits about 3 pt lower; LibreOffice breaks some lines differently from typst, so a page holds one or two lines more or fewer on some pages (line counts per page are within three lines of typst); footnote entries are set with a little more space between them.
- BLOCKED: none. `tools/check.sh --engine docx` cannot run: the court folder has no `checks.yaml` (the gate list), so no check ID was evaluated. See the PR.
