# nced: motion-brief

Doc type: **motion-brief**, the memorandum of law supporting a Rule 12(b) motion, in the United States District Court for the Eastern District of North Carolina (`nced`).
Folder: `courts/fourth-circuit/north-carolina/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the introduction, a portion of the facts, the standard of review, the first point of the argument, the conclusion, the signature block and the certificate of service of a 20-page memorandum) |
| typeface | no face named by the rule: EB Garamond (vendored default; `docs/FONTS.md`, "No face named"); no substitute applied |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, EB Garamond only (vendored), no warnings |
| overlay | ok: `usage/OVERLAY-johnson-memo.pdf` (red = our render, blue = filed page, black = agreement) and `usage/OVERLAY-johnson-memo.txt` (the page map) |
| pages reviewed | 8 of 8, every page rendered at 60 dpi and viewed on the final render (table below) |
| tier 2 | not judged against a second filer: see "Known gaps", item 1 |

## Governing rules

Primary source: United States District Court, Eastern District of North Carolina, **Local Civil Rules, May 2023 edition**, https://www.nced.uscourts.gov/pdfs/Local%20Civil%20Rules%202023.pdf (fetched 2026-10-14; the newest edition found in search; no later edition was located). Rule text quoted from that PDF.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1(e) | A motion (other than one the clerk may grant) is filed with a supporting memorandum "in the manner prescribed by Local Civil Rule 7.2(a)". | Doc type. The memorandum's content is LR 7.2(a). |
| LR 7.2(a) | Form and content: a concise summary of the nature of the case, a concise statement of the facts, the argument (brevity expected) with citations, and copies of decisions. Comply with LR 10.1. | Author content; headings in the order the author writes them. The copies of decisions are not produced. |
| LR 7.2(f)(1) | Headings, footnotes, citations and quotations count toward the limit; the caption, signature block, certificates, tables and attachments do not. | Author content; the template does not count pages or words (see "Known gaps", item 3). |
| LR 7.2(f)(2)(A) | A memorandum supporting a motion (other than a discovery motion) "shall not exceed 30 pages in length". | Not checked by the template (known gap, item 3). |
| LR 7.2(f)(3)(A) and the certificate | A memorandum that uses the word limit (8,400 words) "must contain a certificate, signed by the attorney ... attesting that the memorandum complies with the applicable word limit", stating the number of words. | `word_count` in frontmatter: when present, `word-certificate()` prints the certificate on its own page after the signature. Absent, no certificate (the sample uses the page limit). |
| LR 10.1(a) | Double-spaced, single-sided, letter paper; all typed matter in at least 11-point type; one-inch margin on all sides. | `type-size = 12pt`, `margin = 1in`, `body-leading` (27.6 pt baseline pitch at 12 pt: measured on the render). Footnotes are 12 pt too. |
| LR 10.1(a) typeface | Names no typeface: "all typed matter appearing in at least 11 point font size". Text checked in the 2023 local rules PDF (`pdftotext`, 2026-10-14). | EB Garamond, the vendored default (`docs/FONTS.md`, "No face named"): no court-named substitute is needed. |
| LR 10.1(b) | State the court and division. | `court-title()`; the division is frontmatter `division`. |
| LR 10.1(c) | Bear the case number, except for the initial filing. | `case-number-line()`: "No. <case_number>". |
| LR 10.1(d) | Caption of the case. | `caption()`: one row per frontmatter line, each with a ")" in the next column (the form the rule's own example uses). |
| LR 10.1(e) | Title, and "if applicable" the federal statute or rule number under which the party is proceeding. | `brief_title` (author text). The exemplar's title does not carry the rule number; the rule is named in its first paragraph, and the sample follows the exemplar. A filer who reads LR 10.1(e) literally would add the rule number to `brief_title` (open point, known gap 11). |
| LR 10.1(f) | Name, firm, address, telephone, fax, e-mail and state bar number of each attorney. | `signature-lines()`: `firm`, `signers` (name, bar number, e-mail), `address`, and `counsel_for`. |
| LR 10.1(g) to (i) | Date; signed by an attorney; typed name below the signature. | "This the <date>."; "BY: /s/ <by>"; each signer's name in capitals. |
| LR 10.1(j) | Each page numbered sequentially. | `page-number()`, centered in the footer. |
| Fed. R. Civ. P. 5(d)(1)(B) | A certificate of service must be filed with a paper served other than through the electronic-filing system. Verified against https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14. | `certificate` in frontmatter: `service-certificate()` prints "CERTIFICATE OF SERVICE", the text, the served parties, the date and the signature. |
| Fed. R. Civ. P. 12(b)(2), (6) | The defenses asserted by motion. Verified against https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14. | Author content (the lead-in names the rules). |

## Layout

- Letter paper; one-inch margins; EB Garamond 12 pt; double spacing (27.6 pt between baselines; paragraphs are separated by a blank double line).
- Cover: court and division centered at the top; "No." line; caption (party column, ")" column, title block to the right and centered on the caption); the body starts on the same page, as in the filed exemplar.
- Body: paragraphs with a first-line indent (0.5 in) and no numbers; level 1 headings centered bold capitals; the sub-headings are numbered by the template. Outside ARGUMENT: level 2 = A., B., ...; level 3 = 1., 2., ... Under ARGUMENT: level 2 = I., II., ...; level 3 = A., B., ... The counters reset at each higher level.
- Footnotes at 12 pt, from the body.
- Signature block after the conclusion: "This the <date>.", the firm, the "BY: /s/" line, each signer, the address and the party.
- Certificate of service on the page after the signature, when `certificate` is given; the word-count certificate (when `word_count` is given) starts on a new page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number`, `division` (required), `caption.lines` (as in the complaint: strings or `{t, i}`; each line must fit on one line: the template asserts it), `brief_title` (required), `date` (required), `signature` (`firm`, `by`, `signers`, `address`, `counsel_for`), `certificate` (optional: `text`, `served` list, `date`), `word_count` (optional: integer, printed in the LR 7.2(f)(3) certificate; the template does not count the words).
- Body: `# Heading` (level 1: a section), `## Heading` (level 2), `### Heading` (level 3). Write the heading text without its letter or numeral; the template adds it. Case names are italic (`*Grayson v. Anderson*`).
- Lists are ordinary markdown lists. Footnotes: `text[^key]` and `[^key]: text`.
- Not supported: tables, raw typst, forced line breaks.

