# Measuring and diffing against the filed exemplar (`fb`)

The acceptance bar is that each template reproduce its filed exemplar as an identical PDF image, in
Typst and LaTeX. These `tools/fb` subcommands measure that. Run them with
`cargo run -q --release --manifest-path tools/fb/Cargo.toml -- <subcommand> ...`.

| Subcommand | What it does |
|---|---|
| `fb measure <pdf>` | Writes measured.json to stdout. Per page: size, text frame, every line (baseline, left, right, size, font, bold/italic, word boxes from `pdftotext -bbox-layout`), rules/boxes/vectors (`pdftocairo -svg`, clipped to the page), images, masked regions, and derived stats (left, pitch, first-line indent, hanging). Fonts come from `pdffonts`. |
| `fb diff <exemplar> <render>` | Staged and localized, with no scores. G0 page count/size, then G1 text frame, then G2 content and order, then G3 identical line breaks and per-line baseline/left/right, then G4 rules/boxes/vectors and line styles. A gate runs only when the earlier gates pass. Each finding is signed (ours minus exemplar) and names the parameter it points at, first divergence first. Exit 1 on failure. |
| `fb diff-selftest <doc-dir> [--engine typst\|latex] [--sample ID] [--write-tolerance]` | Rebuilds a sample twice to measure noise (this sets `tools/fb/tolerance.json`). It then checks that the controls (rebuild, identity wrap) diff clean and that every mutant fails: margin +0.05in, spacing x1.02, size +/-0.5pt, a dropped or swapped paragraph, a forced line break. |
| `fb fetch <doc-dir> [--all-missing-only] [--record]` | Downloads the FILED-EXAMPLEs named in `usage/SOURCE.md`, then checks or records their SHA-256. |
| `fb lint <doc-dir> [--engine typst\|latex\|all]` | Flags template runs of 5+ words that also appear in a filed exemplar but not in `rules.md`. Also flags forced line breaks and literal vertical space outside the named-parameter block, and hard breaks or raw typst/latex in `usage/INPUT-*.md`. |
| `fb match-stamp <doc-dir> [--engine E] [--sample ID] [--exemplar PDF]` | Writes `usage/.match-<engine>.txt` (PASS plus the sha256 of each PDF and its exemplar) only when G0-G4 pass. Otherwise it removes the stamp. |

Masks are applied on both sides: the CM/ECF banner band, clerk stamps, and text on raster images
(signatures) are found automatically. Add other regions in `usage/MASKS.json`:
`{"FILED-EXAMPLE-<id>.pdf": [{"page": 1, "bbox": [x0, y0, x1, y1], "why": "clerk stamp"}]}`.
