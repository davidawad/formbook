// Entrypoint. tools/render.sh compiles it with the document-type folder as --root (the folder that holds this typst/):
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md typst/main.typ out.pdf
#import "pawd-motion-brief.typ": pawd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-albright-memorandum.md"))
#let (meta, body) = split-frontmatter(src)
#pawd-motion-brief(meta, body)
