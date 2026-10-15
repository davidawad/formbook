# E.D. Ky. (kyed): motion brief

Doc type: **motion brief**, here the memorandum of law in support of a Fed. R. Civ. P. 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief/`. The motion itself, the proposed order and the notice are separate filings and are not generated (see the rules table). Nothing in this folder sets `status`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-seitz-2-25-cv-00166-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-seitz-discord-memo.md`: caption, introduction, background, legal standard, part of the argument (Section 230), conclusion, signature, certificate of service |
| typeface | face required: none (LR 5.2(a) asks for "at least 12-point proportionately-spaced font"; rule text read 2026-10-15) -> substitute: none, EB Garamond kept (`docs/FONTS.md`, "No face named") -> not applicable |
| render | ok (re-run 2026-10-15): `samples/OUTPUT-seitz-discord-memo.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EB Garamond Regular, Bold, Italic and BoldItalic embedded), no warnings |
| overlay | fail (re-run 2026-10-15): `tools/overlay.sh` exits 1 because `exemplars/FILED-EXAMPLE-*.pdf` is not in this checkout. The `OVERLAY-seitz-discord-memo.txt` committed earlier was not regenerated; no `OVERLAY-seitz-discord-memo.pdf` is in `samples/` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change; re-viewed 2026-10-15 after the re-render, no change) |
| BLOCKED | none |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`), which `tools/render.sh` and `tools/overlay.sh` read and write, not the `<id>.pdf` names in the brief.

## Governing rules

Each requirement has a stable ID (KYED-...) used in the template's comments.

| ID | Rule | Requirement | Where it lives in the template |
|---|---|---|---|
| KYED-FORM-001 | E.D. Ky. LR 5.2(a) | 8½ × 11 inch paper; margins of at least one inch on all sides; text double spaced, except block quotes, headings and footnotes. Primary source: the court's amended Civil Rules, August 2026 (`https://www.kyed.uscourts.gov/sites/kyed/files/KY_Amended_Civil_Rules_August_2026.pdf`). Read and quoted 2026-10-14. | `margin-all = 1in`, `line-pitch = 24pt`, `paper: "us-letter"`. |
| KYED-FORM-002 | E.D. Ky. LR 5.2(a) | At least 12-point proportionately spaced font. The rule sets the font for the paper as a whole; applying it to footnotes is this template's reading. | `type-size = 12pt`, footnote entries at `type-size`, `font-family = "EB Garamond"`. |
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
4. **Font.** LR 5.2(a) names no typeface, only "at least 12-point proportionately-spaced font" (rule text read from the court's Civil Rules PDF, 2026-10-15). Under `docs/FONTS.md` ("No face named") the template keeps EB Garamond, and the rule's 12-point minimum is met. The exemplar's Times New Roman is one filer's choice, not a rule requirement. At 12 pt Garamond sets smaller than that exemplar, so the text looks smaller and the sample runs 11 pages. The template does not switch to Liberation Serif, because the rule does not ask for it.
5. **Page limit (KYED-MOT-002).** The template does not count pages. The exemplar's memorandum runs 25 pages before its certificate, within the 25-page limit. The 25-page limit is for the author.
6. **Signature without a conclusion.** The keep-together rule above works when the body has a `# CONCLUSION` heading. Without one, the signature block can still start a page on its own.
7. **Heading numbers** are typed by the author, not generated. The exemplar does the same.
8. **Local practice not checked.** Judges' standing orders and any E.D. Ky. practice beyond the printed Civil Rules were not checked.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect the court-folder shape (`court.json`, `rules.md`); this doc-type folder does not have it and the brief does not ask for them. Render and overlay were run, and the review below is the Gate 2 record.

## Review of the rendered pages (Gate 2 record, 11 of 11 pages, 60 dpi, viewed after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, opening paragraph, I. INTRODUCTION, footnote 1 | OK. Caption rules and party designations right-aligned. |
| 2 | Introduction (end), II. BACKGROUND, A. | OK. |
| 3 | Background B, III. LEGAL STANDARD, IV. ARGUMENT, A., 1., footnote 2 | OK. Heading levels distinct. |
| 4 | Section 230 argument, 2., footnotes 3 and 4 | OK. Long footnotes single spaced at 12 pt. |
| 5 | 2. (Bride citation), a. heading, Grindr paragraph | OK. |
| 6 | Ohio decision, MySpace, the negligence paragraph | OK. |
| 7 | Negligence (end), strict liability, "Courts have repeatedly" | OK. |
| 8 | Torts of omission, failure to warn, the bracketed omission note | OK. |
| 9 | CONCLUSION, the conclusion sentence, date, signature block | OK. The conclusion and the signature are on one page, kept together. |
| 10 | CERTIFICATE OF SERVICE, the first six service blocks | OK. Service blocks single spaced. |
| 11 | Last service block, the `/s/` line and designation | OK. |

## Build record

Render and overlay, run after `export PATH="$HOME/tb/bin:$PATH"` (typst 0.15.0 from the micromamba env):

```sh
sh tools/render.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief samples/INPUT-seitz-discord-memo.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief seitz-discord-memo
```

Render line pitch: 24.0 pt on every body line (measured with `pdftotext -bbox-layout`); single-spaced caption, footnote and certificate lines at 13.7 to 13.8 pt; heading spacing 19.8 pt.

A layout defect found and fixed during the build: with `spacing: 0pt` between paragraphs, typst leaves no leading between paragraphs, so each new paragraph sat 7.8 pt under the last line of the one before it. The template sets paragraph spacing to the body leading (1.35 em, 16.2 pt), which restores the 24 pt pitch.

## Engines

DOCX engine (`docx/build-reference.sh` builds `docx/reference.docx`; `docx/kyed-motion-brief.lua` builds the caption, the keep-together of the conclusion with the signature block, the signature line and the certificate). Checked structurally only (see below).

- **Matches the typst form (reference settings):** US Letter; 1 in margins on all sides (`w:pgMar` 1440); EB Garamond (vendored) at 12 pt in the document defaults and every style used; body text at an exact 24 pt line pitch with a 0.5 in first-line indent; block quotation single spaced, 0.75 in each side; headings: centered caps (level 1), bold hanging at 0.5 in (level 2), bold indented (level 3), bold italic indented (level 4); footnotes are pandoc's native footnotes at 12 pt, single spaced; centered 12 pt page number in the footer; "Dated:" at the margin and "Respectfully submitted," at a 3.4 in tab stop; the conclusion keeps with the signature block (`keepNext`); the certificate of service starts on a new page, its service blocks single spaced.
- **Differs from typst:** the footnote separator is pandoc's default rule, not typst's 30% rule; the certificate service blocks use single spacing from the font metrics, not typst's added leading (about 13.8 pt per line in the typst render); pagination is not measured (typst gives 11 pages for `samples/OUTPUT-seitz-discord-memo.pdf`; the docx page count is unknown). No table of contents or table of authorities is produced (see the rules table).
- **BLOCKED:** `docx=blocked`. `docx.pdf` / page review: `soffice` (LibreOffice) is not installed on this box, so `samples/OUTPUT-seitz-discord-memo.docx.pdf` was not produced and no page was rendered or viewed (`pages_reviewed=0`). Font embedding and substitution in LibreOffice, and the no-repair-prompt check in Word and LibreOffice, are not verified.


Links: [District Court index for kyed](../README.md) | [Doc type: complaint](../complaint/README.md)
