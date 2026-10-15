# sdb: motion with memorandum

Doc type: **motion with memorandum** (FRBP 9013; motions in adversary proceedings under FRBP 7007 and Bankr. D.S.D. R. 7007-1) in the United States Bankruptcy Court for the District of South Dakota (`sdb`).
Folder: `courts/eighth-circuit/south-dakota/federal/bankruptcy-district/motion-brief/`.

Exemplar: one real, text-layer filed memorandum in support of a motion, from this court (*In re Northern Beef Packers Limited Partnership*, Bankr. No. 13-10118, Doc 134, filed 08/07/2013, filed by the lender agent). The sample is a transcription of it. The template's tier-2 layout is judged against that one filer (see `exemplars/SOURCE.md` for the choice, the searches, and the limits of the match).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-northern-beef-packers-13-10118-motion-brief.pdf` (15 pages, one filer), sourced in `exemplars/SOURCE.md` |
| typeface | **No face required; EB Garamond kept.** Bankr. D.S.D. R. 9004-1(a)(1) (June 2024 local rules, text checked with `pdftotext`) requires "one simple font" and names no face. The only face named in the local rules is Appendix 1F's creditor-mailing-list bullet ("Universal, Times New Roman, or Courier"), which governs the mailing list, not this document. So no substitute from `docs/FONTS.md` is needed: the template keeps EB Garamond (the "No face named" row). Fit: n/a. Re-checked 2026-10-14 (fonts pass, `fb-595.7.5.21`). |
| sample md | `samples/INPUT-northern-beef-packers.md`: transcription of the whole filing (caption, title, body, footnotes 1 to 3, conclusion, signature). TIN shown as last four digits. |
| render | ok: `samples/OUTPUT-northern-beef-packers.pdf` (9 pages), `tools/render.sh`, vendored EB Garamond only, zero typst warnings. |
| overlay | ok: `samples/OVERLAY-northern-beef-packers.pdf` and `.txt` (`tools/overlay.sh`); page pairing by text: ours 1-9 with filed 1, 2, 5, 7, 8, 10, 12, 14, 15. |
| pages reviewed | 9 of 9 of `OUTPUT-northern-beef-packers.pdf`, each rasterized at 70 dpi and viewed in its final state. |

## Governing rules

Sources, fetched 2026-10-14 (the same local rules text as the adversary-complaint folder):

| Source | URL |
|---|---|
| Bankr. D.S.D. Local Bankruptcy Rules and Appendices, as amended June 14, 2024 (revised 1/24/25), with bookmarks | https://www.sdb.uscourts.gov/sites/sdb/files/local_rules/Local%20Rules%20and%20Appendices%20as%20Amended%20June%2014%2C%202024%20%28revised%201%2024%2025%29%20with%20bookmarks%20and%20links_1.pdf |
| Fed. R. Bankr. P. 9013 | https://www.law.cornell.edu/rules/frbp/rule_9013 |
| Fed. R. Bankr. P. 9004 (caption, legibility) | https://www.law.cornell.edu/rules/frbp/rule_9004 |

Finding: **the local rules have no Rule 9013.** The index of the June 2024 rules has 9014-1 to 9014-4 (contested matters) and 9004-1, 9004-2 (format, caption), but nothing titled 9013. The brief's "per this court's local bankruptcy rules" therefore points to the rules below, not to a local Rule 9013.

