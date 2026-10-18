# dcb: motion with memorandum

Doc type: **motion with memorandum** (a written motion under Fed. R. Bankr. P. 9013, with the supporting memorandum of facts and law in the same filing, Local Bankruptcy Rule 9013-1(b)(2)) in the United States Bankruptcy Court for the District of Columbia (`dcb`). Filed here as a motion to dismiss an adversary complaint.
Folder: `courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole 7-page motion and memorandum transcribed, plus the notice of motion and fill-in lines the rule requires and the exemplar lacks (gap 1) |
| typeface | face required: none (LBR and FRBP checked, see gap 2). Font: EB Garamond (`docs/FONTS.md`: "no face named" row) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond Regular, Bold, Italic, BoldItalic, all embedded), no warnings; re-rendered 2026-10-15 |
| overlay | ok: `usage/OVERLAY-swain-landing.pdf` and `OVERLAY-swain-landing.txt` (re-run 2026-10-15 against `usage/FILED-EXAMPLE-motion-brief.pdf`) |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi to PNG and viewed, 2026-10-15) |
| check gates | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this is a doc-type folder, and `tools/` is out of scope for this box |

File names: as in `adversary-complaint/README.md`, the tools' default names are used (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), and the sample is `INPUT-<id>.md`.

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief swain-landing
```

## Governing rules

Verified 2026-10-14. Local rules: the court's Local Bankruptcy Rules as attached to General Order 2025-01 (signed March 3, 2025; revisions effective April 1, 2025), https://www.dcb.uscourts.gov/sites/dcb/files/2025-03-03%20GO%202025-01%20signed%20w%20LBR.pdf (text read from the PDF's text layer). Federal rules: Cornell LII.

| Rule | Requirement | Where the template does it |
|---|---|---|
| Fed. R. Bankr. P. 9013(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9013) | A request for an order is made by written motion; a motion must state its grounds with particularity and set forth the relief requested. | the motion's lead-in and body (author text); `title` |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | Legible; caption with the court's name, the case title, the case and adversary-proceeding numbers, and a designation of the document. | `court-title()`, `caption()`, `title` |
| LBR 9013-1(b)(1)-(2) | Grounds and relief stated with particularity; a memorandum of facts and law may be filed with or combined with the motion. | the body; the memorandum is combined with the motion (no separate memorandum is required) |
| LBR 9013-1(c) | A motion in an adversary proceeding includes or is accompanied by a conspicuous notice of the motion, objection deadline and hearing, conforming substantially to Official Form B 420A (exception: a contemporaneous motion under LBR 9013-2). | `notice-box()`: a bordered notice with fill-in lines for the response deadline and the hearing (blank in the sample) |
| LBR 9013-1(d)(1)-(3) | No hearing set: the moving party serves a notice of opportunity to object and request a hearing, and the opponent may respond within 14 days. Hearing set on 21 days' notice: response due 7 days before the hearing. | `notice-box()` text; the day counts are not printed (the template does not compute dates) |
| LBR 9013-1(e)(2)-(3) | A response may include a memorandum; if no response is timely filed, the Court may treat the motion as conceded and grant it without a hearing. | `notice-box()` (the "no response" sentence) |
| LBR 9013-1(f) | Certificate of service for each motion: the date, the manner of service, and the names and addresses of each recipient not served through CM/ECF. | `certificate-of-service()`: date, manner, recipients, signer |
| LBR 5005-1(c) | First page: the attorney's name, bar number, office address, email, telephone and whom the attorney represents (footer or header permitted). | `counsel-block()` (upper left; asserts email and "represents") |

