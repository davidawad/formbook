# Adversary complaint — United States Bankruptcy Court, D. Idaho (`idb`)

Complete doc-type folder: template, sample, exemplar, render, overlay. Court-level README: [../README.md](../README.md).

## Layout

- `typst/main.typ` entrypoint; `typst/idb-adversary-complaint.typ` template (parameters at the top; each is cited to the rule it follows).
- `samples/INPUT-cutting-adversary-complaint.md` transcribed sample (frontmatter: caption, counsel, lead-in, signature; body: `## ` headings, numbered allegations, `# COUNT` and `# PRAYER` headings, `- ` lettered items).
- `samples/OUTPUT-cutting-adversary-complaint.pdf` our render (9 pages), from `sh tools/render.sh <this-dir> samples/INPUT-cutting-adversary-complaint.md`.
- `samples/OVERLAY-cutting-adversary-complaint.pdf` and `.txt`, from `sh tools/overlay.sh <this-dir> cutting-adversary-complaint`.
- `exemplars/FILED-EXAMPLE-cutting-25-07006-adversary-complaint.pdf` the filed complaint (32 pages); provenance in `exemplars/SOURCE.md`.

## Rules followed (primary sources, fetched 2026-10-14)

- D. Idaho LBR 7003-1, Commencement of Adversary Proceedings [v. 2]: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_7003-1_562.htm?Content_ID=562
  - The bankruptcy case number and the adversary number each carry a three-letter judge suffix (e.g. 25-20068-NGH, 25-07006-NGH). The template asserts this.
  - A complaint starting an adversary proceeding must come with a completed Adversary Proceeding Cover Sheet, the fee, and a summons. **Gap:** the cover sheet and summons are not part of this template.
  - Cites Fed. R. Bankr. P. 7003, 7004, 7007.1, 7010, 9004(b) and Official Form 1040. Rule texts for those were not fetched.
- D. Idaho LBR 5005-1(c), Documents for Filing [v. 3]: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_5005-1_3699.htm?Content_ID=3699
  - Counsel block in the upper left, starting 1 inch from the top; required items: name, ISB number, email, office address, telephone, facsimile, and the party represented.
  - Font 12 to 14 point. The rule names no typeface (checked against the rule text, 2026-10-15), so the template keeps EB Garamond 13 pt; no substitute from `docs/FONTS.md` applies.
  - Caption: "UNITED STATES BANKRUPTCY COURT" / "DISTRICT OF IDAHO", "In re:", debtor, "Debtor" designation, case number and chapter, designation of the paper.
  - The rule does not address margins beyond the top start, line spacing, footers, or signature blocks. Those come from the filed exemplar and the template's defaults (1-inch margins; page number footer).
- Fed. R. Civ. P. 10 (cited in the template header as applicable to the caption): numbered allegations. Text not fetched in this pass.
- Fed. R. Bankr. P. 9004(a)-(b) (legibility, paper size) and 9013/9014 are cited in the motion template; not fetched here.
- Local rules index (all listed rules): https://www.id.uscourts.gov/bankruptcy/forms_fees_rules/Rules.cfm, complete packet: http://www.id.uscourts.gov/content_fetcher/print_pdf_packet.cfml?Court_Unit=Bankruptcy&Content_Type=Rule. The index shows the rules as revised and adopted January 5, 2026; the exemplar was filed December 18, 2025, under the rules in force then. No effective dates appear on the rule pages, so the rule versions here may differ from those in force on 2025-12-18. Verify before relying on a version-specific point.

## What the overlay shows (`samples/OVERLAY-cutting-adversary-complaint.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. The overlay pairs each of our 9 pages with the filed page sharing the most words (`.txt` page map):

| our page | filed page | word overlap |
|---|---|---|
| 1 | 1 | 75.7% |
| 2 | 3 | 55.4% |
| 3 | 4 | 51.8% |
| 4 | 7 | 55.7% |
| 5 | 9 | 53.8% |
| 6 | 12 | 52.4% |
| 7 | 13 | 50.2% |
| 8 | 32 | 54.9% |
| 9 | 32 | 28.7% |

The sample is a portion of the 32-page filing, so pages 8 and 9 do not have a matching filed page; the pairing there is a best guess and the low overlap on page 9 is expected (the prayer and signature). The overlay pairs by word overlap only; it does not check that the caption boxes or margins coincide. Remaining visible differences are typographic (typeface and size against the filed text), so line breaks do not coincide.

## Gaps

- The filed complaint uses bullet points in some allegations (e.g. Count I); the template renders them as lettered items `(a)`, `(b)`, which is a deliberate template choice (lettered is the convention the template uses for lists in pleadings). The filed text does not letter them.
- Count headings are set in bold and centered on two lines; the filed headings wrap at a different point.
- No cover sheet, no summons, no Rule 7007.1 corporate-ownership statement, no consent-to-final-order statement (FRBP 7008(a), LBR 7012-1). None is in the sample; the filed exemplar does not have a consent statement either.
- Second filer: not collected. Tier 2 would be judged against 2 or 3 filers; this folder has one filer (the United States Trustee).
