# Appellee's Brief template (Texas Court of Appeals)

Typst template for an appellee's brief in a Texas court of appeals (TRAP 38.2). The district and seat on the cover come from the frontmatter (`district`, `seat`; default Fifth District at Dallas, the court of the exemplar). Engines: typst (`typst/`, primary) and docx (`docx/`), on one cross-engine layout (see "Layout" and "Engines").

The template module `typst/texapp-answering-brief.typ` is the same code as the opening brief's (`../opening-brief/typst/texapp-opening-brief.typ`); only the header comment differs. The rule table, the markdown contract and the list of 2026-10-16 changes are in `../opening-brief/README.md` and apply here unchanged.

## Governing rules (checked 2026-10-15, re-attempted 2026-10-16)

The primary TRAP PDF (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf) returned HTTP 403 on 2026-10-15 and 2026-10-16; rule text is from secondary summaries. Rules specific to this doc type:

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 38.2(a)(1) | an appellee's brief follows Rule 38.1, except that the identity list is needed only to supplement or correct the appellant's, and the statement of the case, issues and facts may be omitted unless the appellee is dissatisfied with the appellant's | the sample's front matter is a "Supplemental List of Appellant's Counsel" (`identity`); its body keeps statements of the case and facts because the filer did | secondary |
| TRAP 9.4(i)(2)(B) | 15,000 words, computer-generated | `word-limit` = 15000; the count typed in the markdown (literal) in the certificate | secondary |
| TRAP 9.4(c)-(e), (g), 39.7, 9.5 | as for the opening brief | as for the opening brief | secondary |

## Exemplar and overlay

- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf` (58 pages; Karen M. Billingham, Law Office of Karen M Billingham, PC); source in `usage/SOURCE.md`.
- Overlay: `usage/OVERLAY-answering-brief.pdf` and `.txt`. Page map (ours to filed, word overlap): 1-1 cover 69%, 2-2 supplemental counsel 83%, 3-3 contents 33%, 4-5 index 49%, 5-7 oral argument 76%, 6-8 statement of the case 50%, 7-23 facts 24%, 8-24 objections 31%, 9-28 summary 36%, 10-29 standard of review 55%, 11-31 Reply Issue I 72%, 12-45 and 13-45 Reply Issue III 43% and 50%, 14-49 prayer 53%, 15-51 signature and compliance 33%, 16-51 service 42%. The filer's running footer "Appellee's Brief Page n of 57", its single arabic page sequence and its "Other potential authorities" group are tier 3 and not copied.

## Sample

`usage/INPUT-answering-brief.md` transcribes the exemplar's structure: cover, supplemental list of appellant's counsel, contents, index of authorities (22 authorities in two groups), statement regarding oral argument, statement of the case (a two-column label/text table, as filed), abbreviations and record references, statement of facts (the procedural items only), objections to and motion to strike appendices, summary of argument (with a list), argument (standard of review; Reply Issue I, Point B; Reply Issues III and IV, each with its issue statement as a block quotation), conclusion and prayer (list), signature, certificate of compliance (numbered, generated word count) and certificate of service. The parties' personal and medical detail is omitted and marked in brackets.

Render (2026-10-22): 18 pages in typst and docx alike (cover; ii-v: supplemental counsel, contents, index on two pages; body 1-13). Every page of both renders viewed at 50 dpi; review in `reviews/2026-10-22.md`.

## Known gaps

1. One filer for this doc type (Karen M. Billingham); tier 2 judged against this filer and the Palmer exemplars of the other doc types.
2. The statement-of-the-case table splits between rows across a page break (row 2 on page 1, row 3 on page 2). Rows are never split; the break between rows is accepted (the filer's table sits on one page because its statement starts a page).
3. Typst's widow and orphan control leaves two to three empty lines at the foot of some body pages (page 8). Accepted.
4. A citation paragraph longer than 50 characters after a block quotation is indented. OPEN, tier 2 (see the opening brief).
5. Rule text is secondary. `tools/check.sh` runs on the folder: typst and docx 0 failed, XENG-001..003 PASS (2026-10-22).

## Layout (2026-10-22, fb-595.68.36)

Typst and docx are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 14 pt on both engines (TRAP 9.4(e); the docx had set EB Garamond); every line a box of its pitch, the boxes touching: 31.5 pt for the double-spaced text (TRAP 9.4(d)), 16.1 pt single lines for the cover, headings, block quotations and issues, label rows, signature, contents and index, 13.8 pt for the 12 pt footnotes (4 pt apart, 12.1 pt clear of the text above the rule); headings at 14 pt (were typst's 1.4 and 1.2 em sizes): level 1 bold capitals centered 24 pt above and 12 pt below, level 2 bold, level 3 bold italic, level 4 italic, 16 pt above and 8 pt below; quotations 0.5 in in on both sides, 14 pt around them; the identity of parties and a two-column table as label rows (label 2.25 in, text 0.25 in after it, rows never split, an empty 14 pt line between rows); contents and index rows with a 36 pt (contents) and 56 pt (index, or the page list's width when longer) page column, wrapped rows hanging 0.25 in, contents levels stepping 0.4 in; the last list item or paragraph before the signature kept with it; each certificate kept with its signer; the page number in a single line, none on the cover (page i), lower roman to the end of the index, arabic from the body. Word count (TRAP 9.4(i)(1)) the same in both engines (counted on the markdown).

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/texapp.lua`, `docx/reference.xml`; one copy in each of the opening, answering and reply folders): `fb render` builds the reference document from `reference.xml` (base="xengine", the face only as `{font}`) and runs the filter; the contents and index page numbers come from needles (FORMBOOK_NEEDLES) looked up in the LibreOffice PDF until they settle (were `docx/render.sh`'s two passes; `build-reference.sh` and the binary `reference.docx` are gone). Word may paginate slightly differently from LibreOffice; the page numbers are LibreOffice's (docs/DOCX.md).
- Gate 4: `params.cross_engine: gate` (`eval.yaml`): the docx breaks every line and page as typst does (XENG-001..003).
- **latex**: not built for this doc type.
