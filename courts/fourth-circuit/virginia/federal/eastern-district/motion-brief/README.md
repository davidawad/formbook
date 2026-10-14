# vaed: motion-brief

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Virginia (`vaed`).
Folder: `courts/fourth-circuit/virginia/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-keppel-4-26-cv-00112-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-keppel-motion-brief.md` (abridged transcription of the 12-page memorandum; see Known gaps) |
| render | ok: `samples/OUTPUT-keppel-motion-brief.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| typeface | Rule names no face: L.R. 7(F)(3) says "12 point Roman style or 10 pitch Courier style". Any proportional serif is allowed, so the template keeps EB Garamond (`docs/FONTS.md`: no court-named face). Metric note: none needed. Font re-checked 2026-10-14 (`pdffonts`: EB Garamond only). |
| overlay | fail: `tools/overlay.sh` needs the filed exemplar PDF, and `exemplars/` holds only `SOURCE.md` (the PDF is not in this snapshot). Old `OVERLAY-keppel-motion-brief.txt` is from an earlier run and is not current. |
| pages reviewed | 9 of 9 (re-rendered 2026-10-14; every page rasterized at 70 dpi and viewed) |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Va. Local Civil Rule 7(F)(1) | "All motions ... shall be accompanied by a written brief setting forth a concise statement of the facts and supporting reasons, along with a citation of the authorities upon which the movant relies." | The memorandum itself (this doc type). |
| E.D. Va. Local Civil Rule 7(F)(3) | "All briefs, including footnotes, shall be written in 12 point Roman style or 10 pitch Courier style with one inch margins." | `type-size = 12pt`, `show footnote.entry` at 12 pt, `margin-in = 1in`, `body-leading` (double spacing). |
| E.D. Va. Local Civil Rule 7(F)(3) | "opening and responsive briefs, exclusive of affidavits and supporting documentation, shall not exceed thirty (30) 8-1/2 inch x 11 inch pages double-spaced"; rebuttal briefs, 20 pages; excess only for good cause shown in advance. | `max-pages = 30`: a `context` check fails the build above 30 pages (counts the whole document, which is the stricter reading; the certificate is included). A rebuttal brief (20 pages) needs its own limit, not set here. |
| E.D. Va. Local Civil Rule 7(B) | "All pleadings and motions shall include the attorney's office address and telephone number." | The `signature.lines`. |
| Fed. R. Civ. P. 7(b)(1) | The form of a motion (the memorandum supports a motion made under Rule 12(b)(6)). | Context only. |
| Fed. R. Civ. P. 12(b)(6) | Motion to dismiss for failure to state a claim. | The legal standard in the sample. |
| Fed. R. Civ. P. 5(b) | Service; electronic service through the court's system. | `certificate` (CM/ECF certificate of service). |

Sources:
- E.D. Va. Local Civil Rules, last amended December 1, 2024: https://www.vaed.uscourts.gov/sites/vaed/files/Local%20Rules%20EDVA%20December%201%202024.pdf. Rules 7(B) and 7(F) are the civil rules; Criminal Rule 47(F)(3) repeats the 7(F)(3) wording. The January 18, 2023 version has the same 7(B) and 7(F)(3) text.
- Fed. R. Civ. P. 5, 7, 12: https://www.law.cornell.edu/rules/frcp/rule_5, rule_7, rule_12.

Notes on what the rules do not say:
- Table of contents and table of authorities: not required by Local Civil Rule 7(F) (no such requirement was found). The sample has none, and the template does not produce one. A memorandum of this length (the exemplar is 12 pages) does not need one under the rules checked.
- The line-numbering and pleading-paper practice of other districts does not appear in the Eastern District's Local Civil Rules, so none is used.
- The exemplar puts the certificate of service on its own page. The template does the same, as a convention, not a rule.

## Layout

- Court title (3 lines), bold, single-spaced, centered.
- Caption: party box on the left (all four sides ruled), case number on the right, vertically centered.
- Title of the paper, bold, underlined, centered (as the exemplar's title is).
- Body: double-spaced (24 pt baseline pitch at 12 pt, measured in the render); paragraphs with a 0.5 inch first-line indent; left-aligned (ragged right).
- Headings: `#` centered bold caps (INTRODUCTION, CONCLUSION); `##` bold, label hangs ("I.", "II."); `###` bold, indented 0.5 inch, label hangs ("A.", "B.").
- The last body paragraph is kept on the page with the signature block, so the signature never stands alone on a page.
- Signature block: "Date:" line, closing, party name (caps), "/s/" line, counsel lines; single-spaced; kept together.
- Certificate of service: on its own page, centered bold caps heading, paragraph with a first-line indent, the served list (single-spaced), and the signature block repeated, as in the exemplar.
- Page number centered in the footer, 12 point.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (level 1 centered caps), `##` or `###` heading (label hangs), or a paragraph (first-line indent). No numbered allegations; no lists are used in this template.
- Frontmatter: `court` (list of lines), `caption.parties` (list of `{lines, designation}`; "v." is inserted between entries), `caption.case_number`, `brief_title`, `signature` (`date`, `closing`, `party`, `by`, `lines`), `certificate` (`title`, `text`, `served` list).
- Values with a colon must be quoted (YAML).
- Not supported: tables, footnote syntax, raw typst.

