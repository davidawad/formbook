# arwb: motion brief

Doc type: **motion brief** (a brief or memorandum in support of a motion, under Fed. R. Bankr. P. 9013) in the United States Bankruptcy Court for the Western District of Arkansas (`arwb`). Folder: `courts/eighth-circuit/arkansas/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole brief (pages 1 to 8 of the exemplar, caption through certificate of service); the exhibits (pages 9 to 59) are not transcribed |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 9 pages (8 on the earlier EB Garamond render), typst 0.15.0, Times New Roman (pinned; vendored Liberation Serif fallback), no system fonts, no warnings |
| overlay | ok: `usage/OVERLAY-lowry-stay-brief.pdf` and `usage/OVERLAY-lowry-stay-brief.txt` |
| pages reviewed | 8 of 8, on the earlier EB Garamond render (every page rendered at 60 dpi and viewed after the last template change; word-overlap scan clean on the final render) |
| typeface | face required: **none** found (the FRBP and the W.D./E.D. Ark. local rules and ECF procedures retrieved on 2026-10-14 name no face, size or font; see gap 3). Font: **Times New Roman** 13 pt, the house standard (`docs/FONTS.md`, rule 6) and the exemplar's face. Metric-compatible: n/a. Re-checked 2026-10-14, on the earlier EB Garamond render: render ok, `pdffonts` showed `EBGaramond-Regular`, `-Bold` and `-Italic` embedded, 8 pages, all 8 pages viewed. |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` by default; see the note in `../adversary-complaint/README.md`.

## Governing rules

