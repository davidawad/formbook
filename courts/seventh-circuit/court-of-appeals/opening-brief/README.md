# Seventh Circuit: appellant's opening brief

Court: `ca7` (U.S. Court of Appeals for the Seventh Circuit). Doc type: `opening-brief`. One self-contained folder per doc type; the court-root `typst/` and `usage/` (ca9's opening brief lives there) are not touched.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: `usage/FILED-EXAMPLE-opening-brief.pdf` (see `usage/SOURCE.md`) |
| Sample | `usage/INPUT-opening-brief.md` (cover, counsel, TOC, TOA, body excerpt, conclusion, signature, certificates) |
| Typeface | None named by the rules (FRAP 32(a)(5)(A); Cir. R. 32(b)). Font: Times New Roman (vendored; newtx in latex) in all three engines since fb-595.54.1 (the docx had stayed on EB Garamond and failed DEF-FONT-002). Earlier: EB Garamond (fonts pass, 2026-10-15). `pdffonts` then: only `EBGaramond` Regular, Bold, Italic, all embedded. |
| Render | ok (re-run 2026-10-16, fb-595.26.7): `sh tools/render.sh courts/seventh-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md` gives 14 pages, vendored fonts only, no typst warnings |
| Overlay | ok (re-run 2026-10-16, fb-595.26.7): the filed PDF is in `usage/`; `sh tools/overlay.sh courts/seventh-circuit/court-of-appeals/opening-brief torres-opening-brief` exits 0 and rewrites `usage/OVERLAY-torres-opening-brief.pdf` and `.txt` |
| Pages reviewed | 14 of 14 in the verification pass, 2026-10-16 (`pdftoppm -r 60`, every PNG viewed; see "Verification pass") |

Build and check, from the repo root (typst 0.15.0; `PATH` must include the micromamba env):

```sh
sh tools/render.sh courts/seventh-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/overlay.sh courts/seventh-circuit/court-of-appeals/opening-brief torres-opening-brief
```

## Governing rules (primary sources)

Read 2026-10-14 from the Seventh Circuit's own rules PDF, `https://www.ca7.uscourts.gov/assets/pdf/rules.pdf` (the document states it is "current as of December 1, 2025"). It contains both the Federal Rules of Appellate Procedure and the Circuit Rules. The text was extracted with `pdftotext` from a local copy of the PDF.

| Ref | Requirement | How the template meets it |
|---|---|---|
| CA7-FORM-001 — FRAP 32(a)(4); Cir. R. 32(b) | Double-spaced text; margins at least 1 inch on all sides; quotations more than two lines may be single-spaced; headings and footnotes single-spaced. Cir. R. 32(b): proportionally spaced type 12 points or larger in the body, 11 points or larger in footnotes. | Body 14 pt (`type-size`), double leading; 1 in margins; block quotations and footnotes single-spaced; footnotes 12 pt (`footnote-size`). The 14 pt body satisfies both the FRAP 14-point default and the 12-point circuit minimum. |
| CA7-FORM-002 — FRAP 32(a)(5)(A) and (6) | Proportionally spaced face with serifs (sans-serif allowed only in headings and captions), 14 pt or larger, roman type style; italics or bold for emphasis; case names italicized. | EB Garamond, vendored in `fonts/eb-garamond/`; `hyphenate: false`; `fallback: false`; case names italic from the markdown. |
| CA7-FORM-003 — Cir. R. 32(c); FRAP 32(a)(7)(B)(i) | Principal brief: no more than 14,000 words (circuit limit), counting headings, footnotes and quotations; FRAP 32(f) items excluded. | The template counts words from the markdown before `# Addendum` and panics above 14,000. |
| CA7-COVER-001 — FRAP 32(a)(2)(A)-(F) | Front cover: case number centered at top; name of the court; title of the case; nature of the proceeding and the court below; title of the brief identifying the party; name, office address and telephone of counsel. | Case number, court name, caption, proceeding, district court number and judge, "Brief of Appellant", counsel block with address and phone. Counsel is in a two-column grid so the cover fits one page. |
| CA7-COVER-002 — FRAP 32(a)(2) | The cover of an appellant's brief must be blue. | Not produced: paper-copy color (same treatment as ca9's cover color). See "Known gaps". |
| CA7-CONT-001 — FRAP 28(a)(2)-(3) | Table of contents with page references; table of authorities (cases alphabetical, then statutes and other authorities) with page references. | Generated from headings (`outline`) and from `toa:` links (`toa-section`), with "passim" at 7 pages or more. |
| CA7-CONT-010 — FRAP 28(a)(4)-(9); Cir. R. 28(a) | Order: jurisdictional statement (basis of jurisdiction in both courts, timeliness dates, finality); statement of the issues; statement of the case; summary of argument; argument with a standard of review per issue; short conclusion. The jurisdictional statement must give the dates in Cir. R. 28(a)(2)(i)-(iv). | Markdown headings in that order. Section headings are bold capitals, centered. Sub-headings use I. / A. / 1. / a. at every level, in the Statement and in the Argument. |
| CA7-CERT-001 — FRAP 32(g)(1)-(2), Form 6; Cir. R. 32(c) | Certificate of compliance: word count (excluding FRAP 32(f) items) and typeface statement, in the Form 6 wording. | `certificate-of-compliance`: the word count is computed from the markdown; the typeface sentence names the software (`sys.version`) and the font and size from the parameters. |
| CA7-CERT-002 — FRAP 32(a)(5)-(6); Cir. R. 32(b) | Typeface and type-style statement. | Included in CA7-CERT-001. |
| CA7-CERT-003 — FRAP 25(d) | Proof of service statement, when not served through the court's electronic filing system. | `certificate-of-service`, only when `service.certificate: true`. The sample uses CM/ECF service, as the exemplar does. |
| FRAP 28(f) | Statutes, rules and regulations the decision requires may be set out in an addendum at the end. | `# Addendum` in the markdown starts a separate addendum with its own table of contents, numbered Add-1, Add-2 (addendum excluded from the word count). Not used by the sample. |

