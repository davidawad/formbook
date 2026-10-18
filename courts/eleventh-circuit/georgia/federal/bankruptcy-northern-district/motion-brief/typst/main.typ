// Entrypoint. tools/render.sh compiles this with --root <doctype-dir> and --input sample=<md>:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ganb-motion-brief.typ": ganb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ganb-motion-brief-kapitus2302003.md"))
#let (meta, body) = split-frontmatter(src)
#ganb-motion-brief(meta, body)
