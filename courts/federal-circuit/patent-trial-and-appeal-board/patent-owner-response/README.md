# PTAB: patent owner response (IPR)

Doc type `patent-owner-response` of court `ptab`. Self-contained folder, like `../petition/`.

**Status: rendered and overlaid against one filed exemplar; tier 2 NOT finished (one filer only).** The tier-1 form (font, margins, spacing, length, certificates) is built from the rules and checked by eye on all 13 rendered pages. The tier-2 comparison needs a second filer's response and none was found (see `exemplars/SOURCE.md`, search record). Until then this doc type is not a pass on tier 2.

```sh
sh tools/render.sh courts/federal-circuit/patent-trial-and-appeal-board/patent-owner-response samples/INPUT-juniper-ipr.md   # -> samples/OUTPUT-juniper-ipr.pdf
sh tools/overlay.sh courts/federal-circuit/patent-trial-and-appeal-board/patent-owner-response juniper-ipr                    # -> samples/OVERLAY-juniper-ipr.pdf and .txt
```

| Item | Status |
|---|---|
| exemplar | yes: one filed response, Swarm Technology (patent owner), IPR2021-01445. Second filer: not found. |
| render | ok: `samples/OUTPUT-juniper-ipr.pdf`, 13 pages, Liberation Serif embedded, no typst warnings |
| overlay | ok: `samples/OVERLAY-juniper-ipr.pdf` and `.txt`, against the Swarm exemplar (passed explicitly) |
| pages reviewed | 13 (every page of the render viewed as PNG at 70 dpi) |
| typeface | face required: Times New Roman, 14-pt (§ 42.6(a)(2)(ii)) → vendored substitute: `Liberation Serif` (`fonts/liberation-serif`, metric-compatible, per `docs/FONTS.md`) → embedded: LiberationSerif only (`pdffonts`) |

## Layout

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-juniper-swarm-IPR2021-01445-patent-owner-response.pdf` | Filed response, Swarm Technology v. Juniper Networks (IPR2021-01445). 65 pages. Used for the sample and the overlay. |
| `exemplars/SOURCE.md` | URL, case, filer, date, fetch date, and the search record (including the second-filer search that found nothing). |
| `samples/INPUT-juniper-ipr.md` | Markdown transcription, verbatim from the exemplar: caption, introduction, the ’004 patent overview with footnotes, prosecution history, claim construction, level of skill, the Hall-Ellis section, conclusion, signature, and the word-count and service certificates. About 2,300 words of body. Not the whole response (see Gaps). |
| `typst/main.typ` | Entry point; reads the sample and its YAML frontmatter. |
| `typst/ptab-patent-owner-response.typ` | Template: `patent-owner-response(meta, body)`. The petition template with the response wording and the response word-limit citation. Every number traces to a rule (`PTAB-POR-…` IDs below). |

## Governing rules

Verified against the text of each section at Cornell LII on 2026-10-14 (https://www.law.cornell.edu/cfr/text/37/...). Full rule-level record is in the court-level `../rules.md`.

| ID | Requirement | Source (text verified) | Kind | Where in the template |
|---|---|---|---|---|
| PTAB-POR-FORM-001 | Page size 8½ × 11 in | 37 C.F.R. § 42.6(a)(1) | M | `set page(paper: "us-letter")` |
| PTAB-POR-FORM-002 | 14-point Times New Roman, proportional, normal spacing; footnotes and headers too | § 42.6(a)(2)(ii) | M | `font-family`, `type-size`; Liberation Serif stand-in (gap 1) |
| PTAB-POR-FORM-003 | Double spacing, except headings, TOC, TOA, indices, signature blocks, certificates, claim charts; block quotations 1½ spaced and indented from both margins | § 42.6(a)(2)(iii) | M | `double-leading`, `single-leading`, `quote-leading`; `show quote` |
| PTAB-POR-FORM-004 | Margins at least 1 inch on all sides | § 42.6(a)(2)(iv) | M | `page-margin` |
| PTAB-POR-FORM-005 | Black ink or equivalent dark, high-contrast image | § 42.6(a)(2)(i) | M | black text (default) |
| PTAB-POR-LEN-001 | Patent owner response word limit = the petition's: 14,000 words for an IPR | § 42.24(b)(2) (text verified: "The word counts for a patent owner response to petition are the same as the word counts for the petition") | M | `response-word-limit` = 14000; the build fails over the limit |
| PTAB-POR-FORM-008 | Certification of word count stating the number | § 42.24(d) | M | `certificate-of-word-count`; count supplied in the frontmatter (gap 2) |
| PTAB-POR-FORM-009 | Certificate of service with date, manner, and each person served | § 42.6(e)(4)(i), (iii) | M | `certificate-of-service`, cites § 42.6(e) only; the response is served on the petitioner |
| PTAB-POR-TIME-001 | Due date: the Board order sets it; if none does, three months from institution | § 42.120(b) | M | not generated: a timing check, for the filing calendar |
| PTAB-POR-SCOPE-001 | One response to the petition and/or decision on institution, filed as an opposition under the § 42.24 page limits | § 42.120(a) | M | content, not generated |
| PTAB-POR-CONV-001 | Section numbering I., A., 1.; centered capitals for level 1 | Swarm exemplar | C | `heading-number`, `show heading` |
| PTAB-POR-CONV-002 | Caption: "UNITED STATES PATENT AND TRADEMARK OFFICE / BEFORE THE PATENT TRIAL AND APPEAL BOARD", party caption, patent number and title, IPR number, title line | Swarm exemplar | C | `cover(meta)` |
| PTAB-POR-CONV-003 | Front matter in roman numerals; body from page 1; running header | Swarm exemplar (its header is "IPR2021-01445  Patent Owner's Response"; this template prints "Patent Owner Response, U.S. Patent No. …") | C | `patent-owner-response()` page setup. Header wording is OPEN (see review). |

Kind: M = mandated by a rule; C = convention (the source is named in the row).

Not verified: the PTAB Consolidated Trial Practice Guide and any standing order that adds to these rules.

## Markdown contract

Same as the petition (`../petition/README.md`, "Markdown contract"): YAML frontmatter, then the body. Frontmatter: `petitioner`, `patent-owner` (`{name, role}`), `patent-number`, `patent-title`, `case-number`, `title`, `word-count`, `date`, `signature` (`{signer, signer-name, reg-no, lines?}`), `service` (`{manner, recipients: [{name, lines}]}`). Body: `#` level 1, `##` level 2, `###` level 3; footnotes `[^key]` with definitions placed before the conclusion heading (the template keeps the last body paragraph with the signature block, so footnote definitions must not come last).

