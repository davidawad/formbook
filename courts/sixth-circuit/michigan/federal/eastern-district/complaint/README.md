# mied: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Michigan (`mied`).
Folder: `courts/sixth-circuit/michigan/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole 12-page complaint, transcribed) |
| typeface | required: none (LR 5.1(a)(3) sets 14 pt for proportional type and names no face); used: **Times New Roman** 14 pt (vendored, `docs/FONTS.md`), as the filed exemplar, in both engines |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx.pdf`, 12 pages each, as filed (re-rendered 2026-10-22) |
| embedded fonts | `pdffonts`: TimesNewRomanPSMT, -BoldMT, -ItalicMT only (all embedded), both engines |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` (not committed) |
| pages reviewed | 12 of 12, both engines (every page rendered at 60 dpi and viewed on 2026-10-22) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Mich. LR 5.1(a)(2) | Papers double-spaced (quotations excepted), margins at least 1 inch on all sides, pages numbered. | `margin = 1in`; `pitch-body` 32.2 pt (twice the 16.1 pt single line); the page number centred in the footer. |
| E.D. Mich. LR 5.1(a)(3) | Type no smaller than 14 point for proportional fonts (or 10.5 characters per inch for monospace), footnotes included. | `type-size = 14pt`; docx `size="28"`. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, case number, and the party names. | `cover()`, `caption()`, `court-title()`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | `allegations()`: each chunk that is neither a heading nor a list is numbered. |
| Fed. R. Civ. P. 38(b) | Jury demand. | Author content (the sample's `JURY DEMAND` heading); no template check. |

Rule text: the E.D. Mich. local rules PDF (`https://www.mied.uscourts.gov/PDFs/LocalRules.pdf`) returned an HTML error page from this box, and courtrules.net (`https://www.courtrules.net/courts/federal/eastern-district-michigan/local-rules/lr-5-1`) is behind a bot challenge. The LR 5.1 text above is from a search excerpt of courtrules.net and of two judges' brief-certification forms (search date 2026-10-14), not from the official PDF. **Verify LR 5.1(a)(2)-(3) against the official rules before relying on it.** The Fed. R. Civ. P. 10 text was not fetched in this box; the rule numbers above are the standard ones, and the sources should be checked (`https://www.law.cornell.edu/rules/frcp/rule_10`).

Not produced by this template (separate filings): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement, the summons.

## Layout

Both engines run on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line is a box of its pitch (body 32.2 pt, single 16.1 pt, the 12 pt page number 13.8 pt), first-fit ragged-right breaking, no kerning, ligatures or hyphenation; the docx breaks every line and page where the typst render does (`eval.yaml`: `params.cross_engine: gate`).

