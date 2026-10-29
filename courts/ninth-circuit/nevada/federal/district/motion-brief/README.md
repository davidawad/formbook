# nvd: motion to dismiss with memorandum (motion-brief)

Doc type: **motion** under Fed. R. Civ. P. 12(b)(6), with its memorandum of points and authorities, combined in one filed document, in the United States District Court for the District of Nevada (`nvd`).
Folder: `courts/ninth-circuit/nevada/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer, see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole 11-page motion: motion, memorandum, conclusion, signature, certificate of service) |
| typeface | face required: **none** (LR IA 10-1(a)(3) sets size only: "Text must be size 12 font or larger"). Template face: **Times New Roman** 12 pt, the house face (docs/FONTS.md) and the filed exemplar's face and size; was 13 pt for EB Garamond. Embedded: Times New Roman Regular, Bold, Italic (`pdffonts`), the same faces in the typst and docx PDFs. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 11 pages each (typst 0.15.0, pdfLaTeX, LibreOffice), vendored fonts only, no warnings (re-rendered 2026-10-29 on the shared document model, fb-595.96) |
| overlay | ok: `usage/OVERLAY-lynch-motion-to-dismiss.pdf` and `.txt` (pairing by word overlap; see below; re-run 2026-10-15) |
| pages reviewed | 11 of 11 on each engine rendered to PNG at 60 dpi (33 images, `.overlay/`); read by their text layout and line geometry (2026-10-29: the image viewer of the agent pod could not open them; see Visual review) |
| BLOCKED | none. Tier-2 coverage is short of the eval loop's "two or three filers" (see Known gaps 1). |

## Governing rules

Primary source for the local rules: **D. Nev. Local Rules of Practice** (amended 2020; PDF modified 2025-07-30), https://www.nvd.uscourts.gov/wp-content/uploads/2020/04/Local-Rules-of-Practice-Amended-2020.pdf, fetched and read 2026-10-14. The courtrules.net mirror was not used: its text was out of date for LR 7-3 (it gives 30 pages; the court's PDF gives 24 pages for motions other than summary judgment).

Federal rules: Fed. R. Civ. P. 12(b) (LII text, https://www.law.cornell.edu/rules/frcp/rule_12, no "current through" date on the page), fetched 2026-10-14. Fed. R. Civ. P. 5(d)(1)(B) (https://www.law.cornell.edu/rules/frcp/rule_5), fetched 2026-10-14, for the certificate of service.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NVD-MOT-001 | LR 7-2(a) | A motion must be supported by a memorandum of points and authorities; "The motion and supporting memorandum of points and authorities must be combined into a single document that complies with the page limits in LR 7-3." | One document: the body (motion, then memorandum) in one flow after `front` (typst/layout.yaml) |
| NVD-MOT-002 | LR 7-3(b) | Motions other than summary judgment: 24 pages, excluding exhibits. | `eval.yaml` params.page_limit: 24 (checked); the sample is 11 pages |
| NVD-MOT-003 | LR 7-2(d) | Failure to file points and authorities in opposition constitutes consent. | Not a template matter; recorded for the author |
| NVD-FORM-001 | LR IA 10-1(a)(1) | Double-spaced lines of text; lines numbered consecutively from 1 on the left margin of each page, no more than 28 per page. The caption, the court title, the case name and quotations are exempt from double spacing. | layout.yaml `pleading.lines: 28`, `pitch.body: 23` (the shared model draws the numbers, fb-595.96) |
| NVD-FORM-002 | LR IA 10-1(a)(2) | Legible, one side of each page. | PDF output is one-sided |
| NVD-FORM-003 | LR IA 10-1(a)(3) | Text 12 point or larger. | `size: 12` (the FRCP base), footer 12 pt |
| NVD-FORM-004 | LR IA 10-1(a)(4) | Quotations over 50 words indented and single spaced. | layout.yaml `quote`: single spaced (13.8 pt), 0.5 in in on both sides |
| NVD-FORM-005 | LR IA 10-1(a)(5) | All pages numbered consecutively. | the base's `page_number`: a plain number, centered |
| NVD-FORM-006 | LR IA 10-1(a)(6) | Margins at least one inch on all four sides. | layout.yaml `margin` (1 in top, bottom and right, 1.5 in left); `pitch.body: 23` fits the 28 lines between them (Known gaps 3) |
| NVD-FORM-007 | LR IA 10-1(c) | 8½ × 11 inch paper (manual filing). | the base: letter paper |
| NVD-FIRST-001 | LR IA 10-2 | First page: attorney's name beginning at least one inch below the top; name, Nevada bar number, address, phone, email, party represented. | layout.yaml `front`: `{counsel}`, from the top margin |
| NVD-FIRST-002 | LR IA 10-2 | Court title "UNITED STATES DISTRICT COURT / DISTRICT OF NEVADA"; caption with parties at left and case number and document title at right. | layout.yaml `front`: `{xd.court}`, `{xd.district}` (constants), the caption columns |
| NVD-FILE-001 | LR 7.1-1 | Disclosure statement with the first appearance, pleading, petition, motion, response or other request. | Not generated: a separate filing. Defendant has appeared (its first filing was the Notice of Removal, ECF No. 1 in this case), so this is a question for the author, not the template. |
| NVD-FILE-002 | FRCP 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | The sample includes the certificate, as in the exemplar. layout.yaml `after_tail` sets it on its own page after the signature. |

Not produced by this template: the proposed order (LR 7-2(f) applies only if the court instructs one); declarations or exhibits; the index of exhibits.

## Layout

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`) with D. Nev.'s rules overlaid in `typst/layout.yaml`, set by the shared document model (`lib/typst/xdoc.typ`; `latex/` and `docx/` generated by `fb engines gen`, fb-595.96).

