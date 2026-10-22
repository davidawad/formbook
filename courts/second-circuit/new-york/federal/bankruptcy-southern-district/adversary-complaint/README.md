# nysb: adversary complaint (typst, docx)

Court: United States Bankruptcy Court, Southern District of New York (`nysb`). Doc type: the complaint that starts an
adversary proceeding (Fed. R. Bankr. P. 7001). Engines: typst (`typst/`, the reference) and docx (`docx/`), on the shared
cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; gated in `eval.yaml`).

## Governing rules (verified 2026-10-14 unless marked)

| Requirement | Text relied on | Source | Verified |
|---|---|---|---|
| Caption of an adversary pleading | Fed. R. Civ. P. 10 applies, "except that a pleading's caption must substantially conform to the appropriate version of Form 416" | Fed. R. Bankr. P. 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 (amended eff. Dec. 1, 2024) | yes (fetched) |
| Caption layout | Official Form 416D, "Caption for Use in Adversary Proceeding": United States Bankruptcy Court; In re (Debtor); Plaintiff; Defendant; Case No.; Chapter; Adv. Proc. No.; title "COMPLAINT [or other designation]" | Official Form B 416D (12/15), https://www.uscourts.gov/file/18775/download | yes (fetched, read) |
| Typeface | No face named. Fed. R. Bankr. P. 9004 and LBR 9004-1 name none; SDNY Local Civil Rule 7.1(b) (which replaced 11.1, as seen in a 2026 search, not fetched from the court) sets 12-point type, double spacing and 1-inch margins and names no face. Times New Roman (vendored, `docs/FONTS.md`; the house standard), as both exemplars are set; the docx names the same face (`{font}` in `docx/reference.xml`) | Fed. R. Bankr. P. 9004; LBR 9004-1; SDNY Local Civil Rule 7.1(b) | rules: no face named; the face is a convention, not a rule |
| Caption contents, legibility | a document must show the court's name, the case title, the case number and adversary number, and a brief designation of its character; "clearly legible" | Fed. R. Bankr. P. 9004(a), (b), https://www.law.cornell.edu/rules/frbp/rule_9004 (amended eff. Dec. 1, 2024) | yes (fetched) |
| Form of papers | papers "plainly typed or printed"; "not be bound or stapled"; no material erasures; the face shows the filing attorney's name, office and post office addresses, and telephone | Local Bankruptcy Rule 9004-1(a), General Order M-641 (eff. Sept. 30, 2024), https://www.nysb.uscourts.gov/sites/default/files/m641.pdf | yes (read in the order) |
| Numbered paragraphs | "A party must state its claims or defenses in numbered paragraphs" (FRCP 10(b)) | Fed. R. Civ. P. 10(b), applied by FRBP 7010 | **no**: text not fetched in this run; from the rule as known; verify before landing |
| Type size, spacing, margins | not in LBR 9004-1 (its comment says it is adapted from SDNY Local Civil Rule 11.1, which sets 12-point type, double spacing and 1-inch margins) | Civil Rule 11.1 not retrieved: nysb.uscourts.gov and courtrules.net returned 403 / a Cloudflare challenge | **no**: see gaps |

What the verified rules do not set: type face, type size, line spacing, margins, page limits. The template uses the exemplar's
measured values (12 pt, double-spaced at 27.6 pt, 1-inch margins, letter paper, measured on the Celsius complaint) and
records them as conventions, not as rule text.

Judge-specific chambers practices may add requirements; not checked in this run.

## Layout (typst/nysb-adversary-complaint.typ)

- Cover: counsel block top left (LBR 9004-1(a)(4)); court name; the caption (parties left with right and bottom rules,
  Chapter / Case No. / Adv. Pro. No. right); "COMPLAINT"; the debtors' tax-identification note, marked `*` (the body's
  footnotes are numbered from 1, which Gate 0 expects; the exemplar numbers it 1 and the body's notes from 2). The cover
  carries no page number, and the body restarts at 1 after it.
- Body: numbered paragraphs (FRCP 10(b)), the number in a 0.5 in box after the 0.5 in indent (text 1 in from the margin).
  Headings at the type size on the body pitch, as in the exemplar: level 1 centered bold capitals, level 2 bold, lettered
  (A., B.) by the template in a 0.5 in box. Lists become (a), (b) ..., the label at the indent, the text hanging at 1 in.
