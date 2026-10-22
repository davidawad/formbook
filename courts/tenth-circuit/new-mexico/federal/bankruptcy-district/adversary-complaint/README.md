# nmb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the District of New Mexico (`nmb`, Tenth Circuit).
Folder: `courts/tenth-circuit/new-mexico/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the whole filing (10 pages), transcribed from the text layer |
| typeface | No face named (FRBP 9004 and NM LBR, 2023 edition, read in full 2026-10-15; neither names a typeface, font size or spacing). Times New Roman (vendored metric twin), the house standard, on typst and docx alike (fb-595.68.32; the docx was EB Garamond). |
| render | ok (2026-10-22, `sh tools/check.sh`): `usage/OUTPUT-adversary-complaint.typst.pdf`, 10 pages, letter, Times New Roman only, no typst warnings, on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.32) |
| overlay | ok (re-run 2026-10-15, `sh tools/overlay.sh`): `usage/OVERLAY-johnson-v-marker-complaint.pdf` and `OVERLAY-johnson-v-marker-complaint.txt`. The exemplar PDF is not in `usage/` in this snapshot; the run passed a copy fetched from the URL in `usage/SOURCE.md` (sha256 `fea81f88d4b89acffd7e08a90a9bf7eebca9a095e52ba387ab476e383b064eeb`, 10 pages, 2,966 words) as the optional third argument. |
| pages reviewed | 10 of 10 on typst and docx (every page rendered at 45 dpi and viewed side by side after the last template change, 2026-10-22) |
| check.sh / selftest | `sh tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed; `--engine docx`: RESULT: 13 checks passed, 0 failed (XENG-001..003 PASS). No selftest for this doc-type folder. |

## Governing rules

Primary sources. Fetch date 2026-10-14 for all.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, as amended eff. 2024-12-01) | Fed. R. Civ. P. 10 applies to an adversary complaint, except that the caption must substantially conform to Official Form 416. | `caption()` in `typst/nmb-adversary-complaint.typ`; the court line, debtor block, case number right, parties with adversary number, title. |
| Fed. R. Bankr. P. 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004, as amended eff. 2024-12-01) | A pleading must be clearly legible. Common English abbreviations are acceptable. | Body 12 pt Times New Roman, black on white (see Known gaps 1 and 2). |
| Fed. R. Bankr. P. 9004(b) | The caption sets out: (1) the court's name; (2) the case title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the paper. | Frontmatter `court`, `debtor`, `case_number`, `adv_number`, `title`. |
| NM LBR 9004-2 (local rules PDF, see below) | Every paper after the petition includes the chapter number, the case number, the judge's initial and the initial of the location of the 341 meeting, e.g. `7-10-12345-JA`. | `case_number` frontmatter (`Case No. 23-11087-J13`); the sample's own case number is transcribed as filed. Gate 1 would check the form; not checked here. |
| NM LBR 9011-1(a) | Every filed paper includes the name, address, telephone and e-mail of the attorney below the signature line. | `signature()`; the `email` line prints from the frontmatter. The filed copy has no e-mail (see Known gaps 4). |
| NM LBR 7016-1(a) | A party's failure to state consent to final orders under BR 7008, 7012 or 9027 is implied consent. | Not a template item: content the author must write (see Known gaps 5). |
| NM LBR 7007-1, 7007-2 (motions in adversary proceedings) | Briefs are optional unless the court orders otherwise. | Applies to `motion-brief`, not to the complaint. |

Local rules: Bankruptcy Local Rules of the District of New Mexico, PDF dated 2023-03-01, fetched 2026-10-14 from https://nmb.uscourts.gov/sites/default/files/local_rules/NMLocalRules111514_030123.pdf. The court's site also lists a 2019 edition (https://www.nmb.uscourts.gov/sites/default/files/local_rules/lr111514_040119.pdf); the 2023 edition is the later one and was used. Confirm the current edition on the court's site before relying on it.