## Overlay

`tools/overlay.sh` pairs each rendered page with the filed page that shares the most words (see `OVERLAY-johnson-memo.txt`). Pages 1, 2, 7 and 8 pair with the matching filed pages at 90% word overlap or more; page 3 pairs with filed page 4 at 43%, because the sample's facts skip the filed text between the parties' exhibits. Read the overlay as a diagnostic for layout and spacing, not as a score.

## Known gaps and open choices

1. **Only one exemplar; tier 2 is not judged against two filers.** Searches, all on 2026-10-14: CourtListener RECAP search (`type=r`, `court=nced`, `filed_after=2026-06-01` and `2026-01-01`, query "motion to dismiss" memorandum); the nced local rules (2023 PDF); web searches for the local rules. The RECAP results also show an available EDNC memorandum supporting a motion to transfer and to dismiss, Roesel v. Blue Cross and Blue Shield of South Carolina, 7:26-cv-00253 (ECF 12, 38 pages). It was not downloaded: it combines a transfer motion with the dismissal motion and is twice the length of the sample. It is the candidate for a second filer. No second filer was downloaded, so tier 2 is not met.
2. **Font (ACCEPTED).** LR 10.1(a) requires at least 11 point and names no typeface, so the template keeps EB Garamond at 12 pt, as `docs/FONTS.md` directs for a court that names no face. The filed exemplar is Times New Roman: that is one filer's choice (tier 3), not a court requirement, so Liberation Serif is not substituted. EB Garamond has a smaller x-height at 12 pt, so the text looks smaller than the exemplar. Accepted under tier 2: the rule sets the size, not the face.
3. **Length is not checked.** LR 7.2(f)(2)(A) limits the memorandum to 30 pages and LR 7.2(f)(3)(A) to 8,400 words. The template does not count pages or words: the page count of a render is the filer's check, and the word count is the `word_count` frontmatter value (which the template prints in the certificate, unverified). A sample that exceeded the limit would still build.
4. **"Standard of Review" is a bold paragraph, not a heading**, because the exemplar sets it as an unnumbered run-in heading and the template's numbering would give it "I.". The sample uses a bold paragraph for it. Filers who want it as a numbered heading would use a level 2 heading and renumber.
5. **Title block has no box rule.** The exemplar sets its title at the right inside a box rule; the template sets the title in bold capitals at the right, without a box. Accepted: the rule's example form uses the ")" column and no box.
6. **The exemplar's typos are kept in the sample.** The sample transcribes the filing's text as it is printed, for example "North Carolin." in Part I.A and "the "the FTC Buyers Guide,"" in the allegations. The sample is for layout and structure comparison, not for citation.
7. **Exhibit citations are abbreviated.** The sample keeps the exemplar's exhibit and docket-entry citations, but drops the exhibit text it does not reproduce.
8. **File names.** The brief's literal names (`usage/<id>.md`, `<id>-overlay.pdf`) are replaced by the repository's tool names (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`), because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`, and `tools/` is out of scope for this unit.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court root (a `court.json` and `rules.md`); this doc-type folder is not that shape, and the brief forbids touching `tools/`. The render (no warnings, vendored font only) and the overlay were run; the review below is the Gate 2 equivalent.
10. **Sample length.** The sample renders 8 pages from a 20-page exemplar. The brief asks for 8 to 14 pages when the exemplar is that long; the sample is at the low end because it transcribes the parts the template exercises (introduction, facts, a standard of review, one argument point, conclusion, signature, certificate) and not the whole argument.
11. **LR 10.1(e) rule number in the title.** The rule asks that the title state the rule number "if applicable"; the exemplar's title does not (its first paragraph names Rules 12(b)(2) and 12(b)(6)). The template prints `brief_title` as given, so the choice is the filer's. Left open for David: whether the template should require the rule number in the title.

## Review of the rendered pages (final render)

| Page | What was checked | Result |
|---|---|---|
| 1 | Court title and division; "No." line; caption rows and ")" column; title block centered on the caption; the first paragraph (lead-in) and the INTRODUCTION heading; paragraphs at 0.5 in first-line indent. | Pass. |
| 2 | The introduction's last paragraphs; STATEMENT OF FACTS heading; sub-heading A (letter by the template); sub-heading B; footnote 1 at 12 pt. | Pass. |
| 3 | Paragraphs of the facts (exhibit citations); the GAP paragraph; the page ends with white space before heading C, which is kept with its paragraph (sticky). | Pass; the white space is accepted. |
| 4 | Sub-heading C (letter by the template); its sub-headings 1 and 2 (numbered by the template, bold, indented); footnote 2. | Pass. |
| 5 | The claims paragraphs; ARGUMENT heading (level 1, centered); "Standard of Review" as a bold run-in paragraph; the standard-of-review paragraphs. | Pass. |
| 6 | Heading I (Roman, under ARGUMENT, so the scheme switched correctly); sub-heading A and B (letters under ARGUMENT); footnote 3. | Pass. |
| 7 | CONCLUSION heading; the conclusion paragraph; "This the 21st day of August, 2026."; the signature block (firm, BY line, two signers, address, party). | Pass. |
| 8 | CERTIFICATE OF SERVICE heading; the text; the pro se party's address; the date; the signature block repeated. No spill. | Pass. |

## Engines

The same markdown renders through the typst engine (`typst/`, the reference) and the docx engine (`docx/`). The docx output is `usage/OUTPUT-motion-brief.docx` with its LibreOffice PDF `usage/OUTPUT-motion-brief.docx.pdf`. Build: `sh docx/make-reference.sh` (the reference), then `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`.

- *Matches typst (checked on the PDF):* EB Garamond 12 pt, the only face in the PDF (no substitution); letter paper with 1-inch margins (all text inside 72 to 540 pt); body double-spaced at the typst baseline pitch of 27.6 pt, with a 0.5 in first-line indent and no space between paragraphs; the cover and caption as in the complaint, with the "No." line; heading labels as the template prints them: under ARGUMENT, I., II. and A., B.; elsewhere A., B. and 1., 2., each followed by a tab to a hanging indent; level 1 centered bold capitals, level 2 bold with its label at 0, level 3 bold with its label at 0.5 in, all at typst's sizes; footnotes at 12 pt, single-spaced; the dated signature block at 3 in; the certificate of service after the signature, kept on one page with it (Fed. R. Civ. P. 5(d)(1)(B)); the page number centered in the footer, sequential from the cover. Page count is the same as typst (8 pages), and the certificate of service falls on page 8 in both.
- *Differs:* LibreOffice and typst break some lines at different words, so a few pages hold one line more or less. The footnote 3 paragraph ("Consulting Engineers") splits across pages 6 and 7 in the docx, where typst keeps it whole on page 6, so the CONCLUSION heading is on page 7 in both, but the footnote sits on page 7 in the docx and on page 6 in typst. Heading sizes are set as sizes (about 17 pt and 14.5 pt), because typst's 1.4 em and 1.2 em come from its defaults. The labels are typed text, not Word list numbering, so a Word edit does not renumber them.
- *Not built in this sample:* the word-count certificate (LR 7.2(f)(3)) is built and prints when frontmatter has `word_count`, but this sample has none, so it was not rendered here.
- *Not checked:* Word. The `.docx` is a valid zip with well-formed XML parts (checked with `unzip -tq` and `xmllint`), and LibreOffice converts it without error. It has not been opened in Word, so the no-repair check is not done here.
- *BLOCKED:* none. Every requirement of the template that a docx can express is built; nothing is missing from the render.
- *Pages reviewed:* the docx PDF, pages 1 to 8 of 8, each viewed at 60 dpi beside the typst page of the same number.
