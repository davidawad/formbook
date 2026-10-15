# Appellant's Reply Brief template (Texas Court of Appeals, Fifth District at Dallas)

Typst template for an appellant's reply brief in the Fifth Court of Appeals at Dallas. Engine: typst (`typst/`). latex and docx are not built for this doc type.

## Governing rules (checked 2026-10-15)

Verification status: the primary text, the Texas Rules of Appellate Procedure as updated February 6, 2026 (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf), returned HTTP 403 to every fetch from this box on 2026-10-15 (WebFetch, and curl with browser headers). The Rule 9.4 text below comes from secondary summaries (appeal.pro, RuleDex, state-rules.com). Re-check each line against the primary PDF before relying on it.

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 9.4(c) | margins at least 1 inch on both sides, top and bottom | `page-margin` = 1in | secondary |
| TRAP 9.4(e) | conventional typeface no smaller than 14-point; footnotes no smaller than 12-point | `type-size` = 14pt, `footnote-size` = 12pt | secondary |
| TRAP 9.4 (spacing) | body text double-spaced; footnotes, block quotations, short lists and issues may be single-spaced | `body-leading` = 1.6em (pitch 2.25em, about 31.5pt); `single-leading` = 0.5em (pitch 1.15em, about 16pt) | secondary |
| TRAP 9.4(i) | word limit 7,500 words for a reply brief if computer-generated; word-count certificate | not enforced by the template; counsel supplies the certificate | secondary |
| TRAP 38.3 | contents of a reply brief | the template orders the headings the sample supplies; no index of authorities is generated | not verified against primary text |
| TRAP 9.5 | service certificate | counsel supplies | not verified (the exemplar cites Rule 9.5) |
| Fifth Court local rules | local length and briefing limits (a combined reply and cross-appellee brief has its own limit) | not encoded | secondary (search summary) |

Typeface: no face is named by the rules, so EB Garamond (vendored; `docs/FONTS.md`).

## Markdown contract

Same as the opening brief (`../opening-brief/README.md`): frontmatter fields `case_number`, `appellant`, `appellee`, `trial_court`, `county`, `trial_cause`, `brief_title`, optional `caption`, and `counsel` as a list. Paragraphs shorter than 100 characters are not indented.

## Exemplar and overlay

- Exemplar: `exemplars/FILED-EXAMPLE-reply-brief.pdf`; source, filer, date and hash in `exemplars/SOURCE.md`.
- Overlay: `samples/OVERLAY-reply-brief.pdf` and `.txt`. A diagnostic (tier 3), not a score.

## Sample

`samples/INPUT-reply-brief.md` is transcribed from the complete reply body of the exemplar: the first reply issue, the second reply issue (with the minor-specific paragraph bracketed out), conclusion and prayer, signature block, certificate of compliance (word count left as `[word count]`), and certificate of service. The render is 7 pages (cover, contents, five body pages, and the certificates). That is one page short of the 8-page target: the filed reply's body is only about five pages, and the transcription does not pad it.

## Render and review

```
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/reply-brief samples/INPUT-reply-brief.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/reply-brief reply-brief
```

Output: `samples/OUTPUT-reply-brief.pdf`. Review: `reviews/2026-10-15.md`.

## Known gaps

1. Sample is 7 pages, below the 8-page target, because the exemplar's reply body is short. A second filed reply for this doc type would fix it; none was found.
2. No index of authorities is generated (TRAP 38.3 and 38.1). Counsel supplies it. OPEN in the review.
3. No word-count certificate is computed. The certificate in the sample is a placeholder, `[word count]`.
4. Signature blocks are flush left but double-spaced and split across a page break in this sample. OPEN in the review.
5. One filer for this doc type (Scott H. Palmer, P.C.), the same filer as the opening brief.
6. Rule text from secondary sources (see the table above).
7. `tools/check.sh` was not run for this doc type. No stamp is written.
8. Pagination: the cover is unnumbered and the following pages are numbered from the cover as page 1.
