# ohnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Ohio (`ohnd`).
Folder: `courts/sixth-circuit/ohio/federal/northern-district/complaint/` (one self-contained folder per doc type).

| Item | Status |
|---|---|
| exemplar | yes: 2 filers. `usage/FILED-EXAMPLE-complaint.pdf` (12 pp, transcribed) and `usage/FILED-EXAMPLE-complaint-2.pdf` (31 pp, second filer). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md`: the whole 12-page filing (caption, all 26 numbered paragraphs, lettered sub-items, prayer, signature). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 11 pages, `tools/render.sh`, vendored EB Garamond only, no typst warnings. |
| overlay | ok: `usage/OVERLAY-wagner-complaint.pdf` and `usage/OVERLAY-wagner-complaint.txt` (paired against the Wagner exemplar). |
| pages reviewed | 11 of 11 (every page of the current PDF rendered at 60 dpi and viewed after the last template change). |
| content check | every word of the sample body appears in the PDF, in order; the only difference is "non-compliant", which the render breaks at its hyphen (the two halves are present). |
| `tools/check.sh` | not run: it expects a court folder with `court.json`, `rules.md` and `checks.yaml`, which this doc-type folder is not (the same note as the cand complaint). |

## Governing rules

Verified 2026-10-14. Federal rules are quoted from Cornell LII (https://www.law.cornell.edu/rules/frcp/); the local rules from the court's own PDFs (https://www.ohnd.uscourts.gov/).

| Rule | Requirement | Kind | Where in the template |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." The complaint's title names all the parties. | M | `court-title`, `caption` (court name, `case_number`, party column, `title`). |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | M | `allegations()` numbers every paragraph; headings, labels and the WHEREFORE clause (marked `<!--u-->`) are not numbered. |
| Fed. R. Civ. P. 8(a)(1)-(3) (https://www.law.cornell.edu/rules/frcp/rule_8) | A short and plain statement of the jurisdiction, of the claim, and a demand for relief. | M (content) | Author content; the template does not check the wording. |
| Fed. R. Civ. P. 38(b) (https://www.law.cornell.edu/rules/frcp/rule_38) | A jury demand may be included in a pleading, served and filed. | M, when demanded | `jury_demand: true` prints "JURY DEMAND" and the demand sentence before the signature. The sample demands no jury, so this branch is compile-tested only (scratch file, removed). |
| N.D. Ohio L.R. 10.1 (https://www.ohnd.uscourts.gov/sites/ohnd/files/CivilRules_Rule101.pdf, last revised 8/10/18) | 8 1/2 x 11 inch white paper; "plainly typewritten, printed, or prepared by a clearly legible duplication process and double-spaced except for quoted material"; "The top margin of the first page of each document filed shall be one and a half (1.5) inches"; "Each page shall be numbered consecutively."; the signature carries the typed name, address, telephone, facsimile, e-mail and Ohio Bar Registration Number. | M | `page-w/h`, `first-page-top` (1.5 in, the extra half inch added before the court title), `body-pitch` (double spacing), the footer page number, `signature-block`. The sample's signature lines carry the name, bar number, address, telephone, facsimile and e-mail. |
| N.D. Ohio L.R. 3.13(a) (https://www.ohnd.uscourts.gov/sites/ohnd/files/Rule_3_13%20Redline.pdf) | The clerk requires a completed JS-44 civil cover sheet with each new civil case. | M, separate filing | Not produced here (a separate filing). |
| N.D. Ohio L.R. 3.13(b) (same PDF) | A nongovernmental corporate party files a corporate disclosure statement with its first filing. | M, separate filing | Not produced here. |

Not in the rules, so not asserted: a font (L.R. 10.1 sets no typeface or size); margins other than the first-page top margin (one inch is the convention the exemplars follow); a summons (separate form).

## Layout

- Court title centered at the top of page 1, below a 1 1/2 inch top space (L.R. 10.1); the rest of each page has a 1 inch margin.
- Caption: the party names, a column of ")" marks (one mark for each line of each name), and at the right, the case number and judge. A name that wraps takes one ")" per line.
- Title: bold, centered, in a measure narrower than the text (the words wrap; no break is forced).
- Body: double-spaced. Measured: EB Garamond's line box is 0.65 em (7.8 pt at 12 pt, measured by typesetting two lines in a scratch file), so single spacing is 13.8 pt (1.15 em) and double spacing is 27.6 pt, twice the single pitch. The exemplar Hammill (N.D. Ohio, ECF) has a body pitch of 27.6 pt, the same value, so the spacing is the filed convention and not a guess.
- Paragraphs are numbered 1, 2, ... (0.5 inch first-line indent, number, then the text). A paragraph crossing a page is split normally; the trailing leading after each paragraph is added as space so that the lines stay on the grid of body pitches.
- Headings: level 1 bold capitals centered; level 2 bold centered; level 3 bold italic at the left. A heading is sticky (never the last line of a page).
- Lettered sub-items: a markdown ordered list is lettered A., B., ... ; the markdown number is the letter's position, so a list that continues a letter run from an earlier group starts at its own number (see ¶15 of the sample: A-B, C, D, E-O, P-R, S-T).
- Group labels inside a paragraph list: a chunk that is only `**bold**` is an unnumbered label.
- The WHEREFORE clause and its items: each is marked `<!--u-->` (unnumbered, indented).
- Signature: the last paragraph, the jury demand (if any) and the signature block are one unbreakable group, so the signature never stands alone on a page.
- Footer: consecutive arabic page numbers, centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number` (string), `judge` (optional), `division` (optional, e.g. "Eastern Division"), `caption.parties` (list of `{names: [lines], designation}`; "v." is inserted between parties), `title`, `lead_in` (the unnumbered opening paragraph, optional), `jury_demand` (true/false), `date` (optional), `signature.lines` (the signature block, one line each).
- Body: blank-line-separated chunks. `#` level 1 heading, `##` level 2, `###` level 3; `**label**` alone is an unnumbered label; `1.`-style list = lettered sub-items; `<!--u-->` at the start of a chunk = unnumbered paragraph; anything else = a numbered paragraph.
- Not supported: tables, footnotes (not used in complaints), raw typst.

