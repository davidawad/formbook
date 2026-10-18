# gamd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Georgia (`gamd`), Macon, Athens, Columbus, Albany and Valdosta divisions (the template is division-neutral; the division comes from the sample).
Folder: `courts/eleventh-circuit/georgia/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-gamd-complaint-solen521cv00196.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-gamd-complaint-solen.md` (a portion of the 21-page filing, see Known gaps) |
| render | ok: `usage/OUTPUT-gamd-complaint-solen.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-solen-complaint.pdf` and `OVERLAY-solen-complaint.txt` |
| typeface | face required: **none** (M.D. Ga. Local Rules name no typeface); font: **EB Garamond** (vendored, kept per `docs/FONTS.md`, "No face named"); not a substitution, so no metric question arises |
| pages reviewed | 10 of 10 (re-rendered 2026-10-14 with no template change; every page rendered at 60 dpi and viewed) |

## Governing rules

Each rule was read from its source on 2026-10-14. Sources and the text relied on:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 8(a)(1)-(3) | Short and plain statement of the grounds for jurisdiction, of the claim, and a demand for the relief sought. Text from https://www.law.cornell.edu/rules/frcp/rule_8 (current text amended 2010, eff. 2010-12-01), fetched 2026-10-14. | Author content (the sample's jurisdiction, claims, prayer). The template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the title names all the parties. https://www.law.cornell.edu/rules/frcp/rule_10 (as amended 2007, eff. 2007-12-01), fetched 2026-10-14. | `court`, `division`, `caption`, `case_number`, `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts. Same source. | `allegations()` numbers every paragraph (number on its own centred line, text indented 0.5 in). Headings and the prayer are not numbered. |
| Fed. R. Civ. P. 10(c) | Exhibits are part of the pleading. Same source. | Not templated (no exhibit section). |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required for a paper served through the court's e-filing system. https://www.law.cornell.edu/rules/frcp/rule_5, fetched 2026-10-14. | No certificate is generated. The exemplar has none. |
| M.D. Ga. L.R. 83.1.2(A) | Lead counsel's name, address and telephone number on the signature page of the first pleading. Local Rules, consolidated text (PDF dated 3-7-22), https://www.gamd.uscourts.gov/sites/gamd/files/Local_Rules_3-7-22.pdf, read 2026-10-14. | Signature block: "Lead Counsel:" line, with the address block under it. **The exemplar has no lead-counsel label**; the template follows the rule, so this differs from the exemplar on purpose. |
| M.D. Ga. Local Rules (typeface) | No typeface, point size or spacing rule in the consolidated text (PDF dated 3-7-22, read 2026-10-14; LR 5.1 and 7.1 are not formatting rules). Face required: **none**. | Font: **EB Garamond** (`docs/FONTS.md`, "No face named"), 14 pt. The exemplar's Times New Roman is a filer's choice, not a rule. |
| M.D. Ga. L.R. 83.1.2(B) | State Bar of Georgia number on the signature page of each pleading. Same source. | `signature.signers` (each attorney's Georgia Bar No. line). |
| M.D. Ga. L.R. 87.1-87.3 | A nongovernmental corporate party files a corporate disclosure statement with its initial pleading; a party asserting diversity files a jurisdictional statement (state of incorporation and principal place of business; LLC members' citizenship). Same source. | **Not templated.** A separate filing; flagged for any corporate plaintiff. |
| M.D. Ga. L.R. 5.4(A) | Redaction: SSN and taxpayer ID to last four digits, birth year only, minors' initials, financial account numbers to last four digits (the filer's duty). Same source. | **Not checked by the template.** Author's responsibility. |
| M.D. Ga. L.R. 5.0 | Attorneys file electronically through CM/ECF under the court's Administrative Procedures. Same source (the Administrative Procedures themselves were not read). | Not templated. |

Not produced by this template (separate filings, not in the rules read above): the civil cover sheet (JS 44), the summons, and the Rule 7.1 disclosure statement (corporate parties; the 2022 Local Rules text reviewed does not state a Rule 7.1 form).

## Layout

- Letter size, 1 inch on every side (exemplar).
- Court heading on the first page: "IN THE UNITED STATES DISTRICT COURT / FOR THE MIDDLE DISTRICT OF GEORGIA / MACON DIVISION", centred, bold.
- Caption: party names with designations ("Plaintiff," indented 1 inch, "v." between parties), a column of ")" marks, a closing rule under the parties, and at the right the file number ("Civil Action No.") and "JURY TRIAL DEMANDED" (exemplar).
- Title centred bold below the caption; the lead-in paragraph follows, indented.
- Body: double-spaced at a 32 pt baseline pitch (measured on the exemplar with `pdftohtml -xml`; the render measures 32.0 pt with `pdftotext -bbox`). Paragraph numbers are centred on a line of their own, with the text beneath (exemplar form).
- Section headings: centred bold caps (`#`), centred bold (`##`), bold italic left (`###`).
- Prayer: a line beginning "WHEREFORE" (not numbered, as the exemplar), items lettered (a), (b), ...
- Signature block: "Respectfully submitted the 15th day of June, 2021." then the firm and signers indented 3 inches (exemplar), then the lead-counsel line and address flush left, then "Attorney for ...".
- Footer: page number centred, 12 pt, on every page (page 1 too; exemplar shows "1").

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (list of lines), `division`, `caption.parties` (list of `{names, designation}`), `case_number` (the file number, may be empty), `title`, `jury_demand`, `lead_in`, `date` (the sentence after "Respectfully submitted", e.g. "the 15th day of June, 2021"), `signature` (`firm`, `signers` (list of lines per attorney), `lead_counsel`, `address`, `attorney_for`).
- Body: blank-line-separated chunks. `#` heading, `##` sub-heading, `###` bold italic; a markdown list (`1.` items) is lettered (a), (b) by the template; any other chunk is a numbered paragraph. A chunk starting with "WHEREFORE" is not numbered.
- The sample must not put the paragraph numbers in the text: the template numbers them.
- Not supported: tables, footnotes (none needed), raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/eleventh-circuit/georgia/federal/middle-district/complaint usage/INPUT-gamd-complaint-solen.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/federal/middle-district/complaint solen-complaint
```

- The render writes `usage/OUTPUT-gamd-complaint-solen.typst.pdf` (the default name in `tools/render.sh`); the overlay reads it and writes `OVERLAY-solen-complaint.pdf` and `.txt` (the tool's names; the brief's `<id>-overlay` names were not used, because the tool reads and writes these).
- Red = our render, blue = exemplar, black = both. The page map pairs pages by word overlap: ours 1-10 pair with filed 1-4, 6-9, 20 and 21, since the sample skips pages. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 10 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court heading, caption with ")" column, "Civil Action No.", JURY TRIAL DEMANDED, title, lead-in, Nature, Jurisdiction heading and ¶ 1-2 | OK after two fixes: the caption rows overlapped (fixed by sizing each row in whole single-spaced lines), and the headings were rendering at cmarker's default size (fixed to 14 pt). |
| 2 | ¶ 3-6, Parties, Administrative Procedures | OK. |
| 3 | ¶ 7-12, Factual Allegations | OK. |
| 4 | ¶ 13-17 | OK. |
| 5 | ¶ 18-22 | OK. |
| 6 | ¶ 23-27 | OK. |
| 7 | ¶ 28-31 | OK. |
| 8 | ¶ 32-35, Claims for Relief, Count I heading (bold, centred, one line in the render) | OK. |
| 9 | Prayer for Relief: WHEREFORE (unnumbered), items (a) to (i) | OK after the fix that stops "WHEREFORE" being numbered as ¶ 36. |
| 10 | Signature block: date sentence, firm, signers with bar numbers, Lead Counsel line, address, "Attorney for" | OK after the fix that replaced a forced line break with a stacked line. |

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers from different sources. Other M.D. Ga. complaints with stored RECAP PDFs were found (Nulph v. Houston Healthcare System, 5:21-cv-00423, 26 pages, Times New Roman, counsel filing; Mack v. Old Dominion Freight Lines, 5:21-cv-00118, 9 pages) but not saved, because the brief asks for one exemplar per doc type. **Tier 2 is therefore not judged against two filers.**
2. **Font.** The court names no face, so the template keeps **EB Garamond at 14 pt** (`docs/FONTS.md`, "No face named"). The exemplar is 14-pt Times New Roman; that is the filer's choice, not a rule. EB Garamond has a smaller x-height, so the text looks smaller than the exemplar. Liberation Serif (Times New Roman's metric-compatible substitute) is vendored; David may choose it for the tier-2 look, which is a template change not made here.
3. **M.D. Ga. typeface and margin rule.** None found in the consolidated Local Rules text (PDF dated 3-7-22, fetched and text-extracted 2026-10-14; it contains no typeface, font-size, margin or spacing requirement). The layout therefore follows the exemplar, as the brief says. An amending order (3.8.22) exists and the current text was not confirmed. A later rule would override this layout.
4. **Judge's standing orders** (Judge Self in the exemplar; any judge may impose form rules) were not checked.
5. **Sample is a portion of the filing.** The sample carries ¶ 1-35, the prayer and the signature. Counts II and III (filed ¶ 36-86) are not transcribed, and the sample's paragraph numbers run from 1 (the template numbers them). The filed cross-reference "paragraphs 9-33" is kept as filed, so it does not match the sample's numbering.
6. **Filed spelling is kept** ("impaiment", "Hopebridge, LLC's") so the sample matches the filing; the template does not correct it.
7. **Caption label.** The exemplar's caption reads "Civil Action No." with the number blank on the file copy. The sample's `case_number` is empty, so that line reads "Civil Action No." alone.
8. **Headings and prayer.** Headings are typed by the author; the template does not number them. The prayer's items are a markdown list, lettered by the template.
9. **Ragged right.** Body text is left-aligned; the exemplar's justification is not visible in the text layer and is not asserted.
10. **Not run:** `tools/check.sh` and `tools/check-selftest.sh` were not run. They expect a court-level folder with `court.json` and `rules.md`; this doc-type folder is in the one-folder-per-doc-type layout the brief sets, and the brief forbids editing `tools/`.
11. **Lead counsel line** is a rule-driven addition the exemplar does not have (see the rules table).
12. **Outside the template:** the corporate disclosure (L.R. 87), the civil cover sheet, the summons, and the redaction check (L.R. 5.4) are the filer's separate steps.
13. **Exemplar PDF not in the folder.** Only `usage/SOURCE.md` is committed. The 2026-10-14 overlay was run with the PDF fetched from the URL in SOURCE.md (21 pages, "Filed 06/15/21" header checked) and passed as the third argument of `tools/overlay.sh`, not saved in the repo.

## Engines

`typst/` is the reference. The docx engine is `docx/` (`reference.docx` for the styles, page setup and footers; `gamd-complaint.lua` for the cover, caption, allegations, prayer and signature block). Render: `sh tools/render.sh --engine docx courts/eleventh-circuit/georgia/federal/middle-district/complaint usage/INPUT-gamd-complaint-solen.md` writes `usage/OUTPUT-gamd-complaint-solen.docx` and `usage/OUTPUT-gamd-complaint-solen.docx.pdf` (LibreOffice 26.8 converts; EB Garamond from `fonts/` must be installed for LibreOffice, see `docs/FONTS.md`).

| Layout | docx | Note |
|---|---|---|
| Face and size | EB Garamond 14 pt, as typst | Named in the styles; Word substitutes silently if the face is not installed. |
| Line pitch | Exact 32 pt on body, numbers, prayer and signature lead | Same pitch as typst on every page. |
| Margins, paper | Letter, 1 in on every side | |
| Numbered allegations | Number on its own centred line, text with a 0.5 in first-line indent | Number is a Word `SEQ` field, so Word renumbers when a paragraph is added. |
| Prayer | (a) to (i), hanging indent (marker at 0.5 in, text at 0.9 in) | Letter is a `SEQ` field. |
| Headings | Level 1 centred bold caps (All Caps formatting, text kept as typed), level 2 centred bold, level 3 bold italic | |
| Caption | Party column with a right rule; "Civil Action No." and "JURY TRIAL DEMANDED" at right | Typst draws one ")" per caption line. A ")" column needs each wrapped line counted, which a Word table cannot report, so docx draws the rule in the same place instead. |
| Signature block | "Respectfully submitted the ..." at left, firm and signers at 3 in, lead counsel and address flush left | Matches typst on page 10. |
| Page number | Centred 12 pt on every page, page 1 included | `PAGE` field. |

- **Pages reviewed:** all 10 pages of `OUTPUT-gamd-complaint-solen.docx.pdf` were rendered at 60 dpi and compared with the typst output page by page (side-by-side). Page breaks fall where the typst output's do on all 10 pages.
- **Checks:** `tools/check.sh --engine docx` was not run; the folder is a doc-type folder without `court.json` (see gap 10). The docx is not BLOCKED on any tier-1 point in this list. Not verified: opening the `.docx` in Microsoft Word (no Word here). LibreOffice converts it without error; no GUI repair prompt was checked.
- **Pagination:** Word may still break lines differently (`docs/DOCX.md`).
