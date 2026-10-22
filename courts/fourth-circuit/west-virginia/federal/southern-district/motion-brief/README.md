# wvsd: motion-brief (memorandum of law supporting a Rule 12(b) motion to dismiss)

Doc type: **memorandum of law in support of a motion to dismiss** in the United States District Court for the Southern District of West Virginia (`wvsd`).
Folder: `courts/fourth-circuit/west-virginia/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, a state party; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the filing: caption, Introduction through Point III, Conclusion, signature; see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages (caption page plus body numbered 1 to 11), typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-14; the same page count and the same overlay map as before; the earlier EB Garamond render, before fb-595.68: the template now sets Times New Roman) |
| overlay | ok: `usage/OVERLAY-castro-motion-brief.pdf` and `OVERLAY-castro-motion-brief.txt` (re-run 2026-10-14 against `usage/FILED-EXAMPLE-motion-brief.pdf`, restored from the URL in `usage/SOURCE.md`; the file was missing from the snapshot, 24 pages, sha256 `e3906afa18128f556017c7baedc36c667ae7404a627c97864a9ba4dd0516b0ae`) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed on 2026-10-14, on the earlier EB Garamond render) |

File names: the tools write `OUTPUT-<id>.pdf` (render) and `OVERLAY-<id>.pdf/.txt` (overlay) by default, so those are the names used here. The brief's `<id>.pdf` and `<id>-overlay.pdf` names were not used, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR Civ P 7.1(a)(2) | A memorandum of not more than 20 pages must accompany a motion to dismiss. | Not asserted by the template (see Known gaps). |
| LR Civ P 7.1(a)(3) | 8½ × 11 inch paper; text double-spaced; quotations of more than two lines may be indented and single-spaced; headings and footnotes may be single-spaced; margins of at least one inch on all four sides; page numbers may sit in the margin. | `page-w`, `page-h`, `margin = 1in`, `pitch-body = 24pt` (double spacing at 12 pt), `pitch-single = 13.8pt`; quotations and footnotes single-spaced; page number centered in the bottom margin. |
| LR Civ P 7.1(a)(4) | Either a proportionally spaced or monospaced face; a proportionally spaced face must be 12 point or larger; the face must be clearly legible as determined by the judicial officer. Times New Roman, Courier New, Arial, Century Gothic, Garamond, Georgia and Century Schoolbook are presumed legible. No face is named as required. | Typeface row: face required = none (any proportional face at 12 pt or larger; the rule's presumed-legible list includes Garamond). Times New Roman, on the list, per `docs/FONTS.md` rule 6: `font-family = ("Times New Roman", "Liberation Serif")` (the pinned install; Liberation Serif from `fonts/` as fallback); EB Garamond until fb-595.68. Fit: not applicable. `type-size = 12pt`, footnotes at 12 pt. |
| LR Civ P 7.1(a)(6) | A motion to dismiss is filed as a separate pleading. | The template produces the memorandum only; the motion is a separate document (see Known gaps for the exemplar). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `caption` (court title, parties, "Civil Action No.", judge) and `brief_title`. |
| Fed. R. Civ. P. 12(b) | Defenses by motion, including 12(b)(1) and 12(b)(6). | Author content; the template does not check the wording. |

Sources and dates:
- Local rules: *Local Rules of Procedure, Southern District of West Virginia*, amended June 8, 2017, https://www.wvsd.uscourts.gov/sites/wvsd/files/LocalRulesofProcedure-June2017.pdf, fetched 2026-10-14 (the PDF has 95 pages; LR Civ P 7.1 is at printed pp. 6 to 8). The court's September 23, 2025 general order appointed local-rules advisory committees to review and align the rules; I found no amended text as of 2026-10-14. The rules are therefore taken as "the version posted on 2026-10-14," and any amendment from the committee review would need a new check.
- Fed. R. Civ. P. 10(a), 12(b): https://www.law.cornell.edu/rules/frcp/rule_10 and https://www.law.cornell.edu/rules/frcp/rule_12, fetched 2026-10-14.

## Layout

- Caption page: the court title (three centered bold lines, the division from `division`), the caption (parties, a column of ")" marks, and the case number and judge at the right), the brief title in bold capitals, and the counsel block at the lower left of the block indent. The caption page carries no page number.
- Body: numbered from 1 after the caption page, double-spaced, first-line indent 0.5 inch, left-aligned. Headings: level 1 centered bold (INTRODUCTION, FACTUAL BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION); level 2 bold with an automatic Roman numeral (I., II.); level 3 an automatic capital letter (A.); level 4 an arabic number (1.); level 5 a lowercase letter (a.).
- Signature block after the Conclusion: "Dated:" and the signature lines (the `signature` list from the frontmatter, typed as given, including the "/s/" line), kept together on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the markdown body. Frontmatter fields: `case_number`, `judge`, `division`, `caption` (list of sides: `names` as lines, `designation`, and an optional `lead`, which defaults to "v." between sides and is "" for none), `civil_action`, `brief_title`, `counsel` (list of groups: `names`, `lines`), `date`, `signature` (list of single-spaced lines; "" is a blank line).
- Body: `#` for the section headings (no numbers typed), `##` for point headings and deeper levels as listed above; footnotes `text[^1]` with `[^1]: ...` definitions; block quotations with `>`; case names roman, unless the sample writes `*...*`.
- Not supported: tables, a table of contents or authorities (not required by the local rules; the exemplar has none), raw typst.

