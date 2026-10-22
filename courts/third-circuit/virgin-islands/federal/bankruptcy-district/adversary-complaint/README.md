# Adversary complaint: United States Bankruptcy Court, D.V.I. (`vib`)

Doc type `adversary-complaint`, under [`../`](../) (the bankruptcy district court). Governing rules: FRBP 7001 (adversary proceedings), 7008, 7010; LBR of the District Court of the Virgin Islands, Bankruptcy Division (`LBR 5005-1`, `LBR 7008-1`).

## What is here

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter, calls the template. |
| `typst/vib-adversary-complaint.typ` | The template: `complaint(meta, md)`, on the shared cross-engine layout model (`lib/typst/xengine.typ`). Every number is a named parameter or traces to a rule. |
| `docx/reference.xml`, `docx/vib-adversary-complaint.lua` | The docx engine: the Word styles (built by `fb render`) and the filter on `lib/docx/xengine.lua`. No shell script. |
| `eval.yaml` | `params.cross_engine: gate`: the docx must break every line and page as typst does. |
| `usage/INPUT-adversary-complaint.md` | Transcription of the filed First Amended Complaint, with the frontmatter contract below. Two sentences are marked `ADDED` (see VIB-AC-JURIS). |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | Our typst render, 11 pages. |
| `usage/OUTPUT-adversary-complaint.docx`, `.docx.pdf` | The docx render and its LibreOffice PDF, 11 pages. |
| `usage/FILED-EXAMPLE-adversary-complaint.pdf` | The filed exemplar (13 pp., text layer). |
| `usage/SOURCE.md` | Where it came from, filer, case, date filed, URL, date fetched. |

Build and check (from the repo root):

```sh
sh tools/render.sh courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/check.sh courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint
sh tools/check.sh courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint --engine docx
just overlay courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint
```

Rendering uses the vendored fonts only (`--ignore-system-fonts`); any warning fails the render. Both PDFs embed Times New Roman only (regular, bold, italic).

## Governing rules (verified 2026-10-14)

| ID | Requirement | Source (verified text) |
|---|---|---|
| VIB-AC-CAPTION | Caption: court name, case title, case number and adversary number, designation of the document (FRBP 9004(b)). The adversary caption substantially conforms to Form 416 (FRBP 7010), which LBR 7008-1(A) specifies as Official Form 416D. | FRBP 9004(b) and 7010: <https://www.law.cornell.edu/rules/frbp/rule_7010>; LBR 7008-1(A) in the VI bankruptcy local rules: <https://www.vid.uscourts.gov/sites/vid/files/local_rules/NewBK_RulesDec2017.pdf> |
| VIB-AC-NUMBER | All paragraphs in pleadings are sequentially numbered (LBR 5005-1(A)); paragraphs numbered consecutively, each limited as far as practicable to a single set of circumstances (FRCP 10(b), applied by FRBP 7010). | LBR 5005-1(A) (same PDF); FRCP 10(b): <https://www.law.cornell.edu/rules/frcp/rule_10> |
| VIB-AC-FONT | Font size no smaller than 12 Courier, or an equivalent size for another face (LBR 5005-1(B)). Face required = none (Courier is the size benchmark). The template sets Times New Roman 12 pt, footnotes and footer included: the exemplar's face and the house standard, in every engine. | LBR 5005-1(B), text verified 2026-10-14 |
| VIB-AC-PAGE | 8½ × 11 paper; pages sequentially numbered (LBR 5005-1(A)). Footer carries "Page n of N". | LBR 5005-1(A) |
| VIB-AC-JURIS | The jurisdiction allegation names the case (name, number, Code chapter), the district and the division; the complaint states whether the pleader consents to final orders by the bankruptcy court. | FRBP 7008(a): <https://www.law.cornell.edu/rules/frbp/rule_7008> |
| VIB-AC-SIGNATURE | Dated, signed by counsel (`/s/`), with each counsel's name, bar number and address. | FRBP 9011 (signing convention), and the exemplar's signature block |
| VIB-AC-SPACING | Double-spaced body (24 pt line boxes at 12 pt); first-line indent. | The exemplar's line pitch (about twice the type size). Not a rule of the VI bankruptcy court; a convention (tier 2). |

