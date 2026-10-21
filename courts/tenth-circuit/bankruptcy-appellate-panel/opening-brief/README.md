# Tenth Circuit BAP (bap10): principal brief of the appellant (FRBP 8014(a))

- Court: `bap10`, United States Bankruptcy Appellate Panel of the Tenth Circuit (`courts/tenth-circuit/bankruptcy-appellate-panel/`)
- Doc type: `opening-brief`. Rule basis: Fed. R. Bankr. P. Part VIII and 10th Cir. BAP Local Rules (see Governing rules).
- Exemplar: **none**. BLOCKED: no exemplar. Searched WebSearch (standard and extended), the CourtListener API (`court=bap10` RECAP: 0 documents; opinions only), Tenth Circuit RECAP (BAP-origin appeals are ca10 filings, not BAP filings), Justia dockets; only the court's own pro se guide sample brief was found (not a filing). Searches are recorded in usage/SOURCE.md.
- Render: `usage/OUTPUT-opening-brief.typst.pdf` (typst, vendored EB Garamond only). Overlay: **fail**, no exemplar PDF (`tools/overlay.sh` exits 1: "no FILED-EXAMPLE-opening-brief.pdf in usage").
- Sample: `usage/INPUT-opening-brief.md`. Fictional parties, real rule citations. It is a generic sample built to exercise the template, not a transcription of any filing.
- Status: template built and rendered; every page reviewed (see Page review). Not reviewed by a human; `court.json` untouched (status not set).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap10-brief`. |
| `typst/bap10-opening-brief.typ` | Template. Parameter block at the top (`doc-kind`, `word-limit`, `required-sections`, `needs-standard-of-review`); the rest is the shared body, identical in the three doc-type copies. |
| `usage/INPUT-opening-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-opening-brief.typst.pdf` | `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md` |
| `.overlay/<doc path>/OVERLAY-opening-brief.pdf/.txt` | generated on demand; unavailable until a filed exemplar is stored. |
| `usage/SOURCE.md` | The search record. No exemplar file. |

Inputs and outputs follow the `usage/` naming convention. Overlays are written to the gitignored `.overlay/` tree and are not stored in `usage/`.

## Governing rules

Primary source: *Bankruptcy Rule and BAP Local Rules (eff. 1.1.2026)*, the combined Part VIII and 10th Cir. BAP Local Rules, <https://www.bap10.uscourts.gov/sites/bap10/files/clerk/Bankruptcy%20Rule%20and%20BAP%20Local%20Rules%20%28eff.%201.1.2026%29.pdf>. Fetched 2026-10-14 and text-extracted with `pdftotext`; the rule text quoted below was read from that extract on 2026-10-14. Rule numbers are the rulebook's.

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
| FRBP 8014(a)(4)-(9) (opening) | Jurisdictional statement; statement of issues with standard of review; statement of the case; summary of the argument; argument; conclusion | `required-sections` in `bap10-opening-brief.typ`, checked in order |
| FRBP 8014(a)(5) | For each issue, a concise statement of the applicable standard of appellate review | `needs-standard-of-review = true` (opening); a heuristic check (see Known gaps) |
| FRBP 8014(b) (appellee) | Conforms to (a)(1)-(8) and (10). The jurisdictional statement, issues and standard, and case statement need not appear unless the appellee is dissatisfied with the appellant's | `required-sections` = summary and argument only; the conclusion is kept as convention, not rule (see Known gaps) |
| FRBP 8014(c) (reply) | Reply complies with (a)(2)-(3): cover, TOC, TOA | no section required beyond the cover, TOC and TOA |
| FRBP 8014(d) | Statutes, rules and regulations that the decision requires are set out in the brief or an addendum | not supported (no addendum section; see Known gaps) |
| FRBP 8014(f) | Supplemental authorities: 350-word limit | not produced |

## Overlay

Not produced. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief opening-brief` exits 1 with "no FILED-EXAMPLE-opening-brief.pdf in usage", because there is no filed document to overlay. The red/blue test cannot run until an exemplar is stored. Nothing else in this folder stands in for it.

