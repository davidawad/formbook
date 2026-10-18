# scb (D.S.C. Bankruptcy): motion-brief

Doc type: **motion with memorandum of law, filed in an adversary proceeding** (a Rule 12(b)(1) and (6) motion to dismiss under Fed. R. Bankr. P. 7012(b), with the SC LBR 7012-1 notice to a pro se plaintiff), United States Bankruptcy Court for the District of South Carolina (`scb`).
Folder: `courts/fourth-circuit/south-carolina/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole 8-page filing transcribed (SC LBR 7012-1 notice, caption, motion, facts, argument with A./B. and 1./2. sub-headings, footnote 1, conclusion, signature) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this-dir> usage/INPUT-motion-brief.md`) |
| overlay | ok: `usage/OVERLAY-ard-zeidmans.pdf` and `usage/OVERLAY-ard-zeidmans.txt` (`sh tools/overlay.sh <this-dir> ard-zeidmans`) |
| typeface | face required: **none** (the FRBP and the SC LBR cited below name no typeface; the exemplar's Times New Roman is a filer's choice, which the rules do not require). Vendored substitute: **EB Garamond** (kept, no court face). Fit: n/a. Re-checked 2026-10-14 in the fonts pass: `pdffonts` shows only EB Garamond embedded. The SC LBR PDF could not be read through WebFetch that day, so its no-typeface reading rests on the 2026-10-14 fetch recorded below, not on a re-read. |
| pages reviewed | 8 of 8 (every page rasterized at 60 dpi and viewed after the last template change; re-viewed 2026-10-14 in the fonts pass) |

