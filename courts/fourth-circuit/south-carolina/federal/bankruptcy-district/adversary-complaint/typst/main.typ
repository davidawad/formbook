// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "scb-adversary-complaint.typ": scb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-scb-adversary-complaint-haiglerjoye.md"))
#let (meta, body) = split-frontmatter(src)
#scb-adversary-complaint(meta, body)
