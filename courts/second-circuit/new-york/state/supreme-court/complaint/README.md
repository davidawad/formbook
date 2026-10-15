# Supreme Court of the State of New York: verified complaint

Doc type `complaint` for court `nysupct` (CourtListener id `nysupct`). Layout follows the new one-folder-per-doc-type convention: everything for this doc type lives in this folder. The court root (`../court.json`) holds only the court record; `status` stays `todo` (set by David only).

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-people-v-trump-452564-2022-complaint.pdf` | The real filed verified complaint (222 pp, text layer). Provenance: `exemplars/SOURCE.md`. |
| `samples/INPUT-people-v-trump.md` | Markdown transcription of a portion of the exemplar (caption metadata, table of contents, introduction, part of the facts, first cause of action, prayer, signature, verification). |
| `samples/OUTPUT-people-v-trump.pdf` | Our render (9 pages). |
| `samples/OVERLAY-people-v-trump.pdf`, `.txt` | Red/blue overlay of our render on the exemplar, and the page map. |
| `typst/main.typ` | Entry point: reads the sample named by `--input sample=...`, calls the template. |
| `typst/nysupct-complaint.typ` | The template. Content-agnostic; every number is a parameter at the top and traces to a rule or a stated convention. |

## Governing rules

Verified 2026-10-14 (date fetched). "Primary" means the text came from the official source; "mirror" means it came from a non-official copy because the official host refused the request.

| ID | Rule | Requirement used | Source | Status |
|---|---|---|---|---|
| CPLR 2101(a) | Form of papers | 11 x 8.5 in. paper; legible, black ink; signer's name printed beneath each signature; type no smaller than 10-point for complaints (12-point for summonses) | https://www.nysenate.gov/legislation/laws/CVP/2101 | primary |
| CPLR 2101(c) | Caption | Summonses and complaints list the names of all parties in the title | https://www.nysenate.gov/legislation/laws/CVP/2101 | primary |
| 22 NYCRR 202.5(a)(1) | Form of papers, cover and first page | Index number and county of venue on the first page, to the right of the caption; judge's name only if one is assigned (not used here); at least double spacing; margins at least one inch; print no smaller than 12-point; footnotes no smaller than 10-point | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-202.5 | mirror (nycourts.gov returned HTTP 403 to the fetch; re-check the official text before landing) |
| 22 NYCRR 202.8-b(a) | Word limits | Limits apply to affidavits, affirmations, briefs and memoranda of law (and replies). Summonses, complaints and verified complaints are not listed, so no word-count certificate is generated | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-202.8-b | mirror (same reason) |
| CPLR 3020(a) | Verification of a complaint | A verification is a statement subscribed and affirmed under the penalties of perjury under CPLR 2106, that the pleading is true to the deponent's knowledge, except as to matters alleged on information and belief | https://www.nysenate.gov/legislation/laws/CVP/3020 | primary |
| CPLR 3020(d)(3) | Who may verify | An attorney or agent may verify when the party is a foreign corporation or outside the attorney's county, when the claim rests on a money-only instrument held by the agent or attorney, or when the material allegations are within the agent's or attorney's personal knowledge | https://www.nysenate.gov/legislation/laws/CVP/3020 | primary |
| CPLR 2106 | Affirmation in place of affidavit | The affirmation is made under the penalties of perjury under the laws of New York, "which may include a fine or imprisonment", and notes that the document may be filed in a court of law | https://www.nysenate.gov/legislation/laws/CVP/2106 | primary, but the fetch returned a summary; the template's wording is a paraphrase (see Known gaps) |
| 22 NYCRR 202.5-b | E-filing | Filings are PDF (the exemplar carries the NYSCEF legend under 202.5-b(d)(3)(i)). The template produces a text-based PDF; the NYSCEF legend is not generated | (not fetched) | not verified |

Conventions (not rules; each is named in the template):

- **Font.** Face required: none. 22 NYCRR 202.5(a) and CPLR 2101(a) set a minimum point size and name no typeface, so the template keeps EB Garamond at 12 pt (`fonts/eb-garamond`, the no-face default in `docs/FONTS.md`). Not a Times New Roman substitute: the exemplar is set in Times New Roman, which is a convention, not a rule. 12 pt meets 202.5(a). Typeface is visual-only against the exemplar.
- **Spacing.** Body leading is tuned so the baseline pitch matches the exemplar's: measured 27.6 pt from both our render and the exemplar (double spacing at 12 pt). The paragraph spacing equals the body leading, so each numbered paragraph advances one line, as in the exemplar.
- **Margins.** One inch on every side (202.5(a)); the exemplar's left and right text edges fall at the same 72 pt and 540 pt positions. These are the rule values, not coordinates measured off the exemplar.
- **Caption.** Court and county on the first lines; a bordered party box on the left with `-against-` between the sides; the index number and the title on the right (exemplar layout, generated from the frontmatter).
- **Headings.** Level 1 is centred bold capitals; level 2 is left bold; level 3 is bold italic. The author types the numbering (I., A., 1.), as the exemplar does.
- **Table of contents.** Generated from levels 1-2 when `toc: true`.
- **Signature block.** Dated line, "Respectfully submitted," the firm lines, "By:" over a rule, and the signer's printed name beneath (CPLR 2101(a)).
- **Verification.** A separate page, under the heading VERIFICATION, with the verifier and capacity from the frontmatter.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body. The template generates the caption, table of contents, signature block, "To:" service list, and verification.

| Field | Required | Feeds |
|---|---|---|
| `county` | yes | Second caption line ("COUNTY OF ...") |
| `index_no` | yes | Right of the caption, top line |
| `parties` | yes | List of `{names, designation}` groups; the template puts `-against-` between groups. `names` is a list of lines; inline markdown allowed |
| `title` | yes | Right of the caption (bold); verification wording |
| `toc` | no (default false) | Table of contents on the page after the caption |
| `date` | yes | "Dated:" under the body and on the verification |
| `signature` | yes | `firm` (optional list above "By:"), `signer` (printed beneath the rule), `lines` (italic lines under the name) |
| `to` | no | List of `{names, lines}` service-list groups after the signature |
| `verification` | yes | `verifier` (name), `capacity` (who the verifier is and why they may verify, rendered after the name) |

Body: `# I. HEADING` (level 1, centred), `## A. Heading` (level 2), `### ...` (level 3). Numbered paragraphs are typed with the number escaped (`1\.`), which keeps them as paragraphs. Case names are italic (`*People v. ...*`). Footnotes use `[^key]` with `[^key]: text` anywhere in the file.

