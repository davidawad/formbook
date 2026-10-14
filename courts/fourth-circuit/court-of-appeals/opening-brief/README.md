# Fourth Circuit: opening brief of appellant

Doc type `opening-brief` for the U.S. Court of Appeals for the Fourth Circuit (court alias `ca4`). Self-contained: exemplar, sample, template, overlay and this README live in this folder. Court-root `typst/` and `samples/` (the Ninth Circuit's brief) are not touched.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: filed Opening Brief of Appellant, *NetChoice v. Jones*, No. 26-1252, filed 04/15/2026 (see `exemplars/SOURCE.md`) |
| Sample | `samples/INPUT-netchoice-opening-brief.md`: 14 rendered pages, excerpted from a 66-page filed brief |
| Render | ok: `sh tools/render.sh courts/fourth-circuit/court-of-appeals/opening-brief samples/INPUT-netchoice-opening-brief.md`; exit 0, no typst warnings, embedded fonts are EB Garamond only |
| Overlay | ok: `sh tools/overlay.sh courts/fourth-circuit/court-of-appeals/opening-brief netchoice-opening-brief`; wrote `samples/OVERLAY-netchoice-opening-brief.pdf` and `-overlay.txt` |
| Pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed; the cover was re-rendered and viewed again after its counsel lines were shortened) |
| Gate 2 | open: the font (below) |

## Governing rules

Rule text was fetched on 2026-10-14. Where a page was a summary rather than verbatim text, that is noted.

| Requirement | Source | Verified |
|---|---|---|
| Typeface: proportional serif, 14-point or larger (text and footnotes) | FRAP 32(a)(5)(A): https://www.law.cornell.edu/rules/frap/rule_32 | 2026-10-14, verbatim |
| Spacing: double-spaced; block quotations and headings and footnotes may be single-spaced; margins at least 1 inch, 8½ × 11 paper | FRAP 32(a)(4) (same page) | 2026-10-14, verbatim |
| Type style: plain roman, italics or boldface for emphasis, case names italic or underlined | FRAP 32(a)(6) (same page) | 2026-10-14, verbatim |
| Length: principal brief at most 13,000 words (or 1,300 lines monospaced) | FRAP 32(a)(7)(B)(i) (same page) | 2026-10-14, verbatim |
| Excluded from the count: cover, disclosure statement, TOC, TOA, statement regarding oral argument, addendum, certificates, signature block, proof of service | FRAP 32(f) (same page) | 2026-10-14, verbatim |
| Certificate of compliance with the type-volume limit, stating the word count | FRAP 32(g)(1) (same page) | 2026-10-14, verbatim |
| Cover colour: appellant's brief blue (paper); white is permitted for the electronic cover | FRAP 32(a)(2) (same page); Fourth Circuit Brief & Joint Appendix Requirements, "Cover Color" (https://www.ca4.uscourts.gov/appellateprocedureguide/Briefing/briefapxreq.html, March 2026, fetched 2026-10-14, summary) | 2026-10-14 |
| Contents, in order: cover, disclosure statement if required, TOC, TOA, jurisdictional statement, statement of issues, statement of the case, summary of argument, argument (with standard of review), conclusion, request for oral argument, signature, certificate of compliance, certificate of service (non-ECF) | FRAP 28(a)(1)–(10): https://www.ca4.uscourts.gov/rules/Rule28.html (2026-10-14, quoted through a summary of the page) | 2026-10-14 |
| Cover content: docket number centred at top (no district or agency number); "United States Court of Appeals for the Fourth Circuit"; case title; "Appeal from the … District Court"; brief title; counsel names, addresses, phone numbers | Brief & Joint Appendix Requirements, "Cover Content" (same page, summary) | 2026-10-14 |
| Certificate of service: FRAP 25(d) (proof of service); the exemplar uses CM/ECF service wording | FRAP 25(d); exemplar p. 66 | 2026-10-14 |
| Preferred typefaces: Times New Roman, Century Schoolbook, Georgia; the court "discourages the use of Garamond" | Fourth Circuit News, "Preferred Typefaces for Briefs," Dec. 9, 2024, https://www.ca4.uscourts.gov/news-announcements/2024/12/09/preferred-typefaces-for-briefs (fetched 2026-10-14) | 2026-10-14. A notice, not a rule. |

