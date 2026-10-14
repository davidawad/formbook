# D.C. Circuit: appellant's opening brief (typst)

Status: exemplar found, template built and rendered, sample reviewed page by page. Open items are listed under "Known gaps"; the typeface and the line pitch need David's decision.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-centro-v-bessent-25-5181-opening-brief.pdf` | Filed appellants' principal brief, No. 25-5181 (June 27, 2025). Provenance in `exemplars/SOURCE.md`. |
| `samples/INPUT-centro-opening-brief.md` | Transcription of the exemplar: frontmatter with its cover, certificate, glossary, authorities and signature, and a portion of the body (introduction through the start of argument, then conclusion). |
| `samples/OUTPUT-centro-opening-brief.pdf` | Render of the sample. 14 pages. |
| `samples/OVERLAY-centro-opening-brief.pdf`, `-overlay.txt` | Red/blue overlay of the render on the exemplar, and the page map. |
| `typst/cadc-opening-brief.typ` | The template: `dc-brief(meta, body)`. Content-agnostic; every number is a named parameter at the top. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |

Build (from the repo root; the vendored fonts only):

```sh
sh tools/render.sh courts/dc-circuit/court-of-appeals/opening-brief samples/INPUT-centro-opening-brief.md
sh tools/overlay.sh courts/dc-circuit/court-of-appeals/opening-brief centro-opening-brief
```

## Governing rules

Verified 2026-10-14 against the D.C. Circuit's own rules PDF, "Circuit Rules Effective January 1, 1994, As Amended Through December 4, 2025" (which also contains the FRAP text): https://www.cadc.uscourts.gov/sites/cadc/files/rules-RulesFRAP20251204.pdf

