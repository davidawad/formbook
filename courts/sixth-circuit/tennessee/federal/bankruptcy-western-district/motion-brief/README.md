# tnwb: motion-brief

Doc type: **motion with memorandum of law** in the United States Bankruptcy Court for the Western District of Tennessee (`tnwb`), filed under FRBP 9013 and TNWB LBR 9013-1. The template formats the memorandum of law that supports a motion; the motion itself is a separate short filing.
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-kenney-18-00186-motion-brief.pdf` (memorandum only, 1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-kenney-motion-memorandum.md` (the full 7-page memorandum transcribed: caption, background, standard of review, argument, conclusion, footnotes, signature, certificate of service) |
| render | ok: `samples/OUTPUT-kenney-motion-memorandum.pdf`, 6 pages, US Letter, typst 0.15.0, vendored EB Garamond only, no typst warnings |
| overlay | ok: `samples/OVERLAY-kenney-motion-memorandum.pdf` and `samples/OVERLAY-kenney-motion-memorandum.txt` |
| pages reviewed | 6 of 6 (every page of the final render rasterized at 60 dpi and viewed) |
| tier 2 | not met: one filer only (see Known gaps 1) |
| typeface | face required by the rules: none (Known gaps 4) -> vendored substitute: none needed, EB Garamond kept per `docs/FONTS.md` ("No face named") -> not applicable |

