# ohnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Ohio (`ohnd`).
Folder: `courts/sixth-circuit/ohio/federal/northern-district/complaint/` (one self-contained folder per doc type).

| Item | Status |
|---|---|
| exemplar | yes: 2 filers. `usage/FILED-EXAMPLE-complaint.pdf` (12 pp, transcribed) and `usage/FILED-EXAMPLE-complaint-2.pdf` (31 pp, second filer). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md`: the whole 12-page filing (caption, all 26 numbered paragraphs, lettered sub-items, prayer, signature). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 11 pages, `tools/render.sh`, vendored Times New Roman only, no typst warnings; `usage/OUTPUT-complaint.docx` and `.docx.pdf`, 11 pages, breaking every line and page where typst does. |
| overlay | `just overlay <dir>` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` and `.txt` (gitignored, not committed). |
| pages reviewed | 11 of 11 (every page of the current PDF rendered at 60 dpi and viewed after the last template change). |
| content check | every word of the sample body appears in the PDF, in order; the only difference is "non-compliant", which the render breaks at its hyphen (the two halves are present). |
| `tools/check.sh` | typst: `RESULT: 9 checks passed, 0 failed`; docx: `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (260/260 lines, 11/11 pages), gated by `eval.yaml` (`params.cross_engine: gate`). |

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
- Body: double-spaced at 27.6 pt, twice the 13.8 pt single pitch (1.15 x the type size). The exemplar Hammill (N.D. Ohio, ECF) has a body pitch of 27.6 pt, the same value, so the spacing is the filed convention and not a guess. Every line is a box of its pitch on the shared cross-engine layout model (`lib/typst/xengine.typ`): no kerning, ligatures or hyphenation, first-fit ragged-right lines, explicit spaces between blocks.
- Paragraphs are numbered 1, 2, ... (0.5 inch first-line indent, the number in a 0.5 inch box, then the text, 1 inch from the margin; the docx a tab there). A paragraph crossing a page is split normally.
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
| Typeface | Times New Roman 12 pt | Face required: none (L.R. 10.1 names no face or size; it requires "plainly typewritten, printed, or prepared by a clearly legible duplication process"). Times New Roman (vendored, `docs/FONTS.md`), as both exemplars; the typst template declares ("Times New Roman", "Liberation Serif") and the docx names the same face. |
| Line box | the pitch, baseline at 0.8 of it | The cross-engine layout model (Word's exact line spacing). |
| Single pitch | 13.8 pt (1.15 em) | 7.8 pt line box + 6 pt leading. |
| Double pitch | 27.6 pt | Twice the single pitch; equals the Hammill exemplar's measured body pitch. |
| Top margin, page 1 | 1 1/2 in | L.R. 10.1. |
| Other margins | 1 in | Convention (exemplars). |

## Review of the rendered pages (current PDF)

Typst and docx renders of `usage/INPUT-complaint.md` (fb-595.68.30), every page rendered at 60 dpi and viewed side by side; compared with the Wagner exemplar (filed pages 1 and 2 as images, the rest as the text layer) and the Miller exemplar's page 1. The two engines break every line and page alike (XENG-001..003 PASS), so each row holds for both.

| Page | Finding | Status |
|---|---|---|
| 1 | Court title centered below the 1 1/2 in top space (L.R. 10.1); caption with a ")" on every line (two for the wrapped defendant name), "Case No." on the first row and "Judge:" on the third; title bold and centered; lead-in; "JURISDICTION AND VENUE"; ¶¶1-2. | PASS |
| 2 | ¶2 continues; ¶3; PARTIES; ¶¶4-7 at the double pitch. | PASS |
| 3 | ¶¶7-12. | PASS |
| 4 | ¶¶12-15; the label "Accessible Routes" and items A-B, the letter half an inch in and the text hanging at 1 in. | PASS |
| 5 | Labels "Lobby Restrooms", "Access to Goods and Services", "Mobility Accessible Guest Room #708", each kept with its item; items C-G. | PASS |
| 6 | Items H-M; the letter sequence continues. | PASS |
| 7 | Items N-Q; label "Mobility Accessible Guestrooms Generally". | PASS |
| 8 | Items Q-T; label "Policies and Procedures:"; ¶16. | PASS |
| 9 | COUNT I with its second heading; ¶¶17-21. | PASS |
| 10 | COUNT II, its two headings and the bold statute line; ¶¶22-26; WHEREFORE (unnumbered) and the first prayer item. | PASS |
| 11 | The last prayer item kept with "Respectfully submitted," and the signature block (name, Ohio Bar number, address, telephone, facsimile, e-mail; L.R. 10.1); centered page number on every page. | PASS |

No OPEN rows.

## Overlay

The overlay is a diagnostic (tier 3), not a score: `just overlay <dir>` writes it to the gitignored `.overlay/`. Our pages run one step ahead of the filing from page 2 on (the filed copy's paragraph numbering and page breaks differ), not a missing paragraph (see the content check above).

## Known gaps and open choices

1. **Typeface.** L.R. 10.1 names no face and allows any clearly legible typeface. The template sets Times New Roman, as both exemplars (it was EB Garamond before fb-595.68.30).
2. **Second filer not transcribed.** The Miller complaint is saved as the second exemplar for tier-2 comparison but was not transcribed (the sample is the Wagner filing). The comparison is by reading the Miller text layer and first page, not a page-by-page review.
3. **Caption.** The Wagner filing draws the party column with ")" marks; the Miller filing uses a ":" column. The template follows the Wagner filing (tier 2; both are seen in N.D. Ohio filings).
4. **Division.** The sample's caption carries no division (the Wagner filing does not print one). `division` is available in the frontmatter (the Hammill and Miller filings print "Western Division" and "Eastern Division").
5. **Judge line.** "Judge:" prints with the value from frontmatter; a blank value leaves the label alone, as the Wagner filing does.
6. **Lettered items use an ordered list.** Lettering goes beyond the 26 letters only if a list runs past Z; the sample uses A-T.
7. **Standing orders.** Individual judges' standing orders may add format or page rules (for example a font size). Not reviewed here; the district rules above are the only ones cited.
8. **Render and overlay names.** Outputs are `usage/OUTPUT-complaint.typst.pdf`, `.docx`, `.docx.pdf`; overlays go to the gitignored `.overlay/`.
9. **Not produced:** the JS-44 civil cover sheet, the corporate disclosure statement, the summons. They are separate filings (L.R. 3.13).

## Searches (exemplar selection)

- CourtListener RECAP search, `type=r`, `court=ohnd`, query "complaint", filed on or after 2025-06-01 (API v4, 2026-10-14). Most results had no text available (`is_available: false`) or were removals.
- Saved: Wagner v. Schofield Properties (12 pp, text layer, one filer, a complete ADA complaint; the sample) and Miller v. Krupnick (31 pp, text layer, a second filer, with a jury demand).
- Not saved: Underdog Exchange DCM v. Wilson, 1:26-cv-02169 (44 pp, a declaratory-judgment complaint with a text layer, against state officials). It is a third filer, but the brief asks for one exemplar per doc type, and Miller already supplies the second filer.

[Ohio federal index](../../README.md) | [Court folder](../README.md)

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"), and `eval.yaml` gates it (`params.cross_engine: gate`): the docx render must break every line and page where the typst render does.

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`: Times New Roman 12 pt, the typst face as `{font}`; Body Text in exact 27.6 pt lines, single lines 13.8 pt, headings at the type size on the body pitch) and the filter `docx/ohnd-complaint.lua`, which `fb render` runs: it writes the court title (the 1 1/2 in first-page top margin as its space before), the caption as a borderless table (one row per line of the party column; the ")" count of a wrapped name computed from Times New Roman's advances, as typst measures it), the title, numbered paragraphs (the number then a tab to 1 in), labels and lettered items (A., B., the markdown number giving the letter), headings, the jury demand when asked for, the signature block kept with the last paragraph, and the footer (a centered page number) and last section via `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`. The old `build-reference.sh`, `render.sh` and `reference.docx` (EB Garamond) are gone.

- Result: 11 pages, every typst line breaking after the same word (260/260), every page starting and ending on the same word; tier 1 (DEF-FONT-002, DEF-COVER-001, DEF-TOC-001 and the rest) green on both engines.
- No BLOCKED items.
