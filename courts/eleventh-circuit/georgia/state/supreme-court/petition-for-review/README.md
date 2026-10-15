# Supreme Court of Georgia: petition for certiorari (`petition-for-review`)

Governing rules for a petition for certiorari to the Supreme Court of Georgia (Ga. Sup. Ct. R. 38–45). Verified 2026-10-15 against the official rules PDF below.

## Primary source

- Rules: Supreme Court of Georgia, *Rules of the Supreme Court of the State of Georgia*, effective July 2, 2026, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read from the PDF text (85 pages). The third-party mirrors (state-rules.com, courtrules.net) returned HTTP 403 and were not used for the rule text.
- The brief named "Ga. Sup. Ct. R. 20 et seq." for typeface. That is a mis-cite: the typeface rule is **Rule 16 (Typography)**. Rule 20 is the word and page limit. Rule 20 is used here for limits and the certification only.
- Ga. Ct. App. R. 24 (also named in the brief) governs the Court of Appeals, not this court, and is not used.

## Requirements (IDs used in the template)

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| GA-SC-FONT-001 | Rule 16(1) | Proportionally spaced serif body font; monospaced not allowed; Century family given as an example. | `typst/ga-petition-for-review.typ` (`font-family`) |
| GA-SC-FONT-002 | Rule 16(2) | Body and headings no smaller than 13-pt Century Schoolbook; footnotes no smaller than 11-pt. | `type-size`, `note-size` |
| GA-SC-SPACE-001 | Rule 16(4); Rule 17(2) | Line spacing between 1.2x and double; block quotations, headings, captions and footnotes may be single-spaced. Everything else (body, counsel, signature, service list, TOC) must keep at least 1.2x. | `body-leading` = 0.78 em (measured pitch 19.5 pt = 1.5x at 13 pt). `single-leading` = 0.5 em (measured pitch 15.9 pt = 1.22x), so even the single-spaced parts meet the floor. |
| GA-SC-MARGIN-001 | Rule 16(5); Rule 17(2) | Margins at least one inch, top, bottom and sides. Letter paper: Rule 17(1). | `page-margin` = 1 in |
| GA-SC-ELEC-001 | Rule 17(3) | E-filed documents carry no hyperlinks to other documents or external sites. | `show link: it => it.body` |
| GA-SC-PAGE-001 | Rule 21 | Pages counted toward the limit are numbered sequentially in Arabic numerals. The cover is the only unnumbered page. | `set page(numbering: "1")` after the cover |
| GA-SC-ORDER-001 | Rule 41(2) | The question or questions presented go under a separate heading at the beginning, before the table of contents and the introduction. | `questions-page` (from frontmatter `questions_presented`) |
| GA-SC-LIMIT-001 | Rule 20(3) | Petitions for certiorari are limited to 7,000 words. | **Not enforced by the template** (see gaps). Sample body: 2,447 words. |
| GA-SC-LIMIT-002 | Rule 20(6) | Cover, table of contents, table of citations, certificate of service, signature block and the word-count statement are not counted. | Template layout |
| GA-SC-LIMIT-003 | Rule 20(7) | "This submission does not exceed the word-count limit imposed by Rule 20." immediately above the signature block. | `signature()` (generated; wording exact) |
| GA-SC-FORM-001 | Rule 41(1) | A petition complies with Rules 14–22. Rule 22(2): Georgia citations include the official reporter. | Content (author) |
| GA-SC-FORM-002 | Rule 41(3) | Argument shows why the question meets the Rule 40 standard, not merely that the decision was error. | Content (author) |
| GA-SC-TIME-001 | Rule 38(2) | The petition is filed within 20 days after entry of judgment, or after the disposition of a motion for reconsideration. | Not a layout rule (noted for the author) |
| GA-SC-SERVE-001 | Rule 14 | Service on the other parties. The certificate of service is generated from frontmatter `service`. | `service-certificate()` |

The Rule 41 petition is judged against Rule 41 and Rules 14–22. Rule 19(1)(a) (table of contents and table of authorities for briefs "of significant length") is written for an appellant's brief, so no table of authorities is generated here. See gaps.

## Typeface and substitute

