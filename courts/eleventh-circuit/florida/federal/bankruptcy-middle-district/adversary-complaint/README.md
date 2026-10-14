# flmb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Middle District of Florida (`flmb`), Fed. R. Bankr. P. 7001 proceedings.
Folder: `courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-one-fat-frog-6-26-ap-00095-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-budgen-complaint.md`: the full text of the 12-page filing (every paragraph, both footnotes, the transfer table, the prayers, the signature block) |
| render | ok: `samples/OUTPUT-budgen-complaint.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no typst warnings |
| overlay | ok: `samples/OVERLAY-budgen-complaint.pdf` and `samples/OVERLAY-budgen-complaint.txt` (page map: 10 of 10 sample pages paired) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed; see the table at the end) |
| status in `court.json` | not set (the brief does not ask for it) |

## Governing rules

Verified 2026-10-14 from the sources in the Source column. Local rules are the Court's posted PDFs (`flmb.uscourts.gov/localrules/rules/<n>.pdf`); the rule texts were read in full.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 | Form of pleadings in an adversary proceeding. Source: LII title only; the text of Rule 7010 was not retrieved, so this row cites the title and the rules that 7010 points to below. | `flmb-adversary-complaint.typ` (caption, paragraphs). |
| Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number and adversary number, brief designation of the document. Source: LII. | `caption()`, `court-title()`, `full-title()`. |
| Fed. R. Civ. P. 10(a) (as applied by Rule 7010) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. Source: LII. | `caption()` (every party is named in the caption). |
| Fed. R. Civ. P. 10(b) (as applied) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. Source: LII. | `body-chunks()` numbers every paragraph that is not marked `^`. |
| Fed. R. Bankr. P. 7008(a) | The jurisdiction allegation names the case, its number and chapter, and the district and division; the pleader states whether it consents to final orders. Source: LII. | Author content (the filing's paragraphs 1 to 4). The template does not check the wording. |
| Local Rule 9004-1(a) | First page: the caption as in the Official Forms; the title states the name and designation of the party submitting the paper, and a descriptive title. Source: flmb `localrules/rules/9004-1.pdf`. | `caption()`, `full-title()`. See the open question below on the title. |
| Local Rule 9004-1(b) | Demand for jury trial: the title includes "Demand for Jury Trial". | `full-title()` adds it when `jury_demand: true`. Not used by this sample. |
| Local Rule 7001-1(b), 9004-1(c) | Injunctive relief: the title includes "Injunctive Relief Sought". | `full-title()` adds it when `injunctive_relief: true`. Not used by this sample. |
| Local Rule 7001-1(c)-(f) | Service of the summons, complaint and a copy of the rule within seven days; service on all defendants within 28 days; default by 60 days. Source: flmb `localrules/rules/7001-1.pdf`. | Not a form requirement; not produced here. |
| Local Rule 5005-1(d) | Paper: typewritten, single-sided, 8 1/2 by 11 inches, one-inch margins. Source: flmb `localrules/rules/5005-1.pdf`. | `#set page(paper: "us-letter", margin: 1in)`. |
| Court Style Guide, Part II.A (Whole Document) | Times New Roman, 12-point font; one-inch margins on 8 1/2 by 11 inch paper; page numbers centered in the footer on every page except the first. Source: flmb `cmecf/documents/styleguide.pdf` (updated 2/3/2014). The Style Guide states this under its order format. Local Rule 7001-1(k)(2) applies the Style Guide to motions; this template applies the same whole-document format to the complaint, which is the reading taken here (the Style Guide does not say whether it covers complaints). | `font-family`, `type-size`, `margin`, `footer-page()`. The font is a known gap (below). |
| Style (exemplar, convention) | Double spaced body; justified text; numbered paragraphs at a half-inch indent; lettered sub-items and prayers. | `body-leading = 1.35em` (24 pt pitch at 12 pt, measured in the render); `set par(justify: true)`; `set enum(numbering: "a.")`. |

Not produced by this template (separate filings, not part of the pleading): the adversary cover sheet, the summons, the proof of service required by Local Rule 7001-1(d), the corporate ownership statement, and the filing fee receipt. Not verified whether each is required with this complaint; the Court's filing checklist should be checked.

## Layout

- Court title (three lines, bold), the caption (an "In re:" block with the debtor, the case number and chapter at right; the plaintiff and defendant sides with "v." between them and the adversary number at right, the two party blocks closed by rules), the bold title in capitals, then the body. No cover page.
- Body: headings level 1 centered bold capitals, level 2 centered bold, level 3 centered bold italic, all kept with the next paragraph; numbered paragraphs at a half-inch first-line indent; lettered lists (a., b., ...); a markdown table (the transfer chart).
- Signature block at right (firm, then "By: /s/" and the signer), not kept across a page break.
- Footer: page number centered on every page except the first.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division` (e.g. `Orlando`, printed "ORLANDO DIVISION"), `in_re` (debtor names), `case_number`, `chapter`, `caption` (two sides, each `names` and `designation`; "v." is inserted), `adversary_number`, `title`, `signature` (`firm` lines, `signer`, `lines`), optional `date`, `jury_demand`, `injunctive_relief`.
- Body: `# Heading` (level 1), `## Heading` (level 2), `### Heading` (level 3). A blank-line-separated paragraph is numbered 1, 2, ... by the template. A paragraph that starts with `^` is not numbered (the lead-in, the reservation of rights, the prayers); the template removes the `^`. A markdown list (`1.`, `2.`, ...) is lettered a., b., ... A markdown table (GFM pipes) is centered and unruled.
- Footnotes: `text[^1]` in the text and `[^1]: text` anywhere in the file (definitions are not numbered; the template renders each with the paragraph that cites it).
- Do not type paragraph numbers: the template numbers them.

