# D.R.I. (rid): motion-brief (motion to dismiss with memorandum)

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the District of Rhode Island (`rid`).
Folder: `courts/first-circuit/rhode-island/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, 14 pages, memorandum ECF No. 7; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole memorandum (introduction, facts, standard of review, argument with its four numbered sub-headings, conclusion), the five footnotes, the signature block and the certificate of service. Converted from the text layer and corrected by hand. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 15 pages, typst 0.15.0, Times New Roman only (`pdffonts`), no warnings |
| overlay | ok: `usage/OVERLAY-tablada-motion-brief.pdf` and `usage/OVERLAY-tablada-motion-brief.txt` |
| pages reviewed | 14 of 14 on the earlier EB Garamond render, before fb-595.68 (every page rendered at 60 dpi and viewed) |

## Governing rules

Primary sources, fetched 2026-10-14:

- D.R.I. Local Rules, "As Amended through April 1, 2024" (the court's posted "Approved Dec 2024 Rules" PDF), https://www.rid.uscourts.gov/sites/rid/files/documents/Approved%20Dec%202024%20Rules.pdf. LR Cv 5 (form of papers), LR Cv 7 (motions and other papers).
- Fed. R. Civ. P. 7(b)(1)-(2), 12(b)(6), 8(a)(2), 10 (as used for captions), from https://www.law.cornell.edu/rules/frcp/rule_7 and `rule_12`.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR Cv 5(a) | 8 1/2 by 11 inch paper. | `page-w`, `page-h`. |
| LR Cv 5(a)(1) | Full caption, names of all parties; filings after docketing carry the case number and the judge's initials. | `caption()`; `case_number: 1:26-cv-00118-MSM-AEM` in the sample. |
| LR Cv 5(a)(2) | Title stating the nature of the document and the filer. | `brief_title`: "MEMORANDUM IN SUPPORT OF DEFENDANT, ROCKET MORTGAGE, LLC'S MOTION TO DISMISS". |
| LR Cv 5(a)(3) | Double-spaced, at least 12-point type; footnotes at least 10-point, may be single-spaced. | `pitch-double = 27.6pt`, `type-size = 12pt`, `footnote-size = 10pt` with single spacing (`show footnote.entry`). Pitch as measured on both exemplars (see complaint README). |
| LR Cv 5(a)(3) | Pages numbered bottom center. | `set page(numbering: "1")`. |
| LR Cv 5(a)(5) | Signature block: name, address, telephone, bar number, firm, email. | `signature`: `party`, `lead`, `signers` (name and bar), `firm`. |
| LR Cv 7(a)(2)(A) | A motion states with particularity the grounds, the relief, and the legal argument. | Author content (this memorandum carries the argument). |
| LR Cv 7(a)(2)(B) | A memorandum of law is an attachment to the motion, not a separate docket entry. | Not enforced by the template (filing workflow). See Known gaps 2. |
| LR Cv 7(c) | Motions and responses state whether oral argument and/or an evidentiary hearing is requested, and the estimated time. | `oral_argument` (required; the build fails without it). Printed as "Statement on oral argument." before the signature. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order is made by motion, in writing, stating the grounds with particularity and the relief sought. | Author content; the template does not check it. |
| Fed. R. Civ. P. 7(b)(2) | The rules on captions and other matters of form apply to motions and other papers. | The caption and signature rules above apply to this memorandum. |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim upon which relief can be granted: the motion the memorandum supports. | `brief_title`, the introduction. |

## Layout

- Court title and caption as in the complaint (`complaint/README.md`), with the judge's initials in the case number.
- Title centered bold, then body: first-line indent 0.5 inch, paragraphs not numbered (a memorandum is not a pleading), double-spaced.
- Headings: level 1 is centered bold capitals with an automatic roman numeral (I. INTRODUCTION); level 2 is bold, left, with an automatic letter (A. Tablada's Mortgage); level 3 is bold, left, as written (the argument's "1. The Complaint..." keeps its typed number). Headings are sticky.
- Block quotations: indented 0.5 inch on both sides, double-spaced.
- Footnotes: markdown `[^n]` references and `[^n]: text` definitions. The template renders each paragraph with the definitions it refers to, so every reference becomes a typst footnote in 10-point single-spaced text.
- Signature: "Dated:" from `date` in the left column; the lead line ("Respectfully submitted by,"), party lines, the signer with "/s/" and bar number, firm block.
- Certificate of service: its own heading, the text from `certificate_of_service.text`, and the signer's "/s/" line under the signature column.
- Margins: 1 inch all round (convention; no D.R.I. margin rule).

## Markdown contract

- Frontmatter: `case_number`, `caption.parties`, `brief_title`, `jury_demand`, `date`, `oral_argument` (`requested`, optional `minutes`), `signature` (`lead` optional, `party`, `signers` with `name` and `bar`, `firm`), `certificate_of_service.text`.
- Body: blank-line-separated chunks: `#` (level 1), `##` (level 2), `###` (level 3), `>` (block quotation), a list, or a paragraph. Do not type the numbers of level 1 and 2 headings. Escape a leading `1.`, `2.` etc. in a level-3 heading (`### 1\. The Complaint...`); otherwise it becomes a list. Star pages are escaped (`\*5`, `\*\*\*`).
- Italics: the text layer of the exemplar carries no italic markup. The sample italicizes only a few short forms (*Id.*, *Iqbal*) by hand; the template renders whatever is marked.

