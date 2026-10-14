# Motion with memorandum of points and authorities (U.S. Bankruptcy Court, D. Hawaii)

Motion to dismiss an adversary complaint, with a consolidated memorandum of points and authorities, in the Typst engine (`typst/`), rendered from one markdown sample (`samples/INPUT-field-rolloffs-motion-brief.md`).

| File | Role |
|---|---|
| `typst/main.typ`, `typst/hib-motion-brief.typ` | Template (entry point and rule-driven layout) |
| `samples/INPUT-field-rolloffs-motion-brief.md` | Markdown input, transcribed from the filed exemplar (frontmatter = caption, counsel, hearing, signature, authorities) |
| `samples/OUTPUT-field-rolloffs-motion-brief.pdf` | Our render (`tools/render.sh`), 12 pages |
| `samples/OVERLAY-field-rolloffs-motion-brief.pdf` / `.txt` | Red (ours) / blue (filed) overlay and page map (`tools/overlay.sh`) |
| `exemplars/FILED-EXAMPLE-field-v-rolloffs-18-90035-motion-brief.pdf` | The filed exemplar (127 ECF pages; memorandum pages 1-106 are ECF pp. 22-127) |
| `exemplars/SOURCE.md` | Filer, case, date filed, URL, date retrieved |

Engines: typst only. No latex or docx engine is delivered for this doc type.

## Rules

Retrieved 2026-10-14. Local rule text was extracted with `pdftotext` from the court's December 1, 2025 compilation (the fetch tool could not read the PDF).

| ID | Requirement | Source (URL; date) |
|---|---|---|
| HIB-FORM-001 | Caption and cover: counsel top left, court name, caption with the bankruptcy case lines, adversary number, title of the paper, and the hearing (date, time, judge) opposite the remaining parties. | FRBP 9004(b): https://www.law.cornell.edu/rules/frbp/rule_9004 (caption contents, Dec. 1, 2024); LBR 9013-1(c)(1) (hearing date and notice "substantially conform to the local form (Notice of Hearing)") |
| HIB-FORM-002 | 14-point type for all memoranda, including footnotes. The template applies 14 pt to the whole motion. | LBR 9004-1(b)(1): https://www.hib.uscourts.gov/sites/hib/files/documents/local-rules/LBR2025_dec01_8001-1_to_9074-1.pdf (Dec. 1, 2025) |
| HIB-FORM-003 | Double spacing, except identification of counsel, title of the case, quotations, footnotes, and exhibits. | LBR 9004-1(b)(2) (same PDF) |
| HIB-FORM-004 | Margins 1 in. from the edge; paper 8.5 x 11 in. | LBR 9004-1(b)(3), (a)(2) (same PDF) |
| HIB-FORM-005 | Counsel identification single-spaced (exempt from double spacing). | LBR 9004-1(b)(2) |
| HIB-FORM-006 | Hearing notice on the caption (date, time, judge). Hearing notice given 28 days before the hearing (LBR 9013-1(c)(1)). | LBR 9013-1(c)(1) (same PDF) |
| HIB-FORM-007 | Signature block (convention; no local rule text on signatures). | Exemplar |
| LBR 9013-2(b) | Briefs and memoranda over 10 pages include a table of contents and a table of authorities. The template renders both (TOC and TOA built from the body headings and the `toa:` links in the markdown). | LBR 9013-2(b) (same PDF) |
| LBR 9013-2(a) | Length: a supporting memorandum may not exceed 25 pages unless the filer certifies it contains no more than 6,250 words (certificate of compliance, LBR 9013-2(a)(4)). | LBR 9013-2(a)(1), (4) (same PDF) |

Procedural references in the sample (Fed. R. Civ. P. 8(a), 9(b), 12(b)(6); Fed. R. Bankr. P. 7008, 7009, 7012) are quoted from the exemplar's authorities, not re-verified against the rules in this pass.

## Tier 1 and tier 2

- Tier 1 (mandated form): 14-point type (memorandum), double spacing, 1-inch margins, 8.5 x 11 paper, caption content, the table of contents and table of authorities (LBR 9013-2(b), rendered although the 8-page sample is under the 10-page trigger).
- Tier 2 (convention): caption layout (the caption runs onto page 2, as the exemplar's does), centered title headings, numbered headings with a hanging indent, footnotes, the TOC and TOA styles, signature block. Judged against one filer only (see gaps).

## What the overlay shows

`samples/OVERLAY-field-rolloffs-motion-brief.pdf` (red = our render, blue = filed exemplar, black = both). Page pairing by text (`OVERLAY-field-rolloffs-motion-brief.txt`):

| Our page | Filed page | Word overlap | Reading |
|---|---|---|---|
| 1 | 1 | 74.7% | Cover: counsel block, court title and caption. Counsel block and caption rule sit at different positions. Tier 2. |
| 2 | 2 | 65.7% | Caption continuation (the "v." and the second party block; the hearing date, time and judge). Tier 2. |
| 3 | 3 | 32.7% | Table of contents (filed p. 3 is the filed TOC). Entry wording and leaders are not identical. Tier 2 and tier 3. |
| 4 | 10 | 18.5% | Table of authorities, paired with the filed TOA, which begins at filed p. 10. The filed TOA covers the full memorandum; ours lists only the authorities cited in the sample. Tier 3 (content). |
| 5-9 | 22-26 | 55.0-87.4% | Memorandum pages 1-5 (preliminary statement and factual background). Filed p. 22 is the first memorandum page. Line pitch differs from the filed Times New Roman (filed text not vertically aligned), so the match is by words, not position. Tier 3 (font and leading). |
| 10-11 | 33-34 | 61.9-67.2% | Argument, pleading standards (Rule 12(b)(6), Twombly, Iqbal). Filed pp. 33-34 are the same section. Tier 3. |
| 12 | 127 | 49.0% | Conclusion and signature. The filed page 127 carries the Conclusion (per `exemplars/SOURCE.md`, the signature is on numbered p. 106 = ECF p. 127). Tier 2 (signature block layout). |

The overlay is diagnostic (tier 3), not a score. Filed pages the sample does not transcribe are not paired.

## Gaps (open)

1. **Certificate of service (LBR 9013-3).** Not in the sample and not rendered. LBR 9013-3(a) requires one unless Rule 7005 governs service and every party served is an ECF user. The exemplar's transcribed pages have none. Open: whether this motion, served on non-ECF parties, needs a certificate block.
2. **Certificate of compliance (LBR 9013-2(a)(4)).** Not rendered. Needed only if the memorandum relies on the word limit rather than the 25-page limit. The 8-page sample is within the page limit.
3. **Abridged transcription.** The filed memorandum is 106 pages; the sample transcribes the caption, TOC, TOA, the preliminary statement, the factual background (with the filed table of counts omitted, as bracketed in the sample), the pleading standards, and the conclusion. The sample is 12 pages (8 of memorandum), within the 8-14 page band.
4. **Type size of the exemplar.** The exemplar (filed 2019) is Times New Roman at roughly 12 pt by the text metrics. It predates the current 14-point rule, so the template follows the current rule (LBR 9004-1(b)(1)) rather than the exemplar, as the exemplar's SOURCE.md notes.
5. **One filer only.** Tier 2 is judged against one exemplar (Dane S. Field, Chapter 7 Trustee, Adv. 18-90035, Dkt. 19). Per `exemplars/SOURCE.md` a second D. Haw. filing was not found in the search. Tier 2 cannot be fully judged; this is stated, not hidden.

[Court README](../README.md)
