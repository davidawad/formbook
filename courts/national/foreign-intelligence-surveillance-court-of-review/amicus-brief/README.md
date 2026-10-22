# FISCR (United States Foreign Intelligence Surveillance Court of Review): amicus brief

- Court: `fiscr`, FISCR (`courts/national/foreign-intelligence-surveillance-court-of-review/`)
- Doc type: `amicus-brief`. A brief of a court-appointed amicus curiae in an FISCR matter, filed under the FISCR Rules of Procedure, Rule 15(d). Publicly released amicus filings only.
- Exemplar: `usage/FILED-EXAMPLE-amicus-brief.pdf` (*In re Certification of Questions of Law to the FISCR*, No. FISCR 18-01, filed 2018-02-23 by Prof. Laura K. Donohue, a court-appointed amicus). Provenance in `usage/SOURCE.md`.
- Sample: `usage/INPUT-amicus-brief.md`, a transcription of the filed brief's real structure with the body excerpted (see Known gaps).
- Status: template built; rendered, overlaid and every page reviewed (below). `court.json` of the court is untouched and this folder has no status field.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `fiscr-brief`. |
| `typst/fiscr-amicus-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit-appointed` (13,000), `word-limit-other` (6,500), `required-sections`, `needs-standard-of-review = false`, `addendum = "optional"`. |
| `usage/INPUT-amicus-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-amicus-brief.typst.pdf` | `sh tools/render.sh courts/national/foreign-intelligence-surveillance-court-of-review/amicus-brief usage/INPUT-amicus-brief.md` (13 pages on the earlier EB Garamond render; the committed Times New Roman render is 12). |
| `usage/OVERLAY-donohue-amicus-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/national/foreign-intelligence-surveillance-court-of-review/amicus-brief donohue-amicus-brief` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

File names follow the repo tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.md` / `<id>-overlay.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Primary source: the FISCR Rules of Procedure, as posted by the court at <https://www.fisc.uscourts.gov/sites/default/files/Rules%20of%20Procedure.pdf> (linked from <https://www.fisc.uscourts.gov/rules-procedure>). The PDF is the Court of Review's rules (its title page reads "United States Foreign Intelligence Surveillance Court of Review, Rules of Procedure"; footer "May-18"). Read and checked on 2026-10-14. Rule numbers below are the rules' own. The filed exemplar cites them as "FISC Ct. Rev. R. P."; the template uses that form in the certificate.

FRAP text is incorporated by FISCR R. 14(d) and 15(d)(2). Checked against <https://www.law.cornell.edu/rules/frap/rule_32> and <https://www.law.cornell.edu/rules/frap/rule_29> on 2026-10-14.

## Typeface

| Item | Value |
|---|---|
| Face required by the court | None. FISCR R. 9(c) (paper, double spacing, one-inch margins, page numbers) names no face; R. 15(d)(2) defers to FRAP 32(a)(5), which requires a proportionally spaced serif face at 14 point or larger and names no face. Rechecked against the posted rules text on 2026-10-14. |
| Vendored substitute | None needed. No court-named face, so the template sets the house standard, Times New Roman (`docs/FONTS.md` rule 6; the pinned install, Liberation Serif as fallback). |
| Typst family in `typst/fiscr-amicus-brief.typ` | `("Times New Roman", "Liberation Serif")` (`font-family`) |
| Fit | n/a (no court-named face to substitute) |

