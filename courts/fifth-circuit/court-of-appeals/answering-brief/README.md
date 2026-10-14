# Fifth Circuit: appellee's (answering) brief

Court: Court of Appeals for the Fifth Circuit (`ca5`). Folder: `courts/fifth-circuit/court-of-appeals/answering-brief/`.
Doc type: the appellee's principal brief, which the Fifth Circuit calls the "Brief of Appellee" (FRAP 28(b)).

Status of this doc type:

- exemplar: yes (one filed brief, see `exemplars/SOURCE.md`)
- sample: `samples/dawes-answering-brief.md` (a transcribed portion, 14 rendered pages)
- render: ok (`sh tools/render.sh courts/fifth-circuit/court-of-appeals/answering-brief samples/dawes-answering-brief.md`, no typst warnings)
- overlay: ok (`samples/dawes-answering-brief-overlay.pdf`, `-overlay.txt`)
- pages reviewed: 14 of 14 rendered (every page rasterized at 60 dpi and looked at; see the review log)

Not done: the tier-1 open questions under "Open questions" below. The template does not emit a red cover, and I could not confirm two local-rule points from primary text.

## Governing rules

Verified 2026-10-14. "Primary text" means the rule text was fetched and read; "secondary" means a search summary or a filed exemplar was the only source.

| ID | Requirement | Source | Verified | Where the template applies it |
|---|---|---|---|---|
| CA5-LEN-001 | Principal brief at most 13,000 words, excluding the items in FRAP 32(f) | FRAP 32(a)(7)(B)(i), https://www.law.cornell.edu/rules/frap/rule_32 | 2026-10-14, primary text | `word-limit` and the word-count check in `ca5-brief()` |
| CA5-FORM-002 | 8½ × 11 paper; margins at least one inch on all four sides; page numbers may sit in the margin | FRAP 32(a)(4), same URL | 2026-10-14, primary text | `page-margin = 1in`, `paper: "us-letter"` |
| CA5-FORM-003 | Text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced | FRAP 32(a)(4), same URL | 2026-10-14, primary text | `body-leading`, `single-leading`, block quotes |
| CA5-FORM-004 | Proportionally spaced face with serifs; 14-point or larger; sans-serif only in headings and captions | FRAP 32(a)(5)(A), same URL | 2026-10-14, primary text | EB Garamond (vendored) at `type-size = 14pt`, footnotes at 14 pt too |
| CA5-FORM-005 | Plain roman type; italics or bold for emphasis; case names italicized | FRAP 32(a)(6), same URL | 2026-10-14, primary text | `*Case v. Name*` in the markdown is italic |
| CA5-COVER-001 | Cover: case number centred at the top; name of court; title of the case; nature of the proceeding and the court below; brief title identifying the party; counsel's name, office address, telephone | FRAP 32(a)(2)(A)-(F), same URL | 2026-10-14, primary text | `cover-body()` |
| CA5-COVER-002 | Appellee's cover is red | FRAP 32(a)(2), same URL | 2026-10-14, primary text | NOT implemented: see Open questions |
| CA5-STRUCT-001 | Appellee's brief must contain the content of FRAP 28(a)(1)-(8) and (10), except the jurisdictional statement, statement of issues, statement of the case and statement of the standard of review, unless the appellee is dissatisfied with the appellant's | FRAP 28(b), https://www.law.cornell.edu/rules/frap/rule_28 | 2026-10-14, primary text | Missing `# Argument` or `# Conclusion` stops the build (`ca5-brief()`); the others are optional |
| CA5-STRUCT-002 | Table of contents with page references; table of authorities with page references | FRAP 28(a)(2)-(3), same URL | 2026-10-14, primary text | `toc-section()`, `toa-section()` |
| CA5-STRUCT-003 | Summary of argument; argument; conclusion | FRAP 28(a)(7)-(9), same URL | 2026-10-14, primary text | Markdown sections; argument and conclusion are checked |
| CA5-STRUCT-004 | Addendum of statutes, rules and regulations, if the study of them requires it | FRAP 28(f), same URL | 2026-10-14, primary text | `# Addendum` (not exercised in the sample) |
| CA5-CERT-001 | Certificate of compliance: type-volume (FRAP 32(a)(7)(B)) with the word count, excluding the FRAP 32(f) items | FRAP 32(g)(1), same URL | 2026-10-14, primary text | `certificate-of-compliance()` |
| CA5-CERT-002 | Certificate of compliance: typeface (FRAP 32(a)(5)) and type style (FRAP 32(a)(6)), with the program and size | FRAP 32(g)(1), same URL | 2026-10-14, primary text | Frontmatter field `prepared_with` |
| CA5-CERT-003 | Certificate of service; privacy statement | FRAP 25(d) and 25(a)(5), https://www.law.cornell.edu/rules/frap/rule_25 | 2026-10-14, primary text | `certificate-of-service()`, used when `service.certificate: true` |
| CA5-CERT-004 | Certificate of interested persons, Fifth Circuit Local Rule 28.2.1 (a governmental party may be exempt) | The filed exemplar cites it (`exemplars/SOURCE.md`); the rule text was not found | secondary | Frontmatter field `interested_persons`, printed before the table of contents |
| CA5-LOCAL-001 | Local Rule 32.3 and Form 6: certificate of compliance; a 2023 notice proposed adding a generative-AI certification | Notice of proposed amendment, https://www.ca5.uscourts.gov/docs/default-source/default-document-library/public-comment-local-rule.pdf (comments closed 4 Jan 2024) | 2026-10-14, primary text of the notice; adoption NOT confirmed | Not implemented: see Open questions |

