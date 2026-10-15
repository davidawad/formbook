# innb: adversary complaint

Doc type: **complaint commencing an adversary proceeding** in the United States Bankruptcy Court for the Northern District of Indiana (`innb`). Folder: `courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-vendramin-henry-13-03061-adversary-complaint.pdf` (one filer: a creditor-plaintiff; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-vendramin-henry-adversary-complaint.md`: the whole filed text (10 pages of exemplar), transcribed as filed |
| render | ok: `samples/OUTPUT-vendramin-henry-adversary-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 |
| overlay | ok: `samples/OVERLAY-vendramin-henry-adversary-complaint.pdf` and `.txt` (exit 0) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |

This is a doc-type folder, not a court folder: `court.json`, `STATUS.md` and the court-root `typst/` and `samples/` are untouched, and nothing here sets a status.

## Governing rules

Rule text was read from the sources below on 2026-10-14. Local rule PDFs were read through their text layers (WebFetch returned the saved PDFs; `pdftotext` read them). Federal rule text was read from the Cornell LII pages (quotes are short; the rest is paraphrase, marked).

| ID | Rule | Requirement (quoted or closely paraphrased) | Where it is in the template |
|---|---|---|---|
| INNB-FORM-001 | N.D. Ind. L.B.R. B-5005-2(a)(1) (https://www.innb.uscourts.gov/sites/innb/files/local_rules/B-5005-2_0.pdf) | "They shall be plainly typewritten or printed and double spaced, except for quoted material." | `line-pitch = 24pt`, `body-leading`; paragraphs flow on the 24-pt pitch. |
| INNB-FORM-002 | B-5005-2(a)(2) | "The title must be set out on the first page." | `title-block` directly under the caption, on page 1. |
| INNB-FORM-003 | B-5005-2(a)(3) | "Each page shall be consecutively numbered." | Footer page number, 1 to end, centred. |
| INNB-FORM-004 | B-5005-2(a)(4), (b)(2) | "All papers must be clearly legible." Paper: "white paper of good quality, 8½" x 11" in size, printed on one side of the paper only." | `paper: "us-letter"`; 1-inch margins (a style choice; no margin figure in the rule). |
| INNB-FORM-005 | (none) | No typeface or point size is named in B-5005-2 or FRBP 9004(a). B-5005-2(a)(1) says only "plainly typewritten or printed" (text checked 2026-10-15); FRBP 9004(a) says only "clearly legible". Typeface row: face required = none; substitute = none needed, so EB Garamond kept (`docs/FONTS.md`, "No face named"). | `font-family = "EB Garamond"`, `type-size = 13pt` (style choices; see gaps). |
| INNB-CAP-001 | Fed. R. Bankr. P. 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004; amended Apr. 2, 2024, eff. Dec. 1, 2024) | "A document presented for filing must contain a caption that sets forth: the court's name; the case's title; the case number and, if appropriate, adversary-proceeding number; and a brief designation of the document's character." | `court-title`, `debtor-table` (case no., chapter), `parties-table` (adversary number), `title-block` (designation). |
| INNB-CAP-002 | Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010; amended Apr. 2, 2024, eff. Dec. 1, 2024) | "Fed. R. Civ. P. 10 applies in an adversary proceeding except that a pleading's caption must substantially conform to the appropriate version of Form 416." | Caption laid out on the Form 416D (adversary) pattern: debtor block, then plaintiff/defendants with "Adv. Proc. No.". Form text was not retrieved verbatim (see gaps). |
| INNB-CMP-001 | Fed. R. Civ. P. 10(a), (b) via FRBP 7010 (https://www.law.cornell.edu/rules/frcp/rule_10; amended Apr. 30, 2007, eff. Dec. 1, 2007) | 10(a): "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." 10(b): "A party must state its claims or defenses in numbered paragraphs" (the excerpt returned stops there; the rest of 10(b) was not read). | Body paragraphs numbered 1, 2, ... by the template (`render-body`); headings, lettered sub-items and the WHEREFORE paragraph are unnumbered. |
| INNB-PLD-001 | Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008; amended Apr. 2, 2024, eff. Dec. 1, 2024) | "Fed. R. Civ. P. 8 applies in an adversary proceeding." The complaint must state the jurisdiction (the related case's name, number and chapter, and the district and division), and "must state whether the pleader does or does not consent to the entry of final orders or judgment." (quoted from the page summary; the full text was not reproduced) | **Not generated.** The template does not check for a jurisdiction or consent statement. The exemplar has neither. See gaps. |
| INNB-SIG-001 | Convention (no rule cites the form) | Signature block: "Respectfully Submitted," firm, role, "By:" line, signer and bar number, address, telephone, email. | `signature-block`. The exemplar has no date line; none is printed. |

Not used, and why: B-7007-1 (motion practice and brief length) and B-9013-1 (motions) apply to motions, not complaints; B-7008-1 (responsive pleadings) applies to answers, not complaints. The motion-brief doc type is in `../motion-brief/`.

Not produced by this template (separate filings; no rule was checked for them): the summons (FRBP 7004), the adversary cover sheet, the filing fee, and any certificate of service. The exemplar has none of these.

## Layout

- US Letter, 1-inch margins, one side. Double spaced (24 pt) body; single-spaced caption, debtor block, signature block and block quotations.
- Page 1: court title (three centred lines), debtor block (`In re:`, debtor and joint debtor designations, case number and chapter at right), plaintiff/defendant block closed by a right and bottom rule with the adversary number at right, then the title in centred bold caps.
- Headings: `# ...` centred bold caps; `## ...` left bold. Headings are written by the author (the template does not number them).
- Paragraphs: every ordinary paragraph is numbered by the template, so the sample must not type the numbers. A chunk starting with a capital letter and a period (`A. ...`) is an unnumbered lettered sub-item. A line starting `WHEREFORE` is unnumbered. The optional `lead_in` frontmatter field is the unnumbered lead-in paragraph ("Comes now ...").
- Footnotes: `[^key]` in the body and `[^key]: text` as a separate chunk; the definition is attached to the chunk that cites it.

## Markdown contract (for samples)

- YAML frontmatter: `court` (lines), `debtors` (list of `names`, `designation`), `case_number`, `chapter`, `caption` (list of `names`, `designation`, joined by "v."), `adv_number`, `title` (lines), `lead_in` (optional), `signature` (`preamble`, `firm`, `role`, `signer`, `lines`), `date` (optional).
- Body: blank-line-separated chunks. `#` heading, `##` sub-heading, `>` block quotation, `A.`-style sub-item, `WHEREFORE`, or a numbered paragraph. No tables, no raw typst.
- Dollar signs are escaped (`\$`) so cmarker does not read them as math.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env at ~/tb)
sh tools/render.sh courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/adversary-complaint samples/INPUT-vendramin-henry-adversary-complaint.md
sh tools/overlay.sh courts/seventh-circuit/indiana/federal/bankruptcy-northern-district/adversary-complaint vendramin-henry-adversary-complaint
```

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` (it strips the `INPUT-` prefix), and `tools/overlay.sh` reads that and writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The brief's `<id>.pdf` and `<id>-overlay.pdf` names were not used, because the tools fix these names.

