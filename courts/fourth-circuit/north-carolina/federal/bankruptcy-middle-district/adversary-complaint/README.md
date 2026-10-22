# ncmb: adversary-complaint

Doc type: **adversary complaint** (a complaint commencing an adversary proceeding in the United States Bankruptcy Court for the Middle District of North Carolina, `ncmb`). Folder: `courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: caption, title, lead-in, every heading, all 41 numbered paragraphs, the three footnotes, the prayer A to F, the signature block (exhibits not transcribed) |
| typeface | face required: none. The 2022 local rules, the 2025 comment draft and the 2026 rules (`Local Rules 1.1.26.pdf`) name no typeface, point size or spacing (read 2026-10-14); FRBP 9004(a) requires only "clearly legible". The template is set in Times New Roman 12 pt, the house standard where no face is named (`docs/FONTS.md` rule 6; Liberation Serif as fallback), on typst and docx (fb-595.68.18). See gap 3. |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 8 pages, typst 0.15.0, `tools/render.sh` (zero typst warnings); `pdffonts`: Times New Roman Regular, Bold and Italic embedded |
| overlay | ok (re-run 2026-10-14): `usage/OVERLAY-novus-complaint.pdf` and `usage/OVERLAY-novus-complaint.txt`. The filed exemplar is not committed, so it is passed as the third argument (see Render and overlay) |
| pages reviewed | 8 of 8 on the earlier EB Garamond render, before fb-595.68 (2026-10-14: every page rendered at 80 dpi with `pdftoppm` and viewed) |

File names: the shared `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (and read `OUTPUT-<id>.pdf`), so those names are used rather than `<id>.pdf` and `<id>-overlay.pdf`. `tools/` was not edited.

## Governing rules

