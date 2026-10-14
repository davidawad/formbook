# Eleventh Circuit: reply brief (appellant's reply, 11th Cir. R. 28-3)

Status of this doc type: **exemplar found, template built, render and overlay run, every page reviewed.** Not a court-level sign-off: `court.json` and the tracker are unchanged.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-jg-v-northfield-25-12276-reply-brief.pdf` | The filed reply (ECF Doc. 23, 14 pp., text layer present). Provenance in `exemplars/SOURCE.md`. |
| `samples/jg-v-northfield-reply-brief.md` | Transcription of the whole reply: cover, every heading, all argument, conclusion, signature, certificates. Frontmatter holds the cover, counsel, authorities. |
| `samples/jg-v-northfield-reply-brief.pdf` | `sh tools/render.sh courts/eleventh-circuit/court-of-appeals/reply-brief samples/jg-v-northfield-reply-brief.md` (14 pp.) |
| `samples/jg-v-northfield-reply-brief-overlay.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/reply-brief jg-v-northfield-reply-brief` (red = ours, blue = filed, black = agree). |
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

`samples/jg-v-northfield-reply-brief-overlay.pdf`, 14 pages, pages paired by word overlap with the filed exemplar (`-overlay.txt`):

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
| 2 | TOC (roman i) | Fixed in this pass: the page number for entry I. wrapped to its own line. Fix: page-number box 1.2em, gap 0.6em. Now on the same line; the leader on that line is short (one dot), a known cosmetic gap. |
| 3 | TOA (roman ii) | OK: every page listed, asterisks on primary citations (Ross 6*, QBE 7*, Trbovich 8*), no passim, rules group. |
| 4-12 | Body 1-9 | OK: double spacing, 14-point, first-line indent, hanging point headings, italic case names, citation pages correct. Body page 5 (pdf 8) ends with about five lines of white space because the point III heading and its opening lines move to the next page (the heading is kept with the paragraph that follows it). |
| 9 (pdf 12) | Conclusion and signature | OK: centered CONCLUSION, signature block at 50%, firm and address at the margin, after the conclusion. |
| 10 (pdf 13) | Certificate of compliance | OK: numbered paragraphs, word count 2,132 (exemplar states 2,145 from Word; this is the template's count from the Markdown, so a difference of about 13 words is expected), typeface statement. |
| 11 (pdf 14) | Certificate of service | OK: date line from `service.date`, CM/ECF wording, signature. |

Pages reviewed: 14 of 14. Every page was rendered and viewed.

## Differences from the exemplar (accepted, with reason)

- **Typeface**: EB Garamond (vendored in `fonts/eb-garamond/`), not Times New Roman. Only vendored fonts are allowed; the rule is "proportionally spaced, 14-point", which EB Garamond meets. The certificate says so.
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

## Reproduce

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/eleventh-circuit/court-of-appeals/reply-brief samples/jg-v-northfield-reply-brief.md
sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/reply-brief jg-v-northfield-reply-brief
pdftoppm -r 60 -png courts/eleventh-circuit/court-of-appeals/reply-brief/samples/jg-v-northfield-reply-brief.pdf /tmp/pages/p
```
