# canb: adversary complaint

Doc type: **adversary complaint** (complaint commencing an adversary proceeding) in the United States Bankruptcy Court for the Northern District of California (`canb`).
Folder: `courts/ninth-circuit/california/federal/bankruptcy-northern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-appalachian-23-30564-26-03029-adversary-complaint.pdf` (31 pages, one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-appalachian-adversary-complaint.md` (a portion of the complaint: caption and counsel, nature of the action, jurisdiction, parties, first cause of action, prayer, jury demand, signature) |
| render | ok: `samples/OUTPUT-appalachian-adversary-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-appalachian-adversary-complaint.pdf` and `.txt` (`tools/overlay.sh`) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |
| tier 2 | not judged against 2 or 3 filers yet: one exemplar only (see Known gaps 1) |

File names follow the tools, not the brief's `<id>.pdf` / `<id>-overlay.pdf` wording: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`. The sample is `INPUT-<id>.md`, so the id is `appalachian-adversary-complaint`.

## Governing rules

Verified 2026-10-14. Court rules are the Bankruptcy Local Rules "effective May 4, 2026" (the court's index page says so); Civil L.R. 3-4 is taken from the N.D. Cal. Civil Local Rules page as fetched for `../../northern-district/complaint/README.md`.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| B.L.R. 1001-2(a) (https://www.canb.uscourts.gov/procedures/local-rules/1001-2-applicability-civil-local-rules) | Civil L.R. 3-4 (papers presented for filing) applies in bankruptcy, except 3-4(c)(3) (footer) and 3-4(e). Civil L.R. 3-6 (jury demand) applies. Civil L.R. 3-5 (jurisdiction and divisional assignment paragraphs) is not incorporated. | Pleading paper (numbered lines 1 to 28, double rules, 1 inch top margin); 12 pt EB Garamond; 24 pt pitch. Footer is kept as a convention (see Known gaps 4). |
| Civil L.R. 3-4(c)(1), (c)(2) (via B.L.R. 1001-2) | 8½ × 11 inch white paper; double-spaced text, no more than 28 lines per page; standard proportional font, 12 pt or larger. | `page-w`, `page-h`, `lines-per-page = 28`, `pitch = 24pt`, `type-size = 12pt`, `font-family`. |
| Civil L.R. 3-4(a)(1) (via B.L.R. 1001-2) | Counsel's name, address, telephone, email and state bar number upper left. | `counsel` frontmatter: a list of columns (two side by side, as in the exemplar). |
| Civil L.R. 3-4(a)(3) (via B.L.R. 1001-2) | Court title from line 8, unless counsel needs more room. | `court-title`; counsel columns push the title down (the sample's counsel uses 8 pitch rows, so the title is on line 9). |
| Civil L.R. 3-6 (via B.L.R. 1001-2) | "Demand for jury trial" in the caption under the title. | `jury_demand: true` puts `DEMAND FOR JURY TRIAL` in the caption. |
| B.L.R. 1005-1 (https://www.canb.uscourts.gov/procedures/local-rules/1005-1-caption-and-title-papers-filed) | Caption contains the file number of the bankruptcy case and of the adversary proceeding, the debtor's name, the parties to the adversary proceeding, the chapter, and (where applicable) the hearing date, time and place. | `case_number`, `chapter`, `judge`, `adversary_number` (blank for a new complaint, which is how the exemplar was filed), `caption.debtor`, `caption.parties`. No hearing block: a complaint is not noticed for hearing. |
| Fed. R. Bankr. P. 1005 (https://www.law.cornell.edu/rules/frbp/rule_1005) | Caption of the case: court, title of the case (the debtor), case number. | As B.L.R. 1005-1. |
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | Caption of an adversary pleading must substantially conform to the appropriate version of Official Form 416 (416A, caption of a complaint: the court, the parties, the adversary number, the title). | `caption` as above. |
| Fed. R. Bankr. P. 9004 (https://www.law.cornell.edu/rules/frbp/rule_9004) | A document filed must have a caption with the court name, the title, the case and adversary-proceeding numbers, and a brief designation of the document's character. Clearly legible. | `brief_title` in the caption (the designation: "Complaint for ... and Demand for Jury Trial"). |
| Fed. R. Bankr. P. 7001 (https://www.law.cornell.edu/rules/frbp/rule_7001) | Types of adversary proceedings (for example, (f) dischargeability; (i) declaratory judgment related to (a)–(h)). | Not template text; the sample's proceeding is a declaratory judgment under 7001(i), stated in the complaint's own paragraphs. |
| B.L.R. 7008-1 (https://www.canb.uscourts.gov/procedures/local-rules/7008-1-consent-entry-final-order-or-judgment-bankruptcy-court-complaint) | The complaint must say whether the pleader consents to entry of a final order or judgment by the Bankruptcy Court. | Author content: the sample's jurisdiction paragraph ("non-core ... does not consent"). The template does not check the wording. |
| B.L.R. 7003-1 (https://www.canb.uscourts.gov/procedures/local-rules/7003-1-cover-sheet) | Every complaint initiating an adversary proceeding must be accompanied by a completed Adversary Proceeding Cover Sheet. | Not generated (a separate form from the Clerk). Required with the first filing. |
| Fed. R. Civ. P. 10(b) (as applied by Fed. R. Bankr. P. 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template (`allegations()`); headings and lists are not. |

Not produced by this template (separate papers): the adversary cover sheet (B.L.R. 7003-1); the summons; the Certification of Interested Entities or Persons (Civil L.R. 3-15, if the court applies it); any Rule 7.1 disclosure.

## Layout

- Numbered lines 1 to 28 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form, as in the exemplar).
- Top margin 1 inch: line 1 sits on the top margin, the 28 lines end at 10.33 inches, the footer is in the bottom margin.
- Counsel block single-spaced in columns on lines 1 to 8; court title, caption and title of the paper follow.
- Caption: the debtor ("In re:") above the adversary parties, with "v." between the parties; the right column holds the case number, chapter, judge, adversary number, the title (bold caps) and the jury demand legend.
- Numbered paragraphs at 0.5 inch indent; level 1 headings centered bold caps; level 2 centered bold; level 3 bold italic. Lists are lettered (a), (b), ... and may break across pages. A heading stays with the paragraph after it. A heading may run to two numbered lines.
- Signature block (dated, "Respectfully submitted", firm, "By: /s/" and the signer and the other signers) is kept whole on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold italic left), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `chapter`, `judge` (optional), `adversary_number` (blank for a new complaint), `court` (list of lines: court, district, division), `counsel` (list of columns, each a list of lines), `caption.debtor` (optional: `names`, `designation`), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `jury_demand`, `lead_in` (unnumbered lead-in paragraph, optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes (the exemplar's footnote 1 is not transcribed), raw typst.
- Do not type paragraph numbers in the text; the template numbers the allegations.

## Overlay (what it shows)

`samples/OVERLAY-appalachian-adversary-complaint.pdf`: red = our render, blue = the filed exemplar, black = both. Pages are paired by word overlap (`.txt`). Pages 1 to 6 pair with the same-numbered exemplar pages (word overlap 61% to 95%). Pages 7 to 9 pair with exemplar pages 23, 29 and 30 because the sample skips the exemplar's pages 8 to 22 and 24 to 28 (the transcription is a portion of the filing). The overlay is a diagnostic, not a score.

## Review of the rendered pages (Gate 2 equivalent; 60 dpi, every page viewed)

| Page | Result |
|---|---|
| 1 | Counsel columns on lines 1 to 8; court title lines 9 to 11; caption with debtor and parties; right column with case number, chapter, judge, blank adversary number, title and jury demand. Footer shows title and case number. No spill. Pass, with the Known gap 2 note (title on line 9). |
| 2 | Unnumbered lead-in, NATURE OF THE ACTION heading, paragraphs 1 to 7 on the numbered lines. Pass. |
| 3 | Paragraphs 8 to 11; list (a) starts at the bottom. Pass. |
| 4 | List (a) to (g) wrapped and lettered; paragraphs 12 and 13. Pass. |
| 5 | Paragraphs 14 to 20; JURISDICTION AND VENUE and THE PARTIES headings centered; no heading at a page foot. Pass. |
| 6 | Paragraphs 21 to 27; FACTUAL ALLEGATIONS heading and "A." sub-heading; policy list (1., 2., 3. as numbers; the exemplar letters them a., b., c. (Known gap 5)). Pass. |
| 7 | FIRST CAUSE OF ACTION (two-line sub-heading), paragraphs 28 to 31, PRAYER FOR RELIEF, items (a) to (d). Pass. |
| 8 | Prayer items (e) to (l), JURY DEMAND heading and paragraph 32 (Known gap 6). Pass. |
| 9 | Signature block, kept whole: Dated, Respectfully submitted, firm, "By: /s/" with the signer and the other signers. Pass (the block moved from page 8 as a unit). |

## Searches and exemplar choice

- CourtListener search (`https://www.courtlistener.com/api/rest/v4/search/`, `type=r`, `court=canb`, "adversary proceeding" complaint) returned several adversary filings in this court. The Appalachian complaint (adversary 26-03029, filed 2026-06-26) is text-based (Times New Roman embedded, `pdftotext` yields text), on pleading paper with the caption the rules require, and 31 pages long.
- Other hits were not saved: 26-03039 Goldberg v. United States (cover sheet attachment, not checked for pleading format); 26-03016 Callaway (a motion to dismiss, not a complaint); 26-03001 RCASF withdrawal (a motion, see `../motion-brief/README.md`).

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The brief asks for one exemplar per doc type, so the second filer (not saved) is not used. Tier 2 is not judged against two filers yet.
2. **Counsel block length.** The sample's counsel columns run to 8 pitch rows, so the court title is on line 9 rather than line 8. Civil L.R. 3-4(a)(3) allows the extra room. The filed exemplar fits its counsel on lines 1 to 10 in two columns; the template matches that layout.
3. **Font.** EB Garamond is the only vendored font (`fonts/`). The exemplar is Times New Roman; Civil L.R. 3-4(c)(2)(A) names Times New Roman as an example. EB Garamond at 12 pt has a smaller x-height. The 12-point minimum is met. A Times-metric font would remove the difference; `fonts/` is shared and is not edited here.
4. **Footer.** The footer (title and case number) follows the exemplar. B.L.R. 1001-2 excludes Civil L.R. 3-4(c)(3), so the footer is a convention, not a rule requirement. The footer title wraps to two lines.
5. **Policy list letters.** The exemplar letters its policy list a., b., c.; the template letters every list (a), (b), ... This is a template convention (list lettering is shared with the prayer). Recorded as ACCEPTED.
6. **Jury demand numbering.** The exemplar leaves the JURY DEMAND paragraph unnumbered; the template numbers every body paragraph (paragraph 32). Recorded as OPEN: a convention choice for a numbered-paragraph template; a fix would need an unnumbered paragraph style in the template.
7. **Footnote.** The exemplar's footnote 1 ("Appalachian alleges on personal knowledge...") is not transcribed: the template does not support footnotes in this doc type. Recorded as OPEN.
8. **Caption debtor line.** The exemplar's "Debtor and Debtor in Possession" designation is right-indented and so is the template's; the exemplar's underline between the debtor and the adversary parties is not drawn (the caption's bottom rule is). ACCEPTED.
9. **Paragraph numbers differ.** The sample numbers its paragraphs from 1; the filed numbering (1 to 75, with gaps in the sample) is not transcribed.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
11. **Legend.** The sample has no class-action legend; Civil L.R. 3-4(a)(5) is not used.
