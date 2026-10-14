# iand: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Iowa (`iand`).
Folder: `courts/eighth-circuit/iowa/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-iowa-rotocast-fuse-2-26-cv-01019-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-iowa-rotocast-complaint.md`: the complete complaint (caption, 49 paragraphs, three counts, prayer, jury demand, signature block) |
| render | ok: `samples/OUTPUT-iowa-rotocast-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-iowa-rotocast-complaint.pdf` and `.txt` (`tools/overlay.sh`) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Iowa LR 10(a) | 8 1/2 x 11 inch paper. Source: https://www.iand.uscourts.gov/sites/iand/files/Local%20Rules%208.1.2020%20edits.%20clean.pdf (Local Rules, "Revised August 1, 2020", effective December 1, 2020; the posted copy is the version checked). | `page-w`, `page-h`. |
| N.D. Iowa LR 10(b)(1) | Double spaced. | `pitch = 24pt`, `body-leading = 1.35em`; every paragraph and heading is rounded to whole 24 pt lines (`on-grid`). |
| N.D. Iowa LR 10(b)(2) | Printed on one side only. | Single-sided PDF. |
| N.D. Iowa LR 10(b)(3) | Top margin of at least 1 inch. | `margin = 1in` on all sides. |
| N.D. Iowa LR 10(b) (last paragraph) | Documents of more than one page are numbered at the bottom of each page. | `footer` (centered page number). |
| N.D. Iowa LR 10(d) | Caption: district and division, case number, names of the litigants per FRCP 10(a), designation of the content, and the party filing. | `court-title` (district; `division` from frontmatter), `caption` (parties, `No.`, title, `JURY DEMAND`). |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, and the Rule 7(a) designation. | As LR 10(d). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered: true`; paragraphs are numbered by the template; `UNNUMBERED:` marks the prayer's WHEREFORE and the jury demand. |
| Fed. R. Civ. P. 8(a) | Short and plain statement; this is content, not template layout. | Not checked by the template. |
| Fed. R. Civ. P. 38 | Jury demand. | `jury_demand: true` puts the caption line; the demand paragraph is in the body. |
| N.D. Iowa LR 7.1 | Disclosure statement, if required by the rule. | Not produced by this template (a separate filing). |

Not produced by this template (separate filings): the civil cover sheet (JS-44); the summons; any disclosure statement.

## Layout

- Court title on the first page: three centered lines (district, division); the caption below it.
- Caption: parties on the left, closed by a column of `)` marks; case number and designation on the right.
- Body: double spaced; first-line indent 0.5 in; body text ragged right (no justification asserted).
- Headings: level 1 centered caps (PRELIMINARY STATEMENT, FACTS, PRAYER FOR RELIEF); level 2 centered bold (COUNT I: ...). A heading is kept with the paragraph after it.
- Prayer items (markdown list) are lettered A., B., C. ...
- Signature block after the body: "Dated:" line, "Respectfully submitted," firm, "By: /s/" and the signer, then the counsel lines (single spaced).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: a `#` heading, a list, the word `SIGNATURE` (places the signature block), or a paragraph.
- Frontmatter: `case_number`, `numbered` (true for complaints), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `division`, `brief_title`, `jury_demand`, `lead_in` (unnumbered opening paragraph), `date`, `signature` (`firm` lines, `signer`, `lines`).
- A paragraph that begins with `UNNUMBERED:` is not numbered.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **Only one exemplar.** Tier 2 asks for 2 or 3 filers. The search (CourtListener RECAP, `court=iand`, complaints filed 2026-04 to 2026-10) also found Kinetiq, Inc. v. CCR Media, LLC (1:26-cv-00162, 29 pages, verified complaint with exhibits, RECAP doc gov.uscourts.iand.71680.1.0.pdf) and Vohs v. Canpotex (1:26-cv-00101, complaint with jury demand; text not checked). Those were not saved, because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Typeface and size.** The N.D. Iowa Local Rules text (LR 10) names no typeface and no point size, so the template uses EB Garamond 12 pt, the only serif vendored in `fonts/`. The exemplar is Times-metric (Times Roman embedded), so EB Garamond looks smaller at 12 pt. Whether the court wants a larger apparent size is a question for David; a vendored Times-metric font would remove the difference.
3. **Caption.** The party column is closed by a column of `)` marks, as in the exemplar. The exemplar's caption has the party names in the left column and the case number on the right; the template reproduces that structure without measuring coordinates.
4. **Sub-items inside a paragraph.** The exemplar's paragraph 31 lists prior-art items (a) to (f) as separate indented lines inside one numbered paragraph. The sample runs them on as one paragraph, so the paragraph numbers match the exemplar (1 to 49) but the indentation of the sub-items does not.
5. **Exhibits and attachments** are referred to by letter in the text but not included in the sample (they are not part of the complaint's text layer).
6. **Overlay pairing.** The sample is the full complaint (9 pages in the exemplar, 8 in our render). Pages pair by shared words; the page overlap is 36% to 87%, which reflects the typeface and the double spacing applied by the rule, not a transcription gap. The overlay is a diagnostic, not a score.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. Render and overlay were run; the review below is the Gate 2 equivalent.
8. **Output names.** `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name, so the sample is `INPUT-<id>.md` and the outputs are `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt` (the file-role naming of CLAUDE.md, not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief).
9. **Version of the local rules.** The copy checked is dated "Revised August 1, 2020". No later revision was found in the search; the current posting should be confirmed before the template is treated as final.

## Review of the rendered pages (samples/OUTPUT-iowa-rotocast-complaint.pdf)

- Page 1: court title (3 lines), caption with `)` column, `No. 2:26-cv-1019`, COMPLAINT, JURY DEMAND; lead-in paragraph; PRELIMINARY STATEMENT; paragraphs 1 to 6. Pass.
- Page 2: paragraphs 7 to 14, FACTS heading. No heading at the foot of a page. Pass.
- Page 3: paragraphs 15 to 24, double spaced on the 24 pt grid. Pass.
- Page 4: paragraphs 25 to 31; COUNT I heading; paragraph 31 with the prior-art items. Pass.
- Page 5: paragraphs 32 to 35; COUNT II heading at the foot with its first paragraph (35). Pass.
- Page 6: paragraphs 36 to 45; COUNT III heading. Pass.
- Page 7: paragraphs 46 to 48; PRAYER FOR RELIEF heading; WHEREFORE (unnumbered); items A to G. Pass.
- Page 8: JURY DEMAND heading and unnumbered demand; date; signature block (firm, By: /s/, counsel lines, ATTORNEYS FOR PLAINTIFF). Pass.

Heading size: the first render had headings at typst's default heading size (larger than body text) and two-line headings that collided with the following text. Both were fixed (body size; double-spaced headings) and every page re-viewed.
