# utd: motion-brief

Doc type: **motion-brief** (a motion to dismiss under Fed. R. Civ. P. 12(b) with its memorandum, one document) in the United States District Court for the District of Utah (`utd`).
Folder: `courts/tenth-circuit/utah/federal/district/motion-brief/`. Self-contained: exemplar, sample, template and review are in this folder.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (22 pages, text layer; `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (abridged transcription of the exemplar, see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 11 pages each, on the generic FRCP brief (fb-595.92); vendored Times New Roman only, no warnings |
| typeface | face required: **none** (DUCivR 10-1(3) names no typeface). Font: **Times New Roman** 12 pt on both engines, footnotes included (docs/FONTS.md; the docx names the typst face through `{font}`). |
| overlay | `just overlay <dir>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (gitignored, not committed) |
| pages reviewed | 11 of 11 on each engine (2026-10-29, the FRCP-base render: `reviews/2026-10-29.md`) |

File names. The brief names outputs `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh`, `tools/overlay.sh` and the court-folder convention (`CLAUDE.md`) name them `INPUT-<id>.md` → `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`. The tools were used as they are; `<id>` is `miller-motion-to-dismiss`.

## Governing rules

Primary source: D. Utah Local Civil Rules, December 2023 edition, https://www.utd.uscourts.gov/sites/utd/files/Civil%20Rules%20Final%202023.pdf, fetched and read 2026-10-14 (the same PDF the complaint folder cites; the newest civil-rules edition I found). Federal rules: Fed. R. Civ. P. 5(d)(1)(B), 12(b), from https://www.law.cornell.edu/rules/frcp/rule_12 and rule_5, fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| DUCivR 7-1(a)(1) | Motion and memorandum | Motion and memorandum in one document: (A) an initial separate section stating succinctly the specific relief sought and the grounds; (B) the facts, supporting authority and argument. | Body is split at `# MEMORANDUM OF LAW`: the motion comes before it (`motion-md`), the memorandum after (`memo-md`). The motion section has no headings. |
| DUCivR 7-1(a)(4)(A)(i) | Page and word limits | A motion under Rule 12(b) may not exceed 25 pages or 7,750 words. Headings, citations, quotations and footnotes count; caption, TOC, TOA, signature block and certificate of service do not (7-1(a)(6)(A)–(B)). | Not enforced by the template (no page or word counter). See Known gaps. |
| DUCivR 7-1(a)(6)(C) | Word-count certification | When a document exceeds the page limit, a certification of the word count at the end. | Not generated: the sample is well under the limit. |
| DUCivR 10-1(1) | Paper and margins | 8½ × 11 inch; top margin at least 1½ inches; remaining margins at least 1 inch. | `margins` (top 1.5 in, others 1 in) in `typst/utd-motion-brief.typ` |
| DUCivR 10-1(3) | Font and size | Clearly legible; minimum 12 point, including footnotes. No typeface named in the text. | `type-size = 12pt`, `font-family` Times New Roman; footnotes at 12 pt |
| DUCivR 10-1(4) | Spacing | Text double-spaced, except block quotes and footnotes. | `pitch-body = 24pt` (exact 24 pt line boxes; docx 480 twips) for the motion, memorandum, lists and headings; `pitch-single = 13.8pt` for the cover, tables, footnotes and signature |
| DUCivR 10-1(5) | Pagination | Document pages numbered consecutively. | `numbering: "1"` on every page, caption page included (see Known gaps: exemplar uses roman front matter) |
| DUCivR 10-1(6)(A) | Contact information | Upper left, above the caption: counsel's name and Utah State Bar number, firm, mailing address, telephone, email, party represented. | `counsel`, `counsel_role` frontmatter; `counsel-block()` |
| DUCivR 10-1(6)(B) | Caption table | Names of parties, title of the document, case number, assigned judge and referred magistrate judge if applicable. | `caption`, `brief_title`, `case_number`, `judge`, `magistrate` in `caption-table()` |
| DUCivR 10-1(8) | Signatures | Every document signed by counsel. | `signature-block()`: "DATED:", "/s/" and the signing counsel, firm above |
| Fed. R. Civ. P. 12(b)(1), 12(b)(6) | Defenses by motion | Lack of subject-matter jurisdiction; failure to state a claim. | Content of the sample (the bases are listed in the motion section and linked as `toa:` authorities) |
| Fed. R. Civ. P. 5(d)(1)(B) | Certificate of service | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | No certificate generated (sample is an ECF filing; the exemplar has none) |

Not produced by this template: a proposed order (DUCivR 7-1, separate filing), a declaration, and the word-count certificate (not needed under the page limit).

## Layout

- Shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation. The docx render breaks every line and page where typst does (XENG-001..003 gated in `eval.yaml`).
- Page 1: counsel block single-spaced at the upper left with the party represented in italics; a blank double line; the court title centred bold capitals; a blank double line; the caption: the party column (3.75 in; names, designation 1.25 in in, "v." between the sides, a blank line on each side), ruled at its right and foot, and right of the rule the title in bold capitals, the case number and the judge, a blank line apart; a blank double line; the motion (DUCivR 7-1(a)(1)(A)), which may run onto page 2.
- New page: TABLE OF CONTENTS (the title centred, a blank double line; a blank single line above each row; level 1 rows at the margin, "I." half an inch in and "A." an inch in, each label in a half-inch box; the text wraps before a half-inch page column; a dot leader).
- New page: TABLE OF AUTHORITIES, from the `toa:` links of the body: Cases, Statutes, Rules, Other Authorities (a blank single line above each group, 6 pt above each entry; a 1 in page column; 7 or more pages print "passim"). A row keeps its last word before the leader only with 4 pt to spare (`lead-slack`: LibreOffice wraps a word that leaves less).
- New page: the memorandum from `# MEMORANDUM OF LAW`. Headings on the body pitch, bold, kept with their text: level 1 centred capitals; level 2 "I." at the margin, level 3 "A." half an inch in, the label in a half-inch box and the later lines under the text (labels restart under each level 1 heading). Numbered lists as the bullets. Footnotes 12 pt single-spaced, 6 pt between notes.
- Signature: a blank double line, "DATED:" and the date at the left; the firm, "/s/", the signer and the lines from 3.25 in. The last paragraph is kept with the signature block.
- Pages numbered 1, 2, 3 ... from the caption page, centred, the 13.8 pt line box ending 0.5 in above the page edge.

## Markdown contract (for samples)

- YAML frontmatter. Fields: `case_number`, `court` (lines), `counsel` (lines), `counsel_role`, `caption` (list of `{names, designation}`; "v." between sides), `brief_title`, `judge` (optional), `magistrate` (optional), `date`, `signature` (`firm` lines, `signer`, `lines`), and `authorities` (the registry: key → `{kind: case|statute|rule|other, name, cite}`).
- Body: the motion (no headings) then `# MEMORANDUM OF LAW` (required; the template panics without it), then headings (`##` level 2 = I., `###` level 3 = A.), then `# CONCLUSION`.
- Citations: each authority is linked as `[text](toa:KEY)`; `KEY` must be in `authorities`. The template records each link's page and builds the TOA from those links, so a citation not linked does not appear in the TOA.
- The sample does not type heading numbers: the template numbers headings.
- Not supported: tables, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/utah/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/district/motion-brief miller-motion-to-dismiss /path/to/exemplar.pdf
```

The exemplar PDF is not in the checkout (only `usage/SOURCE.md` is). On 2026-10-15 the overlay ran against the RECAP copy at the SOURCE.md URL, fetched to a temp directory and passed as the third argument; its page count (22) matches the SOURCE.md. Without the argument, `overlay.sh` looks for `usage/*.pdf`.

`OVERLAY-miller-motion-to-dismiss.pdf` is the red/blue test: red = our render, blue = the filed exemplar, black = both. `OVERLAY-miller-motion-to-dismiss.txt` is the page map.

Overlay map: ours pp. 1–3 ↔ filed pp. 1–3 (80–90%); ours p. 4 (TOA) ↔ filed p. 4 (32%: the exemplar's TOA page is a different layout); ours pp. 5–12 ↔ filed pp. 7, 8, 10, 12, 13, 17, 19, 21. The later pairs are coarse because the sample skips parts of the memorandum (see Known gaps), so a later page pairs with the exemplar page that shares most of its words, not the page at the same position. The overlay is a diagnostic, not a score.

## Visual review (before the FRCP base, fb-595.68.33; the current record is `reviews/2026-10-29.md`)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block, court title, caption, motion opening and the first bullet | OK on both engines. |
| 2 | The other bullets and "For these reasons" paragraph, then white space | OK; the contents start a new page, as in the exemplar. |
| 3 | TABLE OF CONTENTS | OK; page numbers equal on both engines; typst sets the leader dots apart, Word as a tab leader (the dots are fill, not words). |
| 4 | TABLE OF AUTHORITIES on one page | OK; two long entries wrap before the page column on both engines. |
| 5 | MEMORANDUM OF LAW, introduction, FACTUAL BACKGROUND, footnote 1 at the foot | OK. |
| 6 | Facts 1-13 | OK. |
| 7 | Fact 14, LEGAL STANDARD, LEGAL ARGUMENT | OK. |
| 8 | I., I.A | OK. |
| 9 | I.B, II., II.A | OK. |
| 10 | II.B, III. | OK. |
| 11 | III.A, CONCLUSION, signature block | OK; the signature sits with the conclusion. |

The docx pages break every line and page as typst does (`fb diff --engines`: 253/253 lines, 11 = 11 pages).

## Known gaps and open choices

1. **Abridged memorandum.** Transcribed: the motion, the introduction and footnote 1, all 14 facts, the first two paragraphs of the legal standard, the whole of I.A and I.B, the start of II.A and II.B, the first two paragraphs of III, III.A's first paragraph and the conclusion. Omitted: the rest of the legal standard (the Iqbal paragraphs and judicial notice), the full II.A paragraph (statutory quotation and *Hoai*), the rest of II.B (*Dauwe*), the rest of III.A (*Whipple*, the notice-of-claim content), and the exemplar's TOA entries those parts cite. The render is 12 pages against the exemplar's 22, within the 8–14 target.
2. **Page and word limit not tested.** DUCivR 7-1(a)(4)(A)(i) caps a 12(b) motion at 25 pages or 7,750 words. The template does not count pages or words; the sample is 11 pages with only part of the memorandum, so the limit is not exercised. A full brief needs a count before filing.
3. **Page numbering.** DUCivR 10-1(5) says pages are numbered "consecutively". The template numbers every page 1, 2, 3 … from the caption page, so the TOC and TOA page references are the page numbers printed on the pages. The exemplar uses roman numerals for its front matter (i–vi) and restarts at 1 for the memorandum. Both are readings of the rule; consecutive numbering is the literal one. A judge's standing order could say otherwise.
4. **Typeface.** DUCivR 10-1(3) names no typeface; the template sets Times New Roman 12 pt on both engines (the exemplar embeds Times New Roman among other faces).
5. **TOA completeness.** The TOA is generated from the links in the sample. The exemplar's printed TOA omits *Leverington*, which its text cites; the sample's TOA includes it, because the links make it complete. Authorities cited only in the omitted parts (for example *Dennis v. Sparks*, *Hoai*, *Whipple*) are not in the sample's TOA.
6. **Judge.** The caption shows "Judge Daphne A. Oberg", as the exemplar does; no magistrate judge line (the exemplar has none).
7. **Exemplar wording.** The sample keeps the exemplar's wording, including its "barred by the by Younger abstention". One punctuation change: the *Bailey* cite is set as 846 P.2d 1278, 1280 (the filed text has no comma between the page numbers).
8. **Tier-2 comparison.** Three exemplars from different filers (`usage/SOURCE.md`); the caption order and the contents' indents follow the first two (fb-595.92).
9. **Certificates.** No certificate of service (FRCP 5(d)(1)(B)); no certificate of compliance (not needed under the page limit).
10. **Signature placement.** The last paragraph is kept with the signature block (the base's `keep_with_closing`), in every engine.
11. **Checks.** `sh tools/check.sh <folder> --engine typst`, `latex` and `docx` exit 0 (fb-595.92), XENG-001..003 gated; DEF-COVER-002 reported (`eval.yaml`).

## Engines

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and the shared
document model (docs/EVAL-LOOP.md, "Generated engines"): `typst/layout.yaml` names the base and overlays D. Utah's
local rules, each with its rule; `typst/utd-motion-brief.typ` names the face and stops the render without the
memorandum's heading. `fb engines gen` writes `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`,
`xdoc.lua`) from the merged layout; `eval.yaml` sets `params.cross_engine: gate`, so latex and docx must break every
line and page where typst does (XENG-001..003). The docx is checked with LibreOffice only (Word is not available here).

## FRCP base (fb-595.92): moved

DUCivR 7-1(a)(1)(A)'s motion, an initial separate section under the caption on page 1 with the tables after it, is the
base's `body_before_tables: {until: "MEMORANDUM", place: cover}` (fb-595.92): the body up to its "MEMORANDUM OF LAW"
heading set on the cover's page after the counsel block, the court's name and the caption, the tables of contents and
authorities on the next pages, then the memorandum, every page numbered consecutively, as the template set it before
the move. Changes: the caption's right column now runs title, case number, judge (both filers' order); the party
column's rules are a box ruled at its right inside one ruled at its foot (typst draws a two-side stroke as one
polygon); the contents indent "I." half an inch and "A." an inch (both filers); the contents' "Page" label is gone (the
model has none; neither filer prints one); the last paragraph, not the whole conclusion, is kept with the signature.
Open (tier 2): the bullets of the motion's list stand at the margin, the text half an inch in; the first filer sets the
bullet half an inch in (the model has no list offset).
