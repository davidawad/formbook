# tneb: adversary complaint

Doc type: **adversary-complaint** (a complaint commencing an adversary proceeding) in the United States Bankruptcy Court for the Eastern District of Tennessee (`tneb`).
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the whole filing (8 pages), transcribed from the text layer |
| typeface | face required: none (E.D. Tenn. LBR 9004-1(a) names no typeface; checked against the full local rules PDF, 2026-10-15). Font: Times New Roman (vendored, `fonts/`), the face of the filed complaint, in both engines (was EB Garamond until 2026-10-22). |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `.docx.pdf`, 7 pages each, typst 0.15.0 and LibreOffice, pdffonts shows Times New Roman only (2026-10-22) |
| overlay | ok: `usage/OVERLAY-hood-complaint.pdf` and `usage/OVERLAY-hood-complaint.txt` (regenerated 2026-10-15) |
| pages reviewed | 7 of 7 on each engine (every page of the typst and docx renders at 60 dpi, side by side, 2026-10-22) |

Tools: `sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/adversary-complaint usage/INPUT-adversary-complaint.md`, then `sh tools/overlay.sh <same dir> hood-complaint`. Output names follow the repo's file roles (`OUTPUT-`, `OVERLAY-`), not the `<id>-overlay.pdf` names in the brief, because `tools/render.sh` and `tools/overlay.sh` write those names by default.

## Governing rules

Primary sources. The E.D. Tenn. local rules were read from the court's PDF on 2026-10-14. The FRBP text was obtained by fetching Cornell LII on 2026-10-14 (a summarizing fetch, see Known gaps 5); FRBP 7001 was not fetched.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 7001 | The adversary proceeding categories, including 7001(6) (a proceeding to determine the dischargeability of a debt). Not fetched in this pass: the exemplar cites it, and the template's scope rests on the exemplar's citation. Verify against the official text. | Scope of the template only. |
| FRBP 7003; E.D. Tenn. LBR 7003-1 | "An Adversary Proceeding Cover Sheet, Bankruptcy Form B 1040, must be completed and filed with each complaint that is not filed electronically." Source: E.D. Tenn. Local Rules, https://www.tneb.uscourts.gov/sites/tneb/files/local_rules/TNEB_Local_Rules.pdf (Local Rules effective May 17, 2005, as amended through December 1, 2024; read 2026-10-14). | Not produced: the cover sheet is a separate form. |
| FRBP 7008(a) | "Fed. R. Civ. P. 8 applies in an adversary proceeding." The jurisdiction allegation "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending." A complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." Source: https://www.law.cornell.edu/rules/frbp/rule_7008 (fetched 2026-10-14, via a summarizing fetch; quotations are the fetched text). | Not enforced by the template (see Known gaps 2 and 3). |
| FRBP 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." Source: https://www.law.cornell.edu/rules/frbp/rule_7010 (fetched 2026-10-14). | `cover()` and `caption-row()`: court name, party block with ")" column, adversary number, title. |
| Fed. R. Civ. P. 10(b) (via 7010) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-of()` numbers every paragraph chunk; headings and the WHEREFORE lead-in are not numbered. |
| FRBP 9004(a), (b) | (a) "A petition, pleading, schedule, or other document must be clearly legible." (b) A caption with the court's name, the case's title, the case number and, if appropriate, the adversary number, and "a brief designation of the document's character." Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14). The federal rule sets no paper size or font. | Caption, title line. |
| E.D. Tenn. LBR 9004-1(a) | "all pleadings and other papers presented for filing must be 8½ inches by 11 inches in size, typed or legibly hand-printed, double-spaced (except for Official Forms and quoted material), and paginated consecutively at the bottom beginning with the second page." | `page-w`/`page-h`; `pitch-body` (24 pt double spacing); `page-number()` prints the number from page 2. |
| E.D. Tenn. LBR 9004-2(a) | The caption identifies "the chapter of the case, the division in which the case or adversary proceeding is pending, and the case or adversary proceeding number, including the initials of the judge." | The case number carries the judge's initials in the sample (`-SHB`). The division line is optional in the template (see Known gaps 2). |

Not produced by this template (separate filings that may accompany a complaint): the Form B 1040 cover sheet (LBR 7003-1); the summons (LBR 7004-2); any disclosure the clerk requires. A complaint filed in this court is usually accompanied by these.

## Layout

On the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of its pitch (24 pt double, 13.8 pt single), first-fit ragged-right breaking, no kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does (`eval.yaml`: `params.cross_engine: gate`).

- Letter paper, 1-inch margins, Times New Roman 12 pt. Court title centered and bold in single lines (`IN THE UNITED STATES BANKRUPTCY COURT` / `FOR THE EASTERN DISTRICT OF TENNESSEE`), optional division line.
- Caption: a blank single line, then each row a party or case-information entry, a ")" in a centered 0.3 in column, and right-hand case information, each a 13.8 pt single line (a blank row keeps its line, so the ")" column stays aligned). Docx: a borderless three-column table of the same widths.
- A blank single line, the title centered and bold, a blank single line, then the lead-in paragraph (unnumbered), then the body.
- Headings centered and bold at the type size on the 24 pt pitch; the heading is kept with the paragraph after it.
- Paragraphs: double spaced (24 pt line boxes, LBR 9004-1(a)), first-line indent 0.5 inch, the template's number in a 0.5 in box after it (the text starts 1 in in; docx: a tab at 1 in).
- WHEREFORE lead-in unnumbered; the prayer items lettered (a), (b), ... like the numbered paragraphs (the letter at 0.5 in, the text at 1 in, wrapping to the margin), double spaced with no extra line between them, as in the filed complaint.
- Signature: the dated line on the double pitch, a blank double line, then the single-spaced block at 3.25 inches (the lead line, a blank single line, `signature.by`, `signature.lines`). The last prayer item is kept on one page with the dated line and the signature block.
- Page numbers centered at the bottom from page 2 (LBR 9004-1(a)), a single line ending 0.5 in above the bottom edge; page 1 has none (docx: titlePg with an empty first-page footer).

## Markdown contract (for samples)

- YAML frontmatter: `court`, `district`, optional `division`, `caption` (a list of `{left, right}` rows, each one caption line; blank text is allowed), `title`, optional `lead_in`, `signature` (`dated`, `by`, `lines`, optional `lead`); each value is CommonMark inline text (`*italic*`, `**bold**`, `\_` / `\*` escapes), read with smart punctuation by both engines.
- Body: blank-line-separated chunks. `#` or `##` lines are headings. A paragraph is numbered by the template; a chunk that begins `WHEREFORE` is an unnumbered lead-in; a chunk of `1.`-style items is the lettered prayer list.
- The sample must not contain paragraph numbers in the text (the template numbers them). Case-specific text belongs only in the sample, never in the template.
- Not supported: tables, footnotes, typst markup. `$`, `#` and `@` print as written.

