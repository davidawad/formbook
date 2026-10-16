# Appellee's Brief template (Texas Court of Appeals)

Typst template for an appellee's brief in a Texas court of appeals (TRAP 38.2). The district and seat on the cover come from the frontmatter (`district`, `seat`; default Fifth District at Dallas, the court of the exemplar). Engines: typst (`typst/`, primary) and docx (`docx/`, not regenerated in the 2026-10-16 pass; see "Engines").

The template module `typst/texapp-answering-brief.typ` is the same code as the opening brief's (`../opening-brief/typst/texapp-opening-brief.typ`); only the header comment differs. The rule table, the markdown contract and the list of 2026-10-16 changes are in `../opening-brief/README.md` and apply here unchanged.

## Governing rules (checked 2026-10-15, re-attempted 2026-10-16)

The primary TRAP PDF (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf) returned HTTP 403 on 2026-10-15 and 2026-10-16; rule text is from secondary summaries. Rules specific to this doc type:

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 38.2(a)(1) | an appellee's brief follows Rule 38.1, except that the identity list is needed only to supplement or correct the appellant's, and the statement of the case, issues and facts may be omitted unless the appellee is dissatisfied with the appellant's | the sample's front matter is a "Supplemental List of Appellant's Counsel" (`identity`); its body keeps statements of the case and facts because the filer did | secondary |
| TRAP 9.4(i)(2)(B) | 15,000 words, computer-generated | `word-limit` = 15000; `{{word-count}}` in the certificate | secondary |
| TRAP 9.4(c)-(e), (g), 39.7, 9.5 | as for the opening brief | as for the opening brief | secondary |

## Exemplar and overlay

- Exemplar: `exemplars/FILED-EXAMPLE-answering-brief.pdf` (58 pages; Karen M. Billingham, Law Office of Karen M Billingham, PC); source in `exemplars/SOURCE.md`.
- Overlay: `samples/OVERLAY-answering-brief.pdf` and `.txt`. Page map (ours to filed, word overlap): 1-1 cover 69%, 2-2 supplemental counsel 83%, 3-3 contents 33%, 4-5 index 49%, 5-7 oral argument 76%, 6-8 statement of the case 50%, 7-23 facts 24%, 8-24 objections 31%, 9-28 summary 36%, 10-29 standard of review 55%, 11-31 Reply Issue I 72%, 12-45 and 13-45 Reply Issue III 43% and 50%, 14-49 prayer 53%, 15-51 signature and compliance 33%, 16-51 service 42%. The filer's running footer "Appellee's Brief Page n of 57", its single arabic page sequence and its "Other potential authorities" group are tier 3 and not copied.

## Sample

`samples/INPUT-answering-brief.md` transcribes the exemplar's structure: cover, supplemental list of appellant's counsel, contents, index of authorities (22 authorities in two groups), statement regarding oral argument, statement of the case (a two-column label/text table, as filed), abbreviations and record references, statement of facts (the procedural items only), objections to and motion to strike appendices, summary of argument (with a list), argument (standard of review; Reply Issue I, Point B; Reply Issues III and IV, each with its issue statement as a block quotation), conclusion and prayer (list), signature, certificate of compliance (numbered, generated word count) and certificate of service. The parties' personal and medical detail is omitted and marked in brackets.

Render: 16 pages (cover; ii-iv: supplemental counsel, contents, index; body 1-12). Every page rendered at 60 dpi and viewed on 2026-10-16; review in `reviews/2026-10-16.md`.

## Known gaps

1. One filer for this doc type (Karen M. Billingham); tier 2 judged against this filer and the Palmer exemplars of the other doc types.
2. The statement-of-the-case table splits between rows across a page break (row 2 on page 1, row 3 on page 2). Rows are never split; the break between rows is accepted (the filer's table sits on one page because its statement starts a page).
3. Typst's widow and orphan control leaves two to three empty lines at the foot of some body pages (page 8). Accepted.
4. A citation paragraph longer than 50 characters after a block quotation is indented. OPEN, tier 2 (see the opening brief).
5. Rule text is secondary. `tools/check.sh` not run; no stamp.

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/`): `samples/OUTPUT-answering-brief.docx` and `.docx.pdf` are from the earlier 8-page sample and were **not regenerated** on 2026-10-16 (no `soffice` on this box). The docx filter predates the placeholder contract (`{{contents}}`, `{{identity}}`, `{{signature}}`, `{{signer}}`, `{{word-count}}`) and the frontmatter `identity` and `authorities` lists, so a re-render would print the placeholders literally and omit the identity list and the index. BLOCKED until `docx/texapp.lua` is updated.
- BLOCKED: tools/check.sh docx gates 0 to 3 not run (no `checks.yaml`, `rules.md` at the level `check.sh` reads).
- **latex**: not built for this doc type.
