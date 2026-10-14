# Motion to dismiss with memorandum: U.S. District Court, District of Puerto Rico (`prd`)

Doc type folder for a Rule 12(b) motion to dismiss with the memorandum of law in support. One self-contained folder per doc type; the court-root `typst/` and `samples/` are not touched.

| | |
|---|---|
| Exemplar | **yes**: `exemplars/FILED-EXAMPLE-franklin-california-3-14-cv-01518-motion-brief.pdf` (Motion to Dismiss, ECF 10, and Memorandum of Law, ECF 10-1, No. 3:14-cv-01518-FAB, filed 07/21/2014, text-based, 37 pages). Provenance in `exemplars/SOURCE.md`. |
| Sample | `samples/INPUT-franklin-memorandum.md` (transcription of a portion: caption, counsel block, title, lead-in, Introduction, Background, Standard of Review, Argument I in full, Argument II.A in full, II.B through its second paragraph, footnotes 1–2, Conclusion, signature block, certificate of service) |
| Render | `samples/OUTPUT-franklin-memorandum.pdf`, **10 pages** (cover, TOC `i`, TOA `ii`, body 1–7), no typst warnings (`sh tools/render.sh courts/first-circuit/puerto-rico/federal/district/motion-brief samples/INPUT-franklin-memorandum.md`) |
| Overlay | `samples/OVERLAY-franklin-memorandum.pdf` and `.txt` (`sh tools/overlay.sh courts/first-circuit/puerto-rico/federal/district/motion-brief franklin-memorandum`) |
| Pages reviewed | 10 of 10 (rendered at 60 dpi and looked at; headings re-checked on the final render) |
| Typeface | face required by the rules: **none named** (L.Civ.R. 7 sets a point size, 12 pt for a proportional font; secondary read, see below) → substitute: **EB Garamond** (no face named, `docs/FONTS.md`) → metric-compatible: n/a, visual only. The exemplar is set in Times New Roman, but an exemplar does not set a rule. Font list unchanged in `typst/prd-motion-brief.typ`. |

