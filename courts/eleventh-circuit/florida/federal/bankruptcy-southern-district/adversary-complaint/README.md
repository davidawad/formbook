# flsb: adversary complaint (typst)

Court: United States Bankruptcy Court, Southern District of Florida (`flsb`). Doc type: adversary complaint commencing an adversary proceeding.

**exemplar=yes.** Filed exemplar: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (see `usage/SOURCE.md`).

## Governing rules

Verified 2026-10-14.

| Rule | What it requires | Source | Where the template uses it |
|---|---|---|---|
| Fed. R. Bankr. P. 7001 | An adversary proceeding is commenced by complaint; 7001(c) covers a sale of co-owned estate property under §363(h) | https://www.law.cornell.edu/rules/frbp/rule_7001 (LII, Dec. 1, 2024 text) | Exemplar subject matter; no template code |
| Fed. R. Bankr. P. 7008(a) | Jurisdictional allegations identify the case's name, number and chapter, and the district and division; the pleader states whether it consents to final orders or judgment by the bankruptcy court | https://www.law.cornell.edu/rules/frbp/rule_7008 (summary read via WebFetch, 2026-10-14; the full text was not quoted verbatim) | Body text in the sample (not generated) |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies; the caption must substantially conform to Form 416 | https://www.law.cornell.edu/rules/frbp/rule_7010 | Caption and Civil Rule 10(b) numbering |
| Fed. R. Civ. P. 10(b) (via 7010) | Allegations in numbered paragraphs | Fed. R. Civ. P. 10 | Automatic numbering of body paragraphs |
| Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number and adversary number, designation of the document | https://www.law.cornell.edu/rules/frbp/rule_9004 (Dec. 1, 2024 text) | Caption |
| S.D. Fla. Bankr. L.R. 9004-1(a)(2) | Margins of at least one inch on top, bottom and both sides | 2026 Local Rules, https://www.flsb.uscourts.gov/sites/flsb/files/local_rules/2026_Local_Rules.pdf, Rule 9004-1, pp. 39–40 | `margin: 1in` |
| L.R. 9004-1(a)(3) | 12-point font; footnotes may be 10-point | same | `type-size: 12pt` in Times New Roman (the house standard, `docs/FONTS.md` rule 6) |
| L.R. 9004-1(a)(4) | Double spacing, except captions, titles, headings, quotations over 50 words, footnotes, signature blocks and certificates of service | same | `pitch-double` (24 pt pitch), `pitch-single` (13.8 pt) for caption and signature |
| L.R. 9004-1(e)(2) | Adversary caption: court name, division line, "In re:" block, plaintiff v. defendant, Adv. No. | same | Caption; the division is a blank line when the sample names none |

PDF text layer: L.R. 9004-1(a)(1) requires text-searchable PDF. Typst output has a text layer (pdftotext returns it; checked).

## Layout

| Path | What |
|---|---|
| `typst/flsb-adversary-complaint.typ` | Template: `flsb-adversary-complaint(meta, body)`. Content-agnostic; every case word comes from the sample's frontmatter. |
| `typst/main.typ` | Entry point: reads `sample=` and calls the template. |
| `usage/INPUT-adversary-complaint.md` | Transcription of the exemplar's text (caption, jurisdiction and parties, background, Count I, WHEREFORE items, reservation, signature). |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | Our render (`tools/render.sh`). |
| `usage/OVERLAY-slott-complaint.pdf`, `.txt` | Red (ours) / blue (filed) overlay and page map (`tools/overlay.sh`). |
| `usage/` | The filed PDF and `SOURCE.md`. |

Commands, run from the repo root with the toolchain on `PATH`:

```sh
sh tools/render.sh courts/eleventh-circuit/florida/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/eleventh-circuit/florida/federal/bankruptcy-southern-district/adversary-complaint slott-complaint
```

