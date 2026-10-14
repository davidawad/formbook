# sdb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of South Dakota (`sdb`).
Folder: `courts/eighth-circuit/south-dakota/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: 3 real filings from 3 different filers, see `exemplars/SOURCE.md`. Primary: `exemplars/FILED-EXAMPLE-chase-abrams-08-05003-adversary-complaint.pdf` (creditor). Also `…richards-14-01006…` (debtors) and `…pierce-bekuto-11-04028…` (trustee). |
| sample md | `samples/INPUT-chase-abrams.md`: transcribed from the primary exemplar (all of it: caption, three headings, 16 allegations, the prayer, the signature). `samples/INPUT-fictional-joint-debtors.md`: FICTIONAL, for structure (joint debtors, fka, two plaintiffs, two defendants, two claims under different subsections, a 4-item prayer). |
| render | ok: `samples/OUTPUT-chase-abrams.pdf` (2 pages) and `samples/OUTPUT-fictional-joint-debtors.pdf` (2 pages). typst 0.15.0, `tools/render.sh`, vendored EB Garamond only (pdffonts: EBGaramond-Regular and -Bold, embedded), zero typst warnings. |
| overlay | ok: `samples/OVERLAY-chase-abrams.pdf` and `samples/OVERLAY-chase-abrams.txt` (page map: p.1 ↔ p.1 80.2 %, p.2 ↔ p.2 74.3 % word overlap; a diagnostic, not a score). |
| pages reviewed | 4 of 4 for the current PDFs: 2 pages of `OUTPUT-chase-abrams.pdf` and 2 of `OUTPUT-fictional-joint-debtors.pdf`, each rasterized at 60 dpi and viewed after its last change. Exemplar pages 1 and 3 were viewed for comparison (page 2 was not viewed as a page image; its text was read with pdftotext). |

## File names (deviation from the brief)

The brief names files `samples/<id>.pdf`, `<id>-overlay.pdf` and `<id>-overlay.txt`. The shared tools (`tools/render.sh`, `tools/overlay.sh`) read and write `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`, and the repo convention (`docs/EVAL-LOOP.md`) uses those names, so this folder follows the tools. `tools/` was not edited. The overlay was run with the exemplar given explicitly, because `overlay.sh` otherwise takes the alphabetically first file in `exemplars/`.

`tools/check.sh` and `tools/check-selftest.sh` were **not** run: they expect a court folder with `court.json` and `rules.md` (this folder is a doc-type folder, the same situation as the cand complaint folder). The Gate 2 rows below are the review for this doc type.

## Governing rules

Sources, fetched 2026-10-14. Rules are verified against the text, not the summaries.

| Source | URL |
|---|---|
| Bankr. D.S.D. Local Bankruptcy Rules and Appendices, as amended June 14, 2024 (revised 1/24/25), with bookmarks | https://www.sdb.uscourts.gov/sites/sdb/files/local_rules/Local%20Rules%20and%20Appendices%20as%20Amended%20June%2014%2C%202024%20%28revised%201%2024%2025%29%20with%20bookmarks%20and%20links_1.pdf |
| Court's sample adversary caption (a court form, not a filing) | https://www.sdb.uscourts.gov/sites/sdb/files/forms/Sample%20Caption%20Adversary.pdf |
| Fed. R. Bankr. P. 7001, 7008, 7010, 9004 | https://www.law.cornell.edu/rules/frbp/rule_7008 (and `…/rule_7010`, `…/rule_9004`) |
| Fed. R. Civ. P. 10(b), applied in adversary proceedings by FRBP 7010 | https://www.law.cornell.edu/rules/frcp/rule_10 |

| Rule | Kind | Requirement | Where in the template / status |
|---|---|---|---|
| Bankr. D.S.D. R. 9004-1(a)(1) | **M** | White 8½ × 11 paper, margins of not less than one inch, one simple font, typewritten, no erasures. | `page-w`, `page-h`, `margin = 1in`, `font-family` (EB Garamond, the only font vendored). Font size is not set by any rule (see Known gaps). |
| Bankr. D.S.D. R. 9004-1(a)(4) | **M** | Portrait orientation. | `page-w` < `page-h`. |
| Bankr. D.S.D. R. 9004-1(a)(3) and 9004-2(a) | **M** | Caption per Rule 9004-2: debtor's full name; full EIN (if any); last four digits of SSN (individual) or TIN (if any); names used within eight years, with `aka` / `fka`. | `caption()`: each debtor's `name`, `ssn_last4`, `ein`, `tin_last4`, `aka`, `fka`. The template **stops the build** if a debtor has no EIN, SSN last four or TIN last four (`assert`). |
| Bankr. D.S.D. R. 7010-2 and FRBP 7010 (Form 416) | **M** | Full bankruptcy caption with the complete legal names of all parties, including punctuation; conforms to Official Form 416D and Appendix 7A. | `caption()` prints the court name, `Bankr. No.`, `Chapter`, `Adv. No.`, every plaintiff and defendant with its designation. The name strings are the frontmatter's; the template does not shorten them. |
| Bankr. D.S.D. R. 9004-1(a)(5) | **M** | Each document signed and dated, the filing attorney per Part V of the ECF Procedures. | `signature()`: `DATED <date>.`, `/s/ <signer>`, firm lines. |
| FRBP 7008(a) | **M** | The complaint states the basis for jurisdiction, with the name, number and Code chapter of the case, and the district and division; it states whether the pleader consents to the entry of final orders or judgment by the bankruptcy court. | Jurisdiction is authored body text (not checked). **Consent statement is not checked by the template** (see Known gaps: the Chase transcription has none; the fictional sample has one). |
| FRBP 7009 (fraud, mistake) | **M** | Particularity for fraud-based claims. | Author responsibility, not checked. |
| Bankr. D.S.D. R. 7001-2(b) | **M** | A complaint to determine dischargeability specifies the § 523(a) subsection(s), and for § 523(a)(2) whether (a)(2)(A) or (a)(2)(B). | Author responsibility: the Chase sample cites § 523(a)(2)(A) and the fictional sample cites (a)(2)(A) and (a)(6). Not checked. |
| Bankr. D.S.D. R. 7001-2(a) | **M** | A complaint objecting to discharge specifies the § 727(a) subsection(s). | Author responsibility. Not checked. |
| FRCP 10(b) (via FRBP 7010) | **M** | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `sdb-adversary-complaint()` numbers every body paragraph, starting at 1 after the lead-in. The prayer (a heading beginning PRAYER) is not numbered. |
| Bankr. D.S.D. R. 7007-1 | **M** | A motion in an adversary proceeding is filed separately from the pleading. | Not in this doc type (see `../motion-brief/`). |
| Convention (tier 2) | C | Caption layout: `In re:` block on the left, `)` marks, case numbers on the right, party designations right-aligned, `v.` between sides (the Chase exemplar and the court's sample caption). | `caption()`. |
| Convention (tier 2) | C | Centered bold headings with roman numerals; a centered bold prayer heading; the lettered or numbered prayer. | `# ` headings and list chunks. |
| Convention (tier 2) | C | Court name on two lines, centered bold, above the caption. | `caption()` top. |
| Convention (tier 2) | C | Signature block at the middle of the page, `DATED <date>.` on the left of the page above it. | `signature()`. |

