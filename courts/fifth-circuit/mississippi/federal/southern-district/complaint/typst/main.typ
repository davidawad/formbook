// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "mssd-complaint.typ": mssd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-mariano-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#mssd-complaint(meta, body)
