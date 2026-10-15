# gasd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Georgia (`gasd`).
Folder: `courts/eleventh-circuit/georgia/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-atlantic-casualty-6-26-cv-00049-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-atlantic-casualty-complaint.md`: full text of the 15-page complaint (caption, paragraphs 1 to 47, prayer, signature). Exhibits A to E are not transcribed. |
| render | ok: `samples/OUTPUT-atlantic-casualty-complaint.pdf`, 8 pages, `tools/render.sh`, vendored EB Garamond only, no typst warnings |
| overlay | ok: `samples/OVERLAY-atlantic-casualty-complaint.pdf` and `samples/OVERLAY-atlantic-casualty-complaint.txt` (page map) |
| typeface | face required: none named by the S.D. Ga. rules (LR 5.4, LR 10.1, LR 83.6; text checked 2026-10-14). Substitute: none; EB Garamond kept, since the court names no face (`docs/FONTS.md`). Fit: n/a |
| pages reviewed | 8 of 8 (re-rendered and every page rasterized at 70 dpi and viewed on 2026-10-14) |

File names: the brief asked for `samples/<id>.md`, `samples/<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` read and write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, so the tool names are used. `tools/` was not edited.

## Governing rules

Primary sources. Quoted text was checked against these.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | `court-title()`, `caption()` (file number "CIVIL ACTION FILE / NO." from frontmatter), `title-block()`. |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs". Same source. | `allegations()`: each prose chunk is one numbered paragraph; headings, quotations and lists are not numbered. |
| S.D. Ga. LR 10.1 | Papers "be double-spaced, be numbered on each page, and contain an appropriate appearance as provided in LR 83.6. Page numbering shall begin on the first page". Source: S.D. Ga. Local Rules, rev. June 2016, https://www.gasd.uscourts.gov/sites/gasd/files/Local_Rules_of_Civil_Procedure_Printable_rev_June_2016.pdf (retrieved 2026-10-14). | `body-leading` (24 pt pitch, double spacing), `footer-number()` ("- 1 -" on every page, page 1 included). |
| S.D. Ga. LR 5.4 | "All pleadings and papers presented to the Clerk or Judge for filing shall be on paper which is 8 1/2 inches in width and 11 inches in length." Same source. | `page-w`, `page-h`. |
| S.D. Ga. LR 11.1 | Counsel's name, complete address (including street address), telephone number and State Bar Number. Same source. | `signature-block()`: firm, signers with bar numbers, address and telephone lines. |
| S.D. Ga. LR 83.6(a) | Filing a pleading constitutes an appearance by the signer. Same source. | Signature block. |

Not produced by this template (separate filings, or not required by a rule found): the civil cover sheet (Form JS-44; required by the 2026 proposal, LR Civ. 3A, and by practice); the Rule 7.1 disclosure statement; the summons; a certificate of service (a complaint is served with summons; LR 5.1 requires a certificate for papers "served other than by a United States Marshal", so a later paper would need one).

Not verified in this pass: FRCP 8(a) (the template does not check its content); S.D. Ga. LR 2.1 (cited in the sample's venue paragraph, which is the exemplar's text).

### Currency of the local rules (for David to confirm)

- The text above is the **June 2016** printable local rules. The court's website publishes a Notice of Opportunity for Comment (dated 2026-03-23) on proposed amendments with a comment period ending 2026-04-22. The proposed text (`SDGA_2026_Local_Rule_Proposed.pdf`) has a blank effective date. It was read but not confirmed as adopted. Its LR Civ. 3A (civil cover sheet) and LR Civ. 7 (brief length: 25 pages handwritten, 6,500 words typed) differ from the 2016 text; nothing in the complaint template depends on those.
- No S.D. Ga. rule sets a typeface, type size, or margins. Checked 2026-10-14 against the 2016 text (extracted with `pdftotext`): LR 5.4 sets paper size only, LR 10.1 says "double-spaced, be numbered on each page", and LR 83.6 concerns attorney appearance. The proposed text has none in the parts read. The template uses EB Garamond at 12 pt and 1-inch margins, the usual practice and what the exemplar's filer uses: the exemplar is set in Times New Roman (`pdffonts`), which EB Garamond approximates; EB Garamond has a smaller x-height at 12 pt, so the text looks smaller than the exemplar. These values are choices, not rule-driven, and they are recorded as such in `typst/gasd-complaint.typ`.

## Layout

