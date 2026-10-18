# S.D. Ill. Bankruptcy Court: motion brief (brief in support of a motion)

Doc type: **brief in support of a motion** (here, a brief supporting a motion to dismiss an adversary complaint, the case L.R. 9013-5(A) names). Court: United States Bankruptcy Court for the Southern District of Illinois (ilsb). Folder: `courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief/`.

Status: exemplar=yes (one filed exemplar, Gargula v. Deighan Law LLC, Adv. 20-06018, Doc 15-1, a memorandum in support of a motion; see `usage/SOURCE.md`), render=ok (`usage/OUTPUT-ilsb-motion-brief-gargula.typst.pdf`, 10 pages), overlay=ok (`usage/OVERLAY-gargula-motion-brief.pdf`, `.txt` page map), pages reviewed 10 of 10 (every page rendered at 70 dpi and looked at). Open: a second filer for the tier-2 comparison (see `usage/SOURCE.md`). No `court.json` status is set here; nothing in this folder sets `status`.

## Governing rules

Sources, all read on 2026-10-14:

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| ILSB-9013-5A | S.D. Ill. Local Rules, L.R. 9013-5(A), <https://www.ilsb.uscourts.gov/sites/ilsb/files/LocalRules-BkSoDistrict_12-01-15.pdf> (revision 12-01-15, the copy the court posts) | "Absent leave of Court, the following motions shall be supported by a brief: Motions to dismiss, motions to strike pleadings, motions for a more definite statement, and motions for judgment on the pleadings." | this doc type: the brief supports a motion to dismiss |
| ILSB-9013-5D | L.R. 9013-5(D) | Briefs "shall be filed at the time the corresponding motion is filed and shall be filed as a separate document"; "shall contain a short, concise statement of the party's position and citations to any authorities upon which the party relies." | separate document (the motion is not in this file); citations are the author's (not checked) |
| ILSB-9013-5F | L.R. 9013-5(F) | "Absent leave of Court, briefs shall not exceed 20 pages, exclusive of the signature page and attachments." | not enforced: the template does not count pages (see gaps) |
| ILSB-9013-5G | L.R. 9013-5(G) | If the movant fails to file the required brief, "the Court may enter an order striking or denying the motion." | consequence only |
| ILSB-9013-1A | L.R. 9013-1(A) | Motions are filed separately; "Applications, motions and other requests shall state with particularity the order or relief sought". | the brief is not the motion; a proposed order is separate (L.R. 9013-4) |
| ILSB-9013-2 | L.R. 9013-2(A)-(B) | Papers filed under FRBP 9013 or 9014 "shall comply with Rule 7005(d)", and the court "may refuse consideration of or strike any pleading or document for which a certificate of service has not been filed". | `certificate-of-service` (generated when `service` is in the frontmatter) |
| ILSB-CAP-001 | Fed. R. Bankr. P. 7010 and Fed. R. Civ. P. 10(a), <https://www.law.cornell.edu/rules/frbp/rule_7010>, <https://www.law.cornell.edu/rules/frcp/rule_10> | The caption, for papers in an adversary proceeding, substantially conforms to Form 416 (the same caption as the complaint). | `court-title`, `caption` |
| ILSB-FORM-001 | L.R. 5005-2 | "Papers submitted for filing shall be 8 ½” by 11” in size." | `page-w`, `page-h` |
| ILSB-FORM-002 | L.R. 5005-1(B)(1)-(2) | One side; "shall bear the name of the debtor and chapter of the case. Each paper other than the petition shall also have the case number." | caption fields `debtors`, `chapter`, `bankruptcy_case_no` |
| ILSB-SIG-001 | L.R. 9011(A) | "Under the attorney's signature shall be typed the attorney's name, office address, e-mail address, telephone number, and state bar number." | `signature-block`, `signature.attorney` |
| ILSB-SIG-002 | Electronic Filing Rules (Sept. 2021), Rule 5, <https://www.ilsb.uscourts.gov/sites/ilsb/files/ElectronicFilingRulesSept2021.pdf> | "/s/" followed by the signatory's name. | `signature-block` |

