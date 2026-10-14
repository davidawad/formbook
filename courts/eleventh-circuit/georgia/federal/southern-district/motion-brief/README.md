# gasd: motion-brief

Doc type: **motion brief**, the memorandum of law in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Southern District of Georgia (`gasd`). The brief lists the same paper as the "motion-brief" doc type in the brief: a motion and its memorandum, with a certificate of service.
Folder: `courts/eleventh-circuit/georgia/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-harper-1-25-cv-00203-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-harper-memorandum-mtd.md`: caption, Introduction, Statement of Facts, Argument A to I (all headings; paragraphs abbreviated in part, see Known gaps), Conclusion, signature, certificate of service |
| render | ok: `samples/OUTPUT-harper-memorandum-mtd.pdf`, 11 pages, `tools/render.sh`, vendored EB Garamond only, no typst warnings |
| overlay | ok: `samples/OVERLAY-harper-memorandum-mtd.pdf` and `samples/OVERLAY-harper-memorandum-mtd.txt` (page map) |
| pages reviewed | 11 of 11 (every page rasterized at 60 dpi and viewed after the last template change) |

File names: as in the complaint folder, the tools' default names (`OUTPUT-`, `OVERLAY-`) are used in place of the brief's `<id>.pdf` and `<id>-overlay.pdf`.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Ga. LR 7.1(a) | "Absent prior permission of the Court, no brief shall exceed twenty-six (26) pages in length, inclusive of the certificate of service required by LR 5.1. Page numbering starts from the first page of a submission." Source: S.D. Ga. Local Rules, rev. June 2016, https://www.gasd.uscourts.gov/sites/gasd/files/Local_Rules_of_Civil_Procedure_Printable_rev_June_2016.pdf, retrieved 2026-10-14. | Not enforced by the template. The sample is 11 pages, well inside the limit. |
| S.D. Ga. LR 7.1(b) | "every motion filed in civil proceedings shall cite to supporting legal authorities. A motion and supporting memorandum (brief) may be filed as one document. Every factual assertion ... shall be supported by a citation to the pertinent page in the existing record". Same source. | Content of the sample (citations to "Compl. p. N"). Not checked by the template. |
| S.D. Ga. LR 10.1 | Papers "be double-spaced, be numbered on each page ... Page numbering shall begin on the first page of a submission". Same source. | `body-leading` (24 pt pitch); `footer-number()` on every page. |
| S.D. Ga. LR 5.1 | "Each paper served other than by a United States Marshal shall include a certificate of the person or firm making service, his or its relationship to the parties, action, or proceeding, and the date, method, and address of service. The original of a certificate shall also be signed by the party or his attorney." Same source. | `certificate()`: caption, the statement of service (date, method, address for the unregistered party), signature. |
| S.D. Ga. LR 5.4 | Letter paper, 8 1/2 by 11 inches. Same source. | `page-w`, `page-h`. |
| S.D. Ga. LR 11.1 | Signature, counsel's name, complete address, telephone and State Bar Number. Same source. | `signature-block()`. |
| Fed. R. Civ. P. 7(b)(1)(B), (C) | A motion "must state with particularity the grounds for seeking the order" and "state the relief sought". Fetched from https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Motion's title and conclusion ("WHEREFORE ... dismiss it in its entirety"). |
| Fed. R. Civ. P. 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." Fetched from https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14. | The template still produces a certificate, because LR 5.1 requires one; the rule states the federal minimum, not the local requirement. |

### Currency of the local rules (for David to confirm)

- The text above is the **June 2016** printable local rules. The court's proposed 2026 revision (`SDGA_2026_Local_Rule_Proposed.pdf`; notice dated 2026-03-23; comment period ended 2026-04-22; effective date blank) would change LR Civ. 7(e): a combined motion and brief "shall not exceed 6,500 words" when typed, and 25 pages when handwritten. The 2016 text (26 pages, inclusive of the certificate) is the one in force unless the revision has been adopted; this was not confirmed.
- No S.D. Ga. rule found sets a typeface, type size, or margins. The template uses EB Garamond at 12 pt and 1-inch margins, the usual practice; these are choices, recorded in `typst/gasd-motion-brief.typ`. The exemplar is in Times New Roman (`pdffonts`).

