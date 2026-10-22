# alsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Alabama (`alsd`).
Folder: `courts/eleventh-circuit/alabama/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the complaint's caption, body, four counts, prayer, jury waiver and signature; the service list on the exemplar's last page is not transcribed) |
| typeface | face required: none (S.D. Ala. Gen. L.R. 5(a)(2) asks for "a plain, Roman style (or similar) font"; no face is named). Substitute: **Times New Roman**, the house standard (`docs/FONTS.md` rule 6; EB Garamond until fb-595.68). Fit: n/a. See Known gaps 1. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 11 pages, typst 0.15.0, pinned Times New Roman only, no warnings; `pdffonts` shows `TimesNewRomanPSMT`, `-BoldMT`, `-ItalicMT` embedded (no other face; EB Garamond on the 2026-10-14 re-render, before fb-595.68) |
| overlay | ok: `usage/OVERLAY-frankenmuth-complaint.pdf` and `OVERLAY-frankenmuth-complaint.txt` (`tools/overlay.sh`), re-run 2026-10-14 against the RECAP copy of the exemplar (the exemplar PDF is not stored in the folder; see `usage/SOURCE.md`) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed on 2026-10-14, after the typeface check; the earlier EB Garamond render, before fb-595.68) |

File names follow the repo's tools, not the brief's shorthand: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf` (`tools/render.sh` writes it), the overlay `OVERLAY-<id>.pdf` and `.txt` (`tools/overlay.sh` writes them). `<id>` is `frankenmuth-complaint`.

## Governing rules

Primary source: S.D. Ala. Local Rules (Order Promulgating Local Rules, "Effective August 1, 2015"), PDF at https://www.alsd.uscourts.gov/sites/alsd/files/local-rules.pdf, fetched 2026-10-14. The PDF is the version the court posts; this pass did not check for later amendments. The rules are also listed (not authoritatively) at courtrules.net.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Ala. Gen. L.R. 5(a)(1) | 8½ × 11 paper; text double-spaced (quotations of more than two lines may be single-spaced); headings and footnotes may be single-spaced; margins of at least 1 inch on all four sides; page numbers only in the margins. | `margin = 1in`, `pitch-double` (24 pt, double), `pitch-single` (13.8 pt) for block quotes and the signature, footer page number in the bottom margin. |
| S.D. Ala. Gen. L.R. 5(a)(2) | "A plain, Roman style (or similar) font", italics or boldface for emphasis; case names italic or underlined; 12 point or larger, footnotes included. Names no typeface. | `font-family` = Times New Roman (the house standard, `docs/FONTS.md` rule 6: the rule allows any plain roman face, so no court-named face applies), `type-size = 12pt` (footer too); case names italic from `*...*` in the sample. See Known gaps 1. |
| S.D. Ala. Gen. L.R. 5(a)(3) | Signature line, with the typed name, address and telephone of every attorney of record directly beneath. | `signature-block()`: one block per attorney from `signature.blocks`. |
| S.D. Ala. Civ. L.R. 10(a) | Claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each prose paragraph is numbered 1, 2, ...; headings, lists, block quotes and bracketed record cites are not. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. Fetched https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | `court-title()`, `caption()` (civil action number on the middle line), `brief_title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. Same fetch. | As Civ. L.R. 10(a). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Civil L.R. 7.1 disclosure statement (the form is in the rules' appendix; it is required with the first filing); the summons; the Rule 4 service list on the exemplar's last page. Any of these may be required with the first filing.

## Layout

- Court title on the first page, centered and bold (three lines, single-spaced).
- Caption: the party names in a left column, a column of ")" marks, and "Civil Action No. <case number>" on the middle line.
- Title of the paper centered and bold under the caption; "JURY TRIAL DEMANDED" only when `jury_demand: true`.
- Body double-spaced at 24 pt pitch (`pitch-double`). Numbered paragraphs have a 0.5 inch first-line indent and the number on that line.
- Headings: level 1 centered bold caps; level 2 centered bold (count headings); level 3 bold italic at the left. Headings stay with the paragraph after them.
- Lists: lettered (a), (b), ...; block quotes single-spaced and indented 0.5 inch on both sides.
- Signature: "Dated:" on the left, "Respectfully submitted," and each attorney's block in the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number` (the caption number, e.g. "1:26-cv-228"), `division` (the division line, e.g. "SOUTHERN DIVISION"), `caption.parties` (list of `{names: [lines], designation}`; "v." is inserted between parties), `brief_title`, `jury_demand` (optional), `lead_in` (optional, an unnumbered introductory paragraph), `date`, `signature.blocks` (list of attorney blocks, each a list of lines).
- Body: blank-line-separated chunks. A `#` heading is level 1 (centered caps), `##` level 2 (centered bold), `###` level 3 (bold italic). A chunk starting with `1.`, `2.` or `-` is a lettered list. A chunk starting with `>` is an unnumbered block quote. A chunk starting with `[` or `WHEREFORE` is unnumbered (a record cite or a prayer lead-in). Any other chunk is a numbered paragraph.
- The sample must not contain paragraph numbers in the text: the template numbers the allegations.
- Not supported: tables, footnotes (none used in the sample), raw typst.

