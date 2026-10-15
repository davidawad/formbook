# D.N.D. (ndd): motion brief (motion to dismiss with memorandum)

Doc type: **motion-brief**, a Rule 12(b) motion to dismiss with its memorandum in support, one filed document, in the United States District Court for the District of North Dakota (`ndd`). Folder: `courts/eighth-circuit/north-dakota/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-dms-health-3-23-cv-00204-motion-brief.pdf` (1 filer, private defendant; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-dms-health-motion-to-dismiss.md`: caption, lead-in, sections I to III, V (heading 1, subheading A and its first paragraph), IV, VI, signature and certificate of service. Other argument sections are not transcribed (see gaps). |
| render | ok: `samples/OUTPUT-dms-health-motion-to-dismiss.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh` exit 0) |
| overlay | ok: `samples/OVERLAY-dms-health-motion-to-dismiss.pdf` and `OVERLAY-dms-health-motion-to-dismiss.txt` |
| pages reviewed | 9 of 9 (fonts pass 2026-10-14: every page rendered at 50 dpi and viewed again after the font check) |
| depth | 9 rendered pages against a 26-page exemplar; the target of 8-14 pages is met for the transcribed portion |

File names follow `tools/render.sh` and `tools/overlay.sh` defaults (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` form in the brief, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`.

## Governing rules

Primary source: D.N.D. Civil Rules (local rules), "Effective October 6, 2025", https://www.ndd.uscourts.gov/lci/local_rules.pdf (read 2026-10-14). Federal rules: Fed. R. Civ. P. 7(b)(1), 12(b), fetched from https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14 (the fetch returned a summary; the wording used for 12(b)(1) and 12(b)(6) is checked against the official text before a tier-1 claim is closed).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.D. Civ. R. 5.1(B)(1) | Standard size paper; page numbers at the bottom of each page. | `page` (us-letter; centred page number in the footer). |
| D.N.D. Civ. R. 5.1(B)(2) | One side, one-inch minimum margin; **12-point type or larger**; **double-spaced**, except the title of the case and quoted material may be single-spaced. | `margin = 1in`, `type-size = 12pt`, `body-leading = 1.35em` (24.0 pt baseline pitch, measured); headings are double-spaced; caption, title block, signature block and the service list are single-spaced. |
| D.N.D. Civ. R. 3.1(A) | The division is designated in the caption. | `division` frontmatter line; the template fails the build if it is missing (`assert`). |
| D.N.D. Civ. R. 5.1(B)(3) | Papers after the initial pleading (exhibits excepted) are in pleading format, each with the venue, case title and file number. | `court-title` (venue), `caption` (case title, "Case No." with the file number). |
| D.N.D. Civ. R. 7.1(A)(1)(a) | A dispositive motion (a Rule 12 motion) is filed with a memorandum in support, not exceeding 40 pages; a table of contents and table of authorities, "if a party chooses to include them", are excluded from the limit. | No page counter in the template (not enforced; see gaps). Tables are not produced: they are optional. |
| D.N.D. Civ. R. 7.1(B)(3) | Proposed orders are not required unless ordered. | No proposed order is produced. |
| D.N.D. Civ. R. 7.1.1 | A corporate disclosure statement or certificate of non-applicability within 14 days of the first filing. | Not produced (a separate filing). |
| Fed. R. Civ. P. 7(b)(1) | A motion states with particularity the grounds for seeking the order. | The author's text (the lead-in names the rules and relief). The template does not check it. |
| Fed. R. Civ. P. 12(b)(1), (6) | Defences of lack of subject-matter jurisdiction and failure to state a claim, asserted by motion. | Content of the sample, not the template. |

## Layout

- Court title (three centred bold lines: court, district, division), then the caption: party names with a column of ")" marks; on the right the case number and the bold title. An "In re" caption has no designation line.
- Body text double-spaced, 12-point, one-inch margins, first-line indent 0.5 in, not numbered (briefs are not numbered in this court).
- Headings: `#` centred bold caps (I. INTRODUCTION, III., V., VI.); `##` bold with a hanging indent (the lettered subheading A.); `###` bold italic with a hanging indent (the numbered subheading 1.). Headings are sticky: a heading never ends a page.
- Signature block: frontmatter `closing` ("Respectfully submitted:"), `signature.firm`, then "/s/" plus `signature.signer`, then `signature.lines`, indented to the right half.
- Certificate of service (optional): frontmatter `certificate` (`heading`, `text`, `served` lines, `signer`, `signer_lines`). It is kept on one block so it does not split across pages.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court`, `district`, `division`, `caption.parties` (list of `{names: [lines], designation}`; a blank designation prints nothing), `case_number`, `title`, `lead_in` (the unnumbered lead-in paragraph), `closing`, `signature` (`firm`, `signer`, `lines`), `certificate` (optional), `date` (optional).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings (level 1 is a centred caps section; level 2 and 3 are the lettered and numbered subheadings). A list is lettered (a), (b), ... Any other chunk is a body paragraph with a first-line indent.
- Not supported: footnotes (none are used in the sample), tables, raw typst.

## Spacing (measured)

`pdftotext -bbox` on the render: lines inside a paragraph are 24.0 pt apart, and paragraphs are 24.0 pt apart (each paragraph block carries `below: body-leading`, as in the complaint folder).

## Engines

| Engine | Status | What matches the typst form | What differs / BLOCKED |
|---|---|---|---|
| typst (primary) | as above | the reference | none |
| docx | `samples/OUTPUT-dms-health-motion-to-dismiss.docx` and `.docx.pdf` (10 pages, LibreOffice 26.8.1 PDF, EB Garamond embedded per `pdffonts`; typst is 9) | Letter, 1 in margins, EB Garamond 12 pt, body and headings at 24 pt exact (double), caption as a borderless table with the ")" column, body not numbered, centred PAGE number, headings with the same levels (centred caps, hanging lettered and numbered sub-headings), lettered (a), (b) lists, signature block and certificate of service each kept whole (one unsplittable table row). Checked by rendering all 10 pages to PNG at 60 dpi against the typst pages. | Page breaks are LibreOffice's: the signature block does not fit at the foot of page 8 in docx (it moves to page 9), so the docx runs one page longer than typst. The certificate's text is set as plain text (the sample's certificate has no markdown). Word is not available here: the `.docx` was not opened in Word, so no Word repair-prompt check was run. No gate stamp: `tools/check.sh --engine docx` was not run, because this doc-type folder has no `checks.yaml` or `rules.md`. |

`docx/reference.docx` is built by `docx/make-reference.sh`, and the conversion is `docx/ndd-motion-brief.lua`. The toolchain is as in the complaint's Engines section. Commands: `sh tools/render.sh --engine docx <motion-brief-dir> samples/INPUT-dms-health-motion-to-dismiss.md`.

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for two or three filers. The second filer was not collected. Checked and not used: Turtle Mountain v. Jaeger (3:22-cv-00022, ECF 191, a Rule 12(c) memorandum, 21 pages, RECAP PDF); Hoefer v. Teigen (1:25-cv-00207): the motion (ECF 12) has no stored PDF; Christian Employers Alliance v. EEOC (1:25-cv-00007, ECF 52-2): a settlement agreement, not a brief. Tier 2 is therefore **not** judged against two filers.
2. **Partial transcription.** The sample transcribes sections I to III, IV, V (heading 1, subheading A and its first paragraph), VI, the signature and the certificate. Not transcribed: the rest of subheading A and its argument; subheadings B, C and D under heading 1 (if any); heading 2 and its subheadings; the remaining pages of the exemplar. The overlay pairs therefore stop at the exemplar page where the transcription stops; the untranscribed pages of the exemplar have no render to pair with. The ca9 sample was also a portion.
3. **Length.** Civil Rule 7.1(A)(1)(a) allows 40 pages for a dispositive motion's memorandum. The exemplar is 26 pages. The template does not count pages; a 40-page check would need a page counter that reads the rendered PDF.
4. **Tables.** The exemplar has none, and the rule makes them optional. The template does not produce a table of contents or table of authorities. A brief that includes them would need a template change.
5. **Font.** Typeface check (fonts pass, 2026-10-14): face required = none. D.N.D. Civ. R. 5.1(B)(2) sets a size ("12-point font or larger"), not a typeface, and the rest of the local rules text (`local_rules.pdf`, effective October 6, 2025) names no face. Per `docs/FONTS.md` ("No face named" → EB Garamond), the template keeps EB Garamond at 12 pt; vendored substitute = none needed, font = `EB Garamond`. The filed exemplar is set in Times New Roman, which the rule does not require, and EB Garamond looks smaller than it at the same size. The Times-metric substitute, `Liberation Serif`, is vendored if a court rule ever names Times.
6. **Title.** The exemplar's title reads "DMS HEATH TECHNOLOGIES" (a typo in the filing). The sample uses "HEALTH".
7. **Line break.** In the conclusion, typst breaks "12(b)(1)" between ")" and "(" at the end of a line ("Rules of Civil Procedure 12(b)" / "(1)"). The template has no fix for this; it is a line-breaking nit, not a rule issue, and the text is not altered.
8. **Certificate.** The exemplar includes a certificate of service (CM/ECF). Its presence is a filer convention; D.N.D. Civ. R. 5.1 does not call for it. The template prints it when the sample supplies it.
9. **Overlay pairing.** Exact pairs from `OVERLAY-dms-health-motion-to-dismiss.txt`: ours p.1 ↔ filed p.1, p.2 ↔ p.2, p.3 ↔ p.4, p.4 ↔ p.5, p.5 ↔ p.6, p.6 ↔ p.7, p.7 ↔ p.8, p.8 ↔ p.9, p.9 ↔ p.26 (the certificate). Pages 3 to 8 are offset from the exemplar because its pagination includes pages the transcription does not carry. The overlay is a diagnostic, not a score.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief does not require them. Render and overlay were run; the page review below is the Gate 2 record for this doc type.

## Review of the rendered pages (9 of 9, 60 dpi, viewed after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption ("In re" with no designation), case number, bold title, lead-in, I. INTRODUCTION (first paragraph and part of the second) | OK. |
| 2 | Introduction (end), II. SUMMARY OF PLAINTIFFS' ALLEGATIONS begins | OK. |
| 3 | Summary, Boyd and Kolkind paragraphs | OK. |
| 4 | Summary: damages list and causes of action | OK. Page ends with white space: III. starts on the next page (the heading is kept with its paragraph). |
| 5 | III. MOTION TO DISMISS STANDARD (both paragraphs), start of the 12(b)(1) paragraph | OK. |
| 6 | Standard, diversity and declaratory paragraphs | OK. |
| 7 | IV. CONFLICTS OF LAW; V. ARGUMENT, the intro paragraph and heading 1 (bold italic) | OK. Heading 1 is kept with its paragraph. |
| 8 | Heading 1 paragraph, subheading A (bold), its first paragraph, VI. CONCLUSION, "Respectfully submitted" signature block | OK. The signature block is kept together. Nit 7 (the "12(b)(1)" break) is here. |
| 9 | CERTIFICATE OF SERVICE, the service list, signer block | OK. The certificate is one block and is not split. |
