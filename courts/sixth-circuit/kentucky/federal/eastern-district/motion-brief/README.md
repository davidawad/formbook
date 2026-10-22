# E.D. Ky. (kyed): motion brief

Doc type: **motion brief**, here the memorandum of law in support of a Fed. R. Civ. P. 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief/`. The motion itself, the proposed order and the notice are separate filings and are not generated (see the rules table). Nothing in this folder sets `status`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption, introduction, background, legal standard, part of the argument (Section 230), conclusion, signature, certificate of service |
| typeface | face required: none (LR 5.2(a) asks for "at least 12-point proportionately-spaced font"; rule text read 2026-10-15) -> Times New Roman (vendored), the house default (`docs/FONTS.md`); the docx names the same face (`{font}` in `docx/reference.xml`) |
| render | ok (2026-10-22, fb-595.68.29): `usage/OUTPUT-motion-brief.typst.pdf` 11 pages and `usage/OUTPUT-motion-brief.docx.pdf` 12 pages, Times New Roman only, no warnings; both on the cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`); XENG-001..003 REPORTED, not gated (see "Engines") |
| overlay | fail (re-run 2026-10-15): `tools/overlay.sh` exits 1 because `usage/SAMPLE-*.pdf` is not in this checkout. The `OVERLAY-seitz-discord-memo.txt` committed earlier was not regenerated; no `OVERLAY-seitz-discord-memo.pdf` is in `usage/` |
| pages reviewed | 11 of 11 typst and 12 of 12 docx (side by side, 50 dpi, 2026-10-22, after the last template change) |
| BLOCKED | none |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`), which `tools/render.sh` and `tools/overlay.sh` read and write, not the `<id>.pdf` names in the brief.

## Governing rules

Each requirement has a stable ID (KYED-...) used in the template's comments.

| ID | Rule | Requirement | Where it lives in the template |
|---|---|---|---|
| KYED-FORM-001 | E.D. Ky. LR 5.2(a) | 8½ × 11 inch paper; margins of at least one inch on all sides; text double spaced, except block quotes, headings and footnotes. Primary source: the court's amended Civil Rules, August 2026 (`https://www.kyed.uscourts.gov/sites/kyed/files/KY_Amended_Civil_Rules_August_2026.pdf`). Read and quoted 2026-10-14. | `margin-all = 1in`, `line-pitch = 24pt`, `paper: "us-letter"`. |
| KYED-FORM-002 | E.D. Ky. LR 5.2(a) | At least 12-point proportionately spaced font. The rule sets the font for the paper as a whole; applying it to footnotes is this template's reading. | `type-size = 12pt`, footnote entries at `type-size`, `font-family = ("Times New Roman", "Liberation Serif")`. |
| KYED-FIRST-001 | Fed. R. Civ. P. 7(b)(2) | The rules on captions and other matters of form in pleadings apply to motions and other papers. Source: https://www.law.cornell.edu/rules/frcp/rule_7, read 2026-10-14. | `court-title`, `caption`, `title` frontmatter. |
| KYED-MOT-001 | Fed. R. Civ. P. 12(b)(6); E.D. Ky. LR 7.1(a) | The defense of failure to state a claim is raised by motion before pleading. The motion must state its grounds with particularity and the legal argument; the memorandum carries the argument. Sources: Rule 12 (https://www.law.cornell.edu/rules/frcp/rule_12) and LR 7.1(a), both read 2026-10-14. | Body: the author writes the argument; the template does not check the grounds. |
| KYED-MOT-002 | E.D. Ky. LR 7.1(d) | Motions and responses may not exceed 25 pages without leave of court. Replies may not exceed 15 pages. | Not enforced: the template does not count pages (see gaps). |
| KYED-MOT-003 | E.D. Ky. LR 7.1(e), (h) | A party filing a motion also files a separate proposed order; a copy of any cited authority not available electronically is attached. Both are separate filings. | Not generated. |
| KYED-SIG-001 | Fed. R. Civ. P. 11(a) | The paper is signed by an attorney of record and states the signer's address, e-mail address and telephone number. | `signature-block`: `signature.sign_line`, `signature.lines`. |
| KYED-SIG-002 | Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. Source: https://www.law.cornell.edu/rules/frcp/rule_5, read 2026-10-14. | `certificate-block`: optional, present only when the frontmatter has `certificate`. The sample has one because the exemplar has one. |

Table of contents and table of authorities: not produced. The E.D. Ky. rules text read for this doc type (LR 7.1 and LR 5.2) does not require them, and the exemplar has neither. The Northern District of California template's TOC/TOA rule does not carry over.

Not produced (separate filings): the motion (LR 7.1(a)), the proposed order (LR 7.1(e)), copies of authorities not on electronic databases (LR 7.1(h)), and any hearing request (LR 7.1(f)).

## Layout

- Page 1 begins with the caption, not a cover page (the exemplar does the same): court title lines centered and bold; "Civil Action No." (here "Civil Case No." in the frontmatter `case_label`) centered; a rule; the party column (names, designation right-aligned, "v." between parties); a rule; the title centered and bold.
- Body: the author types the paragraph text; the template sets first-line indents of 0.5 in and double spacing, so paragraphs are separated by one 24 pt line.
- Headings are typed by the author with their numbers ("I. INTRODUCTION", "A. ...", "1. ...", "a. ..."), as in the exemplar. Level 1 is centered caps; level 2 bold at the margin with a hanging indent; level 3 bold, indented 0.5 in; level 4 bold italic, indented 1 in.
- Block quotations are single spaced and indented both sides. Footnotes are single spaced at 12 pt, with a rule above them.
- Conclusion and signature block: when the body has a `# CONCLUSION` heading, the conclusion and the signature block are kept together in one unbreakable block, so the signature does not stand alone on a page. The footnote definitions must come before `# CONCLUSION` in the sample.
- Signature block at the right half of the page: "Dated:" at the left margin, then "Respectfully submitted," and the `/s/` line, signer, firm and designation.
- Certificate of service (optional): a new page, centered caps heading, the text, the service list (one block per counsel group, single spaced, in the order the exemplar gives), and the signature line with designation.
- Footer: centered page number.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between parties), `case_number`, `case_label` (optional; default "Civil Action No."), `title`, `date`, `signature` (`sign_line`, `signer` (unused by the template, kept for the record), `lines` below the sign line), `certificate` (optional: `text`, `services` (list of blocks, each a list of lines), `sign_line`, `designation`).
- Body: ordinary markdown. `#`, `##`, `###`, `####` are the heading levels above. Case names and signals are italicized with `*...*`. Footnotes use `[^id]` references and `[^id]: text` definitions, placed before `# CONCLUSION`.
- Not supported: tables, raw typst.

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the exemplar page that shares the most words: ours p.1-8 with filed p.1, 2, 3, 5, 6, 7, 8, 9; ours p.9 with filed p.25; ours p.10 with filed p.26; ours p.11 with filed p.26 (word overlap 16-89%). The pairing is coarse because the sample is partial and the page breaks differ: the exemplar's memorandum runs 25 pages before its certificate; the sample runs 9 pages of memorandum and 2 of certificate. Red is our render, blue the exemplar, black both. The text lines do not coincide (different font, page breaks, and the exemplar's ECF header). The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one filed document per doc type; that is saved. Tier 2 asks for two or three filers. The search was CourtListener RECAP, `court=kyed`, `type=r`, queries "memorandum in support" with "motion to dismiss" and "motion to dismiss" (run 2026-10-14). Results that were checked: *Mohler v. City of Ashland*, 0:26-cv-00066 (the motion itself, 10 pp.; its memorandum is a separate attachment that was not downloaded); *Davis v. Bell*, 0:26-cv-00065 (a response to a motion; its attachment is a memorandum supporting the response); *Johnson v. Dick*, 5:26-cv-00244 (a response to two motions). *Seitz* is the only defendant's memorandum in support of a 12(b)(6) motion with a local RECAP copy found in those results. Tier 2 is **not** judged against two filers.
2. **Partial transcription.** The sample transcribes the caption, the introduction, background, legal standard, Section 230 argument through the failure-to-warn paragraph (Part IV.A.2), and the conclusion, signature and certificate. Left out: the concealment claim and the rest of Part IV.A.2, Parts IV.B through IV.D, and the footnotes in those parts. The sample says so in an italic note before the conclusion. Footnotes 1 to 4 are transcribed.
3. **Italics.** The exemplar's text layer has no italic markup, so the case-name italics in the sample follow the usual convention and were not checked against the exemplar.
4. **Font.** LR 5.2(a) names no typeface, only "at least 12-point proportionately-spaced font" (rule text read from the court's Civil Rules PDF, 2026-10-15). The template sets Times New Roman 12 pt, the house default (`docs/FONTS.md`), as the exemplar does.
5. **Page limit (KYED-MOT-002).** The template does not count pages. The exemplar's memorandum runs 25 pages before its certificate, within the 25-page limit. The 25-page limit is for the author.
6. **Signature without a conclusion.** The keep-together rule above works when the body has a `# CONCLUSION` heading. Without one, the signature block can still start a page on its own.
7. **Heading numbers** are typed by the author, not generated. The exemplar does the same.
8. **Local practice not checked.** Judges' standing orders and any E.D. Ky. practice beyond the printed Civil Rules were not checked.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect the court-folder shape (`court.json`, `rules.md`); this doc-type folder does not have it and the brief does not ask for them. Render and overlay were run, and the review below is the Gate 2 record.

## Review of the rendered pages (Gate 2 record, 11 of 11 typst pages and 12 of 12 docx pages, viewed 2026-10-22 after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, case number, caption between two rules, title, opening paragraph, I. INTRODUCTION, footnote 1 | OK, both engines alike. Designations right-aligned. |
| 2 | Introduction (end), II. BACKGROUND, A. | OK, alike. |
| 3 | Background B, III. LEGAL STANDARD, footnote 2 | OK, alike. |
| 4 | IV. ARGUMENT, A., 1., "Disputes as to Section 230's application" | OPEN (tier 2): typst sets the paragraph's last line, which carries the marks of footnotes 3 and 4, at the foot of p4 and the two notes (20 lines) on p5, a page after their marks; the docx carries that line to p5 with its notes. From here on the docx runs one line later. |
| 5 | 2., a. heading, footnotes 3 and 4 | OK in each engine (the docx one line later). |
| 6-8 | Grindr, MySpace, negligence, strict liability, torts of omission | OK in each engine (the docx one line later). |
| 9 | Failure to warn, the bracketed omission note; typst: CONCLUSION and the signature block | OK. In the docx the conclusion and the signature block, kept together, move to p10. |
| 10 | typst: CERTIFICATE OF SERVICE, five service blocks; docx: CONCLUSION, signature | OK. |
| 11 | typst: the last two service blocks, the `/s/` line and designation; docx: the certificate | OK. |
| 12 | docx only: the last two service blocks, the `/s/` line and designation | OK. |

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief --engine typst
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief --engine docx
```

Body lines on a 24 pt pitch; headings of levels 2 to 4, footnotes, the caption, the signature and the certificate on single 13.8 pt lines, in both engines (`lib/typst/xengine.typ`; the docx in exact line spacing of the same twips). A footnote is kept whole in both engines (split, typst would start it on the page before its mark).

## Engines

DOCX engine (fb-595.68.29): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`; `fb render` builds `reference.docx` from it) and `docx/kyed-motion-brief.lua` (the court title, the caption between two rules, the title, the headings, the conclusion kept with the signature block, the certificate of service on a new page; footnotes are pandoc's own, in Footnote Text; a paragraph with a footnote has no widow control, in typst too). No shell script. The LibreOffice PDF breaks every line as the typst render up to p4 (296/305 lines alike), but XENG-001..003 stay REPORTED (`eval.yaml`: `cross_engine: report`): where a line's footnotes do not fit below it, typst keeps the line and moves the notes to the next page, LibreOffice moves the line with them (the p4 finding above), so every later page ends one line apart. No setting of either engine aligns the two; typst would need to carry the line over itself. No latex engine in this folder.

Links: [District Court index for kyed](../README.md) | [Doc type: complaint](../complaint/README.md)
