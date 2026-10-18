// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "bap6-opening-brief.typ": *

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#show: brief-style
#brief(meta, body)
