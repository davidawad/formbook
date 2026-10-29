# cacd: motion-brief

Doc type: **motion-brief**: a Rule 12(b)(6) motion to dismiss, with the notice of motion and the memorandum of points and authorities, in the United States District Court for the Central District of California (`cacd`).
Folder: `courts/ninth-circuit/california/federal/central-district/motion-brief/` (self-contained: `typst/`, `usage/`, `usage/`).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer: defendant's counsel, Greenberg Traurig; filed 2020; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (portions of the 31-page filing; see below) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, Times New Roman, no typst warnings (docx: `usage/OUTPUT-motion-brief.docx`, `.docx.pdf`, the same 10 pages) |
| overlay | ok: `usage/OVERLAY-backgrid-motion-brief.pdf` and `usage/OVERLAY-backgrid-motion-brief.txt` (page map below) |
| pages reviewed | 10 of 10 on typst and on docx: every page rendered at 50 dpi (the tables at 80 dpi) and viewed after the cross-engine port (fb-595.68.22) |

File names: the repo tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.{pdf,txt}`; the sample is `INPUT-<id>.md`; `<id>` is `backgrid-motion-brief`. This follows CLAUDE.md's file-role naming rather than `<id>.pdf`/`<id>-overlay.pdf`.

## Governing rules

| Rule | Requirement | Where in the template | Source checked |
|---|---|---|---|
| C.D. Cal. L.R. 11-3.1.1 | Standard proportional font, **14-point or larger**. | `type-size = 14pt` (Times New Roman, the exemplar's face and the house standard; the docx through `{font}`) | CACD Local Rules, Chapter I, https://www.cacd.uscourts.gov/sites/default/files/documents/LocalRules_Chap1.pdf (fetched 2026-10-14; footer dated 6/1/2020; see Known gaps 1) |
| L.R. 11-3.2 | 8½ × 11, numbered left margin, not more than 28 lines per page, double spaced, line 1 at least one inch below the top. | `pitch = 24pt`, `lines-per-page = 27`, `line-numbers()`, `pleading-rules()` | same |
| L.R. 11-3.3 | Pages numbered consecutively at the bottom. | `footer-block`: the number in the numbering of its page (cover none; notice, memorandum arabic from 1; tables roman from i) | same |
| L.R. 11-3.6 | Double spaced, including citations and quotations; footnotes may be single spaced (11-3.6.1). | Body, headings and the tables of contents and authorities at the 24 pt pitch (`pitch`); counsel, caption and signature single spaced (16 pt) | same |
| L.R. 11-3.8(a) | Counsel block, lines 1 onward, left margin; party identified beneath. | `counsel` frontmatter, `counsel-block` | same |
| L.R. 11-3.8(c) | Court title centred on or below line 8. | `court-title`: on the numbered line after the counsel block (line 9 in the sample: 11 counsel lines) | same |
| L.R. 11-3.8(d)-(e) | Party names left of centre; docket number right of centre, opposite the names; description of the document below. | `caption` | same |
| L.R. 11-3.8(e) (last sentence) | Hearing date and time below the description of the document. | `caption`: Date, Time, Courtroom, Judge lines | same |
| L.R. 7-3 | Conference of counsel at least seven days before filing; the notice states the conference date. | Notice paragraph 3 (from the sample) | same |
| L.R. 7-4 | Notice states the relief sought; the first page of the notice and of every document filed with the motion shows the hearing date and time and the judicial officer. | Notice paragraph 1 (relief and hearing date and time, from the sample); the `hearing` block on the cover, which is the first page of the filing, shows date, time, courtroom and judge | same |
| L.R. 7-5 | Memorandum of points and authorities served with the notice. | Notice, then the memorandum (one document, as in the exemplar) | same |
| L.R. 11-6.1 | Memorandum limit **7,000 words** (headings, footnotes, quotations counted; caption, tables, signature and certificate not). | `word_count` in frontmatter is printed in the certificate; the template does not count words itself | **courtrules.net** (https://www.courtrules.net/courts/federal/central-district-california/local-rules/1645, fetched 2026-10-14 through search excerpts only: the page returned 403 to WebFetch). The 6/1/2020 chapter instead has a 25-page limit at L.R. 11-6; see Known gaps 1 |
| L.R. 11-6.2 | Certificate of compliance on the last page, signed by counsel, stating the word count. | `certificate()`: "counsel of record for ... certifies that this brief contains N words, which complies with the word limit of L.R. 11-6.1." | paraphrase of the suggested form as described by courtrules.net (https://www.courtrules.net/courts/federal/central-district-california/local-rules/1644, 403 to WebFetch); **verify the exact form text** |
| L.R. 11-8 | Table of contents and table of authorities for a memorandum over ten pages. | `toc-section`, `toa-section` (generated from the `toa:` links). The sample memorandum is 6 pages, so the tables are not required by the rule; the template produces them anyway, as the exemplar does | same |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim as a defence, asserted by motion. | Notice paragraph 1 | https://www.law.cornell.edu/rules/frcp/rule_12 (fetched 2026-10-14; the page cites "Apr. 2, 2024, eff. Dec. 1, 2024" as the latest amendment in its notes) |

## Layout

- Cover: counsel from line 1; court title on line 9; caption with the party column ruled at its right and foot, the case number, the title and the hearing details on the right. Cross-engine layout model (`lib/typst/xengine.typ`): every numbered line a 24 pt box, the line numbers on the same boxes; single lines 16 pt, each group starting 6.4 pt below a numbered line's top (`single-drop`), so every third single line stands level with a line number.
- Notice of motion (page 1 of the arabic count): the notice paragraphs, the conference statement, the signature block (unbreakable).
- Table of contents (page i) and table of authorities (page ii): at the 24 pt pitch, dot leaders to a page column (`listing-row`), page numbers from the document (headings and `toa:` links).
- Memorandum (arabic from 1): headings `## I.` (level 2, bold, hanging), `### A.` (level 3, bold, indented one half inch), body at the 24 pt pitch, first-line indent 0.5 inch; the conclusion; the signature block; a page break; the certificate of compliance.
- A `toa:KEY` link in the markdown is recorded with the page it starts on; a key with no registry entry in the frontmatter stops the build.

