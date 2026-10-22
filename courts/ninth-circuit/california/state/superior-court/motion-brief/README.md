# calsuperct: motion-brief

Doc type `motion-brief` for the California Superior Courts (court alias `calsuperct`). A notice of motion and motion, with the memorandum of points and authorities, in one document on pleading paper. Template: `typst/calsuperct-motion-brief.typ`, entry `typst/main.typ`.

Status: **typst and docx** (no latex). Both engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): the docx breaks every line and page where typst does, its tables of contents and authorities included (`eval.yaml`: `cross_engine: gate`).

## Governing rules

Verified 2026-10-13 against the Judicial Council rule pages. Quotations are from those pages as shown by the fetch; re-check the text against the Judicial Council pages before any filing.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.100-2.119 | Format of papers (scope) | whole document | https://www.courts.ca.gov/cms/rules/index/two/rule2_100 |
| CRC 2.103 | Papers 8½ × 11 inches; opaque white or unbleached, 20 lb (not e-filed) | page size (`us-letter`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_103 |
| CRC 2.104 | Font size not smaller than 12 points | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | Font style essentially equivalent to Courier, Times New Roman, or Arial | Times New Roman (typst: `("Times New Roman", "Liberation Serif")`, the vendored metric twin; the docx names Times New Roman through `{font}` in `docx/reference.xml`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107 | Left margin at least 1 inch; right margin at least ½ inch | `left-margin = 1.5in`, `right-margin = 0.5in` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 |
| CRC 2.108 | Lines one-and-one-half or double spaced and numbered consecutively; numbers at the left margin, separated from the text by a space of at least ⅕ inch or a single or double vertical line; at least 3 numbers per vertical inch | double spacing (24 pt pitch), 28 numbers, double rule | https://www.courts.ca.gov/cms/rules/index/two/rule2_108 |
| CRC 2.109 | Pages numbered consecutively at the bottom, Arabic numerals only, from the first page | footer page number; no roman numerals for the tables | https://www.courts.ca.gov/cms/rules/index/two/rule2_109 |
| CRC 2.110 | Footer below the page number, divided from the page by a printed line; the title of the paper (or a clear abbreviation) in at least 10-point type | footer | https://www.courts.ca.gov/cms/rules/index/two/rule2_110 |
| CRC 2.111(1)-(3) | Attorney information from line 1, 1 inch from the top; clerk's space in lines 1-7 right of center; court title on line 8, at or below 3⅓ inches | attorney block from line 1, each line left of center (the template stops on a line that does not fit); court title on line 8, or the first numbered line below a longer block | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 2.111(4)-(6) | Case title below the court title on the left; case number to the right; nature of the paper below the case number | caption | same |
| CRC 2.111(7) | Judge and department below the nature of the paper, if assigned | caption: Date, Time, Dept., Judge | same |
| CRC 3.1112(a) | Motion papers: a notice of hearing, the motion itself, and a memorandum in support | notice, then memorandum, in one document | https://www.courts.ca.gov/cms/rules/index/three/rule3_1112 |
| CRC 3.1112(c) | Papers may be combined if the combined pleading specifies each item separately in its caption | caption lists the notice of motion and motion, and the memorandum, separately | same |
| CRC 3.1112(d) | Notice identifies the moving party, the parties addressed, and the basis and relief sought | content of the notice (the sample's notice). Not checked by the template. | same |
| CRC 3.1113(d) | Opening memorandum may not exceed 15 pages. The limit excludes the caption page, the notice, exhibits, declarations, the table of contents, the table of authorities, and the proof of service. | **enforced**: the template panics if the memorandum (from its title page to the page of the signature block) exceeds 15 pages | https://www.courts.ca.gov/cms/rules/index/three/rule3_1113 |
| CRC 3.1113(f) | A memorandum over 10 pages must include a table of contents and a table of authorities | TOC and TOA always generated (before the memorandum) | same |

The template does not generate a proof of service, the exhibits, declarations, a proposed order, or the notice's hearing-date arithmetic (CCP § 1005). Those are separate papers or content.

## Layout

Every number is in `typst/calsuperct-motion-brief.typ` (parameters at the top) and, in twips, in `docx/calsuperct.lua`.

- **Pleading grid (CRC 2.108).** 28 numbered lines of 24 pt from 1 in below the top edge (double spacing: the body, the headings and the rows of both tables); single-spaced lines (attorney block, caption, signature, block quotations, footnotes; CRC 2.108(3)) are 12 pt, two to a numbered line, each group starting 9.6 pt below a numbered line's top so every other single line stands level with a number. The bottom margin is the 48 pt left under the 28th line. Every line is a box of its pitch with the baseline at 0.8 of it (the cross-engine model).
- **Numbers and rules.** The numbers 1-28 right-aligned 1 in from the page edge on the body's line boxes (typst: `lib/typst/pleading-paper.typ`; docx: a page-anchored frame in the footer); a double rule left of the text and a single rule right of it (docx: page borders).
- **Footer (CRC 2.109, 2.110).** 2 pt below the 28th line: the page number (Arabic from page 1, 12 pt), a printed line, the paper's title in capitals at 10 pt. In the docx both sit in a page-anchored frame, the line an underlined tab (LibreOffice grows a footer with text in its flow into the 28th line, and drops a framed paragraph's border).
- **First page (CRC 2.111, 3.1110(b), 3.1112(c)).** The attorney block from line 1, one line per item, left of center (the template stops on an item that does not fit); the court title, bold and centered, on line 8 or the first numbered line after a longer block; a numbered line below, the caption: the case title in the left half, ruled at its right and foot; in the right column, a blank single line apart, the case number, the title of each paper combined (bold), the details, the hearing (Date, Time, Dept., Judge) with the date the action was filed, and the papers filed with it. The notice starts on the first numbered line at least 12 pt below the caption (typst measures where it ended; the docx filter counts the columns' lines with the vendored face's advances, `docx/lib/measure.lua`).
- **Order.** Caption and notice with its signature block; the table of contents; the table of authorities; the memorandum (its title, the body, the signature block). Each table and the memorandum start a page.
- **Tables (CRC 3.1113(f)).** Rows on the numbered lines (typst `listing-row`): the text wraps before a page column (contents 0.5 in, authorities 0.75 in), a dot leader runs from three spaces after it to the page. Contents: the table of authorities, the memorandum, and each heading of the memorandum (level 1 at the margin; deeper levels with the author's label in a half-inch box a half inch further in per level). Authorities: each `[text](toa:KEY)` link of the memorandum, grouped by kind (Cases, Constitutional Provisions, Statutes, Regulations, Rules, Other Authorities), sorted, with the pages it is cited on ("passim" from 7 pages); case names in italics, then the year and report (California style). The docx takes every page number from `fb render`'s needles (the LibreOffice PDF).
- **Headings.** On the numbered lines with no space of their own, bold, kept with the text: level 1 centered capitals; deeper levels the author's label ("A.") in a half-inch box, a half inch further in per level, the lines after the first hanging after the label; level 4 italic.
- **Body.** Paragraphs indent their first line 0.5 in. Block quotations single-spaced, 0.5 in in on both sides, the first line on the next numbered line, the text after them on the first numbered line half a single line clear. Footnotes at 12 pt in 12 pt lines, 6 pt apart, under a 2 in rule; a paragraph that anchors one has no widow or orphan rule on either engine (docx: Body Text Note), and a line whose note does not fit on its page moves to the next page with its note (Word's and LibreOffice's rule; typst would keep the line and move the note alone: the template's note guard places an empty float that ends the page above that line).
- **Signature.** A numbered line below the last paragraph, kept on one page with it: "Dated:" at the margin, the signature lines from 3.1 in, a numbered line lower "By:" and a 2.7 in signature line, the signer (bold capitals) and role 0.3 in further in.
- **Length (CRC 3.1113(d)).** The template stops when the memorandum (its first page to its signature) runs over 15 pages.

No case-specific text, no coordinate measured off the exemplar, no forced line break: the attorney, court and caption lines are the frontmatter's own list items.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

Frontmatter:

| Field | Required | Feeds |
|---|---|---|
| `footer_title` | yes | Footer title, at least 10 pt (CRC 2.110). Keep it on one line; the footer does not wrap. |
| `attorney` | yes | Lines of the attorney block, starting at line 1 (CRC 2.111(1)); each must fit left of center (split a long one). Inline markdown is allowed. |
| `court` | yes | Lines of the court title (CRC 2.111(3)) |
| `caption.left` | yes | Lines of the parties. Leading spaces become an indent (0.25 em per space). |
| `caption.case_number` | no | Case number (CRC 2.111(5)) |
| `caption.title` | yes | Title, bold. One list item per paper (CRC 3.1112(c)). |
| `caption.details` | no | Bracketed statutes or other detail lines |
| `caption.action_filed`, `caption.concurrent` | no | "Action Filed:" and the bracketed concurrently-filed line |
| `hearing` | no | `date`, `time`, `dept`, `judge`: printed as Date / Time / Dept. / Judge (CRC 2.111(7), 3.1110(b)(1)) |
| `authorities` | yes if the body cites | Registry: `kind` (`case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `cite` (required), `name` (optional; italic for cases), `sort` (optional sort key) |
| `signature` | yes | `dated`, `lines` (printed at the right, above the signature line), `signer` (bold caps), `role` |

Body: the notice of motion first, then a line `# MEMORANDUM OF POINTS AND AUTHORITIES` (the template splits the body on this line and prints the title itself), then the memorandum. Headings in the memorandum: `#` for a section, `##`, `###`, `####` for the sub-levels. Citations: `[*Case Name* (year) vol reporter page](toa:KEY)`. A key not in `authorities` stops the build. Footnotes: `[^key]` and `[^key]: text`.


## Build and check

From the repo root:

```sh
sh tools/check.sh courts/ninth-circuit/california/state/superior-court/motion-brief                 # typst
sh tools/check.sh courts/ninth-circuit/california/state/superior-court/motion-brief --engine docx   # docx, XENG gated
just overlay courts/ninth-circuit/california/state/superior-court/motion-brief
```

Typst renders with the vendored fonts only (`--ignore-system-fonts`; any warning fails): Liberation Serif, the metric twin of Times New Roman. The docx names Times New Roman; its LibreOffice PDF embeds it.

## Samples and exemplar

- `usage/INPUT-motion-brief.md`: an excerpt transcribed from the exemplar: the attorney block (line for line as filed, the two firm names split once more to stay left of center), the caption, the notice (all of it), the introduction, factual background A and B (in part), argument A and B (in part, with the block quotation from *Fredericks*) and the conclusion. Footnotes 3-8 and most of the memorandum are not transcribed.
- `usage/OUTPUT-motion-brief.typst.pdf`, `usage/OUTPUT-motion-brief.docx`, `usage/OUTPUT-motion-brief.docx.pdf`: 9 pages each (caption and notice pp. 1-2, contents p. 3, authorities p. 4, memorandum pp. 5-9, 5 pages: CRC 3.1113(d) allows 15).
- Exemplar and source: `usage/FILED-EXAMPLE-motion-brief.pdf`, `usage/SOURCE.md` (ACLU of Southern California, 2024).

## Gate 2: page review (typst and docx, 9 pages each, `pdftoppm -r 60`)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Attorney block lines 1-12, left of center; court title on line 13 (the exemplar's 12: one more attorney line); caption from line 16 with the hearing, filing date and concurrent papers at the right; the notice's first line on line 28. docx alike. | PASS |
| 2 | exemplar p.2 | The notice on the numbered lines, then its signature block a numbered line below. docx alike. | PASS |
| 3 | exemplar p.3 | Table of contents: the authorities, the memorandum, every heading with its page, labels in their boxes, a wrapped heading hanging after its label. docx alike, same pages. | PASS |
| 4 | exemplar p.4-6 | Table of authorities: Cases, Constitutional Provisions, Statutes, sorted, with their pages. typst sets the page at the right of its column (the leader stops at the column), the docx right after the leader (Word's tab): the same words on every line. | ACCEPTED |
| 5 | exemplar p.7 | Memorandum title, INTRODUCTION, factual background and A.; footnote 1 at the foot; the line with footnote 2's mark moves to page 6 with its note (lines 26-27 stay empty). docx alike. | PASS |
| 6 | exemplar p.8-9 | Background A and B; footnote 2. docx alike. | PASS |
| 7 | exemplar p.11 | ARGUMENT, A. over two lines hanging after its label. docx alike. | PASS |
| 8 | exemplar p.12 | B. heading, the block quotation single-spaced and indented both sides; the conclusion, kept whole with the signature block, moves to page 9. docx alike. | PASS |
| 9 | exemplar p.20-21 | CONCLUSION, then the signature block a numbered line below it. docx alike. | PASS |
| all | | docx: the pleading rules are page borders, which LibreOffice draws from the top margin to the footer, not the full page height as typst draws them. | ACCEPTED |

## Known gaps

1. **Exemplars: one.** A second filer's motion (the EFF fee motion, Sacramento Superior Court, 34-2022-80004019) is recorded in `usage/SOURCE.md` but not stored. Tier-2 choices are judged against one filer.
2. **Sample is an excerpt.** Other authorities, longer footnotes and the page-limit guard near 15 pages are not exercised.
3. **Proof of service** is not generated. The exemplar has none.
4. **Hearing-date rules** (CCP § 1005(b) notice period, the reservation of a hearing date) are not checked.
5. **The note guard** moves a footnote's line only when the mark is on the page where its paragraph starts; a mark later in a paragraph that started a page earlier keeps typst's own rule (the note alone moves on), which the docx would not follow (XENG would show it).
6. **docx line counts.** The filter counts the caption's and a block quotation's lines from the face's advances, breaking at spaces only; text that typst breaks elsewhere would put the docx off the numbered lines (XENG would show it).

## Engines

- **typst** (primary): `typst/main.typ`, `typst/calsuperct-motion-brief.typ`.
- **docx**: `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face, Body Text Note) and `docx/calsuperct.lua` (every paragraph, the caption table, both tables with their page numbers from `FORMBOOK_NEEDLES` / `FORMBOOK_PAGES`, the signature blocks, the footer via `FORMBOOK_FOOTERS`, the page via `FORMBOOK_FINAL`), `docx/lib/measure.lua`. `fb render` builds the reference document and the archive; no shell script. Gated against typst (XENG-001..003).
- **latex**: not built for this doc type.

[Court folder](../README.md) | [Formbook index](../../../../../../README.md)
