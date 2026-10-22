# cob: adversary complaint

Doc type: **complaint in an adversary proceeding** (FRBP 7001, 7008(a), 7010; Fed. R. Civ. P. 10 as applied by FRBP 7010) in the United States Bankruptcy Court for the District of Colorado (`cob`). Folder: `courts/tenth-circuit/colorado/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (Complaint to Determine Dischargeability of Debt, § 523(a)(6), 5 pp., seven plaintiffs, two firms). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-adversary-complaint.md`: full transcription of the 5-page filing (caption, jurisdiction, two claims, reservation, prayer, both signature blocks). Second sample: `usage/INPUT-adversary-complaint-2.md` (pro se, existing, kept; no exemplar). |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` (7 pp.), `usage/OUTPUT-adversary-complaint-2.typst.pdf` (9 pp.), typst 0.15.0, vendored Times New Roman only, no warnings, on the shared cross-engine layout model (fb-595.68.32) |
| overlay | ok: `usage/OVERLAY-golec-adversary-complaint.pdf` and `OVERLAY-golec-adversary-complaint.txt` |
| pages reviewed | 16 of 16 on typst and docx (every page of both renders of both samples viewed side by side at 45 dpi after the last template change, 2026-10-22; the review table below was made on the earlier EB Garamond render) |

File names follow the repo tools: `render.sh` writes `OUTPUT-<id>.pdf` from `INPUT-<id>.md`, and `overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`.

## Governing rules

Rule text was read from the primary sources below on 2026-10-14. The Colorado **local** bankruptcy rules were not readable from this box (see "Not verified").

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| COB-CONSENT-001 | Fed. R. Bankr. P. 7008(a), [Cornell LII](https://www.law.cornell.edu/rules/frbp/rule_7008), fetched 2026-10-14 (page shows the 2024 amendment, eff. 2024-12-01, as its latest) | A complaint in an adversary proceeding must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | the first numbered paragraph, generated from `consent` and `proceeding` in the frontmatter (`consent-text`). A `missing` value prints a bracketed flag. |
| COB-CAPTION-001 | Fed. R. Bankr. P. 7010, [Cornell LII](https://www.law.cornell.edu/rules/frbp/rule_7010), fetched 2026-10-14: "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." | Caption conforms to the adversary caption, Official Form 416D ([uscourts.gov](https://www.uscourts.gov/file/18775/download), the form's caption layout; text read via search snippet only, not the PDF). | `caption()` and `title-block()`: debtor block left, case number and chapter right, party block and `Adv. Proc. No.` below. |
| COB-PLEAD-001 | Fed. R. Civ. P. 10(b), [Cornell LII](https://www.law.cornell.edu/rules/frcp/rule_10), fetched 2026-10-14: "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | Numbered paragraphs, consecutively. | numbered body paragraphs in `cob-adversary-complaint()`; unnumbered paragraphs marked `^` (opening, reservation, prayer). |
| COB-FORM-002 | Proxy: D.C.COLO.LCivR 10.1 (district court, not the bankruptcy LBR), text from a third-party aggregator; not re-read this session | Typewritten documents: black ink, font at least 12 point, 8½ × 11 white paper, one side. | `type-size = 12pt`; `font-family = ("Times New Roman", "Liberation Serif")` (no rule names a face: Times New Roman, the house standard; the docx names it through `{font}`) |
| COB-FORM-003 | Proxy: same district rule | Double spacing for all documents. | `pitch-double = 24pt`: every body line a 24 pt box (2 x 12 pt), the cross-engine layout model (`lib/typst/xengine.typ`); single lines (caption, headings, sub-captions, quotations, signature) 13.8 pt (`pitch-single`) |
| COB-FORM-004 | Proxy: same district rule | Top margin 1½ inches; left, right and bottom 1 inch. | `margin-top = 1.5in`, `margin-other = 1in` |
| COB-FRBP-9004 | Fed. R. Bankr. P. 9004(a), (b): cited from `../motion-brief/README.md` (COB-RULE-003, -004); not re-fetched for this doc type | Legible; caption shows court, case title, case number and adversary number, document's character. | `court`, `debtor`, `adversary`, `title` in frontmatter |

Not encoded: a certificate of service (none in the Golec exemplar; the reitmair sample has none); a table of contents or authorities (none in the exemplar; the complaint is 5 pp.); a civil cover sheet or summons (separate filings, not part of the complaint).

## Not verified (the local rules)

- **D.C.COLO.LBR 7010-1 / 9004-1** (local adversary and form-of-papers rules): not read. The Colorado local rules are not in the box's reach (see `../motion-brief/README.md`). If the bankruptcy local rules require a different font or margin, change the parameters in `typst/cob-adversary-complaint.typ` and re-render.
- **Adversary cover sheet and summons**: not part of this doc type.

## Layout

- Page 1: court title (centered bold capitals, single lines), a single line below it the debtor block (`IN RE:`, the names 0.4 in, the designation 0.8 in in; the case number and chapter in a 2.6 in column at the right), a single line below that the adversary block (each side's names and designation, a blank line between the sides) with `Adv. Proc. No.` and a fill-in line when no number is assigned, the complaint title centered bold a single line above and below, then the opening paragraph and the generated consent paragraph (paragraph 1). Every caption line is a single-spaced line block (13.8 pt); each block is never split.
- Body: double-spaced (24 pt lines), first-line indent ½ inch, the paragraph number in a half-inch box after it. Headings single-spaced, a single line above and below, sticky: level 1 (`#`) centered bold capitals, deeper levels bold at the margin. Claim sub-captions (`~ `) centered single lines, a single line below, kept with the text after them. Lists: the label `(a)`, `(b)`, ... (or a bullet) half an inch in, in a 0.4 in box, the text hanging after it. Quotations single-spaced, half an inch in on both sides.
- After the body, a double line below it: signature block (Dated left; the signatories in a 3.2 in column at the right: "Respectfully submitted," unless `lead: false`, the firm, a blank line, `By: /s/` and signer, address lines; a second signatory a double line below), single-spaced and never split. The last block of the body is kept with it.
- Footer: centered 11 pt page number.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `debtor` (`names`, `designation`, `case_number`, `chapter`), `adversary` (`case_number`, `parties` as a list of `{names, designation}`), `title`, `proceeding` (`core` or `non-core`), `consent` (`consents`, `does not consent`, or `missing`), `date`, `signature` (`lead` (default true; false omits "Respectfully submitted,"), `firm` list, `mark` (`/s/`, `By: /s/`, `By:`, or a handwritten marker), `signer`, `lines`, optional `also` list of further signatories with the same keys).
- Body: `#` = centered bold capitals heading (unnumbered), `##` = bold heading at the margin; `~ ` = centered single-spaced unnumbered lines (one per source line); `^` = unnumbered indented paragraph (opening, reservation, prayer); `1. ` lines = lettered sub-items `(a)`, `(b)`; `- ` lines = bulleted items; `> ` = a quotation; any other block = a numbered paragraph. The markdown is read as CommonMark on both engines (`^` is text, not a superscript).
- Quote every frontmatter string that contains `#` or starts with a digit (YAML).
- Not supported: footnotes (the Golec note 1 is written inline), tables, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/tenth-circuit/colorado/federal/bankruptcy-district/adversary-complaint
sh tools/render.sh $D usage/INPUT-adversary-complaint.md
sh tools/overlay.sh $D golec-adversary-complaint $D/usage/SAMPLE-golec-24-01083-adversary-complaint.pdf
```

`overlay.sh` pairs pages by word overlap. Pairs (ours → filed): 1→1, 2→2, 3→3, 4→3, 5→4, 6→5, 7→5. The overlay is a diagnostic, not a score. Our render is 7 pages against the filed 5: 13-point double-spaced type against the exemplar's 12-point pleading form, so the layers do not coincide line for line. Page 4 of ours and page 3 of the filed complaint share the claim 1 text, not the same lines.

## Visual review (Gate 2 record, made on the earlier 16-page EB Garamond render; the 16 pages of the current typst and docx renders were viewed side by side on 2026-10-22, the same content per page, no defect found)

| Doc | Page | What it is | Finding |
|---|---|---|---|
| Golec | 1 | Caption, title, intro, consent (¶1) | OK. Consent follows the unnumbered intro, as in the filing. |
| Golec | 2 | Summary of the case, ¶¶2–9 | OK. Carter's footnote-text note is inline (see gaps). |
| Golec | 3 | ¶¶9–20, jurisdiction, First Claim heading | OK. Claim sub-caption centered. |
| Golec | 4 | ¶¶20–23, lettered judgment amounts, Second Claim heading | OK. Lettered list `(a)`–`(f)`. |
| Golec | 5 | ¶¶24–31, Reservation, Prayer heading | OK. Reservation unnumbered, as in the filing. |
| Golec | 6 | Prayer items A–E | OK. Prayer items unnumbered; sub-items `i.`–`vi.` typed. |
| Golec | 7 | Signature blocks (two firms) | OK. Dated left; both firms right; "By:" lines as printed. |
| reitmair | 1 | Caption, consent-missing flag | OK. Flag prints in bold brackets, as designed. |
| reitmair | 2 | ¶¶2–13 | OK. Headings centered bold. |
| reitmair | 3 | ¶¶13–20, lettered loans | OK. Lettered list `(a)`, `(b)`. |
| reitmair | 4 | ¶¶20–28, bad-faith heading wraps | OK. Two-line heading centered. |
| reitmair | 5 | ¶¶28–35 | OK. |
| reitmair | 6 | Cause of action, Section 523(a)(2)(A) | OK. Run-in sub-headings (bold, left) and lettered list. |
| reitmair | 7 | Intent, reliance, damages | OK. |
| reitmair | 8 | ¶¶48–51, prayer, index of exhibits | OK. Bullet list for exhibits. |
| reitmair | 9 | Exhibit list end, signature | OK. Signature block, "Respectfully submitted," kept. |

## Known gaps and open choices

1. **Second filer not saved.** `EVAL-LOOP` tier 2 asks for two or three filers. Only Golec is saved here. Finding a second public cob adversary complaint (a RECAP copy with a storage path) is open; the search so far returned only orders and motions. **Needs a second exemplar.**
2. **Consent paragraph is generated.** The Golec exemplar puts the § 7008(a) sentence inside ¶12 with the core-proceeding sentence. The template generates the sentence as paragraph 1, and the transcription keeps only the core subsections sentence. Paragraph numbers in our render therefore run one ahead of the filed numbers for the rest of the document.
3. **Plural parties.** The generated consent sentence says "Plaintiff consents" even when the complaint has several plaintiffs (Golec). The template does not pluralize; a clerk would expect "Plaintiffs consent".
4. **Footnote.** The Golec filing's footnote 1 (the joint debtor in case 23-14890) is written inline in ¶2. The template does not render footnotes in the paragraph path.
5. **Debtor SSN/ITIN line.** The filing's debtor line shows "SSN / ITIN: xxx-xx-9933". Not transcribed (a privacy-redaction line, not part of the caption that Form 416D requires).
6. **Prayer sub-items.** The filing types `i.`–`vi.` under prayer item A; they are typed as unnumbered paragraphs, not a true list.
7. **Certificate of service and TOC.** None in the exemplar; not encoded.
8. **Reitmair sample.** No exemplar and no recorded source; kept as an existing sample, as its own render (9 pp.). It is not a transcription of a filed document from this court.
9. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 13.8 pt single lines, letter page with a 1.5 in top margin and 1 in elsewhere, the centered 11 pt page-number footer; the markdown read as CommonMark, as cmarker reads it) and `cob-adversary-complaint.lua` (on `lib/docx/xengine.lua`: the court title, the two caption blocks as one-row tables, the title, the consent paragraph, the numbered and unnumbered paragraphs, sub-captions, headings, lists, quotations and the signature table, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.32; were `build-reference.sh`, `reference.docx` and `cob.lua`, EB Garamond 13 pt, which also missed the `^` and `~ ` markers of the samples). Samples: `usage/OUTPUT-adversary-complaint.docx`, `-2.docx` and their `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 18 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass; both samples).
- `tools/check.sh <dir> --engine docx`: RESULT: 26 checks passed, 0 failed; XENG-001..003 PASS (adversary-complaint 7 pages, 168/168 lines; adversary-complaint-2 9 pages, 202/202 lines).
- Level-1 headings are set in capitals by the template, so a cite in one reads `§ 523(A)(2)(A)` (as the earlier template set it). Open (tier 2): whether to print headings as written.
- No latex engine for this folder.
