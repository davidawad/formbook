# mssb: adversary complaint (Bankruptcy Court, S.D. Mississippi)

Doc type: **adversary-complaint** in the United States Bankruptcy Court for the Southern District of Mississippi (`mssb`). Folder: `courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district/adversary-complaint/`. One self-contained doc-type folder: no shared files.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-griffin-18-00028-adversary-complaint.pdf` (primary; Trustee's complaint, 16 pp.). Second filer, for tier 2: `exemplars/FILED-EXAMPLE-tate-25-06012-adversary-complaint.pdf` (Debtor's complaint, 3 pp.). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-griffin-adversary-complaint.md`: the whole filed complaint, transcribed (see Known gaps for the two additions) |
| render | ok: `samples/OUTPUT-griffin-adversary-complaint.pdf`, 15 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-griffin-adversary-complaint.pdf` and `.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 15 of 15 (every page rendered at 60 dpi and viewed, final template) |
| tier 1 | rules-driven template; asserts that stop the build if counsel e-mail, bar number, telephone or street address, the consent statement, the caption case data, or the title is missing (checked: a sample with no e-mail fails with the rule cited). |

`court.json` and the court-root `typst/`, `samples/` are untouched. Gates `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder is not, so they were not run.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `mssb-adversary-complaint`. |
| `typst/mssb-adversary-complaint.typ` | Template. Parameters at the top, each with its rule. Rule asserts in `check-meta`. |
| `samples/INPUT-griffin-adversary-complaint.md` | Markdown contract sample (frontmatter + body). |
| `samples/OUTPUT-griffin-adversary-complaint.pdf` | `sh tools/render.sh courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district/adversary-complaint samples/INPUT-griffin-adversary-complaint.md` |
| `samples/OVERLAY-griffin-adversary-complaint.pdf`, `.txt` | `sh tools/overlay.sh <this folder> griffin-adversary-complaint` (red = ours, blue = filed, black = agree) |
| `exemplars/` | Two filed exemplars and `SOURCE.md`. |

File names follow the file-role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`), which is what `tools/render.sh` and `tools/overlay.sh` read and write by default. The brief's `<id>.md` / `<id>-overlay.pdf` names would not have matched the tools.

## Governing rules

Primary source for the local rules: Joint Uniform Local Bankruptcy Rules, Northern and Southern Districts of Mississippi, as amended December 1, 2022, <https://www.mssb.uscourts.gov/sites/mssb/files/mssb_local_rules_20221201.pdf>. Text extracted and read in this box on 2026-10-14 (rule pages cited below are the rulebook's printed pages). **Caveat:** a proposed redline of the joint rules, "Eff. 3-1-2026", is posted at <https://www.msnb.uscourts.gov/sites/msnb/files/Proposed%20Uniform%20Local%20Rules%20%28Redline%20Version%29%20Eff.%203-1-2026.pdf>. Its adoption is not confirmed here. Check the operative rules before relying on this table.

