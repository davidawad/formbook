# alsd: motion-brief

Doc type: **motion to dismiss with memorandum** (a Rule 12(b) motion and its supporting brief, which may be one document under Civ. L.R. 7(b)) in the United States District Court for the Southern District of Alabama (`alsd`).
Folder: `courts/eleventh-circuit/alabama/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (caption, title, introduction, factual background, argument I to IV, V (partly), VI, conclusion, signature, certificate of service added by us; several passages elided, see Known gaps) |
| typeface | face required: none (S.D. Ala. Gen. L.R. 5(a)(2) asks for "a plain, Roman style (or similar) font"; no face is named). Substitute: **Times New Roman**, the house standard (`docs/FONTS.md` rule 6; EB Garamond until fb-595.68). Fit: n/a. See Known gaps 1. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, pinned Times New Roman only, no warnings; `pdffonts` shows `TimesNewRomanPSMT`, `-BoldMT`, `-ItalicMT` embedded (no other face; EB Garamond on the 2026-10-14 re-render, before fb-595.68) |
| overlay | ok: `usage/OVERLAY-shell-motion-brief.pdf` and `OVERLAY-shell-motion-brief.txt` (`tools/overlay.sh`), re-run 2026-10-14 against the RECAP copy of the exemplar (the exemplar PDF is not stored in the folder; see `usage/SOURCE.md`) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed on 2026-10-14, after the typeface check; the earlier EB Garamond render, before fb-595.68) |

File names follow the repo's tools (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`); `<id>` is `shell-motion-brief`.

## Governing rules

