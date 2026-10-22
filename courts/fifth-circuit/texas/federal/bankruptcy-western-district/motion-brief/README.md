# txwb: motion brief

Doc type: **motion** (a motion with incorporated argument, with the negative-notice form and a certificate of service) in the United States Bankruptcy Court for the Western District of Texas (`txwb`), filed in an adversary proceeding.
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 21-page filing, see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 9 pages (8 on the earlier EB Garamond render, before fb-595.68), typst 0.15.0, pinned Times New Roman only (`pdffonts`), no warnings |
| overlay | ok: `usage/OVERLAY-oakes-motion.pdf` and `OVERLAY-oakes-motion.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change; re-rendered and all 8 pages viewed again on 2026-10-14, font unchanged; both on the earlier EB Garamond render, before fb-595.68) |

File names follow the tools, not the brief's `<id>.md` shorthand: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf`, and the overlay `OVERLAY-<id>.pdf/.txt` (see `tools/overlay.sh`).

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Bankr. P. 9013 | A request for an order must be made by written motion that states with particularity the grounds for the relief. | Author content (the motion's paragraphs and argument). Not checked by the template. | Rule number from the task brief. Text not fetched in this run. |
| W.D. Tex. L.R. 9014-1(a) | Negative-notice form language, conspicuous, bold, at least 12 pt, placed immediately below the caption and before the body of the pleading. The six sentences are: "This pleading requests relief that may be adverse to your interests."; "If no timely response is filed within 21 days from the date of service, the relief requested herein may be granted without a hearing being held."; "A timely filed response is necessary for a hearing to be held."; "Any response must be timely filed with the United States Bankruptcy Clerk, Western District of Texas, [Clerk's office mailing address]."; "If a timely response is filed, the Court will then set a hearing on the Motion, and you will be provided with notice of the date, time, and place of the hearing."; "If you do not attend the hearing, the Court may decide that you do not oppose the Motion." | `negative-notice(meta)` and `negative-notice-block()`: bold, 12 pt, directly below the caption; the Clerk's address comes from the sample's `clerk_address`. | Fetched from https://www.txwb.uscourts.gov/l-rule-9014-1-contested-matters on 2026-10-14 (WebFetch; six sentences quoted separately). The page carries no revision date. |
| W.D. Tex. L.R. 9014-1 (other) | Responses must admit or deny each allegation; a reply is due 7 days after the response; motions for expedited hearing are separate pleadings with a proposed order; exclusions from the negative notice (matters without a hearing, matters under the Code, shortened timeframe). | Not generated. | Summarized from the same page (WebFetch). |
| Fed. R. Bankr. P. 9004(a) | A petition, pleading, schedule or other document must be clearly legible; common abbreviations are acceptable. | Typography: 12 pt Times New Roman, one-inch margins, double spacing. | Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. The rule sets no point size, margin or spacing. |
| Typeface (court-named face) | None named. FRBP 9004(a) and W.D. Tex. L.R. 9004 set no typeface, size, margin or spacing. The one face list in the local rules (Courier, Times Roman, Helvetica, Orator) governs the mailing matrix in complex Chapter 11 cases, not pleadings. L.R. 9014-1(a) sets bold, at least 12 pt, for the negative notice only. | Times New Roman, the house standard (docs/FONTS.md rule 6; EB Garamond before fb-595.68). Typeface row: no face required, no substitute. | Local rules text read from the 2014 redline on txwb.uscourts.gov, fetched 2026-10-14 (see Known gaps 12). |

Not produced by this template: a separate memorandum of points and authorities (the exemplar's argument is incorporated in the motion's numbered paragraphs, and no txwb rule requiring a separate memorandum was found; see Known gaps); a proposed order (a separate filing); the notice of hearing (a separate filing, set by the Court after a timely response).

## Layout

- Court title on three centered bold lines: IN THE UNITED STATES BANKRUPTCY COURT / FOR THE WESTERN DISTRICT OF TEXAS / DIVISION.
- Caption: left column with the debtor block ("In re:", debtor, "Debtor."), then the adversary parties (names, designation, "v." between the sides, one defendant name per line), closed by a rule on the right and bottom. Right column: "Case No." (bankruptcy case), chapter, and "Adv. Pro. No." (the adversary number).
- Negative-notice block: bold, 12 pt, directly below the caption, before the body (L.R. 9014-1(a)).
- Title of the motion, bold, centered, in capitals. Addressee line (TO THE HONORABLE ...) flush left.
- Lead-in (`lead_in`): unnumbered opening paragraph, as in the filing.
- Body: `#` headings are centered bold sections, unnumbered; `##` headings are centered italic sub-headings; `###` are bold italic. Blank-line-separated paragraphs are numbered 1, 2, ... (first-line indent). Markdown lists are lettered (a), (b), ... (the issues and the list of examples).
- Signature block: "Dated:" left, "Respectfully submitted," then each signer as "By: /s/ Name", the name and the signer lines, separated by -AND-, then the role lines (ATTORNEYS FOR ...).
- Certificate of service: centered bold heading, a paragraph (unnumbered), a two-column service list, and "By: /s/ Name" with the name.
- Footer: page number, centered.

## Markdown contract (for samples)

- YAML frontmatter: `division`, `debtor` (`name`, `case_number`, `chapter`), `caption.parties` (list of `{names, designation}`; `names` is one entry per line), `adversary_number`, `brief_title`, `addressee` (optional), `lead_in` (optional, unnumbered), `date`, `clerk_address` (required by L.R. 9014-1(a); see Known gaps), `signature` (`groups` each with `signer` and `lines`; `role` lines), `certificate` (`text`, `service` groups with `lines`, `signer`, `lines`).
- Body: `#` / `##` / `###` headings (not numbered by the author), paragraphs (numbered by the template), lists (lettered by the template).
- The certificate's text is written with "the undersigned", not a pronoun for the signer (the filing's pronoun is not recorded).

