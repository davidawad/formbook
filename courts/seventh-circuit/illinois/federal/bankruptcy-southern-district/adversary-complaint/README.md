# S.D. Ill. Bankruptcy Court: adversary complaint

Doc type: **adversary complaint** (the complaint that opens an adversary proceeding). Court: United States Bankruptcy Court for the Southern District of Illinois (ilsb). Folder: `courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 8 of 8, typst and docx (fb-595.68.27). No `court.json` status is set here; nothing in this folder sets `status`.

## Governing rules

Sources, all read on 2026-10-14:

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| ILSB-FORM-001 | S.D. Ill. Local Rules, L.R. 5005-2, <https://www.ilsb.uscourts.gov/sites/ilsb/files/LocalRules-BkSoDistrict_12-01-15.pdf> (revision 12-01-15, the copy the court posts) | "Papers submitted for filing shall be 8 ½” by 11” in size." | page size, `typst/ilsb-adversary-complaint.typ` (`page-w`, `page-h`) |
| ILSB-FORM-002 | L.R. 5005-1(B)(1) | "Papers shall be plainly and legibly typewritten, printed or reproduced on one side of the paper only." | one side; no typeface named (see gaps) |
| ILSB-FORM-003 | L.R. 5005-1(B)(2) | Each paper "shall bear the name of the debtor and chapter of the case. Each paper other than the petition shall also have the case number." Caption "in substantial compliance with the Federal Rules of Bankruptcy Procedure, Official Forms or Local Rules". | caption: `debtors`, `debtor_designation`, `chapter`, `bankruptcy_case_no` |
| ILSB-CAP-001 | Fed. R. Bankr. P. 7010, <https://www.law.cornell.edu/rules/frbp/rule_7010> (restyled text, effective Dec. 1, 2024) | "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform" to Form 416. | caption layout (court title, "In re", parties, "v.", adversary number, title) |
| ILSB-CAP-002 | Fed. R. Civ. P. 10(a), <https://www.law.cornell.edu/rules/frcp/rule_10> | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." The complaint's title "must name all the parties". | `court-title`, `caption`, `title` |
| ILSB-PARA-001 | Fed. R. Civ. P. 10(b) (via FRBP 7010) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances"; separate claims "must be stated in a separate count". | `body-flow`: numbered paragraphs, `## Count` headings |
| ILSB-SIG-001 | L.R. 9011(A), <https://www.ilsb.uscourts.gov/sites/ilsb/files/LocalRules-BkSoDistrict_12-01-15.pdf> | "Under the attorney's signature shall be typed the attorney's name, office address, e-mail address, telephone number, and state bar number." | `signature-block`, `signature.attorney` (the ARDC number is the Illinois state bar number) |
| ILSB-SIG-002 | Electronic Filing Rules (Sept. 2021), Rule 5, <https://www.ilsb.uscourts.gov/sites/ilsb/files/ElectronicFilingRulesSept2021.pdf> | An electronically filed pleading bears "the name of the signatory preceded by an '/s/' or 's/'". | `signature-block` ("/s/ name") |
| ILSB-SUM-001 | Administrative Guide for Attorney's Staff (March 19, 2026), <https://www.ilsb.uscourts.gov/sites/ilsb/files/AdminGuide3-19-2026.pdf>, adversary complaint section; Electronic Filing Rules, Rule 6 | "The Summary of Exhibits shall be filed electronically as the last page of the complaint, if applicable." A certificate of service for served exhibits "shall appear on the Summary of Exhibits." | `exhibits` and `exhibits_service` (last page); not exercised by the sample |
| ILSB-AP-001 | Administrative Guide, adversary section | The complaint PDF is filed under the adversary event "Open an AP Case"; the summons is docketed automatically. | not generated: filing event and summons are the clerk's and the filer's, not the document's |

