# ndb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the District of North Dakota (`ndb`), an adversary proceeding under FRBP 7003.
Folder: `courts/eighth-circuit/north-dakota/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-bourbon-street-23-07012-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-bourbon-street.md` (full transcription of the 9-page filing, plus the consent statement in the frontmatter; see "Sample") |
| render | ok: `samples/OUTPUT-bourbon-street.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-bourbon-street.pdf` and `samples/OVERLAY-bourbon-street.txt` (page map) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed; pages 1-7 viewed on the render before the consent change, page 8 viewed after the final change) |

Commands (run from /work/repo with the toolchain on PATH):

```
sh tools/render.sh courts/eighth-circuit/north-dakota/federal/bankruptcy-district/adversary-complaint samples/INPUT-bourbon-street.md
sh tools/overlay.sh courts/eighth-circuit/north-dakota/federal/bankruptcy-district/adversary-complaint bourbon-street
```

File names follow the repo's role-in-the-name convention, which the shared tools read and write (`INPUT-` markdown, `OUTPUT-` our render, `OVERLAY-` comparison). The brief's `<id>.md` / `<id>-overlay.pdf` names were not used because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`.

## Governing rules

Primary sources were fetched 2026-10-14. Rule text is from the Legal Information Institute (Cornell) copies of the Federal Rules of Bankruptcy and Civil Procedure, and from the District's own local rules.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 7003 | An adversary proceeding is commenced by complaint. https://www.law.cornell.edu/rules/frbp/rule_7003 | The complaint itself; the Form B1040 cover sheet is a separate filing (see "Not produced"). |
| FRBP 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to Form 416. https://www.law.cornell.edu/rules/frbp/rule_7010 | `cover()` / `caption()`: court name, debtor block, parties, case number, adversary number, title. |
| FRCP 10(a) | Caption: court name, title, file number, and Rule 7(a) designation. https://www.law.cornell.edu/rules/frcp/rule_10 | As above; the title is centered below the caption. |
| FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-blocks()`: every paragraph that is not a heading, quotation, or WHEREFORE paragraph is numbered 1, 2, ... |
| FRBP 9004(a) | Papers must be clearly legible. https://www.law.cornell.edu/rules/frbp/rule_9004 | 12-point type, black on white, 1-inch margins. |
| FRBP 9004(b) | Caption must contain the court's name, the case title, the case number and adversary number, and a brief designation of the document. | `court-name`, `caption`, `title`. |
| FRBP 7008(a) | Jurisdiction allegation refers to the name, number, and Code chapter of the case, and the district and division; the complaint must state whether the pleader consents to entry of final orders by the bankruptcy court. https://www.law.cornell.edu/rules/frbp/rule_7008 | Caption carries the name, number, and chapter. The consent statement is a required frontmatter field (`consent_statement`); the template panics if it is missing. The jurisdiction paragraph is author content and is not checked. |
| FRBP 9011(a) | Signed by at least one attorney in the attorney's individual name; the document states the signer's address and telephone number. https://www.law.cornell.edu/rules/frbp/rule_9011 | `signature()`: "By: /s/", name, address, telephone, e-mail (from `signature.lines`). |
| D.N.D. Bankr. L.R. 1001-1(D) | Certain District of North Dakota local rules are incorporated in the bankruptcy rules. https://www.ndb.uscourts.gov/sites/default/files/local_rules/Official%20local%20rules%202023.pdf (2023 rules, effective 2023-02-06) | The 2023 bankruptcy local rules have **no** type-size, margin, or spacing rule. The District's general local rules were not retrievable from the court's site on 2026-10-14, so any form rule in them is **unverified** (see Known gaps). |

Nothing in the rules sets a font, a size beyond legibility, or a line spacing for this court in the sources checked. The form choices below therefore come from the filed exemplar, the Word convention for double spacing, and the caption form in FRBP 7010.

## Layout choices (not set by a rule we could read)

- **Type:** EB Garamond 12 pt (vendored). Typeface row (fonts pass, 2026-10-14): face required by the rules = none (FRBP 7010, FRCP 10, FRBP 9004 and the 2023 bankruptcy local rules name no face); substitute = none, so EB Garamond is kept by policy (`docs/FONTS.md` "No face named"). The exemplar is Times New Roman 12 pt; a filer's choice is not a rule, so it is not chased (tier 2 at most). Court site not reachable on 2026-10-14 (HTTP 500), so the District general rules remain unverified.
- **Spacing:** body pitch 27.6 pt, which is Word's double spacing for 12 pt Times New Roman (2 x 13.8 pt). The template sets `pitch = 27.6pt` and `body-leading = pitch - 0.65em`, so the line box of EB Garamond plus the leading gives 27.6 pt. Measured on the render: 27.6 pt between successive lines. Caption, counsel-style lines, quotations and signature are single spaced (13.8 pt).
- **Margins:** 1 inch on all sides; page number centered at the foot of each page (as in the exemplar).
- **Caption:** court name centered and bold on two lines; debtor block ("In re:"), then the parties with "v." between them; a column of ")" marks (as in the exemplar); case number, chapter and adversary number at the right, centered vertically against the parties. The title is centered and bold below the caption.
- **Paragraphs:** numbered from 1, first line indented 0.5 inch, number then text. WHEREFORE paragraphs are not numbered (exemplar convention).
- **Headings:** centered bold, kept with the paragraph after them.
- **Consent statement:** rendered as an unnumbered paragraph just before the signature block. Its place is a template choice: numbering it would move every later paragraph and break the "paragraphs 1-22" cross-references the exemplar makes.
- **Signature:** "Dated" at left; "Respectfully submitted," (optional closing), "By: /s/ <signer>" and the signer's block at right. The signature block is kept together with the consent statement, so it never sits alone on a page.
- **ECF header:** the exemplar's "Case ... Doc 1 Filed ... Entered ..." stamp is added by the court's system when a document is filed. It is not reproduced.

