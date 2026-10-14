# mad: motion-brief

Doc type: **motion-brief**, the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b)(6), in the United States District Court for the District of Massachusetts (`mad`).
Folder: `courts/first-circuit/massachusetts/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-diaz-smith-college-3-26-cv-12246-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-smith-college-motion-to-dismiss.md`: the whole 12-page memorandum (caption, introduction, facts with footnotes and a block quotation, argument I to III, conclusion, signature, certificate of service). Transcribed from the text layer of the exemplar. |
| render | ok: `samples/OUTPUT-smith-college-motion-to-dismiss.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh courts/first-circuit/massachusetts/federal/district/motion-brief samples/INPUT-smith-college-motion-to-dismiss.md`) |
| overlay | ok: `samples/OVERLAY-smith-college-motion-to-dismiss.pdf` and `OVERLAY-smith-college-motion-to-dismiss.txt` (`sh tools/overlay.sh courts/first-circuit/massachusetts/federal/district/motion-brief smith-college-motion-to-dismiss`) |
| typeface | No face named by the court's rules: EB Garamond kept (`docs/FONTS.md`, "No face named"). Fonts pass 2026-10-14: re-rendered with vendored fonts only, `pdffonts` shows EB Garamond only, no warnings. |
| pages reviewed | 12 of 12 (fonts pass 2026-10-14: every page rendered at 60 dpi and viewed; earlier review at the last template change) |

File names follow the tools, not the brief's wording: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf` / `.txt`. The tools are shared and were not edited.

## Governing rules

