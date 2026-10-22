# Motion brief (memorandum supporting a motion in an adversary proceeding): Bankruptcy Court, D. Del.

Court: United States Bankruptcy Court for the District of Delaware (`deb`). Path: `courts/third-circuit/delaware/federal/bankruptcy-district/motion-brief/`.

**Status: Times New Roman 12 pt (LR 7007-2(a)(ii)), vendored, in typst and docx alike; both on the shared cross-engine layout model (fb-595.68.34): the docx breaks every line and page where typst does (XENG-001..003 gated).** Every page (12, both engines) was reviewed. The overlay below is from an earlier render (see "Overlay"). The exemplar is a filed motion memorandum from this court, so the template is built for the adversary-proceeding motion route, not the main-case notice-of-motion route.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Memorandum of Law in Support of Defendant's Motion to Dismiss the Complaint, Adv. Pro. No. 19-51146 (LSS), filed 02/17/2020 by Bumble Bee Foods, LLC. 14 pages. Source and search record: `usage/SOURCE.md`.
- The sample transcribes the full memorandum (`usage/INPUT-motion-brief.md`), including the cover and counsel block, the TOC and TOA sections, all argument headings, the block-quoted transcript, footnotes 1–7, the conclusion, and the signature.

## Governing rules (verified 2026-10-14)

| Rule | Source | What the template does |
|---|---|---|
| Del. Bankr. L.R. 7007-1 | Local Rules (effective Feb. 1, 2025): https://www.deb.uscourts.gov/sites/deb/files/Local_Rules_2025%20%28Clean%29.pdf (fetched and read from the saved copy) | A motion in an adversary proceeding gets no notice of motion; the opening brief is filed with the motion. The template renders a brief, not a notice. |
| Del. Bankr. L.R. 7007-2(a)(i) | same | Cover shows the caption, the title, the date of filing, the party designation, and counsel (name, address, phone, email, Delaware bar number). The template renders all of these from frontmatter. **Email is not on the exemplar's cover; see gaps.** |
| Del. Bankr. L.R. 7007-2(a)(ii) | same | Double-spaced; Courier New or Times New Roman; at least 12-point; side margins at least 1 inch. Double spacing (a 24 pt pitch), 12 pt, 1 inch margins and Times New Roman (vendored, `docs/FONTS.md`) are implemented. Courier New is not used. |
| Del. Bankr. L.R. 7007-2(a)(iv) | same | Opening brief at most 30 pages, excluding tables. The brief is numbered from 1 after the tables (i, ii); the sample's brief is 9 pages; the template does not count pages. |
| Del. Bankr. L.R. 7007-2(b)(i) | same | Contents in order: TOC; TOA; nature and stage; summary of argument; statement of facts; argument; short conclusion. The TOC is generated with page numbers. The order is set by the sample, not enforced. |
| Del. Bankr. L.R. 9004-1(a) | same | Caption names the debtor, the case number, the judge's initials, and the adversary number. The caption block renders these from frontmatter. |
| Fed. R. Bankr. P. 9004(a), (b) | https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14) | Legible; caption includes the court, the title, the case and adversary number, and a designation of the document. |
| Fed. R. Bankr. P. 7010 | https://www.law.cornell.edu/rules/frbp/rule_7010 (verified 2026-10-14; the fetch tool quotes the rule as: Fed. R. Civ. P. 10 applies, "except that a pleading's caption must substantially conform to the appropriate version of Form 416") | Caption follows the Form 416 layout (party block left, numbers right). This applies to pleadings; the template uses it for briefs as the exemplar does. |
| Del. Bankr. L.R. 7007-2(b) / Fed. R. Bankr. P. 7012(b), 8002(a) | cited within the exemplar; not separately verified | Not templated beyond the TOC. |

The local rules PDF was fetched through the fetch tool, which saved it locally; the text was extracted with `pdftotext`. The court's own URL is rejected to curl (a WAF response), so the fetch-tool copy is the verified source.

## Layout

- `typst/main.typ` (entry point), `typst/deb-motion-brief.typ` (template). Parameters at the top of the template, each with its rule.
- `usage/INPUT-motion-brief.md`: frontmatter (caption, title, party designation, date, counsel, signature blocks) plus the body in markdown. Footnotes use markdown `[^n]`; headings: `#` centred section, `##` argument heading, `###` table of authorities (centred, on a page of its own, listed in the TOC with its roman page). The markdown before the first `#` heading is the front matter.
- `usage/OUTPUT-motion-brief.typst.pdf`, `.docx` and `.docx.pdf`: 12 pages each. `OVERLAY-` files are written to the gitignored `.overlay/` (see Overlay).

