# Motion with memorandum of law (prb)

Court: United States Bankruptcy Court, District of Puerto Rico (`prb`). Doc type: motion-brief
(a motion with a supporting memorandum, filed in an adversary proceeding).

## Files

- `exemplars/FILED-EXAMPLE-perez-cruz-20-00126-motion-brief.pdf`: the filed exemplar (10 pages), with
  its source in `exemplars/SOURCE.md`. sha256 `351e1895ae49e72cef27b84e9be06a45a3b939039c6ce7c25f751433578e1048`
  (fetched 2026-10-14 from the RECAP URL in SOURCE.md).
- `samples/INPUT-perez-cruz-osj.md`: the transcription of the exemplar (YAML frontmatter, then the body).
- `samples/OUTPUT-perez-cruz-osj.pdf`: our render, 8 pages (`tools/render.sh`, vendored fonts only, no typst warnings).
- `samples/OVERLAY-perez-cruz-osj.pdf` and `.txt`: red = our render, blue = the filed exemplar, black = both
  (`tools/overlay.sh`); the `.txt` is the page map.
- `typst/main.typ` (entry point) and `typst/prb-motion-brief.typ` (the template). The template is the
  adversary-complaint template of this court, with these changes: no paragraph numbering (the filed motion
  is not numbered), first-line-indented body text, block quotations single spaced and indented, footnotes
  from markdown `[^n]` references, notices marked with a `(single) ` prefix, and a narrow centered title.

## Frontmatter contract

`court` (list of lines), `debtor` (`names`, `designation`), `bankruptcy_case` (number and judge's initials),
`chapter`, `adversary` (blank prints a fill-in line), `parties` (list of `names` and `designation`),
`title`, optional `lead_in`, `signature` (`date`, `signer`, `lines`). Nothing case-specific is in the template.

## Rules

The template comments cite these; the status of each is stated here, because not all of them could be read.

- **LBR 9013-1 (notice of response time).** Search results (a courtrules.net copy and the court's own
  General Order 18-02, June 2018) state a 14-day response period plus 3 days for mail under FRBP 9006(f), with
  the notice in at least 11-point type, single or double spaced. The court's PDF returned binary and the
  courtrules.net page returned HTTP 403, so the text was **not verified**. The template does not set the
  period: the notice text comes from the sample, which carries the exemplar's 30-day wording.
- **LBR 1005-1(a) and (b)** (caption: case name, number, judge's initials and chapter; 8 1/2 x 11 inch). Cited by
  the sibling adversary template. **Not verified**: no text of the District of Puerto Rico's LBR 1005-1 was found.
- **FRBP 9004(b)** (caption) and **FRBP 7056 / FRCP 56** (summary judgment in an adversary proceeding). Cited
  for context; not verified in this run.
- Court convention, not a rule: EB Garamond 12 pt, one-inch margins, double spacing (24 pt baseline pitch),
  11 pt footnotes. The filed exemplar matches these settings.

Open tier-1 question: the exemplar's notice says 30 days, while the search results give 14 days (plus 3 for
mail) for an ordinary motion, and 30 days only for certain motions (for example, to dismiss a chapter 13 case).
Whether this motion takes 14 or 30 days needs the current LBR 9013-1 text. This is for David to decide
before the template's notice wording is final.

## What the overlay shows

Page pairing is by text (`tools/overlay.sh`); word overlap per pair runs from 46% to 92%.

| ours | filed | overlap |
|---|---|---|
| 1 | 1 | 81% |
| 2 | 2 | 67% |
| 3 | 3 | 49% |
| 4 | 5 | 46% |
| 5 | 6 | 71% |
| 6 | 7 | 86% |
| 7 | 8 | 92% |
| 8 | 9 | 74% |

The filed page 10 holds only the date and signature block. Our page 8 carries the notice, the certificate,
and the signature, so filed page 10 has no partner in our render. The differences that show in the overlay:

- **Length.** We render 8 pages to the filed 10. The text is complete (the word diff against the exemplar
  finds no body words missing from our render). The cause is the line pitch: measured on page 2 with
  `pdftotext -bbox`, the filed body lines are about 27 pt apart, and ours are 24 pt. Both are double spaced
  for their fonts, but the filed one is looser. Matching it would take a leading of about 1.5 em instead of
  1.35 em and would make ours about 9 to 10 pages. Open tier-2 item: decide which pitch the court expects
  (the LBR text is not verified, see Rules).
- **Caption.** The filed caption is a bordered table with the case number on the right and the chapter
  and adversary number below it. Ours is the open caption of the sibling template (right rule, no table
  border). A clerk accepts both, so this is recorded as an accepted tier-2 difference, not a defect.
- **Headings.** Ours are bold capitals, left aligned, with the roman numeral in the text. The filed headings
  are bold title case, numbered with a tab, indented. This is a style choice (the caps convention is common in
  PR filings), recorded as an open tier-2 item for review against a second filer.
- **Page numbers.** Plain numbers in ours; the filed uses "−N−". Recorded as accepted (one filer's style).
- **Signature.** Ours reads "Respectfully submitted," then the date and the signature block; the filed reads
  "RESPECTFULLY SUBMITTED." with the date and the firm name above the signature. The template's order
  is a convention, not a rule; recorded as an open tier-2 item.
- **CM/ECF header.** The filed pages carry the court's header line (case, document number, filed and entered
  dates). The court's system applies it at filing, so the template does not reproduce it (accepted).

## Transcription

The sample is a transcription from the text layer (`pdftotext`), checked against the exemplar by a word diff.
Deliberate differences from the filed text:

- The CM/ECF header and the "Page N of 10" lines are not in the body.
- The footnotes are in the sample as `[^1]` to `[^5]`, placed at the same sentences as in the filed text.
- Typos normalized: "appoval" to "approval", "postconfirmation" to "post-confirmation", "exspouse" to
  "ex-spouse" (a line-end hyphen), "vs" to "v." in the caption.
- The stray "a." before the conclusion heading in the filed text is not reproduced.
- The closing "et. Als." in the caption is kept as filed.

## Gaps

1. **Rules not verified** (see Rules). The notice period (14 or 30 days) is an open question for David.
2. **One filer only.** The exemplar is a single filer's motion (Law Offices of Luis M. Suárez-Lozada, for
   defendant Oriental Bank). The eval loop asks for two or three exemplars from different filers before a tier-2
   check; SOURCE.md records that no second PR bankruptcy motion-with-memorandum was found. So the tier-2
   review here is against one filer only, and the overlay is not a tier-2 pass.
3. **Pages reviewed.** Every page of the final render (8 of 8) was looked at as a PNG at 100 dpi.
4. **Not run:** `tools/check.sh` (there is no `rules.md` yet for this folder), `tools/check-selftest.sh`,
   the latex and docx engines, and `tools/tracker.sh`. This folder's brief limits the work to the typst
   render and the overlay.
5. **Line height.** The 24 pt double-spacing model is measured for EB Garamond at 12 pt (line box 0.65 em,
   leading 1.35 em). The template's paragraph spacing equals the leading, so every block gap is one row.
