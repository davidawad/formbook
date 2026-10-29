# gasd: motion-brief

Doc type: **motion brief**, the memorandum of law in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Southern District of Georgia (`gasd`). The brief lists the same paper as the "motion-brief" doc type in the brief: a motion and its memorandum, with a certificate of service.
Folder: `courts/eleventh-circuit/georgia/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption, Introduction, Statement of Facts, Argument A to I (all headings; paragraphs abbreviated in part, see Known gaps), Conclusion, signature, certificate of service |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages (typst), with `.latex.pdf` and `.docx`/`.docx.pdf` generated from the same layout; Times New Roman only, no typst warnings |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| typeface | face required: none named by the S.D. Ga. rules (LR 5.4, LR 10.1, LR 83.6; text checked 2026-10-14). Times New Roman, the house face where no rule names one (`docs/FONTS.md` rule 6). Fit: n/a |
| pages reviewed | 12 of 12 on every engine (2026-10-29, see "Gate 2 review") |

File names: as in the complaint folder, the tools' default names (`OUTPUT-`, `OVERLAY-`) are used in place of the brief's `<id>.pdf` and `<id>-overlay.pdf`.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Ga. LR 7.1(a) | "Absent prior permission of the Court, no brief shall exceed twenty-six (26) pages in length, inclusive of the certificate of service required by LR 5.1. Page numbering starts from the first page of a submission." Source: S.D. Ga. Local Rules, rev. June 2016, https://www.gasd.uscourts.gov/sites/gasd/files/Local_Rules_of_Civil_Procedure_Printable_rev_June_2016.pdf, retrieved 2026-10-14. | `eval.yaml` `page_limit: 26`, checked on every render. The sample is 12 pages. |
| S.D. Ga. LR 7.1(b) | "every motion filed in civil proceedings shall cite to supporting legal authorities. A motion and supporting memorandum (brief) may be filed as one document. Every factual assertion ... shall be supported by a citation to the pertinent page in the existing record". Same source. | Content of the sample (citations to "Compl. p. N"). Not checked by the template. |
| S.D. Ga. LR 10.1 | Papers "be double-spaced, be numbered on each page ... Page numbering shall begin on the first page of a submission". Same source. | the base: `pitch.body` 24 pt; `page_number` centered on every page. |
| S.D. Ga. LR 5.1 | "Each paper served other than by a United States Marshal shall include a certificate of the person or firm making service, his or its relationship to the parties, action, or proceeding, and the date, method, and address of service. The original of a certificate shall also be signed by the party or his attorney." Same source. | `after_tail` in `typst/layout.yaml`: caption, the statement of service (date, method, address for the unregistered party), signature. |
| S.D. Ga. LR 5.4 | Letter paper, 8 1/2 by 11 inches. Same source. | the base: letter paper. |
| S.D. Ga. LR 11.1 | Signature, counsel's name, complete address, telephone and State Bar Number. Same source. | `closing` in `typst/layout.yaml`. |
| Fed. R. Civ. P. 7(b)(1)(B), (C) | A motion "must state with particularity the grounds for seeking the order" and "state the relief sought". Fetched from https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Motion's title and conclusion ("WHEREFORE ... dismiss it in its entirety"). |
| Fed. R. Civ. P. 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." Fetched from https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14. | The layout still sets a certificate (when the sample gives `service`), because LR 5.1 requires one; the rule states the federal minimum, not the local requirement. |

### Currency of the local rules (for David to confirm)

- The text above is the **June 2016** printable local rules. The court's proposed 2026 revision (`SDGA_2026_Local_Rule_Proposed.pdf`; notice dated 2026-03-23; comment period ended 2026-04-22; effective date blank) would change LR Civ. 7(e): a combined motion and brief "shall not exceed 6,500 words" when typed, and 25 pages when handwritten. The 2016 text (26 pages, inclusive of the certificate) is the one in force unless the revision has been adopted; this was not confirmed.
- No S.D. Ga. rule sets a typeface, type size, or margins. Checked 2026-10-14 against the 2016 text (extracted with `pdftotext`): LR 5.4 sets paper size only, LR 10.1 says "double-spaced, be numbered on each page", and LR 83.6 concerns attorney appearance. The template uses Times New Roman at 12 pt (`docs/FONTS.md` rule 6) and 1-inch margins, the usual practice; these are choices, recorded in `typst/gasd-motion-brief.typ`. The exemplar is in Times New Roman (`pdffonts`).

## Layout

Set by `typst/layout.yaml` (the generic FRCP brief, `lib/layouts/frcp-motion-brief.yaml`, with this court's overlay; each value cites its rule or the exemplar where the rules are silent):

- Letter paper (LR 5.4), 1-inch margins, Times New Roman 12 pt, double-spaced at 24 pt (LR 10.1), 16.2 pt between paragraphs (`paragraph_gap`, the exemplar). Single spacing (13.8 pt lines) for the caption, quotations, footnotes and signature blocks.
- Court title: "IN THE UNITED STATES DISTRICT COURT / FOR THE SOUTHERN DISTRICT OF GEORGIA" (`constants`) and the division from frontmatter. Caption: the parties at the left (names; the designation 2 in in, a blank line below; "v." a blank line from each), ruled at their right and foot as the exemplar; "Civil Action No." and the number at the right on the first designation's line. The title bold capitals, underlined and centered, as the exemplar.
- Headings numbered by the layout, not typed: level 1 "I." (centered, bold capitals), level 2 "A." (bold, left), level 3 "1." (bold italic, left). Sample headings carry no numbers.
- Footnotes 12 pt, single-spaced. Quotations three quarters of an inch in on both sides, single-spaced.
- Signature (LR 11.1): "This the <date>." at the margin; from 3.2 in "Respectfully submitted," and each signer ("By: /s/", name, bar number, firm, address, telephone, e-mail, whom they represent); kept whole and with the last paragraph.
- Certificate of service (LR 5.1) on its own page with the caption repeated, CERTIFICATE OF SERVICE, the statement as the sample gives it (`service.text`), each party served by mail centered, the signer from 3.2 in.
- Pages numbered at the bottom center from page 1 (LR 10.1). The old "- N -" form is gone: LaTeX sets it as one word, so XENG-003 failed on every page; LR 10.1 asks only that each page be numbered.

## Markdown contract (for samples)

- Frontmatter: `title`, `division`, `case_label` (default "Civil Action No."), `case_number`, `caption.parties` (`names`, a list of lines; `designation`), `signature` (`date`, `signers`: `name`, `lines`), `service` (`text`, `unregistered`: a list of address line lists, `signer`: `name`, `lines`). The caption's old positional `caption.rows` (blank cells for spacing) became `caption.parties` and `case_number`; the certificate's words moved from the template to `service.text`, as the exemplar words them.
- Body: markdown set by the shared document model (`#` to `###`, paragraphs, lists, quotations, footnotes, `*italics*`).

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
4. **Layout at the end.** The signature block is kept whole and with the last paragraph of the conclusion (page 11); the certificate is on page 12.
5. **Length.** The 26-page limit (2016 text) is checked on every render (`eval.yaml` `page_limit: 26`); the 6,500-word limit of the 2026 proposal is not, as it is not in force.
6. **Second filer search** (done): CourtListener RECAP, `court=gasd`, `type=r`, memoranda and briefs in support of motions to dismiss, filed 2025 to 2026. The S.D. Ga. court site refuses non-browser downloads (HTTP 403 to curl), so the local rules were read from the copy retrieved through the fetch tool.

