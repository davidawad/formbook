// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "vawb-adversary-complaint.typ": vawb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-vawb-adversary-complaint-rosen.md"))
#let (meta, body) = split-frontmatter(src)
#vawb-adversary-complaint(meta, body)
