# mied: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Michigan (`mied`).
Folder: `courts/sixth-circuit/michigan/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-music-laa-5-26-cv-13851-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-music-laa-complaint.md` (the whole 12-page complaint, transcribed) |
| render | ok: `samples/OUTPUT-music-laa-complaint.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-music-laa-complaint.pdf` and `OVERLAY-music-laa-complaint.txt` |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Mich. LR 5.1(a)(2) | Papers double-spaced (quotations excepted), margins at least 1 inch on all sides, pages numbered. | `margin = 1in`; `double-leading` (2.3em pitch); `numbering: "1"` footer. |
| E.D. Mich. LR 5.1(a)(3) | Type no smaller than 14 point for proportional fonts (or 10.5 characters per inch for monospace), footnotes included. | `type-size = 14pt`. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, case number, and the party names. | `cover()`, `caption()`, `court-title()`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | `numbered-body()`: each non-heading, non-list chunk is numbered. |
| Fed. R. Civ. P. 38(b) | Jury demand. | Author content (the sample's `JURY DEMAND` heading); no template check. |

Rule text: the E.D. Mich. local rules PDF (`https://www.mied.uscourts.gov/PDFs/LocalRules.pdf`) returned an HTML error page from this box, and courtrules.net (`https://www.courtrules.net/courts/federal/eastern-district-michigan/local-rules/lr-5-1`) is behind a bot challenge. The LR 5.1 text above is from a search excerpt of courtrules.net and of two judges' brief-certification forms (search date 2026-10-14), not from the official PDF. **Verify LR 5.1(a)(2)-(3) against the official rules before relying on it.** The Fed. R. Civ. P. 10 text was not fetched in this box; the rule numbers above are the standard ones, and the sources should be checked (`https://www.law.cornell.edu/rules/frcp/rule_10`).

Not produced by this template (separate filings): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement, the summons.

## Layout

- No pleading line numbers: E.D. Mich. does not require them (the exemplar has none).
- Caption: court title centered in bold caps (three lines, the division last); party block at left closed by a right and bottom rule (a tier-2 choice, see Known gaps); case number and judge at right; title of the paper centered in bold.
- Body: double-spaced, first-line indent 0.5 in, numbered paragraphs (1., 2., ...) with the number at the indent; headings centered bold caps (level 1), centered bold (level 2), centered italic (level 3).
- Prayer items (markdown list) are lettered A., B., ... with hanging indent.
- Signature block: "Respectfully submitted," then `/s/` name, bar number, and contact lines, at the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division`, `caption.parties` (list of `{names, designation}`; "v." between parties), `case_number`, `judge` (optional), `brief_title`, `lead_in` (optional, unnumbered), `signature` (`signer`, `lines`, and optional `firm`/`date` not used by this template).
- Body: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3); a list (`1.` items, lettered by the template); a paragraph (numbered by the template, do not type numbers in the text).
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The CourtListener search (`court=mied`, `type=r`, complaints filed 2026-09 to 2026-10) also found Fleet Connect Solutions LLC v. Road Ready, LLC, 2:26-cv-13496 (33 pp., Liberation Sans, a patent complaint) and Annapolis Pointe Phase I LDHA LLC v. City of Inkster, 2:26-cv-13484 (23 pp., Arial, Pentiuk, Couvreur & Kobiljak). Those were checked for text but not saved (one exemplar per doc type). Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** The only font vendored in `fonts/` is EB Garamond. The exemplar is Times New Roman. At 14 point, EB Garamond has a smaller x-height, so the text looks smaller than the exemplar. The 14-point minimum is met. A vendored Times-metric font would remove the difference; that is a question for David.
3. **Double spacing.** Defined against the font's own single line (1.15em single, 2.3em double, ~32 pt at 14 pt), which matches Times New Roman's line box. The rule text is "double-spaced", not a pitch, so this is a reading, not a measured number. The exemplar's line pitch is similar (about 32 pt).
4. **Caption.** The party column is closed by a right and bottom rule instead of the ")" column used in some E.D. Mich. filings. Recorded as ACCEPTED.
5. **Case-name italics.** The sample's case names are not italic (the exemplar has no case names). The template italicizes `*...*` markup, so future samples can carry italics.
6. **Paragraph numbers.** The sample's paragraph numbers are generated by the template, so they match the exemplar's sequence (1 to 40) by construction.
7. **Overlay pairing.** The overlay pairs each render page with the exemplar page sharing the most words. Pages 1 to 8 pair at 64 to 83%, pages 9 to 12 at 79 to 94%. The overlay is a diagnostic, not a score.
8. **Sample file names.** The brief asked for `samples/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/overlay.sh` reads `samples/OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`, and CLAUDE.md requires the INPUT-/OUTPUT-/OVERLAY- names, so this folder follows the repo convention. Flagged for the PM.
9. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` are court-level gates (they expect `court.json` and `rules.md` in the court directory), and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.
10. **Signature block.** Lists the attorney's bar number and contact lines as the exemplar does, without a date line (the exemplar has none).

## Review of the rendered pages (current PDF, 12 pages)

- Page 1: court title in bold caps (three lines), caption with party block and case number at right, title centered, lead-in paragraph, heading NATURE OF THE ACTION, paragraph 1. Pass.
- Pages 2 to 4: paragraphs 2 to 12 at double spacing; THE PARTIES on page 2; JURISDICTION AND VENUE on page 3; PLAINTIFFS' RIGHTS IN THE REGISTERED WORKS (two-line heading) at the top of page 4. No heading at the foot of a page. Pass.
- Pages 5 to 8: paragraphs 13 to 28; THE SHEIN SPONSORED USES on page 6; FIRST CLAIM FOR RELIEF with its two sub-headings on page 8, kept with paragraph 28. Pass.
- Pages 9 to 11: paragraphs 29 to 38; SECOND CLAIM FOR RELIEF and PRAYER FOR RELIEF on page 10; prayer items A to D on pages 10 and 11 (the list breaks across pages, as the exemplar's does). Pass.
- Page 12: prayer items E to G, JURY DEMAND with paragraph 40, signature block. Pass.

Defects found and fixed during this review (the template at the time of the final render has none of them):
- Paragraphs that were built from separate content pieces overlapped or ran together in typst 0.15; the body is now one markdown string (`numbered-body()`).
- `context` in a numbered paragraph misplaced the first line; the number is now part of the markdown text.
- Paragraph spacing: between paragraphs typst applies `spacing`, not `leading`; `spacing` is now the double pitch.

[Formbook index](../../../../../README.md)
