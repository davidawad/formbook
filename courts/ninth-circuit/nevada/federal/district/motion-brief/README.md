# nvd: motion to dismiss with memorandum (motion-brief)

Doc type: **motion** under Fed. R. Civ. P. 12(b)(6), with its memorandum of points and authorities, combined in one filed document, in the United States District Court for the District of Nevada (`nvd`).
Folder: `courts/ninth-circuit/nevada/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-lynch-2-26-cv-00895-motion-brief.pdf` (one filer, see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-lynch-motion-to-dismiss.md` (the whole 11-page motion: motion, memorandum, conclusion, signature, certificate of service) |
| typeface | face required: **none** (LR IA 10-1(a)(3) sets size only: "Text must be size 12 font or larger"; read 2026-10-15 from the court's 2020 local rules PDF). Substitute: none needed; **EB Garamond** kept (no-face default, `docs/FONTS.md`). Fit: n/a. Embedded: EBGaramond Regular, Bold, Italic (`pdffonts`). |
| render | ok: `samples/OUTPUT-lynch-motion-to-dismiss.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-15) |
| overlay | ok: `samples/OVERLAY-lynch-motion-to-dismiss.pdf` and `.txt` (pairing by word overlap; see below; re-run 2026-10-15) |
| pages reviewed | 11 of 11 (every page rasterized at 60 dpi and viewed on 2026-10-15) |
| BLOCKED | none. Tier-2 coverage is short of the eval loop's "two or three filers" (see Known gaps 1). |

## Governing rules

Primary source for the local rules: **D. Nev. Local Rules of Practice** (amended 2020; PDF modified 2025-07-30), https://www.nvd.uscourts.gov/wp-content/uploads/2020/04/Local-Rules-of-Practice-Amended-2020.pdf, fetched and read 2026-10-14. The courtrules.net mirror was not used: its text was out of date for LR 7-3 (it gives 30 pages; the court's PDF gives 24 pages for motions other than summary judgment).

