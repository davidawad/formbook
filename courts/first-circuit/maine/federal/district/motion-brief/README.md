# med: motion-brief

Doc type: **motion to dismiss with incorporated memorandum of law** (Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the District of Maine (`med`).
Folder: `courts/first-circuit/maine/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: 2 filers. `usage/SAMPLE-med-motion-brief-ngiramahoro226cv00342.pdf` (primary, transcribed; defendants Botana and Portland Public Schools, Drummond Woodsum) and `usage/SAMPLE-med-motion-brief-arndt226cv00117.pdf` (second filer, Town of Freeport, Bernstein Shur; compared on structure, its incorporated memorandum headings and its certificate of service). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-med-motion-brief-ngiramahoromotiontodismiss.md`: an **excerpt** of the 18-page motion: caption, title, opening paragraph, Introduction, Background, Legal Standard, Argument I (MHRA, subsections i to iii), Argument II (MCRA and Title IX; II.iii (§ 1983) omitted), Conclusion and signature block. Footnotes 1 to 7 (footnotes 8 and 9 are in the omitted II.iii and III). Section III (NIED) is omitted. |
| typeface | none named: D. Me. LR 10(b)(1) requires "12-point font or larger" and names no face (text read 2026-10-14). Substitute: none needed, EB Garamond kept (`docs/FONTS.md`, "No face named"). Metric-compatible: n/a. Filed exemplars are Times New Roman (tier 3, filer style, not chased). `pdffonts`: EBGaramond-Regular, -Bold and -Italic embedded. |
| render | ok: `usage/OUTPUT-med-motion-brief-ngiramahoromotiontodismiss.typst.pdf`, 10 pages, `tools/render.sh` with typst 0.15.0, vendored EB Garamond only, no typst warnings (exit 0). |
| overlay | ok: `usage/OVERLAY-ngiramahoro-motion-to-dismiss.pdf` and `.txt` (against the primary exemplar, `ngiramahoro-2-26-cv-00342`, passed as the exemplar argument to `tools/overlay.sh`). |
| pages reviewed | 10 of 10: every page rendered at 60 dpi and viewed in its final state (pages 4 and 5 after the last heading-style change; pages 1 to 3 and 6 to 10 had identical page text after that change, checked with `pdftotext`). |
| certificate | The template renders a certificate of service when the sample has one. The Ngiramahoro filing has none (service was CM/ECF). Tested with a temporary sample that carried a certificate: rendered with exit 0 and no warnings; that sample is not committed. The Arndt filing's mail-service certificate is not transcribed. |

File names: the brief asked for `usage/<id>.md` and `usage/<id>-overlay.pdf`; the repo's file-role names are used instead (`INPUT-<id>.md` in, `OUTPUT-<id>.pdf` out, `OVERLAY-<id>.pdf/.txt`), because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Primary source: **District of Maine Local Rules, "current as of April 1, 2025"**, https://www.med.uscourts.gov/sites/med/files/LocalRules.pdf, read in full 2026-10-14 (the text was taken from the PDF the fetch tool returned; the court site rejects direct downloads). Federal rules: Fed. R. Civ. P. 10(a), 10(b) and 11(a) from https://www.law.cornell.edu/rules/frcp/rule_10 and https://www.law.cornell.edu/rules/frcp/rule_11, and 5(d)(1)(B) from https://www.law.cornell.edu/rules/frcp/rule_5, verified 2026-10-14. Fed. R. Civ. P. 12(b)(6) is cited as the filings cite it; its text was not fetched in this pass.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Me. LR 7(a) | "Every motion must incorporate a memorandum of law." | The template's title block takes the motion's title from the sample; the sample's title says "with Incorporated Memorandum of Law" (the form the exemplar uses). |
| D. Me. LR 7(d)(1) | A memorandum supporting a motion to dismiss may not exceed 20 pages; a nondispositive motion's memorandum 10; a reply 7. | Not enforced by the template. The filing is 18 pages (the excerpt renders to 10). Open: the rule does not say whether the caption, signature and certificate count toward the 20 pages. |
| D. Me. LR 7(e) | Oral argument may be requested "in the caption of the motion". | Not applied: the Ngiramahoro caption makes no request. Open: no sample asks for argument. |
| D. Me. LR 10(a) | Caption with the case number on the first page; the title and the filing party immediately under the caption. | `court-title()`, `caption()`, `title-block()` in `typst/med-motion-brief.typ`. |
| D. Me. LR 10(b)(1) | 12-point or larger type; footnotes 10-point or larger. | `type-size = 13pt`; `footnote-size = 11pt` (see Known gaps). |
| D. Me. LR 10(b)(2) | Text double-spaced; block quotes, headings and footnotes may be single-spaced. | `body-leading = 27.6pt - 0.65em` (27.6 pt pitch); block quotes, headings, footnotes and the caption single-spaced. |
| D. Me. LR 10(b)(3)–(5) | 8 1/2 x 11 paper; page numbers at the bottom; 1-inch margins. | `paper: "us-letter"`; `footer`; `margin = 1in`. |
| D. Me. LR 10(b)(6) | Supporting documents attached to the main document with the ECF attachment function. | Not applicable to the excerpt (no attachments). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | As LR 10(a). "Civil Action No." is the label; the Ngiramahoro filing uses "Case No.". |
| Fed. R. Civ. P. 11(a) | Signed by an attorney of record, with the signer's address, e-mail address and telephone number. | `signature-block()`: "Dated", the "/s/" line, then the lines of the block from the sample's frontmatter. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served through the court's electronic-filing system. | The certificate is optional (`certificate:` in the sample frontmatter). For mail service (as in the Arndt filing) it is needed; the template renders it under "CERTIFICATE OF SERVICE" with the signature block. |

## Layout

- Court title (two lines, bold, centered); caption with the party block on the left, closed by a rule at its right and bottom; "Civil Action No." and the case number at the right; the motion's title in bold capitals under the caption.
- Double-spaced body with a 0.5 inch first-line indent; no paragraph numbers (a brief is not a pleading under FRCP 10(b)).
- Headings: level 1 bold capitals, centered (INTRODUCTION, BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION); level 2 bold at the left with a hanging indent (I., II.); level 3 underlined at the left with a hanging indent (i., ii.), which is how the Ngiramahoro filing sets its sub-headings. Each heading stays with the text after it.
- Footnotes: 11 pt, single-spaced, above a 2.5 inch rule.
- The last body paragraph stays on the page with the signature block, so a signature never stands alone.
- Certificate of service (when present): bold centered heading, the paragraph, then the signature block, kept together.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `date`, `signature` (`signer`, `lines`), and optional `certificate` (the certificate's text).
- Body: blank-line-separated chunks. `#` heading (level 1); `##` heading (level 2); `###` heading (level 3). Other paragraphs are body paragraphs (no numbers). `>` is a single-spaced block quote.
- Footnotes: `[^n]` at the reference and `[^n]: text` as its own chunk. The template passes each definition to the paragraph that refers to it; a definition chunk is not printed.
- Italics: `*...*`. The sample italicizes case names (full and short forms), `Id.`, and the signals `See`, `see`, `see also` and `See, e.g.,`, as the filing's italic runs show (see the italic runs in the filing's text layer, `pdftohtml -xml -i`).
- Escaped star pages: `\*12` (a Westlaw star page in a citation) renders as a literal asterisk.

## What the overlay shows

`usage/OVERLAY-ngiramahoro-motion-to-dismiss.pdf` is red (our render) over blue (the filed exemplar), page by page, with each sample page paired to the exemplar page sharing the most words (`OVERLAY-ngiramahoro-motion-to-dismiss.txt`). Pages 1 to 8 pair with the same page number at 88 to 95 % word overlap; page 9 at 76 %; page 10 (the conclusion and signature block) pairs with the filing's signature page (page 18) at 39 %, because the filing keeps its conclusion and signature on page 18, while the excerpt has both on page 10. The overlay is a diagnostic, not a score; the review below is the Gate 2 record.

## Known gaps and open choices

1. **Typeface and size.** No face is named, so the template uses EB Garamond. The Ngiramahoro filing is Times New Roman 12 pt (and 10 pt footnotes). The body is set at **13 pt** (12-point or larger, LR 10(b)(1), with about the x-height of 12 pt Times) and footnotes at **11 pt** (10-point or larger). Resolved 2026-10-14: LR 10(b)(1) names no face, so `docs/FONTS.md` keeps EB Garamond (the same as the complaint).
2. **Caption.** The party column is closed by a rule, not the ")" column the Ngiramahoro filing uses. ACCEPTED: the same convention as the complaint template; both are common in D. Me.
3. **Label.** "Civil Action No." replaces the filing's "Case No.". ACCEPTED: LR 10(a) asks for "a case number" and does not fix the label.
4. **Excerpt.** The sample is an excerpt (II.iii and III omitted, as listed above). The omitted sections carry the § 1983 and NIED arguments and footnotes 8 and 9. Headings and footnotes in the sample were checked; a full transcription would run past the 8 to 14 page target (the filing is 18 pages), so it was not done. Open: whether David wants the full memorandum as the sample.
5. **Italics not transcribed.** Italic emphasis inside quoted text (the Ngiramahoro filing italicizes "school district" in the MCRA paragraph and "emphasis supplied" in its Title IX citation) is not marked in the sample. ACCEPTED for this pass.
6. **Signature.** The filing shows "/s//s/" on the signature line (a typing error); the sample uses one "/s/".
7. **Certificate of service.** The sample has none (the Ngiramahoro filing used CM/ECF, FRCP 5(d)(1)(B)). The template path is exercised only by a temporary render (see the status table). The Arndt filing's mail-service certificate is the one a mail-served filing needs; it is not transcribed.
8. **Page limit.** LR 7(d)(1) limits the memorandum to 20 pages. The template does not check page counts. The filing is 18 pages; the excerpt is 10. Open: whether the caption, signature and certificate count toward the 20 pages (the rule does not say).
9. **Second filer.** The Arndt motion (Town of Freeport, 21 pages with a Preliminary Statement and a Factual Background, and a certificate of service) was read in full for its structure and its certificate, not transcribed or rendered for comparison. Tier 2 is judged against the Ngiramahoro filing in full and the Arndt structure and certificate.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape and the brief forbids editing `tools/`. The render and overlay were run; the review below is the Gate 2 record.

## Review of the rendered pages (final state, 10 pages)

Every page rendered at 60 dpi and viewed.

- Page 1: court title, caption with the rule and "Civil Action No. 2:26-cv-00342-SDN", the motion's title in two lines, the opening paragraph, INTRODUCTION. Pass.
- Page 2: BACKGROUND, paragraphs with the footnote 1 marker and its text at the foot of the page. Pass.
- Page 3: continuation of BACKGROUND, LEGAL STANDARD (italic case names), ARGUMENT opening. Pass.
- Page 4: the level 2 heading "I. Plaintiff Failed to State a Cognizable Claim..." (bold), the level 3 "i." heading (underlined), block-quoted MHRA text with italic citations, footnotes 2 and 3 at the foot. Pass.
- Page 5: "ii." and "iii." sub-headings (underlined; the long "iii." heading wraps with a hanging indent), footnotes 4 to 6. Pass.
- Page 6: body of Argument I, the heading "II." (bold) and "i." (underlined) near the foot of the page, with text following them on the same page. Pass.
- Page 7: the MCRA paragraphs, "ii." heading, footnote 7 at the foot. Pass.
- Page 8: Title IX framework, the three-inquiry block quote (single-spaced), citations. Pass.
- Page 9: the application paragraphs, CONCLUSION heading and paragraph moved to page 10 with the signature block, leaving page 9 short at the foot. Pass.
- Page 10: CONCLUSION heading, the concluding paragraph, "Dated: July 7, 2026", the "/s/" signature block, the signer's lines. Pass.

## History

- Paragraph spacing was set to the leading in both templates after the complaint review showed overlapping numbered paragraphs. This template was rendered after that fix and checked for the same defect (none).
- The last paragraph was joined to the signature block after the signature stood alone on a page.
- Level 3 headings went from bold italic to underlined after the exemplar was checked (bold italic is not the filing's style).

## Engines

docx: `docx/build-reference.sh` builds `docx/reference.docx`; `docx/med-motion-brief.lua` builds the caption, title, signature block and certificate of service (certificate only when the sample has one). Output: `usage/OUTPUT-med-motion-brief-ngiramahoromotiontodismiss.docx` and `.docx.pdf` (LibreOffice). Opened and converted with LibreOffice only; Word was not checked.

- Matches typst (every page of both PDFs rendered at 60 dpi and viewed): EB Garamond 13 pt (embedded); double spacing as exact 27.6 pt lines with no paragraph gap; 0.5 in first-line indent; caption, and the title in bold capitals double-spaced as in typst; H1 centered bold capitals, H2 bold at the left with a hanging indent, H3 underlined at the left; single-spaced block quotes; 11 pt single-spaced footnotes; signature block kept with the last paragraph; letter, 1-inch margins; centered page number.
- Certificate of service: tested with a temporary copy of the sample that carried a certificate (rendered through the same filter, 11 pages, not committed). The committed sample has none.
- Differs: footnote separator is pandoc's default separator line, shorter than the 2.5 inch rule typst draws; the "Civil Action No." label sits above its blank rule when the case number is blank (typst: one line), as in the complaint.
- BLOCKED: lines per page: the same exact 27.6 pt limit as the complaint (23 lines per page against typst's 24, because typst's first line on each page overhangs the top margin by about 4.6 pt). Page breaks match typst on pages 1 to 3 and differ from page 4 on; the conclusion and signature move to page 10 in both.
