# njd: complaint

Doc type: **complaint** in the United States District Court for the District of New Jersey (`njd`).
Folder: `courts/third-circuit/new-jersey/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/FILED-EXAMPLE-complaint.pdf` (Kasowitz LLP, primary) and `usage/FILED-EXAMPLE-complaint-2.pdf` (Law Offices of Richard Malagiere). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md` (full transcription of the 12-page DGL complaint, numbering left to the template) |
| typeface | Face required: **none**. The rules that govern this document (Fed. R. Civ. P. 10, 38; L.Civ.R. 10.1, 11.1, 11.2, 38.1) name no typeface, and L.Civ.R. 7.2(d) governs briefs only. Set: **Times New Roman 12 pt**, the house face (`docs/FONTS.md`, "No face named"), vendored, in typst and docx alike (the docx named EB Garamond until fb-595.68.34); both exemplars use Times New Roman 12 pt. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 12 pages; `OUTPUT-complaint.docx` and `.docx.pdf`, 12 pages, every line and page as typst (XENG-001..003 gated, `eval.yaml`; fb-595.68.34) |
| overlay | earlier render only (`just overlay` writes to the gitignored `.overlay/`; not re-run for fb-595.68.34) |
| pages reviewed | 12 of 12 on each engine (2026-10-22, below) |

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
- Times New Roman 12 pt, double spaced on a 27.6 pt pitch (measured in the DGL exemplar, page 3: 27.6 pt), single lines on 13.8 pt; the cross-engine layout model (`lib/typst/xengine.typ`), explicit block spaces. Headings bold and centered at the type size on the body pitch, with no space of their own; a paragraph's number at the 0.5 inch indent in a 0.5 inch box, the text from 1 inch.
- Counsel block top-left, single spaced. Court title centered bold below it. Caption: parties in a column closed by a right and a bottom rule, with "v." between parties and "Defendant." indented; right column with `Civil Action No.`, the judge line when set, and the bold title.
- Body: numbered paragraphs. Unnumbered: a paragraph starting with a prefix listed in `unnumbered_prefixes` (the lead-in "Plaintiff DGL Group Ltd. (", the WHEREFORE clauses, and the jury-demand sentence). The prefix list lives in the sample, not in the template.
- Prayer items: lettered `a.`, `b.` (the DGL exemplar's convention), the letter 0.5 inch in, the text hanging at 0.9 inch, on the body pitch.
- Signature block: "Dated:" left of the first line; firm, a blank line, "By: /s/ signer" and the signer's lines from 3.2 inch, single lines; kept on one page with the last paragraph. Certification on its own page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body is blank-line-separated chunks: `#` heading (level 1, centered bold caps), `##` heading (level 2, centered bold), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template unless it starts with an `unnumbered_prefixes` entry).
- Frontmatter: `counsel` (lines), `court` (lines), `caption.parties` (`{names, designation}`), `case_number`, `judge` (both may be `""`), `title` (must include "and Demand for Jury Trial" when `jury_demand` is true), `jury_demand`, `unnumbered_prefixes`, `date`, `signature` (`firm` lines, `signer`, `lines`), and optional `certification` (`title`, `text` markdown, `date`, `signature`).
- Not supported: tables, footnotes, raw typst. The sample must not put numbers in the text.

## Gate 2: visual review (all 12 pages on each engine, rendered at 45 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 279/279).

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel top-left; court title; caption (party column ruled at right and foot, the title on the right); THE PARTIES; the unnumbered lead-in; paragraph 1 | OK. |
| 2 | Paragraph 2; INTRODUCTION; paragraphs 3 and 4 | OK. "§§ 2, 6" kept with its number. |
| 3 | Paragraphs 4 to 8; JURISDICTION AND VENUE | OK: the page ends short as FACTS and its paragraph do not fit. |
| 4 | FACTS; paragraphs 9 to 13; "The Settlement Agreement" | OK. |
| 5 | Paragraphs 13 to 17 | OK: the filer's unbalanced quotation in paragraph 15 closes after "(Id. § 1)" in both engines. |
| 6 | Paragraphs 17 to 20; "Defendant's Breach of the Agreement ..." | OK. |
| 7 | Paragraphs 21 to 23 | OK. |
| 8 | Paragraph 23 (end); FIRST CAUSE OF ACTION, Breach of Contract; paragraphs 24 to 30 | OK. |
| 9 | Paragraph 30 (end); WHEREFORE and items a. to d.; SECOND CAUSE OF ACTION; paragraphs 31 to 35 | OK. |
| 10 | Paragraphs 35 and 36; WHEREFORE and items a. to d.; PRAYER FOR RELIEF and items a. to e. | OK. |
| 11 | JURY DEMAND and its sentence; date and signature block | OK: the last paragraph kept with the signature. |
| 12 | CERTIFICATION PURSUANT TO LOCAL CIVIL RULE 11.2 on its own page, with its signature | OK. |

