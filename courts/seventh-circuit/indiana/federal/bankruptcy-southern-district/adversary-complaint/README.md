# S.D. Ind. bankruptcy (insb): adversary complaint

Doc type: **adversary complaint** (complaint commencing an adversary proceeding, with numbered allegations, counts, prayer and signature). Court: United States Bankruptcy Court, Southern District of Indiana. Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 6 of 6. Nothing here sets `court.json` status.

## Governing rules

Verified 2026-10-14. Each row is from the text named in its source column.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| INSB-FORM-001 | Fed.R.Bankr.P. 7010 (eff. Dec. 1, 2024), text at https://www.law.cornell.edu/rules/frbp/rule_7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding." The caption must closely follow the appropriate version of Official Form 416. | `typst/insb-adversary-complaint.typ` cover: court title, bankruptcy caption, adversary caption, `title`. The Form 416 text itself was not fetched; the layout follows the exemplar's caption and is checked against the rule's wording only. |
| INSB-FORM-002 | Fed.R.Civ.P. 10(b), applied by Rule 7010 | Numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each plain paragraph is numbered; headings, lettered items, quotations, the prayer and bracketed notes are not. The text of Rule 10(b) was not fetched; cited from the incorporated rule. |
| INSB-CONT-001 | Fed.R.Bankr.P. 7008(a) (eff. Dec. 1, 2024), text at https://www.law.cornell.edu/rules/frbp/rule_7008 | The jurisdiction allegation must include the name, number and Code chapter of the case the proceeding relates to, and the district and division where it is pending. The complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court. | Body text (author-written; see the sample's paragraphs 1, 5 and 6). Not checked by the template. |
| INSB-FORM-003 | Fed.R.Bankr.P. 9004(a) (eff. Dec. 1, 2024), text at https://www.law.cornell.edu/rules/frbp/rule_9004 | "A petition, pleading, schedule, or other document must be clearly legible." | Whole template: 12 pt type, vendored font. |
| INSB-FORM-004 | S.D.Ind. Bankr. L.R. B-5005-3 (Local Rules as amended through Dec. 1, 2025), https://www.insb.uscourts.gov/sites/insb/files/Local-Rules.pdf (linked from https://www.insb.uscourts.gov/content/local-rules) | "Papers submitted for filing shall be no larger than 8-1/2 by 11 in size." | `page-w`, `page-h` (US Letter). |
| INSB-SIGN-001 | S.D.Ind. Bankr. L.R. B-7007-2 (same text) | The Corporate Ownership Statement under Fed.R.Bankr.P. 7007.1 must also be filed by each non-individual party to an adversary proceeding, unless a governmental unit. | Not generated. The plaintiff here is an LLC, so a separate Corporate Ownership Statement is required. It is a separate filing, not part of this template. |

Not used, and why:
- S.D.Ind. B-9013-2 (certificate of service) applies to papers filed under Rules 9013 and 9014. A complaint is commenced under Rule 7001, so no certificate is generated. The summons and its service are separate filings.
- The Local Rules (as amended through Dec. 1, 2025) contain no font, margin, line-spacing, page-limit or caption-format rule for adversary complaints. The `Local-Rules.pdf` was searched for "font", "point", "margin", "double" and "memorand"; only the size rule (B-5005-3) matched. Every layout value in the template is therefore a **layout choice**, marked at its definition.
- Sources that did not respond: the S.D.Ind. Local Rules page on courtrules.net (403); CourtListener's API was usable but rate limited (5 requests per minute).

## Layout choices (not rules)

