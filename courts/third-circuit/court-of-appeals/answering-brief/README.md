# Third Circuit: answering brief (appellee's brief)

One self-contained folder for one document type. Built by fb-595.28.19 from one filed exemplar; the template is a copy of the ca9 opening-brief structure, not its numbers.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-binder-v-coldwell-banker-24-1997-answering-brief.pdf` | The filed exemplar (appellee brief, 30 pp., text layer). Provenance in `exemplars/SOURCE.md`. |
| `samples/INPUT-binder-answering-brief.md` | Markdown transcription of a portion of the exemplar (cover, disclosure, headings, tables, jurisdiction, issue, statement of the case, standard of review, most of Argument I, part of II and III, conclusion, signature, certificates). Frontmatter follows the ca9 contract plus one new field, `disclosure`. |
| `samples/OUTPUT-binder-answering-brief.pdf` | `sh tools/render.sh courts/third-circuit/court-of-appeals/answering-brief samples/INPUT-binder-answering-brief.md` |
| `samples/OVERLAY-binder-answering-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/third-circuit/court-of-appeals/answering-brief binder-answering-brief` (red = ours, blue = filed, black = both). |
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...`. |
| `typst/ca3-answering-brief.typ` | The template: `ca3-answering-brief(meta, md)`. Content-agnostic; no case text, no coordinates from the exemplar, no forced line breaks. |

## Governing rules

Sources are the FRAP text as published by LII (fetched 2026-10-14) and the Third Circuit Local Appellate Rules PDF on ca3.uscourts.gov (`2011_LAR_Final.pdf`, fetched 2026-10-14). **The LAR text is the 2011 edition. It is the only Third Circuit rule text this box could retrieve, and it has not been checked against a current edition. Re-verify every L.A.R. citation before relying on it.**

