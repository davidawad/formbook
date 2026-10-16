# Fourth Circuit: opening brief of appellant

Doc type `opening-brief` for the U.S. Court of Appeals for the Fourth Circuit (court alias `ca4`). Self-contained: exemplar, sample, template, overlay and this README live in this folder. Court-root `typst/` and `samples/` (the Ninth Circuit's brief) are not touched.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: filed Opening Brief of Appellant, *NetChoice v. Jones*, No. 26-1252, filed 04/15/2026 (see `exemplars/SOURCE.md`) |
| Sample | `samples/INPUT-netchoice-opening-brief.md`: 13 rendered pages (typst), excerpted from a 66-page filed brief |
| Render | ok: `sh tools/render.sh courts/fourth-circuit/court-of-appeals/opening-brief samples/INPUT-netchoice-opening-brief.md`; exit 0, no typst warnings, embedded fonts are TeX Gyre Schola only (`pdffonts`) |
| Overlay | ok: `sh tools/overlay.sh courts/fourth-circuit/court-of-appeals/opening-brief netchoice-opening-brief`; wrote `samples/OVERLAY-netchoice-opening-brief.pdf` and `.txt` |
| Pages reviewed | 13 of 13 typst pages (every page rendered at 60 dpi and viewed after the font change; the TOC was viewed again after the page-number fix). 16 of 16 LaTeX pages viewed (see Engines). |
| Gate 2 | open: none in the typst render. The typeface gap is closed (see Typeface). LaTeX layout items are under Engines. |

## Governing rules

Rule text was fetched on 2026-10-14. Where a page was a summary rather than verbatim text, that is noted.

| Requirement | Source | Verified |
|---|---|---|
| Typeface: proportional serif, 14-point or larger (text and footnotes) | FRAP 32(a)(5)(A): https://www.law.cornell.edu/rules/frap/rule_32 | 2026-10-14, verbatim |
| Spacing: double-spaced; block quotations and headings and footnotes may be single-spaced; margins at least 1 inch, 8½ × 11 paper | FRAP 32(a)(4) (same page) | 2026-10-14, verbatim |
| Type style: plain roman, italics or boldface for emphasis, case names italic or underlined | FRAP 32(a)(6) (same page) | 2026-10-14, verbatim |
| Length: principal brief at most 13,000 words (or 1,300 lines monospaced) | FRAP 32(a)(7)(B)(i) (same page) | 2026-10-14, verbatim |
| Excluded from the count: cover, disclosure statement, TOC, TOA, statement regarding oral argument, addendum, certificates, signature block, proof of service | FRAP 32(f) (same page) | 2026-10-14, verbatim |
| Certificate of compliance with the type-volume limit, stating the word count | FRAP 32(g)(1) (same page) | 2026-10-14, verbatim |
| Cover colour: appellant's brief blue (paper); white is permitted for the electronic cover | FRAP 32(a)(2) (same page); Fourth Circuit Brief & Joint Appendix Requirements, "Cover Color" (https://www.ca4.uscourts.gov/appellateprocedureguide/Briefing/briefapxreq.html, March 2026, fetched 2026-10-14, summary) | 2026-10-14 |
| Contents, in order: cover, disclosure statement if required, TOC, TOA, jurisdictional statement, statement of issues, statement of the case, summary of argument, argument (with standard of review), conclusion, request for oral argument, signature, certificate of compliance, certificate of service (non-ECF) | FRAP 28(a)(1)–(10): https://www.ca4.uscourts.gov/rules/Rule28.html (2026-10-14, quoted through a summary of the page) | 2026-10-14 |
| Cover content: docket number centred at top (no district or agency number); "United States Court of Appeals for the Fourth Circuit"; case title; "Appeal from the … District Court"; brief title; counsel names, addresses, phone numbers | Brief & Joint Appendix Requirements, "Cover Content" (same page, summary) | 2026-10-14 |
| Certificate of service: FRAP 25(d) (proof of service); the exemplar uses CM/ECF service wording | FRAP 25(d); exemplar p. 66 | 2026-10-14 |
| Preferred typefaces: Times New Roman, Century Schoolbook, Georgia; the court "discourages the use of Garamond" | Fourth Circuit News, "Preferred Typefaces for Briefs," Dec. 9, 2024, https://www.ca4.uscourts.gov/news-announcements/2024/12/09/preferred-typefaces-for-briefs (fetched 2026-10-14) | 2026-10-14. A notice, not a rule. |

Local Rule 32 (https://www.ca4.uscourts.gov/rules/Rule32.html) was fetched on 2026-10-14. It covers appendices, length (it defers to FRAP 32(a)(7)) and correction of briefs; it has no typeface or cover rules of its own. The page returned a summary, not verbatim text.

## Typeface

| Face the court names | Vendored substitute (Typst name) | Fit | Used by |
|---|---|---|---|
| Century Schoolbook (court's notice of preferred typefaces, Dec. 9, 2024; the filed exemplar is set in it) | TeX Gyre Schola (`TeX Gyre Schola`) | Metric-compatible with the Adobe base-35 New Century Schoolbook AFMs (`docs/FONTS.md`) | typst, LaTeX, docx |

The FRAP names no face, only a proportional serif, which EB Garamond also meets. The notice is not a rule, but it names Times New Roman, Century Schoolbook or Georgia and "discourages the use of Garamond", so the template follows it. Century Schoolbook is chosen over Times New Roman (answering and reply briefs) because it is the face of this court's filed exemplar. The page count moved from 14 to 13 pages with the change (EB Garamond to Schola).

## What the template does

`typst/ca4-opening-brief.typ` (entry point `typst/main.typ`) is driven by the FRAP numbers above and by the parameters at its head:

- Font: TeX Gyre Schola (see Typeface), 14 pt everywhere, double-spaced with a 0.94 em body leading, 1-inch margins.
- Cover: one page; the spacing between its parts shrinks to fit, the type size never does. A cover that cannot fit is an error.
- Front matter: TOC and TOA with lower-roman folios; the TOA is built from `toa:` links in the body. TOA entry spacing is 0.5 em.
- Body: arabic folios from 1. Headings are numbered by the template (I./A./1./a. in the Argument; A./1./a./(1) elsewhere). The signature block follows the last section and stays with the last paragraph.
- Request for oral argument: must be the last section in the markdown; the word count excludes it (FRAP 32(f)).
- Word count: computed from the markdown, checked against 13,000 words. The count for the certificate of compliance is this count, not the filed brief's count.
- Certificates of compliance and of service are generated from the frontmatter (`date`, `signature`).

## Markdown contract

Same shape as the Ninth Circuit's contract (see `courts/ninth-circuit/court-of-appeals/README.extra.md`), with these differences:

- Frontmatter: `case_number`, `caption`, `proceeding`, `brief_title`, `counsel` (groups of `names` and `lines`), `signature` (`signer`, `lines`), `date`, `authorities`. No `phone` (put telephone numbers in the `lines`), no `related_cases`, no `word_limit_basis`, no `service` (the certificate is always generated).
- Headings: no typed numerals; the template numbers them. `#` is a section; under `# Argument`, `##` is a point heading (I.), `###` A., `####` 1.; elsewhere `##` is A., `###` 1., `####` a.
- Case names and signals italic (`*Munaf v. Geren*`, `*See*`); every citation that goes in the TOA is a link `[text](toa:key)` with its key in `authorities:`.

## Known gaps

1. **Typeface: closed in the fonts pass.** Set in TeX Gyre Schola (Century Schoolbook), per the court's notice and the exemplar. Before, EB Garamond was used, which FRAP accepts but the notice discourages. Not a tier-1 item.
2. **Cover colour.** Not produced: the template is paper-agnostic. The appellant's paper cover is blue under FRAP 32(a)(2); the electronic cover may be white.
3. **Disclosure statement.** Not generated. The exemplar (a government party) has none. A private appellant would need one, filed under FRAP 26.1 / Local Rule 26.1 and included in the brief (the court's requirements page).
4. **Excerpt only.** The sample is 13 pages of a 66-page filed brief. It omits brief pages 7–17 (Statement Parts B–G), 22–52 (Argument II.A.2 to II.C.3), and some of the Summary and Introduction paragraphs (each marked in the sample). The TOA lists only the authorities cited in the excerpt. The 1,523-word certificate count is the excerpt's, not the filed brief's 10,452.
5. **Cover layout: closed 2026-10-16.** The exemplar sets counsel in two columns side by side. The template now does the same when there are two or more counsel groups (one group stays in the right half). Lines are roman; a title the markdown italicises stays italic.
6. **Overlay.** The overlay pairs pages by shared words. Because the sample is an excerpt, pairs are partial matches (word overlap 24–80%). Pairing is only indicative: our Table of Authorities (page 3) pairs with filed page 6 at 25%, which is a page of the filed Table of Authorities, but the match is weak because our TOA lists far fewer authorities.
7. **Certificates.** Only the CM/ECF service form is generated. Service on unregistered participants is not supported.

## Overlay map

From `samples/OVERLAY-netchoice-opening-brief.txt`: our pages 1–13 paired with the filed pages named there (after the font change: ours p.4 with filed p.10, ours p.5 with filed p.13, ours p.10 with filed p.62; the excerpt pairs weakly, as before). Red is our render, blue the filed page, black where both agree. The overlay is a diagnostic: it shows where the layout diverges, not a score.

## Page review (Gate 2 input)

Every page of `samples/OUTPUT-netchoice-opening-brief.pdf` was rendered at 60 dpi and viewed after the font change. Folios are the printed ones.

| PDF page | Folio | Content | Finding |
|---|---|---|---|
| 1 | none | Cover | Fits one page. Counsel in two columns, roman (2026-10-16; see gap 5). |
| 2 | i | Table of contents | Entries, folios and indent correct. The two deepest entries (II.A, II.A.1) wrapped their folio onto a new line under the wider face; fixed by setting the folio at its content width. |
| 3 | ii | Table of authorities | One page. |
| 4 | 1 | Introduction | Body double-spaced; excerpt marker shown. |
| 5 | 2 | Issues, jurisdictional statement, Statement A | Numbered issues render as a list. |
| 6 | 3 | Statement A (cont.), standard of review, summary | Heading and subheading hang correctly. |
| 7 | 4 | Summary of argument | Case names italic. |
| 8 | 5 | Summary (cont.), Argument I | Point heading hangs under its numeral. |
| 9 | 6 | Argument I–II.A.1 | Sub-heading levels A./1. correct, italic at level 4. |
| 10 | 7 | Argument II.A.1, III, conclusion | Excerpt marker; TOA-linked citations correct. |
| 11 | 8 | Request for oral argument, signature | Signature block stays with the request paragraph. |
| 12 | 9 | Certificate of compliance | Word count is the excerpt's (1,523). |
| 13 | 10 | Certificate of service | Matches the exemplar's CM/ECF wording. |

## Exemplar search, for the record

Searches (2026-10-14): CourtListener and RECAP for 4th Cir. opening briefs; the ca4 website's brief-requirement and rule pages; Justia docket pages for 2025 4th Cir. cases; advocacy-group repositories. The exemplar chosen is the NetChoice copy of the Attorney General's brief because it is a text-based PDF, a 4th Cir. opening brief, filed April 2026, and public. Others found and not used are listed in `exemplars/SOURCE.md`.

## Engines

Three renderings of the same markdown (`samples/INPUT-netchoice-opening-brief.md`). The typst template is the reference.

**LaTeX** (`latex/template.tex`, `latex/ca4.lua`; `sh tools/render.sh --engine latex`): output `samples/OUTPUT-netchoice-opening-brief.latex.pdf`, 16 pages (14 before the font change to Schola), every page rendered at 50 dpi and viewed; re-rendered and viewed again at 40 dpi on 2026-10-16 after the cover change. Layout items the font change exposed, not fixed here: the last Table of Authorities line ("Va. Code § 59.1-584") falls alone onto page iii, and the "REQUEST FOR ORAL ARGUMENT" heading sits at the foot of page 9 with its text on page 10. Matches: TeX Gyre Schola only (vendored, 14 pt text and footnotes), body double-spaced at the typst pitch (31.43 pt), 1-inch margins, 0.5-inch first-line indent, roman folios for the cover-less front matter and arabic from the body, the cover on one page with counsel in two columns (one group: right half), contents and authorities built from the frontmatter and the `toa:` links (passim from seven pages), the signature block kept with the last paragraph, and the certificate of compliance word count (1,523, the same as typst's count). Differs: the cover's spacing is a fixed gap (typst scales the gap to fit the page); paragraph and heading spacing differ slightly, so body page breaks and the folios in the contents and authorities differ from typst by a line or two per page. Not checked by `check.sh` (no `checks.yaml` in this court).

**docx** (`docx/reference.docx`, `docx/ca4.lua`; `sh tools/render.sh --engine docx`): `samples/OUTPUT-netchoice-opening-brief.docx` is written; the `.docx.pdf` is not, because LibreOffice is not installed (see BLOCKED). Matches in the styles: TeX Gyre Schola 14 pt, body at 31.43 pt exact, 0.5-inch first-line indent, single-spaced headings and block quotations, 1-inch margins, three sections (cover without folio, front matter in roman, body in arabic). The contents and the table of authorities are Word fields (`TOC`, `TA` on each citation, `TOA` per category). Certificate word count 1,523.

BLOCKED (docx):
- All gates on `samples/OUTPUT-netchoice-opening-brief.docx.pdf`: LibreOffice (`soffice`) is not on this box and conda-forge has no package. A Debian `libreoffice-writer-nogui` 25.2.3 was unpacked without root under `~/apt-lo` and its `soffice.bin` segfaulted at start-up; not resolved.
- Contents and authorities page numbers: the cached results have no page numbers, and Word fills them on update (fields are marked dirty). LibreOffice does not honour TA/TOA fields (docs/DOCX.md), so the TOA page checks cannot pass in a LibreOffice PDF.
- The cover's rules and caption positions are paragraph borders and indents, approximated; the cover was not seen in any renderer.
- The last paragraph is not kept with the signature block (no keep-with-next across the pair).
- Opened in neither Word nor LibreOffice: the `.docx` was checked only for well-formed XML parts.

## Verification pass 2026-10-16 (fb-595.26.4)

- Rendered: `sh tools/render.sh … samples/INPUT-netchoice-opening-brief.md` exit 0, no typst warnings, TeX Gyre Schola only (`pdffonts`). 13 pages, the same count as the committed PDF (the "14 rendered pages" in the status table was stale and is corrected).
- Overlay: `sh tools/overlay.sh … netchoice-opening-brief` exit 0; page map unchanged (see Overlay map). All 13 overlay pages viewed: the cover now lines up with the filed cover's two counsel columns; body pages pair as listed, with the expected partial matches of an excerpt.
- Pages viewed: 13 of 13 typst pages at 60 dpi, plus the exemplar's page 1 against our cover. After the fix, page 1 was viewed again; pages 2–13 are pixel-identical to the first render (`compare -metric AE`).
- Fixed (template): cover counsel was one narrow column in the right half, with every office line italic and indented, so addresses and postal codes wrapped. Two or more counsel groups now sit side by side in two columns, roman, as on the filed cover (gap 5 closed). Sample: the cover address lines are split as filed (street / city), the three McGuireWoods names are one per line, and "Counsel for Defendant-Appellant" is italic in the markdown.
- Fixed (LaTeX, `latex/ca4.lua`): the same two-column counsel layout. The sample change alone had pushed the LaTeX cover's closing rule onto a second page (17 pages); with the layout fix the cover is one page again and the PDF is 16 pages. Every page viewed at 40 dpi. Still open there: "Va. Code § 59.1-584" alone on TOA page iii; "REQUEST FOR ORAL ARGUMENT" at the foot of page 9.
- Remaining gaps: Known gaps 2–4, 6, 7 (cover colour, disclosure statement, excerpt, weak overlay pairing, CM/ECF-only service). docx not rebuilt (no LibreOffice); the committed `.docx` predates the sample change.