Attorney disclosure: Cir. R. 26.1(a) requires a separate Rule 26.1 disclosure from each attorney, filed in addition to the brief (Cir. R. 26.1(c): by 21 days after docketing, or earlier). The exemplar places those forms at pages i-iii, as three fillable, text-free pages. The template does not generate them; see "Known gaps".

## Exemplar findings (what the rules leave open)

The exemplar is 55 pages: a cover, three attorney disclosure forms, a table of contents, a table of authorities, the brief, certificates, and a short appendix. Choices the rules leave open that the template follows the exemplar on:

- Body type size: the exemplar uses 14 pt Times New Roman (its line pitch is 32.16 pt, which is 14 pt double-spaced). The template uses 14 pt EB Garamond to match, which is within both rules.
- Heading scheme: the exemplar numbers its Statement of the Case the same way as its Argument (I. / A. / 1.). The template does the same.
- Certificates: the exemplar gives the certificate of compliance and the certificate of filing and service their own pages. The template lets the certificate of service follow the certificate of compliance on the same page, to hold the sample to the 8-14 page target. The rules do not require separate pages.

## Visual review (Gate 2)

Every page of the 14-page sample was rendered with `pdftoppm -r 60` and viewed in strips. Findings and what was done:

- Cover: fits one page; the case number, caption, and counsel block are all on it. The counsel block was made two-column and the emails were removed from the cover to fit the page. The firm name wraps ("ARNOLD & PORTER KAYE / SCHOLER LLP") in the narrow column; since 2026-10-16 the wrapped part keeps the address-line indent.
- TOC: correct entries, page numbers, and dot leaders. The Argument's point headings sit at the margin, as in the exemplar.
- TOA: groups in order, page lists correct, "Page(s)" heading correct.
- Body: double-spaced, single-spaced block quotations and headings, footnote 1 at 12 pt, no widows or orphans on page 1 or in the signature block.
- Signature block: "Respectfully submitted," then the s/ line, the signer's name in capitals, firm, and address. Date printed under it.
- Certificates: the compliance certificate and the certificate of service share page 10 (as described above); the word count shown (1,871) is the count of this partial sample, not the 6,881 words of the filed brief.

