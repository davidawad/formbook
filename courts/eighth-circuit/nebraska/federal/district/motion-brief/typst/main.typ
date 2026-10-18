// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ned-motion-brief.typ": ned-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample"))
#let (meta, body) = split-frontmatter(src)
#ned-motion-brief(meta, body)