Not generated, on purpose: the motion itself (a separate document); a proposed order (L.R. 9013-4, e-mailed to the Court, not attached); a table of contents or table of authorities (no S.D. Ill. rule asks for one for a brief; a 20-page brief may add one by convention); a corporate disclosure statement.

## Exemplar

**One filed exemplar:** `usage/SAMPLE-ilsb-motion-brief-garguladeighan2006018.pdf`, the memorandum in support of the defendants' motion to withdraw the reference (Adv. 20-06018, Doc 15-1, filed 04/12/21), from CourtListener RECAP. It is a brief supporting a motion, the doc type here. Its caption is not on the attachment's first page; the sample's caption is copied from the same adversary's Doc 18. The filing has no certificate of service. Full provenance, the searches and the gaps are in `usage/SOURCE.md`.

Tier 2 wants two or three filers; one is saved. The second candidate (Naumann, 09-32092, Doc 35, a brief supporting an objection to confirmation) is in `usage/SOURCE.md`, not saved.

## Sample

- `usage/INPUT-ilsb-motion-brief-gargula.md` is a **transcription** of the filed exemplar: pages 1 to 10 (through Argument V.A.3), then the Conclusion and signature (pages 19 and 20). The middle of the filing (V.A.4 to V.C) is omitted, and the sample says so in a visible note. Caption fields are from the same adversary's Doc 18 (see `usage/SOURCE.md`). The earlier fictional sample (`INPUT-generic-motion-brief.md`) was removed.
- Frontmatter fields: `title`, `division`, `debtors`, `debtor_designation`, `bankruptcy_case_no`, `chapter`, `adversary_no`, `caption.parties`, `date`, `signature` (`party`, `signer`, `signer_title`, `attorney`), `service` (`statement`, `parties`, `signature`).
- Body markdown: `# Heading` centered bold capitals; `## Heading` centered bold; `### Heading` bold, left. The author types any numbering (I., A., 1.). Paragraphs are not numbered and have a first-line indent. `> text` is a single-spaced block quotation. `- item` is a bullet list. `text[^key]` and `[^key]: text` make a footnote.

