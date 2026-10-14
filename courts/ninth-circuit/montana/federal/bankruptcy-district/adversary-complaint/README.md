# U.S. Bankruptcy Court, D. Montana (`mtb`): adversary complaint

Doc type: **adversary-complaint** (complaint commencing an adversary proceeding, FRBP 7001). Court: United States Bankruptcy Court for the District of Montana. Folder: `courts/ninth-circuit/montana/federal/bankruptcy-district/adversary-complaint/`.

Status: exemplar=yes (1 filed exemplar, 1 filer), render=ok, overlay=ok, pages reviewed 4 of 4. Nothing here sets `status` in `court.json`.

## Governing rules

Sources, all read on 2026-10-14:

- **Mont. LBR** (Local Bankruptcy Rules, December 1, 2025 version), PDF from the court's site: `https://www.mtb.uscourts.gov/sites/mtb/files/LocalBankruptcyRules_12012025.pdf` (linked from `https://www.mtb.uscourts.gov/rules-statutes`). Cited by rule and printed page.
- **Fed. R. Bankr. P.** 7001, 7008, 7010, 9004: Legal Information Institute (`https://www.law.cornell.edu/rules/frbp/rule_7010`, `..._7008`, `..._7001`, `..._9004`). Quotes below are from those pages; where the page would not quote the whole rule, the text is paraphrased and marked so.
- **Fed. R. Civ. P. 10**, applied to adversary complaints by FRBP 7010 (not fetched; the form requirements named here are its standard ones and should be checked against the current text before this template is called complete).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MTB-FORM-001 | Mont. LBR 5005-2(a)(1), (6) | Electronically filed PDF; one-sided. Letter paper (8½ × 11 in) for self-represented litigants; the template uses letter for all. | `set page(paper: "us-letter")` |
| MTB-FORM-002 | Mont. LBR 5005-2(a)(2) | Legible, "at least 12-point font size." | `type-size` = 13 pt |
| MTB-FORM-003 | Mont. LBR 5005-2(a)(5) | "double-spaced, except for quoted material and footnotes." Body pitch 24 pt. | `body-leading`; the body block sets it, the counsel block and caption are single-spaced (block-level exceptions, see gaps) |
| MTB-FORM-004 | Mont. LBR 5005-2(a)(3) | "no less than one-inch margins, exclusive of page numbers." | `margins` |
| MTB-FORM-005 | Mont. LBR 5005-2(a)(4) | Consecutive page numbers at the bottom of each page. | page footer, `counter(page)` |
| MTB-FIRST-001 | Mont. LBR 5005-2(b)(1)-(6) | Upper left of the first page: name, office mailing address, telephone, email, state bar I.D., and the party represented (e.g., "Attorney for Plaintiff"). | `counsel`, `counsel_role` |
| MTB-FIRST-002 | FRBP 9004(b)(1)-(4) | Caption: (1) court's name; (2) case title; (3) case number and, if appropriate, adversary-proceeding number; (4) brief designation of the document's character. | `court`, `caption`, `case_number`, `adversary_number`, `title` |
| MTB-FIRST-003 | Mont. LBR 9004-1 | Case number format `0:12-bk-34567-ABC` (division digit, year, bk or ap, number, judge initials). | the sample's `case_number` and `adversary_number` values |
| MTB-CONT-001 | FRBP 7008(a)-(b) | Jurisdiction statement (case, number, chapter, district and division) and a statement whether the pleader consents to the bankruptcy court's entry of final orders or judgment. | author-written (sample ¶¶ 6-7); not checked by the template |
| MTB-CONT-002 | FRBP 7001 | The proceeding type: e.g., recovery of money or property (7001(a)), determination of the validity, priority or extent of a lien (7001(b)). | author-written; not checked |
| MTB-CONT-003 | Fed. R. Civ. P. 10(b) via FRBP 7010 | Numbered paragraphs. | author-typed numbers (`1\.`), as in the exemplar; not auto-numbered |
| MTB-SIG-001 | Mont. LBR 5005-2(c) | Signature: a cursive signature or a conformed "/s/" with the typed name. | `signature` block: `By /s/ <signer>` |
| MTB-CERT-001 | Mont. LBR 9013-1(e)(2) (service of papers) and the exemplar's practice | A certificate of service or mailing, when service is by mail. Here it is the exemplar's certificate of mailing. | `certificate` block (data from the sample frontmatter) |

Not generated, and why: the adversary cover sheet (Official Form 1040, FRBP 7003), the summons (FRBP 7004), and the filing fee are separate papers. The exemplar has none of them in its ECF entry.

## Exemplar

- `exemplars/FILED-EXAMPLE-bache-9-25-ap-09005-adversary-complaint.pdf`: Complaint, *Robert G. Drummond, Chapter 13 Standing Trustee v. Teri A. Noble*, Adv. No. 9:25-ap-09005-BPH, in *In re Bache*, No. 9:23-bk-90138-BPH. 4 pages, filed April 25, 2025, by the Chapter 13 Standing Trustee. Text layer present.
- Provenance and searches: `exemplars/SOURCE.md`.
- The exemplar was filed under the previous local rules. It is double-spaced (measured pitch 23.4 pt on page 2 from `pdftotext -bbox`), Times, Courier and Helvetica fonts (sizes not measured). The double spacing agrees with the current LBR 5005-2(a)(5) and (a)(2). The template follows the current text.

## Sample

- `samples/INPUT-bache-noble-complaint.md`: transcription of all 4 pages. Frontmatter carries the caption, counsel block, title, signature and the certificate of mailing (the addressee lines are from the exemplar). The ECF header and footer lines (`9:25-ap-09005-BPH Doc#: 1 Filed: ...`) are not transcribed; the template prints its own page numbers.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/ninth-circuit/montana/federal/bankruptcy-district/adversary-complaint samples/INPUT-bache-noble-complaint.md
sh tools/overlay.sh courts/ninth-circuit/montana/federal/bankruptcy-district/adversary-complaint bache-noble-complaint
```

- `samples/OUTPUT-bache-noble-complaint.pdf`: 4 pages. `render.sh` fails on any typst warning; none. Fonts: EB Garamond only (vendored).
- `samples/OVERLAY-bache-noble-complaint.pdf` and `.txt`: red = our render, blue = exemplar, black = both. Page map (word-overlap pairing, coarse): ours p.1 ↔ filed p.1 (73.0%), p.2 ↔ p.2 (68.2%), p.3 ↔ p.3 (71.8%), p.4 ↔ p.4 (84.0%). The layers will not coincide on text lines: the font is different (EB Garamond vs Times), so the overlay is a diagnostic, not a score.

## Visual review (all 4 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block upper left, court title, caption (two rows: bankruptcy case, adversary), title, opening sentence | OK. Caption rule drawn right and bottom of the party column. Case no. and adversary no. on the right. |
| 2 | ¶¶ 1-12, GENERAL ALLEGATIONS heading | OK after fix: the body was single-spaced at first (the counsel block's `set par` leaked into the body; it is now scoped). Double-spaced at 24 pt pitch, first-line indent on each paragraph. |
| 3 | VIOLATION OF THE AUTOMATIC STAY heading (two lines, centered), ¶¶ 13-25, UNAUTHORIZED POST PETITION TRANSFER heading | OK. |
| 4 | ¶¶ 26-27, WHEREFORE and prayer 1-3, DATED and signature block, CERTIFICATE OF MAILING with addressee and conformed signature | OK. Signature block on the right; "Dated" on the left. |

Reviewed pages: 4 of 4.

## Known gaps and open choices

1. **Tier 2 exemplars.** One exemplar, one filer. The eval-loop rule asks for two or three filed exemplars from different filers. A second public Montana adversary complaint with an archived copy was not found on CourtListener's RECAP search (most 2026 complaints are listed as unavailable).
2. **Font.** EB Garamond at 13 pt, not Times. The LBR sets only the 12-point floor and does not name a face. The repo vendors EB Garamond; Times is not vendored.
3. **Caption and counsel block are single-spaced.** The LBR's double-spacing rule (5005-2(a)(5)) exempts only quoted material and footnotes. The filed exemplar single-spaces its counsel block and caption too, and the template follows that. Flagged as a convention, not a rule reading.
4. **Length.** The exemplar is 4 pages, so the sample is 4 pages. The 8-14 page target applies only when the exemplar is that long.
5. **Paragraph numbering** is typed in the sample (`1\.`), not generated. The template does not check consecutive numbering.
6. **Jurisdiction, consent and proceeding-type statements** (FRBP 7008, 7001) are author-written; the template does not check them.
7. **Certificate.** Generated from the frontmatter; the template does not check the service method against LBR 9013-1(e)(2) or FRBP 7004.
8. **Separate papers** (cover sheet, summons, fee, proposed summons) are not generated.
9. **LBR version.** The exemplar was filed under the earlier local rules; the rule text here is the December 1, 2025 version.
10. **Fed. R. Civ. P. 10** is applied through FRBP 7010 from its standard form; the full text of Rule 10 was not fetched.
