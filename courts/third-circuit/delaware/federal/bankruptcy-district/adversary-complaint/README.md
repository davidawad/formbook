# Adversary complaint (FRBP 7001): Bankruptcy Court, D. Del.

Court: United States Bankruptcy Court for the District of Delaware (`deb`). Path: `courts/third-circuit/delaware/federal/bankruptcy-district/adversary-complaint/`.

**Typeface: Times New Roman 12 pt (no face named for pleadings), in typst and docx alike.** Typst and docx are on the shared cross-engine layout model (fb-595.68.34): the docx breaks every line and page where typst does (XENG-001..003 gated). The sample is a partial transcription of the filed complaint, not the whole of it. See "Known gaps".

## Typeface

Times New Roman, the house face (`docs/FONTS.md`, "No face named"), vendored; the docx names the typst face (`{font}` in `docx/reference.xml`; it named EB Garamond until fb-595.68.34). Checked: LR 7007-2 (Del. Bankr. L.R., saved copy of the 2025 local rules) opens with "This Local Rule applies to motions filed in adversary proceedings", so its Courier New / Times New Roman requirement in (a)(ii) does not reach a complaint. Fed. R. Bankr. P. 7010 and Fed. R. Civ. P. 10 name no face. Re-check if the court issues a pleading-specific typeface rule.
## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: Complaint of Lynn Tilton and the Patriarch & Octaluna Entities for Equitable Subordination, Adv. Pro. No. 19-50390 (KBO), Doc 7, filed 11/12/2019 (dated October 1, 2019). 80 pages, text layer present (paragraph numbers are not in the text layer but are on the page image). The RECAP copy is the public redacted version. Source and search record: `usage/SOURCE.md`.
- Filer: Lynn Tilton and the Patriarch and Octaluna entities, by Cole Schotz P.C. and Gibson, Dunn & Crutcher LLP.

## Governing rules (verified 2026-10-14)

| Rule | Source | What the template does |
|---|---|---|
| Fed. R. Bankr. P. 7010 | https://www.law.cornell.edu/rules/frbp/rule_7010 (verified 2026-10-14). The fetch tool quotes it as: Fed. R. Civ. P. 10 applies in an adversary proceeding, "except that a pleading's caption must substantially conform to the appropriate version of Form 416." | Caption in Form 416 layout: court name, party block with the Plaintiffs and Defendants, and the adversary number on the right. Title below. |
| Fed. R. Civ. P. 10(a), (b) (applied by FRBP 7010) | Cited by 7010; not separately fetched | Names of all parties in the caption (the caption lists the Plaintiffs and Defendants in summary, as the exemplar does); numbered paragraphs (each body paragraph is numbered from 1). |
| Fed. R. Bankr. P. 9004(a), (b) | https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14) | Legible; caption contents. |
| Fed. R. Bankr. P. 7008 and Del. Bankr. L.R. 7008-1 | Local Rules (effective Feb. 1, 2025): https://www.deb.uscourts.gov/sites/deb/files/Local_Rules_2025%20%28Clean%29.pdf (read from the saved copy). LR 7008-1: a pleader states whether it consents to entry of final orders; if not, it waives the right to contest the court's authority to enter them. | The sample carries the statement in section III ("Plaintiffs do not consent to entry of a final order by this Court"). The template does not force the statement; it is content. |
| Del. Bankr. L.R. 9004-1(a) | same | Caption contents: debtor, case number, judge initials, adversary number. |
| Del. Bankr. L.R. 7003-1 | same | Cover sheet (Local Form 109) must accompany a complaint not filed electronically. **Not templated; separate filing.** |
| Del. Bankr. L.R. 7004-1 | same | Summons and Notice of Pretrial Conference (Local Form 108), pretrial conference 35–90 days from issuance, served with the complaint. **Not templated; separate filing.** |

The rules were fetched and read on 2026-10-14. The court's own PDF URL is rejected by curl, so the fetch-tool copy was used.

## Layout

- `typst/main.typ` (entry point), `typst/deb-adversary-complaint.typ` (template). Parameters at the top.
- `usage/INPUT-adversary-complaint.md`: frontmatter (caption, title, date, preamble, signature blocks) plus the body. Body paragraphs are numbered automatically (FRCP 10(b)). Unnumbered: headings; lists; the WHEREFORE clause and lettered prayer items; and editorial notes in italic brackets (`*[...]*`), which mark omitted text.
- `usage/OUTPUT-adversary-complaint.typst.pdf` (10 pages); `usage/OVERLAY-zohar-adversary-complaint.pdf` and `.txt`.

Naming: as in the motion-brief README: `OUTPUT-` and `OVERLAY-` are the names `tools/render.sh` and `tools/overlay.sh` use.

