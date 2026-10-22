# orb: adversary-complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of Oregon (`orb`).
Folder: `courts/ninth-circuit/oregon/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (a portion of the 76-page filing; see Known gaps) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `.docx.pdf`, 14 pages each, the same lines and pages (XENG gated), vendored Times New Roman only, no warnings (2026-10-22) |
| overlay | ok: `usage/OVERLAY-green-oregon-complaint.pdf` and `OVERLAY-green-oregon-complaint.txt` |
| pages reviewed | 14 of 14 on each engine (`reviews/2026-10-22.md`) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), not the `<id>.md` names in the brief, because the tools read and write those names by default.

## Governing rules

Primary source: Local Bankruptcy Rules of the District of Oregon, "LBR.120125 clean" (effective 2025-12-01, the current set), https://www.orb.uscourts.gov/sites/orb/files/documents/local_rules/LBR.120125%20clean.pdf, fetched 2026-10-14 (version marked "12/1/2025" on each page).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 9004-1(a)(1)(A)-(B) | 8 1/2 x 11 pages; type no smaller than 10 cpi or 12 point, including footnotes. | `page-w`, `page-h`, `type-size = 12pt` (footer too, see Known gaps). |
| LBR 9004-1(a)(2) | Top and bottom margins at least 1 inch; sides at least 3/4 inch. | `margin-top`, `margin-bottom` = 1in; `margin-side` = 0.75in. |
| LBR 9004-1(a)(1)(B) (typeface) | Sets a type size only (10 cpi or 12 point, footnotes included). It names no typeface anywhere in the local rules (checked 2026-10-15 against the fetched LBR text). | Face required: none. Template face: Times New Roman (vendored, the house face), typst and docx alike. |
| LBR 9004-1(a)(4)(A) | Body text double-spaced. | `pitch-body` (24 pt line boxes at 12 pt). |
| LBR 9004-1(a)(4)(B) | Quotation of four or more lines indented and single-spaced. | Not used by the sample; no quotation support in the template (see Known gaps). |
| LBR 9004-1(a)(9)(A) | Counsel name, address, telephone and OSB number, single-spaced, upper left of the title page, starting at least 1 inch from the top. | `counsel` frontmatter, `lines()` at the top of page 1. |
| LBR 9004-1(a)(9)(D) | Title (or abbreviation) and page number in the lower-left margin of each page. | `page-footer()`: `footer_title` upper-cased, then "Page N of M". |
| LBR 9004-2(c) | Adversary caption: UNITED STATES BANKRUPTCY COURT / FOR THE DISTRICT OF OREGON; "In re"; Case No.; Adv. Proc. No.; parties; title; DEMAND FOR JURY TRIAL when demanded. | `court-title()`, `caption()`: ruled, as both filed examples (the debtor block over the parties, a rule under it and down the party column); the rule's ")" column form is not used. |
| LBR 9004-2(a) | Caption at least 1 inch from the top of the first page. | Top margin 1 inch. |
| LBR 7001-1(b), (c)(2)-(3) | Complaint filed with the fee, an OF 1040 cover sheet, and a summons. | Not on the page; the template does not produce them (see Known gaps). |
| FRBP 7001 (a), (b), (g), (i); FRBP 7008 | Type of proceeding; core statement and consent. | Stated by the sample text (paragraphs 8 and 10 of the exemplar), not checked by the template. These two FRBP rules were not fetched in this run. |

Not verified in this run: the text of FRBP 7001, 7003, 7004, 7008 (the sample quotes the exemplar; no primary-source fetch of the FRBP itself).

## Layout

- Page 1: counsel block (single-spaced), court title, the ruled caption (debtor block | case number; parties | adversary number, title, subtitle, jury demand), then a page break (the filed complaint's body also starts on page 2).
- The cross-engine layout model (`lib/typst/xengine.typ`): 24 pt body line boxes, 13.8 pt single lines, the spaces between blocks explicit (one blank double line between the counsel block, the court title, and the caption).
- Body: each blank-line-separated chunk is one numbered paragraph (first-line indent, the template numbers from 1); headings are centered bold caps (level 1), centered bold (level 2), bold italic (level 3); a chunk starting `- `, `* `, or `1. ` is a list rendered as lettered items A., B., ... (the prayer for relief); a chunk starting `~ ` is an unnumbered paragraph (the prayer lead-in).
- Signature: date line (from `date`), then the `signature` lines 3 in from the margin; the last chunk (the last prayer item) is kept with them.
- Footer on every page: title (upper case) and "Page N of M".

## Markdown contract (for samples)

- YAML frontmatter: `counsel` (lines), `caption` (`debtor`, `debtor_role`, `parties` as `{names, designation}`), `case_number`, `adv_number`, `brief_title`, optional `subtitle`, `footer_title`, optional `lead_in`, optional `jury_demand`, `date`, `signature` (lines).
- Body: paragraphs are numbered by the template, so the sample must not contain the paragraph numbers. Headings with `#`, `##`, `###`. Prayer items are a markdown list; items are lettered by the template.
- Not supported: tables, footnotes, raw typst, quotations of four or more lines.

