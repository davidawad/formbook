# tnmb: motion-brief

Doc type: **motion brief** (a memorandum of law in support of a motion under FRBP 9013) in the United States Bankruptcy Court for the Middle District of Tennessee (`tnmb`).
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, the defendant; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the full 8-page memorandum with its three footnotes, transcribed from the text layer |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored Times New Roman only, no warnings (`tools/render.sh`) |
| typeface | Rules name no face (LBR 5005-3(a): "All filings shall be clearly legible in 12-point font"). Times New Roman (vendored), the face of the exemplar and the default of docs/FONTS.md; the docx names the same face. |
| overlay | ok: `usage/OVERLAY-nng-mtd-memo.pdf` and `usage/OVERLAY-nng-mtd-memo.txt` (`tools/overlay.sh`) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the tools, not the brief's `<id>.pdf` / `<id>-overlay.pdf`: `tools/render.sh` writes `OUTPUT-<id>.pdf`, `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf` and `.txt`, and the markdown is `INPUT-<id>.md`.

## Governing rules

Primary source: Local Bankruptcy Rules of the United States Bankruptcy Court for the Middle District of Tennessee, "Amended and Restated as of July 28, 2025", https://www.tnmb.uscourts.gov/sites/tnmb/files/tfr/2025_Local%20Bankruptcy%20Rules%20Official_0.pdf (text extracted with `pdftotext` on 2026-10-14). Motion procedure: "LBR 9013-1 Motion Practice Procedures" (7.28.25), https://www.tnmb.uscourts.gov/sites/tnmb/files/tfr/LBR%209013%20Motion%20Practice%20Procedures%207.28.25.pdf (fetched 2026-10-14). Federal rule: Fed. R. Bankr. P. 9013, from https://www.law.cornell.edu/rules/frbp/rule_9013 (fetched 2026-10-14; the page shows no "current as of" date, its latest amendment is effective 2024-12-01).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 5005-3(a) | 8 1/2 x 11 inch; "All filings shall be clearly legible in 12-point font"; one-inch margins throughout. | `page-w`, `page-h`, `margin = 1in`, `type-size = 12pt`; the footnote text is also 12 pt (`show footnote.entry`). |
| LBR 5005-3(b) | All pages sequentially numbered at the bottom, with room for the CM/ECF docket footer. | the page number centered in a 13.8 pt line, `footer-descent: 0.6in` (docx: footer 300 twips). |
| LBR 9004-2(a)(1), (b) | Caption: case number, chapter, judge; adversary number for adversary filings; a title that describes the document. | `caption()`; `title` in the frontmatter. |
| LBR 9013-1 | A request for relief (other than one that requires an adversary proceeding) must be made by written motion, complying with the LBR 9013-1 Motion Practice Procedures. | Not a template element: the motion, the LBR 9013-1 Notice and the proposed order are separate filings (Known gaps 3). |
| LBR 9013-1 Procedures (7.28.25) | The motion, the LBR 9013-1 Notice and the proposed order are filed as one PDF, with the notice first. | Not produced (Known gaps 3). |
| LBR 9013-2 | Briefs or memoranda of law may be submitted on the schedule the rule sets. Citations to Westlaw or Lexis are acceptable if retrievable, otherwise the cited document must be provided. | Content, not layout; the template does not check citations. |
| LBR 9013-3(a), (b) | A certificate of service within 3 business days; it states the manner of service and includes the names and addresses served; a copy of the papers served is attached to the certificate. | `certificate` in the frontmatter (`certificate-block`). The attached copy is not produced (Known gaps 4). |
| FRBP 9013(b) | A motion must state its grounds with particularity and set forth the relief requested. | Content of the motion, not the memorandum; the memorandum states the grounds it argues. |
| LBR 5005-4(c) | Electronic filings are PDF and PDF/A. | Not produced by `tools/render.sh` (Known gaps 6). |

## Layout

