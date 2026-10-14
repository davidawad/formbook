# United States Court of Federal Claims: motion-brief

A motion for judgment on the administrative record (RCFC 52.1(c)) with its memorandum of law, the form used in bid protests. This folder is one self-contained doc type under the court (`uscfc`). The court-root `typst/` and `samples/` are not touched.

Status: **exemplar = yes** (the PDF is not in `exemplars/` on the 2026-10-14 fonts-pass box; see Exemplar below), **typeface = EB Garamond, kept** (the rules name no face; see Decisions), **render = ok** (re-rendered 2026-10-14, 13 pages, EB Garamond only, 13 of 13 pages viewed at 50 dpi), **overlay = fail on this box** (`tools/overlay.sh` needs `exemplars/*.pdf` and the OCR text-layer copy, neither present; the committed `OVERLAY-oracle-memorandum.*` were not rewritten). The brief is a full-depth form; the sample is an excerpt of a 72-page memorandum (13 rendered pages). Not a complete reproduction of the filing.

## Layout

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-oracle-18-1880C-motion-brief.pdf` | The filed package: motion (Doc. 59, pp. 1-3), memorandum (Doc. 59-1, pp. 4-75), proposed order (Doc. 59-2, pp. 76-78). |
| `exemplars/SOURCE.md` | Where it came from, filer, dates, and the search log. |
| `samples/INPUT-oracle-memorandum.md` | Markdown transcription of the memorandum (excerpt). Frontmatter per the contract below. |
| `samples/OUTPUT-oracle-memorandum.pdf` | Our render (`tools/render.sh`). |
| `samples/OVERLAY-oracle-memorandum.pdf` / `.txt` | Red (ours) / blue (filed) overlay and page map (`tools/overlay.sh`). |
| `typst/main.typ` | Entry point: reads the sample, splits the frontmatter, calls the template. |
| `typst/uscfc-motion-brief.typ` | The template: `uscfc-brief(meta, md)`. Content-agnostic. |

Build and check (from the repo root):

```sh
sh tools/render.sh courts/federal-circuit/court-of-federal-claims/motion-brief samples/INPUT-oracle-memorandum.md
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

**Font: EB Garamond at 12 point.** RCFC 5.5(c)(2) sets only the minimum type size (12 point) and names no typeface; the whole rules PDF (as amended July 27, 2026) was searched and names none. Per `docs/FONTS.md`, a court that names no face keeps EB Garamond. The filed exemplar is set in Times New Roman, which the rules do not require. `fonts/liberation-serif/` (the Times New Roman substitute) is vendored, but using it would be a convention choice, not a rule requirement, so it is not applied. 12 point EB Garamond looks smaller than 12 point Times; the difference is visible in the overlay.

**Double spacing.** `body-leading = 0.9em` was chosen by eye for a double-spaced look at 12 point. The pitch was not measured against the exemplar.

**Email under the signature.** The exemplar's signature block gives telephone and fax but not the email; the email is on the cover only. RCFC 5.5(f) requires the email "directly below the signature line of every filing", so the template prints it there. This is a rule-driven deviation from the exemplar.

**Bid Protest caption.** RCFC 5.5(h) requires it in all filings. The exemplar has it.

**Certificate of service.** The exemplar's motion (Doc. 59, p. 3) includes one, with the RCFC 5.3 content. The template prints it at the end of the filing. There is no certificate of compliance.

**Heading numbering.** The author's own numbering in the exemplar is mixed (for example "1. INTRODUCTION" followed by "II."). The template numbers every level-1 section with a Roman numeral. This is a convention choice, not a rule. Tier 3 (one filer's style) is not chased.

**Page limit.** The memorandum in the exemplar runs 72 pages, which exceeds RCFC 5.4(b)(1) (40 pages, 50 for a cross-movant) unless leave was granted. The motion says it is filed "pursuant to the Court's Scheduling Order"; the leave order is not in the exemplar, and this box did not look it up. The template enforces the limit on our build, not the exemplar's.