## Overlay

`tools/overlay.sh` paired every sample page with its best-matching exemplar page by word overlap (`OVERLAY-green-oregon-complaint.txt`): 1-1, 2-2, 3-3, 4-5, 5-6, 6-8, 7-9, 8-10, 9-12, 10-50, 11-73, 12-74, 13-76. The pairing is by text, so the jumps (10 to 50, 11 to 73) are the sample's omitted pages, not a layout error. The overlay is a diagnostic, not a score; the red/blue result is not judged here.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one filed document per doc type, so the tier-2 check against two or three filers is not done. Other 2026 adversary complaints in the same court (Dejong v. U.S. Dept. of Education, 26-03057; Columbia Bank v. Vossoughi, 26-03006; Large v. Oregon Brewing, 26-03001) appear in CourtListener search results but had no RECAP PDF on the storage server, so they could not be saved.
2. **Partial transcription.** The sample keeps paragraphs 1-34 and 153-156 of the 76-page complaint, the caption, the first claim heading, prayer items A, B, J-U (with ellipses where text is elided), and the signature. Paragraph 5, the prayer items C-I, and paragraphs 35-152 are omitted or elided. Because the template numbers allegations from 1, the sample's paragraph numbers do not match the filing's (the sample's paragraph 35 is the filing's paragraph 153, not 35). Prayer letters restart at A from the sample's first item and run A-M.
3. **Font.** Times New Roman 12 pt in typst and docx (the docx named EB Garamond until fb-595.68.24). The local rule names no face (LBR 9004-1(a)(1)(B) sets only the type size); the house face applies, which is also the filed complaint's.
4. **Footer type size.** The footer is 12 pt, the same as the body, because LBR 9004-1(a)(1)(B) applies to type "used in a document". The exemplar's footer is smaller; this is a reading of the rule, recorded here.
5. **Cover sheet, fee, summons.** LBR 7001-1(b) and (c)(2)-(3) require the fee (or a trustee's certification of insufficient funds), an OF 1040 cover sheet, and the summons. These are separate filings, not in the template. The exemplar's docket shows a trustee's insufficient-funds certification; the template does not check for one.
6. **Caption form.** LBR 9004-2(c)'s form shows a ")" column; both filed examples (this complaint and the motion's) rule the party column instead, and the template follows them. A ")" per wrapped party line cannot be written by the docx filter, which does not know where Word wraps.
7. **Quotations.** No block-quote support; LBR 9004-1(a)(4)(B) would need a single-spaced indented style if a sample needs one.
8. **No primary-source check of FRBP.** The brief's rule citations for FRBP 7001, 7003, 7004, 7008 are from the complaint text; they were not fetched.
9. **Tool checks.** `tools/check.sh <this folder>` and `--engine docx` run every gate (0 failed; XENG-001..003 gated in `eval.yaml`). `tools/check-selftest.sh` takes a court root with `checks.yaml` and does not run here.
10. **Latex** is not built for this doc type.

## Review of the rendered pages

`reviews/2026-10-22.md` (14 of 14 pages, typst and docx).

## Engines

**docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt, Body Text in exact 24 pt lines, single lines 13.8 pt; "Body Numbered" with a tab to 1 in for the number) and `docx/orb-complaint.lua` with `docx/lib/orb-common.lua` (shared with the motion; the same file in both folders): the cover and the ruled caption, the numbered allegations, the lettered prayer, the signature block, the footer (the title in capitals and "Page N of M", PAGE and NUMPAGES fields) and the section. No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and `render.sh`). Output: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf`, 14 pages, every line and page as typst (XENG-001..003 gated).

- Not verified in Word (LibreOffice only); it opens and converts without a repair prompt.
