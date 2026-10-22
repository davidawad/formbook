# N.D. Okla. (oknd): complaint

Doc type: **complaint** (with jury demand) in the United States District Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: paragraphs 1-46 (caption to damages), Counts I and II, jury demand, prayer, signature |
| typeface | face required: none (LGnR2-4(a) sets a 12-pt floor and names no face). **Times New Roman 12 pt** (vendored; `("Times New Roman", "Liberation Serif")`), the house standard (`docs/FONTS.md`), on both engines; `data/exemplar-fonts.json` `template_face` (the exemplar's Cambria/Caladea is one filer's style, tier 3). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx.pdf`, 15 pages each, typst 0.15.0 and LibreOffice, vendored Times New Roman only, no warnings |
| cross-engine | the docx breaks every line and page as typst does: `fb check --engine docx` XENG-001..003 PASS (335/335 lines, 15 = 15 pages), `params.cross_engine: gate` in `eval.yaml` (fb-595.68.33) |
| pages reviewed | 15 of 15 typst and 15 of 15 docx (every page rendered at 50 dpi and viewed side by side) |

## Governing rules

Primary sources, all fetched 2026-10-14.

| ID | Rule | Requirement | Source | Where in the template |
|---|---|---|---|---|
| OKND-FORM-001 | LGnR2-4(a), Local Rules (2026-07-31 version) | "All papers ... must be double-spaced, if typewritten." The 2023 general order carries the same text. | https://www.oknd.uscourts.gov/sites/default/files/2026-07-31%20Local%20Rules.pdf | `pitch-body` = 27.6 pt: the face's own double spacing (twice Times New Roman's 13.8 pt single line, what a word processor's "Double" sets at 12 pt), in typst and in the docx (552 twips). |
| OKND-FORM-002 | LGnR2-4(a) | "The print style, including footnotes, must not be smaller than 12-point font." | same | `type-size` = 12 pt, `footer-size` = 12 pt. |
| OKND-FORM-003 | LGnR2-4(a) | 8½ × 11 inch paper, one side; margins "a minimum of one inch on the top, bottom, and sides"; "The use of 'Exactly 24 pt' spacing is not permitted"; "All papers must be clearly legible." | same (rule text re-read 2026-10-22, p. 9) | `margin` (1 in all sides), letter page, single-side output. No 24 pt pitch anywhere: the body is 27.6 pt, true double spacing of the face. The docx states it as exact 27.6 pt line boxes (the cross-engine model, so Word breaks as typst does); LibreOffice's "Double" (auto 480) sets the same 27.6 pt pitch but moves the last line of a page, so it was not used (see gaps). |
| OKND-CAP-001 | Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." "The title of the complaint must name all the parties." | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `court-title()` (the court's name, two centered lines), `caption-table()` (all parties; file number on the right), `title` in the cover. |
| OKND-CAP-002 | LCvR38-1, Jury Demand | "If a party demands a jury trial by endorsing it on a pleading ... a notation shall be placed on the front page of the pleading, immediately following the title of the pleading, stating 'Jury Trial Demanded.'" | 2026 Local Rules, p. 50 (same text as the 2023 general order) | `jury_demand: true` puts "Jury Trial Demanded" directly under the title, on page 1. |
| OKND-CONT-001 | Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | https://www.law.cornell.edu/rules/frcp/rule_10 | `allegations()` numbers each body paragraph from 1; headings and lists are not numbered. |
| OKND-CONT-002 | Fed. R. Civ. P. 8(a)(1)-(3) | A pleading with a claim must contain a short and plain statement of the grounds for jurisdiction, of the claim, and "a demand for the relief sought." | https://www.law.cornell.edu/rules/frcp/rule_8 (verified 2026-10-14) | Author content (the sample has jurisdiction and venue headings and a prayer). The template does not check the wording. |
| OKND-CONT-003 | LCvR3-1(a) | The initiating document and the Civil Cover Sheet (JS-44) are "separate documents." | 2026 Local Rules, p. 26 | Not produced: a separate filing. |
| OKND-CONT-004 | LCvR5.2-1; Fed. R. Civ. P. 5.2 | Personal data identifiers are redacted by counsel and the parties. | 2026 Local Rules, p. 29 | Author responsibility. The sample contains no identifiers beyond counsel's public bar information. |

Not produced by this template: the civil cover sheet, the summons, the Rule 7.1 / LCvR7.1-1 disclosure statement (only needed when a party requires it), and any exhibits.

## Layout

The numbers are in `typst/oknd-complaint.typ` (Parameters) and, in twips, in `docx/oknd-complaint.lua` and `docx/reference.xml`; both engines lay the page out on the shared cross-engine model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`: every line a box of its pitch, the space between blocks the larger of the two, first-fit breaks, no kerning, ligatures or hyphenation).

