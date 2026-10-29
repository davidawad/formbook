# ohsd: motion-brief

Doc type: **motion-brief**, a Rule 12(b) motion to dismiss with its memorandum in support, in the United States District Court for the Southern District of Ohio (`ohsd`). The motion and the memorandum are one document, as in the filed exemplar.
Folder: `courts/sixth-circuit/ohio/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, Surdyk, Dowd & Turner Co., L.P.A.; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (full transcription of the 8-page filing; the motion's paragraph in the frontmatter's `motion`) |
| render | ok (2026-10-29, fb-595.17.18): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 7 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with S.D. Ohio's local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay courts/sixth-circuit/ohio/federal/southern-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 7 of 7 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |

## Governing rules

Primary sources, read 2026-10-14 (the same copies as the complaint README):
- S.D. Ohio Local Rules as amended 2024-10-21: `https://www.ohsd.uscourts.gov/sites/ohsd/files/2024-10-21%20Local%20Rules.pdf`.
- Fed. R. Civ. P. 10, 12: `https://www.law.cornell.edu/rules/frcp/rule_10`, `.../rule_12`.

| Rule | Requirement (verified text unless noted) | Where it is in the layout |
|---|---|---|
| S.D. Ohio Civ. R. 5.1(a) | 8½ × 11 paper, double-spaced except block quotations, consecutive page numbers, one-inch margins on all sides for electronic filings. No typeface or point size is set. | The base (letter, one-inch margins, 12 pt, 24 pt double pitch); `page_number` (the motion's page unnumbered, the memorandum from 1, as filed). |
| S.D. Ohio Civ. R. 7.2(a)(1) | A motion is accompanied by a memorandum in support, a brief statement of the grounds with the authority relied on; a certificate of service in accordance with Civ. R. 5.2 accompanies the papers. | `cover` (the motion and its signature), the body (the memorandum from a new page), `closing` (signature and certificate). |
| S.D. Ohio Civ. R. 7.2(a)(3) | The Court prefers memoranda not to exceed 20 pages; a longer memorandum needs a combined table of contents and summary of no more than five pages. | A preference, not a limit: not checked (7 pages). A table of contents is not templated (Known gaps). |
| S.D. Ohio Civ. R. 7.2(b)(3) | Filings that reference a prior filing give pinpoint citations to the PageID number. | Author content. |
| S.D. Ohio Civ. R. 5.2(a) | Proof of service states the date and manner of service and the persons served, on or attached to the paper served. | `certificate` (the text is the author's). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, title, file number and Rule 7(a) designation. | `cover`. Verified 2026-10-14. |
| Fed. R. Civ. P. 12(b) | Defences by motion: "(1) lack of subject-matter jurisdiction", "(6) failure to state a claim upon which relief can be granted". | Author content. |
| Fed. R. Civ. P. 5(d) | Certificate of service on filing. **Not re-fetched in this pass** (from memory). | Via `certificate`. |

The S.D. Ohio local rules put no page limit on a motion and no font or point size on any filing: the base's Times New Roman 12 pt.

## Layout

The generic FRCP brief with S.D. Ohio's overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/ohsd-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Page 1 (the model's cover, unnumbered as filed): the court's name and division centered in bold; the caption as the exemplar sets it: each party's names, a blank line, its designation an inch in, "v." a blank line from each, a column of ")" beside every line, `Case No.` and the judge a line apart at the right from the top; the title bold and centered between two rules; the motion double-spaced; its own signature block from 3.1 in.
- The memorandum from page 2, numbered from 1: MEMORANDUM IN SUPPORT centered in bold capitals; sections (I., II.) bold at the margin, sub-sections (A., B.) bold italic, all at the type size on the body pitch with no space of their own, kept with the next block.
- Body double-spaced (24 pt), first-line indent 0.5 in; paragraphs are not numbered.
- Closing: "Dated:" and the date at the margin when the sample gives one, "Respectfully submitted," and the signer's lines from 3.1 in; kept whole with the last paragraph. Then the certificate of service, kept whole: centered bold heading, the statement, the signature lines.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`; `case_label` (default "Case No."); `judge` (optional); `division`; `caption.parties` (list of `{names, designation}`); `brief_title`; `legend` (optional); `motion` (the motion's text, set on page 1 with its own signature; optional); `date` (optional); `signature.lines`; `certificate` (optional: `text`, `lines`).
- Body: the memorandum: `#` its title, `##` sections, `###` sub-sections; paragraphs.

## Known gaps

- **Tier 2 is not met: one filer** (OPEN). Other S.D. Ohio motions with a combined memorandum were found in the search (*Albright v. University of Cincinnati*, 1:26-cv-00344, doc 7; *Krivatch v. Sweepsteakes Limited*, 2:26-cv-00132, doc 21); their RECAP copies were not fetched.
- **The filed motion has its signature block on page 1 and at the end.** Both come from the same `signature` lines.
- **No table of contents or summary** (Civ. R. 7.2(a)(3)); not needed at 7 pages.
- **Division and judge** are the author's; the sample uses the filed judge line.
- **The exemplar's ECF header** is produced by the filing system, not by this template.
- **Typeface and size** as in the complaint README: Times New Roman 12 pt, not set by the local rules (the filing is in Times New Roman too).

## Review of the rendered pages (Gate 2 record, 7 of 7 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx, 196/196 lines), so one row per page covers all three. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`); this pod has no image viewer. DEF-COVER-002 (page 1 against the exemplar) passes on all three engines with three tier-3 differences ACCEPTED in `eval.yaml` (the filer's doubled caption rule, the signature line under "/s/", the e-mail addresses tabbed under the first).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name and division; caption with the ")" column, Case No. and the judge at the right; the four-line title between two rules; the motion; its signature block, all on the page as filed; no page number | OK. |
| 2 | MEMORANDUM IN SUPPORT, I. INTRODUCTION AND BACKGROUND, two paragraphs; page number 1 | OK. |
| 3 | II. LAW AND ANALYSIS, A. Standard of Review | OK. |
| 4 | B. (its heading on two lines), its argument | OK. |
| 5 | C., its argument | OK. |
| 6 | C. (end); the page ends short: III. CONCLUSION, its paragraph and the signature are kept together on page 7 | ACCEPTED (tier 2: the signature never stands alone). |
| 7 | III. CONCLUSION, its paragraph, "Dated:" with "Respectfully submitted," and the signer's lines; the certificate of service, whole | OK. |

Tier 2 against the exemplar: the filing runs to 8 pages with the certificate alone on the last; ours fits it on page 7 (ACCEPTED: the rules leave it open). The exemplar's closing signature has no date line; ours prints the sample's `date` (ACCEPTED: the author's field).

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/ohio/federal/southern-district/motion-brief --engine typst   # 11 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/ohio/federal/southern-district/motion-brief --engine latex   # 14 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/ohio/federal/southern-district/motion-brief --engine docx    # 15 passed, 0 failed
```

`tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has none, so it does not run here.

## Engines

typst (primary): `typst/main.typ` -> `typst/ohsd-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.18). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx. BLOCKED: none.
