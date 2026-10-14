# Tenth Circuit BAP (bap10): appellee's brief (FRBP 8014(b))

- Court: `bap10`, United States Bankruptcy Appellate Panel of the Tenth Circuit (`courts/tenth-circuit/bankruptcy-appellate-panel/`)
- Doc type: `answering-brief`. Rule basis: Fed. R. Bankr. P. Part VIII and 10th Cir. BAP Local Rules (see Governing rules).
- Exemplar: **none**. BLOCKED: no exemplar. Searched WebSearch (standard and extended), CourtListener (WebFetch returned HTTP 403), Justia dockets; only the court's own pro se guide sample brief was found (not a filing; it has no appellee brief). Searches are recorded in exemplars/SOURCE.md.
- Render: `samples/OUTPUT-generic-answering-brief.pdf` (typst, vendored EB Garamond only). Overlay: **fail**, no exemplar PDF (`tools/overlay.sh` exits 1: "no exemplar pdf in exemplars").
- Sample: `samples/INPUT-generic-answering-brief.md`. Fictional parties, real rule citations. It is a generic sample built to exercise the template, not a transcription of any filing.
- Status: template built and rendered; every page reviewed (see Page review). Not reviewed by a human; `court.json` untouched (status not set).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap10-brief`. |
| `typst/bap10-answering-brief.typ` | Template. Parameter block at the top (`doc-kind`, `word-limit`, `required-sections`, `needs-standard-of-review`); the rest is the shared body, identical in the three doc-type copies. |
| `samples/INPUT-generic-answering-brief.md` | Markdown contract sample (frontmatter + body). |
| `samples/OUTPUT-generic-answering-brief.pdf` | `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief samples/INPUT-generic-answering-brief.md` |
| `samples/OVERLAY-generic-answering-brief.*` | not produced: no exemplar (see Overlay). |
| `exemplars/SOURCE.md` | The search record. No exemplar file. |

File names follow the tools' convention (`INPUT-`/`OUTPUT-`/`OVERLAY-` plus the sample id), so `tools/render.sh` and `tools/overlay.sh` find them without extra arguments.

## Governing rules

Primary source: *Bankruptcy Rule and BAP Local Rules (eff. 1.1.2026)*, the combined Part VIII and 10th Cir. BAP Local Rules, <https://www.bap10.uscourts.gov/sites/bap10/files/clerk/Bankruptcy%20Rule%20and%20BAP%20Local%20Rules%20%28eff.%201.1.2026%29.pdf>. Fetched 2026-10-14 and text-extracted with `pdftotext`; the rule text was read from that extract on 2026-10-14.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 8015(a)(2)(A)-(F) | Cover: case number centered at top; name of the court; title of the case (8003(d)(2)); nature of proceeding and court below; title of brief identifying the party; counsel's name, office address, telephone, and **email** | `cover-body`: `BAP No.` line, court name, caption (`in_re` and `caption`), `bankruptcy`, `proceeding`, `brief_title`, `counsel` with `phone` and `email` |
| L.R. 8015-1(a) | The front cover is satisfied by the caption this Court provides | the cover follows the caption of the court's own sample (pro se guide) |
| FRBP 8015(a)(4) | 8½ × 11; double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; margins at least 1 inch on all sides | `page`, `body-leading`, `page-margin`, quote and footnote styles |
| FRBP 8015(a)(5)(A); L.R. 8015-1(b) | Proportional face with serifs, 14-point or larger. The local rule accepts 12-point; footnotes the same size as the body | `type-size = 14pt` for body, headings, footnotes. 14 meets both |
| FRBP 8015(a)(6) | Plain roman; italics or boldface for emphasis; case names italicized or underlined | markdown emphasis; the template does not guess case names |
| FRBP 8015(a)(7)(A) | Principal brief: not more than 30 pages; reply: 15 pages, unless the type-volume limit of (B) is met | not enforced by page count. Only the word route is checked (see Known gaps) |
| FRBP 8015(a)(7)(B)(i) | Principal brief: no more than 13,000 words, with a certificate under (h) | `word-limit = 13000` (opening and answering) |
| FRBP 8015(a)(7)(B)(ii) | Reply brief: no more than half of (B)(i): 6,500 words | `word-limit = 6500` (reply) |
| FRBP 8015(g) | Excluded from length: cover, disclosure statement (8012), TOC, TOA, oral-argument statement, addendum with statutes, certificate of counsel, signature block, proof of service. Headings, footnotes, quotations count | `strip-oral-argument` (heading matching "oral argument"); the rest is outside the counted body |
| L.R. 8015-1(d) | The Statement of Related Cases (L.R. 8014-1) is excluded from the length limits | the related-cases page is generated after the body and is not counted |
| FRBP 8015(h)(1); 8014(a)(10) | Certificate of compliance for a brief under 8015(a)(7)(B): states the word count | `certificate-of-compliance` (rule wording; see Known gaps on Form 417C) |
| FRBP 8015(h)(2) | A certificate that conforms substantially to Form 417C satisfies (h) | not verified: Form 417C was not fetched |
| L.R. 8014-1 | Last page of the brief: a statement of related cases pending before the Supreme Court, a court of appeals, a district court, or a BAP | `related-cases-page`, the last page, required by `related_cases` in the frontmatter (default: none) |
| FRBP 8014(a)(1); 8012 | Disclosure statement, if required, before the TOC | optional `disclosure` field, rendered before the TOC |
| FRBP 8014(a)(2)-(3) | Table of contents with page references; table of authorities with page references (cases, statutes, other authorities) | `toc-section`, `toa-section`; authorities come from `toa:` links and the `authorities:` registry (an unregistered key stops the build) |
| FRBP 8014(b) (appellee) | Conforms to (a)(1)-(8) and (10). The jurisdictional statement, issues and standard, and case statement need not appear unless the appellee is dissatisfied with the appellant's | `required-sections` = summary and argument only; the conclusion is kept as convention, not rule (see Known gaps) |
| FRBP 8014(a)(5) | For each issue, a concise statement of the applicable standard of review | not required of the appellee (8014(b)(2)): `needs-standard-of-review = false` |
| FRBP 8014(d) | Statutes, rules and regulations that the decision requires are set out in the brief or an addendum | not supported (no addendum section; see Known gaps) |
| FRBP 8014(f) | Supplemental authorities: 350-word limit | not produced |

## Overlay

Not produced. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief generic-answering-brief` exits 1 with "no exemplar pdf in `exemplars`", because there is no filed document to overlay. The red/blue test cannot run until an exemplar is stored.