## Layout

- Letter paper, 1-inch margins, EB Garamond 12 pt, double-spaced. Single spacing for the caption, quotations, footnotes, and signature blocks.
- Court title: "IN THE UNITED STATES DISTRICT COURT / FOR THE SOUTHERN DISTRICT OF GEORGIA / <DIVISION>" (the court lines are constants; the division is from frontmatter). Caption with a ")" column and "Civil Action No." with the number on the right. Title in bold capitals.
- Headings are numbered by the template, not typed: level 1 "I." (centered, bold capitals), level 2 "A." (bold, left), level 3 "1." (bold italic, left). Sample headings carry no numbers.
- Footnotes are 12 pt, single-spaced; a footnote reference in a heading works.
- Quotations are indented on both sides and single-spaced.
- Certificate of service on its own page with the caption repeated (LR 5.1). The recipient block for the pro se plaintiff is indented.

## What the overlay shows

`samples/OVERLAY-harper-memorandum-mtd.pdf`: our render in red, each page paired with the exemplar page sharing the most words (blue), multiplied, so text that agrees is black. Pairing is by word overlap, not by index; see the `.txt` for the map. The overlay is a diagnostic, not a score. Word overlap per page is 40% to 100% (page 10 pairs with exemplar page 18 at 100%, the signature page; the lowest, page 8, pairs with exemplar page 15, where the transcription abbreviates the text).

## Known gaps and open choices

1. **One filer.** Tier 2 was not judged against 2 or 3 filers. The CourtListener search also showed a 12(b) memorandum in *Swain v. NewRez LLC* (S.D. Ga., 2025, RECAP docket 70612194, doc 9 attachment); it was not saved, because the brief asks for one exemplar per doc type.
2. **Transcription is partial** (the brief asks for "a few pages of body"; the exemplar is 20 pages and the target is 8 to 14). Included in full: caption, title, Introduction, Statement of Facts, III.A to III.D, Conclusion, signature, certificate. Included with the paragraphs or citations listed here omitted:
   - III.E (RESPA): the *Echeverria v. BAC Home Loans* quotation and its sentence are omitted.
   - III.F (FHA): the parenthetical "(citing People Helpers Foundation, Inc. v. Richmond ...; Cass v. American Properties, Inc. ...)" is omitted.
   - III.G (IIED): the *Joyner* / *Turnbull* paragraph and the application paragraph ("Here, Plaintiff's allegations ...") are omitted.
   - III.H (unjust enrichment): the *Ridgeline*, *Hill*, *Brooks* and *Camp Creek* citations and the *JTL Consulting* citation are omitted.
   - III.I (implied covenant): the *American Casual Dining*, *Bryant*, and *U.S. Bank v. Phillips* citations are omitted, and so are the last two paragraphs of the section (the "Here, Plaintiff has not asserted" paragraph and the dismissal paragraph).
   Every heading in III.A to III.I is present, so the letters match the exemplar.
3. **Italics.** The exemplar uses an italic face (`TimesNewRomanPS-ItalicMT`), so case names are italic in the filing; the text layer does not say which words are italic, and per-word font data was not extracted. The sample is roman; the template italicizes `*...*` if a sample uses it.
4. **Layout at the end.** The signature block ("This the 27th day of February, 2026.", "Respectfully submitted", and the signer) moves to page 10 as one block, so the date line is separated from the WHEREFORE paragraph on page 9. The certificate is on page 11.
5. **Length.** The template does not check the 26-page (2016) or 6,500-word (2026 proposal) limit.
6. **Second filer search** (done): CourtListener RECAP, `court=gasd`, `type=r`, memoranda and briefs in support of motions to dismiss, filed 2025 to 2026. The S.D. Ga. court site refuses non-browser downloads (HTTP 403 to curl), so the local rules were read from the copy retrieved through the fetch tool.

[Formbook index](../../../../../../README.md) | [Federal courts in Georgia](../../README.md)
