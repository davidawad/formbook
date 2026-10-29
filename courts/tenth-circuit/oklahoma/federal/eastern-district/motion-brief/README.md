# oked: motion-brief

Doc type: **motion to dismiss with brief in support** (a combined motion and brief, Fed. R. Civ. P. 12(b)) in the United States District Court for the Eastern District of Oklahoma (`oked`).
Folder: `courts/tenth-circuit/oklahoma/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer: the Freedom From Religion Foundation, by the ACLU Foundation of Oklahoma and the ACLU Foundation; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a transcription of pages 1 to 11 and 15 to 17 of the 17-page filing (pages 12 to 14 are marked omitted in the sample; footnote 5 is not transcribed) |
| typeface | no face named by the court's rules (LCvR 5.2(a); checked 2026-10-15). Times New Roman (vendored), the house standard of `docs/FONTS.md` and the exemplar's face (`data/exemplar-fonts.json`: `template_face`) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 12 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with E.D. Okla.'s local rules overlaid in `typst/layout.yaml` (fb-595.17.19) |
| overlay | `just overlay courts/tenth-circuit/oklahoma/federal/eastern-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 12 of 12 on typst, latex and docx (every page of the three renders viewed side by side at 40 dpi after the move onto the FRCP base, 2026-10-29) |
| tier 2 | not judged against two filers: one exemplar only (gap 1) |

## Governing rules

Verified 2026-10-14.

