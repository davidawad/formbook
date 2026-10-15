# M.D. Alabama Bankruptcy Court: motion (`almb`)

Doc-type folder for a motion with its grounds in numbered paragraphs (a contested matter in the main case). Engine: typst (`typst/`). Parent court: [`../README.md`](../README.md).

- Exemplar: **none** (see `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-synthetic-stay-motion.md`. **Synthetic**: not transcribed from a filing. Every party, number and date is invented, and placeholders are bracketed.
- Render: `samples/OUTPUT-synthetic-stay-motion.pdf` (3 pages) via `sh tools/render.sh <this-dir> samples/INPUT-synthetic-stay-motion.md`.
- Overlay: **not produced.** `sh tools/overlay.sh <this-dir> synthetic-stay-motion` exits 1 ("no exemplar pdf"). There is nothing to overlay against.

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

## Gate 2 review

All three pages of `samples/OUTPUT-synthetic-stay-motion.pdf` were rendered at 80 dpi and viewed. The caption, the centred Roman-numeral headings, the numbered grounds, the prayer, the signature block and the certificate of service page look as the template intends. No row is recorded against a filed exemplar, because there is none. This is a visual check of the template, not a tier-2 review.

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
