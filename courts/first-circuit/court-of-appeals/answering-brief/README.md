# First Circuit (ca1): answering brief (appellee's principal and response brief)

- Court: `ca1`, Court of Appeals for the First Circuit (`courts/first-circuit/court-of-appeals/`)
- Doc type: `answering-brief`. Brief of Appellee (FRAP 28(b)); one self-contained folder, no shared files.
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf` (*Griffin v. Massachusetts Department of Revenue*, No. 23-1668, filed 2024-01-02; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-answering-brief.md` (excerpt of the filed brief; see Known gaps).
- Status: template built; render and page review re-done 2026-10-14 (pages below). Overlay PDF not regenerated this run (see Overlay). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `ca1-brief`. |
| `typst/ca1-answering-brief.typ` | Template; the same code as the opening-brief template with its parameter block set for an appellee's brief: `word-limit = 13000`, `required-sections` = summary and argument (FRAP 28(b)), `needs-standard-of-review = false`, `addendum = "optional"`. |
| `usage/INPUT-answering-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/first-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md` (10 pages). |
| `usage/OVERLAY-griffin-answering-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/first-circuit/court-of-appeals/answering-brief griffin-answering-brief`. |
| `usage/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary source: the First Circuit Rulebook, "effective with amendments through June 1, 2026", <https://www.ca1.uscourts.gov/sites/ca1/files/rulebook.pdf> (read on 2026-10-13; page numbers are the rulebook's printed pages). FRAP text cross-checked against <https://www.law.cornell.edu/rules/frap/rule_32> on 2026-10-13.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRAP 28(b) | The appellee's brief conforms to FRAP 28(a)(1)-(8) and (10). The jurisdictional statement, statement of issues, statement of the case and standard-of-review statement need not appear unless the appellee disagrees with the appellant's (p. 57) | `required-sections` (summary, argument); `needs-standard-of-review = false` |
| FRAP 28(a)(1)-(3), (7), (8), (10) | Disclosure statement (if Rule 26.1 applies); TOC; TOA; summary; argument; certificate of compliance (p. 56-57) | `disclosure` field; TOC; TOA; summary; argument; `certificate-of-compliance` |
| FRAP 32(a)(2)(A)-(F) | Cover contents (rulebook pp. 67-68) | `cover-body` |
| FRAP 32(a)(4)-(6) | 8½ × 11; double-spaced, quotations single-spaced; margins at least 1 inch; 14-point or larger proportional serif; plain roman, case names italic (p. 68) | page, text, quotation, and footnote styles |
| FRAP 32(a)(5) (typeface) | Rule names no face: a proportionally spaced serif face, 14 pt or larger. No 1st Cir. local rule names a face (rulebook text read 2026-10-14). Court-named face: none | `font-family = "EB Garamond"` (kept, per `docs/FONTS.md` "No face named"); no substitute needed |
| FRAP 32(a)(7)(A), (B)(i) | Principal brief: 13,000 words (p. 68-69). An appellee's principal and response brief is a principal brief under FRAP 32(a)(7)(B)(i) | `word-limit = 13000` |
| FRAP 32(f) | Excluded from the count: cover, disclosure, TOC, TOA, oral-argument statement, addendum with statutes, certificate, signature block (pp. 69-70) | `strip-oral-argument`; markdown body only |
| FRAP 32(g)(1)-(2); Form 6 | Certificate of compliance, Form 6 wording (rulebook p. 113) | `certificate-of-compliance` |
| 1st Cir. R. 28.0(b)(1) | The appellee's brief may include an addendum to add materials (p. 58) | `addendum = "optional"` |
| 1st Cir. Notice to Litigants ¶¶ 2, 7; 1st Cir. R. 25.0(e) | Form per FRAP 32; certificate of service only where FRAP 25(d) requires one | `certificate-of-service`, optional |
| FRAP 32(a)(2) (cover color) | Appellee's brief: red (paper copies only) | not produced; see Known gaps |
| Checklist for Briefs, ca1 (rev. 3/22; secondary) | Footnotes the same size as the body text; disk rule (1st Cir. R. 32.0) only for paper | footnotes at 14 pt; no disk rule |

## Overlay

This run (2026-10-14): `tools/overlay.sh` could not write the PDF, because `usage/FILED-EXAMPLE-answering-brief.pdf` is not in this checkout (`usage/` holds only `SOURCE.md`). The `.txt` page map is unchanged from the earlier run, and the pairings below are from that run.

`usage/OVERLAY-griffin-answering-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only. Pairings from the last run:

- p.1 ↔ filed p.1 (83%), p.2 ↔ p.2 (39%), p.3 ↔ p.3 (24%): cover, TOC, TOA.
- p.4 ↔ p.6 (100%), p.5 ↔ p.7 (97%): statement of the issues, statement of the case, and the facts (the word sets nearly coincide).
- p.6 ↔ p.9 (55%), p.7 ↔ p.13 (70%): summary and argument I.A.
- p.8 ↔ p.25 (33%): argument end, conclusion and signature block.
- p.9 ↔ p.26 (63%), p.10 ↔ p.27 (51%): compliance certificate and service certificate.

