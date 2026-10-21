// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "texcrimapp-petition-for-rehearing.typ": texcrimapp-petition-for-rehearing, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-rehearing.md"))
#let (meta, body) = split-frontmatter(src)
#texcrimapp-petition-for-rehearing(meta, body)
