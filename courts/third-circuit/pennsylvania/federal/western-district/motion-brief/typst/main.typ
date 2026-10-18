// Entrypoint. tools/render.sh compiles it with the document-type folder as --root (the folder that holds this typst/):
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md typst/main.typ out.pdf
#import "pawd-motion-brief.typ": pawd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-pawd-motion-brief-albrightmemorandum.md"))
#let (meta, body) = split-frontmatter(src)
#pawd-motion-brief(meta, body)
