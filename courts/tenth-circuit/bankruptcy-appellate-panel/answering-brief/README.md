# Tenth Circuit BAP (bap10): appellee's brief (FRBP 8014(b))

- Court: `bap10`, United States Bankruptcy Appellate Panel of the Tenth Circuit (`courts/tenth-circuit/bankruptcy-appellate-panel/`)
- Doc type: `answering-brief`. Rule basis: Fed. R. Bankr. P. Part VIII and 10th Cir. BAP Local Rules (see Governing rules).
- Exemplar: **none**. BLOCKED: no exemplar. Searched WebSearch (standard and extended), the CourtListener API (`court=bap10` RECAP: 0 documents; opinions only), Tenth Circuit RECAP (BAP-origin appeals are ca10 filings, not BAP filings), Justia dockets; only the court's own pro se guide sample brief was found (not a filing; it has no appellee brief). Searches are recorded in usage/SOURCE.md.
- Render: `usage/OUTPUT-answering-brief.typst.pdf` (typst, vendored Liberation Serif only). Overlay: **fail**, no exemplar PDF (`tools/overlay.sh` exits 1: "no FILED-EXAMPLE-answering-brief.pdf in usage").
- Sample: `usage/INPUT-answering-brief.md`. Fictional parties, real rule citations. It is a generic sample built to exercise the template, not a transcription of any filing.
- Status: template built and rendered; every page reviewed (see Page review). Not reviewed by a human; `court.json` untouched (status not set).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap10-brief`. |
| `typst/bap10-answering-brief.typ` | Template. Parameter block at the top (`doc-kind`, `word-limit`, `required-sections`, `needs-standard-of-review`); the rest is the shared body, identical in the three doc-type copies. |
| `usage/INPUT-answering-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md` |
| `.overlay/<doc path>/OVERLAY-answering-brief.pdf/.txt` | generated on demand; unavailable until a filed exemplar is stored. |
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
| FRBP 8014(b) (appellee) | Conforms to (a)(1)-(8) and (10). The jurisdictional statement, issues and standard, and case statement need not appear unless the appellee is dissatisfied with the appellant's | `required-sections` = summary and argument only; the conclusion is kept as convention, not rule (see Known gaps) |
| FRBP 8014(a)(5) | For each issue, a concise statement of the applicable standard of review | not required of the appellee (8014(b)(2)): `needs-standard-of-review = false` |
| FRBP 8014(d) | Statutes, rules and regulations that the decision requires are set out in the brief or an addendum | not supported (no addendum section; see Known gaps) |
| FRBP 8014(f) | Supplemental authorities: 350-word limit | not produced |

## Overlay

Not produced. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief answering-brief` exits 1 with "no FILED-EXAMPLE-answering-brief.pdf in usage", because there is no filed document to overlay. The red/blue test cannot run until an exemplar is stored.

## Page review (Gate 2)