Word limit in the sample: 1,333 words, counted by the template from the sample markdown. The exemplar's own certificate says 10,199 words; the two numbers are not comparable, because the sample is a portion.

## Layout of this folder

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-dawes-v-city-of-dallas-25-10979-answering-brief.pdf` | The filed exemplar: Brief of Appellee City of Dallas, Document 38, 62 pages, text-based (pdftotext yields the text). |
| `exemplars/SOURCE.md` | Where it came from, the docket, the filer, the date filed and fetched. |
| `typst/main.typ` | Entry point. Reads `--input sample=...` and calls the template. |
| `typst/ca5-answering-brief.typ` | The template, `ca5-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top, each tied to a rule ID above. |
| `samples/dawes-answering-brief.md` | Markdown for the exemplar: frontmatter (cover, counsel, certificates, authorities) and a portion of the body. |
| `samples/dawes-answering-brief.pdf` | Render of the sample, 14 pages. |
| `samples/dawes-answering-brief-overlay.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar, and the page map. |

## Markdown contract (differences from ca9)

The schema follows `courts/ninth-circuit/court-of-appeals/README.extra.md`, with these changes:

- Frontmatter fields, new: `counsel_for` (printed in capitals under the counsel block), `interested_persons` (text of the certificate of interested persons, printed on its own page before the table of contents), `oral_argument` (text of the statement regarding oral argument, printed on its own page), `prepared_with` (required; names the program and font for the certificate of compliance), `date` (required when `service.certificate` is true).
- Frontmatter fields, dropped: `related_cases`, `word_limit_basis`, `manual_image_words`, `district_court_case`, `judge`. The Fifth Circuit has no Form 17 or Form 8 check boxes, and the template prints no district-court-case line.
- `service.recipients` (text) replaces the ca9 list of unregistered participants.
- Required body sections: `# Argument` and `# Conclusion`. Otherwise the body is free (the appellee need not have a jurisdictional statement, statement of issues or standard-of-review heading; the exemplar has a "Response to Statement of Issues", which the sample keeps).
- Heading numbering: Argument points I., II. (level 2, centred), A. (level 3), 1. (level 4), a. (level 5); elsewhere A., 1., a., (1). Same as ca9.
- The footnote definition is not the last block of the body: the template keeps the last body paragraph with the signature block, and a footnote definition at the end of the body would defeat that (`ca5-brief()`), so it sits after its reference.

## What the overlay shows

`tools/overlay.sh` paired each sample page with the exemplar page sharing the most words:

- red: our render only; blue: the filed exemplar only; black: both agree.
- Pages are paired by word overlap, not by index, so a partial transcription still lines up with the pages it came from.

Map (from `dawes-answering-brief-overlay.txt`):

| Ours | Filed | Word overlap | Note |
|---|---|---|---|
| p.1 | p.1 | 83.0% | cover |
| p.2 | p.2 | 65.5% | certificate of interested persons |
| p.3 | p.3 | 80.0% | statement regarding oral argument |
| p.4 | p.4 | 49.3% | table of contents (ours lists fewer headings: the sample is a portion) |
| p.5 | p.8 | 32.1% | table of authorities (ours is a different set; the sample cites fewer authorities) |
| p.6 | p.10 | 9.3% | table of authorities, second page |
| p.7 | p.12 | 87.0% | response to statement of issues, statement of the case |
| p.8 | p.13 | 73.6% | statement of the case (facts) |
| p.9 | p.19 | 60.1% | summary of argument |
| p.10 | p.20 | 50.3% | argument I |
| p.11 | p.22 | 35.7% | argument II |
| p.12 | p.23 | 37.9% | argument II.A (Graham factors) |
| p.13 | p.61 | 61.4% | certificate of service |
| p.14 | p.62 | 57.4% | certificate of compliance |

