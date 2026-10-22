# New York Court of Appeals: answering brief (brief for respondent)

Status: **exemplar found (2026-10-15); not `done`.** The exemplar is `usage/FILED-EXAMPLE-answering-brief-2.pdf`, a filed Brief for Respondent (Manhattan DA, January 12, 2024). The sample is a **transcription of part of that brief** (cover, tables, preliminary statement, question presented, part of the statement of the case, standard of review, start of the argument, conclusion, certification), not the whole 52 pages. The earlier "BLOCKED: no exemplar" result is superseded; its search log is kept in `usage/SOURCE.md`.

| Gate | Result |
|---|---|
| exemplar | yes: *People v. Watkins*, APL-2023-00099, Brief for Respondent (Manhattan DA), dated January 12, 2024; text layer present; see `usage/SOURCE.md` |
| typeface | face required: none (NY-TYPE-001 / 500.1(j): "serifed, proportionally spaced typeface, such as Times Roman"; Times is an example). Vendored substitute: none needed; **EB Garamond kept** (`fonts/eb-garamond`). Fit: n/a. Liberation Serif (Times-metric) is vendored if David wants the Times example applied: set `font-family` and re-render |
| render | ok (`sh tools/render.sh … usage/INPUT-answering-brief.md`, 13 pages, vendored EB Garamond only, no typst warnings; re-rendered 2026-10-16 after the fixes below, pdffonts: EB Garamond Regular/Italic/Bold embedded) |
| overlay | ok (`sh tools/overlay.sh <court-dir> ny-answering-brief-sample` wrote `usage/OVERLAY-ny-answering-brief-sample.pdf` and `.txt`; page map below) |
| pages reviewed | 13 of 13 of the final render (2026-10-16): every page rendered at 60 dpi (`pdftoppm -r 60`) and viewed after the last template change |

