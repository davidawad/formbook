# PTAB: petition for inter partes review

Doc type `petition` of court `ptab` (Patent Trial and Appeal Board, `courts/federal-circuit/patent-trial-and-appeal-board/`). Self-contained: this folder holds the rules, exemplars, sample, template and review for this doc type only.

**Status: rendered (render=ok), overlaid (overlay=ok), all 14 pages reviewed. Tier 2 is still open.** The rules require 14-point Times New Roman (37 C.F.R. § 42.6(a)(2)(ii)). Times New Roman is not vendored; the template uses Liberation Serif, the vendored metric-compatible stand-in (gap 1). Both filed exemplars are present and their source records are in `exemplars/SOURCE.md`. Tier 2 compares against the two exemplars; the open items are in the review below.

```sh
sh tools/render.sh courts/federal-circuit/patent-trial-and-appeal-board/petition samples/INPUT-salesforce-ipr.md   # -> samples/OUTPUT-salesforce-ipr.pdf
sh tools/overlay.sh courts/federal-circuit/patent-trial-and-appeal-board/petition salesforce-ipr \
  courts/federal-circuit/patent-trial-and-appeal-board/petition/exemplars/FILED-EXAMPLE-salesforce-wsou-IPR2022-00154-petition.pdf
# -> samples/OVERLAY-salesforce-ipr.pdf and .txt
```

The overlay's default exemplar is the first `exemplars/*.pdf` in name order, which is the Huawei copy. The sample is transcribed from the Salesforce copy, so pass that exemplar as the third argument.

The tools name outputs `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (the court-wide convention in `docs/EVAL-LOOP.md`), not `<id>.pdf`; this folder follows the tools.

| Item | Status |
|---|---|
| exemplar | yes: two filed petitions from two filers (Salesforce, Huawei) |
| render | ok: `samples/OUTPUT-salesforce-ipr.pdf`, 14 pages, Liberation Serif embedded, no typst warnings |
| overlay | ok: `samples/OVERLAY-salesforce-ipr.pdf` and `.txt`, against the Salesforce exemplar |
| pages reviewed | 14 (every page of the render viewed as PNG at 70 dpi) |

## Layout

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-salesforce-wsou-IPR2022-00154-petition.pdf` | Filed petition, Salesforce v. WSOU (IPR2022-00154). Used for the sample and the overlay. |
| `exemplars/FILED-EXAMPLE-huawei-wsou-IPR2021-00689-petition.pdf` | Filed petition, Huawei v. WSOU (IPR2021-00689). Second filer, for tier-2 comparison. |
| `exemplars/SOURCE.md` | URL, case, filer, date, date fetched, search record for both. |
| `samples/INPUT-salesforce-ipr.md` | Markdown transcription of the Salesforce petition: cover data, introduction, mandatory notices, requirements, relief, overview, POSITA, claim construction, prior art, conclusion. About 2,100 words. |
| `typst/main.typ` | Entry point; reads the sample and its YAML frontmatter. |
| `typst/ptab-petition.typ` | Template: `petition(meta, body)`. Content-agnostic; every number traces to a rule (`PTAB-PET-…` IDs below). |

## Governing rules

