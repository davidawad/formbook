# njb: motion-brief

Doc type: **memorandum of law in support of a motion** (FRBP 9013; D.N.J. LBR 9013-1) in the United States Bankruptcy Court for the District of New Jersey (`njb`).
Folder: `courts/third-circuit/new-jersey/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-njb-motion-brief-cushing2601099.pdf` (1 filer; see `usage/SOURCE.md`). Its pages 1 and 2 are a notice of motion, not a brief; the brief runs on pages 3 to 13 |
| sample md | `usage/INPUT-njb-motion-brief-cushing.md` (excerpt of the combined response and motion: caption, preliminary statement, facts, legal standard, res judicata, Rooker-Feldman, conclusion, signature; see Known gaps) |
| typeface | face required: none. Substitute: none needed; EB Garamond (`docs/FONTS.md`, "No face named"). Metric: n/a. Checked 2026-10-15 against the D.N.J. Local Bankruptcy Rules package (as posted, 2025): no typeface or point-size text in it, and LBR 1001-1's 2015 comment says an unincorporated Local Civil Rule does not apply. Judges' preferences (Judges' Info tab) were not checked. |
| render | ok: `usage/OUTPUT-njb-motion-brief-cushing.typst.pdf`, 8 pages, typst 0.15.0, embedded fonts EB Garamond only (`pdffonts`), no warnings (re-rendered 2026-10-15) |
| overlay | ok: `usage/OVERLAY-cushing-motion-brief.pdf` and `OVERLAY-cushing-motion-brief.txt` (re-run 2026-10-15) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed on 2026-10-15; the only later edit is a comment in the template, and the text of the render is unchanged) |

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf/.txt`. The sample is `INPUT-<id>.md`.

## Governing rules

| Rule | Requirement | Where in the template |
|---|---|---|
| D.N.J. LBR 9013-1(a) | A motion or cross-motion consists of separate documents: (1) notice of motion with the date, time and place of the hearing; (2) certifications with the facts; (3) a memorandum of law stating the legal basis; (4) a proposed order; (5) the Local Form certification of service. Text from the NJB Local Rules package, https://www.njb.uscourts.gov/sites/njb/files/Local%20Rules%20Package.pdf (fetched 2026-10-14). | This template is item (3) only. Items (1), (2), (4) and (5) are not templated. |
| D.N.J. LBR 7007-1 | A factual certification is made under 28 U.S.C. § 1746, limited to personal knowledge, and may not be combined with legal argument. | Not in the template: the memorandum must not carry the facts that belong in a certification. |
| D.N.J. LBR 9004-1(a), (b) | Attorney block top left; the caption includes the chapter, the judge's initials and the applicable hearing date. | `caption()`: `counsel`, `chapter`, `judge`, and `hearing` (the template asserts that `hearing` is present). |
| FRBP 9004(a), (b) | Legible; caption with court, title, case and adversary number, and a designation of the document. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004, 2026-10-14. | `type-size`, `body-leading`, margins; `caption()`. |
| FRBP 9013(b) | A motion states its grounds with particularity and sets out the relief requested. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9013, 2026-10-14. | The template does not check the content. |
| D.N.J. LBR 1001-1 (2015 comment) | Judges' preferences (Judges' Info tab) and the court's General Orders and Guidelines also govern. | Not checked by the template. Font, length and page limits are not set by the bankruptcy rules. |

Not produced by this template: the notice of motion (LBR 9013-1(a)(1)), certifications (LBR 9013-1(a)(2)), proposed order (LBR 9013-1(a)(4)) and certification of service on the Local Form (LBR 9013-1(a)(5)). The exemplar's last pages are a certification of service, which is a separate document under the rule.

## Layout

- US Letter, one-inch margins, page number centered in the footer.
- Counsel block single-spaced at the top left; "Caption in Compliance with D.N.J. LBR 9004-1" (right); court name centered and bold; the caption (debtor block with the case number, chapter, judge and hearing date on the right; the adversary block with the adversary number on the right); the title centered and bold.
- No cover page: the body starts on page 1 under the caption, as in the exemplar.
- Headings: `#` centered bold caps; `##` bold left at body size; `###` bold italic left at body size. Each heading is kept with the paragraph after it.
- Paragraphs are indented 0.5 in and not numbered (memoranda of law in this court are not paragraph-numbered).
- Signature block: "Dated:" left, "Respectfully submitted," with the firm and `/s/` signer on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `counsel` (lines), `debtor` (lines), `case_no`, `chapter`, `judge`, `hearing` (required, e.g. `"Hearing Date: May 12, 2026, at 2:00 p.m."`), `adv_no`, `caption.parties` (list of `{names, designation}`), `title`, `date`, `signature` (`firm`, `signer`, `lines`), `lead_in` (optional).
- YAML items containing a colon must be quoted.
- Body: blank-line-separated chunks. `#`, `##`, `###` are headings; a `1.` list is rendered as a list; anything else is a paragraph; a chunk in square brackets is an editorial note of the transcription (centered, italic).
- Not supported: tables, footnotes, a table of contents (none is generated), raw typst.

## Known gaps and open choices

