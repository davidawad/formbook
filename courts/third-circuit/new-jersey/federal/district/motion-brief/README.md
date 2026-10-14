# njd: motion-brief

Doc type: **motion-brief**, the memorandum of law in support of a motion (here a Rule 12(b)(6) motion to dismiss), in the United States District Court for the District of New Jersey (`njd`).
Folder: `courts/third-circuit/new-jersey/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-karre-2-26-cv-06421-motion-brief.pdf` (McGuireWoods LLP, primary, 22 pages) and `exemplars/FILED-EXAMPLE-zeines-2-25-cv-13335-motion-brief.pdf` (Freedman Normand Friedland LLP, 13 pages). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-karre-motion-to-dismiss.md`: the cover, the Introduction, Statement of Facts, Legal Standard, Point I, and the Conclusion with signature, transcribed from the Karre memorandum. Points II to IV are omitted and marked in the text. |
| render | ok: `samples/OUTPUT-karre-motion-to-dismiss.pdf`, 11 pages (cover, table of contents `i`, table of authorities `ii`-`iii`, body 1-7), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-karre-motion-to-dismiss.pdf` and `.txt` (against the Karre exemplar; see below) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow `tools/render.sh` and `tools/overlay.sh`: the sample is `INPUT-<id>.md`, with `<id>` = `karre-motion-to-dismiss`.

## Governing rules