## Gate 2 review (every page, 60 dpi; the 12-page EB Garamond render, before fb-595.68)

- p.1 (caption): court title, caption with ")" column, case number and judge at right, title, counsel block. No overlap after the spacing fix. Pass.
- p.2 (body 1): INTRODUCTION centered; paragraphs double-spaced; no page-number on the caption page. Pass.
- p.3 to p.4: FACTUAL BACKGROUND and LEGAL STANDARD centered; citations with "Id." and "¶" wrap normally. Pass.
- p.5 to p.7: ARGUMENT centered; point I heading "I." with hanging text; sub-paragraphs indented. Pass.
- p.8 (body 7): point II heading and its paragraphs. Pass.
- p.9 (body 8): point III heading; footnotes 1 and 2 at 12 pt, single-spaced, separated from the body. Pass.
- p.10 (body 9): point III continues. Pass.
- p.11 (body 10): footnote 3 at the foot of the page; no orphan heading. Pass.
- p.12 (body 11): Conclusion, "Dated:" line, signature block kept together at the right of the page; page number "11" at the foot. Pass.

The first render showed overlapping caption and counsel lines and paragraphs colliding at breaks (typst applies `leading` only within a paragraph, so the grid rows and stacks needed an explicit gap and the paragraph `spacing` needed the leading value). Both are fixed. The second render showed headings unstyled because show rules at the top level of an imported module do not reach the importing document; the rules are now inside `memorandum()`.

## Overlay (red = ours, blue = filed, black = both)

