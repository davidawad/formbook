# Appellant's Reply Brief template (Texas Court of Appeals)

Typst template for an appellant's reply brief in a Texas court of appeals (TRAP 38.3). The district and seat on the cover come from the frontmatter (`district`, `seat`; default Fifth District at Dallas, the court of the exemplar). Engines: typst (`typst/`, primary) and docx (`docx/`), on one cross-engine layout (see "Layout" and "Engines").

The template module `typst/texapp-reply-brief.typ` is the opening brief's code (`../opening-brief/typst/texapp-opening-brief.typ`) with `word-limit` set to 7,500. The rule table, the markdown contract and the 2026-10-16 changes are in `../opening-brief/README.md`.

## Governing rules (checked 2026-10-15, re-attempted 2026-10-16)

The primary TRAP PDF (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf) returned HTTP 403 on 2026-10-15 and 2026-10-16; rule text is from secondary summaries. Rules specific to this doc type:

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 38.3 | the appellant may file a reply addressing any matter in the appellee's brief; no prescribed contents | front matter is empty (no `{{identity}}`); contents and index are still generated, as the filer did | secondary |
| TRAP 9.4(i)(2)(C) | 7,500 words for a computer-generated reply brief in a court of appeals | `word-limit` = 7500; `assert` fails the render above it; the count typed in the markdown (literal) in the certificate | secondary |
| TRAP 9.4(c)-(e), (g), 39.7, 9.5 | as for the opening brief | as for the opening brief | secondary |
| Fifth Court local rules | local limits (a combined reply and cross-appellee brief has its own limit) | not encoded | secondary |

## Exemplar and overlay

- Exemplar: `usage/FILED-EXAMPLE-reply-brief.pdf` (10 pages; Scott H. Palmer, P.C.); source in `usage/SOURCE.md`.
- Overlay: `usage/OVERLAY-reply-brief.pdf` and `.txt`. Page map (ours to filed, word overlap): 1-1 cover 73%, 2-2 contents 46%, 3-2 index 50%, 4-3 94%, 5-4 94%, 6-5 75%, 7-6 50%, 8-7 prayer and signature 46%, 9-8 certificates 40%. The filer puts contents and authorities on one page; the template gives each its own page (tier 3).

## Sample

`usage/INPUT-reply-brief.md` is a full transcription of the filed reply: cover (with ORAL ARGUMENT REQUESTED and ACCELERATED APPEAL), contents, index of authorities, address to the court, First Reply Issue, Second Reply Issue, conclusion and prayer (list), signature, certificate of compliance (generated word count, 1,077 words) and certificate of service with two recipients. The appellant's medical and educational details are bracketed out.

Render (2026-10-22): 10 pages in typst and docx alike (cover; ii contents; iii index; body 1-7). Every page of both renders viewed at 50 dpi; review in `reviews/2026-10-22.md`.

## Known gaps

1. One filer for this doc type (the same filer as the opening brief).
2. The filed reply is short, so the sample cannot reach more pages without invented text; 9 pages is the whole brief.
3. Rule text is secondary. `tools/check.sh` runs on the folder: typst and docx 0 failed, XENG-001..003 PASS (2026-10-22).

## Layout (2026-10-22, fb-595.68.36)

Typst and docx are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 14 pt on both engines (TRAP 9.4(e); the docx had set EB Garamond); every line a box of its pitch, the boxes touching: 31.5 pt for the double-spaced text (TRAP 9.4(d)), 16.1 pt single lines for the cover, headings, block quotations and issues, label rows, signature, contents and index, 13.8 pt for the 12 pt footnotes (4 pt apart, 12.1 pt clear of the text above the rule); headings at 14 pt (were typst's 1.4 and 1.2 em sizes): level 1 bold capitals centered 24 pt above and 12 pt below, level 2 bold, level 3 bold italic, level 4 italic, 16 pt above and 8 pt below; quotations 0.5 in in on both sides, 14 pt around them; the identity of parties and a two-column table as label rows (label 2.25 in, text 0.25 in after it, rows never split, an empty 14 pt line between rows); contents and index rows with a 36 pt (contents) and 56 pt (index, or the page list's width when longer) page column, wrapped rows hanging 0.25 in, contents levels stepping 0.4 in; the last list item or paragraph before the signature kept with it; each certificate kept with its signer; the page number in a single line, none on the cover (page i), lower roman to the end of the index, arabic from the body. Word count (TRAP 9.4(i)(1)) the same in both engines (counted on the markdown).

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/texapp.lua`, `docx/reference.xml`; one copy in each of the opening, answering and reply folders): `fb render` builds the reference document from `reference.xml` (base="xengine", the face only as `{font}`) and runs the filter; the contents and index page numbers come from needles (FORMBOOK_NEEDLES) looked up in the LibreOffice PDF until they settle (were `docx/render.sh`'s two passes; `build-reference.sh` and the binary `reference.docx` are gone). Word may paginate slightly differently from LibreOffice; the page numbers are LibreOffice's (docs/DOCX.md).
- Gate 4: `params.cross_engine: gate` (`eval.yaml`): the docx breaks every line and page as typst does (XENG-001..003).
- **latex**: not built for this doc type.
