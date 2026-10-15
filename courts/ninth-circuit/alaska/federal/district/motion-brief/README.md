# akd: motion-brief

Doc type: **motion-brief**: a Rule 12(b) motion to dismiss with its memorandum of points and authorities, in the United States District Court for the District of Alaska (`akd`). The template is the memorandum (the document that carries the argument); the notice of motion is a separate two-page filing and is not generated. Folder: `courts/ninth-circuit/alaska/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-naec-3-25-cv-00038-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-naec-motion-to-dismiss.md`: an excerpt of the 42-page memorandum (see Sample) |
| render | ok: `samples/OUTPUT-naec-motion-to-dismiss.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-naec-motion-to-dismiss.pdf` and `OVERLAY-naec-motion-to-dismiss.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

Build and check (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/ninth-circuit/alaska/federal/district/motion-brief samples/INPUT-naec-motion-to-dismiss.md
sh tools/overlay.sh courts/ninth-circuit/alaska/federal/district/motion-brief naec-motion-to-dismiss
```

## Governing rules

Primary source: the District of Alaska Local Civil Rules, "Effective October 15, 2025". Fetched 2026-10-14 from https://www.akd.uscourts.gov/sites/akd/files/local_rules/Local_Civil_Rules_10-2025.pdf (see the complaint README for the fetch note).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.Civ.R. 7.1(a)(1)-(2) | A motion states the requested relief and the applicable points and authorities. | The memorandum's Introduction, Background, Legal Standard and Argument; the relief is stated in the Introduction and Conclusion. |
| L.Civ.R. 7.1(b)(1) | A proposed order is not required with a Rule 12 motion. | Not generated. |
| L.Civ.R. 7.1(f) | "Oral Argument Requested" immediately below the title of a motion, if requested. | `oral_argument: true` in frontmatter; not used in the sample. |
| L.Civ.R. 7.4(a)(1) | A Rule 12(b) motion memorandum must not exceed 35 pages or 10,000 words (reply 20 pages or 5,700 words). | Not counted by the template (no page or word counter). The exemplar's body is about 35 pages after the front matter; see the exemplar SOURCE.md. |
| L.Civ.R. 7.4(a)(4) | Page and word limits do not include the caption, signature blocks, tables of contents and authorities, Rand notices, or reproduced statutes. | Front matter is separately numbered (roman); the body restarts at 1. |
| L.Civ.R. 7.5(a)(1)(A)-(E) | Double-spaced; margins of at least 1 inch including footers; page number and case name and number footer on every page of a multi-page document; at least 13-point proportionally spaced font, "or the equivalent" (7.5(a)(1)(D); no face named, re-read 2026-10-15). | `body-leading = 1.35em`, `margins = 1in`, `running-footer` (page number, short paper title, case name and number), `type-size = 13pt`, EB Garamond. See Typeface and the complaint README for the measured spacing. |
| L.Civ.R. 7.5(a)(2)(A) | Letter size, white paper. | `paper: "us-letter"`. |
| L.Civ.R. 7.5(b)(1)-(5) | First-page layout: counsel block upper left; court title; case number with the judge's initials; caption; title of the document. | `cover`: `counsel`, `court`, `caption` (case number and judge at right), `title`. |
| L.Civ.R. 7.5(c)(1)-(2) | Names and bar numbers beneath signatures; the attorney identifies each party represented. | `signature-block`: `preamble`, `/s/` line, `signer`, `lines` (including "Counsel for Defendants"). |
| L.Civ.R. 8.1(a) | Statute relied on, in parentheses under the title of a pleading. | `statute` under the title; the memorandum shows the Rule relied on, as the exemplar does not. (Not a pleading; kept for the motion's citation.) |
| Fed. R. Civ. P. 12(b)(1) | Lack of subject-matter jurisdiction is a defense, asserted by motion. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12 (the text of 12(b) and (b)(1) was read). | Cited in the Legal Standard and on the title line. |

Not generated: the notice of motion; a proposed order (not required for Rule 12 motions, L.Civ.R. 7.1(b)(1)); a certificate of service (the exemplar has none; the template generates one only when the frontmatter has a `certificate`, see Known gaps).

## Typeface

| Item | Value |
|---|---|
| Face required | None named. L.Civ.R. 7.5(a)(1)(D) asks for a 13-point, proportionally-spaced font "or the equivalent". `docs/FONTS.md` applies only where the rule names a face. The exemplar's Times look is not a requirement. |
| Vendored substitute | Not needed. EB Garamond is kept: `font-family = "EB Garamond"` (`fonts/eb-garamond/`). |
| Metric fit | Not applicable (no court-named face). |
| Verified | `pdffonts samples/OUTPUT-naec-motion-to-dismiss.pdf` lists EB Garamond Regular, Bold and Italic only, all embedded (2026-10-15). |

## Layout

- Page i: counsel block (upper left, single-spaced), court title, caption (party column closed by a rule; case number and judge at right), document title, statute.
- Page ii: table of contents, generated from the headings (`outline` of levels 1 to 4), with page numbers.
- Page iii and on: table of authorities, generated from `toa:KEY` links in the body; cases alphabetical, then statutes (by section number, via the `sort` key), rules, regulations and other authorities. An authority cited on 7 or more pages prints "passim".
- Body from page 1: double-spaced paragraphs with a 0.5 inch first-line indent; headings: level 1 centered bold capitals (INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION); level 2 Roman numerals (I.), level 3 letters (A.), level 4 numbers (1.), level 5 letters (a.); block quotations single-spaced and indented; footnotes 13 pt, single-spaced.
- The signature block follows the Conclusion: "Respectfully submitted" date line, the preamble, the `/s/` line, and the signer's details, kept together.

## Measured spacing

Single line 17.0 pt, double 34.5 pt at 13 pt (see the complaint README). The TOC and TOA entries use single spacing with 0.35 em between entries.

## Sample

`samples/INPUT-naec-motion-to-dismiss.md` transcribes the exemplar memorandum's caption, counsel block, title and signature block; its Introduction (complete); Background, section I (the Outer Continental Shelf Lands Act, complete); the Legal Standard (complete, with footnote 5 of the filing as the footnote); the opening of Argument section I and its sub-section A (first paragraph); and the Conclusion. Omitted: Background sections II and III (and the filing's footnotes 3 and 4, which belong to Background III); Argument I.B, II and III; the rest of Argument I.A after its first paragraph. The filed table of contents and table of authorities are **not** transcribed as printed: the template rebuilds both from the sample (the filed page numbers are not reproduced because they refer to the full filing). The sample's table of authorities covers the authorities cited in the excerpt only (18 authorities: 11 cases, 4 statutes, 1 rule, 2 regulations). The filing itself is 42 pages; the excerpt renders to 11 pages.

