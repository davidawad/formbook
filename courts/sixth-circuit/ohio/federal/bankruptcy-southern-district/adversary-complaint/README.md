# ohsb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 proceeding) in the United States Bankruptcy Court for the Southern District of Ohio (`ohsb`).
Folder: `courts/sixth-circuit/ohio/federal/bankruptcy-southern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer, the chapter 7 trustee; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (full transcription of the 10-page filing, Exhibit A included) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `.docx.pdf`, 9 pages each, the same lines and pages (XENG-001..003 gated in `eval.yaml`), vendored Times New Roman only, no warnings (2026-10-22) |
| typeface | Face required: none. The LBRs name no face for filings (S.D. Ohio LBR 9004-1(b): "at least 10-12 font size"). Template face: Times New Roman (vendored, the house face), typst and docx alike (the docx named EB Garamond until fb-595.68.30). |
| overlay | ok: `usage/OVERLAY-caudill-pc-infinity.pdf` and `OVERLAY-caudill-pc-infinity.txt` (page map below). Run 2026-10-15 against the exemplar fetched from the CourtListener URL in `usage/SOURCE.md` to `/tmp`; the PDF is not kept in the repo |
| pages reviewed | 9 of 9 on each engine (typst and docx, re-rendered 2026-10-22, every page at 60 dpi and viewed; see the visual review below) |

## Governing rules

Each rule was read from its primary source. The local rules are the S.D. Ohio Local Bankruptcy Rules as amended effective October 1, 2020 (PDF on the court's site: https://www.ohsb.uscourts.gov/sites/ohsb/files/local_rules/Final%20Version%20of%20Amended%20LBRs_Effective%20Oct%201%202020.pdf), read 2026-10-14. A search on 2026-10-14 found no later bankruptcy LBR amendment on the court's site (the amendment orders found were dated 2009, 2011, 2016 and 2020). That is not proof there is none, so confirm the current text with the clerk before treating this as final.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, read 2026-10-14) | Fed. R. Civ. P. 10 applies to an adversary pleading; the caption must substantially conform to Official Form 416. | caption (`caption` frontmatter), numbered paragraphs (`render-chunk`) |
| Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | every body paragraph is numbered by the template; headings, lists, the table and the lead-in are not |
| Fed. R. Bankr. P. 7008 (https://www.law.cornell.edu/rules/frbp/rule_7008, read 2026-10-14) | Jurisdiction statement; whether the proceeding is core or non-core; whether the pleader consents to final orders. | author content in the sample (the sample states them). The template does not check the wording. |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, read 2026-10-14) | Legible; a caption with the court's name, the case title, the case and adversary numbers, and a brief designation of the document. | `court-title`, `caption`, `brief_title` |
| S.D. Ohio LBR 9004-1(b) | 8½ × 11 bond paper; double spaced; side margins; top margin of at least one inch; typed print at least 10 to 12 point. | `margin` = 1 in on all sides; `type-size` = 12 pt; `pitch-body` = 24 pt line boxes (double spacing at 12 pt) |
| S.D. Ohio LBR 9004-1(a) | Legibility; a document that cannot be filed legibly needs a typed substitute. | not checked (a rendering property, not a template property) |
| S.D. Ohio LBR 9004-2 | Caption: debtor name, case number, chapter, adversary proceeding number, judge's name; the nature of the paper and the relief requested, stated so its relationship to prior filings is explicit. | caption right column (case number, judge, chapter, "Adv. Pro. No."); title (`brief_title`) |
| S.D. Ohio LBR 7001-1 | Separate adversary for each defendant in an avoidance action unless the defendants are part of the same transaction. | not checked (one defendant in this sample; a filing-level rule) |
| S.D. Ohio LBR 7003-1 | Adversary cover sheet (the AO form) with each complaint not filed electronically. | not produced (see gaps) |

Not produced by this template (separate filings with the complaint): the summons (FRBP 7004 and LBR 7004-2 reserved), the Adversary Proceeding Cover Sheet, and any corporate-disclosure statement.

## Layout

The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch (24 pt body, 14 pt single lines), the spaces between blocks explicit, first-fit line breaking with no kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does (Gate 4, `params.cross_engine: gate` in `eval.yaml`).

- Court title (three centered bold single lines): UNITED STATES BANKRUPTCY COURT / SOUTHERN DISTRICT OF OHIO / the division.
- Caption, a blank single line below: the parties on the left (3.4 in), a column of ")" marks (0.3 in), and the case information on the right, 0.15 in in (Case No., Judge, Chapter, Adv. Pro. No.). One row per single line, so each ")" sits beside its party line (docx: a borderless table, one row per line).
- Title of the paper, bold, centered, single spaced, a blank single line below the caption; a blank double line, then the text.
- Body: paragraphs numbered 1, 2, … with a 0.5 inch first-line indent, the number in a 0.5 in box (the text starts 1 in from the margin; docx: a tab); headings at the type size on the body pitch, centered (level 1 in bold capitals, level 2 bold as written), kept with the next block; the demand's items renumbered i., ii., … the same way; a markdown list numbered half an inch in, the text hanging at 0.9 in.
- Signature block (at `{{SIGNATURE}}`), 12 pt below the last item and kept on one page with it: single lines in a column 2.8 in from the margin, "Respectfully submitted," then a blank line and the signer's lines; "Dated:" left of the first line when the frontmatter has a `date`.
- Exhibits: a level-1 heading that starts with "EXHIBIT" opens a page (the filed exhibit is on a page of its own); a pipe table is single spaced with 0.5 pt rules, centered, each column half an em per character of its longest cell plus three.
- Footnotes at 12 pt, single spaced, a short rule above them. Footer: the page number, centered, its line box ending 0.5 in above the page edge.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#` (level 1: centered bold capitals), `##` (level 2: centered bold), a markdown list (`1.` items), a roman-numeral item (`i.` ... the template numbers them), a markdown pipe table (`|`), the directive `{{SIGNATURE}}` (renders the signature block from frontmatter), or a paragraph (numbered by the template).
- Footnotes: `[^n]` references and `[^n]: text` definitions (the definitions can sit anywhere; they are removed from the body and placed at their references).
- Frontmatter: `case_number`, `chapter`, `judge`, `division`, `adv_pro_no` (documentation only; the caption right column carries it), `caption.left` and `caption.right` (one entry per line; empty strings are blank rows), `brief_title`, `lead_in` (optional, unnumbered lead-in), `date` (optional; "Dated:" at the left of the signature block), `signature` (`closing` optional, `lines` for the signer and counsel).
- Not supported: raw typst, HTML, the ECF header lines (the sample does not carry them).

