# Motion or brief in a contested matter — United States Bankruptcy Court, D. Idaho (`idb`)

Complete doc-type folder: template, two samples from two filers, two exemplars, renders, overlays. Court-level README: [../README.md](../README.md).

The two exemplars are different kinds of contested-matter paper from different filers: a numbered objection with argument (Ziegler, objecting creditors) and a motion with a negative-notice legend and a memorandum of points and authorities (Redline, the debtor). Provenance in `usage/SOURCE.md`.

## Layout

- `typst/main.typ` entrypoint; `typst/idb-motion-brief.typ` template (parameters at the top, each cited to the rule or the convention it follows).
- `usage/INPUT-idb-motion-brief-ziegler.md` and `usage/INPUT-idb-motion-brief-redline.md` transcribed samples.
- `usage/OUTPUT-<id>.pdf` our renders (ziegler 9 pages, redline 6 pages), from `sh tools/render.sh <this-dir> usage/INPUT-<id>.md`.
- `usage/OVERLAY-<id>.pdf` and `.txt`, from `sh tools/overlay.sh <this-dir> <id> usage/SAMPLE-...pdf`. The exemplar is passed explicitly: with no third argument `overlay.sh` takes the first exemplar in `ls` order (redline), which is the wrong one for the ziegler sample.
- `usage/SAMPLE-idb-motion-brief-ziegler2040042.pdf` (9 pages) and `usage/SAMPLE-idb-motion-brief-redline2400388.pdf` (17 pages; the motion is pages 1-7).

## Markdown contract

Frontmatter: `case_number` (with the judge suffix), `chapter`, optional `judge` (a third caption line), `debtors` (`names`, `designation`), `title`, optional `notice` (`heading`, `paragraphs` of `label` + `text`: the LBR 2002-2(d)(1) legend), `counsel` (lines), `lead_in`, `dated`, `signature` (`lines_above`, `signer`, optional `by` prefix, default "By ", `lines_below`), optional `service_signature` (`signer`, `name`).

Body, one blank-line-separated chunk each: `# ` centered bold heading (numbering stops after `# PRAYER` or `# CERTIFICATE...`); `## ` centered bold; `### ` bold at the left (a leading "1." is kept as text, not turned into a list); `- ` bulleted items (the source's own letters, if any, stay in the text); `> ` block quote; `~ ` flush continuation; `: ` unnumbered indented paragraph; `WHEREFORE` unnumbered; `[^id]` footnote references with `[^id]: text` definitions (set at the foot of the page that cites them); anything else is a numbered paragraph ("1.", "2.", ...).

Placement: the dated line and signature follow the body and come before `# CERTIFICATE OF SERVICE` (both filers). The body's last chunk is kept on the signature's page in one non-breakable block, so the signature never stands alone. `service_signature` closes the certificate.

## Rules followed (primary sources; fetched 2026-10-14, re-checked 2026-10-16)

- D. Idaho LBR 5005-1 [v. 3], Documents for Filing or Administering: http://www.id.uscourts.gov/Content_Fetcher/index.cfml/Bankruptcy_Local_Rule_5005-1_3699.htm?Content_ID=3699
  - (a): 8 1/2 x 11 paper (`paper: "us-letter"`).
  - (c)(1): counsel block in the upper left, starting 1 inch from the top, with name, ISB number, email, office address, telephone, facsimile, and the party represented (`margin-top`, `counsel-block`).
  - (c)(2): type 12 to 14 point. Body 13 pt (`type-size`); footnotes 12 pt (`note-size`; typst's default 0.85 em would be 11 pt, under the floor). The rule names no typeface, so the template keeps EB Garamond (docs/FONTS.md). The page number in the footer is 11 pt; it is a page furniture item the rule does not reach, carried over unchanged from the earlier pass. Verify if the court reads (c)(2) as covering it.
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
| double-spaced body | `body-leading` 1.45 em (about 27.5 pt baseline to baseline at 13 pt, Word "double" at 12 pt) | yes | yes |
| justified body | `justify: true` | yes | yes |
| 0.5 in first-line indent | `para-indent` | yes | yes |
| numbers "1." with a tab to the text | `num-width` 0.5 in box | yes | yes (sections II-III) |
| single-spaced counsel block, caption, block quote, signature | `single-leading` | yes | yes |
| bold centered title in caps under the caption | yes | yes | yes |
| signature block in the right half, after the dated line | `sig-indent` 3.0 in | yes | yes |
| footnote at the foot of the page, smaller and single spaced | 12 pt, `single-leading` | yes | (exhibit only) |

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
| ziegler | 8 | WHEREFORE kept with the dated line and firm block; certificate follows | OK |
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

## Remaining gaps

- The redline sample renders 6 pages, under the 8 to 14 aimed for: the filed motion itself is 7 pages, and its exhibits (a proposed order with its own caption, a settlement agreement) are separate papers the template does not set.
- The redline exemplar's source URL was not recorded when the file was committed (see `usage/SOURCE.md`).
- Case names: Ziegler has no italics in its text layer, so that sample has none; the redline sample italicizes case names as filed.
- No `rules.md` or `checks.yaml` in this folder, so `tools/check.sh` gates have not been run here.
- The docx engine (`docx/`) was not touched in this pass and still follows the earlier contract: it letters `- ` items, has no `[^id]` footnotes, no `: ` paragraphs, no `notice`, `judge`, `by`, `lines_below` or `service_signature`, and puts the signature at the end. `usage/OUTPUT-idb-motion-brief-ziegler.docx` is from the earlier sample. The latex engine has no folder for this doc type.

## Engines

### docx (`docx/`)

- Set in `docx/reference.docx` (built by `docx/make-reference.sh`) and read by `docx/idb.lua`. Set in styles.xml/sectPr, not rendered: EB Garamond 13 pt in every style; body and numbered paragraphs double spaced (line 480 auto) with 0.6 em (156 twips) after; US Letter, 1 in margins; headings centered bold (levels 1 and 2) or bold at the left (level 3), single spaced; a centered PAGE field at 11 pt in the footer; block quotes single spaced, indented 0.75 in left and 0.5 in right.
- Written by the filter, not rendered here: counsel block single spaced at the top margin; court heading (two lines); caption as a two-column table with a 0.75 pt vertical rule; title in caps; lead-in and numbered paragraphs with a first-line indent, numbers typed with a tab (not Word list numbering); lettered items `(a)`; the dated line and signature block at 3.0 in; numbering stops after the PRAYER and CERTIFICATE OF SERVICE headings.
- Differs from typst: see "Remaining gaps" (the typst contract moved on in this pass); line breaks and page count come from Word or LibreOffice; the typed numbers do not renumber when a paragraph is inserted; the caption rule is a table border, not a line.
- Not yet checked: no page of the docx has been rendered or looked at (pages_reviewed = 0).
- BLOCKED (docx.pdf gates 0 to 3): LibreOffice (`soffice`) is not installed on the build box, so no `.docx.pdf` exists and the gates cannot run. The `.docx` itself is written and validated (zip and well-formed XML parts only).
- BLOCKED (no TOC or TOA in this doc type): nothing to populate.
