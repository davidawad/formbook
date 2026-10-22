# Tenth Circuit BAP (bap10): reply brief of the appellant (FRBP 8014(c); 15 pages or 6,500 words)

- Court: `bap10`, United States Bankruptcy Appellate Panel of the Tenth Circuit (`courts/tenth-circuit/bankruptcy-appellate-panel/`)
- Doc type: `reply-brief`. Rule basis: Fed. R. Bankr. P. Part VIII and 10th Cir. BAP Local Rules (see Governing rules).
- Exemplar: **none**. BLOCKED: no exemplar. Searched WebSearch (standard and extended), the CourtListener API (`court=bap10` RECAP: 0 documents; opinions only), Tenth Circuit RECAP (BAP-origin appeals are ca10 filings, not BAP filings), Justia dockets; only the court's own pro se guide sample brief was found (not a filing; it has no reply brief). Searches are recorded in usage/SOURCE.md.
- Render: `usage/OUTPUT-reply-brief.typst.pdf` (typst, vendored Liberation Serif). Overlay: **fail**, no exemplar PDF (`tools/overlay.sh` exits 1: "no FILED-EXAMPLE-reply-brief.pdf in usage").
- Sample: `usage/INPUT-reply-brief.md`. Fictional parties, real rule citations. It is a generic sample built to exercise the template, not a transcription of any filing.
- Status: template built and rendered; every page reviewed (see Page review). Not reviewed by a human; `court.json` untouched (status not set).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap10-brief`. |
| `typst/bap10-reply-brief.typ` | Template. Parameter block at the top (`doc-kind`, `word-limit`, `required-sections`, `needs-standard-of-review`); the rest is the shared body, identical in the three doc-type copies. |
| `usage/INPUT-reply-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-reply-brief.typst.pdf` | `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief usage/INPUT-reply-brief.md` |
| `.overlay/<doc path>/OVERLAY-reply-brief.pdf/.txt` | generated on demand; unavailable until a filed exemplar is stored. |
| `usage/SOURCE.md` | The search record. No exemplar file. |

Inputs and outputs follow the `usage/` naming convention. Overlays are written to the gitignored `.overlay/` tree and are not stored in `usage/`.

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
| FRBP 8014(c) (reply) | Reply complies with (a)(2)-(3): cover, TOC, TOA | no section required beyond the cover, TOC and TOA |
| FRBP 8014(a)(5) | For each issue, the standard of review | not required of a reply (8014(c)): `needs-standard-of-review = false` |
| FRBP 8014(f) | Supplemental authorities: 350-word limit | not produced |

## Overlay

Not produced. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief reply-brief` exits 1 with "no FILED-EXAMPLE-reply-brief.pdf in usage", because there is no filed document to overlay. The red/blue test cannot run until an exemplar is stored.

## Page review (Gate 2)

Every page of `OUTPUT-reply-brief.typst.pdf` (7 pages) was rendered at 60 dpi and viewed.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: BAP No., court name, caption, bankruptcy line, proceeding, title, counsel with email | OK. Fits one page. |
| 2 | Table of contents (roman i) | OK after the TOC fix (see below): the long point heading II keeps its page number on the same line. |
| 3 | Table of authorities (ii) | OK. Statute only. |
| 4 | Argument I and II (reply body, page 1) | OK. |
| 5 | Conclusion; signature block (page 2) | OK. |
| 6 | Certificate of compliance (word count 129; checkbox; rule wording) | OK. |
| 7 | Statement of related cases (last page) | OK. |

Tier-2 findings (OPEN or ACCEPTED): none OPEN. The reply is short by design; the template adds no statement of the case.

## TOC fix made during review

The first render wrapped the page number of the long point heading "II. The proceeds provision is a concession, not a remedy" onto its own line, because the fixed-width page-number box did not fit on the last line. The box is now natural-width with a 0.35 em gap, so the page number stays flush right on the same line. Page 2 was re-viewed after the change.

## Known gaps

1. **No exemplar.** Built from the rules and the court's own sample. No filed BAP reply brief was found; the layout is not checked against a filing. Overlay cannot run.
2. The sample is a generic fictional reply brief; its single citation (11 U.S.C. § 363) is an example only.
3. Reply length: the word limit (6,500) is half of the principal limit under 8015(a)(7)(B)(ii). The 15-page limit under 8015(a)(7)(A) is not checked.
4. Form 417C: the certificate uses 8015(h) wording; substantial conformity to Form 417C is unverified (8015(h)(2)).
5. Certificate of service: not produced (FRBP 8018 not reviewed in this pass).
6. Appendix references (L.R. 8015-1(c)) are not checked.
7. The oral-argument section is excluded by matching its heading text (not used in this sample).
8. The table of authorities is built from `toa:` links only.
9. Cover color and paper-copy rules are not produced.
10. The face is the vendored Liberation Serif (the metric twin of Times New Roman, docs/FONTS.md); Times New Roman itself is not vendored.

