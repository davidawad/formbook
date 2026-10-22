# Motion brief (memorandum of law in support of a motion): U.S. Bankruptcy Court, N.D. Illinois (`ilnb`)

Doc type `motion-brief`: the memorandum of law that accompanies a motion under Fed. R. Bankr. P. 9013 (written motion, grounds stated with particularity). The motion itself, the notice of motion and the proposed order are separate filings and are not generated. Folder of the court: [`bankruptcy-northern-district`](../README.md).

## Status

- Exemplar: yes, one filer (American Honda Finance Corporation, *In re Martin*, Case 20-10454, filed 2021-01-08, 13 pp.). See `usage/SOURCE.md`.
- Render: ok (`sh tools/render.sh <this dir> usage/INPUT-motion-brief.md`, 13 pages, no typst warnings, Times New Roman only; docx 13 pages, the same breaks).
- Overlay: ok (`sh tools/overlay.sh <this dir> honda-707-memorandum`, `usage/OVERLAY-honda-707-memorandum.pdf` and `.txt`).
- Pages reviewed: 13 of 13 on both engines (every page of `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf` rendered at 50 dpi and looked at, after the cross-engine port, fb-595.68.27).
- Second filer: not collected.

## Governing rules

Verified 2026-10-14. Rule text quoted from the sources; the court's local rules are the version "As amended, Effective September 1, 2024" (newest found; check ilnb.uscourts.gov before filing).

