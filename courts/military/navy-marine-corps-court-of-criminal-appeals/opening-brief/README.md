# NMCCA: appellant's brief and assignments of error (opening-brief)

Court: U.S. Navy-Marine Corps Court of Criminal Appeals (`nmcca`). Doc type: opening brief.

## What is here

| Path | What |
|---|---|
| `typst/nmcca-opening-brief.typ` | The template: `nmcca-opening-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule ID below. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `exemplars/FILED-EXAMPLE-miles-201300272-opening-brief.pdf` | The filed exemplar (appellant's brief, *U.S. v. Miles*, NMCCA No. 201300272, 2013). Provenance in `exemplars/SOURCE.md`. |
| `samples/INPUT-miles-opening-brief.md` | Transcription of part of that exemplar (cover, index source, assignments, jurisdiction, statement of the case, the opening facts, summary, Argument I, conclusion, signature, certificate). |
| `samples/OUTPUT-miles-opening-brief.pdf` | Our render of the sample (12 pages). |
| `samples/OVERLAY-miles-opening-brief.pdf`, `.txt` | Red (ours) / blue (filed) overlay and the page map. |

File names follow the repo tools, not the shorter names in the brief: `tools/render.sh` writes `OUTPUT-<id>.pdf`, `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf/.txt`, so the id is `miles-opening-brief`.

Build and overlay (from the repo root, with the toolchain on PATH):

```sh
D=courts/military/navy-marine-corps-court-of-criminal-appeals/opening-brief
sh tools/render.sh $D samples/INPUT-miles-opening-brief.md     # -> samples/OUTPUT-miles-opening-brief.pdf
sh tools/overlay.sh $D miles-opening-brief                     # -> samples/OVERLAY-miles-opening-brief.pdf and .txt
```

`render.sh` compiles with vendored fonts only (`--ignore-system-fonts`) and treats any typst warning as a failure. Rendered 2026-10-14: no warnings; the PDF embeds only `EBGaramond` faces (see "Typeface" below).

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
| Typst family used | `EB Garamond` (`fonts/eb-garamond/`). No substitute: the court names no face, so the template keeps EB Garamond (`docs/FONTS.md`). |
| Fit to a named face | Not applicable. A Times-metric substitute (`Liberation Serif`) would also conform, but the rule does not require it (see open choice 3). |
| Checked | Rendered 2026-10-14 with `tools/render.sh`: 12 pages, no warnings. `pdffonts`: only EBGaramond Regular, Italic, Bold and BoldItalic, all embedded. Footnotes measured at 14 pt (same glyph height as body text). |

## Exemplar search (what was tried)

- CourtListener NMCCA filings: the search at `courtlistener.com` returned HTTP 403 to the fetch tool; web search for NMCCA appellant's briefs on CourtListener returned no brief.
- Navy JAG NMCCA page (`jag.navy.mil/.../code-05/nmcca/`): lists the docket, opinions and oral arguments; no briefs.
- Web searches for NMCCA appellant's briefs: found the Miles brief (used here) and unpublished NMCCA opinions only.
- The Miles brief was also found on a third-party mirror (`mirror.hep.gg`), now a 404; the ncsfreedom copy was used. It is saved as `exemplars/FILED-EXAMPLE-miles-201300272-opening-brief.pdf` (fetched again 2026-10-14; 63 pages, created 17 Dec 2013, as `exemplars/SOURCE.md` describes), which the overlay reads.

## Exemplar: what it settles and what it does not

The exemplar is a 2013 filing: 12-point Times New Roman, single-spaced, under the rules in force then. Only the 2022 rules govern the template's type size and spacing. The exemplar settles the layout the rules leave open: the cover and caption arrangement, the placement of the index and its page numbering (cover unnumbered, index in roman, body from 1), the bare sub-headings, footnote form, the signature block and the certificate.

## Page review (Gate 2)

Every page of `OUTPUT-miles-opening-brief.pdf` (12 pages) was rendered at 60 dpi with `pdftoppm -r 60` and looked at. The table is from the pass of 2026-10-14 that ran after the footnote-size fix (see "Changed 2026-10-14"). PDF page n is body page n-2 for n of 3 and up; the index prints roman "ii".

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover | Fits one page. Caption, NMCCA No., title, Before Panel No. 3, tried-at paragraph and counsel block all present. The counsel block sits directly under the tried-at paragraph rather than at the foot of the page (the `v(1fr)` spacer did not pin it). **OPEN**, cosmetic. |
| 2 | Index of Brief (roman "ii") | Generated from headings; page references match the body (Conclusion p. 9). The Argument point sub-entry is in capitals with no label. **OPEN**, cosmetic. |
| 3 | Assignments of error, jurisdiction (body p. 1) | Double-spaced, 14 pt. Issue I is flush left and II-V are first-line indented, as the sample writes them. Appendix I shows the issues as numbered items. **OPEN**, cosmetic (sample-driven). |
| 4-6 | Statement of the case, facts (body pp. 2-4) | Footnotes at 14 pt, single-spaced, superscript references. OK. |
| 7 | Summary of argument, begins mid-page (body p. 5) | Summary heading centred; points I-II in sentence form, with the same first-line-indent pattern as page 3 (point III begins on page 8). **OPEN**, cosmetic (sample-driven). |
| 8 | Summary end, Argument I opening (body p. 6) | "Standard of Review" and "Principles of Law" bare bold; argument heading bold italic with label I. OK. |
| 9 | Principles of Law, Quiroz factors (body p. 7) | The numbered list prints with default list markers at the body indent. OK. |
| 10 | Discussion, Conclusion (body p. 8) | "Discussion" bare; "A." labelled sub-heading; argument "Conclusion" bare; footnote 38 at 14 pt. OK. |
| 11 | Final "CONCLUSION", signature block (body p. 9) | The signature block sits with the conclusion on the same page. The stranded-signature layout finding of the earlier pass is gone. OK. |
| 12 | Certificate of filing and service (body p. 10) | Own page, numbered. Service line reads "Appellate Government Division on 16 December 2013." OK. |

Overlay: `OVERLAY-miles-opening-brief.txt` pairs each sample page with the filed page it shares the most words with. Pages 1-2 pair with the filed cover and index (word overlap 91% and 31%). The body pairs run 34-75%, because the sample is 2022-rule formatted (14 pt, double-spaced) and the filed page is 12-point single-spaced, so line and page breaks differ by design. Pages 11-12 both pair with filed page 63, the filing's last page. That pairing is by word overlap only and is not evidence that those pages match. The overlay is a diagnostic, not a score.

## Changed 2026-10-14

- **Footnote size.** The footnote entries rendered at about 12 pt (glyph boxes 15.5 pt high against 18.3 pt for body text), not the 14 pt Rule 17(c) requires for footnotes. Both templates now set `footnote.entry` text to `type-size`. Footnote boxes now match body text (18.3 pt). Page count is unchanged (12). Layout moved: the signature block now sits with the conclusion.
- **Exemplar restored.** `exemplars/FILED-EXAMPLE-miles-201300272-opening-brief.pdf` was missing from this folder, so the overlay could not run. It is the file `SOURCE.md` describes.

## Known gaps

- **Table of authorities** is not generated (NMCCA-CONT-002). Not needed for the sample (under 10,000 words), but a real brief over 10,000 words needs one.
- **Word count** is not computed or checked against the 15,000-word limit (NMCCA-FORM-005).
- **Cover counsel block** is not pinned to the foot of the cover (PDF page 1).
- **Argument point labels** are not repeated in the index.
- **Sample is partial.** Argument points II-V, the rest of the statement of facts (after the "mat room" paragraph, including the paragraphs describing the conduct), and most of the discussion are omitted. The sample keeps the headings, the first points and the closing conclusion. Points II-V are described in the summary only.
- **Font.** See "Typeface" above: no face is required, so EB Garamond (vendored in `fonts/`) stays.

## Open choices (for David)

1. **Issues format.** Rule 18.1(b)(2) says UPPER CASE; Appendix I shows bold italic sentence case. The template follows whatever the sample writes, so the choice is the sample's, not the template's. Which governs?
2. **Index of Brief.** Rule 18.1(b)(1) requires a table of cases and authorities for briefs over 10,000 words. Should the template generate it, or should it stay a sample-only concern?
3. **Font.** Rule 17(c) allows any 14-point proportional type, so EB Garamond (current) conforms. Switch to a Times-metric face (`Liberation Serif`, vendored) by preference, or keep EB Garamond?