Primary source: S.D. Ala. Local Rules (Order Promulgating Local Rules, "Effective August 1, 2015"), PDF at https://www.alsd.uscourts.gov/sites/alsd/files/local-rules.pdf, fetched 2026-10-14. The same PDF is the source for the complaint's rules; see `../complaint/README.md`. Later amendments were not checked.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Ala. Gen. L.R. 5(a)(1) | 8½ × 11 paper; double-spaced text (quotations of more than two lines may be single-spaced); headings and footnotes may be single-spaced; margins of at least 1 inch on all four sides; page numbers only in the margins. | `margin = 1in`, `pitch.body` (24 pt), `pitch.single` (13.8 pt) for block quotes, headings, signature and certificate; footer page number in the bottom margin. |
| S.D. Ala. Gen. L.R. 5(a)(2) | "A plain, Roman style (or similar) font"; case names italic or underlined; 12 point or larger, footnotes included. Names no typeface. | `font-family` = Times New Roman (the house standard, `docs/FONTS.md` rule 6: any plain roman face satisfies the rule), `size: 12`; case names italic from `*...*`. See Known gaps 1. |
| S.D. Ala. Gen. L.R. 5(a)(3) | Signature line, with the typed name, address and telephone of every attorney of record directly beneath. | `typst/layout.yaml`. |
| S.D. Ala. Civ. L.R. 7(a) | Every motion must state the statute, rule, or legal or equitable principle under which it is made. | Not checked by the template. The sample states the rule in its introduction and in section VI (Rule 12(e)); the Rule 12(b)(6) basis appears in the argument, not in a separate statement. |
| S.D. Ala. Civ. L.R. 7(b) | A Rule 12(b) motion must be supported by a brief; the brief may be included within the body of the motion. | The document is the brief; the title says "Memorandum of Law in Support of Its Motion". |
| S.D. Ala. Civ. L.R. 7(e) | Principal briefs at most 30 pages, excluding caption, cover page, table of contents, table of authorities and signature block. | Not checked by the template. The sample (8 pages) and the filed exemplar (22 pages) are within the limit. |
| Fed. R. Civ. P. 12(b)(6); 12(e) | Failure to state a claim; motion for a more definite statement of a pleading "so vague or ambiguous that the party cannot reasonably prepare a response". Fetched https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14. | Argument I to V (12(b)(6)) and section VI (12(e)) in the sample. |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs, each limited to a single set of circumstances (quoted in the exemplar's section VI). Fetched https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | Quoted in the sample; not a template rule (briefs are not numbered). |
| Fed. R. Civ. P. 5(b) | Certificate of service for a paper served through the court's electronic system. Not fetched in this pass. | `typst/layout.yaml`: added to the sample because the exemplar has none. See Known gaps 5. |

## Layout

- Court title on the first page, centered and bold (three lines, single-spaced); caption as in the complaint (party column, ")" column, "Civil Action No." on the middle line).
- Title of the paper centered and bold under the caption.
- Body double-spaced (24 pt pitch, `pitch.body`). Paragraphs are unnumbered with a 0.5 inch first-line indent.
- Headings: level 1 centered bold caps (INTRODUCTION, FACTUAL BACKGROUND, LEGAL ARGUMENT, CONCLUSION); level 2 bold at the left with a hanging indent for the roman numeral; level 3 bold, indented, for the lettered sub-heading. Headings are single-spaced and stay with the text after them.
- Lists: bulleted in the sample (the exemplar's claim list); lettered if the markdown is numbered.
- Block quotes single-spaced, indented 0.5 inch on both sides.
- Signature: "Date:" on the left; "Respectfully submitted," and the attorney block in the right half of the page.
- Certificate of service: centered bold heading, a paragraph and the signature line.

## Markdown contract (for samples)

See "Engines" below: the frontmatter fields are those the layout (`typst/layout.yaml`) reads. Body: markdown (headings `#` to `####`, paragraphs, lists, block quotations, footnotes, `*italics*`), set by the shared document model.

## Overlay (red/blue)

`usage/OVERLAY-shell-motion-brief.pdf` (measured on the earlier EB Garamond render, before fb-595.68) pairs our eight pages with the filed pages by shared words. The map in `OVERLAY-shell-motion-brief.txt`:

```
ours p.1 filed p.1   ours p.2 filed p.3   ours p.3 filed p.4   ours p.4 filed p.6
ours p.5 filed p.7   ours p.6 filed p.20  ours p.7 filed p.21  ours p.8 filed p.22
```

The pairing is not in order because the sample elides the exemplar's pages 8 to 19, and the sample's pages 6 to 8 are the filed pages 20 to 22. The word-overlap figures are 40 to 79 percent; they reflect elided text and line-break differences, not a different text. The overlay is a diagnostic, not a score.

## Review of the rendered pages (every page, last render; the earlier EB Garamond render, before fb-595.68)

- Page 1: court title, caption (party column, ")" column, "Civil Action No. 22-004478-CG-N" on the middle line), title, INTRODUCTION, the first paragraphs and the start of the claims list. Pass.
- Page 2: the claims list finished, the pleading-standard paragraph, FACTUAL BACKGROUND and the first two background paragraphs. Pass.
- Page 3: background paragraphs on the Facebook post, the sticker, the vandalism and the noose; the last paragraph ends in the ellipsis that marks the elided remainder. Pass.
- Page 4: LEGAL ARGUMENT, heading I and its first three paragraphs. Pass.
- Page 5: heading II with its first paragraph, sub-heading A (single-spaced, bold) and the Surtain paragraph; III with two paragraphs; IV's opening. Pass.
- Page 6: the rest of IV's quotation, V's heading (a two-line heading with a hanging indent) and paragraph, VI with the first two paragraphs. Pass.
- Page 7: the shotgun-pleading paragraph, the Jackson paragraph, the application paragraph, CONCLUSION. Pass.
- Page 8: signature block (Date, Respectfully submitted, the attorney block) and the certificate of service with its signature line. Pass, except the open item in Known gaps 6: the signature block is alone on the page with the certificate.

## Known gaps and open choices

1. **Font.** Same as the complaint: the rule names no typeface, so the template uses the house standard, Times New Roman (`docs/FONTS.md` rule 6; see `../complaint/README.md`, gap 1), the exemplar's face too. It kept EB Garamond until fb-595.68.
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

On the generic federal district brief since fb-595.17.4: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst (reference) | `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages | 11 checks passed, 0 failed | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` | 15 checks passed, 0 failed | PASS (216/216 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | 16 checks passed, 0 failed | PASS (216/216 lines) |

Frontmatter: `division`, `case_label` (default "CIVIL ACTION NO."), `case_number`, `caption.parties` (`names`, `designation`), `brief_title`, `signature` (`date`, `blocks`), `service` (`text`, `signature`). The move changed the caption to the form of the exemplar of the same id (the parties closed by a rule at their right and foot instead of a column of ")"; the title underlined); the page limit of Civ. L.R. 7(e) (30 pages) is now checked (`eval.yaml` `params.page_limit`). The list labels stand at the margin in a half-inch box (the base), not half an inch in (tier 3).

