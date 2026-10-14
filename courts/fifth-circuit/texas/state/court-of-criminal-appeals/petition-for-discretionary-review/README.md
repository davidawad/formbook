# Petition for discretionary review

## Governing rules

Rules checked October 14, 2026. The official [Texas Rules of Appellate Procedure](https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf) returned HTTP 403 to the fetcher, so the Rule 9.4 typeface and spacing wording below was confirmed from secondary summaries of the rule. Check it against the official text before relying on this template.

- **TRAP 9.4(b)–(e), (g), (i), (j) (mandated):** 8.5 by 11 inch page; one-inch margins; double-spaced text, with stated exceptions (footnotes, block quotations, short lists, and issues or points of error may be single-spaced); conventional computer type no smaller than 14 point and footnotes no smaller than 12 point; cover contents; 4,500-word maximum for a computer-generated petition (excluding the items listed in 9.4(i)(1)); word-count certificate; text-searchable unlocked PDF for e-filing.
- **TRAP 9.5 (mandated):** serve each party and include proof of service.
- **TRAP 68.3–68.4 (mandated):** file with the Court of Criminal Appeals; include identity of judge, parties, and counsel; table of contents; alphabetical index of authorities; oral-argument statement; case statement; procedural history; numbered grounds or concise questions; direct concise argument; prayer; and the court of appeals opinion in the appendix.
- **TRAP 68.6 (mandated):** a nonconforming or unnecessarily lengthy petition may be struck, redrawn, or refused.

## Markdown contract and template

The markdown file begins with YAML frontmatter: `case_number`, `style_petitioner`, `style_respondent`, `filing_party`, `brief_title`, `appeal_from`, `lead_counsel`, `counsel_lines`, and optional `filed_date`. The body supplies the document-specific required sections and text, including tables, signature, certificate of compliance, and proof of service.

The template builds the cover and renders markdown with vendored cmarker. Body text is 14-point, double-spaced (leading calibrated to a 32.2 pt baseline pitch in EB Garamond). Headings, signature and address blocks (hard line breaks), and table-of-contents or index entries (dot leaders) are single-spaced; short single-spaced blocks do not break across pages. Footnotes are written `[^1]` with a `[^1]: text` definition, rendered at 12 point. The template does not create a table of contents or authorities.

Build from the repository root:

```sh
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/petition-for-discretionary-review samples/INPUT-ukw-pdr.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/petition-for-discretionary-review ukw-pdr
```

## Exemplar

`exemplars/FILED-EXAMPLE-ukwUachu-pd0366-17-pdr.pdf` is the State's petition in *State v. Ukwuachu*, PD-0366-17 (33 pages), retrieved October 14, 2026 (see `exemplars/SOURCE.md`). Its body text is single-spaced (16.1 pt baseline pitch), which departs from the double-spacing rule above. The template follows the rule (tier 1), not the exemplar.

This is one filer. Tier 2 calls for two or three filings from different filers, and none was found in this pass.

## Sample and overlay

`samples/INPUT-ukw-pdr.md` is a transcription of an excerpt of the exemplar: the cover, names of parties, table of contents, index of authorities, oral-argument and case statements, grounds, the factual overview, the opening of Issue One, the prayer, and both certificates. Pages 14 to 21 of the argument are omitted. The render is 11 pages (cover unnumbered, then pages 1 to 10).

The red/blue overlay is `samples/OVERLAY-ukw-pdr.pdf`; its page map is `samples/OVERLAY-ukw-pdr.txt`.

## Page review

Every page of `samples/OUTPUT-ukw-pdr.pdf` (11 pages) was rendered at 100 dpi and viewed on October 14, 2026, after the final render. Footer numbers are shown; the cover has none.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| cover | exemplar p.1 | Caption, title, counsel, and date fit on one page. Apostrophe in the title set as a typographic one. | FIXED |
| 1 | exemplar p.2–3 | Names of parties and table of contents. Contents entries were indented after the first; now flush with dot leaders. | FIXED |
| 2 | exemplar p.3–5 | Index of authorities, single-spaced and flush. Oral-argument heading and double-spaced text. | PASS |
| 3 | exemplar p.5–6 | Statement of the case and procedural history, centered headings, double spacing. | PASS |
| 4 | exemplar p.7 | Grounds for review (numbered list) and start of the factual overview. | PASS |
| 5 | exemplar p.8–9 | Factual overview, typographic quotes, first-line indents. | PASS |
| 6 | exemplar p.9–10 | Factual overview. | PASS |
| 7 | exemplar p.11–12 | Factual overview. | PASS |
| 8 | exemplar p.13 | Issue One heading: two-line bold heading was overlapping; now single-spaced with a gap before the body. | FIXED |
| 9 | exemplar p.22 | Prayer and signature block single-spaced, moved together; certificate of compliance. | FIXED |
| 10 | exemplar p.23 | Certificate of service; addresses single-spaced. | FIXED |

## Known gaps

- One filed exemplar, not two or three from different filers.
- The exemplar is single-spaced; the template follows TRAP 9.4(d) as summarized above.
- Tables of contents and authorities are author-supplied markdown. Their page numbers are copied from the exemplar and do not match this excerpt.
- The certificate of compliance's word count (3,053) is the exemplar's figure. It is not a count of this excerpt and does not verify the 4,500-word limit.
- The template does not calculate word limits, verify service recipients, attach the court of appeals opinion, create bookmarks, or check every Rule 68.4 section.
- The sample is an excerpt, not the complete petition or appendix. No engine other than typst was run, and no automated rule-check suite (`checks.yaml`) exists for this folder.

[Formbook index](../../../../../../README.md)
