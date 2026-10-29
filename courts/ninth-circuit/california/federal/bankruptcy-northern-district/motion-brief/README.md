# canb: motion-brief

Doc type: **motion-brief**, a motion with its memorandum of points and authorities in one document in the United States Bankruptcy Court for the Northern District of California (`canb`): a contested matter (Fed. R. Bankr. P. 9013, 9014) or a motion in an adversary proceeding (Fed. R. Bankr. P. 7007, 7012(b)). B.L.R. 9013-1(b) lets the motion and the memorandum be combined and docketed together; the notice of hearing is a separate document.
Folder: `courts/ninth-circuit/california/federal/bankruptcy-northern-district/motion-brief/` (self-contained; the court-root `typst/` and `latex/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: two filings of two filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (Norton Rose Fulbright; primary, transcribed), `FILED-EXAMPLE-motion-brief-2.pdf` (Ross B. Jones). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 28-page motion to dismiss: caption, motion, memorandum with its preliminary statement, one background section and footnote, legal standard, argument IV.A.1, IV.A.2 in part, IV.B in part, conclusion, signature; see `usage/SOURCE.md`) |
| typeface | face required: none. Civil L.R. 3-4(c)(2)(A) (applied by B.L.R. 1001-2(a)) asks for "a standard, proportionally spaced font (e.g., Times New Roman or Century Schoolbook)", the names examples. Times New Roman 12 pt, the house standard (`docs/FONTS.md`) and both exemplars' face; typst names `("Times New Roman", "Liberation Serif")`, the generated engines the same face. |
| engines | typst (`typst/canb-motion-brief.typ` on `typst/layout.yaml`, an overlay of `lib/layouts/frcp-motion-brief.yaml` with the shared `pleading` key); latex and docx generated from the merged layout by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml`, `docx/xdoc.lua`; do not edit them by hand) |
| render | `usage/OUTPUT-motion-brief.{typst.pdf,latex.pdf,docx,docx.pdf}`, 16 pages each; letter, pleading paper (28 numbered lines), Times New Roman embedded only, no warnings |
| check.sh | typst 10 passed 0 failed; latex 13 passed 0 failed; docx 14 passed 0 failed; XENG-001..003 pass on latex and docx (16 = 16 pages, 0 of 16 page ends moved, 477/477 lines) |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt`; ours p.1 pairs with filed p.1 (91 % word overlap), the body pages with filed p.6-8 and p.15-20, p.26-27 (43-85 %; the transcription skips the redacted background) |
| pages rendered | 48 PNG (16 pages x 3 engines), `pdftoppm -r 60` into `.overlay/<doc path>/png/`; the pod that built this folder could not display images, so every page was reviewed from its text layer and line geometry (below), and the visual look is a PM live check |

## Commands

```
sh tools/render.sh [--engine latex|docx] courts/ninth-circuit/california/federal/bankruptcy-northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/ninth-circuit/california/federal/bankruptcy-northern-district/motion-brief [--engine latex|docx]
just overlay courts/ninth-circuit/california/federal/bankruptcy-northern-district/motion-brief
cargo run -q --release --manifest-path tools/fb/Cargo.toml -- engines gen courts/ninth-circuit/california/federal/bankruptcy-northern-district/motion-brief
```

## Governing rules

Primary source: Bankruptcy Local Rules, N.D. Cal. (effective May 4, 2026), https://www.canb.uscourts.gov/sites/default/files/attchments/Bankruptcy_Local_Rules_%28Effective%20May%204%202026%29%20with%201007-1%20Update.pdf (court-hosted PDF with a text layer, fetched and read 2026-10-29), and the N.D. Cal. Civil Local Rules it incorporates (Civil L.R. 3-4, as quoted in `../../northern-district/motion-brief/README.md`). Rule IDs are those of `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| B.L.R. 1001-2(a) | Civil L.R. 3-4 "Papers Presented For Filing" applies "except that ... subparagraph (c)(3) and subparagraph (e) shall not apply" | the rows below; no footer is required (3-4(c)(3) excluded) |
| Civil L.R. 3-4(c)(1) (CANB-MB-FORM-001) | 8½ x 11 inch paper with numbered lines | `margin`, `pleading`: 28 numbered lines of 24 pt, a double rule left of the text and a single one right |
| Civil L.R. 3-4(c)(2)(A)-(B) (CANB-MB-FORM-002) | a standard proportionally spaced font, 12 point or larger, footnotes included | the base's `size: 12`, footnotes 12 pt; Times New Roman |
| Civil L.R. 3-4(c)(2) (CANB-MB-FORM-003) | text double-spaced, no more than 28 lines a page, except counsel identification, title of the case, footnotes and quotations | `pitch: {body: 24, single: 12}`; 60 pt top and bottom margins (28 x 24 = 672 of 792 pt) |
| Civil L.R. 3-4(a)(1) (CANB-MB-FIRST-001) | counsel's name, address, telephone, e-mail and bar number at the upper left, with the party represented | `cover`: `{counsel}` and `{counsel_role}` in a box at least six numbered lines high |
| Civil L.R. 3-4(a)(3) (CANB-MB-FIRST-002) | starting on the eighth line (unless counsel needs more space): the court, the title of the action, the case number, the title of the paper | `cover`: the court title from line 8 at the earliest (line 11 in the sample, after 19 counsel lines), the caption, `brief_title` |
| B.L.R. 1005-1(a)-(c) (CANB-MB-FIRST-003) | the caption: the bankruptcy case's number and, where applicable, the adversary proceeding's, the debtor's name and the plaintiffs and defendants; the chapter; the date, time and location of the hearing | `cover`: "In re:", the debtor and designation, a rule, the adversary parties (`caption.parties`, optional); at the right `Case No.`, `Chapter`, `Adv. Pro. No.` (optional), the title, Date, Time, Judge, Place |
| B.L.R. 9013-1(b)(1)-(2) (CANB-MB-CONT-001) | the motion: "a concise statement of what relief or Court action the movant seeks"; the memorandum: "a statement of the issues to be decided, a succinct statement of the relevant facts, and the argument ... citing supporting authorities"; "may be combined and docketed together" | the body: the motion's paragraphs, then `# Memorandum of Points and Authorities` and its sections, numbered I., A., 1., a. by the layout |
| B.L.R. 9013-1(b)(3) | the notice of hearing "shall be docketed separately" | not built here (a separate paper) |
| B.L.R. 9013-1(c) (CANB-MB-CONT-002, -003) | memoranda "shall not exceed 25 pages of text" (reply 15); "Any memorandum exceeding 10 pages of text shall also include a table of contents and a table of authorities" | `contents` and `authorities` always set (keyed authorities, `toa:` links); the 25 pages of text are not counted (DEF-LEN-001 skips: the limit counts text pages, not the paper's) |
| Fed. R. Bankr. P. 9011(a); B.L.R. 5005-2(b) | signed by an attorney of record; a document filed through ECF "shall bear the typed name of each person purporting to have signed the document" | `closing`: Dated, the signers and firm, "By: /s/ {signer}", the typed name in the signer's lines |

## Frontmatter contract

```yaml
case_number: "23-40523 WJL"
chapter: "11"
adversary_number: "24-04053 WJL"      # optional: a motion in an adversary proceeding
court: [line, ..]                       # "UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF CALIFORNIA", the division
counsel: [line, ..]
counsel_role: [line, ..]
caption:
  debtor: {names: [line, ..], designation: "Debtor."}
  parties:                              # optional: the adversary proceeding's parties, "v." between them
    - {names: [line, ..], designation: "Plaintiff,"}
    - {names: [line, ..], designation: "Defendants."}
brief_title: "Motion ..."               # set in bold capitals
footer_title: "MOTION TO DISMISS COMPLAINT"
hearing: {date, time, judge, place}     # each optional
date: "January 24, 2024"
signature: {firm: [line, ..], signer, lines: [line, ..]}
authorities: {key: {kind: case|statute|rule|other, name, cite, sort}}
```

The body is markdown: the motion's paragraphs, `#` the memorandum's centered title, `##`, `###`, `####` its numbered sections; `[text](toa:key)` marks an authority's page; `[^n]` footnotes.

## Page review (2026-10-29)

Every page of every engine was rasterized and read from its text layer and line geometry against the exemplar (the latex and docx renders break every line and page where typst does: XENG-002/-003, 477/477 lines, so one reading of the line text covers all three; DEF-FORM-002/-004 cover the margins and line collisions on every page).

| PDF page | Printed | What it is | Finding |
|---|---|---|---|
| 1 | (i, unprinted) | counsel and role (lines 1-10), court title (11-12), caption: "In re:", debtor, rule, plaintiff "v." defendants, ruled at right and foot; at the right case number, chapter, adversary number, title in bold capitals, Date/Time/Judge/Place | as the exemplar's page 1 (DEF-COVER-002: 15 or 16 differences by engine, all ACCEPTED in `eval.yaml`: the exemplar's left-margin recycled-paper mark and its column pairing) |
| 2 | ii | table of contents, "Page" over the column | OK |
| 3-4 | iii-iv | table of authorities: cases (italic name, comma, citation), statutes, rules; "Page(s)" over the first group | OK |
| 5 | 1 | the motion's paragraphs, the memorandum's title, I. Preliminary Statement | OK |
| 6-15 | 2-11 | statement, background II.A and footnote 1, III legal standard, IV argument with A., 1., 2., B. | OK; headings kept with their paragraphs |
| 16 | 12 | IV.B's end, V. Conclusion, Dated, signers, "By: /s/ Rebecca J. Winthrop", the signer's lines | OK; the signature kept with the last paragraph |
| all | | footer: the page number centered, the paper's title under it, 10 pt | OK |

