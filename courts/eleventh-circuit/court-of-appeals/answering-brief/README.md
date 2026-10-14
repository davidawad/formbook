# Eleventh Circuit: appellee's answer brief (court `ca11`)

Doc type `answering-brief`. Folder layout: `exemplars/` (the filed exemplar and its SOURCE.md), `samples/` (the markdown transcription, the rendered PDF, the overlay), `typst/` (the template). The court-root `typst/` and `samples/` of `court-of-appeals/` belong to the older opening-brief work and are untouched.

Status: template and one sample built, rendered and reviewed. Not a complete eval loop: the tools in `tools/check.sh` are not wired to this folder (no `checks.yaml`, no `rules.md`); the requirements below are checked by the reviewer, not by a gate.

## Sources (verified 2026-10-14)

| Tag | Source | URL |
|---|---|---|
| HB | Eleventh Circuit "Federal Rules of Appellate Procedure and Eleventh Circuit Rules" (bookmarked), Rev. 12/25 (Circuit Rules), with FRAP text as printed in that handbook | https://www.ca11.uscourts.gov/sites/default/files/courtdocs/clk/Rules_Bookmarked.DEC25.pdf |
| SHELL | Eleventh Circuit sample shell brief, DEC25 (names the "Appellee's Answer Brief" cover form; shows the page-numbering scheme) | https://www.ca11.uscourts.gov/sites/default/files/courtdocs/clk/Sample_Shell_Brief.DEC25.pdf |
| EX | The filed exemplar in `exemplars/` (see `exemplars/SOURCE.md`) | local |

What was checked: the rule text was read from HB by text extraction on 2026-10-14. HB is the bookmarked handbook the court's own rules pages point to (found by search; the court's rules index URL returned 404 to this box). It is not checked against any later amendment. Within HB the FRAP pages carry different revision dates: Rule 32(a) is Rev. 12/16 and Rule 32(g) is Rev. 12/24. No other source was used for a number in the template.

## Requirements

