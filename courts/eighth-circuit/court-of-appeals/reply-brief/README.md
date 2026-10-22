# Eighth Circuit Court of Appeals: reply brief

Doc type `reply-brief` for court `ca8` (folder `courts/eighth-circuit/court-of-appeals/`). One self-contained folder per doc type; the court-root `typst/` and `usage/` (ca8 court folder, not this one) are untouched.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-reply-brief.pdf` | Real filed reply brief, 8th Cir. No. 24-1786 (19 pp.). Provenance in `usage/SOURCE.md`. |
| `usage/INPUT-reply-brief.md` | Transcription of that brief (frontmatter = cover, counsel, signature, certificates, authorities; body = argument, conclusion, footnotes). |
| `usage/OUTPUT-reply-brief.typst.pdf` | `sh tools/render.sh courts/eighth-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md` (18 pages). |
| `usage/OVERLAY-delgado-midland.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/eighth-circuit/court-of-appeals/reply-brief delgado-midland` (red = ours, blue = filed, black = both). |
| `typst/main.typ` | Entry point: reads the sample named by `--input sample=...`. |
| `typst/ca8-reply-brief.typ` | Template `ca8-reply-brief(meta, md)`. Content-agnostic; the numbers are named parameters at the top. |

## Governing rules

Verified 2026-10-14. Primary text where marked; the rest is secondary.

| ID | Requirement | Source (verified) | How the template meets it |
|---|---|---|---|
| CA8-FORM-002 | Margins at least one inch on all four sides | FRAP 32(a)(4), https://www.law.cornell.edu/rules/frap/rule_32 (fetched 2026-10-14) | `page-margin = 1in` |
| CA8-FORM-003 | Text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced | FRAP 32(a)(4) (same) | `body-leading`; quotations, headings, footnotes single-spaced |
| CA8-FORM-004 | Proportionally spaced serif face, 14-point or larger | FRAP 32(a)(5)(A) (same) | Times New Roman (pinned install; latex newtxtext/newtxmath) at 14 pt everywhere, including footnotes: the standard face (David 2026-10-17, PM decision fb-595.54.9), though the audited exemplar is set in Georgia (`data/exemplar-fonts.json`, `template_face`); the certificate names it ("Times New Roman, 14-point"). |
| CA8-LIMIT-001 | Reply brief no more than half the principal-brief type volume: 6,500 words | FRAP 32(a)(7)(B)(ii) (same); the principal figure 13,000 (FRAP 32(a)(7)(B)(i)) | `word-limit = 6500`; the build fails above it. The 8th Cir. local principal limit (R. 28A(i)) was not retrieved, so it is not used. |
| CA8-COVER-001 | Cover: case number centered at top; court; case title; nature of the proceeding and court below; brief title identifying the party; counsel name, office address, telephone | FRAP 32(a)(2)(A)-(F) (same) | Cover body; the phone number is part of each counsel block's `lines` |
| CA8-COVER-002 | Reply cover colour gray | FRAP 32(a)(2) (same) | **Not produced**: paper copies only. The electronic PDF has a plain cover. |
| CA8-CERT-001 | Certificate of compliance by the attorney, stating the word count; Form 6 meets the requirement | FRAP 32(g)(1)-(2) (same) | `certificate-of-compliance`: Form 6 wording; word count computed from the markdown |
| CA8-CERT-002 | Electronic-version statement that the brief was scanned for viruses and is virus-free | 8th Cir. R. 28A(h)(2): **secondary** (search excerpt of the rule; courtrules.net and ca8.uscourts.gov returned 403 / were not retrieved). Cited in the exemplar as "Circuit Rule 28A(h)". | Statement in the certificate of compliance |
| CA8-CERT-003 | Certificate of service through CM/ECF | FRAP 25; 8th Cir. R. 25A(a) as cited in the exemplar (**not independently verified**) | `certificate-of-service`, printed when `service.certificate: true` |
| CA8-CONT-001 | Table of contents (headings, page numbers) | Convention; exemplar p. i | Outline with dot leaders; the TOA heading is kept out of the TOC, as in the exemplar |
| CA8-CONT-002 | Table of authorities with the page of each citation; "passim" at 7 or more pages | Convention; exemplar pp. ii-iii | Built from `toa:` links in the body, grouped by kind (cases, statutes, rules, other) |
| CA8-CONT-010 | Heading scheme: section headings centered, bold capitals; then A. / 1. / a. / (1) | Exemplar (the rules leave it open) | `style-heading`, `heading-label` |

Not produced, on purpose: a corporate disclosure statement (FRAP 26.1 is filed separately in the 8th Circuit; the exemplar's signature block carries the 501(c)(3) statement, which the template prints as the signature `note`), an addendum, a statement of related cases (not in the reply-brief form used by this exemplar).

## Markdown contract (frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover top line |
| `caption` | yes | list of `{names, designation}` for the two sides; "v." inserted between them |
| `proceeding` | yes | "On Appeal from ..." line (write it in the case's own caps) |
| `brief_title` | yes | Cover title (in capitals), certificate of service description |
| `counsel` | yes | list of `{names, lines}`; `lines` are printed plain; put the telephone number in `lines` |
| `signature` | yes | `signer` (printed "/s/ Name" and then the name), `lines`, optional `also` (further counsel, unsigned), optional `note` (single-spaced paragraph under the block), optional `role` (the line under the name in the certificate signatures; default "Counsel for Appellant") |
| `date` | no | Under the signature block; the date in the certificate of service |
| `service` | no | `certificate: true` prints the certificate of service |
| `authorities` | yes if the body cites any | map of key to `{kind, name, cite}` (`kind`: `case`, `statute`, `rule`, `other`, `constitution`, `regulation`); `name` is omitted for statutes, rules and other |

Body: `# Heading` is a section (centered); `##` A.; `###` 1.; `####` a.; `#####` (1). Do not type the numbers. Case names and signals in `*italics*`. Citations link to their authority: `[*Heintz v. Jenkins*, 514 U.S. 291, 299 (1995)](toa:heintz)`; a short form links to the same key. A key missing from `authorities:` stops the build. Footnotes `text[^fnN]` with `[^fnN]: text` definitions at the end of the file. Pinpoint asterisks are escaped: `\*3`. Smart punctuation is on. The word count is taken from everything before the certificates.

