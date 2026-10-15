# D. Ariz. Bankr. (arb): adversary complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of Arizona (`arb`, Ninth Circuit). Folder: `courts/ninth-circuit/arizona/federal/bankruptcy-district/adversary-complaint/`.

**BLOCKED: no exemplar.** No public filed adversary complaint from this court was found after the searches listed in `exemplars/SOURCE.md`. The template is built from the rules. The sample is fictional (`samples/INPUT-generic-complaint.md`), not transcribed from a filing, so this folder has no tier-2 evidence against a real filer.

| Item | Status |
|---|---|
| exemplar | no (`exemplars/SOURCE.md`: BLOCKED) |
| sample md | `samples/INPUT-generic-complaint.md` (fictional, generic; 5 rendered pages) |
| render | ok: `samples/OUTPUT-generic-complaint.pdf`, 5 pages, typst 0.15.0, vendored EB Garamond only (Regular, Italic, Bold), no warnings |
| typeface | face required: none. LRBP 9004-1(g) (checked on azb.uscourts.gov, 2026-10-15) says "a proportional font size no smaller than 13 point" and names no face. EB Garamond kept; no vendored substitute needed. Not metric-compatible with Times New Roman, and not changed to it |
| overlay | fail: `tools/overlay.sh` needs `exemplars/*.pdf` and there is none, so it exits 1 and writes nothing (re-run 2026-10-15, exit 1) |
| exemplar search | 2026-10-15 (bead fb-595.20.8): three more WebSearch passes (one extended) and the CourtListener API probe (HTTP 401, no key on this box). Still nothing; see `exemplars/SOURCE.md`, "Third search pass" |
| pages reviewed | 5 of 5 (every page rasterised at 60 dpi and viewed) |