## Overlay (red = ours, blue = filed)

**Not regenerated.** The table below is from an earlier 11-page EB Garamond render and no longer matches `OUTPUT-motion-brief.typst.pdf`. Re-run `just overlay <dir>`.

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

Word overlap is a pairing aid, not a score. The overlay is a diagnostic for the body text and argument order; it does not measure layout, and the pages were reviewed visually instead.

## Pages reviewed (Gate 2 record, all 12 pages on each engine, rendered at 45 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 325/325).

| Page | What it is | Finding |
|---|---|---|
| cover (no number) | Court line, the two Form 416 captions, title, party designation, "Dated:" beside the counsel block | OK: each party column ruled at its right and foot, the rule the height of the taller column; designations set right; counsel below the title, as in both exemplars. |
| i | Table of contents | OK: the table of authorities (ii) and the brief's headings with their pages after a dot leader; level-2 rows half an inch in, their later lines hanging. |
| ii | Table of authorities | OK: on a page of its own, as in both exemplars. |
| 1 | Nature and stage; footnotes 1 and 2 | OK. |
| 2 | Statement of facts; footnote 3 | OK. |
| 3 | Facts (cont.) | OK: "¶¶ 381-84" kept with its number. |
| 4 | Argument; heading I (two lines, the second hanging); footnote 4 | OK. |
| 5 | Argument I (cont.); footnotes 5 and 6 | OK. |
| 6 | The block-quoted transcript; footnote 7 | OK: single spaced, half an inch in on both sides, a blank single line between its paragraphs. |
| 7 | Quotation (end); argument I (end); heading II | OK. |
| 8 | Argument II | OK. |
| 9 | Conclusion; signature block | OK: the conclusion kept on the page with the signature; "Dated:" and the place at the left. |

No open tier-2 finding. Changes in this pass: the cover is unnumbered, the contents and authorities numbered i, ii and the brief from 1 (as in both exemplars; LR 7007-2(a)(iv) counts the brief's pages without the tables), each table on a page of its own; the contents list the table of authorities (both exemplars do); the counsel block follows the title (it was set at the foot of the cover); headings bold at the type size on the double pitch (were typst's heading sizes with 16 pt above and below); the block quotation's paragraphs a blank single line apart; footnotes at 12 pt in both engines (were 10 pt in the docx).

## Known gaps

- **Overlay not regenerated.** See "Overlay".
- **Counsel email (LR 7007-2(a)(i)).** The exemplar's cover has no email addresses, but the rule requires them. The template renders what the frontmatter gives, so a real filing sample must supply emails. The sample leaves them out because the exemplar does.
- **TOA.** Typed as text in the sample, not generated from citations. Citations and their page numbers are not checked by the template.
- **Signature placement.** The signature block is kept whole and on one page with the last paragraph.
- **Page limit.** The 30-page limit (LR 7007-2(a)(iv)) is not checked.
- **Footnotes are single spaced** at 12 pt. LR 7007-2(a)(ii) says "All filings must be double-spaced"; footnotes are conventionally single spaced, as in both exemplars. A reading, recorded here.
- Not checked: Fed. R. Bankr. P. 7012(b) and 8002(a) (cited in the exemplar, not templated).

[Court README](../README.md) | [Adversary complaint](../adversary-complaint/README.md)

## Engines

Engine status: typst `OUTPUT-motion-brief.typst.pdf`; docx `OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice), 12 pages each, every line and page as typst (XENG-001..003 gated, `eval.yaml`); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ`: a 24 pt body pitch (double spaced), 14 pt single lines (court line, captions, title, counsel, quotations, contents, footnotes, signature, footer), explicit block spaces; the contents as `listing-row` rows from the heading locations.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; footnotes in 14 pt boxes, 7 pt after, with a 4-twip right indent: LibreOffice sets a footnote line about 0.15 pt narrower than typst, and footnote 7 filled its line to within that; "Body Text Keep" and "Quotation") and `docx/deb-motion-brief.lua` (on `lib/docx/xengine.lua`): the cover, the contents with their page numbers from `fb render`'s passes (needles: the contents' heading, the table of authorities, each body heading with the words after it; lower roman from the contents, arabic from the first body heading; was a TOC field with no page numbers), the headings, the signature block, the footers (a centred PAGE field, an empty one for the cover; `$FORMBOOK_FOOTERS`) and the three sections (`$FORMBOOK_FINAL`). Paragraphs and quotations are written by pandoc, so footnotes are Word footnotes. No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and a committed `reference.docx`). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none.
