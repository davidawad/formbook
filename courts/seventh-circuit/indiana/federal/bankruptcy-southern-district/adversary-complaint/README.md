# S.D. Ind. bankruptcy (insb): adversary complaint

Doc type: **adversary complaint** (complaint commencing an adversary proceeding, with numbered allegations, counts, prayer and signature). Court: United States Bankruptcy Court, Southern District of Indiana. Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 7 of 7 (typst and docx). Nothing here sets `court.json` status.

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

- **Typeface.** Face required by the rules: none. The S.D.Ind. Local Rules (as amended through Dec. 1, 2025; checked 2026-10-15, `Local-Rules.pdf`) name no typeface; B-5005-1(b)(1) requires documents to be "plainly and legibly typewritten, printed, or reproduced". Substitute: none. Times New Roman 12 pt (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike; the exemplar is Times New Roman too.
- Double spacing at a 27.6 pt baseline pitch: the exemplar's body text measured at 27.6 pt with `pdftotext -bbox-layout`. Set as exact 27.6 pt line boxes (`pitch-body`; single lines 13.8 pt, `pitch-single`) on the shared cross-engine layout model (`lib/typst/xengine.typ`), with no extra space between paragraphs.
- 1 inch margins on all sides. The exemplar's margins are similar.
- Numbered allegations run continuously from 1 through the whole complaint, across counts, as in the filing; lettered items keep their label as written (`(a)`, `(1)`) in a 0.6 in box after the 0.5 in indent, their lines hanging at 1.1 in; an allegation number sits in a 0.5 in box after the 0.5 in indent, its text from 1 in.
- The statute quotation is set as a block quotation, indented on both sides.

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: Amended Complaint (ECF Doc 4), 7 pages, filed July 8, 2026 by Rabo AgriFinance LLC (Womble Bond Dickinson (US) LLP). Text layer present (Word-generated, TimesNewRomanPSMT embedded).
- Provenance, searches and the caption spelling note are in `usage/SOURCE.md`.
- One exemplar, one filer. The eval loop's tier-2 rule asks for two or three filed exemplars from different filers; this is a gap (see Known gaps).

## Sample

- `usage/INPUT-adversary-complaint.md`: the whole amended complaint transcribed, every paragraph, the caption, counts, prayer and signature block. The ECF header is not transcribed (a court stamp, not part of the document). Exhibits A and B are referred to, not attached (as in the filing).
- The markdown contract: YAML frontmatter (`case_number`, `chapter`, `division`, `debtor`, `adversary`, `title`, `lead_in`, `date`, `signature`); `#` headings; a blank line between chunks; `(a)` and `(1)` for lettered and prayer items (shown as `a.` and `1.`); a `>` quotation; a `[...]` bracketed note. A chunk that starts with a lowercase letter continues the paragraph before it, unnumbered (the total after paragraph 16's list).
- The sample's case-specific content is only in its frontmatter and body. The template holds no case text.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/seventh-circuit/indiana/federal/bankruptcy-southern-district/adversary-complaint rabo-bayes-adversary-complaint
```

- `usage/OUTPUT-adversary-complaint.typst.pdf`: 7 pages. Typst compiled with no warnings (`render.sh` fails on any). Vendored font only: `pdffonts` shows Times New Roman regular and bold, embedded.
- `usage/OVERLAY-rabo-bayes-adversary-complaint.pdf` and `.txt`: red = our render, blue = exemplar, black = both. The page map pairs pages one to one: ours p.1-6 ↔ filed p.1-6 (word overlap 47-64%). The overlay is a diagnostic, not a score: the exemplar's text sits at a different position on the page (its own spacing and caption layout), so the layers do not coincide line for line.
- File names: the repo's tools read `OUTPUT-<id>.pdf` and write `OVERLAY-<id>.pdf/.txt` (CLAUDE.md naming), so this folder uses `INPUT-`/`OUTPUT-`/`OVERLAY-`, not the `<id>.pdf` and `<id>-overlay.pdf` in the task brief.

## Visual review (Gate 2 record, all 7 pages, typst and docx, rendered at 50 dpi and looked at; fb-595.68.28)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover (court title, bankruptcy caption, adversary caption, title), lead-in, Preliminary Statement, paragraphs 1-2 | OK. Captions single-spaced, the party columns ruled at right and foot; the "Adv. Pro. No." blank in place. |
| 2 | Parties, Jurisdiction and Venue; Facts (paragraphs 3-10) | OK. Headings centered and bold, half a double line above and below; numbered paragraphs on the 27.6 pt pitch. |
| 3 | Paragraphs 11-16 and lettered items (a)-(c) | OK. Labels at 0.5 in, the item lines hanging at 1.1 in. |
| 4 | Item (d), the unnumbered total, paragraphs 17-22 with items (a)-(b) | OK. The total continues the paragraph unnumbered, as in the filing. |
| 5 | Paragraph 23, Count I and its title heading, paragraphs 24-29 | OK. Both headings kept with paragraph 24. |
| 6 | Paragraphs 30-33 with the statute quotation, the prayer (1)-(4), the bracketed note | OK. Quotation single-spaced, indented 1 in left and 0.5 in right; WHEREFORE kept with the prayer. |
| 7 | Signature block | OK. Kept whole (it does not fit under the note on page 6): "Dated" left, firm and "/s/" from 2.8 in, the name in capitals as filed. |

Reviewed pages: 7 of 7 on both engines; the docx breaks every line and page as typst does (XENG-001..003).

## Known gaps and open choices

1. **Tier-2 exemplars.** One exemplar from one filer. The eval loop asks for two or three from different filers. Not done; a second S.D. Ind. bankruptcy adversary complaint would be needed. Searches tried are in `usage/SOURCE.md`.
2. **Form 416.** The caption layout is the exemplar's, checked against Rule 7010's wording. The Official Form 416 text itself was not fetched, so the caption is not checked line by line against the form.
3. **Corporate Ownership Statement (B-7007-2).** Not generated. Required for the LLC plaintiff in a real filing.
4. **Font.** No face named by the rules (checked 2026-10-15); Times New Roman 12 pt, the house standard, in both engines.
5. **Length.** The exemplar is 7 pages; the render is 7 (the signature block, kept whole, opens page 7). The 8-14 page target applies to exemplars of that length, so it does not apply here. The sample is the whole filing.
6. **Quotation spacing.** The statute quotation is single-spaced, as set by the template's quotation block.
7. **Certificates.** None generated (see the rules table: B-9013-2 does not apply to a Rule 7001 complaint).
8. **Summons and other filings.** Not part of this doc type.
9. **Paragraph numbering.** The template numbers allegations itself; the sample's filed paragraph numbers are not transcribed, so they do not match the filing's numbers beyond the first paragraphs.

## Engines

**DOCX** (`docx/`). `docx/reference.xml` holds the Word styles: `base="xengine"` in the typst face (`{font}`, Times New Roman), 12 pt, 552-twip body and 276-twip single line boxes, headings with 276 twips above and below, and the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it. `docx/insb.lua` reads the sample's body chunk by chunk, as the typst template does, and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua`: the cover, the two caption tables, the numbered allegations (Rule 10(b)), the lettered items, the block quotation, the prayer and the signature, all from the sample's frontmatter and body. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002).

- Cross-engine (fb-595.68.28): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (7 = 7 pages, every line breaks after the same word); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.
- TOC and TOA: none in this doc type.
