# orb: adversary-complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of Oregon (`orb`).
Folder: `courts/ninth-circuit/oregon/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-green-oregon-26-03055-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-green-oregon-complaint.md` (a portion of the 76-page filing; see Known gaps) |
| render | ok: `samples/OUTPUT-green-oregon-complaint.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-green-oregon-complaint.pdf` and `OVERLAY-green-oregon-complaint.txt` |
| pages reviewed | 13 of 13 (every page rendered at 60 dpi and viewed; pages 2, 10, 11 also at 110 dpi after the layout fixes) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), not the `<id>.md` names in the brief, because the tools read and write those names by default.

## Governing rules

Primary source: Local Bankruptcy Rules of the District of Oregon, "LBR.120125 clean" (effective 2025-12-01, the current set), https://www.orb.uscourts.gov/sites/orb/files/documents/local_rules/LBR.120125%20clean.pdf, fetched 2026-10-14 (version marked "12/1/2025" on each page).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 9004-1(a)(1)(A)-(B) | 8 1/2 x 11 pages; type no smaller than 10 cpi or 12 point, including footnotes. | `page-w`, `page-h`, `type-size = 12pt` (footer too, see Known gaps). |
| LBR 9004-1(a)(2) | Top and bottom margins at least 1 inch; sides at least 3/4 inch. | `margin-top`, `margin-bottom` = 1in; `margin-side` = 0.75in. |
| LBR 9004-1(a)(4)(A) | Body text double-spaced. | `leading-double` (2.0 em line pitch, 24 pt at 12 pt). |
| LBR 9004-1(a)(4)(B) | Quotation of four or more lines indented and single-spaced. | Not used by the sample; no quotation support in the template (see Known gaps). |
| LBR 9004-1(a)(9)(A) | Counsel name, address, telephone and OSB number, single-spaced, upper left of the title page, starting at least 1 inch from the top. | `counsel` frontmatter, `lines()` at the top of page 1. |
| LBR 9004-1(a)(9)(D) | Title (or abbreviation) and page number in the lower-left margin of each page. | `page-footer()`: `footer_title` upper-cased, then "Page N of M". |
| LBR 9004-2(c) | Adversary caption: UNITED STATES BANKRUPTCY COURT / FOR THE DISTRICT OF OREGON; "In re"; Case No.; Adv. Proc. No.; parties with ")" column; title; DEMAND FOR JURY TRIAL when demanded. | `court-title()`, `caption()` (the ")" column is sized from the measured left column). |
| LBR 9004-2(a) | Caption at least 1 inch from the top of the first page. | Top margin 1 inch. |
| LBR 7001-1(b), (c)(2)-(3) | Complaint filed with the fee, an OF 1040 cover sheet, and a summons. | Not on the page; the template does not produce them (see Known gaps). |
| FRBP 7001 (a), (b), (g), (i); FRBP 7008 | Type of proceeding; core statement and consent. | Stated by the sample text (paragraphs 8 and 10 of the exemplar), not checked by the template. These two FRBP rules were not fetched in this run. |

Not verified in this run: the text of FRBP 7001, 7003, 7004, 7008 (the sample quotes the exemplar; no primary-source fetch of the FRBP itself).

## Layout

- Page 1: counsel block (single-spaced), court title, caption grid (parties | ")" column | case numbers, title, jury demand), then a page break.
- Body: each blank-line-separated chunk is one numbered paragraph (first-line indent, the template numbers from 1); headings are centered bold caps (level 1), centered bold (level 2), bold italic (level 3); a chunk starting `- `, `* `, or `1. ` is a list rendered as lettered items A., B., ... (the prayer for relief); a chunk starting `~ ` is an unnumbered paragraph (the prayer lead-in).
- Signature: date line (from `date`), then the `signature` lines at the right half.
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
3. **Font.** EB Garamond (the only vendored font). Times New Roman is the common Oregon filing face; EB Garamond at 12 pt has a smaller x-height. The 12-point minimum is met.
4. **Footer type size.** The footer is 12 pt, the same as the body, because LBR 9004-1(a)(1)(B) applies to type "used in a document". The exemplar's footer is smaller; this is a reading of the rule, recorded here.
5. **Cover sheet, fee, summons.** LBR 7001-1(b) and (c)(2)-(3) require the fee (or a trustee's certification of insufficient funds), an OF 1040 cover sheet, and the summons. These are separate filings, not in the template. The exemplar's docket shows a trustee's insufficient-funds certification; the template does not check for one.
6. **Paragraph spacing inside the caption.** The caption's ")" column is an approximation built from measured line heights; its alignment with the party lines may differ by a few points from the exemplar.
7. **Quotations.** No block-quote support; LBR 9004-1(a)(4)(B) would need a single-spaced indented style if a sample needs one.
8. **No primary-source check of FRBP.** The brief's rule citations for FRBP 7001, 7003, 7004, 7008 are from the complaint text; they were not fetched.
9. **Tool checks.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder does not have; the brief forbids touching `tools/`, so these gates were not run. Render and overlay were run; the page review above is the Gate 2 equivalent.
10. **Latex and docx engines** are not built for this doc type (the brief asks for typst only).

## Review of the rendered pages (13 pages)

- Page 1: counsel block on the top 1 inch; court title and caption; title in bold at the right; footer "Page 1 of 13". Pass.
- Pages 2-9: numbered paragraphs 1 to 34 with the centered headings NATURE OF THIS ACTION, JURISDICTION AND VENUE, THE PARTIES, FACTUAL BACKGROUND COMMON TO ALL CLAIMS (with subheads). No overlap; no heading at the foot of a page. Pass.
- Pages 9-10: FIRST CLAIM FOR RELIEF heading and paragraphs (unnumbered run continues the count), then PRAYER FOR RELIEF with the WHEREFORE lead-in (unnumbered, `~ `). Pass.
- Pages 10-12: prayer items A-M, each item on its own paragraph, labels in sequence, no overlap. Pass.
- Page 13: date line and signature block (right half, single-spaced). Pass.
