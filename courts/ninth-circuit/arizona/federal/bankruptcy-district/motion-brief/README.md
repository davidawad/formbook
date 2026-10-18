# D. Ariz. Bankr. (arb): motion with memorandum

Doc type: **motion** (FRBP 9013) with the memorandum of points and authorities that LRBP 9013-1(a) requires, in the United States Bankruptcy Court for the District of Arizona (`arb`, Ninth Circuit). Folder: `courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief/`. The same folder serves a motion in an adversary proceeding (dual caption) and a contested matter in the main case (single caption).

**Exemplar: yes.** A filed motion with memorandum from this court, Doc 762 in the *Titan Solar* jointly administered case (2:24-bk-04978-MCW), is saved as `usage/FILED-EXAMPLE-motion-brief.pdf`. Provenance is in `usage/SOURCE.md`. The sample is a transcription of it (`usage/INPUT-motion-brief.md`).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (Doc 762, filed 10/23/25, 11 pages, one filer; `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (transcription of pp. 1–9 of the exemplar: caption, numbered factual paragraphs, two tables, footnotes 1–10, memorandum argument, prayer, joinder and signature blocks; Exhibit A not transcribed) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only (Regular, Italic, Bold), no warnings. Command: `sh tools/render.sh … usage/INPUT-motion-brief.md` exit 0 |
| overlay | ok: `usage/OVERLAY-titan-motion.pdf` and `.txt` (page map: ours p.1–4 pair with filed p.1–4, word overlap 74%–89%; ours p.5–8 pair with filed p.5, 7, 8, 9, overlap 44%–65%; filed p.6 is unpaired, the page holding the table sits between them). Command: `sh tools/overlay.sh … titan-motion` exit 0. Re-run 2026-10-15: exit 1, "no exemplar pdf": `usage/FILED-EXAMPLE-motion-brief.pdf` is not in this checkout (git tracks only `usage/SOURCE.md`), so the overlay could not be regenerated; the committed `OVERLAY-titan-motion.txt` is from an earlier run |
| typeface | face required: none. LRBP 9004-1(g) (checked on azb.uscourts.gov, 2026-10-15) says "a proportional font size no smaller than 13 point" and names no face. EB Garamond kept; no vendored substitute needed. The filed exemplar is Times New Roman, but the rule does not require it, so the template is not changed to it |
| pages reviewed | 8 of 8 (every page of the OUTPUT rasterised at 110 dpi and viewed in its final state; re-reviewed 2026-10-15 at 60 dpi, 8 of 8, after the re-render) |

Note on file names: the tools default to `usage/OUTPUT-<id>.pdf` and `usage/OVERLAY-<id>.pdf`/`.txt`, and `overlay.sh` reads `OUTPUT-<id>.pdf`. The sample id changed from `generic-motion` to `titan-motion`, and the fictional `usage/INPUT-generic-motion.md` was replaced by the transcription. The shared tools were not changed.

## Governing rules

Each rule is quoted or closely paraphrased from the cited source. The date is the date it was read.

| ID | Rule | Requirement | Source and date verified | Where it lives |
|---|---|---|---|---|
| ARB-MOT-001 | FRBP 9013(a), (b) | A request for an order must be made by written motion unless an application is authorized or the request is made during a hearing. "A motion must state its grounds with particularity and set forth the relief or order requested." | Cornell LII https://www.law.cornell.edu/rules/frbp/rule_9013 (fetched 2026-10-14). | The opening paragraph and the `relief` line in the caption; the body is author-written |
| ARB-MOT-002 | LRBP 9013-1(a) | "All motions, unless made in open Court, must include a memorandum setting forth the supporting authorities." | Court rule page https://www.azb.uscourts.gov/rule-9013-1 (WebFetch, 2026-10-14). The rule text was given as a summary with this quotation. The exemplar follows it: "MEMORANDUM OF POINTS AND AUTHORITIES" inside the motion (exemplar p.1). | The sample's "Memorandum of Points and Authorities" section; the template does not check its presence |
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

The sample now transcribes a real motion (`usage/INPUT-motion-brief.md`); its authorities are the exemplar's own (*A & C Properties*, *Woodson*, *Schmitt*, *Newman v. Stein*, *Pennsylvania Truck Lines*, *Planned Protective Services*). They are transcribed as filed and were not re-verified here.

Not produced: certificate of service (LRBP 9013-1(k); author-written when needed), notice of hearing (author-written; the exemplar's own notice is a separate filing, Doc 765 in the same case), proposed order (LRBP 9013-1(e)), table of contents and table of authorities (no rule read here requires them; see gap 4), and the attachments that LRBP 9013-1 excludes from the page count (the exemplar's Exhibit A).

## Layout

- Numbered lines 1 to 28 down the left margin on a 24-point grid, with a double rule at the text's left edge and a single rule at its right (LRBP 9004-1(g)).
- Top margin 1 inch; the 28 lines end at 10.33 inches; the footer sits in the bottom margin.
- Filer block single-spaced from line 1 (LRBP 9004-1(a)); the court title is on line 8 (convention).
- Caption: a debtor row (in re, names, Debtor; chapter and case number) and, in an adversary, a parties row (plaintiffs and defendants, adversary number, title, relief, hearing). Without an adversary, one caption row with the title, relief and hearing on the right.
- Headings: level 1 is a centred bold capital section (MEMORANDUM OF POINTS AND AUTHORITIES); levels 2 to 5 are numbered I., A., 1., a. with a hanging label. Level 2 is the section; the number is typed by the template, not by the author.
- Body paragraphs double-spaced with a 0.5-inch first-line indent; paragraphs are not numbered by the template. Lists are numbered 1., 2., ... (or bulleted with `-`).
- Markdown tables are set in their own unbreakable block, single-spaced at 12 point, with thin rules (`typst/arb-motion-brief.typ`, the `"|"` branch of `body-chunks`). The text after a table starts one line below it.
- A heading stays with the paragraph after it. The last body chunk, the signature block and any certificate are kept together, so a signature never stands alone on a page.
- Footnotes: 12 point, single-spaced; each footnote definition is rendered with the paragraph that refers to it. A footnote reference is allowed inside a table cell.
- Footer: page number, the title in capitals, and `ADV. NO.` (adversary) or `CASE NO.` (main case).

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` (level 1, centred bold capitals), `##` to `#####` (numbered headings), a list, a table (`|` rows), a block quote, or a paragraph.
- Frontmatter: `filer` (list of lines, from line 1), `debtor` (`names`, `chapter`, `case_number`), `adversary_number` (optional; if given, `parties` is required), `parties` (list of `{names, designation}`), `title`, `relief`, `hearing` (optional `{date, time, place}`), `footer_title`, `date`, `signature` (`signer`, `lines`).
- Do not type numbers into headings or the text: the template numbers headings from their level and lists from 1. A paragraph that the filer numbered in the text (for example "1. David A. Birdsell …") is written with the number escaped (`1\.`) so it stays a paragraph, as filed.
- Footnotes: `text[^key]` in the paragraph (or a table cell) and `[^key]: text` anywhere in the body.

## Known gaps and open choices

1. **One exemplar, one filer.** The bar for tier 2 is two or three filed exemplars from different filers. Only one motion was found (the Titan trustees' Doc 762, from Nach, Rodgers, Hilkert & Santilli and its co-trustee counsel). A motion from another Arizona filer is still open. Tier 2 is judged here against this one filing.
2. **Font size.** The rule names no typeface, so EB Garamond is kept (see the typeface row above). The filed exemplar is Times New Roman. EB Garamond sets smaller at the same size. The 13-point minimum is met; the apparent size is smaller than the exemplar's.
3. **Exhibit A not transcribed.** The exemplar's pp. 10–11 are the allocation table (Exhibit A, 23 rows). The sample transcribes the body, including the two summary tables (Shared Assets, Shared Costs), and stops at the signature page. The overlay therefore shows the exemplar's pp. 10–11 with no match.
4. **No table of contents or table of authorities.** The rules read here do not require them for a motion in this court. A longer memorandum may need them by the judge's practice; the template does not generate them.
5. **Notice of hearing and certificate of service are not generated.** LRBP 9013-1(k) (summarised from the court's rule page, not quoted) requires notice of the hearing and a certificate or affidavit of service; the author writes them in the body.
6. **Page limit counts the whole document.** The 15-page limit excludes attachments, which the template does not separate. A motion that carries attachments in the same PDF would be counted with them. Attachments belong in separate filings.
7. **Keep-with-next gaps.** Headings and a last body block are kept together, and a table is unbreakable, so a page can end several lines early. In the exemplar transcription, page 3 ends about five lines early because the Shared Assets table moves to page 4. This is the cost of never leaving a heading or a table split from its label. Not fixed.
8. **Footer size and wrap.** 11 point, as in the complaint. The 13-point minimum is written for text; the footer is identification (convention, flagged). A title longer than the left footer column wraps (the `footer_title` in the sample was shortened to "Trustee's stipulated motion" for this reason).
9. **Bulleted lists are set as numbers.** The filed estate lists use bullets; the template numbers `-` items 1., 2., and so on. Content is faithful; the glyph is not.
10. **Block quote spacing.** The Rule 9019(a) quotation is set as a block quote with extra space above and below, not on the numbered-line grid. Not fixed.
11. **Signature order.** The template prints one signature block at the end (`Dated`, `Respectfully submitted`, the signer). The exemplar has joinder signatures from three other trustees' counsel before the lead counsel's. The sample keeps the joinders in the body and the lead counsel in the template block, so the lead counsel's signature comes last. Not fixed.
12. **Dual caption layout.** Closed by a rule on the right and bottom of the party column, not a column of ")" marks. Form 416A's exact layout is not part of this doc type's rules.
13. **FRBP 7012(b) and 9015 are cited from memory** in the fictional sample of earlier versions; the transcription does not cite them. The template does not cite them.
14. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root, and this doc-type folder has neither. The brief forbids touching `tools/`. The render, the overlay, the page review and the page-limit mutation test below stand in for them.

## Render and review record

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env, see the brief)
sh tools/render.sh courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/arizona/federal/bankruptcy-district/motion-brief titan-motion
```

- Render: exit 0, no typst warnings, 8 pages (letter). Fonts embedded: EBGaramond-Regular, -Italic, -Bold.
- Overlay: exit 0; `usage/OVERLAY-titan-motion.pdf`. Pairing by word overlap, from `OVERLAY-titan-motion.txt`: sample pp. 1–4 to filed pp. 1–4 (74–89%); sample pp. 5–8 to filed pp. 5, 7, 8, 9 (44–65%). The lower overlap from p.5 is the pagination difference, not a missing passage: the sample reaches the signature page one page before the filing does.
- Page-limit mutation test (from the earlier fictional-sample review, template unchanged in this respect): a temporary 27-page sample fails the build with "27 pages; LRBP 9013-1(b) allows 15". The 8-page sample passes.
- Page review (110 dpi, all 8 pages, final state):
  - p.1 filer block, court title, caption with the relief line, opening paragraph, memorandum heading, "I. Factual Background", paragraph 1 with its list to follow: pass.
  - p.2 estate lists for the Birdsell, Reaves and Mason estates, and paragraph 4: pass (bullets are numbered; gap 9).
  - p.3 paragraphs 5–11; the Shared Assets table moves to p.4, leaving about five lines blank (gap 7): pass with gap.
  - p.4 Shared Assets table, Shared Costs table (19 rows, total $211,738.14), paragraph 13, footnotes 2 and 3: pass. The footnote 2 reference is inside a table cell.
  - p.5 Settlement Proposal (II), paragraph 14 with items a and i–iv, footnotes 4–7: pass.
  - p.6 item v and items b and c, footnotes 8–10: pass.
  - p.7 Legal Argument (III), Rule 9019(a) block quote (gap 10), the four-factor test, the Newman citation: pass.
  - p.8 the balance of the argument, WHEREFORE list A–C, RESPECTFULLY SUBMITTED, joinder blocks, and the template's Dated/Respectfully-submitted block: pass.
- Table rendering was a defect before this pass: the template placed a table in the on-grid paragraph path, and the table overlapped the following text ("TOTAL" row over paragraph 12). Fixed by the unbreakable table block described under Layout.

## Engines

DOCX (`docx/`: `build-reference.sh` makes `reference.docx`; `arb-motion.lua` builds the filer block, the caption (one caption in the main case, a dual caption in an adversary), the headings with their labels, lists and tables; `render.sh` runs pandoc with `-fancy_lists` (the sample's `a.` and `i.` labels stay as typed text, as in typst) and fills the footer). Rendered: `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf` (LibreOffice 26.2 conversion, 9 pages). `pdffonts`: EB Garamond Regular, Bold and Italic only.

Matches the typst form (every page of the `.docx.pdf` rendered at 60 dpi and viewed: pages 1 to 9 of 9):
- Letter paper; margins and the 28 pleading lines as in `arb-motion.typ`, with the numbers in one header text box and the rules from `pgBorders`.
- EB Garamond 13 pt, 24 pt line pitch. Filer block on lines 1 to 7, court title on line 8, caption with the rules, the title and relief beside the case number.
- Headings: level 1 centred capitals at 18 pt; level 2 with the label hung at the margin ("I.") at 15.5 pt; level 3 with the label at 0.5 in ("A.").
- Lists keep the sample's labels (bullets; `a.`, `i.`, `1.`) with hanging indents. Markdown tables have a full grid at 12 pt, their columns sized to their content, so figures do not wrap.
- Footnotes 12 pt single. Footer: page number, the title in capitals, `CASE NO.` and the number. The last body paragraph is kept with the signature block.

Differs from the typst form:
- Pagination: 9 pages here against 8 in typst (the extra page is the prayer and joinder, which the renderer lays out with the signature on page 9).
- Block quotations: the spacing above and below is approximate (typst's quote is set on its own lines with a different leading).
- The table column widths come from a per-character model measured on the typst render; a font metric that differs in Word can still wrap a figure.
- Not opened in Word (no Word here). The header text box and page borders are verified in LibreOffice only.

BLOCKED: none. The tier-2 items are the ones above; the exemplar is a single filer (see `usage/SOURCE.md`).

`tools/check.sh` cannot run on this folder: it needs `court.json` and `checks.yaml` at the court root, and neither is in the doc-type folder. The render and page review above stand in for it.
