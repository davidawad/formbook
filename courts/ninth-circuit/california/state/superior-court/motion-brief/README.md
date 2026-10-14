# calsuperct: motion-brief

Doc type `motion-brief` for the California Superior Courts (court alias `calsuperct`). A notice of motion and motion, with the memorandum of points and authorities, in one document on pleading paper. Template: `typst/calsuperct-motion-brief.typ`, entry `typst/main.typ`.

Status: **typst only**. latex and docx are not built for this doc type. The notice, the caption with hearing details, the table of contents, the table of authorities, the memorandum, and the signature blocks are built. Open items are listed below.

## Governing rules

Verified 2026-10-13 against the Judicial Council rule pages. Quotations are from those pages as shown by the fetch; re-check the text against the Judicial Council pages before any filing.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.100-2.119 | Format of papers (scope) | whole document | https://www.courts.ca.gov/cms/rules/index/two/rule2_100 |
| CRC 2.103 | Papers 8½ × 11 inches; opaque white or unbleached, 20 lb (not e-filed) | page size (`us-letter`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_103 |
| CRC 2.104 | Font size not smaller than 12 points | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | Font style essentially equivalent to Courier, Times New Roman, or Arial | open, see Known gaps | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107 | Left margin at least 1 inch; right margin at least ½ inch | `left-margin = 1.5in`, `right-margin = 0.5in` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 |
| CRC 2.108 | Lines one-and-one-half or double spaced and numbered consecutively; numbers at the left margin, separated from the text by a space of at least ⅕ inch or a single or double vertical line; at least 3 numbers per vertical inch | double spacing (24 pt pitch), 28 numbers, double rule | https://www.courts.ca.gov/cms/rules/index/two/rule2_108 |
| CRC 2.109 | Pages numbered consecutively at the bottom, Arabic numerals only, from the first page | footer page number; no roman numerals for the tables | https://www.courts.ca.gov/cms/rules/index/two/rule2_109 |
| CRC 2.110 | Footer below the page number, divided from the page by a printed line; the title of the paper (or a clear abbreviation) in at least 10-point type | footer | https://www.courts.ca.gov/cms/rules/index/two/rule2_110 |
| CRC 2.111(1)-(3) | Attorney information from line 1, 1 inch from the top; clerk's space in lines 1-7 right of center; court title on line 8, at or below 3⅓ inches | attorney block (lines 1-7, panics if taller), court title on lines 8-9 | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 2.111(4)-(6) | Case title below the court title on the left; case number to the right; nature of the paper below the case number | caption | same |
| CRC 2.111(7) | Judge and department below the nature of the paper, if assigned | caption: Date, Time, Dept., Judge | same |
| CRC 3.1112(a) | Motion papers: a notice of hearing, the motion itself, and a memorandum in support | notice, then memorandum, in one document | https://www.courts.ca.gov/cms/rules/index/three/rule3_1112 |
| CRC 3.1112(c) | Papers may be combined if the combined pleading specifies each item separately in its caption | caption lists the notice of motion and motion, and the memorandum, separately | same |
| CRC 3.1112(d) | Notice identifies the moving party, the parties addressed, and the basis and relief sought | content of the notice (the sample's notice). Not checked by the template. | same |
| CRC 3.1113(d) | Opening memorandum may not exceed 15 pages. The limit excludes the caption page, the notice, exhibits, declarations, the table of contents, the table of authorities, and the proof of service. | **enforced**: the template panics if the memorandum (from its title page to the page of the signature block) exceeds 15 pages | https://www.courts.ca.gov/cms/rules/index/three/rule3_1113 |
| CRC 3.1113(f) | A memorandum over 10 pages must include a table of contents and a table of authorities | TOC and TOA always generated (before the memorandum) | same |

The template does not generate a proof of service, the exhibits, declarations, a proposed order, or the notice's hearing-date arithmetic (CCP § 1005). Those are separate papers or content.

## Layout

- **Pleading grid.** Lines are 24 pt apart (double spacing). Each text line is a 1 em box (`top-edge: 0.7em`, `bottom-edge: -0.3em`), so the leading sets the pitch. The 28 line numbers use the same box settings. Checked with `pdftotext -bbox`: line 1 at y = 68.3 pt and line 28 at y = 716.3 pt, 28 body lines per page.
- **Bottom margin.** 46 pt: 28 lines fit and 29 do not. The footer sits 14 pt above the page edge.
- **Rules.** A double vertical rule at 1.22-1.25 in, between the numbers and the text. A single rule at 8.1 in, outside the right margin.
- **First page.** Attorney block in a fixed 168 pt box (lines 1-7; the template panics if the block is taller). Court title in a 48 pt box (lines 8-9). Caption starts on line 11. Left column 3.6 in, with a right and a bottom rule. The right column holds the case number, the title (bold, one paragraph per listed paper), the bracketed statutes, the hearing details, the action-filed date, and the concurrently-filed line.
- **Order of the document.** Caption page and notice (with signature block), then the table of contents, then the table of authorities, then the memorandum (title, body, signature block). Page numbers run continuously in Arabic from page 1 (CRC 2.109). Each table starts on a new page.
- **Table of contents.** Typst's outline of the headings (levels 1 to 4), indented by level, with dot leaders and page numbers, plus the lines for the table of authorities and the memorandum.
- **Table of authorities.** Each `[text](toa:KEY)` link in the body is a citation of KEY. The table reads the links from the document (`query(link)`), groups them by kind (cases, constitutional provisions, statutes, regulations, rules, other), sorts them by name or `sort`, and lists the pages. An authority on 7 or more pages prints "passim" (a convention, tier 2).
- **Headings.** Level 1: centered, bold, capitals. Level 2: bold, hanging under the text, indented 0.5 in. Level 3: bold, indented 1 in. Level 4: bold italic, indented 1.5 in. The labels (A., 1., a.) are typed by the author, not generated.
- **Footnotes** are 12 pt, single-spaced. **Block quotations** are single-spaced and indented 0.5 in on each side.
- **Signature block.** "Dated:" at the left; the firm lines and the "By:" line at 3.1 in; the signer in bold capitals and the role below.

No case-specific text is in the template. The parties, court, title, hearing, authorities and signature come from the frontmatter of the sample. No coordinate was measured off the exemplar. The template inserts line breaks only inside the attorney block, court title, caption and signature block, never inside body text.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

Frontmatter:

| Field | Required | Feeds |
|---|---|---|
| `footer_title` | yes | Footer title, at least 10 pt (CRC 2.110). Keep it on one line; the footer does not wrap. |
| `attorney` | yes | Lines of the attorney block, starting at line 1 (CRC 2.111(1)). Inline markdown is allowed. |
| `court` | yes | Lines of the court title (CRC 2.111(3)) |
| `caption.left` | yes | Lines of the parties. Leading spaces become an indent (0.25 em per space). |
| `caption.case_number` | no | Case number (CRC 2.111(5)) |
| `caption.title` | yes | Title, bold. One list item per paper (CRC 3.1112(c)). |
| `caption.details` | no | Bracketed statutes or other detail lines |
| `caption.action_filed`, `caption.concurrent` | no | "Action Filed:" and the bracketed concurrently-filed line |
| `hearing` | no | `date`, `time`, `dept`, `judge`: printed as Date / Time / Dept. / Judge (CRC 2.111(7)) |
| `authorities` | yes if the body cites | Registry: `kind` (`case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `cite` (required), `name` (optional; italic for cases), `sort` (optional sort key) |
| `signature` | yes | `dated`, `lines` (printed at the right, above the signature line), `signer` (bold caps), `role` |

Body: the notice of motion first, then a line `# MEMORANDUM OF POINTS AND AUTHORITIES` (the template splits the body on this line and prints the title itself), then the memorandum. Headings in the memorandum: `#` for a section, `##`, `###`, `####` for the sub-levels. Citations: `[*Case Name* (year) vol reporter page](toa:KEY)`. A key not in `authorities` is not checked by the template and will print without a table entry; check the table. Footnotes: `[^key]` and `[^key]: text`.

## Build and check

From the repo root:

```sh
export PATH=/work/artifacts/bin:$PATH   # only if typst, poppler and magick are not installed system-wide
sh tools/render.sh courts/ninth-circuit/california/state/superior-court/motion-brief samples/INPUT-aclu-fresno-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/california/state/superior-court/motion-brief aclu-fresno-motion-brief
```

The render fails on any typst warning. The font is vendored (`fonts/eb-garamond`), and `--ignore-system-fonts` is used. `pdffonts` on the output lists `EBGaramond-Regular`, `EBGaramond-Bold` and `EBGaramond-Italic`, all embedded.

## Samples and exemplar

- `samples/INPUT-aclu-fresno-motion-brief.md`: an excerpt transcribed from the exemplar. It has the caption, the notice (all of it, with the signature block), the introduction (in full), factual background sections A and B (in part), argument sections A and B (in part, with the block quotation from *Fredericks*), and the conclusion (in full). The exemplar has no proof of service. Its footnotes 3-8 and most of the memorandum (about 14 pages in the original) are not transcribed. The footnote text is abbreviated (the URLs are dropped).
- `samples/OUTPUT-aclu-fresno-motion-brief.pdf`: the render, 9 pages (caption and notice on pages 1-2, tables on pages 3-4, memorandum on pages 5-9). The memorandum runs 5 pages (CRC 3.1113(d): at most 15).
- `samples/OVERLAY-aclu-fresno-motion-brief.pdf` and `-overlay.txt`: the red/blue overlay against `exemplars/FILED-EXAMPLE-aclu-v-city-of-fresno-24CECG01635-motion-brief.pdf`. Page map from `overlay.sh`:

  ```
  ours p.1  filed p.1   word-overlap 78.5%
  ours p.2  filed p.2   word-overlap 81.6%
  ours p.3  filed p.3   word-overlap 45.5%
  ours p.4  filed p.4   word-overlap 39.3%
  ours p.5  filed p.7   word-overlap 88.1%
  ours p.6  filed p.8   word-overlap 45.2%
  ours p.7  filed p.11  word-overlap 47.1%
  ours p.8  filed p.12  word-overlap 42.3%
  ours p.9  filed p.21  word-overlap 61.7%
  ```

  The map is a text-similarity pairing, not a score. The overlay is a diagnostic (tier 3).

- Exemplar and sources: `exemplars/SOURCE.md`. The table of authorities of the exemplar (pages 4-6) lists the authorities used here; the sample's registry matches the exemplar's citations for the authorities it cites.

## Gate 2: page review (sample `aclu-fresno-motion-brief`, 9 pages, `pdftoppm -r 60`)

Each page of the current PDF was rendered and viewed. Compared with the exemplar's corresponding pages: p.1-2 caption and notice, p.3-4 contents and authorities, p.7-12 memorandum, p.21 signature.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Attorney block on lines 1-7; court title on lines 8-9; caption from line 11; hearing details, action-filed, and the concurrent line on the right; footer title on one line. | PASS |
| 2 | exemplar p.2 | Notice continues on the grid; "Dated" and the signature block at the right, with the signer's role below. | PASS |
| 3 | exemplar p.3 | Table of contents: every heading of the memorandum with its page; "MEMORANDUM OF POINTS AND AUTHORITIES" and "TABLE OF AUTHORITIES" lines; dot leaders. The exemplar's contents are the same kind of list. On "B. The PRA's 'Catch All'..." the page number wraps to its own line (the title fills the line); cosmetic. | ACCEPTED |
| 4 | exemplar p.4-6 | Table of authorities: Cases, Constitutional Provisions, Statutes; each with its pages; alphabetized. The exemplar's table lists its cases alphabetically; its statute and rule groups are not compared. Only the authorities cited in the sample are listed. | PASS |
| 5 | exemplar p.7 | Memorandum title centered, INTRODUCTION centered, "A." heading bold with a hanging line; footnote 1 at the foot of the page. The page ends with a gap of about 4 lines, where the footnote takes the space the next paragraph needs. | PASS |
| 6 | exemplar p.8-9 | Background sections A and B; the citation to "§ 7920.530" is a link to its own table entry. Footnote 2 at the foot of the page. | PASS |
| 7 | exemplar p.11 | Argument heading; "A." heading over two lines; citations set without a gap after the opening parenthesis. | PASS |
| 8 | exemplar p.12 | Argument B; block quotation single-spaced and indented on both sides; CONCLUSION centered; "(§ 7922.525" no longer splits at the line end. | PASS |
| 9 | exemplar p.21 | The signature block alone on this page: "Dated", "Respectfully submitted", "By:" with the signer and role. The conclusion fills page 8, and typst has no keep-with-previous for the last paragraph. The exemplar also puts its signature on the page after the conclusion (p.21), so this matches the exemplar's flow; it is still listed as a layout defect because a signature alone on a page is a clerk-visible defect. | OPEN |

Page 9 is the only open row. It is a layout issue (keep the last paragraph with the signature block), not a rule failure: every rule above is met on every page.

## Known gaps

1. **Font style (CRC 2.105): open.** The only vendored face is EB Garamond (`fonts/eb-garamond`), a Garamond rather than Times New Roman. CRC 2.105 requires a style "essentially equivalent to Courier, Times New Roman, or Arial", so this needs a decision from David: vendor a Times-metric face (for example Tinos, SIL OFL, metric-compatible with Times New Roman) into `fonts/`, or accept EB Garamond. The change is one line in `typst/calsuperct-motion-brief.typ` (`font-family`).
2. **Page 9 signature orphan** (Gate 2, OPEN). The same limitation is open in the complaint.
3. **Exemplars: one.** The brief asks for one exemplar per doc type. A second filer's motion (the EFF fee motion, Sacramento Superior Court, 34-2022-80004019) is recorded in `exemplars/SOURCE.md` but not stored. Tier-2 choices are therefore judged against one filer.
4. **Sample is an excerpt.** The memorandum sections not transcribed are not exercised by the template: other authorities, longer footnotes, more headings at each level, and the page-limit guard near 15 pages.
5. **Second, structurally different sample**: not made.
6. **Proof of service** is not generated. The exemplar has none.
7. **TOC wrap**: a title that fills its line pushes the page number onto the next line. No fix found that keeps the leader; cosmetic.
8. **Undefined keys**: a link `toa:KEY` whose key is not in `authorities:` is not reported; it simply does not appear in the table. Check the table against the citations.
9. **Hearing-date rules** (CCP § 1005(b) notice period, and the reservation of a hearing date) are not checked.
10. **Limited civil label, amount demanded**: not applicable to a motion; not implemented.
11. **Tier-1 checks** are not in `checks.yaml` form for this doc type. The mechanical guards are the attorney-block height panic and the 15-page memorandum panic.

[Court folder](../README.md) | [Formbook index](../../../../../../README.md)