## Overlay

`OVERLAY-naec-motion-to-dismiss.pdf`: red is our render, blue is the filed exemplar, black where both agree. Pages are paired by word overlap (`OVERLAY-naec-motion-to-dismiss.txt`). Our pages 1 to 11 map to filed pages 1, 2, 6, 9, 10, 11, 12, 13, 18, 19 and 42. The pairing is coarse (our page 3 matches filed page 6 at 23% overlap; our page 11 matches filed page 42 at 56%, because the sample's last page is the signature page and the filed signature page is 42). The overlay is a diagnostic, not a score. The layers differ on text lines because the exemplar's text is set on a different pagination.

## Visual review (Gate 2 record, all 11 pages)

| Page | What it is | Finding |
|---|---|---|
| 1 (i) | Cover: counsel block, court title, caption, title, statute | OK. The caption fits on the cover after the single-spacing fix (it spilled onto a second page before). |
| 2 (ii) | Table of contents | OK. |
| 3 (iii) | Table of authorities (cases, statutes, rules, regulations) | OK after tightening spacing: the last entry (Proclamation) had been on a blank page iv. Statutes now in section order. |
| 4 (1) | Introduction, page 1 | OK. Double-spaced; the heading is centered. |
| 5 (2) | Introduction end; Background heading; Background I heading | OK. |
| 6 (3) | Background I continued; the Proclamation block quotation (single-spaced, indented) | OK. |
| 7 (4) | Background I: OCSLA, the five-year program and the four-stage leasing process | OK. Italic *Id.* and *See*. |
| 8 (5) | Background I end (section 12(a) withdrawal authority); Legal Standard heading and first paragraph | OK. |
| 9 (6) | Legal Standard; footnote 5 at foot | OK. Footnote is single-spaced 13 pt. |
| 10 (7) | Argument heading; I. and A. headings; Conclusion | OK. |
| 11 (8) | Signature block alone on this page | Known layout issue: the signature block did not fit below the Conclusion on page 7, so it sits on its own page. See Known gaps. |

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The State of Alaska's motion to dismiss in the same case (Docket 59) is a second filer, but its memorandum was not in RECAP (404). Tier 2 is not judged against two filers.
2. **Font.** No face is named by L.Civ.R. 7.5(a)(1)(D), so EB Garamond stays (see Typeface and the complaint README, Known gap 2). The memorandum is set in Times in the exemplar; EB Garamond reads smaller at the same point size.
3. **Length.** The template does not count pages or words for L.Civ.R. 7.4(a)(1). The full memorandum must be checked by hand before filing.
4. **Signature block alone on a page (page 11 of the render).** The block is kept together and does not fit below the Conclusion; the page is otherwise empty. A convention issue a clerk may notice; left as is because moving text to avoid it would be a case-specific tweak.
5. **Certificate of service.** Not in the exemplar; not in the sample. The template generates one when the frontmatter has a `certificate: {text, signer}` map. The 2025 local rules call for a Certificate of Service only where service is not through CM/ECF (L.Civ.R. 5.1(c)(4), sealed filings served by other means); for an ordinary CM/ECF filing the Notice of Electronic Filing is the proof of service (5.1(c)(3)).
6. **Notice of motion.** The filing's notice (Document 57, 2 pages) is not generated; the template is the memorandum only.
7. **Footnotes.** Single-spaced at 13 pt. L.Civ.R. 7.5(a)(1)(A) does not mention footnotes; the convention is a choice.
8. **Heading style.** Level-2 headings are bold with Roman numerals; the exemplar's are bold too, with the same numbering scheme. ACCEPTED.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the Gate 2 table above is the review.
10. **File names.** The brief names the files `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The tools read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (see `tools/render.sh` and `tools/overlay.sh`), so the tool names are used.
11. **Judge's standing orders** may change the form. Not reflected.

## Engines

**docx** (`docx/`): `build-reference.sh` makes `docx/reference.docx` (EB Garamond 13 pt, double body text, single headings and contents, letter, 1 in margins, footer inside the bottom margin); `akd-motion-brief.lua` builds the cover, contents, authorities, the section break (cover, contents and authorities in lower roman, the memorandum from 1), the numbered headings with their labels, the signature block and the certificate (only when the frontmatter has one); `find-pages.awk` finds the printed page of every heading and citation in a rendered pass; `render.sh` runs pandoc, converts each pass with LibreOffice and repeats until the page numbers stop changing (at most four passes). Build: `sh tools/render.sh --engine docx courts/ninth-circuit/alaska/federal/district/motion-brief samples/INPUT-naec-motion-to-dismiss.md`, which writes `samples/OUTPUT-naec-motion-to-dismiss.docx` and `.docx.pdf` (11 pages; the PDF embeds EB Garamond Regular, Bold and Italic only).

- Checked with LibreOffice only (Word is not available here). Every page of the `.docx.pdf` was rendered at 60 dpi and viewed (11 of 11, after the last change). The contents page numbers were checked against the pages where the headings fall; the authorities page numbers against the pages where each linked citation falls.
- Matches the typst template: font and size, double spacing, 1 in margins, the cover, the contents with dot leaders, the table of authorities grouped as Cases, Statutes, Rules, Regulations (passim at seven pages or more), the roman then arabic page numbering, the labelled headings (I., A., 1., a.), the block quotation, the footnotes and the signature block.
- Differs: (1) the typst OUTPUT PDF is not in this folder, so typst pagination could not be compared. (2) Contents and authorities are typed paragraphs with page numbers from the LibreOffice pass, not TOC or TOA fields, so they do not update in Word. Word may paginate differently, so a page number there can be off by one; this is the TOC/TOA limit in `docs/DOCX.md`. (3) The court title sits 0.5 in below the counsel block (typst: 0.8 in). Local Rule 7.5(b)(2) requires at least 0.5 in; the 0.8 in spacing pushed the title block off the cover in this build. (4) The footer sits 0.25 in from the bottom edge, inside the margin.
- Not exercised by the sample: the passim threshold (no citation reaches seven pages) and the certificate of service (the sample has none).
- BLOCKED: `tools/check.sh --engine docx` cannot run in this folder (it needs `court.json` and `checks.yaml` beside `typst/`, which the doc-type folder does not have). No Gate 0 to 3 result exists for the docx engine; the review above is the only record. Page numbers in Word: BLOCKED as described in (2).
