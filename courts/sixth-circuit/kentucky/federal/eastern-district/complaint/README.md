# E.D. Ky. (kyed): complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/eastern-district/complaint/`. Court alias `kyed`; the court-level `court.json` is not touched here, and nothing in this folder sets `status`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole complaint: caption, 60 numbered paragraphs, counts, prayer, jury demand, signature) |
| typeface | face required: none (LR 5.2(a) asks for "at least 12-point proportionately-spaced font"; rule text read 2026-10-15) -> Times New Roman (vendored), the house default (`docs/FONTS.md`); the docx names the same face (`{font}` in `docx/reference.xml`) |
| render | ok (2026-10-22, fb-595.68.29): `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx.pdf`, 10 pages each, Times New Roman only, no warnings; both on the cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`), every line and page alike (XENG-001..003, `params.cross_engine: gate` in `eval.yaml`) |
| overlay | fail (re-run 2026-10-15): `tools/overlay.sh` exits 1 because `usage/SAMPLE-*.pdf` is not in this checkout. The `OVERLAY-dubya-complaint.txt` committed earlier was not regenerated; no `OVERLAY-dubya-complaint.pdf` is in `usage/` |
| pages reviewed | 10 of 10 on both engines (typst and the docx's LibreOffice PDF side by side, 50 dpi, 2026-10-22, after the last template change) |
| BLOCKED | none |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`), which `tools/render.sh` and `tools/overlay.sh` read and write, not the `<id>.pdf` names in the brief.

## Governing rules

Each requirement has a stable ID (KYED-...) used in the template's comments.

| ID | Rule | Requirement | Where it lives in the template |
|---|---|---|---|
| KYED-FORM-001 | E.D. Ky. LR 5.2(a) | 8½ × 11 inch paper; margins of at least one inch on all sides; text double spaced, except block quotes, headings and footnotes. Primary source: the court's amended Civil Rules, August 2026 (`https://www.kyed.uscourts.gov/sites/kyed/files/KY_Amended_Civil_Rules_August_2026.pdf`, linked from `https://www.kyed.uscourts.gov/local-rules`). Read and quoted 2026-10-14. | `margin-all = 1in`, `line-pitch = 24pt`, `paper: "us-letter"`. |
| KYED-FORM-002 | E.D. Ky. LR 5.2(a) | At least 12-point proportionately spaced font. | `type-size = 12pt`, `font-family = ("Times New Roman", "Liberation Serif")` (the rule names no face; the house default, see the typeface row above). |
| KYED-FIRST-001 | Fed. R. Civ. P. 10(a) | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation (here, the title "COMPLAINT"). Source: https://www.law.cornell.edu/rules/frcp/rule_10, read 2026-10-14. | `court-title`, `caption`, `title` frontmatter. |
| KYED-FIRST-002 | E.D. Ky. LR 3.1 and 3.2 | The division named in the caption ("AT LEXINGTON" in the sample) is the author's choice from the jury-division lists in LR 3.1(a); the template prints the frontmatter lines and does not check the division against the case. | `court` frontmatter. |
| KYED-CONT-001 | Fed. R. Civ. P. 8(a), 10(b) | Short and plain statement of jurisdiction, claim and demand (8(a)); claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances (10(b)). | Numbered paragraphs: each blank-line-separated chunk of the body is one paragraph, numbered 1, 2, ... by the template. |
| KYED-CONT-002 | Convention (no local rule) | Lettered lists in a numbered paragraph and in the prayer are lettered (a), (b), ... by the template. | `set enum(numbering: "(a)")`. |
| KYED-SIG-001 | Fed. R. Civ. P. 11(a) | The paper is signed by an attorney of record, and states the signer's address, e-mail address and telephone number. Source: https://www.law.cornell.edu/rules/frcp/rule_11, read 2026-10-14. | `signature-block`: `signature.preamble`, `signature.signer`, `signature.lines`. |

Not produced by this template (separate filings, listed for the filer): the civil cover sheet and the summons, U.S. Marshal Form 285 (LR 4.3(a)(1), (9), (10)); the disclosure statement (LR 7.1.1 and Fed. R. Civ. P. 7.1). The sample keeps the caption's "Civil Action No." blank, which the clerk fills in.

Pleading (line-numbered) paper is not used. LR 5.2 does not call for it, and the exemplar has none.

## Layout