Verified in this pass: FRBP 9013 and 9004 (LII, quoted); LBR 9013-1(b)-(f) and 5005-1(c) (the court's attached LBR PDF). Not verified: Official Form B 420A (the notice form's own wording and fields, which LBR 9013-1(c) requires the notice to follow substantially), any page limit for a memorandum (none found in the rule text read; the judges' standing orders were not read), and any proposed-order requirement (not produced).

Not produced: a proposed order, the Exhibit A referred to in the motion (the Final Order), and any declaration.

## Layout

- Letter paper, one-inch margins on all sides; page number centred at the foot.
- Counsel block single-spaced in the upper left; court name in bold capitals; caption as a three-column grid with a column of ")" marks; the adversary number on the plaintiff line; the title in bold capitals centred.
- Notice of motion in a bordered box under the title (LBR 9013-1(c)), single-spaced.
- Body double-spaced: 27.6 pt between body lines at 12 pt (measured on the exemplar, pages 2 to 4). Paragraph spacing equals the leading, so consecutive paragraphs keep the same pitch. Block quotations are indented 0.5 inch on each side and single-spaced.
- Headings: level 1 centred bold; level 2 bold; level 3 bold italic and indented. Headings are single-spaced and kept with the text after them. The filer's own numbering (I., A., 1.) is typed in the sample and printed as written.
- Signature block after the body: "Date", "Respectfully submitted", the firm, "/s/", the signer and contact lines. The certificate of service follows on the same page where it fits.
- The template contains no case-specific text. Every name, number, date and paragraph comes from the sample.

## Known gaps and open choices

1. **Notice of motion (LBR 9013-1(c)).** The filed exemplar has no notice of motion, no objection deadline and no hearing, although the rule requires one for a motion in an adversary proceeding unless it is filed with a contemporaneous motion under LBR 9013-2. The template generates the notice; the sample leaves the response deadline and the hearing blank (the fill-in lines print as underscores), because the exemplar gives no date and the sample must not invent one. The notice's wording is not Official Form B 420A: it has not been checked against that form. A filer should use the form itself.
2. **Typeface and size.** As in the complaint README (gap 2), checked 2026-10-15 against the court's LBR PDF: no rule names a typeface or point size, so the template keeps EB Garamond at 12 pt (`docs/FONTS.md`: a court that names no face keeps EB Garamond). The exemplar is Times New Roman, 12 pt. Switching to Liberation Serif is a choice for David, not a rule requirement.
3. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The CourtListener API search (`type=r&court=dcb`, query "motion to dismiss" adversary) turned up Engelhorn (25-10044), Developer RE1 (25-10037), JPK NewCo (25-10015, entry 20, not checked) and Anglin Consulting (25-10032, entry 43, no PDF). None of those was checked for text and none was saved. The web search for a D.C. Bankruptcy motion found the court's local rules and general orders, not a filing. A second filer is needed for tier 2.
4. **Caption number.** The exemplar's caption says "Adversary No. 18-00173 MMH" but the ECF header says "Case 25-10013-ELG". The sample keeps the caption number as printed, and records the ECF number in `usage/SOURCE.md`.
5. **Certificate of service wording.** The exemplar's certificate says "Motion and Memorandum in Support of Debtor's Motion to Dismiss", which does not match the filer's own motion. The template's certificate says "the foregoing", so the sample's certificate differs from the exemplar's words on purpose.
6. **Typed numbering and typos.** The exemplar types its own heading numbers (I., A., 1.), so the template does not number headings. The transcription keeps the filer's wording and typos ("recission", "Similarly state law rescission", "§548(a)(B)(i)", "failure to state a Claim"). Italics for case names are not in the text layer, so the sample is roman (the template italicises `*...*` markup where the sample uses it).
7. **Overlay.** The sample is the whole motion, so the overlay pairs pages one-to-one (ours p.1 to p.7 with filed p.1 to p.7). The overlay is a diagnostic, not a score.

## Review of the rendered pages (re-rendered and viewed 2026-10-15, all 7 pages at 60 dpi)

| Page | Content | Finding |
|---|---|---|
| 1 | Counsel block, court name, caption (debtor, plaintiff, adversary number, defendants), title, notice box with fill-in lines, start of the lead-in | Pass. |
| 2 | Lead-in ends; I. INTRODUCTION (three paragraphs) | Pass. |
| 3 | II. LEGAL STANDARD; A heading (two lines, single-spaced); two block quotations; B heading | Pass after the fix: the heading lines were double-spaced before the template set single leading inside headings. |
| 4 | B heading continues; III. ARGUMENT; A heading (four lines); level-3 heading 1 and its paragraph | Pass. |
| 5 | Level-3 headings 2, 3 and 4 with their paragraphs | Pass. |
| 6 | B heading (three lines); B paragraphs; IV. CONCLUSION and its paragraph | Pass. |
| 7 | Date, Respectfully submitted, signature block; CERTIFICATE OF SERVICE with recipients and signature | Pass. |

Gate 2 rows for these pages are recorded here, not in `reviews/`: this doc type has no `reviews/` folder.

## Engines

Typst is the primary engine (`typst/`). The docx engine (`docx/`) is built here; there is no latex engine for this doc type.

| Engine | Folder | `usage/` output | Status |
|---|---|---|---|
| typst | `typst/` | `OUTPUT-motion-brief.typst.pdf` (rendered, not committed) | primary; not changed by the docx work |
| docx | `docx/` | `OUTPUT-motion-brief.docx` (committed); `.docx.pdf` is a LibreOffice render, kept out of the tree | built; 8 pages against typst's 7; see below |
| latex | none | none | not built |

**docx.** `docx/reference.docx` is generated by `docx/make-reference.sh` (pandoc's default reference, restyled: EB Garamond 12 pt; body double-spaced at 27.6 pt; single lines at 13.2 pt; headings with 13.8 pt above and below; 1-inch margins; a centred PAGE field in the footer). `docx/dcb-motion-brief.lua` writes the cover (counsel block, court title, the caption as a borderless table, the title, the bordered notice of motion), the signature block and the certificate of service from the frontmatter. The body is pandoc's: headings, paragraphs and block quotations (Word's Block Text style). Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md <out>.docx.pdf` (the `.docx` is written beside the PDF path).

What matches the typst render (every page of the docx PDF rendered at 60 dpi and viewed beside the typst page, 2026-10-15):

- the same words in the same order (a word-list diff of the two PDFs differs only at line-break hyphens and in the split of "Rooker–Feldman" and "Plaintiff's" at line ends);
- EB Garamond 12 pt, embedded (`pdffonts`); letter paper, 1-inch margins;
- the cover: counsel block, court title, caption columns, bold title, and the notice box with its fill-in lines (within 3 pt of the typst positions);
- headings (centred bold level 1, bold level 2, bold italic level 3 indented 0.5 in), block quotations, the signature block and the certificate of service.

What differs:

- **Pagination: 8 pages, typst 7.** Headings are kept with the text after them (Word's keep-with-next). The docx moves the "III. ARGUMENT" group, with its A heading and the first level-3 heading, to page 5, which leaves white space at the foot of page 4. The certificate of service is one unbreakable row, as the typst block is, so it moves to page 8 as a whole. Neither is forced; `docs/DOCX.md` says not to force breaks to match a renderer.
- **Level-1 headings.** Typst renders them larger than 12 pt (the cmarker heading inside `heading-line()`). The docx uses 12 pt bold. `typst/` is not changed here.
- **Baselines.** LibreOffice puts double-spaced baselines 2 to 3 pt lower than Typst does. The cover gaps are set from measured baselines (comments in `cover()`).
- **Word.** Not run. The file was opened in LibreOffice 26.8.1 without a repair prompt. Word may paginate slightly differently (`docs/DOCX.md`).

Not run and BLOCKED: `tools/check.sh --engine docx` (Gates 0 to 3). It needs a court folder with `checks.yaml`, `reviews/` and `rules.md`; this doc-type folder has none, and the change does not create them. No check ID was run. Nothing is stamped (`usage/.check-docx.txt` is not written).

Toolchain used for the LibreOffice render: the official LibreOffice 26.8.1 Linux build (documentfoundation.org), with X11 and pango libraries from conda-forge, and the vendored `fonts/eb-garamond` installed in the user's font directory so that LibreOffice finds it.
