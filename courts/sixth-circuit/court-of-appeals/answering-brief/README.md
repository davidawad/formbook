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

**Typeface: TeX Gyre Schola** (the vendored Century Schoolbook substitute, `fonts/tex-gyre-schola/`, `docs/FONTS.md`), which the typst template sets. FRAP 32(a)(5)(A) and (a)(6) require a proportionally spaced serif at 14 pt and name no face; the Sixth Circuit Briefs Checklist ("Typefaces") gives "such as Times New Roman" as an example only. LaTeX sets it with `tgschola`, Word names it (LibreOffice embeds the vendored OpenType fonts).

Fonts: TeX Gyre Schola only (`--ignore-system-fonts`); any typst warning fails the render.

## Governing rules

Verified for this doc type on 2026-10-14. "Court" means the Sixth Circuit's own publication; "text" means the rule text as fetched.

| ID | Requirement | Source | Verified | Where it is in the template |
|---|---|---|---|---|
| CA6-COVER-001 | Cover: "United States Court of Appeals for the Sixth Circuit", case number, case title, nature of proceeding and court below, brief title identifying the party, counsel name/address/telephone | FRAP 32(a)(2); [Court's Briefs Checklist, Part I](https://www.ca6.uscourts.gov/sites/ca6/files/documents/rules_procedures/Briefs%20Checklist.pdf) | Checklist text; FRAP 32(a)(2) by the Checklist citation | `cover-body()` |
| CA6-COVER-002 | Oral argument: the cover says "ORAL ARGUMENT REQUESTED" only when the brief contains the statement | 6 Cir. R. 34(a); Checklist Part V | Checklist text (the 6 Cir. R. 34(a) text itself: not fetched) | `oral_argument` key; panics if the statement heading is missing |
| CA6-FORM-001 | Order of components: cover, corporate disclosure, TOC, TOA, oral-argument statement, jurisdiction, issues, case, summary, argument, conclusion, certificates, addendum | FRAP 28(a); Checklist Parts II-XIV | Checklist text; FRAP 28(a) by citation | Assembly order in `ca6-brief()` |
| CA6-FORM-002 | Margins at least one inch on all four sides; page numbers may sit in the margin, no text there | FRAP 32(a)(4) | Yes (LII, `rule_32`) | `page-margin = 1in` |
| CA6-FORM-003 | Text double-spaced; quotations over two lines and headings and footnotes may be single-spaced | FRAP 32(a)(4) | Yes (LII) | `pitch-double` (31.4 pt); `pitch-single` (20 pt) |
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

2026-10-22 (fb-595.54.3): all 16 pages of the new typst render viewed (`pdftoppm -r 50`), and all 16 of the latex and docx renders. Changed against the 14-page render: the cover is single-spaced throughout with the counsel block at 2.6 in; the TOA runs two pages (ii–iii); the statements before the Argument run pp. iv–v (p. v holds the last two lines of the second issue: ACCEPTED, see Engines); the body is pp. 1–7, certificates pp. 8–9. Checked: cover on one page; disclosure page unnumbered; roman i–v, arabic from 1; TOC numbers equal the printed footers (Counter-Statement of the Case 1, Argument 3, Conclusion 7, Certificate of Compliance 8, Certificate of Service 9); TOA pages equal the citing pages; no heading ends a page; the last paragraph stands with the signature block; the certificate of service and its signature on one page. No defect open.

Word count: the certificate reports 1,146 words (the template's count of the sample body before the addendum, without the Statement in Support of Oral Argument, which FRAP 32(f) excludes; until 2026-10-16 that statement was counted and the certificate read 1,199). Far under 13,000. The certificate cites FRAP 32(a)(7)(B)(i) and FRAP 32(f).

## Known gaps

- **Tier 2 needs a second filer.** Only one Sixth Circuit answering brief was found in this box (Midland/Gladwin). `exemplar=yes` here means one exemplar. The Checklist and two briefing letters were the only other court documents found.
- **6 Cir. R. 32 text not verified.** The court's local rules PDF returned 404 at the URL tried. The exemplar cites "6th Cir. R. 32(a)(7)(B)" and "32(a)(7)(B)(iii)" for the type-volume certificate; the template cites FRAP 32(g) and 28.1 instead, which are verified. Whether the Sixth Circuit adds local exclusions to FRAP 32(f) (the Checklist points to 6 Cir. R. 32(b)) is open.
- **Form 6CA-1 is not reproduced.** The template prints only the answers. The clerk's form is still a separate filing.
- **Certificate wording is FRAP-based**, not the Sixth Circuit's own form text. It cites no local rule.
- **Sample is a portion.** About 1,200 words of the 9,969-word filed brief (and the record designation, which the template supports as an addendum but which is not in this sample). The sample is for layout and structure, not for a full text check.
- **Typeface.** The template sets TeX Gyre Schola; the exemplar is Times New Roman. The certificate names TeX Gyre Schola in every engine.
- **No checks yet.** This folder has no `checks.yaml` and no tool gates; the ca9 gate suite is not wired for ca6.

## Exemplar errors noted (the sample does not carry them)

Listed in `usage/SOURCE.md`: the 2023 signature date, the "359895" Krieger docket in one cite, the Baird entry in the TOA, and OCR damage in the text layer.

## Engines

Same rules and numbers as the typst template; the typst output is the reference every engine matches line for line (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

**latex** (`latex/template.tex`, `latex/*.lua`; pdflatex). The shared layout package `lib/latex/xengine.sty` and the inline rules `lib/latex/xengine.lua`: TeX Gyre Schola (`tgschola`) 14 bp in 31.4 bp line boxes (body, lists) and 20 bp boxes (headings, footnotes, tables, cover, certificates), the typst spaces as `\addvspace`, a block typst keeps whole as a `\vbox`, contents and authorities rows as `\xe@row`. The Type 1 `tgschola` and the OpenType Schola typst and Word set differ in six glyphs, `( ) [ ] / *` (a parenthesis is 0.333 em in Type 1, 0.483 em in OpenType; every other ASCII glyph agrees): the filter sets each of them as `\cag`, a box of the OpenType advance with the glyph centred and widened to all but 0.5 bp either side, so the lines hold what typst's hold and the PDF text has no space inside "(C)(8)". XENG-001..003 pass.

**docx** (`docx/reference.xml`, `docx/ca6-answering-brief.lua`). fb render builds `reference.docx` from `docx/reference.xml` (pandoc's default reference with these styles, fb-595.63; the old `make-reference.sh`, `reference-src/`, `reference.docx`, `reference-addendum.docx`, `render.sh` and `pages.lua` are gone): the recipe of `lib/docx/xengine-reference.sh`, TeX Gyre Schola 14 pt, the typst face, the only font embedded (theme fonts stripped). Every paragraph the filter writes carries the typst line box and spaces (exact line spacing, twips = 20 x pt) and its text as runs with typst's break rules; lists as typst sets them (the number in a half-inch box); a word joiner keeps "32(a)(5)" whole (LibreOffice would break between ")" and "("). TOC and TOA page numbers come from fb render's multi-pass engine (fb-595.63): the filter writes a needle for every heading (its label, title and the text after it), citation (from its first word, as typst tags it; kind N in a footnote) and section start to `FORMBOOK_NEEDLES`, reads `FORMBOOK_PAGES`, writes its page-number footers (the number in a 20 pt line; `Add-1`, `Add-2` in an addendum, checked with a scratch sample) to `FORMBOOK_FOOTERS` and the last section to `FORMBOOK_FINAL`. The old reference's Word 2013 compatibility mode is not carried over: without it the cover's centered lines and the phone numbers sit where typst sets them (the caption 0.16 pt off, was 0.39 pt; "261-2400" 59.15 pt wide as typst, was 60.2 pt); nothing else moves. XENG-001..003 pass. The TOC and TOA are text, so they do not update in Word if the text changes (render again). BLOCKED: none.


All three engines certify the same word count (1,146): each counts the markdown source of the body as typst's `count-words` does, the statement in support of oral argument left out (FRAP 32(f)).

### Cross-engine layout (fb-595.54.3)

Ported onto the shared model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty`, `lib/docx/xengine.lua`; `docs/EVAL-LOOP.md`, adoption checklist). typst: pitches instead of leadings, spaces in pt, section headings at 15 pt (whole half points; was 1.15 em; at 16 pt a heading opening a page reached above the top margin in Schola's glyph box, DEF-FORM-002 on the docx), no small capitals on the point headings (Word and LaTeX would synthesize them), `listing-row` contents and authorities, the page number in a 20 pt line, the cover single-spaced throughout and its counsel block at an explicit 2.6 in (was `pad(left: 40%)`, which typst resolved against the padded block), the right half at 3.25 in, the disclosure's question numbers in a 1.6 em box, loose lists made tight (the shared list rule cannot hold a paragraph break). A space before a closing or separating mark is a no-break space in the LaTeX and Word filters (UAX #14 LB13, as typst breaks). Result: typst 16 pages; latex and docx 16 pages, 296/296 lines alike (before: latex 76.2 %, 17 pages against 15; docx 24.8 %, EB Garamond, DEF-FONT-002 failed).

Tier-2 findings: p. v (roman) carries only the last two lines of the second issue (the double-spaced list does not fit page iv), ACCEPTED; in the latex render the widened parentheses, brackets and slashes look a little heavier than typst's, ACCEPTED; the docx lines run up to 1.5 pt narrower than typst's (LibreOffice rounds Schola's advances), no break moves, ACCEPTED.

## Verification pass 2026-10-16 (fb-595.26.6)

- Re-rendered `usage/OUTPUT-answering-brief.typst.pdf` with `tools/render.sh` (exit 0, no typst warnings): 14 pages, the same count as the committed render; before the fixes below its text was identical to the committed PDF (not stale). Overlay rerun: same page map as before (cover 92%, conclusion 81%, body 22–56%).
- All 14 pages viewed at 60 dpi (pages 12–14 again after the fixes); the 14 overlay pages viewed at 40 dpi, and overlay page 1 (cover against the filed cover) at 150 dpi.
- Fixed:
  - p. 7 (certificate of compliance), tier 1: the word count included the Statement in Support of Oral Argument, which FRAP 32(f) excludes. A top-level section whose heading names oral argument is now left out of the count: 1,199 became 1,146.
  - p. 7: "14-point" broke at its hyphen; now kept on one line (boxed). The Known gap about it is removed.
  - p. 6 (signature block): wrapped office lines ("P.L.C.", "Midland County, MI and Gladwin County, MI") fell back to the column edge instead of the 0.5em indent; each line now wraps under its own indent. Same rule on the cover counsel block.
  - "§§ 324.31506" could break between the two signs (the no-break rule matched one sign only); the rule is now `[§¶]+ \S+`. It did not break in this sample.
- Remaining gaps: as in Known gaps above. The latex PDF was re-rendered (14 pages) but its template still counts the oral-argument statement (1,199); the docx outputs were not touched (no LibreOffice in this box) and also say 1,199. The disclosure page carries no page number, while the opening brief numbers its disclosure page i.
