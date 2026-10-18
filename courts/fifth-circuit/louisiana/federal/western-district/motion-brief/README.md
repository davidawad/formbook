# lawd: motion-brief

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b) motion, in the United States District Court for the Western District of Louisiana (`lawd`). The exemplar is a Rule 12(b)(6) memorandum; the template serves any Rule 12 memorandum of this district (the sample header says so).
Folder: `courts/fifth-circuit/louisiana/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-lawd-motion-brief-lewisharriscounty126cv00172.pdf` (1 filer, see `usage/SOURCE.md`) |
| typeface | face required: none (LR 7.1, 7.8 and 10.1 name no face or size, checked 2026-10-14). Vendored substitute: none needed, EB Garamond kept (`"EB Garamond"`, the no-face default in `docs/FONTS.md`). Fit: n/a. The filed exemplar is set in Times New Roman, which is a filer choice, not a rule. |
| sample md | `usage/INPUT-lawd-motion-brief-lewis.md`: caption, opening, the TOC and TOA, filed pages 1 to 11 (Background, Law and Argument, Legal Standard, Part II.A and II.B), the conclusion, signature and certificate. Parts II.B (rest), II.C to II.F and Part III are a bracketed note. |
| render | ok: `usage/OUTPUT-lawd-motion-brief-lewis.typst.pdf`, 10 pages: caption, TOC, TOA, and 7 body pages (the last holds the signature and certificate), typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> usage/INPUT-lawd-motion-brief-lewis.md`) |
| overlay | ok: `usage/OVERLAY-lewis-motion-brief.pdf` and `OVERLAY-lewis-motion-brief.txt` (`sh tools/overlay.sh <this dir> lewis-motion-brief`) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |
| tools/check.sh | not run: same reason as `../complaint/README.md` |

File names: the tools write `OUTPUT-` and `OVERLAY-` names, not the `<id>.pdf` and `<id>-overlay.pdf` names in the brief. The sample is `INPUT-<id>.md`, which the tools expect.

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1 (W.D. La. Local Civil Rules, Ver3 030526, https://www.lawd.uscourts.gov/sites/lawd/files/UPLOADS/CivilCrimLRs.Barbara.updated.Ver3.030526.ppm.pdf, linked from https://www.lawd.uscourts.gov/local-rules) | A memorandum in support of a motion may not exceed 25 pages, exclusive of the tables; a judge may grant leave. A memorandum over 10 pages must have a table of contents and a table of authorities. | Table of contents (generated from the headings, depth 3) and table of authorities (from the sample's `authorities` list) are produced when `authorities` is in the frontmatter. The 25-page limit is not checked by the template. |
| LR 7.8 | The same limits and tables, for briefs. | Same as LR 7.1. |
| LR 7.3 | A proposed order is not required for a motion filed under Rule 12. | No proposed order is produced. |
| LR 10.1 | 8 1/2 x 11 paper, paginated, double spaced except footnotes and quotations. The caption includes the division, the district judge and the magistrate judge. | `page` (letter, roman numbers for the caption and tables, arabic from the body), `body-leading` (double spacing), `caption()` (JUDGE and MAGISTRATE JUDGE lines), `division` (checked against the five W.D. La. divisions). |
| LR 11.1 | Signature: the signer's name, address, telephone and Attorney Identification Number under the signature. | `signature()` prints the lines the sample gives (the sample carries the bar numbers in parentheses, as the exemplar does). The template does not check them. |
| FRCP 10(a) | Caption with the court's name, title, file number and Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10. | `caption()`, the court title, `title`. |
| FRCP 12(b)(6) | The motion is made by a Rule 12(b)(6) motion, and the memorandum is its support. | Not a template rule; the sample's title follows the filing. |

Not produced: the motion itself, the proposed order (not required, LR 7.3), any certificate of conference (LR 7.4.1 applies to non-dispositive motions, not to a Rule 12 motion).

## Layout

- Front matter (roman numbers): caption, title, optional subtitle (the filer line), and the opening paragraph(s) before the first heading.
- Tables: TABLE OF CONTENTS (generated) and TABLE OF AUTHORITIES (sample list, cases, statutes and other authorities, with dot leaders), each on its own page.
- Body (arabic numbers from 1): level 1 headings centered bold caps, level 2 bold at the margin, level 3 bold italic; paragraphs with a 0.5 inch first-line indent and double spacing; lists numbered (1), (2), ... 
- Signature block (single spaced, the date at left when given), then the CERTIFICATE OF SERVICE when the frontmatter has `certificate`.
- Every block is rounded up to whole 24 pt lines (`on-grid`), so no paragraph overlaps the line before it. Headings are kept with the paragraph after them (`sticky`), and the certificate heading is kept with its text.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `division`, `caption` (`parties`, `separator` such as `VERSUS`), `judge`, `magistrate`, `legend` (optional), `title`, `subtitle` (optional), `authorities` (list of `{category, items: [{cite, pages}]}`), `signature` (`date`, `lines`), `certificate` (`text`, `signature.lines`).
- The body is blank-line separated chunks: `# ` (level 1), `## ` (level 2), `### ` (level 3), a list (`1. ` items), or a paragraph. Case names in `*italics*`. A literal asterisk (as in "at *3") is written `\*`.
- `authorities[].items[].pages` is typed by hand (see Known gaps).
- Not supported: footnotes (none are transcribed), block quotations (single spaced in filings, so they would not match), tables other than the generated ones, and images.

