# N.D. Ohio Bankruptcy Court: motion with memorandum

Status: template built, sample rendered, overlay run, every page reviewed (Gate 2 by eye). Engines: typst only; latex and docx not built.

## Governing rules (verified 2026-10-14 unless marked)

| Requirement | Kind | Source | Verified | What the template does |
|---|---|---|---|---|
| Relief in a contested matter is requested by motion | M | FRBP 9014(a) (https://www.law.cornell.edu/rules/frbp/rule_9014) | 2026-10-14 | Motion section at the head of the document |
| Rule 7012 is not among the rules that apply to contested matters by 9014(c)(1); adversary motions take Rule 7012 directly | M | FRBP 9014(c)(1) (same page) | 2026-10-14 | Motion cites FRCP 12(b)(6) through FRBP 7012(b) (text of 7012(b) itself not fetched) |
| Caption: court name, title, case number and adversary number, designation | M | FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) and 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | 2026-10-14 | Caption, shared with the adversary complaint template |
| Paper: 8 1/2 x 11 inch, one side | M | LBR 5005-1(a) (N.D. Ohio Local Bankruptcy Rules, last revised May 16, 2011, https://www.ohnb.uscourts.gov/sites/default/files/file-list/local-bankruptcy-rules.pdf) | 2026-10-14 | US Letter, one-sided |
| Signature block as LBR 5005-1(c) | M | same PDF | 2026-10-14 | Signature block after the motion and after the memorandum |
| Font size at least 12 pt, footnotes included; memorandum at most 20 pages unless leave is granted (then a table of contents is required) | M | LBR 9013-2(a) (same PDF) | 2026-10-14 | 12 pt, footnotes and the TOC are not generated; the 20-page limit is an author responsibility (A) |
| Notice that objections must be filed within 14 days, and that the court may grant the relief without further notice | M | LBR 9013-1(a)(2) (same PDF) | 2026-10-14 | "NOTICE OF MOTION" paragraph, generated |
| Response and reply periods | M | LBR 9013-1(b), (c) (same PDF) | 2026-10-14 | Not generated (the response is the opponent's paper) |
| Certificate of service: identifies the document, date and method of service, each entity served, and refers to the notice | M | LBR 9013-3(1)-(4) (same PDF) | 2026-10-14 | "CERTIFICATE OF SERVICE" generated from the `service` frontmatter |
| Margins, double spacing, heading style | C | No N.D. Ohio rule found; chosen to match the filed exemplars | - | 1 in margins; 24 pt line pitch; centred bold caps headings |

Not verified in this session: FRBP 9013 (form of a motion) and FRBP 7012(b) text. The 14-day period is the court's own (LBR 9013-1(a)); LBR 9013-1(b) and (c) carry the FRBP 9006(f) cross-reference, whose text was not fetched.

## Files

- `typst/main.typ`: entry point; reads `usage/<id>.md`.
- `typst/ohnb-motion-brief.typ`: template `ohnb-motion-brief(meta, body)`. The body must contain one `# MEMORANDUM` heading: the motion goes before it and the memorandum after; each part is signed.
- `usage/`: two filed motions with memoranda: Templar (Swearingen v. Templar, adversary 21-6017) and Meddings (Harrison v. Meddings, A.P. 21-3021). Sources in `usage/SOURCE.md`.
- `usage/INPUT-motion-brief.md`: Templar's motion and memorandum, transcribed in full (5 pages in the exemplar).
- `usage/OUTPUT-motion-brief.typst.pdf`: our render (4 pages).
- `usage/OVERLAY-motion-brief.pdf` and `.txt`: overlay against the Templar exemplar (passed explicitly; the tool's default would pick the Meddings file alphabetically).

Build and check:

```sh
export PATH="$HOME/tb/bin:$PATH"
cd /work/repo
sh tools/render.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief motion-brief courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief/usage/FILED-EXAMPLE-motion-brief-2.pdf
```

## Gate 2 review (by eye, every page of the current PDF)

Reviewed 2026-10-14 against the Templar exemplar.

| Page | Finding | Status |
|---|---|---|
| 1 | Caption and the motion's opening paragraphs; WHEREFORE at the foot. The signature block falls to page 2, where the exemplar also puts it. | ACCEPTED (matches the exemplar's break) |
| 2 | Signature block, then the memorandum heading (bold, centred, caps; heading size fixed to body size) and paragraphs 1 to 5. | FIXED |
| 3 | Paragraphs 5 to 10, the WHEREFORE for the memorandum; italic case names and "Id." render as italic. | PASS |
| 4 | Second signature block, NOTICE OF MOTION (LBR 9013-1(a), generated; the exemplar has no notice), certificate of service with the service list. | PASS (the notice is an addition the exemplar lacks; see Known gaps) |

## Overlay

`OVERLAY-motion-brief.pdf` pairs our pages with the Templar pages by shared words: page 1 at 95.8%, page 2 with exemplar page 3 at 66.4%, page 3 with exemplar page 4 at 79.8%, page 4 with exemplar page 5 at 54.5%. The differences are the caption column layout, the spacing of body paragraphs (ours is double-spaced; not measured against the exemplar), and the notice paragraph, which the exemplar does not have. The overlay is a diagnostic, not a score.

## Known gaps

- The Templar exemplar has no LBR 9013-1(a) notice and certificate wording; our template adds the notice. This is a tier-1 rule as the local rule reads, so the template follows the rule, not the exemplar.
- Exemplar length: our render (4 pages) is shorter than the 8 to 14 page target. The Templar motion is 5 pages in the filed form; the Meddings motion (7 pages) is in `usage/` but not transcribed.
- Table of contents and table of authorities: not generated. LBR 9013-2(a) requires a table of contents only when leave to exceed 20 pages is granted; the sample is well under 20 pages.
- Footnote size (12 pt under LBR 9013-2(a)) is set by the template but no footnote is in the sample.
- LaTeX and docx engines are not built.
- The sample's CourtListener docket page for the Templar adversary was not recorded (see `usage/SOURCE.md`).

## Engines

docx (`docx/`): `build-reference.sh` makes `docx/reference.docx` (EB Garamond 12 pt, letter, 1 in margins, body double spacing at an exact 24.6 pt pitch, 0.5 in first-line indent, centered bold caps headings, a centered PAGE footer); `render.sh` and `ohnb-motion-brief.lua` build the caption table, the title, the motion, the signature blocks after the motion and the memorandum, and the NOTICE OF MOTION and CERTIFICATE OF SERVICE as in the typst template. Build: `sh docx/build-reference.sh "$PWD/docx/reference.docx"` from the court folder.

- Matches typst, by measurement: page size (612 x 792 pt) and margins (72 pt); font family and size (EB Garamond 12 pt, the same three faces embedded in the typst PDF); body line pitch (24.6 pt on the typst render, exact in the docx); the LBR 9013-2(a) 12 pt size applies to the docx body and the footer.
- Differs from typst: heading, signature and certificate spacing are set in twips by eye from the typst render, not measured line by line; no page count is measured (the typst PDF is 4 pages; the docx has not been paginated); the NOTICE and certificate blocks are kept together only by keep-with-next, not by the block's unbreakable setting in typst; footnotes (none in the sample) are 12 pt in the docx and the typst template sets no footnote size.
- Not generated by either engine: TOC and TOA (not required below 20 pages under LBR 9013-2(a)); pleading line numbers.
- BLOCKED, docx.pdf and page review: `soffice` is not installed on this box, so `usage/OUTPUT-motion-brief.docx.pdf` does not exist. The docx checks cannot run; no page was viewed.
- BLOCKED, Word and LibreOffice open check: not done (no repair-prompt check was run).
- Zip and XML: `OUTPUT-motion-brief.docx` passes the renderer's zip and well-formed-XML checks and has no duplicate entries.
- Word counts: the docx and the typst PDF carry the same words (996 and 1006 by `pandoc -t plain` and `pdftotext`; the difference is the page numbers and caption-cell reading order, not checked word by word).
