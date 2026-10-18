# nhd: motion-brief

Doc type: **motion to dismiss with accompanying memorandum of law** (Fed. R. Civ. P. 12(b)(1) and 12(b)(6)) in the United States District Court for the District of New Hampshire (`nhd`).
Folder: `courts/first-circuit/new-hampshire/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nhd-motion-brief-jonas126cv00600.pdf` (1 filer, government defendants; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nhd-motion-brief-jonas.md`: pages 1 to 13 and 22 to 25 of the 25-page filing, transcribed from the text layer (pages 14 to 21 and the footnotes are not transcribed; see Known gaps) |
| render | ok: `usage/OUTPUT-nhd-motion-brief-jonas.typst.pdf`, 18 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-jonas-motion-brief.pdf` and `OVERLAY-jonas-motion-brief.txt` |
| typeface | Rule names no face (LR 5.1(a): "a proportionately spaced font ... no less than twelve (12) point"; no typeface named in the section). Vendored substitute: none needed. Kept **EB Garamond** (`fonts/eb-garamond/`). Not metric-compatible with the filing's Times New Roman; not chased (tier 3). |
| pages reviewed | 18 of 18 (every page rendered at 60 dpi and viewed after the last template change; re-rendered and re-viewed 2026-10-14 with no template change) |

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.H. LR 7.1(a)(1) (2025 Local Rules, as amended through 2025-12-01; https://www.nhd.uscourts.gov/pdf/2025%20Local%20Rules%20-%20District%20of%20New%20Hampshire.pdf) | The word "motion" in the title; separate motions for separate relief. | `title` frontmatter: "MOTION TO DISMISS ... WITH ACCOMPANYING MEMORANDUM OF LAW". Content only: the template does not check it. |
| LR 7.1(a)(2) | A motion is accompanied by a memorandum with citations to authorities. | The memorandum is the body of the same document (Argument, Conclusion). |
| LR 7.1(a)(3) | Dispositive memorandum no longer than 25 pages without leave. | Not checked by the template. The filing is 25 pages, motion and memorandum together, within the limit; the sample is partial (see Known gaps). |
| LR 7.1(c) | Concurrence is required for a non-dispositive motion; not for a dispositive one. | Not asserted (a Rule 12(b) motion is dispositive, LR 7.1(g)). |
| LR 7.1(e)(1) | Reply memorandum on a dispositive motion, within 7 days after the objection, at most 10 pages. | Not produced: a reply is a separate filing. |
| LR 7.1(g) | "Dispositive motion" includes a motion under Fed. R. Civ. P. 12(b) or (c). | Classifies this doc type (the 25-page limit applies). |
| LR 5.1(a) | 8 1/2 x 11 paper; 12-point proportional type; one-inch margins; page numbers at the bottom center; double spaced except quotations; footnotes sparingly. | `paper: "us-letter"`, `margin: 1in`, `type-size = 12pt`, `body-leading = 1.65em` (27.6 pt pitch: 2 x the 13.8 pt single line), footer page number centered. |
| LR 5.1(b) | Attorney name, address, telephone, e-mail and NH bar number on all filings; bar number after the typed name in the signature section. | `signature` frontmatter (`blocks`), `signature-block()`. |
| LR 5.1(c) | Caption, description of the contents, party filing; docket number with the judge's initials suffix. | `caption` (court title, party block with a column of ")" marks, `case_number`), `title`. |
| LR 5.1(d) | Certificate of service: name and address of the party served, the manner of service, the date, personally signed. | `certificate` frontmatter; printed as filed. See the note below. |
| Fed. R. Civ. P. 5(d)(1)(B) (https://www.law.cornell.edu/rules/frcp/rule_5, fetched 2026-10-14) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | The filing carries a certificate for ECF service. The template prints it, but it is optional for ECF service. |
| Fed. R. Civ. P. 12(b)(1), 12(b)(6) | Defences that must be raised by motion. | Content only. |

Note on the certificate: the filing's certificate states only the ECF manner and the signer. LR 5.1(d) requires the name and address of the party served, the manner, and the date. Those are not in the template; if the motion is served conventionally, the certificate must carry them, and the template would need new frontmatter fields (see Known gaps).

## Layout

- Court title (two lines, bold, centered), caption (party names, a column of ")" marks, `Civil No.` beside the middle line), the title in bold caps centered.
- Body: unnumbered paragraphs, 0.5 inch first-line indent, double spaced. Headings: level 1 centered bold caps (`INTRODUCTION`, `BACKGROUND`, `STANDARD OF REVIEW`, `ARGUMENT`, `CONCLUSION`); level 2 bold flush left (`I. The Claims ...`, `III. ...`); level 3 bold indented 0.5 inch (`A. ...`, `B. ...`); level 4 bold italic indented 1 inch (`i. ...`).
- Markdown lists (`1.` items) are lettered (a), (b), ..., indented.
- Signature block at the right half of the page: `Respectfully submitted,`, the party lines, the date, `/s/` line, then the counsel block.
- Certificate of service (if the frontmatter has `certificate`): heading, one paragraph, the signer's lines at the right half.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties; each name is one line in the caption), `case_number`, `title`, `signature` (`intro`, `party` (lines), `date`, `signer`, `blocks`), `certificate` (`text`, `signer` (lines)).
- Body chunks, separated by blank lines: `#` to `####` headings; `1.` list items; any other chunk is an unnumbered paragraph.
- Not supported: footnotes, tables, raw typst. Text is markdown; the transcription is roman (the exemplar's text layer has no italic markup).

## What the overlay shows

`OVERLAY-jonas-motion-brief.pdf` is red (our render) on blue (the filed PDF), black where both agree. Pages 1 to 13 pair one to one with the filed pages 1 to 13. Our pages 14 to 17 pair with the filed pages 22 to 25 (the sample skips filed pages 14 to 21, so the pairing jumps there). Our page 18 is the certificate of service, which pairs with filed page 25 with little overlap. The `.txt` lists the pairing and word overlap. Overlap percentages are word-level and are not a score.

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP, `type=rd`, `court=nhd`, `q="motion to dismiss" memorandum`, newest first, 2026-10-14) returned, on its first page of results with a stored PDF, this filing and a court opinion (not a filing). Later pages were not checked. Tier 2 is therefore **not** judged against two filers.
2. **Partial transcription.** The filing is 25 pages. The sample has pages 1 to 13 and 22 to 25 (the caption and the Background, Standard of Review, Argument I.A to I.C, the Eleventh Amendment discussion's last paragraphs, Argument III, Conclusion, the signature block and the certificate). Pages 14 to 21 are omitted, which removes the heading `II.` and its text. The rendered sample is 18 pages, above the 8 to 14 page target, because the body text of pages 1 to 13 is double spaced at 27.6 pt; trimming the transcription would drop the structure the overlay compares.
3. **Footnotes.** The filing has footnotes 1 and 2 (on pages 2 and 9). The markdown contract has no footnotes, so their text is absent.
4. **Font.** The filing is Times New Roman, but the rule does not require it: LR 5.1(a) names no typeface, so the fonts policy (`docs/FONTS.md`, rule 3) keeps EB Garamond. At 12 pt EB Garamond has a smaller x-height, so the text looks smaller than the exemplar. The 12-point minimum is met. Matching the filer's Times would be tier 3 and is not chased.
5. **Certificate of service.** Printed as filed (ECF manner, signer, no date and no address). See the note under Governing rules: LR 5.1(d) requires more for conventional service.
6. **Signature and date.** The date line is in the frontmatter (`signature.date`). The template does not check the date or the signer.
7. **Judge initials suffix (LR 5.1(c)).** `case_number` is printed as given (`Civil No. 26-cv-600-LM-TSM`). The template does not add the suffix.
8. **ECF header.** The filed PDF carries the ECF header on each page; the template does not add it.
9. **Heading style.** Level 2 headings are bold flush left without a hanging indent, so a long heading wraps under its numeral. The filing's headings are similar; recorded as ACCEPTED.
10. **Keep-with-next.** A heading is kept with the paragraph after it, so a page may end with white space (page 7 of the render). This is intentional.
11. **Typst warnings.** None: `tools/render.sh` treats any warning as a failure, and the render passed.
12. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The render and overlay were run; the page review below is the Gate 2 equivalent for this doc type.
13. **File names.** The samples are `INPUT-<id>.md` and the outputs are `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, because `tools/render.sh` and `tools/overlay.sh` write these names and the brief forbids editing `tools/`.

## Review of the rendered pages (`OUTPUT-nhd-motion-brief-jonas.typst.pdf`, 60 dpi)

- Page 1: court title, caption with the ")" column and `Civil No.`, title in bold caps, the opening paragraph (NOW COME). No spill. Pass.
- Pages 2 to 4: INTRODUCTION, BACKGROUND, the list (a) to (d) with hanging indent (it breaks between pages 3 and 4). No overlap. Pass.
- Pages 4 to 5: remaining Background paragraphs, STANDARD OF REVIEW. Pass.
- Pages 6 to 12: ARGUMENT, I (level 2), A, B and the level 4 headings i. to iv., with their paragraphs; keep-with-next leaves white space at the foot of page 7. Pass.
- Pages 13 to 16: C (level 3); the civil-penalty and declaratory-judgment paragraphs of the Eleventh Amendment argument (the transcription resumes there, with pages 14 to 21 of the filing omitted); III; CONCLUSION. Pass.
- Page 17: the signature block (`Respectfully submitted,`, party lines, `By and through their counsel`, the Attorney General's name, date, `/s/` line, the counsel block). Pass.
- Page 18: CERTIFICATE OF SERVICE, the paragraph, the signer's lines at the right half. Pass.

Defects found in review and fixed (kept here so the template does not regress): heading blocks collapsed to zero height and overlapped the text around them (fixed by moving the heading gap into the flow and keeping `below` non-zero); paragraph blocks lost one line of leading between each other (fixed by a trailing one-pitch gap); headings rendered at typst's default heading size (pinned to the body size); the caption's long party names wrapped and broke the ")" column (the names are split into lines in the frontmatter); the signature block's wrapped lines took the double leading (single leading is now set inside the single-spaced line stack).

## Engines

docx (`docx/build-reference.sh` builds `docx/reference.docx`; filter `docx/nhd-motion-brief.lua`): `usage/OUTPUT-nhd-motion-brief-jonas.docx` and `OUTPUT-nhd-motion-brief-jonas.docx.pdf` (LibreOffice conversion). Matches typst: EB Garamond; exact 27.6 pt body pitch; the three-column caption with the ")" column and the case number on the middle row; the centered caps heading forms; the certificate of service; the signature block. Page count matches (18 and 18). Word was not available; the file was checked with LibreOffice only.

- BLOCKED: pagination from page 1. In typst page 1 ends after "NOW COME ..." and INTRODUCTION starts page 2; the docx starts INTRODUCTION on page 1. The page breaks differ from there on, though the total is the same at 18 pages. Keep-together and keep-with-next behaviour of typst's blocks is not reproduced.
- The signature block is an all-caps stacked block at the 3.25 in indent in the docx, and a more compact block in typst; both sit on page 17.

[Formbook index](../../../../../../README.md)