Primary sources, read 2026-10-14. Quoted or closely paraphrased; the rule text was read, not summarized from a search result.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NCMB-FORM-001 | Fed. R. Bankr. P. 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding, except that a pleading's caption must substantially conform to the appropriate version of Official Form 416. The caption used is Form 416D (caption for an adversary proceeding other than a complaint filed by a debtor): the trustee is the plaintiff. Form 416D itself was not fetched; the form identification is from a web search summary of the form titles. | caption (`caption` frontmatter, `cover()` and `caption()` in the template) |
| NCMB-FORM-002 | Fed. R. Bankr. P. 9004(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9004 | Papers must be "clearly legible" (9004(a)). A document presented for filing must have a caption with the court's name, the case title, the case number and adversary number, and a brief designation of the document (9004(b)). | `caption`, `title`, `court` frontmatter |
| NCMB-FORM-003 | Fed. R. Civ. P. 10(b), as applied by Fed. R. Bankr. P. 7010 | Each claim in a numbered paragraph, limited as far as practicable to a single set of circumstances. | `allegations()`: each text chunk is one numbered paragraph; headings, lists, quotations and the WHEREFORE lead-in are not numbered |
| NCMB-CONT-001 | Fed. R. Bankr. P. 7008(a), https://www.law.cornell.edu/rules/frbp/rule_7008 | The jurisdictional allegation must name the case the adversary proceeding relates to (name, number, Code chapter) and the district and division where it is pending. The complaint must state whether the pleader consents to the entry of final orders or judgment by the bankruptcy court. | author content (the sample states the jurisdiction in paragraphs 3 to 5). **Not checked by the template.** See gap 1. |
| NCMB-SIG-001 | Local Bankruptcy Rules (M.D.N.C.), LR 9011-4, https://www.ncmb.uscourts.gov/sites/default/files/local_rules/Local%20Bankruptcy%20Rules%20-%20NCMB%20%28October%207%2C%202022%29.pdf | Every paper filed by an attorney carries the attorney's state bar number in the signature block; telephone and email should also appear. | `signature` frontmatter, `signature-block()`: `bar` and `email` for each signer and `phone` are required (the build fails if one is missing) |
| NCMB-LR-001 | Local Bankruptcy Rules, LR 1001-1(c) and (d) | The court may modify the rules in the interest of justice; failure to comply may be sanctioned. | not a template rule |

Rule sources: the local bankruptcy rules text is the copy dated October 7, 2022 (the court's posted PDF). The court's site also lists a September 2025 comment draft, and a set of rules "Effective January 1, 2026", which was found as `Local Rules 1.1.26.pdf` on 2026-10-14 and read for the points above. **The 2026 text was not read in full; this README's LR 9011-4 and FRBP points rest on the 2022 text.** The 2025 draft's LR 7007-1 was read (it concerns motions and briefs, see the motion-brief README). The draft has no LR 9011-4 heading that could be found, so the signature rule could not be compared with it. The 2026 text (`Local Rules 1.1.26.pdf`, https://www.ncmb.uscourts.gov/sites/default/files/local_rules/Local%20Rules%201.1.26.pdf) was read for typeface and format terms on 2026-10-14: none found.

Not produced by this template (separate filings that may be required with the complaint): the adversary proceeding cover sheet (Official Form 1040); the summons; the civil cover sheet; the jury demand, if any (LR 9015-1, not read). The complaint has no certificate of service: service is by summons (Fed. R. Bankr. P. 7004).

## Layout

- US Letter, 1 inch margins, page number centered at the foot of every page (the exemplar's pages 1 to 10 are numbered the same way).
- Caption: court title centered (three lines, one per element); a party column, a ")" column in every row, and a case-number column. The ")" marks run the full height of the caption, as in the exemplar. The caption closes with a rule. The title (`COMPLAINT`) is centered and bold below the rule.
- Body: double spacing (line pitch 24.0 pt, measured with `pdftotext -bbox-layout` on page 2). Numbered paragraphs: number at a 0.5 inch indent, wrapped lines to the margin (as the exemplar). Headings: level 1 centered bold caps, level 2 centered bold, both kept with the paragraph after them (`sticky`).
- Lists: a markdown `1.` list is lettered A., B., ... (the prayer); a `-` list is a bulleted list with no marker, indented 1 inch (the (i), (ii), (iii) sub-items of a numbered paragraph).
- Footnotes: `[^n]` in a paragraph becomes a Typst footnote whose text is `footnotes.n` in the frontmatter.
- Signature block: "Respectfully submitted this ..." on the left, then the firm, `/s/`, each signer with bar number and email, the address, telephone and role, all in a column at 3.25 inches.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (lines), `caption.left` and `caption.right` (rows; a row is a string or `{t, a}` with `a` = `l`, `c` or `r`), `title`, `lead_in` (the unnumbered lead-in paragraph), `footnotes` (keys "1", "2", ...), `signature` (`dated`, `firm`, `signed_by`, `signers` (`name`, `bar`, `email`), `address`, `phone`, `role`).
- Body: blank-line-separated chunks. `#` = level 1 heading, `##` = level 2 heading; a paragraph is numbered; `1.` lists are lettered; `-` lists are unnumbered sub-items; a chunk beginning `WHEREFORE` is the unnumbered prayer lead-in; a chunk beginning `>` is a block quotation.
- Not supported: tables; sub-headings below level 2 are styled but not used by the sample.
- A hard line break inside a paragraph is written as a backslash at the end of the line (used nowhere now that the sub-items are a list).

## Known gaps and open choices

1. **FRBP 7008(a) consent statement is not checked.** The exemplar has no statement of consent to the entry of final orders or judgment by the bankruptcy judge, which Rule 7008(a) requires a complaint in an adversary proceeding to contain. The template cannot tell whether a sample has it, and the sample does not add it (the filed complaint is transcribed as filed). A complaint drafted from this template must state the consent itself. **This is the most important gap for a real filing.**
2. **One exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP, `court=ncmb`, adversary complaints) turned up two more adversary complaints with downloadable PDFs, both image-only (no text layer): Troxler v. Carvana (23-09001, Doc 1) and Battle/Troxler (26-02036, Doc 1). No OCR tool is installed on this box, so they were not used. Tier 2 is judged against one filer.
3. **Typeface and size.** No rule names a typeface (the 2022 text, the 2025 draft and the 2026 text were searched), and FRBP 9004(a) requires only that the paper be "clearly legible". So the template is Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6, David 2026-10-17; recorded as `template_face` in `data/exemplar-fonts.json`). The exemplar embeds Century Schoolbook (`pdffonts`; its point size was not measured); that is the filer's choice, not a rule. Before fb-595.68.18 the typst template was TeX Gyre Schola and the docx EB Garamond 13 pt (earlier still, EB Garamond 13 pt in typst too, on which the review and overlay below were made).
4. **Double spacing and margins.** No rule in the local rules sets line spacing or margins for this court; double spacing matches the exemplar and is a convention choice.
5. **Case names are italic in the sample.** The exemplar's text layer has no italic markup; italics are a convention choice in the transcription, not a reading of the filing.
6. **The exhibits are not transcribed.** Exhibit A (the First Agreement) and Exhibit B (the transfers table) are pages 11 to 34 of the filing. The sample stops at the signature block (page 10 of the filing).
7. **Paragraph numbers.** The template numbers paragraphs from 1 by chunk. The filed complaint also numbers from 1 and the sample reproduces all 41 numbered paragraphs, so the numbers coincide; the sample has no typed numbers.

## Gate 2 review (all 8 pages, rendered at 80 dpi and looked at, 2026-10-14, on the earlier EB Garamond render)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption with the ")" column, title, lead-in, heading "Parties, Jurisdiction and Venue", paragraph 1 | OK. Caption rows align; the title is bold and centered; page number 1 at the foot. |
| 2 | Paragraphs 2 to 11; headings "General Allegations", "First Agreement"; footnote 1 marker at paragraph 11 | OK. Headings at body size (an earlier build had headings at display size; fixed). |
| 3 | Paragraphs 12 to 16 (start); footnote 1 text at the foot; heading "Second Agreement" | OK. The heading moves with paragraph 16. |
| 4 | Paragraphs 16 (end) to 22 (start); headings "Insolvency", "First Claim for Relief" with its sub-heading | OK. The block quotation lead-in (paragraph 22) ends the page; the quotation starts page 5. |
| 5 | Block quotation; paragraph 23 with its (i), (ii), (iii) sub-items; paragraphs 24 and 25; footnote 2 text at the foot | OK. Sub-items indented 1 inch, as the exemplar. |
| 6 | Paragraphs 26 to 31, and the first line of 32; heading "Second Claim for Relief" with sub-heading; footnote 3 text at the foot | OK. |
| 7 | Paragraph 32 (end) to 39; heading "Third Claim for Relief" with sub-heading; the prayer lead-in and item A | OK. Item A wraps and hangs under its text. |
| 8 | Prayer items B to F; "Respectfully submitted this 5th day of December, 2024"; the signature block (firm, /s/, signer with bar number and email, address, telephone, role) | OK. |

Gate 2 rows: `OK` = viewed and acceptable. No `OPEN` rows. The one accepted difference from the filed exemplar was the typeface (gap 3).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/adversary-complaint novus-complaint <path-to>/SAMPLE-anderson-novus-24-06026-adversary-complaint.pdf
```

`usage/` holds `SOURCE.md` only: the filed PDF is not committed. Fetch it from the URL in `usage/SOURCE.md` into a directory outside the repo and pass it as the third argument, because `overlay.sh` otherwise takes the first PDF in `usage/`.

The overlay's page map (`usage/OVERLAY-novus-complaint.txt`, made on the earlier EB Garamond render) pairs each sample page with the filed page sharing the most words: sample 1 with filed 1 (96%), 2 with 2 (68%), 3 with 4 (56%), 4 with 5 (63%), 5 with 6 (69%), 6 with 7 (73%), 7 with 9 (50%), 8 with 10 (45%). The pairing is coarse: a sample page can pair with a filed page one or two pages away, because the sample does not carry the exhibits and the filed pages are longer in the front half. The overlay is a diagnostic, not a score: the filed exemplar uses a different face and line breaks, so the two layers will not coincide line by line.

## Engines

Typst (`typst/`) is the reference. The docx engine (`docx/`) is checked page by page against it, on the LibreOffice PDF of the `.docx`. `tools/check.sh` gates both engines on `eval.yaml` (`usage/.check-typst.txt`, `usage/.check-docx.txt`: PASS; typst 9 and docx 13 checks passed, fb-595.68.18); there are no BLOCKED docx items.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-adversary-complaint.typst.pdf` (8 pp) | reference |
| docx | `OUTPUT-adversary-complaint.docx` and `OUTPUT-adversary-complaint.docx.pdf` (8 pp) | ok: rendered with `tools/render.sh --engine docx`; the LibreOffice PDF converted without error; XENG-001..003 pass (fb-595.68.18); the by-eye review below was on the earlier 9-page EB Garamond docx |

```sh
sh tools/render.sh --engine docx courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/adversary-complaint usage/INPUT-adversary-complaint.md
```

**docx** (`docx/reference.xml`, `docx/ncmb-adversary-complaint.lua`; `docx/make-reference.sh` and `docx/reference.docx` were retired into fb render in fb-595.68.18). `fb render --engine docx` builds the reference document from `reference.xml` on the shared cross-engine recipe in the typst face: Times New Roman 12 pt; body at an exact 24 pt line pitch with a 0.5 in first-line indent; headings; footnote and block-quote styles; letter page with 1-inch margins; a centered page number on every page. The Lua filter builds what pandoc does not write: the cover (court lines, a caption table with the ")" column and closing rule, the title), the numbered paragraphs, the lettered prayer, the sub-items, native footnotes whose text is in the frontmatter, and the signature block kept together at 3.25 in.

- *Matches typst* (seen on the earlier EB Garamond docx; both engines are now Times New Roman 12 pt, 8 pages): typeface and size; line pitch (24.0 pt in both PDFs, measured on page 7); the caption; heading levels (centered capitals, centered bold); the unnumbered WHEREFORE paragraph; the (i), (ii), (iii) sub-items; the prayer A. to F.; footnote size; the signature block; page numbers.
- *Differs* (on that earlier docx; not re-checked here): line and page breaks. The docx was 9 pages against 8. The signature block, with "Respectfully submitted", fell alone on docx page 9; typst kept it on page 8 under the prayer. Word may break lines differently again. Word counts agree within 5 words (2,296 against 2,291).
- *Not built:* no certificate, because the complaint has none (the sample has no service frontmatter).
- *Word:* not opened in Word. `unzip -t` and xmllint pass on every XML part and every style used in the body is defined; LibreOffice converted it without error.
- *Pages reviewed:* 9 of 9 pages of the earlier EB Garamond `OUTPUT-adversary-complaint.docx.pdf`, each viewed beside typst page 1 to 8 (page 9 has no typst counterpart).


See also: [[motion-brief]] (the other doc type in this court), `../../../../../../README.md` for the formbook index.
