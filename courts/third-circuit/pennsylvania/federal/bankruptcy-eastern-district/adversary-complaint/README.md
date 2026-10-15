# paeb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Eastern District of Pennsylvania (`paeb`).
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-tig-reaper-26-00204-adversary-complaint.pdf` (Kang Haggerty LLC, filed 2026-09-21) and `exemplars/FILED-EXAMPLE-krueger-26-00127-adversary-complaint.pdf` (Salzmann Hughes PC, filed 2026-03-24). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-krueger-complaint.md` (the full filing text, ¶¶ 1 to 88, relief, signature, certificate of service); `samples/INPUT-tig-reaper-complaint.md` (an excerpt: caption, ¶¶ 1 to 23, Counts I to V, prayer, signature; see Known gaps) |
| render | ok: `samples/OUTPUT-krueger-complaint.pdf` (12 pages), `samples/OUTPUT-tig-reaper-complaint.pdf` (9 pages); typst 0.15.0, vendored EB Garamond only, `--ignore-system-fonts`, no warnings |
| overlay | ok: `samples/OVERLAY-krueger-complaint.pdf` and `.txt` (against the Krueger exemplar); `samples/OVERLAY-tig-reaper-complaint.pdf` and `.txt` (against the TIG exemplar) |
| pages reviewed | 12 of 12 (Krueger) and 9 of 9 (TIG). Every page was rasterized at 60 dpi and viewed after the last template change. |

Build (from the repo root, PATH per the box setup):

```sh
D=courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-krueger-complaint.md
sh tools/overlay.sh $D krueger-complaint $D/exemplars/FILED-EXAMPLE-krueger-26-00127-adversary-complaint.pdf
```

