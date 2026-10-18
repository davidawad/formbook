# tneb: motion brief (memorandum in support of a motion)

Doc type: **motion-brief**: the memorandum that supports a motion in the United States Bankruptcy Court for the Eastern District of Tennessee (`tneb`), in a main-case contested matter. The exemplar is a memorandum in support of a motion to dismiss an involuntary petition.
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: pages 1 to 10 of the filing, the signature block and the certificate of service; argument headings B to E without their bodies (see Known gaps 4) |
| typeface | face required: none (E.D. Tenn. LBR 9004-1(a) names no typeface; checked against the full local rules PDF, 2026-10-15). Font: EB Garamond kept (vendored, `fonts/eb-garamond/`); no court face to substitute. Visual only versus the filed Times New Roman. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings, pdffonts shows EBGaramond only (2026-10-15) |
| overlay | ok: `usage/OVERLAY-echo-mav-memorandum.pdf` and `usage/OVERLAY-echo-mav-memorandum.txt` (regenerated 2026-10-15) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed on 2026-10-15) |

Tools: `sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-motion-brief.md`, then `sh tools/overlay.sh <same dir> echo-mav-memorandum`.

## Governing rules

Primary sources. The E.D. Tenn. local rules were read from the court's PDF on 2026-10-14 (`https://www.tneb.uscourts.gov/sites/tneb/files/local_rules/TNEB_Local_Rules.pdf`, "Effective May 17, 2005, as Amended ... December 1, 2024"). The FRBP text (9004) was obtained by a summarizing fetch of Cornell LII on 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 9004(a), (b) | (a) "clearly legible." (b) A caption with the court's name, the case title, the case number and, if appropriate, the adversary number, and "a brief designation of the document's character." Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14). | `cover()`: court, district, caption, title. |
| E.D. Tenn. LBR 9004-1(a) | 8½ × 11 inches; "typed or legibly hand-printed, double-spaced (except for Official Forms and quoted material), and paginated consecutively at the bottom beginning with the second page." | `body-leading` (double spacing); page footer from page 2. Block quotations are not used in the sample, so the single-spacing exception is not implemented. |
| E.D. Tenn. LBR 9004-2(a) | The caption identifies "the chapter of the case, the division in which the case or adversary proceeding is pending, and the case or adversary proceeding number, including the initials of the judge." | Caption rows carry the case number with judge's name and chapter; the division line comes from `division` in the frontmatter. |
| E.D. Tenn. LBR 9013-1(a)-(b) | The rule governs "motions" in a bankruptcy case, which must be in writing, titled, state "with particularity the grounds," and "request specific relief." Adversary motions are excluded and governed by LBR 7007-1. | The brief is the supporting paper, so the template does not check the motion's title or grounds; `title` is the memorandum's own title. |
| E.D. Tenn. LBR 9013-1(c) | Every motion must be accompanied by a proposed order, served with the motion. | Not produced (a separate paper). See Known gaps 6. |
| E.D. Tenn. LBR 9013-1(d)(1), (f)(1) | Every motion must contain a certificate under LBR 9013-3; every motion must be set for hearing by a legend below the caption on the first page, or by a separate Notice of Hearing form. | Certificate: `certificate()`. Hearing legend: not in the template (see Known gaps 5). |
| E.D. Tenn. LBR 9013-3(b) | The certificate of service "must include a description of the paper served or noticed and with respect to each person or entity being served or noticed, the name, service address, manner of service, and date of service." | `certificate()`: the paper, the persons served in a two-column grid, the signer. The manner and date are in the certificate text (CM/ECF, date). |

## Layout

- Letter paper, 1-inch margins. Court title centered and bold, the optional division line in capitals, then the caption (fixed single-spaced rows, the ")" column), then the title centered and bold.
- Lead-in paragraph (the first paragraph, with a first-line indent), then the body.
- Section headings (`#`): bold, at the left margin, kept with the text after them.
- Argument headings (`##`): bold, indented 0.5 inch, kept with the text after them.
- Body paragraphs: first-line indent 0.5 inch, double spaced (line box 0.65 em plus a 1.35 em paragraph spacing, about 24 pt). Not numbered (a brief does not number paragraphs).
- Signature block at 3.25 inches, single spaced, kept together.
- Certificate of service: a centered title, the paper and date statement, the persons served in a two-column grid, and the signer on the right. Kept together on one page.

## Markdown contract (for samples)

