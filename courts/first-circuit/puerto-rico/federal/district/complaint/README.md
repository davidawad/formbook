# Complaint: U.S. District Court, District of Puerto Rico (`prd`)

Doc type folder for a complaint in this court. One self-contained folder per doc type; the court-root `typst/` and `usage/` are not touched.

| | |
|---|---|
| Exemplar | **yes**: `usage/FILED-EXAMPLE-complaint.pdf` (Amended Complaint, ECF 7, No. 3:14-cv-01253-PG, filed 06/25/2014, 34 pages, text-based). Provenance in `usage/SOURCE.md`. |
| Sample | `usage/INPUT-complaint.md`: a portion of the filing. Caption, lead-in, all section headings in order; filed ¶¶ 1–4 and 8–10 (introduction), 11–15 (jurisdiction), 16 (plaintiffs), 47–50 (facts), 72–81 (first claim), 82–83 (second claim, incorporation and capacity only), the prayer (A–F, see gaps), and the signature block |
| Render | `usage/OUTPUT-complaint.typst.pdf`, **9 pages**, no typst warnings (`sh tools/render.sh courts/first-circuit/puerto-rico/federal/district/complaint usage/INPUT-complaint.md`) |
| Overlay | `usage/OVERLAY-conde-vidal-complaint.pdf` and `.txt` (`sh tools/overlay.sh courts/first-circuit/puerto-rico/federal/district/complaint conde-vidal-complaint`) |
| Pages reviewed | 9 of 9 (rendered at 60 dpi and looked at, on the earlier EB Garamond render, before fb-595.68; 9 pages then and now) |
| Typeface | face required by the rules: **none named** (L.Civ.R. 7 sets a point size, 12 pt for a proportional font; secondary read, see below) → template face: **Times New Roman** 12 pt, the house standard where no face is named (`docs/FONTS.md` rule 6; Liberation Serif as fallback; EB Garamond before 2026-10-17, the docx until fb-595.68.17), on typst and docx. The exemplar is set in Times New Roman too. |

Names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the names `tools/render.sh` and `tools/overlay.sh` read and write). The brief's `<id>.pdf` and `<id>-overlay.pdf` are the same files under those names.

## Governing rules

| Rule | Text | Source | Verified |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number; the title names all parties | https://www.law.cornell.edu/rules/frcp/rule_10 (as amended Dec. 1, 2007) | read 2026-10-14 (Cornell copy; not govinfo) |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances | same | read 2026-10-14 |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, claim, and relief | not fetched in this run | no |
| D.P.R. Local Civil Rule 7 (form of papers) | Papers typed on 8½ × 11 white paper; font at least 10 cpi or, for a proportional font, at least 12 points; double-spaced except quoted material; caption, title, footnotes, quotations, property descriptions and counsel identifications may be single-spaced; consecutive page numbers, preferably bottom centre | https://www.courtrules.net/courts/federal/district-puerto-rico/local-rules/rule-7 (a third-party compilation; the court's own PDF at prd.uscourts.gov returned 404 from the build box, and the rule page returned 403) | **no, primary not read.** Text read 2026-10-14 through a search excerpt of the courtrules.net page; the court's 20201221 compilation (FAB rules) is the primary source and must be checked before this README is marked verified |

Requirement IDs used in `typst/prd-complaint.typ`:

- **PRD-FORM-002**: 12-point proportional font (Times New Roman, `docs/FONTS.md` rule 6). L.Civ.R. 7 (secondary).
- **PRD-FORM-003**: double spacing, 24 pt pitch. L.Civ.R. 7 (secondary).
- **PRD-FORM-004**: 1-inch margins. Not stated in the rule text read; set from the exemplar (a convention, tier 2).
- **PRD-FORM-005**: page number at bottom centre, same size as the text. L.Civ.R. 7 (secondary: "preferably at the bottom center").
- **PRD-CAP-001**: court title from the template (`UNITED STATES DISTRICT COURT` / `DISTRICT OF PUERTO RICO`), the same for every case in this court; exemplar convention.
- **PRD-CAP-002**: caption box, case number, title of the paper. Exemplar convention.
- **PRD-CONT-001**: headings: centred capitals for sections, bold for sub-headings, bold italic below. Convention.
- **PRD-SIG-001**: date, `Respectfully submitted`, `By: s/`, counsel with `USDC-PR No.`. Exemplar convention; no rule text read.

## What the overlay shows

Measured on the earlier EB Garamond render, before fb-595.68. Red = our render; blue = the filed exemplar; black = both (see `OVERLAY-conde-vidal-complaint.txt` for the page pairing). Pages pair by word overlap, not by index, so a partial transcription still lines up.

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 | 1 | 85.2% |
| 2 | 2 | 65.5% |
| 3 | 5 | 63.0% |
| 4 | 6 | 77.4% |
| 5 | 16 | 67.1% |
| 6 | 25 | 70.9% |
| 7 | 26 | 84.3% |
| 8 | 32 | 94.7% |
| 9 | 33 | 62.2% |

