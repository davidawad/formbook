# cod: complaint

Doc type: **complaint** in the United States District Court for the District of Colorado (`cod`).
Folder: `courts/tenth-circuit/colorado/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer: Walton v. Protecto Wrap Co.; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a transcription of part of the 16-page filing; see Known gaps) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 10 pages, vendored Times New Roman only, no warnings, on the shared cross-engine layout model (fb-595.68.32) |
| overlay | ok: `usage/OVERLAY-walton-complaint.pdf` and `usage/OVERLAY-walton-complaint.txt` |
| pages reviewed | 10 of 10 on typst and docx (every page of both renders viewed side by side at 50 dpi after the last template change, 2026-10-22) |

File names: the sample is `INPUT-<id>.md`, the render is `OUTPUT-<id>.pdf` and the overlay is `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default. The brief's `<id>.md` / `<id>-overlay.pdf` form was not used for this reason.

Commands (from the repo root, with `PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/tenth-circuit/colorado/federal/district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/tenth-circuit/colorado/federal/district/complaint walton-complaint
```

## Governing rules

Primary source: **D.C.COLO.LCivR** (Local Rules of Practice, Civil, effective December 1, 2025), fetched 2026-10-14 from the court's own PDF, https://www.cod.uscourts.gov/Portals/0/Documents/LocalRules/2025_Final_Local_Rules.pdf (linked from https://www.cod.uscourts.gov/CourtOperations/RulesProcedures/LocalRules.aspx). Rule text was read from that PDF's text layer.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.C.COLO.LCivR 10.1(b) | 8½ × 11 inch white paper. | `page-w`, `page-h`. |
| D.C.COLO.LCivR 10.1(c) | Margins 1½ inches at the top, 1 inch at the left, right and bottom. | `margin-top`, `margin-side`, `margin-bottom`. |
| D.C.COLO.LCivR 10.1(d) | Black ink, not less than 12-point font, unless otherwise ordered. | `type-size = 12pt` everywhere, including the page number. |
| Typeface (no face named) | No typeface named in LCivR 10.1; the only face named in the local rules is in D.C.COLO.LPtR 17 (patent cases, briefs only), which does not apply to a complaint. The template sets Times New Roman (vendored), the house standard and the exemplar's face, on typst and docx alike (fb-595.68.32). | `font-family = ("Times New Roman", "Liberation Serif")`; the docx names it through `{font}` |
| D.C.COLO.LCivR 10.1(e) | All pleadings double spaced. | `pitch-double = 24pt`: every body line a 24 pt box (2 x 12 pt), the cross-engine layout model (`lib/typst/xengine.typ`); caption, headings, quotations and signature in 13.8 pt single lines. |
| D.C.COLO.LCivR 10.1(f) | One side of the page only. | Single-sided PDF. |
| D.C.COLO.LCivR 10.1(g) | Legibility. | Typeset text only; no handwriting. |
| D.C.COLO.LCivR 5.1(a) | Format, sign and file electronically in CM/ECF. | The output is one PDF of the pleading; the signature block follows the exemplar's `/s/` form. |
| D.C.COLO.LCivR 3.1(a) | A Civil Cover Sheet is filed at commencement. | **Not produced** (a separate filing; see Known gaps). |
| D.C.COLO.LCivR 3.2(a), (c) | Notice of related cases at the first pleading. | **Not produced** (a separate filing). |
| Fed. R. Civ. P. 10(a) | Caption: court name, title, file number, Rule 7(a) designation; the complaint's title names all parties. | `caption()`: court lines, `Civil Action No.`, parties from `caption`, title from `title`. Text checked against https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | Body paragraphs are numbered by the template (`allegations()`); headings, lists, quotations and `~ ` paragraphs are not. |
| Fed. R. Civ. P. 8(a)(2), 8(d)(1) | A short and plain statement of the claim; allegations simple, concise and direct. | Content (author's). The template does not check wording. Text checked against https://www.law.cornell.edu/rules/frcp/rule_8 on 2026-10-14. |
| Fed. R. Civ. P. 11(a) | Signature by an attorney of record with address, telephone and email. | `signature()`: `s/` line, name, firm and contact lines. |

Not in the local rules and therefore not asserted: a page limit (none for complaints), a line-numbered pleading paper (D.C.COLO.LCivR 10.1 does not require it, so the template does not draw line numbers, unlike the N.D. Cal. complaint), and a typeface (10.1(d) asks only for 12-point or larger).

## Layout

- Letter size. Top margin 1½ inches; left, right and bottom 1 inch; centered page number in the bottom margin, in a single-spaced line.
- Court name in two centered bold lines; a double line below, `Civil Action No.` (a blank to fill in when there is no case number); a double line below, the party block (names, a blank line, the designation indented 0.5 inch, `v.` between sides with a blank line on each side); a double line below, the title centered in bold. All single lines (13.8 pt), never split.
- Body double spaced (24 pt lines), first-line indent 0.5 inch, the paragraph number in a half-inch box after it. Headings: level 1 centered bold capitals, level 2 centered bold, level 3 bold italic at the left; single-spaced, a single line above and below, kept with the next paragraph (sticky). Block quotations single spaced, 1 inch in on each side, a single line above, below and between their paragraphs.
- Prayer items (markdown numbered list) are lettered A., B., ... by item number, the label half an inch in, in a 0.5 inch box, the text hanging after it. The last block of the body is kept with the signature block.
- Signature block single spaced, a double line after the last paragraph: the intro lines (`DATE`, `Respectfully submitted,`) at the margin; a blank line and the firm; a blank line, the `By: /s/` line, the signer's name and the contact lines; a blank line and `Attorneys for ...`; the firm, signer and role lines 3 inches from the margin. Kept on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks.
- Frontmatter: `case_number` (string; blank line printed when absent), `caption` (list of `{names: [...], designation}`; "v." is inserted between sides), `title`, `lead_in` (optional unnumbered opening paragraph), `signature` (`intro`: list of lines; `firm` optional; `signers`: list of `{name, lines, sig_line}`; `role`). `sig_line` defaults to `s/ <name>`.
- Body chunks: `# Heading` (level 1), `## Heading` (level 2), `### Heading` (level 3); a numbered paragraph (any chunk not in the list below) is numbered by the template; `~ ` at the start of a chunk makes an unnumbered paragraph (used for the opening of the prayer, the jury demand and a preliminary statement); `>` starts a block quotation (single spaced, indented 1 inch each side; `>` blank lines separate its paragraphs); a list (`1.` or `-`) is a list, with `1.` lettered A., B., ... by number; a list is one chunk.
- Not supported: footnotes, tables, raw typst, headings deeper than level 3.
- Escape markdown markers at the start of a paragraph (for example `2\. ` when the text starts with a number), as in any markdown. Asterisks inside citations must be escaped (`at \*4`).

## Known gaps and open choices

1. **One filer, not two or three.** EVAL-LOOP's tier-2 rule asks for exemplars from 2 or 3 different filers. Searches on CourtListener (RECAP, `court=cod`) found these other federal complaints, not saved: Peterson v. Christian Community Foundation, Inc., 1:26-cv-00179-RMR-MDB (23 pp; no counsel block on page 1 in the check made here); Dolmas v. Vitalant, Inc., 1:26-cv-01197-LTB-RTG (29 pp; no counsel block on page 1); Preferred Choice Products, LLC v. All American Sales, LLC, 1:26-cv-05134 (25 pp, counsel-signed, filed 10/09/26), which is a 65 MB PDF and was not saved (the repo's exemplars are small public records). The state-court complaints attached to removals (Engvall, Peters) are not federal complaints and were not used. Tier 2 is therefore **not** judged against 2 or 3 filers yet.
2. **Font (resolved).** The rules set no typeface. The template sets Times New Roman 12 pt, the house standard (David, 2026-10-17) and the exemplar's body face, on typst and docx.
3. **Sample is a transcription of part of the filing**, not the whole 16 pages. Included: caption, lead-in, preliminary statement, parties, jurisdiction, administrative remedies, factual allegations (paragraphs 16–30 and 32–49 of the filing), first claim (paragraphs 49–51 of the sample), third claim, fourth claim (with the § 1981 block quotation), prayer, jury demand, signature. Omitted: paragraph 31 (it quotes a racial slur, and the sample leaves that text out), the second claim, paragraph 53 onward within the first claim, the fifth claim (its paragraph 103 quotes the same slur), and the sixth claim. Because the template numbers paragraphs, the sample's paragraph numbers and the filed numbers diverge after the omitted paragraphs, so overlay pairs of later pages share fewer words.
4. **The overlay is a diagnostic, not a score.** Page pairs from the overlay map (`usage/OVERLAY-walton-complaint.txt`): ours p.1–p.2 pair with filed p.1–p.2 at 93–95% word overlap; ours p.3 with p.3 at 78%; the remaining pairs are lower because of the omissions in item 3 and because the filed pages hold different paragraphs. Read the overlay for layout (margins, caption, headings, signature), not for text.
5. **Caption.** The party block is plain lines, with no column of ")" marks or rules, matching the filed Walton caption. This is a convention choice, not a rule point.
6. **Not produced.** Civil Cover Sheet (D.C.COLO.LCivR 3.1(a)), Notice of Related Cases (3.2), summons and the Rule 7.1 disclosure statement are separate filings and are not part of this template.
7. **Judge practice standards.** Individual judges' practice standards (for example, on fonts or a complaint's length) were not checked and are not asserted.
8. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines. There is no `check-selftest.sh` run: the doc-type folder has no `court.json`.
9. **Signer name.** The exemplar's `By: /s/ Name` line is kept as `sig_line`; the signer's name then appears again under it, as in the filing.

