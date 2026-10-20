# Folders that still fail the default eval (fb-xye0)

None. `fb eval courts` passes every folder it evaluates (the one skipped folder has its own `checks.yaml`; run `just check` for it).

The folders that used to fail were fixed in the checker or in their template, not by editing INPUTs or loosening a check:

| Was failing | Cause | Fix |
|---|---|---|
| 8 TNR-EMBEDDED folders (nysupct, ttab, msnb, wiwb, iand, sdb, gub, gamd) | `has_times_exemplar` (`tools/fb/src/fonts.rs`) treated an Adobe Times exemplar mapped to `TeX Gyre Termes` as a Times New Roman exemplar | TNR-EMBEDDED applies when the audit's body face is Times New Roman, or Adobe Times mapped to Times itself; Adobe Times mapped to Termes needs only the Termes declaration `fb lint fonts` already demands |
| caed x2, nvb x2, idb, moeb x2, gub | INPUT template directives (`[unnumbered]`, `[sig]`, `[signature]`, `[[TOC]]`, `[[TOA]]`, `[[MEMO]]`, Idaho `: `, Missouri `%`, Guam `§ `) read as paragraph text | `md-blocks.awk` strips or drops them as the template does (default checks only) |
| kywd, kyed, okeb, gand, nmmb | a footnote split across two pages; nmmb defines its footnote in the frontmatter | `gate0.awk` reassembles a note continued at the foot of a later page (at most 3 parts); `md-blocks.awk` reads a frontmatter `footnotes:` map |
| scotus amicus, cert, merits | `pdf-runs.awk` scaled by page width / 612, so every y on the 441 x 666 booklet was inflated; the page number then sat just above the footer line | the scale is the `pdftohtml` zoom; a run is a footer when its middle is in the bottom margin; `* * *`, a star that cannot open emphasis, and lists inside a quote read as CommonMark does |
| lamb | table cells read in line order, and the header row repeats after a page break | a table row's cells are found whole, shortest first, in any order within the row; a repeated header row is ignored |
| gub, gamd (own layout) | text in the 1 in margins: 28 numbered lines, 0.75 in right margin, line numbers inside the margin (gub); a footnote mark rising above the top margin (gamd) | gub: 27 lines, 1 in right margin, numbers end at the margin; gamd: top margin 1 in + 4 pt |
