# hid: complaint

Doc type: **complaint** in the United States District Court for the District of Hawaii (`hid`).
Folder: `courts/ninth-circuit/hawaii/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-sffa-1-25-cv-00450-complaint.pdf` (1 filer, Students for Fair Admissions; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-sffa-complaint.md`: paragraphs 1 to 24, the prayer for relief and the signature block of the 56-page filing (not the whole filing) |
| typeface | No face named for complaints (LR 10.2(a)(2) covers memoranda only) → **EB Garamond** (kept; `docs/FONTS.md`: no face named). Embedded per `pdffonts`: EBGaramond Regular, Italic, Bold. |
| render | ok: `samples/OUTPUT-sffa-complaint.pdf`, 9 pages (unchanged by this pass), typst 0.15.0, vendored fonts only, no typst warnings |
| overlay | **fail**: needs `exemplars/FILED-EXAMPLE-*.pdf`, not in this snapshot. `samples/OVERLAY-sffa-complaint.*` is stale and must be regenerated once the exemplar PDF is restored. |
| pages reviewed | 9 of 9 (every page rendered at 50 dpi and viewed after the last template change) |

File names follow the tools' convention, not the brief's `<id>.md` shorthand: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads it and writes `OVERLAY-<id>.pdf` / `.txt`, so the sample is `INPUT-<id>.md`.

## Governing rules

Primary sources. The rules are verified against the text as posted by the court; the court's posted copy is the 2019 amended Local Rules.

| Rule | Requirement | Where it is in the template | Kind |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, read 2026-10-14) | Caption with the court's name, the title of the action, the file number, and a Rule 7(a) designation (the document title). | `caption()`: court title, parties box, "Civil No." and title. | M |
| Fed. R. Civ. P. 10(b) (same) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered()`: every body paragraph is numbered 1, 2, ... by the template; headings and the prayer are not. | M |
| Fed. R. Civ. P. 8(a) (https://www.law.cornell.edu/rules/frcp/rule_8, read 2026-10-14) | Content (short and plain statement), not form. | Not a layout rule; the sample's content is the author's. | — |
| D. Haw. LR 10.1 and 10.2(a)(1) (court's posted Local Rules, https://www.hid.uscourts.gov/files/order532/2019_08_26_administrative_Order%20Amending%20the%20Local%20Rules%20eff%202019_09_01(1).pdf, read 2026-10-14; effective 2019-09-01 as posted) | White opaque 8½ × 11 paper, one-inch margins, flat, unbound, legible, one side of each sheet. | `page-margin = 1in`, US-letter, one-sided PDF. | M |
| LR 10.2(a)(4) (same) | All documents double-spaced, except the identification of counsel, the title of the case, footnotes, quotations and exhibits. | `body-leading = 1.0em`: baseline pitch 2.3 em, which is 32.2 pt at 14 pt (exemplar: 32.3 pt). `counsel-column` and the caption are single-spaced. | M |
| LR 10.2(a)(2) (same) | "All memoranda, including footnotes, shall utilize 14-point Times New Roman plain style." | Not applicable to a complaint (it is not a memorandum). The complaint's size is therefore open; see Known gaps 1 and 2. | M for memoranda only |
| LR 10.2(b) (same) | Name, Hawaii bar number, address, telephone and email of counsel, and the party each counsel represents, upper left of the first page. | `caption()`: `counsel.columns`, `counsel_for` lines, single-spaced, on page 1. | M |
| LR 10.2(c)(1)–(4) (same) | After the counsel block: title of the court; title of the action; case number followed by the judge's initials; title of the document. | `court-title`, `parties`, `case_number` plus `judge_initials` (when given), `title`. | M |
| LR 3.1 (same) | Civil complaints are filed electronically through CM/ECF; a civil cover sheet (JS 44) is filed with the complaint. | The JS 44 is a separate form and is not produced (see Known gaps 4). | M, separate filing |
| LR 10.3, 10.5 | Chambers copies, stipulations | Not applicable. | — |

Convention (tier 2; from the exemplar, not a rule): page number centered in the footer ("- n -"); no pleading line numbers and no rules (the D. Haw. rules do not require them, and the exemplar has none); headings: a centered bold capitals heading for each part (PARTIES, JURISDICTION & VENUE, BACKGROUND), a bold roman-numeral heading for each factual section; "WHEREFORE" paragraph unnumbered; prayer items lettered "a.", "b.", ...; signature block dated at left, signature at right.

## Layout

- Page 1: counsel block in three columns, single-spaced, 11-pt (`counsel-size`); "Counsel for ..." line; court title; caption box (parties at left, a rule at the right and bottom; case number and document title at right). The caption is kept whole (unbreakable), and in the sample it fills page 1; the body starts on page 2.
- Body: 14-pt type, double-spaced (`body-leading`), first-line indent 0.5 in on every paragraph including the first after a heading (`all: true`, because typst otherwise skips the first paragraph after a heading).
- Headings: level 1 (`#`) centered bold capitals; level 2 (`##`) bold, roman numeral (I., II., ...), single-spaced, kept with the next paragraph.
- Prayer: `> ` marks the unnumbered WHEREFORE paragraph; `- ` items are lettered a., b., ...
- Signature: dated line at left; "Respectfully submitted," and the signature blocks at the right; kept together.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks:
  - `# Heading`: centered bold capitals, not numbered.
  - `## Heading`: bold, roman numeral (numbered by the template).
  - `> text`: an unnumbered paragraph (the WHEREFORE clause).
  - `- item` lines: lettered list (prayer for relief); consecutive `- ` lines form one list, and a non-`- ` line continues the previous item.
  - any other chunk: a numbered allegation (the template numbers it; do not type numbers).
- Frontmatter: `case_number` (e.g. `"1:25-cv-00450"`); `judge_initials` (optional, appended as `-XX`); `counsel.columns` (a list of columns, each a list of lines; `""` is a blank line; 1 to 3 columns); `counsel_for`; `parties` (list of `{names: [...], designation: "..."}`; "v." is inserted between parties); `title` (document title, printed in the caption); `date` (printed as the dated line); `signature.blocks` (list of `{lines: [...]}`).
- Inline markdown (italics for case names, `*pro hac vice forthcoming*`) works in every line.
- Not supported: tables, footnotes, links that matter for layout (links print their text), raw typst.

## Known gaps and open choices

1. **Font: EB Garamond, by choice.** LR 10.2(a)(2) names 14-pt Times New Roman for memoranda only, so a complaint has no court-named face and keeps EB Garamond (`docs/FONTS.md`). The exemplar is set in Times New Roman, so this is a tier-2 difference from the filed look; the motion brief uses Liberation Serif (`../motion-brief/README.md`). If the court's practice is read to cover all documents, switch `font-family` to `Liberation Serif` and re-check the page count and body pitch as in the motion brief.
2. **Type size.** The complaint's body is 14 pt. The rule fixes 14 pt for memoranda only; the exemplar is 14-pt Times (measured from the exemplar: glyph box 15.5 pt, Times' 1.107-em box, so 14.0 pt; baseline pitch 32.3 pt). EB Garamond at 14 pt has a smaller x-height than Times at 14 pt, so the text looks smaller than the exemplar.
3. **Judge initials.** LR 10.2(c)(3) requires the judge's initials after the case number. The exemplar's case number has none (`Civil Action No. 1:25-cv-450`), so the sample has none. The template prints them when `judge_initials` is given. A real filing must carry them.
4. **JS 44 civil cover sheet, Certification of Interested Entities, summons.** Separate filings (LR 3.1 for the cover sheet). Not produced.
5. **Counsel block size and layout.** Counsel is 11 pt in three columns so that the caption begins on page 1 (as the exemplar's does). The exemplar uses two columns at a larger size. This is a layout choice (tier 2), not a rule.
6. **Only one exemplar.** The brief asks for one exemplar per doc type. EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; that is not met here.
7. **Sample is partial.** The sample is paragraphs 1 to 24 and the prayer and signature of the 56-page filing; the paragraph numbers match the filing. The overlay pairs pages 1 to 7 with the filing's pages 1 to 7 (word overlap 73 to 95%); the prayer pages pair with the filing's pages 55 and 1 because the sample omits the rest of the body. The overlay is a diagnostic, not a score.
8. **Italics.** The exemplar's italics are transcribed from its text layer and the visible italic words (case names, *Id.*, *Doe I*). The overlay compares words, not styles.

## Searches for the exemplar (for the record)

- CourtListener RECAP search (`type=rd` and `type=r`, `court=hid`, 2026 complaints): many D. Haw. complaints are docketed, but almost none has a downloadable RECAP PDF; the anonymous API allows 5 requests per minute and the documents endpoint needs an account.
- Clearinghouse (`clearinghouse.net/doc/165257`, the SFFA complaint): HTTP 403 to this box; the PR-newswire copy was used.
- Justia dockets and cases (`cases.justia.com`, `dockets.justia.com`): HTTP 403 to this box.
- stateimpactcenter.org and inversecondemnation.com PDFs: HTTP 403.
- The DOJ complaint in *United States v. State of Hawaii*, 1:25-cv-00179 (Clearinghouse doc 159777): not reached (403).

## Engines

### docx (`docx/`)

- Built by `docx/make-reference.sh` (writes `docx/reference.docx`) and `docx/hid.lua` (pandoc filter). `sh tools/render.sh --engine docx <this folder> samples/INPUT-sffa-complaint.md` writes `samples/OUTPUT-sffa-complaint.docx`.
- Set in styles.xml, sectPr and footer1.xml (not rendered here): EB Garamond 14 pt throughout; body at exact 32.2 pt line pitch with 0.5 in first-line indent; headings bold, single-spaced (level 1 capitals, left; level 2 hanging "I."); counsel block 11 pt single-spaced; US Letter with 1 in margins; centered "- n -" footer (PAGE field).
- Written by the filter: counsel block and caption box as tables (rule at the right and bottom of the parties box); allegations numbered 1, 2, ... and roman headings; prayer lettered a., b., ...; WHEREFORE paragraph unnumbered; dated line and signature blocks at the right.
- Differs from typst: table cell and border metrics are Word's; no judge initials in the sample; no typst-side tracking, kerning or hyphenation controls. Line breaks and page breaks may differ in Word.
- Font: EB Garamond must be installed on the machine that opens the file, or Word substitutes silently.
- Not rendered: nothing in the `.docx` was looked at. `pages_reviewed` for docx = 0.
- BLOCKED (docx.pdf gates 0 to 3): `soffice` is not installed on the build box (no LibreOffice package on conda-forge), so no `OUTPUT-sffa-complaint.docx.pdf` exists.
- No TOC or TOA in the complaint (LR 7.4(f) does not apply), so no field-result BLOCKED item.
