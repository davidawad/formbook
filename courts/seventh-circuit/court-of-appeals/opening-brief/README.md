# Seventh Circuit: appellant's opening brief

Court: `ca7` (U.S. Court of Appeals for the Seventh Circuit). Doc type: `opening-brief`. One self-contained folder per doc type; the court-root `typst/` and `samples/` (ca9's opening brief lives there) are not touched.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: `exemplars/FILED-EXAMPLE-torres-22-2830-opening-brief.pdf` (see `exemplars/SOURCE.md`) |
| Sample | `samples/INPUT-torres-opening-brief.md` (cover, counsel, TOC, TOA, body excerpt, conclusion, signature, certificates) |
| Render | ok: `sh tools/render.sh courts/seventh-circuit/court-of-appeals/opening-brief samples/INPUT-torres-opening-brief.md` gives 14 pages, vendored fonts only, no typst warnings |
| Overlay | ok: `sh tools/overlay.sh courts/seventh-circuit/court-of-appeals/opening-brief torres-opening-brief` writes `samples/OVERLAY-torres-opening-brief.pdf` (14 pages) and `-overlay.txt` |
| Pages reviewed | 14 of 14 (every page rendered at `pdftoppm -r 60` and viewed; see "Visual review") |

Build and check, from the repo root (typst 0.15.0; `PATH` must include the micromamba env):

```sh
sh tools/render.sh courts/seventh-circuit/court-of-appeals/opening-brief samples/INPUT-torres-opening-brief.md
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

- Cover: fits one page; the case number, caption, and counsel block are all on it. The counsel block was made two-column and the emails were removed from the cover to fit the page. The firm name wraps ("ARNOLD & PORTER KAYE / SCHOLER LLP") in the narrow column. This is accepted: it is the cover's narrow column, not a defect in the text.
- TOC: correct entries, page numbers, and dot leaders. The Argument's point headings sit at the margin, as in the exemplar.
- TOA: groups in order, page lists correct, "Page(s)" heading correct.
- Body: double-spaced, single-spaced block quotations and headings, footnote 1 at 12 pt, no widows or orphans on page 1 or in the signature block.
- Signature block: "Respectfully submitted," then the s/ line, the signer's name in capitals, firm, and address. Date printed under it.
- Certificates: the compliance certificate and the certificate of service share page 10 (as described above); the word count shown (1,871) is the count of this partial sample, not the 6,881 words of the filed brief.

Open tier-2 items (left open, not papered over):
- Argument point headings are left-aligned, not centered as in the exemplar's outline. Accepted: the rules do not require either.
- The overlay pairs each sample page with the exemplar page sharing the most words (`-overlay.txt`). Word overlap runs from 30% to 99%; the cover (p.1 vs filed p.1, 92.8%) and the Summary of Argument (p.5 vs filed p.11, 99.0%) line up best. The sample pages pair with filed pages 1-40 in order, but the filed pages hold the appendix-free brief only in part, so the low scores are expected. This is a diagnostic, not a score.

## Known gaps

- Blue cover (FRAP 32(a)(2)): paper-copy only, not produced.
- Rule 26.1 disclosure forms (Cir. R. 26.1): separate attorney filings, not generated. The exemplar shows them at pages 2-4 as fillable forms; they are not in the sample or the template.
- Body excerpt: the sample transcribes the cover, TOC and TOA material, Jurisdictional Statement, Issue, Introduction (two paragraphs), Statement of the Case (I.A-B in part, II), Summary of Argument, Standard of Review, the start of the Argument (I, I.A.1, I.A.2 opening) and the Conclusion. The middle of the brief (I.A.3 through I.B.2) is not transcribed; the TOC and TOA show only the transcribed headings.
- Second exemplar: a second filer is needed for the tier-2 check (2-3 exemplars from different filers). The candidate `Agofsky v. Baysore`, No. 24-1067, entry 7 (Federal Community Defender; 87 pages; text layer) was found on CourtListener and is recorded in `exemplars/SOURCE.md`, but it is not yet saved or transcribed.
- Circuit Rule 30 short appendix: not produced.
- Fonts: EB Garamond is the vendored serif. The exemplar uses Times New Roman; the template does not match it glyph-for-glyph (tier 3, not chased).
- The rules PDF is "current as of December 1, 2025". The exemplar was filed in March 2024, under the earlier version of the circuit rules. Where the two differ, the current text governs; no difference was found for the rules used here.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls the template. |
| `typst/ca7-opening-brief.typ` | The template: `ca7-opening-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |
| `samples/INPUT-torres-opening-brief.md` | The sample markdown (frontmatter + body). |
| `samples/OUTPUT-torres-opening-brief.pdf` | The render (14 pages). |
| `samples/OVERLAY-torres-opening-brief.pdf`, `-overlay.txt` | The red/blue overlay against the exemplar, and its page map. |
| `exemplars/FILED-EXAMPLE-torres-22-2830-opening-brief.pdf`, `exemplars/SOURCE.md` | The filed exemplar and its source record. |

## Engines

- **typst** (`typst/`): primary, unchanged.
- **latex** (`latex/template.tex`, `latex/ca7-opening-brief.lua`): EB Garamond 14 pt from the vendored `fonts/` (`fontdir`), 12 pt footnotes, 31.4 pt double spacing, one-inch margins, no hyphenation, left aligned. Cover, TOC, TOA (page list, `passim` at 7 or more pages), roman then arabic numbering, signature block and both certificates are built from the same frontmatter. Output `samples/OUTPUT-torres-opening-brief.latex.pdf`, 16 pages (typst: 14). Differences: the cover spacing is hand-set rather than fitted; the signature block can start a page alone (typst keeps the last paragraph with it); the body runs about one page longer; an addendum (FRAP 28(f)) is not rendered and the engine stops with an error if the sample has one. Gates not run: the court has no `checks.yaml` or `rules.md` yet.
- **docx**: no `docx/` template yet. `samples/OUTPUT-torres-opening-brief.docx` is pandoc's default styling, not the court form. BLOCKED: the `.docx.pdf` checks (LibreOffice `soffice` is not installable on this box); the `.docx` is not formatted to the court form (fonts, 14 pt double spacing, margins, page numbering, cover, TOC/TOA, certificates); `tools/render-docx.sh` needs `unzip`, which this box lacks.
