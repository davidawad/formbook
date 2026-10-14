// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "bap8-answering-brief.typ": bap8-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-synthetic-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#bap8-brief(meta, body)
