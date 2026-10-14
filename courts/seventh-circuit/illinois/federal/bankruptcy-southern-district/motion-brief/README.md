# S.D. Ill. Bankruptcy Court: motion brief (brief in support of a motion)

Doc type: **brief in support of a motion** (here, a brief supporting a motion to dismiss an adversary complaint, the case L.R. 9013-5(A) names). Court: United States Bankruptcy Court for the Southern District of Illinois (ilsb). Folder: `courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief/`.

Status: **BLOCKED: no exemplar.** exemplar=no, render=ok (fictional sample), overlay=fail (no exemplar PDF to overlay against), pages reviewed 4 of 4 (the fictional sample, final render). The template is built from the rules. No `court.json` status is set here; nothing in this folder sets `status`.

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

**None found.** See `exemplars/SOURCE.md` for the searches (CourtListener RECAP search with the `is_available` check, web search, the court's own documents). Every brief in support of a motion found in S.D. Ill. dockets is listed as an attachment or docket entry with no RECAP copy. The rules and court guides do not settle the layout, so the template follows the caption and signature rules above and the adversary complaint folder's conventions.

BLOCKED: no exemplar. A text-based, public copy of a brief in support of a motion to dismiss in an S.D. Ill. adversary proceeding is needed (for example, Gargula v. Deighan Law LLC, Adv. No. 20-03052-lkg, Doc 5, attachment 1, from PACER). A second filer is needed for the tier-2 check.

## Sample

- `samples/INPUT-generic-motion-brief.md` is **fictional**. It was written from the rules alone to exercise every part of the template: the caption, the separate-brief title, headings at three levels, a block quotation, a footnote, a bulleted list, the signature and attorney blocks, and the certificate of service. Names, numbers and dates are invented. It is not a transcription and not a visual reference for an S.D. Ill. brief.
- Frontmatter fields: `title`, `division`, `debtors`, `debtor_designation`, `bankruptcy_case_no`, `chapter`, `adversary_no`, `caption.parties`, `date`, `signature` (`party`, `signer`, `signer_title`, `attorney`), `service` (`statement`, `parties`, `signature`).
- Body markdown: `# Heading` centered bold capitals; `## Heading` centered bold; `### Heading` bold, left. The author types any numbering (I., A., 1.). Paragraphs are not numbered and have a first-line indent. `> text` is a single-spaced block quotation. `- item` is a bullet list. `text[^key]` and `[^key]: text` make a footnote.

## Typst and render

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/illinois/federal/bankruptcy-southern-district/motion-brief samples/INPUT-generic-motion-brief.md
```

- `typst/main.typ` is the entry point; `typst/ilsb-motion-brief.typ` is the template (EB Garamond, vendored; `--ignore-system-fonts`; any typst warning fails). The render compiled with no warnings.
- `samples/OUTPUT-generic-motion-brief.pdf`: 4 pages. `pdffonts`: EBGaramond-Regular and -Bold, embedded.
- No overlay: `tools/overlay.sh` compares against an exemplar PDF in `exemplars/`, and there is none. It was not run.

Naming: `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` (the repo's tool name), not the `<id>.pdf` name in the brief. The tools were not edited.

## Visual review (Gate 2, all 4 pages rendered at 60 dpi and looked at, final render)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, title of the brief, Introduction, Background A, footnote 1 at foot | OK. Footnote renders at the foot of its page (it did not, in an earlier render, because footnote definitions were rendered apart from the paragraph that cites them; fixed). |
| 2 | Background A (continued), B, Argument I with a block quotation and II with a bullet list, Conclusion | OK. Heading sizes and levels as in the frontmatter. |
| 3 | Signature block alone on the page | Acceptable but not ideal: the Conclusion sits on page 2 and the signature block (not breakable) moves to page 3. Not fixed. A convention choice (see gaps). |
| 4 | Certificate of service | OK. |

Reviewed pages: 4 of 4.

## Known gaps and open choices

1. **BLOCKED: no exemplar.** See above. Overlay not run. Tier-2 review not possible.
2. **Typeface, type size, margins.** No S.D. Ill. rule names them. EB Garamond 12 pt, 1-inch margins and double spacing are style choices, the same as the adversary complaint folder.
3. **20-page limit (L.R. 9013-5(F)).** Not counted. The author must check the length, excluding the signature page and attachments.
4. **Citations (L.R. 9013-5(D)).** The rule requires citations to the authorities relied on. The template does not check them. Authorities are the author's.
5. **Signature alone on a page** (page 3 of the sample). The signature block is kept whole, so it can move to a page of its own. Keeping the last paragraph with it would fix this; not done.
6. **Certificate of service.** Generated only when `service:` is in the frontmatter. The statement and recipients are the author's text. L.R. 9013-2(A) requires it for papers under Rules 9013 and 9014; the template does not check that the certificate is present for a given filing.
7. **Motion and proposed order** are separate filings and not produced (L.R. 9013-1(A), 9013-4).
8. **Tables of contents and authorities** are not generated (no rule requires them for an S.D. Ill. brief).
9. **Footnote and quotation sizes** are the default sizes of the typst theme, not set separately.