- Rule-named face: Rule 16(1) names the **Century family (e.g., Century Schoolbook)** as permissible, and Rule 16(2) states the size in 13-point Century Schoolbook. The rule does not mandate a single face.
- Substitute (docs/FONTS.md, "Century family, New Century Schoolbook"): **TeX Gyre Schola** (`fonts/tex-gyre-schola/`, GUST Font License), a metric-compatible New Century Schoolbook clone. The template declares `TeX Gyre Schola`. `pdffonts` on the sample shows only `TeXGyreSchola-{Regular,Bold,Italic,BoldItalic}`, all embedded.
- EB Garamond is not used. It appears only in the overlay's red/blue label text, which `tools/overlay.sh` draws itself.

## Markdown contract (sample frontmatter)

| Field | Feeds |
|---|---|
| `case_number` | Top line of the cover |
| `caption` (list of `{names, designation}`) | Caption, two sides, "v." between them |
| `docket` (list of strings) | Right column of the caption, e.g. `CASE NO. A230012` |
| `title` | Cover title (set in capitals) |
| `filed_by` (optional) | Line under the title |
| `counsel` (list of `{names, lines}`) | Counsel block, two groups per row; `lines` in italics only where written with `*...*` |
| `attorneys_for` | Line under the counsel block |
| `questions_presented` (list) | Questions presented page, numbered 1, 2, ... (Rule 41(2)) |
| `date`, `signature` (`signer`, `lines`) | Signature block after the body (with the Rule 20(7) statement above it) |
| `service` (`statement`, `served` as `{names, lines}`, optional `note`) | Certificate of service |

The body is markdown: `#` is a section (centered bold), `##` a sub-section (bold), `###` a sub-sub-section (bold italic). The table of contents is generated from the headings. Footnotes use `[^key]` with `[^key]: text` below. Smart punctuation is on.

## Samples

- `samples/INPUT-dpg-emergency-petition.md`: transcribed from `exemplars/FILED-EXAMPLE-democratic-party-of-georgia-A230012-petition-for-review.pdf`. Frontmatter from the cover, counsel, certificate and signature. Body is an **excerpt**: Introduction; Jurisdiction; Factual and Procedural Background; Enumeration of Errors; Legal Standard; Argument through the first two sub-sections (a, b); the closing "important issues" paragraph; Conclusion. Omitted: Argument sub-sections c–e and the middle of "Plaintiffs' interpretation". Footnote URLs (perma.cc, twitter) are dropped (Rule 17(3)). Footnotes are condensed to their text.
- The filed petition has no Questions Presented page before the TOC (its "Enumeration of Errors" carries the question). The sample adds `questions_presented` from that same question text to satisfy Rule 41(2), so the template's page is a rule-driven addition, not an exemplar copy.
- Render: `samples/OUTPUT-dpg-emergency-petition.pdf`, 12 PDF pages: cover (unnumbered), questions presented (printed 1), TOC (2), body (3–9), Conclusion with the Rule 20(7) statement and signature (10), certificate of service (11).

## Exemplar

- `exemplars/FILED-EXAMPLE-democratic-party-of-georgia-A230012-petition-for-review.pdf`: pages 1–34 of the filed package (exhibits cut). Filed by Intervenors (Georgia Republican Party, NRSC, RNC), Court of Appeals docket A230012; certificate of service dated November 22, 2022. This is an **emergency** petition from an interlocutory superior-court order, not a petition from a Court of Appeals decision. Rule 41 applies to both. Provenance: `exemplars/SOURCE.md`.
- No word-count certificate appears on the filed petition (checked: none of its pages carry Rule 20(7) wording). The template adds it because Rule 20(7) requires it.

## Overlay

`samples/OVERLAY-dpg-emergency-petition.pdf` and `samples/OVERLAY-dpg-emergency-petition.txt` (from `sh tools/overlay.sh`). Red is our render, blue is the filed exemplar page paired by word overlap, black is where they agree. The page map is in the `.txt`. The page map pairs ours p.2 (questions presented) with filed p.13 at 30.6%, which is expected: the filed petition has no questions page before the TOC. Body pages (ours 3–9) pair at 57–78% word overlap. The overlap measures transcription coverage (the sample is an excerpt), not layout. Pages 10–12 (conclusion, certificate) pair at 31–59%, mostly names and addresses.

## Gate 2: page review (Gate 2 record)

Every page of `samples/OUTPUT-dpg-emergency-petition.pdf` was rasterized at 60 dpi and read. Pages 1–12 reviewed (12 of 12).

