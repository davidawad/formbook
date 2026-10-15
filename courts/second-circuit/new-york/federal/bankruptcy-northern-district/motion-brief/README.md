# nynb: motion-brief

Doc type: **memorandum of law in support of a motion** in the United States Bankruptcy Court for the Northern District of
New York (`nynb`). The exemplar is a memorandum supporting a Rule 12(b)(6) motion to dismiss in an adversary proceeding
(FRBP 7012(b)(6)).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-northern-district/motion-brief/`.

**Exemplar found (1 filer).** `exemplars/FILED-EXAMPLE-ef-consulting-v-gecc-10-90175-motion-brief.pdf` is a real, public,
text-based memorandum filed in this court (Adv. Pro. No. 10-90175, Dkt 6, January 2011; 42 pages). The sample is an excerpt
transcription of it: the caption, the Preliminary Statement, the Overview, Statement of Facts A to D, the Conclusion, the
signature block and the affidavit of service. Provenance and the search log are in `exemplars/SOURCE.md`. Tier 2 would
normally be judged against 2 or 3 filers; one filer is on file, so a second memorandum is still wanted.

| Item | Status |
|---|---|
| exemplar | **yes**: `exemplars/FILED-EXAMPLE-ef-consulting-v-gecc-10-90175-motion-brief.pdf` (42 pages, text layer) |
| sample md | `samples/INPUT-motion-brief.md`: excerpt transcription (7 body pages plus the conclusion, signature and affidavit, 7 rendered pages in all). The frontmatter comment lists what is omitted and why. |
| render | ok: `samples/OUTPUT-motion-brief.pdf`, 7 pages, letter, EB Garamond only (embedded), `tools/render.sh` exit 0, no typst warnings |
| overlay | ok: `samples/OVERLAY-motion-brief.pdf` and `.txt`, `tools/overlay.sh` exit 0. The overlay pairs our page 1 with the filing's page 8 (the filing's caption and text start on different pages; see the gaps). Word-overlap per page: 52.8, 78.4, 55.0, 61.6, 58.9, 76.1, 70.7 percent |
| pages reviewed | 7 of 7, each rendered at 70 dpi and viewed. The final change moved only the affidavit's date line (page 7), and page 7 was viewed again after it. |

The rendered sample is 7 pages, below the 8 to 14 pages that an excerpt of a 42-page filing would give if it were
transcribed in full. The transcription covers the caption and the body opening, then jumps to the conclusion; the
omitted middle (Points I to VII) is listed under the gaps. It is not padded to reach a page count.

File names: `INPUT-motion-brief.md`, `OUTPUT-motion-brief.pdf`, `OVERLAY-motion-brief.pdf/.txt` (id `motion-brief`).

## Markdown contract (frontmatter)

| Key | Meaning |
|---|---|
| `chambers_copy` | `true` prints `ECF CASE – CHAMBERS COPY` at the top right of page 1 (LBR 9013-1(h)). Omitted for the exemplar, which predates the rule. |
| `counsel` | list of lines, single-spaced, top left of page 1 (optional; the filing has none at the top, so the sample omits it) |
| `debtor.names`, `debtor.tin` | the debtor under "In re:"; the sample uses a TIN placeholder (see the gaps) |
| `case_number`, `chapter` | right column of the bankruptcy caption |
| `hearing.date`, `hearing.time`, `hearing.location` | printed above the case number (LBR 9013-1(g)(1); see the gaps). The exemplar has none. |
| `adversary` | optional. When present, an adversary caption is printed below the bankruptcy caption |
| `title` | centred bold title of the memorandum |
| `dated`, `signature.firm`, `signature.signer`, `signature.lines` | the date and signature block |
| `certificate.title` | optional heading of the certificate (default `CERTIFICATE OF SERVICE`; the sample uses `AFFIDAVIT OF SERVICE`) |
| `certificate.paragraphs`, `certificate.dated`, `certificate.signer` | the certificate printed after the signature block. `dated` is optional: a sworn affidavit carries its date in the jurat. |

Body: blank-line-separated chunks. `#` is a centred bold heading (PRELIMINARY STATEMENT, ARGUMENT), `##` a bold heading
flush left (a POINT), `###` a bold italic heading flush left. A chunk starting `>` is a block quotation, single-spaced and
indented on both sides. Every other chunk is an unnumbered, double-spaced paragraph with a first-line indent.

