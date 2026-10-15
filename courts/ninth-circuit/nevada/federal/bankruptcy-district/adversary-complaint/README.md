# Bankruptcy court, D. Nev. (nvb): adversary complaint

- Court: `nvb`, United States Bankruptcy Court, District of Nevada (`courts/ninth-circuit/nevada/federal/bankruptcy-district/`)
- Doc type: `adversary-complaint`. A complaint commencing an adversary proceeding (FRBP 7001 et seq.), with numbered paragraphs, separate claims for relief, and a prayer.
- Exemplar: `exemplars/FILED-EXAMPLE-lovato-v-sasson-26-05033-adversary-complaint.pdf` (*Lovato v. Sasson*, Adv. No. 26-05033-gs, filed 2026-08-05; provenance in `exemplars/SOURCE.md`). One filer only; see Gaps.
- Sample: `samples/INPUT-lovato-v-sasson-complaint.md` (transcribed from the exemplar; 10 pages rendered, the exemplar's 10).
- Status: template, render, overlay and page review done (below). `court.json` untouched; no status set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nvb-adversary-complaint`. |
| `typst/nvb-adversary-complaint.typ` | Template. Parameter block at the top (type size, leading, line numbers, margins), with the rule each traces to. |
| `samples/INPUT-lovato-v-sasson-complaint.md` | Markdown contract sample (frontmatter: counsel, debtor, caption parties, case and adversary numbers, title, signature; body: headings, numbered paragraphs, a block quotation, a lettered list, the prayer). |
| `samples/OUTPUT-lovato-v-sasson-complaint.pdf` | `sh tools/render.sh courts/ninth-circuit/nevada/federal/bankruptcy-district/adversary-complaint samples/INPUT-lovato-v-sasson-complaint.md` (10 pages, EB Garamond only, no typst warnings). |
| `samples/OVERLAY-lovato-v-sasson-complaint.pdf`, `.txt` | `sh tools/overlay.sh <court>/adversary-complaint lovato-v-sasson-complaint` (red = ours, blue = filed, black = both agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary sources, read on 2026-10-14:

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 9004(a) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/9004>) | Papers on 8 1/2 by 11; double-spaced unless the court orders otherwise; each printed line consecutively numbered in the left margin; exemptions for exhibits, footnotes, quotations, attorney identification, caption, court title and case name; the title page begins at least 1 1/2 inches from the top | `line-numbers()` (28 lines, 24 pt pitch), `title-page-lines = 2` (counsel block starts on line 3, 1.67 in), single-spaced caption, counsel block and quotations |
| LR 9004(b) | Proportional font at least 12 point; all pages numbered consecutively | `type-size = 13pt` (style choice above the 12-point floor), `footer-size = 12pt`, `page-number()` |
| LR 9004(c) | Signature typed beneath the signature space; "/s/" and the filer's name in an electronic filing | `signature-block()`: "/s/ Name", then the name |
| LR 9004(g) | First page: the filing attorney's identifying information at the top left | `counsel-block()` (one column per counsel group, at the top of the title page) |
| LR 7010(b) (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7010>) | Caption includes the adversary proceeding caption and the adversary number, in addition to the case caption (and LR 9004) | `caption()`: case number and chapter at right; "Adversary No." line filled from frontmatter |
| LR 7008 (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules/7008>) | The first pleading in an adversary proceeding states whether the pleader consents to final orders or judgments by the bankruptcy judge | Not a template feature: the statement is author content (the sample's paragraph 5 carries it, as the exemplar does) |
| Fed. R. Bankr. P. 7010 (<https://www.law.cornell.edu/rules/frbp/rule_7010>) | Adversary pleadings follow Fed. R. Civ. P. 10; the caption substantially conforms to Form 416 | Numbered paragraphs (`numbered-item`), separate claim headings |

Local rules index: the court says its complete set is dated 3/2/2021 and the rules listed are "in effect as of January 1, 2021" (<https://www.nvb.uscourts.gov/rules-forms/rules/local-rules>). No later amendment was found on the site when read; re-check before relying on this folder for a filing.

Choices that the rules leave open (tier 2 or 3, not asserted mechanically): the cover layout (counsel block, court title centered, caption grid), heading styles (level 1 centered bold capitals, level 2 centered bold, level 3 run-in), the lettered prayer list, the signature column.

## Overlay

`samples/OVERLAY-lovato-v-sasson-complaint.pdf` puts our render (red) over the best-matching filed page (blue). Pages are paired by word overlap, not index. Diagnostic only, not a score. Pairings from the last run:

- p.1 ↔ filed p.1 (87%), p.2 ↔ p.2 (84%), p.3 ↔ p.3 (87%), p.4 ↔ p.4 (84%): cover, parties, jurisdiction line up.
- p.5 ↔ p.5 (59%) through p.10 ↔ p.9 (47%): the body lines up with the same passages, but page breaks fall elsewhere because the filed ECF header and its spacing are not reproduced and our text runs with a different line count. Pagination differs; the text does not.
- The filed exemplar's ECF header ("Case 26-05033-gs Doc 1 Entered ...") is an electronic-filing stamp added by the court, not part of the author's paper; the template does not reproduce it.

## Page review (Gate 2)

Every page of `OUTPUT-lovato-v-sasson-complaint.pdf` was rasterized at 60 dpi and viewed (10 of 10), against the filed exemplar page of the same number.

| Page | Content | Result |
|---|---|---|
| 1 | Counsel block at line 3 (title page 1 1/2 in down), court title, caption with adversary number, complaint title, lead-in, paragraphs 1 | PASS |
| 2 | Paragraphs 2–8: jurisdiction and venue heading, factual allegations, list a–d | PASS |
| 3 | List e–k, paragraph 9 | PASS |
| 4 | Paragraphs 10–14; recitals as a single-spaced block quotation | PASS |
| 5 | Paragraphs 15–24 | PASS |
| 6 | Paragraph 25; FIRST CLAIM heading; statute quotation as a single-spaced block; paragraphs 28–30 | PASS |
| 7 | SECOND CLAIM heading; paragraphs 31–36; badges of fraud list | PASS |
| 8 | Paragraphs 36–43; THIRD CLAIM heading | PASS |
| 9 | FOURTH and FIFTH CLAIM headings; paragraphs 44–49; PRAYER heading; WHEREFORE | PASS |
| 10 | Prayer a–f; signature block with two firms ("/s/", names, roles) | PASS |

## Gaps

- **One filer only.** The brief asks for one exemplar; EVAL-LOOP tier 2 asks for two or three filers. `exemplars/SOURCE.md` records two other D. Nev. adversary complaints (Adv. 26-05029 and 26-05034, not saved), and a class-action complaint (Adv. 26-05036). Tier 2 is therefore judged against one filer and the result is provisional.
- Tier-2 choices we did not take from the exemplar: the exemplar's Times face (we use EB Garamond, vendored, at 13 pt); its caption rules and the adversary-number placement (ours fills the line from frontmatter).
- The "Dated" line and the two-firm signature block follow the sample; the exemplar's signature order is not compared line by line.
- Summons and cover sheet (LR 7003) are not produced; the template is the complaint only.
- The sample's lettered prayer items (a–f) are the template's convention; the exemplar's prayer numbering was not compared item by item.

## Engines

docx (`docx/`): `docx/reference.docx` (built by `sh docx/build-reference.sh docx/reference.docx` from pandoc's default reference) and the filter `docx/nvb-adversary-complaint.lua`. Rendered with `sh tools/render.sh --engine docx <this folder> samples/INPUT-lovato-v-sasson-complaint.md`: `samples/OUTPUT-lovato-v-sasson-complaint.docx` and its LibreOffice PDF `.docx.pdf` (10 pages; the typst render is 10 pages). Page review: `reviews/2026-10-15-docx.md` (every page viewed).

What matches the typst output:
- US Letter; top margin 1 in; left 1.5 in; right 0.75 in; bottom 48 pt; the text area is 28 lines at exact 24 pt.
- EB Garamond 13 pt throughout (embedded as EBGaramond-Regular, -Bold, -Italic in the PDF).
- 28 line numbers on every page, fixed to the page, as typst does. They are a text box anchored to the page in the header (a Word pleading-paper box), not `w:lnNumType`: section line numbering counts body lines only, so a single-spaced caption and blank lines would give other than 28 numbers per page.
- Counsel block in columns, court title, caption (rule under and right of the party column), numbered paragraphs (number, then a tab to 0.8 in), lettered and bulleted lists, headings (level 1 centered bold capitals, level 2 centered bold), signature block (Dated; firm; "/s/" name; name; role), consecutive page numbers centered in the footer, one rule left of the text.
- The cover, caption and signature are tables whose row heights are rounded up to whole numbered lines, so the text after them sits on the numbered lines.

What differs from typst:
- Block quotations are 0.5 in indented on both sides. typst's quotation is narrower on the right (its width is text width minus 1 in, then padded 0.5 in on each side, which leaves a 1.5 in right indent); that looks like a sizing error in the reference, not a court form, so it is not copied. Paragraphs of a quotation are about 12 pt apart (typst 6.5 pt).
- The vertical rule runs from the top margin to the bottom margin, not the full page height.
- Grid rounding of the cover and signature uses an estimate of wrapped lines (EB Garamond widths). If Word wraps a line differently, a block can end up a fraction of a line off the numbered lines below it. A quotation's height is estimated the same way.
- Word has not been used to open the file. LibreOffice opens and converts it with no repair prompt. The header text box is Word 2010+ DrawingML (`wps`) without an `mc:AlternateContent` fallback.

BLOCKED:
BLOCKED: check.sh (all gates, every docx check ID): not runnable in this folder. `tools/check.sh` reads `<court-dir>/court.json`, `<court-dir>/checks.yaml`, `rules.md` and `reviews/`, and this doc-type folder has only the template, samples and exemplars (`court.json` exists only at `../` (the court folder); `checks.yaml` and `rules.md` exist nowhere in this court yet). No docx gate was evaluated, so `samples/.check-docx.txt` is not written and the docx engine is not marked passing.
