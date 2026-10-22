# uscgcoca: answering brief (Answer to Appellant's Assignments of Error on Behalf of the United States)

- Court: U.S. Coast Guard Court of Criminal Appeals (CGCCA).
- Doc type: the Government's answer, listed by the court as "Government Answer" (Rule 18(d): "An answer by the United States shall be filed no later than 30 days after the filing of an appellant's brief"; R. 17.2(a) "Answer Briefs").
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf`, an 8-page extract of *United States v. Steen*, Docket No. 1464, Answer to Appellant's Assignments of Error on Behalf of the United States, filed 6 May 2019 by Appellate Government Counsel (Commandant (CG-LMJ)); published by the court (source, page map: `usage/SOURCE.md`). Found on the fourth pass (2026-10-16, bead fb-595.20.21).
- Samples: `usage/INPUT-answering-brief.md` (transcription); `usage/INPUT-answering-brief-2.md` (placeholder, kept).
- Template: `typst/uscgcoca-answering-brief.typ`; identical to `../opening-brief/typst/uscgcoca-opening-brief.typ` except the default title ("ANSWER TO APPELLANT'S ASSIGNMENTS OF ERROR ON BEHALF OF THE UNITED STATES", as filed).
- Status (2026-10-22, bead fb-595.54.7): typst and docx on the shared cross-engine layout model and gated (`eval.yaml`: `params.cross_engine: gate`); `tools/check.sh` 16 passed 0 failed (typst) and 24 passed 0 failed (docx, XENG-001..003 PASS on both samples). `court.json` untouched.

## Governing rules

The same rules and the same parameter mapping as `../opening-brief/README.md` ("Governing rules"): CGCCA Rules of Appellate Procedure Rev. 03/25, R. 17.1 (Times New Roman at least 12 pt, at least 15-point spacing, 1 in margins, letter), R. 17.2(a) (content, certificate of service), R. 17.3 (20,000 words for "briefs and answers", word certificate), R. 14 (signature). Read 2026-10-16 from the Wayback capture 20250428115614. Markdown contract: same as the opening brief.

## Overlay

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief answering-brief` exit 0 (2026-10-22, re-run on the cross-engine render); overlay at `.overlay/courts/military/coast-guard-court-of-criminal-appeals/answering-brief/OVERLAY-answering-brief.pdf` (gitignored; all 8 pages viewed as 50 dpi thumbnails):

| Ours | Filed (extract) | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 86.9% | Caption, introduction, Statement of the Case |
| 2 | 2 | 72.1% | |
| 3 | 3 | 77.7% | |
| 4 | 4 | 87.3% | |
| 5 | 5 | 96.6% | Issue I, Standard of Review |
| 6 | 6 | 99.1% | Discussion, heading A; end of the p. 6 extract |
| 7 | 7 | 97.0% | The p. 18 text, Conclusion, Prayer for Relief and both signature blocks |
| 8 | 8 | 67.4% | Certificates (Compliance, Service) |

## Page review (Gate 2), 2026-10-22

All 8 pages of `OUTPUT-answering-brief.typst.pdf` and of `OUTPUT-answering-brief.docx.pdf`, and both pages of each render of `INPUT-answering-brief-2.md`, rasterized at 60 dpi and viewed side by side. Typst SHA-256: `c9a5b6099cb9c5607e5ae93bd41caa961e71816664d540975855a8410b465526` (answering-brief), `84477f2c7f20b91a970dd67f77811a0c2f8f1a6722d64428fbd1960fa9a19848` (answering-brief-2). Fonts: Times New Roman Regular, Bold, Italic (both engines); no typst warnings.

| Page | Result |
|---|---|
| 1 | OK. Caption (date, title, docket, panel, tried-at), rule, address line, introduction, STATEMENT OF THE CASE, footnote 1. ACCEPTED (tier 3): the filer put "CGCMSP 24978" above the docket; the sample carries it at the start of the tried-at text. |
| 2-4 | OK. Facts with the long footnote 2 single-spaced at the foot of p. 2. |
| 5 | OK. Issue I heading in bold capitals; centered Standard of Review. |
| 6 | OK. Discussion; lettered heading A. The excerpt jumps from source p. 6 to p. 18 (transcription boundary, documented in the sample header). |
| 7 | OK. Conclusion, Prayer for Relief, "Respectfully submitted," kept with the two signature blocks side by side. |
| 8 | OK. Certificate of Compliance (R. 17.3; not in the 2019 filing) and Certificate of Service, signed by the last signer (Godsey, as filed). |
| -2: 1-2 | OK. Caption, headings, signature; certificates on p. 2. |

The docx renders show the same pages line for line (XENG-001..003 PASS).

## Known gaps

1. TOC/TOA and summary of argument over 30 pages (R. 17.3) not generated; word limit printed, not enforced; word count approximate unless `word_count` is given (both engines count the same way).
2. The 2019 exemplar has no word certificate; the template adds it per R. 17.3 (2025).

## Engines

Same model and numbers as `../opening-brief/README.md` ("Engines"): typst on `lib/typst/xengine.typ`, docx (`docx/uscgcoca.lua`, `docx/reference.xml`) on `lib/docx/xengine.lua`, gated by `eval.yaml` (`params.cross_engine: gate`); Times New Roman 12 pt in both, 28 pt body and 15 pt single pitches. The docx now builds the typst form (it built an earlier EB Garamond form; `build-reference.sh` and `reference.docx` retired), including the `signature` list as a two-column table. `tools/check.sh --engine docx` 24 passed, 0 failed.

## History

- 2026-10-14 / 2026-10-15: BLOCKED (no exemplar, rules unread).
- 2026-10-16 (bead fb-595.20.21): Steen answer and the rules recovered from the Internet Archive; template, sample, render, overlay; smoke sample re-rendered (2 pages, viewed).
- 2026-10-22 (bead fb-595.54.7): typst and docx ported onto the shared cross-engine layout model (Times New Roman, 28/15 pt pitches); docx rewritten from the typst template; gated.
