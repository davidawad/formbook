# mdd: motion-brief (memorandum in support of a Rule 12(b) motion)

Doc type: **motion-brief**: the memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b), filed with the motion and a proposed order (LR 105.1) in the United States District Court for the District of Maryland (`mdd`). Folder: `courts/fourth-circuit/maryland/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (complete: caption, text, conclusion, signature block, certificate of service) |
| typeface | Rule names Times New Roman (LR-102.2.b, "Times New Roman or larger typeface"). Set in **Times New Roman** itself (the pinned files of `docs/FONTS.md` rule 1; Liberation Serif only as fallback), on typst and docx. Text 12 pt, footnotes 10 pt. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 12 pages each, vendored faces only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.9) |
| overlay | ok: `usage/OVERLAY-hylton-motion-brief.pdf` and `usage/OVERLAY-hylton-motion-brief.txt`, against the filed exemplar fetched from the RECAP URL in `usage/SOURCE.md` and checked against its SHA-256 (the exemplar PDF is not committed in this snapshot; it is passed to `tools/overlay.sh` as the third argument) |
| pages reviewed | 12 of 12 on typst, latex and docx after the move onto the FRCP base (2026-10-29: every page's text layout and the checks' geometry; see "Gate 2 review on the FRCP base") |
| render command | `sh tools/render.sh courts/fourth-circuit/maryland/federal/district/motion-brief usage/INPUT-motion-brief.md` |
| overlay command | `sh tools/overlay.sh courts/fourth-circuit/maryland/federal/district/motion-brief hylton-motion-brief` |

File names: as in the complaint folder, the names follow the repo's tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), which were not edited.

## Governing rules

Primary sources, fetched 2026-10-14:

- **D. Md. Local Rules, effective December 1, 2025** (the adopted version): https://www.mdd.uscourts.gov/sites/mdd/files/LocalRules.pdf (linked from https://www.mdd.uscourts.gov/local-rules). Quoted text below is from that PDF.
- **Fed. R. Civ. P.** 8(a), 12(b): https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_12.

| ID | Rule | Requirement (quoted or closely paraphrased) | Where it lives |
|---|---|---|---|
| LR-102.2.a | D. Md. L.R. 102.2.a | "The case caption on all court documents shall contain only a short title, consisting of the names of the first plaintiff and the first defendant only, and the civil action number." | `typst/layout.yaml` `front` (the caption); the typst template refuses more than two parties |
| LR-102.2.b | D. Md. L.R. 102.2.b | 8½ × 11 inch paper, one-inch margin on all sides; lines double-spaced except quotations and footnotes; "Pages shall be numbered at the bottom of every page after the first page"; at least 12-point text and 10-point footnotes "in Times New Roman or larger typeface." | the base's letter page, one-inch margins and 12 pt; `typst/layout.yaml`: `pitch.body` 27.6 (2 x the 13.8 pt single line), `page_number.from: 2`, `footnote.size` 10; `font-family` Times New Roman (Known gaps 1) |
| LR-102.1.b.i | D. Md. L.R. 102.1.b.i | "At the bottom of all court documents, counsel … shall state their name, address, telephone number, email and fax number. Counsel shall also state their bar number." | `typst/layout.yaml` `closing` (the typst template refuses a missing field; the fax value is printed as given, so "None" is a valid entry) |
| LR-102.1.c | D. Md. L.R. 102.1.c | "all court documents other than the original complaint must bear a signed certificate … If a document is filed electronically, the notice of electronic filing constitutes a certificate of service." | `closing`, `when: certificate` (optional; the sample carries one because the exemplar has one) |
| LR-105.1 | D. Md. L.R. 105.1 | "Any motion and opposition to a motion shall be filed with the Clerk and be accompanied by a memorandum setting forth the reasoning and authorities in support of it and a proposed order." | This doc type is the memorandum; the motion, the proposed order and the notice are separate filings (not produced) |
| LR-105.3 | D. Md. L.R. 105.3 | "memoranda in support of a motion … shall not exceed thirty (30) pages … exclusive of … tables of contents and citations" | `eval.yaml` `params.page_limit` 15 (DEF-LEN-001, every engine): the stricter LR 105.4 bound, below the 30 pages, since the base sets no table of contents (Known gaps 7) |
| LR-105.4 | D. Md. L.R. 105.4 | "A table of contents shall be included in any memorandum or brief exceeding fifteen (15) pages in length." | Not built on the FRCP base (Known gaps 7); a render over 15 pages fails DEF-LEN-001 in every engine |
| FRCP 8(a) | Fed. R. Civ. P. 8(a) | A pleading must contain "a short and plain statement of the grounds for the court's jurisdiction…". | Not template content (the memorandum does not plead) |
| FRCP 12(b) | Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be raised by motion. | Author content: the title, the introduction and the argument |

Not produced by this template: the motion itself (LR 105.1), the proposed order (LR 105.1), any exhibits (LR 105.5, tabbed when more than five), and the Certificate of Conference where one is required (LR 104.7, discovery motions). Not checked: judge's standing orders.

## Layout

- No separate cover page: the caption, the title and the opening paragraph share page 1, as in the exemplar. The court title (two lines, centered), then the short caption: the first plaintiff and the first defendant on the left with a vertical rule on the right; "Case No. …" on the right.
- The title is centered and bold, as the sample types it (capitals in the sample).
- Body: double-spaced; each paragraph has a 0.5 in first-line indent. Headings: level 1 centered bold capitals (INTRODUCTION, LAW, ARGUMENT, CONCLUSION, CERTIFICATE OF SERVICE); level 2 bold with a hanging indent (A., B., …); level 3 bold italic. Footnotes are 10 pt, separated by a rule.
- Numbered lists (`1.`) are numbered 1, 2, … with a hanging indent.
- Signature block after the conclusion: "/s/", the signer's name, the bar number, firm, address, telephone, facsimile, email and the role, all single-spaced in the right half of the page. "Dated:" is printed on the left only when `date` is given.
- Certificate of service after the signature block (when `certificate:` is set), with the same signature style.
- Page numbers: bottom center from physical page 2. No table of contents (Known gaps 7).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `caption.parties` (exactly two `{names, designation}`), `brief_title`, `signature` (`name`, `bar`, `firm`, `address`, `phone`, `fax`, `email`, `role`), `date` (optional), `certificate` (optional: `text`, `signer`).
- Body: markdown. `#` is level 1 (centered caps), `##` level 2, `###` level 3. Footnotes are `[^n]` with a `[^n]:` definition. Citations are written by the author; the template does not check them.
- Not supported: tables, raw typst. Lettered conclusion items (A., B.) are typed in the text: the template does not letter them.

