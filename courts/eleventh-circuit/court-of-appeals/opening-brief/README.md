# 11th Circuit: appellant's opening brief

Doc-type folder for the Eleventh Circuit, `opening-brief` (one self-contained folder per doc type). Court-root `typst/` and `samples/` are not used here.

| Item | Status |
|---|---|
| Exemplar | yes: `exemplars/FILED-EXAMPLE-hill-v-clayton-county-23-12884-opening-brief.pdf` (see `exemplars/SOURCE.md`) |
| Sample markdown | `samples/INPUT-hill-opening-brief.md`, a partial transcription of the exemplar (cover, CIP, oral argument, jurisdiction, issues, case, argument II.A/II.B, conclusion, certificates) |
| Render | ok: `sh tools/render.sh courts/eleventh-circuit/court-of-appeals/opening-brief samples/INPUT-hill-opening-brief.md` gives 16 pages, no typst warnings |
| Overlay | ok (2026-10-16): `sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/opening-brief hill-opening-brief` writes `samples/OVERLAY-hill-opening-brief.pdf` and `.txt` (16 pages paired) |
| Typeface | face required: none named (FRAP 32(a)(5)(A)); no substitute; EB Garamond kept |
| Pages reviewed | 16 of 16 re-rendered 2026-10-16 and viewed one by one at 60 dpi (see "Verification pass 2026-10-16") |
| Tier 1 gates | not built (no `checks.yaml` for this doc type); the form rules below are implemented in the template and checked by review only |
| Status | not set. `court.json` is not used here |

## Governing rules

Dates verified: 2026-10-14, for every source below, unless marked otherwise.