Tier 1 is every `M` row. A failing `M` row is a defect; a missing one is not checked by the template and is listed under Known gaps.

## Template

| File | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/sdb-adversary-complaint.typ` | The template: `sdb-adversary-complaint(meta, md)`, `caption()`, `signature()`. All parameters are named at the top; no case-specific text, no coordinates, no forced line breaks. |

Markdown contract (frontmatter; the body is blank-line-separated chunks):

- `debtors`: list of `{name, ssn_last4 | ein | tin_last4, aka, fka}`. `ssn_last4`, `ein` or `tin_last4` is required (`assert`).
- `bankr_no`, `chapter`, `adversary_no`.
- `plaintiffs`, `defendants`: lists of `{names, designation}`.
- `title`: the title of the complaint (printed bold, centered, below the caption).
- `lead_in` (optional): an unnumbered paragraph after the title (the COMES NOW opening).
- `signature`: `{date, signer, firm (lines), role}`.
- Body: `# Heading` (centered bold). Other chunks are numbered allegations. A chunk starting `1. ` is a list (prayer items). A heading whose text contains PRAYER turns numbering off.
- Not supported: tables, footnotes, raw typst, `##` headings (they would print with cmarker's default style), and a verification or certificate of service (no exemplar here needed one for the template to be complete; see Known gaps).

## Layout

- Letter size; margins 1 inch on every side; body 12 pt EB Garamond, single spaced (0.5 em leading), 12 pt between paragraphs, first-line indent 0.5 inch on numbered paragraphs.
- Caption: a three-column grid (3.3 in party column with 0.2 in right pad, a 0.3 in ")" column, the right column for numbers). Every row is one line; `row-gutter: 0.5em` keeps the lines apart.
- Footer: page number, 10 pt, centered.

## Gate 2 review (current PDFs)

Reviewed after the last change, every page of each PDF, at 60 dpi, next to the exemplar pages where they correspond. sha256 of the reviewed PDFs (the review is stale if these change):

- `samples/OUTPUT-chase-abrams.pdf`: `b466466dfc3e5d638a7224a0e888819bc9706fb92f96b3cd87d0b59118b65de8`
- `samples/OUTPUT-fictional-joint-debtors.pdf`: `db23cc668bc4182cee68e986f8cb30e5f90f35ac3d4e73904cdb6b3741c2ffe3` (rendered once more after the consent line was added; the hash above is from that render. Recheck with `sha256sum` before landing.)

### sample chase-abrams (transcribed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Caption: court name, `In re:` block, `)` column, `Bankr. No.`, `Chapter 7`, `Adv. No.`, party designations right-aligned as in the exemplar. The ECF stamp at the top of the exemplar ("Case: 08-05003 Document: 1 Filed …") is added by CM/ECF on filing, not by the filer, so it is not generated. | PASS |
| 1 | exemplar p.1 | Title sits below the caption, centered and bold; the exemplar puts it in the right column next to the caption. SD local rules require conformance to Form 416D, which does not fix where the title goes in the column. | ACCEPTED: title below the caption is the court's own sample form's layout; the choice is not mandated. |
| 1 | exemplar p.1 | Font is EB Garamond; the exemplar is set in Arial. R. 9004-1(a)(1) requires one simple font, not a particular face. | ACCEPTED: only EB Garamond is vendored (no Arial or Times); a size and face choice is not mandated. |
| 1 | exemplar p.1 | Title "(11 U.S.C. § 523)" breaks after "11 U.S.C." and keeps "§ 523)" together (non-breaking space in the frontmatter). | PASS |
| 2 | exemplar p.2 | Prayer heading centered; the "WHEREFORE" paragraph is unnumbered, as in the exemplar; items 1 to 4 are a list. | PASS |
| 2 | exemplar p.3 | Signature: `DATED February 19, 2008.` at the left, `/s/ Rick A. Mickelson` and the firm lines indented to the middle. The Chase exemplar puts its signature at the left margin with an underlined `s/` line; Richards and Pierce both indent to the middle (2 of 3 filers), so the middle is the convention. The template prints `/s/` (ECF Part V). | ACCEPTED: the left-margin signature is one filer's style (Chase), not the convention. |

### sample fictional-joint-debtors (structure test, FICTIONAL)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | none (fictional; checked against the template rules) | Two debtors, each with SSN last four; `fka` line; `Debtors.` label on the right after the debtor block; two plaintiffs; `v.`; two defendants with `Defendant One,` and `Defendant Two.`; `Adv. No.` on the first plaintiff row. All right. Paragraph 5 is the 7008(a) consent statement. | PASS |
| 1 | none | Title "COMPLAINT TO DETERMINE DISCHARGEABILITY OF DEBTS (11 U.S.C. § 523(a)(2)(A) AND (a)(6))" breaks after "(a)(2)" leaving "(A) AND (a)(6))" on line 2. Typst breaks after a closing parenthesis. | ACCEPTED: a typesetting choice inside a statute cite; the rule does not fix it, and a word joiner would be an author decision (see Known gaps). |
| 2 | none | Headings "II. FIRST CLAIM FOR RELIEF: NONDISCHARGEABILITY UNDER 11 U.S.C. § 523(a)(2)(A)" and "III. …§ 523(a)(6)" wrap at the statute cite, the second line centered. Same cause as the title. | ACCEPTED: same as above. |
| 2 | none | Italic "represented in writing" in paragraph 7 is italic; numbering runs 6 to 16 across the two claims; prayer items 1 to 4; `DATED January 1, 2001.` and the signature block. | PASS |

## Known gaps and open choices

1. **Second exemplar and third exemplar are not from the same court form.** All three are sdb filings from 2008, 2011 and 2014: one creditor, one debtor, one trustee. Tier 2 is judged against these. The sample exemplar predates the current rule text; the caption rules (9004-2) and the consent statement (7008(a)) have changed since (the 7008 text fetched today requires a consent statement).
2. **Consent statement (FRBP 7008(a)) is not checked by the template.** The Chase transcription does not have one (the exemplar predates it), so the template does not require it. The fictional sample has it (paragraph 5). A future check should be added to `checks.yaml` (not present: no check tooling in this folder) or the frontmatter should carry it.
3. **Font size.** No local rule sets a size. The template uses 12 pt EB Garamond, which looks smaller than 12 pt Arial or Times. This is a tier-2 choice, not a rule. If the clerk expects a larger apparent size, the choice is for David.
4. **Verification and certificate of service are not generated.** The Richards and Pierce exemplars carry a verification under oath (Richards' is signed by each debtor before a notary). No rule in the local rules or FRBP 7001–7010 requires one for every adversary complaint; the template does not produce one. A complaint with a verification needs a second `signature`-like block. Not built.
5. **Statute-cite line breaks.** Typst breaks lines after `)` in citations like `§ 523(a)(2)(A)`. Non-breaking spaces (done for `§ 523`) do not stop that. A word joiner (U+2060) between the subsections would, but that is author text, so it is not in the template.
6. **Joint-debtor signature.** The template prints one `signature` block. Joint filings sign once for the attorney, so this matches; a separate debtor verification would be needed (see 4).
7. **No check tooling run** (see File names above).
8. **Paragraph numbers.** The template numbers from 1 after the lead-in. The Chase exemplar's numbers match (1 to 16). The Richards exemplar's numbering is not transcribed (it is a different sample).

## Loop log

- Iteration 1: first render showed the caption rows overlapping (no row gap), the signature block squeezed to one word per line (the indent was subtracted twice), and the prayer's "WHEREFORE" numbered 17 (the detector looked for PRAYER at the start of the heading; the heading starts with "III."). Fixed: `row-gutter`, signature width, `contains("PRAYER")`. Title nbsp for § 523.
- Iteration 2: party designations right-aligned to match the exemplar; the labels abutted the ")" column, so the party column got a 0.2 in right pad.
- Iteration 3: fictional joint-debtor sample added and rendered; consent allegation added to it (FRBP 7008(a)).
