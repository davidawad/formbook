# Ninth Circuit (ca9): answering brief (appellee's principal and response brief)

- Court: `ca9`, Court of Appeals for the Ninth Circuit (`courts/ninth-circuit/court-of-appeals/`)
- Doc type: `answering-brief`. One self-contained folder: its own template, exemplar and sample. It does not touch the court-root `typst/`, `usage/` or `rules.md`, which hold the opening brief.
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf` (*Newsom v. Trump*, No. 25-3727, Answering Brief of Plaintiffs-Appellees, DktEntry 63.1, filed 2025-09-02; 71 pages; text-based). Provenance in `usage/SOURCE.md`.
- Sample: `usage/INPUT-answering-brief.md`: an excerpt of the filed brief (see Known gaps). Rendered to 15 pages (14 before the 2026-10-16 pass; see the end of this file).
- Status: template built, sample rendered, overlay made, all 15 pages viewed (2026-10-16 pass, below). Not reviewed by a human. `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default `usage/INPUT-answering-brief.md`) and calls `ca9-answering-brief`. |
| `typst/ca9-answering-brief.typ` | Template. A copy of the ca9 opening-brief template (`../typst/ca9-brief.typ`) with four changes: the header says answering brief; the Statement of Related Cases page is generated only when the metadata has a `related_cases` map (Circuit Rule 28-2.6, see below); `toc-depth` is 5 (all argument levels); the function is named `ca9-answering-brief`. The page geometry, type, cover, TOA, Form 8 and addendum code are unchanged. |
| `usage/INPUT-answering-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/ninth-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md` (15 pages). |
| `usage/OVERLAY-newsom-answering-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/ninth-circuit/court-of-appeals/answering-brief newsom-answering-brief`. |
| `usage/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary sources, read on 2026-10-14 in the Ninth Circuit's "FRAP, Ninth Circuit Rules, Circuit Advisory Committee Notes", effective June 1, 2026: <https://cdn.ca9.uscourts.gov/datastore/uploads/frap-June%201%202026.pdf> (printed page numbers below). The form and cover rules (FRAP 32) are the same ones the opening-brief rules cite (`../rules.md`, read 2026-10-06); they are not repeated here.

| Rule | Requirement for an answering brief | Where the template uses it |
|---|---|---|
| FRAP 28(b) (p. 111) | The appellee's brief conforms to FRAP 28(a)(1)-(8) and (10), except that the jurisdictional statement, statement of the issues, statement of the case and standard of review need not appear unless the appellee is dissatisfied with the appellant's statement. | The sample has them anyway because the exemplar does. The template does not require them. |
| FRAP 28(a)(1) and Circuit Rule 28-1(c) (p. 112) | A disclosure statement is not included in the brief (Form 34 is filed separately; see `../rules.md`, finding 1). | No disclosure page. |
| Circuit Rule 28-2.2 (p. 114) | The appellee may state agreement with the appellant's jurisdictional statement under a heading. The exemplar does so ("plaintiffs do not contest the jurisdictional statement"). | Plain markdown heading; no template rule. |
| Circuit Rule 28-2.5 (p. 114) | Standard-of-review statement for the appellant. | Not required for the appellee; not generated. |
| Circuit Rule 28-2.6 (p. 115) | The related-cases statement is on the last page of the *initial* brief. The appellee "need not include any case identified as related in the appellant's brief." | The page is generated only when the metadata has `related_cases`. The exemplar has none. |
| Circuit Rule 28-2.7 (pp. 115-116) | Statutes, rules and regulations are set out verbatim in an addendum, or after the statement of issues. The addendum is optional for the appellee. | `addendum` heading in the markdown; TOC entry added when present. |
| Circuit Rule 28-2.8 (p. 116) | Record citations to the Excerpts of Record. | Markdown text only. |
| FRAP 32(a)(4)-(6); FRAP 32(a)(2)(A)-(F) | Page, margin, double spacing, 14-point serif, plain roman type; cover contents. (See `../rules.md`, CA9-FORM-* and CA9-COVER-*.) | Same code as the opening-brief template. |
| FRAP 32(f); Circuit Rule 32-1(a), (c) (p. 141) | An answering brief is a principal brief: 14,000 words. The cover, TOC, TOA, certificates and signature block are excluded from the count. | `limit = 14000`; `count-words` runs on the markdown body only. |
| Circuit Rule 32-1(e) (p. 141); Form 8 | Certificate of compliance (Form 8) must accompany a brief that uses a word count. | `certificate-of-compliance`, Form 8 wording. |
| Circuit Rule 32-1(f) (p. 141) | Words in visual images that are meant to be read are counted by hand and added to the certificate. | `manual_image_words` (default 0). |
| Circuit Rule 25-5(g)(1) (p. 85) | A brief submitted through ACMS that is served electronically needs no certificate of service. | `service.certificate` is opt-in; not used in the sample. |
| Circuit Rule 25-5(c) (p. 85) | No paper copies unless the Court directs them. The paper-copy cover colour (red for an appellee's brief) therefore does not apply to the electronic PDF. The exemplar's order also asked for paper copies with red covers. | No colour cover is produced. |

## Overlay

`usage/OVERLAY-newsom-answering-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only. Pairings from the last run (`-overlay.txt`):