The filed exemplar's embedded font list names Times New Roman (non-embedded) for body text. That is one filer's choice, not a rule, and the exemplar is the only filer available for this doc type; it is a tier-3 style and is not chased. The template sets Times New Roman anyway, under `docs/FONTS.md` rule 6. The 14-point size comes from FRAP 32(a)(5)(A) and is kept.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FISCR R. 9(c)(1) | 8½ × 11 inch opaque white paper | `page(paper: "us-letter")` |
| FISCR R. 9(c)(2) | Typed double-spaced; quotations over two lines may be indented and single-spaced | `body-leading`, `single-leading`, quotation style |
| FISCR R. 9(c)(3) | Margins of at least one inch on all four sides | `page-margin = 1in` |
| FISCR R. 9(c)(4) | Page numbered in the lower margin | footer, centered |
| FISCR R. 9(c), 15(d)(2); FRAP 32(a)(5)(A) | Proportionally spaced serif face, 14-point or larger | `font-family` (Times New Roman; no face named, see Typeface), `type-size = 14pt`, footnotes 14 pt |
| FRAP 32(a)(6) | Plain roman; italics or bold for emphasis; case names italic | markdown emphasis; the template does not guess case names |
| FISCR R. 15(d)(1); 14(a)(2) | Amicus brief must conform to R. 14(a)(2)-(8) and (10); (A) jurisdictional statement, (B) statement of the issues and (C) standard of review need not appear | `required-sections` (no jurisdiction or issues section), `needs-standard-of-review = false` |
| FISCR R. 14(a)(2) | Table of contents, with page references | `toc-section` (generated) |
| FISCR R. 14(a)(3) | Table of authorities with page references | `toa-section`, built from the `toa:` links in the body |
| FISCR R. 14(a)(6) | Statement of the case: facts, procedural history, rulings presented | `required-sections`: the heading must be "Statement of the Case" or "Introduction". The filed exemplar has only an Introduction. See Known gaps 2. |
| FISCR R. 14(a)(7) | Summary of the argument (not a repeat of the headings) | `required-sections` |
| FISCR R. 14(a)(8) | Argument, with the authorities relied on | `required-sections` |
| FISCR R. 14(a)(9) | Conclusion | not required by the literal text of R. 15(d)(1); the template renders a Conclusion when the body has one, and the signature block after it. See Known gaps 1. |
| FISCR R. 14(a)(10); FRAP 32(g)(1); Form 6 | Certificate of compliance, with word count and the statement that the word count of the word-processing system was relied on | `certificate-of-compliance` |
| FISCR R. 15(d)(2); FRAP 32(a)(7)(B)(i) | Court-appointed amicus: 13,000 words | `word-limit-appointed`, when `court_appointed: true` |
| FISCR R. 15(d)(2); FRAP 29(a)(5) | Amicus not appointed by the court: one-half of the principal-brief limit, 6,500 words | `word-limit-other`, when `court_appointed: false` |
| FRAP 32(f) | Excluded from the count: cover, disclosure statement, TOC, TOA, statement regarding oral argument, addendum with statutes, certificate, signature block, proof of service. Headings, footnotes and quotations are counted. | Oral-argument statement removed before counting; certificates, signature, TOC, TOA and addendum are generated outside the counted body; headings, footnotes and quotations are counted |
| FISCR R. 10(a), (c) | Serve the government through the Litigation Security Group; a certificate of service specifying the time and manner of service | `certificate-of-service` (time printed when given; see Known gaps 8) |
| FISCR R. 12 | Corporate disclosure statement: a nongovernmental corporate party only; not in the list R. 15(d)(1) applies to amici | optional `disclosure` field, rendered only when given |
| FISCR R. 9(d), (e) | Contact information and security-clearance statement: stated for a party (R. 9(d)(1) names "a party other than the government") | not generated. Cover shows counsel name, address, telephone and email (FRAP 32(a)(2)(F) convention). See Known gaps 5. |
| FISCR R. 15(e) | Oral argument: the Court decides whether to hear it | the statement regarding oral argument is a front-matter section (the filer's request), not a rule-driven field |

## Front-matter order (from the exemplar)

Cover (page 1, unnumbered); then, in roman numerals from ii: Statement Regarding Oral Argument, Question Presented, Table of Contents, Table of Authorities, Identity and Interest of Amicus Curiae; then the body in arabic numerals from 1; then the signature block, Certificate of Compliance and Certificate of Service. The template takes the three front sections out of the markdown by heading name (`take-section`), so their position does not depend on where the sample puts them. The identity section follows the TOA, as in the filed brief.

## Overlay

`usage/OVERLAY-donohue-amicus-brief.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run (word overlap in parentheses; pdf page indices):

- Ours p.1 ↔ filed p.1 (100%), p.2 ↔ p.2 (100%), p.3 ↔ p.3 (100%): cover, statement regarding oral argument, question presented.
- p.4 ↔ filed p.5 (30%): table of contents. The filed TOC has its own layout and page numbers; low overlap is expected.
- p.5 ↔ filed p.15 (11%): table of authorities. The filed TOA runs over several pages with a different entry layout, and this sample cites only nine authorities.
- p.6 ↔ filed p.14 (100%): the identity section (filed page xiv).
- p.7 ↔ filed p.15 (58%), p.8 ↔ filed p.17 (66%): introduction and summary; the same passages.
- p.9 ↔ filed p.39 (47%), p.10 ↔ filed p.41 (53%): Argument II (Scalia, Locke, Bentham) and III (the government's position).
- p.11 ↔ filed p.1 (26%): conclusion and signature block. The filed signature page is a scan with no text layer, so there is nothing to pair with.
- p.12 ↔ filed p.1 (12%), p.13 ↔ filed p.3 (18%): certificate of compliance and certificate of service. The filed certificates are scanned images with no text layer; the low overlap is expected.

## Page review (Gate 2)

Every page of `OUTPUT-amicus-brief.typst.pdf` was rendered at 60 dpi and viewed (13 of 13), after the last template change and again on 2026-10-14 in the fonts pass (no font change; the court names no face). Typst printed no warnings. Fonts embedded (`pdffonts`): EB Garamond only. (This review is of the earlier EB Garamond render, before fb-595.68; the committed render embeds TimesNewRomanPSMT and is 12 pages.)

| PDF page | Printed page | Content | Result |
|---|---|---|---|
| 1 | (none) | Cover: docket number, court, caption, proceeding, brief title, counsel, date | OK. One page; court name wraps to two lines. |
| 2 | ii | Statement Regarding Oral Argument | OK. |
| 3 | iii | Question Presented | OK. |
| 4 | iv | Table of Contents | OK after a fix: the page number of TOC entry II had wrapped onto its own line; the page box is narrower now. Front-matter entries are listed as in the filed TOC. |
| 5 | v | Table of Authorities | OK. Sorted by kind; page numbers from the body. |
| 6 | vi | Identity and Interest of Amicus Curiae | OK. Front matter (roman numeral vi), as in the filed brief. |
| 7 | 1 | Introduction; Summary of the Argument (start); footnote 1 | OK. Footnote at 14 pt; the marker and text are separated. |
| 8 | 2 | Summary (end); Argument heading; point I heading and first paragraph | OK. |
| 9 | 3 | Point II heading (sticky with its text); the Scalia and Locke paragraphs; the start of the Bentham block quotation | OK. |
| 10 | 4 | Bentham quotation (end); point III heading and first paragraph | OK. |
| 11 | 5 | Conclusion; signature block | OK after a fix: the Conclusion paragraph was on page 4 and its signature block alone on page 5 (a footnote definition at the end of the body defeated the keep-with-signature rule). The paragraph and block now move together. ACCEPTED: page 4 ends with white space because the Conclusion heading moves with the paragraph. |
| 12 | 6 | Certificate of Compliance (Form 6 wording, drawn check boxes, signature) | OK. The word count (1,170) is the template's count of this excerpt; it is not the filed brief's count (8,539, certified in the exemplar). |
| 13 | 7 | Certificate of Service | OK. The list of recipients is from the frontmatter. |

Tier-2 findings (OPEN or ACCEPTED):

- ACCEPTED: the sample has two point headings (I. and II. in the template's numbering), while the filed brief numbers its points I to V; the template numbers points in order, and the sample omits Parts I.A-III.
- Resolved (was ACCEPTED): typeface. The filed brief sets 14-point Times New Roman (its certificate says so; its font list is Times New Roman, non-embedded); the template used EB Garamond, which FRAP 32(a)(5)(A) and FISCR R. 9(c) and 15(d)(2) allow, and now sets Times New Roman (`docs/FONTS.md` rule 6, see Typeface).
- ACCEPTED: the page-numbering and point-numbering differences above are the excerpt's, not the template's. The cover's exact layout is not reproduced (Known gaps 4); the template's cover is the ca1 cover adapted to FISCR's caption.

## Known gaps

1. The FISCR R. 15(d)(1) list, read literally, requires R. 14(a)(2)-(8) and (10). That omits (9), the Conclusion, and (1), the disclosure statement. The template does not require a Conclusion or disclosure statement; the filed brief has a Conclusion and the sample keeps one. If David reads the rule as meaning the conclusion is required, the template already renders it (no change needed); if he reads it as optional, it is already optional.
2. Statement of the case (R. 14(a)(6)). The filed brief has no heading by that name; its Introduction sets out the posture, and "Identity and Interest" comes before it. The template accepts "Statement of the Case" or "Introduction" to satisfy this requirement. A stricter reading would require a separate Statement of the Case heading, and the filed brief would then fail the template. This is a judgment call for David: accept Introduction as the statement of the case (current), or require the heading.
3. The certificate of compliance in the filed brief cites "FISC Ct. Rev. R. P. 15(b)(A)-(C)" (the exceptions are in 15(d)(1)(A)-(C) of the rules) and "Fed. R. App. P. 29(d)" (the length rule is 29(a)(5)). The template uses the rules' numbers, not the filed brief's.
4. The cover carries the FRAP 32(a)(2) items in the order of the ca1 cover template, with FISCR's caption. The filed cover's exact layout is not copied (no coordinates are measured off the exemplar).
5. Rule 9(e) (security-clearance statement) and Rule 9(d)(1) (contact information) are written for a party other than the government, not an amicus. The template does not generate them. The cover and signature give counsel's name, address, telephone and email. Whether an amicus must give the clearance statement is a question for David.
6. Signature: the template leaves a blank line for a handwritten signature. It does not insert an electronic "/s/" signature, because the filed brief is hand-signed and the Clerk's electronic-filing approval (R. 9(b)(2)) is not in the sources checked.
7. The sample is an excerpt, not the whole brief. It transcribes the cover, oral-argument statement, question presented, identity, introduction (with footnote 1), summary, Argument points I (the first paragraph only) and II and III in part, the conclusion, the signature and both certificates. Omitted: the rest of the Argument, footnotes 2 and 23 to 26, the Summary's middle paragraph, the TOC and TOA as filed (the template generates those), and the appendix. The sample's TOA lists only the authorities it cites.
8. Certificate of service: FISCR R. 10(c) requires the time and manner of service. The filed certificate gives the date and the manner but not a time; the sample follows the filed certificate, so no time is printed. The template prints a time when `service.time` is given.
9. The conclusion, the signature block and both certificates in the filed brief are scanned images with no text layer. The sample transcribes them by reading the page images (pages 44-46 of the PDF). The transcription is not OCR and has not been checked against a second reading. The conclusion is in the sample; the certificates are generated by the template with the template's own wording.
10. Footnotes 2 and 23 to 26 of the filed brief are not all transcribed (the sample has footnote 1). The filed "Eagan" (for Egan) is kept as filed in the sample.
11. Only one exemplar is used, from one filer (Prof. Donohue, court-appointed). The Reporters Committee brief in the same docket (a proposed brief attached to a motion, marked "[PROPOSED]") is a second FISCR amicus filing and is not used for comparison (see `usage/SOURCE.md`). Tier-2 comparison is against this one exemplar only.
12. Word limit: the template counts the body the way FRAP 32(f) counts it; it has not been cross-checked against the rendered PDF's text. The 13,000-word limit applies to the court-appointed brief; for a non-appointed amicus the 6,500-word limit applies (the template chooses from `court_appointed`).
13. The FISCR rules used are the version posted as a PDF on the court's site (footer "May-18"). The rules page's text says its current Rules took effect November 1, 2010, and that text refers to the FISC rules. Which version controls was not resolved; a later amendment was not searched for beyond the court's site.

## Engines

**docx** (checked with LibreOffice only; Word is not available here). Build: `sh tools/render.sh --engine docx <this folder> usage/INPUT-amicus-brief.md`, which runs fb render (`tools/fb`). Files: `docx/reference.xml` (the Word styles; fb render builds `reference.docx` from it, `tools/fb/src/docxref.rs`: Times New Roman 14 pt, the typst face, exact double spacing, the front-matter and heading styles, a PAGE footer and an empty cover footer); `docx/fiscr-amicus.lua` (cover, sections, front matter, body, signature, certificates). fb render renders pass 1, finds the page of each heading and authority in the LibreOffice PDF (the needles the filter writes), and renders again with those pages until they settle (`docx/render.sh`, `pages.sh` and `pages.awk` did this until fb-595.68.4). The table of contents and table of authorities are static text with those page numbers, not TOC/TOA fields. Output: `usage/OUTPUT-amicus-brief.docx` and `.docx.pdf` (13 pages, every page viewed as PNG at 60 dpi against the typst render). Fonts in the PDF: Times New Roman only.

What matches typst: page size, one-inch margins, 14 pt body and footnotes, double spacing, single-spaced headings, quotations and front matter; cover lines and their order; roman numbers from ii, arabic from 1 in the body; the same section order; TOC and TOA entries and page numbers (for this render); the word count (1,170, the same as the typst count) and certificate wording.

What differs, and why:
- Pagination is LibreOffice's, not typst's. Line breaks fall differently in places, so some citations move: "50 U.S.C. § 1803" is on body page 3 here (vi, 3 in the TOA) and on page 2 in typst (vi, 2). Word may paginate differently again, and the static TOC and TOA numbers would then be off by a page until someone checks them.
- Checkboxes in the certificate of compliance are the text "[X]", not drawn boxes. A drawn box needs a glyph or a shape that the vendored fonts do not supply (no fallback fonts are allowed).
- The certificate's typeface sentence prints `word_processor` from the frontmatter as given ("Typst 0.15.0"); this docx was not made by Typst. The frontmatter value is the sample's, not a claim made by the template.
- Spacing above headings and the cover's gaps are close but not identical; the cover's court name wraps after "COURT" in the docx and after "COURT OF" in typst.
- Not built: an addendum and a corporate disclosure statement. The filter stops with an error if the markdown has either; the typst template builds both.
- Line breaks (w:br) appear only between the lines of the counsel block and inside each table-of-authorities entry (name, then citation), as typst's template does; none is used to fix pagination.

docx check (fb-595.63, 2026-10-21): `sh tools/check.sh courts/national/foreign-intelligence-surveillance-court-of-review/amicus-brief --engine docx`: RESULT 8 checks passed, 0 failed (TNR-EMBEDDED and DEF-FONT-002 failed before, when the reference named EB Garamond). The sample's frontmatter `typeface` now says Times New Roman, the face both engines set (it said EB Garamond, so both certificates misstated the face); typst rechecked: 8 passed, 0 failed. Every page of the 13-page `.docx.pdf` was viewed.
