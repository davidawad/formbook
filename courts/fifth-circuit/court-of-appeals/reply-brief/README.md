# Fifth Circuit: reply brief (reply of the appellant, FRAP 28(c))

Template for the reply brief of an appellant in the U.S. Court of Appeals for the Fifth Circuit. Content-agnostic: every number is a named parameter at the top of `typst/ca5-reply-brief.typ` and traces to a rule or a style choice. The template is adapted from the sibling `../opening-brief/typst/ca5-opening-brief.typ`. The court-root `typst/` and `usage/` (older ca5 material) were not touched.

## Layout

| Path | What |
|---|---|
| `usage/SAMPLE-ca5-reply-brief-fisher2610536.pdf` | Filed exemplar: Reply of Plaintiff-Appellant Ellen Mae Fisher, *Fisher v. Texas Tech University Regents*, No. 26-10536 (5th Cir.), filed 2026-08-17, 37 pages, text layer present. |
| `usage/SOURCE.md` | Where the exemplar came from, the docket number, the filer, the date filed and the date fetched. |
| `usage/INPUT-ca5-reply-brief-fisher.md` | Markdown transcription of an excerpt of the exemplar: front matter, the procedural background, Argument point A, the conclusion, the signature, the certificate of compliance and the certificate of service. Follows the markdown contract of the ninth-circuit sample (frontmatter, `# Heading` sections, `toa:` citation links, `[^n]` footnotes). |
| `usage/OUTPUT-ca5-reply-brief-fisher.typst.pdf` | Render of the sample (10 pages). |
| `usage/OVERLAY-fisher-reply-brief.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar, and the page map from `tools/overlay.sh`. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/ca5-reply-brief.typ` | The template: `ca5-reply-brief(meta, md)`. |

Build (from the repo root, with typst 0.15.0 on PATH):

```sh
sh tools/render.sh courts/fifth-circuit/court-of-appeals/reply-brief usage/INPUT-ca5-reply-brief-fisher.md
sh tools/overlay.sh courts/fifth-circuit/court-of-appeals/reply-brief fisher-reply-brief
```

Typst runs with the vendored fonts only (`--ignore-system-fonts`); any typst warning fails the render. The font is EB Garamond (`fonts/eb-garamond/`), and cmarker 0.1.10 is vendored under `vendor/typst-packages/`. Both are the same choices as the ca5 opening-brief template.

## Typeface (fonts pass, 2026-10-14)

| Court requirement | Face the rules name | Substitute | Fit |
|---|---|---|---|
| CA5-FORM-005: proportionally spaced serif, 14 pt text, 12 pt footnotes (FRAP 32(a)(5)-(6); Checklist 2(a), 2(d)) | None. FRAP 32(a)(5)(A)-(B) allows any proportionally spaced face with serifs; Form 6 asks only for the program and font used. The local rule (5th Cir. R. 32.3) text was not fetched. | None needed: EB Garamond (`fonts/eb-garamond/`) kept | n/a (no court-named face; `docs/FONTS.md` "No face named") |

The rules name no face, so the template keeps EB Garamond in typst, latex and docx. The filed exemplar is set in Century Schoolbook; the rules allow it but do not require it, so the difference is a tier-2 visual choice, not a rule failure. Checked on the typst render: `pdffonts` lists only `EBGaramond` (Regular, Bold, Italic) and nothing else is embedded.

## Governing rules

Verified on 2026-10-14.

