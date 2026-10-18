# Tenth Circuit: reply brief

Doc-type folder for the Court of Appeals for the Tenth Circuit, reply brief (the appellant's reply under FRAP 28(c)). Self-contained: its own exemplar, sample, template and overlay. Court-root `typst/` and `usage/` are not touched.

| Path | What |
|---|---|
| `usage/SAMPLE-ca10-reply-brief-oliver262126.pdf` | Filed exemplar, primary: *United States v. Oliver*, No. 26-2126, DOJ reply brief, 2026-10-08. Text layer present. |
| `usage/SAMPLE-ca10-reply-brief-lyman264014.pdf` | Second filer (tier-2 comparison): *Lyman v. Henderson*, No. 26-4014, reply brief, 2026-07-27. |
| `usage/SOURCE.md` | URL fetched from, case, docket, filer, date filed, date fetched, and why each file was used. |
| `usage/INPUT-ca10-reply-brief-oliver.md` | Transcription of the Oliver brief: cover and caption, the Introduction, Argument I.A and I.B, the Conclusion, the signature block (and footnote 1). A portion, not the whole brief. |
| `usage/OUTPUT-ca10-reply-brief-oliver.typst.pdf` | Render, 13 pages. |
| `usage/OVERLAY-oliver-reply-brief.pdf`, `-overlay.txt` | Red/blue overlay against the Oliver exemplar, and the page map. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `typst/ca10-reply-brief.typ` | Template: `ca10-reply-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |

Build, from the repo root:

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (see the toolchain note in the PR)
sh tools/render.sh courts/tenth-circuit/court-of-appeals/reply-brief usage/INPUT-ca10-reply-brief-oliver.md
sh tools/overlay.sh courts/tenth-circuit/court-of-appeals/reply-brief oliver-reply-brief \
  courts/tenth-circuit/court-of-appeals/reply-brief/usage/SAMPLE-ca10-reply-brief-oliver262126.pdf
```

`render.sh` compiles with the vendored fonts only (`--ignore-system-fonts`) and fails on any typst warning. The overlay takes the exemplar as its third argument, because `overlay.sh` otherwise picks the first file in `usage/` alphabetically (the Lyman brief).

## Governing rules

Verified 2026-10-14 against the Tenth Circuit's 2026 FRAP and Local Rules, https://www.ca10.uscourts.gov/sites/ca10/files/clerk/2026Rules.pdf (the page cites below are to that PDF's text). Rule IDs in the template comments are the `CA10-RB-*` IDs here.

| ID | Requirement | Source | Kind | Where the template applies it |
|---|---|---|---|---|
| CA10-RB-TOC | A reply brief must contain a table of contents with page references, and a table of authorities (cases alphabetical, statutes, other authorities) with the pages where each is cited. | FRAP 28(c) | court-mandated | `toc-section()`, `toa-section()`. The TOA is built from `toa:` links; a missing key stops the build. |
| CA10-RB-COVER | Front cover: case number centred at top; name of the court; title of the case; nature of the proceeding and the court below; title of the brief; counsel's name, office address and telephone. | FRAP 32(a)(2)(A)-(F) | court-mandated | `cover()`. Cover colour (gray for a reply brief, FRAP 32(a)(2)) is for paper copies and is not produced. |
| CA10-RB-TYPE | Proportionally spaced serif face, 14-point or larger; plain roman, case names italic. The court prefers 14-point; footnotes are the same size as the body. | FRAP 32(a)(5)(A), 32(a)(6); 10th Cir. R. 32(A) | court-mandated (local rule adds the footnote size) | `type-size = 14pt`, footnotes at `type-size`. |
| CA10-RB-SPACE | Double-spaced text; quotations of more than two lines may be indented and single-spaced; headings and footnotes may be single-spaced. Margins at least one inch on all four sides; 8½ × 11 in paper. | FRAP 32(a)(4) | court-mandated | `body-leading`, `page-margin = 1in`, `paper: "us-letter"`. |
| CA10-RB-LIMIT | Reply brief: no more than 6,500 words excluding the items in FRAP 32(f) (or 15 pages / 650 lines as alternatives). The template counts the markdown body (headings, text, footnotes, quotations; not list markers or generated parts) and stops the build over 6,500. | FRAP 32(a)(7)(A), 32(a)(7)(B)(ii); FRAP appendix chart (p. 160 of the PDF) | court-mandated | `word-limit = 6500`, `count-words()`. |
| CA10-RB-CERT-001 | Certificate of compliance: word count (FRAP 32(f) exclusions), and typeface and type style compliance, in the court's Form 6 wording. | FRAP 32(g)(1)-(2); Form 6 (Appendix of Forms) | court-mandated | `certificate-of-compliance()`. The typesetting program is printed from the frontmatter `typeset_with` (default "Typst 0.15.0"); the signing attorney confirms it. |
| CA10-RB-DIG | Digital-submission certificate: privacy redactions per FRAP 25(a)(5) and 10th Cir. R. 25.5; native PDF; exact copy; virus scan. | 10th Cir. R. 25.5 (privacy, verified); FRAP 25(a)(5) | convention (seen in the Lyman exemplar; not in the rules text) | `certificate-of-digital-submission()`, only when `digital_submission: true`; needs `virus_scanner`. |
| CA10-RB-SVC | Certificate of service. ECF statement under FRAP 25; unregistered participants listed by name and address when the case has them. | FRAP 25 | court-mandated (proof of service); ECF wording is convention | `certificate-of-service()`, always produced. |
| — | Not produced: the glossary (10th Cir. R. 32(B) refers to a glossary under Rule 28.2(C)(4); I did not verify whether that applies to a reply brief, and the Oliver exemplar has one); a cover colour; the paper-copy count (10th Cir. R. 31.5); the addendum. | — | — | Known gaps, below. |

