# nysb: motion with memorandum of law (typst, docx)

Court: United States Bankruptcy Court, Southern District of New York (`nysb`). Doc type: a motion together with its
memorandum of law (Fed. R. Bankr. P. 9013). Engines: typst (`typst/`, the reference) and docx
(`docx/`), on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; gated in `eval.yaml`).

## Governing rules (verified 2026-10-14 unless marked)

| Requirement | Text relied on | Source | Verified |
|---|---|---|---|
| Motion must state its basis | "Each motion shall specify the rules and statutory provisions upon which it is predicated and the legal authorities that support the requested relief, either in the motion or in a separate memorandum of law"; otherwise the court may strike it | Local Bankruptcy Rule 9013-1(a), General Order M-641 (eff. Sept. 30, 2024), https://www.nysb.uscourts.gov/sites/default/files/m641.pdf | yes (read in the order) |
| No separate memorandum required | the 2008 amendment deleted the requirement of a separate memorandum; the discussion of the law must be in the motion or in a separate memorandum | Comment to LBR 9013-1 (M-641) | yes |
| Notice of the motion | notice to any entity believed to have or claim an interest in the subject matter (LBR 9013-1(c)) | M-641 | yes (read) |
| Form of papers | typed or printed; not bound or stapled; no material erasures; face shows the filing attorney's name, office and post office addresses, telephone | LBR 9004-1(a), M-641 | yes (read) |
| Typeface | No face named. LBR 9013-1 and 9004-1 name none; SDNY Local Civil Rule 7.1(b) (which replaced 11.1, as seen in a 2026 search, not fetched from the court) sets 12-point type, double spacing and 1-inch margins and names no face. Times New Roman (vendored, `docs/FONTS.md`; the house standard), as both exemplars are set; the docx names the same face (`{font}` in `docx/reference.xml`) | LBR 9013-1; LBR 9004-1; SDNY Local Civil Rule 7.1(b) | rules: no face named; the face is a convention, not a rule |
| Caption of a document | court name, case title, case number and adversary number, and a brief designation of the document's character | Fed. R. Bankr. P. 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 (amended eff. Dec. 1, 2024) | yes (fetched) |
| Adversary caption | Official Form 416D (the adversary caption), applied through FRBP 7010 | https://www.uscourts.gov/file/18775/download; Rule 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 | yes (fetched) |
| Numbered paragraphs | not required for a memorandum; the exemplar numbers them | convention (exemplar) | n/a |
| Type size, spacing, margins, page limits | not in LBR 9004-1 or 9013-1; the Comment to LBR 9004-1 says it is adapted from SDNY Local Civil Rule 11.1 (12-point, double spacing, 1-inch margins); Civil Rule 11.1 and the judges' chambers rules were not retrieved | see the exemplar and the gaps below | **no** |

What the verified rules do not set: type face and size, line spacing, margins, page limits, a table of contents or a table of
authorities. The template uses the exemplar's measured values (12 pt, double-spaced at 27.6 pt, 1-inch margins, letter paper) and
records them as conventions. Judge-specific chambers practices (page limits, word limits, pre-motion conference rules) are not
checked in this run.

## Layout (typst/nysb-motion-brief.typ)

- Cover: counsel block top left, court name, caption (parties left with right and bottom rules; "v." between the sides, from
  `caption.separator`), Chapter / Case No. / Adv. Pro. No. right, the title centered in bold capitals. No page number. A
  debtors' `note` in the caption is marked `*` (the body's footnotes are numbered from 1).
- Contents page, numbered in roman numerals from the page after the cover: "TABLE OF CONTENTS", "Page" over the page column,
  one single-spaced row per heading with a blank single line above it, its label (I., A., 1.) in a 0.5 in box at the
  heading's indent as the exemplar's contents set them (under ARGUMENT I. at the margin and A. half an inch in; elsewhere A.
  half an inch in and 1. an inch in), the title wrapping before a 0.5 in page column, a dot leader to the page
  (`listing-row` of `lib/typst/xengine.typ`).
