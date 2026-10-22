# NMCCA: answer to appellant's brief and assignments of error (answering-brief)

Court: U.S. Navy-Marine Corps Court of Criminal Appeals (`nmcca`). Doc type: answering brief (the government's answer, Rule 18.4(a)).

## Status

**BLOCKED: no exemplar.** No public filed NMCCA answer (government brief answering an appellant's assignments of error) was found after a real search on 2026-10-15 (trail in `usage/SOURCE.md`). Without one, the sample cannot be rewritten to a real structure and the overlay cannot run. The sample remains synthetic; the template was ported to the cross-engine layout model on 2026-10-22 (see "Engines").

- Template: built and rendered in typst (`typst/`, the reference) and docx (`docx/`), on the shared cross-engine layout model and gated (see "Engines"). No latex engine in this folder.
- Exemplar: **none**. No public filed NMCCA answer was found (search trail in `usage/SOURCE.md`). The template follows the rules and the appellant's format, not a filed answer.
- Sample: `usage/INPUT-answering-brief.md` is **synthetic**. Names, numbers, dates and citations are placeholders in brackets, and the issues and argument are generic. It is not a transcription of any filed brief, so it does not show what a real NMCCA answer looks like.
- Overlay: **not produced**. `tools/overlay.sh` needs a filed exemplar PDF to compare against, and there is none (it exits 1: "no exemplar pdf").
- Not reviewed by a human. `court.json` untouched.

## What is here

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `typst/nmcca-answering-brief.typ` | The template: `nmcca-answering-brief(meta, md)`. Content-agnostic; the layout values are named parameters at the top. |
| `usage/INPUT-answering-brief.md` | Synthetic sample (frontmatter + body). Caption, assignments of error, jurisdiction, statement of the case and of the facts, summary, argument with standard of review, conclusion, signature, certificate. About 6 pages of body. |
| `usage/OUTPUT-answering-brief.typst.pdf` | Our render of the sample (9 pages: cover, index, body 1-6, certificate on 7). |
| `docx/nmcca.lua`, `docx/reference.xml` | The docx engine (see "Engines"); `usage/OUTPUT-answering-brief.docx` and `.docx.pdf` are its output. |
| `eval.yaml` | `params.cross_engine: gate` (Gate 4, XENG-001..003). |
| `usage/SOURCE.md` | The exemplar search. No PDF. |

Build (from the repo root, with the toolchain on PATH):

```sh
D=courts/military/navy-marine-corps-court-of-criminal-appeals/answering-brief
sh tools/render.sh $D usage/INPUT-answering-brief.md     # -> usage/OUTPUT-answering-brief.typst.pdf
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

Rule 17(c) names no face it requires (Times New Roman and Century Schoolbook are examples) and allows any 14-point proportional type, so the template keeps `EB Garamond` (`fonts/eb-garamond/`), with no substitute. Rendered 2026-10-22: 9 pages, no warnings; `pdffonts` lists only EBGaramond faces (typst and docx).

## What the template is built to check

The template fails the build (with a message) if:

- a required level-1 section is missing: "Statement of Statutory Jurisdiction", "Argument", "Conclusion", and either "Issue(s) Presented" or "Assignments of Error" (NMCCA-CONT-001);
- the Argument has no "Standard of Review" heading (NMCCA-CONT-005);
- the frontmatter is missing a field the cover, signature or certificate needs.

## Page review (Gate 2)

Re-reviewed 2026-10-22 after the port to the cross-engine layout model (fb-595.54.7): every page of `OUTPUT-answering-brief.typst.pdf` and of `OUTPUT-answering-brief.docx.pdf` (9 pages each) was rendered at 60 dpi (`pdftoppm -r 60`) and looked at side by side. The two engines set every page alike (same lines, same page breaks; `fb diff --engines`: baselines within 0.04 pt). PDF pages 3-8 are body pages 1-6; PDF page 9 is the certificate (page 7).

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover | Court name, "Before Panel", caption in two columns on one line grid (a blank single line between the parts), title, "To the Honorable" lines, tried-at paragraph; the counsel block now sits at the foot of the cover (2 in bottom margin) in both engines. The NMCCA number wraps onto two lines because the placeholder is long. **OPEN**, cosmetic (placeholder length). |
| 2 | Index of Brief (roman "ii") | Generated from the headings with dot leaders and page numbers that match the body; the Argument points now carry their "I." / "II." labels with the text hanging after them. typst ends the leader before a 36 pt page column, Word runs it to the number. OK. |
| 3 | Assignments of error, jurisdiction, statement of the case (body p. 1) | The second issue is indented, the first is not (a paragraph that follows a paragraph is indented; the sample writes the issues as paragraphs). **OPEN**, cosmetic (sample-driven). |
| 4 | Statement of facts, summary of argument (body p. 2) | Double-spaced 14 pt, headings centred bold capitals. OK. |
| 5 | Argument, standard of review, point I, principles of law, discussion (body p. 3) | "Standard of Review" under the Argument prints bold italic like the points. **OPEN**, cosmetic (see open choice 2). Labels I. and bare sub-headings as NMCCA-CONT-004. OK. |
| 6 | Discussion end, sub-points A. and B. (body p. 4) | Labels printed once, text hangs after them. OK. |
| 7 | Point II, standard of review, discussion (body p. 5) | The page ends early: the conclusion, kept with the signature block, does not fit below. OK. |
| 8 | Conclusion and signature block (body p. 6) | The last paragraph and the signature block stay together; signature rule 3 in. OK. |
| 9 | Certificate of filing and service (body p. 7) | Own page, numbered; service line and signature block. OK. |

Overlay: not produced. `sh tools/overlay.sh` exits 1 ("no exemplar pdf"): no filed NMCCA answer exists to compare against (see Status and `usage/SOURCE.md`). Opening-brief exemplar is not a substitute, since it is a different document type.

## Known gaps

- **No exemplar, no overlay.** The layout is built from the rules alone. A filed NMCCA answer would settle the open choices below and should be added to `usage/` with a `SOURCE.md` row. Until then the template is not tier-2 checked.
- **Sample is synthetic.** `usage/INPUT-answering-brief.md` uses placeholders; it is not a transcription and must not be read as a filed brief.
- **Table of authorities** is not generated (NMCCA-CONT-002). Not needed for a sample this size; a real answer over 10,000 words needs one.
- **Word count** is not computed or checked against the 15,000-word limit (NMCCA-FORM-005; applicability to answers in NMCCA-ANS-003).
- **Standard of Review** under the Argument is styled bold italic, not bare bold (see page 5).
- **Font.** See "Typeface" above: EB Garamond at 14 pt. (The opening-brief template now sets Times New Roman: Rule 17(c) bars the Courier face of its 2013 exemplar; see its README.)

## Open choices (for David)

1. **An NMCCA answer exemplar.** Is there a filed NMCCA answer brief to use? Without one, the template is rule-driven only.
2. **Standard of Review style.** Bare bold (as the opening brief) or italic (current)?

## Engines

Both engines are on the shared cross-engine layout model (fb-595.54.7; `lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Adopting the reference breaker"): EB Garamond 14 pt everywhere (footnotes too), body lines in 33.6 pt boxes (double spacing), the cover, headings, index, quotations, footnotes and signature blocks in 16.8 pt boxes, first-fit line breaking, no kerning and no hyphenation. The docx render breaks every line and page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, XENG-001..003 PASS). Two choices follow from LibreOffice, which makes the docx PDF: it sets EB Garamond's standard ligatures (fi, ff, ffi) whatever the file says (it ignores `w14:ligatures`), so the typst template sets them too; and widow and orphan control is off in both engines (typst's is a cost, LibreOffice's a rule, and they broke pages apart).

- **typst** (`typst/`): the reference.
- **docx** (`docx/`): `reference.xml` (the Word styles, which fb render applies to pandoc's reference document: EB Garamond 14 pt, Body Text exact 672 twips with a 0.5 in first-line indent, First Paragraph without it, List Item, Block Text and footnotes exact 336 twips, headings) and `nmcca.lua` (cover with the two-column caption and the counsel block in a frame at the foot of the text area, Index of Brief with leader tabs, labelled headings with outline levels, signature block kept with the last paragraph, certificate on a new page; the cover, index and body as sections with rIdFtrNone / lower-roman from ii / arabic from 1 footers). The index page numbers come from fb render's multi-pass build (the filter writes heading needles to `$FORMBOOK_NEEDLES` and reads `$FORMBOOK_PAGES`); `render.sh`, `build-reference.sh` and the binary `reference.docx` are retired. The index is static text, not a TOC field: re-render after editing. Opened in LibreOffice only, not in Word.

BLOCKED (docx): none. `sh tools/check.sh <this-folder> --engine docx`: RESULT 11 checks passed, 0 failed.
