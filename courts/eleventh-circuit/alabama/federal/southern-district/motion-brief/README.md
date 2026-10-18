# alsd: motion-brief

Doc type: **motion to dismiss with memorandum** (a Rule 12(b) motion and its supporting brief, which may be one document under Civ. L.R. 7(b)) in the United States District Court for the Southern District of Alabama (`alsd`).
Folder: `courts/eleventh-circuit/alabama/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (caption, title, introduction, factual background, argument I to IV, V (partly), VI, conclusion, signature, certificate of service added by us; several passages elided, see Known gaps) |
| typeface | face required: none (S.D. Ala. Gen. L.R. 5(a)(2) asks for "a plain, Roman style (or similar) font"; no face is named). Substitute: **EB Garamond** (kept, as the brief's rule for courts that name no face). Fit: n/a. See Known gaps 1. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings; re-rendered 2026-10-14, `pdffonts` shows `EBGaramond-Regular`, `-Bold`, `-Italic` embedded (no other face) |
| overlay | ok: `usage/OVERLAY-shell-motion-brief.pdf` and `OVERLAY-shell-motion-brief.txt` (`tools/overlay.sh`), re-run 2026-10-14 against the RECAP copy of the exemplar (the exemplar PDF is not stored in the folder; see `usage/SOURCE.md`) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed on 2026-10-14, after the typeface check) |

File names follow the repo's tools (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`); `<id>` is `shell-motion-brief`.

## Governing rules

