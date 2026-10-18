# Eleventh Circuit: reply brief (appellant's reply, 11th Cir. R. 28-3)

Status of this doc type: **exemplar found, template built, render and overlay run, every page reviewed.** Not a court-level sign-off: `court.json` and the tracker are unchanged.

| Path | What |
|---|---|
| `usage/SAMPLE-ca11-reply-brief-jgvnorthfield2512276.pdf` | The filed reply (ECF Doc. 23, 14 pp., text layer present). Provenance in `usage/SOURCE.md`. |
| `usage/INPUT-ca11-reply-brief-jgvnorthfield.md` | Transcription of the whole reply: cover, every heading, all argument, conclusion, signature, certificates. Frontmatter holds the cover, counsel, authorities. |
| `usage/OUTPUT-ca11-reply-brief-jgvnorthfield.typst.pdf` | `sh tools/render.sh courts/eleventh-circuit/court-of-appeals/reply-brief usage/INPUT-ca11-reply-brief-jgvnorthfield.md` (14 pp.) |
| `usage/OVERLAY-jg-v-northfield-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/reply-brief jg-v-northfield-reply-brief` (red = ours, blue = filed, black = agree). |
| `typst/main.typ` | Entry point: reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/ca11-reply-brief.typ` | The template `ca11-reply-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |

## Governing rules

Dates: "verified" is the date the text was read from the source in this session (2026-10-14). The 11th Circuit local rules are taken from the Clerk's memorandum of **August 5, 2026** (redlined excerpt, 9 pp.), which carries the "Rev." dates shown; the memorandum says a set of revisions is out for comment (comments due September 4, 2026). The text used here is the text as shown in that excerpt, and the excerpt is plain-text extracted, so proposed-change markup is not visible. **Re-check the current local rules on ca11.uscourts.gov before this template is treated as final.**

| ID | Requirement | Source (URL) | Verified |
|---|---|---|---|
| CA11-RB-001 | A reply brief need contain only the cover (a), TOC (c), TOA (d), argument (j), certificate of compliance (l), certificate of service (m) of 11th Cir. R. 28-1. | 11th Cir. R. 28-3, memorandum of Aug. 5, 2026, https://www.ca11.uscourts.gov/sites/default/files/courtdocs/clk/Redlined%20Rules%20Excerpts.AUG26.pdf (Rev. 12/25 for R. 28) | 2026-10-14 |
| CA11-RB-002 | Cover: docket number centered at top; name of the court; title of the case; nature of the proceeding; name of the court below; title of the brief identifying the party; attorney name, office address, telephone. | 11th Cir. R. 28-1(a) (same memorandum); FRAP 32(a)(2) | 2026-10-14 |
| CA11-RB-003 | TOC with page references to each section and each heading of the argument. | 11th Cir. R. 28-1(c) (same memorandum); FRAP 28(c) https://www.law.cornell.edu/rules/frap/rule_28 | 2026-10-14 |
| CA11-RB-004 | TOA lists the page of every citation, with asterisks in the margin for citations the party primarily relies on, and no "passim". | 11th Cir. R. 28-1(d) (same memorandum) | 2026-10-14 |
| CA11-RB-005 | Argument and citations per Bluebook or ALWD; citations give specific pages. | 11th Cir. R. 28-1(j) (same memorandum) | 2026-10-14 |
| CA11-RB-006 | Only the cover, certificate of service, direct quotes, headings and footnotes may be single-spaced. Everything else, including TOC and TOA, is double-spaced. | 11th Cir. R. 32-3 (same memorandum) | 2026-10-14 |
| CA11-RB-007 | Reply length: no more than half the principal limit (13,000 words under FRAP 32(a)(7)(B)(i)), so 6,500 words. The template panics above 6,500. The principal limit itself was not re-read this session. | FRAP 32(a)(7)(B)(ii) https://www.law.cornell.edu/rules/frap/rule_32 | 2026-10-14 |
| CA11-RB-008 | Certificate of compliance: word count (excluding the parts exempted by FRAP 32(f) and 11th Cir. R. 32-4), and the typeface and type-style certificate. Form 6 is an acceptable form. | FRAP 32(g)(1)-(2) (memorandum, FRAP 32 excerpt); 11th Cir. R. 32-4 (same memorandum) | 2026-10-14 |
| CA11-RB-009 | Typeface: proportionally spaced, 14-point or larger; plain roman, italics or boldface for emphasis; margins at least one inch on all four sides. | FRAP 32(a)(4)-(6) https://www.law.cornell.edu/rules/frap/rule_32 | 2026-10-14 |
| CA11-RB-010 | Page numbering: cover, TOC, TOA, and the certificates are outside the page and type-volume counts; they need not be numbered. | 11th Cir. R. 32-4 (same memorandum) | 2026-10-14 |
| CA11-RB-011 | Reply cover color is gray. This is a paper-copy requirement; no color cover is produced here. | FRAP 32(a)(2) https://www.law.cornell.edu/rules/frap/rule_32 (text: "any reply brief, gray") | 2026-10-14 |
| CA11-RB-012 | Certificate of service (proof of service). | FRAP 25(d) (cited by 11th Cir. R. 28-1(m), memorandum) | 2026-10-14 |
| CA11-RB-013 | Reply timing: within 21 days after service of the appellee's brief; filed at least 7 days before argument. Not a layout rule; recorded for reference, not printed. | FRAP 31(a)(1); 11th Cir. R. 31-1(a) (same memorandum) | 2026-10-14 |

