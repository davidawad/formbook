# nmd: motion-brief

Doc type: **motion with its supporting argument** (a Rule 12(b) motion to dismiss that carries its memorandum in the same document) in the United States District Court for the District of New Mexico (`nmd`).
Folder: `courts/tenth-circuit/new-mexico/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, counsel-filed; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole 13-page motion, with its footnote 1 omitted; see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-turner-motion.pdf` and `OVERLAY-turner-motion.txt` (`tools/overlay.sh`) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the sample id is the `.md` name). The brief's `<id>-overlay` names are not what `tools/overlay.sh` writes, so the tool's names are used.

## Governing rules

Primary sources, fetched 2026-10-14. Each rule's text was read in the source; the quoted phrases are from those texts.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.M.LR-Civ. 7.1(a) | "A motion must be in writing and state with particularity the grounds and the relief sought." "Movant must determine whether a motion is opposed, and a motion that omits recitation of a good-faith request for concurrence may be summarily denied." Source: https://www.nmd.uscourts.gov/sites/nmd/files/local_rules/Local%20Rules%20of%20Civil%20Procedure%20Adopted%20October%201%2C%202020_0.pdf (Local Rules of Civil Procedure, "Amended Effective October 1, 2020"; index https://www.nmd.uscourts.gov/court-info/local-rules-and-orders/local-rules). | Sample content (the introduction states the concurrence). The template does not check the wording. |
| D.N.M.LR-Civ. 7.1(b) | "A motion, response, or reply must include a certificate of service on each party." | `certificate-block()`: a required `certificate` (text, the service list, and the signer lines). The template fails without it. |
| D.N.M.LR-Civ. 7.5 | The combined length of a motion and its supporting brief must not exceed 27 double-spaced pages (a response 24; a reply 12). | Not checked by the template. The sample is 11 pages. See Known gaps. |
| D.N.M.LR-Civ. 7.6 | Motions are decided on the briefs unless the Court orders a hearing; no hearing information is required on the caption. | No hearing block in `caption()`. |
| D.N.M.LR-Civ. 10.1 (Form) | 8½ × 11 white paper, one side; typewritten "at least 12 pitch", letter quality; margins: left, right and bottom at least 1 inch, **top at least 1½ inches**; text double spaced except footnotes and quotations; **first page has the case file number and initials of the assigned judges**. | `margins` (top 1.5 in; others 1 in); double spacing (`pitch` 24 pt; `body-leading` for line leading and paragraph spacing); `case_number` on page 1 (the sample has `JMR/GJF`, as the filing does). |
| D.N.M.LR-Civ. 10.2 (Titles) | "The title of a document must clearly identify its substance and any filed document to which it responds or is connected." | `brief_title` (sample content: the title names the motion and the amended complaint it answers, with its docket entry "[Doc. 1-1]"). |
| D.N.M.LR-Civ. 83.4(a) | An attorney's entry of appearance (and the initial pleading it signs) gives name, firm name, address, telephone number, electronic address and facsimile number; the attorney signs the initial pleading. | `signature-block()`: `signature.firm`, `signature.blocks`, `signature.attorneys_for`. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion, "(B) state with particularity the grounds for seeking the order; and (C) state the relief sought." Fetched from https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Content (the sample's introduction and conclusion state the grounds and relief). |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, and Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | `court-title()`, `caption()`, `cover()`. |
| Fed. R. Civ. P. 11(a) | Every written motion must be signed by an attorney of record, who must state the signer's address, e-mail address, and telephone number. Fetched from https://www.law.cornell.edu/rules/frcp/rule_11 on 2026-10-14. | `signature-block()`. |

## Layout

- Letter paper, top margin 1½ in, other margins 1 in. Page numbers centered in the bottom margin, Arabic from 1 on page 1 (the exemplar's running footer is an ECF stamp, not part of the document, and is not reproduced).
- Court title (two lines, centered, bold) at the top of page 1; caption with ")" marks: parties on the left, "Case No. …" on the right; the title centered, bold, in the sample's own capitalization below the caption.
- Body text 12 pt EB Garamond, double spaced at a 24 pt pitch (measured: 24.00 pt between every pair of body lines), first-line indent ½ in, left aligned, unnumbered.
- Headings: level 1 centered bold caps (INTRODUCTION AND PROCEDURAL HISTORY, FACTUAL BACKGROUND, LEGAL STANDARDS, ARGUMENT, CONCLUSION); level 2 a bold roman-numeral argument heading ("I. …") hanging from the numeral; level 3 a bold lettered sub-heading ("a. …") hanging from the letter. Headings are single spaced, kept with the paragraph after them.
- No table of contents or table of authorities: the D.N.M. rules cited do not require them for a motion of this length, and the exemplar has none.
- Signature block at the right of the page, single spaced, kept together; then the certificate of service (centered heading, double-spaced statement, single-spaced service list, signer lines at the right).

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1), `##` (level 2, argument heading), `###` (level 3, lettered sub-heading), or a paragraph (first-line indent, not numbered).
- Frontmatter fields: `case_number` (with the assigned judges' initials after it), `court` (lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title` (given in the sample's own capitalization), `signature` (`firm` lines, `blocks` (a list of line lists, one per attorney group), `attorneys_for`), `certificate` (`text`, `served` (a list of line lists, one per served party or group), `signed` (lines)).
- Not supported: footnotes (cmarker renders them as an inline note), tables, raw typst.

## Overlay

`usage/OVERLAY-turner-motion.pdf`: each page of our render is shown in red and paired with the filed page sharing the most words (blue; black where they agree). The pairing is by text, not by index. The page map is in `OVERLAY-turner-motion.txt`:

```
ours p.1  filed p.1  word-overlap 95.7%
ours p.2  filed p.2  word-overlap 69.0%
ours p.3  filed p.3  word-overlap 56.2%
ours p.4  filed p.5  word-overlap 46.0%
ours p.5  filed p.6  word-overlap 57.5%
ours p.6  filed p.7  word-overlap 74.1%
ours p.7  filed p.8  word-overlap 84.3%
ours p.8  filed p.9  word-overlap 81.7%
ours p.9  filed p.10 word-overlap 62.1%
ours p.10 filed p.11 word-overlap 59.5%
ours p.11 filed p.12 word-overlap 54.4%
```

The overlay is a diagnostic, not a score. The filed document has 13 pages and the render 11; filed page 13 (the last names of the service list) has no render pair. The filed pages carry an ECF header and a "MOTION TO DISMISS PAGE x OF 13" footer, which add words our render does not have, so the lower overlaps (ours p.4, p.11) come from those words and from the different page breaks, not from a layout difference.

## Review of the rendered pages (final render)

Every page was rendered at 60 dpi and viewed.

