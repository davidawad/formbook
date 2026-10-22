# United States Bankruptcy Court, D. Massachusetts (mab): adversary complaint

- Court: `mab`, United States Bankruptcy Court for the District of Massachusetts (`courts/first-circuit/massachusetts/federal/bankruptcy-district/`)
- Doc type: `adversary-complaint` (complaint commencing an adversary proceeding, Fed. R. Bankr. P. 7001 and 7003)
- Exemplar: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (*Lassman v. Paul W. Marks Co. Inc.*, Adv. Proc. No. 26-01083, Doc. 1, filed 2026-08-20; provenance in `usage/SOURCE.md`). Filer: the Chapter 7 trustee of the Good Guys Provision Co. Inc. estate, a preference action.
- Sample: `usage/INPUT-adversary-complaint.md` (full transcription of the 5-page filing, with the additions listed under Gaps).
- Status: template built, rendered, overlaid and page-reviewed. Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, splits frontmatter from body, calls `mab-adversary-complaint`. |
| `typst/mab-adversary-complaint.typ` | Template. Parameters at the top, each tied to a rule. Caption, numbered paragraphs, tables, lists, signature, date. |
| `usage/INPUT-adversary-complaint.md` | Markdown sample: YAML frontmatter (division, debtor, chapter, case number, parties, title, date, signature groups) and the body. |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | `sh tools/render.sh courts/first-circuit/massachusetts/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md` (5 pages; 4 on the earlier EB Garamond render, before fb-595.68). |
| `usage/OVERLAY-lassman-adversary-complaint.pdf`, `.txt` | `sh tools/overlay.sh courts/first-circuit/massachusetts/federal/bankruptcy-district/adversary-complaint lassman-adversary-complaint` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

File names follow the repo's role convention: `INPUT-` for the markdown we feed in, `OUTPUT-` for our render, `OVERLAY-` for the comparison. The tools write and read these names by default.

## Governing rules

Verification date: 2026-10-14. Each rule was read from the source named.

