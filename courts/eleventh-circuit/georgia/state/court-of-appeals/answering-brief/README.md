# Court of Appeals of Georgia (`gactapp`): appellee's brief (`answering-brief`)

In Georgia this is the "Brief of Appellee" (Rule 25 (b)). Exemplar: **yes** (`usage/FILED-EXAMPLE-answering-brief.pdf`, Brief of Appellee in *Campbell v. Taylor*, No. A26A1103, filed March 11, 2026 by Hall Booth Smith, P.C.; source in `usage/SOURCE.md`). It answers the appellant's brief used as the `opening-brief` exemplar, filed by a different firm. The sample is a transcription of the whole brief.

## Status of each output

| Item | Result |
|---|---|
| `usage/` | 1 filed brief, text PDF, 11 pages (Century Schoolbook, court e-filing stamp on every page) |
| `usage/INPUT-answering-brief.md` | transcription of the whole filed brief, both footnotes included. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-answering-brief.typst.pdf`, 10 pages, exit 0, no warnings, Times New Roman embedded |
| overlay | ok: `.overlay/courts/eleventh-circuit/georgia/state/court-of-appeals/answering-brief/OVERLAY-answering-brief.pdf` / `.txt` |
| pages reviewed | all 10 output pages (typst and docx) and all 11 exemplar pages rendered at 60 dpi and inspected |

## Governing rules

Same rules and template as `../opening-brief/README.md` (Rules 2, 6, 24, 25, effective March 26, 2026, read 2026-10-16). Specific to this type: Rule 25 (b): follows Rule 25 (a) except the enumeration of errors; jurisdiction and statement of the case may be omitted if the appellee accepts the appellant's; disagreement with the appellant's statement must be identified with record cites. The filed brief has Statement of the Case, Argument, Conclusion; no table of authorities (not mandatory; Rule 25 (a) (1) asks for one only for long or complex briefs). Length: 8,400 / 14,000 words (24 (f) (1)).

## Overlay page map

(Measured before the fb-595.68.36 port, which moved the layout onto exact line boxes; regenerate with `just overlay` for current pages.)

The regenerated same-id overlay pairs ours pages 1-11 with filed pages 1-11. Text flow and pagination now match page for page; the template is set in Times New Roman 14 pt (Rule 2 (c) (3) names it; the house standard, docs/FONTS.md rule 6; `template_face` in data/exemplar-fonts.json), narrower than the filer's Century Schoolbook, so ours runs to 10 pages against the filed 11.

## Gate 2 review (10 of 10 pages, typst and docx renders at 50 dpi; re-done for fb-595.68.36)

| Page | Finding |
|---|---|
| 1 | Cover: court, case no., caption, "On Appeal from the Superior Court of Lowndes County / No. 2024CV0039", title, counsel. OK |
| 2 | Contents with two argument headings (wrapped lines hanging) and Certificate of Service. OK |
| 3 | Statement of the Case, footnote 1 at 14 pt single spaced. OK |
| 4-8 | Argument, heading I, footnote 2 (p. 5), heading II (p. 7), deposition Q/A block quote (p. 8). OK (the filer sets "V2-109" flush after the quote; ours indents it: tier 3) |
| 9 | Conclusion, Rule 24 certification, date and underlined /s/ signature with counsel lines. OK |
| 10 | Certificate of service (prior-agreement e-mail certification, Rule 6 (b) (2)), recipients, signature. OK; our certificate signature repeats the counsel lines (the filer lists only the signer): tier 3 |

## What changed

Template: as listed in `../opening-brief/README.md` (shared template, copied to `typst/gactapp-answering-brief.typ`). Sample: replaced the synthetic sample by the transcription. Fix found in review: `[APPELLANT]: Yes.` at the start of a quoted line was parsed as a markdown link definition and vanished; the sample escapes the brackets (`\[APPELLANT\]:`), and the contract notes it.

## Gaps

Word count not computed.

## Engines

typst and docx on the cross-engine layout model, gated (`eval.yaml`); the same template, filter and numbers as `../opening-brief/README.md`, Engines (fb-595.68.36). The face moved from TeX Gyre Schola to Times New Roman with the port (house standard, docs/FONTS.md rule 6).
