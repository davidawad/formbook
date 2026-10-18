// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "calsuperct-motion-brief.typ": calsuperct-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-calsuperct-motion-brief-aclufresno.md"))
#let (meta, body) = split-frontmatter(src)
#calsuperct-motion-brief(meta, body)
