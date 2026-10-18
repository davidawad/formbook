# S.D. Alabama Bankruptcy Court (alsb): adversary complaint

- Court: `alsb`, United States Bankruptcy Court, S.D. Alabama (`courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/`)
- Doc type: `adversary-complaint`. Complaint commencing an adversary proceeding (Fed. R. Bankr. P. 7001). Self-contained folder: no shared files.
- Exemplar: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (*Hester v. U.S. Department of Education*, Adv. No. 23-01002, filed 2023-01-06; provenance in `usage/SOURCE.md`). One exemplar only; see Known gaps.
- Sample: `usage/INPUT-adversary-complaint.md` (transcription of the filed complaint, 6 pages). `usage/INPUT-adversary-complaint-2.md` is a fictional template smoke test, not a transcription.
- Status: template and README complete; render, overlay and page review done for the Hester sample (6 of 6 pages). Typst engine only. `court.json` untouched. Fonts pass (2026-10-14): no face named by the court's rules, so EB Garamond is kept; re-rendered and re-reviewed (see Typeface row under Governing rules). DOCX engine added (see Engines); its PDF checks are BLOCKED.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `alsb-adversary-complaint`. |
| `typst/alsb-adversary-complaint.typ` | Template. Parameter block at the top (EB Garamond 13 pt, 1 in margins, double-spaced body, caption, numbered paragraphs). |
| `usage/INPUT-adversary-complaint.md` | Transcription of the filed complaint (frontmatter + body). Includes caption, sections, prayer, signature block and certificate of service. |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | `sh tools/render.sh courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/adversary-complaint usage/INPUT-adversary-complaint.md` (6 pages). |
| `usage/OVERLAY-hester-complaint.pdf`, `.txt` | `sh tools/overlay.sh courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/adversary-complaint hester-complaint` (red = ours, blue = filed, black = agree). |
| `usage/INPUT-adversary-complaint-2.md`, `OUTPUT-adversary-complaint-2.typst.pdf` | Fictional sample (5 pages); kept as a template smoke test. |

Frontmatter fields the template requires: `title`, `case_number`, `chapter`, `adversary_number`, `court`, `caption` (debtor, plaintiff, defendant), `signature` (signer, lines), `stipulation-26-1`. Optional: `date`, `certificate-of-service` (markdown, rendered after the signature block).

## Governing rules

