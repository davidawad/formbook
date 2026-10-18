# Bankr. N.D. Ga.: motion with memorandum of law (`motion-brief`)

Doc type: **motion with a memorandum of law**, filed in an adversary proceeding (or a contested matter) in the United States Bankruptcy Court for the Northern District of Georgia (`ganb`). Folder: `courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, 1 filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`, the whole filing (motion, memorandum, certificate) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only (embedded), no warnings |
| overlay | ok: `usage/OVERLAY-kapitus-23-02003.pdf` and `OVERLAY-kapitus-23-02003.txt`, made 2026-10-14 against the RECAP copy of the exemplar (the exemplar PDF is not committed; see gaps 11) |
| pages reviewed | 7 of 7 re-rendered and viewed 2026-10-14 (fonts pass; the face did not change, see Typeface below) |

## Typeface

| Item | Result |
|---|---|
| Face required by the rules | None named. The BLR 5005-1 and 7007-1 text read (search excerpts of courtrules.net) names no typeface; FRBP 9004(a) says "clearly legible" with no face. Subsection (f) of BLR 5005-1 (caption style) was not seen (see gaps 1). |
| Substitute (`docs/FONTS.md`) | None needed: the "No face named" row, so **EB Garamond** stays. |
| Fit | n/a (the rules name no face to be metric-compatible with) |
| Embedded (`pdffonts`) | `EBGaramond-Regular`, `EBGaramond-Bold`, `EBGaramond-Italic` (all embedded, CID Type 0C) |

Not a `court.json` status; nothing here sets `status`. The court-root `README.md` and `court.json` are not touched.

## File names

The brief asked for `usage/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The shared tools write and read `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt` (`tools/render.sh`, `tools/overlay.sh`), so the sample uses those names. `<id>` is `kapitus-23-02003`.

## Governing rules

Verification date for everything below: 2026-10-14.

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| GANB-RULE-001 | Fed. R. Bankr. P. 9013 (as amended eff. Dec. 1, 2024; text from https://www.law.cornell.edu/rules/frbp/rule_9013, fetched 2026-10-14) | "A motion must state its grounds with particularity and set forth the relief or order requested." | Author content (the sample's "Global moves..." and "WHEREFORE" paragraphs). The template does not check it. |
| GANB-RULE-002 | Fed. R. Bankr. P. 9004(a)-(b) (as amended eff. Dec. 1, 2024; https://www.law.cornell.edu/rules/frbp/rule_9004) | (a) "clearly legible". (b) caption: court name; case title; case number and, if appropriate, adversary-proceeding number; a brief designation of the document's character. | `court_title`, `caption` (rows with the case and adversary numbers), `title`. |
| GANB-FORM-001 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*: courtrules.net text, see "Known gaps" 1) | Paper 8½ × 11 inch; first page leaves a clear space 2 in × 2 in in the upper right corner for the filing stamp. | `page1-caption-gap` (0.4 in after the court title, so the caption starts below 2 in; no text in the stamp area on page 1, measured on the render). Paper: `us-letter`. |
| GANB-FORM-003 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | Adversary and contested-matter papers: "at least one and one-half spaces between lines". | `body-leading = 1.075em`: 1.5 × the 1.15em single pitch. Measured on the render: 22.4 pt pitch at 13 pt (single 14.95 pt). |
| GANB-FORM-002 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*, no font named); FRBP 9004(a) (legible) | Legible, proportional serif. No size set by the rules I could read. | `font-family = "EB Garamond"` (vendored), `type-size = 13pt` (see gaps). |
| GANB-FORM-004 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | 1 inch left margin; the rest is the template's choice. | `margins` (1 in all sides). |
| GANB-FORM-005 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | "All pages must be numbered consecutively at the bottom center of the page." | `footer`: page number, centered, 11 pt. |
| GANB-SIG-001 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | Attorney name, complete address, telephone, e-mail and Georgia bar number on every paper an attorney files. | `signature.lines` (firm, "/s/" line, name, bar number, address, phone, e-mail, "Attorney for ..."). |
| GANB-CONT-001 | Bankr. N.D. Ga. BLR 7007-1 (*secondary*) | Motion in an adversary proceeding "must be accompanied by a memorandum of law or other citation of supporting authority"; affidavits where facts are outside the record. Response 14 days after service; briefs capped at 25 pages absent leave; reply 15 pages. | The sample's "MEMORANDUM OF LAW" section (author content). The template does not count pages or check the memorandum. |
| GANB-CONT-002 | Fed. R. Civ. P. 5(d)(1)(B) via Fed. R. Bankr. P. 7005 (text from https://www.law.cornell.edu/rules/frcp/rule_5, fetched 2026-10-14; the bankruptcy rule itself not fetched) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." Otherwise a certificate must be filed. | Optional `certificate:` (markdown) with the counsel block. The sample uses it (the exemplar has one). |

Not used, and why:
- BLR 9013-1 (*secondary*): motions in the main case need no brief; BLR 7007-1 governs motions in adversary proceedings. The template is for the adversary form. A main-case motion without a memorandum would not need the `MEMORANDUM OF LAW` section, and the template does not require one.
- Fed. R. Bankr. P. 7008(a) (consent to final orders) and 7010 (complaint captions): these apply to complaints, which are the `adversary-complaint` doc type.
- Proposed orders and declarations: separate filings.

## Layout

- Letter paper, 1 inch margins, page number bottom center on every page.
- Page 1: court title (centered, bold capitals), 0.4 in gap, caption, rule, document title (centered, bold capitals). The caption: rows of `[left, right]` with a ")" column, as in the exemplar.
- Body: 1.5 spacing, first-line indent ½ in. Headings: `#` centered bold capitals (`MEMORANDUM OF LAW`), `##` bold at the margin (`Introduction`), `###` bold italic. Heading numbering: none (the exemplar's headings are not numbered).
- Block quotes: single-spaced, indented ½ in on each side. Footnotes: cmarker default.
- Signature block after the body: `signature.dated` on its own line, then `signature.lines` at the right half of the page.
- Certificate of service (optional): centered heading, text, counsel block.
- No table of contents and no table of authorities: the exemplar has neither, and the BLR text I could read asks for none.