- Pleading paper (layout.yaml `pleading`): the numbers 1 to 28 down the left margin, right-aligned on 1.05 in, one per 23 pt numbered line from the top margin (28 x 23 pt = 644 pt between the 1 in margins); a double rule at 1.3 in and 1.34 in from the page's left edge and a single rule at 7.6 in, the page's full height. Page furniture: `eval.yaml` params.pleading_lines: 28 drops the numbers from the text the checks read.
- First page (`front`): counsel single-spaced from the top margin (an empty line a blank one); a blank numbered line; the court title (bold, a numbered line each); a blank numbered line; the caption (parties at left, each party's designation 1.2 in in, "vs." a single line from each, ruled at its right and foot; "Case No.:" and the title in bold at right); a blank numbered line; the motion on the same page (as in the exemplar).
- Memorandum: paragraphs double spaced (23 pt) with a 0.5 in first-line indent. Headings on the numbered lines, kept with what follows: level 1 centered bold caps; levels 2 and 3 bold, half an inch in, the layout's number (I., A.) in a half-inch box and the text hanging after it.
- Quotations: single spaced (13.8 pt lines), indented 0.5 in on both sides, 9.2 pt above and below; a numbered list in a quotation at the quotation's indents.
- Signature block, kept on one page with the last paragraph: "Dated this ...", a blank numbered line, then the firm, "By: /s/" the signer a single line below, and the signer's lines, at 2.6 in.
- Certificate of service (`after_tail`, from the frontmatter's `certificate`): its own page after the signature; the paragraph double spaced, the service list single spaced half an inch in, the employee signature at 2.6 in a numbered line below.

## Markdown contract (for samples)

- YAML frontmatter, then the body: paragraphs, `#` (the memorandum's title), `##` and `###` headings (the layout numbers them I., A.: do not type the labels), `>` quotations (a `1.` list inside one is a list), footnotes.
- Frontmatter: `case_number`, `counsel` (lines; an empty string gives a blank line), `caption` (`separator` optional, default "v."; `parties` as a list of `{names, designation}`), `brief_title`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate` (`paragraphs`, `recipients`, `signer`, `lines`; optional).
- A quotation that runs over several paragraphs and closes in a later one: write its closing mark curly (`”`), as pandoc reads a straight one there and typst does not.
- Escape a literal asterisk that is not emphasis as `\*` (the sample uses `\*3-4` and `\*17` for Westlaw/Lexis pin cites).

## Samples and overlay

```sh
D=courts/ninth-circuit/nevada/federal/district/motion-brief
for e in typst latex docx; do sh tools/render.sh --engine $e $D usage/INPUT-motion-brief.md; done
for e in typst latex docx; do sh tools/check.sh $D --engine $e; done
just overlay $D   # -> .overlay/<doc path>/OVERLAY-motion-brief.pdf and .txt (not committed)
```

## Visual review (Gate 2 record)

2026-10-29, after the move onto the shared model (fb-595.96): every page of the three renders (11 typst, 11 latex, 11 docx: 33 pages) rasterized at 60 dpi with pdftoppm into `.overlay/`. The agent's image viewer could not open the PNGs in its pod, so each page was read by its text layout (`pdftotext -layout`) and its line geometry (`fb measure`: the numbers' and the body lines' baselines, the rules); a look at the images themselves is left to the reviewer (PR). The three engines break every line and page alike (XENG-001..003 PASS, 302 of 302 lines).

| Page | What it is | Finding (all three engines) | Status |
|---|---|---|---|
| 1 | Counsel (single lines from the top margin, the blank line kept), court title on numbered lines 8 and 9, caption with "vs." (the long party name wraps "I-" / "X,"), "Case No.:" and the bold title at right; the motion's two paragraphs | Structure as filed. The exemplar's title column is wider (it runs to its right margin), so its title takes five lines and ours six; the exemplar rules a line above its page number (one filer's style, accepted in eval.yaml for DEF-COVER-002). | ACCEPTED (tier 3) |
| 2 | MEMORANDUM heading, I. INTRODUCTION with A. and B. (labels in half-inch boxes, text hanging), paragraphs | OK. | OK |
| 3 | II. heading (two lines), the 12(b) quotation (single spaced, 0.5 in in on both sides), the standard of review | OK. | OK |
| 4 | Standard of review continued; the Iqbal quotation; "Id. at 1950." | OK. | OK |
| 5 | III. A. heading, the NRS 38.310 quotation (items 1. and 2. as a list in the quotation), the NRS 116.31181 quotation with items (a) to (c) and its closing mark | OK. | OK |
| 6-9 | A. continued; B., C., D. headings and their paragraphs | OK. | OK |
| 10 | III. CONCLUSION, its paragraph, "Dated this ...", firm and signature block at 2.6 in | OK; the signature stays with the last paragraph. | OK |
| 11 | CERTIFICATE OF SERVICE on its own page: paragraph, service list at 0.5 in, employee signature at 2.6 in | OK. | OK |

Reviewed pages: 11 of 11 on each engine (33).

## Known gaps and open choices

1. **One filer only.** The eval loop asks for two or three exemplars from different filers before tier 2 is judged. Searches (CourtListener RECAP API, `type=r`, `court=nvd`, motions to dismiss filed 2025-06 to 2026-10): Advanced Solution v. New Horizon (2:26-cv-00958, 9 pp., Wiley Petersen), Logan v. Citizen's Bank (2:26-cv-00887, 9 pp., Malcolm Cisneros), Browning v. Station Casinos (2:26-cv-00603, 31 pp.) and Riskon v. Zest Labs (2:25-cv-02042, 33 pp.) were found; only the first two are short enough to compare. Both were downloaded and checked for a text layer, but not saved as exemplars or compared in full. Tier 2 is therefore **not** judged against a second filer yet.
2. **Type size.** The rule requires 12 pt or larger (LR IA 10-1(a)(3)). Body text is 12 pt Times New Roman, the exemplar's size; the 13 pt of the earlier template was chosen for EB Garamond and was dropped with that face.
3. **Line pitch.** The exemplar uses a 24 pt grid, so its 28th line sits at about 10.3 in, which breaches the one-inch bottom margin (LR IA 10-1(a)(6)). This template fits the 28 lines between the one-inch margins (pitch 23 pt, a whole number of twips so Word sets the same lines). **This departs from the exemplar's grid; David should confirm the reading.** The same choice is made in the complaint template.
4. **Filed errors kept as filed.** The exemplar cites "Fed. R. Civ. P. 12(b)(5)" in I.B (the motion relies on 12(b)(6)), says "that tenant 'is inapplicable'" (for "tenet"), . The sample keeps them so that the overlay matches the filing. The author should correct them before filing a version of their own.
5. **Case names italic.** Italics are applied to case names, *Id.*, and signals in the sample following standard citation form. The exemplar's text layer has no italic markup; the rendered page images show italics for case names in the exemplar. The italics in the sample are a transcription convention, not a check of every italic in the exemplar.
6. **Page limit (LR 7-3(b)).** 24 pages for this motion: `eval.yaml` params.page_limit checks it. The sample is 11 pages.
7. **Disclosure statement (LR 7.1-1).** Not generated; the defendant has already appeared in this action, so the statement is for the author to decide whether it is due with this filing.
8. **Judge standing orders** can change the form. Not reflected.
9. **Certificate language.** The exemplar's certificate cites NRCP 5(b) and NEFCR 9. Those rules are not in the D. Nev. Local Rules text reviewed; the sample reproduces the exemplar's text as filed and the template does not check the citation.
10. **Check scripts.** `tools/check.sh` runs on this folder on all three engines (typst, latex, docx; the stamps are in `usage/`).

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.96): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/nvd-motion-brief.typ` names the face (Times New Roman 12 pt) and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua`. The pleading paper is the model's `pleading` key: typst the page background, LaTeX a shipout hook of the generated template, Word a header of anchored shapes (the numbers in a text box, a line per rule). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`).

`sh tools/check.sh <dir>`: typst 11 passed, 0 failed; `--engine latex`: 15 passed, 0 failed; `--engine docx`: 16 passed, 0 failed; XENG-001..003 PASS on both (302 of 302 lines). Not verified in Word (LibreOffice only).

## FRCP base port

Moved onto the base with pleading paper (fb-595.96), replacing the folder's own typst template and docx filter (fb-595.17.13 had skipped it for want of pleading paper in the model).

[Parent: nevada/federal/district](../README.md)
