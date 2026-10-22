# ohnd: motion-brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**, the memorandum that supports a Rule 12(b) motion, in the United States District Court for the Northern District of Ohio (`ohnd`).
Folder: `courts/sixth-circuit/ohio/federal/northern-district/motion-brief/` (one self-contained folder per doc type).

| Item | Status |
|---|---|
| exemplar | yes: 2 filers. `usage/FILED-EXAMPLE-motion-brief.pdf` (15 pp, U.S. Government, transcribed) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (29 pp, an individual defendant, with a table of contents and table of authorities; not transcribed). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: the whole 15-page memorandum (caption, every section, three footnotes, signature). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 15 pages, `tools/render.sh`, vendored Times New Roman only, no typst warnings; `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, 15 pages, breaking every line and page where typst does. |
| overlay | `just overlay <dir>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt` (gitignored, not committed). |
| pages reviewed | 14 of 14 (every page of the current PDF rendered at 60 dpi and viewed after the last template change). |
| content check | every word of the sample body and of its three footnotes appears in the PDF (compared as word counts, because footnotes sit at the foot of the page and dashes split at line ends; the body's word order was not compared). |
| `tools/check.sh` | typst: `RESULT: 9 checks passed, 0 failed`; docx: `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (358/358 lines, 15/15 pages), gated by `eval.yaml` (`params.cross_engine: gate`). |

## Governing rules

