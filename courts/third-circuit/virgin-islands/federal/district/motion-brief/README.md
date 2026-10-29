# vid: motion brief

Doc type: **motion brief**, a memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b)(6), in the District Court of the Virgin Islands (`vid`, Division of St. Croix, and the other divisions by frontmatter). Folder: `courts/third-circuit/virgin-islands/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole memorandum: caption, introduction, legal standard, argument, conclusion, signature, certificate of service) |
| typeface | none required by the rules (VI-FONT-001): **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard, in every engine (`fb lint fonts` does not report the folder) |
| render | ok (2026-10-29, fb-595.17.22): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `usage/OUTPUT-motion-brief.docx` with its LibreOffice PDF, 9 pages each; `fb render`, vendored fonts only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 9 of 9, all three engines, as text layout and word boxes (2026-10-29, the renders of fb-595.17.22) |

## Governing rules

Court: District Court of the Virgin Islands. The local rules (LRCi) have two sources, and they do not agree on every point; the FRCP text is from Cornell.

| ID | Rule | Requirement | Source (fetched 2026-10-14) | Where it lives |
|---|---|---|---|---|
| VI-FORM-001 | LRCi 5.1(a) | All papers double-spaced except quoted material; each page numbered consecutively; 8½ × 11-inch white paper. | VID LRCi PDF, https://www.vid.uscourts.gov/sites/vid/files/local_rules/VID_LRCi_042911.pdf (a July 2011 compilation; the court's current version was not confirmed) | `typst/layout.yaml` (the base's `margin`, `pitch.body`, `page_number`) |
| VI-FORM-002 | LRCi 5.1 (type and margins) | At least 12-point type; at least one-inch margins; footnotes may be 10-point and single-spaced. | Not in the 2011 PDF. Search excerpt of the current LRCi text at courtrules.net (https://www.courtrules.net/courts/federal/district-virgin-islands/local-rules/10791); the page returned HTTP 403, so this is an excerpt, not a read page | the base's `size: 12`, `margin` (72 pt each side). No footnotes in this exemplar or the template. |
| VI-FONT-001 | LRCi 5.1(a) and 5.1 (current) | No typeface named. The current excerpt adds "at least 12-point type", which the template meets. | VID LRCi PDF (as above) names no face. Current text: courtrules.net excerpt (as above), which names no face. Checked 2026-10-15. | `typst/vid-motion-brief.typ` `font-family = ("Times New Roman", "Liberation Serif")`: the exemplar's face, the house standard. |
| VI-CONT-001 | LRCi 7.1(c) | A motion is accompanied by a brief stating the reasons and the citation of authorities. | VID LRCi PDF (as above) | The memorandum itself. The notice of motion is a separate filing (see Known gaps 3). |
| VI-CONT-002 | LRCi 7.1(d) | No document may exceed 20 pages without leave (2011 text). | VID LRCi PDF (as above) | Not checked by the template. The sample is 9 pages. |
| VI-CONT-003 | LRCi 7.1 (current) | Over 20 substantive pages needs a word-count certificate of compliance. | courtrules.net excerpt (as above) | Not produced. Not needed at this length. |
| FRCP-10(a) | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. | https://www.law.cornell.edu/rules/frcp/rule_10 | `typst/layout.yaml` `front` |
| FRCP-12(b)(6) | Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be raised by motion. | https://www.law.cornell.edu/rules/frcp/rule_12 | Author content (the memorandum's argument). The template does not check the citations. |

Not produced by this template (separate filings): the notice of motion, the proposed order, declarations, and the exhibits (the Wooten filing attaches its exhibits as separate documents: ECF 14 cites Exhibits 1–5).

## Layout

Since fb-595.17.22 the folder is on the generic federal district brief: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay (each choice cited there), `typst/vid-motion-brief.typ` names the face, and `lib/typst/xdoc.typ` sets the layout; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`. The layout is the one filed before the move (the typst words of all 9 pages within a point of the earlier render).

