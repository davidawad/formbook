# Court of Appeals of Georgia (`gactapp`): appellant's brief (`opening-brief`)

**BLOCKED: no exemplar.** No filed Georgia Court of Appeals appellant's brief was found (searches below). The template and a fictional sample were built from the rules as found; the rule text itself could not be read from a primary source on this box, so every rule-derived value below is provisional.

## Status of each output

| Item | Result |
|---|---|
| `exemplars/` | empty: no real filing found (`exemplars/SOURCE.md`) |
| `samples/INPUT-fictional-opening-brief.md` | fictional sample, rule-driven, not a transcription |
| render (`tools/render.sh`) | ok: `samples/OUTPUT-fictional-opening-brief.pdf`, 7 pages, exit 0, zero typst warnings, Liberation Serif embedded (LiberationSerif, -Bold, -Italic, -BoldItalic) |
| overlay (`tools/overlay.sh`) | fail: no exemplar PDF to overlay (`no exemplar pdf in .../exemplars`, exit 1) |
| pages reviewed | 7 of 7 (final render, every page viewed at 60 dpi) |

The tool's default output name is `OUTPUT-<id>.pdf`, not `<id>.pdf`; the repo's tools read and write those names.

## Governing rules

Rule text status: **not verified against the rule itself.** `gaappeals.gov`, `state-rules.com`, `courtrules.net` and `efast.gaappeals.us` all returned HTTP 403, 404 or a JavaScript shell to this box (2026-10-15). The points below come from search-engine summaries of those pages, marked secondhand.

| Requirement | Value in template | Source and status |
|---|---|---|
| Typeface | serif, proportional, 14-point or larger | Ga. Ct. App. R. 2(3), as summarized from the gaappeals.gov rules page: "computer-generated documents" must use a serif, proportionally spaced face of 14 pt or larger; Times New Roman and Century Schoolbook are listed as compliant examples; sans-serif allowed in headings and captions; monospaced faces (Courier) excluded. **Secondhand; not read from the rule.** |
| Rule-named face | Times New Roman and Century Schoolbook are examples, not a single mandated face (per the summary) | If the primary text names one face only, change the substitute. |
| Substitute | **Liberation Serif** (`docs/FONTS.md`, the Times New Roman row; metric-compatible) | Chosen because the summary's first example is Times New Roman. Century Schoolbook would map to TeX Gyre Schola (not used). |
| Size | 14 pt body, footnotes not used; headings 14 pt bold | Ga. Ct. App. R. 2(3) (secondhand). |
| Spacing | body leading 1.1 em (baseline pitch about 2.2 x type size, measured on the render); headings, block quotations and the cover single-spaced (0.45 em) | Older Georgia rule set (2010, secondhand) required double-spacing "including quotations and footnotes". **Conflict:** the template single-spaces block quotations. Open item. |
| Margins | 1 inch all sides | Convention; not checked against the rule. |
| Paper | US Letter | Convention. |
| Length | not enforced | Rule 24 word limit, secondhand: 8,400 words for civil briefs, 14,000 criminal (summaries disagree on the amendment date: Oct 9, 2025 vs 2017). Word-count certification just above the signature block (secondhand). **Not generated.** |
| Required sections | Table of contents (generated), Statement of Jurisdiction, Enumeration of Errors, Statement of the Case, Statement of Facts, Argument and Citation of Authority, Conclusion | Ga. Ct. App. R. 25 (appellant's brief): secondhand says a 2017 revision lists seven items, four mandatory; the list was not retrieved. The sample uses the heading set above, which matches a 2007 Clerk's seminar paper (Enumeration of Errors as Part II) and is not verified against the current rule. |
| Rule number | Ga. Ct. App. R. 22 to 25 (brief rules: 22 not found; 23 appellee; 24 form and length; 25 contents) | Index by search summary; Rule 22 text not found. |

Date verified: **not verified** (no primary text read). Date of this README: 2026-10-15.

## Template

- `typst/main.typ` reads the sample (`--input sample=...`), splits the frontmatter, and calls `gactapp-brief`.
- `typst/gactapp-opening-brief.typ`: cover (court line, case number, two-sided caption, proceeding line, title, counsel block), table of contents (typst `outline` from level 1 and 2 headings), body (markdown via cmarker), signature block after the body.
- No case-specific text, no measured coordinates, no forced line breaks, no system fonts. The only fixed text is the court name on the cover, which is the court's name.

## Markdown contract

Frontmatter: `case_number`, `caption` (two sides: `names`, `designation`), `proceeding`, `trial_court_case` (optional), `brief_title`, `counsel` (groups with `names` and `lines`), `phone`, `signature` (`signer`, `lines`), `date` (optional). Body: `#` level 1 is a section (centred, capitals, bold); `##` and `###` are sub-headings. Block quotations with `>`. Escape a leading `1.`, `-`, `#` in text with a backslash.

## Known gaps

1. Rule text unverified (see above). The face, size and spacing are the reading of a secondhand summary.
2. No exemplar. The sample is invented; its length (7 pages: cover, contents, 5 body) is below the 8-14 page target, which cannot be checked without a real filing's length.
3. Not generated: table of citations, certificate of word count, certificate of service, word limit check.
4. The signature block is kept with the body by `block(breakable: false)` only. If the Conclusion falls at the foot of a page the signature can start a new page alone. The fictional sample was trimmed to avoid it; a real brief may not be.
5. Block quotations are single-spaced (conflict with the 2010 summary: see Spacing).
6. Paragraphs after the first in an escaped numbered list are indented (typst indents paragraphs that follow paragraphs). Not checked against a filing.
7. Contents entries are set tightly, with no spacing between them.

## Searches tried (2026-10-15)

- Official rules: gaappeals.gov `?p=1073`, `?p=3817`, the 2025 consolidated rules PDF (`COA-Rules-Complete-Eff-9-Oct-2025.pdf`): all HTTP 403 to WebFetch and curl.
- state-rules.com Georgia appellate rules 22-25: JavaScript shell, no rule text.
- courtrules.net Georgia Court of Appeals page: HTTP 403.
- efast.gaappeals.us 2009 and 2010 court rule PDFs: HTTP 404 / blocked.
- Web search (standard and extended): typeface, Rule 24, Rules 22/23/25. Snippets only; one source for Rule 2(3).
- Exemplar: CourtListener REST search for "Court of Appeals of Georgia" with "brief of appellant": 10 results, none a Georgia Court of Appeals brief (N.D. Ga., S.D. Ga., M.D. Ga., 11th Cir., D. Del., etc.). Web search for public Georgia Court of Appeals brief PDFs: only efast seminar papers and a 2025 clerk's order.
