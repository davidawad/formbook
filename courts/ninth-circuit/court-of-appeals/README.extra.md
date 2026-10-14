## What is here

| Path | What |
|---|---|
| `rules.md` | The requirements, each with a stable ID, a primary source and a kind (court-mandated / convention / project / author). Verified against the June 1, 2026 rules handbook. |
| `checks.yaml` | The eval-loop contract: samples, parameters, and one check per requirement ID. See [`docs/EVAL-LOOP.md`](../../../docs/EVAL-LOOP.md). |
| `typst/ca9-brief.typ` | The template: `ca9-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `samples/sweet-opening-brief.{md,pdf}` | Transcribed from the exemplar for visual comparison (a portion of the brief, not all of it). |
| `samples/generic-opening-brief.{md,pdf}` | Fictional, structurally different: the generalization sample. |
| `reviews/` | Recorded visual reviews (Gate 2). |
| `LOG.md` | One short entry per loop iteration. |
| `exemplars/` | The filed exemplar. Visual reference only. |

Build and check (from the repo root):

```sh
sh tools/render.sh courts/ninth-circuit/court-of-appeals samples/INPUT-generic-opening-brief.md   # -> samples/OUTPUT-generic-opening-brief.pdf
sh tools/check.sh courts/ninth-circuit/court-of-appeals                                     # gates 0-3
sh tools/check-selftest.sh courts/ninth-circuit/court-of-appeals                            # does the checker catch breakage?
```

Typst is invoked as `typst compile --root <court-dir> --font-path fonts --ignore-system-fonts --package-cache-path vendor/typst-packages --input sample=samples/NAME.md typst/main.typ out.pdf`. The font and the markdown package are vendored, so a build never depends on what is installed or on the network, and a missing font is an error.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block (metadata) followed by the markdown body. The template generates everything that is not argument: cover, tables, signature block, certificates, addendum scaffolding.

### Frontmatter

| Field | Required | Type | Feeds |
|---|---|---|---|
| `case_number` | yes | string | Cover top line "No. ...", "9th Cir. Case Number(s)" on every certificate, PDF title. |
| `caption` | yes | list of two sides | Cover title of the case. Each side: `names` (list of strings, one centered line each, inline markdown allowed, e.g. `*et al.*`) and `designation` (string, e.g. `Plaintiffs-Appellants,`). "v." is inserted between the sides. |
| `proceeding` | yes | string | Cover: nature of the proceeding and the court below ("On Appeal from the United States District Court for ..."). Wraps naturally; no line breaks. |
| `district_court_case`, `judge` | no | string | Cover line "D.C. No. ...; judge". Shown only when given. |
| `brief_title` | yes | string | Cover title of the brief (printed in capitals); Form 15 description. |
| `counsel` | yes | list of groups | Cover counsel block (FRAP 32(a)(2)(F)). Each group: `names` (printed as given) and `lines` (italic lines under them: role, firm, address). |
| `phone` | yes | string | Telephone number, appended to the last counsel group (required by FRAP 32(a)(2)(F)). |
| `signature` | yes | map | `signer` (name; printed as `s/ Name` and in capitals, Circuit Rule 25-5(f)), `lines` (italic lines under the signature: title, address, phone, email). Used after the Conclusion and on each certificate. |
| `date` | no | string | Printed under the signature block and as the date on each certificate. |
| `related_cases` | no (default `status: none`) | map | Statement of Related Cases (Form 17): `status` is `none`, `other-briefs`, or `pending`; for `pending`, `cases` is a list of `{number, name, relationship}`. |
| `word_limit_basis` | no (default `standard`) | enum | Which Form 8 box is checked: `standard`, `cross-appeal`, `amicus`, `death-penalty`, `longer-joint`, `longer-multiple`, `longer-response-to-joint`, `court-order` (with `court_order_date`), `motion-to-exceed`. |
| `manual_image_words` | no (default 0) | integer | Words manually counted in visual images (Form 8). |
| `service` | no | map | `certificate: true` adds a Certificate of Service (Form 15 wording, only needed when service is not through ACMS); `unregistered` is a list of `{name, address}`. |
| `authorities` | yes if the body cites any | map | The table of authorities registry; see below. |

Not generated, on purpose: a disclosure statement (Circuit Rule 28-1(c): it is filed separately as Form 34), a colored cover (paper copies only, Circuit Rule 25-5(c)).

### Body

- `# Heading` (level 1) is a section: bold, capitals, centered. Required, in this order: Statement of Jurisdiction, Statement of the Issue(s), Statement of the Case, Summary of Argument, Argument, Conclusion. Optional before them: Introduction. A heading containing "Standard of Review" must exist at some level (a section of its own, or under Argument). The signature block is appended after the Conclusion automatically.
- Sub-headings are numbered automatically; do not type the numbers. Under `# Argument`: level 2 is a centered point heading (I., II.), level 3 is A., level 4 is 1., level 5 is a. Everywhere else: level 2 is A., level 3 is 1., level 4 is a., level 5 is (1). Deeper than level 5 is an error.
- `# Addendum` ends the brief. Everything below it is the addendum (Circuit Rule 28-2.7): it starts its own pages, gets its own table of contents of its level-2 headings, and is numbered Add-1, Add-2, ... It is excluded from the word count.
- **Case names and other emphasis**: write `*Horne v. Flores*`. The template does not guess what a case name is; whatever you italicize is italic (FRAP 32(a)(6)). Do the same for *Id.*, *see*, *supra*.
- **Authorities**: cite with a link whose target is `toa:KEY`, with the full citation as the text:
  `[*Horne v. Flores*, 557 U.S. 433, 447 (2009)](toa:horne)`. Short forms and *Id.* link to the same key: `[*Id.* at 443-44](toa:henson)`. Every link is recorded with the page it starts on. The table of authorities is built from these. A key that is not in `authorities:` stops the build.
  The registry entry names the authority once: `horne: {kind: case, name: "Horne v. Flores", cite: "557 U.S. 433 (2009)"}`. `kind` is `case`, `constitution`, `statute`, `regulation`, `rule` or `other` (the six groups, in that order; cases are alphabetized). `name` is optional (shown first, italic for cases); `cite` is required; `sort` overrides the sort key. An authority cited on 7 or more pages prints "passim". Plain links (`https://...`) print their text only.