Cited but not verified, so not used by the template: "10th Cir. R. 25.4" for service, which the Lyman brief cites. The 2026 rules text I checked has no Rule 25.4, so the template cites FRAP 25 only.

## Markdown contract

The sample is one `.md` file: a YAML frontmatter block followed by the body. The ca9 contract (`courts/ninth-circuit/court-of-appeals/README.extra.md`) applies, with these differences:

- No required sections. A reply brief has no Statement of Jurisdiction, Statement of the Issues, etc. (FRAP 28(c) asks only for the TOC and TOA). The body is headings, text, footnotes, quotations, and `toa:` links; the Conclusion heading is a convention the exemplars share.
- Frontmatter, required: `case_number`, `caption`, `proceeding`, `brief_title`, `counsel`, `phone`, `signature`, `date`, and `authorities` when the body cites any. Optional: `district_court_case`, `judge`, `service` (`unregistered`), `digital_submission` (with `virus_scanner`), `typeset_with`.
- A caption side may carry `no-v: true`: it follows the previous side with no "v." between them (the intervenors in the Oliver caption).
- No `# Addendum` section (not generated).
- The Argument uses the same numbering as ca9: level 2 is the centred point heading (I., II.), level 3 is A., level 4 is 1., level 5 is a.

## Results

- **Render:** ok. `tools/render.sh` built `usage/OUTPUT-ca10-reply-brief-oliver.typst.pdf` (13 pages) with no typst warnings. Fonts embedded: EBGaramond-Regular/Bold/Italic (Identity-H). Final build sha256 `5f91caea…`.
- **Overlay:** ok. `usage/OVERLAY-oliver-reply-brief.pdf` and `-overlay.txt` are written.
- **Pages reviewed:** 13 of 13. Every page was rasterised at 60 dpi (`pdftoppm -r 60`) and looked at. The review was on the render made before the last template change. That change (paragraph breaks in the digital-submission list) is not in this sample, and the re-render is the same size as the reviewed one (101,383 bytes), but I did not re-view its pages.
- **Branches tested on a temporary transcription** (deleted, not committed): `digital_submission: true` with `virus_scanner`, and a `service.unregistered` list. The render was 14 pages, with the Certificate of Digital Submission and the unregistered-service paragraph present. The first attempt ran the five list items together ("and(5)"); fixed with paragraph breaks.

### Findings

- Cover: fits one page; the parts are spaced to fit, the type size does not change. The caption's intervenors line sits under the defendant with no "v." (the `no-v` side).
- TOC: matches the rendered pages. TOA: each authority's pages are right on the pages I checked (e.g. *Kennedy v. Lynd* 1, 2, 3, 7; *Powell* 2, 3).
- Body: double-spaced, 14-point, footnote at the body size; the point heading "I." is centred in small caps, the A./B. sub-headings hang.
- Certificates: Form 6 wording; the word count is 1,641 for this portion; the signature block sits with the last paragraph.

## Known gaps

- **Partial sample.** The sample transcribes the Introduction, Argument I.A and I.B, and the Conclusion, not the whole 33-page brief. The TOC and TOA cover that portion only. The overlay's page map pairs our pages with the filed pages by shared words, so with a partial transcription the pairs are approximate (our body pages 1-10 map to filed 1-18; our certificate pages map to filed 43-44).
- **Tier 2 not judged yet.** There is no Gate 2 review (`reviews/`) for this doc type, and no `checks.yaml`. The two exemplars use different typefaces (Century Schoolbook in Oliver, Times New Roman in Lyman); the template uses EB Garamond (vendored, as in ca9), which FRAP 32(a)(5) allows. Font family is a choice the rules leave open.
- **Cover layout.** Both exemplars are unruled. The template draws short rules between the cover's parts, a choice from ca9, not from either exemplar.
- **Glossary and addendum** are not generated. The Oliver exemplar has a glossary after the TOC.
- **Cover colour and paper copies** (gray cover, 10th Cir. R. 31.5 paper counts) are outside the PDF and not produced.
- **Certificate of Digital Submission** is convention (seen in the Lyman exemplar), not a rule in the 2026 text. It is off in the sample.
- **Second sample** not transcribed. The Lyman brief is saved and cited for the digital-submission and service certificates, but the template has been tested on it only by reading.

