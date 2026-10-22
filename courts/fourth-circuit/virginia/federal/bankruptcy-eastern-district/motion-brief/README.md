# vaeb: motion with memorandum

Doc type: **motion with memorandum of points and authorities** in the United States Bankruptcy Court for the Eastern District of Virginia (`vaeb`). The sample is a motion for summary judgment with its memorandum, the form the exemplar uses. The template also serves other motions with a memorandum (LBR 9013-1(F)); the summary-judgment checks apply only when `summary_judgment: true` is in the frontmatter.
Folder: `courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, defendant's counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption, opening, the full Statement of Undisputed Material Facts (28 numbered paragraphs), the Standard of Review, the Visa prepaid card and family support sections, the Conclusion and the signature. The asset-sale, means-test, gambling and garnishment sections are omitted (the exemplar is 19 pages; the sample is 12). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (the earlier EB Garamond render, before fb-595.68; the template now sets Times New Roman) |
| overlay | ok: `usage/OVERLAY-amiri-motion-for-summary-judgment.pdf` and `.txt` (page map below) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed; pages 8 to 12 on the final build, pages 1 to 7 on a build that differs only from page 8 onward in heading levels) |

File names follow the repo's role-prefix convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default. The brief's `<id>.md` / `<id>-overlay.pdf` names were not used for that reason.

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where in the template |
|---|---|---|
| FRBP 9013 | A motion must be in writing; it must state its grounds with particularity and set forth the relief sought. Text fetched from Cornell LII 2026-10-14. | Assert: the body contains "WHEREFORE" (the relief sought). The grounds are the author's text. |
| E.D. Va. LBR 9013-1(B), (C) | Written motion; grounds stated with particularity; relief sought; whether a hearing is requested. | As above. A hearing request is the author's text; no hearing notice is generated (see gaps). |
| E.D. Va. LBR 9013-1(F)(1) | A motion is accompanied by a memorandum of points and authorities setting out the facts, the reasons and the authorities; the memorandum may be combined with the motion in one pleading. | The template renders one combined document; the body carries the memorandum. |
| E.D. Va. LBR 7056-1(C) | A motion for summary judgment is accompanied by a memorandum with a section entitled "Statement of Undisputed Material Facts" listing the facts in numbered paragraphs, each with support under Fed. R. Civ. P. 56(c)(1). | `numbered_sections: ["STATEMENT OF UNDISPUTED MATERIAL FACTS"]` numbers that section's paragraphs automatically. Assert (when `summary_judgment: true`): the section exists and is numbered. |
| E.D. Va. LBR 5005-1(C)(1), (2), (3), (5) | As for the adversary complaint: one side; caption with debtor, case number, chapter and adversary number; letter size; top margin not less than 1 1/2 inches; attorney identified on page 1. | Same as `adversary-complaint/` (`top-margin = 1.5in`; caption; `counsel` block). |
| FRBP 7010; Fed. R. Civ. P. 10(a) | Caption of a paper filed in an adversary proceeding. | `caption`, `title`; assert: division, parties and title. |

Governing local rules: the E.D. Va. Local Bankruptcy Rules, version effective December 1, 2025 (Ver. 11/26/25), https://www.vaeb.uscourts.gov/sites/vaeb/files/LBR%20%20changes%2012-1-2025.pdf. LBR 9013-1(C) and (F) and LBR 7056-1(C) were read in the July 16, 2025 text (https://www.vaeb.uscourts.gov/sites/vaeb/files/LBR%20%20changes%207-16-2025.pdf); the December text has the same headings and the same LBR 5005-1 wording.

Not produced by this template (separate papers that the rules require with the motion): the notice of hearing and the response deadline notice (LBR 9013-1(H), (M); for summary judgment, LBR 7056-1(B) and (H), which require the notice to conform to Official Form 420A and to carry the bold response notice); the proposed order (LBR 9022-1); the Adversary Proceeding Cover Sheet (only with the complaint, LBR 7003-1).

## Layout

- Letter size, 1.5 inch top margin, 1 inch other margins, page numbers centered at the foot.
- Font: Times New Roman 12 pt (the pinned install, docs/FONTS.md rule 1; Liberation Serif from `fonts/` as fallback). No E.D. Va. rule names a typeface (see Known gaps).
- Double spacing (1.35 em leading, 24 pt pitch at 12 pt); single spacing for the counsel block, caption, table, signature block and service list.
- Counsel block at the top left of page 1; court name and division centered; caption as a three-column grid; title centered in capitals.
- Level 1 headings: centered bold capitals (LEGAL ARGUMENT, STATEMENT OF UNDISPUTED MATERIAL FACTS, the lettered sections are level 2). Level 2: bold, left (A. Standard of Review; B. Factual Analysis; C. Conclusion). Level 3: bold italic (1) Summary Judgment). Headings are typed by the author; the template does not number them.
- Paragraphs: first-line indent 0.5 in. Only the paragraphs under the Statement of Undisputed Material Facts are numbered (1, 2, ...); argument paragraphs are not, as in the exemplar.
- Lists render as (a), (b), ...
- Case names are italicized only where the author marks them with `*...*`.
- Signature block: "Respectfully submitted," then "/s/ Name" (no firm line; the exemplar has none), the signer's line and the address, bar number, telephone and email.
- Certificate of service: generated only when the frontmatter has `service` (the exemplar has none).

## Overlay (`usage/OVERLAY-amiri-motion-for-summary-judgment.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. Page map (`usage/OVERLAY-amiri-motion-for-summary-judgment.txt`):

