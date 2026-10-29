# nmd: motion-brief

Doc type: **motion with its supporting argument** (a Rule 12(b) motion to dismiss that carries its memorandum in the same document) in the United States District Court for the District of New Mexico (`nmd`).
Folder: `courts/tenth-circuit/new-mexico/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer: Mynatt Springer P.C. for the City of Rio Rancho; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole 13-page motion, with its footnote 1) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 13 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with D.N.M.'s local rules overlaid in `typst/layout.yaml` (fb-595.17.19) |
| overlay | `just overlay courts/tenth-circuit/new-mexico/federal/district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 13 of 13 on typst, latex and docx (every page of the three renders viewed side by side at 40 dpi after the move onto the FRCP base, 2026-10-29) |

## Governing rules

Primary sources, fetched 2026-10-14. Each rule's text was read in the source; the quoted phrases are from those texts.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.M.LR-Civ. 7.1(a) | "A motion must be in writing and state with particularity the grounds and the relief sought." "Movant must determine whether a motion is opposed, and a motion that omits recitation of a good-faith request for concurrence may be summarily denied." Source: https://www.nmd.uscourts.gov/sites/nmd/files/local_rules/Local%20Rules%20of%20Civil%20Procedure%20Adopted%20October%201%2C%202020_0.pdf (Local Rules of Civil Procedure, "Amended Effective October 1, 2020"; index https://www.nmd.uscourts.gov/court-info/local-rules-and-orders/local-rules). | Sample content (the opening paragraph states the concurrence). The template does not check the wording. |
| D.N.M.LR-Civ. 7.1(b) | "A motion, response, or reply must include a certificate of service on each party." | `after_tail` (`when: service`) sets the certificate; `typst/nmd-motion-brief.typ` stops the render without `service.served`. |
| D.N.M.LR-Civ. 7.5 | The combined length of a motion and its supporting brief must not exceed 27 double-spaced pages (a response 24; a reply 12). | `eval.yaml` `params.page_limit: 27` (DEF-LEN-001, every engine; every page counted). |
| D.N.M.LR-Civ. 7.6 | Motions are decided on the briefs unless the Court orders a hearing; no hearing information is required on the caption. | No hearing line in the caption. |
| D.N.M.LR-Civ. 10.1 (Form) | 8½ × 11 white paper, one side; typewritten "at least 12 pitch", letter quality; margins: left, right and bottom at least 1 inch, **top at least 1½ inches**; text double spaced except footnotes and quotations; **first page has the case file number and initials of the assigned judges**. | The base: letter, 12 pt, 1 inch margins, 24 pt double pitch, single-spaced footnotes and quotations; `typst/layout.yaml` `margin: {top: 108}`; `case_number` on page 1 (the sample has `JMR/GJF`, as the filing does). |
| D.N.M.LR-Civ. 10.2 (Titles) | "The title of a document must clearly identify its substance and any filed document to which it responds or is connected." | `brief_title` (sample content: the title names the motion and the amended complaint it answers, with its docket entry "[Doc. 1-1]"), set in the filer's capitalization. |
| D.N.M.LR-Civ. 83.4(a) | An attorney's entry of appearance (and the initial pleading it signs) gives name, firm name, address, telephone number, electronic address and facsimile number; the attorney signs the initial pleading. | The base's `closing`: `signature.firm`, `signature.blocks`, `signature.counsel_for`. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion, "(B) state with particularity the grounds for seeking the order; and (C) state the relief sought." Fetched from https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Content (the sample's opening paragraph and conclusion state the grounds and relief). |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, and Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | `front` in `typst/layout.yaml` (the court's name from `constants`, the caption, the title). |
| Fed. R. Civ. P. 11(a) | Every written motion must be signed by an attorney of record, who must state the signer's address, e-mail address, and telephone number. Fetched from https://www.law.cornell.edu/rules/frcp/rule_11 on 2026-10-14. | The base's `closing`. |

## Layout

The generic FRCP brief with D.N.M.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there):

