# cacd: motion-brief

Doc type: **motion-brief**: a Rule 12(b)(6) motion to dismiss, with the notice of motion and the memorandum of points and authorities, in the United States District Court for the Central District of California (`cacd`).
Folder: `courts/ninth-circuit/california/federal/central-district/motion-brief/` (self-contained: `typst/`, `usage/`, `usage/`).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer: defendant's counsel, Greenberg Traurig; filed 2020; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (portions of the 31-page filing; see below) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 10 pages each (typst 0.15.0, pdfLaTeX, LibreOffice), no warnings (2026-10-29, on the shared document model, fb-595.96) |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 10 of 10 on each engine rendered to PNG at 60 dpi (30 images, `.overlay/`); read by their text layout and line geometry (2026-10-29: the image viewer of the agent pod could not open them; see Gate 2 review) |

File names: the repo tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.{pdf,txt}`; the sample is `INPUT-<id>.md`; `<id>` is `backgrid-motion-brief`. This follows CLAUDE.md's file-role naming rather than `<id>.pdf`/`<id>-overlay.pdf`.

## Governing rules

| Rule | Requirement | Where in the template | Source checked |
|---|---|---|---|
| C.D. Cal. L.R. 11-3.1.1 | Standard proportional font, **14-point or larger**. | layout.yaml `size: 14`, footnotes 14 pt (Times New Roman, the exemplar's face and the house standard) | CACD Local Rules, Chapter I, https://www.cacd.uscourts.gov/sites/default/files/documents/LocalRules_Chap1.pdf (fetched 2026-10-14; footer dated 6/1/2020; see Known gaps 1) |
| L.R. 11-3.2 | 8½ × 11, numbered left margin, not more than 28 lines per page, double spaced, line 1 at least one inch below the top. | layout.yaml `pitch.body: 24`, `pleading.lines: 27` (the shared model draws the numbers and rules, fb-595.96) | same |
| L.R. 11-3.3 | Pages numbered consecutively at the bottom. | layout.yaml `page_number` (the number, the short title, the case number) and `lead` (the cover unnumbered, the notice from 1), `page_number.front` (the tables from i, the memorandum from 1) | same |
| L.R. 11-3.6 | Double spaced, including citations and quotations; footnotes may be single spaced (11-3.6.1). | Body, headings and the tables of contents and authorities at the 24 pt pitch (`pitch.body`, `contents.pitch`, `authorities.pitch`); counsel, caption and signature single spaced (16 pt) | same |
| L.R. 11-3.8(a) | Counsel block, lines 1 onward, left margin; party identified beneath. | `counsel` frontmatter, the first `lead` paper | same |
| L.R. 11-3.8(c) | Court title centred on or below line 8. | the counsel in a box at least seven numbered lines high (`min_height: 168`), the court title after it (line 9 in the sample: 13 counsel lines) | same |
| L.R. 11-3.8(d)-(e) | Party names left of centre; docket number right of centre, opposite the names; description of the document below. | `caption` | same |
| L.R. 11-3.8(e) (last sentence) | Hearing date and time below the description of the document. | `caption`: Date, Time, Courtroom, Judge lines | same |
| L.R. 7-3 | Conference of counsel at least seven days before filing; the notice states the conference date. | Notice paragraph 3 (from the sample) | same |
| L.R. 7-4 | Notice states the relief sought; the first page of the notice and of every document filed with the motion shows the hearing date and time and the judicial officer. | Notice paragraph 1 (relief and hearing date and time, from the sample); the `hearing` block on the cover, which is the first page of the filing, shows date, time, courtroom and judge | same |
| L.R. 7-5 | Memorandum of points and authorities served with the notice. | Notice, then the memorandum (one document, as in the exemplar) | same |
| L.R. 11-6.1 | Memorandum limit **7,000 words** (headings, footnotes, quotations counted; caption, tables, signature and certificate not). | `words: {limit: 7000, given: word_count}`: the filer's count, checked against the limit, printed in the certificate; the template does not count words itself | **courtrules.net** (https://www.courtrules.net/courts/federal/central-district-california/local-rules/1645, fetched 2026-10-14 through search excerpts only: the page returned 403 to WebFetch). The 6/1/2020 chapter instead has a 25-page limit at L.R. 11-6; see Known gaps 1 |
| L.R. 11-6.2 | Certificate of compliance on the last page, signed by counsel, stating the word count. | layout.yaml `after_tail`: "counsel of record for ... certifies that this brief contains N words, which complies with the word limit of L.R. 11-6.1." | paraphrase of the suggested form as described by courtrules.net (https://www.courtrules.net/courts/federal/central-district-california/local-rules/1644, 403 to WebFetch); **verify the exact form text** |
| L.R. 11-8 | Table of contents and table of authorities for a memorandum over ten pages. | layout.yaml `contents`, `authorities` (keyed, from the `toa:` links). The sample memorandum is 6 pages, so the tables are not required by the rule; the template produces them anyway, as the exemplar does | same |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim as a defence, asserted by motion. | Notice paragraph 1 | https://www.law.cornell.edu/rules/frcp/rule_12 (fetched 2026-10-14; the page cites "Apr. 2, 2024, eff. Dec. 1, 2024" as the latest amendment in its notes) |


## Layout

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`) with C.D. Cal.'s rules overlaid in `typst/layout.yaml`, set by the shared document model (`lib/typst/xdoc.typ`; `latex/` and `docx/` generated by `fb engines gen`, fb-595.96).

