# oked: motion-brief

Doc type: **motion to dismiss with brief in support** (a combined motion and brief, Fed. R. Civ. P. 12(b)) in the United States District Court for the Eastern District of Oklahoma (`oked`).
Folder: `courts/tenth-circuit/oklahoma/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a transcription of pages 1 to 11 and 15 to 17 of the 17-page filing (pages 12 to 14 are marked omitted in the sample; footnote 5 is not transcribed) |
| typeface | no face named by the court's rules (LCvR 5.2(a); checked 2026-10-15). Times New Roman (vendored), the house standard of `docs/FONTS.md`, on both engines (`data/exemplar-fonts.json`: `template_face`). See gap 4 |
| render | ok (2026-10-22, fb-595.68.33): `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx.pdf`, 11 pages each, Times New Roman only, no warnings |
| overlay | ok, re-run 2026-10-15 against the exemplar fetched from the URL in `usage/SOURCE.md` (the PDF is not in the repo; passed to `tools/overlay.sh` as its third argument): `usage/OVERLAY-ffrf-motion-to-dismiss.pdf` and `.txt`; pairing worked (word overlap 39% to 93% per page) |
| pages reviewed | 11 of 11 typst and 11 of 11 docx (every page rendered at 50 dpi and viewed on 2026-10-22, after the last template change) |
| tier 2 | not judged against two filers: one exemplar only (gap 1) |

## Governing rules

Verified 2026-10-14.

| Source | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.2(a), E.D. Okla. Local Civil Rules, effective July 5, 2016 (https://www.oked.uscourts.gov/sites/oked/files/Local_Civil_Rules.pdf) | Paper 8½ × 11 in. Print style, footnotes included, not smaller than 12-point. Margins at least 1 in. on all sides. Line spacing no less than 1.5, excluding blocked quotations and footnotes. | `type-size = 12pt` (footnotes too, `footnote.entry`), `page-margin = 1in`, `pitch-body = 24pt` (double) for the body. Footnotes (12 pt) and blocked quotations are single-spaced (`pitch-single = 13.8pt`), as the rule allows. The caption, headings and signature block are single-spaced (gap 3). |
| Typeface, all E.D. Okla. Local Civil Rules (posted PDF, text extracted and searched 2026-10-15) | No typeface is named. LCvR 5.2(a) sets only the print style's minimum size (12-point), the margins and the line spacing; LCvR 7.1(c) applies the same 5.2(a) form to briefs. | `font-family = ("Times New Roman", "Liberation Serif")` (no face named; the house standard of `docs/FONTS.md`, vendored) |
| LCvR 7.1(b) (same document) | Each motion is a separate pleading with a concise brief. The brief may be combined with the motion "if clearly stated in the title of the motion or pleading". | The title is "DEFENDANT'S MOTION TO DISMISS AND BRIEF IN SUPPORT", set from the `brief_title` frontmatter. |
| LCvR 7.1(c) (same document) | No brief over 25 typewritten pages without leave. Briefs over 15 pages need an indexed table of contents and an indexed table of statutes, rules, cases and other authorities. The form is that of LCvR 5.2(a). | Page limit: author responsibility (A). Indexed TOC and TOA: **not produced by this template** (gap 2). |
| Fed. R. Civ. P. 12(b) (text: "But a party may assert the following defenses by motion"; amendment effective Dec. 1, 2024; https://www.law.cornell.edu/rules/frcp/rule_12) | Defenses by motion, including 12(b)(1) (subject-matter jurisdiction) and 12(b)(6) (failure to state a claim upon which relief can be granted). | The grounds are author content. The sample's headings cite 12(b)(1) and the frontmatter title cites 12(b). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, as amended Dec. 1, 2007) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court`, `case_number`, `caption`, `judge`, `brief_title` frontmatter. The caption box and the right column carry the case number and the judge. |

Not checked against a rule: the certificate of service and the "Date:" line are the exemplar's conventions. The certificate's rule (Fed. R. Civ. P. 5) was not verified for this doc type. Rule 7(b)(1) (a motion "must state with particularity the grounds for seeking the order") is author content.

## Layout

