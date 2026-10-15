# E.D. Ky. (kyed): complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/eastern-district/complaint/`. Court alias `kyed`; the court-level `court.json` is not touched here, and nothing in this folder sets `status`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-dubya-j-brands-5-26-cv-00359-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-dubya-complaint.md` (the whole complaint: caption, 60 numbered paragraphs, counts, prayer, jury demand, signature) |
| typeface | face required: none (LR 5.2(a) asks for "at least 12-point proportionately-spaced font"; rule text read 2026-10-15) -> substitute: none, EB Garamond kept (`docs/FONTS.md`, "No face named") -> not applicable |
| render | ok (re-run 2026-10-15): `samples/OUTPUT-dubya-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EB Garamond Regular and Bold embedded), no warnings |
| overlay | fail (re-run 2026-10-15): `tools/overlay.sh` exits 1 because `exemplars/FILED-EXAMPLE-*.pdf` is not in this checkout. The `OVERLAY-dubya-complaint.txt` committed earlier was not regenerated; no `OVERLAY-dubya-complaint.pdf` is in `samples/` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change; re-viewed 2026-10-15 after the re-render, no change) |
| BLOCKED | none |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`), which `tools/render.sh` and `tools/overlay.sh` read and write, not the `<id>.pdf` names in the brief.

## Governing rules

Each requirement has a stable ID (KYED-...) used in the template's comments.

| ID | Rule | Requirement | Where it lives in the template |
|---|---|---|---|
| KYED-FORM-001 | E.D. Ky. LR 5.2(a) | 8½ × 11 inch paper; margins of at least one inch on all sides; text double spaced, except block quotes, headings and footnotes. Primary source: the court's amended Civil Rules, August 2026 (`https://www.kyed.uscourts.gov/sites/kyed/files/KY_Amended_Civil_Rules_August_2026.pdf`, linked from `https://www.kyed.uscourts.gov/local-rules`). Read and quoted 2026-10-14. | `margin-all = 1in`, `line-pitch = 24pt`, `paper: "us-letter"`. |
| KYED-FORM-002 | E.D. Ky. LR 5.2(a) | At least 12-point proportionately spaced font. | `type-size = 12pt`, `font-family = "EB Garamond"` (the rule names no face, so no substitute applies; see the typeface row above). |
| KYED-FIRST-001 | Fed. R. Civ. P. 10(a) | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation (here, the title "COMPLAINT"). Source: https://www.law.cornell.edu/rules/frcp/rule_10, read 2026-10-14. | `court-title`, `caption`, `title` frontmatter. |
| KYED-FIRST-002 | E.D. Ky. LR 3.1 and 3.2 | The division named in the caption ("AT LEXINGTON" in the sample) is the author's choice from the jury-division lists in LR 3.1(a); the template prints the frontmatter lines and does not check the division against the case. | `court` frontmatter. |
| KYED-CONT-001 | Fed. R. Civ. P. 8(a), 10(b) | Short and plain statement of jurisdiction, claim and demand (8(a)); claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances (10(b)). | Numbered paragraphs: each blank-line-separated chunk of the body is one paragraph, numbered 1, 2, ... by the template. |
| KYED-CONT-002 | Convention (no local rule) | Lettered lists in a numbered paragraph and in the prayer are lettered (a), (b), ... by the template. | `set enum(numbering: "(a)")`. |
| KYED-SIG-001 | Fed. R. Civ. P. 11(a) | The paper is signed by an attorney of record, and states the signer's address, e-mail address and telephone number. Source: https://www.law.cornell.edu/rules/frcp/rule_11, read 2026-10-14. | `signature-block`: `signature.preamble`, `signature.signer`, `signature.lines`. |

Not produced by this template (separate filings, listed for the filer): the civil cover sheet and the summons, U.S. Marshal Form 285 (LR 4.3(a)(1), (9), (10)); the disclosure statement (LR 7.1.1 and Fed. R. Civ. P. 7.1). The sample keeps the caption's "Civil Action No." blank, which the clerk fills in.

Pleading (line-numbered) paper is not used. LR 5.2 does not call for it, and the exemplar has none.

## Layout

