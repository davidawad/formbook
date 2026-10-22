# Court of Appeals for the Sixth Circuit: answering brief (appellee's brief)

Folder: `courts/sixth-circuit/court-of-appeals/answering-brief/`. Status: **template and one sample; not a complete tier-1/tier-2 pass** (see Known gaps). This is a standalone doc-type folder; the court root's `typst/` and `usage/` are not touched.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief.pdf` | The filed exemplar: Brief of Defendants-Appellees Midland County and Gladwin County, 6th Cir. No. 23-1761, Doc. 40, filed 2024-01-31. 56 pp., text layer present. |
| `usage/SOURCE.md` | Where it came from, who filed it, and the errors seen in it. |
| `usage/INPUT-answering-brief.md` | Markdown transcription (a portion, see its header). Markdown contract below. |
| `usage/OUTPUT-answering-brief.typst.pdf` | Render of the sample: 14 pages. |
| `usage/OVERLAY-bruneau-answering-brief.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar (`tools/overlay.sh`). Page map below. |
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter, calls the template. |
| `typst/ca6-answering-brief.typ` | The template `ca6-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or cites a rule. |

Build (from the repo root; the same commands for any sample):

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/sixth-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md
sh tools/overlay.sh courts/sixth-circuit/court-of-appeals/answering-brief bruneau-answering-brief
```

**Typeface: no face named, so EB Garamond stays.** FRAP 32(a)(5)(A) and (a)(6) require a proportionally spaced serif at 14 pt and name no face. The Sixth Circuit Briefs Checklist ("Typefaces") says "a proportionally spaced font at 14 pt. (such as Times New Roman)"; "such as" is an example, not a requirement. So the template uses the vendored EB Garamond (`fonts/eb-garamond/`), as `docs/FONTS.md` provides for a court that names no face. No substitute is needed; the Times New Roman exemplar is a visual comparison only.

Fonts are EB Garamond only; `--ignore-system-fonts`; any typst warning fails the render. `pdffonts` on the sample shows only `EBGaramond-*` faces.

## Governing rules

Verified for this doc type on 2026-10-14. "Court" means the Sixth Circuit's own publication; "text" means the rule text as fetched.

| ID | Requirement | Source | Verified | Where it is in the template |
|---|---|---|---|---|
| CA6-COVER-001 | Cover: "United States Court of Appeals for the Sixth Circuit", case number, case title, nature of proceeding and court below, brief title identifying the party, counsel name/address/telephone | FRAP 32(a)(2); [Court's Briefs Checklist, Part I](https://www.ca6.uscourts.gov/sites/ca6/files/documents/rules_procedures/Briefs%20Checklist.pdf) | Checklist text; FRAP 32(a)(2) by the Checklist citation | `cover-body()` |
| CA6-COVER-002 | Oral argument: the cover says "ORAL ARGUMENT REQUESTED" only when the brief contains the statement | 6 Cir. R. 34(a); Checklist Part V | Checklist text (the 6 Cir. R. 34(a) text itself: not fetched) | `oral_argument` key; panics if the statement heading is missing |
| CA6-FORM-001 | Order of components: cover, corporate disclosure, TOC, TOA, oral-argument statement, jurisdiction, issues, case, summary, argument, conclusion, certificates, addendum | FRAP 28(a); Checklist Parts II-XIV | Checklist text; FRAP 28(a) by citation | Assembly order in `ca6-brief()` |
| CA6-FORM-002 | Margins at least one inch on all four sides; page numbers may sit in the margin, no text there | FRAP 32(a)(4) | Yes (LII, `rule_32`) | `page-margin = 1in` |
| CA6-FORM-003 | Text double-spaced; quotations over two lines and headings and footnotes may be single-spaced | FRAP 32(a)(4) | Yes (LII) | `body-leading`; `single-leading` |
| CA6-FORM-004 | Proportionally spaced serif face, 14-point or larger; case names italic | FRAP 32(a)(5)(A), (a)(6) | Yes (LII) | `type-size = 14pt`, `font-family` |
| CA6-LEN-001 | Principal brief: 13,000 words (30 pages); cross-appeal appellee brief 15,300 words; reply 6,500 words; cross-appeal appellee reply 6,500 words | FRAP 32(a)(7)(A), (B)(i)-(ii); FRAP 28.1(e)(2)(B)(i), (C); Checklist "Length of briefs" | Yes (LII, `rule_32` and `rule_28.1`; the 6,500 figure for the cross-appeal reply is half of 13,000 under 28.1(e)(2)(C)) | `word-limits`; panic when the body exceeds the basis |
| CA6-LEN-002 | Words excluded: cover, disclosure, TOC, TOA, addendum, certificates, signature block and other items listed in FRAP 32(f). The oral-argument statement is counted (Checklist, Part V: "included in the applicable page and/or word counts") | FRAP 32(f); Checklist Part V | FRAP 32(f) by citation; the Checklist's statement that the argument statement counts | `count-words(body-md)` counts everything before the addendum, so the generated parts are never counted |
| CA6-CERT-001 | Certificate of compliance: the attorney certifies the type-volume limit and states the word count | FRAP 32(g)(1) | Yes (LII) | `certificate-of-compliance()` |
| CA6-CERT-002 | Certificate of service, required when not served through CM/ECF alone; date served; parties; manner; signature | FRAP 25(d); Checklist Part XIII | Checklist text | `certificate-of-service()` (always generated; `service.date` required) |
| CA6-DISC-001 | Corporate disclosure statement (6 Cir. R. 26.1) filed with the brief, immediately before the TOC. Government entities and political subdivisions are exempt from the disclosure duty in 26.1(a); the exemplar's filer filed anyway | 6 Cir. R. 26.1 (text quoted in the exemplar's Form 6CA-1 attachment); FRAP 26.1 | The rule text is taken from the attachment to the exemplar, not from the court's site | `disclosure-page()`; reproduces the two answers of Form 6CA-1 only |
| CA6-SIG-001 | Filing attorney's signature "s/ Name" (6 Cir. R. 25(d)(1)) | Checklist Part II-XI | Checklist text | `signature-lines()` |
| CA6-CONT-012 | Heading numbering: Argument point headings I., II.; sub-headings A., B.; then 1., a. | Court's practice as shown in the exemplar; no rule text | Exemplar only | `heading-label()` |
| CA6-REC-001 | Record citations: "RE" or "R." with docket entry and Page ID range; the designation of record documents is an addendum | 6 Cir. R. 28(a)(1), 28(b)(1)(A)(i); Checklist "Citations to the Record" and XIV | Checklist text; 6 Cir. R. 28 by the Checklist citation | Addendum (`# Addendum`), numbered Add-1, ... |

