# flmd: motion-brief (motion to dismiss with memorandum)

Doc type: **motion with legal memorandum** (Fed. R. Civ. P. 12(b)(6), 12(c); M.D. Fla. Local Rules 1.08 and 3.01) in the United States District Court for the Middle District of Florida (`flmd`).
Folder: `courts/eleventh-circuit/florida/federal/middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 19-page filing; see "Excerpt") |
| typeface | Faces allowed: LR 1.08(a) names Book Antiqua (the filed exemplar's body face) among five; 1.08(b) permits Times New Roman at 14 point. Template: **Times New Roman** 14 pt (FLMD-FORM-004; the house standard, `docs/FONTS.md` rule 6), in typst and docx; earlier renders used TeX Gyre Pagella, a visual stand-in for Book Antiqua. See "Typeface" below. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 15 pages (13 with EB Garamond, 14 with TeX Gyre Pagella), typst 0.15.0, no warnings, `pdffonts`: Times New Roman embedded |
| overlay | ok: `usage/OVERLAY-phillip-motion-to-dismiss.pdf` and `OVERLAY-phillip-motion-to-dismiss.txt` (measured on an earlier render) |
| pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed after the change to TeX Gyre Pagella; the earlier 14-page render) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| M.D. Fla. Local Rule 1.08(a) | 8½ × 11 paper; 1-inch margins; bottom-center page numbers (none needed on page one); main text at least 13-point, 2.0 double-spaced; indented quotations at least 12-point single-spaced; footnotes at least 11-point single-spaced; permitted typefaces (Book Antiqua, Calisto MT, Century Schoolbook, Georgia, Palatino). | `page-margin`, footer in `typst/layout.yaml`, `type-size`, `pitch.body`, `show quote`. Typeface: Times New Roman under 1.08(b) (see "Typeface"). |
| M.D. Fla. Local Rule 1.08(b) | Times New Roman at 14-point main text, 13-point indented quotations, 12-point footnotes. | `font-family = ("Times New Roman", "Liberation Serif")`, `size: 14` (all text at 14 pt). |
| M.D. Fla. Local Rule 3.01(b) | A motion includes, in a single document no longer than twenty-five pages, a concise statement of the precise relief requested, the basis, and a legal memorandum. | Not checked by the template (see gap 3). |
| M.D. Fla. Local Rule 3.01(a) | Page limits exclude the caption, the signature block, any certificate of conferral or service, and any verification or attachment. | Relevant to the 25-page count; not computed. |
| M.D. Fla. Local Rule 3.01(g) | Duty to confer before filing a motion, except for a Rule 11 sanction, injunctive relief, judgment on the pleadings, summary judgment, or class certification. A Rule 12(b)(6) motion to dismiss is **not** exempt. The certificate goes under the heading "Local Rule 3.01(g) Certificate" at the end of the motion. | Sample body: the certificate precedes the signature block. |
| M.D. Fla. Local Rule 3.01(d) | A response to a motion to dismiss is due within 21 days after service. | Not in the document; recorded for the clerk's reference. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion, stating with particularity the grounds and the relief sought. | Sample lead-in ("move to dismiss ... Defendants state:"). |
| Fed. R. Civ. P. 10(a) | Caption with court, title, file number, Rule 7(a) designation. | `typst/layout.yaml`. |
| Fed. R. Civ. P. 11(a) | Paper signed by counsel of record. | `typst/layout.yaml`. |

Sources: Local Rule 1.08 and 3.01 text from the court's amended local rules effective 2025-11-01, https://www.flmd.uscourts.gov/sites/flmd/files/flmd-amended-local-rules-effective-november-01-2025.pdf (rule page https://www.flmd.uscourts.gov/local-rules/rule-108-form-pleading-motion-or-other-paper), read 2026-10-14. Rules 7, 8, 10 and 12 from https://www.law.cornell.edu/rules/frcp/rule_7 etc., fetched 2026-10-14.

## Layout

- Court title single-spaced; caption (parties with closing rule; `CASE NO.:` with judge initials on the right); title centered bold; the Rule 12 lead-in paragraph with indent.
- Body double-spaced (32.2 pt baseline pitch, `pitch.body`), 14-point Times New Roman, 1-inch margins, first-line indent on paragraphs. Body paragraphs are **not** numbered (memoranda are not pleadings under Rule 10(b)).
- Headings: level 1 centered bold (write caps in the sample); level 2 centered bold; level 3 bold, left; level 4 bold italic, left.
- Signature block (after the 3.01(g) certificate): "Respectfully submitted," firm, each counsel's `s/` line and details, address, "Attorneys for Defendants". Kept as one unbreakable block.
- Certificate of service: the sample's `# CERTIFICATE OF SERVICE` and everything after it are printed after the signature block as one unbreakable block.

## Markdown contract (for samples)

See "Engines" below: the frontmatter fields are those the layout (`typst/layout.yaml`) reads. Body: markdown (headings `#` to `####`, paragraphs, lists, block quotations, footnotes, `*italics*`), set by the shared document model.

## Typeface

