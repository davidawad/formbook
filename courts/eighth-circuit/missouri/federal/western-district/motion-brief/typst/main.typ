// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it (or the command in ../README.md):
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "mowd-motion-brief.typ": mowd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-mowd-motion-brief-mannonsuggestions.md"))
#let (meta, body) = split-frontmatter(src)
#mowd-motion-brief(meta, body)
