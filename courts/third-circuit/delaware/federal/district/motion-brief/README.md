# D. Del. (ded): motion brief

Doc type: **motion brief**, the opening brief (memorandum of points and authorities) in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the District of Delaware (`ded`). Folder: `courts/third-circuit/delaware/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole 13-page opening brief (cover, contents, table of citations, memorandum through the conclusion, signature block, footnotes 1 and 2) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `OUTPUT-motion-brief.docx` / `.docx.pdf`, 12 pages each (cover, contents i, citations ii to iii, body 1 to 8), Times New Roman 12 pt, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | ok: `usage/OVERLAY-abramson-motion-brief.pdf` and `OVERLAY-abramson-motion-brief.txt` (`sh tools/overlay.sh ...`) |
| pages reviewed | 12 of 12 on each engine (rendered at 45 dpi and looked at side by side after the last template change, 2026-10-22) |
| tier 2 | not judged against two or three filers: one exemplar only (see Known gaps, 1) |
| typeface | face required: none. LR 5.1.1(a) and LR 7.1.3(a)(2) say "plainly typewritten or printed" and "at least 12 point"; no typeface is named (checked 2026-10-15 against the 2026 rules PDF). Substitute: Times New Roman, the house face (vendored, `docs/FONTS.md`, "No face named"; the exemplar is Times New Roman too); the docx names the typst face (`{font}`). It was EB Garamond 13 pt until fb-595.68.34. Fit: not applicable. |

File names follow the repo's role convention and the tools' defaults (`INPUT-` for the markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), not the `<id>.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Primary source: D. Del. Local Rules of Civil Practice and Procedure, revised, effective September 1, 2026: https://www.ded.uscourts.gov/sites/ded/files/2026%20District%20of%20Delaware%20Revised%20Local%20Rules%20Effective%20September%201.pdf (PDF created 2026-08-04). Read and quoted 2026-10-14. The 2016 compilation (`https://www.ded.uscourts.gov/sites/ded/files/local-rules/District%20of%20Delaware%20LOCAL%20RULES%202016.pdf`) has the same 12-point, double-spacing and 1-inch rules; the 2026 text governs.

