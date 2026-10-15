# W.D. Ky. bankruptcy court (kywb): motion brief

Doc type: **motion brief**: a memorandum of law filed in support of a motion (here, a motion to dismiss an adversary complaint), with caption, title, headings, numbered paragraphs, footnotes, signature block and certificate of service. Court: United States Bankruptcy Court, Western District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/motion-brief/`.

Status: exemplar=yes, render=ok (typst, no warnings), overlay=ok, pages reviewed 10 of 10 (rendered at 60 dpi and looked at, final render). Nothing here sets a court-level `status`.

## Governing rules

Fetched 2026-10-14 from the Legal Information Institute (law.cornell.edu) and from the court's website. The local rules are a **draft**: the 2025 local rules file on the court's site, "local_rules_2025_v1_incorporated.docx", reads "Effective (______________)" and "[Note: Table of Contents will be updated once Local Rules are finalized]". Verify against the adopted text before relying on any LBR point. **No W.D. Ky. rule found in that file sets a format for a supporting memorandum**: no typeface, margin, spacing, caption or page-limit rule for briefs. The memorandum's layout therefore rests on the federal rules below and on the filed exemplar (tier 2).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| KYWB-FORM-001 | Fed. R. Bankr. P. 9004(a) (as amended eff. Dec. 1, 2024) | "A petition, pleading, schedule, or other document must be clearly legible." | `typst/kywb-motion-brief.typ` (EB Garamond 13 pt, black on white) |
| KYWB-FORM-002 | Fed. R. Bankr. P. 9004(b) | A document presented for filing must have a caption that sets forth the court's name, the case title, the case number and any adversary-proceeding number, and a brief designation of the document. | `caption()`: court title, debtor block (`caption.debtor_names`, `bankruptcy_lines`), adversary block (`caption.adversary_number`, `caption.judge`), title (`title`) |
| KYWB-FORM-003 | Fed. R. Bankr. P. 7010 (in an adversary proceeding, the caption of a pleading must substantially conform to Form 416) | Applies to pleadings; the memorandum is not a pleading, so the caption follows the filed exemplar's layout, which is the Form 416 layout. | caption layout |
| KYWB-MOT-001 | Fed. R. Bankr. P. 9013(a) | "A request for an order must be made by written motion unless: (1) an application is authorized by these rules; or (2) the request is made during a hearing." | Not generated: the motion is a separate document (see gaps). |
| KYWB-MOT-002 | Fed. R. Bankr. P. 9013(b) | "A motion must state its grounds with particularity and set forth the relief or order requested." | Content is the author's; the memorandum's Preliminary Statement and Conclusion (¶¶1–4, ¶69) carry the grounds and the relief. The template does not check it. |
| KYWB-LBR-001 | W.D. Ky. L.B.R. 9013-1(a)(1) | "The Clerk will not accept any motion for filing unless accompanied by a separate proposed order." | Not generated: a proposed order is a separate filing (see gaps). |
| KYWB-LBR-002 | W.D. Ky. L.B.R. 9004-1 | "All motions, pleadings, tendered orders, and other related matters shall be typewritten and shall include the address, telephone number, and email address of the person filing the document." | `signature-block()`: counsel's address, telephone and email (`signature.groups`) |
| KYWB-SIG-001 | W.D. Ky. L.B.R. 9011-4; L.B.R. 9011-1(b) | The court will refuse a paper "if it is not properly signed"; an image of a signature is a representation by the filer (9011-1(b)(3)). | `signing-block()`: "By: /s/" line with the signer's name |
| KYWB-CERT-001 | Convention, not a rule citation | The filed exemplar ends with a certificate of service on electronic service. No rule text found in this session requires it for a memorandum; it is generated when the sample's frontmatter has `certificate`. | `certificate()` |

Not used, and why:
- **Notice of motion, the motion itself, and a proposed order.** Separate filings (L.B.R. 9013-1(a)(1)). The exemplar is the memorandum only.
- **Table of contents and table of authorities.** The filed exemplar has neither (it is 27 pages). No W.D. Ky. rule found requires them. Not generated.
- **Page limit.** None found in the local rules file; a judge's order may set one. Not enforced.
- **Numbered paragraphs.** The filed exemplar numbers its paragraphs (¶¶1–69). Fed. R. Civ. P. 10(b) requires numbered paragraphs in a pleading, not a memorandum, so the template does not number them: the author types the numbers, as filed.

## Exemplar

- `exemplars/FILED-EXAMPLE-insight-terminal-v-city-of-oakland-24-03007-motion-brief.pdf`: Defendant City of Oakland's Memorandum of Law in Support of Motion to Dismiss, *Insight Terminal Solutions, LLC v. City of Oakland*, Adv. Proc. No. 24-03007-jal (Bankr. W.D. Ky.; main case No. 19-32231). Filed May 1, 2024 by Dentons Bingham Greenbaum LLP for the City, as Attachment 1 (Dkt. 25-1) to the City's motion. The file is the attachment unaltered: 77 pages, of which **pages 2 to 27 are the memorandum** and page 28 is its certificate of service; the rest are further exhibits.
- Provenance, searches and the caveat are in `exemplars/SOURCE.md`.

## Sample

- `samples/INPUT-insight-terminal-city-of-oakland.md`: a **partial** transcription of the memorandum, with the caption, the signature page and the certificate:
  - the caption and title;
  - Part I, Preliminary Statement (¶¶1–4);
  - Part II, Factual Background (¶¶5–25), with its sub-parts A (¶¶7–13), B (¶¶14–19) and C (¶¶20–25), and footnote 1;
  - Part V, Conclusion (¶69);
  - the signature page (all four counsel groups and "Attorneys for Defendant, City of Oakland");
  - the certificate of service.
- **Not transcribed:** ¶¶26–68 (the quoted plan provisions in ¶26, Parts III and IV, and the argument), footnotes 2–5, and the exhibits after the certificate. The frontmatter comment records this. The partial transcription keeps the sample inside the 8–14 page target; the filed memorandum is 27 pages.
- Paragraph and heading numbers are typed in the sample exactly as filed (`1\.`, `## I. PRELIMINARY STATEMENT`), so the template neither numbers nor re-letters them.
- Case names and "Id." are not italicized: the text layer carries no italic markup, so italics were not transcribed. This is a visible difference from the filed page; it is recorded here, not chased.
- Transcription check: every paragraph was compared with the PDF text layer. The first and last words of all 26 transcribed paragraphs (¶¶1–25, ¶69) match. A five-word-run check then flags only passages that the source splits with page headers, form feeds, bracketed alterations, the footnote marker "1" or a hyphen at a line end; the ones examined by hand were those artifacts. The check is not a full proof of every word.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
cd /work/repo
sh tools/render.sh courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/motion-brief samples/INPUT-insight-terminal-city-of-oakland.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/motion-brief insight-terminal-city-of-oakland
```

- `samples/OUTPUT-insight-terminal-city-of-oakland.pdf`: 10 pages. Typst compiled with no warnings. `pdffonts`: EBGaramond-Regular and -Bold only, embedded. Named `OUTPUT-` (the name `tools/render.sh` writes by default and `tools/overlay.sh` reads).
- `samples/OVERLAY-insight-terminal-city-of-oakland.pdf` and `.txt`: red = our render, blue = exemplar (the 77-page attachment), black = both. The page map pairs pages by word overlap: ours p.1–4 ↔ filed p.2–5 (66–90%); p.5–7 ↔ filed p.6–8 (41–59%); p.8 ↔ filed p.9 (23%, the page where the transcription stops at ¶25 and the filing runs on to the Argument); p.9 ↔ filed p.27 (90%, the signature page); p.10 ↔ filed p.28 (83%, the certificate). The overlay is a diagnostic, not a score: the render is in a different face and line length from the filing, so lines will not coincide.

## Visual review (Gate 2 record: all 10 pages, final render at 60 dpi, looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption (court title, debtor block, adversary block with adversary number and judge), title (two lines), heading I, ¶1 | OK. The heading size was pinned to body size after it rendered larger than the text. |
| 2 | ¶¶2–4 | OK. Double spacing at a 24 pt pitch. |
| 3 | Heading II, ¶¶5–6, sub-heading A, ¶¶7–8 | OK. Sub-heading hangs at 0.5 in. |
| 4 | ¶¶8–12 | OK. |
| 5 | Sub-heading B, ¶¶13–15, footnote 1 (Request for Judicial Notice, with its citations) at foot of page | OK. The footnote reference after "RJN" is superscript. |
| 6 | ¶¶16–19 | OK. |
| 7 | Sub-heading C, ¶¶20–24 | OK. Bracketed alterations in ¶23 ("[Mr. John]", "[the former non-member Manager…]") are kept as filed. |
| 8 | ¶25, heading V, ¶69 (the conclusion), blank lower half | OK. The body ends here: the filed Argument (Part III) is not transcribed. |
| 9 | Signature page: "Dated" and "By: /s/" with four counsel groups and "Attorneys for Defendant, CITY OF OAKLAND" | OK after two fixes. First render: the counsel block was unbreakable at normal leading and overflowed the bottom margin into the page number, dropping the last lines. Fixed by zero leading inside the block and smaller gaps between groups; it now sits on one page. |
| 10 | Certificate of service with signing block | OK. |

## Known gaps and open choices

1. **Tier 2 (exemplars).** One exemplar. The eval-loop tier-2 rule asks for two or three from different filers. Not done.
2. **The motion is not in the exemplar.** The filed motion (Dkt. 25) is not in RECAP (the RECAP copy of Dkt. 25 is a 404; only the attachment is available). The template therefore covers the memorandum; the notice and motion, and the proposed order required by L.B.R. 9013-1(a)(1), are separate documents not generated.
3. **Local rules status.** The W.D. Ky. local rules file is a draft with a blank effective date; no memorandum format rule was found in it. Every LBR citation above is to that draft.
4. **Typeface and spacing are style choices**, not rules: EB Garamond (vendored, OFL) at 13 pt; 24 pt double-spaced lines, as the filed memorandum. The filer used Times.
5. **Partial sample.** ¶¶26–68 and Parts III–IV are not transcribed, so the sample is 10 pages against the filed 27 (and the overlay's page 8 shows where the transcription stops).
6. **Italics.** Case names and signals are not italic in the sample (see Sample).
7. **Certificate of service.** A convention drawn from the exemplar; the rule that requires service of a motion is not cited here because its text was not retrieved this session.
8. **Paragraph and heading numerals are typed by the author.** A future author must type them; the template does not check that the numbering is consecutive.
9. **Exemplar caption.** The filed caption carries "Judge Joan A. Lloyd" under the adversary number; the template prints `caption.judge` there when present.
10. **Page-number format.** "- n -" centered at the bottom, as the filed memorandum (its page 25 reads "- 25 -"). The filing's ECF header is system output and is not reproduced.

## Engines

The docx engine (`docx/`) is built, and its `.docx` renders, but its LibreOffice PDF was not made (see BLOCKED). Build: `sh docx/build-reference.sh docx/reference.docx`. Render: `sh tools/render.sh --engine docx <this folder> samples/INPUT-insight-terminal-city-of-oakland.md`, which writes `samples/OUTPUT-insight-terminal-city-of-oakland.docx` and then fails at the `soffice` step. `docx/render.sh` (called by `tools/render-docx.sh`) runs pandoc with `docx/kywb-motion-brief.lua`, puts back the reference's styles and page setup, and checks the zip and XML parts.

What matches the typst form (set in `docx/reference.docx`; read from its XML, not from a rendering):

- Page: US letter, 1 in margins on all sides.
- Font and size: EB Garamond (vendored), 13 pt in the body, headings and footnotes; footer "- n -" at 11 pt, centered, in a PAGE field.
- Spacing: body lines exact 24 pt, first-line indent 0.5 in; Heading 1 and 2 centered and bold; Heading 3 hangs 0.5 in; footnote text single spaced at 13 pt.
- Caption as in the adversary complaint (court, debtor block, adversary block with the number and judge, title).
- Signing block as a borderless two-column table (Dated on the left, By: /s/ and the counsel groups on the right); certificate of service on its own page (`pageBreakBefore`) with its signing block.
- Paragraph and heading numerals are typed in the sample and are not added by the filter, as in typst.

What differs from typst:

- Paragraph spacing: on the typst render (10 pages, `/work/artifacts/kywb/motion-brief/OUTPUT-insight-terminal-city-of-oakland.pdf`, outside the court folder) the pitch measured with `pdftotext -bbox` on page 2 is 24 pt within a paragraph and about 17 pt between paragraphs (for example between ¶2 and ¶3). The typst source says double spacing at 24 pt. The docx keeps 24 pt everywhere. The typst gap is a template question; it is not changed here.
- Footnote and body pagination: not measured for the docx (no LibreOffice); the typst render is 10 pages.
- Italics: the sample has none (as in typst).
- Hyphenation, kerning and ligatures: application defaults in the docx; not asserted.

docx BLOCKED (the checks that run on the `.docx.pdf` cannot run):

- `docx.pdf` and the Gate 0 and Gate 1 checks: `soffice` (LibreOffice) is not installed on this box, so `samples/OUTPUT-insight-terminal-city-of-oakland.docx.pdf` was not produced. Not passed.
- Gate 2 page review of the docx: no PDF to look at, so no pages reviewed. Not passed.
- Opening the `.docx` in LibreOffice or Word (no repair prompt): not done. Only the zip, the XML well-formedness and a pandoc read-back were checked.
- Word limits in `docs/DOCX.md` that apply to this form: none. The form has no table of contents, table of authorities or pleading line numbers.