- Render: exit 0, no warnings, `pdffonts` shows EBGaramond-Regular and -Bold only (embedded).
- Line pitch: measured with `pdftotext -bbox-layout` on page 3: lines fall 23.98 pt apart, i.e. the 24-pt pitch.
- Overlay (red = our render, blue = exemplar, black = both). The page map pairs by word overlap: ours p.1-4 with filed p.1-4; ours p.5 with filed p.6; ours p.6 with p.7; ours p.7 with p.8; ours p.8 and p.9 with p.10. The exemplar uses a different typeface, a different layout (plain caption, no rules) and a different paragraph numbering, so the lines will not coincide. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 9 pages, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, debtor block, caption, adversary number, title, lead-in, paragraph 1 | Pass. The caption fits inside its rule after the designation indent was narrowed (`DEFENDANTS` had crossed the rule, and `JOINT DEBTOR` wrapped). |
| 2 | Paragraphs 2 to 7 | Pass. |
| 3 | Paragraphs 8 to 12 | Pass. |
| 4 | Paragraphs 12 to 13 (filed numbering: see gaps) and lettered sub-items A to D | Pass. Sub-items are unnumbered and indented. |
| 5 | Sub-items D to J, paragraph 14 | Pass. |
| 6 | Paragraph 14 (end), paragraph 15 | Pass. |
| 7 | Paragraphs 16 to 19 | Pass. |
| 8 | RELIEF heading, paragraphs 20 to 25, WHEREFORE | Pass. The WHEREFORE paragraph is unnumbered and indented. |
| 9 | Signature block alone | OPEN: the signature block does not fit at the foot of page 8 and moves to page 9 with no text above it. The block is unbreakable and the template has no keep-with-previous rule. A litigator would usually want the last paragraph carried onto the signature page. |

## Known gaps and open choices

1. **Typeface and size (INNB-FORM-005).** Neither B-5005-2 nor FRBP 9004(a) names one. The exemplar is Times New Roman. Only EB Garamond is vendored (no system fonts allowed), so the template uses EB Garamond at 13 pt, the same choice as the ca9 templates. Whether the court would accept Garamond is a question for David.
2. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers. A second filer is available: Fischer, Trustee v. Radio Shack Credit Services, adv. 08-01025 (Doc 1, filed 02/06/08, two pages, a trustee filing). It was read and not saved (see `exemplars/SOURCE.md`). It would be the second filer for tier 2 if the box has room to add it.
3. **Jurisdiction and consent statements (INNB-PLD-001).** FRBP 7008(a) requires them, and the template does not check for them. The exemplar does not include them, so the sample does not either. A real filing should carry them; the template does not generate them, because they are case-specific.
4. **Form 416D caption.** Rule 7010 requires a caption that "substantially conform[s]" to Form 416. The official form text was not retrieved (the uscourts.gov form page returned HTTP 404; search summaries describe Form 416D). The layout here follows those summaries. This is the main unverified element of the caption.
5. **Cover sheet, summons, fee, service.** Not generated. The FRBP 7003 text available was a stub ("Fed. R. Civ. P. 3 applies"); whether an adversary cover sheet is required was not verified, so nothing is asserted about it.
6. **Paragraph numbering in the exemplar.** The filed complaint numbers 1 to 14 in order, then runs 13, 12, 13, 14, 15 (the numbers repeat and go backwards), then 16 to 21. The template numbers the paragraphs it finds in filed order, 1 to 25, so the sample's numbers differ from the filed ones. The filed errors are otherwise transcribed as filed: "Venderamin" (for Vendramin), "relief on or about , BK Filing", "Fax: 219-531-4 732", "Henry's" in several places, and "Plaintiff/Creditor" usage. These are the exemplar's own text, not template defects.
7. **Sub-item detection.** A line starting with a capital letter and a period is treated as a sub-item. A paragraph starting that way would lose its number; none in this sample does.
8. **Italics.** Case names and citations are not italic in the complaint sample (the complaint cites none); the template italicises `*...*` markup.
9. **Signature block.** No date line (none in the exemplar). `By:` line drawn as a rule, not `/s/`. The block is unbreakable (see page 9 above).
10. **Page count.** The sample is 9 pages, inside the 8-14 page target the brief set for full-depth samples.
