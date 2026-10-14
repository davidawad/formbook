// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "calsuperct-complaint.typ": calsuperct-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/sweetwater-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#calsuperct-complaint(meta, body)