```
ours p.1  filed p.1   word-overlap 86.3%
ours p.2  filed p.2   word-overlap 66.1%
ours p.3  filed p.3   word-overlap 56.7%
ours p.4  filed p.5   word-overlap 48.2%
ours p.5  filed p.6   word-overlap 54.5%
ours p.6  filed p.7   word-overlap 84.0%
ours p.7  filed p.8   word-overlap 64.4%
ours p.8  filed p.10  word-overlap 52.4%
ours p.9  filed p.11  word-overlap 53.2%
ours p.10 filed p.12  word-overlap 46.8%
ours p.11 filed p.13  word-overlap 36.7%
ours p.12 filed p.19  word-overlap 52.3%
```

The overlay is a diagnostic, not a score. Page 12 pairs with the exemplar's signature page (19) because the sample ends at the signature block and skips the exemplar's pages 14 to 18 (the omitted sections). The differences that matter are the choices the template makes on purpose: the 1.5 inch top margin, the chapter and case number in the caption, and the typeface.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers, so tier 2 is not judged against two filers here. Other candidates checked: *King v. Park* (25-01025, Doc 10, Defendant's Motion and Memorandum to Dismiss, 3 pages, Scott J. Newton for Jong Kim) is usable but too short to show a full memorandum; *Elisium Dubai Perfume v. Patrick's Holdings* (25-01041) memoranda are listed in the CourtListener docket search without a storage path, so they were not downloaded.
2. **Typeface.** The exemplar's body is an embedded CID TrueType face (name not in the text layer), with non-embedded Times-Bold and Times-Italic elsewhere, so it is taken to be a Times-style serif. The template uses Times New Roman (docs/FONTS.md rule 6, the house standard; the pinned install of rule 1), so the face now matches the exemplar's Times-style serif. (Until fb-595.68 it used EB Garamond, which has a smaller x-height at 12 pt.) The 12 pt minimum is met.
3. **Top margin.** The rule requires 1.5 inches (LBR 5005-1(C)(3)). The exemplar's body text starts about 1 inch from the top (measured from the text layer's positions). The template follows the rule. Recorded as OPEN for David: confirm whether the 1.5-inch rule applies to the body text or to the whole page with the court's ECF header in it.
4. **Caption contents.** The exemplar's caption gives the bankruptcy case number in the "In re" block and no chapter. The template prints "Chapter 7" and "Case No." in the right column, because LBR 5005-1(C)(2) requires the debtor's name, case number, chapter and adversary number on each document. A rule-driven difference, not a style one.
5. **Counsel position.** The exemplar puts the counsel block at the foot of page 1; the template puts it at the top left (LBR 5005-1(C)(5) requires it on the first page; either place complies). Recorded as ACCEPTED.
6. **Italics.** The exemplar's text layer has no italic markup, so the case-name italics in the sample are the transcriber's, not the filing's.
7. **Transcription.** The sample is a portion of the filing (see the table above). The omitted sections are recorded in the sample's frontmatter (`transcription`), not in the body, so the render shows no gap marker. Heading levels in the sample are the transcriber's choice, not the filing's.
8. **Notice of hearing.** Not produced (see Governing rules). A summary judgment motion in this court needs its own notice; the exemplar's notice is not part of this doc type.
9. **Summary judgment checks.** The "Statement of Undisputed Material Facts" check asserts the heading and that the section is numbered. It does not check that each fact cites evidence (LBR 7056-1(C) requires it); that is the author's responsibility.

