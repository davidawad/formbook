# ohnd: motion-brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**, the memorandum that supports a Rule 12(b) motion, in the United States District Court for the Northern District of Ohio (`ohnd`).
Folder: `courts/sixth-circuit/ohio/federal/northern-district/motion-brief/` (one self-contained folder per doc type).

| Item | Status |
|---|---|
| exemplar | yes: 2 filers. `exemplars/FILED-EXAMPLE-hammill-3-25-cv-00462-motion-brief.pdf` (15 pp, U.S. Government, transcribed) and `exemplars/FILED-EXAMPLE-kinzie-1-25-cv-01217-motion-brief.pdf` (29 pp, an individual defendant, with a table of contents and table of authorities; not transcribed). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-hammill-motion-brief.md`: the whole 15-page memorandum (caption, every section, three footnotes, signature). |
| render | ok: `samples/OUTPUT-hammill-motion-brief.pdf`, 14 pages, `tools/render.sh`, vendored EB Garamond only, no typst warnings. |
| overlay | ok: `samples/OVERLAY-hammill-motion-brief.pdf` and `samples/OVERLAY-hammill-motion-brief.txt` (paired against the Hammill exemplar). |
| pages reviewed | 14 of 14 (every page of the current PDF rendered at 60 dpi and viewed after the last template change). |
| content check | every word of the sample body and of its three footnotes appears in the PDF (compared as word counts, because footnotes sit at the foot of the page and dashes split at line ends; the body's word order was not compared). |
| `tools/check.sh` | not run: same reason as the complaint folder. |

## Governing rules

Verified 2026-10-14. Federal rules from Cornell LII (https://www.law.cornell.edu/rules/frcp/); local rules from the court's own PDFs (https://www.ohnd.uscourts.gov/).

| Rule | Requirement | Kind | Where in the template |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | M | `court-title`, `caption` (for a motion paper: the same caption as the complaint). |
| Fed. R. Civ. P. 12(b) (https://www.law.cornell.edu/rules/frcp/rule_12) | The defenses the motion may raise include "lack of subject-matter jurisdiction" and "failure to state a claim upon which relief can be granted"; the motion "must be made before pleading if a responsive pleading is allowed." | M (the motion; this memorandum supports it) | Author content; the template does not check the defense named. |
| N.D. Ohio L.R. 7.1(c) (https://www.ohnd.uscourts.gov/sites/ohnd/files/Rule_7_1%20redline.pdf) | "The moving party must serve and file with its motion a memorandum of the points and authorities on which it relies in support of the motion." | M | The memorandum is a separate document filed with the motion; the template produces the memorandum only. |
| N.D. Ohio L.R. 7.1(f) (same PDF) | Page limits: "memoranda relating to dispositive motions must not exceed ten (10) pages in length for expedited cases, twenty (20) pages for administrative, standard and unassigned cases, thirty (30) pages for complex cases, and forty (40) pages for mass tort cases"; "Memoranda relating to all other motions must not exceed fifteen (15) pages in length." A memorandum over 15 pages "must have a table of contents, a table of authorities cited, a brief statement of the issue(s) to be decided, and a summary of the argument presented." A dispositive memorandum "must be accompanied by a certification specifying the track, if any, to which the case has been assigned and a statement certifying that the memorandum adheres to the page limitations"; a modified limit must be stated in the certification. | M | `track-limits`, `limit`, `length-checks` (fails the build over the limit, and fails it for a memorandum over 15 pages without contents or without "issue" and "summary" headings), `contents: true` (TOC and TOA), `certification()`. |
| N.D. Ohio L.R. 10.1 (https://www.ohnd.uscourts.gov/sites/ohnd/files/CivilRules_Rule101.pdf, last revised 8/10/18) | 8 1/2 x 11 white paper; double-spaced except quoted material; a 1 1/2 inch top margin on the first page; "Each page shall be numbered consecutively."; signature details. | M | `first-page-top`, `body-leading`/`body-pitch`, the consecutive footer page number, `signature-block`, quotations single-spaced in `show quote`. |

Notes on the sources:
- The L.R. 7.1 PDF on the court's site is a redline (its footer reads "Last revised 12/1/16 1/6/20"). The text read is the one shown with the 1/6/20 revision; check it against the adopted rule before relying on any page limit.
- The Hammill exemplar (15 pages, U.S. Government) carries no L.R. 7.1(f) certification inside the memorandum. The rule requires one for a dispositive memorandum; the template follows the rule, not the exemplar.
- The track is not stated in the exemplar. The sample says `track: "standard"`, which is an author's choice for the sample; a real filing takes the track the case is assigned.

## Layout

- Caption page: the court title (with the division), the party column with ")" marks, the case number and judge at the right, and the title in bold, centered (a measure of 5.6 in, so the words wrap).
- The memorandum begins on the caption page when no contents are requested (as the Hammill exemplar does). With `contents: true`, the caption page is followed by a table of contents page, then a table of authorities page, then the body.
- Body: double-spaced 12 pt, paragraphs indented 0.5 in (every paragraph, as in the exemplar), with the paragraph spacing equal to the leading so every line falls on the grid of 27.6 pt pitches.
- Headings: level 1 bold, left, hanging 0.5 in ("I. BACKGROUND"); level 2 bold, indented 0.5 in ("A. ..."); level 3 bold, indented 1 in ("i. ..."). Each heading is single-spaced and sticky (kept with the paragraph after it). The numerals are typed in the sample as filed; the template does not number headings.
- Footnotes: 12 pt, single-spaced, with a 30% rule above them. (LR 10.1 sets no footnote size; 12 pt is the filed convention.)
- Block quotations: single-spaced, indented 0.5 in on both sides.
- Signature: single-spaced, at the right; the last paragraph of the body is kept with it, so the signature never stands alone.
- Certification: after the signature block, "CERTIFICATION OF TRACK AND PAGE LIMIT", with the track, the limit and any modifying order from frontmatter. It is not counted in the page limit.
- Footer: consecutive arabic page numbers, centered (L.R. 10.1).

## Contents and the table of authorities (L.R. 7.1(f))

- `contents: true` prints a table of contents (outline of the headings, with dot leaders and page numbers) and a table of authorities.
- The table of authorities is built from links in the body with the target `toa:KEY`, with the full citation as the link text. Each `toa:` link marks the page where its authority starts. A key missing from `authorities:` in the frontmatter stops the build. Authorities are grouped (cases, constitutional provisions, statutes, regulations, rules, other) and sorted; an authority on 7 or more pages prints "passim".
- The sample is 14 pages, so it does not need contents, and the committed sample does not use the table of authorities. The TOC and TOA paths were exercised with a scratch variant (contents on, three `toa:` links, the issues and summary headings), which rendered as 17 pages with a TOC on page 2 and a TOA on page 3; the scratch file was deleted. The two L.R. 7.1(f) build failures were also exercised with scratch variants: an `expedited` track (10 pages) on this 14-page memorandum failed with "L.R. 7.1(f) allows 10 for this track", and a 17-page memorandum without contents failed with "requires a table of contents and a table of authorities above 15 pages".

## Review of the rendered pages (current PDF)

Compared with: the Hammill exemplar. Pages 1, 2, 3 and 9 of the exemplar were viewed as images; the rest by the exemplar's text layer. Kinzie page 2 (its table of contents) was viewed as an image, for the contents layout; its page 1 by text.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 (image) | Court title, division, caption with ")" column, case number and judge, three-line bold title, body starts on the caption page. | PASS |
| 2 | exemplar p.2 (image) | Paragraph continues; I. BACKGROUND (bold left); A. heading indented; footnote 1 at the foot. | PASS |
| 3 | exemplar p.3 (image) | Body text on the grid; B. heading with hanging indent. | PASS |
| 4 | exemplar p.4 (text) | Continues the Amended Complaint paragraph; footnote 2 at the foot. | PASS |
| 5 | exemplar p.5 (text) | II. LEGAL STANDARD; III. ARGUMENT; heading A. (three lines, hanging). | PASS |
| 6 | exemplar p.6 (text) | Citations in italics; ¶¶ 35-42 references. | PASS |
| 7 | exemplar p.7 (text) | B. heading; footnote 3 at the foot. | PASS |
| 8 | exemplar p.8 (text) | C. and i. headings; italic *Trump v. CASA* citations. | PASS |
| 9 | exemplar p.9 (image) | Equitable-powers paragraphs; the *Casa* footnote discussion. | PASS |
| 10 | exemplar p.10 (text) | ii. heading (two lines, hanging); § 706 discussion. | PASS |
| 11 | exemplar p.11 (text) | iii. heading (two lines); sovereign-immunity paragraphs. | PASS |
| 12 | exemplar p.12 (text) | Statute and case citations in italics; the refund-suit paragraph. | PASS |
| 13 | exemplar p.13 (text) | The adequate-remedy paragraphs. Ends with white space: the conclusion is kept with the signature, so it moves to p.14. | ACCEPTED: pagination, see open choice 5 |
| 14 | exemplar p.14 (text) | IV. CONCLUSION (the last paragraph), signature block at the right, LR 7.1(f) certification. | PASS |

Every page was rendered at 60 dpi and viewed. No OPEN rows.

## Overlay

`samples/OVERLAY-hammill-motion-brief.pdf` is red (ours), blue (filed), black (both). The page map (`OVERLAY-hammill-motion-brief.txt`) pairs pages 1 to 8 with the same page number (word overlap 97.9% on page 1, falling to 44% on page 8 where the exemplar's pagination drifts); pages 9 to 13 pair one page later (our 9 with the filed 10). Our page 14 pairs with the filed 14 (32.8%) because the certification is ours and the exemplar has none. The overlay is a diagnostic; tier 3 differences are not chased.

## Known gaps and open choices

1. **Typeface.** L.R. 10.1 sets no font. Both exemplars use Times New Roman; the template uses EB Garamond, the only serif family vendored in `fonts/` (no edits to `fonts/` in this box). Same choice and same consequence as the complaint folder.
2. **Track.** The L.R. 7.1(f) limit depends on the track assigned to the case, which the exemplar does not show. The sample uses `standard` (a 20-page limit). A filing in an expedited case has a 10-page limit, and the build fails over it.
3. **Page limit counting.** The rule does not say whether the table of contents, the table of authorities or the caption page count toward the limit. The template counts every page from the caption page through the signature block (contents included). That is the stricter reading, so a memorandum that passes is safe under either. David to confirm.
4. **Modified limits.** A limit set by a judge's order is recorded in frontmatter `page_limit_order`, and the certification states it. The template does not verify the order. The Kinzie exemplar runs 29 pages, over the 20-page limit for a standard track, so it was presumably filed with leave; the order is not in the file.
5. **Pagination.** Page 13 ends with space because the conclusion and signature stay together. A signature alone on a page is worse for a clerk. The conclusion heading moves with the paragraph (it is sticky).
6. **Numbering.** Pages are numbered consecutively in arabic numerals from the caption page (L.R. 10.1: "numbered consecutively"). Kinzie numbers its table of contents in roman numerals and the body from 1; that is a reading of "consecutively" the template does not take.
7. **No certificate of service.** Service is through ECF on filing (both exemplars rely on it and print no certificate). Not produced; add one in the sample if a filing needs it.
8. **Last paragraph.** The last paragraph of the body cannot carry a footnote (the template renders it apart from the rest, so that its footnote could not be matched). The assertion says so when a sample breaks the rule.
9. **Headings.** The numerals are typed in the sample as filed. The template's TOC shows them as typed.
10. **Table of authorities.** Implemented to the rule's requirements but not exercised by the committed sample (14 pages). The scratch variant is the only evidence it renders; a real memorandum over 15 pages should be rendered and checked on its own.
11. **Issues and summary.** Above 15 pages, the template requires a heading containing "issue" and one containing "summary". It checks the heading words, not the content of those sections.
12. **Kinzie.** The second exemplar was not transcribed, and its body was not reviewed page by page. The tier-2 comparison rests on the Hammill exemplar and the Kinzie caption and contents page only.

## Searches (exemplar selection)

- CourtListener RECAP search (API v4, 2026-10-14), `type=r`, `court=ohnd`, two queries ("motion to dismiss" with "memorandum in support", and "memorandum in support of motion to dismiss"), filed on or after 2025-01-01. Many results were the motion alone, with the memorandum attached as a separate document that was not available as text, or were scanned.
- Saved: Hammill Manufacturing (U.S. Government, memorandum at ECF 14-1, text layer, 15 pp; the sample) and Kinzie Advanced Polymers (individual defendant, memorandum at ECF 23-1, text layer, 29 pp; second filer).
- Checked and not saved: Krudy (1:25-cv-00339, ECF 12, a combined motion and memorandum) is a scanned image with no text layer. Loops v. Maxill (1:25-cv-02346, ECF 22-1) has a text layer but its Times New Roman is not embedded. Smith v. Schuller (3:26-cv-00606, ECF 10-1, 19 pp) has a text layer but is set in Aptos and Georgia, not a court-typical face.

[Ohio federal index](../../README.md) | [Court folder](../README.md)