## Governing rules

Primary sources, fetched 2026-10-14 (the date verified for every row).

| Rule | Requirement | Kind | Where it is in the template |
|---|---|---|---|
| LBR 9004-1(a)(1)(A)-(E), (a)(2)(A)-(C) (N.D.N.Y. Local Bankruptcy Rules, effective 12-01-2024; the PDF used is https://www.nynb.uscourts.gov/sites/nynb/files/LBR_GenOrders/Local%20Bankruptcy%20Rules_Effective%2012-01-2024%20Final.pdf) | 12-point minimum (text and footnotes); double-spaced except block quotations and footnotes; legible, single-sided, black; one-inch margins on all four sides; consecutively numbered pages; letter size | M | `type-size`, `pitch`, `body-leading`, `margin`, page numbering, `paper: "us-letter"` |
| LBR 9004-1(c) | Caption: court name, case title, case number and chapter, last four SSN/TIN digits, adversary name and number if pertinent, short title naming the document and the party | M | `bankruptcy-caption`, `adversary-caption`, `title` |
| LBR 9013-1(a)(1) | The notice of motion sets out the specific relief, the party against whom it is sought, and the rule or statute relied on | M (for the notice of motion; the memorandum states the same) | the filing's Preliminary Statement names the motion, the rule (12(b)(6), via 7012(b)(6)) and the relief |
| LBR 9013-1(c) | A certificate of service on registered and non-registered users, stating the manner of service on each party | M | `certificate` (the exemplar's affidavit of service states first-class mail) |
| LBR 9013-1(e) | A motion is filed and served at least 21 days before the return date | A (timing) | not checked; the sample states no return date |
| LBR 9013-1(g)(1) | "The date, time, and location of the hearing shall be included above the case number in the caption." This sentence is in the answering-papers paragraph of the rule. | M for answering papers; applied here to the moving memorandum by convention | `hearing` lines printed above `Case No.` (the exemplar has no hearing block; see the gaps) |
| LBR 9013-1(h)(1)(F) (Albany) and (h)(2)(D) (Syracuse and Utica) | Chambers copy, marked "ECF CASE – CHAMBERS COPY", for memoranda of law | M (marking); delivery is an author duty | `chambers_copy` legend |
| LBR 7056-1(b) | Summary-judgment memorandum: cites all authorities and discloses controlling contrary authority | A (not this template's doc type) | none; the sample is a 12(b)(6) memorandum |
| FRBP 9013 (Cornell LII, fetched 2026-10-14) | "A request for an order must be made by written motion unless…" | M (the motion, not the memorandum) | content |
| FRBP 7012(b) and Fed. R. Civ. P. 12(b)(6), 9(b) (via FRBP 7009) | Motion to dismiss in an adversary proceeding; fraud pleaded with particularity | content | the exemplar's Preliminary Statement cites Rule 12(b)(6) and 7012(b)(6) |

Rows marked M are the tier-1 requirements. The exemplar (2011) predates the current LBR text in places: its caption has no
TIN line and no hearing block, and its cover page carries the firm block. Where the rules and the exemplar differ, the rules
govern and the template keeps its rule-based form.

## Tier-2 comparison with the exemplar (overlay and page review)

| Item | Filed exemplar | Template | Status |
|---|---|---|---|
| Cover page | a separate cover page: caption, title, and the firm block at the foot | the caption, title and text start on page 1 | ACCEPTED: the rules do not require a separate cover; one exemplar only. |
| Title | centred bold, in capitals, over several lines | centred bold | matches. |
| Headings | "PRELIMINARY STATEMENT", "OVERVIEW OF ADVERSARY COMPLAINT", "STATEMENT OF FACTS" centred; "A. Loan Documents" bold, flush left | the same | matches. |
| Conclusion and signature | "CONCLUSION" centred; "Dated:" left; firm block right | the same | matches; the `Dated:` line wraps in the sample. |
| Affidavit of service | "AFFIDAVIT OF SERVICE" with venue, jurat and notary block | the same heading; the jurat is a paragraph and the notary block is a paragraph | ACCEPTED: the template has no notary block; the content is complete. |

## Known gaps

1. **Table of contents and table of authorities: OPEN, not rendered.** The exemplar has both (pages i to vi, with the
   filer's page numbers). The template has neither; the rules found do not require them for this memorandum, and the
   sample omits them. A longer memorandum, or a judge's individual practice, may require them, and then a TOC and a TOA
   template must be added. Neither can be copied from the exemplar, because its page numbers belong to the filing.
2. **Footnotes: OPEN, not supported.** The exemplar has three footnotes. The template does not render footnotes, so the
   sample omits them and the reference numbers in the text. The 12-point footnote rule is stated but untested.
3. **Bullet lists: OPEN, minor.** The exemplar's bullets are indented lists. The sample renders each bullet as a paragraph
   that begins with "•" and a first-line indent.
4. **Hearing block above the case number on a memorandum.** LBR 9013-1(g)(1) puts the hearing above the case number for
   answering papers. The template applies it to the moving memorandum too, by convention, because the NDNY text found does
   not say where the hearing goes on a moving memorandum. The exemplar has no hearing block (it predates the rule). Confirm
   against the court's own practice or a second exemplar.
5. **One exemplar, so tier 2 is judged against one filer.** A second memorandum from a different filer is still wanted.
6. **Excerpt.** The sample transcribes printed pages 1 to 7 and the conclusion, signature and affidavit. Points I to VII
   (printed pages 8 to 33) are not transcribed, so the rendered sample does not show the argument.
7. **TIN placeholder.** The 2011 filing has no TIN line; the sample prints `TIN: xx-xxx0000` so that the rule-required line
   exists. The author supplies the real last four digits.
8. **Not rendered, author responsibility:** the notice of motion itself (LBR 9013-1(a)(1) requires the notice to state the
   relief, the party and the rule), the proposed order, the Statement of Material Facts for a summary-judgment motion (LBR
   7056-1(a)), the chambers copy's delivery (LBR 9013-1(h)), the 21-day service (LBR 9013-1(e)), and the adjournment and
   withdrawal forms (LBR 9013-1(i) to (n)).
9. **No gate checks.** There is no `checks.yaml` for this doc type, so `tools/check.sh` is not wired here and no stamp
   exists. Gates 0 and 1 are not run.
10. **Typeface.** LBR 9004-1 sets a minimum size, not a typeface. EB Garamond is our choice, vendored in `fonts/`.

## Engines

**docx** (`docx/`): `build-reference.sh` builds `docx/reference.docx` with the same styles as the complaint (EB Garamond
12 pt, exact 24 pt body lines, 13.8 pt single lines for the caption, block quotations and signature, 1 in margins, letter,
centred PAGE field); `docx/nynb-motion-brief.lua` builds the cover (chambers legend when given, counsel, court title,
bankruptcy and adversary captions, title), the body (headings and block quotations from the reference styles), the
signature block and the certificate of service. Output: `samples/OUTPUT-motion-brief.docx` and `.docx.pdf`
(LibreOffice). The `.docx` converts in LibreOffice with no error; the zip and XML parts are well formed.

- Matches the typst output: font and size, line pitch, margins, page numbers, caption layout and rules, headings
  (centred, flush left bold, bold italic), block quotation, the signature block before the affidavit of service, the
  affidavit. Page count 7 = 7; all 7 pages of the `.docx.pdf` were viewed beside the typst page.
- Differs: line breaks fall on other words, so text moves a line or two between pages. The caption right inset is 6 pt
  (typst: 10 pt), so the debtor line "HIGHGATE LTC MANAGEMENT, LLC, et al.," stays on one line as in typst; the rule is
  where typst puts it. The caption rules are table borders.
- BLOCKED: `docx`: no `checks.yaml` exists for this doc type, so `tools/check.sh --engine docx` cannot run (exit 2,
  "no such file"). No gate has been run on the docx; the `.docx.pdf` has not been checked against the rules.
