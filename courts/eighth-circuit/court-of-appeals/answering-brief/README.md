# Court of Appeals for the Eighth Circuit: answering brief (appellee's brief)

Doc type `answering-brief` of court `ca8`. One self-contained folder: exemplar, sample, template, overlay, and this file.

| Item | Path | Status |
|---|---|---|
| Exemplar (filed, text-based PDF) | `exemplars/FILED-EXAMPLE-banks-v-costar-25-3320-answering-brief.pdf` (source: `exemplars/SOURCE.md`) | yes |
| Sample markdown | `samples/INPUT-banks-costar-response.md` | yes |
| Rendered sample | `samples/OUTPUT-banks-costar-response.pdf` (14 pages) | render=ok |
| Overlay (red = ours, blue = filed) | `samples/OVERLAY-banks-costar-response.pdf`, `samples/OVERLAY-banks-costar-response.txt` | overlay=ok |
| Template | `typst/main.typ` (entry), `typst/ca8-answering-brief.typ` | |

Build (from the repo root; the toolchain is typst 0.15.0, poppler, ImageMagick):

```sh
sh tools/render.sh courts/eighth-circuit/court-of-appeals/answering-brief samples/INPUT-banks-costar-response.md
sh tools/overlay.sh courts/eighth-circuit/court-of-appeals/answering-brief banks-costar-response
```

No `checks.yaml` or review file exists yet for this doc type: Gates 0 and 1 are not wired up (see "Known gaps").

## Governing rules

Verified 2026-10-14 against the sources below. The rule text was read from the Cornell LII copies of the FRAP and from the Eighth Circuit's own Local Rules PDF (revised June 17, 2024; the local rules page is the court's current copy).

