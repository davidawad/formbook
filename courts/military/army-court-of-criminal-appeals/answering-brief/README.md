# U.S. Army Court of Criminal Appeals (acca): answering brief (brief on behalf of the appellee)

- Court: `acca`, U.S. Army Court of Criminal Appeals (`courts/military/army-court-of-criminal-appeals/`)
- Doc type: `answering-brief`. The United States' answer to the appellant's assignments of error. ACCA Rule 17.1(a): pleadings "raising or addressing" an assignment of error follow Rule 13 and Appendix A, so the answer uses the Appendix A form with the appellee's title.
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf`, an 11-page extract of *United States v. Akbar*, Army Dkt. 20050514, Brief on Behalf of Appellee, filed 29 November 2010 by the Government Appellate Division (source, page map: `usage/SOURCE.md`). Found on the fourth search pass (2026-10-16, bead fb-595.20.20).
- Samples: `usage/INPUT-answering-brief.md` (transcription of the extract); `usage/INPUT-answering-brief-2.md` (FICTIONAL fixture, kept).
- Template: `typst/acca-answering-brief.typ` (entry `typst/main.typ`). Same as `../opening-brief/typst/acca-opening-brief.typ` except the title ("BRIEF ON BEHALF OF APPELLEE", as the filer titles it) and the default certificate recipient (the Defense Appellate Division).
- Status (2026-10-16): rule text retrieved and applied. Render ok (11 pages), overlay ok, every page reviewed. `tools/check.sh` not run (no `checks.yaml`). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ`, `typst/acca-answering-brief.typ` | Entry point and template. |
| `usage/INPUT-answering-brief.md` | Transcription of the extract (caption page, brief pp. 1-7, 216-218). Names the filer blacked out are written `[redacted]`. |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/military/army-court-of-criminal-appeals/answering-brief usage/INPUT-answering-brief.md` (11 pages). |
| `usage/OVERLAY-answering-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/military/army-court-of-criminal-appeals/answering-brief akbar-answering-brief`. |
| `usage/INPUT-answering-brief-2.md`, `OUTPUT-answering-brief-2.typst.pdf` | FICTIONAL fixture and render (4 pages). No overlay. |
| `usage/SOURCE.md` | Exemplar record, page map, search passes. |

Markdown contract: the same as the opening brief (`../opening-brief/README.md`, "Markdown contract"); the certificate's default `recipient` is "the Defense Appellate Division".

## Governing rules

ACCA *Rules of Appellate Procedure*, effective 15 January 2019, `https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf`, read from the Wayback capture 20250729125903 on 2026-10-16. Rules 13.2, 17.1(a)-(b), 17.3 and Appendix A apply as listed in `../opening-brief/README.md` ("Governing rules"): Times New Roman 14 pt (Liberation Serif where absent), double-spaced (32.8 pt pitch), 1 in margins, letter; Appendix A caption on page 1, "TO THE HONORABLE ..." line, "Panel" at the foot of page 1, Certificate of Service on its own page. Appendix A also says an answer "may adopt the appellant's statement of facts if there is no dispute; may state additional facts; or ... restate the facts as they appear from the appellee's viewpoint."

## Overlay

`sh tools/overlay.sh ... akbar-answering-brief` exit 0. Page map:

| Ours | Filed (extract) | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 41.1% | Caption. The filer used a separate caption page with four counsel blocks (2010 practice); App. A puts the caption on page 1 above the body, so our p. 1 also carries the Statement of the Case. Rule wins. |
| 2 | 3 | 40.0% | |
| 3 | 3 | 40.9% | |
| 4 | 5 | 47.5% | |
| 5 | 5 | 41.9% | |
| 6 | 6 | 42.2% | |
| 7 | 7 | 46.9% | |
| 8 | 8 | 67.4% | End of the Statement of Facts extract |
| 9 | 9 | 82.9% | Assignment LVIII, Law and Argument, Conclusion |
| 10 | 10 | 29.7% | Signature blocks |
| 11 | 11 | 79.1% | Certificate of Service |

The filer is Courier 12 pt with smaller footnotes (pre-2019); ours is 14 pt Times-metric throughout per R. 13.2, so our text runs about one page longer per seven. Margins, double-spaced grid and page-number position line up.

## Page review (Gate 2), 2026-10-16

Every page of `OUTPUT-answering-brief.typst.pdf` (11) and `OVERLAY-answering-brief.pdf` (11) rasterized at 60 dpi and viewed. Fonts embedded: Liberation Serif Regular, Bold, Italic, BoldItalic only. No typst warnings.

| Page | Content | Result |
|---|---|---|
| 1 | Caption, "TO THE HONORABLE ...", Statement of the Case, footnotes 1-4, "Panel 2" | OK |
| 2-8 | Statement of Facts, The Crimes; dense footnotes (up to 13 per page) | OK. Footnote marks were a mix of typographic and synthesized superscripts (Liberation Serif lacks some superscript digits); fixed with `set super(typographic: false)`, re-rendered, all marks now match. ACCEPTED: pages with many footnotes leave space at the foot (footnotes kept with their marks). |
| 9 | Assignment LVIII (bold capitals), Law and Argument, Conclusion | OK |
| 10 | Signature blocks (four signers) | OPEN (tier 2): the unbreakable signature block moves to its own page; the filer kept Conclusion and signatures together on p. 217. |
| 11 | Certificate of Service | OK |

## Known gaps

1. TOC/TOA (R. 17.3(a)) not generated; 50-page limit not checked.
2. Exemplar predates the 2019 rules (Courier, separate caption page). No post-2019 ACCA answer found.
3. No `checks.yaml`: `tools/check.sh` runs the default checks with `eval.yaml` (2026-10-22: typst and docx 0 failed).
4. (Resolved 2026-10-22, fb-595.54.7: the docx engine now builds the R. 13.2 / App. A form; see "Engines".)

## History

- 2026-10-14 / 2026-10-15: no exemplar; PROVISIONAL template (EB Garamond 12 pt, cover page). See `usage/SOURCE.md`.
- 2026-10-16 (bead fb-595.20.20): rules and *Akbar* briefs found via the Internet Archive; template moved to R. 13.2 / 17.1 / App. A; *Akbar* sample, render and overlay added.

## Engines

Both engines on the shared cross-engine layout model (fb-595.54.7; `lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Adopting the reference breaker"): Times New Roman 14 pt everywhere (footnotes included), body lines in 32.8 pt boxes (double-spaced), caption, headings, block quotations, footnotes, signature and footer in 16 pt boxes, every space between blocks explicit and the same in both engines. The docx breaks every line and page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, XENG-001..003 PASS on both samples).

