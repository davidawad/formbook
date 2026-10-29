# paed: motion-brief

Doc type: **motion with memorandum of law** (a Rule 12(b) motion to dismiss, the proposed order, the certificate of service, and the memorandum in support) in the United States District Court for the Eastern District of Pennsylvania (`paed`). Folder: `courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (two filers; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 38-page filing; see the frontmatter comment) |
| typeface | face required: **none** (the E.D. Pa. local civil rules name no face; see Governing rules). Font: **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard; the typst, docx and LibreOffice PDF all name it (`fb lint fonts` does not report the folder) |
| render | ok (2026-10-29): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 10 pages each, on the generic FRCP brief (fb-595.92); vendored fonts only, no warnings; latex and docx break every line and page where typst does (XENG-001..003 gated) |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 10 of 10 on each engine (2026-10-29, the FRCP-base render: `reviews/2026-10-29.md`) |
| tier 1 (mandated form) | checked against the rules below; no typography rule in the E.D. Pa. local civil rules |
| tier 2 (professional convention) | judged against one filer only; no table of authorities (see Known gaps) |

Naming: file roles follow the repo's convention (`INPUT-` / `OUTPUT-` / `OVERLAY-`), which `tools/render.sh` and `tools/overlay.sh` read and write by default.

## FRCP base (fb-595.92): moved

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and the shared
document model (docs/EVAL-LOOP.md, "Generated engines"). The packet's papers before the memorandum are the base's
`lead` (fb-595.92): the proposed order (LR 7.1(a)) from `<!-- order -->` to `<!-- motion -->`, unnumbered, under its
caption and `ORDER`, closed by the court's "BY THE COURT:" and the judge's line; the motion (FRCP 7(b)(1)) from
`<!-- motion -->` to `<!-- memorandum -->`, numbered from 1, closed by counsel's signature and the certificate of
service (LR 7.1(d), 5.1.2(7)(b)); then the memorandum (LR 7.1(c)): its caption page unnumbered, the contents in roman
from i, the text from 1 with I./A./1. headings numbered by the layout, counsel's signature. The order's numbered items
stand half an inch in (`list.left`, fb-595.92). `typst/layout.yaml` names the base and holds the papers (the caption
written once, a YAML anchor); `typst/paed-motion-brief.typ` only names the face; `fb engines gen` writes `latex/` and
`docx/` from the merged layout. The render's text is the old template's, line for line and page for page.

## Governing rules

Primary source: **Local Rules of Civil Procedure, E.D. Pa.** (consolidated civil rules PDF dated 05/08/2023, linked from https://www.paed.uscourts.gov/local-rules/Local%20Civil%20Rules): https://www.paed.uscourts.gov/sites/paed/files/documents/locrules/civil/cvrules.pdf. Downloaded and read 2026-10-14. Rule 7.1 text quoted from that PDF (page 18).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| EDPA-MOT-001 | E.D. Pa. Local Civil Rule 7.1(a) | Every motion is accompanied by a form of order that, if approved, would grant the relief sought. | the proposed order: `<!-- order -->` section, `order_title`, `order-signature()` (`typst/paed-motion-brief.typ`); the order's text is case-specific and comes from the sample |
| EDPA-MOT-002 | E.D. Pa. Local Civil Rule 7.1(c) | A motion not certified as uncontested is accompanied by a brief containing a concise statement of the legal contentions and authorities relied upon. Counsel are directed to consult each judge's policies. | the memorandum: `<!-- memorandum -->` section, `memo_title`; the content is author-written |
| EDPA-MOT-003 | E.D. Pa. Local Civil Rule 7.1(d) | A written statement of the date and manner of service accompanies every motion not certified as uncontested. | the certificate of service: `service:` frontmatter, `certificate()` |
| EDPA-MOT-004 | E.D. Pa. Local Civil Rule 5.1.2(7)(b) | Every document filed through ECF contains a Certificate of Service stating that it has been filed electronically and is available for viewing and downloading from the ECF System, and identifying the manner of service on each party. | the certificate's text (`service.text`) |
| EDPA-MOT-005 | Fed. R. Civ. P. 7(b)(1) and 12(b) | A motion states with particularity the grounds for seeking the order (Rule 7(b)(1)); defenses under Rule 12(b)(1) and (6) are raised by motion. Rule text not fetched in this run. | author content (the motion's grounds paragraph and the memorandum) |
| EDPA-MOT-006 | E.D. Pa. Local Civil Rule 7.1 (page limits) | None in the local rules text for civil briefs. The habeas limits (30 pages) do not apply. Judge-specific policies control. | not enforced |

Local typography and margin rules: **none in the E.D. Pa. local civil rules text above.** Re-checked 2026-10-15 by extracting the full text of the 05/08/2023 PDF (poppler `pdftotext`): no typeface, font size, spacing or margin rule in Rules 5.1, 5.1.1, 5.1.2 or elsewhere. So no face is named; the template sets Times New Roman, the face of the filed exemplar and the house standard. The typeface, size, spacing, margins and page-numbering below are convention, chosen to match the filed exemplar. Roman numerals for the table of contents and arabic numerals from 1 for the body follow the exemplar.

Not produced: the table of authorities (not required by the local rules; the exemplar has one; see Known gaps), the summons, and a separate notice of motion (the exemplar has none; the motion itself carries the request).

## Layout (the convention, from the exemplar)

Order of the filed document, each part starting on a new page (a Word section in the docx):

1. **Proposed order**: court title, caption, `ORDER` title, the decretal paragraph, the numbered items (the number half an inch in, the text hanging at 0.9 in), `BY THE COURT:` and the judge's line (`J.`) from 3.7 in, kept with the last item; no page number.
2. **Motion**: court title, caption, the motion title (bold, centered, single-spaced), the motion's paragraphs (unnumbered, first-line indented, double-spaced), the signature blocks kept with the last paragraph (`Date:` at the left; from 2.8 in `Respectfully submitted,`, each counsel block with `By: /s/`), then the certificate of service (heading, text and signature kept together, so it may open a page); arabic page numbers from 1.
3. **Memorandum cover**: court title, caption, the memorandum title (bold, centered); no page number.
4. **Table of contents**: one row per memorandum heading, single-spaced, 12 pt apart, indented half an inch per level, the label in a half-inch box, a dot leader to the page in a half-inch column; roman page numbers from i. The docx takes its pages from the LibreOffice render (fb render's passes).
5. **Memorandum body**: arabic page numbers from 1. Headings numbered by the template, at the type size on the body pitch with no space of their own, kept with the next block: `I.` for level 1 (centered bold capitals), `A.` for level 2 (bold, the label in a half-inch box, the title hanging), `1.` for level 3 (the same, the title bold italic). Block quotations single-spaced, indented half an inch from both margins, 12 pt above and below. The last paragraph is kept with the signature blocks.

Every line is a box of its pitch (the cross-engine layout model, `lib/typst/xengine.typ`, `lib/docx/xengine.lua`): 24 pt for the body and the headings (double spacing, as the exemplar), 13.8 pt for single lines (court title, caption, titles, quotations, contents, signatures, footer); the spaces between blocks explicit. The page number is centred in a single line ending 0.5 in above the page edge.

Caption: court title in bold centered single lines, a blank single line, the party block in single lines, a column of `:` marks (one per party line), and `CIVIL ACTION` / `No. <case>` on the right around the middle line of the party column (the exemplar's form). A blank case number prints as a line.


## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `court_lines` (list), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `order_title`, `motion_title`, `memo_title`, `date`, `signature.blocks` (list of `{firm, signer, lines}`; `By: /s/ <signer>` is inserted above `lines`), `service` (`date`, `text`, `signer`, `lines`).
- Body: three sections, each opened by a marker line on its own: `<!-- order -->`, `<!-- motion -->`, `<!-- memorandum -->`. A section runs to the next marker. All three are required.
- Within a section: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3); a list (`1.` items); a block quotation (lines starting `>`); or a paragraph.
- Underscores used as blanks must be escaped (`\_`), or typst reads them as markup and the render fails on warnings.
- Not supported: tables, footnotes (none used), raw typst.

## Render and overlay

```sh
sh tools/render.sh courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh --engine docx courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief usage/INPUT-motion-brief.md
just overlay courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief
```

The overlay (red = our render, blue = exemplar, black = both) is a diagnostic, not a score: the filed exemplar has an ECF header, bold and underlined captions and its own line breaking.

## Visual review (before the FRCP base, 2026-10-22; the current record is `reviews/2026-10-29.md`)

| Page | What it is | Finding |
|---|---|---|
| 1 | Proposed order: caption, ORDER, decretal paragraph, items 1 to 3, BY THE COURT and the judge's line | OK, both engines alike. No page number. |
| 2 (1) | Motion: caption, title (three bold single lines), AND NOW paragraph, WHEREFORE | OK. Ends short: the last paragraph moves on with the signature blocks. |
| 3 (2) | "Defendants further request", the date and the two counsel blocks | OK. |
| 4 (3) | Certificate of service with its signature | OK; kept whole, it opens the page. |
| 5 | Memorandum cover: caption and memorandum title | OK. No page number. |
| 6 (i) | Table of contents | OK. Pages 1, 1, 1, 2, 4, as the body prints them, in both engines; the II.B row wraps and its page sits on the wrapped line. Word's leader runs into the number (docs/DOCX.md). |
| 7 (1) | I. INTRODUCTION, II. LEGAL ARGUMENT, A. Legal Standard and its lead-in | OK. The quotation moves whole to the next page. |
| 8 (2) | Block quotation, Monge, Morse, Pittsburgh, Aichele; B. (two-line heading) and the standing argument | OK. |
| 9 (3) | Standing argument continued | OK. Ends short: the conclusion stays with the signature. |
| 10 (4) | III. CONCLUSION, signature blocks | OK. |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 212/212 lines, 10/10 pages).

Defects of the earlier template (fixed by the cross-engine port, fb-595.68.35): blocks snapped to whole 24 pt rows by measuring (`on-grid`), unbreakable paragraphs, level-1 memorandum headings at typst's default heading size, the contents from `outline()`; a docx in EB Garamond that no longer opened (its section breaks named footer ids pandoc had renumbered: DEF-DOCX-OPEN) and a TOC field without entries until Word updated it.

## Known gaps and open choices

1. **Table of authorities.** The exemplar has one (three pages in the filed memorandum). The local rules do not require one, and the template does not generate one. The sample's TOC is generated; the TOA is not. A tier-2 finding: a 25-page brief would be expected to carry one by convention. **Needs a call from David** (generate it from `toa:` links, as the CAND motion template does, or leave it out).
2. **One filer only.** The tier-2 rule asks for two or three exemplars from different filers. Only Harvie was saved. Athilekshmi v. Drexel (2:26-cv-02593) was located but not fetched (no RECAP document was reachable in the search results). Tier 2 is therefore not yet judged against the 2-to-3-filer standard.
3. **Typeface.** The local rules name no face. Times New Roman 12 pt, the face of the filed exemplar and the house standard, in every engine.
4. **Proposed order and certificate.** Included as sections of the sample, not as separate files. The local rule requires a proposed order to accompany each motion; in ECF practice it is a separate PDF. The filing is the exemplar's form.
5. **Partial transcription.** Parts II.C to II.F (defamation, false light, time bar, fees under the Anti-SLAPP Act) are not transcribed; the sample ends at Part III. The 8 to 14 page target is met (10 pages); a full memorandum would run 25 pages.
6. **Anti-SLAPP fee application.** 42 Pa. C.S. § 8340.18 is a state statute applied in federal court. The template does not check the fee request's content; it is author content.
7. **Judges' policies** (Local Civil Rule 7.1(c)) may require a different form. Not reflected.
8. **Page limits.** None in the local rules for civil briefs; the template does not count pages.
9. **Selftest.** `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have; `tools/check.sh` runs on it (typst and docx, 0 failed).
10. **Fed. R. Civ. P. 7(b)(1) and 12(b)** were not fetched in this run; the rule text is from the standard rule. Only the E.D. Pa. local rules PDF was downloaded and read.

## Engines

All three engines are generated from the merged layout (`fb engines gen`): `typst/` (the reference), `latex/`
(`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`; each paper a Word section, the order's without
a footer, the motion's numbered from 1). Checks (2026-10-29): typst 10 passed, latex 13 passed, docx 14 passed, 0
failed; XENG-001..003 PASS on latex and docx. Word is not available here; the docx is checked with LibreOffice.