- Page 1 begins with the caption, not a cover page (the exemplar does the same): court title lines centered and bold; "Civil Action No." centered; "ELECTRONICALLY FILED" when set; a rule; the party column (names, then the designation right-aligned, "v." between parties) and, in the right column, "JURY DEMAND" when set; a second rule; the title "COMPLAINT" centered and bold.
- Body: the opening sentence is unnumbered (`~ `); numbered paragraphs have a 0.5 in first-line indent; section headings are centered caps; count headings are centered bold; the WHEREFORE paragraph is unnumbered.
- Block quotations (`> `) are single spaced and indented 0.75 in on both sides. The policy clause in paragraph 34 uses this form.
- Signature block at the right half of the page, single spaced: "Respectfully submitted," firm, `s/` line, then the signer's bar number, address, telephone, fax, e-mail and "Attorney for Plaintiff".
- Footer: centered page number.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between parties), `case_number` (text after "Civil Action No."), `electronically_filed` (bool), `jury_demand` (bool), `title`, `signature` (`preamble` lines above "Respectfully submitted", `signer`, `lines` below the `s/` line).
- Body: `#` = centered caps heading (section); `##` = centered bold heading (count); a paragraph starting `~ ` = unnumbered paragraph; a block starting `> ` = block quotation; a chunk starting `1.` = lettered list `(a)`, `(b)`, ...; any other chunk = numbered paragraph.
- Not supported: tables, footnotes (none in a complaint), raw typst.
- The sample does not type the paragraph numbers; the template numbers them.

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the exemplar page that shares the most words: ours p.1-9 with filed p.1, 2, 4, 5, 6, 7, 9, 10, 11 (the filed p.3 and p.8 are not paired because our page breaks differ; the word overlap is 51-79%). Red is our render, blue the exemplar, black both. The exemplar uses Times New Roman and a larger apparent type size, and our page breaks differ, so the text lines do not coincide. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one filed document per doc type, and that is what is saved. Tier 2 asks for two or three filers. The search that found the Dubya complaint was CourtListener RECAP (`https://www.courtlistener.com/api/rest/v4/search/?q=complaint&court=kyed&type=r&order_by=dateFiled+desc`, run 2026-10-14). Other complaints in those results: *Travelers Casualty Insurance Co. v. EN V US Hamburg LLC*, 5:26-cv-00353 (no local RECAP copy); *Howarth v. A & A Lawncare & Landscaping*, 2:26-cv-00374 (not checked for format). Tier 2 is therefore **not** judged against two filers.
2. **Typeface.** LR 5.2(a) names no typeface, only "at least 12-point proportionately-spaced font" (rule text read from the court's Civil Rules PDF, 2026-10-15). The template sets Times New Roman 12 pt, the house default (`docs/FONTS.md`), as the exemplar does; the sample runs 10 pages against the exemplar's 11 (its caption and spacing differ).
3. **Lettered lists.** The prayer and the sub-items of paragraph 54 are lettered (a), (b), ... by the template. The exemplar letters its prayer A. through I. and its sub-items a) through l). Neither is a rule requirement; the template uses the cand convention.
4. **Caption layout.** The party column is closed by a rule at the foot and the right side, with "JURY DEMAND" in the right column. The exemplar uses a similar layout with its party names in capitals; the placement is a convention choice.
5. **Paragraph numbers.** The sample transcribes all 60 numbered paragraphs, and the template numbers them 1 to 60, the same as the filed numbering. Rendered paragraph 60 and the WHEREFORE paragraph were checked in the text layer.
6. **Heading placement.** The "JURY DEMAND" heading falls alone at the top of page 9, after the prayer. It is kept with its paragraph; the template does not move the prayer to make room.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect the court-folder shape (`court.json`, `rules.md`); this doc-type folder does not have that shape and the brief does not ask for them. Render and overlay were run, and the review above is the Gate 2 record for this doc type.

## Review of the rendered pages (Gate 2 record, 10 of 10 pages, both engines, viewed 2026-10-22 after the last template change)

| Page | What it is | Finding (typst and docx alike: XENG-001..003 pass, 258/258 lines) |
|---|---|---|
| 1 | Court title, civil action number, ELECTRONICALLY FILED, caption between two rules (parties, JURY DEMAND), title, opening sentence, PARTIES AND JURISDICTION, paragraphs 1-2 | OK. |
| 2 | Paragraphs 3-11, FACTS heading | OK. |
| 3 | Paragraphs 11-23 | OK. |
| 4 | Paragraphs 24-34, the appraisal clause (block quotation) begins | OK. The quotation is single spaced and indented 0.75 in on both sides. |
| 5 | End of the quotation, paragraphs 35-43 | OK. |
| 6 | Paragraphs 44-51, CAUSES OF ACTION, Counts I and II | OK. Count headings centered bold. |
| 7 | Paragraphs 52-54, items (a)-(c) | OK. |
| 8 | Items (d)-(l), paragraphs 55-57, Count III | OK. |
| 9 | Count IV, paragraphs 58-60, WHEREFORE with items (a)-(i) | OK. |
| 10 | JURY DEMAND heading, demand, signature block | OK. The demand keeps with the signature block, so the block never stands alone. |

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/complaint --engine typst
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/complaint --engine docx
```

Body lines on a 24 pt pitch, single lines (caption, quotation, signature) on 13.8 pt, in both engines (`lib/typst/xengine.typ`; the docx in exact line spacing of the same twips).

## Engines

DOCX engine (fb-595.68.29): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`; `fb render` builds `reference.docx` from it) and `docx/kyed-complaint.lua` (the court title, the caption table between two rules, the numbered paragraphs, the lettered items and the signature block, each paragraph in exact line boxes of the typst pitches). No shell script. pandoc reads the sample with definition lists off, so a `~ ` paragraph after another paragraph stays a paragraph. The LibreOffice PDF breaks every line and page as the typst render (XENG-001..003 PASS, gated). No latex engine in this folder.

Links: [District Court index for kyed](../README.md) | [Doc type: motion-brief](../motion-brief/README.md)
