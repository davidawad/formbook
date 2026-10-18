# U.S. Bankruptcy Court, M.D. Pennsylvania (pamb): adversary complaint

Doc type: **adversary-complaint** (the complaint that starts an adversary proceeding under Part VII of the Federal Rules of Bankruptcy Procedure). Court: United States Bankruptcy Court for the Middle District of Pennsylvania. Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint/`.

Status: exemplar=yes (one filing, one filer), render=ok, overlay=ok, pages reviewed 4 of 4. Nothing here sets `status` in `court.json`.

## Governing rules

Sources, all fetched 2026-10-14:

- **Local rules.** United States Bankruptcy Court, M.D. Pa., Local Bankruptcy Rules PDF, `https://www.pamb.uscourts.gov/sites/default/files/local-rules/usbc_pamb_local_rules.pdf` (the court's list, https://www.pamb.uscourts.gov/court-info/local-rules-and-orders, shows it as effective October 1, 2025). The PDF's own cover prints "Effective: January 1, 2005"; that date is inconsistent with the court's list, so confirm the operative version before relying on this file. Quotations below are from that PDF.
- **Federal rules.** Fed. R. Bankr. P. 7008, 7010, 9004 as published on Cornell LII (`https://www.law.cornell.edu/rules/frbp/rule_7008`, `.../rule_7010`, `.../rule_9004`), current text effective December 1, 2024.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| PAMB-ADV-001 | L.B.R. 7003-1 | "Any paper complaint filed under Part VII of the Federal Rules of Bankruptcy Procedure must be accompanied by an Adversary Proceeding Cover Sheet (Official Form 1040)." | **Not generated.** The cover sheet is a separate form. See gaps. |
| PAMB-ADV-002 | FRBP 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the caption must "substantially conform to the appropriate version of Form 416." | `caption-table` in `typst/pamb-adversary-complaint.typ` |
| PAMB-ADV-003 | L.B.R. 9004-1 | A pleading filed in an adversary proceeding must have a caption "substantially in compliance with the Caption for Use in Adversary Proceeding (Official Form 416D)." | `caption-table`: court title, debtor block, rule line, party designations, chapter, case number, adversary number (blank line when none). |
| PAMB-ADV-004 | FRBP 7008(a) | The jurisdiction allegation "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending," and "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | `jurisdiction-block`. The case sentence is generated from `debtor` and `jurisdiction.district`. The core and consent statements come from `jurisdiction.core` and `jurisdiction.consent`, which the template requires (it panics without them). |
| PAMB-ADV-005 | FRCP 10(b) (incorporated by FRBP 7010) | Claims in numbered paragraphs, each "limited as far as practicable to a single set of circumstances." Stated from the rule's text; not fetched in this session. | `set enum(...)` in the template: the allegations are numbered from 1 at the margin. |
| PAMB-ADV-006 | FRBP 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." The current text has no paper-size, font, or margin rule. | Vendored EB Garamond only (`fallback: false`, no system fonts); 13 pt; 1 in margins; US Letter. |
| PAMB-ADV-007 | FRBP 9011 (signature) | Convention: the signature block names the firm, the signer, and the contact lines. The rule does not prescribe the layout. | `signature-block` |

Not used: the Official Form 416A/416D text itself was not retrieved; the caption follows the structure of the filed exemplar and the rule's description of the form. Check the form before calling the caption exact.

## Exemplar

- `usage/SAMPLE-pamb-adversary-complaint-webbsheils520ap00078.pdf`: "Trustee's Complaint for Turnover of Funds", Robert P. Sheils, Jr., Esquire, Chapter 7 Trustee, against National Debt Relief, LLC. Adversary No. 5:20-ap-00078-MJC; main case *In re Joseph Ryan Webb*, Case No. 5-20-00695. Filed 2020-11-18. 3 pages, text layer present (`pdftotext` reads it; Helvetica non-embedded, Liberation Sans embedded).
- Provenance, searches and the reasons this one was chosen are in `usage/SOURCE.md`.
- Only one exemplar. The eval-loop tier-2 rule asks for two or three from different filers. Not met; see gaps.
- The filed copy has no FRBP 7008(a) jurisdiction statement and leaves the adversary number blank. The template adds the statement (see PAMB-ADV-004); the sample fills it with bracketed placeholders for the pleader to choose.

