# lamd: motion-brief

Doc type: **motion-brief**, i.e. the memorandum in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Middle District of Louisiana (`lamd`).
Folder: `courts/fifth-circuit/louisiana/federal/middle-district/motion-brief/`. Court-root `typst/` and `usage/` are not touched.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/FILED-EXAMPLE-motion-brief.pdf` (primary; the sample is transcribed from it) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (second filer, tier-2 comparison only). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: caption, pages 1 to 8 and 17 to 20 of the 20-page memorandum, signature, certificate of service. Pages 9 to 16 are not transcribed (see Known gaps). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages (11 on the earlier EB Garamond render, before fb-595.68), `tools/render.sh`, typst 0.15.0, pinned Times New Roman only (`pdffonts`), no typst warnings |
| overlay | ok: `usage/OVERLAY-first-horizon-motion-to-dismiss.pdf` and `.txt`, run against the First Horizon exemplar (`tools/overlay.sh <dir> first-horizon-motion-to-dismiss usage/FILED-EXAMPLE-motion-brief.pdf`; the default would pick the Carpenter file, which sorts first). The exemplar PDF is not in this snapshot; the overlay ran against a fresh copy from the CourtListener URL in `usage/SOURCE.md` (20 pages, Document 7-1, 02/26/26 stamp, checked) |
| typeface | face required: **none** (LR 10(a)(1): "standard 12-point typeface"). Font: **Times New Roman** (`docs/FONTS.md` rule 6, the house standard where the rule names no face; was EB Garamond before fb-595.68). Fit: n/a. See Known gaps 3 |
| pages reviewed | 11 of 11 on the earlier EB Garamond render (every page rendered at 60 dpi and viewed after the last template change; pages 1 to 9 were not affected by the last change, which touched only the signature column on pages 10 and 11; re-checked on the fonts pass, 2026-10-14, no change to the template) |
| gates | `tools/check.sh` and `tools/check-selftest.sh` not run (same reason as the complaint folder). No `court.json` or stamp written. |

File names follow the tools (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), as in the complaint folder.

## Governing rules

Primary source: M.D. La. Local Civil Rules, "2022 Local Rules" (effective 2022-06-30), https://www.lamd.uscourts.gov/sites/default/files/pdf/2022_Local_Rules_6-30-2022.pdf. Fetched and read 2026-10-14 (text extracted with `pdftotext -layout`). The rules text is the version posted on the court's site; the search showed no later revision, but no later revision was positively ruled out. Fed. R. Civ. P. 10, 11 and 12(b)(6) are cited by number; their text was not re-fetched in this pass.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7(d) | "All contested motions must be accompanied by separate memoranda which must contain a concise statement of reasons supporting the motion and citations of authorities." | The doc type itself: a separately filed memorandum. |
| LR 7(g) | Memoranda limited to **25 pages excluding attachments**. A table of contents, table of authorities and certificate of service are excluded from the limit. Signature blocks may extend beyond the limit. The form complies with LR 10(a). | Not measured by the template (no page counter). The sample is 11 pages, the full exemplar is 20. The author checks the count. |
| LR 10(a)(1) | 8½ × 11 paper, typeface no smaller than standard 12-point, double spaced, margins no less than 1 inch, nothing printed in the margins except page numbers (no less than ½ inch from the bottom); quotations and footnotes may be single spaced. | `margin = 1in`, `type-size = 12pt`, `body-leading = 1.35em` (24 pt pitch), `footer-descent = 0.6in`, `page-footer()`; block quotations single spaced (`>` lines). |
| LR 10(a)(2) | After allotment, the caption shows the initials of the district judge and the magistrate judge. | `civil_action_no` + `judges` in the frontmatter (`3:26-cv-00182-BAJ-EWD`); `judge` and `magistrate` lines. |
| LR 11(a)(1), (3) | Signed by counsel admitted here; counsel's name, address, telephone and fax, email and Attorney Identification Number under the signature. | `signature_lines` (the sample carries them, in the right half of the page). |
| LR 11(a)(2) | Electronic signatures comply with the administrative procedures. | `/s/` lines are set flush in the signature column (`signature-indent`). |
| LR 7.1 | A defendant's initial responsive pleading **or motion filed in lieu of a responsive pleading** must be accompanied by a separately filed, signed certificate of interested persons. | Not produced here (separate filing). The sample's motion is a Rule 12(b)(6) motion, so the certificate applies to the motion, not to this memorandum. |
| Fed. R. Civ. P. 10(a) | Caption with the court name, title of the action, file number, and the title of the paper. | `court-name`, caption, `title`. |
| Fed. R. Civ. P. 12(b)(6) | The memorandum's subject. | `title`: "MEMORANDUM IN SUPPORT OF RULE 12(b)(6) MOTION TO DISMISS". |

## Layout

- Court name bold, centered, two lines; caption with the party column at left (names, "VERSUS" between them), the civil action number and judge lines at right; no rules or column of asterisks (see Tier 2 below).
- Title bold, centered, uppercase, on one line.
- Body: double spaced, first-line indent ½ inch, left aligned (ragged right). No paragraph numbers (a memorandum is not a pleading).
- Headings: level 1 centered bold caps (INTRODUCTION, FACTUAL ALLEGATIONS IN THE COMPLAINT, LAW AND ARGUMENT, CONCLUSION, CERTIFICATE OF SERVICE); level 2 bold at the left margin, with its Roman numeral (`## I. APPLICABLE ...`); level 3 bold, indented ½ inch (`### A. Applicable Legal Standards.`). A heading is kept with the paragraph after it.
- Block quotations (`>` lines): single spaced, indented 1 inch both sides. None in the sample (the exemplar's quotations are run in).
- The signature marker `<!-- signature -->` (an HTML comment, not printed) in the sample marks where the signature block goes: after the conclusion and before the certificate of service. The last paragraph before it is kept on the same page as the signature block, and the signature block is not split across pages. In the exemplar the signature follows the conclusion; this template follows that order.
- Signature block: "Respectfully submitted," and the counsel blocks, single spaced, in the right part of the page (starts 2.5 in from the left margin, wide enough for the longest firm name).
- A `/s/` line in the markdown (a chunk starting with `/s/`) is set flush in the signature column, not indented.
- Page numbers centered in the bottom margin.

## Measured (render)

- Body baseline pitch: 24.0 pt (`pdftotext -bbox`), same as the complaint. Paragraph spacing is set equal to the pitch. With spacing 0, consecutive paragraphs and headings overprinted (found on the first render and fixed; the same fault is in the complaint README).
- Signature column: the first render wrapped "SCHONEKAS EVANS McGOEY & McEACHIN, LLC" inside a fixed-height line and overprinted the next line. Fixed by moving the column to 2.5 in.
- Text area 6.5 × 9 in.

## Overlay (red = ours, blue = filed; pages paired by word overlap)

From `usage/OVERLAY-first-horizon-motion-to-dismiss.txt`:

```
ours p.1  filed p.1   word-overlap 93.7%
ours p.2  filed p.2   word-overlap 70.9%
ours p.3  filed p.4   word-overlap 57.4%
ours p.4  filed p.5   word-overlap 72.8%
ours p.5  filed p.6   word-overlap 83.3%
ours p.6  filed p.7   word-overlap 74.6%
ours p.7  filed p.8   word-overlap 48.9%
ours p.8  filed p.18  word-overlap 86.0%
ours p.9  filed p.19  word-overlap 93.8%
ours p.10 filed p.20  word-overlap 76.2%
ours p.11 filed p.20  word-overlap 24.7%
```

The pairing jumps from filed p.8 to filed p.18 because pages 9 to 16 are not transcribed. Sample pages 8 to 11 pair with the filed pages that carry the same text. The overlay is a diagnostic, not a score. The pairing above and these differences were measured on the earlier EB Garamond render, before fb-595.68. Differences seen: Times New Roman (filed) against EB Garamond (ours then) on every page; the filed memorandum has footnote 1 (not in the sample: footnotes are not supported by the template); the filed header line "Case 3:26-cv-00182-BAJ-EWD / Document 7-1 / Page n of 20" is an ECF stamp, not part of the document, and is not reproduced.

## Gate 2 review (every page of the 11-page EB Garamond render, before fb-595.68, viewed at 60 dpi)

| Page | Exemplar page(s) | Finding | Status |
|---|---|---|---|
| 1 | filed p.1 | court name; caption (FIRST HORIZON CORPORATION, VERSUS, KARL HOEFER and DMMS HOLDINGS, LLC; CIVIL ACTION NO. with BAJ-EWD; judge and magistrate lines); title centered bold; opening paragraph; INTRODUCTION heading. | PASS |
| 2 | filed p.2 | INTRODUCTION paragraph; FACTUAL ALLEGATIONS IN THE COMPLAINT heading (centered bold); facts paragraphs. | PASS |
| 3 | filed p.4 | facts; "FIRST HORIZON'S ATTEMPTED CAUSES OF ACTION" heading; Count I and II paragraphs. | PASS |
| 4 | filed p.5 | Counts II to V; injunctive-relief paragraph; LAW AND ARGUMENT heading. | PASS |
| 5 | filed p.6 | I. heading (bold, left) and the Rule 12(b)(6) standard with citations in italics; quotation paragraphs run in. | PASS |
| 6 | filed p.7 | standard continued; II heading (two lines, bold, left); A. sub-heading indented; Louisiana bad-faith citations. | PASS |
| 7 | filed p.8 | end of A; B. Count I Should Be Dismissed; "2. First Horizon Has Not Stated a Claim Under Spurney." sub-heading (the Roman-numeral section that contains it is on pages 9 to 16, not in the sample). | PASS |
| 8 | filed p.18 | end of Count III; V heading (two lines); A. and B. sub-headings; Count V citations. | PASS |
| 9 | filed p.19 | VI heading; A. and B. sub-headings; short closing paragraph. The lower half of the page is empty: the conclusion and its signature block are kept together and move to page 10. | ACCEPTED: the signature block is kept together with the conclusion (a clerk should not find a signature alone on a page); the empty half-page is the cost. |
| 10 | filed p.20 | CONCLUSION heading and paragraph; "Respectfully submitted,"; both counsel blocks (FLANAGAN PARTNERS LLP; SCHONEKAS EVANS McGOEY & McEACHIN, LLC) in the right part of the page; "Attorneys for ..." lines. | PASS |
| 11 | filed p.20 | CERTIFICATE OF SERVICE heading; certificate paragraph; "/s/Joelle F. Evans" and the typed name in the signature column. | PASS |

## Tier 2 (conventions), against two filers

The two exemplars differ in the caption and the title. The template follows what both show and leaves out what only one shows.

Both exemplars were viewed at 60 dpi on page 1 (Carpenter) or pages 1 and 20 (First Horizon). Carpenter's later pages were not viewed.

| Choice | First Horizon (viewed p.1, p.20) | Carpenter (viewed p.1) | Template |
|---|---|---|---|
| Court name, two lines, centered | yes, **regular weight** | yes, bold | bold: one filer each way, so not a convention; kept as a flagged tier-3 choice |
| Party names left, case number and judge at right | yes | yes | yes (convention) |
| Party designations (PLAINTIFF, DEFENDANTS) | no | yes | no (tier 3) |
| Vertical rule between party and case columns | no | yes | no (tier 3) |
| "VERSUS" / "v." between parties | VERSUS | v. | VERSUS (the sample's own wording; tier 3) |
| Title centered, bold, uppercase | yes, two lines | yes, bold, underlined | yes (bold, centered; no underline: tier 3) |
| Double spacing, first-line indent | yes | yes (not measured at this size) | yes (convention) |
| Section headings centered | yes (INTRODUCTION, FACTUAL ALLEGATIONS, CONCLUSION) | not checked | yes (as in the complaint) |
| Counsel blocks at signature | **two columns side by side**, `/s/` lines italic and underlined | not checked | **stacked** in the right part of the page: an open choice, not a convention from two filers |

Open for the tier-2 decision: the side-by-side counsel columns (First Horizon) against stacked blocks (template). The second-filer comparison does not settle it because Carpenter's signature page was not viewed. The heading underline seen in the First Horizon exemplar is not reproduced; it could not be confirmed at 60 dpi, so it is not claimed as a convention.

## Known gaps and open choices

1. **Pages 9 to 16 not transcribed.** The brief's sample target is 8 to 14 rendered pages; the full memorandum is 20 pages and would render longer. Pages 1 to 8 and 17 to 20 carry the caption, introduction, facts, the standard, Count I and the conclusion. The sample's "2. First Horizon Has Not Stated a Claim Under Spurney" sub-heading therefore appears without the Roman-numeral section (III or IV) it belongs to. Transcribing pages 9 to 16 would add about 8 rendered pages.
2. **Footnote 1 dropped** (page 3 of the exemplar). The template does not render footnotes (LR 10(a)(1) allows 10-point footnotes; not implemented).
3. **Font.** As in the complaint folder, LR 10(a)(1) names no face ("standard 12-point typeface"). The fonts pass (2026-10-14) kept EB Garamond; the template is now Times New Roman, the house standard where the rule names no face (`docs/FONTS.md` rule 6, 2026-10-17). The exemplars are Times New Roman (First Horizon) and Century Schoolbook (Carpenter): filer choices, not rule requirements; tier 3, not chased. `pdffonts` on the render: Times New Roman Regular, Bold and Italic only, embedded.
4. **Second structurally different sample not made** (EVAL-LOOP Gate 3). Not done.
5. **25-page limit (LR 7(g))** is not measured. The template has no page counter; a count of the full memorandum must be made by the author, excluding attachments and the table of contents and authorities.
6. **Certificate of interested persons (LR 7.1)** is separate. Not produced.
7. **Heading styles** (level 2 bold at left; level 3 bold indented ½ inch) are the template's choice. The First Horizon headings may carry an underline; that was not confirmed at 60 dpi and the template does not underline. Tier-2 open choice for David.
8. **Ragged right.** Justification not read from the exemplar.
9. **Gate scripts not run** (`tools/check.sh` needs `court.json` and `rules.md`, which this doc-type folder does not have). The Gate 2 table above is the review record.

## Engines

### docx (`docx/`)

Files: `docx/reference.xml` (`base="xengine"`: `fb render --engine docx` builds the reference document from it, the shared cross-engine recipe in the typst template's face) and `docx/lamd-motion-brief.lua` (the cover, caption table, title, signature block at the `<!-- signature -->` (an HTML comment, not printed) marker, the `/s/` lines in the signature column and the block quotes, built as `typst/lamd-motion-brief.typ` does). `tools/render.sh --engine docx` (a wrapper of `fb render --engine docx`) writes `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice 26.2, headless). Word was not run here.

- Matches the typst form: Times New Roman 12 pt, Regular, Bold and Italic (`pdffonts` on the `.docx.pdf`: embedded, no theme or system face in the Latin text), exact 24 pt line pitch, double spaced body with a 0.5 in first-line indent and no space between paragraphs (as the typst render), 1 in margins, letter, centered PAGE number 0.6 in from the bottom edge, caption and title as in typst, section headings as typst (centered caps, bold left, bold indented), the signature block single spaced at 2.5 in with the conclusion kept on its page, the certificate after it. 12 pages, as the typst render (11 on the earlier EB Garamond render).
- Differs from typst (on the earlier EB Garamond render, then built by `docx/build-reference.sh`, since retired into fb render): the typst headings have 6.5 pt of space above and below; the docx headings have none. With that space LibreOffice paginates this sample to 12 pages (one body line fewer per page), so the space was dropped to keep the 11-page pagination. Headings sit tight to the text. The block quotes are single spaced at 1 in on both sides as in typst (none in the sample). Footnotes are not in the sample and not in the template (same as the typst folder).
- BLOCKED: none known for tier 1 (font, size, spacing, margins, page numbers, caption, headings, signature block). The 25-page limit (LR 7(g)) is not measured by the template in either engine.
- Gates: `tools/check.sh <court-dir> --engine docx` could not run on this folder (it needs `court.json` and `checks.yaml` at the court root; this snapshot has no `checks.yaml`). Gate results are not recorded here; the page review is in the PR description.
