# D. Del. (ded): motion brief

Doc type: **motion brief**, the opening brief (memorandum of points and authorities) in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the District of Delaware (`ded`). Folder: `courts/third-circuit/delaware/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-abramson-safe-life-1-26-cv-00772-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-abramson-motion-brief.md`: the whole 13-page opening brief (cover, contents, table of citations, memorandum through the conclusion, signature block, footnotes 1 and 2) |
| render | ok: `samples/OUTPUT-abramson-motion-brief.pdf`, 12 pages (cover, contents i, citations ii to iii, body 1 to 8), typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh ...`) |
| overlay | ok: `samples/OVERLAY-abramson-motion-brief.pdf` and `OVERLAY-abramson-motion-brief.txt` (`sh tools/overlay.sh ...`) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and looked at in its final state) |
| tier 2 | not judged against two or three filers: one exemplar only (see Known gaps, 1) |
| typeface | face required: none. LR 5.1.1(a) and LR 7.1.3(a)(2) say "plainly typewritten or printed" and "at least 12 point"; no typeface is named (checked 2026-10-15 against the 2026 rules PDF). Substitute: none; EB Garamond stays (vendored, `fonts/FONTS.md`, "No face named"). Fit: not applicable. |

File names follow the repo's role convention and the tools' defaults (`INPUT-` for the markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), not the `<id>.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Primary source: D. Del. Local Rules of Civil Practice and Procedure, revised, effective September 1, 2026: https://www.ded.uscourts.gov/sites/ded/files/2026%20District%20of%20Delaware%20Revised%20Local%20Rules%20Effective%20September%201.pdf (PDF created 2026-08-04). Read and quoted 2026-10-14. The 2016 compilation (`https://www.ded.uscourts.gov/sites/ded/files/local-rules/District%20of%20Delaware%20LOCAL%20RULES%202016.pdf`) has the same 12-point, double-spacing and 1-inch rules; the 2026 text governs.

Federal rules: Fed. R. Civ. P. 12(b)(6) and 8(a) are cited by the brief, not reproduced by the template.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Del. LR 7.1.3(a)(1) | Front cover of each brief: the court's name, the caption, the civil action number, a description of the paper, the date of filing, the party for whom it is filed, and counsel's name, Delaware bar number, address and telephone. | `cover()`: court title; `caption-table` (caption and `C.A. No.`); the title; `OF COUNSEL:` (optional) and the counsel block; `Dated:`. |
| D. Del. LR 7.1.3(a)(2) and LR 5.1.1(a) | All briefs at least 12 point; double-spaced (not "exactly 24 point"); margins at least 1 inch; pages numbered consecutively; the date and a descriptive title; Delaware counsel's name, bar number, address, telephone and email under the signature line. | `margins` (1 in); `type-size` (13 pt) and `footer-size` (13 pt; the page number is printed matter); `line-pitch` and `body-leading`; footer page number on every page (roman i, ii on the front matter; arabic from 1 on the body); `signature-block` with the Delaware counsel block. |
| D. Del. LR 7.1.3(a)(4) | No opening or answering brief over 20 pages, exclusive of the contents and the citations. | Not enforced: the template does not count pages. The sample body is 8 pages. |
| D. Del. LR 7.1.3(a)(5) | Citations in the form of *A Uniform System of Citation*, with National Reporter citations. | Not checked: the author writes the citations. |
| D. Del. LR 7.1.3(b)(1)(A) | Table of contents, with page numbers, of every heading in the body. | `toc-section()` from the headings, with dot leaders and the page each heading starts on. |
| D. Del. LR 7.1.3(b)(1)(B) | Table of citations of cases, statutes, rules, textbooks and other authorities. | `toa-section()`: built from the `toa:KEY` links in the body and the `authorities:` registry in the frontmatter; page numbers come from the links' locations; "passim" at 7 or more pages. A link with no registry entry fails the build. |
| D. Del. LR 7.1.3(b)(1)(C)-(G) | Nature and stage of the proceedings; summary of argument (numbered); concise statement of facts; argument under headings; conclusion stating the precise relief. | Author content in the markdown. The template does not check the order or the content. The sample has no nature-and-stage or summary-of-argument section: the exemplar's brief does not have one either (it begins at "Defendant ... files this Motion"). See Known gaps, 4. |
| D. Del. LR 7.1.2(a) | Relief stated in the motion or in a supporting brief. | Not produced: the notice of motion and proposed order are separate filings. |

