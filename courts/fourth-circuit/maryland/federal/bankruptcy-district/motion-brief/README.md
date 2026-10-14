# mdb: motion-brief

Doc type: **memorandum of fact and law in support of a motion** (Local Bankruptcy Rule 9013-2) in an adversary proceeding in the United States Bankruptcy Court for the District of Maryland (`mdb`). Typical filing: "Memorandum in Support of Motion for Abstention and Remand".
Folder: `courts/fourth-circuit/maryland/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-engelhorn-25-00159-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-engelhorn-memorandum.md` (an abridged transcription, see "Transcription") |
| render | ok: `samples/OUTPUT-engelhorn-memorandum.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-engelhorn-memorandum.pdf` and `samples/OVERLAY-engelhorn-memorandum.txt` (12 sample pages paired with 22 exemplar pages) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed; pages 1-8 in the render before the final signature change, which does not touch them; pages 9-12 in the final render) |

File names follow the repo's role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`), because `tools/overlay.sh` reads and writes those names.

## Governing rules

| Source | Requirement | Where it is in the template |
|---|---|---|
| Local Bankruptcy Rule 9013-2 (Ver. 25.01, Dec. 1, 2025, printed p. 76), https://www.mdb.uscourts.gov/files/localrules.pdf, fetched 2026-10-14 | A party must file with each motion a brief memorandum of fact and law entitling the movant to the relief claimed, or a statement that no memorandum will be filed. | The doc type itself: the body is the memorandum. |
| Local Rule 9013-1(a) (p. 76) | Motions and memoranda in support: caption with the court's name, the case name, the case number, the chapter of the case, and a descriptive title; in an adversary, the names of the plaintiff and the defendant; the relevant facts, legal argument, and reference to adequate evidence; compliance with the ECF procedures. | `caption`, `case_number`, `adv_number`, `title`. The facts, argument and evidence references are the author's content. |
| Local Rule 9004-1 (p. 66) | Legible; at least a one-inch margin on each side; 12-point or larger type for text, 10-point or larger for footnotes. | `page-margin = 1in`, `type-size = 12pt`; footer also 12 pt (the template has no footnotes). |
| Local Bankruptcy Rule 9004-1, text checked 2026-10-14 in the PDF of the same URL (p. 66) | Typeface: none named. The rule requires "12 point or larger font for text", and names no face. | `font-family = "EB Garamond"` kept (see Known gaps, item 2). |
| Fed. R. Bankr. P. 9004(a), (b), https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14 | (a) clearly legible. (b) caption: court's name; the case's title; case number and adversary number; brief designation. | `caption` and the title line. |
| Local Rule 9013-4(a), (b) (p. 78) | A certificate of service is required for every motion or other paper; it is placed at the end of the item served and endorsed by an attorney of record. | `# Certificate of Service` chunk, which starts a new page and follows the signature block. |
| Local Rule 9013-3(a) (p. 77) and Appendix H § IV.B | A request for relief (a motion) must be accompanied by a proposed order that conforms to 9013-3 (the 3-inch top margin, the service list, "End of Order"). | **Not produced here.** The proposed order is a separate document that must accompany the motion this memorandum supports. |
| Fed. R. Civ. P. 10(a) (via Fed. R. Bankr. P. 7010) | Caption and title. | Caption as above. **Rule 7010 text not verified verbatim** (see the complaint README). |

## Layout

