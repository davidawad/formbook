// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "waeb-adversary-complaint.typ": complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-waeb-adversary-complaint-icap.md"))
#let (meta, body) = split-frontmatter(src)
#complaint(meta, body)
