# arwd: motion brief

Doc type: **motion brief** (the memorandum in support of a Rule 12(b) motion to dismiss) in the United States District Court for the Western District of Arkansas (`arwd`).
Folder: `courts/eighth-circuit/arkansas/federal/western-district/motion-brief/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-gasper-3-26-cv-03048-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-gasper-motion-brief.md` (the whole 11-page brief, transcribed) |
| render | ok: `samples/OUTPUT-gasper-motion-brief.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-gasper-motion-brief.pdf` and `OVERLAY-gasper-motion-brief.txt` |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the repo's roles (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| W.D./E.D. Ark. Local Rule 7.2(a) | A motion is "accompanied by a brief consisting of a concise statement of relevant facts and applicable law". Both are filed, and copies are served. Source: consolidated "Local Rules of the United States District Court for the Eastern and Western Districts of Arkansas", https://www.arwd.uscourts.gov/sites/arwd/files/ARWD%20Local%20Rules.pdf (PDF dated 2019-12-04; the same text is in the individual LR 7.2 PDF at https://www.arwd.uscourts.gov/sites/arwd/files/7.2.pdf, dated 2014). Read 2026-10-14. | The brief is the document this template makes. The motion is a separate filing. |
| LR 7.2(e) | "Pretrial motions ... and motions to dismiss, shall not be taken up and considered unless set forth in a separate pleading accompanied by a separate brief." | The motion (ECF No. 6 in the exemplar) is not produced; the brief is. |
| LR 7.2(b) | Response to a motion within fourteen days of service; a reply period is set by the rule for summary judgment and §§ 2254/2255 only. | Not a template matter. Recorded for the filer. |
| LR 5.5(a) | Pleadings, motions and other papers "in type not less than elite, in double space, letter size, using only one side of the page", unfolded, no manuscript covers. Same sources as LR 7.2 above. | `page` (US letter), `type-size` 12 pt, `body-leading` (double space, 27.6 pt pitch), one-sided. |
| LR 5.5(c)(1) | Signature of at least one attorney of record in his or her individual name, with address, zip code, telephone number and Arkansas Supreme Court identification number "or other Supreme Court identification number, if applicable". | `signature` (`firm`, `signer`, `lines`). The ID is an author-supplied line; not enforced. |
| Fed. R. Civ. P. 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. Fetched from https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Not a template matter; the motion is separate. |
| Fed. R. Civ. P. 7(b)(2) | "The rules governing captions and other matters of form in pleadings apply to motions and other papers." Same source. | The caption follows the complaint's (Rule 10(a)): court lines, division, case number, title. |
| Fed. R. Civ. P. 12(b) | Defenses that may be raised by motion include (2) lack of personal jurisdiction, (4) insufficient process and (5) insufficient service of process. Fetched from https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14. | Author content (the grounds in the title). |
| Fed. R. Civ. P. 5(d)(1)(B) | A certificate of service "is not required when a paper is served by filing it with the court's electronic-filing system"; otherwise one is required. Fetched from https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14. | `certificate` (optional): rendered only when the frontmatter gives one. The exemplar serves a pro se plaintiff by mail, so it has one. |

No page limit appears in the W.D./E.D. Ark. Local Rules text read (the consolidated PDF was searched for "page"; the only hits are in the judgment and fee rules). Judges may set limits by order; none is checked here.

Not produced by this template: the motion, a proposed order, declarations and exhibits, and any notice of hearing (none is required by the local rules read).

## Layout

- US letter, 1-inch margins on all four sides (the exemplar's margins measured with `pdftotext -bbox`: 72 pt on each side).
- No pleading paper and no line numbers (LR 5.5 does not call for them; the exemplar has none).
- Double spacing: 12 pt EB Garamond, baseline pitch 27.6 pt (`pitch` = 0.65 em line + `body-leading` 1.65 em). The exemplar's pitch is 27.6 pt, the same.
- Caption and court title as in the complaint: court lines and division centered; party names left with the designation right-aligned; "v." and `CASE NO. ...` on the row between the parties.
- Title of the paper centered and bold (its capitals come from the sample).
- The brief's first paragraph (the motion's grounds) is an unheaded paragraph under the title.
- Headings: level 1 centered bold capitals; level 2 centered bold as typed; level 3 bold, left. A heading is set off by one blank double-spaced line above and below and stays with the first line of the paragraph after it.
- Paragraphs: not numbered (a brief is not Fed. R. Civ. P. 10(b)); first-line indent 0.5 in.
- Block quotations (`> ...`): single spaced, indented 0.5 in on both sides.
- Lists: `1.` items, numbered by the template as `1.`, `2.`, ... (the exemplar has none).
- Closing and signature block (right half of the page): "Respectfully submitted," the firm or party lines, `By: /s/ Signer` and the signer's lines (address, bar number, telephone, email, role).
- Certificate of service (optional): centered heading, the sentence from the frontmatter, the names and address served indented, and the `/s/` signature.
- Footer: "Page n of N", centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`; `court` (list of lines, upper-cased); `division` (optional); `caption.parties` (list of `{names: [...], designation: "..."}`; two parties; "v." and `CASE NO.` between them); `title`; `closing` (optional, e.g. "Respectfully submitted,"); `date` (optional, printed as "Dated:" on the left of the signature block); `signature` (`firm`: list of lines, optional; `signer`; `lines`); `certificate` (optional: `body` = the filer's sentence, `served` = list of lines).
- Body: blank-line-separated chunks. `#` = level 1, `##` = level 2, `###` = level 3 headings. A single-paragraph chunk is an unnumbered body paragraph. A chunk beginning `>` is a block quotation. A chunk of `1.` list items is a list. Italics `*...*` for case names, *Id.*, *See*; an asterisk inside a citation is escaped (`at \*3`).
- Not supported: tables, a table of contents or authorities (none is required by the local rules read; the exemplar has none), footnotes (none in the exemplar), raw typst.