## Visual review (Gate 2 record, all 8 pages of the earlier EB Garamond render, before fb-595.68, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption with the full defendant list, negative-notice block (six sentences, bold, 12 pt) | OK. The notice is directly below the caption and before the body, as L.R. 9014-1(a) requires. Clerk address line wraps cleanly. |
| 2 | Title, addressee, lead-in, INTRODUCTION, paragraphs 1-5 | OK. Title bold and centered. |
| 3 | Paragraphs 6-10; THE MOTION TO DISMISS | OK. The heading stays with paragraph 10. |
| 4 | Paragraphs 11-15; THE AMENDED COMPLAINT; the two-line THE COMPLAINT LACKS heading | OK. |
| 5 | Paragraphs 16-20; lettered list (a)-(e); "As for the Alleged Securities Law Violations" (italic sub-heading) | OK. List lettered, items wrap with a hanging indent. |
| 6 | Paragraphs 21-27; "As for the Fraudulent Transfer Claim" | OK. |
| 7 | Paragraphs 28-29; "As for the Unjust Enrichment Count"; Conclusion (30); date, signature groups with By: /s/, -AND-, role | OK. Signature block kept together. |
| 8 | Certificate of service: text, two-column service list, By: /s/ signer | OK. |

## What was fixed during the build

- Paragraph spacing (same defect as the complaint folder): paragraph spacing now equals the body leading so the 24 pt pitch holds at paragraph breaks.
- Signature groups printed the signer's name twice (sample lines and the template's name line); the sample now lists the name once, in the template's position.
- The first paragraph had been typed as a list item (lettered); now a numbered paragraph.
- Conclusion moved to follow the argument (it was above the securities section in the first draft).
- Negative-notice text was the three-sentence form of the exemplar; it now follows the current six-sentence text of L.R. 9014-1(a).

## Known gaps and open choices

1. **Clerk's office mailing address is not verified (needs David or the court).** L.R. 9014-1(a) requires the filer to insert "the mailing address of applicable Clerk's office". The sample uses "903 San Jacinto Blvd., Suite 322, Austin, Texas 78701", taken from a court-site search result (WebSearch, 2026-10-14). The search did not confirm it as the mailing address for filings, and it noted a conflicting listing. The sample's `clerk_address` carries a comment saying so. Confirm with the court before this folder is treated as complete.
2. **Exemplar predates the current negative notice.** The exemplar (filed 2024) carries three of the six sentences in the current text (fetched 2026-10-14). The template follows the current text.
3. **Partial transcription.** The sample transcribes the caption (in full), the negative-notice, title, addressee and lead-in, filing paragraphs 1-9, 13-14, 16-17, 24-28 and 60-71, the signature, and the certificate of service. Filing paragraphs 10-12, 15, 18-23 and 29-59 are not transcribed. The template numbers the paragraphs it has from 1, so the numbers do not match the filing.
4. **Conclusion paragraph is numbered (30).** In the filing the "Conclusion" paragraph is unnumbered. The template numbers every blank-line-separated paragraph; a marker for an unnumbered paragraph is not added.
5. **Separate memorandum not produced.** The brief names "motion with memorandum", but the exemplar is a motion with incorporated argument (numbered paragraphs, no separate memorandum). No W.D. Tex. rule requiring a separate memorandum was located (not searched exhaustively). If the court requires one, the template needs a second document type.
6. **FRBP 9013 text not fetched.** The rule number is from the task brief; the rule's text was not read in this run.
7. **Italics.** The text layer has no italic markup, so the case names and "Id." are roman. The template italicizes `*...*`.
8. **Font.** Times New Roman, the house standard (`docs/FONTS.md` rule 6). The rules name no face (see Governing rules, Typeface), so no substitute is used. Before fb-595.68 the template was EB Garamond, which set smaller at 12 pt than the filed copy's Times.
9. **Spacing and margins are conventions.** Rule 9004(a) sets none; the layout follows the exemplar (double spacing, one-inch margins).
10. **One exemplar.** Tier-2 comparison needs two or three filers; only this one is saved. Other txwb motions are listed in `usage/SOURCE.md`.
11. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. Render and overlay were run; the visual review above is the Gate 2 equivalent.
12. **Local rules checked, one edition.** The W.D. Tex. local rules were read from the 2014 redline on txwb.uscourts.gov (fetched 2026-10-14). L.R. 9004 has no typeface rule for pleadings. The redline may be older than the current rules; the current text is not checked.

