# Eighth Circuit BAP (bap8): reply brief

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `usage/` are untouched.
- Doc type: `reply-brief`. Appellant's reply brief, FRBP 8014(c).
- **Exemplar: BLOCKED: no qualifying text PDF found.** Five search passes are recorded in `usage/SOURCE.md`. A public appellate filing confirms a reply brief was filed in BAP No. 22-6009, but the accessible copy found is a scanned, non-searchable Eighth Circuit filing, not the BAP reply PDF. Nothing is stored in `usage/`.
- Sample: still the synthetic rule-check sample `usage/INPUT-reply-brief.md` (placeholder text, not a filing). Its first caption side now sets `v: false` (see Template changes).
- Render: ok, `usage/OUTPUT-reply-brief.typst.pdf`, 9 pages, Typst 0.15.1 with no warnings (2026-10-21). `pdffonts`: Times New Roman (regular, bold, and italic; embedded).
- Overlay: fail as expected because there is no filed exemplar. `sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/reply-brief reply-brief` reports `no FILED-EXAMPLE-reply-brief.pdf` (2026-10-21).
- Pages reviewed: all 9 output pages rasterized at 60 dpi and inspected (2026-10-21). They are synthetic, so there is no filed page comparison.
- Status: rule-driven template plus a synthetic sample. `court.json` untouched; `status` not set.
- Typeface: the rules require a 14-point or larger serif face but do not name one; the template uses **Times New Roman**, 14 pt, matching the filed brief's typeface.

## Template changes this run (2026-10-16)

`typst/bap8-reply-brief.typ` received the five changes made to the answering-brief template (the two files differ only in the parameter block); see `../answering-brief/README.md`, "Template changes this run": caption `v: false`; court name wraps before "for the Eighth Circuit"; the L.R. BAP 8014A(b)(1) lead sentence and optional `appeal_title` in the interested-parties certification; optional `preliminary` front matter; page references in the tables in their own column. They were settled by the answering-brief exemplar (BAP No. 22-6006) and the opening-brief exemplar, and by the local rule's form text; none was settled by a reply brief.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-reply-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (6,500), `required-sections` (none beyond the tables), `needs-standard-of-review = false`. |
| `usage/INPUT-reply-brief.md` | Markdown contract sample. Placeholder prose and counsel; not a transcription of any filing. |
| `usage/SOURCE.md` | Blocked exemplar search log. |
| Render output | `sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/reply-brief usage/INPUT-reply-brief.md` writes `usage/OUTPUT-reply-brief.typst.pdf`; rendered 2026-10-14 (ok, 9 pages, no typst warnings). |

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

Render rechecked 2026-10-21 with Typst 0.15.1, every page rasterized at 60 dpi (`pdftoppm -r 60`) and inspected. Typst printed no warnings. No filed reply exemplar was available for comparison; these rows record only the synthetic sample's visible structure.

| Page | Content | Result |
|---|---|---|
| 1 | Cover (REPLY BRIEF OF APPELLANT) | OK. Court name now wraps before "FOR THE EIGHTH CIRCUIT"; no "v." after the In re line. Re-viewed after the sample change. |
| 2 | Certification of Interested Parties (i) | OK. Now opens with the L.R. BAP 8014A(b)(1) lead sentence. |
| 3 | Certification of Related Cases (ii) | OK. |
| 4 | Table of Contents (iii): Argument I, II and Conclusion | OK. Page numbers in their own column. |
| 5 | Table of Authorities (iv): one rule | OK. |
| 6 | Argument I and II (1) | OK. Space at the foot of the page: the conclusion moves to page 7 with its signature block. |
| 7 | Conclusion; signature block (2) | OK. |
| 8 | Certificate of Compliance (3); 127 words | OK. |
| 9 | Certificate of Service (4) | OK. |

Pages reviewed: 9 of 9 output pages.

## Overlay

Run 2026-10-21: exits 1 (`no FILED-EXAMPLE-reply-brief.pdf`). No overlay is written. Status: fail because the exemplar is blocked.

## Known gaps

- **No exemplar, so no tier-2 check against a filed reply.** The sample is synthetic rule-check text and does not meet the 8-14 page depth bar.
- **No section is mandated.** 8014(c) requires only the tables. The template does not require an argument or a conclusion.
- **Scope of the reply is not checked** (that it answers only matter raised in the appellee's brief).
- **Word count** comes from the markdown, not the PDF text.
- **Certificate wording** is not verified against Form 417C.
- **Certifications placement:** before the TOC; the answering-brief exemplar does the same.
- **Cover color:** none (FRBP 8015 has no cover-color rule).

## Engines

**docx** (`docx/`). `usage/OUTPUT-reply-brief.docx` and `.docx.pdf` were built on 2026-10-15 and are **stale**: they predate this run's sample and template change (the docx still prints "v." after the In re line and lacks the 8014A(b)(1) lead sentence). Not rebuilt: `soffice` (LibreOffice) is not on this box. The docx build (`front.jq`, `brief.lua`) also does not know the new fields `appeal_title`, `caption[].v`, `preliminary`. BLOCKED: docx re-render (no LibreOffice here); docx front matter must be brought up to the typst template.

**latex**: none in this folder.
