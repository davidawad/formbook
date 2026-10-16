# United States Court of Federal Claims: complaint

Doc-type folder for the Court of Federal Claims (`uscfc`), complaint. Self-contained: `exemplars/`, `samples/`, `typst/`, this README.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: one filed complaint (Design Build, LLC, No. 1:26-cv-01361, filed 2026-09-15). See `exemplars/SOURCE.md`. |
| Typeface | Rule names no face (RCFC 5.5(c)(2): text and footnotes no smaller than 12 point). Keeps EB Garamond; no vendored substitute applied. Visual-only comparison to the exemplar's Times New Roman, see Known gaps 1. |
| Render | ok: `sh tools/render.sh courts/federal-circuit/court-of-federal-claims/complaint samples/INPUT-design-build-llc-26-1361.md`; exit 0, no typst warnings, EB Garamond only (`pdffonts`). 13 pages (re-rendered 2026-10-16). |
| Overlay | ok: `sh tools/overlay.sh courts/federal-circuit/court-of-federal-claims/complaint design-build-llc-26-1361`; exit 0, wrote `OVERLAY-…pdf` and `OVERLAY-….txt`. The exemplar PDF was restored from the URL in `exemplars/SOURCE.md` and matches its SHA-256. |
| Pages reviewed | 13 of 13. Every page of the final render rasterized at 60 dpi (`pdftoppm -r 60`) and looked at, 2026-10-16 (earlier: 50 dpi, 2026-10-14). |
| Tier 2 vs. a second filer | not done (one exemplar only). |

## Governing rules

Source: Rules of the United States Court of Federal Claims, "As amended through July 27, 2026", https://www.uscfc.uscourts.gov/sites/cfc/files/Rules%2010.08.26.pdf (fetched 2026-10-14; read from the PDF, pages 16, 21–25, 29–30, 33–34). The rules are the court's own; no local form is involved.

