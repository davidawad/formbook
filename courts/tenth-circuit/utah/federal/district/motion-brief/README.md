# utd: motion-brief

Doc type: **motion-brief** (a motion to dismiss under Fed. R. Civ. P. 12(b) with its memorandum, one document) in the United States District Court for the District of Utah (`utd`).
Folder: `courts/tenth-circuit/utah/federal/district/motion-brief/`. Self-contained: exemplar, sample, template and review are in this folder.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-miller-stormont-2-25-cv-00857-motion-brief.pdf` (22 pages, text layer; `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-miller-motion-to-dismiss.md` (abridged transcription of the exemplar, see Known gaps) |
| render | ok: `samples/OUTPUT-miller-motion-to-dismiss.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| typeface | face required: **none** (DUCivR 10-1(3) names no typeface; checked against the December 2023 text, 2026-10-15). Substitute: none needed. Font: **EB Garamond** kept (`docs/FONTS.md`: a court naming no face keeps EB Garamond). Not metric-compatible with any Times; not applicable here. |
| overlay | ok: `samples/OVERLAY-miller-motion-to-dismiss.pdf` and `samples/OVERLAY-miller-motion-to-dismiss.txt` (`tools/overlay.sh`, exemplar passed as the third argument: see Render and overlay) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed after the last template change; re-rendered and re-viewed 2026-10-15 in the fonts pass, no change to the template) |

File names. The brief names outputs `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh`, `tools/overlay.sh` and the court-folder convention (`CLAUDE.md`) name them `INPUT-<id>.md` → `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`. The tools were used as they are; `<id>` is `miller-motion-to-dismiss`.

## Governing rules

Primary source: D. Utah Local Civil Rules, December 2023 edition, https://www.utd.uscourts.gov/sites/utd/files/Civil%20Rules%20Final%202023.pdf, fetched and read 2026-10-14 (the same PDF the complaint folder cites; the newest civil-rules edition I found). Federal rules: Fed. R. Civ. P. 5(d)(1)(B), 12(b), from https://www.law.cornell.edu/rules/frcp/rule_12 and rule_5, fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| DUCivR 7-1(a)(1) | Motion and memorandum | Motion and memorandum in one document: (A) an initial separate section stating succinctly the specific relief sought and the grounds; (B) the facts, supporting authority and argument. | Body is split at `# MEMORANDUM OF LAW`: the motion comes before it (`motion-md`), the memorandum after (`memo-md`). The motion section has no headings. |
| DUCivR 7-1(a)(4)(A)(i) | Page and word limits | A motion under Rule 12(b) may not exceed 25 pages or 7,750 words. Headings, citations, quotations and footnotes count; caption, TOC, TOA, signature block and certificate of service do not (7-1(a)(6)(A)–(B)). | Not enforced by the template (no page or word counter). See Known gaps. |
| DUCivR 7-1(a)(6)(C) | Word-count certification | When a document exceeds the page limit, a certification of the word count at the end. | Not generated: the sample is well under the limit. |
| DUCivR 10-1(1) | Paper and margins | 8½ × 11 inch; top margin at least 1½ inches; remaining margins at least 1 inch. | `margins` (top 1.5 in, others 1 in) in `typst/utd-motion-brief.typ` |
| DUCivR 10-1(3) | Font and size | Clearly legible; minimum 12 point, including footnotes. No typeface named in the text. | `type-size = 13pt`, `font-family = EB Garamond`; footnotes at 13 pt |
| DUCivR 10-1(4) | Spacing | Text double-spaced, except block quotes and footnotes. | `line-pitch = 26pt` (measured baseline pitch 25.94 pt), `body-leading` |
| DUCivR 10-1(5) | Pagination | Document pages numbered consecutively. | `numbering: "1"` on every page, caption page included (see Known gaps: exemplar uses roman front matter) |
| DUCivR 10-1(6)(A) | Contact information | Upper left, above the caption: counsel's name and Utah State Bar number, firm, mailing address, telephone, email, party represented. | `counsel`, `counsel_role` frontmatter; `counsel-block()` |
| DUCivR 10-1(6)(B) | Caption table | Names of parties, title of the document, case number, assigned judge and referred magistrate judge if applicable. | `caption`, `brief_title`, `case_number`, `judge`, `magistrate` in `caption-table()` |
| DUCivR 10-1(8) | Signatures | Every document signed by counsel. | `signature-block()`: "DATED:", "/s/" and the signing counsel, firm above |
| Fed. R. Civ. P. 12(b)(1), 12(b)(6) | Defenses by motion | Lack of subject-matter jurisdiction; failure to state a claim. | Content of the sample (the bases are listed in the motion section and linked as `toa:` authorities) |
| Fed. R. Civ. P. 5(d)(1)(B) | Certificate of service | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | No certificate generated (sample is an ECF filing; the exemplar has none) |

Not produced by this template: a proposed order (DUCivR 7-1, separate filing), a declaration, and the word-count certificate (not needed under the page limit).

## Layout

