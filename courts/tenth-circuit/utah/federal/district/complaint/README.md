# utd: complaint

Doc type: **complaint** (complaint and jury demand, FRCP 8 and 10) in the United States District Court for the District of Utah (`utd`).
Folder: `courts/tenth-circuit/utah/federal/district/complaint/`. Self-contained: exemplar, sample, template and review are in this folder.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (15 pages, text layer; `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (abridged transcription of the exemplar, see Known gaps) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx` (+ `.docx.pdf`), 8 pages each, typst 0.15.0 and LibreOffice, vendored Times New Roman only, no warnings (`tools/render.sh`) |
| typeface | face required: **none** (DUCivR 10-1(3) names no typeface). Font: **Times New Roman** 12 pt on both engines (docs/FONTS.md; the docx names the typst face through `{font}`). The filed exemplar is set in Times New Roman too. |
| overlay | ok: `usage/OVERLAY-fastre-complaint.pdf` and `usage/OVERLAY-fastre-complaint.txt` (`tools/overlay.sh`, exemplar passed as the third argument: see Render and overlay) |
| pages reviewed | 8 of 8 typst and 8 of 8 docx (rendered at 50 dpi and viewed after the last template change, fb-595.68.33) |

File names. The brief names outputs `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh`, `tools/overlay.sh` and the court-folder convention (`CLAUDE.md`) name them `INPUT-<id>.md` → `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`. The tools were used as they are; `<id>` is `fastre-complaint`.

## Governing rules

Primary source: D. Utah Local Civil Rules, December 2023 edition, https://www.utd.uscourts.gov/sites/utd/files/Civil%20Rules%20Final%202023.pdf, fetched and read 2026-10-14. That PDF is the newest civil-rules edition I found (a December 2021 edition also exists, superseded). The rule text quoted below is from that PDF. Federal rules: Fed. R. Civ. P. 5(d)(1)(B), 8(a), 10(a)–(b), 38(b), from https://www.law.cornell.edu/rules/frcp/rule_8 (and rule_5, rule_10, rule_38), fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| DUCivR 10-1(1) | Paper and margins | 8½ × 11 inch; top margin at least 1½ inches; remaining margins at least 1 inch. | `margins` (top 1.5 in, others 1 in) in `typst/utd-complaint.typ` |
| DUCivR 10-1(3) | Font and size | Clearly legible; minimum 12 point, including footnotes. No typeface named in the text. | `type-size = 12pt`, `font-family` Times New Roman |
| DUCivR 10-1(4) | Spacing | Text double-spaced, except block quotes and footnotes. | `pitch-body = 24pt` (exact 24 pt line boxes, two 12 pt lines; docx 480 twips) for the body, headings and prayer; `pitch-single = 13.8pt` for the counsel block, court title, caption and signature |
| DUCivR 10-1(5) | Pagination | Document pages numbered consecutively. | `numbering: "1"` on every page, cover included |
| DUCivR 10-1(6)(A) | Contact information | Upper left, above the caption: counsel's name and bar number, firm, address, telephone, email, party represented. | `counsel` and `counsel_role` frontmatter, `counsel-block()` |
| DUCivR 10-1(6)(B) | Caption table | Names of parties, title of the document, case number, assigned judge and referred magistrate judge if applicable. | `caption`, `brief_title`, `case_number`, `judge`, `magistrate` in `caption-table()` |
| DUCivR 10-1(7) | Jury demand | "JURY DEMANDED" in capitals in the caption of the initial pleading, immediately below the title. | `jury_demand: true` → "JURY DEMANDED" under the title in the caption |
| DUCivR 10-1(8) | Signatures | Every document signed by counsel; electronic signature allowed. | `signature-block()`: "DATED this …", "By: /s/", name, "Attorneys for …" |
| Fed. R. Civ. P. 10(a) | Caption | Court name, title, file number, Rule 7(a) designation. | Court title, title, case number, "Plaintiffs," / "Defendants." designations |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs | Each claim or defense in numbered paragraphs. | `allegations()`: each allegation is numbered by the template (1, 2, …) |
| Fed. R. Civ. P. 8(a) | Short plain statement | Grounds for jurisdiction; a short and plain statement of the claim; a demand for relief. | Content of the sample (the template does not check content) |
| Fed. R. Civ. P. 38(b) | Jury demand | Written demand, served and filed. | "Jury Demand" section at the end of the body (not numbered) |

Not produced by this template (separate filings or documents, not part of the complaint): civil cover sheet (JS-44), summons, the Rule 7.1 disclosure statement, and any proposed order. FRCP 5(d)(1)(B) excuses a certificate of service for a paper filed through the court's electronic-filing system, so none is generated.

## Layout

- Shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation. The docx render breaks every line and page where typst does (XENG-001..003 gated in `eval.yaml`).
- Page 1: counsel block single-spaced at the upper left with the party represented (`counsel_role`, italic; DUCivR 10-1(6)(A)); a blank double line; the court title centred bold capitals; a blank double line; the caption: the party column (4 in, names, designation 1.25 in in, "v.", blank single lines between) closed by a rule on its right and below; at the right the title in bold capitals, "JURY DEMANDED" directly below it (DUCivR 10-1(7)), the case number and the judge.
- Body: a blank double line under the caption, then the lead-in (unnumbered). Paragraphs on the 24 pt pitch, first line indented 0.5 in, the number in a 0.5 in box after the indent (text from 1 in, later lines at the margin). Headings on the body pitch, bold, kept with the text after them: level 1 centred capitals, level 2 centred, level 3 at the margin; 12 pt above a heading that follows text. Prayer items: the number at 0.5 in, lines hanging at 1 in.
- Signature: a blank double line, "DATED this ..." at the margin; "Respectfully submitted,", the firm, "By: /s/", the signer and the lines from 3.25 in, single-spaced; kept on one page with the last chunk of the body.
- Page number centred at the foot of every page, its 13.8 pt line box ending 0.5 in above the page edge.
- No pleading paper (no line numbers). DUCivR 10-1 does not require them; the exemplar has none.

## Markdown contract (for samples)

- YAML frontmatter. Fields: `case_number`, `court` (lines), `division` (optional), `counsel` (lines), `counsel_role`, `caption` (list of `{names, designation}`; "v." is inserted between sides), `brief_title`, `jury_demand` (true/false), `judge` (optional), `magistrate` (optional), `lead_in` (optional, unnumbered lead-in paragraph), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = level 1, `##` = level 2, `###` = level 3 headings. A list (`1.`, `-`) is not numbered. A paragraph is numbered unless it is under a heading whose text contains "Prayer" or "Jury Demand", or it introduces a list (the next chunk is a list).
- The sample does not type numbers: the template numbers the allegations. Cross-references to paragraph numbers must not be typed in the text.
- Not supported: tables, footnotes, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/utah/federal/district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/district/complaint fastre-complaint /path/to/exemplar.pdf
```

The exemplar PDF is not in the checkout (only `usage/SOURCE.md` is). On 2026-10-15 the overlay ran against the RECAP copy at the SOURCE.md URL, fetched to a temp directory and passed as the third argument; its page count (15) matches the SOURCE.md. Without the argument, `overlay.sh` looks for `usage/*.pdf`.

`OVERLAY-fastre-complaint.pdf` is the red/blue test: red = our render, blue = the filed exemplar, black = both. `OVERLAY-fastre-complaint.txt` is the page map. `overlay.sh` pairs each render page with the exemplar page that shares the most words (its page map is coarse, see below). The overlay is a diagnostic, not a score.

Overlay map: ours pp. 1–7 ↔ filed pp. 1–7 (word overlap 70–95%); ours p. 8 ↔ filed p. 15 (58%); ours p. 9 ↔ filed p. 15 (20%). Pages 8–9 pair with the exemplar's last page because the sample skips exemplar pp. 8–14 (see Known gaps), so the low overlap there is expected.

## Visual review (Gate 2 record, fb-595.68.33: all 8 pages of each engine rendered at 50 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block with "Attorneys for Plaintiff", court title, caption (whole party list), JURY DEMANDED under the title, case no., judge | OK on both engines. The caption fills the page, so the lead-in starts page 2. |
| 2 | Lead-in, PARTIES, paras 1-7 | OK. |
| 3 | Paras 8-16, JURISDICTION AND VENUE, GENERAL ALLEGATIONS, first sub-heading | OK; 12 pt above each heading. |
| 4 | Paras 16-25 | OK. |
| 5 | Paras 26-37, sub-heading | OK. |
| 6 | Paras 38-45, sub-heading | OK. |
| 7 | Paras 45-53, the three cause-of-action heading lines together | OK. |
| 8 | PRAYER FOR RELIEF items 1-8, JURY DEMAND, DATED, signature block | OK; signature kept with the jury-demand paragraph. |

The docx pages break every line and page as typst does (`fb diff --engines`: 213/213 lines, 8 = 8 pages).

## Known gaps and open choices

1. **Abridged sample.** The sample transcribes exemplar ¶¶ 1–53, the first cause of action's heading and ¶¶ 52–53, the prayer and the jury demand. Omitted: exemplar ¶¶ 54–105 (the rest of the Monell count, the individual-liability count against the jail staff, and the detail of ¶¶ 54–85). The render is 8 pages against the exemplar's 15, within the 8–14 target.
2. **One exemplar.** Tier 2 asks for two or three filers. Alternates were found and recorded in `usage/SOURCE.md` (Keller v. Danford, The Preserve v. Kamas City, Owen v. State of Utah Legislative Services). Not run as a second-filer comparison.
3. **Typeface.** DUCivR 10-1(3) names no typeface; the template sets Times New Roman 12 pt on both engines (the exemplar is set in Times New Roman too).
4. **Type size.** 12 pt, the rule minimum. The sample has no footnotes and the template sets none, so the footnote minimum (DUCivR 10-1(3)) is not exercised.
5. **Caption separator.** The template inserts "v." between sides; the exemplar uses "vs.". Utah filings use both; the template keeps one form.
6. **Title.** The exemplar title is "COMPLAINT AND DEMAND FOR JURY TRIAL". The template prints "COMPLAINT" with "JURY DEMANDED" under it, as DUCivR 10-1(7) asks. The sample therefore carries the rule's form, not the exemplar's title line. A filer who keeps the long title should also keep the jury demand line.
7. **Judge and case number.** Blank in the sample, as filed (the case was not yet assigned a judge's initials at the time of filing). The template prints "Judge ____" only when `judge` is given.
8. **Keep-with-signature.** The template keeps the last plain paragraph with the signature block, so a signature never stands alone. A last list (the prayer) is not kept with the signature; in that case the signature may stand alone. Not seen in this sample.
9. **Sub-heading styling.** The exemplar's sub-headings are bold at the left margin (template: level 3). Its cause-of-action title lines are centred (template: level 2). Both are conventions, not rule text.
10. **Not checked by the template.** Content requirements of FRCP 8(a) (jurisdiction, claim, demand) and the accuracy of cited statutes. Local-rule compliance of exhibits (DUCivR 10-1 exhibits paragraph) is not generated.
11. **Checks.** `sh tools/check.sh <folder> --engine typst` (9 passed, 0 failed) and `--engine docx` (13 passed, 0 failed, XENG-001..003 gated).

## Engines

**typst** (`typst/`): the reference. **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, `{font}`, Body Text 480 twips, single 276, a page-number footer 720 twips above the page edge, the letter section with the 1 1/2 in top margin) and the filter `docx/utd-complaint.lua`, which reads the sample chunk by chunk as the typst template does and writes every paragraph with its typst pitch and spacing (cover, caption table, numbered paragraphs, headings, prayer list, signature). The frontmatter is read as written (`$FORMBOOK_META`). `fb render` builds the reference document; there is no shell builder and no committed `reference.docx` (fb-595.68.33). Results: typst 9 and docx 13 checks passed, 0 failed; XENG-001..003 PASS (8 = 8 pages, 213/213 lines). No latex engine in this folder.
