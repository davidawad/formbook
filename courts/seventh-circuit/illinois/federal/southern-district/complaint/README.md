# ilsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Illinois (`ilsd`).
Folder: `courts/seventh-circuit/illinois/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: caption, lead-in, paragraphs 1 to 54 of the filing and one unnumbered paragraph, Count I, prayer, signature (see "Sample" below) |
| typeface | face required by rules: **none** (S.D. Ill. LR 5.1(a) and 7.1(a)(3) set 12-point type and double spacing only; no typeface named). Template face: **Times New Roman** (vendored, Liberation Serif its metric twin), the exemplar's face; the docx names the same face (`{font}`). |
| render | ok (2026-10-22): `usage/OUTPUT-complaint.typst.pdf`, 12 pages, typst 0.15.0, Times New Roman embedded, no warnings; `usage/OUTPUT-complaint.docx` and `.docx.pdf`, 12 pages |
| overlay | **fail** (2026-10-15): `tools/overlay.sh` needs `usage/*.pdf`, which is not in this snapshot (only `usage/SOURCE.md` is tracked). `usage/OVERLAY-pro-life-complaint.txt` is the earlier output and was not regenerated; no `.pdf` overlay is present. |
| pages reviewed | 11 of 11 (2026-10-15: every page rendered at 60 dpi and viewed; no template change in that pass) |
| `check.sh` | typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (325/325 lines; `params.cross_engine: gate`) (2026-10-22) |

File names: the overlay tool reads and writes `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (its fixed names), so the render and overlay carry those names rather than `<id>.pdf` and `<id>-overlay.pdf`.

## Governing rules

Sources, all read on 2026-10-14:

| ID | Rule | Kind | Requirement | Where it is in the template |
|---|---|---|---|---|
| ILSD-LR-001 | S.D. Ill. Local Rule 5.1(a) and (b) (LocalRules10-30-2023.pdf, https://www.ilsd.uscourts.gov/sites/ilsd/files/LocalRules10-30-2023.pdf) | M for pro se paper originals; counsel file electronically under (b)(1) | Paper originals on 8½ × 11 white paper, double-spaced, every page numbered consecutively. Counsel must file electronically under the court's procedures (the Electronic Case Filing rules, not read for this box). | Page size and page numbers (`ilsd-complaint.typ`: `paper: "us-letter"`, centered page numbers); double spacing (`pitch-body`). |
| ILSD-LR-002 | S.D. Ill. Local Rule 5.1(c) (same PDF) | M | Redaction of personal identifiers under Fed. R. Civ. P. 5.2 and (c)(1). | Author responsibility (A). The template does not check identifiers. |
| ILSD-LR-003 | S.D. Ill. Local Rule 7.1-1 (same PDF) | M, separate filing | Disclosure statements under Fed. R. Civ. P. 7.1 are a separate filing with the first appearance, not part of the complaint. | Not produced. |
| ILSD-LR-004 | S.D. Ill. Local Rule 24.1(a) (same PDF) | M when a constitutional question is raised | "Claim of Unconstitutionality" after the title, or the civil cover sheet box. | Not produced; the sample raises no constitutional question. |
| FRCP-10-001 | Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10; quoted 2026-10-14) | M | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." The title of the complaint names all parties. | Court name (two lines, centered), caption with party designations (`caption()`), "Case No." on the right, title centered. |
| FRCP-10-002 | Fed. R. Civ. P. 10(b) (same page) | M | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | Paragraphs are numbered by the template (`numbered()`); headings and the prayer are not numbered. |
| FRCP-8-001 | Fed. R. Civ. P. 8(a)(1)-(3) (https://www.law.cornell.edu/rules/frcp/rule_8; quoted 2026-10-14) | M | A statement of the grounds for jurisdiction; "a short and plain statement of the claim showing that the pleader is entitled to relief"; "a demand for the relief sought". | Content: the sample's Jurisdiction and Venue, Count I, and Prayer for Relief sections. The template does not check the content. |
| FRCP-8-002 | Fed. R. Civ. P. 8(d)(1) (same page) | M | "Each allegation must be simple, concise, and direct. No technical form is required." | Author content. |
| FRCP-38-001 | Fed. R. Civ. P. 38(b)(1) (https://www.law.cornell.edu/rules/frcp/rule_38; partly quoted 2026-10-14) | M when a jury is demanded | A written demand may be part of a pleading, served no later than 14 days after the last pleading directed to the issue. | `jury_demand: true` puts "DEMAND FOR JURY TRIAL" under the case number in the caption. The filing has no separate demand paragraph; the sample follows it. |
| FRCP-5.2 | Fed. R. Civ. P. 5.2 (cited through LR 5.1(c)) | M | Redaction of SSNs, taxpayer IDs, birth years, minors' names, financial-account numbers. | Author responsibility (A). |
| FRCP-12-001 | Fed. R. Civ. P. 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12; quoted 2026-10-14) | Not applied to the complaint | A defense of "failure to state a claim upon which relief can be granted" is a motion, not a pleading. | Relevant to the `motion-brief` doc type only. |
| CONV-001 | Font size and spacing for complaints | C (convention) | S.D. Ill. Local Rule 7.1(a)(3) sets 12-point type and double spacing for briefs ("no brief shall be submitted which is longer than 20 double-spaced typewritten pages in 12-point font"). No local rule was found that sets the font for a complaint. The exemplar is 12 pt Times New Roman, double-spaced. | `type-size = 12pt`, `pitch-body = 24pt`. |
| CONV-002 | Caption with ")" column | C | Both S.D. Ill. exemplars in this folder's search (Pro-Life; the defense motion in `../motion-brief`) use a caption; the Pro-Life complaint uses a ")" column, the defense motion uses a "§" column. The ")" style is the one used by the complaint. | `caption()`. |

Local practice not checked (judges' standing orders and the ECF Procedures are separate documents, not read for this box).

## Layout

Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt, ragged right, first-fit line breaks, no kerning, ligatures or hyphenation; every line a box of its pitch (24 pt body, double spacing; 13.8 pt single lines: Word's single line at 12 pt).

- Court name on two single lines, centered, a 24 pt gap, then the caption: one row per party line (names, a blank line, the designation 1.4 in in, a blank line, "v." centered, a blank line, ...), a 0.4 in column of ")" marks (one per line of text), "Case No." on the "v." row and "DEMAND FOR JURY TRIAL" (bold) a blank line below it, 0.25 in right of the marks.
- The title "COMPLAINT" centered and bold, 24 pt below the caption and 12 pt above the lead-in.
- Lead-in paragraph (frontmatter `lead_in`), unnumbered, first-line indent 0.5 in.
- Headings, single-spaced, bold, centered, kept with the next block: level 1 (`#`) 18 pt above, 6 pt below; level 2 (`##`) 12 pt above and below.
- Numbered paragraphs (plain paragraphs in the markdown): the number 0.5 in in, in a half-inch box (Word: a tab at 1 in), double spaced.
- Prayer items (`- ` lines): the typed label ("1.") in a half-inch box 0.5 in in, the text hanging at 1 in, 7.2 pt between items.
- Paragraphs starting `~ ` are unnumbered (the WHEREFORE lead-in, the note after paragraph 54).
- Footnotes 12 pt in 13.8 pt lines, 7 pt apart, 12.6 pt between text and rule; a note may split across pages (as LibreOffice splits it).
- Signature block: "Dated:" on the left, then at 3.25 in "Respectfully submitted,", the firm (bold), "By: /s/ NAME" with the counsel lines, co-counsel, and the role (italic), a blank single line between the groups. Kept on one page together with the last paragraph or prayer item.
- Page numbers centered at the foot of each page, in a 13.8 pt line (footer-descent 30 %).

## Sample

- `usage/INPUT-complaint.md` transcribes the filing: caption and counsel block (from the signature), lead-in, paragraphs 1 to 54 of the filing (Introduction, Jurisdiction and Venue, Parties, Factual Background) and the unnumbered paragraph that follows them in the filing (its "Defendant IPLA's very choice of name", sample only, marked `~ `), Count I (filing paragraphs 65 to 74, sample paragraphs 55 to 64), the Prayer for Relief in full, and the signature block. Paragraphs 56 to 64 of the filing (the "Fundraising History" section) and Counts II to IV (paragraphs 75 to 102) are not transcribed. The filing's paragraph numbers are not kept: the template numbers from 1, so the sample's numbers differ from the filing's (the overlay pairs pages, not numbers).
- The prayer is transcribed with its items as they are, but its subitems (a) to (d) and (a) to (g) are written inline in the item text, not as nested lists.
- Case names and other emphasis are roman in the transcription; the exemplar's text layer carries no italic markup, so italics were not invented.
- The left caption column reads "ILLINOIS PRO-LIFE ACTION, and / RIGHT TO LIFE ACTION," with the designation "Defendants." below; the exemplar uses a different line break in the caption, which the template does not reproduce (no forced line breaks).

## Review of the rendered pages (2026-10-22, typst and docx, 60 dpi, every page viewed)

The typst and docx renders break every line and page alike (XENG-001..003), so one review covers both; each page was viewed in both PDFs.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, caption with the ")" column, Case No. on the "v." row and the jury demand a line below (as in the exemplar), COMPLAINT, lead-in, INTRODUCTION, paragraphs 1 and 2; the number at 0.5 in and the text at 1 in, as filed. | PASS |
| 2 | exemplar p.2 | Paragraphs 2 to 9 on the 24 pt pitch. | PASS |
| 3 | exemplar p.3 | Paragraphs 10 to 14; footnote 1 (12 pt, under a short rule) starts here and runs onto page 4. | PASS |
| 4 | exemplar p.4 | Paragraphs 15 to 21; JURISDICTION AND VENUE and PARTIES centered bold; the rest of footnote 1. | PASS |
| 5 | exemplar p.5 | Paragraphs 21 to 26. | PASS |
| 6 | exemplar p.6 | FACTUAL BACKGROUND and PLAINTIFFS' TRADEMARK RIGHTS; paragraphs 27 to 33. | PASS |
| 7 | exemplar p.7 | Paragraphs 34 to 39; the two-line heading DEFENDANTS' WRONGFUL ADOPTION ... centered; paragraph 40. | PASS |
| 8 | exemplar p.8 | Paragraphs 41 to 47. | PASS |
| 9 | exemplar p.9 | Paragraphs 48 to 54 and the unnumbered paragraph after them. | PASS |
| 10 | exemplar p.14 | COUNT I and its two-line subheading; paragraphs 55 to 64. | PASS |
| 11 | exemplar p.19 (prayer) | PRAYER FOR RELIEF; WHEREFORE; items 1 to 4 hanging under their labels; the foot left free because item 5 stays with the signature. | PASS |
| 12 | exemplar p.20 (signature) | Item 5, "Dated:", the signature block at 3.25 in in groups a blank line apart, role in italics. | PASS |

Reviewed pages: 12 of 12 (typst and docx).

## Overlay

`sh tools/overlay.sh courts/seventh-circuit/illinois/federal/southern-district/complaint pro-life-complaint` writes `usage/OVERLAY-pro-life-complaint.pdf` and `.txt`. Page map: ours p.1 ↔ filed p.1, p.2 ↔ p.2, p.3 ↔ p.4, p.4 ↔ p.5, p.5 ↔ p.6, p.6 ↔ p.7, p.7 ↔ p.9, p.8 ↔ p.10, p.9 ↔ p.14, p.10 ↔ p.19, p.11 ↔ p.20. The pairing is by word overlap, so the sample's skipped paragraphs (56 to 64 and the later counts) make the middle pages pair with later filed pages. The overlay is a diagnostic: the exemplar's caption and numbering differ from the template's, and the filed text is in a different font and line length, so the two layers do not coincide on lines.

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers from different filers. Searched CourtListener's search API (`court=ilsd`, `type=r`) for complaints filed 2026-07 to 2026-10. Downloaded and checked: Kirby v. Continental Tire (3:26-cv-01028, counsel-filed, 14 pages; no body text in the text layer, only the ECF header, so unusable); Croom v. Brookhart (3:26-cv-01042, pro se, not text-searchable); Pro-Life (used). Not usable: Hoopes v. Chevron (3:26-cv-01414, complaint not in the RECAP cache). Tier 2 is therefore judged against one filer, and the complaint is not yet "up for review" by EVAL-LOOP's standard.
2. **Font.** The template uses Times New Roman (vendored; Liberation Serif its metric twin) at 12 pt, the exemplar's face. The local rules name no typeface (LR 5.1(a): "typewritten, printed, or prepared by a clearly legible duplication process"; LR 7.1(a)(3): "12-point font"). The docx was EB Garamond until fb-595.68.27; it now names the typst face.
3. **Line length and justification.** Body text is left-aligned (ragged right). The exemplar's justification was not determined from the text layer. Tier 2 or 3.
4. **Caption.** The caption is a ")" column built from a grid; the exemplar's breaks differ (the defendants' name runs onto a second line in the template). No forced line breaks are used.
5. **Paragraph numbers.** Numbered from 1 for the sample. The filing numbers paragraphs continuously from 1 to 102; a complete transcription would keep them.
6. **Page numbers.** Centered at the foot. No local rule requires a particular placement for a complaint; LR 5.1(a) requires only that every page be numbered consecutively, and it applies to paper originals.
7. **Prayer subitems.** Written inline (see Sample), not as nested lists.
8. **Documents not produced.** The civil cover sheet (JS-44), the Rule 7.1 disclosure statement (FRCP 7.1; LR 7.1-1), and the summons. Any of these may be required with the first filing.
9. **Counts and paragraphs beyond the sample.** The sample is a portion (see Sample); a filed complaint with many counts needs the same template, which has no limit on the number of counts or paragraphs.

## Engines

DOCX (`docx/`; ported to the cross-engine layout model 2026-10-22, fb-595.68.27):

- Files: `docx/reference.xml` (the Word styles: `base="xengine"` in the typst face `{font}`, Times New Roman 12 pt; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent, Body Numbered with a tab at 1 in, Body Keep / Body Numbered Keep for the last paragraph, Footnote Text 12 pt in 13.8 pt lines 7 pt apart, the page number in a 13.8 pt footer line; `fb render` builds `reference.docx` from it) and `docx/ilsd-complaint.lua` (court name, caption table, title, headings, prayer items and signature block as WordprocessingML with the typst pitches and spaces in twips; body paragraphs and the footnote written by pandoc in the styles above). No shell script and no committed `reference.docx` (were `build-reference.sh`, which set EB Garamond, and `reference.docx`).
- Output: `usage/OUTPUT-complaint.docx` and `usage/OUTPUT-complaint.docx.pdf` (LibreOffice), written by `fb check --engine docx`.
- Check (2026-10-22): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (12 pages, 325/325 lines break as in typst), gated (`eval.yaml`: `params.cross_engine: gate`).
- Page review (Gate 2 for docx): 12 of 12 pages viewed at 60 dpi beside the typst render: same lines and pages; caption, title, headings, prayer and signature as in typst.
- No TOC or TOA: the typst template has none for this doc type either.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/illinois/federal/southern-district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/southern-district/complaint pro-life-complaint
pdftoppm -r 60 -png courts/seventh-circuit/illinois/federal/southern-district/complaint/usage/OUTPUT-complaint.typst.pdf /tmp/rev/complaint/p
```

[Doc type index](../../../../../../README.md) · [Southern District](../README.md)
