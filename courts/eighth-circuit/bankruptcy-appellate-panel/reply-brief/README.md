# Eighth Circuit BAP (bap8): reply brief

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `samples/` are untouched.
- Doc type: `reply-brief`. Appellant's reply brief, FRBP 8014(c).
- **Exemplar: BLOCKED: no exemplar.** No public filed reply brief from this court was found after eight searches, including one aimed at reply briefs (listed in `exemplars/SOURCE.md`). Nothing is stored in `exemplars/`.
- Template: built from the rules. Render and page review done (Gate 2 below). Overlay not run: there is no exemplar (see Known gaps).
- Status: rule-driven template plus a synthetic rule-check sample. `court.json` untouched; `status` not set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-reply-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (6,500), `required-sections` (none beyond the tables), `needs-standard-of-review = false`. |
| `samples/INPUT-synthetic-reply-brief.md` | Markdown contract sample. Placeholder prose and counsel; not a transcription of any filing. |
| `exemplars/SOURCE.md` | Blocked exemplar search log. |
| Render output | `sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/reply-brief samples/INPUT-synthetic-reply-brief.md` writes `samples/synthetic-reply-brief.pdf`. The PDF was then moved to `/work/artifacts/bap8/reply-brief/` (not committed). |

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
| FRBP 8014(c) | Reply brief must comply with 8014(a)(2)-(3): table of contents and table of authorities | `toc-section`, `toa-section`; `required-sections = ()` (no other section mandated) |
| FRBP 8015(a)(7)(B)(ii) | Reply brief: no more than half the principal-brief type-volume limit (6,500 words), with certificate | `word-limit = 6500` (panic when exceeded) |
| FRBP 8015(a)(2), (a)(4), (a)(5)(A), (a)(6), (g), (h) | Cover contents; layout and margins; 14 pt serif; plain roman; exclusions from length; certificate | as in `opening-brief/README.md` (same template body) |
| L.R. BAP 8th Cir. 8014A(b)(1)-(2) | Certification of Interested Parties; Certification of Related Cases (the local rule covers "the brief", not only the principal briefs) | `certifications` |
| L.R. BAP 8th Cir. 8014A(c) | Service certificate for a paper copy to a non-participant | `certificate-of-service` |
| FRBP 8014(d) | No addendum section; a `# Addendum` heading is refused | as in `opening-brief/README.md` |

## Gate 2: page review

Every page of the rule-check render was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover (REPLY BRIEF OF APPELLANT) | OK. |
| 2 | Certification of Interested Parties (i) | OK. |
| 3 | Certification of Related Cases (ii) | OK. |
| 4 | Table of Contents (iii): Argument I, II and Conclusion | OK. |
| 5 | Table of Authorities (iv): one rule | OK. |
| 6 | Argument I and II | OK. Blank space at the foot of the page: the conclusion moves to page 7 with its signature block. Re-viewed after a one-word wording change. |
| 7 | Conclusion; signature block (2) | OK. |
| 8 | Certificate of Compliance (3); 127 words | OK. |
| 9 | Certificate of Service (4) | OK. |

Pages reviewed: 9 of 9.

## Overlay

Not run. `tools/overlay.sh` needs `exemplars/*.pdf` and `samples/OUTPUT-<id>.pdf`; neither exists for this folder. Run with the sample id, it exits 1 ("no render"; `ls` error on the missing exemplar).

## Known gaps

- **No exemplar, so no tier-2 check.** Nothing is compared to a filed reply brief. The sample is synthetic rule-check text.
- **No section is mandated.** 8014(c) requires only the tables. The template does not require an argument or a conclusion; the sample includes both as a convention.
- **Scope of the reply is not checked.** The template does not confirm that the reply answers only matter raised in the appellee's brief.
- **Overlay tool does not match this layout** (see the opening brief README).
- **Renders are not in the tree.** The rule-check PDF is at `/work/artifacts/bap8/reply-brief/`.
- **Word count** comes from the markdown body and is not cross-checked against the PDF text.
- **Certificate wording** is not verified against Form 417C.
- **Certifications placement:** before the TOC, by choice.
- **Cover color:** none (FRBP 8015 has no cover-color rule).