| ID | Requirement | Source | Verified |
|---|---|---|---|
| CA5-FORM-005 | Proportionally spaced serif type, 14 point or larger for text; 12 point or larger for footnotes. Plain roman, italics for case names. | FRAP 32(a)(5)(A) (14-point or larger; serifs required); FRAP 32(a)(6); Fifth Circuit checklist 2(a), 2(d). Checklist: https://www.ca5.uscourts.gov/docs/default-source/forms-and-documents---clerks-office/rules/brchecklist.pdf (Rev. 9/2024). | Checklist read 2026-10-14; FRAP 32(a)(5)(A) and (a)(6) read via Cornell LII (https://www.law.cornell.edu/rules/frap/rule_32) 2026-10-14. |
| CA5-FORM-004 | Double spaced. Quotations over two lines and footnotes may be single spaced. | Checklist 2(b); FRAP 32(a)(4). | Checklist, 2026-10-14. |
| CA5-FORM-003 | 1 inch margins on all four sides. | Checklist 2(c); FRAP 32(a)(4) ("Margins must be at least one inch on all four sides", read via Cornell LII). | 2026-10-14. |
| CA5-FORM-001 | 8½ × 11 inch paper. | Checklist 2(a). | Checklist, 2026-10-14. |
| CA5-LEN-002 | Reply brief: 15 pages, 650 lines of text, or 6,500 words. The template uses the word option and refuses to build a reply over 6,500 words. The count is from the markdown and matches an independent awk count (1,108 for the sample). | FRAP 32(a)(7)(B)(ii) ("no more than half of the type volume specified in Rule 32(a)(7)(B)(i)", read via Cornell LII); checklist 2(a) table. | 2026-10-14. |
| CA5-LEN-003 | Exempt from the word count: caption, certificate of interested persons, statement regarding oral argument, tables of contents and authorities, certificates, signature. | Checklist 2(g); FRAP 32(f). FRAP 32(f) itself was not fetched; the checklist describes it. | Checklist, 2026-10-14. |
| CA5-CONT-004 | Table of contents with page references; table of authorities (cases alphabetically, then statutes and other authorities), with the pages where each is cited. A reply brief must have both. | FRAP 28(c) ("A reply brief must contain a table of contents, with page references, and a table of authorities"); FRAP 28(a)(2)-(3); checklist 1(c)-(d). | FRAP 28(c) read via Cornell LII, 2026-10-14. |
| CA5-CONT-001 | Certificate of interested persons, placed before the table of contents. | Checklist 1(a) (cites 5th Cir. R. 28.2.1 for all briefs). | Checklist, 2026-10-14. The local rule text was not fetched. |
| CA5-CONT-002 | Statement regarding oral argument, before the table of contents. | Checklist 1(b) (cites 5th Cir. R. 28.2.3 and FRAP 34(a)(1)). | Checklist, 2026-10-14. The local rule text was not fetched. |
| CA5-CONT-003 | Front cover: case number at top; court name; title of the case; nature of the proceeding and the court below; title of the brief identifying the party; counsel's name, office address and telephone. | FRAP 32(a)(2); checklist 3(a). | Checklist, 2026-10-14. |
| CA5-CONT-005 | Argument, with the standard of review where one applies. A reply has no statement of jurisdiction, issues or case; the template does not require them. | FRAP 28(c) (a reply brief is not required to repeat the appellant's statements); checklist 1(i). | Checklist, 2026-10-14. |
| CA5-CONT-006 | Conclusion stating the relief sought; signature of counsel; certificate of service in the form of FRAP 25(d). | FRAP 28(a)(9) (via checklist 1(j)); FRAP 32(d); FRAP 25(d); checklist 1(k)-(l). | Checklist, 2026-10-14. |
| CA5-CONT-007 | Certificate of compliance: the word count, and the typeface and type style. | FRAP 32(g); 5th Cir. R. 32.3 (cited by checklist 1(m)). The local rule text was not fetched. | Checklist, 2026-10-14. |
| CA5-CONT-008 | Cover colour: gray for a reply brief of the appellant (paper copies only; not produced). | Checklist 3(c); FRAP 32(a)(2). | Checklist, 2026-10-14. |
| CA5-CONT-009 | Record citations in the form `ROA.123` (single-record) or `ROA.<docket>.123`. | 5th Cir. R. 28.2.2; checklist 2(h). | Checklist, 2026-10-14. |
| CA5-CONT-010 | Heading numbering. Argument point headings are lettered directly under the Argument (level 3: A., B.), as in the filed exemplar; sub-headings are 1., a. Elsewhere: A., 1., a., (1). Numbers are typed by the template, not the author. | Convention (exemplar), not a rule. | Exemplar. |

**Verification status.** The checklist (Rev. 9/2024) and FRAP 25(d), 28(c), 32(a)(4)-(6), 32(a)(7)(B)(ii) were read on 2026-10-14. The rule text of 5th Cir. R. 28.2.1, 28.2.2, 28.2.3 and 32.3, and of FRAP 28(a) (other than as quoted above), 32(d), 32(f), 32(g) and 34(a)(1), was **not** fetched; those IDs are verified only as the checklist cites them. Re-check against the current local rules before the template is relied on for filing.

**Note on the sibling README.** The ca5 opening-brief README cites FRAP 32(a)(7)(B)(iii) for the reply word limit. The reply limit is 32(a)(7)(B)(ii) (half of the principal limit). Subdivision (iii) is not used here.

## Exemplar settles only what the rules leave open

- The exemplar has **no** certificate of interested persons and **no** statement regarding oral argument. The checklist (1(a)-(b)) requires both for every brief, so the template keeps both (it renders them when a sample supplies them). The sample omits them because the exemplar does, and the overlay shows the difference. Counsel must include both.
- The exemplar uses point letters A to H directly under the Argument, with no Roman numerals. The template follows that (level 3 under Argument). The sibling opening-brief template uses Roman point numbers at level 2; that level is still available.
- The exemplar numbers its top-level sections I., II., III. (Procedural Background, Argument, Conclusion). The template prints the top-level headings unnumbered, as the sibling template does. This is a known difference.
- The exemplar is set in Century Schoolbook. The rules allow any proportional serif face at 14 point, and the vendored EB Garamond is used instead. The overlay will show the typeface difference; that is expected.
- The exemplar's signature stands alone on its own page (PDF page 35, printed 29). The template does not copy that: since 2026-10-16 it keeps the last body paragraph with the signature, so the Conclusion heading, its paragraph and the signature move to the next page together (PDF page 8 of the sample).

## What the overlay shows

`usage/OVERLAY-fisher-reply-brief.txt` maps each of the 10 sample pages to the exemplar page sharing the most words:

| Sample page | Content | Best exemplar page | Word overlap |
|---|---|---|---|
| 1 | Cover | 1 | 80.1% |
| 2 | Table of contents | 3 | 26.0% |
| 3 | Table of authorities | 5 | 21.2% |
| 4 | Procedural background; start of Argument A | 7 | 66.9% |
| 5 | Argument A (NiGen; footnotes 1 to 3) | 9 | 56.7% |
| 6 | Argument A (the AG letters; reply to the third-party retailers) | 10 | 75.6% |
| 7 | Argument A (block quotation from NiGen) | 11 | 74.3% |
| 8 | Conclusion and closing signature | 2 | 40.9% |
| 9 | Certificate of compliance | 36 | 32.5% |
| 10 | Certificate of service | 37 | 58.1% |

The overlay is a diagnostic, not a score. The low overlap on the table of contents and table of authorities is expected, since the exemplar's tables run on different page numbers and carry long dot leaders. The table-of-contents and table-of-authorities pages of the exemplar are on PDF pages 3 to 6; the map pairs them with the nearest body page, which is why the matches are weak. Page 8 pairs with the exemplar's page 2 (the end of its cover caption) because the conclusion repeats the party's name; the exemplar's conclusion is on its page 34 and its signature on page 35.

## Review (Gate 2): all 10 PDF pages rendered and looked at

Each page was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Page numbers below are PDF pages of the sample.

- PDF page 1 (cover): fits on one page; case number, court, caption, proceeding, brief title, counsel and date all on the page.
- PDF page 2 (table of contents, printed "i"): page numbers match the body (Procedural Background 1, Argument 1, point A 1, Conclusion 5, Certificate of Compliance 6, Certificate of Service 7). The point heading wraps and hangs under its label.
- PDF page 3 (table of authorities, printed "ii"): cases alphabetized, then statutes; the "passim" threshold (7 pages) is not reached in the sample. Page references match the body: Ex parte Young 2, 3, 4; NiGen 1, 2, 3, 4; Steel Co. 4.
- PDF page 4 (body 1): the procedural background; point A's heading is set in bold, lettered "A.", and hangs.
- PDF page 5 (body 2): footnotes 1 and 2 at 12 point, single spaced, at the foot of the page.
- PDF page 6 (body 3): double spaced, the "AG issued letters" paragraph; no widows.
- PDF page 7 (body 4): the block quotation is indented on both sides and single spaced (FRAP 32(a)(4)); the page ends after the argument, about a third blank, because the conclusion is kept with the signature.
- PDF page 8 (body 5): the Conclusion heading (centred), its paragraph, the date, "Respectfully submitted," and the signer block.
- PDF page 9 (certificate of compliance): the word count is 1,108, computed by the template from the markdown; an independent awk count of the same text gives 1,108.
- PDF page 10 (certificate of service): the two recipients follow the certificate, flush left, with the signer block.

Defects found and fixed during the first review (2026-10-14): none needed a change to the template after the first render. The one template change from the sibling was the word-limit check (`word-limit`), which panics above 6,500 words. For the fixes of 2026-10-16 see the verification pass below.

## Known gaps

- **Certificate of interested persons and statement regarding oral argument**: required by checklist 1(a)-(b); absent from the exemplar and therefore from the sample. The template renders them when present but does not enforce their presence. A filing must include both.
- **Excerpt**: the exemplar runs 37 pages; the sample carries the procedural background, Argument point A and the conclusion. Points B to H, and the body pages they occupy, are not transcribed. The argument's lettering is therefore complete in the template but the sample shows only A.
- **Cover colour and paper** (checklist 3(b)-(c), 4): gray cover, spiral binding and the paper-copy count are paper requirements and are not produced.
- **Word limit vs page limit**: the checklist allows a reply of 15 pages, 650 lines or 6,500 words. The template enforces the word option only. The 15-page option is not checked; a reply that uses it and exceeds 6,500 words will not build, which is the correct result under the word option but must be read against the page option when counsel files under it.
- **Record references** are typed by the author (`ROA.1177`); the template does not validate them.
- **Certificate typeface statement** names EB Garamond 14 point and footnotes 12 point, as the template sets them. If a different face is used in filing, the statement must change.
- **Word count**: the certificate of compliance uses the count computed from the markdown, not the PDF. Counsel must check it against the word processor before filing.
- **Not run**: `tools/check.sh` and `tools/check-selftest.sh` (no check contract exists for this doc type yet).

## Exemplar search log

- CourtListener search API, ca5 RECAP documents for "reply brief of appellant" (136 results, first 17 read on the first page of results): appellant's replies listed included Fisher v. Texas Tech (26-10536, Doc. 53), Anderton v. Dallas ISD (25-11351, Doc. 45), Yan v. State Bar of TX (26-10286, Doc. 90) and Payne v. City of Houston (26-20052, Doc. 53, an appellee's reply). Fisher and Anderton were downloaded and checked: both have a text layer. Fisher was chosen: 37 pages, a full cover, tables, argument, conclusion and both certificates, with a single-party appellant's reply. Yan and Payne were not downloaded.
- Web searches for federal Fifth Circuit reply briefs in 2025 and 2026 returned mostly dockets and non-reply filings; they did not add a usable exemplar.

