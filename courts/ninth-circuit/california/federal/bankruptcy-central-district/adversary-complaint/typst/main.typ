// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "cacb-adversary-complaint.typ": cacb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-cacb-adversary-complaint-lpgmarshackadversary.md"))
#let (meta, body) = split-frontmatter(src)
#cacb-adversary-complaint(meta, body)
