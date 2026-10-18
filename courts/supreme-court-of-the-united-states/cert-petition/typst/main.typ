// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "scotus-cert-petition-cert-petition.typ": scotus-cert-petition, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-cert-petition.md"))
#let (meta, body) = split-frontmatter(src)
#scotus-cert-petition(meta, body)
