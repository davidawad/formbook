# cob: motion brief

Doc type: **motion with memorandum** (FRBP 9013) in the United States Bankruptcy Court for the District of Colorado (`cob`). Folder: `courts/tenth-circuit/colorado/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (adversary motion, Point Digital Finance's counsel, 15 pp.). A second filer is saved as `usage/FILED-EXAMPLE-motion-brief-2.pdf` (main-case ex parte motion, Receiver's counsel, 12 pp.), not transcribed. See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: full transcription of the 15-page filing (caption, motion, facts, argument I to VIII, conclusion, signature block, certificate of service). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 14 pages, typst 0.15.0, vendored Times New Roman only, no warnings, on the shared cross-engine layout model (fb-595.68.32) |
| overlay | ok: `usage/OVERLAY-katzenberger-motion-brief.pdf` and `OVERLAY-katzenberger-motion-brief.txt` |
| pages reviewed | 14 of 14 on typst and docx (every page of both renders viewed side by side at 45 dpi after the last template change, 2026-10-22; the review table below was made on the earlier EB Garamond render) |

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
| COB-FORM-002 | Proxy: D.C.COLO.LCivR 10.1 (district court, not the bankruptcy LBR), text from a third-party aggregator (courtrules.net, quoted via search 2026-10-14); the district text is "FORMAT OF PLEADINGS AND DOCUMENTS PRESENTED FOR FILING" with a 2005 general order as its source. | Typewritten documents: black ink, font at least 12 point, 8½ × 11 white paper, one side. | `type-size = 12pt`, footnotes included; `font-family = ("Times New Roman", "Liberation Serif")` (no rule names a face: Times New Roman, the house standard; the docx names it through `{font}`) |
| COB-FORM-003 | Proxy: same district rule | Double spacing for all documents. | `pitch-double = 24pt`: every body line a 24 pt box (2 x 12 pt), the cross-engine layout model (`lib/typst/xengine.typ`); single lines (caption, title, headings, quotations, footnotes, signature) 13.8 pt (`pitch-single`) |
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
- Body: double-spaced (24 pt lines), first-line indent ½ inch; headings single-spaced, a single line above and below, sticky, numbered by the template (level 1 unnumbered centered bold capitals; level 2 "I.", level 3 "A.", level 4 "1.", bold, the label in a half-inch box and the title hanging after it, each level half an inch further in); block quotations single-spaced, half an inch in on both sides, a single line above and below; footnotes at 12 pt in single lines under a 30 % rule, 7 pt apart.
- Footer: centered page number, arabic from 1 (the caption page is page 1, as in the exemplar).
- After the body, a double line below it: signature block (Dated left; in a 3.2 in column at the right "Respectfully submitted,", the firm, `/s/` and signer, bar number and address lines, a blank line between the groups), never split, the last paragraph kept with it; then, a double line below, the optional certificate of service (heading, the text at the body pitch, Dated and `/s/` line), never split.

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

## Visual review (Gate 2 record, made on the earlier 14-page EB Garamond render; the 14 pages of the current typst and docx renders were viewed side by side on 2026-10-22, no defect found: caption, headings I to VIII, the block quotation, footnote 1 on page 1, the signature on page 13 and the certificate on page 14)

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
10. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines. `tools/check-selftest.sh` needs a `court.json` and does not run on a doc-type folder.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 13.8 pt single lines and footnotes 7 pt apart, Body Text Note without widow control, Body Text Last kept with the signature a double line below, letter page with a 1.5 in top margin and 1 in elsewhere, the centered 11 pt page-number footer; the markdown read as CommonMark with footnotes, as cmarker reads it) and `cob-motion-brief.lua` (on `lib/docx/xengine.lua`: the court title, the two caption blocks as one-row tables, the title, the numbered headings, the quotations, the paragraphs with native footnotes, the signature and certificate tables, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.32; were `build-reference.sh`, `reference.docx` and `cob.lua`, EB Garamond 13 pt). Samples: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (14 pages, 337/337 lines).
- The footnote definition may stand anywhere in the body: the typst template folds it into the paragraph that cites it (the sample keeps it at the end; the earlier template left the note unresolved there).
- No latex engine for this folder.