- Court title (three centered bold lines), the caption (debtor and parties on the left, a ")" column, case number, chapter, judge and adversary number on the right), then the two-line title of the paper, centered and bold.
- Body double-spaced (24 pt line boxes at 12 pt); paragraphs are not numbered (a memorandum, not a pleading); first-line indent 0.5 inch.
- Level 1 headings (INTRODUCTION AND FACTUAL SUMMARY, ARGUMENT, CONCLUSION) are centered bold caps. Level 2 headings (the A. and B. argument points) are bold and single-spaced, the typed label at the 0.5 inch indent in a half-inch box, the text hanging at 1 inch and stopping 0.5 inch short of the right margin (as filed). Headings stand half a body line from the text on either side.
- Block quotations are single-spaced and indented 0.5 inch from both margins; half a body line around a quotation and between its paragraphs; the paragraph right after a quotation (its citation) starts at the margin, as filed.
- Footnotes at 12 pt, single-spaced, each kept whole on one page. A footnote reference may sit in body text, in a heading, or inside a quotation.
- The last paragraph is kept with the signature block, so a signature never starts a page alone.
- Signature block at 2.5 in, a blank single line below "Respectfully submitted,"; then the certificate of service (its title bold and underlined as filed, the statement single-spaced, each addressee single-spaced at 0.5 in), kept together.

## Markdown contract (for samples)

- YAML frontmatter: `chapter` (string), `case_number`, `judge`, `adv_proc_no`, `division`, `caption` (as the adversary complaint), `title` (list of lines), `signature` (list of lines), and `certificate` (`text` and `recipients`, a list of addressees, each a list of lines).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings; a numbered list (lettered A., B., ...); a block quotation (`>`, the `>` markers are removed and a multi-paragraph quotation keeps its paragraphs); a paragraph. Footnotes: `[^n]` in text, headings or quotations, and `[^n]: text` as a separate chunk at the end (the definitions are collected first).
- Not supported: tables, raw typst.

## Overlay