- Letter paper, 1-inch margins, EB Garamond 12 pt, double-spaced (24 pt baseline pitch, from `body-leading = 1.35em`; single-spaced caption, quotations and signature).
- Court title in bold capitals (court name is a constant in the template; the division is from frontmatter). Caption: party column, a ")" column, and the file number on the right. Title in bold capitals, centered.
- No counsel block on page 1 (the exemplar has none; LR 11.1 is met in the signature block).
- Section headings (level 1) are centered bold capitals; count headings (level 2) are centered bold.
- Quotations are indented on both sides and single-spaced. The policy text in the exemplar is set in indented sub-blocks; the template runs each quotation into one indented paragraph (the text is the same; the indentation of sub-items is lost).
- Prayer items are lettered (a), (b) ...

## What the overlay shows

`samples/OVERLAY-atlantic-casualty-complaint.pdf`: each page of our render in red, paired with the exemplar page sharing the most words (blue), multiplied, so text that agrees is black. The pairing is by word overlap, not by page index, and the page map is in the `.txt`. The overlay is a diagnostic, not a score: the exemplar's own page breaks differ from ours, so a red-only or blue-only line is often a line that moved, not a missing line. Word overlap per page is 48% to 79%.

## Known gaps and open choices

1. **One filer.** Tier 2 (conventions a clerk expects) was not judged against 2 or 3 filers. The S.D. Ga. search found other complaints with available PDFs (Byrd v. Bryan County Jail, 4:26-cv-00259, 8 pages; Davis v. Marta, 2:26-cv-00093, 39 pages); they were not saved, because the brief asks for one exemplar per doc type.
2. **Typeface and margins are not rule-driven** (see Currency above).
3. **Paragraph number position.** The exemplar centers each number on its own line; the template puts the number at the start of the first line (a common convention; the rules leave it open).
4. **Layout at the end.** The WHEREFORE paragraph (¶ 47) stays at the foot of page 7 and the prayer and signature move to page 8, so the paragraph and its prayer are split across a page break. The prayer and signature are kept together (a signature never stands alone).
5. **Exhibits** (A to E) are not transcribed or generated.
6. **Italics.** The exemplar uses an italic face (`TimesNewRomanPS-ItalicMT`, `pdffonts`), so case names and signals are italic in the filing. The text layer does not say which words are italic, and no per-word font data was extracted, so the sample is roman. The template italicizes `*...*` if a sample uses it.
7. **Search for a second filer** (done): CourtListener RECAP, `court=gasd`, `order_by=dateFiled desc`, complaints filed 2026-08 to 2026-10. The S.D. Ga. court site refuses non-browser downloads (HTTP 403 to curl), so the local rules were read from the copy retrieved through the fetch tool.

## Engines

Typst (`typst/`) is the reference. The docx engine is `docx/`: `reference.docx` (rebuilt by `sh docx/make-reference.sh`) and `docx/gasd-complaint.lua`, which builds the cover, caption, lead-in, numbered paragraphs, lettered prayer and signature from the sample's frontmatter. Output: `samples/OUTPUT-atlantic-casualty-complaint.docx`.

- **Matches typst** (same settings in both templates): US Letter, 1-inch margins, EB Garamond 12 pt; double spacing as an exact 24 pt line pitch, 16.2 pt between paragraphs; single-spaced caption, quotations and signature; the caption as a borderless three-column table (3.1 in, 0.3 in, 3.1 in); "- N -" centered in the footer on every page, page 1 included; numbered paragraphs with a 0.5 in first-line indent; lettered prayer items "(a)" at 0.5 in with text at 0.9 in.
- **Differs from typst**:
  - Layout is **not verified**. This box has no LibreOffice, so no `.docx.pdf` was rendered and no page was looked at. Word and LibreOffice may paginate differently from the typst PDF.
  - The paragraph numbers ("1.", "2.") and the lettered items are typed text with a tab, not Word numbering, so they do not renumber when a paragraph is added.
  - Each paragraph of a quotation stays its own paragraph; typst runs a quotation into one paragraph.
  - A quotation's own lists keep Word's numbers ("1. Covered Property").
  - The signature block is kept together, but not with the last numbered paragraph before it (typst keeps the two together).
  - Headings are capitalized by the style (`w:caps`), so the text is as written in the sample.
  - Word and LibreOffice need EB Garamond installed (vendored in `fonts/eb-garamond`); it is not embedded.
- **docx BLOCKED**: the `.docx.pdf` gates (Gate 0 content, Gate 1 rules, Gate 2 page review, Gate 3 generalization, all measured on the LibreOffice PDF) cannot run. `soffice` is not installable here (no conda-forge package, no root), so `tools/render.sh --engine docx` stops after writing the `.docx`, and `tools/check.sh --engine docx` also needs the court's `checks.yaml`, which this court does not have yet. Word or LibreOffice opening the `.docx` without a repair prompt has not been checked. Pages reviewed for docx: 0.

[Formbook index](../../../../../../README.md) | [Federal courts in Georgia](../../README.md)