Not generated, on purpose: a disclosure form that the clerk requires (only its two answers are reproduced; **Form 6CA-1 itself is what gets filed**); a statement of related cases (the Sixth Circuit has none in the Checklist); a colored cover (electronic filing does not need one).

## Markdown contract

Same contract as the ca9 `README.extra.md`, with these differences:

- Frontmatter `preliminary_sections: N`: the first N level-1 sections are numbered in roman with the front matter (in the exemplar these are the oral-argument statement, jurisdiction and issues; the counter-statement starts at page 1).
- Frontmatter `oral_argument: true`: the cover says "ORAL ARGUMENT REQUESTED". The template panics unless the body has a level-1 heading containing "oral argument".
- Frontmatter `disclosure: {party, subsidiary, financial_interest}`: the disclosure page. Omit for a government party.
- Frontmatter `caption` sides may carry `continues: true` to suppress the "v." before that side (the exemplar prints "v." once, between the plaintiffs and the defendants).
- Frontmatter `service: {date, unregistered}` is required.
- `word_limit_basis`: `standard`, `cross-appeal`, `reply`, or `cross-appeal-reply`.
- No `related_cases`, `limit`, `manual_image_words`, or Form 8 keys (Ninth Circuit only).
- Body, citations (`[text](toa:key)`), footnotes, block quotations, lists, escaping: as in the ca9 contract.

