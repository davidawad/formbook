# txwb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the Western District of Texas (`txwb`).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-osherow-25-01073-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-osherow-complaint.md` (a portion of the 14-page filing, see Known gaps) |
| render | ok: `samples/OUTPUT-osherow-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-osherow-complaint.pdf` and `OVERLAY-osherow-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the tools, not the brief's `<id>.md` shorthand: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf` (the default of `tools/render.sh`), and the overlay `OVERLAY-<id>.pdf/.txt` (the default of `tools/overlay.sh`, which reads `OUTPUT-<id>.pdf`).

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Bankr. P. 7001 | An adversary proceeding is commenced by a complaint; the exemplar cites Rule 7001 for its nature. | Author content (the sample's jurisdiction paragraphs). Not checked by the template. | Rule number as cited on the exemplar. Rule text not fetched in this run. |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to a pleading in an adversary proceeding; the caption must substantially conform to the appropriate Official Form 416 (A, B or D). | `court-title`, `caption` (court name, division, debtor and case number at right, adversary number, title of the paper). | Fetched from https://www.law.cornell.edu/rules/frbp/rule_7010 on 2026-10-14 (summary of the text). |
| Fed. R. Civ. P. 10(a) (via 7010) | Caption: court name, title, file number, and the Rule 7(a) designation. | As above; the designation is the party designation (Plaintiff / Defendant). | Via the 7010 summary above. |
| Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template (`allegations()`); headings and the prayer list are not. | Rule text not fetched in this run. |
| Fed. R. Bankr. P. 9004(a) | A petition, pleading, schedule or other document must be clearly legible; common abbreviations are acceptable. | Typography: 12 pt EB Garamond, one-inch margins, double spacing. | Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. The rule sets no point size, margin or spacing. |
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
4. **Font.** EB Garamond (vendored, the only font in `fonts/`), not Times New Roman. The exemplar is in a Times-like face; at 12 pt EB Garamond sets smaller. Whether the court wants a Times metric face is a question for David.
5. **Spacing and margins are conventions.** Neither Rule 7010 nor Rule 9004(a) sets them, and no W.D. Tex. adversary-complaint rule was found. Double spacing and one-inch margins follow the exemplar's layout.
6. **Local rules not verified.** The W.D. Tex. local bankruptcy rules text was searched for (WebSearch found L.R. 9014-1 and the court's pages, not an adversary-complaint format rule). A local adversary-complaint form rule may exist; it is not checked here.
7. **Caption without a § column.** The exemplar uses the IN RE block and a plain party block with no § column; another txwb complaint (Lowe, see SOURCE.md) uses a § column. The template follows the exemplar; both forms appear in the court.
8. **Second exemplar not saved.** Lowe v. Neugebauer (San Antonio Division, 19 pp.) is a second filer for tier-2 comparison and is not in `exemplars/`; see SOURCE.md.
9. **No cover sheet, summons or disclosure statement** (see Governing rules).
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. Render and overlay were run; the visual review above is the Gate 2 equivalent.

## Searches and sources

- Exemplar and other complaints: see `exemplars/SOURCE.md`.
- Rule text: FRBP 7010 and 9004(a) from Cornell LII, fetched 2026-10-14; W.D. Tex. L.R. 9014-1 from https://www.txwb.uscourts.gov/l-rule-9014-1-contested-matters (via WebFetch, 2026-10-14; the page was summarized, not quoted in full).
