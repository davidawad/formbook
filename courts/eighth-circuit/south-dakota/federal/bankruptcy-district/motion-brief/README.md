# sdb: motion with memorandum

Doc type: **motion with memorandum** (FRBP 9013; motions in adversary proceedings under FRBP 7007 and Bankr. D.S.D. R. 7007-1) in the United States Bankruptcy Court for the District of South Dakota (`sdb`).
Folder: `courts/eighth-circuit/south-dakota/federal/bankruptcy-district/motion-brief/`.

BLOCKED: no exemplar. No text-layer filed motion with a memorandum from this court was found after the searches logged in `exemplars/SOURCE.md`. The template is built from the rules below and tested on a fictional sample. Nothing here is judged against a filing (tier 2 is not judged).

| Item | Status |
|---|---|
| exemplar | no (see `exemplars/SOURCE.md`: searches, and why each candidate was not usable) |
| sample md | `samples/INPUT-fictional-stay-relief.md`: FICTIONAL main-case motion for relief from stay with a memorandum. Not a transcription; invented names and numbers. |
| render | ok: `samples/OUTPUT-fictional-stay-relief.pdf` (2 pages), `tools/render.sh`, vendored EB Garamond only (pdffonts: EBGaramond-Regular and -Bold, embedded), zero typst warnings. |
| overlay | **fail**: `tools/overlay.sh` exits 1, "no exemplar pdf in …/exemplars". No overlay PDF exists, because there is no filed document to overlay. |
| pages reviewed | 2 of 2 of `OUTPUT-fictional-stay-relief.pdf`, each rasterized at 60 dpi and viewed after the last change. |

## Governing rules

Sources, fetched 2026-10-14 (the same local rules text as the adversary-complaint folder):

| Source | URL |
|---|---|
| Bankr. D.S.D. Local Bankruptcy Rules and Appendices, as amended June 14, 2024 (revised 1/24/25), with bookmarks | https://www.sdb.uscourts.gov/sites/sdb/files/local_rules/Local%20Rules%20and%20Appendices%20as%20Amended%20June%2014%2C%202024%20%28revised%201%2024%2025%29%20with%20bookmarks%20and%20links_1.pdf |
| Fed. R. Bankr. P. 9013 | https://www.law.cornell.edu/rules/frbp/rule_9013 |
| Fed. R. Bankr. P. 9004 (caption, legibility) | https://www.law.cornell.edu/rules/frbp/rule_9004 |

Finding: **the local rules have no Rule 9013.** The index of the June 2024 rules has 9014-1 to 9014-4 (contested matters) and 9004-1, 9004-2 (format, caption), but nothing titled 9013. The brief's "per this court's local bankruptcy rules" therefore points to the rules below, not to a local Rule 9013.

| Rule | Kind | Requirement | Where in the template / status |
|---|---|---|---|
| Bankr. D.S.D. R. 9004-1(a)(1) | **M** | White 8½ × 11 paper, margins not less than one inch, one simple font, typewritten, no erasures. | `page-w`, `page-h`, `margin = 1in`, `font-family`. |
| Bankr. D.S.D. R. 9004-1(a)(3) and 9004-2 | **M** | Caption per Rule 9004-2: debtor's full name, full EIN (if any), last four of SSN or TIN, names used (aka / fka). | `caption()`. The template **stops the build** if a debtor has no EIN, SSN last four or TIN last four. |
| Bankr. D.S.D. R. 7010-2 | **M** | In an adversary proceeding, the caption carries the full bankruptcy caption and the complete legal names of all parties, conforming to Official Form 416D. | `caption()` prints plaintiffs and defendants when `adversary_no` is given. The template **stops the build** if an adversary caption lacks them. |
| Bankr. D.S.D. R. 9004-1(a)(4) | **M** | Portrait orientation. | `page-w` < `page-h`. |
| Bankr. D.S.D. R. 9004-1(a)(5) | **M** | Each document signed and dated, the filing attorney per Part V of the ECF Procedures. | `signature()`. |
| FRBP 9013(b) | **M** | A motion must state its grounds with particularity and set forth the relief requested. | The template **stops the build** unless the frontmatter gives `movant`, `relief` and `basis`, and prints them as the motion's opening sentence. The grounds themselves are author text (not checked). |
| Bankr. D.S.D. R. 7007-1 | **M** | A motion in an adversary proceeding is filed separately from any pleading. | Author responsibility: the template produces one document per motion. Not checked. |
| Bankr. D.S.D. R. 9004-1(f) | **M** (no requirement) | A party need not submit a brief in support of a motion unless a local rule or order directs one. | The template produces a memorandum-style body because the brief is the motion's text here, but no brief is required. |
| Bankr. D.S.D. R. 7056-1(b) | **M** (only for summary judgment) | A motion for summary judgment (and an objection to one) is accompanied by a brief that sets out the position and the specific legal authority, docketed as an attachment to the motion. | Author responsibility. The template does not know the motion type. If the motion is summary judgment, file the brief as an attachment (not checked). |
| Bankr. D.S.D. R. 9014-4(a) | **M** (only for summary judgment in a contested matter) | A motion for summary judgment in a contested matter is filed at least seven days before any scheduled hearing, unless ordered otherwise. | Author responsibility. Not checked. |
| FRBP 9014 / contested matters | context | A motion in the main case is a contested matter; the response deadlines are in Bankr. D.S.D. R. 9014-1(b). | Not in the template. |
| Convention (tier 2) | C | Caption as in the adversary-complaint folder: `In re:` block on the left, `)` marks, case numbers on the right, designations right-aligned, court name centered and bold above. | `caption()`. Shares the layout of `../adversary-complaint/` (not verified against a motion; no exemplar). |
| Convention (tier 2) | C | A certificate of service after the signature. | Printed when `certificate:` is in the frontmatter. Conventional, not required by the local rules; the certificate's wording is the author's. |