## Measured line pitch

As the complaint: 27.6 pt baseline pitch on the exemplar (Tablada, page 3: 72.49, 100.09, 127.69; `pdftotext -bbox-layout`). The template matches it.

## What the overlay shows

`usage/OVERLAY-tablada-motion-brief.pdf` (measured on the earlier 14-page EB Garamond render, before fb-595.68): each page of our render in red over the filed page it matches best, in blue; black is agreement. The pairing is by word overlap and is in `OVERLAY-tablada-motion-brief.txt`. Pages 1 to 11 pair one to one with per-page word overlap of 48% to 90%. Pages 12 and 13 pair with filed pages 13 and 14, and our page 14 (the certificate of service on its own) pairs with the filed page 14, which also carries the end of the conclusion; the lower overlap there is pagination, not missing text. The overlay is a diagnostic, not a score.

## Review log (Gate 2)

Every page was rendered at 60 dpi and viewed, on the earlier 14-page EB Garamond render, before fb-595.68. Findings:

| Page | Finding | Action |
|---|---|---|
| 1 | Caption, title, first paragraphs and first footnote correct. | none |
| 2-6 | Level 1 and 2 headings auto-numbered (I., II., A., B., C., D.), footnotes 2 to 4 in 10-point at the foot of the page. | none |
| 7 | The argument's "1. The Complaint..." sub-heading rendered as a markdown list (hanging indent). | Fixed in the sample: escaped the marker (`### 1\.`). Re-viewed after the fix: bold heading, no hanging indent. |
| 8-9 | Block quotation (indented both sides) and footnote 5 correct. | Re-viewed after the final render. |
| 9, 11, 12 | Sub-headings 2, 3 and 4 had the same list rendering before the escape. | Fixed with the same escape. Re-viewed: bold headings. The "Woel \*\*\*" text on page 10 is intact. |
| 13 | Conclusion, "Statement on oral argument", "Dated:" and the signature block. The lead line was missing. | Fixed: `signature.lead` ("Respectfully submitted by," as in the exemplar). Re-viewed. |
| 14 | Certificate of service, text and "/s/" signer. | none |
| 1-6, 10 | Headings I., II., III., IV. and A.-D. auto-numbered; footnotes 1 to 4 at the foot of their pages. | none |

