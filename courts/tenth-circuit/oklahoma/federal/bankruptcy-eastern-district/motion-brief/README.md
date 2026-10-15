# E.D. Oklahoma Bankruptcy Court: motion brief (brief in support of a motion)

- Court: `okeb`, United States Bankruptcy Court, E.D. Oklahoma (`courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/`)
- Doc type: `motion-brief`. A brief filed in support of a motion or objection (not a motion, not a complaint).
- Engine: typst only. No latex or docx files for this doc type yet.
- Exemplars: two public filings from different filers, in `exemplars/` (provenance in `exemplars/SOURCE.md`):
  - `FILED-EXAMPLE-gpnb-24-80617-closing-brief.pdf`: Great Plains National Bank's closing brief (creditor's counsel), Chapter 11, filed 2025-04-28, 22 pages.
  - `FILED-EXAMPLE-brooks-15-80927-trustee-brief.pdf`: Chapter 13 standing trustee's brief in support of objection to claim, filed 2017-02-02, 4 pages.
- Samples: `samples/INPUT-gpnb-closing-brief.md` (excerpt, 22 pages filed, transcribed in part; see Gaps) and `samples/INPUT-brooks-trustee-brief.md` (complete).
- Status: template, samples, renders, overlays and page review done (below). Not reviewed by a human. `court.json` untouched, no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `okeb-motion-brief`. |
| `typst/okeb-motion-brief.typ` | Template. Caption, body, headings, numbered paragraphs, signature block, optional certificate. Parameter block at the top. |
| `samples/INPUT-gpnb-closing-brief.md` | Markdown sample with YAML frontmatter (caption, counsel, signature, certificate, excerpt note). |
| `samples/INPUT-brooks-trustee-brief.md` | Same, for the trustee's brief. |
| `samples/OUTPUT-<id>.pdf` | `sh tools/render.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-<id>.md`. Great Plains: 11 pages. Brooks: 3 pages. |
| `samples/OVERLAY-<id>.pdf`, `.txt` | `sh tools/overlay.sh <court>/motion-brief <id> <exemplar.pdf>`. Red = ours, blue = filed, black = both. The `.txt` is the page map. |
| `exemplars/` | The two filed PDFs and `SOURCE.md`. |

## Governing rules

Template parameters, with the source of each:

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| LBR 9004-1 (E.D. Okla. Bankr.), "Papers: requirements of form" | 8½ × 11; type no smaller than 12 point, footnotes included; margins at least one inch; pleadings and briefs double spaced | `type-size`, `page-margin`, `double-leading`, footnote style | **Not verified against the primary text.** The court's site (okeb.uscourts.gov) rejected the request, and courtrules.net returned a Cloudflare challenge. The wording came from a search-engine summary of courtrules.net. Re-check against the court's current local rules before any filing. |
| LBR 9013-1, "Motions; form and service" | Motion papers; any brief-length cap | not used | **Not verified.** Only the title was found. Any page limit (search snippets mention 20 and 10 pages on an old page, not tied to a rule) is not enforced. |
| Fed. R. Bankr. P. 9037 | Privacy redaction | Not applied by the template. The Brooks sample omits the SSN fragments because the template has no field for them, not because the rule requires it. | Not read this session. |

The caption, signature block, certificate forms and heading styles follow the two filed exemplars, not a rule: both use "IN THE UNITED STATES BANKRUPTCY COURT / FOR THE EASTERN DISTRICT OF OKLAHOMA", a debtor column, and the case number and chapter in the right column. Both are double spaced in the text and single spaced in block quotations, lists, footnotes and signature blocks. Both signatures use "/s/" with an OBA number. The template does the same.

## Overlay

Overlays were run with `tools/overlay.sh`. Pages are paired by shared words, not by index, so the page map shows which filed page each render page matched.

- Great Plains (`OVERLAY-gpnb-closing-brief.txt`): our pages 1-11 pair with filed pages 1, 5-12, 21, 22 at 52-93% word overlap. Pages 10-11 pair with the conclusion and signature (filed 21-22). The filed pages 2-4 and 13-20 (table of contents, table of authorities, and the rest of the argument) are not in the sample.
- Brooks (`OVERLAY-brooks-trustee-brief.txt`): our pages 1-3 pair with filed pages 1, 2, 4 at 66-80%. Filed page 3 is not paired with any render page.