- sample p.1-3 ↔ filed p.1-3 (20-61%): cover, TOC, TOA first page. The sample TOA lists only the cited authorities, so its overlap is lower.
- sample p.4 ↔ filed p.9 (18%): TOA second page (Other Authorities); the filed list is much longer.
- sample p.5 ↔ filed p.12 (95%): introduction; the word sets nearly coincide.
- sample p.6-8 ↔ filed p.13-15 (34-59%): introduction end, jurisdiction, statement, summary of argument.
- sample p.9-12 ↔ filed p.25, 27-29 (36-68%): summary end, argument I and I.A.1.a.
- sample p.13 ↔ filed p.48 (40%): the *Martin* discussion. The sample takes it from the filed argument's later part, so the match is partial.
- sample p.14 ↔ filed p.70 (39%): conclusion and signature block.
- sample p.15 ↔ filed p.71 (73%): Form 8.

## Page review (Gate 2)

Every page of `OUTPUT-answering-brief.typst.pdf` was rendered at 60 dpi and viewed (15 of 15, 2026-10-16). Typst printed no warnings. Fonts embedded: EB Garamond only (Regular, Italic, Bold, Bold Italic). Page numbers below are PDF pages; the brief's own page numbers are printed on the page.

| PDF page | Content | Result |
|---|---|---|
| 1 | Cover | OK. Fits one page. The counsel block is abbreviated (see Known gaps). |
| 2 | Table of contents (I, A, 1, a levels) | OK. Matches the exemplar's TOC levels after `toc-depth` was raised to 5. |
| 3 | Table of authorities (ii): cases, constitutional provisions, statutes | OK. Cases italic; each group under its own heading. |
| 4 | Table of authorities (iii): other authorities | OK. Five entries. The Mayson entry nearly fills the line, so its leader is a single dot. |
| 5 | Introduction (brief p. 1) | OK. |
| 6 | Introduction (brief p. 2) | OK. |
| 7 | Introduction end; Jurisdiction; Statement A. (brief p. 3) | OK. |
| 8 | Statement A. end; Summary of Argument (brief p. 4) | OK. |
| 9 | Summary end; Argument heading and I (brief p. 5) | OK. Heading small caps, centered, as in the opening-brief template. |
| 10 | Argument I text; headings A. and 1. (brief p. 6) | OK. Headings numbered by the template (after the fix below). |
| 11 | Argument I.A.1.a heading; text (brief p. 7) | OK. |
| 12 | Argument I.A.1.a text (brief p. 8) | OK. |
| 13 | Argument I.A.1.a *Martin* paragraph (brief p. 9) | OK. |
| 14 | Conclusion; signature block (brief p. 10) | OK. The signature stands with the last paragraph. |
| 15 | Certificate of compliance, Form 8 | OK. States 2,213 words: the count of the sample body, not the filed brief (13,995). |

