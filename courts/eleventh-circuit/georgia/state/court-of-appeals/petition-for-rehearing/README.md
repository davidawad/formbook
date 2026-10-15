# Georgia Court of Appeals (gactapp): petition-for-rehearing

Doc type: **motion for reconsideration** (Ga. Ct. App. R. 37), filed under the name petition-for-rehearing. Rule 41 motions are in scope for this doc type per the brief; their text was not read (see gaps). Court: Court of Appeals of the State of Georgia. Folder: `courts/eleventh-circuit/georgia/state/court-of-appeals/petition-for-rehearing/`.

BLOCKED: no exemplar. No filed motion for reconsideration from this court could be downloaded (searches and reasons in `exemplars/SOURCE.md`). The sample is synthetic and written from the rules.

Status: exemplar=no, render=ok, overlay=fail (no exemplar PDF to overlay against), pages reviewed 5 of 5 (rendered at 60 dpi and looked at). Nothing here sets a `court.json` status.

## Governing rules

The rule text could not be read from the official source on this box: the rules PDF (`https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-9-Oct-2025.pdf`, "Eff 9 Oct 2025") and the gaappeals.us and state-rules.com copies returned HTTP 403, and courtrules.net returned a Cloudflare challenge. Each row is marked by how well it is supported. Nothing is quoted from the official text.

| ID | Rule (as cited) | Requirement | Verified? | Where it lives |
|---|---|---|---|---|
| GACA-FORM-001 | Ga. Ct. App. R. 24 (as cited by the checklist) | Letter paper, 8½ × 11 in. | Not verified; standard paper size assumed | `typst/gactapp-petition-for-rehearing.typ` (`paper`) |
| GACA-FORM-002 | Ga. Ct. App. R. 24 (checklist cites Rule 2(c)(2)) | Typeface: Times New Roman, regular, 14 pt, for printed or e-filed documents. Alternative for typed documents: no smaller than 10 characters per inch. | Secondary only: a WebSearch summary of the court's own checklist (sources not fetched). Rule number conflicts across sources. **Needs checking against the official text.** | `font-family`, `type-size` |
| GACA-FORM-003 | Ga. Ct. App. R. 24 (checklist cites Rule 2(c)(1)) | Double spacing, excluding quotations and footnotes. | Secondary only. | `body-leading` (line pitch 32.2 pt, measured) |
| GACA-FORM-004 | Not found | Margins. Template uses 1 in on all sides. | Not from a rule. Style assumption. | `margins` |
| GACA-FORM-005 | Ga. Ct. App. R. 24(c) (checklist) | Arabic page numbers at the bottom of each page. | Secondary only. | `numbering: "1"`, centred footer |
| GACA-CERT-001 | Ga. Ct. App. R. 37 (two third-party summaries: state-rules.com and courtrules.net, neither fetched) | A motion for reconsideration is prepared under Rule 24 and limited to 4,200 words; the signing attorney adds a word-count certification above the signature block. | Secondary only. **Needs checking.** | `word-count-certificate` (only when frontmatter has `word_count`); sample `word_count` |
| GACA-DEADLINE-001 | Ga. Ct. App. R. 37 (same summaries) | Filed within 10 days from the rendition of the judgment or dismissal; received by 4:30 p.m. on the last day. | Secondary only. Not enforced; the sample's opening sentence says it is timely, which is a sample assertion, not a check. | not enforced |
| GACA-GROUNDS-001 | Ga. Ct. App. R. 37(e) (summaries) | Grounds: the court overlooked a material fact, a controlling statute or decision, or erroneously construed a provision of law. | Secondary only. A 2015 filed example reportedly cites it; not confirmed. | sample opening section ("Grounds for Reconsideration") |
| GACA-SECOND-001 | Ga. Ct. App. R. 37 (summary) | A second motion for reconsideration needs the court's permission; without it the clerk returns the filing. | Secondary only. Not enforced. | not enforced |
| GACA-SIG-001 | Not verified | Signature block: firm, attorney, Georgia Bar number, address, telephone, email. | Convention. | `signature-block` |
| GACA-CERT-002 | Not verified (customary e-filing certificate of service) | Certificate of service on opposing counsel, with the method of service. | Convention. | `certificate-of-service` |
| GACA-RULE41-001 | Ga. Ct. App. R. 41 (named in the brief) | Rule 41 motions. Text not read. | **Not verified.** | not implemented |

## The typeface