## Typst and render

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief usage/INPUT-ilsb-motion-brief-gargula.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief gargula-motion-brief
```

- `typst/main.typ` is the entry point; `typst/ilsb-motion-brief.typ` is the template (EB Garamond, vendored; `--ignore-system-fonts`; any typst warning fails). The render compiled with no warnings.
- `usage/OUTPUT-ilsb-motion-brief-gargula.typst.pdf`: 10 pages. The overlay pairs sample pages 1 to 9 with filed pages 1 to 9 and sample page 10 with filed page 19 (word overlap 56% to 86%; 31% for page 10, where the filed conclusion follows omitted text).
- `usage/OVERLAY-gargula-motion-brief.pdf` (red = render, blue = filed exemplar, black = both) and `OVERLAY-gargula-motion-brief.txt` (page map).

Naming: `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `.txt` (the repo's tool names). The tools were not edited.

## Visual review (Gate 2: every page rendered at 70 dpi and looked at)

Pages 1 to 9 were viewed in the render before the signature fix and are unchanged by it. Page 10 was viewed in the render before and after the fix.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (copied from Doc 18), title, Overview; footnotes 1 and 2 | Caption is template-only: the filed attachment has none (see SOURCE.md). Typeface differs (EB Garamond, not Times). Footnote 1 is attached to the first sentence, not the title. Otherwise OK. |
| 2 | Overview (continued), Procedural Posture; footnotes 3 to 5 | OK. Footnote numbering matches the filing. |
| 3 | Procedural Posture (continued), Part III; footnotes 6 to 14 | OK. |
| 4 | Part III (continued); footnotes 15 to 22 | OK. |
| 5 | Part III (continued), Part IV starts on page 6; footnotes 23 to 28 | OK. |
| 6 | Part IV (Legal Standard) | OK. |
| 7 | Argument V.A and A.1; block quotation (Dimick) | The paragraph after the block quotation (the Dimick citation) takes a first-line indent; in the filing it is flush left, as a continuation. Markup has no "continuation" paragraph. Accepted. |
| 8 | Block quotation (Granfinanciera test); A.2 | Same as page 7 for the paragraph after the quotation. Otherwise OK. |
| 9 | A.2 (continued), A.3; footnote 29 | OK. The transcription note (italic, before the Conclusion) is on page 10. |
| 10 | Transcription note; Conclusion; signature | **Fixed.** Before: the attorney block sat full-width at left, and the signer line had a stray comma ("Mark T. Lavery,"). After: the attorney block sits in the signature column under the signature, as in the filing, and the comma is gone (`typst/ilsb-motion-brief.typ`, `signature-block`). Also OK: the Armgardt block follows the Lavery block with a gap. |

Reviewed pages: 10 of 10.

## Known gaps and open choices

1. **One exemplar, not two.** Tier 2 (a clerk's conventions, judged against two or three filers) needs a second filer; see `usage/SOURCE.md` for the candidate not saved. The caption of the exemplar is not in the filing (copied from the same adversary's Doc 18). The filing has no certificate of service, so the sample does not test that block.
2. **Typeface, type size, margins.** No S.D. Ill. rule names them. EB Garamond 12 pt, 1-inch margins and double spacing are style choices, the same as the adversary complaint folder.
3. **20-page limit (L.R. 9013-5(F)).** Not counted. The author must check the length, excluding the signature page and attachments.
4. **Citations (L.R. 9013-5(D)).** The rule requires citations to the authorities relied on. The template does not check them. Authorities are the author's.
5. **Signature alone on a page.** The signature block is kept whole, so it can move to a page of its own. The filed exemplar's Conclusion and signature fall on pages 19 and 20 of its own paging; in the sample they sit on one page with the Conclusion. Keeping the last paragraph with the block would still prevent a stranded block; not done.
6. **Certificate of service.** Generated only when `service:` is in the frontmatter. The statement and recipients are the author's text. L.R. 9013-2(A) requires it for papers under Rules 9013 and 9014; the template does not check that the certificate is present for a given filing.
7. **Motion and proposed order** are separate filings and not produced (L.R. 9013-1(A), 9013-4).
8. **Tables of contents and authorities** are not generated (no rule requires them for an S.D. Ill. brief).
9. **Footnote and quotation sizes** are the default sizes of the typst theme, not set separately.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **latex** (`latex/`): see `latex/`; not changed by this section.
- **docx** (`docx/reference.docx`, `docx/ilsb.lua`, `docx/build-reference.sh`): pandoc on reference.docx, EB Garamond 12 pt, exact 24 pt body line pitch, 0.5 in first-line indent, 1 in margins, letter, "Page x of y" footer (PAGE and NUMPAGES fields). `ilsb.lua` lays out the caption (a table with a right and a bottom rule), court title, title, the body as written (headings, paragraphs, block quotations as single-spaced indented blocks, bullets, footnotes), the signature table with the attorney block in the signature column, and the certificate of service when the frontmatter has `service`. Every case word comes from the frontmatter. Matches the typst form in: font and size, body pitch, margins, indent, heading styles (centered bold capitals, centered bold, bold), page-number footer, page order. Differs or is unverified: the single-spacing gaps and the caption and signature table spacing are approximate (Word table and style metrics, not measured against typst); footnote text is 12 pt single-spaced (typst's footnote size was not checked); the sample has no certificate of service, so that path is untested.
- docx checks: `usage/OUTPUT-ilsb-motion-brief-gargula.docx` was written and validated (zip test and well-formed XML in every part). BLOCKED on this box: LibreOffice (`soffice`) is not installed, so `usage/OUTPUT-gargula-motion-brief.docx.pdf` was not produced and the docx Gate 0 to 3 checks (`tools/check.sh --engine docx`) cannot run. No page was rendered or reviewed (pages reviewed 0). The `.docx` has not been opened in Word or LibreOffice.
- Blocked or unverified docx items: the docx.pdf render and page review (blocked on soffice); cover and caption table borders not verified against the typst layout; the page count and page breaks in Word may differ from typst.
