// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-<id>.md \
//     typst/main.typ out.pdf
#import "acca-opening-brief.typ": acca-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief-2.md"))
#let (meta, body) = split-frontmatter(src)
#acca-brief(meta, body)
