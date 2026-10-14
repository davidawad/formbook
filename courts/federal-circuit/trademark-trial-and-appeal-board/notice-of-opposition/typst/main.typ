// Entrypoint. Compile with the court-doc folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ttab-notice-of-opposition.typ": ttab-notice-of-opposition, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-brink-notice-of-opposition.md"))
#let (meta, body) = split-frontmatter(src)
#ttab-notice-of-opposition(meta, body)
