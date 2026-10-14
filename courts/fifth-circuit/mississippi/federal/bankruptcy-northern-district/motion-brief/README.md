# msnb: motion-brief

Doc type: **motion with memorandum brief** in the United States Bankruptcy Court for the Northern District of Mississippi (`msnb`), filed under Fed. R. Bankr. P. 9013 and the court's local motion rule.
Folder: `courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | **yes**: `exemplars/FILED-EXAMPLE-clanton-26-11416-motion-brief.pdf` (Fairport Asset Management REO 2, LLC, Doc. 39, 14 pages, filed 2026-07-14). Source and URL in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-clanton.md`: transcription of the filed motion (caption, headings, numbered paragraphs, lettered grounds and relief, signature, certificate of service). The synthetic sample `samples/INPUT-synthetic-motion-brief.md` is kept as a second input. |
| render | ok: `samples/OUTPUT-clanton.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`). |
| overlay | ok: `samples/OVERLAY-clanton.pdf` and `samples/OVERLAY-clanton.txt` (`sh tools/overlay.sh`, 13 pages). |
| pages reviewed | 13 of 13 (OUTPUT rendered at 60 dpi and viewed page by page; overlay pages 1 to 4 viewed). |

## Governing rules

Primary sources, fetched 2026-10-14 from Cornell LII (the text of each rule as currently posted).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 | "A request for an order must be made by written motion unless:" (a); "A motion must state its grounds with particularity and set forth the relief or order requested." (b). Amended April 2, 2024, effective December 1, 2024. https://www.law.cornell.edu/rules/frbp/rule_9013 | The motion section (numbered paragraphs), the grounds list (lettered), and the relief requested (lettered). |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." Amended April 2, 2024, effective December 1, 2024. https://www.law.cornell.edu/rules/frbp/rule_9004 | Black text on white letter paper; no decorative elements. |
| Fed. R. Bankr. P. 9004(b) | Caption contents: court name, case title, case number, and a brief description of the document. | `court-title()`, `caption()`, and the title line. |

Not verified (not fetched on 2026-10-14; the template does not depend on them yet):
- **The court's local motion rule** (L.U.Bankr.R. 9013-1 per the courtrules.net index). The courtrules.net copy returned HTTP 403, and the msnb local-rules page shows no rule text. Nothing on font, margins, line spacing, page limits, memorandum form or certificates was read.
- **Local rule on the memorandum.** Some districts require a separate memorandum, a page limit or a notice of hearing; this court's requirement was not read. The filed exemplar does not contain a memorandum section (its text says a memorandum of law is filed separately), so the template's memorandum section is not shown by the exemplar.
- **Fed. R. Bankr. P. 4001(a)(3)**, cited in the sample's relief (the fourteen-day stay). Cited from the exemplar text only; not fetched.

Because the local rules were unreadable, the format is a **standard-letter default**, not a court requirement:
- US Letter, 1-inch margins, 12-point EB Garamond (the only vendored font), double spaced, page number centered in the footer.
- The caption, paragraph layout and headings are the template's own choices.

The filed exemplar is 14 pages, double spaced, with an ECF header line at the top of each page. The render is 13 pages and has no ECF header, which is why the overlay does not line up on the page edges.

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
- Frontmatter fields: `title`, `case_number`, `debtor` (`names` list, `role`, `chapter`), `counsel` (lines), `signature` (`firm`, `signer`, `title`, `lines`).
- Footnotes are supported (`[^n]`) for the sample's footnotes. Not supported: tables, raw typst. Inline italics via `*...*`.

## Overlay

`samples/OVERLAY-clanton.pdf`: red is our render, blue is the filed exemplar, black where both agree. The pages are paired by text (`samples/OVERLAY-clanton.txt`): ours p.1 to p.13 map to filed p.1, 2, 4, 5, 6, 6, 7, 8, 9, 11, 12, 13, 14. Word overlap per page is 37% to 80%. The overlay is a diagnostic: the text layers match, but the lines do not register, because the filed paper has an ECF header and a different line spacing and margin set.

## Known gaps and open choices

1. **Local rules unread.** Font, margins, spacing, page limits and the memorandum form are defaults (see above). This is the biggest tier-1 risk.
2. **ECF header missing.** The filed paper carries the ECF header on every page; the template does not generate it. This is a visible tier-2 difference.
3. **Pagination.** The render is 13 pages; the filed paper is 14. The transcription pages do not align one-to-one (see the map in the overlay .txt).
4. **Caption.** The caption omits the movant/respondent row; a contested matter may need one, and that is not built.
5. **Certificate of service** is free text in the body; the date and the method of service are the author's words, not generated.
6. **Memorandum section** is not shown by the exemplar; the synthetic sample is the only example of it.

## Review of the rendered pages

Every page of `samples/OUTPUT-clanton.pdf` was rendered at 60 dpi and viewed.

- Pages 1 to 3: counsel block, court title, caption, title, introduction, background, paragraphs 1 to 6, the Calhoun and Webster property descriptions begin. Pass.
- Pages 4 to 6: legal descriptions of the TRACT 1 to 3 parcels with LESS AND EXCEPT paragraphs and the tracts list. Pass.
- Pages 7 to 9: paragraphs 7 to 19 (deeds of trust, default, lawsuit, assignments, foreclosure), RELIEF REQUESTED heading at the foot of page 9 with paragraph 20 below it. Pass.
- Pages 10 to 12: paragraphs 21 to 28 (cause under § 362(d)(1), equity cushion, adequate protection, relief requested), date line, CERTIFICATE OF SERVICE starting on page 12. Pass.
- Page 13: the certificate's date line, signature block right-aligned, counsel block. Pass.