## Build and check

    sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief usage/INPUT-reply-brief.md
    sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief reply-brief   # fails until an exemplar exists

## Re-check 2026-10-15

- Exemplar: still **none** (BLOCKED: no exemplar). The searches of 2026-10-15 are logged at the end of `usage/SOURCE.md`. The BAP's own Briefs page posts no filed brief, only court-authored samples and forms.
- Render: `sh tools/render.sh` exit 0, no typst warnings, 7 pages. The output is `/work/artifacts/bap10/OUTPUT-reply-brief.pdf`, not `usage/`: the snapshot carries no PDFs, so the existing `usage/` names were not regenerated.
- Overlay: `sh tools/overlay.sh` exit 1. It finds no OUTPUT in `usage/`, and there is no exemplar to overlay even if there were. Not produced.
- Pages reviewed: 7 of 7. Every page was rasterised at 60 dpi and viewed on 2026-10-15. The Page review table above matches that render. No template change was made: with no exemplar, no open choice can be settled.
## Engines

**docx** (`docx/`), rebuilt 2026-10-21 (fb-595.63). `docx/reference.xml` holds the Word styles; fb render builds `reference.docx` from it and pandoc's default reference (`tools/fb/src/docxref.rs`; it replaces `build-reference.sh` and the committed `reference.docx`). `docx/bap10.lua` builds the cover, front matter, headings, signature and certificate from the same markdown. The contents and authorities pages come from fb render's multi-pass docx engine (`tools/fb/src/docxpass.rs`, as ca9 and ca10): the filter writes a needle for every heading and citation, fb render finds them in the LibreOffice PDF and renders again until the pages settle; the footers are fb render's (`rIdFtrNone` on the cover, `rIdFtrPage`), the last section is the filter's (`FORMBOOK_FINAL`). Render: `sh tools/render.sh --engine docx courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief usage/INPUT-reply-brief.md`.

- Matches the typst form: letter, 1 in margins; Liberation Serif 14 pt body, footnotes and headings, the typst face (embedded: LiberationSerif Regular, Bold, Italic only; the docx named EB Garamond before, so DEF-FONT-002 failed); body lines exact 628 twips (31.4 pt, the typst body pitch of 2.245 em: double spacing, FRBP 8015(a)(4)) with a 0.5 in first-line indent; section headings 16 pt bold capitals, centered; Argument point headings bold, centered (no synthesized small capitals: Liberation Serif has none, typst draws them plain); other headings with the label at its half-inch step and the title hanging after it; single-spaced headings, quotations, footnotes and front matter; cover with the typst rules (double under the case number and at the foot, 2 in rules between the parts), designations and counsel from the middle of the text; cover with no page number; front matter in lowercase roman; body in arabic from 1 (three sections); TOC with dot leaders and page numbers (ii, 1, 1, 1, 2, 3, the same as typst) and TOA with "Page(s)" and page references (FRBP 8014(a)(2)-(3)); the signature block kept with the last paragraph (Conclusion moves to page 2, as typst); word count and length check on the same markdown rule as typst (limit 6,500; count 129, typst's); certificate of compliance naming the frontmatter's `typeface` (Liberation Serif, the face actually used) and a bordered "X" check box; statement of related cases as the last page (page 4). 7 pages, as typst.
- Differs from typst (tier 2, not chased): heading positions at the top of a page differ by a few points (Word section starts and page-break-before headings); the cover spacing is fixed (typst fits the largest gap); a parenthesis token such as "8015(a)(5)" may break between ")(" in the certificate (typst keeps it whole); the required-section order check runs in typst only. Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
- `sh tools/check.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief --engine docx`: RESULT 10 checks passed, 0 failed (2026-10-21). Every page of the 7-page `.docx.pdf` was viewed. BLOCKED: none.

## Exemplar batch re-check 2026-10-21

- **BLOCKED: no exemplar.** Searched exact-phrase web queries for BAP reply briefs, the BAP's official briefs page, CourtListener, and opinions/dockets for CO-19-043, 24-19, and 25-15. Only opinions and court-authored material surfaced; details are in `usage/SOURCE.md`.
- Render: **ok**. `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief usage/INPUT-reply-brief.md` exited 0 and produced `usage/OUTPUT-reply-brief.typst.pdf` (7 pages; SHA-256 `817f7cf1a46aeacae9c7ee42df66991f4658045ea8995d70930a8577602deede`).
- Overlay: **fail / unavailable**. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/reply-brief reply-brief` exited 1 because `FILED-EXAMPLE-reply-brief.pdf` is absent.
- Pages reviewed: **7/7**. All pages were rasterized with `pdftoppm -r 60` and viewed: cover; contents; authorities; argument; conclusion/signature; compliance certificate; related-cases statement. No exemplar comparison or exemplar-led template change was possible.