## What the overlay shows

`usage/OVERLAY-delgado-midland.pdf` puts our render (red) over the filed brief (blue), page by page. Pages are paired by word overlap (`-overlay.txt`), not by index. The pairing scores run 40% to 100% (page 1: 100%, page 2: 90%, page 17: 40%). The differences are layout, not content:

- The filed brief uses Gelasio (Georgia metrics); ours uses the house-standard Times New Roman. The cross-engine template outputs match typst's line and page breaks except for the documented DOCX whole-twip variance below.
- Pages 1-2 (cover, contents) overlay closely. Our TOA runs 3 pages (ii-iv) against the filed 2; the page numbers in the TOA and TOC therefore differ from the filed ones.
- The body is one page ahead or behind in places; that is the same text on a different page.

## Pages reviewed (Gate 2)

All 18 pages of `usage/OUTPUT-reply-brief.typst.pdf` were rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Findings and fixes made:

| Page (PDF) | Finding | Result |
|---|---|---|
| 1 | Cover: case number, court, caption, proceeding, title, counsel and date all on one page | OK |
| 2 | TOC: "Table of Authorities" listed as a contents entry (not in the filed contents) | Fixed: heading excluded from TOC |
| 3-5 | TOA ran to 4 pages with the last holding one entry | Fixed: entry spacing tightened; now 3 pages |
| 6-16 | Body: 11 pages, double-spaced, 14 pt, footnotes 1-3 on their pages, headings in order | OK |
| 17 (before the fix) | The signature block stood alone on a page (footnote definitions at the end of the markdown stopped the keep-with-signature rule) | Fixed: the last paragraph is kept with the signature; the conclusion now starts on the page with the signature |
| 17 | Certificate of compliance: "14-point" broke at the hyphen | Fixed: kept together |
| 18 | Certificate of service | OK |

## Verification pass 2026-10-22 (fb-595.54.9)

