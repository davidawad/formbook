# njd: complaint

Doc type: **complaint** in the United States District Court for the District of New Jersey (`njd`).
Folder: `courts/third-circuit/new-jersey/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/SAMPLE-njd-complaint-dglgroup226cv13086.pdf` (Kasowitz LLP, primary) and `usage/SAMPLE-njd-complaint-gomez225cv02242.pdf` (Law Offices of Richard Malagiere). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-njd-complaint-dglgroup.md` (full transcription of the 12-page DGL complaint, numbering left to the template) |
| typeface | Face required: **none**. The rules that govern this document (Fed. R. Civ. P. 10, 38; L.Civ.R. 10.1, 11.1, 11.2, 38.1) name no typeface, and L.Civ.R. 7.2(d) governs briefs only. Kept: **EB Garamond** (the default in `docs/FONTS.md`); no substitute applies. Both exemplars use Times New Roman 12 pt, so the look differs (Known gaps 1). |
| render | ok: `usage/OUTPUT-njd-complaint-dglgroup.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular, -Italic, -Bold), no warnings |
| overlay | ok: `usage/OVERLAY-dgl-group-complaint.pdf` and `.txt` (against the DGL exemplar; see below) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the fonts pass; the template is unchanged by that pass, the render is the same) |

File names follow the role convention used by `tools/render.sh` and `tools/overlay.sh`: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf`, the overlay `OVERLAY-<id>.pdf` and `.txt`, with `<id>` = `dgl-group-complaint`.

## Governing rules

Primary sources, fetched and read 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. The complaint's title names all the parties. | `court` (court name, centered bold, first page below the counsel block); `caption` (parties); `title` and `case_number` on the right of the caption. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered 1, 2, ...; headings and lists are not. |
| D.N.J. L.Civ.R. 10.1(a) (https://www.njd.uscourts.gov/sites/njd/files/CompleteLocalRules.pdf, "Civ. RULE 10.1") | The street and post office address of each named party in the first paragraph. | Author content: the sample's first paragraph gives each party's address. The template does not check it. |
| L.Civ.R. 10.1(b) (same) | Papers bear the docket number and the name of the assigned judge, and the name, office, address and telephone of the attorney of record on the first page. Black lettering, 8.5 x 11. | Counsel block top-left (`counsel`); `case_number` and `judge` on the right of the caption. A new complaint has no docket number yet, so `Civil Action No.` is left blank (as in the Gomez exemplar). |
| L.Civ.R. 11.1 and ECF Policies ¶ 12(a) (same) | Signature line with "s/" for an electronically filed document. | `signature-block()`: "By: /s/ <signer>". |
| L.Civ.R. 11.2 (same) | The initial pleading is accompanied by a 28 U.S.C. § 1746 certification on other pending actions on the same matter. | `certification` in the frontmatter: a separate section on its own page, with its own signature. |
| L.Civ.R. 38.1 (same) | A jury demand endorsed on a pleading: the title includes "and Demand for Jury Trial" or the equivalent. | `title: Complaint and Demand for Jury Trial`; the template fails the build if `jury_demand` is set without those words in `title`. |
| Fed. R. Civ. P. 38(b) (https://www.law.cornell.edu/rules/frcp/rule_38) | A jury demand may be included in a pleading. | Jury demand paragraph in the body, unnumbered (see below). |

Not produced by this template (separate papers, required with the first filing; not part of the complaint): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement, the L.Civ.R. 7.1.1 third-party litigation funding disclosure, and the summons.

## Layout

- Letter, 1-inch margins, no pleading paper or line numbers (neither D.N.J. rule nor either exemplar uses them).
- EB Garamond 12 pt, double spaced at a 27.6 pt line pitch (measured in the DGL exemplar, page 3: 27.6 pt; the template measures 27.6 pt on page 2 of its render). Headings are single-line centered bold; paragraphs have a 0.5 inch first-line indent with the number before the text.
- Counsel block top-left, single spaced. Court title centered bold below it. Caption: parties in a column closed by a right and a bottom rule, with "v." between parties and "Defendant." indented; right column with `Civil Action No.`, the judge line when set, and the bold title.
- Body: numbered paragraphs. Unnumbered: a paragraph starting with a prefix listed in `unnumbered_prefixes` (the lead-in "Plaintiff DGL Group Ltd. (", the WHEREFORE clauses, and the jury-demand sentence). The prefix list lives in the sample, not in the template.
- Prayer items: lettered `a.`, `b.` (the DGL exemplar's convention).
- Signature block: "Dated:" at left; firm, "By: /s/ signer" and the signer's lines at right. Certification on its own page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body is blank-line-separated chunks: `#` heading (level 1, centered bold caps), `##` heading (level 2, centered bold), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template unless it starts with an `unnumbered_prefixes` entry).
- Frontmatter: `counsel` (lines), `court` (lines), `caption.parties` (`{names, designation}`), `case_number`, `judge` (both may be `""`), `title` (must include "and Demand for Jury Trial" when `jury_demand` is true), `jury_demand`, `unnumbered_prefixes`, `date`, `signature` (`firm` lines, `signer`, `lines`), and optional `certification` (`title`, `text` markdown, `date`, `signature`).
- Not supported: tables, footnotes, raw typst. The sample must not put numbers in the text.

