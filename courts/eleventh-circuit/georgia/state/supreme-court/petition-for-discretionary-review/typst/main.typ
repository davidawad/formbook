// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ga-petition-for-discretionary-review.typ": ga-petition-for-discretionary-review, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-discretionary-review.md"))
#let (meta, body) = split-frontmatter(src)
#ga-petition-for-discretionary-review(meta, body)
