# oked: motion-brief

Doc type: **motion to dismiss with brief in support** (a combined motion and brief, Fed. R. Civ. P. 12(b)) in the United States District Court for the Eastern District of Oklahoma (`oked`).
Folder: `courts/tenth-circuit/oklahoma/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a transcription of pages 1 to 11 and 15 to 17 of the 17-page filing (pages 12 to 14 are marked omitted in the sample; footnote 5 is not transcribed) |
| typeface | no face named by the court's rules (LCvR 5.2(a); checked 2026-10-15). EB Garamond stays, per `docs/FONTS.md` ("No face named"). See gap 4 |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings. Re-rendered 2026-10-15; `pdffonts` shows EBGaramond Regular, Bold and Italic embedded |
| overlay | ok, re-run 2026-10-15 against the exemplar fetched from the URL in `usage/SOURCE.md` (the PDF is not in the repo; passed to `tools/overlay.sh` as its third argument): `usage/OVERLAY-ffrf-motion-to-dismiss.pdf` and `.txt`; pairing worked (word overlap 39% to 93% per page) |
| pages reviewed | 11 of 11 (every page re-rendered at 60 dpi and viewed on 2026-10-15) |
| tier 2 | not judged against two filers: one exemplar only (gap 1) |

## Governing rules

Verified 2026-10-14.

| Source | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.2(a), E.D. Okla. Local Civil Rules, effective July 5, 2016 (https://www.oked.uscourts.gov/sites/oked/files/Local_Civil_Rules.pdf) | Paper 8½ × 11 in. Print style, footnotes included, not smaller than 12-point. Margins at least 1 in. on all sides. Line spacing no less than 1.5, excluding blocked quotations and footnotes. | `type-size = 12pt` (footnotes too, `footnote.entry`), `page-margin = 1in`, `line-pitch = 24pt` (double) for the body. Footnotes and blocked quotations are single-spaced, as the rule allows. The caption, headings and signature block are single-spaced (gap 3). |
| Typeface, all E.D. Okla. Local Civil Rules (posted PDF, text extracted and searched 2026-10-15) | No typeface is named. LCvR 5.2(a) sets only the print style's minimum size (12-point), the margins and the line spacing; LCvR 7.1(c) applies the same 5.2(a) form to briefs. | `font-family = "EB Garamond"` (no face named, so the vendored default is kept; `docs/FONTS.md`) |
| LCvR 7.1(b) (same document) | Each motion is a separate pleading with a concise brief. The brief may be combined with the motion "if clearly stated in the title of the motion or pleading". | The title is "DEFENDANT'S MOTION TO DISMISS AND BRIEF IN SUPPORT", set from the `brief_title` frontmatter. |
| LCvR 7.1(c) (same document) | No brief over 25 typewritten pages without leave. Briefs over 15 pages need an indexed table of contents and an indexed table of statutes, rules, cases and other authorities. The form is that of LCvR 5.2(a). | Page limit: author responsibility (A). Indexed TOC and TOA: **not produced by this template** (gap 2). |
| Fed. R. Civ. P. 12(b) (text: "But a party may assert the following defenses by motion"; amendment effective Dec. 1, 2024; https://www.law.cornell.edu/rules/frcp/rule_12) | Defenses by motion, including 12(b)(1) (subject-matter jurisdiction) and 12(b)(6) (failure to state a claim upon which relief can be granted). | The grounds are author content. The sample's headings cite 12(b)(1) and the frontmatter title cites 12(b). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, as amended Dec. 1, 2007) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court`, `case_number`, `caption`, `judge`, `brief_title` frontmatter. The caption box and the right column carry the case number and the judge. |

Not checked against a rule: the certificate of service and the "Date:" line are the exemplar's conventions. The certificate's rule (Fed. R. Civ. P. 5) was not verified for this doc type. Rule 7(b)(1) (a motion "must state with particularity the grounds for seeking the order") is author content.

## Layout

