# nced: motion-brief

Doc type: **motion-brief**, the memorandum of law supporting a Rule 12(b) motion, in the United States District Court for the Eastern District of North Carolina (`nced`).
Folder: `courts/fourth-circuit/north-carolina/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the introduction, a portion of the facts, the standard of review, the first point of the argument, the conclusion, the signature block and the certificate of service of a 20-page memorandum) |
| typeface | no face named by the rule: Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6; Liberation Serif as fallback), on typst and docx (fb-595.68.18) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 9 pages each, vendored faces only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.9) |
| overlay | ok: `usage/OVERLAY-johnson-memo.pdf` (red = our render, blue = filed page, black = agreement) and `usage/OVERLAY-johnson-memo.txt` (the page map) |
| pages reviewed | 9 of 9 on typst, latex and docx after the move onto the FRCP base (2026-10-29: every page's text layout and the checks' geometry; see "Gate 2 review on the FRCP base") |
| tier 2 | not judged against a second filer: see "Known gaps", item 1 |

## Governing rules

Primary source: United States District Court, Eastern District of North Carolina, **Local Civil Rules, May 2023 edition**, https://www.nced.uscourts.gov/pdfs/Local%20Civil%20Rules%202023.pdf (fetched 2026-10-14; the newest edition found in search; no later edition was located). Rule text quoted from that PDF.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1(e) | A motion (other than one the clerk may grant) is filed with a supporting memorandum "in the manner prescribed by Local Civil Rule 7.2(a)". | Doc type. The memorandum's content is LR 7.2(a). |
| LR 7.2(a) | Form and content: a concise summary of the nature of the case, a concise statement of the facts, the argument (brevity expected) with citations, and copies of decisions. Comply with LR 10.1. | Author content; headings in the order the author writes them. The copies of decisions are not produced. |
| LR 7.2(f)(1) | Headings, footnotes, citations and quotations count toward the limit; the caption, signature block, certificates, tables and attachments do not. | Author content; the template does not count pages or words (see "Known gaps", item 3). |
| LR 7.2(f)(2)(A) | A memorandum supporting a motion (other than a discovery motion) "shall not exceed 30 pages in length". | Not checked by the template (known gap, item 3). |
| LR 7.2(f)(3)(A) and the certificate | A memorandum that uses the word limit (8,400 words) "must contain a certificate, signed by the attorney ... attesting that the memorandum complies with the applicable word limit", stating the number of words. | `word_count` in frontmatter: when present, the layout's `after_tail` prints the certificate on its own page after the signature. Absent, no certificate (the sample uses the page limit). |
| LR 10.1(a) | Double-spaced, single-sided, letter paper; all typed matter in at least 11-point type; one-inch margin on all sides. | the base's 12 pt and one-inch margins; `pitch.body` (27.6 pt, 2 x the 13.8 pt single line). Footnotes are 12 pt too. |
| LR 10.1(a) typeface | Names no typeface: "all typed matter appearing in at least 11 point font size". Text checked in the 2023 local rules PDF (`pdftotext`, 2026-10-14). | Times New Roman, the house standard where no face is named (`docs/FONTS.md` rule 6). |
| LR 10.1(b) | State the court and division. | `typst/layout.yaml` `front`; the division is frontmatter `division` (asserted). |
| LR 10.1(c) | Bear the case number, except for the initial filing. | `front`: "No. <case_number>" (a blank when not yet given). |
| LR 10.1(d) | Caption of the case. | `front`: the parties, a column of ")" as tall as they are (the form the rule's own example uses). |
| LR 10.1(e) | Title, and "if applicable" the federal statute or rule number under which the party is proceeding. | `brief_title` (author text). The exemplar's title does not carry the rule number; the rule is named in its first paragraph, and the sample follows the exemplar. A filer who reads LR 10.1(e) literally would add the rule number to `brief_title` (open point, known gap 11). |
| LR 10.1(f) | Name, firm, address, telephone, fax, e-mail and state bar number of each attorney. | `closing`: `firm`, `signers` (name, bar number, e-mail), `address`, and `counsel_for`. |
| LR 10.1(g) to (i) | Date; signed by an attorney; typed name below the signature. | "This the <date>."; "BY: /s/ <by>"; each signer's name in capitals. |
| LR 10.1(j) | Each page numbered sequentially. | the base's page number, centered in the footer. |
| Fed. R. Civ. P. 5(d)(1)(B) | A certificate of service must be filed with a paper served other than through the electronic-filing system. Verified against https://www.law.cornell.edu/rules/frcp/rule_5 on 2026-10-14. | `certificate` in frontmatter: `after_tail` prints "CERTIFICATE OF SERVICE", the text, the served parties, the date and the signature. |
| Fed. R. Civ. P. 12(b)(2), (6) | The defenses asserted by motion. Verified against https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14. | Author content (the lead-in names the rules). |

## Layout

- Letter paper; one-inch margins; Times New Roman 12 pt; double spacing (27.6 pt between baselines; paragraphs are separated by a blank double line).
- Cover: court and division centered at the top; "No." line; caption (party column with each designation an inch in, ")" column, title block to the right and centered on the caption), a rule under the parties and their ")" (the exemplar's); the body starts on the same page, as in the filed exemplar.
- Body: paragraphs with a first-line indent (0.5 in) and no numbers; level 1 headings centered bold capitals; the sub-headings are numbered by the template: level 2 = I., II., ...; level 3 = A., B., ..., each label in a 0.6 in box; the counters reset at each higher level. (The exemplar letters the facts' sub-headings A., 1. and numbers the argument's I., A.; the FRCP base numbers a level one way throughout, so the template uses the argument's scheme everywhere: tier 3.)
- Footnotes at 12 pt, from the body.
- Signature block after the conclusion: "This the <date>.", the firm, the "BY: /s/" line, each signer, the address and the party.
- Certificate of service on the page after the signature, when `certificate` is given; the word-count certificate (when `word_count` is given) starts on a new page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number`, `division` (required), `caption.parties` (`{names, designation}`; the names wrap in their column), `brief_title` (required), `date` (required), `signature` (`firm`, `by`, `signers`, `address`, `counsel_for`), `certificate` (optional: `text`, `served` list, `date`), `word_count` (optional: printed in the LR 7.2(f)(3) certificate, on a page of its own).
- Body: `# Heading` (level 1: a section), `## Heading` (level 2), `### Heading` (level 3). Write the heading text without its letter or numeral; the template adds it. Case names are italic (`*Grayson v. Anderson*`).
- Lists are ordinary markdown lists. Footnotes: `text[^key]` and `[^key]: text`.
- Not supported: tables, raw typst, forced line breaks.