## Overlay (`usage/OVERLAY-bruneau-answering-brief.pdf`)

Red = our render, blue = the filed exemplar, black = both. The map (`-overlay.txt`) pairs each sample page with the exemplar page sharing the most words. The sample is a portion, and some paragraphs are condensed, so body pages overlap only partly (word overlap 22-56%); the cover, disclosure, TOC and certificate pages overlap more (cover 92%, conclusion 81%). Read the overlay for layout (margins, cover, TOC position, heading placement) and not for text identity.

## Page review (Gate 2, all 14 pages rendered at 60 dpi and read)

| Page (sample) | Filed page | What was checked | Finding |
|---|---|---|---|
| 1 cover | 1 | caption, title, oral-argument line, counsel block fit on one page | Fixed: counsel column was too narrow ("P.L.C." broke off); now 40% indent. OK. |
| 2 disclosure | 2-3 (form) | heading, two answers | OK. Form 6CA-1 is the real filing. |
| 3 TOC | 4 | page numbers vs. rendered pages (I. p.2, II. p.3, II.B p.4, III p.4, Conclusion p.6) | OK; numbers match the render. |
| 4-5 TOA | 5-7 | all 15 entries, pages, statutes/rules groups | OK. Two pages; the second has only the last 3 entries. |
| 6 prelim (iii-iv) | 6-8 | oral-argument statement, jurisdiction, issues | OK. Roman numbering continues from the TOA. |
| 7 counter-statement p.1 | 11 | double spacing, italics for case names, *Krieger, at \*2* | OK. |
| 8 p.2 | 12-13 | summary, I. heading, Rule 56 cites | OK. |
| 9 p.3 | 14-15 | II. and II.A. headings; point headings in small caps | OK. |
| 10 p.4 | 16-17 | II.B., III. headings; Id. short form | OK. |
| 11 p.5 | 18-19 | Pumpelly, Cress emphasis, Ridgeline | OK. Blank space at the foot: the Conclusion heading moved to the next page with its text (intended, keep-with-next). |
| 12 p.6 | 53 | conclusion; signature block kept with the last paragraph | OK. |
| 13 p.7 | 54 | certificate of compliance | Fixed: the word "14pt" printed in the monospace fallback font (typst prints length values as DejaVu Sans Mono). Now printed as "14-point". OK. |
| 14 p.8 | 54 | certificate of service | Fixed: its signature had split from the certificate onto its own page; the certificate is now one unbreakable block. OK. |

Pages reviewed: 14 of 14.

