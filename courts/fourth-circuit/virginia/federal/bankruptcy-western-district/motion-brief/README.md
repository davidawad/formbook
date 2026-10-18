# United States Bankruptcy Court, W.D. Virginia: motion with memorandum in support

- Court: `vawb`, United States Bankruptcy Court for the Western District of Virginia (`courts/fourth-circuit/virginia/federal/bankruptcy-western-district/`)
- Doc type: `motion-brief`. A motion and the memorandum in support, in one document (FRBP 9013; LR 9013-1). One self-contained folder, no shared files.
- Exemplar: `usage/SAMPLE-vawb-motion-brief-thomas1705010.pdf` (*Thomas v. Midland Funding, LLC*, Adv. Nos. 17-AP-05009 & 17-AP-05010, Defendants' Motion to Dismiss and Memorandum in Support, filed 2017-08-07; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.md`: the caption and counsel, paragraphs 1–12, the Conclusion, paragraph 26, the prayer, the signature block and the certificate of service. Paragraphs 13–25 and footnotes 2–3 are not transcribed.
- Status: template built; render, overlay and a page-by-page review done (below). Not reviewed by a human; `court.json` of the court folder untouched.
- Exemplar: yes (one filer, one exemplar).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `vawb-motion-brief`. |
| `typst/vawb-motion-brief.typ` | Template. Parameter block at the top, each line tied to a rule or marked as a convention. |
| `usage/INPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.md` | Sample: YAML frontmatter (caption, title, counsel, signature, certificate of service) and the body. |
| `usage/OUTPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.typst.pdf` | `sh tools/render.sh courts/fourth-circuit/virginia/federal/bankruptcy-western-district/motion-brief usage/INPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.md` (10 pages, no typst warnings). |
| `usage/OVERLAY-thomas-midland-motion-to-dismiss.pdf`, `.txt` | `sh tools/overlay.sh courts/fourth-circuit/virginia/federal/bankruptcy-western-district/motion-brief thomas-midland-motion-to-dismiss`. |
| `usage/` | The filed exemplar and `SOURCE.md`. |

File names follow the repo's tools (`INPUT-`/`OUTPUT-`/`OVERLAY-`); see `../adversary-complaint/README.md`.

## Governing rules

Primary sources, verified 2026-10-14. Local rules: W.D. Va. Local Rules, effective 3/14/25, <https://www.vawb.uscourts.gov/sites/default/files/local_rules/Local%20Rules%20-%202025.pdf> (read as text with pdftotext; LR 9013-1 at pp. 64–66, LR 5005-3 at p. 44, LR 7001-1 at p. 55).

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 9013(a)–(b), <https://www.law.cornell.edu/rules/frbp/rule_9013> (as amended eff. 12/1/2024) | A request for an order must be made by written motion; a motion must state its grounds with particularity and set forth the relief or order requested | the title and the body (the template does not write the grounds; the sample states them) |
| FRBP 9014(a), <https://www.law.cornell.edu/rules/frbp/rule_9014> (as amended eff. 12/1/2024) | In a contested matter, relief must be requested by motion; reasonable notice and an opportunity to be heard | the motion's form; the notice of hearing is a separate paper (Known gaps) |
| FRBP 7010 and 9004(b) (same source, as amended eff. 12/1/2024) | Caption sets out the court, the title, the case number and adversary number, and a designation of the document; an adversary caption substantially conforms to Official Form 416 | `caption()`; the title line |
| LR 9013-1(A) | Non-CM/ECF motions in writing, originally signed by the movant or counsel | the signature block (`signature-block()`) |
| LR 9013-1(B) | Grounds stated with particularity; relief set out | the body |
| LR 9013-1(C); LR 7001-1(C)(4) | Lower left-hand portion of the signature page: name, address, telephone and e-mail address, if any | `signature-block()`: counsel block lower left |
| LR 9013-1(E) | Proof of service at the end of each motion, signed by counsel, detailing the date, manner, and the names and addresses served | `certificate-of-service()`, from the sample's `service` frontmatter |
| LR 9013-1(I) | Caption example: the court and division, the debtor's name as in the petition, the motion number, and the Movant / Respondent / Trustee designations | `caption()`; the designations are whatever the frontmatter gives (the sample uses the adversary style: Plaintiffs / Defendants) |
| LR 5005-3(C); LR 7001-1(C)(3) | Letter size; top margin of not less than 1 1/2 inches; multi-page papers fastened at the top | `top-margin = 1.5in` |
| LR 5005-3(A); LR 7001-1(C)(1) | Legibility; one side of the paper | text output |

Not verified in this box: FRBP 7012 and 7056 (motions in an adversary proceeding), and the court's Administrative Procedures for electronic filing (LR 5005-4). The template does not depend on them.

Conventions the template follows that no rule above fixes (tier 2): 12 pt EB Garamond (vendored); double spacing (24 pt pitch); one-inch side and bottom margins; page number centered in the footer; headings numbered I., A., 1., a. (the exemplar's pattern); footnotes at the default footnote size; "Respectfully submitted" in the signature block.

### Finding: the local rules do not require a memorandum

The brief for this unit said the motion is "with memorandum, per this court's local bankruptcy rules". The 2025 local rules text does not say that. LR 9013-1 requires grounds stated with particularity and the relief sought, a proof of service, and a response procedure (M), but no memorandum. The only other "memorandum" in the text is in LR 2090-1 (foreign attorneys), which asks a pro se party for a notice address. The template therefore does not require a memorandum: the memorandum is the body text after the motion's numbered paragraphs, as in the exemplar. This is recorded as a finding, not as a rule. If a judge's order or a standing procedure requires a separate memorandum, the template's body can be split into two documents; nothing else in the template changes.

No page limit was found in the 2025 text.

## Overlay

`usage/OVERLAY-thomas-midland-motion-to-dismiss.pdf` puts our render (red) over the filed exemplar page with the most shared words (blue). Pairings from the last run (word overlap):

- Sample p.1 ↔ filed p.2 (45.2%): ours is the caption and first paragraph; the filed p.1 is the caption with counsel block above the title, which the overlay pairs with our p.1 only weakly. Expected: the counsel block is at the signature page in ours (LR 9013-1(C)).
- p.2–p.8 ↔ filed p.2–p.8 (35–68%): the same paragraphs in the same places. Page 8 (the end of paragraph 12, the Conclusion and the prayer) pairs at 35.5%; the filed page with the same text is not the same page layout.
- p.9 ↔ filed p.18 (42.8%): the signature block. On the filed document, the WHEREFORE clause and signature block are on PDF page 18 (the filed footers number body pages one less than the PDF page).
- p.10 ↔ filed p.19 (89.4%): the certificate of service.

Diagnostic only, not a score.

## Page review (Gate 2)

Every page of `OUTPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.typst.pdf` was rendered at 60 dpi and viewed (10 of 10). The first pass showed a caption defect (the Chapter and Case No. lines were in one column and did not line up with the debtor they belong to) and the certificate of service defects below; those were fixed, pages 1–8 re-compared as text (unchanged), and pages 9–10 re-rendered and re-viewed.

| Page | Content | Result |
|---|---|---|
| 1 | Court title (Harrisonburg Division); caption with both debtor cases paired with their chapter and case numbers; title; paragraph 1 | OK after fix: each debtor's chapter and case number sit on the same row as the debtor. |
| 2 | Paragraph 2; heading I (hanging I., bold); paragraph 3 begins | OK. |
| 3 | Paragraph 3 (end), paragraph 4, heading A | OK. |
| 4 | Paragraph 5, paragraph 6, paragraph 7 begins | OK. Citations italic; "Id." italic. |
| 5 | Paragraph 7 (end), paragraph 8, paragraph 9 begins | OK. |
| 6 | Paragraph 9 (end), paragraph 10; footnote 1 at the foot | OK. |
| 7 | Paragraph 11; paragraph 12 begins | OK. |
| 8 | Paragraph 12 (end); heading "Conclusion"; paragraph 26; WHEREFORE | OK. |
| 9 | Dated line; counsel block lower left; "Respectfully submitted" block | OPEN: the signature block is alone on this page; no text of the body is on it. The last body text is on page 8. A court filing should not have a signature page with no text. The fix (keep the last paragraph with the signature block) is not implemented: the template cannot tell which chunk is the last body paragraph without the sample marking it. |
| 10 | Certificate of service: five party groups; "/s/ James Donaldson" | OK after fix: the signer's name is no longer printed twice; party groups are separated. |

Typst printed no warnings. Fonts embedded: EB Garamond Regular, Bold and Italic only.

## Known gaps

1. **Signature block alone on page 9 (OPEN).** See the Gate 2 table. The fix is to keep the body's last paragraph with the signature block, which needs a marker in the sample or a template rule; not done.
2. **Notice of hearing and response (LR 9013-1(D), (H), (M)).** The hearing date, the notice, and the seven-day response rule are not generated. Under LR 9013-1(H) the hearing notice and certification are a separate filing made within seven days after the hearing date is set.
3. **Counsel placement.** The filed motion sets counsel's block at the top of page 1 under the title; the template follows LR 9013-1(C) and LR 7001-1(C)(4) and puts it on the signature page, lower left. Tier-2 difference, accepted because the rule governs.
4. **Exemplar excerpt.** The sample transcribes paragraphs 1–12 and 26 of the 26-paragraph motion; the filed document is 19 pages and the sample renders to 10. Paragraphs 13–25 and footnotes 2–3 are not transcribed. Paragraph numbers in the sample jump from 12 to 26 (the list starts at 26).
5. **Sub-headings in the exemplar.** The text layer does not show whether a bold line is a heading or the first sentence of a numbered paragraph (for example, paragraphs 7 and 12 in the filed text). The sample therefore carries those lines as paragraph text, not as level-4 headings. Visual check of the filed page would settle it; not done in this box.
6. **Contested-matter caption.** The template draws the LR 9013-1(I) caption with Movant, Respondent and Trustee designations and a motion number, but no sample exercises it: no contested-matter motion with a stored, text-based PDF was found.
7. **One filer, one exemplar.** Tier-2 conventions were judged against this one filing (Spotts Fain PC for Midland). The brief's usual 2–3 exemplars from different filers were not found.
8. **Typeface.** Face required: none. The W.D. Va. Local Rules (2025 text, read again 2026-10-14) name no typeface; the only font rule is LR 1007-2(F), a 12-point minimum for a pro se debtor's creditor list, which this template does not produce. FRBP 9004(a) requires only that a paper be "clearly legible". The filed motion embeds Times New Roman, but a filer's choice is not a rule. Vendored substitute: none needed; `EB Garamond` stays (`docs/FONTS.md`: a court that names no face keeps EB Garamond), set at 12 pt, which meets the LR 1007-2(F) minimum. Fit: n/a. Fonts pass (fb-595.7.5): template unchanged, so the render is still 10 pages.

## Engines

- **typst** (primary): as above.
- **docx**: `docx/build-reference.sh` builds `docx/reference.docx` (pandoc's default reference, its styles replaced, PAGE footer, letter page with a 1.5 in top margin); `docx/vawb-motion-brief.lua` writes the court title, the two-debtor caption, the title, the signature block and the certificate of service as Word paragraphs and tables, and the numbered paragraphs and the I. / A. / 1. / a. headings as text with a hanging indent. Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.md` (LibreOffice PDF).
- docx matches the typst form: EB Garamond 12 pt (embedded as EBGaramond in the PDF); body double spaced at an exact 24 pt pitch; one-inch sides and bottom; caption with the debtors paired with their chapter and case numbers, the bordered party column and the adversary numbers; numbers at 0.5 in; headings I. / A. / 1.; footnotes at 10 pt; page number centered 10 pt; counsel block lower left; certificate of service after the signature.
- docx differs from typst in one place: the last body paragraph (the WHEREFORE clause) is kept with the signature block (keepNext). The typst PDF leaves the signature block alone on page 9 (Gate 2 OPEN row); the docx has no such page. Pagination otherwise matches: 10 pages in both. Footnote 1 falls on page 7 in the docx and page 6 in typst.
- docx BLOCKED: none for the form. `tools/check.sh --engine docx` cannot run on this folder: it needs `court.json` and `checks.yaml` in the court directory, and neither exists yet for `vawb` (the Gate 1 rules are not written). So no check ID is measured for docx; the visual review was done by hand on all 10 docx pages and all 10 typst pages.
- Word was not available: the .docx was opened and converted by LibreOffice only.
