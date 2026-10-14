# ilsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Illinois (`ilsd`).
Folder: `courts/seventh-circuit/illinois/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-pro-life-action-league-3-26-cv-01087-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-pro-life-complaint.md`: caption, lead-in, paragraphs 1 to 54 of the filing and one unnumbered paragraph, Count I, prayer, signature (see "Sample" below) |
| render | ok: `samples/OUTPUT-pro-life-complaint.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-pro-life-complaint.pdf` and `samples/OVERLAY-pro-life-complaint.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |
| `check.sh` | not run: the gates expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape (the brief forbids `tools/` edits). Gate 0 and Gate 1 were not run; the review below is the Gate 2 equivalent for this doc type. |

File names: the overlay tool reads and writes `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (its fixed names), so the render and overlay carry those names rather than `<id>.pdf` and `<id>-overlay.pdf`.

## Governing rules

Sources, all read on 2026-10-14:

| ID | Rule | Kind | Requirement | Where it is in the template |
|---|---|---|---|---|
| ILSD-LR-001 | S.D. Ill. Local Rule 5.1(a) and (b) (LocalRules10-30-2023.pdf, https://www.ilsd.uscourts.gov/sites/ilsd/files/LocalRules10-30-2023.pdf) | M for pro se paper originals; counsel file electronically under (b)(1) | Paper originals on 8½ × 11 white paper, double-spaced, every page numbered consecutively. Counsel must file electronically under the court's procedures (the Electronic Case Filing rules, not read for this box). | Page size and page numbers (`ilsd-complaint.typ`: `paper: "us-letter"`, centered page numbers); double spacing (`line-pitch`). |
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
| CONV-001 | Font size and spacing for complaints | C (convention) | S.D. Ill. Local Rule 7.1(a)(3) sets 12-point type and double spacing for briefs ("no brief shall be submitted which is longer than 20 double-spaced typewritten pages in 12-point font"). No local rule was found that sets the font for a complaint. The exemplar is 12 pt Times New Roman, double-spaced. | `type-size = 12pt`, `line-pitch = 24pt`. |
| CONV-002 | Caption with ")" column | C | Both S.D. Ill. exemplars in this folder's search (Pro-Life; the defense motion in `../motion-brief`) use a caption; the Pro-Life complaint uses a ")" column, the defense motion uses a "§" column. The ")" style is the one used by the complaint. | `caption()`. |

Local practice not checked (judges' standing orders and the ECF Procedures are separate documents, not read for this box).

## Layout

- Court name on two lines, centered, then the caption: parties on the left, a column of ")" marks, and "Case No." and "DEMAND FOR JURY TRIAL" on the right, vertically centered on the caption.
- The title "COMPLAINT" centered and bold.
- Lead-in paragraph (frontmatter `lead_in`), unnumbered.
- Headings: level 1 (`#`) centered bold caps, level 2 (`##`) centered bold with 12 pt above and below. Both are kept with the next block.
- Numbered paragraphs (plain paragraphs in the markdown), first-line indent 0.5 in, double spaced (24 pt baseline pitch; measured on pages 2 to 3 of the render).
- Lists (`- ` lines) render as hanging-indent items under the typed labels, for the prayer.
- Paragraphs starting `%` are unnumbered (the WHEREFORE lead-in).
- Footnote definitions (`[^key]: ...`) are shared with every paragraph chunk, so a reference in a numbered paragraph has its text on the same page. Footnotes are 12 pt.
- Signature block: "Dated:" on the left, then "Respectfully submitted," and the firm, "By: /s/ NAME", counsel lines, co-counsel, and the role, starting at 3.25 in. Kept on one page (`breakable: false`).
- Page numbers centered at the foot of each page.

## Sample

- `samples/INPUT-pro-life-complaint.md` transcribes the filing: caption and counsel block (from the signature), lead-in, paragraphs 1 to 54 of the filing (Introduction, Jurisdiction and Venue, Parties, Factual Background) and the unnumbered paragraph that follows them in the filing (its "Defendant IPLA's very choice of name", sample only, marked `%`), Count I (filing paragraphs 65 to 74, sample paragraphs 55 to 64), the Prayer for Relief in full, and the signature block. Paragraphs 56 to 64 of the filing (the "Fundraising History" section) and Counts II to IV (paragraphs 75 to 102) are not transcribed. The filing's paragraph numbers are not kept: the template numbers from 1, so the sample's numbers differ from the filing's (the overlay pairs pages, not numbers).
- The prayer is transcribed with its items as they are, but its subitems (a) to (d) and (a) to (g) are written inline in the item text, not as nested lists.
- Case names and other emphasis are roman in the transcription; the exemplar's text layer carries no italic markup, so italics were not invented.
- The left caption column reads "ILLINOIS PRO-LIFE ACTION, and / RIGHT TO LIFE ACTION," with the designation "Defendants." below; the exemplar uses a different line break in the caption, which the template does not reproduce (no forced line breaks).

## Review of the rendered pages (current PDF, 60 dpi, every page viewed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, caption, Case No. and jury demand on the right, COMPLAINT title, lead-in, INTRODUCTION, paragraphs 1 and 2. Caption designations were overlapping the ")" column; fixed with a left indent for the designation. | FIXED, then re-viewed: PASS |
| 2 | exemplar p.2 | Paragraphs 3 to 10 on the 24 pt grid; numbers indented 0.5 in. | PASS |
| 3 | exemplar p.3 | Paragraphs 11 to 17; "JURISDICTION AND VENUE" centered (was flush left: block shrink-wrapped the centered text, fixed with a full-width block); footnote 1 at 12 pt (was smaller). | FIXED, then re-viewed: PASS |
| 4 | exemplar p.4 | Paragraphs 18 to 22; "PARTIES" centered. | PASS |
| 5 | exemplar p.5 | Paragraphs 23 to 30; "FACTUAL BACKGROUND" and "PLAINTIFFS' TRADEMARK RIGHTS" centered; blank space at foot because the next paragraph and heading would not fit. | PASS |
| 6 | exemplar p.6 | Paragraphs 31 to 39. | PASS |
| 7 | exemplar p.7 | Heading "DEFENDANTS' WRONGFUL ADOPTION ..." two lines, centered; curly quotes in the heading (was straight quotes); paragraphs 40 to 46. | FIXED, then re-viewed: PASS |
| 8 | exemplar p.8 | Paragraphs 47 to 54; the unnumbered paragraph after them (the filing has no number there either). | PASS |
| 9 | exemplar p.9 | "COUNT I" and the two-line subheading centered; paragraphs 55 to 64 (the subheading's space below was too small; increased). | FIXED, then re-viewed: PASS |
| 10 | exemplar p.10 (prayer) | PRAYER FOR RELIEF centered; WHEREFORE with first-line indent; items 1 to 5 hanging under their labels. | PASS |
| 11 | exemplar p.20 (signature) | "Dated:" on the left; "Respectfully submitted," and the firm; "By: /s/ J. Matthew Belz #MO-61088" and counsel lines; co-counsel and role. Lines overlapped (single spacing was 2.4 pt); fixed to a 14 pt single pitch with a stack spacing. | FIXED, then re-viewed: PASS |

Reviewed pages: 11 of 11.

## Overlay

`sh tools/overlay.sh courts/seventh-circuit/illinois/federal/southern-district/complaint pro-life-complaint` writes `samples/OVERLAY-pro-life-complaint.pdf` and `.txt`. Page map: ours p.1 ↔ filed p.1, p.2 ↔ p.2, p.3 ↔ p.4, p.4 ↔ p.5, p.5 ↔ p.6, p.6 ↔ p.7, p.7 ↔ p.9, p.8 ↔ p.10, p.9 ↔ p.14, p.10 ↔ p.19, p.11 ↔ p.20. The pairing is by word overlap, so the sample's skipped paragraphs (56 to 64 and the later counts) make the middle pages pair with later filed pages. The overlay is a diagnostic: the exemplar's caption and numbering differ from the template's, and the filed text is in a different font and line length, so the two layers do not coincide on lines.

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers from different filers. Searched CourtListener's search API (`court=ilsd`, `type=r`) for complaints filed 2026-07 to 2026-10. Downloaded and checked: Kirby v. Continental Tire (3:26-cv-01028, counsel-filed, 14 pages; no body text in the text layer, only the ECF header, so unusable); Croom v. Brookhart (3:26-cv-01042, pro se, not text-searchable); Pro-Life (used). Not usable: Hoopes v. Chevron (3:26-cv-01414, complaint not in the RECAP cache). Tier 2 is therefore judged against one filer, and the complaint is not yet "up for review" by EVAL-LOOP's standard.
2. **Font.** The template uses EB Garamond (vendored, OFL) at 12 pt, not Times New Roman. The rule sets 12 pt for briefs; EB Garamond at 12 pt looks smaller than the exemplar's Times at 12 pt. Only EB Garamond is vendored in `fonts/`; a Times-metric font would need a vendored file, which this box may not add.
3. **Line length and justification.** Body text is left-aligned (ragged right). The exemplar's justification was not determined from the text layer. Tier 2 or 3.
4. **Caption.** The caption is a ")" column built from a grid; the exemplar's breaks differ (the defendants' name runs onto a second line in the template). No forced line breaks are used.
5. **Paragraph numbers.** Numbered from 1 for the sample. The filing numbers paragraphs continuously from 1 to 102; a complete transcription would keep them.
6. **Page numbers.** Centered at the foot. No local rule requires a particular placement for a complaint; LR 5.1(a) requires only that every page be numbered consecutively, and it applies to paper originals.
7. **Prayer subitems.** Written inline (see Sample), not as nested lists.
8. **Documents not produced.** The civil cover sheet (JS-44), the Rule 7.1 disclosure statement (FRCP 7.1; LR 7.1-1), and the summons. Any of these may be required with the first filing.
9. **Counts and paragraphs beyond the sample.** The sample is a portion (see Sample); a filed complaint with many counts needs the same template, which has no limit on the number of counts or paragraphs.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/illinois/federal/southern-district/complaint samples/INPUT-pro-life-complaint.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/southern-district/complaint pro-life-complaint
pdftoppm -r 60 -png courts/seventh-circuit/illinois/federal/southern-district/complaint/samples/OUTPUT-pro-life-complaint.pdf /tmp/rev/complaint/p
```

[Doc type index](../../../../../../README.md) · [Southern District](../README.md)
