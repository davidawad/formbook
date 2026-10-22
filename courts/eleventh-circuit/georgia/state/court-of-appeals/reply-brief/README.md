# Court of Appeals of Georgia (`gactapp`): reply brief (`reply-brief`)

Exemplar: **yes** (`usage/FILED-EXAMPLE-reply-brief.pdf`, Appellant's Reply Brief in *Chapman v. Metropolitan Atlanta Rapid Transit Authority*, No. A26A2158, filed August 3, 2026 by Keith Foster (The Foster Firm, LLC) and Ralph Goldberg (Goldberg & Cuvillier, P.C.); source in `usage/SOURCE.md`). A third filer, different from the opening- and answering-brief exemplars. The sample transcribes the whole brief.

## Status of each output

| Item | Result |
|---|---|
| `usage/` | 1 filed brief, text PDF, 10 pages, court e-filing stamp on every page; its PDF pages are 612 x 1008 pt (legal size), although Rule 2 (c) (1) requires letter paper |
| `usage/INPUT-reply-brief.md` | transcription: cover, table of cited authorities (cases and other authority), argument III with the nested *Graves*/*Garner* quotation, conclusion, both footnotes, certificate of service. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-reply-brief.typst.pdf`, 10 pages, exit 0, no warnings, Times New Roman embedded |
| overlay | ok: `.overlay/courts/eleventh-circuit/georgia/state/court-of-appeals/reply-brief/OVERLAY-reply-brief.pdf` / `.txt` |
| pages reviewed | all 10 output pages (typst and docx) and all 10 exemplar pages rendered at 60 dpi and inspected |

## Governing rules

Same as `../opening-brief/README.md`. Specific: Rule 24 (a): one reply brief as of right; Rule 24 (f) (1): reply briefs limited to 4,200 words, with the Rule 24 certification above the signature block; Rule 25 (c): a reply need only contain the argument (item 7); contents and authorities tables (items 1, 2) encouraged for long replies. The filer prints the certification on its own page headed "Rule 24 Certification" and does not sign the brief body; our template keeps the certification immediately above a signature block as Rule 24 (f) (1) says.

## Overlay page map

(Measured before the fb-595.68.36 port, which moved the layout onto exact line boxes; regenerate with `just overlay` for current pages.)

Ours 1-3 with filed 1-3 (cover 91%, contents 78%, authorities 64%: the filer's table runs to two pages), ours 4-6 with filed 5-7 (68-89%), ours 7-8 with filed 8 (conclusion and footnote 2), ours 9 with filed 10 (certificate of service, 91%).

The filed exemplar's 8.5 x 14 in page size is inconsistent with Rule 2 (c) (1); the template follows the rule's letter size.

## Gate 2 review (10 of 10 pages, typst and docx renders at 50 dpi; re-done for fb-595.68.36)

| Page | Finding |
|---|---|
| 1 | Cover with both counsel groups. OK |
| 2 | Contents, the long point heading III wrapped with its lines hanging. OK |
| 3 | Table of authorities, A. Cases / B. Other Authority, pages generated from the body and the footnotes. OK |
| 4 | Argument heading, long point heading III (single spaced, bold), nested block quotation, footnote 1. OK |
| 5-7 | Quotations single spaced, text double spaced. OK |
| 8 | Conclusion with footnote 2. OK |
| 9 | Rule 24 certification and two signers, kept together, so they open the page. OK |
| 10 | Certificate of service with both signers (`first_signer_only: false`, as filed). OK |

## What changed

Template: shared with the opening brief (`typst/gactapp-reply-brief.typ` is the same file renamed); see `../opening-brief/README.md`. Sample replaced by the transcription.

## Gaps

Word count (4,200) not computed. The filer underlines case names; ours are italic (Rule 2 (c) (3) allows both).

## Engines

typst and docx on the cross-engine layout model, gated (`eval.yaml`); the same template, filter and numbers as `../opening-brief/README.md`, Engines (fb-595.68.36).
