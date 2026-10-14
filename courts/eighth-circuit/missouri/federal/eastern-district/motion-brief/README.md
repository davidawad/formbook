# moed: motion-brief

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b) motion to dismiss, in the United States District Court for the Eastern District of Missouri (`moed`).
Folder: `courts/eighth-circuit/missouri/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-harmony-pointe-4-26-cv-00011-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-harmony-pointe-motion-brief.md` (a transcription of the filing, 9 rendered pages; see "Sample" below) |
| render | ok: `samples/OUTPUT-harmony-pointe-motion-brief.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-harmony-pointe-motion-brief.pdf` and `samples/OVERLAY-harmony-pointe-motion-brief.txt` (page map) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last change to the sample) |
| BLOCKED | none |

File names: `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf/.txt`, so the names follow the tools, not the brief's `<id>.pdf` / `<id>-overlay.pdf` spelling.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Mo. L.R. 2.01(A)(1) | "All filings, unless otherwise permitted by leave of Court, shall be in 12-point or larger font, double spaced, typed or legibly written on 8 1/2 by 11-inch pages." Also: the signer's name, address, telephone, email and state bar registration number immediately beneath each signature. | `type-size = 12pt`, `pitch = 24pt`, `page-w/page-h`; `signature-block()` prints each firm block from `signature` frontmatter. |
| E.D. Mo. L.R. 2.01(A)(2) | A blank area no smaller than 2 by 2 inches in the upper left and upper right corners of the first page. | `court-title()` is a fixed band from the top margin to the 2 inch line, so the caption starts below the corners. |
| Typeface (no face named) | Face required: none. L.R. 2.01 sets size, spacing and paper, not a typeface (see the verification note). Vendored substitute: EB Garamond, the default in `docs/FONTS.md` for a court that names no face. Fit: n/a. | `font-family = "EB Garamond"` in `moed-motion-brief.typ`. |
| E.D. Mo. L.R. 4.01(A) | A motion is filed with a supporting memorandum (the moving party files its memorandum with the motion). | Content of the filing system, not checked by the template; the sample is the memorandum only. |
| E.D. Mo. L.R. 4.01(D) | No motion, memorandum or brief may run past 15 numbered pages without leave. The table of contents, table of authorities, signature page and attachments are not counted. Statements of material fact under 4.01(E) are not counted. | Not enforced (the template cannot count pages against the limit). The sample renders at 9 pages, so it is under the limit. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | `CERTIFICATE OF SERVICE` heading in the sample, placed after the signature block (the template moves the signature ahead of any heading starting "CERTIFICATE"). The certificate is optional: the exemplar has one, so the sample has one. |
| Fed. R. Civ. P. 12(b)(1), 12(b)(6) | The motion and the memorandum's grounds. | Content, not checked by the template. |

Verification status of the rules (2026-10-14):

