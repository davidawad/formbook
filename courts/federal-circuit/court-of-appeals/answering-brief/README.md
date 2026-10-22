# Federal Circuit: answering brief (brief for the appellee)

Doc type: `answering-brief`. Court: `cafc` (Court of Appeals for the Federal Circuit).
Status: full-depth template built from one filed exemplar; typst, latex and docx render the sample to 15 pages each, on the shared cross-engine layout model, and the folder gates Gate 4 CROSS-ENGINE (`eval.yaml`: `params.cross_engine: gate`; fb-595.54.6, see "Cross-engine layout" below).
Not a court-level `court.json` status change: this folder does not set `status` (only David does).

## Layout

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief.pdf` | Brief for Appellee, Director of the USPTO, *In re Ablynx N.V., Sanofi*, No. 26-1333, filed 2026-08-14 (38 pp.). Provenance in `usage/SOURCE.md`. |
| `usage/INPUT-answering-brief.md` | Markdown transcription (front matter + a portion of the body, Statement of the Issue through Conclusion, with the signature and both certificates). |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md` (14 pages). |
| `usage/OVERLAY-ablynx-answering-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-appeals/answering-brief ablynx-answering-brief` (red = our render, blue = exemplar). |
| `typst/main.typ` | Entry point; reads `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/cafc-answering-brief.typ` | Template `cafc-brief(meta, md)`. Structure copied from `courts/ninth-circuit/court-of-appeals/typst/ca9-brief.typ`; numbers and forms are the Federal Circuit's. |

## Governing rules

Each entry: the rule, the primary text I could read, and what is and is not verified.

| Rule | What it requires here | Source read | Verified |
|---|---|---|---|
| FRAP 32(a)(5)(A) | Proportionally spaced serif face, 14-point or larger. Template: EB Garamond 14 pt everywhere. | Cornell LII, `law.cornell.edu/rules/frap/rule_32`, fetched 2026-10-14 | Text yes; not checked against the current official FRAP PDF |
| FRAP 32(a)(6) | Plain roman style; case names italicized. | same | same |
| FRAP 32(a)(4) | Margins of at least one inch (template: 1 in). Double spacing for text, single for headings, quotations, footnotes. | same (the LII text of (a)(4) was not captured; the margin and spacing are from the exemplar and standard practice) | Partial: spacing matched to exemplar, margin from exemplar |
| Fed. Cir. R. 32(b) | Principal brief type-volume limit: 14,000 words (30-page safe harbor). Template: `word-limit = 14000`. The certificate of compliance cites "Fed. Cir. R. 32(b)". | The exemplar's own certificate cites Fed. Cir. R. 32(b). The 14,000 figure comes from a third-party mirror (courtrules.net, Rule 32). | Citation: yes (exemplar). Number: **not verified** at cafc.uscourts.gov, which returned HTTP 404 and a bot challenge to my requests. |
| Fed. Cir. R. 47.4 / Form 9 (Certificate of Interest) | Filed separately with entry of appearance; not generated in the brief. | Not read | **Not verified**; omitted by design, not in the sample |
| Fed. Cir. R. 47.5 (Statement of Related Cases) | Text is supplied by the sample, not generated; the exemplar has the statement on the page before the body. | Exemplar | Exemplar only |
| Pagination (exemplar) | Front matter in lower-case roman (i, ii, iii); body in Arabic from 1; cover unnumbered. | Exemplar | Exemplar only |

Not verified: whether any Federal Circuit rule amendments after the mirror's text changed the word limit or the cover contents. Re-check against the official rules before relying on the 14,000 figure.

## What the overlay shows

The overlay pairs each sample page with the exemplar page sharing the most words. The sample is a portion of a 38-page brief, so most pages overlap only partly (word-overlap 33–92%, see `OVERLAY-ablynx-answering-brief.txt`). The cover (92%), the representative-claim page (88%) and the Statement of the Issue (84%) line up closely. Red-only text is the sample's transcription beyond the exemplar's words; blue-only text is exemplar content the sample does not reproduce (the omitted Statement of the Case, Argument B.2–B.3, the chart and figures).

Measured line pitch on a body page: exemplar 32.2 pt, sample 32.1 pt (body leading `0.99em` with 14 pt type). The first render used `0.94em` and gave 31.4 pt; I changed it to match the exemplar.

## Pages reviewed (Gate 2 record)

All 14 rendered pages were rendered at 60 dpi and looked at, in their final state (2026-10-16).

| Page | Content | Result |
|---|---|---|
| 1 | Cover (case number, caption, proceeding, title, counsel, date) | Fits one page. Counsel lines that wrap now hang under their own indent (fixed 2026-10-16). |
| 2 | Representative claim (unnumbered) | Fed. Cir. R. 32(a)(3); single-spaced; added 2026-10-16. |
| 3 | Table of Contents (i) | Entries, dot leaders, page numbers match the body. |
| 4 | Table of Authorities (ii) | Cases, Statutes groups. Fallaux shows "2, 4, 6". |
| 5 | Statement of Related Cases (iii) | Heading and paragraphs; no defects. |
| 6–12 | Body pp. 1–7 | Numbered headings (I.–V., A., B., 1.), footnotes at 14 pt, block of bullets, signature block kept with the Conclusion. |
| 13 | Certificate of Compliance (body p. 8) | Word count (1,330, computed from the markdown) and the FRAP 32(a)(5)–(6) sentence. |
| 14 | Certificate of Service (body p. 9) | Generic CM/ECF wording (see gaps). |

