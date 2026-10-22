# miwd: motion-brief

Doc type: **motion-brief** (brief in support of a Rule 12(b)(6) motion to dismiss, with its memorandum) in the United States District Court for the Western District of Michigan (`miwd`).
Folder: `courts/sixth-circuit/michigan/federal/western-district/motion-brief/`. Self-contained: it does not touch the court root (`court.json`, `typst/`, `usage/`, `usage/`). The motion itself (the notice of motion, a separate filing that states the relief sought, FRCP 7(b)(1)) is not produced here.

| Item | Status |
|---|---|
| exemplar | yes: 2 filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (primary, Barnes & Thornburg for Alliance Cloud) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (second filer, Biles Wilson for Skopos). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: the full 11-page filing's body (concise statement through conclusion, footnote, signature); TOC generated; TOA not transcribed |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` (typst 0.15.0, no warnings) and `usage/OUTPUT-motion-brief.docx` with its LibreOffice PDF `usage/OUTPUT-motion-brief.docx.pdf`, 9 pages each (cover, contents, 7 body pages), vendored Times New Roman only; the docx breaks every line and page where typst does (Gate 4, `params.cross_engine: gate` in `eval.yaml`) |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` and `.txt` (gitignored; against the primary exemplar) |
| typeface | LCivR 10.1 names no face (it sets the size only; checked against the rule text 2026-10-15). Times New Roman (vendored, docs/FONTS.md), as the filed brief, in both engines (the docx was EB Garamond before 2026-10-22). Embedded: Times New Roman only (`pdffonts`). |
| pages reviewed | 9 of 9 in each engine (typst and docx, every page rendered at 60 dpi and viewed 2026-10-22; see the review below) |

Build, from the repo root (`PATH` must include the toolchain):

```sh
sh tools/render.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief motion-brief usage/FILED-EXAMPLE-motion-brief.pdf
```

`tools/render.sh` writes `usage/OUTPUT-<id>.typst.pdf` (`--engine docx`: `usage/OUTPUT-<id>.docx` and `.docx.pdf`); `sh tools/check.sh <this folder> --engine typst|docx` runs the gates.

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| LCivR 7.2(a) | A motion to dismiss for failure to state a claim is a dispositive motion. | Local Civil Rules, as posted: https://www.miwd.uscourts.gov/sites/miwd/files/Local%20Civil%20Rules.pdf (text dated "Updated February 1, 2018"; the court's rules page shows last modified January 1, 2019) | Scope of this doc type. |
| LCivR 7.2(b) | A brief in support of a dispositive motion is at most 25 pages, exclusive of cover sheet, tables and indices. | same | `max-body-pages = 25`. The template measures the pages from the first page of the brief to the last and fails the build over 25 (`assert` in `typst/miwd-motion-brief.typ`). |
| LCivR 7.2(c) | Reply brief may be filed within 14 days, not more than 10 pages. | same | Not produced (a separate filing). |
| LCivR 7.2(d) | A request for oral argument goes in the caption and in the heading of the brief. | same | `oral_argument_requested` frontmatter, printed under the case number. |
| LCivR 7.1(a) | A brief states the concise reasons in support of the party's position and cites the rules and authorities relied on. | same | Author content. |
| LCivR 7.1(d) | Concurrence certificate is required for non-dispositive motions only. | same | Not required here (not produced). |
| LCivR 10.1 | Double spaced, 8 1/2 x 11, one side; type no smaller than 12 point; margins at least one inch. No typeface is named (checked 2026-10-15). | same | `type-size`, `pitch-body`, `margin` (typst/miwd-motion-brief.typ; docx/reference.xml). Footnotes are 12 point too. |
| LCivR 10.3 | Date of signing and the address and telephone number of the signing attorney. | same | `signature` frontmatter. |
| LCivR 5.7(d)(i) | Electronically filed documents must be in PDF digital format. | same | Render is PDF (`typst compile`). |
| Fed. R. Civ. P. 7(b)(1) | A motion must state with particularity the grounds and the relief sought. | https://www.law.cornell.edu/rules/frcp/rule_7 (verified 2026-10-14) | Author content; the brief's concise statement (section I) states the grounds. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. The title of other papers may name the first party on each side. | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `court-title`, `caption`. |
| Fed. R. Civ. P. 11(a) | Paper signed by an attorney of record, stating the signer's address, e-mail address and telephone number. | https://www.law.cornell.edu/rules/frcp/rule_11 (verified 2026-10-14, lead-in text) | `signature-block`. |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim may be raised by motion made before pleading. | https://www.law.cornell.edu/rules/frcp/rule_12 (verified 2026-10-14, lead-in text) | Author content. |

Not produced: the notice of motion and its order, the certificate of service, the Rule 7.1 disclosure statement (for a nongovernmental corporate party), the civil cover sheet, and the Rule 5.2 redactions (author responsibility).