- **Court-named face:** Times New Roman (per the court's checklist, see GACA-FORM-002).
- **Substitute:** Liberation Serif (`fonts/liberation-serif/`, SIL OFL 1.1), per `docs/FONTS.md`. Metric-compatible with Times New Roman.
- **Not used:** EB Garamond (the rule names a face; `docs/FONTS.md`, rule 3).
- **Size:** 14 pt, footnotes included. Headings are bold at the same size.

## Sample

- `samples/INPUT-rehearing-sample.md`: a synthetic Rule 37-style motion for reconsideration of an opinion (Appellant's motion for reconsideration, with four argument sections and a conclusion). Frontmatter carries the caption, title, signature, service, and `word_count: "2,048"`. Names, numbers and dates are invented. The statements about the opinion (its date, its holdings) describe a fictional case.
- The sample is 5 pages, below the eval-loop target of 8 to 14 pages. No exemplar to size against, so it was not padded.
- The sample's frontmatter has a `synthetic:` field stating it is not a transcription. Templates ignore unknown fields.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/eleventh-circuit/georgia/state/court-of-appeals/petition-for-rehearing samples/INPUT-rehearing-sample.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/state/court-of-appeals/petition-for-rehearing rehearing-sample
```

- `samples/OUTPUT-rehearing-sample.pdf`: 5 pages. Typst compiled with no warnings. `pdffonts`: LiberationSerif-Bold and LiberationSerif, both embedded.
- Output name: `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, as `tools/render.sh` and `tools/overlay.sh` name them; the brief's `<id>.pdf` naming was not used.
- Overlay: **fails**. `tools/overlay.sh` exits 1 with "no exemplar pdf in .../exemplars". No overlay PDF or page map was written.

## Visual review (Gate 2 record, all 5 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption, two-line bold title, opening paragraph, "Grounds for Reconsideration" heading | OK. Title wraps in two centred lines. |
| 2 | Argument heading, sections I, A, B | OK. Headings bold at 14 pt; double spacing even. |
| 3 | Argument II, III | OK. |
| 4 | Argument IV, Conclusion | OK. |
| 5 | Certificate of word count (above the signature), signature block (right half), certificate of service | OK. The signature block sits in the right half, the signer's name is printed once. |

Reviewed pages: 5 of 5.

## Fixes made during review

The same template fixes as `motion-brief/README.md` (its "Fixes made during review" list applies here unchanged):
1. Paragraph overlap at breaks (`spacing: 0pt` removed).
2. Double spacing measured at 32.2 pt line pitch.
3. Headings set to `type-size`.
4. Signature block moved to the right half; signer's name printed once.
5. Service certificate comma fixed.

## Known gaps and open choices

1. **Rule text unverified.** Every GACA-* requirement here is from a secondary source; the official rules could not be read. **Needs David's check** against the published rules, and Rule 37 in particular (word limit, word-count certificate placement, 10-day deadline, grounds subsection (e)).
2. **Rule 41** is named in the brief for this doc type, but its text was not read and no Rule 41 requirement is implemented.
3. **Exemplar.** None. Tier 2 conventions cannot be judged against filed examples. `BLOCKED: no exemplar`.
4. **Level-1 headings** are left-aligned, bold, upper case. Not from a rule.
5. **No word counter.** The certificate prints the frontmatter `word_count`; the template does not count words or check the 4,200-word limit.
6. **No table of contents or authorities.** Not generated; whether a reconsideration motion needs them is not verified.
7. **Margins** (1 in) are an assumption (GACA-FORM-004).
8. **Deadline and second-motion rules** (GACA-DEADLINE-001, GACA-SECOND-001) are not checked by the template; a filer must check them.

## Engines

docx (`docx/`: `reference.docx` from `make-reference.sh`, `gactapp-motion.lua`, `render.sh`; LibreOffice PDF is the checked copy).

- Matches the typst form: Liberation Serif 14 pt throughout; 1-inch margins, Letter; body double-spaced; half-inch first-line indent; cover with the court line, a two-column caption with a vertical rule, and the title centred; the body starts on the cover page, as in the typst form; every page numbered from 1 at the bottom centre; certificate of word count, signature block (3.25 in indent) and certificate of service follow the body.
- Differs: the typst motion template's double spacing is about 32 pt pitch and the docx uses Word's "double" (about 32 pt), so the line pitch matches; word wrapping and the signature-block spacing differ slightly. The docx runs one page longer (motion: typst 4, docx 5). The certificate of service heading is kept with its paragraph.
- Petition for rehearing (same form): the counsel address and signature spill to a new page in the docx sample (page 6), where the typst sample fits on 5 pages.
- BLOCKED: none for this doc type. `sh tools/check.sh --engine docx` was not run (no gate run in this bead; the .docx.pdf is rendered and every page was viewed at 60 dpi).
- Opened and rendered with LibreOffice only; not opened in Word.
