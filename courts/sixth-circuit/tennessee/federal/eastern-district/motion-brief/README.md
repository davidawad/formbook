# tned: motion-brief

Doc type: **motion brief** (memorandum of law supporting a Rule 12(b)(6) motion to dismiss) in the United States District Court for the Eastern District of Tennessee (`tned`).
Folder: `courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole memorandum, footnotes included) |
| render | ok (2026-10-22): `usage/OUTPUT-motion-brief.typst.pdf` and `OUTPUT-motion-brief.docx(.pdf)`, 9 pages, Times New Roman (vendored), on the shared cross-engine layout model; docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | ok (re-run 2026-10-15): `usage/OVERLAY-brockington-motion-brief.pdf` and `OVERLAY-brockington-motion-brief.txt` (page map) |
| pages reviewed | 8 of 8 (re-rendered and re-viewed 2026-10-15 at 60 dpi) |
| typeface | face required: none (LR 5.1) -> Times New Roman (vendored; `docs/FONTS.md` default), the exemplars' face; the docx names the typst face (`{font}` in `docx/reference.xml`) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Tenn. LR 5.1 (Local Rules, revised April 8, 2026; https://www.tned.uscourts.gov/local-rules, PDF `Local Rules_Active_2026.04.08 to Present.pdf`, p. 11; verified 2026-10-14) | 8½ × 11 white paper; double-spaced, except quotations (indented and single-spaced) and headings and footnotes (single-spaced); font size no smaller than 12, footnotes included; margins at least 1 inch on all four sides; pages numbered consecutively at the bottom, with no text in the bottom margin other than the page number; the filing attorney's name, address, telephone number and BPR number. | `page-margin = 1in`, `type-size = 12pt` (also the footnote entries), `pitch-body = 24pt` (double spacing), `pitch-single = 13.8pt` for quotations, headings, footnotes, caption and signature; `quote-indent`; the page footer; `signature` (BPR number per attorney). |
| E.D. Tenn. LR 7.1(b) (same PDF, p. 14; verified 2026-10-14) | Briefs state the factual and legal grounds, comply with LR 5.1, and do not exceed 25 pages unless the Court orders otherwise. | Format per LR 5.1. The 25-page limit is not enforced by the template; the sample is 8 pages. |
| E.D. Tenn. LR 7.1(a) (same PDF, p. 14) | The opening brief and any supporting material are filed with the motion. | The memorandum is the supporting brief; the motion itself is a separate filing (see Known gaps). |
| Fed. R. Civ. P. 7(b)(1) (https://www.law.cornell.edu/rules/frcp/rule_7; verified 2026-10-14) | A request for a court order must be made by motion, in writing, stating the grounds with particularity and the relief sought. | Content of the sample; the template does not check the wording. |
| Fed. R. Civ. P. 12(b) lead-in and 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12; verified 2026-10-14) | A party may assert, by motion, "failure to state a claim upon which relief can be granted." | Content of the sample (the Standard of Review section). |
| Fed. R. Civ. P. 5(d)(1)(B) and 5(b)(2)(E) (https://www.law.cornell.edu/rules/frcp/rule_5; verified 2026-10-14) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | The certificate of service is optional: it renders when the frontmatter carries `certificate_of_service` (the exemplar has one, because one party is served by mail). |

## Layout

- Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md "Cross-engine gate"): every line a box of its pitch, 24 pt for body paragraphs (LR 5.1 double spacing), 13.8 pt (Word's single line) for headings, block quotations and footnotes (LR 5.1 single spacing) and for the court title, caption, title, signature, certificate lines and page number; first fit, ragged right, no kerning, ligatures or hyphenation.
- Court title (centered, bold caps; the division line when the filing names one), a body line above the caption: the parties on the left (names, a blank single line, the designation 1 in; "v." 0.5 in, a blank single line from each side) in a 3.2 in column closed by rules on the right and below; `No.` and the case number on the right, 0.25 in past the rule.
- The title of the paper, centered bold capitals, 24 pt below the caption and 12 pt above the body.
- Body: every paragraph indented 0.5 in on the first line (after a heading or quotation too, as both exemplars). Headings 12 pt above and below, kept with what follows: level 1 centered bold caps (I. INTRODUCTION); deeper levels bold, the typed label in a half-inch box and the text hanging after it (level 2 at the margin, level 3 half an inch in, level 4 an inch in, italic).
- Block quotations (`>`): single-spaced, 0.5 in in on both sides, 12 pt above and below. Footnotes: 12 pt, single-spaced, 7 pt apart.
- The last paragraph is kept on one page with the signature block: at 3.25 in, "Respectfully submitted,", the firm, "By: /s/", each attorney's name with BPR number (LR 5.1) and contact lines, the role (italic), a blank single line between the groups.
- Certificate of service (optional) on its own page: "CERTIFICATE OF SERVICE" centered bold underlined (as both exemplars), the double-spaced text, the recipients 1 in in, the "By: /s/" lines at 3.25 in.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is ordinary markdown: `#` heading (level 1, centered bold caps); `##` (level 2); `###` (level 3); paragraphs; `>` block quotations; footnotes as `[^n]` with `[^n]: text`.
- Frontmatter fields: `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number`, `division` (optional), `title`, `signature` (`firm`, `by`, `attorneys` (list of `{name, bpr (optional), lines}`), `role`), `certificate_of_service` (optional: `text`, `recipients` (list of lists of lines), `by`).
- Star-page citations (`at *2`) must be escaped as `at \*2`, or markdown reads the asterisk as emphasis.
- Not supported: tables, raw typst, a table of contents or authorities (not required under LR 7.1(b) for a brief this length; not produced).

