# uscgcoca: answering brief (Answer to Appellant's Assignments of Error on Behalf of the United States)

- Court: U.S. Coast Guard Court of Criminal Appeals (CGCCA).
- Doc type: the Government's answer, listed by the court as "Government Answer" (Rule 18(d): "An answer by the United States shall be filed no later than 30 days after the filing of an appellant's brief"; R. 17.2(a) "Answer Briefs").
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf`, an 8-page extract of *United States v. Steen*, Docket No. 1464, Answer to Appellant's Assignments of Error on Behalf of the United States, filed 6 May 2019 by Appellate Government Counsel (Commandant (CG-LMJ)); published by the court (source, page map: `usage/SOURCE.md`). Found on the fourth pass (2026-10-16, bead fb-595.20.21).
- Samples: `usage/INPUT-answering-brief.md` (transcription); `usage/INPUT-answering-brief-2.md` (placeholder, kept).
- Template: `typst/uscgcoca-answering-brief.typ`; identical to `../opening-brief/typst/uscgcoca-opening-brief.typ` except the default title ("ANSWER TO APPELLANT'S ASSIGNMENTS OF ERROR ON BEHALF OF THE UNITED STATES", as filed).
- Status (2026-10-21): render ok (8 pages); overlay ok; all 8 output pages and all 8 overlay pages rasterized at 60 dpi and reviewed. Rendered with Typst 0.15.1; no warnings. No `checks.yaml`; `tools/check.sh` not run. `court.json` untouched.

## Governing rules

The same rules and the same parameter mapping as `../opening-brief/README.md` ("Governing rules"): CGCCA Rules of Appellate Procedure Rev. 03/25, R. 17.1 (Times New Roman at least 12 pt, at least 15-point spacing, 1 in margins, letter), R. 17.2(a) (content, certificate of service), R. 17.3 (20,000 words for "briefs and answers", word certificate), R. 14 (signature). Read 2026-10-16 from the Wayback capture 20250428115614. Markdown contract: same as the opening brief.

## Overlay

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief answering-brief` exit 0; overlay at `.overlay/courts/military/coast-guard-court-of-criminal-appeals/answering-brief/OVERLAY-answering-brief.pdf` (gitignored):

| Ours | Filed (extract) | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 83.7% | Caption, introduction, Statement of the Case |
| 2 | 2 | 59.5% | |
| 3 | 3 | 63.2% | |
| 4 | 4 | 69.7% | |
| 5 | 5 | 75.3% | Issue I, Standard of Review, Discussion |
| 6 | 6 | 58.7% | End of the p. 6 extract, then the p. 18 text and Conclusion |
| 7 | 7 | 57.8% | Conclusion continues, then Prayer for Relief and both signature blocks |
| 8 | 8 | 67.4% | Certificates (Compliance, Service) |

## Page review (Gate 2), 2026-10-21

All 8 pages of `OUTPUT-answering-brief.typst.pdf` and all 8 of `.overlay/.../OVERLAY-answering-brief.pdf` rasterized at 60 dpi and viewed. Output SHA-256: `7438edf98bd3d0de4f9f34c05357dba14eb428fb552890cc748b52680c972936`. Fonts: Liberation Serif Regular, Bold, Italic only; no typst warnings.

| Page | Result |
|---|---|
| 1 | OK. Caption (date, title, docket, panel, tried-at), address line, introduction, STATEMENT OF THE CASE, footnote 1. ACCEPTED (tier 3): the filer put "CGCMSP 24978" above the docket; the sample carries it at the start of the tried-at text. |
| 2-4 | OK. Facts with the long footnote 2 single-spaced at the foot of p. 2. |
| 5 | OK. Issue I heading in bold capitals; centered Standard of Review / Discussion; lettered heading A. |
| 6 | OK. The excerpt jumps from source p. 6 to p. 18 mid-page (transcription boundary, documented in the sample header). |
| 7 | ACCEPTED (open choice): the conclusion continues from page 6, followed by Prayer for Relief and both signature blocks. The filed extract has this material on source page 18; the pagination differs because the input excerpt joins source pages 6 and 18 and omits pages 7-17. The page remains professionally grouped, and the rules do not prescribe pagination. |
| 8 | OK. Certificate of Compliance (R. 17.3; not in the 2019 filing) and Certificate of Service, signed by the last signer (Godsey, as filed). |

## Known gaps

1. TOC/TOA and summary of argument over 30 pages (R. 17.3) not generated; word limit printed, not enforced; word count approximate unless `word_count` is given.
2. The 2019 exemplar has no word certificate; the template adds it per R. 17.3 (2025).
3. The docx engine was not changed in this pass and still builds the earlier EB Garamond form; `usage/OUTPUT-answering-brief-2.docx*` come from it. The `signature` list form used by the Steen sample is typst-only for now.
4. No `checks.yaml`; `tools/check.sh` not run.

## Engines

**docx** (`docx/`): unchanged; out of step with the typst form (Known gaps 3). BLOCKED: `tools/check.sh --engine docx` cannot run on this folder (no `checks.yaml`).

## History

- 2026-10-14 / 2026-10-15: BLOCKED (no exemplar, rules unread).
- 2026-10-16 (bead fb-595.20.21): Steen answer and the rules recovered from the Internet Archive; template, sample, render, overlay; smoke sample re-rendered (2 pages, viewed).