- Page 1: counsel block (Utah Attorney General form, single-spaced, upper left), court title (IN THE UNITED STATES DISTRICT COURT / IN AND FOR THE DISTRICT OF UTAH, CENTRAL DIVISION), caption table (party column with a right and bottom rule; right column with the title in bold capitals, case number and judge), then the motion section (the relief sought and its grounds, DUCivR 7-1(a)(1)(A)).
- Page 3: table of contents (generated from the headings, with page numbers and dot leaders).
- Page 4 (onward): table of authorities, generated from the `toa:` links in the body. Groups: Cases, Statutes, Rules, Other Authorities. Entries with 7 or more pages show "passim".
- Memorandum: starts on a new page with `# MEMORANDUM OF LAW`. Level-1 headings are centred bold capitals; level 2 is numbered I., II.; level 3 is numbered A., B. (hanging indent). Fact lists are numbered 1., 2., … at double spacing.
- Footnotes: markdown `[^n]`, at 13 pt.
- Signature: "DATED:" date at left; firm name, "/s/" line, signing counsel and title at right. The block itself does not split across pages, but it is not tied to the conclusion paragraph (a block could start a page alone; see Known gaps).

## Markdown contract (for samples)

- YAML frontmatter. Fields: `case_number`, `court` (lines), `counsel` (lines), `counsel_role`, `caption` (list of `{names, designation}`; "v." between sides), `brief_title`, `judge` (optional), `magistrate` (optional), `date`, `signature` (`firm` lines, `signer`, `lines`), and `authorities` (the registry: key → `{kind: case|statute|rule|other, name, cite}`).
- Body: the motion (no headings) then `# MEMORANDUM OF LAW` (required; the template panics without it), then headings (`##` level 2 = I., `###` level 3 = A.), then `# CONCLUSION`.
- Citations: each authority is linked as `[text](toa:KEY)`; `KEY` must be in `authorities`. The template records each link's page and builds the TOA from those links, so a citation not linked does not appear in the TOA.
- The sample does not type heading numbers: the template numbers headings.
- Not supported: tables, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/utah/federal/district/motion-brief samples/INPUT-miller-motion-to-dismiss.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/district/motion-brief miller-motion-to-dismiss /path/to/exemplar.pdf
```

The exemplar PDF is not in the checkout (only `exemplars/SOURCE.md` is). On 2026-10-15 the overlay ran against the RECAP copy at the SOURCE.md URL, fetched to a temp directory and passed as the third argument; its page count (22) matches the SOURCE.md. Without the argument, `overlay.sh` looks for `exemplars/*.pdf`.

`OVERLAY-miller-motion-to-dismiss.pdf` is the red/blue test: red = our render, blue = the filed exemplar, black = both. `OVERLAY-miller-motion-to-dismiss.txt` is the page map.

Overlay map: ours pp. 1–3 ↔ filed pp. 1–3 (80–90%); ours p. 4 (TOA) ↔ filed p. 4 (32%: the exemplar's TOA page is a different layout); ours pp. 5–12 ↔ filed pp. 7, 8, 10, 12, 13, 17, 19, 21. The later pairs are coarse because the sample skips parts of the memorandum (see Known gaps), so a later page pairs with the exemplar page that shares most of its words, not the page at the same position. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 12 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption page: counsel, court title, caption table, title, judge; start of the motion (first bullets) | OK. Caption and text separated by a half line; bullet list begins on this page. |
| 2 | Rest of the motion's bullets and "For these reasons" paragraph, then white space | OK. Short page before the TOC; the TOC starts on a new page, as in the exemplar. |
| 3 | TABLE OF CONTENTS with page numbers and dot leaders | OK. Entries match the headings; numbering I./A./B. hangs. |
| 4 | TABLE OF AUTHORITIES: Cases, Statutes, Rules, Other Authorities on one page | OK. Entries fit on one page after tightening the entry spacing (the last entry had spilled onto its own page). |
| 5 | MEMORANDUM OF LAW, introduction, footnote 1 at the foot | OK. |
| 6 | FACTUAL BACKGROUND, numbered list 1–10 | OK. |
| 7 | List 11–14; LEGAL STANDARD, first two paragraphs | OK. |
| 8 | LEGAL ARGUMENT, I., A., first paragraphs | OK. Heading sits with its text. |
| 9 | I.A paragraphs; I.B heading | OK. |
| 10 | I.B text; II. and II.A | OK. |
| 11 | II.B; III. heading; GIA paragraphs | OK. |
| 12 | III.A; CONCLUSION; DATED line and signature block | OK. Signature block sits with the conclusion. |

Pages reviewed: 12 of 12.

## Known gaps and open choices

1. **Abridged memorandum.** Transcribed: the motion, the introduction and footnote 1, all 14 facts, the first two paragraphs of the legal standard, the whole of I.A and I.B, the start of II.A and II.B, the first two paragraphs of III, III.A's first paragraph and the conclusion. Omitted: the rest of the legal standard (the Iqbal paragraphs and judicial notice), the full II.A paragraph (statutory quotation and *Hoai*), the rest of II.B (*Dauwe*), the rest of III.A (*Whipple*, the notice-of-claim content), and the exemplar's TOA entries those parts cite. The render is 12 pages against the exemplar's 22, within the 8–14 target.
2. **Page and word limit not tested.** DUCivR 7-1(a)(4)(A)(i) caps a 12(b) motion at 25 pages or 7,750 words. The template does not count pages or words; the sample is 12 pages with only part of the memorandum, so the limit is not exercised. A full brief needs a count before filing.
3. **Page numbering.** DUCivR 10-1(5) says pages are numbered "consecutively". The template numbers every page 1, 2, 3 … from the caption page, so the TOC and TOA page references are the page numbers printed on the pages. The exemplar uses roman numerals for its front matter (i–vi) and restarts at 1 for the memorandum. Both are readings of the rule; consecutive numbering is the literal one. A judge's standing order could say otherwise.
4. **Typeface.** As for the complaint: DUCivR 10-1(3) names no typeface (checked 2026-10-15), so the template keeps EB Garamond at 13 pt, close to Times 12 pt. The filed exemplar embeds TimesNewRoman, Charter, Cambria and Arial: a filer's choice the rule leaves open. Switching to Liberation Serif (the metric-compatible Times substitute in `fonts/`) would be a tier-2 decision for David.
5. **TOA completeness.** The TOA is generated from the links in the sample. The exemplar's printed TOA omits *Leverington*, which its text cites; the sample's TOA includes it, because the links make it complete. Authorities cited only in the omitted parts (for example *Dennis v. Sparks*, *Hoai*, *Whipple*) are not in the sample's TOA.
6. **Judge.** The caption shows "Judge Daphne A. Oberg", as the exemplar does; no magistrate judge line (the exemplar has none).
7. **Exemplar wording.** The sample keeps the exemplar's wording, including its "barred by the by Younger abstention". One punctuation change: the *Bailey* cite is set as 846 P.2d 1278, 1280 (the filed text has no comma between the page numbers).
8. **Tier-2 comparison.** One exemplar only. Alternates (Adams v. Tooele County School District, Fox v. University of Utah, Xlear v. FTC) are in `exemplars/SOURCE.md`. Not run as a second-filer comparison.
9. **Certificates.** No certificate of service (FRCP 5(d)(1)(B)); no certificate of compliance (not needed under the page limit).
10. **Signature placement.** The signature block is unbreakable but is not kept with the conclusion paragraph, unlike the complaint's template. The sample's signature sits on the conclusion's page with room to spare; a longer conclusion could leave the block alone on a page.
11. **Check scripts not run.** As for the complaint: `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 record.

## Engines

**docx** (`docx/`): `docx/reference.docx`, built by `docx/build-reference.sh` (pandoc's reference with the styles, footer and section of `typst/utd-motion-brief.typ`), and the filter `docx/utd-motion-brief.lua` (cover with counsel block and caption, heading labels "I." and "A.", numbered and bulleted lists, table of contents and table of authorities, page breaks before the contents and before the memorandum, signature block). `sh tools/render.sh --engine docx <folder> samples/INPUT-miller-motion-to-dismiss.md` writes `samples/OUTPUT-miller-motion-to-dismiss.docx`.

- Matches the typst form: Letter; top margin 1 1/2 in, others 1 in; EB Garamond 13 pt; exact 26 pt line spacing for body text; first-line indent 0.5 in; headings centred bold capitals (level 1), bold with "I." at the margin (level 2), bold with "A." indented half an inch (level 3); lists numbered "1." and bulleted at 0.5 in; footnotes at 13 pt, single spaced; centred page number on every page; caption with the judge; motion, contents, authorities and memorandum in the same order.
- Differs: the caption and signature are Word tables; the table of contents and table of authorities are written as text (below); the typst page-number column is not reproduced.
- BLOCKED, TOC page numbers: the table of contents is a TOC field whose cached result lists the headings without page numbers. Page numbers need a field update in Word or LibreOffice, and the cached numbers cannot be known without a rendered layout. Each heading entry is present; no page number is shown.
- BLOCKED, TOA page numbers: the table of authorities lists the authorities that the body links, grouped and sorted, without page numbers (no TA or TOA fields; LibreOffice does not honor them, see `docs/DOCX.md`). The "passim" rule (7 or more pages) is not applied.
- Checked on the box: the .docx is a zip whose 17 XML parts are well-formed (`ziptool` + `xmllint`, because `unzip` is not installed).
- BLOCKED, docx.pdf (Gates 0 to 3 on `samples/OUTPUT-miller-motion-to-dismiss.docx.pdf`): `soffice` is not installed on this box and cannot be installed here, so no LibreOffice PDF was made and `tools/check.sh --engine docx` cannot run.
- BLOCKED, `tools/render.sh --engine docx` exits 1: the zip-integrity step runs `unzip -tq`, and `unzip` (and `zip`) are not installed on this box. The .docx is written before that step; the render stops there.
- BLOCKED, visual review of the .docx pages: 0 of 12 pages reviewed (`pages_reviewed=0`); the pages cannot be rendered without LibreOffice. The typst pages were reviewed at 60 dpi (12 of 12) as the reference.
- Not checked: that the file opens in Word or LibreOffice without a repair prompt (no Word, no LibreOffice on the box).
