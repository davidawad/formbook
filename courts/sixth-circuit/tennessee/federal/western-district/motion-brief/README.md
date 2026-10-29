# tnwd: motion-brief

Doc type: **motion-brief**, the memorandum of law that supports a motion to dismiss under Fed. R. Civ. P. 12(b)(6) in the United States District Court for the Western District of Tennessee (`tnwd`), as this district's local rules require (LR 7.2(a)(1): a motion is accompanied by a supporting memorandum "so identified").
Folder: `courts/sixth-circuit/tennessee/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, Pentecost, Glenn & Tilly, PLLC; see `usage/SOURCE.md`) |
| typeface | **Times New Roman** named by the W.D. Tenn. CM/ECF manual, section "Setting up PDF Reader and Converting to PDF": "The court only allows use of the following fonts ... Times New Roman, Arial, and Courier New. Size of font must be (at least) 12 point." LR 7.1(b) itself names no face. Every engine sets the vendored Times New Roman (`fonts/`; Liberation Serif, metric-compatible, is only the declared fallback). |
| sample md | `usage/INPUT-motion-brief.md` (the whole 9-page filing: caption, background, standard, argument I to IV, conclusion, signature block, certificate of service) |
| render | ok (2026-10-29, fb-595.17.18): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 10 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with W.D. Tenn.'s local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay courts/sixth-circuit/tennessee/federal/western-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 10 of 10 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |

## Governing rules

Primary sources, fetched and read 2026-10-14:

- **W.D. Tenn. Local Rules** (revised 11.17.2025): the PDF linked from https://www.tnwd.uscourts.gov/local-rules (`https://www.tnwd.uscourts.gov/sites/tnwd/files/Local%20Rules%20%E2%80%93%20Revised%2011.17.%202025%20%28Addition%20of%20LR%2043.1%28h%29%29.pdf`).
- **Fed. R. Civ. P. 5, 7, 8, 10, 12** from https://www.law.cornell.edu/rules/frcp/rule_5, `.../rule_7`, `.../rule_8`, `.../rule_10`, `.../rule_12`.