- Letter size; 1-inch margins; EB Garamond 12 pt; double spacing on a 24 pt pitch (`pitch`), every block rounded up to the pitch so headings and paragraphs stay on one grid.
- Court name lines and the division (from the frontmatter), centered and bold; caption with a party column closed by a ")" column and a right column for the case number and adversary number; title in bold caps between two rules; then the lead-in paragraph.
- Body paragraphs are indented and **not numbered** (a memorandum is not a numbered pleading).
- Headings: `#` centered, bold, underlined caps (INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION); `##` bold at the margin (roman numerals); `###` bold (lettered sub-headings). A heading is kept with the paragraph after it.
- Bold run-in headings for factors in a list of factors are written as bold text in the paragraph.
- Block quotations are single-spaced and indented (used for the certificate's service list).
- Signature block: date, "Respectfully submitted:", the firm, and the signer block at the right half of the page. The conclusion's last paragraph and the signature block are kept together, so a signature never stands alone on a page.
- The certificate of service starts on a new page, after the signature (Local Rule 9013-4(b)).
- Page number centered at the foot of each page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court` (list of lines), `division`, `caption.in_re` (optional: `names`, `designation`), `caption.parties` (list of `names`, `designation`; "v." inserted between), `case_number`, `adv_number`, `chapter` (optional), `title`, `lead_in` (unnumbered first paragraph), `date`, `signature` (`firm`, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = section heading, `##` = sub-heading, `###` = lettered sub-heading. A plain chunk is an unnumbered indented paragraph. A `>` chunk is a single-spaced block quotation (the certificate's service list uses hard line breaks with a trailing backslash, which is sample content, not template code).
- The chunk `# Certificate of Service` marks where the certificate starts; the template places the signature block before it.

## Transcription (what the sample contains)

The sample is an abridged transcription of Doc 43-1 (22 pages) and renders to 12 pages:

- Caption, title, lead-in, signature block, and the full certificate of service, transcribed from the exemplar.
- Introduction (all paragraphs; the exemplar's footnotes 1-5 are omitted).
- Background, condensed: the Bolog misconduct, the Swain Landing transfer, the three Swain claims, the Adjacent and Unrelated claims, and the Counterclaims. The exemplar's footnotes 6-9 are omitted.
- Argument, the Introduction to the argument and Sections I (A and B), II and III (A and B). The exemplar's footnotes 10-12 are omitted. Within III.A the sample keeps the factors for efficiency, state-law predominance, a related state-court proceeding, a federal jurisdictional basis apart from the bankruptcy, forum shopping, jury trial, and non-debtor parties. **Omitted from III.A:** factor iii (difficult or unsettled state law), factor vi (relatedness), factor vii (substance rather than form), factor viii (severance), and factor ix (the burden on the docket). Section III.B keeps the comity and prejudice factors and omits the others.
- Conclusion, signature block, certificate of service.
- Exhibit references are kept as written. Footnote numbers are not carried into the text.

## Known gaps and open choices

1. **Only one exemplar; tier 2 is not met.** The search (CourtListener RECAP, `court=mdb`) found other memoranda and motions in this court, for example the motion to dismiss in Jenk's Best Living, LLC (Case 26-17758, Doc 47, 24 pp., filed by YSA Investments 1, LLC), but those are motions, not memoranda, or are too large to use as exemplars. Only one memorandum in support was collected. A second filer should be collected before this doc type is judged against tier 2.
2. **Typeface: no court-named face; EB Garamond kept.** Local Rule 9004-1 requires 12-point or larger font and names no typeface, and Fed. R. Bankr. P. 9004 names none either. Per `docs/FONTS.md` ("No face named" row), the template keeps EB Garamond. The exemplar is in Times New Roman, which is the filer's choice, not a rule. The difference is visual only: EB Garamond looks smaller at 12 pt. Substitute: none (`EB Garamond` is the vendored face).
3. **Caption style.** The exemplar uses an asterisk column; the template uses the ")" column of the complaint. Both are seen in this court. Recorded as ACCEPTED.
4. **Certificate of service runs to two pages.** The exemplar's certificate also runs to two pages (its pp. 21-22). The template does not compress the service list to fit one page. Recorded as ACCEPTED.
5. **No proposed order.** Local Rule 9013-3(a) requires one with a motion; it is not produced by this doc type.
6. **Page limit.** No page limit was located in the local rules text (a search for "page limit" returned nothing relevant). None is enforced by the template.

## Overlay

`samples/OVERLAY-engelhorn-memorandum.pdf` is the red/blue comparison: red is our render, blue is the filed memorandum. Pages are paired by shared words; word overlap per page is 34%-89%; the page map is `OVERLAY-engelhorn-memorandum.txt`. The overlay was built against the filed exemplar fetched from the SOURCE.md URL (the PDF is not in this snapshot). The sample is abridged, and its page 12 is the second page of the certificate, which the exemplar places on its page 22. The low overlaps on pages 6, 8 and 10 may reflect omitted text, and the font difference lowers every page's score; the page map does not separate the two causes. The overlay is a diagnostic, not a score.

## Review of the rendered pages (Gate 2 rows)

Every page was rendered at 60 dpi and viewed. Defects found on the first renders and fixed:

- The same overprint of blocks as the complaint (trailing leading not counted in block height). Fixed with `on-grid`.
- Section headings at the default heading size. Fixed: 12 pt, bold.
- The signature block came after the certificate of service. Fixed: the signature precedes the certificate, which starts a new page (Local Rule 9013-4(b); the exemplar does the same).
- The signature block stood alone on a page with no text above it. Fixed: the conclusion's heading and paragraph are kept in the same unbreakable block as the signature.

| Page | Content | Result |
|---|---|---|
| 1 | Court lines, division, caption, title, lead-in, Introduction (first two paragraphs) | Pass. Caption on one grid; no spill. |
| 2 | Introduction, continued | Pass. |
| 3 | Introduction (fourth reason), BACKGROUND heading, first Background paragraphs | Pass. |
| 4 | Background (Swain claims, Counterclaims) | Pass. |
| 5 | ARGUMENT heading, opening, Section I heading, I.A | Pass. |
| 6 | I.B, II (two-line heading), III (heading and opening) | Pass. Two-line headings kept with their text. |
| 7 | III.A heading, factors (efficiency through existence of a jurisdictional basis) | Pass. |
| 8 | III.A factors (forum shopping through non-debtor parties), III.A closing sentence | Pass. Ends with white space: the next block would not fit. |
| 9 | III.B (equitable remand), ends with the prejudice paragraph | Pass. Ends with white space: the conclusion moved to the next page, with its signature. |
| 10 | CONCLUSION paragraph, date, "Respectfully submitted," firm and signer block | Pass. The signature is not alone: the conclusion is on the same page. |
| 11 | CERTIFICATE OF SERVICE (new page), service list | Pass. |
| 12 | Last service recipients, "/s/" line and signer name | Pass. Two lines of the certificate spill to this page, as in the exemplar. |
