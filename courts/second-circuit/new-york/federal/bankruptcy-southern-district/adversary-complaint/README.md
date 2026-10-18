# nysb: adversary complaint (typst)

Court: United States Bankruptcy Court, Southern District of New York (`nysb`). Doc type: the complaint that starts an
adversary proceeding (Fed. R. Bankr. P. 7001). Engine: typst only, as the brief asked (`typst/`).

## Governing rules (verified 2026-10-14 unless marked)

| Requirement | Text relied on | Source | Verified |
|---|---|---|---|
| Caption of an adversary pleading | Fed. R. Civ. P. 10 applies, "except that a pleading's caption must substantially conform to the appropriate version of Form 416" | Fed. R. Bankr. P. 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 (amended eff. Dec. 1, 2024) | yes (fetched) |
| Caption layout | Official Form 416D, "Caption for Use in Adversary Proceeding": United States Bankruptcy Court; In re (Debtor); Plaintiff; Defendant; Case No.; Chapter; Adv. Proc. No.; title "COMPLAINT [or other designation]" | Official Form B 416D (12/15), https://www.uscourts.gov/file/18775/download | yes (fetched, read) |
| Typeface | No face named. Fed. R. Bankr. P. 9004 and LBR 9004-1 name none; SDNY Local Civil Rule 7.1(b) (which replaced 11.1, as seen in a 2026 search, not fetched from the court) sets 12-point type, double spacing and 1-inch margins and names no face. Kept EB Garamond (`font-family`), the vendored default in `docs/FONTS.md`. The exemplars are set in Times New Roman, which the rules do not require | Fed. R. Bankr. P. 9004; LBR 9004-1; SDNY Local Civil Rule 7.1(b) | rules: no face named; the face is a convention, not a rule |
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
  Chapter / Case No. / Adv. Pro. No. right); "COMPLAINT"; the debtors' footnote as in the exemplar. The cover carries no
  page number, and the body restarts at 1 after it.
- Body: numbered paragraphs (FRCP 10(b)). Level-1 headings are centered bold capitals. Level-2 headings are lettered (A., B.)
  by the template. Lists become (a), (b) ... with their markdown numbers kept.