## Measured and decided values

| Value | Choice | Basis |
|---|---|---|
| Typeface | EB Garamond 12 pt (kept) | Face required: none (L.R. 10.1 names no face or size; it requires "plainly typewritten, printed, or prepared by a clearly legible duplication process"). Substitute: none needed, so EB Garamond stays (`docs/FONTS.md`: "No face named"). Vendored Times-metric option: Liberation Serif, not used (tier-2 convention, see open choice 1). |
| Line box | 0.65 em (7.8 pt) | Measured on EB Garamond in a scratch file. |
| Single pitch | 13.8 pt (1.15 em) | 7.8 pt line box + 6 pt leading. |
| Double pitch | 27.6 pt | Twice the single pitch; equals the Hammill exemplar's measured body pitch. |
| Top margin, page 1 | 1 1/2 in | L.R. 10.1. |
| Other margins | 1 in | Convention (exemplars). |

## Review of the rendered pages (current PDF)

Compared with: the Wagner exemplar (filed pages 1 to 12 as the text layer and, for pages 1 and 2, the rendered image). "Text" means the page was compared with the exemplar's text layer, not an image.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 (image and text) | Court title below the 1 1/2 in top space; caption with ")" column; "Judge:" line; title; lead-in; ¶1 heading "JURISDICTION AND VENUE". | PASS |
| 2 | exemplar p.2 (text) | ¶2 continues; ¶3; PARTIES heading; ¶¶4-7 at the double pitch; no paragraph crosses into the next one. | PASS |
| 3 | exemplar p.3 (text) | ¶¶8-12 on the grid; no overlap at the page foot. | PASS |
| 4 | exemplar p.4 (text) | ¶¶13-15; ¶15's "Accessible Routes" label and items A-C. | PASS |
| 5 | exemplar p.5 (text) | Labels "Access to Goods and Services" and "Mobility Accessible Guest Room #708"; items D-I. | PASS |
| 6 | exemplar p.6 (text) | Items J-O; the letter sequence continues from I. | PASS |
| 7 | exemplar p.7 (text) | Label "Mobility Accessible Guestrooms Generally"; items P-R. | PASS |
| 8 | exemplar p.8 (text) | Label "Policies and Procedures:"; items S-T; ¶16; COUNT I heading; ¶¶17-18. | PASS |
| 9 | exemplar p.9 (text) | ¶¶19-23; COUNT II heading; the bold statute line "O.R.C. §4112.01 et seq.". | PASS |
| 10 | exemplar p.10 (text) | ¶¶24-26; WHEREFORE (unnumbered) and its first item; the second item starts page 11 with the signature. | PASS |
| 11 | exemplar p.11 (text) | Second WHEREFORE item; "Respectfully submitted," and the signature block with the Ohio Bar number. The signature is not alone: the last item and the signature share a block. | PASS |

Every page was rendered at 60 dpi and viewed. No OPEN rows.

## Overlay

