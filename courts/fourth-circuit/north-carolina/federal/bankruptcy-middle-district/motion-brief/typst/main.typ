// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ncmb-motion-brief.typ": ncmb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ncmb-motion-brief-eastwoodmsjbrief.md"))
#let (meta, body) = split-frontmatter(src)
#ncmb-motion-brief(meta, body)
