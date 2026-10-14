// Entry point. tools/render.sh compiles it with this folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "nmd-motion-brief.typ": nmd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-turner-motion.md"))
#let (meta, body) = split-frontmatter(src)
#nmd-motion-brief(meta, body)
