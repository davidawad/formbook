# waeb: motion-brief

Doc type: **motion with memorandum of authorities** (motion plus supporting memorandum, filed in an adversary proceeding or a bankruptcy case) in the United States Bankruptcy Court, Eastern District of Washington (`waeb`).
Folder: `courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-1min-25-80007-motion-to-dismiss-memorandum.pdf` (AP Defendants' memorandum supporting a motion to dismiss, Bush Kornfeld LLP and Eisenhower Carlson PLLC, filed 2025-02-19, 42 pages). One filer only. See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-1min-motion-to-dismiss-memorandum.md`: caption, opening paragraph, Preliminary Statement, paragraphs 1 to 26 with Factual Background sections A and B, the Conclusion and the signature blocks. Paragraphs 27 to 101 and the Applicable Standards and Argument are not transcribed (see Known gaps). |
| render | ok: `samples/OUTPUT-1min-motion-to-dismiss-memorandum.pdf`, 14 pages, letter, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> samples/INPUT-1min-motion-to-dismiss-memorandum.md`). |
| overlay | ok: `samples/OVERLAY-1min-motion-to-dismiss-memorandum.pdf` (14 pages) and `samples/OVERLAY-1min-motion-to-dismiss-memorandum.txt` (page map), from `sh tools/overlay.sh <this dir> 1min-motion-to-dismiss-memorandum <exemplar>` (2026-10-15). The exemplar PDF is not in the checkout; it was fetched from its CourtListener URL in `exemplars/SOURCE.md` (sha256 matches the recorded value). See Overlay. |
| pages reviewed | 14 of 14 (2026-10-15: every rendered page rasterized at 70 dpi and viewed as a contact sheet, unchanged font). Earlier review 2026-10-14 at 70 dpi. |
| typeface | LBR 9004-1(a)(3) names no face; EB Garamond kept (2026-10-15 check of the rule text). See Typeface. |

## Governing rules

Primary sources, fetched 2026-10-14 (quoted or paraphrased from the fetched text).

| Rule | Requirement | Template |
|---|---|---|
| LBR 9004-1(a)(1) (Complete Set of Local Rules, https://www.waeb.uscourts.gov/sites/waeb/files/Complete_Set_Local%20Rules_20260717.pdf, rule dated AUGUST 1, 2020) | Documents prepared letter size, 8 " x 11". | `paper: "us-letter"`. |
| LBR 9004-1(a)(3) (same source) | Typed and double-spaced; "a proportionately spaced typeface of 14 points or more"; roman type; "footnotes shall be double-spaced"; quoted material may be single-spaced; average of no more than 280 words per page, including footnotes and quotations. | `type-size = 14pt` (WAEB-MB-FORM-001); `body-leading = 0.94em`, measured line pitch 31.4 pt on 14-pt type, about 2.2 x (WAEB-MB-FORM-002); footnotes set with the body leading (same ID). On the render, pages 2 to 14 average 222 words each (footers excluded); the highest page has 270. |
| LBR 9004-1(a)(4) (same source) | Title of the Court on or below the fifth line of the first page; all pleadings signed under FRBP 5005(a)(2) and 9011; names typed under each signature line. | `court-heading()` below the counsel block (WAEB-MB-CAP-003); `signature-block()` with the name typed under each `/s/` line (WAEB-MB-SIG-001). |
| LBR 9004-1(a)(5)(A)-(D) (same source) | Right of centre, opposite the caption: case number and related case number above the adversary number; nature of the document; name and status of the party filing; "Demand for Jury Trial" when demanded. | `caption()` right column: `case_no` lines in order (WAEB-MB-CAP-004), `title`, `jury_demand`. |
| LBR 9004-1(a)(6) (same source) | Attorney name, mailing address and telephone on the left side above line five. | `counsel-block()` (WAEB-MB-CAP-002). |
| LBR 9004-1(a)(7) (same source) | Bottom left: abbreviated name of the document, followed by the page number. | Footer `MEMORANDUM ISO MOTION TO DISMISS  n` (`footer_title`). |
| LBR 9013-1(d)(1) (Complete Set, rule dated AUGUST 1, 2017) | A memorandum of reasons and list of authorities may, or when the Court requires, be filed in support of a motion; it "must be filed and served ... in accordance with LBR 5005-1(c)". | Doc type scope. The memorandum is a separate document or a part of the motion; the template does not check filing times. |
| LBR 9013-1(d)(2) (same source) | "Citations to Washington cases in a memorandum of authorities shall be to the Washington Reports" (and the other reporter rules listed there). | Not checked by the template (see Exemplar observations). |
| LBR 9013-1(a)(2) (same source) | For a motion in an adversary proceeding, a hearing date is requested on the Court's website, and adequate time is given for objections under LBR 2002-1(c). | Process step, not template content. |
| LBR 2002-1(a)(1)-(2), (c)(1) (Complete Set, rule dated FEBRUARY 24, 2025) | A notice "after notice and hearing" states its purpose, how to object and the time to object, and that the act may occur without a hearing unless a timely objection is filed; a notice may be included with the motion. The moving party gives "at least twenty-one (21) days, plus three (3) additional days if required by [FRBP] 9006(f)" for objections. | Not produced by this template (see Known gaps). |
| LBR 5005-1(c) (Complete Set, rule dated JUNE 15, 2005) | Time of filing is the local time the document is received by the Court. | Cross-reference only (from LBR 9013-1(d)(1)). |
| FRBP 9013(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9013, as amended Apr. 2, 2024, eff. Dec. 1, 2024) | A request for an order is made by written motion; "a motion must state its grounds with particularity and set forth the relief or order requested"; service within the time of FRBP 9006(d). | Opening paragraphs state the motion and relief (content). Service is a separate certificate (see Known gaps). |
| FRBP 7012(b) (https://www.law.cornell.edu/rules/frbp/rule_7012, eff. Dec. 1, 2024) | "Fed. R. Civ. P. 12(b)-(i) applies in an adversary proceeding." | Opening paragraph cites Rule 12(b) and FRBP 7012 as the filing does (content). |
| FRBP 9011(a) (https://www.law.cornell.edu/rules/frbp/rule_9011, eff. Dec. 1, 2024) | Every written motion must be signed by at least one attorney of record in the attorney's individual name; "Each document must state the signer's address and telephone number, if any." | `signature-block()`: each signer block gives the firm, `By /s/` line, the name, and the address and telephone (WAEB-MB-SIG-001). |

## Typeface

- Court rule: LBR 9004-1(a)(3) requires "a proportionately spaced typeface of 14 points or more" and roman type; a monospaced face of no more than 10.5 characters per inch is allowed in a brief. It names no face (checked 2026-10-15 against the text of the Complete Set of Local Rules, dated 2026-07-17 on the court's site).
- Substitution: none. The rule names no face, so the template keeps EB Garamond (`docs/FONTS.md`, "No face named"). No other typeface is used in the template.
- Times New Roman in the filed exemplar is the filer's choice, not a rule requirement, and is not copied.

## Layout

- Page 1: counsel block for the lead firm and co-counsel side by side (lead attorney's address and telephone only, see Decisions); the judge line at the right; the court title; the caption in two columns. Left: "In re:" with the debtors, then the parties with "v." and "and" between groups. Right: case number lines, the adversary number, the title in bold, and the jury-demand line when the frontmatter sets it. The caption is one unbreakable block.
- Body: numbered paragraphs (1, 2, ...) with a 0.5 inch first-line indent, continuous through the memorandum; an unnumbered opening paragraph and an unnumbered conclusion paragraph; level-1 `#` headings centered bold caps (PRELIMINARY STATEMENT, FACTUAL BACKGROUND, CONCLUSION); level-2 `##` headings bold, lettered A., B., ... (restart under each level-1 heading); footnotes numbered and double-spaced.
- Signature: after the conclusion, the date line, then one block per firm (firm name, `By /s/` line, the name and the rest of the signer's lines). The date and all blocks stay together on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields:
  - `judge` (optional): right-aligned line above the court title.
  - `in_re` (list of lines; the last line is "Debtors.").
  - `parties` (list of `{names, designation, joiner}`): `joiner` defaults to "v."; use `joiner: "and"` before an intervenor.
  - `case_no` (list of lines, in order: chapter, case number, joint-administration note, adversary number).
  - `title`, `jury_demand` (bool), `footer_title` (default `MEMORANDUM`).
  - `counsel`: one list of lines, or a list of groups (one group per firm, side by side).
  - `signature`: `date`, and `blocks` (each with `firm`, optional `signer` for the `By /s/` line, and `lines` for the names and details typed under the signature).
- Body chunks, separated by blank lines:
  - `# Heading`: centered bold caps (no number).
  - `## Heading`: lettered A., B., ...; the letters are generated, do not type them.
  - `**Line**`: a bold-only line, centered.
  - `- item` lines: lettered (a), (b), ...
  - `~ text`: an unnumbered paragraph with a first-line indent (the opening paragraph, the conclusion, notes).
  - anything else: a numbered paragraph. Do not type the number.
- Footnotes: `text[^1]` in a paragraph and `[^1]: text` on the line directly after that paragraph, with no blank line between.
- Escapes: `$`, `§` and `¶` are plain text; `*Italic*` and `**bold**` are markdown.

## Decisions and why

- **Counsel block trimmed to the lead attorney.** The first version listed three attorneys for the debtors and their address: the caption then moved to page 2 (the caption is unbreakable and did not fit below the judge line). LBR 9004-1(a)(6) asks for the name, mailing address and telephone of the attorney submitting the document, which the lead attorney's line gives. The signature blocks keep the full list.
- **Judge line kept.** It is a convention in the filed exemplar (top right, line 1). It is not required by the Complete Set of Local Rules. It takes one line on page 1, which is why the counsel block above it was trimmed.
- **Footnotes double-spaced.** LBR 9004-1(a)(3) requires it. The adversary-complaint template sets footnotes single-spaced; that is a question for the adversary template, not changed here.
- **Date and signatures kept together.** A date alone at the foot of a page is not a signature, so the date and all blocks are one unbreakable block; the conclusion moves with them (page 14).
- **Names-only signing block not transcribed.** The filed signature page also has a Mayer Brown LLP block (counsel names and contact, no `/s/` line) and a New York block for Jason I. Kirschner and Danielle A. Sigal under "and". Keeping the Mayer Brown block pushed the signature onto a page of its own, away from the conclusion. The template does support a block with no `signer` (it prints names only); the sample does not use that path.
- **Caption and counsel single-spaced.** The filed exemplar sets its caption single-spaced. LBR 9004-1(a)(3) asks that material be double-spaced except quoted material; the rule text does not name captions as an exception. Kept as the exemplar's convention and flagged (see Open questions).

## Overlay

`samples/OVERLAY-1min-motion-to-dismiss-memorandum.pdf` is the red/blue comparison of our render (red) with the filed exemplar (blue), page by page; the `.txt` is the page map. The pages are paired by word overlap, not by index:

| ours | filed (exemplar PDF page) | word overlap |
|---|---|---|
| 1 (caption) | 42 (signature page) | 33.9% |
| 2 to 13 | 8 to 16 (body) | 34.4% to 77.2% |
| 14 (signature) | 42 | 34.5% |

Page 1 pairs with the exemplar's signature page because both carry counsel names. The filing's own caption runs over its PDF pages 1 and 2, and the pairing does not use them, so the page-1 overlay does not compare captions. The overlay is diagnostic, not a score. The red and blue text do not line up by eye, because the sample is set at 14 pt in EB Garamond and the filing's body is set smaller in Times New Roman. Pages are paired by content, not by position on the page.

## Known gaps

0. **Typeface.** The rule names no face, so EB Garamond is kept. The exemplar's Times is the filer's choice (see Typeface).
1. **Sample is partial.** The sample transcribes paragraphs 1 to 26 and the Factual Background sections A and B. Factual Background section C and paragraphs 27 to 101, the Applicable Standards, and the Argument are not transcribed; the sample says so in an italic note. The render is 14 pages, which is within the 8 to 14 target for a filing this long.
2. **No table of contents or table of authorities.** The filed memorandum has both (pages i to iv of the filing), and the template does not produce them. Neither LBR 9004-1 nor LBR 9013-1 requires them for a memorandum; a clerk would expect them in a memorandum of this length. OPEN (tier 2): the template does not generate TOC/TOA, and the sample omits them.
3. **No certificate of service.** The filed memorandum has none in its 42 pages. Service of a motion under FRBP 9013(b) is shown by a separate certificate or declaration, and LBR 2002-1(b)(4) requires a separate affidavit or unsworn declaration of mailing when notice is given under LBR 2002-1. The template has no certificate block.
4. **Notice and objection period not produced.** Under LBR 2002-1(a)(1), a notice given "after notice and hearing" must state the purpose, how and when to object, and that the act may occur without a hearing unless a timely objection is filed; a notice may be included with the motion (LBR 2002-1(a)(2)). The 21-day objection period plus 3 days (LBR 2002-1(c)(1)) is not set by the template; the sample's caption carries no hearing date.
5. **One filer only.** Tier 2 is judged against 2 or 3 filed exemplars from different filers. Only the AP Defendants' memorandum is saved for this doc type. A second filer (for example, a trustee's or a debtor's motion in this court) is needed before tier 2 can be called passed.
6. **Caption abbreviated in the sample.** The filing lists 70 plaintiffs. The sample has `LAN CAI, et al.,` (the first-named plaintiff) and the template prints the names given. The full list is not transcribed.
7. **Page numbering.** The footer counts the caption page as page 1 and the body follows on page 2. The filing restarts body numbering after the tables (body page 1 is PDF page 8).
8. **Court-applied header not reproduced.** The filing carries the CM/ECF header (`25-80007-FPC Doc 14 Filed ... Pg n of 42`). That header is added by the Court's system, not by the filer; the template does not reproduce it.
9. **Firm footer not reproduced.** The filing's footer carries the firm name and address at the right. It is a firm convention; the template prints only the rule's footer (LBR 9004-1(a)(7)).

## Exemplar observations

- **Counsel block above line five.** The filed first page has no counsel block at the top left (the text layer and the render of page 1 both start with the judge line and the court title). LBR 9004-1(a)(6) asks for one. The template enforces the rule, so the sample takes the lead attorney's name, address and telephone from the signature page. This is sample content chosen to satisfy the rule, not a transcription of the first page.
- **Citation form.** The table of authorities cites several Washington Court of Appeals decisions by "Wash. App." (e.g., 171 Wash. App. 664). LBR 9013-1(d)(2) asks for Washington cases "to the Washington Reports". The template does not check citations; this is noted for the reviewer, not as a template fault.
- **Signature.** The filed signature block gives `/s/` signatures, names, WSBA numbers and the Eisenhower Carlson address, telephone, fax and e-mail. The Bush Kornfeld block gives no e-mail; FRBP 9011(a) asks only for address and telephone, so none is required.

## Open questions for David

1. **Caption and counsel single-spaced.** Kept as the filed exemplar's convention. Should the template double-space them to the letter of LBR 9004-1(a)(3)? (Current choice: single-spaced, flagged here.)
2. **TOC and TOA.** Should a memorandum template produce them? The filed exemplar has both; no local rule requires them.
3. **Second filer.** Is one filer enough for this doc type, or should a second exemplar be found before tier 2 is signed off?

## Review of the rendered pages (2026-10-14, 70 dpi, every page viewed; see Status for pages 1 to 12)

- Page 1: counsel (Bush Kornfeld and Eisenhower Carlson), judge line, court title, caption complete on the page, title and case lines on the right, footer `MEMORANDUM ISO MOTION TO DISMISS 1`. Pass.
- Page 2: unnumbered opening paragraph with footnote 1; PRELIMINARY STATEMENT centered; paragraph 1; paragraph 2 begins. Pass.
- Pages 3 to 4: paragraphs 2 to 5, footnote 2; numbering continuous; footnote double-spaced. Pass.
- Pages 5 to 7: paragraphs 5 to 13; `¶` and `¶¶` stay with their numbers. Pass.
- Page 8: FACTUAL BACKGROUND centered; heading A; paragraphs 14 and 15; footnote 3. Pass.
- Pages 9 to 10: paragraphs 16 to 21; heading B on two lines; footnotes 4 and 5. Pass.
- Pages 11 to 12: paragraphs 22 to 25 (block of all-caps quotation in paragraph 23); footnotes 6 and 7. Pass.
- Page 13: paragraph 26; the rest of the page is empty because the excerpt note, conclusion and signature are kept together on page 14. Pass (accepted layout).
- Page 14: excerpt note, CONCLUSION, the conclusion paragraph, the date and both signature blocks (Bush Kornfeld; Eisenhower Carlson) with names under each `/s/` line. Pass.

## Commands

- Render: `sh tools/render.sh courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-1min-motion-to-dismiss-memorandum.md` (exit 0, no warnings; output `samples/OUTPUT-1min-motion-to-dismiss-memorandum.pdf`).
- Overlay: `sh tools/overlay.sh courts/ninth-circuit/washington/federal/bankruptcy-eastern-district/motion-brief 1min-motion-to-dismiss-memorandum` (writes `samples/OVERLAY-1min-motion-to-dismiss-memorandum.pdf` and `.txt`).
- Toolchain: typst 0.15.0, poppler 26.09.0 (`pdftoppm`), ImageMagick 7.1.2, installed with micromamba from conda-forge into `$HOME/tb`.

[Court README](../README.md) | [Adversary complaint](../adversary-complaint/README.md) | [Formbook index](../../../../../../README.md)

## Engines

docx (`docx/`): `reference.docx` (built by `docx/build-reference.sh`, double-spaced footnotes as the typst motion template), `motion-brief.lua` (the markdown contract to judge line, cover, caption, numbered paragraphs, lettered lists and the signature blocks), `render.sh` (pandoc, then the footer title). Render: `sh tools/render.sh --engine docx <this dir> samples/INPUT-1min-motion-to-dismiss-memorandum.md` writes `samples/OUTPUT-1min-motion-to-dismiss-memorandum.docx` and `.docx.pdf` (LibreOffice 26.8; `pdffonts` shows EB Garamond only). Pages: docx 14, typst 14.

What matches the typst output (`typst/`): letter, 1 in margins; EB Garamond 14 pt throughout; body lines on the typst line pitch (31.4 pt, exact spacing); footnotes double-spaced; counsel side by side, judge line, court title and caption with its rules on page 1; numbered paragraphs, (a) lists and A. headings; footer `MEMORANDUM ISO MOTION TO DISMISS n`; signature blocks after the conclusion, the date kept with the blocks, the excerpt and conclusion kept together.

What differs (checked page by page, `reviews/docx.md`):
- Exact line spacing puts the extra leading above each line, so text starts about 11 pt lower on every page than in typst. The pitch is the same, but a full page holds about one body line fewer, so page breaks differ slightly from the typst render (both 14 pages).
- The caption and the signature block sit a few points off the typst positions (the caption box ends about 20 pt higher).
- Word was not run here (no Word on this machine). Word may paginate slightly differently (docs/DOCX.md).

BLOCKED: check.sh gates 0-3: `tools/check.sh <this dir> --engine docx` cannot run on a doc-type folder. It reads `court.json` and `checks.yaml` from the court dir; this folder has neither, and the court folder has `court.json` but no `checks.yaml`. No `samples/.check-docx.txt` is written. The pages were checked by hand (see `reviews/docx.md`), not by the gates.