## Gate 2: visual review of the render (every page, 60 dpi)

| Page | Review |
|---|---|
| 1 | Counsel top-left; court title centered; caption with party column and title on the right; the lead-in is unnumbered and paragraph 1 begins after it. Pass. |
| 2 | INTRODUCTION heading; paragraphs 3-5. Pass. |
| 3 | JURISDICTION AND VENUE and FACTS headings with a full line above; paragraphs 6-10. Pass. |
| 4 | THE SETTLEMENT AGREEMENT sub-heading; paragraphs 11-15; block quotations run inline in the paragraph (no numbering). Pass. |
| 5 | Paragraphs 16-19; the page ends with two lines of white space because the next heading and two lines would not fit. Pass. |
| 6 | Sub-heading "Defendant's Breach..." sticks with paragraph 20 at the top of the page; paragraphs 20-22. Pass. |
| 7 | FIRST CAUSE OF ACTION and "Breach of Contract" centered; paragraphs 23-28. Pass. |
| 8 | Paragraphs 29-30; WHEREFORE unnumbered; prayer items a-d; SECOND CAUSE heading and sub-heading; paragraphs 31-34. Pass. |
| 9 | Paragraphs 35-36; WHEREFORE and items; PRAYER FOR RELIEF heading; items a-e. Pass. |
| 10 | JURY DEMAND heading and sentence; date and signature block (s/ line, firm, attorneys). Pass. |
| 11 | CERTIFICATION PURSUANT TO LOCAL CIVIL RULE 11.2 on its own page, with the signature. Pass. |

Paragraph count: 36 numbered paragraphs, matching the DGL exemplar's count.

## Overlay (`tools/overlay.sh`)

- Against the DGL exemplar (the default, `usage/*.pdf | head -1`): our pages 1-4 pair with filed pages 1-4, and our pages 5-11 with filed pages 6-12. The one-page shift from page 5 is pagination: the exemplar's pages carry less text than ours at this spacing (a tier-3 difference, logged, not chased). Word overlap 52.5% to 88.7%. Diagnostic only.
- Against the Gomez exemplar (third argument; run once, output then overwritten by the DGL run): word overlap 5% to 17%, as expected for a different case; not a score. Layout comparison (counsel top-left, centered bold title, boxed caption with the bold title on the right, numbered double-spaced paragraphs, centered bold headings) was made by eye from the rasterized pages of both exemplars.

## Known gaps and open choices