| Rule | Requirement | Where in the template |
|---|---|---|
| D. Mass. L.R. 7.1(b)(1) | A party filing a motion files at the same time a memorandum of reasons, including citation of supporting authorities. | The doc type itself: this template renders that memorandum. |
| D. Mass. L.R. 7.1(b)(4) | A memorandum supporting a motion does not exceed 20 pages, double-spaced, without leave of court. | Not enforced by the template. The render is 12 pages (MAD-LEN-001). |
| D. Mass. L.R. 7.1(a)(2) | No motion is filed unless counsel certify that they have conferred and attempted in good faith to resolve or narrow the issue. | `consultation-block()`, rendered when the sample has `consultation` (MAD-CERT-002). The exemplar memorandum has none: the certification is on the motion. |
| D. Mass. L.R. 7.1(d) | A request for oral argument goes in a separate paragraph, set off with a centered caption, "REQUEST FOR ORAL ARGUMENT". | Not generated (the sample does not ask for oral argument). |
| D. Mass. L.R. 5.1(a)(1) | FRCP 10 and 11 apply to the form and signing of papers. The attorney's Board of Bar Overseers registration number is inscribed below the signature. | `signature()`: `(BBO# n)` under each attorney's name (MAD-SIG-001). |
| D. Mass. L.R. 5.1(a)(2) | 8½ × 11 inch printable format; double-spaced except counsel identification, title of the case, footnotes, quotations and exhibits. | `body-leading = 1.2em` (24 pt baseline pitch at 13 pt); single spacing for the caption, quotations, footnotes, signature block and certificates. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title()`, `caption()` (court name, `Civil Action No.`, the title centered below the caption) (MAD-CAP-001..003). |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | `service-block()`, rendered when the sample has `service`; the exemplar has one (MAD-CERT-001). |
| Fed. R. Civ. P. 7(b)(1), 12(b)(6) | A request for a court order is made by motion; the motion must state the grounds. The argument is for failure to state a claim. | Content, not a template rule. |
| Typeface (none named) | D. Mass. L.R. 5.1 names no typeface or size. Judges' standing orders were not checked. | `font-family = "EB Garamond"` (MAD-FORM-002): the no-face case in `docs/FONTS.md`, not a substitute. |

Rule text: L.R. 5.1 and 7.1 from the court's combined local rules PDF, effective November 1, 2019 (https://www.mad.uscourts.gov/general/pdf/LC/Combined%20Local%20Rules%2011-1-19.pdf), read on 2026-10-14. This is the latest consolidated copy the search found; the court's rules page was not reachable in this run (HTTP 404 and 403), so later amendments are not checked. Fed. R. Civ. P. 5(d)(1)(B) was read on 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_5. Fed. R. Civ. P. 7(b), 10 and 12(b)(6) are cited from the rule text, not fetched in this run (Rule 10 was read from https://www.law.cornell.edu/rules/frcp/rule_10).

The local rules set no typeface, font size or margins for D. Mass. (L.R. 5.1 sets paper size and spacing only), so those are style choices, not rule requirements.

## Layout

- Court title, two bold lines, centered: "IN THE UNITED STATES DISTRICT COURT / FOR THE DISTRICT OF MASSACHUSETTS".
- Caption: a party column with a rule on its right and bottom; `Civil Action No.` at the right.
- The title of the memorandum in bold capitals, centered, below the caption.
- Body: unnumbered paragraphs, first line indented 0.5 in; level 1 headings centered bold capitals (FACTS, ARGUMENT, CONCLUSION); level 2 headings bold, left, hanging (the argument's I, II, III); level 3 bold, left.
- Footnotes: single-spaced, 12 pt, attached to the paragraph that cites them.
- Quotations (`>`): single-spaced, indented 0.5 in each side.
- Signature: `DATED:` and the date, then at the right: "Respectfully submitted, By Its Attorneys," then `By: /s/` the signer, each attorney with BBO number and e-mail, then the firm.
- Certificate of service (when given): centered bold heading, the ECF sentence, the counsel blocks, `/s/` and the signer's name.
- Certificate of consultation (when given): centered bold heading, then the text from the sample.
- Footer: page number, centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `date`, `signature` (`lead` lines, `signer`, `attorneys` as `{name, bbo, email}`, `firm` lines), `service` (optional: `date`, `counsel` as a list of counsel blocks, each a list of lines), `consultation` (optional, text).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) headings; a paragraph (unnumbered); a `>` quotation; a list.
- Footnotes: `text[^key]` in the body and `[^key]: One line of footnote text.` anywhere in the file (one line per definition). The template attaches each definition to the chunk that cites it, because the body is rendered one chunk at a time.
- Not supported: tables (none needed), raw typst.

## Overlay

`OVERLAY-smith-college-motion-to-dismiss.pdf`: red is our render, blue is the filed page, black is where they agree. Each sample page is paired with the exemplar page sharing the most words (`.txt`). Pairing: ours p.1 to filed p.1 (96%), p.2 to p.2 (87%), p.3 to p.3 (62%), p.4 to p.4 (72%), p.5 to p.5 (70%), p.6 to p.6 (68%), p.7 to p.7 (89%), p.8 to p.8 (66%), p.9 to p.9 (61%), p.10 to p.11 (54%), p.11 to p.12 (36%), p.12 to p.12 (55%). Pages 1 to 9 pair page for page; after that the pairing shifts by one page (ours p.10 pairs with its p.11, ours p.11 with its p.12, which holds the signature and certificate). The cause was not investigated. The overlay is a diagnostic, not a score.

## Review of the rendered pages (final state)

- Page 1: court title, caption, the title, the introduction (unnumbered paragraphs). No spill. Pass.
- Page 2: the introduction continues, FACTS heading (centered) with footnote 1 at the foot, I. The Collective Bargaining Agreement (level 3), footnote 2. Pass.
- Page 3: the CBA block quotation single-spaced and indented, II. Plaintiff's Allegations. Pass.
- Pages 4 to 10: ARGUMENT, headings I, II, III (level 2, hanging indent, kept with their first paragraph), citations, footnote 3 on page 8 at the foot of the page. Pass.
- Page 11: the rest of the argument, CONCLUSION, and the signature block on the same page (`DATED`, `Respectfully submitted,` `By: /s/`, attorneys, firm). Pass.
- Page 12: CERTIFICATE OF SERVICE, the ECF sentence, the counsel blocks, `/s/` and the signer's name. Pass.

Defects found in review and fixed (all in `mad-motion-brief.typ`):
- Paragraphs overlapped each other. Cause: a zero paragraph gap (`spacing: 0pt`) makes typst 0.15 stack EB Garamond paragraphs on top of each other; fixed with `para-gap = 0.65em`, and each paragraph is a block.
- Lines were too tight to be double-spaced. Cause: leading 0.54em; fixed with 1.2em (24 pt pitch).
- Footnote text was missing from the render. Cause: the body was rendered one chunk at a time, and cmarker resolves a `[^key]` reference only against a definition in the same call. Fixed by attaching each definition to the chunk that cites it.
- The first party's name wrapped so that "and" sat alone on a line. Fixed by widening the caption's party column to 3.5 in.

## Known gaps and open choices

1. **Typeface.** The local rules name no face, so EB Garamond stays. The exemplar is in Times New Roman, which is the filer's choice, not a rule. If David wants the exemplar's look, the metric-compatible vendored substitute is Liberation Serif (`docs/FONTS.md`); switching it is a choice for David, not made here.
2. **Footnotes** are 12 pt, single-spaced; the rules set no footnote size (L.R. 5.1(a)(2) exempts footnotes from double spacing only).
3. **Certificate of consultation** (L.R. 7.1(a)(2)). The template renders it when the sample has `consultation`. The exemplar memorandum does not carry one: the certification belongs to the motion, which is a separate filing and is not produced here.
4. **Request for oral argument** (L.R. 7.1(d)). Not generated.
5. **Exemplars.** One filer saved (Smith College). The second (Ferrini v. Allied World Assurance Co., 1:26-cv-10838-LTS, Starr Surplus Lines) is recorded in `exemplars/SOURCE.md`, not saved. Tier 2 is judged against one filer here.
6. **ECF header.** The court's stamp ("Case 3:26-cv-12246-CLM Document 11 Filed ...") is not reproduced.
7. **Exhibits.** The sample refers to Exhibit A (the CBA); the exhibit is not part of the template.
8. **Case names** are roman in the sample, as the exemplar's text layer shows no italics. The template does italicize `*...*` in markdown.
9. **Rules currency.** The local rules are the 2019 consolidated copy (see above).
10. **Not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and a `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
11. **Page 6 gap.** Page 6 ends about a third of the way up the page; Argument II moves to page 7 with its heading. Seen in the fonts pass; not a font effect, and the cause was not investigated.

[Formbook index](../../../../../../README.md) | [District Court, D. Mass.](../README.md)
