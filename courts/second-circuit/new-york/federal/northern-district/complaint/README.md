# nynd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of New York (`nynd`).
Folder: `courts/second-circuit/new-york/federal/northern-district/complaint/` (self-contained; the court root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer: plaintiff's counsel Capezza Hill, LLP; see `usage/SOURCE.md`; re-fetched from the RECAP URL 2026-10-15, 28 pages) |
| sample md | `usage/INPUT-complaint.md`: caption and lead-in, preliminary statement, parties, jurisdiction and venue, factual allegations I to V, first cause of action, prayer, jury demand, signature block (filed ¶¶ 1 to 61 and 140 to 149; see Known gaps 5) |
| typeface | face required: none (L.R. 10.1 names no typeface; checked against the 2025 edition text 2026-10-15). The template sets **Times New Roman** (vendored), the house standard and the exemplar's face, on typst and docx alike (fb-595.68.26; was EB Garamond). |
| render | ok (re-rendered 2026-10-22): `usage/OUTPUT-complaint.typst.pdf`, 9 pages, vendored Times New Roman only, no warnings, on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.26) |
| overlay | ok (re-run 2026-10-15): `usage/OVERLAY-golub-complaint.pdf` and `OVERLAY-golub-complaint.txt` (the tools' names; see Known gaps 11) |
| pages reviewed | 9 of 9 on typst and docx (every page rendered at 40 dpi and viewed side by side after the last template change, 2026-10-22) |

## Governing rules

Primary source: N.D.N.Y. Local Rules of Practice (2025 edition, effective 2025-01-01), <https://www.nynd.uscourts.gov/sites/nynd/files/local_rules/Local%20Rules%202025_Final.pdf>. Fetched and text-extracted 2026-10-14. The 10.1 header reads "Amended January 1, 2024"; 5.1 reads "Amended January 1, 2025". The search index also lists a 2026 edition that I did not check; re-verify against it before any filing.

Federal rule text: Fed. R. Civ. P. 10(a) and 10(b), <https://www.law.cornell.edu/rules/frcp/rule_10>, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D.N.Y. L.R. 10.1(a)(1) | Text, including footnotes, at least 12-point type. | `type-size = 12pt` (all text, caption, signature, footer). |
| L.R. 10.1 (no typeface) | No face, family or font is named anywhere in L.R. 10.1 or 7.1 (full-text search of the 2025 edition, 2026-10-15). Only "12-point type" in (a)(1). | `font-family = ("Times New Roman", "Liberation Serif")`, the house standard. |
| L.R. 10.1(a)(2) | One-inch margins on all four sides. | `margin = 1in`. |
| L.R. 10.1(a)(3) | Text in the body double-spaced. | `body-leading = 1.35em` (24 pt baseline pitch at 12 pt; measured in the render). |
| L.R. 10.1(a)(4) | Block quotations and footnotes may be single-spaced. | `show quote.where(block: true)` and `footnote.entry` at `single-leading`. |
| L.R. 10.1(a)(7) | Pages consecutively numbered. | Footer: centered arabic page number, every page. |
| L.R. 10.1(b)(1) | 8½ × 11 inch paper (paper filings; the e-filed PDF follows the same page size). | `paper: "us-letter"`. |
| L.R. 10.1(c)(1) | Caption: title of the Court, title of the action, civil action number, the assigned judge's initials, and the name of the paper. | `caption(meta)`; `judges` is required (assert). |
| L.R. 10.1(c)(2) | Filer identification: signature, typed name, bar roll number, office address, telephone, e-mail of the attorney. | `signature-block(sig)`; `bar_roll` is required for each signer (assert). |
| L.R. 5.1(a) | Pleadings in the form prescribed by L.R. 10.1. | Whole template. |
| L.R. 3.2 | Civil cover sheet submitted with the complaint. | Not produced: a separate filing. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | As L.R. 10.1(c)(1) above. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph 1, 2, ... (headings, lists and marked paragraphs are not numbered). |
| Fed. R. Civ. P. 8(a), 38(b) | Short plain statement; jury demand. | Content of the sample only; the template does not check it. Rule 8(a) and 38(b) were not fetched in this pass. |

No page limit applies to complaints in the N.D.N.Y. Local Rules (L.R. 7.1 limits motion papers only).

## Layout

- Caption: court title at the top left (two single-spaced lines). A double line below it, the party block in a left column, a rule under it, the designations indented, "-against-" between parties. Right column: the case number with the judges' initials, then, three blank single lines below, the title of the paper in bold capitals (level with the party lines). Never split.
- No pleading-paper line numbers or margin rules. L.R. 10.1 does not require them and the exemplar has none (this differs from the cand complaint template).
- Body: numbered paragraphs with a 0.5 inch first-line indent (number, then the text one tab later). Headings at the body pitch (24 pt lines), bold, kept with the next block: level 1 centered capitals, level 2 centered, level 3 at the margin. The last block of the body is kept with the signature block. A chunk starting with `<!-- unnumbered -->` (an HTML comment, which the template strips) is an unnumbered indented paragraph (the prayer lead-in and the jury-demand sentence). A chunk wrapped in parentheses is a centered, unnumbered subtitle.
- Prayer items: markdown list, lettered a., b., ... by the template.
- Signature block, a double line below the body, single-spaced (13.8 pt lines) and never split: date at the left; firm name in bold capitals, signature line, each signer's typed name, bar roll number and e-mail, then office address, telephone, and the role line in italics, at the right.
- Footer: centered page number only. No header: the CM/ECF header (case number, document number, filing date) is added by the court's system at filing and is not reproduced.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `judges`; `caption.parties` (list of `{names, designation}`); `caption.between` (`-against-`); `brief_title`; `lead_in` (optional); `signature` (`dated`, `firm`, `signers` list of `{name, bar_roll, email}`, `address` lines, `phone`, `role`).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) headings; `1.` lines for lettered items (consecutive, no blank lines between them); a plain paragraph (numbered); `<!-- unnumbered --> ...` (unnumbered); `> ` block quotations (single-spaced, an inch in on both sides); `(...)` for a centered subtitle.
- The sample does not carry paragraph numbers; the template numbers them.
- Not supported: tables, raw typst, and footnotes (not used here; the template's footnote style is set but not exercised in a complaint).

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP tier 2 asks for 2 or 3 filers. The CourtListener API search (`type=r`, `court=nynd`, complaints filed 2026) returned a number of complaints, most pro se with no text layer or without a clear filer; one further attorney-filed complaint was not collected. Tier 2 is therefore not judged against two filers yet. This is an open item.
2. **Bar roll numbers.** The filed exemplar's signature block has no bar roll number, but L.R. 10.1(c)(2) requires one. The rule governs. The sample carries `Bar Roll No. [to be supplied]` for each signer, and the template refuses to render without one (checked: render fails with the L.R. 10.1(c)(2) message).
3. **Second signer's e-mail.** Not in the exemplar's text layer; the sample says `[e-mail to be supplied]`.
4. **Typeface.** The rule names no face: L.R. 10.1(a)(1) requires only "a minimum of 12-point type". The template sets Times New Roman, the house standard (David, 2026-10-17) and the filing's face, at 12 pt.
5. **Paragraph numbers.** The template numbers paragraphs consecutively. The sample's paragraphs 1 to 61 match the filing's numbers, but the first cause of action (filed ¶¶ 140 to 149) renders as ¶¶ 62 to 71, and its incorporation paragraph says "paragraphs 1 through 123 above" as filed. This is a sample gap (the filing's numbering is not transcribed past ¶ 61), not a template defect.
6. **Footnote in ¶ 142** (a news link) is not transcribed.
7. **Alignment.** Body text is ragged right. The exemplar's justification could not be read from its text layer; this is a tier 2 or 3 choice and is not asserted.
8. **Judges.** The exemplar shows two judges, "(ECC/DJS)". The template takes the initials as one string.
9. **Separate filings not produced:** the civil cover sheet (L.R. 3.2), the summons and the Fed. R. Civ. P. 7.1 disclosure statement.
10. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.
11. **Overlay names.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`, and `tools/render.sh` writes `OUTPUT-<id>.pdf` from `INPUT-<id>.md`. The brief's `<id>.md` and `<id>-overlay.pdf` names were not used, to match the tools and the repo's role-prefix convention.
12. **Overlay pairing** is by word overlap and skips pages the sample does not contain (for example ours p.7 pairs with filed p.18). The overlay is a diagnostic, not a score.
13. **Negative tests** (run 2026-10-14, each exits 1 with the rule message): empty `bar_roll`; missing `judges`. The memorandum folder has the matching tests.

## Review of the rendered pages (Gate 2 equivalent)

Made on the earlier 8-page EB Garamond render (2026-10-15). The 9 pages of the current typst and docx renders were viewed side by side on 2026-10-22: the same caption, headings, paragraphs and signature block, now 9 pages (Times New Roman, headings at the body size); page 9 holds the DEMAND FOR JURY TRIAL heading and sentence with the signature block. No defect found.

- Page 1: caption with court title, case number and judges' initials, party block with rule, bold title in the right column, unnumbered lead-in, PRELIMINARY STATEMENT and ¶ 1, then the PARTIES heading with ¶¶ 2 and 3 at the foot. Pass.
- Page 2: ¶¶ 4 to 15; JURISDICTION AND VENUE, FACTUAL ALLEGATIONS, "I. Background" heading kept with ¶ 13. Pass.
- Page 3: ¶¶ 16 to 27; "II. Defendant Tim Coll's Smear Campaign" heading. Pass.
- Page 4: ¶¶ 28 to 37; "III. May 2023 Resolution" heading kept with ¶ 37. Pass.
- Page 5: ¶¶ 38 to 49; "IV. The Commissioner of Public Safety Position" heading. Pass.
- Page 6: ¶¶ 50 to 61; "V. Plaintiff's Sink Clog"; FIRST CAUSE OF ACTION heading and subtitles moved to the next page with ¶ 62 (no heading left at a page foot after the fix). Pass.
- Page 7: FIRST CAUSE OF ACTION, "Malicious Prosecution under 42 U.S.C. § 1983", "(Against Defendants Coll and Veitch)", ¶¶ 62 to 70. Pass.
- Page 8: ¶ 71; WHEREFORE with lettered items a. to d.; DEMAND FOR JURY TRIAL; date; signature block with signers, bar roll placeholders and address. Pass.

[Formbook index](../../../../../../README.md)

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

docx (`docx/`): `reference.xml` (`base="xengine"`: the typst template's face through `{font}`, 12 pt, exact 24 pt body lines, 13.8 pt single lines, 1 in margins, the centered page-number footer; `pandoc-from` CommonMark as cmarker reads it, so a literal `*` stays literal) and `nynd-complaint.lua` (on `lib/docx/xengine.lua`: the court title, the caption table with the rule under the party column, the lead-in, numbered paragraphs (number at 0.5 in, tab to 1 in), headings, subtitles, unnumbered paragraphs, lettered prayer items, quotations and the signature table, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.26). Output: `usage/OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice; not opened in Word).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (9 pages, 225/225 lines).
- No latex engine for this folder.
