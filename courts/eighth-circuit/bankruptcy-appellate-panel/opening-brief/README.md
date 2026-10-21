# Eighth Circuit BAP (bap8): opening brief (appellant's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `usage/` are untouched.
- Doc type: `opening-brief`. Appellant's brief, FRBP 8014(a).
- **Exemplar: yes.** `usage/FILED-EXAMPLE-opening-brief.pdf`: Brief of Appellant, Michael James Fisette, BAP No. 11-6012, filed 2011-04-07 (68 pages, text-based, public). Source, URL, filer and fetch date in `usage/SOURCE.md`.
- **Sample: transcription.** `usage/INPUT-opening-brief.md` transcribes the filing's cover, party list, body from the Jurisdictional Statement (filing p. 7) through the Nobelman block quote (p. 15), the conclusion (pp. 26-27), the signature and the service certificate. Filing page 15 after the block quote through page 25 (rest of Argument II, Arguments III-VII) is omitted; the omission is marked in the file.
- Render: ok, `usage/OUTPUT-opening-brief.typst.pdf`, 20 pages, typst with no warnings (2026-10-21, fb-595.65; 32.2 pt body line pitch).
- Overlay: ok, `usage/OVERLAY-fisette-11-6012.pdf` and `.txt` (19 pages, 2026-10-14). Diagnostic only, see below.
- Pages reviewed: 19 of 19 as PNG at 60 dpi (2026-10-14). Pages 3, 4, 11, 12 and 14 were re-viewed after the heading-numeral fix; the rest were viewed in the render before it, and the fix did not change pagination.
- Status: `court.json` untouched; `status` not set. No `tracker.sh`, no `STATUS.md`.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(a)(4)-(9) order), `needs-standard-of-review`. |
| `eval.yaml` | Check settings for `tools/check.sh`: 14 pt body size and BAP8-FORM-003 (body baseline pitch >= 28 pt, FRBP 8015(a)(4)), added to the default checks. |
| `usage/INPUT-opening-brief.md` | Markdown transcription of the filed brief (contract below). |
| `usage/OUTPUT-opening-brief.typst.pdf` | Render of the transcription (`sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md`). |
| `usage/OVERLAY-fisette-11-6012.pdf`, `.txt` | Overlay on the exemplar (`sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief fisette-11-6012`). |
| `usage/FILED-EXAMPLE-opening-brief.pdf`, `usage/SOURCE.md` | The filed exemplar and its source log. |

