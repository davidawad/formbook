# gub: adversary complaint

Doc type: **adversary complaint** (Fed. R. Bankr. P. 7001: commencement of an adversary proceeding) in the United States Bankruptcy Court, District of Guam, Bankruptcy Division (`gub`).
Folder: `courts/ninth-circuit/guam/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the complaint's body as filed (paragraphs 1 to 19, the prayer, the signing line), with the counsel block, caption and signature; exhibits not transcribed (see Known gaps) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 4 pages, typst 0.15.0, vendored Times New Roman only, no warnings (fb-595.68.22) |
| typeface | face required: none (GNLR 5.1 and the Bankr. L.R. text, read 2026-10-15, name no face or point size) → **Times New Roman** 12 pt, vendored, the house standard (`data/exemplar-fonts.json` template_face) and the exemplar's face, in typst and docx alike (fb-595.68.22) |
| overlay | ok: `usage/OVERLAY-archbishop-agana-complaint.pdf` and `.txt` (pages 1 to 4 each paired with filed pages 1 to 4; recorded on the earlier EB Garamond render, before fb-595.68.22); the filed exemplar was re-fetched from the RECAP URL in `usage/SOURCE.md` and matches its SHA-256; the PDF is kept outside the repo, since no court tracks exemplar PDFs in git |
| pages reviewed | 4 of 4 of the EB Garamond render (re-rendered 2026-10-15 and every page rasterised at 60 dpi and viewed); the Times New Roman render (4 pages) is not re-reviewed page by page (fb-595.68.22) |

Section 9 of the brief asks for a target of 8 to 14 pages. The filed complaint's body is 4 pages (the ECF pages 1 to 4 of 23); the other 19 pages are Exhibit A and the Statement's Exhibits 8 to 10, which are property tables. The template renders the body at the exemplar's length. Nothing was padded to reach 8 pages.

## Governing rules

| ID | Rule | Requirement | Where it lives in the template | Verified |
|---|---|---|---|---|
| GUB-CMP-001 | Gen. L.R. (D. Guam) 5.1(a) | White 8½ × 11 paper; "All pages shall be numbered consecutively at the bottom"; typewritten, one side; "All papers shall be double-spaced except for the identification of counsel, title of the case, footnotes, quotations, and exhibits." | `page-w`, `page-h`, `line-numbers()`, `footer-block` (page number), `pitch = 24pt` | Text read from the District of Guam General Local Rules, "as of 2021-11-29" PDF (`https://www.gud.uscourts.gov/sites/gud/files/General%20Local%20Rules%20as%20of%2020211129%20final%20%281%29.pdf`), fetched 2026-10-14. The current revision was not checked (see Known gaps). |
| GUB-CMP-002 | Gen. L.R. 5.1(b) | "The title of the Court shall be centered and commence not less than three inches from the top of the page." | `counsel-lines = 8`: the court title starts on line 9 (3.67 in from the top); `counsel-block` asserts the counsel block ends above it. | same |
| GUB-CMP-003 | Gen. L.R. 5.1(c)(1) | Counsel's name, address, telephone in the upper left-hand corner; "the space to the right of the page's center shall be reserved for the clerk's filing stamp." | `counsel-block` (left column only); the top right of the cover is left empty. | same |
| GUB-CMP-004 | Gen. L.R. 5.1(c)(2) | Title of the action below and to the left of the title of the Court; "the title of the proceeding shall contain the names of all parties." | `caption` (left column, "In re:" debtor and the plaintiff and defendant). | same |
| GUB-CMP-005 | Gen. L.R. 5.1(c)(3)(A)–(C) | To the right of the title of the action: the file number, a designation as "bankruptcy" or "adversary", and a brief description of the document. | `case-info`: "Chapter 11 Bankruptcy", "Case No.", "Adversary Proceeding", "Adv. Proc. No.", and the bold title. | same |
| GUB-CMP-006 | Gen. L.R. 5.1(c)(4) | "All documents initiating ... adversary proceedings shall be accompanied by the appropriate cover sheet." | Not generated: a separate filing (see Known gaps). | same |
| GUB-CMP-007 | Gen. L.R. 5.1(d) | "Names shall be typed below signatures." | `signature-block`: "/s/" line, then the typed name. | same |
| GUB-CMP-008 | Fed. R. Bankr. P. 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." Civil Rule 10(b): numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Caption layout; numbered paragraphs (`allegations()`); headings and the prayer are unnumbered. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_7010`, fetched 2026-10-14. |
| GUB-CMP-009 | Fed. R. Bankr. P. 7008(a) | "In an adversary proceeding before a bankruptcy court, a complaint ... must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | The template fails the build (an `assert`) unless the body contains "consent to the entry of final orders". The sample holds a marked placeholder, because the filed complaint states no position. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_7008`, fetched 2026-10-14. |
| GUB-CMP-010 | Fed. R. Bankr. P. 9004(b) | A document's caption "must contain": the court's name, the case's title, the case number and adversary-proceeding number, and "a brief designation of the document's character." | `caption`, `case-info`. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_9004`, fetched 2026-10-14. |
| GUB-CMP-011 | Fed. R. Bankr. P. 9011(a) | "Each document must state the signer's address and telephone number, if any." Attorney signs in the attorney's individual name. | Counsel block (address and telephone) and the signature block. The e-mail address is a convention, not a rule requirement. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_9011`, fetched 2026-10-14. |
| GUB-CMP-012 | Bankr. L.R. 7001-1 | In adversary proceedings, the Bankruptcy and Civil Rules apply, together with the District Court's General and Civil Local Rules, unless the court orders otherwise. | Basis for applying GUB-CMP-001 to 005 to the complaint. | Read through a courtrules.net search excerpt (`https://www.courtrules.net/courts/federal/bankruptcy-district-guam/local-rules/3164`); the direct fetch returned HTTP 403. The official text was not read in full. |

