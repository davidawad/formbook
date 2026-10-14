// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-<id>.md \
//     typst/main.typ out.pdf
#import "prb-adversary-complaint.typ": prb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-organic-power-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#prb-adversary-complaint(meta, body)