## Exemplar and transcription

- The filing is text-based only on pp. 1-3 (the motion). The memorandum (pp. 4-75) and the proposed order (pp. 76-78) are scanned images with no text layer.
- The sample was transcribed from an OCR (tesseract 5.5.3, 300 dpi, `--psm 6`) of the scanned pages. The cover (p. 4) was checked against the image; the email address in the OCR was wrong and is corrected (craig.holman@arnoldporter.com). Other passages were not checked against the images one by one. Redacted passages are omitted. The sample is a visual comparison, not a certified copy.
- The overlay (`tools/overlay.sh`) pairs pages by extracted text, so a scanned exemplar gives no pairing without a text layer. An OCR text-layer copy was built from the same images and the native text of pp. 1-3 (`/work/artifacts/uscfc-motion-brief/oracle-18-1880C-textlayer.pdf`, 78 pages, outside the repo), and passed to the overlay as its third argument. The filed file in `exemplars/` is unchanged.

## Overlay

Pages paired by word overlap (the map is in `OVERLAY-oracle-memorandum.txt`):

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

All 13 rendered pages were rasterized at 60 dpi and viewed in montage (`pdftoppm -r 60`). Defects found and fixed:

1. Typed heading numbers in the sample ("A. A. The Single Award...") — numbers removed from the markdown; the template generates them.
2. Counsel names printed with literal asterisks ("*Of Counsel:*") — names now go through inline markdown.
3. Certificate recipient lines printed literal asterisks ("*Counsel for Defendant*") — now inline markdown.
4. The table of authorities heading and the certificate heading appeared in the table of contents — now unnumbered and outside the TOC, as in the exemplar.

After fixes 2-4 the re-render was checked by text extraction (pp. 1, 10, and the TOA heading); the montage images predate those fixes.

## Known gaps

- **The motion itself (Doc. 59, RCFC 7(b)).** The template renders the memorandum. The short motion paper, with its own caption, is not modeled. It is a separate document and would be a second sample.
- **The sample is an excerpt.** It covers the Introduction, Questions Presented, parts of the Statement of Facts (A-B), the jurisdiction section, part of Argument A, and the conclusion. The TOC and TOA list only what the excerpt contains. The exemplar's Argument (Parts V-VI), its Argument headings, and its full TOA are not reproduced.
- **Overlay pairing for scanned exemplar pages** depends on the OCR text-layer copy outside the repo. If that copy is regenerated, the overlay must be regenerated.
- **The page limit** is enforced on our render, but the sample is short, so the check is not exercised near the limit.
- **Font.** See Decisions: 12 point EB Garamond, kept because the rules name no face; Liberation Serif is vendored but not applied.
- **Single exemplar.** One filing from one filer. The brief asks for one exemplar per doc type; for tier-2 conventions the usual practice is two or three filers, which this box did not find (CourtListener's motion PDFs for uscfc are mostly opinions; docket pages and docket-entry API need auth).

## Search log

- CourtListener API v4, `type=rd`, `court=uscfc`, queries for "motion for judgment on the administrative record", "motion to dismiss", "motion for summary judgment": results are overwhelmingly opinions; no motion PDF with an available file other than the Oracle filing was found. Rate limit: 5 requests per minute.
- Direct RECAP storage probes for motion document numbers (Docs. 1, 54, 64, 65 across several dockets): 404.
- CourtListener docket pages and docket-entries API: 403 / authentication required.
- WebSearch: "Court of Federal Claims motion for judgment on the administrative record pdf" — returned the Oracle filing (washingtontechnology.com). Also returned opinions and the Land of Lincoln 16-744C response (a response, not a motion).
- Court rules: `cofc.uscourts.gov/rules` lists the current rules PDF (July 27, 2026); the first candidate URL on `uscfc.uscourts.gov` returned 404.

[Formbook index](../../../../README.md) | [Court README](../README.md)