## Overlay

`tools/overlay.sh` pairs each sample page with the exemplar page sharing the most words (`usage/OVERLAY-caudill-pc-infinity.txt`):

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

The page map above is from the 2026-10-15 render (8 pages, before the exhibit got its own page); `just overlay <this folder>` writes a fresh one to `.overlay/`. Red = our render, blue = the filed exemplar, black = both. The exemplar uses a sans-serif face and the ECF header lines; the render uses a serif face and no header, so the text layers do not coincide. The overlay is a diagnostic, not a score. Page 8 pairs with filed p.9, which is the demand and signature page of the exemplar; the render has the same content on page 8.

## Visual review (Gate 2 record, all 9 pages on each engine, rendered at 60 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 230/230).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption with the ")" column, title, lead-in, Nature of the Action, paragraphs 1 and 2 (begun), footnote 1 | OK: the ")" marks sit beside every party line; the title two centered lines; the footnote under a short rule. |
| 2 | Paragraphs 2 to 11; Jurisdiction & Venue; The Parties | OK. "§§ 157 and 1334" keeps the signs with the number (the old render split "§" / "§ 157"). |
| 3 | Paragraphs 12 to 19; Factual Background | OK. |
| 4 | Paragraphs 19 to 28 (§ 547(c) defenses) | OK. |
| 5 | Paragraphs 28 to 34; Count I with its subtitle | OK. |
| 6 | Paragraphs 35 to 43; Count II | OK. "§ 547(b)" carried to the next line whole. |
| 7 | Paragraphs 43 to 50; Count III; Demand for Relief; items i. and ii. | OK. |
| 8 | Items ii. to v.; "Respectfully submitted," and the signature block | OK: item v. kept with the signature; the block single spaced 2.8 in in. |
| 9 | Exhibit A: heading and the transfer table | OK: on a page of its own, as filed; the table centered with 0.5 pt rules. |

