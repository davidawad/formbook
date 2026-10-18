# Court of Appeals of Georgia (`gactapp`): appellee's brief (`answering-brief`)

In Georgia this is the "Brief of Appellee" (Rule 25 (b)). Exemplar: **yes** (`usage/SAMPLE-gactapp-answering-brief-campbellvtaylora26a1103.pdf`, Brief of Appellee in *Campbell v. Taylor*, No. A26A1103, filed March 11, 2026 by Hall Booth Smith, P.C.; source in `usage/SOURCE.md`). It answers the appellant's brief used as the `opening-brief` exemplar, filed by a different firm. The sample is a transcription of the whole brief.

## Status of each output

| Item | Result |
|---|---|
| `usage/` | 1 filed brief, text PDF, 11 pages (Century Schoolbook, court e-filing stamp on every page) |
| `usage/INPUT-gactapp-answering-brief-fictional.md` | transcription of the whole filed brief, both footnotes included. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-gactapp-answering-brief-fictional.typst.pdf`, 10 pages, exit 0, no warnings, Liberation Serif embedded |
| overlay | ok: `usage/OVERLAY-fictional-answering-brief.pdf` / `.txt` |
| pages reviewed | 10 of 10 at 60 dpi, plus the 11 exemplar pages |

## Governing rules

Same rules and template as `../opening-brief/README.md` (Rules 2, 6, 24, 25, effective March 26, 2026, read 2026-10-16). Specific to this type: Rule 25 (b): follows Rule 25 (a) except the enumeration of errors; jurisdiction and statement of the case may be omitted if the appellee accepts the appellant's; disagreement with the appellant's statement must be identified with record cites. The filed brief has Statement of the Case, Argument, Conclusion; no table of authorities (not mandatory; Rule 25 (a) (1) asks for one only for long or complex briefs). Length: 8,400 / 14,000 words (24 (f) (1)).

## Overlay page map

Ours 1-4 with filed 1-4 (cover 91%, contents 87%, statement 89%, argument 75%); ours 5-10 with filed 6-11 (58-86%). Our text runs about a page short because Liberation Serif at 14 pt sets narrower than the filer's Century Schoolbook (a face Rule 2 (c) (3) also allows; the court-named substitute here stays Liberation Serif).

## Gate 2 review (10 of 10 pages)

| Page | Finding |
|---|---|
| 1 | Cover: court, case no., caption, "On Appeal from the Superior Court of Lowndes County / No. 2024CV0039", title, counsel. OK |
| 2 | Contents with two argument headings and Certificate of Service. OK |
| 3 | Statement of the Case, footnote 1 at 14 pt single spaced. OK |
| 4-6 | Argument, heading I, footnote 2. OK |
| 7-8 | Heading II, deposition Q/A block quote. OK (the filer sets "V2-109" flush after the quote; ours indents it: tier 3) |
| 8 | Conclusion; rest of page empty because the certification and signature are kept together (ACCEPTED) |
| 9 | Rule 24 certification, date, underlined /s/ signature, counsel lines. OK |
| 10 | Certificate of service (prior-agreement e-mail certification, Rule 6 (b) (2)), recipients, signature. OK; our certificate signature repeats the counsel lines (the filer lists only the signer): tier 3 |

## What changed

Template: as listed in `../opening-brief/README.md` (shared template, copied to `typst/gactapp-answering-brief.typ`). Sample: replaced the synthetic sample by the transcription. Fix found in review: `[APPELLANT]: Yes.` at the start of a quoted line was parsed as a markdown link definition and vanished; the sample escapes the brackets (`\[APPELLANT\]:`), and the contract notes it.

## Gaps

Word count not computed. docx outputs are stale renders of the old synthetic sample (no `soffice` on this box): open docx items are Rule 24 (e) numbering, Rule 24 (f) (1) certification, Rule 6 certificate, the new frontmatter keys. See `../opening-brief/README.md`, Engines.