| Requirement | Rule | Source | What the template does |
|---|---|---|---|
| Appellee's brief must contain the appellant-brief parts listed in FRAP 28(a)(1)-(8) and (10), except that the jurisdictional statement, statement of issues, statement of the case and standard of review need not appear unless the appellee is dissatisfied with the appellant's | FRAP 28(b) | https://www.law.cornell.edu/rules/frap/rule_28 | Summary, disclosure, TOC, TOA, argument, conclusion and certificate are generated. Statement of issues and of the case are the sample's content, not the template's |
| Corporate disclosure statement, if required: before the table of contents, in the principal brief | FRAP 26.1(a), (d)(1)-(2); 8th Cir. R. 26.1A (filed within 7 days of docketing) | https://www.law.cornell.edu/rules/frap/rule_26.1 ; local rules PDF below | Optional `disclosure:` frontmatter, rendered as its own roman-numbered page before the TOC |
| Cover: case number centered at top; court name; title of the case; nature of the proceeding and court below; title of the brief identifying the party; counsel's name, office address and telephone | FRAP 32(a)(2)(A)-(F) | https://www.law.cornell.edu/rules/frap/rule_32 | `cover()`: one page, all six items, spacing (never type size) reduced to fit |
| Appellee's cover color is **red** | FRAP 32(a)(2) | same | Not produced: paper copies only (see Known gaps) |
| 8½ × 11 paper; double-spaced text (quotations over two lines may be single-spaced); margins at least 1 inch on all four sides | FRAP 32(a)(4) | same | Letter paper, 1 in margins; body baseline pitch 28 pt (2 × 14 pt), measured on the sample; block quotations single-spaced |
| Proportionally spaced serif face, 14-point or larger (headings and captions may be sans-serif; the template uses serif throughout) | FRAP 32(a)(5)(A) | same | EB Garamond 14 pt everywhere, footnotes included; vendored; `pdffonts` shows `EBGaramond-*` only. Typeface: the rule names no face, so EB Garamond stays (`docs/FONTS.md`, "No face named"; no metric substitute applies). |
| Plain roman type; case names italicized or underlined | FRAP 32(a)(6) | same | Italics for every name marked `*...*` in the sample |
| Type-volume: principal brief no more than 13,000 words; certificate of compliance stating the count | FRAP 32(a)(7)(B)(i); 32(g)(1)-(2); 28(b) | same | `word-limit = 13000`; the count is over the body only (FRAP 32(f)); `panic` if over the limit; certificate states the computed count |
| Items excluded from length: cover, disclosure, TOC, TOA, statement regarding oral argument, addendum, certificate of counsel, signature block, proof of service | FRAP 32(f) | same | Those parts are outside the counted body |
| Eighth Circuit: summary of the case and statement on oral argument, one page, the first item in the brief (appellant's; the appellee may include a responsive statement) | 8th Cir. R. 28A(i)(1) | https://www.ca8.uscourts.gov/sites/ca8/files/Eighth%20Circuit%20Local%20Rules%206.17.24.pdf | Required `summary:` frontmatter, rendered first (roman i) |
| Statement of issues: for each issue, up to 4 apposite cases and the apposite constitutional and statutory provisions | 8th Cir. R. 28A(i)(2) | same | Author's content in the sample (the template does not check it) |
| Record citation form: "R. Doc. 12, at 3"; parallel "App. 25; R. Doc. 20, at 3" | 8th Cir. R. 28A(j) | same | Author's content (the template does not check it) |
| Electronic version: a single PDF generated from the word-processing file, text searchable; virus statement | 8th Cir. R. 28A(h)(1), (2), (3) | same | Certificate of compliance includes the virus statement from required `virus_check:`; PDF text is searchable (`pdftotext` yields it) |
| Addendum: the appellee's optional addendum is up to 15 pages, filed as a separate electronic document, not in the brief | 8th Cir. R. 28A(g)(3), (5) | same | Not generated (see Known gaps) |
| Certificate of service | FRAP 25(d)(1) (proof of service needed only when service is not through the e-filing system) | https://www.law.cornell.edu/rules/frap/rule_25 | CM/ECF certificate, as in the filed exemplar. Not a rule requirement here |
| Signature: every brief must be signed | FRAP 32(d) | https://www.law.cornell.edu/rules/frap/rule_32 | Signature block after the conclusion, date left, "Respectfully submitted," right |

Tier 2 (conventions) is judged against the exemplar only: cover arrangement, heading and TOC/TOA style, the signature block, the certificate wording, and the page numbering (roman for the front matter, arabic from the statement).

## Markdown contract

One `.md` file: YAML frontmatter, then the body. The template builds the cover, front matter, TOC, TOA, signature block and both certificates. Full field list in the frontmatter of `samples/INPUT-banks-costar-response.md`. Required: `case_number`, `caption`, `proceeding`, `brief_title`, `counsel` (each group may carry its own `phone`, printed under that group), `phone` (only when no counsel group has one; printed under the last group), `signature`, `date`, `virus_check`, `summary`, `authorities` (when the body cites any). Optional: `judge`, `district_court_case`, `disclosure` (omit when the party is not a nongovernmental corporation).

- Headings: `# Heading` is a centered bold section (Statement, Argument, Conclusion). Argument point headings are numbered automatically (I., A., 1., a.); do not type the numbers. Level 2 outside the Argument is A., level 3 is 1., and so on.
- Citations: `[*Case v. Name*, 1 F.4th 2 (8th Cir. 2026)](toa:key)`. Every `toa:` key must be in `authorities:`, or the build stops. Each link is recorded with the page it starts on for the TOA.
- Footnotes: `text[^key]` and `[^key]: note`, in 14 pt.
- Escape a paragraph that starts with an arabic number and a period, as in `1\. Does a statute`, or it becomes a list. Roman numerals such as `I. CoStar` need no escape.
- Smart punctuation is on.

## What the overlay shows

`samples/OVERLAY-banks-costar-response.pdf` puts our render (red) over the filed exemplar page (blue), pages paired by word overlap; black is where both agree. The page map is in `-overlay.txt`. It is a diagnostic, not a score: the sample is a portion of a 58-page brief, so the pages after the first few pair with the exemplar's pages where the same text appears, and where a page has no counterpart the red stands alone. Overlap by page: cover 100%, summary 100%, disclosure 83%, TOC 52% (different entries and page numbers), TOA 29% and 16% (the sample cites a subset), body 50-76%, conclusion 30%, certificates 85-100%.

## Render review (Gate 2 equivalent, recorded by hand)

Each page was rendered at 60 dpi (`pdftoppm -r 60`) and viewed. Pages 1 to 14 were viewed on the first render. Defects found and fixed:

| Page | Finding | Status |
|---|---|---|
| 4 (TOC) | The long title "Summary of the Case and Statement on Oral Argument" pushed its page number onto its own line, because the page-number box was a fixed 2.6 em wide | FIXED: the page number is no longer boxed to a fixed width; the title and leader fit on one line |
| 4 (TOC), 10, 11 | Headings showed doubled numbers ("I. I. CoStar", "A. A. Background"): the sample had typed the numerals the template numbers itself | FIXED in the sample; re-viewed |
| 2 to 14 | Body pitch 28 pt (double spacing), first-line indent, footnote 14 pt, centered bold headings, page numbers bottom-centered, TOA with dot leaders, cover on one page | PASS |
| 1 (cover) | Cover fits one page; the case number, court, caption, proceeding, brief title and two-column counsel block are all present | PASS |
| 13, 14 (certificates) | Word count computed from the body (1,193 for this portion, which is not the filed brief's 11,620); virus statement and date in place | PASS |

The sample's word count (1,193) and the filed brief's (11,620) are different because the sample is a portion; the template computes the count it certifies, so it never copies a number from the exemplar.

## Known gaps

- **Cover color (FRAP 32(a)(2)).** The appellee's cover must be red. That applies to paper copies only, and the rendered PDF is white, like the filed exemplar. The paper printer must use a red cover stock.
- **Addendum (8th Cir. R. 28A(g)(3), (5)).** The appellee's addendum is a separate electronic filing. The template does not generate one; a sample with an `# Addendum` heading would render it as ordinary body text. Count the addendum separately.
- **Statement of the standard of review and statement of issues.** Not required for an appellee (FRAP 28(b)(4)), so the sample omits the standard of review. Both can be added as body headings.
- **Tier 2 judged on one filer.** Only one filer's appellee brief is on file (Banks v. CoStar, a Baker & Hostetler filing). A second filer's brief is needed before any choice can be called a convention rather than that filer's style. Burnett v. Spring Way Center (No. 24-2168, Faegre Drinker) is the candidate noted in `exemplars/SOURCE.md`.
- **Gates 0 and 1 are not wired.** This doc type has no `checks.yaml`, `rules.md` or `reviews/` yet, so `tools/check.sh` does not apply and no pass stamp is written. Those belong with the court-level rules work.
- **Passim.** The TOA lists every page, as the exemplar does. The rules do not call for "passim" and the template does not use it.
- **Font.** EB Garamond is the vendored serif (SIL OFL 1.1, `fonts/eb-garamond/`). The exemplar is set in Calisto MT; FRAP 32(a)(5)(A) requires serif, 14 pt, and nothing about the face beyond that.
- **Certificate statements.** The virus statement comes from `virus_check:` and is counsel's attestation; the template does not verify it. The "proportionally spaced typeface, 14-point EB Garamond" statement describes this template's output. Change it if the brief is produced in another program.
- **Record citations and apposite cases** (8th Cir. R. 28A(i)(2), (j)) are the author's content; the template does not check them.
- **Electronic version (8th Cir. R. 28A(h)(3)).** The rule asks for a PDF printed from the original word-processing file. This PDF is typeset by typst from markdown, not printed from a word processor. The text is searchable (`pdftotext`) and the fonts are embedded, but whether that meets the rule is for counsel and the clerk to decide.
- **Line breaks in "U.S.C. §".** A section sign can fall at the start of a line, away from "U.S.C."; the template binds only "§ 2710" itself, as ca9 does.

## Loop log

1. First render: 17 pages (body 9 pages, TOA 2 pages). Cut the Standard of Review (optional for an appellee under FRAP 28(b)(4)), trimmed the statement and summary paragraphs and one argument paragraph. Now 14 pages, inside the 8-14 target.
2. Fixed the TOC page-number wrap and the doubled heading numerals (see the review table).
3. Overlay regenerated after the last render.

## Verification pass 2026-10-16 (fb-595.26.8)

- Rendered: `sh tools/render.sh courts/eighth-circuit/court-of-appeals/answering-brief samples/INPUT-banks-costar-response.md` exit 0, no typst warnings, 14 pages (unchanged from the committed PDF before this pass), fonts EB Garamond Regular/Bold/Italic only. Overlay re-run (`tools/overlay.sh`, exit 0): cover 100%, summary 100%, disclosure 83%, TOC 52%, TOA 29% and 16%, body 50-76%, conclusion page 30%, certificates 85% and 100%.
- Viewed: all 14 pages at 60 dpi, the exemplar's page 1 against our cover, and all 14 overlay pages at 40 dpi. Pages 1 and 13 viewed again after the fixes below; the text of pages 2-12 and 14 is unchanged by them.
- Fixed (tier 1, FRAP 32(a)(2)(F)): the cover printed one telephone number, under the Chicago group, and it was the Washington number; the Chicago number (312) 416-6200 was missing. The template took a single top-level `phone` and appended it to the last group. Counsel groups now take their own `phone` (top-level `phone` remains the fallback), and the sample gives each group its number as filed. The latex and docx filters read the per-group `phone` the same way (latex re-rendered and its cover viewed; docx not rebuilt, no `soffice`).
- Fixed (sample): an unused footnote definition (`[^kastenmeier]`, left over from trimming) was counted in the certified word count. Removed; the certificate now states 1,193 words (was 1,219).
- No other defects seen: cover on one page, front matter roman i-v, TOC and TOA page numbers match the body, headings not stranded (the Statement of the Case and the Argument start new pages : the heading group did not fit in the few lines left on the page before), footnote 14 pt, certificates complete.
- Remaining: the gaps listed above (one filer only for tier 2; no `checks.yaml`, so `tools/check.sh` does not apply; cover colour; addendum). Latex render (13 pages) builds; on its cover the rule above the brief title runs through the judge line (latex only, not fixed in this pass).

[Court folder](../README.md)

## Engines

- **typst** (primary, `typst/`): the reference for the court's form.
- **latex** (`latex/template.tex`, `latex/ca8.lua`): tectonic (XeTeX) with the vendored EB Garamond; the same page order, 14 pt type, 31.4 pt double spacing, 1 in margins, centered page numbers, TOC and TOA with page numbers (TOA pages collected from a first pass), certificates. Differences: body is shorter in places (page breaks differ from typst by a few lines, so TOC page numbers differ); the LaTeX certificate of compliance uses the source word count (see the PR for the reconciliation with the typst figure); cover and heading spacing are approximate, not measured per page. The filter and template in this folder are the same as the other two briefs apart from the `CFG` block in `ca8.lua` and the cover/signature/certificate macros in `template.tex`.
- **docx** (`docx/reference.docx`, `docx/ca8.lua`, `docx/build-reference.sh`): pandoc on reference.docx (EB Garamond 14 pt, exact 31.4 pt line spacing, 1 in margins, PAGE footer). BLOCKED on this box: LibreOffice (`soffice`) is not installed, so `samples/OUTPUT-<id>.docx.pdf` cannot be produced and the docx checks (Gates 0 to 3) cannot run. Known limits, per docs/DOCX.md: the table of contents is a TOC field (page numbers appear after field update); the table of authorities lists authorities without page numbers (a TOA field needs the same update, and LibreOffice does not honor it); cover and certificates are plain centered paragraphs, not the typst layout.