## Layout

- Letter paper; 1-inch margins; EB Garamond (vendored) at 13 pt; double spacing at about 2.08 em (27 pt at 13 pt); footnotes and the cover, caption, counsel and contents single-spaced.
- Cover: the court title on two centred lines; the caption with the parties in a column closed by a rule on the right and bottom, and `C.A. No.` on the right; the title centred in bold caps; `OF COUNSEL:` on the left and the filing firm's counsel block on the right; the date.
- Contents (roman i) and citations (roman ii, iii): the citation groups are Cases, Statutes, Rules and Other Authorities; each entry's page numbers are in a right-hand column.
- Body (arabic from 1): the memorandum. Level 1 headings unnumbered, centred, bold caps; level 2 `I.`, `II.` and level 3 `A.`, `B.` hang at the margin; paragraphs have a 0.5 in first-line indent; footnotes at the foot of the page.
- Signature block: `Dated:` on the left; the firm, `/s/` and the signing counsel on the right, then `Attorneys for ...`.

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
sh tools/render.sh courts/third-circuit/delaware/federal/district/motion-brief samples/INPUT-abramson-motion-brief.md
sh tools/overlay.sh courts/third-circuit/delaware/federal/district/motion-brief abramson-motion-brief
```

- `OVERLAY-abramson-motion-brief.pdf`: red = our render, blue = exemplar, black = both. The page map (`.txt`) pairs each of our pages with the exemplar page sharing the most words: ours p.1 and p.2 with filed p.1 and p.2 (90 percent each); ours p.3 with filed p.3 (54 percent: the citations page against the filed citations page); ours p.4 with filed p.5 (45 percent: our second citations page against the filed citations page); ours p.5 to p.12 with filed p.6 to p.13 (60 to 92 percent). The offset of one page after p.4 is real: the exemplar's front matter is five PDF pages (cover, contents, citations ii to iv) and ours is four (cover, contents, citations ii and iii). The overlay is a diagnostic, not a score.

## Review of the rendered pages (Gate 2 record, all 12 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption, title, counsel columns, date | OK. |
| 2 | Table of contents (roman i) | OK after the entry layout fix (a long entry wraps under its label; page numbers in the right column); heading text is the body text, not the labels typed in the markdown. |
| 3 | Table of citations, cases (roman ii) | OK after the layout fix (page numbers in a right column, so a wrapped entry does not strand them) and the comma fix (no doubled comma after case names); viewed again in its final state. |
| 4 | Table of citations, statutes, rules, other authorities (roman iii) | OK. |
| 5 | Body 1: opening sentence, FACTUAL ALLEGATIONS, start of ARGUMENT, footnote 1 | OK. Level 1 headings at body size after the heading-size fix. |
| 6 | Body 2: TCPA paragraph, level-2 heading I., footnote 2 | OK. |
| 7 | Body 3: direct-liability argument | OK. |
| 8 | Body 4: heading II., heading A., actual authority | OK. |
| 9 | Body 5: heading B. | OK. |
| 10 | Body 6: heading C., heading D. | OK. |
| 11 | Body 7: transfer argument, CONCLUSION | OK. |
| 12 | Signature block | OK after the fix that keeps the `/s/` line and the first counsel line in one stack (they overlapped). |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Checked and not saved (each has an available RECAP PDF with a text layer): Murdock v. Panini America, Inc., No. 1:26-cv-00849 (opening brief, 22 pages, filed 2026-07-14, RECAP `recap/gov.uscourts.ded.93857/gov.uscourts.ded.93857.14.0.pdf`); Eigen Systems Limited v. Messer Cutting Systems, Inc., No. 1:26-cv-00888 (partial motion, opening brief, 26 pages); CEA Industries, Inc. v. 10X Capital Partners LLC, No. 1:26-cv-00595 (opening brief, 26 pages). Tier 2 is therefore **not** judged against two filers yet.
2. **Assigned judge's standing order.** The rules set 12 point. A secondary source (a 2019 law-firm newsletter, found by web search, not the order itself) says Chief Judge Connolly's standing order asks for 14-point type in case-dispositive briefs and concise statements of fact, with word limits and a word-count certificate; a 2019 IP blog also reports that some D. Del. judges use word limits instead of page limits. The primary orders were not retrieved (the standing-orders page could not be opened from this box). The exemplar is before Judge Noreika (C.A. 26-772-MN). Before filing before a particular judge, check that judge's standing order; if it sets 14 pt, change `type-size` (and `footer-size`, if the order says "all printed matter").
3. **Double spacing.** LR 5.1.1(a) says double spacing "according to typical word processing software". The template uses about 2.08 em (27 pt at 13 pt), measured from the render; it was not compared with a word processor's "double" for EB Garamond. The exemplar's pitch (about 27.6 pt at 12 pt) is the reference.
4. **Sections not in the sample.** The exemplar brief has no nature-and-stage statement and no summary of argument (LR 7.1.3(b)(1)(C)-(D)); the template produces whatever headings the markdown has, so a brief that includes them needs them written into the markdown. The exemplar does not have them and the template does not add them.
5. **Font.** The rules name no typeface (LR 5.1.1(a), LR 7.1.3(a)(2)), so EB Garamond stays. Liberation Serif (Times metric) is vendored, but the exemplar's Times New Roman is the filer's choice, which the rule does not require, so it is not used. The rule's floor is 12 pt and is met at 13 pt.
6. **Pages and word counts.** The 20-page limit (LR 7.1.3(a)(4)) and any word count are not counted by the template; the sample body is 8 pages.
7. **Table of citations.** Page numbers are our render's, computed from the links, not the filed brief's. Only citations linked in the markdown appear, and the sample links every citation in the exemplar's text, including the short forms and the citations in footnote 1.
8. **Italics.** Case names and signals are italicised where the transcription recognised them; the exemplar's italic faces were not compared glyph by glyph.
9. **Separate filings** (the notice of motion, the proposed order, any certificate of service or word count) are not generated.
10. **Caption style.** The party block is closed by a rule on the right and bottom (N.D. Cal. style) rather than the exemplar's colon column (the exemplar uses a column of colons). Recorded as a convention choice.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx`, `docx/ded.lua`, `docx/build-reference.sh`, `docx/render.sh`): `sh docx/render.sh . samples/INPUT-abramson-motion-brief.md samples/OUTPUT-abramson-motion-brief.docx`, run from the court folder. `render.sh` runs pandoc (`--reference-doc=docx/reference.docx --lua-filter=docx/ded.lua`) and then points the section footers at the footer part pandoc writes. The reference carries the typst form: EB Garamond 13 pt, 27 pt exact line pitch, 1 in margins, 0.5 in first-line indent, single-spaced 13 pt footnotes and headings, centred 13 pt page number. The filter builds the cover (caption with the party column closed by a rule, title, `OF COUNSEL:` and counsel columns, date), the contents and the table of citations as their own sections (lower roman, no footer on the cover), the numbered headings (I., A.) and the signature block. Memorandum pages are Arabic from 1.
- Differences from typst: the contents and the table of citations list their entries without page numbers. A TOC field fills in its page numbers when Word or LibreOffice updates fields; pandoc cannot compute the table of citations' pages at all. Word and LibreOffice break lines differently from typst, so page breaks in the memorandum will not match the typst pages.
- Checked here: the `.docx` is a valid zip with well-formed XML parts (CRC read and `xmllint`). Not checked: opening in Word or LibreOffice (LibreOffice is not installed in the build box).
- docx BLOCKED: every gate check measured on the LibreOffice PDF (`samples/OUTPUT-abramson-motion-brief.docx.pdf`, Gates 0 to 3). No check IDs can be listed: this court folder has no `checks.yaml`. Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.
- docx BLOCKED on tier 1 content, not only on the PDF: the table of citations has no page numbers (LR 7.1.3(b)(1)(B)), and the contents has no page numbers until a field update (LR 7.1.3(b)(1)(A)). Reason: pandoc does not paginate and LibreOffice does not honor TA/TOA fields here, so the page numbers cannot be produced in this box.

[Formbook index](../../../../../README.md) | [Delaware federal index](../README.md)
