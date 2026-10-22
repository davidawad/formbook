# tnwd: complaint

Doc type: **complaint** (FRCP 8 and 10; this district's local rules) in the United States District Court for the Western District of Tennessee (`tnwd`).
Folder: `courts/sixth-circuit/tennessee/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| typeface | **Times New Roman** named by the W.D. Tenn. CM/ECF manual, section "Setting up PDF Reader and Converting to PDF": "The court only allows use of the following fonts ... Times New Roman, Arial, and Courier New. Size of font must be (at least) 12 point." LR 7.1(b) itself names no face. Substitute: **Liberation Serif** (`docs/FONTS.md`, metric-compatible with Times New Roman). EB Garamond is not used. |
| sample md | `usage/INPUT-complaint.md` (a portion of the 26-page filing: caption, opening sections, paragraphs 1 to 46, prayer, jury demand, signature, verifications) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx` / `.docx.pdf`, 14 pages each, on the shared cross-engine layout model (fb-595.68.31): typst 0.15.0 and LibreOffice, vendored Times New Roman only, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-complaint.pdf` (not committed) |
| pages reviewed | 14 of 14, typst and docx (every page of the 2026-10-22 renders rasterized at 60 dpi and viewed) |

## Governing rules

Primary sources, fetched and read 2026-10-14:

- **W.D. Tenn. Local Rules** (revised 11.17.2025, the PDF linked from https://www.tnwd.uscourts.gov/local-rules; URL of the PDF: `https://www.tnwd.uscourts.gov/sites/tnwd/files/Local%20Rules%20%E2%80%93%20Revised%2011.17.%202025%20%28Addition%20of%20LR%2043.1%28h%29%29.pdf`, 174 pages).
- **Fed. R. Civ. P. 8, 10** from https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_10.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1(a) | 8½ × 11 inch white paper, typewritten, one-inch margins on all sides; the paper shows the attorney's name, address, telephone, e-mail and Board of Professional Responsibility number. | `page-w`, `page-h`, `margin`; the BPR number and contact lines are in the signature block (`signature.bar_number`, `signature.lines`). No counsel block is printed at the top left: the rule does not say where it goes, and the exemplar puts it at the signature. |
| LR 7.1(b) | Lines double-spaced (quotations, headings and footnotes may be single-spaced); type no smaller than 12 point, footnotes included. | `pitch-body = 27.6pt` (2 × 1.15 × 12 pt, Word's double line), `pitch-single = 13.8pt` for the court title, caption, headings, signature, verification lines and footnotes; `type-size = 12pt`; footnotes set at 12 pt. |
| LR 7.1(c) | If a jury demand is made in the complaint, the demand is in the last paragraph, and the phrase **"JURY DEMAND"** appears immediately opposite the style of the case on the first page. | `jury_demand: true` prints `JURY DEMAND` in the caption's right column; the demand paragraph is the last paragraph of the body (`DEMAND FOR JURY TRIAL` section in the sample). |
| LR 7.1(d) | Page limits exclude captions, signature lines and certificates. | No page limit applies to a complaint; nothing enforced. |
| LR 3.1 | A civil cover sheet (Form JS-44) accompanies every complaint, except pro se cases. | Not generated: a separate filing. See the known gaps. |
| LR 11.1(b) | Every paper has a signature block: "s/" then the filing user's name, attorney bar number, firm name, street address, telephone, primary e-mail. | `signature-block()`: `s/` and the name, `Attorney Bar No.`, the firm, then the lines from the frontmatter, in the rule's order. |
| Fed. R. Civ. P. 7(a) | The complaint is a pleading; the caption's title is the Rule 7(a) designation. | `title` (for example `VERIFIED COMPLAINT`, `COMPLAINT`). |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Author content; the template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and the Rule 7(a) designation. | `court-title()` (court name fixed in the template: this is court-level text), `caption()`, `case_number` (blank at filing; the clerk assigns the number). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered-para()`: every paragraph after the first heading is numbered by the template. Paragraphs before the first heading (the lead-in) are not numbered. |
| Fed. R. Civ. P. 10(c) | A copy of a written instrument that is an exhibit is part of the pleading. | Author content (exhibits are separate files). |
| 28 U.S.C. § 1746 | An unsworn declaration under penalty of perjury (verification). | `verifications` frontmatter: `I, NAME, declare under penalty of perjury that the foregoing is true and correct.` |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44, LR 3.1); the summons; the Rule 7.1 disclosure statement; any certificate of interested persons the court may require.

## Layout

Both engines set it on the shared cross-engine model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation.

- Court title on the first page, single-spaced, centered: `IN THE UNITED STATES DISTRICT COURT` / `FOR THE WESTERN DISTRICT OF TENNESSEE` / the division (`court_division`); a blank double line below.
- Caption: one row per party line (names, the designation 1.25 in in, a blank line, `v.`, a blank line, ...), a column of `)` marks, one per line of text; `Case No.` (a blank rule until the clerk assigns one) opposite the first designation and `JURY DEMAND` opposite `v.` (LR 7.1(c)).
- Title centered, bold, a blank double line above and below.
- Body double-spaced (27.6 pt), 12 point, ragged right, first-line indent of ½ inch; a numbered paragraph's number in a ½-inch box after the indent (text at 1 in).
- Headings single-spaced, a blank single line above and 6.9 pt below, kept with what follows: `#` centered bold; `##` bold at the left (the author types the letters A., B., ...); `###` bold italic at the left.
- Quotations single-spaced, ½ inch in on both sides, 6.9 pt above and below.
- Lettered prayer list (`(a)`, `(b)`, ...): the letter in a ½-inch box ½ inch in, the text hanging at 1 in, double-spaced.
- Footnotes 12 pt (LR 7.1(b)), single-spaced in 13.8 pt lines, 7 pt apart, 12.6 pt between the text and the rule.
- Signature block (LR 11.1(b) order): `Dated:` at the margin, then from the middle of the page `Respectfully submitted,`, `s/ name`, `Attorney Bar No.`, firm, address lines; groups a blank single line apart, kept on one page with the last paragraph.
- Verifications from a new page: one per verifying party, the declaration double-spaced, two body lines of room to sign above the signature line, the name and `Executed on:`; each kept whole.
- Page numbers centered at the foot of each page, in a 13.8 pt line.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number` (blank string at filing), `court_division` (`WESTERN DIVISION` or the division shown on the filing), `caption` (list of `{names: [...], designation: "..."}`; `v.` is inserted between sides), `title`, `jury_demand` (boolean), `date`, `signature` (`signer`, `bar_number`, optional `firm`, `lines`), `verifications` (optional list of `{name, executed}`).
- Body: blank-line-separated chunks. `#` heading, `##`, `###`; a `>` quotation (single-spaced); a `1.` list (lettered by the template); a paragraph (numbered by the template when it follows the first heading).
- `~ ` at the start of a paragraph keeps it unnumbered (the WHEREFORE paragraph, the jury demand sentence); both engines read it.
- Footnotes: `text[^key]` in the paragraph, and `[^key]: text` as its own chunk.
- Not supported: tables, raw typst, paragraphs before the first heading that are meant to be numbered (the lead-in is not numbered).
- The template numbers paragraphs in order. The sample's paragraph numbers match the filing's for paragraphs 1 to 46 only because the sample starts at the filing's first paragraph.

## Review of the rendered pages (2026-10-22, typst and docx, all pages)

Each page of both renders was rasterized with `pdftoppm -r 60` after the last change and viewed; the two renders break every line and page alike (XENG-001..003 PASS, 313/313 lines).

- p. 1: court title; caption with the `)` column, `v.`, designations, `Case No.` with its blank and `JURY DEMAND` on the right; title; lead-in; NATURE OF THE ACTION; paragraphs 1 and 2. Pass.
- pp. 2-3: paragraphs 2 to 13; PARTIES, JURISDICTION AND VENUE, FACTUAL ALLEGATIONS, heading A. Pass.
- p. 4: paragraphs 13 to 16; footnotes 1 and 2 at 12 pt below the rule (paragraph 17 does not fit and opens p. 5, so the page ends short). Pass.
- pp. 5-8: paragraphs 17 to 34; headings B. and C. Pass.
- p. 9: paragraphs 35 to 39; the bold-italic sub-heading; footnote 3 (the page ends short before paragraph 40). Pass.
- p. 10: paragraphs 40 to 45. Pass.
- p. 11: heading D., paragraph 46, PRAYER FOR RELIEF, WHEREFORE (unnumbered), items (a) to (d). Pass.
- p. 12: items (d) to (j). Pass.
- p. 13: items (k) to (n); DEMAND FOR JURY TRIAL; the unnumbered demand; `Dated`; the signature block. Pass.
- p. 14: the two verifications, each with room to sign, the rule, the name and `Executed on:`. Pass.

## Known gaps and open choices

1. **One exemplar only.** The brief asks for one filed document per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Search (CourtListener RECAP, `type=r`, `court=tnwd`, query `"complaint" "demand for jury trial"`, `available_only=on`, most recent first, the first page of 20) also found *Carter v. X.AI Corp.* (2:26-cv-03257, 55 pages, ruled caption, Times New Roman, class complaint), *Malikie Innovations v. Brother Industries* (2:26-cv-02365, 28 pages, patent complaint), and others. They were downloaded and checked for text and format; not saved. Tier 2 is therefore **not** judged against two filers.
2. **The exemplar does not follow LR 7.1(c) on the legend.** The filing reads `JURY TRIAL DEMANDED.` opposite the style; LR 7.1(c) says `JURY DEMAND`. The template follows the rule. This is a finding against the exemplar, not a convention choice.
3. **Font.** Times New Roman is the face the CM/ECF manual allows (and the exemplar uses); both engines set the vendored Times New Roman (`fonts/`), and the docx names it through `{font}`. The 12-point minimum is met.
4. **Caption column.** The exemplar has no `)` column; the template uses one (the W.D. Tenn. memorandum exemplar does). Both are seen in this district; recorded as ACCEPTED, a tier-2 convention choice.
5. **Counsel block.** The exemplar places counsel only in the signature block. LR 7.1(a) does not say where the block goes. The template follows the exemplar. A top-left counsel block would be a change to `typst/tnwd-complaint.typ`.
6. **Verification wording.** The exemplar's verification adds "I believe the allegations expressly stated on information and belief to be true". The template prints the 28 U.S.C. § 1746 declaration only. Counsel may add the sentence in a frontmatter field if wanted; not added.
7. **Numbering.** The sample's paragraph numbers are assigned by the template; the filing numbers 1 to 46 the same way because the sample starts at the filing's first paragraph. In a longer transcription, paragraph numbers after a gap would differ from the filing's, which is expected for a portion.
8. **Italics.** The filing's text layer has no italic markup. The sample is set in roman except for the bold headings and the bold italic sub-heading, which are visible in the render. Case names in the complaint are roman, as in the exemplar's text.
9. **Overlay pairing.** Pages 10 and 13 of the overlay pair with filed pages that share few words (the sample skips parts of the filing); the overlay is a diagnostic, not a score.
10. **Selftest.** `tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has none, so it is not run here. `tools/check.sh` runs on both engines.
11. **Heading lengths.** Headings are set single-spaced and may wrap; the complaint template does not require one-line headings (unlike the CAND template).

## Engines

typst (`typst/tnwd-complaint.typ`) is the reference; docx (`docx/reference.xml`, base="xengine" in the typst face `{font}`, and `docx/tnwd-complaint.lua`, which writes the court title, caption table, title, headings, prayer items, signature and verifications with the typst spaces in twips and leaves body paragraphs, quotations and footnotes to pandoc in the reference styles). `sh tools/check.sh <dir>` and `--engine docx`: 0 failed; XENG-001..003 PASS (313/313 lines, 14 pages), `params.cross_engine: gate` in `eval.yaml`. No latex engine for this folder.

- Differences: none in line or page breaks; widths of identical lines within 0.44 pt, baselines within 0.2 pt.
- BLOCKED: none.
