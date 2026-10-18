// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "bap9-answering-brief.typ": bap9-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-bap9-answering-brief-fictional.md"))
#let (meta, body) = split-frontmatter(src)
#bap9-brief(meta, body)
