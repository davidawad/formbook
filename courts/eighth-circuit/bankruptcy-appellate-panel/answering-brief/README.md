# Eighth Circuit BAP (bap8): answering brief (appellee's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `samples/` are untouched.
- Doc type: `answering-brief`. Appellee's brief, FRBP 8014(b).
- **Exemplar: BLOCKED: no exemplar.** No public filed appellee's brief from this court was found after 20 searches in two passes, plus three direct fetch attempts (listed in `exemplars/SOURCE.md`). Nothing is stored in `exemplars/`. The one public BAP brief found (the debtor's opening brief in BAP No. 11-6012) is the opening-brief exemplar.
- Template: built from the rules. Render (2026-10-15, ok, 9 pages) and full page review done (Gate 2 below). Overlay: fail, no exemplar (see Overlay). Exemplar re-searched 2026-10-15 (nine more searches, `exemplars/SOURCE.md` pass 3): still none.
- Status: rule-driven template plus a synthetic rule-check sample. `court.json` untouched; `status` not set.
- Typeface: rule names no face (FRBP 8015(a)(5)(A)); kept **EB Garamond**, 14 pt. Re-rendered 2026-10-14 with `tools/render.sh` (zero warnings); `pdffonts`: only EB Garamond embedded. Overlay re-run: fail, no exemplar PDF in `exemplars/`.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-answering-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(b): summary, argument), `needs-standard-of-review = false`. |
| `samples/INPUT-synthetic-answering-brief.md` | Markdown contract sample. Placeholder prose and counsel; not a transcription of any filing. |
| `exemplars/SOURCE.md` | Blocked exemplar search log. |
| Render output | `sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief samples/INPUT-synthetic-answering-brief.md` writes `samples/OUTPUT-synthetic-answering-brief.pdf`; rendered 2026-10-14 (ok, 9 pages, no typst warnings). |

## Markdown contract (frontmatter)

Same as `opening-brief/README.md`: `case_number`, `caption`, `proceeding`, `brief_title`, `counsel`, `phone`, `email`, `signature`, `date`, `word_processor`, `typeface`, `interested_parties`, `related_cases`, `disclosure` (optional), `service`, `authorities`. Body citations are `[text](toa:key)`.

## Governing rules

Primary sources, read on 2026-10-14:
- FRBP 8014 and 8015 (restyled, as amended Apr. 2, 2024, eff. Dec. 1, 2024), text from <https://www.law.cornell.edu/rules/frbp/rule_8014> and <https://www.law.cornell.edu/rules/frbp/rule_8015>. This is a mirror of the official text; the official text was not fetched.
- Committee Notes to FRBP 8015 (2014, 2018, 2020, 2024), same page.
- Local Rules of the United States Bankruptcy Appellate Panel for the Eighth Circuit, December 2023 version, <https://ecf.ca8.uscourts.gov/newbap/rules/localrules_bapDec2023.pdf>, read with `pdftotext` on 2026-10-14: L.R. BAP 8th Cir. 8014A(a)-(c), 8015A.
- Not fetched: Official Form 417C; FRBP 8012; the BAP Internal Operating Procedures.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 8014(b) | Appellee's brief conforms to 8014(a)(1)-(8) and (10). Jurisdiction, issues and case (8014(a)(4)-(6)) need appear only if the appellee is dissatisfied with the appellant's statement. The list has no conclusion item (8014(a)(9)). | `required-sections` = summary of argument, argument; `needs-standard-of-review = false` |
| FRBP 8014(a)(7)-(8), (10) | Summary of argument; argument; certificate of compliance if required | section check; `certificate-of-compliance` |
| FRBP 8015(a)(7)(B)(i) | Principal-brief type-volume limit: 13,000 words, read as applying to the appellee's principal brief (see Known gaps) | `word-limit = 13000` |
| FRBP 8015(a)(2), (a)(4), (a)(5)(A), (a)(6), (g), (h) | Cover contents; layout and margins; 14 pt serif; plain roman; exclusions from length; certificate | as in `opening-brief/README.md` (same template body) |
| L.R. BAP 8th Cir. 8014A(b)(1)-(2) | Certification of Interested Parties; Certification of Related Cases | `certifications` |
| L.R. BAP 8th Cir. 8014A(c) | Service certificate for a paper copy to a non-participant | `certificate-of-service` |
| FRBP 8014(d) | No addendum section; a `# Addendum` heading is refused | as in `opening-brief/README.md` |

## Gate 2: page review

Every page of the rule-check render was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed after the final render. Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover (BRIEF OF APPELLEE) | OK. |
| 2 | Certification of Interested Parties (i) | OK. |
| 3 | Certification of Related Cases (ii) | OK. |
| 4 | Table of Contents (iii) | OK. Summary, argument headings, conclusion. |
| 5 | Table of Authorities (iv) | OK. |
| 6 | Summary of argument; Argument I (A, B); Argument II (1) | OK. |
| 7 | Conclusion; signature block (2) | OK. Signature block stays with the last paragraph. |
| 8 | Certificate of Compliance (3); 195 words | OK. |
| 9 | Certificate of Service (4) | OK. |

Pages reviewed: 9 of 9 (all re-viewed 2026-10-15 as PNG at 60 dpi after a fresh render; rows above unchanged).

## Overlay

Run 2026-10-15 (also 2026-10-14): `sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief synthetic-answering-brief` exits 1 ("no exemplar pdf"). No `OVERLAY-` file is written. Status: fail.

## Known gaps

- **No exemplar, so no tier-2 check.** Nothing is compared to a filed brief. The sample is synthetic rule-check text and does not meet the 8-14 page depth bar.
- **Word limit for an appellee's brief.** FRBP 8015(a)(7)(B)(i) speaks of a "principal brief" and does not define it for the appellee. The template reads the 13,000-word limit as applying to the appellee's brief, by analogy to FRAP 32(a)(7). This reading is not confirmed against the BAP.
- **Conclusion not required.** 8014(b) does not list the conclusion, so the template does not require one. The sample includes one as a convention.
- **Overlay tool does not match this layout** (see the opening brief README).
- **Renders are in `samples/`** (`OUTPUT-synthetic-answering-brief.pdf`). PNG review copies are in `/work/artifacts/bap8/answering-brief/`.
- **Word count** comes from the markdown body and is not cross-checked against the PDF text.
- **Standard-of-review check** is turned off for this type (8014(b)(2)). The template does not detect a dissatisfied appellee.
- **Certificate wording** is not verified against Form 417C.
- **Certifications placement:** before the TOC, by choice.
- **Cover color:** none (FRBP 8015 has no cover-color rule).

## Engines

**docx** (`docx/`: `reference.docx`, `build-reference.sh`, `front.jq`, `brief.lua`, `render.sh`). `samples/OUTPUT-synthetic-answering-brief.docx` and `.docx.pdf` (LibreOffice). 9 pages, the same count as typst for this sample. `pdffonts` on the PDF: only EB Garamond embedded.

- Matches typst: the same form as the opening brief (font, size, spacing, margins, cover, contents, authorities, certificates, page numbering). The certificate of compliance word count is 195, the same as typst.
- Differs: the certificate checkbox is the text `[X]`, not a drawn box; contents and authorities are build-time text with page numbers measured on the LibreOffice PDF, not Word fields; headings are paragraph styles with outline levels.
- BLOCKED: none for this engine. `tools/check.sh --engine docx` has not been run for this folder: it needs `court.json` and `checks.yaml`, which this folder does not have.