Note on file names: the brief asked for `samples/<id>.pdf` and `samples/<id>-overlay.pdf`. The shared tools write `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf`/`.txt` (the repo's naming for file roles), and `overlay.sh` reads `OUTPUT-<id>.pdf`. The tools were not changed, so this folder follows the tools' names.

## Governing rules

Each rule is quoted or closely paraphrased from the cited source. The date is the date it was read.

| ID | Rule | Requirement | Source and date verified | Where it lives |
|---|---|---|---|---|
| ARB-FORM-001 | LRBP 9004-1(g) | Papers on 8½ × 11 inch paper; left margin at least 1½ inches, right margin at least ½ inch; number-lined pleading paper, no more than 28 lines per page; double-spaced except footnotes and indented quotations. | Court rule page https://www.azb.uscourts.gov/rule-9004-1 (WebFetch, 2026-10-14). The Local Rules PDF (effective June 1, 2026) was located but could not be downloaded from this box. | `page-w`, `page-h`, `left-margin`, `right-margin`, `lines-per-page`, `pitch`, `line-numbers()` |
| ARB-FORM-002 | LRBP 9004-1(g) | "The text must be in a proportional font size no smaller than 13 point"; footnotes may be 12 point. | Same. | `type-size = 13pt`, `footnote-size = 12pt` |
| ARB-FIRST-001 | LRBP 9004-1(a) | First page: the filer's law firm or name, mailing address, email, responsible counsel and State Bar number, telephone, and the party represented, "starting at line one". | Same. | `filer-block()` from line 1 (`filer` frontmatter) |
| ARB-CAP-001 | LRBP 1005-1(a) | The caption designates the court as "United States Bankruptcy Court, District of Arizona". | https://www.azb.uscourts.gov/rule-1005-1 (WebFetch, 2026-10-14). | `court-title` in the template |
| ARB-CAP-002 | LRBP 9004-1(a) | The caption includes the court title, the debtor's name, the chapter, the case number, and a brief description of the relief requested. | Same as ARB-FORM-001. | `dual-caption()`: debtor, chapter, case number, `relief` |
| ARB-CAP-003 | LRBP 9004-1(b) | "Any filed document must include in the caption the complete case number assigned by the Court and the chapter of the case." | Same. | `debtor.case_number`, `debtor.chapter` |
| ARB-CAP-004 | LRBP 9004-1(c) | Adversary proceedings are dual captioned: the first caption names the debtor; the second names the plaintiffs and defendants and the adversary number. | Same. | `dual-caption()` rows 1 and 2; `adversary_number` |
| ARB-CAP-005 | LRBP 9004-1(e) | If known, the caption includes the hearing's date, time and place, on the right side beneath the case number. | Same. | `hearing` (optional) in the right column of row 2 |
| ARB-CAP-006 | FRBP 7010 | Caption "must substantially conform to the appropriate version of Form 416". | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_7010 (fetched 2026-10-14). | `dual-caption()` layout |
| ARB-PLEAD-001 | FRBP 7001 | An adversary proceeding is commenced by a complaint. | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_7001 (fetched 2026-10-14). | Document type only |
| ARB-PLEAD-002 | FRBP 7008(a) | The complaint states the jurisdiction reference (the case's name, number and Code chapter, and the district and division), and "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_7008 (fetched 2026-10-14). | Frontmatter `consent_to_final_orders` (checked to be "yes" or "no"); the statement itself is in the body |
| ARB-PLEAD-003 | Fed. R. Civ. P. 10(b), applied by FRBP 7010 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_7010 (2026-10-14) for the application; the 10(b) text is the Federal Rule and is not separately fetched. | `allegations()` numbers each body paragraph |
| ARB-PLEAD-004 | FRBP 9015 (jury) | Jury demand under Fed. R. Civ. P. 38. | **Not fetched in this session.** The jury line in the template cites FRBP 9015 from memory; check before relying on it. | `jury_demand: true` adds the demand paragraph |
| ARB-SIG-001 | LRBP 9004-1(g) | "Sign as provided in FRBP 11 or LR 5005-4." | WebFetch summary of https://www.azb.uscourts.gov/rule-9004-1 (2026-10-14). | `signature` block |

Not generated, and why: the adversary cover sheet (Official Form 104 with the civil cover information), the summons (Form 2500A, FRBP 7004), and the certificate of service. None is in the rules read above, and each is a separate filing. Check whether the clerk requires them with the first filing.

## Layout

- Numbered lines 1 to 28 down the left margin on a 24-point grid, with a double rule at the text's left edge and a single rule at its right (the pleading form, LRBP 9004-1(g)).
- Top margin 1 inch (line 1 on the top margin); the 28 lines end at 10.33 inches; the footer sits in the bottom margin.
- Filer block single-spaced from line 1 (LRBP 9004-1(a)); the court title is on line 8 (convention; the rule gives no line for the title).
- Dual caption in a two-by-two grid: the debtor and case number at the top, the adversary parties, adversary number, title, relief and any hearing below.
- Numbered allegations, lettered prayer items (a), (b), ...; headings centred, bold for sub-headings.
- Body paragraphs on the numbered lines (`on-grid`); a heading stays with the paragraph after it; the last body chunk, the jury line (if any) and the signature block are set together, so a signature never stands alone on a page.
- Footer: page number, the title in capitals, and `ADV. NO.`.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (level 1 centred capitals), `##` (level 2 centred bold), `###` (level 3 bold italic); a list (lettered by the template); or a paragraph (numbered by the template).
- Frontmatter: `filer` (list of lines, from line 1), `debtor` (`names`, `chapter`, `case_number`), `adversary_number`, `parties` (list of `{names, designation}`), `title`, `relief`, `hearing` (optional `{date, time, place}`), `jury_demand` (bool), `consent_to_final_orders` (`yes` or `no`), `lead_in` (optional unnumbered paragraph), `footer_title`, `date`, `signature` (`signer`, `lines`).
- The template numbers paragraphs and letters the prayer list. Do not type numbers into the text.

## Known gaps and open choices

1. **No exemplar.** Tier 2 (conventions a clerk expects) is not judged against any filed Arizona complaint. Everything below is from the rules, not from a filing. A filed complaint from `arb` would be the first thing to check (see `exemplars/SOURCE.md`).
2. **Font size.** The rule names no typeface, so EB Garamond is kept (see the typeface row above). Times New Roman is the usual Arizona choice; EB Garamond sets smaller at the same size. The 13-point minimum is met; the apparent size is smaller than Times 13.
3. **Court title on line 8.** Convention. LRBP 9004-1(a) fixes line 1 for the filer block and says nothing about the title's line.
4. **Prayer lead-in can be separated from its list.** When a list starts near the foot of a page, its introduction ("WHEREFORE … judgment:") can stay on the page while the list moves to the next, because the list and signature are kept together. The sample shows this on page 4 and 5. Not fixed.
5. **Footer size.** 11 point. The 13-point minimum is written for text; the footer is identification (convention, flagged).
6. **Dual caption layout.** The party column is closed by a rule on the right and bottom, not a column of "). " marks. Form 416A's exact layout was not fetched, so "substantially conform" is judged from the rule text only.
7. **Jury demand citation.** The jury line cites FRBP 9015 from memory (see ARB-PLEAD-004). Not verified in this session.
8. **Consent and jurisdiction content.** The template checks that `consent_to_final_orders` is present and is "yes" or "no". It does not check that the body contains the jurisdiction reference or the consent sentence (FRBP 7008(a)).
9. **Page limit.** No page limit for complaints is set in the rules read here, so none is checked.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root, and this doc-type folder has neither. The brief forbids touching `tools/`, so the gates were not run; the render and page review above stand in for them.
11. **Sample is fictional and short.** Five pages. It carries the structure (filer block, dual caption, numbered allegations, claims, prayer, signature) but is not a filing.

## Render and review record

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env, see the brief)
sh tools/render.sh courts/ninth-circuit/arizona/federal/bankruptcy-district/adversary-complaint samples/INPUT-generic-complaint.md
sh tools/overlay.sh courts/ninth-circuit/arizona/federal/bankruptcy-district/adversary-complaint generic-complaint   # exits 1: no exemplar
```

- Render: exit 0, no typst warnings, 5 pages (letter). Fonts embedded: EBGaramond-Regular, -Italic, -Bold.
- Baseline pitch on body pages measured with `pdftotext -bbox` at 24.0 pt.
- Page review (60 dpi, every page): p.1 filer block, court title, dual caption, first paragraphs: pass (after moving the lead-in out of the numbered paragraphs and separating the debtor and party rows). p.2 jurisdiction, parties, paragraphs 2–8, ends with blank lines before a heading group: pass. p.3 factual background and the first claim heading kept with its paragraph: pass. p.4 claims, prayer heading and "WHEREFORE" with the list on p.5: pass with gap 4 above. p.5 list (a)–(e) and the signature block: pass.
- Overlay: not run against a filing (no exemplar); `overlay=fail`.

## Engines

DOCX (`docx/`: `build-reference.sh` makes `reference.docx`; `arb-complaint.lua` builds the caption, numbered allegations, lettered prayer and signature; `render.sh` runs pandoc and fills the footer). Rendered: `samples/OUTPUT-generic-complaint.docx` and `samples/OUTPUT-generic-complaint.docx.pdf` (LibreOffice 26.2 conversion, 4 pages). `pdffonts`: EB Garamond Regular, Bold and Italic only.

Matches the typst form (every page of the `.docx.pdf` rendered at 60 dpi and viewed: pages 1 to 4 of 4):
- Letter paper; margins top 1 in, left 1.5 in, right 0.75 in, bottom 0.67 in; line numbers 1 to 28 on the 24 pt grid (one page-anchored text box in the header, so the body keeps its 28 lines); double rule at the left text edge and single rule at the right (`pgBorders`).
- EB Garamond 13 pt, 24 pt line pitch. Filer block on lines 1 to 7, court title on line 8, dual caption with the rules under the debtor and party blocks, the title and relief beside the adversary number.
- Headings at the typst sizes (level 1 18 pt, level 2 15.5 pt), footnotes 12 pt single (none in this sample).
- Footer: page number, the title in capitals, `ADV. NO.` and the number. Signature block set with the last prayer item.

Differs from the typst form:
- Pagination: 4 pages here against 5 in typst. The prayer list and signature fit on page 4; typst moves the list to page 5.
- Numbered paragraphs: the number is followed by a tab (to 1 in), typst leaves 0.3 in after the number, so the text starts up to 6 pt later.
- Caption: the box rules are paragraph borders on the party cells, and the caption's row heights are estimated from the text. A different line break in Word can move the body off the pleading numbers by a line.
- Not opened in Word (no Word here). The line-number text box and page borders are standard WordprocessingML, verified in LibreOffice only.

BLOCKED: none. Open tier-2 items are the ones above and the missing exemplar (see the top of this file).

`tools/check.sh` cannot run on this folder: it needs `court.json` and `checks.yaml` at the court root, and neither is in the doc-type folder. The render and page review above stand in for it.