Reading the overlay: the caption, the lead-in and the first body page line up (pages 1 and 2). The later pages line up with the filed pages they were transcribed from, and the page-level word overlap is lower because the filing's paragraphs are numbered and our numbers are not carried over (the template numbers from 1; see the sample's header). Word overlap is a diagnostic, not a score; the visual review is the check.

## Known gaps

- **Exemplar search**: only one D.P.R. complaint was found as a text-based public PDF. Searched: CourtListener and RECAP (not reachable from the build box, and no storage path could be found); Clearinghouse (403 from the build box); Justia dockets (no documents); the D.P.R. blank civil complaint form (a blank form, not a filing); Democracy Forward, ACLU-PR and Earthjustice filings (the ones found were D.D.C. or D.P.R. amicus filings or a Commonwealth-court *demanda*); Comité Diálogo Ambiental v. FEMA, 3:24-cv-01145 (its complaint was filed in D.D.C. in 2023 before transfer; the PDF was not retrieved). The exemplar's filer is the plaintiffs' counsel in an equal-protection and due-process challenge; it is a 2014 pleading.
- **Local rules not read at primary**: the court's local-rules PDFs (`20230714-USDCPR-Local-Rules.pdf`, `20220304-...`, `20201221` FAB compilation) are on prd.uscourts.gov, which returned 404 for every path tried. The L.Civ.R. 7 text above is from a third-party copy. No D.P.R. local rule about complaint caption, cover page, civil cover sheet, or length was read, so none is implemented.
- **Font**: no D.P.R. rule read names a face; the template is Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6, David 2026-10-17), as is the exemplar (EB Garamond before 2026-10-17, the docx until fb-595.68.17).
- **Paragraph numbers**: the template numbers the allegations from 1 (FRCP 10(b)); the filed numbers are not carried over, so a numbered paragraph in the sample does not match the number on the same paragraph in the filing.
- **Prayer item C**: the filed prayer runs A, B, D, E, F, G (no C). The sample transcribes the items as printed (A–F), so the sample shows one fewer item letter than the filing's last letter.
- **Not transcribed**: filed ¶¶ 5–7, 17–46, 51–71, 84–91, and the body of the second claim after ¶ 83.
- **Not implemented**: jury demand is an optional field (`jury_demand`), not in the exemplar; no civil cover sheet, summons, or Rule 7.1 disclosure statement; no certificate of service (a complaint is served with a summons).
- **Current rules**: the exemplar predates the current D.P.R. rules; the template follows the rule text read today and the exemplar only where the rules are silent.

## Engines

The same markdown renders through typst (`typst/`, the reference) and docx (`docx/`). There is no latex engine here. `tools/check.sh` gates both outputs on `eval.yaml` (`usage/.check-typst.txt` and `usage/.check-docx.txt`: PASS); the docx review below is by eye.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-complaint.typst.pdf` (9 pp, reference) | reference |
| docx | `OUTPUT-complaint.docx`, `OUTPUT-complaint.docx.pdf` (9 pp) | ok: LibreOffice converts it without error; XENG-001..003 pass (253/253 lines, fb-595.68.17). The by-eye review (all 10 pages of the `.docx.pdf` at 60 dpi beside the typst pages) was on the earlier EB Garamond docx |

```sh
sh tools/render.sh --engine docx courts/first-circuit/puerto-rico/federal/district/complaint usage/INPUT-complaint.md
```

**docx** (`docx/reference.xml`, from which `fb render --engine docx` builds the reference document on the shared cross-engine recipe in the typst face, with the `-N-` footer part; `docx/prd-complaint.lua`; `docx/make-reference.sh` and `docx/parts/` were retired into fb render in fb-595.68.17).

- *Matches typst:* Times New Roman 12 pt (Regular and Bold embedded); 9 pages on both engines; double spacing at 24 pt exact; single lines at 13.8 pt; 1-inch margins on US Letter; the page number at the bottom centre in the typst form, `-n-` at 12 pt, on every page; the court title; the caption with the rule on the right and the bottom of the party column, the case number and the title in capitals; the lead-in; numbered allegations with the number at 0.5 inch; level-1 headings centred in capitals and level-2 headings in bold; the prayer's lettered items (A., B., ...); the signature block in two columns (date left; "Respectfully submitted," and the counsel groups right, with "By: s/" lines).
- *Differs* (on the earlier EB Garamond docx; not re-checked here): line breaks fell at different words, so the body ran one page longer than typst (10 against 9) and the signature block sat on page 10 with the last prayer items. Exact-spaced text sat lower in its line than in typst (about 3 pt in the single-spaced caption, about 11 pt in double-spaced body text), because LibreOffice set exact-height text at the bottom of its line. The first party block of the caption wrapped to nine lines where typst used eight. The prayer's letters and text sat on slightly different tab stops.
- *Not built:* the civil cover sheet, summons and Rule 7.1 statement, as for typst (see Known gaps above).
- *BLOCKED:* none. (No check IDs exist for this folder; the requirement IDs above are the ones the typst template cites.)
- *Not opened in Word:* the `.docx` is a valid zip with well-formed XML parts and LibreOffice opens it; Word has not been run, so the no-repair check in Word is not done.