Paragraph count: 36 numbered paragraphs, matching the DGL exemplar's count.

## Overlay (`tools/overlay.sh`)

- Against the DGL exemplar (the default, `usage/*.pdf | head -1`): our pages 1-4 pair with filed pages 1-4, and our pages 5-11 with filed pages 6-12. The one-page shift from page 5 is pagination: the exemplar's pages carry less text than ours at this spacing (a tier-3 difference, logged, not chased). Word overlap 52.5% to 88.7%. Diagnostic only.
- Against the Gomez exemplar (third argument; run once, output then overwritten by the DGL run): word overlap 5% to 17%, as expected for a different case; not a score. Layout comparison (counsel top-left, centered bold title, boxed caption with the bold title on the right, numbered double-spaced paragraphs, centered bold headings) was made by eye from the rasterized pages of both exemplars.

## Known gaps and open choices

1. **Font.** No governing rule names a face (L.Civ.R. 7.2(d) is for briefs only); the house face, Times New Roman 12 pt, is also both exemplars' face.
2. **Caption rule.** The exemplars differ (DGL: none visible in the text layer; Gomez: a full box). The template closes the party column with a right and a bottom rule. Recorded as ACCEPTED (tier 2, two filers show different caption boxes).
3. **Title.** L.Civ.R. 38.1 requires the words "and Demand for Jury Trial" in the title when a demand is endorsed. DGL's title is "COMPLAINT" with "JURY TRIAL DEMANDED" in the caption; the template follows the rule and sets the title "Complaint and Demand for Jury Trial". The DGL exemplar may be noncompliant on this point; that is a finding about the exemplar, not a template defect.
4. **Lead-in.** The lead-in paragraph before paragraph 1 is an unnumbered sentence, identified by its prefix in the sample's frontmatter. A different complaint with a different lead-in needs its own prefix; a missing prefix numbers the lead-in and shifts the numbers.
5. **Tool checks.** `tools/check.sh <this folder>`: `RESULT: 9 checks passed, 0 failed` (typst) and `RESULT: 13 checks passed, 0 failed` (`--engine docx`, XENG-001..003 gated).
6. **Paragraph spacing.** Paragraphs have no extra space between them (double spacing alone separates them), as in both exemplars; since fb-595.68.34 a paragraph break keeps the 27.6 pt pitch (it was 15.7 pt, SP-1, closed).
7. **Smart quotes.** A straight double quote right after a closing parenthesis is set as a closing quote in typst (its smart quotes would open one there; pandoc closes it), so both engines read the filer's unbalanced quotation the same way.

## Engines

Engine status: typst `OUTPUT-complaint.typst.pdf`; docx `OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice), 12 pages each, every line and page as typst (XENG-001..003 gated); latex not built (`latex/` is empty).

- **typst** (primary, `typst/`): the reference for the form, on `lib/typst/xengine.typ`.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 27.6 pt lines with a 0.5 in first-line indent; single lines in 13.8 pt boxes) and `docx/njd-complaint.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the counsel block, the court title, the caption table (party cell bordered at right and foot), the numbered paragraphs (the same `unnumbered_prefixes` rule as typst), headings, lettered prayer items, the signature blocks, the certification on its own page, the footer (a centred PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/njd.lua` and a committed `reference.docx` in EB Garamond). Paragraph numbers are typed text, not Word numbering. Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
