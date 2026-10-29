// Entry point. Compile with the repo root as --root; tools/render.sh does it:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "kywd-motion-brief.typ": kywd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief-2.md"))
#let (meta, body) = split-frontmatter(src)
#kywd-motion-brief(meta, body)
