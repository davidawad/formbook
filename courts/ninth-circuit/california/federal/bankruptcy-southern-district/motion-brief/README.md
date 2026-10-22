# casb: motion (with points and authorities)

Doc type: **motion** (a written motion under FRBP 9013 with the memorandum of points and authorities combined in one filed document) in the United States Bankruptcy Court for the Southern District of California (`casb`).
Folder: `courts/ninth-circuit/california/federal/bankruptcy-southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the motion in full (caption, motion paragraph, POINTS AND AUTHORITIES with sections I and II, CONCLUSION, signature). 5 pages, the same length as the exemplar. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 5 pages, typst 0.15.0, vendored EB Garamond only, no warnings (the earlier EB Garamond render, before fb-595.68; the committed render is Times New Roman, 5 pages) |
| overlay | ok: `usage/OVERLAY-stika-alegria-motion-to-dismiss.pdf` and `.txt` (pages paired one to one; 34 to 95% word overlap, the last page is the signature alone) |
| pages reviewed | 5 of 5 (every page rendered at 60 dpi and viewed after the last template change; see the review table) |

The sample is the exemplar's length (5 pages), so the 8-to-14-page target does not apply: the transcription is complete, and nothing has been padded.

## Governing rules

Primary and secondary sources, with how each was checked. The casb local rules are not reachable from this box (casb.uscourts.gov and courtrules.net return 403 to the fetcher), so local-rule text is taken from a secondary source and is marked as such.

| ID | Rule | Requirement | How it was checked | Where it lives |
|---|---|---|---|---|
| CASB-MOT-001 | Fed. R. Bankr. P. 9013(b) | "A motion must state its grounds with particularity and set forth the relief or order requested." | Fetched from https://www.law.cornell.edu/rules/frbp/rule_9013 on 2026-10-14. The template does not check the content; the author writes the grounds and relief. | body (author text); the motion paragraph in the sample |
| CASB-MOT-002 | LBR 9013-7(d)(1) (S.D. Cal.) | A brief or memorandum supporting a pending motion must not exceed 25 pages; a reply memorandum must not exceed 10 pages. | Secondary: the Practical Law note "Local Bankruptcy Rules: California (S.D. Cal.)" (2021), hosted at https://www.foley.com/wp-content/uploads/imported/0f7995fa1f064f049f1ba48fe094d4d2.pdf, and a courtrules.net search excerpt. Primary text not fetched. | not enforced (no page counter); author responsibility |
| CASB-MOT-003 | LBR 9013-7(d)(3) (S.D. Cal.) | A memorandum longer than 10 pages must include a table of contents and a table of cited authorities (neither counts toward the limit). | Same secondary sources. | `with-toc` (frontmatter `toc: true`) produces the TOC and TOA; see Layout |
| CASB-FORM-001 | S.D. Cal. Admin. Proc. 2.3(a), 2.4, 2.5 (via the same note) | Caption detail: a hearing date, time and judge two lines below the case number when the paper is to be heard; pagination at the bottom of each page; quotations single-spaced and indented 5 to 20 spaces. | Same secondary note, pages 45 to 47. Primary not fetched. | caption (`hearing`, optional); footer; block quotations (`motion-body()`) |
| CASB-FORM-002 | S.D. Cal. Admin. Proc. (line spacing, same note) | Double-spaced, except the counsel block, title of the action, category headings, footnotes, quotations, exhibits and real-property descriptions. | Same note. The font size is not stated in the note. | body at 24 pt pitch; counsel, caption, TOC and TOA single-spaced |
| CASB-FORM-004 | Fed. R. Bankr. P. 9004(a), (b) | Legible; caption with the court, title, case number and adversary number, and a brief designation of the paper. | Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14 (subdivision (a) quoted; (b) summarized). | caption; footer |
| CASB-FORM-003 | Convention (both casb exemplars) | Pleading paper: 28 numbered lines, double rules, footer under the lines. | Read from the text layer of the exemplar (line numbers 1 to 28 on each of the five pages). Not a rule text; a tier-2 convention. | `line-numbers()`, `pleading-rules()`, `lines-per-page = 28` |

Not verified against primary text, so not asserted as a rule: the font (Times New Roman is used, the house standard of docs/FONTS.md rule 6), the 12-point size (the CAND templates use it; no casb rule text was read), and the hearing-line placement beyond the secondary note.

## Layout

- Counsel block from line 1 (single-spaced); the court title follows.
- Caption: a left column with "In re" and the debtor, then the adversary parties with "vs."; a right column with the case number, chapter, adversary number, the title, a hearing (if the frontmatter gives one), and the judge. The left column is closed by a rule on the right and bottom.
- The "TO:" line (`lead_in`) follows the caption on the same page. The body follows it; no page break after the cover unless `toc: true`.
- Every block sits on whole numbered lines (`on-grid`), so paragraphs, headings and the signature block land on the grid. Paragraph gaps come from the grid, not from `par.spacing`, which is 0 (the body is rendered chunk by chunk).
- Headings: level 1 centered bold caps (POINTS AND AUTHORITIES, CONCLUSION); level 2 is numbered "I.", "II." with a hanging indent; level 3 is "A.", bold. The sample types no numbers; the template numbers them.
- Block quotations are single-spaced and indented half an inch each side.
- `toc: true` in frontmatter adds a table of contents (generated from the headings) and a table of authorities (generated from `toa:KEY` links and the `authorities:` registry), on roman-numbered pages, with the body restarting at page 1. With `toc: false` (the sample), neither is produced.
- The footer is three centered lines: page number, the short title (`footer_title`), and the case number.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `adv_number`, `chapter`, `brief_title`, `footer_title`, `counsel` (lines), `in_re` (list of `{names, designation}`), `caption` (list of `{names, designation}`; "vs." is inserted between sides), `lead_in` (optional), `hearing` (optional list of lines), `judge` (optional), `toc` (true/false), `authorities` (required when `toc: true`: a map of KEY to `{kind, name, cite}`; `kind` is `case`, `statute`, `rule`, `regulation` or `other`), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks: `#` / `##` / `###` headings; `>` block quotations; paragraphs. Authority links are `[text](toa:KEY)`.
- Do not number headings or paragraphs in the text; the template does it.

## Overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, jq, gawk (micromamba env at ~/tb)
sh tools/render.sh courts/ninth-circuit/california/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/bankruptcy-southern-district/motion-brief stika-alegria-motion-to-dismiss
```

Pages pair one to one (ours 1 to 5 with filed 1 to 5). Red is our render, blue is the exemplar; the two will not coincide on text lines. The overlay is a diagnostic, not a score.

File names: `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` / `.txt`, as the tools write them by default.

The TOC and TOA branch (`toc: true`) is not exercised by the committed sample (the exemplar has none). It was tested on a temporary copy with two authority links: the TOC lists the two headings with page numbers and dot leaders, the TOA groups the cases and rules and gives the page, and the body restarts at page 1 after the roman pages. The temporary copy was deleted.

## Review of the rendered pages (Gate 2 record)

Every page rendered at 60 dpi and looked at (on the earlier EB Garamond render, before fb-595.68).

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel, court title, caption, title, the "TO:" line, the motion paragraph | OK after the fix below. Paragraphs had been overlapping at their boundaries and the "POINTS AND AUTHORITIES" heading had been drawn over the text above it; fixed by rendering each paragraph and heading in its own whole-line block. The heading "POINTS AND AUTHORITIES" with section I moves to page 2 with its text (the sticky heading does not fit at the foot of page 1), leaving lines 23 to 28 blank. |
| 2 | POINTS AND AUTHORITIES, section I (headings and paragraphs to the Harsco cite) | OK. Section heading hangs with its label "I."; the paragraph after it starts on the next line. |
| 3 | Continuation of section I: Shields, Di Vittorio, Bly-Magee block quotation | OK. The block quotation is single-spaced and indented; the attribution line sits under it. |
| 4 | Section II (heading, paragraphs, Kawaauhau quotation), CONCLUSION | OK. |
| 5 | Last paragraph of CONCLUSION, date, "Respectfully submitted," firm, "/s/ BENJAMIN HESTON", "Attorney for Defendant" | OK after removing the duplicate signer line (the template printed the name twice). |

## Known gaps and open choices

1. **One filer only.** The brief asks for one exemplar per doc type; EVAL-LOOP tier 2 asks for two or three filers. The casb motion search (CourtListener search API, 2026-10-14) returned Medina v. National Collegiate Student Loan Trust (19-90065, Docs 50 and 52 have PDFs) but the docket page and storage paths were blocked (403), so those could not be fetched; Doc 7 of Stika v. Alegria is the only text-based casb motion-with-memorandum fetched.
2. **Local rules not verified.** LBR 9013-7 and the casb administrative procedures are cited through a 2021 practice note and a search excerpt; the primary text was not reachable (403). A reviewer with the current rules should check the caption and the TOC/TOA trigger (more than 10 pages).
3. **Page limit not enforced.** The template does not count pages (25-page limit, LBR 9013-7(d)(1)).
4. **Notice of motion not in the sample.** The Stika motion has no separate notice of hearing (the exemplar is the motion itself). A notice of motion with a hearing date and time, if the court requires one for this motion, is a separate filing; the template's `hearing` field supports it.
5. **Font.** Times New Roman at 12 pt (the pinned install, Liberation Serif fallback; docs/FONTS.md rule 6). A font choice, not a rule.
6. **Case names are roman.** The text layer has no italic markup; the template italicizes `*...*` if a sample carries it (not used).
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render, overlay and page review were run instead.

## Engines

**docx** (`docx/`): `sh tools/render.sh --engine docx courts/ninth-circuit/california/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice PDF, 5 pages, Times New Roman embedded). `fb render --engine docx` builds it: the reference document from `docx/reference.xml` (the shared cross-engine recipe, `base="xengine"`, in the typst face), then pandoc with `docx/casb-motion-brief.lua` (and `docx/lib/lines.lua`), which writes the page, the footer from the frontmatter and the line numbers (`FORMBOOK_FINAL`, `FORMBOOK_FOOTERS`).

- Matches the typst output in the mandated form: Times New Roman 12 pt, 24 pt line pitch, 28 line numbers on the grid, pleading rules, the three-line footer, the counsel block, the caption, first-line indents, headings numbered I., A. as in the typst template, the signature block.
- Differs: (1) the numbers and rules are built as in the adversary folder (framed header, page borders). (2) A single-spaced block quotation has no grid rounding (typst rounds it to whole numbered lines); the text after a quotation can sit half a line off the numbers (seen on page 4). (3) The heading chain (POINTS AND AUTHORITIES, then the first heading, then its paragraph) moves to page 2 as a unit, leaving lines 22 to 28 of page 1 blank, as in typst. Checked with LibreOffice only.
- `toc: true` is not built by this engine: the filter stops with an error. BLOCKED: TOC and TOA checks (no table of contents or authorities is produced; the sample has `toc: false`).
- No typst `OUTPUT-motion-brief.typst.pdf` exists in `usage/` in this snapshot, so there is no typst page to compare against.
- BLOCKED: `tools/check.sh <this folder> --engine docx` exits 2 (`court.json` and `checks.yaml` are missing from this doc-type folder; not created). No gate result is claimed. Gate 0 checked by hand for word presence only (every body word is in the PDF text).