What the overlay shows: the page-paired diagnostic lines up the caption and the opening paragraphs. Because the filed pages break in different places, red and blue text rarely coincide line by line, so the overlay is read for content and order, not for exact line positions. It is not a pixel match and was not scored as one.

**Tool note:** `tools/overlay.sh` writes overlay PDF pages at 240.9 × 311.8 pt, not letter size. The content is complete, but a raster at 60 dpi is too small to read. Rasterize overlay pages at about 220 dpi to view them. This is in the shared tool, not this court folder, so it is not changed here.

## Pages reviewed

Every page of each render was rasterized to PNG and viewed.

- Great Plains render: 11 pages reviewed (pages 1-11).
- Brooks render: 3 pages reviewed (pages 1-3).

Findings from the page review:

- Page 1: counsel block fits on the cover; caption and title match the filed exemplar's layout.
- Pages 2-9: double spacing, footnotes, block quotations and the lists are placed as expected.
- Page 10: the conclusion starts on a new page because the signature block cannot break; the page has space left, which is expected.
- Page 11: signature block, "Respectfully submitted," and the certificate of service (after the signature, as in the filed brief).
- Brooks pages 1-3: caption with two debtors, numbered paragraphs 1-16 running across "FACTS" and "DISCUSSION", "WHEREFORE", signature, and the certificate of mailing.

## Gaps

These are open. None are blocking for a render, but a clerk would notice some of them.

1. **Rules not verified against primary text.** See the table above. The template's LBR 9004-1 numbers (12 point, one inch, double spacing) come from a secondary summary.
2. **No table of contents or table of authorities.** The Great Plains brief has both (filed pages 1-4). The template does not generate them and the sample does not transcribe them. A brief of that length normally carries them, so this is an open tier-2 finding. Whether E.D. Okla. requires them could not be checked (see item 1).
3. **First paragraph after a level-2 or level-3 heading is flush left in the render.** Level-1 headings are followed by an indented paragraph. A minimal Typst test with the same heading rules indents correctly, so the cause is in how the markdown is passed through cmarker. Not fixed in this pass.
4. **Great Plains sample is partial.** It transcribes filed pages 1, 5-13, 21 and 22 of 22. Pages 2-4 (table of contents, table of authorities, start of the argument) and 14-20 (the rest of the argument) are omitted; a line of asterisks marks the gap before the conclusion. The overlay therefore covers those pages only as unpaired.
5. **ECF header and footer not reproduced.** The filed PDFs carry the court's "Case … Doc … Filed … Entered … Page x of y" stamp on every page. The court's system applies it at filing; the template does not produce it.
6. **Brooks mailing list is one paragraph.** The filed certificate lists the debtors' address on its own line. The sample sets it as a paragraph after the certificate's lead-in.
7. **No `rules.md`, `checks.yaml`, `latex/`, `docx/`, or `court.json` status changes.** These are outside this task. No `tools/check.sh` run, so no gate result is reported.

## Engines

Docx engine (`docx/`): `docx/reference.docx` (built by `sh docx/build-reference.sh reference.docx`) and `docx/okeb-motion-brief.lua` (caption as a table with a vertical rule, consecutive numbered paragraphs, property lists, optional counsel block, signature block, optional certificate). It matches the typst form in paper (letter, 1 in margins), type (EB Garamond 12 pt, footnotes included), double spacing (exact 27.6 pt), 0.5 in first-line indent, block quotations (single spaced, indented 0.5 in each side), heading levels (level 1 bold centered capitals, level 2 bold, level 3 bold indented 0.5 in) and the centered page number in the footer.

Differences from typst: Word's line breaking and the caption table's border rendering are not checked; the typst vertical gaps are approximated with paragraph spacing; the body stays ragged right, as in the typst form. A certificate body given as markdown is split into paragraphs at line breaks in the frontmatter.

BLOCKED (docx engine, `samples/OUTPUT-brooks-trustee-brief.docx` and `samples/OUTPUT-gpnb-closing-brief.docx` are written and valid XML, but the rest cannot run here):
- `docx.pdf` (Gates 0 and 1 on the LibreOffice PDF): soffice not installed on this box, and LibreOffice cannot be installed here (no conda-forge package, no root). `tools/render-docx.sh` fails at its soffice step.
- Visual review of the docx pages: BLOCKED for the same reason; pages reviewed: 0.
- Word open check (no repair prompt): not done, no Word here.