- Body: arabic numerals from 1. Numbered paragraphs (the exemplar's convention), the number in a 0.5 in box after the 0.5 in
  indent (text 1 in from the margin, as in the exemplar). Headings at the type size on the body pitch: level 1 centered bold
  capitals (PRELIMINARY STATEMENT, STATEMENT OF FACTS, ARGUMENT, CONCLUSION); levels 2 and 3 bold, labelled at the indents of
  the contents. Under ARGUMENT, level-2 headings are roman numerals (I., II.) and level-3 headings are letters (A., B.).
  Elsewhere, level-2 headings are letters and level-3 headings are numbers (1., 2.).
- Markdown contract: a chunk marked `^` is unnumbered (the introductory paragraph); footnotes are `[^key]` references with
  their definitions in chunks of their own, which are not paragraphs; a literal underscore is written `\_` (the docx reads
  the sample as CommonMark, as typst's cmarker does). The last paragraph of the body is kept whole with the signature block.
- Signature block: "Dated:", the firm, "By: /s/" signer and address lines, single-spaced, a blank double line above it.
- Pitches (cross-engine model: every line a box of its pitch, explicit spaces between blocks): body 27.6 pt (the exemplar's
  double spacing, `pdftotext -bbox` Revlon p.15), single lines and footnotes 13.8 pt, footnotes at 12 pt.

## Files

- `usage/FILED-EXAMPLE-motion-brief.pdf` (primary: Debtors' memorandum in support of their motion to dismiss
  the adversary complaint, Paul Weiss / MoloLamken / Kaplan Rice, ECF Doc. 16, 68 pages, filed Dec. 5, 2022) and
  `usage/FILED-EXAMPLE-motion-brief-2.pdf` (second filer: Tether defendants' memorandum in support of
  their motion to dismiss, Kramer Levin, ECF Doc. 33, 57 pages, dated Jan. 17, 2025). See `usage/SOURCE.md`.
- `usage/INPUT-motion-brief.md`: an excerpt transcribed from the primary exemplar: the preliminary statement (¶¶1-8), the
  first part of the statement of facts (¶¶9-14, sub-heading A) and the first point of the argument (¶¶31-33, renumbered 15-17
  here). Sections B-E of the facts, the rest of the argument and the table of authorities are not transcribed.
- `usage/OUTPUT-motion-brief.typst.pdf`, `.docx` and `.docx.pdf`: 11 pages each (cover, contents, 9 body pages). Overlays: `just overlay <dir>` (`.overlay/`, not committed).
- As for the complaint, the sample uses the repo's `INPUT-`, `OUTPUT-`, `OVERLAY-` names, so the tools work unchanged.

## Commands (from the repo root)

    sh tools/render.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md
    sh tools/overlay.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief revlon-memorandum courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf

The third argument is required here. With no exemplar named, `tools/overlay.sh` takes the first `usage/*.pdf` alphabetically, which is the Tether memorandum (`celsius-tether`), and the match falls to about 12% per page. The Revlon memorandum is the overlay reference.

The render is a clean typst compile with the vendored fonts (no warnings).

## Overlay

`usage/OVERLAY-revlon-memorandum.txt` (ours -> filed page with the most words in common):

    ours p.1 -> p.1 (92.9%)   ours p.2 -> p.2 (29.6%, the contents page)   ours p.3 -> p.13 (93.5%)   ours p.4 -> p.14 (91.9%)
    ours p.5 -> p.15 (90.5%)  ours p.6 -> p.16 (90.3%)  ours p.7 -> p.17 (61.0%)  ours p.8 -> p.18 (52.1%)
    ours p.9 -> p.27 (54.1%)  ours p.10 -> p.27 (31.8%)

Pages 3 to 8 pair with the filed pages 13 to 18 (the filed body, which is the transcribed text). Pages 9 and 10 both pair with
filed page 27: the match is by words, and the sample's last pages carry the point I text, which the filed page 27 only partly
shares (figures from an earlier render). Red (ours) and blue (filed) do not coincide line for line: an excerpt, transcribed.
The overlay is a diagnostic, not a score.

## Gate 2: every page rendered at 60 dpi and reviewed (2026-10-22, both engines)

Rendered with `pdftoppm -r 60` and viewed, typst and docx side by side: all 11 pages of each (they break every line and
page alike: `fb diff --engines`, 233/233 lines).

- p.1 cover: counsel (three firms), "Counsel and Special Litigation Counsel ..." in italics, court name, caption with "v.",
  the title in two single-spaced lines. No page number.
- p.2 contents (i): PRELIMINARY STATEMENT 1; STATEMENT OF FACTS 5; A. The 2016 Credit Facility 5; ARGUMENT 7; I. Plaintiffs
  Lack Standing ... (two lines, the second hanging after the label) 9. Checked against the body footers: right on both engines.
- p.3 (1): the unnumbered opening paragraph, PRELIMINARY STATEMENT, ¶¶1-2. p.4 (2): ¶¶2-4. p.5 (3): ¶¶4-5. p.6 (4): ¶¶6-8.
- p.7 (5): STATEMENT OF FACTS, ¶9 with note 1, A. The 2016 Credit Facility, ¶10. p.8 (6): ¶¶10-13. p.9 (7): ¶¶13-14,
  ARGUMENT, ¶15. p.10 (8): ¶16. p.11 (9): point I, ¶17, the signature block.

ACCEPTED: p.10 (8) ends after ¶16 with half a page free: point I, ¶17 (kept whole with the signature) and the signature
block are 1 pt taller than the space left, so all three open p.11, on both engines. The rule that a signature never stands
alone decides it; nothing is wrong in the layout.

Compared with the two exemplars (Revlon, Paul Weiss; Tether, Kramer Levin): 12 pt Times, 27.6 pt double spacing, centered
bold capital section headings at the type size, numbered paragraphs with the text 1 in from the margin, a contents page in
roman numerals with labels, leaders and a "Page" column: professional and consistent with both. Open (tier 3, not chased):
the Revlon exemplar puts the counsel block at the foot of the cover, underlines its title and point headings, and adds a
table of authorities (see Known gaps).

## Known gaps (tier 2 and beyond; not tier 1)

- No table of authorities. Not required by a verified rule; the exemplar has one (the template does not generate it).
- The counsel block heads the cover (the Revlon exemplar sets it at the foot, under the title); tier 3.
- No proposed order (the exemplar's ECF Doc. 16 ends with one, and the Tether memorandum has a table of authorities).
- The signature block carries one signer (Lewis R. Clayton). The exemplar also has the MoloLamken and Kaplan Rice signatures.
- The sample is an excerpt (the rest of the argument is not transcribed), so the overlay compares partial pages.
- Type size and spacing rest on the exemplar and on the origin rule (SDNY Civil Rule 11.1), not on fetched text. Judges'
  chambers rules were not checked.
- Tier 2 asks for 2-3 filers: two memoranda are in `usage/` (Debtors, Tether). The template is built from the first.

## BLOCKED

Not blocked for the motion memorandum. The verification gap on type size and spacing (SDNY Civil Rule 11.1 and the judges'
chambers rules were not retrieved) bears on tier 1 and should be checked before landing.

## Engines

DOCX (`docx/`): `docx/reference.xml` (base `xengine`: the face `{font}`, Times New Roman as in typst; 12 pt; Body Text in
exact 27.6 pt lines with a 0.5 in indent; footnotes at 12 pt in 13.8 pt lines; Body Number, Body Keep, Lettered and
Lettered Keep; the sample read as CommonMark) and `docx/nysb-motion-brief.lua`, which `fb render` runs: the cover as
WordprocessingML (counsel, court, the Form 416D caption as a table with the party column's right and bottom rules, the title)
in a section without a page number; the contents (rows with a right indent at the page column, `xe.LEAD` and a dot leader
tab) in a section numbered from i; the memorandum (numbered paragraphs, labelled headings, lists, the signature table) with
every paragraph in exact line boxes of the typst pitches and typst's break rules (`lib/docx/xengine.lua`), numbered from 1
through `FORMBOOK_FINAL`. The contents' pages come from needles (`FORMBOOK_NEEDLES`: the contents' title, the memorandum's
first words, each heading with its label and the words after it) that `fb render` finds in the LibreOffice PDF and feeds
back (`FORMBOOK_PAGES`) until they settle. No shell: `docx/build-reference.sh`, `docx/render.sh` and the committed
`reference.docx` are gone (fb-595.68.25).

- `sh tools/check.sh <dir> --engine typst`: 9 checks passed, 0 failed. `--engine docx`: 13 checks passed, 0 failed,
  XENG-001..003 PASS (11 pages each, 233/233 lines) with `params.cross_engine: gate` in `eval.yaml`.
- Word may paginate a line differently from LibreOffice (docs/DOCX.md); the gate compares the LibreOffice PDF. The contents
  are typed text, not a TOC field.