| Rule | Requirement | Where the template applies it | Verified |
|---|---|---|---|
| FRAP 32(a)(2) | Cover: case number at top, court name, case title, nature of proceeding and court below, brief title identifying the party, counsel's name, office address, telephone | `cover-body` | LII text, 2026-10-14 |
| FRAP 32(a)(4) | Letter paper; double-spaced, quotations over two lines may be single-spaced and indented; margins at least 1 inch on all four sides | `page-margin = 1in`, `body-leading`, quotations | LII text, 2026-10-14 |
| FRAP 32(a)(5) | Proportionally spaced serif face, 14-point or larger; sans-serif allowed in headings and captions | `font-family` (EB Garamond, vendored), `type-size = 14pt` | LII text, 2026-10-14 |
| FRAP 32(a)(6) | Plain roman; italics or bold for emphasis; case names italicized or underlined | author writes `*Case v. Name*`; the template does not guess | LII text, 2026-10-14 |
| FRAP 32(a)(7)(B)(i) | Principal brief: no more than 13,000 words (appellee's brief uses the same limit) | `limit = 13000` in `ca3-brief`; the build stops above it | LII text, 2026-10-14 |
| FRAP 32(f) | Exempt from the count: cover, disclosure, tables, signature block, certificates | `count-words` counts the markdown body only | LII text, 2026-10-14 |
| FRAP 32(g)(1), (g)(2), Form 6 | Certificate of compliance stating the word count and typeface/type-style compliance | `certificate-of-compliance` | LII text, 2026-10-14 (Form 6 wording reproduced from memory; the form itself not fetched) |
| FRAP 26.1 | Corporate disclosure statement in the brief | `disclosure-section`, when the frontmatter has `disclosure` | **not fetched in this box**; the exemplar carries one, and the template treats it as optional |
| FRAP 25(d) | Certificate of service | `certificate-of-service`, when the frontmatter has `service` | **not fetched in this box** |
| L.A.R. 28.1(b), 28.2 | Standard of review statement under its own heading (the 28.2 cross-reference applies 28.1(b) to appellee's brief) | sample heading "The Standard of Review"; no template check yet | 2011 LAR text |
| L.A.R. 28.2 (cross-ref. 28.1(a)(2)) | Statement of related cases, read as applying to the appellee's brief | **not generated** (see Known gaps) | 2011 LAR text; to verify |
| L.A.R. 28.3(d) | Certification that at least one attorney on the brief is a member of the bar of the court | `bar-certificate` | 2011 LAR text |
| L.A.R. 31.1(b)(2), (c) | Electronic brief in PDF; certification that its text is identical to the paper copies, and that a virus check was run, with the version of the program | `electronic-certificate` (the program and version are left blank for counsel to fill) | 2011 LAR text |
| L.A.R. 32.1(b), (c), (d), (e) | Margins at least 1 in. sides and 3/4 in. top and bottom; typeface per FRAP 32(a)(5)-(6); PDF, one file; redaction of personal identifiers | margins and typeface as above; PDF output | 2011 LAR text |
| L.A.R. 32.2(a) | Footnotes in the same size type as the text | `footnote.entry` set to `type-size` | 2011 LAR text |

## What the overlay shows

The overlay pairs each sample page with the filed page sharing the most words, so a partial transcription still lines up. The word-overlap per page is in `samples/OVERLAY-binder-answering-brief.txt`.

- Cover, disclosure, first table page: 68% to 87% word overlap with the filed pages 1 to 3. Table of authorities (ours p. 4): 45%. The layout is the same family: caption centered, short rules, counsel block at the bottom, roman page numbers.
- Argument and statement pages: 40% to 69% word overlap. The gap is expected: the sample is a portion, its page breaks come from the template, and the filed brief runs to 30 pages.
- Table of authorities continuation (ours p. 5): 6.9%. The pairing is unreliable on table pages, which hold citations in a different order than the filed version.
- Filed p. 28 is paired twice (ours p. 17 and 18). That is a pairing artifact, not a layout fault.

Typeface: the filed brief is in Century Schoolbook; the template uses EB Garamond. FRAP 32(a)(5) allows any serif 14-point face, so this is an open choice, not a rule violation. The overlay shows the difference in every body line.

## Pages reviewed (Gate 2 for this render)

The render was 20 pages. Every page was rendered at 60 dpi and looked at.

| Physical page | Content | Finding |
|---|---|---|
| 1 | Cover | Fits one page. Counsel's "Counsel for Appellee..." line wraps. Acceptable. |
| 2 | Corporate disclosure statement (roman i) | Fine. |
| 3-4 | Table of contents (ii), table of authorities (iii-iv) | Authorities grouped by kind; passim not reached in this portion. |
| 5-16 | Body (arabic 1-11) | Headings numbered automatically; point headings in small capitals; no widow headings. |
| 17 | Certificate of bar membership (12) | Fine. |
| 18 | Electronic-filing certification (13) | Blank line for the virus-program version. Intentional. |
| 19 | Certificate of compliance (14) | Count is that of this sample (2,421 words), not the filed brief (4,185). The typeface line was fixed to read "14-point EB Garamond" (it had printed as code). Re-checked after the fix. |
| 20 | Certificate of service (15) | Fine. |

The sample is 2,421 words of the exemplar's 4,185; the body is 11 pages, within the 8-14 target.

## Known gaps

- **No statement of related cases.** L.A.R. 28.2 cross-refers to 28.1(a)(2), which would require it. The exemplar omits it. Not generated; to verify against the current LAR before adding.
- **Addendum** is supported by the template but not transcribed. The exemplar has none.
- **Sample is a portion**: the argument is abridged after Argument III; the statement of the case is condensed.
- **Authorities**: the table of authorities covers only the 15 authorities the sample cites (the exemplar's table lists about 23). The `passim` threshold is 7 pages.
- **Rule text**: the L.A.R. citations come from the 2011 edition. FRAP 26.1 and FRAP 25(d) were not fetched in this box.
- **Format**: the template reproduces the FRAP 32(g) certificate from memory of Form 6, not from the form. Check the wording.
- **Checks**: no `checks.yaml`, `check.sh` or `check-selftest.sh` for this doc type yet. The render, overlay and page review above are the only gates run.

## Build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq
cd /work/repo
sh tools/render.sh courts/third-circuit/court-of-appeals/answering-brief samples/INPUT-binder-answering-brief.md
sh tools/overlay.sh courts/third-circuit/court-of-appeals/answering-brief binder-answering-brief
```

`render.sh` uses only the vendored fonts (`--ignore-system-fonts`) and treats any typst warning as a failure.

## Engines

- **typst** (`typst/`): primary, unchanged.
- **latex** (`latex/template.tex`, `latex/ca3.lua`; built by `tools/render-latex.sh` with tectonic, two passes): 14 pt EB Garamond from the vendored `fonts/`, double spaced, 1 inch margins; roman pages for the corporate disclosure statement, contents and authorities, then arabic body pages; the Argument's point headings are centered with roman numerals; the addendum uses `Add-N` page numbers. Differs from typst: 21 pages against typst's 20; the certificate of compliance names LaTeX; the addendum has no table of its own (the sample has no addendum, so it is not exercised); the layout is checked by eye on a contact sheet, not by Gate 2. Tier 1 is not signed off for this engine.
- **docx** (`docx/reference.docx` from `docx/make-reference.sh`, `docx/ca3.lua`): writes `samples/OUTPUT-<id>.docx`. `docx.pdf` checks are **BLOCKED**: LibreOffice (`soffice`) is not installed and has no conda-forge package. Not provided (not checked, not claimed): table of contents and table of authorities page numbers; footer page numbers and the roman/arabic sections; the disclosure statement's paragraph layout; the addendum's own page numbering; body first-line indents; the Argument's centered point headings.
