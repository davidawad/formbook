// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ohnb-adversary-complaint.typ": ohnb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ohnb-adversary-complaint-sample.md"))
#let (meta, body) = split-frontmatter(src)
#ohnb-adversary-complaint(meta, body)