Commands (from the repo root, with `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief samples/INPUT-kenney-motion-memorandum.md
sh tools/overlay.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/motion-brief kenney-motion-memorandum
```

Output names are the tools' defaults (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`): `tools/overlay.sh` reads `OUTPUT-<id>.pdf`.

## Governing rules

Dates verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| FRBP 9013(a) | A request for an order must be made by written motion (unless an exception applies). | https://www.law.cornell.edu/rules/frbp/rule_9013 | Not generated: the motion is a separate filing. The memorandum's title names the motion it supports (`title`). |
| FRBP 9013(b) | A motion must state its grounds with particularity and set forth the relief requested; service on the entities the rules require. | same | Author content (the memorandum's argument). Service is shown by the certificate of service (`service` frontmatter). |
| FRBP 9004(a), (b) (restyled eff. Dec. 1, 2024) | Papers must be clearly legible; caption with the court's name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-heading`, `caption`, `title`. |
| FRBP 7010 (adversary proceedings) | Caption must substantially conform to Official Form 416; Rule 10 of the Civil Rules applies. | https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption` (same layout as the adversary complaint). Form 416 was not fetched (Known gaps 3). |
| TNWB LBR 9013-1 (eff. April 3, 2017) | Motions, applications, objections and proposed consent orders in which relief is sought after notice and hearing; in Chapter 7, 11 and 12 cases the movant files with the Clerk and the Courtroom Deputy sets the deadline. | https://www.tnwb.uscourts.gov/PDFs/BK/LocalRules.4.3.17.pdf | Not checked by the template (Known gaps 2). |
| TNWB LBR 7016-1(a) | Memoranda of facts and law "should not exceed twenty-five (25) pages without prior approval of the court." | same | Not checked by the template. The sample is 6 pages; the author must count any longer memorandum. |
| TNWB LBR 7016-1(b) | An opinion cited that is not on Westlaw or Lexis must be attached or supplied to the court seven days before the hearing. | same | Not generated; author content. |
| TNWB LBR 1001-3(h) | Every filed document bears the signature of an attorney of record and the attorney's address, zip, telephone, email, fax if any, and state bar disciplinary number. | same | `signature` frontmatter (`firm`, `signer`, `name_line`, `lines`, `role`). See Known gaps 5. |

## Layout

- Letter paper, 1 in margins. Body EB Garamond 12 pt, double spaced (24 pt baseline pitch), first-line indent 0.5 in, paragraphs not numbered (the memorandum types its own paragraph numbers, as the exemplar does).
- Court heading centered; caption as in the adversary complaint (debtor block, adversary block, § column, adversary number on the right).
- Title centered in capitals between rules, after the caption.
- `#` headings: centered bold capitals (PROCEDURAL/FACTUAL BACKGROUND, STANDARD OF REVIEW, ARGUMENT, CONCLUSION). `##`: centered bold, mixed case. `###`: left bold (lettered sub-headings such as `A.`).
- Block quotations (`>`): indented 0.5 in on both sides, single spaced, as in the exemplar.
- Tables (pipe tables): centered, single spaced, ruled; a table that breaks across pages repeats its header row.
- Footnotes: `text[^key]` plus `[^key]: ...` definitions at the end; 10 pt.
- Signature block at 3 in from the left margin: closing line ("Respectfully submitted,"), firm, `/s/` signer, name line with state bar number, address and contact lines, role. The last body paragraph is kept in one unbreakable block with the signature.
- Certificate of service (if `service` is given): centered heading, the exemplar's wording with the date, the served parties in two columns, and `/s/` signer.
- Page numbers centered at the foot of each page.

## Markdown contract (for samples)

YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `division` | no | third caption line |
| `debtor` (list of lines) | yes | `IN RE:` block |
| `case_number` | yes | `CASE NO.:` |
| `chapter` (list of lines) | yes | chapter lines |
| `adversary_number` | yes | `ADVERSARY PROCEEDING NO.:` |
| `plaintiffs`, `defendants` (lists) | yes | adversary block |
| `title` | yes | memorandum title, centered in capitals |
| `signature` | yes | `closing`, `firm`, `signer`, optional `name_line`, `lines`, `role` |
| `service` | no | `date` and `parties` (a list; each party is a list of lines) for the certificate of service |

Body: blank-line separated blocks. `#` / `##` / `###` headings; `|` tables; `>` quotations; any other block is an unnumbered paragraph with a first-line indent. A literal `*` must be escaped (`at \*8`), and a paragraph that begins with a number and period must be escaped (`1\. On July 19, 2017`), or cmarker reads it as a list.

## Known gaps and open choices

1. **One exemplar, and it is the memorandum, not the motion.** The tier-2 test (2 or 3 filers) is not met. The search (CourtListener RECAP, `court=tnwb`, memoranda in support) found Johnson 18-00294 and Minnesota Life 18-00157 (memoranda whose PDFs are not in RECAP) and Brown 23-00021 (doc 15, the motion to dismiss, which did not download). None was saved. The motion that Kenney's memorandum supports is not in the exemplar; the template covers the memorandum only.
2. **LBR 9013-1 and 7016-1 are not checked by the template.** The page limit (25 pages, LBR 7016-1(a)) and the motion-practice steps (LBR 9013-1(b)–(c): filing with the Clerk, the Courtroom Deputy's deadlines, the proposed order and certificate on Local Form 008F) are the filer's job. The template does not generate the motion, the proposed order or Local Form 008F.
3. **Form 416 was not fetched.** See the adversary complaint README, Known gaps 3.
4. **No court typeface, margin or spacing rule found.** See the adversary complaint README, Known gaps 2. The conventions here (12 pt, double spaced, 1 in margins) follow the exemplar.
5. **State bar number.** LBR 1001-3(h) requires the state bar disciplinary number. The exemplar's signature block shows "Jay A. Ebelhar (22770)", which is the number on the signature line; the template prints `name_line` as given. The template does not check for it.
6. **Italics.** The exemplar's text layer does not show italics. The sample italicizes case names and signals (*Id.*, *see*, *In re ...*) as a convention; the exemplar's visual italics were not checked.
7. **Certificate of service.** The wording and the layout follow the exemplar. The rule that requires a proof of service on each filed motion was not identified and was not verified; the certificate is an exemplar convention.
8. **Transcription.** The sample is the exemplar's text transcribed from its text layer, with the exemplar's own errors kept (for example "fails to state a clam" in the Standard of Review). The footnote numbering is the exemplar's.
9. **Justification.** Body text is ragged right. Not asserted.
10. **Overlay pairing.** The overlay pairs pages by word overlap, not by index (`OVERLAY-kenney-motion-memorandum.txt`). Pages 1, 2, 5 and 6 match 78–85% with the same-numbered filed page. Page 3 matches its filed page at 48%, and page 4 pairs with filed page 5 (62%), because the page breaks of the sample do not follow the exemplar's. The overlay is a diagnostic, not a score.
11. **Checker not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none of those, and the brief forbids changes to `tools/`. Render and overlay were run; the page review below is the visual check.

## Review of the rendered pages (final render, 6 pages)

Rendered at 60 dpi with `pdftoppm -r 60` and viewed page by page.

| Page | Content | Result |
|---|---|---|
| 1 | Court heading, caption, title, opening paragraph, background paragraphs 1–2; footnote 1 | Pass. Caption and title are not crowded; footnote 1 is in the footnote area. |
| 2 | Background paragraphs 3–8; STANDARD OF REVIEW; footnote 2 (long, set in full at the foot of the page) | Pass. Footnote 2 fits on the page. |
| 3 | Standard of review (cont.); ARGUMENT; sub-heading A; first paragraphs of A | Pass. Sub-heading A is left bold and kept with its paragraph. |
| 4 | Sub-heading A (cont.): block quotation and the Moore citation; sub-heading B | Pass. Block quotation indented and single spaced. Italics on case names. |
| 5 | Sub-heading B (cont.); CONCLUSION; "Respectfully submitted," firm, `/s/` signer, name line, contact lines, role | Pass. The signature stays with the last paragraph of the conclusion. |
| 6 | CERTIFICATE OF SERVICE: wording, two columns of served parties, `/s/` signer | Pass after a fix (two columns instead of three, so "200 Jefferson Avenue, Ste. 1113" does not wrap). |

Open tier-2 findings (ACCEPTED): body text is ragged right; the caption uses the § column; the certificate of service wording follows the exemplar and is not tied to a verified rule (Known gaps 7).

## Engines

docx (`docx/build-reference.sh` -> `docx/reference.docx`, filter `docx/tnwb.lua`; render `sh tools/render.sh --engine docx`; judged on `samples/OUTPUT-kenney-motion-memorandum.docx.pdf`, the LibreOffice conversion):

- Matches the typst output: 6 pages in both; EB Garamond only (`pdffonts`); US Letter, 1 in margins; double spacing (exact 23.9 pt, 27 lines per page as in typst at 24 pt); single-spaced court heading, caption, signature block and the certificate of service's parties in two columns; centered caps, centered bold and left bold headings; block quotation indented 0.5 in on both sides and single spaced; footnotes at 10 pt; page number centered in the footer; the signature block kept with the last body paragraph; the certificate of service on its own page as in typst. Pages reviewed: 6 of 6 (every page of the final docx.pdf rasterized at 60 dpi and viewed, compared with the typst pages).
- Differs (tier 2, not chased): (1) the signature firm name wraps to three lines in LibreOffice ("BAKER, DONELSON, BEARMAN, / CALDWELL & BERKOWITZ, A Professional / Corporation") where typst wraps to two; (2) pagination: the page 2 footnote is set a line tighter, so page 3 begins about one line earlier in the text than in typst; page counts agree; (3) footnote leading is exact 11.5 pt; (4) no PDF bookmarks.
- BLOCKED: none in the template. `sh tools/check.sh <court-dir> --engine docx` cannot run on this folder: it needs `checks.yaml` and `rules.md` (and the court's `court.json`), which this unit does not create; the run exits 2 before any gate. No check ID is BLOCKED by the docx template itself.