## What the overlay shows

`samples/OVERLAY-gasper-motion-brief.pdf`: red = our render, blue = the filed exemplar, black = both. Pages are paired by word overlap (`OVERLAY-gasper-motion-brief.txt`): ours 1-10 ↔ filed 1-10 in order (98.8 % on page 1, 74.7 % on page 5, 44.5 % on page 9, 60.7 % on page 10). The exemplar is set in Times with its own line breaks and the page breaks fall in different places, so the two layers do not coincide line for line. The overlay is a diagnostic, not a score.


## Gate 2: visual review (every page rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title (three lines), caption, title of the brief, the motion's grounds, INTRODUCTION, first two paragraphs | OK. Caption "v." row and `CASE NO.` match the exemplar's arrangement. |
| 2 | Introduction end, STATEMENT OF FACTS, first two paragraphs | OK. |
| 3 | Statement of facts end; LEGAL STANDARD heading moved to page 3 with its paragraph | OK. Before the change the heading and its whole paragraph moved to page 4 (a third of page 3 was blank); the heading is now sticky with the first line of its paragraph. |
| 4 | Rule 12(b)(5) paragraph, Rule 4(h)(1) block quotation (single spaced, indented) | OK. |
| 5 | Arkansas and Oklahoma service law paragraphs; *Velez* paragraph begins | OK. |
| 6 | *Velez* ends; LEGAL ARGUMENT heading and first two paragraphs | OK. |
| 7 | Argument on service by Angela Williams; Arkansas and Oklahoma requirements | OK. |
| 8 | Argument on the service attempt at 309 N. Bryant Avenue; *Graff* citation | OK. |
| 9 | Argument on the entity return; Rule 12(b)(2) paragraph; the reservation paragraph. | OK. The CONCLUSION heading and its paragraph moved to page 10 with the signature (see page 10), so page 9 ends after the reservation paragraph and is about one-third blank. |
| 10 | CONCLUSION and its paragraph, closing and signature block, CERTIFICATE OF SERVICE with the service address and `/s/` line | OK. The conclusion is kept on the same page as the signature block (`body-chunks` returns the last chunk as a tail; the tail and the signature are one unbreakable block). In the exemplar, CONCLUSION and the signature also share a page (its page 10), and the certificate runs on to page 11. |

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for 2 or 3 filers; only Gasper v. Bruce is saved. Other memorandum briefs found (E3 Tax in *Zrazhevskiy*; American Express and Ally in *Page v. TransUnion*; King and River Valley in *Landis*) are listed in `exemplars/SOURCE.md`. Their RECAP main documents have no page counts, so they were not downloaded.
2. **Character pitch.** LR 5.5(a) "type not less than elite" is read as a 12-point type size for a proportional face (as in the complaint). EB Garamond is the vendored face; it sets smaller than Times New Roman at the same size. **Needs David's call** on the reading, as for the complaint.
3. **Motion not produced.** LR 7.2(e) requires the motion in a separate pleading. This template produces the brief only. A motion template and a proposed order would be separate doc types.
4. **No page limit enforced.** No limit appears in the local rules read. The brief is 10 pages rendered; a judge's order could set a limit.
5. **No table of contents or authorities.** Not required by the local rules read; the exemplar (11 pages) has none. A brief of this length does not need them here; a longer brief might.
6. **Citations are not checked.** The template does not validate case citations, the parallel-cite form, or the "4(I)(1)" spelling carried over from the exemplar. The sample keeps the exemplar's citations as printed (including "Ark. R. Civ. P. 4(h)" and the Oklahoma statute references) so the overlay compares like with like.
7. **Italics are the transcriber's.** The text layer has no italic markup; the case names, *Id.* and *See* are italicized by standard citation form (the exemplar embeds Times Italic).
8. **Certificate of service is conditional.** Rendered only when the frontmatter has `certificate`, because Fed. R. Civ. P. 5(d)(1)(B) does not require one for ECF service.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court root; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The Gate 2 table above is the review for this doc type.
