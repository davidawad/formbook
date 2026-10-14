# U.S. Air Force Court of Criminal Appeals (AFCCA): answering brief (Government answer to assignments of error)

- Court: `afcca`, U.S. Air Force Court of Criminal Appeals (`courts/military/air-force-court-of-criminal-appeals/`)
- Doc type: `answering-brief`. The United States' answer to the appellant's assignments of error (AFCCA Rule 18.3: "Answer briefs ... will follow the same format as assignments of error and respond separately to each assigned error"). One self-contained folder; no shared files.
- Exemplars: two, from the same two filer pairs as the opening-brief folder (`exemplars/SOURCE.md`):
  - `FILED-EXAMPLE-douglas-40324-answering-brief.pdf` (*United States v. Douglas*, ACM 40324 (f rev), 3 June 2024, Government Trial and Appellate Operations Division, signed by Mary Ellen Payne). The whole answer. Primary: the overlay defaults to it.
  - `FILED-EXAMPLE-howard-40478-answering-brief.pdf` (*United States v. Howard*, ACM 40478 (f rev), 29 October 2024, GTAOD: G. Matt Osborn, Mary Ellen Payne, Matthew D. Talcott). The cover, index, table of authorities, issues presented and start of the statement of the case.
- Samples: `samples/INPUT-douglas-answering-brief.md` (full transcription, 10 pages rendered) and `samples/INPUT-howard-answering-brief.md` (excerpt, 3 pages rendered; `excerpt: true`).
- Status: template built; render, overlay and page review done for both samples (below). Fonts pass, 2026-10-14: the typeface stays EB Garamond (Known gaps, 1); both renders and both overlays re-run; every page re-viewed. The `FILED-EXAMPLE-*.pdf` files named above are not in this snapshot, so the overlays were run against extracts of the page ranges `exemplars/SOURCE.md` cites, fetched from the URLs there and kept outside the repo. Not reviewed by a human. `court.json` and the court root are untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `afcca-brief`. |
| `typst/afcca-answering-brief.typ` | Template. Identical to `opening-brief/typst/afcca-opening-brief.typ` except `doc-kind = "answering-brief"`. The prayer check (WHEREFORE) applies only to `opening-brief`. |
| `samples/INPUT-douglas-answering-brief.md` | Full transcription of the Douglas answer. |
| `samples/INPUT-howard-answering-brief.md` | Excerpt of the Howard answer: counsel block, issues presented, start of the statement of the case. |
| `samples/OUTPUT-<id>.pdf` | `sh tools/render.sh courts/military/air-force-court-of-criminal-appeals/answering-brief samples/<id>.md` |
| `samples/OVERLAY-<id>.pdf`, `OVERLAY-<id>.txt` | `sh tools/overlay.sh courts/military/air-force-court-of-criminal-appeals/answering-brief <id> [exemplar.pdf]` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The two filed exemplars and `SOURCE.md`. |

The Howard overlay is run against its own exemplar (passed explicitly) because the tool's default is the first file in the folder.

## Governing rules

