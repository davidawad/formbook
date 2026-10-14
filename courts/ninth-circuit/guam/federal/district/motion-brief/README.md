# gud (District Court of Guam): motion-brief

Doc type: **motion-brief**, a Rule 12 motion with its memorandum, in the United States District Court of Guam (`gud`). The exemplar is a memorandum in support of a Rule 12(b)(6) and 12(f) motion to dismiss or strike a counterclaim.
Folder: `courts/ninth-circuit/guam/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-leon-guerrero-25-cv-00030-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-leon-guerrero-memorandum.md` (full transcription of the 12-page memorandum, Doc. 13-1; footnotes 1 and 2 not transcribed, see gaps) |
| render | ok: `samples/OUTPUT-leon-guerrero-memorandum.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-leon-guerrero-memorandum.pdf` and `samples/OVERLAY-leon-guerrero-memorandum.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed) |

Tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the names in `tools/`); the brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools write, so the tool names are used.

## Governing rules

Primary source: **General Local Rules of Practice for the District Court of Guam, effective April 19, 2022 ("GNLR")**, https://www.gud.uscourts.gov/sites/gud/files/General%20Local%20Rules%2020220419%20final_0.pdf, fetched and read 2026-10-14. This is the newest version found; it is not confirmed as current.

Federal rules, text from the Legal Information Institute mirror, fetched 2026-10-14: FRCP 5 https://www.law.cornell.edu/rules/frcp/rule_5, FRCP 7 https://www.law.cornell.edu/rules/frcp/rule_7, FRCP 10 https://www.law.cornell.edu/rules/frcp/rule_10, FRCP 12 https://www.law.cornell.edu/rules/frcp/rule_12.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| GNLR 5.1(a) | White paper, 8 1/2 x 11 in.; all papers double-spaced except counsel identification, title of the case, footnotes, quotations and exhibits; all pages numbered consecutively at the bottom. | `page-w`, `page-h`; `body-leading` (24 pt pitch); page number centred in the footer. |
| GNLR 5.1(b) | Court title centred, commencing not less than three inches from the top of the page. | `counsel-block`: a box from the top margin to 3 in.; a longer counsel block pushes the court title down (one line of clearance), never up. |
| GNLR 5.1(c)(1) | Counsel name, address and telephone at the upper left; space right of centre reserved for the clerk's filing stamp. | `counsel-w` = 3.25 in. (the page centre is 4.25 in. from the left edge); the caption's right column starts at 4.5 in. |
| GNLR 5.1(c)(2) | Title of the action below and to the left of the court title. | `caption-left`: all parties, `between` word ("v.") from the sample. |
| GNLR 5.1(c)(3) | Right of the title of the action: file number, civil designation, brief description, and a mention of any notice of motion or memorandum in support. | `caption-right`: `case_number`, `designation` ("CIVIL"), `case_notes`, `brief_title` ("MEMORANDUM IN SUPPORT OF MOTION ..."), `brief_subtitle` (the Rule 12 grounds). |
| GNLR 5.1(c)(4) | Cover sheets accompany documents initiating civil actions. | Not applicable: a motion-brief is not an initiating document. |
| FRCP 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. | Content (the author's), not checked by the template. The memorandum's "Introduction" states the three grounds and the relief. |
| FRCP 10(a) | Caption: court name, title, file number, Rule 7(a) designation. | `court_title`, `caption`. |
| FRCP 12(b)(6), 12(f) | Defences of failure to state a claim, and motions to strike redundant or immaterial matter. | Named in `brief_subtitle`. |
| FRCP 5(d)(1)(B) | No certificate of service is required for a paper served through the court's e-filing system. | Certificate is a body section in the sample (the exemplar has one); `<!-- single -->` keeps its addresses single-spaced; a heading beginning "CERTIFICATE" starts a new page. |

GNLR 2022 contains no page limit, no memorandum-length rule, no typeface or point-size rule, and no motion-format rule beyond GNLR 5.1 (GNLR 10.1 sets the motion day only). None of those is asserted here. Local practice may add them; the current rules should be checked before the template is called final.

## Layout

- Counsel block (ten lines in the exemplar, two of them wrapped) single-spaced in the upper left; the court title is pushed down to 3.19 in. because the counsel block is taller than the 2 in. box (GNLR 5.1(b) allows it); court title bold, centred, one line in the exemplar.
- Caption: parties left, with "v." between; file number, "CIVIL", the notice of the removal (`case_notes`), the bold title and the Rule 12 grounds right.
- Body double-spaced (24 pt pitch, measured on the PDF), first-line indent 0.5 in., unnumbered paragraphs.
- Headings: level 1 centred bold capitals (`I. INTRODUCTION`, `II. ARGUMENT`, `III. CONCLUSION`); level 2 bold, left (`A.`, `B.`, `C.`). A heading is kept with the paragraph after it.
- Signature block: "Respectfully submitted this ... day of ..." then the firm, "/s/" signer and lines, starting 3 in. from the left margin. Placed where the sample has `<!-- signature -->` (after the conclusion, and again after the certificate), or at the end if the sample has no marker.
- Certificate of service: a new page; addresses single-spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `designation`, `case_notes` (list, optional), `court_title` (list of lines), `caption` (`between`, `parties` as `{names: [...], designation}`), `brief_title`, `brief_subtitle` (optional), `counsel` (list of single-spaced lines), `date`, `signature` (`firm`, `signer`, `lines`).
- Body: `# I. HEADING` (level 1), `## A. Heading` (level 2); a blank-line-separated paragraph is an unnumbered body paragraph; a markdown list is lettered (a), (b), ...
- Markers: `<!-- signature -->` (the signature block goes here); `<!-- single -->` at the start of a chunk keeps its lines single-spaced (addresses).
- Italics as `*...*` (case names, *Id.*, signals). Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this is not met. Candidates seen and not saved: *Prutehi Guahan v. U.S. Department of the Air Force*, 1:22-cv-00001, Doc. 19 (a motion to dismiss on the RECAP index; not downloaded). *Develles v. Government of Guam*, 1:24-cv-00019, Doc. 45 (a motion to dismiss, but the RECAP PDF is a one-page scan with no text layer; not usable). *Guam Visitors Bureau*, 1:26-cv-00017, Doc. 20 (a first motion to dismiss for lack of jurisdiction, 12 pages, a scan with no text layer; not usable).
2. **Only the memorandum (Doc. 13-1) is the exemplar.** The motion itself (Doc. 13, 3 pages, same counsel, same caption) is not transcribed or saved. The template renders the caption, the memorandum and the certificate; a standalone motion would use the same chrome with its own body.
3. **Footnotes not transcribed.** The exemplar has footnote 1 (the Citizen Participation in Government Act, on its page 9) and footnote 2 (the SLAPP argument, 7 GCA § 17101 et seq., on its page 11). The template has no footnote support, and the sample omits both, so the transcription is not complete at those two places.
4. **Typeface.** EB Garamond (the only vendored font). The exemplar is Times New Roman; the same reasoning as the complaint applies (see `../complaint/README.md`, gap 2).
5. **Italics are supplied by the transcription.** The exemplar's text layer has no italic markup; case names and signals are italicised by the transcriber, following the usual convention. Not checked against the filed typography.
6. **Emphasis lost.** The memorandum says "(emphasis added)" in two places; the emphasis is not in the text layer and is not reproduced.
7. **Caption.** No ")" column and no rules; the exemplar has none either. ACCEPTED.
8. **Left-aligned** (ragged right), as in the complaint.
9. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids editing `tools/`. Render, overlay and the page review are the checks run here. No check stamp is written.
10. **Line pitch and clearance** are measured on the PDF: counsel lines 13.8 pt, body 24.0 pt, the first line of the court title 3.19 in. from the top of the page (clear of the counsel block).