## Markdown contract (for samples)

A sample is one `.md` file: YAML frontmatter, then the body.

Frontmatter:
- `court_title`: list of lines, printed centered in capitals.
- `caption`: list of rows, each `[left, right]`. A ")" column is drawn between them. Use `["", ""]` for a blank row. The case number and adversary number go in the right column.
- `title`: list of lines for the document title (printed centered in capitals).
- `signature`: `dated` (optional; the line "Respectfully submitted, this …"), `lines` (list, printed in order; the "/s/" line is one of them).
- `certificate` (optional): markdown text for the certificate of service.

Body:
- `#` = centered section (`MEMORANDUM OF LAW`); `##` = sub-heading; `###` = run-in sub-sub-heading. No numbers typed.
- Paragraphs: blank-line separated, first-line indented.
- Case names and signals in `*italics*`. Escape a leading marker you do not want as a list (`\*3`).
- Footnotes: `text[^key]` with `[^key]: text` (cmarker).
- Not supported: tables, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/motion-brief kapitus-23-02003
```

- `usage/OVERLAY-kapitus-23-02003.pdf`: red = our render, blue = filed exemplar, black = both. Page pairing by word overlap (from `OVERLAY-kapitus-23-02003.txt`): ours p.1 ↔ filed p.1 (86.2%), p.2 ↔ p.2 (78.8%), p.3 ↔ p.3 (60.5%), p.4 ↔ p.5 (50.5%), p.5 ↔ p.6 (75.5%), p.6 ↔ p.7 (74.1%), p.7 ↔ p.8 (52.2%). The filed copy has 10 pages and its later pages (9-10, the certificate) are not paired. The exemplar's caption uses ")" and ours does too, so page 1 lines up closely. The overlay is a diagnostic, not a score.

## Defects found and fixed (Gate 2 record)

1. First render: each paragraph's first line overlapped the last line of the paragraph before it. Cause: `spacing: 0pt` on `set par`. Removed; paragraphs now separate by the normal gap (measured on the render: pitch 22.4 pt inside a paragraph, a few points more at a break).
2. Page 1 leaves a long blank at the bottom: the `#` heading and the `##` heading keep with the first paragraph of the Introduction, which does not fit. Accepted; keeping a heading with its text is the rule the template follows.

## Visual review (all 7 pages rendered at 60 dpi and viewed after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (")" column), rule, title, COMES NOW paragraph | OK. Nothing in the 2 in × 2 in upper-right area (measured: the only text above y = 144 pt sits at x ≤ 428 pt; the stamp area is x ≥ 468 pt). |
| 2 | MEMORANDUM OF LAW, Introduction, Procedural Background | OK. Italic case names; "*3" in the Rosen cite prints correctly. |
| 3 | Procedural Background (cont.) | OK. |
| 4 | ARGUMENT AND CITATIONS OF AUTHORITY; Count I | OK. |
| 5 | Counts II and III | OK. Sub-headings bold, two-line headings with no widow. |
| 6 | Counts IV to VII | OK. |
| 7 | WHEREFORE, signature block, certificate of service | OK. Page number bottom center. |

Reviewed pages: 7 of 7.

## Engines

| Engine | Result here | Output |
|---|---|---|
| typst (primary, `typst/`) | unchanged by this work | `usage/OUTPUT-motion-brief.typst.pdf` |
| docx (`docx/`) | `.docx` built and XML-checked; `.docx.pdf` **not produced** (no LibreOffice in this box), so no page was rendered or reviewed | `usage/OUTPUT-motion-brief.docx` |

`docx/make-reference.sh` builds `docx/reference.docx` from pandoc's default reference: EB Garamond 13 pt; body text 1.5 spaced (exact 22.4 pt); half-inch first-line indent; block quotations single-spaced and indented ½ in on each side; footnotes 11 pt; letter page, 1-inch margins; centered 11 pt page number. `docx/ganb-motion-brief.lua` builds the first page (caption as a borderless table: 3.4 in, 0.3 in ")" column, the rest; 0.4 in gap for the filing stamp; rule; title), passes the body through as written (no paragraph numbers, as the typst template), and builds the signature and certificate blocks in the right half of the page. Certificate text keeps the body first-line indent, as the typst template does.

