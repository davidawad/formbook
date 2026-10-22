# California Supreme Court: petition for review (`cal`)

Doc-type folder for the California Supreme Court (`cal`, `courts/ninth-circuit/california/state/supreme-court/`). It is self-contained: exemplars, sample, template, and this README. The court root's `typst/` and `usage/` (other doc types) are not touched.

Status: exemplar found (two filed petitions); typst template renders the sample with no warnings; overlay generated against the primary exemplar; every page of the sample rendered and inspected (13 of 13; again on 2026-10-16, see "Verification pass"). Typst and docx are on the cross-engine layout model (fb-595.68.37): the docx render breaks every line and page where typst does (`params.cross_engine: gate` in `eval.yaml`); no latex engine for this doc type.

## Folder

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-petition-for-review.pdf` | Primary exemplar (filed 2022-06-20, petitioner's counsel The Vora Law Firm). Used for the transcription and the overlay. |
| `usage/FILED-EXAMPLE-petition-for-review-2.pdf` | Second filer (filed 2022-11-28, Kazan McClain). Not transcribed; kept for the tier-2 comparison. |
| `usage/SOURCE.md` | URLs fetched, case, docket, filer, date filed, date fetched, and why each was chosen. |
| `usage/INPUT-petition-for-review.md` | Markdown transcription of a PORTION of the Quach petition (cover, tables, issues, part of introduction, statement, reasons, conclusion, certificate of compliance, proof of service). |
| `usage/OUTPUT-petition-for-review.typst.pdf` | Render of the sample: `sh tools/render.sh <this dir> usage/INPUT-petition-for-review.md`. 13 pages. |
| `usage/OVERLAY-quach-s275121.pdf`, `-overlay.txt` | Red/blue test against the Quach exemplar (see below). |
| `typst/main.typ` | Entrypoint: reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/cal-petition-for-review.typ` | The template: `cal-petition(meta, md)`. Content-agnostic; every number is a named parameter at the top and traces to a rule or a stated style choice. |

Build and overlay (from the repo root):

```sh
D=courts/ninth-circuit/california/state/supreme-court/petition-for-review
sh tools/render.sh $D usage/INPUT-petition-for-review.md
sh tools/overlay.sh $D quach-s275121 $D/usage/SAMPLE-quach-s275121-petition-for-review.pdf
```

Pass the exemplar explicitly to `overlay.sh`: with no third argument it uses the first exemplar alphabetically (Hoehn), which is not the one the sample was transcribed from.

## Governing rules

Verified 2026-10-14 against the courts.ca.gov rule pages (the "California Rules of Court 2026" text). Quotations are short; the rule text itself is the authority.

