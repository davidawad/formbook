# Eighth Circuit (ca8): opening brief (appellant's principal brief)

- Court: `ca8`, United States Court of Appeals for the Eighth Circuit (`courts/eighth-circuit/court-of-appeals/`)
- Doc type: `opening-brief`. Brief of Appellant (FRAP 28(a)); one self-contained folder. The court-root `typst/` and `usage/` (the ca8 court's own stubs) are untouched.
- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf` (*Wolters v. Sweepsteaks Limited d/b/a Stake.us*, No. 26-2459, filed 2026-09-11; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-opening-brief.md`: a transcription of the filed brief's cover, summary, disclosure, jurisdiction, issues, part of the statement of the case, part of the argument, conclusion, signature and certificates. It is an excerpt, not the whole brief (see Known gaps).
- Render: `usage/OUTPUT-opening-brief.typst.pdf`, 15 pages.
- Status: template built; render, overlay and page review done (below). Not reviewed by a human. `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `ca8-brief`. |
| `typst/ca8-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections`, `needs-standard-of-review`, `addendum = "separate"`. |
| `usage/INPUT-opening-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-opening-brief.typst.pdf` | `sh tools/render.sh courts/eighth-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md` (15 pages, Times New Roman only). |
| `usage/OVERLAY-wolters-opening-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/eighth-circuit/court-of-appeals/opening-brief wolters-opening-brief` (red = ours, blue = filed, black = both agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Verified against primary text on 2026-10-14:

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRAP 32(a)(4) | Double-spaced; block quotations over two lines may be single-spaced; margins at least one inch on all four sides. Cornell LII text, <https://www.law.cornell.edu/rules/frap/rule_32> (amendments through Dec. 1, 2019; 2024 note). | `page-margin = 1in`, `pitch-double = 28pt` (2 x the 14 pt type), quotation style |
| FRAP 32(a)(5)(A) | Proportionally spaced typeface must have serifs (sans-serif allowed only in headings and captions); 14-point or larger. Cornell LII text as above; the 14-point figure is also in the Clerk's pointers (below). | `type-size = 14pt`, Times New Roman (serif) everywhere, footnotes included. Typeface: the rule names no face, so Times metrics (`docs/FONTS.md`, "No face named"); EB Garamond is for rules that name Garamond (fb-595.54.4: LibreOffice also set the vendored EB Garamond up to 2 pt a line narrower than typst, so the docx could not break its lines alike). |
| FRAP 32(a)(6) | Plain roman; italics or boldface for emphasis. Cornell LII text as above. | Markdown emphasis; the template does not guess case names |
| FRAP 32(a)(7)(B)(i) | Principal brief: 13,000 words. Cornell LII text as above. | `word-limit = 13000` (the count excludes FRAP 32(f) items) |
| FRAP 32(f) | Excluded from the count: cover, disclosure statement, TOC, table of citations, statement regarding oral argument, addendum with statutes and rules, certificate of counsel, signature block, proof of service. Cornell LII text as above. | `strip-oral-argument`; the rest is outside the body |
| FRAP 32(g)(1) | Certificate of compliance stating the word count. Cornell LII text as above. | `certificate-of-compliance` (Form 6 wording, drawn checkboxes) |
| 8th Cir. R. 28A(g)(1)-(5) | Appellant's addendum is filed with the brief; the electronic addendum is a separate document, not attached to the brief. Local Rules PDF (rules revised June 17, 2024), <https://www.ca8.uscourts.gov/sites/ca8/files/Eighth%20Circuit%20Local%20Rules%206.17.24.pdf>, fetched 2026-10-14. | `addendum = "separate"`: the template does not produce the addendum (see Known gaps) |
| 8th Cir. R. 28A(h)(2)-(3) | Counsel states that the brief (and addendum) was scanned for viruses and is virus-free; the brief is one PDF printed from the word-processing file. Same PDF as above. | Certificate of compliance, item 3 |
| 8th Cir. R. 28A(i)(1) | Summary of the case, one page at most, the first item in the brief; states whether oral argument is requested and the time needed. Same PDF. | `Summary of the Case`, rendered on the first roman page before the disclosure page |
| 8th Cir. R. 28A(i)(2) | Statement of issues lists, for each issue, the most apposite cases (no more than four) and the apposite constitutional and statutory provisions. Same PDF. | Sample issues list the apposite cases under each issue (the template does not check the count) |
| 8th Cir. R. 28A(j) | Record cites in the form "R. Doc. 12, at 3" and "App. 25". Same PDF. | Used in the sample text as filed |
| 8th Cir. R. 26.1A | Corporate disclosure statement must be filed within 7 days after the appeal is docketed. Same PDF. | The disclosure page is optional (`disclosure:` field) and follows the exemplar's convention; the rule itself is a separate filing |
| FRAP 26.1 | Corporate disclosure statement. Referenced in the exemplar's disclosure text. | Disclosure page text |
| FRAP 28(a)(4)-(9) | Jurisdictional statement, issues, case, summary of argument, argument (with standard of review), conclusion, in that order. Not re-fetched; the order is that of the Clerk's pointers (below) and the ca1 template this file was adapted from. | `required-sections` |
| Clerk's "Pointers on Preparing Briefs" (updated April 7, 2025), <https://www.ca8.uscourts.gov/sites/ca8/files/Pointers%20on%20Preparing%20Briefs.pdf>, fetched 2026-10-14 | Items 1 (type size), 2 (summary of the case), 3 (standard of review), 4 (apposite cases), 5 (jurisdictional statement), 6 (addendum: separate paper and electronic copy), 7 (certifications). | Summarized above; read for the 14-point and serif requirement and the addendum's separate filing |

Not verified and not produced: the cover colour (FRAP 32(a)(2) and any circuit rule; the local rules PDF above states none), paper-copy count (8th Cir. R. 28A(d): ten paper copies; not part of the PDF), the Clerk's "13,000 words or 1,300 lines" figure (from a secondary search summary of the Civil checklist, not read in the primary text).

## Overlay

`usage/OVERLAY-wolters-opening-brief.pdf` puts our render (red) over the best-matching filed page (blue). Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run (word overlap in parentheses):

- Sample p.1 ↔ filed p.1 (88%), p.2 ↔ p.2 (93%): cover and summary.
- p.3 ↔ p.3 (64%), p.4 ↔ p.4 (45%), p.5 ↔ p.5 (34%): disclosure page, table of contents, first table-of-authorities page. Our TOC and TOA are generated, so the word sets differ from the filed pages; expected.
- p.6 ↔ p.8 (13%): the second table-of-authorities page. The filed TOA continues on filed p.6, which is the match a human would expect; the algorithm chose p.8 with low overlap. Known weak pairing.
- p.7 ↔ p.9 (89%): jurisdictional statement and statement of the issues.
- p.8 ↔ p.10 (64%): issues and start of the statement of the case.
- p.9 ↔ p.16 (40%), p.10 ↔ p.18 (44%): statement of the case, summary of the argument, start of the argument. Our text is an excerpt, so later filed pages pair with it.
- p.11 ↔ p.19 (92%): Part I.A heading and argument text.
- p.12 ↔ p.20 (38%): Part I.A continued; the sample omits the filed text after it.
- p.13 ↔ p.33 (38%): conclusion and signature block. Filed p.33 is the filed brief's conclusion page.
- p.14 ↔ p.34 (55%), p.15 ↔ p.35 (51%): certificate of compliance and certificate of service.

## Page review (Gate 2)

Every page of `OUTPUT-opening-brief.typst.pdf` was rendered at 60 dpi and viewed (15 of 15) on the last render. Typst printed no warnings. Fonts embedded: EB Garamond (Regular, Bold, Italic) only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover | OK. Case number, court, caption, proceeding, brief title, two counsel groups side by side, fits one page. |
| 2 | Summary of the case (roman i) | OK. One page, first item of the brief; oral argument request present. |
| 3 | Corporate disclosure statement (ii) | OK. |
| 4 | Table of contents (iii) | OK. Page column aligned; section and subsection levels indented; page numbers match the body. |
| 5 | Table of authorities (iv) | OK. Cases alphabetized with page numbers. Continues on the next page. |
| 6 | Table of authorities, continued (v) | OK. Statutes and rules groups. |
| 7 | Jurisdictional statement (1); start of statement of the issues | OK. Numbered issues with hanging indent. |
| 8 | Issues 1-2 with apposite cases (2); statement of the case begins at the foot of the page | OK. |
| 9 | Statement of the case (end); summary of the argument (3); start of argument (3) | OK. |
| 10 | Argument intro; standard-of-review run-in; Part I heading (4) | OK. |
| 11 | Part I text (4-5); Part I.A heading (5) | OK. |
| 12 | Part I.A continued (6) | OK. |
| 13 | Conclusion; signature block (7) | OK after the fix: the counsel address is now two lines, not one wrapping line. |
| 14 | Certificate of compliance (8) | OK (checkbox wrap fixed 2026-10-16, see below). Word count shows 1,627 words: the count of the sample, not of the filed brief (6,272). Item 3 is the virus statement. |
| 15 | Certificate of service (9) | OK. |

Pages 1-12 and 14-15 were viewed on the render before the last edit. The last edit (splitting the signature address into two lines) changes only page 13, which was viewed again after it.

## Verification pass 2026-10-16 (fb-595.26.8)

- Rendered: `sh tools/render.sh courts/eighth-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md` exit 0, no typst warnings, 15 pages (same as the committed PDF), fonts EB Garamond Regular/Bold/Italic only. Overlay re-run (`tools/overlay.sh`, exit 0); the page pairings and overlaps are the same as listed under "Overlay" above.
- Viewed: all 15 pages at 60 dpi, the exemplar's page 1 against our cover, and all 15 overlay pages at 40 dpi. Page 14 viewed again (60 dpi and 150 dpi) after the fix; the text of every other page is unchanged by it.
- Fixed (tier 2): in the certificate of compliance, the second checkbox item wrapped its second line under the box instead of under the text. Each checkbox item is now a paragraph with a hanging indent the width of the box and its gap.
- Checked, no defect: cover on one page; summary of the case one page, first item (8th Cir. R. 28A(i)(1)); TOC and TOA page numbers match the body; no heading stranded at a page foot; page numbering roman i-v then arabic 1-9. The pilcrow in record cites ("3 ¶ 11") is EB Garamond's own glyph.
- Remaining: the gaps below are unchanged. Latex re-rendered (15 pages, builds); not reviewed page by page in this pass. Docx not rebuilt (no `soffice`).

## Known gaps

- **Length.** The sample renders to 15 pages; the target was 8-14. One more page would come out only by removing argument the sample keeps (the conclusion and its signature block are kept together and do not fit on the page before). The table of authorities takes two pages because the sample cites 20-odd authorities.
- **Excerpt.** The sample is not the whole brief. Omitted from the filed text: Statement of the Issues 3 (whole); Statement of the Case paragraphs on account setup and the checkbox, on the arbitration agreement (with its block quotation), on the updated terms, on the opposition, on the oral argument, the second ground of decision and the unconscionability footnote; the Summary of the Argument's second, third and fourth paragraphs; in the Argument, the Section 2 paragraph, the second half of I.A (the gateway and plain-text analysis, the AAA-rules paragraph, the unconscionability paragraph), and the whole of I.B, I.C and I.D. The Conclusion and signature are as filed. The Statement of the Case and the Argument paragraphs that remain are verbatim.
- **Additions to the filed text.** (1) The bold run-in label "Standard of review." is added before the sentence "The Court reviews a determination concerning the arbitrability of a dispute de novo." so that the FRAP 28(a)(8)(B) statement is explicit for the template's check; the filed brief has no such label. (2) The summary heading is "Summary of the Case" (the filed heading is "Summary of the Case and Request for Oral Argument"). The "and Request for Oral Argument" text is kept in the body as filed.
- **Addendum.** Not produced. The local rules require it as a separate electronic document (8th Cir. R. 28A(g)(5)); the template sets `addendum = "separate"`.
- **Corporate disclosure.** The disclosure page follows the exemplar. The local rule (8th Cir. R. 26.1A) requires the disclosure as a separate filing within 7 days of docketing.
- **Cover.** The filed cover sets the court name and the counsel in two columns; the template reproduces that layout. No cover colour (see Governing rules).
- **Table of authorities.** Built from the sample's `toa:` links only; citations not linked in the sample do not appear in it.
- **Certificate of compliance word count.** It is computed from the sample markdown by the template (1,627 words here) and is not the filed brief's count (6,272 words).
- **Not reviewed by a human.** The exemplar choice and the transcription were checked against the filed PDF's text layer, not against the image of every page.

## Engines

All three engines are on the shared cross-engine layout model (`lib/*/xengine*`; docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.54.4): first-fit line breaking, no kerning, ligatures or hyphenation, exact line boxes (28 pt body, 17 pt single-spaced lines, section headings 16 pt in 20 pt boxes), the typst template's spaces in pt. The latex and docx renders break every line and page where the typst render does (`fb check --engine latex|docx`: XENG-001..003 PASS, 269 of 269 lines, 15 pages), and `eval.yaml` sets `params.cross_engine: gate`. All three certify the same word count (1,627). The summary of the case stays on one page (8th Cir. R. 28A(i)(1)) in every engine; at the earlier 2.2 x pitch in Times it ran onto a second page, so the body pitch is 28 pt, double the type size, as in the answering brief.

- **typst** (primary, `typst/`): the reference. For the cross-engine model: Times New Roman instead of EB Garamond (above); point headings bold, not small capitals; section headings 16 pt (was 1.15 em, 16.1 pt: Word has whole half points only); the Form 6 check boxes a ruled box around a literal X; "1\.", "2\.", "3\." in the certificate are text, not a typst list; a URL breaks only after `?`, `=`, `&`, a hyphen or a slash.
- **latex** (`latex/template.tex`, `latex/ca8.lua`): stock pdflatex (`fb render`; the .tex compiles alone on stock TeX Live), newtx Times; every block built as typst builds it, sizes and spaces in bp, TOA pages from the aux file (passim from 7 pages). An addendum in the same file is not rendered (8th Cir. R. 28A(g): it is filed as its own PDF; typst `addendum = "separate"`): the filter fails loudly.
- **docx** (`docx/render.sh`, `docx/ca8.lua`, `docx/build-reference.sh`, `docx/reference.docx`, `docx/pagemap.awk`, `docx/footer.xml`): pandoc on the reference built by `lib/docx/xengine-reference.sh` plus the "CA ..." styles; render.sh writes the sections and footers and fills the TOC and TOA page numbers from a first LibreOffice pass (pagemap.awk). Counsel columns are a borderless table; the check boxes bordered runs. An addendum fails loudly, as in latex; so does a `toa:` citation inside the summary of the case (its roman page is not in the page map; the sample has none).
