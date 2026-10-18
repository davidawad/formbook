# D. Minn. bankruptcy court (mnb): adversary complaint

- Court: `mnb`, United States Bankruptcy Court, District of Minnesota (`courts/eighth-circuit/minnesota/federal/bankruptcy-district/`)
- Doc type: `adversary-complaint`, the complaint that commences an adversary proceeding (Fed. R. Bankr. P. 7001).
- Exemplar: `usage/SAMPLE-mnb-adversary-complaint-magnetation1705086complaint.pdf` (*Magnetation LLC v. Northern Minnesota Water Conditioning, Inc.*, Adv. No. 17-05086, filed 2017-05-03, 13 pages; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-mnb-adversary-complaint-magnetationcomplaint.md` (transcribed from the exemplar).
- Status: template and sample kept from master; the README, exemplar, render, and overlay were added in this pass. Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `mnb-adversary-complaint`. |
| `typst/mnb-adversary-complaint.typ` | Template. Caption (debtor and adversary boxes), numbered paragraphs, lettered lists, signature block from frontmatter. |
| `usage/INPUT-mnb-adversary-complaint-magnetationcomplaint.md` | Markdown contract sample: YAML frontmatter (title, lead-in, caption, date, signature) plus the body. |
| `usage/OUTPUT-mnb-adversary-complaint-magnetationcomplaint.typst.pdf` | `sh tools/render.sh courts/eighth-circuit/minnesota/federal/bankruptcy-district/adversary-complaint usage/INPUT-mnb-adversary-complaint-magnetationcomplaint.md` (11 pages, typst 0.15.0, no warnings). |
| `usage/OVERLAY-magnetation-complaint.pdf`, `.txt` | `sh tools/overlay.sh <this folder> magnetation-complaint`. Red = our render, blue = filed exemplar, black = both agree. |
| `usage/` | The filed complaint and `SOURCE.md`. |

## Governing rules

Primary sources are the D. Minn. local rules and the Federal Rules of Bankruptcy Procedure. The local-rules text was read on 2026-10-14 from the complete compilation, "MNB Local Rules Complete", stated as effective September 3, 2025: <https://www.mnb.uscourts.gov/sites/mnb/files/MNB%20Local%20Rules%20Complete.pdf>. The individual LBR 9004-1 PDF (renumbering amendment of July 17, 2023) is <https://www.mnb.uscourts.gov/sites/mnb/files/9004-1.pdf>. The FRBP text was read on 2026-10-14 from the Cornell LII copies (<https://www.law.cornell.edu/rules/frbp/rule_7010>, `rule_9004`, `rule_7008`, `rule_9011`). Those are secondary copies; they were not cross-checked against the uscourts.gov PDFs in this box.

| Rule | Requirement | Where the template or sample uses it |
|---|---|---|
| Fed. R. Bankr. P. 7010 (as restyled, eff. Dec. 1, 2024) | Pleading in an adversary proceeding: Fed. R. Civ. P. 10 applies, except the caption must substantially conform to Form 416 | `caption()`: court title, debtor box, adversary box; Official Form 416A layout as the template comment states |
| Fed. R. Civ. P. 10(b) (through Rule 7010) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances | `allegations()`: each blank-line-separated chunk is one numbered paragraph |
| Fed. R. Bankr. P. 7008(a) | The complaint states whether the proceeding is core or non-core (Advisory Committee Note, 1987) | Paragraph 5 of the sample. The template does not check it. |
| Fed. R. Bankr. P. 9004(a) | Legibility; commonly used abbreviations acceptable | Type size 12 pt, EB Garamond, no colour |
| Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number and adversary number, brief designation of the document | Caption block |
| Fed. R. Bankr. P. 9011(a) | Signature by the attorney | `signature-block()`, with the `/s/` signature from frontmatter |
| D. Minn. LBR 9004-1(a) | All documents presented for filing, except trial exhibits, print on 8½ × 11 letter paper | `page-w`, `page-h` = 8.5 × 11 in |
| D. Minn. LBR 9004-1(b)(2) | Documents produced on the attorney's computer are printed directly to PDF, not scanned | Build path: typst to PDF |
| D. Minn. LBR 9011-1(a) | Signature block states the signer's name, address, email, telephone, and attorney bar registration number | Supplied by the sample's signature lines (name, SBN, address, telephone, fax, email). The template does not check it. |

There is no D. Minn. local rule on the adversary-complaint caption or on margins, and the rules leave type face and size open. The margins (1 in), the 12 pt size, and the double spacing (24 pt pitch) follow the filed exemplar. They are named parameters at the top of `mnb-adversary-complaint.typ`.

No D. Minn. local rule in the complete compilation numbers 7008 or 7010 (the 7000 series has only 7004-1, 7005-2, 7007-1, 7018-1, 7037-1, 7041-1, 7054-1, 7055-1, 7056-1, 7067-1, 7069-1). The adversary caption therefore rests on the federal rules alone.

## Overlay

`usage/OVERLAY-magnetation-complaint.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. The overlay is a diagnostic, not a score. Pairings from the last run:

- Sample p.1 ↔ filed p.1 (67%): caption and opening paragraph line up.
- p.2 ↔ p.2 (48%) and p.3 ↔ p.4 (48%): jurisdiction and parties. The filed paragraphs flow differently, so the pages drift.
- p.4-p.9 ↔ filed pp. 5-11 (53-70%): facts, the counts.
- p.10 ↔ p.12 (90%), p.11 ↔ p.13 (80%): prayer, signature block.

The exemplar has no Exhibit A (the statement of account); see Known gaps.

## Page review (Gate 2)

Every page of `OUTPUT-mnb-adversary-complaint-magnetationcomplaint.typst.pdf` was rendered at 70 dpi and viewed (11 of 11) as PNG; the overlay sheets were viewed as contact sheets (all 11 pages present). The comparison against the filed pages is the overlay pairing above; no separate side-by-side images were made in this pass.

| Page | Content | Result |
|---|---|---|
| 1 | Caption (debtor and adversary boxes), title, opening paragraph, "NATURE OF THE CASE", ¶1 | OK |
| 2 | ¶¶2-9: jurisdiction and venue, procedural background | OK |
| 3 | "THE PARTIES", ¶¶10-13 | OPEN: about a third of the page is blank below ¶13. "FACTUAL BACKGROUND" and ¶14 are one unbreakable block (heading kept with its paragraph), so they move to p.4 as a unit. Fix: allow ¶14 to break, keeping only the heading sticky. |
| 4 | "FACTUAL BACKGROUND", ¶¶14-17 | OK |
| 5 | ¶¶18-21 | OK |
| 6 | ¶¶22-26 | OK |
| 7 | "CLAIMS FOR RELIEF", Count I, ¶¶27-35 | OK |
| 8 | ¶¶35-39, Count II (sub-paragraphs A-C), Count III heading with ¶40 | OK |
| 9 | ¶¶41-49: Counts III-V | OK |
| 10 | ¶50, "PRAYER FOR RELIEF", items A and B | ACCEPTED: blank below item B. The last prayer item and the signature block stay together on p.11 (the template keeps the signature with the last chunk, by design). |
| 11 | Prayer item C; signature block (Dated, /s/, counsel's name, SBN, firm, address, telephone, fax, email) | OK |

Tier-2 findings (OPEN or ACCEPTED): the page-3 gap above (OPEN); the page-10 gap above (ACCEPTED).

## Known gaps

1. One exemplar only. `docs/EVAL-LOOP.md` asks for 2 or 3 filed exemplars from different filers before tier 2 can be judged, and says a court with fewer than 2 cannot finish tier 2. Tier 2 is not finished for this doc type.
2. Exhibit A (the statement of account, referenced in ¶21) is not in the exemplar PDF and is not transcribed. The rendered sample shows the reference only.
3. The exemplar is a 2017 filing. It predates the 2023 local-rule renumbering and the 2024 restyling of Rules 7010 and 9004. The template follows the current text; the filing was used only for layout choices the rules leave open.
4. The filed complaint carries no certificate. The summons (Fed. R. Bankr. P. 7004) is a separate form and is not part of this template.
5. Page 3's gap (above) is a template choice, not a rule. It is OPEN.

## Engines

| Engine | Folder | Output in `usage/` | State |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-mnb-adversary-complaint-magnetationcomplaint.typst.pdf` | template, unchanged by the docx work; no PDF in the snapshot |
| latex | `latex/` | none | not built |
| docx | `docx/` | `OUTPUT-mnb-adversary-complaint-magnetationcomplaint.docx`, `OUTPUT-mnb-adversary-complaint-magnetationcomplaint.docx.pdf` | built (below) |

The docx build: `sh tools/render.sh --engine docx adversary-complaint usage/INPUT-mnb-adversary-complaint-magnetationcomplaint.md`. It runs `docx/render.sh` (pandoc, the Lua filter `docx/mnb-adversary-complaint.lua`, and `docx/reference.docx`). `docx/make-reference.sh` rebuilds the reference. The PDF is LibreOffice 26.8.1 with the vendored fonts only.

What matches the typst output: letter paper with 1 in margins; EB Garamond 12 pt, embedded and the only font; body double-spaced at a 24 pt line pitch with a half-inch first-line indent; numbered paragraphs (numbers typed into the text, as the typst template does) and an unnumbered WHEREFORE; the caption (court title, debtor and adversary boxes with 0.75 pt rules, indented designations, the title in the adversary column, an 18 pt gap); the spacing between its rows matches typst's to about 1 pt; centred bold caps headings; lettered lists (A., B., ...) at the typst indents; the signature block; a centred page number in the footer.

What differs:
- Heading sizes: Word takes half-points, so 17 pt and 14.5 pt where typst uses 16.8 pt and 14.4 pt.
- Pagination: 10 pages in docx, 11 in typst. The gap on typst's page 3 is not reproduced: ¶14 flows onto page 3. No page break is forced.
- Position: the first body line on a page sits about 11 pt lower than typst's, and the first caption line about 4 pt lower (LibreOffice places exact-spaced lines lower). The top margin is 1 in in both.
- Footnotes: none in this template or sample. Footnote text is set to 10 pt (typst's default measured 10.2 pt); its line spacing is not checked.

docx BLOCKED items:
- The docx gates do not run yet: this court has no `rules.md` or `checks.yaml`, so `tools/check.sh --engine docx` has no checks to run. Nothing is stamped.
- Word: not opened (no Word on this box). The renderer checks the zip and the XML parts; LibreOffice converts the file without a repair step.

Page review (docx): all 10 pages of `OUTPUT-mnb-adversary-complaint-magnetationcomplaint.docx.pdf` were rendered at 60 dpi and viewed against the typst render. No page has an open defect that is not in the list above.