| Page (PDF) | Printed | Result |
|---|---|---|
| 1 | cover (none) | OK after fix: "IN THE" and "SUPREME COURT OF GEORGIA" now on separate lines; counsel lines show italics, not literal asterisks. |
| 2 | 1 | Questions presented. OK. |
| 3 | 2 | TOC. OK. Entries match the printed page numbers. |
| 4–10 | 3–9 | Body. OK after fixes: first-line indents and paragraph gaps restored; headings single-spaced; no orphaned headings (level-1 headings are sticky). |
| 10 | 9 | "This case presents…" sub-heading and the start of the Conclusion. OK. |
| 11 | 10 | Conclusion, Rule 20(7) statement, signature block, all on one page. OK. |
| 12 | 11 | Certificate of service. OK. |

Defects found and fixed during the review (not present in the final render):
1. Cover: "IN THE" ran into "SUPREME COURT OF GEORGIA" (no paragraph break).
2. Cover: counsel lines printed literal `*` marks (italics were not parsed).
3. Questions presented and TOC were unnumbered; Rule 21 requires Arabic numerals on counted pages.
4. Body paragraphs had no first-line indent and no gap: a later `set par(first-line-indent: 0pt)` leaked into the body (fixed by scoping it to the TOC).
5. Level-1 headings could be stranded at the foot of a page (`block(sticky: true)`).
6. Single-spaced text (counsel, signature, service list, TOC) measured 0.92x (`single-leading` = 0.2 em), under the Rule 16(4) 1.2x floor, and the rule's single-spacing exceptions do not cover it. Raised to 0.5 em (1.22x).
7. Signature block was 3.4 in wide and split the firm address; widened to 4.2 in.

## Gaps (not done here, and why)

- **Word count not enforced.** Rule 20(3) caps the petition at 7,000 words. The template does not count words. The sample body is 2,447 words; the full petition would need a count against the rule (and the Rule 20(6) exclusions) at filing.
- **Table of authorities not generated.** Rule 19(1)(a) is written for appellant's briefs. The filed petition has one; this template does not. Add it if the Court applies Rule 19 to petitions.
- **Certificate of Interested Persons not generated.** Rule 26.1(1) requires it as a separate document at the first filing by a petitioner. It is not part of the petition, so the template does not produce it.
- **Redaction (Rule 17(4)–(5))** is the filer's job: no minors' names, home addresses, or sealed material. Nothing in the template checks this.
- **Excerpt sample.** The body is an excerpt of about 2,450 words, not the whole petition (see the Samples section).
- **Rule 38(2) timing** (20 days) is not a layout requirement and is not checked.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (conda-forge)
sh tools/render.sh courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review samples/INPUT-dpg-emergency-petition.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review dpg-emergency-petition
```

The render fails on any typst warning and on any font outside the vendored set (`--ignore-system-fonts`).

## Engines

Typst is the primary engine (above). The DOCX engine is `docx/`, the same files as `motion-brief/docx/`: `build-reference.sh` writes `reference.docx`; `ga-motion.lua` builds the cover, the questions presented (Rule 41(2), before the TOC), the TOC, closing and certificate; `render.sh` makes two renders so the TOC numbers come from the docx's own layout. Render with `sh tools/render.sh --engine docx <this folder> samples/INPUT-dpg-emergency-petition.md`: `samples/OUTPUT-dpg-emergency-petition.docx` and `.docx.pdf` (LibreOffice 26.8.1).

| | docx | typst |
|---|---|---|
| Pages | 12 | 12 |
| Font | TeX Gyre Schola only | TeX Gyre Schola only |
| Line pitch | 19.5 pt; 7.8 pt after paragraphs | same |
| Questions presented | hanging indent, page 1 | same |
| Cover | same layout | same |
| TOC | numbers equal the typst output on all twelve entries | same |
| Closing | the signature kept on one page | same |
| Certificate | same; recipients in two columns, the third and later wrapping | same |

Checked: every page of `OUTPUT-dpg-emergency-petition.docx.pdf` was rendered (60 dpi) and set beside the typst page; line positions were measured with `pdftotext -bbox`.

What differs:

- **Caption.** The close-parenthesis column and the docket are top-aligned in the table, as in the motion (typst centres them).
- Run-in spacing and Word: see motion-brief.

BLOCKED: none.
