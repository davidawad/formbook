// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "akd-complaint.typ": akd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample"))   // required: render.sh passes --input sample=...
#let (meta, body) = split-frontmatter(src)
#akd-complaint(meta, body)