| ID | Source | Requirement | How the template meets it |
|---|---|---|---|
| ILNB-CAP-001 | Fed. R. Bankr. P. 9004(b) (<https://www.law.cornell.edu/rules/frbp/rule_9004>) | A document filed must contain a caption with the court's name, the case's title, the case number and a brief designation of the document's character. | Court name, title block, debtor, case number, descriptive title. |
| ILNB-CAP-002 | N.D. Ill. Bankr. L.R. 5005-2(C)(5) (<https://www.ilnb.uscourts.gov/sites/ilnb/files/Local-Rules-9-1-2024.pdf>, p. 20) | "The first page must contain at the top the case caption with the number of the case or proceeding, the chapter of the bankruptcy case, the name of the assigned judge, and a descriptive title." | Chapter, case number, judge (`caption.judge`), title. |
| ILNB-CAP-003 | LBR 5005-1(C) (same PDF, p. 18) | "The caption of each document must identify the division of the court to which the case is assigned." | "EASTERN DIVISION" from `division` in the frontmatter. The Honda exemplar does not show a division line; the rule requires one. |
| ILNB-FORM-002 | LBR 5005-2(C)(2) | "Typed documents must be double-spaced, and the font must be at least 12 points." | Times New Roman 12 pt, footnotes included (see Decisions). |
| ILNB-FORM-003 | LBR 5005-2(C)(2) | Double spacing. | 27.6 pt baseline pitch (Word's double line at 12 pt, as in the filed memorandum); caption, headings, quotations, footnotes and signature single (13.8 pt). |
| ILNB-FORM-004 | LBR 5005-2(C)(3) | "Margins (top, bottom, right, and left) must be no less than one inch." | 1 in on all sides. |
| ILNB-FORM-005 | LBR 5005-2(C)(4) | "Pages must be consecutively numbered." | Arabic page number, bottom centre, from page 1. |
| ILNB-FORM-006 | LBR 5005-2(C)(11) | Paper: "on 8½x11-inch white paper". | US Letter. |
| ILNB-LIMIT-001 | LBR 5005-2(D) (same PDF, p. 20) | "No motion, objection, application, brief, memorandum, response, or reply may exceed 15 pages without leave of court." | Every page counts (caption and signature pages included). The template asserts `counter(page).final() <= 15` and the build fails otherwise. `eval.yaml` sets `page_limit: 15`, so DEF-LEN-001 checks it on every engine. Honda's memorandum is 13 pages. |
| ILNB-SIG-001 | LBR 5005-2(C)(6) | "The last page must contain the name, mailing address, email address, and telephone number of the attorney signing the document." | `signature.counsel` block at the end. |
| ILNB-SIG-002 | LBR 5005-2(C)(9) | Electronic signature per the Administrative Procedures. | "/s/ Name" and "One of Its Attorneys" from `signature`. |
| ILNB-HEAD-001 | Layout choice | (none) | Headings: level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a."; bold; hanging. Never the last line of a page. |
| ILNB-MOT-001 | Fed. R. Bankr. P. 9013(b) (<https://www.law.cornell.edu/rules/frbp/rule_9013>) | "A motion must state its grounds with particularity and set forth the relief or order requested." | Content of the memorandum; not a template check. |
| ILNB-MOT-002 | LBR 9013-1(B), (C) (same PDF, pp. 33-34) | The motion's title follows the CM/ECF event; the notice of motion (Local Form G-3), exhibits, proof of service and proposed order accompany the motion. | Separate documents; see Known gaps. |
| ILNB-BRIEF-001 | LBR 9014-1(B) (same PDF, p. 37) | "Failure to file when due a memorandum in support of ... a motion waives the right to file the memorandum." | Timeliness; not a template check. |

## What the overlay shows

`usage/OVERLAY-honda-707-memorandum.pdf`: red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words (`usage/OVERLAY-honda-707-memorandum.txt`):

```
ours p.1  filed p.1  word-overlap 91.6%
ours p.2  filed p.2  word-overlap 83.6%
ours p.3  filed p.3  word-overlap 73.5%
ours p.4  filed p.4  word-overlap 57.3%
ours p.5  filed p.5  word-overlap 48.0%
ours p.6  filed p.7  word-overlap 47.3%
ours p.7  filed p.8  word-overlap 64.2%
ours p.8  filed p.9  word-overlap 78.6%
ours p.9  filed p.10  word-overlap 70.8%
ours p.10  filed p.11  word-overlap 69.5%
ours p.11  filed p.12  word-overlap 85.3%
ours p.12  filed p.13  word-overlap 88.0%
```

Pages 1 to 5 pair one to one. From page 6 our pages pair one page later: the filed copy's one extra page falls between our pages 5 and 6. The lowest overlap (ours p.4 and p.5) is where the heading wording and the italicized case names differ most from the filed text. The overlay is a diagnostic, not a score.

## Decisions (left open by the rules, or interpreted)

- **Font: Times New Roman, 12 pt** (vendored), on every engine. The rule requires at least 12 pt; the filed memorandum is Times New Roman. Was EB Garamond 13 pt before the cross-engine port (fb-595.68.27).
- **Footnotes, block quotations and the caption are single spaced.** LBR 5005-2(C)(2) says "typed documents must be double-spaced" with no exemption. The filed exemplar single-spaces its footnotes. **Literal-reading question for David**: if footnotes must be double spaced, change the footnote rule in `typst/ilnb-motion-brief.typ`.
- **Headings.** The rules set no heading style. The template generates the numerals ("I.", "A.", "1.", "a.") from the heading level, as the exemplar does by hand. Level-1 headings are typed in capitals in the markdown (the exemplar's style); the template does not uppercase them because `upper()` cannot take italic case names.
- **Signature block** follows the exemplar: "Respectfully submitted," the party, "/s/" and "One of Its Attorneys", then counsel. "Dated" sits at the margin on the line of "Respectfully submitted,"; the block is kept together on one page.
- **No table of contents or table of authorities.** The exemplar has none; the memorandum is under 15 pages. Not generated.

## Known gaps

- Motion (LBR 9013-1(B)), notice of motion on Local Form G-3 (LBR 9013-1(C)(1)), proposed fillable order (LBR 9013-1(C)(5)), exhibits (C)(2), and proof of service (C)(3) are separate documents and are not generated. The Honda exemplar is the memorandum only.
- The exemplar's "DRAFT 1-4-20" legend on page 1 is the filer's draft stamp; it is not reproduced.
- Exhibits are referred to, not produced.
- No second filer (Tier 2 needs 2 or 3 filers for this doc type).
- The sample transcribes the full 13-page exemplar. Typos in the exemplar are kept in the body ("could paid", "lasted visited", "have never exceed", "is much less most months", "did not schedules"); the heading typo "BANKRUTPCY" is corrected in the sample.

## Searches tried

- CourtListener RECAP search (`type=rd`, court `ilnb`) for "memorandum in support" and "memorandum of law in support" with motion terms. Hits with archived PDFs included 1518363 (Honda, used), 1518094 (Memorandum of Law in Support of MSJ, 6 pp., not used), 1470904 (Memorandum of Law in Support of MSJ, 19 pp., not used). Many memoranda in the results had no archived PDF (`filepath_local` null).
- Rate limit 5 requests/minute on the API; searches were paced.

## Review log

- Render 1: headings rendered larger than body text (typst default heading size). Fixed: heading text set to body size.
- Render 1: the level label ("I.") sat outside the sized text; fixed.
- Render 2: the Honda sample's section headings were in title case; changed to capitals as in the exemplar.
- Render 3: paragraph spacing was zero, so paragraphs sat 17 pt apart instead of 24 pt; paragraph spacing is now the body leading.
- Final pass: all 12 pages of the final render viewed; body pitch 24 pt within and between paragraphs (measured on page 2); no open defects beyond the Decisions above.
- Cross-engine port (fb-595.68.27): Times New Roman 12 pt, 27.6 pt double pitch as filed (13 pages, as filed; was 12 at 24 pt), single 13.8 pt lines; heading labels bold, as filed. All 13 pages of both renders viewed: caption, title, headings, footnotes and signature look as intended; no open defects beyond the Decisions above.

## Engines

Typst is the reference; the docx engine follows the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate") and breaks every line and page as typst does (`params.cross_engine: gate` in `eval.yaml`).

- **typst** (`typst/ilnb-motion-brief.typ`): pitches, not leadings: 27.6 pt body lines, 13.8 pt single lines, a single line (13.8 pt) around headings and quotations and between the caption's and the signature's groups, a double line (27.6 pt) around the caption and the title and before the signature; footnotes 12 pt in 13.8 pt lines, 7 pt apart, 12.6 pt clearance.
- **docx** (`docx/reference.xml`, `base="xengine"` with the pitches in twips and `{font}`; `docx/ilnb-motion-brief.lua`): no shell, no committed `reference.docx` (`fb render` builds it). The filter writes the court lines, caption table (the party column ruled on the right and bottom), title, headings (label, tab, hanging text, an outline level), quotations and signature with `xe.spacing` in the typst pitches; pandoc writes the body paragraphs (Body Text) with their footnotes.
- **Checks** (`fb check`): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (13 pages, 310/310 lines); DEF-LEN-001 13 of 15 pages.
- **latex**: no latex template in this folder.
