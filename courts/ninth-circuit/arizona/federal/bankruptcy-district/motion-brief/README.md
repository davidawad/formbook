# D. Ariz. Bankr. (arb): motion with memorandum

Doc type: **motion** (FRBP 9013) with the memorandum of points and authorities that LRBP 9013-1(a) requires, in the United States Bankruptcy Court for the District of Arizona (`arb`, Ninth Circuit). Folder: `courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief/`. The same folder serves a motion in an adversary proceeding (dual caption) and a contested matter in the main case (single caption).

**BLOCKED: no exemplar.** No public filed motion from this court was found after the searches listed in `exemplars/SOURCE.md`. The template is built from the rules. The sample is fictional (`samples/INPUT-generic-motion.md`), not transcribed from a filing, so this folder has no tier-2 evidence against a real filer.

| Item | Status |
|---|---|
| exemplar | no (`exemplars/SOURCE.md`: BLOCKED) |
| sample md | `samples/INPUT-generic-motion.md` (fictional, generic; 5 rendered pages) |
| render | ok: `samples/OUTPUT-generic-motion.pdf`, 5 pages, typst 0.15.0, vendored EB Garamond only (Regular, Italic, Bold), no warnings |
| overlay | fail: `tools/overlay.sh` needs `exemplars/*.pdf` and there is none, so it exits 1 and writes nothing |
| pages reviewed | 5 of 5 (every page rasterised at 60 dpi and viewed, after the last template change) |

Note on file names: the brief asked for `samples/<id>.pdf` and `samples/<id>-overlay.pdf`. The shared tools write `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf`/`.txt`, and `overlay.sh` reads `OUTPUT-<id>.pdf`. The tools were not changed, so this folder follows the tools' names.

## Governing rules

| ID | Rule | Requirement | Source and date verified | Where it lives |
|---|---|---|---|---|
| ARB-MOT-001 | FRBP 9013(a), (b) | A request for an order must be made by written motion unless an application is authorized or the request is made during a hearing. "A motion must state its grounds with particularity and set forth the relief or order requested." | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_9013 (fetched 2026-10-14). | The opening paragraph and the `relief` line in the caption; the body is author-written |
| ARB-MOT-002 | LRBP 9013-1(a) | "All motions, unless made in open Court, must include a memorandum setting forth the supporting authorities." | Court rule page https://www.azb.uscourts.gov/rule-9013-1 (WebFetch, 2026-10-14). The rule text was given as a summary with this quotation. | The sample's "Memorandum of Points and Authorities" section; the template does not check its presence |
| ARB-MOT-003 | LRBP 9013-1(b) | A motion, response or reply and its supporting memoranda "must not exceed fifteen (15) pages exclusive of attachments," unless the court orders otherwise. | Same. | `page-limit = 15`; the template fails the build past 15 pages (checked, see the record below) |
| ARB-MOT-004 | LRBP 9013-1(e), (i), (k) | Ex parte or unopposed motions must be accompanied by a form of order; accelerated hearings are a separate motion; the movant gives notice of the hearing (date, time, place, relief, response deadline) and files a certificate or affidavit of service. | Same (WebFetch summary, 2026-10-14). | Not generated. The notice and certificate are author-written (see gap 5). |
| ARB-FORM-001 | LRBP 9004-1(g) | Papers on 8½ × 11 inch paper; left margin at least 1½ inches, right margin at least ½ inch; number-lined pleading paper, no more than 28 lines per page; double-spaced except footnotes and indented quotations. | Court rule page https://www.azb.uscourts.gov/rule-9004-1 (WebFetch, 2026-10-14). The Local Rules PDF (effective June 1, 2026) was located but could not be downloaded from this box. | `page-w`, `page-h`, `left-margin`, `right-margin`, `lines-per-page`, `pitch`, `line-numbers()` |
| ARB-FORM-002 | LRBP 9004-1(g) | "The text must be in a proportional font size no smaller than 13 point"; footnotes may be 12 point. | Same. | `type-size = 13pt`, `footnote-size = 12pt` |
| ARB-FIRST-001 | LRBP 9004-1(a) | First page: the filer's law firm or name, mailing address, email, responsible counsel and State Bar number, telephone, and the party represented, "starting at line one". | Same. | `filer-block()` from line 1 (`filer` frontmatter) |
| ARB-CAP-001 | LRBP 1005-1(a) | The caption designates the court as "United States Bankruptcy Court, District of Arizona". | https://www.azb.uscourts.gov/rule-1005-1 (WebFetch, 2026-10-14). | `court-title` in the template |
| ARB-CAP-002 | LRBP 9004-1(a) | The caption includes the court title, the debtor's name, the chapter, the case number, and a brief description of the relief requested. | Same as ARB-FORM-001. | `caption()`: debtor, chapter, case number, `relief` |
| ARB-CAP-003 | LRBP 9004-1(b) | "Any filed document must include in the caption the complete case number assigned by the Court and the chapter of the case." | Same. | `debtor.case_number`, `debtor.chapter` |
| ARB-CAP-004 | LRBP 9004-1(c) | Adversary proceedings are dual captioned: the first caption names the debtor; the second names the plaintiffs and defendants and the adversary number. | Same. | `caption()` with `adversary_number` present (two-row grid) |
| ARB-CAP-005 | LRBP 9004-1(e) | If known, the caption includes the hearing's date, time and place, on the right side beneath the case number. | Same. | `hearing` (optional) in the right column |
| ARB-FRBP-7008 | FRBP 7008(a) | In an adversary proceeding, a complaint, counterclaim, crossclaim or third-party complaint must state consent or non-consent to final orders. A pleading in response is not covered by the template. | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_7008 (fetched 2026-10-14). | The sample's legal standard paragraph cites it; not checked by the template |