## Page review (Gate 2)

Every page of `OUTPUT-generic-answering-brief.pdf` (7 pages) was rendered at 60 dpi and viewed.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: BAP No., court name, caption, bankruptcy line, proceeding, title, counsel with email | OK. Fits one page. |
| 2 | Table of contents (roman i) | OK. The dot leader on the long point heading "…Sale Finding" is short but present. |
| 3 | Table of authorities (ii) | OK. Only the authorities the sample cites (cases; statutes). |
| 4 | Summary of the argument; Argument I (A., B.); point II | OK. |
| 5 | Point II (continued); conclusion; signature block | OK. |
| 6 | Certificate of compliance (word count 213; checkbox; rule wording) | OK. |
| 7 | Statement of related cases (last page) | OK. |

Tier-2 findings (OPEN or ACCEPTED): none OPEN. The answering brief has no statement of jurisdiction, issues or case, as FRBP 8014(b) allows; the template does not add them. The conclusion is included as convention.

## Known gaps

1. **No exemplar.** Built from the rules and the court's own sample. No filed BAP answering brief was found, so the layout is not checked against a filing. Overlay cannot run.
2. The sample is a generic fictional brief; it is not legal analysis and its citations (*Law v. Siegel*, 11 U.S.C. § 363) are used only as examples.
3. Reading of 8015(a)(7)(B)(i): the template treats the appellee's brief as a principal brief (13,000 words). The rule text does not say so for the appellee's brief in terms; this is a reading, not verified against a BAP order.
4. The conclusion is not listed in FRBP 8014(b). The template keeps it because it is standard practice; it is not enforced.
5. Page limit (30 pages) not checked; only the word route is checked (8015(a)(7)(A)).
6. Form 417C: the certificate uses 8015(h) wording; substantial conformity to Form 417C is unverified (8015(h)(2)).
7. Certificate of service: not produced (FRBP 8018 not reviewed in this pass).
8. Appendix references (L.R. 8015-1(c)) are not checked.
9. The oral-argument section is excluded by matching its heading text.
10. The table of authorities is built from `toa:` links only.
11. Cover color and paper-copy rules are not produced.
12. Only the vendored EB Garamond is available.

## Build and check

    sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief samples/INPUT-generic-answering-brief.md
    sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief generic-answering-brief   # fails until an exemplar exists
