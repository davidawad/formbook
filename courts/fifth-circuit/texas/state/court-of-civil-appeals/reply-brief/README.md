# Appellant's Reply Brief template (Texas Court of Appeals)

Typst template for an appellant's reply brief in a Texas court of appeals (TRAP 38.3). The district and seat on the cover come from the frontmatter (`district`, `seat`; default Fifth District at Dallas, the court of the exemplar). Engines: typst (`typst/`, primary) and docx (`docx/`, not regenerated in the 2026-10-16 pass; see "Engines").

The template module `typst/texapp-reply-brief.typ` is the opening brief's code (`../opening-brief/typst/texapp-opening-brief.typ`) with `word-limit` set to 7,500. The rule table, the markdown contract and the 2026-10-16 changes are in `../opening-brief/README.md`.

## Governing rules (checked 2026-10-15, re-attempted 2026-10-16)

The primary TRAP PDF (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf) returned HTTP 403 on 2026-10-15 and 2026-10-16; rule text is from secondary summaries. Rules specific to this doc type:

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 38.3 | the appellant may file a reply addressing any matter in the appellee's brief; no prescribed contents | front matter is empty (no `{{identity}}`); contents and index are still generated, as the filer did | secondary |
| TRAP 9.4(i)(2)(C) | 7,500 words for a computer-generated reply brief in a court of appeals | `word-limit` = 7500; `assert` fails the render above it; `{{word-count}}` in the certificate | secondary |
| TRAP 9.4(c)-(e), (g), 39.7, 9.5 | as for the opening brief | as for the opening brief | secondary |
| Fifth Court local rules | local limits (a combined reply and cross-appellee brief has its own limit) | not encoded | secondary |

## Exemplar and overlay

- Exemplar: `usage/FILED-EXAMPLE-reply-brief.pdf` (10 pages; Scott H. Palmer, P.C.); source in `usage/SOURCE.md`.
- Overlay: `usage/OVERLAY-reply-brief.pdf` and `.txt`. Page map (ours to filed, word overlap): 1-1 cover 73%, 2-2 contents 46%, 3-2 index 50%, 4-3 94%, 5-4 94%, 6-5 75%, 7-6 50%, 8-7 prayer and signature 46%, 9-8 certificates 40%. The filer puts contents and authorities on one page; the template gives each its own page (tier 3).

## Sample

`usage/INPUT-reply-brief.md` is a full transcription of the filed reply: cover (with ORAL ARGUMENT REQUESTED and ACCELERATED APPEAL), contents, index of authorities, address to the court, First Reply Issue, Second Reply Issue, conclusion and prayer (list), signature, certificate of compliance (generated word count, 1,077 words) and certificate of service with two recipients. The appellant's medical and educational details are bracketed out.

Render: 9 pages (cover; ii contents; iii index; body 1-6). Every page rendered at 60 dpi and viewed on 2026-10-16; review in `reviews/2026-10-16.md`.

## Known gaps

1. One filer for this doc type (the same filer as the opening brief).
2. The filed reply is short, so the sample cannot reach more pages without invented text; 9 pages is the whole brief.
3. Rule text is secondary. `tools/check.sh` not run; no stamp.

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/`): `usage/OUTPUT-reply-brief.docx` and `.docx.pdf` are from the earlier sample and were **not regenerated** on 2026-10-16 (no `soffice` on this box). The docx filter predates the placeholder contract (`{{contents}}`, `{{signature}}`, `{{signer}}`, `{{word-count}}`) and the `authorities` list; a re-render would print the placeholders literally and omit the index. BLOCKED until `docx/texapp.lua` is updated.
- BLOCKED: tools/check.sh docx gates 0 to 3 not run (no `checks.yaml`, `rules.md` at the level `check.sh` reads).
- **latex**: not built for this doc type.
