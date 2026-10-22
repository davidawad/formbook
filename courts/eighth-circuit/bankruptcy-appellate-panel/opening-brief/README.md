# Eighth Circuit BAP (bap8): opening brief (appellant's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `usage/` are untouched.
- Doc type: `opening-brief`. Appellant's brief, FRBP 8014(a).
- **Exemplar: yes.** `usage/FILED-EXAMPLE-opening-brief.pdf`: Brief of Appellant, Michael James Fisette, BAP No. 11-6012, filed 2011-04-07 (68 pages, text-based, public). Source, URL, filer and fetch date in `usage/SOURCE.md`.
- **Sample: transcription.** `usage/INPUT-opening-brief.md` transcribes the filing's cover, party list, body from the Jurisdictional Statement (filing p. 7) through the Nobelman block quote (p. 15), the conclusion (pp. 26-27), the signature and the service certificate. Filing page 15 after the block quote through page 25 (rest of Argument II, Arguments III-VII) is omitted; the omission is marked in the file.
- Render: ok, `usage/OUTPUT-opening-brief.typst.pdf`, 20 pages, typst with no warnings (2026-10-22, fb-595.54.4: shared cross-engine layout model; 32.2 pt body line pitch).
- Overlay: ok, `usage/OVERLAY-fisette-11-6012.pdf` and `.txt` (19 pages, 2026-10-14). Diagnostic only, see below.
- Pages reviewed: 19 of 19 as PNG at 60 dpi (2026-10-14). Pages 3, 4, 11, 12 and 14 were re-viewed after the heading-numeral fix; the rest were viewed in the render before it, and the fix did not change pagination.
- Status: `court.json` untouched; `status` not set. No `tracker.sh`, no `STATUS.md`.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `bap8-brief`. |
| `typst/bap8-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(a)(4)-(9) order), `needs-standard-of-review`. |
| `eval.yaml` | Check settings for `tools/check.sh`: 14 pt body size and BAP8-FORM-003 (body baseline pitch >= 28 pt, FRBP 8015(a)(4)), added to the default checks; Gate 4 XENG-001..003 repeated and gated (`params.cross_engine: gate`). |
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
| FRBP 8015(a)(4) | 8.5 x 11; double spaced; long quotations may be single spaced; headings and footnotes single spaced; margins at least 1 inch | `page`, `line-pitch` (32.2 pt line boxes, lib/typst/xengine.typ), `pitch-single` (16.1 pt) for quotes, footnotes and headings; checked by BAP8-FORM-003 in `eval.yaml` |
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

Reviewed 2026-10-22 (fb-595.54.4), after the port to the shared cross-engine layout model (typst is the reference, so every typst page was looked at again). Every page of both renders, `usage/OUTPUT-opening-brief.typst.pdf` and `usage/OUTPUT-opening-brief.docx.pdf`, was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed side by side. Typst printed no warnings. Fonts embedded, both engines: Times New Roman (regular, bold, italic) only. Both renders have 20 pages and break every line and page alike (Gate 4 XENG-001..003 PASS). Page numbers are PDF pages; the printed number follows in parentheses (body page 1 is the Jurisdictional Statement).

| Page | Content | typst | docx |
|---|---|---|---|
| 1 | Cover: BAP No., court, caption, proceeding, title, counsel. Unnumbered. | OK. Single-spaced in 16.1 pt line boxes; counsel lines 0.5 em in, italic. | OK. Same lines; the gaps between the parts are fixed paragraphs, so the parts sit up to 26 pt higher (tier 3). |
| 2 | Certification of Interested Parties (i) | OK. 14 pt between the paragraphs and above the party list; bullets in a quarter-inch box. | OK. Same breaks. |
| 3 | Certification of Related Cases (ii) | OK | OK |
| 4 | Table of Contents (iii) | OK. Pages 1, 1, 2, 2, 5, 7, 7, 8, 11; numbers in a 36 pt column, leaders from three spaces after the text. | OK. Same pages; the leader runs on to the number (Word's right tab). |
| 5 | Table of Authorities, cases (iv) | OK. Page lists in a 56 pt column. | OK. Same page numbers (citations found by their link text and the words after it). |
| 6 | Table of Authorities, statutes and rules (v) | OK. § 1322(b)(2) on 5 pages, listed; a list wider than 56 pt widens its own row's column. | OK. Same. |
| 7 | Jurisdictional Statement; Statement of Issues (1) | OK. Double-spaced, 32.2 pt pitch; section headings 16 pt in 18.4 pt boxes. | OK |
| 8 | Standard of Review; Statement of the Case (2) | OK | OK |
| 9 | Statement of the Case (3) | OK | OK |
| 10 | Statement of the Case (4) | OK | OK |
| 11 | Summary of Argument (5) | OK | OK |
| 12 | Summary of Argument (6) | OK | OK |
| 13 | Argument; point heading I; footnote 1 (7) | OK. Point heading bold (no small capitals: Word and typst synthesize them differently). Footnote single-spaced, 14 pt. | OK |
| 14 | Argument I end; point heading II (8) | OK | OK |
| 15 | Argument II (9) | OK | OK |
| 16 | Argument II (10) | OK | OK |
| 17 | Argument II end; Nobelman block quote; Conclusion (11) | OK. Block quote single-spaced and indented both sides. | OK |
| 18 | Conclusion end; signature block (12) | OK. Last paragraph kept with the signature; the block starts mid-line (3.25 in; it started 42 pt further left before). | OK |
| 19 | Certificate of Compliance (13) | OK. 2,642 words; check boxes a ruled box around an X, the text hanging after it. | OK. Same count (render.sh counts as typst does; it counted 2,643 before). |
| 20 | Certificate of Service (14) | OK | OK |

Pages reviewed: 20 of 20 (typst) and 20 of 20 (docx). OPEN: none. ACCEPTED (tier 3): the cover's vertical gaps differ between the engines (its lines break alike).

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

**docx** (`docx/`: `reference.xml` (fb render builds `reference.docx` from it, `tools/fb/src/docxref.rs`), `front.jq`, `brief.lua`, `render.sh`). `usage/OUTPUT-opening-brief.docx` and `.docx.pdf` (LibreOffice). 20 pages, as typst. `pdffonts` on the PDF: only Times New Roman (Regular, Bold, Italic) embedded; `docx/reference.xml` names Times New Roman, as the typst template does since fb-9fyu (fb-595.57; it named EB Garamond before, so LibreOffice embedded EB Garamond and DEF-FONT-002 failed).

- Cross-engine layout model (fb-595.54.4; docs/EVAL-LOOP.md, "Cross-engine gate"): `typst/` applies `lib/typst/xengine.typ` (first fit, no kerning, ligatures or hyphenation, exact line boxes: body 32.2 pt, single 16.1 pt, section headings 18.4 pt; spaces between blocks in pt), `docx/reference.xml` holds the styles of `lib/docx/xengine-reference.sh` with the same pitches and spaces in twips, and `docx/brief.lua` writes every run through `lib/docx/xengine.lua` (a no-break hyphen before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number, a word joiner inside "8015(a)(7)(B)"). Gate 4 is gated (`params.cross_engine: gate` in `eval.yaml`): XENG-001..003 PASS, 368 of 368 lines alike.
- Matches typst: Times New Roman 14 pt throughout; US Letter, 1 in margins; 0.5 in first-line indent; single-spaced 14 pt footnotes and block quotations; section headings bold capitals, centered; point headings bold with roman labels; sub-heading labels hang at the typst positions; contents and authorities with the page number in its own column; the certificate's check boxes a ruled box around an X; the word count (render.sh applies the typst count-words rules); the last body paragraph kept with the signature block.
- Differs: contents and authorities are text written at build time, not Word TOC/TA fields, so they do not update in Word; their page numbers are measured on the LibreOffice PDF (headings by their text, citations by their link text and the words after it). Headings are paragraph styles with outline levels, not Heading styles. Dot leaders run to the number (typst stops them at the page column). The cover's gaps are fixed paragraphs, not typst's fitted spacing.
- BLOCKED: none for this engine. `tools/check.sh --engine docx` passes, BAP8-FORM-003 and XENG-001..003 included (2026-10-22).

**latex**: none. This doc type has no `latex/` folder.

`docx/render.sh` (2026-10-22, fb-595.54.4): bash strict mode (`set -euo pipefail`), checked `mktemp` with every scratch folder inside it and the whole removed through `safe_rmdir`, shellcheck clean; its branch count is in `.shell-safety-baseline.json`. The `.docx.pdf` re-renders byte-identical.
