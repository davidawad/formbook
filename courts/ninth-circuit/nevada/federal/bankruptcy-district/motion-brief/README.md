# motion-brief: U.S. Bankruptcy Court, District of Nevada

Motion with a memorandum of points and authorities (contested matter, FRBP 9013 motion practice).

## Files

- `typst/main.typ` entrypoint; `typst/nvb-motion-brief.typ` the template (rule-driven, no case text).
- `exemplars/FILED-EXAMPLE-epica-human-health-26-50579-motion-brief.pdf` filed motion, 10 pages, counsel for a petitioning creditor. Source and filer in `exemplars/SOURCE.md`.
- `samples/INPUT-epica-motion-reconsideration.md` transcription of the exemplar (YAML frontmatter for the caption and signature, markdown body).
- `samples/OUTPUT-epica-motion-reconsideration.pdf` our render, 11 pages.
- `samples/OVERLAY-epica-motion-reconsideration.pdf` and `.txt` red/blue overlay against the filed exemplar, with the page map.

## Rules cited

Local Bankruptcy Rules of the District of Nevada, from nvb.uscourts.gov (checked 2026-10-14):

- **LBR 9004(a)(1)**: papers on 8½ x 11 paper; all printing double-spaced; each printed line consecutively numbered in the left margin on each page. Template: 28 numbered lines at a 24 pt pitch, numbers drawn in the margin on every page.
- **LBR 9004(a)(2)**: caption, attorney identification, court title and case name are outside the format; the title page must begin at least 1½ in from the top. Template: first-page content starts at 1.5 in.
- **LBR 9004(b)**: proportional font at least 12 pt; quotations over 50 words indented; pages numbered consecutively; one-sided. Template: EB Garamond 12 pt (the only serif vendored), page number centred in the footer, block quotations indented and single-spaced (quotations are outside the double-spacing rule).
- **LBR 9014(c)(1)**: a motion must state its facts and contain a legal memorandum. The sample does both (summary, jurisdiction, background, argument, conclusion).
- **LBR 9014(e)(1)**: points and authorities in support of a motion are limited to 20 pages including the motion, excluding exhibits, tables and caption. Sample: 11 pages including the signature and certificate, within the limit.
- **LBR 9014(a)(1), (b)(1)**: 28 days' notice of hearing, and the notice of hearing is a separate document from the motion. Not produced by this template (see gaps).
- **LBR 9014(b)(2)(A)**: proof of service showing date, manner and name of the person served, filed within 7 days of the motion. The sample's certificate of service states date and manner (ECF); the separate filing deadline is not a template property.
- **LBR 7008**: consent to entry of a final order (cited by the exemplar's jurisdiction section; the sample reproduces the statement, the template does not check it).

Primary text quoted from the court's pages: `https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9004` and `.../9014`. The local rules index says the set is "IN EFFECT as of January 1, 2021"; check the current PDF before relying on any number.

## Render and overlay

- `sh tools/render.sh <court-dir> samples/INPUT-epica-motion-reconsideration.md` produced `OUTPUT-epica-motion-reconsideration.pdf`: 11 pages, vendored fonts only, no warnings.
- Every render page (1 to 11) was rasterised and viewed. Layout checked: caption and title page, numbered grid, headings, block quotation, signature block, certificate on its own page. Baseline pitch measured with `pdftotext -bbox`: 24 pt on the body and the line numbers start at the same y on page 2.
- `sh tools/overlay.sh <court-dir> epica-motion-reconsideration` produced the overlay and map. Pairing by text: ours p.1 to p.7 pair with filed p.1 to p.7 (word overlap 53% to 86%); ours p.8 to p.11 pair with filed p.7 to p.10 (47% to 68%). The page map is in `OVERLAY-epica-motion-reconsideration.txt`.
- The overlay shows: page 1, the caption and title agree in content but not in position (the filed copy sets counsel above 1.5 in; the template follows LBR 9004(a)(2)); the body text lines up in wording; the grid is ours, not the filed copy's.

## Gaps

1. **Separate notice of hearing and proof of service are not templated.** LBR 9014(a)(1), (b)(1), (b)(2)(A). The motion shows `Hearing Date: TBD`, which is what the exemplar shows; a real filing needs the notice as a second document.
2. **Font.** Filed copy is Times-type; only EB Garamond is vendored and system fonts are banned. Visual difference, same 12 pt size.
3. **Tier-2 conventions not done.** Second-level headings with a letter label wrap flush left, not on a hanging indent (the label is in the heading text, so the template cannot split it). The filed copy's footer firm block and ECF header are not reproduced; the ECF header is a court stamp, not a filer's format.
4. **Pagination.** Ours is 11 pages, filed 10; the body wraps differently, so the overlay pairing drifts after page 7.
5. **Overlay scale defect in the shared tool.** `tools/overlay.sh` reads PNG resolution from pdftoppm's 254 ppi metadata, so the overlay pages come out 240.9 x 311.8 pt instead of letter size. Content is complete and readable at high resolution (checked page 1 at 200 dpi), but the tool should set `-density` from the render or strip the PNG metadata. Out of scope for this court folder; not changed.
6. **Overlay pages 2 to 11** were not viewed; only page 1 was checked at high resolution after generation. The render pages were all viewed.
7. **Check gates not run.** `tools/check.sh` and `check-selftest.sh` are not part of this run (brief: render and overlay only). No tracker, no STATUS, no court.json change.
8. **Transcription.** The sample is the pre-existing transcription from master, with the certificate's `[sig]` markers removed. The body was checked against the exemplar pages during the overlay review; it was not re-typed from scratch.
