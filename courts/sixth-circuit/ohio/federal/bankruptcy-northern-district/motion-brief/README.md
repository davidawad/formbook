# N.D. Ohio Bankruptcy Court: motion with memorandum

Status: template built, both samples rendered on typst and docx, overlay run, every page reviewed on both engines (Gate 2 by eye, 2026-10-22). Engines: typst and docx on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; XENG gated in `eval.yaml`); latex not built.

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
| Margins, double spacing, heading style | C | No N.D. Ohio rule found; chosen to match the filed exemplars | - | 1 in margins; Times New Roman 12 pt; 24 pt body pitch, 13.8 pt single lines (court lines, caption, title, signatures, service list); centred bold caps headings on the body pitch |

Not verified in this session: FRBP 9013 (form of a motion) and FRBP 7012(b) text. The 14-day period is the court's own (LBR 9013-1(a)); LBR 9013-1(b) and (c) carry the FRBP 9006(f) cross-reference, whose text was not fetched.

## Files

- `typst/main.typ`: entry point; reads `usage/<id>.md`.
- `typst/ohnb-motion-brief.typ`: template `ohnb-motion-brief(meta, body)`. The body must contain one `# MEMORANDUM` heading: the motion goes before it and the memorandum after; each part is signed.
- `usage/`: two filed motions with memoranda: Templar (Swearingen v. Templar, adversary 21-6017) and Meddings (Harrison v. Meddings, A.P. 21-3021). Sources in `usage/SOURCE.md`.
- `usage/INPUT-motion-brief.md`: Meddings' motion, memorandum and certificate, transcribed in full from `FILED-EXAMPLE-motion-brief.pdf` (7 pages; calibration set, `data/calibration-set.json`).
- `usage/INPUT-motion-brief-2.md`: Templar's motion and memorandum, transcribed in full from `FILED-EXAMPLE-motion-brief-2.pdf` (5 pages in the exemplar).
- `usage/OUTPUT-<id>.typst.pdf`, `.docx`, `.docx.pdf`: our renders (motion-brief 7 pages, motion-brief-2 5 pages, the same lines and pages in both engines).
- `docx/reference.xml`: the Word styles (`base="xengine"`, Times New Roman 12 pt, Body Text on 480 twips with a 720 twip first-line indent, single lines 276 twips; "Body Text Keep" for the last chunk of a part).
- `docx/ohnb-motion-brief.lua`: the docx filter (court lines, caption table, title, headings, the two parts and their signatures, notice, certificate, the footer and the section through `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`).
- `eval.yaml`: `params.cross_engine: gate`.
- Overlays: `just overlay <this folder>` writes them to the gitignored `.overlay/` (not committed).

Build and check:

```sh
cd /work/repo
sh tools/render.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief --engine typst
sh tools/check.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief --engine docx
sh tools/overlay.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief motion-brief courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/motion-brief/usage/FILED-EXAMPLE-motion-brief-2.pdf
```

## Gate 2 review (by eye, every page of the current PDFs)

Reviewed 2026-10-22: every page of `OUTPUT-motion-brief.typst.pdf` (7) and `OUTPUT-motion-brief-2.typst.pdf` (5) and of their LibreOffice PDFs `.docx.pdf` rendered at 60 dpi side by side and viewed; page 1 compared with page 1 of both filed motions. The two engines set every line and page alike (XENG-001..003 gated: 177/177 and 117/117 lines), so one table serves both.