- Letter paper, one-inch margins, Times New Roman 12 pt (LRCi 5.1(a); the base's floor). Footer: the page number centred (the base's).
- Every line a box of its pitch, 24 pt for the body (LRCi 5.1(a) double spacing), 13.8 pt for single lines (court title, caption, quotations, signature, footer); the spaces between blocks explicit.
- Court name (bold) and division, centred single lines, on the first page (`IN THE DISTRICT COURT OF THE VIRGIN ISLANDS` is the layout constant `{xd.court}`; the division comes from the frontmatter).
- Caption, a blank single line below: parties on the left (a 3.5 in column), closed by a 0.75 pt rule on the right and bottom (two nested boxes, one ruled at its right and one at its foot, so each rule is a single line in every engine, as filed: DEF-COVER-002); each name single-spaced, its designation 6 pt below and 1.2 in in, "v." (inserted by the template) centred 7 pt from both parties; the number label (`number_label`, here "Case No.") and case number 0.3 in into the right column.
- Title centred and bold on the body pitch (double-spaced when it wraps), a blank double line below the caption.
- Body: paragraphs are not numbered (a memorandum), with a half-inch first-line indent. Headings at the type size on the body pitch with no space of their own, kept with the next block: `# ` centred bold; `## ` bold at the margin (the argument's roman-numeral points); `### ` bold italic (the lettered sub-points). `> ` quotations single-spaced, 0.5 in in from both margins, 12 pt above and below; a markdown list is the model's numbered list (the number in a half-inch box, its text hanging after it; the sample has none).
- Signature block, 24 pt below the conclusion and kept with its last paragraph, as filed: "Dated:" and the date at the left of the first line, then the firm lines, `/s/` signer (7 pt lower) and counsel lines in a column from 3.4 in, single-spaced.
- Certificate of service (frontmatter `certificate`) a blank double line after the signature, as filed: the heading centred bold, the text, and a right-aligned `/s/` line 24 pt below; one unbreakable block.

## Markdown contract (for samples)

- YAML frontmatter, then the body, the same shape as the CAND motion contract (`courts/ninth-circuit/california/federal/northern-district/motion-brief/`). The ca9 appellate contract does not apply.
- Frontmatter: `title`, `division`, `number_label`, `case_number`, `caption` (list of `{names, designation}`), `signature` (`date`, `preamble`, `signer`, `lines`), `certificate` (`title`, `text`, `signer`).
- Body: paragraphs, `# `/`## `/`### ` headings, `> ` quotations, lists. Case names in `*italics*`. Escape a literal `*` (as in `at \*2`) so it is not read as italics.
- Not supported: footnotes, tables, raw typst, a table of contents or table of authorities (the exemplar has neither, and the 2011 LRCi text asks for neither; the current text was not confirmed).

## Overlay

`just overlay courts/third-circuit/virgin-islands/federal/district/motion-brief` writes the red/blue overlay (red is our render, blue the filed exemplar, black both) to the gitignored `.overlay/`. Pages pair by word overlap; the filed copy has a 10-page memorandum and a certificate on page 11, so our later pages pair with later filed pages. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** LRCi tier 2 asks for two or three filers. Port Hamilton Refining & Transportation v. Limetree Bay Terminals, 1:24-cv-00004, ECF 17 (a 10-page memorandum in support of a 12(b)(6) motion to dismiss a counterclaim, filed May 30, 2024; RECAP `gov.uscourts.vid.39844.17.0.pdf`) and Appleton v. Saintnals, LLC, 1:25-cv-00032, ECF 14 (7 pages) were also found with storage. Neither was saved, because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** No rule names a typeface (VI-FONT-001). Times New Roman 12 pt, the face of the filed exemplar and the house standard, in every engine; the 12-point minimum is met.
3. **Notice of motion.** The Wooten filing has a separate motion (ECF 13). Only the memorandum is templated. A notice of motion and a proposed order are separate filings and are not produced.
4. **Caption form.** The complaint template prints "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS"; the Wooten memorandum prints "DISTRICT COURT OF THE VIRGIN ISLANDS" without "IN THE". Both are seen in D.V.I. filings; the complaint's form is used for both templates and recorded as ACCEPTED for tier 2.
5. **Typos kept as filed.** The exemplar's text has errors that the transcription keeps, so the sample matches the filing: "Ashcroft v. Igbal", "plausible of on its face", "Fowler v. UpMC Shadyside, 578 F. 3d 203 (3rd Cir. 2009)" with no pin cite, "Buck, 452 F. 3d 256, 260 (3d Cir. 2006)" cited without the case name, and the repeated "Mutual Aid Agreement is attached" construction. These are the author's text, not template defects.
6. **Italics.** The exemplar's text layer has no italic markup, so case names are italic in the sample as the convention requires. Not checked against the exemplar's typeface.
7. **Page limit.** LRCi 7.1(d) (20 pages, 2011 text) is not checked; the sample is 9 pages.
8. **Exhibits.** The exhibits (Exhibit 1 to Exhibit 5, and Composite Exhibit 4) are referenced by the memorandum and are not templated.
9. **Selftest.** `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have; `tools/check.sh` runs on it (since fb-595.17.22: typst 11, latex 14, docx 15 passed, 0 failed).
10. **Page 8 is short.** The CONCLUSION heading and its paragraph are kept with the signature block, which does not fit below the duplicative-claims argument, so they open page 9 with the certificate of service. The alternative, a signature alone on a page, was rejected.

## Review record (Gate 2: every page of the three renders, typst, latex and docx, as text layout and word boxes, 2026-10-29; the earlier review, 2026-10-22, side by side at 50 dpi)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division, caption, title (two lines), the opening paragraph, INTRODUCTION | OK, the three engines alike: the caption's wrapped party name, rules (1 horizontal, as the exemplar: DEF-COVER-002 PASS) and columns the same. |
| 2 | End of the introduction, LEGAL STANDARD, ARGUMENT, heading I. (four bold lines), heading A., the start of I.A. | OK. Headings keep with the text after them. |
| 3 | Argument I.A. (LBR Services Agreement, Sale Order, public records) | OK. |
| 4 | End of I.A., heading B. (two lines), Argument I.B. | OK. |
| 5 | End of I.B., heading C. (two lines), Argument I.C. | OK. |
| 6 | Heading II. (two lines) and its A. (two lines), Argument II.A. | OK. |
| 7 | End of II.A., heading B., Argument II.B. | OK. |
| 8 | End of II.B., heading C. (three lines), the duplicative-claims argument | OK; short by design (Known gaps 10). |
| 9 | CONCLUSION, the signature block (Dated, firm, `/s/`, counsel lines), CERTIFICATE OF SERVICE and its `/s/` line | OK. The signature is with the conclusion, not alone. |

The latex and docx PDFs break every line and page where the typst PDF does (XENG-001..003: 246/246 lines, 9/9 pages, on both).

Defects of the earlier template (fixed by the cross-engine port, fb-595.68.35): em leadings with the paragraph spacing as the double space, a double space around every heading, the signature as a two-column grid, the certificate's breakable heading; a docx in EB Garamond with blank paragraphs and auto line spacing for the single lines.

[Formbook index](../../../../../../README.md)

## Engines

**typst** is the primary engine (`typst/main.typ`, `typst/vid-motion-brief.typ`, `typst/layout.yaml`). **latex** (`latex/template.tex`, `latex/xdoc.lua`) and **docx** (`docx/reference.xml`, `docx/xdoc.lua`) are generated by `fb engines gen` from the merged layout (`fb engines gen --check` fails on a stale one) and set by the shared code (`lib/pandoc/xdoc.lua`, `lib/latex/xdoc.lua`, `lib/docx/xdoc.lua`); `eval.yaml` gates them (`params.cross_engine: gate`). The old docx filter `docx/vid-motion-brief.lua` is removed (fb-595.17.22).

- Checks (2026-10-29): typst 11 passed, latex 14 passed, docx 15 passed, 0 failed; XENG-001..003 PASS on latex and docx (246/246 lines, 9/9 pages). No table of contents or authorities in this doc type (DEF-TOC-001 passes with none).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
