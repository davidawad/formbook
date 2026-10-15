// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ga-petition-for-review.typ": ga-petition-for-review, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-dpg-emergency-petition.md"))
#let (meta, body) = split-frontmatter(src)
#ga-petition-for-review(meta, body)
