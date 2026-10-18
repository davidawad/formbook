# USCMCR: brief on behalf of appellant (opening brief)

Status for this doc type: exemplar=yes, render=ok, overlay=ok, pages_reviewed=13 (every page of `usage/OUTPUT-opening-brief.typst.pdf`, viewed after the last render).

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

- **Typeface** (above): Liberation Serif now stands in for Times New Roman. The face comes from the filings, not the rule text, which is unverified.
- **Rules unverified** (above): the rule numbers and the 14,000-word, 12-point, double-spacing values are not confirmed against the primary text.
- **Table of authorities** is not produced. The table of contents is generated. A TOA would need a citation registry like the Ninth Circuit template's.
- **Word count** is a frontmatter value, not computed from the body.
- **Line spacing** is set as `leading: 0.95em` (double-spaced by eye), not measured against a rule.
- **Signature alone on a page** (PDF p.11): open tier-2 item above.
- **Footnote size** is 11 pt; the rule on footnote size is not verified.
- **Exemplar coverage**: one opening brief from one filer; tier 2 asks for two or three.

## Engines

**docx** (`docx/`: `build-reference.sh` builds `reference.docx` from pandoc's default reference, `mc.lua` builds the cover, contents, signature and certificates from the frontmatter). Render: `sh tools/render.sh --engine docx <folder> usage/INPUT-opening-brief.md` writes `usage/OUTPUT-opening-brief.docx` and `.docx.pdf` (LibreOffice). Pages reviewed: 13 of 13 (every page of the `.docx.pdf`, each compared with the typst page; the review PNGs are in `/work/artifacts/mc/opening-brief/`, not committed).

- Matches the typst form: Liberation Serif 12 pt (the Times New Roman substitute, `docs/FONTS.md`; `pdffonts` shows only LiberationSerif), 1 in margins, US Letter; caption with the parenthesis column; counsel block; centered bold level-1 headings (17 pt, the size the typst headings render at) and bold hanging level-2/3 headings; footnotes 11 pt; cover and contents unnumbered; body numbered from 1, centered; certificates on their own pages; the signature block kept together.
- Differs: the word count prints with a thousands separator (3,857), as the filed exemplar does; the typst prints 3857. The issues list (1) to (4) is a Word numbered list with a hanging indent, not the typst paragraphs. Word may paginate differently from LibreOffice.
- Typst leading: the typst body renders at a 19.25 pt line pitch (measured), which is not the 25 pt a 12 pt double-spaced line gives in Word. The docx keeps the typst pitch. Whether the rules require true double spacing is unverified (see "Rule basis").
- BLOCKED: TOC page numbers (the contents field has cached entries without page numbers; a field update in Word or LibreOffice adds them; no second pass is implemented). No check ID exists yet (no `checks.yaml`).
- BLOCKED: `sh tools/check.sh <folder> --engine docx` exits 2: `Error: open .../checks.yaml: no such file or directory`. Gates 0 to 3 were not run.
