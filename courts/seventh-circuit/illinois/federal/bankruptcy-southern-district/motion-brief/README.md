# S.D. Ill. Bankruptcy Court: motion brief (brief in support of a motion)

Doc type: **brief in support of a motion** (here, a brief supporting a motion to dismiss an adversary complaint, the case L.R. 9013-5(A) names). Court: United States Bankruptcy Court for the Southern District of Illinois (ilsb). Folder: `courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief/`.

Status: exemplar=yes (one filed exemplar, Gargula v. Deighan Law LLC, Adv. 20-06018, Doc 15-1, a memorandum in support of a motion; see `usage/SOURCE.md`), render=ok (`usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 12 pages each), pages reviewed 12 of 12, typst and docx (fb-595.68.27). Open: a second filer for the tier-2 comparison (see `usage/SOURCE.md`). No `court.json` status is set here; nothing in this folder sets `status`.

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

**One filed exemplar:** `usage/FILED-EXAMPLE-motion-brief.pdf`, the memorandum in support of the defendants' motion to withdraw the reference (Adv. 20-06018, Doc 15-1, filed 04/12/21), from CourtListener RECAP. It is a brief supporting a motion, the doc type here. Its caption is not on the attachment's first page; the sample's caption is copied from the same adversary's Doc 18. The filing has no certificate of service. Full provenance, the searches and the gaps are in `usage/SOURCE.md`.

Tier 2 wants two or three filers; one is saved. The second candidate (Naumann, 09-32092, Doc 35, a brief supporting an objection to confirmation) is in `usage/SOURCE.md`, not saved.

## Sample

- `usage/INPUT-motion-brief.md` is a **transcription** of the filed exemplar: pages 1 to 10 (through Argument V.A.3), then the Conclusion and signature (pages 19 and 20). The middle of the filing (V.A.4 to V.C) is omitted, and the sample says so in a visible note. Caption fields are from the same adversary's Doc 18 (see `usage/SOURCE.md`). The earlier fictional sample (`INPUT-generic-motion-brief.md`) was removed.
- Frontmatter fields: `title`, `division`, `debtors`, `debtor_designation`, `bankruptcy_case_no`, `chapter`, `adversary_no`, `caption.parties`, `date`, `signature` (`party`, `signer`, `signer_title`, `attorney`), `service` (`statement`, `parties`, `signature`).
- Body markdown: `# Heading` centered bold capitals; `## Heading` centered bold; `### Heading` bold, left. The author types any numbering (I., A., 1.). Paragraphs are not numbered and have a first-line indent. `> text` is a single-spaced block quotation. `- item` is a bullet list. `text[^key]` and `[^key]: text` make a footnote.

## Typst and render

```sh
fb render courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md            # typst
fb check courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief --engine typst|docx                     # render and gates
just overlay courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief
```

- `typst/main.typ` is the entry point; `typst/ilsb-motion-brief.typ` is the template. Times New Roman 12 pt (vendored, `("Times New Roman", "Liberation Serif")`); vendored fonts only, `--ignore-system-fonts`, warnings fail. The render compiles with no warnings.
- Layout: the shared cross-engine model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, the boxes touching, explicit spaces between blocks. Pitches: 24 pt body (double spacing, as filed), 13.8 pt single lines (court title, caption, headings, quotations, footnotes, signature), the 10 pt "Page X of Y" footer in a 12 pt line. Headings and block quotations stand half a body line (12 pt) from the text; footnotes are 12 pt (as filed), 7 pt apart, under a rule 6.8 pt below the text (with the 7 pt gap, the 13.8 pt single line of Word's separator), and split over pages where LibreOffice splits them. The caption is the adversary complaint's.
- `usage/OUTPUT-motion-brief.typst.pdf`: 12 pages. `pdffonts`: Times New Roman regular, bold and italic, embedded.
- Overlays (`just overlay`) are written to the gitignored `.overlay/` folder; a diagnostic, not a score.

## Visual review (Gate 2, all 12 pages of the typst and the docx render at 60 dpi, looked at; fb-595.68.27)

The docx render breaks every line and page as the typst render (XENG-001..003, 337/337 lines); the pages below hold for both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (copied from Doc 18), title, Overview; footnotes 1 and 2 | Caption is template-only: the filed attachment has none (see SOURCE.md). Footnote 1 is attached to the first sentence, not the title. OK. |
| 2 | Overview (continued), Procedural Posture | OK. |
| 3 | Procedural Posture (continued); footnotes 3 to 10 | OK. Footnote numbering matches the filing. |
| 4 | Procedural Posture (end), Part III; footnotes 11 to 16 | OK. |
| 5 | Part III (continued); footnotes 17 to 24 | OK. |
| 6 | Part III (end); footnotes 25 to 28 | OK. |
| 7 | Part IV (Legal Standard) | OK. |
| 8 | Part IV (end), Argument V, A, A.1; block quotation (Dimick) | ACCEPTED: the paragraph after a block quotation takes a first-line indent; in the filing it is flush left, as a continuation. Markup has no "continuation" paragraph. |
| 9 | Block quotation (Granfinanciera test); A.2 | Same as page 8 for the paragraph after the quotation. Otherwise OK. |
| 10 | A.2 (continued); footnote 29 | OK. |
| 11 | A.3, transcription note (italic), Conclusion | OK. |
| 12 | Signature, the two counsel blocks in the signature column | ACCEPTED: the signature block is kept whole and does not fit under the Conclusion, so it stands alone on the last page (gap 5). |

Reviewed pages: 12 of 12 (typst) and 12 of 12 (docx).

## Known gaps and open choices

1. **One exemplar, not two.** Tier 2 (a clerk's conventions, judged against two or three filers) needs a second filer; see `usage/SOURCE.md` for the candidate not saved. The caption of the exemplar is not in the filing (copied from the same adversary's Doc 18). The filing has no certificate of service, so the sample does not test that block.
2. **Typeface, type size, margins.** No S.D. Ill. rule names them. Times New Roman 12 pt (footnotes too, as filed), 1-inch margins and double spacing are style choices, the same as the adversary complaint folder.
3. **20-page limit (L.R. 9013-5(F)).** Not counted. The author must check the length, excluding the signature page and attachments.
4. **Citations (L.R. 9013-5(D)).** The rule requires citations to the authorities relied on. The template does not check them. Authorities are the author's.
5. **Signature alone on a page.** The signature block is kept whole, so it can move to a page of its own (it does in the sample). Keeping the last paragraph with the block would prevent a stranded block; not done.
6. **Certificate of service.** Generated in both engines only when `service:` is in the frontmatter. The statement and recipients are the author's text. L.R. 9013-2(A) requires it for papers under Rules 9013 and 9014; the template does not check that the certificate is present for a given filing. No sample exercises it.
7. **Motion and proposed order** are separate filings and not produced (L.R. 9013-1(A), 9013-4).
8. **Tables of contents and authorities** are not generated (no rule requires them for an S.D. Ill. brief).

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.xml`, `docx/ilsb.lua`; built by `fb render`, no shell): `reference.xml` is the cross-engine recipe (`base="xengine"`, `{font}` = the typst face, Times New Roman 12 pt; Body Text in exact 480-twip lines with a 720-twip first-line indent, 276-twip single lines, headings 240 twips from the text, Block Text 240 twips around and between its paragraphs, Footnote Text 12 pt in 276-twip lines, 140 twips after, without keep-lines) plus "Body Text Note" (no widow control, for a paragraph that anchors a footnote) and the "Page X of Y" footer (10 pt in a 240-twip line, 768 twips from the page foot). `ilsb.lua` (`require("docx.xengine")`) writes the court title, the caption table (rules right and bottom of the party column), title, headings, the signature with the attorney block in the signature column (kept together) and the certificate of service with the typst spacing in twips; body paragraphs, quotations and footnotes go to pandoc in those styles. Break rules as typst: no break inside ")(", a break after a slash before a letter and after a period in a web address, a section sign bound to its number also when doubled or after a typed quotation mark ("“§ __"). Until fb-595.68.27 the docx was EB Garamond from `docx/build-reference.sh` (12 pages against typst's 11, 63/331 lines as typst; DEF-FONT-002 and TNR-EMBEDDED failed on its render).
- Checks (fb-595.68.27): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (12 pages each, 337/337 lines). `eval.yaml` sets `params.cross_engine: gate`.
- **latex**: no latex template for this doc type.
