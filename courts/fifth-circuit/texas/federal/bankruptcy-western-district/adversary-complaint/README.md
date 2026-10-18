# txwb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the Western District of Texas (`txwb`).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-txwb-adversary-complaint-osherow2501073.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-txwb-adversary-complaint-osherowcomplaint.md` (a portion of the 14-page filing, see Known gaps) |
| render | ok: `usage/OUTPUT-txwb-adversary-complaint-osherowcomplaint.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-osherow-complaint.pdf` and `OVERLAY-osherow-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change; re-rendered and all 9 pages viewed again on 2026-10-14, font unchanged) |

File names follow the tools, not the brief's `<id>.md` shorthand: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf` (the default of `tools/render.sh`), and the overlay `OVERLAY-<id>.pdf/.txt` (the default of `tools/overlay.sh`, which reads `OUTPUT-<id>.pdf`).

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Bankr. P. 7001 | An adversary proceeding is commenced by a complaint; the exemplar cites Rule 7001 for its nature. | Author content (the sample's jurisdiction paragraphs). Not checked by the template. | Rule number as cited on the exemplar. Rule text not fetched in this run. |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to a pleading in an adversary proceeding; the caption must substantially conform to the appropriate Official Form 416 (A, B or D). | `court-title`, `caption` (court name, division, debtor and case number at right, adversary number, title of the paper). | Fetched from https://www.law.cornell.edu/rules/frbp/rule_7010 on 2026-10-14 (summary of the text). |
| Fed. R. Civ. P. 10(a) (via 7010) | Caption: court name, title, file number, and the Rule 7(a) designation. | As above; the designation is the party designation (Plaintiff / Defendant). | Via the 7010 summary above. |
| Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template (`allegations()`); headings and the prayer list are not. | Rule text not fetched in this run. |
| Fed. R. Bankr. P. 9004(a) | A petition, pleading, schedule or other document must be clearly legible; common abbreviations are acceptable. | Typography: 12 pt EB Garamond, one-inch margins, double spacing. | Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. The rule sets no point size, margin or spacing. |
| Typeface (court-named face) | None named. FRBP 9004(a) and W.D. Tex. L.R. 9004 set no typeface, size, margin or spacing. The one face list in the local rules (Courier, Times Roman, Helvetica, Orator) governs the mailing matrix in complex Chapter 11 cases, not pleadings. | EB Garamond kept (docs/FONTS.md, "No face named"). Typeface row: no face required, no substitute. | Local rules text read from the 2014 redline on txwb.uscourts.gov, fetched 2026-10-14 (see Known gaps 6). |
| W.D. Tex. local bankruptcy rules | No adversary-complaint format rule was located. L.R. 9014-1(a) (negative-notice form language) governs motions, not complaints, and is used only in the motion-brief folder. | Not used here. | Searched; see Known gaps. |

Not produced by this template (separate filings with the complaint, not part of the pleading): the adversary proceeding cover sheet (Official Form 104; the RECAP docket of another txwb adversary shows it attached as Exhibit A to the complaint, rule not verified); the summons; a corporate disclosure statement where required.

## Layout

- Court title on three centered bold lines: IN THE UNITED STATES BANKRUPTCY COURT / FOR THE WESTERN DISTRICT OF TEXAS / DIVISION (from the sample's `division`).
- Caption: left column with the debtor block ("IN RE:", debtor, "Debtor."), then the adversary parties (names, designation, "v." between sides), closed by a rule on the right and bottom. Right column: "Case No." (bankruptcy case), chapter, and "Adv. Pro. No." (blank line when the sample's `adversary_number` is empty, as in the filed copy).
- Title of the paper, bold and centered, in capitals.
- Opening paragraph (`lead_in`): unnumbered, as in the filing.
- Body: `#` headings are centered bold sections numbered I., II., ...; `##` headings are bold sub-headings numbered A., B., ... (restart in each section); `###` headings are bold italic. Blank-line-separated paragraphs are numbered 1, 2, ... (first-line indent). Markdown lists are lettered (a), (b), ... as in the prayer for relief.
- Signature block: "Dated:" left, "Respectfully submitted," and the firm right, then each signer as "/s/ Name", the name and the signer lines, separated by -AND-, then the role lines.
- Footer: page number, centered. No pleading line numbers or footer title (no txwb rule was found requiring them).

## Markdown contract (for samples)

- YAML frontmatter: `division`, `debtor` (`name`, `case_number`, `chapter`), `caption.parties` (list of `{names, designation}`), `adversary_number` (blank for an unnumbered copy), `brief_title`, `lead_in` (optional, unnumbered opening paragraph), `date`, `signature` (`firm` lines, `groups` each with optional `signer` and `lines`, `role` lines).
- Body: `#` / `##` / `###` headings (not numbered by the author), paragraphs (numbered by the template), lists (lettered by the template).
- Case names are written with `*...*` for italics. The exemplar's text layer has no italics, so the sample is roman.

## Visual review (Gate 2 record, all 9 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, title, opening paragraph, introduction paragraphs 1-2 | OK after the paragraph-spacing fix (see below). Caption: debtor block, adversary block, case number and adversary number at right. |
| 2 | Introduction end, parties (3-4), jurisdiction (5-7), factual background heading, A. | OK. Headings keep with the paragraph after them. |
| 3 | Paragraphs 9-15 | OK. Body double-spaced, paragraph numbers at the first-line indent. |
| 4 | B. The Share Redemption Transaction (16-19), C. The Bankruptcy (20-24) | OK. |
| 5 | V. CAUSES OF ACTION; A. Count I (25-32); B. Count II (33-37) | OK. |
| 6 | Count II end (38), C. Count III, D. Count IV, E. Count V | OK. |
| 7 | F. Count VI, G. Count VII, H. Count VIII, I. Count IX, VI. RELIEF REQUESTED, paragraph 58 (WHEREFORE) | OK, except the WHEREFORE paragraph is numbered (see Known gaps). |
| 8 | Prayer for relief items (a) to (i) | OK. Lettered. The list starts on the page after its lead-in (see Known gaps). |
| 9 | Dated line, Respectfully submitted, firm, /s/ signers, -AND-, role | OK. Signature block is one unbreakable block and is kept together. |

## What was fixed during the build

- Paragraph spacing: at 1.35 em leading with zero paragraph spacing, typst 0.15 drew each paragraph's first line over the previous paragraph's last line (reproduced in a minimal file). Paragraph spacing is now equal to the body leading, so the 24 pt pitch holds at paragraph breaks.
- Caption lines: the outer stack had zero spacing, so the "Debtor." line overlapped the debtor name. It now has the single-line spacing.
- Headings: were set larger than the body (cmarker's default heading size); they are now the body size.
- Heading and paragraph blocks were forced unbreakable together, so a heading plus a long paragraph left a gap at the foot of page 2. The paragraph block is now breakable; the heading stays with it (`sticky`).
- Prayer list was numbered 1-9; it is now lettered (a)-(i).

## Known gaps and open choices

1. **Partial transcription.** The sample transcribes the opening paragraph, the introduction, the parties, jurisdiction, the factual background (filing paragraphs 9 to 28 in condensed form; filing paragraphs 7 and 8 were not captured), counts I and II in full, the first paragraphs of counts III to IX (several counts are shorter than the filing), the prayer for relief and the signature block. The template numbers its paragraphs from 1, so the numbers do not match the filing.
2. **WHEREFORE paragraph is numbered.** In the filing the request for relief opens with an unnumbered WHEREFORE paragraph. The template numbers every blank-line-separated paragraph, so the WHEREFORE paragraph is numbered (58). A fix needs a sample marker for an unnumbered paragraph; not added.
3. **Prayer list separated from its lead-in.** The WHEREFORE paragraph ends page 7 and the lettered list starts page 8. The heading and the lead-in are not kept with the first item of a list (a list may break across pages by design).
4. **Font.** EB Garamond (vendored; `docs/FONTS.md` "No face named"), not Times New Roman. The rules name no face (see Governing rules, Typeface), so no substitute is used. The exemplar is in a Times-like face; at 12 pt EB Garamond sets smaller. That is a visual difference from the filed copy, not a rule requirement.
5. **Spacing and margins are conventions.** Neither Rule 7010 nor Rule 9004(a) sets them, and no W.D. Tex. adversary-complaint rule was found. Double spacing and one-inch margins follow the exemplar's layout.
6. **Local rules checked, one edition.** The W.D. Tex. local bankruptcy rules were read from the 2014 redline on txwb.uscourts.gov (fetched 2026-10-14; text extracted with `pdftotext`). No adversary-complaint format rule and no typeface rule for pleadings appears in it. The courtrules.net copy returned HTTP 403, and the redline may be older than the current rules, so the current text is not checked.
7. **Caption without a § column.** The exemplar uses the IN RE block and a plain party block with no § column; another txwb complaint (Lowe, see SOURCE.md) uses a § column. The template follows the exemplar; both forms appear in the court.
8. **Second exemplar not saved.** Lowe v. Neugebauer (San Antonio Division, 19 pp.) is a second filer for tier-2 comparison and is not in `usage/`; see SOURCE.md.
9. **No cover sheet, summons or disclosure statement** (see Governing rules).
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. Render and overlay were run; the visual review above is the Gate 2 equivalent.

## Searches and sources

- Overlay (2026-10-14): the exemplar PDF is not committed to the repo (no `usage/*.pdf` in any court folder). It was downloaded from the URL in `usage/SOURCE.md` to `/work/artifacts/txwb-rules/usage/osherow-complaint.pdf` and passed as the third argument of `tools/overlay.sh`.

- Exemplar and other complaints: see `usage/SOURCE.md`.
- Rule text: FRBP 7010 and 9004(a) from Cornell LII, fetched 2026-10-14; W.D. Tex. L.R. 9014-1 from https://www.txwb.uscourts.gov/l-rule-9014-1-contested-matters (via WebFetch, 2026-10-14; the page was summarized, not quoted in full).

## Engines

**docx** (`docx/`): `sh tools/render.sh --engine docx adversary-complaint usage/INPUT-txwb-adversary-complaint-osherowcomplaint.md` runs pandoc with `docx/txwb-adversary-complaint.lua` on `docx/reference.docx`, then LibreOffice (`soffice --headless --convert-to pdf`). `docx/reference.docx` is rebuilt from `docx/reference-parts/` by `sh docx/build-reference.sh`. EB Garamond must be installed for LibreOffice (`fonts/eb-garamond`). Checked on `usage/OUTPUT-txwb-adversary-complaint-osherowcomplaint.docx.pdf`, 9 of 9 pages rendered at 60 dpi and viewed beside the typst pages.

| Layout | Matches typst | Differs (docx against typst, same sample) |
|---|---|---|
| Page count, Letter, 1 in margins, EB Garamond 12 pt (embedded) | 9 pages | none |
| Line pitch: 24 pt body, 13.8 pt single (exact spacing) | yes, to 0.1 pt in the caption and signature | none |
| Caption: 3.4 in / gutter / 2.8 in, right and bottom rules, case numbers at right | yes | none |
| Court title, title of the paper, lead-in, roman and lettered headings | yes | heading to the paragraph below is about 5 pt larger (heading spacing 6.8 pt above) |
| Numbered paragraphs (0.5 in first line, text at 0.92 in) and lettered prayer (a) (text at 1.09 in) | yes | numbers 10 and up do not push the text right (docx uses a fixed tab; typst flows the number) |
| Signature block, kept together | yes | none |
| Footer page number | yes | none |

- **Vertical placement.** LibreOffice places the text lower inside exact-height lines: body text sits about 11 pt lower on the page than in the typst PDF, single-spaced text about 3 pt lower. Pitch, margins and page breaks agree. Margins are not moved to compensate (the 1 in margin is the convention, and a shifted margin would not be the court's).
- **Line breaks** fall on different words in a few lines (renderer metrics; both are left-aligned).
- **Not tried or not possible here:** 8.6 pt heading lines match typst's page count but clip capital letters in LibreOffice (rejected). Word was not available; it may paginate differently (`docs/DOCX.md`).
- **Not required by this court:** pleading line numbers, TOC and TOA (no txwb rule found; see Governing rules). Not produced.

**docx BLOCKED:** none for the render. The gates (`tools/check.sh --engine docx`) were not run: the court has no `checks.yaml` or `rules.md` yet, so the checker cannot run on it. The evidence here is the render and the page-by-page review, not a stamp.
