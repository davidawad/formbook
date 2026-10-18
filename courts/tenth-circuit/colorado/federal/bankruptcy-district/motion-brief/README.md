# cob: motion brief

Doc type: **motion with memorandum** (FRBP 9013) in the United States Bankruptcy Court for the District of Colorado (`cob`). Folder: `courts/tenth-circuit/colorado/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (adversary motion, Point Digital Finance's counsel, 15 pp.). A second filer is saved as `usage/FILED-EXAMPLE-motion-brief-2.pdf` (main-case ex parte motion, Receiver's counsel, 12 pp.), not transcribed. See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: full transcription of the 15-page filing (caption, motion, facts, argument I to VIII, conclusion, signature block, certificate of service). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-katzenberger-motion-brief.pdf` and `OVERLAY-katzenberger-motion-brief.txt` |
| pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the repo tools rather than the bare `<id>.pdf` in the brief: `render.sh` writes `OUTPUT-<id>.pdf` from `INPUT-<id>.md`, and `overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`.

## Governing rules

Rule text was read from the primary sources below. The Colorado **local** bankruptcy rules were **not** readable from this box (see "Not verified" below), so every local requirement the template could have encoded is listed as unverified rather than cited.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| COB-RULE-001 | Fed. R. Bankr. P. 9013(a) (Cornell LII, fetched 2026-10-14) | A request for an order must be made by written motion unless an application is authorized or the request is made during a hearing. | the document type itself |
| COB-RULE-002 | Fed. R. Bankr. P. 9013(b) (same) | A motion must state its grounds with particularity and set forth the relief or order requested; service under Rule 9006(d) on the trustee/debtor in possession and those entities the rules specify. | body (author-written); certificate of service |
| COB-RULE-003 | Fed. R. Bankr. P. 9004(a) (same) | A petition, pleading, schedule, or other document must be clearly legible. | Typst output (vendored font, no warnings) |
| COB-RULE-004 | Fed. R. Bankr. P. 9004(b) (same) | Caption: (1) court's name; (2) case title; (3) case number and, if appropriate, adversary-proceeding number; (4) brief designation of the document's character. | `court`, `debtor`, `adversary`, `title` in the frontmatter; `caption()` and `title-block()` |
| COB-RULE-005 | Fed. R. Bankr. P. 7010 (same) | In an adversary proceeding, Fed. R. Civ. P. 10 applies, except that a pleading's caption must substantially conform to the appropriate version of Official Form 416. | the adversary caption block (Form 416 is not reproduced verbatim; see gaps) |
| COB-FORM-002 | Proxy: D.C.COLO.LCivR 10.1 (district court, not the bankruptcy LBR), text from a third-party aggregator (courtrules.net, quoted via search 2026-10-14); the district text is "FORMAT OF PLEADINGS AND DOCUMENTS PRESENTED FOR FILING" with a 2005 general order as its source. | Typewritten documents: black ink, font at least 12 point, 8½ × 11 white paper, one side. | `type-size = 13pt`, `font-family = "EB Garamond"` |
| COB-FORM-003 | Proxy: same district rule | Double spacing for all documents. | `line-pitch = 24pt` |
| COB-FORM-004 | Proxy: same district rule | Top margin 1½ inches; left, right and bottom 1 inch. | `margin-top = 1.5in`, `margin-other = 1in` |

Not used, and why:

- **Counsel block upper left** (the CAND rule's 3-4(a)(1)): the exemplar has counsel in the signature block only, and no cited rule in this court's text was read that requires it. Not encoded.
- **Table of contents and table of authorities**: the exemplar has neither (15 pages). No rule was read that requires them for a bankruptcy motion. Not encoded (the CAND template has them).
- **Certificate of service**: the exemplar has one (CM/ECF service). Rendered from frontmatter `certificate`, after the signature block, as in the exemplar. Its requirement comes from the general service duty in FRBP 9013(b), not a cited form.
- **Signature block**: a convention matching the exemplar (Dated left, firm and signer right). Not a rule citation.
- **Notice of motion** with a response deadline: the exemplar contains none; D.C.COLO.LBR 9013-1 (motions practice, third-party text) is said to require a separate notice and proposed order. Not verified; not encoded.

## Not verified (the local rules)

- **D.C.COLO.LBR 9004-1** (form of papers) and **D.C.COLO.LBR 9013-1** (motions): the text could not be read. courtrules.net returned HTTP 403 for both the 9013-1 page and the court index; cob.uscourts.gov returned 404 for every local-rules URL tried (including the 2018 PDF listed in search results). A third-party snippet mentions a separate proposed order per motion and a 14-day response period; not checked against the court's PDF, not encoded.
- **Page limit** for bankruptcy motions: not verified; the 15-page exemplar is the only evidence.
- **Font and margins**: `COB-FORM-002` and `-004` are the district rule as a proxy. If the bankruptcy LBR sets different numbers, change the parameters in `typst/cob-motion-brief.typ` (the only numbers in the file) and re-render.

## Layout

- Page 1: court title (two lines, centered bold capitals), the debtor block ("IN RE:", case number, chapter) on the left and right, the adversary block (parties and "Adv. Proc. No.") below, then the title in centered bold capitals.
- Body: double-spaced, first-line indent ½ inch, headings numbered by the template (level 1 unnumbered centered caps, level 2 "I.", level 3 "A.", level 4 "1."), block quotations single-spaced and indented both sides, footnotes at 13 pt.
- Footer: centered page number, arabic from 1 (the caption page is page 1, as in the exemplar).
- After the body: signature block (Dated left; Respectfully submitted, firm, `/s/` and signer, bar number and address lines right), then the optional certificate of service.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `court` (list of lines), `debtor` (`names`, `case_number`, `chapter`), `adversary` (optional: `case_number`, `parties` as a list of `{names, designation}`), `title`, `date`, `signature` (`firm` list, `signer`, `lines`), `certificate` (optional: `text`, `date`, `signer`). Quote every `signature.lines` entry: an unquoted `#` or leading digit breaks the YAML parse (the first render failed on this).
- Body: `#` = centered bold capitals heading (unnumbered); `##` = numbered `I.` heading; `###` = numbered `A.` heading; `>` = block quotation; `[^1]` = footnote; `*…*` = italic.
- Not supported: tables, raw typst, TOC/TOA.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/tenth-circuit/colorado/federal/bankruptcy-district/motion-brief
sh tools/render.sh $D usage/INPUT-motion-brief.md
sh tools/overlay.sh $D katzenberger-motion-brief $D/usage/SAMPLE-katzenberger-26-01048-motion-brief.pdf
```

`overlay.sh` pairs pages by word overlap. Pairs (ours → filed): 1→1, 2→2, 3→3, 4→4, 5→5, 6→6, 7→8, 8→9, 9→10, 10→11, 11→12, 12→13, 13→14, 14→15. The overlay is a diagnostic, not a score: the filed document is in the Times-set pleading form with no page numbers in its body text, and our render is not, so the layers will not coincide line for line.

## Visual review (Gate 2 record, all 14 pages, 60 dpi, viewed after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, opening paragraphs | OK. Caption blocks aligned; title centered; footer page number. |
| 2 | Opening paragraphs, RELEVANT FACTS, footnote 1 | OK. Footnote at foot of page. |
| 3 | Facts: Section 7.20 block quotation; procedural history | OK. Block quotation single-spaced and indented. |
| 4 | Procedural history end, ARGUMENT, heading I | OK after fixing heading size (headings had been drawn at typst's default scale, larger than body text). |
| 5 | Argument I continued, heading II | OK. |
| 6 | Argument II, heading III | OK. Heading III wraps with the label hung. |
| 7 | Argument III continued | OK. |
| 8 | Argument III end, heading IV | OK. |
| 9 | Argument IV end, heading V | OK. |
| 10 | Argument V end, heading VI | OK. |
| 11 | Argument VI continued, heading VII | OK. |
| 12 | Argument VII, VIII, start of CONCLUSION | OK. CONCLUSION heading kept with its first lines. |
| 13 | Conclusion end, signature block | OK after fixing a repeated signer line (`/s/ Name` was followed by `Name`). Counsel lines single-spaced. |
| 14 | Certificate of service | OK. |

## Known gaps and open choices

1. **Local rules not verified.** See "Not verified" above. The template's only local-rule-like numbers are the district proxy (COB-FORM-002 to -004). **Needs David's call or the court's text** before this doc type is treated as complete.
2. **One exemplar in the filing sense is an adversary motion.** The second saved exemplar (Maverix) is a main-case motion. Tier 2 (2 or 3 filers) is judged here against two filers only for structure, not for adversary captions.
3. **Italics.** The exemplar's text layer has no italic markup, so the sample's italics come from the case names and signals as they read in the filing; they are the transcriber's choice.
4. **Footnote 2 absent.** The exemplar has one footnote (the caption name). Nothing else was dropped.
5. **Headings.** Level-2 headings are numbered by the template (I., II., …), not typed; the filing types them. Heading text is transcribed as printed.
6. **No TOC/TOA.** The exemplar has none. A longer brief (if the local rules require one) would need them; the CAND template has a generator that could be ported.
7. **Date and signature.** `/s/` lines are transcribed from the filing's own `/s/` marks. No signature was added.
8. **ECF header** ("Case 26-01048-MER Doc#:28 Filed:08/17/26 Entered...") is not printed in the render; it is the filing system's stamp and is not part of the document text.
9. **Certificate of service** content is from the exemplar. Whether D.C.COLO requires it in this form was not verified.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder is not. The brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

**docx** (`docx/`: `build-reference.sh` makes `reference.docx` from pandoc's default; `cob.lua` builds the caption, the signature table, the heading labels (`I.`, `A.`, `1.`) and the certificate of service). Render: `sh tools/render.sh --engine docx <doc-folder> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice 26.8.1, vendored EB Garamond). Footnotes are native Word footnotes.