| Rule | Requirement | Where it is in the layout |
|---|---|---|
| LR 7.1(a) | 8½ × 11 inch white paper, one-inch margins on all sides; the paper shows the attorney's name, address, telephone, e-mail and Board of Professional Responsibility number. | The base (letter, one-inch margins); `closing` (name, bar number, firm, lines). |
| LR 7.1(b) | Double-spaced (quotations, headings and footnotes may be single-spaced); no smaller than 12 point, footnotes included. | `pitch.body: 27.6` (Word's double line), single-spaced headings, quotations and footnotes (`heading`, `quote`, `footnote`); the base's 12 pt, footnotes too. |
| LR 7.1(d) | Page limits exclude captions, signature lines and certificates. | `eval.yaml` counts every page (the stricter reading). |
| LR 7.2(a)(1) | A motion is accepted only with a supporting memorandum, "so identified". | The title: `MEMORANDUM IN SUPPORT OF ... MOTION TO DISMISS` (the sample's `brief_title`). |
| LR 7.2(a)(1)(A)-(B) | Proposed order and certificate of consultation: **not required** for motions under Rule 12. | Not produced. |
| LR 7.2(e), LR 12.1(a)-(c) | Memoranda in support of a motion (a Rule 12(b) or (c) motion) not over 20 pages without leave; a reply not over 10 pages. | `eval.yaml` `params.page_limit: 20` (DEF-LEN-001, every engine). |
| LR 7.2(h), (i) | Citations to unreported decisions carry Westlaw or Lexis citations; internet materials are attached as PDFs. | Author content. |
| LR 11.1(b) | Signature block: "s/" then the filing user's name, attorney bar number, firm name, street address, telephone, primary e-mail. | `closing`. |
| Fed. R. Civ. P. 5(b)(2)(E) | Service by filing with the court's electronic-filing system is complete upon filing. | `certificate` frontmatter (`document`, `method`, `served_on`, `date`); the layout prints the certificate wording. |
| Fed. R. Civ. P. 7(b)(1), 10(a) | A motion in writing with its grounds and relief; a caption with the court's name, a title, a file number and the Rule 7(a) designation. | `front` (the file number `No.` opposite "v."). |
| Fed. R. Civ. P. 8(a), 12(b)(6) | The standards the memorandum argues. | Author content. |

Not produced: the motion itself (ECF No. 13; this is its memorandum, ECF No. 13-1), any proposed order, a certificate of consultation, a table of contents or authorities (the exemplar has none).

## Layout

The generic FRCP brief with W.D. Tenn.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/tnwd-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Court name and division centered, a double line below; the caption one row per party and one for "v.": each party's names, a blank line, its designation half an inch in; "v." at the margin a blank line from each, `No.` and the file number opposite it; a column of ")" beside every line (the model counts the lines of each row in every engine).
- The title bold and centered between two rules across the page, a blank line from each (the exemplar's).
- Body double-spaced (27.6 pt), first-line indent 0.5 in; paragraphs are not numbered.
- Headings single-spaced, bold, a blank line above and half of one below, kept with what follows: sections centered; point headings at the margin (the typed "I." with the text), their later lines hung half an inch.
- Block quotations single-spaced, half an inch in on both sides, 6.9 pt from the text. Footnotes 12 pt, single-spaced, 7 pt apart.
- Signature block from 3.25 in (LR 11.1(b) order): "Respectfully submitted,", "s/" name, "Attorney Bar No.", firm, address, telephone, e-mail, role; the date at the margin above when the sample gives one; kept whole with the last paragraph.
- Certificate of service on a page of its own (as filed), kept whole: title, the declaration double-spaced, the persons served, `DATE:`, firm and "s/" line.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`; `case_label` (default "No."); `division`; `caption.parties` (list of `{names: [...], designation}`); `brief_title`; `signature` (`signer`, `bar_number`, optional `firm`, `lines`); `date` (optional); `certificate` (optional: `document`, `method`, `served_on` (lines), `date`).
- Body: `#` section heading; `##` and `###` point headings (their numbers typed); `>` quotation; paragraphs; footnotes `text[^key]` with `[^key]: text`.
- Italic case names: `*Erie County, Ohio v. Morton Salt, Inc.*`, `*Id.*`, `*See*`.

## Known gaps and open choices

1. **One exemplar only.** Tier 2 asks for two or three filers. The search (CourtListener RECAP, `type=r`, `court=tnwd`) turned up other Rule 12 memoranda (ECF No. 21 in *Ewel v. University of Memphis*, 2:26-cv-02129; ECF No. 6 in *Brown v. Navy Federal Credit Union*, 2:26-cv-02414) whose PDFs RECAP did not have. Tier 2 is **not** judged against two filers (OPEN).
2. **The exemplar's caption says WESTERN DIVISION** while the case number carries the `1:` prefix (the Eastern (Jackson) office). The layout takes the division from the frontmatter; the sample transcribes the filing as captioned.
3. **Italic citations are inferred.** The filing's text layer has no italic markup; case names and signals are italic by the citation convention, chosen by the transcriber.
4. **Signature line.** The exemplar prints `By:` above `s/`; LR 11.1(b)'s sample has none, and the layout follows the rule's sample.
5. **Certificate wording** is the exemplar's (ECF and U.S. Mail), from the frontmatter; FRCP 5(b)(2)(E) governs the ECF method.
6. **Caption.** One `)` per line of the party and "v." rows (the model measures each row). The file number stands on the "v." line, as filed; the layout is for a caption of two sides (a third would print the number beside each "v.").

## Review of the rendered pages (Gate 2 record, 10 of 10 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx, 217/217 lines), so one row per page covers all three. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`); this pod has no image viewer. DEF-COVER-002 (page 1 against the exemplar: order, alignment, rules) passes on all three engines.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name and division; caption with the ")" column (17 lines, one per wrapped line of the long defendant name), `No.` opposite "v."; the two-line title between two rules; the lead-in; BACKGROUND | OK. |
| 2-3 | Background, STANDARD, ARGUMENT, point I. | OK. |
| 4-5 | Points II. (two lines, the second hung), III. and the start of IV. | OK. |
| 6-8 | Point IV. Page 8 ends about eight lines short: CONCLUSION, its paragraph and the signature block are kept together and open page 9 | ACCEPTED (tier 2: the signature never stands alone). |
| 9 | CONCLUSION, the paragraph, the signature block | OK. |
| 10 | The certificate of service on its own page | OK. |

Tier 2: the exemplar runs to 9 pages, ours to 10 (the kept conclusion above); the exemplar justifies its text, ours is ragged on the cross-engine model (ACCEPTED).

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/tennessee/federal/western-district/motion-brief --engine typst   # 12 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/tennessee/federal/western-district/motion-brief --engine latex   # 15 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/tennessee/federal/western-district/motion-brief --engine docx    # 16 passed, 0 failed
```

`tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has none, so it does not run here.

## Engines

typst (primary): `typst/main.typ` -> `typst/tnwd-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.18). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx. BLOCKED: none.
