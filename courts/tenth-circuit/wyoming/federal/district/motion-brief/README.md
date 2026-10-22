# District of Wyoming (wyd): motion brief (memorandum in support of a dispositive motion)

- Court: `wyd`, United States District Court for the District of Wyoming (`courts/tenth-circuit/wyoming/federal/district/`)
- Doc type: `motion-brief`. A memorandum in support of a dispositive motion (Fed. R. Civ. P. 12(b)(6), 12(b)(7) and 19), filed with the motion itself as a separate document.
- Exemplar: `usage/FILED-EXAMPLE-motion-brief-2.pdf` (*Elizondo v. Alger*, No. 1:26-cv-00263-SWS, Document 8, filed 2026-10-05, 12 pages; provenance in `usage/SOURCE.md`). One filer (defendant's counsel). The motion (Document 7) is not in the exemplar, so the sample is the memorandum only.
- Samples: `usage/INPUT-motion-brief-2.md` (transcription of the whole memorandum from the introduction through the conclusion, with the signature block and certificate of service in the frontmatter, typographic apostrophes as filed) and `usage/INPUT-motion-brief.md` (the same memorandum with straight apostrophes, an explicit caption `separator` and the persons served only in the service list).
- Status: typst and docx on the shared cross-engine layout model (fb-595.68.33): Times New Roman 12 pt on both engines, the docx breaks every line and page where the typst render does (XENG-001..003 PASS on both samples, `params.cross_engine: gate` in `eval.yaml`); `sh tools/check.sh <this folder>` typst 18 and `--engine docx` 26 checks passed, 0 failed. Every page of both renders of both samples viewed (9 + 9 per sample). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `wyd-motion-brief`. |
| `typst/wyd-motion-brief.typ` | Template. Parameter block at the top: Times New Roman 12 pt, exact 24 pt double pitch (`pitch-body`) and 13.8 pt single lines (`pitch-single`), one-inch margins, 8½ × 11, `page-limit = 25`; `lib/typst/xengine.typ` sets the shared layout model. |
| `docx/reference.xml` | The Word styles, declarative: the cross-engine recipe (`base="xengine"`) in the typst face (`{font}`), 12 pt, 480/276 twip line boxes, the page-number footer. `fb render` builds the reference document from it. |
| `docx/wyd.lua` | Builds the whole document as Word paragraphs from the frontmatter (as written, `$FORMBOOK_META`) and the sample body read chunk by chunk, as the typst template reads it; `lib/docx/xengine.lua` for the runs and paragraph spacing. |
| `eval.yaml` | `params.cross_engine: gate`. |
| `usage/INPUT-motion-brief.md`, `usage/INPUT-motion-brief-2.md` | Markdown contract samples (frontmatter: caption, attorney block, `dated`, signature, certificate; body: `#` headings, paragraphs, a numbered conclusion). |
| `usage/OUTPUT-motion-brief[-2].typst.pdf`, `.docx`, `.docx.pdf` | `sh tools/check.sh <this folder>` and `--engine docx` (9 pages each, no typst warnings). |
| `usage/FILED-EXAMPLE-motion-brief-2.pdf`, `usage/SOURCE.md` | The filed exemplar and where it came from. |

Overlays are not committed: `just overlay <this folder>` writes `.overlay/<this folder>/OVERLAY-motion-brief-2.pdf` and `.txt`.

## Governing rules

Primary sources, read 2026-10-14:

- D. Wyo. Local Civil Rule 7.1(b)(2)(A)–(B) (briefs for dispositive motions; "Briefs in support of and in opposition to all dispositive motions are limited to twenty-five (25) pages"), and 7.1(b)(1)(C) (the ten-page limit that applies to non-dispositive motions, not to this brief): <https://www.wyd.uscourts.gov/sites/wyd/files/local_rules/localrules-cv22.pdf>, the Civil Local Rules, January 2022 edition, printed pp. 8–9 (text extracted with `pdftotext`). The court's current-rules web page returned 404 on the day of review, so this January 2022 edition is the newest text retrieved; the May 2017 edition is superseded.
- D. Wyo. Local Civil Rule 10.1(a) (filing format: typed, double spaced, single-sided, 8½ × 11, one-inch margin on all sides, not less than 12 point) and 10.1(b) (caption per Fed. R. Civ. P. 10(a) plus the attorney information block): same edition, printed p. 12.
- Fed. R. Civ. P. 10(a) (caption) and 5(d)(1)(B) ("No certificate of service is required when a paper is served by filing it with the court's electronic-filing system"; <https://www.law.cornell.edu/rules/frcp/rule_5>, fetched 2026-10-14). See the certificate note under Known gaps.

The page limit is enforced in the template: `wyd-motion-brief.typ` asserts that the render is at most 25 pages (LR 7.1(b)(2)(B)), so a brief over the limit fails the render, not just the review. The exemplar is 12 pages and the sample renders to 9.

## Typeface

| Face required by the rule | Rule (primary source) | Vendored face | Fit |
|---|---|---|---|
| None named. LR 10.1(a) requires only "not less than 12 point font" | D. Wyo. LR 10.1(a), January 2022 edition (see Governing rules) | Times New Roman (`fonts/`), declared `("Times New Roman", "Liberation Serif")` | n/a |

The rule names no face, so the template sets Times New Roman 12 pt, the house standard (`docs/FONTS.md`), on both engines; `data/exemplar-fonts.json` carries `template_face: Times New Roman` for this folder. The typst template had set TeX Gyre Schola (the exemplar's Century Schoolbook is that filer's style, tier 3) and the docx EB Garamond 13 pt (DEF-FONT-002 failed on the docx).

## Layout (typst and docx alike)

- Shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; `docs/EVAL-LOOP.md`, "Cross-engine gate"): first-fit ragged-right lines, no kerning, ligatures or hyphenation, every line an exact box of its pitch. Word twips = 20 × the typst points.
- Double spacing (LR 10.1(a)): the title, headings, paragraphs, the relief items and the certificate's statement in exact 24 pt line boxes, no extra space between paragraphs (the filed brief is double spaced throughout, headings included). Single-spaced 13.8 pt lines for the attorney block, the court name, the caption, the signature block and the service list.
- Attorney information block (LR 10.1(b)) at the top: one column per firm group, 0.3 in apart.
- Court name two centered bold lines 18 pt below it; the caption 18 pt below that: the party column (3.1 in; designations indented 1 in, as in the filed exemplar), a 0.35 in column of ")" marks (one per caption line), "Case No." level with the separator ("v.", or the frontmatter's `caption.separator`). One row per caption line.
- Title centered, bold capitals, 18 pt below the caption, kept with the body; the body 12 pt below it.
- Headings bold, 12 pt above (dropped at the top of a page), kept with the text after them: "I." at the margin in a 0.5 in box, "A." at 0.5 in in a 0.4 in box, the lines hanging after the box, as in the filed exemplar; any other heading ("CONCLUSION") centered.
- Paragraphs with a 0.5 in first-line indent, not numbered. A markdown numbered list keeps its numbers: the number in a 0.35 in box after the 0.5 in indent, the lines hanging at 0.85 in.
- Signature block 24 pt below the last chunk (kept with it, kept on one page): the `dated` line as written, then from 2.5 in "Respectfully submitted,", the "/s/" line and the signer's lines, the role, two blank single lines between the groups.
- Certificate of service 24 pt below, kept on one page: the centered bold heading, the statement (0.5 in first-line indent), the persons served (0.5 in in), the "/s/" line from 2.5 in.
- Page number centered at the foot, 12 pt, in a single-pitch line box ending 0.5 in above the page edge (docx: footer 720 twips).
- LR 7.1(b)(2)(B): the typst template asserts at most 25 pages (the render fails beyond); the docx has no such assertion, but it sets the same pages (XENG-001).

## Page review (Gate 2)

Every page of `OUTPUT-motion-brief.typst.pdf`, `OUTPUT-motion-brief.docx.pdf`, `OUTPUT-motion-brief-2.typst.pdf` and `OUTPUT-motion-brief-2.docx.pdf` was rendered at 50 dpi and viewed side by side (9 of 9 each, fb-595.68.33). The two engines set every page alike (XENG-001..003 PASS: 229/229 and 231/231 lines, 9 = 9 pages). The two samples break the same pages; the content below holds for both.

| Page | Content | Result |
|---|---|---|
| 1 | Attorney block, court name, caption with the designations indented and "Case No." level with "v.", title (two lines), I. INTRODUCTION, first two paragraphs | OK. Sample 2's attorney block carries "Attorney for Defendant" as its sixth line. |
| 2 | I. (end), II. FACTUAL AND PROCEDURAL BACKGROUND, III. LEGAL STANDARD | OK. |
| 3 | III. (cont.), IV. ARGUMENT, heading A (two lines, hanging), Argument A | OK. |
| 4 | Argument A (cont.) | OK. |
| 5 | Heading B, Argument B | OK. |
| 6 | Heading C, Argument C | OK. |
| 7 | Heading D, Argument D | OK. |
| 8 | Heading E, Argument E, CONCLUSION (centered), relief items 1–4 | OK. |
| 9 | Relief item 5, "DATED" line, signature block, CERTIFICATE OF SERVICE, statement, service list, "/s/" line | OK. The last item is kept with the signature block; the certificate shares the page. |

Tier-2 findings (OPEN or ACCEPTED):

- p.1 ACCEPTED: the exemplar has no attorney information block on page 1. LR 10.1(b) requires one, so the template includes it at the top left; the content is the signature block's (name, bar number, address, telephone, email). This is a rule-driven deviation from the filed page.
- p.1 ACCEPTED: the typeface is Times New Roman where the filed brief uses Century Schoolbook (per the `pdffonts` run in `usage/SOURCE.md`); the rule names no face, and the second candidate filer (*Redington*, `usage/SOURCE.md`) uses Times New Roman.
- p.1–9 ACCEPTED: the filed brief's footer carries a short title, the case name and the case number under the page number; the template prints the page number only, as the complaint template does.
- p.1 OPEN (cosmetic): the filed brief bolds some statutory citations in the introduction (e.g. "Wyo. Stat. § 17-29-104(a) (2017)", filed p. 1). The transcription does not reproduce that emphasis, because the text layer does not show it.

## Known gaps

1. Second filer. The brief asks for two or three exemplars from different filers for tier 2. Only *Elizondo* (defendant's counsel) is saved. A second D. Wyo. memorandum, *Redington v. dGEN Energy Partners Inc.*, 1:26-cv-00213-KHR, Document 16 (12(b)(6) memorandum, 17 pages), was found in the RECAP search results and is the candidate for the second filer; it has not been downloaded. Tier 2 is judged against one filer until it is.
2. Italics. The text layer does not carry font style. Case names are italicized by convention, not checked glyph by glyph against the filed page. The rendered pages show them italic.
3. Certificate of service. The rules do not require one for ECF service (Fed. R. Civ. P. 5(d)(1)(B)); the template includes it because the filed exemplar does. A sample without a `certificate` block renders without one.
4. Local rule edition. The rules are the January 2022 edition (see Governing rules). A newer edition, if any, has not been checked.

## Engines

- **typst** (primary, `typst/`): the reference for the form and for the other engine's breaks.
- **docx** (`docx/`): `docx/reference.xml` and `docx/wyd.lua` (no shell, no committed `reference.docx`; `docs/DOCX.md`, "The docx template without shell"). `sh tools/check.sh <this folder> --engine docx`: 26 checks passed, 0 failed, XENG-001..003 PASS on both samples (gated). The relief items are typed numbers with a tab, not Word list numbering; the attorney block and caption are borderless fixed-width tables.
- **latex**: none for this doc type.
