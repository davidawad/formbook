// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md typst/main.typ out.pdf
#import "nywd-complaint.typ": nywd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-kerrick-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#nywd-complaint(meta, body)
