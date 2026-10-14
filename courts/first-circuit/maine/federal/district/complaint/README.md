# med: complaint

Doc type: **complaint** in the United States District Court for the District of Maine (`med`).
Folder: `courts/first-circuit/maine/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: 2 filers. `exemplars/FILED-EXAMPLE-taco-barr-2-26-cv-00470-complaint.pdf` (primary, transcribed) and `exemplars/FILED-EXAMPLE-gagne-2-26-cv-00301-complaint.pdf` (second filer, compared on caption and signature block). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-taco-barr-complaint.md`: the whole body of the 11-page filing (caption, all 53 numbered paragraphs, claims, prayer, jury demand, signature), transcribed from the text layer. ECF header lines and the exhibits are not included. |
| render | ok: `samples/OUTPUT-taco-barr-complaint.pdf`, 9 pages, `tools/render.sh` with typst 0.15.0, vendored EB Garamond only, no typst warnings (exit 0). |
| overlay | ok: `samples/OVERLAY-taco-barr-complaint.pdf` and `samples/OVERLAY-taco-barr-complaint.txt` (against the primary exemplar). |
| pages reviewed | 9 of 9: every page rendered at 60 dpi and viewed in its final state. |
| certificate | none in the exemplar; none in the template (not needed for a complaint, see the rules below). |