## Verification pass 2026-10-16 (fb-595.26.5)

- Rendered: `sh tools/render.sh` (typst, exit 0, no warnings), 10 pages, same count as the committed PDF. Overlay rerun (`tools/overlay.sh`, exit 0); map above updated.
- Viewed: all 10 pages at 60 dpi before the fixes and all 10 again after them; the 10 overlay pages at 40 dpi; exemplar page 1 against our cover.
- Fixed in `typst/ca5-reply-brief.typ` (the same fixes as the opening-brief template): TOC and TOA titles now centred bold capitals like the other section titles; TOC and TOA rows are a grid with the page reference on the entry's last line (a wrapped TOA entry no longer strands its pages); more space above sub-headings (`heading-gap`) and no built-in heading sizes; the closing signature no longer stands alone on a page (it was alone on PDF page 8): the last body paragraph is kept with it, trailing footnote definitions excepted; certificate paragraphs flush left (fixes the indented first recipient line).
- latex engine re-rendered (`--engine latex`, exit 0, 11 pages); its pages were not reviewed in this pass.
- Gaps that remain: on the cover the brief title and the counsel block touch, because the long appellee caption fills the page (tier 2, open); certificate of interested persons and oral-argument statement absent from the sample (as in the exemplar); the sample is an excerpt; typeface differs from the exemplar (tier 2 choice); docx not rendered (no soffice).

