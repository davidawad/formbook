# wawb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the Western District of Washington (`wawb`).
Folder: `courts/ninth-circuit/washington/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-harbor-custom-24-04037-adversary-complaint.pdf` (primary, 24 pp., Polsinelli / Levene Neale) and `exemplars/FILED-EXAMPLE-burdette-25-01017-adversary-complaint.pdf` (second filer, 7 pp., K&L Gates). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-harbor-custom-complaint.md` (a portion of the 24-page filing: cover, jurisdiction, parties, factual allegations, Counts I to V, prayer, signature). |
| render | ok: `samples/OUTPUT-harbor-custom-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: all `EBGaramond-*`), no warnings. |
| overlay | ok: `samples/OVERLAY-harbor-custom-complaint.pdf` and `samples/OVERLAY-harbor-custom-complaint.txt` (page map). |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed; page 9 re-rendered and viewed after the signature-block fix, pages 1 to 8 unaffected by that change). |

Commands (from the repo root; the tools name outputs `OUTPUT-<id>` and `OVERLAY-<id>`, see Known gaps):

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/adversary-complaint samples/INPUT-harbor-custom-complaint.md
sh tools/overlay.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/adversary-complaint harbor-custom-complaint exemplars/FILED-EXAMPLE-harbor-custom-24-04037-adversary-complaint.pdf
```

## Governing rules

Verified 2026-10-14. Primary sources: the W.D. Wash. Local Bankruptcy Rules as adopted effective December 1, 2023 (court PDF, https://www.wawb.uscourts.gov/sites/wawb/files/attachments/2023_rules_clean_23_10_27_FINAL_w_ToC_Added_CSC_CLEAN.pdf), and the Federal Rules as published on Cornell LII.

The court's 2026 proposed amendments (comment period to September 30, 2026; effective December 1, 2026 if adopted) do not change LBR 9004-1. They change LBR 9013-1(d)(3) only (motions to shorten time), which this doc type does not use. The 2023 text governs now.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 9004-1(a) | 8-1/2 x 11 inch paper; standard embedded font, 11 or 12 point; double spaced. | `page-w`, `page-h`; `type-size = 12pt`; `pitch = 24pt`; `footer-size = 11pt` (the bottom notation is held to the same 11 point minimum). |
| Typeface | Face required: none. LBR 9004-1(a) and (b)(4) say "a standard embedded font" and name no face; no other W.D. Wash. local rule names one (checked 2026-10-15 against the same 2023 PDF). | Face: EB Garamond (`font-family` in `typst/wawb-adversary-complaint.typ`), kept because the rule names no face (`docs/FONTS.md`, "No face named"). No vendored substitute applies; fit n/a. Both filed exemplars are Times New Roman; that is filer convention, not a rule. |
| LBR 9004-1(b)(1) | Numbered paper: line numbers in the left margin. | `line-numbers()`, 28 lines (`lines-per-page`). |
| LBR 9004-1(b)(2) | Judge's name at the right side of the top of the first page. | `top-block()`: `judge` at the top right. |
| LBR 9004-1(b)(3) | Bottom of each page: abbreviated title and page number at left; name, address and telephone of the preparing attorney or firm at right. | `footer-block()`: `footer_title` and page number at left; `footer_counsel` at right. |
| LBR 9004-1(b) | Orders are formatted under LBR 9021-1; not applicable here. | Not used. |
| FRBP 7001 | What is an adversary proceeding. The sample's jurisdiction paragraph cites Rule 7001(1), (2), (9) as the filing does. | Author content; the template does not check the classification. |
| FRBP 7010 | Civil Rule 10 applies to pleadings in an adversary proceeding, except that the caption must substantially conform to the appropriate Form 416. https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption()`: court name, division, debtor's case, parties, "Adversary No.", title. |
| FRBP 9004(a) | Document must be clearly legible; the caption sets out the court's name, the case title, the case number and a designation of the document. https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-title()`, `caption()`, `brief_title`, `adversary_number`. |
| FRCP 10(a) (via FRBP 7010) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. https://www.law.cornell.edu/rules/frcp/rule_10 | As above; the complaint title names all parties (the caption lists them). |
| FRCP 10(b) (via FRBP 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each paragraph is numbered by the template; headings and lists are not. |

Not produced by this template (separate filings): the adversary cover sheet, the summons, the Rule 7007.1 disclosure statement, and any notice of hearing. Any of these may be required with the complaint; they are not the complaint.

## Layout

- Counsel (name, address, telephone, email) top left on lines 1 to 10 (the court title moves down for longer counsel blocks; at least 7 lines are reserved). The judge's name and the chapter sit top right.
- Court title on the next numbered lines: "IN THE UNITED STATES BANKRUPTCY COURT / FOR THE WESTERN DISTRICT OF WASHINGTON / AT <division>" (the division comes from the sample: `AT TACOMA` or `AT SEATTLE`).
- Caption: the debtor's case ("In re:", the debtor names, the case number, joint administration) in the left column above the parties; the parties are closed by a rule (right and bottom). The adversary number and the title are at the right.
- Body: double spaced (24 pt baseline), first-line indent, numbered paragraphs; level-1 headings centered caps; level-2 centered bold count titles (may run to two numbered lines); level-3 centered italic statutory basis; a markdown list is lettered A., B., C. (the exemplar's prayer convention).
- Signature: date at left; each firm at right with its firm name, "/s/" signer and the lines of address, telephone and email. Kept as one unbreakable block.

## What the overlay shows

Red = our render, blue = the filed exemplar, black = both. The map (`OVERLAY-harbor-custom-complaint.txt`) pairs sample page to filed page by shared words:

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.1 | 54.7% |
| p.2 | p.2 | 72.0% |
| p.3 | p.4 | 50.5% |
| p.4 | p.5 | 62.5% |
| p.5 | p.6 | 71.2% |
| p.6 | p.21 | 89.5% |
| p.7 | p.22 | 84.9% |
| p.8 | p.23 | 72.9% |
| p.9 | p.24 | 72.7% |

The overlay is a diagnostic, not a score. Overlap is lowest on page 1 (54.7%), the cover, where the sample's counsel block and caption are typeset differently from the filing, and on page 3 (50.5%), which pairs with filed page 4 because the sample's paragraphs 11 to 20 fall where the filing's paragraphs run across pages 3 and 4. Pages 6 to 9 pair with filed pages 21 to 24 because the sample transcribes the counts and the prayer, which are the filing's last pages. The sample's paragraphs run continuously from 1 to 50; the filing restarts numbering inside each count, so paragraph numbers do not line up across the two.

## Page review (Gate 2 equivalent)

- Page 1: counsel top left (lines 1 to 10), judge and chapter top right, court title on lines 12 to 14, caption with debtor block and parties closed by a rule, adversary number and title at right, bottom notation. Pass.
- Page 2: lead-in, JURISDICTION and PARTIES headings, paragraphs 1 to 10 on the numbered lines. Pass.
- Page 3: paragraphs 10 to 20, FACTUAL ALLEGATIONS and "Debtors" sub-heading (centered bold). Pass.
- Page 4: paragraphs 18 to 26; "Loans by Sound Equity" and "Sound Equity – Belfair, Washington" heading kept with its paragraph; two blank numbered lines at the foot because the next heading and paragraph move together. Pass (accepted, see Known gaps).
- Page 5: "Sound Equity Loans to HCDI in Texas", paragraphs 25 to 30, CLAIMS FOR RELIEF and COUNT I heading kept with paragraph 31. Pass.
- Page 6: paragraphs 32 to 41; Count II two-line title and its statutory line; Count III. Pass.
- Page 7: Count IV, Count V, PRAYER FOR RELIEF heading with paragraph 50 at the foot. Pass.
- Page 8: prayer items A to J, lettered, line-aligned. Pass.
- Page 9: date, two firm signature blocks ("/s/" over each signer, no overprint after the fix), bottom notation. Pass.

## Known gaps and open choices

1. **Two filers.** The primary is Harbor Custom (Polsinelli, 24 pp.); Burdette (K&L Gates, 7 pp.) is the second filer. Both are in `exemplars/` and in SOURCE.md. The brief names one exemplar per doc type; the second is saved for the tier-2 cross-check. The second's caption layout (single left column, "Adv. Proc. No." at right) is not the one the template follows.
2. **Font.** The rule names no face (LBR 9004-1(a): "a standard embedded font"), so EB Garamond stays under `docs/FONTS.md`. Both exemplars are Times New Roman, which is filer convention. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the filing. The 12-point minimum is met.
3. **Footer type size.** The bottom notation is 11 pt (the minimum the rule allows), not 10 pt as in the N.D. Cal. template, because LBR 9004-1(a) sets 11 or 12 pt for the pleading and carries no footer exception.
4. **Pleading rules.** The double rule at the left and the single rule at the right are the template's pleading convention (copied from the N.D. Cal. template). The rules do not require them; the exemplar's rules could not be read from the text layer.
5. **Paragraph numbering.** The template numbers paragraphs 1 to 50 continuously. The filing restarts numbering within each count. A complaint's numbering is the filer's choice under FRCP 10(b) (paragraphs numbered, not in which order); recorded here, not asserted.
6. **Letters in the prayer.** The sample letters the prayer items A to J (the exemplar's convention); the rules do not specify it.
7. **Output names.** `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `.txt`; the brief's `<id>.pdf` and `<id>-overlay.pdf` names were not used so the tools work unchanged. The sample is `INPUT-<id>.md`, as the court-of-appeals samples are.
8. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc type is a folder inside a court, so the gates were not run, and no pass stamp was written. Render and overlay were run; the page review above is the visual check.
9. **Sample is a portion.** The sample carries the cover, jurisdiction, parties, the factual allegations through the Sound Equity Texas loans, Counts I to V, the prayer and the signature. The filing's later factual sections (the Athene transfers, the Kenyon declaration, the Surcharge facts) are not transcribed, and the sample's Count V paragraphs are a close transcription, not a verbatim copy of every line. The sample runs 9 pages against the filing's 24.
10. **Local rule timing.** Local-rule text was read from the 2023 clean PDF on the court's site; the court's 2026 proposed amendments were read and do not change LBR 9004-1. If the court adopts a different LBR 9004-1 before the next review, this README needs updating.

## Engines

**docx** (`docx/`): `sh docx/build-reference.sh docx/reference.docx` builds the reference; `docx/complaint.lua` writes the body (counsel, judge, court title, caption, numbered paragraphs, lettered prayer, signature); `docx/render.sh` (run by `tools/render-docx.sh`) fills the bottom notation from the frontmatter. Output: `samples/OUTPUT-harbor-custom-complaint.docx` and `.docx.pdf` (LibreOffice 26.8), 9 pages; all 9 pages rendered at 60 dpi and viewed (`reviews/docx.md`).

- Matches the typst output: letter; margins (top 1 in, bottom 48 pt, left 1.5 in, right 0.75 in); EB Garamond 12 pt (`pdffonts`: EBGaramond only); 28 numbers on a 24 pt grid; pleading rules (double at left, single at right); counsel top left on lines 1 to 10 and judge and chapter top right; court title; caption with the debtor block, the parties, a rule right and bottom, the adversary number and the title at right; page break after the caption; numbered paragraphs; prayer lettered A. to J. with the text at 0.9 in; bottom notation on every page (title and page number left, counsel right); the signature block kept whole.
- Differs from typst: the numbers and the bottom notation are floating text boxes in the header and footer, not body flow; the caption party column is 3.2 in (typst 3.0 in) because at 3.0 in the parties ran past line 28 in LibreOffice; paragraph numbers are typed text, not a Word list, so they do not renumber on edit; page breaks follow LibreOffice (the prayer and the signature block fall on different lines than typst, the signature block is on page 9 in both); Word may paginate differently.
- Fonts: run with a `FONTCONFIG_FILE` that lists only the repo's `fonts/` directory, or LibreOffice substitutes silently.
- Not verified in Word (only LibreOffice here). The `.docx` is a valid zip of well-formed XML, every style it uses is defined, and the placeholders in the footer are all filled.

BLOCKED: check.sh (Gates 0 to 3, docx): `tools/check.sh` reads `<court-dir>/court.json` and `checks.yaml` at the court level, and a doc-type folder has neither; it exits 2 (`jq: Could not open file .../court.json`), so the gates did not run and `samples/.check-docx.txt` was not written.
