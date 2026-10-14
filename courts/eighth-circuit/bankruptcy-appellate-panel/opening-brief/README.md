# Eighth Circuit BAP (bap8): opening brief (appellant's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `samples/` are untouched.
- Doc type: `opening-brief`. Appellant's brief, FRBP 8014(a).
- **Exemplar: yes.** `exemplars/FILED-EXAMPLE-fisette-11-6012-opening-brief.pdf`: Brief of Appellant, Michael James Fisette, BAP No. 11-6012, filed 2011-04-07 (68 pages, text-based, public). Source, URL, filer and fetch date in `exemplars/SOURCE.md`.
- **Sample: transcription.** `samples/INPUT-fisette-11-6012.md` transcribes the filing's cover, party list, body from the Jurisdictional Statement (filing p. 7) through the Nobelman block quote (p. 15), the conclusion (pp. 26-27), the signature and the service certificate. Filing page 15 after the block quote through page 25 (rest of Argument II, Arguments III-VII) is omitted; the omission is marked in the file.
- Render: ok, `samples/OUTPUT-fisette-11-6012.pdf`, 19 pages, typst with no warnings (2026-10-14).
- Overlay: ok, `samples/OVERLAY-fisette-11-6012.pdf` and `.txt` (19 pages, 2026-10-14). Diagnostic only, see below.
- Pages reviewed: 19 of 19 as PNG at 60 dpi (2026-10-14). Pages 3, 4, 11, 12 and 14 were re-viewed after the heading-numeral fix; the rest were viewed in the render before it, and the fix did not change pagination.
- Status: `court.json` untouched; `status` not set. No `tracker.sh`, no `STATUS.md`.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(a)(4)-(9) order), `needs-standard-of-review`. |
| `samples/INPUT-fisette-11-6012.md` | Markdown transcription of the filed brief (contract below). |
| `samples/OUTPUT-fisette-11-6012.pdf` | Render of the transcription (`sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief samples/INPUT-fisette-11-6012.md`). |
| `samples/OVERLAY-fisette-11-6012.pdf`, `.txt` | Overlay on the exemplar (`sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief fisette-11-6012`). |
| `exemplars/FILED-EXAMPLE-fisette-11-6012-opening-brief.pdf`, `exemplars/SOURCE.md` | The filed exemplar and its source log. |

