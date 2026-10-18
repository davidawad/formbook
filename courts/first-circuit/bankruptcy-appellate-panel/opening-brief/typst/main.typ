// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "bap1-opening.typ": bap1-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief-2.md"))
#let (meta, body) = split-frontmatter(src)
#bap1-brief(meta, body)
