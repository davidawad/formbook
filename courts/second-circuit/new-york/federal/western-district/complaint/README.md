# nywd: complaint

Doc type: **complaint** in the United States District Court for the Western District of New York (`nywd`).
Folder: `courts/second-circuit/new-york/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nywd-complaint-kerrick626cv06006.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nywd-complaint-kerrick.md` (the whole complaint text, from the text layer; see Known gaps) |
| render | ok: `usage/OUTPUT-nywd-complaint-kerrick.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-kerrick-complaint.pdf` and `usage/OVERLAY-kerrick-complaint.txt` (`tools/overlay.sh`) |
| pages reviewed | 9 of 9 rendered at 60 dpi and viewed (pages 2, 3, 4 and 6 were viewed before the caption-width and emphasis-escape fixes; neither touches those pages, which have no caption or emphasis; see the review below) |

## Governing rules

Primary sources, fetched 2026-10-14:

- W.D.N.Y. Local Civil Rules (2025 edition, "2025 Local Rules of Civil Procedure FINAL - v3-1.pdf"), https://www.nywd.uscourts.gov/sites/nywd/files/2025%20Local%20Rules%20of%20Civil%20Procedure%20FINAL%20-%20v3-1.pdf. This is the edition the court's rules page lists (https://www.nywd.uscourts.gov/rules-individual-local-federal); no later edition was found on that page on the fetch date. Rules 3, 5.1 and 10 are used here.
- Fed. R. Civ. P. 8, 10, 11 and 38, from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp/rule_8, `rule_10`), fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. Civ. P. 10(a)(1) | All text and footnotes at least 12-point type. | `type-size = 12pt` everywhere (the footer page number is the same size). |
| L.R. Civ. P. 10(a)(2) | Text in the body double-spaced; block quotations and footnotes may be single-spaced. | `body-leading = 1.35em` with paragraph spacing of the same amount, so each line and each paragraph break sits on a 24 pt pitch at 12 pt. Block quotations single-spaced (none in this doc type). |
| L.R. Civ. P. 10(a)(3) | Footnotes and block quotes may not circumvent page limits. | No footnotes are supported by the template. |
| L.R. Civ. P. 10(a)(4) | At least one-inch margins on all four sides. | `margin = 1in`. |
| L.R. Civ. P. 10(a)(5) | Pages consecutively numbered. | Arabic page numbers, centered in the footer, from page 1 (the cover is page 1). |
| L.R. Civ. P. 3 | A civil cover sheet (JS-44) is submitted with every complaint. | Not produced (a separate filing; see Known gaps). |
| L.R. Civ. P. 5.1(a) | ECF filing. | The template is for ECF. The paper-filing requirements of Rule 10(b) (white 8½ × 11 paper, single-sided, original signature) are not asserted. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | Court title (two centered lines), caption box with the parties, title `COMPLAINT`, `Civil Action No.` line (the file number, filled in by the clerk). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | Every body paragraph is numbered by the template (1, 2, ...). Headings, the lead-in, party lines and the prayer are not numbered. |
| Fed. R. Civ. P. 8(a) | Short plain statement of the grounds for jurisdiction, of the claim, and a demand for relief. | Content only (the sample has a jurisdiction section and a relief section). Not checked by the template. |
| Fed. R. Civ. P. 11(a) | Signer's name, address, telephone number and email on the paper. | Signature block: firm, `By:`, signer, address, telephone, email, attorney line. |
| Fed. R. Civ. P. 38(b) | Jury demand. | `jury_demand: true` puts `JURY TRIAL DEMANDED` in the caption (the exemplar's convention, tier 2) and the demand is a body paragraph. |

Court-mandated (tier 1): the type size, double spacing, margins, page numbers, caption, numbered paragraphs and signature block. Convention (tier 2): the caption box, the lettered sub-items, the prayer list, the caption legend.

## Layout

- Cover (page 1): court title, caption box (parties left, title and `Civil Action No.` right), jury legend, then the unnumbered lead-in.
- Body: `#` headings are centered bold capitals (PARTIES, JURISDICTION, FACTUAL BACKGROUND, the cause headings, REQUESTS FOR RELIEF, DEMAND FOR JURY TRIAL); `##` is the centered bold subtitle of a cause of action. Numbered paragraphs are numbered in the template. A `::` prefix marks an unnumbered paragraph. A `1.` list is lettered (a), (b).
- Signature block after the jury demand: `Dated:` at left, firm and signer at right, kept together on one page.

Markdown contract for samples: YAML frontmatter (`case_number`, `caption.parties` (names are joined and wrapped in the box), `title`, `jury_demand`, `lead_in`, `date`, `signature` with `firm`, `by`, `signer`, `lines`), then the body. Blank lines separate blocks. List items must be contiguous (no blank line between `1.` and `2.`). `*text*` is italic; a literal star is written `\*`. Paragraph numbers are not written in the text.

## Overlay

`usage/OVERLAY-kerrick-complaint.pdf`: red is our render only, blue is the filed exemplar only, black is both. Pages are paired by shared words (`usage/OVERLAY-kerrick-complaint.txt`): ours 1–9 pair with filed 1, 2, 4, 5, 6, 7, 7, 9, 10. The pairing is by text, so it is a diagnostic and not a score. Filed pages 3 and 8 are not paired with any sample page, so they do not appear in the overlay.

## Known gaps and open choices

1. **Only one filer.** The brief asks for one exemplar per doc type. Kerrick v. Town of Gorham is the only complaint in this court that was checked for text and layout; tier 2 is judged against this one filer only.
2. **Font.** The rules name no typeface. The template uses EB Garamond (vendored; the only family in `fonts/`). At 12 pt it is smaller to the eye than the Times-family exemplar, so the text looks lighter. Meets the rule as written.
3. **Civil cover sheet (JS-44)** and the summons are separate filings and are not produced.
4. **Caption box.** The box is closed by a rule (right and bottom), not the column of ")" marks some filers use. Tier 2, not asserted.
5. **Keep-together.** The signature block is kept together and moves to its own page (page 9) in this render. A party line (`Defendant Town of Gorham`) can end a page (page 7). Layout only; not corrected.
6. **Transcription.** The sample text comes from the exemplar's text layer with the ECF header, page furniture and paragraph numbers removed; the template renumbers the paragraphs (1 to 66, the same numbers the filed complaint uses). Party lines and the prayer were rewritten as the template expects (the prayer's `A.` to `D.` are now a numbered list).
7. **Rule version.** The rules are the 2025 edition from the court's site. A later edition could change the Local Rule 10 wording; re-check before relying on this folder.