File names: as in `adversary-complaint/README.md` (the sample is `<id>.md` as the brief asked; the render and overlay use `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, which `tools/overlay.sh` requires).

## Governing rules

Sources were fetched 2026-10-14.

| Rule | Requirement | Where it lives |
|---|---|---|
| Fed. R. Bankr. P. 7012(b) (https://www.law.cornell.edu/rules/frbp/rule_7012, fetched 2026-10-14) | Fed. R. Civ. P. 12(b)-(i) applies in an adversary proceeding. | The motion's grounds: "pursuant to Federal Rule of Civil Procedure 12(b)(1) and (6)" (author text). |
| Fed. R. Bankr. P. 9013(b) (https://www.law.cornell.edu/rules/frbp/rule_9013, fetched 2026-10-14) | A motion must state its grounds with particularity and set forth the relief requested. | Author content: the opening paragraph, the argument and the conclusion. The template does not check particularity. |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | Legible; caption with court, title, case number and adversary number, and a brief designation of the document. | Cover: `court`, `bankruptcy`, `caption`, `title` frontmatter. |
| SC LBR 7012-1 (https://www.scb.uscourts.gov/pdf/Local_Rules/2026LocalRulesAugAmendments.pdf, fetched 2026-10-14; rule text in its 2025 notes) | Where a motion to dismiss is directed at a party without counsel, the motion shall contain a notice in substantially the form of the rule (the text: "A motion to dismiss is a request that one or more issues in a case be decided without holding a trial. ..."). | Template constant `notice-text`, printed first on its own page when the frontmatter has `notice` (with the `addressee` line). |
| SC LBR 9013-2(a) (same PDF) | A memorandum required or filed in support must be filed and served no later than seven days before the hearing, unless the court orders otherwise. | Not checked by the template (the memorandum is part of this filing; the filing date is the author's). |
| SC LBR 9013-3(a) (same PDF) | Every motion or pleading requesting relief shall be accompanied by a certificate of service showing names, addresses, manner and date of service. | **Not generated.** See Known gaps. |
| SC LBR 9011-4 (same PDF) | Signature as "/s/" or "s/" with the typed name; each signer's name, address, telephone, email and U.S.D.C. ID number (where applicable). | Signature block: `signature` frontmatter (the sample has all of these). |
| SC LBR 9013-1 | Motion practice "other than adversary proceedings". Does not apply here. | Not used. |

Not generated: a proposed order (SC LBR 9013-1(a) asks for one with non-adversary motions; the text read does not require one for an adversary motion) and a Table of Contents or Table of Authorities (the SC local rules read contain no such requirement and no page limit for a motion; the CAND motion template produces them because CAND's rules require them).

## Layout

- Page: US Letter, 1-inch margins, page number centered at the foot. No pleading-paper line numbers (no SC bankruptcy rule requires them).
- Caption: a ")" column, one row per line. Left: party names; right-aligned designations ("Debtors.", "Plaintiff,", "Defendant.") and an indented "v." (a left entry starting with `~` or `>`). Middle: a ")" on every row. Right: chapter, case number, adversary number. The caption is repeated on the notice page and on the motion's first page, as in the exemplar.
- Title: bold, centered, caps, under the caption.
- Body: double spacing at a 24 pt line pitch (`body-leading` 0.54em at 13 pt). Paragraphs have a 0.5 inch first-line indent.
- Facts: a `##` heading whose text starts with the frontmatter value of `numbered_section` ("FACTS") opens numbered paragraphs (1., 2., ...), which the template numbers. Argument prose is not numbered.
- Headings: `##` centered bold caps. `###` is a bold hanging sub-heading labelled A., B., ...; `####` is labelled 1., 2., ... Labels are drawn by the template.
- Lists: lettered a), b), ... (the exemplar's form).
- Footnotes: `[^label]` in the body, definitions at the end of the markdown (the template moves each definition to the chunk that cites it).
- Signature: "Respectfully submitted," on the motion (not on the notice), firm name, "/s/" and the signer's details, "Attorneys for ...", then the date line.
- The last two chunks (the conclusion heading and its paragraph) stay on one page with the signature block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `court` (list of lines); `bankruptcy` (`chapter`, `case_number`); `caption.rows` (list of `[left, right]` pairs, one per printed line, with `~` for right-aligned and `>` for indented left entries); `title`; `numbered_section` (heading prefix for numbered facts, optional); `notice` (`addressee`, optional: when present, the SC LBR 7012-1 notice is printed first); `signature` (`date`, `signer`, `firm`, `lines`, `role`).
- Body: blank-line-separated chunks. `##`, `###`, `####` headings; `>` block quotations; numbered or bulleted lists (lettered by the template); paragraphs. Footnote definitions may be anywhere in the body.
- Do not type numbers before facts or sub-headings; the template numbers them.
- Italic case names and signals with `*...*`.

## Known gaps and open choices

1. **One exemplar only.** The second filer found (*Milledge v. Carolina Acceptance*, Adv. No. 22-80001-jw, Doc 23, 7 pp., 2022, Moore Bradley Myers) is recorded in `usage/SOURCE.md`, not saved. Tier-2 comparison against two or three filers is **not** done.
2. **Typeface and size.** As in the complaint: the rules name none; EB Garamond at 13 pt; the exemplar is Times New Roman. A choice for David.
3. **Certificate of service (SC LBR 9013-3(a)) is not generated.** The rule requires one with every motion. The exemplar as filed (8 pages) has no certificate, so the filing either carried it as a separate docket entry or missed it. The template does not produce one; a filing needs its certificate added as a separate document or a template section. This is an open item for David: whether the template should produce a certificate by default.
4. **Notice page signature.** The notice's signature block falls alone on page 2, as in the exemplar (its page 2 also opens with the BEST LAW signature block). Kept as the filed layout.
5. **Paragraph numbers differ from the filing.** The filed facts are numbered 1 to 7, then the list, then 2, 3, 4 again (a restart in the filing). The template numbers the facts 1 to 12 in sequence. The sample's text is the filing's text; only the numbers differ.
6. **Title line.** The filed title fits one line at Times 12 pt; the template's bold caps at 13 pt wrap to two lines.
7. **Page numbers.** The filed copy shows only the CM/ECF header ("Case 25-80005-jd Doc 9 Filed ... Page N of 8"), which is not reproduced. The template prints a centered page number, a convention rather than a rule.
8. **Page limit.** SC LBR 9013-2 sets no page limit for an adversary motion in the 2026 text read. Not checked.
9. **Judge's standing orders** can change the form. Not reflected.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and `tools/` was not to be edited. Render and overlay were run; the review above is the page-by-page check.

## Review of the rendered pages (current PDF, 60 dpi)

- Page 1: SC LBR 7012-1 notice. Caption (")" style), notice title, "TO:" line, notice text. Pass.
- Page 2: notice signature block alone (as the filed copy). Pass, see gap 4.
- Page 3: caption, motion title (wraps to two lines), opening paragraph, "FACTS RELEVANT TO THE RELIEF REQUESTED", paragraph 1. Pass.
- Page 4: paragraphs 2-9 (the facts), the lettered list a) and b), footnote 1 at the foot. Pass.
- Page 5: list b), paragraphs 10-12, "ARGUMENT AND CITATION OF LAW IN SUPPORT", sub-heading A. with its text. Pass.
- Page 6: the end of A.; sub-heading B.; paragraphs; sub-heading 1. (hanging, two lines). Pass.
- Page 7: sub-heading 2. with its text; the conclusion of the argument. Pass.
- Page 8: "CONCLUSION" with its paragraph, "Respectfully submitted," the firm, "/s/" and the signer's details, the date. Pass.