Not generated, on purpose: the summons (docketed automatically, ILSB-AP-001); the adversary cover sheet (a separate form filed with the case-opening event); a certificate of service for the complaint (service of the summons is governed by FRBP 7004, not a certificate in the complaint); the ECF header (produced by the court's system).

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: Complaint, Doc 1 in Adv. No. 20-03052-lkg, 33 pages. Filed 11/23/2020 by the United States Trustee for Region 10 (Nancy J. Gargula, by Mark D. Skaggs, Trial Attorney). Text layer present (`pdftotext` reads it). Body in Times (not embedded). Caption uses a ")" column.
- Provenance, searches and the caveats are in `usage/SOURCE.md`.
- Only one exemplar. The eval-loop tier-2 rule asks for two or three from different filers; the search found only short turnover and form complaints from other filers (listed in SOURCE.md) and they were not kept.

## Sample

- `usage/INPUT-adversary-complaint.md` is a transcription of the exemplar: the caption, the lead-in, the jurisdiction and party paragraphs, the procedural history, the factual heading and paragraphs 22 to 30, Count I's first paragraphs and prayer, Count III's paragraphs and prayer, and the signature and attorney blocks. Paragraph 21, paragraphs 31 to 104 and 110 to 162, and parts of 165 to 185 are not transcribed (the exemplar is 33 pages; the sample is 8 pages). The omitted parts are listed in the sample's frontmatter comment. The template numbers the paragraphs, so the sample's numbers run from 1.
- Frontmatter fields are described below, then `typst/` and the sample's markdown contract.

### Frontmatter (`usage/*.md`)

| Field | Required | Feeds |
|---|---|---|
| `title` | yes | Title of the paper, centered in capitals under the caption ("COMPLAINT"). |
| `division` | no | Division line under the court title ("East St. Louis Division"). |
| `debtors` | yes | List of lines in the caption's "In re:" block (inline markdown allowed). |
| `debtor_designation` | yes | "Debtors." under the debtor names. |
| `bankruptcy_case_no`, `chapter` | yes | "Case No." and "Chapter" at the right of the caption (L.R. 5005-1(B)(2)). |
| `adversary_no` | no | "Adversary No." at the right of the caption. Blank gives a fill-in line. |
| `caption.parties` | yes | List of `{names, designation}`: plaintiff first, then defendants, "v." between. |
| `lead_in` | no | Unnumbered first paragraph ("NOW COMES ..."). |
| `date` | yes | "Dated:" line. |
| `signature.party` | yes | Lines under "Respectfully submitted,". |
| `signature.signer`, `signature.signer_title` | yes | "/s/ name" and the signer's name and title. |
| `signature.attorney` | yes | Attorney block under the signature (L.R. 9011(A)). |
| `exhibits` | no | List of `{label, description}`; a Summary of Exhibits page is added last. |
| `exhibits_service` | no | Certificate of service for exhibits (only with `exhibits`). |

### Body (markdown)

- `# Heading`: centered, bold, capitals. `## Heading`: centered, bold, as typed (used for counts). `### Heading`: bold, left (sub-headings). The author types any letters or numbers in headings.
- Paragraphs are numbered by the template (ILSB-PARA-001). Do not type a number at the start of a paragraph: "1. text" would be a list, not a numbered paragraph.
- A paragraph beginning `WHEREFORE` starts the prayer for relief. The items after it are written `A. text`, `B. text` and rendered as lettered, unnumbered, hanging items.
- `- item` is a bullet list. `> text` is a single-spaced block quotation.
- Footnotes: `text[^key]` with `[^key]: text` anywhere in the file (rendered with the paragraph that cites them).
- Case names are italic when written `*Name*`. Smart punctuation is on.

## Typst and render

```sh
fb render courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-adversary-complaint.md            # typst
fb check courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint --engine typst|docx                           # render and gates
just overlay courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint
```

- `typst/main.typ` is the entry point; `typst/ilsb-adversary-complaint.typ` is the template. Times New Roman 12 pt (vendored, `("Times New Roman", "Liberation Serif")`); vendored fonts only, `--ignore-system-fonts`, warnings fail. The render compiles with no warnings.
- Layout: the shared cross-engine model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, the boxes touching, explicit spaces between blocks. Pitches: 24 pt body (double spacing, as filed), 13.8 pt single lines (court title, caption, headings, quotations, signature and attorney block), the 10 pt "Page X of Y" footer in a 12 pt line. Body paragraphs run on at double spacing with no extra space between them (as filed); headings stand half a body line (12 pt) from the text. A numbered paragraph has its number in a half-inch box at the half-inch indent, the text starting 1 in from the margin (as filed); a prayer item its letter in a 0.3 in box at the indent, the text hanging at 0.8 in. The caption's groups are a single line apart, "v." with a single line on either side.
- `usage/OUTPUT-adversary-complaint.typst.pdf`: 8 pages. `pdffonts`: TimesNewRomanPSMT and -BoldMT, embedded.
- Overlays (`just overlay`) are written to the gitignored `.overlay/` folder. The overlay is a diagnostic, not a score: the exemplar is Times in a different layout, so the layers will not line up on text.

## Visual review (Gate 2, all 8 pages of the typst and the docx render at 60 dpi, looked at; fb-595.68.27)

The docx render breaks every line and page as the typst render (XENG-001..003, 209/209 lines); the pages below hold for both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor, parties, "v.", case no., chapter, adversary no.), title, lead-in, Jurisdiction and Venue ¶ 1 | OK. Caption right and bottom rules drawn; groups a line apart. Double spacing consistent. |
| 2 | ¶¶ 2-10: venue, Parties | OK. Section headings centered bold capitals, numbers continue. |
| 3 | ¶ 11, Procedural History, Factual Allegations heading, sub-heading A (bold, left), ¶¶ 14-18 | OK. |
| 4 | ¶¶ 18-26 | OK. The web address in ¶ 19 breaks after "https://www." in both engines (typst's rule for an address; the docx sets the same break). |
| 5 | ¶¶ 26-29, Count I heading (centered bold, as typed), ¶¶ 30-34 | OK. |
| 6 | ¶ 35, WHEREFORE with prayer A-D, Count III heading, ¶¶ 36-39 | OK. Prayer letters at the indent, the text hanging. |
| 7 | ¶¶ 39-44, WHEREFORE for Count III with prayer A-C | OK. |
| 8 | Prayer D-E, Dated line, "Respectfully submitted", "/s/" signature, attorney block | OK. Signature block kept together. |

Reviewed pages: 8 of 8 (typst) and 8 of 8 (docx).

## Known gaps and open choices

1. **No typeface, type size or margin rule.** The S.D. Ill. local rules and the FRBP text fetched (restyled FRBP 9004 has only (a) legibility and (b) caption) set none. Times New Roman 12 pt (vendored), 1-inch margins and double spacing are style choices that match the exemplar (Times). Needs David's call if the court has a standing order.
2. **Double spacing** (24 pt pitch) is a convention; no S.D. Ill. rule requires it for complaints.
3. **Caption.** Follows Form 416 as S.D. Ill. uses it, "substantially" (FRBP 7010). Layout is ours, not the official form, and the adversary number is left as a fill-in line, as in the exemplar.
4. **Jury demand** is not supported by a field. A complaint with a jury demand needs one added (not in the exemplar).
5. **Summary of Exhibits** is implemented in both engines (`exhibits`, `exhibits_service`) but no sample exercises it; the exemplar attaches Exhibit 1 separately. Untested. Bullet lists and block quotations are implemented in both engines but not exercised by the sample either.
6. **Partial sample.** About a quarter of the exemplar is transcribed (see Sample). The omitted paragraphs are not checked against the template.
7. **Tier 2.** One exemplar only. The eval loop asks for two or three from different filers. Not done (SOURCE.md records the search).
8. **Summons, cover sheet, ECF header** are not generated (see Governing rules).
9. **Footer.** "Page x of y" is our footer. The exemplar's ECF header is not reproduced.
10. **Filing-specific fields** (the petition and schedules references, Rule 2016 disclosure) are case text and stay in the sample.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.xml`, `docx/ilsb.lua`; built by `fb render`, no shell): `reference.xml` is the cross-engine recipe (`base="xengine"`, `{font}` = the typst face, Times New Roman 12 pt; Body Text in exact 480-twip lines with a 720-twip first-line indent, 276-twip single lines, headings 240 twips from the text, Block Text 240 twips around) plus "Numbered Paragraph" (tab at 1 in), "Prayer Item" (letter at 0.5 in, text hanging at 0.8 in), "Body Keep" (WHEREFORE, kept with the prayer) and the "Page X of Y" footer (10 pt in a 240-twip line, 768 twips from the page foot). `ilsb.lua` (`require("docx.xengine")`) writes the court title, the caption table (rules right and bottom of the party column), title, headings, quotations, the signature and attorney block (kept together) and the Summary of Exhibits with the typst spacing in twips; the lead-in, numbered paragraphs, WHEREFORE and prayer items go to pandoc in those styles (footnotes stay Word footnotes). Break rules as typst: no break inside ")(", a break after a slash before a letter and after a period in a web address, `§§` bound to its number. Until fb-595.68.27 the docx was EB Garamond from `docx/build-reference.sh` (DEF-FORM-002, DEF-FONT-002 and TNR-EMBEDDED failed).
- Checks (fb-595.68.27): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (8 pages each, 209/209 lines). `eval.yaml` sets `params.cross_engine: gate`.
- **latex**: no latex template for this doc type.