- No pleading line numbers: E.D. Mich. does not require them (the exemplar has none).
- Caption: court title centred in bold capitals (three single lines, the division last); one double line below it, the party column (3.3 in) single-spaced and closed by a 0.75 pt rule at its right and foot, each party's names, a blank line, the designation set in 1 in, "v." between the parties with a blank line above and below; the case number and the judge at the right. One double line below, the title of the paper centred in bold (single spaced), then a single line.
- Body: double-spaced, first-line indent 0.5 in; numbered paragraphs with the number at the indent in a 0.5 in box, the text 1 in from the margin (docx: a tab at 1 in); headings centred at the type size on the body pitch with no space of their own, kept with the next line: level 1 bold capitals, level 2 bold, level 3 italic.
- Prayer items (markdown list) are lettered A., B., ...: the letter 0.5 in in, the text hanging at 1 in.
- Signature block: one double line below the last paragraph, from 3.2 in: "Respectfully submitted,", a blank line, `/s/` name, the signer, bar number and contact lines, single spaced; kept on one page with the last paragraph (or the last prayer item).
- Page number: 12 pt, centred, its line box ending 0.5 in above the page edge.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division`, `caption.parties` (list of `{names, designation}`; "v." between parties), `case_number`, `judge` or `judges` (optional), `brief_title`, `lead_in` (optional, unnumbered), `signature` (`signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3); a list (`1.` or `-` items, lettered by the template); a paragraph (numbered by the template, do not type numbers in the text).
- Not supported: tables, block quotations, footnotes, raw typst.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The CourtListener search (`court=mied`, `type=r`, complaints filed 2026-09 to 2026-10) also found Fleet Connect Solutions LLC v. Road Ready, LLC, 2:26-cv-13496 (33 pp., Liberation Sans, a patent complaint) and Annapolis Pointe Phase I LDHA LLC v. City of Inkster, 2:26-cv-13484 (23 pp., Arial, Pentiuk, Couvreur & Kobiljak). Those were checked for text but not saved (one exemplar per doc type). Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** LR 5.1(a)(3) requires 14 point for proportional type and names no typeface. Times New Roman (the exemplar's face, the repo default, `docs/FONTS.md`) in both engines; the docx was EB Garamond before the cross-engine port (2026-10-22).
3. **Double spacing.** Defined against Times New Roman's single line box (1.15 em: 16.1 pt single, 32.2 pt double at 14 pt). The rule text is "double-spaced", not a pitch, so this is a reading, not a measured number. The exemplar's line pitch is similar (about 32 pt).
4. **Caption.** The party column is closed by a right and bottom rule instead of the ")" column used in some E.D. Mich. filings. Recorded as ACCEPTED.
5. **Case-name italics.** The sample's case names are not italic (the exemplar has no case names). The template italicizes `*...*` markup, so future samples can carry italics.
6. **Paragraph numbers.** Every body paragraph is numbered, the WHEREFORE paragraph before the prayer and the jury demand included (1 to 40); the exemplar leaves those two unnumbered (1 to 38). Tier 3 (one filer's style); OPEN.
7. **Headings.** The exemplar sets its claim headings (three levels) single spaced as one group, its level 3 roman; here every heading sits on a double line and level 3 is italic. Tier 3; ACCEPTED.
8. **Overlay pairing.** The overlay pairs each render page with the exemplar page sharing the most words. It is a diagnostic, not a score.
9. **Sample file names.** The brief asked for `usage/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/overlay.sh` reads `usage/OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`, and CLAUDE.md requires the INPUT-/OUTPUT-/OVERLAY- names, so this folder follows the repo convention. Flagged for the PM.
10. **Selftest.** `tools/check-selftest.sh` needs a `court.json` in the folder it is given ("court.json unreadable" on this doc folder), so it does not apply here; `tools/check.sh` runs on the doc folder (typst and docx below).
11. **Signature block.** Lists the attorney's bar number and contact lines as the exemplar does, without a date line (the exemplar has none).

## Review of the rendered pages (typst and docx, 12 pages each, 2026-10-22)

The docx render breaks every line and page as the typst render (XENG-001..003 PASS, 248/248 lines), so each row holds for both.

- Page 1: court title in bold capitals (three lines), caption with the ruled party column and the case number and judge at the right, title centred in bold on two lines, lead-in, NATURE OF THE ACTION, paragraph 1. Pass.
- Pages 2 to 4: paragraphs 2 to 12; THE PARTIES on page 2; page 3 ends two lines short so that JURISDICTION AND VENUE opens page 4 with its paragraph. No heading at the foot of a page. Pass.
- Pages 5 to 8: paragraphs 13 to 29; PLAINTIFFS' RIGHTS IN THE REGISTERED WORKS opens page 5; THE SHEIN SPONSORED USES on page 6 (the two URLs unbroken); FIRST CLAIM FOR RELIEF with its two sub-headings on page 8, kept with paragraph 28. Pass.
- Pages 9 to 11: paragraphs 30 to 39; page 9 ends short so that SECOND CLAIM FOR RELIEF and its sub-headings open page 10 with paragraph 33; PRAYER FOR RELIEF on page 11 with items A to C. Pass.
- Page 12: prayer items D to G, JURY DEMAND with paragraph 40, the signature block. Pass.

[Formbook index](../../../../../README.md)

## Engines

- **typst** (primary): `typst/mied-complaint.typ` on `lib/typst/xengine.typ`. `tools/check.sh --engine typst`: all tier-1 checks pass.
- **docx**: `docx/reference.xml` (`base="xengine"`, `{font}` Times New Roman, size 28, body 644, single 322 twips, the heading, Numbered Paragraph and Lettered styles) and `docx/mied-complaint.lua` on `lib/docx/xengine.lua`, which writes the cover, caption, body and signature block, the footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`); `fb render` builds the package (no scripts in `docx/`). `tools/check.sh --engine docx`: all tier-1 checks and XENG-001..003 pass (gated).
- **latex**: none for this doc type.
