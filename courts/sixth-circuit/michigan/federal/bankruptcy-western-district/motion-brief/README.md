# miwb: motion with brief in support (adversary proceeding)

Doc type: **motion with brief in support** (Fed. R. Bankr. P. 9013 motion, with the memorandum that supports it, filed in an adversary proceeding) in the United States Bankruptcy Court for the Western District of Michigan (`miwb`).
Folder: `courts/sixth-circuit/michigan/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-cluchey-21-00524-motion-brief.pdf` (primary; motion and brief, Defendant's counsel CBH Attorneys & Counselors, 2021; 7 pp.) and `exemplars/FILED-EXAMPLE-murtha-10-06974-motion-brief.pdf` (Plaintiff's motion with brief, Maxwell Dunn, PLC, 2011; 8 pp.). Provenance in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-cluchey-motion-brief.md`: the whole motion and brief transcribed |
| render | ok: `samples/OUTPUT-cluchey-motion-brief.pdf`, 7 pages (motion 2 + brief 5), letter, 58 KB, typst 0.15.0 with vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> samples/INPUT-cluchey-motion-brief.md`) |
| overlay | ok: `samples/OVERLAY-cluchey-motion-brief.pdf` and `samples/OVERLAY-cluchey-motion-brief.txt`. Run as `sh tools/overlay.sh <this dir> cluchey-motion-brief <this dir>/exemplars/FILED-EXAMPLE-cluchey-21-00524-motion-brief.pdf` |
| pages reviewed | 7 of 7 (every page of the final `OUTPUT-cluchey-motion-brief.pdf` rendered at 60 dpi and viewed) |

