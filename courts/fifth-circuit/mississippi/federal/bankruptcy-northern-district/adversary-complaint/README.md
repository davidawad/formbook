# msnb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Northern District of Mississippi (`msnb`).
Folder: `courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | **no**: `BLOCKED: no exemplar`. See `usage/SOURCE.md` for the searches tried. |
| sample md | `usage/INPUT-synthetic-adversary-complaint.md`. Synthetic content; not a transcription. |
| render | ok: `usage/OUTPUT-msnb-adversary-complaint-synthetic.typst.pdf`, 3 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-community-bank-loancare.pdf` and `.txt` (`sh tools/overlay.sh`, 3 pages). The filed PDF was re-downloaded into `usage/` from the URL in `usage/SOURCE.md` (the saved copy was missing from this snapshot). |
| pages reviewed | 3 of 3 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14 from Cornell LII (the text of each rule as currently posted).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the caption must substantially conform to Official Form 416A. Amended April 2, 2024, effective December 1, 2024. https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption()`, the court title and the ADV. PROC. NO. line |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." Amended April 2, 2024, effective December 1, 2024. https://www.law.cornell.edu/rules/frbp/rule_9004 | Black text on white letter paper; no decorative elements. |
| Fed. R. Bankr. P. 9004(b) | Caption contents: court name, case title, case number and adversary-proceeding number, and a brief description of the document. | `court-title()`, `caption()`, and the title line. |
| Fed. R. Civ. P. 10(a), (b) | Caption; claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | `allegation()` numbers each paragraph; `unnumbered()` for the WHEREFORE lead-in. |

Not verified (not fetched on 2026-10-14; the template does not depend on them yet):
- **Official Form 416A** (the caption form the rule names). Its exact layout was not read; the caption here follows the common msnb-style layout (debtor and case number, then the adversary parties and the adversary number).
- **N.D. Miss. local bankruptcy rules.** The local rules page (msnb.uscourts.gov/local-rules) lists only "Summary of Local Rules" with no rule text in the reader's copy, and the courtrules.net copy of L.U.Bankr.R. 9013-1 returned HTTP 403. No local rule on font, margins, page limits, line spacing, cover contents or certificates was read.

Because the local rules were unreadable, the format below is a **standard-letter default**, not a court requirement:
- US Letter, 1-inch margins, 12-point EB Garamond (no face named by any rule read; see Typeface below), double spaced, page number centered in the footer.

## Typeface

| Item | Value |
|---|---|
| Face required | none found. Fed. R. Bankr. P. 7010 incorporates Fed. R. Civ. P. 10 (caption, numbered paragraphs), which names no face. The msnb local rule on form (Rule 9004-1) could not be read: courtrules.net returned HTTP 403, and the msnb standing order (eff. 3-1-26) is a scanned image with no text layer. |
| Vendored substitute | `EB Garamond` (no court-named face to substitute; `docs/FONTS.md` "No face named") |
| Fit | visual only, and the template's default |
| Filer convention (not a rule) | the filed exemplar sets Times New Roman (embedded `TimesNewRomanPSMT`); the substitute would be `Liberation Serif` (metric-compatible). Not switched: a filer's choice does not make a rule. |
| Open | If Rule 9004-1 or a local rule names Times New Roman, switch the font list to `Liberation Serif` and re-render. |
- The caption, paragraph numbering and prayer layout are the template's own choices.

A local-rule text, or a filed complaint from this court, would settle each of these.

## Layout

- Counsel block, single-spaced, at the top left.
- Court title centered and bold (UNITED STATES BANKRUPTCY COURT / NORTHERN DISTRICT OF MISSISSIPPI).
- Two-row caption: IN RE (debtor, chapter) with CASE NO. on the right; then the plaintiff and defendant with ADV. PROC. NO. on the right.
- Title centered bold capitals.
- Body: markdown headings (level 1, centered bold caps; level 2 centered bold), numbered paragraphs, lettered prayer items, and a signature block right-aligned.
- Not generated: summons, civil cover sheet, Rule 7007.1 disclosure, certificate of service (separate filings if the court requires them).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks:
  - `#` heading (level 1 centered caps; level 2 centered bold);
  - a list (`1.` items, lettered by the template as (a), (b), ...);
  - a paragraph (numbered by the template);
  - a paragraph beginning with `>` (unnumbered, e.g. the WHEREFORE lead-in).
