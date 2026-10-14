# U.S. Bankruptcy Court, D. Utah (utb): motion with supporting memorandum (`motion-brief`)

- Court: `utb`, United States Bankruptcy Court for the District of Utah (`courts/tenth-circuit/utah/federal/bankruptcy-district/`)
- Doc type: `motion-brief`. One motion and its memorandum in one document (LBR 9013-1(c)(1), as the exemplar's own title and the rule's text describe it).
- Exemplar: `exemplars/FILED-EXAMPLE-plaza106-26-02063-motion-brief.pdf` (*Plaza 106, LLC v. First Utah Bank*, Adv. No. 26-02063, Doc 32, filed 2026-07-06, 16 pages; provenance in `exemplars/SOURCE.md`). Re-downloaded 2026-10-14 from the RECAP URL in SOURCE.md; the file is the filed PDF as served by RECAP.
- Sample: `samples/INPUT-plaza106-motion-to-dismiss.md`, an **abridged** transcription of the filed motion (see Known gaps). Renders to 13 pages.
- Status: template built, sample rendered, overlay produced, all 13 pages viewed. Not reviewed by a human; `court.json` untouched; no `rules.md`, no checks, no stamp.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `utb-motion-brief`. |
| `typst/utb-motion-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (7,750), `required-sections` (relief-sought section first, conclusion last), caption court lines, font, sizes, margins. |
| `samples/INPUT-plaza106-motion-to-dismiss.md` | Markdown contract sample (frontmatter: caption, counsel, signature, date, service, authorities; body). |
| `samples/OUTPUT-plaza106-motion-to-dismiss.pdf` | `sh tools/render.sh courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief samples/INPUT-plaza106-motion-to-dismiss.md` (13 pages; typst exit 0, no warnings). |
| `samples/OVERLAY-plaza106-motion-to-dismiss.pdf`, `.txt` | `sh tools/overlay.sh courts/tenth-circuit/utah/federal/bankruptcy-district/motion-brief plaza106-motion-to-dismiss` (red = ours, blue = filed, black = both agree; pages paired by shared words). The `.txt` is the page map. |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

Fonts: `pdffonts` on the render lists EB Garamond Regular, Bold and Italic, all embedded (CID, Identity-H). No fallback font.

## Governing rules

No primary text was read for this court. The governing documents are the District of Utah Local Civil Rules (DUCivR, which the bankruptcy local rules incorporate) and the Local Bankruptcy Rules (LBR). The courtrules.net copies of DUCivR 7-1 and LBR 9013-1 returned HTTP 403 to both WebFetch and curl, and the utd.uscourts.gov and utb.uscourts.gov rules PDFs returned 404 from this box. What follows comes from search-result summaries and the exemplar itself. **Each row is unverified against primary text** and must be checked before this doc type is called tier 1 (see Known gaps).

| Rule | Requirement (as summarized) | Where the template uses it | Verified? |
|---|---|---|---|
| DUCivR 10-1 | Typeface must be legible, at least 12 pt, footnotes included. Double-spaced text; block quotes and footnotes may be single-spaced. Top margin at least 1½ in; other margins at least 1 in. Consecutive page numbers. | `type-size = 13pt` (above the 12 pt minimum), `body-leading` (double), `page-margin` (top 1.5 in, others 1 in), footer page numbers | No. Secondary summary only (search result for DUCivR 10-1, extended). |
| DUCivR 7-1(a)(4)(A) (as cited in the exemplar and in search summaries) | A motion under Rule 12(b), 12(c) or 23(c) may not exceed 25 pages or 7,750 words; reply 10 pages or 3,100 words. Word-count certificate. | `word-limit = 7750`, panic above it; `certificate-of-compliance` prints the template's own count of the body | No. The 7,750 figure appears in several summaries; the 25-page limit is not enforced by the template (see gaps). |
| DUCivR 7-1 (exemplar p. 15) | The filing cites "DUCivR 7-1(a)(4) (incorporated by LBR 1001-1(a))" for the word-limit certificate. | certificate wording follows the exemplar | Only as the exemplar states it. |
| LBR 9013-1(c)(1) (as cited by the exemplar's title and summaries) | The motion and any supporting memorandum are one document; the document opens by stating the relief sought and the grounds. | `required-sections` (first section must be the introduction and relief sought; conclusion last) | No. Summary text only; a page cap was not found in the excerpts and the 15-page limit that `exemplars/SOURCE.md` attributes to LBR 9013-1(h) was **not** found (a 15-page cap in search results belongs to the District of Guam's rule 9013-1). |
| Fed. R. Civ. P. 10(a) / Fed. R. Bankr. P. 9004 and 7010 (caption) | A caption with the name of the court, the title of the case, and the document title. | `court-lines` ("IN THE UNITED STATES BANKRUPTCY COURT / FOR THE DISTRICT OF UTAH"), `caption-table`, `brief_title` | No. The filed exemplar's text does not show a court name line (its page 1 starts with counsel and then the caption); the court-name lines are a convention added here, not copied. |
| Fed. R. Civ. P. 9(b), 12(b)(6), 12(d) (as cited in the motion) | Cited in the content only. Not a format rule. | none (citations are content) | n/a |

## What the overlay shows

`samples/OVERLAY-plaza106-motion-to-dismiss.pdf` pairs our pages with filed pages by shared words (`samples/OVERLAY-plaza106-motion-to-dismiss.txt`). Pages 1 to 9 pair with filed pages 1 to 9 (the abridged sample starts with the same caption and TOC/TOA positions); from page 10 on, our pages pair with filed pages 12, 14, 15 and 16, because the filed motion has more body text before the conclusion and the sample omits part of it.

Visible differences, in tier order:

- **Tier 1**: none found against the rules as summarized. The mechanical gates have not been written (no `checks.yaml`), so this is a reading, not a check.
- **Tier 2, to fix or accept (Gate 2 not recorded):**
  - Caption: the filed caption draws a horizontal rule between the "In re" block and the adversary caption and a full grid; ours draws a right and bottom rule only. Accepted as a difference of style (one filer's layout), pending the second exemplar.
  - Caption: the filed page carries the CM/ECF header ("Case 26-02063 Doc 32 Filed ..."). The template does not produce it; the court's ECF system adds it at filing, so it is not a template defect.
  - Headings: the Argument's point headings (`I.`, `II.`) are bold and left-hung in ours. The filed motion's point headings were not compared on the page (only its text was read), so this is open, not accepted. Accepted only after a second motion exemplar shows the convention.
  - Certificates and service list: ours are double-spaced (the certificate of compliance) and single-spaced (the service list). The filed certificates were not compared on the page.
- **Tier 3 (not chased):** pilcrow and paragraph-number spacing, italic weight of *Id.*, the exact line breaks in the filed text.

## Known gaps

1. **Rules not verified against primary text.** The DUCivR and LBR text was not reachable from this box (403/404). Every row in the rules table marked "No" needs checking against the current DUCivR 7-1, DUCivR 10-1 and LBR 9013-1 before the template is called tier 1. In particular: the top-margin figure (1.5 in), the 12 pt minimum, and the typeface rule. The 13 pt choice is ours (a size above the minimum, chosen so the vendored EB Garamond reads at the size the filed Times New Roman 12 pt reads at); if DUCivR 10-1 requires 12 pt, 13 pt is still compliant.
2. **`exemplars/SOURCE.md` says LBR 9013-1(h) imposes a 15-page limit.** Our search found no such Utah rule (the 15-page limit found belongs to the District of Guam). The filed motion is 16 pages including caption, tables and certificates, so the length claim in SOURCE.md should be checked. This README does not change SOURCE.md; flagging it for the reviewer.
3. **Only one exemplar.** Tier 2 needs 2 or 3 filings from different filers. The motion-brief folder has one (Plaza 106). The adversary-complaint folder has two, but a complaint is a different doc type. SOURCE.md records Power Block Coin's Doc 5 as a pointer only (its memorandum is not in RECAP). Tier 2 can't be judged against a second filer until one is added.
4. **Sample is abridged.** The transcription covers the caption, the introduction, the statement of issues, the background, the legal standard, Part I.A and I.B, Part II.A, the conclusion, and both certificates. It omits Part I.C, Part II.B and Part II.C, and the Count Two passage. The sample body is 1,937 words as counted by the template, against 3,285 in the filed certificate, so the word-count certificate in the rendered sample does not match the filed one. This is expected: the certificate states the count of the text in the sample.
5. **Page limit not enforced.** DUCivR 7-1 (as summarized) also caps a Rule 12(b) motion at 25 pages. The template checks only the word limit. The sample is 13 pages, so it is under either cap; a longer motion would not be caught by the template.
6. **No mechanical gates.** There is no `rules.md`, `checks.yaml` or `reviews/` for this doc type, and `tools/check.sh` was not run. The render and overlay were produced; the page review above is a reading of all 13 rendered pages, recorded here and not as a Gate 2 row.
7. **Latex and docx engines not built.** Only the typst engine exists for this doc type.
8. **Exemplar PDF restored, not tracked in the box snapshot.** The box snapshot has no PDFs; the exemplar was re-downloaded from the RECAP URL in `exemplars/SOURCE.md` (`storage.courtlistener.com/recap/gov.uscourts.utb.478798/gov.uscourts.utb.478798.32.0.pdf`, 470,061 bytes, `%PDF-1.7`). Its checksum was not compared with a prior copy because none exists in the box.
