# tneb: motion brief (memorandum in support of a motion)

Doc type: **motion-brief**: the memorandum that supports a motion in the United States Bankruptcy Court for the Eastern District of Tennessee (`tneb`), in a main-case contested matter. The exemplar is a memorandum in support of a motion to dismiss an involuntary petition.
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: pages 1 to 10 of the filing, the signature block and the certificate of service; argument headings B to E without their bodies (see Known gaps 4) |
| typeface | face required: none (E.D. Tenn. LBR 9004-1(a) names no typeface; checked against the full local rules PDF, 2026-10-15). Font: Times New Roman (vendored, the default per docs/FONTS.md and the face of the filed exemplar), the same face in typst and docx. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx.pdf`, 11 pages each, typst 0.15.0, vendored Times New Roman only, no warnings (2026-10-22) |
| overlay | `just overlay <this dir>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 11 of 11 in both engines (every page rendered at 60 dpi and viewed on 2026-10-22) |

Tools: `sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-motion-brief.md`, then `just overlay <same dir>`.

## Governing rules

Primary sources. The E.D. Tenn. local rules were read from the court's PDF on 2026-10-14 (`https://www.tneb.uscourts.gov/sites/tneb/files/local_rules/TNEB_Local_Rules.pdf`, "Effective May 17, 2005, as Amended ... December 1, 2024"). The FRBP text (9004) was obtained by a summarizing fetch of Cornell LII on 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 9004(a), (b) | (a) "clearly legible." (b) A caption with the court's name, the case title, the case number and, if appropriate, the adversary number, and "a brief designation of the document's character." Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14). | `cover()`: court, district, caption, title. |
| E.D. Tenn. LBR 9004-1(a) | 8½ × 11 inches; "typed or legibly hand-printed, double-spaced (except for Official Forms and quoted material), and paginated consecutively at the bottom beginning with the second page." | `pitch-body` 24 pt (double spacing); page footer from page 2. Block quotations are not used in the sample, so the single-spacing exception is not implemented. |
| E.D. Tenn. LBR 9004-2(a) | The caption identifies "the chapter of the case, the division in which the case or adversary proceeding is pending, and the case or adversary proceeding number, including the initials of the judge." | Caption rows carry the case number with judge's name and chapter; the division line comes from `division` in the frontmatter. |
| E.D. Tenn. LBR 9013-1(a)-(b) | The rule governs "motions" in a bankruptcy case, which must be in writing, titled, state "with particularity the grounds," and "request specific relief." Adversary motions are excluded and governed by LBR 7007-1. | The brief is the supporting paper, so the template does not check the motion's title or grounds; `title` is the memorandum's own title. |
| E.D. Tenn. LBR 9013-1(c) | Every motion must be accompanied by a proposed order, served with the motion. | Not produced (a separate paper). See Known gaps 6. |
| E.D. Tenn. LBR 9013-1(d)(1), (f)(1) | Every motion must contain a certificate under LBR 9013-3; every motion must be set for hearing by a legend below the caption on the first page, or by a separate Notice of Hearing form. | Certificate: `certificate()`. Hearing legend: not in the template (see Known gaps 5). |
| E.D. Tenn. LBR 9013-3(b) | The certificate of service "must include a description of the paper served or noticed and with respect to each person or entity being served or noticed, the name, service address, manner of service, and date of service." | `certificate()`: the paper, the persons served in a two-column grid, the signer. The manner and date are in the certificate text (CM/ECF, date). |

## Layout

- Letter paper, 1-inch margins. Court title centered and bold, the optional division line in capitals, a blank single line, the caption (one 13.8 pt row per frontmatter row, the ")" column), a blank single line, then the title centered, bold and underlined, single-spaced (as filed).
- Lead-in paragraph (the first paragraph, with a first-line indent), then the body.
- Section headings (`#`): the typed label ("I.") bold in a half-inch box at the margin, the text bold and underlined hanging after it (as filed); 13.8 pt lines, 12 pt above and below, kept with the text after them.
- Argument headings (`##`): half an inch in, the label ("A.") in a half-inch box, the text underlined hanging after it (as filed); otherwise as section headings.
- Body paragraphs: first-line indent 0.5 inch, ragged right, double spaced (24 pt line boxes, the cross-engine layout model). Not numbered (a brief does not number paragraphs). The last paragraph is kept on one page with the signature block.
- Signature block at 3.25 inches, single spaced (13.8 pt), a blank single line after the lead and after the firm, kept together, 24 pt below the body.
- Certificate of service, on its own page (as filed): a centered bold underlined title, the paper and date statement (double spaced, first-line indent), the persons served in two columns (single spaced), and the signer at 3.25 inches.