1. **Font (kept for now; question for David).** Both exemplars use Times New Roman 12 pt; EB Garamond is smaller at the same point size, so the text reads smaller than the exemplars. The fonts pass keeps EB Garamond because no governing rule names a face (L.Civ.R. 7.2(d) is for briefs only). Switching to Liberation Serif (the Times New Roman substitute in `docs/FONTS.md`) would match the exemplars visually but would be a choice the rules do not require, so it is left for David.
2. **Caption rule.** The exemplars differ (DGL: none visible in the text layer; Gomez: a full box). The template closes the party column with a right and a bottom rule. Recorded as ACCEPTED (tier 2, two filers show different caption boxes).
3. **Title.** L.Civ.R. 38.1 requires the words "and Demand for Jury Trial" in the title when a demand is endorsed. DGL's title is "COMPLAINT" with "JURY TRIAL DEMANDED" in the caption; the template follows the rule and sets the title "Complaint and Demand for Jury Trial". The DGL exemplar may be noncompliant on this point; that is a finding about the exemplar, not a template defect.
4. **Lead-in.** The lead-in paragraph before paragraph 1 is an unnumbered sentence, identified by its prefix in the sample's frontmatter. A different complaint with a different lead-in needs its own prefix; a missing prefix numbers the lead-in and shifts the numbers.
5. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none of them and the brief forbids editing `tools/`. The gates were not run; the render, the overlay and the review above are the evidence for this doc type.
6. **Paragraph spacing.** Paragraphs have no extra space between them (double spacing alone separates them), as in both exemplars. Measured in the fonts pass: a paragraph break has a 15.7 pt pitch against 27.6 pt inside paragraphs, from the same `spacing: 0pt` setting as the motion brief's open item (SP-1). It reads acceptably at 60 dpi here; not changed in the fonts pass.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx`, `docx/build-reference.sh`, `docx/njd.lua`): pandoc on a reference.docx restyled to the typst form: EB Garamond 12 pt, exact 27.6 pt (double) line spacing, 0.5 in first-line indent, letter page with 1 in margins, centered PAGE number on every page (the cover is page 1, as in typst). The filter builds the counsel block, the court title, the caption as a borderless table (party column closed by a right and a bottom rule, `Civil Action No.`, judge line, bold caps title), the signature table, and the certification on its own page (page break before the title). Body paragraphs are numbered in the text (`N.` then a tab, from the same `unnumbered_prefixes` rule as typst); prayer items are lettered (`a.`, `b.`). Known differences: paragraph numbers are typed text, not Word list numbering, so an edit in Word does not renumber them; list indents follow pandoc's numbering defaults; the table borders and the cell padding differ slightly from typst in Word and LibreOffice. The font is EB Garamond, as in typst: Word needs it installed (it is vendored in `fonts/`), or Word substitutes silently.
- **latex**: not built for this court yet (`latex/` is empty).
- Build: `sh docx/build-reference.sh docx/reference.docx`, then from the court folder `pandoc --from markdown+smart --to docx --reference-doc=complaint/docx/reference.docx --lua-filter=complaint/docx/njd.lua complaint/usage/INPUT-dgl-group-complaint.md -o complaint/usage/OUTPUT-dgl-group-complaint.docx`. The output passes a zip read of every entry and `xmllint --noout` on every XML part; the relationships point at parts that exist.
- **BLOCKED (docx):** the `.docx.pdf` cannot be produced or checked, because LibreOffice cannot run in the build box (`soffice` is not installed; the partial extraction does not run). So no docx gate can be measured, and the pages of the docx were not rendered or viewed (`pages reviewed: 0`). The court has no `checks.yaml` (none is readable in this folder or the court folder), so no gate check IDs can be listed. The requirement IDs the typst template cites (`NJD-FORM-001`, `NJD-FORM-002`, `NJD-FORM-003`: margins, face and size, spacing) are the ones that would be measured on the `.docx.pdf`; all three are BLOCKED for this reason. The typst render was checked page by page (11 of 11) as the reference.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
