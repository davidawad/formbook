# sdd: complaint

Doc type: **complaint** in the United States District Court for the District of South Dakota (`sdd`, ca8).
Folder: `courts/eighth-circuit/south-dakota/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer, pro se; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the filed content of the exemplar; see below) |
| typeface | face required: **none** (D.S.D. Civ. LR 83.4 says only "Fonts must be at least 12-point"; checked in the official PDF 2026-10-14). Substitute: none; **Times New Roman**, the house standard (`docs/FONTS.md` rule 6), in typst and docx (EB Garamond until fb-595.68). Fit: n/a. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 3 pages, typst 0.15.0, pinned Times New Roman only, no warnings; `pdffonts`: TimesNewRomanPSMT and -BoldMT embedded |
| overlay | ok: `usage/OVERLAY-knosp-complaint.pdf` and `OVERLAY-knosp-complaint.txt`, built against the filed exemplar fetched from the RECAP URL in `usage/SOURCE.md` (the PDF is not in `usage/` in this snapshot; pass it as the third argument to `tools/overlay.sh`) |
| pages reviewed | 3 of 3 (every page rendered at 60 dpi and viewed again on 2026-10-14 after the fonts-pass re-render; the earlier EB Garamond render, before fb-595.68) |
| tier 2 | not met to the eval-loop standard: one filer, and that filer is pro se (see Known gaps) |

File names follow the repo convention used by `tools/render.sh` and `tools/overlay.sh` (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`), not the `<id>.pdf` and `<id>-overlay.pdf` names in the brief, because the tools read and write the repo names by default.

## Governing rules

Primary source: D.S.D. Civil Local Rules, the official PDF on the court's site: https://www.sdd.uscourts.gov/sites/sdd/files/local_rules/12-1-15%20CIVIL%20LOCAL%20RULES%20OF%20PRACTICE.pdf . Fetched and read 2026-10-14. The printed page footers say "12/01/2015", which is the version date; no later version was found on the court site in this pass.

Federal rules: Fed. R. Civ. P. 8, 10 and 12, from https://www.law.cornell.edu/rules/frcp/rule_8 , `rule_10` and `rule_12`, fetched 2026-10-14. Rule 10 is "amended Apr. 30, 2007, eff. Dec. 1, 2007"; Rule 12 is "Apr. 2, 2024, eff. Dec. 1, 2024"; Rule 8 is "Apr. 28, 2010, eff. Dec. 1, 2010" (as the notes on the pages).

