# paed: motion-brief

Doc type: **motion with memorandum of law** (a Rule 12(b) motion to dismiss, the proposed order, the certificate of service, and the memorandum in support) in the United States District Court for the Eastern District of Pennsylvania (`paed`). Folder: `courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer, defense counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 38-page filing; see the frontmatter comment) |
| typeface | face required: **none** (the E.D. Pa. local civil rules name no face; see Governing rules). Font: **EB Garamond** (vendored), kept under `docs/FONTS.md` "No face named"; no substitution made. `pdffonts` on the 2026-10-15 render: only EB Garamond embedded (Regular, Bold, Italic) |
| render | ok (re-run 2026-10-15): `usage/OUTPUT-motion-brief.typst.pdf`, 9 pages, typst 0.15.0, `--ignore-system-fonts`, no warnings |
| overlay | **fail** (re-run 2026-10-15): `tools/overlay.sh` exits 1 because `usage/` holds only `SOURCE.md`; the filed PDF named there is not in this snapshot. `usage/OVERLAY-harvie-motion-to-dismiss.txt` is the earlier page map, not regenerated; no `OVERLAY-harvie-motion-to-dismiss.pdf` exists |
| pages reviewed | 9 of 9 (re-rendered 2026-10-15 at 60 dpi; every page looked at, none changed) |
| tier 1 (mandated form) | checked against the rules below; no typography rule in the E.D. Pa. local civil rules |
| tier 2 (professional convention) | judged against one filer only; no table of authorities (see Known gaps) |

Naming: file roles follow the repo's convention (`INPUT-` / `OUTPUT-` / `OVERLAY-`), which `tools/render.sh` and `tools/overlay.sh` read and write by default.

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

Local typography and margin rules: **none in the E.D. Pa. local civil rules text above.** Re-checked 2026-10-15 by extracting the full text of the 05/08/2023 PDF (poppler `pdftotext`): no typeface, font size, spacing or margin rule in Rules 5.1, 5.1.1, 5.1.2 or elsewhere. So no face is named and EB Garamond stays. The typeface, size, spacing, margins and page-numbering below are convention, chosen to match the filed exemplar. Roman numerals for the table of contents and arabic numerals from 1 for the body follow the exemplar.

Not produced: the table of authorities (not required by the local rules; the exemplar has one; see Known gaps), the summons, and a separate notice of motion (the exemplar has none; the motion itself carries the request).

## Layout (the convention, from the exemplar)

Order of the filed document, each part starting on a new page:

1. **Proposed order**: court title, caption, `ORDER` title, the decretal paragraphs (numbered), `BY THE COURT:` with the judge's line and `J.`; no page number.
2. **Motion**: court title, caption, the motion title (bold, centered), the motion's paragraphs (unnumbered, first-line indented, double-spaced), the signature blocks (`Date:` at left; `Respectfully submitted,`, each counsel block with `By: /s/` on the right), then the **certificate of service** on the same run of pages. Arabic page numbers from 1.
3. **Memorandum cover**: court title, caption, the memorandum title (bold, centered); no page number.
4. **Table of contents**: generated from the headings (`outline`), roman page numbers from i.
5. **Memorandum body**: arabic page numbers from 1. Headings numbered by the template: `I.` for level 1 (centered bold capitals), `A.` for level 2 (bold, hanging), `1.` for level 3 (bold italic, hanging), `a.` for level 4. Block quotations single-spaced, indented 0.5 inch from each margin. Signature blocks at the end.

Caption: party block in single spacing, a column of `:` marks, and `CIVIL ACTION` / `No. <case>` on the right (the exemplar's form). A blank case number prints as a line.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `court_lines` (list), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `order_title`, `motion_title`, `memo_title`, `date`, `signature.blocks` (list of `{firm, signer, lines}`; `By: /s/ <signer>` is inserted above `lines`), `service` (`date`, `text`, `signer`, `lines`).
- Body: three sections, each opened by a marker line on its own: `<!-- order -->`, `<!-- motion -->`, `<!-- memorandum -->`. A section runs to the next marker. All three are required.
- Within a section: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3); a list (`1.` items); a block quotation (lines starting `>`); or a paragraph.
- Underscores used as blanks must be escaped (`\_`), or typst reads them as markup and the render fails on warnings.
- Not supported: tables, footnotes (none used), raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/eastern-district/motion-brief harvie-motion-to-dismiss
```

- `usage/OVERLAY-harvie-motion-to-dismiss.pdf`: red = our render, blue = exemplar, black = both. `OVERLAY-harvie-motion-to-dismiss.txt` is the page map (word overlap, coarse). Our page 9 pairs with the filed page 38 only because the conclusion's words recur; the page map is not a page-accurate alignment. The overlay is a diagnostic, not a score: the exemplar is Times with a different line breaking, so text lines will not coincide.

## Visual review (all 9 pages rendered at 60 dpi and looked at, final render)

