// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "vawb-motion-brief.typ": vawb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-vawb-motion-brief-thomasmidlandmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#vawb-motion-brief(meta, body)