Tier 1 (the court's mandated form) is **not claimed as met**: the rules are still only checked against search excerpts (see "Governing rules"). Tier 2 findings are in "Tier 2 review" below.

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
- `usage/INPUT-answering-brief.md`: transcription of part of the exemplar (see the header comment in the file). Frontmatter schema below.
- `usage/OUTPUT-answering-brief.typst.pdf`: render output (13 pages, EB Garamond only).
- `usage/OVERLAY-ny-answering-brief-sample.pdf` and `.txt`: overlay on the exemplar and page map.
- `usage/FILED-EXAMPLE-answering-brief-2.pdf`: the exemplar (52 pages).
- `usage/SOURCE.md`: exemplar record (URL, case, docket, filer, dates) and the search log.

## Markdown contract (frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `apl_docket` | yes | cover, e.g. `APL-2026-00000` |
| `argued_by` | no | cover, upper right corner (500.13(b)): "To be argued by:" and the value (e.g. `MICHAEL J. YETTER (20 Minutes Requested)`); shown only when given (the exemplar prints it) |
| `county_clerk_index` | no | cover, e.g. `Index No. 000000/2025`; shown only when given (the exemplar's cover does not print one) |
| `caption` | yes | list of two sides, each with `names` and `designation`; "–against–" is inserted between sides |
| `proceeding` | no | cover line naming the court below; shown only when given (the exemplar's cover does not print one) |
| `brief_title` | yes | cover title (printed in capitals, see gaps) and document title |
| `counsel` | yes | cover counsel groups (`names`, `lines`) |
| `phone` | yes | cover, after the counsel block |
| `fax` | no | cover, under `phone` (500.13(b) asks for telephone and facsimile numbers); shown only when given |
| `signature` | yes | `signer` and `lines`, after the Conclusion and on the certificates |
| `date` | no | under the signature and on the certificates |
| `disclosure` | no | disclosure statement page, shown only when given |
| `service` | no | `method` and `unregistered` (list of `{name, address}`); shown only when given; certificate of service |
| `authorities` | yes if the body cites any | table of authorities registry: `kind` (case, constitution, statute, regulation, rule, other), `name`, `cite` |

Body: `#` is a section (centered, bold, capitals). `##`, `###`, `####` are sub-headings with their letters and numerals typed in the markdown. Block quotations are `>`. Footnotes are `[^key]` with a definition anywhere in the file. Smart punctuation is on. Escape markdown-looking leading characters (`1\.`).

## Exemplar findings (2026-10-15)

Template changes made from the exemplar (the rules are silent on each; the exemplar settles it):

- Cover: `argued_by` added; `county_clerk_index` and `proceeding` made optional (the exemplar prints neither).
- Headings (all levels) are set unjustified and unhyphenated. The first render broke headings at hyphens (`ARGU-MENT`, `DECLIN-ING`); the exemplar's headings are not hyphenated.
- Page numbers: cover unnumbered, front matter in lower-case roman (`ii`, `iii`), body restarts at 1. The first render counted from the cover, which the exemplar does not do.
- Cover overflow risk: in the first render, a long counsel block pushed the date onto a blank page 2. The sample's counsel block was shortened to fit. The template has no guard for this; a longer counsel block will overflow again. (2026-10-16: the cover is full again with the `fax` line; still no guard.)

## Tier 2 review (13-page render against the exemplar, 2026-10-16)

Each row is a convention the exemplar shows that the template does not match, or a choice the exemplar leaves open. `ACCEPTED` = matches a clerk's expectation for this filing; `OPEN` = unresolved. Page numbers are PDF pages.

| Page | Finding | Status |
|---|---|---|
| 1 (cover) | Date sits after the telephone and fax lines; the exemplar sets the date under the second counsel group. | ACCEPTED (position only) |
| 1 (cover) | Counsel names in the sample are set in capitals as the filer typed them; the template does not force capitals (see gap 5). | ACCEPTED |
| 1 (cover) | The exemplar sets the docket at the top and the counsel block right of centre; ours sets the docket under the court name and counsel in two columns. | ACCEPTED (tier 3) |
| 2 (TOC) | "Page" column heading: now printed (2026-10-16). Entries are single spaced with no space between them; the exemplar spaces them. | ACCEPTED |
| 3 (TOA) | Entries carry no page references (see gap 2). | OPEN |
| 3 (TOA) | Cases and statutes are grouped; the exemplar uses "Federal Cases / State Cases / State Statutes". The template groups by kind, alphabetical within a group (2026-10-16; was file order). | ACCEPTED (grouping label only) |
| 13 (certificate) | The exemplar's word-count certification also states the word processor, the typeface (Garamond), and the point sizes (14-point text, 13-point footnotes). The template states only the word count. Adding typeface and size needs a new field; the rules excerpt does not say whether it is required. | OPEN |
| 12 (signature) | The exemplar uses a "BY:" line under the office name; the template uses the filer's name and title under "Respectfully submitted". | ACCEPTED |
| 4–12 (body) | The body is the exemplar's text in the exemplar's order. TOC page numbers checked against the rendered pages (Preliminary Statement 1, Question Presented 4, Statement of the Case and A. 5, Standard of Review 7, Argument and Point 8, Conclusion 9). | no change needed |

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the best-matching exemplar page by word overlap (`usage/OVERLAY-ny-answering-brief-sample.txt`). The page map of the 2026-10-16 render:

| Our PDF page | Filed PDF page | Word overlap |
|---|---|---|
| 1 (cover) | 1 (cover) | 95.3% |
| 2 (TOC) | 2 (TOC) | 33.8% |
| 3 (TOA) | 5 (TOA, continued) | 30.7% |
| 4 (body p.1) | 8 | 47.7% |
| 5 | 9 | 44.0% |
| 6 | 10 | 50.3% |
| 7 | 10 | 51.4% |
| 8 | 12 | 86.4% |
| 9 | 13 | 93.9% |
| 10 (standard of review) | 27 | 82.5% |
| 11 (Point I) | 31 | 91.7% |
| 12 (conclusion page) | 1 | 24.0% |
| 13 (certificate) | 52 (certification) | 18.3% |

The pairing is by word-set overlap, so it is a diagnostic, not a score. Our page 4 (preliminary statement) pairs with filed page 8, not filed page 7, and our page 12 (the conclusion and signature block) pairs with the filed cover, because the names and office on both pages overlap. Page 13 (certificate) pairs with the filed word-count certification. With the line pitch fixed (31.4 pt, the exemplar's is 31.4/31.6 pt) the red and blue body lines now run at the same pitch on the overlay; before, ours were 25.9 pt.

## Known gaps

1. **Signature block placement.** In the 13-page render (2026-10-16), the Conclusion and signature block share PDF page 12 (numbered 9), so the first render's orphaned signature did not recur. The template still has no keep-with-next control between the Conclusion and the signature block, so a longer body can orphan it again.
2. **Table of authorities has no page references.** Entries are listed by kind with citations, but the pages where each is cited are not generated. The ca9 template tags citations through its markdown link contract; this template does not yet do that. A real filing needs it.
3. **Word count is approximate.** The certificate counts whitespace-delimited tokens of the markdown body, minus footnote definitions. It includes markup tokens (`*`, `#`, `>`), so it overcounts slightly. The sample certificate shows 2,015 for the partial transcription. Not a filing count. The exemplar certifies 11,545 words for the whole brief.
4. **Cover title in capitals.** `brief_title` is printed in capitals on the cover. The exemplar does the same ("BRIEF FOR RESPONDENT" on the cover), so this now matches the exemplar. The rule (NY-TYPE-001) bars all-caps words outside headings; the cover title is treated as a heading. The rule text is still not verified.
5. **Counsel and caption capitalisation.** The exemplar sets counsel and party names in capitals. The template prints whatever the filer types; the sample types them in capitals to match the exemplar. The template itself does not force capitals.
6. **Sub-heading spacing tuned by eye.** Level-3 and level-4 heading spacing was adjusted after the page review. The exemplar's heading spacing is not measured here; this remains a judgment.
7. **Page limit unresolved (NY-WORD-002).** Only the word-count certificate is generated; no page-limit check. The exemplar certifies a word count of 11,545 (under the 14,000-word limit in the excerpt) and does not state a page count, which supports the word-count reading; the rule text is still unverified.
8. **Tier 1 not verified.** The rule table above is from search excerpts. Until the official text is checked, the template is not a tier-1 pass.

## Verification pass 2026-10-16 (fb-595.26.21)

- Render: `sh tools/render.sh … usage/INPUT-answering-brief.md` exit 0, no typst warnings. The committed PDF had 12 pages and re-rendered to 12 before any change; after the fixes below it is 13 pages (cover, contents ii, authorities iii, body 1 to 10). `pdffonts`: EB Garamond only.
- Pages viewed: all 13 pages of the final render at 60 dpi, plus the pages each intermediate fix touched. The 13 overlay pages were viewed at 40 dpi, and the exemplar's page 1 against our cover.
- Overlay: rerun on the final render; map in "What the overlay shows".
- Defects fixed (template `typst/ny-answering-brief.typ`):
  1. Body not double spaced (NY-FORM-002 / 500.1(l)): line pitch was 25.9 pt at 14 pt (`pdftotext -bbox`), and paragraphs were closer together than lines. Leading and paragraph spacing now give 31.4 pt throughout, as the exemplar (31.4/31.6 pt) and the docx reference do.
  2. Headings ignored their show rules' size and centring: section headings printed at typst's default 1.4 em, left aligned, and sub-headings at 1.2 em. Every heading level now sets the body size explicitly; section headings are centred, bold capitals as the README states. Headings are single spaced.
  3. The first paragraph after a heading had no first-line indent. All body paragraphs are now indented.
  4. Footnote number ran into the text ("1Unless"). The number is now followed by a space; footnotes stay 12 pt, single spaced.
  5. The argument request was in the upper left of the cover; 500.13(b) (text as read in `../opening-brief/README.md`) puts it in the upper right. Moved there. Court name and brief title on the cover are now bold, as in the exemplar.
  6. 500.13(b) asks for counsel's facsimile number on the cover: new optional `fax` field, printed under `phone`; the sample now carries the exemplar's fax line.
  7. Contents: "Page" column heading added (was an OPEN tier-2 row). Authorities: alphabetical within each group (was file order, Strickland first).
- Sample fix: `5'10"` was turned into a wrong opening quote by smart punctuation; now typed as the exemplar prints it (`5’10”`).
- Remaining gaps: TOA page references (gap 2); certificate does not state typeface and size (tier-2 OPEN row); the cover now fills the page with the fax line added, so a longer counsel block will push the date onto a page 2 (no guard); tier 1 still rests on search excerpts of the rules (gap 8).

## Searches for an exemplar

See `usage/SOURCE.md`. The 2026-10-14 search found no answering brief. The 2026-10-15 search found the Watkins brief through statecourtreport.org's copies of Court of Appeals briefs. Two other real Court of Appeals filings were read during the earlier search, a 2010 *Hurrell-Harring* reply brief and a 2016 *People v. Trump Entrepreneur Initiative* appellants' brief; neither is an answering brief.

[Formbook index](../../../../../../README.md) | [Court README](../README.md)

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.37): Times New Roman 14 pt (22 NYCRR 500.1(i), (j)(1)), footnotes 12 pt, exact line pitches (31.4 pt double, 19 pt single, 16.3 pt footnotes), first-fit ragged-right lines without kerning, ligatures or hyphenation. The docx render breaks every line and every page where the typst render does (`params.cross_engine: gate` in `eval.yaml`).

**docx** (`docx/`): `docx/reference.xml` (fb render builds `reference.docx` from it: the xengine recipe in the typst face, Body Text Note for a paragraph that anchors a footnote) and `docx/ny-answering.lua`, which writes the cover (the same gap search as typst, on an estimate of its height), the disclosure statement, the table of contents with its page numbers (needles: fb render finds each heading's page in the LibreOffice PDF and renders again), the table of authorities, the headings, the signature block and the certificates, and the three sections (cover unnumbered, front matter from ii, body from 1). No shell scripts. Render: `sh tools/render.sh --engine docx courts/second-circuit/new-york/state/court-of-appeals/answering-brief usage/INPUT-answering-brief.md`.

- The table of authorities has no page references on either engine (known gap 2: the sample's citations are not `toa:` links).
- Word may paginate slightly differently from the LibreOffice PDF the contents' page numbers come from (docs/DOCX.md).
