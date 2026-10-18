# ohsd: motion-brief

Doc type: **motion-brief**, a Rule 12(b) motion to dismiss with its memorandum in support, in the United States District Court for the Southern District of Ohio (`ohsd`). The motion and the memorandum are one document, as in the filed exemplar.
Folder: `courts/sixth-circuit/ohio/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (full transcription of the 8-page filing) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 |
| overlay | ok: `usage/OVERLAY-sharp-motion-to-dismiss.pdf` and `OVERLAY-sharp-motion-to-dismiss.txt` |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed in the final layout) |

File names follow `tools/overlay.sh` and CLAUDE.md (see the complaint README for the reasoning).

## Governing rules

Primary sources, read 2026-10-14 (the same copies as the complaint README):
- S.D. Ohio Local Rules as amended 2024-10-21: `https://www.ohsd.uscourts.gov/sites/ohsd/files/2024-10-21%20Local%20Rules.pdf`.
- Fed. R. Civ. P. 10, 12: `https://www.law.cornell.edu/rules/frcp/rule_10`, `.../rule_12`.

| Rule | Requirement (verified text unless noted) | Where it is in the template |
|---|---|---|
| S.D. Ohio Civ. R. 5.1(a) | 8½ × 11 paper, double-spaced except block quotations, consecutive page numbers, one-inch margins on all sides for electronic filings. No typeface or point size is set. | `page-w`, `page-h`, `margin = 1in`, `body-leading`, page number in the footer. |
| S.D. Ohio Civ. R. 7.2(a)(1) | A motion is accompanied by a memorandum in support, a brief statement of the grounds with the authority relied on; a certificate of service in accordance with Civ. R. 5.2 accompanies the papers. | The memorandum is the body after `# MEMORANDUM IN SUPPORT`; the certificate is `certificate` in the frontmatter. |
| S.D. Ohio Civ. R. 7.2(a)(3) | The Court prefers memoranda not to exceed 20 pages; a longer memorandum needs a combined table of contents and summary of no more than five pages. A judge may set limits by standing order. | Not triggered (7 pages). The template does not produce a table of contents; a memorandum over 20 pages would need one added by hand. |
| S.D. Ohio Civ. R. 7.2(b)(3) | Filings that reference a prior filing give pinpoint citations to the PageID number. | Author content: the sample keeps the filed `PageID` cites. The template does not check them. |
| S.D. Ohio Civ. R. 5.2(a) | Proof of service states the date and manner of service and the persons served, on or attached to the paper served. | `certificate` renders the statement and the signature; its text is the author's (the sample's text is the filed text). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, title, file number and Rule 7(a) designation. | `court-title`, `caption`. Verified 2026-10-14. |
| Fed. R. Civ. P. 12(b) | Defences by motion, before pleading if a responsive pleading is allowed: "(1) lack of subject-matter jurisdiction", "(6) failure to state a claim upon which relief can be granted". | Author content (the grounds in the title and body). Verified 2026-10-14. |
| Fed. R. Civ. P. 12(a)(1)(A)(i) | Answer within 21 days after service of the summons and complaint. | Not rendered (timing is the author's). Verified 2026-10-14. |
| Fed. R. Civ. P. 5(d) | Certificate of service on filing. **Not re-fetched in this pass** (from memory). | Via `certificate`. |

The S.D. Ohio local rules put no page limit on a motion and no font or point size on any filing. The template's EB Garamond 12 pt is a working standard, as in the complaint (see the complaint README, Known gaps).

## Layout

- Letter paper, one-inch margins, EB Garamond 12 pt, double-spaced (24 pt baseline pitch), page number centred at the foot.
- Court title and caption as in the complaint: the parties in a left column with right and bottom rules; the case number, the judge line and the title of the motion on the right in bold single-spaced type.
- Page 1: the motion paragraph, then the motion's own signature block (`motion_signature: true`, no date line, as in the filing).
- The memorandum starts on a new page (`new_page_before: "MEMORANDUM IN SUPPORT"`), centred bold capitals.
- Roman-numeral sections (level 2) are bold and left-aligned; lettered sub-sections (level 3) are bold italic and left-aligned.
- The memorandum's closing paragraph and its signature block are one unbreakable block.
- The certificate of service is one unbreakable block: centred bold heading, the statement, and the signature.
- Body paragraphs are unnumbered (`numbered: false`), with a 0.5 inch first-line indent.

## Overlay

`usage/OVERLAY-sharp-motion-to-dismiss.pdf`: red is our render, blue is the filed exemplar, black where both agree. Pages pair one to one: our pages 1 to 7 pair with filed pages 1, 2, 3, 4, 6, 6, 7. Word overlap is 96% on page 1, 93% on page 2, 72% on page 3, 57% on page 4, 48% on page 5, 50% on page 6, and 63% on page 7. The overlap falls from page 3 on; I did not work out why (the page-by-page line breaks would need a line-level comparison). The overlay is a diagnostic, not a score.

## Review findings (rendered pages, 60 dpi)

Findings from the first renders, all fixed:
- The caption title block was double-spaced (it inherited the body leading). Fixed: single-spaced.
- The memorandum did not begin on a new page and the motion had no signature of its own (the filed page 1 has both). Fixed: `new_page_before` and `motion_signature`.
- The "CERTIFICATE OF SERVICE" heading was drawn over the first line of its text (a sticky heading after an unbreakable signature block). Fixed: the certificate is one unbreakable block.
- Section headings were centred; roman-numeral sections in a memorandum are left-aligned in the filing. Fixed: level 2 left, level 3 bold italic.

Pages reviewed in the final layout: 1 (caption, motion and its signature), 2 (memorandum begins, introduction), 3 (II and A, standard of review), 4 (B), 5 (end of B and C), 6 (end of C), 7 (III, conclusion, signature, certificate). No cover spill, no heading at a page foot, no overlapping lines.

## Known gaps

- **Tier 2 is not met: one filer.** Other S.D. Ohio motions with a combined memorandum were found in the search (for example *Albright v. University of Cincinnati*, 1:26-cv-00344, doc 7, and *Krivatch v. Sweepsteakes Limited*, 2:26-cv-00132, doc 21, whose memorandum is a separate attachment). Their RECAP copies were not fetched in this pass.
- **The filed motion has its signature block on page 1 and at the end.** The template renders the motion's signature on page 1 (`motion_signature`) and the memorandum's signature before the certificate. Both come from the same `signature` lines, so the two must be kept in step by the author.
- **Length.** The render is 7 pages against the filing's 8. The filed certificate sits on its own page 8; ours fits on page 7. I did not work out the cause of the difference in page breaks.
- **No table of contents or summary** (Civ. R. 7.2(a)(3)); not needed at 7 pages, but a memorandum over 20 pages needs them, added by hand.
- **Division and judge** are the author's; the sample uses the filed judge line.
- **Certificate text is not fixed by the rules.** Civ. R. 5.2 requires the date, the manner and the persons served; the sample copies the filed text.
- **The exemplar's ECF header** ("Case: 1:26-cv-00448-JPH Doc #: 8 Filed: 05/12/26 Page 1 of 8") is produced by the filing system, not by this template; the template does not reproduce it.
- **Typeface and size** as in the complaint README: EB Garamond 12 pt, not set by the local rules.

## Engines

**docx** (`docx/`): `build-reference.sh` builds `docx/reference.docx` from pandoc's default (EB Garamond 12 pt, exact 24 pt double spacing, one-inch margins, centred PAGE footer, heading and paragraph styles). `ohsd.lua` sets the court title, the caption table, the motion's own signature (undated, after the first paragraph), the memorandum page break, the closing signature, and the certificate of service. Render: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice 26.8.1, EB Garamond embedded), 7 pages, the same count as the typst render. Reviewed: all 7 pages of the `.docx.pdf` and all 7 pages of the typst render, at 60 dpi, in the final state.

- Matches typst: letter paper, margins, EB Garamond 12 pt, 24 pt body pitch, the page count (7), the court title and caption, the motion paragraph and its signature on page 1 (signature lines 24 pt apart as in typst), the memorandum starting on page 2, the section headings, the closing and certificate on page 7, the centred page number.
- Differs (tier 2, not chased): line breaks differ on most pages; the break after page 4 is one line later in the docx, so page 5 starts at a different sentence; the body text on page 1 starts about 6 pt lower than typst (the caption spacing constant, measured); the certificate heading has a little more space above it than in typst.
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
- BLOCKED: none. No table of contents, table of authorities, line numbering or bookmarks are required for this document (the memorandum is 7 pages, under the 20-page preference of Civ. R. 7.2(a)(3)).
- Gates: `sh tools/check.sh courts/sixth-circuit/ohio/federal/southern-district --engine docx` exits 2 before any gate runs: `checks.yaml` (and `rules.md`) do not exist yet for this court, so Gates 0 to 3 are not run for docx. Not changed here.