- **typst** (`typst/`): the reference. The signature block now stays with the last paragraph (it no longer moves to a page of its own).
- **docx** (`docx/`): `reference.xml` (the Word styles; fb render builds the reference document from it) and `acca-brief.lua` (the Appendix A caption as a borderless two-column table, block quotations, signature block, appendix, Certificate of Service, and the section with its two footers: "Panel X" flush right on page 1, the page number centered after it, through `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`). A word joiner keeps tokens such as "922(B)(2)" whole, as typst does. The old EB Garamond 12 pt cover-page form (`build-reference.sh`, `reference.docx`) is retired. `tools/check.sh --engine docx`: 0 failed. Opened in LibreOffice (DEF-DOCX-OPEN); not opened in Word, which may paginate slightly differently.

## Refreshed exemplar run (2026-10-21)

The filed exhibit is a public ACCA-hosted filing recovered from the Internet Archive; its source URL, case, Army docket, filer, filed date, and retrieval date are recorded in `usage/SOURCE.md`. The transcription remains paired with `FILED-EXAMPLE-answering-brief.pdf` as `INPUT-answering-brief.md`. No template change was needed: Appendix A controls the caption and the exemplar predates those current rules.

Rendered with `sh tools/render.sh` and compared with `sh tools/overlay.sh`; both completed successfully. Rasterized every page of the render, filed exhibit, and overlay at 60 dpi and visually reviewed every page. The overlay is `.overlay/courts/military/army-court-of-criminal-appeals/answering-brief/OVERLAY-answering-brief.pdf` (generated, not committed). Render SHA-256: `44c526812116225b61134de737cce1229da484e694dce580d4c25a366ba46b55`.

| Render page | Filed page | Finding | Status |
|---:|---:|---|---|
| 1 | 1 | Appendix A caption and body start follow current rule; old filing uses separate caption and older Courier form. | ACCEPTED |
| 2 | 3 | Body text and footnotes render cleanly; source page numbering differs in the excerpt. | PASS |
| 3 | 3 | Body and footnote placement look consistent with the sample. | PASS |
| 4 | 5 | Dense facts and footnotes remain legible; current 14 pt rule changes pagination. | ACCEPTED |
| 5 | 5 | Dense facts and footnotes remain legible. | PASS |
| 6 | 6 | Body, citations, and footnotes render cleanly. | PASS |
| 7 | 7 | Body and footnotes render cleanly. | PASS |
| 8 | 8 | End of facts excerpt renders cleanly. | PASS |
| 9 | 9 | Assignment, argument, and conclusion hierarchy is clear. | PASS |
| 10 | 10 | Signature block moves to a separate page; current template keeps the block together. | OPEN (tier 2) |
| 11 | 11 | Certificate of service renders on its own page. | PASS |

This is one filer and a pre-2019 filing; it supports only open-choice diagnostics. The remaining known issues are unchanged: no TOC/TOA or length-limit check, no `checks.yaml`, and the DOCX template is outside this pass.

## Cross-engine port and page review (2026-10-22, fb-595.54.7)

Renders after the port (typst 12 and 5 pages, docx the same): `OUTPUT-answering-brief.typst.pdf` SHA-256 `919974f26389866b52f31454bfc2636d6cf6b784247d41c898225838323c7f6f`, `OUTPUT-answering-brief-2.typst.pdf` `6f6bd7c9a1039b7ba14762d3435f7779be1d5cb573faafc6aed28a875a4a7b4a`. Every page of both typst renders and both docx PDFs rasterized (50-60 dpi) and viewed side by side; `fb diff --engines`: 247/247 and 79/79 lines with the same break, every page alike. Fonts embedded: Times New Roman Regular, Bold, Italic, BoldItalic (both engines).

| Page (sample 1) | Content | Result |
|---|---|---|
| 1 | Caption (court line centered, two columns), "TO THE HONORABLE ...", Statement of the Case, footnotes 1-3, "Panel 2" | PASS (typst and docx alike) |
| 2-9 | Statement of Facts, The Crimes; dense 14 pt footnotes | PASS. ACCEPTED: p. 9 ends short because the long LVIII heading is kept with its text on p. 10. |
| 10 | LVIII, the error in bold capitals, Law and Argument | PASS |
| 11 | Conclusion with the signature block (four signers) | PASS: the signature block now stays with the last paragraph (was OPEN). |
| 12 | Certificate of Service | PASS |

Sample 2 (FICTIONAL, 5 pages): caption, headings I./II. flush left, sub-headings centered, signature with the WHEREFORE paragraph, certificate on p. 5: PASS in both engines.