Fixes made during review:

1. Case names were outside the italics, so the render showed roman case names. They are italic now, inside the link text (`[*Laird v. Tatum*, ...](toa:laird)`).
2. The sample headings carried manual numbers ("I.", "A.", "1.", "a."); the template numbers headings itself, so the render printed "II. A." and so on. The manual numbers are gone, and the heading levels are fixed so the numbering matches the filed brief (I, then A, 1, a under I).
3. `toc-depth` is 5 in this template (the opening-brief template uses 4, which dropped the "a." entries that the exemplar lists).
4. The sample body was 16 pages; it was trimmed to 14 (three paragraphs of the argument removed, with their authorities).

## Known gaps

- **Sample is an excerpt.** The brief is 71 pages. The sample has the cover, the TOC, the TOA (only the cited authorities), the introduction, jurisdiction, part of the statement, the summary of argument, the start of Argument I.A.1.a, and the conclusion with the signature block. Argument I.A.1.b-c, I.A.2, I.B and II (the alternative remedy argument) are not transcribed. Footnotes are omitted. Some sentences in the transcribed paragraphs are left out; the wording that remains is the filed wording.
- **Cover counsel block** is abbreviated: the exemplar lists 14 counsel names. The template fits one counsel group; the sample keeps the lead names. The signature block keeps the signer and his contact details only.
- **TOA** covers only the authorities cited in the sample; the page numbers are the sample's, not the filed brief's.
- **Certificate of compliance** word count is computed from the sample body (2,213). It is not the filed brief's count (13,995).
- **No certificate of service.** ACMS service needs none (Circuit Rule 25-5(g)(1)). The template supports one when `service.certificate: true`; the exemplar has none.
- **No related-cases statement** in the sample: the exemplar has none, and Circuit Rule 28-2.6 does not require one from the appellee unless the appellant omitted a related case.
- **Cover colour** is not produced (paper copies only; Circuit Rule 25-5(c)).
- **One filer only.** The exemplar search (CourtListener RECAP, which allows 5 queries a minute to anonymous callers) found this filing directly. A second filer's answering brief, for the convention check that the eval loop wants, has not been compared; the cover and tables are compared against this one filing only.

## Engines

