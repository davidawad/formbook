# Fonts policy

Every template compiles with the vendored fonts in `fonts/` and nothing else. A court's rules name a typeface; this file says which vendored family stands in for it.

## Rules

1. **Vendored only.** Only fonts with an open licence that permits redistribution live in `fonts/`, each family in its own folder with its licence text beside the files.
2. **System fonts are never used.** Typst runs as `typst compile --font-path fonts --ignore-system-fonts` (`tools/render.sh`, `tools/render-latex.sh`, and the docx path). A missing font is an error, not a silent fallback. Any typst warning fails the render.
3. **Court-named faces map to a free equivalent** (table below). A court that names no face gets EB Garamond.
4. **The embedded font names are asserted** (`pdffonts`, per `docs/EVAL-LOOP.md` R3). A template that embeds anything outside the family it declares is meant to fail Gate 1.
5. **No font is modified.** Renaming and reserved-name clauses in the licences only bite on modified versions; none are made here.

## Vendored families

| Folder | Faces | Licence (text in folder) | Upstream | Used for |
|---|---|---|---|---|
| `fonts/eb-garamond/` | Regular, Italic, Bold, BoldItalic (`.otf`) | SIL OFL 1.1 (`OFL.txt`) | EB Garamond, Octavio Pardo et al. | Default text face; Garamond requirements |
| `fonts/liberation-serif/` | Regular, Italic, Bold, BoldItalic (`.ttf`) | SIL OFL 1.1 (`OFL.txt`) | Liberation Fonts 2.1.5, <https://github.com/liberationfonts/liberation-fonts> (Google, Red Hat) | Times New Roman requirements |
| `fonts/tex-gyre-schola/` | Regular, Italic, Bold, BoldItalic (`.otf`) | GUST Font License, an LPPL-equivalent (`GUST-FONT-LICENSE.txt`) | TeX Gyre Schola 2.609 (31 Mar 2026), GUST e-foundry, <https://www.gust.org.pl/projects/e-foundry/tex-gyre/schola> | Century Schoolbook requirements |

All three are free to use, modify and redistribute, including in a distribution that also carries GPL v3 code. The fonts stay under their own licences; each licence text sits next to the files it covers. The repository's own licence is still `TBD` in `README.md`, so this note does not settle the repo licence.

### Provenance and checksums

Upstream publishes no checksum for these archives. The values below are SHA-256 of the archives as downloaded on 2026-10-14; anyone can re-download and compare.

| Archive | SHA-256 |
|---|---|
| `liberation-fonts-ttf-2.1.5.tar.gz` (GitHub release 2.1.5 asset) | `7191c669bf38899f73a2094ed00f7b800553364f90e2637010a69c0e268f25d0` |
| `tg_schola-otf-2_609-31_03_2026.zip` (GUST) | `40f76a93a159ba7a76d6fe2ac6a54b7eb480afc94557742505a847c571da13fc` |
| `tg_schola-TDS_distr-2_609-31_03_2026.zip` (GUST; source of the README and the OTFs, which are byte-identical to the OTF archive's) | `6e95688bdc0552a953d6e1cb442f0d6be95af746d0db5233353486e6d2f42567` |
| `GUST-FONT-LICENSE.txt` (<http://www.gust.org.pl/fonts/licenses/GUST-FONT-LICENSE.txt>, version 1.0, 22 June 2009) | `5eb61bb836bb1845ef668717cb15b382e997748ce2629e4388cc5e4c3fa4e433` |

The Liberation `.ttf` files and `OFL.txt` are copied unchanged from the tarball; the Schola `.otf` files and `README-TeX-Gyre-Schola.txt` are copied unchanged from the GUST archives.

## Substitution table

Court requirement → vendored family. The rule column is the primary source for the requirement; the family column is what the template declares.

| Court requirement | Rule (primary source) | Vendored family | Metric compatibility |
|---|---|---|---|
| Century family, 12-pt, booklet format (SCOTUS) | Rules of the Supreme Court of the United States, Rule 33.1(b), <https://www.law.cornell.edu/rules/supct/rule_33> (text: "typeset in Century family (e.g., Century Expanded, New Century Schoolbook, or Century Schoolbook) 12-point type") | **TeX Gyre Schola** | Upstream README: glyph widths are consistent with the Adobe base-35 New Century Schoolbook AFMs (`ncr`, `ncb`, `nci`, `ncbi`). A real Century Schoolbook clone, not the original font. |
| Century Schoolbook / New Century Schoolbook (named by a court) | Court rule | **TeX Gyre Schola** | As above. |
| Century Expanded (named by a court) | Court rule | Not vendored. The upstream README documents Schola as a Century Schoolbook replacement, not Century Expanded; a court that names only Century Expanded needs a decision before a template is written. | — |
| Times New Roman, 14-pt, proportional (PTAB) | 37 C.F.R. § 42.6(a)(2)(ii), <https://www.law.cornell.edu/cfr/text/37/42.6> ("14-point, Times New Roman proportional font, with normal spacing, must be used") | **Liberation Serif** | Upstream README: the family "aims to provide document layout compatibility" with Times New Roman. Designed as a metric-compatible substitute; not checked here against a Times New Roman file, since none is on this box. |
| Times / Times New Roman (named by a court, any other rule) | Court rule | **Liberation Serif** | As above. |
| Garamond (named by a court) | Court rule | **EB Garamond** | Not metric-compatible with any commercial Garamond. Line breaks, page count and length limits will differ from a filing set in a commercial Garamond; check the length gate against the rule's limit, not against a filed sample. |
| Palatino / Book Antiqua (named by a court) | Court rule | Not vendored yet. The planned substitute is TeX Gyre Pagella; it is a follow-up, not part of this change. | — |
| No face named (the usual case) | — | **EB Garamond** | — |

A court's rule text decides the requirement; this table only says which vendored family stands in. If a rule names a face not in the table, add a row here in the same change as the template, with the rule cited.

## Proving a family works

Each new family has a one-page typst test under `fonts/tests/`. It exercises regular, bold, italic and bold italic, and must compile with zero warnings:

```sh
typst compile --font-path fonts --ignore-system-fonts fonts/tests/liberation-serif.typ out/liberation-serif.pdf
typst compile --font-path fonts --ignore-system-fonts fonts/tests/tex-gyre-schola.typ out/tex-gyre-schola.pdf
pdffonts out/liberation-serif.pdf
pdffonts out/tex-gyre-schola.pdf
```

`out/` is git-ignored. The names below are as `pdffonts` prints them, with the random subset prefix (`ABCDEF+`) and the `-Identity-H` encoding suffix left out:

| Test | Embedded font names (`pdffonts`) |
|---|---|
| `liberation-serif.typ` | `LiberationSerif`, `LiberationSerif-Bold`, `LiberationSerif-Italic`, `LiberationSerif-BoldItalic` (CID TrueType, all embedded) |
| `tex-gyre-schola.typ` | `TeXGyreSchola-Regular`, `TeXGyreSchola-Bold`, `TeXGyreSchola-Italic`, `TeXGyreSchola-BoldItalic` (CID Type 0C, all embedded) |

Both tests compiled with exit 0 and an empty stderr under the flags above, on typst 0.15.0.