- Markdown contract: a chunk marked `^` is an unnumbered paragraph (the prayer's WHEREFORE clause); footnote definitions are
  not paragraphs; the last paragraph or item of the body is kept with the signature block, so a signature never stands alone.
- Signature block: "Dated:", firm, "By: /s/" signer and address lines (single-spaced), a blank double line above it.
- Pitches (cross-engine model: every line a box of its pitch, explicit spaces between blocks): body 27.6 pt (the exemplar's
  double spacing), single lines and footnotes 13.8 pt, footnotes at 12 pt as in the exemplar (`pdftotext -bbox`, Celsius
  p.2: footnote words as tall as body words, 13.8 pt apart). Margins 72 pt, 12 pt type.

## Files

- `usage/FILED-EXAMPLE-adversary-complaint.pdf` (primary, Quinn Emanuel for the Post-Effective Date
  Celsius Debtors, filed Aug. 9, 2024) and `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (second
  filer, the NY Attorney General for The Lawyers' Fund, filed May 3, 2019, 4 pages). See `usage/SOURCE.md`.
- `usage/INPUT-adversary-complaint.md`: transcribed from the primary exemplar: the caption and counsel frontmatter, paragraphs
  1-31, the prayer and the first signature group. Not the whole pleading (30 pages).
- `usage/OUTPUT-adversary-complaint.typst.pdf`, `.docx` and `.docx.pdf`: 11 pages each (cover + 10). Overlays: `just overlay <dir>` (`.overlay/`, not committed).
- The brief named the sample `usage/<id>.md` and `<id>.pdf`, and `<id>-overlay.pdf`. The repo's tools and file-role names
  (`INPUT-`, `OUTPUT-`, `OVERLAY-`) are used instead, so `tools/render.sh` and `tools/overlay.sh` work unchanged.

## Commands (from the repo root)

    sh tools/render.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-adversary-complaint.md
    sh tools/overlay.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/adversary-complaint celsius-complaint

The render is a clean typst compile with the vendored fonts (no warnings).

## Overlay

`usage/OVERLAY-celsius-complaint.txt` pairs each rendered page with the filed page sharing the most words:

    ours p.1 -> filed p.1 (92.9%)    ours p.2 -> p.2 (74.1%)    ours p.3 -> p.3 (78.8%)    ours p.4 -> p.4 (79.1%)
    ours p.5 -> p.5 (60.7%)          ours p.6 -> p.6 (58.0%)    ours p.7 -> p.7 (63.3%)    ours p.8 -> p.8 (57.6%)
    ours p.9 -> p.9 (69.2%)          ours p.10 -> filed p.29 (46.5%)    ours p.11 -> filed p.30 (35.8%)

Red (ours) and blue (filed) do not coincide line for line (figures from an earlier render). That is expected: the
template's own cover and a partial transcription. Pages 10 and 11 are the prayer and signature, which pair with the filed prayer pages 29
and 30. The overlay is a diagnostic, not a score.

## Gate 2: every page rendered at 60 dpi and reviewed (2026-10-22, both engines)

Rendered with `pdftoppm -r 60` and viewed, typst and docx side by side: all 11 pages of each (they break every line and
page alike: `fb diff --engines`, 272/272 lines).

- p.1 cover: counsel (two groups), "Counsel to ..." in italics, court name, the caption (the debtors marked `*`, "against"
  between the parties, the right and bottom rules), "COMPLAINT"; the `*` note under its rule at the foot of the page.
- p.2 (page 1): the unnumbered opening paragraph, "NATURE OF THE CASE", paragraphs 1-2, note 1.
- p.3: paragraphs 2-5. p.4: 5-8. p.5: 8-9, "THE PARTIES", 10-15, "JURISDICTION AND VENUE", 16. p.6: 16-19, note 2.
- p.7: 20-21, "FACTUAL BACKGROUND", "A." heading, 22-24. p.8: 24-25, "B. The Token Agreement", 26-28. p.9: 28-31.
- p.10: 31, "PRAYER FOR RELIEF", the WHEREFORE clause (unnumbered), items (a)-(d). p.11: items (e)-(g) and the
  signature block, kept with item (g).

Compared with the two exemplars (Celsius, Quinn Emanuel; Ehrenfeld, NY Attorney General): 12 pt Times, 27.6 pt double
spacing, centered bold capital headings at the type size, numbered paragraphs with the text 1 in from the margin, a
single-spaced caption and signature: professional and consistent with both. Open (tier 3, not chased): the Celsius
exemplar sets its counsel groups side by side, underlines its headings, and starts its body with the title on page 2.

## Known gaps (tier 2 and beyond; not tier 1)

- The cover note is marked `*` (the exemplar numbers it 1). In the docx it is the cover section's footer, under a rule
  like the typst footnote separator: a Word footnote would take number 1, and LibreOffice cannot number the body's notes
  from 1 again after it (`numRestart eachSect` becomes a per-page restart there).
- The firms of the counsel block are stacked, not side by side as in the Celsius exemplar (tier 3).
- Only the first signing group of the exemplar is in the sample (the second counsel group and the Scheck block are omitted).
- The sample is a partial transcription (¶¶1-31 and the prayer), so the overlay compares partial pages.
- Not produced: the summons, the Form 1040 adversary cover sheet, the civil cover information, and exhibits. These are
  separate filings, not the complaint.
- The paragraph count in a long complaint is not limited by the template.
- Tier 2 asks for 2-3 filers. Two filed complaints are in `usage/` (Celsius, Ehrenfeld). The sample is transcribed from one.

## BLOCKED

Not blocked for the adversary complaint. The verification gaps above (FRCP 10(b) text not fetched; SDNY Civil Rule 11.1 not
retrieved) are recorded, and they bear on tier 1 (numbered paragraphs, typography) and should be checked before landing.

## Engines

DOCX (`docx/`): `docx/reference.xml` (base `xengine`: the face `{font}`, Times New Roman as in typst; 12 pt; Body Text in
exact 27.6 pt lines with a 0.5 in indent; footnotes at 12 pt in 13.8 pt lines; Body Number, Body Keep, Lettered and
Lettered Keep) and `docx/nysb-adversary-complaint.lua`, which `fb render` runs: the cover as WordprocessingML (counsel,
court, the Form 416D caption as a table with the party column's right and bottom rules, the title), its section without a
page number and the `*` note in its footer; the body (numbered paragraphs, headings, the lettered prayer, the signature
table) with every paragraph in exact line boxes of the typst pitches and typst's break rules (`lib/docx/xengine.lua`); the
body's section (page numbers from 1) through `FORMBOOK_FINAL`. No shell: `docx/build-reference.sh` and the committed
`reference.docx` are gone (fb-595.68.25).

- `sh tools/check.sh <dir> --engine typst`: 9 checks passed, 0 failed. `--engine docx`: 13 checks passed, 0 failed,
  XENG-001..003 PASS (11 pages each, 272/272 lines) with `params.cross_engine: gate` in `eval.yaml`.
- Word may paginate a line differently from LibreOffice (docs/DOCX.md); the gate compares the LibreOffice PDF.