## Overlay (red/blue)

`usage/OVERLAY-frankenmuth-complaint.pdf` (measured on the earlier EB Garamond render, before fb-595.68) pairs our pages with the filed pages by shared words (`tools/overlay.sh` pairing, not an index match). The pairing in `OVERLAY-frankenmuth-complaint.txt` is:

```
ours p.1  filed p.1   ours p.2  filed p.2   ours p.3  filed p.4   ours p.4  filed p.5
ours p.5  filed p.6   ours p.6  filed p.8   ours p.7  filed p.10  ours p.8  filed p.11
ours p.9  filed p.12  ours p.10 filed p.13  ours p.11 filed p.14
```

The word-overlap figures are 50 to 79 percent. The low figures come from different line breaks and from the sample's shorter text and paragraph-number changes, not from different wording. The overlay is a diagnostic, not a score. It shows the two documents are on the same page grid, which is the thing being compared.

## Review of the rendered pages (every page, last render; the earlier EB Garamond render, before fb-595.68)

- Page 1: court title lines 1 to 3, caption with ")" column, "Civil Action No. 1:26-cv-228" on the middle line, title centered, paragraphs 1 to 4 double-spaced. Pass.
- Page 2: paragraphs 5 to 13, GENERAL ALLEGATIONS and THE INDEMNITY AGREEMENT headings single-spaced with a blank line above and below, quote "(3) Indemnification..." single-spaced. Pass.
- Page 3: quoted Loss definition single-spaced and indented, "(5) Collateral Security" quote, paragraphs 16 to 18. Pass.
- Page 4: THE PROJECT AND BONDS heading starts the page, paragraphs 19 to 25. Pass.
- Page 5: paragraphs 26 to 32; the page ends short because COUNT I stays with its first paragraph on the next page. Pass.
- Page 6: COUNT I and CONTRACTUAL INDEMNITY headings, paragraphs 33 to 40, the lettered list (a) to (c) with a blank line after it, WHEREFORE paragraph (unnumbered, flush left). Pass.
- Page 7: COUNT II and COUNT III headings, paragraphs 41 to 51. Pass.
- Page 8: paragraphs 52 to 59. Pass.
- Page 9: paragraphs 60 to 67 with COUNT IV, the statute quote (in text), two *Amerada Hess* quotes with italic case name. Pass.
- Page 10: paragraphs 68, WHEREFORE with lettered prayer (a) to (d), WAIVER OF JURY TRIAL heading, paragraph 69. Pass.
- Page 11: signature block only: "Dated:", "Respectfully submitted," both attorney blocks. Open (see gap 3).

## Known gaps and open choices

