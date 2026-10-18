# vid: motion brief

Doc type: **motion brief**, a memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b)(6), in the District Court of the Virgin Islands (`vid`, Division of St. Croix, and the other divisions by frontmatter). Folder: `courts/third-circuit/virgin-islands/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole memorandum: caption, introduction, legal standard, argument, conclusion, signature, certificate of service) |
| typeface | none required by the rules (VI-FONT-001): EB Garamond kept, no substitute needed |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-wooten-motion-brief.pdf` and `OVERLAY-wooten-motion-brief.txt` |
| pages reviewed | 9 of 9 (each page rendered at 70 dpi and viewed; see the review record below) |

## Governing rules

Court: District Court of the Virgin Islands. The local rules (LRCi) have two sources, and they do not agree on every point; the FRCP text is from Cornell.

| ID | Rule | Requirement | Source (fetched 2026-10-14) | Where it lives |
|---|---|---|---|---|
| VI-FORM-001 | LRCi 5.1(a) | All papers double-spaced except quoted material; each page numbered consecutively; 8½ × 11-inch white paper. | VID LRCi PDF, https://www.vid.uscourts.gov/sites/vid/files/local_rules/VID_LRCi_042911.pdf (a July 2011 compilation; the court's current version was not confirmed) | `vid-motion-brief.typ`: `margin`, `body-leading`, page numbering |
| VI-FORM-002 | LRCi 5.1 (type and margins) | At least 12-point type; at least one-inch margins; footnotes may be 10-point and single-spaced. | Not in the 2011 PDF. Search excerpt of the current LRCi text at courtrules.net (https://www.courtrules.net/courts/federal/district-virgin-islands/local-rules/10791); the page returned HTTP 403, so this is an excerpt, not a read page | `type-size = 12pt`, `margin = 1in`. No footnotes in this exemplar or the template. |
| VI-FONT-001 | LRCi 5.1(a) and 5.1 (current) | No typeface named. The current excerpt adds "at least 12-point type", which the template meets. | VID LRCi PDF (as above) names no face. Current text: courtrules.net excerpt (as above), which names no face. Checked 2026-10-15. | `font-family = "EB Garamond"` kept. FONTS.md's "No face named" row applies, so no substitute is used. |
| VI-CONT-001 | LRCi 7.1(c) | A motion is accompanied by a brief stating the reasons and the citation of authorities. | VID LRCi PDF (as above) | The memorandum itself. The notice of motion is a separate filing (see Known gaps 3). |
| VI-CONT-002 | LRCi 7.1(d) | No document may exceed 20 pages without leave (2011 text). | VID LRCi PDF (as above) | Not checked by the template. The sample is 9 pages. |
| VI-CONT-003 | LRCi 7.1 (current) | Over 20 substantive pages needs a word-count certificate of compliance. | courtrules.net excerpt (as above) | Not produced. Not needed at this length. |
| FRCP-10(a) | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. | https://www.law.cornell.edu/rules/frcp/rule_10 | `court-header`, `caption`, `title` |
| FRCP-12(b)(6) | Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be raised by motion. | https://www.law.cornell.edu/rules/frcp/rule_12 | Author content (the memorandum's argument). The template does not check the citations. |

Not produced by this template (separate filings): the notice of motion, the proposed order, declarations, and the exhibits (the Wooten filing attaches its exhibits as separate documents: ECF 14 cites Exhibits 1–5).

## Layout

- Court name and division, centered, on the first page (`IN THE DISTRICT COURT OF THE VIRGIN ISLANDS` is the template's constant; the division comes from the frontmatter).
- Caption: parties on the left, closed by a rule on the right and bottom; the number label (`number_label`, here "Case No.") and case number on the right. The template inserts "v." between parties.
- Title centered and bold.
- Body: paragraphs are not numbered (a memorandum), with a first-line indent. `# Heading` is a centered bold section; `## ` is a bold left heading (the argument's roman-numeral points); `### ` is bold italic (the lettered sub-points). A list sticks to what follows it.
- Signature block after the conclusion, as filed: date at left; firm, `/s/` signer and counsel lines at right, single-spaced; unbreakable.
- Certificate of service (frontmatter `certificate`): heading, text, and a right-aligned `/s/` line, after the signature, as filed.

## Markdown contract (for samples)

- YAML frontmatter, then the body, the same shape as the CAND motion contract (`courts/ninth-circuit/california/federal/northern-district/motion-brief/`). The ca9 appellate contract does not apply.
- Frontmatter: `title`, `division`, `number_label`, `case_number`, `caption` (list of `{names, designation}`), `signature` (`date`, `preamble`, `signer`, `lines`), `certificate` (`title`, `text`, `signer`).
- Body: paragraphs, `# `/`## `/`### ` headings, `> ` quotations, lists. Case names in `*italics*`. Escape a literal `*` (as in `at \*2`) so it is not read as italics.
- Not supported: footnotes, tables, raw typst, a table of contents or table of authorities (the exemplar has neither, and the 2011 LRCi text asks for neither; the current text was not confirmed).

## Overlay

`usage/OVERLAY-wooten-motion-brief.pdf` and `.txt` are the red/blue test: red is our render, blue is the filed exemplar, black is both agreeing. The pairing is by word overlap, not by index, and the page map is in the `.txt`. Pairs: ours p.1 ↔ filed p.1 (73.0%), p.2 ↔ p.2 (64.7%), p.3 ↔ p.4 (55.0%), p.4 ↔ p.5 (78.1%), p.5 ↔ p.6 (87.6%), p.6 ↔ p.7 (85.3%), p.7 ↔ p.8 (67.1%), p.8 ↔ p.10 (53.7%), p.9 ↔ p.11 (88.4%). The filed copy has a 10-page memorandum and a certificate on page 11. Our page 8 (the conclusion and signature) pairs with filed page 10, the page that carries the conclusion. The overlay is a diagnostic, not a score: the exemplar uses Times, and the render uses EB Garamond, so the text lines will not coincide.

## Known gaps and open choices

1. **One exemplar.** LRCi tier 2 asks for two or three filers. Port Hamilton Refining & Transportation v. Limetree Bay Terminals, 1:24-cv-00004, ECF 17 (a 10-page memorandum in support of a 12(b)(6) motion to dismiss a counterclaim, filed May 30, 2024; RECAP `gov.uscourts.vid.39844.17.0.pdf`) and Appleton v. Saintnals, LLC, 1:25-cv-00032, ECF 14 (7 pages) were also found with storage. Neither was saved, because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** No rule names a typeface (VI-FONT-001 in the complaint README), so the template keeps EB Garamond. The exemplar is in Times New Roman, one filer's choice; the 12-point minimum is met. Tier 2's typeface convention rests on this one exemplar (gap 1).
3. **Notice of motion.** The Wooten filing has a separate motion (ECF 13). Only the memorandum is templated. A notice of motion and a proposed order are separate filings and are not produced.
4. **Caption form.** The complaint template prints "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS"; the Wooten memorandum prints "DISTRICT COURT OF THE VIRGIN ISLANDS" without "IN THE". Both are seen in D.V.I. filings; the complaint's form is used for both templates and recorded as ACCEPTED for tier 2.
5. **Typos kept as filed.** The exemplar's text has errors that the transcription keeps, so the sample matches the filing: "Ashcroft v. Igbal", "plausible of on its face", "Fowler v. UpMC Shadyside, 578 F. 3d 203 (3rd Cir. 2009)" with no pin cite, "Buck, 452 F. 3d 256, 260 (3d Cir. 2006)" cited without the case name, and the repeated "Mutual Aid Agreement is attached" construction. These are the author's text, not template defects.
6. **Italics.** The exemplar's text layer has no italic markup, so case names are italic in the sample as the convention requires. Not checked against the exemplar's typeface.
7. **Page limit.** LRCi 7.1(d) (20 pages, 2011 text) is not checked; the sample is 9 pages.
8. **Exhibits.** The exhibits (Exhibit 1 to Exhibit 5, and Composite Exhibit 4) are referenced by the memorandum and are not templated.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent.
10. **Overlay names.** As for the complaint: the tool's `OUTPUT-`/`OVERLAY-` names are renamed to the brief's names after the run.

## Review record (Gate 2 equivalent: every page rendered at 70 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division, caption, title, the opening paragraph, INTRODUCTION | OK. |
| 2 | LEGAL STANDARD, ARGUMENT, heading I. (four bold lines), heading A. | OK. Headings keep with the text after them. |
| 3 | Body of Argument I.A. (LBR Services Agreement, Sale Order) | OK. |
| 4 | Heading B. (two lines), Argument I.B. | OK. |
| 5 | Heading C. (two lines), Argument I.C., heading II. and its A. | OK. The bold two-line headings do not collide with the text. |
| 6 | Argument II.A., heading II.B. | OK. |
| 7 | Argument II.B., heading II.C. (three lines), the start of the duplicative-claims argument | OK. |
| 8 | End of II.C, CONCLUSION, the signature block (Dated, firm, `/s/`, counsel lines) | OK after the change that moved the certificate below the signature. The signature is with the conclusion, not alone. |
| 9 | CERTIFICATE OF SERVICE and its `/s/` line | OK. |

Defects found during the review and fixed: (a) the caption repeated "v." as a party (fixed: the template inserts it); (b) a `~` marker was printed as text (fixed: removed); (c) the signature stood alone on the last page, after the certificate (fixed: the certificate moved to frontmatter and renders after the signature, as filed).

[Formbook index](../../../../../../README.md)

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/vid.lua`; output `usage/OUTPUT-motion-brief.docx`): pandoc on a per-court reference.docx, with the caption, title, signature block and certificate of service built by the filter from the frontmatter. It matches the typst template in: EB Garamond 12 pt; exact 24 pt (double) line spacing; 1 in margins on letter paper; 0.5 in first-line indent of body paragraphs; centered PAGE number in the footer; the court name and division, centered; the caption (parties left, closed by a rule on the right and bottom; the frontmatter `number_label` and `case_number` at right); the centered bold title; Heading 1 (centered bold), Heading 2 (bold), Heading 3 (bold italic); block quotations single spaced, indented 0.5 in each side; the list kept with what follows; the signature block as a two-column table that does not split; the certificate of service (centered bold title, text, right-aligned `/s/` line) after the signature.
- docx differences (pandoc and Word limits): body paragraphs are not numbered in this doc type, as in the typst template. Keep-with-next approximates the typst sticky list and the sticky certificate title; page breaks are not guaranteed to match the typst render (9 pages). Caption rules and table row heights differ between Word and LibreOffice. No TOC or TOA in this doc type.
- Not verified: pagination and appearance. The docx was checked only as a zip whose entries all read and whose XML parts are well formed (`ziptool`, `xmllint`). It has not been opened in Word or LibreOffice, and no `.docx.pdf` was rendered (LibreOffice is not installed on the build box).
- **BLOCKED** (all checks measured on `usage/OUTPUT-wooten-motion-brief.docx.pdf`): no checks file is readable (this folder and the court folder have no `checks.yaml` or `rules.md`), so the gate check IDs cannot be listed. The rule IDs the template traces to are VI-FORM-001, VI-FORM-002, VI-FONT-001, VI-CONT-001, VI-CONT-002, VI-CONT-003, FRCP-10(a) and FRCP-12(b)(6). Reason for each: LibreOffice cannot run in the build box, so the .docx.pdf cannot be produced or checked.