## Known gaps (not defects of this template; recorded so they are not missed)

- **Portion, not the whole brief.** The sample transcribes the Statement of the Issue, the Statement of the Case (sections A and B, first paragraphs), the Summary, Argument standard of review and B.1 (with its bullets), and the Conclusion. The Argument after B.1, the Statement of the Case's chart, and the figures are omitted. The sample is 13 pages; the exemplar is 38.
- **No figures.** cmarker does not render images or charts; the exemplar's timeline figures and filed chart are not reproduced.
- **No addendum.** The Federal Circuit's addendum (if any) is not generated; the ca9 addendum scaffold was dropped.
- **No CM/ECF header.** The "Case: 26-1333 Document: 23 Page: N Filed: date" line at the top of each filed page is generated by the e-filing system and is not reproduced.
- **Certificate of service wording** is a convention: the exemplar has no certificate of service, and the sample includes one with generic CM/ECF language. Its rule citation is not verified.
- **Certificate of Interest (Form 9)** is not generated. Correct for this filer: Fed. Cir. R. 47.4(b) exempts the United States and its officers or agencies (verified 2026-10-16, see below). A private appellee would need one; the template does not produce it.
- **Signature.** The certificate reuses the sample's signature lines; the exemplar's certificate lists only the signer's title and office. The template prints `certificate_lines` separately so the two can differ.
- **Statement of Related Cases** is text supplied by the sample; the template does not generate it from a form.
- **Word count** is computed from the markdown body (headings, text, footnotes, quotations; not list markers or footnote marks), not from a word processor. The certificate names `word_counter` if the frontmatter gives one; the sample no longer does (it said "Microsoft Word", which the render does not use), so the certificate reads "the word-processing system used to prepare it".
- **Exemplar text layer** is from a paper-capture producer; pdftotext extracts it, but the transcription was checked by eye against the page images, not against an OCR-free source.
- **Second exemplar** is not included; the brief asked for one exemplar per doc type and the ca9 two-filer rule is a court-level check, not this folder's.
- The template's `word-limit` and certificate wording depend on the unverified Fed. Cir. R. 32(b) figure above.

## Rendering

Typst 0.15.0, EB Garamond (vendored in `fonts/eb-garamond/`), cmarker 0.1.10 (vendored in `vendor/typst-packages/`). `tools/render.sh` runs with `--ignore-system-fonts`; the build emitted no warnings.

## Engines

The typst template is the reference. The LaTeX and docx engines are built from the same markdown contract (`docs/EVAL-LOOP.md`, "Engines").

| Engine | Files | Output (`usage/`) | Pages |
|---|---|---|---|
| typst (reference) | `typst/` | `OUTPUT-answering-brief.typst.pdf` | 15 |
| latex | `latex/template.tex`, `latex/cafc.lua` (stock pdflatex, newtx Times) | `OUTPUT-answering-brief.latex.pdf` | 15 |
| docx | `docx/reference.docx` (`docx/build-reference.sh`), `docx/cafc-docx.lua`, `docx/render.sh`, `docx/pagemap.awk`, `docx/footer.xml` | `OUTPUT-answering-brief.docx` and `.docx.pdf` | 15 |

The paragraphs below, down to "Pages viewed", describe the engines before the cross-engine port and are kept as history; "Cross-engine layout" at the end of this file is the current state.

**Matches the typst layout:** 14 pt EB Garamond, double spacing at the typst pitch (32.13 pt, 0.99em leading); 1 in margins; the cover; contents and authorities with page numbers; the Roman section headings (I. to V.) hanging at the margin with the A./1. sub-headings; the statement of related cases; the certificate of compliance with the signature under it; the certificate of service; the footers (roman then arabic).

**Differs from the typst layout:**

- One page longer in both engines (14 against 13). The extra page comes from the body's line breaks, so the sub-headings fall a few lines later than in typst.
- latex: the signature block is kept with the last paragraph of the conclusion, so the conclusion's text and the signature are on consecutive pages, but the signature block itself starts a page of its own (page 9). Typst keeps the tail of the brief with the signature on the same page.
- docx: the contents and authorities are static text, numbered from the LibreOffice render (see the opening brief's Engines note for the limits: TA fields, Word pagination, `Id.` citations).
- docx word counts use pandoc's tokenization, so they can differ from typst by a few words (opening brief: 2,481 against typst's 2,484).

**docx items not verified:** not opened in Word; converted with LibreOffice only.

**Status:** latex render ok; docx render ok. No gate was run (no `checks.yaml` or `check.sh` for this court in this snapshot). The page review is visual.

**Pages viewed:** all 14 pages of the latex render and all 14 of the docx render, at 30 to 40 dpi, in the final state.