- Page 1 begins with the caption, not a cover page (the exemplar does the same): court title lines centered and bold; "Civil Action No." centered; "ELECTRONICALLY FILED" when set; a rule; the party column (names, then the designation right-aligned, "v." between parties) and, in the right column, "JURY DEMAND" when set; a second rule; the title "COMPLAINT" centered and bold.
- Body: the opening sentence is unnumbered (`:: `); numbered paragraphs have a 0.5 in first-line indent; section headings are centered caps; count headings are centered bold; the WHEREFORE paragraph is unnumbered.
- Block quotations (`> `) are single spaced and indented 0.75 in on both sides. The policy clause in paragraph 34 uses this form.
- Signature block at the right half of the page, single spaced: "Respectfully submitted," firm, `s/` line, then the signer's bar number, address, telephone, fax, e-mail and "Attorney for Plaintiff".
- Footer: centered page number.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between parties), `case_number` (text after "Civil Action No."), `electronically_filed` (bool), `jury_demand` (bool), `title`, `signature` (`preamble` lines above "Respectfully submitted", `signer`, `lines` below the `s/` line).
- Body: `#` = centered caps heading (section); `##` = centered bold heading (count); a line starting `:: ` = unnumbered paragraph; a block starting `> ` = block quotation; a chunk starting `1.` = lettered list `(a)`, `(b)`, ...; any other chunk = numbered paragraph.
- Not supported: tables, footnotes (none in a complaint), raw typst.
- The sample does not type the paragraph numbers; the template numbers them.

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the exemplar page that shares the most words: ours p.1-9 with filed p.1, 2, 4, 5, 6, 7, 9, 10, 11 (the filed p.3 and p.8 are not paired because our page breaks differ; the word overlap is 51-79%). Red is our render, blue the exemplar, black both. The exemplar uses Times New Roman and a larger apparent type size, and our page breaks differ, so the text lines do not coincide. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one filed document per doc type, and that is what is saved. Tier 2 asks for two or three filers. The search that found the Dubya complaint was CourtListener RECAP (`https://www.courtlistener.com/api/rest/v4/search/?q=complaint&court=kyed&type=r&order_by=dateFiled+desc`, run 2026-10-14). Other complaints in those results: *Travelers Casualty Insurance Co. v. EN V US Hamburg LLC*, 5:26-cv-00353 (no local RECAP copy); *Howarth v. A & A Lawncare & Landscaping*, 2:26-cv-00374 (not checked for format). Tier 2 is therefore **not** judged against two filers.
2. **Font size.** LR 5.2(a) names no typeface, only "at least 12-point proportionately-spaced font" (rule text read from the court's Civil Rules PDF, 2026-10-15). Under `docs/FONTS.md` ("No face named") the template keeps EB Garamond, and the rule's 12-point minimum is met. The exemplar's Times New Roman is one filer's choice, not a rule requirement. At 12 pt Garamond sets smaller than that exemplar, so the text looks smaller and the sample runs 9 pages against the exemplar's 11. Switching to Liberation Serif would be a filer's choice, not a rule requirement; the template does not make it.
3. **Lettered lists.** The prayer and the sub-items of paragraph 54 are lettered (a), (b), ... by the template. The exemplar letters its prayer A. through I. and its sub-items a) through l). Neither is a rule requirement; the template uses the cand convention.
4. **Caption layout.** The party column is closed by a rule at the foot and the right side, with "JURY DEMAND" in the right column. The exemplar uses a similar layout with its party names in capitals; the placement is a convention choice.
5. **Paragraph numbers.** The sample transcribes all 60 numbered paragraphs, and the template numbers them 1 to 60, the same as the filed numbering. Rendered paragraph 60 and the WHEREFORE paragraph were checked in the text layer.
6. **Heading placement.** The "JURY DEMAND" heading falls alone at the top of page 9, after the prayer. It is kept with its paragraph; the template does not move the prayer to make room.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect the court-folder shape (`court.json`, `rules.md`); this doc-type folder does not have that shape and the brief does not ask for them. Render and overlay were run, and the review above is the Gate 2 record for this doc type.

## Review of the rendered pages (Gate 2 record, 9 of 9 pages, 60 dpi, viewed after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, opening sentence, parties and jurisdiction, paragraphs 1-4 | OK. Section heading on the grid; paragraphs separated by the 24 pt pitch. |
| 2 | Paragraphs 5-12, FACTS heading | OK. |
| 3 | Paragraphs 13-27 | OK. |
| 4 | Paragraphs 28-37, appraisal clause (block quotation) | OK. The block quotation is single spaced and indented on both sides. |
| 5 | Paragraphs 38-47, CAUSES OF ACTION, Count I heading | OK. |
| 6 | Paragraphs 48-53, Count II heading | OK. |
| 7 | Paragraph 54 with lettered items (a)-(l) | OK. |
| 8 | Paragraphs 55-60, Counts III and IV, WHEREFORE with items (a)-(i) | OK. Count headings centered bold. |
| 9 | JURY DEMAND heading, demand, signature block | OK. The signature block is single spaced on the right half of the page. |

## Build record

Render, run in the shell after `export PATH="$HOME/tb/bin:$PATH"` (typst 0.15.0 from the micromamba env; poppler, ImageMagick and gawk from the same env):

```sh
sh tools/render.sh courts/sixth-circuit/kentucky/federal/eastern-district/complaint samples/INPUT-dubya-complaint.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/eastern-district/complaint dubya-complaint
```

Render line pitch: 24.0 pt on every body line (measured with `pdftotext -bbox-layout`); single-spaced caption and signature lines at 13.8 pt.

Links: [District Court index for kyed](../README.md) | [Doc type: motion-brief](../motion-brief/README.md)