## Known gaps and open choices

1. **Font (tier 1, not met).** The Style Guide asks for Times New Roman, 12 point. The only fonts vendored in `fonts/` are EB Garamond, and `fonts/` is a shared directory this work may not change. The template uses EB Garamond at 12 point, so the typeface differs from the mandated one and the page count differs (10 pages here, 12 in the filing; EB Garamond sets narrower than Times). **To close:** vendor a Times-metric serif (for example a Liberation Serif build) into `fonts/` and change `font-family` in `flmb-adversary-complaint.typ`. Nothing else in the template depends on the face.
2. **Title and party designation (open question for the filer).** Local Rule 9004-1(a) asks that the title "state in the title the name and designation of the party" submitting the paper. The filed title ("Complaint to Avoid and Recover Fraudulent Transfers") does not name the Trustee; the designation appears in the first paragraph and the caption. The sample keeps the filed title. Whether the title must carry the designation is a reading question, not settled here.
3. **Numbering of the filing (exemplar defect, not a template defect).** The filed complaint numbers its jurisdiction paragraphs "1" and "1", so every later paragraph of the filing is one lower than the template's continuous numbering. The filing's own cross-references ("paragraphs 1 through 25") therefore point one paragraph short of the template's numbers. The template numbers continuously (Rule 10(b)).
4. **Italics.** Case names and "In re" are italic in the sample by transcriber's judgement; the exemplar's text layer does not carry italic markup. Defined terms are underlined in the motion exemplar, not in the complaint; the template does not reproduce underlining.
5. **Footer.** Page numbers only, centered; the CM/ECF stamp at the top of each filed page is not reproduced.
6. **Justification.** The exemplar is set justified (judged by eye from the line ends on its page images); the template is justified.
7. **Signature.** The filed signature block has no space for a handwritten signature beyond the "/s/" line, as in the exemplar. The template keeps the block together and at the right.
8. **Tools not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, not this doc-type shape; `tools/` is shared and was not changed. The gates were not run; the render, overlay and page review below are the checks run.
9. **Local Rule 7001-1 deadlines and certificates.** Not a form requirement of the complaint; not produced.

## Review of the rendered pages (`samples/OUTPUT-budgen-complaint.pdf`, 60 dpi, every page viewed)

| Page | Result |
|---|---|
| 1 | Court title, caption (In re block with case number and chapter; plaintiff and defendant with the adversary number at "v."), bold title, lead-in, paragraphs 1 to 4 with the first footnote. No page number on page 1. Pass. |
| 2 | Paragraphs 5 to 13, the "THE PARTIES" and "FACTUAL BACKGROUND" headings, the sub-headings, the second footnote at the foot. Pass. |
| 3 | Paragraphs 14 to 24; the transfer table centered without rules; the "Debtor's Creditors" heading. Pass. |
| 4 | Paragraphs 25 to 31; the Count 1 heading (three lines, centered); lettered items a to d. Pass. |
| 5 | Items e to h; paragraphs 32 to 35; the WHEREFORE paragraph unnumbered. Pass. |
| 6 | Count 2 heading; paragraphs 36 to 46. Pass. |
| 7 | Paragraphs 47 to 55; the Count 3 heading; the first lettered item of paragraph 55 at the foot. Pass. |
| 8 | Items b and c of paragraph 55; paragraphs 56 to 62; the Count 4 heading. Pass. |
| 9 | Paragraphs 63 to 67; the WHEREFORE with lettered items a to e (the prayer list breaks cleanly). Pass. |
| 10 | Reservation of rights (unnumbered), the signature block at right, page number 10. No heading is left at a page foot. Pass. |

Overlay (`samples/OVERLAY-budgen-complaint.txt`): the word-overlap pairing matches each sample page to the filed page with the most shared words (52% to 81%); pages 3 to 10 pair with a later filed page, as expected because the filing's cover and counts take more room in Times. The overlay is a diagnostic, not a score.

## How to build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick
sh tools/render.sh courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/adversary-complaint samples/INPUT-budgen-complaint.md
sh tools/overlay.sh courts/eleventh-circuit/florida/federal/bankruptcy-middle-district/adversary-complaint budgen-complaint
```

`render.sh` writes `samples/OUTPUT-budgen-complaint.pdf` and `overlay.sh` writes `samples/OVERLAY-budgen-complaint.pdf` and `.txt`: the names the tools read and write by default.
