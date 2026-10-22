# Georgia Court of Appeals (gactapp): petition-for-rehearing

Doc type: Georgia has no petition for rehearing; the closest real type is the **motion for reconsideration** (Rule 37). Exemplar: **yes** (`usage/FILED-EXAMPLE-petition-for-rehearing.pdf`, Appellant's Motion for Reconsideration with its Brief in Support, *Sierra Club, Inc. v. Georgia Public Service Commission*, No. A21A1129, filed November 3, 2021 by Robert B. Jackson, IV, LLC and Sierra Club, Inc.; source in `usage/SOURCE.md`). Nothing here sets a `court.json` status.

## Status

| Item | Result |
|---|---|
| `usage/` | 1 filing, text PDF, 15 pages: the motion (pages 1-2), its certificate of service (3), then the brief in support (4-15), each with its own cover; court e-filing stamp "Case A21A1129 Filed 11/03/2021" on every page |
| `usage/INPUT-petition-for-rehearing.md` | transcription of the whole brief in support (filed pages 4-15). The two-page motion itself is not transcribed: it is a short request that refers to the brief. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-petition-for-rehearing.typst.pdf` and `usage/OUTPUT-petition-for-rehearing.docx` / `.docx.pdf`, 12 pages each, exit 0, no warnings, Times New Roman embedded |
| overlay | ok: `.overlay/courts/eleventh-circuit/georgia/state/court-of-appeals/petition-for-rehearing/OVERLAY-petition-for-rehearing.pdf` / `.txt` |
| pages reviewed | all 12 pages of the docx render at 50 dpi and of the typst render at 40 dpi (line for line the same: XENG PASS); all 15 exemplar pages at 60 dpi |
| cross-engine | docx XENG-001..003 PASS (247/247 lines, 12 pages); `eval.yaml` `params.cross_engine: gate` |

## Governing rules (primary source, read 2026-10-16)

Rules effective March 26, 2026 (URL and archive copy as in `../motion-brief/README.md`). Rule 37 (a): motions for reconsideration are prepared in accordance with Rule 24, limited to 4,200 words, with the certification "This submission does not exceed the word count limit imposed by Rule 24." just above the signature block. 37 (b): filed within 10 days of the judgment, by 4:30 p.m.; 37 (d): second motion only with permission; 37 (e): grounds (overlooked material fact, statute or controlling decision, or erroneous construction of law); 37 (h): no oral argument. Rule 24 (g): no attachments. Form rules (2 (c), 24 (c), (e)), signature (2 (a) (2) (ii)) and service (6) as in the motion-brief README. Deadline, second-motion and grounds rules are not enforced by the template (filer's job).

## Overlay page map

The regenerated same-id overlay pairs ours pages 1-8 with filed pages 4-11, pages 9-10 with filed page 13, page 11 with filed page 14, and page 12 with filed page 15. The template places the signature under the conclusion; the filed brief uses a separate signature page.

## Gate 2 review (12 of 12 pages, typst and docx alike)

| Page | Finding |
|---|---|
| 1 | Cover: "IN THE COURT OF APPEALS STATE OF GEORGIA", Case No. A21A1129, three-party caption (names centered, designations from the middle of the line, joined by "v." and "&"), title, "Counsel for Appellant Sierra Club, Inc." centered, the two counsel in two columns (as filed). OK |
| 2-3 | Opening paragraph, Argument, the Order's four numbered findings as a single-spaced block quotation. OK |
| 4-6 | Argument text, heading I (bold, wrapped lines hanging), the filer's bold passage kept bold. OK |
| 7-8 | *Stein* block quotation and its citation. OK |
| 9 | Heading II, the numbered list (typed "1)" / "2)", set "1." / "2." in both engines: typst's markdown reader keeps no delimiter). ACCEPTED (tier 3) |
| 10 | Conclusion. The page ends early: the certification, date and signature are kept together and move to page 11. OK |
| 11 | Rule 24 certification, date, underlined "/s/ Robert Jackson" with the name below and both counsel's lines; the second counsel's "/s/ Dorothy Jaffe" is a plain line, not underlined (contract limit, see Gaps). OK |
| 12 | Certificate of service on its own page (Rule 6 (b) (2) prior-agreement wording), two recipient blocks, "SO CERTIFIED", signature. OK |

## What changed

`typst/gactapp-petition-for-rehearing.typ` is the motion template (`../motion-brief/README.md`, "What changed") with the Rule 37 references: separate cover page by default, the Rule 24 certification in the rule's wording (the old template printed its own word-count sentence), underlined conformed signature, certificate of service from `paragraphs` / `recipients` / `closing`, 14 pt headings, optional contents and authorities. Sample replaced by the transcription.

## Gaps

1. Word count (4,200) not computed.
2. A second signer's conformed signature is not underlined (the contract has one `signer_line`).
3. The filer's motion and brief are two documents in one PDF; the template renders one document per sample.
4. Table of authorities and contents are available (`authorities`, `toc`) but this sample uses neither, as filed.

## Engines

typst, latex and docx on the shared document model (fb-595.54.12; docs/EVAL-LOOP.md, "Generated engines", fb-595.54.59): `typst/layout.yaml` holds the layout as data (the motion brief's, with the counsel line `counsel_role` above the two columns of counsel), `typst/gactapp-petition-for-rehearing.typ` hands it to `lib/typst/xdoc.typ`, and `fb engines gen` writes `latex/` and `docx/` from it; LaTeX and Word break every line and page where typst does (`params.cross_engine: gate`). INPUT changes for the port: the counsel line is the field `counsel_role` (it was a counsel group without lines), and the two-item list is numbered "1." (typst sets a "1)" list as "1.", LaTeX and Word as written; docs/open-items/fb-595.54.59.md). What follows records the hand-written engines of fb-595.68.36 that the generated ones replace.

The template, filter and styles are those of `../motion-brief` (see its README, "Engines"): typst and docx on the shared cross-engine layout model, Times New Roman 14 pt, 32.2 pt body and 16.1 pt single line boxes, `docx/reference.xml` (`base="xengine"`) and `docx/gactapp-motion.lua` on `docx.xengine`; `make-reference.sh`, `render.sh` and `reference.docx` are gone. The docx was Liberation Serif (TNR-EMBEDDED failed) and printed the old synthetic layout.
