// Entry point. tools/render.sh compiles it with this folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md typst/main.typ out.pdf
#import "lawd-complaint.typ": lawd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-lawd-complaint-ldil.md"))
#let (meta, body) = split-frontmatter(src)
#lawd-complaint(meta, body)
