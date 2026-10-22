# U.S. Court of Appeals for Veterans Claims (cavc): opening brief

- Court: `cavc`, United States Court of Appeals for Veterans Claims (`courts/federal-circuit/court-of-veteran-appeals/`)
- Doc type: `opening-brief`, the appellant's principal brief (Vet. App. R. 28(a), 32). The Secretary's brief is `../answering-brief/`.
- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf` (*Chavez v. Wilkie*, Vet. App. No. 19-7391, filed 2020-06-22, private counsel). Provenance in `usage/SOURCE.md`. One exemplar only: see Known gaps.
- Status: typst and docx on the shared cross-engine layout model; docx cross-engine gated (XENG-001..003 PASS on both INPUTs, fb-595.54.6); every page reviewed (Gate 2 below). Not reviewed by a human. `court.json` untouched; no status set.
- Every page is the court's own form; no case-specific text in the template.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default `usage/INPUT-opening-brief.md`) and calls `cavc-opening-brief`. |
| `typst/cavc-opening-brief.typ` | Template. Parameter block at the top: font and size, leading, margins, `page-limit = 30`, `required-sections` (Rule 28(a) order). |
| `usage/INPUT-opening-brief.md` | Markdown sample: frontmatter (caption, counsel, signature, service, authorities registry) and a transcribed portion of the brief. |
| `usage/OUTPUT-opening-brief.typst.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-veteran-appeals/opening-brief usage/INPUT-opening-brief.md` (14 pages). |
| `usage/OVERLAY-chavez-opening-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-veteran-appeals/opening-brief chavez-opening-brief` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

Names: the brief asked for `usage/<id>.md`, `<id>.pdf`, `<id>-overlay.pdf`. The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (overlay.sh hardcodes these), so the tool names are used. The sample has no `INPUT-` prefix, so `<id>` is the file stem.

## Governing rules

Primary source: Court of Appeals for Veterans Claims, *Rules of Practice and Procedure* (posted 10/01/2026), <https://www.uscourts.cavc.gov/documents/RulesofPracticeandProcedure20261001.pdf>. Downloaded and text-extracted (`pdftotext`) on 2026-10-14. The caption form is Form 2 and the table-of-authorities form is Form 18, from the Appendix of Forms, <https://www.uscourts.cavc.gov/documents/appendix.pdf> (Form 2 rev. 5/99; Form 18 rev. 08/11), read the same day.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Vet. App. R. 28(a)(1)-(2) | Contents, in order: table of contents with page references; table of authorities (cases alphabetically, statutes, other authorities, and record cites in numerical order), with the page of the brief where each is cited (Form 18) | generated TOC and TOA (`toa:` links); `rba` group for record cites |
| R. 28(a)(3) | Statement of the issues | `required-sections`: "statement of the issue" |
| R. 28(a)(4)(i)-(ii) | Statement of the case, with record pages; a record cite gives the pages cited followed by all pages of the document cited | body text (the template does not check record-cite form) |
| R. 28(a)(5) | Argument, beginning with a summary | `required-sections`: "summary of the argument" then "argument" |
| R. 28(a)(6) | Short conclusion stating the precise relief | `required-sections`: "conclusion" |
| R. 28(i) | Superseded or unpublished authorities reproduced in the brief or an appendix (not in the sample; the template generates no appendix) | not generated (known gap) |
| R. 32(a) | Letter size; margins at least one inch from all edges; one side only | `page`, `page-margin = 1in` |
| R. 32(b) | Proportionally spaced typeface 13-point or larger; text double spaced; quotations of 50 words or more single spaced; footnotes single spaced and in the same typeface requirement | `type-size = 14pt` (Times New Roman); `pitch-double` 29.4 pt (double); block quotes single-spaced (all, a convention); footnotes 14 pt, single-spaced |
| R. 32(c) | Caption page, separate from the text; name of the court, case number, title of the case, brief heading; no cover required (Form 2) | `cover` (caption page, unnumbered): "Vet. App. No.", court, caption, proceeding, brief heading, counsel |
| R. 32(d) | Arabic page numbers for the pages subject to the page limit; lower-case roman for the TOC, TOA, certificate of service; centered at the bottom | caption unnumbered; TOC and TOA `i`, `ii`...; body `1`...; certificate of service `i` |
| R. 32(e) | Principal brief ≤ 30 pages, not counting the TOC, TOA, superseded-authorities appendix, and certificate of service | `page-limit = 30`; the build fails above it (counts from the body's first page to the signature) |
| R. 32(f) | Signature, printed name, address and telephone number of the representative | `signature-block` (signer, address lines, phone) and the counsel block on the caption page |
| R. 25(a) | Every document is submitted with proof of service | `certificate-of-service` (roman page). Wording drafted for this template (the rules prescribe no form); date and method come from the `service` block |
| R. 6(a)-(b) | Redaction of personal identifiers (SSN last four, DOB year, minor's initials) | not generated; the sample contains none. The filer redacts. |
| R. 31(a)(1) | Appellant's brief due 60 days after the R. 10(b) window or 30 days after the Rule 33 conference, whichever is later | not a layout rule; not generated |

Checked and not applicable: Rule 32 sets no word limit and no certificate of compliance, so none is generated. Rule 32(c) requires no cover color.

## Overlay

`usage/OVERLAY-chavez-opening-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap (Jaccard), not by index. Diagnostic only, not a score. Pairings from the last run (word overlap in parentheses):

