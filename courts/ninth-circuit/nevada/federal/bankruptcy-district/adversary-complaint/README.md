# Bankruptcy court, D. Nev. (nvb): adversary complaint

- Court: `nvb`, United States Bankruptcy Court, District of Nevada (`courts/ninth-circuit/nevada/federal/bankruptcy-district/`)
- Doc type: `adversary-complaint`. A complaint commencing an adversary proceeding (FRBP 7001 et seq.), with numbered paragraphs, separate claims for relief, and a prayer.
- Exemplar: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (*Lovato v. Sasson*, Adv. No. 26-05033-gs, filed 2026-08-05; provenance in `usage/SOURCE.md`). One filer only; see Gaps.
- Sample: `usage/INPUT-adversary-complaint.md` (transcribed from the exemplar; 10 pages rendered on typst and docx, the exemplar's 10).
- Status: typst and docx templates on the shared cross-engine layout model; `check.sh` green on both engines, docx gated on the typst render (`eval.yaml`). `court.json` untouched; no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nvb-adversary-complaint`. |
| `typst/nvb-adversary-complaint.typ` | Template on `lib/typst/xengine.typ`. Parameter block at the top (type size, pitches, line numbers, margins, indents), with the rule each traces to. |
| `docx/reference.xml` | Word styles (the cross-engine recipe in `{font}`, the typst face), the pleading line numbers (a page-anchored frame in the header), the page border rule, the footer and the last section. `fb render` builds the reference document from it. |
| `docx/nvb-adversary-complaint.lua` | The filter: cover, caption, numbered paragraphs, lists, quotations and signature as Word paragraphs and tables on `lib/docx/xengine.lua`. |
| `docx/lib/tnr.lua` | Times New Roman advances, so the filter counts the lines of a single-spaced block (typst measures them) and rounds the block up to whole numbered lines as typst does. |
| `eval.yaml` | `params.cross_engine: gate`: the docx breaks every line and page as typst does, or the check fails. |
| `usage/OUTPUT-adversary-complaint.typst.pdf`, `.docx`, `.docx.pdf` | `sh tools/render.sh [--engine docx] <this folder> usage/INPUT-adversary-complaint.md` (10 pages each, Times New Roman only). |
| `reviews/2026-10-22.md` | Gate 2 page review of both renders. |

## Governing rules

Primary sources, read on 2026-10-14 (court-wide table in `../rules.md`):

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 9004(a) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9004>) | Papers on 8 1/2 by 11; double-spaced unless the court orders otherwise; each printed line consecutively numbered in the left margin; exemptions for exhibits, footnotes, quotations, attorney identification, caption, court title and case name; the title page begins at least 1 1/2 inches from the top | `line-numbers()` (27 lines of 24 pt inside 1 in margins), `title-page-lines = 2` (counsel block starts on line 3, 1.67 in); counsel block, caption and quotations single-spaced in 12 pt lines (half a numbered line) |
| LR 9004(b) | Proportional font at least 12 point; all pages numbered consecutively | `type-size = 12pt` (the floor and the exemplar's size), Times New Roman (no face named; the house standard), page number centered in the footer |
| LR 9004(c) | Signature typed beneath the signature space; "/s/" and the filer's name in an electronic filing | `signature-block()`: "/s/ Name", then the name |
| LR 9004(g) | First page: the filing attorney's identifying information at the top left | `counsel-block()` (one column per counsel group, at the top of the title page) |
| LR 7010(b) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7010>) | Caption includes the adversary proceeding caption and the adversary number, in addition to the case caption | `caption()`: case number and chapter at right; "Adversary No." line filled from frontmatter |
| LR 7008 (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7008>) | The first pleading in an adversary proceeding states whether the pleader consents to final orders or judgments by the bankruptcy judge | Not a template feature: the statement is author content (the sample's paragraph 5 carries it, as the exemplar does) |
| Fed. R. Bankr. P. 7010 (<https://www.law.cornell.edu/rules/frbp/rule_7010>) | Adversary pleadings follow Fed. R. Civ. P. 10; the caption substantially conforms to Form 416 | Numbered paragraphs (`numbered-item`), separate claim headings |

Local rules index: the court says its complete set is dated 3/2/2021 and the rules listed are "in effect as of January 1, 2021" (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules>). Re-check before relying on this folder for a filing.

Choices that the rules leave open (tier 2, from the exemplar): the cover layout (counsel columns, court title centered, caption ruled at the right and foot of the party column), headings (level 1 centered bold capitals underlined, level 2 centered bold), paragraph numbers half an inch in with the text from 1 in, lettered prayer and list items 1 in from the margin, no space between double-spaced paragraphs, the signature column.

## Layout model (both engines)

Every line is a box of its pitch with the baseline at 0.8 of it: 24 pt for the double-spaced body (one numbered line), 12 pt for single-spaced blocks (half a numbered line). A single-spaced block (counsel block, caption, signature: a table row; a quotation: the space after it) is rounded up to whole numbered lines, so the text after it is back on the numbered lines; typst measures the block, the docx filter counts its lines first fit with the face's advances (`docx/lib/tnr.lua`). The numbers sit 1.2 pt below the double-spaced baseline, as far above a single line at the foot of a slot, so every line beside a number groups with it alike in both engines' PDF text.

## Gaps

- **One filer only.** EVAL-LOOP tier 2 asks for two or three filers. `usage/SOURCE.md` records other D. Nev. adversary complaints (Adv. 26-05029, 26-05034, 26-05036) not saved. Tier 2 is judged against one filer and is provisional.
- The exemplar has 28 numbered lines a page; ours has 27, inside 1 in margins. The exemplar draws a line under each "/s/"; ours does not.
- Summons and cover sheet (FRBP 7003-7004) are not produced; the template is the complaint only.
- docx: the pleading rule is a page border, so it runs the height of the text area, not the full page as in typst. Word has not been used to open the file; LibreOffice opens and converts it.