Footnote 1 (the filer's note on "turned over") renders at the foot of page 4 with the correct marker. Italic case names and signals render in italics.

Gate 2 rows: the review above. There is no `reviews/` folder for this doc type.

## Engines

**docx** (`docx/`; `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf`, 8 pages in LibreOffice). `sh docx/make-reference.sh` builds `docx/reference.docx` (EB Garamond 13 pt; body at a 24 pt exact pitch; single lines at 19.56 pt exact; 1-inch margins; centered PAGE footer at 12 pt). `docx/scb-motion-brief.lua` builds the caption (")" column), the title line, the SC LBR 7012-1 notice page, the facts numbered inside the `numbered_section`, the A./1. headings, the lettered lists, footnotes (native), and the signature block kept with the last two blocks. Render: `sh tools/render.sh --engine docx <this-dir> usage/INPUT-motion-brief.md`.

Matches typst: typeface and size, margins, the 24 pt body pitch, the ")" caption and its rows (17 pt), the title line, the notice page (the notice text runs onto page 2 in the docx, with its signature block there; typst leaves the signature block alone on page 2, as its gap 4 records), facts numbering, A./1. heading labels, the lettered lists, the footnote, block quotations, the centered page number.

Differs:
- Court title: the docx prints the court name above the caption on the notice page and on the motion (Fed. R. Bankr. P. 9004(b)(1) requires the court's name in the caption). The typst render does not: `motion-part` and `notice-part` in `typst/scb-motion-brief.typ` call only `caption(meta)`, and `court-title` is defined but never called. This is a typst defect for David to decide; `typst/` was not edited.
- Page breaks: 8 pages in both, but the breaks fall in different places, for the same paragraph-spacing reason as the complaint (typst's paragraph-to-paragraph pitch is about 17 pt; the docx keeps 24 pt).
- Numbered facts: typst puts the number at 0.5 in and the text 0.93 in from the margin for a one-digit number (measured); the docx uses a 1.00 in tab stop, so one-digit facts sit 0.07 in further right.
- LibreOffice places the extra leading of exact line spacing above each line, so glyphs sit about 2.5 pt lower than in typst.
- Certificate of service (SC LBR 9013-3(a)): not generated in either engine (typst gap 3).
- Word: not opened (no Word on this machine). LibreOffice converted the file without error, and `unzip -tq` and `xmllint --noout` pass on every XML part.

No BLOCKED items. The court folder has no check IDs for this doc type, and no docx-only limit fails a requirement of the form.

Pages reviewed: 8 of 8 of `usage/OUTPUT-motion-brief.docx.pdf`, each viewed at 60 dpi beside the typst render (`/tmp/scb-motion-brief/typst.pdf`, not in the repo), and line positions checked with `pdftotext -bbox-layout`.

## Reproduce

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/fourth-circuit/south-carolina/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/fourth-circuit/south-carolina/federal/bankruptcy-district/motion-brief ard-zeidmans
```

[Formbook index](../../../../../../README.md) | [Court README](../README.md)