## Searches and sources

- Overlay (2026-10-14): the exemplar PDF is not committed to the repo (no `usage/*.pdf` in any court folder). It was downloaded from the URL in `usage/SOURCE.md` to `/work/artifacts/txwb-rules/usage/minns-motion.pdf` and passed as the third argument of `tools/overlay.sh`.

- Exemplar and other motions: see `usage/SOURCE.md`.
- L.R. 9014-1(a): https://www.txwb.uscourts.gov/l-rule-9014-1-contested-matters (WebFetch, 2026-10-14; the page carries no revision date). A courtrules.net copy exists at https://www.courtrules.net/courts/federal/bankruptcy-western-district-texas/local-rules/l-rule-9014-1.
- FRBP 9004(a): https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14).
- Clerk's office address: WebSearch, 2026-10-14; not confirmed (see Known gaps 1).

## Engines

**docx** (`docx/`): `sh tools/render.sh --engine docx motion-brief usage/INPUT-motion-brief.md` (a wrapper of `fb render --engine docx`) builds the reference document from `docx/reference.xml` (`base="xengine"`: the shared cross-engine recipe in the typst template's face), runs pandoc with `docx/txwb-motion-brief.lua`, then LibreOffice (`soffice --headless --convert-to pdf`). Times New Roman must be installed for LibreOffice (the pinned install, `docs/FONTS.md` rule 1). Checked on `usage/OUTPUT-motion-brief.docx.pdf`, 8 of 8 pages rendered at 60 dpi and viewed beside the typst pages, on the earlier EB Garamond render (then built from `docx/reference-parts/` by `docx/build-reference.sh`, since retired into fb render); the table and notes below are that review. The current `.docx.pdf` and typst PDF are 9 pages each.

| Layout | Matches typst | Differs (docx against typst, same sample) |
|---|---|---|
| Page count, Letter, 1 in margins, EB Garamond 12 pt (embedded; now Times New Roman) | 8 pages | none |
| Line pitch: 24 pt body, 13.8 pt single (exact spacing) | yes, to 0.1 pt in the caption, the negative notice and the signature | none |
| Caption, negative notice (six bold single-spaced lines, L.R. 9014-1(a)), title, addressee, lead-in | yes | none |
| Level 1 headings (centred bold), level 2 (centred bold italic, as the typst PDF renders them), level 3 | yes | heading to the paragraph below is about 5 pt larger |
| Numbered paragraphs (0.5 in first line, text at 1.02 in) and lettered list (a) | yes | numbers 10 and up do not push the text right (fixed tab; typst flows the number) |
| Signature block (By: /s/, -AND-), certificate of service (two-column list, signer) | yes | none |
| Footer page number | yes | none |

- **Vertical placement.** Same as the complaint: LibreOffice sets text about 11 pt lower inside exact 24 pt lines (about 3 pt in 13.8 pt lines). Pitch, margins and page breaks agree; the margins are not moved to compensate.
- **Headings** are 13.8 pt exact lines (8.6 pt lines clip the capitals of the level 1 headings in LibreOffice; rejected). Level 2 is bold italic because the typst output renders it so: its show rule says italic, but the typst PDF embeds BoldItalic on those pages.
- **Line breaks** fall on different words in a few lines (renderer metrics; both are left-aligned).
- Word was not available; it may paginate differently (`docs/DOCX.md`).

**docx BLOCKED:** none for the render. The gates (`tools/check.sh --engine docx`) were not run: the court has no `checks.yaml` or `rules.md` yet, so the checker cannot run on it. The evidence here is the render and the page-by-page review, not a stamp.
