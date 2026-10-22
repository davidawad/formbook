# E.D. Oklahoma Bankruptcy Court: motion brief (brief in support of a motion)

- Court: `okeb`, United States Bankruptcy Court, E.D. Oklahoma (`courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/`)
- Doc type: `motion-brief`. A brief filed in support of a motion or objection (not a motion, not a complaint).
- Engines: typst (`typst/`) and docx (`docx/`), both on the shared cross-engine layout model (fb-595.68.32); no latex.
- Exemplars: two public filings from different filers, in `usage/` (provenance in `usage/SOURCE.md`):
  - `FILED-EXAMPLE-motion-brief-2.pdf`: Great Plains National Bank's closing brief (creditor's counsel), Chapter 11, filed 2025-04-28, 22 pages.
  - `FILED-EXAMPLE-motion-brief.pdf`: Chapter 13 standing trustee's brief in support of objection to claim, filed 2017-02-02, 4 pages.
- Samples: `usage/INPUT-motion-brief-2.md` (excerpt, 22 pages filed, transcribed in part; see Gaps) and `usage/INPUT-motion-brief.md` (complete).
- Status: template, samples, renders and page review done (below). Not reviewed by a human. `court.json` untouched, no status set. `sh tools/check.sh`: typst 18 checks passed, 0 failed; docx 26 passed, 0 failed, XENG-001..003 PASS on both INPUTs (`params.cross_engine: gate` in `eval.yaml`).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `okeb-motion-brief`. |
| `typst/okeb-motion-brief.typ` | Template. Caption, title, optional counsel block, body (headings, numbered paragraphs, quotations, bullets, footnotes), signature block, optional certificate. Parameter block at the top. |
| `docx/reference.xml`, `docx/okeb-motion-brief.lua` | The Word template: styles (`base="xengine"`) and the filter that writes every block as typst sets it. |
| `eval.yaml` | `params.cross_engine: gate`. |
| `usage/INPUT-motion-brief-2.md` | Markdown sample with YAML frontmatter (caption, counsel, signature, certificate, excerpt note). |
| `usage/INPUT-motion-brief.md` | Same, for the trustee's brief. |
| `usage/OUTPUT-<id>.typst.pdf`, `.docx`, `.docx.pdf` | `sh tools/render.sh [--engine docx] courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-<id>.md`. Great Plains: 12 pages. Brooks: 4 pages (the certificate of mailing on a page of its own, as filed). |
| `usage/OVERLAY-<id>.pdf`, `.txt` | `sh tools/overlay.sh <court>/motion-brief <id> <exemplar.pdf>`. Red = ours, blue = filed, black = both. The `.txt` is the page map. |
| `usage/` | The two filed PDFs and `SOURCE.md`. |

## Governing rules

