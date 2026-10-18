// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "tnmd-complaint.typ": tnmd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-tnmd-complaint-doge.md"))
#let (meta, body) = split-frontmatter(src)
#tnmd-complaint(meta, body)