## Gate 2 review (12 of 12 pages, 2026-10-29, the FRCP-base render)

Every page of the typst, LaTeX and Word renders was read as its text layout and word boxes (`pdftotext -layout`, `-bbox`, and the rules of page 1 from `pdftocairo -svg`); the three break every line and page alike (XENG-001..003).

- Page 1: court title and division; the caption ruled at the parties' right and foot, the file number on the "Plaintiff," line; the title underlined in three lines; the opening paragraph with footnote 1; I. INTRODUCTION. Pass.
- Pages 2 to 4: II. STATEMENT OF FACTS, III. ARGUMENT AND AUTHORITIES, A. Legal Standard. Pass.
- Pages 5 to 10: B. to I., the RESPA quotation single-spaced and indented; no heading ends a page. Pass.
- Page 11: IV. CONCLUSION, the date line and the signature block. Pass.
- Page 12: the caption again, CERTIFICATE OF SERVICE, the pro se plaintiff's address centered, the signer. Pass.

## Engines

On the generic federal district brief since fb-595.17.5: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter (`docx/gasd-motion-brief.lua`) are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst (reference) | `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages | 12 checks passed, 0 failed | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` | 15 checks passed, 0 failed | PASS (296/296 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | 16 checks passed, 0 failed | PASS (296/296 lines) |

The LR 7.1(a) 26-page limit (the certificate of service included) is checked on every render (`eval.yaml` `page_limit`). The caption's foot rule is the outer box's bottom stroke around a box ruled at its right: a `{rule}` block in a column printed nothing in the Word render, and one box ruled at its right and foot drew a rule the cover check did not find in the typst render. No item is BLOCKED.