## Gate 2 findings (tier 2)

| Page | Finding | Status |
|---|---|---|
| all | Footer: Norton Rose prints the page number only ("- ii -", its document number and recycled-paper mark at the left); Ross B. Jones prints the number and the paper's title. B.L.R. 1001-2(a) excludes Civil L.R. 3-4(c)(3), so no rule asks for either; the template prints the number and the sample's `footer_title`. | ACCEPTED |
| all | Page numbering: Norton Rose counts the caption page as i (tables from iii after its motion page ii, memorandum from 1); Ross B. Jones numbers every page from 1 on the caption page. The template counts the caption page (unprinted), the tables from ii and the motion from 1. | ACCEPTED (tier 3) |
| 1 | Norton Rose sets the hearing labels in a tab column ("Date:    March 5, 2025") and the place on four lines; the template sets "Place:" and the place on one wrapping line. | ACCEPTED (tier 3) |
| 5 | Norton Rose puts its motion on a page of its own before the tables, signed; the template sets the motion's paragraphs at the head of the body, after the tables, signed once at the end, as Ross B. Jones orders caption, tables, body. | ACCEPTED (tier 3) |
| body | Norton Rose centers "I." on a line above each section's title; the template sets "I." in a half-inch box before the title (as the N.D. Cal. district motion brief). | ACCEPTED (tier 3) |