File names: the brief asked for `samples/<id>.md`; the repo's file-role names are used instead (`INPUT-<id>.md` in, `OUTPUT-<id>.pdf` out, `OVERLAY-<id>.pdf/.txt`), because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Primary source: **District of Maine Local Rules, "current as of April 1, 2025"**, https://www.med.uscourts.gov/sites/med/files/LocalRules.pdf, read in full 2026-10-14 (the court site rejects direct downloads; the text was taken from the PDF the fetch tool returned). Federal rules: Fed. R. Civ. P. 10(a), 10(b), 11(a) from https://www.law.cornell.edu/rules/frcp/rule_10 and https://www.law.cornell.edu/rules/frcp/rule_11, verified 2026-10-14. Fed. R. Civ. P. 5(d)(1)(B) from https://www.law.cornell.edu/rules/frcp/rule_5, verified 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Me. LR 10(a) | Caption with the case number on the first page; the title and the filing party immediately under the caption. | `court-title()`, `caption()`, `title-block()` in `typst/med-complaint.typ`. |
| D. Me. LR 10(b)(1) | Typewritten, 12-point font or larger (footnotes 10-point or larger). | `type-size = 13pt` (see Known gaps). The complaint has no footnotes. |
| D. Me. LR 10(b)(2) | Text double-spaced; block quotes, headings and footnotes may be single-spaced. | `body-leading = 27.6pt - 0.65em` (27.6 pt baseline pitch, the pitch the filed exemplars measure); block quotes and caption single-spaced. |
| D. Me. LR 10(b)(3) | Each page 8 1/2 x 11 inches. | `paper: "us-letter"`. |
| D. Me. LR 10(b)(4) | Each page numbered at the bottom. | `footer` in `med-complaint()`. |
| D. Me. LR 10(b)(5) | 1-inch margins on the top, bottom and each side. | `margin = 1in`. |
| D. Me. LR 10(c) | Verified complaints (signed under oath) are filed electronically with "/s/" and the original kept for 2 years. | Not applied: the sample is signed by counsel, not verified. A verified complaint would need a different signature line. |
| D. Me. LR 3(c) | Every complaint is accompanied by a completed civil cover sheet (JS 44 form, from the court's forms page). | Not produced here: separate filing. |
| D. Me. LR 3(d) | If the complaint seeks immediate relief, the title must state "Request for Immediate Relief". | Not applied: the sample seeks injunctive relief but does not seek immediate relief in the LR 3(d) sense; the title is the filing's own. Open: whether a TRO/preliminary injunction request in the complaint triggers 3(d). |
| D. Me. LR 3(e); LR 7.1 | Non-governmental parties file a corporate disclosure statement with their first appearance. | Not produced here: separate filing. |
| D. Me. LR 3(f) | A complaint seeking a ruling that an Act of Congress or a state statute is unconstitutional requires a separate "Notice of Constitutional Question" (LR 5.1). | Not produced here: separate filing. The Taco Barr sample does not challenge a statute. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | As LR 10(a). The "Civil Action No." blank is for the clerk. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every body paragraph is numbered 1, 2, ... by `body-pieces()`. Headings, the WHEREFORE clause and the jury-demand text are unnumbered (the `~ ` marker in the sample). |
| Fed. R. Civ. P. 11(a) | Signed by an attorney of record, with the signer's address, e-mail address and telephone number. | `signature-block()`: "/s/" line, then the lines of the block from the sample's frontmatter. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | No certificate in this template. (The motion template has one for papers served by mail; see the motion README.) |

## Layout

- Court title (two lines, bold, centered), then the caption: party block on the left, closed by a rule at its right and bottom, with "v." between parties and the designation set in from the names; "Civil Action No." at the right (a blank for the clerk when the sample has no case number).
- The title in bold capitals, the subtitle centered below it, double-spaced body, 0.5 inch first-line indent.
- Headings: level 1 bold capitals centred; level 2 bold centered (the statute line under a claim); level 3 bold italic at the left. Each is kept with the paragraph after it.
- Prayer items are lettered A., B., ... (`set enum(numbering: "A.")`), as in the Taco Barr exemplar.
- Signature block after the last paragraph (the jury demand), kept on the same page as that paragraph.

## Markdown contract (for samples)

- YAML frontmatter: `case_number` (empty for a new complaint), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `subtitle` (optional), `date`, `signature` (`signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (level 1 centered bold; level 2 centered bold sub-heading); `N.` list item (lettered by the template); `>` block quote (single-spaced, unnumbered); `~ ` unnumbered paragraph (marker stripped); any other paragraph is numbered.
- Do not put paragraph numbers in the text; the template numbers them.
- Italics: `*...*` (the Taco Barr filing has no italic case names; none are needed).

## What the overlay shows

`samples/OVERLAY-taco-barr-complaint.pdf` is red (our render) over blue (the filed exemplar), page by page, pairing each sample page with the exemplar page that shares the most words (`OVERLAY-taco-barr-complaint.txt`). Pages 1 to 3 pair with the same page number (word overlap 85 to 90 %). Pages 4 to 9 pair with exemplar pages 5 to 11 and overlap 36 to 85 %: the pairing is by words, and the sample's page breaks fall differently from the filed pages, because the filing is 11 pages at about 200 words a page and our render is 9 pages at about 250 words a page (EB Garamond sets more words to the line than Times New Roman at the same size). The overlay is a diagnostic, not a score; it shows where our layout and the filed layout differ, and the review above is the Gate 2 record.

## Known gaps and open choices

1. **Typeface and size.** The only vendored font family is EB Garamond (`fonts/eb-garamond`). The filed exemplars are Times New Roman 12 pt. The body is set at **13 pt** EB Garamond, which is 12-point or larger (LR 10(b)(1)) and has about the x-height of 12 pt Times; at 12 pt the text looked small against the exemplars. In the final render the sample is 9 pages at about 244 words a page; the filing is 11 pages at about 202 words a page (its body text, without the ECF headers). Whether David wants a Times-metric font vendored instead is open. The sample sets more words per page (about 244 against 202), so it runs to 9 pages against the filing's 11; the narrower face is the likely cause (not measured separately). Word counts (`pdftotext | wc -w`): the filing 2,392 including its ECF header lines on every page; the render 2,200. The render has every body paragraph of the filing.
2. **Caption.** The party column is closed by a rule (right and bottom), not the ")" column that the Taco Barr filing uses. This is a tier-2 choice and is ACCEPTED: both forms are common in D. Me. filings, and the rule reads cleanly at this size.
3. **Signature.** One signature block after the jury demand. The Taco Barr filing repeats the signature after the prayer and again after the jury demand. ACCEPTED: one signature block is what the rules require (FRCP 11(a)).
4. **Prayer sub-items.** Prayer item A in the filing has sub-items (i) and (ii); the sample keeps them inline in item A. ACCEPTED: the template has no third list level.
5. **Italics.** The filing's italic font (embedded in the Taco Barr PDF) is not used in any text run that the text layer exposes, so the sample is roman. Nothing in the template needs italics for this doc type.
6. **Second filer.** The Gagne complaint (Times New Roman, Island Justice and Consumer Attorneys) was compared on the caption and signature block only; its body was not transcribed. Tier 2 is therefore judged against the Taco Barr filing in full and the Gagne caption and signature block. The Gagne caption has a party block with "vs.", no ")" column, and the case number at the right of the caption, as the Taco Barr caption does; the title sits under the caption in both. Nothing in the Gagne caption contradicts the template.
7. **Civil cover sheet, LR 7.1 disclosure, summons, Notice of Constitutional Question.** Separate filings under LR 3(c), 3(e), 3(f), not produced here.
8. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape and the brief forbids editing `tools/`. The render (`tools/render.sh`) and overlay (`tools/overlay.sh`) were run; the review below is the Gate 2 record.
9. **Numbering.** The filed paragraph numbers match the sample's: the sample's paragraphs 1 to 53 are the filing's, including 28 "The posted article" (after the unnumbered "See Exhibit 7.").

## Review of the rendered pages (final state, 9 pages)

Every page rendered at 60 dpi and viewed after the last template change.

- Page 1: court title, caption with the rule and "Civil Action No." blank, COMPLAINT and subtitle, the intro paragraph (unnumbered), INTRODUCTION, paragraphs 1 and 2. No spill. Pass.
- Page 2: THE PARTIES, paragraphs 3 to 10, BACKGROUND heading, paragraph 11. Pass.
- Page 3: paragraphs 12 to 21. Pass.
- Page 4: paragraphs 22 to 27, the block quote (single-spaced, indented), "See Exhibit 7." (unnumbered). Pass.
- Page 5: paragraphs 28 to 36, FIRST CLAIM FOR RELIEF heading and bracketed statute line. Pass.
- Page 6: paragraphs 37 to 45, SECOND and THIRD CLAIM headings (not at the foot of a page). Pass.
- Page 7: paragraphs 46 to 50, FOURTH CLAIM heading (two-line bracketed statute line, centered). Pass.
- Page 8: paragraphs 51 to 53, PRAYER FOR RELIEF, WHEREFORE clause, item A (wrapped lines). Pass.
- Page 9: items B to E, DEMAND FOR JURY TRIAL, the demand, the date, signature block (on the same page as the demand). Pass.
- Pages 1 to 9 show no overlapping lines, no heading at a page foot, no line running into the margin.

## History

- Paragraph spacing was set to the leading after overlapping numbered paragraphs were found on pages 2 to 4 (fixed and re-reviewed).
- Pitch went from 24 pt (the first pass, copied from the pleading-paper template) to 27.6 pt, the pitch measured on the filed exemplars (`pdftotext -bbox`).
- Body size went from 12 pt to 13 pt (before the paragraph-spacing fix, which added length; see Known gaps 1). Final: 9 pages against the filing's 11.