No open tier-2 finding. Tier 3 (not chased): the filed complaint is set in a sans-serif face with ":" caption marks and a rule under the debtor block.

## Known gaps and open choices

1. **One filer only.** The CourtListener search found other S.D. Ohio adversary complaints, but only one with a text PDF in storage; the second search was rate-limited. The brief asks for one exemplar per doc type, so tier 2 is judged against one filer, not two or three.
2. **Adversary number is blank**, as on the filed copy. The template prints "Adv. Pro. No." with nothing after it; the clerk assigns the number at filing.
3. **Adversary Proceeding Cover Sheet and summons are not produced** (LBR 7003-1 and the FRBP 7004 summons are separate filings).
4. **Font.** Times New Roman 12 pt in typst and docx (the docx named EB Garamond until fb-595.68.30). The exemplar is sans-serif (Helvetica / Liberation Sans). The LBRs name no typeface and require 10 to 12 point; 12 point is used, in the house face. A tier-2 convention choice, flagged here rather than treated as a rule.
5. **Footnotes are single spaced** at 12 pt. LBR 9004-1(b) asks for double spacing of the filing; footnotes are conventionally single spaced, and the exemplar's footnote is single spaced. The rule does not exempt footnotes by name, so this is a reading, and it is recorded here.
6. **Exhibit placement.** A level-1 heading that starts with "EXHIBIT" opens a page, as the filed exhibit stands on a page of its own (its page 10).
7. **Page count.** 9 pages against the exemplar's 10 (the exemplar carries the ECF header lines). Inside the depth target for the content transcribed.
8. **Paragraph numbers.** The sample's allegations are numbered 1 to 50 by the template. The filed numbers are not transcribed; the Exhibit A and relief numbering follow the filed text.
9. **Local rule text version.** Read from the 2020 LBR PDF; see the rules note above.
10. **Tool checks.** `tools/check.sh <this folder>` and `--engine docx` run every gate: `RESULT: 9 checks passed, 0 failed` (typst) and `RESULT: 13 checks passed, 0 failed` (docx, XENG-001..003 gated). `tools/check-selftest.sh` takes a court root with `court.json` and does not run on this doc-type folder.
11. **File names.** The brief names outputs `usage/<id>.pdf` and `usage/<id>-overlay.pdf`. The tools read and write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` by default (and `tools/overlay.sh` reads `OUTPUT-<id>.pdf` to build its overlay), so this folder follows the tools' names, as the court-of-appeals and CAND folders do. The sample is `INPUT-<id>.md`, the same convention.

## Engines

Engine status: typst `OUTPUT-adversary-complaint.typst.pdf`; docx `OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice), 9 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

**docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; single lines and footnotes in 14 pt boxes, 7 pt after a footnote; "Numbered Paragraph" with a tab to 1 in for the number, "List Number" hanging at 0.9 in, and their "Keep" variants for the paragraph before the signature) and `docx/ohsb-adversary-complaint.lua` (on `lib/docx/xengine.lua`): the court title, the caption table, the numbered paragraphs and relief items, the headings, the signature block, the exhibit table, the footer (a centered PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/render.sh` and a committed `reference.docx` in EB Garamond). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).

- Notice directive: the complaint has no 21-day notice; `{{NOTICE_21_DAY}}` is not part of this template's contract (the docx filter rejects an unexpected block rather than dropping it).

[Court folder](../README.md)
