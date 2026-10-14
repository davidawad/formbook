# PTAB: petition for inter partes review

Doc type `petition` of court `ptab` (Patent Trial and Appeal Board, `courts/federal-circuit/patent-trial-and-appeal-board/`). Self-contained: this folder holds the rules, exemplars, sample, template and review for this doc type only.

**Status: template built from the rules; deliverable PDF NOT rendered (render=fail).** The rules require 14-point Times New Roman (37 C.F.R. § 42.6(a)(2)(ii)). The vendored fonts (`fonts/`) contain EB Garamond only, so `tools/render.sh` stops with `warning: unknown font family: times new roman` and exits 1 (the warning gate working as designed). `samples/` therefore holds the markdown and no committed PDF. Adding a Times-metric font (Liberation Serif is OFL and metric-compatible with Times New Roman) to `fonts/` is a shared change outside this box's scope; once it is there, the render and overlay commands below run unchanged.

```sh
sh tools/render.sh courts/federal-circuit/patent-trial-and-appeal-board/petition samples/INPUT-salesforce-ipr.md   # -> samples/OUTPUT-salesforce-ipr.pdf
sh tools/overlay.sh courts/federal-circuit/patent-trial-and-appeal-board/petition salesforce-ipr            # -> samples/OVERLAY-salesforce-ipr.pdf and .txt
```

The tools name outputs `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (the court-wide convention in `docs/EVAL-LOOP.md`), not `<id>.pdf`; this folder follows the tools.

## Layout

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-salesforce-wsou-IPR2022-00154-petition.pdf` | Filed petition, Salesforce v. WSOU (IPR2022-00154). Used for the sample and the overlay. |
| `exemplars/FILED-EXAMPLE-huawei-wsou-IPR2021-00689-petition.pdf` | Filed petition, Huawei v. WSOU (IPR2021-00689). Second filer, for tier-2 comparison. |
| `exemplars/SOURCE.md` | URL, case, filer, date, date fetched, search record for both. |
| `samples/INPUT-salesforce-ipr.md` | Markdown transcription of the Salesforce petition: cover data, introduction, mandatory notices, requirements, relief, overview, POSITA, claim construction, prior art, conclusion. About 2,300 words. |
| `typst/main.typ` | Entry point; reads the sample and its YAML frontmatter. |
| `typst/ptab-petition.typ` | Template: `petition(meta, body)`. Content-agnostic; every number traces to a rule (`PTAB-PET-…` IDs below). |

## Governing rules