Primary source: S.D. Ala. Local Rules (Order Promulgating Local Rules, "Effective August 1, 2015"), PDF at https://www.alsd.uscourts.gov/sites/alsd/files/local-rules.pdf, fetched 2026-10-14. The same PDF is the source for the complaint's rules; see `../complaint/README.md`. Later amendments were not checked.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Ala. Gen. L.R. 5(a)(1) | 8½ × 11 paper; double-spaced text (quotations of more than two lines may be single-spaced); headings and footnotes may be single-spaced; margins of at least 1 inch on all four sides; page numbers only in the margins. | `margin = 1in`, `body-leading`, `single-leading` for block quotes, headings, signature and certificate; footer page number in the bottom margin. |
| S.D. Ala. Gen. L.R. 5(a)(2) | "A plain, Roman style (or similar) font"; case names italic or underlined; 12 point or larger, footnotes included. Names no typeface. | `font-family = "EB Garamond"` (kept: any plain roman face satisfies the rule), `type-size = 12pt`; case names italic from `*...*`. See Known gaps 1. |
| S.D. Ala. Gen. L.R. 5(a)(3) | Signature line, with the typed name, address and telephone of every attorney of record directly beneath. | `signature-block()`. |
| S.D. Ala. Civ. L.R. 7(a) | Every motion must state the statute, rule, or legal or equitable principle under which it is made. | Not checked by the template. The sample states the rule in its introduction and in section VI (Rule 12(e)); the Rule 12(b)(6) basis appears in the argument, not in a separate statement. |
| S.D. Ala. Civ. L.R. 7(b) | A Rule 12(b) motion must be supported by a brief; the brief may be included within the body of the motion. | The document is the brief; the title says "Memorandum of Law in Support of Its Motion". |
| S.D. Ala. Civ. L.R. 7(e) | Principal briefs at most 30 pages, excluding caption, cover page, table of contents, table of authorities and signature block. | Not checked by the template. The sample (8 pages) and the filed exemplar (22 pages) are within the limit. |
| Fed. R. Civ. P. 12(b)(6); 12(e) | Failure to state a claim; motion for a more definite statement of a pleading "so vague or ambiguous that the party cannot reasonably prepare a response". Fetched https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14. | Argument I to V (12(b)(6)) and section VI (12(e)) in the sample. |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs, each limited to a single set of circumstances (quoted in the exemplar's section VI). Fetched https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | Quoted in the sample; not a template rule (briefs are not numbered). |
| Fed. R. Civ. P. 5(b) | Certificate of service for a paper served through the court's electronic system. Not fetched in this pass. | `certificate-block()`: added to the sample because the exemplar has none. See Known gaps 5. |

## Layout

- Court title on the first page, centered and bold (three lines, single-spaced); caption as in the complaint (party column, ")" column, "Civil Action No." on the middle line).
- Title of the paper centered and bold under the caption.
- Body double-spaced (24 pt pitch). Paragraphs are unnumbered with a 0.5 inch first-line indent.
- Headings: level 1 centered bold caps (INTRODUCTION, FACTUAL BACKGROUND, LEGAL ARGUMENT, CONCLUSION); level 2 bold at the left with a hanging indent for the roman numeral; level 3 bold, indented, for the lettered sub-heading. Headings are single-spaced and stay with the text after them.
- Lists: bulleted in the sample (the exemplar's claim list); lettered if the markdown is numbered.
- Block quotes single-spaced, indented 0.5 inch on both sides.
- Signature: "Date:" on the left; "Respectfully submitted," and the attorney block in the right half of the page.
- Certificate of service: centered bold heading, a paragraph and the signature line.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number` (the civil action number as printed on the caption), `division`, `caption.parties` (as in the complaint), `brief_title`, `date`, `signature.blocks` (list of attorney blocks), `certificate` (optional: `text` paragraph and `signature` lines).
- Body: blank-line-separated chunks. `#` is level 1, `##` level 2, `###` level 3. A chunk starting with `-` or `1.` is a list. A chunk starting with `>` is a block quote. Any other chunk is a body paragraph with a first-line indent.
- Not supported: footnotes (the exemplar has them; the sample drops the markers and their text, see Known gaps 3), tables, raw typst.

## Overlay (red/blue)

`usage/OVERLAY-shell-motion-brief.pdf` pairs our eight pages with the filed pages by shared words. The map in `OVERLAY-shell-motion-brief.txt`:

```
ours p.1 filed p.1   ours p.2 filed p.3   ours p.3 filed p.4   ours p.4 filed p.6
ours p.5 filed p.7   ours p.6 filed p.20  ours p.7 filed p.21  ours p.8 filed p.22
```

The pairing is not in order because the sample elides the exemplar's pages 8 to 19, and the sample's pages 6 to 8 are the filed pages 20 to 22. The word-overlap figures are 40 to 79 percent; they reflect elided text and line-break differences, not a different text. The overlay is a diagnostic, not a score.

## Review of the rendered pages (every page, last render)

- Page 1: court title, caption (party column, ")" column, "Civil Action No. 22-004478-CG-N" on the middle line), title, INTRODUCTION, the first paragraphs and the start of the claims list. Pass.
- Page 2: the claims list finished, the pleading-standard paragraph, FACTUAL BACKGROUND and the first two background paragraphs. Pass.
- Page 3: background paragraphs on the Facebook post, the sticker, the vandalism and the noose; the last paragraph ends in the ellipsis that marks the elided remainder. Pass.
- Page 4: LEGAL ARGUMENT, heading I and its first three paragraphs. Pass.
- Page 5: heading II with its first paragraph, sub-heading A (single-spaced, bold) and the Surtain paragraph; III with two paragraphs; IV's opening. Pass.
- Page 6: the rest of IV's quotation, V's heading (a two-line heading with a hanging indent) and paragraph, VI with the first two paragraphs. Pass.
- Page 7: the shotgun-pleading paragraph, the Jackson paragraph, the application paragraph, CONCLUSION. Pass.
- Page 8: signature block (Date, Respectfully submitted, the attorney block) and the certificate of service with its signature line. Pass, except the open item in Known gaps 6: the signature block is alone on the page with the certificate.

## Known gaps and open choices

1. **Font.** Same as the complaint: the rule names no typeface, so EB Garamond stays (see `../complaint/README.md`, gap 1). The exemplar is set in Times New Roman; Liberation Serif would be its substitute if David wants the filed look.
2. **One exemplar.** A second motion from a different filer (e.g. *Geovera v. DNB Investments*, 1:24-cv-00003-JB-M, see `usage/SOURCE.md`) would be needed for a tier-2 judgment against 2 or 3 filers.
3. **Footnotes.** The filed memorandum has footnotes (markers 1, 2, 4 and 5 appear in the pages we read; 3 was not read). The sample omits the markers and footnote text. Footnote numbering and sizing were not tested; a footnote in a new sample would need a template check.
4. **Elided text.** The sample transcribes the introduction, the factual background through the transfer and Facebook allegations, argument I, the opening paragraphs of II (with sub-heading A and its first paragraph), III and IV, the opening and closing of V, all of VI, the conclusion and the signature. Everything else in the filed memorandum is not transcribed, including sub-sections IV.A to IV.E and most of V. Each elision inside a transcribed section is marked with "…". Nothing in the sample is a paraphrase of the filed text, but the sample is not a full copy of the memorandum.
5. **Certificate of service.** The filed copy has none (its last page is the signature block). The sample adds a generic certificate (filed with the Clerk using CM/ECF) so the template's certificate block is exercised. The wording is ours, not the exemplar's. Fed. R. Civ. P. 5(b) was not fetched in this pass.
6. **Signature alone on page 8.** The conclusion sits on page 7 and the signature block with the certificate on page 8. The filed exemplar keeps its conclusion and signature together on page 22. The template keeps the signature unbreakable; whether a clerk expects body text on the signature page is a tier-2 question, recorded as OPEN.
7. **Caption number.** The filed caption reads "Civil Action No. 22-004478-CG-N" while the RECAP stamp reads "1:22-cv-00478-TFM-N". The sample uses the caption as printed. Which number a clerk expects is not settled here; the template does not check it.
8. **Rule 7(a) statement.** The template does not check that the motion states its rule. The sample does so in its introduction and section VI.
9. **Page limit.** CivLR 7(e)'s 30-page limit is not checked by the template.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

The typst template is the reference. The docx engine is `docx/reference.docx` (built by `docx/make-reference.sh`) with the Lua filter `docx/alsd-motion-brief.lua`; it renders with `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`, which writes `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf` (LibreOffice 26.8.0.3 converts the file; 8 pages, the same count as the typst render). The fonts must be installed for LibreOffice: EB Garamond from `fonts/eb-garamond/`; `pdffonts` shows only the EB Garamond faces.

| Element | Typst | DOCX |
|---|---|---|
| Paper, margins, font, size | Letter, 1 in, EB Garamond 12 pt | same (in `reference.docx`) |
| Body spacing | 24 pt pitch, paragraphs indented 0.5 in | exact 24 pt, first line indented 0.5 in |
| Caption and cover | a grid with a ")" column; "Civil Action No." on the middle row | a borderless table with the same rows and columns |
| Headings | level 1 centered caps, 1.4 em; level 2 bold with a hanging indent, 1.2 em; level 3 bold, 1 em | level 1 centered caps, 17 pt; level 2 bold with the same hanging indent, 14.5 pt; level 3 bold, 12 pt (rounded to half points) |
| Bullets and lettered lists | bullet at 0.5 in, text at 0.9 in | the same measures |
| Block quotes | single-spaced, indented 0.5 in both sides | the same |
| Signature block and certificate of service | signature at 3.0 in; certificate kept together | the same measures; certificate kept together |
| Page numbers | centered, bottom margin | centered, bottom margin (a PAGE field) |

What differs:

- Line breaks: some lines break a word earlier or later than the typst render (the second line of the brief title, for one), so text is not in the same place on every line.
- The CONCLUSION heading and its paragraph move to page 8 in the DOCX, with the signature block and the certificate of service; the typst render keeps them on page 7. The signature block and certificate are on the last page in both engines (open item 6 above).
- The space between the title of the paper and the first heading is set by measurement of the typst render (a blank line of 16.2 pt in `alsd-motion-brief.lua`), not by a rule.

DOCX BLOCKED items: none. This folder has no `checks.yaml`, so `tools/check.sh --engine docx` does not run here; the docx PDF was reviewed page by page instead (every page of `OUTPUT-motion-brief.docx.pdf`, against the typst render). The `.docx` was converted by LibreOffice without error but was not opened in Microsoft Word, so the Word repair check is not done.