Federal rules: Fed. R. Bankr. P. 7008, 7010 and 9004 read in full on 2026-10-14 from Cornell LII (<https://www.law.cornell.edu/rules/frbp/rule_7008>, `rule_7010`, `rule_9004`). LII is a secondary copy; check the official text on uscourts.gov.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Miss. Bankr. L.R. 5005-1(a)(2)(G) (p. 37) | Papers 8½ × 11 in.; legible in a font no smaller than 12 point; double-spaced, except that quotations, footnotes and legal descriptions may be single-spaced. | `page-w/h`, `type-size = 12pt` (footer and captions too), `body-leading` (24 pt pitch, double spacing). |
| Miss. Bankr. L.R. 5005-1(a)(2)(H)(i) (p. 37) | Every pleading: attorney's name, complete address, telephone, e-mail, Mississippi Bar number. | Signature block; `check-meta` asserts e-mail, Bar number, telephone and a street address. |
| Miss. Bankr. L.R. 5005-1(a)(2)(I) (p. 38) | Clear designation of content; a paper with multiple contents puts all of them in the caption. | `title` frontmatter, printed under the caption in capitals; `check-meta` asserts it. |
| Miss. Bankr. L.R. 7008-1 (p. 42) and Fed. R. Bankr. P. 7008(a) | An adversary complaint states whether the pleader consents to entry of final orders or judgment by the bankruptcy court. The jurisdiction allegation refers to the name, number and chapter of the case and to the district and division. | `consent` frontmatter, printed as an unnumbered paragraph after the lead-in; `check-meta` asserts it is present. The jurisdiction allegation is author text (see Known gaps). |
| Fed. R. Bankr. P. 9004(b) | Caption: court name; case title; case number and adversary number; brief designation of the document. | `cover`, `caption` (the bankruptcy case block on the right, the adversary number on the "V." line, the title below). |
| Fed. R. Bankr. P. 7010 (applies Fed. R. Civ. P. 10) | Caption substantially in the form of Official Form 416; numbered paragraphs, each limited as far as practicable to one set of circumstances (FRCP 10(b)). | Paragraphs numbered by the template (`allegations`, `para-counter`), not in the markdown. |
| Miss. Bankr. L.R. 9011-1(a)(1)-(2) | Signature by login: attorney's name shown as "/s/" with the typed name. | `signature-block` prints `/s/ <signer>`. |

Not produced by this template (separate filings, not part of the complaint): the adversary proceeding cover sheet (Official Form 104; the Tate exemplar's Dkt 1-1 is one); the summons (Official Form 287); the Rule 7.1 disclosure; the privacy redaction under Fed. R. Bankr. P. 9037 (checked by hand only: the sample contains no identifiers beyond those in the filing).

## Layout

- Court name centred (bold) on lines 1 and 2; division on a third line if the frontmatter gives one.
- Caption: debtor block with case number and chapter on the right; parties with designations on the right (PLAINTIFF, DEFENDANTS); "V." with "ADV. PROC. NO." on the right.
- Title in bold capitals, centred, under the caption.
- Body: double-spaced, 0.5 in. first-line indent; numbered paragraphs 1, 2, ... (the template numbers them); level-1 headings centred bold capitals (`#`); level-2 centred bold (`##`); level-3 bold italic (`###`); sub-items (a), (b), ... (`- ` lines); a table row block (`|`) single-spaced and unnumbered; `WHEREFORE` paragraphs unnumbered; footnotes single-spaced at the foot of the page.
- Every block of text is rounded up to whole 24 pt rows (`on-grid`), so the next block starts on the grid. Without this, typst puts the leading between lines and each block's last line runs into the next (found and fixed in this build).
- Signature: date line, "Respectfully submitted," and the signature block in the right half, with counsel details below.

## Overlay

`samples/OVERLAY-griffin-adversary-complaint.pdf` puts our render (red) over the best-matching page of the filed Griffin complaint (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the final run:

- p.1 ↔ p.1 (69%), p.2–p.5 ↔ same numbers (74–87%): caption and the first numbered paragraphs line up.
- p.6 ↔ p.6, p.7 ↔ p.7 (60%, 54%): ¶¶ 36–53, which carry the fee table and footnotes.
- p.8 ↔ p.9 (46%): the lowest match. The same passage falls on different pages in the filing, so the closest page is paired, with a low score.
- p.9–p.14 ↔ p.10–p.15 (73–94%): Counts II–VI and the prayer.
- p.15 ↔ p.16 (58%): prayer item (g), date, signature block.

## Page review (Gate 2)

Every page of `OUTPUT-griffin-adversary-complaint.pdf` was rendered at 60 dpi and viewed in its final form.

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption, COMPLAINT, lead-in, consent placeholder, ¶ 1 | OK. The consent placeholder is in the body on purpose: see Known gaps. |
| 2 | ¶¶ 2–7 | OK. |
| 3 | ¶¶ 8–12, footnotes 1 and 2 | OK. |
| 4 | "FACTS", "Facts specific to Bobby Joe Griffin" (bold italic), ¶¶ 13–23 | OK. |
| 5 | ¶¶ 24–35 | OK. |
| 6 | ¶¶ 36–45, footnote 3 | OK. |
| 7 | ¶¶ 46–53; fee table (¶ 49); footnote 4 | OK. The table is two columns, no rules. ACCEPTED: the filing lists the fees in a plain list. |
| 8 | ¶¶ 54–60; "COUNT I." and "TURNOVER OF ESTATE PROPERTY"; footnotes 5–7 | OK. |
| 9 | ¶¶ 60 (cont.)–69; "COUNT II." | OK. |
| 10 | ¶¶ 70–78; "COUNT III.", "COUNT IV." | OK. |
| 11 | ¶¶ 79–89; "COUNT V." | OK. |
| 12 | ¶¶ 90–99 (sub-items (a)–(c) of ¶ 99) | OK. |
| 13 | Sub-items (d) of ¶ 99; ¶¶ 100–104 and sub-items (a)–(h) of ¶ 101 | OK. |
| 14 | ¶¶ 105–108; "WHEREFORE" and prayer items (a)–(f) | OK. |
| 15 | Prayer item (g); date; signature block | OK. The signature block sits alone on the page below item (g), as in the filing. |

Tier-2 findings (OPEN or ACCEPTED):

- Prayer and sub-items are lettered (a), (b), ... in the template. The filing letters the prayer A., B., ... and the sub-items (a), (b). One list style is used. ACCEPTED.
- Body typeface: EB Garamond, the only serif vendored in `fonts/`. The filing's face is not confirmed here: `pdffonts` reports the exemplar's text as Liberation Sans-named subsets, but the page image of the Lentz memorandum (the second exemplar in the motion folder) reads as a Times-style serif. At 12 pt, EB Garamond has a smaller x-height than Times, so the text looks smaller. The rule's 12 point minimum is met. ACCEPTED pending David's decision on whether to bump the size (see Known gaps).
- Length: 15 pages against the filing's 16. The sample is complete, so the difference is the face.
- Paragraph numbering matches the filing: 1 to 108, the same numbers.

## Known gaps

1. **Consent statement (FRBP 7008(a); Miss. Bankr. L.R. 7008-1).** The filed complaint has no statement of consent to final orders. The sample frontmatter `consent` is a visible bracketed placeholder ("NOT IN THE FILED EXEMPLAR ..."), not invented text. The template asserts that the field is present. A real filing needs the pleader's own statement.
2. **Jurisdiction allegation (FRBP 7008(a)).** The rule requires the jurisdiction allegation to refer to the bankruptcy case's name, number and chapter and to the district and division. As transcribed, ¶ 1 refers to "the above-captioned Chapter 7 case", and the district and division appear only in the caption. The template does not check the allegation's text. This is recorded as a finding about the exemplar, not an error in the template.
3. **Sample text.** The Griffin complaint is transcribed whole. The only text in the sample that is not in the filing is the consent placeholder (gap 1). The frontmatter holds the filing's caption, counsel and date data, reformatted as fields. Word-level check against the filing's text layer: every word of the sample appears in the filing except the words of the placeholder, the frontmatter keys, and "6th" (the filing's superscript "th" in *Cortez*). The filing's words that the sample lacks are its ECF page headers ("Dkt", "Entered", "Page"), the court name and "Respectfully submitted" (both printed by the template), and the ¶ numbers 100–108 (printed by the template, not in the markdown).
4. **Second exemplar.** The Tate complaint (25-06012, Dkt 1, 3 pp.) is kept for a second filer. `overlay.sh` writes one overlay per sample and uses the first exemplar it finds, so no overlay against Tate was produced. Tier 2 was judged against the Griffin filing only. A second overlay needs a different output name.
5. **Margins.** The uniform rules set no margin; the template uses one inch on each side.
6. **Footer.** The footer is the page number only, at 12 pt. The filing's footer is not transcribed.
7. **Overlay size.** The overlay PDF is 3.4 MB (100 dpi page images).
