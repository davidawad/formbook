# moeb: motion brief (motion and memorandum in support)

Doc type: **motion-brief**, a motion or a memorandum in support of one, in the United States Bankruptcy Court for the Eastern District of Missouri, Eastern Division (`moeb`). Folder: `courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief/`.

## Where this started (read first)

The task brief assumed this folder already existed on master with an exemplar and `SOURCE.md`. It did not: the checkout had no `motion-brief/` for moeb, only `adversary-complaint/`, and the snapshot has no git history for one. So the folder was built from scratch, following the parent epic's intent (a real public exemplar, a transcribed sample, an overlay). The three exemplars were found on CourtListener RECAP and are recorded in `exemplars/SOURCE.md`. The primary exemplar is the 14-page Directory Distributing memorandum (ECF Doc 36, 2016).

| Item | Status |
|---|---|
| exemplar | yes: 3 public filings, 3 filers (`exemplars/FILED-EXAMPLE-*.pdf`; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-directory-memorandum.md` (whole memorandum, caption to certificate; transcribed from the 14-page exemplar) |
| render | ok: `samples/OUTPUT-directory-memorandum.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-directory-memorandum.pdf` and `.txt` (page map), against the Directory exemplar |
| pages reviewed | 14 of 14 (every page of the final PDF rendered at 60 dpi and viewed) |
| tier-1 checks | **not built**: no `checks.yaml` or `check.sh` gates in this folder yet. Everything in the Rules table below is checked by eye, not by a mechanical gate. |

## Governing rules

Primary source: **E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"** (cover page of the PDF). Fetched 2026-10-14 from https://www.moeb.uscourts.gov/sites/moeb/files/Local_Rules_Dec_1_2025.pdf. curl is blocked by the court's F5 gateway, so the PDF was retrieved through WebFetch and text-extracted (`pdftotext -layout`, 104 pages). The quotations below are from that text. The copy is not in the repo.

Caveat (same as the adversary template): the rule text's L.R. 1001(C) still says "effective on December 1, 2022". The cover says 2025, and this template follows the cover. David should confirm which is current.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MOEB-MB-001 | L.R. 9004(A) | Caption: court and division; top left the debtor, and for motions the movant and respondent; top right the case number with judge code, chapter, motion number (once assigned), current hearing date, time and location, and the date any response must be filed. | `caption()` in `typst/moeb-motion-brief.typ`; `caption`, `case_number`, `judge`, `chapter`, `hearing` in the sample frontmatter. |
| MOEB-MB-002 | L.R. 9004(B) | Descriptive title stating the relief sought. | `title` (sample frontmatter), set in capitals. |
| MOEB-MB-003 | L.R. 9004(C) | Paper 8½ × 11; margins no less than 1 inch; one side; "standard, 12-point font". | `margin = 1in`, `type-size = 12pt`. Footnotes are 12 pt too (see layout choices). |
| MOEB-MB-004 | L.R. 9004(C) | No motion, memorandum or brief to exceed 15 pages, excluding signature page, certificate of service and attachments. | The sample renders at 14 pages, the signature and certificate on the last page. Checked by eye, not by a gate. |
| MOEB-MB-005 | L.R. 9004(C) | Numbered paragraphs for factual and legal allegations, except in memoranda of law. | Numbered by the template (see layout choices). |
| MOEB-MB-006 | L.R. 9004(D) | Every filing "must include, or be accompanied by, a certificate of service", identifying each person served, the date, and the manner. Parties not served through CM/ECF are named with addresses (D)(2). | `certificate-block()` asserts that the sample has a `certificate`. Not optional. |
| MOEB-MB-007 | L.R. 9013-1(E) | A memorandum, if filed, is filed with the motion; no memorandum over 15 pages (same exclusions). | The sample is the memorandum; it is filed with its motion (see open question 4). |
| MOEB-MB-008 | L.R. 9013-1(B) | Response deadline: seven days before the hearing, unless otherwise specified. | Caption line "Response Deadline: December 5, 2016", seven days before the December 12, 2016 hearing. See open question 3. |
| MOEB-MB-009 | L.R. 9013-1(F) | A consent motion's title must say it is "by consent". | Not applicable to this memorandum. The template does not check it. |

Not produced: the motion itself (this sample is the memorandum; the exemplar is also a memorandum), the proposed order (L.R. 9004(A) captions it; not in the sample), any exhibit or attachment, and any hearing notice.

## Layout choices (not rule-fixed)

- **Font**: EB Garamond 12 pt, the only vendored face (`fonts/eb-garamond`). The exemplar uses Times; no local rule names a face.
- **Spacing**: double spacing (27.6 pt baseline pitch); headings, block quotes, footnotes, caption and signature block single-spaced. The exemplar is double-spaced with single-spaced block quotes.
- **Caption**: the debtor and parties sit in the left column above a rule; the case block sits in the right column. This is the same layout as the adversary template. The exemplar uses a ")" column instead (a filer's choice; tier 2 and not chased).
- **Headings**: level 1 (I., II., ...) centered bold capitals; level 2 (A., B., ...) bold and indented to the paragraph text. The exemplar's sub-headings use a hanging letter.
- **Numbering**: paragraphs numbered 1–29. Two of the three filers number their paragraphs (Directory Distributing, Payless); the Rodriquez memorandum does not. L.R. 9004(C) exempts memoranda, so numbering is a house-style choice and this template follows the majority.
- **Footnotes**: the sample carries four footnotes, written as `[^n]` markers with text in the frontmatter `footnotes` map. The footnote text is 12 pt, not the exemplar's smaller type, because L.R. 9004(C) sets one size for the document.
- **Block quotations**: `> ` chunks, single-spaced, indented 0.5 in on each side (the MSA indemnity clause and two Robins quotations).
- **Signature block**: "Dated:" at left; "Respectfully submitted," firm and "By:" at right; attorney names and contact lines indented under "By:", as in the exemplar.
- **Certificate of service**: its own paragraph block, kept with the signature on the last page so neither stands alone.
- **Non-breaking spaces** keep "11 U.S.C. § 548" and "§ 548" together.
- **Footnote spacing**: `cmarker` trims whitespace at each end of a segment, so a space next to a footnote marker is restored explicitly (`md()` in the typst file).

## Gate 2: visual review (every page of the final PDF, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title; caption (debtor, movant, respondents; case block with hearing and response date); title; lead-in; "I. INTRODUCTION"; ¶ 1 | OK. Caption rule closes the left column. |
| 2 | ¶¶ 1–3 continued, footnote 1 at the foot | OK. Footnote marker after "Krawczyk." renders with the space. |
| 3 | ¶ 3 continued, ¶ 4 under "II. BACKGROUND" and "A.", ¶¶ 5–6 | OK. Heading "B." with ¶ 6 at the foot. |
| 4 | Block quotation (MSA indemnity and independent contractor items a–f), ¶ 7, heading "C.", ¶ 8 | OK. Item d. ends "for all of", as the exemplar does. |
| 5 | ¶¶ 9–10, heading "D." | OK. Italic case name in ¶ 9. |
| 6 | ¶¶ 11–14, heading "E." | OK. |
| 7 | ¶¶ 15–16 with footnote marker 2, "III. ARGUMENT", "A.", ¶ 17 begins, footnote 2 at the foot | OK after the fix. "Krawczyk case.² On October 18" has a space. |
| 8 | ¶ 17 continued, ¶ 18 with footnote 3 at the foot | OK. |
| 9 | Heading "B.", ¶¶ 19–21 | OK. |
| 10 | ¶ 21 continued, Robins I block quotation, ¶ 22, heading "C." | OK. The "Id." continuation sits flush after the quotation. |
| 11 | Robins II quotation continuation, ¶¶ 24–25 with footnote 4 at the foot | OK. |
| 12 | ¶¶ 26–27, Dalkon Shield and asbestos citations in italics | OK. |
| 13 | ¶ 28, heading "D.", "IV. CONCLUSION", ¶ 29 | OK. The WHEREFORE clause moved to page 14 with the signature block (kept together by design). |
| 14 | WHEREFORE; "Dated:" and signature block with attorney names indented under "By:"; certificate of service with the ECF and U.S. Mail recipients | OK after the fix. The first overlap (names over "By:") was corrected with an explicit space. |

## What the overlay shows

`samples/OVERLAY-directory-memorandum.txt` pairs every page of our render with an exemplar page by word overlap. Ours p.1–9 and p.14 pair with the same-numbered filed page; ours p.10–13 pair with filed p.9–12, one page earlier, which suggests our text runs slightly longer through the middle of the document. Word overlap runs from 37% (p.9) to 86% (p.5). The overlay is a diagnostic, not a score. The cause of the one-page offset has not been traced; a difference in block-quotation or paragraph spacing is likely, but that is unverified. Tier 3 differences are not chased.

## Open questions and gaps (for David)

1. **The exemplar premise.** The brief said the folder and exemplar already existed on master. They did not in this checkout. The three RECAP files were acquired instead; `exemplars/SOURCE.md` records each URL and retrieval date. If master holds a different motion-brief exemplar for moeb, this folder should be reconciled with it.
2. **Movant and respondent in the caption (L.R. 9004(A)).** The exemplar's caption names only the debtor, but the rule requires the movant and respondent on the top left of motion filings. The sample names the Debtor as movant and "plaintiffs and non-debtor co-defendants in the Walker and Krawczyk actions" as respondents. That wording is our choice. Confirm it, or supply the respondents' names.
3. **Response deadline line.** The exemplar does not state a response date. The sample states December 5, 2016 (seven days before the December 12 hearing, L.R. 9013-1(B)). That is a computed date, not one the filer wrote. Remove it if the court sets the date another way.
4. **Memorandum versus motion.** L.R. 9013-1(E) makes a memorandum optional, and it must be filed with the motion. The template renders a memorandum on its own. A motion with an incorporated memorandum (the Payless exemplar) would need a different lead-in and a "Motion" title; that is not built.
5. **Certificate of service.** The template fails the build without a certificate (L.R. 9004(D)). The exemplar has one, and so does the sample.
6. **Footnote size.** 12 pt. L.R. 9004(C) sets "standard, 12-point font" for the document and says nothing about footnotes. The exemplar's footnotes are smaller. The 12-point choice is the rule-safe one. If David reads the rule as allowing smaller footnotes, change the footnote size in `md()` only.
7. **Effective date.** See the caveat under Governing rules: the cover page says December 1, 2025, and L.R. 1001(C) says December 1, 2022.
8. **Tier-2 coverage.** Three filers are saved, two of them debtor-side (Directory Distributing, Payless) and one defendant-side in an adversary (Rodriquez). Only the Directory memorandum is transcribed and reviewed page by page. The Payless and Rodriquez files are used as structural references for the caption and signature blocks.
9. **No tier-1 gate.** Gate 0 (content), Gate 1 (one check per rule) and the mutation self-test are not built for this folder. The render and the page review are the only checks. Building `checks.yaml` and `check.sh` for the 15-page limit, the 12-point font, the margins, the certificate and the caption is the next step.
10. **Transcription.** Typos in the exemplar are kept, as they are in the filed text ("co-defndant", "pursing", "Krawcyzk", "carmodymacdonal.com", "in Krawczyk" spelled "Krawcyzk" in footnote 3). Italic case names are marked where the exemplar shows italics, not everywhere.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env; see the brief)
sh tools/render.sh courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-directory-memorandum.md
sh tools/overlay.sh courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief directory-memorandum \
  courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief/exemplars/FILED-EXAMPLE-directory-distributing-16-47428-doc36-memorandum.pdf
```

`tools/overlay.sh` picks the first exemplar alphabetically if no third argument is given, which would be the Directory memorandum here anyway. The explicit argument is passed so the choice does not depend on file order.

Toolchain: `micromamba create -p ~/tb -c conda-forge typst=0.15.0 poppler imagemagick gawk jq`. `typst --version` reports 0.15.0.

[Adversary complaint (same court)](../adversary-complaint/README.md) | [Court README](../README.md)