Verified against the text of each section at Cornell LII on 2026-10-14 (https://www.law.cornell.edu/cfr/text/37/...). The rule text is primary; the petition is the form.

| ID | Requirement | Source (text verified) | Kind | Where in the template |
|---|---|---|---|---|
| PTAB-PET-FORM-001 | Page size 8½ × 11 in | 37 C.F.R. § 42.6(a)(1), last amended 2015-05-19 (80 FR 28565) | M | `set page(paper: "us-letter")` |
| PTAB-PET-FORM-002 | 14-point Times New Roman, proportional, normal spacing; applies to footnotes and headers too (no footnote exception in § 42.6) | § 42.6(a)(2)(ii) | M | `font-family`, `type-size`; Liberation Serif stand-in (gap 1) |
| PTAB-PET-FORM-003 | Double spacing, except headings, TOC, TOA, indices, signature blocks, certificates, claim charts; block quotations may be 1½ spaced and indented from both margins | § 42.6(a)(2)(iii) | M | `double-leading`, `single-leading`, `quote-leading`; `show quote` |
| PTAB-PET-FORM-004 | Margins at least 1 inch (2.5 cm) on all sides | § 42.6(a)(2)(iv) | M | `page-margin` |
| PTAB-PET-FORM-005 | Black ink or equivalent dark, high-contrast image | § 42.6(a)(2)(i) | M | black text (default) |
| PTAB-PET-LEN-001 | Petition for IPR: 14,000 words; the table of contents, table of authorities, mandatory notices, certificate of service or word count, and appendix of exhibits or claim listing are excluded | § 42.24(a)(1)(i) and the exclusion in § 42.24(a) (the 2020 amendment is 85 FR 79128, Dec. 9, 2020) | M | `petition-word-limit`: the build fails if the certified count is over the limit |
| PTAB-PET-FORM-008 | Certification of word count stating the number of words | § 42.24(d) | M | `certificate-of-word-count`; the count is supplied in the frontmatter (gap 2) |
| PTAB-PET-FORM-009 | Certificate of service at the end of each document, stating date, manner and each person served (name and address) | § 42.6(e)(4)(i), (iii) | M | `certificate-of-service`, from frontmatter `service` |
| PTAB-PET-CONT-001 | Mandatory notices: real party in interest; related matters; lead and back-up counsel and service information | § 42.8(a)(1), (b)(1)–(4) (headings verified) | M | section content in the sample (not generated) |
| PTAB-PET-CONT-002 | Power of attorney accompanies the petition; fees authorized | § 42.10(b); § 42.15(a) (cited in the exemplar) | M | content in the sample (not generated) |
| PTAB-PET-CONT-003 | Statement of standing (not barred or estopped; patent available for IPR) and statement of precise relief for each claim, with where each element is found in the prior art | § 42.104(a), (b) (partly verified; full text of (b) exceeds the quote limit) | M | content in the sample (not generated) |
| PTAB-PET-CONV-001 | Section numbering I., A., 1.; centered capitals for level 1 | Salesforce exemplar | C | `heading-number`, `show heading` |
| PTAB-PET-CONV-002 | Cover: "UNITED STATES PATENT AND TRADEMARK OFFICE / BEFORE THE PATENT TRIAL AND APPEAL BOARD", party caption, patent number and title, IPR number, title line | Salesforce exemplar (the Huawei copy opens with an ex parte "In re Patent of" block) | C | `cover(meta)` |
| PTAB-PET-CONV-003 | Front matter in roman numerals; body from page 1; running header naming the patent | Salesforce exemplar | C | `petition()` page setup |

Kind: M = mandated by a rule; C = convention (the source is named in the row); A = author responsibility (not checked by the template).

Not in this folder and not verified: the Board's Consolidated Trial Practice Guide and any PTAB standing order that adds to these rules. If one applies, record it here before relying on it.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

Frontmatter (all required unless noted):

- `petitioner`, `patent-owner`: `{name, role}`. The name is printed on the cover; inline markdown allowed (italic).
- `patent-number`, `patent-title`, `case-number`: cover lines. `title`: the cover's bold title line.
- `word-count`: integer, the count the author certifies (see Gaps: the template does not count words).
- `date`: printed as "Dated:" above the signature block and on each certificate.
- `signature`: `{signer, signer-name, reg-no, lines?}`. Prints as `/s/ signer` and `signer-name (Reg. No. …)`.
- `service`: `{manner, recipients: [{name, lines}]}`. `manner` is the service method ("FedEx"); `recipients` is printed under the certificate of service.

Body: `# Heading` is a level-1 section (numbered I., II. …, centered, capitals). `## ` is level 2 (A., B., …), `### ` is level 3 (1., 2., …). Numbers are generated; do not type them. Block quotations (`>`) are 1½ spaced and indented. Footnotes (`[^key]`) are 14-point. Escape a leading number or marker that is meant as text (`1\. A method …`), as in the sample's claim quotation. The last paragraph of the body is kept on the same page as the signature block.

## Review (Gate 2 equivalent, recorded)

Rendered `samples/OUTPUT-salesforce-ipr.pdf` (14 pages: cover, contents i, body 1–10, word-count certificate, certificate of service) and viewed every page as PNG (70 dpi). Checked: page size, margins, double spacing, indents of paragraphs and of the claim quotation, heading styles and numbering, the bullet counsel list, running header, signature block, the conclusion kept with its signature block, and both certificates. No tier-1 layout defect found.

Calibration (unchanged from the earlier draft): baseline pitch with Liberation Serif at 14 pt is 9.17 pt + `par.leading`; double spacing is `double-leading` = 1.64 em (about 32 pt pitch), which the render measures.

Tier-2 findings, compared against the two filed petitions (both are the same doc type from two filers; a choice seen in both is a convention, one seen in one is that filer's style):

- Contents (page i): entries are in title case ("Introduction"), while the body's level-1 headings are capitals. The earlier draft's review recorded that the exemplars' contents use capitals; this render was not re-compared against the exemplars' contents pages. OPEN.
- No table of authorities. Both exemplars carry front matter beyond the contents (Salesforce: exhibit list and list of challenged claims; Huawei: contents only, with a caption block for the ex parte form). The template generates only the contents. OPEN.
- Counsel details (body pages 2–3): a bullet list, not the exemplar's table. ACCEPTED: the form permits either; a clerk reads both.
- Cover (page 1): follows the Salesforce layout; the Huawei copy has an ex parte caption block instead. ACCEPTED: the Huawei layout is the exception (no PTAB caption line), so Salesforce's is the convention here.

## Overlay

`samples/OVERLAY-salesforce-ipr.pdf` prints our render in red over the Salesforce exemplar in blue (black where both agree). Pages are paired by shared words; the pairing is in `samples/OVERLAY-salesforce-ipr.txt`. Our pages 1–12 pair with filed pp.2–26, and our pp.13–14 pair with filed pp.71–72 (the exemplar's certificates). Our cover (p.1) pairs with filed p.2, the exemplar's PTAB cover page; filed p.1 is the district-court "EXHIBIT A" slip sheet, so it has no counterpart. Word overlap is 29–93% per page; the low pages are the counsel list and the prior-art pages, where the transcription differs from the exemplar's layout. The overlay is a diagnostic, not a score.

## Gaps

1. **Font**: the rule names Times New Roman, which is not vendored. The template uses Liberation Serif (`fonts/liberation-serif`, OFL, metric-compatible with Times New Roman) as the vendored stand-in, following the repo's rule for Times-named forms. Embedded names read LiberationSerif, not TimesNewRoman. Pagination matches Times New Roman's metrics, but this is not the named face; the PDF is not claimed to be TNR.
2. **Word count** is author-supplied (kind A). The template only checks the number is at most 14,000. The sample's frontmatter carries 10,543, which is the **Salesforce petition's** certified count, not a count of the transcribed excerpt, so the certificate on page 11 states a count that does not describe the sample. Any real filing needs the count of its own text.
3. **Transcription is partial**: the sample covers the introduction through the conclusion, with the notices and two prior-art sections; the exemplar runs 73 pages. The sample is for layout and depth, not a full copy. Gate 0 (every word of the sample in the PDF) is not built for this doc type.
4. **No mechanical checks yet**: no `checks.yaml` or `tools/check.sh` run for this folder. Gate 1 (per-requirement checks) is not built.
5. **Tables in the exemplars** (counsel, relief-requested) are lists in the sample, and the contents is typst's own outline.
6. **Not in scope of this brief**: latex and docx engines for this doc type.
