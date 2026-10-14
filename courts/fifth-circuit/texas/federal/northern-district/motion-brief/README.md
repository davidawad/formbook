# txnd: motion-brief

Doc type: **motion-brief**, a brief in support of a Rule 12(b) motion to dismiss with its memorandum, in the United States District Court for the Northern District of Texas (`txnd`).
Folder: `courts/fifth-circuit/texas/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-coney-4-26-cv-00713-motion-brief.pdf` (Defendants' brief in support of a renewed Rule 12(b)(1), (4), (5), (6) motion, with table of contents and index of authorities); second filer `exemplars/FILED-EXAMPLE-legacy-fertel-4-26-cv-00792-motion-brief.pdf` (Plaintiff's combined motion and brief). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-coney-motion-brief.md` (a portion of the 32-page filing: caption, introduction, issues, background, argument A (1 to 3), B (1 to 3), C, conclusion, certificate of service, signature blocks; the argument after section C is omitted) |
| typeface | face required: none (LR 7.2 sets the size, 12 pt or larger; LR 10.1 names no face) -> vendored substitute: EB Garamond (the default, `fonts/eb-garamond/`) -> fit: n/a, no court-named face to match. The filed exemplars use Times New Roman; see Known gaps 4. |
| render | ok: `samples/OUTPUT-coney-motion-brief.pdf`, 11 pages (cover, table of contents, index of authorities, body pages 1 to 8), typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-14; `pdffonts` shows EBGaramond-Regular and EBGaramond-Bold embedded) |
| overlay | ok: `samples/OVERLAY-coney-motion-brief.pdf` and `samples/OVERLAY-coney-motion-brief.txt` (page map; regenerated 2026-10-14 against the Coney exemplar fetched from the URL in `exemplars/SOURCE.md`; the exemplar PDF is not committed) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed on 2026-10-14 after the re-render) |
| file names | the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (the names `tools/render.sh` and `tools/overlay.sh` use); see the complaint README |

## Governing rules

No primary-source text was fetched for the rules below in this run. The court's rule pages were not reachable from this box (courtrules.net returned 403 to a direct fetch and txnd.uscourts.gov returned 404 for the local-rules page). The "checked" column records the search-result excerpts used, not the full text. Before this template is treated as final, the full text of each rule must be read from the court's own site.

| Rule | Requirement | Checked | Where it is in the template |
|---|---|---|---|
| N.D. Tex. LR 7.2 (Briefs) | Type 12 point or larger; double spacing (quotations and headings may be single-spaced); margins of at least one inch; a brief must not exceed 25 pages, excluding the tables; a brief longer than 10 pages must have a table of contents and an alphabetical table of authorities with page references. | search excerpt, courtrules.net `local-rules/26655`, 2026-10-14 | `txnd-motion-brief()`: 12 pt, 24 pt pitch body, single-spaced quotations and headings, 1 inch margins; `outline()` for the table of contents; `index-of-authorities()` for the table of authorities. |
| N.D. Tex. LR 7.1 (Motion practice) | A certificate of conference is required for a motion for which conference is required; conference is not required for motions to dismiss (per the excerpt). | search excerpt, courtrules.net `local-rules/26653`, 2026-10-14 | No certificate of conference is produced. A non-dispositive motion that needs one must add it. |
| N.D. Tex. LR 10.1 (Required Form) | Typed or printed, 8½ × 11, numbered pages, title on each paper, signature block with bar number, fax and email. | search excerpt, courtrules.net `local-rules/26607`, 2026-10-14 | `signature-block()` (bar number, telephone, email); page numbers in the footer; the title on the cover. |
| Fed. R. Civ. P. 12(b) and 7(b) | The motion states its grounds; the grounds are stated in the motion. | not fetched | The cover carries the brief title; the grounds are stated in the body's introduction and issues. |
| Fed. R. Civ. P. 5(b) | Service of a filed paper. | not fetched | `CERTIFICATE OF SERVICE` heading and its text are sample content, not template content. |

Judge-specific requirements (individual judges' standing orders, including the presiding judge's page limit) are not checked. The courtrules.net copy of LR 7.2 includes a subsection on disclosing the use of generative AI that the court-site excerpt does not show. That subsection is not built into the template; check the current rule before filing.

## Layout

- Cover (no page number): court title on three centered lines; caption with § column; `CIVIL ACTION NO.` on the middle row; title of the brief, centered, bold, caps.
- Front matter, roman numerals: `TABLE OF CONTENTS` (generated from the body's headings, levels 1 to 3, with dot leaders); `INDEX OF AUTHORITIES` (generated from the frontmatter list, grouped Cases, Statutes, Rules, each entry with the pages on which its key appears in the body; "passim" beyond five pages).
- Body, arabic numerals from 1: double-spaced (24 pt pitch), 12 pt EB Garamond, 1 inch margins, 0.5 inch first-line indent; headings: level 1 centered bold, level 2 bold with hanging indent, level 3 bold with hanging indent; quotations single-spaced and indented 0.5 inch on both sides; bullets for the issues.
- Signature block at the right half: `Respectfully submitted,`; one block per signer (`/s/`, name, bar number, firm, address, telephone, email, role).
- Page numbers centered at the foot of each body and front-matter page.

## Overlay (`samples/OVERLAY-coney-motion-brief.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by word overlap (`tools/overlay.sh`). The overlay is a diagnostic, not a score: the sample is a portion of the filing, our page breaks do not follow the filing's, and our table pages (cover, contents, authorities) have no counterpart in the sample. The overlay's table-of-authorities page (our page 3) pairs with a filed page that shares few words, which is expected. Read the page map in `samples/OVERLAY-coney-motion-brief.txt`.

