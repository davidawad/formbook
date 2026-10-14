# nmb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the District of New Mexico (`nmb`, Tenth Circuit).
Folder: `courts/tenth-circuit/new-mexico/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-johnson-v-marker-24-01003-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-johnson-v-marker-complaint.md`: the whole filing (10 pages), transcribed from the text layer |
| render | ok: `samples/OUTPUT-johnson-v-marker-complaint.pdf`, 9 pages, letter, EB Garamond only (`pdffonts`), no typst warnings |
| overlay | ok: `samples/OVERLAY-johnson-v-marker-complaint.pdf` and `OVERLAY-johnson-v-marker-complaint.txt` |
| pages reviewed | 9 of 9 (every page of the current PDF rendered at 60 dpi and viewed) |
| check.sh / selftest | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/` |

## Governing rules

Primary sources. Fetch date 2026-10-14 for all.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, as amended eff. 2024-12-01) | Fed. R. Civ. P. 10 applies to an adversary complaint, except that the caption must substantially conform to Official Form 416. | `caption()` in `typst/nmb-adversary-complaint.typ`; the court line, debtor block, case number right, parties with adversary number, title. |
| Fed. R. Bankr. P. 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004, as amended eff. 2024-12-01) | A pleading must be clearly legible. Common English abbreviations are acceptable. | Body 12 pt EB Garamond, black on white (see Known gaps 1 and 2). |
| Fed. R. Bankr. P. 9004(b) | The caption sets out: (1) the court's name; (2) the case title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the paper. | Frontmatter `court`, `debtor`, `case_number`, `adv_number`, `title`. |
| NM LBR 9004-2 (local rules PDF, see below) | Every paper after the petition includes the chapter number, the case number, the judge's initial and the initial of the location of the 341 meeting, e.g. `7-10-12345-JA`. | `case_number` frontmatter (`Case No. 23-11087-J13`); the sample's own case number is transcribed as filed. Gate 1 would check the form; not checked here. |
| NM LBR 9011-1(a) | Every filed paper includes the name, address, telephone and e-mail of the attorney below the signature line. | `signature()`; the `email` line prints from the frontmatter. The filed copy has no e-mail (see Known gaps 4). |
| NM LBR 7016-1(a) | A party's failure to state consent to final orders under BR 7008, 7012 or 9027 is implied consent. | Not a template item: content the author must write (see Known gaps 5). |
| NM LBR 7007-1, 7007-2 (motions in adversary proceedings) | Briefs are optional unless the court orders otherwise. | Applies to `motion-brief`, not to the complaint. |

Local rules: Bankruptcy Local Rules of the District of New Mexico, PDF dated 2023-03-01, fetched 2026-10-14 from https://nmb.uscourts.gov/sites/default/files/local_rules/NMLocalRules111514_030123.pdf. The court's site also lists a 2019 edition (https://www.nmb.uscourts.gov/sites/default/files/local_rules/lr111514_040119.pdf); the 2023 edition is the later one and was used. Confirm the current edition on the court's site before relying on it.

Not verified against the rule text in this pass (cited from memory; check before use): FRBP 7001 (dischargeability proceedings, 7001(6)), FRBP 7008(a) (complaint's statement of jurisdiction and the core/non-core and final-order consent statement). The sample's jurisdiction paragraphs follow the filing.

## Layout

- Letter paper, 1 inch margins (convention; no rule given).
- Body 12 pt EB Garamond, double spaced (about 24 pt baseline pitch), left-aligned.
- Court title centered and bold at the top; debtor block at left and case number at right; party block with a rule at right and bottom and the adversary number to its right; title centered bold.
- Paragraphs numbered by the template from 1, first-line indent 0.5 in; typed numbers in the sample are dropped.
- Headings centered and bold; claim headings are three centered lines.
- Block quotations single spaced, indented 0.75 in each side.
- Sub-items (`    1. ...`) lettered (a), (b), ... under the paragraph before them.
- Footnotes with `[^n]` markers and frontmatter text, 10 pt.
- Footer: the title left, `Page X of Y` right, 10 pt.
- Signature block at the right half, firm in bold, `By:` line, signer, the address and telephone lines, e-mail, role.

## Markdown contract (for samples)

- YAML frontmatter: `court` (list), `debtor` (list; quote any item with a colon, because YAML reads `- IN RE DEBTOR:` as a mapping and renders it in monospace), `case_number`, `parties` (`names`, `role`), `adv_number`, `title`, `footer_title`, `lead_in` (the unnumbered opening paragraph), `prayer` (the unnumbered WHEREFORE paragraph), `signature` (`firm`, `signer`, `lines`, `email`, `role`), `footnotes` (map from number to text).
- Body: blank-line-separated chunks. `#` (level 1), `##` and `###` headings are centered and bold. `N.` at column 0 is a numbered paragraph (the number is dropped, the template renumbers). Indented `N.` is a lettered sub-item. `>` lines are a block quotation. Anything else is an unnumbered paragraph.
- Not supported: tables and raw typst. Dollar amounts in running text render correctly (checked on the page images).

## Known gaps and open choices

1. **Typeface.** No rule in the bankruptcy rules or the NM local rules sets a typeface. EB Garamond is the only vendored serif (`fonts/`); the filed exemplar is Equity-A-style serif at 12 pt for the body and Helvetica for the footer. The body reads a little smaller than the exemplar because EB Garamond has a smaller x-height than Equity at 12 pt. Logged as a convention choice, not a rule defect.
2. **Paper and margins.** The rules cited here do not give a margin or paper size; the template uses letter and 1 inch. The exemplar's margins were not measured, and no coordinate was taken from it.
3. **One exemplar only.** The brief asks for one exemplar per doc type, so tier 2 is judged against one filer. Two more text-layer complaints from this court exist in the public RECAP set (Quorum Health v. Bailey, Adv. 18-01028; Montoya v. Goldstein, Adv. 20-01027; listed in `exemplars/SOURCE.md`). They were not saved here, so the tier-2 check against two or three filers is not done. Open for David: save one or both as `exemplars/` files and judge tier 2 against them.
4. **Exemplar e-mail.** The filed signature block has no e-mail line, which LBR 9011-1(a) requires. The sample carries a bracketed placeholder for the e-mail line, and the template prints it. The template follows the rule, not the exemplar.
5. **Consent statement.** The filed complaint does not state consent to final orders (FRBP 7008(a), 7012(b), see NM LBR 7016-1(a)). The template does not add one; it is author content. The consent paragraph's wording needs checking against FRBP 7008(a) before any real use.
6. **Case names are roman.** The text layer has no italic markup, so the sample's case names are roman. The template italicizes `*...*` from markdown; a sample that marks italics will show them.
7. **Overlay pairing.** The sample is the whole filing, so the overlay pairs every page. Our pages 1 to 5 pair with the filed pages 1 to 5; our pages 6 to 9 pair with filed pages 7 to 10 (word-overlap 52.6% to 91.6%), because our page breaks fall one paragraph apart from the filed ones. The word-overlap figures in `OVERLAY-*.txt` are a pairing aid, not a score (tier 3).
8. **Footer size.** 10 pt. No rule gives a footer size for bankruptcy papers.
9. **Filenames.** The brief names overlay outputs `<id>-overlay.pdf` and `<id>-overlay.txt`, and render outputs `<id>.pdf`. `tools/overlay.sh` reads and writes `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`, and `tools/render.sh` writes `OUTPUT-<id>.pdf` by default. The tools' names are used so that the overlay runs without changes to `tools/`.

## Review of the rendered pages (current PDF, 9 pages)

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