## Page review (Gate 2)

Every page of `OUTPUT-opening-brief.typst.pdf` was rendered at 60 dpi and viewed.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: BAP No., court name, caption with in-re line, bankruptcy line, proceeding, title, counsel with email | OK. Fits one page. |
| 2 | Table of contents (roman i) | OK after the TOC fix (see below). |
| 3 | Table of authorities (ii) | OK. Cases, statutes, rules; statute and rule entries show the cite only. |
| 4 | Oral-argument statement; statement of jurisdiction; statement of the issues and standard of review | OK. |
| 5 | Statement of the case (A., B., C.), summary of the argument, footnote 1 | OK. |
| 6 | Argument heading; I.A.1. | OK. Sub-headings are numbered by the template; the sample types no numbers. |
| 7 | Argument I.A (a.), I.B., II. point heading | OK. |
| 8 | Argument II (continued), III. point heading | ACCEPTED: the lower half is blank because the last paragraph is kept with the signature block (same rule as ca1 and ca9). |
| 9 | Conclusion; signature block | OK. |
| 10 | Certificate of compliance (word count 1,011, rule wording, checkbox) | OK. |
| 11 | Statement of related cases (last page, L.R. 8014-1) | OK. |

Tier-2 findings (OPEN or ACCEPTED): p.8 ACCEPTED (above). The point headings are centered small caps in the Argument, matching ca1. TOC leaders on a line that is nearly full can be a single dot; ACCEPTED (see Known gaps).

## TOC fix made during review

On the first render the TOC repeated the heading numbers ("I. I. ...") and a long point heading's page number wrapped to its own line. The first cause was the sample: its headings typed their own numbers, which the markdown contract forbids. The sample was corrected. The second cause was a fixed-width page-number box that did not fit on the last line; the box is now natural-width with a 0.35 em gap, and the page number stays flush right. The TOC pages were re-viewed after the change.

## Known gaps

1. **No exemplar.** This is the main gap: the template is built from the rules and the court's own sample, and nothing has been checked against a filed BAP opening brief. Overlay cannot run.
2. The sample is a generic fictional brief. Case names are real Supreme Court citations used only as examples (*Law v. Siegel*, *Stern v. Marshall*); the sample's argument is not legal analysis.
3. Page limit: FRBP 8015(a)(7)(A) (30 pages) is not checked; the template checks the word route only. A brief that exceeds 30 pages but stays under 13,000 words passes.
4. Form 417C: the certificate uses 8015(h) wording. Form 417C was not fetched and its substantial-conformity is unverified (8015(h)(2)).
5. Certificate of service: not produced. FRBP 8018 (service) was not reviewed in this pass.
6. Appendix references (L.R. 8015-1(c): brief must cite specific appendix pages) are not checked; the Brief and Appendix Checklist (Attachment 1 to the pro se guide) was not fetched.
7. Addendum (FRBP 8014(d), 8015(g)): not supported.
8. The oral-argument section is excluded by matching its heading text. A differently titled section would be counted.
9. The standard-of-review check (FRBP 8014(a)(5)) is a heuristic: it passes if the body says "standard of review" or any heading contains "standard".
10. The table of authorities is built from `toa:` links only; a citation that is not linked is not listed.
11. Cover color and paper-copy rules (FRBP 8015(a)(1), (3)) are not produced.
12. Leaders in the TOC can show a single dot on a nearly full line (accepted).
13. Only the vendored EB Garamond is available; no other typeface is vendored (`fonts/` is shared and not edited here).

## Build and check

    sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md
    sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief opening-brief   # fails until an exemplar exists

## Re-check 2026-10-15

