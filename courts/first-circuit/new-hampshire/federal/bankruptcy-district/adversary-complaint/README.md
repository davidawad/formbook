# nhb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the District of New Hampshire (`nhb`), the complaint that starts an adversary proceeding.
Folder: `courts/first-circuit/new-hampshire/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-smith-pj-currier-24-01019-adversary-complaint.pdf` (one filer, see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-smith-adversary-complaint.md`: the full complaint (introduction through reservation of rights, all four counts, paragraphs 1 to 40), signature block; no certificate of service (an initiating complaint has none, LBR 7103) |
| render | ok: `samples/OUTPUT-smith-adversary-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-smith-adversary-complaint.pdf` and `samples/OVERLAY-smith-adversary-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed on the final render) |

File names follow the tools' contract (`render.sh` writes `OUTPUT-<id>.pdf`, `overlay.sh` reads it and writes `OVERLAY-<id>.pdf`/`.txt`), not the bare `<id>.md` / `<id>.pdf` names in the task brief.

## Governing rules

Primary sources, fetched 2026-10-14. Federal rules from the Legal Information Institute text of the restyled Bankruptcy Rules (amended Apr. 2, 2024, eff. Dec. 1, 2024): https://www.law.cornell.edu/rules/frbp/. District rules from the court's combined local rules (file dated 2025-04-01): https://www.nhb.uscourts.gov/sites/nhb/files/PDFs/2025-04-01-local-rules-final.pdf.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7001 | An adversary proceeding is commenced by complaint (the sample's introduction cites it). Rule text not read in full for this pass. | Content only (author text). |
| Fed. R. Bankr. P. 7008(a) | Complaint states the grounds for jurisdiction and whether the pleader consents to entry of final orders by the bankruptcy court. | Author content: the sample has the jurisdiction paragraphs and the consent paragraph (para 5). The template does not check the wording. |
| Fed. R. Bankr. P. 7010 | Caption must substantially conform to the appropriate Official Form 416; Fed. R. Civ. P. 10 otherwise applies (numbered paragraphs, Rule 10(b)). | `bankruptcy-caption()` and `adversary-caption()`; paragraphs numbered by `body()`. |
| Fed. R. Bankr. P. 9004(b) | Caption shows the court name, case title, case number and adversary number, and a brief designation of the document. | `court`, `bankruptcy`, `adversary`, `title` frontmatter. |
| Official Form 416D (caption for adversary proceedings, as summarized in search results; the 416A/416B text was not retrieved) | Debtor, plaintiff and defendant, adversary number, judge's initials. | Two-part caption as in the exemplar. |
| D.N.H. LBR 9004-1(a) | Chapter of the case in the style, after the case number. | `bankruptcy.chapter`, printed beside "Case No.". |
| D.N.H. LBR 9004-1(b) | Judge's initials after a hyphen immediately following the case or adversary number. | The sample carries them in `case_number` (`22-10577-MAF`). |
| D.N.H. LBR 9004-1(c) | BNH identification number after counsel's signature. | `signature.lines` (`BNH 05483`). |
| D.N.H. LBR 7003-1 | Adversary proceeding cover sheet, attached to the complaint. | Not produced (separate attachment; see gap 3). |
| D.N.H. LBR 7004-2 | Summons issued by the clerk under Rule 7004. | Not produced. |
| D.N.H. LBR 7103 (certificate of service; cross-referenced from LBR 9004-1) | Every pleading except the initiating complaint carries a certificate of service. | Not applicable to this doc type (no certificate block in the template). |

## Layout (decisions that the rules leave open)

