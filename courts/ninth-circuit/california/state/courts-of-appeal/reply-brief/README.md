# California Court of Appeal: appellant's reply brief

Doc type `reply-brief` for the California Courts of Appeal (`court.json` alias `calctapp`). This folder is self-contained. The court-root `typst/` and `usage/` are untouched, and so is the sibling `opening-brief/` folder. Nothing here is a gate stamp: there is no `checks.yaml` for this doc type yet, so no mechanical Gate 0 or Gate 1 has run.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-reply-brief.pdf` | Filed Appellants' Reply Brief, Sixth District, 33 pages, text layer present. Source and filer in `usage/SOURCE.md`. |
| `usage/INPUT-reply-brief.md` | Transcription of a portion of the exemplar: cover, tables, Introduction, the first part of Argument I (with its footnotes), Conclusion, certificate of word count and proof of service. Frontmatter carries the cover, counsel, signature, service and authorities. |
| `usage/OUTPUT-reply-brief.typst.pdf` | `sh tools/render.sh courts/ninth-circuit/california/state/courts-of-appeal/reply-brief usage/INPUT-reply-brief.md`. 14 pages, Times New Roman only (`pdffonts`). `usage/OUTPUT-reply-brief.docx` and `.docx.pdf`: the docx engine, the same 14 pages line for line. |
| `usage/OVERLAY-kirk-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/ninth-circuit/california/state/courts-of-appeal/reply-brief kirk-reply-brief`. Red = ours, blue = filed, black = both. The `.txt` is the page map. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `typst/calctapp-reply-brief.typ` | The template: `calctapp-reply-brief(meta, md)`. Copied from the `opening-brief` template, which is rule-driven and content-agnostic; the reply-specific parts are the metadata and the sample, not the layout. Parameters at the top; each traces to a rule or is a style choice. |

## Governing rules

Verified 2026-10-14 against the courts.ca.gov rule pages (rule 8.204 and rule 8.74, read through a summarizing fetch with excerpts). The wording below is paraphrase of the official text, and a person should confirm the values against the official rule before relying on them.

| Requirement | Source | Value used in the template |
|---|---|---|
| Font style | Rule 8.74(b)(1) (https://courts.ca.gov/cms/rules/index/eight/rule8_74); Rule 8.204(b)(2)-(3) | Quoted 2026-10-15: "The font style must be a proportionally spaced serif face. Century Schoolbook is preferred." The rule allows any proportional serif, so the face is not named. Century Schoolbook is preferred, not required (rules.md CALCTAPP-FORM-002), so the house face, Times New Roman (`font-family`; the docx named EB Garamond until 2026-10-22, fb-595.68.37). |
| Font size | Rule 8.204(b)(4) (https://courts.ca.gov/cms/rules/index/eight/rule8_204); Rule 8.74(b)(1) | 13 pt, including footnotes (`type-size`). Confirmed in both rules. |
| Line spacing | Rule 8.204(b)(5); Rule 8.74(b)(2) | 1.5 spaced: body lines in 22.5 pt boxes (`pitch-body`), one and a half of the 15 pt single line (`pitch-single`). Headings, footnotes and block quotations single-spaced. |
| Margins | Rule 8.204(b)(6); Rule 8.74(b)(3) | Left and right 1.5 in, top and bottom 1 in (`side-margin`, `top-margin`). |
| Alignment | Rule 8.74(b)(4) | Left-aligned, not justified (`justify: false`). |
| Page size | Rule 8.204(b)(1); Rule 8.74(a) | US Letter. |
| Page numbering | Rule 8.204(b)(7); Rule 8.74(a)(2) | Arabic, consecutive from the cover as page 1, so the printed number equals the PDF page. The cover prints no number. |
| Word limit and word-count certificate | Rule 8.204(c)(1) (as fetched) | `word-limit` = 14,000 words, including footnotes. The fetched text applies this one limit to any computer-produced brief and does not state a separate figure for a reply. The certificate's count is computed from the markdown; the wording follows the exemplar. |
| Cover content | Rule 8.204(b)(10) (title, case title, trial court and Court of Appeal numbers, trial judge, party each attorney represents) | Court lines, Court of Appeal case number, trial court, superior court number, judge, title, counsel with State Bar numbers and "Counsel for ...". Cover color (Rule 8.40(a)) applies to paper filings only and is not produced. |
| Searchable PDF, fonts embedded | Rule 8.74(a)(1) | Text is searchable and fonts are embedded (`pdffonts`). |
| Proof of service | Exemplar wording; the governing rule was not confirmed in this pass | Included, in the exemplar's form. |

## Conflicts and choices

- **Word limit for a reply brief.** From memory, a reply brief may be limited to 9,800 words; this is not in the repo and was not confirmed. The fetched text of rule 8.204(c)(1) does not state that figure and applies 14,000 words to any computer-produced brief. The exemplar's certificate says 10,532 words, which is over 9,800 and under 14,000, so the exemplar is consistent with the fetched text. **David should confirm the reply limit against the official rule before a PR cites it.** The template uses 14,000 until that is settled.
- **The exemplar's margins.** The exemplar is from 2022 and was not measured for margins. The template follows the rule text as fetched (1.5 in left and right), the same choice as the `opening-brief` folder.
- **The e-filing stamp.** The exemplar's "Document received by the CA 6th District Court of Appeal" header is not reproduced: it is an e-filing stamp, not part of the brief's text.
- **Font.** Century Schoolbook is the preferred face under Rule 8.74(b)(1), not a required one; the rule allows any proportional serif. Times New Roman, the house standard (2026-10-22). `fonts/tex-gyre-schola/` is vendored and could replace it if David decides the preference should win; not changed here.

## Gate 2: visual review of `usage/OUTPUT-reply-brief.typst.pdf`

Reviewed 2026-10-14 at 60 dpi, every page (15 of 15), against the exemplar pages the overlay pairs them with. Pages were rendered to `/work/artifacts/reply-review/` and read one by one. Re-reviewed 2026-10-16, every page, after the fixes listed at the end; the committed PDF is `4a8049844f8c46a8…`.

| Page | Compared with (exemplar PDF page, by overlay pairing) | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 (cover) | Caption, court lines, Court of Appeal case number, superior court block, title, counsel block and "Counsel for" fit on one page. No stamp. | PASS |
| 2 | exemplar p.2 (TOC) | The entry "I." (the Argument’s first point) used to push its page number "7" onto a line of its own. Fixed 2026-10-16: the page number now sits in its own column, level with the last line of the title. | FIXED |
| 3 | exemplar p.3 (TOA, cases) | Cases group, single-line citations with dot leaders and page numbers. "Pipoly v. Benson" lists 8, 10, 11, 13. | PASS |
| 4 | exemplar p.5 (TOA, statutes) | Only the statutes group is on this page (the two entries spill from page 3). Mostly white space; this is the sample's own pagination, not the exemplar's. | ACCEPTED |
| 5 | exemplar p.7 (Introduction) | Heading centered, first-line indent, 1.5 spacing, the MHMC cite as a table link. | PASS |
| 6 | exemplar p.8 | Introduction continues, ragged right (not justified). | PASS |
| 7 | exemplar p.8 (Argument I heading) | Argument heading centered; point heading I hangs with bold text. | PASS |
| 8 | exemplar p.9 | Body with case names italic; footnote 1 at 13 pt. | PASS |
| 9 | exemplar p.10 | Footnote 2 on the page of its reference; "Id." and "supra" italic. | PASS |
| 10 | exemplar p.11 | Footnote 3 and the bracketed parentheticals. | PASS |
| 11 | exemplar p.11 | The Pipoly block quotation, single-spaced and indented; footnote 4 at 13 pt. | PASS |
| 12 | exemplar p.12 | Continuation of Part I; the nested "[T]he term ‘conflict’..." quotation. | PASS |
| 13 | exemplar p.12 (pairing is weak: 29% word overlap, because the transcribed Conclusion has no counterpart on that filed page) | Conclusion heading centered; signature block with "s/Anna M. Barvir". The sample ends here; the exemplar's Parts II and III are not transcribed. | PASS |
| 14 | exemplar p.32 (word count certificate) | Certificate wording follows the exemplar. The count is the template's count of the sample (2,614 words), not the filed brief's 10,532. | PASS |
| 15 | exemplar p.33 (proof of service) | Parties and methods as in the exemplar: electronic service through TrueFiling for the two counsel, mail for the superior court. | PASS |

Pages reviewed: 15 of 15.

## Known gaps

- **TOC wrap (page 2).** Fixed 2026-10-16; see "Verification pass 2026-10-16" below.
- **Length: 15 pages, one over the 8-14 target.** The statutes group of the table of authorities spills onto page 4. Shortening the TOA by removing a citation from the transcription would pull it back, but would also remove exemplar text, so it was left as is.
- **Partial transcription.** The sample is about 40% of the exemplar's text. The exemplar's Part I continues past page 12, and Parts II and III (pages 16-30) are not transcribed. The footnote 11 and the end of Part III.B.2 are not transcribed either. The table of authorities and the page numbers are the sample's own pagination.
- **Tier 2.** One exemplar only, and the same filer as the `opening-brief` exemplar. Tier 2 cannot be finished until a second filer's reply brief is added.
- **Word count.** The certificate says 2,614 words, which the template counts from the markdown of the sample. It is not a real filing's count.
- **No mechanical gates.** There is no `checks.yaml` and no `check.sh` run for this doc type. Gate 0 and Gate 1 have not been run.

## Exemplar search

- The first pass returned Supreme Court reply briefs (merits) on supreme.courts.ca.gov and self-help pages on selfhelp.appellate.courts.ca.gov: not Court of Appeal filings.
- A second pass returned michellawyers.com's Kirk case page, which lists the Sixth District Appellants' Reply Brief (H048745). That PDF was downloaded and used.
- Not yet searched for a second filer: CourtListener RECAP for the Court of Appeal dockets, the Second and Fourth District case pages, and the Judicial Council's sample reply forms (APP-202 is for limited civil appeals only and is not a brief).

## Engines

Both engines on the shared cross-engine layout model (2026-10-22, fb-595.68.37; `lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 13 pt everywhere, footnotes included; body lines in exact 22.5 pt boxes (450 twips), single lines (cover, headings, quotations, footnotes, tables, signature, certificates) in 15 pt boxes (300 twips); every space between blocks explicit and the same in both. `docx/reference.xml` (`base="xengine"`, `{font}`) holds the styles; `docx/calctapp.lua` (the same filter as the opening brief's) writes the whole document as typst does: the cover with the ruled caption, the table of contents and the table of authorities with page numbers from `fb render`'s needles, the heading labels, the block quotations (one holds a footnote: Block Text Note), footnotes split over a page as typst splits them, the signature block (kept with the last paragraph), the certificate of word count (the same count as typst: 2,614 words on the sample) and the proof of service; the one section numbers the pages from the cover, the cover's number not printed (`titlePg`). `docx/make-reference.sh` and `reference.docx` are gone. `eval.yaml`: `params.cross_engine: gate`; docx XENG-001..003 pass (355/355 lines, 14 = 14 pages). No latex engine in this folder. The sample is transcribed from `FILED-EXAMPLE-reply-brief.pdf`; `FILED-EXAMPLE-reply-brief-2.pdf` (a second filer) has no INPUT.


## Verification pass 2026-10-16 (fb-595.26.16)

- Rendered with `sh tools/render.sh .../reply-brief usage/INPUT-reply-brief.md`: exit 0, no typst warnings, 15 pages (the committed PDF was also 15 pages, so it was not stale). `pdffonts`: EB Garamond Regular, Italic and Bold only.
- Viewed all 15 pages at 60 dpi, and the 15 overlay pages at 40 dpi. Our cover was compared with the exemplar's page 1 (97% word overlap).
- Overlay rerun (`tools/overlay.sh`): pairings unchanged from the table above.
- Fixed, in `typst/calctapp-reply-brief.typ` (the same two fixes as `opening-brief`, whose template this one copies):
  - TOC page numbers (page 2): two-column entry, page number bottom-aligned in its own column (`toc-page-width`). Entry I now ends "... City’s Law / Creates ....... 7".
  - The no-break rule for a section sign and its number now covers "§§" (`[§¶]+ \S+`). No "§§" occurs in this sample, so its pages did not change.
- Word limit: Rule 8.204(c)(1) sets one limit, 14,000 words, for any computer-produced Court of Appeal brief, the reply included. The separate, lower reply limits in the rules apply to the Supreme Court (rule 8.520), not here. The template keeps 14,000. This was not re-fetched in this pass.
- Accepted, not changed: the TOA statutes group alone on page 4 (sample pagination); the cover order differs from the exemplar's (tier 3, as for `opening-brief`).
- Remaining gaps: one exemplar, the same filer as `opening-brief`, so tier 2 cannot be finished; no `checks.yaml`, so Gates 0 and 1 have not run; latex not rendered (no `latex/` in this folder); docx not converted (no `soffice`).
