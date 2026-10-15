# New York Court of Appeals: answering brief (brief for respondent)

Status: **BLOCKED: no exemplar.** No filed New York Court of Appeals answering brief was found after the searches listed in `exemplars/SOURCE.md`. The template and sample were built from the rules. The sample is **rule-built placeholder text**, not a transcription of a filed brief, and is not a model for any filing.

| Gate | Result |
|---|---|
| exemplar | no (none found) |
| typeface | face required: none (NY-TYPE-001 / 500.1(j): "serifed, proportionally spaced typeface, such as Times Roman"; Times is an example). Vendored substitute: none needed; **EB Garamond kept** (`fonts/eb-garamond`). Fit: n/a. Liberation Serif (Times-metric) is vendored if David wants the Times example applied: set `font-family` and re-render |
| render | ok (`sh tools/render.sh … samples/INPUT-ny-answering-brief-sample.md`, 12 pages, vendored EB Garamond only, no typst warnings; re-rendered 2026-10-15, pdffonts: EB Garamond Regular/Italic/Bold embedded) |
| overlay | fail (`sh tools/overlay.sh` exits 1: `no exemplar pdf in …/exemplars`) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed; pages 7, 12 and 5, 6, 8–11 re-viewed after the fixes below) |

`BLOCKED: no exemplar`. Searches tried are in `exemplars/SOURCE.md`.

## Governing rules

Rules are 22 NYCRR Part 500 (Rules of Practice of the Court of Appeals). Primary source: <https://www.nycourts.gov/ctapps/500rules.htm>.

**Verification limit.** On 2026-10-14 this page returned a Cloudflare challenge / HTTP 403 to every fetch method available here (curl, WebFetch), and so did the Justia copies (`regulations.justia.com/.../section-500-1` and `.../section-500-13`) and the courtrules.net copy. The rule text below comes from **search-result excerpts** of those pages, not from a direct read. Each rule must be checked against the official text before the template is relied on.

| ID | Rule | Source (as excerpted) | Verified |
|---|---|---|---|
| NY-FORM-001 | One-inch margins on all sides, word-processed papers | 22 NYCRR 500.1(l), excerpt | search excerpt only |
| NY-FORM-002 | Double spacing for text | 500.1(l), excerpt | search excerpt only |
| NY-FORM-003 | Block quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced | 500.1(l), excerpt | search excerpt only |
| NY-FORM-004 | Page numbers centered in the bottom margin | 500.1(l), excerpt | search excerpt only |
| NY-TYPE-001 | Serif, proportionally spaced typeface; no narrow or condensed faces; outside headings no bold and no all-caps words | 500.1 typeface subsection (said to sit just before (l); subsection letter not confirmed), excerpt | search excerpt only |
| NY-TYPE-002 | Proportional font: body 14-point, footnotes at least 12-point | same subsection, excerpt | search excerpt only |
| NY-FORM-005 | Covers white; plastic covers not used | 500.13, excerpt | search excerpt only |
| NY-WORD-001 | Principal briefs for appellant and respondent: 14,000 words; signer certifies the word count for the printed body of the brief | 500.13(c)(1), excerpt | search excerpt only |
| NY-WORD-002 | **Conflict, unresolved.** Another excerpt says principal briefs are capped at 35 pages. The template implements the word-count certificate only | 500.13 / Part 500 summary, excerpt | unresolved |
| NY-DISC-001 | Disclosure statement | 500.1(f) (the reference appears in the table of contents of a filed Court of Appeals brief, which was not used as an exemplar) | not checked against the rule text |

Rule dates: none verified. The Justia copy is current only through September 2024, per its own excerpt.

## Folders

- `typst/main.typ`: entrypoint (reads `sample=` from `--input`).
- `typst/ny-answering-brief.typ`: template. Structure copied from `courts/ninth-circuit/court-of-appeals/typst/`; the numbers, rules and certificate wording are New York's (not the ca9 ones).
- `samples/INPUT-ny-answering-brief-sample.md`: rule-built sample. Frontmatter schema below.
- `samples/OUTPUT-ny-answering-brief-sample.pdf`: render output (12 pages).
- `samples/ny-answering-brief-sample-overlay.*`: **not produced** (overlay failed, see above).
- `exemplars/SOURCE.md`: search record.

## Markdown contract (frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `apl_docket` | yes | cover, e.g. `APL-2026-00000` |
| `county_clerk_index` | yes | cover, e.g. `Index No. 000000/2025` |
| `caption` | yes | list of two sides, each with `names` and `designation`; "–against–" is inserted between sides |
| `proceeding` | yes | cover line naming the court below |
| `brief_title` | yes | cover title (printed in capitals, see gaps) and document title |
| `counsel` | yes | cover counsel groups (`names`, `lines`) |
| `phone` | yes | cover, after the counsel block |
| `signature` | yes | `signer` and `lines`, after the Conclusion and on the certificates |
| `date` | no | under the signature and on the certificates |
| `disclosure` | no | disclosure statement page, shown only when given |
| `service` | no | `method` and `unregistered` (list of `{name, address}`); shown only when given; certificate of service |
| `authorities` | yes if the body cites any | table of authorities registry: `kind` (case, constitution, statute, regulation, rule, other), `name`, `cite` |

Body: `#` is a section (centered, bold, capitals). `##`, `###`, `####` are sub-headings with their letters and numerals typed in the markdown. Block quotations are `>`. Footnotes are `[^key]` with a definition anywhere in the file. Smart punctuation is on. Escape markdown-looking leading characters (`1\.`).

## What the overlay shows

Not produced. `tools/overlay.sh` pairs each rendered page with the best-matching exemplar page by word overlap. There is no exemplar, so there is nothing to overlay.

## Known gaps (found in the 12-page review)

1. **Signature block orphaned.** The Conclusion ends on page 9; "Respectfully submitted" and the signature block start page 10. The template has no keep-with-next control between the Conclusion and the signature block. Not fixed.
2. **Table of authorities has no page references.** Entries are listed by kind with citations, but the pages where each is cited are not generated. The ca9 template tags citations through its markdown link contract; this template does not yet do that. A real filing needs it.
3. **Word count is approximate.** The certificate counts whitespace-delimited tokens of the markdown body, minus footnote definitions. It includes markup tokens (`*`, `#`, `>`), so it overcounts slightly. The sample certificate shows 1,119. Not a filing count.
4. **Cover title in capitals.** `brief_title` is printed in capitals on the cover. The rule (NY-TYPE-001) bars all-caps words outside headings; the cover title is treated as a heading. This is a judgment call and is not verified against the rule text.
5. **Counsel and caption in title case.** Filed New York briefs commonly set counsel names in capitals. This template does not, because of NY-TYPE-001 as excerpted. Verify.
6. **Sub-heading spacing tuned by eye.** Level-3 and level-4 heading spacing was adjusted after the page review. A proper measurement against an exemplar is not possible without one.
7. **Page limit unresolved (NY-WORD-002).** Only the word-count certificate is generated; no page-limit check.
8. **No line-level tier-2 review.** Without an exemplar, the layout cannot be judged against a filed brief. Tier 1 is not claimed as met.

## Searches for an exemplar

See `exemplars/SOURCE.md`. Two real Court of Appeals filings were downloaded and read during the search: a 2010 *Hurrell-Harring* reply brief (NYCLU-hosted, 57 pp, text layer present) and a *People v. Trump Entrepreneur Initiative* brief for respondents-appellants (Kasowitz, 2016, ag.ny.gov, 156 pp). Neither is an answering brief, so neither was saved as an exemplar.

[Formbook index](../../../../../../README.md) | [Court README](../README.md)
