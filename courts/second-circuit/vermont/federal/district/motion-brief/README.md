# vtd: motion-brief

Doc type: **motion-brief** (a memorandum of law supporting a motion) in the United States District Court for the District of Vermont (`vtd`). Worked example: a memorandum supporting a Rule 12(b)(6) motion to dismiss.
Folder: `courts/second-circuit/vermont/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-blackberry-coulter-5-22-cv-98-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-coulter-motion-brief.md`: an excerpt of the 25-page memorandum, 9 rendered pages (caption, introduction and background, plaintiffs' allegations, legal standard, the opening of Argument I, all of Argument II, conclusion and signature). The omitted spans are marked in the sample. |
| render | ok: `samples/OUTPUT-coulter-motion-brief.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-coulter-motion-brief.pdf` and `samples/OVERLAY-coulter-motion-brief.txt` (page map) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed; see the review below) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`samples/INPUT-<id>.md` in; `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf|.txt` out). See the complaint README for why.

## Governing rules

Primary source: **D. Vt. Local Rules of Procedure, April 20, 2026** (`LocalRules-20260420.pdf`), posted at https://www.vtd.uscourts.gov/court-info/local-rules-and-orders. Fetched 2026-10-14; read from the PDF's text layer.

Federal rules: Fed. R. Civ. P. 5(d)(1)(B) and 10(a), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/ (`rule_5`, `rule_10`).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 7(a)(1) | The court considers no motion unless its title contains the word "motion". | The template asserts that `brief_title` contains "motion" (the memorandum names the motion it supports). |
| L.R. 7(a)(2) | A motion is accompanied by, or contains, a memorandum of law concisely stating the legal contentions and supporting authorities. | Content: the memorandum is the document this template produces. |
| L.R. 7(a)(3)(A) | A motion to dismiss is a dispositive motion (the opposition is due 30 days after service). | Makes L.R. 7(a)(4)(A) apply. The opposition and reply are not templated here. |
| L.R. 7(a)(4)(A) | A memorandum supporting or opposing a dispositive motion must not exceed 25 pages, excluding exhibits and attachments, unless the judge grants prior leave. | `page-limit = 25`. The template asserts the rendered length after layout (`counter(page).final()`). A mutant with a limit of 5 fails with "the memorandum is 9 pages; the limit is 5", so the check is live. It counts the sample, not the full filing. |
| L.R. 10(a)(1)-(8) | As for the complaint: 8 1/2 x 11, legible, 1 inch margins, at least 12 point (footnotes included), consecutively numbered pages, double-spaced except quoted material, footnotes used sparingly. | Same parameters as the complaint template (see its README). Footnotes are set at the same 13 pt. |
| Typeface (L.R. 10(a) names none) | Face required by the rule: **none** (plainly legible; 12 point or more; no face is named). Vendored substitute: **none needed**; EB Garamond is kept under `docs/FONTS.md` ("No face named"). Metric fit: n/a. | `font-family = "EB Garamond"` |
| Fed. R. Civ. P. 10(a) | Caption with the court name, the title of the action, the file number, and the title of the paper. | `court-title()`, `caption()`: `Docket No.` (`case_label`) and the title. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | No certificate of service in the template; the exemplar's certificate (attachment 9 to the motion) is not in the transcribed text. |

Not checked by the template: the content of the memorandum (the legal argument), the opposition deadline, the reply limit of 10 pages (L.R. 7(a)(5)(B), for a reply), a request for oral argument (L.R. 7(a)(6)), and the L.R. 7(a)(7) statement of agreement (for non-dispositive motions only).

## Layout

- Letter paper, 1 inch margins; no pleading-paper line numbers.
- No separate cover page: court title (two bold lines), caption (parties in a column closed by a rule; the docket number and the title on the right), then the body.
- Headings: level 1 centered bold capitals (INTRODUCTION AND BACKGROUND, ARGUMENT, CONCLUSION); level 2 bold at the margin (argument headings I, II, ...); level 3 bold italic, indented 0.5 inch. Headings are kept with the text after them.
- Body paragraphs: unnumbered, 0.5 inch first-line indent, double-spaced (2.0em baseline pitch, as measured in the complaint).
- Footnotes: 13 pt, single-spaced, separated by a rule.
- Signature: date line (`DATED at Burlington, Vermont this ...`), the firm, a signature line, and the counsel block, indented 2.9 inches, kept on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `case_label` (optional, default `Civil Action No.`; this filing uses `Docket No.`); `caption.parties` (as for the complaint); `brief_title` (must contain "motion"); `signature` with `date_line`, `firm` (optional; a firm name above the signature line), `blocks` (a list of counsel blocks, each a list of lines) and `counsel_for` (optional). `by` is not used here.
- Body: blank-line-separated chunks. `#` is level 1, `##` level 2, `###` level 3. Other chunks are paragraphs (unnumbered). A list (`1.` items) is numbered 1., 2., ...
- Footnotes: markdown `[^n]` references and `[^n]: text` definitions. A definition must follow the paragraph that refers to it; the template folds a definition chunk into the chunk before it, because each chunk is rendered separately.
- Not supported: tables; raw typst.

