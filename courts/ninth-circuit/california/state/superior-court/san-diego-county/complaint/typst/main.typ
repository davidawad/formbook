// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "calsuperct-sandiego-complaint.typ": calsuperct-sandiego-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-sweetwater-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#calsuperct-sandiego-complaint(meta, body)