File names follow the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), not the `<id>.pdf` form in the brief: `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Sources were fetched 2026-10-14. The local rules are the court's own PDF ("Local Bankruptcy Rules", effective October 11, 2026), read in full: https://www.miwb.uscourts.gov/sites/miwb/files/local_rules/Final%20-%20Clean_1.pdf. The federal rules are the Cornell LII text of the restyled Bankruptcy Rules (2024-12-01).

| ID | Rule (source) | Requirement | Where it is in the template |
|---|---|---|---|
| MIWB-FORM-001 | LBR 9004(f) | Except exhibits, official forms and software-generated preprinted forms, documents must be "double-spaced and typewritten in at least 12-point type." | `pitch = 27.6pt` (the Cluchey exemplar's measured baseline pitch), `type-size = 13pt`. No face is named; EB Garamond kept (gap 7). |
| MIWB-FORM-002 | Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | A pleading's caption "must substantially conform to the appropriate version of Form 416". A motion is not a pleading; the template gives the motion and the brief the same caption as the exemplars do. | `caption()`, `document-head()` |
| MIWB-FORM-003 | LBR 9004(a) | The debtor's current chapter in the caption, immediately below the case number. | `caption()`: "Chapter" line directly under "Case No." |
| MIWB-FORM-004 | LBR 9004(b); Fed. R. Bankr. P. 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | The caption carries "a brief designation of the document's character"; the LBR adds that the description is centered, immediately before the body, specific, and states the number of the document (first, second) and the name of the moving party. | `document-head()`: the motion's title and the brief's title, centered, bold, capitals, before the body |
| MIWB-FORM-005 | LBR 9004(c) | Every motion, pleading or other request for relief states the petition date and any conversion, dismissal or reinstatement. | `petition-statement()`: printed right after the motion's first paragraph (from `dates:`). The brief is a supporting document, not a request for relief, so the statement is not repeated in it. |
| MIWB-FORM-006 | LBR 9004(d) | Telephone, office address, email and state bar identification number "directly below the attorney's signature or in some other prominent place." | `signature-block()`: both the motion and the brief; a missing field stops the build |
| MIWB-FORM-007 | Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013) | Relief is requested "by motion". | Doc type. The motion and the brief are both in the template; the motion is the request. |
| MIWB-FORM-008 | LBR 9013(c)(4) and (f) (court LBR, above) | The notice-with-opportunity-to-object procedure "may not be used for ... motions filed within adversary proceedings". For other motions the Clerk schedules the hearing, and "a party filing a brief or response to a motion must file and serve its brief or response at least 7 days before the scheduled hearing." | No notice-of-motion page is generated. The Cluchey exemplar has none. Timing is not in the document; see "Known gaps". |
| MIWB-FORM-009 | LBR 9013(g) (court LBR) | Every request for an order is in a separate motion, except that requests for alternative relief may be in one motion. | Doc type: one motion per document. |
| MIWB-FORM-010 | LBR 7007 (court LBR) | Movant makes "a reasonable effort to meet and confer with opposing counsel" before involving the court. | Not a template field: a fact about the case. See "Known gaps". |
| MIWB-FORM-011 | ECF Administrative Procedures II.A.2 and IV.B (2 MB per document) and V.B (standard letter size) (https://www.miwb.uscourts.gov/sites/miwb/files/local_rules/ECF%20Admin%20Procedures%20Amended%20Eff%2012-13-21.pdf) | "supporting briefs, proposed orders, etc., shall be filed as attachments to the motion"; documents at most 2 MB; letter size. | The brief is a separate document with its own caption and page numbers (`brief-document()`, page numbers restart). Both documents are in one PDF for review, as the Cluchey exemplar is (its brief is docket entry 18-1, attachment 1 to entry 18). Letter paper. The sample is 58 KB. |
| MIWB-FORM-012 | Fed. R. Bankr. P. 7012(b) (incorporates Fed. R. Civ. P. 12 in adversary proceedings) | The motion to dismiss under Rule 12(b)(1) and 12(b)(6). | Doc type: the sample's text cites it. The template does not check the grounds. |

The local rules have no page limit for briefs in an adversary proceeding and no font or margin rule beyond LBR 9004(f) (the only page-limit hits in the LBR are for mediation summaries). The font list in LBR Exhibit 1 is for the creditor matrix only. The template therefore has no length check.

## Layout

- Motion, then the brief on a new page. Each has the same caption (court name, "In re:" block with "Case No." and "Chapter" on the right, party block with rules, "v.", "Adv. Proc. No." on the right), a centered bold title, the body, and a signature block.
- Text: EB Garamond, 13 pt, double-spaced at 27.6 pt baseline pitch (no face named by the rules; gap 7) (`body-leading = 1.477em`, measured with `pdftotext -bbox-layout`).
- Margins: 1 in, letter paper. Footer: centered page number; the page count restarts at the brief.
- Paragraphs: first-line indent 0.5 in; not numbered (the exemplars' motion and brief paragraphs are unnumbered; Murtha's motion is numbered, and that is the exception).
- Headings in the brief are typed by the author ("I.", "A.", "a."), as in the exemplars: level 1 centered bold capitals, level 2 bold, level 3 bold italic.
- Sub-lists are lettered a., b., ...; block quotations are indented 0.5 in; footnotes are supported (`[^key]`).
- No table of contents and no table of authorities: neither the local rules nor the Cluchey exemplar requires them for a brief of this length. Murtha's brief has none either.

## Engines

docx (`docx/`): pandoc with `docx/reference.docx` (built by `docx/build-reference.sh`), the Lua filter `docx/miwb-motion-brief.lua` (the motion and the brief, each with its caption, the LBR 9004(c) statement, signing blocks, and a section break so the brief's page count restarts), and `docx/render.sh`, which puts back the reference styles, page setup and footer that pandoc drops. Built and checked on this box as far as possible: `OUTPUT-cluchey-motion-brief.docx` is written; the zip has no duplicate entries and every XML part is well formed. The text of the sample is in the docx in order (checked by word sequence, against the markdown and the YAML motion body; only the list numerals differ, as they are lettered).

- Matches the typst reference (set in the reference, not yet measured on a rendered page): EB Garamond 13 pt throughout; exact 27.6 pt line spacing for body, headings and signature spacing; 0.5 in first-line indent; letter size with 1 in margins (12240 x 15840 twips, 1440 margins); headings 1 and 2 centered bold capitals, heading 3 bold at the margin; footnote text 13 pt single spaced; centered page number at 11 pt in the footer, restarting at 1 in the brief (`w:pgNumType w:start="1"` on the final section). The typst baseline pitch measures 27.65 pt on the complaint's body page (`/work/artifacts/miwb/adversary-complaint/OUTPUT-spiech-complaint.pdf`); the motion-and-brief render is `/work/artifacts/miwb/motion-brief/OUTPUT-cluchey-motion-brief.pdf` (7 pages).
- Differs from typst: the caption rule is a cell border, not the typst "_____/" slash rule; caption spacing is set in twips. Lettered lists are typed "a." labels with a hanging 0.5 in indent. The motion's body is taken from the YAML as the typst template does, so its paragraphs carry the same text. Page count is not measured (no rendered docx.pdf); the typst render of the same sample is 7 pages in total (motion and brief), the comparison for that count.
- docx BLOCKED (not passed): `docx.pdf` checks (Gates 0, 1 and 2 on the LibreOffice PDF): soffice is not installed on this box (`tools/render-docx.sh` fails at the conversion step after writing the `.docx`). Page review: 0 pages reviewed. Opening the `.docx` in LibreOffice or Word without a repair prompt: not verified. `tools/check.sh --engine docx` also needs `yq`, which is not on this box.
- Word limits that apply: none of the TOC, TOA or pleading line-number features is used by this document type (see `docs/DOCX.md`). PAGE is a field whose cached result is "1"; Word and LibreOffice recompute it on render.

## Overlay

`samples/OVERLAY-cluchey-motion-brief.pdf` pairs each rendered page with the Cluchey exemplar page that shares the most words (`OVERLAY-cluchey-motion-brief.txt`):

| ours | filed | word overlap |
|---|---|---|
| 1 | 1 | 87.1% |
| 2 | 2 | 54.5% |
| 3 | 3 | 63.6% |
| 4 | 4 | 58.8% |
| 5 | 5 | 75.5% |
| 6 | 6 | 86.0% |
| 7 | 7 | 85.2% |

The motion's second page is short in both (the signature block), so the low figure for page 2 is the layout, not missing text. Pages 2 to 4 score lowest; they are the body pages of the brief, where line breaks differ between the template and the filed file. The overlay is a diagnostic, not a score.

## Second exemplar (tier 2)

The Murtha filing (Plaintiff's motion with brief, 2011, Maxwell Dunn, PLC) is a second filer for the same document type. It runs the motion, then the brief, in one PDF; the brief repeats the full caption, as the template does. Its differences from the template are a counsel block at the top of the first page (the rules put attorney information under the signature, LBR 9004(d)), numbered motion paragraphs (not required for a motion), and no LBR 9004(c) statement. The template follows the rules and the Cluchey layout for those points.

## Known gaps and open choices (for David)

1. **Notice and response timing (LBR 9013(c)(4), (f)).** A motion in an adversary proceeding is not a notice-with-objection motion, so no response deadline appears in the template. The brief must be served at least 7 days before the hearing; the hearing is set by the Clerk. Question: should the template add a hearing line when the hearing is known?
2. **Certificate of service.** Neither exemplar includes one. For parties who are not served through CM/ECF, LBR 9013-1(a) requires proof of service to be filed promptly. The template does not produce one; add it as a separate document if needed.
3. **Conference statement (LBR 7007).** The movant must make a reasonable effort to confer. Not a template field.
4. **Dates statement placement.** The LBR says a motion must state the petition date and dates of conversion, dismissal or reinstatement; it does not say where. The template places it after the first paragraph of the motion (the Cluchey motion has no such statement, so the exemplar does not settle this).
5. **E-mail address.** The LBR requires one (LBR 9004(d)); the Cluchey exemplar prints none. The sample says so in brackets.
6. **Wording of the motion's title.** The exemplar's title is in capitals; the template prints the sample's title in capitals. The LBR requires the designation to name the moving party and the number of the document; the sample does.
7. **Typeface (no face named; EB Garamond kept).** The only formatting rule is LBR 9004(f): "typewritten in at least 12-point type". The font list in LBR Exhibit 1 ("Courier, Helvetica, Arial or Times New Roman") applies only to the creditor matrix .txt file, not to a motion or brief. So no substitute from `docs/FONTS.md` applies, and EB Garamond stays (`docs/FONTS.md`, "No face named"). Checked 2026-10-15 against the LBR PDF. At 13 pt its visual size is close to Times New Roman at 12 pt (the exemplars' face); that is a visual comparison, not a metric match. Render: 7 pages, unchanged.
8. **Italics.** The exemplar's text layer shows no italic markup, so case names are not italicised in the sample; the template italicises markdown `*...*` where the sample uses it (`*Id.*`).
9. **Typo carried over.** The Cluchey motion has "ender an Order" and the brief has "Clutchey" and "pary[y]"; the sample keeps the filer's words.
10. **Overlay default.** `tools/overlay.sh` chooses the first exemplar alphabetically (`cluchey`), which is the primary exemplar here, so the default is correct for this folder.

## Searches (for the record)

CourtListener v4 search, `court=miwb`, `type=r`: "motion brief memorandum" and "brief in support" descriptions. Found: Cluchey (21-80053, entries 18 and 18-1; the motion to dismiss with a brief in support, which is the closest match), Murtha (10-80566, entry 20; motion and brief in one PDF, 2011), Morris v. Charron (15-80086, entries 6 and 13: a cross-motion for summary judgment with its brief; not used, since two filers were enough). Court site: local rules at https://www.miwb.uscourts.gov/court-info/local-rules-and-orders/local-rules.

## Rebuild

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (see the brief's toolchain steps)
cd /work/repo
sh tools/render.sh courts/sixth-circuit/michigan/federal/bankruptcy-western-district/motion-brief samples/INPUT-cluchey-motion-brief.md
sh tools/overlay.sh courts/sixth-circuit/michigan/federal/bankruptcy-western-district/motion-brief cluchey-motion-brief courts/sixth-circuit/michigan/federal/bankruptcy-western-district/motion-brief/exemplars/FILED-EXAMPLE-cluchey-21-00524-motion-brief.pdf
```

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md)
