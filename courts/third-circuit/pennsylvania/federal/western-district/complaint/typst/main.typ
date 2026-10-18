// Entrypoint. tools/render.sh compiles it with the court folder as --root (the folder that holds this typst/):
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md typst/main.typ out.pdf
#import "pawd-complaint.typ": pawd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#pawd-complaint(meta, body)