## Layout (as built)

Both engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch (24 pt double, 13.8 pt single), the spaces between blocks explicit, first-fit ragged-right breaking without kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does.

- Cover (page 1, no number): court title centered in bold (three single lines); 24 pt below it the caption (the parties single-spaced in a 3.25 in column closed by a rule on its right and under it, "v." between them; 0.35 in to the right the case number, the judge and, 12 pt below, "ORAL ARGUMENT REQUESTED" in bold, LCivR 7.2(d)); 72 pt below it the title of the brief, bold and centered in the middle 80 % of the line, double spaced.
- Contents (page i): "TABLE OF CONTENTS" centered in bold, "Page" at the right 24 pt below, then a single-spaced row per level 1 and level 2 heading, 12 pt apart: the label in a half-inch box (level 2 half an inch further in), the title hanging after it, a dot leader to the page number in a 36 pt column. The docx takes the page numbers from the LibreOffice render (needles, `fb render`'s passes), so they are its own pages.
- Body (pages 1 to 7): double spaced, first-line indent 0.5 in on every paragraph. Headings single-spaced at the type size, 12 pt above and below, kept with the next block, the label in a half-inch box after the level's half-inch step and the text hanging after it: level 1 bold capitals (I., II.), level 2 bold (A., B.), levels 3 (1.) and 4 (a.) regular. The numbers come from the template. Footnotes 12 pt, single spaced, 7 pt apart, under a short rule. Block quotations single spaced, half an inch in on both sides, 12 pt off the text.
- Signature: 24 pt below the last paragraph, single spaced: "Dated:" and the date at the left of the first line; the firm, then 12 pt below "/s/" and the signer and the remaining lines, from 2.8 in. The last paragraph is kept on one page with it.
- Page numbers: none on the cover, roman on the contents, arabic from the first page of the brief (restarting at 1), centered in a single-pitch line whose box ends 0.5 in above the edge.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `judge` (both print a blank line when empty), `division`, `caption.parties` (list of `{names, designation}`; "v." between parties), `title`, `oral_argument_requested` (true or absent), `date`, `signature` (`firm` list, `signer` string, `lines` list).
- Body: blank-line-separated chunks. `#` level 1 heading, `##` level 2, `###` level 3, `####` level 4; body paragraphs; block quotations (`>`, single spaced, indented); footnotes (`text[^key]` with `[^key]: text` anywhere in the body; the body is rendered whole, the last paragraph apart, kept with the signature); lists (`-` or `1.`, the label in a half-inch box).
- Do not type heading numbers or the TOC. Escape pin cites that start with an asterisk (`at \*5`), or markdown reads them as emphasis.
- Not supported: tables, images, raw typst.

## Review (Gate 2 equivalent, current PDFs)

Each page of `OUTPUT-motion-brief.typst.pdf` and `OUTPUT-motion-brief.docx.pdf` was rendered at 60 dpi and viewed side by side (2026-10-22); the two engines set the same lines on the same pages (XENG-001..003 PASS, 200/200 lines) and print the same contents page numbers. Compared with the primary exemplar (Valenzuela, filed 07/24/26).

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 (cover) | Valenzuela p.1 | Court title, caption with its rule, case number and judge, "ORAL ARGUMENT REQUESTED", title below the caption. The filed cover carries the page number "1"; ours has none. | ACCEPTED (cover unnumbered, a common convention; no rule numbers the cover) |
| 2 (contents) | Valenzuela p.2 (TOC), p.3 to 4 (TOA) | The entries and headings match the filed contents, with dot leaders; page numbers 1, 1, 2, 2, 3, 5, 7, as filed. The filed table of authorities is absent: see Gap 1. | OPEN (TOA not generated) |
| 3 (body 1) | Valenzuela p.5 | I. and II. headings bold, single spaced; concise statement and background; footnote 1 on the page that carries its reference; italic case names. | PASS |
| 4 (body 2) | Valenzuela p.6 | Background end, III. legal standard, IV. argument introduction. | PASS |
| 5 (body 3) | Valenzuela p.7 | Heading A (two lines, bold, hanging after its label), its text. | PASS |
| 6 (body 4) | Valenzuela p.8 to 9 | Argument A continued; citations with *id.* and signals in italics; ¶¶ kept with their numbers. | PASS |
| 7 (body 5) | Valenzuela p.9 to 10 | End of A, heading B (two lines), its text. | PASS |
| 8 (body 6) | Valenzuela p.10 | Argument B continued and its last paragraph; the page ends early because the conclusion is kept with the signature. | PASS |
| 9 (body 7) | Valenzuela p.11 | V. CONCLUSION, its paragraph, the date and signature block together. | PASS |

Tier-2 items recorded as accepted or open:

- **Table of authorities (OPEN).** The filed brief has one; the template does not generate one. A TOA needs a citation registry (as in the ca9 template: each citation is linked with its authority key and its page recorded), which this doc type does not have yet.
- **Caption (ACCEPTED).** The second filer (Coddington) uses a section-mark (§) column between the parties and the case number; the template uses a party column closed by a rule, as in the complaint. Both forms appear in this district's filings (tier-2 choice).
- **Font (ACCEPTED).** LCivR 10.1 names no typeface; the template sets Times New Roman, as the filed brief, in both engines (the docx was EB Garamond before 2026-10-22). LCivR 10.1 sets 12 point, which is met, footnotes included.

## Overlay

`just overlay courts/sixth-circuit/michigan/federal/western-district/motion-brief` writes the red/blue overlay of the typst render on the primary exemplar to the gitignored `.overlay/` (a diagnostic, not a score). The contents page overlays the filed contents and, in blue only, the filed table of authorities that we do not produce.

## Known gaps

1. **No table of authorities** (OPEN, above). The exemplar's TOA is the target. The sample does not transcribe it.
2. **Word limit and its certificate (OPEN, tier 1).** The court folder's `rules.md` (verified 2026-10-20) records the amended rules as adopted by Administrative Order No. 26-RL-067 (August 13, 2026, effective October 12, 2026): a dispositive-motion brief produced on a computer may not exceed 10,800 words (LCivR 7.2(b)(i), MIWD-LEN-001; the 25-page limit now applies to hand-written or typewritten briefs) and must be accompanied by a Certificate of Compliance Regarding Word Count stating the count and the name and version of the word-processing software (LCivR 7.2(b)(ii), MIWD-CERT-002). The template still enforces the 25-page limit only and prints no certificate. Adding it is a content change outside the cross-engine port (fb-595.68.30): the count must be the same in every engine, and a certificate that names the software differs between engines (docs/EVAL-LOOP.md, "What the first adoption found"), so its wording needs a decision.
3. **Italics are our marking.** Case names and signals are italic by citation convention. The filed text layer has no italic markup and I did not check the typeface span by span, so the italics are not a transcription of the filing.
4. **Font** (above): Times New Roman in both engines.
5. **Not produced:** the notice of motion, the certificate of service, the Rule 7.1 disclosure statement, the certificate of concurrence (not required for a dispositive motion, LCivR 7.1(d)), the proposed order.
6. **Checker.** `tools/check.sh` runs on this folder (typst and docx: every gate green, 2026-10-22). `tools/check-selftest.sh` needs a court folder with `court.json` and does not run here.
7. **Cover numbering.** The filed cover shows "1", and the body restarts at 1 after the contents. Ours leaves the cover unnumbered and starts the body at 1. Both appear in W.D. Mich. filings; this is tier-2.

## Searches (exemplar)

CourtListener search for W.D. Mich. motions and briefs in support of a motion to dismiss (`court=miwd`, RECAP `type=r`, filed 2024 to 2026). Downloaded and checked for a text layer: Valenzuela (11 pp., text), Coddington (26 pp., text), and Moser (64 pp., Attorney General, set aside because it runs well past the 25-page limit of a single brief). The other search hits were not downloaded. Chosen: Valenzuela (primary) and Coddington (second filer).

## Engines

DOCX (`docx/`): `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and its LibreOffice PDF. `fb render` builds the styles from `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`, Times New Roman 12 pt, 24 pt and 13.8 pt exact line boxes; Footnote Text, Block Text, "Body Text Note" and "Body Text Keep") and runs `docx/miwd-motion-brief.lua` on `lib/docx/xengine.lua`, which writes the cover, the contents, the numbered headings, the signature, the page-number footer (`$FORMBOOK_FOOTERS`) and the three sections (cover unnumbered, contents lower roman, brief arabic; the last via `$FORMBOOK_FINAL`). The contents' page numbers come from needles (`$FORMBOOK_NEEDLES`: each heading with the words after it, the brief's last line) that `fb render` finds in the LibreOffice PDF and feeds back (`$FORMBOOK_PAGES`) until they settle; the same pass checks the 25-page limit (LCivR 7.2(b)). pandoc reads the sample as CommonMark, as cmarker does; a frontmatter line that starts like a list label ("(616) 742-3930") is set from its text as written (`$FORMBOOK_META`). There are no shell scripts and no committed `reference.docx` (were `docx/build-reference.sh`, `render.sh`, EB Garamond and a TOC field without page numbers, until 2026-10-22).

- Gate 4: XENG-001..003 PASS (9/9 pages, 200/200 lines), `params.cross_engine: gate` in `eval.yaml`.
- Differs from typst by design: heading numbers are typed text and a tab, not Word numbering; the contents are typed rows with their page numbers, not a TOC field (Word does not renumber them when the text changes; re-render instead); the caption rule is a cell border.
- Not produced in either engine: the table of authorities (open gap, above).
