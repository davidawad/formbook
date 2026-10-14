# ohsb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 proceeding) in the United States Bankruptcy Court for the Southern District of Ohio (`ohsb`).
Folder: `courts/sixth-circuit/ohio/federal/bankruptcy-southern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-caudill-2-25-ap-02053-adversary-complaint.pdf` (1 filer, the chapter 7 trustee; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-caudill-pc-infinity.md` (full transcription of the 10-page filing, Exhibit A included) |
| render | ok: `samples/OUTPUT-caudill-pc-infinity.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular and -Bold, embedded), no warnings |
| overlay | ok: `samples/OVERLAY-caudill-pc-infinity.pdf` and `OVERLAY-caudill-pc-infinity.txt` (page map below) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Each rule was read from its primary source. The local rules are the S.D. Ohio Local Bankruptcy Rules as amended effective October 1, 2020 (PDF on the court's site: https://www.ohsb.uscourts.gov/sites/ohsb/files/local_rules/Final%20Version%20of%20Amended%20LBRs_Effective%20Oct%201%202020.pdf), read 2026-10-14. A search on 2026-10-14 found no later bankruptcy LBR amendment on the court's site (the amendment orders found were dated 2009, 2011, 2016 and 2020). That is not proof there is none, so confirm the current text with the clerk before treating this as final.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, read 2026-10-14) | Fed. R. Civ. P. 10 applies to an adversary pleading; the caption must substantially conform to Official Form 416. | caption (`caption` frontmatter), numbered paragraphs (`render-body`) |
| Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | every body paragraph is numbered by the template; headings, lists, the table and the lead-in are not |
| Fed. R. Bankr. P. 7008 (https://www.law.cornell.edu/rules/frbp/rule_7008, read 2026-10-14) | Jurisdiction statement; whether the proceeding is core or non-core; whether the pleader consents to final orders. | author content in the sample (the sample states them). The template does not check the wording. |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, read 2026-10-14) | Legible; a caption with the court's name, the case title, the case and adversary numbers, and a brief designation of the document. | `court-title`, `caption`, `brief_title` |
| S.D. Ohio LBR 9004-1(b) | 8½ × 11 bond paper; double spaced; side margins; top margin of at least one inch; typed print at least 10 to 12 point. | `margin` = 1 in on all sides; `type-size` = 12 pt; `body-leading` = 1.35 em (24 pt pitch at 12 pt) |
| S.D. Ohio LBR 9004-1(a) | Legibility; a document that cannot be filed legibly needs a typed substitute. | not checked (a rendering property, not a template property) |
| S.D. Ohio LBR 9004-2 | Caption: debtor name, case number, chapter, adversary proceeding number, judge's name; the nature of the paper and the relief requested, stated so its relationship to prior filings is explicit. | caption right column (case number, judge, chapter, "Adv. Pro. No."); title (`brief_title`) |
| S.D. Ohio LBR 7001-1 | Separate adversary for each defendant in an avoidance action unless the defendants are part of the same transaction. | not checked (one defendant in this sample; a filing-level rule) |
| S.D. Ohio LBR 7003-1 | Adversary cover sheet (the AO form) with each complaint not filed electronically. | not produced (see gaps) |

Not produced by this template (separate filings with the complaint): the summons (FRBP 7004 and LBR 7004-2 reserved), the Adversary Proceeding Cover Sheet, and any corporate-disclosure statement.

## Layout

- Court title (three centered lines in bold): UNITED STATES BANKRUPTCY COURT / SOUTHERN DISTRICT OF OHIO / the division.
- Caption: the parties on the left, a column of ")" marks, and the case information on the right (Case No., Judge, Chapter, and Adv. Pro. No.). Each line is a fixed-height row, so the marks line up with the parties' lines.
- Title of the paper, bold, centered.
- Body: paragraphs numbered 1, 2, … with a 0.5 inch first-line indent; headings centered (level 1 in bold capitals, level 2 bold as written); the demand's items numbered i., ii., … ; the signature block at the end, single spaced with the closing "Respectfully submitted," at the right; exhibit tables centered.
- Footer: page number, centered.
- Paragraph spacing equals the leading (1.35 em): typst adds leading only between the lines of one paragraph, so the gap between paragraphs carries the second half of the double-spaced pitch. Headings keep with the next paragraph (`sticky`).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#` (level 1: centered bold capitals), `##` (level 2: centered bold), a markdown list (`1.` items), a roman-numeral item (`i.` ... the template numbers them), a markdown pipe table (`|`), the directive `{{SIGNATURE}}` (renders the signature block from frontmatter), or a paragraph (numbered by the template).
- Footnotes: `[^n]` references and `[^n]: text` definitions (the definitions can sit anywhere; they are removed from the body and placed at their references).
- Frontmatter: `case_number`, `chapter`, `judge`, `division`, `adv_pro_no` (documentation only; the caption right column carries it), `caption.left` and `caption.right` (one entry per line; empty strings are blank rows), `brief_title`, `lead_in` (optional, unnumbered lead-in), `date` (optional; "Dated:" at the left of the signature block), `signature` (`closing` optional, `lines` for the signer and counsel).
- Not supported: raw typst, HTML, the ECF header lines (the sample does not carry them).

## Overlay

`tools/overlay.sh` pairs each sample page with the exemplar page sharing the most words (`samples/OVERLAY-caudill-pc-infinity.txt`):

```
ours p.1  filed p.1  word-overlap 81.9%
ours p.2  filed p.2  word-overlap 71.0%
ours p.3  filed p.3  word-overlap 53.4%
ours p.4  filed p.5  word-overlap 64.2%
ours p.5  filed p.6  word-overlap 62.3%
ours p.6  filed p.7  word-overlap 84.1%
ours p.7  filed p.8  word-overlap 74.4%
ours p.8  filed p.9  word-overlap 42.8%
```

Red = our render, blue = the filed exemplar, black = both. The exemplar uses a sans-serif face and the ECF header lines; the render uses a serif face and no header, so the text layers do not coincide. The overlay is a diagnostic, not a score. Page 8 pairs with filed p.9, which is the demand and signature page of the exemplar; the render has the same content on page 8.

## Visual review (Gate 2 record, all 8 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption with ")" column, title, lead-in, paragraphs 1 and 2, footnote 1 | OK after two fixes: the title's two lines were 8 pt apart (paragraph leading had been zeroed on the cover) and now sit 14 pt apart with a gap above the first paragraph. |
| 2 | Paragraphs 3 to 12; Jurisdiction and Venue; The Parties | OK. Headings have space above and below. |
| 3 | Paragraphs 12 to 19; Factual Background | OK. |
| 4 | Paragraphs 20 to 28 (§ 547(c) defenses) | OK. |
| 5 | Paragraphs 29 to 36; Count I heading | OK. |
| 6 | Paragraphs 37 to 44; Count II | OK. |
| 7 | Count III (with its heading, moved from the foot of page 6 by sticky headings), paragraphs 45 to 49, Demand for Relief, items i. to iv. | OK. |
| 8 | Item v; "Respectfully submitted," signature block; Exhibit A table | OK. The exhibit heading follows the signature on the same page (see gaps). |

Earlier defects found and fixed during this review (for the record): overlapping paragraphs (a paragraph-spacing bug: the gap between paragraphs was one leading short); a heading stranded at the foot of a page (fixed by `sticky`); the title's two lines set 8 pt apart (fixed: single leading on the title); the space after a footnote reference was lost ("Period¹pursuant"), because markdown drops whitespace at segment edges (fixed by `seg()`, the same fix as in the motion template).

## Known gaps and open choices

1. **One filer only.** The CourtListener search found other S.D. Ohio adversary complaints, but only one with a text PDF in storage; the second search was rate-limited. The brief asks for one exemplar per doc type, so tier 2 is judged against one filer, not two or three.
2. **Adversary number is blank**, as on the filed copy. The template prints "Adv. Pro. No." with nothing after it; the clerk assigns the number at filing.
3. **Adversary Proceeding Cover Sheet and summons are not produced** (LBR 7003-1 and the FRBP 7004 summons are separate filings).
4. **Font.** EB Garamond at 12 pt. The exemplar is sans-serif (Helvetica / Liberation Sans). The LBRs name no typeface and require 10 to 12 point; 12 point is used. This is a tier-2 convention choice, flagged here rather than treated as a rule.
5. **Footnotes are single spaced** at 12 pt. LBR 9004-1(b) asks for double spacing of the filing; footnotes are conventionally single spaced, and the exemplar's footnote is single spaced. The rule does not exempt footnotes by name, so this is a reading, and it is recorded here.
6. **Exhibit placement.** Exhibit A begins on the page of the signature rather than a new page. The exemplar also has its exhibit on the last page (its page 10) with the signature above it on page 9. Left as is.
7. **Page count.** 8 pages against the exemplar's 10 (the exemplar carries the ECF header and a separate exhibit page). Inside the depth target for the content transcribed.
8. **Paragraph numbers.** The sample's allegations are numbered 1 to 50 by the template. The filed numbers are not transcribed; the Exhibit A and relief numbering follow the filed text.
9. **Local rule text version.** Read from the 2020 LBR PDF; see the rules note above.
10. **`tools/check.sh` and `tools/check-selftest.sh` are not run.** They expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape; the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 record.
11. **File names.** The brief names outputs `samples/<id>.pdf` and `samples/<id>-overlay.pdf`. The tools read and write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` by default (and `tools/overlay.sh` reads `OUTPUT-<id>.pdf` to build its overlay), so this folder follows the tools' names, as the court-of-appeals and CAND folders do. The sample is `INPUT-<id>.md`, the same convention.

[Court folder](../README.md)