| ID | Rule | Requirement | Verified | Where it lives |
|---|---|---|---|---|
| MOT-REQ-001 | Fed. R. Bankr. P. 9013(a) | "A request for an order must be made by written motion unless: (1) an application is authorized by these rules; or (2) the request is made during a hearing." | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_9013 | the brief supports a written motion; the motion itself is a separate filing (docket 115 in the exemplar's case) |
| MOT-REQ-002 | Fed. R. Bankr. P. 9013(b) | "A motion must state its grounds with particularity and set forth the relief or order requested." | 2026-10-14, same URL | the author's text (sections I to IV); the template does not check it |
| MOT-CAP-001 | Fed. R. Bankr. P. 9004(b) | A document presented for filing must contain a caption that sets forth (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, the adversary-proceeding number, and (4) a brief designation of the document's character. | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-title()`, `caption()` (debtor, case number, chapter), `brief_title` |
| MOT-FORM-001 | Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." | 2026-10-14, same URL | the body type size (13 pt) and double spacing |
| MOT-LOCAL-001 | W.D. Ark. Local Bankruptcy Rules (joint with E.D. Ark.) | The brief-form rule (the bankruptcy local rule on motions and memoranda) could not be retrieved; see gap 1. Rule 1001-1 (from a search result): matters not covered by the local rules are governed by the Federal Rules of Bankruptcy Procedure. | not retrieved | Not enforced; see gap 1 |
| MOT-TIME-001 | Fed. R. Bankr. P. 4001(a)(3) | Fourteen-day stay of an order granting relief from stay. Cited in the exemplar's conclusion; not re-read this session. | not checked | author's text only |

## Layout (what the template produces)

- Court title: two bold centred lines, capitals (the court's name and the division), as the exemplar has them.
- Caption: on the left, `IN RE:` and the debtor's name with the designation `DEBTOR`; on the right, `Case No:` and the chapter (Rule 9004(b)(3)).
- Title of the paper: bold capitals, centred (`brief_title`; the designation required by 9004(b)(4)).
- Opening paragraph (`lead_in`), unnumbered, in the form of the exemplar's "COMES NOW ...".
- Body: double spaced (24 pt baseline pitch at 13 pt), 1 inch margins, US Letter, page numbers centred at the foot, arabic from page 1 (the exemplar's form; there is no table of contents or table of authorities, see gap 2).
- Headings: numbered by the template from the heading level (`##` gives I., II.; `###` gives A., B.; `####` gives 1., 2.; `#####` gives a., b.). The author does not type the numbers. Headings are bold capitals at the margin with the text after a half-inch tab, and stay with the paragraph after them.
- Lists: a markdown list is lettered (1), (2), ... and hangs from its label. The exemplar's factor lists (1) to (12) are rendered this way.
- Signature block: "Respectfully submitted," then one single-spaced block for the signer (`signature`), set at 3.25 inches from the left margin.
- Certificate of service: centred bold heading; the text (`certificate_of_service.text`), the recipients (a single-spaced list, indented), and the signer's block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (list of lines), `case_number`, `chapter`, `caption.debtor` (`names`, `designation`), `brief_title`, `lead_in` (optional), `signature` (a flat list of lines), `certificate_of_service` (`date`, `text`, `recipients`, `signer`; optional).
- Body: blank-line-separated chunks. `##`, `###`, `####`, `#####` headings (numbers typed by the template); a list chunk (one item per line, `1.`); any other chunk is an unnumbered paragraph with a first-line indent.
- Italics with `*...*` (case names, `Id.`, signals). Markdown escapes are needed for a literal `#` (as in a bar number: `\#2007-076`).
- YAML values that end in a colon must be a folded block (`>-`); see `lead_in` and `certificate_of_service.text`.
- Not supported: tables, footnotes, raw typst, the table of contents or authorities (not generated).

## Overlay (what it shows)

`usage/OVERLAY-lowry-stay-brief.pdf`: red is our render, blue is the filed exemplar, black is both. The page map (`usage/OVERLAY-lowry-stay-brief.txt`) pairs each of our pages with the filed page sharing the most words: ours 1 to 8 with filed 1 to 8, in order. The sample is the brief itself, so the pairing is one to one. The overlay is a diagnostic, not a score: the exemplar is set in Times New Roman with an ECF header, and our render was then EB Garamond (measured before fb-595.68), with no header, so the two layers will not coincide on text lines. The page-level word overlap (51 to 95 per cent) follows the text, not the layout.

## Known gaps and open choices

1. **W.D. Ark. local rule on motion briefs (open question for David).** The bankruptcy local rule on motions, memoranda and briefs (the form, length and format of a brief) was not retrievable from this box. The court's site (arwb.uscourts.gov, arb.uscourts.gov) returned 404 or a WAF rejection for the rule PDFs guessed, and the courtrules.net index is behind a Cloudflare challenge. A search for the local rule text returned only other districts' rules. The template follows FRBP 9004 and 9013 and the filed exemplar. If the local rules set a page limit, a font or a size, or require a table of contents or authorities, that must be checked against the local text before this doc type is called complete.
2. **Table of contents and authorities.** Not generated. The exemplar (8 pages of brief) has neither. The local rule that would require them (if any) is the one in gap 1.
3. **Font.** Times New Roman at 13 pt. No rule read names a typeface, so the house standard applies (`docs/FONTS.md`, rule 6); the exemplar is Times New Roman too. The template was EB Garamond before, which sets narrower than Times, so 13 pt was chosen then to match the exemplar's line length; the template keeps 13 pt.
4. **Exhibits and the state-court attachments.** Pages 9 to 59 of the exemplar (the attached state-court documents) are not transcribed. The brief is complete in the sample; the attachments are not part of it.
5. **Notice of motion and hearing.** The template produces no notice of motion, no hearing notice and no objection-deadline paragraph. The exemplar, a brief, has none; a motion filed with it does. Whether the local rules require a notice with the brief is part of gap 1.
6. **Filer's spelling kept.** The exemplar has typos, and the sample transcribes them as filed: the title reads "BRIEF IN SUPPPORT OF" (three Ps), the body says "Lowery Farms" for the debtor's name, "State Cour Case" for "State Court Case", and "purse" for "pursue". The sample is a transcription, not a template, so these stay; a filing would correct them.
7. **Other candidates not saved.** Bojie (Rocket Mortgage LLC, 5:25-bk-72221, docket 34) and Schwarz (Arvest Bank, 6:25-bk-71974, docket 8) are motions for relief from stay without a memorandum; Veg Liquidation (5:13-bk-73597, docket 957) is a post-trial brief from 2014. They are recorded in `usage/SOURCE.md`. Tier 2 (2 or 3 filers) is therefore **not** judged yet; the brief asks for one exemplar per doc type.
8. **No check scripts run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. The render and overlay were run; the page review below is the Gate 2 equivalent for this doc type.
9. **Signature and certificate.** The `/s/` signature and the certificate's date are as filed. The template does not check that the certificate's recipients match the docket.

## Review of the rendered pages (the EB Garamond PDF of that review, 8 pages)

Every page was rendered at 60 dpi (`pdftoppm -r 60`) and viewed after the last template change. A bounding-box scan (`pdftotext -bbox`) found no overlapping words on the final render.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (IN RE: LOWRY FARMS, INC., DEBTOR; Case No., Chapter), title, COMES NOW paragraph, Section I (Introduction), first paragraph | OK. Headings are bold, numbered I. at the margin. The two-line title wraps "STAY" to a second line, as the exemplar does. |
| 2 | Section I (end), Section II (Facts) | OK. |
| 3 | Section III (Analysis), factor list (1) to (7) | OK. Hanging labels align. |
| 4 | Factor list (8) to (12), the citation paragraph, the facts list (1) | OK. Italic case names and *Id.*. |
| 5 | Facts list (2) to (7) | OK. The factor list items are double spaced, as the exemplar's are. |
| 6 | Facts list (8) to (12), the "It is necessary" paragraph starts page 7 | OK. |
| 7 | Conclusion (IV), signature block | OK. The signature block is single spaced at 3.25 inches. |
| 8 | Certificate of service: heading, text, recipients, signer | OK after the fix: the recipients are one single-spaced list (they overlapped before), and the bar number reads "#2007-076" (a typst `#` had truncated it to "Bar"). |

Gate 2 rows: pages 1 to 8 pass for layout. Tier-2 findings (conventions a clerk expects): the font and line length (gap 3), the local rule on briefs (gap 1), and the table of contents question (gap 2). The filer's typos are transcribed, not corrected (gap 6).

## Engines

| Engine | Output | What matches the typst template | What differs |
|---|---|---|---|
| typst (primary) | `usage/OUTPUT-motion-brief.typst.pdf` | (the reference) | (the reference) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | US Letter; 1 in margins; Times New Roman 13 pt (embedded in the PDF); exact 24 pt double spacing; 0.5 in first-line indent; bold court title; caption as a borderless table (debtor left, case number and chapter right); bold capitals title; argument headings I., A., 1., a. with a hanging label; the factor lists (1), (2), ...; single-spaced signature block at 3.25 in; the certificate of service; a plain centred page number | measured on the earlier EB Garamond render (both engines are 9 pages now): 9 pages, typst 8: the conclusion keeps with the signature block (a signature is never alone at the top of a page), and the certificate of service stays together as one block, so the last page starts later; the text of a factor item starts at 1.0 in on every line (typst puts the first line's text at about 1.25 in); the gaps before the signature and the certificate are paragraph spacing |

docx: all 9 pages of `OUTPUT-motion-brief.docx.pdf` were rendered at 60 dpi and compared with the typst pages (side by side and as a grid). Gate result: no BLOCKED items. `tools/check.sh` was not run for the docx engine (no stamp; see the court README). Word was not available: open the `.docx` in Word once to confirm there is no repair prompt, and install Times New Roman on the reader's machine, or Word substitutes a font silently (`docs/DOCX.md`).

Source: `docx/reference.xml` holds the styles, and `fb render` builds the reference document from it (`base="xengine"`, the shared cross-engine recipe; `docx/build-reference.sh` did this until fb-595.68); `docx/arwb-motion-brief.lua` lays out the markdown contract. Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/eighth-circuit/arkansas/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/eighth-circuit/arkansas/federal/bankruptcy-western-district/motion-brief lowry-stay-brief
```

## Current shared-model adoption status (2026-10-22)

The DOCX engine uses `docx/reference.xml` and Lua filters with the shared cross-engine layout model. The Word face is resolved from this folder's typst template. The folder has no docx shell builder/render script or binary `reference.docx`; its entry is absent from `.shell-safety-baseline.json`. The current `sh tools/check.sh` runs for typst and docx both report zero failed checks. `DEF-COVER-001` and `DEF-TOC-001` pass; the sample has no contents or authorities table. No LaTeX engine is present in this folder.

The docx check passes XENG-001..003 on every input. Older DOCX notes in this README describe the pre-adoption shell-built engine and are superseded by this status.