## Known gaps and open choices

1. **Exemplars.** Two filers: `FILED-EXAMPLE-motion-brief.pdf` (Miller & Martin PLLC) and `FILED-EXAMPLE-motion-brief-2.pdf` (Blanchard Horton PLLC; see `usage/SOURCE.md`). Tier 2 is judged against both (below).
2. **Motion not produced.** A Rule 12(b) motion is a separate filing (Fed. R. Civ. P. 7(b)(1)). This template produces the memorandum only. The exemplar's motion (Document 10) is not in this folder.
3. **Typeface.** Face required: none (LR 5.1 names no typeface, only the 12-point minimum). Times New Roman (vendored) is the default substitute per `docs/FONTS.md`, and the exemplars' face; both engines set it (fb-595.68.31; was EB Garamond).
4. **Page limit (LR 7.1(b)).** The template does not count pages. The sample is 9 pages, under 25.
5. **Caption convention.** The party column is closed by a rule (right and bottom). The exemplar's caption rule style is not verified from its text layer, so this is recorded as a tier-2 choice (ACCEPTED), not as a match.
6. **Signature and certificate.** The signature block is kept with the last paragraph (page 8); the certificate of service starts its own page (page 9), as in the first exemplar.
7. **Division line.** The exemplar's caption shows "AT CHATTANOOGA" under the court title; the sample carries it through `division`, so the template's division line is exercised.
8. **Overlay pairing.** The overlay pairs sample pages with exemplar pages by shared words, not by index. Sample page 5 pairs with exemplar page 6, and sample page 8 with exemplar page 10 (the exemplar's certificate page; its signature is on page 9). The overlay is a diagnostic, not a score; the page-by-page review above is the Gate 2 equivalent for this doc type.
9. **Gate scripts.** `sh tools/check.sh <dir>` and `--engine docx` run on this folder (0 failed on both, 2026-10-22). `tools/check-selftest.sh` has no mutants for this folder (it needs a court folder with a generic sample: "court.json unreadable").

## Review of the rendered pages (current PDF)

Re-rendered 2026-10-22 on the cross-engine model; every page of the typst and the docx PDF rasterized at 50 dpi and viewed, and compared with both exemplars (caption, title, headings, quotation, footnotes, signature, certificate). The two PDFs break every line and page alike.

- Page 1: court title with the division, caption, title of the paper, opening paragraph, I. INTRODUCTION and its paragraph. Pass.
- Page 2: II. FACTUAL BACKGROUND, the class definition as a single-spaced quotation, footnotes 1 and 2. Pass.
- Page 3: III. STANDARD OF REVIEW, IV. ARGUMENT, heading A. (label box, text hanging, two lines). Pass.
- Page 4: argument; footnote 3 with its web address broken after a "/". Pass.
- Pages 5 and 6: argument, the string citation. Pass.
- Page 7: heading B., argument, footnote 4 (17 lines) whole at the foot. Pass.
- Page 8: argument, V. CONCLUSION, its paragraph, the signature block. Pass.
- Page 9: certificate of service. Pass.

Tier 2 against the exemplars: the first exemplar sets rules above and below the title and justifies its text; the second underlines its headings; ours sets neither (ACCEPTED, conventions differ between the filers). A paragraph that continues after a quotation ("*Id.* ¶ 22. While ...") is indented in ours, flush in the first exemplar: markdown cannot mark a continuation (ACCEPTED).

## Engines

- **typst** (primary, `typst/tned-motion-brief.typ`): the reference.
- **docx** (`docx/reference.xml`, base="xengine"; `docx/tned-motion-brief.lua` on `require("docx.xengine")`): writes the court title, caption (a two-cell table, the party cell ruled right and below), title, headings, signature and certificate with the typst pitches and spaces in twips; body paragraphs, quotations and footnotes through pandoc in Body Text / Body Text Note / Body Keep / Block Text / Footnote Text. Gate 4: XENG-001..003 PASS (238/238 lines, 9/9 pages), `params.cross_engine: gate` (`eval.yaml`). Diagnostic only: the lines after the caption sit 0.75 pt lower in the docx (LibreOffice adds the rule's width to the cell).
- BLOCKED: none.