| ID | Requirement | Source | Where in the template |
|---|---|---|---|
| DC-FRAP-032-A2 | Cover: case number centered at top; court name; title of case; nature of proceeding and court below; brief title identifying the party; counsel name, office address and telephone | FRAP 32(a)(2)(A)–(F) | `cover()` |
| DC-CR-028-A8 | The words "ORAL ARGUMENT NOT YET SCHEDULED" (or the argued/submitted statement) in capital letters at the top of the front cover | Circuit Rule 28(a)(8) | `cover()`, from `oral_argument` |
| DC-FRAP-032-A4 | 8½ × 11 paper; double-spaced; quotations over two lines and headings and footnotes may be single-spaced; margins at least one inch on all sides | FRAP 32(a)(4) | `page-margin`, `body-leading`, `single-leading` |
| DC-FRAP-032-A5 | Proportionally spaced serif face, 14-point or larger; sans-serif allowed in headings and captions | FRAP 32(a)(5)(A) | `font-family`, `type-size` |
| DC-HB-IX-A6 | Handbook, Format: encourages Century and Times New Roman; discourages Garamond; 14-point serif | D.C. Circuit Handbook IX.A.6, as revised 16 March 2021 (Clerk's notice "Preferred Typefaces for Briefs"): https://www.cadc.uscourts.gov/sites/cadc/files/noticeGen-noticePreferredTypefacesForBriefs.pdf | see Known gaps, item 1 |
| DC-FRAP-032-A6 | Plain roman type; case names italicized | FRAP 32(a)(6) | markdown `*...*` |
| DC-FRAP-028.1-E2 / 032-A7 | Appellant's principal brief: no more than 13,000 words (or 1,300 monospaced lines); the template refuses to build over the limit | FRAP 28.1(e)(2)(A)(i), 32(a)(7)(B)(i); Circuit Rule 32(e) | `word-limit`; `dc-brief()` panics |
| DC-CR-028-A1 | Certificate as to Parties, Rulings, and Related Cases, immediately inside the cover and before the table of contents, with paragraphs A (parties and amici), B (rulings under review), C (related cases), and the Rule 26.1 disclosure | Circuit Rule 28(a)(1)(A)–(C); FRAP 26.1; Circuit Rule 26.1 | front matter, from `certificate` |
| DC-FRAP-028-A2 | Table of contents with page references | FRAP 28(a)(2) | `outline()` |
| DC-CR-028-A2 | Table of authorities: every page on which each authority is cited is listed; "passim" or similar may not be used; asterisks optional | Circuit Rule 28(a)(2) | `toa()`; the template has no "passim" path |
| DC-CR-028-A3 | Glossary of every abbreviation, on a page immediately after the table of authorities | Circuit Rule 28(a)(3) | `glossary` (optional, from metadata) |
| DC-FRAP-028-A4 | Jurisdictional statement (district and court of appeals jurisdiction, timeliness dates, finality) | FRAP 28(a)(4)(A)–(D) | author content in the body; not checked by the template |
| DC-FRAP-028-A5–A9 | Issues presented, statement of the case, summary of argument, standard of review, argument, conclusion | FRAP 28(a)(5)–(9); Circuit Rule 28(a)(6) | body headings |
| DC-CR-028-A5 | Statutes and regulations set out in the body or in an addendum; an addendum over 40 pages is bound separately; a colored separation page applies when bound with the brief | Circuit Rule 28(a)(5) | `# Addendum` renders after the certificates; the colored separator is paper-only (Known gaps, item 7) |
| DC-FRAP-032-G1 | Certificate of compliance stating the word count, and the typeface and type-style statement | FRAP 32(g)(1)–(2) (Form 6) | certificate of compliance, word count computed from the body |
| DC-FRAP-025-D | Certificate of service | FRAP 25(d) | certificate of service |
| DC-CR-032-B1 | Electronic filings are PDFs generated from a word-processing file and are text-searchable | Circuit Rule 32(b)(1) | the PDF is text-searchable (`pdftotext` yields the body) |

Notes on the rules: the D.C. Circuit's cover rule is Circuit Rule 28(a)(8), not Circuit Rule 32(b)(1), which governs electronic filing. Circuit Rule 32(e) governs form only by reference to FRAP 28.1 and 32(a).

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block (metadata) followed by the body. The template generates the cover, the certificates, the tables, the signature block and the glossary page.

### Frontmatter

| Field | Required | Type | Feeds |
|---|---|---|---|
| `case_number` | yes | string | Cover "No. ..." and the PDF title |
| `oral_argument` | yes | string | Cover statement, capitals, at the top (Circuit Rule 28(a)(8)) |
| `caption` | yes | list of two sides | Cover. Each side: `names` (one centered line each; inline markdown allowed) and `designation` (e.g. `Plaintiffs-Appellants,`). "v." is inserted between the sides. |
| `proceeding` | yes | string | Cover, "On Appeal from ..." |
| `district_court_case`, `judge` | no | string | Cover lines, shown when given |
| `brief_title` | yes | string | Cover title (printed in capitals) |
| `counsel` | yes | list of groups | Cover counsel block. Each group: `names` and `lines` (phone number included in `lines`). Groups are set side by side. |
| `date` | yes | string | Under the cover counsel; the signature block; the certificate of service |
| `word_processor` | yes | string | Certificate of compliance: "using ..." |
| `certificate` | yes | map | `parties`, `rulings`, `related`, `disclosure`: each markdown text, paragraphs separated by a blank line |
| `signature` | yes | map | `signer` (printed as `/s/ Name`, then the name) and `lines` (italic lines under it) |
| `glossary` | no | list of `{abbr, meaning}` | Glossary page after the table of authorities |
| `authorities` | yes if the body cites any | map | Table of authorities registry: `kind` (`case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `name` (optional; italic for cases), `cite` (required), `sort` (optional) |

### Body

- `# HEADING` (level 1) is a centered bold section. Write the headings in capitals as the brief prints them.
- `## heading` (level 2) and `### heading` (level 3) are bold, left-aligned. Write the labels yourself (`I.`, `A.`, `1.`); the template does not number headings.
- Citations: link to a registry key, with the full citation as the text: `[*Arizona v. United States*, 567 U.S. 387, 407 (2012)](toa:arizona)`. A short form (`*Id.* § 6651`) links to the same key. Every link records the page on which it starts. A key not in `authorities:` stops the build.
- A line that starts with a number and a period is a list to a markdown parser. Escape it: `1\. Individuals ...`.
- `> quoted text` is a block quotation (single-spaced, indented).
- `# Addendum` ends the brief: everything below it renders after the certificate of service and is excluded from the word count.
- Not supported: tables, images, raw typst.

## Overlay

`sh tools/overlay.sh` puts the sample page (red) over the matched exemplar page (blue); black is where both agree. Pages are paired by word overlap, so the sample's pages land on the exemplar's pages they came from. Word overlap by page: 92.5% on the cover (p.1); 26% on the table of authorities (p.5; the sample lists far fewer authorities than the exemplar); 39–78% on the other pages. The overlay is a diagnostic, not a score; it is recorded here so the pages are not reviewed in isolation.

Page map (`samples/OVERLAY-centro-opening-brief.txt`): sample p.1 → exemplar p.1; p.2 → p.2; p.3 → p.4; p.4 → p.5; p.5 → p.8; p.6 → p.15; p.7 → p.16; p.8 → p.18; p.9 → p.20; p.10 → p.41; p.11 → p.45; p.12 → p.70; p.13 → p.71; p.14 → p.72.

## Review record (Gate 2)

Every page of `samples/OUTPUT-centro-opening-brief.pdf` (14 pages) was rendered at 60 dpi and viewed. The pages were checked against the exemplar's layout and the rules above.

| Page | Content | Finding |
|---|---|---|
| 1 | Cover | Fits one page. Oral-argument line, case number, court, caption, proceeding, title, three counsel groups, date. OK. |
| 2 | Rule 28(a)(1) certificate, parties, rulings | Heading two lines, single-spaced. OK. |
| 3 | Certificate cont. (related cases, Rule 26.1) | OK. |
| 4 | Table of contents | Page numbers match the layout. OK. |
| 5 | Table of authorities | Every citation page listed, no "passim". OK. |
| 6 | Glossary | OK. |
| 7 | Introduction, p. 1 | Double-spaced, first-line indent. OK. |
| 8 | Introduction cont., Jurisdiction | OK. |
| 9 | Question presented, statement of the case, summary | OK. |
| 10 | Summary, standard of review | OK. |
| 11 | Argument (heading and first paragraph), conclusion | OK. |
| 12 | Signature block, alone on its page | OPEN: the block did not fit under the conclusion and moved to the next page. Layout only. |
| 13 | Certificate of compliance | Word count and typeface sentence present. OK. |
| 14 | Certificate of service | OK. |

Defects found during review and fixed in the template: the bold lead-ins of the certificate ran into their paragraphs; paragraph spacing overlapped at every paragraph break; single-spaced two-line headings overlapped; the body lost its first-line indent (a `set par` in the certificate section leaked into the body; the body now resets its own paragraph style).

## Known gaps

1. **Typeface.** The only vendored serif is EB Garamond (`fonts/eb-garamond/`). The Handbook (IX.A.6) discourages Garamond; it does not forbid it, and EB Garamond at 14 pt satisfies FRAP 32(a)(5)(A). The D.C. Circuit prefers Century or Times New Roman. Neither is vendored, and `fonts/` is outside this box's scope. To switch: vendor a Century Schoolbook-metric or Times-metric font under `fonts/`, then change `font-family` in `typst/cadc-opening-brief.typ`. **Decision for David.**
2. **Line pitch.** `body-leading` is 1.07em, giving a baseline pitch of about 24 pt at 14 pt. That is the pitch of the filed exemplar's body text. FRAP 32(a)(4) says "double-spaced" without a number; a pitch of about 2× the nominal 14 pt line (≈28 pt) would be larger and would push the sample past 14 pages. **Decision for David.**
3. **Word count.** The certificate's count (1,312) is the template's count of the sample's body, which is a portion of the brief. The exemplar's own certificate states 10,418 words for the whole brief. The 13,000-word limit is enforced at build time for any sample.
4. **Sample is a portion.** It is the exemplar's introduction through the start of the argument, then the conclusion, signature and certificates. The argument body and the statutory addendum are not transcribed. The summary's point I is transcribed only as far as the text read.
5. **Signature alone on a page** (page 12 above). The conclusion and the signature block split across pages.
6. **Cover color.** FRAP 32(a)(2) makes the appellant's cover blue. This applies to paper copies; the PDF is not colored.
7. **Addendum separator.** Circuit Rule 28(a)(5) requires a distinctly colored separation page when the addendum is bound with the brief. Paper only; not produced. The sample has no addendum.
8. **Headings are not numbered by the template.** The labels are typed in the markdown.
9. **Glossary completeness** (Circuit Rule 28(a)(3)) is the author's job; the template renders what is given.
10. **Jurisdictional statement** (FRAP 28(a)(4)(C)–(D): timeliness dates, finality) is author content. The template does not check it.
11. **Signature block** lists one signer. The exemplar lists three counsel in the signature; the template takes one `signer` per block.
12. **Authorities.** The sample's registry has 12 entries; the sample cites no authority it does not list. Short-form citations link to the registry key of the full citation.

## Not verified

- The Clerk's Handbook and "Brief Compliance Checklist" were not read in their current versions. The checklist URL returned 404 when fetched. The typeface rule is taken from the 16 March 2021 notice, which quotes the Handbook section.
- The exemplar's page structure (sections, TOC page numbers) was read from its text layer, not from a rendering. The TOC numbers in the sample are the template's, not the filing's.

## Search record

- CourtListener search for D.C. Circuit appellant briefs: https://www.courtlistener.com/api/rest/v4/search/ (queries "Brief for Appellant", "Oral Argument Not Yet Scheduled"). Returned mostly orders; the usable hits were the Centro (No. 25-5181) and Kelly (No. 26-5070) briefs, both on public sites.
- Web searches for the Circuit Rule 32 text returned other circuits' rules; the D.C. Circuit text came from the rules PDF above.