Primary sources, fetched and read 2026-10-14 (D.N.J. Local Civil Rules, complete compilation, https://www.njd.uscourts.gov/sites/njd/files/CompleteLocalRules.pdf; Fed. R. Civ. P. text from https://www.law.cornell.edu/rules/frcp).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.Civ.R. 7.2(b) | Any brief includes a table of contents and a table of authorities; the text is limited to 40 ordinary typed pages (15 for a reply), excluding the contents pages. | `toc-section()` and `toa-section()`, built from the headings and from the `toa:` links in the body. The 40-page limit is not enforced by the template; the sample is 7 body pages. |
| L.Civ.R. 7.2(c) | 8.5 x 11 inch paper, black lettering, margins not less than one inch on the sides, top and bottom. | `paper: "us-letter"`; `margins` (1 inch on all sides). |
| L.Civ.R. 7.2(d) | Double-spaced text and/or single-spaced footnotes or inserts; 12 pt non-proportional (Courier New 12) or the equivalent 14 pt proportional font (Times New Roman 14); a 12 pt proportional font reduces the page limits by 25%; footnotes in the same size as the text. | `type-size = 14pt`; `pitch = 28.3pt` (measured in Karre: 28.3 pt); footnotes `set text(size: type-size)`; block quotations single-spaced, which Karre also does (measured: 16.1 pt pitch at 14 pt). |
| L.Civ.R. 7.1(d)(1) | The brief is a separate document, prepared under L.Civ.R. 7.2, filed at least 24 days before the noticed motion day. | Separate file in the court's ECF filing; the template produces one document. Timing is not a template matter. |
| L.Civ.R. 78.1(a) | Regular motion days are the first and third Monday of each month. | `motion_day` on the cover ("Motion Day: August 17, 2026", a third Monday; the Karre exemplar's "Motion Date"). |
| L.Civ.R. 10.1(a) | The first paper states the address of each named party. | Author content: the sample's counsel block gives counsel's address; the template does not check party addresses (see gap 2). |
| L.Civ.R. 10.1(b) | Papers bear the docket number and the name of the assigned judge; the first page endorses the name, office, address and telephone of the attorney of record; black lettering; 8.5 x 11. | `case_number` (Civil Action No.) and `judge` (blank in the sample: see gap 2); counsel block top-left (`counsel`). |
| L.Civ.R. 11.1 and ECF Policies ¶ 12(a) | Signature line with "s/" for an electronically filed document. | `signature-block()`: "/s/ <signer>". |
| Fed. R. Civ. P. 12(b)(6) (Cornell text) | The motion asserts failure to state a claim. | Content only; the sample cites the rule. |

## Layout

- Letter, 1-inch margins; EB Garamond 14 pt; double spacing at a 28.3 pt pitch; first-line indent 0.5 inch; headings: level 1 centered bold caps (INTRODUCTION, ARGUMENT, CONCLUSION), level 2 numbered "I." with a hanging indent and bold text, level 3 "A.", level 4 "1.".
- Cover (no page number): counsel block top-left, single spaced; court title centered bold caps; caption with the party column closed by a right and a bottom rule; the right column carries the `Civil Action No.`, the judge line when set, and `Motion Day:`; the bold caps title centered under the caption.
- Contents pages numbered in roman numerals (`i`, `ii`, ...); the body restarts at 1 (L.Civ.R. 7.2(b) does not prescribe the numbering; this is the usual practice in both exemplars).
- Table of contents: headings with dot leaders and page numbers, produced from the headings. Table of authorities: grouped Cases, Statutes, Rules, Regulations, Other Authorities; case names italic; an authority cited on seven pages or more reads "passim"; page numbers from the `toa:` link locations.
- Signature block: "Dated:" at left; "Respectfully submitted," "/s/" signer, signer, firm and the signer's lines at right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body: `#` heading (level 1), `##` (level 2, numbered by the template as I., II., ...), `###` (level 3, A., B., ...), paragraphs, block quotations (`>`, single spaced and indented), and inline italics (`*...*`).
- Authority links: `[*Case Name*](toa:key)`, one link per citation occurrence that should appear in the table of authorities; each key must have an entry under `authorities:` in the frontmatter (the template fails the build otherwise). Star pages (`at *6`) and the "E*TRADE" name use an escaped asterisk (`\*`).
- Frontmatter: `counsel` (lines), `court` (lines), `caption.parties` (`{names, designation}`), `case_number`, `judge` (`""` allowed), `motion_day`, `title`, `date`, `signature` (`signer`, `firm` lines, `lines`), `authorities` (`{kind: case|statute|rule|regulation|other, name?, cite}`).
- Not supported: tables, footnotes in the body (none used), raw typst.

## Gate 2: visual review of the render (every page, 60 dpi)

| Page | Review |
|---|---|
| 1 (cover) | Counsel top-left; court title centered bold; caption with party column and rule; `Civil Action No.` and `Motion Day:` on the right; title centered bold below the caption. No page number. Pass. |
| 2 (contents `i`) | TABLE OF CONTENTS; four top-level entries, the Point I entry, and CONCLUSION; page numbers right-aligned with dot leaders. Pass. |
| 3 (authorities `ii`) | TABLE OF AUTHORITIES; Cases list in alphabetical order, italic case names, page numbers. Pass. |
| 4 (authorities `iii`) | Remaining cases; Statutes and Rules groups, each entry with its page numbers. Pass. |
| 5 (body 1) | INTRODUCTION centered; double-spaced text with first-line indent; a paragraph with the em dash; citations and the Rule link. Pass. |
| 6 (body 2) | Paragraphs on the STATEMENT OF FACTS; "See id." italic signals; paragraph spacing unchanged. Pass. |
| 7 (body 3) | LEGAL STANDARD heading; quotations and "Id." italic; star pages as `*6`. Pass. |
| 8 (body 4) | ARGUMENT centered; "I." heading with hanging indent and bold text; Point I opening paragraphs. Pass. |
| 9 (body 5) | Paragraphs with Third Circuit and state citations; case names italic throughout. Pass. |
| 10 (body 6) | Block quotation single spaced and indented; citation line flush left after it; the omission marker in italics. Pass. |
| 11 (body 7) | CONCLUSION centered; signature block: dated line, "Respectfully submitted," "/s/" signer, firm and address. Pass. |

## Overlay (`tools/overlay.sh`)

- Against the Karre exemplar (the default, `exemplars/*.pdf | head -1`): our page 1 pairs with filed page 1 (word overlap 84.9%), our pages 2-4 with filed pages 2, 4, 5 (42.8%, 40.4%, 26.7%), our 5-10 with filed 7-13 (80.1%, 57.6%, 47.0%, 67.4%, 77.6%, 81.9%), and our page 11 with filed page 22 (63.6%). The map is by word overlap, so the offsets follow the exemplar's own pagination (its text is a 22-page memorandum; ours is a partial transcription of the same passages).
- Against the Zeines exemplar (third argument; run once, then overwritten by the Karre run): overlap 5% to 20%, expected for a different case; diagnostic only.
- Layout comparison with both exemplars was made by eye from the rasterized cover pages: Zeines puts counsel top-left, the bold court title centered, a caption closed by a right and bottom rule, and the bold title under the caption (matches this template). Karre puts counsel under the title on the cover; L.Civ.R. 10.1(b) allows either placement, and the template follows Zeines.

## Known gaps and open choices (for David)

1. **Font size and face (L.Civ.R. 7.2(d)).** The rule allows "12-point non-proportional font (such as Courier New 12) or an equivalent 14-point proportional font (such as Times New Roman 14)". The template uses EB Garamond at 14 pt, the only vendored family. EB Garamond at 14 pt looks smaller than Times New Roman at 14 pt, so whether it is "equivalent" is a reading question. The alternatives are: vendor a Times-metric font (removes the question); use 12 pt proportional, which the rule allows with the page limits cut by 25% (our sample is far below either limit); or keep EB Garamond 14 pt and accept the visual difference. Decision needed.
2. **Judge's name (L.Civ.R. 10.1(b)).** The rule says the paper bears "the name of the Judge assigned". Both exemplars print only the judge's initials, inside the case number (`WJM-CF`, `JXN-LDW`); neither prints the name on the cover. The template has a `judge` line for the full name; the sample leaves it blank because the name is not in the exemplar and was not invented. Whether initials suffice in practice, or the name is required, is a question for David.
3. **Party addresses (L.Civ.R. 10.1(a)).** This rule asks for each party's address in the first paragraph of an initial paper. A motion memorandum is not an initial paper, so the template does not require it; noted in case a reader takes the other view.
4. **Partial transcription.** The sample omits Points II to IV, the rest of Point I, and their citations. The bracketed marker in the body says so. The contents and authorities pages list only the entries in the transcription, not those of the filed memorandum.
5. **Block quotations.** Single spaced, as Karre sets them. L.Civ.R. 7.2(d) says "double-spaced text and/or single-spaced footnotes or inserts"; whether a block quotation is an "insert" is a reading question. Karre's practice supports the reading used here.
6. **Footnotes.** The footnote style is set (14 pt, single spaced, same size as the text) but no footnote is in the sample, so it is untested.
7. **Page limit.** The 40-page limit (L.Civ.R. 7.2(b)) is not checked by the template; the sample is far below it.
8. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none of them and the brief forbids editing `tools/`. The gates were not run; the render, the overlay and the review above are the evidence for this doc type.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
