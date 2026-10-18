# U.S. Court of Appeals for Veterans Claims (cavc): answering brief (Secretary's principal brief)

- Court: `cavc`, United States Court of Appeals for Veterans Claims (`courts/federal-circuit/court-of-veteran-appeals/`)
- Doc type: `answering-brief`, the Secretary's brief (Vet. App. R. 28(b), 32). The appellant's brief is `../opening-brief/`.
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf` (*Fulton v. Wilkie*, Vet. App. No. 19-0320, filed 2019-11-18, VA Office of General Counsel). Provenance in `usage/SOURCE.md`. One exemplar only: see Known gaps.
- Status: template built, rendered, overlay generated, every page reviewed (Gate 2 below). Not reviewed by a human. `court.json` untouched; no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default `usage/INPUT-answering-brief.md`) and calls `cavc-answering-brief`. |
| `typst/cavc-answering-brief.typ` | Template. Same layout code as `../opening-brief/typst/`; `required-sections` is the Rule 28(b) list (summary, argument, conclusion). |
| `usage/INPUT-answering-brief.md` | Markdown sample: frontmatter and a transcribed portion of the brief. |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-veteran-appeals/answering-brief usage/INPUT-answering-brief.md` (11 pages). |
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

Every page of `OUTPUT-answering-brief.typst.pdf` was rendered at 60 dpi and viewed (11 of 11). Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| i (pdf 1) | Caption page | OK. Vet. App. No., court, caption, "On appeal from the Board of Veterans' Appeals", "Brief of Appellee Secretary of Veterans Affairs", counsel; fits one page; unnumbered. |
| i (pdf 2) | TOC | OK. Nested A. and B. under Statement of the Case; I. and II. under Argument. |
| ii-iii (pdf 3-4) | TOA: cases; statute; record cites | OK. Record cites grouped; page numbers update with the layout (checked after the last change). |
| 1 (pdf 5) | Issue Presented; Statement of the Case, Nature of the Case | OK. |
| 2 (pdf 6) | Statement of Facts and Procedural History; Summary of the Argument begins | OK. |
| 3 (pdf 7) | Summary (end); Argument; I. Standard of Review; II. begins | OK. Point heading centered, small caps. |
| 4 (pdf 8) | Argument II; First and Second points | OK. |
| 5 (pdf 9) | Third and Fourth points | OK. |
| 6 (pdf 10) | Conclusion; signature block; date | OK. The conclusion and signature are on one page. |
| i (pdf 11) | Certificate of service | OK. Roman numeral; drafted wording (see Governing rules). |

## Engines

| Engine | Folder | Output in `usage/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-answering-brief.typst.pdf` | rendered; Gate 2 above |
| docx | `docx/` | `OUTPUT-answering-brief.docx` (pandoc, `docx/reference.docx`, `docx/cavc.lua`) | `.docx` written; `.docx.pdf` not produced (BLOCKED, below) |
| latex | `—` | none | not built |

Build: `sh docx/make-reference.sh` regenerates `docx/reference.docx` from pandoc's default reference; `sh tools/render.sh --engine docx courts/federal-circuit/court-of-veteran-appeals/answering-brief usage/INPUT-answering-brief.md` writes the `.docx`. No `checks.yaml` exists for this court yet. `tools/check.sh --engine docx` exits 2 here (no `court.json` in the doc-type folder, and no `yq` on this box), so no gate ran on either engine.

**docx matches the typst template:**

- Letter page, 1-inch margins; EB Garamond 14 pt (the font named in the styles, not embedded); body double-spaced (exact 31.45 pt) with a half-inch first-line indent; block quotations and footnotes single-spaced at 14 pt.
- Caption page with Form 2's contents (Vet. App. No., court, caption, proceeding, brief title, counsel, telephone), with no page number.
- Contents and authorities in lower roman from i; the body in arabic from 1; the certificate of service in lower roman from i (section breaks carry `w:pgNumType`).
- Rule 28 labels and indents: in the Argument, point headings (`I.`, `II.`) centered in small capitals and sub-headings `A.`, `1.`, `a.`; elsewhere `A.`, `1.`, `a.`, `(1)`. Levels 4 and below are bold italic, as in the typst template.
- Table of authorities groups in the typst order (cases, statutes, regulations, rules, other authorities, record citations).
- The signature block is kept with the last paragraph of the brief (`keepNext`).
- The level-1 sections required by Rule 28 are checked; the build fails when one is missing or out of order, as the typst template does.

**docx differs from the typst template:**

- The table of contents and the table of authorities have no page numbers. Typst measures them. The docx engine has no pagination pass, so both are static text (not Word fields) and show the entries without page numbers.
- The caption rules are paragraph borders, and the caption's spacing is set by hand; the typst template fits the caption to one page by measurement. Whether it fits one page has not been checked.
- Word and LibreOffice paginate differently from each other; no page-based property is asserted for docx.

**docx BLOCKED (delivered partial):**

- `docx.pdf` gates (Gates 0 to 3 and the page review) are BLOCKED. `soffice --headless --convert-to pdf` segfaults at startup on the box where this was built (exit 139), after LibreOffice 25.2.3 and its runtime packages were unpacked from Debian trixie without root; no debugger was available. No `.docx.pdf` was produced, so no page was rendered or reviewed (`pages_reviewed=0`).
- R. 28(a)(1)-(2), the table of contents and table of authorities with page references: not generated for docx.
- R. 32(e), the 30-page limit: not checked for docx (the typst template checks it).
- The `.docx` passed the render script's integrity check (a valid zip, every XML part well formed). It has not been opened in Word or LibreOffice, and no font check has been run on it.

## Known gaps

- **One exemplar per doc type.** Tier 2 asks for 2-3 filed exemplars from different filers. Only *Fulton* (Secretary's brief) was found. The Secretary's briefs are filed by VA OGC; a second example from a different Secretary's brief would be the next step.
- **Exemplar age and font.** The exemplar is 2019. Its body size was not verified against the 13-point floor (the font-size read was ambiguous); the template uses 14 pt, which meets the rule without depending on the exemplar.
- **Signature block.** One signer only. The filed brief has four signing counsel (General Counsel, Chief Counsel, Deputy Chief Counsel, Appellate Attorney); the template prints one (the appellate attorney). Multi-signer blocks are not generated.
- **Statement of the issues and of the case.** The template does not require them (Rule 28(b)(1)); the sample uses "Issue Presented", as the filed brief does.
- **Superseded authorities appendix (R. 28(i), 32(d)).** Not generated.
- **Argument and relief (R. 28(b)(2)-(3)).** Not checked by the template: the body must state the Secretary's agreement with Board error and the relief sought.
- **Certificate of service wording.** Drafted; the rules prescribe no form.
- **Sample is an excerpt.** Parts of the Argument of the filed brief are not transcribed; the sample ends at the conclusion.
