# tned: motion-brief

Doc type: **motion brief** (memorandum of law supporting a Rule 12(b)(6) motion to dismiss) in the United States District Court for the Eastern District of Tennessee (`tned`).
Folder: `courts/sixth-circuit/tennessee/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-brockington-sweet-emmaline-1-26-cv-00065-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-brockington-motion-brief.md` (the whole memorandum, footnotes included) |
| render | ok (re-run 2026-10-15): `samples/OUTPUT-brockington-motion-brief.pdf`, 8 pages, typst 0.15.0, `tools/render.sh` with vendored fonts only, no warnings; `pdffonts`: EB Garamond Regular, Bold and Italic embedded |
| overlay | ok (re-run 2026-10-15): `samples/OVERLAY-brockington-motion-brief.pdf` and `OVERLAY-brockington-motion-brief.txt` (page map) |
| pages reviewed | 8 of 8 (re-rendered and re-viewed 2026-10-15 at 60 dpi) |
| typeface | face required: none (LR 5.1) → EB Garamond kept (no substitute) → visual only for the exemplar's Times-like face |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Tenn. LR 5.1 (Local Rules, revised April 8, 2026; https://www.tned.uscourts.gov/local-rules, PDF `Local Rules_Active_2026.04.08 to Present.pdf`, p. 11; verified 2026-10-14) | 8½ × 11 white paper; double-spaced, except quotations (indented and single-spaced) and headings and footnotes (single-spaced); font size no smaller than 12, footnotes included; margins at least 1 inch on all four sides; pages numbered consecutively at the bottom, with no text in the bottom margin other than the page number; the filing attorney's name, address, telephone number and BPR number. | `page-margin = 1in`, `type-size = 12pt` (also the footnote entries), `body-leading = 1.35em` (24 pt pitch), `single-leading` for quotations, headings, footnotes, caption and signature; the page footer; `signature-block` (BPR number per attorney). |
| E.D. Tenn. LR 7.1(b) (same PDF, p. 14; verified 2026-10-14) | Briefs state the factual and legal grounds, comply with LR 5.1, and do not exceed 25 pages unless the Court orders otherwise. | Format per LR 5.1. The 25-page limit is not enforced by the template; the sample is 8 pages. |
| E.D. Tenn. LR 7.1(a) (same PDF, p. 14) | The opening brief and any supporting material are filed with the motion. | The memorandum is the supporting brief; the motion itself is a separate filing (see Known gaps). |
| Fed. R. Civ. P. 7(b)(1) (https://www.law.cornell.edu/rules/frcp/rule_7; verified 2026-10-14) | A request for a court order must be made by motion, in writing, stating the grounds with particularity and the relief sought. | Content of the sample; the template does not check the wording. |
| Fed. R. Civ. P. 12(b) lead-in and 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12; verified 2026-10-14) | A party may assert, by motion, "failure to state a claim upon which relief can be granted." | Content of the sample (the Standard of Review section). |
| Fed. R. Civ. P. 5(d)(1)(B) and 5(b)(2)(E) (https://www.law.cornell.edu/rules/frcp/rule_5; verified 2026-10-14) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | The certificate of service is optional: it renders when the frontmatter carries `certificate_of_service` (the exemplar has one, because one party is served by mail). |

## Layout

- Court title (centered, bold caps), with the division line when the filing names one (`division`). The caption: parties on the left in a column closed by a rule on the right and bottom; `No.` and the case number on the right.
- The title of the paper, centered and bold, under the caption.
- Body: double-spaced; paragraphs indented 0.5 inch on the first line; no paragraph numbers. Headings: level 1 centered bold caps (I. INTRODUCTION); level 2 bold with a hanging indent (A. ...); level 3 bold italic. Headings are sticky: a heading never ends a page.
- Block quotations (`>`) are indented 0.5 inch on both sides and single-spaced. Footnotes are single-spaced, 12 pt.
- Signature block: "Respectfully submitted," the firm, "By: /s/" and the signer, then each attorney's name, BPR number, address and contact lines, then the role. It does not break across pages.
- Certificate of service (optional): "CERTIFICATE OF SERVICE", a double-spaced paragraph from `certificate_of_service.text`, then each recipient's address (single-spaced) and the "By: /s/" line.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is ordinary markdown: `#` heading (level 1, centered bold caps); `##` (level 2); `###` (level 3); paragraphs; `>` block quotations; footnotes as `[^n]` with `[^n]: text`.
- Frontmatter fields: `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number`, `division` (optional), `title`, `signature` (`firm`, `by`, `attorneys` (list of `{name, bpr (optional), lines}`), `role`), `certificate_of_service` (optional: `text`, `recipients` (list of lists of lines), `by`).
- Star-page citations (`at *2`) must be escaped as `at \*2`, or markdown reads the asterisk as emphasis.
- Not supported: tables, raw typst, a table of contents or authorities (not required under LR 7.1(b) for a brief this length; not produced).

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP through the API, `court=tned`, memoranda supporting motions to dismiss) found ABC IP, LLC v. Hoffman, No. 1:25-cv-00389 (E.D. Tenn., a memorandum in support of a Rule 12(b)(6) motion, 23 pages, available on RECAP) as a candidate; it was not downloaded in this pass. Tier 2 is therefore **not** judged against two filers yet.
2. **Motion not produced.** A Rule 12(b) motion is a separate filing (Fed. R. Civ. P. 7(b)(1)). This template produces the memorandum only. The exemplar's motion (Document 10) is not in this folder.
3. **Typeface.** Face required: none. LR 5.1 names no typeface, only the 12-point minimum (checked 2026-10-15 against the Local Rules PDF and a courtrules.net reproduction of LR 5.1). Substitute: none needed, so EB Garamond stays per `docs/FONTS.md` ("No face named"). EB Garamond at 12 pt has a smaller x-height than the Times New Roman-like face in the exemplar, so the text looks smaller; Liberation Serif would match the exemplar's face, but the rule does not require it, and the exemplar's face is not the test. The same choice is recorded in the complaint README and in ca9's templates. A vendored Times-metric font would remove the difference.
4. **Page limit (LR 7.1(b)).** The template does not count pages. The sample is 8 pages, under 25.
5. **Caption convention.** The party column is closed by a rule (right and bottom). The exemplar's caption rule style is not verified from its text layer, so this is recorded as a tier-2 choice (ACCEPTED), not as a match.
6. **Signature block and certificate on page 8.** The signature block does not break across pages (`breakable: false`), so the sample's signature and certificate fall on page 8 with no body text there. The exemplar's signature also sits on its own page. Recorded as a tier-2 layout note; not a defect.
7. **Division line.** The exemplar's caption shows "AT CHATTANOOGA" under the court title; the sample carries it through `division`, so the template's division line is exercised.
8. **Overlay pairing.** The overlay pairs sample pages with exemplar pages by shared words, not by index. Sample page 5 pairs with exemplar page 6, and sample page 8 with exemplar page 10 (the exemplar's certificate page; its signature is on page 9). The overlay is a diagnostic, not a score; the page-by-page review above is the Gate 2 equivalent for this doc type.
9. **Gate scripts not run.** The brief forbids editing `tools/`, and `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`. This doc-type folder is not that shape, so those gates were not run. Render and overlay were run.

## Review of the rendered pages (current PDF)

Every page was rasterized at 60 dpi and viewed.

- Page 1: court title (three lines, the division included), caption (parties left, `No.` right), the title of the paper, the opening paragraph, heading I. INTRODUCTION, the introduction paragraph. Footer: page number. Pass.
- Page 2: heading II. FACTUAL BACKGROUND, paragraphs, the class definition as a single-spaced block quotation, footnotes 1 and 2 at the foot of the page. Pass.
- Page 3: heading III. STANDARD OF REVIEW; heading IV. ARGUMENT; heading A. (bold, hanging indent, two lines); start of the argument. Pass.
- Page 4: argument text; footnote 3 at the foot of the page. Pass.
- Page 5: argument text, the string citation in a paragraph, no heading at the foot of the page. Pass.
- Page 6: argument text; footnote 4 (a long string citation) at the foot of the page, continuing onto page 7. Pass.
- Page 7: heading B. (two lines, bold, hanging indent), argument, heading V. CONCLUSION, conclusion paragraph, continuation of footnote 4. Pass.
- Page 8: signature block (firm, "By: /s/", both attorneys' BPR numbers and contact lines, role), CERTIFICATE OF SERVICE heading, certificate text, recipient, "By: /s/" line. No text in the bottom margin except the page number. Pass.

## Engines

- **typst** (primary, `typst/`): the reference for this section.
- **docx** (`docx/`: `build-reference.sh` makes `reference.docx`; `tned-motion-brief.lua` sets the caption, the title, the first-paragraph rule, the signature block and the certificate). Rendered with `tools/render.sh --engine docx`: `samples/OUTPUT-brockington-motion-brief.docx` and `samples/OUTPUT-brockington-motion-brief.docx.pdf` (LibreOffice, 8 pages, EB Garamond from `fonts/`). Pages reviewed: 8 of 8 at 60 dpi, each compared with the typst output.
  - Matches: letter paper, 1-inch margins, 24-pt double spacing, 12-pt EB Garamond, the three-line court title with the division, the caption, the title of the paper, headings (level 1 centred caps, level 2 with a hanging indent, level 3 bold italic), single-spaced block quotations indented 0.5 inch on both sides, native footnotes at 12 pt, no first-line indent after a heading, a block quotation or at the start of the body, the signature block and the certificate of service on page 8 with the conclusion's signature, page number footer.
  - Differs (tier 2, not chased): the 24-pt exact line places text about 4.6 pt lower than typst, so the page breaks differ early in the brief. Heading II (FACTUAL BACKGROUND) starts page 1 in the docx and page 2 in typst; pages 3 to 6 start on different lines. Footnote 4 is split across pages 6 and 7 in typst and sits on page 6 in the docx. Page count and the placement of the conclusion and signature block (page 7 and page 8) are the same. Word may break pages differently again.
  - BLOCKED: none. `sh tools/check.sh <court-dir> --engine docx` cannot run for this doc-type folder: it expects `checks.yaml` and `court.json` in the court folder, which this folder does not have (see Known gaps, item 9). No gate was edited to make it pass.