## Sample

- `usage/INPUT-pamb-adversary-complaint-webbtrusteeturnover.md`: the complete text of the exemplar (caption, title, the lead-in, allegations 1 to 11, the fee table, the prayer and the signature block). The caption spelling "JOSPEH" is kept as filed.
- Frontmatter fields: `court`, `debtor` (name, chapter, case_number), `adversary_number` (blank), `caption` (sides with names and designation), `title`, `jurisdiction` (district, core, consent), `signature` (firm, signer, id, lines). Optional: `date` (printed as "Dated:").
- The sample is 3 pages in the exemplar and 4 in the render. The depth target (8 to 14 pages) applies to exemplars of that length; this one is 3 pages, so the sample is the whole document.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint usage/INPUT-pamb-adversary-complaint-webbtrusteeturnover.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint webb-trustee-turnover
```

- File names follow the tools, not the brief's `<id>-overlay` form: `usage/OUTPUT-pamb-adversary-complaint-webbtrusteeturnover.typst.pdf` (our render; 4 pages; typst with no warnings), `usage/OVERLAY-webb-trustee-turnover.pdf` and `.txt` (red = ours, blue = filed, black = both). The sample is `usage/INPUT-pamb-adversary-complaint-webbtrusteeturnover.md` (no `INPUT-` prefix; `render.sh` strips only `INPUT-` when naming the output).
- Fonts: `pdffonts` shows EBGaramond-Regular and -Bold embedded, nothing else.
- Overlay page map: ours p.1 ↔ filed p.1 (42%), p.2 ↔ p.2 (54%), p.3 ↔ p.2 (35%), p.4 ↔ p.3 (78%). The pairing is by word overlap and coarse; the filed copy is the same text on fewer pages, and the render's extra page is the prayer and signature moved together by the sticky rule. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record: every page of the final render, at 60 dpi, looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (IN RE block, chapter, case no., blank adversary no., Plaintiff/Defendant), title, Statement of Jurisdiction, the start of the lead-in | OK. The two bracketed placeholders for core and consent print where the pleader must fill them in; this is intentional. |
| 2 | Lead-in, allegations 1 to 8 | OK. Numbers at the margin, text after; double-spaced. |
| 3 | Allegations 9 to 11, fee table | OK. The table sits between paragraph 11 and the prayer. The prayer moved to page 4 with the signature (sticky rule), leaving the bottom third of page 3 blank. Accepted: the signature never stands alone. |
| 4 | Prayer ("WHEREFORE"), signature block | OK after the indent fix (the sticky block had lost the first-line indent; now drawn as a leading space). |

Pages reviewed: 4 of 4.

## Known gaps and open choices

1. **Cover sheet (PAMB-ADV-001).** L.B.R. 7003-1 requires the Adversary Proceeding Cover Sheet (Official Form 1040) with a paper complaint. Not generated: it is a separate form, and the e-filing system prompts for the same information. Not verified against the form's current text.
2. **Core and consent statements (PAMB-ADV-004).** The filed exemplar has neither. The template requires both fields and prints them as written; the sample's values are bracketed placeholders, so the sample is not a finished pleading until the pleader chooses. Neither statement's legal conclusion is supplied by the template.
3. **Summons and service.** Not generated (FRBP 7004 not checked).
4. **Font, margins, spacing.** Typeface row: face required = none; substitute = none needed (EB Garamond kept, `docs/FONTS.md` row "No face named"); fit = n/a. Checked 2026-10-15 against the full text of the local rules PDF (no rule on font, typeface, point size, margins or spacing; L.B.R. 9004-1 governs the caption only) and the federal text (FRBP 9004(a): legibility only). EB Garamond at 13 pt, 1 in margins, double-spaced body (24 pt pitch) follow the look of the filed copy: convention, not a rule. Times-matched type size was not attempted.
5. **Paper size.** US Letter; no rule text found. Convention.
6. **Tier-2 exemplars.** One exemplar. The eval-loop rule asks for two or three from different filers. A second and third M.D. Pa. adversary complaint with text layers were not found on CourtListener's RECAP archive (RECAP hits were orders, certificates of service, stipulations, or scanned complaints such as 5:17-ap-00098, which has no text layer).
7. **Caption exactness (PAMB-ADV-002, -003).** Built from the rule's description and the filed copy, not from the Form 416 images, which were not retrieved.
8. **Glyph check.** The filed copy's text layer drops apostrophes ("Sheriffs"). This complaint's text was checked against the text layer only; the exemplar page image was not compared. Compare against the page image before relying on the sample's apostrophes (the motion-brief exemplar's image was checked and shows them, see that folder's README).
9. **Page-limit and other checks.** No rule check runs over the rendered output. The required-field panics (`jurisdiction.core`, `jurisdiction.consent`, `debtor`, `caption`, and the others) are not exercised by a test here.
10. **Allegation numbering.** cmarker's enumerated list does the numbering. A paragraph that starts with a number or a marker must be escaped (`1\.`), as in any markdown.

## Engines

- **typst** (primary, `typst/`): the reference. Reviewed: 4 of 4 pages of the render of `usage/INPUT-pamb-adversary-complaint-webbtrusteeturnover.md` (checked at 60 dpi in /tmp, not written to usage/).
- **docx** (`docx/`): `build-reference.sh <out.docx> 11 center` builds `docx/reference.docx` (pandoc's default reference, changed in place: EB Garamond 13 pt, exact 24 pt line pitch, 0.5 in first-line indent, US Letter, 1 in margins, centered PAGE footer at 11 pt, centered bold caps level-1 headings, 1 pt table grid, footnotes 13 pt single). `docx/pamb.lua` builds the caption (borderless table with the rule under the debtor block and the vertical rule), the title, the Statement of Jurisdiction, the numbered allegations, the prayer kept with the signature, and the signature block at 3.3 in. Built from the court folder with `pandoc --from markdown+smart --to docx --reference-doc=adversary-complaint/docx/reference.docx --lua-filter=adversary-complaint/docx/pamb.lua adversary-complaint/usage/INPUT-webb-trustee-turnover.md -o adversary-complaint/usage/OUTPUT-webb-trustee-turnover.docx`.
  - Matches the typst template: page setup, font, line pitch, indents, caption layout, the fee table grid, the signature position, the page number. Checked by reading the .docx back (pandoc text read-back, every paragraph style defined, `ziptool` reads all 17 entries, `xmllint` on all 17 XML parts). Not checked visually.
  - Differs (pandoc and Word limits): the allegation numbers are typed text (number, tab, text), not a Word list, so they do not renumber when edited; the caption and signature cells are plain text (no markdown inside them); the blank "Adversary No." line is an underlined run of no-break spaces; the title is not written to the document properties (pandoc's title block is suppressed); footnotes are 13 pt single-spaced (the template inherits the body pitch; the samples have no footnotes).
  - BLOCKED: every gate check on `usage/OUTPUT-webb-trustee-turnover.docx.pdf` (Gates 0 to 3). This court folder has no `checks.yaml`, so no check IDs are readable here. Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.

## Searches tried

- CourtListener search API (`/api/rest/v4/search/`), `type=r` and `type=rd`, `court=pamb`: "adversary complaint", "Adversary Complaint", "complaint filed by", "complaint summons adversary proceeding plaintiff", "complaint dischargeability", "complaint for declaratory". Hosted PDFs were checked: Sheils (adversary 5:20-ap-00078) text-based and used; DeLuca / Tullio (adversary 5:17-ap-00098, doc 1, 9 pages) a scan with no text layer, not used.
- Web search for `gov.uscourts.pamb` adversary complaint PDFs: nothing beyond the RECAP archive.
- The court's website lists forms and rules but not filed complaints.

[Court root](../README.md) | [Motion brief](../motion-brief/README.md)
