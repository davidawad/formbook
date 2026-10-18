# Motion brief (memorandum supporting a motion in an adversary proceeding): Bankruptcy Court, D. Del.

Court: United States Bankruptcy Court for the District of Delaware (`deb`). Path: `courts/third-circuit/delaware/federal/bankruptcy-district/motion-brief/`.

**Status: typeface set (Times New Roman, via the vendored substitute Liberation Serif).** The render succeeds with zero typst warnings and every page (12) was reviewed. The overlay **did not run**: the exemplar PDF is not in `usage/` on this box (only `SOURCE.md`), so `OVERLAY-bumble-bee-motion-brief.pdf` was not regenerated and the `.txt` shown below is from the earlier EB Garamond render. See "Known gaps". The exemplar is a filed motion memorandum from this court, so the template is built for the adversary-proceeding motion route, not the main-case notice-of-motion route.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Memorandum of Law in Support of Defendant's Motion to Dismiss the Complaint, Adv. Pro. No. 19-51146 (LSS), filed 02/17/2020 by Bumble Bee Foods, LLC. 14 pages. Source and search record: `usage/SOURCE.md`.
- The sample transcribes the full memorandum (`usage/INPUT-motion-brief.md`), including the cover and counsel block, the TOC and TOA sections, all argument headings, the block-quoted transcript, footnotes 1–7, the conclusion, and the signature.

## Governing rules (verified 2026-10-14)

| Rule | Source | What the template does |
|---|---|---|
| Del. Bankr. L.R. 7007-1 | Local Rules (effective Feb. 1, 2025): https://www.deb.uscourts.gov/sites/deb/files/Local_Rules_2025%20%28Clean%29.pdf (fetched and read from the saved copy) | A motion in an adversary proceeding gets no notice of motion; the opening brief is filed with the motion. The template renders a brief, not a notice. |
| Del. Bankr. L.R. 7007-2(a)(i) | same | Cover shows the caption, the title, the date of filing, the party designation, and counsel (name, address, phone, email, Delaware bar number). The template renders all of these from frontmatter. **Email is not on the exemplar's cover; see gaps.** |
| Del. Bankr. L.R. 7007-2(a)(ii) | same | Double-spaced; Courier New or Times New Roman; at least 12-point; side margins at least 1 inch. Double spacing, 12 pt, 1 inch margins and the typeface are implemented: Times New Roman is set as its metric-compatible substitute, Liberation Serif (`docs/FONTS.md`). Courier New is not used. |
| Del. Bankr. L.R. 7007-2(a)(iv) | same | Opening brief at most 30 pages, excluding tables. The sample is 11 pages; the template does not count pages. |
| Del. Bankr. L.R. 7007-2(b)(i) | same | Contents in order: TOC; TOA; nature and stage; summary of argument; statement of facts; argument; short conclusion. The TOC is generated (see the TOC note below). The order is set by the sample, not enforced. |
| Del. Bankr. L.R. 9004-1(a) | same | Caption names the debtor, the case number, the judge's initials, and the adversary number. The caption block renders these from frontmatter. |
| Fed. R. Bankr. P. 9004(a), (b) | https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14) | Legible; caption includes the court, the title, the case and adversary number, and a designation of the document. |
| Fed. R. Bankr. P. 7010 | https://www.law.cornell.edu/rules/frbp/rule_7010 (verified 2026-10-14; the fetch tool quotes the rule as: Fed. R. Civ. P. 10 applies, "except that a pleading's caption must substantially conform to the appropriate version of Form 416") | Caption follows the Form 416 layout (party block left, numbers right). This applies to pleadings; the template uses it for briefs as the exemplar does. |
| Del. Bankr. L.R. 7007-2(b) / Fed. R. Bankr. P. 7012(b), 8002(a) | cited within the exemplar; not separately verified | Not templated beyond the TOC. |

