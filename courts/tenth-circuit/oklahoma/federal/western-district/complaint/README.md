# okwd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Oklahoma (`okwd`).
Folder: `courts/tenth-circuit/oklahoma/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, plaintiff's counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole complaint, all 109 paragraphs, caption, headings, prayer, jury demand, signature |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 17 pages (the docx render too), typst 0.15.0, Times New Roman only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-caskey-complaint.pdf` and `OVERLAY-caskey-complaint.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 17 of 17, typst and docx (every page rendered at 40 to 50 dpi and viewed after the last template change; fb-595.68.33) |

File names follow the house convention that `tools/render.sh` and `tools/overlay.sh` read and write: the
brief's `usage/<id>.md` is `usage/INPUT-<id>.md`, its `<id>.pdf` is `OUTPUT-<id>.pdf`, and its
`<id>-overlay.pdf` / `.txt` are `OVERLAY-<id>.pdf` / `.txt`.

## Governing rules

Primary sources. Local rules: the W.D. Okla. Local Civil Rules as posted at
https://okwd.uscourts.gov/local-rules (current edition: `LocalRules2026.pdf`, effective April 2026, read by text
extraction on 2026-10-14; the court posts a red-lined set of 2026 proposed amendments with no effective date, which
this template does not reflect). Federal rules: Fed. R. Civ. P. 8, 10 and 12 from https://www.law.cornell.edu/rules/frcp/ , fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR7.1(d) | Print style, footnotes included, not less than **13-point**; margins at least one inch top, bottom and sides. | `type-size = 13pt`; `margin = 1in`. The footer page number is also 13 pt. |
| LCvR5.2(a) | Papers double-spaced if typewritten; 8 1/2 by 11 inch paper; one side. | `pitch-body = 29.9pt`, exact line boxes of two single lines of Times New Roman at 13 pt (the motion exemplar measures the same 29.9 pt); checked as OKWD-FORM-001 in `eval.yaml` (every pair of body lines at least 26 pt apart); `page-w`, `page-h`. |
| LCvR5.4 | "All papers shall contain the name, mailing address, daytime telephone number, fax number, and e-mail address" of the attorney. | `signature.lines` in the sample frontmatter (the block sits at the end of the complaint, as in both filed W.D. Okla. papers in the exemplar set). |
| LCvR3.1 | Counsel and pro se litigants number each party separately in the caption: plaintiffs consecutively, defendants consecutively. | `caption.parties[].names` carries the "1." numbers as filed; the template prints the names as given. |
| LCvR3.1 | A completed civil cover sheet (JS-44) must accompany the complaint. | Not produced (separate form; see known gaps). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | Court title lines, `caption`, `case_number` ("Case No." blank for a new filing), `brief_title`. Verified text: law.cornell.edu/rules/frcp/rule_10. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph 1, 2, ...; headings and lists are not numbered; the `unnumbered` frontmatter list keeps the prayer and jury demand unnumbered as filed. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Content only: the template does not check the wording. |
| Fed. R. Civ. P. 11(a) | Every pleading signed by at least one attorney of record, with name, address, e-mail and telephone. | `signature.sign` ("/s/ name") and `signature.lines`. |

## Layout

- Plain double-spaced pages, no pleading line numbers: W.D. Okla. filings do not use numbered pleading paper (both exemplars have none). This is the main difference from the N.D. Cal. complaint template in `courts/ninth-circuit/california/federal/northern-district/complaint/`, which uses numbered lines and 12 pt type.
- Court title on lines of its own, bold; the caption is single-spaced (14.95 pt lines): party names, each designation indented 0.5 in, a ")" column (one ")" per caption line; each caption line is one line, the names being short) and the case number at the right. `JURY TRIAL DEMANDED` appears at the right of the caption when `jury_demand: true`.
- Title of the paper bold and centered below the caption.
- Body double spaced in exact 29.9 pt line boxes (`pitch-body`; single lines 14.95 pt) on the shared cross-engine layout model (`lib/typst/xengine.typ`), with no extra space between paragraphs (as both exemplars). Numbered paragraphs (Rule 10(b)): the number in a 0.5 in box after the 0.5 in indent, the text from 1 in, the lines after the first at the margin. Headings bold, single-spaced at 13 pt with a blank single line above, centered (level 1 in capitals; they were set at typst's larger heading sizes before). Prayer items lettered A., B., ... (markdown numbered items) at the 0.5 in indent, the text hanging at 1 in.
- Signature block single-spaced from 3.4 in (the date, when given, at the margin beside "Respectfully submitted,"), with "Respectfully submitted," and the `/s/` line, kept together and with the last paragraph (so the signature never stands alone on a page).
- Footer: centered page number on every page. The clerk's ECF header ("Case 5:26-cv-... Document 1 Filed ... Page x of y") is applied by the court, not by the filer, and is not produced here.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1, centered bold caps), a `##` heading (level 2, centered bold), a list (`1.` items, lettered A., B. by the template), or a paragraph (numbered by the template unless under an `unnumbered` level-1 heading).
- Frontmatter fields: `case_number` (empty string for a new filing: the caption shows "Case No. ____"), `caption.parties` (list of `{names, designation}`; `names` is plain text, lines not run through markdown, so "1." numbering is not read as a list), `brief_title`, `lead_in` (unnumbered opening paragraph), `jury_demand`, `unnumbered` (list of level-1 heading texts after which paragraphs are not numbered), `date` (optional), `signature` (`firm` list before the signer, optional; `sign` the "/s/" line; `lines` the rest of the block).
- Not supported: tables, footnotes, raw typst, forced line breaks in the body.
- The sample must not put the numbering in the text: the template numbers the paragraphs.

