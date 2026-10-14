// Entrypoint. tools/render.sh compiles it with this doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "wvnb-motion-brief.typ": wvnb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-example-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#wvnb-motion-brief(meta, body)