Federal rules: Fed. R. Civ. P. 12(b) (LII text, https://www.law.cornell.edu/rules/frcp/rule_12, no "current through" date on the page), fetched 2026-10-14. Fed. R. Civ. P. 5(d)(1)(B) (https://www.law.cornell.edu/rules/frcp/rule_5), fetched 2026-10-14, for the certificate of service.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NVD-MOT-001 | LR 7-2(a) | A motion must be supported by a memorandum of points and authorities; "The motion and supporting memorandum of points and authorities must be combined into a single document that complies with the page limits in LR 7-3." | One document: `memorandum()` follows the motion's opening paragraphs in one flow |
| NVD-MOT-002 | LR 7-3(b) | Motions other than summary judgment: 24 pages, excluding exhibits. | Not enforced by the template (no page counter); the sample is 11 pages |
| NVD-MOT-003 | LR 7-2(d) | Failure to file points and authorities in opposition constitutes consent. | Not a template matter; recorded for the author |
| NVD-FORM-001 | LR IA 10-1(a)(1) | Double-spaced lines of text; lines numbered consecutively from 1 on the left margin of each page, no more than 28 per page. The caption, the court title, the case name and quotations are exempt from double spacing. | `lines-per-page = 28`, `pitch`, `line-numbers()` |
| NVD-FORM-002 | LR IA 10-1(a)(2) | Legible, one side of each page. | PDF output is one-sided |
| NVD-FORM-003 | LR IA 10-1(a)(3) | Text 12 point or larger. | `type-size = 13pt` (see Known gaps 2); footer 12 pt |
| NVD-FORM-004 | LR IA 10-1(a)(4) | Quotations over 50 words indented and single spaced. | `memorandum()`: a `>` quotation is single spaced and indented 0.5 in on both sides |
| NVD-FORM-005 | LR IA 10-1(a)(5) | All pages numbered consecutively. | `footer-block()`, plain page number |
| NVD-FORM-006 | LR IA 10-1(a)(6) | Margins at least one inch on all four sides. | `top-margin = 1in`, `bottom-margin = 1in`; `pitch` is set so the 28 lines fit between them (Known gaps 3) |
| NVD-FORM-007 | LR IA 10-1(c) | 8½ × 11 inch paper (manual filing). | `page-w`, `page-h`, `paper: "us-letter"` |
| NVD-FIRST-001 | LR IA 10-2 | First page: attorney's name beginning at least one inch below the top; name, Nevada bar number, address, phone, email, party represented. | `counsel` frontmatter, from line 1 at the top margin |
| NVD-FIRST-002 | LR IA 10-2 | Court title "UNITED STATES DISTRICT COURT / DISTRICT OF NEVADA"; caption with parties at left and case number and document title at right. | `court-title()`, `caption()` |
| NVD-FILE-001 | LR 7.1-1 | Disclosure statement with the first appearance, pleading, petition, motion, response or other request. | Not generated: a separate filing. Defendant has appeared (its first filing was the Notice of Removal, ECF No. 1 in this case), so this is a question for the author, not the template. |
| NVD-FILE-002 | FRCP 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | The sample includes the certificate, as in the exemplar. `certificate-block()` renders it on its own page after the signature. |

Not produced by this template: the proposed order (LR 7-2(f) applies only if the court instructs one); declarations or exhibits; the index of exhibits.

## Layout

- Numbered lines 1 to 28 down the left margin on a grid of 9 in / 28 = 23.14 pt, starting at the top margin. Double rule at the text's left edge, single rule at its right (the pleading form).
- First page: counsel block single-spaced from line 1; a blank numbered line; the court title (bold, two lines); a blank line; the caption box (parties at left with a rule at right and bottom, separator "vs."; "Case No." and the title at right). The motion begins on the same page, after a blank line, with no page break (as in the exemplar).
- Memorandum: paragraphs double spaced with a 0.5 in first-line indent and not numbered. Headings: level 1 centered bold caps (MEMORANDUM OF POINTS AND AUTHORITIES); level 2 bold with its roman numeral, hanging when it wraps (I., II., III.); level 3 bold with its letter, hanging (A., B., C., D.). A heading is sticky: it stays with the block after it, so it never ends a page, and a long paragraph can still break across pages.
- Quotations: single spaced, indented 0.5 in on both sides, measured at the indented width so the grid stays exact.
- Signature block: "Dated this ..." then the firm, "By: /s/" the signer and the signer's lines, at 2.6 in from the left.
- Certificate of service: its own page after the signature; the paragraph, the service list (single spaced, indented) and the employee signature.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are blank-line separated: a `#` heading (level 1), `##` (level 2), `###` (level 3), a `1.` list, a `>` quotation (its lines may hold several paragraphs separated by a `>` line), or a paragraph (unnumbered, first-line indent).
- Frontmatter: `case_number`, `counsel` (lines; an empty string gives a blank line), `caption` (`separator` optional, default "v."; `parties` as a list of `{names, designation}`), `brief_title`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate` (`paragraphs`, `recipients`, `signer`, `lines`; optional).
- Escape a literal asterisk that is not emphasis as `\*` (the sample uses `\*3-4` and `\*17` for Westlaw/Lexis pin cites).
- Do not number the paragraphs or the headings in the text.

## Samples and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
D=courts/ninth-circuit/nevada/federal/district/motion-brief
sh tools/render.sh $D samples/INPUT-lynch-motion-to-dismiss.md   # -> samples/OUTPUT-lynch-motion-to-dismiss.pdf
sh tools/overlay.sh $D lynch-motion-to-dismiss                   # -> samples/OVERLAY-lynch-motion-to-dismiss.pdf and .txt
```

Naming: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, with the sample named `INPUT-<id>.md`; these follow the `tools/render.sh` and `tools/overlay.sh` defaults, which are not changed here.

- `samples/OVERLAY-lynch-motion-to-dismiss.pdf`: red = our render, blue = exemplar, black = both. The page map (`.txt`) pairs each of our 11 pages with the exemplar page of the same number (word overlap 54 to 96 per cent). The overlay is a diagnostic, not a score: the exemplar's line numbers and Times text do not coincide with ours, and the ECF header is not reproduced.

## Visual review (Gate 2 record: every page rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block (lines 1 to 10), court title, caption with "vs.", title at right, motion opening | OK. |
| 2 | MEMORANDUM heading, I. INTRODUCTION with A. and B., paragraphs | OK. Headings follow the exemplar's line-to-line spacing. |
| 3 | II. heading (two lines, hanging), the 12(b) quotation, the standard of review | OK after the fix: the quotation's last line had overlapped the next paragraph (its height was measured at full width, not the indented width). Now measured at the indented width and re-checked. |
| 4 | Standard of review continued; the Iqbal block quotation; "Id. at 1950." | OK. |
| 5 | III. A. heading (three lines), NRS 38.310 quotation (numbered items 1 and 2), NRS 116.31181 quotation with items (a) to (c) | OK after the fix: the (a) to (c) items had overlapped; now measured and re-checked. |
| 6 | Continuation of A.; B. heading and its first paragraph | OK. The earlier blank block at the foot of this page is gone (the sticky heading now stays with a breakable paragraph). |
| 7 | B. continued (the facts paragraph) | OK. Four blank lines at the foot: the C. heading moved to the next page with its text (intended, heading kept with text). |
| 8 | C. heading (three lines), statute quotation, the authority paragraphs | OK. |
| 9 | C. continued; D. heading (two lines) and IIED paragraphs | OK. |
| 10 | Continuation of D.; III. CONCLUSION; "Dated this 6th day of April, 2026."; firm and signature block | OK. |
| 11 | CERTIFICATE OF SERVICE on its own page: paragraph, service list, employee signature | OK. |

Reviewed pages: 11 of 11.

## Known gaps and open choices

1. **One filer only.** The eval loop asks for two or three exemplars from different filers before tier 2 is judged. Searches (CourtListener RECAP API, `type=r`, `court=nvd`, motions to dismiss filed 2025-06 to 2026-10): Advanced Solution v. New Horizon (2:26-cv-00958, 9 pp., Wiley Petersen), Logan v. Citizen's Bank (2:26-cv-00887, 9 pp., Malcolm Cisneros), Browning v. Station Casinos (2:26-cv-00603, 31 pp.) and Riskon v. Zest Labs (2:25-cv-02042, 33 pp.) were found; only the first two are short enough to compare. Both were downloaded and checked for a text layer, but not saved as exemplars or compared in full. Tier 2 is therefore **not** judged against a second filer yet.
2. **Type size.** The rule requires 12 pt or larger (LR IA 10-1(a)(3)). Body text is 13 pt EB Garamond (the rule names no face, so EB Garamond stays; see the typeface row), chosen so it reads at about the size of the exemplar's 12 pt Times New Roman. EB Garamond at 12 pt would be the minimum-compliant alternative.
3. **Line pitch.** The exemplar uses a 24 pt grid, so its 28th line sits at about 10.3 in, which breaches the one-inch bottom margin (LR IA 10-1(a)(6)). This template fits the 28 lines between the one-inch margins (pitch 23.14 pt). **This departs from the exemplar's grid; David should confirm the reading.** The same choice is made in the complaint template.
4. **Filed errors kept as filed.** The exemplar cites "Fed. R. Civ. P. 12(b)(5)" in I.B (the motion relies on 12(b)(6)), says "that tenant 'is inapplicable'" (for "tenet"), . The sample keeps them so that the overlay matches the filing. The author should correct them before filing a version of their own.
5. **Case names italic.** Italics are applied to case names, *Id.*, and signals in the sample following standard citation form. The exemplar's text layer has no italic markup; the rendered page images show italics for case names in the exemplar. The italics in the sample are a transcription convention, not a check of every italic in the exemplar.
6. **Page limit (LR 7-3(b)).** 24 pages for this motion; the template does not count pages. The sample is 11 pages.
7. **Disclosure statement (LR 7.1-1).** Not generated; the defendant has already appeared in this action, so the statement is for the author to decide whether it is due with this filing.
8. **Judge standing orders** can change the form. Not reflected.
9. **Certificate language.** The exemplar's certificate cites NRCP 5(b) and NEFCR 9. Those rules are not in the D. Nev. Local Rules text reviewed; the sample reproduces the exemplar's text as filed and the template does not check the citation.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder under the district court, so the gates were not run and no pass stamp is written. The brief also forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

[Parent: nevada/federal/district](../README.md)
