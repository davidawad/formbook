# Fonts policy

Every template compiles with the vendored fonts in `fonts/`, plus the one pinned Times New Roman directory where required. A court's rules name a typeface; this file says which installed or vendored family the template uses.

## Rules

1. **Vendored or pinned licensed install.** Fonts with an open licence that permits redistribution live in `fonts/`, each family in its own folder with its licence text beside the files. Times New Roman is the exception: it is licensed and installed separately on the build box, never committed; renders use only the four Times New Roman 2.82 files (Debian `ttf-mscorefonts-installer`, as on the box image) whose SHA-256 is pinned in `data/render-pin.json`, staged alone in a temp directory. The macOS system copy (`/System/Library/Fonts/Supplemental`, version 5.01) has different outlines and metrics and is never used: copy the four `Times_New_Roman*.ttf` files from a box to `~/.local/share/formbook/msttcorefonts` (or set `FB_TNR_DIR`). The exact installed font is asserted in Gate 1.
2. **Unpinned system fonts are never used.** Typst runs with `--ignore-system-fonts` and explicit font paths: `fonts/` and, for Times New Roman, the staged pinned files from rule 1. `fb render` also refuses to run unless `typst --version` equals the `typst` pin in `data/render-pin.json` (the box image pins the same release). A missing font is an error, not a silent fallback. Any typst warning fails the render.
3. **Court-named faces map to the approved face** (substitution table below). A template whose court rules name a face uses that face's approved choice. A Times exemplar uses Times New Roman first and Liberation Serif as fallback. Other court-named faces use their listed substitute. A court that names no face gets Liberation Serif. EB Garamond is used only where a court's rules name Garamond. A ruling over the audit is recorded on the exemplar's entry in `data/exemplar-fonts.json` as `template_face` (the face the template must declare; `face` stays the audited match) with the reason in `note`: `fb lint fonts` checks the template against `template_face`, and a `template_face` of Times New Roman requires the embedded `TimesNewRomanPSMT` as a Times exemplar does (e.g. `eighth-circuit/court-of-appeals/reply-brief`: Georgia exemplar, Times New Roman by David's 2026-10-17 ruling, fb-595.54.9).
4. **The embedded font names are asserted** (`pdffonts`, per `docs/EVAL-LOOP.md` R3). A template that embeds anything outside the family it declares is meant to fail Gate 1.
5. **No font is modified.** Renaming and reserved-name clauses in the licences only bite on modified versions; none are made here.

Times New Roman Typst renders go through the Rust renderer so it can add the pinned platform directory while retaining `--ignore-system-fonts`:

```sh
cargo run -q --manifest-path tools/fb/Cargo.toml -- render <doc-type-dir> usage/INPUT-<id>.md
```

`tools/check.sh` routes its Typst render through the same Rust path. For LaTeX the target is stock pdflatex on stock TeX Live (fb-595.45): a Times template loads `\usepackage{newtxtext,newtxmath}` (TeXGyreTermesX, NewTX: metric-compatible with Times New Roman, in every TeX Live), and for the latex engine only Gate 1 accepts TeXGyreTermesX, TeX Gyre Termes or NewTX where the template declares Times New Roman (`TNR-EMBEDDED`, the declared-family check); any other face still fails. Templates not yet migrated select Times New Roman through fontspec (falling back to Liberation Serif) and build with tectonic.

## Vendored families