## Known gaps and open choices

1. **Excerpt, not the whole memorandum.** The sample transcribes pages 1 to 7 (with the omission of the rest of Argument I, pages 8 to 11, marked in the text), pages 12 and 13 (Argument II, all of it; the Argument III heading starts on page 13 and is not transcribed), and page 25 (conclusion and signature). Pages 14 to 24 (Arguments III to V) are marked as not transcribed. The overlay therefore pairs the sample's pages with the exemplar's pages 1 to 7, 12, and 25, and the word overlap on the later sample pages is lower for that reason. The page-limit assertion counts the sample only; it does not show the full memorandum is within 25 pages (the exemplar is 25 pages, which is within the limit).
2. **One exemplar, one filer, filed 2022.** The EVAL-LOOP tier-2 standard asks for two or three filers. The search (CourtListener RECAP API, `type=r`, `court=vtd`, `available_only=on`, query "memorandum in support" "motion to dismiss") found *Pharmaceutical Research and Manufacturers of America v. Arel*, No. 2:25-cv-00600 (ECF 21, memorandum as attachment 1), but its download returned no file, and *Bingham Brook, LLC v. Verdantas, LLC*, No. 2:26-cv-00223 (memorandum as attachment 1), which was not downloaded. The exemplar is from 2022, before the current local rules (April 20, 2026); L.R. 10(a) is the same text in both, but the page limit is taken from the current rules.
3. **Type size and font.** Same as the complaint: the rule names no face and EB Garamond is kept; 13 pt against the rule's 12 point minimum, matched by eye to the exemplar's Times New Roman at 12 pt. The vendored `Liberation Serif` is metric-compatible with Times New Roman, so a switch is possible; whether to make it is a question for David (see the complaint README, Known gaps 2).
4. **Italics.** The text layer has no italic markup, so case names and signals (*Id.*, *See*) are transcribed in roman. The template supports `*...*` italics.
5. **Argument heading style.** Argument headings are bold at the margin (level 2). The exemplar's heading style is not known from the text layer, so this is a style choice.
6. **Certificate of service.** Not included (see the rules table). The exemplar filed one as an attachment.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`, which this doc-type folder does not have, and `tools/` is not part of this work. Render, overlay, and the mutant check of the page limit were run; the review below is the per-page check.

## Review of the rendered pages (`samples/OUTPUT-coulter-motion-brief.pdf`, 9 pages, viewed at 60 dpi, after the final template change)

- Page 1: court title; caption with `Docket No. 5:22-CV-98` and the bold title at the right; the opening paragraph; INTRODUCTION AND BACKGROUND; the first paragraph and the start of the second. Pass.
- Page 2: the rest of the litigation-history paragraph, the Santa Clara paragraph, and the first part of the "After Plaintiffs filed..." paragraph, which ends at "in Vermont," (footnote 1's reference is on page 3). Pass.
- Page 3: the rest of the "After Plaintiffs filed..." paragraph (reference 1); the discovery paragraph (reference 2); footnote 1 and footnote 2 text at the foot. Footnote 2 continues onto page 4 (normal footnote split). Pass.
- Page 4: the "Because the Superior Court..." paragraph (reference 3, text at the foot); the "It is against this backdrop" paragraph; the PLAINTIFFS' ALLEGATIONS heading and its first two paragraphs. Pass.
- Page 5: the "Ms. Coulter worked..." paragraph (references 4 and 5, both texts at the foot of this page); the remaining allegations paragraphs; LEGAL STANDARD and the start of its first paragraph. Pass.
- Page 6: the legal standard paragraphs; "Applying this standard..."; ARGUMENT; heading I; the first paragraph. Pass.
- Page 7: the rest of the first paragraph of Argument I, the Bank of America citation paragraph, the RCA paragraph, and the "At the outset" paragraph; the omission marker for pages 8 to 11. Pass.
- Page 8: heading II (three lines, bold at the margin); the three paragraphs of Argument II. Pass.
- Page 9: "Here, Plaintiffs' breach..."; the omission marker for Arguments III to V; CONCLUSION; the date line; the firm name, the signature line, the counsel block, and "Attorneys for Defendant KAYLAN COULTER". Pass.

Footnote placement was checked in the text layer: each reference and its text are on the same page (1 and 2 on page 3, 3 on page 4, 4 and 5 on page 5). An earlier template put footnote 4's text one page after its reference; the fix is noted in the template.

Pages reviewed: 9 of 9.
