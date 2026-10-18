# tneb: adversary complaint

Doc type: **adversary-complaint** (a complaint commencing an adversary proceeding) in the United States Bankruptcy Court for the Eastern District of Tennessee (`tneb`).
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the whole filing (8 pages), transcribed from the text layer |
| typeface | face required: none (E.D. Tenn. LBR 9004-1(a) names no typeface; checked against the full local rules PDF, 2026-10-15). Font: EB Garamond kept (vendored, `fonts/eb-garamond/`); no court face to substitute. Visual only versus the filed Times New Roman. |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings, pdffonts shows EBGaramond only (2026-10-15) |
| overlay | ok: `usage/OVERLAY-hood-complaint.pdf` and `usage/OVERLAY-hood-complaint.txt` (regenerated 2026-10-15) |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed on 2026-10-15) |

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
| E.D. Tenn. LBR 9004-1(a) | "all pleadings and other papers presented for filing must be 8½ inches by 11 inches in size, typed or legibly hand-printed, double-spaced (except for Official Forms and quoted material), and paginated consecutively at the bottom beginning with the second page." | `page-w`/`page-h`; `body-leading` (double spacing); the footer counter is shown from page 2. |
| E.D. Tenn. LBR 9004-2(a) | The caption identifies "the chapter of the case, the division in which the case or adversary proceeding is pending, and the case or adversary proceeding number, including the initials of the judge." | The case number carries the judge's initials in the sample (`-SHB`). The division line is optional in the template (see Known gaps 2). |

Not produced by this template (separate filings that may accompany a complaint): the Form B 1040 cover sheet (LBR 7003-1); the summons (LBR 7004-2); any disclosure the clerk requires. A complaint filed in this court is usually accompanied by these.

## Layout

- Letter paper, 1-inch margins. Court title centered and bold (`IN THE UNITED STATES BANKRUPTCY COURT` / `FOR THE EASTERN DISTRICT OF TENNESSEE`), optional division line.
- Caption: each row has a party or case-information entry, a ")" in a centered column, and right-hand case information. Rows are a fixed single-spaced pitch (13.8 pt), so the ")" column stays aligned with blank rows.
- Title centered and bold, then the lead-in paragraph (unnumbered), then the body.
- Headings centered and bold; the heading is kept with the paragraph after it.
- Paragraphs: first-line indent 0.5 inch, numbered by the template, double spaced (line box 0.65 em plus a 1.35 em paragraph spacing gives about 24 pt).
- WHEREFORE lead-in unnumbered; the prayer list is lettered (a), (b), ... with a double-spaced line between items.
- Signature: "Respectfully submitted this ... day ...," then the signature block at 3.25 inches, from frontmatter (`signature.by`, `signature.lines`).
- Page numbers centered at the bottom from page 2 (LBR 9004-1(a)).

## Markdown contract (for samples)

- YAML frontmatter: `court`, `district`, optional `division`, `caption` (a list of `{left, right}` rows, each one caption line; blank text is allowed), `title`, optional `lead_in`, `signature` (`dated`, `by`, `lines`, optional `lead`), with markup limited to `*italic*`, `**bold**`, and `\_` / `\*` escapes.
- Body: blank-line-separated chunks. `#` or `##` lines are headings. A paragraph is numbered by the template; a chunk that begins `WHEREFORE` is an unnumbered lead-in; a chunk of `1.`-style items is the lettered prayer list.
- The sample must not contain paragraph numbers in the text (the template numbers them). Case-specific text belongs only in the sample, never in the template.
- Not supported: tables, footnotes, typst markup. `$`, `#` and `@` print as written.

## Known gaps and open choices

