# waeb: motion-brief

Doc type: **memorandum in support of a motion** (memorandum of law supporting a motion to dismiss) in the United States Bankruptcy Court, Eastern District of Washington (`waeb`).
Folder: `courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `exemplars/FILED-EXAMPLE-1min-25-80007-motion-to-dismiss-memorandum.pdf` (AP Defendants, by Bush Kornfeld LLP, Eisenhower Carlson PLLC and Mayer Brown LLP; Adv. Proc. No. 25-80007, Doc 14, filed 2025-02-19; 42 pages; sha256 `990f5dc6...5e39d`). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-1min-motion-to-dismiss-memorandum.md`: full caption (including the plaintiff list), judge line, counsel block, paragraphs 1 to 24, headings PRELIMINARY STATEMENT, FACTUAL BACKGROUND and A and B, footnotes 1 to 6, signature block. Argument, Conclusion and TOC/TOA are not transcribed (see Known gaps). |
| render | ok: `samples/OUTPUT-1min-motion-to-dismiss-memorandum.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-1min-motion-to-dismiss-memorandum.md`). |
| overlay | ok: `samples/OVERLAY-1min-motion-to-dismiss-memorandum.pdf` and `samples/OVERLAY-1min-motion-to-dismiss-memorandum.txt` (`sh tools/overlay.sh <this dir> 1min-motion-to-dismiss-memorandum`). |
| pages reviewed | 14 of 14 (every page rasterized at 60 dpi and viewed after the last template change, 2026-10-14). |

## Governing rules

