// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-<id>.md \
//     typst/main.typ out.pdf
#import "prb-motion-brief.typ": prb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-perez-cruz-msj.md"))
#let (meta, body) = split-frontmatter(src)
#prb-motion-brief(meta, body)
