# lawb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the Western District of Louisiana (`lawb`). Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-andrus-v-c-g-boats-19-05061-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-andrus-adversary-complaint.md` (the whole filed complaint, 8 pages, transcribed) |
| render | ok: `samples/OUTPUT-andrus-adversary-complaint.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-andrus-adversary-complaint.pdf` and `.txt` |
| pages reviewed | 7 of 7 (every page rendered and looked at after the last template change; ¶9–10 checked at 110 dpi) |

File names: `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the tools hard-code these names), so the sample PDF and overlay carry those names rather than `<id>.pdf` and `<id>-overlay.pdf`.

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Where it lives in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to an adversary pleading; the caption must substantially conform to Official Form 416. Source: https://www.law.cornell.edu/rules/frbp/rule_7010 (text as amended Apr. 2, 2024, eff. Dec. 1, 2024). | `court-title`, `caption`, `cover` |
| Fed. R. Civ. P. 10(a) | Caption: court's name, a title, a file number, a Rule 7(a) designation. Source: https://www.law.cornell.edu/rules/frcp/rule_10 (as amended Apr. 30, 2007, eff. Dec. 1, 2007). | `court-title` (court name is fixed in the template), `caption.right` (case and adversary numbers), `title` ("COMPLAINT") |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." Same source. | `allegations()`: each paragraph is numbered; headings, the opening paragraph and the prayer lead-in are not |
| Fed. R. Bankr. P. 7008(a) | The complaint must state whether the pleader consents to entry of final orders or judgment by the bankruptcy court. (The core/non-core statement was removed in 2016.) Source: https://www.law.cornell.edu/rules/frbp/rule_7008 (as amended Apr. 2, 2024, eff. Dec. 1, 2024). | Not asserted by the template (the exemplar does not contain the consent statement; see gaps). |
| Fed. R. Bankr. P. 9004(a) | Papers must be clearly legible. Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (as amended Apr. 2, 2024, eff. Dec. 1, 2024). | whole template: 12–13 pt, black text on white |
| LBR 7001-1 | The adversary complaint is filed in the division where the chapter case is pending. Source: W.D. La. Local Bankruptcy Rules, revised as of April 1, 2026, https://www.lawb.uscourts.gov/sites/lawb/files/Local%20Bankruptcy%20Rules%20Revised%20as%20of%201%20April%202026%20with%20Appendices.pdf (fetched and read 2026-10-14). | `division` frontmatter (case-specific); `court-title` prints it under the court name |
| LBR 7003-1 | An adversary cover sheet accompanies every adversary proceeding. | Not produced: the cover sheet is a separate filing (see gaps). |
| LBR 7004-1 | The clerk issues the summons; the plaintiff serves it under FRBP 7004. | Not produced: a separate paper (see gaps). |
| LBR 5005-1(b) | The signature block includes the name, state bar number, address, telephone and email (if applicable) of the signing party or attorney. Same source. | `signature` frontmatter: firm, "By:" line, names with bar numbers, address, telephone, `counsel_for` |

No LBR gives a typeface, margin, spacing or line-count rule for adversary complaints (`grep` of the full LBR text finds none), and FRBP 9004 sets only legibility. The layout is therefore the exemplar's (1-inch margins, double-spaced body, centered headings, caption with a divider), in EB Garamond, the only typeface vendored in `fonts/`.

## Exemplar

- `exemplars/FILED-EXAMPLE-andrus-v-c-g-boats-19-05061-adversary-complaint.pdf`: *Andrus v. C & G Boats, Inc.*, Adv. Proc. 19-05061 (main case *In re Rooster Petroleum, LLC*, No. 17-50708, Chapter 7, Lafayette Division), complaint for avoidance and recovery of preferential transfers, 8 pages, filed 2019-05-31 by the chapter 7 trustee's counsel. Provenance and the searches are in `exemplars/SOURCE.md`.
- Only one exemplar. EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; see gaps.

## Sample and template

- `samples/INPUT-andrus-adversary-complaint.md` carries the filing's text: caption (frontmatter), the opening paragraph (`>`, unnumbered), headings (`#`), numbered paragraphs, the transfers table (¶17), the prayer's list (`1.` items, lettered (a)–(d)), the prayer lead-in (`>`), and the signature block (frontmatter). Coverage against the filed PDF: every word of the filing except the ECF header and footer text ("Page n of 8", "19-05061 - #1 File 05/31/19 …"), which are not part of the document.
- Markdown contract (for future samples): YAML frontmatter (`division`, `caption.left` as `{t, i}` items where `i` is the indent level, `caption.right` as lines, `title`, `signature` with `firm`, `by`, `lines`, `counsel_for`); then blank-line-separated chunks: `#` heading (level 1 centered bold underlined caps: the template does not uppercase, so write the caps as filed), a `>` paragraph (unnumbered), a `1.` list (lettered (a), (b)…), a `|` table, or any other chunk (one numbered paragraph). The template numbers paragraphs; the sample does not put numbers in its text.
- `typst/lawb-adversary-complaint.typ` (template) and `typst/main.typ` (entry point). Court name and layout constants are in the template; every case-specific word comes from the frontmatter.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/adversary-complaint samples/INPUT-andrus-adversary-complaint.md
sh tools/overlay.sh courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/adversary-complaint andrus-adversary-complaint
```

- Render: typst compiled with `--ignore-system-fonts` and no warnings (`render.sh` fails on any warning). `pdffonts` shows EBGaramond-Regular and -Bold only.
- Overlay: red = our render, blue = exemplar, black = both. Pages are paired by word overlap: ours p.1–3 ↔ filed p.1–3, ours p.4 ↔ filed p.5, ours p.5 ↔ filed p.6, ours p.6 ↔ filed p.7, ours p.7 ↔ filed p.8. The overlay is a diagnostic, not a score: the filed copy is pleading-style with a different caption layout and the sample is not on its line grid, so the text will not coincide line for line. The page mapping above is what matters for review.

## Visual review (Gate 2 record, 7 of 7 pages, rendered at 50 dpi and looked at; ¶9–10 at 110 dpi)

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, COMPLAINT, caption (parties left, case and adversary numbers right), opening paragraph, JURISDICTION ¶1–3 | OK. |
| 2 | VENUE ¶4, PARTIES ¶5–6, BACKGROUND FACTS, ¶7–8 and the start of ¶9 | OK after the spacing fix below. |
| 3 | ¶9–16 | OK after the spacing fix. Fix: paragraphs overprinted each other (typst adds no leading after a paragraph's last line; paragraph spacing now equals the leading). ¶9/¶10 re-checked at 110 dpi. |
| 4 | End of ¶16, ¶17 with the transfers table, the unnumbered "(the foregoing amounts…)" line, ¶18, COUNT I heading, ¶19–20 | OK. |
| 5 | End of ¶20, ¶21–23, COUNT II heading (wraps to two lines at "§ 502(d)"; non-breaking space after the §), ¶24–25 | OK. Fix: the template no longer uppercases headings (it turned "502(d)" into "502(D)"). |
| 6 | RELIEF REQUESTED ¶26–28, WHEREFORE lead-in, prayer items (a)–(b) | OK. |
| 7 | Prayer items (c)–(d), signature block (firm, "By:" line, four attorneys with bar numbers, address, telephone, telecopier, counsel for plaintiff) | OK. |

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers from different filers; the brief asks for one per doc type. A second W.D. La. adversary complaint (*Andrus v. Island Operating Co.*, Adv. 19-05054, same trustee and counsel) was seen in the search but is the same filer, so it would not satisfy the rule either. Tier 2 is therefore not judged against two filers.
2. **Page count and type size.** The filed copy is 8 pages in Times 12; the render is 7 pages in EB Garamond 13 pt. The template uses 13 pt because EB Garamond looks smaller than Times at 12 pt (the same choice cand's templates make). No LBR or FRBP rule sets a type size for this paper, so 13 pt is a tier-2 judgment, not a rule.
3. **Paragraph ¶22.** The filed complaint skips paragraph 22 (21 is followed by 23). The template numbers without gaps, so from ¶22 on each sample number is one less than the filed number (sample ¶22 is filed ¶23).
4. **Adversary number.** The filed caption leaves "ADVERSARY PROCEEDING NO.:" blank. The sample prints 19-05061, the number stamped on the docket. The sample is a transcription with that one change.
5. **FRBP 7008(a) consent statement.** Required by the rule; the exemplar has none; the template does not check or print one. A consent paragraph would be author text in the body.
6. **Signature block email.** LBR 5005-1(b) requires an email address "if applicable." The filed block has telephone and telecopier only; the template prints what the sample supplies and does not assert the email field.
7. **Separate filings not produced.** The adversary cover sheet (LBR 7003-1; the docket lists it as a separate attachment, not part of this PDF), the summons (LBR 7004-1) and any Rule 7.1 disclosure are separate papers and are not part of this template.
8. **Footer.** The filed copy has "Page n of 8" and an ECF stamp. The template prints a centered page number only. The ECF stamp is not reproduced (it is not document text).
9. **Caption layout.** The filing and the template both divide the parties from the case numbers with one vertical rule; the filing has no `)` column. Tier-2 convention, recorded here.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The render and overlay commands above are the checks that were run.
11. **Alignment.** Body text is left-aligned, not justified. The exemplar's justification is not asserted.
12. **Exemplar vintage.** Filed in 2019; the rules in the table above are the current text (FRBP as amended Dec. 1, 2024; LBR revised April 1, 2026). The template follows the current text.