- Plain page, no line numbers, no pleading rules (N.D. Okla. does not require pleading paper; LGnR2-4 does not mention numbered lines). Footer: the page number centred at 12 pt in a single line whose box ends 0.5 in above the page edge.
- Times New Roman 12 pt. Body lines 27.6 pt apart (the face's double spacing, LGnR2-4(a)); the court name, caption, title, headings and signature block in single 13.8 pt lines.
- Cover on page 1, body begins under the title on the same page (no forced page break): the court name (two centered bold lines), a blank double line, the caption (parties in the left column, each side's designation 1.8 in in, "v." centred between sides with a blank single line above and below, the column ruled down its right and across its foot; "Case No." on the right, centred on the party column's height), the title (bold, centered, 27.6 pt below the caption), and the jury notation 13.8 pt under it if `jury_demand` is true.
- No counsel block at the top. The local rules do not require one, and both exemplars put counsel at the end (signature block).
- Headings: `#` centered bold caps; `##` centered bold; `###` bold italic at the margin; single-spaced with a blank single line (13.8 pt) above and below, kept with the text after them.
- Paragraphs: no space between them; first line indented 0.5 in, the number in a 0.5 in box (its text starts 1 in from the margin), numbered from 1; continuation lines flush left. The lead-in (`lead_in`) and the `WHEREFORE` paragraph are indented, unnumbered.
- Lists (subparagraphs and the prayer) are lettered (a), (b), ...: the label at 0.5 in in a 0.4 in box, the item's lines hanging at 0.9 in, on the body pitch; a list may break across pages.
- A paragraph beginning `WHEREFORE` is the prayer's lead-in and is not numbered (see gaps).
- Signature block (single-spaced, on one page, kept with the last chunk of the body so it never stands alone): "Dated:" at the left margin and "Respectfully submitted," 3.3 in in on the same line, then a blank double line, "/s/" and the signer's lines in the same column.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (string, verbatim; the court assigns it), `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between sides), `title` (the title of the pleading), `jury_demand` (true/false; required for the LCvR38-1 notation), `lead_in` (optional, unnumbered introductory paragraph), `date` (string), `signature` (`signer`, and `lines` for OBA number, firm, address, telephone, email).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings; a list (`1.` items, rendered as (a), (b), ...); or a paragraph (numbered by the template). Do not type paragraph numbers.
- Not supported: tables, footnotes (none used), raw typst.

## Render and check

```sh
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/northern-district/complaint usage/INPUT-complaint.md
sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/northern-district/complaint usage/INPUT-complaint.md
sh tools/check.sh courts/tenth-circuit/oklahoma/federal/northern-district/complaint --engine typst   # 9 passed, 0 failed
sh tools/check.sh courts/tenth-circuit/oklahoma/federal/northern-district/complaint --engine docx    # 13 passed, 0 failed (XENG-001..003 PASS)
just overlay courts/tenth-circuit/oklahoma/federal/northern-district/complaint                      # .overlay/, not committed
```

The overlay is a diagnostic, not a score. The exemplar is 24 pages in Cambria/Calibri, not double-spaced, with a different caption layout, and the sample omits Counts III-XIII: the layers agree on words and not on line position.

## Visual review (Gate 2 record, all 15 pages of both engines, rendered at 50 dpi and looked at side by side; fb-595.68.33)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, caption, title, "Jury Trial Demanded", lead-in, Nature of the Action, paragraph 1 | OK on both engines. Caption rule on the right and bottom; "Case No." centred on the party column. Jury notation directly under the title. |
| 2-3 | Paragraphs 2-8 | OK. Double-spaced (27.6 pt), numbers at the 0.5 in indent, text from 1 in. |
| 4 | Parties, paragraphs 9-12 | OK. Heading at the top of the page with its paragraph. |
| 5 | Paragraphs 13-18, Jurisdiction and Venue | OK. |
| 6 | Paragraphs 19-22, Securities at Issue | OK. The page ends early: "Factual Allegations", heading A. and paragraph 23 go on together (headings are kept with their text). ACCEPTED. |
| 7-10 | Factual Allegations, A.-D., paragraphs 23-42 | OK. Bold-italic sub-headings at the margin, two-line headings single-spaced. |
| 11-12 | E., paragraph 43 and the list (a)-(i), paragraphs 44-48, Claims for Relief, Count I | OK. Lettered items hang at 0.9 in. |
| 13 | Paragraphs 48-56, Count II | OK. |
| 14 | Demand for Jury Trial (57), Prayer for Relief, WHEREFORE (unnumbered), (a)-(j) | OK. |
| 15 | Prayer (k)-(l), date, signature block | OK. The signature block is with the last prayer items, nothing spills. |

Reviewed pages: 15 of 15 (typst) and 15 of 15 (docx); the two engines set the same words on every line and page.

## Known gaps and open choices

1. **One exemplar only.** Tier 2 of the eval loop asks for two or three filers. The CourtListener search (`type=r`, `court=oknd`, complaints filed 2024 onward, RECAP documents marked available) returned one downloadable complaint. The other new complaint (Nichols v. Reed, 4:26-cv-00616, pro se) is not available. Tier 2 is **not** judged against two filers.
2. **The exemplar does not carry the LCvR38-1 notation.** Lord's complaint is captioned "Complaint and Demand for Jury Trial" and has no "Jury Trial Demanded" line under the title. The template follows LCvR38-1 (tier 1), so the overlay shows the notation as a difference from the filed document. This is a finding about the exemplar, not a template defect.
3. **Font and size.** Times New Roman 12 pt on both engines (was EB Garamond, then Caladea, at 13 pt in typst and EB Garamond in the docx, which failed DEF-FONT-002). The rule's floor is 12 pt and is met; it names no face.
4. **Caption, signature block and headings are single-spaced.** LGnR2-4 says "all papers ... must be double-spaced" and does not exempt the caption, the signature block, or headings. They are single-spaced as in the exemplar; headings have a blank single line above and below. Flagged for David's call.
5. **Lettered lists, not numerals.** The exemplar's prayer uses "1., 2., ...". The template letters all lists (a), (b), ... (as the cand complaint does). The rules do not specify; this is a convention choice, recorded as ACCEPTED.
6. **Prayer lead-in.** A paragraph beginning `WHEREFORE` is unnumbered. This is a structural convention in the template (a prayer lead-in is not an allegation); the rule does not say so. Flagged.
7. **Transcription.** The sample transcribes paragraphs 1-46 (so that Count I's "paragraphs 1 through 46" is accurate), Counts I and II, the jury demand and the prayer. Counts III-XIII are not transcribed, and the jury demand (exemplar ¶ 118) is numbered 57 by the template. Extraction artifacts in the source text ("15)", "4.-", "Doe's") were removed; "Wherefore" and signature-block spacing were normalized. Two quoted passages were reflowed without changing words (the Blume signature block, the term sheet's "Funding Up to $50,000,000" line).
8. **Paragraph numbering.** The template numbers from 1 and does not reproduce the filed numbers (see 7).
9. **Certificate of service.** None for a complaint: service is by summons (Rule 4). Not produced.
10. **Civil cover sheet, summons, disclosure statement.** Not produced (see Governing rules).
11. **Selftest.** `tools/check-selftest.sh` takes a court folder (with `court.json`); it does not run on this doc-type folder. `tools/check.sh` runs here (see Render and check).
12. **"Exactly" line boxes in the docx.** LGnR2-4(a) bars "Exactly 24 pt" spacing. The docx sets its body lines as exact 27.6 pt boxes (Word shows "Exactly 27.6 pt"), the true double spacing of the face and the same pitch Word's "Double" gives at 12 pt; LibreOffice's "Double" (auto, 480) was tried and sets the same 27.6 pt pitch but lets a page's last line overrun, so seven page ends moved off typst's. Whether the clerk reads the rule as barring any "Exactly" setting, or only the compressed 24 pt one, is David's call.

## Engines

DOCX engine (`docx/`: `reference.xml`, `oknd-complaint.lua`; no shell, no binary reference: `fb render` builds the reference document from `reference.xml`, `base="xengine"`, the face only as `{font}`). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/northern-district/complaint usage/INPUT-complaint.md`.

- **Matches the typst form, line for line:** the filter reads the sample chunk by chunk as typst does and writes every paragraph with the typst pitch and spaces (exact 552 twips body, 276 single); Times New Roman 12 pt; the 12 pt page number in a 276-twip footer line 0.5 in above the page edge; the caption as a two-column table (party column ruled at right and foot, the case number centred beside it); typed paragraph numbers in a 0.5 in tab, lettered list labels in a 0.4 in tab; headings and the signature block kept with what follows. XENG-001..003 PASS: 335/335 lines and 15 = 15 pages.
- **Differs from typst:** allegation numbers and list labels are typed text, not Word list fields (they do not renumber when a paragraph is added by hand). The caption is a Word table. Footnotes are not used by this form.
- **BLOCKED:** none.