1. **Font.** No rule for this court names a font (LBR 9004-1 says nothing about type). The exemplar is Times New Roman (non-embedded, see `pdffonts`). The template uses EB Garamond, the only vendored serif font. EB Garamond at 12 point has a smaller x-height than Times at 12 point. The exemplar's 8 pages render as 7 here. Whether the court expects a Times-metric face is a question for David (a vendored Times-metric font would remove the difference).
2. **Division.** LBR 9004-2(a) requires the caption to identify the division. The exemplar's caption has no division line (its case number `3:17-bk-33605-SHB` carries the judge's initials and the chapter is in the caption). The template prints a division line when the frontmatter gives one; the sample omits it so that the transcription matches the filing. Filing with the division line is required by the rule; the template does not enforce it.
3. **Consent to final orders (FRBP 7008(a)).** The exemplar (filed 2018-03-09) has no statement of whether the pleader consents to final orders. The current rule text, as fetched, requires one. The template does not enforce it, and the sample does not add one, because it would be an invented litigation position. The overlay shows the gap. Before this template is used for a filing, the complaint must state consent or non-consent.
4. **Jurisdiction reference (FRBP 7008(a)).** The exemplar's jurisdiction paragraph refers to the Chapter 7 case but not to its name or number; the caption carries the number. The template does not check the jurisdiction paragraph.
5. **Rule text source.** The FRBP 7008(a) and 7010 quotations come from a fetch of Cornell LII that summarized the page, not from a copy of the official rule text on uscourts.gov. The LBR text is from the court's own PDF. Verify the FRBP quotations against the official rules before relying on them.
6. **Tier-2 exemplars.** EVAL-LOOP asks for two or three filers. This pass collected one exemplar, as the brief asks. The paragraph layout and caption follow the single exemplar; the second filer is not checked.
7. **Prayer spacing.** The prayer items sit a little further apart than in the filing (one extra double-spaced line between items). Cosmetic; not measured against a rule.
8. **Signature block.** The exemplar's text is transcribed as filed, including the spelling "Abbacus Holdings Ltd." in the signature block. The rest of the filing uses "Abbacas".
9. **Not produced.** Cover sheet (Form B 1040), summons, proposed order. See the rules table.

## Overlay

`usage/OVERLAY-hood-complaint.pdf`: red is our render, blue is the filed exemplar, black is where both agree. Page pairing (`OVERLAY-hood-complaint.txt`): our pages 1 to 7 pair with filed pages 1, 2, 4, 5, 6, 7, 8. The word overlap per page is 47% to 87%. The pairing is by words, so a page offset is expected where our pagination differs by a line. The overlay is a diagnostic, not a score.

## Engines

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference (EB Garamond 12 pt, exact 24 pt double lines, 13.8 pt single lines, 1 in margins, page number from page 2 through `titlePg`); `docx/tneb-adversary-complaint.lua` builds the cover, caption, numbered allegations, lettered prayer and signature. Rendered with `sh tools/render.sh --engine docx <dir> usage/INPUT-adversary-complaint.md` to `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice 26.8.1, 7 pages, pdffonts shows EB Garamond only). Every page of both the `.docx.pdf` and the typst output was rasterized at 60 dpi and viewed (7 of 7, 2026-10-15).

- Matches the typst output: letter page, 1 in margins, EB Garamond 12 pt, double-spaced body with a 0.5 in first-line indent, the cover (court, district, caption, title) in the same lines and single-spaced caption, bold centered headings, numbered allegations, lettered prayer, the signature block at 3.25 in kept on one page, the page number centered from page 2 with page 1 unnumbered.
- Differs (tier 2, not chased): line breaks fall one line apart on some pages (page 3 carries one more line in the docx, so the page 4 break moves); LibreOffice places exact-spacing leading above the text, so the text starts about 11 pt lower on each page (the margin is unchanged); the number-to-text gap is a tab to 1 in, where typst uses 0.3 in after the number; pandoc's smart extension prints curly quotes and dashes where typst prints the sample's straight characters; the cover spacers (3 pt and 22 pt) are tuned to the typst title position, not a rule value.
- BLOCKED: none. The form has no pleading line numbers, TOC or TOA, so no DOCX.md limit applies. `tools/check.sh --engine docx` cannot pass until the court has `rules.md`, `checks.yaml` and a review file (not part of this unit).
