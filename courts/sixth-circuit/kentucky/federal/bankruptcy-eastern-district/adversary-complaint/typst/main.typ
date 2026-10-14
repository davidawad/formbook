// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "kyeb-adversary-complaint.typ": kyeb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-kennedy-cambrian-19-51200.md"))
#let (meta, body) = split-frontmatter(src)
#kyeb-adversary-complaint(meta, body)