## Review (Gate 2 equivalent, recorded)

Rendered `samples/OUTPUT-juniper-ipr.pdf` (13 pages) and viewed every page as PNG (70 dpi): cover (p.1), contents (i), body pages 1–9, word-count certificate, certificate of service. Checked: page size, margins, double spacing, block paragraph indents, heading styles and numbering, footnotes at 14 pt, running header, signature block placement, the conclusion kept with its signature block. No layout defect found in tier 1.

Tier-2 findings, compared against the Swarm exemplar only (one filer, so none can be called a convention; all are OPEN, not judged):

- Body pages 1, 7 and 8 (claim-element lists in the introduction and conclusion): rendered as bullets; the exemplar uses indented roman numerals with no bullet. OPEN.
- Contents (page i): level-1 entries are in title case ("Introduction"); the exemplar's contents are in capitals. OPEN.
- Running header (pages 1–9): "Patent Owner Response, U.S. Patent No. 9,852,004"; the exemplar's is "IPR2021-01445  Patent Owner's Response". OPEN.
- No table of authorities and no exhibit list: the exemplar has both (pp. ii, after the contents). The template generates only the contents. OPEN.
- Cover (page 1): caption layout follows the exemplar's general order; the exemplar's "Case: IPR2021-01445" block is printed as a single line here. ACCEPTED, one filer.
- Certificate of word count (page 12): the template prints "CERTIFICATION UNDER 37 C.F.R. § 42.24" (count and signature); the exemplar prints "CERTIFICATE OF COMPLIANCE" with a typeface statement under § 42.6. The typeface statement is not in the template. OPEN (a clerk expects both certificates; § 42.6 typeface statement is not mandated text).

## Overlay

`samples/OVERLAY-juniper-ipr.pdf` prints our render in red over the Swarm exemplar in blue (black where both agree). Pages are paired by shared words; the pairing is in `samples/OVERLAY-juniper-ipr.txt`. Our cover (p.1) pairs with filed p.1 and our contents (p.2) with filed p.2. Our body pages 1–7 (render pp.3–9) pair with filed pp.6–13; render p.3 pairs at 100% word overlap. Render pp.10–13 (the conclusion, word-count certificate and service certificate) pair with filed pp.63–65. The filed response's argument sections (its sections V through IX, filed pp.18–57) are not in the sample, so the overlay has no pairing for them. The overlay is a diagnostic, not a score.

## Gaps

1. **Font**: the rule names Times New Roman, which is not vendored. The template uses Liberation Serif (`fonts/liberation-serif`, OFL, metric-compatible with Times New Roman) as the vendored stand-in, following the repo's rule for Times-named forms. Embedded names read LiberationSerif, not TimesNewRoman. Pagination matches Times New Roman's metrics, but this is not the named face; the PDF is not claimed to be TNR.
2. **Word count** is author-supplied (kind A). The frontmatter carries 11,176, which is the **exemplar's certified count**, not a count of the transcribed excerpt. The template only checks the number is at most 14,000.
3. **Transcription is partial**: the sample covers the introduction through the conclusion, omitting the ’004 figure, most of the argument sections (V through VIII), and the exhibit list. The exemplar runs 65 pages. Gate 0 (every word of the sample in the PDF) is not built.
4. **Tier 2 cannot be finished**: one filer. CLAUDE.md and EVAL-LOOP require two or three filers. The second-filer search is recorded in `exemplars/SOURCE.md`.
5. **No mechanical checks**: no `checks.yaml` or `tools/check.sh` run for this folder. Gate 1 is not built.
6. **Latex and docx engines**: not in this brief's scope.
7. **Source provenance**: the exemplar is the copy republished on ptablitigationblog.com, not the PTAB E2E record.