## Page review (Gate 2)

Every page of `OUTPUT-answering-brief.typst.pdf` was rendered at 60 dpi and viewed (10 of 10). Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover | OK. Fits one page. |
| 2 | Table of contents | OK. |
| 3 | Table of authorities | First render listed "Fed. R. Civ. P. 12(b)(6)" on page i because a citation link in an argument heading was carried into the TOC. Fixed: the heading is plain text, and the template now refuses `toa:` links in headings. Re-checked: the TOA reads "1, 3". |
| 4 | Statement of the issues; statement of the case | OK. |
| 5 | Statement of the case (end); statement of facts A.; footnotes 1-2 | OK. |
| 6 | Summary of the argument with block quotation; argument heading I; A. | OK. |
| 7 | Argument I.A (continued) | OK. |
| 8 | Argument (end); conclusion; signature block | OK. |
| 9 | Certificate of compliance (Form 6 wording) | OK. Word count from the markdown (1,012). Certificate of service comma fixed on re-render. |
| 10 | Certificate of service | OK. |

Tier-2 findings (ACCEPTED): the typeface is EB Garamond where the filed brief uses Times New Roman (the rule names no face, so EB Garamond stays; see `docs/FONTS.md`). No other tier-2 finding is open on these ten pages.

## Known gaps

1. Cover color (red for the appellee) is not produced. FRAP 32(a)(2) applies to paper copies; the PDF is white.
2. The sample is an excerpt: it transcribes the cover, TOC, TOA, statement of the issues, statement of the case, the start of the facts with footnotes, the summary with its block quotation, Argument I.A, the conclusion and signature, and the certificates. The filed brief is 27 pages.
3. No addendum is transcribed (optional for the appellee under 1st Cir. R. 28.0(b)(1)). The template still renders an addendum section if `# Addendum` is present.
4. The word count is computed from the markdown body (`count-words`). It has not been cross-checked against the PDF text in this box.
5. The table of authorities is built only from `toa:` links. Every citation the filer wants listed must be linked. A link inside a heading is refused.
6. The template does not require a standard-of-review statement from an appellee (FRAP 28(b)(4)); when one is given, it is ordinary argument text. The sample includes one (Argument I.A).
7. The oral-argument section is excluded from the word count by heading match, a heuristic.
8. Typeface: EB Garamond is kept because the rulebook names no face. A filer who wants Times New Roman would use Liberation Serif (`docs/FONTS.md`); that would be a style choice, not a rule requirement.

## Engines

The typst template is the reference. The same sample is rendered in two more engines; each has its own output in `usage/`.

| Engine | Folder | Output | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-answering-brief.typst.pdf` (10 pages) | unchanged |
| latex | `latex/` (`template.tex` + `ca1.lua`, tectonic) | `usage/OUTPUT-answering-brief.latex.pdf` (10 pages) | renders; checked by eye, see below |
| docx | `docx/` (`reference.docx` + `ca1.lua`, pandoc) | `usage/OUTPUT-answering-brief.docx` | builds and validates; `.docx.pdf` BLOCKED (no LibreOffice) |

**LaTeX matches** (tier 1): EB Garamond 14 pt from `fonts/` only (`fontdir`), body double-spaced at the typst pitch (31.5 pt), 1 inch margins, footnotes 14 pt, roman front matter, arabic body, the cover (FRAP 32(a)(2)), the TOC and TOA with page numbers from the aux file, the certificates (Form 6 wording and the word count, 1012 words, equal to typst), the signature and the addendum with `Add-N` pages. No addendum in the sample; the addendum is optional here (1st Cir. R. 28.0(b)(1)), so none is rendered.

**LaTeX differs** (tier 2): the body breaks lines and pages a little differently, so the sample is 10 pages against typst's 10. The sub-heading paragraphs keep with the text below them by `\nobreak` only (`needspace` misfired in this box). The signature block is not kept with the last paragraph. Tectonic fetches TeX packages on its first run (cached afterwards).

**DOCX** (`usage/OUTPUT-answering-brief.docx`): the word count is 1012, equal to typst. The cover, certificates and signature use the custom styles in `reference.docx`; the sections give roman front matter, arabic body and (addendum briefs) `Add-N`.

BLOCKED (docx):
- `docx.pdf` checks (every gate on the LibreOffice PDF): BLOCKED, no `soffice` on this box (LibreOffice has no conda-forge package; `docs/DOCX.md`). No `usage/.check-docx.txt` stamp is written.
- Contents and authorities page numbers: no page numbers are printed. They need a first-pass layout, which needs LibreOffice. The entries list the headings and authorities only.
- Point headings of the Argument are Heading 2 (left), not centered small capitals.
- Check boxes are the text "[X]" (EB Garamond has no check-box glyph).
- Cover rule lines are not drawn in the docx.
- The `.docx` is not yet opened in Word or LibreOffice (no LibreOffice here), so the no-repair check is not done.

Build: `sh docx/make-reference.sh none` once (the output is committed), then `sh tools/render.sh --engine latex|docx <court-dir> usage/INPUT-answering-brief.md`. The docx command exits non-zero at the LibreOffice step after writing the `.docx`.
