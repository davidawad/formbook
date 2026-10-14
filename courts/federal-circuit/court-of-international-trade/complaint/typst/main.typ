// Entry point. tools/render.sh compiles this file with this doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "cit-complaint.typ": cit-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-trek-bicycle.md"))
#let (meta, body) = split-frontmatter(src)
#cit-complaint(meta, body)