Verified against the text of each section at Cornell LII on 2026-10-14 (https://www.law.cornell.edu/cfr/text/37/...). The rule text is primary; the petition is the form.

| ID | Requirement | Source (text verified) | Kind | Where in the template |
|---|---|---|---|---|
| PTAB-PET-FORM-001 | Page size 8½ × 11 in | 37 C.F.R. § 42.6(a)(1), last amended 2015-05-19 (80 FR 28565) | M | `set page(paper: "us-letter")` |
| PTAB-PET-FORM-002 | 14-point Times New Roman, proportional, normal spacing; applies to footnotes and headers too (no footnote exception in § 42.6) | § 42.6(a)(2)(ii) | M | `font-family`, `type-size`; **font not vendored, see Status** |
| PTAB-PET-FORM-003 | Double spacing, except headings, TOC, TOA, indices, signature blocks, certificates, claim charts; block quotations may be 1½ spaced and indented from both margins | § 42.6(a)(2)(iii) | M | `double-leading`, `single-leading`, `quote-leading`; `show quote` |
| PTAB-PET-FORM-004 | Margins at least 1 inch (2.5 cm) on all sides | § 42.6(a)(2)(iv) | M | `page-margin` |
| PTAB-PET-FORM-005 | Black ink or equivalent dark, high-contrast image | § 42.6(a)(2)(i) | M | black text (default) |
| PTAB-PET-LEN-001 | Petition for IPR: 14,000 words; the table of contents, table of authorities, mandatory notices, certificate of service or word count, and appendix of exhibits or claim listing are excluded | § 42.24(a)(1)(i) and the exclusion in § 42.24(a) (the 2020 amendment is 85 FR 79128, Dec. 9, 2020) | M | `petition-word-limit`: the build fails if the certified count is over the limit |
| PTAB-PET-FORM-008 | Certification of word count stating the number of words | § 42.24(d) | M | `certificate-of-word-count`; the count is supplied in the frontmatter (see Gaps) |
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

The deliverable PDF does not exist (render failed), so the review below is of a **non-deliverable draft**: the same template with `"Times New Roman"` replaced by Liberation Serif, a font metric-compatible with Times New Roman and used here only for layout, built in a scratch folder outside the repo (not `tools/render.sh`, not committed). The draft is 14 pages (cover, contents i, body 1–12). All 14 pages were rendered at 60 dpi and viewed. The overlay was not run: there is no committed OUTPUT PDF.

Spacing calibration. Measured with Liberation Serif at 14 pt in typst 0.15: baseline pitch = 9.17 pt + `par.leading`. Double spacing for Times New Roman (line box 1.15 em, so 2 × 16.1 pt) gives 32.1 pt, so `double-leading` = 1.64 em (23 pt). Single = 0.5 em (16.2 pt pitch), 1½ = 1.07 em (24 pt). The draft body measures a 32.1 pt pitch.

Defects found in the review and fixed in the template:

1. The contents block's `set par(leading: 0.4em, …)` leaked into the body: the whole body was single-spaced and unindented. Fixed by scoping the contents in `{ }`.
2. Heading text used typst's default heading size (larger than 14 pt). Fixed: `set text(size: type-size)` in each heading show rule.
3. Bullet items collided with the next item and with the line before a list (a zero gap leaves no room for the last line's leading). Fixed: list item and block spacing set to `double-leading`.
4. The conclusion's signature block fell alone onto its own page. Fixed: the last body paragraph is kept with the signature in one unbreakable block.
5. The word count printed as "10543". Fixed: thousands separator.

Remaining, by page of the draft (all tier 2, OPEN unless marked):

- Contents entries are in title case ("Introduction"); the exemplars use capitals in the contents. OPEN (tier 2).
- No table of authorities. The Salesforce exemplar has a contents, a list of exhibits and a list of challenged claims in its front matter; the template generates only the contents. OPEN (tier 2, convention C).
- Counsel details are a bullet list, not the exemplar's table. Tier 2, ACCEPTED for now: the form permits either; a clerk reads both.
- Pages 3–4 (counsel list) and page 10 (signature): the list and signature layout is correct in the draft; this depends on the final font's metrics and must be re-checked after rendering in Times New Roman.
- Cover: compared against the Salesforce exemplar only; its layout is followed. ACCEPTED (tier 3 difference, one filer).

## Gaps

- **Font**: not vendored (see Status). Until the Times-metric font is in `fonts/`, the petition cannot be rendered under `tools/render.sh`, and nothing in this folder claims a PDF exists.
- **Word count** is author-supplied (kind A). The template only checks the number is at most 14,000. The sample's frontmatter carries 10,543, which is the **Salesforce petition's** certified count, not a count of the transcribed excerpt. Any real filing needs the count of its own text.
- **Transcription is partial**: the sample covers the introduction through the conclusion, with the notices and two prior-art sections; the exemplar runs 73 pages. The sample is for layout and depth, not a full copy. Gate 0 (every word of the sample in the PDF) is not built for this doc type.
- **No mechanical checks yet**: no `checks.yaml` or `tools/check.sh` run for this folder. Gate 1 (per-requirement checks) is not built.
- **Tables in the exemplars** (counsel, relief-requested) are lists in the sample, and the contents is typst's own outline.
- **Overlay not run** (no committed OUTPUT PDF); the page map cannot be produced yet.
- **Not in scope of this brief**: latex and docx engines for this doc type.