- Exemplar: still **none** (BLOCKED: no exemplar). The searches of 2026-10-15 are logged at the end of `usage/SOURCE.md`. The BAP's own Briefs page posts no filed brief, only court-authored samples and forms.
- Render: `sh tools/render.sh` exit 0, no typst warnings, 11 pages. The output is `/work/artifacts/bap10/OUTPUT-opening-brief.pdf`, not `usage/`: the snapshot carries no PDFs, so the existing `usage/` names were not regenerated.
- Overlay: `sh tools/overlay.sh` exit 1. It finds no OUTPUT in `usage/`, and there is no exemplar to overlay even if there were. Not produced.
- Pages reviewed: 11 of 11. Every page was rasterised at 60 dpi and viewed on 2026-10-15. The Page review table above matches that render. No template change was made: with no exemplar, no open choice can be settled.
## Engines

**docx** (`docx/`): `build-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/bap10.lua` builds the cover, front matter, headings, signature and certificates from the same markdown. Build: `sh docx/build-reference.sh docx/reference.docx`; render: `sh tools/render.sh --engine docx courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md`.

- Matches the typst form: letter, 1 in margins; EB Garamond 14 pt body, footnotes and headings; double-spaced body (Word "double", auto 480) with a 0.5 in first-line indent; single-spaced headings, quotations and footnotes; cover with no page number; front matter in lowercase roman; body in arabic from 1 (three sections); Argument point headings centered; heading labels (I. A. 1. a. in the Argument, A. 1. a. (1) elsewhere); word count and length check on the same markdown rule as typst (limit: 13,000 words); certificate of compliance; statement of related cases as the last page.
- Differs from typst: heading labels are typed text, not list numbering; the certificate checkbox is "[X]", not a drawn box; the front matter and body are separate Word sections, and a cover that fills the page may push its empty section-break paragraph onto a new page in Word or LibreOffice; the required-section order check runs in typst only (not repeated in the Lua filter); no keep-with-signature rule.
- BLOCKED, docx.pdf gates (Gates 0 and 1 on `OUTPUT-opening-brief.docx.pdf`): LibreOffice (`soffice`) is not installed on this box, so no `.docx.pdf` was made and no page was rendered or viewed (pages reviewed: 0).
- BLOCKED, table of contents page numbers: the TOC is a TOC field whose cached entries have no page numbers; Word or LibreOffice fills them only after a field update. LibreOffice needs an update on load (see docs/DOCX.md).
- BLOCKED, table of authorities page references: no page numbers are written (a TOA field is not honored by LibreOffice, and no first-pass page numbers are generated). The authorities list itself is complete.
- Not checked here: no Word open test (no repair prompt), font embedding (EB Garamond must be installed on the reader's machine; the file names it), and Word vs LibreOffice pagination of the cover (one page is typst-checked only).

## Exemplar batch re-check 2026-10-21

- **BLOCKED: no exemplar.** Searched exact-phrase web queries for opening briefs, the BAP's official briefs page, CourtListener, and opinions/dockets for CO-19-043, 24-19, and 25-15. The found Rusk opening brief was filed in the Tenth Circuit Court of Appeals, not the BAP; the other results were opinions or court-authored material. Details are in `usage/SOURCE.md`.
- Render: **ok**. `sh tools/render.sh courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md` exited 0 and produced `usage/OUTPUT-opening-brief.typst.pdf` (11 pages; SHA-256 `6a5b1d8a7ab866f39d44fea062ee19384c89a50299ba8fd9ccdf95d942452e72`).
- Overlay: **fail / unavailable**. `sh tools/overlay.sh courts/tenth-circuit/bankruptcy-appellate-panel/opening-brief opening-brief` exited 1 because `FILED-EXAMPLE-opening-brief.pdf` is absent.
- Pages reviewed: **11/11**. All pages were rasterized with `pdftoppm -r 60` and viewed: cover; contents; authorities; oral-argument/jurisdiction/issues; case statement and summary; argument pages 1–3; conclusion/signature; compliance certificate; related-cases statement. Page 1's caption block appears crowded in this render; left unchanged because no filed exemplar was found to establish a convention or guide a permitted adjustment.