## Known gaps and open choices

1. **Font.** No rule for this court names a font (LBR 9004-1 says nothing about type). The exemplar is Times New Roman (non-embedded, see `pdffonts`); both engines now set the vendored Times New Roman (was EB Garamond). The exemplar's 8 pages render as 7 here: its caption is taller (a ruled line of underscores, a two-line title) and its paragraphs are justified.
2. **Division.** LBR 9004-2(a) requires the caption to identify the division. The exemplar's caption has no division line (its case number `3:17-bk-33605-SHB` carries the judge's initials and the chapter is in the caption). The template prints a division line when the frontmatter gives one; the sample omits it so that the transcription matches the filing. Filing with the division line is required by the rule; the template does not enforce it.
3. **Consent to final orders (FRBP 7008(a)).** The exemplar (filed 2018-03-09) has no statement of whether the pleader consents to final orders. The current rule text, as fetched, requires one. The template does not enforce it, and the sample does not add one, because it would be an invented litigation position. The overlay shows the gap. Before this template is used for a filing, the complaint must state consent or non-consent.
4. **Jurisdiction reference (FRBP 7008(a)).** The exemplar's jurisdiction paragraph refers to the Chapter 7 case but not to its name or number; the caption carries the number. The template does not check the jurisdiction paragraph.
5. **Rule text source.** The FRBP 7008(a) and 7010 quotations come from a fetch of Cornell LII that summarized the page, not from a copy of the official rule text on uscourts.gov. The LBR text is from the court's own PDF. Verify the FRBP quotations against the official rules before relying on them.
6. **Tier-2 exemplars.** EVAL-LOOP asks for two or three filers. This pass collected one exemplar, as the brief asks. The paragraph layout and caption follow the single exemplar; the second filer is not checked.
7. **Prayer spacing.** Resolved 2026-10-22: the prayer items are double spaced with no extra line between them, the letter at the paragraph indent and the text wrapping to the margin, as in the filing.
8. **Signature block.** The exemplar's text is transcribed as filed, including the spelling "Abbacus Holdings Ltd." in the signature block. The rest of the filing uses "Abbacas".
9. **Not produced.** Cover sheet (Form B 1040), summons, proposed order. See the rules table.

## Overlay

`usage/OVERLAY-hood-complaint.pdf`: red is our render, blue is the filed exemplar, black is where both agree. Page pairing (`OVERLAY-hood-complaint.txt`): our pages 1 to 7 pair with filed pages 1, 2, 4, 5, 6, 7, 8. The word overlap per page is 47% to 87%. The pairing is by words, so a page offset is expected where our pagination differs by a line. The overlay is a diagnostic, not a score.

## Engines

Both engines are on the shared cross-engine layout model; typst is the reference.

DOCX (`docx/`): `docx/reference.xml` (`base="xengine"`: the face is the typst template's, `{font}` = Times New Roman, 12 pt, Body Text in exact 480-twip lines with a 720-twip first-line indent, single lines 276 twips; added styles "Body Numbered" with a tab at 1 in, and "Body Text Keep" / "Body Numbered Keep" for the last body paragraph; `pandoc-from` CommonMark with smart punctuation, as typst's cmarker reads the sample) and `docx/tneb-adversary-complaint.lua` on `lib/docx/xengine.lua`, which writes the cover, the caption table, the headings, the numbered and lettered paragraphs, the signature block, the page-number footer (`$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `titlePg` with fb render's empty first-page footer; `$FORMBOOK_FINAL`). No shell scripts (the former `docx/build-reference.sh` and `reference.docx` are gone). Rendered with `sh tools/render.sh --engine docx <dir> usage/INPUT-adversary-complaint.md` to `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf`.

- Gate 4 (`eval.yaml`, `params.cross_engine: gate`): XENG-001..003 PASS, 7 = 7 pages, 191/191 typst lines break after the same word, every baseline within 0.04 pt (`fb diff --engines`, 2026-10-22).
- Both engines print the sample's quotes and dashes as smart punctuation.
- BLOCKED: none. The form has no pleading line numbers, TOC or TOA, so no DOCX.md limit applies. The .docx was opened in LibreOffice only, not in Word.
