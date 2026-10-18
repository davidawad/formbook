// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "afcca-answering-brief.typ": afcca-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-afcca-answering-brief-douglas.md"))
#let (meta, body) = split-frontmatter(src)
#afcca-brief(meta, body)
