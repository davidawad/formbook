# Bankruptcy court, D. Nev. (nvb): motion with memorandum of points and authorities

- Court: `nvb`, United States Bankruptcy Court, District of Nevada (`courts/ninth-circuit/nevada/federal/bankruptcy-district/`)
- Doc type: `motion-brief`. A contested-matter motion in the main case, with its legal memorandum in the same paper (LR 9014(c)(1)); the motion here is a Rule 59(e)/60(b) motion for reconsideration.
- Exemplar: `usage/FILED-EXAMPLE-motion-brief.pdf` (*In re Epica Human Health LLC*, Case No. BK-26-50579-gs, Motion for Reconsideration, filed 2026-07-16, ECF 79; provenance in `usage/SOURCE.md`). One filer only; see Gaps.
- Sample: `usage/INPUT-motion-brief.md` (transcribed from the exemplar; 12 pages rendered on typst and docx, the exemplar's 10 at 28 lines a page).
- Status: typst and docx templates on the shared cross-engine layout model; `check.sh` green on both engines, docx gated on the typst render (`eval.yaml`). `court.json` untouched; no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nvb-motion-brief`. |
| `typst/nvb-motion-brief.typ` | Template on `lib/typst/xengine.typ`. Parameter block at the top (type size, pitches, line numbers, margins, indents, footnote spacing), with the rule each traces to. |
| `docx/reference.xml` | Word styles (the cross-engine recipe in `{font}`, the typst face; "Nvb Body" and its keep variant for body paragraphs, which carry pandoc's footnotes), the pleading line numbers (a page-anchored frame in the header), the page border rule, the footer and the last section. `fb render` builds the reference document from it. |
| `docx/nvb-motion-brief.lua` | The filter: cover, caption, body, headings, quotations, signature block and `[sig]` lines on `lib/docx/xengine.lua`. |
| `docx/lib/tnr.lua` | Times New Roman advances, so the filter counts the lines of a single-spaced block (typst measures them) and rounds the block up to whole numbered lines as typst does. |
| `eval.yaml` | `params.cross_engine: gate`: the docx breaks every line and page as typst does, or the check fails. |
| `usage/OUTPUT-motion-brief.typst.pdf`, `.docx`, `.docx.pdf` | `sh tools/render.sh [--engine docx] <this folder> usage/INPUT-motion-brief.md` (12 pages each, Times New Roman only). |
| `reviews/2026-10-22.md` | Gate 2 page review of both renders. |

## Governing rules

Primary sources, read on 2026-10-14:

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 9004(a) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9004>) | Papers on 8 1/2 by 11; double-spaced unless the court orders otherwise; each printed line consecutively numbered in the left margin; exemptions for exhibits, footnotes, quotations, attorney identification, caption, court title and case name; the title page begins at least 1 1/2 inches from the top | `line-numbers()` (27 lines of 24 pt inside 1 in margins); `title-page-lines = 2`, so the counsel block starts on line 3 (1.67 in); footnotes, quotations, counsel block and caption single-spaced in 12 pt lines (half a numbered line) |
| LR 9004(b) | Proportional font at least 12 point; all pages numbered consecutively | `type-size = 12pt` (the floor and the exemplar's size), Times New Roman (no face named; the house standard), footnote text at `type-size`, page number centered in the footer |
| LR 9004(c) | Signature typed beneath the signature space; "/s/" and the filer's name in an electronic filing | `signature-block()`: "/s/ Name", then the name, then the role line |
| LR 9004(g) | First page: the filing attorney's identifying information at the top left | `counsel-block()` |
| LR 7010 (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7010>) | Caption: LR 9004 applies; the adversary caption is needed only for an adversary complaint | `caption()` has no adversary line, since this is a main-case motion |
| LR 9014(b)(1) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9014>) | Notice of hearing is a separate document filed with the motion; it states the date, time and place, a description of the relief, and the objection deadline, with the prescribed warning | Not produced (see Gaps). The caption carries "Hearing Date" and "Hearing Time" from frontmatter; the exemplar shows "TBD" |
| LR 9014(b)(2) | Proof of service filed within seven days of the motion | Not produced (see Gaps); the sample's certificate of service is the exemplar's text |
| LR 9014(c)(1) | The motion states the facts on which it is based and contains a legal memorandum; no prescribed order of contents | Body order follows the exemplar (intro, summary, jurisdiction, background, legal argument, conclusion, certificate) |
| LR 9014(e)(1) | Opening brief or points and authorities: 20-page limit, excluding exhibits, tables and the caption | Sample is 12 pages; the limit is not measured by the template |
| LR 7008 (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7008>) | The first pleading, motion or paper in a contested matter states whether the pleader consents to final orders or judgments by the bankruptcy judge | Author content; the sample's jurisdiction paragraph carries it, as the exemplar does |


Local rules index: the court says its complete set is dated 3/2/2021 and the rules listed are "in effect as of January 1, 2021" (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules>). No later amendment was found on the site when read; re-check before relying on this folder for a filing.

Choices the rules leave open (tier 2, from the exemplar): the cover layout, the caption rule and the centered court title ("FOR THE DISTRICT OF NEVADA", as the exemplar has it), headings (level 1 centered bold capitals underlined, level 2 centered bold, level 3 bold at the margin), no space between double-spaced paragraphs, the signature column, the certificate of service on its own page (as filed).

## Layout model (both engines)

Every line is a box of its pitch with the baseline at 0.8 of it: 24 pt for the double-spaced body (one numbered line), 12 pt for single-spaced blocks and footnotes (half a numbered line). A single-spaced block (counsel block, caption, signature, `[sig]` lines: a table row; a quotation: the space after it) is rounded up to whole numbered lines, so the text after it is back on the numbered lines; typst measures the block, the docx filter counts its lines first fit with the face's advances (`docx/lib/tnr.lua`). The numbers sit 1.2 pt below the double-spaced baseline, as far above a single line at the foot of a slot, so every line beside a number groups with it alike in both engines' PDF text. Footnotes stand 18 pt below the body (12 pt to the rule, 6 pt after it), between LibreOffice's footnote spacing and a numbered line, so a page holds the same numbered lines above a footnote in both engines. The paragraph before the signature block or `[sig]` lines is kept whole with it, so a signature never stands alone on a page.

## Gaps

- **One filer only.** EVAL-LOOP tier 2 asks for two or three filers. `usage/SOURCE.md` records a second candidate (a Womble Bond Dickinson motion to compel in the lead case, ECF 279, not saved) and a pro se motion (not a counsel model). Tier 2 is therefore judged against one filer and the result is provisional.
- **Page 1.** The seven-line footnote of the first paragraph leaves room for two body lines on page 1 (the exemplar, at 28 lines and with its counsel block from line 1, fits five). The footnote is transcribed unchanged and cannot go below 12 point (LR 9004(b)).
- **Notice of hearing and proof of service** (LR 9014(b)(1)-(2)) are separate documents and are not produced. The sample's hearing block reads "TBD", as the exemplar does.
- **Filed-copy features not reproduced:** the counsel footer on page 1 (bottom left), the "* * * * *" ornament above the court title, the underline below the debtor's name (the template rules the party column at its right and foot instead), the 28th numbered line, and the signature line under "/s/".
- **Title-page offset.** The exemplar's counsel block starts on line 1. LR 9004(a) requires the title page to begin at least 1 1/2 inches from the top, so the template starts it on line 3.
- **Sample edits.** The sample has a `[signature]` marker after the conclusion (the frontmatter signature block is placed there, as in the exemplar), and the certificate's three `[sig]` lines are one chunk so they render as one block.
- docx: the pleading rule is a page border, so it runs the height of the text area, not the full page as in typst. Word has not been used to open the file; LibreOffice opens and converts it.