Verified 2026-10-14. Federal rules from Cornell LII (https://www.law.cornell.edu/rules/frcp/); local rules from the court's own PDFs (https://www.ohnd.uscourts.gov/).

| Rule | Requirement | Kind | Where in the template |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | M | `court-title`, `caption` (for a motion paper: the same caption as the complaint). |
| Fed. R. Civ. P. 12(b) (https://www.law.cornell.edu/rules/frcp/rule_12) | The defenses the motion may raise include "lack of subject-matter jurisdiction" and "failure to state a claim upon which relief can be granted"; the motion "must be made before pleading if a responsive pleading is allowed." | M (the motion; this memorandum supports it) | Author content; the template does not check the defense named. |
| N.D. Ohio L.R. 7.1(c) (https://www.ohnd.uscourts.gov/sites/ohnd/files/Rule_7_1%20redline.pdf) | "The moving party must serve and file with its motion a memorandum of the points and authorities on which it relies in support of the motion." | M | The memorandum is a separate document filed with the motion; the template produces the memorandum only. |
| N.D. Ohio L.R. 7.1(f) (same PDF) | Page limits: "memoranda relating to dispositive motions must not exceed ten (10) pages in length for expedited cases, twenty (20) pages for administrative, standard and unassigned cases, thirty (30) pages for complex cases, and forty (40) pages for mass tort cases"; "Memoranda relating to all other motions must not exceed fifteen (15) pages in length." A memorandum over 15 pages "must have a table of contents, a table of authorities cited, a brief statement of the issue(s) to be decided, and a summary of the argument presented." A dispositive memorandum "must be accompanied by a certification specifying the track, if any, to which the case has been assigned and a statement certifying that the memorandum adheres to the page limitations"; a modified limit must be stated in the certification. | M | `track-limits`, `limit`, `length-checks` (fails the build over the limit, and fails it for a memorandum over 15 pages without contents or without "issue" and "summary" headings), `contents: true` (TOC and TOA), `certification()`. |
| N.D. Ohio L.R. 10.1 (https://www.ohnd.uscourts.gov/sites/ohnd/files/CivilRules_Rule101.pdf, last revised 8/10/18) | 8 1/2 x 11 white paper; double-spaced except quoted material; a 1 1/2 inch top margin on the first page; "Each page shall be numbered consecutively."; signature details. | M | `first-page-top`, `pitch-body`, the consecutive footer page number, `signature-block`, quotations single-spaced in `show quote`. |

Notes on the sources:
- The L.R. 7.1 PDF on the court's site is a redline (its footer reads "Last revised 12/1/16 1/6/20"). The text read is the one shown with the 1/6/20 revision; check it against the adopted rule before relying on any page limit.
- The Hammill exemplar (15 pages, U.S. Government) carries no L.R. 7.1(f) certification inside the memorandum. The rule requires one for a dispositive memorandum; the template follows the rule, not the exemplar.
- The track is not stated in the exemplar. The sample says `track: "standard"`, which is an author's choice for the sample; a real filing takes the track the case is assigned.

## Layout

- Caption page: the court title (with the division), the party column with ")" marks, the case number and judge at the right, and the title in bold, centered (a measure of 5.6 in, so the words wrap).
- The memorandum begins on the caption page when no contents are requested (as the Hammill exemplar does). With `contents: true`, the caption page is followed by a table of contents page, then a table of authorities page, then the body.
- Body: double-spaced 12 pt at 27.6 pt, twice the 13.8 pt single pitch; every paragraph indented 0.5 in (as in the exemplar). Every line is a box of its pitch on the shared cross-engine layout model (`lib/typst/xengine.typ`): no kerning, ligatures or hyphenation, first-fit ragged-right lines, explicit spaces between blocks.
- Headings: level 1 bold, left, hanging 0.5 in ("I. BACKGROUND"); level 2 bold, indented 0.5 in ("A. ..."); level 3 bold, indented 1 in ("i. ..."). Each heading is single-spaced, a single line (13.8 pt) below the text above it, and sticky (kept with the paragraph after it). The numerals are typed in the sample as filed; the template does not number headings.
- Footnotes: 12 pt, single-spaced (13.8 pt), with a 30% rule above them, 10.5 pt from the text to the first note and 7 pt below each note, as LibreOffice sets Word's footnotes (a note's line moves on with the line before it: `footnote-widows: false`). (LR 10.1 sets no footnote size; 12 pt is the filed convention.)
- Block quotations: single-spaced, indented 0.5 in on both sides, a single line above and below.
- Signature: single-spaced, from 2.8 in ("Dated:" and the date, when given, at its left), a double line below the text; the last paragraph of the body is kept with it, so the signature never stands alone.
- Certification: a double line after the signature block, "CERTIFICATION OF TRACK AND PAGE LIMIT", with the track, the limit and any modifying order from frontmatter, kept whole. It is not counted in the page limit.

## Contents and the table of authorities (L.R. 7.1(f))

- `contents: true` prints a table of contents (outline of the headings, with dot leaders and page numbers) and a table of authorities.
- The table of authorities is built from links in the body with the target `toa:KEY`, with the full citation as the link text. Each `toa:` link marks the page where its authority starts. A key missing from `authorities:` in the frontmatter stops the build. Authorities are grouped (cases, constitutional provisions, statutes, regulations, rules, other) and sorted; an authority on 7 or more pages prints "passim".
- The sample is 14 pages, so it does not need contents, and the committed sample does not use the table of authorities. The TOC and TOA paths were exercised with a scratch variant (contents on, three `toa:` links, the issues and summary headings), which rendered as 17 pages with a TOC on page 2 and a TOA on page 3; the scratch file was deleted. The two L.R. 7.1(f) build failures were also exercised with scratch variants: an `expedited` track (10 pages) on this 14-page memorandum failed with "L.R. 7.1(f) allows 10 for this track", and a 17-page memorandum without contents failed with "requires a table of contents and a table of authorities above 15 pages".

## Review of the rendered pages (current PDF)

Typst and docx renders of `usage/INPUT-motion-brief.md` (fb-595.68.30), every page rendered at 60 dpi and viewed side by side; compared with the Hammill exemplar (pages 1 to 3 as images, the rest by its text layer). The two engines break every line and page alike (XENG-001..003 PASS), so each row holds for both.

| Page | Finding | Status |
|---|---|---|
| 1 | Court title with the division below the 1 1/2 in top space (L.R. 10.1); caption with a ")" on every line (two for the wrapped second defendant), case number and judge; the bold title in three centered lines; the body starts on the caption page, as filed. | PASS |
| 2 | I. BACKGROUND (bold, left); A. heading half an inch in; footnote 1 at the foot under its rule. | PASS |
| 3 | B. heading (two lines, hanging). | PASS |
| 4 | The Amended Complaint paragraphs; footnote 2 at the foot. | PASS |
| 5 | II. LEGAL STANDARD; the Rule 12(b)(1) and 12(b)(6) standards, citations in italics. | PASS |
| 6 | III. ARGUMENT; heading A. (three lines, hanging); standing. | PASS |
| 7 | Footnote 3 at the foot; the page ends a line early because heading B. moves on with its paragraph (sticky). | PASS |
| 8 | B. heading; the *Mann Construction* paragraphs. | PASS |
| 9 | C. and i. headings; *Trump v. CASA* citations. | PASS |
| 10 | The equitable-powers and *Casa* paragraphs. | PASS |
| 11 | ii. heading (two lines, hanging); § 706 discussion. | PASS |
| 12 | iii. heading (two lines); sovereign-immunity paragraphs. | PASS |
| 13 | The adequate-remedy paragraphs. | PASS |
| 14 | Ends with white space: the conclusion is kept with the signature, so it moves to p.15. | ACCEPTED: pagination, see open choice 5 |
| 15 | IV. CONCLUSION (the last paragraph), "Respectfully submitted," the firm and signature lines at 2.8 in, the L.R. 7.1(f) certification; centered page number on every page. | PASS |

No OPEN rows.

## Overlay

The overlay is a diagnostic (tier 3), not a score: `just overlay <dir>` writes it to the gitignored `.overlay/`. Our page 15 holds the certification, which the exemplar does not print.

## Known gaps and open choices

1. **Typeface.** L.R. 10.1 names no face and allows any clearly legible typeface. The template sets Times New Roman, as both exemplars (it was EB Garamond before fb-595.68.30).
2. **Track.** The L.R. 7.1(f) limit depends on the track assigned to the case, which the exemplar does not show. The sample uses `standard` (a 20-page limit). A filing in an expedited case has a 10-page limit, and the build fails over it.
3. **Page limit counting.** The rule does not say whether the table of contents, the table of authorities or the caption page count toward the limit. The template counts every page from the caption page through the signature block (contents included). That is the stricter reading, so a memorandum that passes is safe under either. David to confirm.
4. **Modified limits.** A limit set by a judge's order is recorded in frontmatter `page_limit_order`, and the certification states it. The template does not verify the order. The Kinzie exemplar runs 29 pages, over the 20-page limit for a standard track, so it was presumably filed with leave; the order is not in the file.
5. **Pagination.** Page 13 ends with space because the conclusion and signature stay together. A signature alone on a page is worse for a clerk. The conclusion heading moves with the paragraph (it is sticky).
5. **Pagination.** Page 14 ends with space because the conclusion and signature stay together. A signature alone on a page is worse for a clerk. The conclusion heading moves with the paragraph (it is sticky).
7. **No certificate of service.** Service is through ECF on filing (both exemplars rely on it and print no certificate). Not produced; add one in the sample if a filing needs it.
8. **Last paragraph.** The last paragraph of the body cannot carry a footnote (the template renders it apart from the rest, so that its footnote could not be matched). The assertion says so when a sample breaks the rule.
9. **Headings.** The numerals are typed in the sample as filed. The template's TOC shows them as typed.
10. **Table of authorities.** Implemented to the rule's requirements but not exercised by the committed sample (14 pages). The scratch variant is the only evidence it renders; a real memorandum over 15 pages should be rendered and checked on its own.
10. **Table of authorities.** Implemented to the rule's requirements but not exercised by the committed sample (15 pages, not over the 15-page threshold). The scratch variant is the only evidence it renders; a real memorandum over 15 pages should be rendered and checked on its own.
12. **Kinzie.** The second exemplar was not transcribed, and its body was not reviewed page by page. The tier-2 comparison rests on the Hammill exemplar and the Kinzie caption and contents page only.

## Searches (exemplar selection)

- CourtListener RECAP search (API v4, 2026-10-14), `type=r`, `court=ohnd`, two queries ("motion to dismiss" with "memorandum in support", and "memorandum in support of motion to dismiss"), filed on or after 2025-01-01. Many results were the motion alone, with the memorandum attached as a separate document that was not available as text, or were scanned.
- Saved: Hammill Manufacturing (U.S. Government, memorandum at ECF 14-1, text layer, 15 pp; the sample) and Kinzie Advanced Polymers (individual defendant, memorandum at ECF 23-1, text layer, 29 pp; second filer).
- Checked and not saved: Krudy (1:25-cv-00339, ECF 12, a combined motion and memorandum) is a scanned image with no text layer. Loops v. Maxill (1:25-cv-02346, ECF 22-1) has a text layer but its Times New Roman is not embedded. Smith v. Schuller (3:26-cv-00606, ECF 10-1, 19 pp) has a text layer but is set in Aptos and Georgia, not a court-typical face.

[Ohio federal index](../../README.md) | [Court folder](../README.md)

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"), and `eval.yaml` gates it (`params.cross_engine: gate`): the docx render must break every line and page where the typst render does.

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`: Times New Roman 12 pt, the typst face as `{font}`; Body Text in exact 27.6 pt lines, single lines, headings and footnotes 13.8 pt, 7 pt after each footnote; "Body Text Note" for a paragraph that carries a footnote) and the filter `docx/ohnd-motion-brief.lua`, which `fb render` runs: it writes the court title (the 1 1/2 in first-page top margin as its space before), the caption as a borderless table (one row per line of the party column; the ")" count of a wrapped name computed from Times New Roman's advances, as typst measures it), the title, the headings, paragraphs and quotations with the typst spaces, the signature block kept with the last paragraph, the certification, and the footer (a centered page number) and last section via `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`; pandoc writes the paragraphs that carry footnotes, and the notes. The old `build-reference.sh`, `render.sh` and `reference.docx` (EB Garamond) are gone.

- Result: 15 pages, every typst line breaking after the same word (358/358), every page starting and ending on the same word; tier 1 (DEF-FONT-002, DEF-COVER-001, DEF-TOC-001 and the rest) green on both engines.
- BLOCKED: `contents: true` (table of contents and table of authorities, L.R. 7.1(f) above 15 pages): not built by the docx engine. The filter stops with an error rather than omit them. TOC/TOA fields need an update step and LibreOffice does not honor TA/TOA the way Word does (docs/DOCX.md).
- BLOCKED: the L.R. 7.1(f) page-limit assertion (the typst `length-checks`) is not made in the docx: it needs the laid-out page count of the LibreOffice PDF. The sample's docx is 15 pages, the same as typst (XENG-001), within the standard track's 20.