- p.1 ↔ filed p.1 (74%): caption page lines up.
- p.2 ↔ p.2 (23%) and p.3 ↔ p.2 (42%): TOC and TOA are different layouts from the filed ones; expected.
- p.4-p.12 ↔ filed pp.4-12 (57-91%): body text lines up with the same passages.
- p.13-p.14 ↔ filed p.20 (40-42%): the signature page and the end of the conclusion (the filed brief's last page carries the signature).
- p.15 ↔ filed p.1 (17%): certificate of service; there is no matching filed page.

## Page review (Gate 2)

Every page of the four renders was rendered at 60 dpi and viewed (fb-595.54.6, after the move to the shared cross-engine layout model): `OUTPUT-opening-brief.typst.pdf` and `.docx.pdf` (14 of 14 each), `OUTPUT-opening-brief-2.typst.pdf` and `.docx.pdf` (12 of 12 each). Typst printed no warnings. Fonts embedded: Times New Roman (regular, bold, italic) in all four.

`OUTPUT-opening-brief` (the docx pages are the same, line for line):

| Page | Content | Result |
|---|---|---|
| pdf 1 | Caption page | OK. Vet. App. No., court, caption, proceeding, brief heading, counsel; fits one page; unnumbered. |
| i (pdf 2) | TOC | OK. Leaders to a 36 pt page column. |
| ii-iv (pdf 3-5) | TOA: cases, statutes, regulations, rules, record cites | OK. Record cites grouped last ("Citations to the Record Before the Agency"), in their `sort` order. |
| 1 (pdf 6) | Statement of the Issue; Statement of the Case begins | OK. |
| 2-3 (pdf 7-8) | Statement of the Case; footnotes 1 and 2 | OK. Footnotes 14 pt, single spaced; footnote 2 runs over to page 3 (both engines). |
| 4 (pdf 9) | Summary of the Argument; Standard of Review | OK. |
| 5-7 (pdf 10-12) | Standard of Review end; Argument; Conclusion begins | OK. |
| 8 (pdf 13) | Conclusion end; signature block; date | OK. The last paragraph is kept with the signature block. |
| i (pdf 14) | Certificate of service | OK. Roman numeral; signature in the right half. |

`OUTPUT-opening-brief-2` (Butler; the docx pages are the same, line for line): caption page (no proceeding line: the INPUT gives none), TOC i, TOA ii-iii, body 1-7 (Brief of the Appellant, Statement of the Issue, Statement of the Case A-C with footnote 1, the block quotation on 3-4, Argument opening with its bold "Summary" paragraph, point I., Conclusion with the signature block on 7), certificate of service i. OK.

Visible changes from the renders before fb-595.54.6: body pitch 29.4 pt (was about 30 pt with taller ascender boxes; 14 pages, was 13; -2 still 12); section headings 16 pt; point headings bold without small capitals; TOC/TOA rows on the shared listing-row (page column, leader from three spaces after the text); `INPUT-opening-brief-2.md`'s `word: {justify: true, shrink: 0.76}` is no longer applied (the layout model sets ragged right, first fit, in every engine), so that brief is now ragged right.

## Engines

| Engine | Folder | Output in `usage/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-opening-brief.typst.pdf`, `OUTPUT-opening-brief-2.typst.pdf` | `check.sh`: 0 failed; Gate 2 above |
| docx | `docx/` | `OUTPUT-opening-brief[-2].docx`, `.docx.pdf` (pandoc, `docx/reference.docx`, `docx/cavc.lua`) | `check.sh --engine docx`: 0 failed, XENG-001..003 PASS on both INPUTs (cross-engine gated) |
| latex | none | none | not built |

Both engines run on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`, `lib/docx/xengine-reference.sh`; docs/EVAL-LOOP.md, "Cross-engine gate"): first-fit breaking, no kerning, ligatures or hyphenation, exact line boxes (body 29.4 pt, single 17 pt, section headings 16 pt in 20 pt), explicit block spacings. `eval.yaml` sets `params.cross_engine: gate`: the docx must break every line and page where typst does. Build: `sh docx/make-reference.sh` rebuilds `docx/reference.docx`; `sh tools/render.sh --engine docx <this folder> usage/INPUT-<id>.md` renders (fb render runs the page pass: the filter writes needles, the TOC and TOA page numbers come from the LibreOffice PDF of the previous pass). `docx/cavc.lua` is the same file as `../answering-brief/docx/cavc.lua` except its `CFG` block.

Where LibreOffice would break otherwise, the docx filter follows typst (Unicode line breaking): no break at a space before closing punctuation (". . ."), none inside a token of adjacent parentheses ("7261(a)(3)", a word joiner), a measure one twip narrower (LibreOffice keeps a word that overruns by less than a twip), and footnotes that may run over to the next page (the shared reference recipe keeps them whole; typst splits them).

docx limits: the 30-page limit (R. 32(e)) is checked by the typst template only (the docx breaks its pages alike); the caption page's spacing is estimated from the text length, not measured (its lines break alike, its gaps differ by a few points); Word may paginate slightly differently from LibreOffice (docs/DOCX.md).

## Known gaps

- **One exemplar per doc type.** Tier 2 asks for 2-3 filed exemplars from different filers. Only *Chavez* (opening) was found for this doc type. A second CAVC appellant's brief from another filer would be the next step (the efiling records at `efiling.uscourts.cavc.gov/cmecf/servlet/TransportRoom?servlet=ShowDoc%2F...` are the source; the Gray brief at hillandponton.com is 53 pages).
- **Exemplar age.** The exemplar is 2020. The governing rules are the 2026 text; the exemplar's own font and spacing are not the rule's floor.
- **Signature block.** One signer only. A brief with several counsel signing (the Secretary's briefs) is not generated; the answering-brief template has the same limit.
- **Superseded authorities appendix (R. 28(i), 32(d)).** Not generated. A brief that cites superseded statutes or regulations needs one.
- **Standard of Review heading.** Not required by the rule; the sample has one, as the filed brief does.
- **Passim.** The "passim" threshold (7 pages) is a convention from the ca9 template, not a CAVC rule.
- **Certificate of service wording.** Drafted; the rules prescribe no form.
- **Sample is an excerpt.** Omitted from the filed brief: the Argument after the competent-lay-evidence paragraph (about filed pp. 9-13), and the rest of the Conclusion. The sample is not the whole filing.
