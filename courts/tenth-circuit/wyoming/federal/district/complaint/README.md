# District of Wyoming (wyd): complaint

- Court: `wyd`, United States District Court for the District of Wyoming (`courts/tenth-circuit/wyoming/federal/district/`)
- Doc type: `complaint`. An original complaint with numbered paragraphs, a caption and the attorney information block; no separate certificate (see Governing rules).
- Exemplar: `usage/SAMPLE-wyd-complaint-onqfinancial126cv00277.pdf` (*On Q Financial, LLC v. Jorns & Associates LLC and Justin Ward Jorns*, No. 1:26-cv-00277, filed 2026-09-28, 17 pages; provenance in `usage/SOURCE.md`). One filer (plaintiff's counsel). This is one exemplar, not the tier-2 pair of 2 or 3 from different filers; see Known gaps.
- Sample: `usage/INPUT-wyd-complaint-onq.md` (transcription of the complaint from the caption through the prayer for relief, with the signature block in the frontmatter).
- Status: template and sample present; render, overlay and page review redone 2026-10-14 (below). Fonts pass 2026-10-15: the rule names no face, so the template keeps EB Garamond (see Typeface); render, overlay and all 10 pages re-checked. `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `wyd-complaint`. |
| `typst/wyd-complaint.typ` | Template. Parameter block at the top: EB Garamond 13 pt, double spacing (`body-leading = 1.05em`), one-inch margins, 8½ × 11. |
| `usage/INPUT-wyd-complaint-onq.md` | Markdown contract sample (frontmatter: caption, attorney block, date, signature; body: paragraphs, headings, numbered allegations, prayer). |
| `usage/OUTPUT-wyd-complaint-onq.typst.pdf` | `sh tools/render.sh courts/tenth-circuit/wyoming/federal/district/complaint usage/INPUT-wyd-complaint-onq.md` (10 pages, no typst warnings). |
| `usage/OVERLAY-onq-complaint.pdf`, `OVERLAY-onq-complaint.txt` | `sh tools/overlay.sh courts/tenth-circuit/wyoming/federal/district/complaint onq-complaint courts/tenth-circuit/wyoming/federal/district/complaint/usage/SAMPLE-wyd-complaint-onqfinancial126cv00277.pdf` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. The PDF is re-downloaded from the URL in `SOURCE.md`; it is not in git. |

## Governing rules

Primary sources, read 2026-10-14:

- D. Wyo. Local Civil Rule 10.1(a) (filing format) and 10.1(b) (caption and attorney information block): <https://www.wyd.uscourts.gov/sites/wyd/files/local_rules/localrules-cv22.pdf>, the Civil Local Rules, January 2022 edition, printed p. 12 (text extracted with `pdftotext`). The court's current-rules web page returned 404 on the day of review, so this January 2022 edition is the newest text retrieved; the May 2017 edition at `localrules-cv.pdf` is superseded. Rule 10.1(a): "typed, double spaced, single-sided, on eight and one-half (8½) x eleven (11) inch paper ... with a one (1) inch margin on all sides ... not less than 12 point font." Rule 10.1(b): caption per Fed. R. Civ. P. 10(a) plus the attorney information block (name, bar number, firm, address, telephone, email).
- Fed. R. Civ. P. 10(a) (caption: court name, title, file number, Rule 7(a) designation; the complaint's title names all the parties) and 10(b) (numbered paragraphs, each limited as far as practicable to a single set of circumstances): <https://www.law.cornell.edu/rules/frcp/rule_10> (fetched 2026-10-14; the page shows the amendment date 2007, no current-as-of date).
- Fed. R. Civ. P. 5(d)(1)(B): "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system" (<https://www.law.cornell.edu/rules/frcp/rule_5>, fetched 2026-10-14). The complaint template has no certificate of service, so nothing is lost by this rule.

Where the rules leave the layout open (the caption's column widths, the position of the signature block), the template follows the filed exemplar; the one place it does not yet (the party-designation indent) is an open item below.

## Typeface

| Face required by the rule | Rule (primary source) | Vendored substitute | Fit |
|---|---|---|---|
| None named. LR 10.1(a) requires only "not less than 12 point font" | D. Wyo. LR 10.1(a), January 2022 edition (see Governing rules) | None needed: EB Garamond is the default (`docs/FONTS.md`, "No face named") | n/a |

The rule names no face, so the template keeps EB Garamond at 13 pt. The filed exemplar uses Times-family type (see the tier-2 finding on p.1). That is a filer's convention, not a rule requirement, so no Liberation Serif substitute is applied here.

## Overlay

`usage/OVERLAY-onq-complaint.pdf` puts our render (red) over the best-matching filed page (blue). Pages are paired by word overlap, not by index. Diagnostic only, not a score. Last run:

- Sample p.1 ↔ filed p.1 (58%): caption, attorney block, title, introduction.
- p.2 ↔ p.3 (54%), p.3 ↔ p.4 (68%), p.4 ↔ p.5 (48%): jurisdiction, venue, parties and the factual background, which the filed pages carry in the same order.
- p.5 ↔ p.7 (86%), p.6 ↔ p.9 (61%), p.7 ↔ p.10 (82%), p.8 ↔ p.11 (53%): Counts I–III and the prayer.
- p.9 ↔ p.14 (52%), p.10 ↔ p.15 (42%): the prayer for relief and the signature block. The sample stops at the prayer; its signature block comes from the frontmatter.

## Page review (Gate 2)

Every page of `OUTPUT-wyd-complaint-onq.typst.pdf` was rendered at 60 dpi and viewed (10 of 10).

| Page | Content | Result |
|---|---|---|
| 1 | Attorney block (two columns), court name, caption with "Case No." and "JURY TRIAL DEMANDED", title, introduction, ¶¶ 1–2 | OK. Caption and attorney block are single-spaced. |
| 2 | ¶¶ 3–9, "PARTIES" heading | OK. |
| 3 | "JURISDICTION AND VENUE", ¶¶ 10–17 | OK. |
| 4 | "FACTUAL BACKGROUND", ¶¶ 18–23 with lettered sub-items (a)–(c) | OK. |
| 5 | ¶¶ 23(d), 24–30 | OK. |
| 6 | ¶¶ 31–39 | OK. |
| 7 | ¶¶ 40–45, "COUNT I" and "COUNT II" headings with the italic subtitles | OK. |
| 8 | ¶¶ 46–51, "COUNT III" heading | OK. |
| 9 | ¶¶ 52–57, "PRAYER FOR RELIEF" heading, prayer for Count I | OK. |
| 10 | Prayer for Counts II and III; "Dated" line; "Respectfully submitted" signature block | OK. The firm line "BROWNSTEIN HYATT FARBER SCHRECK, LLP" is the widest line and stays on one line. |

Tier-2 findings (OPEN or ACCEPTED):

- p.1 OPEN: the party designations ("Plaintiff,", "Defendants.") sit flush left under the party names. The brief template (`motion-brief/typst/wyd-motion-brief.typ`) indents them one inch, as the Elizondo exemplar does; this complaint template has not been changed to match yet.
- p.1 ACCEPTED: the typeface is EB Garamond where the filed complaint uses Times-family type (per `usage/SOURCE.md`). The rule names no face (LR 10.1(a): "not less than 12 point font"), so `docs/FONTS.md` gives EB Garamond. A Times-family filer convention would be Liberation Serif, but the choice is not a rule requirement; the template uses 13 pt. Decision for David: whether tier 2 should follow the exemplar's Times family.
- p.1 ACCEPTED: the attorney block sits above the court name, in two columns. LR 10.1(b) requires the block; its position is the template's.
- p.10 ACCEPTED: the sample stops at the prayer for relief, so the signature block is built from the frontmatter and placed after the prayer. The filed complaint's signature page was not compared line by line in this pass.

## Known gaps

1. Exemplar count. The one exemplar is a single filer's complaint (plaintiff's counsel). Tier 2 calls for 2 or 3 exemplars from different filers; a second complaint was not searched for in this pass, so tier 2 is judged against one filer only.
2. Sample scope. The sample transcribes the complaint from the caption through the prayer, not the exhibit list. The filed complaint is 17 pages; the render is 10 pages, inside the 8–14 page target.
3. Italics. The text layer does not carry font style, so the italics in the sample (case names, the "Declaratory Judgment" subtitles) follow convention and were not checked glyph by glyph against the filed page.
4. Local rule edition. The rules are the January 2022 edition (see Governing rules). A newer edition, if any, has not been checked.

## Engines

- **typst** (primary, `typst/`): the reference for the form. Pages reviewed for this section: 10 of 10 (typst render, 60 dpi).
- **docx** (`docx/`): `docx/reference.docx` (pandoc on it; EB Garamond 13 pt, exact 26 pt line pitch, 1 in margins, centered PAGE footer, borderless tables for the attorney block and caption), `docx/build-reference.sh` (rebuilds the reference; uses `ziptool`, since this box has no `unzip` or `zip`), `docx/wyd.lua` (builds the attorney block, court name, caption, title, signature block and the numbered allegations and lettered items from the frontmatter and body, following `typst/wyd-complaint.typ`). Build from this folder: `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/wyd.lua usage/INPUT-wyd-complaint-onq.md -o usage/OUTPUT-wyd-complaint-onq.docx`. The `.docx` passes the zip and XML checks (every part `xmllint --noout`); it has not been opened in Word or LibreOffice.
- **docx differences from typst:** paragraph and item numbers are typed text ("1.", "(a)") with a tab, not Word list numbering, so they will not renumber if an allegation is inserted; the caption and attorney block are tables, whose row heights and rule-free layout Word and LibreOffice may draw slightly differently from typst; the line pitch is exact 26 pt, which matches the typst leading at 13 pt but is not Word's "double" setting; headings carry outline levels but no table of contents is generated (the complaint has none).
- **docx BLOCKED:** every gate check measured on the LibreOffice PDF of the `.docx` (`usage/OUTPUT-onq-complaint.docx.pdf`) is BLOCKED. This folder has no `checks.yaml` (the court folder has none), so there are no check IDs to list, and `tools/check.sh` cannot run for `wyd` on any engine. Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.