- Court name centered, bold, in capitals (two lines, from `court`).
- Caption: a ruled box around the parties (plaintiffs, "v.", defendant), with the designations in italic, as in the exemplar. To the right: "Case No." and the judge.
- Title centered, bold, in capitals, after the caption.
- Body: double spaced. Paragraphs have a 0.5 in. first-line indent; argument paragraphs are not numbered, and the facts are (marked `<!--numbered-->` in the sample, as the exemplar numbers them).
- Headings: level 1 centered bold capitals (FACTUAL BACKGROUND, ARGUMENT, CONCLUSION). Level 2 "I.", "II." with a hanging label, bold. Level 3 "A.", "B.", bold. The template counts the labels, so the sample types no numbers. Headings are `sticky`.
- Footnotes: 12 pt (LCvR 5.2(a)), single-spaced (13.8 pt lines), 6 pt apart, under a 2 in rule.
- Signature block: "Date:" on the left, "Respectfully submitted," and "/s/" with the signer's lines on the right, then `attorneys_for`. The conclusion paragraph and its heading are kept on the page with the signature block.
- Certificate of service: starts on a new page (the exemplar does the same), with its paragraph and its own signature block.
- Page number centered at the foot, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter: `court`, `case_number`, `judge`, `caption.plaintiffs` and `caption.defendants` (each a list of `{names: [lines], designation}`), `brief_title`, `date`, `signature` (`signer`, `lines`), `attorneys_for`, `certificate` (`signer`, `lines`, `attorneys_for`).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) headings. `<!--numbered-->` before a numbered paragraph; any other chunk is an unnumbered paragraph. Footnotes with `[^label]` in the text and `[^label]: text` definitions, as in the cand sample. `# CERTIFICATE OF SERVICE` begins the certificate (the template starts it on a new page and prints the heading in capitals).
- `[Pages 12 to 14 are not transcribed in this sample.]` marks the omitted run.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one per doc type, and EDOK's tier-2 rule asks for two or three filers. Searches for other EDOK motions to dismiss on CourtListener (through the web search, since the court's CM/ECF and CourtListener's search pages are not reachable from this box) found only other districts' filings, and the FFRF motion (6:25-cv-94-JFH) is the one saved. Tier 2 is therefore **not** judged against two filers.
2. **Indexed TOC and TOA (LCvR 7.1(c)), open and a tier-1 gap for long briefs.** The template does not produce a table of contents or a table of authorities. A brief over 15 pages does not comply until one is built; the cand template has both and could be adapted. The exemplar (17 pages, including the caption, signature and certificate) has neither, so either the rule counts the body differently or the filer did not comply. **Question for David:** does the 15-page count in LCvR 7.1(c) include the caption, the signature block and the certificate of service?
3. **Spacing of the caption, headings and signature block (tier-1 reading, open).** LCvR 5.2(a) requires line spacing of at least 1.5 except blocked quotations and footnotes. The caption, the headings and the signature block are single-spaced, as in the exemplar. Read literally, they need 1.5 spacing. **Question for David:** do these fall under the 1.5 requirement? The template follows the exemplar until David answers.
4. **Font.** No face is named by the court's rules (checked 2026-10-15; see the complaint README, gap 2). Times New Roman 12 pt on both engines (fb-595.68.33; the docx named EB Garamond before the cross-engine port and failed DEF-FONT-002), which is also the exemplar's face.
5. **Partial transcription.** The sample transcribes pages 1 to 11 and 15 to 17 of the filing, with pages 12 to 14 omitted and footnote 5 not transcribed. The sample's footnotes 1 to 4 are from the filing's text layer, which is clean for this exemplar, so their wording is the filer's. The headings and the signature block were checked against the page images.
6. **"¶" at a line end (fixed).** A paragraph sign or a doubled sign stays with its number: the shared layout model (`lib/typst/xengine.typ`) boxes "§ 6" and "¶ 6", the template "¶¶ 20–24"; the docx filter binds them with a no-break space.
7. **Certificate of service.** The certificate's wording and signature block follow the exemplar. Fed. R. Civ. P. 5 was not verified for this doc type.
8. **Checks.** `sh tools/check.sh <dir> --engine typst|docx` run on this folder: typst 9 and docx 13 checks passed, 0 failed (2026-10-22). `tools/check-selftest.sh` needs a `checks.yaml` (court root); not run.
9. **Tool output names.** `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `.txt`. The brief named `<id>.pdf` and `<id>-overlay.pdf`. The tools' names are used because `overlay.sh` reads `OUTPUT-<id>.pdf`.

## Review of the rendered pages (`OUTPUT-motion-brief.typst.pdf` and `OUTPUT-motion-brief.docx.pdf`)

Every page of both engines rendered at 50 dpi and viewed on 2026-10-22, after the last template change; the two engines break every line and page alike (XENG-001..003 PASS), so each row holds for both. Exemplar page numbers in the second column.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, boxed caption, "Case No." and the judge on the third and fourth lines of the box, title, opening paragraph, footnote 1 at the foot. | PASS |
| 2 | exemplar p.2 | Body at double spacing; unnumbered argument-lead paragraphs. | PASS |
| 3 | exemplar p.3 | "Read generously..." paragraph; FACTUAL BACKGROUND heading; numbered facts 1 and 2. | PASS |
| 4 | exemplar p.4 | Facts 3 and 4; ARGUMENT centered; I. and A. headings with hanging labels. | PASS |
| 5 | exemplar p.5 | Standing argument; footnote 2 at the foot under a 2 in rule. | PASS |
| 6 | exemplar p.6 | Standing argument, continued. | PASS |
| 7 | exemplar p.7 | Standing conclusion; the page ends short because the B. heading is kept with the first two lines of its paragraph (two-line heading). | PASS |
| 8 | exemplar p.8 | B. heading (two lines, hanging); jurisdiction argument; footnote 3. | PASS |
| 9 | exemplar p.9 | II. and A. headings, OCPA paragraphs; footnote 4. | PASS |
| 10 | exemplar pp.11, 16 | B. heading; "[Pages 12 to 14 ...]" marker; CONCLUSION and its paragraph with the signature block on the same page: "Date:" at the left, "Respectfully submitted," and the /s/ block from 3 in, "Counsel for Defendant". | PASS |
| 11 | exemplar p.17 | CERTIFICATE OF SERVICE on its own page; the certificate paragraph; its signature block. | PASS |

## Pass stamp

`usage/.check-typst.txt` and `usage/.check-docx.txt`, written by `tools/check.sh` (typst 9 and docx 13 checks passed, 0 failed, 2026-10-22).

## Engines

Typst is the primary engine; both engines are on the shared cross-engine layout model (fb-595.68.33; docs/EVAL-LOOP.md, "Cross-engine gate"), and `eval.yaml` gates it (`params.cross_engine: gate`).

- typst (`typst/oked-motion-brief.typ`): `lib/typst/xengine.typ`, every line a box of its pitch (24 pt body, 13.8 pt caption, headings, quotations, signature block and footnotes), explicit spaces between blocks (24 pt court title to caption and caption to title, 12 pt title to body and above a heading, 24 pt above the signature block, 12 pt inside it), footnotes at 12 pt with 6 pt between notes and 8.5 pt from the text to the rule (with the gap, the 14.5 pt LibreOffice keeps above a note).
- docx: `docx/reference.xml` (`base="xengine"`, the face as `{font}`, Body Text Keep, Footnote Text at 12 pt in 13.8 pt lines with 6 pt after, the 12 pt page-number footer) and `docx/oked.lua`, which reads the sample chunk by chunk as typst does and writes every paragraph with the typst pitch and spaces (`require("docx.xengine")`); a paragraph that carries a footnote is left to pandoc (Body Text, Body Text Keep), so the notes are numbered 1 to 4 in one sequence. Every paragraph stands 1 twip in from the right margin: LibreOffice kept a word on a line 0.04 pt past the measure where typst wraps it. No shell: `docx/build-reference.sh`, `docx/render.sh` and the binary `reference.docx` are gone.
- The baseline docx failed DEF-CONT-001: LibreOffice printed the shell port's footnotes as 1, 1, 2, 3 where the sample has 1 to 4 (its section restarted the notes each section, and pandoc had read the whole sample at once; the exact trigger was not isolated). Written by `docx/oked.lua` (each chunk read alone with the notes it refers to, the last section from the recipe), they print 1 to 4. It also failed DEF-FONT-002 (EB Garamond). Both pass now; XENG-001..003 PASS (11 = 11 pages, 301/301 lines).
- Not produced by either engine: the TOC and TOA of LCvR 7.1(c) (gap 2).
