# nysb: motion with memorandum of law (typst)

Court: United States Bankruptcy Court, Southern District of New York (`nysb`). Doc type: a motion together with its
memorandum of law (Fed. R. Bankr. P. 9013). Engine: typst only, as the brief asked (`typst/`).

## Governing rules (verified 2026-10-14 unless marked)

| Requirement | Text relied on | Source | Verified |
|---|---|---|---|
| Motion must state its basis | "Each motion shall specify the rules and statutory provisions upon which it is predicated and the legal authorities that support the requested relief, either in the motion or in a separate memorandum of law"; otherwise the court may strike it | Local Bankruptcy Rule 9013-1(a), General Order M-641 (eff. Sept. 30, 2024), https://www.nysb.uscourts.gov/sites/default/files/m641.pdf | yes (read in the order) |
| No separate memorandum required | the 2008 amendment deleted the requirement of a separate memorandum; the discussion of the law must be in the motion or in a separate memorandum | Comment to LBR 9013-1 (M-641) | yes |
| Notice of the motion | notice to any entity believed to have or claim an interest in the subject matter (LBR 9013-1(c)) | M-641 | yes (read) |
| Form of papers | typed or printed; not bound or stapled; no material erasures; face shows the filing attorney's name, office and post office addresses, telephone | LBR 9004-1(a), M-641 | yes (read) |
| Typeface | No face named. LBR 9013-1 and 9004-1 name none; SDNY Local Civil Rule 7.1(b) (which replaced 11.1, as seen in a 2026 search, not fetched from the court) sets 12-point type, double spacing and 1-inch margins and names no face. Kept EB Garamond (`font-family`), the vendored default in `docs/FONTS.md`. The exemplars are set in Times New Roman, which the rules do not require | LBR 9013-1; LBR 9004-1; SDNY Local Civil Rule 7.1(b) | rules: no face named; the face is a convention, not a rule |
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
  `caption.separator`), Chapter / Case No. / Adv. Pro. No. right, the title centered in bold capitals. No page number.