- **Typeface.** Face required by the rules: none. The S.D.Ind. Local Rules (as amended through Dec. 1, 2025; checked 2026-10-15, `Local-Rules.pdf`) name no typeface; B-5005-1(b)(1) requires documents to be "plainly and legibly typewritten, printed, or reproduced". Substitute: none. EB Garamond 12 pt is kept (vendored, OFL), as `docs/FONTS.md` says for a court that names no face. The exemplar is Times New Roman, which the rules do not require.
- Double spacing at a 27.6 pt baseline pitch: the exemplar's body text measured at 27.6 pt with `pdftotext -bbox-layout`. Set as `body-leading = 1.65em` on the 0.65 em line box (measured, same method as the CAND template).
- 1 inch margins on all sides. The exemplar's margins are similar.
- Numbered allegations run continuously from 1 through the whole complaint, across counts, as in the filing; lettered items display `a.`, `b.` (the exemplar's style).
- The statute quotation is set as a block quotation, indented on both sides.

## Exemplar

- `usage/SAMPLE-insb-adversary-complaint-rabobayes2659007.pdf`: Amended Complaint (ECF Doc 4), 7 pages, filed July 8, 2026 by Rabo AgriFinance LLC (Womble Bond Dickinson (US) LLP). Text layer present (Word-generated, TimesNewRomanPSMT embedded).
- Provenance, searches and the caption spelling note are in `usage/SOURCE.md`.
- One exemplar, one filer. The eval loop's tier-2 rule asks for two or three filed exemplars from different filers; this is a gap (see Known gaps).

## Sample

- `usage/INPUT-insb-adversary-complaint-rabobayes.md`: the whole amended complaint transcribed, every paragraph, the caption, counts, prayer and signature block. The ECF header is not transcribed (a court stamp, not part of the document). Exhibits A and B are referred to, not attached (as in the filing).
- The markdown contract: YAML frontmatter (`case_number`, `chapter`, `division`, `debtor`, `adversary`, `title`, `lead_in`, `date`, `signature`); `#` headings; a blank line between chunks; `(a)` and `(1)` for lettered and prayer items (shown as `a.` and `1.`); a `>` quotation; a `[...]` bracketed note. A chunk that starts with a lowercase letter continues the paragraph before it, unnumbered (the total after paragraph 16's list).
- The sample's case-specific content is only in its frontmatter and body. The template holds no case text.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-insb-adversary-complaint-rabobayes.md
sh tools/overlay.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint rabo-bayes-adversary-complaint
```

- `usage/OUTPUT-insb-adversary-complaint-rabobayes.typst.pdf`: 6 pages. Typst compiled with no warnings (`render.sh` fails on any). Vendored font only: `pdffonts` shows EBGaramond-Regular and -Bold, embedded (Identity-H).
- `usage/OVERLAY-rabo-bayes-adversary-complaint.pdf` and `.txt`: red = our render, blue = exemplar, black = both. The page map pairs pages one to one: ours p.1-6 ↔ filed p.1-6 (word overlap 47-64%). The overlay is a diagnostic, not a score: the exemplar's text sits at a different position on the page (its own spacing and caption layout), so the layers do not coincide line for line.
- File names: the repo's tools read `OUTPUT-<id>.pdf` and write `OVERLAY-<id>.pdf/.txt` (CLAUDE.md naming), so this folder uses `INPUT-`/`OUTPUT-`/`OVERLAY-`, not the `<id>.pdf` and `<id>-overlay.pdf` in the task brief.

## Visual review (Gate 2 record, all 6 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover (court title, bankruptcy caption, adversary caption, title), Preliminary Statement, paragraphs 1-2 | OK. Captions single-spaced; the adversary caption rule and the "Adv. Pro. No." blank are in place. |
| 2 | Parties, Jurisdiction and Venue; Facts (paragraphs 3-11) | OK. Headings centered and bold; numbered paragraphs on the 27.6 pt grid. |
| 3 | Paragraphs 12-17: four lettered credit lines (a-d) and the total | OK. The total continues the paragraph unnumbered, as in the filing. |
| 4 | Paragraphs 18-23; page ends with white space because Count I's heading is kept with its first paragraph | OK. Heading kept with text (no orphan). |
| 5 | Count I heading, the realleged paragraph, paragraphs 24-31; the statute quotation starts | OK. Quotation block indented on both sides, single-spaced. |
| 6 | Quotation end, paragraphs 32-33, prayer (1-4), bracketed note, signature block | OK. Signature block: "Dated" left, firm and "/s/" right, name in capitals as filed. |

Reviewed pages: 6 of 6 (final state). Earlier passes found and fixed: line overlaps where block heights were measured at the wrong width (fixed by measuring each chunk at the width it is set at), and heading size (fixed by setting heading size to body size).

## Known gaps and open choices

1. **Tier-2 exemplars.** One exemplar from one filer. The eval loop asks for two or three from different filers. Not done; a second S.D. Ind. bankruptcy adversary complaint would be needed. Searches tried are in `usage/SOURCE.md`.
2. **Form 416.** The caption layout is the exemplar's, checked against Rule 7010's wording. The Official Form 416 text itself was not fetched, so the caption is not checked line by line against the form.
3. **Corporate Ownership Statement (B-7007-2).** Not generated. Required for the LLC plaintiff in a real filing.
4. **Font.** No face named by the rules (checked 2026-10-15); EB Garamond at 12 pt is kept. Not a Times New Roman template, because the rules do not require one.
5. **Length.** The exemplar is 7 pages; the render is 6. The 8-14 page target applies to exemplars of that length, so it does not apply here. The sample is the whole filing.
6. **Quotation spacing.** The statute quotation is single-spaced, as set by the template's quotation block.
7. **Certificates.** None generated (see the rules table: B-9013-2 does not apply to a Rule 7001 complaint).
8. **Summons and other filings.** Not part of this doc type.
9. **Paragraph numbering.** The template numbers allegations itself; the sample's filed paragraph numbers are not transcribed, so they do not match the filing's numbers beyond the first paragraphs.

## Engines

**DOCX** (`docx/`). `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference: EB Garamond 12 pt, exact 27.6 pt (double) line spacing, 0.5 in first-line indent, letter page with 1 in margins, a centered page number in the footer, and single-spaced caption and signature styles. `docx/insb.lua` lays out the cover, the two caption tables, the numbered allegations (Rule 10(b)), the lettered items as "a." and "1.", the block quotation and the signature table, all from the sample's frontmatter and body.

- Matches the typst form, by construction: font and size, double spacing, first-line indent, margins, the page-number footer, the caption and signature text.
- Differs or is unverified: the allegation number is followed by a tab stop at 1 in (typst uses a 0.3 in gap); the body grid is kept by exact line spacing, not by typst's block rounding, so page breaks may fall differently; the caption rule (0.75 pt, right and bottom) and the borderless signature table are written as XML and not checked against the typst layout.
- BLOCKED: docx.pdf checks (Gates 0 and 1 on `usage/OUTPUT-rabo-bayes-adversary-complaint.docx.pdf`): not produced, because `soffice` is not installed on this box. No page was rendered or reviewed (pages reviewed 0).
- `sh tools/render.sh --engine docx` writes `usage/OUTPUT-insb-adversary-complaint-rabobayes.docx`, then fails at the soffice step (expected here). The `.docx` was checked with `unzip -tq` and `xmllint --noout` on every XML part.
- TOC and TOA: none in this doc type.