- YAML frontmatter: `court`, `district`, optional `division`, `caption` (rows of `{left, right}`), `title`, `lead_in`, `signature` (`lead`, optional `firm`, `by`, `lines`), `certificate` (`text`, `served` as a list of strings with one "\n" per line, and `signer`). Markup in these fields is limited to `*italic*`, `**bold**`, and `\_` / `\*` escapes.
- Body: blank-line-separated paragraphs. A chunk that starts `##` is an argument heading; `#` is a section heading. Other chunks are paragraphs.
- Not supported: footnotes (the exemplar's footnote 1 is omitted, see Known gaps 4), tables in the body, typst markup. `$`, `#` and `@` print as written.

## Known gaps and open choices

1. **Font.** No rule for this court names a font. The exemplar is Times New Roman (embedded). The template uses EB Garamond, the only vendored serif font. The exemplar's 22 pages render as 10 here, because the sample is a partial transcription (see gap 4); the x-height difference is the same as in the complaint. Whether the court expects a Times-metric face is a question for David.
2. **Motion versus memorandum.** The exemplar is a memorandum (a brief) filed in a main-case contested matter. It falls under LBR 9013-1. An adversary-proceeding motion falls under LBR 7007-1, which adds a 21-day passive notice legend and a brief requirement; that is a different doc type and is not produced here.
3. **Italics.** Case names in the exemplar are italic in the printed filing (the filing's body font has an italic face), but the text layer carries no italic markup. The sample's case names are roman. The template italicizes `*...*` in the sample, so an italic sample would carry italics.
4. **Partial transcription.** The sample transcribes pages 1 to 10 of the 22-page filing (the introduction, the statement of facts, the legal standard, Argument A), and then the Argument B to E headings (with no bodies), the conclusion, the signature block (page 21) and the certificate (page 22). Pages 11 to 20 are not transcribed. The footnote on page 5 (WooCommerce) is not carried; the sample names "WooCommerce" without its footnote. The brief's depth bar (8 to 14 pages) is met by the 10 rendered pages.
5. **Hearing notice.** LBR 9013-1(f)(1) requires a legend below the caption on the first page of every motion, or a separate Notice of Hearing. The exemplar (a memorandum, not a motion) has none. The template has no legend slot; a motion built from this doc type would need one.
6. **Proposed order and Notice of Hearing.** Not produced. LBR 9013-1(c) requires a proposed order with every motion. Its format is in E.D. Tenn. LBR 9072-1(c) (a four-inch top margin on the first page for the judge's signature, an end marker, and the attorney block); it is a separate doc type.
7. **Rule text source.** The FRBP 9004 quotation comes from a summarizing fetch of Cornell LII; verify against the official text before relying on it. The LBR text is from the court's own PDF.
8. **Tier-2 exemplars.** This pass collected one exemplar, as the brief asks. EVAL-LOOP asks for two or three filers; not met.

## Overlay

`usage/OVERLAY-echo-mav-memorandum.pdf`: red is our render, blue is the filed exemplar, black is where both agree. Page pairing (`OVERLAY-echo-mav-memorandum.txt`): our pages 1 to 3 pair with filed pages 1 to 3; our pages 4 to 9 pair with filed pages 5 to 10 (a one-page offset from our page 4 on: the pairing is by words, so a page offset is expected where our pagination differs from the filing's); our page 10 (the certificate) pairs with filed page 22. The word overlap per page is 44% to 86%. The overlay is a diagnostic, not a score.

## Engines

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference (EB Garamond 12 pt, exact 24 pt double lines, 13.8 pt single lines, 1 in margins, section headings bold at the margin, argument headings bold and indented 0.5 in, page number from page 2 through `titlePg`); `docx/tneb-motion-brief.lua` builds the cover, body, signature and the certificate of service (a borderless two-column table). Rendered with `sh tools/render.sh --engine docx <dir> usage/INPUT-motion-brief.md` to `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice 26.8.1, 10 pages, pdffonts shows EB Garamond only). Every page of both the `.docx.pdf` and the typst output was rasterized at 60 dpi and viewed (10 of 10, 2026-10-15).

- Matches the typst output: letter page, 1 in margins, EB Garamond 12 pt, double-spaced body with a 0.5 in first-line indent, the cover (court, district, division, caption, title) in the same lines, bold section and argument headings in the same positions, the signature block at 3.25 in kept on one page (keep-with-next), the certificate of service with the two served persons side by side, the page number centered from page 2.
- Differs (tier 2, not chased): line breaks fall one line apart on some pages, so later page breaks move by a line (still 10 pages); LibreOffice places exact-spacing leading above the text, so the text starts about 11 pt lower on each page (the margin is unchanged); heading spacing around the argument headings is pandoc's, a few points less than the typst block spacing; pandoc's smart extension prints curly quotes and dashes where typst prints the sample's straight characters; the cover spacer (about 17 pt) is tuned to the typst title position, not a rule value.
- BLOCKED: none. The form has no pleading line numbers, TOC or TOA, so no DOCX.md limit applies. `tools/check.sh --engine docx` cannot pass until the court has `rules.md`, `checks.yaml` and a review file (not part of this unit).
