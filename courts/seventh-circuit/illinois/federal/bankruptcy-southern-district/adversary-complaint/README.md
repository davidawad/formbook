# S.D. Ill. Bankruptcy Court: adversary complaint

Doc type: **adversary complaint** (the complaint that opens an adversary proceeding). Court: United States Bankruptcy Court for the Southern District of Illinois (ilsb). Folder: `courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 7 of 7 (final render). No `court.json` status is set here; nothing in this folder sets `status`.

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

- `usage/INPUT-adversary-complaint.md` is a transcription of the exemplar: the caption, the lead-in, the jurisdiction and party paragraphs, the procedural history, the factual heading and paragraphs 22 to 30, Count I's first paragraphs and prayer, Count III's paragraphs and prayer, and the signature and attorney blocks. Paragraph 21, paragraphs 31 to 104 and 110 to 162, and parts of 165 to 185 are not transcribed (the exemplar is 33 pages; the sample is 7 pages). The omitted parts are listed in the sample's frontmatter comment. The template numbers the paragraphs, so the sample's numbers run from 1.
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
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/adversary-complaint gargula-adversary-complaint
```

- `typst/main.typ` is the entry point; `typst/ilsb-adversary-complaint.typ` is the template. Vendored fonts only (EB Garamond); `tools/render.sh` uses `--ignore-system-fonts` and fails on any typst warning. The render compiled with no warnings.
- `usage/OUTPUT-adversary-complaint.typst.pdf`: 7 pages. `pdffonts`: EBGaramond-Regular and -Bold, embedded.
- `usage/OVERLAY-gargula-adversary-complaint.pdf` and `.txt`: red is our render, blue the exemplar, black both. The page map (by word overlap): ours p.1-3 to filed p.1-3, ours p.4 to filed p.5, ours p.5 to filed p.23, p.6 to p.32, p.7 to p.33. The overlay is a diagnostic, not a score: the exemplar is Times in a different layout, so the layers will not line up on text.

Naming: `tools/render.sh` and `tools/overlay.sh` write and read `usage/OUTPUT-<id>.pdf`, `usage/OVERLAY-<id>.pdf` and `.txt` (the repo's tool names), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief. The tools are shared and were not edited.

## Visual review (Gate 2, all 7 pages rendered at 60 dpi and looked at, final render)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor, parties, "v.", case no., chapter, adversary no.), title, lead-in, Jurisdiction and venue ¶¶ 1-3 | OK. Caption right and bottom rules drawn. Double spacing consistent. |
| 2 | ¶¶ 3-13: venue, Parties, Procedural history | OK. Section headings centered bold, numbers continue. |
| 3 | Factual allegations heading, sub-heading A, ¶¶ 14-21 | OK. Sub-heading left bold; paragraph spacing as on page 2. |
| 4 | ¶¶ 22-29, Count I heading (centered bold, case as typed), ¶¶ 30-31 | OK. |
| 5 | Count I ¶¶ 32-35, WHEREFORE with prayer A-D, Count III heading (one line) and ¶¶ 36-37 | OK. Prayer letters hang with the text. |
| 6 | ¶¶ 38-44, blank space at foot | OK. The WHEREFORE line for Count III moved to page 7 with its prayer (kept together; the sticky rule works). |
| 7 | WHEREFORE for Count III with prayer A-E, Dated line, "Respectfully submitted", "/s/" signature, attorney block | OK. Signature block not split. |

Reviewed pages: 7 of 7.

## Known gaps and open choices

1. **No typeface, type size or margin rule.** The S.D. Ill. local rules and the FRBP text fetched (restyled FRBP 9004 has only (a) legibility and (b) caption) set none. EB Garamond 12 pt (vendored), 1-inch margins and double spacing are style choices that match the exemplar's look. The exemplar is Times. Needs David's call if the court has a standing order.
2. **Double spacing** (24 pt pitch) is a convention; no S.D. Ill. rule requires it for complaints.
3. **Caption.** Follows Form 416 as S.D. Ill. uses it, "substantially" (FRBP 7010). Layout is ours, not the official form, and the adversary number is left as a fill-in line, as in the exemplar.
4. **Jury demand** is not supported by a field. A complaint with a jury demand needs one added (not in the exemplar).
5. **Summary of Exhibits** is implemented (`exhibits`, `exhibits_service`) but no sample exercises it; the exemplar attaches Exhibit 1 separately. Untested.
6. **Partial sample.** About a quarter of the exemplar is transcribed (see Sample). The omitted paragraphs are not checked against the template.
7. **Tier 2.** One exemplar only. The eval loop asks for two or three from different filers. Not done (SOURCE.md records the search).
8. **Summons, cover sheet, ECF header** are not generated (see Governing rules).
9. **Footer.** "Page x of y" is our footer. The exemplar's ECF header is not reproduced.
10. **Filing-specific fields** (the petition and schedules references, Rule 2016 disclosure) are case text and stay in the sample.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **latex** (`latex/`): see `latex/`; not changed by this section.
- **docx** (`docx/reference.docx`, `docx/ilsb.lua`, `docx/build-reference.sh`): pandoc on reference.docx, EB Garamond 12 pt, exact 24 pt body line pitch, 0.5 in first-line indent, 1 in margins, letter, "Page x of y" footer (PAGE and NUMPAGES fields). `ilsb.lua` lays out the caption (a table with a right and a bottom rule), court title, title, lead-in, numbered paragraphs (typed by the filter, numbers from 1), prayer items (`A.` with a hanging indent), signature table and attorney block, and the Summary of Exhibits; every case word comes from the frontmatter. Matches the typst form in: font and size, body pitch, margins, indent, paragraph numbering, prayer layout, page-number footer, page order. Differs or is unverified: the single-spacing gaps and the caption and signature table spacing are approximate (Word table and style metrics, not measured against typst); footnote text is 12 pt single-spaced (typst's footnote size was not checked); the numbered paragraph tab stop is the default 0.5 in grid, not the typst 0.3 in gap.
- docx checks: `usage/OUTPUT-adversary-complaint.docx` was written and validated (zip test and well-formed XML in every part). BLOCKED on this box: LibreOffice (`soffice`) is not installed, so `usage/OUTPUT-gargula-adversary-complaint.docx.pdf` was not produced and the docx Gate 0 to 3 checks (`tools/check.sh --engine docx`) cannot run. No page was rendered or reviewed (pages reviewed 0). The `.docx` has not been opened in Word or LibreOffice.
- Blocked or unverified docx items: the docx.pdf render and page review (blocked on soffice); cover and caption table borders not verified against the typst layout; the page count and page breaks in Word may differ from typst.