| Page | What it is | Finding |
|---|---|---|
| 1 | Proposed order: caption, ORDER, decretal paragraphs 1 to 3, BY THE COURT line | OK. The blanks for the day and the year, and the judge's line, are underscores escaped in the sample; the judge's line is drawn as a rule. |
| 2 | Motion: caption, title (three bold lines), AND NOW paragraph, WHEREFORE, Defendants further request | OK. |
| 3 | Motion signature blocks (Date; Respectfully submitted; two counsel blocks) and the certificate of service | OK. Two counsel blocks run down the right column; the Date sits at the left. |
| 4 | Memorandum cover: caption and memorandum title | OK. The title's last line holds only "8340.18": the title is the exemplar's text and wraps there; a judge would not care, but it is visible. |
| 5 | Table of contents, roman i | OK. Entries with leaders and page numbers; the entry for Part II.B wraps and its page number sits on the wrapped line. |
| 6 | Body 1: I. INTRODUCTION, II. LEGAL ARGUMENT, A. Legal Standard (the lead-in sentence; the block quotation moves to the next page) | OK. Gap at the foot of the page (the unbreakable quotation). |
| 7 | Body 2: block quotation, Monge, Morse, Pittsburgh, Aichele, Schering | OK. |
| 8 | Body 3: B. (two-line heading kept with its paragraph), standing argument | OK. |
| 9 | Body 4: Part III, CONCLUSION, signature blocks | OK. |

Defects found during review and fixed in the template:

1. Paragraphs overlapped the paragraph after them on the first render (no fixed block height). Fixed by snapping each paragraph, heading and quotation to whole pitch rows (`on-grid`).
2. A paragraph that broke across a page overlapped the next paragraph (a fixed-height block that splits). Fixed by making paragraph blocks unbreakable: a paragraph moves whole to the next page. Gaps at the foot of pages 6 and 7 are the cost.
3. The TOC drew Part II.B's heading in the body style. Fixed by a hanging layout for level 2 and 3 headings.

## Known gaps and open choices

1. **Table of authorities.** The exemplar has one (three pages in the filed memorandum). The local rules do not require one, and the template does not generate one. The sample's TOC is generated; the TOA is not. A tier-2 finding: a 25-page brief would be expected to carry one by convention. **Needs a call from David** (generate it from `toa:` links, as the CAND motion template does, or leave it out).
2. **One filer only.** The tier-2 rule asks for two or three exemplars from different filers. Only Harvie was saved. Athilekshmi v. Drexel (2:26-cv-02593) was located but not fetched (no RECAP document was reachable in the search results). Tier 2 is therefore not yet judged against the 2-to-3-filer standard.
3. **Typeface.** The local rules name no face, so EB Garamond stays (`docs/FONTS.md`, "No face named"). The filed exemplar is Times New Roman, a choice by its filer, not a requirement. The text looks smaller than the exemplar, as in the complaint.
4. **Proposed order and certificate.** Included as sections of the sample, not as separate files. The local rule requires a proposed order to accompany each motion; in ECF practice it is a separate PDF. The filing is the exemplar's form.
5. **Partial transcription.** Parts II.C to II.F (defamation, false light, time bar, fees under the Anti-SLAPP Act) are not transcribed; the sample ends at Part III. The 8 to 14 page target is met (9 pages); a full memorandum would run 25 pages.
6. **Anti-SLAPP fee application.** 42 Pa. C.S. § 8340.18 is a state statute applied in federal court. The template does not check the fee request's content; it is author content.
7. **Judges' policies** (Local Civil Rule 7.1(c)) may require a different form. Not reflected.
8. **Page limits.** None in the local rules for civil briefs; the template does not count pages.
9. **Shared tools not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. Render and overlay were run; the review above is the Gate 2 record for this doc type.
10. **Fed. R. Civ. P. 7(b)(1) and 12(b)** were not fetched in this run; the rule text is from the standard rule. Only the E.D. Pa. local rules PDF was downloaded and read.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/paed.lua`): pandoc on a reference with the template's typography (EB Garamond 12 pt, exact 24 pt line pitch, 0.5 in first-line indent, 1 in margins on US Letter, single-spaced block quotations indented 0.5 in from both margins, the counsel blocks and the caption single spaced). The memorandum's headings are numbered by a Word list attached to the heading styles (I. for level 1, centered capitals; A. for level 2; 1. for level 3, bold italic), as the typst `heading-num` does. The Lua filter builds the cover of each part, the proposed order's signature, the counsel signature blocks, the certificate of service, the table of contents field, and the section breaks: order (no page number), motion (arabic from 1), memorandum cover (none), contents (roman from i), memorandum body (arabic from 1). The section breaks name the reference's footers as `rId9` (page number) and `rId10` (empty), the ids pandoc gives them; a rebuild must keep those ids (check `word/_rels/document.xml.rels`). Output: `usage/OUTPUT-motion-brief.docx`. Built with `sh docx/build-reference.sh docx/reference.docx` and `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/paed.lua usage/INPUT-motion-brief.md -o usage/OUTPUT-motion-brief.docx`. Checked only as a zip of well-formed XML. Not opened in Word or LibreOffice.
- **docx differs from typst**: the caption's right cell is top-aligned; the proposed order's judge line is a paragraph border 2.8 in wide (typst 2.6 in); the table of contents is a TOC field with the update-on-open flag, so its entries and page numbers appear only after Word or LibreOffice updates fields (the cached text is a placeholder); pagination is Word's; no table of authorities (none in the typst template either).
- **Source issue that the docx shows**: `usage/INPUT-motion-brief.md` has an unescaped `*` in "at *9" (Monge citation). Typst keeps it as a literal asterisk. pandoc treats it as an unclosed emphasis marker: the asterisk is dropped from the docx and the italics of the citations after it are shifted (the Monge to Pittsburgh citations). Fix: escape it as `\*9` in the sample (not changed here: samples are read-only for this build).
- **docx BLOCKED**: this court folder has no checks file (no `checks.yaml`), so no gate check ID can be listed. Gates 0 to 3 on `usage/OUTPUT-harvie-motion-to-dismiss.docx.pdf` are BLOCKED. Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked. The TOC entries and page numbers are unchecked until the fields are updated (see above).
