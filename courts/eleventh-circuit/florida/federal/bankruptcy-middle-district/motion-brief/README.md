# flmb: motion with incorporated memorandum

Doc type: **motion** (here a motion to dismiss with an incorporated memorandum of law) in the United States Bankruptcy Court for the Middle District of Florida (`flmb`), Fed. R. Bankr. P. 9013 motion practice.
Folder: `courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-sargeant-6-26-ap-00150-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`; SHA-256 checked against `SOURCE.md`) |
| sample md | `samples/INPUT-mac-haik-motion.md`: the full text of the 16-page motion as filed (caption, every section, the footnote, the conclusion, the date and signature block) |
| typeface | required: Times New Roman, 12 point (Style Guide II.A). Template: **Liberation Serif**, the metric-compatible substitute in `docs/FONTS.md`. Embedded: `LiberationSerif` family only (`pdffonts`). |
| render | ok: `samples/OUTPUT-mac-haik-motion.pdf`, 15 pages, typst 0.15.0, vendored Liberation Serif only, no typst warnings |
| overlay | ok: `samples/OVERLAY-mac-haik-motion.pdf` and `samples/OVERLAY-mac-haik-motion.txt` (page map: 15 of 15 sample pages paired) |
| pages reviewed | 15 of 15 (every page rendered at 60 dpi and viewed; see the table at the end) |
| status in `court.json` | not set (the brief does not ask for it) |

## Governing rules