The local rules PDF was fetched through the fetch tool, which saved it locally; the text was extracted with `pdftotext`. The court's own URL is rejected to curl (a WAF response), so the fetch-tool copy is the verified source.

## Layout

- `typst/main.typ` (entry point), `typst/deb-motion-brief.typ` (template). Parameters at the top of the template, each with its rule.
- `usage/INPUT-motion-brief.md`: frontmatter (caption, title, date, counsel, signature blocks) plus the body in markdown. Footnotes use markdown `[^n]`; headings: `#` centred section, `##` argument heading, `###` table of authorities (centred, kept out of the TOC).
- `usage/OUTPUT-motion-brief.typst.pdf`: render (12 pages, Liberation Serif embedded; was 11 pages in EB Garamond). `usage/OVERLAY-bumble-bee-motion-brief.pdf` and `.txt`: overlay (not regenerated; see Overlay).

Naming: the brief asks for `usage/<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, and the overlay reads the `OUTPUT-` name. The tool names are used so the overlay runs unmodified.

## Overlay (red = ours, blue = filed; `OVERLAY-bumble-bee-motion-brief.txt`)

**Not regenerated.** `tools/overlay.sh` exits 1 here: `usage/` has no `SAMPLE-*.pdf` (only `SOURCE.md`), and the RECAP download in `SOURCE.md` returned an error page, not a PDF. The table below is from the earlier 11-page EB Garamond render and no longer matches `OUTPUT-motion-brief.typst.pdf`. Re-run `sh tools/overlay.sh` once the exemplar is in place.

Old page map (EB Garamond, 11 pages), our page to filed page, by word overlap:

| Ours | Filed | Overlap |
|---|---|---|
| 1 | 1 | 51.4% |
| 2 | 2 | 82.8% |
| 3 | 3 | 52.4% |
| 4 | 6 | 54.9% |
| 5 | 7 | 68.2% |
| 6 | 8 | 83.2% |
| 7 | 9 | 76.6% |
| 8 | 10 | 55.0% |
| 9 | 12 | 54.5% |
| 10 | 13 | 61.9% |
| 11 | 14 | 59.1% |

Word overlap is a pairing aid, not a score. The pairing is by shared words, so the filed page it picks is not always the page our render corresponds to: our pages 4–11 pair with filed pages 6–14, and the sample's pagination differs from the filed one. Pages 2 and 6 match best. The overlay is a diagnostic for the body text and argument order; it does not measure layout, and the pages were reviewed visually instead.

## Pages reviewed

Re-reviewed after the typeface change (Liberation Serif, 12 pages): all 12 pages rasterised at 60 dpi and viewed. Cover (1), TOC (2), TOA and nature-and-stage (3), facts (4–6), argument I (7–9), argument II and conclusion (10–11), signature block alone (12). Pagination moved by about a page because Times New Roman at 12 pt is wider than EB Garamond; the TOC page numbers are generated and match the new layout.

Earlier review (EB Garamond, 11 pages). Fixes made along the way:
- Paragraph overlap: the body used zero paragraph spacing, so the 1.35em leading did not carry across paragraph breaks. Fixed with `spacing: body-leading` in the body styles.
- The TOC was a paragraph list with no page numbers. Replaced with a generated `outline()` over levels 1–2.
- A level 2 heading ("I. Plaintiff's Claims ...") ran into the paragraph below it. Fixed with a below-spacing of `body-leading`.

Pages 1–11 as reviewed in the final render: cover (1), TOC (2), table of authorities and the start of the nature-and-stage section (3), facts (4–5), argument I (6–9), argument II and conclusion (9–10), signature block (11). The signature block lands alone on page 11, which is a layout choice; the Conclusion sits on page 10.

## Known gaps

- **Typeface: Times New Roman → Liberation Serif (visual and metric check).** LR 7007-2(a)(ii) names Times New Roman, set here through Liberation Serif, the metric-compatible substitute in `docs/FONTS.md`. Metric compatibility is the upstream claim, not checked on this box (no Times New Roman file). The page count rose from 11 to 12 with the change; the rule is the reason, not a defect.
- **Overlay not run (exemplar missing).** See "Overlay". The exemplar PDF must be restored to `usage/` before the overlay can be regenerated.
- **Counsel email (LR 7007-2(a)(i)).** The exemplar's cover has no email addresses, but the rule requires them. The template renders what the frontmatter gives, so a real filing sample must supply emails. The sample leaves them out because the exemplar does.
- **TOC.** Generated from levels 1–2, so the TOA is not listed. LR 7007-2(b)(i)(A) asks for a TOC of the body's headings; the TOA heading is a section of its own and is left out. Minor.
- **TOA.** Typed as text in the sample, not generated from citations. Citations and their page numbers are not checked by the template.
- **Signature placement.** The signature block is kept whole and can land on its own page (here page 11).
- **Page limit.** The 30-page limit (LR 7007-2(a)(iv)) is not checked.
- Not checked: Fed. R. Bankr. P. 7012(b) and 8002(a) (cited in the exemplar, not templated).

[Court README](../README.md) | [Adversary complaint](../adversary-complaint/README.md)

## Engines

- **typst** (primary, `typst/`): the reference for the form. Rendered sample: `usage/OUTPUT-motion-brief.typst.pdf`.
- **latex**: not built (`latex/` is empty).
- **docx** (`docx/`): `build-reference.sh` makes `docx/reference.docx` from pandoc's default reference: Times New Roman 12 pt (LR 7007-2(a)(ii)), double spacing (Word "double", line 480 auto), 0.5 in first-line indent on body text, 1 in margins on letter paper, centered PAGE number in the footer, black bold headings (level 3 in capitals), 10 pt single footnotes, and the paragraph styles "Centered", "CenteredBody" and "Single". `docx/deb.lua` builds from the frontmatter the cover (court line, Form 416 caption, title, party designation, date and counsel), the table of contents, the body and the signature block. Build: `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/deb.lua usage/INPUT-motion-brief.md -o usage/OUTPUT-motion-brief.docx`.
- **docx: matches** the typst form: page size and margins, the face and size, the first-line indent, the block quotes single-spaced and indented, the caption layout, the centered headings, the page-number footer, footnotes at the end of each page, the table of authorities as typed text (as in typst).
- **docx: differs**:
  - Line pitch. The typst body pitch is 24.06 pt for 12 pt type (measured on page 4 of `OUTPUT-motion-brief.typst.pdf`). Word's double is two line heights of the font, not measured here. The docx will run longer than the typst pages.
  - Table of contents: a TOC field over levels 1 and 2, with its entries cached but no page numbers. Word or LibreOffice shows the page numbers after the field is updated (select all, F9). The typst contents page carries page numbers.
  - The date and the counsel block sit at the foot of the cover as two frames anchored to the bottom margin. This is a Word frame placement; it was not checked in LibreOffice.
  - The table of authorities is typed text with no page numbers, as the typst sample is.
  - The face is Times New Roman; typst renders the metric-compatible Liberation Serif. A Word user has Times New Roman; a LibreOffice user needs a metric-compatible face for the same line breaks.
  - The `.docx` has been checked as a zip and as well-formed XML only. It was not opened in Word or LibreOffice (neither is available on the build box).
- **docx BLOCKED.** The court folder has no `checks.yaml` or `rules.md`, so no gate check ID is readable here. Every gate measured on the LibreOffice PDF (`usage/OUTPUT-bumble-bee-motion-brief.docx.pdf`) is BLOCKED: Gate 0 (content, italics, footnotes), Gate 1 (rule checks, including the TOC page numbers), Gate 2 (page review of the `.docx.pdf`) and Gate 3 (second sample). Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.
- Pages reviewed: typst 12 of 12 (60 dpi). docx: 0 (the `.docx` pages cannot be rendered on this box).
