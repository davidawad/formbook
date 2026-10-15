# U.S. Court of Appeals for Veterans Claims (cavc): opening brief

- Court: `cavc`, United States Court of Appeals for Veterans Claims (`courts/federal-circuit/court-of-veteran-appeals/`)
- Doc type: `opening-brief`, the appellant's principal brief (Vet. App. R. 28(a), 32). The Secretary's brief is `../answering-brief/`.
- Exemplar: `exemplars/FILED-EXAMPLE-chavez-19-7391-opening-brief.pdf` (*Chavez v. Wilkie*, Vet. App. No. 19-7391, filed 2020-06-22, private counsel). Provenance in `exemplars/SOURCE.md`. One exemplar only: see Known gaps.
- Status: template built, rendered, overlay generated, every page reviewed (Gate 2 below). Not reviewed by a human. `court.json` untouched; no status set.
- Every page is the court's own form; no case-specific text in the template.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default `samples/INPUT-chavez-opening-brief.md`) and calls `cavc-opening-brief`. |
| `typst/cavc-opening-brief.typ` | Template. Parameter block at the top: font and size, leading, margins, `page-limit = 30`, `required-sections` (Rule 28(a) order). |
| `samples/INPUT-chavez-opening-brief.md` | Markdown sample: frontmatter (caption, counsel, signature, service, authorities registry) and a transcribed portion of the brief. |
| `samples/OUTPUT-chavez-opening-brief.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-veteran-appeals/opening-brief samples/INPUT-chavez-opening-brief.md` (15 pages). |
| `samples/OVERLAY-chavez-opening-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-veteran-appeals/opening-brief chavez-opening-brief` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

