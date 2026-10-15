# cob: adversary complaint

Doc type: **complaint in an adversary proceeding** (FRBP 7001, 7008(a), 7010; Fed. R. Civ. P. 10 as applied by FRBP 7010) in the United States Bankruptcy Court for the District of Colorado (`cob`). Folder: `courts/tenth-circuit/colorado/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-golec-24-01083-adversary-complaint.pdf` (Complaint to Determine Dischargeability of Debt, § 523(a)(6), 5 pp., seven plaintiffs, two firms). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-golec-adversary-complaint.md`: full transcription of the 5-page filing (caption, jurisdiction, two claims, reservation, prayer, both signature blocks). Second sample: `samples/INPUT-reitmair-adversary-complaint.md` (pro se, existing, kept; no exemplar). |
| render | ok: `samples/OUTPUT-golec-adversary-complaint.pdf` (7 pp.), `samples/OUTPUT-reitmair-adversary-complaint.pdf` (9 pp.), typst 0.15.0, vendored EB Garamond, no warnings |
| overlay | ok: `samples/OVERLAY-golec-adversary-complaint.pdf` and `OVERLAY-golec-adversary-complaint.txt` |
| pages reviewed | 16 of 16 (Golec 7 and reitmair 9 rendered at 60 dpi and viewed as PNG after the last template change) |

File names follow the repo tools: `render.sh` writes `OUTPUT-<id>.pdf` from `INPUT-<id>.md`, and `overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`.

## Governing rules

Rule text was read from the primary sources below on 2026-10-14. The Colorado **local** bankruptcy rules were not readable from this box (see "Not verified").

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| COB-CONSENT-001 | Fed. R. Bankr. P. 7008(a), [Cornell LII](https://www.law.cornell.edu/rules/frbp/rule_7008), fetched 2026-10-14 (page shows the 2024 amendment, eff. 2024-12-01, as its latest) | A complaint in an adversary proceeding must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | the first numbered paragraph, generated from `consent` and `proceeding` in the frontmatter (`consent-para`). A `missing` value prints a bracketed flag. |
| COB-CAPTION-001 | Fed. R. Bankr. P. 7010, [Cornell LII](https://www.law.cornell.edu/rules/frbp/rule_7010), fetched 2026-10-14: "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." | Caption conforms to the adversary caption, Official Form 416D ([uscourts.gov](https://www.uscourts.gov/file/18775/download), the form's caption layout; text read via search snippet only, not the PDF). | `caption()` and `title-block()`: debtor block left, case number and chapter right, party block and `Adv. Proc. No.` below. |
| COB-PLEAD-001 | Fed. R. Civ. P. 10(b), [Cornell LII](https://www.law.cornell.edu/rules/frcp/rule_10), fetched 2026-10-14: "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | Numbered paragraphs, consecutively. | numbered body paragraphs in `cob-adversary-complaint()`; unnumbered lines marked `+` (opening, reservation, prayer). |
| COB-FORM-002 | Proxy: D.C.COLO.LCivR 10.1 (district court, not the bankruptcy LBR), text from a third-party aggregator; not re-read this session | Typewritten documents: black ink, font at least 12 point, 8½ × 11 white paper, one side. | `type-size = 13pt`, `font-family = "EB Garamond"` |
| COB-FORM-003 | Proxy: same district rule | Double spacing for all documents. | `line-pitch = 24pt` |
| COB-FORM-004 | Proxy: same district rule | Top margin 1½ inches; left, right and bottom 1 inch. | `margin-top = 1.5in`, `margin-other = 1in` |
| COB-FRBP-9004 | Fed. R. Bankr. P. 9004(a), (b): cited from `../motion-brief/README.md` (COB-RULE-003, -004); not re-fetched for this doc type | Legible; caption shows court, case title, case number and adversary number, document's character. | `court`, `debtor`, `adversary`, `title` in frontmatter |

Not encoded: a certificate of service (none in the Golec exemplar; the reitmair sample has none); a table of contents or authorities (none in the exemplar; the complaint is 5 pp.); a civil cover sheet or summons (separate filings, not part of the complaint).

## Not verified (the local rules)

- **D.C.COLO.LBR 7010-1 / 9004-1** (local adversary and form-of-papers rules): not read. The Colorado local rules are not in the box's reach (see `../motion-brief/README.md`). If the bankruptcy local rules require a different font or margin, change the parameters in `typst/cob-adversary-complaint.typ` and re-render.
- **Adversary cover sheet and summons**: not part of this doc type.

## Layout

- Page 1: court title (two lines, centered bold capitals), the debtor block on the left and the case number and chapter on the right, the adversary block (parties, `v.`, defendant) with `Adv. Proc. No.` blank, the complaint title in centered bold capitals, then the opening paragraph and the generated consent paragraph (paragraph 1).
- Body: double-spaced, first-line indent ½ inch. Level-1 headings (`#`) are centered bold capitals; claim sub-captions (`%`) are centered single-spaced lines.
- After the body: signature block (Dated left; firm, `By: /s/` and signer, address lines right). A second firm is added with `also` in the frontmatter, as in the Golec exemplar.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `debtor` (`names`, `designation`, `case_number`, `chapter`), `adversary` (`case_number`, `parties` as a list of `{names, designation}`), `title`, `proceeding` (`core` or `non-core`), `consent` (`consents`, `does not consent`, or `missing`), `date`, `signature` (`lead` (default true; false omits "Respectfully submitted,"), `firm` list, `mark` (`/s/`, `By: /s/`, `By:`, or a handwritten marker), `signer`, `lines`, optional `also` list of further signatories with the same keys).
- Body: `#` = centered bold capitals heading (unnumbered); `%` = centered single-spaced unnumbered lines (one per source line); `+` = unnumbered indented paragraph (opening, reservation, prayer); `1. ` lines = lettered sub-items `(a)`, `(b)`; any other block = a numbered paragraph.
- Quote every frontmatter string that contains `#` or starts with a digit (YAML).
- Not supported: footnotes (the Golec note 1 is written inline), tables, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/tenth-circuit/colorado/federal/bankruptcy-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-golec-adversary-complaint.md
sh tools/overlay.sh $D golec-adversary-complaint $D/exemplars/FILED-EXAMPLE-golec-24-01083-adversary-complaint.pdf
```

`overlay.sh` pairs pages by word overlap. Pairs (ours → filed): 1→1, 2→2, 3→3, 4→3, 5→4, 6→5, 7→5. The overlay is a diagnostic, not a score. Our render is 7 pages against the filed 5: 13-point double-spaced type against the exemplar's 12-point pleading form, so the layers do not coincide line for line. Page 4 of ours and page 3 of the filed complaint share the claim 1 text, not the same lines.

## Visual review (Gate 2 record, 16 pages, 60 dpi, viewed after the last template change)

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
9. **Check scripts not run.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`, which this doc-type folder is not. The review above is the Gate 2 equivalent for this doc type.

