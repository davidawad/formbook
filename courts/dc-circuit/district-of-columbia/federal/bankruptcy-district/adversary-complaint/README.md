# dcb: adversary complaint

Doc type: **adversary complaint** (plaintiff's complaint commencing an adversary proceeding, Fed. R. Bankr. P. 7001 and 7003) in the United States Bankruptcy Court for the District of Columbia (`dcb`).
Folder: `courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the whole 13-page complaint transcribed, plus the consent statement the rules require and the exemplar lacks (gap 3) |
| typeface | face required: none (LBR and FRBP checked, see gap 2). Font: Times New Roman (the house standard, fb-9fyu; the exemplar's face) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 13 pages, typst 0.15.0, vendored Times New Roman only, no warnings; re-rendered 2026-10-22 (fb-595.68.6) |
| overlay | ok: `usage/OVERLAY-square-funding.pdf` and `OVERLAY-square-funding.txt` (re-run 2026-10-15 against `usage/FILED-EXAMPLE-adversary-complaint-2.pdf`) |
| pages reviewed | 13 of 13 on typst and docx (every page viewed side by side, 2026-10-22) |
| check gates | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this is a doc-type folder, and `tools/` is out of scope for this box |

File names: the brief asks for `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, and `overlay.sh` reads `OUTPUT-<id>.pdf`, so the tools' names are used. The sample is `INPUT-<id>.md`, following the file-role names in `CLAUDE.md`.

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint square-funding
```

## Governing rules

Verified 2026-10-14. Local rules: the court's Local Bankruptcy Rules as attached to General Order 2025-01 (signed March 3, 2025; revisions effective April 1, 2025), https://www.dcb.uscourts.gov/sites/dcb/files/2025-03-03%20GO%202025-01%20signed%20w%20LBR.pdf (text read from the PDF's text layer). Federal rules: Cornell LII pages for each rule.

| Rule | Requirement | Where the template does it |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | Fed. R. Civ. P. 10 applies to an adversary complaint, except that the caption must substantially conform to Official Form 416. | `caption()`, `cover()` |
| Fed. R. Bankr. P. 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004) | The document must be clearly legible. | letter paper, 12 pt type, one-inch margins (`dcb-adversary-complaint.typ`) |
| Fed. R. Bankr. P. 9004(b) | Caption sets out: the court's name; the case's title; the case number and, if appropriate, the adversary-proceeding number; a brief designation of the document. | `court-title()`, `caption()` (debtor case number, chapter, "Adv. Case No."), `title` |
| Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The pleading must include a reference to the name, number and Code chapter of the case, and must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. The core/non-core statement was removed in 2016 (committee note), so it is not required. | `final-orders()`: the statement is generated from `final_orders.consent` and names the debtor, the case number and the chapter from the caption |
| LBR 7012-1 | Each party includes in its initial substantive filing a statement whether it consents to entry of final orders and/or judgments by the bankruptcy judge. | `final-orders()` (same statement as FRBP 7008(a)) |
| LBR 5005-1(c) | On the first page, the represented party's attorney gives name, bar number, office address, email, telephone, and whom the attorney represents (footer or header permitted); a D.C. Bar number is required if the attorney is a D.C. Bar member. | `counsel-block()` (upper left; asserts email and "represents") |
| LBR 7003-1 | Cover sheet (Official Form) required only from a party not represented by an electronic filing user. | not produced (represented filer) |
| LBR 7004-2 | The Clerk issues the summons; if it is not delivered or mailed within 7 days of issuance, the party contacts the Clerk for a new one. | not produced (separate filing) |
| LBR 7007.1-1 | A corporate party files its ownership statement separately through CM/ECF with its initial pleading. | not produced (separate filing) |
| Fed. R. Civ. P. 10(b), as incorporated by FRBP 7010 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph (not the lead-in or WHEREFORE paragraphs) |

Verified in this pass: FRBP 7010, 9004(a)-(b), 7008(a) (LII pages, quoted). LBR 5005-1(c), 7003-1, 7004-2, 7007.1-1, 7012-1 (the court's attached LBR PDF). Not verified in this pass: the text of Fed. R. Civ. P. 10(b) and Official Forms 416 and 104 (the cover sheet). The template does not depend on the Official Form wording.

Not produced by this template: the adversary cover sheet (Official Form 104), the summons, the corporate ownership statement, and any jury demand (the exemplar has none; the template has no jury-demand option).

## Layout

- Letter paper, one-inch margins on all sides, page number centred at the foot of each page.
- Counsel block single-spaced in the upper left (LBR 5005-1(c)); the court name in bold capitals; the caption as a three-column grid (party names, a column of ")" marks, the case numbers); the title of the paper in bold capitals centred.
- Body double-spaced: a 27.6 pt baseline pitch at 12 pt (measured on the exemplar with `pdftotext -bbox-layout`: body lines on its page 3 are 27.6 pt apart). Every line is a box of its pitch (27.6 pt body, 13.8 pt single lines: the cross-engine layout model, `lib/typst/xengine.typ`); spaces between blocks are explicit.
- Headings: level 1 is a centred bold line; level 2 (the statute line under a count heading) is a centred line.
- Paragraphs are first-line indented 0.5 inch; after the first heading they are numbered 1, 2, ... by the template (the number in a 0.5-inch box after the indent); the lead-in and WHEREFORE paragraphs are not.
- The consent statement follows the last count and stays on one page with the signature block: "Dated", "Respectfully submitted", "By: /s/", the signer's name, bar number, address, phone, facsimile (when given), email and role.
- The template contains no case-specific text. Every name, number, date and paragraph comes from the sample.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this doc type has 1. Searches: CourtListener API (`type=r&court=dcb`, query "complaint adversary", ordered by date; the HTML search page returns 403 to WebFetch, the API works). Of the results with PDFs, Akers (17-10012, entry 1, 2017) and Elliot (26-10013, entry 1, 2026) are scans with no body text and were not used. Webster v. CFG Merchant Solutions (25-10055) is the same filer, the same day, the same counsel, so it is not a second filer. Webster v. Jaycee Development (25-10052) is text-based but a different layout (Calibri), and was not saved. A second filer is needed for tier 2.
2. **Typeface and size.** Checked 2026-10-15 against the court's LBR PDF (text layer, searched for font, typeface, point and format terms): no rule names a typeface or a point size. The only format rule is LBR 5005-1(b), which covers pro se papers (letter size, 1-inch margins, "plainly and legibly" typed) and names no face. The template sets Times New Roman 12 pt, the house standard (fb-9fyu) and the exemplar's face, on typst and docx alike.
3. **Consent statement (assumed value).** The exemplar states no position on final orders, and the rules require one. The sample's `final_orders.consent: consents` is an assumption made to test the template, not a fact from the exemplar. The trustee's actual choice is unknown. The template prints the sentence for either value and refuses any other.
4. **Exemplar as filed.** The transcription keeps what the filer wrote: the blank adversary number ("Adv. Case No. ____________"), two typographical slips ("time he December 2022 Agreement"; the WHEREFORE paragraph of Count II ends without a period), . The "[Signature on Following Page]" line is a layout note and is not transcribed.
5. **Page count.** The render is 13 pages, as the filed PDF; both are double-spaced at the same 27.6 pt pitch. The text is complete (all 71 paragraphs, numbered 1 to 71 as filed).
6. **Italics.** The exemplar's case names and "Id." are probably italic, but the text layer carries no italic markup, so the sample is roman. The template italicises `*...*` markup where the sample uses it.
7. **Overlay.** The sample is the whole complaint, so the overlay map pairs most pages one-to-one (page 6 with filed page 8 and page 9 with filed page 10 show the pagination drift). The overlay is a diagnostic, not a score.

## Review of the rendered pages (fb-595.68.6, 13 pages per engine)

Rendered with `pdftoppm -r 40`; every page of the typst render and of the docx render viewed side by side after the
last template change. Gate 2 rows for these pages are recorded here: this doc type has no `reviews/` folder.

- Page 1: counsel block (single-spaced, upper left), the court name in two bold centered lines, the ")" caption (one row per line: "In re:", the case number and chapter at the debtor, the adversary number at the plaintiff), "COMPLAINT", the lead-in. Pass on both engines.
- Pages 2 to 12: headings centered (count headings bold, the statute line under each regular), numbered paragraphs 1 to 71 at the double pitch, the WHEREFORE paragraphs unnumbered; no heading at a page foot. Pass on both.
- Page 13: the statement on final orders and judgments (FRBP 7008(a), LBR 7012-1) with the signature block ("Dated", "Respectfully submitted,", "By: /s/", the signer's lines). Pass on both.

## Engines

Typst is the primary engine (`typst/`); the docx engine is `docx/`: `reference.xml` (the cross-engine style recipe,
`base="xengine"`, in the typst face) and `dcb-adversary-complaint.lua`; `fb render` builds the reference document and
runs pandoc (no shell script, fb-595.68). There is no latex engine for this doc type. Both engines sit on the
cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line in a box of its pitch,
first-fit ragged-right line breaking, no kerning, ligatures or hyphenation; the caption is a table of one row per
line in Word as in typst; the docx filter adds typst's break rules that LibreOffice lacks (a word joiner in ")(", a
zero-width space after a slash before a letter).

- **Gate 4:** `params.cross_engine: gate` (`eval.yaml`): XENG-001..003 pass, the docx breaks every line and page as the typst render (13 pages).
- **docx BLOCKED items:** none.
- **Not verified:** the `.docx` has not been opened in Microsoft Word (none here); it converts without error in LibreOffice (DEF-DOCX-OPEN).