- Markdown contract: a chunk marked `^` is an unnumbered paragraph (the prayer's WHEREFORE clause); footnote definitions are
  not paragraphs; the last item of the body sticks to the signature block, so a signature never stands alone.
- Signature block: "Dated:", "/s/" signer, firm and address lines (single-spaced).
- Measured exemplar values: pitch 27.6 pt (double), margins 72 pt, 12 pt type (`pdftotext -bbox`, Celsius p.8).

## Files

- `usage/SAMPLE-nysb-adversary-complaint-celsius2404018.pdf` (primary, Quinn Emanuel for the Post-Effective Date
  Celsius Debtors, filed Aug. 9, 2024) and `usage/SAMPLE-nysb-adversary-complaint-ehrenfeld1901128.pdf` (second
  filer, the NY Attorney General for The Lawyers' Fund, filed May 3, 2019, 4 pages). See `usage/SOURCE.md`.
- `usage/INPUT-nysb-adversary-complaint-celsiuscomplaint.md`: transcribed from the primary exemplar: the caption and counsel frontmatter, paragraphs
  1-31, the prayer and the first signature group. Not the whole pleading (30 pages).
- `usage/OUTPUT-nysb-adversary-complaint-celsiuscomplaint.typst.pdf`: 11 pages (cover + 10). `usage/OVERLAY-celsius-complaint.pdf` and `.txt`.
- The brief named the sample `usage/<id>.md` and `<id>.pdf`, and `<id>-overlay.pdf`. The repo's tools and file-role names
  (`INPUT-`, `OUTPUT-`, `OVERLAY-`) are used instead, so `tools/render.sh` and `tools/overlay.sh` work unchanged.

## Commands (from the repo root)

    sh tools/render.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-nysb-adversary-complaint-celsiuscomplaint.md
    sh tools/overlay.sh courts/second-circuit/new-york/federal/bankruptcy-southern-district/adversary-complaint celsius-complaint

The render is a clean typst compile with the vendored fonts (no warnings).

## Overlay

`usage/OVERLAY-celsius-complaint.txt` pairs each rendered page with the filed page sharing the most words:

    ours p.1 -> filed p.1 (92.9%)    ours p.2 -> p.2 (74.1%)    ours p.3 -> p.3 (78.8%)    ours p.4 -> p.4 (79.1%)
    ours p.5 -> p.5 (60.7%)          ours p.6 -> p.6 (58.0%)    ours p.7 -> p.7 (63.3%)    ours p.8 -> p.8 (57.6%)
    ours p.9 -> p.9 (69.2%)          ours p.10 -> filed p.29 (46.5%)    ours p.11 -> filed p.30 (35.8%)

Red (ours) and blue (filed) do not coincide line for line. That is expected: EB Garamond against the filed Times New
Roman, and a partial transcription. Pages 10 and 11 are the prayer and signature, which pair with the filed prayer pages 29
and 30. The overlay is a diagnostic, not a score.

## Gate 2: every page rendered at 60 dpi and reviewed

Rendered with `pdftoppm -r 60` and viewed: all 11 pages.

- p.1 cover: counsel, court name, caption, title and the debtors' footnote fit on one page; no spill to page 2.
- p.2: "NATURE OF THE CASE", paragraphs 1-2 (intro unnumbered).
- p.3: paragraphs 3-5. p.4: 6-9. p.5: "THE PARTIES", 10-17 with "JURISDICTION AND VENUE".
- p.6: 18-20. p.7: "FACTUAL BACKGROUND", A., 21-25. p.8: "B. The Token Agreement", 26-29.
- p.9: 30-31 and "PRAYER FOR RELIEF" with the WHEREFORE clause (unnumbered).
- p.10: prayer items (a)-(f). p.11: item (g) and the signature block (sticky to the last item).

Defects found in review and fixed in the template:
1. Paragraph blocks overlapped the next block (about one line) because typst puts no leading after a block's last line.
   Fixed: every body block has `below` equal to one leading.
2. Numbers are a plain count in the loop, not a counter. (Earlier I suspected `context` as the cause of the overlap; it was item 1.)
3. Footnote definitions printed as numbered paragraphs (33, 34). Fixed: skipped.
4. The WHEREFORE clause was numbered. Fixed: `^` marks an unnumbered paragraph.
5. The signature block stood alone on a page. Fixed: the last item sticks to the signature (the list is split so that only
   the last item moves).

Open in the render: none that is visible at this resolution. The overlay is not a score.

## Known gaps (tier 2 and beyond; not tier 1)

- Font: EB Garamond (vendored) instead of Times New Roman. No rule in the verified text names a font.
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

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` (EB Garamond 12 pt, exact 27.6 pt double spacing, exact
13.8 pt single spacing for the counsel block, caption, signature and footnotes at 11 pt, 1 in margins, letter, PAGE footer);
`docx/nysb-adversary-complaint.lua` builds the cover (counsel, court title, Form 416D caption as a table with a right and a bottom
rule, title), a section break (no page number on the cover, body from 1), numbered paragraphs, lettered (a) to (g) prayer items,
and the signature block, which keeps with the last item. Rendered with `tools/render.sh --engine docx`: 11 pages, all 11 viewed
side by side with the typst reference (`/work/artifacts/nysb/adversary-complaint/pair-NN.png`).

- Matches typst: type face and size, double and single spacing, margins, cover layout (one page), the body restart at 1, the
  paragraph numbering, the heading sizes (level 1 at 17 pt, level 2 at 14.5 pt, as typst's default heading sizes), page breaks
  within about one line of the typst pages.
- Differs: headings and paragraph labels (A., 1.) are typed text, not Word numbering; the caption rules are paragraph borders
  inside the caption table (LibreOffice draws them at the same places as the typst rules); line-level pagination can differ by a
  line from Word.
- Body footnotes: the typst render prints no text for the body footnotes (`[^2]`, `[^3]` of the Celsius sample): the typst
  template drops footnote definitions. The docx prints them. This is a typst defect, not a docx difference.
- The `.docx` opens in LibreOffice with no repair prompt (the conversion ran without errors; `unzip -t` and `xmllint` pass on the parts).
- BLOCKED, docx gates not run: `tools/check.sh` needs `court.json` and `checks.yaml` in the court root (for Gate 1) and the
  court root has no `checks.yaml` (and no `rules.md`), so no docx check ID could be run and no stamp was written. Gate 2 for
  docx is not recorded.