Federal rules: Fed. R. Civ. P. 12(b)(6) and 8(a) are cited by the brief, not reproduced by the template.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Del. LR 7.1.3(a)(1) | Front cover of each brief: the court's name, the caption, the civil action number, a description of the paper, the date of filing, the party for whom it is filed, and counsel's name, Delaware bar number, address and telephone. | `cover()`: court title; `caption-table` (caption and `C.A. No.`); the title; `OF COUNSEL:` (optional) and the counsel block; `Dated:`. |
| D. Del. LR 7.1.3(a)(2) and LR 5.1.1(a) | All briefs at least 12 point; double-spaced (not "exactly 24 point"); margins at least 1 inch; pages numbered consecutively; the date and a descriptive title; Delaware counsel's name, bar number, address, telephone and email under the signature line. | `margin` (1 in); `type-size` (12 pt, the footnotes and the page number too: printed matter); `pitch-body` (27.6 pt); footer page number on every page (roman i, ii on the front matter; arabic from 1 on the body); `signature-block` with the Delaware counsel block. |
| D. Del. LR 7.1.3(a)(4) | No opening or answering brief over 20 pages, exclusive of the contents and the citations. | Not enforced: the template does not count pages. The sample body is 8 pages. |
| D. Del. LR 7.1.3(a)(5) | Citations in the form of *A Uniform System of Citation*, with National Reporter citations. | Not checked: the author writes the citations. |
| D. Del. LR 7.1.3(b)(1)(A) | Table of contents, with page numbers, of every heading in the body. | `toc-section()` from the headings, with dot leaders and the page each heading is on (docx: the same pages, from fb render's passes). |
| D. Del. LR 7.1.3(b)(1)(B) | Table of citations of cases, statutes, rules, textbooks and other authorities. | `toa-section()`: built from the `toa:KEY` links in the body and the `authorities:` registry in the frontmatter; page numbers come from the pages the links start on (docx: the same, from fb render's passes); "passim" at 7 or more pages. A link with no registry entry fails the build. |
| D. Del. LR 7.1.3(b)(1)(C)-(G) | Nature and stage of the proceedings; summary of argument (numbered); concise statement of facts; argument under headings; conclusion stating the precise relief. | Author content in the markdown. The template does not check the order or the content. The sample has no nature-and-stage or summary-of-argument section: the exemplar's brief does not have one either (it begins at "Defendant ... files this Motion"). See Known gaps, 4. |
| D. Del. LR 7.1.2(a) | Relief stated in the motion or in a supporting brief. | Not produced: the notice of motion and proposed order are separate filings. |

## Layout

- Letter paper; 1-inch margins; Times New Roman (vendored) at 12 pt; double spacing on a 27.6 pt pitch (2 x 1.15 x 12 pt, LR 5.1.1(a) "typical word processing software"; the exemplar's pitch); the cover, headings that wrap, contents, citations, signature and footnotes on a 13.8 pt pitch. Cross-engine layout model (`lib/typst/xengine.typ`): first fit, ragged right, no hyphenation; explicit block spaces.
- Cover (no page number): the court title on two centred lines; the caption with the parties in a column ruled at its right and foot, and `C.A. No.` on the right; the title centred in bold caps; `OF COUNSEL:` on the left and the filing firm's counsel block on the right; the date.
- Contents (roman i) and citations (roman ii, iii): single-spaced rows a single line apart (citations half a line), the page in a column at the right (0.5 in, citations 1 in) with a dot leader to it; the citation groups are Cases, Statutes, Rules and Other Authorities; a citation's page is the page it starts on.
- Body (arabic from 1): the memorandum. Level 1 headings unnumbered, centred, bold caps on the body pitch; level 2 `I.`, `II.` at the margin and level 3 `A.`, `B.` half an inch in, bold single lines a single line above and below, the title hanging after a 0.5 in label box; paragraphs have a 0.5 in first-line indent; footnotes at the foot of the page, 12 pt single spaced, 7 pt below each.
- Signature block: single lines in a column from 3.2 in, `Dated:` left of its first line; the firm, `/s/` and the signing counsel, then `Attorneys for ...`; kept whole and with the last paragraph.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`; `caption` (list of `{names, designation}`); `brief_title`; `of_counsel` (optional lines for the cover's left column; `OF COUNSEL:` is printed above them); `counsel` (lines for the cover's right column); `date`; `signature` (`firm` lines, `signer`, `lines`); `authorities` (see below).
- `authorities` registry: each key is a link target. Each entry has `kind` (`case`, `statute`, `rule` or `other`), `cite` (the printed citation) and, for cases, `name` (the case name, printed in italics, with its trailing comma).
- Citations in the body: `[text](toa:KEY)`, where the text is the citation as it appears in the brief (including italics). Every authority the brief cites needs a link so that it appears in the table and its page is counted.
- Headings: `#` level 1 (unnumbered; centred caps), `##` level 2 (`I.`), `###` level 3 (`A.`). The sample types no numbers: the template numbers the headings.
- Footnotes: `[^name]` in the text, `[^name]: text` in the body.
- No forced line breaks; no case-specific text in the template; no coordinates measured off the exemplar.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/delaware/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/third-circuit/delaware/federal/district/motion-brief abramson-motion-brief
```

- `OVERLAY-abramson-motion-brief.pdf`: red = our render, blue = exemplar, black = both. The page map (`.txt`) pairs each of our pages with the exemplar page sharing the most words: ours p.1 and p.2 with filed p.1 and p.2 (90 percent each); ours p.3 with filed p.3 (54 percent: the citations page against the filed citations page); ours p.4 with filed p.5 (45 percent: our second citations page against the filed citations page); ours p.5 to p.12 with filed p.6 to p.13 (60 to 92 percent). The offset of one page after p.4 is real: the exemplar's front matter is five PDF pages (cover, contents, citations ii to iv) and ours is four (cover, contents, citations ii and iii). The overlay is a diagnostic, not a score; it predates the move to Times New Roman and the 27.6 pt pitch (fb-595.68.34) and was not re-run.

## Review of the rendered pages (Gate 2 record, all 12 pages on each engine, rendered at 45 dpi and looked at side by side, 2026-10-22)

Every page of the typst and docx renders carries the same lines (XENG-003, 275/275), and the contents and the citations print the same pages in both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption (ruled at the right and foot), title, counsel columns, date; no page number | OK. |
| 2 | Table of contents (i) | OK: labels at the margin and half an inch in, wrapped titles under the title, pages in the right column. |
| 3 | Table of citations, cases (ii) | OK: a wrapped citation hangs 0.35 in; the pages on its last line. |
| 4 | Cases (end), statutes, rules, other authorities (iii) | OK. |
| 5 | Body 1: opening paragraph, FACTUAL ALLEGATIONS, ARGUMENT, footnote 1 | OK: the seven-line footnote under a short rule. |
| 6 | Body 2: heading I., footnote 2 | OK. |
| 7 | Body 3: direct-liability argument | ACCEPTED (tier 2): the page ends three lines short; the next paragraph moves whole in both engines. |
| 8 | Body 4: heading II. | ACCEPTED (tier 2): heading A. moves to the next page with its paragraph, leaving the foot of the page empty. |
| 9 | Body 5: headings A. and B. | OK. |
| 10 | Body 6: headings C. and D. | OK. |
| 11 | Body 7: transfer argument | OK. |
| 12 | Body 8: CONCLUSION and the signature block | OK: the last paragraph kept with the block. |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Checked and not saved (each has an available RECAP PDF with a text layer): Murdock v. Panini America, Inc., No. 1:26-cv-00849 (opening brief, 22 pages, filed 2026-07-14, RECAP `recap/gov.uscourts.ded.93857/gov.uscourts.ded.93857.14.0.pdf`); Eigen Systems Limited v. Messer Cutting Systems, Inc., No. 1:26-cv-00888 (partial motion, opening brief, 26 pages); CEA Industries, Inc. v. 10X Capital Partners LLC, No. 1:26-cv-00595 (opening brief, 26 pages). Tier 2 is therefore **not** judged against two filers yet.
2. **Assigned judge's standing order.** The rules set 12 point. A secondary source (a 2019 law-firm newsletter, found by web search, not the order itself) says Chief Judge Connolly's standing order asks for 14-point type in case-dispositive briefs and concise statements of fact, with word limits and a word-count certificate; a 2019 IP blog also reports that some D. Del. judges use word limits instead of page limits. The primary orders were not retrieved (the standing-orders page could not be opened from this box). The exemplar is before Judge Noreika (C.A. 26-772-MN). Before filing before a particular judge, check that judge's standing order; if it sets 14 pt, change `type-size` (and `footer-size`, if the order says "all printed matter").
3. **Double spacing.** LR 5.1.1(a) says double spacing "according to typical word processing software". The template uses 27.6 pt (2 x 1.15 x 12 pt), the exemplar's pitch, in exact line boxes in both engines.
4. **Sections not in the sample.** The exemplar brief has no nature-and-stage statement and no summary of argument (LR 7.1.3(b)(1)(C)-(D)); the template produces whatever headings the markdown has, so a brief that includes them needs them written into the markdown. The exemplar does not have them and the template does not add them.
5. **Font.** The rules name no typeface (LR 5.1.1(a), LR 7.1.3(a)(2)), so the house face applies: Times New Roman 12 pt, the exemplar's face too, at the rule's floor (it was EB Garamond 13 pt until fb-595.68.34).
6. **Pages and word counts.** The 20-page limit (LR 7.1.3(a)(4)) and any word count are not counted by the template; the sample body is 8 pages.
7. **Table of citations.** Page numbers are our render's, computed from the links, not the filed brief's. Only citations linked in the markdown appear, and the sample links every citation in the exemplar's text, including the short forms and the citations in footnote 1.
8. **Italics.** Case names and signals are italicised where the transcription recognised them; the exemplar's italic faces were not compared glyph by glyph.
9. **Separate filings** (the notice of motion, the proposed order, any certificate of service or word count) are not generated.
10. **Caption style.** The party column is ruled at its right and foot rather than the exemplar's column of colons. Recorded as a convention choice (tier 3).

## Engines

Engine status: typst `OUTPUT-motion-brief.typst.pdf`; docx `OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice), 12 pages each, every line and page as typst (XENG-001..003 gated, `eval.yaml`); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ` (`footnote-widows: false`: a footnote's line moves on with the line before it, as Word does); the contents and the citations as `listing-row` rows.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 27.6 pt lines with a 0.5 in first-line indent; single lines and footnotes in 13.8 pt boxes, 7 pt after a footnote; "Body Text Keep" for the last paragraph) and `docx/ded-motion-brief.lua` (on `lib/docx/xengine.lua`): the cover, the contents and the citations, the headings, the signature block, the footers (none on the cover; a centred PAGE field) and the three sections (cover; lower roman from i; arabic from 1). The pages of the contents and the citations come from `fb render`'s passes: a needle per heading (its label, text and the words after it) and per `toa:` link (in a footnote, an `N` needle), and `#section` lines at the contents' title and the first paragraph. A contents or citation row's right indent is 3 pt less than typst's page column: LibreOffice keeps a space more than typst before a leader tab past the right indent (a citation typst fits within 1.4 pt of its column wrapped). No shell: `fb render` builds the reference document, runs the passes and packs the archive (were `docx/build-reference.sh`, `docx/render.sh` and a committed `reference.docx` in EB Garamond 13 pt, and a contents and citations without page numbers). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none (the contents and the citations carry their page numbers, LR 7.1.3(b)(1)(A)-(B)).

[Formbook index](../../../../../README.md) | [Delaware federal index](../README.md)
