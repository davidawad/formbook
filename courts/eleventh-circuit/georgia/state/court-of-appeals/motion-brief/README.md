# Georgia Court of Appeals (gactapp): motion-brief

Doc type: **motion** (a filed motion with its supporting argument). Court: Court of Appeals of the State of Georgia. Folder: `courts/eleventh-circuit/georgia/state/court-of-appeals/motion-brief/`.

BLOCKED: no exemplar. No filed motion of this type from this court could be downloaded (searches and reasons in `exemplars/SOURCE.md`). The sample is synthetic and written from the rules.

Status: exemplar=no, render=ok, overlay=fail (no exemplar PDF to overlay against), pages reviewed 4 of 4 (rendered at 60 dpi and looked at). Nothing here sets a `court.json` status.

## Governing rules

The rule text could not be read from the official source on this box. The official rules PDF (`https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-9-Oct-2025.pdf`, "Eff 9 Oct 2025") and the gaappeals.us and state-rules.com copies all returned HTTP 403, so each row below is marked by how well it is supported. Nothing below is quoted from the official text.

| ID | Rule (as cited) | Requirement | Verified? | Where it lives |
|---|---|---|---|---|
| GACA-FORM-001 | Ga. Ct. App. R. 24 (as cited by the court's checklist) | Letter paper, 8½ × 11 in. | Not verified; standard paper size assumed | `typst/gactapp-motion-brief.typ` (`paper`) |
| GACA-FORM-002 | Ga. Ct. App. R. 24 (the checklist cites Rule 2(c)(2)) | Typeface: Times New Roman, regular, 14 pt, for printed or e-filed documents. Alternative for typed documents: no smaller than 10 characters per inch. | Secondary only: a WebSearch summary of the court's own checklist (gaappeals.us, sources not fetched). Rule number conflicts across sources. **Needs checking against the official text.** | `font-family`, `type-size` |
| GACA-FORM-003 | Ga. Ct. App. R. 24 (checklist cites Rule 2(c)(1)) | Double spacing, excluding quotations and footnotes. | Secondary only (same checklist). | `body-leading` (line pitch 32.2 pt, measured) |
| GACA-FORM-004 | Not found | Margins. Template uses 1 in on all sides. | Not from a rule. Style assumption. | `margins` |
| GACA-FORM-005 | Ga. Ct. App. R. 24(c) (checklist) | Arabic page numbers at the bottom of each page. | Secondary only. | `numbering: "1"`, centred footer |
| GACA-CONT-001 | Not verified | Body structure: statement of the case, argument with citation of authority, conclusion. | Convention, not a rule citation. The sample uses these headings. | body (markdown `#` and `##` headings) |
| GACA-CERT-001 | Ga. Ct. App. R. 37 (as summarised by two third-party sites) | Motions for reconsideration are prepared under Rule 24 and limited to 4,200 words, with a word-count certificate above the signature block. | Secondary only. | `word-count-certificate` (only when frontmatter has `word_count`) |
| GACA-SIG-001 | Not verified | Signature block: firm, attorney, Georgia Bar number, address, telephone, email. | Convention. | `signature-block` |
| GACA-CERT-002 | Not verified (e-filing certificate of service is customary) | Certificate of service on opposing counsel, with the method of service. | Convention. | `certificate-of-service` |
| GACA-LIMIT-001 | Ga. Ct. App. R. 24 (checklist: 30 pages paper / 8,400 words e-filed for civil briefs) | Length limit for briefs. | Secondary only. Not enforced: the template has no page or word counter. | not enforced |

Rule 37's 10-day deadline and its grounds (subsection (e)) are secondary-only and do not apply to a motion-brief; they are recorded in the rehearing folder's README.

## The typeface

- **Court-named face:** Times New Roman (per the court's checklist, see GACA-FORM-002).
- **Substitute:** Liberation Serif (`fonts/liberation-serif/`, SIL OFL 1.1), per `docs/FONTS.md`. Metric-compatible with Times New Roman.
- **Not used:** EB Garamond. The rule names a face, so the substitute above applies (`docs/FONTS.md`, rule 3).
- **Size:** 14 pt, footnotes included (footnote text is set at `type-size`). Headings are bold at the same size.

## Sample

- `samples/INPUT-motion-sample.md`: a synthetic motion (Appellee's motion to dismiss an appeal as untimely). Frontmatter carries the court, case number, caption, title, signature, service and word count. Body: a statement of the case, an argument in three parts with sub-parts, and a conclusion. Names, numbers and dates are invented. Statutory citations (O.C.G.A. §§ 5-6-38(a) and 9-15-14) are given as illustrations and have not been checked against the code.
- The sample is 4 pages. The eval-loop target is 8 to 14 pages when the exemplar is that long, but there is no exemplar to size against, so the sample was not padded to reach it.
- The sample's frontmatter has a `synthetic:` field stating it is not a transcription. Templates ignore unknown fields.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/eleventh-circuit/georgia/state/court-of-appeals/motion-brief samples/INPUT-motion-sample.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/state/court-of-appeals/motion-brief motion-sample
```

- `samples/OUTPUT-motion-sample.pdf`: 4 pages. Typst compiled with no warnings (`render.sh` treats any warning as a failure). `pdffonts`: LiberationSerif-Bold and LiberationSerif, both embedded.
- Output name: `tools/render.sh` and `tools/overlay.sh` name files `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`; the brief's `<id>.pdf` naming was not used, so the existing tools work unchanged.
- Overlay: **fails**. `tools/overlay.sh` exits 1 with "no exemplar pdf in .../exemplars", because `exemplars/` has no PDF. No `OVERLAY-motion-sample.pdf` or `.txt` was written.

## Visual review (Gate 2 record, all 4 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption (left party block, right case number and lower-court number), title, opening paragraph, "Statement of the Case" begins | OK after fixes. The first render had body paragraphs overlapping one another (see Fixes). |
| 2 | Argument, sections I, A, B | OK. Headings bold at 14 pt; paragraphs have first-line indent; double spacing even. |
| 3 | Argument II, III; Conclusion | OK. |
| 4 | Certificate of word count, signature block (right-hand column), certificate of service | OK. Signature block sits in the right half. Word-count certificate sits above the signature, as the rule summary describes. |

Reviewed pages: 4 of 4.

## Fixes made during review

1. **Overlapping lines at paragraph breaks.** `set par(spacing: 0pt)` caused the first line of a new paragraph to sit on top of the last line of the previous one. Removed; the paragraph break now has no extra gap and the first-line indent marks the new paragraph.
2. **Double spacing.** First leading (0.85 em) gave about 16 pt line pitch, which is single spacing. Measured with `pdftotext -bbox-layout`, pitch is now 32.2 pt, double spacing at 14 pt.
3. **Heading size.** Level-1 and level-2 headings were rendered at the default heading size. Now set to `type-size`.
4. **Signature block.** Was right-aligned with the signer's name repeated. Now placed in the right half with the name only once (the name was removed from the sample's `signature.signer` list).
5. **Service certificate.** "on 15th day of October" changed to "on October 15, 2026," (the service `date` field now holds the date form).

## Known gaps and open choices

1. **Rule text unverified.** Every GACA-* requirement is from a secondary source; the official rules could not be read. **Needs David's check** against the current published rules (`COA-Rules-Complete-Eff-9-Oct-2025.pdf`) before the template is treated as complete. The rule-number conflict (Rule 2(c) against Rule 24) is open.
2. **Exemplar.** None. Tier 2 conventions cannot be judged against filed examples. `BLOCKED: no exemplar`.
3. **Level-1 headings** are left-aligned, bold, upper case. Many briefs centre them; the choice here is not from a rule.
4. **No table of contents or table of authorities.** Not generated. Whether this court requires them for a motion is not verified.
5. **No length counter.** The word-count certificate is written from the frontmatter `word_count` field, not counted by the template.
6. **Margins** (1 in) are an assumption (GACA-FORM-004).
7. **Footnotes** are supported by cmarker but the sample has none; footnote size follows `type-size`, not separately checked.

## Engines

docx (`docx/`: `reference.docx` from `make-reference.sh`, `gactapp-motion.lua`, `render.sh`; LibreOffice PDF is the checked copy).

- Matches the typst form: Liberation Serif 14 pt throughout; 1-inch margins, Letter; body double-spaced; half-inch first-line indent; cover with the court line, a two-column caption with a vertical rule, and the title centred; the body starts on the cover page, as in the typst form; every page numbered from 1 at the bottom centre; certificate of word count, signature block (3.25 in indent) and certificate of service follow the body.
- Differs: the typst motion template's double spacing is about 32 pt pitch and the docx uses Word's "double" (about 32 pt), so the line pitch matches; word wrapping and the signature-block spacing differ slightly. The docx runs one page longer (motion: typst 4, docx 5). The certificate of service heading is kept with its paragraph.
- Petition for rehearing (same form): the counsel address and signature spill to a new page in the docx sample (page 6), where the typst sample fits on 5 pages.
- BLOCKED: none for this doc type. `sh tools/check.sh --engine docx` was not run (no gate run in this bead; the .docx.pdf is rendered and every page was viewed at 60 dpi).
- Opened and rendered with LibreOffice only; not opened in Word.