- Court name centered, bold, in capitals (two lines, from `court`).
- Caption: a ruled box around the parties (plaintiffs, "v.", defendant), with the designations in italic, as in the exemplar. To the right: "Case No." and the judge.
- Title centered, bold, in capitals, after the caption.
- Body: double spaced. Paragraphs have a 0.5 in. first-line indent; argument paragraphs are not numbered, and the facts are (marked `[numbered]` in the sample, as the exemplar numbers them).
- Headings: level 1 centered bold capitals (FACTUAL BACKGROUND, ARGUMENT, CONCLUSION). Level 2 "I.", "II." with a hanging label, bold. Level 3 "A.", "B.", bold. The template counts the labels, so the sample types no numbers. Headings are `sticky`.
- Footnotes: 12 pt, single-spaced, rule across 30% of the width.
- Signature block: "Date:" on the left, "Respectfully submitted," and "/s/" with the signer's lines on the right, then `attorneys_for`. The conclusion paragraph and its heading are kept on the page with the signature block.
- Certificate of service: starts on a new page (the exemplar does the same), with its paragraph and its own signature block.
- Page number centered at the foot, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter: `court`, `case_number`, `judge`, `caption.plaintiffs` and `caption.defendants` (each a list of `{names: [lines], designation}`), `brief_title`, `date`, `signature` (`signer`, `lines`), `attorneys_for`, `certificate` (`signer`, `lines`, `attorneys_for`).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) headings. `[numbered]` before a numbered paragraph; any other chunk is an unnumbered paragraph. Footnotes with `[^label]` in the text and `[^label]: text` definitions, as in the cand sample. `# CERTIFICATE OF SERVICE` begins the certificate (the template starts it on a new page and prints the heading in capitals).
- `[Pages 12 to 14 are not transcribed in this sample.]` marks the omitted run.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one per doc type, and EDOK's tier-2 rule asks for two or three filers. Searches for other EDOK motions to dismiss on CourtListener (through the web search, since the court's CM/ECF and CourtListener's search pages are not reachable from this box) found only other districts' filings, and the FFRF motion (6:25-cv-94-JFH) is the one saved. Tier 2 is therefore **not** judged against two filers.
2. **Indexed TOC and TOA (LCvR 7.1(c)), open and a tier-1 gap for long briefs.** The template does not produce a table of contents or a table of authorities. A brief over 15 pages does not comply until one is built; the cand template has both and could be adapted. The exemplar (17 pages, including the caption, signature and certificate) has neither, so either the rule counts the body differently or the filer did not comply. **Question for David:** does the 15-page count in LCvR 7.1(c) include the caption, the signature block and the certificate of service?
3. **Spacing of the caption, headings and signature block (tier-1 reading, open).** LCvR 5.2(a) requires line spacing of at least 1.5 except blocked quotations and footnotes. The caption, the headings and the signature block are single-spaced, as in the exemplar. Read literally, they need 1.5 spacing. **Question for David:** do these fall under the 1.5 requirement? The template follows the exemplar until David answers.
4. **Font.** No face is named by the court's rules (checked 2026-10-15; see the complaint README, gap 2). EB Garamond is used, at 12 pt, as `docs/FONTS.md` directs for "No face named". The exemplar is Times New Roman 12 pt, the filer's choice. The apparent size differs (see the complaint README, gap 2).
5. **Partial transcription.** The sample transcribes pages 1 to 11 and 15 to 17 of the filing, with pages 12 to 14 omitted and footnote 5 not transcribed. The sample's footnotes 1 to 4 are from the filing's text layer, which is clean for this exemplar, so their wording is the filer's. The headings and the signature block were checked against the page images.
6. **"¶" at a line end (fixed).** A paragraph sign can end a line with its number on the next line. The template now puts a non-breaking space after "¶" (`inl()`), so "¶ 6" stays together. The complaint template has the same rule, and its sample has no paragraph sign.
7. **Certificate of service.** The certificate's wording and signature block follow the exemplar. Fed. R. Civ. P. 5 was not verified for this doc type.
8. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root. This doc-type folder has neither, and the brief forbids changing `tools/`. Render and overlay were run, and the review below is the Gate 2 equivalent for this doc type.
9. **Tool output names.** `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `.txt`. The brief named `<id>.pdf` and `<id>-overlay.pdf`. The tools' names are used because `overlay.sh` reads `OUTPUT-<id>.pdf`.

## Review of the rendered pages (current PDF, `OUTPUT-motion-brief.typst.pdf`)

Compared with the exemplar's corresponding pages (exemplar page numbers in the right column).

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, boxed caption, case number and judge at the right, title, opening paragraph, footnote 1 at the foot. | PASS |
| 2 | exemplar p.2 | Body at double spacing; "The Complaint centers on..." and the two unnumbered paragraphs; FACTUAL BACKGROUND heading on the page. | PASS |
| 3 | exemplar p.3 | Argument-lead paragraph ("Read generously..."); numbered facts 1 and 2. | PASS |
| 4 | exemplar p.4 | Facts 3 and 4; ARGUMENT heading centered; I. heading with hanging label; A. heading; footnote 2 at the foot. | PASS |
| 5 | exemplar p.5 | Standing argument; "¶ 6" now stays together (previously "¶" ended a line). | PASS |
| 6 | exemplar p.6 | Argument on the standing theory, continued. | PASS |
| 7 | exemplar p.7 | Standing conclusion; B. heading (level 3 under I.) with hanging label; footnote 3 at the foot. | PASS |
| 8 | exemplar p.8 | II. heading, A. heading, OCPA paragraphs; footnote 4 at the foot. | PASS |
| 9 | exemplar p.9 | OCPA burden framework; B. heading; "[Pages 12 to 14 are not transcribed...]" marker; CONCLUSION heading kept with its paragraph on the next page. | PASS |
| 10 | exemplar p.16 | CONCLUSION heading and paragraph with the signature block on the same page, "Date:" at the left, "Respectfully submitted," and the /s/ block at the right, "Counsel for Defendant". | PASS |
| 11 | exemplar p.17 | CERTIFICATE OF SERVICE on its own page; the certificate paragraph; its signature block. | PASS |


## Pass stamp

Not written. `tools/check.sh` cannot run on this folder shape (gap 8).

## Engines

Typst is the primary engine. The DOCX engine is pandoc with `docx/reference.docx` (built by `docx/build-reference.sh`), `docx/motion-brief.lua` (boxed caption table, the "I." and "A." heading labels, numbering of the "[numbered]" paragraphs, the date and signature block, and the certificate on a new page) and `docx/render.sh` (letter page setup and the centered 12 pt page-number footer, which pandoc does not copy from the reference).

- Matches the typst form: EB Garamond 12 pt; body at an exact 24 pt pitch with a 0.5 in first-line indent; 1 in margins; single-spaced headings' second lines, block quotations, footnotes and signature block; the caption as a bordered cell beside the case number and judge; the certificate of service on a new page.
- Differs: Word may paginate differently from typst; the caption box is a table cell border, which Word and LibreOffice draw slightly differently; the TOC and TOA (LCvR 7.1(c), gap 2) are not produced by either engine; the "keep the conclusion with the signature" rule is a Word keep-with-next chain, which LibreOffice may break differently.
- DOCX BLOCKED items: `docx.pdf` (the LibreOffice PDF) is not produced: `soffice` is not installed on the box and cannot be installed without root. `tools/render-docx.sh` fails at its zip-integrity step because `unzip` is not installed, so `usage/OUTPUT-motion-brief.docx` is written but the command exits 1 before the PDF step. The XML parts of the written `.docx` were checked with `ziptool` and `xmllint` (17 of 17 well formed). Visual review of the docx pages: not done (no renderer); pages reviewed = 0. Not verified: that the file opens in Word or LibreOffice without a repair prompt.
- Gate 0/1/2/3 for the docx engine are not run (`tools/check.sh --engine docx` needs the `.docx.pdf`).