| Rule | Kind | Requirement | Where in the template / status |
|---|---|---|---|
| Bankr. D.S.D. R. 9004-1(a)(1) | **M** | White 8½ × 11 paper, margins not less than one inch, one simple font, typewritten, no erasures. | `page-w`, `page-h`, `margin = 1in`, `font-family`. |
| Bankr. D.S.D. R. 9004-1(a)(3) and 9004-2 | **M** | Caption per Rule 9004-2: debtor's full name, full EIN (if any), last four of SSN or TIN, names used (aka / fka). | `caption()`. The template **stops the build** if a debtor has no EIN, SSN last four or TIN last four. |
| Bankr. D.S.D. R. 7010-2 | **M** | In an adversary proceeding, the caption carries the full bankruptcy caption and the complete legal names of all parties, conforming to Official Form 416D. | `caption()` prints plaintiffs and defendants when `adversary_no` is given. The template **stops the build** if an adversary caption lacks them. |
| Bankr. D.S.D. R. 9004-1(a)(4) | **M** | Portrait orientation. | `page-w` < `page-h`. |
| Bankr. D.S.D. R. 9004-1(a)(5) | **M** | Each document signed and dated, the filing attorney per Part V of the ECF Procedures. | `signature()`. |
| FRBP 9013(b) | **M** | A motion must state its grounds with particularity and set forth the relief requested. | The template **stops the build** unless the frontmatter gives `movant`, `relief` and `basis`, and prints them as the motion's opening sentence. The grounds themselves are author text (not checked). |
| Bankr. D.S.D. R. 7007-1 | **M** | A motion in an adversary proceeding is filed separately from any pleading. | Author responsibility: the template produces one document per motion. Not checked. |
| Bankr. D.S.D. R. 9004-1(f) | **M** (no requirement) | A party need not submit a brief in support of a motion unless a local rule or order directs one. | The template produces a memorandum-style body because the brief is the motion's text here, but no brief is required. |
| Bankr. D.S.D. R. 7056-1(b) | **M** (only for summary judgment) | A motion for summary judgment (and an objection to one) is accompanied by a brief that sets out the position and the specific legal authority, docketed as an attachment to the motion. | Author responsibility. The template does not know the motion type. If the motion is summary judgment, file the brief as an attachment (not checked). |
| Bankr. D.S.D. R. 9014-4(a) | **M** (only for summary judgment in a contested matter) | A motion for summary judgment in a contested matter is filed at least seven days before any scheduled hearing, unless ordered otherwise. | Author responsibility. Not checked. |
| FRBP 9014 / contested matters | context | A motion in the main case is a contested matter; the response deadlines are in Bankr. D.S.D. R. 9014-1(b). | Not in the template. |
| Convention (tier 2) | C | Caption as in the adversary-complaint folder: `In re:` block on the left, `)` marks, case numbers on the right, designations right-aligned, court name centered and bold above. | `caption()`. Shares the layout of `../adversary-complaint/` (not verified against a motion; no exemplar). |
| Convention (tier 2) | C | A certificate of service after the signature. | Printed when `certificate:` is in the frontmatter. Conventional, not required by the local rules; the certificate's wording is the author's. |

Tier 1 is every `M` row above. The template enforces the four "stops the build" items; the rest are author responsibilities and are listed under Known gaps.

## Template

| File | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/sdb-motion-brief.typ` | The template: `sdb-motion-brief(meta, md)`, `caption()`, `signature()`, `certificate()`. Named parameters at the top; no case-specific text, no coordinates, no forced line breaks. |

Markdown contract (frontmatter; the body is blank-line-separated chunks):

- `debtors`: list of `{name, ssn_last4 | ein | tin_last4, aka, fka}`.
- `bankr_no`, `chapter`; `adversary_no` (optional: if present, `plaintiffs` and `defendants` are required and printed).
- `title`: the title of the motion (printed bold, centered, below the caption).
- `movant`, `relief`, `basis` (required): the opening sentence is `<movant> moves the Court for <relief> under <basis>.`
- `signature`: `{date, signer, firm (lines), role}`.
- `certificate` (optional): `{text, signer, firm}`.
- Body: `# Heading` (centered bold); `## Heading` (bold, left); other chunks are unnumbered body paragraphs (first-line indent 0.5 inch); a chunk starting `1. ` is a list.
- `judge` (optional): printed as `Hon. <judge>` in the caption's right column under `Chapter`. `hearing` (optional list of lines): printed under it (e.g. `Hearing Date:`, `Hearing Time:`). Convention (tier 2), not a rule.
- Not supported: tables, footnotes, raw typst. A footnote in the source is printed as its own paragraph directly after the paragraph that carries its marker (the transcription does this).

