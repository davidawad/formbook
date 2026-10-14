// Entrypoint. Compile with the court's doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "nywb-adversary-complaint.typ": nywb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-wallach-rothstein-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#nywb-adversary-complaint(meta, body)
