# NMCCA: appellant's brief and assignments of error (opening-brief)

Court: U.S. Navy-Marine Corps Court of Criminal Appeals (`nmcca`). Doc type: opening brief.

## What is here

| Path | What |
|---|---|
| `typst/nmcca-opening-brief.typ` | The template: `nmcca-opening-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule ID below. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `usage/FILED-EXAMPLE-opening-brief.pdf` | The filed exemplar (appellant's brief, *U.S. v. Miles*, NMCCA No. 201300272, 2013). Provenance in `usage/SOURCE.md`. |
| `usage/INPUT-opening-brief.md` | Transcription of part of that exemplar (cover, index source, assignments, jurisdiction, statement of the case, the opening facts, summary, Argument I, conclusion, signature, certificate). |
| `usage/OUTPUT-opening-brief.typst.pdf` | Our render of the sample (16 pages). |
| `docx/nmcca.lua`, `docx/reference.xml` | The docx engine (see "Engines"); `usage/OUTPUT-opening-brief.docx` and `.docx.pdf` are its output. |
| `eval.yaml` | `params.cross_engine: gate` (Gate 4, XENG-001..003). |

Build and overlay (from the repo root, with the toolchain on PATH):

```sh
D=courts/military/navy-marine-corps-court-of-criminal-appeals/opening-brief
sh tools/render.sh $D usage/INPUT-opening-brief.md     # -> usage/OUTPUT-opening-brief.typst.pdf
just overlay $D                                        # -> .overlay/<doc path>/OVERLAY-opening-brief.pdf and .txt (not committed)
```

`render.sh` compiles with vendored fonts only (`--ignore-system-fonts`) and treats any typst warning as a failure. Rendered 2026-10-22: no warnings; the PDF embeds only `LiberationMono` faces (see "Typeface" below).

## Governing rules

Primary source: **NMCCA Rules of Appellate Procedure (2022)**, effective 1 June 2022, PDF at
https://stjececmsdusgva001.blob.core.usgovcloudapi.net/public/documents/2022_NMCCA_Rules_of_App_Proc.pdf
(the newest version found; the Navy JAG NMCCA page links to it. Rule numbers and page references below are to that PDF; text checked by extraction on 2026-10-14). Secondary: 32 CFR Part 150, § 150.15 (eCFR/GovInfo 2025 edition), which requires briefs to be "double-spaced on white paper" and does not set type size.

| ID | Requirement | Source |
|---|---|---|
| NMCCA-FORM-001 | All printed matter, footnotes included, in 14-point proportional type. Courier and similar are not acceptable. | Rule 17(c), p. 28 |
| NMCCA-FORM-002 | Text double-spaced; the caption, headers and signature blocks are excepted. Footnotes are single-spaced here (convention; the rule is silent). | Rule 17(a)-(c), pp. 27-28 |
| NMCCA-FORM-003 | 8.5 x 11 white paper. First page: at least 2-inch bottom margin for filing stamps. Other pages: 1-inch bottom margin. All pages except the first numbered; page numbers may sit in the margin, but no text (footnotes included) in the bottom margin. Top and side margins are not stated; 1 inch is used. | Rule 17(a)-(c), pp. 27-28 |
| NMCCA-FORM-004 | Caption includes the NMCCA number and the assigned panel; cover layout follows Appendix I (court name, "Before [Panel]", parties, title, "TO THE HONORABLE ...", counsel). | Rule 17(c); Appendix I, p. 93 |
| NMCCA-FORM-005 | Principal briefs: 15,000 words or fewer, excluding caption, footnotes, indexes, certificates and appendices. Footnotes do not count. The template does not count words (see gaps). | Rule 17 "Length", p. 28 |
| NMCCA-CONT-001 | Required order: index (where over 10,000 words), issues presented, statement of statutory jurisdiction, statement of the case, statement of facts, summary of argument, argument, conclusion, certificate of service. The template fails the build if a required section is missing. | Rule 18.1(b)(1)-(9), pp. 31-32; Appendix I |
| NMCCA-CONT-002 | Index with page references and a table of cases, statutes and other authorities, required when the brief is over 10,000 words. The template generates the index from headings; it does not generate a table of authorities. | Rule 18.1(b)(1), p. 31 |
| NMCCA-CONT-003 | Issues presented: each error as a question in UPPER CASE letters, numbered with Roman numerals. **Conflict:** Appendix I illustrates the issues in bold, italic, sentence case. The template prints what the sample gives it; see open choices. | Rule 18.1(b)(2), p. 31; Appendix I, p. 94 |
| NMCCA-CONT-004 | Argument: each error in bold italic sentence case, argued separately. The template labels Argument points I., A., 1., a. (a convention, not stated in the rules); "Standard of Review", "Principles of Law", "Discussion" and "Conclusion" stay bare, as in the filed brief. | Appendix I, p. 95 |
| NMCCA-CONT-005 | Argument states the standard of review for each issue. The build fails without a "Standard of Review" heading. | Rule 18.1(b)(7), p. 32 |
| NMCCA-CONT-006 | Conclusion states the relief sought for each issue with specificity. | Rule 18.1(b)(8), p. 32 |
| NMCCA-CONT-007 | Signature block ("Respectfully submitted." and the counsel block) after the conclusion. | Appendix I, p. 96 |
| NMCCA-CONT-008 | Certificate of filing and service on opposing counsel, in the Appendix I form. The service recipient is a frontmatter field (`served_on`). | Rule 18.1(b)(9), p. 32; Appendix I, p. 96 |

## Typeface

| Item | Value |
|---|---|
| Rule text | Rule 17(c), p. 28: "All printed matter, including footnotes, must appear in 14-point proportional type, e.g., Times New Roman, Century Schoolbook, etc. Courier, Courier New, and similar non-proportional fonts are not acceptable." (text read with `pdftotext`, 2026-10-14) |
| Face the rule requires | None. The named faces are examples, and the rule allows any 14-point proportional type. |
| Typst family used | `Liberation Mono` (`fonts/liberation-mono/`), in typst and docx. Set on 2026-10-17 (commit "align templates with audited exemplar fonts"): `data/exemplar-fonts.json` records the filed exemplar as Courier New and maps it to Liberation Mono, and `fb lint fonts` (run by `fb check`) fails the folder unless the template declares that face. **Conflict with NMCCA-FORM-001**: Rule 17(c) bars Courier and similar non-proportional type, so a brief in this face would not conform; the exemplar predates the 2022 rules. Open choice 3. Before 2026-10-17 the template used EB Garamond. |
| Fit to a named face | Liberation Mono is metric-compatible with Courier New (the exemplar face). |
| Checked | Rendered 2026-10-22 with `tools/render.sh`: 16 pages, no warnings. `pdffonts` (typst and docx): only LiberationMono Regular, Bold, Italic and BoldItalic, all embedded. |

## Exemplar search (what was tried)

- CourtListener NMCCA filings: the search at `courtlistener.com` returned HTTP 403 to the fetch tool; web search for NMCCA appellant's briefs on CourtListener returned no brief.
- Navy JAG NMCCA page (`jag.navy.mil/.../code-05/nmcca/`): lists the docket, opinions and oral arguments; no briefs.
- Web searches for NMCCA appellant's briefs: found the Miles brief (used here) and unpublished NMCCA opinions only.
- The Miles brief was also found on a third-party mirror (`mirror.hep.gg`), now a 404; the ncsfreedom copy was used. It is saved as `usage/FILED-EXAMPLE-opening-brief.pdf` (fetched again 2026-10-14; 63 pages, created 17 Dec 2013, as `usage/SOURCE.md` describes), which the overlay reads.

## Exemplar: what it settles and what it does not

The exemplar is a 2013 filing: 12-point Times New Roman, single-spaced, under the rules in force then. Only the 2022 rules govern the template's type size and spacing. The exemplar settles the layout the rules leave open: the cover and caption arrangement, the placement of the index and its page numbering (cover unnumbered, index in roman, body from 1), the bare sub-headings, footnote form, the signature block and the certificate.

## Page review (Gate 2)

Re-reviewed 2026-10-22 after the port to the cross-engine layout model (fb-595.54.7): every page of `OUTPUT-opening-brief.typst.pdf` and of `OUTPUT-opening-brief.docx.pdf` (16 pages each) was rendered at 60 dpi (`pdftoppm -r 60`) and looked at side by side. The two engines set every page alike (same lines, same page breaks, same footnotes per page; `fb diff --engines`: baselines within 0.04 pt). The face is Liberation Mono (see "Typeface"), which makes the brief 16 pages where EB Garamond made 12. PDF pages 3-15 are body pages 1-13; PDF page 16 is the certificate (page 14).

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover | Court name, Before Panel No. 3, caption in two columns on one line grid, title, "To the Honorable" lines, tried-at paragraph; the counsel block sits at the foot of the cover (2 in bottom margin) in both engines; "1254 Charles Morris Street SE, Suite 100" wraps in the 3.5 in column. OK. |
| 2 | Index of Brief (roman "ii") | Generated from the headings; page numbers match the body (Conclusion p. 13); the Argument point now carries its "I." label, the text hanging after it. OK. |
| 3 | Assignments of error, jurisdiction (body p. 1) | Issue I flush left, II-V first-line indented, as the sample writes them (paragraphs, not a list). **OPEN**, cosmetic (sample-driven). |
| 4-9 | Statement of the case, facts, summary of argument (body pp. 2-7) | Double-spaced 14 pt; footnotes 14 pt single-spaced under a short rule, numbers raised; the long footnote 11 stays whole on page 6. Summary points I-V as paragraphs (same pattern as page 3). OK. |
| 10-11 | Summary end, Argument, point I, Standard of Review (body pp. 8-9) | Point heading bold italic with label I.; "Standard of Review" and "Principles of Law" bare bold. OK. |
| 12-13 | Principles of Law, the five Quiroz factors (body pp. 10-11) | The list is numbered in a 0.5 in box with the text hanging. OK. |
| 14 | Discussion, "A." sub-heading, argument conclusion (body p. 12) | Labels and bare headings per NMCCA-CONT-004. OK. |
| 15 | Final "CONCLUSION" and signature block (body p. 13) | The last paragraph and the signature block stay together. OK. |
| 16 | Certificate of filing and service (body p. 14) | Own page, numbered; "Appellate Government Division on 16 December 2013." OK. |

Overlay: not re-run for this pass (`just overlay <this-folder>` writes it to the gitignored `.overlay/`). The exemplar is a 2013 filing (12 pt, single-spaced), so body pages do not line up with it by design; the cover and index layout were compared with it by eye (FILED-EXAMPLE pages 1-2): same parts in the same order.

## Changed 2026-10-14

- **Footnote size.** The footnote entries rendered at about 12 pt (glyph boxes 15.5 pt high against 18.3 pt for body text), not the 14 pt Rule 17(c) requires for footnotes. Both templates now set `footnote.entry` text to `type-size`. Footnote boxes now match body text (18.3 pt). Page count is unchanged (12). Layout moved: the signature block now sits with the conclusion.
- **Exemplar restored.** `usage/FILED-EXAMPLE-opening-brief.pdf` was missing from this folder, so the overlay could not run. It is the file `SOURCE.md` describes.

## Known gaps

- **Table of authorities** is not generated (NMCCA-CONT-002). Not needed for the sample (under 10,000 words), but a real brief over 10,000 words needs one.
- **Word count** is not computed or checked against the 15,000-word limit (NMCCA-FORM-005).
- **Sample is partial.** Argument points II-V, the rest of the statement of facts (after the "mat room" paragraph, including the paragraphs describing the conduct), and most of the discussion are omitted. The sample keeps the headings, the first points and the closing conclusion. Points II-V are described in the summary only.
- **Font.** See "Typeface" above: the template declares Liberation Mono (the audited exemplar face), which NMCCA-FORM-001 does not allow. Open choice 3.

## Open choices (for David)

1. **Issues format.** Rule 18.1(b)(2) says UPPER CASE; Appendix I shows bold italic sentence case. The template follows whatever the sample writes, so the choice is the sample's, not the template's. Which governs?
2. **Index of Brief.** Rule 18.1(b)(1) requires a table of cases and authorities for briefs over 10,000 words. Should the template generate it, or should it stay a sample-only concern?
3. **Font.** The font audit (`data/exemplar-fonts.json`) makes this template declare Liberation Mono (Courier New metrics, as the 2013 exemplar), but Rule 17(c) (NMCCA-FORM-001) bars Courier and similar non-proportional fonts. Should the audit entry be overridden so the template returns to a proportional face (EB Garamond, as the answering brief, or a Times-metric face), or does the exemplar face stand? Both engines follow whichever face the template declares.

## Engines

Both engines are on the shared cross-engine layout model (fb-595.54.7; `lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Adopting the reference breaker"): Liberation Mono 14 pt everywhere (footnotes too; see "Typeface"), body lines in 33.6 pt boxes (double spacing), the cover, headings, index, quotations, footnotes and signature blocks in 16.8 pt boxes, first-fit line breaking, no kerning and no hyphenation. The docx render breaks every line and page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, XENG-001..003 PASS). Widow and orphan control is off in both engines (typst's is a cost that footnotes can override, LibreOffice's a rule; they broke pages apart). typst sets standard ligatures, as LibreOffice does whatever the file says (Liberation Mono has none).

- **typst** (`typst/`): the reference.
- **docx** (`docx/`): `reference.xml` (the Word styles, which fb render applies to pandoc's reference document: Liberation Mono 14 pt, Body Text exact 672 twips with a 0.5 in first-line indent, First Paragraph without it, List Item, Block Text and footnotes exact 336 twips, headings) and `nmcca.lua` (cover with the two-column caption and the counsel block in a frame at the foot of the text area, Index of Brief with leader tabs, labelled headings with outline levels, signature block kept with the last paragraph, certificate on a new page; the cover, index and body as sections with rIdFtrNone / lower-roman from ii / arabic from 1 footers). The index page numbers come from fb render's multi-pass build (the filter writes heading needles to `$FORMBOOK_NEEDLES` and reads `$FORMBOOK_PAGES`); `render.sh`, `build-reference.sh` and the binary `reference.docx` are retired. The index is static text, not a TOC field: re-render after editing. Opened in LibreOffice only, not in Word.

BLOCKED (docx): none. `sh tools/check.sh <this-folder> --engine docx`: RESULT 11 checks passed, 0 failed.
