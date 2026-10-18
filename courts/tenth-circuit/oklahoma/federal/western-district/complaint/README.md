# okwd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Oklahoma (`okwd`).
Folder: `courts/tenth-circuit/oklahoma/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, plaintiff's counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole complaint, all 109 paragraphs, caption, headings, prayer, jury demand, signature |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 15 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-caskey-complaint.pdf` and `OVERLAY-caskey-complaint.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 15 of 15, every page rasterized at 60 dpi and viewed (pages 2 to 5 on the first render, the rest after the last template change; the later changes did not move the page breaks of pages 2 to 13, checked against the numbered paragraphs) |

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
| LCvR5.2(a) | Papers double-spaced if typewritten; 8 1/2 by 11 inch paper; one side. | `body-leading = 1.35em` (2.0em pitch, about 26 pt at 13 pt); `page-w`, `page-h`. |
| LCvR5.4 | "All papers shall contain the name, mailing address, daytime telephone number, fax number, and e-mail address" of the attorney. | `signature.lines` in the sample frontmatter (the block sits at the end of the complaint, as in both filed W.D. Okla. papers in the exemplar set). |
| LCvR3.1 | Counsel and pro se litigants number each party separately in the caption: plaintiffs consecutively, defendants consecutively. | `caption.parties[].names` carries the "1." numbers as filed; the template prints the names as given. |
| LCvR3.1 | A completed civil cover sheet (JS-44) must accompany the complaint. | Not produced (separate form; see known gaps). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | Court title lines, `caption`, `case_number` ("Case No." blank for a new filing), `brief_title`. Verified text: law.cornell.edu/rules/frcp/rule_10. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph 1, 2, ...; headings and lists are not numbered; the `unnumbered` frontmatter list keeps the prayer and jury demand unnumbered as filed. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Content only: the template does not check the wording. |
| Fed. R. Civ. P. 11(a) | Every pleading signed by at least one attorney of record, with name, address, e-mail and telephone. | `signature.sign` ("/s/ name") and `signature.lines`. |

## Layout

- Plain double-spaced pages, no pleading line numbers: W.D. Okla. filings do not use numbered pleading paper (both exemplars have none). This is the main difference from the N.D. Cal. complaint template in `courts/ninth-circuit/california/federal/northern-district/complaint/`, which uses numbered lines and 12 pt type.
- Court title on lines of its own, bold; the caption is single-spaced: party names, a ")" column (one ")" per line of each party row) and the case number at the right. `JURY TRIAL DEMANDED` appears at the right of the caption when `jury_demand: true`.
- Title of the paper bold and centered below the caption.
- Body: first-line indent 0.5 inch; numbered paragraphs (Rule 10(b)); level-1 headings bold and centered in capitals; level-2 headings bold and centered; prayer items lettered A., B., ... (markdown numbered items).
- Signature block single-spaced at the right half of the page, with "Respectfully submitted," and the `/s/` line, kept together and with the last paragraph (so the signature never stands alone on a page).
- Footer: centered page number on every page. The clerk's ECF header ("Case 5:26-cv-... Document 1 Filed ... Page x of y") is applied by the court, not by the filer, and is not produced here.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1, centered bold caps), a `##` heading (level 2, centered bold), a list (`1.` items, lettered A., B. by the template), or a paragraph (numbered by the template unless under an `unnumbered` level-1 heading).
- Frontmatter fields: `case_number` (empty string for a new filing: the caption shows "Case No. ____"), `caption.parties` (list of `{names, designation}`; `names` is plain text, lines not run through markdown, so "1." numbering is not read as a list), `brief_title`, `lead_in` (unnumbered opening paragraph), `jury_demand`, `unnumbered` (list of level-1 heading texts after which paragraphs are not numbered), `date` (optional), `signature` (`firm` list before the signer, optional; `sign` the "/s/" line; `lines` the rest of the block).
- Not supported: tables, footnotes, raw typst, forced line breaks in the body.
- The sample must not put the numbering in the text: the template numbers the paragraphs.

## Known gaps and open choices

