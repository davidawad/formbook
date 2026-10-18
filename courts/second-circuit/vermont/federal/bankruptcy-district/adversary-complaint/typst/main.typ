// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "vtb-adversary-complaint.typ": vtb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-vtb-adversary-complaint-fouracre.md"))
#let (meta, body) = split-frontmatter(src)
#vtb-adversary-complaint(meta, body)