- Letter paper, one-inch margins, page numbers centered at the foot. No NH or federal rule gives a margin or pleading-paper format for adversary complaints, so these follow common practice and the exemplar.
- Body: EB Garamond 12 pt (vendored, the only font in `fonts/`), double-spaced at 27.6 pt line pitch (Word's double spacing for 12 pt Times). No line numbers (the exemplar is not on pleading paper).
- Caption: court name centered bold caps, then the bankruptcy caption (debtor, chapter, case number with judge's initials), then the adversary caption (parties, "v.", "Adv. Pro. No." left blank for the clerk), then the title centered bold caps.
- Paragraphs are numbered 1, 2, ... by the template (Rule 10(b)). Paragraphs under the headings listed in the frontmatter `unnumbered` field (INTRODUCTION, RESERVATION OF RIGHTS) are not numbered, and neither are paragraphs starting with "WHEREFORE"; the exemplar leaves all of these unnumbered, and its numbering runs 1 to 40.
- Lettered sub-items of a numbered paragraph (`(A)`, `(B)`, `(C)` in the sample) are unnumbered and indented, as in the exemplar.
- `#` headings are centered bold caps; `##` headings are centered bold (count sub-titles).
- Signature block: "Date:" on the left, the firm and the signature on the right half, counsel lines and BNH number below. The last paragraph is unbreakable and sticky, so it stays with the signature block and a signature page never stands alone.
- No forced line breaks, no case-specific text, and no coordinates in the template. Every case word comes from the sample frontmatter.

## What the overlay shows

`samples/OVERLAY-smith-adversary-complaint.pdf`: red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by word overlap; the page map is in `OVERLAY-smith-adversary-complaint.txt`:

```
ours p.1 filed p.1 word-overlap 75.8%   ours p.6 filed p.6 word-overlap 74.5%
ours p.2 filed p.2 word-overlap 86.0%   ours p.7 filed p.7 word-overlap 59.2%
ours p.3 filed p.3 word-overlap 89.8%   ours p.8 filed p.8 word-overlap 46.5%
ours p.4 filed p.4 word-overlap 71.4%   ours p.9 filed p.9 word-overlap 53.4%
ours p.5 filed p.5 word-overlap 58.3%
```

The overlay is a diagnostic, not a score. The lower overlaps are the expected ones: the exemplar is set in Times New Roman with a different line length, and the transfer schedule on page 3 is a table in the filing (see gap 5). The overlay was produced on the final render, after the last template change.

## Known gaps and open choices

1. **Typeface.** No NH local rule or FRBP 9004 text found sets a typeface or size for adversary complaints (the only LBR font rule, LBR 1007-2(b)(2), covers creditor matrices). The template uses EB Garamond 12 pt, the only vendored font; the exemplar is Times New Roman. Whether a Times-metric font is wanted is a question for David (it would need a vendored font, which is outside this box's scope).
2. **Only one exemplar.** The brief asks for one exemplar per doc type. Tier-2 review (EVAL-LOOP) would want two or three filers; this pass has one. CourtListener RECAP lists other NH adversary complaints with downloadable PDFs (for example Goodman v. U.S. Bank, 25-01034, 4 pages; Seacoast Powersports v. Hemstreet, 25-01004), but they were not downloaded for this pass.
3. **Cover sheet and summons.** LBR 7003-1 requires the adversary cover sheet as an attachment, and the summons is issued by the clerk under LBR 7004-2. Neither is produced by this template; both are separate documents.
4. **Count sub-titles.** Count sub-titles in the exemplar are in parentheses and are transcribed as `##` headings; the template does not enforce that wording.
5. **Transfer schedule is flattened.** The filed complaint's table of transfers (date, payee, bank, amount; paragraph 17) is transcribed as a single run-on paragraph. Markdown tables are not supported by the sample contract; this is a structural gap. The table would need a tables feature in the template (not added here).
6. **Italics.** The exemplar's text layer has no italic markup; case names in the sample are roman.
7. **Caption drawing.** The exemplar draws its caption with a column of ")" marks. This template uses a bordered two-column caption, a tier-2 convention choice rather than a rule.
8. **Judge's initials.** The sample uses `MAF` as in the exemplar. The template does not check that the initials match the assigned judge.

## Review of the rendered pages (final render)

- Page 1: court title, bankruptcy caption (debtor, chapter, case number), adversary caption (plaintiff, "v.", defendant, blank Adv. Pro. No.), COMPLAINT title, INTRODUCTION (unnumbered). Pass.
- Page 2: JURISDICTION AND VENUE, PARTIES, FACTS; paragraphs 1 to 11. Pass.
- Page 3: paragraphs 12 to 17; the transfer schedule (gap 5) runs as one paragraph. Pass for layout; content flattened by design.
- Page 4: paragraphs 18 to 20. Pass.
- Page 5: COUNT I with its sub-title; paragraphs 21 to 29. Pass.
- Page 6: paragraph 30; WHEREFORE (unnumbered); COUNT II with its sub-title; paragraphs 31 and 32; sub-item (A) unnumbered and indented. Pass.
- Page 7: sub-items (B) and (C); paragraph 33; WHEREFORE (unnumbered); COUNT III with paragraphs 34 to 36; WHEREFORE (unnumbered). Pass.
- Page 8: COUNT IV with paragraphs 37 to 40. Pass. The page ends with paragraph 40; the reservation moved to page 9 with the signature.
- Page 9: RESERVATION OF RIGHTS (unnumbered) with its paragraph, date, signature block with BNH number. Pass.

No findings were recorded in `reviews/` (this doc type has no `reviews/` folder). The Gate 2 record for this doc type is this section.

[Formbook index](../../../../../../README.md) | [Bankruptcy court README](../README.md)
