// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "ncwd-complaint.typ": ncwd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ncwd-complaint-bell.md"))
#let (meta, body) = split-frontmatter(src)
#ncwd-complaint(meta, body)