`usage/OVERLAY-castro-motion-brief.pdf` pairs each sample page with the filed page sharing the most words: p.1 with filed p.3 (91.8%), p.2 with filed p.4 (86.0%), p.3 with p.5 (69.6%), p.4 with p.6 (52.6%), p.5 with p.8 (53.7%), p.6 with p.9 (67.1%), p.7 with p.10 (83.5%), p.8 with p.11 (76.1%), p.9 with p.12 (53.1%), p.10 with p.14 (50.4%), p.11 with p.15 (74.4%), p.12 with p.2 (30.0%). The pairing is by words, not position, so the low-overlap pages are where the sample's line breaks or omitted text differ from the filed page. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Sample is a portion.** Point III's last paragraphs and all of Point IV are omitted from the sample (the Conclusion follows Point III). The filed memorandum runs 21 numbered pages; the sample is 11 body pages.
2. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met. The filer is a state intervenor, represented by the Attorney General's office, not a private party; its format may differ from a typical private filer's.
3. **The exemplar combines the motion and the memorandum in one document (ECF No. 44).** LR Civ P 7.1(a)(6) says a motion to dismiss is a separate pleading. The filed memorandum is the separate pleading; the template produces only the memorandum. The separate motion (ECF No. 45, 2 pages) was not used as the exemplar.
4. **Length not asserted.** LR Civ P 7.1(a)(2) allows 20 pages. The filed memorandum's numbered body runs to page 20 with the signature on page 21, so the exemplar is at the limit. The template does not count pages; check the body length by hand before filing.
5. **Italics.** The exemplar's text layer has no italic markup, so case names are roman in the sample. The template italicizes `*...*`, so a future sample can carry italics.
6. **Typeface.** Times New Roman, on the rule's presumed-legible list and the house standard (`docs/FONTS.md` rule 6). Until fb-595.68 the template used EB Garamond, whose smaller x-height made the text look smaller than a Times filing.
7. **Justification.** Body text is left-aligned. The exemplar's justification could not be read from its text layer; not asserted.
8. **No certificate of service and no table of contents or authorities.** Neither is in the exemplar, and the local rules do not require a table of contents or authorities for this brief. A certificate of service is not produced; check what the court's ECF practice requires before filing.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court root, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run; render, overlay and the page review above are the checks for this doc type.

## Searches tried (exemplar)

- CourtListener search API, `court=wvsd`, `type=r`, for complaints and motions to dismiss with stored PDFs (`filepath_local`). Only opinions and a few other filings have stored PDFs; the wvsd motions and memoranda listed for this court (Perkins v. The Associated Press, 5:26-cv-00351; Brogan v. Vanderbilt Mortgage, 2:25-cv-00386; Branch v. Allergan, 1:26-cv-00019) had no stored PDF in the API results.
- CourtListener docket lookup for Castro v. Warner, 2:23-cv-00598 (docket id 237539): docs 1, 2, 44, 45, 46, 47 and 48 fetched from `storage.courtlistener.com/recap/`. Doc 44 is the memorandum (chosen). Doc 45 is the 2-page motion. Docs 46 to 48 were not used.
- WebSearch for S.D. W. Va. memoranda in support of motions to dismiss: no standalone memorandum PDF other than the Castro docket.
- Clearinghouse (clearinghouse.net) listed other S.D. W. Va. motion and memorandum documents but returned HTTP 403 to every request, so none could be downloaded.

## Engines

**docx** (`docx/`): fb render builds the reference document from `reference.xml` (`base="xengine"`, the shared cross-engine recipe in the typst face); `motion-brief.lua` builds the cover (caption table, title, counsel block at 3.25 in) and the numbered headings; the body and footnotes are pandoc's, in the styles of `reference.xml`.

- Matches the typst form: Times New Roman 12 pt; body lines exact 24 pt (double); caption, counsel, quotations, footnotes and signature lines exact 13.8 pt (single); 1 in margins on letter paper; cover without a page number; body numbered from 1; level 1 headings centered and bold, level 2 bold with I., A., 1., a. on the template's indents; no first-line indent for the paragraph after a heading; footnotes 12 pt single; the "Dated" line and signature block at 3.25 in, kept together.
- Differs (the earlier build by `build-reference.sh`, before the fb-595.68 cross-engine port; `eval.yaml` now gates the docx on typst's line and page breaks): the docx had 13 PDF pages (12 body) against typst's 12. LibreOffice places exact-spaced text about 3 to 11 pt lower on the page, so one line less fits per page; the last signature block is kept with the conclusion (same page in typst). Level 1 and 2 heading sizes follow typst's default (16.8 pt and 14.4 pt); levels 3 to 5 are 12 pt (the sample uses only levels 1 and 2). Caption blank rows differ from typst by a few points.
- Gates: `sh tools/check.sh <this folder> --engine docx` exits 2 (`Error: open .../checks.yaml: no such file or directory`; this snapshot has no `checks.yaml` for this court). No check ID is BLOCKED for a content reason.