## Known gaps and open choices

1. **A portion, not the whole brief.** The sample transcribes pages 1 to 9 and 21 to 24 of the filing, in part: introduction, issues, background, the Rule 12(b)(1) and limitations argument, the service argument, the individual-liability section (the filing's section D; the sample calls it C), the conclusion, the certificate of service and the signature blocks. The filing's pleading-standards sections and its claim-by-claim discussion (pages 10 to 21) are omitted. The sample's body is therefore eight pages; a full 25-page brief has more.
2. **The index of authorities is hand-maintained.** The page numbers are computed by typst, but the list of authorities is the frontmatter `authorities` list. An authority that is cited in the body and not listed is not indexed. An authority whose `key` does not occur in the body shows no page. The keys are literal text (escaped for the regex), so a key must match the body's wording exactly.
3. **"Passim" threshold.** An authority on more than five pages is listed as `passim` (`toa-passim-after`). This is a choice; the rule does not say.
4. **Typeface (tier 2, open choice).** N.D. Tex. LR 7.2 names a size and no face (found by search, not read from the court's full text), so the rules do not require Times New Roman and the template keeps EB Garamond, per `docs/FONTS.md`. The filed exemplars use Times New Roman (system font). EB Garamond has a smaller x-height than Times at 12 pt. Switching to `Liberation Serif` (the Times New Roman substitute in `fonts/liberation-serif/`) would close the gap; that is a choice for the court's convention, not for the rules, and is left to the reviewer.
5. **Signature block alone on the last page.** The conclusion and the certificate of service sit on body page 7; the signature blocks fall alone on body page 8. The filed exemplar does the same (its signature runs onto page 24 with the certificate of service on it). Recorded as ACCEPTED.
6. **Certificate of service.** It follows the conclusion with no page break. The filed exemplar starts its certificate on a new page. Tier 2; open.
7. **Combined motion and brief.** The Legacy exemplar combines the motion and the brief in one filing; the template is the brief only. A combined filing would need its motion paragraph (grounds, relief requested) ahead of the brief's introduction.
8. **Footnotes** are not supported by the sample contract and none appear in the sample. The filing's footnotes (for example, the descriptions of the complaints' other claims) are summarized in the body text.
9. **Case-name italics.** The text layer carries no italic markup, so case names are not italicized in the sample. The template italicizes `*...*` markdown, so future samples can carry italics.
10. **Indent of the first paragraph** after the lead-in "COME NOW" is not reproduced; the template indents every body paragraph.
11. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. The page review below is the Gate 2 equivalent.

## Review of the rendered pages (`samples/OUTPUT-coney-motion-brief.pdf`, 11 pages)

Each page was rendered at 60 dpi and viewed after the last template change.

- Page 1 (cover, no number): court title on three lines; caption with § column; `CIVIL ACTION NO. 4:26-cv-00713-P-BJ` on one line (the caption's right column is 3.2 inches; the earlier 2.5-inch column wrapped the number); the brief title centered. Pass.
- Page 2 (`ii`): `TABLE OF CONTENTS`; levels 1 to 3 with dot leaders and page numbers; the subsection entries hang. Pass.
- Page 3 (`iii`): `INDEX OF AUTHORITIES`; Cases, Statutes, Rules; each entry with its pages (`5, 7`, `1, 2, 3, 4, 5`, `passim` where applicable); the page numbers match the body's headings. Pass.
- Page 4 (body 1): `COME NOW` paragraph (unindented, see gap 10); `I. INTRODUCTION AND SUMMARY OF ARGUMENT`; two paragraphs; `II. ISSUES PRESENTED` with bullets. Pass.
- Page 5 (body 2): bullets continue; `III. FACTUAL AND PROCEDURAL BACKGROUND`; paragraphs; the procedural history paragraph. Pass.
- Page 6 (body 3): `IV. ARGUMENT AND AUTHORITIES`; `A.` heading (two lines, hanging indent); `1.` and `2.` headings with the Rule 12(b)(1) paragraphs. Pass.
- Page 7 (body 4): the `2.` paragraphs (Terry, the hybrid-claim paragraph, Escamilla, the application to Plaintiff); the `3.` heading (statute of limitations) kept with its first paragraph. Pass.
- Page 8 (body 5): the `3.` paragraphs (accrual, the events alleged, the limitations conclusion); `B.` heading (two lines) kept with its paragraph. Pass.
- Page 9 (body 6): `1.` heading (12(b)(4)/(5)); `2.` heading; the Rule 4(h) block quotation (single-spaced, indented) and the paragraphs that follow it; `3.` heading. Pass.
- Page 10 (body 7): `C.` heading (two lines); its paragraph; `V. CONCLUSION`; `CERTIFICATE OF SERVICE`; `/s/` line. Pass (see gap 6).
- Page 11 (body 8): `Respectfully submitted,`; two signature blocks (`/s/`, name, bar number, firm, address, telephone, email, role). Pass (see gap 5).

Earlier review rounds found and fixed the same defects the complaint had (see the complaint README): the caption and signature lines overlapped (single-spaced stacks needed a gap); the caption's case number wrapped (column widened).
