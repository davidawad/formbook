# California Supreme Court: opening brief on the merits

Doc type `opening-brief-on-the-merits` for the California Supreme Court (`court.json` alias `cal`). This folder is self-contained; the court-root `typst/` and `samples/` are untouched, and `court.json` status is not set here. Nothing in this folder is a gate stamp: there is no `checks.yaml` for this doc type yet, so no mechanical Gate 0 or Gate 1 has run.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-people-v-mccune-S276303-opening-brief-on-the-merits.pdf` | Filed appellant's opening brief on the merits, 57 pages, text layer present (Pirolo). |
| `exemplars/FILED-EXAMPLE-people-v-patton-S279670-opening-brief-on-the-merits.pdf` | Filed appellant's opening brief on the merits, 37 pages, text layer present (Demson). |
| `exemplars/SOURCE.md` | URL, case, filer, date filed and date fetched for both exemplars. |
| `samples/INPUT-mccune-opening-brief-on-the-merits.md` | Transcription of a portion of the McCune brief: cover, TOC and TOA (built from the markdown), Issue Presented, Introduction, part of the Statement of the Case, most of Argument I.A and part of I.B, Conclusion, word-count certificate, attorney's proof of service. |
| `samples/OUTPUT-mccune-opening-brief-on-the-merits.pdf` | `sh tools/render.sh courts/ninth-circuit/california/state/supreme-court/opening-brief-on-the-merits samples/INPUT-mccune-opening-brief-on-the-merits.md`. 15 pages, EB Garamond only (embedded). |
| `samples/OVERLAY-mccune-opening-brief-on-the-merits.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/ninth-circuit/california/state/supreme-court/opening-brief-on-the-merits mccune-opening-brief-on-the-merits`. Red = ours, blue = filed, black = both. The `.txt` is the page map. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `typst/cal-opening-brief-on-the-merits.typ` | The template: `cal-opening-brief-on-the-merits(meta, md)`. Parameters at the top; each traces to a rule or is a style choice. Structure copied from `courts/ninth-circuit/california/state/courts-of-appeal/opening-brief/typst/calctapp-opening-brief.typ` (same rule family), not its numbers. |

## Governing rules

Verified 2026-10-14 against the courts.ca.gov rule pages. The pages were read through a summarizing fetch with limited quoting, so the wording below is paraphrase of the official text; a person should confirm the quoted values against the official rule before relying on them.

| Requirement | Source | Value used in the template |
|---|---|---|
| Paper size | Rule 8.204(b)(1) (https://courts.ca.gov/cms/rules/index/eight/rule8_204) | US Letter, 8½ × 11 in. |
| Font style | Rule 8.204(b)(2)–(3) (same URL) | Any conventional roman font; case names italicized. EB Garamond (the only serif vendored in `fonts/`). The McCune exemplar is Century Schoolbook; the font is a style choice, not a rule. |
| Type size | Rule 8.204(b)(4) (same URL) | 13 pt, footnotes included (`type-size`). |
| Line spacing | Rule 8.204(b)(5) (same URL) | Lines at least 1½ spaced (`body-leading`); headings, footnotes, block quotations, TOC and TOA single spaced. |
| Margins | Rule 8.204(b)(6) (same URL) | Left and right at least 1½ in (`side-margin`), top and bottom at least 1 in (`top-margin`). |
| Page numbering | Rule 8.204(b)(7) (same URL) | Arabic, consecutive from the cover as page 1. The cover prints no number. |
| Cover content | Rule 8.204(b)(10)(A)–(D) (same URL) | Title of the brief; title of the case with the Supreme Court number and the Court of Appeal number; the trial court and each participating trial judge; the party each attorney represents. The template prints the Supreme Court No. and the Court of Appeal No. on the right of the caption, the review line, trial court, superior court number, judge, title, and counsel. |
| Tables first | Rule 8.204(a)(1)(A) (same URL) | TOC and TOA, listed separately, at the front (`toc-section`, `toa-section`). |
| Point headings | Rule 8.204(a)(1)(B) (same URL) | Each point under a heading that summarizes it (the argument headings in the sample). |
| Opening brief content | Rule 8.204(a)(2)(A)–(C) (same URL) | The template does not enforce these; the sample has the argument and conclusion. Statement of the nature of the action, final judgment or appealable order, and a summary of significant facts are required content (see Known gaps). |
| Length | Rule 8.520(c)(1) (https://courts.ca.gov/cms/rules/index/eight/rule8_520) | A computer-generated opening brief on the merits is limited to 14,000 words, footnotes included (`word-limit`). The template fails above that. |
| Certificate of word count | Rule 8.520(c)(1); the certificate does not count toward the limit (8.520(c)(3)) | Certificate by appellate counsel stating the count. The count is computed from the markdown (`count-words`), excluding tables and the certificate. The wording follows the exemplar's certificate. |
| Typewritten limit | Rule 8.520(c)(2) (same URL) | 50 pages for a typewritten brief. Not applicable: the brief is computer-generated. |
| Electronic service | Rule 2.251(j)(1) (https://courts.ca.gov/cms/rules/index/two/rule2_251) | Proof of electronic service is made as provided in Code Civ. Proc. § 1013b. The attorney's proof of service in the template follows the exemplar's form (see below). |
| Attorney's proof of service | Code Civ. Proc. § 1013a(2), Cal. Rules of Court 8.71(f) and 8.77, as cited in the exemplar | **Not verified against the rules.** The rule numbers are taken from the McCune exemplar's own heading. The template prints them as cited there. Confirm before relying on them. |

## Overlay

Overlay of `OUTPUT-mccune-opening-brief-on-the-merits.pdf` against the McCune exemplar (`overlay.sh` takes the first file in `exemplars/`, which is McCune). Pages are paired by word overlap (`overlay.txt`): cover 1 to 1 (79%), TOC 2 to 2 (68%), TOA 3 to 4 (48%), 4 to 7 (46%), body 5 to 10 (52%), 6 to 11 (54%), 7 to 12 (81%), 8 to 13 (53%), 9 to 19 (54%), 10 to 20 (55%), 11 to 22 (79%), 12 to 23 (58%), conclusion and signature 13 to 53 (74%), certificate 14 to 54 (85%), proof of service 15 to 55 (72%). Word overlap is low where the sample is a portion; it is a diagnostic, not a score.

The sample is a portion, so its body pages pair with the filed pages they came from, and the filed pages it did not transcribe show as blue in the overlay. The cover and certificates line up by content.

## Page review (Gate 2 record)

All 15 pages of `OUTPUT-mccune-opening-brief-on-the-merits.pdf` were rendered at 60 dpi and viewed as images. Pages 5–7 were viewed before the footnote fix on page 8; that fix moved text only on pages 8 onward, so they were not re-viewed. Pages 2–4 and 8 were re-checked by text after the final edits, and the TOC page numbers match the rendered headings (Issue 5, Introduction 5, Statement of the Case 8, Argument 9, Conclusion 12).

Defects found and fixed in this pass:

- Page 1 (cover): the caption's designations wrapped ("Plaintiff and / Respondent,") because the left column was narrow. The indent was reduced from 45% to 25% and the column split kept at 3.4 : 2.6 so "Court of Appeal No. A163579" stays on one line.
- Page 8 (footnote): footnote 2 had captured the next sentences of the paragraph, because its definition was inserted in the middle of a paragraph. The definition now follows the whole paragraph; the sentences are back in the body.
- Page 13: the signature block stood alone on a page when the markdown ended in footnote definitions (the keep-with-signature check looked at the last block, which was a footnote). Footnote definitions now sit after the paragraph that references them, so the conclusion stays with its signature.
- Page 15: a service entry had the mailing address in the name field. Fixed in the frontmatter.

Open choices, recorded here so the reviewer can see them:

- Length: 15 rendered pages, against the target of 8–14. The breakdown: cover 1, TOC 1, TOA 2, body 9 (pp. 5–13), certificates 2. The body is trimmed to what the sample needs to show the structure; the TOA runs to a second page because the sample cites 20 authorities. A further cut would drop authorities that the remaining text cites.
- The sample omits the Statement of Facts and most of the Argument; the frontmatter comment says so.
- The TOA's second page holds only a few entries; that is the TOA's own length, not a layout defect.

## Known gaps

- **Tier 2 is not finished.** Two exemplars from two filers are on file (Pirolo, Demson); the eval loop asks for 2 or 3, so the minimum is met, but a third filer would firm up the comparison. The McCune and Patton exemplars use Century Schoolbook; the template uses EB Garamond (only vendored serif).
- **Notice of intent to rely on a Court of Appeal brief** (Rule 8.520(a)(4)): the rule requires it to be attached to the cover when a party relies on a brief it already filed in the Court of Appeal. The template does not generate it; a brief that reuses a Court of Appeal brief needs the notice added by hand.
- **Statement of Appealability and Statement of the Facts** (Rule 8.204(a)(2)(A)–(C)): the sample omits the statement of facts; the template does not enforce the required content.
- **Attorney's proof of service** wording and its rule citations (CCP § 1013a, Rules 8.71(f), 8.77) are taken from the exemplar and not verified (see the rules table).
- **Word count** is computed from the markdown by the template; the number printed on the certificate is that computed count, not a count from a word processor. The exemplar's certificate says "Microsoft Word"; the template prints the `word_processor` field from the frontmatter.
- **Cover caption**: a long party name or a long review line may wrap; the cover is one page and the template refuses to build if it cannot fit (`cover`), so a very long caption must be shortened in the frontmatter.
- The template has no checks yet (`checks.yaml` is not written). The gate stamps and the selftest belong to the court-level eval loop, not this box.