- Pleading paper (layout.yaml `pleading`): the numbers 1 to 27, right-aligned on 1 in, one per 24 pt numbered line from the one-inch top margin; a double rule at 1.3 in and 1.34 in from the page's left edge and a single rule at 7.6 in. `eval.yaml` params.pleading_lines: 27 drops the numbers from the text the checks read.
- Cover (the first `lead` paper, unnumbered, no footer): counsel from line 1, the court title from line 8 at the earliest (line 9 in the sample), the caption with the party column ruled at its right and foot (designations half an inch in), the case number, the title in bold and the hearing (date, time, courtroom, judge) on the right.
- Notice of motion (the second `lead` paper, from 1): `notice_to` and the notice paragraphs from the frontmatter, the signature.
- Table of contents (i) and table of authorities (ii), at the 24 pt pitch, dot leaders to a page column, page numbers from the document.
- Memorandum (from 1): headings `#` (I., at the margin) and `##` (A., half an inch in), numbered by the layout, bold, at the 24 pt pitch; paragraphs with a 0.5 in first-line indent; the conclusion; the signature, kept with the last paragraph.
- Certificate of compliance (L.R. 11-6.2) on its own page, signed.
- The sample's body opens with the two papers' markers (`<!-- notice -->`, `<!-- memorandum -->`), which set nothing.

## Markdown contract (for samples)

- Frontmatter: `notice_to` (optional), `notice` (the notice's paragraphs), `case_number`, `caption` (list of `{names, designation}`), `brief_title`, `footer_title` (in capitals, as filed), `hearing` (`date`, `time`, `place` = courtroom, `judge`), `counsel` (lines; an empty string a blank line), `division` (optional), `date`, `signature` (`firm`, `signer`, `lines`), `certificate_party`, `word_count` (the filer's count), `authorities` (keyed: `{kind, name, cite}`).
- Body: the markers `<!-- notice -->` and `<!-- memorandum -->` first; then `# HEADING` (numbered I., II.), `## Heading` (numbered A., B.), paragraphs. Numbers are not typed in the text.
- Citations: `[*Case v. Name*, 556 U.S. 662, 678 (2009)](toa:key)`; a short form links to the same key.

## Known gaps and open choices