Authorities cited in the sample (Bankruptcy Code §§ 547, 548, 550; *Twombly*; *Iqbal*; Fed. R. Bankr. P. 7012(b)) are written for the structure of the sample. They were not checked against the reporters or the Code in this session, and the sample is not a filing. Do not copy them into a real filing without checking.

Not produced: certificate of service (LRBP 9013-1(k); author-written when needed), notice of hearing (author-written), proposed order (LRBP 9013-1(e)), table of contents and table of authorities (no rule read here requires them; see gap 4), and the attachments that LRBP 9013-1 excludes from the page count.

## Layout

- Numbered lines 1 to 28 down the left margin on a 24-point grid, with a double rule at the text's left edge and a single rule at its right (LRBP 9004-1(g)).
- Top margin 1 inch; the 28 lines end at 10.33 inches; the footer sits in the bottom margin.
- Filer block single-spaced from line 1 (LRBP 9004-1(a)); the court title is on line 8 (convention).
- Caption: a debtor row (in re, names, Debtor; chapter and case number) and, in an adversary, a parties row (plaintiffs and defendants, adversary number, title, relief, hearing). Without an adversary, one caption row with the title, relief and hearing on the right.
- Headings: level 1 is a centred bold capital section (MEMORANDUM OF POINTS AND AUTHORITIES); levels 2 to 5 are numbered I., A., 1., a. with a hanging label. Level 2 is the section; the number is typed by the template, not by the author.
- Body paragraphs double-spaced with a 0.5-inch first-line indent; paragraphs are not numbered (motions are not pleadings under FRCP 10(b)). Lists are numbered 1., 2., ...
- A heading stays with the paragraph after it. The last body chunk, the signature block and any certificate are kept together, so a signature never stands alone on a page.
- Footnotes: 12 point, single-spaced; each footnote definition is rendered with the paragraph that refers to it.
- Footer: page number, the title in capitals, and `ADV. NO.` (adversary) or `CASE NO.` (main case).

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` (level 1, centred bold capitals), `##` to `#####` (numbered headings), a list, or a paragraph.
- Frontmatter: `filer` (list of lines, from line 1), `debtor` (`names`, `chapter`, `case_number`), `adversary_number` (optional; if given, `parties` is required), `parties` (list of `{names, designation}`), `title`, `relief`, `hearing` (optional `{date, time, place}`), `footer_title`, `date`, `signature` (`signer`, `lines`).
- Do not type numbers into headings or the text: the template numbers headings from their level and lists from 1.
- Footnotes: `text[^key]` in the paragraph and `[^key]: text` anywhere in the body.

## Known gaps and open choices

1. **No exemplar.** Tier 2 (conventions a clerk expects) is not judged against any filed Arizona motion. Everything here is from the rules, not from a filing.
2. **Font size.** 13-point EB Garamond is the only vendored proportional font. The apparent size is smaller than Times New Roman at 13 point, which is the usual Arizona choice. The 13-point minimum is met.
3. **Court title on line 8.** Convention. LRBP 9004-1(a) fixes line 1 for the filer block and says nothing about the title's line.
4. **No table of contents or table of authorities.** The rules read here do not require them for a motion in this court. A longer memorandum may need them by the judge's practice; the template does not generate them.
5. **Notice of hearing and certificate of service are not generated.** LRBP 9013-1(k) (summarised from the court's rule page, not quoted) requires notice of the hearing and a certificate or affidavit of service; the author writes them in the body.
6. **Page limit counts the whole document.** The 15-page limit excludes attachments, which the template does not separate. A motion that carries attachments in the same PDF would be counted with them. Attachments belong in separate filings.
7. **Keep-with-next gaps.** Headings and a last body block are kept together, so a page can end several lines early (pages 2 to 4 of the sample end with 4 to 6 blank numbered lines). This is the cost of never leaving a heading at the foot of a page. Not fixed.
8. **Footer size.** 11 point, as in the complaint. The 13-point minimum is written for text.
9. **Dual caption layout.** Closed by a rule on the right and bottom of the party column, not a column of ")" marks. Form 416A's exact layout is not part of this doc type's rules.
10. **FRBP 7012(b) and 9015 are cited from memory** in the sample (7012(b) in the text, not checked here). The template does not cite them.
11. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root, and this doc-type folder has neither. The brief forbids touching `tools/`. The render, the page review and the page-limit mutation test below stand in for them.

## Render and review record

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env, see the brief)
sh tools/render.sh courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief samples/INPUT-generic-motion.md
sh tools/overlay.sh courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief generic-motion   # exits 1: no exemplar
```

- Render: exit 0, no typst warnings, 5 pages (letter). Fonts embedded: EBGaramond-Regular, -Italic, -Bold.
- Baseline pitch on body pages: 24.0 pt (as for the complaint; the same leading and grid).
- Page-limit mutation test: a temporary 27-page sample (padded by repeated paragraphs, then deleted) fails the build with "27 pages; LRBP 9013-1(b) allows 15". The 5-page sample passes.
- Page review (60 dpi, all 5 pages, after the footnote fix): p.1 filer block, court title, dual caption with the hearing: pass. p.2 memorandum heading, Introduction, Background, footnote 1 at foot of page (12 point, single-spaced): pass. p.3 Legal Standard, Argument A and A.1 with the 7008(a) paragraph: pass; gap of 6 lines at foot (gap 7). p.4 A.2, B, B.1, B.2 with the paragraphs: pass; gap of 4 lines at foot (gap 7). p.5 Conclusion with the numbered relief list and the signature block: pass.
- Overlay: not run against a filing (no exemplar); `overlay=fail`.
