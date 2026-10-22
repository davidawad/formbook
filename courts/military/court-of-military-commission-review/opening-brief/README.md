# USCMCR: brief on behalf of appellant (opening brief)

Status for this doc type: exemplar=yes, render=ok, overlay=ok, pages_reviewed=16 (every page of `usage/OUTPUT-opening-brief.typst.pdf` and `.docx.pdf`, viewed after the cross-engine port, fb-595.54.7; the "Page review" table below is of the earlier render).

**Tier 1 (the rules' mandated form) is NOT verified.** The governing rules text could not be read (see "Rule basis"), and the typeface the rules call for is not vendored (see "Typeface"). Do not treat this template as passing tier 1.

## What is here

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-opening-brief.pdf` | The filed brief (Hicks, Nov. 5, 2013). Text-based PDF. |
| `usage/SOURCE.md` | URL, case, filer, date filed, date fetched. |
| `usage/INPUT-opening-brief.md` | Markdown transcription of the exemplar: cover data, issues, jurisdiction, statement of the case and facts, Argument I to III (in part), conclusion, footnotes, certificate data. |
| `usage/OUTPUT-opening-brief.typst.pdf` | Our render (13 pages). |
| `usage/OVERLAY-hicks-opening-brief.pdf`, `.txt` | Red (ours) over blue (filed) overlay, and its page map. |
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...`. |
| `typst/mc-opening-brief.typ` | The template: `mc-brief(meta, body)`. Court constants and rule-driven parameters at the top. |

Build and check (from the repo root, with the toolchain on `PATH`):

```sh
sh tools/render.sh courts/military/court-of-military-commission-review/opening-brief usage/INPUT-opening-brief.md
sh tools/overlay.sh courts/military/court-of-military-commission-review/opening-brief hicks-opening-brief
```

File-name deviations from the brief: the sample is `INPUT-<id>.md` (the tools strip `INPUT-` to derive the id, and CLAUDE.md says file roles belong in the name); the render is `OUTPUT-<id>.pdf` (the default output of `tools/render.sh`, which `tools/overlay.sh` reads); the overlay is `OVERLAY-<id>.pdf` and `.txt` (the default). `tools/check.sh` and `tools/check-selftest.sh` are not run for this doc type: there is no `checks.yaml` yet.

## Rule basis

The layout is meant to follow the USCMCR Rules of Practice. I could not read them.

| Requirement used by the template | Value | Source | Status |
|---|---|---|---|
| Type-volume (word) limit, principal brief | Not enforced; the certificate prints the word count from the frontmatter | CMCR Rules of Practice, Feb. 3, 2016 (mc.mil PDF), as quoted by a search summary: 14,000 words or 1,300 lines of monospaced text, placed in Rule 15(g) | **Unverified.** The mc.mil PDF returned HTTP 403 to WebFetch and "Access Denied" to curl. The 2013 filing cites "Rule 14(i)" for the same limit. The rule number conflicts between sources. |
| Typeface and point size | 12 pt; Liberation Serif stands in for Times New Roman (see "Typeface") | The 2013 filing's certificate: "12-point font and Times New Roman style", citing "Rule 14(e) and (i)"; a 2016 search summary says Times New Roman 12 pt | **Face: rule text unverified** (the mc.mil PDF is not reachable from the build box). The filing also says "monospaced typeface", which contradicts "Times New Roman". Substitute: metric-compatible (`docs/FONTS.md`). |
| Spacing | Double-spaced body text | 2016 search summary: "typed or printed, double-spaced, on white paper" | Unverified. |
| Margins, paper size | 1 in margins, US Letter | Not found | Unverified; chosen to match the exemplar's appearance. |
| Certificate of compliance and of service | Both generated | The 2013 filing's certificates | Form taken from the exemplar; rule number unverified. |

Primary source needed before tier 1 can be judged: the current CMCR Rules of Practice (the Office of Military Commissions site, or the Rules as published with the Regulation for Trial by Military Commission). Until then the rule numbers and values above are provisional.

### Searches tried

- WebSearch: "United States Court of Military Commission Review rules of practice and procedure ... font size word limit". No rules text; pointed to the mc.mil 2016 PDF.
- WebFetch and curl of `https://www.mc.mil/Portals/0/pdfs/CMCR%20Rules%20of%20Practice%20(Feb%203%202016).pdf` and three URL variants: all denied (403 / "Access Denied").
- WebSearch: "CMCR Rules of Practice ... Rule 14 ... 14,000 words ...". Returned the same 2016 summary and a "Rule 15(g)" reference.
- WebSearch: "Court of Military Commission Review" brief filed pdf. Returned the Hicks CMCR filings on ccrjustice.org, which became the exemplars.

## Exemplar

One exemplar: the Hicks appellant brief (CMCR Case No. 13-004, filed Nov. 5, 2013) by the Center for Constitutional Rights and the detailed defense counsel. The brief's own cover case number is blank; 13-004 comes from the government's brief in the same case.

Tier 2 calls for two or three exemplars from different filers. Only one opening brief was found in the public record. The second answering-type filing from the same case is in `../answering-brief/`, but it is not an opening brief, so tier 2 here rests on one filer and should not be treated as settled.

## Typeface

**Face required:** Times New Roman, as the filed exemplar is set (PDF fonts: TimesNewRomanPSMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT) and as its certificate states under "Rule 14(e)". The same certificate also mentions a monospaced 12-cpi option. The primary rule text could not be read: the mc.mil PDF does not resolve from the build box, and a WebSearch of the rule returned only the 2016 summary.

**Font used:** `Liberation Serif` (the Times New Roman substitute in `docs/FONTS.md`, metric-compatible), 12 pt. The template's `body-font` is set to it. Pagination is 13 pages both before and after the switch.

**Still open for tier 1:** the rule text itself. Until someone reads the current CMCR Rules of Practice (Rule 14(e) or its successor), the face is taken from the filings, not from the rule. The monospaced option is not used.

## Overlay (red/blue)

`usage/OVERLAY-hicks-opening-brief.pdf` pairs each of our pages with the filed page sharing the most words, and shows our render in red over that filed page in blue. The map, from `OVERLAY-hicks-opening-brief.txt`, after the final render:

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 (cover) | 1 | 97.3% |
| 2 (contents) | 2 | 88.3% |
| 3 | 5 | 87.6% |
| 4 | 6 | 53.8% |
| 5 | 8 | 56.9% |
| 6 | 10 | 77.4% |
| 7 | 11 | 78.0% |
| 8 | 12 | 51.5% |
| 9 | 14 | 73.7% |
| 10 | 15 | 81.6% |
| 11 | 19 | 36.5% |
| 12 | 18 | 75.9% |
| 13 | 19 | 84.2% |

The sample is an excerpt of the filed brief (the Argument from Part III onward, the appendix references and the table of authorities are not transcribed), so partial overlap is expected. The overlay is a diagnostic, not a score.

## Page review (Gate 2 stand-in)

Every page of `usage/OUTPUT-opening-brief.typst.pdf` was rendered at 60 dpi and viewed after the last change.

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover, caption, counsel | Clean after the row-gutter fix. Caption parenthesis column reads correctly. |
| 2 | Table of contents | Clean. Generated from headings; page numbers are typst's, not the filed brief's. |
| 3 | Body p.1: opening sentence, issues presented | **Open (tier 2):** issues (2) to (4) are indented as paragraphs; the filed brief hangs them. Cosmetic. |
| 4 | Body p.2: statement of the case, facts | Clean. Footnotes readable; citations italic; headings bold. |
| 5 to 8 | Body pp.3 to 6 | Clean. |
| 9 to 10 | Body pp.7 to 8 (argument, conclusion) | Clean. |
| 11 | Body p.9: closing signature block only | **Open (tier 2):** "Dated / Respectfully submitted / signature" falls alone on this page because the conclusion ends p.8. A signature page with no text is poor form. Keeping the conclusion with the signature is not done. |
| 12 | Certificate of compliance | Clean. The word count (3857) is the exemplar's figure, not counted from the sample. |
| 13 | Certificate of service | Clean. |

Fixes made during this review: paragraph spacing was zero, so separate paragraphs overlapped (cover, counsel block, issues list, body); paragraph spacing now matches the leading. The caption rows touched; a row gutter now separates them. "Respectfully submitted" was split from its signature; the closing and signature are now one unbreakable block. The certificate heading read "RULE 14(I)" (uppercased); it now reads "CERTIFICATE OF COMPLIANCE".

## Known gaps

- **Typeface**: Times New Roman (vendored; the PDFs embed TimesNewRomanPSMT), as Rule 15(e) names it (`../../rules.md`, MC-FORM-001). The "Typeface" section above describes an earlier Liberation Serif render.
- **Rules unverified** (above): the rule numbers and the 14,000-word, 12-point, double-spacing values are not confirmed against the primary text.
- **Table of authorities** is not produced. The table of contents is generated. A TOA would need a citation registry like the Ninth Circuit template's.
- **Word count** is a frontmatter value, not computed from the body.
- **Line spacing**: body lines at 27.6 pt, Rule 15(e) double spacing (see "Engines").
- **Signature alone on a page** (PDF p.11): open tier-2 item above.
- **Footnote size**: 12 pt (Rule 15(e) names 12 point for the document).
- **Exemplar coverage**: one opening brief from one filer; tier 2 asks for two or three.

## Engines

**Shared cross-engine layout model (fb-595.54.7).** The typst template (`typst/mc-opening-brief.typ`) imports `lib/typst/xengine.typ`, and the docx filter (`docx/mc.lua`) uses `lib/docx/xengine.lua` on `docx/reference.xml` (`fb render` builds the reference document; `build-reference.sh` and `reference.docx` are retired). Both engines set Times New Roman 12 pt (Rule 15(e); the vendored face, so `TNR-EMBEDDED` and `DEF-FONT-002` pass on both), footnotes included, in exact line boxes: body 27.6 pt (Rule 15(e) double spacing: twice Times New Roman's 13.8 pt single line), single-spaced material (cover, caption, contents, signature, certificates, footnotes) 13.8 pt, section headings 17 pt bold on 19.6 pt, argument headings 14.5 pt bold on 16.7 pt; first-fit breaks, no kerning, ligatures or hyphenation. The contents rows are `listing-row` (page column 36 pt, dot leader) in typst and right-indented leader-tab paragraphs in Word; the Word page numbers come from `fb render`'s multi-pass engine (needles per heading, `FORMBOOK_PAGES`, footers `rIdFtrNone`/`rIdFtrPage`, `FORMBOOK_FINAL`). pandoc reads "(a) ..." / "(1) ..." paragraphs as fancy lists; the filter writes them back as paragraphs, as CommonMark (typst) reads them. Both certificates print the word count with a thousands separator. The docx render breaks every line and page where the typst render does (`fb diff --engines`: XENG-001..003 PASS, 100 % of lines), so `eval.yaml` sets `params.cross_engine: gate`.

Render: `sh tools/render.sh <folder> usage/INPUT-opening-brief.md` (typst) and `sh tools/render.sh --engine docx <folder> usage/INPUT-opening-brief.md` (`usage/OUTPUT-opening-brief.docx` and `.docx.pdf`, LibreOffice). Check: `sh tools/check.sh <folder>` and `sh tools/check.sh <folder> --engine docx` (both 0 failed). Pages reviewed after the port: all 16 pages of the typst and of the docx PDF, at 60 dpi, side by side (no visible difference beyond the footnote rule's weight and the contents' page numbers set flush with the margin in Word).

Changes in the port that move the typst output: body pitch 19.7 pt to 27.6 pt (the template said "double-spaced", Rule 15(e) requires it, the exemplars are at about 27.6 pt), footnotes 11 pt to 12 pt (Rule 15(e): 12 point), headings 16.8/14.4 pt to 17/14.5 pt (whole half points), the certificate word count with a thousands separator, footnote text flush left with a space after the mark. Word may paginate slightly differently from LibreOffice (`docs/DOCX.md`).