## Known gaps and open choices

1. **Tier 2 is judged against one filer only.** The brief and EVAL-LOOP ask for 2 or 3 filers. Found and not saved: *Ballentine v. Hall*, No. 1:26-cv-02331-RDA-IDD (E.D. Va., Alexandria), Document 11, 17 pages, filed 2026-08-12, the National Center for Missing & Exploited Children's memorandum in support of its motion to dismiss (see `exemplars/SOURCE.md`). It was not saved because the overlay pairs against the first file in `exemplars/`, which would then be Ballentine for the sample's Keppel text. Recorded as an open gap for David.
2. **The sample is abridged.** Marked in the sample where it matters: the block quotations from *Cory* and *Baldwin* are omitted (marked "[Block quotations ... omitted from this transcription.]"); the *Sloane*, *Harless*, and *Cretella* citations are omitted (marked); the Goulmamine discussion is reduced to its first citation; the Thompson and McGuire discussion is not transcribed; Background paragraphs are partial; Argument II's and III's paragraphs are transcribed as read. Footnotes 1 and 2 of the filing are not transcribed. The template sets footnote text to 12 point, but the markdown contract has no footnote syntax yet, so footnotes are not tested.
3. **Font.** Tier 1 asks for a 12 point Roman face. The rule names no face ("Roman style"), so `docs/FONTS.md` keeps EB Garamond. The exemplar is Times-style. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar. The point size meets the rule; the apparent size does not. Open question for David: if "Roman style" is read as Times New Roman, the substitute is Liberation Serif (metric-compatible, `docs/FONTS.md`) and the template should switch. Not switched here, because the rule does not name Times (recorded as ACCEPTED).
4. **Signature mark.** The exemplar's "/s/" line is transcribed as "/s/ Kristina H. Vaquera", as the filing shows it.
5. **30-page cap: tested.** The cap is a template assertion. It was exercised with a throwaway 420-paragraph draft (33 pages): the build failed with "33 pages exceed the 30-page limit of Local Civil Rule 7(F)(3)". The throwaway file was deleted. The rendered sample is 9 pages, so the assertion does not fire on it.
6. **Keep-together.** The conclusion and the signature move to the next page together when they do not fit (the sample's conclusion moved to page 8 for that reason, leaving page 7 with white space below Argument IV).
7. **Overlay pairing.** The sample is shorter than the filing, so the word-overlap figures in `OVERLAY-keppel-motion-brief.txt` are low on pages 4 and 7 (the pairing is by shared words). The overlay is a diagnostic, not a score.
8. **Output file names.** `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`, and `OVERLAY-<id>.txt`, not the `<id>.pdf` and `<id>-overlay.pdf` names in the task brief. The tool defaults were followed.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and `tools/` is out of scope. Render, overlay, and the page review below are the checks run.
10. **Rebuttal brief.** The 20-page limit for rebuttal briefs is not implemented; this template is for the opening memorandum.

## Review of the rendered pages (final, 2026-10-14)

- Page 1: court title, caption (party box, case number), title (bold, underlined), INTRODUCTION heading, first paragraphs. Pass.
- Page 2: intro end, STATEMENT OF ALLEGED FACTS, first fact paragraphs with citations. Pass.
- Page 3: remaining fact paragraphs, LEGAL STANDARD, ARGUMENT, heading I and A (A wraps to two lines, label hangs). Pass.
- Page 4: Argument I.A end, I.B with its heading (bold, label hangs), "[Block quotations ... omitted]" note. Pass.
- Page 5: I.B end, I.C, heading II (two lines), first paragraphs of II. Pass.
- Page 6: II end, heading III (two lines), III's first paragraphs. Pass.
- Page 7: III end, heading IV, IV's paragraphs; white space below because the conclusion moved to page 8 with its signature. Pass.
- Page 8: CONCLUSION heading and paragraph, "Date:", "Respectfully submitted," party name, "/s/" line, counsel block single-spaced. Pass.
- Page 9: CERTIFICATE OF SERVICE on its own page, served list, date, signature block repeated. Pass.