1. **Font.** Face required by the court's rules: **none named**. LCvR7.1(d) (read in `LocalRules2026.pdf`, text extraction on 2026-10-15) requires "print style ... not less than 13-point type" and nothing about a face; LCvR5.2(a) requires double spacing and 8 1/2 by 11 paper. Template font: **EB Garamond** (`fonts/eb-garamond`), kept per `docs/FONTS.md` ("No face named"). The exemplar is set in Century Schoolbook (measured body text height about 15.6 pt by `pdftotext -bbox`, consistent with 13 pt); the exemplar's face does not change the rule, so it is not substituted. EB Garamond at 13 pt has a smaller x-height than Century Schoolbook at 13 pt, so the text looks smaller than the exemplar; the 13-point minimum is met. Visual difference only; not metric-compatible with the exemplar's face, so line breaks differ.
2. **Exemplar count.** One exemplar, one filer (plaintiff's counsel). EVAL-LOOP tier 2 asks for two or three filers. The search (CourtListener RECAP, `court=okwd`, complaints filed 2026-09 to 2026-10, `available_only`) found other W.D. Okla. complaints that are in RECAP (for example Griffin v. OU Medicine Inc., 5:26-cv-02815, 24 pages; Doe v. Independent School District No. 20 of Caddo County, 5:26-cv-02438, 28 pages), but these were not downloaded or checked for layout. Tier 2 is therefore **not** judged against two or three filers.
3. **Length.** The complaint is 19 pages as filed and the sample transcribes all of it; the render is 15 pages. The brief's target of 8 to 14 pages applies to exemplars of that length; this one is longer, and the transcription is complete rather than partial so the paragraph numbers match the filing.
4. **Case number.** The exemplar's caption is blank ("Case No. ____") because it is the initial filing. A later-filed paper would carry the number and judge's suffix (for example "CIV-2026-2422-R" in the exemplar for the motion); the template prints the value given.
5. **Civil cover sheet and related papers.** The JS-44 civil cover sheet (LCvR3.1), any Rule 7.1 disclosure statement and the summons are separate filings and are not produced. The exemplar's ECF attachments list a Civil Cover Sheet, which is not reproduced.
6. **Caption layout.** The caption uses a ")" column, as both exemplars do. The party names are plain text, so a party name written with markdown italics or emphasis is not rendered as such.
7. **Case names are not italic in the sample.** The text layer of the exemplar has no italic markup, so the transcription is roman (this complaint has no case citations to italicize; the note applies to the motion).
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
9. **Page pairing in the overlay.** The overlay pairs each sample page with the filed page sharing the most words (`OVERLAY-caskey-complaint.txt` gives the map, with word-overlap 40 to 74 percent). The pairs are not one to one (sample page 3 pairs with filed page 4, sample page 15 with filed page 19), because the render and the filing break pages differently: the filing has 19 pages including the ECF header, the render 15. The overlay is a diagnostic, not a score.
10. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; this is a tier 2/3 choice and is not asserted.

## Engines

**docx** (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference (styles, letter page with 1 in margins, centered PAGE footer); `docx/okwd-complaint.lua` builds the cover, caption, numbered allegations (typed "N." then a tab), lettered prayer items and the signature block. Render: `sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/western-district/complaint usage/INPUT-complaint.md`.

- Matches the typst template: EB Garamond 13 pt; exact 26 pt line pitch (double); 17.55 pt after each paragraph; 0.5 in first-line indent; level-1 headings bold centered capitals, level-2 bold centered; single 15 pt blocks for the caption, counsel and signature; `Case No. ____` when the case number is blank; `JURY TRIAL DEMANDED` at the right of the caption when set; signature kept with the last paragraph.
- Differs from typst: the caption and signature are borderless tables (one ")" paragraph per caption line, not measured against wrapped names); numbers are typed text, not Word list numbering; footnote text is exact 26 pt, as the typst body leading would set it (the template has no separate footnote rule).
- Word check: `usage/OUTPUT-complaint.docx` was written. Every XML part passes `xmllint --noout` and pandoc reads it back (`pandoc -f docx -t plain`). Word itself has not been run.
- BLOCKED, `docx.pdf` (LibreOffice PDF, Gates 0 and 1 on the docx): `soffice` is not installed on this box and cannot be installed here (no conda-forge package, no root). `usage/OUTPUT-caskey-complaint.docx.pdf` does not exist.
- BLOCKED, `tools/render-docx.sh` integrity step: `unzip` and `zip` are not installed. The render prints `render-docx.sh: 43: unzip: not found`, then `render-docx.sh: .../OUTPUT-caskey-complaint.docx is not a valid zip`, and exits 1 after writing the .docx. `reference.docx` was built with `ziptool` (libzip) instead.
- BLOCKED, visual review of the docx pages: no LibreOffice, so no docx page was rendered or viewed (pages reviewed: 0 of 15). The typst pages were reviewed (15 of 15) as the template reference only; that is not a docx review.
- Not done: Word open test (no repair prompt), font embedding (EB Garamond must be installed where the file opens), table-of-contents or cross-reference fields (none in this doc type).
