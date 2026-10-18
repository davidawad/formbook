// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "txsb-motion-brief.typ": txsb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-txsb-motion-brief-cmgfunding.md"))
#let (meta, body) = split-frontmatter(src)
#txsb-motion-brief(meta, body)
