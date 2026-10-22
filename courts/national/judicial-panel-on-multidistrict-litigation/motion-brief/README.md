# JPML: motion-brief (motion to transfer under 28 U.S.C. § 1407, with memorandum of law)

Doc type: **motion-brief**. Court: United States Judicial Panel on Multidistrict Litigation. Folder: `courts/national/judicial-panel-on-multidistrict-litigation/motion-brief/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 11 of 11. Nothing here sets a court-level `court.json` status. The court root (`../README.md`, `../court.json`, and any root `typst/` or `usage/`) is untouched.

## Governing rules

Source: Rules of Procedure of the United States Judicial Panel on Multidistrict Litigation, **effective February 19, 2026** (the rules' own cover page). Public PDF at https://www.jpml.uscourts.gov/sites/jpml/files/Panel%20Rules%20Effective%202-19-2026.pdf (found by search; the JPML site returned 404 to direct requests from this box). Text read and quoted from the PDF on 2026-10-14. Rule numbers below are the 2026 numbers; the 2011 rules number the form-of-papers rule differently, and are superseded.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| JPML-FIRST-001 | Rule 3.2(a)(i) | Each case document bears the heading "Before the United States Judicial Panel on Multidistrict Litigation," the identification "MDL No.___," and the descriptive title. | `panel-heading`, `caption` (cover and motion page 1) |
| JPML-FORM-001 | Rule 3.2(a)(iv) | Letter size (8½ × 11 in), sequentially numbered pages. | `set page(paper: "us-letter")`; page numbers in `page-footer` |
| JPML-FORM-002 | Rule 3.2(a)(iv) | 12-point font for both text and footnotes. | `type-size = 12pt`, footnotes via `footnote.entry` |
| JPML-FORM-003 | Rule 3.2(a)(iv) | Double spaced, **text only**. Headings, counsel blocks, captions, footnotes, tables and signature blocks may be single spaced. | `line-pitch = 24pt`, `body-leading` (body); `single-leading` (everything else) |
| JPML-LIMIT-001 | Rule 3.2(a)(iii) | A brief submitted with a motion does not exceed 20 pages. Exclusive of exhibits, tables of contents or authorities, and signature blocks. | Checked by the template: the memorandum body is counted from its first page to its last line of text (`brief-page-limit = 20`). The render **fails** if the body exceeds it. Mutant-tested: limit 4 fails with "runs 5 pages"; limit 5 passes. |
| JPML-SIG-001 | Rule 3.2(a)(ii) | The final page of each case document has the name, address, telephone and email of the attorney designated to receive service, and the name of each party represented. | `signature-block`, `counsel-grid`, `counsel_role` (on the final page of the motion and of the memorandum) |
| JPML-MOT-001 | Rule 6.1(b)(i) | A motion briefly describes the action or relief sought; it includes a brief that concisely states the background and the movant's factual and legal contentions. | Motion text (`motion_title`, body before the marker) and the memorandum body |
| JPML-XFER-001 | Rule 6.2(a) | A party to an action initiates a § 1407 transfer by filing a motion under these Rules. | Motion's first paragraph, which cites Rule 6.2 (author-written) |
| JPML-SERV-001 | Rule 6.1(b)(iii), Rule 4.1(a) | Proof of service: all case documents contain proof of service on parties not served through CM/ECF, stating the name and manner of service. | `certificate`, generated from `date` and `signature` (a CM/ECF certificate; see gap 3) |

Not generated, and why: Rule 6.1(b)(ii) (numbered Schedule of Actions), 6.1(b)(iii)(A) (service list), 6.1(b)(iv) (copies of complaints and docket sheets), 6.1(b)(v) (exhibits), Rule 4.1(b) (transfer-motion certificate that the notice and schedule went to each transferor court) and Rule 4.1(c) / 6.2(c) (notice of appearance within 14 days). These are concurrent attachments or separate filings; see gaps.

Conventions (not required by the rules; the filed exemplar has them): the table of contents and table of authorities (JPML Rule 3.2(a)(iii) excludes them from the page count, so the template generates them from the body's headings and `toa:` links); Roman numerals for the front matter and Arabic restarting at 1 for the body; heading numbering I., A., 1., a.; 0.5 in first-line indent; the "Respectfully submitted" and "/s/" signature block; the memorandum cover with the counsel blocks.

## Exemplars

Two real filed JPML documents, from different filers:

- `usage/FILED-EXAMPLE-motion-brief.pdf`: the Torres plaintiffs' Motion for Transfer and Memorandum of Law, filed January 22, 2021 (pp. 1–25 of a 387-page compilation). Used for the sample and the overlay. Full citation and provenance in `usage/SOURCE.md`.
- `usage/FILED-EXAMPLE-motion-brief-2.pdf`: USPlabs, LLC's Motion for Transfer, MDL No. 2523, filed January 13, 2014 (3 pages; its brief in support is not in the file). Consulted for the motion's caption and numbered-paragraph structure. Not overlaid.

## Sample

`usage/INPUT-motion-brief.md`. Frontmatter (the case fields: `heading`, `mdl_no`, `in_re`, `motion_title`, `brief_title`, `counsel`, `counsel_role`, `date`, `signature`, `authorities`), then the **motion** markdown, then the line `<!-- memorandum -->`, then the **memorandum** markdown. The marker is the only way the template tells the two case documents apart.

Transcribed from the exemplar: the motion (both paragraphs); the memorandum's opening paragraph; I. Introduction (the five-action list and the two procedural paragraphs); II. Nature of the Actions (three paragraphs); III. Argument (the three lead paragraphs, including the § 1407 standard and its citations); III.B (the lead paragraph); III.B.1 and III.B.1.a (with footnotes 1–3, verbatim); IV. Conclusion; and the signature and certificate text (the same wording as the exemplar).

Not transcribed (marked in italics in the sample, so the gap is visible): Argument III.A.1–3; III.B.1.b–c; III.B.2. The memorandum body in the sample is 5 pages; the exemplar's is 17.

The table of authorities is generated from the `toa:` links in the sample, so it lists the authorities cited in the transcribed text (7 cases and 1 statute), not all 40-odd in the exemplar.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # micromamba env: typst 0.15.0, poppler, ImageMagick, gawk, jq
sh tools/render.sh courts/national/judicial-panel-on-multidistrict-litigation/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/national/judicial-panel-on-multidistrict-litigation/motion-brief chevrolet-bolt
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 11 pages, letter size. Typst compiled with no warnings (`render.sh` fails on any). Fonts: EB Garamond Regular, Italic and Bold only, embedded (`pdffonts`; the earlier EB Garamond render, before fb-595.68: the committed render embeds TimesNewRomanPSMT and is still 11 pages). The tools write `OUTPUT-<id>` and `OVERLAY-<id>` by default; the brief asked for `<id>.pdf` and `<id>-overlay.pdf`. I used the tools as they are and did not change them.
- Line pitch, measured with `pdftotext -bbox` on body page 6 (PDF p. 6): baselines 24.0 pt apart; 27 lines per page.
- `usage/OVERLAY-chevrolet-bolt.pdf` and `OVERLAY-chevrolet-bolt.txt`: red = our render, blue = the exemplar, black = both. The page map pairs pages by word overlap, which is coarse: ours p.1–3 ↔ filed p.1–3 (98–100%), ours p.4 ↔ filed p.4 (TOC), ours p.5 ↔ filed p.6 (our TOA is shorter than the filed one), ours p.6 ↔ filed p.8 (body start), ours p.9 ↔ filed p.17 (both Argument III.B), ours p.10 ↔ filed p.18. Our p.11 (memorandum signature) pairs with filed p.2 (the motion's signature), which is a mis-pairing: the memorandum's signature is at filed p.24. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 11 pages, rendered at 60 dpi and looked at)

| PDF p. | What it is | Finding |
|---|---|---|
| 1 | Motion, page 1: heading, caption, title, body | OK. Found a defect and fixed it: a paragraph setting from the title leaked into the body, which made the motion single spaced and unindented. Re-rendered: double spaced, indented. |
| 2 | Motion signature page: dates, "Respectfully submitted", counsel blocks, "Attorneys for the Moving Plaintiffs" | OK. The signature block moved whole to this page (it is unbreakable), as in the exemplar. |
| 3 | Memorandum cover: heading, caption, title, two-column counsel blocks, Dated | OK. |
| 4 | Table of contents (i) | OK. Page numbers match the body pages: I. 1, II. 2, III. 3, III.A and III.B 4, IV. 5. |
| 5 | Table of authorities (ii) | OK after a fix: entries wrapped and pushed their page numbers onto a new line; page numbers now sit in their own column. Known cosmetic: where an entry wraps, a stray leader dot sits at the end of the wrapped line (e.g. after "(J.P.M.L. 2003)"). Accepted. |
| 6 | Body, memorandum p. 1: introduction and the five-action list | OK. Double spaced; numbered and lettered items; I. heading. |
| 7 | Body p. 2: procedural paragraph and the request for relief; II. Nature of the Actions | OK. |
| 8 | Body p. 3: Nature (end); III. Argument, § 1407 standard with citations | OK. Italic case names. |
| 9 | Body p. 4: III.A heading with omission note; III.B; III.B.1; III.B.1.a | OK. Heading labels correct (A., B., 1., a.). Footnote 1 at foot of page. |
| 10 | Body p. 5: III.B.1.a end, omission note, IV. Conclusion; footnotes 2 and 3 | OK. The conclusion and footnotes fit. The signature block starts on the next page, whole. |
| 11 | Signature and certificate of service (memorandum final page) | OK. Counsel blocks, "Attorneys for the Moving Plaintiffs", Certificate of Service, "By: /s/". |

Reviewed pages: 11 of 11, each rendered and looked at. The place() change to the page-limit marker (below) came after the review and is not visual (it takes no space in the flow): the render is still 11 pages and the body still ends on p. 10.

## Known gaps and open choices

1. **Typeface.** The rules set a 12-point size and do not name a typeface. The template sets Times New Roman 12 pt (`docs/FONTS.md` rule 6, David's 2026-10-17 house standard; the pinned install, Liberation Serif as fallback), the face of the exemplar. Until fb-595.68 it used EB Garamond, which sets visibly smaller than Times at the same size; the open question of a Times-metric face is settled by that rule.
2. **Schedule of Actions, service list, complaints and docket sheets** (Rule 6.1(b)(ii), (iii)(A), (iv)) are not generated. They are concurrent attachments, and the motion refers to "the Schedule of Actions filed concurrently herewith," as the exemplar does. A real filing needs them.
3. **Proof of service.** The generated certificate is a CM/ECF certificate (the exemplar's form). Rule 4.1(b) requires a transfer motion's proof of service to certify that counsel sent the notice of filing and the schedule of actions to the clerk of each transferor district court. That certificate is not generated.
4. **Notice of appearance** (Rules 4.1(c), 6.2(c)) is a separate filing; not generated.
5. **Page numbering.** Rule 3.2(a)(iv) asks for "sequentially numbered pages." The template follows the exemplar: the motion runs 1–2; the memorandum cover is unnumbered; the table of contents and authorities are roman (i, ii); the body restarts at 1. Whether the roman front matter satisfies "sequentially numbered" is an interpretation to confirm.
6. **Page limit.** Checked for the memorandum body only (JPML-LIMIT-001). The count runs from the body's first page to its last line of text; the signature block and certificate are not counted, as Rule 3.2(a)(iii) excludes signature blocks. The sample is 5 pages, well within 20.
7. **Partial sample.** Argument III.A.1–3, III.B.1.b–c and III.B.2 are not transcribed (see the Sample section). The rendered depth is 11 pages, inside the 8–14 page target.
8. **Tier-2 exemplars.** Two exemplars from different filers are on file, but the second is a motion only (no brief), so the memorandum's conventions rest on one filing. The eval loop asks for two or three filed exemplars for tier 2; this is partly met.
9. **Overlay pairing** is coarse at the memorandum signature (see Render and overlay).
10. **Counsel block.** The sample lists all three firms' counsel on the final page. Rule 3.2(a)(ii) asks for the contact details of the attorney designated to receive service; the template prints every counsel block passed in, so the author chooses which to include.
11. **Chevrolet Bolt exemplar is a compilation.** Pages 26–387 (schedule, complaints, docket sheets) were left out of `usage/` to keep the file size reasonable. The compiled file is still a real filed document for the pages kept.

## Engines

**docx** (`docx/`): built by fb render (`sh tools/render.sh --engine docx`): the reference document from `docx/reference.xml` in the typst face, then pandoc with `docx/jpml.lua`, in passes that find the page numbers of the table of contents and table of authorities (`docx/render.sh`, `build-reference.sh` and `pages.awk` did this until fb-595.68). Checked with LibreOffice only: Word is not available here, so Word pagination is not verified.

What matches the typst output (all 12 docx pages and all 11 typst pages were rendered at 60 dpi and viewed, on the earlier EB Garamond build): the typst face at 12 pt, embedded (now Times New Roman in both: TimesNewRomanPSMT); letter paper, 1 in margins; body text at exactly 24 pt with a 0.5 in first-line indent; single spacing for the caption, counsel blocks, signature block, headings and footnotes; the motion numbered 1-2, the memorandum cover unnumbered, the table of contents and table of authorities roman (i, ii), the body from 1; the caption, counsel grid, signature block (one unbreakable table row, so it moves whole) and certificate of service; heading labels I., A., 1., a. with hanging indents; native footnotes.

What differs and why:
- Pagination: the docx is 12 pages (body 1-7) against 11 for typst (body 1-6). LibreOffice breaks lines and footnotes differently, and the certificate of service falls alone on body p. 7 because the signature block fills p. 6.
- The panel heading on page 1 wraps to two lines in the docx; typst keeps it on one line.
- Typst sets the memorandum headings larger (its default heading size); the docx keeps the 12 pt size the rules set, for headings too.
- The (a)-(e) list in the introduction is double spaced with hanging indents in the docx; typst sets it single spaced. The docx follows the rule that text is double spaced (JPML-FORM-003).
- The table of contents and table of authorities are static text, not TOC/TA fields. Their page numbers come from fb render's LibreOffice passes, so they are right for LibreOffice; if the document is edited or opened in Word with different pagination, rerun `sh tools/render.sh --engine docx` to regenerate them.

BLOCKED (docx):
- `sh tools/check.sh <doc-type-dir> --engine docx` does not run: it reads `checks.yaml` and `court.json`, and neither exists for this doc type or in the court folder (no `checks.yaml`, no rules file with check IDs). It exits 2 before any gate runs, so there is no Gate 0 or Gate 1 result and no `.check-docx.txt` stamp. Blocked until the court has a `checks.yaml`.
- Gate 2 (visual review) is recorded above for the docx as rendered by LibreOffice, not Word.