The same markdown renders through three engines. Typst (`typst/`) is the reference; the LaTeX and DOCX engines were built to its form and checked against it page by page.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-answering-brief.typst.pdf` (15 pp) | reference |
| latex | `OUTPUT-answering-brief.latex.pdf` (15 pp) | ok: rendered, every page compared with the typst page |
| docx | `OUTPUT-answering-brief.docx`; no `.docx.pdf` | BLOCKED: no LibreOffice on this box (below) |

```sh
sh tools/render.sh --engine latex courts/ninth-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md
sh tools/render.sh --engine docx  courts/ninth-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md
```

**latex** (`latex/template.tex`, `latex/ca9.lua`). This is the reply-brief LaTeX engine (see `../reply-brief/README.md`, "Engines") with the answering limits: `ca9.lua` checks the 14,000-word limit of Circuit Rule 32-1(a) and lists five heading levels in the table of contents, as the typst answering template does. `fb render` builds it: pandoc writes the `.tex`, then stock pdflatex runs until the aux file settles, so the tables take their page numbers from the final layout. Fonts: Times from newtx (TeXGyreTermesX, metric-compatible with Times New Roman); the PDF embeds those faces and nothing else, on US Letter.

- *Matches typst:* the same form elements as the reply brief, with the same page for every heading, the Introduction, Jurisdiction, Statement and its "A. Legal Background", Summary of Argument, Argument with all five levels, Conclusion and certificate. The table of authorities (groups, page lists, the statute and the other authorities) matches. The certificate's word count, 2,213, is the same as typst's.
- *Differs:* body lines break at slightly different words, so a few pages begin a line or two apart from typst's; the page count is the same. The signature block sits at half the text width, where typst's sits at about 40%. The cover spacing is fixed rather than fitted. The deepest table-of-contents entry wraps its title in the same place as typst.
- *Not exercised by this sample:* a related-cases statement (the sample has none; the template emits one only when the metadata has `related_cases`), the Certificate of Service, the addendum, and "passim". These were checked on the synthetic sample used for the reply brief.
- *Gates:* `tools/check.sh` does not apply to this folder (no `checks.yaml` or `court.json`). The review is by eye: all 14 pages of the LaTeX PDF were rendered at 60 dpi and set beside the typst page (before 2026-10-16; see the verification pass for the 15-page rebuild).

**docx** (`docx/reference.docx`, `docx/ca9.lua`, `docx/make-reference.sh`). **BLOCKED.** The reasons are the reply brief's (`../reply-brief/README.md`, "Engines"): no `soffice` on this box, so no `.docx.pdf` and no gate on the docx. The `.docx` is delivered as a valid zip with well-formed XML. The BLOCKED check IDs are the same as for the reply brief, with one difference: the related-cases statement is not in the sample, so CA9-CERT-003 is not exercised. CA9-COVER-001 to -007, CA9-CONT-001, CA9-CONT-002, CA9-CERT-001 and -004, CA9-ADD-001, CA9-FORM-008 and CA9-CONT-012 are not built for docx.

## Verification pass 2026-10-16 (fb-595.26.9)

- **Rendered:** `sh tools/render.sh` on the committed sample first gave 14 pages, the same as the committed PDF, and exit 0 with no typst warnings. After the sample fixes below it gives 15 pages, also exit 0 with no warnings. The PDF embeds only the four EB Garamond faces.
- **Viewed:** all 15 pages of the typst PDF at 60 dpi, the exemplar's page 1 beside our cover, and all 15 overlay pages (at 40 and 150 dpi).
- **Overlay:** rerun with `sh tools/overlay.sh`; pairings above. The cover, introduction and Form 8 align by text. The body pitch and margins match the filed pages. The filed Form 8 is the court's form layout ("Form 8. Certificate of Compliance for Briefs", instructions URL, form footer). Ours gives the same statements and boxes under a plain heading. That is tier 2 and is not changed here.
- **Defects found and fixed (sample transcription, not template):**
  1. The TOA left out authorities that the transcribed text cites: U.S. Const. art. I, § 8, cls. 15-16; Exec. Order 14339; and the Leider, Coakley and Vladeck articles. The exemplar's TOA lists all of them. FRAP 28(a)(3) requires each authority with the pages where it is cited. They are now `toa:` links with frontmatter entries, worded as in the filed TOA. The TOA now has a Constitutional Provisions group and runs to two pages (ii-iii), so the PDF is 15 pages. The body page numbers are unchanged.
  2. On the cover, "Attorney General of California" was in `names` (roman) and the attorneys Harbourt and Hu were in `lines` (italic), so names and titles were set the wrong way round. The block is now two groups: Bonta with his title, then Harbourt and Hu with "Deputy Solicitors General", the department and the address. The cover still fits one page.
- **Template:** no change. No case-specific text, no measured coordinates and no forced breaks were found in `typst/ca9-answering-brief.typ`.
- **LaTeX:** rebuilt with `sh tools/render.sh --engine latex` (exit 0, 15 pages, the same page count as typst, EB Garamond only). Pages 1-4 (cover, TOC, TOA) were viewed this pass; the TOA page numbers match typst. Gap: the Coakley entry in the latex TOA wraps, and its page number ("3") sits alone on the next line with no leader. Pages 5-15 of the latex PDF were not viewed this pass.
- **Remaining gaps:** as listed under Known gaps (excerpt sample, abbreviated counsel block, one filer only). Also, the Form 8 page is not the court's form layout. DOCX is untouched (no `soffice`).
