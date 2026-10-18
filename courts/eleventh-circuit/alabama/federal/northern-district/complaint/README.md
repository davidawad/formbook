# N.D. Alabama (alnd): complaint

- Court: `alnd`, United States District Court for the Northern District of Alabama (`courts/eleventh-circuit/alabama/federal/northern-district/`)
- Doc type: `complaint`. Original complaint, Southern Division; numbered paragraphs, caption, counts, prayer, signature block.
- Exemplar: `usage/SAMPLE-alnd-complaint-sec226cv01586.pdf` (*The Southeastern Conference v. Louisiana State University, et al.*, No. 2:26-cv-01586-ACA, Doc. 1, filed 2026-09-03, 29 pages; provenance in `usage/SOURCE.md`). Re-downloaded from CourtListener RECAP on 2026-10-14.
- Sample: `usage/INPUT-alnd-complaint-sec.md` (transcription of selected pages; see Known gaps).
- Status: template present, render and overlay re-run on 2026-10-14 (fonts pass: no face named by the court's rules, so EB Garamond stays; see Typeface); every page of the render reviewed (10 of 10). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `alnd-complaint`. |
| `typst/alnd-complaint.typ` | Template. Parameter block at the top: typeface (EB Garamond 13 pt), double spacing (24 pt pitch), margins, paragraph indent, caption column width. |
| `usage/INPUT-alnd-complaint-sec.md` | Markdown contract sample: YAML frontmatter (court, caption, title, lead-in, date line, signature) plus the numbered body. |
| `usage/OUTPUT-alnd-complaint-sec.typst.pdf` | `sh tools/render.sh courts/eleventh-circuit/alabama/federal/northern-district/complaint usage/INPUT-alnd-complaint-sec.md` (10 pages). |
| `usage/OVERLAY-sec-complaint.pdf`, `OVERLAY-sec-complaint.txt` | `sh tools/overlay.sh courts/eleventh-circuit/alabama/federal/northern-district/complaint sec-complaint` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary sources. Rule 10 text was read on 2026-10-14 (Cornell LII); LR 23.1 was read from the court's PDF (below); Rules 8(a) and 11(a) are cited from the template's header and were not re-read this session.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Fed. R. Civ. P. 8(a) (cited, not re-read) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. <https://www.law.cornell.edu/rules/frcp/rule_8> | content of the pleading (not a layout rule) |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and the Rule 7(a) designation. <https://www.law.cornell.edu/rules/frcp/rule_10> (text read 2026-10-14) | `caption`, `court-title`; `case_number` is blank for a new complaint (the clerk assigns it) |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs"; each limited as far as practicable to a single set of circumstances (same URL, text read 2026-10-14) | numbered paragraphs (the template numbers the allegations itself, from 1 per sample) |
| Fed. R. Civ. P. 10(c) | Statements may be adopted by reference; exhibits become part of the pleading (same URL) | not rendered; the sample has no exhibits |
| Fed. R. Civ. P. 11(a) (cited, not re-read) | Signature by at least one attorney of record, with address, email and telephone number. <https://www.law.cornell.edu/rules/frcp/rule_11> | `signature` block |
| N.D. Ala. LR 23.1 | In a class action, the pleading's caption, under the case number, includes the legend "Class Action." Text quoted from the Local Rules PDF below. | optional legend, shown only when the case is a class action (not in the sample) |

The court's Local Rules are at <https://www.alnd.uscourts.gov/local-rules>. The copy read for this README is the 2019 revision, linked there as "ALND Local Rules Revised 12-04-2019" (<https://www.alnd.uscourts.gov/sites/alnd/files/ALND%20Local%20Rules%20Revised%2012-04-2019.pdf>), read 2026-10-14: 14 pages, headed "(Effective December 4, 2019)", PDF modified 2019-12-09. Its text contains no rule on typeface, font size, margins, spacing, page length, or certificates of service for pleadings (checked by text search of the extracted PDF). Rule text quoted from it:

> LR 23.1 Designation of Class Action in the Caption. In any case sought to be maintained as a class action, the complaint, or other pleading, document or other papers asserting a class action, shall include in its caption under the case number, the legend "Class Action."

Judge's standing orders are not part of the local rules and were not checked for this template (see Typeface below).

Because the local rules set no layout rule, the layout follows the filed exemplar: 13 pt (the template's stated choice against the exemplar's Times 12 pt; not re-measured this session), double spacing with a 24 pt pitch, 1-inch margins, a caption with a party column and a case-number column, and page numbers at the foot.

## Typeface

| Face required | Vendored substitute | Fit |
|---|---|---|
| None. The court's Local Rules (2019) name no typeface, so the template keeps EB Garamond (the court's rules name no face; `docs/FONTS.md` "No face named"). | EB Garamond (`fonts/eb-garamond/`) | n/a |

A single judge's standing order can set a face for that judge's cases. Judge Johnson's Initial Order (Huntsville, `https://www.alnd.uscourts.gov/sites/alnd/files/HNJ%20Initial%20Order%20without%20Rule%2026%20Language.docx`, read 2026-10-14) says "The parties motions and briefs shall be in Times New Roman font and 14-point type", double-spaced. It binds only that judge's cases and is not a court rule, so this template does not follow it. A per-judge variant (Liberation Serif, 14 pt; `docs/FONTS.md` "Times New Roman") would be a separate template and is not built here.

The filed exemplar's body text is Times New Roman (`pdffonts` on the exemplar, 2026-10-14; it also embeds Arial). The overlay compares against it as a visual reference only; that is not a rule, and the layout is not changed to match it.

## Overlay