| Rule | Requirement (quoted or closely paraphrased from the source) | Where it is in the template |
|---|---|---|
| D.S.D. Civ. LR 83.4 | "All documents must be on 8 1/2 x 11 inch paper. The text must be double-spaced, but quotations more than two lines long must be indented and single-spaced. Headings and footnotes must be single-spaced. Margins must be at least one inch on all four sides. Fonts must be at least 12-point." | `margin = 1in`; `pitch-double` (27.6 pt, Word's double spacing); `type-size = 12pt`; headings at `pitch-single` (13.8 pt); `paper: "us-letter"`. |
| D.S.D. Civ. LR 10.1(A) | "A pleading or other paper presented for filing must begin with the caption of the case, the title of the document, and the name of the party filing the document." | `cover(meta)`: court title, caption (parties), case number, title. |
| D.S.D. Civ. LR 10.1(B) | "All papers must be signed and include the typed or printed name, address, telephone number, and email address of the signer beneath the signature. This information must not appear as a header or footer on each page of the document, or as part of the caption of the case." | `signature-block(meta)` (the signature block is at the end of the body, not in the footer or the caption). |
| D.S.D. Civ. LR 5.1(A)(4) | The filing user's login serves as the signature; "Electronically filed documents must include a signature block" and the filing user's name "must be preceded by a '/ s /'". | `sig.pro_se` (a party without an attorney signs personally, with a line); otherwise "By: /s/" (attorney form). |
| Fed. R. Civ. P. 8(a) | "a short and plain statement of the grounds for the court's jurisdiction"; "a short and plain statement of the claim showing that the pleader is entitled to relief"; "a demand for the relief sought". | Sample sections: Basis for Jurisdiction, Statement of Claim, Relief (content supplied by the filer; the template does not check it). |
| Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." "The title of the complaint must name all the parties." | `court-title`, `caption` (names of all parties; case number; title). |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | `allegations()`: each paragraph is numbered 1, 2, ... ; a paragraph that starts with `~` is unnumbered (used for the certification, which is not an allegation). |

Jury demand: the template prints "JURY TRIAL DEMANDED" under the title when `jury_demand: true` (Fed. R. Civ. P. 38 requires a written demand; the rule is not quoted here because the template does not check it).

Not produced by this template: the civil cover sheet (JS 44), the summons, any Rule 7.1 disclosure, and any certificate of interested parties. These are separate filings; the exemplar's JS 44 is a separate page and is not transcribed.

No certificate of service is printed for the complaint: the complaint is served with a summons under Rule 4, not through CM/ECF. The motion brief template prints one (see `../motion-brief/README.md`).

## Layout

- Court title on top (three centered lines: "UNITED STATES DISTRICT COURT", "DISTRICT OF SOUTH DAKOTA", and the division, if given), then the caption: parties on the left (closed by a right and bottom rule), the case number, the title and "JURY TRIAL DEMANDED" on the right.
- No pleading paper and no line numbers: LR 83.4 does not require them, and the exemplar has none.
- Body double-spaced (27.6 pt pitch, `pitch-double`), first-line indent 0.5 in, numbered paragraphs. Headings are centered caps (level 1), bold (level 2), or bold italic (level 3), kept with the paragraph after them.
- Tables are single-spaced and not numbered (the exemplar's form uses party and defendant tables, and the sample keeps them as tables).
- Signature block at the end, kept on the same page as the last paragraph (so the signature is never alone on a page).
- Page number centered at the foot of every page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`, `division` (optional), `caption.parties` (list of `{names, designation}`), `brief_title`, `jury_demand` (true or false), `date`, `signature` (`signer`, `pro_se` (true or false), `lines`, and `firm` for an attorney's firm block).
- Body chunks separated by blank lines: `#`, `##`, `###` headings; a markdown table; a list (lettered (a), (b), ...); or a paragraph (numbered). A paragraph starting with `~` is unnumbered.
- Not supported: footnotes (the complaint has none), raw typst. The sample must not put the paragraph numbers in the text; the template numbers the paragraphs.

## Overlay (red/blue test)

`usage/OVERLAY-knosp-complaint.pdf` (measured on the earlier EB Garamond render, before fb-595.68): red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words, not by index (see `usage/OVERLAY-knosp-complaint.txt`):

- our p.1 over filed p.1 (41.6% word overlap)
- our p.2 over filed p.4 (49.4%)
- our p.3 over filed p.5 (17.7%)

The pairing is partial: the exemplar is a 7-page form whose entries sit on pages 1 to 6 among pre-printed labels and instructions, so the word-overlap score is low even where the content matches. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One filer, and it is pro se.** The brief asks for one exemplar per doc type, and EVAL-LOOP's tier 2 asks for two or three filers. The search (CourtListener RECAP, `court=sdd`, `type=r`, complaint queries; the API is limited to 5 requests a minute) found many complaints in this court, but only Knosp's has an available PDF. Tier 2 is therefore **not** judged against two or three filers. Whether a pro se AO form is a fair tier-2 reference for an attorney-drafted complaint is a question for David.
2. **Depth: 3 rendered pages, not 8 to 14.** The exemplar is 7 pages, but 6 of them are the AO form with its instructions and blanks; the filled content is about one and a half pages. The sample carries all of that filed content. No text was invented to reach a page count. A longer attorney-drafted complaint would be needed to test the body-text bar.
3. **Single spacing in the exemplar.** The AO form is single-spaced. LR 83.4 requires double spacing, so the template is double-spaced and the exemplar differs. The rule governs (the brief says the court's rules decide the layout; the exemplar settles only what the rules leave open).
4. **Sub-paragraph "A." became paragraph 2.** The form's "A. The federal statutes at issue..." is a separate paragraph in the sample and is numbered 2 by the template. This is the template's rule (each paragraph numbered), not a transcription error.
5. **Redactions.** Plaintiff's street address, telephone and e-mail are `[redacted]` in the sample, and the signature block shows the city only. Defendants' service addresses are kept (they are the registered-agent addresses). No SSN, birth date or financial-account number appears (LR 5.2).
6. **Jury demand.** The form's jury box is ambiguous in the text layer ("|^| Yes |_| No"). The docket text on CourtListener says "COMPLAINT with Jury Demand", so `jury_demand: true`.
7. **Signing date.** The text layer of the "Date of signing" line is illegible. The sample uses "July 21, 2026", the filing date stamped in the header, and says so in `usage/SOURCE.md`.
8. **Font.** LR 83.4 names no typeface, so the template is set in the house standard, Times New Roman (`docs/FONTS.md` rule 6; see the typeface row above). The filed exemplar is in a Times-style face too. The 12-point minimum is met.
9. **Caption.** The party column is closed by a right and bottom rule, not the ")" column of the form. Both are seen in filings; recorded as a tier-2 choice.
10. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` and are not run here; the brief says not to touch `tools/`. Render and overlay were run, and every page was reviewed.
11. **Page-number footer.** The number is centered at the foot of each page; the footer is not the case title (the complaint has no line-numbered pleading paper, so there is no required footer title).

## Review of the rendered pages (the earlier EB Garamond render, before fb-595.68)

- Page 1: court title (three lines), caption with parties, case number, title and "JURY TRIAL DEMANDED", the "I. The Parties" heading, the plaintiff table, the defendants table, the "II. Basis for Jurisdiction" heading and paragraph 1. Pass (tables do not run into the caption; the heading is kept with its paragraph).
- Page 2: paragraph 2 (sub-paragraph A, jurisdiction), "III. Statement of Claim" with paragraph 3, "IV. Relief" with paragraph 4, "V. Certification and Closing" with its sub-heading. No overlap between paragraphs (after the paragraph-spacing fix described in `../motion-brief/README.md`). Pass.
- Page 3: the unnumbered certification paragraph and the signature block (line, name, pro se label, address, telephone, e-mail), kept together and not orphaned. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

Typst is the primary engine (`typst/`). The DOCX engine is `docx/`: `fb render --engine docx` builds the reference document from `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst template's face; `docx/build-reference.sh` is retired) and runs pandoc with the filter `docx/sdd-complaint.lua`. Its outputs are `usage/OUTPUT-complaint.docx` and the LibreOffice PDF `usage/OUTPUT-complaint.docx.pdf` (3 pages). The BLOCKED items below were recorded before fb-595.68, when no `.docx.pdf` could be made here.

What the docx follows from the same rules as the typst template (checked in the style and section XML of the earlier `build-reference.sh` reference document, not on a render; the face, pitch and footer rows are updated from `docx/reference.xml`):

| Form item (LR 83.4 and the typst template) | DOCX |
|---|---|
| Times New Roman 12 pt, every style | `reference.xml`: the typst template's face (`{font}`), 12 pt (`size="24"` half points) |
| Double spacing, 27.6 pt pitch | body text: exact 27.6 pt line (`body="552"` twips) |
| Headings, tables, footnotes, caption, signature: single | `Heading1`-`3`, `Table`, `FootnoteText`, `Single`, `Compact` at single spacing |
| Margins 1 in, US Letter | `w:pgMar` 1440 twips on all four sides; `w:pgSz` letter |
| 0.5 in first-line indent | `BodyText` first-line indent 720 twips |
| Numbered paragraphs (Fed. R. Civ. P. 10(b)) | "N." then a tab to 0.94 in; `~` marks an unnumbered paragraph (the certification) |
| Caption: parties left, rule on the right and bottom | a 3-column table, 3.25 in party column, cell borders |
| Signature block at the end, kept with the last paragraph | `Dated` and the signature table; last paragraph in `BodyKeep` (keep with next) |
| Page number, centered, in the bottom margin | PAGE field in the footer, its line 36.75 pt above the page foot (`footer="735"` twips) |

Differences and open items:

- **Pagination is not checked** (recorded before fb-595.68; the committed typst and LibreOffice renders are now 3 pages each). The docx was never rendered or viewed then, so no line break, page break or page number of the docx is verified. Word and LibreOffice may paginate it differently from the typst PDF.
- **Page number position** is set in the footer distance, not copied from the typst PDF; it sits in the bottom margin, as in typst.
- **Footnotes**: none in this doc type.
- **Lists**: none in the sample; a docx list would be single-spaced (`Compact`), where typst double-spaces it.
- **Pro se line**: a bottom-bordered paragraph 3.2 in wide stands in for the typst signature rule.
- **Title block**: the docx omits pandoc's title block (`doc.meta` is cleared), so the date and the other frontmatter appear only where the template puts them.

docx BLOCKED items:

- `docx.pdf` (Gates 0 to 3 on the LibreOffice PDF of `OUTPUT-complaint.docx`): **BLOCKED**. LibreOffice is not on conda-forge and apt needs root. The Debian trixie LibreOffice 25.2.3 debs, extracted without root into a private prefix, abort at UNO bootstrap (`terminate called after throwing an instance of 'com::sun::star::uno::RuntimeException'`, also for `soffice --version`); the cause was not found. No `.docx.pdf` exists, so no docx Gate 0 to 3 result and no docx page was reviewed.
- Word: the `.docx` was not opened in Word (not available here), so the "opens without a repair prompt" check is not done. The package parts are well-formed XML (`xmllint`).
