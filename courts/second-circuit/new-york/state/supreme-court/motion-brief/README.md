# Supreme Court of the State of New York: memorandum of law on a motion (motion-brief)

Doc type `motion-brief` for court `nysupct` (CourtListener id `nysupct`, New York Supreme Court, the state's general trial court). Layout follows the one-folder-per-doc-type convention: everything for this doc type lives in this folder. The court root (`../court.json`) holds only the court record, unchanged here; `status` stays `todo` (set by David only). The sibling doc type `complaint/` is untouched.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-motion-brief.pdf` | The real filed memorandum of law (Plaintiff's opposition to a CPLR 3211 motion), 30 pp., text layer. Provenance: `usage/SOURCE.md`. |
| `usage/INPUT-motion-brief.md` | Markdown transcription of a portion of the exemplar: cover data, the Preliminary Statement, the Statement of Facts, Argument I (intro, I.A.i(a)-(c), I.A.ii), the Conclusion, signature, service list and certification. Verbatim text except where the Known gaps section says otherwise. |
| `usage/OUTPUT-motion-brief.typst.pdf` | Our render (14 pp.). |
| `usage/OVERLAY-valentino.pdf`, `usage/OVERLAY-valentino.txt` | Red/blue overlay of our render on the exemplar, and the page map. |
| `typst/main.typ` | Entry point: reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/nysupct-motion-brief.typ` | The template. Content-agnostic; every number is a named parameter at the top and traces to a rule (NYSM- IDs below) or a stated convention. |

File names: the sample is `INPUT-motion-brief.md` and the outputs are `OUTPUT-motion-brief.typst.pdf` and `OVERLAY-valentino.{pdf,txt}`, which are the names `tools/render.sh` and `tools/overlay.sh` read and write by default (the same pattern as the sibling `complaint/` folder). The brief asked for `<id>.pdf` and `<id>-overlay.pdf`; the tools do not take those names, and the tools were not edited.

## Governing rules

Verified 2026-10-14 (date fetched). "Primary" means the text came from the official host. "Mirror" means it came from a non-official copy (Cornell LII) because the official host (nycourts.gov, nysenate.gov) refused the fetch from this box. "Secondary" means the text was reported in search results, not read from the statute.

| ID | Rule | Requirement used | Source | Status |
|---|---|---|---|---|
| NYSM-FORM-001 | 22 NYCRR 202.5(a)(1) | Double space between lines (except quotations and attorney names and addresses) | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-202.5 | mirror (text read) |
| NYSM-FORM-002 | 22 NYCRR 202.5(a)(1) | Print no smaller than 12-point | same | mirror (text read) |
| NYSM-FORM-003 | 22 NYCRR 202.5(a)(1) | Footnotes no smaller than 10-point (11-point used) | same | mirror (text read) |
| NYSM-FORM-004 | 22 NYCRR 202.5(a)(1) | 8 1/2 x 11 in. paper; margins no smaller than one inch; writing on one side only | same | mirror (text read) |
| NYSM-CAP-001 | 22 NYCRR 202.5(a)(1) | Index number and county of venue on the cover and first page, to the right of the caption; a brief description of the paper | same | mirror (text read) |
| NYSM-CAP-002 | 22 NYCRR 202.5(a)(1) | Name of the assigned judge to the right of the caption, where the case is assigned (the `judge` field; shown only when given) | same | mirror (text read) |
| NYSM-SIG-001 | CPLR 2101(a) | Legible, black ink; type no smaller than 10-point for general papers (202.5 requires 12-point, which is stricter and is used); the name signed must be printed beneath each signature | https://www.nysenate.gov/legislation/laws/CVP/2101 | secondary (nysenate.gov refused the fetch; text taken from search results quoting the statute, consistent across sources) |
| NYSM-SIG-002 | CPLR 2101(a) | Paper 11 x 8 1/2 in. | same | secondary (as NYSM-SIG-001) |
| NYSM-WORD-001 | 22 NYCRR 202.8-b(a)(i), (a)(ii) | Affidavits, affirmations, briefs and memoranda of law in chief: 7,000 words; reply: 4,200 words (unless the court permits otherwise). The template asserts the count is within the limit and fails the build otherwise. `filing: reply` selects 4,200 | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-202.8-b | mirror (text read); the Cornell page is titled "[Effective until 7/7/2025]" and a secondary source lists a later amendment effective 1/1/2026; both versions report the same limits. Re-check the current text on nycourts.gov before landing |
| NYSM-WORD-002 | 22 NYCRR 202.8-b(b), (c) | The count excludes the caption, table of contents, table of authorities and signature block. A certification page is attached to the end, stating the count and that the document complies; counsel may rely on the word-processing count | same | mirror (text read) |
| NYSM-EFILE-001 | 22 NYCRR 202.5(a)(2) | An electronically-submitted memorandum of law over 4,500 words, prepared on a computer, must include bookmarks listing the document's contents. The template's PDF outline comes from the headings (see the render check below) | same | mirror (text read) |

Not generated: the NYSCEF legend on the first page (22 NYCRR 202.5-b, not fetched; the exemplar carries one). The PDF is text-based and bookmarked; the legend is a separate filing-system artifact.

Conventions (not rules; each is named in the template):

- **Font.** Face required: none. 22 NYCRR 202.5(a) and CPLR 2101(a) set a minimum point size and name no typeface, so the template sets Times New Roman (the house standard, docs/FONTS.md; vendored) at 12 pt, footnotes at 11 pt (the 202.5(a) floors are 12 and 10), on typst and docx alike (the docx names the typst face through `{font}` in docx/reference.xml; data/exemplar-fonts.json records `template_face`).
- **Spacing.** Double spacing (202.5(a)) as exact 24 pt line boxes; quotations, the cover, headings, tables, signature and service blocks in 13.8 pt single lines (202.5(a) excepts quotations and attorneys' names and addresses); footnotes in 12.65 pt lines. The pitches are those of the shared cross-engine layout model (lib/typst/xengine.typ). The cover sets the title and the counsel block 1.6 in below the part above each (no flexible space, which Word has no equivalent for).
- **Caption.** The court and county on the top lines; a bordered party box on the left with `-against-` between the sides; the index number, the judge and the motion sequence on the right. The title is printed once, centred on the cover, with the counsel block at the foot of the page (the exemplar's layout).
- **Headings.** The author types the numbering (I., A., i., a.), as the exemplar does. Level 1 is centred bold capitals; levels 2 and 3 are bold; level 4 is bold italic; level 5 is italic. Headings deeper than level 5 fail the build.
- **Table of contents and table of authorities.** The TOC is generated from the headings (levels 1-4) with dot leaders, in roman numerals. The TOA is generated from the `toa:KEY` links in the body with their pages, in the exemplar's groups (Cases, Statutes, Other Authorities). An authority on 7 or more pages prints "passim" (the ca9 convention).
- **Front matter and body numbering.** Cover unnumbered; TOC and TOA in lower-case roman; the body in arabic from 1.
- **Signature block.** Dated line (place and date), "Respectfully submitted," the firm, "By:" over a rule, and the signer's printed name beneath (CPLR 2101(a)). The service list ("TO:") follows.
- **Certification.** A separate page at the end: the word count, the clause (`202.8-b(a)(i)` or `(a)(ii)`), and the signer's name under a rule.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the markdown body. The template generates the caption, cover, TOC, TOA, signature block, service list and certification.

### Frontmatter

| Field | Required | Type | Feeds |
|---|---|---|---|
| `county` | yes | string | Second caption line ("COUNTY OF ...") |
| `index_no` | yes | string | Right of the caption, top line |
| `judge` | no | string | Right of the caption, under the index number (NYSM-CAP-002) |
| `motion_seq` | no | string | Right of the caption, under the judge |
| `parties` | yes | list of `{names, designation}` | Caption party box; the template puts `-against-` between groups. `names` is a list of lines; inline markdown allowed |
| `title` | yes | string | Centred on the cover; PDF title |
| `filing` | no (default `in-chief`) | `in-chief` or `reply` | Selects the word limit (NYSM-WORD-001) and the clause in the certification |
| `toc` | no (default true) | boolean | Table of contents on the page after the cover |
| `date` | yes | string | Under the place line in the signature block and on the certification |
| `place` | yes | string | "New York, New York" in the signature block and on the certification |
| `counsel` | yes | `{names, lines, on_brief}` | Cover counsel block at the foot of the page; `on_brief` (optional) is the "On the Memorandum of Law:" list |
| `signature` | yes | `{firm, signer, lines}` | `firm` (list above "By:"), `signer` (printed beneath the rule), `lines` (names under the signer) |
| `to` | no | list of `{names, lines}` | Service list after the signature |
| `authorities` | yes | map of KEY to `{kind, name, cite}` | Table of authorities. `kind` is `case`, `constitution`, `statute`, `regulation`, `rule` or `other`. `name` is optional (italic for cases); `cite` is required; `sort` overrides the sort key. A key used in the body but not listed fails the build |

Strings that begin with `*` (italic markup) or contain `*` must be quoted in YAML. A cite that contains a literal asterisk (a Westlaw star page) is written with a backslash escape (`\*2-3`) inside a single-quoted string.

### Body

- `# HEADING` (level 1) is a section: centred, bold, capitals. The template does not require any particular section; the exemplar uses PRELIMINARY STATEMENT, STATEMENT OF FACTS, ARGUMENT, CONCLUSION.
- Sub-headings are typed by the author: `## I. ...`, `### A. ...`, `#### i. ...`, `##### a. ...`.
- Numbered paragraphs are typed with the number escaped (`1\.`).
- **Case names and other emphasis**: `*Horne v. Flores*`. The template does not guess what a case name is; whatever is italicised is italic.
- **Authorities**: cite with a link whose target is `toa:KEY`, with the full citation as the text: `[*Allergan Fin., LLC v. Pfizer Inc.*, 67 Misc.3d 1206(A) (Sup. Ct. N.Y. 2020)](toa:allergan)`. Every link is recorded with the page it starts on.
- **Footnotes**: `text[^key]` and, anywhere in the file, `[^key]: One paragraph of footnote text.`
- **Block quotations**: `> quoted text`. Indented and single-spaced.
- Smart punctuation is on. Not supported: tables, images, raw HTML, raw typst, headings deeper than level 5.