## Build and check

From the repo root (toolchain first: `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/second-circuit/new-york/state/supreme-court/complaint samples/INPUT-people-v-trump.md
sh tools/overlay.sh courts/second-circuit/new-york/state/supreme-court/complaint people-v-trump
```

Output names are the tools' own: `samples/OUTPUT-people-v-trump.pdf`, `samples/OVERLAY-people-v-trump.pdf` and `.txt`. The brief's shorter names (`<id>.pdf`, `<id>-overlay.pdf`) would need a change to `tools/`, which this box does not edit.

Typst is invoked with `--font-path fonts --ignore-system-fonts`. A missing font is an error, and any typst warning fails the render (`tools/render.sh` enforces this).

## What the overlay shows

Red is our render; blue is the exemplar page the tool paired with it (best word overlap, page by page); black is where both agree. The overlay compares the layout of our typeset page against a filed page that carries the same words. It is a diagnostic, not a score.

Pairings from `samples/OVERLAY-people-v-trump.txt`:

| Our page | Paired exemplar page | Word overlap | Note |
|---|---|---|---|
| 1 | 5 | 42.1% | Caption page, paired with the summons caption (the same caption text) |
| 2 | 8 | 73.7% | Introduction |
| 3 | 9 | 73.6% | Introduction, footnotes |
| 4 | 10 | 56.9% | Facts (section A) |
| 5 | 11 | 40.3% | Facts, Causes of Action |
| 6 | 206 | 71.0% | First cause of action |
| 7 | 220 | 67.0% | Prayer |
| 8 | 221 | 36.6% | Prayer, signature |
| 9 | 222 | 37.5% | Verification |

## Review record (Gate 2)

Every page of `OUTPUT-people-v-trump.pdf` was rendered at 60 dpi and looked at: 9 of 9 reviewed. The first pass found three defects, all fixed in the template:

1. Caption: the court line and the county line shared a row. Cause: `align` inside a code block joined inline. Fix: each line wrapped in a block.
2. Body: paragraphs overlapped (line pitch ran at zero or negative gap). Cause: paragraph spacing set to a negative value. Fix: paragraph spacing equal to the body leading (1.65 em), so the paragraph gap is one line, matching the exemplar.
3. Signature: the signer's name ran into the firm line. Fix: line break after the name.

A fourth point was also corrected: the first paragraph after a heading lost its first-line indent (typst's default). Fixed with `first-line-indent: (amount: ..., all: true)`.

A fifth change replaced the signature and service-list manual line breaks with a stacked layout, so the template has no forced line breaks. That change touches only the signature and service blocks; pages 8 and 9 were re-rendered and looked at after it, and pages 1-7 carry no change from it.

After the fixes, all 9 pages were re-rendered and looked at again (the final render has 9 pages; 9 of 9 reviewed).

## Known gaps

- **Summons not generated.** The exemplar's pp. 1-5 are the summons with the service list. This template produces the complaint only.
- **Verification wording.** The CPLR 2106 fetch returned a summary, not the statutory text. The affirmation in the template paraphrases it. Check the form against the official text before relying on it.
- **Official rule text.** 22 NYCRR 202.5 and 202.8-b are cited from a Cornell LII mirror because nycourts.gov returned HTTP 403. Re-check the margins, the 10-pt footnote floor and the word-limit list against the official text.
- **E-filing.** 202.5-b (NYSCEF) formatting is not implemented beyond producing a text PDF. The NYSCEF legend is not generated.
- **Caption placement.** The exemplar puts the table of contents on its own pages after the summons. The template puts it on the page after the caption, which is a convention; the exemplar's layout is not copied.
- **Typeface.** EB Garamond at 12 pt, not Times New Roman. The rules name no face, so no vendored substitute applies (`docs/FONTS.md`: no face named → EB Garamond). Visible difference from the exemplar, which is a convention and not a requirement.
- **Sample coverage.** The sample is a portion of the 222-page filing (introduction, part of section A, the first cause of action, prayer, signature, verification). Parties (section II), jurisdiction (section III), most of section IV, and the other causes of action are not transcribed. The prayer's missing letter H is in the exemplar itself and is kept as it appears there.
- **Index number.** The exemplar copy reads "INDEX NO. UNASSIGNED". The index no. 452564/2022 appears in a secondary source only (see `exemplars/SOURCE.md`).

## Exemplar search (for the record)

Searched (2026-10-14): NYSCEF and nycourts.gov form pages (blank forms only); Justia form pages (blank); a nycourts.gov opinion referencing a 2022 verified complaint (an opinion, not the complaint); the NY Attorney General site (`ag.ny.gov/sites/default/files/tto_complaint.pdf`, found and used). CourtListener was not searched directly: only general web search was used, so a RECAP or other CourtListener copy of a New York Supreme Court complaint may exist and was not checked. The exemplar is a public filing by the NY Attorney General.

## Engines

Three engines per doc type: `typst/` (primary), `docx/` and `latex/` (not built here; see the Engines section of the PR). The docx engine is `docx/build-reference.sh` (builds `docx/reference.docx` from pandoc 3.12's default reference) plus `docx/nysupct-complaint.lua` (caption table, TOC field, signature block, service list, verification page). Render: `sh tools/render.sh --engine docx courts/second-circuit/new-york/state/supreme-court/complaint samples/INPUT-people-v-trump.md`.

- **Matches the typst form.** Letter paper; 1 in margins (22 NYCRR 202.5(a)); EB Garamond 12 pt body (no face named by the rules); double line spacing (`w:line="480"`, auto); 0.5 in first-line indent; footnotes 10 pt single-spaced; centred bold level-1 headings; caption with the bordered party box and `-against-`; centred page number in the footer; verification on its own page.
- **Differs.** Word's "double" is two times the font's line height, not the typst leading of 1.65 em, so the line pitch will not equal the typst pitch. The caption and signature blocks are tables, whose borders Word and LibreOffice draw slightly differently. The TOC is a TOC field: its cached entries are the headings, without page numbers, until the field is updated.
- **Generated.** `samples/OUTPUT-people-v-trump.docx` (validated: `unzip -tq` passes; all 17 XML parts pass `xmllint --noout`). Not generated, as in typst: the summons and the NYSCEF legend.
- **BLOCKED (docx.pdf gates).** LibreOffice (`soffice`) is not installed on the box that built this engine, so no `samples/OUTPUT-people-v-trump.docx.pdf` exists and no page was rendered or reviewed. Gates 0 and 1 on the docx PDF cannot run here.
- **BLOCKED (TOC page numbers).** The TOC check cannot pass by construction until a LibreOffice field update (or a Word update with `w:updateFields`) fills the page numbers; the cached result carries no pages.
