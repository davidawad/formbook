// Entrypoint. Compile with the court-doc folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ttab-notice-of-appearance.typ": ttab-notice-of-appearance, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-notice-of-appearance.md"))
#let (meta, body) = split-frontmatter(src)
#ttab-notice-of-appearance(meta, body)
