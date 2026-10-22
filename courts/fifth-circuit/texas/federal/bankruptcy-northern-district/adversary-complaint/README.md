# txnb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Northern District of Texas (`txnb`).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-northern-district/adversary-complaint/`.

Exemplar: Prime Asset LLC v. PrimaLend Capital Partners, LP, adversary 26-09001 (Bankr. N.D. Tex., Fort Worth Division), Doc 1, filed January 7, 2026. Source and URLs in `usage/SOURCE.md`.

| Item | Status |
|---|---|
| typeface | face required: none (L.B.R. revised 12/1/2025 and 12/1/16 name no face for complaints). Substitute: none; **Times New Roman** (the house standard, `docs/FONTS.md` rule 6, and the exemplar's face; was EB Garamond before fb-595.68). Metric note: none needed. |
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (the whole 27-page filing, text layer present) |
| sample md | `usage/INPUT-adversary-complaint.md`: a transcription of the caption and counsel block, ¶¶ 1–37, the Count Six to Eight paragraphs, the prayer and the signature. Filing pages 10–24 (¶¶ 38–122, the factual allegations and Counts One to Five) are not transcribed; the sample marks the gap. |
| render | ok: `tools/render.sh` (typst 0.15.0, pinned Times New Roman only, no warnings) writes `usage/OUTPUT-adversary-complaint.typst.pdf`, 13 pages (11 on the earlier EB Garamond render, before fb-595.68) |
| overlay | ok: `tools/overlay.sh` writes `usage/OVERLAY-prime-asset-v-primalend.pdf` and `.txt`; every rendered page is paired with a filed page (see the page map in the `.txt`) |
| pages reviewed | 11 of 11 on the earlier EB Garamond render (every page of that render rasterized at 80 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14 (the date this folder was checked):

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7001 | Lists the proceedings that are adversary proceedings (recovery of money or property, lien validity, dischargeability, objections to discharge, injunctions, subordination, declaratory judgments, etc.). Fetched from https://www.law.cornell.edu/rules/frbp/rule_7001 on 2026-10-14 (paraphrased; the page's quote limit prevented verbatim quoting). | Scope of the document type only; the template does not check the claim category. |
| Fed. R. Bankr. P. 7003 | "Fed. R. Civ. P. 3 applies in an adversary proceeding." Fetched from https://www.law.cornell.edu/rules/frbp/rule_7003 on 2026-10-14. | Commencement by complaint; no template element. |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to a pleading in an adversary proceeding, except that the caption must substantially conform to Official Form 416. Fetched from https://www.law.cornell.edu/rules/frbp/rule_7010 on 2026-10-14. | Caption: `caption()` is the Form 416 layout (debtor on top, adversary parties under it, chapter, case number and adversary number on the right). |
| Fed. R. Bankr. P. 9004(a)-(b) | Papers must be clearly legible; a document presented for filing must contain a caption with (1) the court's name, (2) the case title, (3) the case number and adversary-proceeding number, (4) a brief designation of the document. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. | `court-title()` (court name), `caption()` (case and adversary numbers), `cover()` title line (designation: `title` frontmatter). |
| Fed. R. Civ. P. 10(b) (via Rule 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered; headings and lists are not; `[unnumbered]` marks a paragraph that is not numbered (prayer, jury demand). |
| L.B.R. 7001-1 | An adversary complaint is filed in the division where the related chapter case is pending (unless 28 U.S.C. § 1409 requires otherwise). Local rules revised 12/1/16, fetched from https://www.txnb.uscourts.gov/sites/txnb/files/local_rules/TXNB_Local_Rules_Revised_12.1.16_0.pdf on 2026-10-14. | `division` frontmatter, shown under the court name. |
| L.B.R. 7003-1 | Every adversary proceeding must be accompanied by an adversary proceeding cover sheet. (Same local rules copy.) | Not produced by this template. The cover sheet is a separate filing (see Known gaps). |
| L.B.R. 7007-2(a) | A brief shall be printed, typewritten, or presented in some other legible form. | Applies to briefs (see `motion-brief`), not to a complaint. |

No font, margin or line-spacing rule for complaints was found in the N.D. Tex. bankruptcy local rules (the copy above). The 12/1/2025 revision (read 2026-10-14 from its PDF text) was also checked: L.B.R. 5005-1(d) (form of pleadings: heading, style, caption, numbers and hearing line) names no typeface, so the face is not court-named and the template is set in Times New Roman, the house standard (`docs/FONTS.md` rule 6). The mailing-matrix type rule (10 to 14 pt, Courier, Times Roman, Helvetica or Orator) is for the matrix in a complex Chapter 11 case and is not applied to the complaint.

The local rules copy is dated "Revised 12/1/16". A later revision may exist on the court's site; this run did not find one. Recheck before filing.

## Layout

- Letter size, 1-inch margins, page number centered in the footer.
- Counsel block single-spaced at the top left (the N.D. Tex. bankruptcy local rules do not say where counsel goes; this is a convention).
- Court title centered and bold: UNITED STATES BANKRUPTCY COURT / NORTHERN DISTRICT OF TEXAS / DIVISION.
- Form 416 caption: left column, the debtor ("In re: ..., Debtor.") above the adversary parties ("Plaintiff. v. Defendant."), closed by a rule on the right and bottom; right column, Chapter, Case No., Adversary Proceeding No.
- Title centered and bold.
- Body double-spaced (27.6 pt pitch at 12 pt, Word's double, as the exemplar measures). Headings are set as written: level 1 centered bold (the template does not change their case, because `upper()` turned citation letters such as "(a)" into "(A)"); level 2 bold; level 3 bold italic. Headings keep with the paragraph that follows.
- Numbered paragraphs, first line indented 0.5 in. Lists are lettered (a), (b), ... by the template.
- Signature block: "Dated", "Respectfully submitted," the firm, "By: /s/ <signer>", bar number. Kept together on one block.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `caption` (`debtor` optional; `parties` as a list of `{names, designation}`; "v." is inserted between parties), `chapter` (number), `case_number`, `adversary_number`, `division`, `title`, `counsel` (lines), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. A `#` heading; a list (`1.`, `-`, `*`, `+`); or a paragraph. A paragraph is numbered unless it starts with `<!-- unnumbered -->` (an HTML comment, not printed).
- Not supported: tables, footnotes, raw typst. The template does not number paragraphs in the text itself.

## Known gaps and open choices

1. **Excerpt, not the whole filing.** The sample covers filing pages 1–9 and 24–27. Filing pages 10–24 (¶¶ 38–122 and Counts One to Five) are marked in the sample and not transcribed. Counts Six to Eight are unnumbered in the sample, because the template numbers paragraphs in sequence and the filing's numbers there (¶¶ 123 onward) would not match.
2. **Footnote and ECF header not reproduced.** Footnote 1 of the filing (the debtors' last-four EIN digits and headquarters address) is not transcribed: the markdown contract does not support footnotes. The ECF stamp at the top of each filed page is added by the court's system and is not part of the form. The filer's two-column counsel block is set as one column.
3. **Adversary cover sheet (L.B.R. 7003-1) and summons.** Not generated. The cover sheet is a separate filing that must accompany the complaint; the N.D. Tex. form is not in the vendored set, and the Southern District's B104 form found in search is not this court's form. Needs a decision.
4. **Certificates and proposed order.** Not part of a complaint in this template. A certificate of service of the summons may be needed; not in scope.
5. **Font.** No typeface rule was found for complaints in the 2016 or 2025 local-rules text, so the face is not court-named and the template is set in Times New Roman at 12 pt, the house standard (`docs/FONTS.md` rule 6) and the exemplar's face (EB Garamond before fb-595.68). Re-check if the court names a face in a later revision.
6. **Output PDFs.** `usage/OUTPUT-adversary-complaint.typst.pdf` and `usage/OVERLAY-prime-asset-v-primalend.pdf` (with `.txt`) are written where the tools put them. Regenerate with `sh tools/render.sh <this-folder> usage/INPUT-adversary-complaint.md` and `sh tools/overlay.sh <this-folder> prime-asset-v-primalend`.
7. **Paragraph numbering is not checked for continuity across sections or claim headings.** Numbering is by the template only; a complaint that restarts numbering per claim would need a change.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and `tools/` is out of scope for this box. The gates were not run.
9. **Signature block differs from the filing.** The template prints "Respectfully submitted," and the firm name above "By: /s/"; the filing has only the "Dated" line, the firm and the signers. Recorded here, not changed.

## Review of the rendered pages (Prime Asset transcription, 11 pages of the earlier EB Garamond render, before fb-595.68)

- Page 1: counsel block at top left; court title centered on three lines; Form 416 style caption with the debtor, plaintiff, defendants and the chapter / case / adversary numbers on the right; the title centered below. No overlap. Pass.
- Pages 2–8: ¶¶ 1–37 numbered in sequence; PRELIMINARY STATEMENT, JURISDICTION AND VENUE, PARTIES and FACTUAL BACKGROUND centered bold; sub-headings A and B bold; no orphaned heading. Pass.
- Page 9: the bracketed omission note (unnumbered), COUNT SIX and COUNT SEVEN with their unnumbered paragraphs. Pass.
- Page 10: COUNT EIGHT, the WHEREFORE line and relief items (a) and (b) with the hanging letter. Pass.
- Page 11: relief items (c) to (i), the date and the signature block, kept together. Pass.
- Overlay: the filed pages differ from ours in the places listed in Known gaps (ECF header, two-column counsel block, the omitted pages). The word-overlap scores (45–83%, on the earlier EB Garamond render) are a pairing aid, not a grade.
- Fixed in this pass: level-1 headings no longer pass through `upper()`, and headings are kept with the following paragraph (the first render had "(A)" for "(a)" in a heading).

Earlier template versions overlapped headings and body text (block-wrapped paragraphs with `context`); the final version puts paragraphs in plain content separated by `parbreak()`, which fixed it. Both pages were re-reviewed after that change.

[Formbook index](../../../../../../README.md) | [Court README](../README.md)

## Engines

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`: `fb render --engine docx` builds the reference document from it, the shared cross-engine recipe in the typst template's face) and `docx/txnb-adversary-complaint.lua`. Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-adversary-complaint.md` (a wrapper of `fb render --engine docx`) writes `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (13 pages, the same count as the typst output; 11 on the earlier EB Garamond render).

- Matches typst: US Letter with 1 in margins; Times New Roman 12 pt (`pdffonts` on the `.docx.pdf` shows only Times New Roman, no fallback face); body double-spaced at a 27.6 pt line pitch, 0.5 in first-line indent, no space between paragraphs; counsel single-spaced at top left; court title bold, centered, in 13.8 pt single lines; Form 416 caption as a borderless table with the party column ruled on the right and bottom; title bold and centered; numbered paragraphs with the number in a half-inch box after the first-line indent, as the typst template does; lists lettered (a), (b), ...; headings (level 1 centered bold, level 2 bold, level 3 bold italic) kept with the next paragraph; signature block kept together; page number centered in the footer.
- Differs (recorded on the earlier EB Garamond render, then built by `docx/build-reference.sh`, since retired into fb render): (1) LibreOffice places the text of a 24 pt line about 4 pt lower than typst does, so each page holds the same lines but the first line starts about 4 pt lower; margins are unchanged. (2) Paragraph numbers are typed text, not Word list numbering (no automatic renumbering). (3) Word's natural line height for EB Garamond can differ from LibreOffice's, so Word may paginate slightly differently. (4) No footnotes in this doc type; if used, the `Footnote Text` style is 12 pt, single-spaced.
- Pages reviewed (docx): 1-11 of 11 of the earlier EB Garamond render, each rendered at 60 dpi and viewed, side by side with the typst page where the layout was compared.
- BLOCKED: none for the sample. Not applicable: table of contents (this doc type has no TOC) and table of authorities (not generated by the typst template either, see Known gaps 1 and 3).
- Gates: `tools/check.sh` was not run for the docx engine on this folder. The gate harness expects a court folder with `court.json` and `checks.yaml`, which this doc-type folder does not have.