`usage/OVERLAY-nng-mtd-memo.pdf`: red is our render, blue is the filed exemplar, black is where they agree. `OVERLAY-nng-mtd-memo.txt` maps each of our pages to the best-matching filed page by shared words: ours 1 to filed 1 (65.4%), 2 to 2 (62.5%), 3 to 3 (74.4%), 4 to 5 (52.6%), 5 to 6 (60.5%), 6 to 7 (71.1%), 7 to 8 (73.9%). (Measured on an earlier 7-page EB Garamond render; the render is now 8 pages in Times New Roman, as the exemplar.) The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Font.** The rules name no font family. The exemplar is Times New Roman; the template sets the vendored Times New Roman (docs/FONTS.md), in both engines. The 12-point minimum is met.
2. **One exemplar, one filer.** The brief asks for one exemplar per doc type, so tier 2 (2 or 3 filers) is not met. The companion motion (Doc. 8, 2 pages, same filer) was downloaded and has a text layer but is not saved: the exemplar here is the memorandum, which is the "brief" part of a motion-brief. A second filer for this doc type has not been collected.
3. **Separate filings not produced.** The motion itself, the LBR 9013-1 Notice (the court's form, with the hearing date, the response deadline and the courtroom), and the proposed order are separate filings under LBR 9013-1 and its Procedures. They are not in this template. The Procedures say the three should be filed as one PDF, with the notice first (unless the size dictates otherwise); a filer must assemble that.
4. **Certificate attachment.** LBR 9013-3(b) requires a copy of the papers served to be attached to the certificate. The template produces the certificate text and addressees, not the attachment; the attachment is a filing-level step.
5. **Page limit.** No page limit for memoranda appears in the local rules text (a search of the extracted rules for "page limit" and "twenty-five" found none). The court's Practitioner's Handbook, which the rules point to, was not retrievable (HTTP 404 at the URL tried), The 9013-1 Procedures (read in full) state none. A page limit set by a judge's standing order is not checked, so none is verified.
6. **PDF/A.** LBR 5005-4(c) requires PDF/A. `tools/render.sh` does not pass a PDF standard to typst, so the output is not PDF/A-conformant. A tool-level question for David.
7. **Footnote size.** LBR 5005-3(a) requires 12-point type for all filings. The exemplar's footnotes are visibly smaller than its body text. The template sets footnotes to 12 pt on the literal reading of the rule; the exemplar is a filed document that shows the smaller convention, so this is a tier-1 reading, recorded here so it can be changed if the court's practice differs.
8. **Caption rows.** As in the complaint, each party name must fit one line in the 3.7 inch party column.
9. **Heading style.** The exemplar's sub-headings are bold, with the argument letter at the start; the template matches that. Tier-2 choice; not asserted.
10. **Alignment.** Body text is left-aligned (ragged right). Not asserted.
11. **Gates.** `sh tools/check.sh <this folder>` (typst 9 passed, 0 failed) and `--engine docx` (13 passed, 0 failed, XENG-001..003 gated). `tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has no selftest.

## Searches for the exemplar

- CourtListener REST search API, `type=r`, `court=tnmb`, query `"adversary proceeding" complaint`, filtered for memoranda and motions with a RECAP PDF (the search returned many filings; the memoranda in the Lemeh case and the Hiawatha Manor summary-judgment brief, Adv. Proc. 2:25-ap-90051, were candidates). The Hiawatha brief is a summary-judgment brief in a Chapter 11 adversary, a different motion type, and was not used.
- WebSearch on the court's local rules and the "LBR 9013-1 Motion Practice Procedures" (found the 7.28.25 Procedures PDF used above).
- The memorandum (Doc. 9) and the motion (Doc. 8) in *Lemeh v. No Name Group*, Adv. Proc. 3:25-ap-90071, were both checked for a text layer; both have one.

## Review of the rendered pages (current PDF)

Typst and docx renders viewed page by page at 60 dpi (8 of 8 each, side by side); they are line for line the same.

- Page 1: court title, caption, the two-line title, the opening paragraph, "In support, NNG states as follows:". The INTRODUCTION heading carries footnote 1, which does not fit with it and two lines of text: heading and note move to page 2, leaving white space at the foot of page 1 (ACCEPTED: the keep rule, in both engines).
- Page 2: INTRODUCTION AND FACTUAL SUMMARY with its footnote mark; paragraphs; footnote 1 whole at the foot. Pass.
- Page 3: the rest of the introduction; footnote 2 at the foot. ARGUMENT moves to page 4 with its sub-heading and two lines. Pass.
- Page 4: ARGUMENT; the A. sub-heading (bold, label in a box, text hanging, as filed); the RCS quotation single-spaced and indented; "*Id.* at 225." at the margin. Pass.
- Page 5: argument A; the *Regions Bank* quotation with footnote 3 inside it; footnote 3 at the foot. Pass.
- Page 6: the rest of the quotation (three paragraphs, half a body line apart, the ellipsis paragraph), "*Id.* at 616-17.", the B. sub-heading and argument B. Pass.
- Page 7: the end of argument B with the *Koch Refining* quotation; white space at the foot because CONCLUSION, its paragraph and the signature block are kept together (ACCEPTED: the signature never starts a page alone).
- Page 8: CONCLUSION, its paragraph, the signature block, CERTIFICATE OF SERVICE with the statement and the addressee. Pass.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"), Times New Roman 12 pt on both: 24 pt double body pitch, 13.8 pt single lines (court title, caption, title, headings, quotations, signature, certificate, footnotes, page number), half a body line around headings and quotations and between a quotation's paragraphs, 12 pt footnotes 7 pt apart, each kept whole on one page. `eval.yaml` sets `params.cross_engine: gate`.

**docx** (`docx/reference.xml`, `base="xengine"` with the face as `{font}`, "Head 1"/"Head 2", "Body Text Note", "Body Flush", "Body Keep"; `docx/tnmb-motion-brief.lua` writes the court title, caption table (one single line per row, the ")" column), title, signature and certificate of service with the typst spacing in twips, and leaves headings (a footnote in a heading stays a Word footnote), paragraphs, quotations and footnotes to pandoc in those styles).

- XENG-001..003 pass: 8 pages, every page end and 219/219 lines as typst.
- Not produced (as in typst): the motion's LBR 9013-1 notice, the proposed order, exhibits.
- BLOCKED: none.