- Contents page: `outline()` with headings to three levels, numbered in roman numerals from the page after the cover.
- Body: arabic numerals from 1. Numbered paragraphs (the exemplar's convention). Level-1 headings are centered bold capitals
  (PRELIMINARY STATEMENT, STATEMENT OF FACTS, ARGUMENT, CONCLUSION). Under ARGUMENT, level-2 headings are roman numerals (I., II.)
  and level-3 headings are letters (A., B.). Elsewhere, level-2 headings are letters and level-3 headings are numbers (1., 2.).
  The template works out which applies from the nearest level-1 heading.
- Markdown contract: a chunk marked `^` is unnumbered (the introductory paragraph); footnotes are cmarker footnotes; footnote
  definitions are not paragraphs. The last item of the body sticks to the signature block.
- Signature block: "Dated:", "/s/" signer, firm and address lines.

## Files

- `exemplars/FILED-EXAMPLE-revlon-22-01167-motion-brief.pdf` (primary: Debtors' memorandum in support of their motion to dismiss
  the adversary complaint, Paul Weiss / MoloLamken / Kaplan Rice, ECF Doc. 16, 68 pages, filed Dec. 5, 2022) and
  `exemplars/FILED-EXAMPLE-celsius-tether-24-04018-motion-brief.pdf` (second filer: Tether defendants' memorandum in support of
  their motion to dismiss, Kramer Levin, ECF Doc. 33, 57 pages, dated Jan. 17, 2025). See `exemplars/SOURCE.md`.
- `samples/INPUT-revlon-memorandum.md`: an excerpt transcribed from the primary exemplar: the preliminary statement (¶¶1-8), the
  first part of the statement of facts (¶¶9-14, sub-heading A) and the first point of the argument (¶¶31-33, renumbered 15-17
  here). Sections B-E of the facts, the rest of the argument and the table of authorities are not transcribed.
- `samples/OUTPUT-revlon-memorandum.pdf`: 10 pages (cover, contents, 8 body pages). `samples/OVERLAY-revlon-memorandum.pdf` and `.txt`.
- As for the complaint, the sample uses the repo's `INPUT-`, `OUTPUT-`, `OVERLAY-` names, so the tools work unchanged.

## Commands (from the repo root)

    sh tools/render.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief samples/INPUT-revlon-memorandum.md
    sh tools/overlay.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief revlon-memorandum courts/second-circuit/new-york/federal/bankruptcy-southern-district/motion-brief/exemplars/FILED-EXAMPLE-revlon-22-01167-motion-brief.pdf

The third argument is required here. With no exemplar named, `tools/overlay.sh` takes the first `exemplars/*.pdf` alphabetically, which is the Tether memorandum (`celsius-tether`), and the match falls to about 12% per page. The Revlon memorandum is the overlay reference.

The render is a clean typst compile with the vendored fonts (no warnings).

## Overlay

`samples/OVERLAY-revlon-memorandum.txt` (ours -> filed page with the most words in common):

    ours p.1 -> p.1 (92.9%)   ours p.2 -> p.2 (29.6%, the contents page)   ours p.3 -> p.13 (93.5%)   ours p.4 -> p.14 (91.9%)
    ours p.5 -> p.15 (90.5%)  ours p.6 -> p.16 (90.3%)  ours p.7 -> p.17 (61.0%)  ours p.8 -> p.18 (52.1%)
    ours p.9 -> p.27 (54.1%)  ours p.10 -> p.27 (31.8%)

Pages 3 to 8 pair with the filed pages 13 to 18 (the filed body, which is the transcribed text). Pages 9 and 10 both pair with
filed page 27: the match is by words, and the sample's last pages carry the point I text, which the filed page 27 only partly
shares. Red (ours) and blue (filed) do not coincide line for line: EB Garamond against Times New Roman, and a transcription.
The overlay is a diagnostic, not a score.

## Gate 2: every page rendered at 60 dpi and reviewed

All 10 pages viewed.

- p.1 cover: counsel, court name, caption with "v.", the title, fits on one page.
- p.2 contents (roman i): PRELIMINARY STATEMENT 1; STATEMENT OF FACTS 4; "The 2016 Credit Facility" 5; ARGUMENT 6; point I 8.
  (Checked against the body footers after the last render: body 1, 4, 5, 6, 8 sit on the pages listed.)
- p.3 (body 1): intro (unnumbered), PRELIMINARY STATEMENT, ¶¶1-2. p.4 (2): ¶¶3-4.
- p.5 (3): ¶¶5-6. p.6 (4): ¶¶7-8, then STATEMENT OF FACTS with ¶9 beginning at the foot of the page.
- p.7 (5): ¶9 continued, A. The 2016 Credit Facility, ¶¶10-12. p.8 (6): ¶¶13-14, ARGUMENT, ¶15 begins.
- p.9 (7): ¶15 continued, ¶16. p.10 (8): point I (sticky heading), ¶17, the signature block.

Defects found in review and fixed in the template:
1. Paragraph blocks overlapped the next block (a line at each boundary): every body block now has `below` equal to one leading.
2. A heading with its paragraph was held in one unbreakable block, which left half a page empty before STATEMENT OF FACTS. The
   heading is sticky and the paragraph may break after it.
3. The heading counter did not advance when headings had no numbering. Headings now carry an empty numbering pattern, and the
   visible labels come from the show rules.
4. A bare-counter lookup failed on the first point heading; fixed by (3).

Open in the render: the contents page lists headings without their labels (I., A.): typst's outline shows the numbering
pattern, which here is empty, and a pattern cannot depend on the enclosing section. Recorded as a gap.

## Known gaps (tier 2 and beyond; not tier 1)

- No table of authorities. Not required by a verified rule; the exemplar has one (the template does not generate it).
- The contents page omits the labels (I., A.) from the entries (see the review).
- Font: EB Garamond (vendored) instead of Times New Roman. No verified rule names a font.
- No proposed order (the exemplar's ECF Doc. 16 ends with one, and the Tether memorandum has a table of authorities).
- The signature block carries one signer (Lewis R. Clayton). The exemplar also has the MoloLamken and Kaplan Rice signatures.
- The sample is an excerpt (the rest of the argument is not transcribed), so the overlay compares partial pages.
- Type size and spacing rest on the exemplar and on the origin rule (SDNY Civil Rule 11.1), not on fetched text. Judges'
  chambers rules were not checked.
- Tier 2 asks for 2-3 filers: two memoranda are in `exemplars/` (Debtors, Tether). The template is built from the first.

## BLOCKED

Not blocked for the motion memorandum. The verification gap on type size and spacing (SDNY Civil Rule 11.1 and the judges'
chambers rules were not retrieved) bears on tier 1 and should be checked before landing.
