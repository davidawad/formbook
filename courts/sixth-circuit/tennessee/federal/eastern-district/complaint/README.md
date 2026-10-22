# tned: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Tennessee (`tned`).
Folder: `courts/sixth-circuit/tennessee/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole filing's text, with partly illegible paragraphs marked) |
| render | ok (2026-10-22): `usage/OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx(.pdf)`, 10 pages, Times New Roman (vendored), on the shared cross-engine layout model; docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | ok (re-run 2026-10-15): `usage/OVERLAY-simpson-complaint.pdf` and `OVERLAY-simpson-complaint.txt` (page map) |
| pages reviewed | 10 of 10 (re-rendered and re-viewed 2026-10-15 at 60 dpi; the spacing defect found on the first pass is fixed and re-checked) |
| typeface | face required: none (LR 5.1) -> Times New Roman (vendored; `docs/FONTS.md` default), the exemplar's face; the docx names the typst face (`{font}` in `docx/reference.xml`) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Tenn. LR 5.1 (Local Rules, revised April 8, 2026; https://www.tned.uscourts.gov/local-rules, PDF `Local Rules_Active_2026.04.08 to Present.pdf`, p. 11; verified 2026-10-14) | 8½ × 11 white paper; double-spaced, except quotations (indented and single-spaced) and headings and footnotes (single-spaced); font size no smaller than 12, footnotes included; margins at least 1 inch on all four sides; pages numbered consecutively at the bottom, with no text in the bottom margin other than the page number; the filing attorney's name, address, telephone number and BPR number. | `page-margin = 1in`, `type-size = 12pt`, `pitch-body = 24pt` (double spacing), `pitch-single = 13.8pt`, the page footer, `signature-block`. |
| E.D. Tenn. LR 5.2 (same PDF, p. 12) | Electronic filing. PDF filings must meet LR 5.1. | Output is a PDF from typst; the layout rules above apply. |
| E.D. Tenn. LR 3.1 (same PDF, p. 3) | Every complaint must be accompanied by a completed civil cover sheet (JS-44). | Not produced here (a separate form). See Known gaps. |
| E.D. Tenn. LR 3.1.2 (same PDF, p. 4) | Divisional filing: a plaintiff files in the division where a defendant resides, or where the events occurred, or where the plaintiff resides. | `division` frontmatter key puts the division (for example, AT KNOXVILLE) under the court title when the filing names one. The sample has none, because the exemplar's caption has none. |
| Fed. R. Civ. P. 8(a)(1)–(3) (https://www.law.cornell.edu/rules/frcp/rule_8; verified 2026-10-14) | Short and plain statement of jurisdiction, of the claim, and a demand for relief. | Content of the sample (not checked by the template). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10; verified 2026-10-14) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation; the complaint's title names all the parties. | `court-title`, `caption` (`caption.parties` lists every party), `case_number`, `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered by the template; headings and lists are not numbered; prayer items are lettered. |
| Fed. R. Civ. P. 38(b)(1) (https://www.law.cornell.edu/rules/frcp/rule_38; verified 2026-10-14) | A jury demand may be included in a pleading, no later than 14 days after the last pleading directed to the issue. | The jury demand is in the title (`title` frontmatter) and in a body section. The template does not check the wording. |

Rules checked and not applicable to the complaint: LR 7.1(b), the 25-page limit (motions and briefs, see `../motion-brief/`); FRCP 5(d)(1)(B) (no certificate of service for an ECF-served paper, so the complaint carries none).

## Layout

- Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md "Cross-engine gate"): every line a box of its pitch, 24 pt for body paragraphs, headings and lettered items (LR 5.1 double spacing), 13.8 pt (Word's single line) for the court title, caption, signature, footnotes and page number; first fit, ragged right, no kerning, ligatures or hyphenation.
- Court title (centered, bold caps) a body line above the caption: the parties on the left (names, a blank single line, the designation 1 in; "v." 0.5 in, a blank single line from each side) in a 3.2 in column closed by rules on the right and below, 10 pt in; the case number and, a body line below, the bold title on the right, 0.25 in past the rule.
- Lead-in paragraph (unnumbered) 12 pt below the caption, then the body. Each body paragraph is numbered 1, 2, ...: the number in a half-inch box after a half-inch indent (as filed). Headings sit in a body line, kept with what follows: level 1 centered bold caps underlined (as filed), level 2 centered bold, level 3 bold at the left.
- List items: `1.` items lettered (a), (b), ... and `-` items a bullet, the label in a half-inch box half an inch in, the text hanging at 1 in. A paragraph beginning `WHEREFORE` is unnumbered.
- Signature block, kept on one page with the last paragraph: "Dated:" at the margin and "Respectfully submitted," at 3.25 in on the same line; then at 3.25 in the firm (bold), "By: /s/" and the signer, the signer, the BPR number (`signature.bpr`, when the filer has one), address, telephone and email, and the role (italic), a blank single line between the groups.
- Footnotes (supported, none in the sample): 12 pt in 13.8 pt lines, 7 pt apart, 12.6 pt clearance.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (level 1, centered caps), `##` (centered bold), `###` (bold, left); a list (`1.` items, lettered by the template); or a paragraph (numbered by the template, unless it begins `WHEREFORE`).
- Frontmatter fields: `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number`, `title`, `lead_in` (optional), `division` (optional), `signature` (`date`, `firm`, `signer`, `bpr` (optional), `lines`, `role`).
- Not supported: tables, raw typst. Footnotes: `[^id]` references with their definitions as separate chunks. The template does not number the body; the sample must not put numbers in the text.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP through the API, `court=tned`, complaints filed 2026-06 to 2026-09) found Blitchington v. Portfolio Recovery Associates, LLC, No. 1:26-cv-00274 (13 pages, filed 2026-09-24) as a candidate; it was not downloaded in this pass. Tier 2 is therefore **not** judged against two filers yet.
2. **BPR number (LR 5.1).** The exemplar filer is pro hac vice, and its signature block shows no Tennessee BPR number. The template reserves a `bpr` line, but the sample leaves it out, because the exemplar does not show one. Whether a pro hac vice complaint must carry local counsel's BPR number is a question for David (the filing would need local counsel's name and number).
3. **Typeface.** Face required: none (LR 5.1 names no typeface, only the 12-point minimum). Times New Roman (vendored) is the default substitute per `docs/FONTS.md`, and the exemplar's face; both engines set it (fb-595.68.31; was EB Garamond).
4. **Civil cover sheet (LR 3.1, JS-44).** Not produced here. It is a separate form and must accompany the complaint.
5. **Caption convention.** The party column is closed by a rule (right and bottom) rather than a column of ")" marks. The exemplar's caption rule style is not verified from its text layer, so this is recorded as a tier-2 choice (ACCEPTED), not as a match.
6. **Division.** The exemplar's caption has no division line, although LR 3.1.2 requires filing in a division. The template takes a `division` line when a filing names one; the sample does not.
7. **Partial exemplar text.** About 20 of the exemplar's 103 numbered paragraphs are truncated or missing in its text layer. The sample marks each with a bracketed note rather than guessing. Those marks are numbered paragraphs in the sample, so the sample's numbers differ from the filed paragraph numbers (the sample's paragraph 20 is the filed paragraph 21, for example). Paragraph numbering is not asserted.
8. **Overlay pairing.** The overlay pairs sample pages with exemplar pages by shared words, not by index. Page 3 of the sample pairs with page 4 of the exemplar, and page 10 with page 13. The overlay is a diagnostic, not a score; the page-by-page review above is the Gate 2 equivalent for this doc type.
9. **No footer title or case number.** LR 5.1 requires only page numbers, so the footer carries the page number alone (ca9 also carries a title and case number, which N.D. Cal. requires).
10. **Gate scripts.** `sh tools/check.sh <dir>` and `--engine docx` run on this folder (0 failed on both, 2026-10-22). `tools/check-selftest.sh` has no mutants for this folder (it needs a court folder with a generic sample: "court.json unreadable").

## Review of the rendered pages (current PDF)

Re-rendered 2026-10-22 on the cross-engine model; every page of the typst and the docx PDF rasterized at 50-60 dpi and viewed, and compared with the exemplar (caption, headings, numbered paragraphs, prayer, signature). The two PDFs break every line and page alike.

- Page 1: court title, caption (parties left in the ruled column, case number and title right), lead-in, JURISDICTION AND VENUE, paragraphs 1 to 5, PARTIES. Pass.
- Page 2: paragraphs 6 to 17, FACTUAL ALLEGATIONS. Pass.
- Page 3: Background, paragraphs 18 to 36. Pass.
- Page 4: paragraphs 37 to 50, Violations. Pass.
- Page 5: paragraphs 50 to 61. Pass.
- Page 6: paragraphs 62 to 74, Damages. Pass.
- Page 7: FIRST CAUSE OF ACTION and its sub-heading, paragraphs 75 to 82, items (a) to (d). Pass.
- Page 8: items (e) to (g), paragraphs 83 to 89, SECOND CAUSE OF ACTION and its sub-heading. Pass.
- Page 9: paragraphs 90 to 95, WHEREFORE paragraph, DEMAND FOR TRIAL BY JURY, paragraph 96, PRAYER FOR RELIEF, items (a) to (c). Pass.
- Page 10: items (d) and (e), the signature block. Pass.

Tier 2 against the exemplar: the exemplar's caption reads "-against-" and puts the case number mid-box; ours "v." and the case number at the top (ACCEPTED, convention). The exemplar bolds "WHEREFORE" and letters its prayer "a)"; ours "(a)" (ACCEPTED, tier 3).

## Engines

- **typst** (primary, `typst/tned-complaint.typ`): the reference.
- **docx** (`docx/reference.xml`, base="xengine"; `docx/tned-complaint.lua` on `require("docx.xengine")`): writes the court title, caption (a two-cell table, the party cell ruled right and below), lead-in, headings, lettered items and signature with the typst pitches and spaces in twips; numbered and WHEREFORE paragraphs and footnotes through pandoc in Body Numbered / Body Text. Gate 4: XENG-001..003 PASS (267/267 lines, 10/10 pages), `params.cross_engine: gate` (`eval.yaml`). Diagnostic only: the lines after the caption sit 0.75 pt lower in the docx (LibreOffice adds the rule's width to the cell).
- BLOCKED: none.