| Rule | Requirement | Where it is implemented |
|---|---|---|
| [8.504(a)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_504) | A petition must comply with the form rules of rule 8.204. | Whole template. |
| [8.504(b)(1)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_504) | The body must begin with a concise, nonargumentative statement of the issues presented for review. (Amended eff. 2024-01-01.) | `cal-petition()` panics unless the body's first heading contains "issue" and nothing precedes it (CAL-BODY-001). |
| 8.504(b)(4)–(6) | Copies of the Court of Appeal opinion/order must be attached. | **Not generated** (see Known gaps). |
| [8.504(b)(7)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_504) | The cover's case title and party designations must match the Court of Appeal opinion. | Cover caption comes from frontmatter `caption:`; the template does not check it against the opinion. |
| [8.504(d)(1)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_504) | A computer-prepared petition must not exceed 8,400 words, including footnotes, and needs a certificate stating the word count. | `word-limit = 8400`; `count-words()` on the body (CAL-LENGTH-001); the Certificate of Compliance prints the count (CAL-CERT-001). |
| 8.504(d)(3) | Tables, cover, the opinion, the word-count certificate, signature blocks and attachments are not counted. | The count is taken from the body markdown only. |
| [8.204(b)(4)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_204) | Font size at least 13-point, footnotes included. | `type-size = 13pt`; footnotes set at `type-size` (CAL-FONT-002). |
| 8.204(b)(5) | Text unnumbered and at least 1.5-spaced; headings and footnotes may be single-spaced; block quotes may be indented and single-spaced. | Text in exact 24 pt lines (`pitch-body`; 1.5 x the face's 14.95 pt single line is 22.4 pt; double, as the exemplar is); headings, footnotes, quotations, tables single-spaced. Line numbers are never printed. |
| [8.204(b)(6)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_204) | Margins: at least 1½ in left and right, 1 in top and bottom. | `margin-x = 1.5in`, `margin-y = 1in` (CAL-MARGIN-001). |
| 8.204(b)(7) | Pages numbered consecutively in Arabic numerals from the cover as page 1; the cover number may be suppressed. | Cover is page 1, number not printed; all later pages numbered from 2 (CAL-PAGE-001). |
| [8.74(a)(1)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | Text-searchable PDF. | Typst output; text layer checked with `pdftotext`. |
| 8.74(a)(2), (a)(7) | Page counter matches page numbers; 8½ × 11 in. | `paper: "us-letter"`; numbering from the cover. |
| [8.74(a)(3)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | A descriptive bookmark for each heading, subheading, and first page of each component (declaration, exhibit, proof of service). | Typst outlines every heading; a hidden outlined heading on the cover gives the cover a bookmark (CAL-BOOK-001). Checked in the PDF's outline (`/Title` entries). |
| [8.74(a)(9)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | The cover lists each filing attorney's name, mailing address, telephone number and State Bar number. | Frontmatter `counsel:` (names carry the SBN) and `phone:` (CAL-COVER-002). |
| [8.74(b)(1)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | Proportionally spaced serif face (Century Schoolbook preferred), 13-point including footnotes; sans-serif allowed for headings and captions. | Century Schoolbook is preferred, not required: **Times New Roman** (`font-family`, the house face, vendored; `docs/FONTS.md`), 13 pt, footnotes included, on typst and docx. The certificate names the face used, "Times New Roman". |
| [8.74(b)(2)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | Text 1.5-spaced (footnotes, headings, subheadings, quotations may be single). | Same as 8.204(b)(5). |
| [8.74(b)(3)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | Margins 1½ in left/right, 1 in top/bottom. | Same as 8.204(b)(6). |
| [8.74(b)(4)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | Left-aligned, not justified. | `justify: false` everywhere. |
| [8.74(c)(1)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_74) | The cover of a brief states its title, the trial court and Court of Appeal numbers, the trial court name and judges, and each party represented. | Cover: "PETITION FOR REVIEW", frontmatter `court_of_appeal:`, `trial_court:`, `judge:`, `counsel:`, and the party represented from `represents:` (CAL-COVER-001). |
| [8.25(a)(1)–(2)](https://www.courts.ca.gov/cms/rules/index/eight/rule8_25) | Serve each separately represented party and any other person required; attach a proof of service showing each person served and each party each attorney represents. | `proof-of-service()` from frontmatter `service:` (CAL-SERV-001). |
| [8.208](https://www.courts.ca.gov/cms/rules/index/eight/rule8_208) | Certificate of interested entities or persons. Its scope is principal briefs and filings in the Court of Appeal in civil appeals; the rule text does not address Supreme Court petitions. | **Not generated** (see Known gaps). |

Dates on the rules: 8.504 subdivision (b) eff. 2024-01-01 (subd. (a) 2007, (d) 2011); 8.204 as a whole last amended eff. 2024-01-01; 8.74 amended eff. 2026-07-01; 8.25 (a) eff. 2021-01-01; 8.208 amended eff. 2016-01-01. These are the dates the rule pages show.

Convention, not rule (chosen to match the exemplar, and the rules leave it open): Roman-numeral sections, bold capitals, centered; double spacing; first-line indent of ½ in; the title "Table of Contents" and "Table of Authorities"; the heading "Certificate of Compliance"; the proof of service text; a body with a "Conclusion" section (the template requires one, CAL-BODY-002).

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body. The template generates everything that is not argument.

### Frontmatter

| Field | Required | Feeds |
|---|---|---|
| `supreme_court_case` | no (default `S__________`) | Cover line "No. S…"; PDF title. |
| `court_of_appeal` | yes | Cover, the Court of Appeal number and district (rule 8.74(c)(1)). |
| `trial_court` | yes | Cover, the superior court and case number. |
| `judge` | no | Cover, the trial judge. |
| `caption` | yes | Two sides, each `names` (list, inline markdown allowed) and `designation` (right-aligned). "v." is inserted between the sides. Must match the Court of Appeal opinion (rule 8.504(b)(7)). |
| `counsel` | yes | Cover counsel block (rule 8.74(a)(9)). Each group: `names` (with SBN, as printed) and `lines`. |
| `phone` | yes | Appended to the last counsel group as "Telephone: …". |
| `represents` | yes | Cover line under the counsel block, in italics, naming the party represented (rule 8.74(c)(1)). |
| `signature` | yes | `signer` (printed as `/s/ Name`, then in capitals) and `lines` under it. Used after the Conclusion and on each certificate. |
| `date` | yes | Cover (bottom left), "Dated:" lines, the certificate and the proof of service. |
| `service` | yes | Proof of service. Each entry: `party`, `names` (optional), `lines` (optional), `method`. |
| `authorities` | yes if the body cites any | Table of Authorities registry; see below. |

### Body

- `# Heading` is a section (Roman numeral, bold capitals, centered). The first heading must be the issues presented (rule 8.504(b)(1)); a "Conclusion" section is required by the template.
- `##` is A., `###` is 1., `####` is a., `#####` is (1). Do not type the numbers; they are generated. Deeper than level 5 is an error.
- Case names and other emphasis: `*St. Agnes*`. Whatever is italic is italic.
- Authorities: cite with a link whose target is `toa:KEY` and the citation as the text, for every mention, including short forms and *Id.*: `[*St. Agnes*, 31 Cal.4th at 1203](toa:stagnes)`. The table of authorities is built from these links (page numbers come from where the link sits). A key missing from `authorities:` stops the build. Authorities cited on 7 or more pages print "passim". An unlinked mention is not in the table (this is what the ca9 contract also requires; the sample was linked on every mention).
- Footnotes: `text[^key]` and `[^key]: text`. Footnotes are 13 pt, single-spaced.
- Block quotations: `> text`. Indented, single-spaced.
- Smart punctuation is on (curly quotes, en/em dashes). Lists work; a paragraph beginning with a marker must be escaped as in any markdown.
- Not supported: tables, images, raw HTML, raw typst (`raw-typst` is off).

The word count in the certificate is computed from the body markdown (headings, text, footnote text; not list markers, footnote reference marks, or the generated parts). A count above 8,400 stops the build.

## Decisions

- **Exemplar: Quach over Hoehn.** Quach opens its body with "I. ISSUES PRESENTED FOR REVIEW" and its certificate states the font and word count. Hoehn opens with an "Introduction" and has no issues statement, which rule 8.504(b)(1) requires. The template follows the rule, so Hoehn is not transcribed.
- **Typeface: Times New Roman, 13 pt.** Rule 8.74(b)(1) says the face "must be a proportionally spaced serif face. Century Schoolbook is preferred"; preferred is not required, so the house face (Times New Roman, as the Hoehn exemplar uses) is set on every engine. The certificate states the face used ("13-point Times New Roman font"; it had named Century Schoolbook, which the PDF did not use).
- **Spacing: exact 24 pt lines** (double at 12 pt; at least 1.5 x the 14.95 pt single line, rule 8.204(b)(5)); single lines 14.95 pt.
- **Cover fits one page** with fixed 18 pt gaps between its parts; the template refuses to build if it does not fit (the type never shrinks). The counsel block and the signature column start 2 in from the margin.
- **The conclusion's last paragraph is kept with the signature block**, so the signature never stands alone on a page.
- **Certificate of compliance before the proof of service**, as in the exemplar.

## Overlay

`usage/OVERLAY-quach-s275121.pdf` puts each sample page (red) over the exemplar page it matches (blue); black is where both agree. Pages are paired by word overlap (`-overlay.txt`), not by index. It is a diagnostic, not a score. Read it page by page.

The pairing in the current render (TeX Gyre Schola; `-overlay.txt`): sample p.1 with filed p.1 (cover, 84%); p.2 (TOC) with filed p.2 (47%); p.3 (TOA) with filed p.5 (30%); the issues page (sample p.4) with filed p.8 (87%); the sample's pages 5 to 7 with filed pages 9 to 11 (78% to 81%); sample pages 8 to 13 with filed pages 14, 23, 24, 26, 42 and 78 (38% to 76%). The filed exemplar's body starts on p.8 and ours on p.4, because our TOC and TOA are shorter (they list only what the portion cites). The lower overlaps (sample pp.11 and 12, 38% and 58%) are where the sample skips exemplar text between the parts it transcribed, so the paired filed page holds text the sample does not have. Sample pages 12 and 13 are the certificate of compliance and the proof of service; they pair with filed pages 42 and 78, which are the exemplar's own certificate and proof of service.

## Verification pass 2026-10-16 (fb-595.26.15)

- Rendered `usage/INPUT-petition-for-review.md` with `tools/render.sh` (typst): exit 0, no warnings, 13 pages before and after the fixes (the committed OUTPUT was not stale in page count). Fonts (`pdffonts`): TeX Gyre Schola regular, bold, italic, embedded, nothing else.
- Viewed all 13 pages at 60 dpi before the fixes and all 13 again after them. Compared the exemplar's page 1 with our cover. Overlay re-run against the Quach exemplar and all 13 overlay pages viewed: pairing as in "Overlay" above (cover 84%).
- Fixed, page 1 (cover): the counsel block sat in a column fixed at half the text width, so "(SBN 266728)", "(SBN 323482)" and "Suite 300" wrapped onto lines of their own. It now sits against the right margin and is as wide as its widest line (at least half the text width), as in the exemplar. The address lines are upright (they were italic), the telephone carries "Telephone:", and the party represented is printed under the block (new required field `represents`, rule 8.74(c)(1)); the cover had no "Attorneys for …" line before.
- Fixed, page 2 (TOC): a wrapped entry ("Following Morgan, … Applies to") ran into the page-number column. Page numbers now sit in their own column; wrapped lines stop short of it.
- Fixed, pages 11 to 13 (signature blocks): same column fix as the cover, so "Attorneys for Plaintiff-Petitioner Peter Quach" no longer wraps.
- Not changed: tier 3 differences the overlay shows (the exemplar's small-capital counsel names, its tabular proof of service, the full counsel block under its certificate signature). Known gaps below are unchanged.

## Known gaps

1. **Typeface.** Times New Roman, not the Century Schoolbook that rule 8.74(b)(1) prefers (not requires).
2. **Court of Appeal opinion attachment** (rule 8.504(b)(4)–(6)). The petition must be filed with the opinion attached (and the attachments are not counted toward the length limit). The template produces the petition only; the opinion PDF is added at filing.
3. **Certificate of interested entities** (rule 8.208). Not generated. The rule text covers Court of Appeal civil appeals and does not address Supreme Court petitions, and the exemplars have none. Open question: whether the Supreme Court requires one for this petition. Not included until David decides.
4. **Service list.** The Quach exemplar serves the Court of Appeal and the superior court clerk as well as the parties. The rule text (8.25(a)) requires service on each separately represented party and any other person required by rule or statute; the rule that requires service on the court of appeal and trial court for a petition was not verified. The template prints whatever the frontmatter lists.
5. **The sample is a portion.** The statement after its first two parts, most of the reasons, and the Court of Appeal opinion are not transcribed. The certificate's word count (1,785 at the time of render) is the count of the sample's body, not of the real petition.
6. **Bookmarks.** Checked in the PDF outline for the headings, the cover, the TOC, the TOA, the certificate and the proof of service. Entries with curly apostrophes are stored hex-encoded in the file, so a plain grep finds only some of them.
7. **Checks.** `sh tools/check.sh <this dir>` (typst 9 passed, 0 failed) and `--engine docx` (13 passed, 0 failed, XENG-001..003 PASS). `tools/check-selftest.sh` needs a folder with `checks.yaml` and `court.json` and does not run here.
8. **Tier 2 is not measured.** The template is judged against one exemplar (Quach) plus the second filer's (Hoehn) conventions by eye; the overlay is diagnostic.

[Formbook index](../../../../../../README.md) | [Court root](../README.md)

## Engines

**docx** (`docx/reference.xml`: the cross-engine style recipe, `base="xengine"`, in the typst face; `docx/cal.lua` writes the document; `fb render --engine docx` builds it in passes, with the page numbers of the two tables from its needles; no shell scripts).

- The same content and layout as typst from the same markdown: the cover, the tables of contents and of authorities with page numbers, the heading labels, lists, footnotes (13 pt), the signature block kept with the last paragraph, the certificate of compliance with the same word count, the proof of service. Every paragraph in exact line boxes of the typst pitches (480 and 299 twips) with the typst spaces between blocks.
- Gate 4: XENG-001..003 PASS (282/282 lines, 13 = 13 pages), `params.cross_engine: gate`. Measured on the LibreOffice PDF; Word may paginate slightly differently (docs/DOCX.md).
- Not reproduced: PDF bookmarks (LibreOffice's export writes none by default).
