// Entry point. tools/render.sh compiles it with the repo root as --root:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-<id>.md typst/main.typ out.pdf
#import "scd-motion-brief.typ": scd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#scd-motion-brief(meta, body)