| Source | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.2(a), E.D. Okla. Local Civil Rules, effective July 5, 2016 (https://www.oked.uscourts.gov/sites/oked/files/Local_Civil_Rules.pdf) | Paper 8½ × 11 in. Print style, footnotes included, not smaller than 12-point. Margins at least 1 in. on all sides. Line spacing no less than 1.5, excluding blocked quotations and footnotes. | The base: 12 pt (footnotes too), one-inch margins, a 24 pt (double) body pitch; footnotes and blocked quotations single-spaced (13.8 pt), as the rule allows. The caption, headings and signature block are single-spaced (gap 3). |
| Typeface, all E.D. Okla. Local Civil Rules (posted PDF, text extracted and searched 2026-10-15) | No typeface is named. LCvR 5.2(a) sets only the print style's minimum size (12-point), the margins and the line spacing; LCvR 7.1(c) applies the same 5.2(a) form to briefs. | `font-family = ("Times New Roman", "Liberation Serif")` in `typst/oked-motion-brief.typ` (no face named; the house standard of `docs/FONTS.md`, vendored) |
| LCvR 7.1(b) (same document) | Each motion is a separate pleading with a concise brief. The brief may be combined with the motion "if clearly stated in the title of the motion or pleading". | The title is "DEFENDANT'S MOTION TO DISMISS AND BRIEF IN SUPPORT", set from the `brief_title` frontmatter. |
| LCvR 7.1(c) (same document) | No brief over 25 typewritten pages without leave. Briefs over 15 pages need an indexed table of contents and an indexed table of statutes, rules, cases and other authorities. The form is that of LCvR 5.2(a). | `eval.yaml` `params.page_limit: 15` (DEF-LEN-001, every engine, every page counted): the template makes no tables, so it holds a brief to 15 pages. Indexed TOC and TOA: **not produced by this template** (gap 2). |
| Fed. R. Civ. P. 12(b) (text: "But a party may assert the following defenses by motion"; amendment effective Dec. 1, 2024; https://www.law.cornell.edu/rules/frcp/rule_12) | Defenses by motion, including 12(b)(1) (subject-matter jurisdiction) and 12(b)(6) (failure to state a claim upon which relief can be granted). | The grounds are author content. The sample's headings cite 12(b)(1) and the frontmatter title cites 12(b). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, as amended Dec. 1, 2007) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `front` in `typst/layout.yaml`: the court's name (`constants`), the parties in a ruled box, the case number and `judge` at its right, `brief_title`. |

Not checked against a rule: the "Date:" line is the exemplar's convention. The certificate of service is the body's last section (`tail`, on a page of its own) with its signer after it (`after_tail`); its rule (Fed. R. Civ. P. 5) was not verified for this doc type. Rule 7(b)(1) (a motion "must state with particularity the grounds for seeking the order") is author content.

## Layout

The generic FRCP brief with E.D. Okla.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there):

- Letter, one-inch margins, Times New Roman 12 pt; body double spaced (24 pt), first-line indent half an inch; page number centered at the foot.
- Court name centered, bold, in capitals (two lines, `constants`).
- Caption: a ruled box around the parties (each party's names, the designation in italics two inches in, "v." an inch in), as in the exemplar; at its right, "Case No." and a line below it the judge (`judge`).
- Title centered, bold, in capitals, underlined, after the caption.
- Body: paragraphs with a 0.5 in. first-line indent; the facts are numbered in the text (`1\.`), as the exemplar numbers them.
- Headings: level 1 centered bold capitals (FACTUAL BACKGROUND, ARGUMENT, CONCLUSION); level 2 "I.", "II." bold with the label in a half-inch box and the title hanging; level 3 "A.", "B." the same, half an inch in. The template counts the labels, so the sample types no numbers. Headings are kept with what follows.
- Block quotations single spaced, an inch in at the left and half an inch at the right. Footnotes 12 pt (LCvR 5.2(a)), single-spaced (13.8 pt lines), under a 30 % rule.
- Signature (the base's closing): "Date:" at the body pitch, then at the right "Respectfully submitted," (`firm`), a signature line, the /s/ block and "Counsel for Defendant". The conclusion paragraph and its heading are kept on the page with the signature block.
- Certificate of service: the body's `# CERTIFICATE OF SERVICE` section, on a new page (the exemplar does the same), with its own signature block at the right (`service.signed`).

## Markdown contract (for samples)

- YAML frontmatter (the base's): `case_number`, `case_label` (optional, default `Case No.`), `caption.parties` (list of `{names, designation}`; `names` one string, a newline between lines), `brief_title`, `signature` (`date_line`, `firm` (the line above the signature line), `blocks`, `counsel_for`). E.D. Okla.'s: `judge` (optional), `service` (`signed`: the certificate's signature lines, `counsel_for` optional).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) headings. A numbered fact paragraph types its number with the period escaped (`1\. On March 31, ...`). Footnotes with `[^label]` in the text and `[^label]: text` definitions. `# CERTIFICATE OF SERVICE` begins the certificate (set after the signature, on a new page).
- `[Pages 12 to 14 are not transcribed in this sample.]` marks the omitted run.

## Known gaps and open choices

1. **One exemplar.** EDOK's tier-2 rule asks for two or three filers. Searches for other EDOK motions to dismiss on CourtListener found only other districts' filings, and the FFRF motion (6:25-cv-94-JFH) is the one saved. Tier 2 is therefore **not** judged against two filers.
2. **Indexed TOC and TOA (LCvR 7.1(c)).** The template does not produce a table of contents or a table of authorities, so DEF-LEN-001 holds a render to 15 pages, every page counted. The exemplar (17 pages, including the caption, signature and certificate) has neither, so either the rule counts the body differently or the filer did not comply. **Question for David:** does the 15-page count in LCvR 7.1(c) include the caption, the signature block and the certificate of service?
3. **Spacing of the caption, headings and signature block (tier-1 reading, open).** LCvR 5.2(a) requires line spacing of at least 1.5 except blocked quotations and footnotes. The caption, the headings and the signature block are single-spaced, as in the exemplar. **Question for David:** do these fall under the 1.5 requirement? The template follows the exemplar until David answers.
4. **Partial transcription.** The sample transcribes pages 1 to 11 and 15 to 17 of the filing, with pages 12 to 14 omitted and footnote 5 not transcribed.
5. **Certificate of service.** The certificate's wording and signature block follow the exemplar. Fed. R. Civ. P. 5 was not verified for this doc type.
6. **Signature line.** The base sets a blank signature line above the /s/ block; the exemplar underlines the /s/ name itself. Tier 3.
7. **DEF-COVER-002 on typst.** The typst render's caption box is drawn as one stroked rectangle, which the cover-structure check does not read as two horizontal rules; latex and docx draw lines it reads and pass. The typst row stays in `data/cover-structure-baseline.txt` (REPORTED).
8. **Self-test.** There is no `check-selftest.sh` run: the doc-type folder has no `court.json`.

## Gate 2 review (2026-10-29, the three renders after the move onto the FRCP base, every page)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, boxed caption, "Case No." and the judge at its right, title, opening paragraph, footnote 1 at the foot | PASS |
| 2 | exemplar p.2 | Body at double spacing; argument-lead paragraphs | PASS |
| 3 | exemplar p.3 | "More fundamentally..."; FACTUAL BACKGROUND; facts 1 and 2 | PASS |
| 4 | exemplar p.4 | Facts 2 (end) to 4; the page ends short, as ARGUMENT, I. and A. are kept with the paragraph after them | PASS |
| 5 | exemplar p.4-5 | ARGUMENT; I. and A. headings with hanging labels; standing argument; footnote 2 | PASS |
| 6 | exemplar p.6 | Standing argument, continued | PASS |
| 7 | exemplar p.7 | Standing argument, continued | PASS |
| 8 | exemplar p.8 | B. heading (two lines, hanging); jurisdiction argument; footnote 3 | PASS |
| 9 | exemplar p.9 | II. and A. headings, OCPA paragraphs; footnote 4 | PASS |
| 10 | exemplar p.11 | B. heading; "[Pages 12 to 14 ...]" marker; the page ends short, as the conclusion is kept with the signature | OPEN |
| 11 | exemplar p.16 | CONCLUSION and its paragraph; "Date:" at the left, "Respectfully submitted," and the /s/ block at the right, "Counsel for Defendant" | PASS |
| 12 | exemplar p.17 | CERTIFICATE OF SERVICE on its own page; the certificate paragraph; its signature block | PASS |

## Engines

typst (`typst/oked-motion-brief.typ` names the face; `typst/layout.yaml` the E.D. Okla. overlay); latex (`latex/template.tex`, `latex/xdoc.lua`) and docx (`docx/reference.xml`, `docx/xdoc.lua`) generated by `fb engines gen` from the merged layout. `params.cross_engine: gate` in `eval.yaml`.

- typst: `RESULT: 11 checks passed, 0 failed` (DEF-COVER-002 REPORTED, gap 7).
- latex: `RESULT: 15 checks passed, 0 failed`; XENG-001..003 PASS (12 pages, 306/306 typst lines break after the same word).
- docx: `RESULT: 16 checks passed, 0 failed`; XENG-001..003 PASS (12 pages, 306/306).
- Not produced by any engine: the TOC and TOA of LCvR 7.1(c) (gap 2).
- BLOCKED: none.
