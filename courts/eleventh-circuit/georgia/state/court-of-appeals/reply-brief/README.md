# Court of Appeals of Georgia (`gactapp`): reply brief (`reply-brief`)

Exemplar: **yes** (`usage/FILED-EXAMPLE-reply-brief.pdf`, Appellant's Reply Brief in *Chapman v. Metropolitan Atlanta Rapid Transit Authority*, No. A26A2158, filed August 3, 2026 by Keith Foster (The Foster Firm, LLC) and Ralph Goldberg (Goldberg & Cuvillier, P.C.); source in `usage/SOURCE.md`). A third filer, different from the opening- and answering-brief exemplars. The sample transcribes the whole brief.

## Status of each output

| Item | Result |
|---|---|
| `usage/` | 1 filed brief, text PDF, 10 pages, court e-filing stamp on every page |
| `usage/INPUT-reply-brief.md` | transcription: cover, table of cited authorities (cases and other authority), argument III with the nested *Graves*/*Garner* quotation, conclusion, both footnotes, certificate of service. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-reply-brief.typst.pdf`, 9 pages, exit 0, no warnings, Liberation Serif embedded |
| overlay | ok: `usage/OVERLAY-fictional-reply-brief.pdf` / `.txt` |
| pages reviewed | 9 of 9 at 60 dpi, plus the 10 exemplar pages |

## Governing rules

Same as `../opening-brief/README.md`. Specific: Rule 24 (a): one reply brief as of right; Rule 24 (f) (1): reply briefs limited to 4,200 words, with the Rule 24 certification above the signature block; Rule 25 (c): a reply need only contain the argument (item 7); contents and authorities tables (items 1, 2) encouraged for long replies. The filer prints the certification on its own page headed "Rule 24 Certification" and does not sign the brief body; our template keeps the certification immediately above a signature block as Rule 24 (f) (1) says.

## Overlay page map

Ours 1-3 with filed 1-3 (cover 91%, contents 78%, authorities 64%: the filer's table runs to two pages), ours 4-6 with filed 5-7 (68-89%), ours 7-8 with filed 8 (conclusion and footnote 2), ours 9 with filed 10 (certificate of service, 91%).

## Gate 2 review (9 of 9 pages)

| Page | Finding |
|---|---|
| 1 | Cover with both counsel groups. OK |
| 2 | Contents. OK |
| 3 | Table of authorities, A. Cases / B. Other Authority, pages generated. OK. Fixed in review: authorities cited only in footnote 1 (*Durham*, *Hunter*, *Wallace*, *Zayac*) showed "--" because footnote entries were outside the marking rule; the template now marks footnotes too |
| 4 | Argument heading, long point heading III (single spaced, bold), nested block quotation. OK |
| 5-7 | Quotations single spaced, text double spaced. OK |
| 8 | Conclusion with footnote 2, Rule 24 certification, two signers. OK |
| 9 | Certificate of service with both signers (`first_signer_only: false`, as filed). OK |

## What changed

Template: shared with the opening brief (`typst/gactapp-reply-brief.typ` is the same file renamed); see `../opening-brief/README.md`. Sample replaced by the transcription.

## Gaps

Word count (4,200) not computed. The filer underlines case names; ours are italic (Rule 2 (c) (3) allows both). docx outputs stale (no `soffice`), same open items as the opening brief.