## Build and check

From the repo root (toolchain first: `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/second-circuit/new-york/state/supreme-court/motion-brief usage/INPUT-motion-brief.md   # -> usage/OUTPUT-motion-brief.typst.pdf
sh tools/overlay.sh courts/second-circuit/new-york/state/supreme-court/motion-brief valentino                    # -> OVERLAY-valentino.pdf and .txt
```

Typst runs as `typst compile --root <doctype-dir> --font-path fonts --ignore-system-fonts --package-cache-path vendor/typst-packages --input sample=usage/NAME.md typst/main.typ out.pdf`. The font and the markdown package (cmarker 0.1.10) are vendored, so a build never depends on what is installed or on the network. Any typst warning fails the render (`tools/render.sh`).

Checks run for this doc type:

- **Render**: `tools/render.sh` exit 0, no warnings; typst 0.15.0; all fonts embedded as `TimesNewRoman*` (`pdffonts`).
- **Word-limit gate (negative test)**: a throwaway sample of 7,102 words was rendered; the build failed with `assertion failed: ... 7102 words exceeds the 22 NYCRR 202.8-b(a) limit of 7000`. The throwaway file was deleted.
- **Word count cross-check**: the certification on the sample states 2,854 words. Counting the words of the PDF text on the body pages (4-12, page-number lines excluded) gives 2,854. The sample count and the PDF agree.
- **Outline**: the PDF carries a bookmark outline generated from the headings (NYSM-EFILE-001).
- **Overlay**: `tools/overlay.sh` ran and wrote `OVERLAY-valentino.pdf` and `.txt`.
- **Page review**: all 14 rendered pages were rasterised with `pdftoppm -r 60` and looked at (see below).

## What the overlay shows

Red = our render; blue = the filed exemplar; black = both agree. The page map (`OVERLAY-valentino.txt`) pairs each render page with the exemplar page sharing the most words:

| Ours | Filed | Word overlap | What it compares |
|---|---|---|---|
| 1 | 1 | 82.9% | Cover (the caption and counsel block line up well) |
| 2 | 2 | 35.4% | TOC (ours is a generated list; the exemplar's is a typed list with a different layout) |
| 3 | 4 | 28.0% | TOA (rebuilt in our style; the exemplar's TOA runs over two pages, and its entries are typed) |
| 4-8 | 6-10 | 55-86% | Preliminary Statement, Argument I.A.i.(a)-(c). The closest body match is the Preliminary Statement (85.8%) |
| 9-12 | 12-16 | 38-87% | Argument I.A.i.(c) to I.A.ii, the Conclusion |
| 13 | 29 | 42.8% | Signature block and service list (the exemplar's signature is on p. 29 with the Conclusion) |
| 14 | 30 | 57.1% | Certification |

The overlay is a diagnostic, not a score. The low overlap on pages 2-3 is structural (the generated TOC and TOA), not a text error; the body pages overlap where the sample transcribes the exemplar.

## Page review (all 14 pages)

Rendered at `pdftoppm -r 60` and looked at, page by page. Page numbers below are PDF page numbers (the cover is p. 1); the body's own printed numbers start at 1 on PDF p. 4. Findings and actions:

| Page (render) | Finding | Action |
|---|---|---|
| 1 cover | The title printed twice (once in the caption's right column, once centred). | Fixed: the caption no longer prints the title; the centred title is the only copy. Re-rendered and re-checked. |
| 2 TOC | Each entry printed its page number twice (`1 ... 1`). | Fixed: the outline entry uses `it.body()`, not `it.inner()`, which already includes the page. Re-checked: one page number per entry; the CONCLUSION entry added in the final render. |
| 3 TOA | Cases alphabetised; each entry has its citation, dot leaders and pages; "Statutes" and "Other Authorities" groups correct. | None. |
| 4 Preliminary Statement | Double spacing; footnote 1 in the smaller footnote face at the foot of the page; the heading is centred. | None. |
| 5 Preliminary Statement, Statement of Facts | Double spacing; "STATEMENT OF FACTS" heading and its one paragraph at the foot of the page. | None. |
| 6 Argument I | Level 2 heading wraps at the hyphen in "PRE-ANSWER" (a natural break in the typed heading). The CPLR 3211 block quotation (Allergan) is single-spaced and indented; the level 3, 4 and 5 headings (A., i., a.) are distinct. | Accepted. |
| 7 I.A.i.(a) | Body; the TOA-linked citations are italic where the exemplar italicises them; the "*cf.*" signal is italic; footnote 3 at the foot. | None. |
| 8 I.A.i.(b) | Level-5 heading "b."; the Section 21.11 block quotation is single-spaced and indented, as the exemplar sets it. | None. |
| 9 I.A.i.(b) to (c) | The paragraphs after the block quotation; footnotes 4, 5 and 6 at the foot; the level-5 heading "c." sits directly after the paragraph above with little space. | Accepted (cosmetic). |
| 10 I.A.i.(c) to ii. | Body; the level-4 heading "ii." starts mid-page, with the Kel Kim citation italic under it. | None. |
| 11 I.A.ii | Body; footnote 7 ("See Footnote 5") at the foot; the "¶¶ 17, 23 and 25" and "§ 3211" tokens are kept together. | None. |
| 12 Conclusion | CONCLUSION heading (centred) and its one paragraph; the page ends with white space. | None. |
| 13 Signature, service list | The signature block (CPLR 2101(a): the signer's printed name beneath the rule), the "Dated" stack, and the TO: list. The block moves to this page as a whole. | Accepted; see Known gaps. |
| 14 Certification | Count 2,854, clause `202.8-b(a)(i)`, dated line, the signer's name beneath the rule. | None. |

## Known gaps

- **The sample is a portion of the brief, not the whole.** The exemplar is 30 pages; the sample transcribes the cover, both tables (rebuilt), the Preliminary Statement, the Statement of Facts, Argument I.A.i.(a)-(c) and I.A.ii, the Conclusion, signature, service list and certification. Not transcribed: the rest of I.A.i.(c) (the Sage Realty, Urban Archaeology and Maxton passages, and a paragraph on the pandemic's "complex" character), I.A.iii to v, I.B, Point II, Point III, and footnotes beyond those in the sample. The omitted passages are dropped from the sample rather than filled in; the TOA lists only the authorities the sample cites.
- **The signature block lands on its own page (render p. 13).** The Conclusion ends near the foot of PDF p. 12, too little room for the signature block, so it moves to p. 13 as a whole. The exemplar keeps the closing paragraph with the signature. The ca9 template keeps the last paragraph with the signature block (`courts/ninth-circuit/court-of-appeals/typst/ca9-brief.typ`); this template does not yet. The signature block itself is complete and not split.
- **Commercial Division Rule 17.** The exemplar's certification cites Rule 17 of the Rules of Practice for the Commercial Division (believed to be 22 NYCRR 202.70(g); not verified), not 202.8-b. The case is a Commercial Division case. This template uses 202.8-b (the brief's governing rule). Commercial Division Rule 17 was not fetched and is not implemented. Commercial Division matters may carry different limits or certification wording; a Commercial Division filing needs that rule checked before the template is used for one.
- **Word count is the template's count.** The certification number is computed from the markdown (headings, text and footnotes; excluding the caption, TOC, TOA and signature block), and was cross-checked against the PDF text on this sample. Counsel may rely on the word-processing count (202.8-b(c)); the certification must be checked against the word processor before signing.
- **Rules not re-verified against the official host.** nycourts.gov and nysenate.gov refused the fetch from this box. The 202.5 and 202.8-b texts are read from Cornell's copy (labelled "[Effective until 7/7/2025]"); a secondary source reports an amendment effective 1/1/2026. The CPLR 2101(a) text is from secondary sources. Re-check all three against the official text before landing.
- **E-filing legend and 202.5-b** are not generated or fetched.
- **Exemplar is an opposition, not a motion in support.** `motion-brief` covers both. The exemplar is a Plaintiff's memorandum in opposition; the template treats it as an in-chief brief (7,000 words). A reply brief uses `filing: reply` (4,200 words); not exercised on any filed exemplar here.

## Decisions

- **One exemplar, not two.** The brief asked for one real filed document of this type. Valentino v. 693 Fifth Owner LLC was chosen: a NYSCEF-stamped NY County memorandum with a text layer, 30 pp., and the full structure (cover, TOC, TOA, sections, signature, service list, certification). Two other candidates were found by search and listed in `usage/SOURCE.md` (a Suffolk County memorandum in support of a CPLR 3211 motion; a NY County memorandum in *Wong*).
- **Cover follows the exemplar, not the complaint.** The complaint template prints the title in the caption's right column; the memorandum prints it once, centred, with the counsel block at the foot of the cover, as the exemplar does.
- **Word limit enforced as a build failure.** An over-limit sample fails the render, rather than printing a certification that is wrong. The limit is the rule's, not a convention.
- **Cmarker markdown, as in the ca9 template.** The same markdown contract, the same `toa:` link mechanism for the TOA, and the same page-accurate tagging.
- **No disclosure statement and no addendum.** Not required for a NY Supreme Court memorandum; the exemplar has neither.

## Provenance

- Exemplar: `usage/SOURCE.md` (URL fetched from, case, index no., filer, date filed, date fetched).
- Rules: the Cornell and search-result sources in the table above, read 2026-10-14.

## Engines

Two engines: `typst/` (the reference) and `docx/` (no `latex/` for this court yet). The docx engine is declarative: `docx/reference.xml` (the cross-engine style recipe, `base="xengine"`, in the typst face) and `docx/nysupct-motion-brief.lua` (cover, the three sections: cover unnumbered, tables lower-case roman from i, body arabic from 1; the tables of contents and authorities with page numbers from fb render's needles; body, signature block, service list, word-count certification with the count made from the sample rule for rule as typst makes it). `fb render` builds the reference document and runs the passes; there is no shell script. Render: `sh tools/render.sh --engine docx courts/second-circuit/new-york/state/supreme-court/motion-brief usage/INPUT-motion-brief.md`.

- **Cross-engine gate.** `eval.yaml` sets `params.cross_engine: gate`: the docx render breaks every line and every page where the typst render does (XENG-001..003, fb-595.68.37); the tables' page numbers and the certified word count are the same on both engines.
- **Known docx difference (diagnostic only).** LibreOffice sets the right-aligned party designations in the caption box about 2.6 pt further left than typst (the box's right rule); no line or page break moves.
- **Word count.** Both engines count the sample's body and footnotes the same way; the certificate states that count, so counsel must check it against the word processor before signing.