## Known gaps and open choices

1. **Table of authorities page references are typed, not generated.** The template does not find the pages where an authority is cited. The page references in the sample were taken from this sample's render (searched per body page), so they match this sample. They are not the filed pages, and they must be re-typed if the sample changes. A full brief needs generated references (a tier-1 gap for LR 7.8 on a complete filing); not solved here.
2. **Font.** The same finding as `../complaint/README.md`: the W.D. La. local rules name no typeface, so EB Garamond stays. The exemplar is Times New Roman 12 pt, and the text looks smaller than the exemplar. Switching to the vendored Liberation Serif is a question for David.
3. **Footnotes.** The exemplar uses footnotes (references to the complaint, "Doc. 1, p. 23" and the like). The sample omits them (the markers are left out of the text), and the template does not render footnotes. Not tested whether cmarker renders `[^n]` footnotes; left as a gap.
4. **Block quotations.** The exemplar's block quotations (the Armstrong and Webster passage at 60 F.4th 276) are single spaced; the template has no quotation directive, so a quotation would be double spaced. The sample replaces that quotation with a bracketed note.
5. **Page limit.** LR 7.1 and 7.8 cap a memorandum at 25 pages, exclusive of tables. The template does not count pages. The exemplar is 15 pages of body text plus tables and certificate.
6. **Table of authorities wrap.** A long entry (Alvarado) wraps and its page reference drops to the next line, with dot leaders on that line. Cosmetic; not corrected.
7. **Caption style and filer line.** The caption uses asterisks and the subtitle carries the filer line, as the exemplar does; the exemplar's title block differs in spacing. Recorded as ACCEPTED.
8. **Second filer.** The brief asks for one exemplar. Other W.D. La. Rule 12 memoranda were checked for text and format but not stored: Burroughs v. KTBS, LLC, 5:25-cv-01933, Doc. 15-1 (32 pages; Times New Roman; TOC and TOA; Shreveport; https://storage.courtlistener.com/recap/gov.uscourts.lawd.215021/gov.uscourts.lawd.215021.15.1.pdf) and Street v. Christ, 2:25-cv-01882, Doc. 29-1 (33 pages; Lake Charles; https://storage.courtlistener.com/recap/gov.uscourts.lawd.214913/gov.uscourts.lawd.214913.29.1.pdf). Tier 2 is not judged against two filers yet.

## Review of the rendered pages

Every page was rendered at 60 dpi and viewed after the last template change.

- Page 1 (caption, roman i): court title, caption with VERSUS, JUDGE DRELL, MAGISTRATE JUDGE PEREZ-MONTES, JURY TRIAL REQUESTED, the title and filer line, MAY IT PLEASE THE COURT and the opening paragraph. Pass.
- Page 2 (TOC, roman ii): entries to level 3, page numbers 1 to 6 matching the body pages (checked against the body headings). Pass.
- Page 3 (TOA, roman iii): cases, statute and other authorities with dot leaders and page references from the body search (see gap 1). Pass, with the wrap noted in gap 6.
- Page 4 (body 1): BACKGROUND, I. Factual background., the numbered list (1), (2) and the facts paragraph. Pass.
- Page 5 (body 2): II. Plaintiffs' claims with its two paragraphs, LAW AND ARGUMENT and its introduction. I. Legal Standard moves with its paragraph to page 6 (the orphan is fixed by `sticky`). Pass.
- Page 6 (body 3): I. Legal Standard and its paragraphs; II. heading with its first paragraph. Pass.
- Page 7 (body 4): Monell paragraphs; heading A with its first paragraph. Pass.
- Page 8 (body 5): the rest of A, heading B and its paragraphs (Edwards, Pembaur, Piotrowski). Pass.
- Page 9 (body 6): the rest of B, the bracketed note on the Armstrong quotation, CONCLUSION. Pass.
- Page 10 (body 7): date and signature block, CERTIFICATE OF SERVICE heading with its text and signature (the heading had stranded at the foot of page 4 in an earlier build; fixed). Pass.

## Engines

**docx** (`docx/reference.docx`, `docx/make-reference.sh`, `docx/lawd-motion-brief.lua`, `docx/render.sh`). Output: `usage/OUTPUT-lawd-motion-brief-lewis.docx`. **The `.docx.pdf` is BLOCKED** (below), so no page of the docx has been checked on a PDF.

- Build: `sh tools/render.sh --engine docx <this dir> usage/INPUT-lawd-motion-brief-lewis.md` runs `docx/render.sh` (pandoc, then the footer part for the front matter), which writes the `.docx`; the step that needs `soffice` then fails. Rebuild the reference with `sh docx/make-reference.sh`.
- *Matches typst (from the template, not measured on a rendered page):* EB Garamond 12 pt; body double spaced at an exact 24 pt pitch with a half-inch first-line indent; letter page with 1-inch margins; the front matter (caption, opening paragraphs, tables) numbered in lowerRoman from `i`, the body arabic from 1 (two sections); level 1 headings centered bold capitals, level 2 bold at the margin, level 3 bold italic; caption, title and subtitle as in the complaint; the table of contents as a TOC field over the heading styles; the table of authorities as entries with dot leaders and page references from the sample's frontmatter, grouped by category ("passim" as given); the signature block; the certificate of service. Every word of the sample is in the `.docx`, except the sample's own list markers (`1.`, `2.`), which are relabeled `(1)`, `(2)` as in typst (checked with pandoc's text export).
- *Differs:* the list labels and the caption asterisks are typed text and an estimate (as in the complaint). The TOA entries are typed text, not TA fields (see BLOCKED). The TOC is a field, not typed entries.
- *BLOCKED (docx.pdf and every gate on it):* `soffice` is not installed on this box (no conda-forge package, no root for apt): the `.docx` is written and `render-docx.sh` stops at the conversion. No `.check-docx.txt` stamp exists; there is no `checks.yaml` or `court.json` in this doc-type folder, so `tools/check.sh` does not apply here either.
- *BLOCKED items (per `docs/DOCX.md`, to be confirmed on a LibreOffice PDF):* the TOC page numbers (the TOC field is empty until Word or LibreOffice updates it: `updateFields` is set and the field is marked dirty, so Word asks on open; LibreOffice needs an update step that this box cannot run, so the TOC check is BLOCKED); the TOA page numbers, which are the sample's own typst pagination, not the docx's (they may be off by a page or more in Word or LibreOffice, and no TA fields are written: LibreOffice does not honor them, see `docs/DOCX.md`); every Gate 1 and Gate 2 check for the docx.
- *Not opened in Word or LibreOffice:* the no-repair check is not done. The `.docx` is a valid zip, every part is well-formed XML, and pandoc reads it back.
- *Preview only, not the checked PDF:* the eleven pages were converted with office2pdf (a converter, not LibreOffice, and not the checked PDF) and viewed at 60 dpi. The page-number format (roman front matter, arabic body) and the section structure came through; the exact line spacing and the style-level indents did not lay out as in the typst PDF (the same converter limit as the complaint, see that README). The page count of the preview (11) differs from typst (10), which cannot be attributed without a LibreOffice PDF.