File-name note: the brief asked for `usage/<id>.pdf` and `usage/<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, and the overlay reads `OUTPUT-<id>.pdf`; the tools are not changed here, so the tool names are used.

## Overlay (red/blue test)

`sh tools/overlay.sh` (run on the earlier EB Garamond render, before fb-595.68) pairs each of our pages with the filed page sharing the most words (`usage/OVERLAY-slott-complaint.txt`). Pairings: ours p.1 → filed p.1 (83.3%), p.2 → p.2 (70.7%), p.3 → p.3 (65.2%), p.4 → p.5 (54.3%), p.5 → p.6 (57.1%). Our pages 4 and 5 pair with later filed pages because our page breaks fall in different places from the exemplar's; the overlay is a word-match diagnostic, not a score, and was not used to set any value.

What the rules drive, and the exemplar does not:

- The exemplar has no division line; our caption prints a blank `___________ DIVISION` line, as L.R. 9004-1(e)(2) requires.
- Body type is 12-point Times New Roman, double-spaced, with 1-inch margins (L.R. 9004-1(a)); the exemplar's own type size and margins were not measured, so the overlay is not evidence for or against them.

## Page review (Gate 2)

Every page of `OUTPUT-adversary-complaint.typst.pdf` was rendered at 60 dpi and looked at (the earlier 5-page EB Garamond render, before fb-595.68). `pages_reviewed=5`.

| Page | Result |
|---|---|
| 1 | Caption, title and opening paragraph; spacing and numbering correct. |
| 2 | Headings kept with their paragraphs; double spacing consistent (24 pt pitch, checked with `pdftotext -bbox`). |
| 3 | Count I heading; §363(h) block quotation single-spaced and indented; numbering continues from the lead-in, which is unnumbered as in the exemplar. |
| 4 | §363(j) quotation; WHEREFORE with lettered items (a)–(c). |
| 5 | WHEREFORE items (d)–(f); reservation of rights (¶28, matching the exemplar); signature block. |

Defects found and fixed while reviewing:

- Paragraphs overlapped: a block's height did not include the leading after its last line, so one-line paragraphs collided with the next. Fixed by giving each body block `below: body-leading`.
- Paragraphs after a heading lost that spacing too (they were wrapped in a block without `below`). Fixed on the wrapper.
- The opening paragraph was numbered 1; the exemplar leaves it unnumbered. Now unnumbered, so the numbering matches the exemplar (¶18 realleges, ¶28 reservation).

## Known gaps

- **Length.** The sample renders to 6 pages (5 on the earlier EB Garamond render). The exemplar is 9 pages with two exhibits; its body is 6 pages. The brief's 8–14-page target is not reached because the exemplar is not that long. The sample transcribes the whole body.
- **Exhibits A and B** are separate attachments and are not transcribed.
- **§363(h) quotation** is set as one paragraph, so the exemplar's line structure inside the statute is lost.
- **Jurisdiction and consent** (FRBP 7008(a)) are in the sample body as text; the template does not check that they are present.
- **Exemplar typos are kept.** The transcription keeps the exemplar's wording as filed (for example "Bank. P." and "a 2024 an assessed value"), so the overlay shows them as differences.
- **No certificate of service** is generated, because the exemplar has none.
- **Gate 2 scope.** Review is by eye at 60 dpi; no automated check of the rule values beyond the typst source.

## Engines

Word (`docx/`): `fb render --engine docx` builds the reference document from `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst template's face; `docx/make-reference.sh` and `docx/render.sh` are retired) and runs pandoc with `docx/flsb-adversary-complaint.lua`; it writes `usage/OUTPUT-adversary-complaint.docx` and the LibreOffice `usage/OUTPUT-adversary-complaint.docx.pdf`. Run `sh tools/render.sh --engine docx <this dir> usage/INPUT-adversary-complaint.md`.

What matches the typst output (recorded before fb-595.68; the face is now that of `docx/reference.xml`): Times New Roman 12 pt; 1-inch margins on letter paper; double spacing (24 pt exact) for body paragraphs with a half-inch first-line indent; single-spaced caption, title, signature block and block quotations; 10-point footnotes; centered page number; the caption (court, division or blank line, debtor, parties, case and adversary numbers) as a borderless table; paragraph numbers 1 to 28 with the opening paragraph and WHEREFORE unnumbered; lettered items (a)–(f) at a half-inch left indent; headings kept with the next paragraph.

What differs: paragraph numbers and lettered markers are typed text, not Word list numbering; Word's line breaking may differ from the LibreOffice PDF. The Times New Roman font must be installed on the machine that opens the file, or Word substitutes another face.

docx BLOCKED (not verified; see docs/DOCX.md; recorded before fb-595.68, when `soffice` was not available here):
- `docx.pdf` gates (all of `tools/check.sh --engine docx`, which measure the LibreOffice PDF): BLOCKED: LibreOffice (`soffice`) is not installed in this environment and is not in conda-forge, so `usage/OUTPUT-slott-complaint.docx.pdf` was not produced and no page was rendered or reviewed. `tools/check.sh` also cannot run here yet (it needs `yq`, `checks.yaml` and `court.json` for this doc type).
- The `.docx` itself was written and its XML parts are well-formed (`unzip -t`, `xmllint`). It has not been opened in Word or LibreOffice, so "opens without a repair prompt" is unchecked.

## Status

`court.json` is not touched; status is not set. Shared tools, the root README, `STATUS.md` and `data/` are not edited.
