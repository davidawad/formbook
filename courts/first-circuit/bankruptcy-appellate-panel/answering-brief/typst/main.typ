// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "bap1-answering.typ": bap1-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-generic-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#bap1-brief(meta, body)
