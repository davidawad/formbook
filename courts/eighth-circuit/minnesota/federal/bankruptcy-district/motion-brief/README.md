# D. Minn. bankruptcy court (mnb): motion with memorandum of law

- Court: `mnb`, United States Bankruptcy Court, District of Minnesota (`courts/eighth-circuit/minnesota/federal/bankruptcy-district/`)
- Doc type: `motion-brief`, a notice of hearing and motion with a supporting memorandum of law (D. Minn. LBR 9013-1(a)).
- Exemplar: `exemplars/FILED-EXAMPLE-mend-22-60407-motion-to-convert.pdf` (*In re MEnD Correctional Care, PLLC*, BKY No. 22-60407, ECF Doc 49, filed 2023-01-20, 17 pages; provenance in `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-mend-motion-to-convert.md` (transcribed from the exemplar).
- Status: template and sample kept from master; the README, exemplar, render, and overlay were added in this pass. Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `mnb-motion-brief`. |
| `typst/mnb-motion-brief.typ` | Template. Caption, notice and motion (numbered paragraphs), memorandum part split at `<!-- memorandum -->`, verification, signature block from frontmatter. |
| `samples/INPUT-mend-motion-to-convert.md` | Markdown contract sample: YAML frontmatter (notice title, memorandum title, lead-in, caption, date, signature) plus the body. |
| `samples/OUTPUT-mend-motion-to-convert.pdf` | `sh tools/render.sh courts/eighth-circuit/minnesota/federal/bankruptcy-district/motion-brief samples/INPUT-mend-motion-to-convert.md` (11 pages, typst 0.15.0, no warnings). |
| `samples/OVERLAY-mend-motion-to-convert.pdf`, `.txt` | `sh tools/overlay.sh <this folder> mend-motion-to-convert`. Red = our render, blue = filed exemplar, black = both agree. |
| `exemplars/` | The filed motion and `SOURCE.md`. |

## Governing rules

Primary sources are the D. Minn. local rules and the Federal Rules of Bankruptcy Procedure. The local-rules text was read on 2026-10-14 from the complete compilation, "MNB Local Rules Complete", stated as effective September 3, 2025: <https://www.mnb.uscourts.gov/sites/mnb/files/MNB%20Local%20Rules%20Complete.pdf>. Individual rules, read the same day: LBR 9004-1 <https://www.mnb.uscourts.gov/sites/mnb/files/9004-1.pdf>, LBR 9013-1 <https://www.mnb.uscourts.gov/sites/mnb/files/9013-1.pdf>, LBR 9013-3 <https://www.mnb.uscourts.gov/sites/mnb/files/9013-3.pdf>. The FRBP text is from the Cornell LII copies (<https://www.law.cornell.edu/rules/frbp/rule_9004>, `rule_9011`, `rule_9013`, `rule_9014`), read 2026-10-14. Those are secondary copies; they were not cross-checked against the uscourts.gov PDFs in this box.

| Rule | Requirement | Where the template or sample uses it |
|---|---|---|
| Fed. R. Bankr. P. 9013 | A request for an order is made by written motion | Structure: notice and motion, then memorandum |
| Fed. R. Bankr. P. 9014 | Contested matters: procedure for motions that start one | Cited in the notice (¶5) and the memorandum; the template does not render it |
| Fed. R. Bankr. P. 9004(a), (b) | Legibility; caption (court, title, case number, designation of the document) | `caption()`, 12 pt type |
| Fed. R. Bankr. P. 9011(a) | Signature by the attorney | `signature-block()`, `/s/` signature from frontmatter |
| D. Minn. LBR 9013-1(a)(1) | Notice of hearing and motion substantially complying with Local Form 9013-1 | Notice and motion, paragraphs 1-24 of the sample |
| LBR 9013-1(a)(2) | Concise memorandum of facts and law | Memorandum part after `<!-- memorandum -->` |
| LBR 9013-1(a)(3) | Verification if facts are at issue | "VERIFICATION" section after the signature block |
| LBR 9013-1(a)(4) | Proposed witness list, if applicable | Not rendered; see Known gaps |
| LBR 9013-1(a)(5) | Proposed order | Not rendered; see Known gaps |
| LBR 9013-1(a)(6) | Proof of service, if required | Not rendered; see Known gaps |
| LBR 9013-1(d) | Relief without hearing if no timely response | Cited in the notice (¶3) |
| LBR 9004-1(a), (b)(2) | Letter-size paper; attorney-produced documents printed to PDF | `page-w`, `page-h` = 8.5 × 11 in; typst to PDF |
| LBR 9011-1(a) | Signature block: name, address, email, telephone, attorney registration number | The sample's signature lines (see Known gaps: the filed block omits email) |

Note on the notice's "TO:" line. The sample says "The debtors and other entities specified in Local Rule 9013-3", as filed in January 2023. The 2023 renumbering (effective July 17, 2023) gave LBR 9013-3 the title "Applications", so the cross-reference is out of date in the current rules. The sample keeps the filed text verbatim; the current cross-reference is not verified.

## Overlay

`samples/OVERLAY-mend-motion-to-convert.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. The overlay is a diagnostic, not a score. Pairings from the last run:

- Sample p.1 ↔ filed p.1 (77%) and p.2 ↔ p.2 (59%): caption, notice, first paragraphs line up.
- p.3-p.8 ↔ filed pp. 4-9 (37-86%): facts, the motion to convert, the expedited-hearing paragraphs, the verification.
- p.9 ↔ p.13 (81%), p.10 ↔ p.15 (78%), p.11 ↔ p.16 (80%): the memorandum.

The exemplar's proposed order (filed p.17) has no counterpart in the sample.

## Page review (Gate 2)

Every page of `OUTPUT-mend-motion-to-convert.pdf` was rendered at 70 dpi and viewed (11 of 11) as PNG. Pages 5 and 10 were also rendered at 150 dpi and the foot of each viewed. The overlay sheet was viewed as a contact sheet (all 11 pages present). The comparison against the filed pages is the overlay pairing above; no separate side-by-side images were made in this pass.

| Page | Content | Result |
|---|---|---|
| 1 | Caption, notice title, "TO:" line, ¶¶1-4 (jurisdiction, expedited hearing, response deadline) | OK |
| 2 | ¶5 (basis and relief), "FACTS", ¶¶6-8 | OK |
| 3 | ¶¶9-12, list (A), (B) | OK |
| 4 | List (C)-(H), ¶13 | OK |
| 5 | ¶¶14-15, "MOTION TO CONVERT", ¶16, statutory list (A)-(J) | OPEN: the list runs to the bottom margin. At 150 dpi, the folio "5" sits directly under item (J). |
| 6 | List (K)-(P), ¶¶17-19 | OK |
| 7 | ¶20, "Need for Expedited Hearing" ¶21, "CONCLUSION" ¶22 | OK |
| 8 | ¶¶23-24, WHEREFORE, Dated and signature block, "VERIFICATION" and its signature | OK |
| 9 | Memorandum caption, "CONVERSION TO CHAPTER 7", §1112(b) block quote (to (2)) | OK |
| 10 | Block quote (A)-(B), citation paragraph, argument | OPEN: the folio "10" sits directly under the last line of text at 150 dpi, with no clear space between them. Same cause as p.5. |
| 11 | Memorandum argument end, WHEREFORE, signature block | OK |

Tier-2 findings (OPEN or ACCEPTED): pages 5 and 10 (OPEN). The bottom margin is shared with the folio: body text reaches the margin, so the folio collides with a line that ends at the foot of a page. Fix: move the folio down (for example `footer-descent`) or set a larger bottom gap for the footer, then re-render and re-review every page. Not changed in this pass, because it alters every page of the template and the brief asks to keep templates unless broken.

## Known gaps

1. One exemplar only. `docs/EVAL-LOOP.md` asks for 2 or 3 filed exemplars from different filers before tier 2 can be judged. Tier 2 is not finished for this doc type.
2. The proposed order (LBR 9013-1(a)(5)) is on filed p.17. It is not transcribed, and the template has no order page.
3. The certificate of service is a separate docket entry (ECF Doc 50, "Certificate of service (re: 49 Motion ...)", filed 2023-01-20), not part of this PDF. It is not transcribed, and the template renders no certificate. LBR 9013-1(a)(6) requires proof of service "if required".
4. No witness list (LBR 9013-1(a)(4)) is in the sample. The filing does not include one; the rule applies only when a witness is proposed.
5. Exhibit A (the client care list, referenced in ¶13) is not in the exemplar PDF and is not transcribed. The rendered sample shows the reference only.
6. The filed notice's "TO:" cross-reference to LBR 9013-3 predates the 2023 renumbering (see the note under Governing rules). It is kept verbatim.
7. The filed signature block gives no email address. LBR 9011-1(a) requires one in the current rules. The sample's signature lines are kept as filed, so the rendered block omits an email too.
8. Pages 5 and 10 (OPEN, above).

## Engines

| Engine | Folder | Output in `samples/` | State |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-mend-motion-to-convert.pdf` | template, unchanged by the docx work; no PDF in the snapshot |
| latex | `latex/` | none | not built |
| docx | `docx/` | `OUTPUT-mend-motion-to-convert.docx`, `OUTPUT-mend-motion-to-convert.docx.pdf` | built (below) |

The docx build: `sh tools/render.sh --engine docx motion-brief samples/INPUT-mend-motion-to-convert.md`. It runs `docx/render.sh` (pandoc, the Lua filter `docx/mnb-motion-brief.lua`, and `docx/reference.docx`). `docx/make-reference.sh` rebuilds the reference. The PDF is LibreOffice 26.8.1 with the vendored fonts only.

What matches the typst output: letter paper with 1 in margins; EB Garamond 12 pt, embedded and the only font; body double-spaced at a 24 pt line pitch with a half-inch first-line indent; numbered notice paragraphs and unnumbered memorandum paragraphs; the caption (court title, debtor box with 0.75 pt rules, indented "Debtor.", the centred bold title); the notice's signature block with its firm lines and "By: /s/"; the verification and its signature; the memorandum on a new page with its own caption; block quotations single-spaced and indented; lettered lists; centred bold section headings; a centred page number in the footer. The notice runs 8 pages and the memorandum 3, as in typst (11 in both).

What differs:
- Heading sizes: Word takes half-points, so 17 pt and 14.5 pt where typst uses 16.8 pt and 14.4 pt.
- Position: the first body line on a page sits about 11 pt lower than typst's, and the first caption line about 3 to 4 pt lower (LibreOffice places exact-spaced lines lower). The top margin is 1 in in both.
- Typst's folio collisions on pages 5 and 10 (OPEN above) do not occur here: the folio sits below the last line of each page.
- Block quotations use the spacing measured on typst's render: 13.8 pt lines, 18 pt before the first quoted paragraph, 1.2 pt between quoted paragraphs. The quoted text is indented 0.67 in on each side (typst: 0.5 in plus the quote's own indent).
- Footnotes: none in this template or sample. Footnote text is set to 10 pt (typst's default measured 10.2 pt); its line spacing is not checked.

docx BLOCKED items:
- The docx gates do not run yet: this court has no `rules.md` or `checks.yaml`, so `tools/check.sh --engine docx` has no checks to run. Nothing is stamped.
- Word: not opened (no Word on this box). The renderer checks the zip and the XML parts; LibreOffice converts the file without a repair step.

Page review (docx): all 11 pages of `OUTPUT-mend-motion-to-convert.docx.pdf` were rendered at 60 dpi and viewed against the typst render. No page has an open defect that is not in the list above.
