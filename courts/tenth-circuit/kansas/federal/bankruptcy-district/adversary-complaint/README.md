# D. Kan. Bankr. (ksb): adversary complaint

- Court: `ksb`, United States Bankruptcy Court for the District of Kansas (`courts/tenth-circuit/kansas/federal/bankruptcy-district/`)
- Doc type: `adversary-complaint`. Complaint commencing an adversary proceeding under FRBP Part VII. One self-contained folder.
- Exemplar: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (*Rebein v. Panhandle Eastern Pipe Line Company, LP*, Adv. No. 25-07014, filed 2025-04-09, 13 pages, Chapter 7 trustee's complaint). Provenance, search trail and caveats in `usage/SOURCE.md`. The file was re-downloaded from its URL on 2026-10-14.
- Sample: `usage/INPUT-adversary-complaint.md`, a transcription of the filed complaint (caption, counsel block, introduction, jurisdiction, Counts I to III with prayers, signature block, Exhibit A). The exemplar's Exhibit B (demand letter) and ECF header and footer are not transcribed.
- Status: template complete, rendered, overlaid, and every page reviewed (below). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...` and calls `ksb-adversary-complaint`. |
| `typst/ksb-adversary-complaint.typ` | Template. Parameter block at the top (type, spacing, margins, indents). Metadata checks at the top of `ksb-adversary-complaint`. |
| `usage/INPUT-adversary-complaint.md` | Markdown contract sample: YAML frontmatter, then the body. |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | `sh tools/render.sh courts/tenth-circuit/kansas/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md` (9 pages, no typst warnings; on the shared cross-engine layout model, fb-595.68.32). |
| `usage/OVERLAY-rebein-sandy-road-farms.pdf`, `.txt` | `sh tools/overlay.sh courts/tenth-circuit/kansas/federal/bankruptcy-district/adversary-complaint rebein-sandy-road-farms` (red = ours, blue = filed, black = agree; page map in the `.txt`). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

### Frontmatter contract (sample metadata)

Required by the template (a missing key is a build failure): `court` (list of lines), `debtor` (`names`, `designation`), `bankruptcy_case`, `chapter`, `caption` (list of `names` + `designation`), `title`, `signature`. Optional: `adversary_number` (printed as `Adv. Proc. No.` followed by the number; blank line when absent), `date`. `signature` takes `preamble`, `signer`, `bar`, `lines`, `role`.

## Governing rules

Checked 2026-10-14.

| Source | Rule text used | URL |
|---|---|---|
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding, except that a pleading's caption must substantially conform to Form 416. | <https://www.law.cornell.edu/rules/frbp/rule_7010> |
| Fed. R. Bankr. P. 9004(a) | The document must be clearly legible. | <https://www.law.cornell.edu/rules/frbp/rule_9004> |
| Fed. R. Bankr. P. 9004(b) | The caption must give the court's name, the case title, the case number and, if appropriate, the adversary-proceeding number, and a brief designation of the document. | same |
| Fed. R. Bankr. P. 7008(a) | Paraphrase: a complaint must say whether the proceeding is core or non-core, and a party alleging non-core must say whether it consents to final orders by the bankruptcy judge. Not checked by the template; the sample states the consent. | <https://www.law.cornell.edu/rules/frbp/rule_7008> |
| D. Kan. LBR 9004.1(a)(1) | 8½ × 11 paper; type no smaller than 12 points, set no more than an average of 12 characters per inch; double-spaced where practicable. | <https://www.ksb.uscourts.gov/sites/ksb/files/KS_LBRs_2024Dec.pdf> (p. 55; LBR as amended 12/1/24) |
| D. Kan. LBR 9004.1(a)(2) | Pagination from the first page; numbered pages include the cover and every other part. | same (p. 56) |
| D. Kan. LBR 9004.1(a)(4) (via FRBP 7010 and Official Forms) | Adversary-proceeding documents follow FRBP 7010 and the Official Forms. | same (p. 56) |
| D. Kan. LBR 7003.1(a) | An Adversary Proceeding Cover Sheet (Form B1040) must accompany the complaint. Not produced here: see Known gaps. | same (p. 50) |
| D. Kan. LBR 7003.1(b) | Adversary numbers: two-digit year, a hyphen, and a four-digit number. Topeka proceedings begin with "7" (e.g., 24-7001). The filed exemplar is 25-07014 (Topeka). | same (p. 50) |

Requirement IDs used in `ksb-adversary-complaint.typ`:

| ID | Requirement | Where | Source | Kind |
|---|---|---|---|---|
| KSB-FORM-001 | 8½ × 11 paper, margins 1 inch on all sides | `set page` | LBR 9004.1(a)(1) (paper); margin is a style choice | M (paper), C (margin) |
| KSB-FORM-002 | Type ≥ 12 pt and ≤ 12 characters per inch on average | `type-size = 16pt`, Times New Roman (vendored metric twin; no rule names a face) | LBR 9004.1(a)(1). Measured in Liberation Serif: 12.8 cpi at 14 pt, 11.2 at 16 pt | M |
| KSB-FORM-003 | Double-spaced where practicable | `pitch-double = 32pt` (2 × type size); court, caption, title, signature and tables single-spaced, `pitch-single = 18.4pt` (1.15 × type size) | LBR 9004.1(a)(1) | M |
| KSB-FORM-004 | Pages numbered from the first page, the cover included | `numbering: "1"` | LBR 9004.1(a)(2) | M |
| KSB-CAP-001 | Caption: court name, case title, case number, adversary number (blank line when not yet assigned), document designation | `caption-block` (a table of one row per single line, the party column ruled at its right) | FRBP 9004(b); FRBP 7010 and Form 416 | M |
| KSB-CAP-002 | Adversary number, when given, is printed as `Adv. Proc. No. <number>`; the sample leaves it blank, as the filer did. The number format is the author's responsibility | `adversary_number` (optional) | LBR 7003.1(b) | A |

## Overlay

`usage/OVERLAY-rebein-sandy-road-farms.pdf` (10 pages, one per page of our render) puts our render (red) over the best-matching page of the filed complaint (blue). Pages are paired by word overlap, not index.

- Pairings (word overlap, from the `.txt` map): ours p.1 ↔ filed p.1 (58%), p.2 ↔ p.2 (49%), p.3 ↔ p.2 (58%), p.4 ↔ p.3 (72%), p.5 ↔ p.4 (43%), p.6 ↔ p.4 (62%), p.7 ↔ p.5 (89%), p.8 ↔ p.6 (81%), p.9 ↔ p.7 (76%), p.10 ↔ p.7 (67%). Pairing by word overlap is only a locator; it does not show that the layouts match.
- Visible differences: the blue layer carries the ECF header and footer (`Case 25-07014 Doc# 1 Filed 04/09/25 Page n of 13`), and the filed text is a different serif, so lines wrap at different words and the red and blue text do not coincide. Our paragraphs have no space between them; the filed complaint leaves a blank line between paragraphs. See page review.
- The overlay is a diagnostic (tier 3), not a score.

## Page review (Gate 2)

Made on the earlier EB Garamond render (10 pages). The 9 pages of the current typst and docx renders (Times New Roman 16 pt, cross-engine layout model, fb-595.68.32) were viewed side by side at 60 dpi on 2026-10-22: every line and page alike; caption, headings, numbered paragraphs (the number in a half-inch box after the indent), the signature block (p. 8, kept whole with the last prayer) and Exhibit A on its own page (p. 9: the payee column twice as wide as each other one, so a payee takes two lines, not three) look professional. No defect found.

Every page of `OUTPUT-adversary-complaint.typst.pdf` was rendered at 70 dpi and viewed (10 of 10). Typst printed no warnings. Fonts: EB Garamond only (then). The "Compared with" column gives the overlay pairing. Filed pages were viewed as images only for overlay p.1 and filed p.4.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | overlay p.1 (filed p.1) | Caption, title, first paragraph. Adv. Proc. No. left blank as filed. | PASS |
| 2 | filed p.2 | Introduction ¶¶ 1-4 and the jurisdiction heading. | PASS |
| 3 | filed p.2 | ¶¶ 5-8 (jurisdiction, venue, parties). | PASS |
| 4 | filed p.3 | Count I heading and ¶¶ 9-11. The filed complaint leaves a blank line between paragraphs (seen on filed p.4); ours has none. One filer only, so this is not yet a convention (tier 3). | ACCEPTED |
| 5 | filed p.4 | ¶¶ 12-18 and the Count I prayer begins. Paragraph spacing as on p.4. | ACCEPTED |
| 6 | filed p.4 | Count I prayer continues; Count II heading and ¶¶ 19-21. | PASS |
| 7 | filed p.5 | Count II prayer; Count III heading and ¶¶ 22-23. | PASS |
| 8 | filed p.6 | Count III prayer; signature block with date, firm, signer and role. | PASS |
| 9 | filed p.7 (by overlap; Exhibit A not compared) | Exhibit A heading and payment table. Payee names wrap to three lines in the narrow column. | ACCEPTED |
| 10 | filed p.7 (by overlap) | Table continues; total row. | PASS |

Tier-2 findings (ACCEPTED): the paragraph spacing (pp. 4-5), and the Exhibit A column width (p. 9). Both rest on one exemplar, so neither is a confirmed convention; a second filer would settle it. The filed Exhibit A pages were not compared line by line.

## Known gaps

1. **One exemplar.** Tier 2 wants two or three filers; only the Rebein complaint is in `usage/`. Paragraph spacing and the choice of a 16 pt serif are judged from this one filing only.
2. **No cover sheet.** The Adversary Proceeding Cover Sheet (Form B1040, LBR 7003.1(a)) is a separate filing and is not produced.
3. **Exhibits.** The filed Exhibit B (demand letter) is not transcribed. Exhibit A is transcribed as a table only.
4. **ECF header and footer** (`Case … Doc# 1 Filed … Page n of 13`) and the scanned return-receipt card are not transcribed. The template prints no ECF footer.
5. **Consent statement and core/non-core** (FRBP 7008(a)) are in the sample but not checked by the template.
6. **Certificate of service** is not included. The complaint is served with the summons (FRBP 7004), and that certificate is a separate filing. LBR 9013.3 applies to later papers.
7. **Numbered-paragraph spacing** is the open tier-2 question above; not chased, since the rules do not dictate it.
8. **Character density** (LBR 9004.1(a)(1)) is not checked mechanically. 16 pt was chosen from Liberation Serif (Times New Roman metrics) measurements on the sample text: 11.2 cpi at 16 pt.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`). Both are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; fb-595.68.32): Times New Roman 16 pt, exact 32 pt body lines and 18.4 pt single lines, explicit spaces between blocks, headings at the body pitch and sticky, the last body block kept with the never-split signature block, exhibits on a page of their own.

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 16 pt, 32 pt body and 18.4 pt single lines, 1 in margins, the centered page-number footer; the markdown read as CommonMark with pipe tables, as cmarker reads it) and `ksb-adversary-complaint.lua` (on `lib/docx/xengine.lua`: the court lines, the caption table, the title, the numbered paragraphs, headings, the signature and the exhibit table, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (were `build-reference.sh`, `reference.docx` and `ksb.lua`, EB Garamond; the old filter looked for a `[[signature]]` marker the sample does not use, so its render carried no signature block). Samples: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (9 pages, 188/188 lines).
- No latex engine for this folder.
