// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "afcca-answering-brief.typ": afcca-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-douglas-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#afcca-brief(meta, body)
