// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "flsd-complaint.typ": flsd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-castellanos-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#flsd-complaint(meta, body)
