# Eighth Circuit BAP (bap8): opening brief (appellant's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `samples/` are untouched.
- Doc type: `opening-brief`. Appellant's brief, FRBP 8014(a).
- **Exemplar: BLOCKED: no exemplar.** No public filed opening brief from this court was found after eight searches (listed in `exemplars/SOURCE.md`). Nothing is stored in `exemplars/`.
- Template: built from the rules. Render and page review done (Gate 2 below). Overlay not run: there is no exemplar (see Known gaps).
- Status: rule-driven template plus a synthetic rule-check sample. `court.json` untouched; `status` not set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(a)(4)-(9) order), `needs-standard-of-review`. |
| `samples/INPUT-synthetic-opening-brief.md` | Markdown contract sample. Placeholder prose and counsel; not a transcription of any filing. |
| `exemplars/SOURCE.md` | Blocked exemplar search log. |
| Render output | `sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief samples/INPUT-synthetic-opening-brief.md` writes `samples/synthetic-opening-brief.pdf`. The PDF was then moved to `/work/artifacts/bap8/opening-brief/` (not committed; the repo carries no PDFs). |

## Markdown contract (frontmatter)

`case_number` (printed after "BAP No."), `caption` (list of `{names, designation}`; the template prints "v." between sides), `proceeding`, `brief_title`, `counsel` (list of `{names, lines}`), `phone`, `email`, `signature` (`signer`, `for`, `lines`), `date`, `word_processor`, `typeface`, `interested_parties` and `related_cases` (markdown; L.R. BAP 8014A(b)), `disclosure` (optional; FRBP 8014(a)(1)), `service` (`certificate`; `unregistered` list of `name`/`address`), `authorities` (key: `{kind: case|statute|rule|constitution|regulation|other, cite, name}`). Body citations are `[text](toa:key)`; a `toa:` link in a heading is refused. An authority cited in the body must be in `authorities`.

## Governing rules

Primary sources, read on 2026-10-14:
- FRBP 8014 and 8015 (restyled, as amended Apr. 2, 2024, eff. Dec. 1, 2024), text from <https://www.law.cornell.edu/rules/frbp/rule_8014> and <https://www.law.cornell.edu/rules/frbp/rule_8015>. This is a mirror of the official text; the official text was not fetched.
- Committee Notes to FRBP 8015 (2014, 2018, 2020, 2024), same page. Used for: no cover-color rule (2014 note); the 2020 note on the e-filing change to the proof-of-service requirement (FRBP 8011(d)).
- Local Rules of the United States Bankruptcy Appellate Panel for the Eighth Circuit, December 2023 version, <https://ecf.ca8.uscourts.gov/newbap/rules/localrules_bapDec2023.pdf>, read with `pdftotext` on 2026-10-14: L.R. BAP 8th Cir. 8014A(a)-(c), 8015A.
- Not fetched: Official Form 417C (type-volume certificate); FRBP 8012 (disclosure statement); the BAP Internal Operating Procedures (only a search snippet was read).

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 8014(a)(1)-(10) | Order: disclosure (if 8012), TOC, TOA, jurisdiction, issues with standard of review, case, summary, argument, conclusion, certificate of compliance | `required-sections`, `needs-standard-of-review`, `disclosure`, `certificate-of-compliance` |
| FRBP 8014(a)(4)(A)-(D) | Jurisdiction: bankruptcy court, BAP, timeliness, final order | section heading check only; content not checked |
| FRBP 8015(a)(2)(A)-(F) | Cover: case number at top; court name; case title (8003(d)(2)); nature of proceeding and court below; brief title; counsel name, address, telephone and email | `cover-body` |
| FRBP 8015(a)(4) | 8.5 x 11; double spaced; long quotations may be single spaced; headings and footnotes single spaced; margins at least 1 inch | `page`, `body-leading`, quote and footnote styles |
| FRBP 8015(a)(5)(A) | Proportional face with serifs, 14 pt or larger | `type-size = 14pt`; `font-family = "EB Garamond"` (the only vendored serif) |
| FRBP 8015(a)(6) | Plain roman; italics or bold for emphasis; case names italic or underlined | markdown emphasis; the template does not guess case names |
| FRBP 8015(a)(7)(B)(i) | Principal brief: 13,000 words (or 1,300 monospaced lines), with certificate | `word-limit = 13000` (panic when exceeded) |
| FRBP 8015(g) | Excluded from length: cover, disclosure, TOC, TOA, oral-argument statement, statute addendum, certificate, signature block, proof of service. Headings, footnotes and quotations count. | `strip-oral-argument`; cover, TOC, TOA, certificates and signature sit outside the body count |
| FRBP 8015(h)(1)-(2) | Type-volume certificate; Form 417C substantially conforming | `certificate-of-compliance` (wording not checked against Form 417C) |
| L.R. BAP 8th Cir. 8014A(b)(1)-(2) | Certification of Interested Parties; Certification of Related Cases | `certifications`. Placement before the TOC is a choice; the rule does not fix it. |
| L.R. BAP 8th Cir. 8014A(a) | Record citations identify docket entry, page and line | not checked; the markdown text is the only input |
| L.R. BAP 8th Cir. 8014A(c) | CM/ECF service; paper copy to a non-participant with a certificate stating date, method and address | `certificate-of-service`, shown when `service.unregistered` is given or `service.certificate` is true |
| FRBP 8014(d) | Statutes set out in the brief or in an addendum | no addendum section; a `# Addendum` heading is refused |