OPEN: none in the template.

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for 2 or 3 filers. The search also found a supporting memorandum attached to a motion to dismiss in *United States v. Amore* (1:25-cv-00639, RECAP attachment, 50 pages). Not downloaded or checked for layout.
2. **Rule against the exemplar.** LR Cv 7(a)(2)(B) says a memorandum "must be served as an attachment to the motion and not as a separate docket entry". The exemplar was filed as its own entry (ECF No. 7). The rule governs; the template produces the memorandum as a document that can be attached. Who files it as an attachment is a filing decision, not a template one. Flagged for David.
3. **Oral argument statement.** LR Cv 7(c) requires the statement in motions and responses. The exemplar memorandum has none (the motion carries it). The template prints the statement from `oral_argument`. The sample's value ("not requested") is a placeholder, not a fact from the exemplar.
4. **Page limit.** No page limit was found in the text of LR Cv 7 or LR Cv 5 as posted. Individual judges' practices were not checked. The template has no page check. The sample is 15 pages (14 on the earlier EB Garamond render); the exemplar is 14.
5. **Caption rule.** The party column is closed by a rule; the exemplar uses a ")" column. Recorded as a tier-2 choice.
6. **Font.** LR Cv 5(a)(3) names no typeface (same check as the complaint, 2026-10-14), so the template is set in Times New Roman, the house standard (`docs/FONTS.md` rule 6, David 2026-10-17), the exemplar's face too; EB Garamond before 2026-10-17 (the docx until fb-595.68.17).
7. **Case names.** Not italicized in the sample (no italic markup in the text layer). A tier-2 gap for filers' italics; the template renders italics when they are marked.
8. **Verbatim errors kept.** The exemplar's "Id..", "form the ECF system", "Respectfully submitted by," and "2018WL" spacing are transcribed as filed.
9. **Certificate placement.** The certificate of service follows the signature block on page 15; the conclusion starts on page 14. The exemplar carries the certificate on its last page with the end of the conclusion. (On the earlier EB Garamond render the certificate fell on page 14 by itself.)
10. **File names.** As in the complaint README: `INPUT-`, `OUTPUT-`, `OVERLAY-` (what `tools/render.sh` and `tools/overlay.sh` read and write).

LOG:
- 2026-10-14: first render, 14 pages; the argument's "1." sub-headings rendered as list items (fixed by escaping), and the lead line was missing from the signature (fixed).

## Engines

**typst** is the reference and is unchanged by the docx work.

**docx** (`docx/reference.xml`, from which `fb render --engine docx` builds the reference document on the shared cross-engine recipe in the typst face; `docx/rid-motion-brief.lua` for the cover, the heading labels, the statement on oral argument, the signature block and the certificate of service; `docx/make-reference.sh` was retired into fb render in fb-595.68.17). Output: `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf` (LibreOffice, 15 pages, as typst). Status: converts without error; XENG-001..003 pass (362/362 lines, fb-595.68.17); every page of the earlier EB Garamond docx PDF was viewed at 60 dpi beside the typst page of the same sample (pages_reviewed = 15). Not opened in Microsoft Word (not available here); the file is a valid zip with well-formed XML parts.

- *Matches typst (checked on the LibreOffice PDF of the earlier EB Garamond docx; the face is now Times New Roman 12 pt on both, the only font embedded):* US Letter, 1-inch margins; double spacing at exact 27.6 pt; footnotes 10 pt, single spaced; block quotations indented 0.5 in on both sides, double spaced; the caption and cover; headings with the typst labels (I. INTRODUCTION centered; A. Tablada's Mortgage at the left; level 3 as written, bold); the statement on oral argument; the signature block with "Dated:", "Respectfully submitted by," and the same gaps as typst (measured on the PDF); the certificate of service on its own last page with its signer line; page number centered at the bottom of every page, arabic from 1.
- *Differs (tier 2, not blocking; seen on the earlier EB Garamond docx and 14-page typst render, not re-checked here; both are 15 pages now):* (a) Pagination: the docx had one page more (15 against 14). The text drifts by a line or two per page because LibreOffice wraps some lines differently; the level 3 heading "1." of the Argument moves to page 8 (keep with next), which leaves about six blank lines at the foot of page 7; the conclusion and signature block fall on page 14 in the docx and page 13 in typst. The certificate is alone on page 15 in the docx and on page 14 in typst. (b) Footnote text wraps slightly wider in LibreOffice than in typst (same 10 pt size and line pitch), so footnote lines differ. (c) Every line sits about 3 pt lower than in the typst PDF (same cause as the complaint). (d) Heading labels are typed text, not Word numbering.
- *BLOCKED:* none. `tools/check.sh --engine docx` now gates the docx on `eval.yaml` (`usage/.check-docx.txt`: PASS). No tier-1 requirement is blocked in docx.
- *Pagination:* Word may paginate slightly differently from LibreOffice (see `docs/DOCX.md`).
