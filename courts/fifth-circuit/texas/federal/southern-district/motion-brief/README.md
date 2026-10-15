# txsd: motion-brief

Doc type: **motion-brief**: a Rule 12(b)(1) and 12(b)(6) motion to dismiss with its memorandum in one document (the Houston Division form; the Galveston Division form, which forbids a separate memorandum, is not the same document).
Folder: `courts/fifth-circuit/texas/federal/southern-district/motion-brief/` (the court-root `typst/` and `samples/` are untouched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-dangelas-4-26-cv-04908-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-dangelas-motion-brief.md` (portions of the 22-page filing; see the sample's header) |
| typeface | face required by the retrieved rules: none named (LR10.2, Judge Hanks Procs. 7.A, Galveston f.). Substitute: none; **EB Garamond kept** (`docs/FONTS.md`, "No face named"). Embedded: EB Garamond only (`pdffonts`). |
| render | ok (re-run 2026-10-14): `samples/OUTPUT-dangelas-motion-brief.pdf`, 10 pages, typst 0.15.0, `tools/render.sh`, vendored fonts only, no warnings |
| overlay | ok (re-run 2026-10-14): `samples/OVERLAY-dangelas-motion-brief.pdf` and `samples/OVERLAY-dangelas-motion-brief.txt` |
| pages reviewed | 10 of 10 (re-rendered at 60 dpi and every page viewed on 2026-10-14; the layout is unchanged from the earlier review, which is listed below) |
| BLOCKED | none for the template. The table of authorities is not produced (see Known gaps 3). |

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption: court name, title, file number, Rule 7(a) designation. | `court-title`, `caption-section` (the § form). | Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 |
| Fed. R. Civ. P. 12(b)(1) | Lack of subject-matter jurisdiction as a defense by motion. | Title and the brief's subject; the template does not check the grounds stated. | Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12 |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim as a defense by motion. | As above. | Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12 |
| Fed. R. Civ. P. 5(b)(2)(E) | Service through the court's electronic-filing system is complete on filing. | The certificate of service heading (`CERTIFICATE OF SERVICE`) and its text, from the sample. | Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_5 |
| S.D. Tex. LR10.2 (Format) | Double spaced, 8½" x 11", paginated. Names **no typeface and no point size**. | `double = 1.35em`, page size, margins, page numbers. | Text extracted 2026-10-14 from https://www.txs.uscourts.gov/sites/txs/files/LR%20September%202025%20Reprint.pdf (`pdftotext`) |
| S.D. Tex. LR7.1(D) (motion conference averment) | "Except for motions under Federal Rules of Civil Procedure 12(b), (c), (e), or (f) and 56," an opposed motion must aver that the movant conferred and counsel cannot agree. | This motion is a Rule 12(b) motion, so LR7.1(D) does not require the averment. The `certificate_of_conference` is printed only when the sample carries it (the judge's procedure, below). | Text extracted 2026-10-14 from the same reprint |
| Judge George C. Hanks, Jr. Court Procedures, 7.A (Houston Division) | "...limited to 25 pages, 13-point type-font, double-spaced, with 1" margins." Names no face. | `type-size = 13pt`. Applies to Judge Hanks's cases; the Dangelas motion is before Judge Eskridge. | Fetched 2026-10-14 from https://www.txs.uscourts.gov/sites/txs/files/GCH_Court_Procedures.pdf (`pdftotext`) |
| Galveston Division Rules of Practice, b., d., f. | No separate memorandum; a certificate of conference for non-dispositive motions; "13-point or larger font", double-spaced; 30-page limit for a motion or response; a table of authorities and a statement of the nature and stage above 10 pages of argument. | `type-size = 13pt`, `double = 1.35em`. The other items are **not** produced by the template or the sample (see Known gaps 3). Galveston rules bind only the Galveston Division's judges. | Fetched 2026-10-14 from https://www.txs.uscourts.gov/sites/txs/files/GalvestonDistrictCourtRulesofPractice.pdf |
| Judge's Court Procedures 17(a)–(b), 18(c) (Eskridge, Houston) | Conference procedure and word-limit certificate, as cited in the exemplar. | `word_count_certificate` and `certificate_of_conference` are the sample's text, not a template requirement. | Not fetched; cited from the exemplar. |

## Layout

- Page: US Letter, 1-inch margins; page numbers centered at the foot; 13 pt EB Garamond, double-spaced (see the complaint README for the font decision).
- Cover: court title (three lines, with the division); a § caption (`caption.style: section`: parties on the left, "§" in the middle column, `Civil Action No.` and the judge at the right); the title, bold and centered.
- Table of contents: `toc: true` puts the cover on its own page and generates the contents from the headings (the template's `outline`, depth 2), so the contents include the certificates, as the exemplar's do.
- Body: `#` headings centered bold capitals; `##` headings bold, left. Paragraphs are unnumbered (a brief); numbered lists (the statement of the issues) keep their numbers with a hanging indent.
- Signature: `signature` block (`by`, `signer_lines`) at the right, and `date` above it.
- Certificates: `word_count_certificate`, `certificate_of_conference`, `certificate_of_service` (each printed only when present), each under a level-1 heading, with `certificate_signature` below.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `division`, `judge`, `caption` (`style: section`, `parties`), `toc`, `brief_title`, `signature`, `date`, and the certificate fields.
- The body is blank-line-separated chunks: `#`/`##` headings, a numbered list (`1. `), or a paragraph.
- Case names are italic with `*...*`. Record citations (Dkt.) are kept as filed.

## What the overlay shows

Word-overlap per page (see `samples/OVERLAY-dangelas-motion-brief.txt`): ours 1 with filed 1 (86%), 2 with 2 (55%), 3 with 5 (54%), 4 with 7 (54%), 5 with 8 (65%), 6 with 9 (55%), 7 with 20 (45%), 8 with 20 (42%), 9 with 22 (39%), 10 with 22 (18%). Our pages 1 and 2 match the exemplar's cover and contents; pages 3 to 6 match the introduction through the summary; pages 7 to 10 pair with the exemplar's last pages (the argument's end and the certificates) because the sample's argument is shorter than the filing's. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this pass collected one. Seen and not saved: AAUP v. Albritton, 4:26-cv-06268, Dkt. 31 (31 pages, Rule 12(b)(1) and (b)(6), "Brief in Support"); Thomas v. Rockett, 4:26-cv-04970, Dkt. 7 (5 pages, a short motion). Tier 2 is **not** judged against two filers yet.
2. **Font size and face (open question for David).** 13 pt follows the Galveston Division rule (f.) and Judge Hanks's procedures (7.A); neither binds Judge Eskridge, whose procedures were not retrieved, and LR10.2 names no size. No retrieved rule names a face, so `docs/FONTS.md` ("No face named") keeps EB Garamond (decided 2026-10-14). The Dangelas exemplar is 12 pt Times New Roman, a filer's choice. Liberation Serif (metric-compatible with Times New Roman) is vendored if David wants Times.
3. **Table of authorities not produced.** The exemplar has a table of authorities, and the Galveston rule requires one above 10 pages of argument. The template does not build one (it would need citation extraction), and the sample omits it. If the Houston Division requires it, the template needs a citation index, which is an open design choice.
4. **Certificates are the sample's text.** The word-count certificate cites Court Procedure 18(c) and the conference certificate cites Court Procedures 17(a)–(b), both of the judge's own procedures. The template prints them only when the sample carries them. Their requirements are not verified for other judges.
5. **Sample is partial.** The sample transcribes the cover, the contents, the introduction to the summary, the opening of Argument A, the futility section, the conclusion and the three certificates. The middle of the argument (exemplar pages 9 to 17) is not transcribed.
6. **Overlay file names.** The overlay is `OVERLAY-dangelas-motion-brief.pdf`, not `dangelas-motion-brief-overlay.pdf` as the brief named it, so the repo tool runs unchanged.
7. **Widow on page 10.** The certificate of service runs three lines onto page 10 in the sample. This follows from the sample's length; a longer sample or a page-break rule would change it.
8. **Gate scripts not run.** As in the complaint folder: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; the brief forbids editing `tools/`. Render and overlay were run; this README's page review is the Gate 2 equivalent.
9. **Caption number.** `Civil Action No.` takes `case_number` from the sample; this is content, not a template defect.

## Pages reviewed (Gate 2 rows, rendered at 60 dpi and viewed)

- Page 1: § caption with the court title on three lines (the first render overlapped the division line; fixed by setting the court title as one paragraph), the title on two lines, the judge at the right. Pass.
- Page 2: TABLE OF CONTENTS from the headings, including the three certificates, with page numbers. Pass.
- Page 3: the introduction, nature and stage (two paragraphs), body text double-spaced. Pass.
- Page 4: statement of facts; the statement of the issues begins; the numbered issues hang. Pass.
- Page 5: issues 3 to 5; the standard of review (bold heading centered). Pass.
- Page 6: the standard of review continues; the summary heading; two paragraphs of the summary. Pass.
- Page 7: the summary's end; ARGUMENT; A (bold, left) and its text; sub-heading I. Pass.
- Page 8: futility paragraphs; conclusion and prayer. Pass.
- Page 9: signature block at the right (Dated line at the left); CERTIFICATE OF WORD COUNT, CERTIFICATE OF CONFERENCE and the start of CERTIFICATE OF SERVICE, each under its heading with the `/s/` line. Pass (after the certificate headings were changed to level-1 headings; the first render overlapped the text under each heading).
- Page 10: the service certificate's last lines and the `/s/` line; a widow (Known gap 7). Pass with the gap noted.

## Engines

**docx** (`docx/`; `samples/OUTPUT-dangelas-motion-brief.docx` and `samples/OUTPUT-dangelas-motion-brief.docx.pdf`, the LibreOffice conversion that was checked). Files: `reference.docx` (from `docx/build-reference.sh`: EB Garamond 13 pt set in the styles and the theme, exact 26 pt line pitch, Letter, 1-inch margins, centered PAGE field); `txsd.lua` (court title, section caption, title, the table of contents, lettered and numbered items, signature block and certificates, all read from the sample; `NUMBERED = false` here); `render.sh` (two passes: the page of each heading is read from the LibreOffice layout of pass 1 and written into the TOC's PAGEREF results in pass 2; bookmarks `_Toc1` to `_Toc13`).

- Matches the typst form: only EB Garamond is embedded; 13 pt; 1-inch margins on Letter; double spacing (26 pt pitch); section caption with the § column and one row per line at typst's pitch; the title; a TOC field whose page numbers equal the typst TOC's (3, 3, 4, 4, 5, 6, 7, 7, 7, 8, 9, 9, 9); signature block at 3.25 inch; certificates under level-1 headings; page number centered at the foot. 10 pages, as typst.
- Differs (not blocking): (1) LibreOffice places the extra leading of an exact line above the glyphs; typst places it below. Text sits about 11 to 13 pt lower on each page; line pitch and margins are the same. Word was not run. (2) The title keeps the typographic apostrophe (pandoc's smart punctuation) where typst prints a straight one. (3) Some lines break at a different word from typst, so a few page ends move by a line. (4) Word can paginate differently; the TOC numbers are from the LibreOffice layout and can be refreshed in Word with Update Field.
- BLOCKED: none. The table of authorities is not produced by this template (Known gap 3), as in typst. `tools/check.sh` cannot run on this folder (it needs `court.json` and `checks.yaml`).