- Page 1: court title, caption (plaintiffs and defendants with ")" marks), "Case No. 1:26-cv-03220 JMR/GJF", the title on two lines in caps with "[Doc. 1-1]" in the sample's capitalization; INTRODUCTION AND PROCEDURAL HISTORY; first two paragraphs. Pass.
- Page 2: the rest of the introduction; FACTUAL BACKGROUND (centered); the first paragraphs of facts. Pass.
- Page 3: facts (the Amended Complaint's structure). Pass.
- Page 4: the end of the introduction (the paragraph stating the relief sought); LEGAL STANDARDS (centered); "a. Rule 12(b)(6) and Rule 8" (hanging, bold); two paragraphs of the standard. Pass.
- Page 5: the standard continues; "b. Rule 12(b)(1)" (hanging). Pass.
- Page 6: "c. 28 U.S.C. § 1654" and "d. Rule 42(b)"; ARGUMENT (centered); "I." heading hanging over three lines; "a." sub-heading. Pass.
- Page 7: argument I.a continues; "b. Plaintiffs fail to state a § 1983 claim against the City." Pass.
- Page 8: argument I.b continues; "c. …" heading over two lines. Pass.
- Page 9: the end of I.c; "II." heading over three lines; "III." heading. Pass.
- Page 10: "IV." heading; CONCLUSION (centered); the conclusion's three paragraphs. Pass.
- Page 11: the signature block ("Respectfully submitted," the firm, the attorneys with bar numbers, contact lines, "Attorneys for Defendant City of Rio Rancho") at the right; CERTIFICATE OF SERVICE; the statement; the service list; the signer lines at the right. Pass.

Measured: body line pitch 24.00 pt; 100 characters per full 6.5 in line (about 15 characters per inch, above the "at least 12 pitch" minimum).

## Known gaps and open choices

1. **One exemplar, one filer.** The tier-2 rule asks for 2 or 3 filers. Searched: CourtListener RECAP (`type=r`, `court=nmd`, motions to dismiss with a memorandum, 2016 to 2026). Downloaded and text-checked: Turner v. City of Rio Rancho, 1:26-cv-03220 (saved). Other D.N.M. motions seen but not downloaded: McCombs v. Delta Group Electronics, Inc., 1:22-cv-00662 (docket 65307716); Serna v. County of Bernalillo Sheriff's Department, 1:23-cv-00254 (docket 67163945). Tier 2 is therefore **not** judged against two filers yet.
2. **Footnote 1 is omitted.** cmarker renders a markdown footnote as an inline note, not a page footnote, so the template does not support footnotes. The footnote on filed page 2 (the citation convention for the page numbers of the amended complaint) is not transcribed; the sample's frontmatter comment says so.
3. **Italics.** The exemplar's text layer has no italic markup, so case names are roman (for example *Gallegos*, *Twombly*). The template italicizes `*...*` markdown, so a future sample can carry italics; the convention in a clerk's copy is italic case names.
4. **Combined length.** LR 7.5 limits the motion and its supporting brief together to 27 double-spaced pages. The template does not count pages or subtract the caption, signature and certificate; the sample is 11 pages, well within the limit.
5. **One document, no separate memorandum template.** This filing puts its argument in the motion. A separate memorandum brief (as in some other D.N.M. filings) would need its own template; none is built here.
6. **The certificate of service** wording and the service list are sample content. LR 7.1(b) requires the certificate, not particular words.
7. **Ragged right.** Body text is left aligned. The exemplar's justification could not be read from its text layer; this is a tier-2/3 choice and is not asserted.
8. **Heading spacing.** A sub-heading is single spaced with 12 pt above and below; the paragraph after a lettered sub-heading sits close to it in the render. This is a readable convention, not a rule.
9. **Font.** Same as the complaint: 12 pt EB Garamond (the only serif vendored in `fonts/`). EB Garamond has a smaller x-height than Times, so the text looks smaller than the exemplar. The 12-point minimum is met; whether the court wants a larger apparent size is a question for David.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court root, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

[Formbook index](../../../../../../README.md)

## Engines

DOCX (`docx/`): `reference.docx` is built by `docx/build-reference.sh` from pandoc's default reference. It matches the typst form on the same points: EB Garamond 12 pt, 24 pt exact line pitch for the body, 0.5 in first-line indent, top margin 1.5 in and 1 in elsewhere, letter page, centered bold capitals for level 1 headings, bold single-spaced hanging headings (0.5 in) for levels 2 and 3, centered PAGE number 0.45 in from the bottom edge. `docx/nmd.lua` builds the cover (court, caption table with ")" marks, case number, title), the body (not numbered), the signature block ("Respectfully submitted," and the attorney blocks) and the certificate of service from the sample frontmatter.

What differs: the caption, signature block and certificate lists are borderless tables or single-spaced paragraphs, which Word and LibreOffice may space slightly differently; footnotes are 12 pt single-spaced (the typst template sets no footnote style, so none is verified against it); the frontmatter `footer_title` is not used, as in the typst template.

BLOCKED (docx): `docx.pdf` is not produced because `soffice` (LibreOffice) is not installed on this box, so Gates 0 and 1 cannot run on the rendered PDF; the visual review of the docx pages has not been done (no docx page viewed); the open-without-repair check in Word and LibreOffice has not been done. The `.docx` itself passes `unzip -tq` and the well-formedness check of every XML part.
