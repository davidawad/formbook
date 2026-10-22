# United States Court of Federal Claims: motion-brief

A motion for judgment on the administrative record (RCFC 52.1(c)) with its memorandum of law, the form used in bid protests. This folder is one self-contained doc type under the court (`uscfc`). The court-root `typst/` and `usage/` are not touched.

Status: **exemplar = yes** (in `usage/`), **typeface = Times New Roman 12 pt** (the rules name no face; `docs/FONTS.md` rule 6 and the exemplar's face; in typst and docx, Liberation Serif the typst fallback), **render = ok** (typst and docx, 14 pages each, re-rendered 2026-10-22, all pages viewed at 60 dpi; docx cross-engine gated, see Engines), **overlay = ok** (rerun 2026-10-16 against a rebuilt OCR text-layer copy; see "Verification pass 2026-10-16"). The brief is a full-depth form; the sample is an excerpt of a 72-page memorandum (14 rendered pages). Not a complete reproduction of the filing.

## Layout

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-motion-brief.pdf` | The filed package: motion (Doc. 59, pp. 1-3), memorandum (Doc. 59-1, pp. 4-75), proposed order (Doc. 59-2, pp. 76-78). |
| `usage/SOURCE.md` | Where it came from, filer, dates, and the search log. |
| `usage/INPUT-motion-brief.md` | Markdown transcription of the memorandum (excerpt). Frontmatter per the contract below. |
| `usage/OUTPUT-motion-brief.typst.pdf` | Our render (`tools/render.sh`). |
| `usage/OVERLAY-oracle-memorandum.pdf` / `.txt` | Red (ours) / blue (filed) overlay and page map (`tools/overlay.sh`). |
| `typst/main.typ` | Entry point: reads the sample, splits the frontmatter, calls the template. |
| `typst/uscfc-motion-brief.typ` | The template: `uscfc-brief(meta, md)`. Content-agnostic. |

Build and check (from the repo root):

```sh
sh tools/render.sh courts/federal-circuit/court-of-federal-claims/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/federal-circuit/court-of-federal-claims/motion-brief oracle-memorandum /work/artifacts/uscfc-motion-brief/oracle-18-1880C-textlayer.pdf
```

The overlay's third argument is the text-layer copy of the filing described under "Exemplar" below. It lives in `/work/artifacts`, not in this folder.

## Governing rules

Verified against the **RCFC as amended July 27, 2026**, from the court's rules PDF at `https://www.cofc.uscourts.gov/sites/cfc/files/Rules%2010.08.26.pdf` (the cofc.uscourts.gov "Current Rules (July 27, 2026)" link), fetched 2026-10-14. The rules page (`uscfc.uscourts.gov/rules-court`) returned 404 at the time of the check.

| ID | Rule | Requirement | Where it lands |
|---|---|---|---|
| RCFC-LEN-001 | 5.4(b)(1) | Initial brief: 40 pages, 50 for a cross-movant, not counting the TOC, TOA, or appendix, except by leave of the court on motion. | `page-limit` in the template; a build that runs over fails loudly. |
| RCFC-ORD-001 | 5.4(a)(2)(A)-(G) | Order: TOC; TOA (volume and page, cases alphabetical); questions presented; statement of the case; argument; conclusion; appendix. | Front matter order; the TOA groups cases first. |
| RCFC-FORM-001 | 5.5(c)(1)(A)-(C) | 8½ × 11 paper, letter-quality type, clear black on white. | `paper: "us-letter"`; vector output. |
| RCFC-FORM-002 | 5.5(c)(2) | Type size for text and footnotes no smaller than 12 point. | `type-size = 12pt`, footnotes 12pt. |
| RCFC-FORM-003 | 5.5(c)(3) | Margins no less than 1 inch each side. | `page-margin = 1in`. |
| RCFC-FORM-004 | 5.5(c)(4) | Text double spaced; quoted and indented material and footnotes single spaced. | `body-leading`; block quotations and footnotes single-spaced. |
| RCFC-FORM-005 | 5.5(c)(6) | Page numbers in the center of the bottom margin. | `number-align: center` in the footer. |
| RCFC-CAP-001 | 5.5(h) | "Bid Protest" in the caption directly below the court name, in all filings. | `bid_protest: true` prints it under the court name. |
| RCFC-CAP-002 | 5.5(g) | Name of the assigned judge directly below the docket number, in all filings other than the complaint. | `judge` is required and prints under the case number. |
| RCFC-CAP-003 | 10(a), 7(b)(2) | Caption: court name, title, file number, party designation; the rules for pleadings apply to motions. | Caption block; `case_number`, `parties`, `brief_title`. |
| RCFC-SIG-001 | 5.5(e) | The date the paper is signed, on the signature page. | `date`, printed as "Dated:" before the signature. |
| RCFC-SIG-002 | 5.5(f) | Email address and telephone number of the attorney of record directly below the signature line. | `phone` and `email` print directly under the signature line. |
| RCFC-SVC-001 | 5.3(a)-(b); 5(d)(1)(B) | Certificate of service attached to the end of the filing: day and manner of service, persons served, method. | `service` is required and prints the certificate at the end. |
| RCFC-MOT-001 | 7(b)(1)-(2) | A motion must state grounds with particularity and the relief sought; the caption rules apply to motions. | Covered by the caption block. The motion itself is a separate paper (see Known gaps). |
| RCFC-JAR-001 | 52.1(c)(1)-(2) | A JAR motion includes a statement of facts citing the administrative record; the response includes a counterstatement. | Covered by the content (the sample's Statement of Facts cites AR tabs), not by the template. |

Not required and not generated: a certificate of compliance. The RCFC impose page limits, not word limits, so the ca9 word-count certificate has no analogue here.

## Markdown contract

The sample is one `.md` file: a YAML frontmatter block, then the body.

Frontmatter fields:

- `case_number` (required), `judge` (required, RCFC-CAP-002), `bid_protest` (default false; set true for bid protests, RCFC-CAP-001).
- `parties`: list of `{name, role}`. `name` prints as a caption line; `role` prints indented under it. A party with only `name` (for example "and", "v.") is a connective line.
- `brief_title`: printed in capitals on the cover and in the certificate.
- `counsel`: list of groups `{names, lines}`; the groups print side by side (for example "Of Counsel" and the attorney of record). Names may carry inline markdown.
- `phone`, `email` (required, RCFC-SIG-002), `date` (required, RCFC-SIG-001).
- `signature`: `{signer, lines}`. `signer` prints as `/s/ Name`, then the name; `lines` print after the email.
- `service` (required, RCFC-SVC-001): `{day, manner, documents, recipients: [{lines}]}`.
- `authorities` (required if the body cites): keys used as `toa:KEY` link targets in the body. `kind` is `case`, `statute`, `regulation`, `rule` or `other`. `name` is optional (italic for cases), `cite` is required, `sort` overrides the sort key. Cited on 7 or more pages prints "passim".
- `cross_motion` (default false): true sets the page limit to 50.

Body:

- `# Heading` is a section (level 1): centered, bold, capitals, numbered I., II., ... by the template. Do not type the numbers.
- `## Heading` is A., B., ...; `### Heading` is 1., 2., ...; `#### Heading` is a., b., ...; `##### Heading` is (1), (2). Do not type the numbers; the template generates them. (The first draft typed them and produced "A. A.", which was fixed.)
- Case names in italics: `*Horne v. Flores*`. Short forms and *Id.* in italics too.
- Authority links: `[*Full cite*](toa:KEY)`; short forms link to the same KEY. The TOA page numbers come from the links.
- Footnotes: `text[^key]` and `[^key]: text` at the end.
- Block quotations: `> quoted text` (single-spaced, indented).
- Escape markers that start a paragraph: `1\. Whether ...`.
- The signature block follows the last paragraph, kept together with it.

## Decisions

**Font: Times New Roman at 12 point.** RCFC 5.5(c)(2) sets only the minimum type size (12 point) and names no typeface; the whole rules PDF (as amended July 27, 2026) was searched and names none. Per `docs/FONTS.md` rule 6, a court that names no face gets the house face, Times New Roman, which is also the filed exemplar's face (the template set EB Garamond until 2026-10-17).

**Double spacing** (before the cross-engine port of 2026-10-22, on the EB Garamond render; the body pitch is now 27.6 pt, see Engines)**.** `body-leading = 0.9em` was chosen by eye for a double-spaced look at 12 point. Measured 2026-10-16 on the render (`pdftotext -bbox`, body p. 1): 26.46 pt baseline pitch (2.2 em). The complaint template uses 27.6 pt (2 × 1.15 em); both are double spaced, but the two doc types differ slightly.

**Email under the signature.** The exemplar's signature block gives telephone and fax but not the email; the email is on the cover only. RCFC 5.5(f) requires the email "directly below the signature line of every filing", so the template prints it there. This is a rule-driven deviation from the exemplar.

**Bid Protest caption.** RCFC 5.5(h) requires it in all filings. The exemplar has it.

**Certificate of service.** The exemplar's motion (Doc. 59, p. 3) includes one, with the RCFC 5.3 content. The template prints it at the end of the filing. There is no certificate of compliance.

**Heading numbering.** The author's own numbering in the exemplar is mixed (for example "1. INTRODUCTION" followed by "II."). The template numbers every level-1 section with a Roman numeral. This is a convention choice, not a rule. Tier 3 (one filer's style) is not chased.

**Page limit.** The memorandum in the exemplar runs 72 pages, which exceeds RCFC 5.4(b)(1) (40 pages, 50 for a cross-movant) unless leave was granted. The motion says it is filed "pursuant to the Court's Scheduling Order"; the leave order is not in the exemplar, and this box did not look it up. The template enforces the limit on our build, not the exemplar's.

## Exemplar and transcription

- The filing is text-based only on pp. 1-3 (the motion). The memorandum (pp. 4-75) and the proposed order (pp. 76-78) are scanned images with no text layer.
- The sample was transcribed from an OCR (tesseract 5.5.3, 300 dpi, `--psm 6`) of the scanned pages. The cover (p. 4) was checked against the image; the email address in the OCR was wrong and is corrected (craig.holman@arnoldporter.com). Other passages were not checked against the images one by one. Redacted passages are omitted. The sample is a visual comparison, not a certified copy.
- The overlay (`tools/overlay.sh`) pairs pages by extracted text, so a scanned exemplar gives no pairing without a text layer. An OCR text-layer copy was built from the same images and the native text of pp. 1-3 (`/work/artifacts/uscfc-motion-brief/oracle-18-1880C-textlayer.pdf`, 78 pages, outside the repo), and passed to the overlay as its third argument. The filed file in `usage/` is unchanged.

## Overlay

Pages paired by word overlap (the map is in `OVERLAY-oracle-memorandum.txt`; measured on the earlier 13-page EB Garamond render):

| Ours | Filed | Overlap | Note |
|---|---|---|---|
| p.1 | p.4 | 77.5% | Cover. |
| p.2 | p.5 | 34.8% | TOC. |
| p.3 | p.7 | 32.9% | TOA. |
| p.4 | p.11 | 93.9% | Introduction. |
| p.5 | p.12 | 71.0% | Introduction, continued. |
| p.6 | p.13 | 65.3% | Introduction, footnotes. |
| p.7 | p.21 | 41.1% | Statement of Facts A. |
| p.8 | p.22 | 46.8% | Statement of Facts A-B. |
| p.9 | p.23 | 42.3% | Statement of Facts B. |
| p.10 | p.31 | 37.7% | Jurisdiction (filed p.31-32). |
| p.11 | p.32 | 95.6% | Jurisdiction, Argument A. |
| p.12 | p.75 | 62.3% | Conclusion and signature (pairs with the filed conclusion). |
| p.13 | p.3 | 79.3% | Certificate of service (pairs with the filed motion's certificate). |

Red is ours, blue is filed; black is agreement. The pairing is by text, so a low score on a page means the wording differs, not necessarily the layout.

## Gate review (pages reviewed)

All 13 rendered pages (the earlier EB Garamond render) were rasterized at 60 dpi and viewed in montage (`pdftoppm -r 60`). Defects found and fixed:

1. Typed heading numbers in the sample ("A. A. The Single Award...") — numbers removed from the markdown; the template generates them.
2. Counsel names printed with literal asterisks ("*Of Counsel:*") — names now go through inline markdown.
3. Certificate recipient lines printed literal asterisks ("*Counsel for Defendant*") — now inline markdown.
4. The table of authorities heading and the certificate heading appeared in the table of contents — now unnumbered and outside the TOC, as in the exemplar.

After fixes 2-4 the re-render was checked by text extraction (pp. 1, 10, and the TOA heading); the montage images predate those fixes. All 13 pages of the current render were viewed on 2026-10-16 (see below).

## Known gaps

- **The motion itself (Doc. 59, RCFC 7(b)).** The template renders the memorandum. The short motion paper, with its own caption, is not modeled. It is a separate document and would be a second sample.
- **The sample is an excerpt.** It covers the Introduction, Questions Presented, parts of the Statement of Facts (A-B), the jurisdiction section, part of Argument A, and the conclusion. The TOC and TOA list only what the excerpt contains. The exemplar's Argument (Parts V-VI), its Argument headings, and its full TOA are not reproduced.
- **Overlay pairing for scanned exemplar pages** depends on the OCR text-layer copy outside the repo. If that copy is regenerated, the overlay must be regenerated.
- **The page limit** is enforced on our render, but the sample is short, so the check is not exercised near the limit.
- **Font.** See Decisions: 12 point Times New Roman, the house face, because the rules name no face.
- **Single exemplar.** One filing from one filer. The brief asks for one exemplar per doc type; for tier-2 conventions the usual practice is two or three filers, which this box did not find (CourtListener's motion PDFs for uscfc are mostly opinions; docket pages and docket-entry API need auth).

## Engines

Engines: typst (the reference) and docx; no latex folder for this doc type. Both run on the shared cross-engine layout model (fb-595.54.6; `lib/typst/xengine.typ`, `lib/docx/xengine.lua`, `lib/docx/xengine-reference.sh`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt in both (Liberation Serif, the same metrics, the typst fallback), first-fit ragged-right lines, no kerning, ligatures or hyphenation, exact line boxes of 27.6 pt (double-spaced text) and 13.8 pt (cover, headings, quotations, footnotes, tables, signature), the typst spaces between blocks in twips; contents and authorities as `listing-row` (the text wraps before a 36 pt / 56 pt page column, a dot leader to the number). **Cross-engine gated** (`eval.yaml`: `params.cross_engine: gate`): the docx breaks every line and page where the typst render does (XENG-001..003 PASS, 319 of 319 lines), the TOC and TOA page numbers included.

`fb render --engine docx` builds the reference document from `docx/reference.xml`: the shared recipe (`base="xengine"`), plus the "Keep With Next" style (the body's arabic numbering from 1 is in the sections the filter writes). `docx/uscfc-motion-brief.lua` writes the cover (caption one table row per line), the TOC and TOA, the numbered headings, the signature block and the certificate, and sets two break rules typst has and LibreOffice does not: no break inside "2304a(d)(4)" (a word joiner between ")" and "("), and a break opportunity after a slash before a letter in a URL (a zero-width space). `fb render --engine docx` owns the build (`docx/render.sh` did until fb-595.68): it measures the page of each heading and of each authority link on a first build (a link by its text and the words after it, so a heading that names the same statute without a link is not counted, as typst counts only links) and builds again with those numbers.

Visible change of the port in the typst render (2026-10-22, all 14 pages viewed at 60 dpi): Times New Roman instead of EB Garamond in the docx; the cover is laid out with fixed spaces (a double line between its parts) instead of the largest spacing that fits, and its caption rows now line up (they overlapped before); single-spaced material on a 13.8 pt pitch (was 15.6 pt); the body on a 27.6 pt pitch (was 26.5 pt), so the brief runs 14 pages (was 12; the body and certificate 11, was 9). The TOC and TOA page numbers follow.

## Verification pass 2026-10-16 (fb-595.26.14)

- Rendered: `sh tools/render.sh … usage/INPUT-motion-brief.md`, exit 0, no typst warnings, EB Garamond only. 13 pages (cover, TOC i, TOA ii, body 1-10), the same count as the committed PDF.
- Viewed: all 13 pages at 60 dpi, before and after the fixes; exemplar pp. 3, 4 and 75 at 50 dpi; all 13 overlay pages.
- Overlay: the OCR text-layer copy named above (`/work/artifacts/...`) is no longer on the box. Run without it, `tools/overlay.sh` paired 11 of 13 pages with the wrong filed page (overlap 5-12%), because pp. 4-78 of the exemplar are scans. The copy was rebuilt outside the repo (`/tmp/uscfc-textlayer.pdf`, which is not kept): native pp. 1-3, plus pp. 4-78 OCR'd with tesseract 5 (conda-forge, `--psm 6`, 300 dpi). `sh tools/overlay.sh … oracle-memorandum /tmp/uscfc-textlayer.pdf` exited 0, and the page map is the same as in the Overlay table (cover 80.3%, p. 12 61.4%, p. 9 40.0%; the other pages unchanged). In the overlay the body lines drift apart down each page (different face and leading), and the exemplar's caption box, redaction bars and "REDACTED VERSION" stamp are absent from ours (tier 3 / not template content).
- Fixed:
  1. The certificate of service statement was single spaced, with no indent. RCFC 5.5(c)(4) double-spaces text, and the exemplar's certificate (p. 3) is double spaced. It now uses the body leading and a first-line indent; the recipient blocks stay single spaced.
  2. The certificate's `/s/` signature was placed about 0.85 in from the left margin, not in the signature column. It is now in the right half, on a signature rule.
  3. The brief's signature block had no signature line. RCFC 5.5(f) puts the email and phone "directly below the signature line", and the exemplar draws one. `/s/ Name` now sits on a rule the width of the column.
- Gaps that remain: Known gaps above. The docx was not re-rendered in this pass (no LibreOffice on the box), so it does not have fixes 1-3. The latex engine has no folder for this doc type. The overlay depends on a text-layer copy that is not in the repo.

## Search log

- CourtListener API v4, `type=rd`, `court=uscfc`, queries for "motion for judgment on the administrative record", "motion to dismiss", "motion for summary judgment": results are overwhelmingly opinions; no motion PDF with an available file other than the Oracle filing was found. Rate limit: 5 requests per minute.
- Direct RECAP storage probes for motion document numbers (Docs. 1, 54, 64, 65 across several dockets): 404.
- CourtListener docket pages and docket-entries API: 403 / authentication required.
- WebSearch: "Court of Federal Claims motion for judgment on the administrative record pdf" — returned the Oracle filing (washingtontechnology.com). Also returned opinions and the Land of Lincoln 16-744C response (a response, not a motion).
- Court rules: `cofc.uscourts.gov/rules` lists the current rules PDF (July 27, 2026); the first candidate URL on `uscfc.uscourts.gov` returned 404.

[Formbook index](../../../../README.md) | [Court README](../README.md)
