// Entry point. tools/render.sh compiles it with the court folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "mab-adversary-complaint.typ": mab-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-lassman-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#mab-adversary-complaint(meta, body)