Names: the brief asked for `samples/<id>.md`, `<id>.pdf`, `<id>-overlay.pdf`. The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (overlay.sh hardcodes these), so the tool names are used. The sample has no `INPUT-` prefix, so `<id>` is the file stem.

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
| R. 32(b) | Proportionally spaced typeface 13-point or larger; text double spaced; quotations of 50 words or more single spaced; footnotes single spaced and in the same typeface requirement | `type-size = 14pt` (EB Garamond, vendored); `body-leading` (double); block quotes single-spaced (all, a convention); footnotes 14 pt, single-spaced |
| R. 32(c) | Caption page, separate from the text; name of the court, case number, title of the case, brief heading; no cover required (Form 2) | `cover` (caption page, unnumbered): "Vet. App. No.", court, caption, proceeding, brief heading, counsel |
| R. 32(d) | Arabic page numbers for the pages subject to the page limit; lower-case roman for the TOC, TOA, certificate of service; centered at the bottom | caption unnumbered; TOC and TOA `i`, `ii`...; body `1`...; certificate of service `i` |
| R. 32(e) | Principal brief ≤ 30 pages, not counting the TOC, TOA, superseded-authorities appendix, and certificate of service | `page-limit = 30`; the build fails above it (counts from the body's first page to the signature) |
| R. 32(f) | Signature, printed name, address and telephone number of the representative | `signature-block` (signer, address lines, phone) and the counsel block on the caption page |
| R. 25(a) | Every document is submitted with proof of service | `certificate-of-service` (roman page). Wording drafted for this template (the rules prescribe no form); date and method come from the `service` block |
| R. 6(a)-(b) | Redaction of personal identifiers (SSN last four, DOB year, minor's initials) | not generated; the sample contains none. The filer redacts. |
| R. 31(a)(1) | Appellant's brief due 60 days after the R. 10(b) window or 30 days after the Rule 33 conference, whichever is later | not a layout rule; not generated |

Checked and not applicable: Rule 32 sets no word limit and no certificate of compliance, so none is generated. Rule 32(c) requires no cover color.

## Overlay

`samples/OVERLAY-chavez-opening-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap (Jaccard), not by index. Diagnostic only, not a score. Pairings from the last run (word overlap in parentheses):

- p.1 ↔ filed p.1 (74%): caption page lines up.
- p.2 ↔ p.2 (23%) and p.3 ↔ p.2 (42%): TOC and TOA are different layouts from the filed ones; expected.
- p.4-p.12 ↔ filed pp.4-12 (57-91%): body text lines up with the same passages.
- p.13-p.14 ↔ filed p.20 (40-42%): the signature page and the end of the conclusion (the filed brief's last page carries the signature).
- p.15 ↔ filed p.1 (17%): certificate of service; there is no matching filed page.

## Page review (Gate 2)

Every page of `OUTPUT-chavez-opening-brief.pdf` was rendered at 60 dpi and viewed (15 of 15). Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| i (pdf 1) | Caption page | OK. Vet. App. No., court, caption, proceeding, brief heading, counsel; fits one page; unnumbered. |
| ii (pdf 2) | TOC | OK. Entries, dot leaders, page column right-aligned. |
| ii-iv (pdf 3-5) | TOA: cases, statutes, regulations, rules, record cites | OK. Record cites are grouped as "Citations to the Record Before the Agency" in numerical order. Page numbers update with the layout (checked after the last change). |
| 1 (pdf 6) | Statement of the Issue; Statement of the Case begins | OK. Double spaced; heading centered. |
| 2 (pdf 7) | Statement of the Case, footnote 1 | OK. Footnote 14 pt single spaced. |
| 3 (pdf 8) | Statement of the Case, footnote 2 | OK. |
| 4 (pdf 9) | Statement of the Case end; Summary of the Argument; Standard of Review begins | OK. |
| 5 (pdf 10) | Standard of Review; Argument begins | OK. |
| 6 (pdf 11) | Argument | OK. |
| 7 (pdf 12) | Argument; Conclusion begins | OK. |
| 8 (pdf 13) | Five lines: end of the Conclusion's first paragraphs | OPEN (layout). The last paragraph and the signature are kept together (the ca9 rule, so a signature never stands alone); that block did not fit, so page 8 is short. Accepted for now: see Known gaps. |
| 9 (pdf 14) | Last paragraph of the Conclusion; signature block; date | OK. |
| i (pdf 15) | Certificate of service | OK. Roman numeral; wording drafted (see Governing rules). |

## Engines

| Engine | Folder | Output in `samples/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-chavez-opening-brief.pdf` | rendered; Gate 2 above |
| docx | `docx/` | `OUTPUT-chavez-opening-brief.docx` (pandoc, `docx/reference.docx`, `docx/cavc.lua`) | `.docx` written; `.docx.pdf` not produced (BLOCKED, below) |
| latex | `—` | none | not built |

Build: `sh docx/make-reference.sh` regenerates `docx/reference.docx` from pandoc's default reference; `sh tools/render.sh --engine docx courts/federal-circuit/court-of-veteran-appeals/opening-brief samples/INPUT-chavez-opening-brief.md` writes the `.docx`. No `checks.yaml` exists for this court yet. `tools/check.sh --engine docx` exits 2 here (no `court.json` in the doc-type folder, and no `yq` on this box), so no gate ran on either engine.

**docx matches the typst template:**

- Letter page, 1-inch margins; EB Garamond 14 pt (the font named in the styles, not embedded); body double-spaced (exact 31.45 pt) with a half-inch first-line indent; block quotations and footnotes single-spaced at 14 pt.
- Caption page with Form 2's contents (Vet. App. No., court, caption, proceeding, brief title, counsel, telephone), with no page number.
- Contents and authorities in lower roman from i; the body in arabic from 1; the certificate of service in lower roman from i (section breaks carry `w:pgNumType`).
- Rule 28 labels and indents: in the Argument, point headings (`I.`, `II.`) centered in small capitals and sub-headings `A.`, `1.`, `a.`; elsewhere `A.`, `1.`, `a.`, `(1)`. Levels 4 and below are bold italic, as in the typst template.
- Table of authorities groups in the typst order (cases, statutes, regulations, rules, other authorities, record citations).
- The signature block is kept with the last paragraph of the brief (`keepNext`).
- The level-1 sections required by Rule 28 are checked; the build fails when one is missing or out of order, as the typst template does.

**docx differs from the typst template:**

- The table of contents and the table of authorities have no page numbers. Typst measures them. The docx engine has no pagination pass, so both are static text (not Word fields) and show the entries without page numbers.
- The caption rules are paragraph borders, and the caption's spacing is set by hand; the typst template fits the caption to one page by measurement. Whether it fits one page has not been checked.
- Word and LibreOffice paginate differently from each other; no page-based property is asserted for docx.

**docx BLOCKED (delivered partial):**

- `docx.pdf` gates (Gates 0 to 3 and the page review) are BLOCKED. `soffice --headless --convert-to pdf` segfaults at startup on the box where this was built (exit 139), after LibreOffice 25.2.3 and its runtime packages were unpacked from Debian trixie without root; no debugger was available. No `.docx.pdf` was produced, so no page was rendered or reviewed (`pages_reviewed=0`).
- R. 28(a)(1)-(2), the table of contents and table of authorities with page references: not generated for docx.
- R. 32(e), the 30-page limit: not checked for docx (the typst template checks it).
- The `.docx` passed the render script's integrity check (a valid zip, every XML part well formed). It has not been opened in Word or LibreOffice, and no font check has been run on it.

## Known gaps

- **One exemplar per doc type.** Tier 2 asks for 2-3 filed exemplars from different filers. Only *Chavez* (opening) was found for this doc type. A second CAVC appellant's brief from another filer would be the next step (the efiling records at `efiling.uscourts.cavc.gov/cmecf/servlet/TransportRoom?servlet=ShowDoc%2F...` are the source; the Gray brief at hillandponton.com is 53 pages).
- **Exemplar age.** The exemplar is 2020. The governing rules are the 2026 text; the exemplar's own font and spacing are not the rule's floor.
- **Page 8 layout.** The short page 8 is the keep-with-signature rule applied to a 20-line block. Shortening the block or dropping the keep would remove it; neither was done.
- **Signature block.** One signer only. A brief with several counsel signing (the Secretary's briefs) is not generated; the answering-brief template has the same limit.
- **Superseded authorities appendix (R. 28(i), 32(d)).** Not generated. A brief that cites superseded statutes or regulations needs one.
- **Standard of Review heading.** Not required by the rule; the sample has one, as the filed brief does.
- **Passim.** The "passim" threshold (7 pages) is a convention from the ca9 template, not a CAVC rule.
- **Certificate of service wording.** Drafted; the rules prescribe no form.
- **Sample is an excerpt.** Omitted from the filed brief: the Argument after the competent-lay-evidence paragraph (about filed pp. 9-13), and the rest of the Conclusion. The sample is not the whole filing.