## Verification pass 2026-10-16 (fb-595.26.13)

- Rendered: `sh tools/render.sh courts/federal-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md`, exit 0, no typst warnings. Before the fixes it gave 13 pages (same as the committed PDF); after them, 14. Overlay rerun, exit 0: cover 92%, claim page ↔ filed p. 2 88%, front matter 33–73%, body 41–89%, certificates ↔ filed pp. 37–38.
- Viewed: all 13 pages before the fixes and all 14 after, at 60 dpi; the overlay pages at 40 dpi; the exemplar's pages 1 and 2 against ours.
- Fixed:
  - Missing representative claim (tier 1). Fed. Cir. R. 32(a)(3) (Rules of Practice, Oct. 6, 2026 compilation, p. 145, fetched 2026-10-16): when the language of a patent or application is at issue, each principal brief carries exemplary claims inside the front cover or right after it. The exemplar has it on p. 2. New optional `patent_claims` / `patent_claims_heading` frontmatter, rendered on unnumbered single-spaced page(s) after the cover (typst and latex); the sample now transcribes claim 51 and "Appx151." (the subscript n of "(X)n" is set as plain text).
  - Certificate of compliance said the count was "calculated by Microsoft Word"; the number is computed by the template. Removed `word_counter` from the sample, so the default wording is used.
  - Cover: a counsel line too long for the column ("Attorneys for the Director of the U.S. Patent and Trademark Office") wrapped to the column edge, out of its indent. Each line is now its own block, so it wraps under its indent.
- Verified at the primary source (Rules of Practice, Oct. 6, 2026, fetched 2026-10-16 from cafc.uscourts.gov): Fed. Cir. R. 32(b)(1), 14,000 words for a principal brief (p. 145); Fed. Cir. R. 47.4(b), the United States and its officers or agencies are exempt from the certificate of interest (p. 199). The "Not verified" notes on these two rows above are superseded.
- LaTeX re-rendered: 15 pages (the claim page added; the body still runs one page longer than typst). docx not re-rendered (no LibreOffice): the committed `.docx`/`.docx.pdf` predate the claim page and still print "as calculated by Microsoft Word"; `docx/cafc-docx.lua` keeps an "Is/" signature prefix in a code path this sample does not reach (the committed docx PDF has no "Is/").
- Remaining gaps: as under Known gaps; the latex cover still wraps the long counsel line flush left.

## DOCX font and layout fixes (2026-10-21, fb-595.59)

The docx engine moves from EB Garamond to Times New Roman, the face the typst template declares (DEF-FONT-002). The type-volume certificate's boxes are bordered runs ("X" or three no-break spaces) in the body face, as ca9.lua draws them, not DejaVu Sans ballot-box glyphs. `check.sh --engine docx` is green.

## Cross-engine layout (2026-10-22, fb-595.54.6)

The three engines now run on the shared layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; `docs/EVAL-LOOP.md`, "Adopting the reference breaker") and break every line and page alike: `check.sh --engine latex|docx` prints XENG-001..003 PASS (before: latex 13 against 15 pages, 66.3 % of lines alike; docx 13 against 14, 41.1 %), and `eval.yaml` gates it.

- Pitches from the exemplar (this README, "What the overlay shows"): 32.2 pt for the double-spaced text, 16.1 pt for everything single-spaced (Word's single line of 14 pt Times, as the exemplar's tables and certificate measure). The typst template had drifted to a 26.6 pt body pitch when the face changed to Times New Roman (its 0.99em leading had been set for EB Garamond's line box), so the brief is now 15 pages (was 13): the body runs pp. 1 to 8, the certificates pp. 9 and 10.
- Spaces between blocks in pt (the em values before, at 14 pt); contents and authorities as `listing-row` rows with a 36 pt / 56 pt page column; footnote marks at 58 %; the list bullet in a half-inch box; the right half of the cover and the signature blocks starts at the middle of the text width (before, typst's `pad(left: 50%)` inside `align` measured half of the block's own width, so the signature block moved with its longest line).
- No orphan where a footnote moves a line on (typst `no-footnote-orphan`): typst keeps a paragraph's first two lines together but, when the second carries a footnote that does not fit under it, moved that line on and left the first alone; Word and LaTeX move the paragraph. The typst template now does the same (body p. 5 ends after the B. section, "Appellants concede" starts p. 6).
- latex and docx are rewritten on the model: `latex/cafc.lua` builds the cover, tables, signature and certificates as the typst template does, `latex/template.tex` holds the macros (`\xe@lines`, `\addvspace`, `\xe@row`); the docx is built by `docx/render.sh` in two passes (pass 1 with placeholders, the page map of its LibreOffice PDF read by `docx/pagemap.awk`, pass 2 must give the same map), on a reference from `lib/docx/xengine-reference.sh`. Word count block by block in every engine (1,330).
- Pages viewed (60 dpi, all 15 of the typst render, all 15 of latex and docx side by side against it, 2026-10-22): no defect found. Positions differ only on the cover (the gaps between its parts: typst 14 pt plus block spacing, latex and docx 14 pt) and by under 2.5 pt elsewhere (footnote marks, bullets).