`usage/OVERLAY-wagner-complaint.pdf` is red (ours), blue (filed), black (both). The pairing in `OVERLAY-wagner-complaint.txt` is by shared words, so pages one step apart in the filing pair with each other (our p.2 with the filed p.2 at 46.7%; our p.3 with the filed p.4). The shift is the paragraph numbering of the filed copy and the page breaks, not a missing paragraph (see the content check above). The overlay is a diagnostic; tier 3 differences are not chased.

## Known gaps and open choices

1. **Typeface.** L.R. 10.1 names no face and allows any clearly legible typeface, so `docs/FONTS.md` gives no substitute and the template keeps EB Garamond. The exemplars use Times New Roman; that is a filer convention (tier 2), not a rule. EB Garamond at 12 pt has a smaller x-height than Times, so the text looks smaller on the page. Liberation Serif (metric-compatible with Times New Roman) is vendored and would remove the difference; switching is a tier-2 decision left open.
2. **Second filer not transcribed.** The Miller complaint is saved as the second exemplar for tier-2 comparison but was not transcribed (the sample is the Wagner filing). The comparison is by reading the Miller text layer and first page, not a page-by-page review.
3. **Caption.** The Wagner filing draws the party column with ")" marks; the Miller filing uses a ":" column. The template follows the Wagner filing (tier 2; both are seen in N.D. Ohio filings).
4. **Division.** The sample's caption carries no division (the Wagner filing does not print one). `division` is available in the frontmatter (the Hammill and Miller filings print "Western Division" and "Eastern Division").
5. **Judge line.** "Judge:" prints with the value from frontmatter; a blank value leaves the label alone, as the Wagner filing does.
6. **Lettered items use an ordered list.** Lettering goes beyond the 26 letters only if a list runs past Z; the sample uses A-T.
7. **Standing orders.** Individual judges' standing orders may add format or page rules (for example a font size). Not reviewed here; the district rules above are the only ones cited.
8. **Render and overlay names.** The brief names `usage/<id>.md` and `usage/<id>.pdf`; the tools write `usage/OUTPUT-<id>.pdf` and `usage/OVERLAY-<id>.pdf/.txt` by default. The tools were used as written (they are not to be edited), so those are the names in the folder.
9. **Not produced:** the JS-44 civil cover sheet, the corporate disclosure statement, the summons. They are separate filings (L.R. 3.13).

## Searches (exemplar selection)

- CourtListener RECAP search, `type=r`, `court=ohnd`, query "complaint", filed on or after 2025-06-01 (API v4, 2026-10-14). Most results had no text available (`is_available: false`) or were removals.
- Saved: Wagner v. Schofield Properties (12 pp, text layer, one filer, a complete ADA complaint; the sample) and Miller v. Krupnick (31 pp, text layer, a second filer, with a jury demand).
- Not saved: Underdog Exchange DCM v. Wilson, 1:26-cv-02169 (44 pp, a declaratory-judgment complaint with a text layer, against state officials). It is a third filer, but the brief asks for one exemplar per doc type, and Miller already supplies the second filer.

[Ohio federal index](../../README.md) | [Court folder](../README.md)

## Engines

**docx** (`docx/`): `reference.docx` is built by `docx/build-reference.sh` (pandoc's default, rewritten with sed/perl; zipped and checked with xmllint). `docx/render.sh` owns the build: pandoc with `docx/ohnd-complaint.lua` (caption table, numbered paragraphs, lettered items, signature), then the reference's styles, page setup and footer are put back.

- Matches typst (set in the reference, from the typst template and measured on its render): EB Garamond 12 pt (`fonts/eb-garamond`; the typst PDF embeds EBGaramond-Regular and -Bold); body lines at an exact 27.6 pt pitch (measured 27.6 pt on the typst page 2); single lines at an exact 13.8 pt; 0.5 in first-line indent; 1 in margins, letter paper; a centered 12 pt page number in the footer; numbered paragraphs 1., 2. with the WHEREFORE clause unnumbered; lettered items A., B. (the markdown numbers give the letter).
- Differs from typst: the 1 1/2 in first-page top margin is a 0.5 in spacer paragraph on page 1 (Word has no per-page top margin); the caption's ")" column has one ")" per party name, not one per wrapped line (a Word table row does not know its wrap count), so a long name that wraps shows fewer ")" than typst; the caption is a borderless Word table, not a typst grid. Not measured: the docx page count (the typst render is 11 pages for the Wagner sample).
- BLOCKED: `docx.pdf` and page review: soffice is not installed on this box (`soffice: not found`), so no LibreOffice PDF exists, Gates 0 to 3 cannot run on the docx, and no docx page was viewed.
- BLOCKED: the caption ")" count on a wrapped name (see above); verify on the LibreOffice PDF before the docx gate.
