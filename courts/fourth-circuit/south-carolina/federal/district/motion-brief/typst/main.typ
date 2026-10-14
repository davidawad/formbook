// Entrypoint. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-<id>.md typst/main.typ out.pdf
#import "scd-motion-brief.typ": scd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-cobb-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#scd-motion-brief(meta, body)