Primary source: *United States Air Force Court of Criminal Appeals Rules of Practice and Procedure*, effective 29 June 2026 (published with the Joint Rules of Appellate Procedure), <https://afcca.law.af.mil/afcca_data/cp/afcca_rules_of_practice_and_procedure_wjrap_29_jun_2026_2888395.pdf>. Downloaded and read on 2026-10-14; page numbers are the rules' printed pages.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| AFCCA R. 18.3 (p. 23) | Answer briefs follow the same format as assignments of error and respond separately to each assigned error; answers may adopt the appellant's statement of the case and add facts | `required-sections` (issues presented or assignments of error; statement of the case; argument) in order; `Issues Presented` is the answer's heading for the assignments |
| AFCCA R. 17.1(a) (p. 18) | 12-point proportional type; double-spaced; one side of 8.5 × 11; margins at least one inch | `type-size = 12pt`, `body-leading`, `page-margin = 1in`. Typeface: no face is required (the rule's Times New Roman and Century Schoolbook are examples, "e.g."; any proportional type is allowed), so the template keeps EB Garamond, the vendored default (Known gaps, 1). |
| AFCCA R. 17.3 (p. 20) | 50-page limit, excluding indices, attachments and appendices | `page-limit = 50`, the end-of-brief check |
| AFCCA R. 18.1 (p. 22) | Subject index and table of authorities for briefs over 30 pages | `index: true` draws the TOC and the TOA; the check panics over 30 pages without it |
| AFCCA R. 17.1(b)-(f), 17.2(c) (pp. 18-19) | E-filing wrapper, PII redaction | Outside the document (see Known gaps) |
| App. A (pp. 46-47) | Caption, "TO THE HONORABLE" line, sections, signature block, certificate | Caption page, body line, `signature` and `certificate` frontmatter. The standard-of-review check applies to answers too (App. A's argument rule). The prayer check does not apply to answers: the rules require one for the appellant's argument, and the Douglas and Howard answers have none. |

The standard-of-review check is the text heuristic "the body contains 'standard of review'". It proves the words are there, not that each assignment of error is answered.

## Overlay

Pages are paired by word overlap, not by index (the tool's map is in `samples/OVERLAY-<id>.txt`).

`samples/OVERLAY-douglas-answering-brief.pdf` (10 pages, against the Douglas exemplar, the default): p.1-6 ↔ filed p.1-6 (47-91%): caption, issues, facts, the argument's first pages (the argument is the densest text, and line breaks differ); p.7 ↔ filed p.8 (62%), p.8 ↔ filed p.9 (54%), p.9 ↔ filed p.10 (64%): point II, the Lepore discussion; p.10 ↔ filed p.12 (37%): the last page, the signature block (the filing's last page 12 is the signature; the overlay pairs by words, and this page has few).

`samples/OVERLAY-howard-answering-brief.pdf` (3 pages, against the Howard exemplar, passed explicitly): p.1 ↔ filed p.1 (cover, 75%); p.2 ↔ filed p.11 (61%: the issues presented list); p.3 ↔ filed p.12 (80%: the start of the statement of the case, Articles 90 and 91).

Diagnostic only, not a score. Reading the Howard exemplar makes poppler print "xref" warnings (broken cross-reference entries in the source); the renders are unaffected.

## Page review (Gate 2)

Every page of both `OUTPUT-*.pdf` files was rendered at 60 dpi and viewed. Typst printed no warnings. Fonts embedded: EB Garamond only. Re-checked in the fonts pass on 2026-10-14: the render and the page count (10 and 3) are unchanged; every page was re-rendered at 70 dpi and viewed, and the OK/ACCEPTED rows below still hold.

**`douglas-answering-brief`, 10 of 10 pages:**

| Page | Content | Result |
|---|---|---|
| 1 | Caption; TO THE HONORABLE; issues presented I–II; statement of the case; start of the statement of facts | OK |
| 2 | Statement of facts (continued); footnote 1 (the corrected EOJ) | OK |
| 3 | Argument heading I; additional facts | OK |
| 4 | Standard of review; law and analysis; sub-heading A (numbered by the template); footnote 2 (DAFI 51-201) | OK. A and B are numbered by the template; the sample types no numerals. |
| 5 | Block quotation from *Brooks*; sub-heading A continued | OK |
| 6 | A continued; sub-heading B (prejudice) | OK |
| 7 | Argument heading II; standard of review; law and analysis; sub-heading A | OK |
| 8 | Sub-heading A continued; sub-heading B (collateral matter); footnote 3 | OK |
| 9 | Sub-heading B continued (Lepore; Appellant's argument) | OK |
| 10 | The last paragraph as filed ("Relying entirely on a"); signature block | ACCEPTED: the filed text ends on this word, before the signature. The transcription keeps it (see `exemplars/SOURCE.md`). |

**`howard-answering-brief`, 3 of 3 pages:**

| Page | Content | Result |
|---|---|---|
| 1 | Caption; counsel block (three counsel groups); TO THE HONORABLE; issue I | OK. The counsel block is centered above the TO THE HONORABLE line. |
| 2 | Issues II–VII; statement of the case; Article 89 | OK |
| 3 | Articles 90 and 91; the second specification | ACCEPTED: sample limit (`excerpt: true`); the filed answer continues |

Tier-2 findings (OPEN or ACCEPTED): typeface (see Known gaps); the excerpt sample does not carry the answer's argument, so the sample does not test a full argument's pagination.

## Known gaps

1. **Typeface.** The same as the opening-brief folder: R. 17.1(a) asks for proportional 12-point type, with Times New Roman and Century Schoolbook as examples ("e.g."), and allows any proportional type, so no court-named face is required; the template keeps EB Garamond at 12 pt. The metric-compatible Times New Roman substitute is Liberation Serif (`fonts/liberation-serif/`); switching is one line, `font-family` in `typst/afcca-answering-brief.typ`, and is not made here. EB Garamond reads smaller than the filing's faces; this is a tier-2 point.
2. **Each assignment answered (R. 18.3).** The template checks the section order and the standard of review, not that each assignment of error has its own answer. A reviewer must check that.
3. **E-filing wrapper (R. 17.1(b)-(d)).** The subject line, the narrative block and the PDF naming are not generated.
4. **Index is authored, not computed.** The same as the opening-brief folder: `index: true` draws the TOC and TOA; the check panics over 30 pages without it; a body under 30 pages with an index is not detected as a mismatch.
5. **TOA is built from links, not detected.** Every citation the answer lists must be a `toa:KEY` link with an `authorities:` entry.
6. **Excerpt samples.** `excerpt: true` (Howard) skips the required-section and standard-of-review checks. A complete answer must not set it.
7. **Grostefon (R. 18.2).** An answer to a Grostefon issue is not covered by a separate template; the Howard answer excerpt has no such appendix.
8. **Caption and counsel.** The caption grid aligns the ")" column with the caption's left-hand lines. A long title on the right wraps on its own. The counsel block is printed on the caption page when given; Appendix A does not call for one.