## Status

- exemplar: yes (`usage/SAMPLE-ca5-reply-brief-fisher2610536.pdf`)
- render: ok (`usage/OUTPUT-ca5-reply-brief-fisher.typst.pdf`, 10 pages, no typst warnings)
- overlay: ok (`usage/OVERLAY-fisher-reply-brief.pdf`, page map in `-overlay.txt`)
- pages reviewed: 10 of 10

## Engines

- **latex** (`latex/template.tex`, `latex/ca5-brief.lua`; `sh tools/render.sh --engine latex`): matches the typst form for the mandated items: EB Garamond from `fonts/` (`fontdir`), 14 pt text, 12 pt footnotes, 30.8 pt double pitch, 17 pt single pitch for headings, quotations and certificates, 1 in margins, letter paper, roman front pages and arabic body from 1, certificates on their own pages, TOC and TOA built from the headings and `toa:` citations (two tectonic passes). Differs: the TOA page list is read from the previous pass, so it settles on the second run; the word count is computed from the markdown body and may differ from typst by a few words. Open tier-1 findings: see the PR description and the Gate 2 review rows.
- **docx** (`docx/reference.docx`, built by `docx/make-reference.sh`; `docx/ca5-docx.lua`): styles only (font, sizes, spacing, margins, heading styles). BLOCKED: `<id>.docx.pdf` (no LibreOffice on this box: `soffice` not found, and conda-forge has no package), so Gates 0 and 1 cannot run on the docx. Not in the docx yet: the cover and caption layout, the front statements from frontmatter, the TOC and TOA (TOA citations are plain text), heading numbering labels, the page-number footer, and the generated certificates of service and compliance from frontmatter (the body certificates are in).