## Markdown contract (for samples)

- YAML frontmatter: `court`, `district`, optional `division`, `caption` (rows of `{left, right}`), `title`, `lead_in`, `signature` (`lead`, optional `firm`, `by`, `lines`), `certificate` (`text`, `served` as a list of strings with one "\n" per line, and `signer`). These fields and the body are markdown (italics, bold, escapes; straight quotes print as typographic quotes in both engines).
- Body: blank-line-separated paragraphs. A chunk that starts `##` is an argument heading; `#` is a section heading. Other chunks are paragraphs.
- Not supported: footnotes (the exemplar's footnote 1 is omitted, see Known gaps 4), tables in the body, typst markup. `$`, `#` and `@` print as written.

## Known gaps and open choices

1. **Font.** No rule for this court names a font. The exemplar is Times New Roman (embedded); the template sets the vendored Times New Roman in both engines (was EB Garamond). The exemplar's 22 pages render as 11 here, because the sample is a partial transcription (see gap 4).
2. **Motion versus memorandum.** The exemplar is a memorandum (a brief) filed in a main-case contested matter. It falls under LBR 9013-1. An adversary-proceeding motion falls under LBR 7007-1, which adds a 21-day passive notice legend and a brief requirement; that is a different doc type and is not produced here.
3. **Italics.** Case names in the exemplar are italic in the printed filing (the filing's body font has an italic face), but the text layer carries no italic markup. The sample's case names are roman. The template italicizes `*...*` in the sample, so an italic sample would carry italics.
4. **Partial transcription.** The sample transcribes pages 1 to 10 of the 22-page filing (the introduction, the statement of facts, the legal standard, Argument A), and then the Argument B to E headings (with no bodies), the conclusion, the signature block (page 21) and the certificate (page 22). Pages 11 to 20 are not transcribed. The footnote on page 5 (WooCommerce) is not carried; the sample names "WooCommerce" without its footnote. The brief's depth bar (8 to 14 pages) is met by the 11 rendered pages.
5. **Hearing notice.** LBR 9013-1(f)(1) requires a legend below the caption on the first page of every motion, or a separate Notice of Hearing. The exemplar (a memorandum, not a motion) has none. The template has no legend slot; a motion built from this doc type would need one.
6. **Proposed order and Notice of Hearing.** Not produced. LBR 9013-1(c) requires a proposed order with every motion. Its format is in E.D. Tenn. LBR 9072-1(c) (a four-inch top margin on the first page for the judge's signature, an end marker, and the attorney block); it is a separate doc type.
7. **Rule text source.** The FRBP 9004 quotation comes from a summarizing fetch of Cornell LII; verify against the official text before relying on it. The LBR text is from the court's own PDF.
8. **Tier-2 exemplars.** This pass collected one exemplar, as the brief asks. EVAL-LOOP asks for two or three filers; not met.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt, no kerning, ligatures or hyphenation, first-fit ragged-right lines, every line an exact box of its pitch (24 pt body, 13.8 pt single), the spaces between blocks the same twips in both. `eval.yaml` sets `params.cross_engine: gate`: the docx breaks every line and page as typst does (XENG-001..003 PASS, 287/287 lines, 11 pages; 2026-10-22).

DOCX (`docx/`): `docx/reference.xml` (base="xengine", the face as `{font}`; built by `fb render`) gives the Body Text style (24 pt exact lines, 0.5 in first-line indent), Body Keep (the last paragraph, kept with the signature), the page-number footer in a 13.8 pt line from page 2 on (`titlePg`, an empty first-page footer); `docx/tneb-motion-brief.lua` writes the court title, the caption table, the title, the headings, the signature block and the certificate of service (a borderless two-column table) with the typst spacing, and leaves body paragraphs to pandoc. Rendered with `sh tools/render.sh --engine docx <dir> usage/INPUT-motion-brief.md` to `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`.

- Matches the typst output line for line and page for page (Gate 4 CROSS-ENGINE).
- Differs (visual only): Word underlines the space at the end of a wrapped underlined heading line; typst does not.
- BLOCKED: none. The form has no pleading line numbers, TOC or TOA, so no DOCX.md limit applies.