A low number on p.5, p.6, p.11 and p.12 is expected: the sample transcribes part of the brief and uses the template's own table of authorities, so the filed page it pairs with shares few words. The overlay is a diagnostic, not a score; read it for layout (where the lines fall, the cover, the headings), not for the number.

## Review log (Gate 2)

All 14 pages were rendered at 60 dpi and looked at. Findings and their fates:

| Page | Finding | Fate |
|---|---|---|
| 1 cover | The court's name wrapped to leave "CIRCUIT" alone on a line. | Fixed: the name is set in a narrower block (75%), so it breaks after "APPEALS". No forced break. |
| 1 cover | The counsel-for line ("ATTORNEYS FOR THE CITY OF DALLAS") wraps to two lines. | Accepted: a long line wrapping; the cover still fits one page. |
| 2 | Certificate of interested persons on its own page, signature. | OK. |
| 3 | Statement regarding oral argument on its own page. | OK. |
| 4 contents | "11" wrapped onto a line of its own for long entries; the dot leader was too narrow. | Fixed: each TOC row is a three-column grid (title, leader, page), so the title wraps in its own column and the page number stays on the row. |
| 5-6 authorities | Cases and rules in alphabetical order, page references, "Page(s)" heading. Italic case names. | OK. |
| 7 | Response to statement of issues, statement of the case; footnote 1 at 14 pt, continues to page 8. | OK. |
| 8-9 | Facts, summary of argument; running text. | OK. |
| 10 | Argument point I in small caps, centred; block quote indented and single-spaced; "[W]here" bracket preserved. | OK. |
| 11 | Point II heading wraps across three lines, centred; sub-point A hangs under its label. | OK. |
| 12 | Conclusion heading and paragraph, then signature block kept together. | OK. Changed from an earlier render in which the signature stood alone on page 13 (the footnote definition was the last block; see the last bullet of the Markdown contract). |
| 13 | Certificate of service. | OK. |
| 14 | Certificate of compliance: two numbered paragraphs with the word count and the typeface statement. | Fixed: the two paragraphs were run together (no paragraph break); now separate. |

Pages changed after the review: pages 1 and 4 were rendered again after the cover and TOC fixes, and looked at; the rest of the layout did not change.

## Open questions (for David)

1. Cover colour. FRAP 32(a)(2) says an appellee's cover is red. The template does not colour the cover, and the filed exemplar's cover is plain (checked: greyscale). Decide whether the Fifth Circuit's e-filed PDF must be red, or whether this is paper-only as the ca9 template treats it. If it must be red, add it to `cover-body()` for this doc type.
2. Generative-AI certification. The 2023 notice of proposed amendment to Fifth Circuit Local Rule 32.3 and Form 6 would require a certification that no generative AI was used, or that its output was reviewed. Adoption is not confirmed; the Dawes brief (January 2026) carries the pre-amendment certificate text. The template does not add the certification. Decide whether to add it once the adoption is confirmed.
3. Local Rules 28.2.1 and 32.2. The template uses the FRAP limits (13,000 words, 14 pt) and the certificate of interested persons as the exemplar uses it. The rule text of the Fifth Circuit's own local rules was not found in a primary source; a search result gave the checklist figures (30 pages, 1,300 lines, 13,000 words) which match FRAP. Check the current local rules before relying on the local numbers.
4. Typeface. EB Garamond 14 pt (vendored, FRAP-compliant) instead of the exemplar's Century Schoolbook. Clerks may expect the look of the exemplar; this is a tier-2 convention choice, not a rule failure.
5. Certificate of interested persons with a list. The template prints the text given in `interested_persons`. The exemption form is the only one exercised; a private filer's list of persons is not in the sample.
6. Signature block. The sample has one signer; the exemplar lists several attorneys. The template supports a list in `signature.lines` only for the signer's own lines.

## Searches tried for the exemplar

- CourtListener search API, `type=r` (RECAP documents), `court=ca5`, with `"brief of appellee"`, `"appellee's brief"`, `"brief for appellee"`, `"brief of appellees"`, `"answering brief"`, `"brief for the appellee"`, `"brief of the appellee"`. Kept only available documents of 15 pages or more.
- Candidates downloaded and checked for text (pdftotext) and structure: Dawes v. City of Dallas, No. 25-10979 (Document 38, 62 pp.; chosen: a government appellee, a full brief with cover, contents, tables, argument, certificates); Domanic v. Christian Brothers Automotive, No. 25-20486 (Document 32, 54 pp., a second candidate, not used because the exemplar slot takes one file); Emmerich Newspapers v. Particle Media, No. 25-60550 (Document 63, 81 pp., not used).
- The Fifth Circuit's own "brief guidance and sample briefs" checklist page returned 404 to WebFetch; the Texas Public Policy Foundation brief returned 403. Neither was used.