## Overlay (`OVERLAY-zohar-adversary-complaint.txt`)

| Ours | Filed | Overlap |
|---|---|---|
| 1 | 2 | 44.2% |
| 2 | 4 | 54.1% |
| 3 | 5 | 67.9% |
| 4 | 6 | 54.5% |
| 5 | 7 | 38.3% |
| 6 | 10 | 58.5% |
| 7 | 11 | 78.6% |
| 8 | 12 | 73.7% |
| 9 | 79 | 27.4% |
| 10 | 80 | 64.3% |

Our pages 1–8 pair with the filed pages 2–12 and page 9 (the prayer) with filed page 79. The pairing is by shared words; it does not line up numbering or layout. Page 5 (38%) pairs poorly and the cause was not checked. The overlay is a diagnostic, not a score.

## Pages reviewed (Gate 2 record, all 10 pages on each engine, rendered at 45 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 292/292).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court line, the two Form 416 captions, title, preamble | OK: each party column ruled at its right and foot, the rule running the height of the taller column; designations set right. |
| 2 | Preamble (end); I. Preliminary Statement; paragraphs 1 and 2 | OK. |
| 3 | Paragraphs 2 to 4 | OK. |
| 4 | Paragraphs 4 to 6 | OK. |
| 5 | Paragraphs 6 to 10 | OK. |
| 6 | Paragraphs 10 to 13 | OK. |
| 7 | Paragraphs 13 to 17; II. Parties and Other Relevant Entities | OK. |
| 8 | Paragraphs 17 to 21 | OK. |
| 9 | Paragraphs 22 to 28; the omission notes; III to V; Count I | OK: "§§ 157" carried to the next line whole (the old render split the signs). |
| 10 | Omission note; VI. Prayer for Relief; WHEREFORE and items a) to d); signature block | OK: item d) kept on the page with the signature; "Dated:" and the place beside the first two lines of the signature column. |

No open tier-2 finding. Changes in this pass: headings at the type size on the double pitch (they were typst's default heading sizes); an allegation's text at 1 in (the number in a 0.5 in box at the indent, docx a tab); the caption rule the height of the row; the signature block as single lines from 2.8 in (it was a two-column grid with 12 pt gaps), kept with the last paragraph.

## Known gaps

- **Typeface: none named for pleadings.** See "Typeface".

- **Overlay not run (exemplar missing).** The overlay section below is from an earlier render. Restore the exemplar PDF to `usage/`, then re-run `sh tools/overlay.sh`.
- **Partial transcription.** The sample covers the caption, the preamble, the preliminary statement (paragraphs 1–13 of the transcription), the first part of section II, section III, the count I lead-in, the prayer, and the signature. Section II's remaining defendants, section IV (factual allegations), and count I's subsections are not transcribed. The omissions are marked in the sample with italic-bracket notes. The complaint runs 80 pages; the sample is 10.
- **Paragraph numbers do not match the filed complaint.** The filed complaint cross-refers to paragraph 68 (in section II). The sample numbers its paragraphs from 1 in order, so its numbers are not the filed ones. Filing a real complaint from this template would number from the real text.
- **Redactions.** The public version has redaction gaps (in paragraphs 8 and 9 of the transcription). They are shown as `[REDACTED]`, which is a transcription mark, not a template feature.
- **Footnotes.** The filed complaint's footnotes are not in the sample. The template does not number footnote definitions (they would become paragraphs), so a sample that uses footnotes must keep them out of the numbered flow. Footnotes 1 (the debtor list) and others are not in the sample; footnote 1's caption marker is written as "¹" in the caption text.
- **Outside the template:** the adversary cover sheet (Local Form 109, LR 7003-1) and the summons (Local Form 108, LR 7004-1) are separate filings and are not templated.
- **Signature placement.** The signature block is kept whole and on one page with the last paragraph (page 10 here).
- **Not checked:** the consent statement's exact form (it is content in the sample; the template does not force it).

[Court README](../README.md) | [Motion brief](../motion-brief/README.md)

## Engines

Engine status: typst `OUTPUT-adversary-complaint.typst.pdf`; docx `OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice), 10 pages each, every line and page as typst (XENG-001..003 gated, `eval.yaml`); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ`: a 24 pt body pitch (double spaced), 14 pt single lines (court line, captions, title, signature, footer), explicit block spaces.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; single lines in 14 pt boxes) and `docx/deb-adversary-complaint.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the court line, the captions (one-row tables, the party cell bordered at its right and foot), the numbered allegations, the headings, the prayer, the notes, the signature block, the footer (a centred PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and a committed `reference.docx` in EB Garamond). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none.
- Footnotes are not supported in either engine (see "Known gaps").