## Layout

- Letter size; margins 1 inch on every side; body 12 pt EB Garamond, single spaced (0.5 em leading), 12 pt between paragraphs, first-line indent 0.5 inch.
- Caption: three-column grid, as in the adversary-complaint folder.
- Signature: a final body paragraph is kept in the same unbreakable block as the signature block, so the signature never stands alone on a page (convention; found by the overlay review of the transcription).
- Footer: page number, 10 pt, centered.

## Gate 2 review (current PDF)

sha256 of `samples/OUTPUT-northern-beef-packers.pdf`: `d865e31d3bec85be518f1c573fe183b5533201b8fcb915c54e69b5c77afd922b` (re-rendered and re-reviewed 2026-10-15; 9 pages, all 9 viewed as PNG at 60 dpi; same content as the 2026-10-14 render)

Pairing from `samples/OVERLAY-northern-beef-packers.txt` (by text): ours 1 = filed 1; ours 2 = filed 2; ours 3 = filed 5; ours 4 = filed 7; ours 5 = filed 8; ours 6 = filed 10; ours 7 = filed 12; ours 8 = filed 14; ours 9 = filed 15. Word overlap per page: 89%, 56%, 54%, 53%, 63%, 67%, 53%, 72%, 62%. Word overlap is low on most pages because our render is single spaced and the filing is double spaced, so the same words sit on fewer, longer pages; it is a pairing aid, not a score.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | filed p.1 | Caption matches: court name, `In re:`, debtor, TIN last four, `Bankr. No. 13-10118`, `Chapter 11`, `Hon.`, hearing date and time. Title centered bold, seven lines. The generated opening sentence (movant, relief, basis, from the frontmatter, FRBP 9013(b)) is not in the filing, which opens "hereby submits this Memorandum in Support". | PASS for the caption. ACCEPTED: the opening sentence is a rule-driven template element and differs from this filing. |
| 2 | filed p.2 | Preliminary statement and background; `#` headings centered bold. First-line indent comparable. The paragraph gap and line spacing differ (filing is double spaced: see OPEN below). The filing's headings are bold small caps with an underline; the template's are bold caps. | PASS for structure. ACCEPTED: heading style (one filer; not a rule). |
| 3 | filed p.5 | Section headings `##` numbered with a bold run-in title; the body and the citation string set in the template's own justification (left, unjustified, as in the filing). | PASS |
| 4 | filed p.7 | Footnote 1 printed as its own paragraph after its paragraph, with a superscript number. The filing sets it at the foot of the page. | ACCEPTED: the template has no footnote support; the transcription places the note after its paragraph. |
| 5 | filed p.8 | Footnote 2 and point 3 (fee) and point 4 (interest rate); the numbers, amounts and dates match the filing. | PASS |
| 6 | filed p.10 | Footnote 3 after its paragraph; point 5 (`¶ 20(D)`) and point 6 (`¶ 20(E)`), numbers and headings as in the filing. | PASS |
| 7 | filed p.12 | Points 7 to 11. | PASS |
| 8 | filed p.14 | Points 12 to 14 and `CONCLUSION` centered bold, with the WHEREFORE paragraph. The page ends after the conclusion, and the signature moves to page 9 with it (the overlay review found the signature alone on a page; fixed in the template). | PASS |
| 9 | filed p.15 | Conclusion, the date line, signature block at about the middle of the page (the filing's block starts at about the same position as ours), signer, firm, pro hac vice counsel block. Differences in wording: the filing has `Dated: August 7, 2013.` and `Respectfully submitted,` with the entity name `WHITE OAK GLOBAL ADVISORS, LLC` and `By /s/`; the template prints `DATED <date>.` and `/s/ <signer>`, with the role line carrying the party. | PASS for position and content. ACCEPTED: the template's signature wording (the role line names the party). |

Also compared (tier 2, not in the table): the filing's CM/ECF header (`Case: 13-10118 Document: 134 Filed: 08/07/13 Page n of 15`, blue, top of each page) is generated by the court's system on filing, not by the filer's template, so the template does not print it. ACCEPTED.

OPEN (tier 2, decision for David): **line spacing.** The filing is double spaced (checked on page 3 of the PDF). The template is single spaced by a stated choice (README "Layout"). The local rules (Bankr. D.S.D. R. 9004-1 and the full June 2024 text, searched for "spacing" and "double") set no spacing or font size, so double spacing is one filer's choice, not a rule, and one exemplar cannot establish it as a clerk's convention. Changing it would make the render about 15 pages (the filing's length) instead of 9. Not changed here.

## Known gaps and open choices

1. **One filer for tier 2.** The exemplar is one memorandum from one lender's counsel. Layout conventions (double spacing, signature position, title placement, the opening sentence) are judged against that filing alone; tier 3 (matching this filer exactly) is not chased.
2. **Memorandum, not motion.** The filing is a memorandum in support of the debtor's motion (Doc 45); the motion itself is not on RECAP. The template's opening sentence is generated from the frontmatter and does not appear in the filing.
3. **No local Rule 9013 exists.** The brief says "per this court's local bankruptcy rules" for FRBP 9013. The court's June 2024 rules have no Rule 9013. The template follows the rules that do exist (9004-1, 9004-2, 7010-2, 7007-1, 9014-4, 7056-1).
4. **Brief not required.** Bankr. D.S.D. R. 9004-1(f) says a party need not submit a brief with a motion unless a rule or order directs one. Summary judgment (R. 7056-1(b)) is the directed case. The template does not know the motion type; the author decides whether to attach a separate brief.
5. **Font size and spacing.** No local rule sets a size or spacing. 12 pt single-spaced EB Garamond (the only font vendored) is a choice, not a rule. See the OPEN spacing row above.
6. **Caption for an adversary motion** shares its code with `../adversary-complaint/`; the adversary branch is exercised by the code path but not by a sample (the only sample is a main-case motion). A second sample with `adversary_no` would be the test.
7. **Certificate of service.** Its wording is conventional text, not a rule. The filing's certificate is docket Attachment 1, not in the PDF, so this transcription has none.
8. **Check tooling not run.** As in the adversary folder, `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this folder is a doc-type folder.

## Loop log

- Iteration 1: built the template from the rules; rendered a fictional main-case sample. Exemplar search: no usable filing found; BLOCKED.
- Iteration 2 (2026-10-14): new CourtListener search (sdb, RECAP) found *Northern Beef Packers*, Doc 134, a 15-page text-layer memorandum in support of a debtor's motion. Added the judge and hearing lines to the caption (optional frontmatter). Transcribed the filing as `samples/INPUT-northern-beef-packers.md` (replacing the fictional sample). Rendered (9 pages), overlaid, and viewed all 9 pages. Fixed one defect the overlay review exposed: the signature block stood alone on page 9; a final body paragraph now stays with the signature block.
- Iteration 3 (2026-10-15, depth pass): checked the transcription against the exemplar text layer (`pdftotext` of the 15-page filing): every content word of the filing appears in `samples/INPUT-northern-beef-packers.md` except running headers (`district`, `document`, `united`, `dated`) and words split across line ends (`longterm`, `nondefault`, `openended`, `oversecured`). The transcription already carries the full structure (caption, title, headings, footnotes, conclusion, signature block), so no depth was added. Re-rendered (9 pages, typst, no warnings, EB Garamond only embedded) and re-ran the overlay against the filing fetched to a scratch directory (sha256 matches `SOURCE.md`); viewed pages 1 to 9. No template defect found. OPEN spacing item above is unchanged and is for David to decide.
