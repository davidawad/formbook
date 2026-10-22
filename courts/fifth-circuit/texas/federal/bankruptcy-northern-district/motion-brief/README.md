# txnb: motion-brief

Doc type: **motion with brief in support** in the United States Bankruptcy Court for the Northern District of Texas (`txnb`), filed in an adversary proceeding (for example, a motion to dismiss).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-northern-district/motion-brief/`.

Exemplar: Shook adversary 26-03089 (Bankr. N.D. Tex., Dallas Division), Doc 9, "Defendants' Brief and Partial Motion to Dismiss," filed October 9, 2026. Source and URLs in `usage/SOURCE.md`.

| Item | Status |
|---|---|
| typeface | face required: none (L.B.R. revised 12/1/2025 and 12/1/16 name no face for motions or briefs). Substitute: none; **Times New Roman** (the house standard, `docs/FONTS.md` rule 6, and the exemplar's face; was EB Garamond before fb-595.68). Metric note: none needed. |
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (the whole 9-page filing, text layer present) |
| sample md | `usage/INPUT-motion-brief.md`: a transcription of the whole filing: caption, counsel block, the body (sections I to IX), the signature, the certificate of conference and the certificate of service |
| render | ok: `tools/render.sh` (typst 0.15.0, pinned Times New Roman only, no warnings) writes `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages (8 on the earlier EB Garamond render, before fb-595.68) |
| overlay | ok: `tools/overlay.sh` writes `usage/OVERLAY-ruxton-v-shook.pdf` and `.txt`; every rendered page is paired with a filed page (see the page map in the `.txt`) |
| pages reviewed | 8 of 8 on the earlier EB Garamond render (every page of that render rasterized at 80 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 | A motion must state its grounds with particularity and set forth the relief or order requested; a request for an order is made by written motion, with the exceptions in the rule. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9013 on 2026-10-14 (paraphrased; the page's quote limit prevented verbatim quoting). | Title (`title` frontmatter) and the body; the template does not check that grounds are stated. |
| Fed. R. Bankr. P. 9004(a)-(b) | Legible papers; caption with (1) court name, (2) case title, (3) case number and adversary number, (4) designation of the document. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. | `court-title()`, `caption()` (case and adversary numbers), `cover()` title line. |
| L.B.R. 9013-1(a) | Applies L.B.R. 7007-1(a)-(c) and 7007-3 to motion practice in the bankruptcy court. Local rules revised 12/1/16, fetched from https://www.txnb.uscourts.gov/sites/txnb/files/local_rules/TXNB_Local_Rules_Revised_12.1.16_0.pdf on 2026-10-14. | The three items below. |
| L.B.R. 7007-1(a) | Conference before filing, except for motions to dismiss, motions for judgment on the pleadings, motions for summary judgment, motions for new trial, or when a conference is not possible or practicable. | No element; a motion to dismiss does not need the conference. |
| L.B.R. 7007-1(b) and (f) | Certificate of conference (unopposed or opposed, date, attorneys conferring, reasons); a certificate of conference is required for a motion that needs a conference. | `certificate_conference` frontmatter; the certificate is written only when the frontmatter gives it. |
| L.B.R. 7007-1(c) | Proposed order, set forth separately as an exhibit to the motion. | Not generated (see Known gaps). |
| L.B.R. 7007-1(e) and 9014-1(b) | Certificate of service (date, mode of service, names and addresses of parties served) filed with the clerk, attached to the motion. | `certificate_service` frontmatter. |
| L.B.R. 7007-2(a) | A brief shall be printed, typewritten, or presented in some other legible form. | Typeset in the template. |
| L.B.R. 7007-2(c) | A brief shall not exceed 25 pages, excluding the table of contents and table of authorities. A reply brief shall not exceed 10 pages. | Not enforced by the template (see Known gaps). |
| L.B.R. 7007-2(d) | A brief over 10 pages shall contain (1) a table of contents with page references and (2) an alphabetically arranged table of authorities with page references. | Table of contents: generated from the headings when `toc: true`. Table of authorities: not generated (see Known gaps). |
| L.B.R. 9013-1(b)(5) | A complete paper copy of a motion to dismiss under Fed. R. Bankr. P. 7012 is to be delivered within 24 hours of electronic filing, unless the Presiding Judge orders otherwise. | Not a template element; a filing step to note. |

No font, margin or line-spacing rule for motions was found in the N.D. Tex. bankruptcy local rules (the copy above). The 12/1/2025 revision (`TXNB Local Rules (Revised 12-1-2025)`, read 2026-10-14 from its PDF text) was also checked: no typeface, font size or spacing rule appears in L.B.R. 5005-1, 7007-1, 7007-2 or 9013-1, so the face is not court-named and the template is set in Times New Roman, the house standard (`docs/FONTS.md` rule 6). The mailing-matrix type rule (10 to 14 pt, Courier, Times Roman, Helvetica or Orator) is for the matrix in a complex Chapter 11 case and is not applied here.

The local rules copy is dated "Revised 12/1/16". A later revision may exist on the court's site; this run did not find one. Recheck before filing.

## Layout

- Letter size, 1-inch margins, page number centered in the footer.
- Counsel block single-spaced at the top left (the N.D. Tex. bankruptcy local rules do not say where counsel goes; this is a convention).
- Court title centered and bold: UNITED STATES BANKRUPTCY COURT / NORTHERN DISTRICT OF TEXAS / DIVISION.
- Form 416 caption (same as the adversary-complaint folder): debtor above the adversary parties on the left; chapter, case number and adversary number on the right.
- Title centered and bold, then the body.
- Body double-spaced (27.6 pt pitch at 12 pt, Word's double, as the exemplar measures), paragraphs unnumbered and first-line indented 0.5 in. Headings are set as written: level 1 centered bold (the template does not change their case, because `upper()` turned citation letters such as "(a)" into "(A)"); level 2 bold; level 3 bold italic. Headings keep with the paragraph that follows.
- Lists numbered 1., 2., ... as written (relief items).
- Table of contents on its own page, after the cover, when `toc: true`.
- Signature block, then the certificate of conference and the certificate of service when given. Each certificate is kept on one page with its heading.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `caption` (`debtor` optional; `parties` list of `{names, designation}`), `chapter`, `case_number`, `adversary_number`, `division`, `title`, `toc` (true to generate the table of contents), `counsel`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate_conference` and `certificate_service` (optional markdown; a leading `[noindent]` is removed).
- Body: blank-line-separated chunks. A `#` heading (the table of contents picks up levels 1 and 2); a list; or a paragraph. A paragraph starting with `[noindent]` is not first-line indented.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **Paragraph numbers (OPEN, a clerk-convention question for David).** The exemplar numbers its body paragraphs 1 to 13; the template's motion convention is unnumbered paragraphs (the complaint template numbers them). The rules reviewed here do not require numbers in a motion, and the exemplar is one filer, so the template is not changed. Decide whether motions should be numbered.
2. **Table of contents not generated for this exemplar.** The exemplar is 9 pages and has no table of contents; L.B.R. 7007-2(d) applies only to a brief over 10 pages, so the sample sets `toc: false`.
3. **Table of authorities not generated.** L.B.R. 7007-2(d)(2) requires one for a brief over 10 pages. Generating page references needs a citation-tagging step in the sample, which is not built. A brief over 10 pages cannot be filed from this template without it.
4. **Page limit not enforced.** L.B.R. 7007-2(c) allows 25 pages, excluding the table of contents and authorities. The template does not count body pages or fail the build past 25.
5. **Proposed order not generated.** L.B.R. 7007-1(c) requires it as a separate exhibit. It is a separate document, to be drafted separately.
6. **Certificate of conference.** L.B.R. 7007-1(a) exempts motions to dismiss from the conference requirement. The template writes a certificate only when the frontmatter gives one, so a motion to dismiss can omit it.
7. **Font.** No typeface rule was found for motions in either the 2016 or the 2025 local-rules text, so the face is not court-named and the template is set in Times New Roman at 12 pt, the house standard (`docs/FONTS.md` rule 6) and the exemplar's face (EB Garamond before fb-595.68). Re-check if the court names a face in a later revision.
8. **Output PDFs.** `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OVERLAY-ruxton-v-shook.pdf` (with `.txt`) are written where the tools put them. Regenerate with `sh tools/render.sh <this-folder> usage/INPUT-motion-brief.md` and `sh tools/overlay.sh <this-folder> ruxton-v-shook`.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and `tools/` is out of scope for this box. The gates were not run.
10. **Signature block.** The template prints "Respectfully submitted," above the firm name; the filing's block is the same in substance. The filing's certificate of conference is written in the template's single-spaced certificate style.

## Review of the rendered pages (Ruxton transcription, 8 pages of the earlier EB Garamond render, before fb-595.68)

- Page 1: counsel block; court title; Form 416 style caption; the title centered; the intro paragraph. Pass.
- Pages 2–3: sections II to IV; headings bold and centered, as written; citations keep their case (for example "§ 523(a)(4)"). Pass.
- Page 4: section V; "V. Count II: § 523(a)(4) fiduciary theory" keeps its lowercase letters. Pass.
- Page 5: section VI; "VI. Counts V–VII: § 727(a)(3), (2), and (4)" keeps its lowercase letters. Pass.
- Page 6: section VII, starting the page with its heading and paragraph (the first render left the heading alone at the foot of page 5, so headings were made sticky), and the start of VIII. Pass.
- Page 7: the rest of VIII, section IX, the date, the signature block. Pass.
- Page 8: the certificate of conference and the certificate of service, each with the "/s/" line. Pass.
- Overlay: the filed pages differ from ours in the places listed in Known gaps (paragraph numbers, the ECF header, the filing's own headings). The word-overlap scores (53–90%, on the earlier EB Garamond render) are a pairing aid, not a grade.
- Fixed in this pass: level-1 headings no longer pass through `upper()`; headings are kept with the following paragraph; the transcription no longer repeats "Respectfully submitted," and no longer shows a stray "[unnumbered]" marker.

[Formbook index](../../../../../../README.md) | [Court README](../README.md)

## Engines

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`: `fb render --engine docx` builds the reference document from it, the shared cross-engine recipe in the typst template's face) and `docx/txnb-motion-brief.lua`. Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md` (a wrapper of `fb render --engine docx`) writes `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (10 pages, as the typst output; on the earlier EB Garamond render 9 against typst's 8).

- Matches typst: US Letter with 1 in margins; Times New Roman 12 pt (`pdffonts` shows only Times New Roman); body double-spaced at a 27.6 pt line pitch, 0.5 in first-line indent, unnumbered paragraphs; counsel block and Form 416 caption as in the adversary folder; court title in single lines and the bold title set off by a double line; headings (level 1 centered bold, level 2 bold, level 3 bold italic); lists numbered "1." and a tab; signature block kept together ("Dated", "Respectfully submitted", firm, "By: /s/", bar lines); certificate of conference and certificate of service, each a centered bold uppercase heading, unindented paragraphs, "/s/" right aligned, kept together; page number centered in the footer.
- Differs (recorded on the earlier EB Garamond render, then built by `docx/build-reference.sh`, since retired into fb render): (1) pagination: the text of each 24 pt line sits about 4 pt lower in LibreOffice than in typst, so each page carries slightly fewer lines of body text. The result is a 9-page `.docx.pdf` against the 8-page typst output: the signature block starts page 8 and the certificate of service is on page 9. The margins are unchanged. (2) Word's natural line height for EB Garamond may differ from LibreOffice's, so Word may paginate differently. (3) Paragraph numbers are not used in a motion (as in the typst template).
- Pages reviewed (docx): 1-9 of 9 of the earlier EB Garamond render, each rendered at 60 dpi and viewed.
- Table of contents (not exercised by the sample, which has `toc: false`): with `toc: true` the filter writes the contents with dot leaders and fb render fills in the page numbers from the LibreOffice PDF (the needles in `docx/txnb-motion-brief.lua`). Before fb-595.68 the docx had a TOC field with a placeholder only, recorded then as BLOCKED (L.B.R. 7007-2(d)). The table of authorities is not generated by either engine (typst Known gaps 1 and 3 apply to the docx too), so it is BLOCKED for the docx engine.
- Gates: `tools/check.sh` was not run for the docx engine on this folder; the harness needs a court folder with `court.json` and `checks.yaml`, which this doc-type folder does not have.
