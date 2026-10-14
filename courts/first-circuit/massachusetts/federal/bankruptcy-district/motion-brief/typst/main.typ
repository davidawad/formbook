// Entry point. tools/render.sh compiles it with the court folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "mab-motion-brief.typ": mab-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-saint-ann-motion-to-dismiss.md"))
#let (meta, body) = split-frontmatter(src)
#mab-motion-brief(meta, body)
