// Entry point. tools/render.sh compiles it with the court folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-<id>.md \
//     typst/main.typ out.pdf
#import "txeb-adversary-complaint.typ": txeb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#txeb-adversary-complaint(meta, body)