## Engines

**docx** (`docx/`: `build-reference.sh` makes `reference.docx` from pandoc's default; `cob.lua` builds the caption, the generated consent paragraph, the signature tables). Render: `sh tools/render.sh --engine docx <doc-folder> samples/INPUT-golec-adversary-complaint.md` writes `samples/OUTPUT-golec-adversary-complaint.docx` and `.docx.pdf` (LibreOffice 26.8.1, vendored EB Garamond).

- Matches the typst reference: court title and adversary caption (debtor block left, case number and chapter right, parties with a blank `Adv. Proc. No.`), 13 pt EB Garamond, letter, 1.5 in top margin and 1 in elsewhere, double spacing (exact 24 pt), 0.5 in first-line indent, consent paragraph as paragraph 1, lettered `(a)` to `(f)` items with the typst item spacing, both signature blocks, 11 pt centered page number. Page count 7 = typst 7. All 7 docx pages and all 7 typst pages were rasterized at 60 dpi and viewed.
- Differs from typst (tier 2 or renderer, not a mandated-form miss):
  - Page breaks: LibreOffice places exact-spaced lines and headings a few points lower, so the breaks drift by one or two lines from typst (for example docx page 3 starts at paragraph 9; typst page 3 starts mid-paragraph 9). The text order is the same, and the signature block starts page 7 in both.
  - Prayer sub-items `i.` to `vi.` are double spaced in the docx (COB-FORM-003). The typst output sets them single spaced, which looks like a cmarker default and is not a rule; the docx keeps the rule.
  - Caption: the docx party-designation lines sit about 2 to 3 pt lower than typst.
- BLOCKED: none declared. This folder has no `checks.yaml`, so there are no docx check IDs to block. `sh tools/check.sh <court-dir> --engine docx` fails at the court folder (`checks.yaml` missing), see the PR notes; it was not made to pass.
- Not checked: Microsoft Word (not available here). The `.docx` is a valid zip with well-formed XML parts and converts in LibreOffice without error.