| Folder | Faces | Licence (text in folder) | Upstream | Used for |
|---|---|---|---|---|
| `fonts/eb-garamond/` | Regular, Italic, Bold, BoldItalic (`.otf`) | SIL OFL 1.1 (`OFL.txt`) | EB Garamond, Octavio Pardo et al. | Garamond requirements only (a court rule that names Garamond) |
| `fonts/liberation-serif/` | Regular, Italic, Bold, BoldItalic (`.ttf`) | SIL OFL 1.1 (`OFL.txt`) | Liberation Fonts 2.1.5, <https://github.com/liberationfonts/liberation-fonts> (Google, Red Hat) | Default text face (no face named); fallback for Times New Roman |
| `fonts/tex-gyre-schola/` | Regular, Italic, Bold, BoldItalic (`.otf`) | GUST Font License, an LPPL-equivalent (`GUST-FONT-LICENSE.txt`) | TeX Gyre Schola 2.609 (31 Mar 2026), GUST e-foundry, <https://www.gust.org.pl/projects/e-foundry/tex-gyre/schola> | Century Schoolbook requirements |
| `fonts/tex-gyre-termes/` | Regular, Italic, Bold, BoldItalic (`.otf`) | GUST Font License (`GUST-FONT-LICENSE.txt`) | TeX Gyre Termes 2.609, GUST e-foundry, <https://www.gust.org.pl/projects/e-foundry/tex-gyre/termes> | Times alternate |
| `fonts/tex-gyre-pagella/` | Regular, Italic, Bold, BoldItalic (`.otf`) | GUST Font License | TeX Gyre Pagella 2.609, <https://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella> | Palatino / Book Antiqua requirements |
| `fonts/tex-gyre-bonum/` | Regular, Italic, Bold, BoldItalic (`.otf`) | GUST Font License | TeX Gyre Bonum 2.609, <https://www.gust.org.pl/projects/e-foundry/tex-gyre/bonum> | Bookman requirements |

Other families (Liberation Sans/Mono, TeX Gyre Heros/Cursor, Carlito, Caladea, Gelasio, a Tahoma stand-in) are vendored by sibling changes under fb-595.7; their folders carry their own `SOURCE.md`. Each folder's `SOURCE.md` records URL and SHA-256.

All the vendored families are free to use, modify and redistribute, including in a distribution that also carries GPL v3 code. The fonts stay under their own licences; each licence text sits next to the files it covers. The repository's own licence is still `TBD` in `README.md`, so this note does not settle the repo licence.

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
| Century Expanded (named by a court) | Court rule | **TeX Gyre Schola** (visual stand-in) | Visual only. See "Century Expanded" below. |
| Times New Roman, 14-pt, proportional (PTAB) | 37 C.F.R. § 42.6(a)(2)(ii), <https://www.law.cornell.edu/cfr/text/37/42.6> ("14-point, Times New Roman proportional font, with normal spacing, must be used") | **Times New Roman**, Liberation Serif fallback | Primary font is the licensed Microsoft font installed separately on build boxes; Gate 1 requires embedded `TimesNewRomanPSMT`. |
| Times / Times New Roman (named by a court, any other rule; or exemplar uses Times) | Court rule or exemplar audit | **Times New Roman**, Liberation Serif fallback | Primary font is the licensed Microsoft font installed separately on build boxes; Gate 1 requires embedded `TimesNewRomanPSMT`. |
| Garamond (named by a court) | Court rule | **EB Garamond** | Not metric-compatible with any commercial Garamond. Line breaks, page count and length limits will differ from a filing set in a commercial Garamond; check the length gate against the rule's limit, not against a filed sample. |
| Palatino / Book Antiqua (named by a court) | Court rule | **TeX Gyre Pagella** | Visual only. |
| No face named (the usual case) | — | **Liberation Serif** | Metric-compatible with Times New Roman. |

A court's rule text decides the requirement; this table only says which vendored family stands in. If a rule names a face not in the table, add a row here in the same change as the template, with the rule cited.

Size under the default face. Templates written while EB Garamond was the default often set 13 pt "because EB Garamond sets smaller than Times". That reason is gone: Liberation Serif has Times metrics, so the rule's own floor (usually 12 pt) is the size, unless the rule asks for more. Measured with typst 0.15.0 on the vendored files (2026-10-17): a pangram at 100 pt is 17.15 em wide in EB Garamond and 18.27 em in Liberation Serif, so 12 pt Liberation Serif sets about as many words per line as 13 pt EB Garamond did; the default line box (cap height) is 0.650 em in EB Garamond and 0.655 em in Liberation Serif, so leading computed for one holds for the other to within 0.1 pt per line at 14 pt.