Template parameters, with the source of each:

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| LBR 9004-1 (E.D. Okla. Bankr.), "Papers: requirements of form" | 8½ × 11; type no smaller than 12 point, footnotes included; margins at least one inch; pleadings and briefs double spaced | `type-size`, `page-margin`, `pitch-double = 27.6pt` (every body line a 27.6 pt box, Word's double), 13.8 pt single lines for quotations, bullets, footnotes and blocks; footnote style | **Not verified against the primary text.** The court's site (okeb.uscourts.gov) rejected the request, and courtrules.net returned a Cloudflare challenge. The wording came from a search-engine summary of courtrules.net. Re-check against the court's current local rules before any filing. |
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

Every page of each render (typst and docx, both INPUTs) was rasterized to PNG and viewed side by side after the last template change (2026-10-22).

- Great Plains render: 12 of 12 pages, typst and docx.
- Brooks render: 4 of 4 pages, typst and docx.

Findings from the page review:

- Page 1: caption, the three-line title and the counsel block on the first page, as filed.
- Great Plains pages 2-10: double spacing, footnotes, headings (levels 1 to 3), block quotations and the bullets placed as expected; "* * *" centered on page 10.
- Great Plains page 11: the conclusion; the rest of the page is empty because the signature block cannot break and does not fit with the conclusion.
- Great Plains page 12: the dated line, signature block and the certificate of service.
- Brooks pages 1-3: caption with two debtors, numbered paragraphs 1-16 running across "FACTS" and "DISCUSSION", "WHEREFORE" and the signature. Page 4: the certificate of mailing, kept whole on its own page (as filed).

## Gaps

These are open. None are blocking for a render, but a clerk would notice some of them.

1. **Rules not verified against primary text.** See the table above. The template's LBR 9004-1 numbers (12 point, one inch, double spacing) come from a secondary summary.
2. **No table of contents or table of authorities.** The Great Plains brief has both (filed pages 1-4). The template does not generate them and the sample does not transcribe them. A brief of that length normally carries them, so this is an open tier-2 finding. Whether E.D. Okla. requires them could not be checked (see item 1).
3. **First paragraph after a heading (fixed).** Every body paragraph is indented half an inch, after a heading too (each chunk is its own paragraph since fb-595.68.32).
4. **Great Plains sample is partial.** It transcribes filed pages 1, 5-13, 21 and 22 of 22. Pages 2-4 (table of contents, table of authorities, start of the argument) and 14-20 (the rest of the argument) are omitted; a line of asterisks marks the gap before the conclusion. The overlay therefore covers those pages only as unpaired.
5. **ECF header and footer not reproduced.** The filed PDFs carry the court's "Case … Doc … Filed … Entered … Page x of y" stamp on every page. The court's system applies it at filing; the template does not produce it.
6. **Brooks mailing list.** A certificate paragraph written with markdown line breaks (an address) is set as single-spaced lines at the margin, as filed.
7. **No `checks.yaml` or `latex/`.** `tools/check.sh` runs the default checks; the RESULT lines are under Status and Engines. The LBR 7007-1(B) 20-page limit is asserted by the typst template (DEF-LEN-001 still SKIPs: no `params.page_limit`).

## Engines

Both engines follow the shared cross-engine layout model (fb-595.68.32): Times New Roman 12 pt (LBR 9004-1(A) names no face; the docx names the typst face through `{font}`), every line an exact box of its pitch (27.6 pt double-spaced body, LBR 9004-1(A); 13.8 pt single lines for the court, caption, title, headings, quotations, bullets, footnotes, counsel and signature), explicit spaces between blocks, first-fit ragged-right breaking without kerning, ligatures or hyphenation (the Brooks sample's `word:` justification map is no longer read).

- Layout: the caption a one-row table, the debtor column ruled at its right; the title bold centered capitals, single spaced, a double line below the caption; the counsel block 3.25 in from the margin; headings single spaced, a single line above and below, sticky (level 1 centered capitals, level 2 bold at the margin, level 3 bold half an inch in); quotations half an inch in on both sides and bullets (the bullet half an inch in, the text hanging 0.25 in after it) single spaced, a single line above and below; "* * *" centered; footnotes in single lines under a 30 % rule, 7 pt apart; the signature block a double line below the body, never split, the last body block kept with it; the certificate kept whole.
- docx: `docx/reference.xml` (`base="xengine"`, 24 half points, body 552, single 276 twips, footer 720; Body Text Note without widow control, Body Text Keep, a Footnote Text that splits) and `docx/okeb-motion-brief.lua` (`require("docx.xengine")`): every paragraph with the typst pitch and spaces in twips; the caption an OOXML table; the signature block a table row that cannot split, after an empty double line kept with it (a chain of kept paragraphs longer than the room left would be split, where typst moves the block whole); the caption, counsel and signature strings from `$FORMBOOK_META` as written, the title and certificate text read as markdown. `docx/build-reference.sh` and the binary `reference.docx` are gone. The docx had been set in EB Garamond, failing DEF-FONT-002 and TNR-EMBEDDED.

Results (2026-10-22): typst `RESULT: 18 checks passed, 0 failed`; docx `RESULT: 26 checks passed, 0 failed`; XENG-001..003 PASS on both INPUTs (Brooks 82/82 lines, 4 pages; Great Plains 321/321 lines, 12 pages). Every page of both renders of both INPUTs viewed side by side. Great Plains page 11 ends half empty: the conclusion and the 22-line signature block do not fit on one page together, so the signature block starts page 12 (both engines).
