# N.D. Okla. Bankruptcy Court (oknb): motion with memorandum

Doc type: **motion with memorandum** (a contested-matter motion under FRBP 9013/9014, with the memorandum of law in the same filed document, and the notice of opportunity for hearing under LBR 9013-1(B)). Court: United States Bankruptcy Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief/`.

Status: **exemplar=yes**, render=ok, overlay=ok, pages reviewed 10 of 10 (every page rendered at 70 dpi and viewed). Nothing here sets a court-level `court.json` status.

## Governing rules

Dates: the local rules were read from the PDF on the court's site (cover: "Updated March 21, 2025"); FRBP 9013 and 9004 were read from Cornell LII on 2026-10-14. Rules not listed in the table (FRBP 4003(d), 9006(f), 9014, 5005-1(E) text, 11 U.S.C. §§ 101(36), 522(b), 522(f)(1)(A), 522(f)(2)(A), Fed. R. Bankr. P. 9015 etc.) were **not re-fetched** this session; they are cited from the author's knowledge and must be checked before this folder is treated as complete. Note LBR 9013-1(B) quotes its prescribed statement; the template reproduces it from the local rules PDF.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| OKNB-MOT-001 | Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013), read 2026-10-14 | A request for a court order is made by written motion, which states its grounds with particularity and specifies the relief sought. | the motion itself (sample `# Relief Requested`) |
| OKNB-MOT-002 | LBR 9013-1(A)-(B) (court's local rules PDF, Updated March 21, 2025) | A motion for which the Code permits but does not require a hearing carries the words "And Notice of Opportunity for Hearing" in its title and the prescribed NOTICE OF OPPORTUNITY FOR HEARING statement in its body, with the response period (14 days where no period is prescribed, including the 3 mailing days of FRBP 9006(f)). | `title` check (asserts the phrase when `notice_of_opportunity: true`); `notice-block` (prescribed text, `response_days`) |
| OKNB-MOT-003 | LBR 9013-1(D)(6) | The notice procedure does not apply to Part VII (adversary) requests, except a motion to dismiss a complaint objecting to discharge (LBR 7041-1). | why this sample is a contested matter (§ 522(f) lien avoidance, FRBP 4003(d)), not an adversary motion |
| OKNB-MOT-004 | LBR 9013-1(G)(2), LBR 5005-1(E) | Motions are served on parties not registered for ECF by mail within two days of filing, and a certificate of service is filed within seven days. | `certificate-block` (served list from frontmatter) |
| OKNB-MOT-005 | LBR 7007-1(A) | A brief in an adversary proceeding is not to exceed 20 pages. This is an adversary-proceeding rule. No page limit for a contested-matter motion was found in the local rules read. | not enforced; no page counter (see gaps) |
| OKNB-MOT-006 | LBR 9004-1(A) | 8 1/2 x 11; no less than 12-point font including footnotes; margins at least one inch; one side; pleadings and briefs double spaced. | `type-size` 13pt; `margin` 1in; `body-leading` 1.35em (2.0em pitch); footnote size = `type-size` |
| OKNB-MOT-007 | LBR 9004-2(A) | Caption: court name, title of the case, bankruptcy case number and adversary number (if any), the chapter number directly under the case number, and a title that describes the document. | `court-title`, `caption`, `title-block`; adversary number printed only when given |
| OKNB-MOT-008 | LBR 9004-1(C), LBR 9011-1 | Attorney signature block: full name, state bar number, address, email, telephone, fax if any, and the party represented. | `signature-block` (asserts `bar_number`, `telephone`, `email`) |
| OKNB-MOT-009 | FRBP 4003(d) (not re-fetched) and FRBP 9014 (not re-fetched) | A motion to avoid a lien under 11 U.S.C. § 522(f) is a contested matter under Rule 9014, commenced by motion. | the sample's `# Argument` and `# Relief Requested` text |

## Typeface

LBR 9004-1(A) (court's local rules, "Updated March 21, 2025"; the rule text as quoted on courtrules.net, checked 2026-10-15) requires no less than 12-point font, footnotes included. It names no typeface. Under `docs/FONTS.md` ("No face named"), the template keeps **EB Garamond** (vendored, OFL 1.1). Face required: none. Substitute: none needed (EB Garamond is the default). The exemplar (docket 409, 2025) names Times-Roman (base-14, not embedded, per `pdffonts`); that is the filer's choice, not a rule, and it is not a reason to switch.

## Exemplar

`usage/SAMPLE-oknb-motion-brief-okf2411060.pdf`: the **amended joint motion** of OKF, LLC (debtor in possession) and the Official Committee of Unsecured Creditors to surcharge under 11 U.S.C. § 506(c) and exclude fees from a secured claim, with the NOTICE OF OPPORTUNITY FOR HEARING, in *In re OKF, LLC*, Case No. 24-11060-T, Chapter 11. Docket 409, entered September 15, 2025. 15 pages, text-based (4,257 words extract). Counsel: Crowe & Dunlevy (Craige, Sokolosky) for the debtor; Bernstein-Burkley (Kallergis) for the committee. Source, searches and rejected candidates (two scanned motions, one Chapter 15 stay motion) are in `usage/SOURCE.md`.

Only one exemplar from this court, from one filer (the joint filing counts as one). Tier 2 is therefore judged against this filing and the rules, not against two or three filers.

## Sample

- `usage/INPUT-oknb-motion-brief-sample.md` is a **transcription of an excerpt** of the exemplar (not synthetic). Its frontmatter says so. Names, numbers and facts are the filers', as filed.
- The filing is 15 pages. The sample keeps the caption, the report on the sale (Section I), the equities (Section II), the surcharge (Section IV in the filing, Section III in the render), the prayer, the signature block and the certificate. **Section III of the filing (paragraphs 12-22, filing pages 6-10) is omitted** and the body says so in a bracketed note; it is not paraphrased. This keeps the render at 10 pages, inside the 8-14 page target for an exemplar of that length.
- The notice of opportunity, the caption, the title and the signature block are generated from the frontmatter. The title is the filing's, with "And Notice of Opportunity for Hearing" appended as LBR 9013-1 requires.
- Naming: `INPUT-oknb-motion-brief-sample.md` / `OUTPUT-oknb-motion-brief-sample.typst.pdf` / `OVERLAY-motion-brief.pdf` and `.txt`, as the tools read and write them.

### Where the transcription departs from the filing

1. **Excerpt.** Section III is omitted (see above). The filing's Section IV is rendered as Section III, and the prayer as Section IV. The filer's paragraph numbers (1-11, then 23-29) are typed as written, so the numbers jump at the omission.
2. **Signature.** The template's signature block takes one signer. The filing is joint: Craige and Sokolosky for the debtor, and Kallergis for the committee. The sample carries Craige and the firm, with the joint movants named in the `for` line; the second counsel block is not reproduced (see gaps).
3. **Certificate.** The filing's certificate is an electronic-service certificate with no served list. The sample passes an empty `served` list. The template now omits "on the parties listed below" in that case (see fixes).
4. **Footnote 4** (after "$3,500,000" in ¶ 27) has no text in the PDF's text layer. The sample has no footnote there and the gap is noted here.
5. **Level-1 headings** are typed in title case. The filing's headings are in capitals. See fixes and gaps.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief usage/INPUT-oknb-motion-brief-sample.md
sh tools/overlay.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief motion-brief
```

- render: **ok**. `usage/OUTPUT-oknb-motion-brief-sample.typst.pdf`, 10 pages, 612 x 792 pt. typst emitted no warnings (render.sh fails on any). Fonts: EBGaramond-Regular, -Bold and -Italic, embedded. No system or fallback font after the backtick fix (a stray backtick had pulled in DejaVu Sans Mono).
- overlay: **ok**. The filed PDF is not in this checkout; it was fetched from the RECAP URL in `usage/SOURCE.md` to a scratch directory (15 pages, matching the record) and passed to `tools/overlay.sh` as its third argument. `usage/OVERLAY-motion-brief.pdf` and `.txt` written. Word overlap per page as the tool reports it: ours p.1 vs filed p.13 51.6%; p.2 65.4%; p.3 54.1%; p.4 51.8%; p.5 53.9%; p.6 vs filed p.10 39.7%; p.7 vs filed p.11 46.7%; p.8 vs filed p.12 43.2%; p.9 vs filed p.12 40.9%; p.10 vs filed p.15 25.0%. The overlay is a diagnostic, not a score. The pairing of pages is the tool's, and the page numbers do not line up one to one because of the omission.

## Visual review (Gate 2, all 10 pages rendered at 70 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, Case No., Chapter 11), title ("…And Notice of Opportunity for Hearing"), the prescribed NOTICE box, the response-time paragraph, the opening paragraph | OK. Notice box reads as LBR 9013-1(B) prescribes, with 14 days from `response_days`. |
| 2 | I. Report on the Sale ¶¶ 1-3 (lead-in to table); footnote 1 | OK. Footnote 1 attaches to ¶ 3. The table moves to page 3 as one block, leaving white space at the foot of page 2 (a choice: the table is kept together). |
| 3 | Payoff table (single-spaced, one block), ¶¶ 4-5, block quotation | OK. Table is single spaced and not split. |
| 4 | II. The Equities of the Case… ¶¶ 6-7, footnote 2 | OK. The heading is in title case (see gaps). Citations are not altered. |
| 5 | ¶¶ 8-10 | OK. |
| 6 | ¶ 11; bracketed omission note for Section III; III. Surcharge… heading; ¶ 23 (begins) | OK. The omission note gives filing pages 6-10. The heading number is III in the render; the filing's is IV (see gaps). |
| 7 | ¶ 23 (continues), ¶ 24; footnote 3 | OK. Footnote 2 attaches at "$47,747." |
| 8 | ¶¶ 25-28 | OK. |
| 9 | ¶ 29; IV. Prayer for Relief; signature block | OK. The signature block sits with the prayer on this page. |
| 10 | Certificate of Service | OK. One "/s/" line; the ECF sentence; no served list. |

## Fixes made during this pass

1. **Citations in Level-1 headings.** The template uppercased level-1 headings, which turned "11 U.S.C. § 506(c)" into "§ 506(C)" in the heading. Level-1 headings now keep the case written (bold, centred). This is a choice: the filing's headings are in capitals, and the template no longer reproduces that.
2. **Tables.** Table text was double spaced and the payoff table broke across pages 2 and 3. Tables are now single spaced and kept in one block.
3. **Certificate signature.** The certificate printed the signer's name twice (`/s/ Name` and `Name`). It now prints `/s/ Name` only, as the filing does.
4. **Certificate with no served list.** The sentence said "on the parties listed below" with no list beneath it. The clause is now omitted when `served` is empty.
5. **Footnote reference on its own line.** A footnote reference that stood alone in a paragraph was dropped from the render (footnote 1 was missing). The reference now sits at the end of the paragraph before the table (transcription fix; the template's handling of a lone reference is not investigated).
6. **Stray backtick.** Typed backticks pulled in a monospace font. The filer's quotation marks are now escaped in the sample.

## Known gaps and open choices

1. **Joint signature** (OPEN, tier 2): the signature block takes one signer. The second debtor's counsel and the committee's counsel are not in the render. A joint-motion signature block needs a list of signers in the template.
2. **Excerpt** (documented): Section III is omitted; the render numbers the surcharge section III where the filing numbers it IV.
3. **Heading case** (choice): Level-1 headings are in title case, not capitals. The filing's capitals are a convention, not a rule. Revisit if the clerk's standing orders require capitals.
4. **Footnote 4** (documented): no text in the filing's text layer; not reproduced.
5. **Page limit:** not counted. LBR 7007-1(A) caps briefs in adversary proceedings at 20 pages; no page limit for a contested-matter motion was found in the local rules read. Not checked by the template.
6. **TOC and TOA:** not generated. No oknb local rule found requires them. The filing has neither.
7. **Proposed order:** not generated. LBR 9013-1(B) addresses a request for entry of an order after the response period; the proposed order is a separate document.
8. **Declaration of value:** the filing does not attach one and the template does not generate or check one; the author attaches it where a motion's value depends on schedules.
9. **Certificate method:** the template states CM/ECF service in its certificate sentence. The author confirms that every party is registered before using an ECF-only certificate.
10. **Response period:** `response_days` is the author's calculation (LBR 9013-1(B): 14 days where no period is prescribed, including FRBP 9006(f)'s 3 mailing days; add to a prescribed period unless hand-delivered). The template does not compute it.
11. **Bracketed text in the notice:** "[and others who are required to be served]" is reproduced from the local rule's form with its brackets, as the rule prints it. The author deletes the brackets and the words, or keeps them, per the notice's filing.
12. **Font:** EB Garamond (vendored, OFL) at 13 pt, not Times New Roman. 13 pt because EB Garamond sets small at 12; both meet the LBR 9004-1(A) floor. A choice; the court's rule names no font (see Typeface).
13. **Statute and rule text** not re-fetched (see governing rules): § 522(f)(1)(A), (f)(2)(A), § 101(36), FRBP 4003(d), 9006(f), 9014. Check before this folder is treated as complete.

## Engines

**docx** (`docx/reference.docx`, no Lua filter; built from pandoc's default reference by a scratch script).

- Matches the typst form: US Letter, 1 in margins on all sides, EB Garamond 13 pt body, footnote text 13 pt, body and headings on an exact 26 pt (double) line, block quotes and footnotes single spaced, level-1 headings bold and centred in the case written (not capitals), level-2 bold with a 0.5 in hanging indent, level-3 bold italic with a 0.5 in hanging indent, page number centred in the footer, table cells with a full single-rule grid, single spaced. No line numbers or rules.
- Differs: pandoc writes only the markdown body. The caption, the court title block, the notice of opportunity for hearing box (LBR 9013-1(B)), the generated response-time paragraph, the signature block and the certificate of service are produced by the typst template from the frontmatter and are **not** in the docx. Tables are pandoc tables, so column widths and cell padding follow pandoc, not the typst grid. Lists use pandoc's numbering, not the typst `(a)` form. This docx is therefore not a filable motion yet.
- BLOCKED: `docx.pdf` and Gates 0-1 on the LibreOffice PDF: `soffice` is not installed on this box and cannot be installed here.
- BLOCKED: visual review of the docx pages: 0 docx pages viewed (only the typst pages were rendered and reviewed).
- BLOCKED: `tools/render-docx.sh` stops at its `unzip -tq` step because `unzip` is not installed on this box (the failure is reported as "not a valid zip"); the `.docx` itself is written before that step and was checked with libzip `ziptool` and `xmllint` (all 17 XML/rels parts well-formed).
- Not done: opening the `.docx` in Word or LibreOffice for the no-repair check; the Word pagination of the body.