1. **Font.** The rule requires "a plain, Roman style (or similar) font" and names no typeface, so the court-named-face rule (`docs/FONTS.md`) does not apply and the template (`typst/alsd-complaint.typ` and the docx) uses the house standard, Times New Roman (`docs/FONTS.md` rule 6), the filed exemplar's face too. Until fb-595.68 it kept EB Garamond, whose smaller x-height made the text look slightly smaller than the exemplar.
2. **One exemplar.** The brief asks for one filed exemplar per doc type. A second complaint from a different filer (see `usage/SOURCE.md`) would be needed to judge tier 2 against 2 or 3 filers.
3. **Signature page.** The signature block lands alone on page 11 because the transcription ends on a full page. The filed exemplar does not do this: its page 14 carries the jury waiver paragraph above the signature block. The template keeps the signature block unbreakable and does not pull body text onto its page. A clerk may still want at least a few lines of text on the signature page; this is a tier-2 open item, recorded as OPEN.
4. **Caption layout.** The exemplar uses no ")" column; the template uses one (a common S.D. Ala. form, and the one in the Chapa complaint). The column is a convention choice, recorded as ACCEPTED.
5. **Quoted clause numbers.** The exemplar quotes its Indemnity Agreement as "3. Indemnification..." and "5. Collateral Security...". The sample writes "(3)" and "(5)" so the markdown does not turn the quote into a list. The quoted words are unchanged. Recorded as ACCEPTED.
6. **WHEREFORE lead-ins** are flush left, as in the exemplar's text layer; the exemplar's indentation could not be read from the text layer, so this is not asserted as a rule.
7. **Paragraph numbers.** The template numbers the allegations from 1. The filed numbering is the same (1 to 69) because the sample transcribes every paragraph; the service list on the exemplar's last page is not transcribed.
8. **Footnotes.** None in the sample (the filed complaint has none).
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
10. **Local rules version.** The rules PDF is dated "Effective August 1, 2015". Later amendments, and any judge's standing order, were not checked.

## Engines

The typst template is the reference. The docx engine is `docx/reference.xml` (from which `fb render --engine docx` builds the reference document: the cross-engine recipe, `base="xengine"`, in the typst template's face; `docx/make-reference.sh` is retired) with the Lua filter `docx/alsd-complaint.lua`; it renders with `sh tools/render.sh --engine docx <this folder> usage/INPUT-complaint.md`, which writes `usage/OUTPUT-complaint.docx` and `usage/OUTPUT-complaint.docx.pdf` (LibreOffice converts the file; 11 pages, the same count as the typst render). Times New Roman must be installed for LibreOffice (the pinned install, `docs/FONTS.md` rule 1); `pdffonts` shows only Times New Roman faces. The table below was written before fb-595.68; its paper, font and spacing rows are current.

| Element | Typst | DOCX |
|---|---|---|
| Paper, margins, font, size | Letter, 1 in, Times New Roman 12 pt | same (in `reference.xml`) |
| Body spacing | 24 pt pitch | exact 24 pt |
| Caption and cover | a grid with a ")" column; "Civil Action No." on the middle row | a borderless table with the same rows and columns |
| Numbered allegations | number at 0.5 in, text after a 0.2 in gap | number at 0.5 in, tab to 1 in |
| Headings | 1.4 em (level 1), 1.2 em (level 2), 1 em bold italic (level 3) | 17 pt, 14.5 pt, 12 pt bold italic (the same sizes, rounded to half points) |
| Lettered lists, block quotes, signature block | (a) at 0.5 in, text at 0.9 in; single-spaced quotes indented 0.5 in both sides; signature at 3.0 in | the same measures |
| Page numbers | centered, bottom margin | centered, bottom margin (a PAGE field) |

What differs (on the earlier EB Garamond renders, before fb-595.68):

- Line breaks: a few lines break a word earlier or later than the typst render (page 5 and others), so text is not in the same place on every line. Each page is the same grid.
- The first line of text on page 1 sits about 3 pt lower in the DOCX.
- The numbers of the allegations are followed by a tab, so the text of a numbered paragraph starts about 0.15 in further right than in the typst render.
- The signature block is alone on the last page in both engines (open item 3 above).

DOCX BLOCKED items: none. This folder has no `checks.yaml`, so `tools/check.sh --engine docx` does not run here; the docx PDF was reviewed page by page instead (before fb-595.68) (every page of `OUTPUT-complaint.docx.pdf`, against the typst render). The `.docx` was converted by LibreOffice without error but was not opened in Microsoft Word, so the Word repair check is not done.