Template change this run: `required-sections` now matches `^(statement of (the )?)?jurisdiction`, so a heading "Jurisdictional Statement" (the filing's wording) passes. The old pattern required the words "statement of" and rejected the filing. Nothing else in the template changed. The answering and reply templates have their own copies of the pattern and are untouched.

## Markdown contract (frontmatter)

`case_number` (printed after "BAP No."), `caption` (list of `{names, designation}`; the template prints "v." between sides), `proceeding`, `brief_title`, `counsel` (list of `{names, lines}`), `phone`, `email`, `signature` (`signer`, `for`, `lines`), `date`, `word_processor`, `typeface`, `interested_parties` and `related_cases` (markdown; L.R. BAP 8014A(b)), `disclosure` (optional; FRBP 8014(a)(1)), `service` (`certificate`; `unregistered` list of `name`/`address`), `authorities` (key: `{kind: case|statute|rule|constitution|regulation|other, cite, name}`). Body citations are `[text](toa:key)`; a `toa:` link in a heading is refused. An authority cited in the body must be in `authorities`.

Transcription notes for `INPUT-opening-brief.md`:
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
| FRBP 8015(a)(4) | 8.5 x 11; double spaced; long quotations may be single spaced; headings and footnotes single spaced; margins at least 1 inch | `page`, `line-pitch` (32.2 pt) and `body-leading`, quote and footnote styles; checked by BAP8-FORM-003 in `eval.yaml` |
| FRBP 8015(a)(5)(A) | Proportional face with serifs, 14 pt or larger. No face named by the rule. | `type-size = 14pt`; `font-family = ("Times New Roman", "Liberation Serif")` (no court-named face; the filing's face, vendored) |
| FRBP 8015(a)(6) | Plain roman; italics or bold for emphasis; case names italic or underlined | markdown emphasis; the template does not guess case names |
| FRBP 8015(a)(7)(B)(i) | Principal brief: 13,000 words (or 1,300 monospaced lines), with certificate | `word-limit = 13000` (panic when exceeded) |
| FRBP 8015(g) | Excluded from length: cover, disclosure, TOC, TOA, oral-argument statement, statute addendum, certificate, signature block, proof of service. Headings, footnotes and quotations count. | `strip-oral-argument`; cover, TOC, TOA, certificates and signature sit outside the body count |
| FRBP 8015(h)(1)-(2) | Type-volume certificate; Form 417C substantially conforming | `certificate-of-compliance` (wording not checked against Form 417C) |
| L.R. BAP 8th Cir. 8014A(b)(1)-(2) | Certification of Interested Parties; Certification of Related Cases | `certifications`. Placement before the TOC is a choice; the rule does not fix it. |
| L.R. BAP 8th Cir. 8014A(a) | Record citations identify docket entry, page and line | not checked; the markdown text is the only input |
| L.R. BAP 8th Cir. 8014A(c) | CM/ECF service; paper copy to a non-participant with a certificate stating date, method and address | `certificate-of-service`, shown when `service.unregistered` is given or `service.certificate` is true |
| FRBP 8014(d) | Statutes set out in the brief or in an addendum | no addendum section; a `# Addendum` heading is refused |

## Gate 2: page review

Reviewed 2026-10-21 (fb-595.65), after the line-pitch fix. Every page of both renders, `usage/OUTPUT-opening-brief.typst.pdf` and `usage/OUTPUT-opening-brief.docx.pdf`, was rasterized at 50 dpi (`pdftoppm -r 50`) and viewed; page 19 was viewed again at 60 dpi after the typeface fix. Typst printed no warnings. Fonts embedded, both engines: Times New Roman (regular, bold, italic) only. Both renders have 20 pages. Page numbers are PDF pages; the printed number follows in parentheses (body page 1 is the Jurisdictional Statement).

| Page | Content | typst | docx |
|---|---|---|---|
| 1 | Cover: BAP No., court, caption, proceeding, title, counsel. Unnumbered. | OK | OK. The rule under the court name is a single line where typst draws a double one (tier 3). |
| 2 | Certification of Interested Parties (i) | OK | OK |
| 3 | Certification of Related Cases (ii) | OK | OK |
| 4 | Table of Contents (iii) | OK. Pages 1, 1, 2, 2, 5, 7, 7, 8, 11. | OK. Same pages. |
| 5 | Table of Authorities, cases (iv) | OK | OK. Case pages differ from typst where body pagination differs (p. 14 to 17 below). |
| 6 | Table of Authorities, statutes and rules (v) | OK | OK. § 1322(b)(2) is on 7 pages here, so *passim* (typst: 5 pages, listed). |
| 7 | Jurisdictional Statement; Statement of Issues (1) | OK. Double-spaced, 32.2 pt pitch. | OK. 32.2 pt pitch. |
| 8 | Standard of Review; Statement of the Case (2) | OK | OK |
| 9 | Statement of the Case (3) | OK | OK |
| 10 | Statement of the Case (4) | OK | OK |
| 11 | Summary of Argument (5) | OK | OK |
| 12 | Summary of Argument (6) | OK | OK |
| 13 | Argument; point heading I; footnote 1 (7) | OK. Footnote single-spaced, 14 pt. | OK |
| 14 | Argument I end; point heading II (8) | OK | OK. Point heading II in small caps. From here to p. 17 the docx page breaks fall a few lines away from the typst ones (heading spacing differs, tier 3). |
| 15 | Argument II (9) | OK | OK |
| 16 | Argument II (10) | OK | OK |
| 17 | Argument II end; Nobelman block quote; Conclusion (11) | OK. Block quote single-spaced and indented. | OK. Same; the page opens a few lines earlier in the text than typst. |
| 18 | Conclusion end; signature block (12) | OK. Last paragraph kept with the signature. | OK |
| 19 | Certificate of Compliance (13) | OK. "14-point Times New Roman" (the INPUT said EB Garamond before this run). 2,642 words. | OK. Same wording; `[X]` text boxes; 2,643 words. |
| 20 | Certificate of Service (14) | OK | OK |

Pages reviewed: 20 of 20 (typst) and 20 of 20 (docx). OPEN: none. ACCEPTED (tier 3): the docx single cover rule; the docx/typst page breaks inside the Argument, which move the authorities' page numbers on pp. 5-6 of the docx.

## Overlay

Run: `sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/opening-brief fisette-11-6012`. Exit 0; writes `OVERLAY-fisette-11-6012.pdf` (19 pages) and `.txt`.

Page map (sample page to exemplar page, by shared words):
- Body pages 7 to 9 of the render pair with filed pages 7 to 9 at 65-95% word overlap; body pages 10 to 16 pair at 46-84%.
- Cover and front matter pair at 16-60%; the contents page (ours p.4) pairs with filed p.3 at 44%. These pairings are word-set guesses, not matched pages. Ours p.3 (related-cases certification) pairs with filed p.27 at 27%, which is not a real correspondence.
- Conclusion and certificates (ours p.17-19) pair with filed pp. 27-30 at 16-53%, which do not correspond to each other.

What the overlay shows: our text and the filing's text share words and paragraphs, but the lines do not line up. The filing is Times New Roman, not embedded, with its own leading and margins; our template was EB Garamond at 14 pt when this overlay was made (2026-10-14); it is now Times New Roman at a 32.2 pt pitch, and the overlay was not rerun. This is the tier-3 mismatch (matching one filer's style), which is not chased. The overlay is a diagnostic only.

## Known gaps

- **Partial transcription.** Filing pages 7-15 and 26-27 are transcribed (11 pages of body, which is the render's pages 7-17). Filing page 15 after the block quote through page 25 is omitted and marked in the file. The render is 19 pages in all: the cover, the interested-parties and related-cases certifications, contents, two pages of authorities, 11 body pages, and the certificate of compliance and certificate of service.
- **Certificate of compliance.** The template computes the word count from the markdown it receives, so the certificate says 2,644 words for the transcribed body. The filing's certificate says 6,491 words for the whole brief. The filing's certificate is not reproduced.
- **Certificate of service wording.** Template wording ("I hereby certify ...by using the CM/ECF system") follows L.R. BAP 8014A(c) and does not copy the filing's wording. The recipients are the filing's.
- **Email.** The filing has no counsel email. The template requires an `email` field; the render says "Not stated in the filed brief" instead of inventing one.
- **Typeface.** The filing is Times New Roman (not embedded; `pdffonts` lists TimesNewRomanPS). The render uses the vendored Times New Roman (fb-595.57); the INPUT's `typeface` field says so (fb-595.65).
- **Word-limit check.** The 13,000-word check runs on the transcribed body, not the full brief.
- **Jurisdiction content** (8014(a)(4)(A)-(D)) is not checked beyond the heading.
- **Standard-of-review and oral-argument checks are heuristics.** The first passes if the body says "standard of review" or a heading contains "standard"; the second matches a heading containing "oral argument". This brief has no oral-argument statement.
- **Cover color:** none. FRBP 8015 has no cover-color rule (2014 Committee Note).
- **Page limit:** only the type-volume (word) limit is enforced; the 30-page limit of 8015(a)(7)(A) is not counted.
- **Form 417C wording** is not verified.
- **Certifications placement:** before the TOC, by choice (see the rules table).
- **Disclosure statement:** rendered only when `disclosure` is given. The filing has no disclosure statement, so none is given.
- **Trustee's brief and the reply** in this case were not found (Justia is blocked from this box). See `../answering-brief/usage/SOURCE.md` and `../reply-brief/usage/SOURCE.md`.

## Engines

**docx** (`docx/`: `reference.docx`, `build-reference.sh`, `front.jq`, `brief.lua`, `render.sh`). `usage/OUTPUT-opening-brief.docx` and `.docx.pdf` (LibreOffice). 20 pages, as typst (fb-595.65). `pdffonts` on the PDF: only Times New Roman (Regular, Bold, Italic) embedded; `docx/build-reference.sh` names Times New Roman, as the typst template does since fb-9fyu (fb-595.57; it named EB Garamond before, so LibreOffice embedded EB Garamond and DEF-FONT-002 failed).

- Matches typst: Times New Roman 14 pt throughout (headings, footnotes, cover, contents, authorities); US Letter, 1 in margins; double spacing at 32.2 pt exact (`w:line="644"`, the typst `line-pitch`; measured 32.20 pt in both PDFs); 0.5 in first-line indent; single-spaced 14 pt footnotes and block quotations; section headings bold and centered; point headings bold small caps with roman labels; sub-heading labels hang at the typst positions; cover with the same parts in the same order; page numbers lower-roman on the front matter and arabic from body page 1, none on the cover; contents and authorities with dot leaders; the last body paragraph kept with the signature block.
- Differs: the checkbox in the certificate of compliance is the text `[X]`, not a drawn box. Contents and authorities are text written at build time, not Word TOC/TA fields, so they do not update in Word; their page numbers are measured on the LibreOffice PDF. Headings are paragraph styles with outline levels, not Heading styles. The word count in the certificate comes from pandoc's plain text: 2,643 here, typst counts 2,642. Body page breaks inside the Argument fall a few lines apart from typst (heading spacing differs), so some authorities' page numbers differ (Gate 2, pp. 5-6).
- BLOCKED: none for this engine. `tools/check.sh --engine docx` passes, BAP8-FORM-003 included (fb-595.65, 2026-10-21); all 20 pages of the `.docx.pdf` were viewed (Gate 2).

**latex**: none. This doc type has no `latex/` folder, so `tools/check.sh --engine latex` has nothing to render (it fails DEF-RENDER-001 for that reason). Not built in fb-595.65.