## Sample

`samples/INPUT-bourbon-street.md` transcribes the complete 9-page filing: caption, lead-in, all 39 numbered paragraphs, the three counts with their headings and WHEREFORE clauses, and the signature block. The transcription keeps the filing's wording and punctuation. Differences from the filed document:

- `consent_statement` is a test value, supplied in the frontmatter. The filed complaint does not contain a consent statement. The statement is required by FRBP 7008(a) and the wording is counsel's choice; the sample's text is only a stand-in to exercise the field.
- The bracketed "[Signature on Following Page]" line is not transcribed (the template places the signature).
- The ECF header and footer stamps are not reproduced.

Paragraph numbers in the render match the exemplar's numbering (1 to 39).

## Overlay

`samples/OVERLAY-bourbon-street.pdf`: red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words (see `OVERLAY-bourbon-street.txt`):

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 | 1 | 80.0% |
| 2 | 2 | 75.6% |
| 3 | 3 | 64.1% |
| 4 | 4 | 51.2% |
| 5 | 5 | 46.1% |
| 6 | 7 | 55.4% |
| 7 | 8 | 60.0% |
| 8 | 8 | 32.5% |

The overlay is a diagnostic, not a score. Differences in the lower-overlap pages come from the typeface (EB Garamond against Times New Roman), the ECF header, and page breaks that fall at different words.

## Known gaps and open choices

1. **Typeface.** The exemplar is Times New Roman. EB Garamond is the only vendored font, and the tools forbid system fonts. EB Garamond sets slightly smaller at the same point size, so the render looks lighter than the exemplar. A vendored Times-metric substitute exists (`Liberation Serif`, `docs/FONTS.md`), but no rule we could read names Times, so switching is a filer-convention choice, not a rule fix; EB Garamond is kept (fonts pass, 2026-10-14).
2. **One filer only.** Tier 2 asks for 2 or 3 filers. Other ND bankruptcy adversary complaints in CourtListener RECAP were checked: Doeling v. Wasness, 24-07004 (2 pages); Doeling v. Werner, 24-07009 (4 pages, a 727 objection); Doeling v. O'Keeffe O'Brien Lyson, 26-07005 (3 pages). They are too short to test the 8-14 page depth bar and are not saved. Tier 2 is therefore **not** judged against two filers.
3. **Exemplar lacks FRBP 7008(a) content.** The filed complaint has no consent statement, and its jurisdiction paragraph does not restate the case name, number, and chapter (they appear only in the caption). The template requires the consent statement; the sample supplies one. This is a case where the rule outranks the exemplar.
4. **District general rules not checked.** D.N.D. Gen. L.R. (the District's general local rules, which the bankruptcy rules incorporate in part under L.R. 1001-1(D)) were not retrievable on 2026-10-14; the District's site has no rules text linked from its local-rules page. Any form-of-papers rule there is unverified.
5. **Lists not supported.** A markdown list in the body panics the build; the complaint's prayer is written as WHEREFORE paragraphs.
6. **Not produced:** the Form B1040 adversary cover sheet, the summons, the Form 416-style cover page of any exhibit, and the exhibits (Agreement, Exhibit A). These are separate filings.
7. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder under the court, and the brief forbids editing `tools/`. The render and overlay were run instead, and the review below is the Gate 2 equivalent.

## Review of the rendered pages (Gate 2 rows)

Every page of `samples/OUTPUT-bourbon-street.pdf` was rendered at 60 dpi and viewed. Defects found during the review and fixed in the template are listed first.

Fixed during review:
- Paragraph spacing: blocks did not add the leading after their last line, so paragraphs collided and headings overlapped the text before them. Fixed by `below: body-leading` on every body block.
- Pitch: the first pass used 24 pt and gave 6 pages (filed exemplar: 9). Changed to Word's double spacing (27.6 pt), which gives 8 pages.
- Consent statement: first rendered as numbered paragraph 40 after the prayer; changed to an unnumbered statement before the signature.
- Signature with consent statement: kept in one unbreakable block so the signature never lands alone on a page.

Page rows (as of the final render):

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption with ")" column, right-hand case block, title, lead-in, paragraphs 1-2 | Pass: caption rows align; title centered; no spill of the cover |
| 2 | Paragraphs 2-7 | Pass: double spacing, numbers at 0.5 inch, no collisions |
| 3 | Paragraphs 8-14; headings "Parties", "Jurisdiction and Venue", "General Allegations" | Pass: headings centered bold, kept with text |
| 4 | Paragraphs 15-21 | Pass |
| 5 | Paragraphs 22-28; heading "Count I" | Pass: count heading kept with paragraph 23 |
| 6 | Paragraphs 29-34; WHEREFORE (Count I); heading "Count II" | Pass: WHEREFORE unnumbered; WHEREFORE continues onto page 7 |
| 7 | WHEREFORE (Count II) continued; "Count III"; paragraphs 35-39; WHEREFORE (Count III) starts | Pass |
| 8 | WHEREFORE (Count III) end; consent statement (unnumbered); signature block | Pass: signature block complete on the page; nothing below it |

Open tier-2 items for David (not defects of the template as built): the consent statement's position (before the signature, not in the jurisdiction section); single exemplar; the EB Garamond substitution.

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md)
