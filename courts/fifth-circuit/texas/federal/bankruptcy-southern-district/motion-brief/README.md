# txsb: motion-brief

Doc type: **motion with integrated memorandum** (a motion that argues its own grounds; there is no separate memorandum in the exemplar) in the United States Bankruptcy Court for the Southern District of Texas (`txsb`).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the complete numbered text of the motion (¶¶ 1 to 42, all sections, the WHEREFORE clause), the caption, the emergency notice, the signature blocks and the certificate of service. Exemplar footnotes 2 to 4 are not transcribed; the proposed order (Exhibit A) is not saved. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, typst 0.15.0, pinned Times New Roman only (`pdffonts`; EB Garamond before fb-595.68), no warnings, exit 0 |
| overlay | **not regenerated (fail)**: `tools/overlay.sh` exits 1 because `usage/` holds only `SOURCE.md` in this snapshot (the filed PDF is not in the tree or in git). `usage/OVERLAY-cmg-funding.txt` is the page map from the earlier run; no `OVERLAY-cmg-funding.pdf` is present. |
| pages reviewed | 12 of 12 (fonts pass, 2026-10-14: every page of the then EB Garamond render viewed at 60 dpi, before fb-595.68) |

## Governing rules

Verified 2026-10-14. Sources as in the adversary-complaint README (the same court rules and the same LR10); the motion-specific rules are below.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 9004(a), (b) ([Cornell, eff. Dec. 1, 2024](https://www.law.cornell.edu/rules/frbp/rule_9004)) | Legible; a caption with the court, case title, case and adversary numbers, and a brief designation of the document. | `cover`: court name, `case_number`, `adversary_number`, `title`. |
| FRBP 9013 ([Cornell, eff. Dec. 1, 2024](https://www.law.cornell.edu/rules/frbp/rule_9013)) | A request for an order must be made by written motion; a motion must state its grounds with particularity and set forth the relief requested. | The body: numbered paragraphs (relief in ¶ 21, grounds in ¶¶ 22 to 42, WHEREFORE). Author content; the template does not check the grounds. |
| BLR 7007-1 ([Bankruptcy Local Rules, eff. March 3, 2026](https://www.txs.uscourts.gov/sites/txs/files/Local_Rules_March_3_2026.pdf)) | Motion practice in adversary proceedings is governed by BLR 9013-1. | Why BLR 9013-1 applies to this adversary motion. |
| BLR 9013-1(a) (same) | The pleading's title identifies the filer and describes the pleading. | `title` (author content). |
| BLR 9013-1(b) (same) | Each pleading seeking an order must include, immediately below the title, the notice text in the rule (verbatim). | `notice-block()`: the rule's text, verbatim, immediately below the title. |
| BLR 9013-1(c) (same) | If self-calendared, a hearing line at the end of the notice. | `notice-block()`: optional `hearing` (date, time, courtroom, address). The exemplar's hearing and conference-room instructions are not transcribed. |
| BLR 9013-1(f) (same) | The serving party files a certificate of service that includes the name and address of those served. | `certificate()`: ECF-service wording with the date and signer from the sample. It does not list those served (see Known gaps). |
| BLR 9013-1(h) (same) | Each motion must be accompanied by a proposed order. | Not produced (see Known gaps). |
| BLR 9013-1(i) (same) | An emergency motion has "Emergency" in its title; it includes a detailed statement why an emergency exists and the date relief is needed, is certified for its accuracy by the movant or counsel, and includes the emergency paragraph. | `title` (author content: "Emergency Motion ..."); `relief_by` (the date line) and the emergency paragraph (verbatim) in `notice-block()`. The certification is not printed (see Known gaps). |
| BLR 7008-1 (same) | A statement of consent to final orders, if the proceeding is core. | Author content in the body (¶ 7 says the proceeding is core; the consent statement is not in the exemplar's motion). |
| LR10.1, LR10.2 (district rules, via BLR 1001-1(b)) | Caption with the filer's designation; 8½ × 11 paper; double spaced; paginated. | As in the adversary-complaint README. |

The notice text (BLR 9013-1(b) and (i)) is fixed in the template as the rule states it. The exemplar's own notice reads differently (it adds "Relief is requested not later than ..."; the judge's hearing and video instructions are in the exemplar only), so the overlay will show the notice text differing from the filed exemplar.

## Layout

As the adversary-complaint template: US Letter, 1 inch margins (a convention), Times New Roman 12 pt (the house standard, `docs/FONTS.md` rule 6, and the exemplar's face; no typeface is set by the rules; EB Garamond before fb-595.68), double spacing. Typeface row (fonts pass, 2026-10-14): face required = none (the Bankruptcy Local Rules and the LR Sept. 2025 reprint were extracted with `pdftotext` and searched for font, typeface, type size and margin: none) → vendored substitute = EB Garamond (kept then; now Times New Roman, `docs/FONTS.md` rule 6) → fit = n/a (24 pt pitch), page numbers in the footer, numbered paragraphs (0.5 inch first-line indent), level 1 headings centered bold (Roman numerals written in the sample), level 3 headings bold left (A., B., ...), and the same caption. Additional blocks:

- Notice: BLR 9013-1(b) text, single spaced, directly below the caption and title. For an emergency motion, the BLR 9013-1(i) paragraph follows, after the `relief_by` line.
- Unnumbered WHEREFORE paragraph (markdown `> `).
- Certificate of service: a block with its own heading, kept together, below the signature block, with the signer's name and `/s/` line at the right.

## Markdown contract (for samples)

- Frontmatter: as the adversary-complaint sample, plus `emergency` (true for an emergency motion), `relief_by` (required with `emergency`), optional `hearing` (`date`, `time`, `courtroom`, `address`), and `certificate` (`date`, `signature` as a list of lines).
- Body: as the adversary-complaint contract, including `> ` for an unnumbered paragraph. Lists are `1.` items (lettered (a), (b), ...). Do not number the paragraphs in the sample.
- Not supported: body footnotes (only the caption footnote), tables, raw typst.

## Known gaps and open choices

1. **Proposed order (BLR 9013-1(h)) is not produced.** The exemplar's Exhibit A is a separate proposed order; this template does not produce one.
2. **Emergency certification (BLR 9013-1(i)).** The rule requires the emergency motion to be certified for accuracy by the movant or counsel. The template does not print a certification; the sample's preliminary statement (¶¶ 1 to 5) states the emergency, but the certification is not in the exemplar's motion and is not in the render.
3. **Certificate of service (BLR 9013-1(f)).** The rule requires the certificate to include the name and address of those served. The exemplar's certificate is ECF-service wording only, with no list. The template follows the exemplar. Whether ECF notice satisfies (f) is a question for David; the template does not supply a list of those served.
4. **Judge's procedures.** The exemplar's notice refers to Judge Perez's hearing procedures (video and dial-in), which are a judge's individual procedure (BLR 1001-1(c)(4)). The template does not reflect any judge's procedures.
5. **Responses and conference certificates.** BLR 9013-1(g)(1) (certificate of conference) applies to responses, not to motions; this template does not produce responses.
6. **Footnotes.** Body footnotes are not supported. The exemplar's footnotes 2 to 4 (defined terms and the declaration reference) are omitted from the sample.
7. **Only one exemplar.** The brief asks for one filed document per doc type; tier 2 is not judged against two or three filers.
8. **Overlay.** Red = our render, blue = the matched exemplar page, black = both. The page map (`OVERLAY-cmg-funding.txt`) pairs our pages with the exemplar by word overlap, not by number. The ECF header of the filed PDF is not reproduced (it is applied by the electronic filing system). The overlay is a diagnostic, not a score.

## Review of the rendered pages (12 pages of the earlier EB Garamond render, before fb-595.68)

- Page 1: court name and division; caption (debtor, plaintiff, defendant, chapter, case number, adversary number); title; the BLR 9013-1(b) notice; the emergency paragraph; the lead-in; footnote 1 (debtor). No spill. Pass.
- Page 2: ¶¶ 1 to 4; I. PRELIMINARY STATEMENT. Pass.
- Page 3: ¶¶ 5 to 12; II. JURISDICTION; III. FACTUAL BACKGROUND and A. General Background. Pass.
- Page 4: ¶¶ 13 to 17; the loan-document list (a) to (e) is line-aligned and follows ¶ 14. Pass.
- Page 5: ¶¶ 18 to 23; IV. RELIEF REQUESTED; V. ARGUMENT. Pass.
- Page 6: ¶¶ 24 to 26; A. There Is A Substantial Likelihood CMG Will Prevail On The Merits. Pass.
- Page 7: ¶¶ 27 to 30; B. If The Motion Is Not Granted, CMG Will Suffer Irreparable Harm. Pass.
- Page 8: ¶¶ 31 to 33; C. The Threatened Injury To CMG Outweighs The Threatened Harm To The Debtor. Pass.
- Page 9: ¶¶ 34 to 38; D. Granting The Preliminary Injunction Will Benefit Public Interest. Pass.
- Page 10: ¶¶ 39 to 42; E. (the bond heading, two lines, kept with ¶ 40); VI. NO PRIOR REQUEST; VII. NOTICE; VIII. CONCLUSION; the start of the WHEREFORE clause. Pass.
- Page 11: the rest of the WHEREFORE clause; Dated; Respectfully submitted; three signing blocks, separated by `-and-`. Pass.
- Page 12: CERTIFICATE OF SERVICE with the ECF wording and the signer. Pass.
- Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

docx (`docx/`): `reference.xml` (`base="xengine"`: `fb render --engine docx` builds the reference document from it, the shared cross-engine recipe in the typst template's face); `motion.lua` builds the caption with its rules, the BLR 9013-1 notices, numbered paragraphs, lettered lists, the signature block and the certificate of service from the sample; `sh tools/render.sh --engine docx <dir> usage/INPUT-motion-brief.md` (a wrapper of `fb render --engine docx`) runs pandoc with it. Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice, 12 pages; typst is 12 pages).

- Matches the typst form: Times New Roman 12 pt; body double spaced as an exact 24 pt line; 1 in margins, letter; 0.5 in first-line indent; numbered paragraphs; headings (centered bold for levels 1 and 2, bold left for level 3); the two-column caption with the right and bottom rules and the case numbers at right; the BLR 9013-1(b) and (i) notice text, verbatim; the emergency and hearing lines when the sample has them; the certificate of service; centered page number; the debtor footnote at 10 pt in 11.5 pt lines; single-spaced lines at the typst pitch (13.8 pt); signature block kept whole.
- Differs, and why: the paragraph numbers are typed with a tab, not Word auto-numbering (the numbers are the sample's own); the caption rules are cell borders written by the filter (`docx/render.sh` added them before fb-595.68), because pandoc cannot write cell borders and LibreOffice does not draw paragraph borders in a table cell; LibreOffice places exact-line text about 3 pt lower than typst, so a page can hold one line less and a break can fall differently (page counts match on this sample, 12 and 12).
- Opened and converted with LibreOffice only; Word was not checked.
- BLOCKED: none.