Word count: the certificate reports 1,146 words (the template's count of the sample body before the addendum, without the Statement in Support of Oral Argument, which FRAP 32(f) excludes; until 2026-10-16 that statement was counted and the certificate read 1,199). Far under 13,000. The certificate cites FRAP 32(a)(7)(B)(i) and FRAP 32(f).

## Known gaps

- **Tier 2 needs a second filer.** Only one Sixth Circuit answering brief was found in this box (Midland/Gladwin). `exemplar=yes` here means one exemplar. The Checklist and two briefing letters were the only other court documents found.
- **6 Cir. R. 32 text not verified.** The court's local rules PDF returned 404 at the URL tried. The exemplar cites "6th Cir. R. 32(a)(7)(B)" and "32(a)(7)(B)(iii)" for the type-volume certificate; the template cites FRAP 32(g) and 28.1 instead, which are verified. Whether the Sixth Circuit adds local exclusions to FRAP 32(f) (the Checklist points to 6 Cir. R. 32(b)) is open.
- **Form 6CA-1 is not reproduced.** The template prints only the answers. The clerk's form is still a separate filing.
- **Certificate wording is FRAP-based**, not the Sixth Circuit's own form text. It cites no local rule.
- **Sample is a portion.** About 1,200 words of the 9,969-word filed brief (and the record designation, which the template supports as an addendum but which is not in this sample). The sample is for layout and structure, not for a full text check.
- **Typeface.** The template sets EB Garamond; the exemplar is Times New Roman. The certificate says EB Garamond, as it must for this render.
- **No checks yet.** This folder has no `checks.yaml` and no tool gates; the ca9 gate suite is not wired for ca6.

## Exemplar errors noted (the sample does not carry them)

Listed in `usage/SOURCE.md`: the 2023 signature date, the "359895" Krieger docket in one cite, the Baird entry in the TOA, and OCR damage in the text layer.

## Engines

Same rules and numbers as the typst template (the reference). **latex** (`latex/`, tectonic): EB Garamond 14 pt from `fonts/`, double spacing, one-page cover, TOC and TOA page numbers checked against the body, certificate word count 1,199 (typst now 1,146: the latex count still includes the oral-argument statement). Differs: the cover's lower part sits slightly higher than typst's; some lines break differently, so a few TOA page numbers differ by a page from typst; no designation section (typst has none). **docx** (`docx/reference.xml`, `docx/ca6-answering-brief.lua`; fb-595.63): fb render builds `reference.docx` from `docx/reference.xml` (pandoc's default reference with these styles; the old `make-reference.sh`, `reference-src/`, `reference.docx`, `reference-addendum.docx`, `render.sh` and `pages.lua` are gone). TeX Gyre Schola 14 pt, the typst face, is the only font embedded (Regular, Bold, Italic, BoldItalic); body lines exact at the typst pitch (31.85 pt), single-spaced blocks at 20.37 pt, 16 pt section titles at 23.3 pt, 1 in margins. TOC and TOA page numbers come from fb render's multi-pass engine (the filter writes needles to `FORMBOOK_NEEDLES`, reads `FORMBOOK_PAGES`, names the footers `rIdFtrNone` and `rIdFtrPage` and writes the last section to `FORMBOOK_FINAL`; an addendum gets `rIdFtrAdd`, Add-1, Add-2, checked with a scratch sample). The certificate of compliance names TeX Gyre Schola and counts 1,146 words, as typst (the oral-argument statement is left out, FRAP 32(f)). Matches: cover on one page, unnumbered disclosure, roman front matter from the TOC, body from 1, every TOC and TOA page number checked against the pages, the body pages 1-9 start and end where typst's do within a few lines, certificates and signatures. Differs (tier 2): 16 pages against typst's 15, because the front matter runs one page longer (the last two lines of issue 2 fall on page v; docx headings take a few points more than typst's and LibreOffice widow control will not leave one line); Word may paginate slightly differently from the checked LibreOffice PDF (docs/DOCX.md). `check.sh --engine docx`: 8 passed, 0 failed. BLOCKED: none.

## Verification pass 2026-10-16 (fb-595.26.6)

- Re-rendered `usage/OUTPUT-answering-brief.typst.pdf` with `tools/render.sh` (exit 0, no typst warnings): 14 pages, the same count as the committed render; before the fixes below its text was identical to the committed PDF (not stale). Overlay rerun: same page map as before (cover 92%, conclusion 81%, body 22–56%).
- All 14 pages viewed at 60 dpi (pages 12–14 again after the fixes); the 14 overlay pages viewed at 40 dpi, and overlay page 1 (cover against the filed cover) at 150 dpi.
- Fixed:
  - p. 7 (certificate of compliance), tier 1: the word count included the Statement in Support of Oral Argument, which FRAP 32(f) excludes. A top-level section whose heading names oral argument is now left out of the count: 1,199 became 1,146.
  - p. 7: "14-point" broke at its hyphen; now kept on one line (boxed). The Known gap about it is removed.
  - p. 6 (signature block): wrapped office lines ("P.L.C.", "Midland County, MI and Gladwin County, MI") fell back to the column edge instead of the 0.5em indent; each line now wraps under its own indent. Same rule on the cover counsel block.
  - "§§ 324.31506" could break between the two signs (the no-break rule matched one sign only); the rule is now `[§¶]+ \S+`. It did not break in this sample.
- Remaining gaps: as in Known gaps above. The latex PDF was re-rendered (14 pages) but its template still counts the oral-argument statement (1,199); the docx outputs were not touched (no LibreOffice in this box) and also say 1,199. The disclosure page carries no page number, while the opening brief numbers its disclosure page i.
