# U.S. Court of Appeals for Veterans Claims (cavc): answering brief (Secretary's principal brief)

- Court: `cavc`, United States Court of Appeals for Veterans Claims (`courts/federal-circuit/court-of-veteran-appeals/`)
- Doc type: `answering-brief`, the Secretary's brief (Vet. App. R. 28(b), 32). The appellant's brief is `../opening-brief/`.
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf` (*Fulton v. Wilkie*, Vet. App. No. 19-0320, filed 2019-11-18, VA Office of General Counsel). Provenance in `usage/SOURCE.md`. One exemplar only: see Known gaps.
- Status: typst and docx on the shared cross-engine layout model; docx cross-engine gated (XENG-001..003 PASS, fb-595.54.6); every page reviewed (Gate 2 below). Not reviewed by a human. `court.json` untouched; no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default `usage/INPUT-answering-brief.md`) and calls `cavc-answering-brief`. |
| `typst/cavc-answering-brief.typ` | Template. Same layout code as `../opening-brief/typst/`; `required-sections` is the Rule 28(b) list (summary, argument, conclusion). |
| `usage/INPUT-answering-brief.md` | Markdown sample: frontmatter and a transcribed portion of the brief. |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-veteran-appeals/answering-brief usage/INPUT-answering-brief.md` (12 pages). |
| `usage/OVERLAY-fulton-answering-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-veteran-appeals/answering-brief fulton-answering-brief` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