Names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`, the names `tools/render.sh` and `tools/overlay.sh` read and write. The brief's `<id>.pdf` and `<id>-overlay.pdf` are the same files under those names.

## Governing rules

| Rule | Text | Source | Verified |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption: court's name, title, file number; title names all parties | https://www.law.cornell.edu/rules/frcp/rule_10 (as amended Dec. 1, 2007) | read 2026-10-14 (Cornell copy) |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances (not applied: a memorandum has unnumbered paragraphs) | same | read 2026-10-14 |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim: the sample's standard-of-review text quotes the rule; the rule text is taken from the exemplar | not fetched | no (rule text as quoted in the exemplar) |
| D.P.R. Local Civil Rule 7 (form of papers) | Same as in `../complaint/README.md`: 8½ × 11, 12-point proportional font, double-spaced except quotations and captions/titles/footnotes/counsel, consecutive page numbers | https://www.courtrules.net/courts/federal/district-puerto-rico/local-rules/rule-7 (a third-party compilation) | **no, primary not read** (same reason as the complaint README) |
| D.P.R. Local Civil Rule 7, table of contents | A memorandum of 10 pages or more must contain a table of contents | quoted in a D.P.R. order (17-MC-506, promesa.prd.uscourts.gov), seen only in a search excerpt; the order URL returned 404 | **no**, secondary-of-secondary |
| D.P.R. Local Civil Rule 7, page limit | Not confirmed (search excerpts did not show it); **not implemented** | — | no |

Requirement IDs used in `typst/prd-motion-brief.typ`:

- **PRD-FORM-002**: 12-point proportional font (EB Garamond, vendored). L.Civ.R. 7 (secondary).
- **PRD-FORM-003**: double spacing, 24 pt pitch, for the memorandum's text; single spacing for the caption, counsel block, headings' inner lines, footnotes, TOC and TOA. L.Civ.R. 7 (secondary).
- **PRD-FORM-004**: 1-inch margins. Not in the rule text read; from the exemplar (a convention).
- **PRD-FORM-005**: page number bottom centre; roman for the cover-less front matter, arabic from the first body page (the exemplar's convention).
- **PRD-CAP-001**: court title from the template (`UNITED STATES DISTRICT COURT` / `FOR THE DISTRICT OF PUERTO RICO`); exemplar.
- **PRD-CONT-001**: headings: level 1 centred capitals; level 2 I., level 3 A., level 4 1., level 5 a. (numbered by the template, not typed). Exemplar convention.
- **PRD-SIG-001**: `Respectfully submitted,` / `Dated:`; each signing counsel `By: s/` with `USDC-PR No.`, two per row. Exemplar convention.
- **PRD-SIG-002**: certificate of service: the CM/ECF sentence (court's wording in the exemplar) and `In <place>, this <date>.`, with the signer. Exemplar convention.

## What the overlay shows

Red = our render; blue = the filed exemplar; black = both (see `OVERLAY-franklin-memorandum.txt` for the page pairing). Pages pair by word overlap.

| Our page | Filed page | Word overlap | Note |
|---|---|---|---|
| 1 (cover) | 4 | 76.3% | memorandum cover |
| 2 (TOC) | 5 | 70.9% | |
| 3 (TOA) | 6 | 22.8% | the filed TOA lists authorities we do not cite (and our TOA lists only linked cites); low by design |
| 4 (Introduction) | 11 | 73.4% | |
| 5 (Background) | 16 | 33.1% | a different filed page with the same subject |
| 6 (Argument I) | 18 | 51.4% | |
| 7 (Argument I–II.A) | 19 | 71.5% | |
| 8 (II.A–II.B) | 20 | 60.4% | |
| 9 (II.B–Conclusion) | 22 | 87.9% | |
| 10 (Signature, certificate) | 3 | 48.9% | pairs with the motion's own certificate of service (filed p. 3), so the word match is the certificate text, not the signature block |

Reading the overlay: the filed PDF is a motion (ECF 10, three pages) followed by the memorandum (ECF 10-1), so the filed pages 1–3 are the motion, not the memorandum. The memorandum pages line up with filed pages 4–37. Word overlap is a diagnostic, not a score; the visual review is the check.

## Known gaps

- **Exemplar search**: one D.P.R. motion with a memorandum was found as a text-based public PDF (via a law-firm host, Mintz; the ECF copy is not on CourtListener in this build box). The exemplar is from the Commonwealth's counsel, with a multi-party caption. Searched: CourtListener and RECAP (no reachable storage path); Clearinghouse (403 from the build box); Justia dockets (no documents); D.P.R. local-rule compilations (not reachable at the primary URL).
- **Local rules not read at primary**: as in the complaint README. The page limit, the table-of-contents trigger and the form of the memorandum's cover are not confirmed against the court's PDF, and the page limit is not implemented.
- **Font**: the exemplar is Times New Roman, but no D.P.R. rule read names a face, so EB Garamond stays (`docs/FONTS.md`, "No face named"). It sets visibly smaller than 12-point Times. If the primary L.Civ.R. 7 is found to name Times New Roman, switch the font list to `Liberation Serif` (the substitute in `docs/FONTS.md`) and re-check the page count.
- **Authorities**: the TOA is built from `toa:` links only. A cite written as plain text (for example *Hanover Nat'l Bank v. Moyses* in footnote 2, *Neblett v. Carpenter*, *Doty v. Love*, *FDIC v. Torrefación Café Cialitos*) does not appear in the TOA. A complete table needs every cite linked. The sample does not link them because the transcription is partial.
- **Not transcribed**: Argument II.B after its second paragraph; Arguments III–V; footnotes after footnote 2; the memorandum's TOA entries for authorities not in the sample. The sample's page count (10) is therefore below the exemplar's (37 with the motion).
- **Short citations**: the template does not check that a short cite's page is correct; that is the author's job.
- **Hearing and noticed-motion language**: the cover has no hearing date, time or courtroom fields. The exemplar's ECF-era memorandum has none; a noticed-motion field (if the court requires one) is not implemented.
- **Current rules**: the exemplar was filed in 2014, under the local rules of that year; the template follows the rule text read today and the exemplar only where the rules are silent.