### Full substitution table

The Typst name is exactly what a template passes to `font:`; the first five rows' names were read from the font files with `fc-scan`. Folders for other agents' families are given by their expected upstream names; confirm with `fc-scan` when they land.

| Court-named face | Substitute (Typst family name) | Folder under `fonts/` | Licence | Fit |
|---|---|---|---|---|
| Times New Roman, Times | `Times New Roman` (primary), `Liberation Serif` (fallback) | pinned system install; `liberation-serif/` | proprietary install; SIL OFL 1.1 | Primary exact; fallback metric-compatible |
| Times New Roman, Times (alternate visual substitute) | `TeX Gyre Termes` | `tex-gyre-termes/` | GUST FL | Visual (Times clone, URW Nimbus Roman lineage) |
| Century Schoolbook, New Century Schoolbook, "Century family" | `TeX Gyre Schola` | `tex-gyre-schola/` | GUST FL | Metric-compatible with the Adobe base-35 New Century Schoolbook AFMs |
| Century Expanded | `TeX Gyre Schola` | `tex-gyre-schola/` | GUST FL | Visual only |
| Georgia | `Gelasio` | `gelasio/` | SIL OFL 1.1 | Metric-compatible (designed as a Georgia match) |
| Arial | `Liberation Sans` (metric-compatible choice; do not use Heros for Arial, it is not guaranteed Arial-metric) | `liberation-sans/` | SIL OFL 1.1 | Metric-compatible |
| Helvetica | `TeX Gyre Heros` (Helvetica only) | `tex-gyre-heros/` | GUST FL | Visual (Helvetica clone) |
| Courier New | `Liberation Mono` | `liberation-mono/` | SIL OFL 1.1 | Metric-compatible |
| Courier | `TeX Gyre Cursor` | `tex-gyre-cursor/` | GUST FL | Visual (Courier clone) |
| Calibri | `Carlito` | `carlito/` | SIL OFL 1.1 | Metric-compatible |
| Cambria | `Caladea` | `caladea/` | SIL OFL 1.1 or Apache 2.0 (per upstream; check the folder) | Metric-compatible |
| Book Antiqua, Palatino, Palatino Linotype | `TeX Gyre Pagella` | `tex-gyre-pagella/` | GUST FL | Visual only |
| Bookman, Bookman Old Style | `TeX Gyre Bonum` | `tex-gyre-bonum/` | GUST FL | Visual only |
| Tahoma | `DejaVu Sans` | `dejavu-sans/` | Bitstream Vera / DejaVu licence (check the folder) | Visual fallback only; NOT metric-compatible, so pagination may differ. See `fonts/TAHOMA-NOTE.md` |
| Equity (Butterick) | `Liberation Serif` (alternate `TeX Gyre Termes`) | not vendorable | commercial | Visual only; see below |
| Garamond | `EB Garamond` | `eb-garamond/` | SIL OFL 1.1 | Visual only |
| No face named (default: Liberation Serif unless exemplar is Times) | `Liberation Serif` | `liberation-serif/` | SIL OFL 1.1 | Metric-compatible |

### Century Expanded

Not vendored. Century Expanded (Morris Fuller Benton, ATF, 1900s) is a commercial typeface in current digital form; no free font of that exact name exists. Candidates checked:

- TeX Gyre Schola: a Century Schoolbook clone (GUST FL, redistributable). Century Schoolbook is Benton's descendant of Century Expanded, so it is the nearest lineage; it is visually close but not identical (Schoolbook is a sturdier text-school redraw). Chosen stand-in.
- URW C059 (urw-base35, ArtifexSoftware, <https://github.com/ArtifexSoftware/urw-base35-fonts>): also a Century Schoolbook clone, licensed AGPL-3.0 with a PostScript/PDF-embedding exception per Debian's copyright file (<https://doc.duckcorp.org/cgi-bin/dwww/usr/share/doc/fonts-urw-base35/copyright>). AGPL-3.0 may be combined with GPL v3 (AGPL section 13), so it is likely vendorable, but it is the same design as Schola, adds nothing, and brings a second copyleft licence. Not vendored.
- Academico (OFL, Century-derived per a forum report, <https://forums.steinberg.net/t/academico-open-font-license/114847>): no verified upstream repository or licence file found. Not vendored.
- Libre Baskerville, Merriweather (OFL): different designs. Not Century.

SCOTUS Rule 33.1(b) lists "New Century Schoolbook" and "Century Schoolbook" alongside Century Expanded, so Schola satisfies the rule's own text. A court naming only Century Expanded is a visual-only substitution.

### Equity

Not vendorable. Equity (Matthew Butterick, MB Type) is commercial and licensed per purchase; its licence does not allow redistributing the font files in a public repo (<https://mbtype.com/>; licence text not independently read here, so confirm before relying on this). Stand-in: Liberation Serif, alternate TeX Gyre Termes. Butterick describes Equity as fitting about as many words per page as Times New Roman, so a Times-metric face is the safer fit for page and length limits; it is visual-only, and the result will not look like Equity. A filer who owns Equity can set it by hand outside this repo.

### Finding which face a court requires

Check the court's `rules.md` (or the `README.md` "Typeface" row) in its folder under `courts/`, and the cited rule text. Then use that face's substitute from the table. Templates must use the substitute of the court-named face wherever the rules name one, and Liberation Serif (Times New Roman substitute) where they name none. EB Garamond only stands in for a court-named Garamond. If a rule names a face missing from the table, add a row in the same change.

## Proving a family works

Each new family has a one-page typst test under `fonts/tests/`. It exercises regular, bold, italic and bold italic, and must compile with zero warnings:

```sh
typst compile --font-path fonts --ignore-system-fonts fonts/tests/liberation-serif.typ out/liberation-serif.pdf
typst compile --font-path fonts --ignore-system-fonts fonts/tests/tex-gyre-schola.typ out/tex-gyre-schola.pdf
# likewise tex-gyre-termes, tex-gyre-pagella, tex-gyre-bonum
pdffonts out/liberation-serif.pdf
pdffonts out/tex-gyre-schola.pdf
```

`out/` is git-ignored. The names below are as `pdffonts` prints them, with the random subset prefix (`ABCDEF+`) and the `-Identity-H` encoding suffix left out:

| Test | Embedded font names (`pdffonts`) |
|---|---|
| `liberation-serif.typ` | `LiberationSerif`, `LiberationSerif-Bold`, `LiberationSerif-Italic`, `LiberationSerif-BoldItalic` (CID TrueType, all embedded) |
| `tex-gyre-schola.typ` | `TeXGyreSchola-Regular`, `TeXGyreSchola-Bold`, `TeXGyreSchola-Italic`, `TeXGyreSchola-BoldItalic` (CID Type 0C, all embedded) |
| `tex-gyre-termes.typ` | `TeXGyreTermes-Regular`, `-Bold`, `-Italic`, `-BoldItalic` (CID Type 0C, embedded) |
| `tex-gyre-pagella.typ` | `TeXGyrePagella-Regular`, `-Bold`, `-Italic`, `-BoldItalic` (CID Type 0C, embedded) |
| `tex-gyre-bonum.typ` | `TeXGyreBonum-Regular`, `-Bold`, `-Italic`, `-BoldItalic` (CID Type 0C, embedded) |

All tests compiled with exit 0 and an empty stderr under the flags above, on typst 0.15.0 (Termes, Pagella, Bonum checked 2026-10-14).