Verified on 2026-10-14 unless noted.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Fed. R. Bankr. P. 7008(a) (<https://www.law.cornell.edu/rules/frbp/rule_7008>; amended Apr. 2, 2024, eff. Dec. 1, 2024) | A complaint must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | Not enforced by the template. The filed Hester complaint has no consent statement, so the transcription has none (Known gaps 7). |
| Fed. R. Bankr. P. 7010 (<https://www.law.cornell.edu/rules/frbp/rule_7010>; amended Apr. 2, 2024, eff. Dec. 1, 2024) | Fed. R. Civ. P. 10 applies, except that the caption must substantially conform to the appropriate version of Official Form 416 (the template cites Official Form 416A for the complaint caption; not re-verified this session). | `caption()`: court lines, party groups, case number, chapter, adversary number, title. |
| Fed. R. Civ. P. 10(b) (applies via Rule 7010; not re-verified this session) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `enum` show rule: numbered paragraphs run continuously through the complaint. |
| Fed. R. Bankr. P. 7001, 9004(a)-(b) | Adversary proceeding; legibility and caption. | Cited in the template comment. Not re-verified this session. |
| S.D. Ala. LBR 7026-1, "Discovery - Required Disclosures" (<https://www.alsb.uscourts.gov/sites/alsb/files/LocalRules_0.pdf>; the copy on the site is marked "Effective Date: December 1, 2009", read 2026-10-14) | Every complaint must state whether the pleader stipulates that Fed. R. Civ. P. 26(a)(1) will not apply. A complaint without the statement is construed as a stipulation that Rule 26(a)(1) will not apply. | Required `stipulation-26-1` field, rendered before the signature block. |
| S.D. Ala. LBR, full copy (14 pp., same source, read 2026-10-14) | No typeface is named. A text search of the whole copy for font, typeface, point size, margin, spacing and paper finds no requirement for pleadings. | Typeface: no face required, so the template keeps EB Garamond (`docs/FONTS.md`, "No face named"). Size, margins and spacing are convention choices. |

The same S.D. Ala. local rules copy contains no font, margin, spacing or paper-size requirement for complaints (grep for font, margin, spacing, format found none). Those values are convention choices, not rule values.

**Typeface row (fonts pass, 2026-10-14):** face required: none. Vendored substitute: EB Garamond (the no-face default; no court-named face to substitute). Metric-compatible: n/a. Visual-only: n/a. Engines: typst only; this folder has no `latex/` or `docx/` engine to update. The template header previously said the local rules were "dated 08/07/2023"; that date is not supported by the copy read on 2026-10-14 (effective December 1, 2009). Whether a newer local rules set exists is not verified.

## Overlay

`usage/OVERLAY-hester-complaint.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the final run:

- p.1 ↔ filed p.1 (76%), p.2 ↔ p.2 (71%), p.3 ↔ p.3 (72%), p.4 ↔ p.4 (68%): body text lines up with the same passages.
- p.5 ↔ filed p.6 (44%), p.6 ↔ filed p.6 (31%): prayer, signature and certificate of service. The filed complaint has its signature and certificate on pages 5-6 with a different break.

## Page review (Gate 2)

Every page of `OUTPUT-adversary-complaint.typst.pdf` was rasterized at 60 dpi and viewed after the final render (6 of 6). Typst printed no warnings. Fonts embedded: EB Garamond (regular, bold, italic) only.

| Page | Content | Result |
|---|---|---|
| 1 | Caption (court, parties, case no., chapter, adversary no.), title, introduction, Jurisdiction and Venue, Parties ¶¶ 1-2 | OK. Party lines are single-spaced. |
| 2 | Parties ¶ 3; Factual background, A.; ¶¶ 4-6 | OK. |
| 3 | ¶¶ 7-9 | OK. |
| 4 | ¶ 10; B.; ¶¶ 11-14; Count I heading; ¶¶ 15-18 | OK. |
| 5 | Prayer; ¶ 19 and its items (1)-(3); LBR 7026-1 statement (bracketed note); signature block; Certificate of Service begins | OK. Signature lines run as one block. |
| 6 | Remainder of the certificate of service; signature | OK. Last page is mostly blank: the certificate ends here. |

Tier-2 findings (ACCEPTED, not chased):

- Paragraph numbers run continuously (1-19). The filed complaint numbers 1-15, 18-20, 22 (it skips 16, 17, 21). See Known gaps.
- The prayer items (1)-(3) render as separate paragraphs, with (1) at the margin and (2)-(3) indented. The filing sets them as one paragraph.
- The body uses EB Garamond; the filing uses Times New Roman. Typeface is convention (no S.D. Ala. rule).
- The certificate of service paragraphs take a first-line indent; the filing's paragraphs do not.

## Engines

- **typst** (primary): `typst/`, output `usage/OUTPUT-<id>.pdf`.
- **docx**: `docx/reference.docx` (built by `sh docx/make-reference.sh` from `docx/reference-parts/`: styles, numbering, footer) and `docx/alsb.lua` (caption box, stipulation line, signature block, numbered paragraphs, from the same frontmatter). Output `usage/OUTPUT-<id>.docx` for both samples. Command: `sh tools/render.sh --engine docx <this-folder> usage/INPUT-<id>.md`.
- **latex**: not built.

**Matches typst** (the values come from `typst/alsb-adversary-complaint.typ`, and the line pitch was measured on our own typst render at 26 pt): US Letter, 1 in margins, EB Garamond 13 pt; body lines exactly 26 pt apart; 0.5 in first-line indent; numbered paragraphs run continuously (`1.`-`19.`) at the 0.5 in indent with wrapped lines back at the margin; centered bold caps headings (level 1 at 18 pt, level 2 bold at 15.5 pt); caption with a vertical rule and the case-number column; the LBR 7026-1 line before the signature block; "Dated" and "Respectfully submitted" side by side; certificate of service after the signature; centered page number at 11 pt.

**Differs from typst:**

- Single-spaced blocks (caption, signature, footer) use Word's natural line height for EB Garamond, not typst's 0.3 em leading, so their vertical positions shift by a few points.
- The prayer items `(1)`-`(3)` are literal labelled paragraphs with the body first-line indent. Typst's render puts `(1)` at the margin and indents `(2)`-`(3)`.
- Certificate bullets use pandoc's default list indent, not the typst template's.
- The footer is a bare page number (no "Page X of Y").
- EB Garamond must be installed on the machine that opens the `.docx`. Word substitutes silently when it is missing.

**docx BLOCKED** (not verified; this box has no working LibreOffice):

- `docx-pdf-render`: the `.docx.pdf` could not be made. conda-forge has no LibreOffice package. The Debian LibreOffice packages were extracted without root, and `soffice.bin` aborts in its UNO bootstrap (`uno::RuntimeException`), so `soffice --headless --convert-to pdf` fails. Gates 0-3 are measured on that PDF, so none of them ran. Visual review: 0 pages rendered, 0 pages looked at.
- `check-docx`: `sh tools/check.sh <this-folder> --engine docx` fails before any gate runs. The checker reads `court.json` and `checks.yaml` next to the doc-type folder, and this court has neither.
- Word open test: not run (no Word here). The package parts are well-formed XML (`xmllint`), and pandoc reads the `.docx` back with the caption, body, signature and certificate in order. That is a structural check, not a Word check.

## Known gaps

1. One exemplar only. The court has one public filed complaint (Hester). A second filer's complaint was not found: CourtListener RECAP searches and one web search on 2026-10-14 turned up no second S.D. Ala. adversary complaint PDF. The court's checklist asks for two; add one when found.
2. The filed complaint skips paragraph numbers 16, 17 and 21. The transcription keeps the filed text in order; the template numbers paragraphs continuously, so rendered numbers differ from the filing after ¶ 15.
3. The caption's "IN RE:" line above the debtor is not rendered (the template has no field for it).
4. The filed "Adversary Case No." is blank. The adversary number `23-01002` in the sample is taken from the ECF header of the filing (the adversary number matches the ECF docket entry).
5. The filed complaint has no LBR 7026-1 statement. The sample carries a bracketed note saying so, so the omission is visible. The note is a transcription addition, not the filer's text.
6. The filing's signature line reads "RESPECTFULLY submitted on this the 6th day of January, 2023." The template prints "Dated: January 6, 2023" in its place.
7. The consent-to-final-orders statement (Rule 7008(a)) is not enforced by the template. The transcription does not state consent either: the filed complaint has no consent statement, and the template does not check for one.
8. No `latex/` engine is built. The docx engine is built but its visual and PDF checks are BLOCKED (see Engines).
9. The fictional `INPUT-adversary-complaint-2.md` renders 5 pages and is not reviewed page by page; it exists as a template smoke test only. Its stipulation text was added so it still satisfies the required field.