## Known gaps

- **Visual review (PM live check).** The 48 PNGs were rendered but could not be displayed in the pod that built the folder; a person should look at the pages once.
- **Characters per inch.** Civil L.R. 3-4(c)(2)(C) ("spaced no more than 10 characters per horizontal inch") cannot be met by a proportional 12-point face read literally; not enforced, as in `../../northern-district/motion-brief/README.md` (open question 1 there).
- **Partial sample; redactions.** The public copy of the exemplar redacts most of its factual background; the sample keeps one unredacted section, which the layout numbers II.A (II.B.6 in the filing). Italics: the case names are italicized in the sample as is usual; the exemplar's own emphasis is not visible to `pdftotext`.
- **Figure dashes.** The exemplar's U+2012 figure dashes are transcribed as en dashes: typst breaks a line at a figure dash where LaTeX and LibreOffice do not (a shared-model item, not taken on here).
- **Authority sort keys.** Every authority in the sample has an explicit `sort` of lower-case letters, digits and spaces: lib/typst/xdoc.typ `sort-key` lowercases a default key but does not strip its punctuation, as its comment and lib/pandoc/xdoc.lua `sort_key` do, so the engines ordered "Official Comm. ... (In re ...)" and "Official Comm. ..." differently (a shared-model follow-up).
- **Notice of hearing.** A separate paper (B.L.R. 9013-1(b)(3)); not built here.
- **Selftest.** `tools/check-selftest.sh` needs a folder-specific `checks.yaml`; this folder uses the default check set and adds no check, so the mutation selftest does not apply.
- **Judges' practices.** Some canb judges ask for PDF bookmarks to each heading in a memorandum (judge procedures, not B.L.R.); the typst render bookmarks its headings, the LaTeX and Word renders were not checked for them.