## Overlay (red/blue)

`tools/overlay.sh` pairs each render page with the best-matching exemplar page by shared words:

```
ours p.1  filed p.1   word-overlap 81.7%
ours p.2  filed p.3   word-overlap 36.7%
ours p.3  filed p.4   word-overlap 23.9%
ours p.4  filed p.6   word-overlap 29.0%
ours p.5  filed p.10  word-overlap 72.0%
ours p.6  filed p.10  word-overlap 37.4%
ours p.7  filed p.11  word-overlap 81.4%
ours p.8  filed p.15  word-overlap 44.8%
ours p.9  filed p.15  word-overlap 38.7%
ours p.10 filed p.31  word-overlap 46.7%
ours p.11 filed p.31  word-overlap 30.0%
```

The overlap is a diagnostic, not a score. The sample transcribes portions of the filing, so a page pairs with the exemplar page sharing most words, and the low figures on pages 2 to 4 and 8 to 11 reflect the untranscribed text (the rest of the facts, the argument) rather than a layout difference. The differences were not itemized in this run.

## Markdown contract (for samples)

- Frontmatter: `notice_to` (optional: the notice's address line, e.g. "TO PLAINTIFF AND ITS ATTORNEYS OF RECORD:"; was template text), `case_number`, `caption` (list of `{names, designation}`), `brief_title`, `footer_title`, `hearing` (`date`, `time`, `place` = courtroom, `judge`), `counsel` (lines), `notice` (list of paragraphs for the notice of motion; inline markdown; no `toa:` links here, since the table of authorities is built from the memorandum only), `date`, `signature` (`firm` lines, `signer`, `lines`), `certificate_party`, `word_count`, `authorities` (registry: `kind` case, statute, rule, regulation or other; `name` (optional); `cite`).
- Body: `## HEADING` (level 2, numbered I., II.), `### Heading` (level 3, numbered A., B.), paragraphs, lists. Numbers are not typed in the text.
- Citations: `[*Case v. Name*, 556 U.S. 662, 678 (2009)](toa:key)`; a short form links to the same key. Case names in italic by `*...*`.

## Known gaps and open choices

1. **Rules version.** The copy of the CACD Local Rules that was reachable is the 6/1/2020 edition of Chapter I. The December 2025 edition named in the search index returned 404. The 7,000-word limit (L.R. 11-6.1) and the certificate (11-6.2) come from courtrules.net excerpts, which were reachable only through search; the page itself returns 403. **The current text of 11-3, 11-6.1 and 11-6.2 has not been confirmed against the court's own publication.** This is the first thing to check before the PR.
2. **Exemplar age.** The exemplar was filed on 2020-02-03, under a rule set that predates the current word limit. The exemplar's 25-page-style length and certificate are not evidence of the current form.
3. **Tables at the 24 pt pitch.** L.R. 11-3.6 requires double spacing "including citations and quotations"; since fb-595.68.22 the tables of contents and authorities are set at the numbered lines' pitch (they were single spaced).
4. **Cover height.** The party column is 2.7 inches wide so the title block and hearing details fit beside it on the cover.
5. **Footer page number.** The page number is drawn in the footer by the template, and typst's own default footer is disabled (`footer: none`); a first version drew the number twice.
6. **Word count.** `word_count: 1161` is `wc -w` over the markdown body (headings included, citations included). A filer's software count may differ. The count covers the sample, not the whole filing.
7. **Certificate wording.** The certificate sentence follows the summary of the suggested form on courtrules.net. Verify it against the official form before relying on it.
8. **Sample is partial.** The sample transcribes the notice's operative paragraphs, the introduction, the first part of the summary of facts, the standard of review, and the conclusion. It does not transcribe filed pages 6 to 14 (the rest of the facts and the argument), 15 to 20 (the argument), or the request for judicial notice, the declaration and the proposed order. The table of authorities is generated from the sample's citations, so it is not the filed table.
9. **Footnotes.** The sample has none, and neither engine styles them for L.R. 11-3.6.1 since the cross-engine port (fb-595.68.22); a sample with footnotes needs that added to both.
10. **Hearing details.** The exemplar's notice gives "Courtroom 7B" and "Honorable André Birotte Jr." on the cover; the template prints them as the sample supplies them. Current CACD practice may require a different form of the judicial officer's name; not checked.
11. **Italics.** The text layer of the exemplar carries no italic markup; the sample italicizes case names from the citation form.

## Engines

**docx** (`docx/reference.xml`, the cross-engine recipe `base="xengine"` in the typst face `{font}`, and `docx/cacd-motion-brief.lua`; fb-595.68.22: were `build-reference.sh`, `render.sh` and an EB Garamond `reference.docx`). Checked with LibreOffice only; Word was not available. `sh tools/render.sh --engine docx <dir> usage/INPUT-motion-brief.md` gives `OUTPUT-motion-brief.docx` and `.docx.pdf` (10 pages, all viewed).

- The same layout model as typst (`lib/docx/xengine.lua`): Times New Roman 14 pt, exact 24 pt and 16 pt line boxes. The line numbers 1 to 27 are a page-anchored frame in each section's footer; the footers (`$FORMBOOK_FOOTERS`) carry the page number, the paper's title and the case number (not on the cover); four sections: cover, notice (arabic from 1), tables (roman from i), memorandum and certificate (arabic from 1, `$FORMBOOK_FINAL`).
- The table of contents and table of authorities take their page numbers from fb render's passes (needles: each heading with its label and the words after it, each `toa:` link; was BLOCKED without page numbers).
- `sh tools/check.sh <dir> --engine docx`: 13 passed, 0 failed; XENG-001..003 pass (327/327 lines, 10 pages), `params.cross_engine: gate` in `eval.yaml`.
- Differs from typst: the pleading rules are page borders around the text area.

## FRCP base port assessment (fb-595.17.11)

Skipped: pleading paper. C.D. Cal. L.R. 11-3.2 requires a numbered left margin with at most 28 lines a page; the template sets the numbered lines and the pleading rules (`lib/typst/pleading-paper.typ`). The FRCP base (`lib/layouts/frcp-motion-brief.yaml`) has no pleading paper yet (fb-595.84 brings it), so the folder stays on its own templates.
