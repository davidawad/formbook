// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "okwd-motion-brief.typ": okwd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-okwd-motion-brief-trupia.md"))
#let (meta, body) = split-frontmatter(src)
#okwd-motion-brief(meta, body)