## Review of the rendered pages (12 pages; the earlier EB Garamond render, before fb-595.68)

- Page 1: counsel block (top left), court and division, caption with the "In re" block (Chapter 7, Case No. 25-12110-BFK) and the adversary block (Case No. 26-1002-BFK), the title, the opening paragraph and the first body paragraph. Pass.
- Page 2: STATEMENT OF UNDISPUTED MATERIAL FACTS heading (centered), paragraphs 1 to 5, and the start of the (a)-(e) list. Pass.
- Page 3: list item (e) and paragraphs 6 to 12. Pass.
- Page 4: paragraphs 13 to 21. Pass.
- Page 5: paragraphs 22 to 26 and the start of the (a)-(f) list in paragraph 26. Pass.
- Page 6: list items (f) and paragraphs 27 to 28; LEGAL ARGUMENT (centered); A. Standard of Review (bold, left); 1) Summary Judgment (bold italic); the start of the body. Pass.
- Page 7: Summary Judgment and 2) Denial of Discharge under 727(a)(4); italic case names. Pass.
- Page 8: 2) continued; B. Factual Analysis (bold, left). Pass.
- Page 9: Closing of Bank of America Accounts and Visa Prepaid Card (bold italic); body. Pass.
- Page 10: Visa continued; Family Support on Schedule I. Pass.
- Page 11: Family Support continued; C. Conclusion; body; the omitted-sections gap is not shown (see gap 7). Pass.
- Page 12: end of Conclusion; WHEREFORE paragraph; "Respectfully submitted," and the signature block. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`: fb render builds the reference document from the shared cross-engine recipe in the typst face) and `docx/vaeb.lua` (counsel block, court title, caption, numbered Statement of Undisputed Material Facts, lettered lists, "Respectfully submitted," signature block).
- Matches typst: Times New Roman 12 pt (the PDF embeds TimesNewRomanPSMT); exact 24 pt double and 13.8 pt single lines; 0.5 in first-line indent; letter size, 1.5 in top margin, 1 in other margins; centered page number; headings at 12 pt on the 24 pt body pitch, level 1 centered bold capitals, level 2 bold left, level 3 bold italic; caption as three columns (3.4 in, 0.3 in, 2.8 in); the signature block and the list spacing; 5 pt table insets and 0.5 pt rules.
- Differs (recorded on the earlier build by `docx/build-reference.sh`, before the fb-595.68 cross-engine port; `eval.yaml` now gates the docx on typst's line and page breaks): (1) Word-native widow and orphan control moves one or two lines to the next page, so the sample runs to 13 pages in the docx and 12 in typst; (2) the closing WHEREFORE paragraph is kept with the signature block (keep-with-next), so the signature is not left alone on a page; (3) LibreOffice places exact-height lines about 3 pt lower than typst; (4) the caption and signature blocks are borderless tables.
- No TOC or TOA, no pleading-paper line numbers (this court does not use them).
- BLOCKED: none recorded. `sh tools/check.sh <court> --engine docx` exits 2 before any gate runs: the court folder has no `checks.yaml` (Gate 1) and no `reviews/`, so the gates cannot pass yet. That is a court-level prerequisite, not a docx limit.