- Matches the typst reference: court title, caption (debtor block, adversary block with its case number), bold capital title, 13 pt EB Garamond, letter, 1.5 in top margin and 1 in elsewhere, double spacing (exact 24 pt), 0.5 in first-line indent, `#` headings centered bold capitals, `##` and `###` headings numbered `I.` and `A.` and hung at the margin, single-spaced block quotation indented 0.5 in both sides, the footnote at 13 pt, the signature block (`Dated:` left, `Respectfully submitted,` and the firm and signer right), the certificate of service after the signature, and the 11 pt centered page number starting at 1. Page count 14 = typst 14. All 14 docx pages and all 14 typst pages were rasterized at 60 dpi and viewed.
- Differs from typst (renderer or tier 2, not a mandated-form miss):
  - Page breaks: the body in LibreOffice starts about 6 pt lower on each page and loses a line or two over the document, so breaks fall within a line or two of typst's; page 2 starts with a different paragraph than typst. Page count matches.
  - Signature block: typst keeps it on page 13; the docx moves the signature table to page 14 with the certificate, because the docx has about one line less space on page 13. The signature content is identical.
  - Heading VI: the typst heading wraps "Code." to a second line; the docx heading fits on one line (hanging-indent measure differs).
  - Caption: the adversary designation lines sit a few points lower than typst.
- BLOCKED: none declared. This folder has no `checks.yaml`, so there are no docx check IDs to block. `sh tools/check.sh <court-dir> --engine docx` fails at the court folder (`checks.yaml` missing), see the PR notes; it was not made to pass.
- Not checked: Microsoft Word (not available here). The `.docx` is a valid zip with well-formed XML parts and converts in LibreOffice without error.
