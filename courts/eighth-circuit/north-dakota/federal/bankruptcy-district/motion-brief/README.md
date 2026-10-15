# ndb: motion brief (motion with memorandum in support)

Doc type: **memorandum in support of a motion** in the United States Bankruptcy Court for the District of North Dakota (`ndb`), filed in an adversary proceeding with a motion under FRBP 9013. The exemplar is the memorandum supporting a motion to compel.
Folder: `courts/eighth-circuit/north-dakota/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-elliott-24-07012-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-elliott-memo.md` (full transcription of the 10-page memorandum: caption, 27 numbered paragraphs, headings, one footnote, block quotations, signature) |
| render | ok: `samples/OUTPUT-elliott-memo.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-elliott-memo.pdf` and `samples/OVERLAY-elliott-memo.txt` (page map) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed; pages 9 and 10 re-viewed after the signature change) |

Commands (run from /work/repo with the toolchain on PATH):

```
sh tools/render.sh courts/eighth-circuit/north-dakota/federal/bankruptcy-district/motion-brief samples/INPUT-elliott-memo.md
sh tools/overlay.sh courts/eighth-circuit/north-dakota/federal/bankruptcy-district/motion-brief elliott-memo
```

File names follow the repo's role-in-the-name convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`), which the shared tools read and write. The brief's `<id>.md` / `<id>-overlay.pdf` names were not used, for the same reason as in `../adversary-complaint/README.md`.

## Governing rules

