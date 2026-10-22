# Motion or brief in a contested matter — United States Bankruptcy Court, D. Idaho (`idb`)

Complete doc-type folder: template, two samples from two filers, two exemplars, renders, overlays. Court-level README: [../README.md](../README.md).

The two exemplars are different kinds of contested-matter paper from different filers: a numbered objection with argument (Ziegler, objecting creditors) and a motion with a negative-notice legend and a memorandum of points and authorities (Redline, the debtor). Provenance in `usage/SOURCE.md`.

## Layout

- `typst/main.typ` entrypoint; `typst/idb-motion-brief.typ` template (parameters at the top, each cited to the rule or the convention it follows).
- `usage/INPUT-motion-brief-2.md` and `usage/INPUT-motion-brief.md` transcribed samples.
- `usage/OUTPUT-<id>.pdf` our renders (ziegler 10 pages, redline 6 pages; typst and docx), from `sh tools/render.sh <this-dir> usage/INPUT-<id>.md`.
- `usage/OVERLAY-<id>.pdf` and `.txt`, from `sh tools/overlay.sh <this-dir> <id> usage/SAMPLE-...pdf`. The exemplar is passed explicitly: with no third argument `overlay.sh` takes the first exemplar in `ls` order (redline), which is the wrong one for the ziegler sample.
- `usage/FILED-EXAMPLE-motion-brief-2.pdf` (9 pages) and `usage/FILED-EXAMPLE-motion-brief.pdf` (17 pages; the motion is pages 1-7).

## Markdown contract

Frontmatter: `case_number` (with the judge suffix), `chapter`, optional `judge` (a third caption line), `debtors` (`names`, `designation`), `title`, optional `notice` (`heading`, `paragraphs` of `label` + `text`: the LBR 2002-2(d)(1) legend), `counsel` (lines), `lead_in`, `dated`, `signature` (`lines_above`, `signer`, optional `by` prefix, default "By ", `lines_below`), optional `service_signature` (`signer`, `name`).