Open tier-2 items (left open, not papered over):
- Argument point headings are left-aligned, not centered as in the exemplar's outline. Accepted: the rules do not require either.
- The overlay pairs each sample page with the exemplar page sharing the most words (`-overlay.txt`). Word overlap runs from 30% to 99%; the cover (p.1 vs filed p.1, 92.8%) and the Summary of Argument (p.5 vs filed p.11, 99.0%) line up best. The sample pages pair with filed pages 1-40 in order, but the filed pages hold the appendix-free brief only in part, so the low scores are expected. This is a diagnostic, not a score.

## Verification pass 2026-10-16 (fb-595.26.7)

- Rendered: `sh tools/render.sh ... usage/INPUT-opening-brief.md`, exit 0, no typst warnings, 14 pages (the committed OUTPUT was also 14 pages; no stale page count). Re-rendered after each fix.
- Viewed: all 14 pages at `pdftoppm -r 60`, one PNG at a time; pages 1, 2 and 9 again after the fixes (the other 11 pages are text-identical to the first render, checked page by page with `pdftotext -layout`). Exemplar page 1 compared with our cover. All 14 overlay pages viewed at `-r 40`.
- Overlay: regenerated (the exemplar is now in `usage/`). Pairing unchanged: cover 92.8% (filed p.1), Summary of Argument 99.0% (filed p.11), other pages 30-70% because the sample is an excerpt. Margins and the text block coincide with the filed pages; the differences are the face (EB Garamond vs Times New Roman) and omitted text.
- Fixed in `typst/ca7-opening-brief.typ`:
  - TOC: the page number now has its own column (`toc-page-col`), so a title whose last line is full can no longer push the number onto a line by itself (was: entry I.B, page "3" stranded under the leaders).
  - Cover counsel and signature block: address lines step in as one padded block (`counsel-step`), so a wrapped line keeps the indent (was: "SCHOLER LLP" and "Washington, DC 20001" fell back to the left edge).
- Checked and left: there is no forced page break in the body; the Statement of the Case (folio 3) and Argument I (folio 7) move to the next page because a heading chain is kept with its first lines of text, which leaves white space at the foot of folios 2 and 6; the certificates share PDF page 14 (rules do not require separate pages).
- Still open: Rule 26.1 disclosure forms, blue cover (paper only), short appendix, partial transcription, second opening-brief exemplar (see "Known gaps"). The latex engine was re-rendered (exit 0, 16 pages) but its pages were not viewed in this pass; the docx outputs were not rebuilt (no LibreOffice on this box).

## Known gaps