## Gate 2: page review

Every page of the rule-check render was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: BAP No., court, caption, proceeding, title, counsel with email | OK. One page, unnumbered. |
| 2 | Certification of Interested Parties (i) | OK after a fix: the "BAP No." line ran into the paragraph. A paragraph break now separates them. Re-viewed after the fix. |
| 3 | Certification of Related Cases (ii) | OK. |
| 4 | Table of Contents (iii) | OK. Body headings and subheadings. The Table of Authorities is not listed (fixed: it had listed itself). |
| 5 | Table of Authorities (iv) | OK. Statutes and Rules groups; page column. |
| 6 | Statement regarding oral argument; jurisdiction; issues with standard of review; statement of the case (1) | OK. |
| 7 | Statement of the case, facts (2); summary of argument; Argument I heading | OK. White space at the foot of the page: the sticky heading block moves Argument II down. |
| 8 | Argument II, A and B | OK. |
| 9 | Argument III; conclusion; signature block (4) | OK. The signature block stays with the last paragraph. |
| 10 | Certificate of Compliance (5) | OK. Word count 587 (body markdown). |
| 11 | Certificate of Service (6) | OK. |

Pages reviewed: 11 of 11. Pages 1, 3 and 4 were viewed in the render before the certification paragraph-break fix. That fix changes only page 2, and page 2 was re-viewed after it.

## Overlay

Not run. `tools/overlay.sh` needs `exemplars/*.pdf` and `samples/OUTPUT-<id>.pdf`; neither exists for this folder. Run with the sample id, it exits 1 ("no render"; `ls` error on the missing exemplar).

## Known gaps

- **No exemplar, so no tier-2 check.** Nothing is compared to a filed brief. The sample is synthetic rule-check text, not a transcription, so it does not meet the 8-14 page depth bar that an exemplar would set.
- **Overlay tool does not match this layout.** `tools/overlay.sh` reads `samples/OUTPUT-<id>.pdf` and `exemplars/*.pdf`. This folder uses `samples/<id>.pdf` and has no exemplar. The shared tool was left unchanged.
- **Renders are not in the tree.** The repo carries no PDFs. The rule-check PDFs are at `/work/artifacts/bap8/opening-brief/`.
- **Word count** comes from the markdown body (`count-words`), not from the PDF text, and is not cross-checked against it.
- **Standard-of-review and oral-argument checks are heuristics.** The first passes if the body says "standard of review" or a heading contains "standard"; the second matches a heading containing "oral argument".
- **Cover color:** none. FRBP 8015 has no cover-color rule (2014 Committee Note).
- **Page limit:** only the type-volume (word) limit is enforced; the 30-page limit of 8015(a)(7)(A) is not counted.
- **Form 417C wording** is not verified. The certificate uses the FRAP Form 6 wording adapted to FRBP 8015 citations.
- **Typeface:** EB Garamond is the only vendored serif. 8015(a)(5)(A) requires a proportional serif at 14 pt or more, so the choice is compliant on its face. No BAP filing was checked for typeface.
- **Certifications placement:** before the TOC, by choice (see the rules table).
- **Disclosure statement:** rendered only when `disclosure` is given. The template does not decide whether FRBP 8012 applies.
- **Jurisdiction content** (8014(a)(4)(A)-(D)) is not checked beyond the heading.