| ID | Rule | Requirement | Where in the template |
|---|---|---|---|
| CFC-FORM-001 | RCFC 5.5(c)(1)(A) | 8½ × 11-inch paper | `page(paper: "us-letter")` |
| CFC-FORM-002 | RCFC 5.5(c)(2) | Text and footnotes no smaller than 12 point | `type-size = 12pt`; footnote entries set to `type-size` |
| CFC-FORM-003 | RCFC 5.5(c)(3) | Margins not less than 1 inch on each side | `page-margin = 1in` |
| CFC-FORM-004 | RCFC 5.5(c)(4) | Text double spaced; quoted and indented material and footnotes may be single spaced | body leading = pitch 2.3 em (2 × 1.15 em) less the face's 0.65 em line box; quotes and footnotes single |
| CFC-FORM-005 | RCFC 5.5(c)(6) | Every page numbered, centred at the bottom | `numbering: "1"`, `number-align: center + bottom` |
| CFC-FORM-006 | RCFC 5.5(c)(5) | Binding that does not obscure text | not a template property (paper filing) |
| CFC-CAP-001 | RCFC 10(a) | Caption with the court's name, a title, a file number, and the RCFC 7(a) designation | `caption()`: court name, `COMPLAINT`, file number (blank for the clerk unless given), "Plaintiff," / "Defendant." |
| CFC-CAP-002 | RCFC 10(a) | The complaint's title names all parties | caption shows each side's names from frontmatter |
| CFC-CAP-003 | RCFC 5.5(h) | "Bid Protest" directly below the court name in a bid protest case | `bid_protest: true` prints it (default off) |
| CFC-CAP-004 | RCFC 5.5(g) | Judge's name not required in a complaint (required in later filings) | "Judge ____" left blank, a convention the exemplar follows; not a rule requirement |
| CFC-BODY-001 | RCFC 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances | author supplies the numbers (escaped `1\.` in the markdown so they stay the author's) |
| CFC-BODY-002 | RCFC 8(a)(1)–(3) | Short and plain statement of the jurisdictional grounds, of the claim, and a demand for relief | content, not template; the sample has all three |
| CFC-BODY-003 | RCFC 9(p) | A claim already litigated elsewhere must state the effect of the prior suit on jurisdiction | content, not template; not in the sample (the exemplar has none) |
| CFC-SIG-001 | RCFC 5.5(d)(1)(A) | Original signature on the paper complaint; electronic filing under Appendix E | signature block prints `/s/` plus name; the paper original is the filer's job |
| CFC-SIG-002 | RCFC 5.5(e) | Date the paper is signed, on the signature page | `date` frontmatter, printed beside the signature |
| CFC-SIG-003 | RCFC 5.5(f) | E-mail address and telephone number of the attorney of record directly below the signature line | `signature.phone`, `signature.email` |
| CFC-SRV-001 | RCFC 5(d)(1)(B) (2026 note) | Certificate of service filed with the underlying submission | optional `certificate_of_service: true` prints the certificate (exemplar has one) |
| CFC-PRIV-001 | RCFC 5.2(a) | Redact SSN, TIN and birth date to last four digits / year; minors by initials; financial accounts to last four digits | the sample contains none of those (checked by reading the text); the template cannot check content |
| CFC-SEP-001 | RCFC 7.1(a)–(b) | A nongovernmental corporate party files a disclosure statement with its first filing | separate filing, not part of the complaint; not generated |
| CFC-SEP-002 | RCFC 5.5(d)(1)(A)(ii), Appendix of Forms, Form 2 | Completed civil cover sheet with the paper complaint | separate filing; not generated |

Not used (and why): RCFC 5.5(c)(1)(C) (copy quality) and RCFC 5.5(b) (duplication) are the filer's production issue; RCFC 9(m) (tax refund) is not a content requirement of this sample; RCFC 5.4 word limits apply to briefs, not complaints, so no certificate of compliance is generated.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `court` | yes | court name line (RCFC 10(a)) |
| `caption` | yes | list of sides; each `names` (one centred line each) and `designation` (for example `Plaintiff,`) |
| `title` | yes | title under the caption, printed in capitals |
| `file_number` | no | file number at the right of the caption; blank line for the clerk when absent |
| `bid_protest` | no (default false) | prints "Bid Protest" under the court name (RCFC 5.5(h)) |
| `date` | yes | date beside the signature and in the certificate |
| `signature` | yes | `signer`, `lines` (italic lines under the name), `phone`, `email` |
| `certificate_of_service` | no (default false) | prints the certificate of service after the signature |

Body: `## Heading` prints as a centred bold capital section heading; `### Heading` as a bold left sub-heading. Headings are never numbered by the template. Paragraph numbers are typed by the author and escaped (`1\.`), because a markdown ordered list would renumber across headings. Lettered prayer items use `- a. …` (list markers are suppressed). Footnotes use `[^key]`. Smart punctuation is on. Case names are italicised by the author (`*United States v. Spearin*`). Non-breaking spaces in citations (`§`, `U.S.C.`, `FAR 52`) keep numbers and citations on one line.

## What the overlay shows

`OVERLAY-design-build-llc-26-1361.pdf`: red is our render only; blue is the filed exemplar only; black is where both agree. `OVERLAY-design-build-llc-26-1361.txt` is the page map: each of our pages is paired with the exemplar page sharing the most words.

The map pairs by text, so it is approximate. Our pages 1–6 pair with exemplar pages 1–6 (word overlap 69–77%). Our page 7 pairs with exemplar page 10 (33%): it holds the transcription note for the omitted ¶¶ 30–40 and 43–48, so the exemplar pages 7–9 have no counterpart. Our pages 8–13 pair with exemplar pages 12, 13, 14, 15, 16 and 18 (41–79%; map regenerated 2026-10-16, same pairing). Word overlap is partial by design, because the sample is a partial transcription. The check that matters is the caption on page 1 and the signature and certificate on pages 12–13.

## Samples

- `samples/INPUT-design-build-llc-26-1361.md`: transcription of the exemplar (caption, Nature of the Action, Parties, Jurisdiction and Venue, The Contract, factual background ¶¶ 15–29 and 41–42 in full, COFDs ¶¶ 49–56, Count I ¶¶ 57–65, prayer, signature, certificate of service). Paragraphs 30–40 and 43–48 are not transcribed, and the sample says so in a bracketed note. The exemplar is 18 pages; the sample renders to 13.
- `samples/OUTPUT-design-build-llc-26-1361.pdf`: render (13 pages). Named `OUTPUT-` and `OVERLAY-` because `tools/render.sh` and `tools/overlay.sh` use those names by default.

## Known gaps

1. **Typeface.** RCFC 5.5(c)(2) sets only the minimum type size (12 point) and names no face; a search of the whole rules PDF (as amended July 27, 2026) finds no typeface named. Per `docs/FONTS.md` the template therefore keeps EB Garamond at 12 point. The exemplar is set in Times New Roman, which the rules do not require. `fonts/liberation-serif/` (Liberation Serif, the Times New Roman substitute) is vendored, but applying it here would be a convention choice, not a rule requirement. EB Garamond has a smaller x-height than Times, so the text looks slightly smaller than the exemplar at the same point size; the overlay shows this.
2. **One exemplar.** Tier 2 (conventions a clerk expects) is judged against two or three filers. Only Design Build, LLC is in hand. A second complaint from another filer (for example one of the individual plaintiffs in the CourtListener results) is needed before tier 2 can be called done.
3. **Partial transcription.** The sample omits ¶¶ 30–40 and 43–48 of the exemplar.
4. **Not generated, by design:** the CM/ECF header line (`Case 1:26-cv-… Document 1 Filed … Page x of y`), the receipt-number stamp, the cover sheet (Form 2), and any RCFC 7.1 disclosure statement. These are court-system or separate-filing items.
5. **Caption.** The exemplar prints a "26-1361 C" file number and a blank judge line. This template prints the file number only when the sample supplies one, and always prints a blank judge line.
6. **Sealed or redacted filings** (RCFC 5.2, 9(m)) are the filer's job; the template has no sealed-filing mode.

## Engines

The docx engine is `docx/` (`make-reference.sh` builds `reference.docx`; `uscfc-complaint.lua` adds the caption, the signature block, the certificate and the prayer-list indents). Render: `sh tools/render.sh --engine docx courts/federal-circuit/court-of-federal-claims/complaint samples/INPUT-design-build-llc-26-1361.md` writes `samples/OUTPUT-design-build-llc-26-1361.docx` and its LibreOffice PDF (LibreOffice 26.8.1; on the render box `fonts/eb-garamond` was linked into fontconfig, see docs/DOCX.md).

| Matches the typst render | Differs from it |
|---|---|
| EB Garamond 12 pt throughout; footnotes 12 pt single-spaced; block quotes single-spaced (RCFC 5.5(c)(2), (c)(4)) | Pages: the docx runs 14 pages, the typst render 13. Each page holds the same 22 double-spaced lines (27.6 pt pitch, measured on both), but LibreOffice places exact-spaced lines about 14 pt lower and the heading and caption spacing is set by eye, so the text drifts. |
| Letter, 1-inch margins (RCFC 5.5(c)(1)(A), (c)(3)) | The signature block is alone on page 13 in the docx (kept whole, as typst keeps it); typst fits it under the prayer on page 12. |
| Arabic page number at bottom centre on every page, the caption page included (RCFC 5.5(c)(6)) | Heading spacing is approximate (the typst gap between a level-2 and a level-3 heading is larger than the docx gap). |
| Caption: court name, optional BID PROTEST line, parties with designations, file number or blank line, judge line (RCFC 10(a), 5.5(g)-(h)) | Word may paginate slightly differently from LibreOffice (docs/DOCX.md); the page numbers above are LibreOffice's. |
| Centred bold capital level-2 headings; bold left level-3 headings; prayer items a., i. at the typst indents | The auto-numbered prayer letters of the sample are typed text, as in typst. |
| Signature block: Dated, Respectfully submitted, `/s/`, name, contact lines (RCFC 5.5(d)-(f)); certificate of service on its own page | |

**docx BLOCKED:** `tools/check.sh <court> --engine docx` cannot run for this court yet: the court root has no `court.json`, `checks.yaml` or `rules.md`, so Gates 1 and 2 have nothing to check against. This is a court-level gap, not a docx check failure, and it is not fixed in this folder. The gates themselves were not run. Pages reviewed: all 14 pages of the docx PDF, rasterized at 60 dpi and viewed, 2026-10-15.

## Verification pass 2026-10-16 (fb-595.26.14)

- Rendered: `sh tools/render.sh … samples/INPUT-design-build-llc-26-1361.md`, exit 0, no typst warnings, EB Garamond only. 13 pages, as before (the committed PDF was not stale in page count).
- Viewed: all 13 pages at 60 dpi, before and after the fixes; exemplar pages 1, 17 and 18 at 50 dpi; all 13 overlay pages.
- Overlay: `sh tools/overlay.sh … design-build-llc-26-1361` rerun, exit 0; same page pairing as above. It shows our caption sits slightly lower, our lines drift against the exemplar's down each page (different face and leading), and the exemplar's caption names are bold (tier 3).
- Fixed:
  1. Section (`##`) headings printed at Typst's default heading size (about 14 pt), larger than the 12 pt title and the exemplar's headings. Both heading levels are now set at `type-size`.
  2. The certificate of service text was single spaced. RCFC 5.5(c)(4) double-spaces text and lets only quoted material and footnotes be single spaced, and the exemplar double-spaces it. It now uses the body leading.
  3. The certificate's `/s/` line was right-aligned, with its rule running left of the name. It now uses the same right-hand column as the complaint's signature block.
- Gaps that remain: Known gaps 1–6 above. The docx was not re-rendered in this pass (no LibreOffice on the box), so it does not have fixes 1–3. The latex engine has no folder for this doc type.

## Build and check (from the repo root)

```sh
sh tools/render.sh courts/federal-circuit/court-of-federal-claims/complaint samples/INPUT-design-build-llc-26-1361.md
sh tools/overlay.sh courts/federal-circuit/court-of-federal-claims/complaint design-build-llc-26-1361
```

Typst is invoked by `tools/render.sh` with `--root <doctype-dir> --font-path fonts --ignore-system-fonts --package-cache-path vendor/typst-packages`. Any warning fails the build.

[Court index](../README.md)