- **Footnotes**: `text[^key]` and, anywhere in the file, `[^key]: One paragraph of footnote text.` Footnotes are 14 pt.
- **Block quotations**: `> quoted text`. Indented, single-spaced (FRAP 32(a)(4)).
- **Lists**: ordinary markdown lists work.
- **Text that begins with a markdown marker must be escaped, as in any markdown.** A line starting `90. `, `1) `, `- `, `+ `, `# ` or `> ` is a list, heading or quotation to a markdown parser. To start a paragraph with those characters, escape the marker: `90\. The record shows`, `2\) A pleading`, `\- Nothing`, `\+ Note`. Gate 0 proves nothing is lost either way: an unescaped marker is rendered as the list it is, never dropped.
- Smart punctuation is on: straight quotes become curly, `--` an en dash, `---` an em dash, `...` an ellipsis. Type the characters you want (the em dash, curly quotes) and nothing surprising happens.
- Not supported: tables, images, raw HTML, raw typst (`raw-typst` is off, so a markdown file cannot inject layout code), headings deeper than level 5.

The word count in the certificate is computed from the markdown (everything before `# Addendum`: headings, text, footnotes, quotations; not list markers, footnote reference marks, or generated parts) and is checked against an independent count and against the PDF.

## Decisions

**Markdown: cmarker, not pandoc.** Both were evaluated on the generic sample. `cmarker` (Typst Universe, v0.1.10) renders footnotes, nested headings, block quotes, lists, emphasis, links and escapes in a single `typst compile`, keeps the author's characters exactly, and its output elements (`heading`, `link`, `footnote`, `quote`) are styled by ordinary show rules in the template, so the table of contents, the table of authorities and the numbering fall out of typst's own introspection. `pandoc --to typst` needs a second build step that writes a `.typ` file that is then included, rewrites apostrophes and quotes to straight characters (the text no longer matches the author's), emits links as `#link(...)[...];` with no hook short of a Lua filter, and would still need the TOA marker handled outside typst. cmarker is vendored under `vendor/typst-packages/` so builds are pinned and offline.

**Font: EB Garamond (SIL OFL 1.1), vendored in `fonts/eb-garamond/` with its license.** The exemplar is set in Garamond (`pdffonts`: Garamond, Garamond-Bold, Garamond-Italic), and the FRAP requirement is a proportionally spaced serif face of 14 pt or larger (FRAP 32(a)(5)(A)). EB Garamond is the free Garamond; it has the real italic and small-capital glyphs the point headings use. The checker asserts the embedded font names are `EBGaramond-*` and fails on any other, so a fallback can never go unnoticed.

**No disclosure statement.** The Ninth Circuit moved FRAP 26.1 disclosures out of the brief (Circuit Rule 28-1(c), Rule 26.1-1, Form 34). The exemplar has none either.

**Related-cases and certificates use the court's own forms.** Form 17 and Form 8 wording is reproduced, with the selected box drawn as a vector shape (no font glyph to fall back on). Circuit Rule 32-1(e) requires Form 8; the exemplar's own paragraph is the older FRAP-style certificate.

**Statement of related cases before the certificate of compliance.** Circuit Rule 28-2.6 says the statement goes "on the last page of its initial brief"; the exemplar puts it immediately before the certificate of compliance, so the certificates share the final pages. The template follows the exemplar.

## Known limits

- The cover must fit on one page. The template shrinks the space between the cover's parts to make it fit (never the type) and refuses to build if it still cannot; a very long counsel or party list must be shortened. The generic sample shows the densest cover that fits.
- A table of contents entry, table of authorities entry or certificate is never split across a page, so a page can end with white space. Short last paragraphs are kept with the signature block so it never stands alone.
- A citation that begins at the end of one page and ends on the next is listed on the page it begins on.
- Cover color, paper-copy binding, and the colored addendum separator page apply to paper copies only and are not produced (rules.md, CA9-COVER-008).
- Gate 2 (visual review) is recorded in `reviews/`; open-choice differences from the exemplar that were accepted are listed there with the reason.