| ID | Requirement | Source | Implemented as |
|---|---|---|---|
| CA11-FORM-002 | Margins at least 1 inch, all four sides | FRAP 32(a)(4) https://www.law.cornell.edu/rules/frap/rule_32 | `page-margin = 1in` |
| CA11-FORM-003 | Proportionally spaced serif face, 14-point or larger, including footnotes | FRAP 32(a)(5)(A), same URL; 11th Cir. R. 32-3 (as printed in the Aug. 5, 2026 packet) | EB Garamond at 14 pt; footnotes at 14 pt |
| CA11-FORM-004 | Double spacing for typed matter | 11th Cir. R. 32-3, https:\/\/www.ca11.uscourts.gov\/sites\/default\/files\/courtdocs\/clk\/Redlined%20Rules%20Excerpts.AUG26.pdf (as printed in the Aug. 5, 2026 packet of proposed amendments; the packet's redline marks do not show in text extraction, so the 32-3 wording is taken as current) | body, CIP, TOC, TOA, Certificate of Compliance double-spaced |
| CA11-FORM-005 | Single spacing allowed only for cover, certificate of service, direct quotes, headings, footnotes | 11th Cir. R. 32-3 (as above) | cover, headings, block quotes, footnotes, signature blocks, certificate of service single-spaced |
| CA11-FORM-006 | Type style: plain roman; case names italicized or underlined | FRAP 32(a)(6), same URL | `*...*` in the markdown, as written |
| CA11-COVER-001 | Cover: docket number centered at top; name of this court; title of case; nature of proceeding; court below; title of brief; attorney name, office address, telephone | 11th Cir. R. 28-1(a) (as above); FRAP 32(a)(2) | `cover-body` |
| CA11-CONT-001 | Table of Contents with page references to each section and each heading | 11th Cir. R. 28-1(c) (as above) | outline of every outlined heading, with page numbers |
| CA11-CONT-002 | Table of Citations: every page on which an authority is cited, no "passim", asterisks on citations the party primarily relies on | 11th Cir. R. 28-1(d) (as above) | `toa:KEY` links list every page; `toa*:KEY` marks a primary citation with an asterisk on that page; "passim" is never printed |
| CA11-CONT-003 | Required sections, in order: CIP (26.1-1), oral-argument statement (28-1(b)), TOC (c), TOC of citations (d), adoption statement (e), jurisdiction (f), issues (g), case incl. facts and standard of review (h), summary of argument (i), argument (j), conclusion (k), certificate of compliance (l), certificate of service (m) | 11th Cir. R. 28-1 (as above) | front matter in that order; body sections as headings; certificates after the signature |
| CA11-LEN-001 | Principal brief: no more than 13,000 words, excluding the cover, tables, certificates and signature block | FRAP 32(a)(7)(B)(i), same URL; FRAP 32(f) lists the excluded items (text not re-fetched) | word count from the markdown body only; the cover, CIP, tables, oral-argument statement, signature block and certificates are outside it by construction; the template panics above 13,000 |
| CA11-CERT-001 | Certificate of compliance with word count and typeface statement | FRAP 32(g)(1), same URL (quoted: the certificate "must state the number of words") | `certificate-of-compliance`; the word count is computed from the markdown |
| CA11-CERT-002 | Certificate of service | FRAP 25(d); the clerk's sample shell brief, https://www.ca11.uscourts.gov/sites/default/files/courtdocs/clk/Sample_Shell_Brief.DEC25.pdf (fetched 2026-10-14) | `certificate-of-service`, only when `service: true` in the frontmatter |
| CA11-CIP-001 | Certificate of Interested Persons and Corporate Disclosure Statement | 11th Cir. R. 26.1-1; FRAP 26.1 | placed first, paginated C-1, C-2; the exemplar places it in the brief. Open question below |

The clerk's sample shell brief (13 pp.) and the 11th Cir. rules excerpt are the court's own sources for the cover, the section order and the 14-point rule. The filed exemplar settles only what the rules leave open: the Times New Roman face (not vendored here, see gaps), the front-matter pagination (C-1, i, ii, ...), and the signature layout.

Not verified: the full text of 11th Cir. R. 26.1-1 (the CIP form is at https://www.ca11.uscourts.gov/sites/default/files/courtdocs/clk/CIP%20Form.JUN26.pdf, seen in search results, not opened).

## Markdown contract (the frontmatter fields)

| Field | Feeds |
|---|---|
| `case_number` | cover "Case No.", PDF title |
| `caption` | list of `{names, designation}` sides; "v." inserted between |
| `proceeding`, `district_court_case` | cover lines under the caption |
| `brief_title` | cover title, certificates |
| `counsel` (`names`, `lines`), `phone`, `role` | cover counsel block, role line |
| `date`, `signature` (`signer`, `lines`) | signature block: "Respectfully submitted this {date}." |
| `cip_intro`, `cip` (list), `cip_closing` | CIP, numbered C-1, C-2 |
| `oral_argument` | Statement Regarding Oral Argument (roman i) |
| `service` (true/false), `service_list` (list of `{lines}`) | certificate of service |
| `authorities` | Table of Citations: `{kind: case|statute|rule|other, name, cite}` per key |

The body: `#` sections (Statement Regarding Adoption, Jurisdictional Statement, Statement of the Issues, Statement of the Case, Summary of the Argument, Argument, Conclusion). Under Argument, `##` is a centered point heading (I., II.), `###` is A., `####` is 1. Elsewhere `##` is A., `###` is 1. Cite an authority as `[*Case v. Case*, cite](toa:KEY)`; `toa*:KEY` marks a primary citation.

## Overlay (`samples/OVERLAY-hill-opening-brief.txt`)

The overlay pairs each of our pages with the filed page sharing the most words. Pages 1-5 (cover, CIP, oral argument, TOC) pair with the same-numbered exemplar pages, with 58-86% word overlap; pages 6-7 (the rest of the TOC) pair with exemplar pages 5-6 at 31-33%. Body pages (ours 9-16) pair with exemplar pages 15-43 at 32-77% overlap, because the sample is a partial transcription that starts at the Jurisdictional Statement. Overlay page 8 (our TOA) pairs with exemplar page 2 at 1.4%; that is a pairing artifact, because the Table of Citations has no counterpart in the exemplar's first pages, not a content match. The overlay is a diagnostic, not a score.

Visible differences from the exemplar that are tier 3 (one filer's choice) and are left alone:

- Face: EB Garamond (vendored) against the exemplar's Times New Roman. Both are proportional serif faces at 14 pt, which FRAP 32(a)(5)(A) allows.
- Heading style: the exemplar's point headings are in small capitals and bold; the template uses bold capitals for point headings and bold for A./B. headings.
- Front matter: the exemplar's Statement of the Case uses roman I/II/III; the template uses the ca9-style A./B. convention for the non-argument sections.

## Page review (16 pages, final render)

| Page | Reviewed | Result |
|---|---|---|
| 1 (cover) | yes | fits on one page; docket, court, caption, proceeding, title, counsel, role all present |
| 2-3 (C-1, C-2) | yes | CIP double-spaced, all 18 items; closing paragraph on C-2 |
| 4 (i) | yes | oral argument statement, double-spaced |
| 5-6 (ii, iii) | yes | TOC with page numbers; wrapped entries double-spaced; C-1 entry at top |
| 7-8 (iv, v) | yes | Table of Citations; primary citations marked with asterisks (`*4`, `*5`); "Rules" group spills one entry onto v |
| 9 (1) | yes | Adoption and Jurisdictional Statement |
| 10 (2) | yes | Issues and Statement of the Case, A. and B. headings; the B. Standard of Review paragraph continues on page 3 |
| 11 (3) | yes | end of Standard of Review; Summary of the Argument; Argument I. Standard of Review; blank space at the foot of the page before point II (the point heading, A. and the first lines would not fit) |
| 12 (4) | yes | point II centered heading in bold capitals; A. subheading hanging; block quotes single-spaced |
| 13 (5) | yes | B. subheading, Anago quote; Conclusion heading |
| 14 (6) | yes | conclusion and signature block kept together |
| 15 (7) | yes | Certificate of Compliance: word count 1,055 (computed), 14-point typeface statement |
| 16 (8) | yes | Certificate of Service with the service list and the signature on one page |

Defects found during review and fixed in this pass: the signature block stood alone on a page (fixed by keeping the last paragraph with it); the TOC, TOA and CIP were single-spaced (the 11th Cir. R. 32-3 double-spacing rule applies to them; fixed); the service list's signature split from the list (fixed); the certificate printed "14pt" in monospace (now "14-point").

## Known gaps and open questions

1. **Tier 1 gates not built.** There is no `checks.yaml` for this doc type yet, so the rules above are verified by review only. Gate 0 (content) and Gate 1 (rules) need to be added before this is marked green.
2. **Typeface.** Decided 2026-10-14: the face required is none. FRAP 32(a)(5)(A) requires a proportionally spaced face with serifs, 14 pt or larger, and names no family (checked at Cornell LII). The Eleventh Circuit local-rule text (R. 32-3, 32-4) could not be read here, so a local face cannot be ruled out. No substitute is needed and EB Garamond stays. The exemplar's Times New Roman is one filer's choice (tier 3).
3. **TOC and TOA spacing.** 11th Cir. R. 32-3 reads "All other typed matter must be double-spaced, including the Table of Contents and the Table of Citations." The exemplar single-spaces its TOC lines with space between entries. The template double-spaces wrapped lines and the space between single-line entries stays at the template default. Confirm the intended reading.
4. **CIP placement.** 11th Cir. R. 26.1-1 may require the CIP to be filed separately (through the web-based form) rather than inside the brief. The exemplar includes it inside the brief as C-1; the template follows the exemplar. Confirm.
5. **Primary-citation asterisks** (11th Cir. R. 28-1(d)) are implemented as a `toa*:` marker, with the asterisk on the page. The rule does not say exactly where the asterisk goes; the template puts it next to the page number in the Table of Citations.
6. **Transcription.** The sample is a partial transcription. The minor child's name in the settlement agreement quotation is replaced with "[minor child name redacted]". The exemplar has apparent citation errors (Hayes v. Nat'l Serv. Indus. dated 1990; Mass. Cas. v. Forman dated 1994 in one place), which are copied as written and not corrected.
7. **Exemplar count.** One exemplar only (Hill). `exemplars/SOURCE.md` lists two other RECAP briefs found by search (Lozman, No. 24-11477; Popoca, No. 22-10994). Tier 2 says two or three exemplars from different filers; a second one is needed before tier 2 can pass.
8. **Clearinghouse** listings (e.g. doc 74063) returned an error page from this environment.
9. **Not implemented:** addenda, a required-section ordering check, and the Standard-of-Review heading check that ca9 has.
10. **Length.** 16 rendered pages against a target of 8-14. The extra pages are the double-spaced TOC and TOA (2 + 2 pages) and the CIP (2 pages), all required by the rules or the exemplar. Trimming the body further would cut the argument down to a stub.

## Verification pass 2026-10-16 (fb-595.26.11)

- Rendered: `sh tools/render.sh courts/eleventh-circuit/court-of-appeals/opening-brief samples/INPUT-hill-opening-brief.md` exits 0, no typst warnings, 16 pages (the committed PDF also had 16). Fonts embedded: EB Garamond Regular, Italic, Bold only.
- Viewed: all 16 pages at 60 dpi, before and after the fix; the exemplar's page 1 against our cover; the 16 overlay pages at 40 dpi.
- Overlay: rerun; `samples/OVERLAY-hill-opening-brief.pdf` and `.txt` rewritten. Pages 1-5 pair with exemplar pages 1-5 (58-86%); page 8 (the short Rules page of the TOA) still pairs at 1.4%, a pairing artifact.
- Defect fixed (tier 2): body paragraphs had no first-line indent, so with double spacing a new paragraph could not be told from a continued one (exemplar and convention indent them). Cause: the `set par(first-line-indent: 0pt)` for the oral-argument statement was not scoped and carried into the body. It is now scoped; body paragraphs indent 0.5 in, and the oral-argument statement indents too. Page count unchanged; the Standard of Review paragraph now ends on page 3 and the TOA page for *Managed Care* moved from 2 to 3, as the TOA shows.
- Remaining gaps: a citation line that follows a block quote is a new markdown paragraph, so it is indented (the exemplar sets it flush left); tier 3, left. The rest of "Known gaps" stands (no `checks.yaml`, one exemplar, CIP placement, asterisk position).
- latex: `sh tools/render.sh --engine latex ...` rebuilt `OUTPUT-hill-opening-brief.latex.pdf` (exit 0, 16 pages); its pages were not reviewed in this pass. docx outputs untouched (no LibreOffice on this box).

## Build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst, poppler, imagemagick, gawk, jq (micromamba, conda-forge)
sh tools/render.sh courts/eleventh-circuit/court-of-appeals/opening-brief samples/INPUT-hill-opening-brief.md
sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/opening-brief hill-opening-brief
```

## Engines

The typst template is the reference. The latex and docx engines follow the same form (`latex/`, `docx/`); the rendered
outputs are `samples/OUTPUT-hill-opening-brief.latex.pdf`, `.docx` and `.docx.pdf`.

- **latex** (`latex/template.tex`, `latex/ca11.lua`, `latex/render.sh`). Matches: EB Garamond 14 pt from `fonts/`,
  double spacing, one-inch margins, the cover, the C-1 and C-2 pages of the certificate of interested persons,
  roman front matter, arabic body, the table of contents and table of citations with their pages (from a second
  LaTeX pass), the asterisks on primary citations, the signature kept with the last paragraph, both certificates.
  Differs: line breaks and some heading spacing, so body text falls one line apart from typst from about page 12 on; the
  table pages carry the LaTeX pages.
- **docx** (`docx/reference.docx`, `docx/ca11.lua`, `docx/render.sh`, `docx/make-reference.sh`). The cover, the
  certificates and the tables are written with explicit formatting; sections carry the C-, roman and arabic footers.
  The page numbers in the tables are written text, taken from a first LibreOffice render (no TOC or TOA fields), so
  Word may paginate differently. Differs: no space before the dot leaders of the tables; the body text runs about
  as long as typst's, 16 pages both.
  BLOCKED: none for the build. The docx is checked on its LibreOffice PDF only; Word was not available.
