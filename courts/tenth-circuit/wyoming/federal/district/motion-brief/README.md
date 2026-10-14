# District of Wyoming (wyd): motion brief (memorandum in support of a dispositive motion)

- Court: `wyd`, United States District Court for the District of Wyoming (`courts/tenth-circuit/wyoming/federal/district/`)
- Doc type: `motion-brief`. A memorandum in support of a dispositive motion (Fed. R. Civ. P. 12(b)(6), 12(b)(7) and 19), filed with the motion itself as a separate document.
- Exemplar: `exemplars/FILED-EXAMPLE-elizondo-1-26-cv-00263-motion-brief.pdf` (*Elizondo v. Alger*, No. 1:26-cv-00263-SWS, Document 8, filed 2026-10-05, 12 pages; provenance in `exemplars/SOURCE.md`). One filer (defendant's counsel). The motion (Document 7) is not in the exemplar, so the sample is the memorandum only.
- Sample: `samples/INPUT-elizondo-motion-brief.md` (transcription of the whole memorandum from the introduction through the conclusion, with the signature block and certificate of service in the frontmatter).
- Status: template, sample, render, overlay and page review done 2026-10-14 (below). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `wyd-motion-brief`. |
| `typst/wyd-motion-brief.typ` | Template. Parameter block at the top: EB Garamond 13 pt, double spacing (`body-leading = 1.05em`), one-inch margins, 8½ × 11, `page-limit = 25`. |
| `samples/INPUT-elizondo-motion-brief.md` | Markdown contract sample (frontmatter: caption, attorney block, date, signature, certificate; body: `#` headings, paragraphs, a numbered conclusion). |
| `samples/OUTPUT-elizondo-motion-brief.pdf` | `sh tools/render.sh courts/tenth-circuit/wyoming/federal/district/motion-brief samples/INPUT-elizondo-motion-brief.md` (9 pages, no typst warnings). |
| `samples/OVERLAY-elizondo-motion-brief.pdf`, `OVERLAY-elizondo-motion-brief.txt` | `sh tools/overlay.sh courts/tenth-circuit/wyoming/federal/district/motion-brief elizondo-motion-brief` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. The PDF is re-downloaded from the URL in `SOURCE.md`; it is not in git. |

## Governing rules

Primary sources, read 2026-10-14:

- D. Wyo. Local Civil Rule 7.1(b)(2)(A)–(B) (briefs for dispositive motions; "Briefs in support of and in opposition to all dispositive motions are limited to twenty-five (25) pages"), and 7.1(b)(1)(C) (the ten-page limit that applies to non-dispositive motions, not to this brief): <https://www.wyd.uscourts.gov/sites/wyd/files/local_rules/localrules-cv22.pdf>, the Civil Local Rules, January 2022 edition, printed pp. 8–9 (text extracted with `pdftotext`). The court's current-rules web page returned 404 on the day of review, so this January 2022 edition is the newest text retrieved; the May 2017 edition is superseded.
- D. Wyo. Local Civil Rule 10.1(a) (filing format: typed, double spaced, single-sided, 8½ × 11, one-inch margin on all sides, not less than 12 point) and 10.1(b) (caption per Fed. R. Civ. P. 10(a) plus the attorney information block): same edition, printed p. 12.
- Fed. R. Civ. P. 10(a) (caption) and 5(d)(1)(B) ("No certificate of service is required when a paper is served by filing it with the court's electronic-filing system"; <https://www.law.cornell.edu/rules/frcp/rule_5>, fetched 2026-10-14). See the certificate note under Known gaps.

The page limit is enforced in the template: `wyd-motion-brief.typ` asserts that the render is at most 25 pages (LR 7.1(b)(2)(B)), so a brief over the limit fails the render, not just the review. The exemplar is 12 pages and the sample renders to 9.

## Overlay

`samples/OVERLAY-elizondo-motion-brief.pdf` puts our render (red) over the best-matching filed page (blue). Pages are paired by word overlap, not by index. Diagnostic only, not a score. Last run:

- Sample p.1 ↔ filed p.1 (75%), p.2 ↔ p.2 (54%): caption, title, introduction, background.
- p.3 ↔ p.4 (61%), p.4 ↔ p.5 (52%): legal standard, Rule 19 framework, Argument A.
- p.5 ↔ p.7 (64%), p.6 ↔ p.9 (60%), p.7 ↔ p.10 (67%): Arguments B–E.
- p.8 ↔ p.12 (45%): conclusion, signature block, certificate. The filed conclusion starts on p. 11 and continues onto p. 12, which carries the signature and the certificate.
- p.9 ↔ p.12 (53%): the certificate of service, which the filed brief carries on p. 12.

## Page review (Gate 2)

Every page of `OUTPUT-elizondo-motion-brief.pdf` was rendered at 60 dpi and viewed (9 of 9). Pages were viewed in pairs; the paired images were rendered from the final PDF after the last template change.

| Page | Content | Result |
|---|---|---|
| 1 | Attorney block (top left), court name, caption with designations indented one inch and "Case No." level with "v.", title (two lines), I. INTRODUCTION, first two paragraphs | OK. Case names italic. |
| 2 | I. INTRODUCTION (end), II. FACTUAL AND PROCEDURAL BACKGROUND, III. LEGAL STANDARD (start) | OK. |
| 3 | III. (cont.), IV. ARGUMENT, heading A with its hanging number, Argument A | OK. |
| 4 | Argument A (cont.), B. heading | OK. |
| 5 | Argument B (cont.), C. heading | OK. |
| 6 | Argument C (cont.), D. heading | OK. |
| 7 | Argument D (cont.), E. heading | OK. |
| 8 | Argument E (cont.), CONCLUSION (centered), the numbered relief 1–5, "DATED" line, "Respectfully submitted," signature block | OK. The page ends with the signature block. |
| 9 | CERTIFICATE OF SERVICE, the service statement, the served party, "/s/" signature | OK. The certificate is one unbreakable block, so it moves to this page whole. |

Tier-2 findings (OPEN or ACCEPTED):

- p.1 ACCEPTED: the exemplar has no attorney information block on page 1. LR 10.1(b) requires one, so the template includes it at the top left; the content is the signature block's (name, bar number, address, telephone, email). This is a rule-driven deviation from the filed page.
- p.1 ACCEPTED: the typeface is EB Garamond where the filed brief uses Century Schoolbook (per the `pdffonts` run in `exemplars/SOURCE.md`). EB Garamond is the only serif family vendored; LR 10.1(a) requires not less than 12 point, and the template uses 13 pt.
- p.1–9 ACCEPTED: the filed brief's footer carries a short title, the case name and the case number under the page number; the template prints the page number only, as the complaint template does.
- p.9 ACCEPTED: the certificate of service stands alone on the last page. The filed brief keeps it on the signature page. Fed. R. Civ. P. 5(d)(1)(B) does not require a certificate for ECF service; the template keeps it because the filed exemplar has one.
- p.1 OPEN (cosmetic): the filed brief bolds some statutory citations in the introduction (e.g. "Wyo. Stat. § 17-29-104(a) (2017)", filed p. 1). The transcription does not reproduce that emphasis, because the text layer does not show it.

## Known gaps

1. Second filer. The brief asks for two or three exemplars from different filers for tier 2. Only *Elizondo* (defendant's counsel) is saved. A second D. Wyo. memorandum, *Redington v. dGEN Energy Partners Inc.*, 1:26-cv-00213-KHR, Document 16 (12(b)(6) memorandum, 17 pages), was found in the RECAP search results and is the candidate for the second filer; it has not been downloaded. Tier 2 is judged against one filer until it is.
2. Italics. The text layer does not carry font style. Case names are italicized by convention, not checked glyph by glyph against the filed page. The rendered pages show them italic.
3. Certificate of service. The rules do not require one for ECF service (Fed. R. Civ. P. 5(d)(1)(B)); the template includes it because the filed exemplar does. A filer who drops it would change only the frontmatter `certificate` block, not the template.
4. Sample scope. The sample is the whole memorandum (the filed brief is 12 pages). Its frontmatter attorney block, signature and certificate are built from the filed signature and certificate; the filed first page has no attorney block (see Tier-2 findings).
5. Local rule edition. The rules are the January 2022 edition (see Governing rules). A newer edition, if any, has not been checked.