Not in the template, on purpose: the civil/adversary cover sheet (GUB-CMP-006), the summons (Official Form 416B), and the Certificate of Interested Entities (if any applies). Any of these may be required with the first filing.

Official Form 416A (the full caption for a complaint) was not read: `uscourts.gov` returned an HTML page instead of the PDF. The caption layout follows the exemplar and Rule 9004(b). This must be checked against the form before the template is treated as final.

## Layout

- Numbered lines 1 to 27 down the left margin (the exemplar has 28; 27 are what fit between 1 in margins), a double rule at the text's left edge and a single rule at the right (the pleading form). This is the exemplar's convention; GNLR 5.1 does not mention line numbers.
- Counsel block single-spaced in lines 1 to 8, court title on line 9 ("IN THE DISTRICT COURT OF GUAM / TERRITORY OF GUAM / BANKRUPTCY DIVISION"), caption on lines 13 to 18.
- Paragraphs numbered 1, 2, ... by the template; a paragraph beginning `§ ` in the sample is unnumbered (the consent sentence, WHEREFORE, the signing line). Headings and the prayer list stay with the paragraph that follows.
- Prayer items (markdown list) are lettered (a), (b), ...

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#` is a centred bold section, `##` a centred bold sub-heading, a `1.` list is lettered, any other chunk is a numbered paragraph unless it starts with `§ `.
- Frontmatter: `counsel` (lines), `case_number`, `adversary_number`, `chapter`, `caption` (`debtor` with `names` and `designation`; `parties` with `names` and `designation`; "v." is inserted between the parties), `brief_title`, `footer_title`, `lead_in` (optional, unnumbered), `signature` (`firm`, `signer`, `lines`).
- Quote a YAML value that contains `#` (it starts a comment otherwise), e.g. `"Robert T. Kugler (MN #0194116)"`.
- Not supported: tables, exhibits, footnotes (none needed here), raw typst.

## Known gaps and open choices