File names follow the tools, which read and write `INPUT-`, `OUTPUT-` and `OVERLAY-` names by default (`tools/render.sh` writes `samples/OUTPUT-<id>.pdf`, `tools/overlay.sh` reads it and writes `samples/OVERLAY-<id>.pdf` and `.txt`). The brief's `<id>.md` / `<id>-overlay.pdf` names were not used so that the tools work unchanged.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **latex**: not built for this doc type yet (`latex/` is empty).
- **docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/paeb.lua`): pandoc on a reference.docx built from pandoc's default (EB Garamond 12 pt, exact 24 pt line pitch, no space between paragraphs, 0.5 in first-line indent, 1 in margins on letter paper, centered PAGE footer). Build: `sh docx/build-reference.sh docx/reference.docx`, then from the court folder `pandoc --from markdown+smart --to docx --reference-doc=<D>/docx/reference.docx --lua-filter=<D>/docx/paeb.lua <D>/samples/INPUT-<id>.md -o <D>/samples/OUTPUT-<id>.docx`.
  - Matches the typst template: the two-line bold court title; the caption as a borderless three-column table (party names, colons, `Chapter` / `Case No.` / `Adv. Proc. No.`) with the 1.2 in designation indent; numbered allegations with unnumbered WHEREFORE clauses; lettered or roman lists from the sample's `list_numbering`; bold capitals centered level-1 headings and bold level-2 and level-3 headings kept with the text after them; the signature block (Dated at left; firm, `By: /s/` and the lines at right) with the last paragraph kept on its page; the optional certificate of service kept on one page.
  - Differs from typst (pandoc and Word limits, not chosen): the caption and signature are Word tables, so their borders and cell padding are Word's; the heading spacing is 6 pt before and after the heading line (typst's measured offset is about 6.5 pt); the list text starts at 1.1 in (typst places it by the marker width plus 0.4 in); footnotes are at body size because the typst template sets no footnote size (no sample has a footnote); line breaks and page breaks follow Word's layout, so the page count of the typst render (12, 9 and 8 pages for the three samples) is not reproduced.
  - Checks: the docx passes the zip and XML checks only (every zip entry reads, every XML part is well formed). No `checks.yaml` exists for this court, so there is no list of gate check IDs to read. BLOCKED: every gate check on `samples/OUTPUT-<id>.docx.pdf` (the Gate 0 to 3 checks, none readable here): LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.

## Governing rules

Each rule was fetched on 2026-10-14 from the URL shown. Current text of the FRBP and FRCP rules took effect 2024-12-01 (FRBP) or as stated.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; a pleading's caption must substantially conform to the appropriate version of Form 416. | https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption-rows()`, `caption()` |
| Fed. R. Bankr. P. 9004(a) | A document must be clearly legible. | https://www.law.cornell.edu/rules/frbp/rule_9004 | 12 pt type, black text, no decoration |
| Fed. R. Bankr. P. 9004(b) | Caption: (1) the court's name; (2) the case's title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the document's character. | same | `court-title()`; `caption-rows()` (`Chapter`, `Case No.`, `Adv. Proc. No.`); `title` |
| Fed. R. Civ. P. 10(a) (applied by 7010) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | https://www.law.cornell.edu/rules/frcp/rule_10 | as 9004(b) |
| Fed. R. Civ. P. 10(b) (applied by 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | same | `body-pieces()` numbers every paragraph in order; headings and lists are not numbered |
| Fed. R. Bankr. P. 7008(a) | "In an adversary proceeding before a bankruptcy court, a complaint … must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | https://www.law.cornell.edu/rules/frbp/rule_7008 | not rendered by the template: it is author content in the body (see Known gaps, 3) |
| L.B.R. 9004-1(b) (PAEB Local Rules, Dec. 1, 2025) | A paper document shall measure 8½ × 11 inches and be stapled or fastened at the top. | https://www.paeb.uscourts.gov/sites/paeb/files/PAEB%20Local%20Rules%20-2025-12-01%20Final.pdf | `page(paper: "us-letter")` |
| L.B.R. 7003-1 (same PDF) | A paper complaint is filed with the Adversary Proceeding Cover Sheet provided by the Clerk. | same | not generated (see Known gaps, 4) |

No E.D. Pa. rule on the typeface, type size, margins, line spacing or page limit was found: I searched the text of the local-rules PDF (93 pages) for font, point, margin, spacing and page limit, and read FRBP 9004 (current text), which has only legibility and caption subdivisions. The typeface, size, margins and spacing are therefore conventions, judged against the two filed exemplars, not mandated form.

## Layout (conventions, judged against the exemplars)

- Letter paper, 1 inch margins, page number centered at the foot.
- Court name in bold capitals, two lines, centered (the exemplars use the same two-line court title).
- Caption: a three-column table. Party column, a column of colons, and a case column with `Chapter`, `Case No.` and `Adv. Proc. No.`. Long party names are written as one row per line in the sample, so the colons line up.
- Title in bold, centered. The lead-in (unnumbered) follows.
- Double spacing (24 pt baseline pitch at 12 pt, measured from the PDF text positions). Paragraphs are separated by one blank double-spaced line. Headings: level 1 bold capitals, centered; levels 2 and 3 bold, left. Headings and WHEREFORE lead-ins stay with the text that follows them.
- Lists are lettered `(a)`, or roman `(i)` when the sample sets `list_numbering`.
- Signature block: "Dated" at left and "Respectfully submitted," with the firm, `By: /s/` and the lines given at right. The last body piece stays on the page with the signature block, so a signature never stands alone.
- Optional certificate of service (`certificate:` in the frontmatter), on the page after the signature.

## What the overlay shows

`OVERLAY-<id>.pdf` puts our render in red and the filed exemplar in blue, page against page. The `.txt` map pairs each of our pages with the exemplar page that shares the most words. Both samples are excerpts or transcriptions, so word overlap is not a score (see the page map in each `.txt`). The overlay is a diagnostic only; the review below is the Gate 2 equivalent.

## Gate 2 review (final renders, every page viewed)

Krueger, 12 pages (`samples/OUTPUT-krueger-complaint.pdf`):

- p. 1: court title, caption (colons aligned), title, lead-in, Parties, Jurisdiction headings. Pass.
- p. 2 to p. 6: numbered ¶¶ 7 to 58, procedural background and factual allegations. Pass.
- p. 7 to p. 10: Count I (¶¶ 59 to 74, p. 7 to p. 8), collateral estoppel (¶¶ 75 to 83, p. 8 to p. 10), the state-court request (¶¶ 84 to 88, p. 10). Pass. Page 10 ends after ¶ 88; the WHEREFORE and the relief heading move to p. 11 with the relief list.
- p. 11: WHEREFORE, Relief Requested, items (i) to (v), signature block. Pass.
- p. 12: Certificate of service with the four CM/ECF service blocks, date and signature. Pass.

TIG Reaper, 9 pages (`samples/OUTPUT-tig-reaper-complaint.pdf`):

- p. 1: court title, caption (the plaintiffs' name is split into rows and the colons align), title, lead-in, Preliminary Statement ¶¶ 1 to 4. Pass.
- p. 2 to p. 3: ¶¶ 5 to 19 (parties, jurisdiction and venue, factual background with lettered items (a) and (b)). Pass.
- p. 4: ¶¶ 20 to 29, Count I begins. Pass.
- p. 5: ¶¶ 30 to 39, Count I's WHEREFORE, Count II begins. Pass.
- p. 6: ¶¶ 40 to 48, Count II's WHEREFORE, Count III begins. Pass.
- p. 7: ¶¶ 49 to 56, Count III's WHEREFORE, Count IV. Pass.
- p. 8: Count V (¶¶ 57 to 60) and its WHEREFORE. Pass. The prayer and signature move to p. 9 as one block, so the prayer heading does not end p. 8; p. 8 has white space at the foot by design.
- p. 9: WHEREFORE, Prayer for Relief items (a) to (e), signature block. Pass.

## Known gaps and open choices

1. **Typeface (fonts pass, 2026-10-15).** Face required by the rules: none. Verified against the PAEB Local Rules PDF (2025-12-01): L.B.R. 9004-1(b) sets paper size and fastening only, and FRBP 9004 names no face. Substitute: none, so EB Garamond stays (a court that names no face keeps it). The filed exemplars use Times New Roman (checked with `pdffonts`); that is an exemplar convention, not a rule, and is not chased. Metric-compatible / visual-only: not applicable. Size is 12 pt; EB Garamond has a smaller x-height than Times at 12 pt, so the text looks smaller on the page.
2. **Form 416.** Rule 7010 requires the caption to substantially conform to Official Form 416. The uscourts.gov page I tried for the caption form returned 404, so the form's own layout was not checked. The caption follows the two filed exemplars, which share the same layout.
3. **FRBP 7008(a) consent statement.** Verified text: a complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court. The template does not generate or check this sentence; it is author content. The TIG exemplar has it (¶ 15). The Krueger exemplar has **no** such statement (no match for "consent" in its text), so the filed Krueger complaint does not meet 7008(a) on its face. The Krueger sample follows its exemplar and therefore has no such paragraph; a complaint built from it would need one added.
4. **Clerk's cover sheet.** L.B.R. 7003-1 requires the Clerk's Adversary Proceeding Cover Sheet with a paper complaint. The TIG exemplar's pages 1 and 2 are that form (B1040). The template does not generate it.
5. **CM/ECF header.** The court's header line on each page of the exemplars (`Case 26-00127-pmm Doc 1 Filed … Page N of M`) is added at filing. The template does not reproduce it.
6. **Certificate of service.** The `certificate:` block follows the Krueger exemplar and is optional. L.B.R. 9014-4(a) requires a certificate for a document "required to be served" and names applications, motions, objections and notices; a complaint is served with a summons (FRBP 7004, not fetched for this pass), so the certificate here is author practice. The L.B.F. 9014-4 form was not fetched.
7. **TIG sample is an excerpt.** Paragraphs 24 to 122 of the TIG filing are not transcribed. The template numbers the sample's paragraphs 1 to 60 itself, so they do not match the filing (Count I is filed ¶ 124 and is ¶ 24 in the sample). Paragraph 23's block quotation is abridged and marked in brackets in the sample. The Krueger sample is the full text (¶¶ 1 to 88), and its numbers match the filing.
8. **Alignment.** Body text is left-aligned, not justified. The exemplars' justification could not be read from the text layer; this is a convention choice.
9. **Two filers.** The tier-2 rule asks for 2 or 3 filers. Two are present (Kang Haggerty LLC and Salzmann Hughes PC). Other searches were not usable: Golas v. Bliss (26-00166) and Acey v. City of Philadelphia (26-00162) are scans with no text layer; Shubert v. Chun (26-00205) is not available on RECAP.
10. **Tool gate not run.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`, which this doc-type folder does not have, and the brief forbids editing `tools/`. The page review above stands in for Gate 2.

## Search log (exemplars)

- CourtListener search API, `court=paeb`, `type=r`, `q="adversary proceeding" complaint`, `filed_after=2026-01-01`, 31 results. Downloadable complaints checked: TIG Reaper (chosen), Krueger (chosen), Golas (scan), Acey (scan). Shubert v. Chun (26-00205, Doc 1) is `is_available: false`.
- Dates: docket numbers and filing dates are from each PDF's header stamp.