Local Rule 32 (https://www.ca4.uscourts.gov/rules/Rule32.html) was fetched on 2026-10-14. It covers appendices, length (it defers to FRAP 32(a)(7)) and correction of briefs; it has no typeface or cover rules of its own. The page returned a summary, not verbatim text.

## What the template does

`typst/ca4-opening-brief.typ` (entry point `typst/main.typ`) is driven by the FRAP numbers above and by the parameters at its head:

- Font: EB Garamond (the only vendored serif face), 14 pt everywhere, double-spaced with a 0.94 em body leading, 1-inch margins.
- Cover: one page; the spacing between its parts shrinks to fit, the type size never does. A cover that cannot fit is an error.
- Front matter: TOC and TOA with lower-roman folios; the TOA is built from `toa:` links in the body. TOA entry spacing is 0.5 em.
- Body: arabic folios from 1. Headings are numbered by the template (I./A./1./a. in the Argument; A./1./a./(1) elsewhere). The signature block follows the last section and stays with the last paragraph.
- Request for oral argument: must be the last section in the markdown; the word count excludes it (FRAP 32(f)).
- Word count: computed from the markdown, checked against 13,000 words. The count for the certificate of compliance is this count, not the filed brief's count.
- Certificates of compliance and of service are generated from the frontmatter (`date`, `signature`).

## Markdown contract

Same shape as the Ninth Circuit's contract (see `courts/ninth-circuit/court-of-appeals/README.extra.md`), with these differences:

- Frontmatter: `case_number`, `caption`, `proceeding`, `brief_title`, `counsel` (groups of `names` and `lines`), `signature` (`signer`, `lines`), `date`, `authorities`. No `phone` (put telephone numbers in the `lines`), no `related_cases`, no `word_limit_basis`, no `service` (the certificate is always generated).
- Headings: no typed numerals; the template numbers them. `#` is a section; under `# Argument`, `##` is a point heading (I.), `###` A., `####` 1.; elsewhere `##` is A., `###` 1., `####` a.
- Case names and signals italic (`*Munaf v. Geren*`, `*See*`); every citation that goes in the TOA is a link `[text](toa:key)` with its key in `authorities:`.

## Known gaps

1. **Typeface (open; needs David).** The only vendored serif is EB Garamond. FRAP 32(a)(5) accepts it, but the court's December 2024 notice prefers Times New Roman, Century Schoolbook or Georgia and says it "discourages the use of Garamond," and the filed exemplar is in Century Schoolbook. Adding a font means changing the shared `fonts/` folder, which this box does not edit. Until a font is vendored, the sample is compliant with FRAP but not with the court's stated preference. This is the one tier-2 item left open.
2. **Cover colour.** Not produced: the template is paper-agnostic. The appellant's paper cover is blue under FRAP 32(a)(2); the electronic cover may be white.
3. **Disclosure statement.** Not generated. The exemplar (a government party) has none. A private appellant would need one, filed under FRAP 26.1 / Local Rule 26.1 and included in the brief (the court's requirements page).
4. **Excerpt only.** The sample is 14 pages of a 66-page filed brief. It omits brief pages 7–17 (Statement Parts B–G), 22–52 (Argument II.A.2 to II.C.3), and some of the Summary and Introduction paragraphs (each marked in the sample). The TOA lists only the authorities cited in the excerpt. The 1,523-word certificate count is the excerpt's, not the filed brief's 10,452.
5. **Cover layout.** The exemplar sets counsel in two columns side by side. The template stacks them in one column in the right half of the page, so counsel lines wrap and postal codes fall onto their own line. Content is complete and the cover fits one page.
6. **Overlay.** The overlay pairs pages by shared words. Because the sample is an excerpt, pairs are partial matches (word overlap 24–80%). Pairing is only indicative: our Table of Authorities (page 3) pairs with filed page 6 at 25%, which is a page of the filed Table of Authorities, but the match is weak because our TOA lists far fewer authorities.
7. **Certificates.** Only the CM/ECF service form is generated. Service on unregistered participants is not supported.

## Overlay map

From `samples/OVERLAY-netchoice-opening-brief.txt`: our pages 1–14 paired with the filed pages named there. Red is our render, blue the filed page, black where both agree. The overlay is a diagnostic: it shows where the layout diverges, not a score.

## Page review (Gate 2 input)

Every page of `samples/OUTPUT-netchoice-opening-brief.pdf` was rendered at 60 dpi and viewed. Folios are the printed ones.

| PDF page | Folio | Content | Finding |
|---|---|---|---|
| 1 | none | Cover | Fits one page. Counsel wraps in the narrow column (see gap 5). Re-rendered after shortening lines. |
| 2 | i | Table of contents | Entries, folios and indent correct. The Table of Authorities entry lists folio ii. |
| 3 | ii | Table of authorities | One page after reducing entry spacing from 0.7 em to 0.5 em; before, one line spilled onto an extra page. |
| 4 | 1 | Introduction | Body double-spaced; excerpt marker shown. |
| 5 | 2 | Issues, jurisdictional statement | Numbered issues render as a list. Fine. |
| 6 | 3 | Statement A, standard of review | Heading and subheading hang correctly. Excerpt marker shown. |
| 7 | 4 | Summary of argument | Case names italic. Excerpt marker shown. |
| 8 | 5 | Summary (cont.), Argument I | Point heading hangs under its numeral. |
| 9 | 6 | Argument I–II.A.1 | Sub-heading levels A./1. correct, italic at level 4. |
| 10 | 7 | Argument excerpt, III | Excerpt marker; TOA-linked citations correct. |
| 11 | 8 | Conclusion | Conclusion page ends with white space, as the exemplar does. |
| 12 | 9 | Request for oral argument, signature | Signature block stays with the request paragraph. |
| 13 | 10 | Certificate of compliance | Word count is the excerpt's (1,523). |
| 14 | 11 | Certificate of service | Matches the exemplar's CM/ECF wording. |

## Exemplar search, for the record

Searches (2026-10-14): CourtListener and RECAP for 4th Cir. opening briefs; the ca4 website's brief-requirement and rule pages; Justia docket pages for 2025 4th Cir. cases; advocacy-group repositories. The exemplar chosen is the NetChoice copy of the Attorney General's brief because it is a text-based PDF, a 4th Cir. opening brief, filed April 2026, and public. Others found and not used are listed in `exemplars/SOURCE.md`.