- **L.R. 2.01(A)(1)-(2)**: text read from search excerpts of the court's rule PDF and of a courtrules.net copy. The court's PDF host and courtrules.net refused the fetch from this box, so the rule was not read in full, and the date of the current text is not confirmed. Re-check against the current PDF (the court's December 2025 amendments are on its local-rules page) before a filing.
- **L.R. 4.01(D)**: the 15-page limit and the exclusions read from search excerpts of courtrules.net and of a judge's requirements PDF; not read in full from the court's PDF.
- **L.R. 4.01(A)**: the memorandum-with-motion requirement read from the same search excerpt.
- **Fed. R. Civ. P. 5(d)(1)(B)**: text confirmed in search excerpts.
- **Typeface (2026-10-14)**: search excerpts of L.R. 2.01(A)(1) (courtrules.net copy and the court's rule PDF) give size, spacing and paper, and name no face. courtrules.net returned HTTP 403 to the fetch, and the court's November 2019 press release PDF could not be read as text here (its "standard font" sentence is unread). "No face named" therefore rests on those excerpts; re-check the full rule before a filing. If the rule does name a face, switch `font-family` to the substitute in `docs/FONTS.md`.
- Judge-specific requirements are not in the template. One E.D. Mo. judge's published requirements set a 13-point size for memoranda and a page limit with leave; another requires a table of contents and table of authorities above 10 pages. The assigned judge's requirements must be checked before filing. None of these are verified for the judge assigned to this case.

## Layout

- Page: 8 1/2 by 11 inch, 1 inch margins (the margin is not stated in L.R. 2.01; 1 inch is the convention used here), page number centered at the foot of each page.
- Text: EB Garamond 12 pt (the substitute for a court that names no face, per `docs/FONTS.md`), body at a 24 pt baseline pitch (double spacing).
- First-page caption: court name block in the top band; parties in a left column with a right and bottom rule; "Case No." at right. The exemplar uses a column of ")" marks; the template uses the rule (see Known gaps).
- Body: unnumbered prose with a 0.5 inch first-line indent.
- Headings: level 1 centered bold caps (NATURE OF THE CASE, ARGUMENT, CONCLUSION); level 2 bold, left (I., II. ...); level 3 bold with a 0.5 inch indent (A., B. ...).
- Notes (`> ...` in the sample): single spaced, unnumbered. The template has no footnote mechanism, so footnote text sits in the note style at its place in the text.
- Signature: "DATED:" line only if the frontmatter gives a date (the exemplar has none; the date is in the certificate), "Respectfully submitted," and each firm block at 3.25 inch indent, single spaced, then the party represented.
- Certificate of service: a heading starting "CERTIFICATE" makes the template print the signature block before it; the `/s/` line is at the signature indent.

## Sample

The sample transcribes the filing's caption, title, lead-in, NATURE OF THE CASE, SUMMARY OF ARGUMENT, BACKGROUND, LEGAL STANDARD, ARGUMENT I to IV (in full, except footnote 1 and footnote 2 handling below), CONCLUSION, signature block and certificate of service. The filing's footnotes are handled as follows:

- footnote 1 (the Missouri-takings paragraph, filing page 8): transcribed inline as the last paragraph of II.B;
- footnote 2 (the "Moot" to "Not Ripe" correction, filing page 10): transcribed as a note at the start of III.B;
- footnote 3 (the exhaustion and ripeness distinction, filing page 10): transcribed inline in III.B.

The sample carries no pin-cite changes; citations are as filed. Case names are italic in the sample; the exemplar's text layer has no italics, so the italic is convention, not checked against the exemplar.

## Known gaps and open choices

1. **One filer only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers from different firms. The search also found Killgo v. The Washington University, 4:25-cv-01407-CMS (Doc. 51, 15 pages, a memorandum in support of a partial motion to dismiss by defendants' counsel), which was downloaded, has a text layer, and was not kept because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers. OPEN.
2. **Font.** L.R. 2.01 names no typeface, so the template keeps EB Garamond (`docs/FONTS.md`: a court that names no face keeps EB Garamond). The exemplar is Times New Roman, and EB Garamond looks smaller at 12 pt. The 12-point minimum is met. The difference is visual only, and switching to a Times substitute (Liberation Serif) would be a choice the rule does not require. ACCEPTED (tier 2); David may choose otherwise.
3. **Caption closing.** The exemplar uses a column of ")" marks between the party names and the case number; the template uses a right and bottom rule on the party column. Both are seen in E.D. Mo. filings. ACCEPTED (tier 2).
4. **Footnotes.** The template has no footnote mechanism, so footnotes are transcribed inline or as notes. This removes the footnote numerals and the page-foot placement. ACCEPTED (tier 2/3).
5. **Length.** The sample is 9 pages (about 3,100 words of body text). The filing's memorandum text is about 3,700 words over 13 pages. The template sets more words per page than the filing (EB Garamond 12 pt, 1 inch margins), so the sample's 9 pages are within the 8 to 14 page target but are not the filing's page count. The sample omits two citations from the filing: "See Compl., ¶¶ 105-06" in Part I, and *301, 712, 2103 & 3151 LLC v. City of Minneapolis*, 27 F.4th 1377 (8th Cir. 2022) in Part II.B. No argument heading is omitted. The L.R. 4.01(D) limit (15 pages) is met by the sample; the template does not count pages.
6. **Overlay pairing.** Pages pair by word overlap. Pages 2, 5 and 9 share 47-51% of their words with their pairs; the rest share 57-86%. The overlay is a diagnostic, not a score.
7. **Justification.** The template sets ragged-right text; the exemplar's justification could not be read from its text layer. ACCEPTED (tier 2/3).
8. **Pin cites and the Westlaw star page.** Star pages (`at *2`) are escaped in the Markdown (`\*`), so they render as asterisks, not italics. The sample does not check the cited authorities (their existence and their pin cites are as filed).
9. **Keep-with-next gap.** A Part heading moves to the next page with its first paragraph, which leaves a few lines empty at the foot of page 6. This is the intended behaviour (a heading never ends a page), not a defect.

## Gate 2: rendered pages (current PDF, 60 dpi, viewed)

- Page 1: court name in the top band, caption below the 2 inch line, "Case No." at right, title, lead-in, NATURE OF THE CASE, start of SUMMARY OF ARGUMENT. The top-left and top-right 2 by 2 inch corners are blank. Pass.
- Page 2: the rest of SUMMARY OF ARGUMENT (Count II, the "Finally..." paragraph, the alternative request), BACKGROUND, and the paragraphs on SWO 1 and the start of SWO 2. Pass.
- Page 3: SWO 2 and 3 paragraph, LEGAL STANDARD, the 12(b)(6) and 12(b)(1) paragraphs, the Williams citation. Pass.
- Page 4: ARGUMENT heading, Part I (Count I) paragraphs with Chesterfield, Myers and Grove, bold heading at the left. Pass.
- Page 5: the rest of Part I (Prewitt, Lemke, Saba), Accordingly, Count I ..., Part II heading, Part II.A with Cedar Point. Pass.
- Page 6: Part II.A (the Cedar Point distinction) and II.B (Penn Central, Becker, footnote 1 inline, the Missouri-takings paragraph). Pass.
- Page 7: Part III heading and its introduction; III.A with Jeffco, Baycol, Owydat and Kelly; the exhaustion paragraph. Pass.
- Page 8: III.A end; III.B heading with the footnote 2 note; III.B text with footnote 3 inline; Saba; Part IV heading and the Chesterfield quote. Pass.
- Page 9: Part IV end, CONCLUSION, the signature block at 3.25 inch indent with bar numbers and contacts, CERTIFICATE OF SERVICE with the service paragraph and the /s/ line. Pass.

Defects found and fixed during review: the first render stacked each block on the one before it (a block's height excluded the trailing leading, so each paragraph overlapped the last line of the one before). Fixed by a `below` gap of one body leading on every body block; the same fix is in the complaint template. A stray date line ("DATED:") that the exemplar does not carry was removed from the sample. Footnote numbering in the first draft of the sample was wrong (the footnote 3 note was a footnote 2); corrected as in "Sample" above.
