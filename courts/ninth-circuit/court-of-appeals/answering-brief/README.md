# Ninth Circuit (ca9): answering brief (appellee's principal and response brief)

- Court: `ca9`, Court of Appeals for the Ninth Circuit (`courts/ninth-circuit/court-of-appeals/`)
- Doc type: `answering-brief`. One self-contained folder: its own template, exemplar and sample. It does not touch the court-root `typst/`, `samples/` or `rules.md`, which hold the opening brief.
- Exemplar: `exemplars/FILED-EXAMPLE-newsom-v-trump-25-3727-answering-brief.pdf` (*Newsom v. Trump*, No. 25-3727, Answering Brief of Plaintiffs-Appellees, DktEntry 63.1, filed 2025-09-02; 71 pages; text-based). Provenance in `exemplars/SOURCE.md`.
- Sample: `samples/INPUT-newsom-answering-brief.md`: an excerpt of the filed brief (see Known gaps). Rendered to 14 pages.
- Status: template built, sample rendered, overlay made, all 14 pages viewed (below). Not reviewed by a human. `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default `samples/INPUT-newsom-answering-brief.md`) and calls `ca9-answering-brief`. |
| `typst/ca9-answering-brief.typ` | Template. A copy of the ca9 opening-brief template (`../typst/ca9-brief.typ`) with four changes: the header says answering brief; the Statement of Related Cases page is generated only when the metadata has a `related_cases` map (Circuit Rule 28-2.6, see below); `toc-depth` is 5 (all argument levels); the function is named `ca9-answering-brief`. The page geometry, type, cover, TOA, Form 8 and addendum code are unchanged. |
| `samples/INPUT-newsom-answering-brief.md` | Markdown contract sample (frontmatter + body). |
| `samples/OUTPUT-newsom-answering-brief.pdf` | `sh tools/render.sh courts/ninth-circuit/court-of-appeals/answering-brief samples/INPUT-newsom-answering-brief.md` (14 pages). |
| `samples/OVERLAY-newsom-answering-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/ninth-circuit/court-of-appeals/answering-brief newsom-answering-brief`. |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

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

`samples/OVERLAY-newsom-answering-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only. Pairings from the last run (`-overlay.txt`):

- sample p.1-3 ↔ filed p.1-3 (19-57%): cover, TOC, TOA. The sample TOA lists only the cited authorities, so its overlap is lower.
- sample p.4 ↔ filed p.12 (95%): introduction; the word sets nearly coincide.
- sample p.5-7 ↔ filed p.13-15 (34-59%): introduction end, jurisdiction, statement, summary of argument.
- sample p.8-11 ↔ filed p.25, 27-29 (46-68%): summary end, argument I and I.A.1.a.
- sample p.12 ↔ filed p.48 (40%): the *Martin* discussion. The sample takes it from the filed argument's later part, so the match is partial.
- sample p.13 ↔ filed p.70 (39%): conclusion and signature block.
- sample p.14 ↔ filed p.71 (73%): Form 8.

## Page review (Gate 2)

Every page of `OUTPUT-newsom-answering-brief.pdf` was rendered at 60 dpi and viewed (14 of 14). Typst printed no warnings. Fonts embedded: EB Garamond only (Regular, Italic, Bold, Bold Italic). Page numbers below are PDF pages; the brief's own page numbers are printed on the page.

| PDF page | Content | Result |
|---|---|---|
| 1 | Cover | OK. Fits one page. The counsel block is abbreviated (see Known gaps). |
| 2 | Table of contents (I, A, 1, a levels) | OK. Matches the exemplar's TOC levels after `toc-depth` was raised to 5. |
| 3 | Table of authorities | OK. Cases italic; statutes and other authorities in their own groups. |
| 4 | Introduction (brief p. 1) | OK. |
| 5 | Introduction end (brief p. 2) | OK. |
| 6 | Introduction end; Jurisdiction; Statement A. (brief p. 3) | OK. |
| 7 | Statement A. end; Summary of Argument (brief p. 4) | OK. |
| 8 | Summary end; Argument heading and I (brief p. 5) | OK. Heading small caps, centered, as in the opening-brief template. |
| 9 | Argument I text; headings A. and 1. (brief p. 6) | OK. Headings numbered by the template (after the fix below). |
| 10 | Argument I.A.1.a heading; text (brief p. 7) | OK. |
| 11 | Argument I.A.1.a text (brief p. 8) | OK. |
| 12 | Argument I.A.1.a *Martin* paragraph (brief p. 9) | OK. |
| 13 | Conclusion; signature block (brief p. 10) | OK. The signature stands with the last paragraph. |
| 14 | Certificate of compliance, Form 8 | OK. States 2,213 words: the count of the sample body, not the filed brief (13,995). |

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