Template change this run: `required-sections` now matches `^(statement of (the )?)?jurisdiction`, so a heading "Jurisdictional Statement" (the filing's wording) passes. The old pattern required the words "statement of" and rejected the filing. Nothing else in the template changed. The answering and reply templates have their own copies of the pattern and are untouched.

## Markdown contract (frontmatter)

`case_number` (printed after "BAP No."), `caption` (list of `{names, designation}`; the template prints "v." between sides), `proceeding`, `brief_title`, `counsel` (list of `{names, lines}`), `phone`, `email`, `signature` (`signer`, `for`, `lines`), `date`, `word_processor`, `typeface`, `interested_parties` and `related_cases` (markdown; L.R. BAP 8014A(b)), `disclosure` (optional; FRBP 8014(a)(1)), `service` (`certificate`; `unregistered` list of `name`/`address`), `authorities` (key: `{kind: case|statute|rule|constitution|regulation|other, cite, name}`). Body citations are `[text](toa:key)`; a `toa:` link in a heading is refused. An authority cited in the body must be in `authorities`.

Transcription notes for `INPUT-fisette-11-6012.md`:
- The filing's "Email" is absent (the 2011 filing has none). The `email` field and the signature block say "Not stated in the filed brief" rather than inventing an address.
- The filing gives two suites for counsel: 2001 Killebrew Drive, Suite 330 on the cover and Suite 300 in the signature. Both are kept as printed.
- The filing's page 2 lists three creditor parties only; those are the interested parties printed.
- The filing states no related cases; `related_cases` says so.
- Case names are plain text, as in the filing's text layer, not italic.

## Governing rules

Primary sources, read on 2026-10-14:
- FRBP 8014 and 8015 (restyled, as amended Apr. 2, 2024, eff. Dec. 1, 2024), text from <https://www.law.cornell.edu/rules/frbp/rule_8014> and <https://www.law.cornell.edu/rules/frbp/rule_8015>. This is a mirror of the official text; the official text was not fetched.
- Committee Notes to FRBP 8015 (2014, 2018, 2020, 2024), same page. Used for: no cover-color rule (2014 note); the 2020 note on the e-filing change to the proof-of-service requirement (FRBP 8011(d)).
- Local Rules of the United States Bankruptcy Appellate Panel for the Eighth Circuit, December 2023 version, <https://ecf.ca8.uscourts.gov/newbap/rules/localrules_bapDec2023.pdf>, read with `pdftotext` on 2026-10-14: L.R. BAP 8th Cir. 8014A(a)-(c), 8015A.
- Not fetched: Official Form 417C (type-volume certificate); FRBP 8012 (disclosure statement); the BAP Internal Operating Procedures.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 8014(a)(1)-(10) | Order: disclosure (if 8012), TOC, TOA, jurisdiction, issues with standard of review, case, summary, argument, conclusion, certificate of compliance | `required-sections`, `needs-standard-of-review`, `disclosure`, `certificate-of-compliance` |
| FRBP 8014(a)(4)(A)-(D) | Jurisdiction: bankruptcy court, BAP, timeliness, final order | section heading check only; content not checked |
| FRBP 8015(a)(2)(A)-(F) | Cover: case number at top; court name; case title (8003(d)(2)); nature of proceeding and court below; brief title; counsel name, address, telephone and email | `cover-body` |
| FRBP 8015(a)(4) | 8.5 x 11; double spaced; long quotations may be single spaced; headings and footnotes single spaced; margins at least 1 inch | `page`, `body-leading`, quote and footnote styles |
| FRBP 8015(a)(5)(A) | Proportional face with serifs, 14 pt or larger | `type-size = 14pt`; `font-family = "EB Garamond"` (the only vendored serif) |
| FRBP 8015(a)(6) | Plain roman; italics or bold for emphasis; case names italic or underlined | markdown emphasis; the template does not guess case names |
| FRBP 8015(a)(7)(B)(i) | Principal brief: 13,000 words (or 1,300 monospaced lines), with certificate | `word-limit = 13000` (panic when exceeded) |
| FRBP 8015(g) | Excluded from length: cover, disclosure, TOC, TOA, oral-argument statement, statute addendum, certificate, signature block, proof of service. Headings, footnotes and quotations count. | `strip-oral-argument`; cover, TOC, TOA, certificates and signature sit outside the body count |
| FRBP 8015(h)(1)-(2) | Type-volume certificate; Form 417C substantially conforming | `certificate-of-compliance` (wording not checked against Form 417C) |
| L.R. BAP 8th Cir. 8014A(b)(1)-(2) | Certification of Interested Parties; Certification of Related Cases | `certifications`. Placement before the TOC is a choice; the rule does not fix it. |
| L.R. BAP 8th Cir. 8014A(a) | Record citations identify docket entry, page and line | not checked; the markdown text is the only input |
| L.R. BAP 8th Cir. 8014A(c) | CM/ECF service; paper copy to a non-participant with a certificate stating date, method and address | `certificate-of-service`, shown when `service.unregistered` is given or `service.certificate` is true |
| FRBP 8014(d) | Statutes set out in the brief or in an addendum | no addendum section; a `# Addendum` heading is refused |

## Gate 2: page review

Every page of the render was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Typst printed no warnings. Fonts embedded: EB Garamond only. Page numbers in the table are the printed numbers of the render; the body numbering follows the brief's own pages (body page 1 is the Jurisdictional Statement).

| Page | Content | Result |
|---|---|---|
| 1 | Cover: BAP No., court, caption, proceeding, title, counsel. Unnumbered. | OK. Email line reads "Not stated in the filed brief" (see transcription notes). |
| 2 | Certification of Interested Parties (i) | OK. |
| 3 | Certification of Related Cases (ii) | OK. |
| 4 | Table of Contents (iii) | OK after a fix: argument subsection numerals printed twice ("I. I."). The numerals are removed from the transcribed headings; the template numbers them. Re-viewed. |
| 5 | Table of Authorities (iv) | OK. Cases with pages. |
| 6 | Table of Authorities, statutes and rules (v) | OK. |
| 7 | Jurisdictional Statement; Statement of Issues on Appeal (1) | OK. The heading now passes (see Template change). |
| 8 | Standard of Review; Statement of the Case (2) | OK. |
| 9 | Statement of the Case (3) | OK. |
| 10 | Statement of the Case (4); Summary of Argument begins | OK. |
| 11 | Summary of Argument (5) | OK. Re-viewed. |
| 12 | Summary of Argument (6); Argument heading I | OK after the fix (heading "I. The right to..." printed once). Re-viewed. |
| 13 | Argument I (7); footnote 1 | OK. |
| 14 | Argument II heading and text (8) | OK after the fix (heading "II." printed once). Re-viewed. |
| 15 | Argument II (9) | OK. |
| 16 | Argument II, block quote from Nobelman (10) | OK. Block quote single-spaced. |
| 17 | Conclusion, continued; signature block (11) | OK. Signature block stays with the last paragraph. |
| 18 | Certificate of Compliance (12) | OK. Shows the count of the transcribed body (2,644 words), not the filing's count (6,491). See Known gaps. |
| 19 | Certificate of Service (13) | OK. Lists the four unregistered recipients. |

Pages reviewed: 19 of 19.

## Overlay

Run: `sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief fisette-11-6012`. Exit 0; writes `OVERLAY-fisette-11-6012.pdf` (19 pages) and `.txt`.

Page map (sample page to exemplar page, by shared words):
- Body pages 7 to 9 of the render pair with filed pages 7 to 9 at 65-95% word overlap; body pages 10 to 16 pair at 46-84%.
- Cover and front matter pair at 16-60%; the contents page (ours p.4) pairs with filed p.3 at 44%. These pairings are word-set guesses, not matched pages. Ours p.3 (related-cases certification) pairs with filed p.27 at 27%, which is not a real correspondence.
- Conclusion and certificates (ours p.17-19) pair with filed pp. 27-30 at 16-53%, which do not correspond to each other.

What the overlay shows: our text and the filing's text share words and paragraphs, but the lines do not line up. The filing is Times New Roman, not embedded, with its own leading and margins; our template is EB Garamond at 14 pt double-spaced. This is the tier-3 mismatch (matching one filer's style), which is not chased. The overlay is a diagnostic only.

