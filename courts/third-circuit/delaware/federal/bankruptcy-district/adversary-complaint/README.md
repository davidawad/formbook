# Adversary complaint (FRBP 7001): Bankruptcy Court, D. Del.

Court: United States Bankruptcy Court for the District of Delaware (`deb`). Path: `courts/third-circuit/delaware/federal/bankruptcy-district/adversary-complaint/`.

**Typeface: EB Garamond (no face named for pleadings).** The template renders with zero typst warnings and all 10 pages were re-reviewed. The overlay **did not run**: the exemplar PDF is not in `exemplars/` on this box (only `SOURCE.md`), so the `OVERLAY-` files are from an earlier render. The sample is a partial transcription of the filed complaint, not the whole of it. See "Known gaps".

## Typeface

Kept at EB Garamond, the no-face default in `docs/FONTS.md`. Checked: LR 7007-2 (Del. Bankr. L.R., saved copy of the 2025 local rules) opens with "This Local Rule applies to motions filed in adversary proceedings", so its Courier New / Times New Roman requirement in (a)(ii) does not reach a complaint. Fed. R. Bankr. P. 7010 and Fed. R. Civ. P. 10 name no face. Re-check if the court issues a pleading-specific typeface rule.

## Exemplar

- `exemplars/FILED-EXAMPLE-zohar-iii-tilton-19-50390-adversary-complaint.pdf`: Complaint of Lynn Tilton and the Patriarch & Octaluna Entities for Equitable Subordination, Adv. Pro. No. 19-50390 (KBO), Doc 7, filed 11/12/2019 (dated October 1, 2019). 80 pages, text layer present (paragraph numbers are not in the text layer but are on the page image). The RECAP copy is the public redacted version. Source and search record: `exemplars/SOURCE.md`.
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
- `samples/INPUT-zohar-adversary-complaint.md`: frontmatter (caption, title, date, preamble, signature blocks) plus the body. Body paragraphs are numbered automatically (FRCP 10(b)). Unnumbered: headings; lists; the WHEREFORE clause and lettered prayer items; and editorial notes in italic brackets (`*[...]*`), which mark omitted text.
- `samples/OUTPUT-zohar-adversary-complaint.pdf` (10 pages); `samples/OVERLAY-zohar-adversary-complaint.pdf` and `.txt`.

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

## Pages reviewed

Re-reviewed on the current render (10 pages, EB Garamond, unchanged by the typeface pass): all 10 pages rasterised at 60 dpi and viewed. Earlier review: all 10 pages were rasterised at 60 dpi and viewed. Pages 1, 4 and 9 were viewed in the final render. Pages 6–8 and 10 were viewed in the render just before the WHEREFORE indent fix. Pages 2, 3 and 5 were viewed in an earlier 7-page render, before the parties section was added; their text is unchanged since. The WHEREFORE indent is the only change on the pages viewed later. Fixes made along the way:
- Paragraph numbering: the prayer's WHEREFORE and its lettered items were numbered as paragraphs. The template now leaves them unnumbered, as the exemplar does.
- Lettered prayer items were rendered as bullets from a markdown list. They are now plain `a)`–`d)` lines, indented.
- WHEREFORE paragraph flush with the margin. Fixed with the same first-line indent as the body.
- Footnotes in a numbered paragraph chunk would be numbered as paragraphs, and a footnote in the preamble cannot resolve. The sample carries no footnotes; the template does not handle them (see gaps).

Layout as reviewed: caption and preamble (1–2), preliminary statement (2–6), section II parties (6–8), section III jurisdiction (8–9), section IV heading with an omission note (9), count I (9), prayer (9), signature (10).

## Known gaps

- **Typeface: none named for pleadings.** See "Typeface". The motion brief uses Liberation Serif for LR 7007-2(a)(ii); that rule is limited to motions, so this complaint stays on EB Garamond.
- **Overlay not run (exemplar missing).** The overlay section below is from an earlier render. Restore the exemplar PDF to `exemplars/`, then re-run `sh tools/overlay.sh`.
- **Partial transcription.** The sample covers the caption, the preamble, the preliminary statement (paragraphs 1–13 of the transcription), the first part of section II, section III, the count I lead-in, the prayer, and the signature. Section II's remaining defendants, section IV (factual allegations), and count I's subsections are not transcribed. The omissions are marked in the sample with italic-bracket notes. The complaint runs 80 pages; the sample is 10.
- **Paragraph numbers do not match the filed complaint.** The filed complaint cross-refers to paragraph 68 (in section II). The sample numbers its paragraphs from 1 in order, so its numbers are not the filed ones. Filing a real complaint from this template would number from the real text.
- **Redactions.** The public version has redaction gaps (in paragraphs 8 and 9 of the transcription). They are shown as `[REDACTED]`, which is a transcription mark, not a template feature.
- **Footnotes.** The filed complaint's footnotes are not in the sample. The template does not number footnote definitions (they would become paragraphs), so a sample that uses footnotes must keep them out of the numbered flow. Footnotes 1 (the debtor list) and others are not in the sample; footnote 1's caption marker is written as "¹" in the caption text.
- **Outside the template:** the adversary cover sheet (Local Form 109, LR 7003-1) and the summons (Local Form 108, LR 7004-1) are separate filings and are not templated.
- **Signature placement.** The signature block is kept whole and lands alone on page 10 here.
- **Not checked:** the consent statement's exact form (it is content in the sample; the template does not force it).

[Court README](../README.md) | [Motion brief](../motion-brief/README.md)