| Rule | Requirement | Where the template uses it | Source and how checked |
|---|---|---|---|
| Fed. R. Bankr. P. 7001, 7003 | An adversary proceeding is commenced by complaint | Document type | Rule text not separately fetched in this box; the exemplar is a Rule 7001 recovery action (Nature of Suit 12, 11 U.S.C. § 547). |
| Fed. R. Bankr. P. 7008(a) | The complaint must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court | `assert` in `mab-adversary-complaint`: the body must contain the consent sentence, else the build fails | <https://www.law.cornell.edu/rules/frbp/rule_7008>, read 2026-10-14. The 2016 committee note says a core/non-core statement is no longer required. |
| Fed. R. Bankr. P. 7010 | The caption must substantially conform to the appropriate version of Official Form 416 (Fed. R. Civ. P. 10(a) applies) | `caption()`: court, division, debtor and chapter/case block, and the adversary parties block with the adversary number | <https://www.law.cornell.edu/rules/frbp/rule_7010>, read 2026-10-14. Form 416D (caption for an adversary proceeding) is identified by a secondary source (formsworkflow.com) and the N.D. Ill. local rule; the official form text was not retrieved. |
| Fed. R. Civ. P. 10(a), (b), via Rule 7010 | Caption names all parties; claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances | `allegations()`: each paragraph chunk is numbered, headings and tables are not; the prayer (`WHEREFORE`) is not numbered | <https://www.law.cornell.edu/rules/frcp/rule_10>, read 2026-10-14. |
| Fed. R. Bankr. P. 9004(a), (b) | Legible; caption states the court name, the case title, the case number and a brief designation | caption and title | <https://www.law.cornell.edu/rules/frbp/rule_9004>, read 2026-10-14. |
| MLBR 7003-1 (D. Mass. Local Bankruptcy Rules, May 1, 2025) | The original complaint must be accompanied by a completed adversary proceeding cover sheet (Director's Form B1040) | Not generated. The filer attaches it. Listed under Gaps. | <https://www.mab.uscourts.gov/sites/mab/files/May%201%202025%20Rules.pdf>, downloaded and read with `pdftotext` 2026-10-14. |
| MLBR 9004-1 | Documents filed with the Court conform to Appendix 8 | the whole template | Same PDF, p. 58. |
| MLBR Appendix 8, (a) | 8.5 x 11 in; double-spaced (except counsel identification, title, pleading title and footnotes; block quotations and certificates are exempt); margins at least one inch on all four sides; page numbers may sit in the margins; complaints are not stricken for non-conformity | `page(margin: 1in)`, `body-leading` (1.35em, a 24 pt baseline pitch at 12 pt; measured in the render), single spacing for caption and signature | <https://www.mab.uscourts.gov/sites/mab/files/APPENDIX%208%20GENERAL%20REQUIREMENTS%20OF%20FORM.pdf>, downloaded and read with `pdftotext` 2026-10-14. |
| MLBR Appendix 8, (b) | Every page numbered consecutively; the first page need not show the number | footer `counter(page)`, suppressed on page 1 | Same. |
| MLBR Appendix 8, (c) | Body at least 12-point; footnotes at least 10-point; plain roman type (italics or bold for emphasis) | `type-size = 12pt`, `footnote-size = 10pt` (no footnotes in this complaint) | Same. |
| Division names | Eastern, Central and Western divisions | `division` frontmatter, printed in the caption | The three divisions are listed in the front matter of the MLBR PDF (same source as above). Rule 5001-1 itself was not read. |

Typeface (checked 2026-10-14): face required: none. MLBR Appendix 8(c) says "a plain, Roman Type" at 12 pt body and 10 pt footnotes, and names no face. The May 1, 2025 MLBR text and Appendix 8 were searched for Times, Helvetica, Arial, Garamond, Century, Georgia, Courier and "font"; none names a face. Standing orders were not checked. Vendored substitute: none needed; the template is set in **Times New Roman**, the house standard (`docs/FONTS.md` rule 6; before fb-595.68 it kept EB Garamond, the "No face named" default). Fit: n/a. The filed exemplar is set in Times New Roman (`pdffonts`) too; the rules leave the face open.

## Overlay

`usage/OVERLAY-lassman-adversary-complaint.pdf` puts our render (red) over the best-matching exemplar page (blue). Pages are paired by word overlap. Diagnostic only, not a score. Pairings from the last run (on the earlier EB Garamond render, before fb-595.68):

- ours p.1 ↔ filed p.1 (69%): caption, title, Parties. The filed caption is set in Times and has the ECF header; ours was then in EB Garamond with the same layout.
- ours p.2 ↔ filed p.2 (61%): Jurisdiction and Venue, General Allegations, the transfer table.
- ours p.3 ↔ filed p.3 (44%): paragraphs 13-23 and Count I against the same passages in the filing, with different line breaks. Our numbering is one higher than the filing from paragraph 5 onward because of the added consent paragraph (Gaps, 1).
- ours p.4 ↔ filed p.4 (41%): WHEREFORE, signature, date. The filed signature block is on p. 5 (the filed p.4 holds the prayer and the last count paragraphs), so the pairing is one page off, as expected from a 4-page render of a 5-page filing.

## Page review (Gate 2; the earlier EB Garamond render, before fb-595.68)

Every page of `OUTPUT-adversary-complaint.typst.pdf` was rendered at 60 dpi and viewed (4 of 4). Typst printed no warnings. Fonts embedded: EB Garamond Regular and Bold only.

| Page | Content | Result |
|---|---|---|
| 1 | Court (three lines), In re block with the debtor and Chapter 7 / Case No., adversary parties with right and bottom rule, Adv. Proc. No. blank, title, Parties 1-2, Jurisdiction heading | OK. The caption fits on page 1 with the body starting beneath it. |
| 2 | Jurisdiction 3-6 (including the consent paragraph), General Allegations 7-10, transfer table, 11-12 | OK. The table is indented to the paragraph text and single-spaced; the TOTAL line is right-aligned as in the filing. |
| 3 | 13-23, Count I heading (centered, bold, two lines), start of the prayer | OK. Headings are the body size (the first render used a larger heading size; fixed). |
| 4 | Prayer a.-d., signature block ("Respectfully Submitted", party block, "By his attorneys", /s/ block), Date line | OK. The signature is indented 3.1 in as in the filing; the date sits left below it. |

No OPEN findings on this doc type. The filed document's ECF stamp and the Times typeface are not reproduced (see Gaps).

## Known gaps

1. **Consent paragraph added to the sample.** The filed complaint (Doc. 1) has no FRBP 7008(a) consent statement. The template requires one, so the sample has the sentence "The Trustee does not consent to the entry of final orders or judgment by the bankruptcy court." as paragraph 5. The position it takes is a placeholder chosen for the test sample, not a decision for the filer; the filer must choose. Because the paragraph is added, numbering from paragraph 5 on is one higher than the exemplar.
2. **Adversary cover sheet (MLBR 7003-1, Director's Form B1040) is not produced.** The filer attaches it. The RECAP entry for Doc. 1 lists "Adversary Proceeding Cover Sheet" as Attachment 1; it is not in the exemplar file and not transcribed.
3. **ECF header and footer** ("Case 26-01083 Doc 1 Filed ... Desc Main") are system stamps and are not reproduced.
4. **Typeface** is Times New Roman, as in the exemplar (`docs/FONTS.md` rule 6; EB Garamond, then the only vendored face, before fb-595.68). Appendix 8(c) allows any plain roman at 12 pt or larger.
5. **Signature** uses the `/s/` form and the typed name, as the exemplar does. A search summary said Standing Order 2024-04 requires an imaged signature under "Appendix 8, Rule 7". The Appendix 8 copy read here has only subsections (a) to (c), so that point is unverified and the template does not check it.
6. **Footnotes** are supported (footnote definitions are passed to the chunk that cites them) but the complaint sample has none; the footnote path is exercised only by the motion sample.
7. **Jury demand** is not supported. The exemplar has none; a demand would need a heading and the MLBR 9015-1 timing.
8. **Exhibits** are not produced; the exemplar has none.
9. **Counsel block** on the cover is not produced. The exemplar puts counsel only in the signature block, which is what the template does.
10. **Searches tried (for the record):** CourtListener RECAP search for `type=rd`, `court=mab`, "complaint adversary proceeding", available-only (returned Adv. 26-01083, Adv. 26-04027, Adv. 26-04024, Adv. 26-01084 and others). The Lassman complaint was chosen as the shortest filing with a text layer whose counsel and form are typical of the district.

## Engines

Typst is the primary engine. The DOCX engine (`docx/`: `reference.xml`, from which `fb render --engine docx` builds the reference document on the shared cross-engine recipe in the typst template's face, with the footer parts (page numbers from page 2); `mab.lua` for the cover, caption, signature and numbering; until fb-595.68 a committed EB Garamond `reference.docx` from `build-reference.sh` and a `render.sh` for the section, footers and numbering part, since retired into fb render) is checked on the LibreOffice PDF of the `.docx`, as `docs/DOCX.md` describes.

- **Matches the typst output:** Times New Roman 12 pt body (embedded in the docx PDF); exact 24 pt line pitch; 0.5 in first-line indent; 1 in margins on Letter; caption with the right and bottom rules; numbered allegations from 1 with the prayer and the "Respectfully Submitted" block unnumbered; the signature block at 3.1 in, kept on one page; page numbers from page 2 with an empty first-page footer; headings centered and bold; the transfer table.
- **Differs (tier 2, not tier 1; recorded on the earlier EB Garamond build, before fb-595.68; the committed typst and docx renders are now 5 pages each):** the docx runs to 5 pages where the typst render runs to 4, because the docx signature block moves whole to page 5. The transfer table has Word's default grid rules and sits flush left, where typst has no rules and indents it to the paragraph text. The prayer list uses Word's default list indent. Word may paginate differently from LibreOffice.
- **DOCX BLOCKED items:** none for this doc type. Not run in this box: `sh tools/check.sh <dir> --engine docx` (the gates were not executed here), and opening the `.docx` in Microsoft Word (only LibreOffice 26.8.1 was available).