`usage/OVERLAY-sec-complaint.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run:

```
ours p.1  filed p.1   71.2%   caption and opening paragraphs
ours p.2  filed p.3   51.5%
ours p.3  filed p.5   67.9%
ours p.4  filed p.7   41.7%   jurisdiction and venue
ours p.5  filed p.11  29.9%
ours p.6  filed p.17  33.5%
ours p.7  filed p.19  66.6%
ours p.8  filed p.21  69.4%   Count I
ours p.9  filed p.28  36.5%   prayer for relief
ours p.10 filed p.29  79.4%   signature block
```

Pairing is by word overlap; low scores (below 40%) on pages 4 to 6 and 9 are the transcription gaps below, not layout faults.

## Page review (Gate 2)

Every page of `OUTPUT-alnd-complaint-sec.typst.pdf` was rasterized (`pdftoppm -r 60`) and viewed: 10 of 10. Typst printed no warnings. Only EB Garamond is embedded. A scan of the text positions of every page (`pdftotext -bbox`) found no line pair closer than 12 pt.

| Page | Content | Result |
|---|---|---|
| 1 | Court heading, caption, title "COMPLAINT", start of the lead-in and the "INTRODUCTION" heading | OK. `Case No.:` blank (correct for a new complaint). |
| 2 | Introduction, paragraphs 2 to 6 | OK. |
| 3 | Paragraphs 7 to 12; "PARTIES" heading | OK. |
| 4 | Paragraphs 13 to 18; "JURISDICTION AND VENUE" | OK. |
| 5 | Paragraphs 19 to 24; factual background headings | OK. |
| 6 | Paragraphs 25 to 30; "The SEC's First Amendment Rights" | OK. |
| 7 | Paragraphs 31 to 35; "Harm to the Conference" | OK. |
| 8 | Paragraphs 36 to 41; "CAUSES OF ACTION", "COUNT I" with "(Against All Defendants)" | OK. |
| 9 | Paragraphs 42 to 43; "PRAYER FOR RELIEF", items A to D | OK. |
| 10 | Date line; two signature blocks; "Attorneys for Plaintiff" | OK. |

Tier-2 findings (OPEN or ACCEPTED):

- ACCEPTED, p.1: `Case No.:` is blank. The sample is a new complaint with no number; the filed exemplar carries the number the clerk assigned (2:26-cv-01586-ACA), which the sample does not transcribe.
- ACCEPTED, p.8: the Count I heading and its "(Against All Defendants)" legend are set as the transcription gives them; the filed exemplar's heading wording is in the transcription, not re-checked against the PDF page image in this review.
- OPEN, p.10: the two signature blocks sit side by side in two columns, as in the transcription; the filed exemplar's exact column placement was not compared line by line.

## Engines

The docx engine (`docx/`: `make-reference.sh` builds `reference.docx`, `alnd-complaint.lua` builds the cover, the numbered paragraphs and the signature block) renders `usage/OUTPUT-alnd-complaint-sec.docx` and `.docx.pdf` (the LibreOffice conversion). Every page of the `.docx.pdf` (10 of 10) was rasterized (`pdftoppm -r 60`) and compared with the typst render of the same sample.

| Item | typst (primary) | docx |
|---|---|---|
| Typeface and size | EB Garamond 13 pt | same; EB Garamond is embedded in the PDF |
| Body spacing | 24 pt pitch | 24 pt exact |
| Caption, title, signature block | 15 pt pitch, caption rules | same; the gaps around the caption were measured against the typst render and agree within 4 pt |
| Numbered paragraphs | number at 0.5 in, text after it, wrapped lines at the margin | same, with tab stops |
| Lettered prayer items | label at 0.5 in, text at 0.9 in | same, hanging indent |
| Headings | level 1 bold capitals; levels 2 and 3 bold, centered | same |
| Page number | centered in the footer | same (PAGE field) |

What differs:

- Pagination: LibreOffice and typst break lines at different points, so a few paragraphs move. Both render 10 pages. The heading "FACTUAL BACKGROUND" moves to page 5 in the docx (it keeps with the next paragraph) where typst keeps it on page 4, and the prayer items start on page 10 where typst keeps them on page 9.
- The caption and the two-firm signature block are Word tables built from the plain text of their entries, so italics inside them are not kept. The sample has none there.
- The `.docx` was not opened interactively in Word or LibreOffice (Word is not available here; the LibreOffice check was headless, which cannot show a repair prompt). The file is a well-formed zip with well-formed XML parts (`tools/render-docx.sh`).
- The docx gates (`tools/check.sh --engine docx`) were not run: this court folder has no `checks.yaml` or `rules.md` yet.

docx BLOCKED items:

- `BLOCKED: tools/check.sh --engine docx: not run, because the court folder has no checks.yaml yet.`

## Known gaps

1. The sample is a transcription of selected parts of the 29-page exemplar. The frontmatter comment in `INPUT-alnd-complaint-sec.md` lists which paragraphs and sections are transcribed; Count II and the pages between are not. The template numbers the allegations itself, so the sample numbers run from 1 and do not match the filed paragraph numbers.
2. The sample has no certificate of service. A complaint is served with the summons under Rule 4, so the template has no certificate block; the template does not render one.
3. The class-action legend (LR 23.1) is supported but not exercised: the sample is not a class action, so the legend is absent from its caption.
4. Italics of case names are not in the exemplar's text layer and are not transcribed; the sample's case names are plain text.
5. The typeface is EB Garamond because the court's rules name no face, not because a Times New Roman substitute is missing: `fonts/liberation-serif/` is vendored. The 14-point Times New Roman rule in Judge Johnson's standing order is not applied (see Typeface).
6. The 2019 local rules are read (see Governing rules); the Rule 8(a) and 11(a) text is still not re-read this session.