- Faces allowed: LR 1.08(a) names Book Antiqua (the filed exemplar's body is `BookAntiqua`, with Times New Roman in some places) among five; 1.08(b) permits Times New Roman at 14 point. The template sets Times New Roman (FLMD-FORM-004), the pinned install (`docs/FONTS.md` rule 1), as the house standard (rule 6), in typst and docx.
- Earlier renders: **TeX Gyre Pagella** (`fonts/tex-gyre-pagella/`, GUST Font License) as a visual stand-in for Book Antiqua (`docs/FONTS.md` marks it **visual only**: a Palatino clone, not metric-compatible with Book Antiqua). The notes below on leading and pagination are from that render.
- Size: 14-point main text (1.08(b) for Times New Roman; 1.08(a) minimum 13-point).
- Leading (the Pagella render): `body-leading` was 1.31 em (was 1.35 em with EB Garamond). This keeps the measured baseline pitch at 2.0 em (28.1 pt at 14 pt). Leading is the only spacing unit changed.
- Pagination (the Pagella render): 14 pages, one more than with EB Garamond (13); the committed Times New Roman render is 15. The substitute is wider, so paragraphs wrap to more lines. The page-count change is recorded here; the signature block and the certificate of service still sit as unbreakable blocks.
- Line breaks and the page count differ from a filing set in Book Antiqua. The length check against the 25-page limit (LR 3.01(b)) must not rely on this render.

## Known gaps and open choices

1. **One exemplar.** The CourtListener search (`type=r`, `court=flmd`, query "motion to dismiss" "memorandum", filings from 2026) returned mostly Warden-as-party motions in habeas petitions, which are not motions to dismiss a complaint with a memorandum. Phillip was the only candidate whose RECAP PDF was stored and opened. A second filer was not collected, so tier 2 is not judged against two filers yet.
2. **Excerpt.** The sample transcribes pages 1 to 12 of the filing and the signature and certificate pages, omitting Section III (Request for Judicial Notice) and Section IV.a.ii.D to F (NIED, negligence per se, medical monitoring, FDUPTA). Omissions are marked in the sample with an italic note. The full filing is 19 pages.
3. **25-page limit.** Not computed by the template. The filing's text pages fall under 25; the sample is not the whole brief, so the limit is not tested here.
4. **Footnotes.** Not supported by the markdown contract. The exemplar's footnotes 1 and 2 are omitted.
5. **Level-3 headings.** Long argument headings wrap without a hanging indent. The exemplar's own wrap is not reproduced; cosmetic.
6. **Case names not italic.** The exemplar's text layer has no italic markup; the sample is roman. The template italicizes `*...*` markdown if a sample uses it.
7. **Overlay file names.** See the complaint README, gap 6.
8. **Gates not run.** See the complaint README, gap 7.
9. **Exemplar typos preserved.** The sample reproduces the filing's text, including its "Per to Local Rule 3.01(g)", "Section III. CONCLUSION" after "IV. ARGUMENT", and "failed to identified". They are the filer's, not ours; the sample is a transcription.
10. **Overlay pairing** (measured on an earlier render). Pages are paired by shared words, and the excerpt skips filed pages, so pairs are loose: word overlap is 39 to 47 percent on sample pages 4, 9 and 12 (paired with filed pages 7, 16 and 19). Read the overlay as a diagnostic; the cause of each low pairing was not traced further.

## Review of the rendered pages (the earlier 14-page Pagella PDF, 60 dpi)

Every page was rendered with `pdftoppm -r 60`, montaged two per image, and viewed. Result below.

- Page 1: caption, title, Rule 12 lead-in. Pass.
- Page 2: MEMORANDUM OF LAW, I. INTRODUCTION, body with indent. Pass.
- Page 3: II. LEGAL STANDARD, heading kept with its paragraph. Pass.
- Page 4: omission note (italic), no orphaned heading. Pass.
- Page 5: IV. ARGUMENT, heading a. (bold, wraps to four lines), i. heading kept with its paragraph. Pass.
- Page 6: argument i. continued. Pass.
- Page 7: argument i. continued. Pass.
- Page 8: argument i. continued, ends the i. section. Pass.
- Page 9: heading ii., A. and B. headings. Pass.
- Page 10: B. continued; C. and b. headings. Pass.
- Page 11: b. continued; c. heading; shotgun-pleading argument. Pass.
- Page 12: shotgun argument continued; III. CONCLUSION. Pass. Lower half blank by design: the certificate and signature block are kept together and move to page 13.
- Page 13: LOCAL RULE 3.01(g) CERTIFICATE; "Respectfully submitted,"; both counsel's blocks; "Attorneys for Defendants". Pass.
- Page 14: CERTIFICATE OF SERVICE, served list, `s/Jonathan Kepko` and "Attorney" together. Pass.

## Engines

On the generic federal district brief since fb-595.17.4: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst (reference) | `usage/OUTPUT-motion-brief.typst.pdf`, 15 pages | 12 checks passed, 0 failed | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` | 15 checks passed, 0 failed | PASS (305/305 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | 16 checks passed, 0 failed | PASS (305/305 lines) |

Frontmatter: `division`, `case_label` (default "Case No."), `case_number`, `caption.parties` (`names`, `designation`), `brief_title`, `lead_in` (the motion's opening, the first paragraph), `signature` (`firm`, `counsel`: a list of lines per counsel, `address`, `for`), `service` (`text`, `served`, `signer`). The certificate of service moved from the body (its "~ " unindented chunks, a markup of the old template that pandoc reads as a definition list) to `service` in the frontmatter, set after the signature by the layout; the transcription note in the body lost its "~ ". Page one is unnumbered (LR 1.08(a)); the 25-page limit of LR 3.01(a) is checked (`eval.yaml`).