- Letter paper, top margin 1½ in, other margins 1 in. Page numbers centered in the bottom margin, Arabic from 1 on page 1 (the exemplar's running footer, "MOTION TO DISMISS PAGE x OF 13", is the filer's and is not reproduced).
- Court title (two lines, centered, bold); caption with ")" marks: parties on the left (designation an inch in, "v." between them), "Case No. …" at the right; the title centered, bold, underlined, in the sample's own capitalization.
- The opening paragraph (the motion's grounds and the LR-Civ. 7.1(a) concurrence) before the first heading, as in the filing.
- Body text 12 pt Times New Roman, double spaced in 24 pt line boxes, first-line indent ½ in, left aligned. Court title, caption, headings, signature and service lists in 13.8 pt single lines. The last paragraph of the body is kept with the signature block.
- Headings: level 1 centered bold capitals; level 2 a bold "I." argument heading and level 3 a bold "a." sub-heading, numbered by the template, the label in a ½ in box and the title hanging after it, 12 pt above and below, kept with what follows.
- Footnotes 12 pt, single spaced, under a 30 % rule.
- No table of contents or table of authorities: the D.N.M. rules cited do not require them for a motion of this length, and the exemplar has none.
- Signature (the base's closing): "Respectfully submitted," at the body pitch, then at the right the firm, a signature line, the attorneys' block and whom they represent, kept together with the last paragraph; then the certificate of service (centered bold heading, the statement at the body pitch, the service list two to a row, the signers at the right), kept together.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a paragraph, a `#` heading (level 1), `##` (level 2, argument heading), `###` (level 3, sub-heading); the template numbers levels 2 and 3. Footnotes `[^1]` with `[^1]: text` definitions.
- Frontmatter fields: `case_number` (with the assigned judges' initials after it), `case_label` (optional, default `Case No.`), `caption.parties` (list of `{names, designation}`; `names` one string, a newline between lines; "v." is inserted between parties), `brief_title` (in the sample's own capitalization), `signature` (`date_line`, `firm`, `blocks` (a list of line lists, one per attorney group), `counsel_for`), `service` (`text`, `served` (a list of entries, each its lines joined by newlines), `signed` (lines)).
- A list chunk (`-` or `1.` items) is set at the body pitch, the label in a half-inch box, the text hanging.
- Not supported: raw typst.

## Known gaps and open choices

1. **One exemplar, one filer.** The tier-2 rule asks for 2 or 3 filers. Searched: CourtListener RECAP (`type=r`, `court=nmd`, motions to dismiss with a memorandum, 2016 to 2026). Downloaded and text-checked: Turner v. City of Rio Rancho, 1:26-cv-03220 (saved). Other D.N.M. motions seen but not downloaded: McCombs v. Delta Group Electronics, Inc., 1:22-cv-00662 (docket 65307716); Serna v. County of Bernalillo Sheriff's Department, 1:23-cv-00254 (docket 67163945). Tier 2 is therefore **not** judged against two filers yet.
2. **Italics.** The exemplar's text layer has no italic markup, so case names are roman. The template italicizes `*...*` markdown, so a future sample can carry italics; the convention in a clerk's copy is italic case names.
3. **One document, no separate memorandum template.** This filing puts its argument in the motion. A separate memorandum brief would need its own sample.
4. **The certificate of service** wording and the service list are sample content. LR 7.1(b) requires the certificate, not particular words.
5. **Ragged right.** Body text is left aligned; the exemplar is justified. A tier-2/3 choice, not asserted.
6. **Caption.** The exemplar sets its parties without a ")" column, the case number beside the plaintiffs' designation; the template keeps the ")" caption it set before the move (the D.N.M. rules prescribe neither). DEF-COVER-002 finds no difference in order or alignment.
7. **Signature.** The base sets "Respectfully submitted," at the left and the firm above a signature line in the right column; the exemplar sets both in the signature column. Tier 3 (one filer's style).
8. **Self-test.** There is no `check-selftest.sh` run: the doc-type folder has no `court.json`.

## Gate 2 review (2026-10-29, the three renders after the move onto the FRCP base, every page)

| Page | What is on it | Finding | Status |
|---|---|---|---|
| 1 | Court title, caption with ")" marks, "Case No. 1:26-cv-03220 JMR/GJF", the title in two underlined lines, the opening paragraph, INTRODUCTION AND PROCEDURAL HISTORY | none | PASS |
| 2 | Introduction (end) with the note 1 mark; FACTUAL BACKGROUND; footnote 1 at the foot | none | PASS |
| 3 | Facts | none | PASS |
| 4 | Facts (end); LEGAL STANDARDS; a. Rule 12(b)(6) and Rule 8 | none | PASS |
| 5 | Rule 12(b)(6) standard (end) | none | PASS |
| 6 | b. Rule 12(b)(1); c. 28 U.S.C. § 1654 | none | PASS |
| 7 | d. Rule 42(b); ARGUMENT; I. (four-line heading, hanging); a. | none | PASS |
| 8 | a. (end); b. § 1983 claim | none | PASS |
| 9 | b. (end); c. criminal statutes | none | PASS |
| 10 | II. NMTCA notice; III. | none | PASS |
| 11 | III. (end); IV. bifurcation; CONCLUSION | none | PASS |
| 12 | The conclusion's last paragraph and the signature block | The last paragraph is kept with the signature, so the page holds only them | PASS |
| 13 | CERTIFICATE OF SERVICE, the two service groups side by side, the signers | none | PASS |

## Engines

typst (`typst/nmd-motion-brief.typ` names the face and asserts the certificate; `typst/layout.yaml` the D.N.M. overlay); latex (`latex/template.tex`, `latex/xdoc.lua`) and docx (`docx/reference.xml`, `docx/xdoc.lua`) generated by `fb engines gen` from the merged layout. `params.cross_engine: gate` in `eval.yaml`.

- typst: `RESULT: 12 checks passed, 0 failed`.
- latex: `RESULT: 15 checks passed, 0 failed`; XENG-001..003 PASS (13 pages, 309/309 typst lines break after the same word).
- docx: `RESULT: 16 checks passed, 0 failed`; XENG-001..003 PASS (13 pages, 309/309).
- The certificate assertion runs in typst only; the page limit runs in every engine.
- BLOCKED: none.

[Formbook index](../../../../../../README.md)
