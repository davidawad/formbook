# W.D.N.C. Bankruptcy Court (ncwb): adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding, opened by a complaint). Court: United States Bankruptcy Court, Western District of North Carolina (Charlotte Division in the exemplar). Folder: `courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/adversary-complaint/`.

Status: exemplar=yes (one filing; tier-2 needs two or three, see gaps), render=ok, overlay=ok, pages reviewed 8 of 8 (every page rendered at 60 dpi and looked at). Nothing here sets `status` in `court.json`.

## Governing rules

All text read 2026-10-14. The federal rules are from the Legal Information Institute (LII) pages, which show the restyled text effective December 1, 2024; the local rules are from the court's posted PDF, extracted with `pdftotext`.

| ID | Source (URL, rule) | Requirement | Where it lives |
|---|---|---|---|
| NCWB-PLEAD-001 | FRBP 7001, https://www.law.cornell.edu/rules/frbp/rule_7001 | Defines which proceedings are adversary proceedings, including "a proceeding to obtain a declaratory judgment related to" the other listed proceedings (paragraph (i) in LII's lettering). The exemplar's count I cites Rule 7001(9); that is the exemplar's citation, kept as transcribed. | Count I text (sample) |
| NCWB-PLEAD-002 | FRBP 7008(a), https://www.law.cornell.edu/rules/frbp/rule_7008 | Rule 8 applies. The jurisdiction allegation must name the case (name, number, Code chapter) and the district and division. A complaint in an adversary proceeding must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | Not enforced by the template (content). See gap 3. |
| NCWB-PLEAD-003 | FRBP 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 | Rule 10 applies; the caption must "substantially conform to" Official Form 416. | `caption()` in the template: debtor box, then adversary box, with `Adv. Proc. No.` |
| NCWB-PLEAD-004 | FRBP 9004(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9004 | Legible (9004(a)). Caption sets out: the court's name; the case's title; the case number and, if appropriate, the adversary-proceeding number; a brief designation of the document's character (9004(b)). | `court-title()`, `caption()`, `title-block()` |
| NCWB-LR-001 | W.D.N.C. Bankruptcy Local Rules, Sept 2021 (PDF: https://www.ncwb.uscourts.gov/sites/ncwb/files/WDNC%20Bankruptcy%20Local%20Rules%20Sept%202021.pdf), LR 7003-1, p. 77 | "All complaints initiating adversary proceedings ... shall be accompanied by Official Bankruptcy Form B 1040 ('Adversary Proceeding Cover Sheet')." | Not generated. A separate filing; it is not part of this PDF. |
| NCWB-LR-002 | Same PDF, LR 9013-2(a), p. 96 (briefs; applied here as a convention, see below) | 12-point minimum font; double-spaced; one-inch margins on all sides; numbered pages; 25-page limit. The rule is written for briefs, not complaints. The template applies the same type, margin and spacing to the complaint so that it matches the exemplar's look. | `type-size`, `margin`, `double`, page numbers |

Paper size: the local rules are silent on paper size (checked: no "8 1/2" rule found). Letter is used. Not a rule.

Typeface: face required by the rules: **none**. LR 9013-2(a) says only "the font size is a minimum of 12 point"; no face name appears anywhere in the Sept 2021 local rules text (checked 2026-10-14). Substitute: none needed, so the template keeps **EB Garamond** (`docs/FONTS.md`: a court that names no face keeps EB Garamond). Fit: n/a. The Times New Roman in the filed exemplar (by name, not embedded) is exemplar evidence, not a rule.

Rules not used here, with reasons: LR 9013-1(c) (certificate of service) applies to pleadings served on a party; the complaint is served with a summons under FRBP 7004, and the exemplar carries no certificate. The template generates a certificate only if the frontmatter has a `service` block, and this sample has none.

## Exemplar

- `exemplars/FILED-EXAMPLE-providence-gcc-chase-16-03271-adversary-complaint.pdf`: Adversary Complaint for Declaratory Judgment and Injunctive Relief, *Providence Real Estate Venture, LLC v. GCC-Chase, LLC, et al.*, Adv. Proc. No. 16-03271 (Bankr. W.D.N.C., Charlotte Division). 15 pages, Doc 1, filed May 4, 2016 by the plaintiff.
- Provenance and searches: `exemplars/SOURCE.md`.
- Fonts in the exemplar: TimesNewRoman, Times-BoldItalic and Courier, not embedded. The exemplar is in Times at 12 point.

## Sample

- `samples/INPUT-gcc-chase-16-03271.md` transcribes the exemplar's caption, counsel block, opening paragraph, ¶¶ 1-20 (parties, jurisdiction, venue, core proceedings), a bracketed note that ¶¶ 21-56 (general allegations) are omitted, Count I (¶¶ 57-71), Count II (¶¶ 72-84), both prayers and the signature block. Text is verbatim, including the exemplar's own slips (for example "if Defendants' do not cease" in ¶ 80, and no period after "Purchase Agreement" in ¶ 84).
- Frontmatter drives every case word: `court`, `district`, `division`, `debtor`, `adversary`, `caption.parties`, `title`, `signature`.
- Page-map note: the template numbers nothing. The author types the paragraph numbers (escaped as `1\.` so they are not read as list markers), so the numbers in the sample are the exemplar's own.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/adversary-complaint samples/INPUT-gcc-chase-16-03271.md
sh tools/overlay.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/adversary-complaint gcc-chase-16-03271
```

- `samples/OUTPUT-gcc-chase-16-03271.pdf`: 8 pages, letter. Compiled with no typst warnings (`render.sh` fails on any). `pdffonts`: EBGaramond-Regular, -Italic, -Bold, all embedded. No system fonts.
- `samples/OVERLAY-gcc-chase-16-03271.pdf` and `.txt`: red = our render, blue = filed exemplar, black = both. Page map from the tool: ours p.1, 2, 3 pair with filed p.1, 2, 3 (word overlap 70.5%, 65.7%, 48.9%); ours p.4-8 pair with filed p.11-15, which is correct for the text transcribed (Count I and II), but the filed pages 4-10 (¶¶ 21-56) are absent from our sample, so the overlay shows missing text there, not a rendering difference. The overlay is a diagnostic, not a score.
- File names: the brief asked for `samples/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, and the brief's own tools use those names, so the repo's naming (`INPUT-`, `OUTPUT-`, `OVERLAY-`) is followed.

## Visual review (Gate 2 record; all 8 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, Form 416-style caption (debtor box with Case No. and Chapter; adversary box with Adv. Proc. No.), title, opening paragraph, first heading | OK after two fixes: the court title and caption stacks overlapped (paragraph and stack spacing set to 0 pt; now the leading), and the heading overlapped the paragraph under it (EB Garamond's line box is shorter than its glyphs; headings now get vertical inset). |
| 2 | ¶¶ 2-11 | OK. Paragraph indent and spacing consistent. |
| 3 | ¶¶ 12-20, note on the omitted paragraphs, Count I heading | OK. The italic note is a transcription marker, not exemplar text. |
| 4 | ¶¶ 58-67 | OK. |
| 5 | ¶¶ 68-71, WHEREFORE (Count I), Count II heading, ¶¶ 72-75 | OK. |
| 6 | ¶¶ 76-83 | OK. |
| 7 | ¶ 84, WHEREFORE (Count II), date and first signature block | OK. The prayer keeps its first-line indent. |
| 8 | Remainder of the second signature block | Known layout: the signature block runs from page 7 onto page 8 (two firms' blocks are taller than the space left). Fits within the margins. |

## Known gaps and open choices

1. **Tier-2 exemplars (one only).** The eval loop asks for two or three filings from different filers. Only one was used. Searches tried: web search for "Western District of North Carolina bankruptcy adversary proceeding complaint pdf" (no complaint PDFs; calendars, local rules and one appellate judgment); CourtListener RECAP search (`https://www.courtlistener.com/api/rest/v4/search/?type=rd&court=ncwb`, query "complaint adversary"; 589 results, the first page read). Candidates from that page: Wilson, 24-01002 (WBL SPO I v. Wilson, 78 pages, too long); McCoy/Ace Motor, 18-03036 (51 pages); Jacobs, 15-03182 (7 pages, a different pleading form, by Gray Layton Kersh et al.; a possible second exemplar for tier 2, not yet downloaded and checked for filer or form); Power Home Solar, 24-03072 (its complaint, doc 1.0, is on RECAP but was not downloaded; the file the search returned for doc 1 was the cover-sheet attachment, 1.1). A second and third filing still need to be found.
2. **§ 7008(a) consent statement is missing from the exemplar.** The filed complaint says the counts are "core proceedings" (¶ 20) and says nothing about consent to final orders, which FRBP 7008(a) requires. The sample reproduces the exemplar as filed. Tier-1 (court-mandated) content, so this needs David's call: either add a consent paragraph to the sample (and treat the exemplar as non-compliant) or record it as an accepted difference. The template does not write this content.
3. **§ 7008(a) jurisdiction allegation is partial in the exemplar.** The exemplar's ¶¶ 16-19 do not recite the case name, number and Code chapter together, or the district and division; the caption carries the case number and chapter, and the court title carries the district and division. Recorded as a Gate 2 finding, not fixed in the template.
4. **Font.** The rules name no face (see Governing rules), so the template keeps EB Garamond (vendored, OFL), at 12 point. The exemplar is Times New Roman (by name; not embedded). EB Garamond sets smaller than Times at the same point size, so a clerk could read the page as smaller type; the rule's floor is point size, so the render is compliant on the rule's terms. A Times-style substitute (Liberation Serif) would match the exemplar's look but is a convention, not a rule requirement; a typeface choice for David.
5. **LR 7003-1 cover sheet** (Form B 1040) is required with the complaint and is a separate filing. Not generated.
6. **Local rules currency.** The Sept 2021 PDF is the latest posted version I could find; I did not check whether there is a later one. FRBP text is the LII version effective December 1, 2024; I read 7001, 7008, 7010 and 9004 through the LII summaries, not the full PDF of the rules.
7. **Form 416 text** was not fetched; the caption follows the exemplar's layout and the rule's required elements.
8. **ECF header** ("Case 16-03271 Doc 1 Filed ...") is added by CM/ECF on filing and is not reproduced.
9. **Caption layout.** The exemplar uses a ")" column; the template uses drawn rules (no measured coordinates, no forced line breaks).
10. **Signature block** runs across pages 7-8 (see the review table).
11. **Exemplar typos** are transcribed as filed, not corrected.

## Engines

Typst (`typst/`) is the reference. The docx engine is built here (`docx/`: `reference.docx` from `make-reference.sh`, and `ncwb.lua` for the caption, signature block and page layout). The latex engine is not built for this folder.

| Engine | Output (`samples/`) | Status |
|---|---|---|
| typst | `OUTPUT-gcc-chase-16-03271.pdf` (8 pp) | reference |
| docx | `OUTPUT-gcc-chase-16-03271.docx` (16 KB) and `OUTPUT-gcc-chase-16-03271.docx.pdf` (LibreOffice, 10 pp) | ok: converted without error; all 10 pages of the `.docx.pdf` rendered at 60 dpi and looked at, and typst pages 1 to 8 looked at beside them |

Rebuild and render: `sh docx/make-reference.sh`, then `sh tools/render.sh --engine docx <this folder> samples/INPUT-gcc-chase-16-03271.md`.

- *Matches typst:* US Letter; one-inch margins; EB Garamond 12 pt only (`pdffonts`: EBGaramond Regular, Bold and Italic, all embedded); body double-spaced at exact 24 pt, half-inch first-line indent, 16 pt after each paragraph (the typst paragraph spacing); headings centered and bold (levels 1 and 2), level 3 bold; the court title, the two-box caption with its rules and "Adv. Proc. No.", the title; the signature block (Dated on the left, the lines from 2.8 in); a centered page number on every page.
- *Differs (tier 2, not chased):* body line breaks fall at other words in LibreOffice, so page breaks fall at other paragraphs: 10 pages against typst's 8. Page 1 ends before the first numbered paragraph (the "PARTIES" heading moves with ¶ 1). The signature block runs from page 9 onto page 10, where eight lines stand alone; typst breaks its block between pages 7 and 8. The caption rules are table borders, which Word may draw slightly differently (not checked in Word).
- *Not built:* nothing the typst form has. The complaint has no certificate of service (no `service` block in the sample), as in typst.
- *Word:* not opened in Word (not installed on this box). Checked: `unzip -tq` is clean, every XML part passes `xmllint --noout`, no style ID is defined twice, and LibreOffice converts the file without error. The no-repair check in Word is not done.
- *Exemplars:* the filed exemplar this README cites is not in `exemplars/` in this checkout (only `SOURCE.md` is there), so the docx is judged against the typst render only, not against a filed exemplar.
- *BLOCKED:* none. Every mandated element above renders; the open items are tier 2 or the Word check.

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md) | [Motion sibling](../motion-brief/README.md)