Not a rule of this court, and not generated: a page limit (complaints have none in LBR); the ECF header stamp (the court's, added at filing); the adversary cover sheet and summons (separate documents).

## Frontmatter contract

| Field | Required | Feeds |
|---|---|---|
| `division` | yes | Court header: "DIVISION OF ___, BANKRUPTCY DIVISION". |
| `debtor` | yes | `names` (lines) and `designation` ("Debtor.") in the caption. |
| `chapter`, `case_number` | yes | Right column of the caption. |
| `caption` | yes | Two sides, plaintiff then defendant: `names` and `designation`. "v." between them. |
| `adversary` | yes | `number` (the adversary number), optional `note` (e.g. the "all pleadings to be filed in" line). |
| `title` | yes | Title under the caption, in capitals. |
| `footer` | no | Short title for the footer, in capitals. Defaults to `title`; it wraps before the page column (a second line stacks upward, as Word sets a footer). |
| `date` | yes | "Dated:" line. |
| `signature` | yes | Groups: `signer` (optional, printed as `By: /s/ name`) and `lines`. Groups are separated by "- and –". |

Markdown body: each numbered paragraph is a markdown list item (`1. ...`). The template numbers them 1, 2, 3, ... through the whole document (counter, not the typed number), so numbering continues across headings. Sub-items stay inline as (a), (b). Unnumbered paragraphs (the opening paragraph, the prayer) are plain paragraphs. `#` and `##` are centred bold headings, as the sample writes them (PARTIES, PRAYER; the Count headings). Footnotes use `[^n]`. Nested lists are not supported. The body must end with a paragraph: it is kept on one page with the signature block.

## Layout

- Letter paper, 1 in margins, Times New Roman 12 pt. The cross-engine layout model: the body in 24 pt line boxes, single lines (court header, caption, title, signature, footnotes, footer) in 13.8 pt boxes, every space between blocks explicit.
- Court header: two centred bold single lines. Caption (Form 416): two rows, the party column 3.45 in wide, ruled on its right and below each row (0.75 pt), the text 0.2 in off the rule on both sides, 6 pt below a row's top and 10 pt above its rule; designations 0.5 in in from the names; the chapter and case number beside the debtor, the adversary number and its note beside the adversary parties. Title: centred bold capitals, single-spaced, 24 pt below the caption, a blank single line above the text.
- Body: numbered paragraphs (the number at the 0.5 in indent in a 0.5 in box, the text from 1 in; a tab in the docx), unnumbered paragraphs with the 0.5 in first-line indent; headings centred bold on the body pitch with no space of their own, kept with the next block. Footnotes 12 pt single-spaced, 7 pt apart, under a short rule.
- Signature block, 24 pt below the last paragraph and kept on one page with it: "Dated:" at the margin, each counsel group from 3.0 in, a blank single line between the parts and "- and –" between two groups.
- Footer: the short title at the left (wrapping before a 1.3 in page column), "Page n of N" at the right on its last line, the last line ending 0.3 in above the page edge.

## Pages reviewed (Gate 2, 2026-10-22)

All 11 pages of `usage/OUTPUT-adversary-complaint.typst.pdf` and of `usage/OUTPUT-adversary-complaint.docx.pdf`, side by side at 50 dpi; page 1 also beside the filed exemplar's page 1. The two engines set every page alike (XENG-001..003: 318/318 lines, 11/11 pages).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court header, caption, title, opening, PARTIES, ¶¶ 1–2 | OK. Caption rules and columns as the exemplar's Form 416 box; the footer's short title wraps to two lines before "Page 1 of 11". |
| 2 | ¶¶ 2–7, JURISDICTION AND PROCEDURAL BACKGROUND, THE TRANSFERS | OK. |
| 3 | ¶¶ 7–11, footnotes 1 and 2 | OK; the notes under a short rule, 12 pt. |
| 4 | ¶¶ 11–16 | OK. |
| 5 | ¶¶ 16–23, CAUSES OF ACTION, Count One | OK; the two-line count heading kept with ¶ 21. |
| 6 | ¶¶ 24–33, Count Two | OK. |
| 7 | ¶¶ 33–40, Count Three, footnote 3 | OK. |
| 8 | ¶¶ 41–52, Counts Four and Five | OK. |
| 9 | ¶¶ 53–61, Counts Six and Seven | OK. |
| 10 | ¶¶ 62–66, Count Eight, RESERVATION OF RIGHTS | OK. Ends short: the PRAYER heading, its paragraph and the signature block stay together. |
| 11 | PRAYER, signature block (two counsel groups) | OK. |

Open findings (Gate 2):

- VIB-AC-JURIS (rule text, tier 1): the filed exemplar does not state the consent to final orders, and its paragraph 3 does not name the division. The sample adds both sentences, marked `ADDED`, so the sample meets FRBP 7008(a). The exemplar predates the current wording of the rule; the sample follows the current text. The template cannot write these sentences (they are case content), so the author must.
- ACCEPTED (tier 3): the filed exemplar's line breaks, its firm document-ID line in the footer, its underlined headings and its smaller footer type.
- ACCEPTED (tier 3): LibreOffice draws the footnote separator at its own length (typst: 30 % of the measure). Neither engine moves a line or a page for it.

## Known gaps

- One exemplar, one filer. Tier 2 asks for two or three exemplars from different filers. A second VI bankruptcy adversary complaint was not located in this pass (searches: CourtListener RECAP `type=rd`, `court=vib`, queries "adversary complaint", "adversary proceeding", "Amended Complaint"; results were mostly motions and orders, and the other complaint PDFs are not available). Tier 2 is therefore judged against this one filer, and the overlay is a diagnostic only.
- No cover sheet, summons or certificate of service is generated. Those are separate filings; the README of the motion records the service gap for the motion.
- The footer uses the sample's `footer` field, not the title, so a sample with a long title and no `footer` field gets a footer of several lines.
- The complaint has no page-limit check (none in the rules).
- `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have; `tools/check.sh` runs on it (typst and docx, 0 failed).

## Log

- 2026-10-14: exemplar found (CourtListener RECAP, Adv. 09-03071, ECF 35); sample transcribed; template built; render ok (no typst warnings); overlay ok; all 10 pages reviewed.
- 2026-10-22 (fb-595.68.35): typst and docx on the shared cross-engine layout model; `docx/build-reference.sh`, `reference.docx` and `vib.lua` replaced by `docx/reference.xml` and `docx/vib-adversary-complaint.lua`; all 11 pages of both engines reviewed.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary): the reference.
- **docx**: `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 12 pt; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent, single lines and footnotes 13.8 pt, 7 pt after a note; "Numbered Paragraph" with a tab 1 in from the margin, and the "Keep" variants for the last paragraph; pandoc reads CommonMark with smart punctuation and footnotes, as cmarker does) and `docx/vib-adversary-complaint.lua`, which writes the court header, the caption table, the title, the numbered paragraphs (numbers typed from one counter, as typst types them), the headings, the signature block, the footer (a borderless two-cell table: the short title, and "Page" PAGE "of" NUMPAGES; `$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). Footnotes are Word footnotes. `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (318/318 lines, 11/11 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).

[Formbook index](../../../../../../README.md)