- Blue cover (FRAP 32(a)(2)): paper-copy only, not produced.
- Rule 26.1 disclosure forms (Cir. R. 26.1): separate attorney filings, not generated. The exemplar shows them at pages 2-4 as fillable forms; they are not in the sample or the template.
- Body excerpt: the sample transcribes the cover, TOC and TOA material, Jurisdictional Statement, Issue, Introduction (two paragraphs), Statement of the Case (I.A-B in part, II), Summary of Argument, Standard of Review, the start of the Argument (I, I.A.1, I.A.2 opening) and the Conclusion. The middle of the brief (I.A.3 through I.B.2) is not transcribed; the TOC and TOA show only the transcribed headings.
- Second exemplar: a second filer is needed for the tier-2 check (2-3 exemplars from different filers). The candidate `Agofsky v. Baysore`, No. 24-1067, entry 7 (Federal Community Defender; 87 pages; text layer) was found on CourtListener and is recorded in `usage/SOURCE.md`, but it is not yet saved or transcribed.
- Circuit Rule 30 short appendix: not produced.
- Fonts: EB Garamond is kept. The exemplar uses Times New Roman, but the rules name no face (see the court `README.md` "Typeface"), so Liberation Serif is not substituted; matching the filer's face is tier 3, not chased.
- Table of contents (PDF page 2, folio i): the entry "B. Mr. Torres is confined in a moldy, contaminated cell for three months" used to wrap with its page number "3" dropped to a line of its own. Fixed 2026-10-16 (see "Verification pass").
- The rules PDF is "current as of December 1, 2025". The exemplar was filed in March 2024, under the earlier version of the circuit rules. Where the two differ, the current text governs; no difference was found for the rules used here.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls the template. |
| `typst/ca7-opening-brief.typ` | The template: `ca7-opening-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |
| `usage/INPUT-opening-brief.md` | The sample markdown (frontmatter + body). |
| `usage/OUTPUT-opening-brief.typst.pdf` | The render (14 pages). |
| `usage/OVERLAY-torres-opening-brief.pdf`, `-overlay.txt` | The red/blue overlay against the exemplar, and its page map. |
| `usage/FILED-EXAMPLE-opening-brief.pdf`, `usage/SOURCE.md` | The filed exemplar and its source record. |

## Engines

All three on the shared cross-engine layout model (fb-595.54.1; `lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; docs/EVAL-LOOP.md, "Adopting the reference breaker"): Times New Roman (newtx in latex) 14 pt in 31.4 pt line boxes, headings and tables in 20 pt boxes, 12 pt footnotes in 17 pt boxes; latex and docx break every line and page where typst does, and `eval.yaml` gates it (`params.cross_engine: gate`, XENG-001..003). The docx filter of this folder no longer matches its answering- and reply-brief copies outside `CFG`.

- **typst** (`typst/`): primary. TOC page column and counsel-line indent changed 2026-10-16 (see "Verification pass").
- **latex** (`latex/template.tex`, `latex/ca7-opening-brief.lua`): Times (newtx, stock pdflatex) 14 pt, 12 pt footnotes, 31.4 pt double spacing, one-inch margins, no hyphenation, left aligned. Cover, TOC, TOA (page list, `passim` at 7 or more pages), roman then arabic numbering, signature block and both certificates are built from the same frontmatter. Output `usage/OUTPUT-opening-brief.latex.pdf`, 16 pages (typst: 14). Differences: the cover spacing is hand-set rather than fitted; the signature block can start a page alone (typst keeps the last paragraph with it); the body runs about one page longer; an addendum (FRAP 28(f)) is not rendered and the engine stops with an error if the sample has one. Gates not run: the court has no `checks.yaml` or `rules.md` yet.
- **docx** (`docx/`): `build-reference.sh` (lib/docx/xengine-reference.sh plus the CA styles: Times New Roman 14 pt, exact 31.4 pt double spacing, 12 pt footnotes), `ca7-opening-brief.lua` (cover with double rules and two-column counsel, TOC, TOA, signature and certificates), `render.sh` (sections with roman front matter and arabic body, PAGE footers, and a two-pass TOC/TOA page map read from the LibreOffice PDF), `pagemap.awk` (headings by label and title, citations as needles in document order). Output `usage/OUTPUT-opening-brief.docx` and `.docx.pdf`, 14 pages (typst: 14); the certificate word count is 1,871, the same as typst. Matches typst: the face and sizes, spacing, margins, cover, TOC entries with the certificates, TOA with page numbers, body and certificates. Differences: the cover is spaced by hand; the TOA page list comes from a text search of the PDF; the TOC and TOA are static text, not fields; the compliance certificate omits the typst "using Typst" clause and the typeface is named from the template (EB Garamond). Opened in LibreOffice without error; not opened in Word. BLOCKED: `tools/check.sh --engine docx` cannot run: no `checks.yaml` and no `court.json` in this folder or the court (exit 2), so no Gate 1 check ID can be reported; Gate 2 has no `reviews/` file.