- Times New Roman is used on typst, LaTeX (`newtxtext`/`newtxmath`) and docx; the certificate states "Times New Roman, 14-point." All pages of all three engines were reviewed after the final render; see [the page-by-page review](reviews/2026-10-22.md).
- Fixed (tier 2): the signature under both certificates was set in markup with `\` breaks, so each line picked up a leading space and the three lines stepped to the right. It is now one `cert-sig` block, flush left from mid-page like the signature block, with the role line from `signature.role` (default "Counsel for Appellant") instead of fixed text.
- Checked, no defect: cover on one page; TOC (i) and TOA (ii-iv) page numbers match the body; footnotes 1-3 on their pages at 14 pt; no heading stranded; page 15 ends short because the conclusion is kept with the signature block (as before).
- All applicable tier-1 checks pass. DOCX XENG-003 is reported under the documented one-twip LibreOffice limitation (397/400 line endings); no tier-2 findings remain.

## Known gaps

- **Word count**: the certificate states 2,557 words; the filed brief's own certificate states 2,741 (Microsoft Word). The template counts whitespace-delimited words from the markdown, which is not Word's method, so the two numbers are not comparable. The printed number is the template's.
- **Length**: 18 pages in total (cover, 1 page of contents, 3 of TOA, 11 of body, 2 of certificates); the filed brief is 19 (body 13). The body was transcribed in full, so the sample is at the exemplar's length, above the 8-14 page target. It was not trimmed to hit the target.
- **Emphasis**: the filed brief's italics on "(emphasis added)" are not reproduced; the markdown has the phrase without the italics.
- **Cover colour** (FRAP 32(a)(2)): not produced; paper copies only.
- **Font**: Times New Roman (the standard face, David 2026-10-17; fb-595.54.9), not Georgia. The FRAP requirement is a proportional serif at 14 pt; both meet it.
- **Secondary sources**: 8th Cir. R. 28A(h)(2) and R. 25A(a) are cited from the exemplar and a search excerpt. The court's own rules page was not retrievable from this box (403). Re-verify against the court's rules before relying on the certificate wording.
- **No other doc type** is in this folder. Opening brief, cross-appeal and other ca8 doc types are not covered.

## Engines

All three engines are on the shared cross-engine layout model (`lib/*/xengine*`; docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.54.4, fb-595.54.9): first-fit line breaking, no kerning, ligatures or hyphenation, exact line boxes (28 pt body, 17 pt single-spaced lines), the typst template's spaces in pt. Every engine certifies 2,557 words and uses Times New Roman (LaTeX: `newtxtext`/`newtxmath`), the standard face under David's 2026-10-17 ruling (PM decision fb-595.54.9; `template_face` in `data/exemplar-fonts.json`), although the filed exemplar uses Gelasio (Georgia metrics).

`params.cross_engine: gate`, `params.cross_engine_docx: report` (`eval.yaml`). 18 pages on every engine.

- latex: XENG-001..003 PASS, 400 of 400 lines.
- docx: XENG-001 and XENG-002 PASS (every page and page end); XENG-003 REPORTED, 397 of 400 lines: on p9 line 14 typst overflows the measure by 0.07 pt with "collateral", and LibreOffice, which decides a line in whole twips (its PDF sets that line 0.08 pt narrower than typst's), keeps the word, so p9 lines 14 to 16 break one word later. A 1-twip right indent on Body Text fixes p9 and breaks p16 line 2 instead (typst fills it to within 0.01 pt, and LibreOffice then measures it as too wide although its PDF sets it 0.2 pt narrower): no template setting reproduces a sub-twip decision, so the docx is reported, not gated.

- **typst** (primary, `typst/`): the reference. For the cross-engine model: footnote marks are scaled digits (`super(typographic: false)`, never a face's superior figures), widows and orphans cost 10000 %, and a paragraph whose last line carries a footnote too long to fit with it carries its second-to-last line over too (`lib/typst/xengine.typ`, the footnote widow guard: p12/p13 of this INPUT, where typst had left "§ 548.101(a)(5) (emphasis added).²" alone at the top of p13 while LaTeX and Word carry two lines); a URL breaks only after `?`, `=`, `&`, a hyphen or a slash (not after its scheme's `//`), the counsel block and signatures start at a fixed share of the text width (`right-half`).
- **latex** (`latex/template.tex`, `latex/ca8.lua`): stock pdflatex, newtxtext/newtxmath; every block built as typst builds it, sizes and spaces in bp; the ellipsis over 1 em, Times New Roman's glyph; no italic correction. The text width is 0.05 bp wider than typst's: newtx sets a line up to about 0.04 bp wider than Times New Roman (p9 line 11, which typst fills to within 0.02 bp, took one word less).
- **docx** (`docx/render.sh`, `docx/ca8.lua`, `docx/build-reference.sh`, `docx/reference.docx`, `docx/pagemap.awk`, `docx/footer.xml`): pandoc on the reference built by `lib/docx/xengine-reference.sh` plus the "CA ..." styles; render.sh writes the sections and footers and fills the TOC and TOA page numbers from a first LibreOffice pass (a URL citation is found by its text up to its first break point). The certificate's "Fed. R. App. P." no-break spaces are written as runs (xe.inlines turns one after a period back into a space).
