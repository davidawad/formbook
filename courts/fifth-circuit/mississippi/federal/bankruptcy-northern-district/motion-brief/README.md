# msnb: motion-brief

Doc type: **motion with memorandum brief** in the United States Bankruptcy Court for the Northern District of Mississippi (`msnb`), filed under Fed. R. Bankr. P. 9013 and the court's local motion rule.
Folder: `courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | **no**: `BLOCKED: no exemplar`. See `exemplars/SOURCE.md` for the searches tried. |
| sample md | `samples/INPUT-synthetic-motion-brief.md`. Synthetic content (a relief-from-stay motion); not a transcription. |
| render | ok: `samples/OUTPUT-synthetic-motion-brief.pdf`, 3 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | **fail (not run)**: `tools/overlay.sh` needs a filed PDF in `exemplars/`, and there is none |
| pages reviewed | 3 of 3 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14 from Cornell LII (the text of each rule as currently posted).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 | "A request for an order must be made by written motion unless:" (a); "A motion must state its grounds with particularity and set forth the relief or order requested." (b). Amended April 2, 2024, effective December 1, 2024. https://www.law.cornell.edu/rules/frbp/rule_9013 | The motion section (numbered paragraphs), the grounds list (lettered), and the relief requested (lettered). |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." Amended April 2, 2024, effective December 1, 2024. https://www.law.cornell.edu/rules/frbp/rule_9004 | Black text on white letter paper; no decorative elements. |
| Fed. R. Bankr. P. 9004(b) | Caption contents: court name, case title, case number, and a brief description of the document. | `court-title()`, `caption()`, and the title line. |

Not verified (not fetched on 2026-10-14; the template does not depend on them yet):
- **The court's local motion rule** (L.U.Bankr.R. 9013-1 per the courtrules.net index). The courtrules.net copy returned HTTP 403, and the msnb local-rules page shows no rule text. Nothing on font, margins, line spacing, page limits, memorandum form or certificates was read.
- **Local rule on the memorandum.** Some districts require a separate memorandum, a page limit or a notice of hearing; this court's requirement was not read. The template allows a memorandum section inside the same paper, and a separate memorandum would be a second template.
- **Fed. R. Bankr. P. 4001(a)(3)**, cited in the sample's relief (the fourteen-day stay). Cited from the sample only; not fetched.

Because the local rules were unreadable, the format below is a **standard-letter default**, not a court requirement:
- US Letter, 1-inch margins, 12-point EB Garamond (the only vendored font), double spaced, page number centered in the footer.
- The caption, paragraph layout and headings are the template's own choices.

A local-rule text, or a filed motion from this court, would settle each of these.

## Layout

- Counsel block, single-spaced, at the top left.
- Court title centered and bold (UNITED STATES BANKRUPTCY COURT / NORTHERN DISTRICT OF MISSISSIPPI).
- One-row caption: IN RE (debtor, chapter) with CASE NO. on the right. No adversary row (this is a contested matter in the main case; the adversary complaint is a separate template).
- Title centered bold capitals.
- Body: markdown headings (level 1 centered caps; level 2 bold; level 3 bold italic), numbered motion paragraphs, lettered grounds and relief items, prose memorandum paragraphs (not numbered), and a signature block right-aligned.
- Certificate of service: written in the body (heading plus paragraph), not generated.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks:
  - `#` heading (level 1 centered caps; level 2 bold; level 3 bold italic);
  - a `1.` list: numbered motion paragraphs, one per line;
  - a `- ` list: lettered items, (a), (b), ... (grounds, relief);
  - a plain paragraph: memorandum prose with a first-line indent (not numbered).
- Frontmatter fields: `title`, `case_number`, `debtor` (`names` list, `role`, `chapter`), `counsel` (lines), `signature` (`firm`, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst. Inline italics via `*...*`.

## Known gaps and open choices

1. **No exemplar.** Tier 2 cannot be judged against filed motions. Overlay not run.
2. **Local rules unread.** Font, margins, spacing, page limits and the memorandum form are defaults (see above). This is the biggest tier-1 risk.
3. **Synthetic sample only.** The sample is 3 pages of invented content; the depth target (8 to 14 pages) was not met because there is no exemplar to transcribe.
4. **Headings and caption.** The caption omits the movant/respondent row; a contested matter may need one, and that is not built.
5. **Certificate of service** is free text in the body; the date and the method of service are the author's words, not generated.

## Review of the rendered pages

- Page 1: counsel block, court title, one-row caption, title (two lines), "MOTION" heading, motion paragraphs 1 to 4 (numbered), grounds (a) to (b). Pass.
- Page 2: grounds (c), MEMORANDUM BRIEF, sections I to III (level-2 headings at the left, bold), RELIEF REQUESTED (a) to (c), start of CERTIFICATE OF SERVICE. The certificate heading is not stranded at the foot of the page. Pass.
- Page 3: the certificate continues, the date line, signature block right-aligned, page number. Pass.