1. **Consent to final orders (GUB-CMP-009) is a placeholder.** The filed complaint does not say whether the Committee consents. The template refuses to build without the sentence, and the sample carries a bracketed placeholder that counsel must replace. This is a question only the filer can answer; it is recorded here, not guessed.
2. **Exhibits are not transcribed.** Exhibit A and the Statement's Exhibits 8, 9 and 10 (about 19 pages of property tables) are not in the sample; the template has no exhibit slip-sheets or table support. The sample ends at the signing line, as the body does.
3. **Cover sheet and summons (GUB-CMP-006)** are separate filings and not generated.
4. **Pleading line numbers.** GNLR 5.1 does not require them; they follow the exemplar, which is one filer's practice. A second filer's complaint would show whether the court expects them. Not judged.
5. **Font.** Times New Roman 12 pt (vendored), in typst and docx (fb-595.68.22; was EB Garamond). No rule read names a typeface (GNLR 5.1; Bankr. L.R. text checked 2026-10-15); `data/exemplar-fonts.json` records template_face Times New Roman under the house-standard ruling. The exemplar is Times 12 pt.
6. **Exemplar count.** Only one filer's complaint was found on the RECAP copy of the gub docket (see `usage/SOURCE.md`). Tier 2 is not judged against a second filer.
7. **Footer.** Page number and the paper's title in 10 pt. GNLR 5.1(a) asks only for the page number; the title is a convention.
8. **Adversary number.** Printed on the first page under "Adv. Proc. No." (the exemplar leaves it blank, since the complaint is the first filing). The number comes from the ECF header of the exemplar, `Case 19-00001`.
9. **Court name.** The complaint's caption reads "IN THE DISTRICT COURT OF GUAM, TERRITORY OF GUAM, BANKRUPTCY DIVISION"; the motion's reads "UNITED STATES DISTRICT COURT, DISTRICT COURT OF GUAM". The court's own form GUB 9073-1 reads "District Court of Guam, Bankruptcy Division". The complaint template follows the complaint exemplar.
10. **Local rule version.** GNLR 5.1 was read from the 2021-11-29 version. Newer versions of the District's General Local Rules exist (a 2022 revision is listed on the court's site); the current text was not confirmed.
11. **Local counsel and admission.** Counsel is from Minnesota. Whether Guam admission or local counsel is required is outside this template and was not checked.
12. **Overlay pairing.** The sample is the whole body, so the overlay pairs most pages with the same-numbered filed page. It is a diagnostic, not a score.
13. **File names.** The brief names overlay files `<id>-overlay.pdf` and `.txt`; `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt` and reads `OUTPUT-<id>.pdf`. The repo tools were not edited, so the tool's names are used.

## Visual review (Gate 2 record, all 4 pages of the EB Garamond render, rendered at 60 dpi and looked at; before fb-595.68.22)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel block, court title on line 9, caption with the adversary designation and the title at right | OK. Counsel bar numbers in full after the YAML fix (a `#` had been taken as a comment). No spill. |
| 2 | Lead-in, paragraphs 1 to 8 with the parties, jurisdiction and the unnumbered consent placeholder | OK. The placeholder is unnumbered, so paragraph numbers match the exemplar (the cross-reference "paragraphs 1 through 14" is correct). |
| 3 | Paragraphs 9 to 19, cause of action heading, WHEREFORE | OK. The WHEREFORE line moved to page 4 with its list (keep-with-next). |
| 4 | WHEREFORE, the prayer (a), (b), signing line, signature block | OK. Signature block at right, "/s/" line and typed name below. |

Pages reviewed: 4 of 4.

## Engines

### docx (fb-595.68.22, checked with LibreOffice)

Files: `docx/reference.xml` (the cross-engine style recipe, `base="xengine"`, in the typst face; built by `fb render`) and `docx/gub-adversary-complaint.lua`. `docx/make-reference.sh` and `docx/reference.docx` are gone. Sample output: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (4 pages, as typst).

Both engines are on the shared cross-engine layout model and set Times New Roman 12 pt:
- The pleading page: line numbers 1 to 27 on the 24 pt grid (GNLR 5.1(a) double spacing), the double and single rules, the page number and the paper's title; in docx a footer of page-anchored frames written by the filter (`FORMBOOK_FOOTERS`, `FORMBOOK_FINAL`), replacing Word's line numbering that counted text lines.
- Single-spaced cover and signature lines in 12 pt boxes dropped 9.6 pt into a numbered line, so they sit on the numbers' baselines and halfway; the counsel block a fixed eight numbered lines (GNLR 5.1(b)).
- The caption one table with the party column's rule as tall as the row; paragraph numbers in a half-inch box after the indent; lettered prayer items (a), (b) half an inch in; `§` lead-ins unnumbered and kept with the next block; the last block kept with the signature.

Checks: `sh tools/check.sh <this folder> --engine docx`: `RESULT: 13 checks passed, 0 failed`; Gate 4 XENG-001..003 pass (4 pages, 128/128 lines break after the same word as typst; `eval.yaml` `params.cross_engine: gate`). typst: `RESULT: 9 checks passed, 0 failed`. DEF-TOC-001 and DEF-COVER-001 pass on both. The earlier docx BLOCKED items (no LibreOffice, Word line numbering, the computed court-title spacer, the missing footer title) are resolved by this port.