| Sample | Page | Finding | Status |
|---|---|---|---|
| motion-brief | 1 | Court lines centred bold capitals with the division; caption (debtor, parties, ")" column, case, chapter, judge, adversary numbers), MOTION TO DISMISS; the motion's first paragraph. The WHEREFORE paragraph and the signature do not fit below it and move to page 2 together, leaving the foot of page 1 empty. | ACCEPTED (the last paragraph is kept with the signature) |
| motion-brief | 2 | WHEREFORE, the signature block single-spaced 3.25 in from the margin, MEMORANDUM IN SUPPORT (a blank single line above), the memorandum. | PASS |
| motion-brief | 3-5 | Memorandum paragraphs, double spaced with the 0.5 in indent; italic case names. | PASS |
| motion-brief | 6 | The memorandum's WHEREFORE kept with its signature; NOTICE OF MOTION (LBR 9013-1(a)(2)). The certificate does not fit below it and opens page 7. | ACCEPTED (the certificate is kept on one page) |
| motion-brief | 7 | CERTIFICATE OF SERVICE (LBR 9013-3): the sentence, the three entities single-spaced with a blank line between them, the "s/" signature. | PASS |
| motion-brief-2 | 1 | Caption without a chapter line (none in the frontmatter); the title wraps over three centred bold lines; the motion's first two paragraphs. | PASS |
| motion-brief-2 | 2 | WHEREFORE and the signature (the attorney line wraps after "Companies,", as in the filed motion); the memorandum heading over three double-spaced lines; paragraphs 1 to 5. | ACCEPTED (a long level-1 heading is set on the body pitch) |
| motion-brief-2 | 3 | Paragraphs 5 to 9; "Id." and case names italic. | PASS |
| motion-brief-2 | 4 | Paragraph 10, the closing paragraph kept with the signature, NOTICE OF MOTION. | PASS |
| motion-brief-2 | 5 | CERTIFICATE OF SERVICE and its signature. | PASS |

Open tier-2 rows: none. The .docx files were opened in LibreOffice only (no repair prompt), not in Word.

## Overlay

`OVERLAY-motion-brief.pdf` pairs our pages with the Templar pages by shared words: page 1 at 95.8%, page 2 with exemplar page 3 at 66.4%, page 3 with exemplar page 4 at 79.8%, page 4 with exemplar page 5 at 54.5%. The differences are the caption column layout, the spacing of body paragraphs (ours is double-spaced; not measured against the exemplar), and the notice paragraph, which the exemplar does not have. The overlay is a diagnostic, not a score.

## Known gaps

- The Templar exemplar has no LBR 9013-1(a) notice and certificate wording; our template adds the notice. This is a tier-1 rule as the local rule reads, so the template follows the rule, not the exemplar.
- Length: our renders are 7 pages (Meddings) and 5 pages (Templar), as filed.
- Table of contents and table of authorities: not generated. LBR 9013-2(a) requires a table of contents only when leave to exceed 20 pages is granted; the sample is well under 20 pages.
- Footnote size (12 pt under LBR 9013-2(a)) is set by the template but no footnote is in the sample.
- LaTeX is not built for this doc type.
- The sample's CourtListener docket page for the Templar adversary was not recorded (see `usage/SOURCE.md`).

## Engines

docx (`docx/`): `docx/reference.xml` (fb render builds the styles from the cross-engine recipe, `base="xengine"`, in the typst face Times New Roman; was `build-reference.sh`, `render.sh` and a committed `reference.docx` in EB Garamond, fb-595.68.30) and `docx/ohnb-motion-brief.lua` on `lib/docx/xengine.lua`: every paragraph in exact line boxes of the typst pitches (480 and 276 twips), the caption a borderless fixed table of 5040, 432 and 3888 twips (typst 3.5, 0.3 and 2.7 in), the signatures 4680 twips (3.25 in) from the margin, the notice and the certificate each kept on one page (keep with next through the block, as typst's unbreakable blocks), the footer's centred page number 720 twips from the bottom edge (typst footer-foot 0.5 in), the typst break rules on every run (no break inside ")(", a break after a slash before a letter, a doubled section sign bound to its number).

- `sh tools/check.sh <this folder> --engine typst` and `--engine docx`: every gate green on both samples, XENG-001..003 PASS (7/7 and 5/5 pages, 177/177 and 117/117 lines).
- `tools/check-selftest.sh` takes a court root with `court.json` and does not run on this doc-type folder.
- Not generated by either engine: TOC and TOA (not required below 20 pages under LBR 9013-2(a)); pleading line numbers.
- The .docx files were opened in LibreOffice only, not in Word.