Primary sources were fetched 2026-10-14 (Cornell LII copies of the federal rules; the District's own 2023 local rules PDF).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 9013(b) | A motion must state its grounds with particularity and set forth the relief requested. https://www.law.cornell.edu/rules/frbp/rule_9013 | The memorandum states the grounds in numbered paragraphs; the motion itself (a separate filing) carries the relief. |
| D.N.D. Bankr. L.R. 7007-1(B) | In an adversary proceeding, a non-dispositive motion is filed with a memorandum in support, not to exceed **20 pages**; response 14 days, not to exceed 20 pages; reply 7 days, not to exceed 7 pages. Dispositive motions (FRCP 12 or 56): memorandum 40 pages, 25 of argument. https://www.ndb.uscourts.gov/sites/default/files/local_rules/Official%20local%20rules%202023.pdf (2023, effective 2023-02-06) | Not checked by the template. The sample is 10 pages, inside the 20-page limit for a non-dispositive motion. Page count is a reviewer check. |
| D.N.D. Bankr. L.R. 7007-1(C) | The notice of a motion must include the number of days an interested party has to respond. (Same URL.) | Not produced: the notice of motion is a separate filing (see "Not produced"). |
| D.N.D. Bankr. L.R. 9013-1(A) | For motions governed by FRBP 9013, interested parties have 14 days to respond. (Same URL.) | Not produced by the template (a notice-of-motion item). |
| FRBP 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; caption must substantially conform to Form 416. https://www.law.cornell.edu/rules/frbp/rule_7010 | `cover()` / `caption()`: court name, debtor block, parties, case number, adversary number, title. |
| FRCP 10(a) | Caption: court name, title, file number, Rule 7(a) designation. https://www.law.cornell.edu/rules/frcp/rule_10 | As above. |
| FRCP 10(b) | Claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-blocks()`: every paragraph is numbered 1, 2, ... (the memorandum's conclusion is numbered too, as in the exemplar). |
| FRBP 9004(a), (b) | Legible; caption with court name, title, case and adversary numbers, and a brief designation of the paper. https://www.law.cornell.edu/rules/frbp/rule_9004 | 12-point type; caption; title centered below it. |
| FRBP 9011(a) | Signed by an attorney of record in the attorney's individual name, with address and telephone number. https://www.law.cornell.edu/rules/frbp/rule_9011 | `signature()`: "Dated", "By: /s/", name, bar number, firm, address, telephone and e-mail (from `signature.lines`). |

No type-size, margin, or spacing rule appears in the 2023 bankruptcy local rules. The District's general local rules were not retrievable on 2026-10-14 (see Known gaps). The form choices below are the exemplar's and the Word convention for double spacing.

## Layout choices (not set by a rule we could read)

- **Type:** EB Garamond 12 pt (vendored). Typeface row (fonts pass, 2026-10-14): face required by the rules = none (FRBP 9013, FRCP 10, FRBP 9004 and the 2023 bankruptcy local rules name no face); substitute = none, so EB Garamond is kept by policy (`docs/FONTS.md` "No face named"). The exemplar is Times New Roman 12 pt; a filer's choice is not a rule, so it is not chased (tier 2 at most). Court site not reachable on 2026-10-14 (HTTP 500), so the District general rules remain unverified.
- **Spacing:** body pitch 27.6 pt (Word's double spacing for 12 pt Times New Roman, 2 x 13.8 pt); `body-leading = pitch - 0.65em` gives that pitch with EB Garamond. Caption and signature are single spaced.
- **Margins:** 1 inch; page number centered at the foot of each page.
- **Caption:** as in `../adversary-complaint/README.md`: court name on two lines, debtor block ("In re:"), parties with "v.", a column of ")" marks, case number, chapter and adversary number at the right. The exemplar puts the title in the right-hand caption column; the template centers it below the caption, a common alternative. Recorded as a tier-2 choice.
- **Paragraphs:** numbered from 1, first line indented 0.5 inch. Quotations are indented both sides and single spaced, not numbered. A paragraph that continues after a quotation is flush left and unnumbered (exemplar: "This was at a time when...").
- **Footnotes:** real typst footnotes (the exemplar's footnote 1), placed at the foot of the page where the reference falls.
- **Headings:** centered bold caps as written in the sample.
- **Signature:** "Dated: <date>" at left; "By: /s/ <signer>" and the signer's block at right. No "Respectfully submitted," (the exemplar has none). The last numbered paragraph is kept with the signature block, so a signature never sits alone on a page.
- **Certificate of service:** optional (`certificate_of_service` in the frontmatter, rendered after the signature). The exemplar has none, so the sample does not use one.
- **ECF header:** the court's "Case ... Doc 36 Filed ... Entered ..." stamp is added at filing and is not reproduced.

## Sample

`samples/INPUT-elliott-memo.md` transcribes the complete 10-page memorandum: caption, all 27 numbered paragraphs (numbering checked against the exemplar: 1 to 27), the three quotations, the continuation paragraphs, the footnote, and the signature block. Wording, punctuation, and the filer's own typos are kept as filed (for example the stray quotation mark in paragraph 24 and "Defendant’s" in paragraph 10). Differences from the filed document:

- The ECF header is not reproduced.
- The exhibits (Kaler affidavit, Exhibits 1 to 8) are referenced, not included, as in the filing.

## Overlay

`samples/OVERLAY-elliott-memo.pdf`: red is our render, blue is the filed exemplar. Pairing by shared words (`OVERLAY-elliott-memo.txt`):

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 | 1 | 90.7% |
| 2 | 2 | 90.0% |
| 3 | 3 | 88.2% |
| 4 | 4 | 80.1% |
| 5 | 5 | 77.5% |
| 6 | 6 | 73.6% |
| 7 | 7 | 53.6% |
| 8 | 9 | 47.0% |
| 9 | 9 | 42.6% |
| 10 | 10 | 43.0% |

The overlay is a diagnostic, not a score. The lower overlap on pages 7 to 10 comes from the typeface and from page breaks that fall at different words from the filed ones (our page 8 pairs with filed page 9, because our page breaks come a few lines earlier).

## Known gaps and open choices

1. **Typeface.** As in the adversary complaint: EB Garamond is kept for the exemplar's Times New Roman. A vendored Times-metric substitute exists (`Liberation Serif`, `docs/FONTS.md`), but no rule we could read names Times, so switching is a filer-convention choice, not a rule fix (fonts pass, 2026-10-14).
2. **One filer only.** Tier 2 asks for 2 or 3 filers. Other ND bankruptcy memoranda in CourtListener RECAP were looked at (Ahlgren v. Berg, 24-07014, a motion to dismiss party, 3 pages; Generations on 1st v. Red River, 25-07009, an exhibit of unpublished cases); none was a 10-page memorandum with a filer whose format could be compared, so none is saved. Tier 2 is therefore **not** judged against two filers.
3. **Page limit not enforced.** The template does not count pages. The sample is 10 pages against a 20-page limit (L.R. 7007-1(B), non-dispositive). A dispositive motion has a 40-page limit with 25 pages of argument; a different template setting would be needed only if the motion were dispositive, which the template does not detect.
4. **Notice and proposed order.** D.N.D. Bankr. L.R. 7007-1(C) requires the notice of motion to state the number of days to respond (14 days under 9013-1(A)). The notice, the motion (Doc 35 in the exemplar's docket), and any proposed order are separate filings and are not produced.
5. **Certificate of service.** Not in the exemplar; the field is optional and no service rule was verified for it in this pass. A reviewer should confirm the service requirement for the motion before using it.
6. **Lists not supported.** A markdown list in the body panics the build; the memorandum has none.
7. **Footnote placement.** Footnotes are real footnotes at the page foot; the exemplar's footnote 1 falls on page 7 in both renders.
8. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder, and the brief forbids editing `tools/`. The render and overlay were run instead, and the review below is the Gate 2 equivalent.

## Review of the rendered pages (Gate 2 rows)

Every page of `samples/OUTPUT-elliott-memo.pdf` was rendered at 60 dpi and viewed. Defects found and fixed during the review:

- Paragraph spacing collided across block boundaries (same fault as the complaint). Fixed with `below: body-leading` on every body block.
- Pitch: first pass 24 pt; changed to Word's double spacing, 27.6 pt, to match the exemplar's line count per page (10 pages, as the exemplar).
- Signature alone on page 10: the conclusion ended at the foot of page 9 and the signature block moved to page 10 without its paragraph. Fixed by keeping the last numbered paragraph and the signature block in one unbreakable block; the conclusion and signature now share page 10.

Page rows (as of the final render):

| Page | Content | Result |
|---|---|---|
| 1 | Caption with ")" column, title, heading "PROCEDURAL BACKGROUND", paragraphs 1-3 | Pass: caption rows align with the ")" marks; title centered |
| 2 | Paragraphs 3-7; heading "DISCOVERY DISPUTE" | Pass: heading kept with paragraph 6 |
| 3 | Paragraphs 8-10; the first quotation (paragraph 9) indented, single spaced; the continuation after it flush left | Pass |
| 4 | Paragraphs 10-11 | Pass |
| 5 | Paragraphs 12-14; the two quotations of paragraph 12 (Objection, Answer) | Pass: two quotations as separate indented blocks |
| 6 | Paragraphs 15-18 (start) | Pass |
| 7 | Quotation of paragraph 18 with footnote 1 reference; continuation; paragraph 19; heading "LAW AND ARGUMENT"; paragraph 20; footnote 1 at page foot | Pass: footnote at foot of page, real footnote |
| 8 | Paragraphs 21-24 | Pass |
| 9 | Paragraphs 25-26 | Pass: page ends after paragraph 26 with space left; the conclusion moves with its signature |
| 10 | Heading "CONCLUSION", paragraph 27, "Dated" and the signature block | Pass: conclusion and signature together |

Open tier-2 items for David: the title placement (below the caption, not in the right column); the single exemplar; the EB Garamond substitution; whether the filer's own typographic quirks should be kept in any future sample (they are kept here as transcribed).

## Engines

### docx (pandoc, `docx/`)

Built with pandoc from `docx/reference.docx` and the Lua filter `docx/ndb-court-form.lua`, which lays out the cover, numbering, signature and certificate from the same frontmatter as the typst template. `docx/make-reference.sh` regenerates `reference.docx`. Render: `sh tools/render.sh --engine docx <this folder> samples/INPUT-<id>.md` (writes `samples/OUTPUT-<id>.docx`).

What matches the typst form (same values, set as Word styles):

- EB Garamond 12 pt throughout (style `rFonts`); letter page, 1-inch margins; centered page number in the footer.
- Body paragraphs double-spaced at exact 27.6 pt; caption, counsel block, quotations and signature single-spaced at exact 13.8 pt.
- Caption as a borderless table: party column 3.4 in, ")" column 0.3 in, case block at right, vertically centered.
- Numbered paragraphs (text numbers, 0.5 in first-line indent); "~" continuations and WHEREFORE paragraphs unnumbered; quotations indented 0.5 in both sides.
- Real footnotes (pandoc); headings centered and bold; signature block as a two-column table; the last numbered paragraph keeps with it.

What differs or is not checked:

- The number-to-text gap is a tab to the next default tab stop (1.0 in), not the typst 0.25 in gap.
- Caption and signature lines are plain text (typst reads them as markdown inline).
- Pagination is not compared with the typst render: no LibreOffice PDF exists yet (see below), so the page breaks in Word are unverified.
- The font must be installed on the machine that opens the file; Word substitutes silently otherwise.

docx BLOCKED items (`docs/DOCX.md`):

- BLOCKED: Gates 0 to 3 on `samples/OUTPUT-<id>.docx.pdf` (`tools/check.sh --engine docx`): `soffice` cannot be run here. LibreOffice is not on conda-forge; the Debian trixie LibreOffice 25.2.3 packages were unpacked without root, but `soffice.bin` aborts at startup with an uncaught `com::sun::star::uno::RuntimeException`. Consequently no `.docx.pdf` was made, no page was rendered or viewed, and `pages_reviewed=0`. The `.docx` is valid (zip test and well-formed XML parts pass) and pandoc reads its text back in order, but nothing visual is claimed for it.
- BLOCKED: the "opens in Word and LibreOffice without a repair prompt" check: not done (no Word here; LibreOffice unavailable).

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md)