Body, one blank-line-separated chunk each: `# ` centered bold heading (numbering stops after `# PRAYER` or `# CERTIFICATE...`); `## ` centered bold; `### ` bold at the left (a leading "1." is kept as text, not turned into a list); `- ` bulleted items (the source's own letters, if any, stay in the text); `> ` block quote; `~ ` flush continuation; `: ` unnumbered indented paragraph; `WHEREFORE` unnumbered; `[^id]` footnote references with `[^id]: text` definitions (set at the foot of the page that cites them); anything else is a numbered paragraph ("1.", "2.", ...).

Placement: the dated line and signature follow the body and come before `# CERTIFICATE OF SERVICE` (both filers). The body's last chunk is kept on the signature's page in one non-breakable block, so the signature never stands alone. `service_signature` closes the certificate.

## Rules followed (primary sources; fetched 2026-10-14, re-checked 2026-10-16)

- D. Idaho LBR 5005-1 [v. 3], Documents for Filing or Administering: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_5005-1_3699.htm?Content_ID=3699
  - (a): 8 1/2 x 11 paper (`paper: "us-letter"`).
  - (c)(1): counsel block in the upper left, starting 1 inch from the top, with name, ISB number, email, office address, telephone, facsimile, and the party represented (`margin-top`, `counsel-block`).
  - (c)(2): type 12 to 14 point. Body 12 pt (`type-size`), Times New Roman (the rule names no typeface; Times New Roman is the house standard, docs/FONTS.md, and both filers set it); footnotes 12 pt (`note-size`; typst's default 0.85 em would be 11 pt, under the floor); the page number 12 pt.
  - (c)(3): caption with "UNITED STATES BANKRUPTCY COURT" and "DISTRICT OF IDAHO", and the case number with the three-letter judge suffix (asserted; both "20-40042-JMM" and the "24-bk-00388-ngh" form are accepted).
  - Not in the rule: line spacing, margins other than the 1-inch top, page numbering, footnotes. Those are tier 2 (below).
- D. Idaho LBR 2002-2 [v. 4], Notice and Hearing: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_2002-2_4296.htm?Content_ID=4296
  - (d)(1): a motion on negative notice carries the legend (No Objection / Objection / Hearing on Objection) immediately below the caption; the 2008 advisory committee note puts it in a text box before the substantive allegations. The template sets `meta.notice` in a ruled box under the title and before the lead-in. The legend's words come from the sample (the objection period varies; (d)(2) sets a 14-day floor). (e)(4) has a parallel legend for notices set 28 or more days out; the same field carries it.
- D. Idaho LBR 9014-1, Witness Testimony at Hearings on Contested Matters: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_9014-1_578.htm?Content_ID=578 — a content duty (say whether witnesses will testify), not a format rule; not implemented.
- D. Idaho LBR 9004-1 (form of orders) applies to orders, not motions or briefs; not used.
- Fed. R. Bankr. P. 9013, 9014, 9004(a)-(b) are cited in the template header; their texts were not fetched in this pass.

**Gap, not closed:** no Idaho local rule on the format or length of a motion or brief was found; the local rules index (https://www.id.uscourts.gov/bankruptcy/forms_fees_rules/Rules.cfm, re-checked 2026-10-16) has no LBR 9013. The template sets no page or word limit.

## Tier 2 choices (seen in both filers, so convention)

| choice | template | Ziegler | Redline |
|---|---|---|---|
| double-spaced body | `pitch-double` 27.6 pt line boxes (Word "double" at 12 pt Times New Roman) | yes | yes |
| justified body | ragged right since fb-595.68.23 (the cross-engine model: typst and Word justify differently, so no two engines would break alike) | yes | yes |
| 0.5 in first-line indent | `para-indent` | yes | yes |
| numbers "1." with a tab to the text | `num-width` 0.5 in box | yes | yes (sections II-III) |
| single-spaced counsel block, caption, block quote, signature | `pitch-single` 13.8 pt | yes | yes |
| bold centered title in caps under the caption | yes | yes | yes |
| signature block in the right half, after the dated line | `sig-indent` 3.0 in | yes | yes |
| footnote at the foot of the page, smaller and single spaced | 12 pt, `pitch-single` | yes | (exhibit only) |

## What the overlays show

Red is our render, blue the filed exemplar, black where they agree. Pages are paired by word overlap (`.txt`).

`usage/OVERLAY-ziegler-motion-brief.pdf`:

| our page | filed page | word overlap |
|---|---|---|
| 1 | 1 | 82.5% |
| 2 | 2 | 81.1% |
| 3 | 3 | 72.1% |
| 4 | 4 | 57.6% |
| 5 | 5 | 48.1% |
| 6 | 6 | 54.4% |
| 7 | 8 | 52.2% |
| 8 | 9 | 47.1% |
| 9 | 9 | 31.4% |

Both are 9 pages. Pages 1-3 run in step (counsel block, caption, title, paragraphs 1-4, footnote 1 at the foot of page 3 in the filed brief; ours puts the footnote at the foot of page 3, where its reference falls). From page 4 ours runs ahead by a fraction of a page (EB Garamond 13 pt against Times New Roman 12 pt), so page 7 pairs with filed 8. Ours closes like the filed brief: WHEREFORE, the dated line and firm block, then the certificate of service (our 8-9, filed 9).

`usage/OVERLAY-redline-motion-brief.pdf`:

| our page | filed page | word overlap |
|---|---|---|
| 1 | 1 | 84.1% |
| 2 | 2 | 65.8% |
| 3 | 3 | 60.5% |
| 4 | 5 | 44.2% |
| 5 | 5 | 41.8% |
| 6 | 6 | 33.3% |

Page 1 aligns on the counsel block, caption with the judge line, title and the boxed notice. The filer starts the body on a new page after the notice; ours runs the lead-in on under the box (the rule asks only that the legend come before the substantive allegations). Ours is 6 pages against the filed motion's 7, because the filer set the dated line and signature alone on page 7 and ours keeps the conclusion with the signature on page 6.

## Gate 2 review (pages rendered at 60 dpi and looked at, 2026-10-16)

Pages reviewed: ziegler OUTPUT 9/9 and OVERLAY 9/9; redline OUTPUT 6/6 and OVERLAY 6/6 (30 pages).

| sample | page | finding | status |
|---|---|---|---|
| ziegler | 1 | counsel block, court name, caption with rule, title, lead-in, paragraph 1; the filed counsel block is a two-column table (two firms) | ACCEPTED (tier 3: one filer's table) |
| ziegler | 2 | paragraph 2 double spaced and justified, as filed | OK |
| ziegler | 3 | footnote 1 at the foot of the page, 12 pt, under a rule; bullets start | OK |
| ziegler | 4 | bullets double spaced at 0.5 in with a hanging indent; filed bullets sit at about 1 in with a right indent too | ACCEPTED (tier 3) |
| ziegler | 5-6 | block quote single spaced, indented both sides, breaks across 5-6 | OK |
| ziegler | 7 | paragraph 9 | OK |
| ziegler | 8 | WHEREFORE kept with the dated line and firm block; certificate follows (superseded by the review below) | OK |
| ziegler | 8-9 | service list one recipient per line; the filer sets it in two columns, name over email | ACCEPTED (tier 3) |
| ziegler | 1-9 | no running footer title ("Objection to Debtor's Motion to Convert / Page - n"); ours has a centered page number | ACCEPTED (tier 3: Redline uses a centered number) |
| redline | 1 | judge line in the caption; LBR 2002-2 notice in a ruled box, centered bold heading, underlined run-in labels | OK |
| redline | 1 | filer's caption has rules above and below the court name and title, and "Case Number:" | ACCEPTED (tier 3) |
| redline | 2 | MEMORANDUM heading centered bold; section headings bold at the left; filer underlines them and hangs "I." on a tab | ACCEPTED (tier 3) |
| redline | 2-3 | numbered paragraphs 1-11 with aligned text after 1. and 10.; page 2 ends about 4 lines short because heading III is kept with paragraph 4 | OK |
| redline | 4 | lettered factors inside the block quote stay as the filer's text; flush citation line after the quote | OK |
| redline | 5 | sub-headings "1." to "3." bold at the left; filer indents them about 1 in; page ends about 3 lines short (heading 4 kept with its paragraph) | ACCEPTED (tier 3) |
| redline | 6 | CONCLUSION, its paragraph, dated line and signature (/s/ name, firm, party) on one page | OK |

No OPEN tier-2 rows.

## Gate 2 review of the cross-engine renders (fb-595.68.23, 2026-10-22)

Every page of both samples rendered at 60 dpi on both engines (typst and docx.pdf side by side) and looked at: ziegler 10/10, redline 6/6 per engine (32 pages). The two engines are line for line and page for page alike on every page.

| sample | page | finding | status |
|---|---|---|---|
| redline | 1 | counsel, court lines, caption (rule, judge line), title, the legend in its ruled box, lead-in; ragged right where the filers justify | ACCEPTED (cross-engine model) |
| redline | 2-5 | headings, numbered paragraphs 1-11, the block quote and its flush citation line, sub-headings 1-3 | PASS |
| redline | 6 | sub-heading 4, CONCLUSION, its paragraph kept with the dated line and signature | PASS |
| ziegler | 1 | counsel block (two firms one after the other, a blank line before the party), caption, three-line title, lead-in, paragraph 1 | PASS |
| ziegler | 2 | paragraph 2 | PASS |
| ziegler | 3 | footnote 1 at the foot of the page, 12 pt, indented mark | PASS |
| ziegler | 4-5 | bullets with a hanging indent; paragraphs 5-7 | PASS |
| ziegler | 6-7 | block quote and its Id. line, the See also continuation, paragraphs 8-9 | PASS |
| ziegler | 8 | paragraph 9 ends half way down: WHEREFORE is kept with the dated line and signature on page 9 (the template keeps the last body paragraph with the signature) | ACCEPTED (template rule) |
| ziegler | 9-10 | WHEREFORE, dated line, firm block and signature; CERTIFICATE OF SERVICE, e-mail and mail lists, its signature | PASS |

## Remaining gaps

- The redline sample renders 6 pages, under the 8 to 14 aimed for: the filed motion itself is 7 pages, and its exhibits (a proposed order with its own caption, a settlement agreement) are separate papers the template does not set.
- The redline exemplar's source URL was not recorded when the file was committed (see `usage/SOURCE.md`).
- Case names: Ziegler has no italics in its text layer, so that sample has none; the redline sample italicizes case names as filed.
- The latex engine has no folder for this doc type.

## Engines

Both engines follow the cross-engine layout model (lib/typst/xengine.typ, lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): first-fit ragged-right lines, no kerning, ligatures or hyphenation, every line an exact box of its pitch (27.6 pt body, 13.8 pt single), explicit spaces between blocks. `eval.yaml` sets `params.cross_engine: gate`: the docx must break every line and page as typst does (XENG-001..003; both samples 100 %: 145/145 and 237/237 lines, 6 and 10 pages).

### docx (`docx/`)

- `docx/reference.xml` (base="xengine", `{font}` = the typst face, Times New Roman 12 pt): Body Text 552-twip exact lines with a 720-twip first-line indent; headings in the same boxes; Footnote Text 12 pt in 276-twip lines with the half-inch indent before the mark; "Body Text Note" for a paragraph that carries a footnote (pandoc writes it; no widow control; a tab at 1 in for the number); letter page, 1-inch margins, centered page number 735 twips above the page foot. pandoc reads the sample without fancy lists or definition lists, so "(a)" in a quotation and `: ` paragraphs stay text.
- `docx/idb.lua` writes every other paragraph as WordprocessingML with the typst spacings: counsel lines, court lines, the caption as a two-cell table (right rule on the party column), the negative-notice legend as a one-cell ruled table (0.1 in inset; 129 twips above and below, Word adds the 0.75 pt rule inside the cell), numbered paragraphs ("1." and a tab to 1 in), bullets (0.3 in box at 0.5 in), quotations (0.75 in / 0.5 in, a sample's hard line break kept), the dated line and signature kept with the last body paragraph, the certificate and its signature.
- Footnote clearance: LibreOffice keeps more than 13.2 pt and at most 26.8 pt between the last text line and the first note (measured on this template by lengthening the note); typst's `note-clearance` + `note-gap` is 17 pt, inside that range.
- No TOC or TOA in this doc type.