## Review of the rendered pages (made on the earlier 10-page EB Garamond render; the 10 pages of the current typst and docx renders were viewed side by side on 2026-10-22, no defect found: the same text falls on each page, the prayer items A.-E. end page 9, and page 10 carries item F., the jury demand and the signature block)

- Page 1: court name, civil action line, party block, title, lead-in and the preliminary statement; the PARTIES heading moves to page 2 with its paragraph (no heading left at the foot). Footer page number. No spill. Pass.
- Page 2: PARTIES heading and paragraphs 1–5; JURISDICTION AND VENUE heading and paragraphs 6–10. Pass.
- Page 3: ADMINISTRATIVE REMEDIES EXHAUSTED heading and paragraphs 11–15; FACTUAL ALLEGATIONS heading and paragraphs 16–21 (21 continues on page 4). Pass.
- Page 4: paragraphs 21 (end) to 32; numbered paragraphs at 0.5 inch indent, double spaced. Pass.
- Page 5: paragraphs 33–46. Pass.
- Page 6: paragraphs 47–48; FIRST CLAIM FOR RELIEF heading and title (bold, centered); paragraphs 49–51; THIRD CLAIM heading and paragraphs 52–56. Pass.
- Page 7: paragraphs 57–62; FOURTH CLAIM heading and its title; paragraphs 63–64 (the citation's asterisk printed as `*4`). Pass.
- Page 8: paragraphs 65–72; the § 1981 block quotation single spaced, indented 1 inch each side. Pass.
- Page 9: paragraphs 73–75; PRAYER FOR RELIEF heading, the WHEREFORE paragraph (unnumbered), items A.–F., JURY TRIAL DEMAND heading and its unnumbered paragraph. Pass.
- Page 10: signature block (DATE and Respectfully submitted, firm, the `By: /s/` line, contacts, Attorneys for). The block is kept together and sits alone on the last page; it is not separated from the prayer. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

**docx** (`docx/`: `reference.xml`, the cross-engine recipe (`base="xengine"`) at the typst pitches in twips, a 1½ inch top margin; `cod-complaint.lua` writes every paragraph with the typst spacing, on `lib/docx/xengine.lua`). `fb render --engine docx` (via `tools/check.sh --engine docx`) writes `OUTPUT-complaint.docx` and `OUTPUT-complaint.docx.pdf` (LibreOffice; `pdffonts`: Times New Roman only, embedded).

- Gate 4: XENG-001..003 PASS (10 pages; 239/239 typst lines break after the same word), `params.cross_engine: gate` in `eval.yaml`. typst: `RESULT: 9 checks passed, 0 failed`; docx: `RESULT: 13 checks passed, 0 failed` (DEF-TOC-001 and DEF-COVER-001 pass on both).
- Differs: the page number sits 0.76 pt lower in the docx (the footer line); nothing else measured.
- BLOCKED: none.