## Overlay

`tools/overlay.sh` pairs each rendered page with the filed page that shares the most words (see `OVERLAY-johnson-memo.txt`; made on the earlier 8-page EB Garamond render, before fb-595.68). Pages 1, 2, 7 and 8 paired with the matching filed pages at 90% word overlap or more; page 3 paired with filed page 4 at 43%, because the sample's facts skip the filed text between the parties' exhibits. Read the overlay as a diagnostic for layout and spacing, not as a score.

## Known gaps and open choices

1. **Only one exemplar; tier 2 is not judged against two filers.** Searches, all on 2026-10-14: CourtListener RECAP search (`type=r`, `court=nced`, `filed_after=2026-06-01` and `2026-01-01`, query "motion to dismiss" memorandum); the nced local rules (2023 PDF); web searches for the local rules. The RECAP results also show an available EDNC memorandum supporting a motion to transfer and to dismiss, Roesel v. Blue Cross and Blue Shield of South Carolina, 7:26-cv-00253 (ECF 12, 38 pages). It was not downloaded: it combines a transfer motion with the dismissal motion and is twice the length of the sample. It is the candidate for a second filer. No second filer was downloaded, so tier 2 is not met.
2. **Font (ACCEPTED).** LR 10.1(a) requires at least 11 point and names no typeface, so the template is Times New Roman at 12 pt, the house standard (`docs/FONTS.md` rule 6, David 2026-10-17), as is the filed exemplar. It was EB Garamond before 2026-10-17 (the docx until fb-595.68.18).
3. **Length.** The 30 pages of LR 7.2(f)(2)(A) are `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine; counted with the caption, signature and certificates, the conservative reading). The 8,400 words of LR 7.2(f)(3)(A) are not counted: a memorandum that uses the word limit states its count (`word_count`) in the certificate.
4. **"Standard of Review" is a bold paragraph, not a heading**, because the exemplar sets it as an unnumbered run-in heading and the template's numbering would give it "I.". The sample uses a bold paragraph for it. Filers who want it as a numbered heading would use a level 2 heading and renumber.
5. **Title block has no box rule.** The exemplar sets its title at the right inside a box rule; the template sets the title in bold capitals at the right, without a box. Accepted: the rule's example form uses the ")" column and no box.
6. **The exemplar's typos are kept in the sample.** The sample transcribes the filing's text as it is printed, for example "North Carolin." in Part I.A and "the "the FTC Buyers Guide,"" in the allegations. The sample is for layout and structure comparison, not for citation.
7. **Exhibit citations are abbreviated.** The sample keeps the exemplar's exhibit and docket-entry citations, but drops the exhibit text it does not reproduce.
8. **File names.** The brief's literal names (`usage/<id>.md`, `<id>-overlay.pdf`) are replaced by the repository's tool names (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`), because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`, and `tools/` is out of scope for this unit.
9. **Checks.** `tools/check.sh` runs on this folder for typst, latex and docx (see Engines).
10. **Sample length.** The sample renders 9 pages (8 on the earlier EB Garamond render) from a 20-page exemplar. The brief asks for 8 to 14 pages when the exemplar is that long; the sample is at the low end because it transcribes the parts the template exercises (introduction, facts, a standard of review, one argument point, conclusion, signature, certificate) and not the whole argument.
11. **LR 10.1(e) rule number in the title.** The rule asks that the title state the rule number "if applicable"; the exemplar's title does not (its first paragraph names Rules 12(b)(2) and 12(b)(6)). The template prints `brief_title` as given, so the choice is the filer's. Left open for David: whether the template should require the rule number in the title.

## Review of the rendered pages (the earlier 8-page EB Garamond render, before fb-595.68)

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

## Gate 2 review on the FRCP base (2026-10-29, typst, latex and docx)

Every page of the three renders was reviewed as text layout (`pdftotext -layout`, page by page) with the checks' geometry (DEF-COVER-002 against the exemplar's page 1, XENG-001..003: every typst line identical in latex and docx); the pod that did the move could not open images, so a visual look at the pages is left to the PM.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court, division, "No." line, caption with the ")" column and the title beside it, the rule under the parties, lead-in, INTRODUCTION | OK; DEF-COVER-002 passes |
| 2 | Introduction, STATEMENT OF FACTS, I. | OK; the page ends short: heading II. moves with its paragraph (which calls footnote 1) |
| 3-5 | II. (footnote 1), III. and its A., B. (footnote 2), the claims | OK |
| 6-7 | ARGUMENT, the bold "Standard of Review" paragraph, I. and A., B. (footnote 3) | OK |
| 8 | CONCLUSION, "This the ...", the signature block three inches in | OK |
| 9 | CERTIFICATE OF SERVICE, the person served, the date, the signature block | OK |

OPEN (tier 3): the facts' sub-headings are numbered I., A. (the exemplar: A., 1.).

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.9): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays what E.D.N.C. sets itself, each with its rule: the court's name and division and the "No." line (LR 10.1(b), (c)), the caption with its ")" column and the title beside it (10.1(d), (e)), the 27.6 pt double pitch (10.1(a)), the dated signature block (10.1(f) to (i)), the word-count certificate (7.2(f)(3)) and the certificate of service (Fed. R. Civ. P. 5(d)(1)(B)). `typst/nced-motion-brief.typ` names the face and asserts the division, the date and the signer. `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them); the per-folder typst code and the docx filter are removed. The page limit is `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine).

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |
