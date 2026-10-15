# D. Mont. (mtd): complaint

Doc type: **complaint** (complaint and demand for jury trial, an originating pleading). Court: United States District Court for the District of Montana. Folder: `courts/ninth-circuit/montana/federal/district/complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 9 of 9 (every page rendered at 60 dpi and looked at). Nothing here sets `status` in any `court.json`.

## Governing rules

Sources: the District of Montana's Local Rules of Procedure, two versions, both fetched from the court's website on 2026-10-14:

- Effective **December 1, 2026** (the version that takes effect after this review): https://www.mtd.uscourts.gov/sites/mtd/files/LocalRules_12012026.pdf
- Effective **December 1, 2025** (the version in force on the review date): https://www.mtd.uscourts.gov/sites/mtd/files/LocalRules_12012025.pdf

The rules quoted below read the same in both versions (L.R. 1.5(a)(2) says "14-point font" in 2026 and "14-point font size" in 2025; L.R. 3.1 and 38.1 are unchanged). Local rules index: https://www.mtd.uscourts.gov/local-rules.

Federal Rules: Fed. R. Civ. P. 8(a), 10(a)-(b), 11(a), read from the Cornell LII text on 2026-10-14 (https://www.law.cornell.edu/rules/frcp/rule_8, `.../rule_10`, `.../rule_11`). LII mirrors the official text; the official text is at https://www.uscourts.gov/rules-policies/current-rules-practice-procedure.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MT-FORM-001 | D. Mont. L.R. 1.5(a)(1) | 8½ × 11 inch, printed on one side, one-inch top, bottom and side margins, no shading. | `page` margins in `typst/mtd-complaint.typ` |
| MT-FORM-002 | L.R. 1.5(a)(2) | Typewritten in **14-point** font, double-spaced except quoted material and footnotes. | `type-size = 14pt`; `line-pitch = 32pt`; footnotes at 14 pt |
| MT-FORM-003 | L.R. 1.5(a)(2) | Double-spacing: 32 pt baseline pitch at 14 pt (measured, see Sample). | `line-pitch`, `body-leading`, `gap` |
| MT-FORM-004 | L.R. 1.5(a)(3) | Consecutively numbered at the bottom of each page. The cover is page 1. | `footer` of the page |
| MT-FONT-001 | L.R. 1.5(a)(2) (2025 text read 2026-10-15: "typewritten in 14-point font size") | **No typeface is named.** Face required: none. Font: EB Garamond (vendored, OFL), kept; no court-named substitute applies. Metric-compatibility: n/a. | `font-family` in `typst/mtd-complaint.typ` |
| MT-CAP-001 | L.R. 1.5(a)(4) and Appendix C, Form A | Counsel block at upper left; court title "IN THE UNITED STATES DISTRICT COURT / FOR THE DISTRICT OF MONTANA / [division]"; caption with the party names, "Plaintiffs," "v.", "Defendant."; case number and document title on the right. | `counsel-block`, `court-title`, `caption-table` |
| MT-DIV-001 | L.R. 1.2 (divisions) | The division name is printed under the court title (here MISSOULA DIVISION, from the frontmatter). | `court-title` |
| MT-JURY-001 | L.R. 38.1 | A pleading that carries a jury demand must say so in its title. The template fails the build if `jury_demand: true` and the title does not contain "JURY TRIAL". | `mtd-complaint` assertion |
| MT-SIG-001 | L.R. 1.5(b), 11.1 | Printed name under the signature line; the signer's `/s/` signature. | `signature-block` |
| MT-FILE-001 | L.R. 3.1(a) | A complaint is filed with the filing fee (or an IFP motion) and a civil cover sheet. Those are separate filings: **not generated**. | none |
| FRCP-8 | Fed. R. Civ. P. 8(a) | Short and plain statement of jurisdiction, claim and demand for relief. Content is author-written; the template does not check it. | author (`samples/`) |
| FRCP-10a | Fed. R. Civ. P. 10(a) | The title of the complaint must name all the parties. Checked: the caption must list parties on at least two sides. | `mtd-complaint` assertion |
| FRCP-10b | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. The template numbers every body paragraph automatically; the author types no numbers. | `paragraphs()` |

Not used: L.R. 7.1 (motions and briefs) applies to motions, not to the complaint. Pleading-paper line numbers are not required by the D. Mont. rules (the CAND complaint template has them; this one deliberately does not).

## Exemplar

- `exemplars/FILED-EXAMPLE-fsc-knudsen-9-24-cv-00067-complaint.pdf`: Complaint and Demand for Jury Trial, *Free Speech Coalition, Inc. v. Knudsen*, No. 9:24-cv-00067-DWM (D. Mont., Missoula Division). 48 pages, filed by the plaintiffs' counsel May 14, 2024 (ECF 1). Text layer present (`pdffonts` shows embedded Times New Roman; `pdftotext` reads it).
- Provenance, searches and the caveats are in `exemplars/SOURCE.md`.
- Only one exemplar. The eval-loop rule for tier 2 asks for two or three from different filers. Not done (see gaps).

## Sample

- `samples/INPUT-fsc-knudsen-complaint.md` is a transcription of the exemplar: the cover (counsel, court title, caption, title), the lead-in, the introduction (¶¶ 1–9), jurisdiction and venue (¶¶ 10–11), parties (¶¶ 12–16, with headings "PARTIES" and "I. Plaintiffs"), the prayer for relief (lettered A–D), the demand for jury trial, the signature block, and footnote 1.
- It is an excerpt. Paragraphs 17–102 and Counts 1–5 (¶¶ 103–107) are not transcribed, so the sample numbering stops at ¶ 16. The sample's numbering is therefore a prefix of the filed numbering, which is what the overlay pairs.
- Caption typo: the filing reads "Stat of Montana"; the sample reads "State of Montana". Everything else is transcribed as filed.
- The sample renders to 9 pages (the target is 8–14 when the exemplar is that long; the exemplar is 48 pages).

### Markdown contract for this doc type

- Frontmatter: `case_number` (blank on an initial filing: prints "Case No. ______"), `division` (required), `counsel` (list of groups; each group is a list of lines, shown in two columns), `counsel_role` (italic line), `lead_in` (optional, unnumbered), `caption` (two sides, each with `names` and `designation`), `title` (must contain "JURY TRIAL" when `jury_demand` is true), `jury_demand`, `date`, `signature` (`firm`, `signer`, `lines`).
- Body: blank-line-separated paragraphs are numbered automatically. `#` is a centered section heading (bold capitals). `##` is a bold sub-heading (the author types the numeral: "I. Plaintiffs"). `1. ` items are a lettered list (A., B., ...), not numbered paragraphs, used for the prayer.
- A paragraph that starts with `%` is printed unnumbered (the prayer's "WHEREFORE" lead-in, the jury-demand sentence). `%` is removed from the output.
- Footnotes: `text[^1]` in a paragraph and `[^1]: text` anywhere in the file. The definition is printed at the reference; it is not a paragraph.
- Case names in italic: `*Reno v. ACLU*`. The template does not guess what a case name is.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/ninth-circuit/montana/federal/district/complaint samples/INPUT-fsc-knudsen-complaint.md
sh tools/overlay.sh courts/ninth-circuit/montana/federal/district/complaint fsc-knudsen-complaint
```

- `samples/OUTPUT-fsc-knudsen-complaint.pdf`: 9 pages. Typst compiled with no warnings (`render.sh` fails on any warning). Only the vendored font: `pdffonts` shows EBGaramond-Regular, -Italic and -Bold, all embedded.
- Line pitch (measured with `pdftotext -bbox`, page 2): 32.06 pt between body lines, the double-spacing of a 14-point line. EB Garamond's line box is 0.65 em, so `body-leading = 1.64em` gives the pitch and `gap = line-pitch - 0.65em` separates blocks.
- `samples/OVERLAY-fsc-knudsen-complaint.pdf` and `.txt` (the tools' naming: `OVERLAY-<id>` and `OUTPUT-<id>`, the same convention as the other courts; red = our render, blue = exemplar, black = both). The page map: ours p.1–7 ↔ filed p.1–7 (word overlap 67–89%); ours p.8–9 ↔ filed p.47 (the prayer and signature), since the sample's last pages are the filed prayer and signature. The overlay is a diagnostic, not a score: the exemplar's cover uses a different counsel layout (two columns) and the filed body is Times New Roman, so the text lines will not coincide.

## Visual review (Gate 2 record)

Each page was rendered at 60 dpi and looked at.

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel (two columns), court title, caption, title, case number blank | OK. Counsel on two columns fits on page 1 (the first version spilled the caption onto page 2; fixed). Page number 1 at foot. |
| 2 | Lead-in, INTRODUCTION, ¶ 1–2 | OK after fixing paragraph overlap (see below). Double-spaced. |
| 3 | ¶ 2–4 | OK. |
| 4 | ¶ 4–7, footnote 1 begins at foot | OK. Footnote reference "1" superscript. The footnote continues onto page 5. |
| 5 | ¶ 8–11, footnote 1 continues, JURISDICTION AND VENUE, PARTIES heading moved to page 6 | OK. |
| 6 | PARTIES, I. Plaintiffs, ¶ 12–13 | OK. Headings are kept with the following paragraph. |
| 7 | ¶ 14–16 | OK. Italic title of the book inside a paragraph. |
| 8 | PRAYER FOR RELIEF, lettered A–D | OK. The WHEREFORE lead-in is unnumbered; the list is lettered A–D as in the exemplar. |
| 9 | DEMAND FOR JURY TRIAL, the unnumbered demand, date, signature block | OK. The heading, demand and signature are kept together (the signature no longer stands alone). |

Defects found and fixed during review (all three were template defects, not sample defects):
1. **Paragraphs overlapped their successors** (the first render). Blocks had no gap, so the next paragraph started one natural line-height below the last line. Fixed by `below: gap` on every block.
2. **A gap was lost after a heading** (the second render). Headings were wrapped together with the paragraph after them in an unbreakable block, and typst drops a block's trailing gap inside a container. Fixed: no wrappers; headings are `sticky` blocks of their own.
3. **A footnote definition was numbered as a paragraph** (`19.` with no text), and **footnote 1 did not print** (cmarker binds a reference only to a definition in the same call). Fixed: definitions are skipped as paragraphs and passed along with each chunk that holds a reference.

Reviewed pages: 9 of 9.

## Known gaps and open choices

1. **Font.** EB Garamond (vendored, OFL) at 14 pt, not Times New Roman as in the exemplar. The rules require 14-point type and name no face (checked in the 2025 text on 2026-10-15), so the court-named-face substitution (`docs/FONTS.md`) does not apply and the default face stays. If David prefers the exemplar's look, the vendored Times substitute is Liberation Serif (`font-family` change only; line counts would need a re-check). Style choice: noted for David.
2. **Tier-2 exemplars.** One exemplar only (the complaint in *Free Speech Coalition v. Knudsen*). The eval loop asks for two or three from different filers before tier 2 is judged. Searched without success for a second public D. Mont. complaint in a text-based PDF (see `exemplars/SOURCE.md`).
3. **Partial sample.** Paragraphs 17–102 and Counts 1–5 are not transcribed (see Sample). The sample ends at the prayer and signature from the exemplar's last pages.
4. **Counsel layout.** Two columns (as the exemplar sets it), not the single column of Form A. Substantial compliance with Appendix C is the rule's standard; the two-column layout was chosen so the cover fits on page 1.
5. **Page number on the cover.** The rule says every page is numbered at the bottom (L.R. 1.5(a)(3)); the cover shows "1". The exemplar's cover shows no visible page number. The rule governs.
6. **Filing items not generated.** Civil cover sheet, filing fee or IFP motion (L.R. 3.1(a)) and the summons are separate documents.
7. **Counts and jury demand.** The sample has the jury demand; counts are not transcribed, so the count headings and the cover-title assertion are exercised only through the prayer and demand.
8. **No hearing or word-limit lines.** A complaint has no word limit (L.R. 7.1(d)(2) applies to briefs) and no noticed hearing.
9. **Division.** `division` is free text from the frontmatter. The template does not check that it is one of the five divisions of L.R. 1.2 (Billings, Butte, Great Falls, Helena, Missoula).
10. **Overlay file names.** The task brief named the overlay `<id>-overlay.pdf`; `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and reads `OUTPUT-<id>.pdf`. The tools win; the names follow them.

## Engines

**docx** (`docx/`): `reference.docx` (built by `sh docx/build-reference.sh docx/reference.docx` from `reference-styles.xml`), `mtd-complaint.lua` (cover, caption, numbered paragraphs, prayer letters, signature), `fonts.conf`.

Render: `export FONTCONFIG_FILE=$PWD/docx/fonts.conf` (the LibreOffice conversion must see the vendored EB Garamond; without it LibreOffice substitutes another serif), then `sh tools/render.sh --engine docx <this folder> samples/INPUT-fsc-knudsen-complaint.md`. Output: `samples/OUTPUT-fsc-knudsen-complaint.docx` and `.docx.pdf` (9 pages).

- Matches the typst output: EB Garamond 14 pt; exact 32 pt double spacing; 1 in margins on Letter; page number centred at the foot from the cover; two-column counsel block; court title; caption with a right and bottom rule on the party cell; numbered paragraphs with the number at 0.5 in; prayer items lettered A. to D. at 0.5 in; unnumbered `%` paragraphs; footnotes at 14 pt single-spaced; signature block. Page count: 9, as typst.
- Differs: pagination is LibreOffice's (prayer item D starts p.9; typst keeps A. to D. on p.8). Exact line spacing puts each text line about 5 to 9 pt lower than typst. Word may paginate differently.
- BLOCKED: GATE-RUN (`tools/check.sh <this folder> --engine docx`): exits 2 before any gate runs, because this folder has no `court.json` and no `checks.yaml` (the court folder has neither either). No docx gate result is recorded. The rule checks (MT-FORM-001 to MT-SIG-001) are therefore not run by the tool; the visual review is in `reviews/2026-10-15-docx.md`.