## Review of the rendered pages (Gate 2 equivalent)

Rendered at 60 dpi, every page viewed, after the last template change:

- Page 1: counsel block top left, single-spaced, ending above the court title; court title "IN THE UNITED STATES DISTRICT COURT OF GUAM" bold, centred; caption with the parties left and the file number, civil designation, removal notice, bold title and Rule 12 grounds right; heading I and the first paragraphs. **Pass.** (The first render overlapped the last counsel line with the court title; the counsel-block clearance fixed it.)
- Page 2: heading II, A., paragraphs with the italic case names and signals. **Pass.**
- Page 3: paragraphs continuing A. **Pass.**
- Page 4: paragraphs of A. to B.; heading B. (two lines) kept with its paragraph. **Pass.**
- Page 5: paragraphs of B. (Rule 12(f) and the cases). **Pass.**
- Page 6: paragraphs of B.; "as follows:" ends the page. **Pass.**
- Page 7: the counterclaim paragraphs summarised as "123 –" to "129 –" lines, and the *Id.* line. **Pass.**
- Page 8: the affirmative-defense paragraphs ("82 –" to "116 –"); the end of B.; heading C. **Pass.**
- Page 9: C. (*Noerr-Pennington*, with the italic doctrine name in the heading and the body). **Pass.**
- Page 10: C. end; heading III, CONCLUSION; signature block (firm, "/s/ Leslie A. Travis", the signer's lines). **Pass.**
- Page 11: CERTIFICATE OF SERVICE on its own page; the two addresses single-spaced; the signature block again. **Pass.**

Tier 2 is **not** judged (one filer only; see gap 1). OPEN items for tier 2: the second exemplar (gap 1), the footnotes (gap 3), the typeface (gap 4).
