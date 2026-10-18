# uscgcoca: answering brief (Answer to Appellant's Assignments of Error on Behalf of the United States)

- Court: U.S. Coast Guard Court of Criminal Appeals (CGCCA).
- Doc type: the Government's answer, listed by the court as "Government Answer" (Rule 18(d): "An answer by the United States shall be filed no later than 30 days after the filing of an appellant's brief"; R. 17.2(a) "Answer Briefs").
- Exemplar: `usage/SAMPLE-uscgcoca-answering-brief-steen1464.pdf`, an 8-page extract of *United States v. Steen*, Docket No. 1464, Answer to Appellant's Assignments of Error on Behalf of the United States, filed 6 May 2019 by Appellate Government Counsel (Commandant (CG-LMJ)); published by the court (source, page map: `usage/SOURCE.md`). Found on the fourth pass (2026-10-16, bead fb-595.20.21).
- Samples: `usage/INPUT-uscgcoca-answering-brief-steen.md` (transcription); `usage/INPUT-uscgcoca-answering-brief-smoke.md` (placeholder, kept).
- Template: `typst/uscgcoca-answering-brief.typ`; identical to `../opening-brief/typst/uscgcoca-opening-brief.typ` except the default title ("ANSWER TO APPELLANT'S ASSIGNMENTS OF ERROR ON BEHALF OF THE UNITED STATES", as filed).
- Status (2026-10-16): render ok (8 pages); overlay ok; every page reviewed. No `checks.yaml`; `tools/check.sh` not run. `court.json` untouched.

## Governing rules

The same rules and the same parameter mapping as `../opening-brief/README.md` ("Governing rules"): CGCCA Rules of Appellate Procedure Rev. 03/25, R. 17.1 (Times New Roman at least 12 pt, at least 15-point spacing, 1 in margins, letter), R. 17.2(a) (content, certificate of service), R. 17.3 (20,000 words for "briefs and answers", word certificate), R. 14 (signature). Read 2026-10-16 from the Wayback capture 20250428115614. Markdown contract: same as the opening brief.

## Overlay

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief steen-answering-brief` exit 0:

| Ours | Filed (extract) | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 83.7% | Caption, introduction, Statement of the Case |
| 2 | 2 | 59.5% | |
| 3 | 3 | 60.8% | |
| 4 | 4 | 61.6% | |
| 5 | 5 | 60.7% | Issue I, Standard of Review, Discussion |
| 6 | 6 | 44.4% | End of the p. 6 extract, then the p. 18 text and Conclusion |
| 7 | 8 | 46.6% | Mispaired: ours p. 7 holds the Prayer for Relief and both signature blocks (filed extract p. 7); the filed certificate page repeats Godsey's address block, so it scores higher. |
| 8 | 8 | 67.4% | Certificates (Compliance, Service) |

## Page review (Gate 2), 2026-10-16

All 8 pages of `OUTPUT-uscgcoca-answering-brief-steen.typst.pdf` and all 8 of `OVERLAY-steen-answering-brief.pdf` rasterized at 60 dpi and viewed. Fonts: Liberation Serif Regular, Bold, Italic only; no typst warnings.

| Page | Result |
|---|---|
| 1 | OK. Caption (date, title, docket, panel, tried-at), address line, introduction, STATEMENT OF THE CASE, footnote 1. ACCEPTED (tier 3): the filer put "CGCMSP 24978" above the docket; the sample carries it at the start of the tried-at text. |
| 2-4 | OK. Facts with the long footnote 2 single-spaced at the foot of p. 2. |
| 5 | OK. Issue I heading in bold capitals; centered Standard of Review / Discussion; lettered heading A. |
| 6 | OK. The excerpt jumps from source p. 6 to p. 18 mid-page (transcription boundary, documented in the sample header). |
| 7 | OPEN (tier 2): PRAYER FOR RELIEF starts a new page with the two side-by-side signature blocks; the filer kept Conclusion, Prayer and signatures on one page (p. 18). Caused by the sticky heading plus the unbreakable signature row not fitting under the Conclusion. |
| 8 | OK. Certificate of Compliance (R. 17.3; not in the 2019 filing) and Certificate of Service, signed by the last signer (Godsey, as filed). |

## Known gaps

1. TOC/TOA and summary of argument over 30 pages (R. 17.3) not generated; word limit printed, not enforced; word count approximate unless `word_count` is given.
2. The 2019 exemplar has no word certificate; the template adds it per R. 17.3 (2025).
3. The docx engine was not changed in this pass and still builds the earlier EB Garamond form; `usage/OUTPUT-uscgcoca-answering-brief-smoke.docx*` come from it. The `signature` list form used by the Steen sample is typst-only for now.
4. No `checks.yaml`; `tools/check.sh` not run.

## Engines

**docx** (`docx/`): unchanged; out of step with the typst form (Known gaps 3). BLOCKED: `tools/check.sh --engine docx` cannot run on this folder (no `checks.yaml`).

## History

- 2026-10-14 / 2026-10-15: BLOCKED (no exemplar, rules unread).
- 2026-10-16 (bead fb-595.20.21): Steen answer and the rules recovered from the Internet Archive; template, sample, render, overlay; smoke sample re-rendered (2 pages, viewed).
