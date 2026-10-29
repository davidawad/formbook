# miwd: motion-brief

Doc type: **motion-brief** (brief in support of a Rule 12(b)(6) motion to dismiss) in the United States District Court for the Western District of Michigan (`miwd`).
Folder: `courts/sixth-circuit/michigan/federal/western-district/motion-brief/`. The motion itself (the notice of motion, a separate filing that states the relief sought, FRCP 7(b)(1)) is not produced here.

| Item | Status |
|---|---|
| exemplar | yes: 2 filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (primary, Barnes & Thornburg for Alliance Cloud) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (second filer, Biles Wilson for Skopos). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: the full 11-page filing's body (concise statement through conclusion, footnote, signature); TOC generated; TOA not transcribed |
| render | ok (2026-10-29, fb-595.17.17): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 9 pages each (cover, contents, 7 body pages), vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with W.D. Mich.'s local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` and `.txt` (gitignored; against the primary exemplar) |
| typeface | LCivR 10.1 names no face (it sets the size only; checked against the rule text 2026-10-15). Times New Roman (vendored, docs/FONTS.md), as the filed brief, in all three engines. |
| pages reviewed | 9 of 9 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |

## Governing rules

Verified 2026-10-14 (LCivR 7.2(b) as amended: the court folder's `../rules.md`, verified 2026-10-20).

| Rule | Requirement | Source | Where |
|---|---|---|---|
| LCivR 7.2(a) | A motion to dismiss for failure to state a claim is a dispositive motion. | Local Civil Rules, as posted: https://www.miwd.uscourts.gov/sites/miwd/files/Local%20Civil%20Rules.pdf | Scope of this doc type. |
| LCivR 7.2(b)(i) | A dispositive-motion brief produced on a computer is at most 10,800 words, headings, footnotes, citations and quotations included; the caption, cover, tables and signature block excluded (Administrative Order No. 26-RL-067, effective October 12, 2026; `../rules.md` MIWD-LEN-001). Before: 25 pages, exclusive of cover sheet, tables and indices (now the limit of a hand-written or typewritten brief). | same; `../rules.md` | `words: {limit: 10800}` in `typst/layout.yaml` (the body's words counted alike in every engine, the render stops over it); `eval.yaml` `params.page_limit: 25` (DEF-LEN-001), counted with the cover and contents. |
| LCivR 7.2(b)(ii) | A dispositive brief is accompanied by a Certificate of Compliance Regarding Word Count (the count and the name and version of the word-processing software). | `../rules.md` MIWD-CERT-002 | Not produced: OPEN (Known gaps 2). |
| LCivR 7.2(d) | A request for oral argument goes in the caption and in the heading of the brief. | same | `oral_argument_requested` frontmatter, printed under the judge on the cover. |
| LCivR 10.1 | Double spaced, 8 1/2 x 11, one side; type no smaller than 12 point; margins at least one inch. No typeface is named. | same | The base (letter, 12 pt, footnotes too, 24 pt double pitch, one-inch margins). |
| LCivR 10.3 | Date of signing and the address and telephone number of the signing attorney. | same | `closing`: `date`, `signature`. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `cover` in `typst/layout.yaml`. |
| Fed. R. Civ. P. 11(a) | Paper signed by an attorney of record, stating the signer's address, e-mail address and telephone number. | https://www.law.cornell.edu/rules/frcp/rule_11 (verified 2026-10-14) | `closing`. |

Not produced: the notice of motion and its order, the certificate of service, the Rule 7.1 disclosure statement, the certificate of concurrence (not required for a dispositive motion, LCivR 7.1(d)), the civil cover sheet.

## Layout (as built)

The generic FRCP brief with W.D. Mich.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/miwd-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Cover (page 1, unnumbered), the primary exemplar's: the court's name and the division centered in bold, a short rule under them; the parties at the left (designations half an inch in, "v." between them); at the right, centered on their height, the case number, the judge and, when requested, "ORAL ARGUMENT REQUESTED" bold and underlined (LCivR 7.2(d)); a rule across the page under the caption, in two halves (the exemplar's table border); the brief's title bold, underlined and centered.
- Contents (page i): "TABLE OF CONTENTS" centered in bold capitals, then a row per level 1 and level 2 heading, 12 pt apart: the label in a half-inch box (level 2 half an inch further in), a dot leader to the page in a 36 pt column. The docx takes the page numbers from its own LibreOffice render (`fb render`'s passes).
- Body (pages 1 to 7): double spaced, first-line indent 0.5 in. Headings single spaced, 12 pt above and below, kept with the next block, numbered by the template: I. bold capitals, A. bold, 1. and a. roman, each level half an inch further in, the label in a half-inch box with the title hung after it. Footnotes 12 pt, single spaced, under a 30 % rule. Block quotations single spaced, half an inch in on both sides.
- Signature: "Dated:" and the date at the left of the first line; the firm, "/s/" and the signer and the remaining lines from 2.8 in, kept with the last paragraph.
- Page numbers: none on the cover, roman on the contents, arabic from the first page of the brief, centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `judge` (a blank line to fill in when missing), `division`, `caption.parties` (list of `{names, designation}`; "v." between parties), `brief_title`, `oral_argument_requested` (true or absent), `date`, `signature` (`firm` list, `signer` string, `lines` list).
- Body: `#` level 1 heading, `##` level 2, `###` level 3, `####` level 4; paragraphs; block quotations (`>`); footnotes (`text[^key]` with `[^key]: text`); lists.
- Do not type heading numbers or the TOC. Escape pin cites that start with an asterisk (`at \*5`), or markdown reads them as emphasis.

## Review (Gate 2 record, 9 of 9 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx) and print the same contents page numbers. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`, `fb measure`; this pod has no image viewer). Compared with the primary exemplar (Valenzuela, filed 07/24/26).

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 (cover) | Valenzuela p.1 | Court title, the short rule, caption with case number, judge, "ORAL ARGUMENT REQUESTED", the rule under the caption, the underlined title; DEF-COVER-002 PASS (15/15 lines paired, 3 rules vs 3). The filed cover carries the page number "1"; ours has none. | ACCEPTED (cover unnumbered, a common convention; no rule numbers the cover) |
| 2 (contents) | Valenzuela p.2 (TOC), p.3 to 4 (TOA) | Entries I. to V. with A. and B., dot leaders, pages 1, 1, 2, 2, 3, 5, 7, as filed. The filed "Page" label over the page column is not set: the base's contents have no such label (tier 3). The filed table of authorities is absent: see Known gaps 1. | OPEN (TOA not generated) |
| 3 (body 1) | Valenzuela p.5 | I. and II. headings; concise statement and background; footnote 1 on the page of its reference. | PASS |
| 4 (body 2) | Valenzuela p.6 | Background end, III. legal standard, IV. argument introduction. | PASS |
| 5 (body 3) | Valenzuela p.7 | Heading A (two lines, hung after its label), its text. | PASS |
| 6 (body 4) | Valenzuela p.8 to 9 | Argument A continued; ¶¶ kept with their numbers. | PASS |
| 7 (body 5) | Valenzuela p.9 to 10 | End of A, heading B (two lines), its text. | PASS |
| 8 (body 6) | Valenzuela p.10 | Argument B continued; the page ends early because the conclusion is kept with the signature. | PASS |
| 9 (body 7) | Valenzuela p.11 | V. CONCLUSION, its paragraph, the date and signature block together. | PASS |

Tier-2 items recorded as accepted or open:

- **Table of authorities (OPEN).** The filed brief has one; the sample does not key its citations (`[text](toa:key)` with `authorities:` in the frontmatter, which the base can set), so none is generated.
- **Caption (ACCEPTED).** The second filer (Coddington) uses a section-mark (§) column between the parties and the case number; the template follows the primary exemplar.

## Known gaps

1. **No table of authorities** (OPEN, above).
2. **Word-count certificate (OPEN, tier 1).** LCivR 7.2(b)(ii) asks for a Certificate of Compliance Regarding Word Count naming the word-processing software and its version. The word limit itself is now checked in every engine (`words: {limit: 10800}`), but a certificate that names the software differs between engines (typst, LaTeX, Word), so its wording needs a decision before it is set.
3. **Italics are our marking.** Case names and signals are italic by citation convention; the filed text layer has no italic markup.
4. **Cover numbering.** The filed cover shows "1", and the body restarts at 1 after the contents. Ours leaves the cover unnumbered and starts the body at 1 (tier 2).

## Searches (exemplar)

CourtListener search for W.D. Mich. motions and briefs in support of a motion to dismiss (`court=miwd`, RECAP `type=r`, filed 2024 to 2026). Downloaded and checked for a text layer: Valenzuela (11 pp., text), Coddington (26 pp., text), and Moser (64 pp., Attorney General, set aside because it runs well past the 25-page limit of a single brief). Chosen: Valenzuela (primary) and Coddington (second filer).

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief --engine typst   # 12 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief --engine latex   # 15 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief --engine docx    # 16 passed, 0 failed
```

## Engines

typst (primary): `typst/main.typ` -> `typst/miwd-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.17). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx.
