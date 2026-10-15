# NMCCA: answer to appellant's brief and assignments of error (answering-brief)

Court: U.S. Navy-Marine Corps Court of Criminal Appeals (`nmcca`). Doc type: answering brief (the government's answer, Rule 18.4(a)).

## Status

**BLOCKED: no exemplar.** No public filed NMCCA answer (government brief answering an appellant's assignments of error) was found after a real search on 2026-10-15 (trail in `exemplars/SOURCE.md`). Without one, the sample cannot be rewritten to a real structure and the overlay cannot run. The template and sample below are unchanged from 2026-10-14 and remain synthetic.

- Template: built and rendered. Typst only (`typst/`). `latex/` and `docx/` are not in this folder.
- Exemplar: **none**. No public filed NMCCA answer was found (search trail in `exemplars/SOURCE.md`). The template follows the rules and the appellant's format, not a filed answer.
- Sample: `samples/INPUT-answering-brief.md` is **synthetic**. Names, numbers, dates and citations are placeholders in brackets, and the issues and argument are generic. It is not a transcription of any filed brief, so it does not show what a real NMCCA answer looks like.
- Overlay: **not produced**. `tools/overlay.sh` needs a filed exemplar PDF to compare against, and there is none (it exits 1: "no exemplar pdf").
- Not reviewed by a human. `court.json` untouched.

## What is here

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `typst/nmcca-answering-brief.typ` | The template: `nmcca-answering-brief(meta, md)`. Content-agnostic; the layout values are named parameters at the top. |
| `samples/INPUT-answering-brief.md` | Synthetic sample (frontmatter + body). Caption, assignments of error, jurisdiction, statement of the case and of the facts, summary, argument with standard of review, conclusion, signature, certificate. About 6 pages of body. |
| `samples/OUTPUT-answering-brief.pdf` | Our render of the sample (8 pages: cover, index, body 1-5, certificate on 6). |
| `exemplars/SOURCE.md` | The exemplar search. No PDF. |

Build (from the repo root, with the toolchain on PATH):

```sh
D=courts/military/navy-marine-corps-court-of-criminal-appeals/answering-brief
sh tools/render.sh $D samples/INPUT-answering-brief.md     # -> samples/OUTPUT-answering-brief.pdf
sh tools/overlay.sh $D answering-brief                     # fails: no exemplar PDF
```

`render.sh` compiles with the vendored fonts only (`--ignore-system-fonts`) and treats any typst warning as a failure. The sample renders with no warnings; the PDF embeds only EB Garamond faces.

## Governing rules

Primary source: **NMCCA Rules of Appellate Procedure (2022)**, effective 1 June 2022, PDF at
https://stjececmsdusgva001.blob.core.usgovcloudapi.net/public/documents/2022_NMCCA_Rules_of_App_Proc.pdf
Text read by `pdftotext` on 2026-10-14 (the fetch tool returned the PDF as binary). Page numbers are the rules' printed pages. The layout IDs (NMCCA-FORM-, NMCCA-CONT-) are defined and cited in `../opening-brief/README.md`; the answer-specific rule is below.

| ID | Requirement | Source |
|---|---|---|
| NMCCA-ANS-001 | An answer follows the same format as an appellant's filing, responding separately to each assigned error (Rule 18.1(b)). It may adopt the appellant's summary of proceedings and statement of facts, and may state additional facts. Due 30 days after the appellant's brief and assignments of error. | Rule 18.4(a), p. 34 (text verified 2026-10-14) |
| NMCCA-ANS-002 | Because the format is the appellant's, the answer uses the same type, spacing, margins, caption and certificate: NMCCA-FORM-001 to -004 and NMCCA-CONT-001, -004 to -008 in `../opening-brief/README.md`. Rule 18.4 does not restate them. | Rule 18.4(a), p. 34; Rule 17(c), p. 28; Rule 18.1(b), pp. 31-32; Appendix I, pp. 93-96 |
| NMCCA-ANS-003 | Answers are not counted against the principal-brief word limit in the same way. Rule 17 "Length" (15,000 words for principal briefs) is not restated for answers. The template does not count words (see gaps). | Rule 17 "Length", p. 28 (applicability to answers not stated; treated as applying) |

Because the rules do not give an answer-specific caption, the template follows the appellant's cover (Appendix I), with the United States as appellee and the appellant as appellant.

## Typeface

Same as the opening brief (see `../opening-brief/README.md`, "Typeface"). Rule 17(c) names no face it requires (Times New Roman and Century Schoolbook are examples) and allows any 14-point proportional type, so the template keeps `EB Garamond` (`fonts/eb-garamond/`), with no substitute. Rendered 2026-10-14: 8 pages, no warnings; `pdffonts` lists only EBGaramond faces.

## What the template is built to check

The template fails the build (with a message) if:

- a required level-1 section is missing: "Statement of Statutory Jurisdiction", "Argument", "Conclusion", and either "Issue(s) Presented" or "Assignments of Error" (NMCCA-CONT-001);
- the Argument has no "Standard of Review" heading (NMCCA-CONT-005);
- the frontmatter is missing a field the cover, signature or certificate needs.

## Page review (Gate 2)

Every page of `OUTPUT-answering-brief.pdf` (8 pages) was rendered at 60 dpi (`pdftoppm -r 60`) and looked at after the final edit (the argument-heading fix). Pages 1-8 were all reviewed, and no page was skipped. Re-reviewed 2026-10-14 after the footnote-size fix: the sample has no footnotes, so the layout did not change.

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover | Caption, "Before Panel", United States as appellee, appellant block, title, "To the Honorable" line, tried-at paragraph and counsel block all present. The NMCCA number wraps onto two lines because the placeholder is long. **OPEN**, cosmetic (placeholder length). |
| 2 | Index of Brief (roman "ii") | Generated from headings; page references match the body. The argument point sub-entries have no "I." / "II." label, the known gap from the opening brief. **OPEN**, cosmetic. |
| 3 | Assignments of error, jurisdiction, statement of the case, facts (body p. 1) | The second issue's first line is indented, the first issue's is not. The template gives every paragraph a first-line indent, but the issue paragraphs are not indented alike. **OPEN**, cosmetic (sample-driven: the sample writes the issues as separate paragraphs). |
| 4 | Summary of argument, Argument opening (body p. 2) | "Standard of Review" under the Argument prints bold italic, the same style as the argument point headings. The opening brief prints it bare bold. **OPEN**, cosmetic (template styles every level-2 heading in the Argument italic). |
| 5 | Argument point I, sub-headings (body p. 3) | "I." label appears once (heading numerals removed from the sample, which had doubled them). "Principles of Law" and "Discussion" bare; the first sub-point is labelled A. **Fixed** (the duplicated numerals were a sample fault, and the sample is corrected). |
| 6 | Argument point I end, point II, standard of review (body p. 4) | Labels "A.", "B.", "II." each printed once. Point II's "Standard of Review" (level 3) is bare bold. OK. |
| 7 | Point II discussion, conclusion, signature block (body p. 5) | The conclusion ends and the signature block sits with it on the same page. OK. |
| 8 | Certificate of filing and service (body p. 6) | Own page, numbered. The service line reads "Appellate Defense Division, Navy-Marine Corps Appellate Review Activity on [date of filing]." OK. |

Re-rendered and re-reviewed 2026-10-15: `sh tools/render.sh` exit 0, 8 pages, fonts are EB Garamond only. All 8 pages were rasterized (`pdftoppm -r 60`) and viewed. The table above still holds; PDF pages 3-7 are body pages 1-5 and PDF page 8 is the certificate (page 6).

Overlay: not produced. `sh tools/overlay.sh` exits 1 on 2026-10-15 (and on 2026-10-14) ("no exemplar pdf"): no filed NMCCA answer exists to compare against (see Status and `exemplars/SOURCE.md`). Opening-brief exemplar is not a substitute, since it is a different document type.

## Known gaps

- **No exemplar, no overlay.** The layout is built from the rules alone. A filed NMCCA answer would settle the open choices below and should be added to `exemplars/` with a `SOURCE.md` row. Until then the template is not tier-2 checked.
- **Sample is synthetic.** `samples/INPUT-answering-brief.md` uses placeholders; it is not a transcription and must not be read as a filed brief.
- **Table of authorities** is not generated (NMCCA-CONT-002). Not needed for a sample this size; a real answer over 10,000 words needs one.
- **Word count** is not computed or checked against the 15,000-word limit (NMCCA-FORM-005; applicability to answers in NMCCA-ANS-003).
- **Argument point labels** are not repeated in the index.
- **Standard of Review** under the Argument is styled bold italic, not bare bold (see page 4).
- **Font.** See "Typeface" above: EB Garamond at 14 pt, as in the opening-brief template.

## Open choices (for David)

1. **An NMCCA answer exemplar.** Is there a filed NMCCA answer brief to use? Without one, the template is rule-driven only.
2. **Standard of Review style.** Bare bold (as the opening brief) or italic (current)?