1. **Rules version.** The copy of the CACD Local Rules that was reachable is the 6/1/2020 edition of Chapter I. The December 2025 edition named in the search index returned 404. The 7,000-word limit (L.R. 11-6.1) and the certificate (11-6.2) come from courtrules.net excerpts, which were reachable only through search; the page itself returns 403. **The current text of 11-3, 11-6.1 and 11-6.2 has not been confirmed against the court's own publication.** This is the first thing to check before the PR.
2. **Exemplar age.** The exemplar was filed on 2020-02-03, under a rule set that predates the current word limit. The exemplar's 25-page-style length and certificate are not evidence of the current form.
3. **Tables at the 24 pt pitch.** L.R. 11-3.6 requires double spacing "including citations and quotations"; since fb-595.68.22 the tables of contents and authorities are set at the numbered lines' pitch (they were single spaced).
4. **Cover height.** The party column is 2.7 inches wide so the title block and hearing details fit beside it on the cover.
5. **Footer.** The page number, the short title (`footer_title`, in capitals as filed) and "CASE NO." with the case number, centred, 10 pt in 12 pt lines, the last 12 pt above the foot (`page_number.foot`); the exemplar sets the title at the left and the case number at the right of one line (one filer's layout, tier 3). The cover has no footer.
6. **Word count.** `word_count: 1161` is `wc -w` over the markdown body (headings included, citations included). A filer's software count may differ. The count covers the sample, not the whole filing. The layout takes it as the filer's (`words.given`) and stops the render over 7,000 (`words.limit`).
7. **Certificate wording.** The certificate sentence follows the summary of the suggested form on courtrules.net. Verify it against the official form before relying on it.
8. **Sample is partial.** The sample transcribes the notice's operative paragraphs, the introduction, the first part of the summary of facts, the standard of review, and the conclusion. It does not transcribe filed pages 6 to 14 (the rest of the facts and the argument), 15 to 20 (the argument), or the request for judicial notice, the declaration and the proposed order. The table of authorities is generated from the sample's citations, so it is not the filed table.
9. **Footnotes.** The sample has none; the layout sets them at 14 pt, single-spaced (L.R. 11-3.6.1), in every engine.
10. **Hearing details.** The exemplar's notice gives "Courtroom 7B" and "Honorable André Birotte Jr." on the cover; the template prints them as the sample supplies them. Current CACD practice may require a different form of the judicial officer's name; not checked.
11. **Italics.** The text layer of the exemplar carries no italic markup; the sample italicizes case names from the citation form.

## Gate 2 review (2026-10-29)

After the move onto the shared model (fb-595.96): every page of the three renders (10 typst, 10 latex, 10 docx: 30 pages) rasterized at 60 dpi with pdftoppm into `.overlay/`. The agent's image viewer could not open the PNGs in its pod, so each page was read by its text layout (`pdftotext -layout`) and its line geometry (`fb measure`); a look at the images themselves is left to the reviewer (PR). The three engines break every line and page alike (XENG-001..003 PASS).

| Page | Printed | What it is | Finding (all three engines) | Status |
|---|---|---|---|---|
| 1 | none | Cover: counsel, court title, caption, title, hearing | Structure as filed; the exemplar's tabbed hearing block and the party column ruled to the row's foot differ (eval.yaml `cover_structure: report`). | ACCEPTED (tier 3) |
| 2 | 1 | Notice of motion, signature | OK. | OK |
| 3 | i | Table of contents | OK. No "Page" label over the column (the model's contents have none). | OPEN (tier 2) |
| 4 | ii | Table of authorities | OK: "Page(s)", italic case names, a comma before the citation. | OK |
| 5-9 | 1-5 | Memorandum: introduction, summary of facts, argument, conclusion, signature | OK: I./A. headings in their boxes, citations, signature kept with the last paragraph. | OK |
| 10 | 6 | Certificate of compliance, signature | OK: "1,161 words". | OK |
| all | | Footer: number, short title, case number (none on the cover) | Centred lines, not the exemplar's split line (gap 5). | ACCEPTED (tier 3) |

Reviewed pages: 10 of 10 on each engine (30).

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.96): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/cacd-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua` (`docx/cacd-motion-brief.lua` is gone; the LaTeX engine is new; Word's numbers and rules are the model's header shapes, no longer a footer frame and page borders). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`).

`sh tools/check.sh <dir>`: typst 10 passed, 0 failed; `--engine latex`: 13 passed, 0 failed; `--engine docx`: 14 passed, 0 failed; XENG-001..003 PASS on both. Not verified in Word (LibreOffice only).

[Parent: california/federal/central-district](../README.md)
