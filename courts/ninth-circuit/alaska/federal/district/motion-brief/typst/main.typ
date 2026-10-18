// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "akd-motion-brief.typ": akd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample"))   // required: render.sh passes --input sample=...
#let (meta, body) = split-frontmatter(src)
#akd-motion-brief(meta, body)
