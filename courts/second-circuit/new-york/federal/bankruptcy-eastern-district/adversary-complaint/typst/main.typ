// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "nyeb-adversary-complaint.typ": nyeb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nyeb-adversary-complaint-toyvation.md"))
#let (meta, body) = split-frontmatter(src)
#nyeb-adversary-complaint(meta, body)
