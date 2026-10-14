# Bankruptcy court, D. Nev. (nvb): motion with memorandum of points and authorities

- Court: `nvb`, United States Bankruptcy Court, District of Nevada (`courts/ninth-circuit/nevada/federal/bankruptcy-district/`)
- Doc type: `motion-brief`. A contested-matter motion in the main case, with its legal memorandum in the same paper (LR 9014(c)(1)); the motion here is a Rule 59(e)/60(b) motion for reconsideration.
- Exemplar: `exemplars/FILED-EXAMPLE-epica-human-health-26-50579-motion-brief.pdf` (*In re Epica Human Health LLC*, Case No. BK-26-50579-gs, Motion for Reconsideration, filed 2026-07-16, ECF 79; provenance in `exemplars/SOURCE.md`). One filer only; see Gaps.
- Sample: `samples/INPUT-epica-motion-reconsideration.md` (transcribed from the exemplar; 10 pages rendered, the exemplar's 10).
- Status: template, render, overlay and page review done (below). `court.json` untouched; no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nvb-motion-brief`. |
| `typst/nvb-motion-brief.typ` | Template. Parameter block at the top, with the rule each traces to. Footnotes, block quotations, lists, headings and the signature are handled here. |
| `samples/INPUT-epica-motion-reconsideration.md` | Markdown contract sample: frontmatter (counsel, debtor, case number, chapter, title, hearing, date, signature); body with headings, paragraphs, one footnote, a block quotation, and a certificate of service. |
| `samples/OUTPUT-epica-motion-reconsideration.pdf` | `sh tools/render.sh <court>/motion-brief samples/INPUT-epica-motion-reconsideration.md` (10 pages, EB Garamond only, no typst warnings). |
| `samples/OVERLAY-epica-motion-reconsideration.pdf`, `.txt` | `sh tools/overlay.sh <court>/motion-brief epica-motion-reconsideration` (red = ours, blue = filed, black = both agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary sources, read on 2026-10-14:

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 9004(a) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9004>) | Papers on 8 1/2 by 11; double-spaced unless the court orders otherwise; each printed line consecutively numbered in the left margin; exemptions for exhibits, footnotes, quotations, attorney identification, caption, court title and case name; the title page begins at least 1 1/2 inches from the top | `line-numbers()` (28 lines, 24 pt pitch); `title-page-lines = 2`, so the counsel block starts on line 3 (1.67 in); footnotes, quotations, counsel block and caption single-spaced |
| LR 9004(b) | Proportional font at least 12 point; all pages numbered consecutively | `type-size = 13pt` (style choice above the 12-point floor), footnote text at `type-size`, `page-number()` |
| LR 9004(c) | Signature typed beneath the signature space; "/s/" and the filer's name in an electronic filing | `signature-block()`: "/s/ Name", then the name, then the role line |
| LR 9004(g) | First page: the filing attorney's identifying information at the top left | `counsel-block()` |
| LR 7010 (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7010>) | Caption: LR 9004 applies; the adversary caption is needed only for an adversary complaint | `caption()` has no adversary line, since this is a main-case motion |
| LR 9014(b)(1) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9014>) | Notice of hearing is a separate document filed with the motion; it states the date, time and place, a description of the relief, and the objection deadline, with the prescribed warning | Not produced (see Gaps). The caption carries "Hearing Date" and "Hearing Time" from frontmatter; the exemplar shows "TBD" |
| LR 9014(b)(2) | Proof of service filed within seven days of the motion | Not produced (see Gaps); the sample's certificate of service is the exemplar's text |
| LR 9014(c)(1) | The motion states the facts on which it is based and contains a legal memorandum; no prescribed order of contents | Body order follows the exemplar (intro, summary, jurisdiction, background, legal argument, conclusion, certificate) |
| LR 9014(e)(1) | Opening brief or points and authorities: 20-page limit, excluding exhibits, tables and the caption | Sample is 10 pages; the limit is not measured by the template |
| LR 7008 (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7008>) | The first pleading, motion or paper in a contested matter states whether the pleader consents to final orders or judgments by the bankruptcy judge | Author content; the sample's jurisdiction paragraph carries it, as the exemplar does |

Local rules index: the court says its complete set is dated 3/2/2021 and the rules listed are "in effect as of January 1, 2021" (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules>). No later amendment was found on the site when read; re-check before relying on this folder for a filing.

Choices the rules leave open (tier 2 or 3, not asserted mechanically): the cover layout, the caption rule and the centered court title (the template uses "FOR THE DISTRICT OF NEVADA", as the exemplar does), heading styles (level 1 centered bold capitals, level 2 centered bold, level 3 run-in bold), the signature column.

## Overlay

`samples/OVERLAY-epica-motion-reconsideration.pdf` puts our render (red) over the best-matching filed page (blue). Pages are paired by word overlap, not index. Diagnostic only, not a score. Pairings from the last run:

- p.1 ↔ filed p.1 (82%), p.2 ↔ p.2 (63%), p.3 ↔ p.3 (61%): the cover, the caption and the opening paragraph line up. Our counsel block starts at line 3 (the title-page offset in LR 9004(a)); the exemplar starts at line 1, and the overlay shows the offset.
- p.4 ↔ p.4 (52%) through p.7 ↔ p.7 (48%): the legal argument, with the same passages on the same pages in the filed copy, but different line breaks.
- p.8 ↔ p.7 (54%), p.9 ↔ p.8 (65%), p.10 ↔ p.9 (68%): the last pages, conclusion and certificate of service.
- The filed exemplar's counsel footer (bottom left, page 1 only) and its "* * * * *" ornament above the court title are not reproduced; see Gaps.

## Page review (Gate 2)

Every page of `OUTPUT-epica-motion-reconsideration.pdf` was rasterized at 60 dpi and viewed (10 of 10), against the filed exemplar page of the same number.

| Page | Content | Result |
|---|---|---|
| 1 | Counsel block at line 3; court title; caption with case number and chapter; title, hearing date and time; body begins on page 2 | OPEN: four blank lines sit above the footnote because the footnote (six lines) leaves no room for the first body paragraph. The filed exemplar's shorter footnote lets its body start on page 1. Tier 2; see Gaps. |
| 2 | Opening paragraphs of the motion (footnote 1 is on page 1); memorandum introduction; SUMMARY heading | PASS |
| 3 | SUMMARY continued; JURISDICTION; BACKGROUND | PASS |
| 4 | BACKGROUND continued; LEGAL ARGUMENT heading; section A heading (centered bold, two lines) | PASS |
| 5 | Section A continued; block quotation of Wright, Miller & Kane, single-spaced and indented | PASS |
| 6 | Section A continued; Notice Requirement heading (level 3, run-in) | PASS |
| 7 | Section B heading; subsection 1 heading (level 3); body | PASS |
| 8 | Subsection 1 continued; subsection 2 heading | PASS |
| 9 | Section C heading; body | PASS |
| 10 | Body; CONCLUSION; signature block (firm, "/s/", name, role); CERTIFICATE OF SERVICE with its signature lines kept together | PASS |

## Gaps

- **One filer only.** EVAL-LOOP tier 2 asks for two or three filers. `exemplars/SOURCE.md` records a second candidate (a Womble Bond Dickinson motion to compel in the lead case, ECF 279, not saved) and a pro se motion (not a counsel model). Tier 2 is therefore judged against one filer and the result is provisional.
- **Page 1 (OPEN).** A six-line footnote on page 1 pushes the first body paragraph to page 2, leaving four blank lines above the footnote. The footnote text is transcribed unchanged and cannot be shortened, and the footnote cannot go below 12 point (LR 9004(b)). A fix would have to change how the first paragraph is split across pages, which is tier 2 layout work not yet done. Left open rather than hidden.
- **Notice of hearing and proof of service** (LR 9014(b)(1)-(2)) are separate documents and are not produced. The sample's hearing block reads "TBD", as the exemplar does.
- **Filed-copy features not reproduced:** the counsel footer on page 1 (bottom left), the "* * * * *" ornament above the court title, and the underline below the debtor's name (the template draws a right and bottom rule instead, as the adversary template does).
- **Title-page offset.** The exemplar's counsel block starts on line 1. LR 9004(a) requires the title page to begin at least 1 1/2 inches from the top, so the template starts it on line 3. That is a deliberate departure from the exemplar, to follow the rule.
- **Sample edits.** The sample was changed in two places to match the markdown contract: a `[signature]` marker after the conclusion (the frontmatter signature block is placed there, as in the exemplar; before, the block sat after the certificate), and the certificate's three `[sig]` lines were merged into one chunk so they render as one block and do not orphan. The words are unchanged; the overlay pairs the same passages.
- Type size 13 pt is a style choice above the 12-point floor (see the template's parameter block).