## Overlay

`usage/OVERLAY-hylton-motion-brief.pdf` (measured on the earlier 11-page Liberation Serif render, before fb-595.68): red = our render, blue = the filed exemplar, black = both. Pages pair one-to-one here (ours p.n with filed p.n, 38-89% word overlap), because the sample is the whole memorandum. The visible differences are the page-1 page number (the exemplar prints "1"; LR-102.2.b does not), the signature block (the exemplar's "/S/" line and its missing fax line),. The page breaks differ from the exemplar, because the template's spacing is set from the rule rather than from the exemplar. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Font and size (LR-102.2.b).** Same as the complaint folder: Times New Roman itself, the face the rule names, at 12 pt, footnotes 10 pt (fb-595.68.18); 27.6 pt double pitch and 13.8 pt single lines set directly. The render is 12 pages. History: a 13 pt EB Garamond stand-in, then Liberation Serif at 12 pt (pitch re-measured at 27.6 pt, single 13.9 pt; 11 pages), then Times New Roman.
2. **Fax number (LR-102.1.b.i).** The filed signature block has no fax line. The rule asks for one. The sample states "None" so the template's required field is filled; the exemplar itself does not comply on this point, and the README records it rather than inventing a number.
3. **Page 1 number.** The exemplar prints "1" on page 1. LR-102.2.b says pages are numbered "after the first page"; the template follows the rule and leaves page 1 unnumbered.
4. **Footnote 3.** The exemplar's footnote 3 marker appears in the text layer with no footnote text, so the sample does not transcribe it.
5. **Italics.** The text layer has no italic markup. The sample italicises case names and signals (Bluebook style) as the transcriber's choice; the filed document was not checked for italics.
6. **Certificate of service.** The rule does not require one for an electronically filed paper (the notice of electronic filing is the certificate). The template prints one when `certificate:` is set; the sample carries the exemplar's certificate.
7. **Table of contents (LR 105.4): not built (missing base feature).** The FRCP base sets a table of contents only before the body's first page (`contents`, with a `cover`); D. Md. puts the caption and the text on page 1, and a contents page the frontmatter switches (`contents.when`) still leaves the cover's page break when it is off. The base needs a contents page that a frontmatter field switches together with the cover. Until then `eval.yaml` holds the render to 15 pages (DEF-LEN-001, every engine), the length that needs no table; the old typst-only TOC path is gone with the per-folder code.
7a. **Table of authorities.** Not required by D. Md. L.R. 105.4 (which asks for a table of contents only); not produced.
8. **One exemplar only.** EVAL-LOOP tier 2 asks for two or three filers. Candidates not saved (Carroll v. Mayor and City Council of Baltimore, 14 pages, and Bland v. Clearone Advantage LLC, 16 pages) are in `usage/SOURCE.md`.
9. **Gates.** `tools/check.sh` runs on this folder for typst, latex and docx (see Engines).10. **Ragged right.** Body text is left-aligned. The exemplar's justification cannot be read from the text layer; a convention, not a rule.
11. **Signature line.** The template prints "/s/" where the exemplar prints "/S/" (case only).
12. **Sample typo (open).** The CONCLUSION in `usage/INPUT-motion-brief.md` (line 124) reads "Educaiton", so the render prints it. It is the sample's transcription, not a template rule, and was left for the transcriber to fix against the filed exemplar.

## Review of the rendered pages (Gate 2 record; all 11 pages at 60 dpi, on the earlier Liberation Serif render, before fb-595.68)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, short caption (HYLTON v. SOMERSET COUNTY BOARD OF EDUCATION, ET. AL.), case number, title, opening paragraph | OK. No page number (LR-102.2.b). |
| 2 | INTRODUCTION, A. Procedural Background, B. (start) | OK. Number "2" at the foot. |
| 3 | Introduction, B. (continued) | OK. |
| 4 | LAW heading and paragraphs; ARGUMENT heading; A. (heading wraps with hanging indent) | OK. |
| 5 | Argument A (§ 1983); footnote 1 at foot of page (10 pt) | OK. |
| 6 | Argument A (Maryland boards as state agencies, continued), Count I conclusion | OK. |
| 7 | Argument B (heading wraps, hanging indent); defamation standard | OK. |
| 8 | Lankford statements (numbered list 1-3); footnote 2 at foot | OK. |
| 9 | Opinion discussion (Oliveres, Hughley); Hernandez paragraph; start of the third allegation | OK. |
| 10 | Third allegation (continued); new defendants; end of Argument B | OK. |
| 11 | CONCLUSION (A., B.), signature block (right half), CERTIFICATE OF SERVICE with signature line | OK. Transcription typo in the sample text, not the template: "Educaiton" (see Known gaps 12). |

Reviewed pages: 11 of 11 of the earlier Liberation Serif render (rendered at 70 dpi, viewed as 2×2 montages; the montages are in `/work/artifacts/review`, outside the repo).

## Gate 2 review on the FRCP base (2026-10-29, typst, latex and docx)

Every page of the three renders was reviewed as text layout (`pdftotext -layout`, page by page) with the checks' geometry (DEF-COVER-002 against the exemplar's page 1, XENG-001..003: 264 of 264 lines identical in latex and docx); the pod that did the move could not open images, so a visual look at the pages is left to the PM.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, short caption ruled at its right (designation an inch in, "v." half an inch in, as the exemplar), case number, title, opening paragraph | OK; no page number (LR 102.2.b). DEF-COVER-002 passes. |
| 2-3 | INTRODUCTION, A. and B. | OK |
| 4-8 | LAW, ARGUMENT A. (footnote 1 at 10 pt), B., the numbered list, footnote 2 | OK |
| 9-10 | Opinion discussion, third allegation | OK |
| 11 | End of argument, CONCLUSION (A., B.), the signature block in the right half | OK; the last paragraph kept with the signature. |
| 12 | CERTIFICATE OF SERVICE (kept whole on its own) | OK |

OPEN (tier 3): the title is no longer set in capitals by the template (the sample types it so; `upper` turned "12(b)" into "12(B)").

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.9): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays what D. Md. sets itself, each with its rule: the court's name, the 27.6 pt double pitch, page numbers from page 2 and 10 pt footnotes (L.R. 102.2.b), the short caption (102.2.a), the counsel block (102.1.b.i) and the certificate of service (102.1.c). `typst/mdd-motion-brief.typ` names the face and asserts the rules the layout cannot (two parties, the counsel fields). `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them); the per-folder typst code and the docx filter are removed. The page limit is `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine).

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none (the table of contents is missing in every engine: Known gaps 7) |
