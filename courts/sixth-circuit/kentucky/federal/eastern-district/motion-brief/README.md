# E.D. Ky. (kyed): motion brief

Doc type: **motion brief**, here the memorandum of law in support of a Fed. R. Civ. P. 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief/`. The motion itself, the proposed order and the notice are separate filings and are not generated (see the rules table). Nothing in this folder sets `status`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer: Stoll Keenon Ogden PLLC for Discord Inc.; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption, introduction, background, legal standard, part of the argument (Section 230), conclusion, signature, certificate of service |
| typeface | face required: none (LR 5.2(a) asks for "at least 12-point proportionately-spaced font"; rule text read 2026-10-15) -> Times New Roman (vendored), the house default (`docs/FONTS.md`), in all three engines |
| render | ok (2026-10-29, fb-595.17.17): `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 11 pages each, Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with E.D. Ky.'s local rules overlaid in `typst/layout.yaml` |
| overlay | `just overlay courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 11 of 11 on typst, latex and docx (2026-10-29, after the move onto the FRCP base; text layer and line boxes of every page, see the review below) |
| BLOCKED | none |

## Governing rules

Each requirement has a stable ID (KYED-...).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| KYED-FORM-001 | E.D. Ky. LR 5.2(a) | 8½ × 11 inch paper; margins of at least one inch on all sides; text double spaced, except block quotes, headings and footnotes. Primary source: the court's amended Civil Rules, August 2026 (`https://www.kyed.uscourts.gov/sites/kyed/files/KY_Amended_Civil_Rules_August_2026.pdf`). Read and quoted 2026-10-14. | The base: letter paper, one-inch margins, 24 pt double pitch, single 13.8 pt lines for headings, quotations and notes. |
| KYED-FORM-002 | E.D. Ky. LR 5.2(a) | At least 12-point proportionately spaced font. The rule sets the font for the paper as a whole; applying it to footnotes is this template's reading. | The base: 12 pt, footnotes too; `font-family` in `typst/kyed-motion-brief.typ`. |
| KYED-FIRST-001 | Fed. R. Civ. P. 7(b)(2), 10(a) | The rules on captions and other matters of form in pleadings apply to motions and other papers. Source: https://www.law.cornell.edu/rules/frcp/rule_7, read 2026-10-14. | `front` in `typst/layout.yaml`. |
| KYED-MOT-001 | Fed. R. Civ. P. 12(b)(6); E.D. Ky. LR 7.1(a) | The defense of failure to state a claim is raised by motion before pleading. The motion must state its grounds with particularity and the legal argument; the memorandum carries the argument. Sources: Rule 12 (https://www.law.cornell.edu/rules/frcp/rule_12) and LR 7.1(a), both read 2026-10-14. | Body: the author writes the argument; the template does not check the grounds. |
| KYED-MOT-002 | E.D. Ky. LR 7.1(d) | Motions and responses may not exceed 25 pages without leave of court. Replies may not exceed 15 pages. | `eval.yaml` `params.page_limit: 25` (DEF-LEN-001, every engine), counted with the certificate of service. |
| KYED-MOT-003 | E.D. Ky. LR 7.1(e), (h) | A party filing a motion also files a separate proposed order; a copy of any cited authority not available electronically is attached. Both are separate filings. | Not generated. |
| KYED-SIG-001 | Fed. R. Civ. P. 11(a) | The paper is signed by an attorney of record and states the signer's address, e-mail address and telephone number. | `closing`: `signature.date`, `signature.sign_line`, `signature.lines`. |
| KYED-SIG-002 | Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. Source: https://www.law.cornell.edu/rules/frcp/rule_5, read 2026-10-14. | `closing` (`when: certificate`): optional, present only when the frontmatter has `certificate`. The sample has one because the exemplar has one. |

Table of contents and table of authorities: not produced. The E.D. Ky. rules text read for this doc type (LR 7.1 and LR 5.2) does not require them, and the exemplar has neither.

Not produced (separate filings): the motion (LR 7.1(a)), the proposed order (LR 7.1(e)), copies of authorities not on electronic databases (LR 7.1(h)), and any hearing request (LR 7.1(f)).

## Layout

The generic FRCP brief with E.D. Ky.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there). The typst template `typst/kyed-motion-brief.typ` only names the face; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Page 1 begins with the caption (the exemplar does the same): the court's name and the division centered and bold; the parties at the left, ruled at their right and foot (the base's caption, which is the exemplar's), each party's designation a line under its names, "v." between them; "Civil Case No." (the frontmatter `case_label`) and the number at the right, centered on the parties; the title centered in bold underlined capitals.
- Body double spaced (24 pt), first-line indent 0.5 in.
- Headings are typed by the author with their numbers ("I. INTRODUCTION", "A. ...", "1. ...", "a. ..."), as in the exemplar. Level 1 centered bold capitals on the body pitch; level 2 bold at the margin, its later lines hung half an inch; level 3 bold half an inch in; level 4 bold italic an inch in; levels 2 to 4 single spaced, a single line above and below.
- Block quotations single spaced, three quarters of an inch in on both sides. Footnotes 12 pt, single spaced, under a 30 % rule.
- Signature: "Dated:" at the margin, then "Respectfully submitted," the `/s/` line and the signer's lines three inches in (the exemplar's), kept whole with the body's last paragraph.
- Certificate of service (optional): a new page, centered bold heading, the text at the body pitch, the counsel served two to a row (the exemplar's two columns), the `/s/` line and designation three inches in.
- Footer: centered page number on every page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `division` (optional), `caption.parties` (list of `{names: [...], designation: "..."}`; "v." is inserted between parties), `case_number`, `case_label` (optional; default "Civil Action No."), `brief_title`, `signature` (`date` (optional), `preamble` (optional lines above the sign line), `sign_line`, `signer` (unused, kept for the record), `lines` below the sign line), `certificate` (optional: `text`, `services` (list of blocks, each a list of lines), `sign_line`, `designation`).
- Body: ordinary markdown. `#`, `##`, `###`, `####` are the heading levels above. Case names and signals are italicized with `*...*`. Footnotes use `[^id]` references and `[^id]: text` definitions.

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for two or three filers. The search was CourtListener RECAP, `court=kyed`, `type=r`, queries "memorandum in support" with "motion to dismiss" and "motion to dismiss" (run 2026-10-14); *Seitz* is the only defendant's memorandum in support of a 12(b)(6) motion with a local RECAP copy found (see `usage/SOURCE.md`). Tier 2 is **not** judged against two filers.
2. **Partial transcription.** The sample transcribes the caption, the introduction, background, legal standard, Section 230 argument through the failure-to-warn paragraph (Part IV.A.2), and the conclusion, signature and certificate. Left out: the concealment claim and the rest of Part IV.A.2, Parts IV.B through IV.D, and the footnotes in those parts. The sample says so in an italic note before the conclusion.
3. **Italics.** The exemplar's text layer has no italic markup, so the case-name italics in the sample follow the usual convention.
4. **Section numbers (tier 3, ACCEPTED).** The exemplar sets a section's number at a Word tab stop before its centered, underlined title ("I.<tab>INTRODUCTION"); the template centers the number the author types with the title, not underlined. DEF-COVER-002 lists the difference as ACCEPTED (`eval.yaml` `cover_structure_accepted`).
5. **Local practice not checked.** Judges' standing orders and any E.D. Ky. practice beyond the printed Civil Rules were not checked.

## Review of the rendered pages (Gate 2 record, 11 of 11 pages on typst, latex and docx, 2026-10-29)

The three renders break every line and page alike (XENG-001..003 PASS on latex and docx), so one row per page covers all three. Reviewed from each page's text layer and line boxes (`pdftotext -layout`, `-bbox`, `fb measure`); this pod has no image viewer.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division, boxed caption with the case number at the right, underlined title, opening paragraph, I. INTRODUCTION, footnote 1 | OK. |
| 2 | Introduction (end), II. BACKGROUND, A. | OK. |
| 3 | Background B, III. LEGAL STANDARD, footnote 2 | OK. |
| 4 | IV. ARGUMENT, A., 1., "Disputes as to Section 230's application" | OK: the paragraph's last line, with the marks of footnotes 3 and 4, moves to p5 with its notes in every engine. |
| 5 | 2., a. heading, footnotes 3 and 4 | OK. |
| 6-8 | Grindr, MySpace, negligence, strict liability, torts of omission | OK. |
| 9 | Failure to warn, the bracketed omission note | OPEN (tier 2): the conclusion and the signature block, kept together, start p10, leaving the foot of p9 empty. |
| 10 | CONCLUSION, "Dated:", signature block | OK. |
| 11 | CERTIFICATE OF SERVICE, the seven service blocks two to a row, the `/s/` line and designation | OK. |

## Build record

```sh
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief --engine typst   # 12 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief --engine latex   # 15 passed, 0 failed
sh tools/check.sh courts/sixth-circuit/kentucky/federal/eastern-district/motion-brief --engine docx    # 16 passed, 0 failed
```

## Engines

typst (primary): `typst/main.typ` -> `typst/kyed-motion-brief.typ` -> `lib/typst/xdoc.typ` with `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml` (fb-595.17.17). latex and docx: generated by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua`, `docx/reference.xml`; do not edit them, change the layout and generate again). Gate 4 is `cross_engine: gate` (`eval.yaml`): XENG-001..003 PASS on latex and docx.

Links: [District Court index for kyed](../README.md) | [Doc type: complaint](../complaint/README.md)