Names: same as `../opening-brief/README.md`: tool-default names (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`).

## Governing rules

Primary source: Court of Appeals for Veterans Claims, *Rules of Practice and Procedure* (posted 10/01/2026), <https://www.uscourts.cavc.gov/documents/RulesofPracticeandProcedure20261001.pdf>. Downloaded and text-extracted on 2026-10-14. Form 2 and Form 18: Appendix of Forms, <https://www.uscourts.cavc.gov/documents/appendix.pdf>.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Vet. App. R. 28(b)(1) | The Secretary's brief conforms to Rule 28(a), but a statement of the issues or of the case need not be made unless the Secretary is dissatisfied with the appellant's statement | `required-sections` leaves them out; a `# Issue Presented` or `# Statement of the Case` section is accepted and printed in its place |
| R. 28(b)(2)-(3) | The argument includes any agreement with the appellant's assertion of Board error, any independent assertion of material Board error, and the relief the Secretary considers appropriate | body text (the template does not check it) |
| R. 28(a)(1)-(2) | TOC and TOA (the Secretary's brief conforms to 28(a)) | generated TOC and TOA (`toa:` links); `rba` group for record cites |
| R. 28(a)(5) | Argument, beginning with a summary | `required-sections`: "summary of the argument" then "argument" |
| R. 28(a)(6) | Conclusion stating the precise relief | `required-sections`: "conclusion" |
| R. 28(h), (i) | Record citations; superseded or unpublished authorities reproduced in the brief or an appendix | record citations are text; the appendix is not generated (known gap) |
| R. 32(a)-(f) | Same as the opening brief: letter size; one-inch margins; 13-point proportional type, double spaced; caption page; roman and arabic page numbers; principal brief ≤ 30 pages; signature block | as in `../opening-brief/README.md`, Governing rules |
| R. 25(a) | Proof of service with every document | `certificate-of-service` (roman page), drafted wording |
| R. 31(a)(2) | The Secretary's brief due 60 days after service of the appellant's brief | not a layout rule; not generated |
| R. 31(a)(3) | Reply brief, 14 days after the Secretary's brief | not in this template (the reply is a separate doc type, not built) |

Checked and not applicable: no word limit and no certificate of compliance under Rule 32.

## Overlay

`usage/OVERLAY-fulton-answering-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run:

- p.1 ↔ filed p.1 (72%): caption page; p.2 ↔ filed p.2 (58%): TOC; p.3 ↔ filed p.3 (77%): TOA ii; the filed TOA is laid out differently, expected.
- p.4 ↔ filed p.4 (48%): TOA iii, record citations.
- p.5 ↔ filed p.6 (79%): Issue Presented and Statement of the Case.
- p.6-p.10 ↔ filed pp.7, 11, 12, 14, 16 (50-64%): facts, summary, argument, conclusion.
- p.11 ↔ filed p.16 (19%): certificate of service; there is no matching filed page.

## Page review (Gate 2)

Every page of `OUTPUT-answering-brief.typst.pdf` and of `OUTPUT-answering-brief.docx.pdf` was rendered at 60 dpi and viewed (12 of 12 each; fb-595.54.6, after the move to the shared cross-engine layout model). Fonts embedded: Liberation Sans (regular, bold, italic) in both.

| Page | Content | Result |
|---|---|---|
| pdf 1 | Caption page | OK. Vet. App. No., court, caption, "On appeal from the Board of Veterans' Appeals", brief title, counsel; fits one page; unnumbered. |
| i (pdf 2) | TOC | OK. Nested A. and B. under Statement of the Case; I. and II. under Argument; leaders to a 36 pt page column. |
| ii-iii (pdf 3-4) | TOA: cases; statute; record cites | OK. Record cites grouped last; page lists in a 56 pt column. |
| 1-2 (pdf 5-6) | Issue Presented; Statement of the Case, A. and B. | OK. |
| 3 (pdf 7) | Summary of the Argument; Argument; I. Standard of Review | OK. Point heading centered, bold (no small capitals: the engines must set the same glyphs). |
| 4-6 (pdf 8-10) | Argument II | OK. |
| 7 (pdf 11) | Conclusion; signature block; date | OK. The conclusion is kept with the signature block (page 6 ends short). |
| i (pdf 12) | Certificate of service | OK. Roman numeral; the signature in the right half (it sat at the left before: a 50 % pad of an auto-width block). |

Visible changes from the render before fb-595.54.6: body pitch 29.4 pt (was about 26.5 pt), so 12 pages (was 11); headings 16 pt; point headings bold without small capitals; TOC/TOA rows on the shared listing-row (page column, leader from three spaces after the text).

## Engines

| Engine | Folder | Output in `usage/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-answering-brief.typst.pdf` | `check.sh`: 0 failed; Gate 2 above |
| docx | `docx/` | `OUTPUT-answering-brief.docx`, `.docx.pdf` (pandoc, `docx/reference.docx`, `docx/cavc.lua`) | `check.sh --engine docx`: 0 failed, XENG-001..003 PASS (cross-engine gated) |
| latex | none | none | not built |

Both engines run on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`, `lib/docx/xengine-reference.sh`; docs/EVAL-LOOP.md, "Cross-engine gate"): first-fit breaking, no kerning, ligatures or hyphenation, exact line boxes (body 29.4 pt, single 17 pt, section headings 16 pt in 20 pt), explicit block spacings. `eval.yaml` sets `params.cross_engine: gate`: the docx must break every line and page where typst does. Build: `sh docx/make-reference.sh` rebuilds `docx/reference.docx`; `sh tools/render.sh --engine docx <this folder> usage/INPUT-answering-brief.md` renders (fb render runs the page pass: the filter writes needles, the TOC and TOA page numbers come from the LibreOffice PDF of the previous pass).

docx limits: the 30-page limit (R. 32(e)) is checked by the typst template only (the docx breaks its pages alike); the caption page's spacing is estimated from the text length, not measured (its lines break alike, its gaps differ by a few points); Word may paginate slightly differently from LibreOffice (docs/DOCX.md).

## Known gaps

- **One exemplar per doc type.** Tier 2 asks for 2-3 filed exemplars from different filers. Only *Fulton* (Secretary's brief) was found. The Secretary's briefs are filed by VA OGC; a second example from a different Secretary's brief would be the next step.
- **Exemplar age and font.** The exemplar is 2019. Its body size was not verified against the 13-point floor (the font-size read was ambiguous); the template uses 14 pt, which meets the rule without depending on the exemplar.
- **Signature block.** One signer only. The filed brief has four signing counsel (General Counsel, Chief Counsel, Deputy Chief Counsel, Appellate Attorney); the template prints one (the appellate attorney). Multi-signer blocks are not generated.
- **Statement of the issues and of the case.** The template does not require them (Rule 28(b)(1)); the sample uses "Issue Presented", as the filed brief does.
- **Superseded authorities appendix (R. 28(i), 32(d)).** Not generated.
- **Argument and relief (R. 28(b)(2)-(3)).** Not checked by the template: the body must state the Secretary's agreement with Board error and the relief sought.
- **Certificate of service wording.** Drafted; the rules prescribe no form.
- **Sample is an excerpt.** Parts of the Argument of the filed brief are not transcribed; the sample ends at the conclusion.