1. **Exemplar is a combined response and motion.** The RECAP search (`court=njb`, motions and memoranda filed 2026-02 to 2026-10) turned up mainly orders, reply briefs and attachments. The filing used here (Cushing v. Lakeview, adv. 26-01099, doc 7) is a combined response to a motion for default judgment and a motion to dismiss. BTG Pactual v. Barclays (26-01041, doc 46) is a reply in support of a motion under Rule 7012(b), 25 pages; it was checked and not used. An opening memorandum in support of a motion, filed by itself, is not in the exemplar.
2. **One exemplar.** Tier 2 of EVAL-LOOP asks for two or three filers. Only one was collected; tier 2 is **not** judged against two filers yet.
3. **Hearing date in the caption.** The exemplar's caption carries no hearing date, though its notice of motion gives one (May 5, 2026, corrected to May 12, 2026 at 2:00 p.m.). LBR 9004-1(b) requires the applicable hearing date in the caption of a document requiring a caption. The template follows the rule, so the sample's caption carries the corrected date. This departs from the exemplar on purpose.
4. **Typeface and size are a convention.** As for the adversary complaint: the bankruptcy rules set no typeface. The exemplar's body measures about 12 pt Times New Roman (word boxes). The template uses EB Garamond 14 pt because no rule in the package names a face (checked 2026-10-15; see the typeface row above), so `docs/FONTS.md` ("No face named") gives EB Garamond. Visually EB Garamond 14 pt is about the size of Times 12 to 13 pt; whether a larger face is needed is for David to decide.
5. **Excerpt.** The sample transcribes pages 3 to 13 of the filing in part. The bracketed notes mark the omissions: the Younger Doctrine argument (pages 6 to 8) and the Rooker-Feldman heading and pages 9 to 11 (the heading is not transcribed). Pages 12 to 13 (certification of service) are not transcribed.
6. **Filer's text kept as filed.** The sample keeps the filer's wording and citation forms as they appear in the text layer, including "Under 12A;3-301", "NJSA Title 12A", and the Bell Sussex and Lance v. Dennis citations as the filer wrote them (the sample was corrected once and then restored to the filer's text). These are the filer's errors, not template defects.
7. **Signature alone on the last page.** The conclusion and signature block fall on pages 7 and 8, and page 8 holds only the signature block. The template keeps the signature block unbreakable but does not keep it with the last paragraph. Courts are not bothered by this in practice, but it is a tier-2 finding that is left open.
8. **No table of contents.** The template does not generate one. The exemplar's combined pleading has none. Whether the court's judges expect one for a longer brief is a question for the judges' preferences (LBR 1001-1 comment), not a rule.
9. **Check scripts not run.** As for the adversary complaint: `tools/check.sh` is not run for this doc-type shape and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent.

## Review of the rendered pages (OUTPUT-njb-motion-brief-cushing.typst.pdf, 8 pages)

- Page 1: counsel block, court name, the LBR 9004-1 caption note, the debtor block (case number, chapter 13, judge, hearing date), the adversary block, the bold title and the lead-in. Nothing spills. Pass.
- Page 2: PRELIMINARY STATEMENT and the first paragraphs of STATEMENT OF FACTS. Pass.
- Page 3: Statement of Facts continued, including the Uniform Commercial Code paragraphs. Pass.
- Page 4: the end of the facts, LEGAL ARGUMENT, heading I and sub-headings A and B at body size. Pass.
- Page 5: standard of review (Rule 12(b)(6) continued, 12(h)(3)), heading "1." in bold caps and the start of the res judicata argument. Pass.
- Page 6: the entire-controversy paragraphs, the two bracketed notes, and the start of the Rooker-Feldman paragraph. Pass.
- Page 7: the Rooker-Feldman argument, CONCLUSION. Pass.
- Page 8: the signature block only (see Known gaps, item 7). Open, not accepted.

Overlay (`OVERLAY-cushing-motion-brief.txt`): page 1 pairs with the exemplar's page 3 (the first brief page) at 62 percent; pages 2 to 5 pair with exemplar pages 4 to 7 (41 to 65 percent); pages 6 to 8 pair with exemplar pages 8, 11 and 13 (27 to 44 percent, the excerpt skips pages). The overlay is a diagnostic, not a score.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/njb.lua`): pandoc on `reference.docx`. Matches the typst template: EB Garamond 14 pt, exact 25.2 pt line pitch and 9.8 pt paragraph gap (both measured on the typst output, not on a filed PDF), 0.5 in first-line indent on body paragraphs, 1 in margins on letter paper, 12 pt centered page number in the footer, bold centered 13 pt capital level-1 headings, bold 14 pt level-2 and bold italic level-3 headings, the caption (counsel block, court name, LBR 9004-1 note, caption tables with the right and bottom rules including the hearing line, bold title), the body directly after the title, bracketed notes centered and italic, signature block in a borderless table. Paragraphs are not numbered, as in the typst template.
- Differs from typst: cover and signature text is plain (italics in the frontmatter are dropped there); caption and signature rules are Word table borders, which Word and LibreOffice draw slightly differently; line breaks and page numbers may differ in Word from the typst pages.
- Not built on the docx: no TOC or TOA (none in this template); footnotes are not used by the template.
- BLOCKED: LibreOffice (`soffice`) is not installed in the build box, so `usage/OUTPUT-cushing-motion-brief.docx.pdf` cannot be produced, and the Gate 0 CONTENT, Gate 1 RULES, Gate 2 VISUAL REVIEW and Gate 3 GENERALIZATION checks cannot be run on it. No `checks.yaml` exists for `njb` yet, so there are no check IDs to list. Reason for every item: LibreOffice cannot run in the build box, so the .docx.pdf cannot be produced or checked. The `.docx` passes the zip and XML well-formedness checks; it has not been rendered or viewed.
