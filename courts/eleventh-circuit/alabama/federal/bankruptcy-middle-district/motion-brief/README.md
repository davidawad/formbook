# M.D. Alabama Bankruptcy Court: motion (`almb`)

Doc-type folder for a motion with its grounds in numbered paragraphs (a contested matter in the main case). Engine: typst (`typst/`). Parent court: [`../README.md`](../README.md).

- Exemplar: **none** (see `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-synthetic-stay-motion.md`. **Synthetic**: not transcribed from a filing. Every party, number and date is invented, and placeholders are bracketed.
- Render: `samples/OUTPUT-synthetic-stay-motion.pdf` (5 pages, EB Garamond embedded, no typst warnings) via `sh tools/render.sh <this-dir> samples/INPUT-synthetic-stay-motion.md`. **render=ok** (2026-10-15).
- Overlay: **fail**, not produced. `sh tools/overlay.sh <this-dir> synthetic-stay-motion` exits 1 ("no exemplar pdf in exemplars"). There is nothing to overlay against, so tier 2 cannot be judged.
- Depth: the sample was extended from the 3-page stub to 5 pages with the structure a motion needs (caption, `#` and `##` headings, numbered runs 1-22, a block quotation, prayer, signature block, certificate on its own page). **Below the 8-14 page target.** The target assumes a real exemplar of that length. No exemplar exists, and padding a synthetic sample with invented text would test nothing.

## Engines

- **typst** (primary): `typst/`, as above.
- **docx**: `docx/reference.docx` (built by `sh docx/make-reference.sh`) and `docx/almb-motion-brief.lua` (the court title, caption, title, signature block and certificate of service; the body stays pandoc's). `sh tools/render.sh --engine docx <this-dir> samples/INPUT-synthetic-stay-motion.md` writes `samples/OUTPUT-synthetic-stay-motion.docx`, then stops: `soffice` is not on the build box, so no `samples/OUTPUT-synthetic-stay-motion.docx.pdf` exists.
- **Matches the typst form** (the reference styles and filter, checked in the `.docx` XML and its text, not by eye): letter with 1-inch margins; EB Garamond 13 pt in every style; body double-spaced at exactly 24 pt with a 0.5 in first-line indent; the caption as a table with a boxed left column and the case number and chapter at right, no adversary number; centered bold level-1 headings in caps at 18 pt (the typst heading scale); `##` subheadings bold and left-aligned, kept with the paragraph after; the prayer kept with the signature block; the signature block single-spaced and unbreakable; the certificate of service on its own page; a centered "-N-" page number at 11 pt in the footer.
- **Differs or is unverified**: (a) no page of the docx has been rendered or viewed, so line breaks, page count, caption box spacing and footer position are not checked against the typst pages; Word and LibreOffice may paginate differently. (b) The block quotation is single-spaced with 0.5 in indents on both sides, set by eye from the typst page; it is not measured. (c) The numbered grounds are literal numbers in ordinary paragraphs, not Word list numbering. (d) The core document title is empty: the frontmatter is cleared so pandoc does not print a Title paragraph above the caption.
- **docx BLOCKED** (see `docs/DOCX.md`):
  - `tools/check.sh --engine docx`, Gates 0 and 1 on the `.docx.pdf`: BLOCKED. `soffice` is not installed and conda-forge has no LibreOffice package. The `.docx` passes the render step's zip and XML checks; the PDF conversion does not run.
  - Gate 2 on the docx: BLOCKED, same cause. `pages_reviewed=0`.
  - Opening in LibreOffice and Word without a repair prompt: not performed (neither is installed).
  - `tools/check.sh` for any engine: BLOCKED for this court. It needs `court.json` and `checks.yaml`, and this court has neither yet.

## Rules (requirement IDs)

Verified 2026-10-14 from the primary text. Kind: **M** mandated by a rule, **C** convention, **A** author responsibility.

| ID | Requirement | Kind | Source (verified) |
|---|---|---|---|
| ALMB-MOT-001 | A motion must state its grounds with particularity and set forth the relief or order requested. | M | FRBP 9013(b), https://www.law.cornell.edu/rules/frbp/rule_9013 ("A motion must state its grounds with particularity and set forth the relief or order requested."). Last amended 2024-04-02, eff. 2024-12-01. The template's numbered grounds section is the author's; the rule does not fix the layout. |
| ALMB-MOT-002 | The caption shows the court name, the case title, the case number and a brief designation of the document. A main-case motion has no adversary number. | M | FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14; last amended 2024-04-02, eff. 2024-12-01). |
| ALMB-MOT-003 | The document is legible. | M | FRBP 9004(a), same URL. |
| ALMB-MOT-004 | Every signed paper has a signature block at the end of the text with the full name of each signer, a complete mailing address, a telephone number and an email address. `/s/` is acceptable. | M | LBR 9011-1(a)-(b), M.D. Ala. Local Rules effective 2017-12-01 (PDF `almb.uscourts.gov/sites/almb/files/Local_Rules_Dec_1_%202017.pdf`, p. 48). Not checked against the 2024 local rules (see Gaps). |
| ALMB-MOT-005 | A motion for relief from the automatic stay states with specificity why the relief is requested, and attaches legible copies of the documents that support the claimed interest in the debtor's property (mortgages on real property show their recording information). | M | LBR 4001-1(a)(1)-(2) (M.D. Ala. Local Rules effective 2017-12-01, p. 34). Read this session from the 2017 text. The 2024 text was not checked. The synthetic sample does not attach Exhibit A, so this requirement is not met by the sample as delivered; it is an author responsibility there. |
| ALMB-MOT-006 | A certificate of service accompanies the motion. The template prints it when `certificate` is in the frontmatter. | C | No local rule text checked for motions this session. The draft 2023 local-rule table lists "9013-3 Certificates of service for motions" and "7005-1 Certificates of service in adversary proceedings", but the adopted text was not retrieved. Treat the requirement as C until verified. |
| ALMB-MOT-007 | No typography, margin or spacing rule in the local rules. Font, size, margins and double spacing are the template's style choices, matched to the adversary complaint in this court. | C | 2017 local rules, full text searched for font, margin, point size, spacing: none. |

## What the overlay shows

Nothing. There is no exemplar, so no overlay is produced.

## Template changes in the depth pass

- `##` lines render as bold, left-aligned subheadings kept with the paragraph after them. Before this, every `#` line was a centred level-1 heading, so the sample's `## A. ...` subheadings would have looked like Roman-numeral sections.

## Gate 2 review

Depth pass, 2026-10-15: every page of `samples/OUTPUT-synthetic-stay-motion.pdf` (5 pages) was rendered at 60 dpi and viewed. Page 1 caption and first headings, page 2 numbered runs and subheadings, page 3 the block quotation and section IV, page 4 section V, the prayer and the signature block (checked again after the telephone placeholder fix), page 5 the certificate on its own page. The sample's own telephone placeholder had been parsed as emphasis (`___`) and printed as `[(__) -]`; it now reads `[TELEPHONE]`. The template renders the markdown, so the sample text is the thing to fix, not the template.

No row is recorded against a filed exemplar, because there is none. This is a visual check of the template, not a tier-2 review.

Known render behaviour, not yet judged against a filing: the certificate of service is a single paragraph with no signature line; the caption's left box and the right column are set from the template's own widths.

## Exemplar searches (depth pass, 2026-10-15)

Not found. Tried after `exemplars/SOURCE.md` (2026-10-14):

- WebSearch (standard): `"Middle District of Alabama" bankruptcy "motion for relief from stay" courtlistener almb`. Returned hearing calendars on almb.uscourts.gov only.
- WebSearch (standard): `"Bankr. M.D. Ala." motion for relief from automatic stay "Exhibit A"`. Returned LR 4001-1 text (courtrules.net) and form templates, no filed motion.
- WebSearch (extended): almb motion for relief from stay filed document, Northern Division, 2024-2025. Returned govinfo published opinions (for example 24-80619, 20-30619, 25-30256 consent order) and the court's local-forms page. Opinions and orders are not the motions. The consent order in 25-30256 (Doc. 1618) is an order, not a movant's filing. The govinfo opinions cite the motions but are not the motions.

**BLOCKED: no exemplar.** A filed almb motion for relief from stay would close the gap: find its RECAP docket by case number (e.g. 25-30256, 24-80619), save `exemplars/FILED-EXAMPLE-<name>-motion.pdf`, transcribe it into `samples/INPUT-<id>.md`, then run the overlay.

## Gaps

- **No exemplar.** The brief asks for a public filed exemplar and a transcribed sample. None was found (see `exemplars/SOURCE.md`). Until one is added, the sample is synthetic and tier 2 cannot be judged.
- **Local rules currency.** The rules cited are the 2017 set. The 2024 set (effective 2024-04-01, which the court's ECF notes refer to) includes LBR 9013-1 "Motion Practice" and LBR 9013-3 "Certificates of service for motions" per the 2023 draft table of contents; the adopted text was not retrieved. Those requirements are not encoded here.
- **Service.** FRBP 9014(b) (service of a motion in a contested matter) was not fetched this session; the certificate text is a placeholder, not a checked statement of the service method.
- **No gate run.** `tools/check.sh` and `tools/check-selftest.sh` were not run for this doc type.

## Run status (2026-10-15)

- **exemplar=no.** No filed almb motion was found. Two more WebSearch passes (standard mode) returned only court hearing calendars and an order template from almb.uscourts.gov; no RECAP motion PDF. `exemplars/` holds no PDF, so the transcription and overlay steps in this README could not be done.
- **render=ok** on the existing synthetic sample only: `sh tools/render.sh <this-dir> samples/INPUT-synthetic-stay-motion.md` wrote `samples/OUTPUT-synthetic-stay-motion.pdf` (3 pages). This is a template check, not a filed-form comparison, and is below the 8-14 page bar.
- **overlay=fail.** `sh tools/overlay.sh <this-dir> synthetic-stay-motion` exits 1 with "no exemplar pdf"; no OVERLAY file was written.
- **pages_reviewed=3** (all three pages of the synthetic render were viewed as PNG). Page 1 caption and headings, page 2 grounds and signature block, page 3 certificate of service: render layout is clean; content is placeholder text.
- Still needed: a RECAP-hosted almb motion (see the Gaps above), then a real INPUT transcription and overlay.