- **Matches (by construction, from the typst parameters):** font, size, line pitch, margins, indent, caption columns, stamp gap, page-number footer, block quotations, certificate placement.
- **Differs:** the docx has not been paginated or viewed, so page count and line breaks are unknown; Word and LibreOffice may break lines differently. The sample has no footnotes or block quotations, so those styles are set from the template but not exercised. The title is set with the All Caps property, so "523(a)" stays in the source text; the typst template's `upper()` would turn it into "523(A)".
- **docx BLOCKED** (Gate 0 and Gate 1 are measured on the `.docx.pdf`; `docs/DOCX.md`). The `.docx.pdf` cannot be made in this box (conda-forge has no `libreoffice`; no root), so every row below is BLOCKED until a box with LibreOffice runs the check:
  - BLOCKED: GANB-FORM-001: stamp-area measurement on the PDF cannot run.
  - BLOCKED: GANB-FORM-002: font and size on the PDF cannot be checked.
  - BLOCKED: GANB-FORM-003: line pitch on the PDF cannot be checked.
  - BLOCKED: GANB-FORM-004: margins on the PDF cannot be checked.
  - BLOCKED: GANB-FORM-005: page-number footer on the PDF cannot be checked.
  - BLOCKED: GANB-SIG-001: counsel block on the PDF cannot be checked.
  - BLOCKED: GANB-CONT-001: memorandum heading on the PDF cannot be checked.
  - BLOCKED: GANB-CONT-002: certificate of service on the PDF cannot be checked.
  - BLOCKED: GANB-RULE-001: caption and title on the PDF cannot be checked.
  - BLOCKED: GANB-RULE-002: caption layout on the PDF cannot be checked.

## Known gaps and open choices

1. **Local rule text is secondary, not verified against the court's PDF.** BLR 5005-1 and 7007-1 were read through search-result excerpts of courtrules.net. Fetching courtrules.net (both the tool and curl with browser headers) returns HTTP 403, and the court's own 2019 local rules PDF (`ganb.uscourts.gov/sites/default/files/local_rules_effective_9-1-2019.pdf`) returns an error page. The court's current rules may differ from the 2019 text. **Needs someone to check the current BLR 5005-1, 7007-1 and 9013-1 against the court's PDF before this template is called complete.**
2. **Font.** EB Garamond at 13 pt (vendored; the only serif in `fonts/`). The exemplar is Liberation Sans/Helvetica body text with Times headers. The rules I could read do not name a font. 13 pt is a style choice so EB Garamond reads at the size of 12 pt Times.
3. **Tier 2: one exemplar only.** EVAL-LOOP asks for two or three filers. Searches: CourtListener RECAP `court=ganb` for motions with a memorandum. Kapitus Doc 29 (same docket, motion with embedded argument, no memorandum section) and Palmer v. Nasir 23-02020 Doc 4 (motion to dismiss, no RECAP PDF) were checked; a search for Bargar v. Wells Fargo 25-05040 Doc 7 (memorandum supporting default judgment) returned no hits. Not saved.
4. **Certificate page does not repeat the caption.** The exemplar's certificate page repeats the full caption; this template does not. Tier-2 finding, OPEN. Not required by any rule I could read.
5. **Filing stamp area.** Kept (2 in × 2 in clear area on page 1) because BLR 5005-1 asks for it. The exemplar is an ECF copy and has no stamp space; the template keeps the area for paper filing.
6. **Page limit (BLR 7007-1, 25 pages).** Not counted. The sample is 7 pages.
7. **No table of contents or table of authorities.** The exemplar has none.
8. **Exemplar typos kept.** "CITIATIONS", "Similary", "Vigil", "brough", "Global., and", a Rule 12(b)(6) cite under the bankruptcy rules. The transcription is verbatim, so the sample matches the filing.
9. **The sample is the whole filing** (the motion, memorandum, WHEREFORE, signature and certificate), so the overlay covers all of it.
10. **Certificate of service optional.** Under Fed. R. Civ. P. 5(d)(1)(B) no certificate is needed for ECF service. The template keeps the certificate as an option because the exemplar has one.
11. **Local practice not checked:** judge-specific standing orders, and the signature style (`/s/`) beyond the exemplar.
12. **Exemplar PDF not in the repo.** Only `usage/SOURCE.md` is committed. For the 2026-10-14 overlay the RECAP copy was fetched from the URL in `SOURCE.md` into a scratch directory and passed to `tools/overlay.sh` as its third argument. Committing the PDF is a repo decision, not made here.
13. **BLR 5005-1 subsection (f) and the 2019 PDF not retrieved (2026-10-14).** courtrules.net returns HTTP 403; the court's 2019 local-rules PDF returns an 855-byte error page. The font conclusion rests on the excerpts, which name no face; re-check subsection (f) against the court's PDF.