## Typeface (fonts pass, 2026-10-15)

- **Face required by the rules: none named.** FRAP 32(a)(5) requires a proportionally spaced face with serifs, 14-point or larger (or a monospaced face); FRAP 32(a)(6) requires plain roman. The court's own 2026 briefing checklist (item "Is the brief in either 13- or 14-point font (14-point font is preferred)? See 10th Cir. R. 32(A)") and its Quick Reference Guide ("Form and Font Size (14-Point Preferred)") name no face. Source texts were read 2026-10-15: Cornell FRAP 32, `ca10.uscourts.gov` checklist 2026 and QRG (PDF text via pdftotext). The text of 10th Cir. R. 32(A) itself was not retrieved (the court's local-rules page returned 404).
- **Unverified claim, not used.** A secondary Typelaw blog post says the Tenth Circuit requires Century Schoolbook. No court-published text found says so, so the template does not follow it. The filed exemplars use different faces (Oliver reply: Century Schoolbook; Lyman opening: Times New Roman), which is consistent with the rules naming none.
- **Substitute: none; EB Garamond kept** (vendored, `fonts/eb-garamond/`), per the fonts policy: a court whose rules name no face keeps EB Garamond. Set in the template as `font-family`.
- **Compatibility:** not applicable (no named face to match). Pagination is therefore not checked against a Times or Century filing; the length gate uses the word count, not the page count.
- **Renders (2026-10-15):** `tools/render.sh` with vendored fonts only, zero warnings; `pdffonts` shows only EB Garamond (Regular, Bold, Italic). Page counts unchanged. Every page rasterised at 60 dpi and viewed. Overlay regenerated against the filed exemplar (downloaded from the CourtListener URL in `usage/SOURCE.md`; the PDF is not committed to the repo).

## Engines

DOCX (`docx/`): `build-reference.sh` makes `reference.docx` (the same styles as the opening brief: EB Garamond 14 pt, exact 31.4 pt double spacing, 0.5 in first-line indent, letter, 1 in margins). `ca10.lua` writes the cover (one page, no number), the front matter in lower roman, the body in arabic from 1, the signature block, and the certificates (compliance, digital submission when `digital_submission: true`, service).

- Matches the typst output: 13 pages (typst: 13); footer numbers i to iii, then 1 to 9; cover layout (case number, court, caption with "v." except before a `no-v` side, proceeding, D.C. number and judge, brief title, counsel with the telephone on the last group); the body; the certificate of compliance word count (1,641, same as typst); the certificate of service and the signature grid.
- Differs (tier 2, not chased): headings sit lower at the top of a page; cover rules and spacing are fixed, not fitted; line breaks differ in places; the contents and authorities have no dot leaders.
- BLOCKED `TOC` (contents, page column): page numbers need a field update in Word or LibreOffice, which this pipeline does not do.
- BLOCKED `TOA` (table of authorities, "Page(s)" column): same reason.
- Certificate of compliance, item 2: the typst output prints the typesetting program ("using Typst 0.15.0"). The docx prints no program name ("a proportionally spaced typeface, EB Garamond"); the filer must name the word processor it used. Not a page-count item, but the certificate is incomplete until the filer fills it in.
- `sh tools/check.sh <court-dir> --engine docx` fails: the court folder has no `checks.yaml` (Gate 1 cannot run). Nothing was edited to pass it.

## Verification pass 2026-10-16 (fb-595.26.10)

- Rendered: `tools/render.sh` exit 0, no typst warnings, 13 pages (unchanged). Overlay rerun with the Oliver exemplar as the third argument; page map unchanged (cover 51.8%, body pages 47-81%). Run without the third argument, `overlay.sh` takes the Lyman brief and the map drops to 4-21% on the body; do not regenerate it that way.
- Viewed: all 13 pages at 60 dpi (this closes the gap noted under Results: the pages of the current render have now been looked at); the 13 overlay pages at 40 dpi; Oliver exemplar page 1 against our cover (same parts and order; the exemplar continues counsel on an inside cover, ours fits one page).
- Defect fixed: the TOA sort key's punctuation-stripping step never ran (a method chain on a new line after `#let` is markup, not code), and digit runs sorted as text. The key is now parenthesised and zero-pads digit runs, so "2 U.S.C." sorts before "28 U.S.C.". The sample's TOA order is unchanged (checked in the text layer of pages ii-iii after the rebuild).
- No other defects found: cover on one page, TOC and TOA page numbers match the body pages, 14-point double-spaced body, footnote at body size, signature kept with the conclusion, Form 6 certificate (1,641 words) and certificate of service each on their own page.
- DOCX output not touched (no LibreOffice on this box). No latex engine in this folder.
- Remaining gaps: as listed under Known gaps (partial sample, no Gate 2 review or `checks.yaml`, glossary and addendum not generated, cover colour, second sample not transcribed).
