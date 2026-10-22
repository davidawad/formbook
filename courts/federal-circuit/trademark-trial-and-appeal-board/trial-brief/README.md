# TTAB: brief on the case at final hearing (typst + docx)

Doc type `trial-brief` under the Trademark Trial and Appeal Board (court `ttab`). Self-contained: exemplar, sample, template and this README live in this folder. The court root's `typst/` and `usage/` are not touched. The template covers the main brief, the reply brief and the rebuttal brief; the page limit differs by stage (see the rule table).

## Status

| Item | State |
|---|---|
| Exemplar | yes, one filer: TreeFrog Development (Opposer's rebuttal brief, 2018). Redacted public version. See `usage/SOURCE.md`. Only one trial brief was found; tier 2 (two or three filers) is not met |
| Sample | `usage/INPUT-trial-brief.md`: caption, authorities registry, introduction, section II in full, the start of section III with its statutory block quotation, sections IV and V, conclusion, signature block, certificate of service. Images, sections III(B)-(F) and the rest of the body are not transcribed |
| Render (typst) | ok: `sh tools/render.sh courts/federal-circuit/trademark-trial-and-appeal-board/trial-brief usage/INPUT-trial-brief.md` writes `usage/OUTPUT-trial-brief.typst.pdf`, 9 pages (caption i, table of authorities ii, body 1-7), no typst warnings, Times New Roman (or the vendored Liberation Serif with the same metrics) |
| Overlay | ok: `sh tools/overlay.sh <dir> treefrog-rebuttal-brief <dir>/usage/FILED-EXAMPLE-trial-brief.pdf` writes `usage/OVERLAY-treefrog-rebuttal-brief.pdf` and `.txt` |
| Pages reviewed | 9 of 9 of each engine (typst and docx, after the cross-engine port; see "Page review") |
| Check gates (`tools/check.sh`) | typst and docx: 0 failed (`data/checks-default.yaml` with `eval.yaml`) |
| Cross-engine (Gate 4) | gated (`eval.yaml` `params.cross_engine: gate`): the docx breaks every line and page as typst does (XENG-001..003 PASS), on the shared layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`, `lib/docx/xengine-reference.sh`; fb-595.54.6) |

File names: as for the notice of opposition, the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`.

## Governing rules

Verified 2026-10-14. Primary text: 37 C.F.R. Part 2 from the Cornell LII mirror (https://www.law.cornell.edu/cfr/text/37/...), and TBMP June 2025 (chapter 800, section 801.03; the TBMP PDF was read from the USPTO download, sections 309 and 801 quoted in the text).

| ID | Kind | Rule | Source | What the template does |
|---|---|---|---|---|
| TTAB-TB-FORM-001 | court-mandated (tier 1) | Text in an electronic submission: at least 11-point type, double-spaced. | 37 C.F.R. § 2.126(a)(1) (https://www.law.cornell.edu/cfr/text/37/2.126); TBMP § 801.03 (June 2025) repeats it | 12-point Times New Roman; footnotes 12 pt, single-spaced |
| TTAB-TB-FORM-002 | court-mandated (tier 1) | Double-spaced text. Block quotations and footnotes are single-spaced: the Board's text says "[e]xtensive single-spaced footnotes may not be used as a subterfuge to avoid the page limit" (TBMP § 801.03), so single-spaced footnotes are the Board's own usage. Block quotations are not addressed by any rule; single spacing is the convention and is flagged here as an interpretation | TBMP § 801.03 | 24 pt pitch in the body (exact line boxes, see "Measurements"); single spacing for block quotations, footnotes, caption, signature, authorities |
| TTAB-TB-FORM-003 | convention (tier 2) | 1 in. margins; US Letter; centered page number. | 37 C.F.R. § 2.126(b)(2) fixes the paper size for paper filings only | US Letter, 1 in. margins, roman numerals on the caption and the authorities, arabic from 1 at the body (as the exemplar) |
| TTAB-TB-PAGE-001 | court-mandated (tier 1) | A main brief on the case may not exceed 55 pages in its entirety, and a reply brief 25 pages in its entirety. The limit includes the table of contents, the index of cases, the description of the record, the statement of the issues, the recitation of facts, the argument and the summary. Exhibits and appendices are outside it. | 37 C.F.R. § 2.128(b); TBMP § 801.03. (A secondary source reports a 15-page reply limit; the primary text says 25 pages, and 25 is what is implemented in the review.) | Not enforced by the template. The sample's body is 7 pages, well inside both limits. The page count is the author's responsibility |
| TTAB-TB-INDEX-001 | court-mandated (tier 1) | Each brief shall contain an alphabetical index of cases cited. | 37 C.F.R. § 2.128(b) | The table of authorities has a "Cases" group sorted alphabetically (by `sort`, else by name with the italics removed). Statutes, regulations, rules and other authorities follow in their own groups. Interpretation: the index of cases and the table of authorities are one list here, as in the exemplar. A brief that wants a separate index of cases can split the group |
| TTAB-TB-SERVICE-001 | court-mandated (tier 1) | Every submission other than the notice of opposition must be served; proof of service must be made before the submission is considered; service is by email unless the parties stipulate otherwise; the certificate states the date and the manner of service. | 37 C.F.R. § 2.119(a), (b) (https://www.law.cornell.edu/cfr/text/37/2.119; amended 81 FR 69975, Oct. 7, 2016) | A certificate of service on its own page, with the date, "via email to:" and the recipients from `service`, signed "s/Name" |
| TTAB-TB-FILE-001 | court-mandated (tier 1) | Submissions are made through ESTTA; confidential portions require a public copy with the confidential portions redacted. | 37 C.F.R. § 2.126(a), (c) | The caption page prints the version line from `version` (e.g. "Redacted Version"); the template does not make or check the redaction |
| TTAB-TB-SIG-001 | court-mandated (tier 1) | Electronic signature for ESTTA filings. | 37 C.F.R. § 2.193(c) (cited by § 2.101(b)) | "s/Name" over the signer's name, with the party line "By its attorneys," |
| TTAB-TB-TIMING-001 | not formatting | Main brief due 60 days after the close of rebuttal testimony; defendant's brief 30 days later; plaintiff's reply 15 days after that. | 37 C.F.R. § 2.128(a)(1) | Not implemented: a date rule, not a layout rule |
| TTAB-TB-CONTENT-001 | convention (tier 2) | Caption and heading. The heading "IN THE UNITED STATES PATENT AND TRADEMARK OFFICE / BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD" and the proceeding number. | TBMP § 309.02(a) (for the complaint; a brief follows the same practice) | Heading, caption with the ")" column, proceeding numbers (`caption_right`), title, counsel block at the foot of the caption page |

Interpretations listed for review: (1) block quotations single-spaced (TTAB-TB-FORM-002); (2) one list for the index of cases and the table of authorities (TTAB-TB-INDEX-001); (3) no table of contents is generated: the exemplar has none, and TBMP 801.03 counts a table of contents toward the page limit only when one is present.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

| Field | Required | Feeds |
|---|---|---|
| `caption` | yes | list of `{names, designation}`; the "v." line is inserted between the two sides |
| `caption_right` | yes | list of strings printed to the right of the caption (proceeding, application, mark) |
| `brief_title` | yes | title, centered, bold, capitals (use the case's own wording) |
| `version` | no | a line under the title, e.g. "Redacted Version" |
| `date` | yes | the date under the caption and the date of the signature |
| `counsel` | yes | list of `{names, lines}` for the caption page (bottom right); `phone` is printed after the last group |
| `signature` | yes | `party` (e.g. "TREEFROG DEVELOPMENT, INC."), `signer` (printed as `s/Name`), `lines` (firm, address, telephone) |
| `service` | yes | `date` (the words "this ... day of ..."), `recipients` (one line each), `signer` |
| `authorities` | yes, if any citation | map key -> `{kind, name, cite, sort}`. `kind` is `case`, `constitution`, `statute`, `regulation`, `rule` or `other`. `name` is italic for cases (write the asterisks). `cite` is required |

Body: `# I. INTRODUCTION` is a centered bold section heading (write the numerals yourself; they are not generated). `## A. Priority ...` is a bold left subheading. Citations are links whose target is `toa:KEY` with the full citation as the text: `[*Ritchie v. Simpson*, 50 U.S.P.Q.2d 1023, 1025 (Fed. Cir. 1999)](toa:ritchie)`. A key that is not in `authorities` stops the build. Each link is recorded with the page on which it starts; the table of authorities lists the pages in the body's numbering (arabic from 1), and an authority cited on 7 or more pages prints "passim". Block quotations are `>` lines in one paragraph (a blank `>` line between paragraphs makes cmarker warn, which fails the render). Footnotes use `[^n]` and `[^n]: text` (cmarker).

## Measurements

- Line pitch (cross-engine layout model, `lib/typst/xengine.typ`; fb-595.54.6): every line is a box of its pitch with the baseline at 0.8 of it, the boxes touching, as Word's exact line spacing sets them. Body 24 pt (double spacing at 12 pt); single-spaced lines (caption, headings, block quotations, footnotes, authorities, signature) 13.8 pt. The spaces between blocks are explicit, in pt, the same in the docx (twips = 20 x pt).
- Paragraph spacing 0; first-line indent 0.5 in on every paragraph, including those after a heading (`first-line-indent: (amount, all: true)`).

## Overlay

`OVERLAY-treefrog-rebuttal-brief.pdf`: red is our render, blue is the filed exemplar, black is where both agree. Pairs by word overlap (`OVERLAY-treefrog-rebuttal-brief.txt`):

- ours p.1 (caption) -> filed p.1 (95%); p.3 (body 1) -> filed p.5 (99%); p.4 -> filed p.6 (82%); p.9 (certificate) -> filed p.26 (100%).
- ours p.2 (table of authorities) -> filed p.3 (26%). Expected: the filed table lists every authority of the 26-page brief; ours lists only the authorities of the transcription.
- ours p.5-p.8 -> filed p.11, p.23-p.25 (41-68%): these are the transcribed body pages; the filed pages that match them are in different places in the filed brief because our transcription omits the material in between.

The overlay is a diagnostic. Differences in the table of authorities page numbers (computed by the template from our body, not copied from the filed brief) and the exact line breaks are tier 3 and are not chased.

## Page review

Every page of `OUTPUT-trial-brief.typst.pdf` and `OUTPUT-trial-brief.docx.pdf` (9 pages each) was rendered and looked at after the cross-engine port (fb-595.54.6), side by side with the render before it.

| Page | Content | Finding |
|---|---|---|
| i | Caption page: heading, caption with ")" column, proceeding numbers at right (one every other row, centered on the caption), title, "Redacted Version", counsel block, date | OK |
| ii | TABLE OF AUTHORITIES: Cases (alphabetical, italic names, dot leaders, page numbers in a 56 pt column), Statutes | OK. Page numbers agree with the body: Cunningham p.2, Herbaceuticals p.5, the statute p.1, 3, 4; the heading is now 12 pt (was typst's default 16.8 pt) |
| 1 | I. INTRODUCTION, three paragraphs | OK. Double spacing now also between paragraphs (before the port the space between two paragraphs was a single line) |
| 2 | II. heading (three lines, centered, bold), section II paragraphs, footnote 1 | OK. The footnote is 12 pt, single-spaced, at the foot of the page |
| 3 | III. heading, the statutory block quotation (single-spaced, indented 0.5 in both sides), the Cook and H.D. Vest paragraphs | OK |
| 4 | A. subheading (hanging, bold), section A paragraph, IV. heading, the start of IV | OK |
| 5 | Rest of IV, V. heading, section V paragraph | OK |
| 6 | VI. CONCLUSION, its paragraph kept with the signature block: party line, "By its attorneys," "s/Heather J. Kliebenstein", firm lines | OK. Page 5 ends short: the conclusion is one paragraph, kept with the signature block |
| 7 | CERTIFICATE OF SERVICE on its own page: text, recipients, "s/Abigail Krueger" | OK |

Note: the rendered body has 7 pages (body 1-7 are PDF pages 3-9); the certificate starts a new page, as in the exemplar.

## Known gaps

- Tier 2 is not met: one filer's brief (a rebuttal brief, not an opening brief). The template's conventions (caption, table of authorities, signature, certificate) are checked against the exemplar only.
- No table of contents is generated. The exemplar has none; a main brief of 20+ pages normally has one.
- Body headings are typed (numerals and letters); the template does not number them.
- Footnotes are single-spaced at 12 pt; the sample has one footnote.
- The page limit is not enforced (TTAB-TB-PAGE-001).
- The sample omits the exemplar's images (the end-cap and CES photographs), and the sample is a portion of the body.

## Engines

The docx engine (`docx/`, see `docs/DOCX.md`) is built from `docx/make-reference.sh` (the `reference.docx`, from the shared recipe `lib/docx/xengine-reference.sh`: Times New Roman 12 pt, the body in 24 pt exact line boxes with a half-inch first-line indent, single-spaced 13.8 pt block quotations and footnotes), `docx/ttab-trial-brief.lua` (the caption page with the counsel block and date at the foot of the page, the table of authorities, the headings, the signature block kept with the last paragraph, the certificate of service; every paragraph with the typst pitch and spaces), and `docx/render.sh`, which runs the conversion twice or more: pandoc cannot know the pages of the authorities, so each pass converts to PDF with LibreOffice, `docx/toa-pages.sh` finds the body page of every citation, and the next pass lists them. Render: `sh tools/render.sh --engine docx <this-dir> usage/INPUT-trial-brief.md` writes `usage/OUTPUT-trial-brief.docx` and `.docx.pdf`.

Sections: the caption page and the table of authorities are roman (i, ii); the body is arabic from 1 and the certificate continues it.

| Item | docx vs typst |
|---|---|
| Lines and pages | Identical breaks: Gate 4 XENG-001..003 PASS, gated in `eval.yaml` |
| Table of authorities | The same rows and page numbers. Page numbers are text computed from the LibreOffice PDF, not Word TA/TOA fields, so they do not update in Word |
| Caption page | The counsel block is a frame anchored to the bottom margin (typst: `v(1fr)` above it) |

A row of the table of authorities keeps 4 pt more than the three spaces before its leader free on its last line (typst `toa-tab-room`): LibreOffice moves the last word to a new line otherwise (measured here: it needs 3.8 to 4.0 pt beyond the three no-break spaces before the leader tab).

## Searches

- Web search, several phrasings: "trial brief" / "opposer's trial brief" / "applicant's trial brief" with ttabvue and "Opposition No." (returned Board orders, extension notices, docket entries, and docketalarm pages; no brief directly).
- TTABVUE direct fetches: the Brink docket 91274910 OPP-1 to OPP-40 (only OPP-1, OPP-2 and OPP-4 were retrievable at the time; the host reset connections intermittently); the LooseLeaf docket 91301120 (judgment order, not a brief); TreeFrog 91232860 OPP-39 (the brief, found).
- BRF and TRL document codes were probed (`ttabvue-91274910-BRF-n`); for the four numbers probed (10, 20, 26, 30) they returned the same 8135-byte response, so no BRF entry was confirmed; the brief was found under the OPP code.
- Primary rule text: 37 C.F.R. §§ 2.101, 2.104, 2.119, 2.126, 2.128 (Cornell LII); TBMP June 2025 chapter 800 (section 801.03) and chapter 300 (section 309.02), read from the USPTO PDFs after the fetch tool could not decode them.