Kind: **M** = mandated by a court rule (FRAP or Circuit Rule), **C** = convention (the rules leave it open; the exemplar is the reference), **T** = project choice.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA11-FORM-001 | Letter paper, 8½ × 11 in. | FRAP 32(a)(4), HB | M |
| CA11-FORM-002 | Margins at least one inch on all four sides; page numbers may sit in the margin, no other text may. | FRAP 32(a)(4), HB | M |
| CA11-FORM-003 | Text double-spaced, including the Table of Contents and the Table of Citations. Quotations over two lines and headings and footnotes may be single-spaced; the cover page and the certificate of service may be single-spaced. | FRAP 32(a)(4); 11th Cir. R. 32-3, HB | M |
| CA11-FORM-004 | Proportionally spaced serif face, 14-point or larger. Template: EB Garamond (vendored), 14 pt, everywhere including footnotes and headings. | FRAP 32(a)(5)(A), HB | M |
| CA11-FORM-005 | Plain roman type; italics or bold for emphasis; case names italicized. | FRAP 32(a)(6), HB | M |
| CA11-FORM-006 | Every font embedded and vendored. Typst's fallback monospace font is not allowed; the template prints the point size as a number so no length value is rendered in a fallback face. | project | T |
| CA11-FORM-007 | Page numbers: the cover is unnumbered; front matter (Statement Regarding Oral Argument, Table of Contents, Table of Citations) in lowercase roman; body from 1 at the Introduction; certificates and the addendum continue the body count. | 11th Cir. R. 32-4 (materials in 28-1(a)–(g) need not be numbered); SHELL, EX | C |
| CA11-COVER-001 | Cover: docket number centered at top; name of this court; case title; nature of the proceeding and the court below; title of the brief identifying the party; name, office address and telephone number of counsel. | FRAP 32(a)(2)(A)–(F); 11th Cir. R. 28-1(a), HB | M |
| CA11-COVER-002 | Cover color: red for an appellee's brief; the electronic PDF is white (as the exemplar is). Red applies to paper copies that the clerk requests under 11th Cir. R. 31-3 (two copies within seven days of the clerk's notice); the paper cover is not produced by this template. | FRAP 32(a)(2); 11th Cir. I.O.P. 1 (Color of Covers); 11th Cir. R. 31-3, HB | M (paper) |
| CA11-ORAL-001 | Statement Regarding Oral Argument, first item after the cover. The appellee's brief includes one. | 11th Cir. R. 28-1(b), HB | M |
| CA11-CONT-001 | Table of Contents with page references to every section and to every heading and subheading of each issue argued. | 11th Cir. R. 28-1(c), HB | M |
| CA11-CONT-002 | Table of Citations: every page on which an authority is cited. "passim" is not allowed; ranges are allowed only where the authority is cited on every page of the range. The template lists every page, no ranges. | 11th Cir. R. 28-1(d), HB | M |
| CA11-CONT-003 | Appellee's brief may omit the jurisdictional statement, the statement of the issues and the statement of the case if satisfied with the appellant's statement. The sample includes the statement of the case and the standard of review, as the exemplar does; the template does not require any of the three. | 11th Cir. R. 28-2; FRAP 28(b), HB | M (optional items) |
| CA11-CONT-004 | Statement of the Case, with the standard or scope of review for each contention (the template's heading "Standard of Review" must exist at some level). | 11th Cir. R. 28-1(h)(iii), HB | M |
| CA11-CONT-005 | Summary of the Argument: suitably paragraphed, seldom more than two pages, never more than five. | 11th Cir. R. 28-1(i), HB | M |
| CA11-CONT-006 | Argument, with citations in the Bluebook or ALWD style and pinpoint pages. | 11th Cir. R. 28-1(j), HB | M |
| CA11-CONT-007 | Conclusion stating the precise relief sought. The signature block follows it. | 11th Cir. R. 28-1(k), HB | M |
| CA11-CONT-008 | Adoption statement (only if the brief adopts another party's brief under FRAP 28(i)): not generated; add as a section if used. | 11th Cir. R. 28-1(e), HB | M (conditional) |
| CA11-LEN-001 | Principal brief, no cross-appeal: no more than 13,000 words. The template's limit for `word_limit_basis: standard`. | FRAP 32(a)(7)(B)(i); 11th Cir. R. 32-4, HB | M |
| CA11-LEN-002 | Appellee's principal and response brief in a cross-appeal: no more than 15,300 words. The template's limit for `word_limit_basis: cross-appeal`, with the certificate citing FRAP 28.1(e)(2)(A)(ii). | FRAP 28.1(e)(2)(A)(ii), HB | M (conditional) |
| CA11-LEN-003 | Excluded from the count: cover, table of contents, table of citations, statement regarding oral argument, addendum, certificates, signature block, proof of service. The template counts the markdown before `# Addendum`, minus the frontmatter, minus the generated parts. | FRAP 32(f); 11th Cir. R. 32-4, HB | M |
| CA11-CERT-001 | Certificate of Compliance with the type-volume limit and the typeface requirements, in the form of Form 6 (the word count stated). Generated from the markdown count. | FRAP 32(g)(1)–(2), Form 6, HB | M |
| CA11-CERT-002 | Certificate of Service: FRAP 25(d) requires one when the brief is not served through the court's electronic-filing system. The sample includes one, as the exemplar does; the template makes it opt-in (`service.certificate`). | FRAP 25(d), HB; EX | C |
| CA11-CIP-001 | The Certificate of Interested Persons is not part of the brief: it is filed separately, on paper or electronically, and the web-based CIP is completed. The template does not generate one. | 11th Cir. R. 26.1-1(a)–(b) (Rev. 12/25), HB | M (outside this template) |
| CA11-ADD-001 | Addendum (statutes, rules, regulations) after the certificates; numbered Add-1, Add-2; excluded from the count. | 11th Cir. R. 32-4, HB | M |

Findings that differ from the other circuits' templates:

1. **No Statement of Related Cases.** The Ninth Circuit's Form 17 has no Eleventh Circuit equivalent in this handbook; the CIP (CA11-CIP-001) is the disclosure document. The ca9 template's related-cases page is not carried over.
2. **No "passim."** 11th Cir. R. 28-1(d) forbids it; the template lists every page (CA11-CONT-002).
3. **Certificate of Compliance is Form 6** (FRAP 32(g)(2)), not the ca9 Form 8. It states the word count and the typeface.
4. **Word limit is 13,000**, not 14,000; 15,300 for a cross-appeal response.
5. **Front matter order** follows 11th Cir. R. 28-1: oral-argument statement, then contents, then authorities.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body. Fields:

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover top line, "No. ..." |
| `caption` | yes | Cover title of the case: each side's `names` (one centered line each) and `designation`. "v." between the sides. |
| `proceeding` | yes | Cover: nature of the proceeding and the court below. |
| `brief_title` | yes | Cover title, in capitals. |
| `oral_argument` | yes | The Statement Regarding Oral Argument (front matter, page i). Not counted in the words. |
| `counsel` | yes | Cover counsel block: `names` and `lines` per group. The phone number is appended to the last group. |
| `phone` | yes | Telephone, on the cover. |
| `signature` | yes | `signer` (printed "s/ Name" and in capitals), `party` (for "Attorney for ..."), `lines`. |
| `date` | no | "Dated" line under the signature and on the certificates. |
| `word_limit_basis` | no (default `standard`) | `standard` (13,000) or `cross-appeal` (15,300). |
| `manual_image_words` | no (default 0) | Words counted by hand in visual images (Form 6 wording). |
| `service` | no | `certificate: true` adds the Certificate of Service; `unregistered` lists non-CM/ECF persons. |
| `authorities` | yes if the body cites any | Registry: `kind` (`case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `name` (optional, italic for cases), `cite`. |

Body: `# Heading` is a section (bold, capitals, centered). Sub-headings are numbered automatically: level 2 is I., level 3 A., level 4 1., level 5 a. (the exemplar's scheme in both the Statement of the Case and the Argument). Citations: `[*Bernal v. Fainter*, 467 U.S. 216, 219 (1984)](toa:bernal)`; short forms use the same key. Footnotes use markdown footnote syntax. A `toa:` key missing from `authorities:` stops the build.

## Build and check

From the repo root, with `export PATH="$HOME/tb/bin:$PATH"` (typst 0.15.0, poppler, ImageMagick, gawk, jq):

```sh
sh tools/render.sh courts/eleventh-circuit/court-of-appeals/answering-brief samples/INPUT-naacp-v-byrd-25-12813.md
sh tools/overlay.sh courts/eleventh-circuit/court-of-appeals/answering-brief naacp-v-byrd-25-12813
```

Render result: `samples/OUTPUT-naacp-v-byrd-25-12813.pdf`, 14 pages, no typst warnings, embedded fonts only EB Garamond Regular, Italic and Bold.

Word count: 1,428 by the template; 1,428 by an independent `awk` count of the markdown body (same exclusions).

## Overlay (the red/blue test)

`samples/OVERLAY-naacp-v-byrd-25-12813.pdf`: red = our render only, blue = the exemplar only, black = both agree. Pages are paired by word overlap (`samples/OVERLAY-naacp-v-byrd-25-12813.txt`):

| ours | filed | word overlap |
|---|---|---|
| 1 (cover) | 1 | 60.2% |
| 2 (oral argument) | 14 | 77.7% |
| 3 (contents) | 15 | 39.3% |
| 4 (authorities) | 17 | 30.3% |
| 5 (authorities, statutes) | 18 | 5.3% |
| 6 (introduction) | 19 | 83.8% |
| 7 (statement of the case) | 20 | 46.4% |
| 8 (standard, summary) | 26 | 93.3% |
| 9 (argument I.A) | 28 | 42.2% |
| 10 (argument I.A) | 29 | 70.1% |
| 11 (argument I.A, footnote) | 30 | 43.0% |
| 12 (conclusion, signature) | 46 | 31.4% |
| 13 (certificate of compliance) | 47 | 33.8% |
| 14 (certificate of service) | 13 | 25.6% |

The overlay is a diagnostic, not a score. Low overlap on the contents and the certificates is expected: the page pairing matches words, and the exemplar's contents and authorities pages list different page numbers and an extra CIP. Page 5 (overlap 5.3%) is the short statutes page, which pairs with an exemplar authorities page of different content. Page 14 pairs with exemplar page 13 (the exemplar's certificate of compliance) because the exemplar's text is on that page; the pairing is by word, so it is not the same certificate.

## Gate 2: visual review

Pages reviewed: **14 of 14**, each rendered at 60 dpi with `pdftoppm -r 60` and looked at.

Defects found and fixed during review:

- Typst fell back to DejaVu Sans Mono on the certificate of compliance page, because the point size was interpolated as a length. Fixed: the size prints as a number. Re-rendered: only EB Garamond is embedded.
- A contents entry put its page number alone on the next line when the title filled the line. Fixed: the page number is in its own bottom-aligned column.
- The certificate of service was missing a comma after the date. Fixed.

Open or accepted findings, by page:

| Page | Finding | Status |
|---|---|---|
| 1 | Cover fits on one page; counsel block reads correctly. The lead counsel's firm name wraps on the cover. | ACCEPTED (column width is the cover's half-page indent, as in the ca9 template) |
| 2 | Statement Regarding Oral Argument on page i. | OK |
| 3 | Contents: page numbers right, leaders present, subheading entries wrap with page numbers on the last line. | OK |
| 4 | Table of Citations: no passim, every page listed. | OK |
| 5 | Statutes group starts a new page (iv) with two entries. | ACCEPTED (each authority entry is kept whole, so the short statutes group moves to a new page; the layout is the same as ca9's) |
| 6 | Introduction and the start of the statement of the case, double-spaced, headings in place. | OK |
| 6 | "Fla. Stat. § 97.0575(1)(f)" breaks between "Stat." and "§" at the line end. | OPEN (typographic: a non-breaking space in the markdown would fix it; the sample text is kept as filed) |
| 7 | Procedural background, standard of review, summary: contents match the numbering. | OK |
| 8 | Standard of Review and Summary of Argument. | OK |
| 9–10 | Argument I.A: point and subheading placement, italic case names, citations in the body. | OK |
| 11 | Footnote 1 (the exemplar's footnote 8) continues onto the next page. | ACCEPTED (footnote renumbered from the sample's position; a split footnote is normal typesetting) |
| 12 | Conclusion; signature block with "s/" and capitals, lead counsel only. | ACCEPTED (one signer; the exemplar has three counsel signing as "/s/" on one line, which the template does not model) |
| 13 | Certificate of compliance, Form 6 wording, word count. | OK |
| 14 | Certificate of service, CM/ECF wording. | OK |

Nothing is marked OK without a render and a look.

## Known gaps

1. **Typeface.** The exemplar is set in Times New Roman 14 pt. FRAP 32(a)(5)(A) requires a serif face at 14 pt; the template uses EB Garamond, the only serif face vendored in `fonts/`. Adding a Times-metric face is a change to `fonts/`, which this box does not touch.
2. **CIP.** The exemplar includes its Certificate of Interested Persons inside the brief (pp. C-1 to C-12). 11th Cir. R. 26.1-1 requires it as a separate filing; the template does not produce one.
3. **Excerpt.** The sample is a transcription of part of the brief: the cover, oral-argument statement, contents, authorities, introduction, the statement of the case (I and II.A only), standard of review, summary, Argument I.A (first part), conclusion, signature, certificates. The exemplar's body runs from page 1 to page 28, with certificates on page 29 of its own numbering. Statement II.B–C and Argument I.B–C and II are not transcribed.
4. **Exemplar inconsistency.** The exemplar's Table of Citations gives *In re Griffiths* as 413 U.S. 719; its text gives 413 U.S. 717. The sample uses 717, the cite in the body.
5. **Cross-references.** The exemplar's footnote 8 says "See supra at 6"; the sample says "See supra Statement of the Case," because page references in the sample do not match the exemplar's pagination. The footnote number is the sample's own (1), not the exemplar's (8).
6. **Multiple counsel.** The cover lists three counsel and one lead signer. The template models one signer.
7. **Form 6 "word-processing program".** Form 6 asks for the program name and version; the certificate says "set with Typst 0.15.0" because that is the program that set the type.
8. **Addendum, adoption statement, cross-appeal layout.** Template supports the addendum and the cross-appeal word limit; no sample exercises them, and the adoption statement (CA11-CONT-008) is not generated.
9. **No gate.** `tools/check.sh` is not wired to this folder: no `checks.yaml`, no `rules.md`, no selftest. The checks above are by reading and by the word count.
