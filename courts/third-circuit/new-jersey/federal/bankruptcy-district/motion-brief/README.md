# njb: motion-brief

Doc type: **memorandum of law in support of a motion** (FRBP 9013; D.N.J. LBR 9013-1) in the United States Bankruptcy Court for the District of New Jersey (`njb`).
Folder: `courts/third-circuit/new-jersey/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`). Its pages 1 and 2 are a notice of motion, not a brief; the brief runs on pages 3 to 13 |
| sample md | `usage/INPUT-motion-brief.md` (excerpt of the combined response and motion: caption, preliminary statement, facts, legal standard, res judicata, Rooker-Feldman, conclusion, signature; see Known gaps) |
| typeface | face required: none. Times New Roman 14 pt, the house face (`docs/FONTS.md`, "No face named"), vendored, in typst and docx alike (was EB Garamond until fb-595.68.34). Checked 2026-10-15 against the D.N.J. Local Bankruptcy Rules package (as posted, 2025): no typeface or point-size text in it, and LBR 1001-1's 2015 comment says an unincorporated Local Civil Rule does not apply. Judges' preferences (Judges' Info tab) were not checked. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages; `OUTPUT-motion-brief.docx` and `.docx.pdf`, 10 pages, every line and page as typst (XENG-001..003 gated, `eval.yaml`; fb-595.68.34) |
| overlay | earlier render only (`just overlay` writes to the gitignored `.overlay/`; not re-run for fb-595.68.34) |
| pages reviewed | 10 of 10 on each engine (2026-10-22, below) |

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
- Cross-engine layout model (`lib/typst/xengine.typ`): body on a 28 pt pitch (double spaced at 14 pt), single lines (counsel, court, caption, title, headings, signature, footer) on a 16 pt pitch, explicit block spaces.
- Headings at the body size, single-spaced, 12 pt above and below: `#` centered bold caps; `##` bold left; `###` bold italic left. Each heading is kept with the paragraph after it.
- Paragraphs are indented 0.5 in and not numbered (memoranda of law in this court are not paragraph-numbered).
- Signature block: "Dated:" left of the first line, "Respectfully submitted," the firm and the `/s/` signer from 3.1 in, single lines; kept on one page with the last paragraph.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `counsel` (lines), `debtor` (lines), `case_no`, `chapter`, `judge`, `hearing` (required, e.g. `"Hearing Date: May 12, 2026, at 2:00 p.m."`), `adv_no`, `caption.parties` (list of `{names, designation}`), `title`, `date`, `signature` (`firm`, `signer`, `lines`), `lead_in` (optional).
- YAML items containing a colon must be quoted.
- Body: blank-line-separated chunks. `#`, `##`, `###` are headings (a heading may start with "1."); anything else is a paragraph (lists are not supported); a chunk in square brackets is an editorial note of the transcription (centered, italic).
- Not supported: tables, footnotes, a table of contents (none is generated), raw typst.

## Known gaps and open choices

1. **Exemplar is a combined response and motion.** The RECAP search (`court=njb`, motions and memoranda filed 2026-02 to 2026-10) turned up mainly orders, reply briefs and attachments. The filing used here (Cushing v. Lakeview, adv. 26-01099, doc 7) is a combined response to a motion for default judgment and a motion to dismiss. BTG Pactual v. Barclays (26-01041, doc 46) is a reply in support of a motion under Rule 7012(b), 25 pages; it was checked and not used. An opening memorandum in support of a motion, filed by itself, is not in the exemplar.
2. **One exemplar.** Tier 2 of EVAL-LOOP asks for two or three filers. Only one was collected; tier 2 is **not** judged against two filers yet.
3. **Hearing date in the caption.** The exemplar's caption carries no hearing date, though its notice of motion gives one (May 5, 2026, corrected to May 12, 2026 at 2:00 p.m.). LBR 9004-1(b) requires the applicable hearing date in the caption of a document requiring a caption. The template follows the rule, so the sample's caption carries the corrected date. This departs from the exemplar on purpose.
4. **Typeface and size are a convention.** As for the adversary complaint: the bankruptcy rules set no typeface. The exemplar's body measures about 12 pt Times New Roman (word boxes). The template uses Times New Roman 14 pt, the house face where no rule names one (checked 2026-10-15; see the typeface row above), double spaced; the size is the District's Local Civil Rule 7.2(d) convention for a proportional face, not a bankruptcy rule.
5. **Excerpt.** The sample transcribes pages 3 to 13 of the filing in part. The bracketed notes mark the omissions: the Younger Doctrine argument (pages 6 to 8) and the Rooker-Feldman heading and pages 9 to 11 (the heading is not transcribed). Pages 12 to 13 (certification of service) are not transcribed.
6. **Filer's text kept as filed.** The sample keeps the filer's wording and citation forms as they appear in the text layer, including "Under 12A;3-301", "NJSA Title 12A", and the Bell Sussex and Lance v. Dennis citations as the filer wrote them (the sample was corrected once and then restored to the filer's text). These are the filer's errors, not template defects.
7. **Signature with the last paragraph.** Fixed in fb-595.68.34: the last paragraph is kept on one page with the signature block (and the CONCLUSION heading with it), so the signature never stands alone. The cost: page 9 ends about half full when the conclusion moves to page 10. Accepted (tier 2).
8. **No table of contents.** The template does not generate one. The exemplar's combined pleading has none. Whether the court's judges expect one for a longer brief is a question for the judges' preferences (LBR 1001-1 comment), not a rule.
9. **Tool checks.** `tools/check.sh <this folder>`: `RESULT: 9 checks passed, 0 failed` (typst) and `RESULT: 13 checks passed, 0 failed` (`--engine docx`, XENG-001..003 gated).

## Review of the rendered pages (Gate 2 record, all 10 pages on each engine, rendered at 45 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 220/220).

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block, court name, LBR 9004-1 note, the debtor block (case number, chapter, judge, hearing date), the adversary block, the bold title, the lead-in | OK: nothing spills; the two-line title centered. |
| 2 | PRELIMINARY STATEMENT; STATEMENT OF FACTS begun | OK. |
| 3 | Statement of Facts continued (the UCC paragraphs) | OK. |
| 4 | Statement of Facts continued | OK. |
| 5 | End of the facts; LEGAL ARGUMENT, heading I, sub-headings A and B | OK: stacked headings single-spaced, 12 pt apart. |
| 6 | Rule 12(b)(6) continued, 12(h)(3); heading "1." over three lines; res judicata begun | OK. |
| 7 | Res judicata and entire controversy; the two bracketed notes | OK. |
| 8 | Rooker-Feldman argument | OK. |
| 9 | Rooker-Feldman argument (end) | ACCEPTED: the page ends about half full, as CONCLUSION, its paragraph and the signature block are kept together on page 10 (Known gaps 7). |
| 10 | CONCLUSION; "Dated:" and the signature block | OK. |

## Engines

Engine status: typst `OUTPUT-motion-brief.typst.pdf`; docx `OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice), 10 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

- **typst** (primary, `typst/`): the reference for the form, on `lib/typst/xengine.typ`.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 14 pt; Body Text in exact 28 pt lines with a 0.5 in first-line indent; single lines and headings in 16 pt boxes, 12 pt around a heading) and `docx/njb-motion-brief.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the counsel block, court, note, caption tables with the hearing line, title, headings, paragraphs, notes, the signature block, the footer (a centred 12 pt PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/njb.lua` and a committed `reference.docx` in EB Garamond). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none. No TOC or TOA in this template; footnotes are not used.
