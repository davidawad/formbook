# ncwd: complaint

Doc type: **complaint** in the United States District Court for the Western District of North Carolina (`ncwd`).
Folder: `courts/fourth-circuit/north-carolina/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (27 pages, one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: a portion of the filing (caption, lead-in, intro, parties, jurisdiction, facts, claims 1 and 2, prayer, jury demand, signature) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages, typst 0.15.0, Times New Roman only (`pdffonts`), no warnings (`tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-bell-complaint.pdf` and `usage/OVERLAY-bell-complaint.txt` (`tools/overlay.sh`) |
| typeface | face required: none named (LCvR 7.1(d) sets a 12-point minimum only; a judge's standing order may set a face). Template face: **Times New Roman** 12 pt, the house standard where no face is named (`docs/FONTS.md` rule 6; Liberation Serif as fallback), on typst and docx; EB Garamond before 2026-10-17 (the docx until fb-595.68.19). |
| pages reviewed | 8 of 8 on the earlier EB Garamond render, before fb-595.68 (every page rendered at 60 dpi and viewed; re-checked 2026-10-14 with the font pass) |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`) rather than the
`<id>.md` / `<id>-overlay.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write
those names. The overlay is a diagnostic, not a score.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 7.1(d) (W.D.N.C. Local Civil Rules, as revised effective 2022-12-01; https://www.ncwd.uscourts.gov/sites/default/files/local_rules/Revised%20Local%20Rules%20120122.pdf, printed p. 14; fetched and read 2026-10-14) | Absent a judge's Standing Civil Order or Case Management Order: font at least 12 point, lines double-spaced, one-inch margins, each page numbered. The 25-page limit applies to briefs (not the complaint). | `type-size = 12pt`, `margin = 1in`, `pitch-body` (double spacing, 27.6 pt), `page-number()` in the footer. |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the title of a complaint names all the parties. | `court-title`, `caption` (the file number line reads "Civil Action No."; the title of the complaint is in the caption). |
| Fed. R. Civ. P. 10(b) (same source) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered()` numbers each body paragraph 1, 2, ...; headings, quoted text and the prayer are unnumbered. |
| Fed. R. Civ. P. 11(a) (https://www.law.cornell.edu/rules/frcp/rule_11, fetched 2026-10-14) | The signer's address, e-mail address and telephone number on the paper. | `signature-block()`: date, "Respectfully submitted," and each firm's "By: /s/" block with the lines the sample gives. |
| Fed. R. Civ. P. 8(a) (https://www.law.cornell.edu/rules/frcp/rule_8, fetched 2026-10-14) | A short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Content only: the template does not check the pleading's sufficiency. |
| LCvR 3.1(a) (same PDF, p. 5) | A filing fee is paid on commencement. | Not produced by the template (see Known gaps). |

Primary sources only for the rules above. Nothing in this folder was checked against a Standing Civil Order: those
orders can change the font, spacing and page limits for a given judge, and LCvR 7.1(d) says so.

## Layout

- US Letter, one-inch margins on all four sides, 12 pt Times New Roman (no face is named by the rules; the house standard, `docs/FONTS.md` rule 6).
- First page: the court title (three bold centered lines, the last one the division when the sample gives one), then a
  caption: the party column with one line per row, a ")" column the same height as the party column, and the right
  column with "Civil Action No." and the title. A "JURY TRIAL DEMANDED" line sits under the title when the sample asks.
- Double spacing is a 27.6 pt pitch (`pitch-body`), twice the 13.8 pt single line (`pitch-single`). The filed
  exemplar's pitch is also 27.6 pt (`pdftotext -bbox` on page 3 of each file, on the earlier EB Garamond render:
  baselines 27.6 pt apart in both).
- Headings: level 1 centered bold caps (section); level 2 centered bold (a claim's title); level 3 centered regular
  (the claim's "(On Behalf of ...)" line). Each heading stays with the text after it (sticky).
- Numbered paragraphs: 0.5 in first-line indent, then the number in a 0.5 in box (the text starts 1 in from the margin).
- Unnumbered text: a markdown chunk that starts with `>` (the WHEREFORE clause, a quoted class definition, the jury
  demand) is set as a plain paragraph with the first-line indent and no number.
- Prayer: markdown `1.` items are lettered A., B., ... (as in the filed prayer).
- Signature: a date line on the left; "Respectfully submitted," and one block per firm at the right half. A firm that
  signs has a "By: /s/" line for the signer; co-counsel has the firm and its lines only.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number` (empty prints a blank "Civil Action No.:"), `division`
  (or null), `caption.parties` (list of `{lines: [...], designation}`; "v." is inserted between parties; each entry in
  `lines` is one printed line and should be short enough not to wrap in the 2.9 in party column), `title` (list of bold
  lines), `jury_demand`, `lead_in` (unnumbered opening paragraph, optional), `signature` (`date` and `blocks` of
  `{firm, by, lines}`).
- Body chunks separated by blank lines: `#` heading (level 1), `##` (level 2), `###` (level 3); a `1.` list (lettered
  in the output); a `>` chunk (unnumbered); or a plain paragraph (numbered).
- Not supported: tables, footnotes, raw typst. Italics (`*...*`) work through the markdown renderer.
- Case-specific text is only in the sample. The template contains no case words.

## Overlay

`usage/OVERLAY-bell-complaint.pdf` (made on the earlier EB Garamond render, before fb-595.68) shows the render in red and the filed page in blue; black where they agree. The
text map (`OVERLAY-bell-complaint.txt`) pairs each rendered page with the filed page that shares the most words. The
sample is an excerpt, so filed pages not transcribed (most of the 27) pair with low word overlap, as expected. Overlap
numbers do not measure quality.

## Known gaps and open choices

1. **One exemplar.** The task asks for one filed exemplar per doc type; the tier-2 bar in the protocol asks for two or
   three from different filers. The RECAP search also listed *McMillan v. Pluri Potent Partnership, LLC* (WDNC ECF 1,
   11 pages, described as "COMPLAINT ... with Jury Demand") as a candidate; it was not downloaded or read. Tier 2 is
   therefore **not** judged against two filers.
2. **Font.** The rules name no face (LCvR 7.1(d) gives a size only). The template is Times New Roman 12 pt, the house
   standard (`docs/FONTS.md` rule 6, David 2026-10-17), the exemplar's face too; EB Garamond before 2026-10-17 (the docx until fb-595.68.19). The
   12-point minimum is met.
3. **Pleading paper.** WDNC's rules do not require numbered line pleading paper, and the exemplar has none. The
   template does not draw line numbers. (The CAND complaint in this repo does; the WDNC template deliberately does not.)
4. **Judge's standing order.** LCvR 7.1(d) defers to a judge's Standing Civil Order and Case Management Order. The
   template applies the Local Rule defaults only. Per-judge orders were not searched.
5. **Filings that go with a complaint are not produced**: the civil cover sheet (JS 44), summons, the Rule 7.1
   disclosure statement and any AI or other certification. None of these was verified as a WDNC requirement for the
   complaint in this pass.
6. **Quoted text.** A `>` chunk is set with the first-line indent only, not as an indented block quotation as the
   exemplar shows the class definition.
7. **Signature on its own page.** The signature block is unbreakable. On the earlier EB Garamond render it moved to
   page 8 with the jury demand on page 7; the page was not full but the block was not split.
8. **Sample is an excerpt.** The sample transcribes the caption, the opening, the parties, jurisdiction, parts of
   the facts, claims 1 and 2, the prayer, the jury demand and the signature. The filed paragraph numbers are not
   transcribed; the template numbers from 1. Exhibits A to D are referred to and not attached.
9. **Heading style.** Section headings are bold caps (as the exemplar's). The sub-heading "FLSA Requirements" is a
   centered bold line, a choice made for the sample; the exemplar's sub-headings are not checked against it.

## Review of the rendered pages (`usage/OUTPUT-complaint.typst.pdf`, 8 pages, the earlier EB Garamond render)

Each page was rendered at 60 dpi and viewed, before fb-595.68; the current render is 9 pages.

- Page 1: court title, caption with ")" column, "Civil Action No.:" blank, title and jury demand legend at the
  right, lead-in, Introduction heading, paragraphs 1 to 3. Pass.
- Page 2: paragraphs 4 to 11 (11 begins here), Summary of Claims, Parties. Pass.
- Page 3: paragraph 11 (ends), 12, Jurisdiction and Venue (13 to 15), Plaintiff's Experience heading, paragraphs 16
  to 20. Pass.
- Page 4: paragraphs 21 to 23, Tip Credit heading, FLSA Requirements. Pass; the first claim heading moved to page 5
  with its paragraph (sticky).
- Page 5: First Claim for Relief heading block, paragraphs 24 to 29, Second Claim heading, paragraph 30. Pass.
- Page 6: paragraphs 31 to 34, Prayer for Relief, WHEREFORE (unnumbered), item A. Pass.
- Page 7: prayer items B to K, Demand for Trial by Jury (unnumbered). Pass.
- Page 8: date, "Respectfully submitted," and the two firm blocks (signer's "By: /s/" line; co-counsel with no "By"). Pass.

Gate 2 rows for these pages are recorded here (this doc type has no `reviews/` folder).

## Engines

**docx** (`docx/reference.xml`, from which `fb render --engine docx` builds the reference document on the shared cross-engine recipe in the typst face; `docx/complaint.lua` builds the caption, the numbering, the prayer letters and the signature block; `docx/make-reference.sh` and `docx/reference.docx` were retired into fb render in fb-595.68.19). Output: `usage/OUTPUT-complaint.docx` and `usage/OUTPUT-complaint.docx.pdf` (LibreOffice, 9 pages, the same page count as typst). XENG-001..003 pass and `tools/check.sh --engine docx` passes on `eval.yaml` (`usage/.check-docx.txt`: PASS). Not opened in Word; `unzip -tq` and `xmllint` pass on every XML part, and LibreOffice converted it without error.

- *Matches typst* (checked by eye on the earlier 8-page EB Garamond docx; the face is now Times New Roman 12 pt on both, Regular and Bold embedded): US Letter with one-inch margins; double-spaced body at the same 27.6 pt pitch and single lines at 13.8 pt (`pdftotext -bbox`: body and caption pitches equal in both PDFs); the caption top at the same place (109 pt from the page top); the caption (party column, ")" column, right column with "Civil Action No.:", the bold title and the jury legend); the court title; the lead-in; allegations numbered 1 to 34 with the same first-line indent; the prayer lettered A. to K.; the jury demand; the signature block at the right half, with "Dated:", "Respectfully submitted," and "By: /s/" for the signer; a centered page number on every page.
- *Differs (tier 2; on that earlier docx, not re-checked here):* line breaks differ from typst's in places (LibreOffice and typst break lines differently), so some page breaks fall at other lines and the signature block moves to page 8 in both, with the jury demand on page 7 in typst and on page 8 in docx. Section headings are 17 pt and sub-headings 14.5 pt to approximate typst's default heading sizes (typst sets them at 1.4 and 1.2 em); the space around a heading is within a few points of typst's but not identical. Numbers are followed by a tab to the one-inch stop, not typst's 0.3 in gap. The quoted `>` chunks are set with the first-line indent, as in typst.
- *Pages reviewed:* docx pages 1 to 8 of the earlier EB Garamond `OUTPUT-complaint.docx.pdf` (all 8), and typst pages 1 to 8 of the typst render (all 8), at 60 dpi.
- *BLOCKED:* none. The complaint has no table of contents or table of authorities, so no field is needed; the caption table has no visible borders in LibreOffice.
