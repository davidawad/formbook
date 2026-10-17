# U.S. Army Court of Criminal Appeals (acca): answering brief (brief on behalf of the appellee)

- Court: `acca`, U.S. Army Court of Criminal Appeals (`courts/military/army-court-of-criminal-appeals/`)
- Doc type: `answering-brief`. The United States' answer to the appellant's assignments of error. ACCA Rule 17.1(a): pleadings "raising or addressing" an assignment of error follow Rule 13 and Appendix A, so the answer uses the Appendix A form with the appellee's title.
- Exemplar: `exemplars/FILED-EXAMPLE-akbar-20050514-answering-brief.pdf`, an 11-page extract of *United States v. Akbar*, Army Dkt. 20050514, Brief on Behalf of Appellee, filed 29 November 2010 by the Government Appellate Division (source, page map: `exemplars/SOURCE.md`). Found on the fourth search pass (2026-10-16, bead fb-595.20.20).
- Samples: `samples/INPUT-akbar-answering-brief.md` (transcription of the extract); `samples/INPUT-fictional-answering-brief.md` (FICTIONAL fixture, kept).
- Template: `typst/acca-answering-brief.typ` (entry `typst/main.typ`). Same as `../opening-brief/typst/acca-opening-brief.typ` except the title ("BRIEF ON BEHALF OF APPELLEE", as the filer titles it) and the default certificate recipient (the Defense Appellate Division).
- Status (2026-10-16): rule text retrieved and applied. Render ok (11 pages), overlay ok, every page reviewed. `tools/check.sh` not run (no `checks.yaml`). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ`, `typst/acca-answering-brief.typ` | Entry point and template. |
| `samples/INPUT-akbar-answering-brief.md` | Transcription of the extract (caption page, brief pp. 1-7, 216-218). Names the filer blacked out are written `[redacted]`. |
| `samples/OUTPUT-akbar-answering-brief.pdf` | `sh tools/render.sh courts/military/army-court-of-criminal-appeals/answering-brief samples/INPUT-akbar-answering-brief.md` (11 pages). |
| `samples/OVERLAY-akbar-answering-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/military/army-court-of-criminal-appeals/answering-brief akbar-answering-brief`. |
| `samples/INPUT-fictional-answering-brief.md`, `OUTPUT-fictional-answering-brief.pdf` | FICTIONAL fixture and render (4 pages). No overlay. |
| `exemplars/SOURCE.md` | Exemplar record, page map, search passes. |

Markdown contract: the same as the opening brief (`../opening-brief/README.md`, "Markdown contract"); the certificate's default `recipient` is "the Defense Appellate Division".

## Governing rules

ACCA *Rules of Appellate Procedure*, effective 15 January 2019, `https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf`, read from the Wayback capture 20250729125903 on 2026-10-16. Rules 13.2, 17.1(a)-(b), 17.3 and Appendix A apply as listed in `../opening-brief/README.md` ("Governing rules"): Times New Roman 14 pt (Liberation Serif), double-spaced (32.3 pt pitch), 1 in margins, letter; Appendix A caption on page 1, "TO THE HONORABLE ..." line, "Panel" at the foot of page 1, Certificate of Service on its own page. Appendix A also says an answer "may adopt the appellant's statement of facts if there is no dispute; may state additional facts; or ... restate the facts as they appear from the appellee's viewpoint."

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

Every page of `OUTPUT-akbar-answering-brief.pdf` (11) and `OVERLAY-akbar-answering-brief.pdf` (11) rasterized at 60 dpi and viewed. Fonts embedded: Liberation Serif Regular, Bold, Italic, BoldItalic only. No typst warnings.

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
3. No `checks.yaml`; `tools/check.sh` not run.
4. The docx engine was not changed in this pass and still builds the old EB Garamond 12 pt cover-page form; `samples/OUTPUT-fictional-answering-brief.docx` is from that form.

## History

- 2026-10-14 / 2026-10-15: no exemplar; PROVISIONAL template (EB Garamond 12 pt, cover page). See `exemplars/SOURCE.md`.
- 2026-10-16 (bead fb-595.20.20): rules and *Akbar* briefs found via the Internet Archive; template moved to R. 13.2 / 17.1 / App. A; *Akbar* sample, render and overlay added.

## Engines

**docx** (`docx/`), unchanged and out of step with the typst form (Known gaps 4). BLOCKED: `tools/check.sh --engine docx` cannot run (no LibreOffice on the earlier box; no `checks.yaml`).