Not verified against the rule text in this pass (cited from memory; check before use): FRBP 7001 (dischargeability proceedings, 7001(6)), FRBP 7008(a) (complaint's statement of jurisdiction and the core/non-core and final-order consent statement). The sample's jurisdiction paragraphs follow the filing.

## Layout

- Letter paper, 1 inch margins (convention; no rule given).
- Body 12 pt Times New Roman, double spaced: 24 pt line boxes (`pitch-double`), ragged right, on the shared cross-engine layout model (`lib/typst/xengine.typ`: no kerning, ligatures or hyphenation, first-fit line breaking).
- Court lines centered and bold at the top; a single line below them the debtor's lines at left and the case number at right; a single line below that the parties box (each party's names and role, a blank line between parties) ruled at its right and bottom, its text 9 pt off the rules, the adversary number beside its middle line; a double line below the caption the title, centered and bold. Every caption line a 15 pt single line (`pitch-single`), never split.
- The lead-in a double line below the title. Paragraphs numbered by the template from 1, first-line indent 0.5 in; typed numbers in the sample are dropped.
- Headings centered and bold at the body pitch, kept with the next block; claim headings are three centered lines.
- Block quotations single spaced (15 pt lines), indented 0.75 in each side, a single line above and below each quoted paragraph.
- Sub-items (`    1. ...`) lettered (a), (b), ... half an inch in, the text hanging 0.4 in after the letter.
- Footnotes with `[^n]` markers and frontmatter text, 10 pt in 11.5 pt lines under a 30 % rule, 7 pt between notes; a space after a marker in the text is kept.
- Footer: the short title left, `Page X of Y` right, 10 pt in an 11.5 pt line, 36 pt above the page foot.
- The prayer kept whole with the signature block. Signature block 3.25 in from the left margin, single spaced, never split: `Respectfully Submitted,`, the firm in bold, a `By:` line of underscores, signer, the address and telephone lines, e-mail, role.

## Markdown contract (for samples)

- YAML frontmatter: `court` (list), `debtor` (list; quote any item with a colon, because YAML reads `- IN RE DEBTOR:` as a mapping and renders it in monospace), `case_number`, `parties` (`names`, `role`), `adv_number`, `title`, `footer_title`, `lead_in` (the unnumbered opening paragraph), `prayer` (the unnumbered WHEREFORE paragraph), `signature` (`firm`, `signer`, `lines`, `email`, `role`), `footnotes` (map from number to text).
- Body: blank-line-separated chunks. `#` (level 1), `##` and `###` headings are centered and bold. `N.` at column 0 is a numbered paragraph (the number is dropped, the template renumbers). Indented `N.` is a lettered sub-item. `>` lines are a block quotation. Anything else is an unnumbered paragraph.
- Not supported: tables and raw typst. Dollar amounts in running text render correctly (checked on the page images).

## Known gaps and open choices

1. **Typeface.** No rule in the bankruptcy rules or the NM local rules sets a typeface (re-checked 2026-10-15 against the full text of the 2023 NM LBR PDF and FRBP 9004). The template sets Times New Roman (vendored metric twin), the house standard; the filed exemplar is an Equity-style serif at 12 pt for the body and Helvetica for the footer. Logged as a convention choice, not a rule defect.
2. **Paper and margins.** The rules cited here do not give a margin or paper size; the template uses letter and 1 inch. The exemplar's margins were not measured, and no coordinate was taken from it.
3. **One exemplar only.** The brief asks for one exemplar per doc type, so tier 2 is judged against one filer. Two more text-layer complaints from this court exist in the public RECAP set (Quorum Health v. Bailey, Adv. 18-01028; Montoya v. Goldstein, Adv. 20-01027; listed in `usage/SOURCE.md`). They were not saved here, so the tier-2 check against two or three filers is not done. Open for David: save one or both as `usage/` files and judge tier 2 against them.
4. **Exemplar e-mail.** The filed signature block has no e-mail line, which LBR 9011-1(a) requires. The sample carries a bracketed placeholder for the e-mail line, and the template prints it. The template follows the rule, not the exemplar.
5. **Consent statement.** The filed complaint does not state consent to final orders (FRBP 7008(a), 7012(b), see NM LBR 7016-1(a)). The template does not add one; it is author content. The consent paragraph's wording needs checking against FRBP 7008(a) before any real use.
6. **Case names are roman.** The text layer has no italic markup, so the sample's case names are roman. The template italicizes `*...*` from markdown; a sample that marks italics will show them.
7. **Overlay pairing.** The sample is the whole filing, so the overlay pairs every page. Our pages 1 to 5 pair with the filed pages 1 to 5; our pages 6 to 9 pair with filed pages 7 to 10 (word-overlap 52.6% to 91.6%), because our page breaks fall one paragraph apart from the filed ones. The word-overlap figures in `OVERLAY-*.txt` are a pairing aid, not a score (tier 3).
8. **Footer size.** 10 pt. No rule gives a footer size for bankruptcy papers.
9. **Filenames.** The brief names overlay outputs `<id>-overlay.pdf` and `<id>-overlay.txt`, and render outputs `<id>.pdf`. `tools/overlay.sh` reads and writes `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`, and `tools/render.sh` writes `OUTPUT-<id>.pdf` by default. The tools' names are used so that the overlay runs without changes to `tools/`.