- Frontmatter fields: `title`, `case_number`, `adv_number`, `debtor` (`names` list, `role`, `chapter`), `plaintiffs` (list), `defendants` (list), `counsel` (lines), `signature` (`firm`, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst. Inline italics via `*...*`.

## Known gaps and open choices

1. **No exemplar.** Tier 2 cannot be judged against filed complaints. Overlay not run.
2. **Local rules unread.** Font, margins, line spacing and the caption form are defaults (see above). This is the biggest tier-1 risk.
3. **Synthetic sample only.** The sample is 3 pages of invented content; the depth target (8 to 14 pages) was not met because there is no exemplar to transcribe.
4. **Font.** EB Garamond stays because no rule read names a face (see Typeface). The filed exemplar uses Times New Roman; that would only change if Rule 9004-1 names it.
5. **Caption.** The party column is closed by a rule (right and bottom). The adversary number is shown on the right of the party block, not in a separate row.

## Review of the rendered pages

- Page 1: counsel block, court title, two-row caption, title, paragraphs 1 to 5 (preliminary statement, jurisdiction and venue, parties). No overlap. Pass.
- Page 2: paragraphs 6 to 17, FACTUAL BACKGROUND, COUNT I heading, paragraphs 14 to 17 on the page. No overlap, no heading at foot. Pass.
- Page 3: paragraphs 18 to 24, COUNT II, REQUEST FOR RELIEF with the WHEREFORE lead-in unnumbered, lettered items (a) to (d) with hanging indent, DEMAND FOR JURY TRIAL, signature block right-aligned, page number. Pass.

## Engines

Docx engine (`docx/`): `reference.docx` (built by `docx/make-reference.sh`), `msnb-adversary-complaint.lua` (counsel block, court title, caption rows, numbered allegations, lettered and prayer items, signature block), and `render.sh` (the pandoc call; `tools/render-docx.sh` uses it). Renders: `usage/OUTPUT-msnb-adversary-complaint-communitybankloancare.docx` and `.docx.pdf` (3 pages, LibreOffice 26.8).

| Item | Typst (primary) | Docx | Note |
|---|---|---|---|
| Font, size | EB Garamond 12 pt | EB Garamond 12 pt (embedded, the only font in the PDF) | |
| Page, margins | US Letter, 1 in | US Letter, 1 in | |
| Body spacing | double, 24 pt baseline | exact 24 pt | |
| Caption | IN RE and case number on one row, rule, PLAINTIFF, VS. and ADVERSARY NO., DEFENDANTS | same, as borderless two-column table rows with a rule under the debtor row | line breaks in the party column differ slightly |
| Title | centered bold caps | same | |
| Signature | DATED line, firm, `By: /s/ name` right column, title, counsel block flush left | same | |
| Page number | centered, 10 pt | centered, 10 pt (`PAGE` field) | |
| Pages (sample) | 3 | 3 | |

Differences, by design:
- **Allegation numbering.** The typst template numbers the markdown's plain paragraphs from its own counter, which starts again at 1 after the `1. The parties are:` item, so the sample's typst output shows two paragraphs numbered 1. The docx numbers every allegation consecutively (Fed. R. Civ. P. 10(b)). This is a typst defect; `typst/` is not changed here.
- The WHEREFORE lead-in (the markdown `>` line) is unnumbered, as in typst; the prayer list keeps its own numbers.

BLOCKED / not verified for docx:
- Gates 0 to 3 cannot run: no `rules.md` or `checks.yaml` in this court yet, and `yq` is not on the box.
- Opened in LibreOffice only (the PDF conversion succeeded); not opened in Microsoft Word.
- The README's older note about `usage/INPUT-synthetic-adversary-complaint.md` is stale: that file is not in the folder, so only `INPUT-msnb-adversary-complaint-communitybankloancare.md` renders. No second sample exists for Gate 3.