Verified 2026-10-14 from the sources in the Source column. Local rules are the Court's posted PDFs (`flmb.uscourts.gov/localrules/rules/<n>.pdf`); each rule text was read in full.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013(a) | A request for an order is made by written motion. Source: LII. | The sample is a written motion. |
| Fed. R. Bankr. P. 9013(b) | A motion must state its grounds with particularity and set forth the relief requested. Source: LII. | Author content (the motion's argument). The template does not check it. |
| Fed. R. Bankr. P. 9004(b); Fed. R. Civ. P. 10(a) | Caption: court name, case title, case number and adversary number, designation of the document (see the complaint README). Source: LII. | `caption()`, `court-title()`, `full-title()`. |
| Fed. R. Bankr. P. 7012(b) (as cited in the motion) | Rule 12(b)(6) applies in adversary proceedings. Source: cited in the exemplar; not separately verified. | Author content. |
| Local Rule 9013-1(a) | A motion requests only one form of relief unless alternative forms are under the same provision. Source: flmb `localrules/rules/9013-1.pdf`. | Author content (the conclusion lists alternatives under §§ 1334(c) and 1412 in one motion). |
| Local Rule 9013-1(d)-(f) | Emergency motions, expedited consideration and injunctive relief must say so in the title or first page. Source: flmb `localrules/rules/9013-1.pdf`. | Not used by this sample. Only injunctive relief is in `full-title()`; emergency and expedited wording is not implemented. |
| Local Rule 9004-1(a)-(c) | Caption; the title states the name and designation of the submitting party and a descriptive title; jury demand and injunctive relief wording in the title. Source: flmb `localrules/rules/9004-1.pdf`. | `full-title()`; the sample's title includes the party designation ("Defendant Mac Haik Automotive Group's Motion ..."), as the exemplar does. |
| Local Rule 7001-1(k)(1) | One form of relief per motion (as above). | Author content. |
| Local Rule 7001-1(k)(2) | Motions, responses and replies comply with the Court's Style Guide; papers should be double spaced; a legal memorandum where appropriate. Source: flmb `localrules/rules/7001-1.pdf`. | Style Guide format (below); `body-leading`; the memorandum is incorporated in the motion. |
| Local Rule 7001-1(k)(3) | Absent leave, motions, responses, replies and supporting memoranda must not exceed **ten pages**; proofs of service, exhibits and the signature block are not counted. Source: flmb `localrules/rules/7001-1.pdf`. | **Not enforced.** The exemplar is 16 pages, and the sample renders to 15 (the body runs to page 14 and the last conclusion item and the signature block sit on page 15). Whether leave was granted for the exemplar is not in the record fetched. See open questions. |
| Local Rule 7001-1(k)(4) | Motions to dismiss (Rule 7012 motions) are served using the negative notice procedure of Local Rule 2002-4, with a legend that gives a 14-day response period and a reply within seven days. Source: flmb `localrules/rules/7001-1.pdf`. | **Not produced.** The filed motion has no negative-notice legend in its text layer, and the legend text (Local Rule 2002-4) was not retrieved. See open questions. |
| Local Rule 5005-1(d) | Paper: typewritten, single-sided, 8 1/2 by 11 inches, one-inch margins. Source: flmb `localrules/rules/5005-1.pdf`. | `#set page(paper: "us-letter", margin: 1in)`. |
| Court Style Guide, Part II.A | Times New Roman, 12-point font; one-inch margins; page numbers centered in the footer on every page except the first. Source: flmb `cmecf/documents/styleguide.pdf` (updated 2/3/2014). Applied to motions through Local Rule 7001-1(k)(2). | `font-family` (Liberation Serif, the substitute for Times New Roman; `docs/FONTS.md`), `type-size`, `margin`, `footer-page()`. |
| Style (exemplar, convention) | Double spaced; justified text; numbered paragraphs at a half-inch indent; unnumbered introduction and conclusion; flush-left bold section headings; lettered sub-headings in bold italic. | `body-leading`; `set par(justify: true)`; the `^` marker; `show heading` rules. |

Not produced by this template (separate filings or not verified as required): a certificate of service (the filed motion has none; service is through CM/ECF, and no rule read here requires a certificate for registered users); notices of hearing; proposed orders; the negative-notice legend (above).

## Layout

- Court title (three lines, bold), the caption (as in the complaint: "In re:" block, plaintiff and defendant sides with the adversary number at "v.", party blocks closed by rules), the bold title in capitals, the body, the conclusion, the date ("Dated:") at left and the signature block at right.
- Body: level 1 headings centered bold capitals (I. INTRODUCTION); level 2 headings bold, flush left (A. Counts ...); level 3 headings bold italic, indented (a. ...); numbered paragraphs from the first numbered section, unnumbered paragraphs marked with `^`; the conclusion as a list numbered 1., 2., ...
- Conclusion keeping (`body-chunks()` in `flmb-motion-brief.typ`): the conclusion heading and lead-in flow into the list; the list's last item is set in the same unbreakable block as the signature block, so the signature never stands alone on a page. The list items before it flow normally across pages. A conclusion list longer than the space left would need this changed. Verified on this render: no text runs into the bottom margin (`pdftotext -bbox`).
- Footer: page number centered on every page except the first.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division`, `in_re`, `case_number`, `chapter`, `caption` (two sides, `names` and `designation`), `adversary_label` (the exemplar's label, "Adversary No."; the default is "Adv. Case No."), `adversary_number`, `title` (in sentence case; the template capitalizes it), `date`, `signature` (`firm` lines, `signer`, `lines`), optional `jury_demand`, `injunctive_relief`.
- Body: `# Heading` (level 1), `## Heading` (level 2), `### Heading` (level 3). A blank-line-separated paragraph is numbered 1, 2, ... by the template. A paragraph that starts with `^` is unnumbered (the motion's introduction, the unnumbered paragraphs of Section I, the conclusion lead-in). A markdown list is numbered 1., 2., ... Footnotes: `text[^1]` and `[^1]: text`.
- Do not type paragraph numbers: the template numbers them.

## Known gaps and open choices

1. **Font (closed; metric-compatible substitute).** The Style Guide names Times New Roman, 12 point. The template now sets Liberation Serif at 12 point (`fonts/liberation-serif/`, SIL OFL 1.1), the substitute `docs/FONTS.md` gives for Times New Roman. The page count rose from 14 (EB Garamond) to 15 (Liberation Serif); the text is no longer metric-identical to the filing. Liberation Serif is designed to be metric-compatible with Times New Roman; it has not been checked against a Times New Roman file, since none is on this box (`docs/FONTS.md`).
2. **Page limit (open question for the filer).** Local Rule 7001-1(k)(3) limits a motion and its memorandum to ten pages absent leave. The filed motion is 16 pages, and the sample renders to 15. The template does not enforce the limit. Whether leave was granted for the filed motion was not checked on the docket. A motion of this length needs leave, or the argument needs to be cut to ten pages of text.
3. **Negative-notice legend (open question).** A motion to dismiss must be served by negative notice under Local Rule 2002-4 (Local Rule 7001-1(k)(4)), with a legend that gives a 14-day response period. The filed motion's text has no legend, and the legend text was not retrieved, so the template does not produce one. The filing's legend, if any, should come from the Court's Negative Notice List or the filer's CM/ECF event.
4. **Certificate of service.** The filed motion has none (checked in the text layer). Not produced.
5. **Italics and underlining.** Case names, signals and "*Id.*" are italic by transcriber's judgement (the text layer carries no italic markup). The filed motion underlines its defined terms (for example "Mac Haik", "Contract"); the template does not reproduce underlining.
6. **Font of the caption and the heading case.** The filed motion uses Times New Roman in the caption, title and body (`pdffonts`), and mixed-case subheadings; the template follows the same heading case and the substitute face.
7. **Tools not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, not this doc-type shape; `tools/` is shared and was not changed. The gates were not run; the render, overlay and page review below are the checks run.

## Review of the rendered pages (`samples/OUTPUT-mac-haik-motion.pdf`, 60 dpi, every page viewed)

Viewed on the Liberation Serif render (the current `OUTPUT`).

| Page | Result |
|---|---|
| 1 | Court title, caption (In re block; plaintiff; defendants with the adversary number at "v."), bold two-line title, the unnumbered opening paragraph, section I begins. No page number on page 1. Pass. |
| 2 | Section I (unnumbered paragraphs) to the end of the introduction; footnote 1 at the foot. Pass. |
| 3 | Section II begins; "A. The Underlying Transaction" (bold, flush left); paragraphs 1 and 2; "B. Prior Proceedings" with paragraph 3 begins. Pass. |
| 4 | Paragraph 3 (continued); "C. The Instant Complaint" (paragraph 4); section III and paragraph 5 (the Standard of Review citations). Pass. |
| 5 | Paragraph 5 (continued); section IV and the bold, three-line heading A; paragraphs 6 to 8. Pass. |
| 6 | Paragraphs 9 to 12 (the jurisdiction argument). Pass. |
| 7 | Paragraphs 13 to 15; heading B (two lines). Pass. |
| 8 | Paragraphs 16 to 20 (paragraph 20 continues onto page 9). Pass. |
| 9 | Paragraph 20 (continued); paragraphs 21 to 24; heading C (two lines). Pass. |
| 10 | Heading D; paragraphs 25 to 29; sub-headings a. and b. (bold italic). Pass. |
| 11 | Heading E; paragraphs 30 to 33; sub-heading a. (permissive abstention). Pass. |
| 12 | Paragraph 33 (continued); paragraphs 34 to 37; sub-heading b.; paragraph 38 begins. Pass. |
| 13 | Paragraph 38 (continued); paragraphs 39 and 40; sub-heading c. (two lines); paragraphs 41 to 44. Pass. |
| 14 | Section V, "V. CONCLUSION", with its lead-in; items 1 to 6 of the list. No heading or lead-in is left at the foot. Page number 14. Pass. |
| 15 | Item 7 (the last list item) and, with it, "Dated: September 11, 2026" at left and the "Respectfully submitted," block at right with the signature, bar number and e-mail addresses. Page number 15. Pass. |

Overlay (`samples/OVERLAY-mac-haik-motion.txt`): each sample page is paired with the filed page with the most shared words (27% to 90%); page 15 pairs weakly (27%) because it holds only the last item and the signature block. The overlay is a diagnostic, not a score.

## How to build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick
sh tools/render.sh courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/motion-brief samples/INPUT-mac-haik-motion.md
sh tools/overlay.sh courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/motion-brief mac-haik-motion
```

`render.sh` writes `samples/OUTPUT-mac-haik-motion.pdf` and `overlay.sh` writes `samples/OVERLAY-mac-haik-motion.pdf` and `.txt`: the names the tools read and write by default.

## Engines

- **typst** (primary): unchanged; see the sections above.
- **docx** (`docx/`): pandoc, `docx/reference.docx` (built by `sh docx/build-reference.sh` from `docx/parts/`: styles, numbering, footer) and `docx/flmb-pleading.lua`. Output: `samples/OUTPUT-mac-haik-motion.docx`.
  - Matches typst: Letter, one-inch margins; 12 point body with exact 24 pt double spacing; numbered paragraphs (bare numbers, half-inch first line) and unnumbered `^` paragraphs; the court title, caption (slash rule), title, and signature block built from the frontmatter; the conclusion's last item kept with the signature block; level 1 to 3 heading styles; footnotes at 12 point, single spaced; page numbers centered from page 2 (first-page footer empty).
  - Differs: the declared font is Times New Roman (the Style Guide's face); typst uses the Liberation Serif substitute. Caption and signature are two-column tables whose widths are fractions (pandoc writes them against its own base width; Word scales them, not verified). The caption rule is a paragraph border with a tab for the slash, not a drawn line. Lists take one of ten `Pleading List n` styles, so an eleventh ordered list in one sample fails the build.
  - docx BLOCKED: `docx.pdf` gates (Gate 0 and 1 on `samples/OUTPUT-mac-haik-motion.docx.pdf`, and the page review). LibreOffice is not installable from conda-forge; Debian packages extracted without root segfault at startup on this box. Pages reviewed: 0 of 0 (no `.docx.pdf` exists). The font-name proof cannot pass as written: the LibreOffice PDF would show the metric substitute, not Times New Roman. `tools/check.sh --engine docx` expects a court folder (`court.json`, `rules.md`) and was not run.