Every page of `OUTPUT-answering-brief.typst.pdf` (7 pages) was rendered at 60 dpi and viewed.

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
12. The typeface is the vendored Liberation Serif (Times New Roman's metric twin, docs/FONTS.md), in the typst and docx renders alike.

## Build and check

    sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md
    sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief answering-brief   # fails until an exemplar exists

## Re-check 2026-10-15

- Exemplar: still **none** (BLOCKED: no exemplar). The searches of 2026-10-15 are logged at the end of `usage/SOURCE.md`. The BAP's own Briefs page posts no filed brief, only court-authored samples and forms.
- Render: `sh tools/render.sh` exit 0, no typst warnings, 7 pages. The output is `/work/artifacts/bap10/OUTPUT-answering-brief.pdf`, not `usage/`: the snapshot carries no PDFs, so the existing `usage/` names were not regenerated.
- Overlay: `sh tools/overlay.sh` exit 1. It finds no OUTPUT in `usage/`, and there is no exemplar to overlay even if there were. Not produced.
- Pages reviewed: 7 of 7. Every page was rasterised at 60 dpi and viewed on 2026-10-15. The Page review table above matches that render. No template change was made: with no exemplar, no open choice can be settled.
## Engines

**Cross-engine layout model (fb-595.54.5).** typst and docx share one layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`, `lib/docx/xengine-reference.sh`; docs/EVAL-LOOP.md, "Cross-engine gate"): first-fit line breaking on Unicode break opportunities, no hyphenation, kerning or ligatures, every line an exact box of its pitch (body 31.4 pt, single-spaced 20 pt, section headings 16 pt type in 23 pt lines), the spaces between blocks in points, the larger of two adjacent ones. typst is the reference; the docx render breaks every line and every page where it does, and `eval.yaml` gates that (`params.cross_engine: gate`; Gate 4 XENG-001..003). The design numbers did not change in the port (Liberation Serif 14 pt, the 2.245/1.425 em pitches, the em spaces now written in points); the section headings are 16 pt (were 1.15 em = 16.1 pt: Word has only half points), the point headings no longer ask for small capitals (Liberation Serif has none), the check box is a ruled box around an X, the signature blocks start at the middle of the text width, and the table of authorities sorts on the normalized key the template meant (a stray line had dropped the normalization).

**typst** (`typst/`): `show: xengine.with(pitch: 31.4pt, list-indent: 0.5in)`; contents and authorities rows with `listing-row` (the page in a 36 pt column, the authorities' in 56 pt or the list's own width); a loose list's paragraph breaks are dropped inside an item; "§§ 157" is kept together like "§ 157".

**docx** (`docx/`): `fb render` builds the reference document from `docx/reference.xml` (the shared recipe, `base="xengine"`: Liberation Serif 14 pt, the typst face, the typst pitches as exact line spacing; it replaced `build-reference.sh`); `docx/bap10.lua` writes the cover, front matter, headings, signature and certificates as paragraphs with the typst spaces, and pandoc writes the body on the reference styles. Build and render: `sh tools/render.sh --engine docx courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md`.

- Pages: `fb render` renders the document, finds every heading and citation in the LibreOffice PDF (the needles the filter writes) and renders again with those pages until they settle; the contents and authorities carry the same page numbers as typst. Three sections: no number on the cover, lowercase roman for the front matter, arabic from 1 for the body.
- Headings are not "keep with next" in Word: LibreOffice moved a kept heading and the whole paragraph after it to the next page when that paragraph split there with a widow line pulled over (typst splits it). The filter keeps a run of headings with the text after it from the page map instead: the run's first heading breaks the page when the previous pass left it at the foot of a page whose text went on to the next.
- The cover: the gap between its parts is typst's (the largest of 1, 0.8, 0.6 ... em that fits the page, estimated from Liberation Serif's advances); every cover line within 0.3 pt of typst's baseline.
- Same word count as typst (counted on the markdown source by the same rules; limit: 13,000 words).
- Not checked here: no Word open test, and Word's own pagination (the gate is LibreOffice's PDF; docs/DOCX.md).


## Exemplar batch re-check 2026-10-21

- **BLOCKED: no exemplar.** Searched exact-phrase web queries for Tenth Circuit BAP briefs, the BAP's official briefs page, CourtListener, and opinions/dockets for CO-19-043, 24-19, and 25-15. Only opinions and court-authored material surfaced; details are in `usage/SOURCE.md`.
- Render: **ok**. `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md` exited 0 and produced `usage/OUTPUT-answering-brief.typst.pdf` (7 pages; SHA-256 `14dd1318a9aecc87aa34f43945dfa2f1bedd1b1736e06415882ce9438ecd7863`).
- Overlay: **fail / unavailable**. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/answering-brief answering-brief` exited 1 because `FILED-EXAMPLE-answering-brief.pdf` is absent.
- Pages reviewed: **7/7**. All pages were rasterized with `pdftoppm -r 60` and viewed: cover; contents; authorities; summary and argument; conclusion/signature; compliance certificate; related-cases statement. No exemplar comparison or exemplar-led template change was possible.