## Review of the rendered pages (made on an earlier render, 9 pages. The 10 pages of the current typst and docx renders were viewed side by side on 2026-10-22: every line and page alike, caption, headings, footnote, signature and footers as described under Layout; no defect found. The page numbers in the table below are those of the earlier render)

Compared with the filed exemplar (10 pages).

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title, debtor block, case number right, party block with rule, adversary number, title centered; lead-in paragraph. No spill. | PASS |
| 2 | exemplar p.2 | "Jurisdiction and Venue" and "Facts Common to All Claims" centered bold; paragraphs 1 to 10 numbered, double spaced. | PASS |
| 3 | exemplar p.3 | Lettered sub-items (a) to (c) of paragraph 10 indented 0.5 in, text aligned after the letter; paragraphs 11 to 15 with footnote-free body. | PASS |
| 4 | exemplar p.4 | Block quotation of paragraph 16 (single spaced, indented both sides, citation after); paragraphs 17 to 20; Q/A block of paragraph 20 with the citation after it. | PASS |
| 5 | exemplar p.5 | Q/A block of paragraph 21; paragraphs 22 to 27. | PASS |
| 6 | exemplar p.6 | Paragraphs 28 to 35; no heading at page foot. | PASS |
| 7 | exemplar p.7 | Paragraphs 36 to 42; footnote 1 at page foot, 10 pt, separated by a rule; "First Claim for Relief" heading in three centered lines. | PASS |
| 8 | exemplar p.9 | Paragraphs 43 to 49; second claim heading; lettered list (a) to (c) of paragraph 46. | PASS |
| 9 | exemplar p.9 | Paragraphs 50 to 54; third claim heading; WHEREFORE paragraph; signature block at the right half with the `By:` line; e-mail placeholder. | PASS (placeholder, Known gaps 4) |

Gate 2 rows are recorded here, not in `reviews/`, because this doc type has no court-level `reviews/` folder.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

**docx** (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 15 pt single lines, 10 pt footnotes in 11.5 pt lines, 1 in margins; Body Text Note, Body Text Keep, Sub Item and a Footnote Text that splits) and `nmb-adversary-complaint.lua` (on `lib/docx/xengine.lua`: reads the sample as the typst template does, the frontmatter strings as written and the body in blank-line-separated chunks as CommonMark, and writes the court lines, the caption as two tables, the title, the lead-in, the numbered paragraphs, headings, quotations, lettered sub-items, the prayer, the signature and the footnotes in the typst template's line boxes and spaces; the footer with the short title and "Page X of Y" (PAGE and NUMPAGES fields) and the section through `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.32; were `build-reference.sh`, `reference.docx` and `nmb-filter.lua`, EB Garamond, with no title in the footer). Samples: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (10 pages, 262/262 lines).
- No TOC or TOA in this form, so no field-update caveat applies.
- No latex engine for this folder.