## Known gaps

- **Partial transcription.** Filing pages 7-15 and 26-27 are transcribed (11 pages of body, which is the render's pages 7-17). Filing page 15 after the block quote through page 25 is omitted and marked in the file. The render is 19 pages in all: the cover, the interested-parties and related-cases certifications, contents, two pages of authorities, 11 body pages, and the certificate of compliance and certificate of service.
- **Certificate of compliance.** The template computes the word count from the markdown it receives, so the certificate says 2,644 words for the transcribed body. The filing's certificate says 6,491 words for the whole brief. The filing's certificate is not reproduced.
- **Certificate of service wording.** Template wording ("I hereby certify ...by using the CM/ECF system") follows L.R. BAP 8014A(c) and does not copy the filing's wording. The recipients are the filing's.
- **Email.** The filing has no counsel email. The template requires an `email` field; the render says "Not stated in the filed brief" instead of inventing one.
- **Typeface.** The filing is Times New Roman (not embedded; `pdffonts` lists TimesNewRomanPS). The render uses EB Garamond, the only vendored serif. Matching the filer's typeface is tier 3 and is not chased.
- **Word-limit check.** The 13,000-word check runs on the transcribed body, not the full brief.
- **Jurisdiction content** (8014(a)(4)(A)-(D)) is not checked beyond the heading.
- **Standard-of-review and oral-argument checks are heuristics.** The first passes if the body says "standard of review" or a heading contains "standard"; the second matches a heading containing "oral argument". This brief has no oral-argument statement.
- **Cover color:** none. FRBP 8015 has no cover-color rule (2014 Committee Note).
- **Page limit:** only the type-volume (word) limit is enforced; the 30-page limit of 8015(a)(7)(A) is not counted.
- **Form 417C wording** is not verified.
- **Certifications placement:** before the TOC, by choice (see the rules table).
- **Disclosure statement:** rendered only when `disclosure` is given. The filing has no disclosure statement, so none is given.
- **Trustee's brief and the reply** in this case were not found (Justia is blocked from this box). See `../answering-brief/exemplars/SOURCE.md` and `../reply-brief/exemplars/SOURCE.md`.