## Review of the rendered pages (Gate 2)

Every page was rendered with `pdftoppm -r 60` and viewed.

- Page 1: court title, caption box with the parties and `COMPLAINT`, `Civil Action No.`, `JURY TRIAL DEMANDED`; lead-in; PARTIES; paragraphs 1 to 7. Pass.
- Page 2: paragraphs 8 to 17 with JURISDICTION and FACTUAL BACKGROUND headings. Pass.
- Page 3: paragraphs 18 to 28. Pass.
- Page 4: paragraphs 29 to 37; cause heading and subtitle centered; both party lines. Pass.
- Page 5: paragraphs 38 to 47; the lettered sub-items (a), (b), (c) of paragraph 39. Pass (the first render lettered every item (a); fixed by making the sample's list contiguous).
- Page 6: paragraphs 48 to 55; SECOND CAUSE OF ACTION heading and subtitle. Pass.
- Page 7: paragraphs 56 to 62; THIRD CAUSE OF ACTION heading; `Defendant Town of Gorham` at the foot of the page (open, gap 5).
- Page 8: paragraphs 63 to 66; REQUESTS FOR RELIEF with the lettered prayer items (a) to (d); DEMAND FOR JURY TRIAL. Pass.
- Page 9: `Dated: January 5, 2026` and the signature block alone (open, gap 5). Pass for content.

## Rebuild

From the repo root, with the toolchain on PATH (see the brief's install lines):

```sh
sh tools/render.sh courts/second-circuit/new-york/federal/western-district/complaint usage/INPUT-nywd-complaint-kerrick.md
sh tools/overlay.sh courts/second-circuit/new-york/federal/western-district/complaint kerrick-complaint
```

`tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads it and writes `OVERLAY-<id>.pdf/.txt`. This folder keeps the names in the brief, so after the overlay run: `mv usage/OUTPUT-<id>.pdf usage/<id>.pdf`, `mv usage/OVERLAY-<id>.pdf usage/<id>-overlay.pdf`, `mv usage/OVERLAY-<id>.txt usage/<id>-overlay.txt`.

## Engines

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` (EB Garamond 12 pt, exact 24 pt body pitch, 15.6 pt single lines, 1 in margins, centered page-number footer); `docx/nywd-complaint.lua` builds the caption, the numbered paragraphs (number, tab, text), the lettered items, the unnumbered paragraphs (`::`) and the signature block as Word paragraphs and tables. Output: `usage/OUTPUT-nywd-complaint-kerrick.docx` and `usage/OUTPUT-nywd-complaint-kerrick.docx.pdf` (LibreOffice; converts with no error; 9 pages).

- Matches typst: page size and margins, font and size, double spacing, paragraph numbering 1 to 66, lettered items, caption layout (court title, parties box with rules, title and `Civil Action No.`, jury legend), signature block, centered page numbers. Pagination matches the typst render page for page (each page starts with the same paragraph in both).
- Differs: the number is followed by a tab to 1 in (typst: a 0.5 em gap); the space above the signature block and the caption is a few points different where a page starts with it; Word and LibreOffice place text in exact-height lines a few points lower than typst does.
- Pages looked at: all 9 pages of `usage/OUTPUT-nywd-complaint-kerrick.docx.pdf`, side by side with the typst render at 60 dpi.
- BLOCKED: `tools/check.sh --engine docx` cannot run for this folder: there is no `checks.yaml` (and no `court.json` at the doc-type level), so every Gate 0 to 3 check ID is BLOCKED, not passed. No stamp is written.