Tier 1 is every `M` row above. The template enforces the four "stops the build" items; the rest are author responsibilities and are listed under Known gaps.

## Template

| File | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/sdb-motion-brief.typ` | The template: `sdb-motion-brief(meta, md)`, `caption()`, `signature()`, `certificate()`. Named parameters at the top; no case-specific text, no coordinates, no forced line breaks. |

Markdown contract (frontmatter; the body is blank-line-separated chunks):

- `debtors`: list of `{name, ssn_last4 | ein | tin_last4, aka, fka}`.
- `bankr_no`, `chapter`; `adversary_no` (optional: if present, `plaintiffs` and `defendants` are required and printed).
- `title`: the title of the motion (printed bold, centered, below the caption).
- `movant`, `relief`, `basis` (required): the opening sentence is `<movant> moves the Court for <relief> under <basis>.`
- `signature`: `{date, signer, firm (lines), role}`.
- `certificate` (optional): `{text, signer, firm}`.
- Body: `# Heading` (centered bold); `## Heading` (bold, left); other chunks are unnumbered body paragraphs (first-line indent 0.5 inch); a chunk starting `1. ` is a list.
- Not supported: tables, footnotes, raw typst.

## Layout

- Letter size; margins 1 inch on every side; body 12 pt EB Garamond, single spaced (0.5 em leading), 12 pt between paragraphs, first-line indent 0.5 inch.
- Caption: three-column grid, as in the adversary-complaint folder.
- Footer: page number, 10 pt, centered.

## Gate 2 review (current PDF)

sha256 of `samples/OUTPUT-fictional-stay-relief.pdf`: `066321b25eb529fe7ca787867e8b6dd1dad7a2298cb6daad80e8424b23b863aa`

There is no exemplar, so no row compares a page with a filed page. The rows check the page against the rules above.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | none (rules: R. 9004-1(a)(1), 9004-2, 9013(b)) | Caption: court name, `In re:`, debtor name, SSN last four, `aka` line, `Debtor.` right-aligned, `Bankr. No.`, `Chapter 13`; no adversary block (main case). Title centered bold, wraps to "SUPPORT" on line 2 (a one-word line). Opening sentence states movant, relief and basis. Headings: MEMORANDUM centered; I. Facts and II. Argument left bold; a numbered list in the argument; III. Conclusion. Margins and type size as set. | PASS for the rule items. ACCEPTED: the one-word second title line is a typesetting result of the title's length, not a defect the rules set; a shorter title or a longer line length is the author's choice. |
| 2 | none | `DATED January 1, 2001.`, signature block at the middle of the page, `CERTIFICATE OF SERVICE` centered bold, the certificate text and its signature. The page holds only the signature and the certificate; no body text is split. | PASS |

## Known gaps and open choices

1. **No exemplar, so tier 2 is not judged.** Layout conventions for motions (title placement, memorandum headings, certificate placement, prayer style, the lead-in sentence) are the template's own choices, not checked against a filing. This is the main gap. The BLOCKED note above is the record.
2. **No local Rule 9013 exists.** The brief says "per this court's local bankruptcy rules" for FRBP 9013. The court's June 2024 rules have no Rule 9013. The template follows the rules that do exist (9004-1, 9004-2, 7010-2, 7007-1, 9014-4, 7056-1).
3. **Brief not required.** Bankr. D.S.D. R. 9004-1(f) says a party need not submit a brief with a motion unless a rule or order directs one. Summary judgment (R. 7056-1(b)) is the directed case. The template does not know the motion type; the author decides whether to attach a separate brief.
4. **Font size.** No local rule sets a size. 12 pt EB Garamond (the only font vendored) is a choice, not a rule.
5. **Caption for an adversary motion** shares its code with `../adversary-complaint/`; the adversary branch is exercised by the code path but not by a sample (the only sample is a main-case motion). A second sample with `adversary_no` would be the test.
6. **Certificate of service.** Its wording (CM/ECF notice, mail to the debtor and the debtor's attorney) is conventional text in the sample, not a rule. Local rules and FRBP 9013 do not prescribe it.
7. **Fictional sample.** The sample's legal content (the stay-relief standard, the 4001(a)(3) waiver) is illustrative and not a legal opinion; a real motion has its own authorities.
8. **Check tooling not run.** As in the adversary folder, `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this folder is a doc-type folder. The overlay failed (no exemplar).

## Loop log

- Iteration 1: built the template from the rules; rendered the fictional sample. The caption, the opening sentence and both pages rendered without warnings.