Primary source: the Local Rules, Complete Set, for the Eastern District of Washington (https://www.waeb.uscourts.gov/sites/waeb/files/Complete_Set_Local%20Rules_20260717.pdf, fetched 2026-10-14; the same source as the adversary-complaint README). The rule dates are printed on the rule pages.

| Rule | Requirement | Tier | Template |
|---|---|---|---|
| LBR 9004-1(a)(1) (rule dated AUGUST 1, 2020) | Documents prepared letter size. | M | `paper: "us-letter"` (WAEB-MB-FORM-003). |
| LBR 9004-1(a)(3) (same) | Double-spaced; "a proportionately spaced typeface of 14 points or more"; roman type; quoted material may be single spaced, **"however footnotes shall be double-spaced"**; no document may have "an average of more than 280 words per page, including footnotes and quotations". | M | `type-size = 14pt`, `body-leading = 0.94em`, EB Garamond (WAEB-MB-FORM-001, -002). Footnotes use the body leading (WAEB-MB-FORM-003). Words per page on the render (pdftotext, footnotes included): 133 to 271 per page; about 220 per page over all 14 pages; 239 to 271 on the body pages 4 to 13. |
| LBR 9004-1(a)(4) (same) | Title of the Court on or below the fifth line of the first page; signatures as FRBP 9011 requires; names typed under each signature line. | M | `court-heading()` below the counsel block (WAEB-MB-CAP-003); `signature-block()` with the name under each `/s/` line (WAEB-MB-SIG-001). |
| LBR 9004-1(a)(5)(A)-(B) (same) | Right of centre, opposite the caption: case number and related case number above the adversary number; the nature of the document. | M | `caption()`: `related_case`, `adversary_no`, `title` (WAEB-MB-CAP-004). |
| LBR 9004-1(a)(6) (same) | Attorney name, mailing address and telephone on the left side above line five. | M | `counsel-block()`, in columns, above the court title (WAEB-MB-CAP-002). "Line five" is approximated (see Known gaps). |
| LBR 9004-1(a)(7) (same) | Bottom left of each page: abbreviated name of the document, then the page number. | M | Footer `AP DEFENDANTS' MEMORANDUM ISO MOTION TO DISMISS  n` (WAEB-MB-FOOT-001). |
| LBR 9013-1(d)(1) (rule dated AUGUST 1, 2017) | A party files "a brief written memorandum of reasons and a list of authorities on which the party relies" in support of a motion. | M (what the document is) | Doc-type scope. The template does not check the argument. |
| LBR 9013-1(d)(2) (same) | Citations to Washington cases to the Washington Reports; other states to the National Reporter System; federal to the U.S. Reports, Federal Reporter or Federal Supplement; bankruptcy cases to West's Bankruptcy Reporter, Collier's or Bankruptcy Court Decisions. | M | Content of the sample, not the template. Not checked. |
| FRBP 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004) | "A petition, pleading, schedule, or other document must be clearly legible." | M | EB Garamond 14 pt, roman, no fallback font (`fallback: false`). |
| FRBP 9011 (https://www.law.cornell.edu/rules/frbp/rule_9011) | Signature of the attorney; the name, address and telephone number. | M | Signature block (WAEB-MB-SIG-001). |
| FRCP 10(b) as the exemplar follows it (https://www.law.cornell.edu/rules/frcp/rule_10) | Numbered paragraphs. Applies to pleadings, not to a memorandum. | C | Numbered paragraphs by the template (WAEB-MB-BODY-001). The exemplar numbers its paragraphs; this is a convention, not a rule. |

Not produced by this template: the proposed order (LBR 9013-1(c), a separate document), the declarations the memorandum cites (the exemplar cites the Kirschner Declaration), and the certificate of service (see Known gaps).

## Layout

- Page 1: a judge line top right (optional `judge` field); the counsel block in side-by-side columns (one column per firm); the court title; the caption in two columns: debtor on the left with a rule on the right and bottom, the case numbers, the adversary number and the title on the right. The party list (plaintiffs, defendants, intervenor) breaks between parties if it runs over a page; a party never splits across pages.
- Body: numbered paragraphs (1, 2, ...) with a 0.5 inch first-line indent; the unnumbered opening paragraph (`~`); level-1 `#` headings centered bold caps; level-2 `##` headings bold, lettered A., B., ... (restart under each level-1 heading); lettered list items (a), (b), ...
- Footnotes: 14 pt, double-spaced, at the foot of the page.
- Signature block after the last paragraph: the date, then each firm with its `/s/` signer and the names under it; firms after the first are joined by `-and-`. The block never splits (it moves to a new page whole).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `judge` (optional, right-aligned line above the counsel block), `in_re` (list of lines), `related_case`, `adversary_no`, `parties` (list of `{names, designation, joiner}`; `v.` is inserted before each party after the first, and `joiner` replaces it, e.g. `and`), `title`, `jury_demand` (bool), `footer_title`, `counsel` (one list of lines, or a list of groups for side-by-side columns), `signature` (`date`, and `blocks`: a list of `{firm, signer, lines}`; `signer` is optional and prints `/s/`).
- Body chunks, separated by blank lines:
  - `# Heading` centered bold caps (no number).
  - `## Heading` lettered A., B., ...; the letters are generated, do not type them.
  - `**Line**` a bold-only line: centered, unnumbered.
  - `- item` lines: lettered (a), (b), ...
  - `~ text`: an unnumbered paragraph with a first-line indent (the opening paragraph, the excerpt note).
  - anything else: a numbered paragraph. Do not type the number.
- Footnotes: `text[^1]` in a paragraph and `[^1]: text` on the line directly after that paragraph, with no blank line between.
- `*Italic*` and `**bold**` are markdown.

## Decisions and why

- **Counsel block above the court title.** LBR 9004-1(a)(6) puts counsel on the left above line five and (a)(4) puts the court title on or below line five. The exemplar prints counsel in the footer of each page instead. The template follows the rule, so this is a tier-2 difference from the exemplar (ACCEPTED, see below).
- **Caption may break between parties.** The exemplar's caption runs from page 1 to page 2 too (the plaintiff list of 70 names). At 14 pt the list is about a page and a half, so the template lets the party list run onto the next page, one party at a time.
- **Signature after the last paragraph, not after the Conclusion.** This sample stops at paragraph 24 (see the excerpt note), so the signature block is the filed one, reproduced for layout. In the exemplar the Conclusion (filed page 34) comes before the signature page (filed page 35).
- **Footnotes double-spaced.** The first version used single leading for footnotes, the same as the adversary-complaint template. LBR 9004-1(a)(3) says footnotes shall be double-spaced, so the memorandum template uses the body leading. The adversary-complaint template has not been changed (see Known gaps).

## Overlay

`samples/OVERLAY-1min-motion-to-dismiss-memorandum.pdf` is the red/blue comparison of our render (red) with the filed exemplar (blue), page by page; `.txt` is the page map. Pairing by text gives: ours 1 with filed 42 (the counsel names occur on the last page); ours 2 with filed 1; ours 3 to 13 with filed 8 to 15, word overlap 35 to 70 per cent; ours 14 with filed 42 (the signature page). The pairing is approximate: ours 12 and 13 both pair with filed 15, so the later pages of the transcription are not matched one to one. The overlay is diagnostic, not a score: the red and blue differ in font size (EB Garamond 14 pt against Times in the exemplar), and the filed pages carry a line-numbered pleading background and the ECF header, which the template does not reproduce.

What the overlay shows that is a difference of style (tier 3 or tier 2 ACCEPTED, not a defect):
- The filed document is on 26-line pleading paper with line numbers and an ECF header stamp; the template has neither.
- The filed page 1 names the judge top right (the template takes it from frontmatter when given).
- The filed counsel block sits in the footer; the template sets it at the top of page 1 (LBR 9004-1(a)(6)).

## Known gaps

1. **Tier 2 cannot be finished.** `exemplars/` has one filer (1 Min LLC, Bush Kornfeld and Eisenhower Carlson). EVAL-LOOP needs 2 or 3 filers to tell convention from one filer's style. Nothing else was collected; the box snapshot has no PDFs and the second filer was not searched for in this run.
2. **No table of contents or table of authorities.** The exemplar has a 2-page TOC and a 2-page TOA with page references. Neither is transcribed or templated. LBR 9004-1 (as fetched) does not require either; they are tier 2 conventions a clerk expects in a memorandum this long, and they need a page-reference check (Gate 1 style) before they can be templated.
3. **No certificate of service.** The exemplar's memorandum has none; "certificate of service" appears only in a reference to Docket No. 89, another filing. Nothing is invented. Service rules (FRBP 7005, LBR 5005-1) were not fetched for this doc type.
4. **Line numbering not reproduced.** LBR 9004-1(a)(4) and (a)(6) say "on or below the fifth line" and "above line five". Without line numbers those positions cannot be measured. The template places the court title and counsel block by flow, not by line. Whether David wants pleading paper (26 numbered lines) is an open choice; it is a tier 2 question, not a rule the fetched text states.
5. **Font.** Only EB Garamond is vendored. At 14 pt it looks smaller than the exemplar's Times face at a similar size. A vendored Times-metric font would remove the difference; that is a question for David, not a template fix. The same gap is in the adversary-complaint README.
6. **Excerpt.** The sample stops after paragraph 24 (page 13). The body from paragraph 25 (the Loan Agreement amendment and the rest of Part B and Part C), the Argument, and the Conclusion are not transcribed. The rendered length is 14 pages, which is within the 8 to 14 page target.
7. **Caption text is typed.** The template does not enforce capitalization of the caption or heading text, nor the case-specific names in the sample.
8. **Adversary-complaint footnotes.** The adversary-complaint template (`../adversary-complaint/typst/waeb-adversary-complaint.typ`) sets footnotes single-spaced, which LBR 9004-1(a)(3) does not allow. It is outside this doc type and was not changed here. It should be checked against the same rule.
9. **Words per page.** The 280-word average is measured with pdftotext on the render (footnotes and captions included): about 220 per page. That is a manual count, not a Gate 1 check.

## Review of the rendered pages (2026-10-14, 60 dpi, every page viewed after the last template change)

- Page 1: judge line, counsel in two columns (Bush Kornfeld; Eisenhower Carlson with Mayer Brown), court title, caption start (In re, the debtors, Lead Case No., Adv. Proc. No., title). The party list begins on page 2, unbroken. Footer `AP DEFENDANTS' MEMORANDUM ISO MOTION TO DISMISS 1`. Pass.
- Page 2: plaintiff list (70 names), `Plaintiffs,` at the foot of the caption box. Pass.
- Page 3: `v.`, defendants, `and`, intervenor (caption continues), opening unnumbered paragraph, footnote 1 double-spaced. Pass.
- Pages 4 to 7: PRELIMINARY STATEMENT centered; paragraphs 1 to 8 numbered; footnote 2 on page 5 double-spaced. Pass.
- Pages 8 to 9: paragraphs 9 to 13, FACTUAL BACKGROUND centered, A. heading. Pass.
- Pages 10 to 11: paragraphs 14 to 20, footnotes 3 and 4 double-spaced, B. heading on two lines with a hanging indent. Pass.
- Page 12: paragraphs 21 to 23, footnotes 5 and 6; the all-capitals quotation in paragraph 23 is an in-text quotation and is set at body leading. Pass.
- Page 13: paragraph 24, the excerpt note in italics. Pass.
- Page 14: signature block: date, BUSH KORNFELD LLP with `/s/ James L. Day`, EISENHOWER CARLSON PLLC with `/s/ Darren R. Krattli`, MAYER BROWN LLP, names under each. Pass.