Not verified, **open**: Certificate of Interested Persons (11th Cir. R. 26.1-1). The court's CIP form says it must appear in every brief and reply. The form URL I tried (`ca11.uscourts.gov/sites/default/files/courtdocs/clk/CIP%20Form.FEB23.pdf`) returned 404, and the R. 26.1-1 text was not in the memorandum excerpt. The exemplar reply has no CIP. The template does **not** generate a CIP. This is a question for David: whether reply briefs carry a CIP in this court, and if so, which form version applies.

Also not verified: FRAP 32(a)(7)(B)(i) text (13,000 words) and the 11th Cir. R. 28-1 items not in the memorandum excerpt.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block (metadata), then the body. Same conventions as `courts/ninth-circuit/court-of-appeals/README.extra.md`, with these differences for this court:

- Frontmatter: `case_number` (printed "COURT OF APPEALS NO. ..."), `caption`, `proceeding`, `brief_title`, `counsel` (groups of `names`/`lines`), `phone` (appended to the last counsel group), `signature` (`signer`, `lines`, optional `address`), `service.date` (the certificate of service's date), `authorities` (registry as in ca9). Optional: `district_court_case`, `judge`.
- Body: `# ARGUMENT AND CITATIONS OF AUTHORITY` (or any other top-level section; the Argument is the section whose title starts with "argument"), `## POINT HEADING` (numbered I., II. automatically; under the Argument the scheme is I. / A. / 1. / a.), `# CONCLUSION`. Type the heading text in capitals as the filing does. No numbers typed in headings.
- Citations: `[*Smith v. Owens*, 848 F.3d 975, 978 (11th Cir. 2017)](toa:smith-owens)`. Use `toa-primary:KEY` for a citation the brief primarily relies on; those pages get an asterisk in the TOA (11th Cir. R. 28-1(d)). `*Id.*` links to the same key.
- Not supported: addenda, `related_cases` (no related-case statement in this court; the CIP question is open), unregistered-service lists, tables, images, raw typst. Footnotes and block quotes are supported as in ca9.
- Word count: computed from the body Markdown (headings and text; not link targets or footnote marks). Panics above 6,500 words.

## Overlay (the red/blue test)

`usage/OVERLAY-jg-v-northfield-reply-brief.pdf`, 14 pages, pages paired by word overlap with the filed exemplar (`-overlay.txt`):

| ours | filed | word-overlap |
|---|---|---|
| 1 cover | 1 | 82.9% |
| 2 TOC | 2 | 85.3% |
| 3 TOA | 3 | 77.5% |
| 4-12 body 1-9 | 4-12 | 92.6 / 80.5 / 77.2 / 77.2 / 75.3 / 65.8 / 62.6 / 60.2 / 57.6% |
| 13 certificate of compliance | 13 | 69.4% |
| 14 certificate of service | 14 | 89.6% |

The overlap is a pairing aid, not a score (the overlay itself is a diagnostic). All 14 sample pages paired with the same-numbered filed page. Transcription check: the word list of the sample's body (pdf pages 4-12) was diffed against the exemplar's body pages (4-12). The only exemplar-only tokens are the ECF header words (Case, Document, Date Filed, Page), its page numbers, and line-break hyphen splits (e.g. "post-judgment", "non-covered"). The only sample-only tokens are the same words after rejoining those splits. No content word is missing from the transcription.

## Visual review (Gate 2)

All 14 pages rendered at 60 dpi (`pdftoppm -r 60`) and viewed one by one. Findings:

| Page | Content | Result |
|---|---|---|
| 1 | Cover | OK: docket line, court, caption with "v.", proceeding, title, counsel block. Fits one page. |
| 2 | TOC (roman i) | Fixed in this pass: the page number for entry I. wrapped to its own line. Fix: page-number box 1.2em, gap 0.6em. Now on the same line; the leader on that line is short (one dot), a known cosmetic gap. 2026-10-16: the gap between entries was smaller than the leading inside an entry, so single-line entries sat closer than double spacing; now equal (fixed). |
| 3 | TOA (roman ii) | OK: every page listed, asterisks on primary citations (Ross 6*, QBE 7*, Trbovich 8*), no passim, rules group. |
| 4-12 | Body 1-9 | OK: double spacing, 14-point, first-line indent, hanging point headings, italic case names, citation pages correct. Body page 5 (pdf 8) ends with about five lines of white space because the point III heading and its opening lines move to the next page (the heading is kept with the paragraph that follows it). |
| 9 (pdf 12) | Conclusion and signature | OK: centered CONCLUSION, signature block at 50%, firm and address at the margin, after the conclusion. |
| 10 (pdf 13) | Certificate of compliance | OK: numbered paragraphs, word count 2,132 (exemplar states 2,145 from Word; this is the template's count from the Markdown, so a difference of about 13 words is expected), typeface statement. |
| 11 (pdf 14) | Certificate of service | OK: date line from `service.date`, CM/ECF wording, signature. |

Pages reviewed: 14 of 14. Every page was rendered and viewed.

## Differences from the exemplar (accepted, with reason)

- **Typeface**: decided 2026-10-14. Face required: none named. FRAP 32(a)(5)(A) requires a proportionally spaced serif face, 14 pt or larger, and names no family; the Eleventh Circuit local-rule text could not be read here. No substitute, so EB Garamond (vendored in `fonts/eb-garamond/`) stays; the exemplar's Times New Roman is a filer's choice (tier 3). The certificate says so.
- **Double-spaced TOC and TOA**: the exemplar single-spaces them; 11th Cir. R. 32-3 requires double spacing. The template follows the rule.
- **Asterisks in the TOA**: the exemplar has none. The primary-citation marks (Ross, QBE, Trbovich) are the transcriber's choice, and need the brief's author to confirm.
- **Certificates numbered**: 11th Cir. R. 32-4 lets them go unnumbered; the exemplar numbers them, so the template numbers them.
- **Signature block single-spaced**: the rule says "all other typed matter must be double-spaced"; the signature block is kept single as in the exemplar. Flag for review.
- **Counsel block order**: the exemplar places the phone number before the "Attorney for Appellant" lines; the template appends the phone to the last counsel group, so it follows the attorney lines.
- **ECF header** ("USCA11 Case ... Date Filed ... Page x of y") is the court's own stamp, not part of the brief; not produced.
- **Conclusion** is included (the exemplar has it). 11th Cir. R. 28-3 does not list it, so it is optional for the rule.

## Known gaps

- CIP (11th Cir. R. 26.1-1): not generated; open question above.
- Cover color (gray for reply, FRAP 32(a)(2)): paper copies only; not produced.
- Second exemplar: not found yet. The Liberty Mutual reply (25-13187) was rejected (garbled text layer). A second filer's reply brief is still needed to check tier-2 conventions against two exemplars.
- Certificate word count is the template's own count (2,132 for this text), not a word-processor count.
- Unregistered-party service (`service.unregistered`) is not supported; add when a sample needs it.
- The TOC leader on entry I. is one dot long (text is near full width there); cosmetic.

## Verification pass 2026-10-16 (fb-595.26.11)

- Rendered: `sh tools/render.sh courts/eleventh-circuit/court-of-appeals/reply-brief usage/INPUT-ca11-reply-brief-jgvnorthfield.md` exits 0, no typst warnings, 14 pages (the committed PDF also had 14).
- Viewed: all 14 pages at 60 dpi (pages 2-3 again after the fix); the exemplar's page 1 against our cover; the 14 overlay pages at 40 dpi.
- Overlay: rerun; `usage/OVERLAY-jg-v-northfield-reply-brief.pdf` and `.txt` rewritten. Every page still pairs with the same-numbered filed page, 57.6-92.6% (table above unchanged).
- Defect fixed (tier 1, 11th Cir. R. 32-3): in the TOC and TOA the space between entries (0.3em, 0.6em, 0.7em) was less than the double-spaced leading inside an entry, so consecutive one-line entries were not double-spaced. Both tables now use the body leading between entries. Page count unchanged.
- Remaining gaps: as listed under "Known gaps" (one exemplar, CIP question, TOC entry I. one-dot leader, signature block single-spaced). latex rebuilt (`--engine latex`, exit 0, 14 pages), its pages not reviewed in this pass; docx untouched (no LibreOffice).

## Reproduce

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/eleventh-circuit/court-of-appeals/reply-brief usage/INPUT-ca11-reply-brief-jgvnorthfield.md
sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/reply-brief jg-v-northfield-reply-brief
pdftoppm -r 60 -png courts/eleventh-circuit/court-of-appeals/reply-brief/usage/OUTPUT-ca11-reply-brief-jgvnorthfield.typst.pdf /tmp/pages/p
```

## Engines

The typst template is the reference. The latex and docx engines follow the same form (`latex/`, `docx/`); the rendered
outputs are `usage/OUTPUT-ca11-reply-brief-jgvnorthfield.latex.pdf`, `.docx` and `.docx.pdf`.

- **latex** (`latex/template.tex`, `latex/ca11.lua`, `latex/render.sh`). Matches: EB Garamond 14 pt, double spacing,
  one-inch margins, the centered cover, the table of contents (with the Table of Authorities and the certificates
  listed, as typst lists them) and the table of authorities with the primary citations starred, the two numbered
  certificates of counsel with the signature blocks. Differs: line breaks and some heading spacing (14 pages both);
  the heading labels of the Argument follow the same I., A., 1. scheme as typst.
- **docx** (`docx/reference.docx`, `docx/ca11.lua`, `docx/render.sh`, `docx/make-reference.sh`). The cover, the
  certificates and the tables are written with explicit formatting; sections carry the roman and arabic footers. The
  page numbers in the tables are written text from a first LibreOffice render, and the primary-citation stars are set
  on the pages where a `toa-primary:` link is found. Differs: 15 pages against typst's 14 (the body text breaks
  earlier in Word's layout).
  BLOCKED: none for the build; checked on the LibreOffice PDF only.