## Known gaps and open choices

1. **Font.** Face required by the court's rules: **none named**. LCvR7.1(d) (read in `LocalRules2026.pdf`, text extraction on 2026-10-15) requires "print style ... not less than 13-point type" and nothing about a face; LCvR5.2(a) requires double spacing and 8 1/2 by 11 paper. Template font: **Times New Roman** 13 pt, the house standard (`docs/FONTS.md`; `data/exemplar-fonts.json` records `template_face: Times New Roman` over the audited face), in typst and docx alike (fb-595.68.33; was EB Garamond, then TeX Gyre Schola in typst). The exemplar is set in Century Schoolbook (measured body text height about 15.6 pt by `pdftotext -bbox`, consistent with 13 pt): one filer's style (tier 3), not the court's. Line breaks therefore differ from the exemplar's.
2. **Exemplar count.** One exemplar, one filer (plaintiff's counsel). EVAL-LOOP tier 2 asks for two or three filers. The search (CourtListener RECAP, `court=okwd`, complaints filed 2026-09 to 2026-10, `available_only`) found other W.D. Okla. complaints that are in RECAP (for example Griffin v. OU Medicine Inc., 5:26-cv-02815, 24 pages; Doe v. Independent School District No. 20 of Caddo County, 5:26-cv-02438, 28 pages), but these were not downloaded or checked for layout. Tier 2 is therefore **not** judged against two or three filers.
3. **Length.** The complaint is 19 pages as filed and the sample transcribes all of it; the render is 17 pages. The brief's target of 8 to 14 pages applies to exemplars of that length; this one is longer, and the transcription is complete rather than partial so the paragraph numbers match the filing.
4. **Case number.** The exemplar's caption is blank ("Case No. ____") because it is the initial filing. A later-filed paper would carry the number and judge's suffix (for example "CIV-2026-2422-R" in the exemplar for the motion); the template prints the value given.
5. **Civil cover sheet and related papers.** The JS-44 civil cover sheet (LCvR3.1), any Rule 7.1 disclosure statement and the summons are separate filings and are not produced. The exemplar's ECF attachments list a Civil Cover Sheet, which is not reproduced.
6. **Caption layout.** The caption uses a ")" column, as both exemplars do. The party names are plain text, so a party name written with markdown italics or emphasis is not rendered as such.
7. **Case names are not italic in the sample.** The text layer of the exemplar has no italic markup, so the transcription is roman (this complaint has no case citations to italicize; the note applies to the motion).
8. **Gates.** `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 11, docx 15 checks passed, 0 failed; fb-595.68.33).
9. **Page pairing in the overlay.** The overlay pairs each sample page with the filed page sharing the most words (`OVERLAY-caskey-complaint.txt` gives the map, with word-overlap 40 to 74 percent). The pairs are not one to one (sample page 3 pairs with filed page 4, sample page 15 with filed page 19), because the render and the filing break pages differently: the filing has 19 pages including the ECF header, the render 15 at the time (17 since fb-595.68.33; the overlay was not re-run). The overlay is a diagnostic, not a score.
10. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; this is a tier 2/3 choice and is not asserted.

## Engines

Typst is the primary engine. The docx engine (`docx/`): `reference.xml` holds the Word styles (`base="xengine"` in the typst face `{font}`, Times New Roman 13 pt, 598-twip body and 299-twip single line boxes, the 13 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it), and `okwd-complaint.lua` reads the sample's body chunk by chunk as the typst template does and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua` (the frontmatter read as written, `$FORMBOOK_META`): the caption as a three-column table row, the numbered paragraphs and prayer items with the label before a tab at 1 in, the signature block kept together and with the last chunk. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.33; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002, and a typst template in TeX Gyre Schola).

- Cross-engine (fb-595.68.33): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (17 = 17 pages, 367/367 lines break after the same word); `params.cross_engine: gate` in `eval.yaml`. typst 11 and docx 15 checks passed, 0 failed (with OKWD-FONT-001, every word at least 13 pt, and OKWD-FORM-001, double spacing, from `eval.yaml`).
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.
