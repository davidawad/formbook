# msnb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Northern District of Mississippi (`msnb`).
Folder: `courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | **no**: `BLOCKED: no exemplar`. See `exemplars/SOURCE.md` for the searches tried. |
| sample md | `samples/INPUT-synthetic-adversary-complaint.md`. Synthetic content; not a transcription. |
| render | ok: `samples/OUTPUT-synthetic-adversary-complaint.pdf`, 3 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | **fail (not run)**: `tools/overlay.sh` needs a filed PDF in `exemplars/`, and there is none |
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
- US Letter, 1-inch margins, 12-point EB Garamond (the only vendored font), double spaced, page number centered in the footer.
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
4. **Font.** EB Garamond is the only vendored font. Local rules may name Times New Roman; see the ca9 folder's README for the same issue.
5. **Caption.** The party column is closed by a rule (right and bottom). The adversary number is shown on the right of the party block, not in a separate row.

## Review of the rendered pages

- Page 1: counsel block, court title, two-row caption, title, paragraphs 1 to 5 (preliminary statement, jurisdiction and venue, parties). No overlap. Pass.
- Page 2: paragraphs 6 to 17, FACTUAL BACKGROUND, COUNT I heading, paragraphs 14 to 17 on the page. No overlap, no heading at foot. Pass.
- Page 3: paragraphs 18 to 24, COUNT II, REQUEST FOR RELIEF with the WHEREFORE lead-in unnumbered, lettered items (a) to (d) with hanging indent, DEMAND FOR JURY TRIAL, signature block right-aligned, page number. Pass.
