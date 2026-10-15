# tned: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Tennessee (`tned`).
Folder: `courts/sixth-circuit/tennessee/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-simpson-experian-1-26-cv-00138-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-simpson-complaint.md` (the whole filing's text, with partly illegible paragraphs marked) |
| render | ok (re-run 2026-10-15): `samples/OUTPUT-simpson-complaint.pdf`, 10 pages, typst 0.15.0, `tools/render.sh` with vendored fonts only, no warnings; `pdffonts`: EB Garamond Regular and Bold embedded |
| overlay | ok (re-run 2026-10-15): `samples/OVERLAY-simpson-complaint.pdf` and `OVERLAY-simpson-complaint.txt` (page map) |
| pages reviewed | 10 of 10 (re-rendered and re-viewed 2026-10-15 at 60 dpi; the spacing defect found on the first pass is fixed and re-checked) |
| typeface | face required: none (LR 5.1) → EB Garamond kept (no substitute) → visual only for the exemplar's Times-like face |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Tenn. LR 5.1 (Local Rules, revised April 8, 2026; https://www.tned.uscourts.gov/local-rules, PDF `Local Rules_Active_2026.04.08 to Present.pdf`, p. 11; verified 2026-10-14) | 8½ × 11 white paper; double-spaced, except quotations (indented and single-spaced) and headings and footnotes (single-spaced); font size no smaller than 12, footnotes included; margins at least 1 inch on all four sides; pages numbered consecutively at the bottom, with no text in the bottom margin other than the page number; the filing attorney's name, address, telephone number and BPR number. | `page-margin = 1in`, `type-size = 12pt`, `body-leading = 1.35em` (24 pt pitch), `single-leading`, the page footer, `signature-block`. |
| E.D. Tenn. LR 5.2 (same PDF, p. 12) | Electronic filing. PDF filings must meet LR 5.1. | Output is a PDF from typst; the layout rules above apply. |
| E.D. Tenn. LR 3.1 (same PDF, p. 3) | Every complaint must be accompanied by a completed civil cover sheet (JS-44). | Not produced here (a separate form). See Known gaps. |
| E.D. Tenn. LR 3.1.2 (same PDF, p. 4) | Divisional filing: a plaintiff files in the division where a defendant resides, or where the events occurred, or where the plaintiff resides. | `division` frontmatter key puts the division (for example, AT KNOXVILLE) under the court title when the filing names one. The sample has none, because the exemplar's caption has none. |
| Fed. R. Civ. P. 8(a)(1)–(3) (https://www.law.cornell.edu/rules/frcp/rule_8; verified 2026-10-14) | Short and plain statement of jurisdiction, of the claim, and a demand for relief. | Content of the sample (not checked by the template). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10; verified 2026-10-14) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation; the complaint's title names all the parties. | `court-title`, `caption` (`caption.parties` lists every party), `case_number`, `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered by the template; headings and lists are not numbered; prayer items are lettered. |
| Fed. R. Civ. P. 38(b)(1) (https://www.law.cornell.edu/rules/frcp/rule_38; verified 2026-10-14) | A jury demand may be included in a pleading, no later than 14 days after the last pleading directed to the issue. | The jury demand is in the title (`title` frontmatter) and in a body section. The template does not check the wording. |

Rules checked and not applicable to the complaint: LR 7.1(b), the 25-page limit (motions and briefs, see `../motion-brief/`); FRCP 5(d)(1)(B) (no certificate of service for an ECF-served paper, so the complaint carries none).

## Layout

- Court title (centered, bold caps), then the caption: parties on the left in a column closed by a rule on the right and bottom, `Case No.` and the title on the right.
- Lead-in paragraph (unnumbered), then body. Each body paragraph is numbered 1, 2, … with a 0.5 inch first-line indent. Headings are centered bold caps (level 1), centered bold (level 2), or bold at the left (level 3). Headings are sticky: a heading never ends a page.
- Prayer items (markdown list) are lettered (a), (b), …. A paragraph beginning `WHEREFORE` is an unnumbered prayer lead-in.
- Signature block: "Dated" at the left; "Respectfully submitted," the firm, "By: /s/" and the signer, the BPR number (`signature.bpr`, when the filer has one), address, telephone, email and role.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (level 1, centered caps), `##` (centered bold), `###` (bold, left); a list (`1.` items, lettered by the template); or a paragraph (numbered by the template, unless it begins `WHEREFORE`).
- Frontmatter fields: `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number`, `title`, `lead_in` (optional), `division` (optional), `signature` (`date`, `firm`, `signer`, `bpr` (optional), `lines`, `role`).
- Not supported: tables, footnotes, raw typst. The template does not number the body; the sample must not put numbers in the text.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP through the API, `court=tned`, complaints filed 2026-06 to 2026-09) found Blitchington v. Portfolio Recovery Associates, LLC, No. 1:26-cv-00274 (13 pages, filed 2026-09-24) as a candidate; it was not downloaded in this pass. Tier 2 is therefore **not** judged against two filers yet.
2. **BPR number (LR 5.1).** The exemplar filer is pro hac vice, and its signature block shows no Tennessee BPR number. The template reserves a `bpr` line, but the sample leaves it out, because the exemplar does not show one. Whether a pro hac vice complaint must carry local counsel's BPR number is a question for David (the filing would need local counsel's name and number).
3. **Typeface.** Face required: none. LR 5.1 names no typeface, only the 12-point minimum (checked 2026-10-15 against the Local Rules PDF and a courtrules.net reproduction of LR 5.1). Substitute: none needed, so EB Garamond stays per `docs/FONTS.md` ("No face named"). EB Garamond at 12 pt has a smaller x-height than the Times New Roman of the exemplar, so the text looks smaller; Liberation Serif would match the exemplar's face, but the rule does not require it, and the exemplar's face is not the test. ca9's complaint template records the same choice. A vendored Times-metric font would remove the difference.
4. **Civil cover sheet (LR 3.1, JS-44).** Not produced here. It is a separate form and must accompany the complaint.
5. **Caption convention.** The party column is closed by a rule (right and bottom) rather than a column of ")" marks. The exemplar's caption rule style is not verified from its text layer, so this is recorded as a tier-2 choice (ACCEPTED), not as a match.
6. **Division.** The exemplar's caption has no division line, although LR 3.1.2 requires filing in a division. The template takes a `division` line when a filing names one; the sample does not.
7. **Partial exemplar text.** About 20 of the exemplar's 103 numbered paragraphs are truncated or missing in its text layer. The sample marks each with a bracketed note rather than guessing. Those marks are numbered paragraphs in the sample, so the sample's numbers differ from the filed paragraph numbers (the sample's paragraph 20 is the filed paragraph 21, for example). Paragraph numbering is not asserted.
8. **Overlay pairing.** The overlay pairs sample pages with exemplar pages by shared words, not by index. Page 3 of the sample pairs with page 4 of the exemplar, and page 10 with page 13. The overlay is a diagnostic, not a score; the page-by-page review above is the Gate 2 equivalent for this doc type.
9. **No footer title or case number.** LR 5.1 requires only page numbers, so the footer carries the page number alone (ca9 also carries a title and case number, which N.D. Cal. requires).
10. **Gate scripts not run.** The brief forbids editing `tools/`, and `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`. This doc-type folder is not that shape, so those gates were not run. Render and overlay were run.

## Review of the rendered pages (current PDF)

Every page was rasterized at 60 dpi and viewed. The first render had collided paragraph lines (the blocks had no trailing leading, so each paragraph's first line sat on the previous paragraph's last line). The template now gives each paragraph block a trailing `body-leading`, and every page was re-viewed.

- Page 1: court title, caption (parties left, `Case No.` and title right), lead-in, heading JURISDICTION AND VENUE, paragraphs 1 to 6. Footer: page number. Pass.
- Page 2: paragraphs 7 to 17, FACTUAL ALLEGATIONS heading. Pass.
- Page 3: Background heading, paragraphs 18 to 36. Pass.
- Page 4: paragraphs 37 to 49, Violations heading. Pass.
- Page 5: paragraphs 50 to 61. Pass.
- Page 6: paragraphs 62 to 74, Damages heading. Pass.
- Page 7: FIRST CAUSE OF ACTION heading and sub-heading on lines of their own, paragraphs 75 to 82, lettered items (a) to (d). No heading at a page foot. Pass.
- Page 8: items (e) to (g), paragraphs 83 to 90, SECOND CAUSE OF ACTION heading. Pass.
- Page 9: paragraphs 91 to 95, WHEREFORE lead-in, DEMAND FOR TRIAL BY JURY heading and paragraph 96, PRAYER FOR RELIEF heading, items (a) to (c). Pass.
- Page 10: items (d) and (e), date, signature block (single-spaced, firm, "By: /s/", signer, address, telephone, email, role). No text in the bottom margin except the page number. Pass.
